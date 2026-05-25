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
//      Checked In          : $Date: 2012-07-30 08:38:46 +0100 (Mon, 30 Jul 2012) $
//
//      Revision            : $Revision: 216795 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Top level of the CortexA53 CPU (without RAMs)
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
// g) Checks Clock Enables              1            2
//
// Notes
// -----
// 1. Data is written to a ^2 alias address, which will be location 0 if the RAM
//    is the correct size. If the RAM is too large, RAM will read back 0.
//    It isn't possible to write to an alias for the largest cache size.
//    A too small RAM is checked for by (1).
// 2. Only for those RAM's which have a clock gate inside RAM wrapper.
//

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

  
  localparam SIZE_WIDTH = 3;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_8K     = 3'b000;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_16K    = 3'b001;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_32K    = 3'b011;
  localparam [SIZE_WIDTH-1:0] CORTEXA53_SIZE_64K    = 3'b111;

  localparam STATE_WIDTH = 4;
  localparam [STATE_WIDTH-1:0] STATE_IDLE         = 4'b0000;
  localparam [STATE_WIDTH-1:0] START_D_DATARAM    = 4'b0001;
  localparam [STATE_WIDTH-1:0] START_D_TAGRAM     = 4'b0010;
  localparam [STATE_WIDTH-1:0] START_I_DATARAM    = 4'b0011;
  localparam [STATE_WIDTH-1:0] START_I_TAGRAM     = 4'b0100;
  localparam [STATE_WIDTH-1:0] START_TLBRAM       = 4'b0101;
  localparam [STATE_WIDTH-1:0] START_DIRTYRAM     = 4'b0110;
  localparam [STATE_WIDTH-1:0] START_BTACRAM_STG0 = 4'b0111;
  localparam [STATE_WIDTH-1:0] START_BTACRAM_STG1 = 4'b1000;
  localparam [STATE_WIDTH-1:0] STATE_FINISH       = 4'b1001;

  localparam PRINT_WIDTH = 4;
  localparam [STATE_WIDTH-1:0] PRINT_IDLE         = 4'b0000;
  localparam [PRINT_WIDTH-1:0] PRINT_HEADER       = 4'b0001;
  localparam [PRINT_WIDTH-1:0] WAIT_FOR_DONE      = 4'b0010;
  localparam [PRINT_WIDTH-1:0] PRINT_D_DATARAM    = 4'b0011;
  localparam [PRINT_WIDTH-1:0] PRINT_D_TAGRAM     = 4'b0100;
  localparam [PRINT_WIDTH-1:0] PRINT_I_DATARAM    = 4'b0101;
  localparam [PRINT_WIDTH-1:0] PRINT_I_TAGRAM     = 4'b0110;
  localparam [PRINT_WIDTH-1:0] PRINT_TLBRAM       = 4'b0111;
  localparam [PRINT_WIDTH-1:0] PRINT_DIRTYRAM     = 4'b1000;
  localparam [STATE_WIDTH-1:0] PRINT_BTACRAM_STG0 = 4'b1001;
  localparam [STATE_WIDTH-1:0] PRINT_BTACRAM_STG1 = 4'b1010;
  localparam [PRINT_WIDTH-1:0] PRINT_FINISH       = 4'b1011;

   //Wire and Reg Declarations
   //-------------------------

  reg  [7 * 8 : 1] dc_size_str;
  reg  [7 * 8 : 1] ic_size_str;
  reg  [10:0]      max_d_dataram_range;
  reg  [7:0 ]      max_d_tagram_range;
  reg  [11:0]      max_i_dataram_range;
  reg  [8:0]       max_i_tagram_range;
  reg  [8:0 ]      max_dirtyram_range;

  reg  [3:0 ]      next_state;
  reg  [3:0 ]      state;
  reg  [3:0 ]      print_state;
  reg  [3:0 ]      print_next_state;
  reg  [1:0]       start_count;

  wire [7:0 ]      max_tlbram_range;
  wire [6:0]       max_btacram_range;
  wire [1:0]       start_count_end;
  wire             start_count_en;
  wire [1:0]       start_count_nxt;

  wire             dc_dataram_passed_num1;
  wire             dc_dataram_passed_num2;
  wire             dc_dataram_passed_num3;
  wire             dc_dataram_done_num1;
  wire             dc_dataram_done_num2;
  wire             dc_dataram_done_num3;
  wire             dc_tagram_passed_num1;
  wire             dc_tagram_passed_num2;
  wire             dc_tagram_done_num1;
  wire             dc_tagram_done_num2;
  wire             ic_dataram_passed_num1;
  wire             ic_dataram_passed_num2;
  wire             ic_dataram_passed_num3;
  wire             ic_dataram_done_num1;
  wire             ic_dataram_done_num2;
  wire             ic_dataram_done_num3;
  wire             ic_tagram_passed_num1;
  wire             ic_tagram_passed_num2;
  wire             ic_tagram_done_num1;
  wire             ic_tagram_done_num2;
  wire             dc_dirtyram_passed_num1;
  wire             dc_dirtyram_passed_num2;
  wire             dc_dirtyram_passed_num3;
  wire             dc_dirtyram_done_num1;
  wire             dc_dirtyram_done_num2;
  wire             dc_dirtyram_done_num3;
  wire             tlbram_passed_num1;
  wire             tlbram_passed_num2;
  wire             tlbram_done_num1;
  wire             tlbram_done_num2;
  wire             btacram_stg0_passed_num1;
  wire             btacram_stg0_passed_num2;
  wire             btacram_stg0_done_num1;
  wire             btacram_stg0_done_num2;
  wire             all_tests_completed;
  wire             all_tests_passed;
  wire             debug;

   // -----------------------------------------------------------------------------
   // Convert D-Cache size to string (for testbench summary output)
   // -----------------------------------------------------------------------------


  assign max_tlbram_range  = {8{1'b1}};
  assign max_btacram_range = {`CA53_BTAC_RAM_ADDR_W{1'b1}};

  always @(negedge reset_n_cpu)
    if (!reset_n_cpu)
      case (dc_size_i)
        CORTEXA53_SIZE_8K: begin
          dc_size_str          <= "8kB";
          max_d_dataram_range  <= 11'b00011111111;
          max_d_tagram_range   <= 8'b00011111;
          max_dirtyram_range   <= 9'b000111111;
        end

        CORTEXA53_SIZE_16K: begin
          dc_size_str          <= "16kB";
          max_d_dataram_range  <= 11'b00111111111;
          max_d_tagram_range   <= 8'b00111111;
          max_dirtyram_range   <= 9'b001111111;
        end

        CORTEXA53_SIZE_32K: begin
          dc_size_str          <= "32kB";
          max_d_dataram_range  <= 11'b01111111111;
          max_d_tagram_range   <= 8'b01111111;
          max_dirtyram_range   <= 9'b011111111;
        end

        CORTEXA53_SIZE_64K: begin
          dc_size_str          <= "64kB";
          max_d_dataram_range  <= 11'b11111111111;
          max_d_tagram_range   <= 8'b11111111;
          max_dirtyram_range   <= 9'b111111111;
        end
        default: begin
          dc_size_str         <= "Invalid";
          max_d_dataram_range <= 11'b00000000000;
          max_d_tagram_range   <= 8'b00000000;
          max_dirtyram_range   <= 9'b000000000;
        end
      endcase

   // -----------------------------------------------------------------------------
   // Convert I-Cache size to string (for testbench summary output)
   // -----------------------------------------------------------------------------

  always @(negedge reset_n_cpu)
    if (!reset_n_cpu)
      case (ic_size_i)
        CORTEXA53_SIZE_8K: begin
          ic_size_str          <= "8kB";
          max_i_dataram_range  <= 12'b000111111111;
          max_i_tagram_range   <= 9'b000111111;
        end

        CORTEXA53_SIZE_16K: begin
          ic_size_str          <= "16kB";
          max_i_dataram_range  <= 12'b001111111111;
          max_i_tagram_range   <= 9'b001111111;
        end

        CORTEXA53_SIZE_32K: begin
          ic_size_str          <= "32kB";
          max_i_dataram_range  <= 12'b011111111111;
          max_i_tagram_range   <= 9'b011111111;
        end

        CORTEXA53_SIZE_64K: begin
          ic_size_str          <= "64kB";
          max_i_dataram_range  <= 12'b111111111111;
          max_i_tagram_range   <= 9'b111111111;
        end
        default: begin
          ic_size_str         <= "Invalid";
          max_i_dataram_range <= 12'b00000000000;
          max_i_tagram_range  <= 9'b000000000;
        end
      endcase

   // -------------------------------------------
   // State Machine to trigger L1 TB (staggered)
   // ------------------------------------------

   always @*
    case (state)
      STATE_IDLE         : next_state = reset_n_cpu ? START_D_DATARAM : STATE_IDLE;
      START_D_DATARAM    : next_state = start_count == start_count_end ? START_D_TAGRAM     : START_D_DATARAM    ;
      START_D_TAGRAM     : next_state = start_count == start_count_end ? START_I_DATARAM    : START_D_TAGRAM     ;
      START_I_DATARAM    : next_state = start_count == start_count_end ? START_I_TAGRAM     : START_I_DATARAM    ;
      START_I_TAGRAM     : next_state = start_count == start_count_end ? START_TLBRAM       : START_I_TAGRAM     ;
      START_TLBRAM       : next_state = start_count == start_count_end ? START_DIRTYRAM     : START_TLBRAM       ;
      START_DIRTYRAM     : next_state = start_count == start_count_end ? START_BTACRAM_STG0 : START_DIRTYRAM     ;
      START_BTACRAM_STG0 : next_state = start_count == start_count_end ? START_BTACRAM_STG1 : START_BTACRAM_STG0 ;
      START_BTACRAM_STG1 : next_state = start_count == start_count_end ? STATE_FINISH       : START_BTACRAM_STG1 ;
      STATE_FINISH       : next_state = STATE_FINISH;
      default            : next_state = STATE_IDLE;
    endcase

    //Registering the next stage
   always @(posedge clk or negedge reset_n_cpu)
    if (!reset_n_cpu) begin
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

   always @(posedge clk or negedge reset_n_cpu)
    if (!reset_n_cpu) begin
      start_count <= 2'h0;
    end else if (start_count_en) begin
      start_count <= start_count_nxt;
    end

   // --------------------------
   // L1- Testbench Declarations
   // ---------------------------

  ca53_d_dataram_tb  #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_d_dataram_tb (
   .dc_dataram_en_o          (dc_dataram_en_o       ),
   .dc_dataram_strb0_o       (dc_dataram_strb0_o    ),
   .dc_dataram_strb1_o       (dc_dataram_strb1_o    ),
   .dc_dataram_strb2_o       (dc_dataram_strb2_o    ),
   .dc_dataram_strb3_o       (dc_dataram_strb3_o    ),
   .dc_dataram_strb4_o       (dc_dataram_strb4_o    ),
   .dc_dataram_strb5_o       (dc_dataram_strb5_o    ),
   .dc_dataram_strb6_o       (dc_dataram_strb6_o    ),
   .dc_dataram_strb7_o       (dc_dataram_strb7_o    ),
   .dc_dataram_wr_o          (dc_dataram_wr_o       ),
   .dc_dataram_wdata0_o      (dc_dataram_wdata0_o   ),
   .dc_dataram_wdata1_o      (dc_dataram_wdata1_o   ),
   .dc_dataram_wdata2_o      (dc_dataram_wdata2_o   ),
   .dc_dataram_wdata3_o      (dc_dataram_wdata3_o   ),
   .dc_dataram_wdata4_o      (dc_dataram_wdata4_o   ),
   .dc_dataram_wdata5_o      (dc_dataram_wdata5_o   ),
   .dc_dataram_wdata6_o      (dc_dataram_wdata6_o   ),
   .dc_dataram_wdata7_o      (dc_dataram_wdata7_o   ),
   .dc_dataram_addr0_o       (dc_dataram_addr0_o    ),
   .dc_dataram_addr1_o       (dc_dataram_addr1_o    ),
   .dc_dataram_addr2_o       (dc_dataram_addr2_o    ),
   .dc_dataram_addr3_o       (dc_dataram_addr3_o    ),
   .dc_dataram_addr4_o       (dc_dataram_addr4_o    ),
   .dc_dataram_addr5_o       (dc_dataram_addr5_o    ),
   .dc_dataram_addr6_o       (dc_dataram_addr6_o    ),
   .dc_dataram_addr7_o       (dc_dataram_addr7_o    ),
   .dc_dataram_rdata0_i      (dc_dataram_rdata0_i   ),
   .dc_dataram_rdata1_i      (dc_dataram_rdata1_i   ),
   .dc_dataram_rdata2_i      (dc_dataram_rdata2_i   ),
   .dc_dataram_rdata3_i      (dc_dataram_rdata3_i   ),
   .dc_dataram_rdata4_i      (dc_dataram_rdata4_i   ),
   .dc_dataram_rdata5_i      (dc_dataram_rdata5_i   ),
   .dc_dataram_rdata6_i      (dc_dataram_rdata6_i   ),
   .dc_dataram_rdata7_i      (dc_dataram_rdata7_i   ),

   .dc_dataram_passed_num1_o (dc_dataram_passed_num1),
   .dc_dataram_passed_num2_o (dc_dataram_passed_num2),
   .dc_dataram_passed_num3_o (dc_dataram_passed_num3),
   .dc_dataram_done_num1_o   (dc_dataram_done_num1  ),
   .dc_dataram_done_num2_o   (dc_dataram_done_num2  ),
   .dc_dataram_done_num3_o   (dc_dataram_done_num3  ),
   .clk                      (clk                   ),
   .reset_n                  (reset_n_cpu           ),
   .max_d_dataram_range      (max_d_dataram_range   ),
   .test_start_i             (state == START_D_DATARAM)
  );

 ca53_d_tagram_tb #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_d_tagram_tb (
   .dc_tagram_en_o           (dc_tagram_en_o       ),
   .dc_tagram_wr_o           (dc_tagram_wr_o       ),
   .dc_tagram_wdata_o        (dc_tagram_wdata_o    ),
   .dc_tagram_addr_o         (dc_tagram_addr_o     ),
   .dc_tagram_rdata0_i       (dc_tagram_rdata0_i   ),
   .dc_tagram_rdata1_i       (dc_tagram_rdata1_i   ),
   .dc_tagram_rdata2_i       (dc_tagram_rdata2_i   ),
   .dc_tagram_rdata3_i       (dc_tagram_rdata3_i   ),

   .dc_tagram_passed_num1_o  (dc_tagram_passed_num1),
   .dc_tagram_passed_num2_o  (dc_tagram_passed_num2),
   .dc_tagram_done_num1_o    (dc_tagram_done_num1  ),
   .dc_tagram_done_num2_o    (dc_tagram_done_num2  ),
   .clk                      (clk                  ),
   .reset_n                  (reset_n_cpu          ),
   .dc_size_i                (dc_size_i            ),
   .max_d_tagram_range       (max_d_tagram_range   ),
   .test_start_i             (state == START_D_TAGRAM)
 );

 ca53_i_dataram_tb  #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_i_dataram_tb (
   .ic_dataram_en_o          (ic_dataram_en_o       ),
   .ic_dataram_wr_o          (ic_dataram_wr_o       ),
   .ic_dataram_strb0_o       (ic_dataram_strb0_o    ),
   .ic_dataram_strb1_o       (ic_dataram_strb1_o    ),
   .ic_dataram_wdata0_o      (ic_dataram_wdata0_o   ),
   .ic_dataram_wdata1_o      (ic_dataram_wdata1_o   ),
   .ic_dataram_addr0_o       (ic_dataram_addr0_o    ),
   .ic_dataram_addr1_o       (ic_dataram_addr1_o    ),
   .ic_dataram_rdata0_i      (ic_dataram_rdata0_i   ),
   .ic_dataram_rdata1_i      (ic_dataram_rdata1_i   ),

   .ic_dataram_passed_num1_o (ic_dataram_passed_num1),
   .ic_dataram_passed_num2_o (ic_dataram_passed_num2),
   .ic_dataram_passed_num3_o (ic_dataram_passed_num3),
   .ic_dataram_done_num1_o   (ic_dataram_done_num1  ),
   .ic_dataram_done_num2_o   (ic_dataram_done_num2  ),
   .ic_dataram_done_num3_o   (ic_dataram_done_num3  ),
   .clk                      (clk                   ),
   .reset_n                  (reset_n_cpu                   ),
   .max_i_dataram_range      (max_i_dataram_range   ),
   .test_start_i             (state == START_I_DATARAM)
  );

 ca53_i_tagram_tb #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_i_tagram_tb (
   .ic_tagram_en_o           (ic_tagram_en_o       ),
   .ic_tagram_wr_o           (ic_tagram_wr_o       ),
   .ic_tagram_wdata_o        (ic_tagram_wdata_o    ),
   .ic_tagram_addr_o         (ic_tagram_addr_o     ),
   .ic_tagram_rdata0_i       (ic_tagram_rdata0_i   ),
   .ic_tagram_rdata1_i       (ic_tagram_rdata1_i   ),

   .ic_tagram_passed_num1_o  (ic_tagram_passed_num1),
   .ic_tagram_passed_num2_o  (ic_tagram_passed_num2),
   .ic_tagram_done_num1_o    (ic_tagram_done_num1  ),
   .ic_tagram_done_num2_o    (ic_tagram_done_num2  ),
   .clk                      (clk                  ),
   .reset_n                  (reset_n_cpu          ),
   .max_i_tagram_range       (max_i_tagram_range   ),
   .test_start_i             (state == START_I_TAGRAM)
 );

 ca53_dirtyram_tb #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53_dirtyram_tb (
  .dc_dirtyram_en_o          (dc_dirtyram_en_o       ),
  .dc_dirtyram_wr_o          (dc_dirtyram_wr_o       ),
  .dc_dirtyram_strb_o        (dc_dirtyram_strb_o     ),
  .dc_dirtyram_wdata_o       (dc_dirtyram_wdata_o    ),
  .dc_dirtyram_addr_o        (dc_dirtyram_addr_o     ),
  .dc_dirtyram_rdata_i       (dc_dirtyram_rdata_i    ),

  .dc_dirtyram_passed_num1_o (dc_dirtyram_passed_num1),
  .dc_dirtyram_passed_num2_o (dc_dirtyram_passed_num2),
  .dc_dirtyram_passed_num3_o (dc_dirtyram_passed_num3),
  .dc_dirtyram_done_num1_o   (dc_dirtyram_done_num1  ),
  .dc_dirtyram_done_num2_o   (dc_dirtyram_done_num2  ),
  .dc_dirtyram_done_num3_o   (dc_dirtyram_done_num3  ),
  .clk                       (clk                    ),
  .reset_n                   (reset_n_cpu            ),
  .max_dirtyram_range        (max_dirtyram_range     ),
  .test_start_i              (state == START_DIRTYRAM)
 );

 ca53tlbram_tb #(.CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION)) u_ca53tlbram_tb (
  .tlb_ram_en_o             (tlb_ram_en_o      ),
  .tlb_ram_wr_o             (tlb_ram_wr_o      ),
  .tlb_ram_addr_o           (tlb_ram_addr_o    ),
  .tlb_ram_wdata_o          (tlb_ram_wdata_o   ),
  .tlb_ram_rdata0_i         (tlb_ram_rdata0_i  ),
  .tlb_ram_rdata1_i         (tlb_ram_rdata1_i  ),
  .tlb_ram_rdata2_i         (tlb_ram_rdata2_i  ),
  .tlb_ram_rdata3_i         (tlb_ram_rdata3_i  ),

  .tlbram_passed_num1_o     (tlbram_passed_num1),
  .tlbram_passed_num2_o     (tlbram_passed_num2),
  .tlbram_done_num1_o       (tlbram_done_num1  ),
  .tlbram_done_num2_o       (tlbram_done_num2  ),
  .clk                      (clk               ),
  .reset_n                  (reset_n_cpu       ),
  .max_tlbram_range         (max_tlbram_range  ),
  .test_start_i             (state == START_TLBRAM)

 );

 ca53_btacram_stg0_tb u_ca53_btacram_stg0_tb (
  .btac_stg0_ram_rdata_i  (btac_stg0_ram_rdata_i   ),
  .btac_stg0_ram_en_o     (btac_stg0_ram_en_o      ),
  .btac_stg0_ram_wr_o     (btac_stg0_ram_wr_o      ),
  .btac_stg0_ram_wdata_o  (btac_stg0_ram_wdata_o   ),
  .btac_stg0_ram_addr_o   (btac_stg0_ram_addr_o    ),

  .btacram_passed_num1_o  (btacram_stg0_passed_num1),
  .btacram_passed_num2_o  (btacram_stg0_passed_num2),
  .btacram_done_num1_o    (btacram_stg0_done_num1  ),
  .btacram_done_num2_o    (btacram_stg0_done_num2  ),
  .clk                    (clk                     ),
  .reset_n                (reset_n_cpu             ),
  .max_btacram_range      (max_btacram_range       ),
  .test_start_i           (state == START_BTACRAM_STG0)

 );

  ca53_btacram_stg1_tb u_ca53_btacram_stg1_tb (
  .btac_stg1_ram_rdata_i  (btac_stg1_ram_rdata_i   ),
  .btac_stg1_ram_en_o     (btac_stg1_ram_en_o      ),
  .btac_stg1_ram_wr_o     (btac_stg1_ram_wr_o      ),
  .btac_stg1_ram_wdata_o  (btac_stg1_ram_wdata_o   ),
  .btac_stg1_ram_addr_o   (btac_stg1_ram_addr_o    ),

  .btacram_passed_num1_o  (btacram_stg1_passed_num1),
  .btacram_passed_num2_o  (btacram_stg1_passed_num2),
  .btacram_done_num1_o    (btacram_stg1_done_num1  ),
  .btacram_done_num2_o    (btacram_stg1_done_num2  ),
  .clk                    (clk                     ),
  .reset_n                (reset_n_cpu             ),
  .max_btacram_range      (max_btacram_range       ),
  .test_start_i           (state == START_BTACRAM_STG1)

 );


   // ---------------------------------
   // State Machine for Print messages
   // ---------------------------------

   assign debug = 0;

   assign all_tests_completed = dc_dataram_done_num1   & dc_dataram_done_num2   & dc_dataram_done_num3  &
                                dc_tagram_done_num1    & dc_tagram_done_num2    &
                                ic_dataram_done_num1   & ic_dataram_done_num2   & ic_dataram_done_num3  &
                                ic_tagram_done_num1    & ic_tagram_done_num2    &
                                dc_dirtyram_done_num1  & dc_dirtyram_done_num2  & dc_dirtyram_done_num3 &
                                tlbram_done_num1       & tlbram_done_num2       &
                                btacram_stg0_done_num1 & btacram_stg0_done_num2 &
                                btacram_stg1_done_num1 & btacram_stg1_done_num2;

   assign all_tests_passed    = dc_dataram_passed_num1   & dc_dataram_passed_num2   & dc_dataram_passed_num3  &
                                dc_tagram_passed_num1    & dc_tagram_passed_num2    &
                                ic_dataram_passed_num1   & ic_dataram_passed_num2   & ic_dataram_passed_num3  &
                                ic_tagram_passed_num1    & ic_tagram_passed_num2    &
                                dc_dirtyram_passed_num1  & dc_dirtyram_passed_num2  & dc_dirtyram_passed_num3 &
                                tlbram_passed_num1       & tlbram_passed_num2       &
                                btacram_stg0_passed_num1 & btacram_stg0_passed_num2 &
                                btacram_stg1_passed_num1 & btacram_stg1_passed_num2;

   always @*
    case (print_state)
      PRINT_IDLE         : print_next_state = reset_n_cpu ? PRINT_HEADER : PRINT_IDLE;
      PRINT_HEADER       : print_next_state = WAIT_FOR_DONE;
      WAIT_FOR_DONE      : print_next_state = all_tests_completed ? PRINT_D_DATARAM : WAIT_FOR_DONE;
      PRINT_D_DATARAM    : print_next_state = PRINT_D_TAGRAM;
      PRINT_D_TAGRAM     : print_next_state = PRINT_I_DATARAM;
      PRINT_I_DATARAM    : print_next_state = PRINT_I_TAGRAM;
      PRINT_I_TAGRAM     : print_next_state = PRINT_TLBRAM;
      PRINT_TLBRAM       : print_next_state = PRINT_DIRTYRAM;
      PRINT_DIRTYRAM     : print_next_state = PRINT_BTACRAM_STG0;
      PRINT_BTACRAM_STG0 : print_next_state = PRINT_BTACRAM_STG1;
      PRINT_BTACRAM_STG1 : print_next_state = PRINT_FINISH;
      PRINT_FINISH       : print_next_state = PRINT_FINISH;
      default            : print_next_state = PRINT_IDLE;
    endcase

    //Registering the print next stage
   always @(posedge clk or negedge reset_n_cpu)
    if (!reset_n_cpu) begin
      print_state <= PRINT_IDLE;
    end else begin
      print_state <= print_next_state;
    end

   //Needs Printing in individual States
    always @(print_state) begin
      if (print_state == PRINT_HEADER) begin
        $display ("\n");
        $display ("------- Starting CPU %d RAM Test -------", cpu_id_i);
        $display ("----------------------------------------");
        $display (" - Size of D-Cache %s ", dc_size_str);
        $display (" - Size of I-Cache %s ", ic_size_str);
        $display ("\n");
      end else if (print_state == PRINT_D_DATARAM) begin

          if (debug == 1) begin
            case (dc_dataram_passed_num1)
              1'b0 : $display ("Test1 of D-Cache Data = FAILED");
              1'b1 : $display ("Test1 of D-Cache Data = PASSED");
            endcase
            case (dc_dataram_passed_num2)
              1'b0 : $display ("Test2 of D-Cache Data = FAILED");
              1'b1 : $display ("Test2 of D-Cache Data = PASSED");
            endcase
            case (dc_dataram_passed_num3)
              1'b0 : $display ("Test3 of D-Cache Data = FAILED");
              1'b1 : $display ("Test3 of D-Cache Data = PASSED");
            endcase
          end

          case (dc_dataram_passed_num1 & dc_dataram_passed_num2 & dc_dataram_passed_num3)
            1'b0 :  $display ("Status of D-Cache Data  = FAILED ");
            1'b1 :  $display ("Status of D-Cache Data  = PASSED ");
          endcase

      end else if (print_state == PRINT_D_TAGRAM) begin

          if (debug == 1) begin
            case (dc_tagram_passed_num1)
              1'b0 : $display ("Test1 of D-Cache Tag = FAILED");
              1'b1 : $display ("Test1 of D-Cache Tag = PASSED");
            endcase
            case (dc_tagram_passed_num2)
              1'b0 : $display ("Test2 of D-Cache Tag = FAILED");
              1'b1 : $display ("Test2 of D-Cache Tag = PASSED");
            endcase
          end

          case (dc_tagram_passed_num1 & dc_tagram_passed_num2)
            1'b0 :  $display ("Status of D-Cache Tag   = FAILED ");
            1'b1 :  $display ("Status of D-Cache Tag   = PASSED ");
          endcase

      end else if (print_state == PRINT_I_DATARAM) begin

          if (debug == 1) begin
            case (ic_dataram_passed_num1)
              1'b0 : $display ("Test1 of I-Cache Data = FAILED");
              1'b1 : $display ("Test1 of I-Cache Data = PASSED");
            endcase
            case (ic_dataram_passed_num2)
              1'b0 : $display ("Test2 of I-Cache Data = FAILED");
              1'b1 : $display ("Test2 of I-Cache Data = PASSED");
            endcase
            case (ic_dataram_passed_num3)
              1'b0 : $display ("Test3 of I-Cache Data = FAILED");
              1'b1 : $display ("Test3 of I-Cache Data = PASSED");
            endcase
         end

         case (ic_dataram_passed_num1 & ic_dataram_passed_num2 & ic_dataram_passed_num3)
            1'b0 :  $display ("Status of I-Cache Data  = FAILED ");
            1'b1 :  $display ("Status of I-Cache Data  = PASSED ");
         endcase


      end else if (print_state == PRINT_I_TAGRAM) begin

          if (debug == 1) begin
            case (ic_tagram_passed_num1)
              1'b0 : $display ("Test1 of I-Cache Tag = FAILED");
              1'b1 : $display ("Test1 of I-Cache Tag = PASSED");
            endcase
            case (ic_tagram_passed_num2)
              1'b0 : $display ("Test2 of I-Cache Tag = FAILED");
              1'b1 : $display ("Test2 of I-Cache Tag = PASSED");
            endcase
          end

          case (ic_tagram_passed_num1 & ic_tagram_passed_num2)
            1'b0 :  $display ("Status of I-Cache Tag   = FAILED ");
            1'b1 :  $display ("Status of I-Cache Tag   = PASSED ");
          endcase


      end else if (print_state == PRINT_TLBRAM) begin

          if (debug == 1) begin
            case (tlbram_passed_num1)
              1'b0 : $display ("Test1 of TLB = FAILED");
              1'b1 : $display ("Test1 of TLB = PASSED");
            endcase
            case (tlbram_passed_num2)
              1'b0 : $display ("Test2 of TLB = FAILED");
              1'b1 : $display ("Test2 of TLB = PASSED");
            endcase
          end

          case (tlbram_passed_num1 & tlbram_passed_num2)
            1'b0 :  $display ("Status of TLB           = FAILED ");
            1'b1 :  $display ("Status of TLB           = PASSED ");
          endcase


      end else if (print_state == PRINT_DIRTYRAM) begin

          if (debug == 1) begin
            case (dc_dirtyram_passed_num1)
              1'b0 : $display ("Test1 of D-Cache Dirty = FAILED");
              1'b1 : $display ("Test1 of D-Cache Dirty = PASSED");
            endcase
            case (dc_dirtyram_passed_num2)
              1'b0 : $display ("Test2 of D-Cache Dirty = FAILED");
              1'b1 : $display ("Test2 of D-Cache Dirty = PASSED");
            endcase
            case (dc_dirtyram_passed_num3)
              1'b0 : $display ("Test3 of D-Cache Dirty = FAILED");
              1'b1 : $display ("Test3 of D-Cache Dirty = PASSED");
            endcase
          end

         case (dc_dirtyram_passed_num1 & dc_dirtyram_passed_num2 & dc_dirtyram_passed_num3)
            1'b0 :  $display ("Status of D-Cache Dirty = FAILED ");
            1'b1 :  $display ("Status of D-Cache Dirty = PASSED ");
         endcase

      end else if (print_state == PRINT_BTACRAM_STG0) begin

          if (debug == 1) begin
            case (btacram_stg0_passed_num1)
              1'b0 : $display ("Test1 of BTAC STG0 Ram = FAILED");
              1'b1 : $display ("Test1 of BTAC STG0 Ram = PASSED");
            endcase
            case (btacram_stg0_passed_num2)
              1'b0 : $display ("Test2 of BTAC STG0 Ram = FAILED");
              1'b1 : $display ("Test2 of BTAC STG0 Ram = PASSED");
            endcase
          end

         case (btacram_stg0_passed_num1 & btacram_stg0_passed_num2)
            1'b0 :  $display ("Status of BTAC STG0 Ram = FAILED ");
            1'b1 :  $display ("Status of BTAC STG0 Ram = PASSED ");
         endcase

      end else if (print_state == PRINT_BTACRAM_STG1) begin

          if (debug == 1) begin
            case (btacram_stg1_passed_num1)
              1'b0 : $display ("Test1 of BTAC STG1 Ram = FAILED");
              1'b1 : $display ("Test1 of BTAC STG1 Ram = PASSED");
            endcase
            case (btacram_stg1_passed_num2)
              1'b0 : $display ("Test2 of BTAC STG1 Ram = FAILED");
              1'b1 : $display ("Test2 of BTAC STG1 Ram = PASSED");
            endcase
          end

         case (btacram_stg1_passed_num1 & btacram_stg1_passed_num2)
            1'b0 :  $display ("Status of BTAC STG1 Ram = FAILED ");
            1'b1 :  $display ("Status of BTAC STG1 Ram = PASSED ");
         endcase

      end else if (print_state == PRINT_FINISH) begin
          $display ("\n");
          case (all_tests_passed)
            1'b1 : $display ("NO ERRORS found in CPU %d RAM Test !!!", cpu_id_i);
            1'b0 : begin
                    $display ("===================================");
                    $display ("ERRORS FOUND IN CPU %d RAM Test !!!", cpu_id_i);
                    $display ("===================================");
                    $finish;
                   end
          endcase
      end
   end

endmodule // ca53_noram

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
