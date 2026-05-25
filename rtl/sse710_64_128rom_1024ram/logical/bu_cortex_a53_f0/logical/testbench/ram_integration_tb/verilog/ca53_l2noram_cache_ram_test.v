//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-30 17:16:48 +0100 (Mon, 30 Jul 2012) $
//
//      Revision            : $Revision: 216970 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Top level of the CortexA53 L2 memory system (without RAMs)
//-----------------------------------------------------------------------------

//
// This module presents the same portlist as the real ca53_noram but
// performs RAM test operations in order to determine if the I-Cache and
// D-Cache have been correctly integrated. Use this with
// CORTEXA53_RAMtestbench as described in the Configuration and Sign-off Guide.
//
// The testbench checks that all RAMs are integrated correctly. Three tests are run
// on each RAM:
//
// 1. Write Data = Address to all RAM words, then read back
// 2. Write/Read a walking 1 pattern across the RAM word, with all Byte/BitWE high.
//    This checks for data in/out shorts. Only 1 bit written at a time. (WR_*).
// 3. Write/Read a walking 1 pattern across the RAM word, with WE selecting which
//    byte/bit is written to.
//    - for byte writeable RAM, the same data pattern is driven to each byte. Only
//      the expected byte should be written to. This checks for ByteWE shorts.
//    - for bit writeable RAM, a solid '1' pattern is driven to all data pins.
//      BitWE selects which bit is written to. This creates a walking '1' with
//      a solid '1' tail, checking for BitWE shorts.
//    - If a RAM has multiple WE and EN controls, 2 is repeated twice, once with
//      WE toggling (WR_*WE) and the other with EN (WR_*EN) toggling.

