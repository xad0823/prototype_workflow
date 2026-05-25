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
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Top level of the CortexA53 CPU (without RAMs)
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53_noram `CA53_NORAM_PARAM_DECL (
  // Clock Signal
  input  wire                                  clk,
  // Reset Signals
  input  wire                                  reset_n_cpu,
  input  wire                                  po_reset_n_cpu,
  // Test Signals
  input  wire                                  DFTSE,
  input  wire                                  DFTRSTDISABLE,
  input  wire                                  DFTRAMHOLD,
  // SCU: Address Request Channel
  output wire                                  biu_ar_active_o,
  input  wire                                  scu_ar_credit_i,
  input  wire                                  scu_ar_block_i,
  output wire                                  biu_ar_valid_o,
  output wire [4:0]                            biu_ar_id_o,
  output wire [4:0]                            biu_ar_type_o,
  output wire [7:0]                            biu_ar_attrs_o,
  output wire [4:0]                            biu_ar_way_o,
  output wire [40:0]                           biu_ar_addr_o,
  output wire [1:0]                            biu_ar_len_o,
  output wire [2:0]                            biu_ar_size_o,
  output wire                                  biu_ar_lock_o,
  output wire                                  biu_ar_priv_o,
  // SCU: Data/Response Channel
  output wire                                  biu_dr_credit_o,
  input  wire                                  scu_dr_valid_i,
  input  wire [4:0]                            scu_dr_id_i,
  input  wire [5:0]                            scu_dr_resp_i,
  input  wire [1:0]                            scu_dr_chunk_i,
  input  wire [127:0]                          scu_dr_data_i,
  input  wire                                  scu_rr_valid_i,
  input  wire [4:0]                            scu_rr_id_i,
  input  wire [1:0]                            scu_rr_resp_i,
  input  wire [3:0]                            scu_rr_l2db_id_i,
  input  wire [7:0]                            scu_ev_done_i,
  // SCU: Write Data Channel
  output wire                                  biu_dw_valid_o,
  output wire [3:0]                            biu_dw_l2db_id_o,
  output wire [3:0]                            biu_dw_chunks_valid_o,
  output wire                                  biu_dw_last_o,
  output wire [31:0]                           biu_dw_strb_o,
  output wire [255:0]                          biu_dw_data_o,
  output wire                                  biu_dw_err_o,
  output wire                                  biu_dw_fatal_o,
  // SCU: Write Response Channel
  input  wire                                  scu_db_excl_valid_i,
  input  wire [1:0]                            scu_db_excl_resp_i,
  input  wire                                  scu_db_decerr_i,
  input  wire                                  scu_db_slverr_i,
  // SCU: Coherency Address Channel
  input  wire                                  scu_ac_valid_i,
  output wire                                  dcu_ac_ready_o,
  input  wire [2:0]                            scu_ac_id_i,
  input  wire [3:0]                            scu_ac_l2db_id_i,
  input  wire [3:0]                            scu_ac_snoop_i,
  input  wire [40:0]                           scu_ac_addr_i,
  input  wire [3:0]                            scu_ac_way_i,
  // SCU: Coherency Response Channel
  output wire                                  dcu_cr_valid_o,
  output wire [2:0]                            dcu_cr_id_o,
  output wire                                  dcu_cr_dirty_o,
  output wire                                  dcu_cr_age_o,
  output wire                                  dcu_cr_alloc_o,
  output wire                                  dcu_cr_migratory_o,
  // SCU: Misc
  input  wire [7:0]                            scu_reqbufs_busy_i,
  output wire                                  dcu_dvm_complete_o,
  input  wire                                  scu_dvm_complete_i,
  input  wire                                  scu_drain_stb_i,
  input  wire                                  scu_leave_ramode_i,
  // SCU performance monitor events
  input  wire                                  scu_evnt_l2_access_i,
  input  wire                                  scu_evnt_l2_refill_i,
  input  wire                                  scu_evnt_l2_wb_i,
  input  wire                                  scu_evnt_snooped_data_i,
  input  wire                                  scu_evnt_bus_cycle_i,
  input  wire                                  scu_evnt_bus_acc_rd_i,
  input  wire                                  scu_evnt_bus_acc_wr_i,
  input  wire                                  scu_evnt_eviction_i,
  // Interrupt related signals
  input  wire                                  gic_irq_i,
  input  wire                                  gic_fiq_i,
  input  wire                                  gic_virq_i,
  input  wire                                  gic_vfiq_i,
  input  wire                                  gov_sei_level_req_i,
  input  wire                                  gov_vsei_level_req_i,
  input  wire                                  gov_rei_level_req_i,
  input  wire                                  gov_int_active_i,
  input  wire                                  gic_icc_sre_el1_ns_sre_i,
  input  wire                                  gic_icc_sre_el1_s_sre_i,
  input  wire                                  gic_icc_sre_el2_enable_i,
  input  wire                                  gic_icc_sre_el2_sre_i,
  input  wire                                  gic_icc_sre_el3_enable_i,
  input  wire                                  gic_icc_sre_el3_sre_i,
  input  wire                                  gic_ich_hcr_el2_tall0_i,
  input  wire                                  gic_ich_hcr_el2_tall1_i,
  input  wire                                  gic_ich_hcr_el2_tc_i,
  // Outputs
  output wire [1:0]                            dpu_exception_level_o,
  output wire                                  dpu_aarch64_at_el3_o,
  output wire                                  dpu_dscr_halted_o,
  output wire                                  dpu_hcr_el2_fmo_o,
  output wire                                  dpu_hcr_el2_imo_o,
  output wire                                  dpu_hcr_el2_amo_o,
  output wire                                  dpu_monitor_mode_o,
  output wire                                  dpu_rei_level_ack_o,
  output wire                                  dpu_scr_el3_fiq_o,
  output wire                                  dpu_scr_el3_irq_o,
  output wire                                  dpu_scr_el3_ns_o,
  output wire                                  dpu_sei_level_ack_o,
  output wire                                  dpu_vsei_level_ack_o,
  output wire                                  dpu_wfi_req_o,
  output wire                                  dpu_wfe_req_o,
  output wire                                  dpu_irq_pended_o,
  output wire                                  dpu_fiq_pended_o,
  output wire                                  dpu_sei_pended_o,
  output wire                                  dpu_irq_masked_o,
  output wire                                  dpu_fiq_masked_o,
  output wire                                  dpu_sei_masked_o,
  output wire                                  dpu_virq_pended_o,
  output wire                                  dpu_vfiq_pended_o,
  output wire                                  dpu_vsei_pended_o,
  output wire                                  dpu_virq_masked_o,
  output wire                                  dpu_vfiq_masked_o,
  output wire                                  dpu_vsei_masked_o,
  output wire                                  dpu_dbg_double_lock_set_o,
  output wire                                  dpu_ns_state_o,
  output wire                                  stb_wfx_ready_o,
  output wire                                  biu_wfx_ready_o,
  output wire                                  dcu_wfx_ready_o,
  output wire                                  ifu_wfx_ready_o,
  output wire                                  tlb_wfx_ready_o,
  output wire                                  etm_wfx_ready_o,
  output wire                                  dpu_imp_abort_pending_o,
  // Retention Control Interface
  output wire [2:0]                            dpu_cpuectlr_cpu_ret_delay_o,
  output wire [2:0]                            dpu_cpuectlr_neon_ret_delay_o,
  output wire                                  dpu_neon_active_o,
  input  wire                                  gov_stall_neon_i,
  // Debug APB Interface
  input  wire                                  gov_pseldbg_dbg_i,
  input  wire                                  gov_pseldbg_pmu_i,
  input  wire                                  gov_pseldbg_etm_i,
  input  wire [11:2]                           gov_paddrdbg_i,
  input  wire                                  gov_paddrdbg31_i,
  input  wire                                  gov_penabledbg_i,
  output wire [31:0]                           dpu_prdatadbg_o,
  output wire [31:0]                           etm_prdatadbg_o,
  input  wire [31:0]                           gov_pwdatadbg_i,
  output wire                                  dpu_preadydbg_o,
  output wire                                  etm_preadydbg_o,
  output wire                                  dpu_pslverrdbg_o,
  input  wire                                  gov_pwritedbg_i,
  input  wire                                  gov_etmpdsr_rd_i,
  // Debug Miscellaneous Signals
  input  wire                                  gov_dbgen_i,
  input  wire                                  gov_spiden_i,
  input  wire                                  gov_niden_i,
  input  wire                                  gov_spniden_i,
  output wire                                  dpu_dbgack_o,
  input  wire                                  gov_edbgrq_i,
  output wire                                  dpu_dbgtrigger_o,
  output wire                                  dpu_commrx_o,
  output wire                                  dpu_commtx_o,
  output wire                                  dpu_ncommirq_o,
  input  wire                                  gov_dbgrestart_i,
  output wire                                  dpu_dbgrstreq_o,
  output wire                                  dpu_dbgnopwrdwn_o,
  input  wire [39:12]                          gov_dbgromaddr_i,
  input  wire                                  gov_dbgromaddrv_i,
  input  wire                                  gov_dbgpwrupreq_i,
  input  wire                                  gov_dbgl1rstdisable_i,
  input  wire                                  gov_edecr_osuce_i,
  input  wire                                  gov_edecr_rce_i,
  input  wire                                  gov_edecr_ss_i,
  input  wire                                  gov_edlsr_slk_i,
  input  wire                                  gov_pmlsr_slk_i,
  input  wire [(`CA53_ETMEXT_W-1):0]           gov_extin_i,
  output wire [(`CA53_ETMEXT_W-1):0]           etm_extout_o,
  output wire                                  etm_oslock_o,
  // DCU-GOV Misc
  output wire                                  dcu_excl_mon_cleared_o,
  // DCU-GOV CP15 signals
  output wire [(`CA53_CPADDR_W-1):0]           dcu_cp_gov_addr_o,
  output wire                                  dcu_cp_gov_ns_o,
  output wire                                  dcu_cp_gov_req_o,
  output wire [(`CA53_CPSEL_W-1):0]            dcu_cp_gov_sel_o,
  output wire [(`CA53_CPDATA_W-1):0]           dcu_cp_gov_wdata_o,
  output wire                                  dcu_cp_gov_wenable_o,
  input  wire                                  gov_cp_ack_i,
  input  wire [(`CA53_CPDATA_W-1):0]           gov_cp_rdata_i,
  input  wire                                  gov_stall_dsb_i,
  // ETM ATB Interface
  input  wire                                  gov_atclken_i,
  input  wire                                  gov_atreadym_i,
  input  wire                                  gov_afvalidm_i,
  output wire [(`CA53_ATDATAM_W-1):0]          etm_atdatam_o,
  output wire                                  etm_atvalidm_o,
  output wire [(`CA53_ATBYTESM_W-1):0]         etm_atbytesm_o,
  output wire                                  etm_afreadym_o,
  output wire [(`CA53_ATIDM_W-1):0]            etm_atidm_o,
  input  wire                                  gov_syncreqm_i,
  // Architectural Timers Interface
  input  wire [63:0]                           gov_tsvalueb_i,
  input  wire                                  gov_pcnt_kernel_access_i,
  input  wire                                  gov_pcnt_usr_access_i,
  input  wire                                  gov_vcnt_usr_access_i,
  input  wire                                  gov_cntp_usr_access_i,
  input  wire                                  gov_cntv_usr_access_i,
  input  wire                                  gov_cntp_kernel_access_i,
  // Miscellaneous Signals
  output wire                                  dpu_warmrstreq_o,
  input  wire [39:2]                           gov_rvbaraddr_i,
  input  wire                                  gov_aa64naa32_i,
  input  wire                                  gov_cryptodisable_i,
  input  wire                                  gov_cp15sdisable_i,
  input  wire                                  gov_cfgend_i,
  input  wire                                  gov_vinithi_i,
  input  wire                                  gov_cfgte_i,
  input  wire [7:0]                            gov_clusteridaff1_i,
  input  wire [7:0]                            gov_clusteridaff2_i,
  input  wire [1:0]                            cpu_id_i,
  input  wire [3:0]                            ctr_cwg_i,
  input  wire [3:0]                            ctr_erg_i,
  input  wire [39:18]                          gov_periphbase_i,
  input  wire                                  gov_giccdisable_i,
  input  wire                                  gov_mbist_req_i,
  output wire                                  dpu_smp_en_o,
  input  wire                                  gov_event_reg_i,
  input  wire                                  gov_wfx_drain_req_i,
  input  wire                                  gov_wfx_wake_i,
  input  wire                                  gov_standbywfi_i,
  input  wire                                  gov_standbywfe_i,
  output wire                                  dpu_sev_req_o,
  output wire                                  dpu_clr_event_register_o,
  output wire                                  dpu_npmuirq_o,
  input  wire [3:0]                            l2_size_i,
  input  wire [2:0]                            ic_size_i,
  input  wire [2:0]                            dc_size_i,
  input  wire                                  scu_broadcastinner_i,
  // Core Trace Interface
  output wire [25:0]                           dpu_pmuevent_o,
  // Data rams for DCache - 8 banks of rams (with byte enable)
  output wire [7:0]                            dc_dataram_en_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb0_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb1_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb2_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb3_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb4_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb5_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb6_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb7_o,
  output wire                                  dc_dataram_wr_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata0_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata1_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata2_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata3_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata4_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata5_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata6_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata7_o,
  output wire [10:0]                           dc_dataram_addr0_o,
  output wire [10:0]                           dc_dataram_addr1_o,
  output wire [10:0]                           dc_dataram_addr2_o,
  output wire [10:0]                           dc_dataram_addr3_o,
  output wire [10:0]                           dc_dataram_addr4_o,
  output wire [10:0]                           dc_dataram_addr5_o,
  output wire [10:0]                           dc_dataram_addr6_o,
  output wire [10:0]                           dc_dataram_addr7_o,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata0_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata1_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata2_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata3_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata4_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata5_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata6_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata7_i,
  // Tag rams for DCache - 4 banks of rams (with global enable)
  output wire [3:0]                            dc_tagram_en_o,
  output wire                                  dc_tagram_wr_o,
  output wire [(`CA53_DTAG_RAM_W-1):0]         dc_tagram_wdata_o,
  output wire [7:0]                            dc_tagram_addr_o,
  input  wire [(`CA53_DTAG_RAM_W-1):0]         dc_tagram_rdata0_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]         dc_tagram_rdata1_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]         dc_tagram_rdata2_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]         dc_tagram_rdata3_i,
  // Dirty ram for DCache - 1 bank of ram (with bit enable)
  output wire                                  dc_dirtyram_en_o,
  output wire                                  dc_dirtyram_wr_o,
  output wire [(`CA53_DDIRTY_RAM_W-1):0]       dc_dirtyram_strb_o,
  output wire [(`CA53_DDIRTY_RAM_W-1):0]       dc_dirtyram_wdata_o,
  output wire [8:0]                            dc_dirtyram_addr_o,
  input  wire [(`CA53_DDIRTY_RAM_W-1):0]       dc_dirtyram_rdata_i,
  // Data rams for ICache - 2 banks of rams (with byte enable)
  output wire [3:0]                            ic_dataram_en_o,
  output wire                                  ic_dataram_wr_o,
  output wire [(`CA53_IDATA_WEN_W-1):0]        ic_dataram_strb0_o,
  output wire [(`CA53_IDATA_WEN_W-1):0]        ic_dataram_strb1_o,
  output wire [(`CA53_IDATA_RAM_W-1):0]        ic_dataram_wdata0_o,
  output wire [(`CA53_IDATA_RAM_W-1):0]        ic_dataram_wdata1_o,
  output wire [11:0]                           ic_dataram_addr0_o,
  output wire [11:0]                           ic_dataram_addr1_o,
  input  wire [(`CA53_IDATA_RAM_W-1):0]        ic_dataram_rdata0_i,
  input  wire [(`CA53_IDATA_RAM_W-1):0]        ic_dataram_rdata1_i,
  // Tag rams for ICache - 2 banks of rams (with global enable)
  output wire [1:0]                            ic_tagram_en_o,
  output wire                                  ic_tagram_wr_o,
  output wire [(`CA53_ITAG_RAM_W-1):0]         ic_tagram_wdata_o,
  output wire [8:0]                            ic_tagram_addr_o,
  input  wire [(`CA53_ITAG_RAM_W-1):0]         ic_tagram_rdata0_i,
  input  wire [(`CA53_ITAG_RAM_W-1):0]         ic_tagram_rdata1_i,
  // RAM Interface for the TLB - 2 banks of rams
  output wire [3:0]                            tlb_ram_en_o,
  output wire                                  tlb_ram_wr_o,
  output wire [(`CA53_TLB_RAM_ADDR_W-1):0]     tlb_ram_addr_o,
  output wire [(`CA53_TLB_RAM_W-1):0]          tlb_ram_wdata_o,
  input  wire [(`CA53_TLB_RAM_W-1):0]          tlb_ram_rdata0_i,
  input  wire [(`CA53_TLB_RAM_W-1):0]          tlb_ram_rdata1_i,
  input  wire [(`CA53_TLB_RAM_W-1):0]          tlb_ram_rdata2_i,
  input  wire [(`CA53_TLB_RAM_W-1):0]          tlb_ram_rdata3_i,
  // RAM Interface for the BTAC - 3 banks of rams (with global enable)
  input  wire [(`CA53_BTAC_RAM_S0D_W-1):0]     btac_stg0_ram_rdata_i,
  input  wire [(`CA53_BTAC_RAM_S1D_W-1):0]     btac_stg1_ram_rdata_i,
  output wire                                  btac_stg0_ram_en_o,
  output wire                                  btac_stg0_ram_wr_o,
  output wire [(`CA53_BTAC_RAM_S0D_W-1):0]     btac_stg0_ram_wdata_o,
  output wire [(`CA53_BTAC_RAM_ADDR_W-1):0]    btac_stg0_ram_addr_o,
  output wire                                  btac_stg1_ram_en_o,
  output wire                                  btac_stg1_ram_wr_o,
  output wire [(`CA53_BTAC_RAM_S1D_W-1):0]     btac_stg1_ram_wdata_o,
  output wire [(`CA53_BTAC_RAM_ADDR_W-1):0]    btac_stg1_ram_addr_o
  );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire                          [39:4] biu_alloc_addr_m0;
  wire                           [7:0] biu_alloc_attrs_m1;
  wire                         [255:0] biu_alloc_data_m0;
  wire                                 biu_alloc_data_req_m0;
  wire                                 biu_alloc_dirty_age_m1;
  wire                           [1:0] biu_alloc_dirty_moesi_m1;
  wire                                 biu_alloc_dirty_req_m0;
  wire                                 biu_alloc_halfline_m0;
  wire                                 biu_alloc_ns_dsc_m0;
  wire                           [1:0] biu_alloc_tag_moesi_m0;
  wire                                 biu_alloc_tag_req_m0;
  wire                           [3:0] biu_alloc_way_m0;
  wire                          [40:0] biu_ar_addr;
  wire                           [7:0] biu_ar_attrs;
  wire                           [4:0] biu_ar_id;
  wire                           [1:0] biu_ar_len;
  wire                                 biu_ar_lock;
  wire                           [2:0] biu_ar_size;
  wire                           [4:0] biu_ar_type;
  wire                                 biu_ar_valid;
  wire                           [4:0] biu_ar_way;
  wire                                 biu_ccb_lf_hazard;
  wire                                 biu_dirty_lf_in_progress;
  wire                                 biu_dr_credit;
  wire                         [255:0] biu_dw_data;
  wire                                 biu_dw_last;
  wire                          [31:0] biu_dw_strb;
  wire                                 biu_dw_valid;
  wire                                 biu_ecc_cinv_ack;
  wire                                 biu_ecc_cinv_complete;
  wire                           [4:0] biu_ev_hazard;
  wire                           [1:0] biu_evnt_ext_mem_req;
  wire                           [1:0] biu_evnt_ext_mem_req_nc;
  wire                                 biu_evnt_pf_lf;
  wire                                 biu_evnt_ramode;
  wire                                 biu_evnt_ramode_enter;
  wire                                 biu_evnt_rw_lf;
  wire                                 biu_excl_lf_in_progress;
  wire                                 biu_i_arready;
  wire                           [1:0] biu_i_rchunk;
  wire                         [127:0] biu_i_rdata;
  wire                           [1:0] biu_i_rid;
  wire                           [2:0] biu_i_rresp;
  wire                                 biu_i_rvalid;
  wire                           [4:0] biu_lf_can_merge;
  wire                           [4:0] biu_lf_hazard;
  wire                           [4:0] biu_lf_hazard_migratory;
  wire                           [1:0] biu_lf_hazard_way_slot0;
  wire                           [1:0] biu_lf_hazard_way_slot1;
  wire                           [1:0] biu_lf_hazard_way_slot2;
  wire                           [1:0] biu_lf_hazard_way_slot3;
  wire                           [1:0] biu_lf_hazard_way_slot4;
  wire                           [7:0] biu_lf_in_progress;
  wire                                 biu_lf_next_ready_dc3;
  wire                                 biu_lf_ready_dc2;
  wire                           [4:0] biu_lf_real_hazard;
  wire                           [4:0] biu_lf_serialized;
  wire                          [52:0] biu_mbist_in_data_hi_mb3;
  wire                           [3:0] biu_pf_in_progress;
  wire                          [39:6] biu_pf_tag_addr_m0;
  wire                                 biu_pf_tag_ns_dsc_m0;
  wire                                 biu_pf_tag_req_m0;
  wire                                 biu_pld_l2_next_ready;
  wire                                 biu_read_abort_dc2;
  wire                                 biu_read_abort_dc3;
  wire                                 biu_read_alloc_mode;
  wire                          [63:0] biu_read_data_dc2;
  wire                          [63:0] biu_read_data_dc3;
  wire                                 biu_read_data_valid_dc2;
  wire                                 biu_read_data_valid_dc3;
  wire                           [1:0] biu_read_fault_dc2;
  wire                           [1:0] biu_read_fault_dc3;
  wire                                 biu_stb_ar_ack;
  wire                           [1:0] biu_stb_ar_resp;
  wire                           [4:0] biu_stb_ar_resp_id;
  wire                           [3:0] biu_stb_ar_resp_l2dbid;
  wire                                 biu_stb_ar_resp_valid;
  wire                                 biu_stb_write_accept;
  wire                           [1:0] biu_strex_bresp;
  wire                                 biu_strex_bresp_valid;
  wire                                 biu_suppress_load_hit_dc2;
  wire                                 biu_suppress_tlb_hit;
  wire                                 biu_w_imp_abort;
  wire                           [1:0] biu_w_imp_fault;
  wire                                 biu_walk_ack;
  wire                          [63:0] biu_walk_data;
  wire                                 biu_walk_lf_hazard;
  wire                           [2:0] biu_walk_resp;
  wire                          [10:0] dc_dataram_addr0;
  wire                          [10:0] dc_dataram_addr1;
  wire                          [10:0] dc_dataram_addr2;
  wire                          [10:0] dc_dataram_addr3;
  wire                          [10:0] dc_dataram_addr4;
  wire                          [10:0] dc_dataram_addr5;
  wire                          [10:0] dc_dataram_addr6;
  wire                          [10:0] dc_dataram_addr7;
  wire                           [7:0] dc_dataram_en;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb0;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb1;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb2;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb3;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb4;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb5;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb6;
  wire       [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb7;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata0;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata1;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata2;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata3;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata4;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata5;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata6;
  wire       [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata7;
  wire                                 dc_dataram_wr;
  wire                           [8:0] dc_dirtyram_addr;
  wire                                 dc_dirtyram_en;
  wire      [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_strb;
  wire      [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_wdata;
  wire                                 dc_dirtyram_wr;
  wire                           [7:0] dc_tagram_addr;
  wire                           [3:0] dc_tagram_en;
  wire        [(`CA53_DTAG_RAM_W-1):0] dc_tagram_wdata;
  wire                                 dc_tagram_wr;
  wire                                 dcu_alloc_ack_m1;
  wire                                 dcu_alloc_has_priority_m0;
  wire                           [7:0] dcu_attrs_dc1;
  wire                           [7:0] dcu_attrs_dc2;
  wire                           [7:0] dcu_attrs_dc3;
  wire                                 dcu_biu_active;
  wire                                 dcu_biu_req_dc2;
  wire                                 dcu_biu_req_dc3;
  wire                                 dcu_block_lookups;
  wire                                 dcu_cache_walk_ack_m1;
  wire                          [63:0] dcu_cache_walk_data_m2;
  wire                                 dcu_cache_walk_has_priority_m0;
  wire                                 dcu_cache_walk_hit_m2;
  wire                           [3:0] dcu_cache_walk_victim_way_m2;
  wire                          [13:6] dcu_ccb_index;
  wire                                 dcu_ccb_req_active;
  wire                                 dcu_ccb_req_valid;
  wire                           [3:0] dcu_ccb_ways;
  wire                                 dcu_cm_operation_dc3;
  wire                          [39:0] dcu_cp_addr_ifu;
  wire                          [61:0] dcu_cp_addr_tlb;
  wire                                 dcu_cp_ns;
  wire                           [2:0] dcu_cp_op_ifu;
  wire                           [4:0] dcu_cp_op_tlb;
  wire                          [63:0] dcu_cp_reg_data;
  wire                           [5:0] dcu_cp_reg_en_dc2;
  wire                           [5:0] dcu_cp_reg_en_dc3;
  wire                                 dcu_cp_reg_size;
  wire                                 dcu_cp_reg_write_active;
  wire                                 dcu_cp_reg_write_dc3;
  wire                                 dcu_cp_valid_ifu;
  wire                                 dcu_cp_valid_tlb;
  wire                                 dcu_dbg_dsb_ack;
  wire                                 dcu_drain_entire_stb;
  wire                           [4:0] dcu_drain_slots;
  wire                                 dcu_drain_stb_lf;
  wire                                 dcu_dvm_sync_needed_dc3;
  wire                                 dcu_dvm_valid_ifu;
  wire                           [7:0] dcu_ecc_cinv_index;
  wire                                 dcu_ecc_cinv_req;
  wire                           [1:0] dcu_ecc_cinv_way;
  wire                                 dcu_ecc_data_err_m3;
  wire                                 dcu_ecc_err_dc3;
  wire                                 dcu_ecc_err_m3;
  wire                                 dcu_ecc_fatal;
  wire                                 dcu_ecc_fatal_m3;
  wire                                 dcu_ecc_in_progress;
  wire                          [10:0] dcu_ecc_index;
  wire                           [1:0] dcu_ecc_ramid;
  wire                          [55:0] dcu_ecc_syndrome_m3;
  wire                                 dcu_ecc_tag_err_m2;
  wire                                 dcu_ecc_tag_err_m3;
  wire                                 dcu_ecc_valid;
  wire                           [2:0] dcu_ecc_way_bank_id;
  wire                                 dcu_evnt_dc_access;
  wire                                 dcu_exclusive_dc2;
  wire                                 dcu_exclusive_dc3;
  wire                                 dcu_exclusive_monitor;
  wire                                 dcu_force_non_mergeable_dc3;
  wire                          [63:0] dcu_ld_data_dc3;
  wire                                 dcu_leaving_dc1;
  wire                                 dcu_leaving_dc2;
  wire                           [3:0] dcu_length_dc2;
  wire                           [3:0] dcu_length_dc3;
  wire                                 dcu_lf_active;
  wire                                 dcu_lf_req_dc1;
  wire                                 dcu_lf_req_dc2;
  wire                                 dcu_lf_req_dc3;
  wire                           [1:0] dcu_lf_way_dc1;
  wire                           [1:0] dcu_lf_way_dc2;
  wire                           [1:0] dcu_lf_way_dc3;
  wire                                 dcu_load_dc1;
  wire                                 dcu_load_dc2;
  wire                                 dcu_load_dc3;
  wire                           [4:0] dcu_load_sameline_dc3;
  wire                           [8:0] dcu_mbist_array_mb3;
  wire                           [6:0] dcu_mbist_data_checkbits_mb6;
  wire                          [63:0] dcu_mbist_out_data_mb6;
  wire                                 dcu_neon_access_dc3;
  wire                                 dcu_ns_dsc_dc2;
  wire                                 dcu_ns_dsc_dc3;
  wire                                 dcu_ongoing_burst_dc1;
  wire                                 dcu_p_abort_dc3;
  wire                                 dcu_p_direction_dc3;
  wire                           [3:0] dcu_p_domain_dc3;
  wire                           [6:0] dcu_p_fault_dc3;
  wire                           [1:0] dcu_p_fault_stage_dc3;
  wire                          [39:0] dcu_pa_dc2;
  wire                          [39:0] dcu_pa_dc3;
  wire                                 dcu_pf_tag_ack_m1;
  wire                                 dcu_pf_tag_has_priority_m0;
  wire                                 dcu_pf_tag_hit_m2;
  wire                                 dcu_pipe_valid_dc3;
  wire                                 dcu_pld_l2_req_dc2;
  wire                                 dcu_pld_l2_req_dc3;
  wire                                 dcu_pldw_dc3;
  wire                                 dcu_priv_dc1;
  wire                                 dcu_priv_dc3;
  wire                                 dcu_ready_cp_iss;
  wire                                 dcu_ready_iss;
  wire                           [1:0] dcu_size_dc2;
  wire                           [1:0] dcu_size_dc3;
  wire                           [1:0] dcu_snoop_chunk_m2;
  wire                         [255:0] dcu_snoop_data_m2;
  wire                                 dcu_snoop_dw_active;
  wire                           [3:0] dcu_snoop_l2db_id_m2;
  wire                                 dcu_snoop_last_m2;
  wire                           [1:0] dcu_snoop_rotate_m2;
  wire                                 dcu_snoop_valid_m2;
  wire                           [7:0] dcu_stb_attrs_dc3;
  wire                                 dcu_stb_data_ack_m1;
  wire                                 dcu_stb_data_has_priority_m0;
  wire                                 dcu_stb_exclusive_dc3;
  wire                         [127:0] dcu_stb_read_data_m2;
  wire                                 dcu_stb_req_dc3;
  wire                                 dcu_stb_tag_ack_m1;
  wire                                 dcu_stb_tag_has_priority_m0;
  wire                           [3:0] dcu_stb_tag_hit_m2;
  wire                                 dcu_stb_tag_migratory_m2;
  wire                                 dcu_stb_tag_shared_m2;
  wire                           [3:0] dcu_stb_victim_way_m2;
  wire                                 dcu_stlr_dc3;
  wire                                 dcu_stop_pf;
  wire                          [15:0] dcu_store_bls_dc3;
  wire                                 dcu_store_cp15_dc3;
  wire                                 dcu_store_dc1;
  wire                                 dcu_store_dc2;
  wire                                 dcu_store_dc3;
  wire                                 dcu_store_dmb_dc3;
  wire                                 dcu_store_dsb_dc3;
  wire                                 dcu_store_last_dc3;
  wire                           [4:0] dcu_store_merge_dc3;
  wire                           [4:0] dcu_store_sameline_dc3;
  wire                                 dcu_strex_okay_dc3;
  wire                           [2:0] dcu_transl_type_dc1;
  wire                                 dcu_v2p_lpae_dc3;
  wire                          [63:0] dcu_va_dc3;
  wire                                 dcu_va_valid_dc1;
  wire                                 dcu_va_valid_early_dc1;
  wire                                 dcu_valid_dc2;
  wire                                 dcu_valid_dc3;
  wire                                 dcu_wpt_check_512_dc1;
  wire                                 dcu_wpt_hit_dc3;
  wire                           [3:1] dpu_aarch64_at_el;
  wire                                 dpu_aarch64_state;
  wire                                 dpu_abort_dc1;
  wire                                 dpu_access_flag_enable_el1;
  wire                                 dpu_access_flag_enable_el3;
  wire                          [48:6] dpu_agu_a_operand_iss;
  wire                          [48:6] dpu_agu_b_operand_iss;
  wire                                 dpu_agu_carry_out_64b_iss;
  wire                           [2:0] dpu_align_size_iss;
  wire                                 dpu_apb_active;
  wire                          [12:0] dpu_attributes_dc1;
  wire                          [12:3] dpu_br_addr_ex2;
  wire                                 dpu_br_call_wr;
  wire                                 dpu_br_return_wr;
  wire                                 dpu_br_taken_wr;
  wire                                 dpu_btac_ret;
  wire                                 dpu_burst_iss;
  wire                                 dpu_cc_fail_wr;
  wire                                 dpu_clear_excl_mon;
  wire                          [63:0] dpu_cp_data_wr;
  wire                           [8:0] dpu_cp_op_iss;
  wire                                 dpu_cross_64_iss;
  wire                          [31:0] dpu_dacr;
  wire                                 dpu_data_prefetch_stride_detect;
  wire                          [11:2] dpu_dbg_addr;
  wire                                 dpu_dbg_dsb_req;
  wire                          [31:0] dpu_dbg_ins;
  wire                                 dpu_dbg_sample_contextid;
  wire                                 dpu_dbg_tlb_hw_bkpt_wpt_en;
  wire                                 dpu_dbg_tlb_sw_bkpt_wpt_en;
  wire                                 dpu_dbg_valid;
  wire                           [3:0] dpu_dbg_vid;
  wire                          [31:0] dpu_dbg_wdata;
  wire                                 dpu_dbg_wr;
  wire                                 dpu_dcache_on;
  wire                                 dpu_dcache_on_el1;
  wire                                 dpu_dcache_on_el2;
  wire                                 dpu_dcache_on_el3;
  wire                                 dpu_default_cacheable;
  wire                                 dpu_disable_data_prefetch_readunique;
  wire                                 dpu_disable_data_prefetch_stores_pattern;
  wire                                 dpu_disable_device_split_throttle;
  wire                                 dpu_l1deien;
  wire                                 dpu_disable_dmb;
  wire                                 dpu_disable_no_allocate;
  wire                           [3:0] dpu_domain_dc1;
  wire                           [2:0] dpu_enable_data_prefetch;
  wire                           [1:0] dpu_enable_data_prefetch_streams;
  wire                                 dpu_endian_el1;
  wire                                 dpu_endian_el2;
  wire                                 dpu_endian_el3;
  wire                                 dpu_excl_iss;
  wire                                 dpu_expt_catch_pending;
  wire                           [8:0] dpu_fault_dc1;
  wire                          [63:0] dpu_fe_addr_opa_ret;
  wire                          [48:1] dpu_fe_addr_opa_wr;
  wire                          [17:1] dpu_fe_addr_opb_ret;
  wire                          [27:1] dpu_fe_addr_opb_wr;
  wire                                 dpu_fe_context_sync_ret;
  wire                           [1:0] dpu_fe_isa_ret;
  wire                           [1:0] dpu_fe_isa_wr;
  wire                           [7:0] dpu_fe_itstate_ret;
  wire                                 dpu_fe_valid_ret;
  wire                                 dpu_fe_valid_wr;
  wire                                 dpu_first_iss;
  wire                                 dpu_flush;
  wire                                 dpu_flush_i_utlb;
  wire                                 dpu_force_first_iss;
  wire                                 dpu_halt_ifu;
  wire                                 dpu_hivecs;
  wire                                 dpu_icache_on;
  wire                                 dpu_ipa_to_pa_en;
  wire                                 dpu_iq_full;
  wire                                 dpu_iq_part_full;
  wire                                 dpu_kill_wr;
  wire                                 dpu_ldar_stlr_iss;
  wire                           [4:0] dpu_length_iss;
  wire                           [3:0] dpu_level_dc1;
  wire                                 dpu_lpae_dc1;
  wire                                 dpu_mispred_wr;
  wire                                 dpu_mmu_on;
  wire                                 dpu_mmu_on_el1;
  wire                                 dpu_mmu_on_el2;
  wire                                 dpu_mmu_on_el3;
  wire                           [4:0] dpu_mode_iss;
  wire                          [31:5] dpu_mon_vec_base_dc1;
  wire                                 dpu_neon_access_iss;
  wire                                 dpu_non_temporal_iss;
  wire                                 dpu_ns_dsc_dc1;
  wire                                 dpu_ns_state;
  wire                         [39:12] dpu_pa_dc1;
  wire                          [21:0] dpu_periphbase;
  wire                                 dpu_pld_iss;
  wire                                 dpu_pld_level_iss;
  wire                                 dpu_pr_tablewalk;
  wire                                 dpu_pred_br_ex2;
  wire                                 dpu_pred_br_wr;
  wire                                 dpu_priv_iss;
  wire                           [1:0] dpu_ramode_cnt_l1;
  wire                           [1:0] dpu_ramode_cnt_l2;
  wire                                 dpu_ready_cc_fail_wr;
  wire                                 dpu_ready_cc_pass_wr;
  wire                                 dpu_ready_wr;
  wire                                 dpu_req_align_iss;
  wire                                 dpu_reset_catch_pending;
  wire                                 dpu_s2_dcache_on;
  wire                                 dpu_scr_el3_ns;
  wire                                 dpu_sctlr_itd;
  wire                                 dpu_sctlr_uwxn_el1;
  wire                                 dpu_sctlr_uwxn_el3;
  wire                                 dpu_sctlr_wxn_el1;
  wire                                 dpu_sctlr_wxn_el2;
  wire                                 dpu_sctlr_wxn_el3;
  wire                                 dpu_second_x64_iss;
  wire                                 dpu_sif_only;
  wire                           [1:0] dpu_size_iss;
  wire                         [127:0] dpu_st_data_wr;
  wire                                 dpu_stack_align_expt_dc1;
  wire                                 dpu_store_iss;
  wire                          [15:0] dpu_strobe_iss;
  wire                                 dpu_tex_remap_enable_el1;
  wire                                 dpu_tex_remap_enable_el3;
  wire                                 dpu_throttle_enable;
  wire                                 dpu_tlb_abandon;
  wire                                 dpu_utlb_hit_dc1;
  wire                           [3:0] dpu_utlb_hit_entry_dc1;
  wire                          [63:0] dpu_va_dc1;
  wire                                 dpu_valid_cp_iss;
  wire                                 dpu_valid_iss;
  wire                          [31:5] dpu_vec_base_ns_dc1;
  wire                          [31:5] dpu_vec_base_s_dc1;
  wire                          [63:1] dpu_wpt_addr;
  wire                                 dpu_wpt_advance;
  wire                           [3:0] dpu_wpt_exception_type;
  wire                           [3:0] dpu_wpt_exlevel;
  wire                                 dpu_wpt_link;
  wire                                 dpu_wpt_non_secure;
  wire                                 dpu_wpt_prohibited;
  wire                                 dpu_wpt_range;
  wire                                 dpu_wpt_t32_nt16;
  wire                                 dpu_wpt_taken;
  wire                          [63:1] dpu_wpt_target_addr_opa;
  wire                          [27:1] dpu_wpt_target_addr_opb;
  wire                           [1:0] dpu_wpt_target_isa;
  wire                           [2:0] dpu_wpt_type;
  wire                                 dpu_wpt_valid;
  wire                                 etm_if_en;
  wire                                 etm_stall_cpu;
  wire                          [11:0] ic_dataram_addr0;
  wire                          [11:0] ic_dataram_addr1;
  wire                           [3:0] ic_dataram_en;
  wire       [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0;
  wire       [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1;
  wire       [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0;
  wire       [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1;
  wire                                 ic_dataram_wr;
  wire                           [8:0] ic_tagram_addr;
  wire                           [1:0] ic_tagram_en;
  wire        [(`CA53_ITAG_RAM_W-1):0] ic_tagram_wdata;
  wire                                 ic_tagram_wr;
  wire                          [39:0] ifu_araddr;
  wire                           [1:0] ifu_arid;
  wire                           [1:0] ifu_arlen;
  wire                           [1:0] ifu_arprot;
  wire                                 ifu_arvalid;
  wire                           [7:0] ifu_attrs;
  wire                                 ifu_cp_ack;
  wire                          [31:0] ifu_cp_dbg_0;
  wire                          [31:0] ifu_cp_dbg_1;
  wire                                 ifu_cp_dbg_valid;
  wire                                 ifu_dbg_ready;
  wire                                 ifu_early_two_valid_if3;
  wire                                 ifu_evnt_ic_access;
  wire                                 ifu_evnt_ic_lf;
  wire                                 ifu_evnt_ic_miss_wait;
  wire                                 ifu_evnt_iutlb_miss_wait;
  wire                                 ifu_evnt_pdc_valid;
  wire                                 ifu_evnt_throttle;
  wire                          [27:0] ifu_hpfar;
  wire                          [31:1] ifu_ifar;
  wire                           [6:0] ifu_ifsr;
  wire                                 ifu_ifsr_lpae;
  wire                           [1:0] ifu_ifsr_stage2;
  wire                          [47:0] ifu_instr0_if3;
  wire                          [47:0] ifu_instr1_if3;
  wire                           [1:0] ifu_instr_valid_if3;
  wire       [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6;
  wire                           [2:0] ifu_outstanding_lfb;
  wire                          [48:0] ifu_pred_addr_if4;
  wire                                 ifu_pred_addr_valid_if4;
  wire                          [11:0] ifu_pty_index;
  wire                                 ifu_pty_ramid;
  wire                                 ifu_pty_valid;
  wire                                 ifu_pty_way_bank_id;
  wire                                 ifu_rready;
  wire                                 ifu_utlb_miss_req;
  wire                          [63:0] ifu_va_if2;
  wire                                 ifu_valid_if2;
  wire                                 po_reset_n;
  wire                                 reset_n;
  wire                          [39:0] stb_ar_addr;
  wire                          [15:0] stb_ar_asid;
  wire                           [7:0] stb_ar_attrs;
  wire                                 stb_ar_early_req;
  wire                                 stb_ar_excl;
  wire                           [4:0] stb_ar_id;
  wire                                 stb_ar_ns_dsc;
  wire                                 stb_ar_priv;
  wire                                 stb_ar_req;
  wire                           [7:0] stb_ar_type;
  wire                          [24:0] stb_ar_va;
  wire                           [7:0] stb_ar_vmid;
  wire                           [1:0] stb_ar_way;
  wire                                 stb_attr_mismatch_dc2;
  wire                          [15:0] stb_biu_write_bls;
  wire                           [1:0] stb_biu_write_chunk;
  wire                         [127:0] stb_biu_write_data;
  wire                           [3:0] stb_biu_write_l2dbid;
  wire                                 stb_biu_write_last;
  wire                                 stb_biu_write_req;
  wire                                 stb_biu_write_req_active;
  wire                                 stb_block_ccb;
  wire                                 stb_block_loads_dc1;
  wire                          [13:4] stb_cache_data_addr_m0;
  wire                           [7:0] stb_cache_data_attrs_m0;
  wire                          [15:0] stb_cache_data_bls_m0;
  wire                                 stb_cache_data_migratory_m0;
  wire                                 stb_cache_data_req_m0;
  wire                           [3:0] stb_cache_data_way_m0;
  wire                                 stb_cache_data_wr_m0;
  wire                          [39:6] stb_cache_tag_addr_m0;
  wire                                 stb_cache_tag_ns_dsc_m0;
  wire                                 stb_cache_tag_req_m0;
  wire                           [3:0] stb_cache_tag_way_m0;
  wire                                 stb_cache_tag_wr_m0;
  wire                         [127:0] stb_cache_write_data_m0;
  wire                                 stb_cacheable_strex_done;
  wire                           [4:0] stb_can_merge_dc2;
  wire                          [63:0] stb_data_dc2;
  wire                                 stb_defer_ccb;
  wire                                 stb_evnt_stb_stall;
  wire                                 stb_force_non_mergeable;
  wire                           [7:0] stb_hit_dc2;
  wire                                 stb_lf_active;
  wire                           [4:0] stb_lf_earliest_slot;
  wire                           [4:0] stb_lf_merge;
  wire                           [4:0] stb_lf_req;
  wire                           [4:0] stb_load_sameline_dc2;
  wire                           [4:0] stb_sameline_dc2;
  wire                          [39:0] stb_slot0_addr;
  wire                           [7:0] stb_slot0_attrs;
  wire                           [1:0] stb_slot0_way;
  wire                          [39:0] stb_slot1_addr;
  wire                           [7:0] stb_slot1_attrs;
  wire                           [1:0] stb_slot1_way;
  wire                          [39:0] stb_slot2_addr;
  wire                           [7:0] stb_slot2_attrs;
  wire                           [1:0] stb_slot2_way;
  wire                          [39:0] stb_slot3_addr;
  wire                           [7:0] stb_slot3_attrs;
  wire                           [1:0] stb_slot3_way;
  wire                          [39:0] stb_slot4_addr;
  wire                           [7:0] stb_slot4_attrs;
  wire                           [1:0] stb_slot4_way;
  wire                           [4:0] stb_slot_cachewrite_m1;
  wire                           [4:0] stb_slots_dev_ng;
  wire                           [4:0] stb_slots_dsb;
  wire                           [4:0] stb_slots_emptying;
  wire                           [4:0] stb_slots_ns_dsc;
  wire                           [4:0] stb_slots_valid;
  wire                                 stb_strex_failed;
  wire                           [3:0] tlb_bkpt_hit_if2;
  wire                          [39:3] tlb_cache_walk_addr;
  wire                           [1:0] tlb_cache_walk_lookup_req_m0;
  wire                                 tlb_cache_walk_ns_dsc;
  wire                          [31:0] tlb_context_id;
  wire                                 tlb_cp_ack;
  wire                          [63:0] tlb_cp_read_data_dc2;
  wire                                 tlb_cp_reg_write_ready;
  wire                           [1:0] tlb_d_tcr_el1_tbi;
  wire                                 tlb_d_tcr_el2_tbi0;
  wire                                 tlb_d_tcr_el3_tbi0;
  wire                          [95:0] tlb_d_utlb_data;
  wire                                 tlb_d_utlb_enable;
  wire                                 tlb_d_utlb_flush;
  wire                                 tlb_d_utlb_lpae;
  wire                                 tlb_d_utlb_might_enable;
  wire                                 tlb_d_utlb_valid;
  wire                          [31:0] tlb_dbg_rdata;
  wire                                 tlb_evnt_data_pagewalk;
  wire                                 tlb_evnt_instr_pagewalk;
  wire                          [96:0] tlb_i_utlb_data;
  wire                                 tlb_i_utlb_enable;
  wire                                 tlb_i_utlb_flush;
  wire                                 tlb_i_utlb_lpae;
  wire                                 tlb_i_utlb_might_enable;
  wire                                 tlb_i_utlb_valid;
  wire                                 tlb_lpae_mode;
  wire                                 tlb_lpae_mode_s;
  wire                         [116:0] tlb_mbist_out_data_mb6;
  wire                           [1:0] tlb_mem_granule;
  wire                                 tlb_pagewalk_invalidated;
  wire                           [7:0] tlb_pty_index;
  wire                                 tlb_pty_valid;
  wire                           [1:0] tlb_pty_way_bank_id;
  wire    [(`CA53_TLB_RAM_ADDR_W-1):0] tlb_ram_addr;
  wire                           [3:0] tlb_ram_en;
  wire           [`CA53_TLB_RAM_W-1:0] tlb_ram_wdata;
  wire                                 tlb_ram_wr;
  wire                           [1:0] tlb_vcr_hit_if2;
  wire                           [7:0] tlb_vmid;
  wire                          [39:0] tlb_walk_addr;
  wire                           [7:0] tlb_walk_attrs;
  wire                                 tlb_walk_lf_active;
  wire                                 tlb_walk_lf_req;
  wire                                 tlb_walk_nc_req;
  wire                                 tlb_walk_ns_dsc;
  wire                                 tlb_walk_size;
  wire                           [1:0] tlb_walk_way;
  wire                          [15:0] tlb_wpt_hit_dc1;
  /*END*/

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Reset repeater
  // ------------------------------------------------------

  ca53_cpu_reset u_ca53_cpu_rst (
    /*ARMAUTO*/
    // Inputs
    .clk            (clk),
    .DFTRSTDISABLE  (DFTRSTDISABLE),
    .reset_n_cpu    (reset_n_cpu),
    .po_reset_n_cpu (po_reset_n_cpu),
    // Outputs
    .reset_n        (reset_n),
    .po_reset_n     (po_reset_n)
  );  // u_ca53_cpu_rst

  // ------------------------------------------------------
  // DPU
  // ------------------------------------------------------

  ca53dpu `CA53_DPU_PARAM_INST u_ca53dpu (
    /*ARMAUTO*/
    // Inputs
    .clk                                        (clk),
    .reset_n                                    (reset_n),
    .po_reset_n                                 (po_reset_n),
    .DFTSE                                      (DFTSE),
    .biu_evnt_ext_mem_req_i                     (biu_evnt_ext_mem_req[1:0]),
    .biu_evnt_ext_mem_req_nc_i                  (biu_evnt_ext_mem_req_nc[1:0]),
    .biu_evnt_pf_lf_i                           (biu_evnt_pf_lf),
    .biu_evnt_rw_lf_i                           (biu_evnt_rw_lf),
    .biu_evnt_ramode_i                          (biu_evnt_ramode),
    .biu_evnt_ramode_enter_i                    (biu_evnt_ramode_enter),
    .gov_cfgend_i                               (gov_cfgend_i),
    .gov_cp15sdisable_i                         (gov_cp15sdisable_i),
    .gov_dbgen_i                                (gov_dbgen_i),
    .gov_dbgrestart_i                           (gov_dbgrestart_i),
    .gov_dbgromaddrv_i                          (gov_dbgromaddrv_i),
    .gov_dbgromaddr_i                           (gov_dbgromaddr_i[39:12]),
    .gov_edecr_osuce_i                          (gov_edecr_osuce_i),
    .gov_edecr_rce_i                            (gov_edecr_rce_i),
    .gov_edecr_ss_i                             (gov_edecr_ss_i),
    .gov_edlsr_slk_i                            (gov_edlsr_slk_i),
    .gov_pmlsr_slk_i                            (gov_pmlsr_slk_i),
    .gov_dbgpwrupreq_i                          (gov_dbgpwrupreq_i),
    .dc_size_i                                  (dc_size_i[2:0]),
    .biu_w_imp_abort_i                          (biu_w_imp_abort),
    .biu_w_imp_fault_i                          (biu_w_imp_fault[1:0]),
    .etm_if_en_i                                (etm_if_en),
    .etm_stall_cpu_i                            (etm_stall_cpu),
    .ifu_dbg_ready_i                            (ifu_dbg_ready),
    .gov_edbgrq_i                               (gov_edbgrq_i),
    .ic_size_i                                  (ic_size_i[2:0]),
    .l2_size_i                                  (l2_size_i[3:0]),
    .ifu_evnt_ic_lf_i                           (ifu_evnt_ic_lf),
    .ifu_evnt_ic_access_i                       (ifu_evnt_ic_access),
    .ifu_evnt_ic_miss_wait_i                    (ifu_evnt_ic_miss_wait),
    .ifu_evnt_iutlb_miss_wait_i                 (ifu_evnt_iutlb_miss_wait),
    .ifu_evnt_pdc_valid_i                       (ifu_evnt_pdc_valid),
    .ifu_evnt_throttle_i                        (ifu_evnt_throttle),
    .dcu_ecc_err_dc3_i                          (dcu_ecc_err_dc3),
    .dcu_p_fault_dc3_i                          (dcu_p_fault_dc3[6:0]),
    .dcu_p_fault_stage_dc3_i                    (dcu_p_fault_stage_dc3[1:0]),
    .dcu_ld_data_dc3_i                          (dcu_ld_data_dc3[63:0]),
    .dcu_va_dc3_i                               (dcu_va_dc3[63:0]),
    .dcu_pa_dc3_i                               (dcu_pa_dc3[39:12]),
    .dcu_p_abort_dc3_i                          (dcu_p_abort_dc3),
    .dcu_p_domain_dc3_i                         (dcu_p_domain_dc3[3:0]),
    .dcu_p_direction_dc3_i                      (dcu_p_direction_dc3),
    .dcu_cm_operation_dc3_i                     (dcu_cm_operation_dc3),
    .dcu_valid_dc3_i                            (dcu_valid_dc3),
    .dcu_ready_iss_i                            (dcu_ready_iss),
    .dcu_ready_cp_iss_i                         (dcu_ready_cp_iss),
    .dcu_strex_okay_dc3_i                       (dcu_strex_okay_dc3),
    .dcu_v2p_lpae_dc3_i                         (dcu_v2p_lpae_dc3),
    .dcu_wpt_hit_dc3_i                          (dcu_wpt_hit_dc3),
    .dcu_evnt_dc_access_i                       (dcu_evnt_dc_access),
    .dcu_dbg_dsb_ack_i                          (dcu_dbg_dsb_ack),
    .dcu_ecc_fatal_i                            (dcu_ecc_fatal),
    .dcu_ecc_valid_i                            (dcu_ecc_valid),
    .dcu_ecc_ramid_i                            (dcu_ecc_ramid[1:0]),
    .dcu_ecc_way_bank_id_i                      (dcu_ecc_way_bank_id[2:0]),
    .dcu_ecc_index_i                            (dcu_ecc_index[10:0]),
    .gic_fiq_i                                  (gic_fiq_i),
    .gic_vfiq_i                                 (gic_vfiq_i),
    .gic_irq_i                                  (gic_irq_i),
    .gic_virq_i                                 (gic_virq_i),
    .gov_sei_level_req_i                        (gov_sei_level_req_i),
    .gov_vsei_level_req_i                       (gov_vsei_level_req_i),
    .gov_rei_level_req_i                        (gov_rei_level_req_i),
    .gov_int_active_i                           (gov_int_active_i),
    .gic_icc_sre_el1_ns_sre_i                   (gic_icc_sre_el1_ns_sre_i),
    .gic_icc_sre_el1_s_sre_i                    (gic_icc_sre_el1_s_sre_i),
    .gic_icc_sre_el2_enable_i                   (gic_icc_sre_el2_enable_i),
    .gic_icc_sre_el2_sre_i                      (gic_icc_sre_el2_sre_i),
    .gic_icc_sre_el3_enable_i                   (gic_icc_sre_el3_enable_i),
    .gic_icc_sre_el3_sre_i                      (gic_icc_sre_el3_sre_i),
    .gic_ich_hcr_el2_tall0_i                    (gic_ich_hcr_el2_tall0_i),
    .gic_ich_hcr_el2_tall1_i                    (gic_ich_hcr_el2_tall1_i),
    .gic_ich_hcr_el2_tc_i                       (gic_ich_hcr_el2_tc_i),
    .ifu_ifar_i                                 (ifu_ifar[31:1]),
    .ifu_ifsr_i                                 (ifu_ifsr[6:0]),
    .ifu_ifsr_stage2_i                          (ifu_ifsr_stage2[1:0]),
    .ifu_instr0_if3_i                           (ifu_instr0_if3[47:0]),
    .ifu_instr1_if3_i                           (ifu_instr1_if3[47:0]),
    .ifu_instr_valid_if3_i                      (ifu_instr_valid_if3[1:0]),
    .ifu_early_two_valid_if3_i                  (ifu_early_two_valid_if3),
    .ifu_pred_addr_if4_i                        (ifu_pred_addr_if4[48:0]),
    .ifu_pred_addr_valid_if4_i                  (ifu_pred_addr_valid_if4),
    .ifu_ifsr_lpae_i                            (ifu_ifsr_lpae),
    .ifu_hpfar_i                                (ifu_hpfar[27:0]),
    .ifu_pty_valid_i                            (ifu_pty_valid),
    .ifu_pty_ramid_i                            (ifu_pty_ramid),
    .ifu_pty_way_bank_id_i                      (ifu_pty_way_bank_id),
    .ifu_pty_index_i                            (ifu_pty_index[11:0]),
    .gov_niden_i                                (gov_niden_i),
    .gov_spiden_i                               (gov_spiden_i),
    .gov_spniden_i                              (gov_spniden_i),
    .stb_evnt_stb_stall_i                       (stb_evnt_stb_stall),
    .gov_rvbaraddr_i                            (gov_rvbaraddr_i[39:2]),
    .gov_aa64naa32_i                            (gov_aa64naa32_i),
    .gov_cryptodisable_i                        (gov_cryptodisable_i),
    .gov_giccdisable_i                          (gov_giccdisable_i),
    .gov_cfgte_i                                (gov_cfgte_i),
    .tlb_d_utlb_enable_i                        (tlb_d_utlb_enable),
    .tlb_d_utlb_might_enable_i                  (tlb_d_utlb_might_enable),
    .tlb_d_utlb_valid_i                         (tlb_d_utlb_valid),
    .tlb_d_utlb_lpae_i                          (tlb_d_utlb_lpae),
    .tlb_d_utlb_data_i                          (tlb_d_utlb_data[95:0]),
    .tlb_d_utlb_flush_i                         (tlb_d_utlb_flush),
    .tlb_d_tcr_el1_tbi_i                        (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i                       (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i                       (tlb_d_tcr_el3_tbi0),
    .tlb_lpae_mode_i                            (tlb_lpae_mode),
    .tlb_lpae_mode_s_i                          (tlb_lpae_mode_s),
    .tlb_evnt_data_pagewalk_i                   (tlb_evnt_data_pagewalk),
    .tlb_evnt_instr_pagewalk_i                  (tlb_evnt_instr_pagewalk),
    .tlb_pty_valid_i                            (tlb_pty_valid),
    .tlb_pty_way_bank_id_i                      (tlb_pty_way_bank_id[1:0]),
    .tlb_pty_index_i                            (tlb_pty_index[7:0]),
    .gov_vinithi_i                              (gov_vinithi_i),
    .gov_pseldbg_dbg_i                          (gov_pseldbg_dbg_i),
    .gov_pseldbg_pmu_i                          (gov_pseldbg_pmu_i),
    .gov_pwritedbg_i                            (gov_pwritedbg_i),
    .gov_paddrdbg_i                             (gov_paddrdbg_i[11:2]),
    .gov_paddrdbg31_i                           (gov_paddrdbg31_i),
    .gov_pwdatadbg_i                            (gov_pwdatadbg_i[31:0]),
    .tlb_dbg_rdata_i                            (tlb_dbg_rdata[31:0]),
    .gov_clusteridaff2_i                        (gov_clusteridaff2_i[7:0]),
    .gov_clusteridaff1_i                        (gov_clusteridaff1_i[7:0]),
    .cpu_id_i                                   (cpu_id_i[1:0]),
    .ctr_cwg_i                                  (ctr_cwg_i[3:0]),
    .ctr_erg_i                                  (ctr_erg_i[3:0]),
    .gov_event_reg_i                            (gov_event_reg_i),
    .gov_wfx_wake_i                             (gov_wfx_wake_i),
    .gov_stall_neon_i                           (gov_stall_neon_i),
    .scu_evnt_l2_access_i                       (scu_evnt_l2_access_i),
    .scu_evnt_l2_refill_i                       (scu_evnt_l2_refill_i),
    .scu_evnt_l2_wb_i                           (scu_evnt_l2_wb_i),
    .scu_evnt_snooped_data_i                    (scu_evnt_snooped_data_i),
    .scu_evnt_bus_cycle_i                       (scu_evnt_bus_cycle_i),
    .scu_evnt_bus_acc_rd_i                      (scu_evnt_bus_acc_rd_i),
    .scu_evnt_bus_acc_wr_i                      (scu_evnt_bus_acc_wr_i),
    .scu_evnt_eviction_i                        (scu_evnt_eviction_i),
    .gov_periphbase_i                           (gov_periphbase_i[39:18]),
    .gov_pcnt_kernel_access_i                   (gov_pcnt_kernel_access_i),
    .gov_pcnt_usr_access_i                      (gov_pcnt_usr_access_i),
    .gov_vcnt_usr_access_i                      (gov_vcnt_usr_access_i),
    .gov_cntp_usr_access_i                      (gov_cntp_usr_access_i),
    .gov_cntv_usr_access_i                      (gov_cntv_usr_access_i),
    .gov_cntp_kernel_access_i                   (gov_cntp_kernel_access_i),
    // Outputs
    .dpu_commrx_o                               (dpu_commrx_o),
    .dpu_commtx_o                               (dpu_commtx_o),
    .dpu_ncommirq_o                             (dpu_ncommirq_o),
    .dpu_non_temporal_iss_o                     (dpu_non_temporal_iss),
    .dpu_ldar_stlr_iss_o                        (dpu_ldar_stlr_iss),
    .dpu_attributes_dc1_o                       (dpu_attributes_dc1[12:0]),
    .dpu_fault_dc1_o                            (dpu_fault_dc1[8:0]),
    .dpu_l1deien_o                              (dpu_l1deien),
    .dpu_disable_dmb_o                          (dpu_disable_dmb),
    .dpu_disable_device_split_throttle_o        (dpu_disable_device_split_throttle),
    .dpu_enable_data_prefetch_o                 (dpu_enable_data_prefetch[2:0]),
    .dpu_enable_data_prefetch_streams_o         (dpu_enable_data_prefetch_streams[1:0]),
    .dpu_data_prefetch_stride_detect_o          (dpu_data_prefetch_stride_detect),
    .dpu_disable_data_prefetch_stores_pattern_o (dpu_disable_data_prefetch_stores_pattern),
    .dpu_disable_data_prefetch_readunique_o     (dpu_disable_data_prefetch_readunique),
    .dpu_disable_no_allocate_o                  (dpu_disable_no_allocate),
    .dpu_ramode_cnt_l1_o                        (dpu_ramode_cnt_l1[1:0]),
    .dpu_ramode_cnt_l2_o                        (dpu_ramode_cnt_l2[1:0]),
    .dpu_smp_en_o                               (dpu_smp_en_o),
    .dpu_periphbase_o                           (dpu_periphbase[21:0]),
    .dpu_apb_active_o                           (dpu_apb_active),
    .dpu_dbg_dsb_req_o                          (dpu_dbg_dsb_req),
    .dpu_clear_excl_mon_o                       (dpu_clear_excl_mon),
    .dpu_dbg_tlb_sw_bkpt_wpt_en_o               (dpu_dbg_tlb_sw_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_o               (dpu_dbg_tlb_hw_bkpt_wpt_en),
    .dpu_dbg_sample_contextid_o                 (dpu_dbg_sample_contextid),
    .dpu_dbgack_o                               (dpu_dbgack_o),
    .dpu_dbgtrigger_o                           (dpu_dbgtrigger_o),
    .dpu_align_size_iss_o                       (dpu_align_size_iss[2:0]),
    .dpu_pred_br_ex2_o                          (dpu_pred_br_ex2),
    .dpu_br_addr_ex2_o                          (dpu_br_addr_ex2[12:3]),
    .dpu_br_call_wr_o                           (dpu_br_call_wr),
    .dpu_br_return_wr_o                         (dpu_br_return_wr),
    .dpu_br_taken_wr_o                          (dpu_br_taken_wr),
    .dpu_cp_op_iss_o                            (dpu_cp_op_iss[8:0]),
    .dpu_cp_data_wr_o                           (dpu_cp_data_wr[63:0]),
    .dpu_burst_iss_o                            (dpu_burst_iss),
    .dpu_cross_64_iss_o                         (dpu_cross_64_iss),
    .dpu_dcache_on_o                            (dpu_dcache_on),
    .dpu_s2_dcache_on_o                         (dpu_s2_dcache_on),
    .dpu_wpt_valid_o                            (dpu_wpt_valid),
    .dpu_wpt_addr_o                             (dpu_wpt_addr[63:1]),
    .dpu_wpt_target_addr_opa_o                  (dpu_wpt_target_addr_opa[63:1]),
    .dpu_wpt_target_addr_opb_o                  (dpu_wpt_target_addr_opb[27:1]),
    .dpu_wpt_advance_o                          (dpu_wpt_advance),
    .dpu_wpt_range_o                            (dpu_wpt_range),
    .dpu_wpt_type_o                             (dpu_wpt_type[2:0]),
    .dpu_wpt_link_o                             (dpu_wpt_link),
    .dpu_wpt_taken_o                            (dpu_wpt_taken),
    .dpu_wpt_target_isa_o                       (dpu_wpt_target_isa[1:0]),
    .dpu_wpt_t32_nt16_o                         (dpu_wpt_t32_nt16),
    .dpu_wpt_exception_type_o                   (dpu_wpt_exception_type[3:0]),
    .dpu_wpt_non_secure_o                       (dpu_wpt_non_secure),
    .dpu_wpt_exlevel_o                          (dpu_wpt_exlevel[3:0]),
    .dpu_wpt_prohibited_o                       (dpu_wpt_prohibited),
    .dpu_excl_iss_o                             (dpu_excl_iss),
    .dpu_fe_valid_wr_o                          (dpu_fe_valid_wr),
    .dpu_fe_addr_opa_wr_o                       (dpu_fe_addr_opa_wr[48:1]),
    .dpu_fe_addr_opb_wr_o                       (dpu_fe_addr_opb_wr[27:1]),
    .dpu_fe_isa_wr_o                            (dpu_fe_isa_wr[1:0]),
    .dpu_sif_only_o                             (dpu_sif_only),
    .dpu_first_iss_o                            (dpu_first_iss),
    .dpu_force_first_iss_o                      (dpu_force_first_iss),
    .dpu_second_x64_iss_o                       (dpu_second_x64_iss),
    .dpu_neon_access_iss_o                      (dpu_neon_access_iss),
    .dpu_flush_o                                (dpu_flush),
    .dpu_hivecs_o                               (dpu_hivecs),
    .dpu_default_cacheable_o                    (dpu_default_cacheable),
    .dpu_ipa_to_pa_en_o                         (dpu_ipa_to_pa_en),
    .dpu_pr_tablewalk_o                         (dpu_pr_tablewalk),
    .dpu_kill_wr_o                              (dpu_kill_wr),
    .dpu_cc_fail_wr_o                           (dpu_cc_fail_wr),
    .dpu_ready_cc_fail_wr_o                     (dpu_ready_cc_fail_wr),
    .dpu_ready_cc_pass_wr_o                     (dpu_ready_cc_pass_wr),
    .dpu_mispred_wr_o                           (dpu_mispred_wr),
    .dpu_va_dc1_o                               (dpu_va_dc1[63:0]),
    .dpu_pa_dc1_o                               (dpu_pa_dc1[39:12]),
    .dpu_dbg_valid_o                            (dpu_dbg_valid),
    .dpu_dbg_ins_o                              (dpu_dbg_ins[31:0]),
    .dpu_halt_ifu_o                             (dpu_halt_ifu),
    .dpu_pld_iss_o                              (dpu_pld_iss),
    .dpu_pld_level_iss_o                        (dpu_pld_level_iss),
    .dpu_pred_br_wr_o                           (dpu_pred_br_wr),
    .dpu_priv_iss_o                             (dpu_priv_iss),
    .dpu_ready_wr_o                             (dpu_ready_wr),
    .dpu_req_align_iss_o                        (dpu_req_align_iss),
    .dpu_store_iss_o                            (dpu_store_iss),
    .dpu_strobe_iss_o                           (dpu_strobe_iss[15:0]),
    .dpu_utlb_hit_dc1_o                         (dpu_utlb_hit_dc1),
    .dpu_utlb_hit_entry_dc1_o                   (dpu_utlb_hit_entry_dc1[3:0]),
    .dpu_valid_iss_o                            (dpu_valid_iss),
    .dpu_valid_cp_iss_o                         (dpu_valid_cp_iss),
    .dpu_tlb_abandon_o                          (dpu_tlb_abandon),
    .dpu_dbg_vid_o                              (dpu_dbg_vid[3:0]),
    .dpu_mmu_on_o                               (dpu_mmu_on),
    .dpu_mmu_on_el1_o                           (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_o                           (dpu_mmu_on_el2),
    .dpu_mmu_on_el3_o                           (dpu_mmu_on_el3),
    .dpu_dcache_on_el1_o                        (dpu_dcache_on_el1),
    .dpu_dcache_on_el2_o                        (dpu_dcache_on_el2),
    .dpu_dcache_on_el3_o                        (dpu_dcache_on_el3),
    .dpu_sctlr_wxn_el1_o                        (dpu_sctlr_wxn_el1),
    .dpu_sctlr_wxn_el2_o                        (dpu_sctlr_wxn_el2),
    .dpu_sctlr_wxn_el3_o                        (dpu_sctlr_wxn_el3),
    .dpu_sctlr_uwxn_el1_o                       (dpu_sctlr_uwxn_el1),
    .dpu_sctlr_uwxn_el3_o                       (dpu_sctlr_uwxn_el3),
    .dpu_sctlr_itd_o                            (dpu_sctlr_itd),
    .dpu_throttle_enable_o                      (dpu_throttle_enable),
    .dpu_endian_el1_o                           (dpu_endian_el1),
    .dpu_endian_el2_o                           (dpu_endian_el2),
    .dpu_endian_el3_o                           (dpu_endian_el3),
    .dpu_icache_on_o                            (dpu_icache_on),
    .dpu_vec_base_s_dc1_o                       (dpu_vec_base_s_dc1[31:5]),
    .dpu_vec_base_ns_dc1_o                      (dpu_vec_base_ns_dc1[31:5]),
    .dpu_mon_vec_base_dc1_o                     (dpu_mon_vec_base_dc1[31:5]),
    .dpu_ns_dsc_dc1_o                           (dpu_ns_dsc_dc1),
    .dpu_ns_state_o                             (dpu_ns_state),
    .dpu_hcr_el2_fmo_o                          (dpu_hcr_el2_fmo_o),
    .dpu_hcr_el2_imo_o                          (dpu_hcr_el2_imo_o),
    .dpu_hcr_el2_amo_o                          (dpu_hcr_el2_amo_o),
    .dpu_scr_el3_fiq_o                          (dpu_scr_el3_fiq_o),
    .dpu_scr_el3_irq_o                          (dpu_scr_el3_irq_o),
    .dpu_scr_el3_ns_o                           (dpu_scr_el3_ns),
    .dpu_tex_remap_enable_el1_o                 (dpu_tex_remap_enable_el1),
    .dpu_tex_remap_enable_el3_o                 (dpu_tex_remap_enable_el3),
    .dpu_access_flag_enable_el1_o               (dpu_access_flag_enable_el1),
    .dpu_access_flag_enable_el3_o               (dpu_access_flag_enable_el3),
    .dpu_npmuirq_o                              (dpu_npmuirq_o),
    .dpu_iq_full_o                              (dpu_iq_full),
    .dpu_iq_part_full_o                         (dpu_iq_part_full),
    .dpu_size_iss_o                             (dpu_size_iss[1:0]),
    .dpu_st_data_wr_o                           (dpu_st_data_wr[127:0]),
    .dpu_fe_valid_ret_o                         (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_ret_o                      (dpu_fe_addr_opa_ret[63:0]),
    .dpu_fe_addr_opb_ret_o                      (dpu_fe_addr_opb_ret[17:1]),
    .dpu_fe_isa_ret_o                           (dpu_fe_isa_ret[1:0]),
    .dpu_fe_itstate_ret_o                       (dpu_fe_itstate_ret[7:0]),
    .dpu_fe_context_sync_ret_o                  (dpu_fe_context_sync_ret),
    .dpu_btac_ret_o                             (dpu_btac_ret),
    .dpu_mode_iss_o                             (dpu_mode_iss[4:0]),
    .dpu_exception_level_o                      (dpu_exception_level_o[1:0]),
    .dpu_dscr_halted_o                          (dpu_dscr_halted_o),
    .dpu_aarch64_at_el_o                        (dpu_aarch64_at_el[3:1]),
    .dpu_aarch64_state_o                        (dpu_aarch64_state),
    .dpu_monitor_mode_o                         (dpu_monitor_mode_o),
    .dpu_pmuevent_o                             (dpu_pmuevent_o[25:0]),
    .dpu_length_iss_o                           (dpu_length_iss[4:0]),
    .dpu_flush_i_utlb_o                         (dpu_flush_i_utlb),
    .dpu_prdatadbg_o                            (dpu_prdatadbg_o[31:0]),
    .dpu_preadydbg_o                            (dpu_preadydbg_o),
    .dpu_pslverrdbg_o                           (dpu_pslverrdbg_o),
    .dpu_dbg_wr_o                               (dpu_dbg_wr),
    .dpu_dbg_addr_o                             (dpu_dbg_addr[11:2]),
    .dpu_dbg_wdata_o                            (dpu_dbg_wdata[31:0]),
    .dpu_dbgnopwrdwn_o                          (dpu_dbgnopwrdwn_o),
    .dpu_dbgrstreq_o                            (dpu_dbgrstreq_o),
    .dpu_warmrstreq_o                           (dpu_warmrstreq_o),
    .dpu_sev_req_o                              (dpu_sev_req_o),
    .dpu_clr_event_register_o                   (dpu_clr_event_register_o),
    .dpu_wfi_req_o                              (dpu_wfi_req_o),
    .dpu_wfe_req_o                              (dpu_wfe_req_o),
    .dpu_irq_pended_o                           (dpu_irq_pended_o),
    .dpu_fiq_pended_o                           (dpu_fiq_pended_o),
    .dpu_sei_pended_o                           (dpu_sei_pended_o),
    .dpu_irq_masked_o                           (dpu_irq_masked_o),
    .dpu_fiq_masked_o                           (dpu_fiq_masked_o),
    .dpu_sei_masked_o                           (dpu_sei_masked_o),
    .dpu_virq_pended_o                          (dpu_virq_pended_o),
    .dpu_vfiq_pended_o                          (dpu_vfiq_pended_o),
    .dpu_vsei_pended_o                          (dpu_vsei_pended_o),
    .dpu_virq_masked_o                          (dpu_virq_masked_o),
    .dpu_vfiq_masked_o                          (dpu_vfiq_masked_o),
    .dpu_vsei_masked_o                          (dpu_vsei_masked_o),
    .dpu_imp_abort_pending_o                    (dpu_imp_abort_pending_o),
    .dpu_cpuectlr_cpu_ret_delay_o               (dpu_cpuectlr_cpu_ret_delay_o[2:0]),
    .dpu_cpuectlr_neon_ret_delay_o              (dpu_cpuectlr_neon_ret_delay_o[2:0]),
    .dpu_neon_active_o                          (dpu_neon_active_o),
    .dpu_rei_level_ack_o                        (dpu_rei_level_ack_o),
    .dpu_sei_level_ack_o                        (dpu_sei_level_ack_o),
    .dpu_vsei_level_ack_o                       (dpu_vsei_level_ack_o),
    .dpu_dbg_double_lock_set_o                  (dpu_dbg_double_lock_set_o),
    .dpu_dacr_o                                 (dpu_dacr[31:0]),
    .dpu_stack_align_expt_dc1_o                 (dpu_stack_align_expt_dc1),
    .dpu_domain_dc1_o                           (dpu_domain_dc1[3:0]),
    .dpu_abort_dc1_o                            (dpu_abort_dc1),
    .dpu_level_dc1_o                            (dpu_level_dc1[3:0]),
    .dpu_lpae_dc1_o                             (dpu_lpae_dc1),
    .dpu_reset_catch_pending_o                  (dpu_reset_catch_pending),
    .dpu_expt_catch_pending_o                   (dpu_expt_catch_pending),
    .dpu_agu_a_operand_iss_o                    (dpu_agu_a_operand_iss[48:6]),
    .dpu_agu_b_operand_iss_o                    (dpu_agu_b_operand_iss[48:6]),
    .dpu_agu_carry_out_64b_iss_o                (dpu_agu_carry_out_64b_iss)
  );  // u_ca53dpu

  // ------------------------------------------------------
  // IFU
  // ------------------------------------------------------

  ca53ifu `CA53_IFU_PARAM_INST u_ca53ifu (
    /*ARMAUTO*/
    // Inputs
    .clk                        (clk),
    .reset_n                    (reset_n),
    .DFTSE                      (DFTSE),
    .DFTRAMHOLD                 (DFTRAMHOLD),
    .gov_mbist_req_i            (gov_mbist_req_i),
    .dpu_iq_full_i              (dpu_iq_full),
    .dpu_iq_part_full_i         (dpu_iq_part_full),
    .dpu_fe_valid_wr_i          (dpu_fe_valid_wr),
    .dpu_fe_addr_opa_wr_i       (dpu_fe_addr_opa_wr[48:1]),
    .dpu_fe_addr_opb_wr_i       (dpu_fe_addr_opb_wr[27:1]),
    .dpu_fe_isa_wr_i            (dpu_fe_isa_wr[1:0]),
    .dpu_pred_br_ex2_i          (dpu_pred_br_ex2),
    .dpu_br_addr_ex2_i          (dpu_br_addr_ex2[12:3]),
    .dpu_pred_br_wr_i           (dpu_pred_br_wr),
    .dpu_mispred_wr_i           (dpu_mispred_wr),
    .dpu_br_taken_wr_i          (dpu_br_taken_wr),
    .dpu_br_return_wr_i         (dpu_br_return_wr),
    .dpu_br_call_wr_i           (dpu_br_call_wr),
    .dpu_fe_valid_ret_i         (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_ret_i      (dpu_fe_addr_opa_ret[63:0]),
    .dpu_fe_addr_opb_ret_i      (dpu_fe_addr_opb_ret[17:1]),
    .dpu_fe_isa_ret_i           (dpu_fe_isa_ret[1:0]),
    .dpu_fe_itstate_ret_i       (dpu_fe_itstate_ret[7:0]),
    .dpu_fe_context_sync_ret_i  (dpu_fe_context_sync_ret),
    .dpu_btac_ret_i             (dpu_btac_ret),
    .dpu_halt_ifu_i             (dpu_halt_ifu),
    .dpu_mmu_on_i               (dpu_mmu_on),
    .dpu_ipa_to_pa_en_i         (dpu_ipa_to_pa_en),
    .dpu_exception_level_i      (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el[3:1]),
    .dpu_flush_i_utlb_i         (dpu_flush_i_utlb),
    .dpu_dacr_i                 (dpu_dacr[31:0]),
    .dpu_sif_only_i             (dpu_sif_only),
    .dpu_ns_state_i             (dpu_ns_state),
    .dpu_default_cacheable_i    (dpu_default_cacheable),
    .dpu_icache_on_i            (dpu_icache_on),
    .dpu_kill_wr_i              (dpu_kill_wr),
    .dpu_sctlr_itd_i            (dpu_sctlr_itd),
    .dpu_throttle_enable_i      (dpu_throttle_enable),
    .dpu_dbg_ins_i              (dpu_dbg_ins[31:0]),
    .dpu_dbg_valid_i            (dpu_dbg_valid),
    .dpu_reset_catch_pending_i  (dpu_reset_catch_pending),
    .dpu_expt_catch_pending_i   (dpu_expt_catch_pending),
    .tlb_i_utlb_enable_i        (tlb_i_utlb_enable),
    .tlb_i_utlb_might_enable_i  (tlb_i_utlb_might_enable),
    .tlb_i_utlb_valid_i         (tlb_i_utlb_valid),
    .tlb_i_utlb_lpae_i          (tlb_i_utlb_lpae),
    .tlb_i_utlb_data_i          (tlb_i_utlb_data[96:0]),
    .tlb_i_utlb_flush_i         (tlb_i_utlb_flush),
    .tlb_d_tcr_el1_tbi_i        (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i       (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i       (tlb_d_tcr_el3_tbi0),
    .tlb_lpae_mode_i            (tlb_lpae_mode),
    .tlb_bkpt_hit_if2_i         (tlb_bkpt_hit_if2[3:0]),
    .tlb_vcr_hit_if2_i          (tlb_vcr_hit_if2[1:0]),
    .biu_i_arready_i            (biu_i_arready),
    .biu_i_rid_i                (biu_i_rid[1:0]),
    .biu_i_rvalid_i             (biu_i_rvalid),
    .biu_i_rdata_i              (biu_i_rdata[127:0]),
    .biu_i_rresp_i              (biu_i_rresp[2:0]),
    .biu_i_rchunk_i             (biu_i_rchunk[1:0]),
    .dcu_cp_valid_ifu_i         (dcu_cp_valid_ifu),
    .dcu_dvm_valid_ifu_i        (dcu_dvm_valid_ifu),
    .dcu_cp_op_ifu_i            (dcu_cp_op_ifu[2:0]),
    .dcu_cp_addr_ifu_i          (dcu_cp_addr_ifu[39:0]),
    .dcu_cp_ns_i                (dcu_cp_ns),
    .ic_size_i                  (ic_size_i[2:0]),
    .ic_tagram_rdata0_i         (ic_tagram_rdata0_i[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_rdata1_i         (ic_tagram_rdata1_i[(`CA53_ITAG_RAM_W-1):0]),
    .ic_dataram_rdata0_i        (ic_dataram_rdata0_i[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_rdata1_i        (ic_dataram_rdata1_i[(`CA53_IDATA_RAM_W-1):0]),
    .btac_stg0_ram_rdata_i      (btac_stg0_ram_rdata_i[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg1_ram_rdata_i      (btac_stg1_ram_rdata_i[(`CA53_BTAC_RAM_S1D_W-1):0]),
    // Outputs
    .ifu_wfx_ready_o            (ifu_wfx_ready_o),
    .ifu_instr0_if3_o           (ifu_instr0_if3[47:0]),
    .ifu_instr1_if3_o           (ifu_instr1_if3[47:0]),
    .ifu_instr_valid_if3_o      (ifu_instr_valid_if3[1:0]),
    .ifu_early_two_valid_if3_o  (ifu_early_two_valid_if3),
    .ifu_pred_addr_if4_o        (ifu_pred_addr_if4[48:0]),
    .ifu_pred_addr_valid_if4_o  (ifu_pred_addr_valid_if4),
    .ifu_ifar_o                 (ifu_ifar[31:1]),
    .ifu_ifsr_o                 (ifu_ifsr[6:0]),
    .ifu_ifsr_stage2_o          (ifu_ifsr_stage2[1:0]),
    .ifu_ifsr_lpae_o            (ifu_ifsr_lpae),
    .ifu_hpfar_o                (ifu_hpfar[27:0]),
    .ifu_evnt_ic_lf_o           (ifu_evnt_ic_lf),
    .ifu_evnt_ic_access_o       (ifu_evnt_ic_access),
    .ifu_evnt_ic_miss_wait_o    (ifu_evnt_ic_miss_wait),
    .ifu_evnt_iutlb_miss_wait_o (ifu_evnt_iutlb_miss_wait),
    .ifu_evnt_throttle_o        (ifu_evnt_throttle),
    .ifu_evnt_pdc_valid_o       (ifu_evnt_pdc_valid),
    .ifu_dbg_ready_o            (ifu_dbg_ready),
    .ifu_pty_valid_o            (ifu_pty_valid),
    .ifu_pty_ramid_o            (ifu_pty_ramid),
    .ifu_pty_way_bank_id_o      (ifu_pty_way_bank_id),
    .ifu_pty_index_o            (ifu_pty_index[11:0]),
    .ifu_utlb_miss_req_o        (ifu_utlb_miss_req),
    .ifu_outstanding_lfb_o      (ifu_outstanding_lfb[2:0]),
    .ifu_va_if2_o               (ifu_va_if2[63:0]),
    .ifu_cp_dbg_valid_o         (ifu_cp_dbg_valid),
    .ifu_cp_dbg_1_o             (ifu_cp_dbg_1[31:0]),
    .ifu_cp_dbg_0_o             (ifu_cp_dbg_0[31:0]),
    .ifu_arvalid_o              (ifu_arvalid),
    .ifu_arid_o                 (ifu_arid[1:0]),
    .ifu_araddr_o               (ifu_araddr[39:0]),
    .ifu_arlen_o                (ifu_arlen[1:0]),
    .ifu_attrs_o                (ifu_attrs[7:0]),
    .ifu_arprot_o               (ifu_arprot[1:0]),
    .ifu_rready_o               (ifu_rready),
    .ifu_mbist_out_data_mb6_o   (ifu_mbist_out_data_mb6[(`CA53_IDATA_RAM_W-1):0]),
    .ifu_cp_ack_o               (ifu_cp_ack),
    .ifu_valid_if2_o            (ifu_valid_if2),
    .ic_tagram_en_o             (ic_tagram_en[1:0]),
    .ic_tagram_wr_o             (ic_tagram_wr),
    .ic_tagram_wdata_o          (ic_tagram_wdata[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_addr_o           (ic_tagram_addr[8:0]),
    .ic_dataram_en_o            (ic_dataram_en[3:0]),
    .ic_dataram_wr_o            (ic_dataram_wr),
    .ic_dataram_addr0_o         (ic_dataram_addr0[11:0]),
    .ic_dataram_addr1_o         (ic_dataram_addr1[11:0]),
    .ic_dataram_strb0_o         (ic_dataram_strb0[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_strb1_o         (ic_dataram_strb1[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_wdata0_o        (ic_dataram_wdata0[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_wdata1_o        (ic_dataram_wdata1[(`CA53_IDATA_RAM_W-1):0]),
    .btac_stg0_ram_en_o         (btac_stg0_ram_en_o),
    .btac_stg0_ram_wr_o         (btac_stg0_ram_wr_o),
    .btac_stg0_ram_wdata_o      (btac_stg0_ram_wdata_o[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg0_ram_addr_o       (btac_stg0_ram_addr_o[(`CA53_BTAC_RAM_ADDR_W-1):0]),
    .btac_stg1_ram_en_o         (btac_stg1_ram_en_o),
    .btac_stg1_ram_wr_o         (btac_stg1_ram_wr_o),
    .btac_stg1_ram_wdata_o      (btac_stg1_ram_wdata_o[(`CA53_BTAC_RAM_S1D_W-1):0]),
    .btac_stg1_ram_addr_o       (btac_stg1_ram_addr_o[(`CA53_BTAC_RAM_ADDR_W-1):0])
  );  // u_ca53ifu

  // ------------------------------------------------------
  // STB
  // ------------------------------------------------------

  ca53stb `CA53_STB_PARAM_INST u_ca53stb  (
    /*ARMAUTO*/
    // Inputs
    .clk                            (clk),
    .reset_n                        (reset_n),
    .DFTSE                          (DFTSE),
    .dcu_drain_entire_stb_i         (dcu_drain_entire_stb),
    .dcu_drain_slots_i              (dcu_drain_slots[4:0]),
    .dcu_ecc_data_err_m3_i          (dcu_ecc_data_err_m3),
    .dcu_ecc_tag_err_m2_i           (dcu_ecc_tag_err_m2),
    .dcu_ecc_in_progress_i          (dcu_ecc_in_progress),
    .dcu_exclusive_monitor_i        (dcu_exclusive_monitor),
    .dcu_store_dc1_i                (dcu_store_dc1),
    .dcu_valid_dc2_i                (dcu_valid_dc2),
    .dcu_store_dc2_i                (dcu_store_dc2),
    .dcu_pa_dc2_i                   (dcu_pa_dc2[39:3]),
    .dcu_ns_dsc_dc2_i               (dcu_ns_dsc_dc2),
    .dcu_attrs_dc2_i                (dcu_attrs_dc2[7:0]),
    .dcu_leaving_dc2_i              (dcu_leaving_dc2),
    .dcu_store_dc3_i                (dcu_store_dc3),
    .dcu_stb_req_dc3_i              (dcu_stb_req_dc3),
    .dcu_stlr_dc3_i                 (dcu_stlr_dc3),
    .dcu_store_merge_dc3_i          (dcu_store_merge_dc3[4:0]),
    .dcu_store_sameline_dc3_i       (dcu_store_sameline_dc3[4:0]),
    .dcu_load_sameline_dc3_i        (dcu_load_sameline_dc3[4:0]),
    .dcu_pa_dc3_i                   (dcu_pa_dc3[39:0]),
    .dcu_ns_dsc_dc3_i               (dcu_ns_dsc_dc3),
    .dcu_priv_dc3_i                 (dcu_priv_dc3),
    .dcu_stb_exclusive_dc3_i        (dcu_stb_exclusive_dc3),
    .dcu_store_cp15_dc3_i           (dcu_store_cp15_dc3),
    .dcu_dvm_sync_needed_dc3_i      (dcu_dvm_sync_needed_dc3),
    .dcu_store_dmb_dc3_i            (dcu_store_dmb_dc3),
    .dcu_store_dsb_dc3_i            (dcu_store_dsb_dc3),
    .dcu_stb_attrs_dc3_i            (dcu_stb_attrs_dc3[7:0]),
    .dcu_store_bls_dc3_i            (dcu_store_bls_dc3[15:0]),
    .dcu_store_last_dc3_i           (dcu_store_last_dc3),
    .dcu_force_non_mergeable_dc3_i  (dcu_force_non_mergeable_dc3),
    .dcu_stb_tag_has_priority_m0_i  (dcu_stb_tag_has_priority_m0),
    .dcu_stb_tag_ack_m1_i           (dcu_stb_tag_ack_m1),
    .dcu_stb_tag_hit_m2_i           (dcu_stb_tag_hit_m2[3:0]),
    .dcu_stb_tag_shared_m2_i        (dcu_stb_tag_shared_m2),
    .dcu_stb_tag_migratory_m2_i     (dcu_stb_tag_migratory_m2),
    .dcu_stb_victim_way_m2_i        (dcu_stb_victim_way_m2[3:0]),
    .dcu_stb_data_has_priority_m0_i (dcu_stb_data_has_priority_m0),
    .dcu_stb_data_ack_m1_i          (dcu_stb_data_ack_m1),
    .dcu_stb_read_data_m2_i         (dcu_stb_read_data_m2[127:0]),
    .dcu_ccb_req_valid_i            (dcu_ccb_req_valid),
    .dcu_ccb_index_i                (dcu_ccb_index[13:6]),
    .dcu_ccb_ways_i                 (dcu_ccb_ways[3:0]),
    .biu_lf_hazard_i                (biu_lf_hazard[4:0]),
    .biu_lf_real_hazard_i           (biu_lf_real_hazard[4:0]),
    .biu_lf_hazard_migratory_i      (biu_lf_hazard_migratory[4:0]),
    .biu_lf_hazard_way_slot0_i      (biu_lf_hazard_way_slot0[1:0]),
    .biu_lf_hazard_way_slot1_i      (biu_lf_hazard_way_slot1[1:0]),
    .biu_lf_hazard_way_slot2_i      (biu_lf_hazard_way_slot2[1:0]),
    .biu_lf_hazard_way_slot3_i      (biu_lf_hazard_way_slot3[1:0]),
    .biu_lf_hazard_way_slot4_i      (biu_lf_hazard_way_slot4[1:0]),
    .biu_lf_serialized_i            (biu_lf_serialized[4:0]),
    .biu_ev_hazard_i                (biu_ev_hazard[4:0]),
    .biu_lf_can_merge_i             (biu_lf_can_merge[4:0]),
    .biu_stb_write_accept_i         (biu_stb_write_accept),
    .biu_read_alloc_mode_i          (biu_read_alloc_mode),
    .biu_stb_ar_ack_i               (biu_stb_ar_ack),
    .biu_stb_ar_resp_valid_i        (biu_stb_ar_resp_valid),
    .biu_stb_ar_resp_i              (biu_stb_ar_resp[1:0]),
    .biu_stb_ar_resp_id_i           (biu_stb_ar_resp_id[4:0]),
    .biu_stb_ar_resp_l2dbid_i       (biu_stb_ar_resp_l2dbid[3:0]),
    .biu_dirty_lf_in_progress_i     (biu_dirty_lf_in_progress),
    .biu_excl_lf_in_progress_i      (biu_excl_lf_in_progress),
    .dpu_store_iss_i                (dpu_store_iss),
    .dpu_kill_wr_i                  (dpu_kill_wr),
    .dpu_st_data_wr_i               (dpu_st_data_wr[127:0]),
    .dpu_disable_dmb_i              (dpu_disable_dmb),
    .gov_wfx_drain_req_i            (gov_wfx_drain_req_i),
    .scu_dvm_complete_i             (scu_dvm_complete_i),
    .scu_drain_stb_i                (scu_drain_stb_i),
    .dc_size_i                      (dc_size_i[2:0]),
    // Outputs
    .stb_slots_emptying_o           (stb_slots_emptying[4:0]),
    .stb_slots_dev_ng_o             (stb_slots_dev_ng[4:0]),
    .stb_slots_dsb_o                (stb_slots_dsb[4:0]),
    .stb_block_loads_dc1_o          (stb_block_loads_dc1),
    .stb_cacheable_strex_done_o     (stb_cacheable_strex_done),
    .stb_strex_failed_o             (stb_strex_failed),
    .stb_can_merge_dc2_o            (stb_can_merge_dc2[4:0]),
    .stb_sameline_dc2_o             (stb_sameline_dc2[4:0]),
    .stb_load_sameline_dc2_o        (stb_load_sameline_dc2[4:0]),
    .stb_attr_mismatch_dc2_o        (stb_attr_mismatch_dc2),
    .stb_hit_dc2_o                  (stb_hit_dc2[7:0]),
    .stb_data_dc2_o                 (stb_data_dc2[63:0]),
    .stb_force_non_mergeable_o      (stb_force_non_mergeable),
    .stb_cache_tag_req_m0_o         (stb_cache_tag_req_m0),
    .stb_cache_tag_wr_m0_o          (stb_cache_tag_wr_m0),
    .stb_cache_tag_way_m0_o         (stb_cache_tag_way_m0[3:0]),
    .stb_cache_tag_addr_m0_o        (stb_cache_tag_addr_m0[39:6]),
    .stb_cache_tag_ns_dsc_m0_o      (stb_cache_tag_ns_dsc_m0),
    .stb_cache_data_req_m0_o        (stb_cache_data_req_m0),
    .stb_cache_data_wr_m0_o         (stb_cache_data_wr_m0),
    .stb_cache_data_addr_m0_o       (stb_cache_data_addr_m0[13:4]),
    .stb_cache_data_way_m0_o        (stb_cache_data_way_m0[3:0]),
    .stb_cache_data_bls_m0_o        (stb_cache_data_bls_m0[15:0]),
    .stb_cache_data_attrs_m0_o      (stb_cache_data_attrs_m0[7:0]),
    .stb_cache_data_migratory_m0_o  (stb_cache_data_migratory_m0),
    .stb_cache_write_data_m0_o      (stb_cache_write_data_m0[127:0]),
    .stb_block_ccb_o                (stb_block_ccb),
    .stb_defer_ccb_o                (stb_defer_ccb),
    .stb_slots_valid_o              (stb_slots_valid[4:0]),
    .stb_slot0_addr_o               (stb_slot0_addr[39:0]),
    .stb_slot1_addr_o               (stb_slot1_addr[39:0]),
    .stb_slot2_addr_o               (stb_slot2_addr[39:0]),
    .stb_slot3_addr_o               (stb_slot3_addr[39:0]),
    .stb_slot4_addr_o               (stb_slot4_addr[39:0]),
    .stb_slots_ns_dsc_o             (stb_slots_ns_dsc[4:0]),
    .stb_slot0_way_o                (stb_slot0_way[1:0]),
    .stb_slot1_way_o                (stb_slot1_way[1:0]),
    .stb_slot2_way_o                (stb_slot2_way[1:0]),
    .stb_slot3_way_o                (stb_slot3_way[1:0]),
    .stb_slot4_way_o                (stb_slot4_way[1:0]),
    .stb_slot0_attrs_o              (stb_slot0_attrs[7:0]),
    .stb_slot1_attrs_o              (stb_slot1_attrs[7:0]),
    .stb_slot2_attrs_o              (stb_slot2_attrs[7:0]),
    .stb_slot3_attrs_o              (stb_slot3_attrs[7:0]),
    .stb_slot4_attrs_o              (stb_slot4_attrs[7:0]),
    .stb_lf_active_o                (stb_lf_active),
    .stb_lf_req_o                   (stb_lf_req[4:0]),
    .stb_lf_merge_o                 (stb_lf_merge[4:0]),
    .stb_lf_earliest_slot_o         (stb_lf_earliest_slot[4:0]),
    .stb_slot_cachewrite_m1_o       (stb_slot_cachewrite_m1[4:0]),
    .stb_biu_write_req_o            (stb_biu_write_req),
    .stb_biu_write_l2dbid_o         (stb_biu_write_l2dbid[3:0]),
    .stb_biu_write_chunk_o          (stb_biu_write_chunk[1:0]),
    .stb_biu_write_data_o           (stb_biu_write_data[127:0]),
    .stb_biu_write_bls_o            (stb_biu_write_bls[15:0]),
    .stb_biu_write_last_o           (stb_biu_write_last),
    .stb_biu_write_req_active_o     (stb_biu_write_req_active),
    .stb_ar_early_req_o             (stb_ar_early_req),
    .stb_ar_req_o                   (stb_ar_req),
    .stb_ar_id_o                    (stb_ar_id[4:0]),
    .stb_ar_way_o                   (stb_ar_way[1:0]),
    .stb_ar_type_o                  (stb_ar_type[7:0]),
    .stb_ar_addr_o                  (stb_ar_addr[39:0]),
    .stb_ar_ns_dsc_o                (stb_ar_ns_dsc),
    .stb_ar_attrs_o                 (stb_ar_attrs[7:0]),
    .stb_ar_priv_o                  (stb_ar_priv),
    .stb_ar_excl_o                  (stb_ar_excl),
    .stb_ar_asid_o                  (stb_ar_asid[15:0]),
    .stb_ar_vmid_o                  (stb_ar_vmid[7:0]),
    .stb_ar_va_o                    (stb_ar_va[24:0]),
    .stb_evnt_stb_stall_o           (stb_evnt_stb_stall),
    .stb_wfx_ready_o                (stb_wfx_ready_o)
  );  // u_ca53stb

  // ------------------------------------------------------
  // DCU
  // ------------------------------------------------------

  ca53dcu `CA53_DCU_PARAM_INST u_ca53dcu (
    /*ARMAUTO*/
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .DFTSE                            (DFTSE),
    .DFTRAMHOLD                       (DFTRAMHOLD),
    .biu_read_data_valid_dc2_i        (biu_read_data_valid_dc2),
    .biu_read_data_dc2_i              (biu_read_data_dc2[63:0]),
    .biu_read_abort_dc2_i             (biu_read_abort_dc2),
    .biu_read_fault_dc2_i             (biu_read_fault_dc2[1:0]),
    .biu_suppress_load_hit_dc2_i      (biu_suppress_load_hit_dc2),
    .biu_read_data_valid_dc3_i        (biu_read_data_valid_dc3),
    .biu_read_data_dc3_i              (biu_read_data_dc3[63:0]),
    .biu_lf_ready_dc2_i               (biu_lf_ready_dc2),
    .biu_lf_next_ready_dc3_i          (biu_lf_next_ready_dc3),
    .biu_lf_in_progress_i             (biu_lf_in_progress[7:0]),
    .biu_pf_in_progress_i             (biu_pf_in_progress[3:0]),
    .biu_ecc_cinv_ack_i               (biu_ecc_cinv_ack),
    .biu_ecc_cinv_complete_i          (biu_ecc_cinv_complete),
    .biu_alloc_tag_req_m0_i           (biu_alloc_tag_req_m0),
    .biu_alloc_data_m0_i              (biu_alloc_data_m0[255:0]),
    .biu_alloc_data_req_m0_i          (biu_alloc_data_req_m0),
    .biu_alloc_halfline_m0_i          (biu_alloc_halfline_m0),
    .biu_alloc_dirty_req_m0_i         (biu_alloc_dirty_req_m0),
    .biu_alloc_tag_moesi_m0_i         (biu_alloc_tag_moesi_m0[1:0]),
    .biu_alloc_dirty_moesi_m1_i       (biu_alloc_dirty_moesi_m1[1:0]),
    .biu_alloc_dirty_age_m1_i         (biu_alloc_dirty_age_m1),
    .biu_alloc_attrs_m1_i             (biu_alloc_attrs_m1[7:0]),
    .biu_alloc_addr_m0_i              (biu_alloc_addr_m0[39:4]),
    .biu_alloc_ns_dsc_m0_i            (biu_alloc_ns_dsc_m0),
    .biu_alloc_way_m0_i               (biu_alloc_way_m0[3:0]),
    .biu_ccb_lf_hazard_i              (biu_ccb_lf_hazard),
    .biu_pld_l2_next_ready_i          (biu_pld_l2_next_ready),
    .biu_pf_tag_req_m0_i              (biu_pf_tag_req_m0),
    .biu_pf_tag_addr_m0_i             (biu_pf_tag_addr_m0[39:6]),
    .biu_pf_tag_ns_dsc_m0_i           (biu_pf_tag_ns_dsc_m0),
    .biu_strex_bresp_valid_i          (biu_strex_bresp_valid),
    .biu_strex_bresp_i                (biu_strex_bresp[1:0]),
    .biu_read_abort_dc3_i             (biu_read_abort_dc3),
    .biu_read_fault_dc3_i             (biu_read_fault_dc3[1:0]),
    .biu_dirty_lf_in_progress_i       (biu_dirty_lf_in_progress),
    .biu_suppress_tlb_hit_i           (biu_suppress_tlb_hit),
    .ifu_outstanding_lfb_i            (ifu_outstanding_lfb[2:0]),
    .ifu_cp_ack_i                     (ifu_cp_ack),
    .ifu_valid_if2_i                  (ifu_valid_if2),
    .dc_size_i                        (dc_size_i[2:0]),
    .dc_tagram_rdata0_i               (dc_tagram_rdata0_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata1_i               (dc_tagram_rdata1_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata2_i               (dc_tagram_rdata2_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata3_i               (dc_tagram_rdata3_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_dataram_rdata0_i              (dc_dataram_rdata0_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata1_i              (dc_dataram_rdata1_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata2_i              (dc_dataram_rdata2_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata3_i              (dc_dataram_rdata3_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata4_i              (dc_dataram_rdata4_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata5_i              (dc_dataram_rdata5_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata6_i              (dc_dataram_rdata6_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata7_i              (dc_dataram_rdata7_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_rdata_i              (dc_dirtyram_rdata_i[(`CA53_DDIRTY_RAM_W-1):0]),
    .stb_slots_valid_i                (stb_slots_valid[4:0]),
    .stb_slots_emptying_i             (stb_slots_emptying[4:0]),
    .stb_slots_dev_ng_i               (stb_slots_dev_ng[4:0]),
    .stb_slots_dsb_i                  (stb_slots_dsb[4:0]),
    .stb_cacheable_strex_done_i       (stb_cacheable_strex_done),
    .stb_strex_failed_i               (stb_strex_failed),
    .stb_can_merge_dc2_i              (stb_can_merge_dc2[4:0]),
    .stb_sameline_dc2_i               (stb_sameline_dc2[4:0]),
    .stb_load_sameline_dc2_i          (stb_load_sameline_dc2[4:0]),
    .stb_attr_mismatch_dc2_i          (stb_attr_mismatch_dc2),
    .stb_hit_dc2_i                    (stb_hit_dc2[7:0]),
    .stb_data_dc2_i                   (stb_data_dc2[63:0]),
    .stb_cache_tag_req_m0_i           (stb_cache_tag_req_m0),
    .stb_cache_tag_wr_m0_i            (stb_cache_tag_wr_m0),
    .stb_cache_tag_way_m0_i           (stb_cache_tag_way_m0[3:0]),
    .stb_cache_tag_addr_m0_i          (stb_cache_tag_addr_m0[39:6]),
    .stb_cache_tag_ns_dsc_m0_i        (stb_cache_tag_ns_dsc_m0),
    .stb_cache_data_req_m0_i          (stb_cache_data_req_m0),
    .stb_cache_data_wr_m0_i           (stb_cache_data_wr_m0),
    .stb_cache_data_addr_m0_i         (stb_cache_data_addr_m0[13:4]),
    .stb_cache_data_way_m0_i          (stb_cache_data_way_m0[3:0]),
    .stb_cache_data_bls_m0_i          (stb_cache_data_bls_m0[15:0]),
    .stb_cache_data_attrs_m0_i        (stb_cache_data_attrs_m0[7:0]),
    .stb_cache_data_migratory_m0_i    (stb_cache_data_migratory_m0),
    .stb_cache_write_data_m0_i        (stb_cache_write_data_m0[127:0]),
    .stb_defer_ccb_i                  (stb_defer_ccb),
    .stb_block_ccb_i                  (stb_block_ccb),
    .stb_block_loads_dc1_i            (stb_block_loads_dc1),
    .stb_force_non_mergeable_i        (stb_force_non_mergeable),
    .tlb_wpt_hit_dc1_i                (tlb_wpt_hit_dc1[15:0]),
    .tlb_cache_walk_addr_i            (tlb_cache_walk_addr[39:3]),
    .tlb_cache_walk_lookup_req_m0_i   (tlb_cache_walk_lookup_req_m0[1:0]),
    .tlb_cache_walk_ns_dsc_i          (tlb_cache_walk_ns_dsc),
    .tlb_cp_read_data_dc2_i           (tlb_cp_read_data_dc2[63:0]),
    .tlb_cp_ack_i                     (tlb_cp_ack),
    .tlb_cp_reg_write_ready_i         (tlb_cp_reg_write_ready),
    .tlb_vmid_i                       (tlb_vmid[7:0]),
    .tlb_d_utlb_enable_i              (tlb_d_utlb_enable),
    .tlb_d_tcr_el1_tbi_i              (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i             (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i             (tlb_d_tcr_el3_tbi0),
    .tlb_pagewalk_invalidated_i       (tlb_pagewalk_invalidated),
    .dpu_aarch64_at_el_i              (dpu_aarch64_at_el[3:1]),
    .dpu_abort_dc1_i                  (dpu_abort_dc1),
    .dpu_align_size_iss_i             (dpu_align_size_iss[2:0]),
    .dpu_burst_iss_i                  (dpu_burst_iss),
    .dpu_cross_64_iss_i               (dpu_cross_64_iss),
    .dpu_cp_op_iss_i                  (dpu_cp_op_iss[8:0]),
    .dpu_dbg_dsb_req_i                (dpu_dbg_dsb_req),
    .dpu_clear_excl_mon_i             (dpu_clear_excl_mon),
    .dpu_mmu_on_el1_i                 (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_i                 (dpu_mmu_on_el2),
    .dpu_mmu_on_el3_i                 (dpu_mmu_on_el3),
    .dpu_dcache_on_el1_i              (dpu_dcache_on_el1),
    .dpu_dcache_on_el2_i              (dpu_dcache_on_el2),
    .dpu_dcache_on_el3_i              (dpu_dcache_on_el3),
    .dpu_default_cacheable_i          (dpu_default_cacheable),
    .dpu_l1deien_i                    (dpu_l1deien),
    .dpu_disable_dmb_i                (dpu_disable_dmb),
    .dpu_disable_no_allocate_i        (dpu_disable_no_allocate),
    .dpu_domain_dc1_i                 (dpu_domain_dc1[3:0]),
    .dpu_exception_level_i            (dpu_exception_level_o[1:0]),
    .dpu_aarch64_state_i              (dpu_aarch64_state),
    .dpu_excl_iss_i                   (dpu_excl_iss),
    .dpu_first_iss_i                  (dpu_first_iss),
    .dpu_force_first_iss_i            (dpu_force_first_iss),
    .dpu_icache_on_i                  (dpu_icache_on),
    .dpu_level_dc1_i                  (dpu_level_dc1[3:0]),
    .dpu_periphbase_i                 (dpu_periphbase[21:0]),
    .dpu_pld_iss_i                    (dpu_pld_iss),
    .dpu_pld_level_iss_i              (dpu_pld_level_iss),
    .dpu_priv_iss_i                   (dpu_priv_iss),
    .dpu_store_iss_i                  (dpu_store_iss),
    .dpu_strobe_iss_i                 (dpu_strobe_iss[15:0]),
    .dpu_second_x64_iss_i             (dpu_second_x64_iss),
    .dpu_neon_access_iss_i            (dpu_neon_access_iss),
    .dpu_s2_dcache_on_i               (dpu_s2_dcache_on),
    .dpu_valid_iss_i                  (dpu_valid_iss),
    .dpu_valid_cp_iss_i               (dpu_valid_cp_iss),
    .dpu_length_iss_i                 (dpu_length_iss[4:0]),
    .dpu_size_iss_i                   (dpu_size_iss[1:0]),
    .dpu_req_align_iss_i              (dpu_req_align_iss),
    .dpu_non_temporal_iss_i           (dpu_non_temporal_iss),
    .dpu_ldar_stlr_iss_i              (dpu_ldar_stlr_iss),
    .dpu_va_dc1_i                     (dpu_va_dc1[63:0]),
    .dpu_utlb_hit_dc1_i               (dpu_utlb_hit_dc1),
    .dpu_utlb_hit_entry_dc1_i         (dpu_utlb_hit_entry_dc1[3:0]),
    .dpu_pa_dc1_i                     (dpu_pa_dc1[39:12]),
    .dpu_attributes_dc1_i             (dpu_attributes_dc1[12:0]),
    .dpu_fault_dc1_i                  (dpu_fault_dc1[8:0]),
    .dpu_ns_dsc_dc1_i                 (dpu_ns_dsc_dc1),
    .dpu_ready_wr_i                   (dpu_ready_wr),
    .dpu_cp_data_wr_i                 (dpu_cp_data_wr[63:0]),
    .dpu_st_data_wr_i                 (dpu_st_data_wr[127:0]),
    .dpu_kill_wr_i                    (dpu_kill_wr),
    .dpu_flush_i                      (dpu_flush),
    .dpu_agu_a_operand_iss_i          (dpu_agu_a_operand_iss[48:6]),
    .dpu_agu_b_operand_iss_i          (dpu_agu_b_operand_iss[48:6]),
    .dpu_agu_carry_out_64b_iss_i      (dpu_agu_carry_out_64b_iss),
    .dpu_cc_fail_wr_i                 (dpu_cc_fail_wr),
    .dpu_ready_cc_fail_wr_i           (dpu_ready_cc_fail_wr),
    .dpu_ready_cc_pass_wr_i           (dpu_ready_cc_pass_wr),
    .dpu_ns_state_i                   (dpu_ns_state),
    .dpu_scr_el3_ns_i                 (dpu_scr_el3_ns),
    .dpu_stack_align_expt_dc1_i       (dpu_stack_align_expt_dc1),
    .dpu_lpae_dc1_i                   (dpu_lpae_dc1),
    .dpu_ipa_to_pa_en_i               (dpu_ipa_to_pa_en),
    .gov_giccdisable_i                (gov_giccdisable_i),
    .gov_stall_dsb_i                  (gov_stall_dsb_i),
    .gov_cp_ack_i                     (gov_cp_ack_i),
    .gov_cp_rdata_i                   (gov_cp_rdata_i[63:0]),
    .gov_mbist_req_i                  (gov_mbist_req_i),
    .gov_wfx_drain_req_i              (gov_wfx_drain_req_i),
    .gov_standbywfe_i                 (gov_standbywfe_i),
    .gov_standbywfi_i                 (gov_standbywfi_i),
    .gov_dbgl1rstdisable_i            (gov_dbgl1rstdisable_i),
    .scu_ac_addr_i                    (scu_ac_addr_i[40:0]),
    .scu_ac_id_i                      (scu_ac_id_i[2:0]),
    .scu_ac_l2db_id_i                 (scu_ac_l2db_id_i[3:0]),
    .scu_ac_snoop_i                   (scu_ac_snoop_i[3:0]),
    .scu_ac_valid_i                   (scu_ac_valid_i),
    .scu_ac_way_i                     (scu_ac_way_i[3:0]),
    .scu_broadcastinner_i             (scu_broadcastinner_i),
    .scu_reqbufs_busy_i               (scu_reqbufs_busy_i[7:0]),
    // Outputs
    .dcu_lf_req_dc1_o                 (dcu_lf_req_dc1),
    .dcu_lf_way_dc1_o                 (dcu_lf_way_dc1[1:0]),
    .dcu_lf_active_o                  (dcu_lf_active),
    .dcu_leaving_dc1_o                (dcu_leaving_dc1),
    .dcu_load_dc1_o                   (dcu_load_dc1),
    .dcu_load_dc2_o                   (dcu_load_dc2),
    .dcu_mbist_array_mb3_o            (dcu_mbist_array_mb3[8:0]),
    .dcu_pa_dc2_o                     (dcu_pa_dc2[39:0]),
    .dcu_ns_dsc_dc2_o                 (dcu_ns_dsc_dc2),
    .dcu_attrs_dc1_o                  (dcu_attrs_dc1[7:0]),
    .dcu_attrs_dc2_o                  (dcu_attrs_dc2[7:0]),
    .dcu_size_dc2_o                   (dcu_size_dc2[1:0]),
    .dcu_length_dc2_o                 (dcu_length_dc2[3:0]),
    .dcu_pld_l2_req_dc2_o             (dcu_pld_l2_req_dc2),
    .dcu_exclusive_dc2_o              (dcu_exclusive_dc2),
    .dcu_leaving_dc2_o                (dcu_leaving_dc2),
    .dcu_lf_req_dc2_o                 (dcu_lf_req_dc2),
    .dcu_lf_way_dc2_o                 (dcu_lf_way_dc2[1:0]),
    .dcu_biu_active_o                 (dcu_biu_active),
    .dcu_biu_req_dc2_o                (dcu_biu_req_dc2),
    .dcu_load_dc3_o                   (dcu_load_dc3),
    .dcu_lf_req_dc3_o                 (dcu_lf_req_dc3),
    .dcu_lf_way_dc3_o                 (dcu_lf_way_dc3[1:0]),
    .dcu_neon_access_dc3_o            (dcu_neon_access_dc3),
    .dcu_biu_req_dc3_o                (dcu_biu_req_dc3),
    .dcu_pa_dc3_o                     (dcu_pa_dc3[39:0]),
    .dcu_pipe_valid_dc3_o             (dcu_pipe_valid_dc3),
    .dcu_ns_dsc_dc3_o                 (dcu_ns_dsc_dc3),
    .dcu_priv_dc3_o                   (dcu_priv_dc3),
    .dcu_attrs_dc3_o                  (dcu_attrs_dc3[7:0]),
    .dcu_size_dc3_o                   (dcu_size_dc3[1:0]),
    .dcu_length_dc3_o                 (dcu_length_dc3[3:0]),
    .dcu_exclusive_dc3_o              (dcu_exclusive_dc3),
    .dcu_pldw_dc3_o                   (dcu_pldw_dc3),
    .dcu_pld_l2_req_dc3_o             (dcu_pld_l2_req_dc3),
    .dcu_stop_pf_o                    (dcu_stop_pf),
    .dcu_ecc_cinv_req_o               (dcu_ecc_cinv_req),
    .dcu_ecc_cinv_index_o             (dcu_ecc_cinv_index[7:0]),
    .dcu_ecc_cinv_way_o               (dcu_ecc_cinv_way[1:0]),
    .dcu_ecc_syndrome_m3_o            (dcu_ecc_syndrome_m3[55:0]),
    .dcu_ecc_fatal_m3_o               (dcu_ecc_fatal_m3),
    .dcu_ecc_tag_err_m3_o             (dcu_ecc_tag_err_m3),
    .dcu_mbist_data_checkbits_mb6_o   (dcu_mbist_data_checkbits_mb6[6:0]),
    .dcu_mbist_out_data_mb6_o         (dcu_mbist_out_data_mb6[63:0]),
    .dcu_snoop_dw_active_o            (dcu_snoop_dw_active),
    .dcu_snoop_valid_m2_o             (dcu_snoop_valid_m2),
    .dcu_snoop_data_m2_o              (dcu_snoop_data_m2[255:0]),
    .dcu_snoop_chunk_m2_o             (dcu_snoop_chunk_m2[1:0]),
    .dcu_snoop_rotate_m2_o            (dcu_snoop_rotate_m2[1:0]),
    .dcu_snoop_l2db_id_m2_o           (dcu_snoop_l2db_id_m2[3:0]),
    .dcu_snoop_last_m2_o              (dcu_snoop_last_m2),
    .dcu_alloc_has_priority_m0_o      (dcu_alloc_has_priority_m0),
    .dcu_alloc_ack_m1_o               (dcu_alloc_ack_m1),
    .dcu_pf_tag_has_priority_m0_o     (dcu_pf_tag_has_priority_m0),
    .dcu_pf_tag_ack_m1_o              (dcu_pf_tag_ack_m1),
    .dcu_pf_tag_hit_m2_o              (dcu_pf_tag_hit_m2),
    .dcu_ccb_ways_o                   (dcu_ccb_ways[3:0]),
    .dcu_ccb_index_o                  (dcu_ccb_index[13:6]),
    .dcu_ccb_req_active_o             (dcu_ccb_req_active),
    .dcu_ccb_req_valid_o              (dcu_ccb_req_valid),
    .dcu_drain_stb_lf_o               (dcu_drain_stb_lf),
    .dcu_cp_valid_ifu_o               (dcu_cp_valid_ifu),
    .dcu_dvm_valid_ifu_o              (dcu_dvm_valid_ifu),
    .dcu_cp_addr_ifu_o                (dcu_cp_addr_ifu[39:0]),
    .dcu_cp_op_ifu_o                  (dcu_cp_op_ifu[2:0]),
    .dcu_cp_ns_o                      (dcu_cp_ns),
    .dc_tagram_en_o                   (dc_tagram_en[3:0]),
    .dc_tagram_wr_o                   (dc_tagram_wr),
    .dc_tagram_wdata_o                (dc_tagram_wdata[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_addr_o                 (dc_tagram_addr[7:0]),
    .dc_dataram_en_o                  (dc_dataram_en[7:0]),
    .dc_dataram_wr_o                  (dc_dataram_wr),
    .dc_dataram_strb0_o               (dc_dataram_strb0[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb1_o               (dc_dataram_strb1[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb2_o               (dc_dataram_strb2[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb3_o               (dc_dataram_strb3[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb4_o               (dc_dataram_strb4[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb5_o               (dc_dataram_strb5[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb6_o               (dc_dataram_strb6[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb7_o               (dc_dataram_strb7[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_addr0_o               (dc_dataram_addr0[10:0]),
    .dc_dataram_addr1_o               (dc_dataram_addr1[10:0]),
    .dc_dataram_addr2_o               (dc_dataram_addr2[10:0]),
    .dc_dataram_addr3_o               (dc_dataram_addr3[10:0]),
    .dc_dataram_addr4_o               (dc_dataram_addr4[10:0]),
    .dc_dataram_addr5_o               (dc_dataram_addr5[10:0]),
    .dc_dataram_addr6_o               (dc_dataram_addr6[10:0]),
    .dc_dataram_addr7_o               (dc_dataram_addr7[10:0]),
    .dc_dataram_wdata0_o              (dc_dataram_wdata0[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata1_o              (dc_dataram_wdata1[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata2_o              (dc_dataram_wdata2[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata3_o              (dc_dataram_wdata3[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata4_o              (dc_dataram_wdata4[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata5_o              (dc_dataram_wdata5[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata6_o              (dc_dataram_wdata6[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata7_o              (dc_dataram_wdata7[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_en_o                 (dc_dirtyram_en),
    .dc_dirtyram_wr_o                 (dc_dirtyram_wr),
    .dc_dirtyram_strb_o               (dc_dirtyram_strb[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_dirtyram_addr_o               (dc_dirtyram_addr[8:0]),
    .dc_dirtyram_wdata_o              (dc_dirtyram_wdata[(`CA53_DDIRTY_RAM_W-1):0]),
    .dcu_dvm_sync_needed_dc3_o        (dcu_dvm_sync_needed_dc3),
    .dcu_drain_entire_stb_o           (dcu_drain_entire_stb),
    .dcu_drain_slots_o                (dcu_drain_slots[4:0]),
    .dcu_ecc_data_err_m3_o            (dcu_ecc_data_err_m3),
    .dcu_ecc_in_progress_o            (dcu_ecc_in_progress),
    .dcu_ecc_tag_err_m2_o             (dcu_ecc_tag_err_m2),
    .dcu_exclusive_monitor_o          (dcu_exclusive_monitor),
    .dcu_load_sameline_dc3_o          (dcu_load_sameline_dc3[4:0]),
    .dcu_valid_dc2_o                  (dcu_valid_dc2),
    .dcu_stb_req_dc3_o                (dcu_stb_req_dc3),
    .dcu_stlr_dc3_o                   (dcu_stlr_dc3),
    .dcu_store_dc1_o                  (dcu_store_dc1),
    .dcu_store_dc2_o                  (dcu_store_dc2),
    .dcu_store_dc3_o                  (dcu_store_dc3),
    .dcu_store_merge_dc3_o            (dcu_store_merge_dc3[4:0]),
    .dcu_store_sameline_dc3_o         (dcu_store_sameline_dc3[4:0]),
    .dcu_store_cp15_dc3_o             (dcu_store_cp15_dc3),
    .dcu_store_dmb_dc3_o              (dcu_store_dmb_dc3),
    .dcu_store_dsb_dc3_o              (dcu_store_dsb_dc3),
    .dcu_stb_attrs_dc3_o              (dcu_stb_attrs_dc3[7:0]),
    .dcu_store_bls_dc3_o              (dcu_store_bls_dc3[15:0]),
    .dcu_store_last_dc3_o             (dcu_store_last_dc3),
    .dcu_stb_tag_has_priority_m0_o    (dcu_stb_tag_has_priority_m0),
    .dcu_stb_tag_ack_m1_o             (dcu_stb_tag_ack_m1),
    .dcu_stb_tag_hit_m2_o             (dcu_stb_tag_hit_m2[3:0]),
    .dcu_stb_tag_migratory_m2_o       (dcu_stb_tag_migratory_m2),
    .dcu_stb_tag_shared_m2_o          (dcu_stb_tag_shared_m2),
    .dcu_stb_victim_way_m2_o          (dcu_stb_victim_way_m2[3:0]),
    .dcu_stb_data_has_priority_m0_o   (dcu_stb_data_has_priority_m0),
    .dcu_stb_data_ack_m1_o            (dcu_stb_data_ack_m1),
    .dcu_stb_read_data_m2_o           (dcu_stb_read_data_m2[127:0]),
    .dcu_force_non_mergeable_dc3_o    (dcu_force_non_mergeable_dc3),
    .dcu_stb_exclusive_dc3_o          (dcu_stb_exclusive_dc3),
    .dcu_cp_valid_tlb_o               (dcu_cp_valid_tlb),
    .dcu_cp_op_tlb_o                  (dcu_cp_op_tlb[4:0]),
    .dcu_transl_type_dc1_o            (dcu_transl_type_dc1[2:0]),
    .dcu_cache_walk_has_priority_m0_o (dcu_cache_walk_has_priority_m0),
    .dcu_va_valid_dc1_o               (dcu_va_valid_dc1),
    .dcu_va_valid_early_dc1_o         (dcu_va_valid_early_dc1),
    .dcu_ongoing_burst_dc1_o          (dcu_ongoing_burst_dc1),
    .dcu_cache_walk_ack_m1_o          (dcu_cache_walk_ack_m1),
    .dcu_cache_walk_data_m2_o         (dcu_cache_walk_data_m2[63:0]),
    .dcu_ecc_err_m3_o                 (dcu_ecc_err_m3),
    .dcu_cache_walk_hit_m2_o          (dcu_cache_walk_hit_m2),
    .dcu_cache_walk_victim_way_m2_o   (dcu_cache_walk_victim_way_m2[3:0]),
    .dcu_cp_addr_tlb_o                (dcu_cp_addr_tlb[61:0]),
    .dcu_cp_reg_en_dc2_o              (dcu_cp_reg_en_dc2[5:0]),
    .dcu_cp_reg_write_dc3_o           (dcu_cp_reg_write_dc3),
    .dcu_cp_reg_write_active_o        (dcu_cp_reg_write_active),
    .dcu_cp_reg_en_dc3_o              (dcu_cp_reg_en_dc3[5:0]),
    .dcu_cp_reg_data_o                (dcu_cp_reg_data[63:0]),
    .dcu_cp_reg_size_o                (dcu_cp_reg_size),
    .dcu_priv_dc1_o                   (dcu_priv_dc1),
    .dcu_block_lookups_o              (dcu_block_lookups),
    .dcu_wpt_check_512_dc1_o          (dcu_wpt_check_512_dc1),
    .dcu_ecc_err_dc3_o                (dcu_ecc_err_dc3),
    .dcu_ecc_fatal_o                  (dcu_ecc_fatal),
    .dcu_ecc_valid_o                  (dcu_ecc_valid),
    .dcu_ecc_ramid_o                  (dcu_ecc_ramid[1:0]),
    .dcu_ecc_way_bank_id_o            (dcu_ecc_way_bank_id[2:0]),
    .dcu_ecc_index_o                  (dcu_ecc_index[10:0]),
    .dcu_evnt_dc_access_o             (dcu_evnt_dc_access),
    .dcu_excl_mon_cleared_o           (dcu_excl_mon_cleared_o),
    .dcu_ready_cp_iss_o               (dcu_ready_cp_iss),
    .dcu_ready_iss_o                  (dcu_ready_iss),
    .dcu_valid_dc3_o                  (dcu_valid_dc3),
    .dcu_ld_data_dc3_o                (dcu_ld_data_dc3[63:0]),
    .dcu_strex_okay_dc3_o             (dcu_strex_okay_dc3),
    .dcu_wpt_hit_dc3_o                (dcu_wpt_hit_dc3),
    .dcu_p_abort_dc3_o                (dcu_p_abort_dc3),
    .dcu_p_fault_dc3_o                (dcu_p_fault_dc3[6:0]),
    .dcu_p_fault_stage_dc3_o          (dcu_p_fault_stage_dc3[1:0]),
    .dcu_p_domain_dc3_o               (dcu_p_domain_dc3[3:0]),
    .dcu_p_direction_dc3_o            (dcu_p_direction_dc3),
    .dcu_v2p_lpae_dc3_o               (dcu_v2p_lpae_dc3),
    .dcu_cm_operation_dc3_o           (dcu_cm_operation_dc3),
    .dcu_va_dc3_o                     (dcu_va_dc3[63:0]),
    .dcu_dbg_dsb_ack_o                (dcu_dbg_dsb_ack),
    .dcu_cp_gov_addr_o                (dcu_cp_gov_addr_o[17:0]),
    .dcu_cp_gov_ns_o                  (dcu_cp_gov_ns_o),
    .dcu_cp_gov_req_o                 (dcu_cp_gov_req_o),
    .dcu_cp_gov_sel_o                 (dcu_cp_gov_sel_o[2:0]),
    .dcu_cp_gov_wdata_o               (dcu_cp_gov_wdata_o[63:0]),
    .dcu_cp_gov_wenable_o             (dcu_cp_gov_wenable_o),
    .dcu_wfx_ready_o                  (dcu_wfx_ready_o),
    .dcu_ac_ready_o                   (dcu_ac_ready_o),
    .dcu_cr_alloc_o                   (dcu_cr_alloc_o),
    .dcu_cr_dirty_o                   (dcu_cr_dirty_o),
    .dcu_cr_id_o                      (dcu_cr_id_o[2:0]),
    .dcu_cr_migratory_o               (dcu_cr_migratory_o),
    .dcu_cr_age_o                     (dcu_cr_age_o),
    .dcu_cr_valid_o                   (dcu_cr_valid_o),
    .dcu_dvm_complete_o               (dcu_dvm_complete_o)
  );  // u_ca53dcu

  // ------------------------------------------------------
  // TLB
  // ------------------------------------------------------

  ca53tlb `CA53_TLB_PARAM_INST u_ca53tlb (
    /*ARMAUTO*/
    .dbg_resetn_i                     (po_reset_n),
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .DFTSE                            (DFTSE),
    .DFTRAMHOLD                       (DFTRAMHOLD),
    .biu_walk_ack_i                   (biu_walk_ack),
    .biu_walk_resp_i                  (biu_walk_resp[2:0]),
    .biu_walk_data_i                  (biu_walk_data[63:0]),
    .biu_walk_lf_hazard_i             (biu_walk_lf_hazard),
    .biu_mbist_in_data_hi_mb3_i       (biu_mbist_in_data_hi_mb3[52:0]),
    .dcu_va_valid_dc1_i               (dcu_va_valid_dc1),
    .dcu_va_valid_early_dc1_i         (dcu_va_valid_early_dc1),
    .dcu_transl_type_dc1_i            (dcu_transl_type_dc1[2:0]),
    .dcu_ongoing_burst_dc1_i          (dcu_ongoing_burst_dc1),
    .dcu_store_dc1_i                  (dcu_store_dc1),
    .dcu_wpt_check_512_dc1_i          (dcu_wpt_check_512_dc1),
    .dcu_priv_dc1_i                   (dcu_priv_dc1),
    .dcu_cp_reg_en_dc2_i              (dcu_cp_reg_en_dc2[5:0]),
    .dcu_cp_reg_write_active_i        (dcu_cp_reg_write_active),
    .dcu_cp_reg_write_dc3_i           (dcu_cp_reg_write_dc3),
    .dcu_cp_reg_en_dc3_i              (dcu_cp_reg_en_dc3[5:0]),
    .dcu_cp_valid_tlb_i               (dcu_cp_valid_tlb),
    .dcu_cp_reg_data_i                (dcu_cp_reg_data[63:0]),
    .dcu_cp_reg_size_i                (dcu_cp_reg_size),
    .dcu_cp_addr_tlb_i                (dcu_cp_addr_tlb[61:0]),
    .dcu_cp_ns_i                      (dcu_cp_ns),
    .dcu_cp_op_tlb_i                  (dcu_cp_op_tlb[4:0]),
    .dcu_cache_walk_ack_m1_i          (dcu_cache_walk_ack_m1),
    .dcu_cache_walk_data_m2_i         (dcu_cache_walk_data_m2[63:0]),
    .dcu_ecc_err_m3_i                 (dcu_ecc_err_m3),
    .dcu_cache_walk_hit_m2_i          (dcu_cache_walk_hit_m2),
    .dcu_cache_walk_victim_way_m2_i   (dcu_cache_walk_victim_way_m2[3:0]),
    .dcu_cache_walk_has_priority_m0_i (dcu_cache_walk_has_priority_m0),
    .dcu_block_lookups_i              (dcu_block_lookups),
    .dpu_apb_active_i                 (dpu_apb_active),
    .dpu_va_dc1_i                     (dpu_va_dc1[63:0]),
    .dpu_utlb_hit_dc1_i               (dpu_utlb_hit_dc1),
    .dpu_hivecs_i                     (dpu_hivecs),
    .dpu_ipa_to_pa_en_i               (dpu_ipa_to_pa_en),
    .dpu_default_cacheable_i          (dpu_default_cacheable),
    .dpu_tlb_abandon_i                (dpu_tlb_abandon),
    .dpu_dbg_vid_i                    (dpu_dbg_vid[3:0]),
    .dpu_mmu_on_el3_i                 (dpu_mmu_on_el3),
    .dpu_mmu_on_el1_i                 (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_i                 (dpu_mmu_on_el2),
    .dpu_dcache_on_el3_i              (dpu_dcache_on_el3),
    .dpu_dcache_on_el1_i              (dpu_dcache_on_el1),
    .dpu_dcache_on_el2_i              (dpu_dcache_on_el2),
    .dpu_endian_el3_i                 (dpu_endian_el3),
    .dpu_endian_el1_i                 (dpu_endian_el1),
    .dpu_endian_el2_i                 (dpu_endian_el2),
    .dpu_icache_on_i                  (dpu_icache_on),
    .dpu_s2_dcache_on_i               (dpu_s2_dcache_on),
    .dpu_tex_remap_enable_el3_i       (dpu_tex_remap_enable_el3),
    .dpu_tex_remap_enable_el1_i       (dpu_tex_remap_enable_el1),
    .dpu_access_flag_enable_el3_i     (dpu_access_flag_enable_el3),
    .dpu_access_flag_enable_el1_i     (dpu_access_flag_enable_el1),
    .dpu_sctlr_wxn_el3_i              (dpu_sctlr_wxn_el3),
    .dpu_sctlr_wxn_el1_i              (dpu_sctlr_wxn_el1),
    .dpu_sctlr_wxn_el2_i              (dpu_sctlr_wxn_el2),
    .dpu_sctlr_uwxn_el3_i             (dpu_sctlr_uwxn_el3),
    .dpu_sctlr_uwxn_el1_i             (dpu_sctlr_uwxn_el1),
    .dpu_pr_tablewalk_i               (dpu_pr_tablewalk),
    .dpu_scr_el3_ns_i                 (dpu_scr_el3_ns),
    .dpu_ns_state_i                   (dpu_ns_state),
    .dpu_vec_base_s_dc1_i             (dpu_vec_base_s_dc1[31:5]),
    .dpu_vec_base_ns_dc1_i            (dpu_vec_base_ns_dc1[31:5]),
    .dpu_mon_vec_base_dc1_i           (dpu_mon_vec_base_dc1[31:5]),
    .dpu_mode_iss_i                   (dpu_mode_iss[4:0]),
    .dpu_exception_level_i            (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el_i              (dpu_aarch64_at_el[3:1]),
    .dpu_dbg_tlb_sw_bkpt_wpt_en_i     (dpu_dbg_tlb_sw_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i     (dpu_dbg_tlb_hw_bkpt_wpt_en),
    .dpu_dbg_sample_contextid_i       (dpu_dbg_sample_contextid),
    .dpu_dbg_wr_i                     (dpu_dbg_wr),
    .dpu_dbg_addr_i                   (dpu_dbg_addr[11:2]),
    .dpu_dbg_wdata_i                  (dpu_dbg_wdata[31:0]),
    .ifu_utlb_miss_req_i              (ifu_utlb_miss_req),
    .ifu_va_if2_i                     (ifu_va_if2[63:0]),
    .ifu_cp_dbg_valid_i               (ifu_cp_dbg_valid),
    .ifu_cp_dbg_1_i                   (ifu_cp_dbg_1[31:0]),
    .ifu_cp_dbg_0_i                   (ifu_cp_dbg_0[31:0]),
    .gov_mbist_req_i                  (gov_mbist_req_i),
    .tlb_ram_rdata0_i                 (tlb_ram_rdata0_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata1_i                 (tlb_ram_rdata1_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata2_i                 (tlb_ram_rdata2_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata3_i                 (tlb_ram_rdata3_i[`CA53_TLB_RAM_W-1:0]),
    // Outputs
    .tlb_mem_granule_o                (tlb_mem_granule[1:0]),
    .tlb_walk_addr_o                  (tlb_walk_addr[39:0]),
    .tlb_walk_attrs_o                 (tlb_walk_attrs[7:0]),
    .tlb_walk_ns_dsc_o                (tlb_walk_ns_dsc),
    .tlb_walk_size_o                  (tlb_walk_size),
    .tlb_walk_way_o                   (tlb_walk_way[1:0]),
    .tlb_walk_nc_req_o                (tlb_walk_nc_req),
    .tlb_walk_lf_active_o             (tlb_walk_lf_active),
    .tlb_walk_lf_req_o                (tlb_walk_lf_req),
    .tlb_mbist_out_data_mb6_o         (tlb_mbist_out_data_mb6[116:0]),
    .tlb_wpt_hit_dc1_o                (tlb_wpt_hit_dc1[15:0]),
    .tlb_cp_read_data_dc2_o           (tlb_cp_read_data_dc2[63:0]),
    .tlb_cp_reg_write_ready_o         (tlb_cp_reg_write_ready),
    .tlb_cp_ack_o                     (tlb_cp_ack),
    .tlb_cache_walk_lookup_req_m0_o   (tlb_cache_walk_lookup_req_m0[1:0]),
    .tlb_cache_walk_addr_o            (tlb_cache_walk_addr[39:3]),
    .tlb_cache_walk_ns_dsc_o          (tlb_cache_walk_ns_dsc),
    .tlb_lpae_mode_o                  (tlb_lpae_mode),
    .tlb_lpae_mode_s_o                (tlb_lpae_mode_s),
    .tlb_vmid_o                       (tlb_vmid[7:0]),
    .tlb_pagewalk_invalidated_o       (tlb_pagewalk_invalidated),
    .tlb_dbg_rdata_o                  (tlb_dbg_rdata[31:0]),
    .tlb_wfx_ready_o                  (tlb_wfx_ready_o),
    .tlb_d_utlb_enable_o              (tlb_d_utlb_enable),
    .tlb_d_utlb_might_enable_o        (tlb_d_utlb_might_enable),
    .tlb_d_utlb_valid_o               (tlb_d_utlb_valid),
    .tlb_d_utlb_lpae_o                (tlb_d_utlb_lpae),
    .tlb_d_utlb_data_o                (tlb_d_utlb_data[95:0]),
    .tlb_d_utlb_flush_o               (tlb_d_utlb_flush),
    .tlb_d_tcr_el1_tbi_o              (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_o             (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_o             (tlb_d_tcr_el3_tbi0),
    .tlb_evnt_data_pagewalk_o         (tlb_evnt_data_pagewalk),
    .tlb_evnt_instr_pagewalk_o        (tlb_evnt_instr_pagewalk),
    .tlb_pty_valid_o                  (tlb_pty_valid),
    .tlb_pty_way_bank_id_o            (tlb_pty_way_bank_id[1:0]),
    .tlb_pty_index_o                  (tlb_pty_index[7:0]),
    .tlb_i_utlb_enable_o              (tlb_i_utlb_enable),
    .tlb_i_utlb_might_enable_o        (tlb_i_utlb_might_enable),
    .tlb_i_utlb_valid_o               (tlb_i_utlb_valid),
    .tlb_i_utlb_lpae_o                (tlb_i_utlb_lpae),
    .tlb_i_utlb_data_o                (tlb_i_utlb_data[96:0]),
    .tlb_i_utlb_flush_o               (tlb_i_utlb_flush),
    .tlb_bkpt_hit_if2_o               (tlb_bkpt_hit_if2[3:0]),
    .tlb_vcr_hit_if2_o                (tlb_vcr_hit_if2[1:0]),
    .tlb_ram_en_o                     (tlb_ram_en[3:0]),
    .tlb_ram_wr_o                     (tlb_ram_wr),
    .tlb_ram_addr_o                   (tlb_ram_addr[(`CA53_TLB_RAM_ADDR_W-1):0]),
    .tlb_ram_wdata_o                  (tlb_ram_wdata[`CA53_TLB_RAM_W-1:0]),
    .tlb_context_id_o                 (tlb_context_id[31:0])
  );  // u_ca53tlb

  // ------------------------------------------------------
  // BIU
  // ------------------------------------------------------

  ca53biu `CA53_BIU_PARAM_INST u_ca53biu (
    /*ARMAUTO*/
    // Inputs
    .clk                                        (clk),
    .reset_n                                    (reset_n),
    .DFTSE                                      (DFTSE),
    .dc_size_i                                  (dc_size_i[2:0]),
    .dpu_dcache_on_i                            (dpu_dcache_on),
    .dpu_ramode_cnt_l1_i                        (dpu_ramode_cnt_l1[1:0]),
    .dpu_ramode_cnt_l2_i                        (dpu_ramode_cnt_l2[1:0]),
    .dpu_disable_device_split_throttle_i        (dpu_disable_device_split_throttle),
    .dpu_enable_data_prefetch_i                 (dpu_enable_data_prefetch[2:0]),
    .dpu_enable_data_prefetch_streams_i         (dpu_enable_data_prefetch_streams[1:0]),
    .dpu_data_prefetch_stride_detect_i          (dpu_data_prefetch_stride_detect),
    .dpu_disable_data_prefetch_stores_pattern_i (dpu_disable_data_prefetch_stores_pattern),
    .dpu_disable_data_prefetch_readunique_i     (dpu_disable_data_prefetch_readunique),
    .dpu_kill_wr_i                              (dpu_kill_wr),
    .dpu_flush_i                                (dpu_flush),
    .dpu_ready_wr_i                             (dpu_ready_wr),
    .dpu_ready_cc_fail_wr_i                     (dpu_ready_cc_fail_wr),
    .dpu_pa_dc1_i                               (dpu_pa_dc1[39:12]),
    .dpu_va_dc1_i                               (dpu_va_dc1[11:4]),
    .dpu_ns_dsc_dc1_i                           (dpu_ns_dsc_dc1),
    .gov_mbist_req_i                            (gov_mbist_req_i),
    .gov_wfx_drain_req_i                        (gov_wfx_drain_req_i),
    .scu_ar_credit_i                            (scu_ar_credit_i),
    .scu_ar_block_i                             (scu_ar_block_i),
    .scu_dr_valid_i                             (scu_dr_valid_i),
    .scu_dr_id_i                                (scu_dr_id_i[4:0]),
    .scu_dr_resp_i                              (scu_dr_resp_i[5:0]),
    .scu_dr_chunk_i                             (scu_dr_chunk_i[1:0]),
    .scu_dr_data_i                              (scu_dr_data_i[127:0]),
    .scu_rr_valid_i                             (scu_rr_valid_i),
    .scu_rr_id_i                                (scu_rr_id_i[4:0]),
    .scu_rr_resp_i                              (scu_rr_resp_i[1:0]),
    .scu_rr_l2db_id_i                           (scu_rr_l2db_id_i[3:0]),
    .scu_ev_done_i                              (scu_ev_done_i[7:0]),
    .scu_db_excl_valid_i                        (scu_db_excl_valid_i),
    .scu_db_excl_resp_i                         (scu_db_excl_resp_i[1:0]),
    .scu_db_decerr_i                            (scu_db_decerr_i),
    .scu_db_slverr_i                            (scu_db_slverr_i),
    .scu_leave_ramode_i                         (scu_leave_ramode_i),
    .tlb_mem_granule_i                          (tlb_mem_granule[1:0]),
    .tlb_walk_addr_i                            (tlb_walk_addr[39:0]),
    .tlb_walk_attrs_i                           (tlb_walk_attrs[7:0]),
    .tlb_walk_ns_dsc_i                          (tlb_walk_ns_dsc),
    .tlb_walk_size_i                            (tlb_walk_size),
    .tlb_walk_nc_req_i                          (tlb_walk_nc_req),
    .tlb_walk_lf_active_i                       (tlb_walk_lf_active),
    .tlb_walk_lf_req_i                          (tlb_walk_lf_req),
    .tlb_walk_way_i                             (tlb_walk_way[1:0]),
    .dcu_lf_active_i                            (dcu_lf_active),
    .dcu_leaving_dc1_i                          (dcu_leaving_dc1),
    .dcu_load_dc1_i                             (dcu_load_dc1),
    .dcu_load_dc2_i                             (dcu_load_dc2),
    .dcu_mbist_array_mb3_i                      (dcu_mbist_array_mb3[8:0]),
    .dcu_biu_active_i                           (dcu_biu_active),
    .dcu_biu_req_dc2_i                          (dcu_biu_req_dc2),
    .dcu_pa_dc2_i                               (dcu_pa_dc2[39:0]),
    .dcu_ns_dsc_dc2_i                           (dcu_ns_dsc_dc2),
    .dcu_attrs_dc2_i                            (dcu_attrs_dc2[7:0]),
    .dcu_size_dc2_i                             (dcu_size_dc2[1:0]),
    .dcu_length_dc2_i                           (dcu_length_dc2[3:0]),
    .dcu_pld_l2_req_dc2_i                       (dcu_pld_l2_req_dc2),
    .dcu_exclusive_dc2_i                        (dcu_exclusive_dc2),
    .dcu_lf_req_dc1_i                           (dcu_lf_req_dc1),
    .dcu_lf_way_dc1_i                           (dcu_lf_way_dc1[1:0]),
    .dcu_attrs_dc1_i                            (dcu_attrs_dc1[7:0]),
    .dcu_lf_req_dc2_i                           (dcu_lf_req_dc2),
    .dcu_lf_way_dc2_i                           (dcu_lf_way_dc2[1:0]),
    .dcu_leaving_dc2_i                          (dcu_leaving_dc2),
    .dcu_load_dc3_i                             (dcu_load_dc3),
    .dcu_lf_req_dc3_i                           (dcu_lf_req_dc3),
    .dcu_lf_way_dc3_i                           (dcu_lf_way_dc3[1:0]),
    .dcu_neon_access_dc3_i                      (dcu_neon_access_dc3),
    .dcu_biu_req_dc3_i                          (dcu_biu_req_dc3),
    .dcu_stb_req_dc3_i                          (dcu_stb_req_dc3),
    .dcu_pa_dc3_i                               (dcu_pa_dc3[39:0]),
    .dcu_pipe_valid_dc3_i                       (dcu_pipe_valid_dc3),
    .dcu_valid_dc3_i                            (dcu_valid_dc3),
    .dcu_ns_dsc_dc3_i                           (dcu_ns_dsc_dc3),
    .dcu_priv_dc3_i                             (dcu_priv_dc3),
    .dcu_attrs_dc3_i                            (dcu_attrs_dc3[7:0]),
    .dcu_size_dc3_i                             (dcu_size_dc3[1:0]),
    .dcu_length_dc3_i                           (dcu_length_dc3[3:0]),
    .dcu_exclusive_dc3_i                        (dcu_exclusive_dc3),
    .dcu_pldw_dc3_i                             (dcu_pldw_dc3),
    .dcu_pld_l2_req_dc3_i                       (dcu_pld_l2_req_dc3),
    .dcu_stop_pf_i                              (dcu_stop_pf),
    .dcu_drain_stb_lf_i                         (dcu_drain_stb_lf),
    .dcu_ecc_cinv_req_i                         (dcu_ecc_cinv_req),
    .dcu_ecc_cinv_index_i                       (dcu_ecc_cinv_index[7:0]),
    .dcu_ecc_cinv_way_i                         (dcu_ecc_cinv_way[1:0]),
    .dcu_ecc_syndrome_m3_i                      (dcu_ecc_syndrome_m3[55:0]),
    .dcu_ecc_fatal_m3_i                         (dcu_ecc_fatal_m3),
    .dcu_ecc_tag_err_m3_i                       (dcu_ecc_tag_err_m3),
    .dcu_snoop_dw_active_i                      (dcu_snoop_dw_active),
    .dcu_snoop_valid_m2_i                       (dcu_snoop_valid_m2),
    .dcu_snoop_data_m2_i                        (dcu_snoop_data_m2[255:0]),
    .dcu_snoop_chunk_m2_i                       (dcu_snoop_chunk_m2[1:0]),
    .dcu_snoop_rotate_m2_i                      (dcu_snoop_rotate_m2[1:0]),
    .dcu_snoop_l2db_id_m2_i                     (dcu_snoop_l2db_id_m2[3:0]),
    .dcu_snoop_last_m2_i                        (dcu_snoop_last_m2),
    .dcu_alloc_has_priority_m0_i                (dcu_alloc_has_priority_m0),
    .dcu_alloc_ack_m1_i                         (dcu_alloc_ack_m1),
    .dcu_stb_data_ack_m1_i                      (dcu_stb_data_ack_m1),
    .dcu_pf_tag_has_priority_m0_i               (dcu_pf_tag_has_priority_m0),
    .dcu_pf_tag_ack_m1_i                        (dcu_pf_tag_ack_m1),
    .dcu_pf_tag_hit_m2_i                        (dcu_pf_tag_hit_m2),
    .dcu_ccb_req_active_i                       (dcu_ccb_req_active),
    .dcu_ccb_ways_i                             (dcu_ccb_ways[3:0]),
    .dcu_ccb_index_i                            (dcu_ccb_index[13:6]),
    .ifu_arvalid_i                              (ifu_arvalid),
    .ifu_arid_i                                 (ifu_arid[1:0]),
    .ifu_araddr_i                               (ifu_araddr[39:0]),
    .ifu_arlen_i                                (ifu_arlen[1:0]),
    .ifu_attrs_i                                (ifu_attrs[7:0]),
    .ifu_arprot_i                               (ifu_arprot[1:0]),
    .ifu_rready_i                               (ifu_rready),
    .ifu_outstanding_lfb_i                      (ifu_outstanding_lfb[2:0]),
    .stb_slots_valid_i                          (stb_slots_valid[4:0]),
    .stb_slot0_addr_i                           (stb_slot0_addr[39:0]),
    .stb_slot1_addr_i                           (stb_slot1_addr[39:0]),
    .stb_slot2_addr_i                           (stb_slot2_addr[39:0]),
    .stb_slot3_addr_i                           (stb_slot3_addr[39:0]),
    .stb_slot4_addr_i                           (stb_slot4_addr[39:0]),
    .stb_slots_ns_dsc_i                         (stb_slots_ns_dsc[4:0]),
    .stb_slot0_way_i                            (stb_slot0_way[1:0]),
    .stb_slot1_way_i                            (stb_slot1_way[1:0]),
    .stb_slot2_way_i                            (stb_slot2_way[1:0]),
    .stb_slot3_way_i                            (stb_slot3_way[1:0]),
    .stb_slot4_way_i                            (stb_slot4_way[1:0]),
    .stb_slot0_attrs_i                          (stb_slot0_attrs[7:0]),
    .stb_slot1_attrs_i                          (stb_slot1_attrs[7:0]),
    .stb_slot2_attrs_i                          (stb_slot2_attrs[7:0]),
    .stb_slot3_attrs_i                          (stb_slot3_attrs[7:0]),
    .stb_slot4_attrs_i                          (stb_slot4_attrs[7:0]),
    .stb_lf_active_i                            (stb_lf_active),
    .stb_lf_req_i                               (stb_lf_req[4:0]),
    .stb_lf_merge_i                             (stb_lf_merge[4:0]),
    .stb_lf_earliest_slot_i                     (stb_lf_earliest_slot[4:0]),
    .stb_slot_cachewrite_m1_i                   (stb_slot_cachewrite_m1[4:0]),
    .stb_biu_write_req_i                        (stb_biu_write_req),
    .stb_biu_write_l2dbid_i                     (stb_biu_write_l2dbid[3:0]),
    .stb_biu_write_chunk_i                      (stb_biu_write_chunk[1:0]),
    .stb_biu_write_data_i                       (stb_biu_write_data[127:0]),
    .stb_biu_write_bls_i                        (stb_biu_write_bls[15:0]),
    .stb_biu_write_last_i                       (stb_biu_write_last),
    .stb_biu_write_req_active_i                 (stb_biu_write_req_active),
    .stb_ar_req_i                               (stb_ar_req),
    .stb_ar_early_req_i                         (stb_ar_early_req),
    .stb_ar_id_i                                (stb_ar_id[4:0]),
    .stb_ar_way_i                               (stb_ar_way[1:0]),
    .stb_ar_type_i                              (stb_ar_type[7:0]),
    .stb_ar_addr_i                              (stb_ar_addr[39:0]),
    .stb_ar_ns_dsc_i                            (stb_ar_ns_dsc),
    .stb_ar_attrs_i                             (stb_ar_attrs[7:0]),
    .stb_ar_priv_i                              (stb_ar_priv),
    .stb_ar_excl_i                              (stb_ar_excl),
    .stb_ar_asid_i                              (stb_ar_asid[15:0]),
    .stb_ar_vmid_i                              (stb_ar_vmid[7:0]),
    .stb_ar_va_i                                (stb_ar_va[24:0]),
    .tlb_mbist_out_data_mb6_i                   (tlb_mbist_out_data_mb6[116:0]),
    .ifu_mbist_out_data_mb6_i                   (ifu_mbist_out_data_mb6[`CA53_IDATA_RAM_W-1:0]),
    .dcu_mbist_out_data_mb6_i                   (dcu_mbist_out_data_mb6[63:0]),
    .dcu_mbist_data_checkbits_mb6_i             (dcu_mbist_data_checkbits_mb6[6:0]),
    // Outputs
    .biu_w_imp_abort_o                          (biu_w_imp_abort),
    .biu_w_imp_fault_o                          (biu_w_imp_fault[1:0]),
    .biu_evnt_ext_mem_req_o                     (biu_evnt_ext_mem_req[1:0]),
    .biu_evnt_ext_mem_req_nc_o                  (biu_evnt_ext_mem_req_nc[1:0]),
    .biu_evnt_rw_lf_o                           (biu_evnt_rw_lf),
    .biu_evnt_pf_lf_o                           (biu_evnt_pf_lf),
    .biu_evnt_ramode_o                          (biu_evnt_ramode),
    .biu_evnt_ramode_enter_o                    (biu_evnt_ramode_enter),
    .biu_wfx_ready_o                            (biu_wfx_ready_o),
    .biu_ar_active_o                            (biu_ar_active_o),
    .biu_ar_valid_o                             (biu_ar_valid),
    .biu_ar_id_o                                (biu_ar_id[4:0]),
    .biu_ar_type_o                              (biu_ar_type[4:0]),
    .biu_ar_attrs_o                             (biu_ar_attrs[7:0]),
    .biu_ar_way_o                               (biu_ar_way[4:0]),
    .biu_ar_addr_o                              (biu_ar_addr[40:0]),
    .biu_ar_len_o                               (biu_ar_len[1:0]),
    .biu_ar_size_o                              (biu_ar_size[2:0]),
    .biu_ar_lock_o                              (biu_ar_lock),
    .biu_ar_priv_o                              (biu_ar_priv_o),
    .biu_dr_credit_o                            (biu_dr_credit),
    .biu_dw_valid_o                             (biu_dw_valid),
    .biu_dw_l2db_id_o                           (biu_dw_l2db_id_o[3:0]),
    .biu_dw_chunks_valid_o                      (biu_dw_chunks_valid_o[3:0]),
    .biu_dw_last_o                              (biu_dw_last),
    .biu_dw_data_o                              (biu_dw_data[255:0]),
    .biu_dw_strb_o                              (biu_dw_strb[31:0]),
    .biu_dw_err_o                               (biu_dw_err_o),
    .biu_dw_fatal_o                             (biu_dw_fatal_o),
    .biu_walk_ack_o                             (biu_walk_ack),
    .biu_walk_resp_o                            (biu_walk_resp[2:0]),
    .biu_walk_data_o                            (biu_walk_data[63:0]),
    .biu_walk_lf_hazard_o                       (biu_walk_lf_hazard),
    .biu_pld_l2_next_ready_o                    (biu_pld_l2_next_ready),
    .biu_read_data_valid_dc2_o                  (biu_read_data_valid_dc2),
    .biu_read_data_dc2_o                        (biu_read_data_dc2[63:0]),
    .biu_read_abort_dc2_o                       (biu_read_abort_dc2),
    .biu_read_fault_dc2_o                       (biu_read_fault_dc2[1:0]),
    .biu_suppress_load_hit_dc2_o                (biu_suppress_load_hit_dc2),
    .biu_lf_ready_dc2_o                         (biu_lf_ready_dc2),
    .biu_lf_next_ready_dc3_o                    (biu_lf_next_ready_dc3),
    .biu_read_data_valid_dc3_o                  (biu_read_data_valid_dc3),
    .biu_read_data_dc3_o                        (biu_read_data_dc3[63:0]),
    .biu_read_abort_dc3_o                       (biu_read_abort_dc3),
    .biu_read_fault_dc3_o                       (biu_read_fault_dc3[1:0]),
    .biu_ecc_cinv_ack_o                         (biu_ecc_cinv_ack),
    .biu_ecc_cinv_complete_o                    (biu_ecc_cinv_complete),
    .biu_lf_in_progress_o                       (biu_lf_in_progress[7:0]),
    .biu_pf_in_progress_o                       (biu_pf_in_progress[3:0]),
    .biu_alloc_data_m0_o                        (biu_alloc_data_m0[255:0]),
    .biu_alloc_tag_req_m0_o                     (biu_alloc_tag_req_m0),
    .biu_alloc_data_req_m0_o                    (biu_alloc_data_req_m0),
    .biu_alloc_halfline_m0_o                    (biu_alloc_halfline_m0),
    .biu_alloc_dirty_req_m0_o                   (biu_alloc_dirty_req_m0),
    .biu_alloc_addr_m0_o                        (biu_alloc_addr_m0[39:4]),
    .biu_alloc_ns_dsc_m0_o                      (biu_alloc_ns_dsc_m0),
    .biu_alloc_way_m0_o                         (biu_alloc_way_m0[3:0]),
    .biu_alloc_tag_moesi_m0_o                   (biu_alloc_tag_moesi_m0[1:0]),
    .biu_alloc_dirty_moesi_m1_o                 (biu_alloc_dirty_moesi_m1[1:0]),
    .biu_alloc_dirty_age_m1_o                   (biu_alloc_dirty_age_m1),
    .biu_alloc_attrs_m1_o                       (biu_alloc_attrs_m1[7:0]),
    .biu_pf_tag_req_m0_o                        (biu_pf_tag_req_m0),
    .biu_pf_tag_addr_m0_o                       (biu_pf_tag_addr_m0[39:6]),
    .biu_pf_tag_ns_dsc_m0_o                     (biu_pf_tag_ns_dsc_m0),
    .biu_ccb_lf_hazard_o                        (biu_ccb_lf_hazard),
    .biu_strex_bresp_valid_o                    (biu_strex_bresp_valid),
    .biu_strex_bresp_o                          (biu_strex_bresp[1:0]),
    .biu_suppress_tlb_hit_o                     (biu_suppress_tlb_hit),
    .biu_i_arready_o                            (biu_i_arready),
    .biu_i_rvalid_o                             (biu_i_rvalid),
    .biu_i_rid_o                                (biu_i_rid[1:0]),
    .biu_i_rdata_o                              (biu_i_rdata[127:0]),
    .biu_i_rresp_o                              (biu_i_rresp[2:0]),
    .biu_i_rchunk_o                             (biu_i_rchunk[1:0]),
    .biu_lf_hazard_o                            (biu_lf_hazard[4:0]),
    .biu_lf_real_hazard_o                       (biu_lf_real_hazard[4:0]),
    .biu_lf_hazard_migratory_o                  (biu_lf_hazard_migratory[4:0]),
    .biu_lf_hazard_way_slot0_o                  (biu_lf_hazard_way_slot0[1:0]),
    .biu_lf_hazard_way_slot1_o                  (biu_lf_hazard_way_slot1[1:0]),
    .biu_lf_hazard_way_slot2_o                  (biu_lf_hazard_way_slot2[1:0]),
    .biu_lf_hazard_way_slot3_o                  (biu_lf_hazard_way_slot3[1:0]),
    .biu_lf_hazard_way_slot4_o                  (biu_lf_hazard_way_slot4[1:0]),
    .biu_lf_serialized_o                        (biu_lf_serialized[4:0]),
    .biu_ev_hazard_o                            (biu_ev_hazard[4:0]),
    .biu_lf_can_merge_o                         (biu_lf_can_merge[4:0]),
    .biu_stb_write_accept_o                     (biu_stb_write_accept),
    .biu_read_alloc_mode_o                      (biu_read_alloc_mode),
    .biu_stb_ar_ack_o                           (biu_stb_ar_ack),
    .biu_stb_ar_resp_valid_o                    (biu_stb_ar_resp_valid),
    .biu_stb_ar_resp_o                          (biu_stb_ar_resp[1:0]),
    .biu_stb_ar_resp_id_o                       (biu_stb_ar_resp_id[4:0]),
    .biu_stb_ar_resp_l2dbid_o                   (biu_stb_ar_resp_l2dbid[3:0]),
    .biu_dirty_lf_in_progress_o                 (biu_dirty_lf_in_progress),
    .biu_excl_lf_in_progress_o                  (biu_excl_lf_in_progress),
    .biu_mbist_in_data_hi_mb3_o                 (biu_mbist_in_data_hi_mb3[52:0])
  );  // u_ca53biu

  // ------------------------------------------------------
  // ETM
  // ------------------------------------------------------

  ca53etm u_ca53etm (
    /*ARMAUTO*/
    // Inputs
    .clk                       (clk),
    .po_reset_n                (po_reset_n),
    .gov_atclken_i             (gov_atclken_i),
    .gov_atreadym_i            (gov_atreadym_i),
    .gov_afvalidm_i            (gov_afvalidm_i),
    .gov_syncreqm_i            (gov_syncreqm_i),
    .gov_pseldbg_etm_i         (gov_pseldbg_etm_i),
    .gov_penabledbg_i          (gov_penabledbg_i),
    .gov_pwdatadbg_i           (gov_pwdatadbg_i[31:0]),
    .gov_paddrdbg_i            (gov_paddrdbg_i[11:2]),
    .gov_pwritedbg_i           (gov_pwritedbg_i),
    .gov_etmpdsr_rd_i          (gov_etmpdsr_rd_i),
    .gov_wfx_drain_req_i       (gov_wfx_drain_req_i),
    .dpu_wpt_valid_i           (dpu_wpt_valid),
    .dpu_wpt_addr_i            (dpu_wpt_addr[63:1]),
    .dpu_wpt_target_addr_opa_i (dpu_wpt_target_addr_opa[63:1]),
    .dpu_wpt_target_addr_opb_i (dpu_wpt_target_addr_opb[27:1]),
    .dpu_wpt_advance_i         (dpu_wpt_advance),
    .dpu_wpt_range_i           (dpu_wpt_range),
    .tlb_context_id_i          (tlb_context_id[31:0]),
    .tlb_vmid_i                (tlb_vmid[7:0]),
    .tlb_d_tcr_el1_tbi_i       (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i      (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i      (tlb_d_tcr_el3_tbi0),
    .dpu_wpt_type_i            (dpu_wpt_type[2:0]),
    .dpu_wpt_link_i            (dpu_wpt_link),
    .dpu_wpt_taken_i           (dpu_wpt_taken),
    .dpu_wpt_target_isa_i      (dpu_wpt_target_isa[1:0]),
    .dpu_wpt_t32_nt16_i        (dpu_wpt_t32_nt16),
    .dpu_wpt_exception_type_i  (dpu_wpt_exception_type[3:0]),
    .dpu_wpt_non_secure_i      (dpu_wpt_non_secure),
    .dpu_wpt_exlevel_i         (dpu_wpt_exlevel[3:0]),
    .dpu_wpt_prohibited_i      (dpu_wpt_prohibited),
    .DFTSE                     (DFTSE),
    .gov_extin_i               (gov_extin_i[3:0]),
    .dpu_pmuevent_i            (dpu_pmuevent_o[25:0]),
    .gov_tsvalueb_i            (gov_tsvalueb_i[63:0]),
    .gov_dbgen_i               (gov_dbgen_i),
    .gov_niden_i               (gov_niden_i),
    // Outputs
    .etm_atvalidm_o            (etm_atvalidm_o),
    .etm_afreadym_o            (etm_afreadym_o),
    .etm_atdatam_o             (etm_atdatam_o[31:0]),
    .etm_atbytesm_o            (etm_atbytesm_o[1:0]),
    .etm_atidm_o               (etm_atidm_o[6:0]),
    .etm_prdatadbg_o           (etm_prdatadbg_o[31:0]),
    .etm_preadydbg_o           (etm_preadydbg_o),
    .etm_stall_cpu_o           (etm_stall_cpu),
    .etm_if_en_o               (etm_if_en),
    .etm_wfx_ready_o           (etm_wfx_ready_o),
    .etm_extout_o              (etm_extout_o[3:0]),
    .etm_oslock_o              (etm_oslock_o)
  );  // u_ca53etm

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign dc_dataram_en_o         = dc_dataram_en;
  assign dc_dataram_strb0_o      = dc_dataram_strb0;
  assign dc_dataram_strb1_o      = dc_dataram_strb1;
  assign dc_dataram_strb2_o      = dc_dataram_strb2;
  assign dc_dataram_strb3_o      = dc_dataram_strb3;
  assign dc_dataram_strb4_o      = dc_dataram_strb4;
  assign dc_dataram_strb5_o      = dc_dataram_strb5;
  assign dc_dataram_strb6_o      = dc_dataram_strb6;
  assign dc_dataram_strb7_o      = dc_dataram_strb7;
  assign dc_dataram_wr_o         = dc_dataram_wr;
  assign dc_dataram_wdata0_o     = dc_dataram_wdata0;
  assign dc_dataram_wdata1_o     = dc_dataram_wdata1;
  assign dc_dataram_wdata2_o     = dc_dataram_wdata2;
  assign dc_dataram_wdata3_o     = dc_dataram_wdata3;
  assign dc_dataram_wdata4_o     = dc_dataram_wdata4;
  assign dc_dataram_wdata5_o     = dc_dataram_wdata5;
  assign dc_dataram_wdata6_o     = dc_dataram_wdata6;
  assign dc_dataram_wdata7_o     = dc_dataram_wdata7;
  assign dc_dataram_addr0_o      = dc_dataram_addr0;
  assign dc_dataram_addr1_o      = dc_dataram_addr1;
  assign dc_dataram_addr2_o      = dc_dataram_addr2;
  assign dc_dataram_addr3_o      = dc_dataram_addr3;
  assign dc_dataram_addr4_o      = dc_dataram_addr4;
  assign dc_dataram_addr5_o      = dc_dataram_addr5;
  assign dc_dataram_addr6_o      = dc_dataram_addr6;
  assign dc_dataram_addr7_o      = dc_dataram_addr7;
  assign dc_tagram_en_o          = dc_tagram_en;
  assign dc_tagram_wr_o          = dc_tagram_wr;
  assign dc_tagram_wdata_o       = dc_tagram_wdata;
  assign dc_tagram_addr_o        = dc_tagram_addr;
  assign dc_dirtyram_en_o        = dc_dirtyram_en;
  assign dc_dirtyram_wr_o        = dc_dirtyram_wr;
  assign dc_dirtyram_strb_o      = dc_dirtyram_strb;
  assign dc_dirtyram_wdata_o     = dc_dirtyram_wdata;
  assign dc_dirtyram_addr_o      = dc_dirtyram_addr;
  assign ic_dataram_en_o         = ic_dataram_en;
  assign ic_dataram_wr_o         = ic_dataram_wr;
  assign ic_dataram_strb0_o      = ic_dataram_strb0;
  assign ic_dataram_strb1_o      = ic_dataram_strb1;
  assign ic_dataram_wdata0_o     = ic_dataram_wdata0;
  assign ic_dataram_wdata1_o     = ic_dataram_wdata1;
  assign ic_dataram_addr0_o      = ic_dataram_addr0;
  assign ic_dataram_addr1_o      = ic_dataram_addr1;
  assign ic_tagram_en_o          = ic_tagram_en;
  assign ic_tagram_wr_o          = ic_tagram_wr;
  assign ic_tagram_wdata_o       = ic_tagram_wdata;
  assign ic_tagram_addr_o        = ic_tagram_addr;
  assign tlb_ram_en_o            = tlb_ram_en;
  assign tlb_ram_wr_o            = tlb_ram_wr;
  assign tlb_ram_addr_o          = tlb_ram_addr;
  assign tlb_ram_wdata_o         = tlb_ram_wdata;
  assign biu_ar_valid_o          = biu_ar_valid;
  assign biu_ar_type_o           = biu_ar_type;
  assign biu_ar_addr_o           = biu_ar_addr;
  assign biu_ar_len_o            = biu_ar_len;
  assign biu_ar_size_o           = biu_ar_size;
  assign biu_ar_lock_o           = biu_ar_lock;
  assign biu_ar_attrs_o          = biu_ar_attrs;
  assign biu_ar_id_o             = biu_ar_id;
  assign biu_ar_way_o            = biu_ar_way;
  assign biu_dr_credit_o         = biu_dr_credit;
  assign biu_dw_valid_o          = biu_dw_valid;
  assign biu_dw_last_o           = biu_dw_last;
  assign biu_dw_data_o           = biu_dw_data;
  assign biu_dw_strb_o           = biu_dw_strb;
  assign dpu_ns_state_o          = dpu_ns_state;
  assign dpu_scr_el3_ns_o        = dpu_scr_el3_ns;
  assign dpu_aarch64_at_el3_o    = dpu_aarch64_at_el[3];

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Instantiate block interface checker modules. These are
  // automatically generated from the machine readable block
  // interface specifications

  ca53_biu_dpu u_ca53_biu_dpu (
    /*ARMAUTO*/
    // Inputs
    .clk                                        (clk),
    .reset_n                                    (reset_n),
    .dpu_dcache_on_i                            (dpu_dcache_on),
    .dpu_ramode_cnt_l1_i                        (dpu_ramode_cnt_l1[1:0]),
    .dpu_ramode_cnt_l2_i                        (dpu_ramode_cnt_l2[1:0]),
    .dpu_disable_device_split_throttle_i        (dpu_disable_device_split_throttle),
    .dpu_enable_data_prefetch_i                 (dpu_enable_data_prefetch[2:0]),
    .dpu_enable_data_prefetch_streams_i         (dpu_enable_data_prefetch_streams[1:0]),
    .dpu_data_prefetch_stride_detect_i          (dpu_data_prefetch_stride_detect),
    .dpu_disable_data_prefetch_stores_pattern_i (dpu_disable_data_prefetch_stores_pattern),
    .dpu_disable_data_prefetch_readunique_i     (dpu_disable_data_prefetch_readunique),
    .dpu_kill_wr_i                              (dpu_kill_wr),
    .dpu_flush_i                                (dpu_flush),
    .dpu_ready_wr_i                             (dpu_ready_wr),
    .dpu_ready_cc_fail_wr_i                     (dpu_ready_cc_fail_wr),
    .dpu_pa_dc1_i                               (dpu_pa_dc1[39:12]),
    .dpu_va_dc1_i                               (dpu_va_dc1[11:4]),
    .dpu_ns_dsc_dc1_i                           (dpu_ns_dsc_dc1),
    .dcu_load_dc1_i                             (dcu_load_dc1),
    .biu_w_imp_abort_i                          (biu_w_imp_abort),
    .biu_w_imp_fault_i                          (biu_w_imp_fault[1:0]),
    .biu_evnt_ext_mem_req_i                     (biu_evnt_ext_mem_req[1:0]),
    .biu_evnt_ext_mem_req_nc_i                  (biu_evnt_ext_mem_req_nc[1:0]),
    .biu_evnt_rw_lf_i                           (biu_evnt_rw_lf),
    .biu_evnt_pf_lf_i                           (biu_evnt_pf_lf),
    .biu_evnt_ramode_i                          (biu_evnt_ramode),
    .biu_evnt_ramode_enter_i                    (biu_evnt_ramode_enter)
  );  // u_ca53_biu_dpu

  ca53_dcu_biu u_ca53_dcu_biu (
    /*ARMAUTO*/
    // Inputs
    .clk                            (clk),
    .reset_n                        (reset_n),
    .biu_pld_l2_next_ready_i        (biu_pld_l2_next_ready),
    .biu_read_data_valid_dc2_i      (biu_read_data_valid_dc2),
    .biu_read_data_dc2_i            (biu_read_data_dc2[63:0]),
    .biu_read_abort_dc2_i           (biu_read_abort_dc2),
    .biu_read_fault_dc2_i           (biu_read_fault_dc2[1:0]),
    .biu_suppress_load_hit_dc2_i    (biu_suppress_load_hit_dc2),
    .biu_lf_ready_dc2_i             (biu_lf_ready_dc2),
    .biu_lf_next_ready_dc3_i        (biu_lf_next_ready_dc3),
    .biu_read_data_valid_dc3_i      (biu_read_data_valid_dc3),
    .biu_read_data_dc3_i            (biu_read_data_dc3[63:0]),
    .biu_read_abort_dc3_i           (biu_read_abort_dc3),
    .biu_read_fault_dc3_i           (biu_read_fault_dc3[1:0]),
    .biu_ecc_cinv_ack_i             (biu_ecc_cinv_ack),
    .biu_ecc_cinv_complete_i        (biu_ecc_cinv_complete),
    .biu_lf_in_progress_i           (biu_lf_in_progress[7:0]),
    .biu_pf_in_progress_i           (biu_pf_in_progress[3:0]),
    .biu_alloc_data_m0_i            (biu_alloc_data_m0[255:0]),
    .biu_alloc_tag_req_m0_i         (biu_alloc_tag_req_m0),
    .biu_alloc_data_req_m0_i        (biu_alloc_data_req_m0),
    .biu_alloc_halfline_m0_i        (biu_alloc_halfline_m0),
    .biu_alloc_dirty_req_m0_i       (biu_alloc_dirty_req_m0),
    .biu_alloc_addr_m0_i            (biu_alloc_addr_m0[39:4]),
    .biu_alloc_ns_dsc_m0_i          (biu_alloc_ns_dsc_m0),
    .biu_alloc_way_m0_i             (biu_alloc_way_m0[3:0]),
    .biu_alloc_tag_moesi_m0_i       (biu_alloc_tag_moesi_m0[1:0]),
    .biu_alloc_dirty_moesi_m1_i     (biu_alloc_dirty_moesi_m1[1:0]),
    .biu_alloc_dirty_age_m1_i       (biu_alloc_dirty_age_m1),
    .biu_alloc_attrs_m1_i           (biu_alloc_attrs_m1[7:0]),
    .biu_pf_tag_req_m0_i            (biu_pf_tag_req_m0),
    .biu_pf_tag_addr_m0_i           (biu_pf_tag_addr_m0[39:6]),
    .biu_pf_tag_ns_dsc_m0_i         (biu_pf_tag_ns_dsc_m0),
    .biu_ccb_lf_hazard_i            (biu_ccb_lf_hazard),
    .biu_strex_bresp_valid_i        (biu_strex_bresp_valid),
    .biu_strex_bresp_i              (biu_strex_bresp[1:0]),
    .biu_dirty_lf_in_progress_i     (biu_dirty_lf_in_progress),
    .biu_suppress_tlb_hit_i         (biu_suppress_tlb_hit),
    .dpu_kill_wr_i                  (dpu_kill_wr),
    .dpu_flush_i                    (dpu_flush),
    .dpu_ready_wr_i                 (dpu_ready_wr),
    .dpu_ready_cc_fail_wr_i         (dpu_ready_cc_fail_wr),
    .dpu_pa_dc1_i                   (dpu_pa_dc1[39:12]),
    .dpu_va_dc1_i                   (dpu_va_dc1[11:6]),
    .dpu_ns_dsc_dc1_i               (dpu_ns_dsc_dc1),
    .stb_slots_valid_i              (stb_slots_valid[4:0]),
    .stb_slots_dev_ng_i             (stb_slots_dev_ng[4:0]),
    .dcu_store_cp15_dc3_i           (dcu_store_cp15_dc3),
    .dcu_stb_attrs_dc3_i            (dcu_stb_attrs_dc3[7:0]),
    .stb_cache_data_req_m0_i        (stb_cache_data_req_m0),
    .stb_cache_data_wr_m0_i         (stb_cache_data_wr_m0),
    .dcu_stb_data_has_priority_m0_i (dcu_stb_data_has_priority_m0),
    .dcu_stb_data_ack_m1_i          (dcu_stb_data_ack_m1),
    .gov_mbist_req_i                (gov_mbist_req_i),
    .dcu_cache_walk_ack_m1_i        (dcu_cache_walk_ack_m1),
    .dcu_load_dc1_i                 (dcu_load_dc1),
    .dcu_leaving_dc1_i              (dcu_leaving_dc1),
    .dcu_lf_active_i                (dcu_lf_active),
    .dcu_load_dc2_i                 (dcu_load_dc2),
    .dcu_pa_dc2_i                   (dcu_pa_dc2[39:0]),
    .dcu_ns_dsc_dc2_i               (dcu_ns_dsc_dc2),
    .dcu_attrs_dc2_i                (dcu_attrs_dc2[7:0]),
    .dcu_size_dc2_i                 (dcu_size_dc2[1:0]),
    .dcu_length_dc2_i               (dcu_length_dc2[3:0]),
    .dcu_pld_l2_req_dc2_i           (dcu_pld_l2_req_dc2),
    .dcu_exclusive_dc2_i            (dcu_exclusive_dc2),
    .dcu_lf_req_dc1_i               (dcu_lf_req_dc1),
    .dcu_lf_way_dc1_i               (dcu_lf_way_dc1[1:0]),
    .dcu_attrs_dc1_i                (dcu_attrs_dc1[7:0]),
    .dcu_lf_req_dc2_i               (dcu_lf_req_dc2),
    .dcu_lf_way_dc2_i               (dcu_lf_way_dc2[1:0]),
    .dcu_biu_req_dc2_i              (dcu_biu_req_dc2),
    .dcu_biu_active_i               (dcu_biu_active),
    .dcu_leaving_dc2_i              (dcu_leaving_dc2),
    .dcu_load_dc3_i                 (dcu_load_dc3),
    .dcu_lf_req_dc3_i               (dcu_lf_req_dc3),
    .dcu_lf_way_dc3_i               (dcu_lf_way_dc3[1:0]),
    .dcu_neon_access_dc3_i          (dcu_neon_access_dc3),
    .dcu_biu_req_dc3_i              (dcu_biu_req_dc3),
    .dcu_stb_req_dc3_i              (dcu_stb_req_dc3),
    .dcu_pa_dc3_i                   (dcu_pa_dc3[39:0]),
    .dcu_pipe_valid_dc3_i           (dcu_pipe_valid_dc3),
    .dcu_valid_dc3_i                (dcu_valid_dc3),
    .dcu_ns_dsc_dc3_i               (dcu_ns_dsc_dc3),
    .dcu_priv_dc3_i                 (dcu_priv_dc3),
    .dcu_attrs_dc3_i                (dcu_attrs_dc3[7:0]),
    .dcu_size_dc3_i                 (dcu_size_dc3[1:0]),
    .dcu_length_dc3_i               (dcu_length_dc3[3:0]),
    .dcu_exclusive_dc3_i            (dcu_exclusive_dc3),
    .dcu_pldw_dc3_i                 (dcu_pldw_dc3),
    .dcu_pld_l2_req_dc3_i           (dcu_pld_l2_req_dc3),
    .dcu_stop_pf_i                  (dcu_stop_pf),
    .dcu_drain_stb_lf_i             (dcu_drain_stb_lf),
    .dcu_ecc_cinv_req_i             (dcu_ecc_cinv_req),
    .dcu_ecc_cinv_index_i           (dcu_ecc_cinv_index[7:0]),
    .dcu_ecc_cinv_way_i             (dcu_ecc_cinv_way[1:0]),
    .dcu_ecc_syndrome_m3_i          (dcu_ecc_syndrome_m3[55:0]),
    .dcu_ecc_fatal_m3_i             (dcu_ecc_fatal_m3),
    .dcu_ecc_tag_err_m3_i           (dcu_ecc_tag_err_m3),
    .dcu_snoop_dw_active_i          (dcu_snoop_dw_active),
    .dcu_snoop_valid_m2_i           (dcu_snoop_valid_m2),
    .dcu_snoop_data_m2_i            (dcu_snoop_data_m2[255:0]),
    .dcu_snoop_chunk_m2_i           (dcu_snoop_chunk_m2[1:0]),
    .dcu_snoop_rotate_m2_i          (dcu_snoop_rotate_m2[1:0]),
    .dcu_snoop_l2db_id_m2_i         (dcu_snoop_l2db_id_m2[3:0]),
    .dcu_snoop_last_m2_i            (dcu_snoop_last_m2),
    .dcu_alloc_has_priority_m0_i    (dcu_alloc_has_priority_m0),
    .dcu_alloc_ack_m1_i             (dcu_alloc_ack_m1),
    .dcu_pf_tag_has_priority_m0_i   (dcu_pf_tag_has_priority_m0),
    .dcu_pf_tag_ack_m1_i            (dcu_pf_tag_ack_m1),
    .dcu_pf_tag_hit_m2_i            (dcu_pf_tag_hit_m2),
    .dcu_ccb_req_active_i           (dcu_ccb_req_active),
    .dcu_ccb_ways_i                 (dcu_ccb_ways[3:0]),
    .dcu_ccb_index_i                (dcu_ccb_index[13:6]),
    .dcu_mbist_out_data_mb6_i       (dcu_mbist_out_data_mb6[63:0]),
    .dcu_mbist_data_checkbits_mb6_i (dcu_mbist_data_checkbits_mb6[6:0]),
    .dcu_mbist_array_mb3_i          (dcu_mbist_array_mb3[8:0])
  );  // u_ca53_dcu_biu

  ca53_dcu_stb #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_dcu_stb (
    /*ARMAUTO*/
    // Inputs
    .clk                            (clk),
    .reset_n                        (reset_n),
    .stb_slots_valid_i              (stb_slots_valid[4:0]),
    .stb_slots_emptying_i           (stb_slots_emptying[4:0]),
    .stb_slots_dev_ng_i             (stb_slots_dev_ng[4:0]),
    .stb_slots_dsb_i                (stb_slots_dsb[4:0]),
    .stb_block_loads_dc1_i          (stb_block_loads_dc1),
    .stb_cacheable_strex_done_i     (stb_cacheable_strex_done),
    .stb_strex_failed_i             (stb_strex_failed),
    .stb_can_merge_dc2_i            (stb_can_merge_dc2[4:0]),
    .stb_sameline_dc2_i             (stb_sameline_dc2[4:0]),
    .stb_load_sameline_dc2_i        (stb_load_sameline_dc2[4:0]),
    .stb_attr_mismatch_dc2_i        (stb_attr_mismatch_dc2),
    .stb_hit_dc2_i                  (stb_hit_dc2[7:0]),
    .stb_data_dc2_i                 (stb_data_dc2[63:0]),
    .stb_force_non_mergeable_i      (stb_force_non_mergeable),
    .stb_cache_tag_req_m0_i         (stb_cache_tag_req_m0),
    .stb_cache_tag_wr_m0_i          (stb_cache_tag_wr_m0),
    .stb_cache_tag_way_m0_i         (stb_cache_tag_way_m0[3:0]),
    .stb_cache_tag_addr_m0_i        (stb_cache_tag_addr_m0[39:6]),
    .stb_cache_tag_ns_dsc_m0_i      (stb_cache_tag_ns_dsc_m0),
    .stb_cache_data_req_m0_i        (stb_cache_data_req_m0),
    .stb_cache_data_wr_m0_i         (stb_cache_data_wr_m0),
    .stb_cache_data_addr_m0_i       (stb_cache_data_addr_m0[13:4]),
    .stb_cache_data_way_m0_i        (stb_cache_data_way_m0[3:0]),
    .stb_cache_write_data_m0_i      (stb_cache_write_data_m0[127:0]),
    .stb_cache_data_bls_m0_i        (stb_cache_data_bls_m0[15:0]),
    .stb_cache_data_attrs_m0_i      (stb_cache_data_attrs_m0[7:0]),
    .stb_cache_data_migratory_m0_i  (stb_cache_data_migratory_m0),
    .stb_block_ccb_i                (stb_block_ccb),
    .stb_defer_ccb_i                (stb_defer_ccb),
    .dpu_kill_wr_i                  (dpu_kill_wr),
    .biu_ev_hazard_i                (biu_ev_hazard[4:0]),
    .stb_lf_merge_i                 (stb_lf_merge[4:0]),
    .biu_lf_can_merge_i             (biu_lf_can_merge[4:0]),
    .dcu_drain_entire_stb_i         (dcu_drain_entire_stb),
    .dcu_drain_slots_i              (dcu_drain_slots[4:0]),
    .dcu_exclusive_monitor_i        (dcu_exclusive_monitor),
    .dcu_store_dc1_i                (dcu_store_dc1),
    .dcu_valid_dc2_i                (dcu_valid_dc2),
    .dcu_store_dc2_i                (dcu_store_dc2),
    .dcu_pa_dc2_i                   (dcu_pa_dc2[39:3]),
    .dcu_ns_dsc_dc2_i               (dcu_ns_dsc_dc2),
    .dcu_attrs_dc2_i                (dcu_attrs_dc2[7:0]),
    .dcu_leaving_dc2_i              (dcu_leaving_dc2),
    .dcu_store_dc3_i                (dcu_store_dc3),
    .dcu_stb_req_dc3_i              (dcu_stb_req_dc3),
    .dcu_stlr_dc3_i                 (dcu_stlr_dc3),
    .dcu_store_merge_dc3_i          (dcu_store_merge_dc3[4:0]),
    .dcu_store_sameline_dc3_i       (dcu_store_sameline_dc3[4:0]),
    .dcu_load_sameline_dc3_i        (dcu_load_sameline_dc3[4:0]),
    .dcu_pa_dc3_i                   (dcu_pa_dc3[39:0]),
    .dcu_ns_dsc_dc3_i               (dcu_ns_dsc_dc3),
    .dcu_priv_dc3_i                 (dcu_priv_dc3),
    .dcu_stb_exclusive_dc3_i        (dcu_stb_exclusive_dc3),
    .dcu_store_cp15_dc3_i           (dcu_store_cp15_dc3),
    .dcu_dvm_sync_needed_dc3_i      (dcu_dvm_sync_needed_dc3),
    .dcu_store_dmb_dc3_i            (dcu_store_dmb_dc3),
    .dcu_store_dsb_dc3_i            (dcu_store_dsb_dc3),
    .dcu_stb_attrs_dc3_i            (dcu_stb_attrs_dc3[7:0]),
    .dcu_store_bls_dc3_i            (dcu_store_bls_dc3[15:0]),
    .dcu_store_last_dc3_i           (dcu_store_last_dc3),
    .dcu_force_non_mergeable_dc3_i  (dcu_force_non_mergeable_dc3),
    .dcu_stb_tag_has_priority_m0_i  (dcu_stb_tag_has_priority_m0),
    .dcu_stb_tag_ack_m1_i           (dcu_stb_tag_ack_m1),
    .dcu_stb_tag_hit_m2_i           (dcu_stb_tag_hit_m2[3:0]),
    .dcu_stb_tag_shared_m2_i        (dcu_stb_tag_shared_m2),
    .dcu_stb_tag_migratory_m2_i     (dcu_stb_tag_migratory_m2),
    .dcu_stb_victim_way_m2_i        (dcu_stb_victim_way_m2[3:0]),
    .dcu_ecc_data_err_m3_i          (dcu_ecc_data_err_m3),
    .dcu_ecc_tag_err_m2_i           (dcu_ecc_tag_err_m2),
    .dcu_ecc_in_progress_i          (dcu_ecc_in_progress),
    .dcu_stb_data_has_priority_m0_i (dcu_stb_data_has_priority_m0),
    .dcu_stb_data_ack_m1_i          (dcu_stb_data_ack_m1),
    .dcu_stb_read_data_m2_i         (dcu_stb_read_data_m2[127:0]),
    .dcu_ccb_req_valid_i            (dcu_ccb_req_valid),
    .dcu_ccb_index_i                (dcu_ccb_index[13:6]),
    .dcu_ccb_ways_i                 (dcu_ccb_ways[3:0])
  );  // u_ca53_dcu_stb

  ca53_stb_biu u_ca53_stb_biu (
    /*ARMAUTO*/
    // Inputs
    .clk                            (clk),
    .reset_n                        (reset_n),
    .biu_lf_hazard_i                (biu_lf_hazard[4:0]),
    .biu_lf_real_hazard_i           (biu_lf_real_hazard[4:0]),
    .biu_lf_hazard_migratory_i      (biu_lf_hazard_migratory[4:0]),
    .biu_lf_hazard_way_slot0_i      (biu_lf_hazard_way_slot0[1:0]),
    .biu_lf_hazard_way_slot1_i      (biu_lf_hazard_way_slot1[1:0]),
    .biu_lf_hazard_way_slot2_i      (biu_lf_hazard_way_slot2[1:0]),
    .biu_lf_hazard_way_slot3_i      (biu_lf_hazard_way_slot3[1:0]),
    .biu_lf_hazard_way_slot4_i      (biu_lf_hazard_way_slot4[1:0]),
    .biu_lf_serialized_i            (biu_lf_serialized[4:0]),
    .biu_ev_hazard_i                (biu_ev_hazard[4:0]),
    .biu_lf_can_merge_i             (biu_lf_can_merge[4:0]),
    .biu_stb_write_accept_i         (biu_stb_write_accept),
    .biu_read_alloc_mode_i          (biu_read_alloc_mode),
    .biu_stb_ar_ack_i               (biu_stb_ar_ack),
    .biu_stb_ar_resp_valid_i        (biu_stb_ar_resp_valid),
    .biu_stb_ar_resp_i              (biu_stb_ar_resp[1:0]),
    .biu_stb_ar_resp_id_i           (biu_stb_ar_resp_id[4:0]),
    .biu_stb_ar_resp_l2dbid_i       (biu_stb_ar_resp_l2dbid[3:0]),
    .biu_dirty_lf_in_progress_i     (biu_dirty_lf_in_progress),
    .biu_excl_lf_in_progress_i      (biu_excl_lf_in_progress),
    .dcu_stb_req_dc3_i              (dcu_stb_req_dc3),
    .dcu_store_cp15_dc3_i           (dcu_store_cp15_dc3),
    .dcu_pa_dc3_i                   (dcu_pa_dc3[39:0]),
    .dcu_ns_dsc_dc3_i               (dcu_ns_dsc_dc3),
    .stb_cache_data_req_m0_i        (stb_cache_data_req_m0),
    .stb_cache_data_wr_m0_i         (stb_cache_data_wr_m0),
    .dcu_stb_data_has_priority_m0_i (dcu_stb_data_has_priority_m0),
    .dcu_stb_data_ack_m1_i          (dcu_stb_data_ack_m1),
    .scu_dvm_complete_i             (scu_dvm_complete_i),
    .stb_slots_valid_i              (stb_slots_valid[4:0]),
    .stb_slot0_addr_i               (stb_slot0_addr[39:0]),
    .stb_slot1_addr_i               (stb_slot1_addr[39:0]),
    .stb_slot2_addr_i               (stb_slot2_addr[39:0]),
    .stb_slot3_addr_i               (stb_slot3_addr[39:0]),
    .stb_slot4_addr_i               (stb_slot4_addr[39:0]),
    .stb_slots_ns_dsc_i             (stb_slots_ns_dsc[4:0]),
    .stb_slot0_way_i                (stb_slot0_way[1:0]),
    .stb_slot1_way_i                (stb_slot1_way[1:0]),
    .stb_slot2_way_i                (stb_slot2_way[1:0]),
    .stb_slot3_way_i                (stb_slot3_way[1:0]),
    .stb_slot4_way_i                (stb_slot4_way[1:0]),
    .stb_slot0_attrs_i              (stb_slot0_attrs[7:0]),
    .stb_slot1_attrs_i              (stb_slot1_attrs[7:0]),
    .stb_slot2_attrs_i              (stb_slot2_attrs[7:0]),
    .stb_slot3_attrs_i              (stb_slot3_attrs[7:0]),
    .stb_slot4_attrs_i              (stb_slot4_attrs[7:0]),
    .stb_lf_active_i                (stb_lf_active),
    .stb_lf_req_i                   (stb_lf_req[4:0]),
    .stb_lf_earliest_slot_i         (stb_lf_earliest_slot[4:0]),
    .stb_lf_merge_i                 (stb_lf_merge[4:0]),
    .stb_slot_cachewrite_m1_i       (stb_slot_cachewrite_m1[4:0]),
    .stb_biu_write_req_i            (stb_biu_write_req),
    .stb_biu_write_l2dbid_i         (stb_biu_write_l2dbid[3:0]),
    .stb_biu_write_chunk_i          (stb_biu_write_chunk[1:0]),
    .stb_biu_write_data_i           (stb_biu_write_data[127:0]),
    .stb_biu_write_bls_i            (stb_biu_write_bls[15:0]),
    .stb_biu_write_last_i           (stb_biu_write_last),
    .stb_biu_write_req_active_i     (stb_biu_write_req_active),
    .stb_ar_req_i                   (stb_ar_req),
    .stb_ar_early_req_i             (stb_ar_early_req),
    .stb_ar_id_i                    (stb_ar_id[4:0]),
    .stb_ar_way_i                   (stb_ar_way[1:0]),
    .stb_ar_type_i                  (stb_ar_type[7:0]),
    .stb_ar_addr_i                  (stb_ar_addr[39:0]),
    .stb_ar_ns_dsc_i                (stb_ar_ns_dsc),
    .stb_ar_attrs_i                 (stb_ar_attrs[7:0]),
    .stb_ar_priv_i                  (stb_ar_priv),
    .stb_ar_excl_i                  (stb_ar_excl),
    .stb_ar_asid_i                  (stb_ar_asid[15:0]),
    .stb_ar_vmid_i                  (stb_ar_vmid[7:0]),
    .stb_ar_va_i                    (stb_ar_va[24:0])
  );  // u_ca53_stb_biu

  ca53_tlb_rams #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_tlb_rams (
    /*ARMAUTO*/
    // Inputs
    .clk              (clk),
    .reset_n          (reset_n),
    .tlb_ram_rdata0_i (tlb_ram_rdata0_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata1_i (tlb_ram_rdata1_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata2_i (tlb_ram_rdata2_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata3_i (tlb_ram_rdata3_i[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_en_i     (tlb_ram_en[3:0]),
    .tlb_ram_wr_i     (tlb_ram_wr),
    .tlb_ram_addr_i   (tlb_ram_addr[`CA53_TLB_RAM_ADDR_W-1:0]),
    .tlb_ram_wdata_i  (tlb_ram_wdata[`CA53_TLB_RAM_W-1:0])
  );  // u_ca53_tlb_rams

  ca53_dcu_tlb u_ca53_dcu_tlb (
    /*ARMAUTO*/
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .tlb_d_utlb_enable_i              (tlb_d_utlb_enable),
    .tlb_wpt_hit_dc1_i                (tlb_wpt_hit_dc1[15:0]),
    .tlb_cache_walk_lookup_req_m0_i   (tlb_cache_walk_lookup_req_m0[1:0]),
    .tlb_cache_walk_addr_i            (tlb_cache_walk_addr[39:3]),
    .tlb_cache_walk_ns_dsc_i          (tlb_cache_walk_ns_dsc),
    .tlb_cp_read_data_dc2_i           (tlb_cp_read_data_dc2[63:0]),
    .tlb_pagewalk_invalidated_i       (tlb_pagewalk_invalidated),
    .tlb_cp_reg_write_ready_i         (tlb_cp_reg_write_ready),
    .tlb_cp_ack_i                     (tlb_cp_ack),
    .tlb_d_tcr_el1_tbi_i              (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i             (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i             (tlb_d_tcr_el3_tbi0),
    .tlb_vmid_i                       (tlb_vmid[7:0]),
    .dpu_utlb_hit_dc1_i               (dpu_utlb_hit_dc1),
    .tlb_d_utlb_flush_i               (tlb_d_utlb_flush),
    .dcu_va_valid_early_dc1_i         (dcu_va_valid_early_dc1),
    .dcu_va_valid_dc1_i               (dcu_va_valid_dc1),
    .dcu_ongoing_burst_dc1_i          (dcu_ongoing_burst_dc1),
    .dcu_store_dc1_i                  (dcu_store_dc1),
    .dcu_wpt_check_512_dc1_i          (dcu_wpt_check_512_dc1),
    .dcu_priv_dc1_i                   (dcu_priv_dc1),
    .dcu_transl_type_dc1_i            (dcu_transl_type_dc1[2:0]),
    .dcu_cache_walk_has_priority_m0_i (dcu_cache_walk_has_priority_m0),
    .dcu_cache_walk_ack_m1_i          (dcu_cache_walk_ack_m1),
    .dcu_cache_walk_hit_m2_i          (dcu_cache_walk_hit_m2),
    .dcu_cache_walk_data_m2_i         (dcu_cache_walk_data_m2[63:0]),
    .dcu_cache_walk_victim_way_m2_i   (dcu_cache_walk_victim_way_m2[3:0]),
    .dcu_ecc_err_m3_i                 (dcu_ecc_err_m3),
    .dcu_cp_reg_en_dc2_i              (dcu_cp_reg_en_dc2[5:0]),
    .dcu_block_lookups_i              (dcu_block_lookups),
    .dcu_cp_reg_write_dc3_i           (dcu_cp_reg_write_dc3),
    .dcu_cp_reg_write_active_i        (dcu_cp_reg_write_active),
    .dcu_cp_reg_en_dc3_i              (dcu_cp_reg_en_dc3[5:0]),
    .dcu_cp_reg_data_i                (dcu_cp_reg_data[63:0]),
    .dcu_cp_reg_size_i                (dcu_cp_reg_size),
    .dcu_cp_valid_tlb_i               (dcu_cp_valid_tlb),
    .dcu_cp_addr_tlb_i                (dcu_cp_addr_tlb[61:0]),
    .dcu_cp_ns_i                      (dcu_cp_ns),
    .dcu_cp_op_tlb_i                  (dcu_cp_op_tlb[4:0])
  );  // u_ca53_dcu_tlb

  ca53_dpu_tlb u_ca53_dpu_tlb (
    /*ARMAUTO*/
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .tlb_d_utlb_flush_i           (tlb_d_utlb_flush),
    .tlb_d_utlb_enable_i          (tlb_d_utlb_enable),
    .tlb_d_utlb_might_enable_i    (tlb_d_utlb_might_enable),
    .tlb_d_utlb_lpae_i            (tlb_d_utlb_lpae),
    .tlb_d_utlb_valid_i           (tlb_d_utlb_valid),
    .tlb_d_utlb_data_i            (tlb_d_utlb_data[95:0]),
    .tlb_lpae_mode_i              (tlb_lpae_mode),
    .tlb_lpae_mode_s_i            (tlb_lpae_mode_s),
    .tlb_d_tcr_el1_tbi_i          (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i         (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i         (tlb_d_tcr_el3_tbi0),
    .tlb_dbg_rdata_i              (tlb_dbg_rdata[31:0]),
    .tlb_evnt_data_pagewalk_i     (tlb_evnt_data_pagewalk),
    .tlb_evnt_instr_pagewalk_i    (tlb_evnt_instr_pagewalk),
    .tlb_pty_valid_i              (tlb_pty_valid),
    .tlb_pty_way_bank_id_i        (tlb_pty_way_bank_id[1:0]),
    .tlb_pty_index_i              (tlb_pty_index[7:0]),
    .dpu_va_dc1_i                 (dpu_va_dc1[63:0]),
    .dpu_utlb_hit_dc1_i           (dpu_utlb_hit_dc1),
    .dpu_tlb_abandon_i            (dpu_tlb_abandon),
    .dpu_scr_el3_ns_i             (dpu_scr_el3_ns),
    .dpu_ns_state_i               (dpu_ns_state),
    .dpu_mmu_on_el1_i             (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_i             (dpu_mmu_on_el2),
    .dpu_mmu_on_el3_i             (dpu_mmu_on_el3),
    .dpu_dcache_on_el1_i          (dpu_dcache_on_el1),
    .dpu_dcache_on_el2_i          (dpu_dcache_on_el2),
    .dpu_dcache_on_el3_i          (dpu_dcache_on_el3),
    .dpu_icache_on_i              (dpu_icache_on),
    .dpu_sctlr_uwxn_el3_i         (dpu_sctlr_uwxn_el3),
    .dpu_sctlr_uwxn_el1_i         (dpu_sctlr_uwxn_el1),
    .dpu_sctlr_wxn_el3_i          (dpu_sctlr_wxn_el3),
    .dpu_sctlr_wxn_el1_i          (dpu_sctlr_wxn_el1),
    .dpu_sctlr_wxn_el2_i          (dpu_sctlr_wxn_el2),
    .dpu_access_flag_enable_el3_i (dpu_access_flag_enable_el3),
    .dpu_access_flag_enable_el1_i (dpu_access_flag_enable_el1),
    .dpu_tex_remap_enable_el3_i   (dpu_tex_remap_enable_el3),
    .dpu_tex_remap_enable_el1_i   (dpu_tex_remap_enable_el1),
    .dpu_endian_el3_i             (dpu_endian_el3),
    .dpu_endian_el1_i             (dpu_endian_el1),
    .dpu_endian_el2_i             (dpu_endian_el2),
    .dpu_hivecs_i                 (dpu_hivecs),
    .dpu_dbg_vid_i                (dpu_dbg_vid[3:0]),
    .dpu_s2_dcache_on_i           (dpu_s2_dcache_on),
    .dpu_vec_base_s_dc1_i         (dpu_vec_base_s_dc1[31:5]),
    .dpu_vec_base_ns_dc1_i        (dpu_vec_base_ns_dc1[31:5]),
    .dpu_mon_vec_base_dc1_i       (dpu_mon_vec_base_dc1[31:5]),
    .dpu_mode_iss_i               (dpu_mode_iss[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el[3:1]),
    .dpu_dbg_tlb_sw_bkpt_wpt_en_i (dpu_dbg_tlb_sw_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en),
    .dpu_dbg_sample_contextid_i   (dpu_dbg_sample_contextid),
    .dpu_default_cacheable_i      (dpu_default_cacheable),
    .dpu_ipa_to_pa_en_i           (dpu_ipa_to_pa_en),
    .dpu_pr_tablewalk_i           (dpu_pr_tablewalk),
    .dpu_apb_active_i             (dpu_apb_active),
    .dpu_dbg_wr_i                 (dpu_dbg_wr),
    .dpu_dbg_addr_i               (dpu_dbg_addr[11:2]),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata[31:0])
  );  // u_ca53_dpu_tlb

  ca53_dpu_scu u_ca53_dpu_scu (
    /*ARMAUTO*/
    // Inputs
    .clk                     (clk),
    .reset_n                 (reset_n),
    .scu_evnt_l2_access_i    (scu_evnt_l2_access_i),
    .scu_evnt_l2_refill_i    (scu_evnt_l2_refill_i),
    .scu_evnt_l2_wb_i        (scu_evnt_l2_wb_i),
    .scu_evnt_snooped_data_i (scu_evnt_snooped_data_i),
    .scu_evnt_bus_cycle_i    (scu_evnt_bus_cycle_i),
    .scu_evnt_bus_acc_rd_i   (scu_evnt_bus_acc_rd_i),
    .scu_evnt_bus_acc_wr_i   (scu_evnt_bus_acc_wr_i),
    .scu_evnt_eviction_i     (scu_evnt_eviction_i)
  );  // u_ca53_dpu_scu

  ca53_dpu_l2rams u_ca53_dpu_l2rams (
    /*ARMAUTO*/
    // Inputs
    .clk       (clk),
    .reset_n   (reset_n),
    .l2_size_i (l2_size_i[3:0])
  );  // u_ca53_dpu_l2rams

  ca53_dpu_etm u_ca53_dpu_etm (
    /*ARMAUTO*/
    // Inputs
    .clk                       (clk),
    .po_reset_n                (po_reset_n),
    .etm_if_en_i               (etm_if_en),
    .etm_stall_cpu_i           (etm_stall_cpu),
    .gov_wfx_drain_req_i       (gov_wfx_drain_req_i),
    .tlb_d_tcr_el1_tbi_i       (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i      (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i      (tlb_d_tcr_el3_tbi0),
    .dpu_wpt_valid_i           (dpu_wpt_valid),
    .dpu_wpt_addr_i            (dpu_wpt_addr[63:1]),
    .dpu_wpt_target_addr_opa_i (dpu_wpt_target_addr_opa[63:1]),
    .dpu_wpt_target_addr_opb_i (dpu_wpt_target_addr_opb[27:1]),
    .dpu_wpt_advance_i         (dpu_wpt_advance),
    .dpu_wpt_range_i           (dpu_wpt_range),
    .dpu_wpt_type_i            (dpu_wpt_type[2:0]),
    .dpu_wpt_link_i            (dpu_wpt_link),
    .dpu_wpt_taken_i           (dpu_wpt_taken),
    .dpu_wpt_target_isa_i      (dpu_wpt_target_isa[1:0]),
    .dpu_wpt_t32_nt16_i        (dpu_wpt_t32_nt16),
    .dpu_wpt_exception_type_i  (dpu_wpt_exception_type[3:0]),
    .dpu_wpt_non_secure_i      (dpu_wpt_non_secure),
    .dpu_wpt_exlevel_i         (dpu_wpt_exlevel[3:0]),
    .dpu_wpt_prohibited_i      (dpu_wpt_prohibited),
    .dpu_pmuevent_i            (dpu_pmuevent_o[25:0])
  );  // u_ca53_dpu_etm

  ca53_tlb_etm u_ca53_tlb_etm (
    /*ARMAUTO*/
    // Inputs
    .clk                 (clk),
    .po_reset_n          (po_reset_n),
    .tlb_context_id_i    (tlb_context_id[31:0]),
    .tlb_vmid_i          (tlb_vmid[7:0])
  );  // u_ca53_tlb_etm


  ca53_stb_dpu u_ca53_stb_dpu (
    /*ARMAUTO*/
    // Inputs
    .clk                  (clk),
    .reset_n              (reset_n),
    .dpu_store_iss_i      (dpu_store_iss),
    .dpu_kill_wr_i        (dpu_kill_wr),
    .dpu_st_data_wr_i     (dpu_st_data_wr[127:0]),
    .dpu_disable_dmb_i    (dpu_disable_dmb),
    .stb_evnt_stb_stall_i (stb_evnt_stb_stall)
  );  // u_ca53_stb_dpu

  ca53_biu_tlb u_ca53_biu_tlb (
    /*ARMAUTO*/
    // Inputs
    .clk                        (clk),
    .reset_n                    (reset_n),
    .tlb_mem_granule_i          (tlb_mem_granule[1:0]),
    .tlb_walk_lf_active_i       (tlb_walk_lf_active),
    .tlb_walk_nc_req_i          (tlb_walk_nc_req),
    .tlb_walk_lf_req_i          (tlb_walk_lf_req),
    .tlb_walk_addr_i            (tlb_walk_addr[39:0]),
    .tlb_walk_ns_dsc_i          (tlb_walk_ns_dsc),
    .tlb_walk_size_i            (tlb_walk_size),
    .tlb_walk_attrs_i           (tlb_walk_attrs[7:0]),
    .tlb_walk_way_i             (tlb_walk_way[1:0]),
    .tlb_mbist_out_data_mb6_i   (tlb_mbist_out_data_mb6[116:0]),
    .gov_mbist_req_i            (gov_mbist_req_i),
    .dcu_cp_addr_tlb_i          (dcu_cp_addr_tlb[61:0]),
    .biu_walk_ack_i             (biu_walk_ack),
    .biu_walk_resp_i            (biu_walk_resp[2:0]),
    .biu_walk_data_i            (biu_walk_data[63:0]),
    .biu_walk_lf_hazard_i       (biu_walk_lf_hazard),
    .biu_mbist_in_data_hi_mb3_i (biu_mbist_in_data_hi_mb3[52:0])
  );  // u_ca53_biu_tlb

  ca53_dcu_rams #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_dcu_rams (
    /*ARMAUTO*/
    // Inputs
    .clk                 (clk),
    .reset_n             (reset_n),
    .dc_size_i           (dc_size_i[2:0]),
    .dc_tagram_rdata0_i  (dc_tagram_rdata0_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata1_i  (dc_tagram_rdata1_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata2_i  (dc_tagram_rdata2_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata3_i  (dc_tagram_rdata3_i[(`CA53_DTAG_RAM_W-1):0]),
    .dc_dataram_rdata0_i (dc_dataram_rdata0_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata1_i (dc_dataram_rdata1_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata2_i (dc_dataram_rdata2_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata3_i (dc_dataram_rdata3_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata4_i (dc_dataram_rdata4_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata5_i (dc_dataram_rdata5_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata6_i (dc_dataram_rdata6_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata7_i (dc_dataram_rdata7_i[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_rdata_i (dc_dirtyram_rdata_i[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_tagram_en_i      (dc_tagram_en[3:0]),
    .dc_tagram_wr_i      (dc_tagram_wr),
    .dc_tagram_wdata_i   (dc_tagram_wdata[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_addr_i    (dc_tagram_addr[7:0]),
    .dc_dataram_en_i     (dc_dataram_en[7:0]),
    .dc_dataram_wr_i     (dc_dataram_wr),
    .dc_dataram_strb0_i  (dc_dataram_strb0[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb1_i  (dc_dataram_strb1[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb2_i  (dc_dataram_strb2[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb3_i  (dc_dataram_strb3[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb4_i  (dc_dataram_strb4[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb5_i  (dc_dataram_strb5[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb6_i  (dc_dataram_strb6[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb7_i  (dc_dataram_strb7[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_addr0_i  (dc_dataram_addr0[10:0]),
    .dc_dataram_addr1_i  (dc_dataram_addr1[10:0]),
    .dc_dataram_addr2_i  (dc_dataram_addr2[10:0]),
    .dc_dataram_addr3_i  (dc_dataram_addr3[10:0]),
    .dc_dataram_addr4_i  (dc_dataram_addr4[10:0]),
    .dc_dataram_addr5_i  (dc_dataram_addr5[10:0]),
    .dc_dataram_addr6_i  (dc_dataram_addr6[10:0]),
    .dc_dataram_addr7_i  (dc_dataram_addr7[10:0]),
    .dc_dataram_wdata0_i (dc_dataram_wdata0[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata1_i (dc_dataram_wdata1[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata2_i (dc_dataram_wdata2[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata3_i (dc_dataram_wdata3[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata4_i (dc_dataram_wdata4[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata5_i (dc_dataram_wdata5[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata6_i (dc_dataram_wdata6[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata7_i (dc_dataram_wdata7[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dirtyram_en_i    (dc_dirtyram_en),
    .dc_dirtyram_wr_i    (dc_dirtyram_wr),
    .dc_dirtyram_strb_i  (dc_dirtyram_strb[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_dirtyram_addr_i  (dc_dirtyram_addr[8:0]),
    .dc_dirtyram_wdata_i (dc_dirtyram_wdata[(`CA53_DDIRTY_RAM_W-1):0])
  );  // u_ca53_dcu_rams

  ca53_dpu_dcu u_ca53_dpu_dcu (
    /*ARMAUTO*/
    // Inputs
    .clk                         (clk),
    .reset_n                     (reset_n),
    .dcu_ready_cp_iss_i          (dcu_ready_cp_iss),
    .dcu_ready_iss_i             (dcu_ready_iss),
    .dcu_valid_dc3_i             (dcu_valid_dc3),
    .dcu_ld_data_dc3_i           (dcu_ld_data_dc3[63:0]),
    .dcu_strex_okay_dc3_i        (dcu_strex_okay_dc3),
    .dcu_wpt_hit_dc3_i           (dcu_wpt_hit_dc3),
    .dcu_p_abort_dc3_i           (dcu_p_abort_dc3),
    .dcu_ecc_err_dc3_i           (dcu_ecc_err_dc3),
    .dcu_p_domain_dc3_i          (dcu_p_domain_dc3[3:0]),
    .dcu_p_fault_dc3_i           (dcu_p_fault_dc3[6:0]),
    .dcu_p_fault_stage_dc3_i     (dcu_p_fault_stage_dc3[1:0]),
    .dcu_v2p_lpae_dc3_i          (dcu_v2p_lpae_dc3),
    .dcu_p_direction_dc3_i       (dcu_p_direction_dc3),
    .dcu_cm_operation_dc3_i      (dcu_cm_operation_dc3),
    .dcu_va_dc3_i                (dcu_va_dc3[63:0]),
    .dcu_pa_dc3_i                (dcu_pa_dc3[39:12]),
    .dcu_dbg_dsb_ack_i           (dcu_dbg_dsb_ack),
    .dcu_evnt_dc_access_i        (dcu_evnt_dc_access),
    .dcu_ecc_fatal_i             (dcu_ecc_fatal),
    .dcu_ecc_valid_i             (dcu_ecc_valid),
    .dcu_ecc_ramid_i             (dcu_ecc_ramid[1:0]),
    .dcu_ecc_way_bank_id_i       (dcu_ecc_way_bank_id[2:0]),
    .dcu_ecc_index_i             (dcu_ecc_index[10:0]),
    .tlb_d_utlb_enable_i         (tlb_d_utlb_enable),
    .dpu_valid_iss_i             (dpu_valid_iss),
    .dpu_valid_cp_iss_i          (dpu_valid_cp_iss),
    .dpu_store_iss_i             (dpu_store_iss),
    .dpu_strobe_iss_i            (dpu_strobe_iss[15:0]),
    .dpu_excl_iss_i              (dpu_excl_iss),
    .dpu_periphbase_i            (dpu_periphbase[21:0]),
    .dpu_pld_iss_i               (dpu_pld_iss),
    .dpu_pld_level_iss_i         (dpu_pld_level_iss),
    .dpu_priv_iss_i              (dpu_priv_iss),
    .dpu_first_iss_i             (dpu_first_iss),
    .dpu_force_first_iss_i       (dpu_force_first_iss),
    .dpu_second_x64_iss_i        (dpu_second_x64_iss),
    .dpu_neon_access_iss_i       (dpu_neon_access_iss),
    .dpu_length_iss_i            (dpu_length_iss[4:0]),
    .dpu_size_iss_i              (dpu_size_iss[1:0]),
    .dpu_req_align_iss_i         (dpu_req_align_iss),
    .dpu_align_size_iss_i        (dpu_align_size_iss[2:0]),
    .dpu_burst_iss_i             (dpu_burst_iss),
    .dpu_cross_64_iss_i          (dpu_cross_64_iss),
    .dpu_cp_op_iss_i             (dpu_cp_op_iss[8:0]),
    .dpu_non_temporal_iss_i      (dpu_non_temporal_iss),
    .dpu_ldar_stlr_iss_i         (dpu_ldar_stlr_iss),
    .dpu_agu_a_operand_iss_i     (dpu_agu_a_operand_iss[48:6]),
    .dpu_agu_b_operand_iss_i     (dpu_agu_b_operand_iss[48:6]),
    .dpu_agu_carry_out_64b_iss_i (dpu_agu_carry_out_64b_iss),
    .dpu_va_dc1_i                (dpu_va_dc1[63:0]),
    .dpu_utlb_hit_dc1_i          (dpu_utlb_hit_dc1),
    .dpu_utlb_hit_entry_dc1_i    (dpu_utlb_hit_entry_dc1[3:0]),
    .dpu_pa_dc1_i                (dpu_pa_dc1[39:12]),
    .dpu_attributes_dc1_i        (dpu_attributes_dc1[12:0]),
    .dpu_ns_dsc_dc1_i            (dpu_ns_dsc_dc1),
    .dpu_lpae_dc1_i              (dpu_lpae_dc1),
    .dpu_level_dc1_i             (dpu_level_dc1[3:0]),
    .dpu_domain_dc1_i            (dpu_domain_dc1[3:0]),
    .dpu_fault_dc1_i             (dpu_fault_dc1[8:0]),
    .dpu_abort_dc1_i             (dpu_abort_dc1),
    .dpu_stack_align_expt_dc1_i  (dpu_stack_align_expt_dc1),
    .dpu_ready_wr_i              (dpu_ready_wr),
    .dpu_cp_data_wr_i            (dpu_cp_data_wr[63:0]),
    .dpu_st_data_wr_i            (dpu_st_data_wr[127:0]),
    .dpu_kill_wr_i               (dpu_kill_wr),
    .dpu_cc_fail_wr_i            (dpu_cc_fail_wr),
    .dpu_ready_cc_fail_wr_i      (dpu_ready_cc_fail_wr),
    .dpu_ready_cc_pass_wr_i      (dpu_ready_cc_pass_wr),
    .dpu_flush_i                 (dpu_flush),
    .dpu_ns_state_i              (dpu_ns_state),
    .dpu_scr_el3_ns_i            (dpu_scr_el3_ns),
    .dpu_exception_level_i       (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el_i         (dpu_aarch64_at_el[3:1]),
    .dpu_aarch64_state_i         (dpu_aarch64_state),
    .dpu_clear_excl_mon_i        (dpu_clear_excl_mon),
    .dpu_dbg_dsb_req_i           (dpu_dbg_dsb_req),
    .dpu_mmu_on_el1_i            (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_i            (dpu_mmu_on_el2),
    .dpu_mmu_on_el3_i            (dpu_mmu_on_el3),
    .dpu_dcache_on_el1_i         (dpu_dcache_on_el1),
    .dpu_dcache_on_el2_i         (dpu_dcache_on_el2),
    .dpu_dcache_on_el3_i         (dpu_dcache_on_el3),
    .dpu_s2_dcache_on_i          (dpu_s2_dcache_on),
    .dpu_l1deien_i               (dpu_l1deien),
    .dpu_disable_dmb_i           (dpu_disable_dmb),
    .dpu_disable_no_allocate_i   (dpu_disable_no_allocate),
    .dpu_icache_on_i             (dpu_icache_on),
    .dpu_ipa_to_pa_en_i          (dpu_ipa_to_pa_en),
    .dpu_default_cacheable_i     (dpu_default_cacheable)
  );  // u_ca53_dpu_dcu

  ca53_dpu_rams u_ca53_dpu_rams (
    /*ARMAUTO*/
    // Inputs
    .clk       (clk),
    .reset_n   (reset_n),
    .dc_size_i (dc_size_i[2:0]),
    .ic_size_i (ic_size_i[2:0])
  );  // u_ca53_dpu_rams

  ca53_biu_rams u_ca53_biu_rams (
    /*ARMAUTO*/
    // Inputs
    .clk       (clk),
    .reset_n   (reset_n),
    .dc_size_i (dc_size_i[2:0])
  );  // u_ca53_biu_rams

  ca53_biu_scu u_ca53_biu_scu (
    /*ARMAUTO*/
    // Inputs
    .clk                   (clk),
    .reset_n               (reset_n),
    .scu_ar_credit_i       (scu_ar_credit_i),
    .scu_ar_block_i        (scu_ar_block_i),
    .scu_dr_valid_i        (scu_dr_valid_i),
    .scu_dr_id_i           (scu_dr_id_i[4:0]),
    .scu_dr_resp_i         (scu_dr_resp_i[5:0]),
    .scu_dr_chunk_i        (scu_dr_chunk_i[1:0]),
    .scu_dr_data_i         (scu_dr_data_i[127:0]),
    .scu_rr_valid_i        (scu_rr_valid_i),
    .scu_rr_id_i           (scu_rr_id_i[4:0]),
    .scu_rr_resp_i         (scu_rr_resp_i[1:0]),
    .scu_rr_l2db_id_i      (scu_rr_l2db_id_i[3:0]),
    .scu_ev_done_i         (scu_ev_done_i[7:0]),
    .scu_db_excl_valid_i   (scu_db_excl_valid_i),
    .scu_db_excl_resp_i    (scu_db_excl_resp_i[1:0]),
    .scu_db_decerr_i       (scu_db_decerr_i),
    .scu_db_slverr_i       (scu_db_slverr_i),
    .scu_leave_ramode_i    (scu_leave_ramode_i),
    .scu_ac_valid_i        (scu_ac_valid_i),
    .dcu_ac_ready_i        (dcu_ac_ready_o),
    .scu_ac_snoop_i        (scu_ac_snoop_i[2:0]),
    .scu_ac_id_i           (scu_ac_id_i[2:0]),
    .scu_ac_l2db_id_i      (scu_ac_l2db_id_i[3:0]),
    .dcu_cr_valid_i        (dcu_cr_valid_o),
    .dcu_cr_id_i           (dcu_cr_id_o[2:0]),
    .biu_ar_active_i       (biu_ar_active_o),
    .biu_ar_valid_i        (biu_ar_valid),
    .biu_ar_id_i           (biu_ar_id[4:0]),
    .biu_ar_type_i         (biu_ar_type[4:0]),
    .biu_ar_attrs_i        (biu_ar_attrs[7:0]),
    .biu_ar_way_i          (biu_ar_way[4:0]),
    .biu_ar_addr_i         (biu_ar_addr[40:0]),
    .biu_ar_len_i          (biu_ar_len[1:0]),
    .biu_ar_size_i         (biu_ar_size[2:0]),
    .biu_ar_lock_i         (biu_ar_lock),
    .biu_ar_priv_i         (biu_ar_priv_o),
    .biu_dr_credit_i       (biu_dr_credit),
    .biu_dw_valid_i        (biu_dw_valid),
    .biu_dw_l2db_id_i      (biu_dw_l2db_id_o[3:0]),
    .biu_dw_chunks_valid_i (biu_dw_chunks_valid_o[3:0]),
    .biu_dw_last_i         (biu_dw_last),
    .biu_dw_data_i         (biu_dw_data[255:0]),
    .biu_dw_strb_i         (biu_dw_strb[31:0]),
    .biu_dw_err_i          (biu_dw_err_o),
    .biu_dw_fatal_i        (biu_dw_fatal_o)
  );  // u_ca53_biu_scu

  ca53_scu_dcu u_ca53_scu_dcu (
    /*ARMAUTO*/
    // Inputs
    .clk                  (clk),
    .reset_n              (reset_n),
    .dcu_ac_ready_i       (dcu_ac_ready_o),
    .dcu_cr_valid_i       (dcu_cr_valid_o),
    .dcu_cr_id_i          (dcu_cr_id_o[2:0]),
    .dcu_cr_dirty_i       (dcu_cr_dirty_o),
    .dcu_cr_age_i         (dcu_cr_age_o),
    .dcu_cr_alloc_i       (dcu_cr_alloc_o),
    .dcu_cr_migratory_i   (dcu_cr_migratory_o),
    .dcu_dvm_complete_i   (dcu_dvm_complete_o),
    .scu_ac_valid_i       (scu_ac_valid_i),
    .scu_ac_id_i          (scu_ac_id_i[2:0]),
    .scu_ac_l2db_id_i     (scu_ac_l2db_id_i[3:0]),
    .scu_ac_snoop_i       (scu_ac_snoop_i[3:0]),
    .scu_ac_addr_i        (scu_ac_addr_i[40:0]),
    .scu_ac_way_i         (scu_ac_way_i[3:0]),
    .scu_reqbufs_busy_i   (scu_reqbufs_busy_i[7:0]),
    .scu_broadcastinner_i (scu_broadcastinner_i)
  );  // u_ca53_scu_dcu

  ca53_stb_scu u_ca53_stb_scu (
    /*ARMAUTO*/
    // Inputs
    .clk                (clk),
    .reset_n            (reset_n),
    .scu_dvm_complete_i (scu_dvm_complete_i),
    .scu_drain_stb_i    (scu_drain_stb_i)
  );  // u_ca53_stb_scu

  ca53_stb_rams u_ca53_stb_rams (
    /*ARMAUTO*/
    // Inputs
    .clk       (clk),
    .reset_n   (reset_n),
    .dc_size_i (dc_size_i[2:0])
  );  // u_ca53_stb_rams

  ca53_ifu_rams #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_ifu_rams (
    /*ARMAUTO*/
    // Inputs
    .clk                   (clk),
    .reset_n               (reset_n),
    .ic_tagram_rdata0_i    (ic_tagram_rdata0_i[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_rdata1_i    (ic_tagram_rdata1_i[(`CA53_ITAG_RAM_W-1):0]),
    .ic_dataram_rdata0_i   (ic_dataram_rdata0_i[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_rdata1_i   (ic_dataram_rdata1_i[(`CA53_IDATA_RAM_W-1):0]),
    .ic_size_i             (ic_size_i[2:0]),
    .btac_stg0_ram_rdata_i (btac_stg0_ram_rdata_i[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg1_ram_rdata_i (btac_stg1_ram_rdata_i[(`CA53_BTAC_RAM_S1D_W-1):0]),
    .ic_tagram_en_i        (ic_tagram_en[1:0]),
    .ic_tagram_wr_i        (ic_tagram_wr),
    .ic_tagram_wdata_i     (ic_tagram_wdata[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_addr_i      (ic_tagram_addr[8:0]),
    .ic_dataram_en_i       (ic_dataram_en[3:0]),
    .ic_dataram_wr_i       (ic_dataram_wr),
    .ic_dataram_addr0_i    (ic_dataram_addr0[11:0]),
    .ic_dataram_addr1_i    (ic_dataram_addr1[11:0]),
    .ic_dataram_strb0_i    (ic_dataram_strb0[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_strb1_i    (ic_dataram_strb1[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_wdata0_i   (ic_dataram_wdata0[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_wdata1_i   (ic_dataram_wdata1[(`CA53_IDATA_RAM_W-1):0]),
    .btac_stg0_ram_en_i    (btac_stg0_ram_en_o),
    .btac_stg0_ram_wr_i    (btac_stg0_ram_wr_o),
    .btac_stg0_ram_wdata_i (btac_stg0_ram_wdata_o[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg0_ram_addr_i  (btac_stg0_ram_addr_o[(`CA53_BTAC_RAM_ADDR_W-1):0]),
    .btac_stg1_ram_en_i    (btac_stg1_ram_en_o),
    .btac_stg1_ram_wr_i    (btac_stg1_ram_wr_o),
    .btac_stg1_ram_wdata_i (btac_stg1_ram_wdata_o[(`CA53_BTAC_RAM_S1D_W-1):0]),
    .btac_stg1_ram_addr_i  (btac_stg1_ram_addr_o[(`CA53_BTAC_RAM_ADDR_W-1):0])
  );  // u_ca53_ifu_rams

  ca53_ifu_biu #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_ifu_biu (
    /*ARMAUTO*/
    // Inputs
    .clk                      (clk),
    .reset_n                  (reset_n),
    .biu_i_arready_i          (biu_i_arready),
    .biu_i_rvalid_i           (biu_i_rvalid),
    .biu_i_rid_i              (biu_i_rid[1:0]),
    .biu_i_rdata_i            (biu_i_rdata[127:0]),
    .biu_i_rresp_i            (biu_i_rresp[2:0]),
    .biu_i_rchunk_i           (biu_i_rchunk[1:0]),
    .gov_mbist_req_i          (gov_mbist_req_i),
    .ifu_arvalid_i            (ifu_arvalid),
    .ifu_arid_i               (ifu_arid[1:0]),
    .ifu_araddr_i             (ifu_araddr[39:0]),
    .ifu_arlen_i              (ifu_arlen[1:0]),
    .ifu_attrs_i              (ifu_attrs[7:0]),
    .ifu_arprot_i             (ifu_arprot[1:0]),
    .ifu_rready_i             (ifu_rready),
    .ifu_outstanding_lfb_i    (ifu_outstanding_lfb[2:0]),
    .ifu_mbist_out_data_mb6_i (ifu_mbist_out_data_mb6[(`CA53_IDATA_RAM_W-1):0])
  );  // u_ca53_ifu_biu

  ca53_dcu_ifu u_ca53_dcu_ifu (
    /*ARMAUTO*/
    // Inputs
    .clk                   (clk),
    .reset_n               (reset_n),
    .ifu_outstanding_lfb_i (ifu_outstanding_lfb[2:0]),
    .ifu_cp_ack_i          (ifu_cp_ack),
    .ifu_valid_if2_i       (ifu_valid_if2),
    .dpu_kill_wr_i         (dpu_kill_wr),
    .gov_mbist_req_i       (gov_mbist_req_i),
    .dcu_cp_valid_ifu_i    (dcu_cp_valid_ifu),
    .dcu_dvm_valid_ifu_i   (dcu_dvm_valid_ifu),
    .dcu_cp_op_ifu_i       (dcu_cp_op_ifu[2:0]),
    .dcu_cp_addr_ifu_i     (dcu_cp_addr_ifu[39:0]),
    .dcu_cp_ns_i           (dcu_cp_ns)
  );  // u_ca53_dcu_ifu

  ca53_dpu_ifu u_ca53_dpu_ifu (
    /*ARMAUTO*/
    // Inputs
    .clk                        (clk),
    .reset_n                    (reset_n),
    .ifu_instr0_if3_i           (ifu_instr0_if3[47:0]),
    .ifu_instr1_if3_i           (ifu_instr1_if3[47:0]),
    .ifu_instr_valid_if3_i      (ifu_instr_valid_if3[1:0]),
    .ifu_early_two_valid_if3_i  (ifu_early_two_valid_if3),
    .ifu_pred_addr_if4_i        (ifu_pred_addr_if4[48:0]),
    .ifu_pred_addr_valid_if4_i  (ifu_pred_addr_valid_if4),
    .ifu_ifar_i                 (ifu_ifar[31:1]),
    .ifu_ifsr_i                 (ifu_ifsr[6:0]),
    .ifu_ifsr_stage2_i          (ifu_ifsr_stage2[1:0]),
    .ifu_ifsr_lpae_i            (ifu_ifsr_lpae),
    .ifu_hpfar_i                (ifu_hpfar[27:0]),
    .ifu_evnt_ic_lf_i           (ifu_evnt_ic_lf),
    .ifu_evnt_ic_access_i       (ifu_evnt_ic_access),
    .ifu_evnt_ic_miss_wait_i    (ifu_evnt_ic_miss_wait),
    .ifu_evnt_iutlb_miss_wait_i (ifu_evnt_iutlb_miss_wait),
    .ifu_evnt_pdc_valid_i       (ifu_evnt_pdc_valid),
    .ifu_evnt_throttle_i        (ifu_evnt_throttle),
    .ifu_dbg_ready_i            (ifu_dbg_ready),
    .ifu_pty_valid_i            (ifu_pty_valid),
    .ifu_pty_ramid_i            (ifu_pty_ramid),
    .ifu_pty_way_bank_id_i      (ifu_pty_way_bank_id),
    .ifu_pty_index_i            (ifu_pty_index[11:0]),
    .tlb_lpae_mode_i            (tlb_lpae_mode),
    .dpu_iq_full_i              (dpu_iq_full),
    .dpu_iq_part_full_i         (dpu_iq_part_full),
    .dpu_fe_valid_wr_i          (dpu_fe_valid_wr),
    .dpu_fe_addr_opa_wr_i       (dpu_fe_addr_opa_wr[48:1]),
    .dpu_fe_addr_opb_wr_i       (dpu_fe_addr_opb_wr[27:1]),
    .dpu_fe_isa_wr_i            (dpu_fe_isa_wr[1:0]),
    .dpu_pred_br_ex2_i          (dpu_pred_br_ex2),
    .dpu_br_addr_ex2_i          (dpu_br_addr_ex2[12:3]),
    .dpu_pred_br_wr_i           (dpu_pred_br_wr),
    .dpu_mispred_wr_i           (dpu_mispred_wr),
    .dpu_br_taken_wr_i          (dpu_br_taken_wr),
    .dpu_br_return_wr_i         (dpu_br_return_wr),
    .dpu_br_call_wr_i           (dpu_br_call_wr),
    .dpu_fe_valid_ret_i         (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_ret_i      (dpu_fe_addr_opa_ret[63:0]),
    .dpu_fe_addr_opb_ret_i      (dpu_fe_addr_opb_ret[17:1]),
    .dpu_fe_isa_ret_i           (dpu_fe_isa_ret[1:0]),
    .dpu_fe_itstate_ret_i       (dpu_fe_itstate_ret[7:0]),
    .dpu_fe_context_sync_ret_i  (dpu_fe_context_sync_ret),
    .dpu_btac_ret_i             (dpu_btac_ret),
    .dpu_halt_ifu_i             (dpu_halt_ifu),
    .dpu_mmu_on_i               (dpu_mmu_on),
    .dpu_ipa_to_pa_en_i         (dpu_ipa_to_pa_en),
    .dpu_exception_level_i      (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el[3:1]),
    .dpu_flush_i_utlb_i         (dpu_flush_i_utlb),
    .dpu_sif_only_i             (dpu_sif_only),
    .dpu_dacr_i                 (dpu_dacr[31:0]),
    .dpu_sctlr_itd_i            (dpu_sctlr_itd),
    .dpu_throttle_enable_i      (dpu_throttle_enable),
    .dpu_ns_state_i             (dpu_ns_state),
    .dpu_default_cacheable_i    (dpu_default_cacheable),
    .dpu_icache_on_i            (dpu_icache_on),
    .dpu_dbg_valid_i            (dpu_dbg_valid),
    .dpu_kill_wr_i              (dpu_kill_wr),
    .dpu_dbg_ins_i              (dpu_dbg_ins[31:0]),
    .dpu_reset_catch_pending_i  (dpu_reset_catch_pending),
    .dpu_expt_catch_pending_i   (dpu_expt_catch_pending)
  );  // u_ca53_dpu_ifu

  ca53_ifu_tlb u_ca53_ifu_tlb (
    /*ARMAUTO*/
    // Inputs
    .clk                       (clk),
    .reset_n                   (reset_n),
    .tlb_i_utlb_enable_i       (tlb_i_utlb_enable),
    .tlb_i_utlb_might_enable_i (tlb_i_utlb_might_enable),
    .tlb_i_utlb_valid_i        (tlb_i_utlb_valid),
    .tlb_i_utlb_lpae_i         (tlb_i_utlb_lpae),
    .tlb_i_utlb_data_i         (tlb_i_utlb_data[96:0]),
    .tlb_i_utlb_flush_i        (tlb_i_utlb_flush),
    .tlb_lpae_mode_i           (tlb_lpae_mode),
    .tlb_bkpt_hit_if2_i        (tlb_bkpt_hit_if2[3:0]),
    .tlb_vcr_hit_if2_i         (tlb_vcr_hit_if2[1:0]),
    .tlb_d_tcr_el1_tbi_i       (tlb_d_tcr_el1_tbi[1:0]),
    .tlb_d_tcr_el2_tbi0_i      (tlb_d_tcr_el2_tbi0),
    .tlb_d_tcr_el3_tbi0_i      (tlb_d_tcr_el3_tbi0),
    .ifu_utlb_miss_req_i       (ifu_utlb_miss_req),
    .ifu_va_if2_i              (ifu_va_if2[63:0]),
    .ifu_cp_dbg_valid_i        (ifu_cp_dbg_valid),
    .ifu_cp_dbg_0_i            (ifu_cp_dbg_0[31:0]),
    .ifu_cp_dbg_1_i            (ifu_cp_dbg_1[31:0])
  );  // u_ca53_ifu_tlb

  ca53_gov_dcu u_ca53_gov_dcu (
    /*ARMAUTO*/
    // Inputs
    .clk                    (clk),
    .reset_n                (reset_n),
    .dcu_excl_mon_cleared_i (dcu_excl_mon_cleared_o),
    .dcu_cp_gov_addr_i      (dcu_cp_gov_addr_o[17:0]),
    .dcu_cp_gov_ns_i        (dcu_cp_gov_ns_o),
    .dcu_cp_gov_req_i       (dcu_cp_gov_req_o),
    .dcu_cp_gov_sel_i       (dcu_cp_gov_sel_o[2:0]),
    .dcu_cp_gov_wdata_i     (dcu_cp_gov_wdata_o[63:0]),
    .dcu_cp_gov_wenable_i   (dcu_cp_gov_wenable_o),
    .dcu_wfx_ready_i        (dcu_wfx_ready_o),
    .gov_giccdisable_i      (gov_giccdisable_i),
    .gov_stall_dsb_i        (gov_stall_dsb_i),
    .gov_cp_ack_i           (gov_cp_ack_i),
    .gov_cp_rdata_i         (gov_cp_rdata_i[63:0]),
    .gov_wfx_drain_req_i    (gov_wfx_drain_req_i),
    .gov_standbywfe_i       (gov_standbywfe_i),
    .gov_standbywfi_i       (gov_standbywfi_i),
    .gov_mbist_req_i        (gov_mbist_req_i),
    .gov_dbgl1rstdisable_i  (gov_dbgl1rstdisable_i)
  );  // u_ca53_gov_dcu

  ca53_gov_stb u_ca53_gov_stb (
    /*ARMAUTO*/
    // Inputs
    .clk                 (clk),
    .reset_n             (reset_n),
    .stb_wfx_ready_i     (stb_wfx_ready_o),
    .gov_wfx_drain_req_i (gov_wfx_drain_req_i)
  );  // u_ca53_gov_stb

  ca53_gov_biu u_ca53_gov_biu (
    /*ARMAUTO*/
    // Inputs
    .clk                 (clk),
    .reset_n             (reset_n),
    .biu_wfx_ready_i     (biu_wfx_ready_o),
    .gov_wfx_drain_req_i (gov_wfx_drain_req_i),
    .gov_mbist_req_i     (gov_mbist_req_i)
  );  // u_ca53_gov_biu

  ca53_gov_ifu u_ca53_gov_ifu (
    /*ARMAUTO*/
    // Inputs
    .clk             (clk),
    .reset_n         (reset_n),
    .ifu_wfx_ready_i (ifu_wfx_ready_o),
    .gov_mbist_req_i (gov_mbist_req_i)
  );  // u_ca53_gov_ifu

  ca53_gov_tlb u_ca53_gov_tlb (
    /*ARMAUTO*/
    // Inputs
    .clk             (clk),
    .reset_n         (reset_n),
    .gov_mbist_req_i (gov_mbist_req_i),
    .tlb_wfx_ready_i (tlb_wfx_ready_o)
  );  // u_ca53_gov_tlb

  ca53_dpu_gic u_ca53_dpu_gic (
    /*ARMAUTO*/
    // Inputs
    .clk                      (clk),
    .reset_n                  (reset_n),
    .gic_fiq_i                (gic_fiq_i),
    .gic_icc_sre_el1_ns_sre_i (gic_icc_sre_el1_ns_sre_i),
    .gic_icc_sre_el1_s_sre_i  (gic_icc_sre_el1_s_sre_i),
    .gic_icc_sre_el2_enable_i (gic_icc_sre_el2_enable_i),
    .gic_icc_sre_el2_sre_i    (gic_icc_sre_el2_sre_i),
    .gic_icc_sre_el3_enable_i (gic_icc_sre_el3_enable_i),
    .gic_icc_sre_el3_sre_i    (gic_icc_sre_el3_sre_i),
    .gic_ich_hcr_el2_tall0_i  (gic_ich_hcr_el2_tall0_i),
    .gic_ich_hcr_el2_tall1_i  (gic_ich_hcr_el2_tall1_i),
    .gic_ich_hcr_el2_tc_i     (gic_ich_hcr_el2_tc_i),
    .gic_irq_i                (gic_irq_i),
    .gic_vfiq_i               (gic_vfiq_i),
    .gic_virq_i               (gic_virq_i),
    .gov_giccdisable_i        (gov_giccdisable_i)
  );  // u_ca53_dpu_gic

  ca53_dpu_gov u_ca53_dpu_gov (
    /*ARMAUTO*/
    // Inputs
    .clk                           (clk),
    .po_reset_n                    (po_reset_n),
    .cpu_id_i                      (cpu_id_i[1:0]),
    .ctr_cwg_i                     (ctr_cwg_i[3:0]),
    .ctr_erg_i                     (ctr_erg_i[3:0]),
    .gov_clusteridaff1_i           (gov_clusteridaff1_i[7:0]),
    .gov_clusteridaff2_i           (gov_clusteridaff2_i[7:0]),
    .gov_cp15sdisable_i            (gov_cp15sdisable_i),
    .gov_cryptodisable_i           (gov_cryptodisable_i),
    .gov_giccdisable_i             (gov_giccdisable_i),
    .gov_aa64naa32_i               (gov_aa64naa32_i),
    .gov_cfgend_i                  (gov_cfgend_i),
    .gov_cfgte_i                   (gov_cfgte_i),
    .gov_vinithi_i                 (gov_vinithi_i),
    .gov_rvbaraddr_i               (gov_rvbaraddr_i[39:2]),
    .gov_dbgromaddrv_i             (gov_dbgromaddrv_i),
    .gov_dbgromaddr_i              (gov_dbgromaddr_i[39:12]),
    .gov_periphbase_i              (gov_periphbase_i[39:18]),
    .gov_pseldbg_dbg_i             (gov_pseldbg_dbg_i),
    .gov_pseldbg_pmu_i             (gov_pseldbg_pmu_i),
    .gov_paddrdbg_i                (gov_paddrdbg_i[11:2]),
    .gov_paddrdbg31_i              (gov_paddrdbg31_i),
    .gov_pwritedbg_i               (gov_pwritedbg_i),
    .gov_pwdatadbg_i               (gov_pwdatadbg_i[31:0]),
    .gov_dbgen_i                   (gov_dbgen_i),
    .gov_niden_i                   (gov_niden_i),
    .gov_spiden_i                  (gov_spiden_i),
    .gov_spniden_i                 (gov_spniden_i),
    .gov_edecr_osuce_i             (gov_edecr_osuce_i),
    .gov_edecr_rce_i               (gov_edecr_rce_i),
    .gov_edecr_ss_i                (gov_edecr_ss_i),
    .gov_edbgrq_i                  (gov_edbgrq_i),
    .gov_edlsr_slk_i               (gov_edlsr_slk_i),
    .gov_pmlsr_slk_i               (gov_pmlsr_slk_i),
    .gov_dbgrestart_i              (gov_dbgrestart_i),
    .gov_dbgpwrupreq_i             (gov_dbgpwrupreq_i),
    .gov_event_reg_i               (gov_event_reg_i),
    .gov_wfx_wake_i                (gov_wfx_wake_i),
    .gov_stall_neon_i              (gov_stall_neon_i),
    .gov_pcnt_kernel_access_i      (gov_pcnt_kernel_access_i),
    .gov_pcnt_usr_access_i         (gov_pcnt_usr_access_i),
    .gov_vcnt_usr_access_i         (gov_vcnt_usr_access_i),
    .gov_cntp_usr_access_i         (gov_cntp_usr_access_i),
    .gov_cntv_usr_access_i         (gov_cntv_usr_access_i),
    .gov_cntp_kernel_access_i      (gov_cntp_kernel_access_i),
    .gov_sei_level_req_i           (gov_sei_level_req_i),
    .gov_vsei_level_req_i          (gov_vsei_level_req_i),
    .gov_rei_level_req_i           (gov_rei_level_req_i),
    .gov_int_active_i              (gov_int_active_i),
    .gov_wfx_drain_req_i           (gov_wfx_drain_req_i),
    .reset_n_i                     (reset_n),
    .gic_fiq_i                     (gic_fiq_i),
    .gic_irq_i                     (gic_irq_i),
    .gic_vfiq_i                    (gic_vfiq_i),
    .gic_virq_i                    (gic_virq_i),
    .dpu_preadydbg_i               (dpu_preadydbg_o),
    .dpu_prdatadbg_i               (dpu_prdatadbg_o[31:0]),
    .dpu_pslverrdbg_i              (dpu_pslverrdbg_o),
    .dpu_ncommirq_i                (dpu_ncommirq_o),
    .dpu_commrx_i                  (dpu_commrx_o),
    .dpu_commtx_i                  (dpu_commtx_o),
    .dpu_dbgack_i                  (dpu_dbgack_o),
    .dpu_dbgtrigger_i              (dpu_dbgtrigger_o),
    .dpu_dbgnopwrdwn_i             (dpu_dbgnopwrdwn_o),
    .dpu_dbgrstreq_i               (dpu_dbgrstreq_o),
    .dpu_dscr_halted_i             (dpu_dscr_halted_o),
    .dpu_wfi_req_i                 (dpu_wfi_req_o),
    .dpu_wfe_req_i                 (dpu_wfe_req_o),
    .dpu_sev_req_i                 (dpu_sev_req_o),
    .dpu_clr_event_register_i      (dpu_clr_event_register_o),
    .dpu_irq_pended_i              (dpu_irq_pended_o),
    .dpu_fiq_pended_i              (dpu_fiq_pended_o),
    .dpu_sei_pended_i              (dpu_sei_pended_o),
    .dpu_irq_masked_i              (dpu_irq_masked_o),
    .dpu_fiq_masked_i              (dpu_fiq_masked_o),
    .dpu_sei_masked_i              (dpu_sei_masked_o),
    .dpu_virq_pended_i             (dpu_virq_pended_o),
    .dpu_vfiq_pended_i             (dpu_vfiq_pended_o),
    .dpu_vsei_pended_i             (dpu_vsei_pended_o),
    .dpu_virq_masked_i             (dpu_virq_masked_o),
    .dpu_vfiq_masked_i             (dpu_vfiq_masked_o),
    .dpu_vsei_masked_i             (dpu_vsei_masked_o),
    .dpu_imp_abort_pending_i       (dpu_imp_abort_pending_o),
    .dpu_dbg_double_lock_set_i     (dpu_dbg_double_lock_set_o),
    .dpu_neon_active_i             (dpu_neon_active_o),
    .dpu_cpuectlr_cpu_ret_delay_i  (dpu_cpuectlr_cpu_ret_delay_o[2:0]),
    .dpu_cpuectlr_neon_ret_delay_i (dpu_cpuectlr_neon_ret_delay_o[2:0]),
    .dpu_scr_el3_ns_i              (dpu_scr_el3_ns),
    .dpu_sei_level_ack_i           (dpu_sei_level_ack_o),
    .dpu_vsei_level_ack_i          (dpu_vsei_level_ack_o),
    .dpu_rei_level_ack_i           (dpu_rei_level_ack_o),
    .dpu_hcr_el2_fmo_i             (dpu_hcr_el2_fmo_o),
    .dpu_hcr_el2_imo_i             (dpu_hcr_el2_imo_o),
    .dpu_hcr_el2_amo_i             (dpu_hcr_el2_amo_o),
    .dpu_scr_el3_fiq_i             (dpu_scr_el3_fiq_o),
    .dpu_scr_el3_irq_i             (dpu_scr_el3_irq_o),
    .dpu_monitor_mode_i            (dpu_monitor_mode_o),
    .dpu_smp_en_i                  (dpu_smp_en_o),
    .dpu_npmuirq_i                 (dpu_npmuirq_o),
    .dpu_warmrstreq_i              (dpu_warmrstreq_o)
  );  // u_ca53_dpu_gov

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"NS-req=NS => NS-attr=NS")
    ovl_tz_utlb_ns_state (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (dpu_mmu_on & tlb_d_utlb_valid & tlb_d_utlb_enable & dpu_ns_state & ~dpu_flush_i_utlb),
                          .consequent_expr (tlb_d_utlb_data[65]));

  // There should be no AXI requests while the core is asleep, apart from in
  // response to a snoop request (when the clocks are turned back on briefly to
  // allow the request to be processed).
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"There must be no AXI requests while the core is asleep")
    ovl_wfi_ar_valid_check (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (gov_standbywfi_i & dcu_wfx_ready_o),
                            .consequent_expr (~biu_ar_valid));

  // Since the core can only be processing snoop requests during WFx, only the
  // DCU, BIU (to return the data), IFU/TLB (to deal with DVM requests) and ETM
  // (to deal with APB debug requests) can be active during WFx.  Note that
  // there is not a DPU WFx ready signal, but that could also be active in WFx
  // to deal with APB Debug requests.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Only DCU, BIU, IFU, TLB and/or ETM can be active during WFI")
    ovl_wfi_inactive_check (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (gov_standbywfi_i),
                            .consequent_expr (stb_wfx_ready_o));

`endif

`ifdef CORTEXA53_UNIVENT
  ca53_follower `CA53_NORAM_PARAM_INST u_follower ();
`endif

endmodule // ca53_noram

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
