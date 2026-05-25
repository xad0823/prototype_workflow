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
//      Checked In          : $Date: 2009-03-16 23:51:56 +0000 (Mon, 16 Mar 2009) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Top level of the CortexA53 CPU (with RAMs)
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53_cpu `CA53_CPU_PARAM_DECL (
  // Clock Signal
  input  wire                                  clk,
  // Reset Signals
  input  wire                                  reset_n_cpu,
  input  wire                                  po_reset_n_cpu,
  // Test Signals
  input  wire                                  DFTSE,
  input  wire                                  DFTRAMHOLD,
  input  wire                                  DFTRSTDISABLE,
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
  input  wire                                  scu_broadcastinner_i,
  // Core Trace Interface
  output wire [25:0]                           dpu_pmuevent_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire   [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr;
  wire                                 btac_stg0_ram_en;
  wire    [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_rdata;
  wire    [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_wdata;
  wire                                 btac_stg0_ram_wr;
  wire   [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr;
  wire                                 btac_stg1_ram_en;
  wire    [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_rdata;
  wire    [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_wdata;
  wire                                 btac_stg1_ram_wr;
  wire                          [10:0] dc_dataram_addr0;
  wire                          [10:0] dc_dataram_addr1;
  wire                          [10:0] dc_dataram_addr2;
  wire                          [10:0] dc_dataram_addr3;
  wire                          [10:0] dc_dataram_addr4;
  wire                          [10:0] dc_dataram_addr5;
  wire                          [10:0] dc_dataram_addr6;
  wire                          [10:0] dc_dataram_addr7;
  wire                           [7:0] dc_dataram_en;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata0;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata1;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata2;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata3;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata4;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata5;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata6;
  wire         [`CA53_DDATA_RAM_W-1:0] dc_dataram_rdata7;
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
  wire        [`CA53_DDIRTY_RAM_W-1:0] dc_dirtyram_rdata;
  wire      [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_strb;
  wire      [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_wdata;
  wire                                 dc_dirtyram_wr;
  wire                           [2:0] dc_size;
  wire                           [7:0] dc_tagram_addr;
  wire                           [3:0] dc_tagram_en;
  wire          [`CA53_DTAG_RAM_W-1:0] dc_tagram_rdata0;
  wire          [`CA53_DTAG_RAM_W-1:0] dc_tagram_rdata1;
  wire          [`CA53_DTAG_RAM_W-1:0] dc_tagram_rdata2;
  wire          [`CA53_DTAG_RAM_W-1:0] dc_tagram_rdata3;
  wire        [(`CA53_DTAG_RAM_W-1):0] dc_tagram_wdata;
  wire                                 dc_tagram_wr;
  wire                          [11:0] ic_dataram_addr0;
  wire                          [11:0] ic_dataram_addr1;
  wire                           [3:0] ic_dataram_en;
  wire         [`CA53_IDATA_RAM_W-1:0] ic_dataram_rdata0;
  wire         [`CA53_IDATA_RAM_W-1:0] ic_dataram_rdata1;
  wire       [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0;
  wire       [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1;
  wire       [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0;
  wire       [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1;
  wire                                 ic_dataram_wr;
  wire                           [2:0] ic_size;
  wire                           [8:0] ic_tagram_addr;
  wire                           [1:0] ic_tagram_en;
  wire          [`CA53_ITAG_RAM_W-1:0] ic_tagram_rdata0;
  wire          [`CA53_ITAG_RAM_W-1:0] ic_tagram_rdata1;
  wire        [(`CA53_ITAG_RAM_W-1):0] ic_tagram_wdata;
  wire                                 ic_tagram_wr;
  wire    [(`CA53_TLB_RAM_ADDR_W-1):0] tlb_ram_addr;
  wire                           [3:0] tlb_ram_en;
  wire           [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata0;
  wire           [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata1;
  wire           [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata2;
  wire           [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata3;
  wire         [(`CA53_TLB_RAM_W-1):0] tlb_ram_wdata;
  wire                                 tlb_ram_wr;
  /*END*/

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // NoRAM instantiation
  // ------------------------------------------------------

  ca53_noram `CA53_NORAM_PARAM_INST u_ca53_noram (
    /*ARMAUTO*/
    // Inputs
    .clk                           (clk),
    .reset_n_cpu                   (reset_n_cpu),
    .po_reset_n_cpu                (po_reset_n_cpu),
    .DFTSE                         (DFTSE),
    .DFTRSTDISABLE                 (DFTRSTDISABLE),
    .DFTRAMHOLD                    (DFTRAMHOLD),
    .scu_ar_credit_i               (scu_ar_credit_i),
    .scu_ar_block_i                (scu_ar_block_i),
    .scu_dr_valid_i                (scu_dr_valid_i),
    .scu_dr_id_i                   (scu_dr_id_i[4:0]),
    .scu_dr_resp_i                 (scu_dr_resp_i[5:0]),
    .scu_dr_chunk_i                (scu_dr_chunk_i[1:0]),
    .scu_dr_data_i                 (scu_dr_data_i[127:0]),
    .scu_rr_valid_i                (scu_rr_valid_i),
    .scu_rr_id_i                   (scu_rr_id_i[4:0]),
    .scu_rr_resp_i                 (scu_rr_resp_i[1:0]),
    .scu_rr_l2db_id_i              (scu_rr_l2db_id_i[3:0]),
    .scu_ev_done_i                 (scu_ev_done_i[7:0]),
    .scu_db_excl_valid_i           (scu_db_excl_valid_i),
    .scu_db_excl_resp_i            (scu_db_excl_resp_i[1:0]),
    .scu_db_decerr_i               (scu_db_decerr_i),
    .scu_db_slverr_i               (scu_db_slverr_i),
    .scu_ac_valid_i                (scu_ac_valid_i),
    .scu_ac_id_i                   (scu_ac_id_i[2:0]),
    .scu_ac_l2db_id_i              (scu_ac_l2db_id_i[3:0]),
    .scu_ac_snoop_i                (scu_ac_snoop_i[3:0]),
    .scu_ac_addr_i                 (scu_ac_addr_i[40:0]),
    .scu_ac_way_i                  (scu_ac_way_i[3:0]),
    .scu_reqbufs_busy_i            (scu_reqbufs_busy_i[7:0]),
    .scu_dvm_complete_i            (scu_dvm_complete_i),
    .scu_drain_stb_i               (scu_drain_stb_i),
    .scu_leave_ramode_i            (scu_leave_ramode_i),
    .scu_evnt_l2_access_i          (scu_evnt_l2_access_i),
    .scu_evnt_l2_refill_i          (scu_evnt_l2_refill_i),
    .scu_evnt_l2_wb_i              (scu_evnt_l2_wb_i),
    .scu_evnt_snooped_data_i       (scu_evnt_snooped_data_i),
    .scu_evnt_bus_cycle_i          (scu_evnt_bus_cycle_i),
    .scu_evnt_bus_acc_rd_i         (scu_evnt_bus_acc_rd_i),
    .scu_evnt_bus_acc_wr_i         (scu_evnt_bus_acc_wr_i),
    .scu_evnt_eviction_i           (scu_evnt_eviction_i),
    .gic_irq_i                     (gic_irq_i),
    .gic_fiq_i                     (gic_fiq_i),
    .gic_virq_i                    (gic_virq_i),
    .gic_vfiq_i                    (gic_vfiq_i),
    .gov_sei_level_req_i           (gov_sei_level_req_i),
    .gov_vsei_level_req_i          (gov_vsei_level_req_i),
    .gov_rei_level_req_i           (gov_rei_level_req_i),
    .gov_int_active_i              (gov_int_active_i),
    .gic_icc_sre_el1_ns_sre_i      (gic_icc_sre_el1_ns_sre_i),
    .gic_icc_sre_el1_s_sre_i       (gic_icc_sre_el1_s_sre_i),
    .gic_icc_sre_el2_enable_i      (gic_icc_sre_el2_enable_i),
    .gic_icc_sre_el2_sre_i         (gic_icc_sre_el2_sre_i),
    .gic_icc_sre_el3_enable_i      (gic_icc_sre_el3_enable_i),
    .gic_icc_sre_el3_sre_i         (gic_icc_sre_el3_sre_i),
    .gic_ich_hcr_el2_tall0_i       (gic_ich_hcr_el2_tall0_i),
    .gic_ich_hcr_el2_tall1_i       (gic_ich_hcr_el2_tall1_i),
    .gic_ich_hcr_el2_tc_i          (gic_ich_hcr_el2_tc_i),
    .gov_stall_neon_i              (gov_stall_neon_i),
    .gov_pseldbg_dbg_i             (gov_pseldbg_dbg_i),
    .gov_pseldbg_pmu_i             (gov_pseldbg_pmu_i),
    .gov_pseldbg_etm_i             (gov_pseldbg_etm_i),
    .gov_paddrdbg_i                (gov_paddrdbg_i[11:2]),
    .gov_paddrdbg31_i              (gov_paddrdbg31_i),
    .gov_penabledbg_i              (gov_penabledbg_i),
    .gov_pwdatadbg_i               (gov_pwdatadbg_i[31:0]),
    .gov_pwritedbg_i               (gov_pwritedbg_i),
    .gov_etmpdsr_rd_i              (gov_etmpdsr_rd_i),
    .gov_dbgen_i                   (gov_dbgen_i),
    .gov_spiden_i                  (gov_spiden_i),
    .gov_niden_i                   (gov_niden_i),
    .gov_spniden_i                 (gov_spniden_i),
    .gov_edbgrq_i                  (gov_edbgrq_i),
    .gov_dbgrestart_i              (gov_dbgrestart_i),
    .gov_dbgromaddr_i              (gov_dbgromaddr_i[39:12]),
    .gov_dbgromaddrv_i             (gov_dbgromaddrv_i),
    .gov_dbgpwrupreq_i             (gov_dbgpwrupreq_i),
    .gov_dbgl1rstdisable_i         (gov_dbgl1rstdisable_i),
    .gov_edecr_osuce_i             (gov_edecr_osuce_i),
    .gov_edecr_rce_i               (gov_edecr_rce_i),
    .gov_edecr_ss_i                (gov_edecr_ss_i),
    .gov_edlsr_slk_i               (gov_edlsr_slk_i),
    .gov_pmlsr_slk_i               (gov_pmlsr_slk_i),
    .gov_extin_i                   (gov_extin_i[(`CA53_ETMEXT_W-1):0]),
    .gov_cp_ack_i                  (gov_cp_ack_i),
    .gov_cp_rdata_i                (gov_cp_rdata_i[(`CA53_CPDATA_W-1):0]),
    .gov_stall_dsb_i               (gov_stall_dsb_i),
    .gov_atclken_i                 (gov_atclken_i),
    .gov_atreadym_i                (gov_atreadym_i),
    .gov_afvalidm_i                (gov_afvalidm_i),
    .gov_syncreqm_i                (gov_syncreqm_i),
    .gov_tsvalueb_i                (gov_tsvalueb_i[63:0]),
    .gov_pcnt_kernel_access_i      (gov_pcnt_kernel_access_i),
    .gov_pcnt_usr_access_i         (gov_pcnt_usr_access_i),
    .gov_vcnt_usr_access_i         (gov_vcnt_usr_access_i),
    .gov_cntp_usr_access_i         (gov_cntp_usr_access_i),
    .gov_cntv_usr_access_i         (gov_cntv_usr_access_i),
    .gov_cntp_kernel_access_i      (gov_cntp_kernel_access_i),
    .gov_rvbaraddr_i               (gov_rvbaraddr_i[39:2]),
    .gov_aa64naa32_i               (gov_aa64naa32_i),
    .gov_cryptodisable_i           (gov_cryptodisable_i),
    .gov_cp15sdisable_i            (gov_cp15sdisable_i),
    .gov_cfgend_i                  (gov_cfgend_i),
    .gov_vinithi_i                 (gov_vinithi_i),
    .gov_cfgte_i                   (gov_cfgte_i),
    .gov_clusteridaff1_i           (gov_clusteridaff1_i[7:0]),
    .gov_clusteridaff2_i           (gov_clusteridaff2_i[7:0]),
    .cpu_id_i                      (cpu_id_i[1:0]),
    .ctr_cwg_i                     (ctr_cwg_i[3:0]),
    .ctr_erg_i                     (ctr_erg_i[3:0]),
    .gov_periphbase_i              (gov_periphbase_i[39:18]),
    .gov_giccdisable_i             (gov_giccdisable_i),
    .gov_mbist_req_i               (gov_mbist_req_i),
    .gov_event_reg_i               (gov_event_reg_i),
    .gov_wfx_drain_req_i           (gov_wfx_drain_req_i),
    .gov_wfx_wake_i                (gov_wfx_wake_i),
    .gov_standbywfi_i              (gov_standbywfi_i),
    .gov_standbywfe_i              (gov_standbywfe_i),
    .l2_size_i                     (l2_size_i[3:0]),
    .ic_size_i                     (ic_size[2:0]),
    .dc_size_i                     (dc_size[2:0]),
    .scu_broadcastinner_i          (scu_broadcastinner_i),
    .dc_dataram_rdata0_i           (dc_dataram_rdata0[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata1_i           (dc_dataram_rdata1[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata2_i           (dc_dataram_rdata2[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata3_i           (dc_dataram_rdata3[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata4_i           (dc_dataram_rdata4[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata5_i           (dc_dataram_rdata5[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata6_i           (dc_dataram_rdata6[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_rdata7_i           (dc_dataram_rdata7[(`CA53_DDATA_RAM_W-1):0]),
    .dc_tagram_rdata0_i            (dc_tagram_rdata0[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata1_i            (dc_tagram_rdata1[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata2_i            (dc_tagram_rdata2[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_rdata3_i            (dc_tagram_rdata3[(`CA53_DTAG_RAM_W-1):0]),
    .dc_dirtyram_rdata_i           (dc_dirtyram_rdata[(`CA53_DDIRTY_RAM_W-1):0]),
    .ic_dataram_rdata0_i           (ic_dataram_rdata0[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_rdata1_i           (ic_dataram_rdata1[(`CA53_IDATA_RAM_W-1):0]),
    .ic_tagram_rdata0_i            (ic_tagram_rdata0[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_rdata1_i            (ic_tagram_rdata1[(`CA53_ITAG_RAM_W-1):0]),
    .tlb_ram_rdata0_i              (tlb_ram_rdata0[(`CA53_TLB_RAM_W-1):0]),
    .tlb_ram_rdata1_i              (tlb_ram_rdata1[(`CA53_TLB_RAM_W-1):0]),
    .tlb_ram_rdata2_i              (tlb_ram_rdata2[(`CA53_TLB_RAM_W-1):0]),
    .tlb_ram_rdata3_i              (tlb_ram_rdata3[(`CA53_TLB_RAM_W-1):0]),
    .btac_stg0_ram_rdata_i         (btac_stg0_ram_rdata[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg1_ram_rdata_i         (btac_stg1_ram_rdata[(`CA53_BTAC_RAM_S1D_W-1):0]),
    // Outputs
    .biu_ar_active_o               (biu_ar_active_o),
    .biu_ar_valid_o                (biu_ar_valid_o),
    .biu_ar_id_o                   (biu_ar_id_o[4:0]),
    .biu_ar_type_o                 (biu_ar_type_o[4:0]),
    .biu_ar_attrs_o                (biu_ar_attrs_o[7:0]),
    .biu_ar_way_o                  (biu_ar_way_o[4:0]),
    .biu_ar_addr_o                 (biu_ar_addr_o[40:0]),
    .biu_ar_len_o                  (biu_ar_len_o[1:0]),
    .biu_ar_size_o                 (biu_ar_size_o[2:0]),
    .biu_ar_lock_o                 (biu_ar_lock_o),
    .biu_ar_priv_o                 (biu_ar_priv_o),
    .biu_dr_credit_o               (biu_dr_credit_o),
    .biu_dw_valid_o                (biu_dw_valid_o),
    .biu_dw_l2db_id_o              (biu_dw_l2db_id_o[3:0]),
    .biu_dw_chunks_valid_o         (biu_dw_chunks_valid_o[3:0]),
    .biu_dw_last_o                 (biu_dw_last_o),
    .biu_dw_strb_o                 (biu_dw_strb_o[31:0]),
    .biu_dw_data_o                 (biu_dw_data_o[255:0]),
    .biu_dw_err_o                  (biu_dw_err_o),
    .biu_dw_fatal_o                (biu_dw_fatal_o),
    .dcu_ac_ready_o                (dcu_ac_ready_o),
    .dcu_cr_valid_o                (dcu_cr_valid_o),
    .dcu_cr_id_o                   (dcu_cr_id_o[2:0]),
    .dcu_cr_dirty_o                (dcu_cr_dirty_o),
    .dcu_cr_age_o                  (dcu_cr_age_o),
    .dcu_cr_alloc_o                (dcu_cr_alloc_o),
    .dcu_cr_migratory_o            (dcu_cr_migratory_o),
    .dcu_dvm_complete_o            (dcu_dvm_complete_o),
    .dpu_exception_level_o         (dpu_exception_level_o[1:0]),
    .dpu_aarch64_at_el3_o          (dpu_aarch64_at_el3_o),
    .dpu_dscr_halted_o             (dpu_dscr_halted_o),
    .dpu_hcr_el2_fmo_o             (dpu_hcr_el2_fmo_o),
    .dpu_hcr_el2_imo_o             (dpu_hcr_el2_imo_o),
    .dpu_hcr_el2_amo_o             (dpu_hcr_el2_amo_o),
    .dpu_monitor_mode_o            (dpu_monitor_mode_o),
    .dpu_rei_level_ack_o           (dpu_rei_level_ack_o),
    .dpu_scr_el3_fiq_o             (dpu_scr_el3_fiq_o),
    .dpu_scr_el3_irq_o             (dpu_scr_el3_irq_o),
    .dpu_scr_el3_ns_o              (dpu_scr_el3_ns_o),
    .dpu_sei_level_ack_o           (dpu_sei_level_ack_o),
    .dpu_vsei_level_ack_o          (dpu_vsei_level_ack_o),
    .dpu_wfi_req_o                 (dpu_wfi_req_o),
    .dpu_wfe_req_o                 (dpu_wfe_req_o),
    .dpu_irq_pended_o              (dpu_irq_pended_o),
    .dpu_fiq_pended_o              (dpu_fiq_pended_o),
    .dpu_sei_pended_o              (dpu_sei_pended_o),
    .dpu_irq_masked_o              (dpu_irq_masked_o),
    .dpu_fiq_masked_o              (dpu_fiq_masked_o),
    .dpu_sei_masked_o              (dpu_sei_masked_o),
    .dpu_virq_pended_o             (dpu_virq_pended_o),
    .dpu_vfiq_pended_o             (dpu_vfiq_pended_o),
    .dpu_vsei_pended_o             (dpu_vsei_pended_o),
    .dpu_virq_masked_o             (dpu_virq_masked_o),
    .dpu_vfiq_masked_o             (dpu_vfiq_masked_o),
    .dpu_vsei_masked_o             (dpu_vsei_masked_o),
    .dpu_dbg_double_lock_set_o     (dpu_dbg_double_lock_set_o),
    .dpu_ns_state_o                (dpu_ns_state_o),
    .stb_wfx_ready_o               (stb_wfx_ready_o),
    .biu_wfx_ready_o               (biu_wfx_ready_o),
    .dcu_wfx_ready_o               (dcu_wfx_ready_o),
    .ifu_wfx_ready_o               (ifu_wfx_ready_o),
    .tlb_wfx_ready_o               (tlb_wfx_ready_o),
    .etm_wfx_ready_o               (etm_wfx_ready_o),
    .dpu_imp_abort_pending_o       (dpu_imp_abort_pending_o),
    .dpu_cpuectlr_cpu_ret_delay_o  (dpu_cpuectlr_cpu_ret_delay_o[2:0]),
    .dpu_cpuectlr_neon_ret_delay_o (dpu_cpuectlr_neon_ret_delay_o[2:0]),
    .dpu_neon_active_o             (dpu_neon_active_o),
    .dpu_prdatadbg_o               (dpu_prdatadbg_o[31:0]),
    .etm_prdatadbg_o               (etm_prdatadbg_o[31:0]),
    .dpu_preadydbg_o               (dpu_preadydbg_o),
    .etm_preadydbg_o               (etm_preadydbg_o),
    .dpu_pslverrdbg_o              (dpu_pslverrdbg_o),
    .dpu_dbgack_o                  (dpu_dbgack_o),
    .dpu_dbgtrigger_o              (dpu_dbgtrigger_o),
    .dpu_commrx_o                  (dpu_commrx_o),
    .dpu_commtx_o                  (dpu_commtx_o),
    .dpu_ncommirq_o                (dpu_ncommirq_o),
    .dpu_dbgrstreq_o               (dpu_dbgrstreq_o),
    .dpu_dbgnopwrdwn_o             (dpu_dbgnopwrdwn_o),
    .etm_extout_o                  (etm_extout_o[(`CA53_ETMEXT_W-1):0]),
    .etm_oslock_o                  (etm_oslock_o),
    .dcu_excl_mon_cleared_o        (dcu_excl_mon_cleared_o),
    .dcu_cp_gov_addr_o             (dcu_cp_gov_addr_o[(`CA53_CPADDR_W-1):0]),
    .dcu_cp_gov_ns_o               (dcu_cp_gov_ns_o),
    .dcu_cp_gov_req_o              (dcu_cp_gov_req_o),
    .dcu_cp_gov_sel_o              (dcu_cp_gov_sel_o[(`CA53_CPSEL_W-1):0]),
    .dcu_cp_gov_wdata_o            (dcu_cp_gov_wdata_o[(`CA53_CPDATA_W-1):0]),
    .dcu_cp_gov_wenable_o          (dcu_cp_gov_wenable_o),
    .etm_atdatam_o                 (etm_atdatam_o[(`CA53_ATDATAM_W-1):0]),
    .etm_atvalidm_o                (etm_atvalidm_o),
    .etm_atbytesm_o                (etm_atbytesm_o[(`CA53_ATBYTESM_W-1):0]),
    .etm_afreadym_o                (etm_afreadym_o),
    .etm_atidm_o                   (etm_atidm_o[(`CA53_ATIDM_W-1):0]),
    .dpu_warmrstreq_o              (dpu_warmrstreq_o),
    .dpu_smp_en_o                  (dpu_smp_en_o),
    .dpu_sev_req_o                 (dpu_sev_req_o),
    .dpu_clr_event_register_o      (dpu_clr_event_register_o),
    .dpu_npmuirq_o                 (dpu_npmuirq_o),
    .dpu_pmuevent_o                (dpu_pmuevent_o[25:0]),
    .dc_dataram_en_o               (dc_dataram_en[7:0]),
    .dc_dataram_strb0_o            (dc_dataram_strb0[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb1_o            (dc_dataram_strb1[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb2_o            (dc_dataram_strb2[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb3_o            (dc_dataram_strb3[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb4_o            (dc_dataram_strb4[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb5_o            (dc_dataram_strb5[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb6_o            (dc_dataram_strb6[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_strb7_o            (dc_dataram_strb7[(`CA53_DDATA_WEN_W-1):0]),
    .dc_dataram_wr_o               (dc_dataram_wr),
    .dc_dataram_wdata0_o           (dc_dataram_wdata0[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata1_o           (dc_dataram_wdata1[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata2_o           (dc_dataram_wdata2[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata3_o           (dc_dataram_wdata3[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata4_o           (dc_dataram_wdata4[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata5_o           (dc_dataram_wdata5[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata6_o           (dc_dataram_wdata6[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_wdata7_o           (dc_dataram_wdata7[(`CA53_DDATA_RAM_W-1):0]),
    .dc_dataram_addr0_o            (dc_dataram_addr0[10:0]),
    .dc_dataram_addr1_o            (dc_dataram_addr1[10:0]),
    .dc_dataram_addr2_o            (dc_dataram_addr2[10:0]),
    .dc_dataram_addr3_o            (dc_dataram_addr3[10:0]),
    .dc_dataram_addr4_o            (dc_dataram_addr4[10:0]),
    .dc_dataram_addr5_o            (dc_dataram_addr5[10:0]),
    .dc_dataram_addr6_o            (dc_dataram_addr6[10:0]),
    .dc_dataram_addr7_o            (dc_dataram_addr7[10:0]),
    .dc_tagram_en_o                (dc_tagram_en[3:0]),
    .dc_tagram_wr_o                (dc_tagram_wr),
    .dc_tagram_wdata_o             (dc_tagram_wdata[(`CA53_DTAG_RAM_W-1):0]),
    .dc_tagram_addr_o              (dc_tagram_addr[7:0]),
    .dc_dirtyram_en_o              (dc_dirtyram_en),
    .dc_dirtyram_wr_o              (dc_dirtyram_wr),
    .dc_dirtyram_strb_o            (dc_dirtyram_strb[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_dirtyram_wdata_o           (dc_dirtyram_wdata[(`CA53_DDIRTY_RAM_W-1):0]),
    .dc_dirtyram_addr_o            (dc_dirtyram_addr[8:0]),
    .ic_dataram_en_o               (ic_dataram_en[3:0]),
    .ic_dataram_wr_o               (ic_dataram_wr),
    .ic_dataram_strb0_o            (ic_dataram_strb0[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_strb1_o            (ic_dataram_strb1[(`CA53_IDATA_WEN_W-1):0]),
    .ic_dataram_wdata0_o           (ic_dataram_wdata0[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_wdata1_o           (ic_dataram_wdata1[(`CA53_IDATA_RAM_W-1):0]),
    .ic_dataram_addr0_o            (ic_dataram_addr0[11:0]),
    .ic_dataram_addr1_o            (ic_dataram_addr1[11:0]),
    .ic_tagram_en_o                (ic_tagram_en[1:0]),
    .ic_tagram_wr_o                (ic_tagram_wr),
    .ic_tagram_wdata_o             (ic_tagram_wdata[(`CA53_ITAG_RAM_W-1):0]),
    .ic_tagram_addr_o              (ic_tagram_addr[8:0]),
    .tlb_ram_en_o                  (tlb_ram_en[3:0]),
    .tlb_ram_wr_o                  (tlb_ram_wr),
    .tlb_ram_addr_o                (tlb_ram_addr[(`CA53_TLB_RAM_ADDR_W-1):0]),
    .tlb_ram_wdata_o               (tlb_ram_wdata[(`CA53_TLB_RAM_W-1):0]),
    .btac_stg0_ram_en_o            (btac_stg0_ram_en),
    .btac_stg0_ram_wr_o            (btac_stg0_ram_wr),
    .btac_stg0_ram_wdata_o         (btac_stg0_ram_wdata[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg0_ram_addr_o          (btac_stg0_ram_addr[(`CA53_BTAC_RAM_ADDR_W-1):0]),
    .btac_stg1_ram_en_o            (btac_stg1_ram_en),
    .btac_stg1_ram_wr_o            (btac_stg1_ram_wr),
    .btac_stg1_ram_wdata_o         (btac_stg1_ram_wdata[(`CA53_BTAC_RAM_S1D_W-1):0]),
    .btac_stg1_ram_addr_o          (btac_stg1_ram_addr[(`CA53_BTAC_RAM_ADDR_W-1):0])
  );  // u_ca53_noram

  // ------------------------------------------------------
  // RAM block instantiation (all TLB/Instruction/Data RAMs)
  // ------------------------------------------------------

  ca53_caches_tlb_rams `CA53_L1_RAM_PARAM_INST u_ca53_caches_tlb_rams (
    /*ARMAUTO*/
    // Inputs
    .clk                   (clk),
    .DFTSE                 (DFTSE),
    .dc_dataram_en_i       (dc_dataram_en[7:0]),
    .dc_dataram_strb0_i    (dc_dataram_strb0[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb1_i    (dc_dataram_strb1[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb2_i    (dc_dataram_strb2[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb3_i    (dc_dataram_strb3[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb4_i    (dc_dataram_strb4[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb5_i    (dc_dataram_strb5[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb6_i    (dc_dataram_strb6[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_strb7_i    (dc_dataram_strb7[`CA53_DDATA_WEN_W-1:0]),
    .dc_dataram_wr_i       (dc_dataram_wr),
    .dc_dataram_wdata0_i   (dc_dataram_wdata0[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata1_i   (dc_dataram_wdata1[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata2_i   (dc_dataram_wdata2[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata3_i   (dc_dataram_wdata3[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata4_i   (dc_dataram_wdata4[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata5_i   (dc_dataram_wdata5[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata6_i   (dc_dataram_wdata6[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_wdata7_i   (dc_dataram_wdata7[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_addr0_i    (dc_dataram_addr0[10:0]),
    .dc_dataram_addr1_i    (dc_dataram_addr1[10:0]),
    .dc_dataram_addr2_i    (dc_dataram_addr2[10:0]),
    .dc_dataram_addr3_i    (dc_dataram_addr3[10:0]),
    .dc_dataram_addr4_i    (dc_dataram_addr4[10:0]),
    .dc_dataram_addr5_i    (dc_dataram_addr5[10:0]),
    .dc_dataram_addr6_i    (dc_dataram_addr6[10:0]),
    .dc_dataram_addr7_i    (dc_dataram_addr7[10:0]),
    .dc_tagram_en_i        (dc_tagram_en[3:0]),
    .dc_tagram_wr_i        (dc_tagram_wr),
    .dc_tagram_wdata_i     (dc_tagram_wdata[`CA53_DTAG_RAM_W-1:0]),
    .dc_tagram_addr_i      (dc_tagram_addr[7:0]),
    .dc_dirtyram_en_i      (dc_dirtyram_en),
    .dc_dirtyram_strb_i    (dc_dirtyram_strb[`CA53_DDIRTY_RAM_W-1:0]),
    .dc_dirtyram_wr_i      (dc_dirtyram_wr),
    .dc_dirtyram_wdata_i   (dc_dirtyram_wdata[`CA53_DDIRTY_RAM_W-1:0]),
    .dc_dirtyram_addr_i    (dc_dirtyram_addr[8:0]),
    .ic_dataram_en_i       (ic_dataram_en[3:0]),
    .ic_dataram_wr_i       (ic_dataram_wr),
    .ic_dataram_addr0_i    (ic_dataram_addr0[11:0]),
    .ic_dataram_addr1_i    (ic_dataram_addr1[11:0]),
    .ic_dataram_strb0_i    (ic_dataram_strb0[`CA53_IDATA_WEN_W-1:0]),
    .ic_dataram_strb1_i    (ic_dataram_strb1[`CA53_IDATA_WEN_W-1:0]),
    .ic_dataram_wdata0_i   (ic_dataram_wdata0[`CA53_IDATA_RAM_W-1:0]),
    .ic_dataram_wdata1_i   (ic_dataram_wdata1[`CA53_IDATA_RAM_W-1:0]),
    .ic_tagram_en_i        (ic_tagram_en[1:0]),
    .ic_tagram_wr_i        (ic_tagram_wr),
    .ic_tagram_wdata_i     (ic_tagram_wdata[`CA53_ITAG_RAM_W-1:0]),
    .ic_tagram_addr_i      (ic_tagram_addr[8:0]),
    .tlb_ram_en_i          (tlb_ram_en[3:0]),
    .tlb_ram_wr_i          (tlb_ram_wr),
    .tlb_ram_wdata_i       (tlb_ram_wdata[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_addr_i        (tlb_ram_addr[`CA53_TLB_RAM_ADDR_W-1:0]),
    .btac_stg0_ram_en_i    (btac_stg0_ram_en),
    .btac_stg0_ram_wr_i    (btac_stg0_ram_wr),
    .btac_stg0_ram_wdata_i (btac_stg0_ram_wdata[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg0_ram_addr_i  (btac_stg0_ram_addr[(`CA53_BTAC_RAM_ADDR_W-1):0]),
    .btac_stg1_ram_en_i    (btac_stg1_ram_en),
    .btac_stg1_ram_wr_i    (btac_stg1_ram_wr),
    .btac_stg1_ram_wdata_i (btac_stg1_ram_wdata[(`CA53_BTAC_RAM_S1D_W-1):0]),
    .btac_stg1_ram_addr_i  (btac_stg1_ram_addr[(`CA53_BTAC_RAM_ADDR_W-1):0]),
    // Outputs
    .ic_size_o             (ic_size[2:0]),
    .dc_size_o             (dc_size[2:0]),
    .dc_dataram_rdata0_o   (dc_dataram_rdata0[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata1_o   (dc_dataram_rdata1[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata2_o   (dc_dataram_rdata2[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata3_o   (dc_dataram_rdata3[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata4_o   (dc_dataram_rdata4[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata5_o   (dc_dataram_rdata5[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata6_o   (dc_dataram_rdata6[`CA53_DDATA_RAM_W-1:0]),
    .dc_dataram_rdata7_o   (dc_dataram_rdata7[`CA53_DDATA_RAM_W-1:0]),
    .dc_tagram_rdata0_o    (dc_tagram_rdata0[`CA53_DTAG_RAM_W-1:0]),
    .dc_tagram_rdata1_o    (dc_tagram_rdata1[`CA53_DTAG_RAM_W-1:0]),
    .dc_tagram_rdata2_o    (dc_tagram_rdata2[`CA53_DTAG_RAM_W-1:0]),
    .dc_tagram_rdata3_o    (dc_tagram_rdata3[`CA53_DTAG_RAM_W-1:0]),
    .dc_dirtyram_rdata_o   (dc_dirtyram_rdata[`CA53_DDIRTY_RAM_W-1:0]),
    .ic_dataram_rdata0_o   (ic_dataram_rdata0[`CA53_IDATA_RAM_W-1:0]),
    .ic_dataram_rdata1_o   (ic_dataram_rdata1[`CA53_IDATA_RAM_W-1:0]),
    .ic_tagram_rdata0_o    (ic_tagram_rdata0[`CA53_ITAG_RAM_W-1:0]),
    .ic_tagram_rdata1_o    (ic_tagram_rdata1[`CA53_ITAG_RAM_W-1:0]),
    .tlb_ram_rdata0_o      (tlb_ram_rdata0[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata1_o      (tlb_ram_rdata1[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata2_o      (tlb_ram_rdata2[`CA53_TLB_RAM_W-1:0]),
    .tlb_ram_rdata3_o      (tlb_ram_rdata3[`CA53_TLB_RAM_W-1:0]),
    .btac_stg0_ram_rdata_o (btac_stg0_ram_rdata[(`CA53_BTAC_RAM_S0D_W-1):0]),
    .btac_stg1_ram_rdata_o (btac_stg1_ram_rdata[(`CA53_BTAC_RAM_S1D_W-1):0])
  );  // u_ca53_caches_tlb_rams

endmodule // ca53_cpu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