//
// These three tests cover the following checks:
//
// Check                                Checked by   Note
// -------------------------------      ----------   ----
// a) RAM is expected size.             1,3          1
// b) CS shorts/miswiring               1
// c) WE shorts/miswiring               3
// d) Data bus shorts/miswiring         1,2
// e) Address bus shorts/miswiring      1
// f) Wiring to correct RAM             RAM tests staggered
//
// Notes
// -----
// 1. Data is written to a ^2 alias address, which will be location 0 if the RAM
//    is the correct size. If the RAM is too large, RAM will read back 0.
//    It isn't possible to write to an alias for the largest cache size.
//    A too small RAM is checked for by (1).
//

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


  localparam SIZE_WIDTH = 3;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_8K      = 3'b000;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_16K     = 3'b001;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_32K     = 3'b011;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_64K     = 3'b111;

  localparam L2_SIZE_WIDTH = 4;
  localparam [L2_SIZE_WIDTH-1:0] CORTEXA53_L2SIZE_128K  = 4'b0000;
  localparam [L2_SIZE_WIDTH-1:0] CORTEXA53_L2SIZE_256K  = 4'b0001;
  localparam [L2_SIZE_WIDTH-1:0] CORTEXA53_L2SIZE_512K  = 4'b0011;
  localparam [L2_SIZE_WIDTH-1:0] CORTEXA53_L2SIZE_1024K = 4'b0111;
  localparam [L2_SIZE_WIDTH-1:0] CORTEXA53_L2SIZE_2048K = 4'b1111;

  localparam STATE_WIDTH = 4;
  localparam [STATE_WIDTH-1:0] STATE_IDLE         = 4'b0000;
  localparam [STATE_WIDTH-1:0] START_L2_DATARAM   = 4'b0001;
  localparam [STATE_WIDTH-1:0] START_L2_TAGRAM    = 4'b0010;
  localparam [STATE_WIDTH-1:0] START_L1D_CPU0     = 4'b0011;
  localparam [STATE_WIDTH-1:0] START_L1D_CPU1     = 4'b0100;
  localparam [STATE_WIDTH-1:0] START_L1D_CPU2     = 4'b0101;
  localparam [STATE_WIDTH-1:0] START_L1D_CPU3     = 4'b0110;
  localparam [STATE_WIDTH-1:0] START_L2_VICTIMRAM = 4'b0111;
  localparam [STATE_WIDTH-1:0] STATE_FINISH       = 4'b1000;


  localparam PRINT_WIDTH = 4;
  localparam [STATE_WIDTH-1:0] PRINT_IDLE         = 4'b0000;
  localparam [PRINT_WIDTH-1:0] PRINT_HEADER       = 4'b0001;
  localparam [PRINT_WIDTH-1:0] WAIT_FOR_DONE      = 4'b0010;
  localparam [PRINT_WIDTH-1:0] PRINT_L2_DATARAM   = 4'b0011;
  localparam [PRINT_WIDTH-1:0] PRINT_L2_TAGRAM    = 4'b0100;
  localparam [PRINT_WIDTH-1:0] PRINT_L1D_CPU0     = 4'b0101;
  localparam [PRINT_WIDTH-1:0] PRINT_L1D_CPU1     = 4'b0110;
  localparam [PRINT_WIDTH-1:0] PRINT_L1D_CPU2     = 4'b0111;
  localparam [PRINT_WIDTH-1:0] PRINT_L1D_CPU3     = 4'b1000;
  localparam [PRINT_WIDTH-1:0] PRINT_L2_VICTIMRAM = 4'b1001;
  localparam [PRINT_WIDTH-1:0] PRINT_FINISH       = 4'b1010;

  //Wire and Reg Declarations
  //-------------------------

  reg [7 * 8 : 1]                         l1d_size_str;
  reg [7 * 8 : 1]                         l2_size_str;
  reg [7:0 ]                              max_l1dtagram_range;
  reg [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]    max_l2tagram_range;
  reg [`CA53_SCU_L2_DATARAM_ADDR_W-1-3:0] max_l2_dataram_range;
  reg [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] max_l2victimram_range;
  reg  [3:0 ]                             next_state;
  reg  [3:0 ]                             state;
  reg  [3:0 ]                             print_state;
  reg  [3:0 ]                             print_next_state;
  reg  [1:0]                              start_count;
  reg                                     l1d_tests_completed;
  reg                                     all_l1d_tests_completed;
  reg                                     start_l1d_clken_chk;
  reg                                     clken_chk;  
  reg                                     all_l1d_tests_passed;
  
  wire   l1d_clken_chk_en;
  wire [7:0]                              max_tlbram_range;
  wire [1:0]                              start_count_end;
  wire                                    start_count_en;
  wire [1:0]                              start_count_nxt;
  wire                                    all_tests_completed;
  wire                                    all_tests_passed;

  wire                                    l1dtagram_passed_cpu0_num1;
  wire                                    l1dtagram_passed_cpu0_num2;
  wire                                    l1dtagram_done_cpu0_num1;
  wire                                    l1dtagram_done_cpu0_num2;
  wire                                    l1dtagram_passed_cpu1_num1;
  wire                                    l1dtagram_passed_cpu1_num2;
  wire                                    l1dtagram_done_cpu1_num1;
  wire                                    l1dtagram_done_cpu1_num2;
  wire                                    l1dtagram_passed_cpu2_num1;
  wire                                    l1dtagram_passed_cpu2_num2;
  wire                                    l1dtagram_done_cpu2_num1;
  wire                                    l1dtagram_done_cpu2_num2;
  wire                                    l1dtagram_passed_cpu3_num1;
  wire                                    l1dtagram_passed_cpu3_num2;
  wire                                    l1dtagram_done_cpu3_num1;
  wire                                    l1dtagram_done_cpu3_num2;
  wire                                    l1dtagram_clken_cpu0;
  wire                                    l1dtagram_clken_cpu1;
  wire                                    l1dtagram_clken_cpu2;
  wire                                    l1dtagram_clken_cpu3;
  wire                                    l2tagram_passed_num1;
  wire                                    l2tagram_passed_num2;
  wire                                    l2tagram_done_num1;
  wire                                    l2tagram_done_num2;
  wire                                    l2_dataram_passed_num1;
  wire                                    l2_dataram_passed_num2;
  wire                                    l2_dataram_done_num1;
  wire                                    l2_dataram_done_num2;
  wire                                    l2_victimram_passed_num1;
  wire                                    l2_victimram_passed_num2;
  wire                                    l2_victimram_passed_num3;
  wire                                    l2_victimram_done_num1;
  wire                                    l2_victimram_done_num2;
  wire                                    l2_victimram_done_num3;
  wire                                    l2_tests_completed;
  wire                                    debug;
  wire                                    l2_tests_passed;

  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu0_en;
  wire  				  l1d_tagram_cpu0_wr;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu0_addr;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu0_wdata;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu0_en_clken;
  wire  				  l1d_tagram_cpu0_wr_clken;  
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu0_addr_clken;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu0_wdata_clken;
  wire  				  l1dtagram_passed_cpu0_clken_num1;
  wire  				  l1dtagram_passed_cpu0_clken_num2;
  wire  				  l1dtagram_done_cpu0_clken_num1;
  wire  				  l1dtagram_done_cpu0_clken_num2;
  wire  				  l1dtagram_clken_cpu0_clken;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu1_en;
  wire  				  l1d_tagram_cpu1_wr;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu1_addr;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu1_wdata;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu1_en_clken;
  wire  				  l1d_tagram_cpu1_wr_clken;  
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu1_addr_clken;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu1_wdata_clken;
  wire  				  l1dtagram_passed_cpu1_clken_num1;
  wire  				  l1dtagram_passed_cpu1_clken_num2;
  wire  				  l1dtagram_done_cpu1_clken_num1;
  wire  				  l1dtagram_done_cpu1_clken_num2;
  wire  				  l1dtagram_clken_cpu1_clken;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu2_en;
  wire  				  l1d_tagram_cpu2_wr;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu2_addr;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu2_wdata;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu2_en_clken;
  wire  				  l1d_tagram_cpu2_wr_clken;  
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu2_addr_clken;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu2_wdata_clken;
  wire  				  l1dtagram_passed_cpu2_clken_num1;
  wire  				  l1dtagram_passed_cpu2_clken_num2;
  wire  				  l1dtagram_done_cpu2_clken_num1;
  wire  				  l1dtagram_done_cpu2_clken_num2;
  wire  				  l1dtagram_clken_cpu2_clken;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu3_en;
  wire  				  l1d_tagram_cpu3_wr;
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu3_addr;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu3_wdata;
  wire [`CA53_SCU_L1D_ASSOC-1:0]	  l1d_tagram_cpu3_en_clken;
  wire  				  l1d_tagram_cpu3_wr_clken;  
  wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]  l1d_tagram_cpu3_addr_clken;
  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]  l1d_tagram_cpu3_wdata_clken;
  wire  				  l1dtagram_passed_cpu3_clken_num1;
  wire  				  l1dtagram_passed_cpu3_clken_num2;
  wire  				  l1dtagram_done_cpu3_clken_num1;
  wire  				  l1dtagram_done_cpu3_clken_num2;
  wire  				  l1dtagram_clken_cpu3_clken;
  
  //Fanning out reset and clock logic to L1 Cache Level
  //----------------------------------------------------

  assign clk_cpu     = {NUM_CPUS{CLKIN}};
  assign reset_n_cpu = ncorereset;
  assign clk         = CLKIN;

  // ---------------------------------------------------------
  // L2 Stimulus
  // ---------------------------------------------------------

  assign max_tlbram_range = {8{1'b1}};

  always @(negedge nl2reset)
    if (!nl2reset)
      case (l1_dc_size_i)
        CORTEXA53_SIZE_8K: begin
          l1d_size_str          <= "8kB";
          max_l1dtagram_range   <= 8'b00011111;
        end

        CORTEXA53_SIZE_16K: begin
          l1d_size_str          <= "16kB";
          max_l1dtagram_range   <= 8'b00111111;
        end

        CORTEXA53_SIZE_32K: begin
          l1d_size_str          <= "32kB";
          max_l1dtagram_range   <= 8'b01111111;
        end

        CORTEXA53_SIZE_64K: begin
          l1d_size_str          <= "64kB";
          max_l1dtagram_range   <= 8'b11111111;
        end
        default: begin
          l1d_size_str         <= "Invalid";
          max_l1dtagram_range   <= 8'b00000000;
        end
      endcase

  always @(negedge nl2reset)
    if (!nl2reset)
      case (l2_size_i)
        CORTEXA53_L2SIZE_128K: begin
          l2_size_str           <= "128kB";
          max_l2tagram_range    <= 11'b00001111111;
          max_l2_dataram_range  <= 12'b000011111111;
          max_l2victimram_range <= 11'b00001111111;
        end

        CORTEXA53_L2SIZE_256K: begin
          l2_size_str           <= "256kB";
          max_l2tagram_range    <= 11'b00011111111;
          max_l2_dataram_range  <= 12'b000111111111;
          max_l2victimram_range <= 11'b00011111111;
        end

        CORTEXA53_L2SIZE_512K: begin
          l2_size_str           <= "512kB";
          max_l2tagram_range    <= 11'b00111111111;
          max_l2_dataram_range  <= 12'b001111111111;
          max_l2victimram_range <= 11'b00111111111;
        end

        CORTEXA53_L2SIZE_1024K: begin
          l2_size_str           <= "1024kB";
          max_l2tagram_range    <= 11'b01111111111;
          max_l2_dataram_range  <= 12'b011111111111;
          max_l2victimram_range <= 11'b01111111111;
        end

        CORTEXA53_L2SIZE_2048K: begin
          l2_size_str           <= "2048kB";
          max_l2tagram_range    <= 11'b11111111111;
          max_l2_dataram_range  <= 12'b111111111111;
          max_l2victimram_range <= 11'b11111111111;
        end

        default: begin
          l2_size_str          <= "Invalid";
          max_l2tagram_range    <= {11{1'b0}};
          max_l2_dataram_range  <= {12{1'b0}};
          max_l2victimram_range <= {11{1'b0}};
        end
      endcase

    // -------------------------------------------
   // State Machine to trigger L2 TB (staggered)
   // ------------------------------------------

   always @*
    case (state)
      STATE_IDLE          : next_state = nl2reset                       ? START_L2_DATARAM   : STATE_IDLE        ;
      START_L2_DATARAM    : next_state = start_count == start_count_end ? START_L2_TAGRAM    : START_L2_DATARAM  ;
      START_L2_TAGRAM     : next_state = start_count == start_count_end ? START_L1D_CPU0     : START_L2_TAGRAM   ;
      START_L1D_CPU0      : next_state = start_count == start_count_end ? START_L1D_CPU1     : START_L1D_CPU0    ;
      START_L1D_CPU1      : next_state = start_count == start_count_end ? START_L1D_CPU2     : START_L1D_CPU1    ;
      START_L1D_CPU2      : next_state = start_count == start_count_end ? START_L1D_CPU3     : START_L1D_CPU2    ;
      START_L1D_CPU3      : next_state = start_count == start_count_end ? START_L2_VICTIMRAM : START_L1D_CPU3    ;
      START_L2_VICTIMRAM  : next_state = start_count == start_count_end ? STATE_FINISH       : START_L2_VICTIMRAM;
      STATE_FINISH        : next_state = STATE_FINISH;
      default             : next_state = STATE_IDLE;
    endcase

    //Registering the next stage
   always @(posedge CLKIN or negedge nl2reset)
    if (!nl2reset) begin
      state      <= STATE_IDLE;
    end else begin
      state      <= next_state;
    end

  // Start Counter for staggering after a few cycles
  //------------------------------------------------

  //Stop the counter so the test will stagger by 4 clock cycles
  assign start_count_end = 2'b11;

  assign start_count_en  = state != STATE_IDLE  & state != STATE_FINISH;

  assign start_count_nxt = state != STATE_IDLE & (start_count < start_count_end) ? start_count + 2'h1 : 2'h0;

   always @(posedge CLKIN or negedge nl2reset)
    if (!nl2reset) begin
      start_count <= 2'h0;
    end else if (start_count_en) begin
      start_count <= start_count_nxt;
    end

  // --------------------------
  // L2- Testbench Declarations
  // ---------------------------

 // clken for L1D TagRAM 
 assign l1d_tagram_clken_o = ~clken_chk ? (l1dtagram_clken_cpu0 | l1dtagram_clken_cpu1 | l1dtagram_clken_cpu2 | l1dtagram_clken_cpu3) :
                                          (l1dtagram_clken_cpu0_clken | l1dtagram_clken_cpu1_clken | l1dtagram_clken_cpu2_clken | l1dtagram_clken_cpu3_clken);
 
 assign l1d_tagram_cpu0_en_o    = ~clken_chk ? l1d_tagram_cpu0_en    : l1d_tagram_cpu0_en_clken;       
 assign l1d_tagram_cpu0_wr_o    = ~clken_chk ? l1d_tagram_cpu0_wr    : l1d_tagram_cpu0_wr_clken;  
 assign l1d_tagram_cpu0_addr_o  = ~clken_chk ? l1d_tagram_cpu0_addr  : l1d_tagram_cpu0_addr_clken;
 assign l1d_tagram_cpu0_wdata_o = ~clken_chk ? l1d_tagram_cpu0_wdata : l1d_tagram_cpu0_wdata_clken;
 
 ca53l1d_tagram_tb `CA53_L2_PARAM_INST u_ca53_cpu0_l1d_tagram_tb (
  .l1d_tagram_cpu_way0_rdata_i      (l1d_tagram_cpu0_way0_rdata_i),
  .l1d_tagram_cpu_way1_rdata_i      (l1d_tagram_cpu0_way1_rdata_i),
  .l1d_tagram_cpu_way2_rdata_i      (l1d_tagram_cpu0_way2_rdata_i),
  .l1d_tagram_cpu_way3_rdata_i      (l1d_tagram_cpu0_way3_rdata_i),
  .l1d_tagram_cpu_en_o              (l1d_tagram_cpu0_en          ),
  .l1d_tagram_cpu_wr_o              (l1d_tagram_cpu0_wr          ),
  .l1d_tagram_cpu_addr_o            (l1d_tagram_cpu0_addr        ),
  .l1d_tagram_cpu_wdata_o           (l1d_tagram_cpu0_wdata       ),

  .l1dtagram_passed_num1_o          (l1dtagram_passed_cpu0_num1  ),
  .l1dtagram_passed_num2_o          (l1dtagram_passed_cpu0_num2  ),
  .l1dtagram_clken_o                (l1dtagram_clken_cpu0        ),
  .l1dtagram_done_num1_o            (l1dtagram_done_cpu0_num1    ),
  .l1dtagram_done_num2_o            (l1dtagram_done_cpu0_num2    ),
  .clk                              (CLKIN                       ),
  .reset_n                          (nl2reset                    ),
  .l1_dc_size_i                     (l1_dc_size_i                ),
  .max_l1dtagram_range              (max_l1dtagram_range         ),
  .num_cpu                          (2'b00                       ),
  .test_start_i                     (state == START_L1D_CPU0     )
 );

 ca53l1d_tagram_clken_tb `CA53_L2_PARAM_INST u_ca53_cpu0_l1d_tagram_clken_tb (
  .l1d_tagram_cpu_way0_rdata_i      (l1d_tagram_cpu0_way0_rdata_i     ),
  .l1d_tagram_cpu_way1_rdata_i      (l1d_tagram_cpu0_way1_rdata_i     ),
  .l1d_tagram_cpu_way2_rdata_i      (l1d_tagram_cpu0_way2_rdata_i     ),
  .l1d_tagram_cpu_way3_rdata_i      (l1d_tagram_cpu0_way3_rdata_i     ),
  .l1d_tagram_cpu_en_o              (l1d_tagram_cpu0_en_clken         ),
  .l1d_tagram_cpu_wr_o              (l1d_tagram_cpu0_wr_clken         ),
  .l1d_tagram_cpu_addr_o            (l1d_tagram_cpu0_addr_clken       ),
  .l1d_tagram_cpu_wdata_o           (l1d_tagram_cpu0_wdata_clken      ),

  .l1dtagram_passed_num1_o          (l1dtagram_passed_cpu0_clken_num1 ),
  .l1dtagram_passed_num2_o          (l1dtagram_passed_cpu0_clken_num2 ),
  .l1dtagram_clken_o                (l1dtagram_clken_cpu0_clken       ),
  .l1dtagram_done_num1_o            (l1dtagram_done_cpu0_clken_num1   ),
  .l1dtagram_done_num2_o            (l1dtagram_done_cpu0_clken_num2   ),
  .clk                              (CLKIN                            ),
  .reset_n                          (nl2reset                         ),
  .l1_dc_size_i                     (l1_dc_size_i                     ),
  .max_l1dtagram_range              (max_l1dtagram_range              ),
  .num_cpu                          (2'b00                            ),
  .test_start_i                     (start_l1d_clken_chk              )
 );
 
 generate if (NUM_CPUS >= 2) begin : l1d_tagramcpu1_tb

   assign l1d_tagram_cpu1_en_o    = ~clken_chk ? l1d_tagram_cpu1_en    : l1d_tagram_cpu1_en_clken;       
   assign l1d_tagram_cpu1_wr_o    = ~clken_chk ? l1d_tagram_cpu1_wr    : l1d_tagram_cpu1_wr_clken;  
   assign l1d_tagram_cpu1_addr_o  = ~clken_chk ? l1d_tagram_cpu1_addr  : l1d_tagram_cpu1_addr_clken;
   assign l1d_tagram_cpu1_wdata_o = ~clken_chk ? l1d_tagram_cpu1_wdata : l1d_tagram_cpu1_wdata_clken;
   
   ca53l1d_tagram_tb `CA53_L2_PARAM_INST u_ca53_cpu1_l1d_tagram_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu1_way0_rdata_i),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu1_way1_rdata_i),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu1_way2_rdata_i),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu1_way3_rdata_i),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu1_en          ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu1_wr          ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu1_addr        ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu1_wdata       ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu1_num1  ),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu1_num2  ),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu1        ),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu1_num1    ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu1_num2    ),
   .clk                             (CLKIN                       ),
   .reset_n                         (nl2reset                    ),
   .l1_dc_size_i                    (l1_dc_size_i                ),
   .max_l1dtagram_range             (max_l1dtagram_range         ),
   .num_cpu                         (2'b01                       ),
   .test_start_i                    (state == START_L1D_CPU1     )
  );

  ca53l1d_tagram_clken_tb `CA53_L2_PARAM_INST u_ca53_cpu1_l1d_tagram_clken_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu1_way0_rdata_i    ),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu1_way1_rdata_i    ),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu1_way2_rdata_i    ),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu1_way3_rdata_i    ),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu1_en_clken        ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu1_wr_clken        ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu1_addr_clken      ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu1_wdata_clken     ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu1_clken_num1),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu1_clken_num2),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu1_clken      ),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu1_clken_num1  ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu1_clken_num2  ),
   .clk                             (CLKIN                           ),
   .reset_n                         (nl2reset                        ),
   .l1_dc_size_i                    (l1_dc_size_i                    ),
   .max_l1dtagram_range             (max_l1dtagram_range             ),
   .num_cpu                         (2'b01                           ),
   .test_start_i                    (start_l1d_clken_chk             )
  );
  
 end else begin : l1d_tagramcpu1_tieoffs
  assign l1dtagram_clken_cpu1       =  1'b0;
  assign l1dtagram_clken_cpu1_clken =  1'b0;
  assign l1d_tagram_cpu1_en_o       = {`CA53_SCU_L1D_ASSOC{1'b0}};
  assign l1d_tagram_cpu1_wr_o       =  1'b0;
  assign l1d_tagram_cpu1_addr_o     = {`CA53_SCU_L1D_TAGRAM_ADDR_W{1'b0}};
  assign l1d_tagram_cpu1_wdata_o    = {`CA53_SCU_L1D_TAGRAM_DATA_W{1'b0}};
 end
 endgenerate

 generate if (NUM_CPUS >= 3) begin : l1d_tagramcpu2_tb
   
   assign l1d_tagram_cpu2_en_o    = ~clken_chk ? l1d_tagram_cpu2_en    : l1d_tagram_cpu2_en_clken;       
   assign l1d_tagram_cpu2_wr_o    = ~clken_chk ? l1d_tagram_cpu2_wr    : l1d_tagram_cpu2_wr_clken;  
   assign l1d_tagram_cpu2_addr_o  = ~clken_chk ? l1d_tagram_cpu2_addr  : l1d_tagram_cpu2_addr_clken;
   assign l1d_tagram_cpu2_wdata_o = ~clken_chk ? l1d_tagram_cpu2_wdata : l1d_tagram_cpu2_wdata_clken;
   
   ca53l1d_tagram_tb `CA53_L2_PARAM_INST u_ca53_cpu2_l1d_tagram_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu2_way0_rdata_i),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu2_way1_rdata_i),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu2_way2_rdata_i),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu2_way3_rdata_i),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu2_en         ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu2_wr         ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu2_addr       ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu2_wdata      ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu2_num1 ),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu2_num2 ),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu2_num1   ),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu2       ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu2_num2   ),
   .clk                             (CLKIN                      ),
   .reset_n                         (nl2reset                   ),
   .l1_dc_size_i                    (l1_dc_size_i               ),
   .max_l1dtagram_range             (max_l1dtagram_range        ),
   .num_cpu                         (2'b10                      ),
   .test_start_i                    (state == START_L1D_CPU2    )
  );
 
   ca53l1d_tagram_clken_tb `CA53_L2_PARAM_INST u_ca53_cpu2_l1d_tagram_clken_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu2_way0_rdata_i    ),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu2_way1_rdata_i    ),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu2_way2_rdata_i    ),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu2_way3_rdata_i    ),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu2_en_clken        ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu2_wr_clken        ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu2_addr_clken      ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu2_wdata_clken     ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu2_clken_num1),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu2_clken_num2),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu2_clken_num1  ),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu2_clken      ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu2_clken_num2  ),
   .clk                             (CLKIN                           ),
   .reset_n                         (nl2reset                        ),
   .l1_dc_size_i                    (l1_dc_size_i                    ),
   .max_l1dtagram_range             (max_l1dtagram_range             ),
   .num_cpu                         (2'b10                           ),
   .test_start_i                    (start_l1d_clken_chk             )
  );

 end else begin : l1d_tagramcpu2_tieoffs
  assign l1dtagram_clken_cpu2       =  1'b0;
  assign l1dtagram_clken_cpu2_clken =  1'b0;
  assign l1d_tagram_cpu2_en_o       = {`CA53_SCU_L1D_ASSOC{1'b0}};
  assign l1d_tagram_cpu2_wr_o       =  1'b0;
  assign l1d_tagram_cpu2_addr_o     = {`CA53_SCU_L1D_TAGRAM_ADDR_W{1'b0}};
  assign l1d_tagram_cpu2_wdata_o    = {`CA53_SCU_L1D_TAGRAM_DATA_W{1'b0}};
 end
 endgenerate

generate if (NUM_CPUS >= 4) begin : l1d_tagramcpu3_tb

   assign l1d_tagram_cpu3_en_o    = ~clken_chk ? l1d_tagram_cpu3_en    : l1d_tagram_cpu3_en_clken;       
   assign l1d_tagram_cpu3_wr_o    = ~clken_chk ? l1d_tagram_cpu3_wr    : l1d_tagram_cpu3_wr_clken;  
   assign l1d_tagram_cpu3_addr_o  = ~clken_chk ? l1d_tagram_cpu3_addr  : l1d_tagram_cpu3_addr_clken;
   assign l1d_tagram_cpu3_wdata_o = ~clken_chk ? l1d_tagram_cpu3_wdata : l1d_tagram_cpu3_wdata_clken;
   
   ca53l1d_tagram_tb `CA53_L2_PARAM_INST u_ca53_cpu3_l1d_tagram_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu3_way0_rdata_i),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu3_way1_rdata_i),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu3_way2_rdata_i),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu3_way3_rdata_i),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu3_en          ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu3_wr          ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu3_addr        ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu3_wdata       ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu3_num1 ),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu3_num2 ),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu3       ),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu3_num1   ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu3_num2   ),
   .clk                             (CLKIN                      ),
   .reset_n                         (nl2reset                   ),
   .l1_dc_size_i                    (l1_dc_size_i               ),
   .max_l1dtagram_range             (max_l1dtagram_range        ),
   .num_cpu                         (2'b11                      ),
   .test_start_i                    (state == START_L1D_CPU3    )
  );
   
   ca53l1d_tagram_clken_tb `CA53_L2_PARAM_INST u_ca53_cpu3_l1d_tagram_clken_tb (
   .l1d_tagram_cpu_way0_rdata_i     (l1d_tagram_cpu3_way0_rdata_i    ),
   .l1d_tagram_cpu_way1_rdata_i     (l1d_tagram_cpu3_way1_rdata_i    ),
   .l1d_tagram_cpu_way2_rdata_i     (l1d_tagram_cpu3_way2_rdata_i    ),
   .l1d_tagram_cpu_way3_rdata_i     (l1d_tagram_cpu3_way3_rdata_i    ),
   .l1d_tagram_cpu_en_o             (l1d_tagram_cpu3_en_clken        ),
   .l1d_tagram_cpu_wr_o             (l1d_tagram_cpu3_wr_clken        ),
   .l1d_tagram_cpu_addr_o           (l1d_tagram_cpu3_addr_clken      ),
   .l1d_tagram_cpu_wdata_o          (l1d_tagram_cpu3_wdata_clken     ),

   .l1dtagram_passed_num1_o         (l1dtagram_passed_cpu3_clken_num1),
   .l1dtagram_passed_num2_o         (l1dtagram_passed_cpu3_clken_num2),
   .l1dtagram_clken_o               (l1dtagram_clken_cpu3_clken      ),
   .l1dtagram_done_num1_o           (l1dtagram_done_cpu3_clken_num1  ),
   .l1dtagram_done_num2_o           (l1dtagram_done_cpu3_clken_num2  ),
   .clk                             (CLKIN                           ),
   .reset_n                         (nl2reset                        ),
   .l1_dc_size_i                    (l1_dc_size_i                    ),
   .max_l1dtagram_range             (max_l1dtagram_range             ),
   .num_cpu                         (2'b11                           ),
   .test_start_i                    (start_l1d_clken_chk             )
  );
  
 end else begin : l1d_tagramcpu3_tieoffs
  assign l1dtagram_clken_cpu3       =  1'b0;
  assign l1dtagram_clken_cpu3_clken =  1'b0;
  assign l1d_tagram_cpu3_en_o       = {`CA53_SCU_L1D_ASSOC{1'b0}};
  assign l1d_tagram_cpu3_wr_o       =  1'b0;
  assign l1d_tagram_cpu3_addr_o     = {`CA53_SCU_L1D_TAGRAM_ADDR_W{1'b0}};
  assign l1d_tagram_cpu3_wdata_o    = {`CA53_SCU_L1D_TAGRAM_DATA_W{1'b0}};
 end
 endgenerate

 generate if (L2_CACHE == 1) begin : l2_tagram_tb
   ca53_l2_tagram_tb `CA53_L2_PARAM_INST u_ca53_l2_tagram_tb (
     .l2_tagram_clken_o             (l2_tagram_clken_o      ),
     .l2_tagram_en_o                (l2_tagram_en_o         ),
     .l2_tagram_wr_o                (l2_tagram_wr_o         ),
     .l2_tagram_addr_o              (l2_tagram_addr_o       ),
     .l2_tagram_wdata_o             (l2_tagram_wdata_o      ),
     .l2_tagram_way0_rdata_i        (l2_tagram_way0_rdata_i ),
     .l2_tagram_way1_rdata_i        (l2_tagram_way1_rdata_i ),
     .l2_tagram_way2_rdata_i        (l2_tagram_way2_rdata_i ),
     .l2_tagram_way3_rdata_i        (l2_tagram_way3_rdata_i ),
     .l2_tagram_way4_rdata_i        (l2_tagram_way4_rdata_i ),
     .l2_tagram_way5_rdata_i        (l2_tagram_way5_rdata_i ),
     .l2_tagram_way6_rdata_i        (l2_tagram_way6_rdata_i ),
     .l2_tagram_way7_rdata_i        (l2_tagram_way7_rdata_i ),
     .l2_tagram_way8_rdata_i        (l2_tagram_way8_rdata_i ),
     .l2_tagram_way9_rdata_i        (l2_tagram_way9_rdata_i ),
     .l2_tagram_way10_rdata_i       (l2_tagram_way10_rdata_i),
     .l2_tagram_way11_rdata_i       (l2_tagram_way11_rdata_i),
     .l2_tagram_way12_rdata_i       (l2_tagram_way12_rdata_i),
     .l2_tagram_way13_rdata_i       (l2_tagram_way13_rdata_i),
     .l2_tagram_way14_rdata_i       (l2_tagram_way14_rdata_i),
     .l2_tagram_way15_rdata_i       (l2_tagram_way15_rdata_i),
     .l2tagram_passed_num1_o        (l2tagram_passed_num1   ),
     .l2tagram_passed_num2_o        (l2tagram_passed_num2   ),
     .l2tagram_done_num1_o          (l2tagram_done_num1     ),
     .l2tagram_done_num2_o          (l2tagram_done_num2     ),
     .clk                           (CLKIN                  ),
     .reset_n                       (nl2reset               ),
     .l2_size_i                     (l2_size_i              ),
     .max_l2tagram_range            (max_l2tagram_range     ),
     .test_start_i                  (state == START_L2_TAGRAM)
    );
 end else begin : l2_tagram_tieoffs
  assign l2_tagram_clken_o =  1'b0;
  assign l2_tagram_en_o    = {`CA53_SCU_L2_ASSOC{1'b0}};
  assign l2_tagram_wr_o    =  1'b0;
  assign l2_tagram_addr_o  = {`CA53_SCU_L2_TAGRAM_ADDR_W{1'b0}};
  assign l2_tagram_wdata_o = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
 end
 endgenerate

 generate if (L2_CACHE == 1) begin : l2_dataram_tb
   ca53_l2_dataram_tb `CA53_L2_PARAM_INST u_ca53_l2_dataram_tb (
    .l2_dataram_no_acc_next_cycle_o  (l2_dataram_no_acc_next_cycle_o),
    .l2_dataram_clken_o              (l2_dataram_clken_o            ),
    .l2_dataram_en_o                 (l2_dataram_en_o               ),
    .l2_dataram_wr_o                 (l2_dataram_wr_o               ),
    .l2_dataram_addr_o               (l2_dataram_addr_o             ),
    .l2_dataram_wdata0_o             (l2_dataram_wdata0_o           ),
    .l2_dataram_wdata1_o             (l2_dataram_wdata1_o           ),
    .l2_dataram_wdata2_o             (l2_dataram_wdata2_o           ),
    .l2_dataram_wdata3_o             (l2_dataram_wdata3_o           ),
    .l2_dataram_wdata4_o             (l2_dataram_wdata4_o           ),
    .l2_dataram_wdata5_o             (l2_dataram_wdata5_o           ),
    .l2_dataram_wdata6_o             (l2_dataram_wdata6_o           ),
    .l2_dataram_wdata7_o             (l2_dataram_wdata7_o           ),
    .l2_dataram_rdata0_i             (l2_dataram_rdata0_i           ),
    .l2_dataram_rdata1_i             (l2_dataram_rdata1_i           ),
    .l2_dataram_rdata2_i             (l2_dataram_rdata2_i           ),
    .l2_dataram_rdata3_i             (l2_dataram_rdata3_i           ),
    .l2_dataram_rdata4_i             (l2_dataram_rdata4_i           ),
    .l2_dataram_rdata5_i             (l2_dataram_rdata5_i           ),
    .l2_dataram_rdata6_i             (l2_dataram_rdata6_i           ),
    .l2_dataram_rdata7_i             (l2_dataram_rdata7_i           ),

    .l2_dataram_passed_num1_o        (l2_dataram_passed_num1        ),
    .l2_dataram_passed_num2_o        (l2_dataram_passed_num2        ),
    .l2_dataram_done_num1_o          (l2_dataram_done_num1          ),
    .l2_dataram_done_num2_o          (l2_dataram_done_num2          ),
    .clk                             (CLKIN                         ),
    .reset_n                         (nl2reset                      ),
    .max_l2_dataram_range            (max_l2_dataram_range          ),
    .test_start_i                    (state == START_L2_DATARAM     )
   );
 end else begin : l2_dataram_tieoffs
  assign l2_dataram_no_acc_next_cycle_o =  1'b0;
  assign l2_dataram_clken_o             = {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};   
  assign l2_dataram_en_o                = {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};   
  assign l2_dataram_wr_o                =  1'b0;			       
  assign l2_dataram_addr_o              = {`CA53_SCU_L2_DATARAM_ADDR_W{1'b0}}; 
  assign l2_dataram_wdata0_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata1_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata2_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata3_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata4_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata5_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata6_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
  assign l2_dataram_wdata7_o            = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}}; 
 end
 endgenerate

 generate if (L2_CACHE == 1) begin : l2_victimram_tb
   ca53_l2_victimram_tb u_ca53_l2_victimram_tb (
    .l2_victimram_no_acc_next_cycle_o (l2_victimram_no_acc_next_cycle_o),
    .l2_victimram_clken_o             (l2_victimram_clken_o            ),
    .l2_victimram_en_o                (l2_victimram_en_o               ),
    .l2_victimram_wr_o                (l2_victimram_wr_o               ),
    .l2_victimram_strb_o              (l2_victimram_strb_o             ),
    .l2_victimram_addr_o              (l2_victimram_addr_o             ),
    .l2_victimram_wdata_o             (l2_victimram_wdata_o            ),
    .l2_victimram_rdata_i             (l2_victimram_rdata_i            ),

    .l2_victimram_passed_num1_o       (l2_victimram_passed_num1        ),
    .l2_victimram_passed_num2_o       (l2_victimram_passed_num2        ),
    .l2_victimram_passed_num3_o       (l2_victimram_passed_num3        ),
    .l2_victimram_done_num1_o         (l2_victimram_done_num1          ),
    .l2_victimram_done_num2_o         (l2_victimram_done_num2          ),
    .l2_victimram_done_num3_o         (l2_victimram_done_num3          ),
    .clk                              (CLKIN		               ),
    .reset_n                          (nl2reset 	               ),
    .max_l2_victimram_range           (max_l2victimram_range           ),
    .test_start_i                     (state == START_L2_VICTIMRAM     )
   );
 end else begin : l2_victimram_tieoffs
   assign l2_victimram_no_acc_next_cycle_o = 1'b0;
   assign l2_victimram_clken_o             = 1'b0;
   assign l2_victimram_en_o                = 1'b0;
   assign l2_victimram_wr_o                = 1'b0;
   assign l2_victimram_strb_o              = {`CA53_SCU_L2_VICTIMRAM_STRB_W{1'b0}};
   assign l2_victimram_addr_o              = {`CA53_SCU_L2_VICTIMRAM_ADDR_W{1'b0}};
   assign l2_victimram_wdata_o             = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
   assign l2_victimram_rdata_i             = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
 end
 endgenerate

 // ---------------------------------
 // State Machine for Print messages
 // ---------------------------------
 
 //Generate a pulse again to start L1D test for CLKEN
 assign l1d_clken_chk_en = (l1d_tests_completed & ~clken_chk) | start_l1d_clken_chk;
 
 always @(posedge CLKIN or negedge nl2reset) begin
   if(~nl2reset) begin
     start_l1d_clken_chk <= 1'b0;
     clken_chk           <= 1'b0;
   end else if (l1d_clken_chk_en) begin
     start_l1d_clken_chk <= ~start_l1d_clken_chk;
     clken_chk           <= 1'b1;
   end
 end
   
 assign debug = 0;
 assign l2_tests_completed = L2_CACHE ? l2_dataram_done_num1   & l2_dataram_done_num2   & l2tagram_done_num1 & l2tagram_done_num2 &
                                        l2_victimram_done_num1 & l2_victimram_done_num2 & l2_victimram_done_num3 : 1'b1;

 always@*
   case (NUM_CPUS)
     1     : l1d_tests_completed = l1dtagram_done_cpu0_num1 & l1dtagram_done_cpu0_num2;
     2     : l1d_tests_completed = l1dtagram_done_cpu0_num1 & l1dtagram_done_cpu0_num2 &
                                   l1dtagram_done_cpu1_num1 & l1dtagram_done_cpu1_num2;
     3     : l1d_tests_completed = l1dtagram_done_cpu0_num1 & l1dtagram_done_cpu0_num2 &
                                   l1dtagram_done_cpu1_num1 & l1dtagram_done_cpu1_num2 &
                                   l1dtagram_done_cpu2_num1 & l1dtagram_done_cpu2_num2;
     4     : l1d_tests_completed = l1dtagram_done_cpu0_num1 & l1dtagram_done_cpu0_num2 &
                                   l1dtagram_done_cpu1_num1 & l1dtagram_done_cpu1_num2 &
                                   l1dtagram_done_cpu2_num1 & l1dtagram_done_cpu2_num2 &
                                   l1dtagram_done_cpu3_num1 & l1dtagram_done_cpu3_num2;
   default : l1d_tests_completed = 1'bx;
  endcase

 always@*
   case (NUM_CPUS)
     1     : all_l1d_tests_completed = l1d_tests_completed & l1dtagram_done_cpu0_clken_num1 & l1dtagram_done_cpu0_clken_num2;
     2     : all_l1d_tests_completed = l1d_tests_completed & l1dtagram_done_cpu0_clken_num1 & l1dtagram_done_cpu0_clken_num2 &
                                                             l1dtagram_done_cpu1_clken_num1 & l1dtagram_done_cpu1_clken_num2;
     3     : all_l1d_tests_completed = l1d_tests_completed & l1dtagram_done_cpu0_clken_num1 & l1dtagram_done_cpu0_clken_num2 &
                                                             l1dtagram_done_cpu1_clken_num1 & l1dtagram_done_cpu1_clken_num2 &
                                                             l1dtagram_done_cpu2_clken_num1 & l1dtagram_done_cpu2_clken_num2;
     4     : all_l1d_tests_completed = l1d_tests_completed & l1dtagram_done_cpu0_clken_num1 & l1dtagram_done_cpu0_clken_num2 &
                                                             l1dtagram_done_cpu1_clken_num1 & l1dtagram_done_cpu1_clken_num2 &
                                                             l1dtagram_done_cpu2_clken_num1 & l1dtagram_done_cpu2_clken_num2 &
                                                             l1dtagram_done_cpu3_clken_num1 & l1dtagram_done_cpu3_clken_num2;
   default : all_l1d_tests_completed = 1'bx;
  endcase
  
 assign all_tests_completed = l2_tests_completed & all_l1d_tests_completed;
 
 assign l2_tests_passed = L2_CACHE ? l2_dataram_passed_num1   & l2_dataram_passed_num2   & l2tagram_passed_num1 & l2tagram_passed_num2  &
                                     l2_victimram_passed_num1 & l2_victimram_passed_num2 & l2_victimram_passed_num3 : 1'b1;

 always@*
   case (NUM_CPUS)
     1     : all_l1d_tests_passed = l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num1 & l1dtagram_passed_cpu0_clken_num2;
     2     : all_l1d_tests_passed = l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num1 & l1dtagram_passed_cpu0_clken_num2 &
                                    l1dtagram_passed_cpu1_num1 & l1dtagram_passed_cpu1_num2 & l1dtagram_passed_cpu1_clken_num1 & l1dtagram_passed_cpu1_clken_num2;
     3     : all_l1d_tests_passed = l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num1 & l1dtagram_passed_cpu0_clken_num2 &
                                    l1dtagram_passed_cpu1_num1 & l1dtagram_passed_cpu1_num2 & l1dtagram_passed_cpu1_clken_num1 & l1dtagram_passed_cpu1_clken_num2 &
                                    l1dtagram_passed_cpu2_num1 & l1dtagram_passed_cpu2_num2 & l1dtagram_passed_cpu2_clken_num1 & l1dtagram_passed_cpu2_clken_num2;
     4     : all_l1d_tests_passed = l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num1 & l1dtagram_passed_cpu0_clken_num2 &
                                    l1dtagram_passed_cpu1_num1 & l1dtagram_passed_cpu1_num2 & l1dtagram_passed_cpu1_clken_num1 & l1dtagram_passed_cpu1_clken_num2 &
                                    l1dtagram_passed_cpu2_num1 & l1dtagram_passed_cpu2_num2 & l1dtagram_passed_cpu2_clken_num1 & l1dtagram_passed_cpu2_clken_num2 &
                                    l1dtagram_passed_cpu3_num1 & l1dtagram_passed_cpu3_num2 & l1dtagram_passed_cpu3_clken_num1 & l1dtagram_passed_cpu3_clken_num2;
   default : all_l1d_tests_passed = 1'bx;
  endcase

assign all_tests_passed = l2_tests_passed & all_l1d_tests_passed;

 always @*
    case (print_state)
      PRINT_IDLE         : print_next_state = nl2reset ? PRINT_HEADER : PRINT_IDLE;
      PRINT_HEADER       : print_next_state = WAIT_FOR_DONE;
      WAIT_FOR_DONE      : print_next_state = all_tests_completed ? PRINT_L2_DATARAM : WAIT_FOR_DONE;
      PRINT_L2_DATARAM   : print_next_state = PRINT_L2_TAGRAM;
      PRINT_L2_TAGRAM    : print_next_state = PRINT_L1D_CPU0;
      PRINT_L1D_CPU0     : print_next_state = PRINT_L1D_CPU1;
      PRINT_L1D_CPU1     : print_next_state = PRINT_L1D_CPU2;
      PRINT_L1D_CPU2     : print_next_state = PRINT_L1D_CPU3;
      PRINT_L1D_CPU3     : print_next_state = PRINT_L2_VICTIMRAM;
      PRINT_L2_VICTIMRAM : print_next_state = PRINT_FINISH;
      PRINT_FINISH       : print_next_state = PRINT_FINISH;
      default            : print_next_state = PRINT_IDLE;
    endcase

    //Registering the print next stage
   always @(posedge CLKIN or negedge nl2reset)
    if (!nl2reset) begin
      print_state <= PRINT_IDLE;
    end else begin
      print_state <= print_next_state;
    end

  //Needs Printing in individual States
   always @(print_state) begin
     if (print_state == PRINT_HEADER) begin
       $display ("\n");
       $display ("--------- Starting L2 RAM Test ---------");
       $display ("----------------------------------------");
       if (L2_CACHE == 1) begin
         $display (" - Size of L2     %s ", l2_size_str);
       end
       $display (" - Size of L1-Dup %s ", l1d_size_str);
       $display ("\n");
     end else if (print_state == PRINT_L2_DATARAM & L2_CACHE == 1) begin

         if (debug == 1) begin
           case (l2_dataram_passed_num1)
             1'b0 : $display ("Test1 of L2  DataRam = FAILED");
             1'b1 : $display ("Test1 of L2  DataRam = PASSED");
           endcase
           case (l2_dataram_passed_num2)
             1'b0 : $display ("Test2 of L2  DataRam = FAILED");
             1'b1 : $display ("Test2 of L2  DataRam = PASSED");
           endcase
         end

         case (l2_dataram_passed_num1 & l2_dataram_passed_num2)
            1'b0 :  $display ("Status of L2  DataRam         = FAILED ");
            1'b1 :  $display ("Status of L2  DataRam         = PASSED ");
         endcase

     end else if (print_state == PRINT_L2_TAGRAM & L2_CACHE == 1) begin

         if (debug == 1) begin
           case (l2tagram_passed_num1)
             1'b0 : $display ("Test1 of L2  TagRam = FAILED");
             1'b1 : $display ("Test1 of L2  TagRam = PASSED");
           endcase
           case (l2tagram_passed_num2)
             1'b0 : $display ("Test2 of L2  TagRam = FAILED");
             1'b1 : $display ("Test2 of L2  TagRam = PASSED");
           endcase
         end

         case (l2tagram_passed_num1 & l2tagram_passed_num2)
            1'b0 :  $display ("Status of L2  TagRam          = FAILED ");
            1'b1 :  $display ("Status of L2  TagRam          = PASSED ");
         endcase

     end else if (print_state == PRINT_L2_VICTIMRAM & L2_CACHE == 1) begin

         if (debug == 1) begin
           case (l2_victimram_passed_num1)
             1'b0 : $display ("Test1 of L2 VictimRam = FAILED");
             1'b1 : $display ("Test1 of L2 VictimRam = PASSED");
           endcase
           case (l2_victimram_passed_num2)
             1'b0 : $display ("Test2 of L2 VictimRam = FAILED");
             1'b1 : $display ("Test2 of L2 VictimRam = PASSED");
           endcase
           case (l2_victimram_passed_num3)
             1'b0 : $display ("Test3 of L2 VictimRam = FAILED");
             1'b1 : $display ("Test3 of L2 VictimRam = PASSED");
           endcase
         end

         case (l2_victimram_passed_num1 & l2_victimram_passed_num2 & l2_victimram_passed_num3)
            1'b0 :  $display ("Status of L2 VictimRam        = FAILED ");
            1'b1 :  $display ("Status of L2 VictimRam        = PASSED ");
         endcase

     end else if (print_state == PRINT_L1D_CPU0) begin

         if (debug == 1) begin
           case (l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_clken_num1)
             1'b0 : $display ("Test1 of L1-Dup TagRam CPU 0 = FAILED");
             1'b1 : $display ("Test1 of L1-Dup TagRam CPU 0 = PASSED");
           endcase
           case (l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num2)
             1'b0 : $display ("Test2 of L1-Dup TagRam CPU 0 = FAILED");
             1'b1 : $display ("Test2 of L1-Dup TagRam CPU 0 = PASSED");
           endcase
         end

         case (l1dtagram_passed_cpu0_num1 & l1dtagram_passed_cpu0_num2 & l1dtagram_passed_cpu0_clken_num1 & l1dtagram_passed_cpu0_clken_num2)
            1'b0 :  $display ("Status of L1-Dup TagRam CPU 0 = FAILED ");
            1'b1 :  $display ("Status of L1-Dup TagRam CPU 0 = PASSED ");
         endcase

     end else if (print_state == PRINT_L1D_CPU1 & NUM_CPUS >= 2) begin

         if (debug == 1) begin
           case (l1dtagram_passed_cpu1_num1 & l1dtagram_passed_cpu1_clken_num1)
             1'b0 : $display ("Test1 of L1-Dup TagRam CPU 1 = FAILED");
             1'b1 : $display ("Test1 of L1-Dup TagRam CPU 1 = PASSED");
           endcase
           case (l1dtagram_passed_cpu1_num2 & l1dtagram_passed_cpu1_clken_num2)
             1'b0 : $display ("Test2 of L1-Dup TagRam CPU 1 = FAILED");
             1'b1 : $display ("Test2 of L1-Dup TagRam CPU 1 = PASSED");
           endcase
         end

         case (l1dtagram_passed_cpu1_num1 & l1dtagram_passed_cpu1_num2 & l1dtagram_passed_cpu1_clken_num1 & l1dtagram_passed_cpu1_clken_num2)
            1'b0 :  $display ("Status of L1-Dup TagRam CPU 1 = FAILED ");
            1'b1 :  $display ("Status of L1-Dup TagRam CPU 1 = PASSED ");
         endcase

     end else if (print_state == PRINT_L1D_CPU2 & NUM_CPUS >= 3) begin

         if (debug == 1) begin
           case (l1dtagram_passed_cpu2_num1 & l1dtagram_passed_cpu2_clken_num1)
             1'b0 : $display ("Test1 of L1-Dup TagRam CPU 2 = FAILED");
             1'b1 : $display ("Test1 of L1-Dup TagRam CPU 2 = PASSED");
           endcase
           case (l1dtagram_passed_cpu2_num2 & l1dtagram_passed_cpu2_clken_num2)
             1'b0 : $display ("Test2 of L1-Dup TagRam CPU 2 = FAILED");
             1'b1 : $display ("Test2 of L1-Dup TagRam CPU 2 = PASSED");
           endcase
         end

         case (l1dtagram_passed_cpu2_num1 & l1dtagram_passed_cpu2_num2 & l1dtagram_passed_cpu2_clken_num1 & l1dtagram_passed_cpu2_clken_num2)
            1'b0 :  $display ("Status of L1-Dup TagRam CPU 2 = FAILED ");
            1'b1 :  $display ("Status of L1-Dup TagRam CPU 2 = PASSED ");
         endcase

     end else if (print_state == PRINT_L1D_CPU3 & NUM_CPUS >= 4) begin

         if (debug == 1) begin
           case (l1dtagram_passed_cpu3_num1 & l1dtagram_passed_cpu3_clken_num1)
             1'b0 : $display ("Test1 of L1-Dup TagRam CPU 3 = FAILED");
             1'b1 : $display ("Test1 of L1-Dup TagRam CPU 3 = PASSED");
           endcase
           case (l1dtagram_passed_cpu3_num2 & l1dtagram_passed_cpu3_clken_num2)
             1'b0 : $display ("Test2 of L1-Dup TagRam CPU 3 = FAILED");
             1'b1 : $display ("Test2 of L1-Dup TagRam CPU 3 = PASSED");
           endcase
         end

         case (l1dtagram_passed_cpu3_num1 & l1dtagram_passed_cpu3_num2 & l1dtagram_passed_cpu3_clken_num1 & l1dtagram_passed_cpu3_clken_num2)
            1'b0 :  $display ("Status of L1-Dup TagRam CPU 3 = FAILED ");
            1'b1 :  $display ("Status of L1-Dup TagRam CPU 3 = PASSED ");
         endcase
     end else if (print_state == PRINT_FINISH & L2_CACHE == 1) begin
          $display ("\n");
          case (all_tests_passed)
            1'b1 : $display ("NO ERRORS found in L1-Dup & L2 RAM Test !!!");
            1'b0 : begin
                    $display ("========================================");
                    $display ("ERRORS FOUND IN L1-Dup or L2 RAM Test!!!");
                    $display ("========================================");
                    $finish;
                   end
          endcase
      end else if (print_state == PRINT_FINISH & L2_CACHE == 0) begin
          $display ("\n");
          case (all_tests_passed)
            1'b1 : $display ("NO ERRORS found in L1-Dup RAM Test !!!");
            1'b0 : begin
                    $display ("==================================");
                    $display ("ERRORS FOUND IN L1-Dup RAM Test!!!");
                    $display ("==================================");
                    $finish;
                   end
          endcase
      end
  end


endmodule // ca53_l2noram

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
