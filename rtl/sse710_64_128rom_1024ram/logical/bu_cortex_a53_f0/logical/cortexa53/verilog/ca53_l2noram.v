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
// Description: Top level of the CortexA53 L2 memory system (without RAMs)
//-----------------------------------------------------------------------------

`include "ca53scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53_l2noram `CA53_L2_PARAM_DECL (
  // Inputs
  input wire                                      CLKIN,
  input wire                                      DFTSE,
  input wire                                      DFTRSTDISABLE,
  input wire                                      DFTRAMHOLD,
  input wire                                      DFTMCPHOLD,
  input wire [NUM_CPUS-1:0]                       ncpuporeset,
  input wire [NUM_CPUS-1:0]                       ncorereset,
  input wire                                      nl2reset,
  input wire                                      nmbistreset,
  input wire                                      l2rstdisable_i,
  input wire [NUM_CPUS-1:0]                       cfgend_i,
  input wire [NUM_CPUS-1:0]                       vinithi_i,
  input wire [NUM_CPUS-1:0]                       cfgte_i,
  input wire [NUM_CPUS-1:0]                       cp15sdisable_i,
  input wire [ 7:0]                               clusteridaff1_i,
  input wire [ 7:0]                               clusteridaff2_i,
  input wire [NUM_CPUS-1: 0]                      etm_oslock_i,
  input wire [NUM_CPUS-1:0]                       aa64naa32_i,
  input wire [(`CA53_RVBARADDR_PKDED_W-1):0]      rvbaraddr_i,
  input wire [NUM_CPUS-1:0]                       cryptodisable_i,
  input wire [NUM_CPUS-1:0]                       nfiq_i,
  input wire [NUM_CPUS-1:0]                       nirq_i,
  input wire [NUM_CPUS-1:0]                       nsei_i,
  input wire [NUM_CPUS-1:0]                       nrei_i,
  input wire [NUM_CPUS-1:0]                       nvfiq_i,
  input wire [NUM_CPUS-1:0]                       nvirq_i,
  input wire [NUM_CPUS-1:0]                       nvsei_i,
  input wire [ 39:18]                             periphbase_i,
  input wire                                      giccdisable_i,
  input wire                                      icdtvalid_i,
  input wire [ 15:0]                              icdtdata_i,
  input wire                                      icdtlast_i,
  input wire [ 1:0]                               icdtdest_i,
  input wire                                      icctready_i,
  input wire [ 63:0]                              cntvalueb_i,
  input wire                                      cntclken_i,
  input wire [ 63:0]                              tsvalueb_i,
  input wire                                      clrexmonreq_i,
  input wire                                      eventi_i,
  input wire                                      l2flushreq_i,
  input wire [NUM_CPUS-1:0]                       cpuqreqn_i,
  input wire [NUM_CPUS-1:0]                       neonqreqn_i,
  input wire                                      l2qreqn_i,
  input wire                                      broadcastcachemaint_i,
  input wire                                      broadcastinner_i,
  input wire                                      broadcastouter_i,
  input wire                                      aclkenm_i,
  input wire                                      acinactm_i,
  input wire                                      sysbardisable_i,
  input wire                                      awreadym_i,
  input wire                                      wreadym_i,
  input wire                                      bvalidm_i,
  input wire [`CA53_SCU_EXT_WID_W-1:0]            bidm_i,
  input wire [`CA53_ACE_BRESP_W-1:0]              brespm_i,
  input wire                                      arreadym_i,
  input wire                                      rvalidm_i,
  input wire [`CA53_SCU_EXT_RID_W-1:0]            ridm_i,
  input wire [`CA53_SCU_EXT_DATA_W-1:0]           rdatam_i,
  input wire [`CA53_ACE_RRESP_W-1:0]              rrespm_i,
  input wire                                      rlastm_i,
  input wire                                      acvalidm_i,
  input wire [`CA53_SCU_EXT_ADDR_W-1:0]           acaddrm_i,
  input wire [`CA53_ACE_ACPROT_W-1:0]             acprotm_i,
  input wire [`CA53_ACE_ACSNOOP_W-1:0]            acsnoopm_i,
  input wire                                      crreadym_i,
  input wire                                      cdreadym_i,
  input wire                                      sclken_i,
  input wire                                      sinact_i,
  input wire [6:0]                                nodeid_i,
  input wire                                      rxsactive_i,
  input wire                                      rxlinkactivereq_i,
  input wire                                      txlinkactiveack_i,
  input wire                                      txreqlcrdv_i,
  input wire                                      txrsplcrdv_i,
  input wire                                      txdatlcrdv_i,
  input wire                                      rxsnpflitpend_i,
  input wire                                      rxsnpflitv_i,
  input wire [64:0]                               rxsnpflit_i,
  input wire                                      rxrspflitpend_i,
  input wire                                      rxrspflitv_i,
  input wire [44:0]                               rxrspflit_i,
  input wire                                      rxdatflitpend_i,
  input wire                                      rxdatflitv_i,
  input wire [193:0]                              rxdatflit_i,
  input wire [1:0]                                samaddrmap0_i,
  input wire [1:0]                                samaddrmap1_i,
  input wire [1:0]                                samaddrmap2_i,
  input wire [1:0]                                samaddrmap3_i,
  input wire [1:0]                                samaddrmap4_i,
  input wire [1:0]                                samaddrmap5_i,
  input wire [1:0]                                samaddrmap6_i,
  input wire [1:0]                                samaddrmap7_i,
  input wire [1:0]                                samaddrmap8_i,
  input wire [1:0]                                samaddrmap9_i,
  input wire [1:0]                                samaddrmap10_i,
  input wire [1:0]                                samaddrmap11_i,
  input wire [1:0]                                samaddrmap12_i,
  input wire [1:0]                                samaddrmap13_i,
  input wire [1:0]                                samaddrmap14_i,
  input wire [1:0]                                samaddrmap15_i,
  input wire [39:24]                              sammnbase_i,
  input wire [6:0]                                sammnnodeid_i,
  input wire [6:0]                                samhni0nodeid_i,
  input wire [6:0]                                samhni1nodeid_i,
  input wire [6:0]                                samhnf0nodeid_i,
  input wire [6:0]                                samhnf1nodeid_i,
  input wire [6:0]                                samhnf2nodeid_i,
  input wire [6:0]                                samhnf3nodeid_i,
  input wire [6:0]                                samhnf4nodeid_i,
  input wire [6:0]                                samhnf5nodeid_i,
  input wire [6:0]                                samhnf6nodeid_i,
  input wire [6:0]                                samhnf7nodeid_i,
  input wire [2:0]                                samhnfmode_i,
  input wire                                      aclkens_i,
  input wire                                      ainacts_i,
  input wire                                      awvalids_i,
  input wire [ 4:0]                               awids_i,
  input wire [ 39:0]                              awaddrs_i,
  input wire [ 7:0]                               awlens_i,
  input wire [ 3:0]                               awcaches_i,
  input wire [ 1:0]                               awusers_i,
  input wire [ 2:0]                               awprots_i,
  input wire                                      wvalids_i,
  input wire [127:0]                              wdatas_i,
  input wire [ 15:0]                              wstrbs_i,
  input wire                                      wlasts_i,
  input wire                                      breadys_i,
  input wire                                      arvalids_i,
  input wire [ 4:0]                               arids_i,
  input wire [ 39:0]                              araddrs_i,
  input wire [ 7:0]                               arlens_i,
  input wire [ 3:0]                               arcaches_i,
  input wire [ 1:0]                               arusers_i,
  input wire [ 2:0]                               arprots_i,
  input wire                                      rreadys_i,
  input wire                                      npresetdbg_i,
  input wire                                      pclkendbg_i,
  input wire                                      pseldbg_i,
  input wire [ 21: 2]                             paddrdbg_i,
  input wire                                      paddrdbg31_i,
  input wire                                      penabledbg_i,
  input wire                                      pwritedbg_i,
  input wire [ 31:0]                              pwdatadbg_i,
  input wire [(`CA53_PRDATADBG_PKDED_W-1):0]      dpu_prdatadbg_i,
  input wire [NUM_CPUS-1:0]                       dpu_preadydbg_i,
  input wire [NUM_CPUS-1:0]                       dpu_pslverrdbg_i,
  input wire [(`CA53_PRDATADBG_PKDED_W-1):0]      etm_prdatadbg_i,
  input wire [NUM_CPUS-1:0]                       etm_preadydbg_i,
  input wire [(`CA53_ETMEXT_PKDED_W-1):0]         etm_extout_i,
  input wire [NUM_CPUS-1:0]                       dcu_excl_mon_cleared_i,
  input wire [(`CA53_CPADDR_PKDED_W-1):0]         dcu_cp_gov_addr_i,
  input wire [NUM_CPUS-1:0]                       dcu_cp_gov_ns_i,
  input wire [NUM_CPUS-1:0]                       dcu_cp_gov_req_i,
  input wire [(`CA53_CPSEL_PKDED_W-1):0]          dcu_cp_gov_sel_i,
  input wire [(`CA53_CPDATA_PKDED_W-1):0]         dcu_cp_gov_wdata_i,
  input wire [NUM_CPUS-1:0]                       dcu_cp_gov_wenable_i,
  input wire [ 39:12]                             dbgromaddr_i,
  input wire                                      dbgromaddrv_i,
  input wire [NUM_CPUS-1:0]                       edbgrq_i,
  input wire [NUM_CPUS-1:0]                       dbgen_i,
  input wire [NUM_CPUS-1:0]                       spiden_i,
  input wire [NUM_CPUS-1:0]                       niden_i,
  input wire [NUM_CPUS-1:0]                       spniden_i,
  input wire [NUM_CPUS-1:0]                       dbgpwrdup_i,
  input wire                                      dbgl1rstdisable_i,
  input wire                                      atclken_i,
  input wire [(`CA53_ATREADYM_PKDED_W-1):0]       atreadym_i,
  input wire [(`CA53_AFVALIDM_PKDED_W-1):0]       afvalidm_i,
  input wire [(`CA53_ATDATAM_PKDED_W-1):0]        etm_atdatam_i,
  input wire [(`CA53_ATVALIDM_PKDED_W-1):0]       etm_atvalidm_i,
  input wire [(`CA53_ATBYTESM_PKDED_W-1):0]       etm_atbytesm_i,
  input wire [(`CA53_AFREADYM_PKDED_W-1):0]       etm_afreadym_i,
  input wire [(`CA53_ATIDM_PKDED_W-1):0]          etm_atidm_i,
  input wire [(`CA53_SYNCREQM_PKDED_W-1):0]       syncreqm_i,
  input wire [3:0]                                ctichin_i,
  input wire [3:0]                                ctichoutack_i,
  input wire [NUM_CPUS-1:0]                       ctiirqack_i,
  input wire                                      cisbypass_i,
  input wire [3:0]                                cihsbypass_i,
  input wire [NUM_CPUS-1:0]                       dpu_warmrstreq_i,
  input wire [NUM_CPUS-1:0]                       dpu_dbgtrigger_i,
  input wire [NUM_CPUS-1:0]                       dpu_dbgack_i,
  input wire [NUM_CPUS-1:0]                       dpu_commrx_i,
  input wire [NUM_CPUS-1:0]                       dpu_commtx_i,
  input wire [NUM_CPUS-1:0]                       dpu_ncommirq_i,
  input wire [NUM_CPUS-1:0]                       dpu_dbgrstreq_i,
  input wire [NUM_CPUS-1:0]                       dpu_dbgnopwrdwn_i,
  input wire [NUM_CPUS-1:0]                       dpu_clr_event_register_i,
  input wire [(`CA53_EXCP_LEV_PKDED_W-1):0]       dpu_exception_level_i,
  input wire [NUM_CPUS-1:0]                       dpu_aarch64_at_el3_i,
  input wire [NUM_CPUS-1:0]                       dpu_hcr_el2_fmo_i,
  input wire [NUM_CPUS-1:0]                       dpu_hcr_el2_imo_i,
  input wire [NUM_CPUS-1:0]                       dpu_hcr_el2_amo_i,
  input wire [NUM_CPUS-1:0]                       dpu_monitor_mode_i,
  input wire [NUM_CPUS-1:0]                       dpu_rei_level_ack_i,
  input wire [NUM_CPUS-1:0]                       dpu_scr_el3_fiq_i,
  input wire [NUM_CPUS-1:0]                       dpu_scr_el3_irq_i,
  input wire [NUM_CPUS-1:0]                       dpu_scr_el3_ns_i,
  input wire [NUM_CPUS-1:0]                       dpu_sei_level_ack_i,
  input wire [NUM_CPUS-1:0]                       dpu_vsei_level_ack_i,
  input wire [NUM_CPUS-1:0]                       dpu_wfi_req_i,
  input wire [NUM_CPUS-1:0]                       dpu_wfe_req_i,
  input wire [NUM_CPUS-1:0]                       dpu_irq_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_fiq_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_sei_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_irq_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_fiq_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_sei_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_virq_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_vfiq_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_vsei_pended_i,
  input wire [NUM_CPUS-1:0]                       dpu_virq_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_vfiq_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_vsei_masked_i,
  input wire [NUM_CPUS-1:0]                       dpu_dbg_double_lock_set_i,
  input wire [NUM_CPUS-1:0]                       dpu_ns_state_i,
  input wire [NUM_CPUS-1:0]                       dpu_dscr_halted_i,
  input wire [NUM_CPUS-1:0]                       stb_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       biu_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       dcu_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       ifu_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       tlb_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       etm_wfx_ready_i,
  input wire [NUM_CPUS-1:0]                       dpu_imp_abort_pending_i,
  input wire [(`CA53_RET_CTL_PKDED_W-1):0]        dpu_cpuectlr_cpu_ret_delay_i,
  input wire [(`CA53_RET_CTL_PKDED_W-1):0]        dpu_cpuectlr_neon_ret_delay_i,
  input wire [NUM_CPUS-1: 0]                      dpu_neon_active_i,
  input wire [NUM_CPUS-1:0]                       dpu_npmuirq_i,
  input wire [(`CA53_PMUEVNT_CPU_PKDED_W-1):0]    dpu_pmuevent_i,
  input wire [NUM_CPUS-1:0]                       dpu_smp_en_i,
  input wire [NUM_CPUS-1:0]                       dpu_sev_req_i,
  input wire [(`CA53_ARACTIVE_PKDED_W-1):0]       biu_ar_active_i,
  input wire [(`CA53_ARVALID_PKDED_W-1):0]        biu_ar_valid_i,
  input wire [(`CA53_ARID_PKDED_W-1):0]           biu_ar_id_i,
  input wire [(`CA53_ARTYPE_PKDED_W-1):0]         biu_ar_type_i,
  input wire [(`CA53_ARATTRS_PKDED_W-1):0]        biu_ar_attrs_i,
  input wire [(`CA53_ARWAY_PKDED_W-1):0]          biu_ar_way_i,
  input wire [(`CA53_ARADDR_PKDED_W-1):0]         biu_ar_addr_i,
  input wire [(`CA53_ARLEN_PKDED_W-1):0]          biu_ar_len_i,
  input wire [(`CA53_ARSIZE_PKDED_W-1):0]         biu_ar_size_i,
  input wire [(`CA53_ARLOCK_PKDED_W-1):0]         biu_ar_lock_i,
  input wire [(`CA53_ARPRIV_PKDED_W-1):0]         biu_ar_priv_i,
  input wire [(`CA53_DRCREDIT_PKDED_W-1):0]       biu_dr_credit_i,
  input wire [(`CA53_DWVALID_PKDED_W-1):0]        biu_dw_valid_i,
  input wire [(`CA53_DWL2DB_PKDED_W-1):0]         biu_dw_l2db_id_i,
  input wire [(`CA53_DWCHUNKS_PKDED_W-1):0]       biu_dw_chunks_valid_i,
  input wire [(`CA53_DWLAST_PKDED_W-1):0]         biu_dw_last_i,
  input wire [(`CA53_DWSTRB_PKDED_W-1):0]         biu_dw_strb_i,
  input wire [(`CA53_DWDATA_PKDED_W-1):0]         biu_dw_data_i,
  input wire [(`CA53_DWERR_PKDED_W-1):0]          biu_dw_err_i,
  input wire [(`CA53_DWFATAL_PKDED_W-1):0]        biu_dw_fatal_i,
  input wire [(`CA53_ACREADY_PKDED_W-1):0]        dcu_ac_ready_i,
  input wire [(`CA53_CRVALID_PKDED_W-1):0]        dcu_cr_valid_i,
  input wire [(`CA53_CRID_PKDED_W-1):0]           dcu_cr_id_i,
  input wire [(`CA53_CRDIRTY_PKDED_W-1):0]        dcu_cr_dirty_i,
  input wire [(`CA53_CRAGE_PKDED_W-1):0]          dcu_cr_age_i,
  input wire [(`CA53_CRALLOC_PKDED_W-1):0]        dcu_cr_alloc_i,
  input wire [(`CA53_CRMIG_PKDED_W-1):0]          dcu_cr_migratory_i,
  input wire [(`CA53_DVM_COMP_PKDED_W-1):0]       dcu_dvm_complete_i,
  input wire                                      mbistreq_i,
  input wire [(`CA53_MBIST0_ADDR_W-1): 0]         mbistaddr0_i,
  input wire [(`CA53_MBIST1_ADDR_W-1): 0]         mbistaddr1_i,
  input wire [(`CA53_MBIST0_DATA_W-1): 0]         mbistindata0_i,
  input wire [(`CA53_MBIST1_DATA_W-1): 0]         mbistindata1_i,
  input wire                                      mbistwriteen0_i,
  input wire                                      mbistwriteen1_i,
  input wire                                      mbistreaden0_i,
  input wire                                      mbistreaden1_i,
  input wire [(`CA53_MBIST0_RAMARRAY_W-1):0]      mbistarray0_i,
  input wire [(`CA53_MBIST1_RAMARRAY_W-1):0]      mbistarray1_i,
  input wire [(`CA53_MBIST0_BE_W-1):0]            mbistbe0_i,
  input wire [(`CA53_MBIST1_BE_W-1):0]            mbistbe1_i,
  input wire                                      mbistcfg0_i,
  input wire                                      mbistcfg1_i,
  input wire [(`CA53_L1DC_SIZE_W-1):0]            l1_dc_size_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu0_way0_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu0_way1_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu0_way2_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu0_way3_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu1_way0_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu1_way1_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu1_way2_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu1_way3_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu2_way0_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu2_way1_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu2_way2_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu2_way3_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu3_way0_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu3_way1_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu3_way2_rdata_i,
  input wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]    l1d_tagram_cpu3_way3_rdata_i,
  input wire [`CA53_L2_SIZE_W-1:0]                l2_size_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way0_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way1_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way2_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way3_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way4_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way5_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way6_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way7_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way8_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way9_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way10_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way11_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way12_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way13_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way14_rdata_i,
  input wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]     l2_tagram_way15_rdata_i,
  input wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]  l2_victimram_rdata_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata0_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata1_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata2_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata3_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata4_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata5_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata6_i,
  input wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]    l2_dataram_rdata7_i,
  // Outputs
  output wire [NUM_CPUS-1:0]                      clk_cpu,
  output wire                                     clk,
  output wire [NUM_CPUS-1:0]                      reset_n_cpu,
  output wire [NUM_CPUS-1:0]                      po_reset_n_cpu,
  output wire [NUM_CPUS-1:0]                      warmrstreq_o,
  output wire [NUM_CPUS-1:0]                      gov_cfgend_o,
  output wire [NUM_CPUS-1:0]                      gov_vinithi_o,
  output wire [NUM_CPUS-1:0]                      gov_cfgte_o,
  output wire [NUM_CPUS-1:0]                      gov_cp15sdisable_o,
  output wire [ 7:0]                              gov_clusteridaff1_o,
  output wire [ 7:0]                              gov_clusteridaff2_o,
  output wire [NUM_CPUS-1:0]                      gov_aa64naa32_o,
  output wire [(`CA53_RVBARADDR_PKDED_W-1):0]     gov_rvbaraddr_o,
  output wire [NUM_CPUS-1:0]                      gov_cryptodisable_o,
  output wire [NUM_CPUS-1:0]                      gov_stall_neon_o,
  output wire [NUM_CPUS-1:0]                      gic_irq_o,
  output wire [NUM_CPUS-1:0]                      gic_fiq_o,
  output wire [NUM_CPUS-1:0]                      gic_virq_o,
  output wire [NUM_CPUS-1:0]                      gic_vfiq_o,
  output wire [NUM_CPUS-1:0]                      gov_sei_level_req_o,
  output wire [NUM_CPUS-1:0]                      gov_vsei_level_req_o,
  output wire [NUM_CPUS-1:0]                      gov_rei_level_req_o,
  output wire [NUM_CPUS-1:0]                      gov_int_active_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el1_ns_sre_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el1_s_sre_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el2_enable_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el2_sre_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el3_enable_o,
  output wire [NUM_CPUS-1:0]                      gic_icc_sre_el3_sre_o,
  output wire [NUM_CPUS-1:0]                      gic_ich_hcr_el2_tall0_o,
  output wire [NUM_CPUS-1:0]                      gic_ich_hcr_el2_tall1_o,
  output wire [NUM_CPUS-1:0]                      gic_ich_hcr_el2_tc_o,
  output wire [NUM_CPUS-1:0]                      nvcpumntirq_o,
  output wire [ 39:18]                            gov_periphbase_o,
  output wire                                     gov_giccdisable_o,
  output wire                                     icdtready_o,
  output wire                                     icctvalid_o,
  output wire [ 15:0]                             icctdata_o,
  output wire                                     icctlast_o,
  output wire [ 1:0]                              icctid_o,
  output wire [NUM_CPUS-1:0]                      gov_standbywfi_o,
  output wire [NUM_CPUS-1:0]                      gov_standbywfe_o,
  output wire [NUM_CPUS-1:0]                      standbywfi_o,
  output wire [NUM_CPUS-1:0]                      standbywfe_o,
  output wire                                     standbywfil2_o,
  output wire [NUM_CPUS-1: 0]                     gov_wfx_drain_req_o,
  output wire [NUM_CPUS-1: 0]                     gov_wfx_wake_o,
  output wire                                     clrexmonack_o,
  output wire                                     evento_o,
  output wire [NUM_CPUS-1:0]                      gov_mbistreq_cpu_o,
  output wire [NUM_CPUS-1:0]                      gov_event_reg_o,
  output wire [NUM_CPUS-1:0]                      ncntpsirq_o,
  output wire [NUM_CPUS-1:0]                      ncntpnsirq_o,
  output wire [NUM_CPUS-1:0]                      ncnthpirq_o,
  output wire [NUM_CPUS-1:0]                      ncntvirq_o,
  output wire [NUM_CPUS-1:0]                      gov_smpen_o,
  output wire [NUM_CPUS-1:0]                      cpuqactive_o,
  output wire [NUM_CPUS-1:0]                      cpuqdeny_o,
  output wire [NUM_CPUS-1:0]                      cpuqacceptn_o,
  output wire [NUM_CPUS-1:0]                      neonqactive_o,
  output wire [NUM_CPUS-1:0]                      neonqdeny_o,
  output wire [NUM_CPUS-1:0]                      neonqacceptn_o,
  output wire                                     l2qactive_o,
  output wire                                     l2qdeny_o,
  output wire                                     l2qacceptn_o,
  output wire                                     l2flushdone_o,
  output wire                                     nexterrirq_o,
  output wire                                     ninterrirq_o,
  output wire [NUM_CPUS-1:0]                      scu_broadcastinner_o,
  output wire                                     scu_ext_ar_valid_o,
  output wire [(`CA53_SCU_EXT_ADDR_W-1):0]        scu_ext_ar_addr_o,
  output wire [(`CA53_ACE_ARLEN_W-1):0]           scu_ext_ar_len_o,
  output wire [(`CA53_ACE_ARSIZE_W-1):0]          scu_ext_ar_size_o,
  output wire [(`CA53_ACE_ARBURST_W-1):0]         scu_ext_ar_burst_o,
  output wire                                     scu_ext_ar_lock_o,
  output wire [(`CA53_ACE_ARCACHE_W-1):0]         scu_ext_ar_cache_o,
  output wire [(`CA53_ACE_ARPROT_W-1):0]          scu_ext_ar_prot_o,
  output wire [(`CA53_ACE_ARDOMAIN_W-1):0]        scu_ext_ar_domain_o,
  output wire [(`CA53_ACE_ARSNOOP_W-1):0]         scu_ext_ar_snoop_o,
  output wire [(`CA53_ACE_ARBAR_W-1):0]           scu_ext_ar_bar_o,
  output wire [(`CA53_SCU_EXT_RID_W-1):0]         scu_ext_ar_id_o,
  output wire [7:0]                               scu_ext_rdmemattr_o,
  output wire                                     scu_ext_dr_ready_o,
  output wire                                     scu_ext_aw_valid_o,
  output wire [(`CA53_SCU_EXT_ADDR_W-1):0]        scu_ext_aw_addr_o,
  output wire [(`CA53_ACE_AWLEN_W-1):0]           scu_ext_aw_len_o,
  output wire [(`CA53_ACE_AWSIZE_W-1):0]          scu_ext_aw_size_o,
  output wire [(`CA53_ACE_AWBURST_W-1):0]         scu_ext_aw_burst_o,
  output wire                                     scu_ext_aw_lock_o,
  output wire [(`CA53_ACE_AWCACHE_W-1):0]         scu_ext_aw_cache_o,
  output wire [(`CA53_ACE_AWPROT_W-1):0]          scu_ext_aw_prot_o,
  output wire [(`CA53_SCU_EXT_WID_W-1):0]         scu_ext_aw_id_o,
  output wire [(`CA53_ACE_AWDOMAIN_W-1):0]        scu_ext_aw_domain_o,
  output wire [(`CA53_ACE_AWSNOOP_W-1):0]         scu_ext_aw_snoop_o,
  output wire [(`CA53_ACE_AWBAR_W-1):0]           scu_ext_aw_bar_o,
  output wire                                     scu_ext_aw_unique_o,
  output wire [7:0]                               scu_ext_wrmemattr_o,
  output wire [(`CA53_SCU_EXT_STRB_W-1):0]        scu_ext_dw_strb_o,
  output wire [(`CA53_SCU_EXT_DATA_W-1):0]        scu_ext_dw_data_o,
  output wire [(`CA53_SCU_EXT_WID_W-1):0]         scu_ext_dw_id_o,
  output wire                                     scu_ext_dw_last_o,
  output wire                                     scu_ext_dw_valid_o,
  output wire                                     scu_ext_db_ready_o,
  output wire                                     scu_ext_ac_ready_o,
  output wire                                     scu_ext_cr_valid_o,
  output wire [(`CA53_ACE_CRRESP_W-1):0]          scu_ext_cr_resp_o,
  output wire                                     scu_ext_cd_valid_o,
  output wire [(`CA53_SCU_EXT_DATA_W-1):0]        scu_ext_cd_data_o,
  output wire                                     scu_ext_cd_last_o,
  output wire                                     scu_ext_rack_o,
  output wire                                     scu_ext_wack_o,
  output wire [NUM_CPUS-1:0]                      gov_pseldbg_dbg_o,
  output wire [NUM_CPUS-1:0]                      gov_pseldbg_pmu_o,
  output wire [NUM_CPUS-1:0]                      gov_pseldbg_etm_o,
  output wire [(`CA53_PADDRDBG_PKDED_W-1):0]      gov_paddrdbg_o,
  output wire [NUM_CPUS-1:0]                      gov_paddrdbg31_o,
  output wire [NUM_CPUS-1:0]                      gov_penabledbg_o,
  output wire [NUM_CPUS-1:0]                      gov_pwritedbg_o,
  output wire [(`CA53_PWDATADBG_PKDED_W-1):0]     gov_pwdatadbg_o,
  output wire                                     scu_txsactive_o,
  output wire                                     scu_rxlinkactiveack_o,
  output wire                                     scu_txlinkactivereq_o,
  output wire                                     scu_txreqflitpend_o,
  output wire                                     scu_txreqflitv_o,
  output wire [99:0]                              scu_txreqflit_o,
  output wire [7:0]                               scu_reqmemattr_o,
  output wire                                     scu_txrspflitpend_o,
  output wire                                     scu_txrspflitv_o,
  output wire [44:0]                              scu_txrspflit_o,
  output wire                                     scu_txdatflitpend_o,
  output wire                                     scu_txdatflitv_o,
  output wire [193:0]                             scu_txdatflit_o,
  output wire                                     scu_rxsnplcrdv_o,
  output wire                                     scu_rxrsplcrdv_o,
  output wire                                     scu_rxdatlcrdv_o,
  output wire                                     scu_acp_awready_o,
  output wire                                     scu_acp_wready_o,
  output wire                                     scu_acp_bvalid_o,
  output wire [ 4:0]                              scu_acp_bid_o,
  output wire [ 1:0]                              scu_acp_bresp_o,
  output wire                                     scu_acp_arready_o,
  output wire                                     scu_acp_rvalid_o,
  output wire [ 4:0]                              scu_acp_rid_o,
  output wire [127:0]                             scu_acp_rdata_o,
  output wire [ 1:0]                              scu_acp_rresp_o,
  output wire                                     scu_acp_rlast_o,
  output wire [ 31:0]                             prdatadbg_o,
  output wire                                     preadydbg_o,
  output wire                                     pslverrdbg_o,
  output wire [NUM_CPUS-1:0]                      ncommirq_o,
  output wire [NUM_CPUS-1:0]                      dbgack_o,
  output wire [NUM_CPUS-1:0]                      commrx_o,
  output wire [NUM_CPUS-1:0]                      commtx_o,
  output wire [NUM_CPUS-1:0]                      dbgrstreq_o,
  output wire [NUM_CPUS-1:0]                      dbgnopwrdwn_o,
  output wire [NUM_CPUS-1:0]                      gov_dbgpwrupreq_o,
  output wire [NUM_CPUS-1:0]                      dbgpwrupreq_o,
  output wire [NUM_CPUS-1:0]                      gov_dbgl1rstdisable_o,
  output wire [(`CA53_ETMEXT_PKDED_W-1):0]        gov_extin_o,
  output wire [NUM_CPUS-1:0]                      gov_edecr_osuce_o,
  output wire [NUM_CPUS-1:0]                      gov_edecr_rce_o,
  output wire [NUM_CPUS-1:0]                      gov_edecr_ss_o,
  output wire [NUM_CPUS-1:0]                      gov_edlsr_slk_o,
  output wire [NUM_CPUS-1:0]                      gov_pmlsr_slk_o,
  output wire [NUM_CPUS-1:0]                      gov_etmpdsr_rd_o,
  output wire [ 39:12]                            gov_dbgromaddr_o,
  output wire                                     gov_dbgromaddrv_o,
  output wire [NUM_CPUS-1:0]                      gov_edbgrq_o,
  output wire [NUM_CPUS-1:0]                      gov_dbgen_o,
  output wire [NUM_CPUS-1:0]                      gov_spiden_o,
  output wire [NUM_CPUS-1:0]                      gov_niden_o,
  output wire [NUM_CPUS-1:0]                      gov_spniden_o,
  output wire [NUM_CPUS-1:0]                      gov_dbgrestart_o,
  output wire [NUM_CPUS-1:0]                      gov_stall_dsb_o,
  output wire [NUM_CPUS-1:0]                      gov_cp_ack_o,
  output wire [(`CA53_CPDATA_PKDED_W-1):0]        gov_cp_rdata_o,
  output wire [NUM_CPUS-1:0]                      gov_pcnt_kernel_access_o,
  output wire [NUM_CPUS-1:0]                      gov_pcnt_usr_access_o,
  output wire [NUM_CPUS-1:0]                      gov_vcnt_usr_access_o,
  output wire [NUM_CPUS-1:0]                      gov_cntp_usr_access_o,
  output wire [NUM_CPUS-1:0]                      gov_cntv_usr_access_o,
  output wire [NUM_CPUS-1:0]                      gov_cntp_kernel_access_o,
  output wire [63:0]                              gov_tsvalueb_o,
  output wire [NUM_CPUS-1: 0]                     gov_atclken_o,
  output wire [(`CA53_ATREADYM_PKDED_W-1):0]      gov_atreadym_o,
  output wire [(`CA53_AFVALIDM_PKDED_W-1):0]      gov_afvalidm_o,
  output wire [(`CA53_ATDATAM_PKDED_W-1):0]       atdatam_o,
  output wire [(`CA53_ATVALIDM_PKDED_W-1):0]      atvalidm_o,
  output wire [(`CA53_ATBYTESM_PKDED_W-1):0]      atbytesm_o,
  output wire [(`CA53_AFREADYM_PKDED_W-1):0]      afreadym_o,
  output wire [(`CA53_ATIDM_PKDED_W-1):0]         atidm_o,
  output wire [(`CA53_SYNCREQM_PKDED_W-1):0]      gov_syncreqm_o,
  output wire [NUM_CPUS-1:0]                      npmuirq_o,
  output wire [(`CA53_PMUEVNT_PKDED_W-1):0]       pmuevent_o,
  output wire [(`CA53_ARCREDIT_PKDED_W-1):0]      scu_ar_credit_o,
  output wire [(`CA53_ARBLOCK_PKDED_W-1):0]       scu_ar_block_o,
  output wire [(`CA53_DRVALID_PKDED_W-1):0]       scu_dr_valid_o,
  output wire [(`CA53_DRID_PKDED_W-1):0]          scu_dr_id_o,
  output wire [(`CA53_DRRESP_PKDED_W-1):0]        scu_dr_resp_o,
  output wire [(`CA53_DRCHUNK_PKDED_W-1):0]       scu_dr_chunk_o,
  output wire [(`CA53_DRDATA_PKDED_W-1):0]        scu_dr_data_o,
  output wire [(`CA53_RRVALID_PKDED_W-1):0]       scu_rr_valid_o,
  output wire [(`CA53_RRID_PKDED_W-1):0]          scu_rr_id_o,
  output wire [(`CA53_RRRESP_PKDED_W-1):0]        scu_rr_resp_o,
  output wire [(`CA53_RRL2DB_PKDED_W-1):0]        scu_rr_l2db_id_o,
  output wire [(`CA53_EVDONE_PKDED_W-1):0]        scu_ev_done_o,
  output wire [(`CA53_DBEXCLVAL_PKDED_W-1):0]     scu_db_excl_valid_o,
  output wire [(`CA53_DBEXCLRSP_PKDED_W-1):0]     scu_db_excl_resp_o,
  output wire [(`CA53_DBDECERR_PKDED_W-1):0]      scu_db_decerr_o,
  output wire [(`CA53_DBSLVERR_PKDED_W-1):0]      scu_db_slverr_o,
  output wire [(`CA53_LEAVERAM_PKDED_W-1):0]      scu_leave_ramode_o,
  output wire [(`CA53_ACVALID_PKDED_W-1):0]       scu_ac_valid_o,
  output wire [(`CA53_ACID_PKDED_W-1):0]          scu_ac_id_o,
  output wire [(`CA53_ACL2DB_PKDED_W-1):0]        scu_ac_l2db_id_o,
  output wire [(`CA53_ACSNOOP_PKDED_W-1):0]       scu_ac_snoop_o,
  output wire [(`CA53_ACADDR_PKDED_W-1):0]        scu_ac_addr_o,
  output wire [(`CA53_ACWAY_PKDED_W-1):0]         scu_ac_way_o,
  output wire [(`CA53_DVM_COMP_PKDED_W-1):0]      scu_dvm_complete_o,
  output wire [(`CA53_REQBUFS_BUSY_PKDED_W-1):0]  scu_reqbufs_busy_o,
  output wire [(`CA53_DRAIN_STB_PKDED_W-1):0]     scu_drain_stb_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_l2_access_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_l2_refill_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_l2_wb_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_snooped_data_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_bus_cycle_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_bus_acc_rd_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_bus_acc_wr_o,
  output wire [NUM_CPUS-1:0]                      scu_evnt_eviction_o,
  output wire [3:0]                               ctichout_o,
  output wire [3:0]                               ctichinack_o,
  output wire [NUM_CPUS-1:0]                      ctiirq_o,
  output wire                                     mbistack0_o,
  output wire                                     mbistack1_o,
  output wire [(`CA53_MBIST0_DATA_W-1): 0]        mbistoutdata0_o,
  output wire [(`CA53_MBIST1_DATA_W-1): 0]        mbistoutdata1_o,
  output wire                                     l1d_tagram_clken_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu0_en_o,
  output wire                                     l1d_tagram_cpu0_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu0_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu1_en_o,
  output wire                                     l1d_tagram_cpu1_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu1_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu2_en_o,
  output wire                                     l1d_tagram_cpu2_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu2_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu3_en_o,
  output wire                                     l1d_tagram_cpu3_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu3_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_wdata_o,
  output wire                                     l2_tagram_clken_o,
  output wire [`CA53_SCU_L2_ASSOC-1:0]            l2_tagram_en_o,
  output wire                                     l2_tagram_wr_o,
  output wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]    l2_tagram_addr_o,
  output wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_wdata_o,
  output wire                                     l2_victimram_no_acc_next_cycle_o,
  output wire                                     l2_victimram_clken_o,
  output wire                                     l2_victimram_en_o,
  output wire                                     l2_victimram_wr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata_o,
  output wire                                     l2_dataram_no_acc_next_cycle_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]     l2_dataram_clken_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]     l2_dataram_en_o,
  output wire                                     l2_dataram_wr_o,
  output wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0]   l2_dataram_addr_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata0_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata1_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata2_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata3_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata4_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata5_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata6_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata7_o
);

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar cpu;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(`CA53_ARACTIVE_W-1):0]          biu_cpu0_ar_active;
  wire [(`CA53_ARVALID_W-1):0]           biu_cpu0_ar_valid;
  wire [(`CA53_ARID_W-1):0]              biu_cpu0_ar_id;
  wire [(`CA53_ARTYPE_W-1):0]            biu_cpu0_ar_type;
  wire [(`CA53_ARATTRS_W-1):0]           biu_cpu0_ar_attrs;
  wire [(`CA53_ARWAY_W-1):0]             biu_cpu0_ar_way;
  wire [(`CA53_ARADDR_W-1):0]            biu_cpu0_ar_addr;
  wire [(`CA53_ARLEN_W-1):0]             biu_cpu0_ar_len;
  wire [(`CA53_ARSIZE_W-1):0]            biu_cpu0_ar_size;
  wire [(`CA53_ARLOCK_W-1):0]            biu_cpu0_ar_lock;
  wire [(`CA53_ARPRIV_W-1):0]            biu_cpu0_ar_priv;
  wire [(`CA53_DRCREDIT_W-1):0]          biu_cpu0_dr_credit;
  wire [(`CA53_DWVALID_W-1):0]           biu_cpu0_dw_valid;
  wire [(`CA53_DWL2DB_W-1):0]            biu_cpu0_dw_l2db_id;
  wire [(`CA53_DWCHUNKS_W-1):0]          biu_cpu0_dw_chunks_valid;
  wire [(`CA53_DWLAST_W-1):0]            biu_cpu0_dw_last;
  wire [(`CA53_DWSTRB_W-1):0]            biu_cpu0_dw_strb;
  wire [(`CA53_DWDATA_W-1):0]            biu_cpu0_dw_data;
  wire [(`CA53_DWERR_W-1):0]             biu_cpu0_dw_err;
  wire [(`CA53_DWFATAL_W-1):0]           biu_cpu0_dw_fatal;
  wire [(`CA53_ACREADY_W-1):0]           dcu_cpu0_ac_ready;
  wire [(`CA53_CRVALID_W-1):0]           dcu_cpu0_cr_valid;
  wire [(`CA53_CRID_W-1):0]              dcu_cpu0_cr_id;
  wire [(`CA53_CRDIRTY_W-1):0]           dcu_cpu0_cr_dirty;
  wire [(`CA53_CRAGE_W-1):0]             dcu_cpu0_cr_age;
  wire [(`CA53_CRALLOC_W-1):0]           dcu_cpu0_cr_alloc;
  wire [(`CA53_CRMIG_W-1):0]             dcu_cpu0_cr_migratory;
  wire [(`CA53_DVM_COMP_W-1):0]          dcu_cpu0_dvm_complete;
  wire                                   gov_cpu0_inv_all_req;
  wire                                   gov_cpu0_smp_en;
  wire [(`CA53_ARACTIVE_W-1):0]          biu_cpu1_ar_active;
  wire [(`CA53_ARVALID_W-1):0]           biu_cpu1_ar_valid;
  wire [(`CA53_ARID_W-1):0]              biu_cpu1_ar_id;
  wire [(`CA53_ARTYPE_W-1):0]            biu_cpu1_ar_type;
  wire [(`CA53_ARATTRS_W-1):0]           biu_cpu1_ar_attrs;
  wire [(`CA53_ARWAY_W-1):0]             biu_cpu1_ar_way;
  wire [(`CA53_ARADDR_W-1):0]            biu_cpu1_ar_addr;
  wire [(`CA53_ARLEN_W-1):0]             biu_cpu1_ar_len;
  wire [(`CA53_ARSIZE_W-1):0]            biu_cpu1_ar_size;
  wire [(`CA53_ARLOCK_W-1):0]            biu_cpu1_ar_lock;
  wire [(`CA53_ARPRIV_W-1):0]            biu_cpu1_ar_priv;
  wire [(`CA53_DRCREDIT_W-1):0]          biu_cpu1_dr_credit;
  wire [(`CA53_DWVALID_W-1):0]           biu_cpu1_dw_valid;
  wire [(`CA53_DWL2DB_W-1):0]            biu_cpu1_dw_l2db_id;
  wire [(`CA53_DWCHUNKS_W-1):0]          biu_cpu1_dw_chunks_valid;
  wire [(`CA53_DWLAST_W-1):0]            biu_cpu1_dw_last;
  wire [(`CA53_DWSTRB_W-1):0]            biu_cpu1_dw_strb;
  wire [(`CA53_DWDATA_W-1):0]            biu_cpu1_dw_data;
  wire [(`CA53_DWERR_W-1):0]             biu_cpu1_dw_err;
  wire [(`CA53_DWFATAL_W-1):0]           biu_cpu1_dw_fatal;
  wire [(`CA53_ACREADY_W-1):0]           dcu_cpu1_ac_ready;
  wire [(`CA53_CRVALID_W-1):0]           dcu_cpu1_cr_valid;
  wire [(`CA53_CRID_W-1):0]              dcu_cpu1_cr_id;
  wire [(`CA53_CRDIRTY_W-1):0]           dcu_cpu1_cr_dirty;
  wire [(`CA53_CRAGE_W-1):0]             dcu_cpu1_cr_age;
  wire [(`CA53_CRALLOC_W-1):0]           dcu_cpu1_cr_alloc;
  wire [(`CA53_CRMIG_W-1):0]             dcu_cpu1_cr_migratory;
  wire [(`CA53_DVM_COMP_W-1):0]          dcu_cpu1_dvm_complete;
  wire                                   gov_cpu1_inv_all_req;
  wire                                   gov_cpu1_smp_en;
  wire [(`CA53_ARACTIVE_W-1):0]          biu_cpu2_ar_active;
  wire [(`CA53_ARVALID_W-1):0]           biu_cpu2_ar_valid;
  wire [(`CA53_ARID_W-1):0]              biu_cpu2_ar_id;
  wire [(`CA53_ARTYPE_W-1):0]            biu_cpu2_ar_type;
  wire [(`CA53_ARATTRS_W-1):0]           biu_cpu2_ar_attrs;
  wire [(`CA53_ARWAY_W-1):0]             biu_cpu2_ar_way;
  wire [(`CA53_ARADDR_W-1):0]            biu_cpu2_ar_addr;
  wire [(`CA53_ARLEN_W-1):0]             biu_cpu2_ar_len;
  wire [(`CA53_ARSIZE_W-1):0]            biu_cpu2_ar_size;
  wire [(`CA53_ARLOCK_W-1):0]            biu_cpu2_ar_lock;
  wire [(`CA53_ARPRIV_W-1):0]            biu_cpu2_ar_priv;
  wire [(`CA53_DRCREDIT_W-1):0]          biu_cpu2_dr_credit;
  wire [(`CA53_DWVALID_W-1):0]           biu_cpu2_dw_valid;
  wire [(`CA53_DWL2DB_W-1):0]            biu_cpu2_dw_l2db_id;
  wire [(`CA53_DWCHUNKS_W-1):0]          biu_cpu2_dw_chunks_valid;
  wire [(`CA53_DWLAST_W-1):0]            biu_cpu2_dw_last;
  wire [(`CA53_DWSTRB_W-1):0]            biu_cpu2_dw_strb;
  wire [(`CA53_DWDATA_W-1):0]            biu_cpu2_dw_data;
  wire [(`CA53_DWERR_W-1):0]             biu_cpu2_dw_err;
  wire [(`CA53_DWFATAL_W-1):0]           biu_cpu2_dw_fatal;
  wire [(`CA53_ACREADY_W-1):0]           dcu_cpu2_ac_ready;
  wire [(`CA53_CRVALID_W-1):0]           dcu_cpu2_cr_valid;
  wire [(`CA53_CRID_W-1):0]              dcu_cpu2_cr_id;
  wire [(`CA53_CRDIRTY_W-1):0]           dcu_cpu2_cr_dirty;
  wire [(`CA53_CRAGE_W-1):0]             dcu_cpu2_cr_age;
  wire [(`CA53_CRALLOC_W-1):0]           dcu_cpu2_cr_alloc;
  wire [(`CA53_CRMIG_W-1):0]             dcu_cpu2_cr_migratory;
  wire [(`CA53_DVM_COMP_W-1):0]          dcu_cpu2_dvm_complete;
  wire                                   gov_cpu2_inv_all_req;
  wire                                   gov_cpu2_smp_en;
  wire [(`CA53_ARACTIVE_W-1):0]          biu_cpu3_ar_active;
  wire [(`CA53_ARVALID_W-1):0]           biu_cpu3_ar_valid;
  wire [(`CA53_ARID_W-1):0]              biu_cpu3_ar_id;
  wire [(`CA53_ARTYPE_W-1):0]            biu_cpu3_ar_type;
  wire [(`CA53_ARATTRS_W-1):0]           biu_cpu3_ar_attrs;
  wire [(`CA53_ARWAY_W-1):0]             biu_cpu3_ar_way;
  wire [(`CA53_ARADDR_W-1):0]            biu_cpu3_ar_addr;
  wire [(`CA53_ARLEN_W-1):0]             biu_cpu3_ar_len;
  wire [(`CA53_ARSIZE_W-1):0]            biu_cpu3_ar_size;
  wire [(`CA53_ARLOCK_W-1):0]            biu_cpu3_ar_lock;
  wire [(`CA53_ARPRIV_W-1):0]            biu_cpu3_ar_priv;
  wire [(`CA53_DRCREDIT_W-1):0]          biu_cpu3_dr_credit;
  wire [(`CA53_DWVALID_W-1):0]           biu_cpu3_dw_valid;
  wire [(`CA53_DWL2DB_W-1):0]            biu_cpu3_dw_l2db_id;
  wire [(`CA53_DWCHUNKS_W-1):0]          biu_cpu3_dw_chunks_valid;
  wire [(`CA53_DWLAST_W-1):0]            biu_cpu3_dw_last;
  wire [(`CA53_DWSTRB_W-1):0]            biu_cpu3_dw_strb;
  wire [(`CA53_DWDATA_W-1):0]            biu_cpu3_dw_data;
  wire [(`CA53_DWERR_W-1):0]             biu_cpu3_dw_err;
  wire [(`CA53_DWFATAL_W-1):0]           biu_cpu3_dw_fatal;
  wire [(`CA53_ACREADY_W-1):0]           dcu_cpu3_ac_ready;
  wire [(`CA53_CRVALID_W-1):0]           dcu_cpu3_cr_valid;
  wire [(`CA53_CRID_W-1):0]              dcu_cpu3_cr_id;
  wire [(`CA53_CRDIRTY_W-1):0]           dcu_cpu3_cr_dirty;
  wire [(`CA53_CRAGE_W-1):0]             dcu_cpu3_cr_age;
  wire [(`CA53_CRALLOC_W-1):0]           dcu_cpu3_cr_alloc;
  wire [(`CA53_CRMIG_W-1):0]             dcu_cpu3_cr_migratory;
  wire [(`CA53_DVM_COMP_W-1):0]          dcu_cpu3_dvm_complete;
  wire                                   gov_cpu3_inv_all_req;
  wire                                   gov_cpu3_smp_en;
  wire                                   scu_ext_aclken;
  wire                                   scu_ext_ar_ready;
  wire [(`CA53_SCU_EXT_RID_W-1):0]       scu_ext_dr_id;
  wire                                   scu_ext_dr_valid;
  wire                                   scu_ext_dr_last;
  wire [(`CA53_SCU_EXT_DATA_W-1):0]      scu_ext_dr_data;
  wire [(`CA53_ACE_RRESP_W-1):0]         scu_ext_dr_resp;
  wire                                   scu_ext_aw_ready;
  wire                                   scu_ext_dw_ready;
  wire [(`CA53_SCU_EXT_WID_W-1):0]       scu_ext_db_id;
  wire [(`CA53_ACE_BRESP_W-1):0]         scu_ext_db_resp;
  wire                                   scu_ext_db_valid;
  wire                                   scu_ext_ac_valid;
  wire [(`CA53_SCU_EXT_ADDR_W-1):0]      scu_ext_ac_addr;
  wire [(`CA53_ACE_ACPROT_W-1):0]        scu_ext_ac_prot;
  wire [(`CA53_ACE_ACSNOOP_W-1):0]       scu_ext_ac_snoop;
  wire                                   scu_ext_cr_ready;
  wire                                   scu_ext_cd_ready;
  wire                                   ext_sclken;
  wire                                   ext_sinact;
  wire [6:0]                             ext_nodeid;
  wire                                   ext_rxsactive;
  wire                                   ext_rxlinkactivereq;
  wire                                   ext_txlinkactiveack;
  wire                                   ext_txreqlcrdv;
  wire                                   ext_txrsplcrdv;
  wire                                   ext_txdatlcrdv;
  wire                                   ext_rxsnpflitpend;
  wire                                   ext_rxsnpflitv;
  wire [64:0]                            ext_rxsnpflit;
  wire                                   ext_rxrspflitpend;
  wire                                   ext_rxrspflitv;
  wire [44:0]                            ext_rxrspflit;
  wire                                   ext_rxdatflitpend;
  wire                                   ext_rxdatflitv;
  wire [193:0]                           ext_rxdatflit;
  wire [1:0]                             ext_samaddrmap0;
  wire [1:0]                             ext_samaddrmap1;
  wire [1:0]                             ext_samaddrmap2;
  wire [1:0]                             ext_samaddrmap3;
  wire [1:0]                             ext_samaddrmap4;
  wire [1:0]                             ext_samaddrmap5;
  wire [1:0]                             ext_samaddrmap6;
  wire [1:0]                             ext_samaddrmap7;
  wire [1:0]                             ext_samaddrmap8;
  wire [1:0]                             ext_samaddrmap9;
  wire [1:0]                             ext_samaddrmap10;
  wire [1:0]                             ext_samaddrmap11;
  wire [1:0]                             ext_samaddrmap12;
  wire [1:0]                             ext_samaddrmap13;
  wire [1:0]                             ext_samaddrmap14;
  wire [1:0]                             ext_samaddrmap15;
  wire [39:24]                           ext_sammnbase;
  wire [6:0]                             ext_sammnnodeid;
  wire [6:0]                             ext_samhni0nodeid;
  wire [6:0]                             ext_samhni1nodeid;
  wire [6:0]                             ext_samhnf0nodeid;
  wire [6:0]                             ext_samhnf1nodeid;
  wire [6:0]                             ext_samhnf2nodeid;
  wire [6:0]                             ext_samhnf3nodeid;
  wire [6:0]                             ext_samhnf4nodeid;
  wire [6:0]                             ext_samhnf5nodeid;
  wire [6:0]                             ext_samhnf6nodeid;
  wire [6:0]                             ext_samhnf7nodeid;
  wire [2:0]                             ext_samhnfmode;
  wire                                   ext_acp_aclken;
  wire                                   ext_acp_ainact;
  wire                                   ext_acp_awvalid;
  wire [4:0]                             ext_acp_awid;
  wire [39:0]                            ext_acp_awaddr;
  wire [7:0]                             ext_acp_awlen;
  wire [3:0]                             ext_acp_awcache;
  wire [1:0]                             ext_acp_awuser;
  wire [2:0]                             ext_acp_awprot;
  wire                                   ext_acp_wvalid;
  wire [127:0]                           ext_acp_wdata;
  wire [15:0]                            ext_acp_wstrb;
  wire                                   ext_acp_wlast;
  wire                                   ext_acp_bready;
  wire                                   ext_acp_arvalid;
  wire [4:0]                             ext_acp_arid;
  wire [39:0]                            ext_acp_araddr;
  wire [7:0]                             ext_acp_arlen;
  wire [3:0]                             ext_acp_arcache;
  wire [1:0]                             ext_acp_aruser;
  wire [2:0]                             ext_acp_arprot;
  wire                                   ext_acp_rready;
  wire [NUM_CPUS-1:0]                    gov_inv_all_req;
  wire [NUM_CPUS-1:0]                    scu_inv_all_ack;
  wire                                   scu_cpu0_inv_all_ack;
  wire                                   scu_cpu1_inv_all_ack;
  wire                                   scu_cpu2_inv_all_ack;
  wire                                   scu_cpu3_inv_all_ack;
  wire                                   scu_cpu0_broadcastinner;
  wire                                   scu_cpu1_broadcastinner;
  wire                                   scu_cpu2_broadcastinner;
  wire                                   scu_cpu3_broadcastinner;
  wire                                   scu_cpu0_ar_credit;
  wire                                   scu_cpu0_ar_block;
  wire                                   scu_cpu0_dr_valid;
  wire [(`CA53_DRID_W-1):0]              scu_cpu0_dr_id;
  wire [(`CA53_DRRESP_W-1):0]            scu_cpu0_dr_resp;
  wire [(`CA53_DRCHUNK_W-1):0]           scu_cpu0_dr_chunk;
  wire [(`CA53_DRDATA_W-1):0]            scu_cpu0_dr_data;
  wire                                   scu_cpu0_rr_valid;
  wire [(`CA53_RRID_W-1):0]              scu_cpu0_rr_id;
  wire [(`CA53_RRRESP_W-1):0]            scu_cpu0_rr_resp;
  wire [(`CA53_RRL2DB_W-1):0]            scu_cpu0_rr_l2db_id;
  wire [(`CA53_EVDONE_W-1):0]            scu_cpu0_ev_done;
  wire [(`CA53_DBEXCLVAL_W-1):0]         scu_cpu0_db_excl_valid;
  wire [(`CA53_DBEXCLRSP_W-1):0]         scu_cpu0_db_excl_resp;
  wire [(`CA53_DBDECERR_W-1):0]          scu_cpu0_db_decerr;
  wire [(`CA53_DBSLVERR_W-1):0]          scu_cpu0_db_slverr;
  wire [(`CA53_LEAVERAM_W-1):0]          scu_cpu0_leave_ramode;
  wire [(`CA53_ACVALID_W-1):0]           scu_cpu0_ac_valid;
  wire [(`CA53_ACID_W-1):0]              scu_cpu0_ac_id;
  wire [(`CA53_ACL2DB_W-1):0]            scu_cpu0_ac_l2db_id;
  wire [(`CA53_ACSNOOP_W-1):0]           scu_cpu0_ac_snoop;
  wire [40:0]                            scu_cpu0_ac_addr;
  wire [(`CA53_ACWAY_W-1):0]             scu_cpu0_ac_way;
  wire [(`CA53_DVM_COMP_W-1):0]          scu_cpu0_dvm_complete;
  wire [(`CA53_REQBUFS_BUSY_W-1):0]      scu_cpu0_reqbufs_busy;
  wire [(`CA53_DRAIN_STB_W-1):0]         scu_cpu0_drain_stb;
  wire                                   scu_cpu0_evnt_l2_access;
  wire                                   scu_cpu0_evnt_l2_refill;
  wire                                   scu_cpu0_evnt_l2_wb;
  wire                                   scu_cpu0_evnt_snooped_data;
  wire                                   scu_cpu0_evnt_bus_cycle;
  wire                                   scu_cpu0_evnt_bus_acc_rd;
  wire                                   scu_cpu0_evnt_bus_acc_wr;
  wire                                   scu_cpu0_evnt_eviction;
  wire                                   scu_cpu1_ar_credit;
  wire                                   scu_cpu1_ar_block;
  wire                                   scu_cpu1_dr_valid;
  wire [(`CA53_DRID_W-1):0]              scu_cpu1_dr_id;
  wire [(`CA53_DRRESP_W-1):0]            scu_cpu1_dr_resp;
  wire [(`CA53_DRCHUNK_W-1):0]           scu_cpu1_dr_chunk;
  wire [(`CA53_DRDATA_W-1):0]            scu_cpu1_dr_data;
  wire                                   scu_cpu1_rr_valid;
  wire [(`CA53_RRID_W-1):0]              scu_cpu1_rr_id;
  wire [(`CA53_RRRESP_W-1):0]            scu_cpu1_rr_resp;
  wire [(`CA53_RRL2DB_W-1):0]            scu_cpu1_rr_l2db_id;
  wire [(`CA53_EVDONE_W-1):0]            scu_cpu1_ev_done;
  wire [(`CA53_DBEXCLVAL_W-1):0]         scu_cpu1_db_excl_valid;
  wire [(`CA53_DBEXCLRSP_W-1):0]         scu_cpu1_db_excl_resp;
  wire [(`CA53_DBDECERR_W-1):0]          scu_cpu1_db_decerr;
  wire [(`CA53_DBSLVERR_W-1):0]          scu_cpu1_db_slverr;
  wire [(`CA53_LEAVERAM_W-1):0]          scu_cpu1_leave_ramode;
  wire [(`CA53_ACVALID_W-1):0]           scu_cpu1_ac_valid;
  wire [(`CA53_ACID_W-1):0]              scu_cpu1_ac_id;
  wire [(`CA53_ACL2DB_W-1):0]            scu_cpu1_ac_l2db_id;
  wire [(`CA53_ACSNOOP_W-1):0]           scu_cpu1_ac_snoop;
  wire [40:0]                            scu_cpu1_ac_addr;
  wire [(`CA53_ACWAY_W-1):0]             scu_cpu1_ac_way;
  wire [(`CA53_DVM_COMP_W-1):0]          scu_cpu1_dvm_complete;
  wire [(`CA53_REQBUFS_BUSY_W-1):0]      scu_cpu1_reqbufs_busy;
  wire [(`CA53_DRAIN_STB_W-1):0]         scu_cpu1_drain_stb;
  wire                                   scu_cpu1_evnt_l2_access;
  wire                                   scu_cpu1_evnt_l2_refill;
  wire                                   scu_cpu1_evnt_l2_wb;
  wire                                   scu_cpu1_evnt_snooped_data;
  wire                                   scu_cpu1_evnt_bus_cycle;
  wire                                   scu_cpu1_evnt_bus_acc_rd;
  wire                                   scu_cpu1_evnt_bus_acc_wr;
  wire                                   scu_cpu1_evnt_eviction;
  wire                                   scu_cpu2_ar_credit;
  wire                                   scu_cpu2_ar_block;
  wire                                   scu_cpu2_dr_valid;
  wire [(`CA53_DRID_W-1):0]              scu_cpu2_dr_id;
  wire [(`CA53_DRRESP_W-1):0]            scu_cpu2_dr_resp;
  wire [(`CA53_DRCHUNK_W-1):0]           scu_cpu2_dr_chunk;
  wire [(`CA53_DRDATA_W-1):0]            scu_cpu2_dr_data;
  wire                                   scu_cpu2_rr_valid;
  wire [(`CA53_RRID_W-1):0]              scu_cpu2_rr_id;
  wire [(`CA53_RRRESP_W-1):0]            scu_cpu2_rr_resp;
  wire [(`CA53_RRL2DB_W-1):0]            scu_cpu2_rr_l2db_id;
  wire [(`CA53_EVDONE_W-1):0]            scu_cpu2_ev_done;
  wire [(`CA53_DBEXCLVAL_W-1):0]         scu_cpu2_db_excl_valid;
  wire [(`CA53_DBEXCLRSP_W-1):0]         scu_cpu2_db_excl_resp;
  wire [(`CA53_DBDECERR_W-1):0]          scu_cpu2_db_decerr;
  wire [(`CA53_DBSLVERR_W-1):0]          scu_cpu2_db_slverr;
  wire [(`CA53_LEAVERAM_W-1):0]          scu_cpu2_leave_ramode;
  wire [(`CA53_ACVALID_W-1):0]           scu_cpu2_ac_valid;
  wire [(`CA53_ACID_W-1):0]              scu_cpu2_ac_id;
  wire [(`CA53_ACL2DB_W-1):0]            scu_cpu2_ac_l2db_id;
  wire [(`CA53_ACSNOOP_W-1):0]           scu_cpu2_ac_snoop;
  wire [40:0]                            scu_cpu2_ac_addr;
  wire [(`CA53_ACWAY_W-1):0]             scu_cpu2_ac_way;
  wire [(`CA53_DVM_COMP_W-1):0]          scu_cpu2_dvm_complete;
  wire [(`CA53_REQBUFS_BUSY_W-1):0]      scu_cpu2_reqbufs_busy;
  wire [(`CA53_DRAIN_STB_W-1):0]         scu_cpu2_drain_stb;
  wire                                   scu_cpu2_evnt_l2_access;
  wire                                   scu_cpu2_evnt_l2_refill;
  wire                                   scu_cpu2_evnt_l2_wb;
  wire                                   scu_cpu2_evnt_snooped_data;
  wire                                   scu_cpu2_evnt_bus_cycle;
  wire                                   scu_cpu2_evnt_bus_acc_rd;
  wire                                   scu_cpu2_evnt_bus_acc_wr;
  wire                                   scu_cpu2_evnt_eviction;
  wire                                   scu_cpu3_ar_credit;
  wire                                   scu_cpu3_ar_block;
  wire                                   scu_cpu3_dr_valid;
  wire [(`CA53_DRID_W-1):0]              scu_cpu3_dr_id;
  wire [(`CA53_DRRESP_W-1):0]            scu_cpu3_dr_resp;
  wire [(`CA53_DRCHUNK_W-1):0]           scu_cpu3_dr_chunk;
  wire [(`CA53_DRDATA_W-1):0]            scu_cpu3_dr_data;
  wire                                   scu_cpu3_rr_valid;
  wire [(`CA53_RRID_W-1):0]              scu_cpu3_rr_id;
  wire [(`CA53_RRRESP_W-1):0]            scu_cpu3_rr_resp;
  wire [(`CA53_RRL2DB_W-1):0]            scu_cpu3_rr_l2db_id;
  wire [(`CA53_EVDONE_W-1):0]            scu_cpu3_ev_done;
  wire [(`CA53_DBEXCLVAL_W-1):0]         scu_cpu3_db_excl_valid;
  wire [(`CA53_DBEXCLRSP_W-1):0]         scu_cpu3_db_excl_resp;
  wire [(`CA53_DBDECERR_W-1):0]          scu_cpu3_db_decerr;
  wire [(`CA53_DBSLVERR_W-1):0]          scu_cpu3_db_slverr;
  wire [(`CA53_LEAVERAM_W-1):0]          scu_cpu3_leave_ramode;
  wire [(`CA53_ACVALID_W-1):0]           scu_cpu3_ac_valid;
  wire [(`CA53_ACID_W-1):0]              scu_cpu3_ac_id;
  wire [(`CA53_ACL2DB_W-1):0]            scu_cpu3_ac_l2db_id;
  wire [(`CA53_ACSNOOP_W-1):0]           scu_cpu3_ac_snoop;
  wire [40:0]                            scu_cpu3_ac_addr;
  wire [(`CA53_ACWAY_W-1):0]             scu_cpu3_ac_way;
  wire [(`CA53_DVM_COMP_W-1):0]          scu_cpu3_dvm_complete;
  wire [(`CA53_REQBUFS_BUSY_W-1):0]      scu_cpu3_reqbufs_busy;
  wire [(`CA53_DRAIN_STB_W-1):0]         scu_cpu3_drain_stb;
  wire                                   scu_cpu3_evnt_l2_access;
  wire                                   scu_cpu3_evnt_l2_refill;
  wire                                   scu_cpu3_evnt_l2_wb;
  wire                                   scu_cpu3_evnt_snooped_data;
  wire                                   scu_cpu3_evnt_bus_cycle;
  wire                                   scu_cpu3_evnt_bus_acc_rd;
  wire                                   scu_cpu3_evnt_bus_acc_wr;
  wire                                   scu_cpu3_evnt_eviction;

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire                                       gov_clear_axierr;
  wire                                       gov_clear_eccerr;
  wire                                       gov_disable_evict;
  wire                                       gov_enable_writeevict;
  wire                                       gov_l2_in_retention;
  wire                                 [1:0] gov_l2victim_ctl;
  wire                                       gov_l2deien;
  wire                                       gov_l2teien;
  wire          [(`CA53_MBIST0_ADDR_W-1): 0] gov_mbistaddr0;
  wire          [(`CA53_MBIST1_ADDR_W-1): 0] gov_mbistaddr1;
  wire       [(`CA53_MBIST0_RAMARRAY_W-1):0] gov_mbistarray0;
  wire       [(`CA53_MBIST1_RAMARRAY_W-1):0] gov_mbistarray1;
  wire             [(`CA53_MBIST0_BE_W-1):0] gov_mbistbe0;
  wire             [(`CA53_MBIST1_BE_W-1):0] gov_mbistbe1;
  wire                                       gov_mbistcfg0;
  wire                                       gov_mbistcfg1;
  wire          [(`CA53_MBIST0_DATA_W-1): 0] gov_mbistindata0;
  wire          [(`CA53_MBIST1_DATA_W-1): 0] gov_mbistindata1;
  wire                                       gov_mbistreaden0;
  wire                                       gov_mbistreaden1;
  wire                                       gov_mbistreq;
  wire                                       gov_mbistwriteen0;
  wire                                       gov_mbistwriteen1;
  wire                       [NUM_CPUS-1: 0] gov_smpen;
  wire                       [NUM_CPUS-1: 0] gov_standbywfi;
  wire                                       scu_axierr;
  wire                                       scu_eccerr;
  wire                                       scu_l2_retention_ready;
  wire                              [  3: 0] scu_l2ecc_cpuid_way;
  wire                                       scu_l2ecc_fatal;
  wire                              [ 14: 0] scu_l2ecc_index;
  wire                              [  1: 0] scu_l2ecc_ramid;
  wire                                       scu_l2ecc_valid;
  wire                                       scu_mbistack0;
  wire                                       scu_mbistack1;
  wire          [(`CA53_MBIST0_DATA_W-1): 0] scu_mbistoutdata0;
  wire          [(`CA53_MBIST1_DATA_W-1): 0] scu_mbistoutdata1;
  wire                        [NUM_CPUS-1:0] scu_wfx_ready;
  /*END*/

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Unpack buses for the SCU
  // ------------------------------------------------------

  // CPU 0
  assign biu_cpu0_ar_active        = biu_ar_active_i[((`CA53_ARACTIVE_W      *1)-1):(`CA53_ARACTIVE_W *0)];
  assign biu_cpu0_ar_valid         = biu_ar_valid_i[((`CA53_ARVALID_W        *1)-1):(`CA53_ARVALID_W  *0)];
  assign biu_cpu0_ar_id            = biu_ar_id_i[((`CA53_ARID_W              *1)-1):(`CA53_ARID_W     *0)];
  assign biu_cpu0_ar_type          = biu_ar_type_i[((`CA53_ARTYPE_W          *1)-1):(`CA53_ARTYPE_W   *0)];
  assign biu_cpu0_ar_attrs         = biu_ar_attrs_i[((`CA53_ARATTRS_W        *1)-1):(`CA53_ARATTRS_W  *0)];
  assign biu_cpu0_ar_way           = biu_ar_way_i[((`CA53_ARWAY_W            *1)-1):(`CA53_ARWAY_W    *0)];
  assign biu_cpu0_ar_addr          = biu_ar_addr_i[((`CA53_ARADDR_W          *1)-1):(`CA53_ARADDR_W   *0)];
  assign biu_cpu0_ar_len           = biu_ar_len_i[((`CA53_ARLEN_W            *1)-1):(`CA53_ARLEN_W    *0)];
  assign biu_cpu0_ar_size          = biu_ar_size_i[((`CA53_ARSIZE_W          *1)-1):(`CA53_ARSIZE_W   *0)];
  assign biu_cpu0_ar_lock          = biu_ar_lock_i[((`CA53_ARLOCK_W          *1)-1):(`CA53_ARLOCK_W   *0)];
  assign biu_cpu0_ar_priv          = biu_ar_priv_i[((`CA53_ARPRIV_W          *1)-1):(`CA53_ARPRIV_W   *0)];
  assign biu_cpu0_dr_credit        = biu_dr_credit_i[((`CA53_DRCREDIT_W      *1)-1):(`CA53_DRCREDIT_W *0)];
  assign biu_cpu0_dw_valid         = biu_dw_valid_i[((`CA53_DWVALID_W        *1)-1):(`CA53_DWVALID_W  *0)];
  assign biu_cpu0_dw_l2db_id       = biu_dw_l2db_id_i[((`CA53_DWL2DB_W       *1)-1):(`CA53_DWL2DB_W   *0)];
  assign biu_cpu0_dw_chunks_valid  = biu_dw_chunks_valid_i[((`CA53_DWCHUNKS_W*1)-1):(`CA53_DWCHUNKS_W *0)];
  assign biu_cpu0_dw_last          = biu_dw_last_i[((`CA53_DWLAST_W          *1)-1):(`CA53_DWLAST_W   *0)];
  assign biu_cpu0_dw_strb          = biu_dw_strb_i[((`CA53_DWSTRB_W          *1)-1):(`CA53_DWSTRB_W   *0)];
  assign biu_cpu0_dw_data          = biu_dw_data_i[((`CA53_DWDATA_W          *1)-1):(`CA53_DWDATA_W   *0)];
  assign biu_cpu0_dw_err           = biu_dw_err_i[((`CA53_DWERR_W            *1)-1):(`CA53_DWERR_W    *0)];
  assign biu_cpu0_dw_fatal         = biu_dw_fatal_i[((`CA53_DWFATAL_W        *1)-1):(`CA53_DWFATAL_W  *0)];
  assign dcu_cpu0_ac_ready         = dcu_ac_ready_i[((`CA53_ACREADY_W        *1)-1):(`CA53_ACREADY_W  *0)];
  assign dcu_cpu0_cr_valid         = dcu_cr_valid_i[((`CA53_CRVALID_W        *1)-1):(`CA53_CRVALID_W  *0)];
  assign dcu_cpu0_cr_id            = dcu_cr_id_i[((`CA53_CRID_W              *1)-1):(`CA53_CRID_W     *0)];
  assign dcu_cpu0_cr_dirty         = dcu_cr_dirty_i[((`CA53_CRDIRTY_W        *1)-1):(`CA53_CRDIRTY_W  *0)];
  assign dcu_cpu0_cr_age           = dcu_cr_age_i[((`CA53_CRAGE_W            *1)-1):(`CA53_CRAGE_W    *0)];
  assign dcu_cpu0_cr_alloc         = dcu_cr_alloc_i[((`CA53_CRALLOC_W        *1)-1):(`CA53_CRALLOC_W  *0)];
  assign dcu_cpu0_cr_migratory     = dcu_cr_migratory_i[((`CA53_CRMIG_W      *1)-1):(`CA53_CRMIG_W    *0)];
  assign dcu_cpu0_dvm_complete     = dcu_dvm_complete_i[((`CA53_DVM_COMP_W   *1)-1):(`CA53_DVM_COMP_W *0)];
  assign gov_cpu0_inv_all_req      = gov_inv_all_req[((`CA53_INV_ALL_W       *1)-1):(`CA53_INV_ALL_W  *0)];
  assign gov_cpu0_smp_en           = gov_smpen[0];

  // CPU 1
  generate if (NUM_CPUS >= 2) begin : cpu1_assigns
    assign biu_cpu1_ar_active        = biu_ar_active_i[((`CA53_ARACTIVE_W      *2)-1):(`CA53_ARACTIVE_W *1)];
    assign biu_cpu1_ar_valid         = biu_ar_valid_i[((`CA53_ARVALID_W        *2)-1):(`CA53_ARVALID_W  *1)];
    assign biu_cpu1_ar_id            = biu_ar_id_i[((`CA53_ARID_W              *2)-1):(`CA53_ARID_W     *1)];
    assign biu_cpu1_ar_type          = biu_ar_type_i[((`CA53_ARTYPE_W          *2)-1):(`CA53_ARTYPE_W   *1)];
    assign biu_cpu1_ar_attrs         = biu_ar_attrs_i[((`CA53_ARATTRS_W        *2)-1):(`CA53_ARATTRS_W  *1)];
    assign biu_cpu1_ar_way           = biu_ar_way_i[((`CA53_ARWAY_W            *2)-1):(`CA53_ARWAY_W    *1)];
    assign biu_cpu1_ar_addr          = biu_ar_addr_i[((`CA53_ARADDR_W          *2)-1):(`CA53_ARADDR_W   *1)];
    assign biu_cpu1_ar_len           = biu_ar_len_i[((`CA53_ARLEN_W            *2)-1):(`CA53_ARLEN_W    *1)];
    assign biu_cpu1_ar_size          = biu_ar_size_i[((`CA53_ARSIZE_W          *2)-1):(`CA53_ARSIZE_W   *1)];
    assign biu_cpu1_ar_lock          = biu_ar_lock_i[((`CA53_ARLOCK_W          *2)-1):(`CA53_ARLOCK_W   *1)];
    assign biu_cpu1_ar_priv          = biu_ar_priv_i[((`CA53_ARPRIV_W          *2)-1):(`CA53_ARPRIV_W   *1)];
    assign biu_cpu1_dr_credit        = biu_dr_credit_i[((`CA53_DRCREDIT_W      *2)-1):(`CA53_DRCREDIT_W *1)];
    assign biu_cpu1_dw_valid         = biu_dw_valid_i[((`CA53_DWVALID_W        *2)-1):(`CA53_DWVALID_W  *1)];
    assign biu_cpu1_dw_l2db_id       = biu_dw_l2db_id_i[((`CA53_DWL2DB_W       *2)-1):(`CA53_DWL2DB_W   *1)];
    assign biu_cpu1_dw_chunks_valid  = biu_dw_chunks_valid_i[((`CA53_DWCHUNKS_W*2)-1):(`CA53_DWCHUNKS_W *1)];
    assign biu_cpu1_dw_last          = biu_dw_last_i[((`CA53_DWLAST_W          *2)-1):(`CA53_DWLAST_W   *1)];
    assign biu_cpu1_dw_strb          = biu_dw_strb_i[((`CA53_DWSTRB_W          *2)-1):(`CA53_DWSTRB_W   *1)];
    assign biu_cpu1_dw_data          = biu_dw_data_i[((`CA53_DWDATA_W          *2)-1):(`CA53_DWDATA_W   *1)];
    assign biu_cpu1_dw_err           = biu_dw_err_i[((`CA53_DWERR_W            *2)-1):(`CA53_DWERR_W    *1)];
    assign biu_cpu1_dw_fatal         = biu_dw_fatal_i[((`CA53_DWFATAL_W        *2)-1):(`CA53_DWFATAL_W  *1)];
    assign dcu_cpu1_ac_ready         = dcu_ac_ready_i[((`CA53_ACREADY_W        *2)-1):(`CA53_ACREADY_W  *1)];
    assign dcu_cpu1_cr_valid         = dcu_cr_valid_i[((`CA53_CRVALID_W        *2)-1):(`CA53_CRVALID_W  *1)];
    assign dcu_cpu1_cr_id            = dcu_cr_id_i[((`CA53_CRID_W              *2)-1):(`CA53_CRID_W     *1)];
    assign dcu_cpu1_cr_dirty         = dcu_cr_dirty_i[((`CA53_CRDIRTY_W        *2)-1):(`CA53_CRDIRTY_W  *1)];
    assign dcu_cpu1_cr_age           = dcu_cr_age_i[((`CA53_CRAGE_W            *2)-1):(`CA53_CRAGE_W    *1)];
    assign dcu_cpu1_cr_alloc         = dcu_cr_alloc_i[((`CA53_CRALLOC_W        *2)-1):(`CA53_CRALLOC_W  *1)];
    assign dcu_cpu1_cr_migratory     = dcu_cr_migratory_i[((`CA53_CRMIG_W      *2)-1):(`CA53_CRMIG_W    *1)];
    assign dcu_cpu1_dvm_complete     = dcu_dvm_complete_i[((`CA53_DVM_COMP_W   *2)-1):(`CA53_DVM_COMP_W *1)];
    assign gov_cpu1_inv_all_req      = gov_inv_all_req[((`CA53_INV_ALL_W       *2)-1):(`CA53_INV_ALL_W  *1)];
    assign gov_cpu1_smp_en           = gov_smpen[1];
  end else begin : cpu1_tieoffs
    assign biu_cpu1_ar_active        = {`CA53_ARACTIVE_W{1'b0}};
    assign biu_cpu1_ar_valid         = {`CA53_ARVALID_W{1'b0}};
    assign biu_cpu1_ar_id            = {`CA53_ARID_W{1'b0}};
    assign biu_cpu1_ar_type          = {`CA53_ARTYPE_W{1'b0}};
    assign biu_cpu1_ar_attrs         = {`CA53_ARATTRS_W{1'b0}};
    assign biu_cpu1_ar_way           = {`CA53_ARWAY_W{1'b0}};
    assign biu_cpu1_ar_addr          = {`CA53_ARADDR_W{1'b0}};
    assign biu_cpu1_ar_len           = {`CA53_ARLEN_W{1'b0}};
    assign biu_cpu1_ar_size          = {`CA53_ARSIZE_W{1'b0}};
    assign biu_cpu1_ar_lock          = {`CA53_ARLOCK_W{1'b0}};
    assign biu_cpu1_ar_priv          = {`CA53_ARPRIV_W{1'b0}};
    assign biu_cpu1_dr_credit        = {`CA53_DRCREDIT_W{1'b0}};
    assign biu_cpu1_dw_valid         = {`CA53_DWVALID_W{1'b0}};
    assign biu_cpu1_dw_l2db_id       = {`CA53_DWL2DB_W{1'b0}};
    assign biu_cpu1_dw_chunks_valid  = {`CA53_DWCHUNKS_W{1'b0}};
    assign biu_cpu1_dw_last          = {`CA53_DWLAST_W{1'b0}};
    assign biu_cpu1_dw_strb          = {`CA53_DWSTRB_W{1'b0}};
    assign biu_cpu1_dw_data          = {`CA53_DWDATA_W{1'b0}};
    assign biu_cpu1_dw_err           = {`CA53_DWERR_W{1'b0}};
    assign biu_cpu1_dw_fatal         = {`CA53_DWFATAL_W{1'b0}};
    assign dcu_cpu1_ac_ready         = {`CA53_ACREADY_W{1'b0}};
    assign dcu_cpu1_cr_valid         = {`CA53_CRVALID_W{1'b0}};
    assign dcu_cpu1_cr_id            = {`CA53_CRID_W{1'b0}};
    assign dcu_cpu1_cr_dirty         = {`CA53_CRDIRTY_W{1'b0}};
    assign dcu_cpu1_cr_age           = {`CA53_CRAGE_W{1'b0}};
    assign dcu_cpu1_cr_alloc         = {`CA53_CRALLOC_W{1'b0}};
    assign dcu_cpu1_cr_migratory     = {`CA53_CRMIG_W{1'b0}};
    assign dcu_cpu1_dvm_complete     = {`CA53_DVM_COMP_W{1'b0}};
    assign gov_cpu1_inv_all_req      = {`CA53_INV_ALL_W{1'b0}};
    assign gov_cpu1_smp_en           = 1'b0;
  end
  endgenerate

  // CPU 2
  generate if (NUM_CPUS >= 3) begin : cpu2_assigns
    assign biu_cpu2_ar_active        = biu_ar_active_i[((`CA53_ARACTIVE_W      *3)-1):(`CA53_ARACTIVE_W *2)];
    assign biu_cpu2_ar_valid         = biu_ar_valid_i[((`CA53_ARVALID_W        *3)-1):(`CA53_ARVALID_W  *2)];
    assign biu_cpu2_ar_id            = biu_ar_id_i[((`CA53_ARID_W              *3)-1):(`CA53_ARID_W     *2)];
    assign biu_cpu2_ar_type          = biu_ar_type_i[((`CA53_ARTYPE_W          *3)-1):(`CA53_ARTYPE_W   *2)];
    assign biu_cpu2_ar_attrs         = biu_ar_attrs_i[((`CA53_ARATTRS_W        *3)-1):(`CA53_ARATTRS_W  *2)];
    assign biu_cpu2_ar_way           = biu_ar_way_i[((`CA53_ARWAY_W            *3)-1):(`CA53_ARWAY_W    *2)];
    assign biu_cpu2_ar_addr          = biu_ar_addr_i[((`CA53_ARADDR_W          *3)-1):(`CA53_ARADDR_W   *2)];
    assign biu_cpu2_ar_len           = biu_ar_len_i[((`CA53_ARLEN_W            *3)-1):(`CA53_ARLEN_W    *2)];
    assign biu_cpu2_ar_size          = biu_ar_size_i[((`CA53_ARSIZE_W          *3)-1):(`CA53_ARSIZE_W   *2)];
    assign biu_cpu2_ar_lock          = biu_ar_lock_i[((`CA53_ARLOCK_W          *3)-1):(`CA53_ARLOCK_W   *2)];
    assign biu_cpu2_ar_priv          = biu_ar_priv_i[((`CA53_ARPRIV_W          *3)-1):(`CA53_ARPRIV_W   *2)];
    assign biu_cpu2_dr_credit        = biu_dr_credit_i[((`CA53_DRCREDIT_W      *3)-1):(`CA53_DRCREDIT_W *2)];
    assign biu_cpu2_dw_valid         = biu_dw_valid_i[((`CA53_DWVALID_W        *3)-1):(`CA53_DWVALID_W  *2)];
    assign biu_cpu2_dw_l2db_id       = biu_dw_l2db_id_i[((`CA53_DWL2DB_W       *3)-1):(`CA53_DWL2DB_W   *2)];
    assign biu_cpu2_dw_chunks_valid  = biu_dw_chunks_valid_i[((`CA53_DWCHUNKS_W*3)-1):(`CA53_DWCHUNKS_W *2)];
    assign biu_cpu2_dw_last          = biu_dw_last_i[((`CA53_DWLAST_W          *3)-1):(`CA53_DWLAST_W   *2)];
    assign biu_cpu2_dw_strb          = biu_dw_strb_i[((`CA53_DWSTRB_W          *3)-1):(`CA53_DWSTRB_W   *2)];
    assign biu_cpu2_dw_data          = biu_dw_data_i[((`CA53_DWDATA_W          *3)-1):(`CA53_DWDATA_W   *2)];
    assign biu_cpu2_dw_err           = biu_dw_err_i[((`CA53_DWERR_W            *3)-1):(`CA53_DWERR_W    *2)];
    assign biu_cpu2_dw_fatal         = biu_dw_fatal_i[((`CA53_DWFATAL_W        *3)-1):(`CA53_DWFATAL_W  *2)];
    assign dcu_cpu2_ac_ready         = dcu_ac_ready_i[((`CA53_ACREADY_W        *3)-1):(`CA53_ACREADY_W  *2)];
    assign dcu_cpu2_cr_valid         = dcu_cr_valid_i[((`CA53_CRVALID_W        *3)-1):(`CA53_CRVALID_W  *2)];
    assign dcu_cpu2_cr_id            = dcu_cr_id_i[((`CA53_CRID_W              *3)-1):(`CA53_CRID_W     *2)];
    assign dcu_cpu2_cr_dirty         = dcu_cr_dirty_i[((`CA53_CRDIRTY_W        *3)-1):(`CA53_CRDIRTY_W  *2)];
    assign dcu_cpu2_cr_age           = dcu_cr_age_i[((`CA53_CRAGE_W            *3)-1):(`CA53_CRAGE_W    *2)];
    assign dcu_cpu2_cr_alloc         = dcu_cr_alloc_i[((`CA53_CRALLOC_W        *3)-1):(`CA53_CRALLOC_W  *2)];
    assign dcu_cpu2_cr_migratory     = dcu_cr_migratory_i[((`CA53_CRMIG_W      *3)-1):(`CA53_CRMIG_W    *2)];
    assign dcu_cpu2_dvm_complete     = dcu_dvm_complete_i[((`CA53_DVM_COMP_W   *3)-1):(`CA53_DVM_COMP_W *2)];
    assign gov_cpu2_inv_all_req      = gov_inv_all_req[((`CA53_INV_ALL_W       *3)-1):(`CA53_INV_ALL_W  *2)];
    assign gov_cpu2_smp_en           = gov_smpen[2];
  end else begin : cpu2_tieoffs
    assign biu_cpu2_ar_active        = {`CA53_ARACTIVE_W{1'b0}};
    assign biu_cpu2_ar_valid         = {`CA53_ARVALID_W{1'b0}};
    assign biu_cpu2_ar_id            = {`CA53_ARID_W{1'b0}};
    assign biu_cpu2_ar_type          = {`CA53_ARTYPE_W{1'b0}};
    assign biu_cpu2_ar_attrs         = {`CA53_ARATTRS_W{1'b0}};
    assign biu_cpu2_ar_way           = {`CA53_ARWAY_W{1'b0}};
    assign biu_cpu2_ar_addr          = {`CA53_ARADDR_W{1'b0}};
    assign biu_cpu2_ar_len           = {`CA53_ARLEN_W{1'b0}};
    assign biu_cpu2_ar_size          = {`CA53_ARSIZE_W{1'b0}};
    assign biu_cpu2_ar_lock          = {`CA53_ARLOCK_W{1'b0}};
    assign biu_cpu2_ar_priv          = {`CA53_ARPRIV_W{1'b0}};
    assign biu_cpu2_dr_credit        = {`CA53_DRCREDIT_W{1'b0}};
    assign biu_cpu2_dw_valid         = {`CA53_DWVALID_W{1'b0}};
    assign biu_cpu2_dw_l2db_id       = {`CA53_DWL2DB_W{1'b0}};
    assign biu_cpu2_dw_chunks_valid  = {`CA53_DWCHUNKS_W{1'b0}};
    assign biu_cpu2_dw_last          = {`CA53_DWLAST_W{1'b0}};
    assign biu_cpu2_dw_strb          = {`CA53_DWSTRB_W{1'b0}};
    assign biu_cpu2_dw_data          = {`CA53_DWDATA_W{1'b0}};
    assign biu_cpu2_dw_err           = {`CA53_DWERR_W{1'b0}};
    assign biu_cpu2_dw_fatal         = {`CA53_DWFATAL_W{1'b0}};
    assign dcu_cpu2_ac_ready         = {`CA53_ACREADY_W{1'b0}};
    assign dcu_cpu2_cr_valid         = {`CA53_CRVALID_W{1'b0}};
    assign dcu_cpu2_cr_id            = {`CA53_CRID_W{1'b0}};
    assign dcu_cpu2_cr_dirty         = {`CA53_CRDIRTY_W{1'b0}};
    assign dcu_cpu2_cr_age           = {`CA53_CRAGE_W{1'b0}};
    assign dcu_cpu2_cr_alloc         = {`CA53_CRALLOC_W{1'b0}};
    assign dcu_cpu2_cr_migratory     = {`CA53_CRMIG_W{1'b0}};
    assign dcu_cpu2_dvm_complete     = {`CA53_DVM_COMP_W{1'b0}};
    assign gov_cpu2_inv_all_req      = {`CA53_INV_ALL_W{1'b0}};
    assign gov_cpu2_smp_en           = 1'b0;
  end
  endgenerate

  // CPU 3
  generate if (NUM_CPUS >= 4) begin : cpu3_assigns
    assign biu_cpu3_ar_active        = biu_ar_active_i[((`CA53_ARACTIVE_W      *4)-1):(`CA53_ARACTIVE_W *3)];
    assign biu_cpu3_ar_valid         = biu_ar_valid_i[((`CA53_ARVALID_W        *4)-1):(`CA53_ARVALID_W  *3)];
    assign biu_cpu3_ar_id            = biu_ar_id_i[((`CA53_ARID_W              *4)-1):(`CA53_ARID_W     *3)];
    assign biu_cpu3_ar_type          = biu_ar_type_i[((`CA53_ARTYPE_W          *4)-1):(`CA53_ARTYPE_W   *3)];
    assign biu_cpu3_ar_attrs         = biu_ar_attrs_i[((`CA53_ARATTRS_W        *4)-1):(`CA53_ARATTRS_W  *3)];
    assign biu_cpu3_ar_way           = biu_ar_way_i[((`CA53_ARWAY_W            *4)-1):(`CA53_ARWAY_W    *3)];
    assign biu_cpu3_ar_addr          = biu_ar_addr_i[((`CA53_ARADDR_W          *4)-1):(`CA53_ARADDR_W   *3)];
    assign biu_cpu3_ar_len           = biu_ar_len_i[((`CA53_ARLEN_W            *4)-1):(`CA53_ARLEN_W    *3)];
    assign biu_cpu3_ar_size          = biu_ar_size_i[((`CA53_ARSIZE_W          *4)-1):(`CA53_ARSIZE_W   *3)];
    assign biu_cpu3_ar_lock          = biu_ar_lock_i[((`CA53_ARLOCK_W          *4)-1):(`CA53_ARLOCK_W   *3)];
    assign biu_cpu3_ar_priv          = biu_ar_priv_i[((`CA53_ARPRIV_W          *4)-1):(`CA53_ARPRIV_W   *3)];
    assign biu_cpu3_dr_credit        = biu_dr_credit_i[((`CA53_DRCREDIT_W      *4)-1):(`CA53_DRCREDIT_W *3)];
    assign biu_cpu3_dw_valid         = biu_dw_valid_i[((`CA53_DWVALID_W        *4)-1):(`CA53_DWVALID_W  *3)];
    assign biu_cpu3_dw_l2db_id       = biu_dw_l2db_id_i[((`CA53_DWL2DB_W       *4)-1):(`CA53_DWL2DB_W   *3)];
    assign biu_cpu3_dw_chunks_valid  = biu_dw_chunks_valid_i[((`CA53_DWCHUNKS_W*4)-1):(`CA53_DWCHUNKS_W *3)];
    assign biu_cpu3_dw_last          = biu_dw_last_i[((`CA53_DWLAST_W          *4)-1):(`CA53_DWLAST_W   *3)];
    assign biu_cpu3_dw_strb          = biu_dw_strb_i[((`CA53_DWSTRB_W          *4)-1):(`CA53_DWSTRB_W   *3)];
    assign biu_cpu3_dw_data          = biu_dw_data_i[((`CA53_DWDATA_W          *4)-1):(`CA53_DWDATA_W   *3)];
    assign biu_cpu3_dw_err           = biu_dw_err_i[((`CA53_DWERR_W            *4)-1):(`CA53_DWERR_W    *3)];
    assign biu_cpu3_dw_fatal         = biu_dw_fatal_i[((`CA53_DWFATAL_W        *4)-1):(`CA53_DWFATAL_W  *3)];
    assign dcu_cpu3_ac_ready         = dcu_ac_ready_i[((`CA53_ACREADY_W        *4)-1):(`CA53_ACREADY_W  *3)];
    assign dcu_cpu3_cr_valid         = dcu_cr_valid_i[((`CA53_CRVALID_W        *4)-1):(`CA53_CRVALID_W  *3)];
    assign dcu_cpu3_cr_id            = dcu_cr_id_i[((`CA53_CRID_W              *4)-1):(`CA53_CRID_W     *3)];
    assign dcu_cpu3_cr_dirty         = dcu_cr_dirty_i[((`CA53_CRDIRTY_W        *4)-1):(`CA53_CRDIRTY_W  *3)];
    assign dcu_cpu3_cr_age           = dcu_cr_age_i[((`CA53_CRAGE_W            *4)-1):(`CA53_CRAGE_W    *3)];
    assign dcu_cpu3_cr_alloc         = dcu_cr_alloc_i[((`CA53_CRALLOC_W        *4)-1):(`CA53_CRALLOC_W  *3)];
    assign dcu_cpu3_cr_migratory     = dcu_cr_migratory_i[((`CA53_CRMIG_W      *4)-1):(`CA53_CRMIG_W    *3)];
    assign dcu_cpu3_dvm_complete     = dcu_dvm_complete_i[((`CA53_DVM_COMP_W   *4)-1):(`CA53_DVM_COMP_W *3)];
    assign gov_cpu3_inv_all_req      = gov_inv_all_req[((`CA53_INV_ALL_W       *4)-1):(`CA53_INV_ALL_W  *3)];
    assign gov_cpu3_smp_en           = gov_smpen[3];
  end else begin : cpu3_tieoffs
    assign biu_cpu3_ar_active        = {`CA53_ARACTIVE_W{1'b0}};
    assign biu_cpu3_ar_valid         = {`CA53_ARVALID_W{1'b0}};
    assign biu_cpu3_ar_id            = {`CA53_ARID_W{1'b0}};
    assign biu_cpu3_ar_type          = {`CA53_ARTYPE_W{1'b0}};
    assign biu_cpu3_ar_attrs         = {`CA53_ARATTRS_W{1'b0}};
    assign biu_cpu3_ar_way           = {`CA53_ARWAY_W{1'b0}};
    assign biu_cpu3_ar_addr          = {`CA53_ARADDR_W{1'b0}};
    assign biu_cpu3_ar_len           = {`CA53_ARLEN_W{1'b0}};
    assign biu_cpu3_ar_size          = {`CA53_ARSIZE_W{1'b0}};
    assign biu_cpu3_ar_lock          = {`CA53_ARLOCK_W{1'b0}};
    assign biu_cpu3_ar_priv          = {`CA53_ARPRIV_W{1'b0}};
    assign biu_cpu3_dr_credit        = {`CA53_DRCREDIT_W{1'b0}};
    assign biu_cpu3_dw_valid         = {`CA53_DWVALID_W{1'b0}};
    assign biu_cpu3_dw_l2db_id       = {`CA53_DWL2DB_W{1'b0}};
    assign biu_cpu3_dw_chunks_valid  = {`CA53_DWCHUNKS_W{1'b0}};
    assign biu_cpu3_dw_last          = {`CA53_DWLAST_W{1'b0}};
    assign biu_cpu3_dw_strb          = {`CA53_DWSTRB_W{1'b0}};
    assign biu_cpu3_dw_data          = {`CA53_DWDATA_W{1'b0}};
    assign biu_cpu3_dw_err           = {`CA53_DWERR_W{1'b0}};
    assign biu_cpu3_dw_fatal         = {`CA53_DWFATAL_W{1'b0}};
    assign dcu_cpu3_ac_ready         = {`CA53_ACREADY_W{1'b0}};
    assign dcu_cpu3_cr_valid         = {`CA53_CRVALID_W{1'b0}};
    assign dcu_cpu3_cr_id            = {`CA53_CRID_W{1'b0}};
    assign dcu_cpu3_cr_dirty         = {`CA53_CRDIRTY_W{1'b0}};
    assign dcu_cpu3_cr_age           = {`CA53_CRAGE_W{1'b0}};
    assign dcu_cpu3_cr_alloc         = {`CA53_CRALLOC_W{1'b0}};
    assign dcu_cpu3_cr_migratory     = {`CA53_CRMIG_W{1'b0}};
    assign dcu_cpu3_dvm_complete     = {`CA53_DVM_COMP_W{1'b0}};
    assign gov_cpu3_inv_all_req      = {`CA53_INV_ALL_W{1'b0}};
    assign gov_cpu3_smp_en           = 1'b0;
  end
  endgenerate

  // Top-Level inputs for the SCU
  assign scu_ext_aclken      = aclkenm_i;
  assign scu_ext_ar_ready    = arreadym_i;
  assign scu_ext_dr_id       = ridm_i;
  assign scu_ext_dr_valid    = rvalidm_i;
  assign scu_ext_dr_last     = rlastm_i;
  assign scu_ext_dr_data     = rdatam_i;
  assign scu_ext_dr_resp     = rrespm_i;
  assign scu_ext_aw_ready    = awreadym_i;
  assign scu_ext_dw_ready    = wreadym_i;
  assign scu_ext_db_id       = bidm_i;
  assign scu_ext_db_resp     = brespm_i;
  assign scu_ext_db_valid    = bvalidm_i;
  assign scu_ext_ac_valid    = acvalidm_i;
  assign scu_ext_ac_addr     = acaddrm_i;
  assign scu_ext_ac_prot     = acprotm_i;
  assign scu_ext_ac_snoop    = acsnoopm_i;
  assign scu_ext_cr_ready    = crreadym_i;
  assign scu_ext_cd_ready    = cdreadym_i;
  assign ext_sclken          = sclken_i;
  assign ext_sinact          = sinact_i;
  assign ext_nodeid          = nodeid_i;
  assign ext_rxsactive       = rxsactive_i;
  assign ext_rxlinkactivereq = rxlinkactivereq_i;
  assign ext_txlinkactiveack = txlinkactiveack_i;
  assign ext_txreqlcrdv      = txreqlcrdv_i;
  assign ext_txrsplcrdv      = txrsplcrdv_i;
  assign ext_txdatlcrdv      = txdatlcrdv_i;
  assign ext_rxsnpflitpend   = rxsnpflitpend_i;
  assign ext_rxsnpflitv      = rxsnpflitv_i;
  assign ext_rxsnpflit       = rxsnpflit_i;
  assign ext_rxrspflitpend   = rxrspflitpend_i;
  assign ext_rxrspflitv      = rxrspflitv_i;
  assign ext_rxrspflit       = rxrspflit_i;
  assign ext_rxdatflitpend   = rxdatflitpend_i;
  assign ext_rxdatflitv      = rxdatflitv_i;
  assign ext_rxdatflit       = rxdatflit_i;
  assign ext_samaddrmap0     = samaddrmap0_i;
  assign ext_samaddrmap1     = samaddrmap1_i;
  assign ext_samaddrmap2     = samaddrmap2_i;
  assign ext_samaddrmap3     = samaddrmap3_i;
  assign ext_samaddrmap4     = samaddrmap4_i;
  assign ext_samaddrmap5     = samaddrmap5_i;
  assign ext_samaddrmap6     = samaddrmap6_i;
  assign ext_samaddrmap7     = samaddrmap7_i;
  assign ext_samaddrmap8     = samaddrmap8_i;
  assign ext_samaddrmap9     = samaddrmap9_i;
  assign ext_samaddrmap10    = samaddrmap10_i;
  assign ext_samaddrmap11    = samaddrmap11_i;
  assign ext_samaddrmap12    = samaddrmap12_i;
  assign ext_samaddrmap13    = samaddrmap13_i;
  assign ext_samaddrmap14    = samaddrmap14_i;
  assign ext_samaddrmap15    = samaddrmap15_i;
  assign ext_sammnbase       = sammnbase_i;
  assign ext_sammnnodeid     = sammnnodeid_i;
  assign ext_samhni0nodeid   = samhni0nodeid_i;
  assign ext_samhni1nodeid   = samhni1nodeid_i;
  assign ext_samhnf0nodeid   = samhnf0nodeid_i;
  assign ext_samhnf1nodeid   = samhnf1nodeid_i;
  assign ext_samhnf2nodeid   = samhnf2nodeid_i;
  assign ext_samhnf3nodeid   = samhnf3nodeid_i;
  assign ext_samhnf4nodeid   = samhnf4nodeid_i;
  assign ext_samhnf5nodeid   = samhnf5nodeid_i;
  assign ext_samhnf6nodeid   = samhnf6nodeid_i;
  assign ext_samhnf7nodeid   = samhnf7nodeid_i;
  assign ext_samhnfmode      = samhnfmode_i;
  assign ext_acp_aclken      = aclkens_i;
  assign ext_acp_ainact      = ainacts_i;
  assign ext_acp_awvalid     = awvalids_i;
  assign ext_acp_awid        = awids_i;
  assign ext_acp_awaddr      = awaddrs_i;
  assign ext_acp_awlen       = awlens_i;
  assign ext_acp_awcache     = awcaches_i;
  assign ext_acp_awuser      = awusers_i;
  assign ext_acp_awprot      = awprots_i;
  assign ext_acp_wvalid      = wvalids_i;
  assign ext_acp_wdata       = wdatas_i;
  assign ext_acp_wstrb       = wstrbs_i;
  assign ext_acp_wlast       = wlasts_i;
  assign ext_acp_bready      = breadys_i;
  assign ext_acp_arvalid     = arvalids_i;
  assign ext_acp_arid        = arids_i;
  assign ext_acp_araddr      = araddrs_i;
  assign ext_acp_arlen       = arlens_i;
  assign ext_acp_arcache     = arcaches_i;
  assign ext_acp_aruser      = arusers_i;
  assign ext_acp_arprot      = arprots_i;
  assign ext_acp_rready      = rreadys_i;

  // ------------------------------------------------------
  // SCU
  // ------------------------------------------------------

  ca53scu `CA53_SCU_PARAM_INST u_ca53scu (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                            (CLKIN),
    .DFTSE                            (DFTSE),
    .DFTRSTDISABLE                    (DFTRSTDISABLE),
    .DFTRAMHOLD                       (DFTRAMHOLD),
    .DFTMCPHOLD                       (DFTMCPHOLD),
    .nl2reset_i                       (nl2reset),
    .nmbistreset_i                    (nmbistreset),
    .l2rstdisable_i                   (l2rstdisable_i),
    .acinactm_i                       (acinactm_i),
    .gov_standbywfi_i                 (gov_standbywfi[NUM_CPUS-1:0]),
    .gov_enable_writeevict_i          (gov_enable_writeevict),
    .gov_disable_evict_i              (gov_disable_evict),
    .gov_l2victim_ctl_i               (gov_l2victim_ctl[1:0]),
    .gov_l2deien_i                    (gov_l2deien),
    .gov_l2teien_i                    (gov_l2teien),
    .gov_l2_in_retention_i            (gov_l2_in_retention),
    .biu_cpu0_ar_active_i             (biu_cpu0_ar_active),
    .biu_cpu0_ar_valid_i              (biu_cpu0_ar_valid),
    .biu_cpu0_ar_id_i                 (biu_cpu0_ar_id[4:0]),
    .biu_cpu0_ar_type_i               (biu_cpu0_ar_type[4:0]),
    .biu_cpu0_ar_attrs_i              (biu_cpu0_ar_attrs[7:0]),
    .biu_cpu0_ar_way_i                (biu_cpu0_ar_way[4:0]),
    .biu_cpu0_ar_addr_i               (biu_cpu0_ar_addr[40:0]),
    .biu_cpu0_ar_len_i                (biu_cpu0_ar_len[1:0]),
    .biu_cpu0_ar_size_i               (biu_cpu0_ar_size[2:0]),
    .biu_cpu0_ar_lock_i               (biu_cpu0_ar_lock),
    .biu_cpu0_ar_priv_i               (biu_cpu0_ar_priv),
    .biu_cpu0_dr_credit_i             (biu_cpu0_dr_credit),
    .biu_cpu0_dw_valid_i              (biu_cpu0_dw_valid),
    .biu_cpu0_dw_l2db_id_i            (biu_cpu0_dw_l2db_id[3:0]),
    .biu_cpu0_dw_chunks_valid_i       (biu_cpu0_dw_chunks_valid[3:0]),
    .biu_cpu0_dw_last_i               (biu_cpu0_dw_last),
    .biu_cpu0_dw_strb_i               (biu_cpu0_dw_strb[31:0]),
    .biu_cpu0_dw_data_i               (biu_cpu0_dw_data[255:0]),
    .biu_cpu0_dw_err_i                (biu_cpu0_dw_err),
    .biu_cpu0_dw_fatal_i              (biu_cpu0_dw_fatal),
    .dcu_cpu0_ac_ready_i              (dcu_cpu0_ac_ready),
    .dcu_cpu0_cr_valid_i              (dcu_cpu0_cr_valid),
    .dcu_cpu0_cr_id_i                 (dcu_cpu0_cr_id[2:0]),
    .dcu_cpu0_cr_dirty_i              (dcu_cpu0_cr_dirty),
    .dcu_cpu0_cr_age_i                (dcu_cpu0_cr_age),
    .dcu_cpu0_cr_alloc_i              (dcu_cpu0_cr_alloc),
    .dcu_cpu0_cr_migratory_i          (dcu_cpu0_cr_migratory),
    .dcu_cpu0_dvm_complete_i          (dcu_cpu0_dvm_complete),
    .biu_cpu1_ar_active_i             (biu_cpu1_ar_active),
    .biu_cpu1_ar_valid_i              (biu_cpu1_ar_valid),
    .biu_cpu1_ar_id_i                 (biu_cpu1_ar_id[4:0]),
    .biu_cpu1_ar_type_i               (biu_cpu1_ar_type[4:0]),
    .biu_cpu1_ar_attrs_i              (biu_cpu1_ar_attrs[7:0]),
    .biu_cpu1_ar_way_i                (biu_cpu1_ar_way[4:0]),
    .biu_cpu1_ar_addr_i               (biu_cpu1_ar_addr[40:0]),
    .biu_cpu1_ar_len_i                (biu_cpu1_ar_len[1:0]),
    .biu_cpu1_ar_size_i               (biu_cpu1_ar_size[2:0]),
    .biu_cpu1_ar_lock_i               (biu_cpu1_ar_lock),
    .biu_cpu1_ar_priv_i               (biu_cpu1_ar_priv),
    .biu_cpu1_dr_credit_i             (biu_cpu1_dr_credit),
    .biu_cpu1_dw_valid_i              (biu_cpu1_dw_valid),
    .biu_cpu1_dw_l2db_id_i            (biu_cpu1_dw_l2db_id[3:0]),
    .biu_cpu1_dw_chunks_valid_i       (biu_cpu1_dw_chunks_valid[3:0]),
    .biu_cpu1_dw_last_i               (biu_cpu1_dw_last),
    .biu_cpu1_dw_strb_i               (biu_cpu1_dw_strb[31:0]),
    .biu_cpu1_dw_data_i               (biu_cpu1_dw_data[255:0]),
    .biu_cpu1_dw_err_i                (biu_cpu1_dw_err),
    .biu_cpu1_dw_fatal_i              (biu_cpu1_dw_fatal),
    .dcu_cpu1_ac_ready_i              (dcu_cpu1_ac_ready),
    .dcu_cpu1_cr_valid_i              (dcu_cpu1_cr_valid),
    .dcu_cpu1_cr_id_i                 (dcu_cpu1_cr_id[2:0]),
    .dcu_cpu1_cr_dirty_i              (dcu_cpu1_cr_dirty),
    .dcu_cpu1_cr_age_i                (dcu_cpu1_cr_age),
    .dcu_cpu1_cr_alloc_i              (dcu_cpu1_cr_alloc),
    .dcu_cpu1_cr_migratory_i          (dcu_cpu1_cr_migratory),
    .dcu_cpu1_dvm_complete_i          (dcu_cpu1_dvm_complete),
    .biu_cpu2_ar_active_i             (biu_cpu2_ar_active),
    .biu_cpu2_ar_valid_i              (biu_cpu2_ar_valid),
    .biu_cpu2_ar_id_i                 (biu_cpu2_ar_id[4:0]),
    .biu_cpu2_ar_type_i               (biu_cpu2_ar_type[4:0]),
    .biu_cpu2_ar_attrs_i              (biu_cpu2_ar_attrs[7:0]),
    .biu_cpu2_ar_way_i                (biu_cpu2_ar_way[4:0]),
    .biu_cpu2_ar_addr_i               (biu_cpu2_ar_addr[40:0]),
    .biu_cpu2_ar_len_i                (biu_cpu2_ar_len[1:0]),
    .biu_cpu2_ar_size_i               (biu_cpu2_ar_size[2:0]),
    .biu_cpu2_ar_lock_i               (biu_cpu2_ar_lock),
    .biu_cpu2_ar_priv_i               (biu_cpu2_ar_priv),
    .biu_cpu2_dr_credit_i             (biu_cpu2_dr_credit),
    .biu_cpu2_dw_valid_i              (biu_cpu2_dw_valid),
    .biu_cpu2_dw_l2db_id_i            (biu_cpu2_dw_l2db_id[3:0]),
    .biu_cpu2_dw_chunks_valid_i       (biu_cpu2_dw_chunks_valid[3:0]),
    .biu_cpu2_dw_last_i               (biu_cpu2_dw_last),
    .biu_cpu2_dw_strb_i               (biu_cpu2_dw_strb[31:0]),
    .biu_cpu2_dw_data_i               (biu_cpu2_dw_data[255:0]),
    .biu_cpu2_dw_err_i                (biu_cpu2_dw_err),
    .biu_cpu2_dw_fatal_i              (biu_cpu2_dw_fatal),
    .dcu_cpu2_ac_ready_i              (dcu_cpu2_ac_ready),
    .dcu_cpu2_cr_valid_i              (dcu_cpu2_cr_valid),
    .dcu_cpu2_cr_id_i                 (dcu_cpu2_cr_id[2:0]),
    .dcu_cpu2_cr_dirty_i              (dcu_cpu2_cr_dirty),
    .dcu_cpu2_cr_age_i                (dcu_cpu2_cr_age),
    .dcu_cpu2_cr_alloc_i              (dcu_cpu2_cr_alloc),
    .dcu_cpu2_cr_migratory_i          (dcu_cpu2_cr_migratory),
    .dcu_cpu2_dvm_complete_i          (dcu_cpu2_dvm_complete),
    .biu_cpu3_ar_active_i             (biu_cpu3_ar_active),
    .biu_cpu3_ar_valid_i              (biu_cpu3_ar_valid),
    .biu_cpu3_ar_id_i                 (biu_cpu3_ar_id[4:0]),
    .biu_cpu3_ar_type_i               (biu_cpu3_ar_type[4:0]),
    .biu_cpu3_ar_attrs_i              (biu_cpu3_ar_attrs[7:0]),
    .biu_cpu3_ar_way_i                (biu_cpu3_ar_way[4:0]),
    .biu_cpu3_ar_addr_i               (biu_cpu3_ar_addr[40:0]),
    .biu_cpu3_ar_len_i                (biu_cpu3_ar_len[1:0]),
    .biu_cpu3_ar_size_i               (biu_cpu3_ar_size[2:0]),
    .biu_cpu3_ar_lock_i               (biu_cpu3_ar_lock),
    .biu_cpu3_ar_priv_i               (biu_cpu3_ar_priv),
    .biu_cpu3_dr_credit_i             (biu_cpu3_dr_credit),
    .biu_cpu3_dw_valid_i              (biu_cpu3_dw_valid),
    .biu_cpu3_dw_l2db_id_i            (biu_cpu3_dw_l2db_id[3:0]),
    .biu_cpu3_dw_chunks_valid_i       (biu_cpu3_dw_chunks_valid[3:0]),
    .biu_cpu3_dw_last_i               (biu_cpu3_dw_last),
    .biu_cpu3_dw_strb_i               (biu_cpu3_dw_strb[31:0]),
    .biu_cpu3_dw_data_i               (biu_cpu3_dw_data[255:0]),
    .biu_cpu3_dw_err_i                (biu_cpu3_dw_err),
    .biu_cpu3_dw_fatal_i              (biu_cpu3_dw_fatal),
    .dcu_cpu3_ac_ready_i              (dcu_cpu3_ac_ready),
    .dcu_cpu3_cr_valid_i              (dcu_cpu3_cr_valid),
    .dcu_cpu3_cr_id_i                 (dcu_cpu3_cr_id[2:0]),
    .dcu_cpu3_cr_dirty_i              (dcu_cpu3_cr_dirty),
    .dcu_cpu3_cr_age_i                (dcu_cpu3_cr_age),
    .dcu_cpu3_cr_alloc_i              (dcu_cpu3_cr_alloc),
    .dcu_cpu3_cr_migratory_i          (dcu_cpu3_cr_migratory),
    .dcu_cpu3_dvm_complete_i          (dcu_cpu3_dvm_complete),
    .gov_mbistreq_i                   (gov_mbistreq),
    .gov_mbistarray0_i                (gov_mbistarray0[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .gov_mbistarray1_i                (gov_mbistarray1[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .gov_mbistwriteen0_i              (gov_mbistwriteen0),
    .gov_mbistwriteen1_i              (gov_mbistwriteen1),
    .gov_mbistreaden0_i               (gov_mbistreaden0),
    .gov_mbistreaden1_i               (gov_mbistreaden1),
    .gov_mbistaddr0_i                 (gov_mbistaddr0[(`CA53_MBIST0_ADDR_W-1): 0]),
    .gov_mbistaddr1_i                 (gov_mbistaddr1[(`CA53_MBIST1_ADDR_W-1): 0]),
    .gov_mbistbe0_i                   (gov_mbistbe0[(`CA53_MBIST0_BE_W-1):0]),
    .gov_mbistbe1_i                   (gov_mbistbe1[(`CA53_MBIST1_BE_W-1):0]),
    .gov_mbistcfg0_i                  (gov_mbistcfg0),
    .gov_mbistcfg1_i                  (gov_mbistcfg1),
    .gov_mbistindata0_i               (gov_mbistindata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .gov_mbistindata1_i               (gov_mbistindata1[(`CA53_MBIST1_DATA_W-1): 0]),
    .l1d_tagram_cpu0_way0_rdata_i     (l1d_tagram_cpu0_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way1_rdata_i     (l1d_tagram_cpu0_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way2_rdata_i     (l1d_tagram_cpu0_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way3_rdata_i     (l1d_tagram_cpu0_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way0_rdata_i     (l1d_tagram_cpu1_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way1_rdata_i     (l1d_tagram_cpu1_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way2_rdata_i     (l1d_tagram_cpu1_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way3_rdata_i     (l1d_tagram_cpu1_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way0_rdata_i     (l1d_tagram_cpu2_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way1_rdata_i     (l1d_tagram_cpu2_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way2_rdata_i     (l1d_tagram_cpu2_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way3_rdata_i     (l1d_tagram_cpu2_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way0_rdata_i     (l1d_tagram_cpu3_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way1_rdata_i     (l1d_tagram_cpu3_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way2_rdata_i     (l1d_tagram_cpu3_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way3_rdata_i     (l1d_tagram_cpu3_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_size_i                        (l2_size_i[`CA53_L2_SIZE_W-1:0]),
    .l2_tagram_way0_rdata_i           (l2_tagram_way0_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way1_rdata_i           (l2_tagram_way1_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way2_rdata_i           (l2_tagram_way2_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way3_rdata_i           (l2_tagram_way3_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way4_rdata_i           (l2_tagram_way4_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way5_rdata_i           (l2_tagram_way5_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way6_rdata_i           (l2_tagram_way6_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way7_rdata_i           (l2_tagram_way7_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way8_rdata_i           (l2_tagram_way8_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way9_rdata_i           (l2_tagram_way9_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way10_rdata_i          (l2_tagram_way10_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way11_rdata_i          (l2_tagram_way11_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way12_rdata_i          (l2_tagram_way12_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way13_rdata_i          (l2_tagram_way13_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way14_rdata_i          (l2_tagram_way14_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way15_rdata_i          (l2_tagram_way15_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_victimram_rdata_i             (l2_victimram_rdata_i[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .l2_dataram_rdata0_i              (l2_dataram_rdata0_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata1_i              (l2_dataram_rdata1_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata2_i              (l2_dataram_rdata2_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata3_i              (l2_dataram_rdata3_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata4_i              (l2_dataram_rdata4_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata5_i              (l2_dataram_rdata5_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata6_i              (l2_dataram_rdata6_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata7_i              (l2_dataram_rdata7_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l1_dc_size_i                     (l1_dc_size_i[`CA53_L1DC_SIZE_W-1:0]),
    .broadcastinner_i                 (broadcastinner_i),
    .broadcastouter_i                 (broadcastouter_i),
    .broadcastcachemaint_i            (broadcastcachemaint_i),
    .sysbardisable_i                  (sysbardisable_i),
    .gov_clear_axierr_i               (gov_clear_axierr),
    .gov_clear_eccerr_i               (gov_clear_eccerr),
    .gov_cpu0_inv_all_req_i           (gov_cpu0_inv_all_req),
    .gov_cpu1_inv_all_req_i           (gov_cpu1_inv_all_req),
    .gov_cpu2_inv_all_req_i           (gov_cpu2_inv_all_req),
    .gov_cpu3_inv_all_req_i           (gov_cpu3_inv_all_req),
    .scu_ext_aclken_i                 (scu_ext_aclken),
    .scu_ext_ar_ready_i               (scu_ext_ar_ready),
    .scu_ext_dr_id_i                  (scu_ext_dr_id[`CA53_SCU_EXT_RID_W-1:0]),
    .scu_ext_dr_valid_i               (scu_ext_dr_valid),
    .scu_ext_dr_last_i                (scu_ext_dr_last),
    .scu_ext_dr_data_i                (scu_ext_dr_data[`CA53_SCU_EXT_DATA_W-1:0]),
    .scu_ext_dr_resp_i                (scu_ext_dr_resp[`CA53_ACE_RRESP_W-1:0]),
    .scu_ext_aw_ready_i               (scu_ext_aw_ready),
    .scu_ext_dw_ready_i               (scu_ext_dw_ready),
    .scu_ext_db_id_i                  (scu_ext_db_id[`CA53_SCU_EXT_WID_W-1:0]),
    .scu_ext_db_resp_i                (scu_ext_db_resp[`CA53_ACE_BRESP_W-1:0]),
    .scu_ext_db_valid_i               (scu_ext_db_valid),
    .scu_ext_ac_valid_i               (scu_ext_ac_valid),
    .scu_ext_ac_snoop_i               (scu_ext_ac_snoop[`CA53_ACE_ACSNOOP_W-1:0]),
    .scu_ext_ac_addr_i                (scu_ext_ac_addr[`CA53_SCU_EXT_ADDR_W-1:0]),
    .scu_ext_ac_prot_i                (scu_ext_ac_prot[`CA53_ACE_ACPROT_W-1:0]),
    .scu_ext_cr_ready_i               (scu_ext_cr_ready),
    .scu_ext_cd_ready_i               (scu_ext_cd_ready),
    .ext_sclken_i                     (ext_sclken),
    .ext_sinact_i                     (ext_sinact),
    .ext_nodeid_i                     (ext_nodeid[6:0]),
    .ext_rxsactive_i                  (ext_rxsactive),
    .ext_rxlinkactivereq_i            (ext_rxlinkactivereq),
    .ext_txlinkactiveack_i            (ext_txlinkactiveack),
    .ext_txreqlcrdv_i                 (ext_txreqlcrdv),
    .ext_txrsplcrdv_i                 (ext_txrsplcrdv),
    .ext_txdatlcrdv_i                 (ext_txdatlcrdv),
    .ext_rxsnpflitpend_i              (ext_rxsnpflitpend),
    .ext_rxsnpflitv_i                 (ext_rxsnpflitv),
    .ext_rxsnpflit_i                  (ext_rxsnpflit[64:0]),
    .ext_rxrspflitpend_i              (ext_rxrspflitpend),
    .ext_rxrspflitv_i                 (ext_rxrspflitv),
    .ext_rxrspflit_i                  (ext_rxrspflit[44:0]),
    .ext_rxdatflitpend_i              (ext_rxdatflitpend),
    .ext_rxdatflitv_i                 (ext_rxdatflitv),
    .ext_rxdatflit_i                  (ext_rxdatflit[193:0]),
    .ext_samaddrmap0_i                (ext_samaddrmap0[1:0]),
    .ext_samaddrmap1_i                (ext_samaddrmap1[1:0]),
    .ext_samaddrmap2_i                (ext_samaddrmap2[1:0]),
    .ext_samaddrmap3_i                (ext_samaddrmap3[1:0]),
    .ext_samaddrmap4_i                (ext_samaddrmap4[1:0]),
    .ext_samaddrmap5_i                (ext_samaddrmap5[1:0]),
    .ext_samaddrmap6_i                (ext_samaddrmap6[1:0]),
    .ext_samaddrmap7_i                (ext_samaddrmap7[1:0]),
    .ext_samaddrmap8_i                (ext_samaddrmap8[1:0]),
    .ext_samaddrmap9_i                (ext_samaddrmap9[1:0]),
    .ext_samaddrmap10_i               (ext_samaddrmap10[1:0]),
    .ext_samaddrmap11_i               (ext_samaddrmap11[1:0]),
    .ext_samaddrmap12_i               (ext_samaddrmap12[1:0]),
    .ext_samaddrmap13_i               (ext_samaddrmap13[1:0]),
    .ext_samaddrmap14_i               (ext_samaddrmap14[1:0]),
    .ext_samaddrmap15_i               (ext_samaddrmap15[1:0]),
    .ext_sammnbase_i                  (ext_sammnbase[39:24]),
    .ext_sammnnodeid_i                (ext_sammnnodeid[6:0]),
    .ext_samhni0nodeid_i              (ext_samhni0nodeid[6:0]),
    .ext_samhni1nodeid_i              (ext_samhni1nodeid[6:0]),
    .ext_samhnf0nodeid_i              (ext_samhnf0nodeid[6:0]),
    .ext_samhnf1nodeid_i              (ext_samhnf1nodeid[6:0]),
    .ext_samhnf2nodeid_i              (ext_samhnf2nodeid[6:0]),
    .ext_samhnf3nodeid_i              (ext_samhnf3nodeid[6:0]),
    .ext_samhnf4nodeid_i              (ext_samhnf4nodeid[6:0]),
    .ext_samhnf5nodeid_i              (ext_samhnf5nodeid[6:0]),
    .ext_samhnf6nodeid_i              (ext_samhnf6nodeid[6:0]),
    .ext_samhnf7nodeid_i              (ext_samhnf7nodeid[6:0]),
    .ext_samhnfmode_i                 (ext_samhnfmode[2:0]),
    .ext_acp_aclken_i                 (ext_acp_aclken),
    .ext_acp_ainact_i                 (ext_acp_ainact),
    .ext_acp_awvalid_i                (ext_acp_awvalid),
    .ext_acp_awid_i                   (ext_acp_awid[4:0]),
    .ext_acp_awaddr_i                 (ext_acp_awaddr[39:0]),
    .ext_acp_awlen_i                  (ext_acp_awlen[7:0]),
    .ext_acp_awcache_i                (ext_acp_awcache[3:0]),
    .ext_acp_awuser_i                 (ext_acp_awuser[1:0]),
    .ext_acp_awprot_i                 (ext_acp_awprot[2:0]),
    .ext_acp_wvalid_i                 (ext_acp_wvalid),
    .ext_acp_wdata_i                  (ext_acp_wdata[127:0]),
    .ext_acp_wstrb_i                  (ext_acp_wstrb[15:0]),
    .ext_acp_wlast_i                  (ext_acp_wlast),
    .ext_acp_bready_i                 (ext_acp_bready),
    .ext_acp_arvalid_i                (ext_acp_arvalid),
    .ext_acp_arid_i                   (ext_acp_arid[4:0]),
    .ext_acp_araddr_i                 (ext_acp_araddr[39:0]),
    .ext_acp_arlen_i                  (ext_acp_arlen[7:0]),
    .ext_acp_arcache_i                (ext_acp_arcache[3:0]),
    .ext_acp_aruser_i                 (ext_acp_aruser[1:0]),
    .ext_acp_arprot_i                 (ext_acp_arprot[2:0]),
    .ext_acp_rready_i                 (ext_acp_rready),
    .gov_cpu0_smp_en_i                (gov_cpu0_smp_en),
    .gov_cpu1_smp_en_i                (gov_cpu1_smp_en),
    .gov_cpu2_smp_en_i                (gov_cpu2_smp_en),
    .gov_cpu3_smp_en_i                (gov_cpu3_smp_en),
    .l2flushreq_i                     (l2flushreq_i),
    // Outputs
    .clk                              (clk),
    .standbywfil2_o                   (standbywfil2_o),
    .scu_wfx_ready_o                  (scu_wfx_ready[NUM_CPUS-1:0]),
    .scu_l2_retention_ready_o         (scu_l2_retention_ready),
    .scu_cpu0_ar_credit_o             (scu_cpu0_ar_credit),
    .scu_cpu0_ar_block_o              (scu_cpu0_ar_block),
    .scu_cpu0_dr_valid_o              (scu_cpu0_dr_valid),
    .scu_cpu0_dr_id_o                 (scu_cpu0_dr_id[4:0]),
    .scu_cpu0_dr_resp_o               (scu_cpu0_dr_resp[5:0]),
    .scu_cpu0_dr_chunk_o              (scu_cpu0_dr_chunk[1:0]),
    .scu_cpu0_dr_data_o               (scu_cpu0_dr_data[127:0]),
    .scu_cpu0_rr_valid_o              (scu_cpu0_rr_valid),
    .scu_cpu0_rr_id_o                 (scu_cpu0_rr_id[4:0]),
    .scu_cpu0_rr_resp_o               (scu_cpu0_rr_resp[1:0]),
    .scu_cpu0_rr_l2db_id_o            (scu_cpu0_rr_l2db_id[3:0]),
    .scu_cpu0_ev_done_o               (scu_cpu0_ev_done[7:0]),
    .scu_cpu0_db_excl_valid_o         (scu_cpu0_db_excl_valid),
    .scu_cpu0_db_excl_resp_o          (scu_cpu0_db_excl_resp[1:0]),
    .scu_cpu0_db_decerr_o             (scu_cpu0_db_decerr),
    .scu_cpu0_db_slverr_o             (scu_cpu0_db_slverr),
    .scu_cpu0_leave_ramode_o          (scu_cpu0_leave_ramode),
    .scu_cpu0_ac_valid_o              (scu_cpu0_ac_valid),
    .scu_cpu0_ac_id_o                 (scu_cpu0_ac_id[2:0]),
    .scu_cpu0_ac_l2db_id_o            (scu_cpu0_ac_l2db_id[3:0]),
    .scu_cpu0_ac_snoop_o              (scu_cpu0_ac_snoop[3:0]),
    .scu_cpu0_ac_addr_o               (scu_cpu0_ac_addr[40:0]),
    .scu_cpu0_ac_way_o                (scu_cpu0_ac_way[3:0]),
    .scu_cpu0_dvm_complete_o          (scu_cpu0_dvm_complete),
    .scu_cpu0_reqbufs_busy_o          (scu_cpu0_reqbufs_busy[7:0]),
    .scu_cpu0_drain_stb_o             (scu_cpu0_drain_stb),
    .scu_cpu1_ar_credit_o             (scu_cpu1_ar_credit),
    .scu_cpu1_ar_block_o              (scu_cpu1_ar_block),
    .scu_cpu1_dr_valid_o              (scu_cpu1_dr_valid),
    .scu_cpu1_dr_id_o                 (scu_cpu1_dr_id[4:0]),
    .scu_cpu1_dr_resp_o               (scu_cpu1_dr_resp[5:0]),
    .scu_cpu1_dr_chunk_o              (scu_cpu1_dr_chunk[1:0]),
    .scu_cpu1_dr_data_o               (scu_cpu1_dr_data[127:0]),
    .scu_cpu1_rr_valid_o              (scu_cpu1_rr_valid),
    .scu_cpu1_rr_id_o                 (scu_cpu1_rr_id[4:0]),
    .scu_cpu1_rr_resp_o               (scu_cpu1_rr_resp[1:0]),
    .scu_cpu1_rr_l2db_id_o            (scu_cpu1_rr_l2db_id[3:0]),
    .scu_cpu1_ev_done_o               (scu_cpu1_ev_done[7:0]),
    .scu_cpu1_db_excl_valid_o         (scu_cpu1_db_excl_valid),
    .scu_cpu1_db_excl_resp_o          (scu_cpu1_db_excl_resp[1:0]),
    .scu_cpu1_db_decerr_o             (scu_cpu1_db_decerr),
    .scu_cpu1_db_slverr_o             (scu_cpu1_db_slverr),
    .scu_cpu1_leave_ramode_o          (scu_cpu1_leave_ramode),
    .scu_cpu1_ac_valid_o              (scu_cpu1_ac_valid),
    .scu_cpu1_ac_id_o                 (scu_cpu1_ac_id[2:0]),
    .scu_cpu1_ac_l2db_id_o            (scu_cpu1_ac_l2db_id[3:0]),
    .scu_cpu1_ac_snoop_o              (scu_cpu1_ac_snoop[3:0]),
    .scu_cpu1_ac_addr_o               (scu_cpu1_ac_addr[40:0]),
    .scu_cpu1_ac_way_o                (scu_cpu1_ac_way[3:0]),
    .scu_cpu1_dvm_complete_o          (scu_cpu1_dvm_complete),
    .scu_cpu1_reqbufs_busy_o          (scu_cpu1_reqbufs_busy[7:0]),
    .scu_cpu1_drain_stb_o             (scu_cpu1_drain_stb),
    .scu_cpu2_ar_credit_o             (scu_cpu2_ar_credit),
    .scu_cpu2_ar_block_o              (scu_cpu2_ar_block),
    .scu_cpu2_dr_valid_o              (scu_cpu2_dr_valid),
    .scu_cpu2_dr_id_o                 (scu_cpu2_dr_id[4:0]),
    .scu_cpu2_dr_resp_o               (scu_cpu2_dr_resp[5:0]),
    .scu_cpu2_dr_chunk_o              (scu_cpu2_dr_chunk[1:0]),
    .scu_cpu2_dr_data_o               (scu_cpu2_dr_data[127:0]),
    .scu_cpu2_rr_valid_o              (scu_cpu2_rr_valid),
    .scu_cpu2_rr_id_o                 (scu_cpu2_rr_id[4:0]),
    .scu_cpu2_rr_resp_o               (scu_cpu2_rr_resp[1:0]),
    .scu_cpu2_rr_l2db_id_o            (scu_cpu2_rr_l2db_id[3:0]),
    .scu_cpu2_ev_done_o               (scu_cpu2_ev_done[7:0]),
    .scu_cpu2_db_excl_valid_o         (scu_cpu2_db_excl_valid),
    .scu_cpu2_db_excl_resp_o          (scu_cpu2_db_excl_resp[1:0]),
    .scu_cpu2_db_decerr_o             (scu_cpu2_db_decerr),
    .scu_cpu2_db_slverr_o             (scu_cpu2_db_slverr),
    .scu_cpu2_leave_ramode_o          (scu_cpu2_leave_ramode),
    .scu_cpu2_ac_valid_o              (scu_cpu2_ac_valid),
    .scu_cpu2_ac_id_o                 (scu_cpu2_ac_id[2:0]),
    .scu_cpu2_ac_l2db_id_o            (scu_cpu2_ac_l2db_id[3:0]),
    .scu_cpu2_ac_snoop_o              (scu_cpu2_ac_snoop[3:0]),
    .scu_cpu2_ac_addr_o               (scu_cpu2_ac_addr[40:0]),
    .scu_cpu2_ac_way_o                (scu_cpu2_ac_way[3:0]),
    .scu_cpu2_dvm_complete_o          (scu_cpu2_dvm_complete),
    .scu_cpu2_reqbufs_busy_o          (scu_cpu2_reqbufs_busy[7:0]),
    .scu_cpu2_drain_stb_o             (scu_cpu2_drain_stb),
    .scu_cpu3_ar_credit_o             (scu_cpu3_ar_credit),
    .scu_cpu3_ar_block_o              (scu_cpu3_ar_block),
    .scu_cpu3_dr_valid_o              (scu_cpu3_dr_valid),
    .scu_cpu3_dr_id_o                 (scu_cpu3_dr_id[4:0]),
    .scu_cpu3_dr_resp_o               (scu_cpu3_dr_resp[5:0]),
    .scu_cpu3_dr_chunk_o              (scu_cpu3_dr_chunk[1:0]),
    .scu_cpu3_dr_data_o               (scu_cpu3_dr_data[127:0]),
    .scu_cpu3_rr_valid_o              (scu_cpu3_rr_valid),
    .scu_cpu3_rr_id_o                 (scu_cpu3_rr_id[4:0]),
    .scu_cpu3_rr_resp_o               (scu_cpu3_rr_resp[1:0]),
    .scu_cpu3_rr_l2db_id_o            (scu_cpu3_rr_l2db_id[3:0]),
    .scu_cpu3_ev_done_o               (scu_cpu3_ev_done[7:0]),
    .scu_cpu3_db_excl_valid_o         (scu_cpu3_db_excl_valid),
    .scu_cpu3_db_excl_resp_o          (scu_cpu3_db_excl_resp[1:0]),
    .scu_cpu3_db_decerr_o             (scu_cpu3_db_decerr),
    .scu_cpu3_db_slverr_o             (scu_cpu3_db_slverr),
    .scu_cpu3_leave_ramode_o          (scu_cpu3_leave_ramode),
    .scu_cpu3_ac_valid_o              (scu_cpu3_ac_valid),
    .scu_cpu3_ac_id_o                 (scu_cpu3_ac_id[2:0]),
    .scu_cpu3_ac_l2db_id_o            (scu_cpu3_ac_l2db_id[3:0]),
    .scu_cpu3_ac_snoop_o              (scu_cpu3_ac_snoop[3:0]),
    .scu_cpu3_ac_addr_o               (scu_cpu3_ac_addr[40:0]),
    .scu_cpu3_ac_way_o                (scu_cpu3_ac_way[3:0]),
    .scu_cpu3_dvm_complete_o          (scu_cpu3_dvm_complete),
    .scu_cpu3_reqbufs_busy_o          (scu_cpu3_reqbufs_busy[7:0]),
    .scu_cpu3_drain_stb_o             (scu_cpu3_drain_stb),
    .scu_mbistack0_o                  (scu_mbistack0),
    .scu_mbistack1_o                  (scu_mbistack1),
    .scu_mbistoutdata0_o              (scu_mbistoutdata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .scu_mbistoutdata1_o              (scu_mbistoutdata1[(`CA53_MBIST1_DATA_W-1): 0]),
    .l1d_tagram_clken_o               (l1d_tagram_clken_o),
    .l1d_tagram_cpu0_en_o             (l1d_tagram_cpu0_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu0_wr_o             (l1d_tagram_cpu0_wr_o),
    .l1d_tagram_cpu0_addr_o           (l1d_tagram_cpu0_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu0_wdata_o          (l1d_tagram_cpu0_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_en_o             (l1d_tagram_cpu1_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu1_wr_o             (l1d_tagram_cpu1_wr_o),
    .l1d_tagram_cpu1_addr_o           (l1d_tagram_cpu1_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu1_wdata_o          (l1d_tagram_cpu1_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_en_o             (l1d_tagram_cpu2_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu2_wr_o             (l1d_tagram_cpu2_wr_o),
    .l1d_tagram_cpu2_addr_o           (l1d_tagram_cpu2_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu2_wdata_o          (l1d_tagram_cpu2_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_en_o             (l1d_tagram_cpu3_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu3_wr_o             (l1d_tagram_cpu3_wr_o),
    .l1d_tagram_cpu3_addr_o           (l1d_tagram_cpu3_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu3_wdata_o          (l1d_tagram_cpu3_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_tagram_clken_o                (l2_tagram_clken_o),
    .l2_tagram_en_o                   (l2_tagram_en_o[`CA53_SCU_L2_ASSOC-1:0]),
    .l2_tagram_wr_o                   (l2_tagram_wr_o),
    .l2_tagram_addr_o                 (l2_tagram_addr_o[`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]),
    .l2_tagram_wdata_o                (l2_tagram_wdata_o[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_victimram_no_acc_next_cycle_o (l2_victimram_no_acc_next_cycle_o),
    .l2_victimram_clken_o             (l2_victimram_clken_o),
    .l2_victimram_en_o                (l2_victimram_en_o),
    .l2_victimram_wr_o                (l2_victimram_wr_o),
    .l2_victimram_strb_o              (l2_victimram_strb_o[`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0]),
    .l2_victimram_addr_o              (l2_victimram_addr_o[`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0]),
    .l2_victimram_wdata_o             (l2_victimram_wdata_o[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .l2_dataram_no_acc_next_cycle_o   (l2_dataram_no_acc_next_cycle_o),
    .l2_dataram_clken_o               (l2_dataram_clken_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_en_o                  (l2_dataram_en_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_wr_o                  (l2_dataram_wr_o),
    .l2_dataram_addr_o                (l2_dataram_addr_o[`CA53_SCU_L2_DATARAM_ADDR_W-1:0]),
    .l2_dataram_wdata0_o              (l2_dataram_wdata0_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata1_o              (l2_dataram_wdata1_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata2_o              (l2_dataram_wdata2_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata3_o              (l2_dataram_wdata3_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata4_o              (l2_dataram_wdata4_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata5_o              (l2_dataram_wdata5_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata6_o              (l2_dataram_wdata6_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata7_o              (l2_dataram_wdata7_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .scu_cpu0_broadcastinner_o        (scu_cpu0_broadcastinner),
    .scu_cpu1_broadcastinner_o        (scu_cpu1_broadcastinner),
    .scu_cpu2_broadcastinner_o        (scu_cpu2_broadcastinner),
    .scu_cpu3_broadcastinner_o        (scu_cpu3_broadcastinner),
    .nexterrirq_o                     (nexterrirq_o),
    .ninterrirq_o                     (ninterrirq_o),
    .scu_axierr_o                     (scu_axierr),
    .scu_eccerr_o                     (scu_eccerr),
    .scu_l2ecc_valid_o                (scu_l2ecc_valid),
    .scu_l2ecc_fatal_o                (scu_l2ecc_fatal),
    .scu_l2ecc_ramid_o                (scu_l2ecc_ramid[  1: 0]),
    .scu_l2ecc_cpuid_way_o            (scu_l2ecc_cpuid_way[  3: 0]),
    .scu_l2ecc_index_o                (scu_l2ecc_index[ 14: 0]),
    .scu_cpu0_inv_all_ack_o           (scu_cpu0_inv_all_ack),
    .scu_cpu1_inv_all_ack_o           (scu_cpu1_inv_all_ack),
    .scu_cpu2_inv_all_ack_o           (scu_cpu2_inv_all_ack),
    .scu_cpu3_inv_all_ack_o           (scu_cpu3_inv_all_ack),
    .scu_cpu0_evnt_l2_access_o        (scu_cpu0_evnt_l2_access),
    .scu_cpu0_evnt_l2_refill_o        (scu_cpu0_evnt_l2_refill),
    .scu_cpu0_evnt_l2_wb_o            (scu_cpu0_evnt_l2_wb),
    .scu_cpu0_evnt_snooped_data_o     (scu_cpu0_evnt_snooped_data),
    .scu_cpu0_evnt_bus_cycle_o        (scu_cpu0_evnt_bus_cycle),
    .scu_cpu0_evnt_bus_acc_rd_o       (scu_cpu0_evnt_bus_acc_rd),
    .scu_cpu0_evnt_bus_acc_wr_o       (scu_cpu0_evnt_bus_acc_wr),
    .scu_cpu0_evnt_eviction_o         (scu_cpu0_evnt_eviction),
    .scu_cpu1_evnt_l2_access_o        (scu_cpu1_evnt_l2_access),
    .scu_cpu1_evnt_l2_refill_o        (scu_cpu1_evnt_l2_refill),
    .scu_cpu1_evnt_l2_wb_o            (scu_cpu1_evnt_l2_wb),
    .scu_cpu1_evnt_snooped_data_o     (scu_cpu1_evnt_snooped_data),
    .scu_cpu1_evnt_bus_cycle_o        (scu_cpu1_evnt_bus_cycle),
    .scu_cpu1_evnt_bus_acc_rd_o       (scu_cpu1_evnt_bus_acc_rd),
    .scu_cpu1_evnt_bus_acc_wr_o       (scu_cpu1_evnt_bus_acc_wr),
    .scu_cpu1_evnt_eviction_o         (scu_cpu1_evnt_eviction),
    .scu_cpu2_evnt_l2_access_o        (scu_cpu2_evnt_l2_access),
    .scu_cpu2_evnt_l2_refill_o        (scu_cpu2_evnt_l2_refill),
    .scu_cpu2_evnt_l2_wb_o            (scu_cpu2_evnt_l2_wb),
    .scu_cpu2_evnt_snooped_data_o     (scu_cpu2_evnt_snooped_data),
    .scu_cpu2_evnt_bus_cycle_o        (scu_cpu2_evnt_bus_cycle),
    .scu_cpu2_evnt_bus_acc_rd_o       (scu_cpu2_evnt_bus_acc_rd),
    .scu_cpu2_evnt_bus_acc_wr_o       (scu_cpu2_evnt_bus_acc_wr),
    .scu_cpu2_evnt_eviction_o         (scu_cpu2_evnt_eviction),
    .scu_cpu3_evnt_l2_access_o        (scu_cpu3_evnt_l2_access),
    .scu_cpu3_evnt_l2_refill_o        (scu_cpu3_evnt_l2_refill),
    .scu_cpu3_evnt_l2_wb_o            (scu_cpu3_evnt_l2_wb),
    .scu_cpu3_evnt_snooped_data_o     (scu_cpu3_evnt_snooped_data),
    .scu_cpu3_evnt_bus_cycle_o        (scu_cpu3_evnt_bus_cycle),
    .scu_cpu3_evnt_bus_acc_rd_o       (scu_cpu3_evnt_bus_acc_rd),
    .scu_cpu3_evnt_bus_acc_wr_o       (scu_cpu3_evnt_bus_acc_wr),
    .scu_cpu3_evnt_eviction_o         (scu_cpu3_evnt_eviction),
    .scu_ext_ar_valid_o               (scu_ext_ar_valid_o),
    .scu_ext_ar_addr_o                (scu_ext_ar_addr_o[`CA53_SCU_EXT_ADDR_W-1:0]),
    .scu_ext_ar_len_o                 (scu_ext_ar_len_o[`CA53_ACE_ARLEN_W-1:0]),
    .scu_ext_ar_size_o                (scu_ext_ar_size_o[`CA53_ACE_ARSIZE_W-1:0]),
    .scu_ext_ar_burst_o               (scu_ext_ar_burst_o[`CA53_ACE_ARBURST_W-1:0]),
    .scu_ext_ar_lock_o                (scu_ext_ar_lock_o),
    .scu_ext_ar_cache_o               (scu_ext_ar_cache_o[`CA53_ACE_ARCACHE_W-1:0]),
    .scu_ext_ar_prot_o                (scu_ext_ar_prot_o[`CA53_ACE_ARPROT_W-1:0]),
    .scu_ext_ar_snoop_o               (scu_ext_ar_snoop_o[`CA53_ACE_ARSNOOP_W-1:0]),
    .scu_ext_ar_domain_o              (scu_ext_ar_domain_o[`CA53_ACE_ARDOMAIN_W-1:0]),
    .scu_ext_ar_bar_o                 (scu_ext_ar_bar_o[`CA53_ACE_ARBAR_W-1:0]),
    .scu_ext_ar_id_o                  (scu_ext_ar_id_o[`CA53_SCU_EXT_RID_W-1:0]),
    .scu_ext_rdmemattr_o              (scu_ext_rdmemattr_o[7:0]),
    .scu_ext_dr_ready_o               (scu_ext_dr_ready_o),
    .scu_ext_aw_valid_o               (scu_ext_aw_valid_o),
    .scu_ext_aw_addr_o                (scu_ext_aw_addr_o[`CA53_SCU_EXT_ADDR_W-1:0]),
    .scu_ext_aw_len_o                 (scu_ext_aw_len_o[`CA53_ACE_AWLEN_W-1:0]),
    .scu_ext_aw_size_o                (scu_ext_aw_size_o[`CA53_ACE_AWSIZE_W-1:0]),
    .scu_ext_aw_burst_o               (scu_ext_aw_burst_o[`CA53_ACE_AWBURST_W-1:0]),
    .scu_ext_aw_lock_o                (scu_ext_aw_lock_o),
    .scu_ext_aw_cache_o               (scu_ext_aw_cache_o[`CA53_ACE_AWCACHE_W-1:0]),
    .scu_ext_aw_prot_o                (scu_ext_aw_prot_o[`CA53_ACE_AWPROT_W-1:0]),
    .scu_ext_aw_snoop_o               (scu_ext_aw_snoop_o[`CA53_ACE_AWSNOOP_W-1:0]),
    .scu_ext_aw_domain_o              (scu_ext_aw_domain_o[`CA53_ACE_AWDOMAIN_W-1:0]),
    .scu_ext_aw_bar_o                 (scu_ext_aw_bar_o[`CA53_ACE_AWBAR_W-1:0]),
    .scu_ext_aw_id_o                  (scu_ext_aw_id_o[`CA53_SCU_EXT_WID_W-1:0]),
    .scu_ext_aw_unique_o              (scu_ext_aw_unique_o),
    .scu_ext_wrmemattr_o              (scu_ext_wrmemattr_o[7:0]),
    .scu_ext_dw_strb_o                (scu_ext_dw_strb_o[`CA53_SCU_EXT_STRB_W-1:0]),
    .scu_ext_dw_data_o                (scu_ext_dw_data_o[`CA53_SCU_EXT_DATA_W-1:0]),
    .scu_ext_dw_id_o                  (scu_ext_dw_id_o[`CA53_SCU_EXT_WID_W-1:0]),
    .scu_ext_dw_last_o                (scu_ext_dw_last_o),
    .scu_ext_dw_valid_o               (scu_ext_dw_valid_o),
    .scu_ext_db_ready_o               (scu_ext_db_ready_o),
    .scu_ext_ac_ready_o               (scu_ext_ac_ready_o),
    .scu_ext_cr_valid_o               (scu_ext_cr_valid_o),
    .scu_ext_cr_resp_o                (scu_ext_cr_resp_o[`CA53_ACE_CRRESP_W-1:0]),
    .scu_ext_cd_valid_o               (scu_ext_cd_valid_o),
    .scu_ext_cd_data_o                (scu_ext_cd_data_o[`CA53_SCU_EXT_DATA_W-1:0]),
    .scu_ext_cd_last_o                (scu_ext_cd_last_o),
    .scu_ext_rack_o                   (scu_ext_rack_o),
    .scu_ext_wack_o                   (scu_ext_wack_o),
    .scu_txsactive_o                  (scu_txsactive_o),
    .scu_rxlinkactiveack_o            (scu_rxlinkactiveack_o),
    .scu_txlinkactivereq_o            (scu_txlinkactivereq_o),
    .scu_txreqflitpend_o              (scu_txreqflitpend_o),
    .scu_txreqflitv_o                 (scu_txreqflitv_o),
    .scu_txreqflit_o                  (scu_txreqflit_o[99:0]),
    .scu_reqmemattr_o                 (scu_reqmemattr_o[7:0]),
    .scu_txrspflitpend_o              (scu_txrspflitpend_o),
    .scu_txrspflitv_o                 (scu_txrspflitv_o),
    .scu_txrspflit_o                  (scu_txrspflit_o[44:0]),
    .scu_txdatflitpend_o              (scu_txdatflitpend_o),
    .scu_txdatflitv_o                 (scu_txdatflitv_o),
    .scu_txdatflit_o                  (scu_txdatflit_o[193:0]),
    .scu_rxsnplcrdv_o                 (scu_rxsnplcrdv_o),
    .scu_rxrsplcrdv_o                 (scu_rxrsplcrdv_o),
    .scu_rxdatlcrdv_o                 (scu_rxdatlcrdv_o),
    .scu_acp_awready_o                (scu_acp_awready_o),
    .scu_acp_wready_o                 (scu_acp_wready_o),
    .scu_acp_bvalid_o                 (scu_acp_bvalid_o),
    .scu_acp_bid_o                    (scu_acp_bid_o[4:0]),
    .scu_acp_bresp_o                  (scu_acp_bresp_o[1:0]),
    .scu_acp_arready_o                (scu_acp_arready_o),
    .scu_acp_rvalid_o                 (scu_acp_rvalid_o),
    .scu_acp_rid_o                    (scu_acp_rid_o[4:0]),
    .scu_acp_rdata_o                  (scu_acp_rdata_o[127:0]),
    .scu_acp_rresp_o                  (scu_acp_rresp_o[1:0]),
    .scu_acp_rlast_o                  (scu_acp_rlast_o),
    .l2flushdone_o                    (l2flushdone_o)
  );  // u_ca53scu

  // ------------------------------------------------------
  // Governor
  // ------------------------------------------------------

  ca53governor `CA53_GOVERNOR_PARAM_INST u_ca53governor (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .DFTRSTDISABLE                 (DFTRSTDISABLE),
    .ncpuporeset                   (ncpuporeset[NUM_CPUS-1: 0]),
    .ncorereset                    (ncorereset[NUM_CPUS-1: 0]),
    .nl2reset                      (nl2reset),
    .nmbistreset                   (nmbistreset),
    .cfgend_i                      (cfgend_i[NUM_CPUS-1: 0]),
    .vinithi_i                     (vinithi_i[NUM_CPUS-1: 0]),
    .cfgte_i                       (cfgte_i[NUM_CPUS-1: 0]),
    .cp15sdisable_i                (cp15sdisable_i[NUM_CPUS-1: 0]),
    .clusteridaff1_i               (clusteridaff1_i[  7: 0]),
    .clusteridaff2_i               (clusteridaff2_i[  7: 0]),
    .etm_oslock_i                  (etm_oslock_i[NUM_CPUS-1: 0]),
    .aa64naa32_i                   (aa64naa32_i[NUM_CPUS-1: 0]),
    .rvbaraddr_i                   (rvbaraddr_i[(`CA53_RVBARADDR_PKDED_W-1): 0]),
    .cryptodisable_i               (cryptodisable_i[NUM_CPUS-1: 0]),
    .nfiq_i                        (nfiq_i[NUM_CPUS-1: 0]),
    .nirq_i                        (nirq_i[NUM_CPUS-1: 0]),
    .nsei_i                        (nsei_i[NUM_CPUS-1: 0]),
    .nrei_i                        (nrei_i[NUM_CPUS-1:0]),
    .nvfiq_i                       (nvfiq_i[NUM_CPUS-1: 0]),
    .nvirq_i                       (nvirq_i[NUM_CPUS-1: 0]),
    .nvsei_i                       (nvsei_i[NUM_CPUS-1: 0]),
    .periphbase_i                  (periphbase_i[ 39:18]),
    .giccdisable_i                 (giccdisable_i),
    .icdtvalid_i                   (icdtvalid_i),
    .icdtdata_i                    (icdtdata_i[ 15: 0]),
    .icdtlast_i                    (icdtlast_i),
    .icdtdest_i                    (icdtdest_i[  1: 0]),
    .icctready_i                   (icctready_i),
    .cntvalueb_i                   (cntvalueb_i[ 63: 0]),
    .cntclken_i                    (cntclken_i),
    .tsvalueb_i                    (tsvalueb_i[ 63: 0]),
    .clrexmonreq_i                 (clrexmonreq_i),
    .eventi_i                      (eventi_i),
    .dpu_sev_req_i                 (dpu_sev_req_i[NUM_CPUS-1: 0]),
    .dpu_clr_event_register_i      (dpu_clr_event_register_i[NUM_CPUS-1: 0]),
    .dpu_exception_level_i         (dpu_exception_level_i[(`CA53_EXCP_LEV_PKDED_W-1):0]),
    .dpu_aarch64_at_el3_i          (dpu_aarch64_at_el3_i[NUM_CPUS-1: 0]),
    .dpu_hcr_el2_fmo_i             (dpu_hcr_el2_fmo_i[NUM_CPUS-1: 0]),
    .dpu_hcr_el2_imo_i             (dpu_hcr_el2_imo_i[NUM_CPUS-1: 0]),
    .dpu_hcr_el2_amo_i             (dpu_hcr_el2_amo_i[NUM_CPUS-1: 0]),
    .dpu_monitor_mode_i            (dpu_monitor_mode_i[NUM_CPUS-1: 0]),
    .dpu_rei_level_ack_i           (dpu_rei_level_ack_i[NUM_CPUS-1: 0]),
    .dpu_scr_el3_fiq_i             (dpu_scr_el3_fiq_i[NUM_CPUS-1: 0]),
    .dpu_scr_el3_irq_i             (dpu_scr_el3_irq_i[NUM_CPUS-1: 0]),
    .dpu_scr_el3_ns_i              (dpu_scr_el3_ns_i[NUM_CPUS-1: 0]),
    .dpu_sei_level_ack_i           (dpu_sei_level_ack_i[NUM_CPUS-1: 0]),
    .dpu_vsei_level_ack_i          (dpu_vsei_level_ack_i[NUM_CPUS-1: 0]),
    .dpu_wfi_req_i                 (dpu_wfi_req_i[NUM_CPUS-1: 0]),
    .dpu_wfe_req_i                 (dpu_wfe_req_i[NUM_CPUS-1: 0]),
    .dpu_irq_pended_i              (dpu_irq_pended_i[NUM_CPUS-1: 0]),
    .dpu_fiq_pended_i              (dpu_fiq_pended_i[NUM_CPUS-1: 0]),
    .dpu_sei_pended_i              (dpu_sei_pended_i[NUM_CPUS-1: 0]),
    .dpu_irq_masked_i              (dpu_irq_masked_i[NUM_CPUS-1: 0]),
    .dpu_fiq_masked_i              (dpu_fiq_masked_i[NUM_CPUS-1: 0]),
    .dpu_sei_masked_i              (dpu_sei_masked_i[NUM_CPUS-1: 0]),
    .dpu_virq_pended_i             (dpu_virq_pended_i[NUM_CPUS-1: 0]),
    .dpu_vfiq_pended_i             (dpu_vfiq_pended_i[NUM_CPUS-1: 0]),
    .dpu_vsei_pended_i             (dpu_vsei_pended_i[NUM_CPUS-1: 0]),
    .dpu_virq_masked_i             (dpu_virq_masked_i[NUM_CPUS-1: 0]),
    .dpu_vfiq_masked_i             (dpu_vfiq_masked_i[NUM_CPUS-1: 0]),
    .dpu_vsei_masked_i             (dpu_vsei_masked_i[NUM_CPUS-1: 0]),
    .dpu_dbg_double_lock_set_i     (dpu_dbg_double_lock_set_i[NUM_CPUS-1: 0]),
    .dpu_ns_state_i                (dpu_ns_state_i[NUM_CPUS-1: 0]),
    .stb_wfx_ready_i               (stb_wfx_ready_i[NUM_CPUS-1: 0]),
    .biu_wfx_ready_i               (biu_wfx_ready_i[NUM_CPUS-1: 0]),
    .dcu_wfx_ready_i               (dcu_wfx_ready_i[NUM_CPUS-1: 0]),
    .ifu_wfx_ready_i               (ifu_wfx_ready_i[NUM_CPUS-1: 0]),
    .tlb_wfx_ready_i               (tlb_wfx_ready_i[NUM_CPUS-1: 0]),
    .etm_wfx_ready_i               (etm_wfx_ready_i[NUM_CPUS-1: 0]),
    .scu_wfx_ready_i               (scu_wfx_ready[NUM_CPUS-1: 0]),
    .dpu_imp_abort_pending_i       (dpu_imp_abort_pending_i[NUM_CPUS-1: 0]),
    .dpu_cpuectlr_cpu_ret_delay_i  (dpu_cpuectlr_cpu_ret_delay_i[(`CA53_RET_CTL_PKDED_W-1): 0]),
    .dpu_cpuectlr_neon_ret_delay_i (dpu_cpuectlr_neon_ret_delay_i[(`CA53_RET_CTL_PKDED_W-1): 0]),
    .dpu_neon_active_i             (dpu_neon_active_i[NUM_CPUS-1: 0]),
    .dpu_smp_en_i                  (dpu_smp_en_i[NUM_CPUS-1: 0]),
    .cpuqreqn_i                    (cpuqreqn_i[NUM_CPUS-1: 0]),
    .neonqreqn_i                   (neonqreqn_i[NUM_CPUS-1: 0]),
    .l2qreqn_i                     (l2qreqn_i),
    .scu_l2_retention_ready_i      (scu_l2_retention_ready),
    .scu_ac_valid_i                (scu_ac_valid_o[(`CA53_ACVALID_PKDED_W-1): 0]),
    .dpu_prdatadbg_i               (dpu_prdatadbg_i[(`CA53_PRDATADBG_PKDED_W-1): 0]),
    .dpu_preadydbg_i               (dpu_preadydbg_i[NUM_CPUS-1: 0]),
    .dpu_pslverrdbg_i              (dpu_pslverrdbg_i[NUM_CPUS-1: 0]),
    .etm_prdatadbg_i               (etm_prdatadbg_i[(`CA53_PRDATADBG_PKDED_W-1): 0]),
    .etm_preadydbg_i               (etm_preadydbg_i[NUM_CPUS-1: 0]),
    .etm_extout_i                  (etm_extout_i[(`CA53_ETMEXT_PKDED_W-1): 0]),
    .dcu_excl_mon_cleared_i        (dcu_excl_mon_cleared_i[NUM_CPUS-1:0]),
    .dcu_cp_gov_addr_i             (dcu_cp_gov_addr_i[(`CA53_CPADDR_PKDED_W-1):0]),
    .dcu_cp_gov_ns_i               (dcu_cp_gov_ns_i[NUM_CPUS-1: 0]),
    .dcu_cp_gov_req_i              (dcu_cp_gov_req_i[NUM_CPUS-1: 0]),
    .dcu_cp_gov_sel_i              (dcu_cp_gov_sel_i[(`CA53_CPSEL_PKDED_W-1):0]),
    .dcu_cp_gov_wdata_i            (dcu_cp_gov_wdata_i[(`CA53_CPDATA_PKDED_W-1):0]),
    .dcu_cp_gov_wenable_i          (dcu_cp_gov_wenable_i[NUM_CPUS-1: 0]),
    .npresetdbg                    (npresetdbg_i),
    .pclkendbg_i                   (pclkendbg_i),
    .pseldbg_i                     (pseldbg_i),
    .paddrdbg_i                    (paddrdbg_i[ 21: 2]),
    .paddrdbg31_i                  (paddrdbg31_i),
    .penabledbg_i                  (penabledbg_i),
    .pwritedbg_i                   (pwritedbg_i),
    .pwdatadbg_i                   (pwdatadbg_i[ 31: 0]),
    .dbgromaddr_i                  (dbgromaddr_i[ 39:12]),
    .dbgromaddrv_i                 (dbgromaddrv_i),
    .dpu_warmrstreq_i              (dpu_warmrstreq_i[NUM_CPUS-1: 0]),
    .dpu_dbgtrigger_i              (dpu_dbgtrigger_i[NUM_CPUS-1: 0]),
    .dpu_dbgack_i                  (dpu_dbgack_i[NUM_CPUS-1: 0]),
    .dpu_commrx_i                  (dpu_commrx_i[NUM_CPUS-1: 0]),
    .dpu_commtx_i                  (dpu_commtx_i[NUM_CPUS-1: 0]),
    .dpu_ncommirq_i                (dpu_ncommirq_i[NUM_CPUS-1: 0]),
    .dpu_dscr_halted_i             (dpu_dscr_halted_i[NUM_CPUS-1: 0]),
    .edbgrq_i                      (edbgrq_i[NUM_CPUS-1: 0]),
    .dbgen_i                       (dbgen_i[NUM_CPUS-1: 0]),
    .niden_i                       (niden_i[NUM_CPUS-1: 0]),
    .spiden_i                      (spiden_i[NUM_CPUS-1: 0]),
    .spniden_i                     (spniden_i[NUM_CPUS-1: 0]),
    .dpu_dbgrstreq_i               (dpu_dbgrstreq_i[NUM_CPUS-1: 0]),
    .dpu_dbgnopwrdwn_i             (dpu_dbgnopwrdwn_i[NUM_CPUS-1: 0]),
    .dbgpwrdup_i                   (dbgpwrdup_i[NUM_CPUS-1: 0]),
    .dbgl1rstdisable_i             (dbgl1rstdisable_i),
    .scu_axierr_i                  (scu_axierr),
    .scu_eccerr_i                  (scu_eccerr),
    .scu_l2ecc_valid_i             (scu_l2ecc_valid),
    .scu_l2ecc_fatal_i             (scu_l2ecc_fatal),
    .scu_l2ecc_ramid_i             (scu_l2ecc_ramid[  1: 0]),
    .scu_l2ecc_cpuid_way_i         (scu_l2ecc_cpuid_way[  3: 0]),
    .scu_l2ecc_index_i             (scu_l2ecc_index[ 14: 0]),
    .atclken_i                     (atclken_i),
    .atreadym_i                    (atreadym_i[(`CA53_ATREADYM_PKDED_W-1): 0]),
    .afvalidm_i                    (afvalidm_i[(`CA53_AFVALIDM_PKDED_W-1): 0]),
    .etm_atdatam_i                 (etm_atdatam_i[(`CA53_ATDATAM_PKDED_W-1): 0]),
    .etm_atvalidm_i                (etm_atvalidm_i[(`CA53_ATVALIDM_PKDED_W-1): 0]),
    .etm_atbytesm_i                (etm_atbytesm_i[(`CA53_ATBYTESM_PKDED_W-1): 0]),
    .etm_afreadym_i                (etm_afreadym_i[(`CA53_AFREADYM_PKDED_W-1): 0]),
    .etm_atidm_i                   (etm_atidm_i[(`CA53_ATIDM_PKDED_W-1): 0]),
    .syncreqm_i                    (syncreqm_i[(`CA53_SYNCREQM_PKDED_W-1): 0]),
    .ctichin_i                     (ctichin_i[3:0]),
    .ctichoutack_i                 (ctichoutack_i[3:0]),
    .ctiirqack_i                   (ctiirqack_i[NUM_CPUS-1: 0]),
    .cisbypass_i                   (cisbypass_i),
    .cihsbypass_i                  (cihsbypass_i[3:0]),
    .dpu_npmuirq_i                 (dpu_npmuirq_i[NUM_CPUS-1: 0]),
    .dpu_pmuevent_i                (dpu_pmuevent_i[(`CA53_PMUEVNT_CPU_PKDED_W-1): 0]),
    .scu_inv_all_ack_i             (scu_inv_all_ack[NUM_CPUS-1: 0]),
    .mbistreq_i                    (mbistreq_i),
    .scu_mbistack0_i               (scu_mbistack0),
    .scu_mbistack1_i               (scu_mbistack1),
    .mbistaddr0_i                  (mbistaddr0_i[(`CA53_MBIST0_ADDR_W-1): 0]),
    .mbistaddr1_i                  (mbistaddr1_i[(`CA53_MBIST1_ADDR_W-1): 0]),
    .mbistindata0_i                (mbistindata0_i[(`CA53_MBIST0_DATA_W-1): 0]),
    .mbistindata1_i                (mbistindata1_i[(`CA53_MBIST1_DATA_W-1): 0]),
    .scu_mbistoutdata0_i           (scu_mbistoutdata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .scu_mbistoutdata1_i           (scu_mbistoutdata1[(`CA53_MBIST1_DATA_W-1): 0]),
    .mbistwriteen0_i               (mbistwriteen0_i),
    .mbistwriteen1_i               (mbistwriteen1_i),
    .mbistreaden0_i                (mbistreaden0_i),
    .mbistreaden1_i                (mbistreaden1_i),
    .mbistarray0_i                 (mbistarray0_i[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .mbistarray1_i                 (mbistarray1_i[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .mbistbe0_i                    (mbistbe0_i[(`CA53_MBIST0_BE_W-1):0]),
    .mbistbe1_i                    (mbistbe1_i[(`CA53_MBIST1_BE_W-1):0]),
    .mbistcfg0_i                   (mbistcfg0_i),
    .mbistcfg1_i                   (mbistcfg1_i),
    // Outputs
    .clk_cpu                       (clk_cpu[NUM_CPUS-1: 0]),
    .reset_n_cpu                   (reset_n_cpu[NUM_CPUS-1: 0]),
    .po_reset_n_cpu                (po_reset_n_cpu[NUM_CPUS-1: 0]),
    .warmrstreq_o                  (warmrstreq_o[NUM_CPUS-1: 0]),
    .gov_cfgend_o                  (gov_cfgend_o[NUM_CPUS-1: 0]),
    .gov_vinithi_o                 (gov_vinithi_o[NUM_CPUS-1: 0]),
    .gov_cfgte_o                   (gov_cfgte_o[NUM_CPUS-1: 0]),
    .gov_cp15sdisable_o            (gov_cp15sdisable_o[NUM_CPUS-1: 0]),
    .gov_clusteridaff1_o           (gov_clusteridaff1_o[  7: 0]),
    .gov_clusteridaff2_o           (gov_clusteridaff2_o[  7: 0]),
    .gov_aa64naa32_o               (gov_aa64naa32_o[NUM_CPUS-1: 0]),
    .gov_rvbaraddr_o               (gov_rvbaraddr_o[(`CA53_RVBARADDR_PKDED_W-1): 0]),
    .gov_cryptodisable_o           (gov_cryptodisable_o[NUM_CPUS-1: 0]),
    .gov_stall_neon_o              (gov_stall_neon_o[NUM_CPUS-1: 0]),
    .ncntpsirq_o                   (ncntpsirq_o[NUM_CPUS-1: 0]),
    .ncntpnsirq_o                  (ncntpnsirq_o[NUM_CPUS-1: 0]),
    .ncnthpirq_o                   (ncnthpirq_o[NUM_CPUS-1: 0]),
    .ncntvirq_o                    (ncntvirq_o[NUM_CPUS-1: 0]),
    .gic_irq_o                     (gic_irq_o[NUM_CPUS-1: 0]),
    .gic_fiq_o                     (gic_fiq_o[NUM_CPUS-1: 0]),
    .gic_virq_o                    (gic_virq_o[NUM_CPUS-1: 0]),
    .gic_vfiq_o                    (gic_vfiq_o[NUM_CPUS-1: 0]),
    .gov_sei_level_req_o           (gov_sei_level_req_o[NUM_CPUS-1: 0]),
    .gov_vsei_level_req_o          (gov_vsei_level_req_o[NUM_CPUS-1: 0]),
    .gov_rei_level_req_o           (gov_rei_level_req_o[NUM_CPUS-1: 0]),
    .gov_int_active_o              (gov_int_active_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el1_ns_sre_o      (gic_icc_sre_el1_ns_sre_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el1_s_sre_o       (gic_icc_sre_el1_s_sre_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el2_enable_o      (gic_icc_sre_el2_enable_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el2_sre_o         (gic_icc_sre_el2_sre_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el3_enable_o      (gic_icc_sre_el3_enable_o[NUM_CPUS-1: 0]),
    .gic_icc_sre_el3_sre_o         (gic_icc_sre_el3_sre_o[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tall0_o       (gic_ich_hcr_el2_tall0_o[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tall1_o       (gic_ich_hcr_el2_tall1_o[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tc_o          (gic_ich_hcr_el2_tc_o[NUM_CPUS-1: 0]),
    .nvcpumntirq_o                 (nvcpumntirq_o[NUM_CPUS-1: 0]),
    .gov_periphbase_o              (gov_periphbase_o[ 39:18]),
    .gov_giccdisable_o             (gov_giccdisable_o),
    .icdtready_o                   (icdtready_o),
    .icctvalid_o                   (icctvalid_o),
    .icctdata_o                    (icctdata_o[ 15: 0]),
    .icctlast_o                    (icctlast_o),
    .icctid_o                      (icctid_o[  1: 0]),
    .gov_tsvalueb_o                (gov_tsvalueb_o[ 63: 0]),
    .gov_standbywfi_o              (gov_standbywfi[NUM_CPUS-1: 0]),
    .gov_standbywfe_o              (gov_standbywfe_o[NUM_CPUS-1: 0]),
    .standbywfi_o                  (standbywfi_o[NUM_CPUS-1: 0]),
    .standbywfe_o                  (standbywfe_o[NUM_CPUS-1: 0]),
    .gov_wfx_drain_req_o           (gov_wfx_drain_req_o[NUM_CPUS-1: 0]),
    .gov_wfx_wake_o                (gov_wfx_wake_o[NUM_CPUS-1: 0]),
    .clrexmonack_o                 (clrexmonack_o),
    .evento_o                      (evento_o),
    .gov_event_reg_o               (gov_event_reg_o[NUM_CPUS-1: 0]),
    .gov_smpen_o                   (gov_smpen[NUM_CPUS-1: 0]),
    .cpuqactive_o                  (cpuqactive_o[NUM_CPUS-1: 0]),
    .cpuqdeny_o                    (cpuqdeny_o[NUM_CPUS-1: 0]),
    .cpuqacceptn_o                 (cpuqacceptn_o[NUM_CPUS-1: 0]),
    .neonqactive_o                 (neonqactive_o[NUM_CPUS-1: 0]),
    .neonqdeny_o                   (neonqdeny_o[NUM_CPUS-1: 0]),
    .neonqacceptn_o                (neonqacceptn_o[NUM_CPUS-1: 0]),
    .l2qactive_o                   (l2qactive_o),
    .l2qdeny_o                     (l2qdeny_o),
    .l2qacceptn_o                  (l2qacceptn_o),
    .gov_l2_in_retention_o         (gov_l2_in_retention),
    .prdatadbg_o                   (prdatadbg_o[(`CA53_PRDATADBG_W-1): 0]),
    .preadydbg_o                   (preadydbg_o),
    .pslverrdbg_o                  (pslverrdbg_o),
    .gov_pseldbg_dbg_o             (gov_pseldbg_dbg_o[NUM_CPUS-1: 0]),
    .gov_pseldbg_pmu_o             (gov_pseldbg_pmu_o[NUM_CPUS-1: 0]),
    .gov_pseldbg_etm_o             (gov_pseldbg_etm_o[NUM_CPUS-1: 0]),
    .gov_paddrdbg_o                (gov_paddrdbg_o[(`CA53_PADDRDBG_PKDED_W-1):0]),
    .gov_paddrdbg31_o              (gov_paddrdbg31_o[NUM_CPUS-1: 0]),
    .gov_penabledbg_o              (gov_penabledbg_o[NUM_CPUS-1: 0]),
    .gov_pwritedbg_o               (gov_pwritedbg_o[NUM_CPUS-1: 0]),
    .gov_pwdatadbg_o               (gov_pwdatadbg_o[(`CA53_PWDATADBG_PKDED_W-1):0]),
    .gov_dbgromaddr_o              (gov_dbgromaddr_o[ 39:12]),
    .gov_dbgromaddrv_o             (gov_dbgromaddrv_o),
    .ncommirq_o                    (ncommirq_o[NUM_CPUS-1: 0]),
    .dbgack_o                      (dbgack_o[NUM_CPUS-1: 0]),
    .commrx_o                      (commrx_o[NUM_CPUS-1: 0]),
    .commtx_o                      (commtx_o[NUM_CPUS-1: 0]),
    .gov_edbgrq_o                  (gov_edbgrq_o[NUM_CPUS-1: 0]),
    .gov_dbgen_o                   (gov_dbgen_o[NUM_CPUS-1: 0]),
    .gov_niden_o                   (gov_niden_o[NUM_CPUS-1: 0]),
    .gov_spiden_o                  (gov_spiden_o[NUM_CPUS-1: 0]),
    .gov_spniden_o                 (gov_spniden_o[NUM_CPUS-1: 0]),
    .gov_dbgrestart_o              (gov_dbgrestart_o[NUM_CPUS-1: 0]),
    .gov_stall_dsb_o               (gov_stall_dsb_o[NUM_CPUS-1: 0]),
    .gov_cp_ack_o                  (gov_cp_ack_o[NUM_CPUS-1: 0]),
    .gov_cp_rdata_o                (gov_cp_rdata_o[(`CA53_CPDATA_PKDED_W-1):0]),
    .gov_pcnt_kernel_access_o      (gov_pcnt_kernel_access_o[NUM_CPUS-1: 0]),
    .gov_pcnt_usr_access_o         (gov_pcnt_usr_access_o[NUM_CPUS-1: 0]),
    .gov_vcnt_usr_access_o         (gov_vcnt_usr_access_o[NUM_CPUS-1: 0]),
    .gov_cntp_usr_access_o         (gov_cntp_usr_access_o[NUM_CPUS-1: 0]),
    .gov_cntv_usr_access_o         (gov_cntv_usr_access_o[NUM_CPUS-1: 0]),
    .gov_cntp_kernel_access_o      (gov_cntp_kernel_access_o[NUM_CPUS-1: 0]),
    .dbgrstreq_o                   (dbgrstreq_o[NUM_CPUS-1: 0]),
    .dbgnopwrdwn_o                 (dbgnopwrdwn_o[NUM_CPUS-1: 0]),
    .gov_dbgpwrupreq_o             (gov_dbgpwrupreq_o[NUM_CPUS-1: 0]),
    .dbgpwrupreq_o                 (dbgpwrupreq_o[NUM_CPUS-1: 0]),
    .gov_extin_o                   (gov_extin_o[(`CA53_ETMEXT_PKDED_W-1): 0]),
    .gov_edecr_osuce_o             (gov_edecr_osuce_o[NUM_CPUS-1: 0]),
    .gov_edecr_rce_o               (gov_edecr_rce_o[NUM_CPUS-1: 0]),
    .gov_edecr_ss_o                (gov_edecr_ss_o[NUM_CPUS-1: 0]),
    .gov_edlsr_slk_o               (gov_edlsr_slk_o[NUM_CPUS-1: 0]),
    .gov_pmlsr_slk_o               (gov_pmlsr_slk_o[NUM_CPUS-1: 0]),
    .gov_etmpdsr_rd_o              (gov_etmpdsr_rd_o[NUM_CPUS-1: 0]),
    .gov_atclken_o                 (gov_atclken_o[NUM_CPUS-1: 0]),
    .gov_atreadym_o                (gov_atreadym_o[(`CA53_ATREADYM_PKDED_W-1): 0]),
    .gov_afvalidm_o                (gov_afvalidm_o[(`CA53_AFVALIDM_PKDED_W-1): 0]),
    .atdatam_o                     (atdatam_o[(`CA53_ATDATAM_PKDED_W-1): 0]),
    .atvalidm_o                    (atvalidm_o[(`CA53_ATVALIDM_PKDED_W-1): 0]),
    .atbytesm_o                    (atbytesm_o[(`CA53_ATBYTESM_PKDED_W-1): 0]),
    .afreadym_o                    (afreadym_o[(`CA53_AFREADYM_PKDED_W-1): 0]),
    .atidm_o                       (atidm_o[(`CA53_ATIDM_PKDED_W-1): 0]),
    .gov_syncreqm_o                (gov_syncreqm_o[(`CA53_SYNCREQM_PKDED_W-1): 0]),
    .npmuirq_o                     (npmuirq_o[NUM_CPUS-1: 0]),
    .pmuevent_o                    (pmuevent_o[(`CA53_PMUEVNT_PKDED_W-1): 0]),
    .ctichout_o                    (ctichout_o[3:0]),
    .ctichinack_o                  (ctichinack_o[3:0]),
    .ctiirq_o                      (ctiirq_o[NUM_CPUS-1: 0]),
    .gov_enable_writeevict_o       (gov_enable_writeevict),
    .gov_disable_evict_o           (gov_disable_evict),
    .gov_l2victim_ctl_o            (gov_l2victim_ctl[1:0]),
    .gov_l2deien_o                 (gov_l2deien),
    .gov_l2teien_o                 (gov_l2teien),
    .gov_clear_axierr_o            (gov_clear_axierr),
    .gov_clear_eccerr_o            (gov_clear_eccerr),
    .gov_inv_all_req_o             (gov_inv_all_req[NUM_CPUS-1: 0]),
    .gov_dbgl1rstdisable_o         (gov_dbgl1rstdisable_o[NUM_CPUS-1: 0]),
    .gov_mbistreq_o                (gov_mbistreq),
    .gov_mbistreq_cpu_o            (gov_mbistreq_cpu_o[NUM_CPUS-1: 0]),
    .mbistack0_o                   (mbistack0_o),
    .mbistack1_o                   (mbistack1_o),
    .gov_mbistaddr0_o              (gov_mbistaddr0[(`CA53_MBIST0_ADDR_W-1): 0]),
    .gov_mbistaddr1_o              (gov_mbistaddr1[(`CA53_MBIST1_ADDR_W-1): 0]),
    .gov_mbistindata0_o            (gov_mbistindata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .gov_mbistindata1_o            (gov_mbistindata1[(`CA53_MBIST1_DATA_W-1): 0]),
    .mbistoutdata0_o               (mbistoutdata0_o[(`CA53_MBIST0_DATA_W-1): 0]),
    .mbistoutdata1_o               (mbistoutdata1_o[(`CA53_MBIST1_DATA_W-1): 0]),
    .gov_mbistwriteen0_o           (gov_mbistwriteen0),
    .gov_mbistwriteen1_o           (gov_mbistwriteen1),
    .gov_mbistreaden0_o            (gov_mbistreaden0),
    .gov_mbistreaden1_o            (gov_mbistreaden1),
    .gov_mbistarray0_o             (gov_mbistarray0[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .gov_mbistarray1_o             (gov_mbistarray1[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .gov_mbistbe0_o                (gov_mbistbe0[(`CA53_MBIST0_BE_W-1):0]),
    .gov_mbistbe1_o                (gov_mbistbe1[(`CA53_MBIST1_BE_W-1):0]),
    .gov_mbistcfg0_o               (gov_mbistcfg0),
    .gov_mbistcfg1_o               (gov_mbistcfg1)
  );  // u_ca53governor

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign gov_standbywfi_o = gov_standbywfi;
  assign gov_smpen_o      = gov_smpen;

  generate if (NUM_CPUS >= 1) begin : g_l2noram_pack_bus_cpu0
    assign scu_ar_credit_o[((`CA53_ARCREDIT_W       *1)-1):(`CA53_ARCREDIT_W    *0)] = scu_cpu0_ar_credit;
    assign scu_ar_block_o[((`CA53_ARBLOCK_W         *1)-1):(`CA53_ARBLOCK_W     *0)] = scu_cpu0_ar_block;
    assign scu_dr_valid_o[((`CA53_DRVALID_W         *1)-1):(`CA53_DRVALID_W     *0)] = scu_cpu0_dr_valid;
    assign scu_dr_id_o[((`CA53_DRID_W               *1)-1):(`CA53_DRID_W        *0)] = scu_cpu0_dr_id;
    assign scu_dr_resp_o[((`CA53_DRRESP_W           *1)-1):(`CA53_DRRESP_W      *0)] = scu_cpu0_dr_resp;
    assign scu_dr_chunk_o[((`CA53_DRCHUNK_W         *1)-1):(`CA53_DRCHUNK_W     *0)] = scu_cpu0_dr_chunk;
    assign scu_dr_data_o[((`CA53_DRDATA_W           *1)-1):(`CA53_DRDATA_W      *0)] = scu_cpu0_dr_data;
    assign scu_rr_valid_o[((`CA53_RRVALID_W         *1)-1):(`CA53_RRVALID_W     *0)] = scu_cpu0_rr_valid;
    assign scu_rr_id_o[((`CA53_RRID_W               *1)-1):(`CA53_RRID_W        *0)] = scu_cpu0_rr_id;
    assign scu_rr_resp_o[((`CA53_RRRESP_W           *1)-1):(`CA53_RRRESP_W      *0)] = scu_cpu0_rr_resp;
    assign scu_rr_l2db_id_o[((`CA53_RRL2DB_W        *1)-1):(`CA53_RRL2DB_W      *0)] = scu_cpu0_rr_l2db_id;
    assign scu_ev_done_o[((`CA53_EVDONE_W           *1)-1):(`CA53_EVDONE_W      *0)] = scu_cpu0_ev_done;
    assign scu_db_excl_valid_o[((`CA53_DBEXCLVAL_W  *1)-1):(`CA53_DBEXCLVAL_W   *0)] = scu_cpu0_db_excl_valid;
    assign scu_db_excl_resp_o[((`CA53_DBEXCLRSP_W   *1)-1):(`CA53_DBEXCLRSP_W   *0)] = scu_cpu0_db_excl_resp;
    assign scu_db_decerr_o[((`CA53_DBDECERR_W       *1)-1):(`CA53_DBDECERR_W    *0)] = scu_cpu0_db_decerr;
    assign scu_db_slverr_o[((`CA53_DBSLVERR_W       *1)-1):(`CA53_DBSLVERR_W    *0)] = scu_cpu0_db_slverr;
    assign scu_leave_ramode_o[((`CA53_LEAVERAM_W    *1)-1):(`CA53_LEAVERAM_W    *0)] = scu_cpu0_leave_ramode;
    assign scu_ac_valid_o[((`CA53_ACVALID_W         *1)-1):(`CA53_ACVALID_W     *0)] = scu_cpu0_ac_valid;
    assign scu_ac_id_o[((`CA53_ACID_W               *1)-1):(`CA53_ACID_W        *0)] = scu_cpu0_ac_id;
    assign scu_ac_l2db_id_o[((`CA53_ACL2DB_W        *1)-1):(`CA53_ACL2DB_W      *0)] = scu_cpu0_ac_l2db_id;
    assign scu_ac_snoop_o[((`CA53_ACSNOOP_W         *1)-1):(`CA53_ACSNOOP_W     *0)] = scu_cpu0_ac_snoop;
    assign scu_ac_addr_o[((`CA53_ACADDR_W           *1)-1):(`CA53_ACADDR_W      *0)] = scu_cpu0_ac_addr;
    assign scu_ac_way_o[((`CA53_ACWAY_W             *1)-1):(`CA53_ACWAY_W       *0)] = scu_cpu0_ac_way;
    assign scu_dvm_complete_o[((`CA53_DVM_COMP_W    *1)-1):(`CA53_DVM_COMP_W    *0)] = scu_cpu0_dvm_complete;
    assign scu_reqbufs_busy_o[((`CA53_REQBUFS_BUSY_W*1)-1):(`CA53_REQBUFS_BUSY_W*0)] = scu_cpu0_reqbufs_busy;
    assign scu_drain_stb_o[((`CA53_DRAIN_STB_W      *1)-1):(`CA53_DRAIN_STB_W   *0)] = scu_cpu0_drain_stb;
    assign scu_broadcastinner_o[0]                                                   = scu_cpu0_broadcastinner;
    assign scu_evnt_l2_access_o[0]                                                   = scu_cpu0_evnt_l2_access;
    assign scu_evnt_l2_refill_o[0]                                                   = scu_cpu0_evnt_l2_refill;
    assign scu_evnt_l2_wb_o[0]                                                       = scu_cpu0_evnt_l2_wb;
    assign scu_evnt_snooped_data_o[0]                                                = scu_cpu0_evnt_snooped_data;
    assign scu_evnt_bus_cycle_o[0]                                                   = scu_cpu0_evnt_bus_cycle;
    assign scu_evnt_bus_acc_rd_o[0]                                                  = scu_cpu0_evnt_bus_acc_rd;
    assign scu_evnt_bus_acc_wr_o[0]                                                  = scu_cpu0_evnt_bus_acc_wr;
    assign scu_inv_all_ack[0]                                                        = scu_cpu0_inv_all_ack;
    assign scu_evnt_eviction_o[0]                                                    = scu_cpu0_evnt_eviction;
  end endgenerate

  generate if (NUM_CPUS >= 2) begin : g_l2noram_pack_bus_cpu1
    assign scu_ar_credit_o[((`CA53_ARCREDIT_W       *2)-1):(`CA53_ARCREDIT_W    *1)] = scu_cpu1_ar_credit;
    assign scu_ar_block_o[((`CA53_ARBLOCK_W         *2)-1):(`CA53_ARBLOCK_W     *1)] = scu_cpu1_ar_block;
    assign scu_dr_valid_o[((`CA53_DRVALID_W         *2)-1):(`CA53_DRVALID_W     *1)] = scu_cpu1_dr_valid;
    assign scu_dr_id_o[((`CA53_DRID_W               *2)-1):(`CA53_DRID_W        *1)] = scu_cpu1_dr_id;
    assign scu_dr_resp_o[((`CA53_DRRESP_W           *2)-1):(`CA53_DRRESP_W      *1)] = scu_cpu1_dr_resp;
    assign scu_dr_chunk_o[((`CA53_DRCHUNK_W         *2)-1):(`CA53_DRCHUNK_W     *1)] = scu_cpu1_dr_chunk;
    assign scu_dr_data_o[((`CA53_DRDATA_W           *2)-1):(`CA53_DRDATA_W      *1)] = scu_cpu1_dr_data;
    assign scu_rr_valid_o[((`CA53_RRVALID_W         *2)-1):(`CA53_RRVALID_W     *1)] = scu_cpu1_rr_valid;
    assign scu_rr_id_o[((`CA53_RRID_W               *2)-1):(`CA53_RRID_W        *1)] = scu_cpu1_rr_id;
    assign scu_rr_resp_o[((`CA53_RRRESP_W           *2)-1):(`CA53_RRRESP_W      *1)] = scu_cpu1_rr_resp;
    assign scu_rr_l2db_id_o[((`CA53_RRL2DB_W        *2)-1):(`CA53_RRL2DB_W      *1)] = scu_cpu1_rr_l2db_id;
    assign scu_ev_done_o[((`CA53_EVDONE_W           *2)-1):(`CA53_EVDONE_W      *1)] = scu_cpu1_ev_done;
    assign scu_db_excl_valid_o[((`CA53_DBEXCLVAL_W  *2)-1):(`CA53_DBEXCLVAL_W   *1)] = scu_cpu1_db_excl_valid;
    assign scu_db_excl_resp_o[((`CA53_DBEXCLRSP_W   *2)-1):(`CA53_DBEXCLRSP_W   *1)] = scu_cpu1_db_excl_resp;
    assign scu_db_decerr_o[((`CA53_DBDECERR_W       *2)-1):(`CA53_DBDECERR_W    *1)] = scu_cpu1_db_decerr;
    assign scu_db_slverr_o[((`CA53_DBSLVERR_W       *2)-1):(`CA53_DBSLVERR_W    *1)] = scu_cpu1_db_slverr;
    assign scu_leave_ramode_o[((`CA53_LEAVERAM_W    *2)-1):(`CA53_LEAVERAM_W    *1)] = scu_cpu1_leave_ramode;
    assign scu_ac_valid_o[((`CA53_ACVALID_W         *2)-1):(`CA53_ACVALID_W     *1)] = scu_cpu1_ac_valid;
    assign scu_ac_id_o[((`CA53_ACID_W               *2)-1):(`CA53_ACID_W        *1)] = scu_cpu1_ac_id;
    assign scu_ac_l2db_id_o[((`CA53_ACL2DB_W        *2)-1):(`CA53_ACL2DB_W      *1)] = scu_cpu1_ac_l2db_id;
    assign scu_ac_snoop_o[((`CA53_ACSNOOP_W         *2)-1):(`CA53_ACSNOOP_W     *1)] = scu_cpu1_ac_snoop;
    assign scu_ac_addr_o[((`CA53_ACADDR_W           *2)-1):(`CA53_ACADDR_W      *1)] = scu_cpu1_ac_addr;
    assign scu_ac_way_o[((`CA53_ACWAY_W             *2)-1):(`CA53_ACWAY_W       *1)] = scu_cpu1_ac_way;
    assign scu_dvm_complete_o[((`CA53_DVM_COMP_W    *2)-1):(`CA53_DVM_COMP_W    *1)] = scu_cpu1_dvm_complete;
    assign scu_reqbufs_busy_o[((`CA53_REQBUFS_BUSY_W*2)-1):(`CA53_REQBUFS_BUSY_W*1)] = scu_cpu1_reqbufs_busy;
    assign scu_drain_stb_o[((`CA53_DRAIN_STB_W      *2)-1):(`CA53_DRAIN_STB_W   *1)] = scu_cpu1_drain_stb;
    assign scu_broadcastinner_o[1]                                                   = scu_cpu1_broadcastinner;
    assign scu_evnt_l2_access_o[1]                                                   = scu_cpu1_evnt_l2_access;
    assign scu_evnt_l2_refill_o[1]                                                   = scu_cpu1_evnt_l2_refill;
    assign scu_evnt_l2_wb_o[1]                                                       = scu_cpu1_evnt_l2_wb;
    assign scu_evnt_snooped_data_o[1]                                                = scu_cpu1_evnt_snooped_data;
    assign scu_evnt_bus_cycle_o[1]                                                   = scu_cpu1_evnt_bus_cycle;
    assign scu_evnt_bus_acc_rd_o[1]                                                  = scu_cpu1_evnt_bus_acc_rd;
    assign scu_evnt_bus_acc_wr_o[1]                                                  = scu_cpu1_evnt_bus_acc_wr;
    assign scu_inv_all_ack[1]                                                        = scu_cpu1_inv_all_ack;
    assign scu_evnt_eviction_o[1]                                                    = scu_cpu1_evnt_eviction;
  end endgenerate

  generate if (NUM_CPUS >= 3) begin : g_l2noram_pack_bus_cpu2
    assign scu_ar_credit_o[((`CA53_ARCREDIT_W       *3)-1):(`CA53_ARCREDIT_W    *2)] = scu_cpu2_ar_credit;
    assign scu_ar_block_o[((`CA53_ARBLOCK_W         *3)-1):(`CA53_ARBLOCK_W     *2)] = scu_cpu2_ar_block;
    assign scu_dr_valid_o[((`CA53_DRVALID_W         *3)-1):(`CA53_DRVALID_W     *2)] = scu_cpu2_dr_valid;
    assign scu_dr_id_o[((`CA53_DRID_W               *3)-1):(`CA53_DRID_W        *2)] = scu_cpu2_dr_id;
    assign scu_dr_resp_o[((`CA53_DRRESP_W           *3)-1):(`CA53_DRRESP_W      *2)] = scu_cpu2_dr_resp;
    assign scu_dr_chunk_o[((`CA53_DRCHUNK_W         *3)-1):(`CA53_DRCHUNK_W     *2)] = scu_cpu2_dr_chunk;
    assign scu_dr_data_o[((`CA53_DRDATA_W           *3)-1):(`CA53_DRDATA_W      *2)] = scu_cpu2_dr_data;
    assign scu_rr_valid_o[((`CA53_RRVALID_W         *3)-1):(`CA53_RRVALID_W     *2)] = scu_cpu2_rr_valid;
    assign scu_rr_id_o[((`CA53_RRID_W               *3)-1):(`CA53_RRID_W        *2)] = scu_cpu2_rr_id;
    assign scu_rr_resp_o[((`CA53_RRRESP_W           *3)-1):(`CA53_RRRESP_W      *2)] = scu_cpu2_rr_resp;
    assign scu_rr_l2db_id_o[((`CA53_RRL2DB_W        *3)-1):(`CA53_RRL2DB_W      *2)] = scu_cpu2_rr_l2db_id;
    assign scu_ev_done_o[((`CA53_EVDONE_W           *3)-1):(`CA53_EVDONE_W      *2)] = scu_cpu2_ev_done;
    assign scu_db_excl_valid_o[((`CA53_DBEXCLVAL_W  *3)-1):(`CA53_DBEXCLVAL_W   *2)] = scu_cpu2_db_excl_valid;
    assign scu_db_excl_resp_o[((`CA53_DBEXCLRSP_W   *3)-1):(`CA53_DBEXCLRSP_W   *2)] = scu_cpu2_db_excl_resp;
    assign scu_db_decerr_o[((`CA53_DBDECERR_W       *3)-1):(`CA53_DBDECERR_W    *2)] = scu_cpu2_db_decerr;
    assign scu_db_slverr_o[((`CA53_DBSLVERR_W       *3)-1):(`CA53_DBSLVERR_W    *2)] = scu_cpu2_db_slverr;
    assign scu_leave_ramode_o[((`CA53_LEAVERAM_W    *3)-1):(`CA53_LEAVERAM_W    *2)] = scu_cpu2_leave_ramode;
    assign scu_ac_valid_o[((`CA53_ACVALID_W         *3)-1):(`CA53_ACVALID_W     *2)] = scu_cpu2_ac_valid;
    assign scu_ac_id_o[((`CA53_ACID_W               *3)-1):(`CA53_ACID_W        *2)] = scu_cpu2_ac_id;
    assign scu_ac_l2db_id_o[((`CA53_ACL2DB_W        *3)-1):(`CA53_ACL2DB_W      *2)] = scu_cpu2_ac_l2db_id;
    assign scu_ac_snoop_o[((`CA53_ACSNOOP_W         *3)-1):(`CA53_ACSNOOP_W     *2)] = scu_cpu2_ac_snoop;
    assign scu_ac_addr_o[((`CA53_ACADDR_W           *3)-1):(`CA53_ACADDR_W      *2)] = scu_cpu2_ac_addr;
    assign scu_ac_way_o[((`CA53_ACWAY_W             *3)-1):(`CA53_ACWAY_W       *2)] = scu_cpu2_ac_way;
    assign scu_dvm_complete_o[((`CA53_DVM_COMP_W    *3)-1):(`CA53_DVM_COMP_W    *2)] = scu_cpu2_dvm_complete;
    assign scu_reqbufs_busy_o[((`CA53_REQBUFS_BUSY_W*3)-1):(`CA53_REQBUFS_BUSY_W*2)] = scu_cpu2_reqbufs_busy;
    assign scu_drain_stb_o[((`CA53_DRAIN_STB_W      *3)-1):(`CA53_DRAIN_STB_W   *2)] = scu_cpu2_drain_stb;
    assign scu_broadcastinner_o[2]                                                   = scu_cpu2_broadcastinner;
    assign scu_evnt_l2_access_o[2]                                                   = scu_cpu2_evnt_l2_access;
    assign scu_evnt_l2_refill_o[2]                                                   = scu_cpu2_evnt_l2_refill;
    assign scu_evnt_l2_wb_o[2]                                                       = scu_cpu2_evnt_l2_wb;
    assign scu_evnt_snooped_data_o[2]                                                = scu_cpu2_evnt_snooped_data;
    assign scu_evnt_bus_cycle_o[2]                                                   = scu_cpu2_evnt_bus_cycle;
    assign scu_evnt_bus_acc_rd_o[2]                                                  = scu_cpu2_evnt_bus_acc_rd;
    assign scu_evnt_bus_acc_wr_o[2]                                                  = scu_cpu2_evnt_bus_acc_wr;
    assign scu_inv_all_ack[2]                                                        = scu_cpu2_inv_all_ack;
    assign scu_evnt_eviction_o[2]                                                    = scu_cpu2_evnt_eviction;
  end endgenerate

  generate if (NUM_CPUS >= 4) begin : g_l2noram_pack_bus_cpu3
    assign scu_ar_credit_o[((`CA53_ARCREDIT_W       *4)-1):(`CA53_ARCREDIT_W    *3)] = scu_cpu3_ar_credit;
    assign scu_ar_block_o[((`CA53_ARBLOCK_W         *4)-1):(`CA53_ARBLOCK_W     *3)] = scu_cpu3_ar_block;
    assign scu_dr_valid_o[((`CA53_DRVALID_W         *4)-1):(`CA53_DRVALID_W     *3)] = scu_cpu3_dr_valid;
    assign scu_dr_id_o[((`CA53_DRID_W               *4)-1):(`CA53_DRID_W        *3)] = scu_cpu3_dr_id;
    assign scu_dr_resp_o[((`CA53_DRRESP_W           *4)-1):(`CA53_DRRESP_W      *3)] = scu_cpu3_dr_resp;
    assign scu_dr_chunk_o[((`CA53_DRCHUNK_W         *4)-1):(`CA53_DRCHUNK_W     *3)] = scu_cpu3_dr_chunk;
    assign scu_dr_data_o[((`CA53_DRDATA_W           *4)-1):(`CA53_DRDATA_W      *3)] = scu_cpu3_dr_data;
    assign scu_rr_valid_o[((`CA53_RRVALID_W         *4)-1):(`CA53_RRVALID_W     *3)] = scu_cpu3_rr_valid;
    assign scu_rr_id_o[((`CA53_RRID_W               *4)-1):(`CA53_RRID_W        *3)] = scu_cpu3_rr_id;
    assign scu_rr_resp_o[((`CA53_RRRESP_W           *4)-1):(`CA53_RRRESP_W      *3)] = scu_cpu3_rr_resp;
    assign scu_rr_l2db_id_o[((`CA53_RRL2DB_W        *4)-1):(`CA53_RRL2DB_W      *3)] = scu_cpu3_rr_l2db_id;
    assign scu_ev_done_o[((`CA53_EVDONE_W           *4)-1):(`CA53_EVDONE_W      *3)] = scu_cpu3_ev_done;
    assign scu_db_excl_valid_o[((`CA53_DBEXCLVAL_W  *4)-1):(`CA53_DBEXCLVAL_W   *3)] = scu_cpu3_db_excl_valid;
    assign scu_db_excl_resp_o[((`CA53_DBEXCLRSP_W   *4)-1):(`CA53_DBEXCLRSP_W   *3)] = scu_cpu3_db_excl_resp;
    assign scu_db_decerr_o[((`CA53_DBDECERR_W       *4)-1):(`CA53_DBDECERR_W    *3)] = scu_cpu3_db_decerr;
    assign scu_db_slverr_o[((`CA53_DBSLVERR_W       *4)-1):(`CA53_DBSLVERR_W    *3)] = scu_cpu3_db_slverr;
    assign scu_leave_ramode_o[((`CA53_LEAVERAM_W    *4)-1):(`CA53_LEAVERAM_W    *3)] = scu_cpu3_leave_ramode;
    assign scu_ac_valid_o[((`CA53_ACVALID_W         *4)-1):(`CA53_ACVALID_W     *3)] = scu_cpu3_ac_valid;
    assign scu_ac_id_o[((`CA53_ACID_W               *4)-1):(`CA53_ACID_W        *3)] = scu_cpu3_ac_id;
    assign scu_ac_l2db_id_o[((`CA53_ACL2DB_W        *4)-1):(`CA53_ACL2DB_W      *3)] = scu_cpu3_ac_l2db_id;
    assign scu_ac_snoop_o[((`CA53_ACSNOOP_W         *4)-1):(`CA53_ACSNOOP_W     *3)] = scu_cpu3_ac_snoop;
    assign scu_ac_addr_o[((`CA53_ACADDR_W           *4)-1):(`CA53_ACADDR_W      *3)] = scu_cpu3_ac_addr;
    assign scu_ac_way_o[((`CA53_ACWAY_W             *4)-1):(`CA53_ACWAY_W       *3)] = scu_cpu3_ac_way;
    assign scu_dvm_complete_o[((`CA53_DVM_COMP_W    *4)-1):(`CA53_DVM_COMP_W    *3)] = scu_cpu3_dvm_complete;
    assign scu_reqbufs_busy_o[((`CA53_REQBUFS_BUSY_W*4)-1):(`CA53_REQBUFS_BUSY_W*3)] = scu_cpu3_reqbufs_busy;
    assign scu_drain_stb_o[((`CA53_DRAIN_STB_W      *4)-1):(`CA53_DRAIN_STB_W   *3)] = scu_cpu3_drain_stb;
    assign scu_broadcastinner_o[3]                                                   = scu_cpu3_broadcastinner;
    assign scu_evnt_l2_access_o[3]                                                   = scu_cpu3_evnt_l2_access;
    assign scu_evnt_l2_refill_o[3]                                                   = scu_cpu3_evnt_l2_refill;
    assign scu_evnt_l2_wb_o[3]                                                       = scu_cpu3_evnt_l2_wb;
    assign scu_evnt_snooped_data_o[3]                                                = scu_cpu3_evnt_snooped_data;
    assign scu_evnt_bus_cycle_o[3]                                                   = scu_cpu3_evnt_bus_cycle;
    assign scu_evnt_bus_acc_rd_o[3]                                                  = scu_cpu3_evnt_bus_acc_rd;
    assign scu_evnt_bus_acc_wr_o[3]                                                  = scu_cpu3_evnt_bus_acc_wr;
    assign scu_inv_all_ack[3]                                                        = scu_cpu3_inv_all_ack;
    assign scu_evnt_eviction_o[3]                                                    = scu_cpu3_evnt_eviction;
  end endgenerate


  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Instantiate block interface checker modules. These are
  // automatically generated from the machine readable block
  // interface specifications

  ca53_scu_rams `CA53_SCU_RAMS_PARAM_INST u_ca53_scu_rams (
    /*ARMAUTO*/
    .clk                          (CLKIN),
    .reset_n                      (nl2reset),
    // Inputs
    .l1_dc_size_i                     (l1_dc_size_i[`CA53_L1DC_SIZE_W-1:0]),
    .l1d_tagram_cpu0_way0_rdata_i     (l1d_tagram_cpu0_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way1_rdata_i     (l1d_tagram_cpu0_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way2_rdata_i     (l1d_tagram_cpu0_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way3_rdata_i     (l1d_tagram_cpu0_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way0_rdata_i     (l1d_tagram_cpu1_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way1_rdata_i     (l1d_tagram_cpu1_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way2_rdata_i     (l1d_tagram_cpu1_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way3_rdata_i     (l1d_tagram_cpu1_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way0_rdata_i     (l1d_tagram_cpu2_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way1_rdata_i     (l1d_tagram_cpu2_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way2_rdata_i     (l1d_tagram_cpu2_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way3_rdata_i     (l1d_tagram_cpu2_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way0_rdata_i     (l1d_tagram_cpu3_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way1_rdata_i     (l1d_tagram_cpu3_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way2_rdata_i     (l1d_tagram_cpu3_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way3_rdata_i     (l1d_tagram_cpu3_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_size_i                        (l2_size_i[`CA53_L2_SIZE_W-1:0]),
    .l2_tagram_way0_rdata_i           (l2_tagram_way0_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way1_rdata_i           (l2_tagram_way1_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way2_rdata_i           (l2_tagram_way2_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way3_rdata_i           (l2_tagram_way3_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way4_rdata_i           (l2_tagram_way4_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way5_rdata_i           (l2_tagram_way5_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way6_rdata_i           (l2_tagram_way6_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way7_rdata_i           (l2_tagram_way7_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way8_rdata_i           (l2_tagram_way8_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way9_rdata_i           (l2_tagram_way9_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way10_rdata_i          (l2_tagram_way10_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way11_rdata_i          (l2_tagram_way11_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way12_rdata_i          (l2_tagram_way12_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way13_rdata_i          (l2_tagram_way13_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way14_rdata_i          (l2_tagram_way14_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way15_rdata_i          (l2_tagram_way15_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_victimram_rdata_i             (l2_victimram_rdata_i[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .l2_dataram_rdata0_i              (l2_dataram_rdata0_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata1_i              (l2_dataram_rdata1_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata2_i              (l2_dataram_rdata2_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata3_i              (l2_dataram_rdata3_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata4_i              (l2_dataram_rdata4_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata5_i              (l2_dataram_rdata5_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata6_i              (l2_dataram_rdata6_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata7_i              (l2_dataram_rdata7_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .gov_l2_in_retention_i            (gov_l2_in_retention),
    .l1d_tagram_clken_i               (l1d_tagram_clken_o),
    .l1d_tagram_cpu0_en_i             (l1d_tagram_cpu0_en_o[3:0]),
    .l1d_tagram_cpu1_en_i             (l1d_tagram_cpu1_en_o[3:0]),
    .l1d_tagram_cpu2_en_i             (l1d_tagram_cpu2_en_o[3:0]),
    .l1d_tagram_cpu3_en_i             (l1d_tagram_cpu3_en_o[3:0]),
    .l1d_tagram_cpu0_wr_i             (l1d_tagram_cpu0_wr_o),
    .l1d_tagram_cpu1_wr_i             (l1d_tagram_cpu1_wr_o),
    .l1d_tagram_cpu2_wr_i             (l1d_tagram_cpu2_wr_o),
    .l1d_tagram_cpu3_wr_i             (l1d_tagram_cpu3_wr_o),
    .l1d_tagram_cpu0_addr_i           (l1d_tagram_cpu0_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu1_addr_i           (l1d_tagram_cpu1_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu2_addr_i           (l1d_tagram_cpu2_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu3_addr_i           (l1d_tagram_cpu3_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu0_wdata_i          (l1d_tagram_cpu0_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_wdata_i          (l1d_tagram_cpu1_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_wdata_i          (l1d_tagram_cpu2_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_wdata_i          (l1d_tagram_cpu3_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_tagram_clken_i                (l2_tagram_clken_o),
    .l2_tagram_en_i                   (l2_tagram_en_o[15:0]),
    .l2_tagram_wr_i                   (l2_tagram_wr_o),
    .l2_tagram_addr_i                 (l2_tagram_addr_o[`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]),
    .l2_tagram_wdata_i                (l2_tagram_wdata_o[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_victimram_clken_i             (l2_victimram_clken_o),
    .l2_victimram_en_i                (l2_victimram_en_o),
    .l2_victimram_no_acc_next_cycle_i (l2_victimram_no_acc_next_cycle_o),
    .l2_victimram_wr_i                (l2_victimram_wr_o),
    .l2_victimram_strb_i              (l2_victimram_strb_o[`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0]),
    .l2_victimram_addr_i              (l2_victimram_addr_o[`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0]),
    .l2_victimram_wdata_i             (l2_victimram_wdata_o[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .l2_dataram_clken_i               (l2_dataram_clken_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_no_acc_next_cycle_i   (l2_dataram_no_acc_next_cycle_o),
    .l2_dataram_en_i                  (l2_dataram_en_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_wr_i                  (l2_dataram_wr_o),
    .l2_dataram_addr_i                (l2_dataram_addr_o[`CA53_SCU_L2_DATARAM_ADDR_W-1:0]),
    .l2_dataram_wdata0_i              (l2_dataram_wdata0_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata1_i              (l2_dataram_wdata1_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata2_i              (l2_dataram_wdata2_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata3_i              (l2_dataram_wdata3_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata4_i              (l2_dataram_wdata4_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata5_i              (l2_dataram_wdata5_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata6_i              (l2_dataram_wdata6_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata7_i              (l2_dataram_wdata7_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0])
  );  // u_ca53_scu_rams


  ca53_scu_ext u_ca53_scu_ext (
    /*ARMAUTO*/
    .clk                   (CLKIN),
    .reset_n               (nl2reset),
    // Inputs
    .l2rstdisable_i        (l2rstdisable_i),
    .broadcastinner_i      (broadcastinner_i),
    .broadcastouter_i      (broadcastouter_i),
    .broadcastcachemaint_i (broadcastcachemaint_i),
    .sysbardisable_i       (sysbardisable_i),
    .acinactm_i            (acinactm_i),
    .scu_ext_aclken_i      (scu_ext_aclken),
    .ext_sclken_i          (ext_sclken),
    .ext_sinact_i          (ext_sinact),
    .l2flushreq_i          (l2flushreq_i),
    .scu_ext_ar_ready_i    (scu_ext_ar_ready),
    .scu_ext_dr_valid_i    (scu_ext_dr_valid),
    .scu_ext_dr_id_i       (scu_ext_dr_id[5:0]),
    .scu_ext_dr_resp_i     (scu_ext_dr_resp[3:0]),
    .scu_ext_dr_data_i     (scu_ext_dr_data[127:0]),
    .scu_ext_dr_last_i     (scu_ext_dr_last),
    .scu_ext_aw_ready_i    (scu_ext_aw_ready),
    .scu_ext_dw_ready_i    (scu_ext_dw_ready),
    .scu_ext_db_valid_i    (scu_ext_db_valid),
    .scu_ext_db_id_i       (scu_ext_db_id[4:0]),
    .scu_ext_db_resp_i     (scu_ext_db_resp[1:0]),
    .scu_ext_ac_valid_i    (scu_ext_ac_valid),
    .scu_ext_ac_snoop_i    (scu_ext_ac_snoop[3:0]),
    .scu_ext_ac_addr_i     (scu_ext_ac_addr[43:0]),
    .scu_ext_ac_prot_i     (scu_ext_ac_prot[2:0]),
    .scu_ext_cr_ready_i    (scu_ext_cr_ready),
    .scu_ext_cd_ready_i    (scu_ext_cd_ready),
    .ext_rxsactive_i       (ext_rxsactive),
    .ext_rxlinkactivereq_i (ext_rxlinkactivereq),
    .ext_txlinkactiveack_i (ext_txlinkactiveack),
    .ext_txreqlcrdv_i      (ext_txreqlcrdv),
    .ext_txrsplcrdv_i      (ext_txrsplcrdv),
    .ext_txdatlcrdv_i      (ext_txdatlcrdv),
    .ext_rxsnpflitpend_i   (ext_rxsnpflitpend),
    .ext_rxsnpflitv_i      (ext_rxsnpflitv),
    .ext_rxsnpflit_i       (ext_rxsnpflit[64:0]),
    .ext_rxrspflitpend_i   (ext_rxrspflitpend),
    .ext_rxrspflitv_i      (ext_rxrspflitv),
    .ext_rxrspflit_i       (ext_rxrspflit[44:0]),
    .ext_rxdatflitpend_i   (ext_rxdatflitpend),
    .ext_rxdatflitv_i      (ext_rxdatflitv),
    .ext_rxdatflit_i       (ext_rxdatflit[193:0]),
    .ext_samaddrmap0_i     (ext_samaddrmap0[1:0]),
    .ext_samaddrmap1_i     (ext_samaddrmap1[1:0]),
    .ext_samaddrmap2_i     (ext_samaddrmap2[1:0]),
    .ext_samaddrmap3_i     (ext_samaddrmap3[1:0]),
    .ext_samaddrmap4_i     (ext_samaddrmap4[1:0]),
    .ext_samaddrmap5_i     (ext_samaddrmap5[1:0]),
    .ext_samaddrmap6_i     (ext_samaddrmap6[1:0]),
    .ext_samaddrmap7_i     (ext_samaddrmap7[1:0]),
    .ext_samaddrmap8_i     (ext_samaddrmap8[1:0]),
    .ext_samaddrmap9_i     (ext_samaddrmap9[1:0]),
    .ext_samaddrmap10_i    (ext_samaddrmap10[1:0]),
    .ext_samaddrmap11_i    (ext_samaddrmap11[1:0]),
    .ext_samaddrmap12_i    (ext_samaddrmap12[1:0]),
    .ext_samaddrmap13_i    (ext_samaddrmap13[1:0]),
    .ext_samaddrmap14_i    (ext_samaddrmap14[1:0]),
    .ext_samaddrmap15_i    (ext_samaddrmap15[1:0]),
    .ext_sammnbase_i       (ext_sammnbase[39:24]),
    .ext_sammnnodeid_i     (ext_sammnnodeid[6:0]),
    .ext_samhni0nodeid_i   (ext_samhni0nodeid[6:0]),
    .ext_samhni1nodeid_i   (ext_samhni1nodeid[6:0]),
    .ext_samhnf0nodeid_i   (ext_samhnf0nodeid[6:0]),
    .ext_samhnf1nodeid_i   (ext_samhnf1nodeid[6:0]),
    .ext_samhnf2nodeid_i   (ext_samhnf2nodeid[6:0]),
    .ext_samhnf3nodeid_i   (ext_samhnf3nodeid[6:0]),
    .ext_samhnf4nodeid_i   (ext_samhnf4nodeid[6:0]),
    .ext_samhnf5nodeid_i   (ext_samhnf5nodeid[6:0]),
    .ext_samhnf6nodeid_i   (ext_samhnf6nodeid[6:0]),
    .ext_samhnf7nodeid_i   (ext_samhnf7nodeid[6:0]),
    .ext_samhnfmode_i      (ext_samhnfmode[2:0]),
    .ext_nodeid_i          (ext_nodeid[6:0]),
    .ext_acp_aclken_i      (ext_acp_aclken),
    .ext_acp_ainact_i      (ext_acp_ainact),
    .ext_acp_awvalid_i     (ext_acp_awvalid),
    .ext_acp_awid_i        (ext_acp_awid[4:0]),
    .ext_acp_awaddr_i      (ext_acp_awaddr[39:0]),
    .ext_acp_awlen_i       (ext_acp_awlen[7:0]),
    .ext_acp_awcache_i     (ext_acp_awcache[3:0]),
    .ext_acp_awuser_i      (ext_acp_awuser[1:0]),
    .ext_acp_awprot_i      (ext_acp_awprot[2:0]),
    .ext_acp_wvalid_i      (ext_acp_wvalid),
    .ext_acp_wdata_i       (ext_acp_wdata[127:0]),
    .ext_acp_wstrb_i       (ext_acp_wstrb[15:0]),
    .ext_acp_wlast_i       (ext_acp_wlast),
    .ext_acp_bready_i      (ext_acp_bready),
    .ext_acp_arvalid_i     (ext_acp_arvalid),
    .ext_acp_arid_i        (ext_acp_arid[4:0]),
    .ext_acp_araddr_i      (ext_acp_araddr[39:0]),
    .ext_acp_arlen_i       (ext_acp_arlen[7:0]),
    .ext_acp_arcache_i     (ext_acp_arcache[3:0]),
    .ext_acp_aruser_i      (ext_acp_aruser[1:0]),
    .ext_acp_arprot_i      (ext_acp_arprot[2:0]),
    .ext_acp_rready_i      (ext_acp_rready),
    .nexterrirq_i          (nexterrirq_o),
    .ninterrirq_i          (ninterrirq_o),
    .standbywfil2_i        (standbywfil2_o),
    .l2flushdone_i         (l2flushdone_o),
    .scu_ext_ar_valid_i    (scu_ext_ar_valid_o),
    .scu_ext_ar_id_i       (scu_ext_ar_id_o[5:0]),
    .scu_ext_ar_addr_i     (scu_ext_ar_addr_o[43:0]),
    .scu_ext_ar_len_i      (scu_ext_ar_len_o[7:0]),
    .scu_ext_ar_size_i     (scu_ext_ar_size_o[2:0]),
    .scu_ext_ar_burst_i    (scu_ext_ar_burst_o[1:0]),
    .scu_ext_ar_lock_i     (scu_ext_ar_lock_o),
    .scu_ext_ar_cache_i    (scu_ext_ar_cache_o[3:0]),
    .scu_ext_ar_prot_i     (scu_ext_ar_prot_o[2:0]),
    .scu_ext_ar_snoop_i    (scu_ext_ar_snoop_o[3:0]),
    .scu_ext_ar_domain_i   (scu_ext_ar_domain_o[1:0]),
    .scu_ext_ar_bar_i      (scu_ext_ar_bar_o[1:0]),
    .scu_ext_rdmemattr_i   (scu_ext_rdmemattr_o[7:0]),
    .scu_ext_dr_ready_i    (scu_ext_dr_ready_o),
    .scu_ext_aw_valid_i    (scu_ext_aw_valid_o),
    .scu_ext_aw_id_i       (scu_ext_aw_id_o[4:0]),
    .scu_ext_aw_addr_i     (scu_ext_aw_addr_o[43:0]),
    .scu_ext_aw_len_i      (scu_ext_aw_len_o[7:0]),
    .scu_ext_aw_size_i     (scu_ext_aw_size_o[2:0]),
    .scu_ext_aw_burst_i    (scu_ext_aw_burst_o[1:0]),
    .scu_ext_aw_lock_i     (scu_ext_aw_lock_o),
    .scu_ext_aw_cache_i    (scu_ext_aw_cache_o[3:0]),
    .scu_ext_aw_prot_i     (scu_ext_aw_prot_o[2:0]),
    .scu_ext_aw_snoop_i    (scu_ext_aw_snoop_o[2:0]),
    .scu_ext_aw_domain_i   (scu_ext_aw_domain_o[1:0]),
    .scu_ext_aw_bar_i      (scu_ext_aw_bar_o[1:0]),
    .scu_ext_aw_unique_i   (scu_ext_aw_unique_o),
    .scu_ext_wrmemattr_i   (scu_ext_wrmemattr_o[7:0]),
    .scu_ext_dw_valid_i    (scu_ext_dw_valid_o),
    .scu_ext_dw_id_i       (scu_ext_dw_id_o[4:0]),
    .scu_ext_dw_strb_i     (scu_ext_dw_strb_o[15:0]),
    .scu_ext_dw_data_i     (scu_ext_dw_data_o[127:0]),
    .scu_ext_dw_last_i     (scu_ext_dw_last_o),
    .scu_ext_db_ready_i    (scu_ext_db_ready_o),
    .scu_ext_ac_ready_i    (scu_ext_ac_ready_o),
    .scu_ext_cr_valid_i    (scu_ext_cr_valid_o),
    .scu_ext_cr_resp_i     (scu_ext_cr_resp_o[4:0]),
    .scu_ext_cd_valid_i    (scu_ext_cd_valid_o),
    .scu_ext_cd_data_i     (scu_ext_cd_data_o[127:0]),
    .scu_ext_cd_last_i     (scu_ext_cd_last_o),
    .scu_ext_rack_i        (scu_ext_rack_o),
    .scu_ext_wack_i        (scu_ext_wack_o),
    .scu_txsactive_i       (scu_txsactive_o),
    .scu_rxlinkactiveack_i (scu_rxlinkactiveack_o),
    .scu_txlinkactivereq_i (scu_txlinkactivereq_o),
    .scu_txreqflitpend_i   (scu_txreqflitpend_o),
    .scu_txreqflitv_i      (scu_txreqflitv_o),
    .scu_txreqflit_i       (scu_txreqflit_o[99:0]),
    .scu_reqmemattr_i      (scu_reqmemattr_o[7:0]),
    .scu_txrspflitpend_i   (scu_txrspflitpend_o),
    .scu_txrspflitv_i      (scu_txrspflitv_o),
    .scu_txrspflit_i       (scu_txrspflit_o[44:0]),
    .scu_txdatflitpend_i   (scu_txdatflitpend_o),
    .scu_txdatflitv_i      (scu_txdatflitv_o),
    .scu_txdatflit_i       (scu_txdatflit_o[193:0]),
    .scu_rxsnplcrdv_i      (scu_rxsnplcrdv_o),
    .scu_rxrsplcrdv_i      (scu_rxrsplcrdv_o),
    .scu_rxdatlcrdv_i      (scu_rxdatlcrdv_o),
    .scu_acp_awready_i     (scu_acp_awready_o),
    .scu_acp_wready_i      (scu_acp_wready_o),
    .scu_acp_bvalid_i      (scu_acp_bvalid_o),
    .scu_acp_bid_i         (scu_acp_bid_o[4:0]),
    .scu_acp_bresp_i       (scu_acp_bresp_o[1:0]),
    .scu_acp_arready_i     (scu_acp_arready_o),
    .scu_acp_rvalid_i      (scu_acp_rvalid_o),
    .scu_acp_rid_i         (scu_acp_rid_o[4:0]),
    .scu_acp_rdata_i       (scu_acp_rdata_o[127:0]),
    .scu_acp_rresp_i       (scu_acp_rresp_o[1:0]),
    .scu_acp_rlast_i       (scu_acp_rlast_o)
  );  // u_ca53_scu_ext

  ca53_gov_scu `CA53_GOV_SCU_PARAM_INST u_gov_checker (
    /*ARMAUTO*/
    .clk                      (CLKIN),
    .reset_n                  (nl2reset),
    // Inputs
    .scu_wfx_ready_i          (scu_wfx_ready[NUM_CPUS-1:0]),
    .scu_axierr_i             (scu_axierr),
    .scu_eccerr_i             (scu_eccerr),
    .scu_l2ecc_valid_i        (scu_l2ecc_valid),
    .scu_l2ecc_fatal_i        (scu_l2ecc_fatal),
    .scu_l2ecc_ramid_i        (scu_l2ecc_ramid[1:0]),
    .scu_l2ecc_cpuid_way_i    (scu_l2ecc_cpuid_way[3:0]),
    .scu_l2ecc_index_i        (scu_l2ecc_index[14:0]),
    .scu_l2_retention_ready_i (scu_l2_retention_ready),
    .scu_cpu0_inv_all_ack_i   (scu_cpu0_inv_all_ack),
    .scu_cpu1_inv_all_ack_i   (scu_cpu1_inv_all_ack),
    .scu_cpu2_inv_all_ack_i   (scu_cpu2_inv_all_ack),
    .scu_cpu3_inv_all_ack_i   (scu_cpu3_inv_all_ack),
    .scu_mbistack0_i          (scu_mbistack0),
    .scu_mbistack1_i          (scu_mbistack1),
    .scu_mbistoutdata0_i      (scu_mbistoutdata0[`CA53_MBIST0_DATA_W-1: 0]),
    .scu_mbistoutdata1_i      (scu_mbistoutdata1[`CA53_MBIST1_DATA_W-1: 0]),
    .gov_cpu0_smp_en_i        (gov_cpu0_smp_en),
    .gov_cpu1_smp_en_i        (gov_cpu1_smp_en),
    .gov_cpu2_smp_en_i        (gov_cpu2_smp_en),
    .gov_cpu3_smp_en_i        (gov_cpu3_smp_en),
    .gov_standbywfi_i         (gov_standbywfi[NUM_CPUS-1:0]),
    .gov_enable_writeevict_i  (gov_enable_writeevict),
    .gov_disable_evict_i      (gov_disable_evict),
    .gov_l2victim_ctl_i       (gov_l2victim_ctl[1:0]),
    .gov_l2deien_i            (gov_l2deien),
    .gov_l2teien_i            (gov_l2teien),
    .gov_clear_axierr_i       (gov_clear_axierr),
    .gov_clear_eccerr_i       (gov_clear_eccerr),
    .gov_l2_in_retention_i    (gov_l2_in_retention),
    .gov_cpu0_inv_all_req_i   (gov_cpu0_inv_all_req),
    .gov_cpu1_inv_all_req_i   (gov_cpu1_inv_all_req),
    .gov_cpu2_inv_all_req_i   (gov_cpu2_inv_all_req),
    .gov_cpu3_inv_all_req_i   (gov_cpu3_inv_all_req),
    .gov_mbistreq_i           (gov_mbistreq),
    .gov_mbistarray0_i        (gov_mbistarray0[`CA53_MBIST0_RAMARRAY_W-1:0]),
    .gov_mbistarray1_i        (gov_mbistarray1[`CA53_MBIST1_RAMARRAY_W-1:0]),
    .gov_mbistwriteen0_i      (gov_mbistwriteen0),
    .gov_mbistwriteen1_i      (gov_mbistwriteen1),
    .gov_mbistreaden0_i       (gov_mbistreaden0),
    .gov_mbistreaden1_i       (gov_mbistreaden1),
    .gov_mbistaddr0_i         (gov_mbistaddr0[`CA53_MBIST0_ADDR_W-1: 0]),
    .gov_mbistaddr1_i         (gov_mbistaddr1[`CA53_MBIST1_ADDR_W-1: 0]),
    .gov_mbistbe0_i           (gov_mbistbe0[`CA53_MBIST0_BE_W-1:0]),
    .gov_mbistbe1_i           (gov_mbistbe1[`CA53_MBIST1_BE_W-1:0]),
    .gov_mbistcfg0_i          (gov_mbistcfg0),
    .gov_mbistcfg1_i          (gov_mbistcfg1),
    .gov_mbistindata0_i       (gov_mbistindata0[`CA53_MBIST0_DATA_W-1: 0]),
    .gov_mbistindata1_i       (gov_mbistindata1[`CA53_MBIST1_DATA_W-1: 0])
  );  // u_gov_checker

  ca53_gicarb_ext `CA53_GIC_PARAM_INST u_ca53_gicarb_ext (
    .clk                (CLKIN),
    .reset_n            (nl2reset),
    .gov_giccdisable_i  (gov_giccdisable_o),
    .icctdata_i         (icctdata_o),
    .icctid_i           (icctid_o),
    .icctlast_i         (icctlast_o),
    .icctready_i        (icctready_i),
    .icctvalid_i        (icctvalid_o),
    .icdtdata_i         (icdtdata_i),
    .icdtdest_i         (icdtdest_i),
    .icdtlast_i         (icdtlast_i),
    .icdtready_i        (icdtready_o),
    .icdtvalid_i        (icdtvalid_i)
  ); // u_ca53_gicarb_ext

  generate

    for ( cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1 ) begin : ca53gic_cpu_ext

      ca53_gic_ext u_ca53_gic_ext (
        .clk                (CLKIN),
        .reset_n            (nl2reset),
        .gov_giccdisable_i  (gov_giccdisable_o),
        .nvcpumntirq_i      (nvcpumntirq_o[cpu])
      ); // u_ca53_gic_ext

    end

  endgenerate


`endif

endmodule // ca53_l2noram

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
