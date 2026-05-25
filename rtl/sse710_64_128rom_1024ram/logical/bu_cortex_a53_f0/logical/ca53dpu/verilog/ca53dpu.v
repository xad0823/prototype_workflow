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
//      Checked In          : $Date: 2015-02-14 09:39:17 +0000 (Sat, 14 Feb 2015) $
//
//      Revision            : $Revision: 301905 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU (Data Processing Unit) Top Level
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The top-level for the Data Processing Unit (integer core).

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire          clk,
  input  wire          reset_n,
  input  wire          po_reset_n,                                 // Power on reset signal (active low)
  input  wire          DFTSE,
  input  wire   [1:0]  biu_evnt_ext_mem_req_i,                     // External memory request event
  input  wire   [1:0]  biu_evnt_ext_mem_req_nc_i,                  // Non-cacheable external memory request event
  input  wire          biu_evnt_pf_lf_i,                           // Linefill due to prefetch event
  input  wire          biu_evnt_rw_lf_i,                           // Linefill due to read/write event
  input  wire          biu_evnt_ramode_i,                          // Entering read allocate mode event
  input  wire          biu_evnt_ramode_enter_i,                    // Entering read allocate mode event
  input  wire          gov_cfgend_i,                               // Comes up in big endian (BE-8) state
  input  wire          gov_cp15sdisable_i,                         // CP15 Security Disable
  input  wire          gov_dbgen_i,                                // Debug Enable
  input  wire          gov_dbgrestart_i,                           // External restart request
  input  wire          gov_dbgromaddrv_i,                          // Debug ROM valid
  input  wire  [39:12] gov_dbgromaddr_i,                           // Debug ROM physical address
  input  wire          gov_edecr_osuce_i,                          // Debug OS Unlock Catch Enable    EDECR[0]
  input  wire          gov_edecr_rce_i,                            // Reset catch debug event enable  EDECR[1]
  input  wire          gov_edecr_ss_i,                             // Halting step debug event enable EDECR[2]
  input  wire          gov_edlsr_slk_i,                            // Debug Software Lock Status EDLSR[1]
  input  wire          gov_pmlsr_slk_i,                            // PMU Software Lock Status PMLSR[1]
  input  wire          gov_dbgpwrupreq_i,                          // Debug Core Power-up Request DBGPRCR[3]
  input  wire   [2:0]  dc_size_i,                                  // D-cache size
  input  wire          biu_w_imp_abort_i,                          // Imprecise abort from AXI master
  input  wire   [1:0]  biu_w_imp_fault_i,                          // Fault information for imprecise abort (SLVERR, DECERR or ECCERR)
  input  wire          etm_if_en_i,                                // Enable DPU/ETM Interface
  input  wire          etm_stall_cpu_i,                            // ETM request to stall pipeline
  input  wire          ifu_dbg_ready_i,                            // Instruction cache ready for debug events
  input  wire          gov_edbgrq_i,                               // External Debug Request
  input  wire   [2:0]  ic_size_i,                                  // I-cache size
  input  wire   [3:0]  l2_size_i,                                  // L2 cache size
  input  wire          ifu_evnt_ic_lf_i,                           // Instruction cache line fill event
  input  wire          ifu_evnt_ic_access_i,                       // Instruction cache access event
  input  wire          ifu_evnt_ic_miss_wait_i,                    // Instruciion cache miss & wait event
  input  wire          ifu_evnt_iutlb_miss_wait_i,                 // Instruction micro-TLB miss & wait event
  input  wire          ifu_evnt_pdc_valid_i,                       // Instruction predecode error event
  input  wire          ifu_evnt_throttle_i,                        // Instruction cache throttle request
  input  wire          dcu_ecc_err_dc3_i,                          // ECC error in load data
  input  wire   [6:0]  dcu_p_fault_dc3_i,                          // Reason for abort
  input  wire   [1:0]  dcu_p_fault_stage_dc3_i,                    // Stage of translation which caused the fault
  input  wire  [63:0]  dcu_ld_data_dc3_i,                          // Load data from the DCU
  input  wire  [63:0]  dcu_va_dc3_i,                               // Virtual address for transaction in dc3-stage
  input  wire  [39:12] dcu_pa_dc3_i,                               // IPA address for second stage faults in dc3-stage
  input  wire          dcu_p_abort_dc3_i,                          // Transaction is aborted (precisely)
  input  wire   [3:0]  dcu_p_domain_dc3_i,                         // Domain of abort
  input  wire          dcu_p_direction_dc3_i,                      // Direction (store/load) of abort transaction
  input  wire          dcu_cm_operation_dc3_i,                     // Cache Maintenance Operation
  input  wire          dcu_valid_dc3_i,                            // DCU can provide load data and retire
  input  wire          dcu_ready_iss_i,                            // DCU can accept an LS transaction
  input  wire          dcu_ready_cp_iss_i,                         // DCU can accept a non-MVA CP transaction
  input  wire          dcu_strex_okay_dc3_i,                       // STREX returned EXOKAY response
  input  wire          dcu_v2p_lpae_dc3_i,                         // LPAE format signal for V2P operations
  input  wire          dcu_wpt_hit_dc3_i,                          // Transaction hit a watchpoint
  input  wire          dcu_evnt_dc_access_i,                       // Data cache access event
  input  wire          dcu_dbg_dsb_ack_i,                          // DSB completed
  input  wire          dcu_ecc_fatal_i,                            // ECC fatal error
  input  wire          dcu_ecc_valid_i,                            // ECC valid
  input  wire   [1:0]  dcu_ecc_ramid_i,                            // ECC RAM ID
  input  wire   [2:0]  dcu_ecc_way_bank_id_i,                      // ECC way or bank ID
  input  wire  [10:0]  dcu_ecc_index_i,                            // ECC index
  input  wire          gic_fiq_i,                                  // FIQ
  input  wire          gic_vfiq_i,                                 // VFIQ
  input  wire          gic_irq_i,                                  // IRQ
  input  wire          gic_virq_i,                                 // VIRQ
  input  wire          gov_sei_level_req_i,                        // System error interrupt from nSEI pin
  input  wire          gov_vsei_level_req_i,                       // Virtual system error interrupt from nVSEI pin
  input  wire          gov_rei_level_req_i,                        // Ram error interrupt from nREI pin
  input  wire          gov_int_active_i,                           // There is an active interrupt from the governor or GIC
  input  wire          gic_icc_sre_el1_ns_sre_i,                   // ICC_SRE_EL1.SRE bit (non-secure copy)
  input  wire          gic_icc_sre_el1_s_sre_i,                    // ICC_SRE_EL1.SRE bit (secure copy)
  input  wire          gic_icc_sre_el2_enable_i,                   // ICC_SRE_EL2.ENABLE bit
  input  wire          gic_icc_sre_el2_sre_i,                      // ICC_SRE_EL2.SRE bit
  input  wire          gic_icc_sre_el3_enable_i,                   // ICC_SRE_EL3.ENABLE bit
  input  wire          gic_icc_sre_el3_sre_i,                      // ICC_SRE_EL3.SRE bit
  input  wire          gic_ich_hcr_el2_tall0_i,                    // ICH_HCR_EL2.TALL0 bit
  input  wire          gic_ich_hcr_el2_tall1_i,                    // ICH_HCR_EL2.TALL1 bit
  input  wire          gic_ich_hcr_el2_tc_i,                       // ICH_HCR_EL2.TC bit
  input  wire  [31:1]  ifu_ifar_i,                                 // Instruction Fault Address
  input  wire   [6:0]  ifu_ifsr_i,                                 // Instruction Fault Status
  input  wire   [1:0]  ifu_ifsr_stage2_i,                          // Instruction Fault is from stage2
  input  wire  [47:0]  ifu_instr0_if3_i,                           // PD format instruction
  input  wire  [47:0]  ifu_instr1_if3_i,                           // PD format instruction
  input  wire   [1:0]  ifu_instr_valid_if3_i,                      // Instruction from IFU valid
  input  wire          ifu_early_two_valid_if3_i,                  // Early two instructions from IFU valid
  input  wire  [48:0]  ifu_pred_addr_if4_i,                        // Predicted indirect branch address
  input  wire          ifu_pred_addr_valid_if4_i,                  // Predicted address valid
  input  wire          ifu_ifsr_lpae_i,                            // IFU LPAE Format fault
  input  wire  [27:0]  ifu_hpfar_i,                                // IPA address for second stage faults trapped in Hyp
  input  wire          ifu_pty_valid_i,                            // IFU parity error valid
  input  wire          ifu_pty_ramid_i,                            // IFU parity error RAM ID
  input  wire          ifu_pty_way_bank_id_i,                      // IFU parity error way or bank ID
  input  wire  [11:0]  ifu_pty_index_i,                            // IFU parity error index
  input  wire          gov_niden_i,                                // Non-invasive Debug Enable
  input  wire          gov_spiden_i,                               // Secure invasive debug permitted
  input  wire          gov_spniden_i,                              // Secure non-invasive debug permitted
  input  wire          stb_evnt_stb_stall_i,                       // Store stalled due to a full store buffer
  input  wire  [39:2]  gov_rvbaraddr_i,                            // Reset vector base address
  input  wire          gov_aa64naa32_i,                            // Cold reset should come up in AArch64
  input  wire          gov_cryptodisable_i,                        // Disable crypto logic
  input  wire          gov_giccdisable_i,                          // Disable GIC CPU interface
  input  wire          gov_cfgte_i,                                // Default exception handling state (0 = ARM)
  input  wire          tlb_d_utlb_enable_i,                        // Enable from the main TLB to the uTLB
  input  wire          tlb_d_utlb_might_enable_i,                  // Speculative enable from the main TLB to the uTLB
  input  wire          tlb_d_utlb_valid_i,                         // Valid bit to write to the uTLB entry
  input  wire          tlb_d_utlb_lpae_i,                          // The format of the entry being written is LPAE.
  input  wire  [95:0]  tlb_d_utlb_data_i,                          // Page from the main TLB to the uTLB
  input  wire          tlb_d_utlb_flush_i,                         // Flush all uTLB entries
  input  wire   [1:0]  tlb_d_tcr_el1_tbi_i,                        // TCR_EL1.{TBI1,TBI0}
  input  wire          tlb_d_tcr_el2_tbi0_i,                       // TCR_EL2.TBI0
  input  wire          tlb_d_tcr_el3_tbi0_i,                       // TCR_EL3.TBI0
  input  wire          tlb_lpae_mode_i,                            // LPAE format of uTLB entries (current TTBCR.EAE)
  input  wire          tlb_lpae_mode_s_i,                          // LPAE format of secure state
  input  wire          tlb_evnt_data_pagewalk_i,                   // TLB DSide pagewalk event signal
  input  wire          tlb_evnt_instr_pagewalk_i,                  // TLB ISide pagewalk event signal
  input  wire          tlb_pty_valid_i,                            // TLB parity error valid
  input  wire   [1:0]  tlb_pty_way_bank_id_i,                      // TLB parity error way or bank ID
  input  wire   [7:0]  tlb_pty_index_i,                            // TLB parity error index
  input  wire          gov_vinithi_i,                              // Comes up in High-Vecs mode
  input  wire          gov_pseldbg_dbg_i,                          // PSELDBG (debug logic)
  input  wire          gov_pseldbg_pmu_i,                          // PSELDBG (PMU)
  input  wire          gov_pwritedbg_i,                            // PWRITEDBG
  input  wire  [11:2]  gov_paddrdbg_i,                             // PADDRDBG
  input  wire          gov_paddrdbg31_i,                           // PADDRDBG31 (external debugger when 1)
  input  wire  [31:0]  gov_pwdatadbg_i,                            // PWDATADBG
  input  wire  [31:0]  tlb_dbg_rdata_i,                            // Debug read data from TLB
  input  wire   [7:0]  gov_clusteridaff2_i,                        // Affinity 2 cluster ID for MPIDR
  input  wire   [7:0]  gov_clusteridaff1_i,                        // Affinity 1 cluster ID for MPIDR
  input  wire   [1:0]  cpu_id_i,                                   // CPU ID for MPIDR
  input  wire   [3:0]  ctr_cwg_i,                                  // Override value for CTR.CWG
  input  wire   [3:0]  ctr_erg_i,                                  // Override value for CTR.ERG
  input  wire          gov_event_reg_i,                            // WFE event signal
  input  wire          gov_wfx_wake_i,                             // WFx wakeup signal
  input  wire          gov_stall_neon_i,                           // NEON stall while in retention
  input  wire          scu_evnt_l2_access_i,                       // SCU L2 Access PMU event
  input  wire          scu_evnt_l2_refill_i,                       // SCU L2 Access PMU event
  input  wire          scu_evnt_l2_wb_i,                           // SCU L2 Refill PMU event
  input  wire          scu_evnt_snooped_data_i,                    // SCU Data snooped from other CPU PMU event
  input  wire          scu_evnt_bus_cycle_i,                       // SCU Bus Cycle PMU event
  input  wire          scu_evnt_bus_acc_rd_i,                      // SCU Bus Access (Read) PMU event
  input  wire          scu_evnt_bus_acc_wr_i,                      // SCU Bus Access (Write) PMU event
  input  wire          scu_evnt_eviction_i,                        // Data cache eviction event
  input  wire  [39:18] gov_periphbase_i,                           // Peripheral base address
  input  wire          gov_pcnt_kernel_access_i,                   // Kernel access is permitted to the physical counter
  input  wire          gov_pcnt_usr_access_i,                      // User access is permitted to the physical counter
  input  wire          gov_vcnt_usr_access_i,                      // User access is permitted to the virtual counter
  input  wire          gov_cntp_usr_access_i,                      // User access is permitted to the CNTP registers
  input  wire          gov_cntv_usr_access_i,                      // User access is permitted to the CNTV registers
  input  wire          gov_cntp_kernel_access_i,                   // Kernel access is permitted to the CNTP registers
  // Outputs
  output wire          dpu_commrx_o,                               // rDTR Empty
  output wire          dpu_commtx_o,                               // wDTR Full
  output wire          dpu_ncommirq_o,                             // DTR channel interrupt
  output wire          dpu_non_temporal_iss_o,                     // Load/Store non-temporal instruction
  output wire          dpu_ldar_stlr_iss_o,                        // Load Acquire/Store Release instruction
  output wire  [12:0]  dpu_attributes_dc1_o,                       // Micro TLB attributes
  output wire   [8:0]  dpu_fault_dc1_o,                            // Micro TLB fault information
  output wire          dpu_l1deien_o,                              // Control bit
  output wire          dpu_disable_dmb_o,                          // Control bit
  output wire          dpu_disable_device_split_throttle_o,        // Control bit
  output wire   [2:0]  dpu_enable_data_prefetch_o,                 // Control bits
  output wire   [1:0]  dpu_enable_data_prefetch_streams_o,         // Control bits
  output wire          dpu_data_prefetch_stride_detect_o,          // Control bit
  output wire          dpu_disable_data_prefetch_stores_pattern_o, // Control bit
  output wire          dpu_disable_data_prefetch_readunique_o,     // Control bit
  output wire          dpu_disable_no_allocate_o,                  // Control bit
  output wire   [1:0]  dpu_ramode_cnt_l1_o,                        // Control bit
  output wire   [1:0]  dpu_ramode_cnt_l2_o,                        // Control bit
  output wire          dpu_smp_en_o,                               // Control bit
  output wire  [21:0]  dpu_periphbase_o,                           // Periphbase for GIC memory mapped accesses
  output wire          dpu_apb_active_o,                           // APB transaction
  output wire          dpu_dbg_dsb_req_o,                          // Request a data synchronization barrier from caches
  output wire          dpu_clear_excl_mon_o,                       // Clear exclusive monitor because of exception return
  output wire          dpu_dbg_tlb_sw_bkpt_wpt_en_o,               // Software Breakpoint and watchpoint enabled
  output wire          dpu_dbg_tlb_hw_bkpt_wpt_en_o,               // Hardware Breakpoint and watchpoint enabled
  output wire          dpu_dbg_sample_contextid_o,                 // Instructs TLB to sample Context ID for debug
  output wire          dpu_dbgack_o,                               // Debug Acknowledge
  output wire          dpu_dbgtrigger_o,                           // Debug request taken
  output wire   [2:0]  dpu_align_size_iss_o,                       // Size of alignment checking required
  output wire          dpu_pred_br_ex2_o,                          // Valid branch in Ex2
  output wire  [12:3]  dpu_br_addr_ex2_o,                          // Ex2 branch address
  output wire          dpu_br_call_wr_o,                           // Instr was function call
  output wire          dpu_br_return_wr_o,                         // Instr was function return
  output wire          dpu_br_taken_wr_o,                          // Branch was taken
  output wire   [8:0]  dpu_cp_op_iss_o,                            // CP operation encoding
  output wire  [63:0]  dpu_cp_data_wr_o,                           // Write data for CP register
  output wire          dpu_burst_iss_o,                            // Access is part of burst and more beats will be sent
  output wire          dpu_cross_64_iss_o,                         // Access crosses an aligned 64-bit boundary
  output wire          dpu_dcache_on_o,                            // D cache enabled
  output wire          dpu_s2_dcache_on_o,                         // D cache enabled for Stage 2 translations
  output wire          dpu_wpt_valid_o,                            // Waypoint valid for ETM
  output wire  [63:1]  dpu_wpt_addr_o,                             // Waypoint source address
  output wire  [63:1]  dpu_wpt_target_addr_opa_o,                  // Waypoint target address
  output wire  [27:1]  dpu_wpt_target_addr_opb_o,                  // Waypoint target address
  output wire          dpu_wpt_advance_o,
  output wire          dpu_wpt_range_o,
  output wire   [2:0]  dpu_wpt_type_o,                             // Waypoint type
  output wire          dpu_wpt_link_o,                             // Waypoint is a call instruction
  output wire          dpu_wpt_taken_o,                            // Waypoint was taken
  output wire   [1:0]  dpu_wpt_target_isa_o,                       // Target ISA of waypoint
  output wire          dpu_wpt_t32_nt16_o,                         // Size of waypoint source instruction
  output wire   [3:0]  dpu_wpt_exception_type_o,                   // Waypoint exception type
  output wire          dpu_wpt_non_secure_o,                       // Waypoint from non-secure state
  output wire   [3:0]  dpu_wpt_exlevel_o,                          // Waypoint source exception level
  output wire          dpu_wpt_prohibited_o,
  output wire          dpu_excl_iss_o,                             // Request is exclusive
  output wire          dpu_fe_valid_wr_o,                          // Address is valid in Wr-stage
  output wire  [48:1]  dpu_fe_addr_opa_wr_o,                       // Operand-A of Wr stage force
  output wire  [27:1]  dpu_fe_addr_opb_wr_o,                       // Operand-B of Wr stage force
  output wire   [1:0]  dpu_fe_isa_wr_o,                            // ISA of Wr stage force
  output wire          dpu_sif_only_o,                             // Secure Instruction Fetch only
  output wire          dpu_first_iss_o,                            // First cycle of mcycle/boundary-crossing request
  output wire          dpu_force_first_iss_o,
  output wire          dpu_second_x64_iss_o,                       // Second cycle of x64
  output wire          dpu_neon_access_iss_o,                      // Load/store is for a NEON/FP instruction
  output wire          dpu_flush_o,                                // DPU is flushing all transactions except the one in wr
  output wire          dpu_hivecs_o,                               // Enable HIVECs (exception vectors at 0xFFFF0000)
  output wire          dpu_default_cacheable_o,                    // Default Cacheable
  output wire          dpu_ipa_to_pa_en_o,                         // Second stage of translation enable
  output wire          dpu_pr_tablewalk_o,                         // Protected Table Walk for TLB from CP15 HCR register
  output wire          dpu_kill_wr_o,                              // DPU is killing load store transaction
  output wire          dpu_cc_fail_wr_o,                           // Instruction in Wr has CC failed
  output wire          dpu_ready_cc_fail_wr_o,                     // Instruction in Wr is ready and has CC failed
  output wire          dpu_ready_cc_pass_wr_o,                     // Instruction in Wr is ready and has CC passed
  output wire          dpu_mispred_wr_o,                           // IFU misprediction detected
  output wire  [63:0]  dpu_va_dc1_o,                               // Virtual address
  output wire  [39:12] dpu_pa_dc1_o,                               // Physical address
  output wire          dpu_dbg_valid_o,                            // Valid instruction for the IFU
  output wire  [31:0]  dpu_dbg_ins_o,                              // Instruction for the IFU
  output wire          dpu_halt_ifu_o,                             // IFU should stop fetching single-cycle hot
  output wire          dpu_pld_iss_o,                              // Request is a PLD
  output wire          dpu_pld_level_iss_o,                        // Which level of cache is targeted by a PLD
  output wire          dpu_pred_br_wr_o,                           // Branch was predictable
  output wire          dpu_priv_iss_o,                             // Privilege level of transaction
  output wire          dpu_ready_wr_o,                             // DPU is ready to retire the transaction
  output wire          dpu_req_align_iss_o,                        // DPU requests alignment checking
  output wire          dpu_store_iss_o,                            // Request is a store
  output wire  [15:0]  dpu_strobe_iss_o,                           // Read/Write strobes
  output wire          dpu_utlb_hit_dc1_o,                         // Micro TLB hit signal
  output wire  [3:0]   dpu_utlb_hit_entry_dc1_o, 
  output wire          dpu_valid_iss_o,                            // Request is valid
  output wire          dpu_valid_cp_iss_o,                         // CP operation
  output wire          dpu_tlb_abandon_o,                          // Abandon pagewalk due to change in configuration
  output wire  [3:0]   dpu_dbg_vid_o,                              // Upper bits of the EDVIDSR register for the TLB
  output wire          dpu_mmu_on_o,                               // MMU on signal for TLB from CP15 SCTLR registers
  output wire          dpu_mmu_on_el1_o,                           // MMU on signal for TLB from CP15 SCTLR registers
  output wire          dpu_mmu_on_el2_o,                           // MMU on signal for TLB from CP15 HSCTLR register
  output wire          dpu_mmu_on_el3_o,                           // MMU on signal for TLB from CP15 SCTLR registers
  output wire          dpu_dcache_on_el1_o,                        // DCache on signal for TLB from CP15 SCTLR registers
  output wire          dpu_dcache_on_el2_o,                        // DCache on signal for TLB from CP15 HSCTLR register
  output wire          dpu_dcache_on_el3_o,                        // DCache on signal for TLB from CP15 SCTLR registers
  output wire          dpu_sctlr_wxn_el1_o,                        // Write permission for TLB from CP15 SCTLR register
  output wire          dpu_sctlr_wxn_el2_o,                        // Write permission for TLB from CP15 HSCTLR register
  output wire          dpu_sctlr_wxn_el3_o,                        // Write permission for TLB from CP15 SCTLR register
  output wire          dpu_sctlr_uwxn_el1_o,                       // Write permission for TLB from CP15 SCTLR register
  output wire          dpu_sctlr_uwxn_el3_o,                       // Write permission for TLB from CP15 SCTLR register
  output wire          dpu_sctlr_itd_o,                            //
  output wire          dpu_throttle_enable_o,                      // Enable the throttle predictor
  output wire          dpu_endian_el1_o,                           // Endian signal for TLB from CP15 SCTLR registers
  output wire          dpu_endian_el2_o,                           // Endian signal for TLB from CP15 HSCTLR register
  output wire          dpu_endian_el3_o,                           // Endian signal for TLB from CP15 SCTLR registers
  output wire          dpu_icache_on_o,                            // ICache on signal for TLB from CP15 SCTLR registers
  output wire  [31:5]  dpu_vec_base_s_dc1_o,                       // Secure vector base address
  output wire  [31:5]  dpu_vec_base_ns_dc1_o,                      // Non-secure vector base address
  output wire  [31:5]  dpu_mon_vec_base_dc1_o,                     // Monitor mode vector base address
  output wire          dpu_ns_dsc_dc1_o,                           // Security state from micro-TLB
  output wire          dpu_ns_state_o,                             // Security state of processor
  output wire          dpu_hcr_el2_fmo_o,                          // HCR_EL2.FMO bit
  output wire          dpu_hcr_el2_imo_o,                          // HCR_EL2.IMO bit
  output wire          dpu_hcr_el2_amo_o,                          // HCR_EL2.AMO bit
  output wire          dpu_scr_el3_fiq_o,                          // SCR_EL3.FIQ bit
  output wire          dpu_scr_el3_irq_o,                          // SCR_EL3.IRQ bit
  output wire          dpu_scr_el3_ns_o,                           // SCR_EL3.NS bit
  output wire          dpu_tex_remap_enable_el1_o,                 // For TLB
  output wire          dpu_tex_remap_enable_el3_o,                 // For TLB
  output wire          dpu_access_flag_enable_el1_o,               // For TLB
  output wire          dpu_access_flag_enable_el3_o,               // For TLB
  output wire          dpu_npmuirq_o,                              // System metrics IRQ output
  output wire          dpu_iq_full_o,                              // IQ is full/one space
  output wire          dpu_iq_part_full_o,                         // IQ is half-full
  output wire   [1:0]  dpu_size_iss_o,                             // Size of each access
  output wire [127:0]  dpu_st_data_wr_o,                           // Store data out to memory system
  output wire          dpu_fe_valid_ret_o,                         // Fetch address in Ret-stage is valid
  output wire  [63:0]  dpu_fe_addr_opa_ret_o,                      // Operand-A of Ret stage force
  output wire  [17:1]  dpu_fe_addr_opb_ret_o,                      // Operand-B of Ret stage force
  output wire   [1:0]  dpu_fe_isa_ret_o,                           // ISA of Ret stage force
  output wire   [7:0]  dpu_fe_itstate_ret_o,                       // ITSTATE of Ret stage force
  output wire          dpu_fe_context_sync_ret_o,                  // Ret-stage force is due to a context synchronisation operation
  output wire          dpu_btac_ret_o,                             // BTAC'able instruction in Ret
  output wire   [4:0]  dpu_mode_iss_o,                             // (Speculative) Mode of iss-stage
  output wire   [1:0]  dpu_exception_level_o,                      // Current exception level
  output wire          dpu_dscr_halted_o,                          // DPU in halting debug mode
  output wire   [3:1]  dpu_aarch64_at_el_o,                        // Current Architecture of {el3,el2,el1}
  output wire          dpu_aarch64_state_o,                        // Currently in AArch64
  output wire          dpu_monitor_mode_o,                         // Currently executing in Monitor mode
  output wire  [25:0]  dpu_pmuevent_o,                             // Performance monitor unit outputs
  output wire   [4:0]  dpu_length_iss_o,                           // Number of registers that need to be accessed
  output wire          dpu_flush_i_utlb_o,                         // Flush the micro-TLB in the IFU
  output wire  [31:0]  dpu_prdatadbg_o,                            // PRDATADBG
  output wire          dpu_preadydbg_o,                            // PREADYDBG
  output wire          dpu_pslverrdbg_o,                           // PSLVERRDBG
  output wire          dpu_dbg_wr_o,                               // Debug write enable to TLB
  output wire  [11:2]  dpu_dbg_addr_o,                             // Debug address to TLB
  output wire  [31:0]  dpu_dbg_wdata_o,                            // Debug write data to TLB
  output wire          dpu_dbgnopwrdwn_o,                          // DBGnoPWRDWN output to power controller
  output wire          dpu_dbgrstreq_o,                            // Debug request core reset
  output wire          dpu_warmrstreq_o,                           // RMR request core reset
  output wire          dpu_sev_req_o,                              // Send Event
  output wire          dpu_clr_event_register_o,                   // Clear the event register for this CPU
  output wire          dpu_wfi_req_o,                              // WFI request
  output wire          dpu_wfe_req_o,                              // WFE request
  output wire          dpu_irq_pended_o,
  output wire          dpu_fiq_pended_o,
  output wire          dpu_sei_pended_o,
  output wire          dpu_irq_masked_o,
  output wire          dpu_fiq_masked_o,
  output wire          dpu_sei_masked_o,
  output wire          dpu_virq_pended_o,
  output wire          dpu_vfiq_pended_o,
  output wire          dpu_vsei_pended_o,
  output wire          dpu_virq_masked_o,
  output wire          dpu_vfiq_masked_o,
  output wire          dpu_vsei_masked_o,
  output wire          dpu_imp_abort_pending_o,
  output wire   [2:0]  dpu_cpuectlr_cpu_ret_delay_o,               // CPU retention delay control
  output wire   [2:0]  dpu_cpuectlr_neon_ret_delay_o,              // NEON retention delay control
  output wire          dpu_neon_active_o,                          // NEON is active
  output wire          dpu_rei_level_ack_o,                        // DPU has taken an REI from the system
  output wire          dpu_sei_level_ack_o,                        // DPU has taken an SEI from the system
  output wire          dpu_vsei_level_ack_o,                       // DPU has taken an SEI from the system
  output wire          dpu_dbg_double_lock_set_o,
  output wire  [31:0]  dpu_dacr_o,                                 // CP15 DACR register
  output wire          dpu_stack_align_expt_dc1_o,                 // Stack alignment exception
  output wire   [3:0]  dpu_domain_dc1_o,                           // Micro TLB domain
  output wire          dpu_abort_dc1_o,                            // Micro TLB abort
  output wire   [3:0]  dpu_level_dc1_o,                            // Micro TLB level
  output wire          dpu_lpae_dc1_o,                             // Micro TLB lpae mode
  output wire          dpu_reset_catch_pending_o,                  // A reset catch debug event is pending (to IFU)
  output wire          dpu_expt_catch_pending_o,                   // An exception catch debug event is pending (to IFU)
  output wire  [48:6]  dpu_agu_a_operand_iss_o,                    // AGU operands sent to DCU for cache way tracker logic
  output wire  [48:6]  dpu_agu_b_operand_iss_o,
  output wire          dpu_agu_carry_out_64b_iss_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                 slot1_ls_de;
  wire                                 ctl_64bit_op_alu1_iss;
  wire                                 ctl_64bit_op_alu0_iss;
  wire                                 ctl_64bit_op_mac_iss;
  wire                                 agu_sub_b_de;
  wire                                 sctlr_align_check;
  wire                                 sctlr_ntwe;
  wire                                 sctlr_ntwi;
  wire                                 sctlr_cp15ben;
  wire                                 sctlr_sed;
  wire                                 sctlr_el1_uci;
  wire                                 sctlr_el1_uct;
  wire                                 sctlr_el1_uma;
  wire                                 sctlr_el1_dze;
  wire                           [3:0] sctlr_sa_at_el;
  wire                                 alu0_qbit_wr;
  wire                                 alu1_qbit_wr;
  wire                                 use_ex1_alu_0_de;
  wire                                 use_ex1_alu_1_de;
  wire                                 use_ex1_alu_0_iss;
  wire                                 use_ex1_alu_1_iss;
  wire                                 alu0_valid_de;
  wire                                 alu1_valid_de;
  wire                                 raw_alu0_valid_iss;
  wire                                 raw_alu1_valid_iss;
  wire                                 alu0_valid_iss;
  wire                                 alu1_valid_iss;
  wire                                 br_call_wr;
  wire                                 br_direct_wr;
  wire                                 br_flush_ret;
  wire                                 br_flush_wr;
  wire                                 br_valid_de;
  wire                                 br_pred_takenness_de;
  wire                                 br_pred_takenness_wr;
  wire                                 mis_predicted_branch_wr;
  wire                                 cc_pass_instr0_cbz_ex2;
  wire                                 cc_pass_instr0_ex2;
  wire                                 cc_pass_instr0_wr;
  wire                                 cc_pass_instr1_cbz_ex2;
  wire                                 cc_pass_instr1_ex2;
  wire                                 cc_pass_instr1_early_ex2;
  wire                                 cc_pass_instr1_wr;
  wire                                 fp0_ccmp_fail_ex2;
  wire                                 fp1_ccmp_fail_ex2;
  wire                                 alu0_csel_pass_ex2;
  wire                                 cp_op_ats1_de;
  wire                                 cp_other_sec_de;
  wire                                 fp_serialise_de;
  wire                                 mac_stall_iss;
  wire                                 div_valid_de;
  wire                                 div_valid_iss;
  wire                                 raw_div_valid_iss;
  wire                                 div_busy_iss;
  wire                                 nxt_div_busy_wr;
  wire                                 evnt_br_valid_wr;
  wire                                 evnt_br_mispred;
  wire                                 evnt_br_direct_wr;
  wire                                 evnt_br_indirect;
  wire                                 evnt_br_indirect_mispred;
  wire                                 evnt_br_indirect_mispred_addr;
  wire                                 cptr_el3_tcpac;
  wire                                 cptr_el3_tfp;
  wire                                 hcr_fb;
  wire                           [1:0] hcr_bsu;
  wire                                 hcr_twi;
  wire                                 hcr_twe;
  wire                                 hcr_tid0;
  wire                                 hcr_tid1;
  wire                                 hcr_tid2;
  wire                                 hcr_tid3;
  wire                                 hcr_tsc;
  wire                                 hcr_tidcp;
  wire                                 hcr_tacr;
  wire                                 hcr_tsw;
  wire                                 hcr_tpc;
  wire                                 hcr_tpu;
  wire                                 hcr_ttlb;
  wire                                 hcr_tvm;
  wire                                 hcr_tdz;
  wire                                 hcr_trvm;
  wire                                 hcr_tge;
  wire                           [1:0] exception_level_debug;
  wire                           [3:0] debug_enabled_from_el;
  wire                                 mdscr_el1_tdcc;
  wire                                 mdscr_el1_ss;
  wire                                 hdcr_tdra;
  wire                                 hdcr_tdosa;
  wire                                 hdcr_tda;
  wire                                 hdcr_tde;
  wire                                 hdcr_tpm;
  wire                                 hdcr_tpmcr;
  wire                                 hdcr_hpme;
  wire                           [4:0] hdcr_hpmn;
  wire                                 mdcr_el3_tdosa;
  wire                                 mdcr_el3_tda;
  wire                                 mdcr_el3_tpm;
  wire                          [13:0] hstr_trap_cp15;
  wire                                 hsctlr_te;
  wire                           [3:1] aarch64_at_el;
  wire                          [39:2] rvbaraddr;
  wire                                 sctlr_endian_el1;
  wire                                 sctlr_endian_el2;
  wire                                 sctlr_endian_el3;
  wire                                 sctlr_el1_e0e;
  wire                                 sctlr_el3_itd;
  wire                                 sctlr_el2_itd;
  wire                                 sctlr_el1_itd;
  wire                                 sctlr_ns_te;
  wire                                 sctlr_s_te;
  wire                                 sctlr_ns_hivecs;
  wire                                 sctlr_s_hivecs;
  wire                                 cpsr_abit_ret;
  wire                                 cpsr_dbit_ret;
  wire                                 cpsr_fbit_ret;
  wire                                 cpsr_flag_update_cp_dscr_wr;
  wire                                 cpsr_ibit_ret;
  wire                                 cpsr_ilbit_ret;
  wire                                 cpsr_ssbit_ret;
  wire                                 cpsr_tbit_ret;
  wire                                 cp_icimvau;
  wire                                 expt_in_halt;
  wire                                 end_expt_in_halt;
  wire                                 dbg_event;
  wire                                 dbg_event_halt_wr;
  wire                                 dbg_ss_vld_expt_type_ret;
  wire                                 dbg_expt;
  wire                                 dpu_default_cacheable;
  wire                                 dpu_mmu_on;
  wire                                 dpu_mmu_on_el1;
  wire                                 dpu_br_call_de;
  wire                                 br_btac_de;
  wire                                 dpu_br_return_de;
  wire                                 dpu_br_return_wr;
  wire                                 dpu_br_taken_wr;
  wire                                 dpu_fe_valid_ret;
  wire                                 dpu_fe_valid_wr;
  wire                                 clear_virtual_ea;
  wire                                 dpu_mispred_wr;
  wire                                 dpu_halt_ifu;
  wire                                 dpu_pred_br_de;
  wire                                 dpu_pred_br_wr;
  wire                                 dpu_valid_branch_instr_wr;
  wire                                 prefetch_flush_wr;
  wire                                 nxt_mon_el3_mode_ret;
  wire                           [1:0] dpu_exception_level;
  wire                           [1:0] target_exception_level;
  wire                                 head_instr_ls_iss;
  wire                                 ls_conditional_iss;
  wire                           [4:0] rf_wr_mode_de;
  wire                                 usr_mode_regs_ldm_de;
  wire                                 no_interrupt_de;
  wire                                 no_interrupt_wr;
  wire                                 enable_base_restore_de;
  wire                                 enable_base_restore_iss;
  wire                                 save_base_ex2;
  wire                                 first_cycle_ls_de;
  wire                                 end_instr_dbg_wr;
  wire                                 end_instr_de;
  wire                                 end_instr_iss;
  wire                                 end_instr_no_quash_wr;
  wire                                 end_instr_wr;
  wire                                 pre_end_instr_wr;
  wire                                 evnt_data_rd_wr;
  wire                                 evnt_data_wr_wr;
  wire                           [1:0] evnt_instr_exec;
  wire                                 evnt_fpu_interlock_iss;
  wire                                 evnt_agu_interlock_iss;
  wire                                 evnt_unaligned_ls;
  wire                                 evnt_data_mem_access;
  wire                                 evnt_expt_taken;
  wire                                 evnt_call_expt_taken;
  wire                                 evnt_sw_change_pc;
  wire      [`CA53_FAULT_REG_EN_W-1:0] expt_fault_reg_en_wr;
  wire                                 expt_fault_reg_sel_wr;
  wire                                 expt_aa32_uses_el1_esr_wr;
  wire                          [12:0] expt_ifsr_wr;
  wire                          [12:0] expt_dfsr_wr;
  wire                          [63:0] expt_far_data_wr;
  wire                          [27:0] expt_hpfar_data_wr;
  wire                                 expt_quash_wr;
  wire                                 expt_rtn_wr;
  wire                                 expt_rtn_ret;
  wire                                 expt_serr_pending;
  wire                                 expt_irq_pending;
  wire                                 expt_fiq_pending;
  wire                                 evnt_fiq_taken;
  wire                                 evnt_irq_taken;
  wire                                 cp_mdcr_el3_sdd;
  wire                           [1:0] cp_mdcr_el3_spd32;
  wire                                 cp_mdcr_el3_spme;
  wire                                 cp_mdcr_el3_epmad;
  wire                                 cp_mdcr_el3_edad;
  wire                                 first_x64_iss;
  wire                                 first_x64_wr;
  wire                                 flush_ret;
  wire                                 slot0_br_flush_wr;
  wire                                 flush_wr;
  wire                                 flush_ls_wr;
  wire                                 div_flush;
  wire                                 flush_d_utlb;
  wire                                 force_usr_priv_mem_de;
  wire                                 force_wfx_nop;
  wire                                 insert_forceop_wr;
  wire                                 forceop_valid_de;
  wire                                 forceop_valid_iss;
  wire                                 forceop_valid_wr;
  wire                                 insert_forceop_ret;
  wire                                 etm_trace_expt;
  wire                                 etm_trace_dbgentry;
  wire                                 expt_dbgexit;
  wire                                 fp_serialize_iss;
  wire                                 cp_fpexc_en;
  wire                                 cp_fpcr_ahp;
  wire                                 cp_fpcr_dn;
  wire                                 cp_fpcr_fz;
  wire                           [1:0] cp_fpcr_rmode;
  wire                                 dbg_hw_halt_req;
  wire                                 held_dbg_hw_halt_req;
  wire                                 held_dbg_osuc_halt_req;
  wire                                 held_dbg_ext_hw_halt_req;
  wire                                 dbg_restart_qual;
  wire                                 dbg_cancel_biu;
  wire                           [1:0] head_instr_de;
  wire                                 psr_wr_operation_de;
  wire                           [5:0] psr_wr_en_de;
  wire                           [3:0] psr_wr_src_de;
  wire  [`CA53_SLOT1_INSTR_TYPE_W-1:0] slot1_instr_type_de;
  wire                                 slot1_branch_iss;
  wire                                 slot1_branch_ex2;
  wire                                 slot1_branch_wr;
  wire                                 slot1_blx_ex2;
  wire                                 slot1_bx_wr;
  wire                                 slot1_blx_wr;
  wire                                 slot1_ls_ex2;
  wire                                 evnt_ls_instr_wr;
  wire                                 slot1_mul_iss;
  wire                                 slot1_mul_wr;
  wire                                 w0_slot1_wr;
  wire                                 cp_valid_ex2;
  wire                                 incr_pc_halt_mode_ret;
  wire                                 dbg_halt_ecc_expt_iss;
  wire                           [1:0] fmac_valid_sp_de;
  wire                           [1:0] fdiv_valid_de;
  wire                           [1:0] neon_can_fwd_acc_de;
  wire                           [1:0] instr_fmstat_de;
  wire                           [1:0] instr_fmstat_ex2;
  wire                           [1:0] iq_instr_is_fn;
  wire                                 instr_is_cp10_cp11_de;
  wire                                 interlock_iss;
  wire                           [1:0] isa_instr0_ex2;
  wire                           [1:0] isa_instr0_wr;
  wire                           [1:0] isa_instr0_ret;
  wire                                 isa_switch_br_ex2;
  wire                                 issue_to_ex1;
  wire                                 issue_to_ex2;
  wire                                 issue_to_ex2_fpu;
  wire                                 issue_to_iss;
  wire                                 issue_to_iss_fpu;
  wire                                 issue_to_f4;
  wire                                 issue_to_wr;
  wire                                 ld_t_bit_wr;
  wire                                 ldc_ex2;
  wire                                 ldc_stc_wr;
  wire     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_de;
  wire     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_wr;
  wire                                 ls_multiple_de;
  wire                                 ls_isv_set_de;
  wire                                 ls_isv_set_wr;
  wire                                 ls_synd_sf_de;
  wire                                 ls_synd_sf_wr;
  wire                           [4:0] ls_synd_srt_wr;
  wire                                 ls_stall_wr;
  wire                                 ls_store_de;
  wire                                 ls_store_neon_de;
  wire                                 ls_store_ex2;
  wire                                 ls_store_wr;
  wire                                 ls_store_neon_ex2;
  wire                                 ls_valid_de;
  wire                                 ls_valid_ex1;
  wire                                 ls_valid_ex2;
  wire                                 ls_valid_iss;
  wire                                 ls_valid_wr;
  wire                                 ls_check_stack_de;
  wire                                 first_lsm_skidding;
  wire                                 inter_lsm_skidding;
  wire                                 lsm_skidding;
  wire                                 lsm_64b_be;
  wire                                 lsm_64b_be_skidding;
  wire                                 lsm_n64b_be_skidding;
  wire                                 last_lsm_skidding;
  wire                                 ls_128b_be;
  wire                                 cp_de;
  wire                           [8:0] cp_op_de;
  wire                                 cp_op_mva_de;
  wire                                 cp_valid_de;
  wire                           [8:0] cp_decode_de;
  wire                                 dcu_not_ready_iss;
  wire                                 force_extra_lsm_cycle;
  wire                                 extra_lsm_cycle;
  wire                                 ldr_no_early_fwd_iss;
  wire                                 mac_valid_de;
  wire                                 raw_mac_valid_iss;
  wire                                 mac_valid_iss;
  wire                                 mod_pc_top_bits_de;
  wire                                 mul_cpsr_nz_v_de;
  wire                                 new_mac_qflag_wr;
  wire                                 no_insert_de;
  wire                                 nxt_cpsr_tbit_ret_pre;
  wire                                 cpsr_tbit_wr;
  wire                                 quash_ex1;
  wire                                 quash_ex2;
  wire                                 quash_iss;
  wire                                 quash_slot0_wr;
  wire                                 expt_slot1_wr;
  wire                                 quash_wr;
  wire                                 req_strict_algn_de;
  wire                                 check_x64_de;
  wire                           [2:0] algn_size_de;
  wire                                 btac_rtn_instr_iss;
  wire                                 paq_stall_iss;
  wire                           [1:0] rf_rd_en_fr0_de;
  wire                           [1:0] rf_rd_en_fr0_iss;
  wire                           [1:0] rf_rd_en_fr0_ex1;
  wire                           [1:0] rf_rd_en_fr0_ex2;
  wire                           [1:0] rf_rd_en_fr1_de;
  wire                           [1:0] rf_rd_en_fr1_iss;
  wire                           [1:0] rf_rd_en_fr1_ex1;
  wire                           [1:0] rf_rd_en_fr1_ex2;
  wire                           [1:0] rf_rd_en_fr2_de;
  wire                           [1:0] rf_rd_en_fr2_iss;
  wire                           [1:0] rf_rd_en_fr2_ex1;
  wire                           [1:0] rf_rd_en_fr2_ex2;
  wire                           [1:0] rf_rd_en_fr3_de;
  wire                           [1:0] rf_rd_en_fr3_iss;
  wire                           [1:0] rf_rd_en_fr3_ex1;
  wire                           [1:0] rf_rd_en_fr3_ex2;
  wire                           [1:0] rf_rd_en_fr4_de;
  wire                           [1:0] rf_rd_en_fr4_iss;
  wire                           [1:0] rf_rd_en_fr4_ex1;
  wire                           [1:0] rf_rd_en_fr4_ex2;
  wire                           [1:0] rf_rd_en_fr5_de;
  wire                           [1:0] rf_rd_en_fr5_iss;
  wire                           [1:0] rf_rd_en_fr5_ex1;
  wire                           [1:0] rf_rd_en_fr5_ex2;
  wire                                 rf_rd_en_r0_de;
  wire                                 rf_rd_en_r1_de;
  wire                                 rf_rd_en_r2_de;
  wire                                 rf_rd_en_r3_de;
  wire                                 rf_rd_en_r4_de;
  wire                           [3:0] rf_wr_en_fw0_de;
  wire                           [3:0] rf_wr_en_fw1_de;
  wire                                 rf_wr_en_fw_f5;
  wire                           [3:0] rf_wr_en_fw0_f5;
  wire                           [3:0] rf_wr_en_fw1_f5;
  wire                                 rf_wr_en_w0_de;
  wire                                 rf_wr_en_w0_wr;
  wire                                 rf_wr_en_hi_wr;
  wire                                 rf_wr_en_lo_wr;
  wire                                 rf_wr_en_w1_de;
  wire                                 rf_wr_en_w1_wr;
  wire                                 rf_wr_en_w2_de;
  wire                                 rf_wr_en_w2_wr;
  wire                                 aarch64_state_iss;
  wire                                 rf_wr_64b_w0_de;
  wire                                 rf_wr_64b_w0_wr;
  wire                                 rf_wr_64b_w1_de;
  wire                                 rf_wr_64b_w1_wr;
  wire                                 rf_wr_64b_w2_de;
  wire                                 rf_wr_64b_w2_wr;
  wire       [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_de;
  wire       [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_de;
  wire                                 rtn_addr_valid_de;
  wire                                 sel_fwd_addr_dcu_a_iss;
  wire                           [2:0] rf_rd_r0_agu_de;
  wire                           [2:0] rf_rd_r1_agu_de;
  wire                                 en_rf_rd_r0_agu_de;
  wire                                 en_rf_rd_r1_agu_de;
  wire                                 sel_mac_nzflags_wr;
  wire                                 sel_rf_wr_w0_wr;
  wire                                 sel_rf_wr_w1_wr;
  wire                                 sel_rf_wr_w2_wr;
  wire                                 cpsr_ebit_value_de;
  wire                                 size_instr0_de;
  wire                                 size_instr0_ex2;
  wire                                 size_instr0_iss;
  wire                                 size_instr0_wr;
  wire                                 size_instr0_ret;
  wire                                 size_instr1_de;
  wire                                 size_instr1_ex2;
  wire                                 size_instr1_iss;
  wire                                 size_instr1_wr;
  wire                                 size_instr1_ret;
  wire                                 thumb_instr0_de;
  wire                                 thumb_instr1_de;
  wire                                 thumb_instr0_iss;
  wire                                 thumb_instr0_ret;
  wire                                 thumb_instr1_ret;
  wire                                 expt_slot1_ret;
  wire                                 spec_endianness_iss;
  wire                                 spec_endianness_ex2;
  wire                           [1:0] isa_instr0_iss;
  wire                                 instr0_de_pc_in_iss;
  wire                                 prefetch_abort_iss;
  wire                                 srs_wr;
  wire                                 stall_ex1;
  wire                                 stall_ex2;
  wire                                 stall_iss;
  wire                                 stall_slot0_iss;
  wire                                 stall_br_iss;
  wire                                 ilock_stall_iss;
  wire                                 second_x64_iss;
  wire                                 ls_multiple_iss;
  wire                                 ls_store_iss;
  wire                                 nxt_div_stall_wr;
  wire                                 stall_wr;
  wire                                 advance_pipeline;
  wire                                 str0_valid_de;
  wire                                 str0_b_valid_de;
  wire                                 ctl_64bit_op_str0_de;
  wire                                 raw_str0_valid_iss;
  wire                                 str0_a_valid_iss;
  wire                                 str0_b_valid_iss;
  wire                                 ctl_64bit_op_str0_iss;
  wire                                 str1_valid_de;
  wire                                 str1_b_valid_de;
  wire                                 ctl_64bit_op_str1_de;
  wire                                 raw_str1_valid_iss;
  wire                                 str1_a_valid_iss;
  wire                                 str1_b_valid_iss;
  wire                                 ctl_64bit_op_str1_iss;
  wire                                 t16o_it_cpsr_valid_de;
  wire                                 aarch64_state_ext;
  wire     [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_instr1_de;
  wire                                 taken_br_instr_iss;
  wire                                 tbit_btac_rtn_instr_iss;
  wire                                 wd_align_pc_alu0_de;
  wire                                 wd_align_pc_alu0_iss;
  wire                                 wd_align_pc_alu1_de;
  wire                                 wd_align_pc_alu1_iss;
  wire                                 wd_align_pc_ls_de;
  wire                                 wd_align_pc_ls_iss;
  wire                                 pg_align_pc_ls_de;
  wire                                 pg_align_pc_ls_iss;
  wire                                 nxt_wfx_ifu_halt;
  wire                                 wfx_ifu_halt;
  wire        [`CA53_BR_PIPECTL_W-1:0] br_pipectl_de;
  wire                                 br_x_bit_de;
  wire                                 br_x_bit_iss;
  wire       [`CA53_ALU_EX1_CTL_W-1:0] alu0_ex1_ctl_iss;
  wire       [`CA53_ALU_EX2_CTL_W-1:0] alu0_ex2_ctl_iss;
  wire                                 alu0_wr_ctl_iss;
  wire       [`CA53_ALU_EX1_CTL_W-1:0] alu1_ex1_ctl_iss;
  wire       [`CA53_ALU_EX2_CTL_W-1:0] alu1_ex2_ctl_iss;
  wire                                 alu1_wr_ctl_iss;
  wire       [`CA53_ALU_PIPECTL_W-1:0] alu0_pipectl_de;
  wire       [`CA53_ALU_PIPECTL_W-1:0] alu1_pipectl_de;
  wire       [`CA53_MAC_PIPECTL_W-1:0] mac_pipectl_de;
  wire                                 alu0_msk_data_sel_de;
  wire                                 alu1_msk_data_sel_de;
  wire         [`CA53_SEL_SHF_A_W-1:0] alu0_data_a_sel_de;
  wire         [`CA53_SEL_SHF_B_W-1:0] alu0_data_b_sel_de;
  wire         [`CA53_SEL_SHF_C_W-1:0] alu0_data_c_sel_de;
  wire         [`CA53_SEL_SHF_A_W-1:0] alu1_data_a_sel_de;
  wire         [`CA53_SEL_SHF_B_W-1:0] alu1_data_b_sel_de;
  wire         [`CA53_SEL_SHF_C_W-1:0] alu1_data_c_sel_de;
  wire         [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_de;
  wire         [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_de;
  wire         [`CA53_SEL_DIV_A_W-1:0] div_data_a_sel_de;
  wire         [`CA53_SEL_DIV_B_W-1:0] div_data_b_sel_de;
  wire                                 ctl_fp_dp_en;
  wire        [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_de;
  wire        [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_iss;
  wire        [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_f1;
  wire                                 crypto_enable_de;
  wire                                 crypto_enable_iss;
  wire                                 crypto_enable_f1;
  wire        [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_iss;
  wire        [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_f1;
  wire        [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_iss;
  wire        [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_f1;
  wire                           [1:0] fp_div_enb_ex1;
  wire                           [1:0] fp_div_active;
  wire                                 instr_is_cp10_cp11_wr;
  wire      [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_de;
  wire      [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f2;
  wire      [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3;
  wire      [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_iss;
  wire      [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_iss;
  wire      [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_iss;
  wire      [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_iss;
  wire      [`CA53_FP_CFLAG_SRC_W-1:0] fp0_cflag_src_f5;
  wire      [`CA53_FP_CFLAG_SRC_W-1:0] fp1_cflag_src_f5;
  wire      [`CA53_FP_XFLAG_SRC_W-1:0] fp0_xflag_src_f5;
  wire      [`CA53_FP_XFLAG_SRC_W-1:0] fp1_xflag_src_f5;
  wire                           [3:0] fp_cflags_add0_f2;
  wire                           [3:0] fp_cflags_add1_f2;
  wire                           [3:0] fp_cflags_add0_f5;
  wire                           [3:0] fp_cflags_add1_f5;
  wire            [`CA53_XFLAGS_W-1:0] fp_xflags_mul0_f5;
  wire            [`CA53_XFLAGS_W-1:0] fp_xflags_mul1_f5;
  wire            [`CA53_XFLAGS_W-1:0] fp_xflags_add0_f5;
  wire            [`CA53_XFLAGS_W-1:0] fp_xflags_add1_f5;
  wire           [`CA53_IMM_SEL_W-1:0] imm_data_sel_0_de;
  wire           [`CA53_IMM_SEL_W-1:0] imm_data_sel_1_de;
  wire          [`CA53_IMM_DATA_W-1:0] imm_data_0_de;
  wire          [`CA53_IMM_DATA_W-1:0] imm_data_1_de;
  wire                          [32:0] imm_data_ls_de;
  wire         [`CA53_IMM_SHIFT_W-1:0] imm_shift_0_de;
  wire         [`CA53_IMM_SHIFT_W-1:0] imm_shift_1_de;
  wire        [`CA53_INSTR_TYPE_W-1:0] instr_type_de;
  wire   [`CA53_EXPT_INSTR_TYPE_W-1:0] expt_instr_type_de;
  wire                                 skid_x64_multiple_de;
  wire                                 isb_wr;
  wire       [`CA53_MAC_ISS_CTL_W-1:0] mac_iss_ctl_iss;
  wire                                 alu0_msk_data_sel_iss;
  wire                                 alu1_msk_data_sel_iss;
  wire         [`CA53_SEL_SHF_A_W-1:0] alu0_data_a_sel_iss;
  wire         [`CA53_SEL_SHF_B_W-1:0] alu0_data_b_sel_iss;
  wire         [`CA53_SEL_SHF_C_W-1:0] alu0_data_c_sel_iss;
  wire         [`CA53_SEL_SHF_A_W-1:0] alu1_data_a_sel_iss;
  wire         [`CA53_SEL_SHF_B_W-1:0] alu1_data_b_sel_iss;
  wire         [`CA53_SEL_SHF_C_W-1:0] alu1_data_c_sel_iss;
  wire         [`CA53_SEL_MAC_A_W-1:0] mac_data_a_sel_iss;
  wire         [`CA53_SEL_MAC_B_W-1:0] mac_data_b_sel_iss;
  wire         [`CA53_SEL_DIV_A_W-1:0] div_data_a_sel_iss;
  wire         [`CA53_SEL_DIV_B_W-1:0] div_data_b_sel_iss;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr0_de;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr1_de;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr2_de;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr3_de;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr4_de;
  wire       [`CA53_RF_FRD_NEED_W-1:0] rf_rd_need_fr5_de;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_de;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f5;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f3;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw0_f4;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_de;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f5;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f3;
  wire        [`CA53_RF_FWR_SRC_W-1:0] rf_wr_src_fw1_f4;
  wire       [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw0_f4;
  wire       [`CA53_RF_FWR_WHEN_W-1:0] rf_wr_when_fw1_f4;
  wire                                 rf_rd_remap_de;
  wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r0_de;
  wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r1_de;
  wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r2_de;
  wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r3_de;
  wire        [`CA53_RF_RD_NEED_W-1:0] rf_rd_need_r4_de;
  wire      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_wr;
  wire      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_wr;
  wire      [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_wr;
  wire      [`CA53_RF_WR_SRC_W0_W-1:0] rf_wr_src_w0_de;
  wire      [`CA53_RF_WR_SRC_W1_W-1:0] rf_wr_src_w1_de;
  wire      [`CA53_RF_WR_SRC_W2_W-1:0] rf_wr_src_w2_de;
  wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w0_de;
  wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w1_de;
  wire        [`CA53_RF_WR_WHEN_W-1:0] rf_wr_when_w2_de;
  wire         [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_iss;
  wire         [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_iss;
  wire         [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_iss;
  wire         [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_iss;
  wire         [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_iss;
  wire         [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_iss;
  wire                                 sel_fml0_a_iss;
  wire         [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_iss;
  wire                                 sel_fml0_c_iss;
  wire                                 sel_fml1_a_iss;
  wire         [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_iss;
  wire                                 sel_fml1_c_iss;
  wire         [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_f1;
  wire         [`CA53_SEL_FAD_B_W-1:0] sel_fad0_b_f1;
  wire         [`CA53_SEL_FAD_C_W-1:0] sel_fad0_c_f1;
  wire         [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_f1;
  wire         [`CA53_SEL_FAD_B_W-1:0] sel_fad1_b_f1;
  wire         [`CA53_SEL_FAD_C_W-1:0] sel_fad1_c_f1;
  wire                                 sel_fml0_a_f1;
  wire         [`CA53_SEL_FML_B_W-1:0] sel_fml0_b_f1;
  wire                                 sel_fml0_c_f1;
  wire                                 sel_fml1_a_f1;
  wire         [`CA53_SEL_FML_B_W-1:0] sel_fml1_b_f1;
  wire                                 sel_fml1_c_f1;
  wire       [`CA53_SEL_FWD_DCU_W-1:0] sel_fwd_dcu_a_iss;
  wire       [`CA53_SEL_FWD_DCU_W-1:0] sel_fwd_dcu_b_iss;
  wire         [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_de;
  wire         [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_de;
  wire         [`CA53_SEL_DCU_A_W-1:0] agu_data_a_sel_iss;
  wire         [`CA53_SEL_DCU_B_W-1:0] agu_data_b_sel_iss;
  wire         [`CA53_SEL_STR_A_W-1:0] str0_data_a_sel_de;
  wire         [`CA53_SEL_STR_B_W-1:0] str0_data_b_sel_de;
  wire         [`CA53_SEL_STR_A_W-1:0] str0_data_a_sel_iss;
  wire         [`CA53_SEL_STR_B_W-1:0] str0_data_b_sel_iss;
  wire         [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_de;
  wire         [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_de;
  wire         [`CA53_SEL_STR_A_W-1:0] str1_data_a_sel_iss;
  wire         [`CA53_SEL_STR_B_W-1:0] str1_data_b_sel_iss;
  wire                           [5:0] cpsr_aifbits_val;
  wire                           [2:0] agu_shf_value_de;
  wire                           [1:0] valid_instrs_de;
  wire                           [1:0] valid_instrs_iss;
  wire                                 pre_valid_instrs_wr;
  wire                           [1:0] valid_instrs_wr;
  wire                                 dbgdscr_halted;
  wire                           [1:0] edscr_intdis;
  wire                                 dbgen_synced;
  wire                                 spiden_synced;
  wire                                 dbg_hlt_en;
  wire                                 dbg_bkpt_wpt_en;
  wire                          [27:1] br_offset_de;
  wire               [`CA53_FWD_W-1:0] alu0_a_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] alu0_b_fwd_ex1;
  wire                           [1:0] fp_div_busy_nxt_cyc;
  wire                           [1:0] fp_alu_en;
  wire                           [1:0] fp_mul_en;
  wire                                 clk_fp_alu0;
  wire                                 clk_fp_alu1;
  wire                                 clk_fp_mul0;
  wire                                 clk_fp_mul1;
  wire                                 clk_crypto;
  wire                                 clk_fp_nrf;
  wire                                 clk_fp;
  wire                           [5:0] fr0_fwd_ex1;
  wire                           [5:0] fr1_fwd_ex1;
  wire                           [5:0] fr2_fwd_ex1;
  wire                           [5:0] fr3_fwd_ex1;
  wire                           [5:0] fr4_fwd_ex1;
  wire                           [5:0] fr5_fwd_ex1;
  wire                           [2:0] ls_size_de;
  wire                           [2:0] ls_elem_size_de;
  wire                           [1:0] ls_size_wr;
  wire                           [1:0] ls_elem_size_ex2;
  wire                           [1:0] ls_elem_size_wr;
  wire                           [3:0] v_addr_ex2;
  wire               [`CA53_FWD_W-1:0] r0_fwd_iss;
  wire               [`CA53_FWD_W-1:0] r1_fwd_iss;
  wire               [`CA53_FWD_W-1:0] r2_fwd_iss;
  wire               [`CA53_FWD_W-1:0] r3_fwd_iss;
  wire               [`CA53_FWD_W-1:0] r4_fwd_iss;
  wire                           [5:0] fr0_fwd_ex2;
  wire                           [5:0] fr1_fwd_ex2;
  wire                           [5:0] fr2_fwd_ex2;
  wire                           [5:0] fr3_fwd_ex2;
  wire                           [5:0] fr4_fwd_ex2;
  wire                           [5:0] fr5_fwd_ex2;
  wire                                 evnt_iq_empty;
  wire                           [1:0] fp_mul_fwd_ex2;
  wire                           [1:0] str0_sel_fp_f1;
  wire                           [1:0] str1_sel_fp_f1;
  wire                           [1:0] str0_sel_fp_f2;
  wire                           [1:0] str1_sel_fp_f2;
  wire               [`CA53_FWD_W-1:0] str0_a_fwd_ex2;
  wire               [`CA53_FWD_W-1:0] str0_b_fwd_ex2;
  wire               [`CA53_FWD_W-1:0] str0_a_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] str0_b_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] str1_a_fwd_ex2;
  wire               [`CA53_FWD_W-1:0] str1_b_fwd_ex2;
  wire               [`CA53_FWD_W-1:0] str1_a_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] str1_b_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] alu1_a_fwd_ex1;
  wire               [`CA53_FWD_W-1:0] alu1_b_fwd_ex1;
  wire                           [5:0] mac_fwd_ctl_ex1;
  wire                          [31:0] psr_cp_rd_data;
  wire                          [63:0] dbg_cp_rd_data;
  wire                          [63:0] pmu_cp_rd_data;
  wire                          [31:0] dbg_dtrrx_data;
  wire                          [31:0] cpsr_ret;
  wire                          [63:0] mcr_data_wr;
  wire                          [48:1] dpu_fe_addr_opa_wr;
  wire                          [27:1] dpu_fe_addr_opb_wr;
  wire                          [63:0] dpu_fe_addr_opa_ret;
  wire                          [17:1] dpu_fe_addr_opb_ret;
  wire                          [63:0] forceop_pc_ret;
  wire       [`CA53_SEL_CPSR_EN_W-1:0] expt_cpsr_wr_en_ret;
  wire      [`CA53_SEL_CPSR_SRC_W-1:0] expt_cpsr_wr_src_ret;
  wire                           [4:0] expt_cpsr_mode_ret;
  wire                          [17:1] forceop_pc_offset_ret;
  wire                          [63:0] alu0_fwd_data_early_ex2;
  wire                          [63:0] alu1_fwd_data_early_ex2;
  wire                          [63:0] alu0_fwd_data_early_wr;
  wire                          [63:0] alu1_fwd_data_early_wr;
  wire                          [63:0] fp_str0_data_f1;
  wire                          [63:0] fp_str1_data_f1;
  wire                          [63:0] fp_str0_data_f2;
  wire                          [63:0] fp_str1_data_f2;
  wire                          [63:0] fp_alu0_f2i_res_f3;
  wire                          [63:0] fp_alu1_f2i_res_f3;
  wire                          [63:0] fwd_ld_data_int_wr;
  wire                          [12:0] fp0_imm_data_f1;
  wire                          [12:0] fp1_imm_data_f1;
  wire                          [20:0] raw_imm_data_0_iss;
  wire                          [20:0] raw_imm_data_1_iss;
  wire                           [1:0] adrp_valid_iss;
  wire                          [63:0] ld_data0_wr;
  wire                          [63:0] ld_data1_wr;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r0_de;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r1_de;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r0_agu_de;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r1_agu_de;
  wire                           [5:0] rf_r0_for_fwd_check_de;
  wire                           [5:0] rf_r1_for_fwd_check_de;
  wire                          [63:0] pc_instr0_de;
  wire                          [63:0] pc_instr0_iss;
  wire                          [48:1] pc_instr1_iss;
  wire                          [48:1] pc_instr0_ex2;
  wire                          [63:0] pc_instr0_wr;
  wire                          [63:0] pc_instr0_ret;
  wire                                 nxt_pc_sample_perm;
  wire                                 pc_sample_perm;
  wire                          [31:0] cpsr_masked_ret;
  wire                          [63:0] rf_rd_data_r0_iss;
  wire                          [63:0] rf_rd_data_r0_agu_iss;
  wire                          [63:0] rf_rd_data_r1_iss;
  wire                          [63:0] rf_rd_data_r1_agu_iss;
  wire                          [63:0] rf_rd_data_r2_iss;
  wire                          [63:0] rf_rd_data_r3_iss;
  wire                          [63:0] rf_rd_data_r4_iss;
  wire                          [63:0] rf_wr_data_w0_wr;
  wire                          [63:0] rf_wr_data_w1_wr;
  wire                          [63:0] rf_wr_data_w2_wr;
  wire                          [63:0] mrc_data_wr;
  wire                          [31:0] spsr_ret;
  wire                          [63:0] st0_data_ex1;
  wire                          [63:0] st0_data_wr;
  wire                          [63:0] st1_data_ex1;
  wire                          [63:0] st1_data_wr;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_iss;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_iss;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_iss;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_iss;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_iss;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_iss;
  wire                                 rf_wr_en_fw_f3;
  wire                          [48:1] rtn_addr_iss;
  wire                          [27:1] br_offset_iss;
  wire                           [3:0] ccflags_wr;
  wire                           [3:0] cond_code_instr0_de;
  wire                           [3:0] cond_code_instr0_ex2;
  wire                           [3:0] cond_code_instr1_de;
  wire                           [3:0] cond_code_instr1_ex2;
  wire                           [3:0] cpsr_flag_update_nzcv;
  wire                           [4:0] cpsr_mode_ret;
  wire                                 disable_dual_issue;
  wire                                 disable_fp_dual_issue;
  wire                                 force_clean_to_invalidate;
  wire                                 cp_trap_fp;
  wire                                 cp_trap_neon;
  wire                           [3:0] expt_status_moe_data_wr;
  wire                                 expt_idle;
  wire                                 in_halt;
  wire                                 expt_mon_mode_clear_ns;
  wire                           [3:0] cp_fpsr_cflags;
  wire                           [3:0] fp_fwd_cflags_ex2;
  wire                           [3:0] geflags_wr;
  wire                           [4:0] spec_cpsr_mode_iss;
  wire                                 spec_cpsr_mode_usr_iss;
  wire                                 spec_cpsr_mode_sys_iss;
  wire                                 spec_cpsr_mode_mon_iss;
  wire                                 spec_cpsr_mode_hyp_iss;
  wire                                 ns_state;
  wire                                 ns_state_de;
  wire                                 aarch64_state;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_de;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_de;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_de;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_de;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_de;
  wire     [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_de;
  wire                           [5:0] rf_rd_addr_r0_de;
  wire                           [5:0] rf_rd_addr_r1_de;
  wire                           [5:0] rf_rd_addr_r2_de;
  wire                           [5:0] rf_rd_addr_r3_de;
  wire                           [5:0] rf_rd_addr_r4_de;
  wire                           [5:0] rf_stm_rd_addr_r2_de;
  wire                           [5:0] rf_stm_rd_addr_r3_de;
  wire                                 instr0_r2_enabled_de;
  wire                                 instr0_w0_enabled_de;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r2_iss;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r3_iss;
  wire      [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r4_iss;
  wire     [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_de;
  wire     [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_de;
  wire     [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f5;
  wire     [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f5;
  wire                                 msr_mrs_reg_wr_de;
  wire                                 msr_mrs_spsr_de;
  wire                           [5:0] msr_mrs_data_de;
  wire                           [3:0] msr_mrs_data_wr;
  wire                           [4:0] rf_wr_vaddr_w0_de;
  wire                           [4:0] rf_wr_vaddr_w1_de;
  wire                           [4:0] rf_wr_vaddr_w2_de;
  wire                           [5:0] rf_wr_addr_w0_wr;
  wire                           [5:0] rf_wr_addr_w1_wr;
  wire                           [5:0] rf_wr_addr_w2_wr;
  wire                           [5:0] ls_length_de;
  wire                          [31:0] expt_esr_data_wr;
  wire                           [7:0] t16o_it_cpsr_mask_de;
  wire                          [31:0] dpu_dacr;
  wire                          [31:0] dpu_dacr_ns;
  wire                                 dpu_dacr_mmu_on;
  wire         [`CA53_EXPT_TYPE_W-1:0] expt_type;
  wire                                 expt_type_l1_ecc;
  wire      [`CA53_FORCEOP_TYPE_W-1:0] forceop_type;
  wire    [`CA53_FORCEOP_OFFSET_W-1:0] forceop_offset;
  wire                                 forceop_aa64;
  wire                                 nxt_cp_valid_wr;
  wire                                 cp_valid_wr;
  wire                                 raw_cp_valid_wr;
  wire                           [8:0] raw_cp_decode_wr;
  wire                          [15:0] cp15_pmu_access_wr;
  wire                                 mrc_instr_ex1;
  wire                                 mrc_instr_ex2;
  wire                                 mrc_instr_wr;
  wire                           [3:0] pmn_useren;
  wire                          [63:5] cp_vbar_el3;
  wire                          [63:5] cp_vbar_el1;
  wire                          [31:5] cp_mvbar;
  wire                          [63:5] cp_hvbar;
  wire                                 scr_twi;
  wire                                 scr_twe;
  wire                                 scr_st;
  wire                                 scr_hce;
  wire                                 scr_smd;
  wire                                 scr_aw;
  wire                                 scr_fw;
  wire                                 scr_ea;
  wire                                 scr_fiq;
  wire                                 scr_irq;
  wire                                 edscr_sdd;
  wire                                 edscr_tda;
  wire                                 ns_scr;
  wire                                 nxt_ns_scr;
  wire                                 wr_scr;
  wire                           [1:0] cp_sder;
  wire                                 dbg_non_inv_perm_us;
  wire                                 dbg_non_inv_perm_synced;
  wire                                 dbg_os_lock_synced;
  wire                                 dbg_double_lock_set;
  wire                                 dbg_halting_allowed;
  wire                                 hcr_va;
  wire                                 hcr_vi;
  wire                                 hcr_vf;
  wire                                 hcr_amo;
  wire                                 hcr_imo;
  wire                                 hcr_fmo;
  wire                          [11:2] apb_addr;
  wire                          [31:0] apb_wdata;
  wire                                 pmu_apb_wr;
  wire                                 nxt_pmu_apb_wr;
  wire                          [31:0] pmu_apb_rdata;
  wire                                 apb_pmu_access;
  wire                                 ongoing_ldm_wr;
  wire                           [4:0] ls_synd_srt_de;
  wire     [`CA53_FLAGEN_INSTR1_W-1:0] flag_en_instr1_wr;
  wire                                 rf_wr_en_w0_iss;
  wire                                 rf_wr_en_w1_iss;
  wire                                 rf_wr_en_w2_iss;
  wire                           [1:0] rf_wr_when_w0_iss;
  wire                           [1:0] rf_wr_when_w1_iss;
  wire                           [1:0] rf_wr_when_w2_iss;
  wire                           [4:0] rf_wr_vaddr_w0_iss;
  wire                           [4:0] rf_wr_vaddr_w1_iss;
  wire                           [4:0] rf_wr_vaddr_w2_iss;
  wire                                 rf_wr_en_w0_ex1;
  wire                                 rf_wr_en_w1_ex1;
  wire                                 rf_wr_en_w2_ex1;
  wire                           [1:0] rf_wr_when_w0_ex1;
  wire                           [1:0] rf_wr_when_w1_ex1;
  wire                           [1:0] rf_wr_when_w2_ex1;
  wire                           [4:0] rf_wr_vaddr_w0_ex1;
  wire                           [4:0] rf_wr_vaddr_w1_ex1;
  wire                           [4:0] rf_wr_vaddr_w2_ex1;
  wire                           [3:0] rf_wr_en_fw0_iss;
  wire                           [3:0] rf_wr_en_fw1_iss;
  wire                           [3:0] rf_wr_en_fw0_f1;
  wire                           [3:0] rf_wr_en_fw1_f1;
  wire                           [3:0] rf_wr_en_fw0_f2;
  wire                           [3:0] rf_wr_en_fw1_f2;
  wire                           [1:0] rf_wr_when_fw0_iss;
  wire                           [1:0] rf_wr_when_fw1_iss;
  wire                           [1:0] rf_wr_when_fw0_f1;
  wire                           [1:0] rf_wr_when_fw1_f1;
  wire                           [1:0] rf_wr_when_fw0_f2;
  wire                           [1:0] rf_wr_when_fw1_f2;
  wire                           [5:0] rf_wr_addr_fw0_iss;
  wire                           [5:0] rf_wr_addr_fw1_iss;
  wire                           [5:0] rf_wr_addr_fw0_f1;
  wire                           [5:0] rf_wr_addr_fw1_f1;
  wire                           [5:0] rf_wr_addr_fw0_f2;
  wire                           [5:0] rf_wr_addr_fw1_f2;
  wire                                 exception_valid_iss;
  wire                                 exception_valid_ex1;
  wire    [`CA53_EXPT_INSTR_BUS_W-1:0] expt_instr_data_de;
  wire                                 early_expt_enable_de;
  wire                                 neon_de_active;
  wire                                 fp_dp_en_active;
  wire                                 crypto_active;
  wire                                 paq_full;
  wire                                 cpuactlr_el3;
  wire                                 cpuectlr_el3;
  wire                                 l2ctlr_el3;
  wire                                 l2ectlr_el3;
  wire                                 l2actlr_el3;
  wire                                 cpuactlr_el2;
  wire                                 cpuectlr_el2;
  wire                                 l2ctlr_el2;
  wire                                 l2ectlr_el2;
  wire                                 l2actlr_el2;
  wire                                 cp14_wr_dspsr;
  wire                                 dbg_starting;
  wire                                 ss_enter_halt;
  wire                                 edecr_ss_reg;
  wire          [`CA53_CPSR_RET_W-1:0] dspsr_reg;
  wire                                 branch_align_pc_wr;
  wire                                 debug_exit_aa32;
  wire                                 cryptodisable;
  wire                                 giccdisable;
  wire                                 dbg_soft_step_active;
  wire                                 dbg_halt_step_active_not_pend;
  wire                           [1:0] expt_cpacr_el1_fpen;
  wire                                 expt_cpacr_asedis;
  wire                                 expt_cptr_el2_tfp;
  wire                                 expt_hcptr_tase;
  wire                                 expt_cptr_el2_tcpac;
  wire                                 evnt_mem_err_ifu;
  wire                                 evnt_mem_err_dcu;
  wire                                 evnt_mem_err_tlb;
  wire                           [1:0] neon_instr_iss;

  // ------------------------------------------------------
  // CP
  // ------------------------------------------------------

  ca53dpu_cp `CA53_DPU_PARAM_INST u_dpu_cp (
    // Inputs
    .clk                                        (clk),
    .reset_n                                    (reset_n),
    .po_reset_n                                 (po_reset_n),
    .DFTSE                                      (DFTSE),
    .aarch64_state_i                            (aarch64_state),
    .dpu_exception_level_i                      (dpu_exception_level[1:0]),
    .stall_iss_i                                (stall_iss),
    .stall_wr_i                                 (stall_wr),
    .flush_wr_i                                 (flush_wr),
    .flush_ret_i                                (flush_ret),
    .expt_quash_wr_i                            (expt_quash_wr),
    .cc_pass_instr0_wr_i                        (cc_pass_instr0_wr),
    .cp_valid_de_i                              (cp_valid_de),
    .cp_decode_de_i                             (cp_decode_de[8:0]),
    .fp_serialise_de_i                          (fp_serialise_de),
    .in_halt_i                                  (in_halt),
    .dcu_ld_data_dc3_i                          (dcu_ld_data_dc3_i[63:0]),
    .dbg_cp_rd_data_i                           (dbg_cp_rd_data[63:0]),
    .pmu_cp_rd_data_i                           (pmu_cp_rd_data[63:0]),
    .psr_cp_rd_data_i                           (psr_cp_rd_data[31:0]),
    .st0_data_wr_i                              (st0_data_wr[63:0]),
    .expt_mon_mode_clear_ns_i                   (expt_mon_mode_clear_ns),
    .expt_fault_reg_en_wr_i                     (expt_fault_reg_en_wr[`CA53_FAULT_REG_EN_W-1:0]),
    .expt_fault_reg_sel_wr_i                    (expt_fault_reg_sel_wr),
    .expt_aa32_uses_el1_esr_wr_i                (expt_aa32_uses_el1_esr_wr),
    .expt_ifsr_wr_i                             (expt_ifsr_wr[12:0]),
    .expt_dfsr_wr_i                             (expt_dfsr_wr[12:0]),
    .expt_far_data_wr_i                         (expt_far_data_wr[63:0]),
    .expt_hpfar_data_wr_i                       (expt_hpfar_data_wr[27:0]),
    .expt_esr_data_wr_i                         (expt_esr_data_wr),
    .gov_rvbaraddr_i                            (gov_rvbaraddr_i[39:2]),
    .gov_aa64naa32_i                            (gov_aa64naa32_i),
    .gov_cryptodisable_i                        (gov_cryptodisable_i),
    .gov_giccdisable_i                          (gov_giccdisable_i),
    .gov_cfgend_i                               (gov_cfgend_i),
    .gov_cfgte_i                                (gov_cfgte_i),
    .gov_vinithi_i                              (gov_vinithi_i),
    .ic_size_i                                  (ic_size_i[2:0]),
    .dc_size_i                                  (dc_size_i[2:0]),
    .l2_size_i                                  (l2_size_i[3:0]),
    .gov_clusteridaff2_i                        (gov_clusteridaff2_i[7:0]),
    .gov_clusteridaff1_i                        (gov_clusteridaff1_i[7:0]),
    .cpu_id_i                                   (cpu_id_i[1:0]),
    .ctr_cwg_i                                  (ctr_cwg_i[3:0]),
    .ctr_erg_i                                  (ctr_erg_i[3:0]),
    .clear_virtual_ea_i                         (clear_virtual_ea),
    .expt_serr_pending_i                        (expt_serr_pending),
    .expt_irq_pending_i                         (expt_irq_pending),
    .expt_fiq_pending_i                         (expt_fiq_pending),
    .ns_state_i                                 (ns_state),
    .gov_periphbase_i                           (gov_periphbase_i[39:18]),
    .fp0_cflag_src_f5_i                         (fp0_cflag_src_f5[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp1_cflag_src_f5_i                         (fp1_cflag_src_f5[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp0_xflag_src_f5_i                         (fp0_xflag_src_f5[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp1_xflag_src_f5_i                         (fp1_xflag_src_f5[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp_cflags_add0_f5_i                        (fp_cflags_add0_f5[3:0]),
    .fp_cflags_add1_f5_i                        (fp_cflags_add1_f5[3:0]),
    .fp_xflags_mul0_f5_i                        (fp_xflags_mul0_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_mul1_f5_i                        (fp_xflags_mul1_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add0_f5_i                        (fp_xflags_add0_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add1_f5_i                        (fp_xflags_add1_f5[`CA53_XFLAGS_W-1:0]),
    .spec_cpsr_mode_mon_iss_i                   (spec_cpsr_mode_mon_iss),
    .dpu_fe_valid_ret_i                         (dpu_fe_valid_ret),
    .dcu_ecc_fatal_i                            (dcu_ecc_fatal_i),
    .dcu_ecc_valid_i                            (dcu_ecc_valid_i),
    .dcu_ecc_ramid_i                            (dcu_ecc_ramid_i),
    .dcu_ecc_way_bank_id_i                      (dcu_ecc_way_bank_id_i),
    .dcu_ecc_index_i                            (dcu_ecc_index_i),
    .tlb_pty_valid_i                            (tlb_pty_valid_i),
    .tlb_pty_way_bank_id_i                      (tlb_pty_way_bank_id_i),
    .tlb_pty_index_i                            (tlb_pty_index_i),
    .ifu_pty_valid_i                            (ifu_pty_valid_i),
    .ifu_pty_ramid_i                            (ifu_pty_ramid_i),
    .ifu_pty_way_bank_id_i                      (ifu_pty_way_bank_id_i),
    .ifu_pty_index_i                            (ifu_pty_index_i),
    // Outputs
    .mcr_data_wr_o                              (mcr_data_wr[63:0]),
    .mrc_data_wr_o                              (mrc_data_wr[63:0]),
    .cp_valid_ex2_o                             (cp_valid_ex2),
    .nxt_cp_valid_wr_o                          (nxt_cp_valid_wr),
    .cp_valid_wr_o                              (cp_valid_wr),
    .raw_cp_valid_wr_o                          (raw_cp_valid_wr),
    .raw_cp_decode_wr_o                         (raw_cp_decode_wr[8:0]),
    .cp15_pmu_access_wr_o                       (cp15_pmu_access_wr[15:0]),
    .dpu_icache_on_o                            (dpu_icache_on_o),
    .dpu_l1deien_o                              (dpu_l1deien_o),
    .dpu_disable_dmb_o                          (dpu_disable_dmb_o),
    .dpu_disable_device_split_throttle_o        (dpu_disable_device_split_throttle_o),
    .dpu_enable_data_prefetch_o                 (dpu_enable_data_prefetch_o[2:0]),
    .dpu_enable_data_prefetch_streams_o         (dpu_enable_data_prefetch_streams_o[1:0]),
    .dpu_data_prefetch_stride_detect_o          (dpu_data_prefetch_stride_detect_o),
    .dpu_disable_data_prefetch_stores_pattern_o (dpu_disable_data_prefetch_stores_pattern_o),
    .dpu_disable_data_prefetch_readunique_o     (dpu_disable_data_prefetch_readunique_o),
    .dpu_disable_no_allocate_o                  (dpu_disable_no_allocate_o),
    .dpu_ramode_cnt_l1_o                        (dpu_ramode_cnt_l1_o[1:0]),
    .dpu_ramode_cnt_l2_o                        (dpu_ramode_cnt_l2_o[1:0]),
    .dpu_periphbase_o                           (dpu_periphbase_o[21:0]),
    .dpu_smp_en_o                               (dpu_smp_en_o),
    .force_clean_to_invalidate_o                (force_clean_to_invalidate),
    .disable_dual_issue_o                       (disable_dual_issue),
    .disable_fp_dual_issue_o                    (disable_fp_dual_issue),
    .cptr_el3_tcpac_o                           (cptr_el3_tcpac),
    .cptr_el3_tfp_o                             (cptr_el3_tfp),
    .hcr_fb_o                                   (hcr_fb),
    .hcr_bsu_o                                  (hcr_bsu),
    .hcr_twi_o                                  (hcr_twi),
    .hcr_twe_o                                  (hcr_twe),
    .hcr_tid0_o                                 (hcr_tid0),
    .hcr_tid1_o                                 (hcr_tid1),
    .hcr_tid2_o                                 (hcr_tid2),
    .hcr_tid3_o                                 (hcr_tid3),
    .hcr_tsc_o                                  (hcr_tsc),
    .hcr_tidcp_o                                (hcr_tidcp),
    .hcr_tacr_o                                 (hcr_tacr),
    .hcr_tsw_o                                  (hcr_tsw),
    .hcr_tpc_o                                  (hcr_tpc),
    .hcr_tpu_o                                  (hcr_tpu),
    .hcr_tdz_o                                  (hcr_tdz),
    .hcr_ttlb_o                                 (hcr_ttlb),
    .hcr_tvm_o                                  (hcr_tvm),
    .hcr_trvm_o                                 (hcr_trvm),
    .hcr_tge_o                                  (hcr_tge),
    .hcr_va_o                                   (hcr_va),
    .hcr_vi_o                                   (hcr_vi),
    .hcr_vf_o                                   (hcr_vf),
    .hcr_amo_o                                  (hcr_amo),
    .hcr_imo_o                                  (hcr_imo),
    .hcr_fmo_o                                  (hcr_fmo),
    .hdcr_tdra_o                                (hdcr_tdra),
    .hdcr_tdosa_o                               (hdcr_tdosa),
    .hdcr_tda_o                                 (hdcr_tda),
    .hdcr_tde_o                                 (hdcr_tde),
    .hdcr_tpm_o                                 (hdcr_tpm),
    .hdcr_tpmcr_o                               (hdcr_tpmcr),
    .hdcr_hpme_o                                (hdcr_hpme),
    .hdcr_hpmn_o                                (hdcr_hpmn[4:0]),
    .mdcr_el3_tdosa_o                           (mdcr_el3_tdosa),
    .mdcr_el3_tda_o                             (mdcr_el3_tda),
    .mdcr_el3_tpm_o                             (mdcr_el3_tpm),
    .hstr_trap_cp15_o                           (hstr_trap_cp15[13:0]),
    .hsctlr_te_o                                (hsctlr_te),
    .aarch64_at_el_o                            (aarch64_at_el[3:1]),
    .rvbaraddr_o                                (rvbaraddr[39:2]),
    .dpu_warmrstreq_o                           (dpu_warmrstreq_o),
    .sctlr_endian_el1_o                         (sctlr_endian_el1),
    .sctlr_endian_el2_o                         (sctlr_endian_el2),
    .sctlr_endian_el3_o                         (sctlr_endian_el3),
    .sctlr_el1_e0e_o                            (sctlr_el1_e0e),
    .sctlr_el3_itd_o                            (sctlr_el3_itd),
    .sctlr_el2_itd_o                            (sctlr_el2_itd),
    .sctlr_el1_itd_o                            (sctlr_el1_itd),
    .sctlr_ns_te_o                              (sctlr_ns_te),
    .sctlr_s_te_o                               (sctlr_s_te),
    .sctlr_ns_hivecs_o                          (sctlr_ns_hivecs),
    .sctlr_s_hivecs_o                           (sctlr_s_hivecs),
    .sctlr_align_check_o                        (sctlr_align_check),
    .sctlr_ntwe_o                               (sctlr_ntwe),
    .sctlr_ntwi_o                               (sctlr_ntwi),
    .sctlr_cp15ben_o                            (sctlr_cp15ben),
    .sctlr_sed_o                                (sctlr_sed),
    .sctlr_el1_uci_o                            (sctlr_el1_uci),
    .sctlr_el1_uct_o                            (sctlr_el1_uct),
    .sctlr_el1_uma_o                            (sctlr_el1_uma),
    .sctlr_el1_dze_o                            (sctlr_el1_dze),
    .sctlr_sa_at_el_o                           (sctlr_sa_at_el[3:0]),
    .dpu_sctlr_uwxn_el1_o                       (dpu_sctlr_uwxn_el1_o),
    .dpu_sctlr_uwxn_el3_o                       (dpu_sctlr_uwxn_el3_o),
    .dpu_hivecs_o                               (dpu_hivecs_o),
    .dpu_default_cacheable_o                    (dpu_default_cacheable),
    .dpu_ipa_to_pa_en_o                         (dpu_ipa_to_pa_en_o),
    .dpu_pr_tablewalk_o                         (dpu_pr_tablewalk_o),
    .dpu_dcache_on_o                            (dpu_dcache_on_o),
    .dpu_s2_dcache_on_o                         (dpu_s2_dcache_on_o),
    .dpu_mmu_on_o                               (dpu_mmu_on),
    .dpu_mmu_on_el1_o                           (dpu_mmu_on_el1),
    .dpu_mmu_on_el2_o                           (dpu_mmu_on_el2_o),
    .dpu_mmu_on_el3_o                           (dpu_mmu_on_el3_o),
    .dpu_dcache_on_el1_o                        (dpu_dcache_on_el1_o),
    .dpu_dcache_on_el2_o                        (dpu_dcache_on_el2_o),
    .dpu_dcache_on_el3_o                        (dpu_dcache_on_el3_o),
    .dpu_sctlr_wxn_el1_o                        (dpu_sctlr_wxn_el1_o),
    .dpu_sctlr_wxn_el2_o                        (dpu_sctlr_wxn_el2_o),
    .dpu_sctlr_wxn_el3_o                        (dpu_sctlr_wxn_el3_o),
    .dpu_sctlr_itd_o                            (dpu_sctlr_itd_o),
    .dpu_throttle_enable_o                      (dpu_throttle_enable_o),
    .fp_serialize_iss_o                         (fp_serialize_iss),
    .mrc_instr_ex1_o                            (mrc_instr_ex1),
    .mrc_instr_ex2_o                            (mrc_instr_ex2),
    .mrc_instr_wr_o                             (mrc_instr_wr),
    .cp_vbar_el3_o                              (cp_vbar_el3[63:5]),
    .cp_vbar_el1_o                              (cp_vbar_el1[63:5]),
    .cp_mvbar_o                                 (cp_mvbar[31:5]),
    .cp_hvbar_o                                 (cp_hvbar[63:5]),
    .dpu_sif_only_o                             (dpu_sif_only_o),
    .scr_twi_o                                  (scr_twi),
    .scr_twe_o                                  (scr_twe),
    .scr_st_o                                   (scr_st),
    .scr_hce_o                                  (scr_hce),
    .scr_smd_o                                  (scr_smd),
    .scr_aw_o                                   (scr_aw),
    .scr_fw_o                                   (scr_fw),
    .scr_ea_o                                   (scr_ea),
    .scr_fiq_o                                  (scr_fiq),
    .scr_irq_o                                  (scr_irq),
    .ns_scr_o                                   (ns_scr),
    .nxt_ns_scr_o                               (nxt_ns_scr),
    .wr_scr_o                                   (wr_scr),
    .ns_state_de_o                              (ns_state_de),
    .dpu_tex_remap_enable_el1_o                 (dpu_tex_remap_enable_el1_o),
    .dpu_tex_remap_enable_el3_o                 (dpu_tex_remap_enable_el3_o),
    .dpu_access_flag_enable_el1_o               (dpu_access_flag_enable_el1_o),
    .dpu_access_flag_enable_el3_o               (dpu_access_flag_enable_el3_o),
    .dpu_dacr_o                                 (dpu_dacr),
    .dpu_dacr_ns_o                              (dpu_dacr_ns),
    .dpu_dacr_mmu_on_o                          (dpu_dacr_mmu_on),
    .flush_d_utlb_o                             (flush_d_utlb),
    .flush_i_utlb_o                             (dpu_flush_i_utlb_o),
    .tlb_abandon_o                              (dpu_tlb_abandon_o),
    .cp_sder_o                                  (cp_sder[1:0]),
    .cp_icimvau_o                               (cp_icimvau),
    .dpu_cpuectlr_cpu_ret_delay_o               (dpu_cpuectlr_cpu_ret_delay_o),
    .dpu_cpuectlr_neon_ret_delay_o              (dpu_cpuectlr_neon_ret_delay_o),
    .cp_fpexc_en_o                              (cp_fpexc_en),
    .cp_fpsr_cflags_o                           (cp_fpsr_cflags[3:0]),
    .cp_fpcr_ahp_o                              (cp_fpcr_ahp),
    .cp_fpcr_dn_o                               (cp_fpcr_dn),
    .cp_fpcr_fz_o                               (cp_fpcr_fz),
    .cp_fpcr_rmode_o                            (cp_fpcr_rmode[1:0]),
    .cp_mdcr_el3_sdd_o                          (cp_mdcr_el3_sdd),
    .cp_mdcr_el3_spd32_o                        (cp_mdcr_el3_spd32),
    .cp_mdcr_el3_spme_o                         (cp_mdcr_el3_spme),
    .cp_mdcr_el3_epmad_o                        (cp_mdcr_el3_epmad),
    .cp_mdcr_el3_edad_o                         (cp_mdcr_el3_edad),
    .cpuactlr_el3_o                             (cpuactlr_el3),
    .cpuectlr_el3_o                             (cpuectlr_el3),
    .l2ctlr_el3_o                               (l2ctlr_el3),
    .l2ectlr_el3_o                              (l2ectlr_el3),
    .l2actlr_el3_o                              (l2actlr_el3),
    .cpuactlr_el2_o                             (cpuactlr_el2),
    .cpuectlr_el2_o                             (cpuectlr_el2),
    .l2ctlr_el2_o                               (l2ctlr_el2),
    .l2ectlr_el2_o                              (l2ectlr_el2),
    .l2actlr_el2_o                              (l2actlr_el2),
    .expt_cpacr_el1_fpen_o                      (expt_cpacr_el1_fpen[1:0]),
    .expt_cpacr_asedis_o                        (expt_cpacr_asedis),
    .expt_cptr_el2_tfp_o                        (expt_cptr_el2_tfp),
    .expt_hcptr_tase_o                          (expt_hcptr_tase),
    .expt_cptr_el2_tcpac_o                      (expt_cptr_el2_tcpac),
    .cp_trap_fp_o                               (cp_trap_fp),
    .cp_trap_neon_o                             (cp_trap_neon),
    .cryptodisable_o                            (cryptodisable),
    .giccdisable_o                              (giccdisable),
    .evnt_mem_err_ifu_o                         (evnt_mem_err_ifu),
    .evnt_mem_err_dcu_o                         (evnt_mem_err_dcu),
    .evnt_mem_err_tlb_o                         (evnt_mem_err_tlb)
  );

  // ------------------------------------------------------
  // PMU
  // ------------------------------------------------------

  ca53dpu_pmu `CA53_DPU_PARAM_INST u_dpu_pmu (
    // Inputs
    .clk                                  (clk),
    .reset_n                              (reset_n),
    .DFTSE                                (DFTSE),
    .nxt_cp_valid_wr_i                    (nxt_cp_valid_wr),
    .cp_valid_wr_i                        (cp_valid_wr),
    .raw_cp_valid_wr_i                    (raw_cp_valid_wr),
    .raw_cp_decode_wr_i                   (raw_cp_decode_wr[8:0]),
    .cp15_pmu_access_wr_i                 (cp15_pmu_access_wr[15:0]),
    .mcr_data_wr_i                        (mcr_data_wr[63:0]),
    .hdcr_hpme_i                          (hdcr_hpme),
    .hdcr_hpmn_i                          (hdcr_hpmn[4:0]),
    .cp_mdcr_el3_spme_i                   (cp_mdcr_el3_spme),
    .aarch64_state_i                      (aarch64_state),
    .dpu_exception_level_i                (dpu_exception_level[1:0]),
    .ns_state_i                           (ns_state),
    .stall_wr_i                           (stall_wr),
    .dbgdscr_halted_i                     (dbgdscr_halted),
    .dbg_non_inv_perm_synced_i            (dbg_non_inv_perm_synced),
    .biu_evnt_ext_mem_req_i               (biu_evnt_ext_mem_req_i),
    .biu_evnt_ext_mem_req_nc_i            (biu_evnt_ext_mem_req_nc_i),
    .biu_evnt_pf_lf_i                     (biu_evnt_pf_lf_i),
    .biu_evnt_rw_lf_i                     (biu_evnt_rw_lf_i),
    .biu_evnt_ramode_i                    (biu_evnt_ramode_i),
    .biu_evnt_ramode_enter_i              (biu_evnt_ramode_enter_i),
    .dcu_evnt_dc_access_i                 (dcu_evnt_dc_access_i),
    .tlb_evnt_data_pagewalk_i             (tlb_evnt_data_pagewalk_i),
    .tlb_evnt_instr_pagewalk_i            (tlb_evnt_instr_pagewalk_i),
    .scu_evnt_l2_access_i                 (scu_evnt_l2_access_i),
    .scu_evnt_l2_refill_i                 (scu_evnt_l2_refill_i),
    .scu_evnt_l2_wb_i                     (scu_evnt_l2_wb_i),
    .scu_evnt_snooped_data_i              (scu_evnt_snooped_data_i),
    .scu_evnt_bus_cycle_i                 (scu_evnt_bus_cycle_i),
    .scu_evnt_bus_acc_rd_i                (scu_evnt_bus_acc_rd_i),
    .scu_evnt_bus_acc_wr_i                (scu_evnt_bus_acc_wr_i),
    .scu_evnt_eviction_i                  (scu_evnt_eviction_i),
    .ifu_evnt_ic_lf_i                     (ifu_evnt_ic_lf_i),
    .ifu_evnt_ic_access_i                 (ifu_evnt_ic_access_i),
    .ifu_evnt_ic_miss_wait_i              (ifu_evnt_ic_miss_wait_i),
    .ifu_evnt_iutlb_miss_wait_i           (ifu_evnt_iutlb_miss_wait_i),
    .ifu_evnt_pdc_valid_i                 (ifu_evnt_pdc_valid_i),
    .ifu_evnt_throttle_i                  (ifu_evnt_throttle_i),
    .evnt_expt_taken_i                    (evnt_expt_taken),
    .evnt_call_expt_taken_i               (evnt_call_expt_taken),
    .evnt_sw_change_pc_i                  (evnt_sw_change_pc),
    .expt_rtn_ret_i                       (expt_rtn_ret),
    .evnt_data_rd_wr_i                    (evnt_data_rd_wr),
    .evnt_data_wr_wr_i                    (evnt_data_wr_wr),
    .evnt_instr_exec_i                    (evnt_instr_exec[1:0]),
    .interlock_iss_i                      (interlock_iss),
    .evnt_fpu_interlock_iss_i             (evnt_fpu_interlock_iss),
    .evnt_agu_interlock_iss_i             (evnt_agu_interlock_iss),
    .evnt_unaligned_ls_i                  (evnt_unaligned_ls),
    .evnt_data_mem_access_i               (evnt_data_mem_access),
    .evnt_br_valid_wr_i                   (evnt_br_valid_wr),
    .evnt_br_mispred_i                    (evnt_br_mispred),
    .evnt_br_direct_wr_i                  (evnt_br_direct_wr),
    .evnt_br_indirect_i                   (evnt_br_indirect),
    .evnt_br_indirect_mispred_i           (evnt_br_indirect_mispred),
    .evnt_br_indirect_mispred_addr_i      (evnt_br_indirect_mispred_addr),
    .evnt_iq_empty_i                      (evnt_iq_empty),
    .evnt_mem_err_ifu_i                   (evnt_mem_err_ifu),
    .evnt_mem_err_dcu_i                   (evnt_mem_err_dcu),
    .evnt_mem_err_tlb_i                   (evnt_mem_err_tlb),
    .ls_store_wr_i                        (ls_store_wr),
    .ls_valid_wr_i                        (ls_valid_wr),
    .dpu_pred_br_wr_i                     (dpu_pred_br_wr),
    .dpu_mispred_wr_i                     (dpu_mispred_wr),
    .evnt_fiq_taken_i                     (evnt_fiq_taken),
    .evnt_irq_taken_i                     (evnt_irq_taken),
    .stb_evnt_stb_stall_i                 (stb_evnt_stb_stall_i),
    .pmu_apb_wr_i                         (pmu_apb_wr),
    .nxt_pmu_apb_wr_i                     (nxt_pmu_apb_wr),
    .apb_addr_i                           (apb_addr[11:2]),
    .apb_wdata_i                          (apb_wdata[31:0]),
    // Outputs
    .pmu_cp_rd_data_o                     (pmu_cp_rd_data[63:0]),
    .dpu_npmuirq_o                        (dpu_npmuirq_o),
    .dpu_pmuevent_o                       (dpu_pmuevent_o[25:0]),
    .pmn_useren_o                         (pmn_useren),
    .pmu_apb_rdata_o                      (pmu_apb_rdata[31:0]),
    .apb_pmu_access_o                     (apb_pmu_access)
  );

  // ------------------------------------------------------
  // Decoder
  // ------------------------------------------------------

  ca53dpu_de `CA53_DPU_PARAM_INST u_dpu_de (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .DFTSE                        (DFTSE),
    .stall_de_i                   (stall_iss),
    .gov_cp15sdisable_i           (gov_cp15sdisable_i),
    .giccdisable_i                (giccdisable),
    .ns_scr_i                     (ns_scr),
    .ifu_instr_valid_if3_i        (ifu_instr_valid_if3_i[1:0]),
    .ifu_early_two_valid_if3_i    (ifu_early_two_valid_if3_i),
    .ifu_instr0_if3_i             (ifu_instr0_if3_i[47:0]),
    .ifu_instr1_if3_i             (ifu_instr1_if3_i[47:0]),
    .paq_full_i                   (paq_full),
    .in_halt_i                    (in_halt),
    .spec_cpsr_mode_iss_i         (spec_cpsr_mode_iss[4:0]),
    .spec_cpsr_mode_usr_iss_i     (spec_cpsr_mode_usr_iss),
    .spec_cpsr_mode_sys_iss_i     (spec_cpsr_mode_sys_iss),
    .spec_cpsr_mode_mon_iss_i     (spec_cpsr_mode_mon_iss),
    .spec_cpsr_mode_hyp_iss_i     (spec_cpsr_mode_hyp_iss),
    .ns_state_de_i                (ns_state_de),
    .aarch64_state_i              (aarch64_state),
    .aarch64_at_el3_i             (aarch64_at_el[3]),
    .dpu_exception_level_i        (dpu_exception_level[1:0]),
    .isa_instr0_iss_i             (isa_instr0_iss[1:0]),
    .sctlr_sa_at_el_i             (sctlr_sa_at_el[3:0]),
    .instr0_de_pc_in_iss_i        (instr0_de_pc_in_iss),
    .prefetch_abort_iss_i         (prefetch_abort_iss),
    .slot1_branch_iss_i           (slot1_branch_iss),
    .size_instr0_iss_i            (size_instr0_iss),
    .size_instr1_iss_i            (size_instr1_iss),
    .size_instr1_ret_i            (size_instr1_ret),
    .valid_instrs_iss_i           (valid_instrs_iss[1:0]),
    .end_instr_iss_i              (end_instr_iss),
    .flush_wr_i                   (flush_wr),
    .expt_slot1_ret_i             (expt_slot1_ret),
    .forceop_valid_de_i           (forceop_valid_de),
    .forceop_valid_iss_i          (forceop_valid_iss),
    .insert_forceop_ret_i         (insert_forceop_ret),
    .forceop_type_i               (forceop_type[`CA53_FORCEOP_TYPE_W-1:0]),
    .forceop_offset_i             (forceop_offset[`CA53_FORCEOP_OFFSET_W-1:0]),
    .forceop_aa64_i               (forceop_aa64),
    .pc_instr0_iss_i              (pc_instr0_iss[63:0]),
    .pc_instr0_wr_i               (pc_instr0_wr[48:1]),
    .pc_instr0_ret_i              (pc_instr0_ret[63:0]),
    .thumb_instr0_iss_i           (thumb_instr0_iss),
    .thumb_instr0_ret_i           (thumb_instr0_ret),
    .thumb_instr1_ret_i           (thumb_instr1_ret),
    .tlb_d_tcr_el1_tbi_i          (tlb_d_tcr_el1_tbi_i[1:0]),
    .tlb_d_tcr_el2_tbi0_i         (tlb_d_tcr_el2_tbi0_i),
    .tlb_d_tcr_el3_tbi0_i         (tlb_d_tcr_el3_tbi0_i),
    .br_offset_iss_i              (br_offset_iss[27:1]),
    .btac_rtn_instr_iss_i         (btac_rtn_instr_iss),
    .tbit_btac_rtn_instr_iss_i    (tbit_btac_rtn_instr_iss),
    .taken_br_instr_iss_i         (taken_br_instr_iss),
    .br_x_bit_iss_i               (br_x_bit_iss),
    .rtn_addr_iss_i               (rtn_addr_iss[48:1]),
    .dpu_fe_valid_wr_i            (dpu_fe_valid_wr),
    .dpu_fe_valid_ret_i           (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_wr_i         (dpu_fe_addr_opa_wr[48:1]),
    .dpu_fe_addr_opb_wr_i         (dpu_fe_addr_opb_wr[27:1]),
    .dpu_fe_addr_opa_ret_i        (dpu_fe_addr_opa_ret[63:0]),
    .dpu_fe_addr_opb_ret_i        (dpu_fe_addr_opb_ret[17:1]),
    .disable_dual_issue_i         (disable_dual_issue),
    .disable_fp_dual_issue_i      (disable_fp_dual_issue),
    .force_clean_to_invalidate_i  (force_clean_to_invalidate),
    .cp_trap_fp_i                 (cp_trap_fp),
    .cp_trap_neon_i               (cp_trap_neon),
    .edecr_ss_reg_i               (edecr_ss_reg),
    .dbg_soft_step_active_i       (dbg_soft_step_active),
    .cpsr_tbit_wr_i               (cpsr_tbit_wr),
    .cpsr_tbit_ret_i              (cpsr_tbit_ret),
    .incr_pc_halt_mode_ret_i      (incr_pc_halt_mode_ret),
    .dbg_halt_ecc_expt_iss_i      (dbg_halt_ecc_expt_iss),
    .dpu_halt_ifu_i               (dpu_halt_ifu),
    .issue_to_iss_i               (issue_to_iss),
    .issue_to_iss_fpu_i           (issue_to_iss_fpu),
    .exception_valid_iss_i        (exception_valid_iss),
    .hcr_fb_i                     (hcr_fb),
    .hcr_bsu_i                    (hcr_bsu),
    .hcr_imo_i                    (hcr_imo),
    .hcr_fmo_i                    (hcr_fmo),
    .rf_wr_en_w0_iss_i            (rf_wr_en_w0_iss),
    .rf_wr_en_w1_iss_i            (rf_wr_en_w1_iss),
    .rf_wr_en_w2_iss_i            (rf_wr_en_w2_iss),
    .rf_wr_when_w0_iss_i          (rf_wr_when_w0_iss),
    .rf_wr_when_w1_iss_i          (rf_wr_when_w1_iss),
    .rf_wr_when_w2_iss_i          (rf_wr_when_w2_iss),
    .rf_wr_vaddr_w0_iss_i         (rf_wr_vaddr_w0_iss[4:0]),
    .rf_wr_vaddr_w1_iss_i         (rf_wr_vaddr_w1_iss[4:0]),
    .rf_wr_vaddr_w2_iss_i         (rf_wr_vaddr_w2_iss[4:0]),
    .rf_wr_en_w0_ex1_i            (rf_wr_en_w0_ex1),
    .rf_wr_en_w1_ex1_i            (rf_wr_en_w1_ex1),
    .rf_wr_en_w2_ex1_i            (rf_wr_en_w2_ex1),
    .rf_wr_when_w0_ex1_i          (rf_wr_when_w0_ex1),
    .rf_wr_when_w1_ex1_i          (rf_wr_when_w1_ex1),
    .rf_wr_when_w2_ex1_i          (rf_wr_when_w2_ex1),
    .rf_wr_vaddr_w0_ex1_i         (rf_wr_vaddr_w0_ex1[4:0]),
    .rf_wr_vaddr_w1_ex1_i         (rf_wr_vaddr_w1_ex1[4:0]),
    .rf_wr_vaddr_w2_ex1_i         (rf_wr_vaddr_w2_ex1[4:0]),
    .rf_wr_en_fw0_iss_i           (rf_wr_en_fw0_iss),
    .rf_wr_en_fw1_iss_i           (rf_wr_en_fw1_iss),
    .rf_wr_en_fw0_f1_i            (rf_wr_en_fw0_f1),
    .rf_wr_en_fw1_f1_i            (rf_wr_en_fw1_f1),
    .rf_wr_en_fw0_f2_i            (rf_wr_en_fw0_f2),
    .rf_wr_en_fw1_f2_i            (rf_wr_en_fw1_f2),
    .rf_wr_when_fw0_iss_i         (rf_wr_when_fw0_iss),
    .rf_wr_when_fw1_iss_i         (rf_wr_when_fw1_iss),
    .rf_wr_when_fw0_f1_i          (rf_wr_when_fw0_f1),
    .rf_wr_when_fw1_f1_i          (rf_wr_when_fw1_f1),
    .rf_wr_when_fw0_f2_i          (rf_wr_when_fw0_f2),
    .rf_wr_when_fw1_f2_i          (rf_wr_when_fw1_f2),
    .rf_wr_addr_fw0_iss_i         (rf_wr_addr_fw0_iss),
    .rf_wr_addr_fw1_iss_i         (rf_wr_addr_fw1_iss),
    .rf_wr_addr_fw0_f1_i          (rf_wr_addr_fw0_f1),
    .rf_wr_addr_fw1_f1_i          (rf_wr_addr_fw1_f1),
    .rf_wr_addr_fw0_f2_i          (rf_wr_addr_fw0_f2),
    .rf_wr_addr_fw1_f2_i          (rf_wr_addr_fw1_f2),
    .raw_imm_data_0_iss_i         (raw_imm_data_0_iss[20:0]),
    .raw_imm_data_1_iss_i         (raw_imm_data_1_iss[20:0]),
    .adrp_valid_iss_i             (adrp_valid_iss[1:0]),
    .second_x64_iss_i             (second_x64_iss),
    // Outputs
    .expt_instr_data_de_o         (expt_instr_data_de[`CA53_EXPT_INSTR_BUS_W-1:0]),
    .early_expt_enable_de_o       (early_expt_enable_de),
    .head_instr_de_o              (head_instr_de[1:0]),
    .end_instr_de_o               (end_instr_de),
    .first_cycle_ls_de_o          (first_cycle_ls_de),
    .psr_wr_operation_de_o        (psr_wr_operation_de),
    .psr_wr_en_de_o               (psr_wr_en_de),
    .psr_wr_src_de_o              (psr_wr_src_de),
    .use_ex1_alu_0_de_o           (use_ex1_alu_0_de),
    .use_ex1_alu_1_de_o           (use_ex1_alu_1_de),
    .alu0_valid_de_o              (alu0_valid_de),
    .alu1_valid_de_o              (alu1_valid_de),
    .alu0_pipectl_de_o            (alu0_pipectl_de[`CA53_ALU_PIPECTL_W-1:0]),
    .alu1_pipectl_de_o            (alu1_pipectl_de[`CA53_ALU_PIPECTL_W-1:0]),
    .mac_pipectl_de_o             (mac_pipectl_de[`CA53_MAC_PIPECTL_W-1:0]),
    .alu0_msk_data_sel_de_o       (alu0_msk_data_sel_de),
    .alu1_msk_data_sel_de_o       (alu1_msk_data_sel_de),
    .alu0_data_a_sel_de_o         (alu0_data_a_sel_de[`CA53_SEL_SHF_A_W-1:0]),
    .alu0_data_b_sel_de_o         (alu0_data_b_sel_de[`CA53_SEL_SHF_B_W-1:0]),
    .alu0_data_c_sel_de_o         (alu0_data_c_sel_de[`CA53_SEL_SHF_C_W-1:0]),
    .alu1_data_a_sel_de_o         (alu1_data_a_sel_de[`CA53_SEL_SHF_A_W-1:0]),
    .alu1_data_b_sel_de_o         (alu1_data_b_sel_de[`CA53_SEL_SHF_B_W-1:0]),
    .alu1_data_c_sel_de_o         (alu1_data_c_sel_de[`CA53_SEL_SHF_C_W-1:0]),
    .mac_data_a_sel_de_o          (mac_data_a_sel_de[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_de_o          (mac_data_b_sel_de[`CA53_SEL_MAC_B_W-1:0]),
    .div_data_a_sel_de_o          (div_data_a_sel_de[`CA53_SEL_DIV_A_W-1:0]),
    .div_data_b_sel_de_o          (div_data_b_sel_de[`CA53_SEL_DIV_B_W-1:0]),
    .mac_valid_de_o               (mac_valid_de),
    .mul_cpsr_nz_v_de_o           (mul_cpsr_nz_v_de),
    .div_valid_de_o               (div_valid_de),
    .ls_valid_de_o                (ls_valid_de),
    .ls_length_de_o               (ls_length_de[5:0]),
    .ls_store_de_o                (ls_store_de),
    .ls_store_neon_de_o           (ls_store_neon_de),
    .ls_size_de_o                 (ls_size_de[2:0]),
    .ls_elem_size_de_o            (ls_elem_size_de[2:0]),
    .ls_instr_type_de_o           (ls_instr_type_de[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_multiple_de_o             (ls_multiple_de),
    .ls_isv_set_de_o              (ls_isv_set_de),
    .ls_synd_sf_de_o              (ls_synd_sf_de),
    .ls_check_stack_de_o          (ls_check_stack_de),
    .cp_de_o                      (cp_de),
    .cp_op_de_o                   (cp_op_de),
    .cp_op_mva_de_o               (cp_op_mva_de),
    .cp_valid_de_o                (cp_valid_de),
    .cp_decode_de_o               (cp_decode_de[8:0]),
    .cp_op_ats1_de_o              (cp_op_ats1_de),
    .cp_other_sec_de_o            (cp_other_sec_de),
    .fp_serialise_de_o            (fp_serialise_de),
    .msr_mrs_reg_wr_de_o          (msr_mrs_reg_wr_de),
    .msr_mrs_spsr_de_o            (msr_mrs_spsr_de),
    .msr_mrs_data_de_o            (msr_mrs_data_de[5:0]),
    .force_usr_priv_mem_de_o      (force_usr_priv_mem_de),
    .str0_data_a_sel_de_o         (str0_data_a_sel_de[`CA53_SEL_STR_A_W-1:0]),
    .str0_data_b_sel_de_o         (str0_data_b_sel_de[`CA53_SEL_STR_B_W-1:0]),
    .str0_b_valid_de_o            (str0_b_valid_de),
    .ctl_64bit_op_str0_de_o       (ctl_64bit_op_str0_de),
    .str1_data_a_sel_de_o         (str1_data_a_sel_de[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_de_o         (str1_data_b_sel_de[`CA53_SEL_STR_B_W-1:0]),
    .str1_b_valid_de_o            (str1_b_valid_de),
    .ctl_64bit_op_str1_de_o       (ctl_64bit_op_str1_de),
    .agu_shf_value_de_o           (agu_shf_value_de[2:0]),
    .agu_data_a_sel_de_o          (agu_data_a_sel_de[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_de_o          (agu_data_b_sel_de[`CA53_SEL_DCU_B_W-1:0]),
    .agu_sub_b_de_o               (agu_sub_b_de),
    .valid_instrs_de_o            (valid_instrs_de[1:0]),
    .size_instr0_de_o             (size_instr0_de),
    .size_instr1_de_o             (size_instr1_de),
    .thumb_instr0_de_o            (thumb_instr0_de),
    .thumb_instr1_de_o            (thumb_instr1_de),
    .cond_code_instr0_de_o        (cond_code_instr0_de[3:0]),
    .cond_code_instr1_de_o        (cond_code_instr1_de[3:0]),
    .pc_instr0_de_o               (pc_instr0_de[63:0]),
    .mod_pc_top_bits_de_o         (mod_pc_top_bits_de),
    .no_insert_de_o               (no_insert_de),
    .enable_base_restore_de_o     (enable_base_restore_de),
    .usr_mode_regs_ldm_de_o       (usr_mode_regs_ldm_de),
    .no_interrupt_de_o            (no_interrupt_de),
    .rf_wr_mode_de_o              (rf_wr_mode_de[4:0]),
    .rf_rd_addr_r0_de_o           (rf_rd_addr_r0_de[5:0]),
    .rf_rd_addr_r1_de_o           (rf_rd_addr_r1_de[5:0]),
    .rf_rd_addr_r2_de_o           (rf_rd_addr_r2_de[5:0]),
    .rf_rd_addr_r3_de_o           (rf_rd_addr_r3_de[5:0]),
    .rf_rd_addr_r4_de_o           (rf_rd_addr_r4_de[5:0]),
    .rf_stm_rd_addr_r2_de_o       (rf_stm_rd_addr_r2_de[5:0]),
    .rf_stm_rd_addr_r3_de_o       (rf_stm_rd_addr_r3_de[5:0]),
    .instr0_r2_enabled_de_o       (instr0_r2_enabled_de),
    .instr0_w0_enabled_de_o       (instr0_w0_enabled_de),
    .long_rf_rd_addr_r0_de_o      (long_rf_rd_addr_r0_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r1_de_o      (long_rf_rd_addr_r1_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r0_agu_de_o       (rf_rd_addr_r0_agu_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r1_agu_de_o       (rf_rd_addr_r1_agu_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_r0_for_fwd_check_de_o     (rf_r0_for_fwd_check_de[5:0]),
    .rf_r1_for_fwd_check_de_o     (rf_r1_for_fwd_check_de[5:0]),
    .rf_rd_en_r4_de_o             (rf_rd_en_r4_de),
    .rf_rd_en_r3_de_o             (rf_rd_en_r3_de),
    .rf_rd_en_r2_de_o             (rf_rd_en_r2_de),
    .rf_rd_en_r1_de_o             (rf_rd_en_r1_de),
    .rf_rd_en_r0_de_o             (rf_rd_en_r0_de),
    .rf_rd_need_r4_de_o           (rf_rd_need_r4_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r3_de_o           (rf_rd_need_r3_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r2_de_o           (rf_rd_need_r2_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r1_de_o           (rf_rd_need_r1_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r0_de_o           (rf_rd_need_r0_de[(`CA53_RF_RD_NEED_W-1):0]),
    .slot1_instr_type_de_o        (slot1_instr_type_de[(`CA53_SLOT1_INSTR_TYPE_W-1):0]),
    .rf_rd_remap_de_o             (rf_rd_remap_de),
    .wd_align_pc_alu0_de_o        (wd_align_pc_alu0_de),
    .wd_align_pc_alu1_de_o        (wd_align_pc_alu1_de),
    .wd_align_pc_ls_de_o          (wd_align_pc_ls_de),
    .pg_align_pc_ls_de_o          (pg_align_pc_ls_de),
    .rf_wr_vaddr_w0_de_o          (rf_wr_vaddr_w0_de[4:0]),
    .rf_wr_vaddr_w1_de_o          (rf_wr_vaddr_w1_de[4:0]),
    .rf_wr_vaddr_w2_de_o          (rf_wr_vaddr_w2_de[4:0]),
    .rf_wr_src_w0_de_o            (rf_wr_src_w0_de[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_de_o            (rf_wr_src_w1_de[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_src_w2_de_o            (rf_wr_src_w2_de[`CA53_RF_WR_SRC_W2_W-1:0]),
    .rf_wr_en_w0_de_o             (rf_wr_en_w0_de),
    .rf_wr_en_w1_de_o             (rf_wr_en_w1_de),
    .rf_wr_en_w2_de_o             (rf_wr_en_w2_de),
    .rf_wr_64b_w0_de_o            (rf_wr_64b_w0_de),
    .rf_wr_64b_w1_de_o            (rf_wr_64b_w1_de),
    .rf_wr_64b_w2_de_o            (rf_wr_64b_w2_de),
    .rf_wr_when_w0_de_o           (rf_wr_when_w0_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_wr_when_w1_de_o           (rf_wr_when_w1_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_wr_when_w2_de_o           (rf_wr_when_w2_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_rd_addr_fr0_de_o          (rf_rd_addr_fr0_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr1_de_o          (rf_rd_addr_fr1_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr2_de_o          (rf_rd_addr_fr2_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr3_de_o          (rf_rd_addr_fr3_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr4_de_o          (rf_rd_addr_fr4_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr5_de_o          (rf_rd_addr_fr5_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_en_fr0_de_o            (rf_rd_en_fr0_de),
    .rf_rd_en_fr1_de_o            (rf_rd_en_fr1_de),
    .rf_rd_en_fr2_de_o            (rf_rd_en_fr2_de),
    .rf_rd_en_fr3_de_o            (rf_rd_en_fr3_de),
    .rf_rd_en_fr4_de_o            (rf_rd_en_fr4_de),
    .rf_rd_en_fr5_de_o            (rf_rd_en_fr5_de),
    .rf_rd_need_fr0_de_o          (rf_rd_need_fr0_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr1_de_o          (rf_rd_need_fr1_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr2_de_o          (rf_rd_need_fr2_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr3_de_o          (rf_rd_need_fr3_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr4_de_o          (rf_rd_need_fr4_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr5_de_o          (rf_rd_need_fr5_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_wr_addr_fw0_de_o          (rf_wr_addr_fw0_de[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .rf_wr_addr_fw1_de_o          (rf_wr_addr_fw1_de[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .rf_wr_en_fw0_de_o            (rf_wr_en_fw0_de),
    .rf_wr_en_fw1_de_o            (rf_wr_en_fw1_de),
    .rf_wr_src_fw0_de_o           (rf_wr_src_fw0_de[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_de_o           (rf_wr_src_fw1_de[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_de_o          (rf_wr_when_fw0_de[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_when_fw1_de_o          (rf_wr_when_fw1_de[`CA53_RF_FWR_WHEN_W-1:0]),
    .fp_ex_pipe_de_o              (fp_ex_pipe_de),
    .crypto_enable_de_o           (crypto_enable_de),
    .fp0_pipectl_iss_o            (fp0_pipectl_iss[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_iss_o            (fp1_pipectl_iss[`CA53_FP_PIPECTL_W-1:0]),
    .sel_fad0_a_iss_o             (sel_fad0_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad0_b_iss_o             (sel_fad0_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad0_c_iss_o             (sel_fad0_c_iss[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fad1_a_iss_o             (sel_fad1_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_b_iss_o             (sel_fad1_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad1_c_iss_o             (sel_fad1_c_iss[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fml0_a_iss_o             (sel_fml0_a_iss),
    .sel_fml0_b_iss_o             (sel_fml0_b_iss[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml0_c_iss_o             (sel_fml0_c_iss),
    .sel_fml1_a_iss_o             (sel_fml1_a_iss),
    .sel_fml1_b_iss_o             (sel_fml1_b_iss[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml1_c_iss_o             (sel_fml1_c_iss),
    .br_valid_de_o                (br_valid_de),
    .dpu_pred_br_de_o             (dpu_pred_br_de),
    .dpu_br_return_de_o           (dpu_br_return_de),
    .dpu_br_call_de_o             (dpu_br_call_de),
    .br_btac_de_o                 (br_btac_de),
    .br_pipectl_de_o              (br_pipectl_de[(`CA53_BR_PIPECTL_W-1):0]),
    .br_pred_takenness_de_o       (br_pred_takenness_de),
    .br_offset_de_o               (br_offset_de[27:1]),
    .br_x_bit_de_o                (br_x_bit_de),
    .rtn_addr_valid_de_o          (rtn_addr_valid_de),
    .t16o_it_cpsr_mask_de_o       (t16o_it_cpsr_mask_de[7:0]),
    .t16o_it_cpsr_valid_de_o      (t16o_it_cpsr_valid_de),
    .cpsr_ebit_value_de_o         (cpsr_ebit_value_de),
    .cpsr_aifbits_val_o           (cpsr_aifbits_val[5:0]),
    .instr_type_de_o              (instr_type_de[(`CA53_INSTR_TYPE_W-1):0]),
    .expt_instr_type_de_o         (expt_instr_type_de[(`CA53_EXPT_INSTR_TYPE_W-1):0]),
    .skid_x64_multiple_de_o       (skid_x64_multiple_de),
    .str0_valid_de_o              (str0_valid_de),
    .str1_valid_de_o              (str1_valid_de),
    .imm_data_0_de_o              (imm_data_0_de[(`CA53_IMM_DATA_W-1):0]),
    .imm_data_1_de_o              (imm_data_1_de[(`CA53_IMM_DATA_W-1):0]),
    .imm_data_ls_de_o             (imm_data_ls_de[32:0]),
    .imm_shift_0_de_o             (imm_shift_0_de[(`CA53_IMM_SHIFT_W-1):0]),
    .imm_shift_1_de_o             (imm_shift_1_de[(`CA53_IMM_SHIFT_W-1):0]),
    .imm_data_sel_0_de_o          (imm_data_sel_0_de[(`CA53_IMM_SEL_W-1):0]),
    .imm_data_sel_1_de_o          (imm_data_sel_1_de[(`CA53_IMM_SEL_W-1):0]),
    .req_strict_algn_de_o         (req_strict_algn_de),
    .check_x64_de_o               (check_x64_de),
    .algn_size_de_o               (algn_size_de[2:0]),
    .iq_instr_is_fn_o             (iq_instr_is_fn[1:0]),
    .instr_is_cp10_cp11_de_o      (instr_is_cp10_cp11_de),
    .slot1_ls_de_o                (slot1_ls_de),
    .instr_fmstat_de_o            (instr_fmstat_de[1:0]),
    .fmac_valid_sp_de_o           (fmac_valid_sp_de[1:0]),
    .fdiv_valid_de_o              (fdiv_valid_de[1:0]),
    .neon_can_fwd_acc_de_o        (neon_can_fwd_acc_de[1:0]),
    .neon_vld_ctl_de_o            (neon_vld_ctl_de[`CA53_NEON_VLD_CTL_W-1:0]),
    .fp0_cflag_src_iss_o          (fp0_cflag_src_iss[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp1_cflag_src_iss_o          (fp1_cflag_src_iss[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp0_xflag_src_iss_o          (fp0_xflag_src_iss[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp1_xflag_src_iss_o          (fp1_xflag_src_iss[`CA53_FP_XFLAG_SRC_W-1:0]),
    .dpu_iq_full_o                (dpu_iq_full_o),
    .dpu_iq_part_full_o           (dpu_iq_part_full_o),
    .aarch64_state_ext_o          (aarch64_state_ext),
    .flag_en_instr1_de_o          (flag_en_instr1_de[(`CA53_FLAGEN_INSTR1_W-1):0]),
    .ls_synd_srt_de_o             (ls_synd_srt_de[4:0]),
    .neon_de_active_o             (neon_de_active),
    .evnt_iq_empty_o              (evnt_iq_empty),
    .neon_instr_iss_o             (neon_instr_iss[1:0])
    );

  assign cpsr_mode_ret = cpsr_ret[4:0];

  // The CPU is in AArch64 if bit [4] of the mode is zero
  assign aarch64_state = ~spec_cpsr_mode_iss[4];

  // ------------------------------------------------------
  // Control
  // ------------------------------------------------------

  ca53dpu_ctl `CA53_DPU_PARAM_INST u_dpu_ctl (
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .DFTSE                            (DFTSE),
    .aarch64_state_i                  (aarch64_state),
    .rvbaraddr_i                      (rvbaraddr[39:2]),
    .dpu_exception_level_i            (dpu_exception_level[1:0]),
    .gov_stall_neon_i                 (gov_stall_neon_i),
    .etm_stall_cpu_i                  (etm_stall_cpu_i),
    .muls_in_de_i                     (mul_cpsr_nz_v_de),
    .dbg_hw_halt_req_i                (dbg_hw_halt_req),
    .in_halt_i                        (in_halt),
    .held_dbg_hw_halt_req_i           (held_dbg_hw_halt_req),
    .held_dbg_osuc_halt_req_i         (held_dbg_osuc_halt_req),
    .held_dbg_ext_hw_halt_req_i       (held_dbg_ext_hw_halt_req),
    .dbg_soft_step_active_i           (dbg_soft_step_active),
    .dbg_halt_step_active_not_pend_i  (dbg_halt_step_active_not_pend),
    .dbg_restart_qual_i               (dbg_restart_qual),
    .ss_enter_halt_i                  (ss_enter_halt),
    .dbg_cancel_biu_i                 (dbg_cancel_biu),
    .head_instr_de_i                  (head_instr_de[1:0]),
    .end_instr_de_i                   (end_instr_de),
    .first_cycle_ls_de_i              (first_cycle_ls_de),
    .valid_instrs_de_i                (valid_instrs_de[1:0]),
    .size_instr0_de_i                 (size_instr0_de),
    .size_instr1_de_i                 (size_instr1_de),
    .thumb_instr0_de_i                (thumb_instr0_de),
    .thumb_instr1_de_i                (thumb_instr1_de),
    .pc_instr0_de_i                   (pc_instr0_de[63:0]),
    .mod_pc_top_bits_de_i             (mod_pc_top_bits_de),
    .no_insert_de_i                   (no_insert_de),
    .dcu_not_ready_iss_i              (dcu_not_ready_iss),
    .first_lsm_skidding_i             (first_lsm_skidding),
    .inter_lsm_skidding_i             (inter_lsm_skidding),
    .lsm_skidding_i                   (lsm_skidding),
    .lsm_64b_be_i                     (lsm_64b_be),
    .lsm_64b_be_skidding_i            (lsm_64b_be_skidding),
    .lsm_n64b_be_skidding_i           (lsm_n64b_be_skidding),
    .last_lsm_skidding_i              (last_lsm_skidding),
    .force_extra_lsm_cycle_i          (force_extra_lsm_cycle),
    .extra_lsm_cycle_i                (extra_lsm_cycle),
    .ls_128b_be_i                     (ls_128b_be),
    .ldr_no_early_fwd_iss_i           (ldr_no_early_fwd_iss),
    .enable_base_restore_iss_i        (enable_base_restore_iss),
    .ls_instr_type_wr_i               (ls_instr_type_wr[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_store_wr_i                    (ls_store_wr),
    .ls_isv_set_wr_i                  (ls_isv_set_wr),
    .ls_synd_sf_wr_i                  (ls_synd_sf_wr),
    .ls_synd_srt_wr_i                 (ls_synd_srt_wr[4:0]),
    .ls_stall_wr_i                    (ls_stall_wr),
    .ls_valid_wr_i                    (ls_valid_wr),
    .first_x64_iss_i                  (first_x64_iss),
    .second_x64_iss_i                 (second_x64_iss),
    .agu_data_a_sel_iss_i             (agu_data_a_sel_iss[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_iss_i             (agu_data_b_sel_iss[`CA53_SEL_DCU_B_W-1:0]),
    .usr_mode_regs_ldm_de_i           (usr_mode_regs_ldm_de),
    .rf_r0_for_fwd_check_de_i         (rf_r0_for_fwd_check_de[5:0]),
    .rf_r1_for_fwd_check_de_i         (rf_r1_for_fwd_check_de[5:0]),
    .no_interrupt_de_i                (no_interrupt_de),
    .rf_wr_mode_de_i                  (rf_wr_mode_de[4:0]),
    .rf_wr_en_w0_de_i                 (rf_wr_en_w0_de),
    .rf_wr_en_w1_de_i                 (rf_wr_en_w1_de),
    .rf_wr_en_w2_de_i                 (rf_wr_en_w2_de),
    .rf_wr_64b_w0_de_i                (rf_wr_64b_w0_de),
    .rf_wr_64b_w1_de_i                (rf_wr_64b_w1_de),
    .rf_wr_64b_w2_de_i                (rf_wr_64b_w2_de),
    .rf_wr_vaddr_w0_de_i              (rf_wr_vaddr_w0_de[4:0]),
    .rf_wr_vaddr_w1_de_i              (rf_wr_vaddr_w1_de[4:0]),
    .rf_wr_vaddr_w2_de_i              (rf_wr_vaddr_w2_de[4:0]),
    .rf_wr_src_w0_de_i                (rf_wr_src_w0_de[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_de_i                (rf_wr_src_w1_de[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_src_w2_de_i                (rf_wr_src_w2_de[`CA53_RF_WR_SRC_W2_W-1:0]),
    .rf_rd_addr_fr0_de_i              (rf_rd_addr_fr0_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr1_de_i              (rf_rd_addr_fr1_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr2_de_i              (rf_rd_addr_fr2_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr3_de_i              (rf_rd_addr_fr3_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr4_de_i              (rf_rd_addr_fr4_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr5_de_i              (rf_rd_addr_fr5_de[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_en_fr0_de_i                (rf_rd_en_fr0_de),
    .rf_rd_en_fr1_de_i                (rf_rd_en_fr1_de),
    .rf_rd_en_fr2_de_i                (rf_rd_en_fr2_de),
    .rf_rd_en_fr3_de_i                (rf_rd_en_fr3_de),
    .rf_rd_en_fr4_de_i                (rf_rd_en_fr4_de),
    .rf_rd_en_fr5_de_i                (rf_rd_en_fr5_de),
    .rf_rd_need_fr0_de_i              (rf_rd_need_fr0_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr1_de_i              (rf_rd_need_fr1_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr2_de_i              (rf_rd_need_fr2_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr3_de_i              (rf_rd_need_fr3_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr4_de_i              (rf_rd_need_fr4_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_rd_need_fr5_de_i              (rf_rd_need_fr5_de[(`CA53_RF_FRD_NEED_W-1):0]),
    .rf_wr_addr_fw0_de_i              (rf_wr_addr_fw0_de[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .rf_wr_addr_fw1_de_i              (rf_wr_addr_fw1_de[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .rf_wr_en_fw0_de_i                (rf_wr_en_fw0_de),
    .rf_wr_en_fw1_de_i                (rf_wr_en_fw1_de),
    .rf_wr_src_fw0_de_i               (rf_wr_src_fw0_de[(`CA53_RF_FWR_SRC_W-1):0]),
    .rf_wr_src_fw1_de_i               (rf_wr_src_fw1_de[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_de_i              (rf_wr_when_fw0_de[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_when_fw1_de_i              (rf_wr_when_fw1_de[`CA53_RF_FWR_WHEN_W-1:0]),
    .fp_ex_pipe_de_i                  (fp_ex_pipe_de),
    .crypto_enable_de_i               (crypto_enable_de),
    .instr_fmstat_de_i                (instr_fmstat_de[1:0]),
    .fmac_valid_sp_de_i               (fmac_valid_sp_de[1:0]),
    .fdiv_valid_de_i                  (fdiv_valid_de[1:0]),
    .neon_can_fwd_acc_de_i            (neon_can_fwd_acc_de[1:0]),
    .neon_vld_ctl_de_i                (neon_vld_ctl_de[`CA53_NEON_VLD_CTL_W-1:0]),
    .fp0_pipectl_iss_i                (fp0_pipectl_iss[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_iss_i                (fp1_pipectl_iss[`CA53_FP_PIPECTL_W-1:0]),
    .sel_fad0_a_iss_i                 (sel_fad0_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad0_b_iss_i                 (sel_fad0_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad0_c_iss_i                 (sel_fad0_c_iss[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fad1_a_iss_i                 (sel_fad1_a_iss[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_b_iss_i                 (sel_fad1_b_iss[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad1_c_iss_i                 (sel_fad1_c_iss[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fml0_a_iss_i                 (sel_fml0_a_iss),
    .sel_fml0_b_iss_i                 (sel_fml0_b_iss[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml0_c_iss_i                 (sel_fml0_c_iss),
    .sel_fml1_a_iss_i                 (sel_fml1_a_iss),
    .sel_fml1_b_iss_i                 (sel_fml1_b_iss[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml1_c_iss_i                 (sel_fml1_c_iss),
    .fp_serialize_iss_i               (fp_serialize_iss),
    .iq_instr_is_fn_i                 (iq_instr_is_fn[1:0]),
    .instr_is_cp10_cp11_de_i          (instr_is_cp10_cp11_de),
    .fp0_cflag_src_iss_i              (fp0_cflag_src_iss[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp1_cflag_src_iss_i              (fp1_cflag_src_iss[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp0_xflag_src_iss_i              (fp0_xflag_src_iss[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp1_xflag_src_iss_i              (fp1_xflag_src_iss[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp_div_busy_nxt_cyc_i            (fp_div_busy_nxt_cyc[1:0]),
    .neon_de_active_i                 (neon_de_active),
    .cond_code_instr0_de_i            (cond_code_instr0_de[3:0]),
    .cond_code_instr1_de_i            (cond_code_instr1_de[3:0]),
    .alu0_pipectl_de_i                (alu0_pipectl_de[`CA53_ALU_PIPECTL_W-1:0]),
    .alu1_pipectl_de_i                (alu1_pipectl_de[`CA53_ALU_PIPECTL_W-1:0]),
    .mac_pipectl_de_i                 (mac_pipectl_de[`CA53_MAC_PIPECTL_W-1:0]),
    .alu0_msk_data_sel_de_i           (alu0_msk_data_sel_de),
    .alu1_msk_data_sel_de_i           (alu1_msk_data_sel_de),
    .alu0_data_a_sel_de_i             (alu0_data_a_sel_de[`CA53_SEL_SHF_A_W-1:0]),
    .alu0_data_b_sel_de_i             (alu0_data_b_sel_de[`CA53_SEL_SHF_B_W-1:0]),
    .alu0_data_c_sel_de_i             (alu0_data_c_sel_de[`CA53_SEL_SHF_C_W-1:0]),
    .mac_data_a_sel_de_i              (mac_data_a_sel_de[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_de_i              (mac_data_b_sel_de[`CA53_SEL_MAC_B_W-1:0]),
    .div_data_a_sel_de_i              (div_data_a_sel_de[`CA53_SEL_DIV_A_W-1:0]),
    .div_data_b_sel_de_i              (div_data_b_sel_de[`CA53_SEL_DIV_B_W-1:0]),
    .alu1_data_a_sel_de_i             (alu1_data_a_sel_de[`CA53_SEL_SHF_A_W-1:0]),
    .alu1_data_b_sel_de_i             (alu1_data_b_sel_de[`CA53_SEL_SHF_B_W-1:0]),
    .alu1_data_c_sel_de_i             (alu1_data_c_sel_de[`CA53_SEL_SHF_C_W-1:0]),
    .str0_data_a_sel_de_i             (str0_data_a_sel_de[`CA53_SEL_STR_A_W-1:0]),
    .str0_data_b_sel_de_i             (str0_data_b_sel_de[`CA53_SEL_STR_B_W-1:0]),
    .str0_b_valid_de_i                (str0_b_valid_de),
    .ctl_64bit_op_str0_de_i           (ctl_64bit_op_str0_de),
    .str1_data_a_sel_de_i             (str1_data_a_sel_de[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_de_i             (str1_data_b_sel_de[`CA53_SEL_STR_B_W-1:0]),
    .str1_b_valid_de_i                (str1_b_valid_de),
    .ctl_64bit_op_str1_de_i           (ctl_64bit_op_str1_de),
    .use_ex1_alu_0_de_i               (use_ex1_alu_0_de),
    .use_ex1_alu_1_de_i               (use_ex1_alu_1_de),
    .alu0_valid_de_i                  (alu0_valid_de),
    .alu1_valid_de_i                  (alu1_valid_de),
    .str0_valid_de_i                  (str0_valid_de),
    .str1_valid_de_i                  (str1_valid_de),
    .mac_valid_de_i                   (mac_valid_de),
    .ls_valid_de_i                    (ls_valid_de),
    .cp_de_i                          (cp_de),
    .div_valid_de_i                   (div_valid_de),
    .div_busy_iss_i                   (div_busy_iss),
    .nxt_div_busy_wr_i                (nxt_div_busy_wr),
    .instr_type_de_i                  (instr_type_de[(`CA53_INSTR_TYPE_W-1):0]),
    .expt_instr_type_de_i             (expt_instr_type_de[(`CA53_EXPT_INSTR_TYPE_W-1):0]),
    .expt_instr_data_de_i             (expt_instr_data_de[`CA53_EXPT_INSTR_BUS_W-1:0]),
    .early_expt_enable_de_i           (early_expt_enable_de),
    .expt_cpacr_el1_fpen_i            (expt_cpacr_el1_fpen[1:0]),
    .expt_cpacr_asedis_i              (expt_cpacr_asedis),
    .expt_cptr_el2_tfp_i              (expt_cptr_el2_tfp),
    .expt_hcptr_tase_i                (expt_hcptr_tase),
    .expt_cptr_el2_tcpac_i            (expt_cptr_el2_tcpac),
    .rf_rd_need_r0_de_i               (rf_rd_need_r0_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r1_de_i               (rf_rd_need_r1_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r2_de_i               (rf_rd_need_r2_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r3_de_i               (rf_rd_need_r3_de[(`CA53_RF_RD_NEED_W-1):0]),
    .rf_rd_need_r4_de_i               (rf_rd_need_r4_de[(`CA53_RF_RD_NEED_W-1):0]),
    .slot1_instr_type_de_i            (slot1_instr_type_de[(`CA53_SLOT1_INSTR_TYPE_W-1):0]),
    .rf_rd_remap_de_i                 (rf_rd_remap_de),
    .rf_wr_when_w0_de_i               (rf_wr_when_w0_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_wr_when_w1_de_i               (rf_wr_when_w1_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_wr_when_w2_de_i               (rf_wr_when_w2_de[(`CA53_RF_WR_WHEN_W-1):0]),
    .rf_rd_addr_r0_de_i               (rf_rd_addr_r0_de[5:0]),
    .rf_rd_addr_r1_de_i               (rf_rd_addr_r1_de[5:0]),
    .rf_rd_addr_r2_de_i               (rf_rd_addr_r2_de[5:0]),
    .rf_rd_addr_r3_de_i               (rf_rd_addr_r3_de[5:0]),
    .rf_rd_addr_r4_de_i               (rf_rd_addr_r4_de[5:0]),
    .rf_stm_rd_addr_r2_de_i           (rf_stm_rd_addr_r2_de[5:0]),
    .rf_stm_rd_addr_r3_de_i           (rf_stm_rd_addr_r3_de[5:0]),
    .rf_rd_en_r0_de_i                 (rf_rd_en_r0_de),
    .rf_rd_en_r1_de_i                 (rf_rd_en_r1_de),
    .rf_rd_en_r2_de_i                 (rf_rd_en_r2_de),
    .rf_rd_en_r3_de_i                 (rf_rd_en_r3_de),
    .rf_rd_en_r4_de_i                 (rf_rd_en_r4_de),
    .instr0_r2_enabled_de_i           (instr0_r2_enabled_de),
    .instr0_w0_enabled_de_i           (instr0_w0_enabled_de),
    .wd_align_pc_alu0_de_i            (wd_align_pc_alu0_de),
    .wd_align_pc_alu1_de_i            (wd_align_pc_alu1_de),
    .wd_align_pc_ls_de_i              (wd_align_pc_ls_de),
    .pg_align_pc_ls_de_i              (pg_align_pc_ls_de),
    .expt_rtn_ret_i                   (expt_rtn_ret),
    .cpsr_ssbit_ret_i                 (cpsr_ssbit_ret),
    .cpsr_ilbit_ret_i                 (cpsr_ilbit_ret),
    .cpsr_ibit_ret_i                  (cpsr_ibit_ret),
    .cpsr_fbit_ret_i                  (cpsr_fbit_ret),
    .cpsr_abit_ret_i                  (cpsr_abit_ret),
    .cpsr_mode_ret_i                  (cpsr_mode_ret[4:0]),
    .cc_pass_instr0_ex2_i             (cc_pass_instr0_ex2),
    .cc_pass_instr0_cbz_ex2_i         (cc_pass_instr0_cbz_ex2),
    .cc_pass_instr1_ex2_i             (cc_pass_instr1_ex2),
    .cc_pass_instr1_early_ex2_i       (cc_pass_instr1_early_ex2),
    .fp0_ccmp_fail_ex2_i              (fp0_ccmp_fail_ex2),
    .fp1_ccmp_fail_ex2_i              (fp1_ccmp_fail_ex2),
    .fp_cflags_add0_f2_i              (fp_cflags_add0_f2[3:0]),
    .fp_cflags_add1_f2_i              (fp_cflags_add1_f2[3:0]),
    .cp_fpsr_cflags_i                 (cp_fpsr_cflags),
    .br_flush_wr_i                    (br_flush_wr),
    .slot0_br_flush_wr_i              (slot0_br_flush_wr),
    .br_flush_ret_i                   (br_flush_ret),
    .sctlr_ns_hivecs_i                (sctlr_ns_hivecs),
    .sctlr_s_hivecs_i                 (sctlr_s_hivecs),
    .sctlr_ntwe_i                     (sctlr_ntwe),
    .sctlr_ntwi_i                     (sctlr_ntwi),
    .sctlr_cp15ben_i                  (sctlr_cp15ben),
    .sctlr_sed_i                      (sctlr_sed),
    .sctlr_el1_uci_i                  (sctlr_el1_uci),
    .sctlr_el1_uct_i                  (sctlr_el1_uct),
    .sctlr_el1_uma_i                  (sctlr_el1_uma),
    .sctlr_el1_dze_i                  (sctlr_el1_dze),
    .aarch64_at_el_i                  (aarch64_at_el[3:1]),
    .dbgdscr_halted_i                 (dbgdscr_halted),
    .edscr_intdis_i                   (edscr_intdis[1:0]),
    .dbgen_synced_i                   (dbgen_synced),
    .spiden_synced_i                  (spiden_synced),
    .dbg_hlt_en_i                     (dbg_hlt_en),
    .dbg_bkpt_wpt_en_i                (dbg_bkpt_wpt_en),
    .gov_wfx_wake_i                   (gov_wfx_wake_i),
    .gic_fiq_i                        (gic_fiq_i),
    .gic_irq_i                        (gic_irq_i),
    .gic_vfiq_i                       (gic_vfiq_i),
    .gic_virq_i                       (gic_virq_i),
    .gov_sei_level_req_i              (gov_sei_level_req_i),
    .gov_vsei_level_req_i             (gov_vsei_level_req_i),
    .gov_rei_level_req_i              (gov_rei_level_req_i),
    .gov_int_active_i                 (gov_int_active_i),
    .dcu_valid_dc3_i                  (dcu_valid_dc3_i),
    .dcu_p_abort_dc3_i                (dcu_p_abort_dc3_i),
    .dcu_p_domain_dc3_i               (dcu_p_domain_dc3_i[3:0]),
    .dcu_p_fault_dc3_i                (dcu_p_fault_dc3_i[6:0]),
    .dcu_p_fault_stage_dc3_i          (dcu_p_fault_stage_dc3_i[1:0]),
    .dcu_p_direction_dc3_i            (dcu_p_direction_dc3_i),
    .dcu_ecc_err_dc3_i                (dcu_ecc_err_dc3_i),
    .dcu_pa_dc3_i                     (dcu_pa_dc3_i[39:12]),
    .dcu_cm_operation_dc3_i           (dcu_cm_operation_dc3_i),
    .dcu_v2p_lpae_dc3_i               (dcu_v2p_lpae_dc3_i),
    .dcu_wpt_hit_dc3_i                (dcu_wpt_hit_dc3_i),
    .tlb_lpae_mode_i                  (tlb_lpae_mode_i),
    .tlb_lpae_mode_s_i                (tlb_lpae_mode_s_i),
    .biu_w_imp_abort_i                (biu_w_imp_abort_i),
    .biu_w_imp_fault_i                (biu_w_imp_fault_i[1:0]),
    .dpu_fe_valid_wr_i                (dpu_fe_valid_wr),
    .dpu_fe_valid_ret_i               (dpu_fe_valid_ret),
    .incr_pc_halt_mode_ret_i          (incr_pc_halt_mode_ret),
    .paq_stall_iss_i                  (paq_stall_iss),
    .br_x_bit_de_i                    (br_x_bit_de),
    .ls_multiple_de_i                 (ls_multiple_de),
    .ls_multiple_iss_i                (ls_multiple_iss),
    .ls_store_iss_i                   (ls_store_iss),
    .ls_valid_iss_i                   (ls_valid_iss),
    .ls_valid_ex1_i                   (ls_valid_ex1),
    .ls_size_wr_i                     (ls_size_wr[1:0]),
    .mac_stall_iss_i                  (mac_stall_iss),
    .cp_vbar_el3_i                    (cp_vbar_el3[63:5]),
    .cp_vbar_el1_i                    (cp_vbar_el1[63:5]),
    .cp_mvbar_i                       (cp_mvbar[31:5]),
    .cp_hvbar_i                       (cp_hvbar[63:5]),
    .pmn_useren_i                     (pmn_useren[3:0]),
    .mdscr_el1_tdcc_i                 (mdscr_el1_tdcc),
    .hdcr_tdra_i                      (hdcr_tdra),
    .hdcr_tdosa_i                     (hdcr_tdosa),
    .hdcr_tda_i                       (hdcr_tda),
    .hdcr_tde_i                       (hdcr_tde),
    .hdcr_tpm_i                       (hdcr_tpm),
    .hdcr_tpmcr_i                     (hdcr_tpmcr),
    .mdcr_el3_tdosa_i                 (mdcr_el3_tdosa),
    .mdcr_el3_tda_i                   (mdcr_el3_tda),
    .mdcr_el3_tpm_i                   (mdcr_el3_tpm),
    .hcr_twi_i                        (hcr_twi),
    .hcr_twe_i                        (hcr_twe),
    .hcr_trvm_i                       (hcr_trvm),
    .hcr_tdz_i                        (hcr_tdz),
    .cptr_el3_tcpac_i                 (cptr_el3_tcpac),
    .cptr_el3_tfp_i                   (cptr_el3_tfp),
    .scr_el3_twi_i                    (scr_twi),
    .scr_el3_twe_i                    (scr_twe),
    .scr_el3_st_i                     (scr_st),
    .scr_el3_hce_i                    (scr_hce),
    .scr_el3_smd_i                    (scr_smd),
    .hstr_trap_cp15_i                 (hstr_trap_cp15[13:0]),
    .cpuactlr_el3_i                   (cpuactlr_el3),
    .cpuectlr_el3_i                   (cpuectlr_el3),
    .l2ctlr_el3_i                     (l2ctlr_el3),
    .l2ectlr_el3_i                    (l2ectlr_el3),
    .l2actlr_el3_i                    (l2actlr_el3),
    .cpuactlr_el2_i                   (cpuactlr_el2),
    .cpuectlr_el2_i                   (cpuectlr_el2),
    .l2ctlr_el2_i                     (l2ctlr_el2),
    .l2ectlr_el2_i                    (l2ectlr_el2),
    .l2actlr_el2_i                    (l2actlr_el2),
    .gov_cntkctl_el1_el0pcten_i       (gov_pcnt_usr_access_i),
    .gov_cntkctl_el1_el0vcten_i       (gov_vcnt_usr_access_i),
    .gov_cntkctl_el1_el0pten_i        (gov_cntp_usr_access_i),
    .gov_cntkctl_el1_el0vten_i        (gov_cntv_usr_access_i),
    .gov_cnthctl_el2_el1pcen_i        (gov_cntp_kernel_access_i),
    .gov_cnthctl_el2_el1pcten_i       (gov_pcnt_kernel_access_i),
    .gic_icc_sre_el1_ns_sre_i         (gic_icc_sre_el1_ns_sre_i),
    .gic_icc_sre_el1_s_sre_i          (gic_icc_sre_el1_s_sre_i),
    .gic_icc_sre_el2_enable_i         (gic_icc_sre_el2_enable_i),
    .gic_icc_sre_el2_sre_i            (gic_icc_sre_el2_sre_i),
    .gic_icc_sre_el3_enable_i         (gic_icc_sre_el3_enable_i),
    .gic_icc_sre_el3_sre_i            (gic_icc_sre_el3_sre_i),
    .gic_ich_hcr_el2_tall0_i          (gic_ich_hcr_el2_tall0_i),
    .gic_ich_hcr_el2_tall1_i          (gic_ich_hcr_el2_tall1_i),
    .gic_ich_hcr_el2_tc_i             (gic_ich_hcr_el2_tc_i),
    .cp_fpexc_en_i                    (cp_fpexc_en),
    .hcr_tid0_i                       (hcr_tid0),
    .hcr_tid1_i                       (hcr_tid1),
    .hcr_tid2_i                       (hcr_tid2),
    .hcr_tid3_i                       (hcr_tid3),
    .hcr_tsc_i                        (hcr_tsc),
    .hcr_tidcp_i                      (hcr_tidcp),
    .hcr_tacr_i                       (hcr_tacr),
    .hcr_tsw_i                        (hcr_tsw),
    .hcr_tpc_i                        (hcr_tpc),
    .hcr_tpu_i                        (hcr_tpu),
    .hcr_ttlb_i                       (hcr_ttlb),
    .hcr_tvm_i                        (hcr_tvm),
    .dbg_double_lock_set_i            (dbg_double_lock_set),
    .dbg_os_lock_synced_i             (dbg_os_lock_synced),
    .hcr_tge_i                        (hcr_tge),
    .hcr_amo_i                        (hcr_amo),
    .hcr_imo_i                        (hcr_imo),
    .hcr_fmo_i                        (hcr_fmo),
    .scr_ea_i                         (scr_ea),
    .scr_fiq_i                        (scr_fiq),
    .scr_irq_i                        (scr_irq),
    .scr_aw_i                         (scr_aw),
    .scr_fw_i                         (scr_fw),
    .edscr_sdd_i                      (edscr_sdd),
    .edscr_tda_i                      (edscr_tda),
    .nxt_ns_scr_i                     (nxt_ns_scr),
    .nxt_mon_el3_mode_ret_i           (nxt_mon_el3_mode_ret),
    .ifu_ifsr_i                       (ifu_ifsr_i[6:0]),
    .ifu_ifsr_stage2_i                (ifu_ifsr_stage2_i[1:0]),
    .ifu_ifsr_lpae_i                  (ifu_ifsr_lpae_i),
    .ifu_hpfar_i                      (ifu_hpfar_i[27:0]),
    .dcu_va_dc3_i                     (dcu_va_dc3_i[63:0]),
    .ifu_ifar_i                       (ifu_ifar_i[31:1]),
    .hcr_va_i                         (hcr_va),
    .hcr_vi_i                         (hcr_vi),
    .hcr_vf_i                         (hcr_vf),
    .cp_icimvau_i                     (cp_icimvau),
    .gov_event_reg_i                  (gov_event_reg_i),
    .msr_mrs_reg_de_i                 (msr_mrs_reg_wr_de),
    .msr_mrs_spsr_de_i                (msr_mrs_spsr_de),
    .msr_mrs_data_de_i                (msr_mrs_data_de[5:0]),
    .flag_en_instr1_de_i              (flag_en_instr1_de[(`CA53_FLAGEN_INSTR1_W-1):0]),
    .mrc_instr_ex1_i                  (mrc_instr_ex1),
    .mrc_instr_ex2_i                  (mrc_instr_ex2),
    .mrc_instr_wr_i                   (mrc_instr_wr),
    .dbg_halting_allowed_i            (dbg_halting_allowed),
    .cryptodisable_i                  (cryptodisable),
    .raw_imm_data_0_iss_i             (raw_imm_data_0_iss[12:0]),
    .raw_imm_data_1_iss_i             (raw_imm_data_1_iss[12:0]),
    .nxt_pc_sample_perm_i             (nxt_pc_sample_perm),
    // Outputs
    .interlock_iss_o                  (interlock_iss),
    .stall_ex1_o                      (stall_ex1),
    .stall_ex2_o                      (stall_ex2),
    .stall_wr_o                       (stall_wr),
    .stall_iss_o                      (stall_iss),
    .stall_slot0_iss_o                (stall_slot0_iss),
    .stall_br_iss_o                   (stall_br_iss),
    .ilock_stall_iss_o                (ilock_stall_iss),
    .nxt_div_stall_wr_o               (nxt_div_stall_wr),
    .div_flush_o                      (div_flush),
    .advance_pipeline_o               (advance_pipeline),
    .flush_wr_o                       (flush_wr),
    .flush_ls_wr_o                    (flush_ls_wr),
    .flush_ret_o                      (flush_ret),
    .quash_iss_o                      (quash_iss),
    .quash_ex1_o                      (quash_ex1),
    .quash_ex2_o                      (quash_ex2),
    .quash_wr_o                       (quash_wr),
    .quash_slot0_wr_o                 (quash_slot0_wr),
    .expt_slot1_wr_o                  (expt_slot1_wr),
    .expt_quash_wr_o                  (expt_quash_wr),
    .fp0_imm_data_f1_o                (fp0_imm_data_f1[12:0]),
    .fp1_imm_data_f1_o                (fp1_imm_data_f1[12:0]),
    .pc_instr1_iss_o                  (pc_instr1_iss[48:1]),
    .mac_iss_ctl_iss_o                (mac_iss_ctl_iss[(`CA53_MAC_ISS_CTL_W-1):0]),
    .ctl_64bit_op_alu1_iss_o          (ctl_64bit_op_alu1_iss),
    .ctl_64bit_op_alu0_iss_o          (ctl_64bit_op_alu0_iss),
    .ctl_64bit_op_mac_iss_o           (ctl_64bit_op_mac_iss),
    .alu0_msk_data_sel_iss_o          (alu0_msk_data_sel_iss),
    .alu1_msk_data_sel_iss_o          (alu1_msk_data_sel_iss),
    .alu0_data_a_sel_iss_o            (alu0_data_a_sel_iss[`CA53_SEL_SHF_A_W-1:0]),
    .alu0_data_b_sel_iss_o            (alu0_data_b_sel_iss[`CA53_SEL_SHF_B_W-1:0]),
    .alu0_data_c_sel_iss_o            (alu0_data_c_sel_iss[`CA53_SEL_SHF_C_W-1:0]),
    .alu1_data_a_sel_iss_o            (alu1_data_a_sel_iss[`CA53_SEL_SHF_A_W-1:0]),
    .alu1_data_b_sel_iss_o            (alu1_data_b_sel_iss[`CA53_SEL_SHF_B_W-1:0]),
    .alu1_data_c_sel_iss_o            (alu1_data_c_sel_iss[`CA53_SEL_SHF_C_W-1:0]),
    .mac_data_a_sel_iss_o             (mac_data_a_sel_iss[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_iss_o             (mac_data_b_sel_iss[`CA53_SEL_MAC_B_W-1:0]),
    .div_data_a_sel_iss_o             (div_data_a_sel_iss[`CA53_SEL_DIV_A_W-1:0]),
    .div_data_b_sel_iss_o             (div_data_b_sel_iss[`CA53_SEL_DIV_B_W-1:0]),
    .alu0_ex1_ctl_iss_o               (alu0_ex1_ctl_iss[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu0_ex2_ctl_iss_o               (alu0_ex2_ctl_iss[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu0_wr_ctl_iss_o                (alu0_wr_ctl_iss),
    .alu1_ex1_ctl_iss_o               (alu1_ex1_ctl_iss[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu1_ex2_ctl_iss_o               (alu1_ex2_ctl_iss[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu1_wr_ctl_iss_o                (alu1_wr_ctl_iss),
    .msr_mrs_data_wr_o                (msr_mrs_data_wr[3:0]),
    .str0_data_a_sel_iss_o            (str0_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0]),
    .str0_data_b_sel_iss_o            (str0_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0]),
    .str1_data_a_sel_iss_o            (str1_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_iss_o            (str1_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0]),
    .expt_mon_mode_clear_ns_o         (expt_mon_mode_clear_ns),
    .expt_fault_reg_en_wr_o           (expt_fault_reg_en_wr[`CA53_FAULT_REG_EN_W-1:0]),
    .expt_fault_reg_sel_wr_o          (expt_fault_reg_sel_wr),
    .expt_aa32_uses_el1_esr_wr_o      (expt_aa32_uses_el1_esr_wr),
    .expt_ifsr_wr_o                   (expt_ifsr_wr[12:0]),
    .expt_dfsr_wr_o                   (expt_dfsr_wr[12:0]),
    .expt_far_data_wr_o               (expt_far_data_wr[63:0]),
    .expt_hpfar_data_wr_o             (expt_hpfar_data_wr[27:0]),
    .expt_status_moe_data_wr_o        (expt_status_moe_data_wr[3:0]),
    .expt_idle_o                      (expt_idle),
    .target_exception_level_o         (target_exception_level),
    .expt_esr_data_wr_o               (expt_esr_data_wr),
    .clear_virtual_ea_o               (clear_virtual_ea),
    .nxt_wfx_ifu_halt_o               (nxt_wfx_ifu_halt),
    .wfx_ifu_halt_o                   (wfx_ifu_halt),
    .force_wfx_nop_o                  (force_wfx_nop),
    .issue_to_iss_o                   (issue_to_iss),
    .issue_to_iss_fpu_o               (issue_to_iss_fpu),
    .issue_to_ex1_o                   (issue_to_ex1),
    .issue_to_ex2_o                   (issue_to_ex2),
    .issue_to_ex2_fpu_o               (issue_to_ex2_fpu),
    .issue_to_wr_o                    (issue_to_wr),
    .issue_to_f4_o                    (issue_to_f4),
    .sel_mac_nzflags_wr_o             (sel_mac_nzflags_wr),
    .isa_instr0_iss_o                 (isa_instr0_iss[1:0]),
    .instr0_de_pc_in_iss_o            (instr0_de_pc_in_iss),
    .prefetch_abort_iss_o             (prefetch_abort_iss),
    .size_instr0_iss_o                (size_instr0_iss),
    .size_instr1_iss_o                (size_instr1_iss),
    .size_instr0_ret_o                (size_instr0_ret),
    .size_instr1_ret_o                (size_instr1_ret),
    .expt_slot1_ret_o                 (expt_slot1_ret),
    .pc_instr0_iss_o                  (pc_instr0_iss[63:0]),
    .thumb_instr0_iss_o               (thumb_instr0_iss),
    .br_x_bit_iss_o                   (br_x_bit_iss),
    .use_ex1_alu_0_iss_o              (use_ex1_alu_0_iss),
    .use_ex1_alu_1_iss_o              (use_ex1_alu_1_iss),
    .raw_alu0_valid_iss_o             (raw_alu0_valid_iss),
    .raw_alu1_valid_iss_o             (raw_alu1_valid_iss),
    .alu0_valid_iss_o                 (alu0_valid_iss),
    .alu1_valid_iss_o                 (alu1_valid_iss),
    .raw_str0_valid_iss_o             (raw_str0_valid_iss),
    .str0_a_valid_iss_o               (str0_a_valid_iss),
    .str0_b_valid_iss_o               (str0_b_valid_iss),
    .ctl_64bit_op_str0_iss_o          (ctl_64bit_op_str0_iss),
    .raw_str1_valid_iss_o             (raw_str1_valid_iss),
    .str1_a_valid_iss_o               (str1_a_valid_iss),
    .str1_b_valid_iss_o               (str1_b_valid_iss),
    .ctl_64bit_op_str1_iss_o          (ctl_64bit_op_str1_iss),
    .raw_mac_valid_iss_o              (raw_mac_valid_iss),
    .mac_valid_iss_o                  (mac_valid_iss),
    .div_valid_iss_o                  (div_valid_iss),
    .raw_div_valid_iss_o              (raw_div_valid_iss),
    .long_rf_rd_addr_r2_iss_o         (long_rf_rd_addr_r2_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r3_iss_o         (long_rf_rd_addr_r3_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r4_iss_o         (long_rf_rd_addr_r4_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .wd_align_pc_alu0_iss_o           (wd_align_pc_alu0_iss),
    .wd_align_pc_alu1_iss_o           (wd_align_pc_alu1_iss),
    .wd_align_pc_ls_iss_o             (wd_align_pc_ls_iss),
    .pg_align_pc_ls_iss_o             (pg_align_pc_ls_iss),
    .rf_wr_addr_w0_wr_o               (rf_wr_addr_w0_wr[5:0]),
    .rf_wr_addr_w1_wr_o               (rf_wr_addr_w1_wr[5:0]),
    .rf_wr_addr_w2_wr_o               (rf_wr_addr_w2_wr[5:0]),
    .sel_rf_wr_w0_wr_o                (sel_rf_wr_w0_wr),
    .sel_rf_wr_w1_wr_o                (sel_rf_wr_w1_wr),
    .sel_rf_wr_w2_wr_o                (sel_rf_wr_w2_wr),
    .rf_wr_en_hi_wr_o                 (rf_wr_en_hi_wr),
    .rf_wr_en_lo_wr_o                 (rf_wr_en_lo_wr),
    .rf_wr_en_w0_wr_o                 (rf_wr_en_w0_wr),
    .rf_wr_en_w1_wr_o                 (rf_wr_en_w1_wr),
    .rf_wr_en_w2_wr_o                 (rf_wr_en_w2_wr),
    .aarch64_state_iss_o              (aarch64_state_iss),
    .rf_wr_64b_w0_wr_o                (rf_wr_64b_w0_wr),
    .rf_wr_64b_w1_wr_o                (rf_wr_64b_w1_wr),
    .rf_wr_64b_w2_wr_o                (rf_wr_64b_w2_wr),
    .rf_wr_src_w0_wr_o                (rf_wr_src_w0_wr[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_wr_o                (rf_wr_src_w1_wr[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_src_w2_wr_o                (rf_wr_src_w2_wr[`CA53_RF_WR_SRC_W2_W-1:0]),
    .rf_rd_en_fr0_iss_o               (rf_rd_en_fr0_iss),
    .rf_rd_en_fr1_iss_o               (rf_rd_en_fr1_iss),
    .rf_rd_en_fr2_iss_o               (rf_rd_en_fr2_iss),
    .rf_rd_en_fr3_iss_o               (rf_rd_en_fr3_iss),
    .rf_rd_en_fr4_iss_o               (rf_rd_en_fr4_iss),
    .rf_rd_en_fr5_iss_o               (rf_rd_en_fr5_iss),
    .rf_rd_en_fr0_ex1_o               (rf_rd_en_fr0_ex1),
    .rf_rd_en_fr1_ex1_o               (rf_rd_en_fr1_ex1),
    .rf_rd_en_fr2_ex1_o               (rf_rd_en_fr2_ex1),
    .rf_rd_en_fr3_ex1_o               (rf_rd_en_fr3_ex1),
    .rf_rd_en_fr4_ex1_o               (rf_rd_en_fr4_ex1),
    .rf_rd_en_fr5_ex1_o               (rf_rd_en_fr5_ex1),
    .rf_rd_en_fr0_ex2_o               (rf_rd_en_fr0_ex2),
    .rf_rd_en_fr1_ex2_o               (rf_rd_en_fr1_ex2),
    .rf_rd_en_fr2_ex2_o               (rf_rd_en_fr2_ex2),
    .rf_rd_en_fr3_ex2_o               (rf_rd_en_fr3_ex2),
    .rf_rd_en_fr4_ex2_o               (rf_rd_en_fr4_ex2),
    .rf_rd_en_fr5_ex2_o               (rf_rd_en_fr5_ex2),
    .rf_rd_addr_fr0_iss_o             (rf_rd_addr_fr0_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr1_iss_o             (rf_rd_addr_fr1_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr2_iss_o             (rf_rd_addr_fr2_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr3_iss_o             (rf_rd_addr_fr3_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr4_iss_o             (rf_rd_addr_fr4_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr5_iss_o             (rf_rd_addr_fr5_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_wr_en_fw_f3_o                 (rf_wr_en_fw_f3),
    .rf_wr_en_fw_f5_o                 (rf_wr_en_fw_f5),
    .rf_wr_en_fw0_f5_o                (rf_wr_en_fw0_f5),
    .rf_wr_en_fw1_f5_o                (rf_wr_en_fw1_f5),
    .rf_wr_addr_fw0_f5_o              (rf_wr_addr_fw0_f5[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_addr_fw1_f5_o              (rf_wr_addr_fw1_f5[`CA53_FP_RF_WR_ADDR_W-1:0]),
    .rf_wr_src_fw0_f3_o               (rf_wr_src_fw0_f3[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f4_o               (rf_wr_src_fw0_f4[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f5_o               (rf_wr_src_fw0_f5[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f3_o               (rf_wr_src_fw1_f3[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f4_o               (rf_wr_src_fw1_f4[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f5_o               (rf_wr_src_fw1_f5[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_f4_o              (rf_wr_when_fw0_f4[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_when_fw1_f4_o              (rf_wr_when_fw1_f4[`CA53_RF_FWR_WHEN_W-1:0]),
    .fp0_cflag_src_f5_o               (fp0_cflag_src_f5[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp1_cflag_src_f5_o               (fp1_cflag_src_f5[`CA53_FP_CFLAG_SRC_W-1:0]),
    .fp0_xflag_src_f5_o               (fp0_xflag_src_f5[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fp1_xflag_src_f5_o               (fp1_xflag_src_f5[`CA53_FP_XFLAG_SRC_W-1:0]),
    .fr0_fwd_ex1_o                    (fr0_fwd_ex1[5:0]),
    .fr1_fwd_ex1_o                    (fr1_fwd_ex1[5:0]),
    .fr2_fwd_ex1_o                    (fr2_fwd_ex1[5:0]),
    .fr3_fwd_ex1_o                    (fr3_fwd_ex1[5:0]),
    .fr4_fwd_ex1_o                    (fr4_fwd_ex1[5:0]),
    .fr5_fwd_ex1_o                    (fr5_fwd_ex1[5:0]),
    .fr0_fwd_ex2_o                    (fr0_fwd_ex2[5:0]),
    .fr1_fwd_ex2_o                    (fr1_fwd_ex2[5:0]),
    .fr2_fwd_ex2_o                    (fr2_fwd_ex2[5:0]),
    .fr3_fwd_ex2_o                    (fr3_fwd_ex2[5:0]),
    .fr4_fwd_ex2_o                    (fr4_fwd_ex2[5:0]),
    .fr5_fwd_ex2_o                    (fr5_fwd_ex2[5:0]),
    .fp_mul_fwd_ex2_o                 (fp_mul_fwd_ex2[1:0]),
    .str0_sel_fp_f1_o                 (str0_sel_fp_f1[1:0]),
    .str1_sel_fp_f1_o                 (str1_sel_fp_f1[1:0]),
    .str0_sel_fp_f2_o                 (str0_sel_fp_f2[1:0]),
    .str1_sel_fp_f2_o                 (str1_sel_fp_f2[1:0]),
    .ctl_fp_dp_en_o                   (ctl_fp_dp_en),
    .dpu_neon_active_o                (dpu_neon_active_o),
    .fp_ex_pipe_iss_o                 (fp_ex_pipe_iss[(`CA53_FP_EX_PIPE_W-1):0]),
    .fp_ex_pipe_f1_o                  (fp_ex_pipe_f1[(`CA53_FP_EX_PIPE_W-1):0]),
    .crypto_enable_iss_o              (crypto_enable_iss),
    .crypto_enable_f1_o               (crypto_enable_f1),
    .fp0_pipectl_f1_o                 (fp0_pipectl_f1[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_f1_o                 (fp1_pipectl_f1[`CA53_FP_PIPECTL_W-1:0]),
    .fp_div_enb_ex1_o                 (fp_div_enb_ex1[1:0]),
    .fp_div_active_o                  (fp_div_active[1:0]),
    .instr_fmstat_ex2_o               (instr_fmstat_ex2[1:0]),
    .fp_fwd_cflags_ex2_o              (fp_fwd_cflags_ex2[3:0]),
    .fp_cflags_add0_f5_o              (fp_cflags_add0_f5[3:0]),
    .fp_cflags_add1_f5_o              (fp_cflags_add1_f5[3:0]),
    .instr_is_cp10_cp11_wr_o          (instr_is_cp10_cp11_wr),
    .neon_vld_ctl_f2_o                (neon_vld_ctl_f2[(`CA53_NEON_VLD_CTL_W-1):0]),
    .neon_vld_ctl_f3_o                (neon_vld_ctl_f3[(`CA53_NEON_VLD_CTL_W-1):0]),
    .sel_fad0_a_f1_o                  (sel_fad0_a_f1[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad0_b_f1_o                  (sel_fad0_b_f1[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad0_c_f1_o                  (sel_fad0_c_f1[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fad1_a_f1_o                  (sel_fad1_a_f1[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_b_f1_o                  (sel_fad1_b_f1[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad1_c_f1_o                  (sel_fad1_c_f1[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fml0_a_f1_o                  (sel_fml0_a_f1),
    .sel_fml0_b_f1_o                  (sel_fml0_b_f1[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml0_c_f1_o                  (sel_fml0_c_f1),
    .sel_fml1_a_f1_o                  (sel_fml1_a_f1),
    .sel_fml1_b_f1_o                  (sel_fml1_b_f1[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml1_c_f1_o                  (sel_fml1_c_f1),
    .valid_instrs_iss_o               (valid_instrs_iss[1:0]),
    .head_instr_ls_iss_o              (head_instr_ls_iss),
    .end_instr_iss_o                  (end_instr_iss),
    .end_instr_wr_o                   (end_instr_wr),
    .pre_end_instr_wr_o               (pre_end_instr_wr),
    .end_instr_no_quash_wr_o          (end_instr_no_quash_wr),
    .end_instr_dbg_wr_o               (end_instr_dbg_wr),
    .ls_conditional_iss_o             (ls_conditional_iss),
    .isb_wr_o                         (isb_wr),
    .pre_valid_instrs_wr_o            (pre_valid_instrs_wr),
    .valid_instrs_wr_o                (valid_instrs_wr[1:0]),
    .dpu_flush_o                      (dpu_flush_o),
    .dpu_kill_wr_o                    (dpu_kill_wr_o),
    .pc_instr0_ret_o                  (pc_instr0_ret[63:0]),
    .pc_sample_perm_o                 (pc_sample_perm),
    .dpu_dbg_vid_o                    (dpu_dbg_vid_o),
    .pc_instr0_wr_o                   (pc_instr0_wr[63:0]),
    .pc_instr0_ex2_o                  (pc_instr0_ex2[48:1]),
    .save_base_ex2_o                  (save_base_ex2),
    .cond_code_instr0_ex2_o           (cond_code_instr0_ex2[3:0]),
    .cond_code_instr1_ex2_o           (cond_code_instr1_ex2[3:0]),
    .cc_pass_instr0_wr_o              (cc_pass_instr0_wr),
    .cc_pass_instr1_wr_o              (cc_pass_instr1_wr),
    .size_instr0_wr_o                 (size_instr0_wr),
    .size_instr1_wr_o                 (size_instr1_wr),
    .isa_instr0_wr_o                  (isa_instr0_wr[1:0]),
    .isa_instr0_ret_o                 (isa_instr0_ret[1:0]),
    .thumb_instr0_ret_o               (thumb_instr0_ret),
    .thumb_instr1_ret_o               (thumb_instr1_ret),
    .expt_type_o                      (expt_type[`CA53_EXPT_TYPE_W-1:0]),
    .expt_type_l1_ecc_o               (expt_type_l1_ecc),
    .forceop_type_o                   (forceop_type[`CA53_FORCEOP_TYPE_W-1:0]),
    .forceop_offset_o                 (forceop_offset[`CA53_FORCEOP_OFFSET_W-1:0]),
    .forceop_aa64_o                   (forceop_aa64),
    .r0_fwd_iss_o                     (r0_fwd_iss[`CA53_FWD_W-1:0]),
    .r1_fwd_iss_o                     (r1_fwd_iss[`CA53_FWD_W-1:0]),
    .r2_fwd_iss_o                     (r2_fwd_iss[`CA53_FWD_W-1:0]),
    .r3_fwd_iss_o                     (r3_fwd_iss[`CA53_FWD_W-1:0]),
    .r4_fwd_iss_o                     (r4_fwd_iss[`CA53_FWD_W-1:0]),
    .slot1_ls_ex2_o                   (slot1_ls_ex2),
    .evnt_ls_instr_wr_o               (evnt_ls_instr_wr),
    .slot1_branch_iss_o               (slot1_branch_iss),
    .slot1_branch_ex2_o               (slot1_branch_ex2),
    .slot1_branch_wr_o                (slot1_branch_wr),
    .slot1_blx_ex2_o                  (slot1_blx_ex2),
    .slot1_bx_wr_o                    (slot1_bx_wr),
    .slot1_blx_wr_o                   (slot1_blx_wr),
    .slot1_mul_iss_o                  (slot1_mul_iss),
    .slot1_mul_wr_o                   (slot1_mul_wr),
    .w0_slot1_wr_o                    (w0_slot1_wr),
    .alu0_a_fwd_ex1_o                 (alu0_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu0_b_fwd_ex1_o                 (alu0_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_a_fwd_ex1_o                 (str0_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_b_fwd_ex1_o                 (str0_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str1_a_fwd_ex1_o                 (str1_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .str1_b_fwd_ex1_o                 (str1_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu1_a_fwd_ex1_o                 (alu1_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu1_b_fwd_ex1_o                 (alu1_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_a_fwd_ex2_o                 (str0_a_fwd_ex2[`CA53_FWD_W-1:0]),
    .str0_b_fwd_ex2_o                 (str0_b_fwd_ex2[`CA53_FWD_W-1:0]),
    .str1_a_fwd_ex2_o                 (str1_a_fwd_ex2[`CA53_FWD_W-1:0]),
    .str1_b_fwd_ex2_o                 (str1_b_fwd_ex2[`CA53_FWD_W-1:0]),
    .mac_fwd_ctl_ex1_o                (mac_fwd_ctl_ex1[5:0]),
    .sel_fwd_dcu_a_iss_o              (sel_fwd_dcu_a_iss[`CA53_SEL_FWD_DCU_W-1:0]),
    .sel_fwd_dcu_b_iss_o              (sel_fwd_dcu_b_iss[`CA53_SEL_FWD_DCU_W-1:0]),
    .sel_fwd_addr_dcu_a_iss_o         (sel_fwd_addr_dcu_a_iss),
    .rf_rd_r0_agu_de_o                (rf_rd_r0_agu_de[2:0]),
    .rf_rd_r1_agu_de_o                (rf_rd_r1_agu_de[2:0]),
    .en_rf_rd_r0_agu_de_o             (en_rf_rd_r0_agu_de),
    .en_rf_rd_r1_agu_de_o             (en_rf_rd_r1_agu_de),
    .insert_forceop_wr_o              (insert_forceop_wr),
    .forceop_pc_ret_o                 (forceop_pc_ret[63:0]),
    .expt_cpsr_wr_en_ret_o            (expt_cpsr_wr_en_ret[`CA53_SEL_CPSR_EN_W-1:0]),
    .expt_cpsr_wr_src_ret_o           (expt_cpsr_wr_src_ret[`CA53_SEL_CPSR_SRC_W-1:0]),
    .expt_cpsr_mode_ret_o             (expt_cpsr_mode_ret[4:0]),
    .forceop_valid_de_o               (forceop_valid_de),
    .forceop_valid_iss_o              (forceop_valid_iss),
    .forceop_valid_wr_o               (forceop_valid_wr),
    .insert_forceop_ret_o             (insert_forceop_ret),
    .dbg_halt_ecc_expt_iss_o          (dbg_halt_ecc_expt_iss),
    .etm_trace_expt_o                 (etm_trace_expt),
    .etm_trace_dbgentry_o             (etm_trace_dbgentry),
    .expt_dbgexit_o                   (expt_dbgexit),
    .forceop_pc_offset_ret_o          (forceop_pc_offset_ret[17:1]),
    .isa_instr0_ex2_o                 (isa_instr0_ex2[1:0]),
    .size_instr0_ex2_o                (size_instr0_ex2),
    .size_instr1_ex2_o                (size_instr1_ex2),
    .dpu_halt_ifu_o                   (dpu_halt_ifu),
    .expt_in_halt_o                   (expt_in_halt),
    .end_expt_in_halt_o               (end_expt_in_halt),
    .dbg_event_o                      (dbg_event),
    .dbg_event_halt_wr_o              (dbg_event_halt_wr),
    .dbg_ss_vld_expt_type_ret_o       (dbg_ss_vld_expt_type_ret),
    .dbg_expt_o                       (dbg_expt),
    .evnt_expt_taken_o                (evnt_expt_taken),
    .evnt_call_expt_taken_o           (evnt_call_expt_taken),
    .evnt_instr_exec_o                (evnt_instr_exec[1:0]),
    .evnt_fpu_interlock_iss_o         (evnt_fpu_interlock_iss),
    .evnt_agu_interlock_iss_o         (evnt_agu_interlock_iss),
    .ns_state_o                       (ns_state),
    .dpu_sev_req_o                    (dpu_sev_req_o),
    .dpu_clr_event_register_o         (dpu_clr_event_register_o),
    .dpu_wfi_req_o                    (dpu_wfi_req_o),
    .dpu_wfe_req_o                    (dpu_wfe_req_o),
    .expt_serr_pending_o              (expt_serr_pending),
    .expt_irq_pending_o               (expt_irq_pending),
    .expt_fiq_pending_o               (expt_fiq_pending),
    .evnt_fiq_taken_o                 (evnt_fiq_taken),
    .evnt_irq_taken_o                 (evnt_irq_taken),
    .dpu_irq_pended_o                 (dpu_irq_pended_o),
    .dpu_fiq_pended_o                 (dpu_fiq_pended_o),
    .dpu_sei_pended_o                 (dpu_sei_pended_o),
    .dpu_irq_masked_o                 (dpu_irq_masked_o),
    .dpu_fiq_masked_o                 (dpu_fiq_masked_o),
    .dpu_sei_masked_o                 (dpu_sei_masked_o),
    .dpu_virq_pended_o                (dpu_virq_pended_o),
    .dpu_vfiq_pended_o                (dpu_vfiq_pended_o),
    .dpu_vsei_pended_o                (dpu_vsei_pended_o),
    .dpu_virq_masked_o                (dpu_virq_masked_o),
    .dpu_vfiq_masked_o                (dpu_vfiq_masked_o),
    .dpu_vsei_masked_o                (dpu_vsei_masked_o),
    .dpu_rei_level_ack_o              (dpu_rei_level_ack_o),
    .dpu_sei_level_ack_o              (dpu_sei_level_ack_o),
    .dpu_vsei_level_ack_o             (dpu_vsei_level_ack_o),
    .dpu_imp_abort_pending_o          (dpu_imp_abort_pending_o),
    .no_interrupt_wr_o                (no_interrupt_wr),
    .flag_en_instr1_wr_o              (flag_en_instr1_wr[(`CA53_FLAGEN_INSTR1_W-1):0]),
    .rf_wr_en_w0_iss_o                (rf_wr_en_w0_iss),
    .rf_wr_en_w1_iss_o                (rf_wr_en_w1_iss),
    .rf_wr_en_w2_iss_o                (rf_wr_en_w2_iss),
    .rf_wr_when_w0_iss_o              (rf_wr_when_w0_iss),
    .rf_wr_when_w1_iss_o              (rf_wr_when_w1_iss),
    .rf_wr_when_w2_iss_o              (rf_wr_when_w2_iss),
    .rf_wr_vaddr_w0_iss_o             (rf_wr_vaddr_w0_iss[4:0]),
    .rf_wr_vaddr_w1_iss_o             (rf_wr_vaddr_w1_iss[4:0]),
    .rf_wr_vaddr_w2_iss_o             (rf_wr_vaddr_w2_iss[4:0]),
    .rf_wr_en_w0_ex1_o                (rf_wr_en_w0_ex1),
    .rf_wr_en_w1_ex1_o                (rf_wr_en_w1_ex1),
    .rf_wr_en_w2_ex1_o                (rf_wr_en_w2_ex1),
    .rf_wr_when_w0_ex1_o              (rf_wr_when_w0_ex1),
    .rf_wr_when_w1_ex1_o              (rf_wr_when_w1_ex1),
    .rf_wr_when_w2_ex1_o              (rf_wr_when_w2_ex1),
    .rf_wr_vaddr_w0_ex1_o             (rf_wr_vaddr_w0_ex1[4:0]),
    .rf_wr_vaddr_w1_ex1_o             (rf_wr_vaddr_w1_ex1[4:0]),
    .rf_wr_vaddr_w2_ex1_o             (rf_wr_vaddr_w2_ex1[4:0]),
    .rf_wr_en_fw0_iss_o               (rf_wr_en_fw0_iss),
    .rf_wr_en_fw1_iss_o               (rf_wr_en_fw1_iss),
    .rf_wr_en_fw0_f1_o                (rf_wr_en_fw0_f1),
    .rf_wr_en_fw1_f1_o                (rf_wr_en_fw1_f1),
    .rf_wr_en_fw0_f2_o                (rf_wr_en_fw0_f2),
    .rf_wr_en_fw1_f2_o                (rf_wr_en_fw1_f2),
    .rf_wr_when_fw0_iss_o             (rf_wr_when_fw0_iss),
    .rf_wr_when_fw1_iss_o             (rf_wr_when_fw1_iss),
    .rf_wr_when_fw0_f1_o              (rf_wr_when_fw0_f1),
    .rf_wr_when_fw1_f1_o              (rf_wr_when_fw1_f1),
    .rf_wr_when_fw0_f2_o              (rf_wr_when_fw0_f2),
    .rf_wr_when_fw1_f2_o              (rf_wr_when_fw1_f2),
    .rf_wr_addr_fw0_iss_o             (rf_wr_addr_fw0_iss),
    .rf_wr_addr_fw1_iss_o             (rf_wr_addr_fw1_iss),
    .rf_wr_addr_fw0_f1_o              (rf_wr_addr_fw0_f1),
    .rf_wr_addr_fw1_f1_o              (rf_wr_addr_fw1_f1),
    .rf_wr_addr_fw0_f2_o              (rf_wr_addr_fw0_f2),
    .rf_wr_addr_fw1_f2_o              (rf_wr_addr_fw1_f2),
    .exception_valid_iss_o            (exception_valid_iss),
    .exception_valid_ex1_o            (exception_valid_ex1)
  );

  // ------------------------------------------------------
  // Datapath
  // ------------------------------------------------------

  ca53dpu_dp `CA53_DPU_PARAM_INST u_dpu_dp (
    // Inputs
    .clk                           (clk),
    .reset_n                       (reset_n),
    .DFTSE                         (DFTSE),
    .aarch64_state_i               (aarch64_state),
    .issue_to_iss_i                (issue_to_iss),
    .alu0_valid_de_i               (alu0_valid_de),
    .alu1_valid_de_i               (alu1_valid_de),
    .imm_data_0_de_i               (imm_data_0_de[(`CA53_IMM_DATA_W-1):0]),
    .imm_data_1_de_i               (imm_data_1_de[(`CA53_IMM_DATA_W-1):0]),
    .imm_shift_0_de_i              (imm_shift_0_de[(`CA53_IMM_SHIFT_W-1):0]),
    .imm_shift_1_de_i              (imm_shift_1_de[(`CA53_IMM_SHIFT_W-1):0]),
    .imm_data_sel_0_de_i           (imm_data_sel_0_de[(`CA53_IMM_SEL_W-1):0]),
    .imm_data_sel_1_de_i           (imm_data_sel_1_de[(`CA53_IMM_SEL_W-1):0]),
    .r0_fwd_iss_i                  (r0_fwd_iss[`CA53_FWD_W-1:0]),
    .r1_fwd_iss_i                  (r1_fwd_iss[`CA53_FWD_W-1:0]),
    .r2_fwd_iss_i                  (r2_fwd_iss[`CA53_FWD_W-1:0]),
    .r3_fwd_iss_i                  (r3_fwd_iss[`CA53_FWD_W-1:0]),
    .r4_fwd_iss_i                  (r4_fwd_iss[`CA53_FWD_W-1:0]),
    .alu0_a_fwd_ex1_i              (alu0_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu0_b_fwd_ex1_i              (alu0_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_a_fwd_ex1_i              (str0_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_b_fwd_ex1_i              (str0_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str1_a_fwd_ex1_i              (str1_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .str1_b_fwd_ex1_i              (str1_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu1_a_fwd_ex1_i              (alu1_a_fwd_ex1[`CA53_FWD_W-1:0]),
    .alu1_b_fwd_ex1_i              (alu1_b_fwd_ex1[`CA53_FWD_W-1:0]),
    .str0_a_fwd_ex2_i              (str0_a_fwd_ex2[`CA53_FWD_W-1:0]),
    .str0_b_fwd_ex2_i              (str0_b_fwd_ex2[`CA53_FWD_W-1:0]),
    .str1_a_fwd_ex2_i              (str1_a_fwd_ex2[`CA53_FWD_W-1:0]),
    .str1_b_fwd_ex2_i              (str1_b_fwd_ex2[`CA53_FWD_W-1:0]),
    .mac_fwd_ctl_ex1_i             (mac_fwd_ctl_ex1[5:0]),
    .rf_rd_data_r0_iss_i           (rf_rd_data_r0_iss[63:0]),
    .rf_rd_data_r1_iss_i           (rf_rd_data_r1_iss[63:0]),
    .rf_rd_data_r2_iss_i           (rf_rd_data_r2_iss[63:0]),
    .rf_rd_data_r3_iss_i           (rf_rd_data_r3_iss[63:0]),
    .rf_rd_data_r4_iss_i           (rf_rd_data_r4_iss[63:0]),
    .rf_wr_src_w0_wr_i             (rf_wr_src_w0_wr[`CA53_RF_WR_SRC_W0_W-1:0]),
    .rf_wr_src_w1_wr_i             (rf_wr_src_w1_wr[`CA53_RF_WR_SRC_W1_W-1:0]),
    .rf_wr_src_w2_wr_i             (rf_wr_src_w2_wr[`CA53_RF_WR_SRC_W2_W-1:0]),
    .rf_wr_64b_w0_wr_i             (rf_wr_64b_w0_wr),
    .rf_wr_64b_w1_wr_i             (rf_wr_64b_w1_wr),
    .rf_wr_64b_w2_wr_i             (rf_wr_64b_w2_wr),
    .pc_instr0_iss_i               (pc_instr0_iss[63:0]),
    .pc_instr1_iss_i               (pc_instr1_iss[48:1]),
    .wd_align_pc_alu0_iss_i        (wd_align_pc_alu0_iss),
    .wd_align_pc_alu1_iss_i        (wd_align_pc_alu1_iss),
    .str0_valid_de_i               (str0_valid_de),
    .raw_str0_valid_iss_i          (raw_str0_valid_iss),
    .str0_a_valid_iss_i            (str0_a_valid_iss),
    .str0_b_valid_iss_i            (str0_b_valid_iss),
    .ctl_64bit_op_str0_iss_i       (ctl_64bit_op_str0_iss),
    .str1_valid_de_i               (str1_valid_de),
    .raw_str1_valid_iss_i          (raw_str1_valid_iss),
    .str1_a_valid_iss_i            (str1_a_valid_iss),
    .str1_b_valid_iss_i            (str1_b_valid_iss),
    .ctl_64bit_op_str1_iss_i       (ctl_64bit_op_str1_iss),
    .str0_data_a_sel_iss_i         (str0_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0]),
    .str0_data_b_sel_iss_i         (str0_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0]),
    .str1_data_a_sel_iss_i         (str1_data_a_sel_iss[`CA53_SEL_STR_A_W-1:0]),
    .str1_data_b_sel_iss_i         (str1_data_b_sel_iss[`CA53_SEL_STR_B_W-1:0]),
    .ld_data0_wr_i                 (ld_data0_wr[63:0]),
    .ld_data1_wr_i                 (ld_data1_wr[63:0]),
    .use_ex1_alu_0_iss_i           (use_ex1_alu_0_iss),
    .use_ex1_alu_1_iss_i           (use_ex1_alu_1_iss),
    .raw_alu0_valid_iss_i          (raw_alu0_valid_iss),
    .raw_alu1_valid_iss_i          (raw_alu1_valid_iss),
    .alu0_valid_iss_i              (alu0_valid_iss),
    .alu1_valid_iss_i              (alu1_valid_iss),
    .mac_valid_de_i                (mac_valid_de),
    .raw_mac_valid_iss_i           (raw_mac_valid_iss),
    .mac_valid_iss_i               (mac_valid_iss),
    .div_valid_iss_i               (div_valid_iss),
    .div_valid_de_i                (div_valid_de),
    .raw_div_valid_iss_i           (raw_div_valid_iss),
    .save_base_ex2_i               (save_base_ex2),
    .cond_code_instr0_ex2_i        (cond_code_instr0_ex2[3:0]),
    .cond_code_instr1_ex2_i        (cond_code_instr1_ex2[3:0]),
    .div_flush_i                   (div_flush),
    .flush_wr_i                    (flush_wr),
    .flush_ret_i                   (flush_ret),
    .advance_pipeline_i            (advance_pipeline),
    .quash_iss_i                   (quash_iss),
    .quash_ex1_i                   (quash_ex1),
    .stall_ex1_i                   (stall_ex1),
    .stall_ex2_i                   (stall_ex2),
    .stall_wr_i                    (stall_wr),
    .pre_valid_instrs_wr_i         (pre_valid_instrs_wr),
    .cpsr_masked_ret_i             (cpsr_masked_ret[31:0]),
    .cpsr_ret_i                    (cpsr_ret[31:0]),
    .sel_mac_nzflags_wr_i          (sel_mac_nzflags_wr),
    .srs_wr_i                      (srs_wr),
    .spsr_ret_i                    (spsr_ret[31:0]),
    .slot1_ls_ex2_i                (slot1_ls_ex2),
    .slot1_mul_iss_i               (slot1_mul_iss),
    .w0_slot1_wr_i                 (w0_slot1_wr),
    .ldc_stc_wr_i                  (ldc_stc_wr),
    .spec_endianness_ex2_i         (spec_endianness_ex2),
    .ls_elem_size_ex2_i            (ls_elem_size_ex2[1:0]),
    .ls_elem_size_wr_i             (ls_elem_size_wr[1:0]),
    .ls_valid_ex2_i                (ls_valid_ex2),
    .ls_store_ex2_i                (ls_store_ex2),
    .ls_store_neon_ex2_i           (ls_store_neon_ex2),
    .instr_is_cp10_cp11_wr_i       (instr_is_cp10_cp11_wr),
    .neon_vld_ctl_f2_i             (neon_vld_ctl_f2[(`CA53_NEON_VLD_CTL_W-1):0]),
    .neon_vld_ctl_f3_i             (neon_vld_ctl_f3[(`CA53_NEON_VLD_CTL_W-1):0]),
    .first_x64_wr_i                (first_x64_wr),
    .v_addr_ex2_i                  (v_addr_ex2[3:0]),
    .cp_valid_ex2_i                (cp_valid_ex2),
    .dbg_dtrrx_data_i              (dbg_dtrrx_data[31:0]),
    .dcu_strex_okay_dc3_i          (dcu_strex_okay_dc3_i),
    .cpsr_flag_update_cp_dscr_wr_i (cpsr_flag_update_cp_dscr_wr),
    .cpsr_flag_update_nzcv_i       (cpsr_flag_update_nzcv[3:0]),
    .instr_fmstat_ex2_i            (instr_fmstat_ex2[1:0]),
    .fp_fwd_cflags_ex2_i           (fp_fwd_cflags_ex2[3:0]),
    .fp_cflags_add0_f2_i           (fp_cflags_add0_f2[3:0]),
    .fp_cflags_add1_f2_i           (fp_cflags_add1_f2[3:0]),
    .ctl_64bit_op_alu1_iss_i       (ctl_64bit_op_alu1_iss),
    .ctl_64bit_op_alu0_iss_i       (ctl_64bit_op_alu0_iss),
    .ctl_64bit_op_mac_iss_i        (ctl_64bit_op_mac_iss),
    .mac_iss_ctl_iss_i             (mac_iss_ctl_iss[(`CA53_MAC_ISS_CTL_W-1):0]),
    .alu0_msk_data_sel_iss_i       (alu0_msk_data_sel_iss),
    .alu1_msk_data_sel_iss_i       (alu1_msk_data_sel_iss),
    .alu0_data_a_sel_iss_i         (alu0_data_a_sel_iss[`CA53_SEL_SHF_A_W-1:0]),
    .alu0_data_b_sel_iss_i         (alu0_data_b_sel_iss[`CA53_SEL_SHF_B_W-1:0]),
    .alu0_data_c_sel_iss_i         (alu0_data_c_sel_iss[`CA53_SEL_SHF_C_W-1:0]),
    .alu1_data_a_sel_iss_i         (alu1_data_a_sel_iss[`CA53_SEL_SHF_A_W-1:0]),
    .alu1_data_b_sel_iss_i         (alu1_data_b_sel_iss[`CA53_SEL_SHF_B_W-1:0]),
    .alu1_data_c_sel_iss_i         (alu1_data_c_sel_iss[`CA53_SEL_SHF_C_W-1:0]),
    .mac_data_a_sel_iss_i          (mac_data_a_sel_iss[`CA53_SEL_MAC_A_W-1:0]),
    .mac_data_b_sel_iss_i          (mac_data_b_sel_iss[`CA53_SEL_MAC_B_W-1:0]),
    .div_data_a_sel_iss_i          (div_data_a_sel_iss[`CA53_SEL_DIV_A_W-1:0]),
    .div_data_b_sel_iss_i          (div_data_b_sel_iss[`CA53_SEL_DIV_B_W-1:0]),
    .alu0_ex1_ctl_iss_i            (alu0_ex1_ctl_iss[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu0_ex2_ctl_iss_i            (alu0_ex2_ctl_iss[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu0_wr_ctl_iss_i             (alu0_wr_ctl_iss),
    .alu1_ex1_ctl_iss_i            (alu1_ex1_ctl_iss[(`CA53_ALU_EX1_CTL_W-1):0]),
    .alu1_ex2_ctl_iss_i            (alu1_ex2_ctl_iss[(`CA53_ALU_EX2_CTL_W-1):0]),
    .alu1_wr_ctl_iss_i             (alu1_wr_ctl_iss),
    .mrc_data_wr_i                 (mrc_data_wr[63:0]),
    .fp_str0_data_f1_i             (fp_str0_data_f1[63:0]),
    .fp_str1_data_f1_i             (fp_str1_data_f1[63:0]),
    .fp_str0_data_f2_i             (fp_str0_data_f2[63:0]),
    .fp_str1_data_f2_i             (fp_str1_data_f2[63:0]),
    .rtn_addr_iss_i                (rtn_addr_iss[31:1]),
    .fp_alu0_f2i_res_f3_i          (fp_alu0_f2i_res_f3[63:0]),
    .fp_alu1_f2i_res_f3_i          (fp_alu1_f2i_res_f3[63:0]),
    // Outputs
    .raw_imm_data_0_iss_o          (raw_imm_data_0_iss[20:0]),
    .raw_imm_data_1_iss_o          (raw_imm_data_1_iss[20:0]),
    .adrp_valid_iss_o              (adrp_valid_iss[1:0]),
    .alu0_qbit_wr_o                (alu0_qbit_wr),
    .alu1_qbit_wr_o                (alu1_qbit_wr),
    .cc_pass_instr0_ex2_o          (cc_pass_instr0_ex2),
    .cc_pass_instr0_cbz_ex2_o      (cc_pass_instr0_cbz_ex2),
    .cc_pass_instr1_ex2_o          (cc_pass_instr1_ex2),
    .cc_pass_instr1_cbz_ex2_o      (cc_pass_instr1_cbz_ex2),
    .cc_pass_instr1_early_ex2_o    (cc_pass_instr1_early_ex2),
    .fp0_ccmp_fail_ex2_o           (fp0_ccmp_fail_ex2),
    .fp1_ccmp_fail_ex2_o           (fp1_ccmp_fail_ex2),
    .alu0_csel_pass_ex2_o          (alu0_csel_pass_ex2),
    .mac_stall_iss_o               (mac_stall_iss),
    .new_mac_qflag_wr_o            (new_mac_qflag_wr),
    .div_busy_iss_o                (div_busy_iss),
    .nxt_div_busy_wr_o             (nxt_div_busy_wr),
    .dpu_st_data_wr_o              (dpu_st_data_wr_o[127:0]),
    .st0_data_ex1_o                (st0_data_ex1[63:0]),
    .st0_data_wr_o                 (st0_data_wr[63:0]),
    .st1_data_ex1_o                (st1_data_ex1[63:0]),
    .st1_data_wr_o                 (st1_data_wr[63:0]),
    .rf_wr_data_w0_wr_o            (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_o            (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_o            (rf_wr_data_w2_wr[63:0]),
    .ccflags_wr_o                  (ccflags_wr[3:0]),
    .geflags_wr_o                  (geflags_wr[3:0]),
    .alu0_fwd_data_early_ex2_o     (alu0_fwd_data_early_ex2[63:0]),
    .alu1_fwd_data_early_ex2_o     (alu1_fwd_data_early_ex2[63:0]),
    .alu0_fwd_data_early_wr_o      (alu0_fwd_data_early_wr[63:0]),
    .alu1_fwd_data_early_wr_o      (alu1_fwd_data_early_wr[63:0])
  );

  // ------------------------------------------------------
  // Load-store pipeline
  // ------------------------------------------------------

  ca53dpu_ldst `CA53_DPU_PARAM_INST u_dpu_ldst (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .DFTSE                        (DFTSE),
    .aarch64_state_i              (aarch64_state),
    .aarch64_at_el_i              (aarch64_at_el[3:1]),
    .stall_iss_i                  (stall_iss),
    .ilock_stall_iss_i            (ilock_stall_iss),
    .interlock_iss_i              (interlock_iss),
    .stall_wr_i                   (stall_wr),
    .nxt_div_stall_wr_i           (nxt_div_stall_wr),
    .cc_pass_instr0_ex2_i         (cc_pass_instr0_ex2),
    .cc_pass_instr1_ex2_i         (cc_pass_instr1_ex2),
    .slot1_ls_ex2_i               (slot1_ls_ex2),
    .evnt_ls_instr_wr_i           (evnt_ls_instr_wr),
    .dpu_exception_level_i        (dpu_exception_level[1:0]),
    .head_instr_ls_iss_i          (head_instr_ls_iss),
    .ls_conditional_iss_i         (ls_conditional_iss),
    .enable_base_restore_de_i     (enable_base_restore_de),
    .flush_ls_wr_i                (flush_ls_wr),
    .flush_wr_i                   (flush_wr),
    .flush_ret_i                  (flush_ret),
    .advance_pipeline_i           (advance_pipeline),
    .slot0_br_flush_wr_i          (slot0_br_flush_wr),
    .spec_endianness_iss_i        (spec_endianness_iss),
    .spec_endianness_ex2_i        (spec_endianness_ex2),
    .skid_x64_multiple_de_i       (skid_x64_multiple_de),
    .ls_valid_de_i                (ls_valid_de),
    .ls_length_de_i               (ls_length_de[5:0]),
    .ls_store_de_i                (ls_store_de),
    .ls_store_neon_de_i           (ls_store_neon_de),
    .ls_size_de_i                 (ls_size_de[2:0]),
    .ls_elem_size_de_i            (ls_elem_size_de[2:0]),
    .ls_instr_type_de_i           (ls_instr_type_de[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_isv_set_de_i              (ls_isv_set_de),
    .ls_synd_sf_de_i              (ls_synd_sf_de),
    .ls_synd_srt_de_i             (ls_synd_srt_de),
    .ls_check_stack_de_i          (ls_check_stack_de),
    .cp_de_i                      (cp_de),
    .cp_op_de_i                   (cp_op_de),
    .cp_op_mva_de_i               (cp_op_mva_de),
    .force_usr_priv_mem_de_i      (force_usr_priv_mem_de),
    .agu_shf_value_de_i           (agu_shf_value_de[2:0]),
    .agu_data_a_sel_de_i          (agu_data_a_sel_de[`CA53_SEL_DCU_A_W-1:0]),
    .sel_fwd_dcu_a_iss_i          (sel_fwd_dcu_a_iss[`CA53_SEL_FWD_DCU_W-1:0]),
    .sel_fwd_addr_dcu_a_iss_i     (sel_fwd_addr_dcu_a_iss),
    .agu_data_b_sel_de_i          (agu_data_b_sel_de[`CA53_SEL_DCU_B_W-1:0]),
    .sel_fwd_dcu_b_iss_i          (sel_fwd_dcu_b_iss[`CA53_SEL_FWD_DCU_W-1:0]),
    .agu_sub_b_de_i               (agu_sub_b_de),
    .rf_rd_data_r0_agu_iss_i      (rf_rd_data_r0_agu_iss[63:0]),
    .rf_rd_data_r1_agu_iss_i      (rf_rd_data_r1_agu_iss[63:0]),
    .alu0_fwd_data_early_ex2_i    (alu0_fwd_data_early_ex2[63:0]),
    .alu1_fwd_data_early_ex2_i    (alu1_fwd_data_early_ex2[63:0]),
    .alu0_fwd_data_early_wr_i     (alu0_fwd_data_early_wr[63:0]),
    .alu1_fwd_data_early_wr_i     (alu1_fwd_data_early_wr[63:0]),
    .pc_instr0_iss_i              (pc_instr0_iss[63:1]),
    .pc_instr1_iss_i              (pc_instr1_iss[48:1]),
    .wd_align_pc_ls_iss_i         (wd_align_pc_ls_iss),
    .pg_align_pc_ls_iss_i         (pg_align_pc_ls_iss),
    .imm_data_ls_de_i             (imm_data_ls_de[32:0]),
    .slot1_ls_de_i                (slot1_ls_de),
    .dcu_ld_data_dc3_i            (dcu_ld_data_dc3_i[63:0]),
    .dcu_ready_iss_i              (dcu_ready_iss_i),
    .dcu_ready_cp_iss_i           (dcu_ready_cp_iss_i),
    .dcu_valid_dc3_i              (dcu_valid_dc3_i),
    .req_strict_algn_de_i         (req_strict_algn_de),
    .check_x64_de_i               (check_x64_de),
    .algn_size_de_i               (algn_size_de),
    .sctlr_align_check_i          (sctlr_align_check),
    .cp_op_ats1_de_i              (cp_op_ats1_de),
    .cp_other_sec_de_i            (cp_other_sec_de),
    .tlb_d_utlb_enable_i          (tlb_d_utlb_enable_i),
    .tlb_d_utlb_might_enable_i    (tlb_d_utlb_might_enable_i),
    .tlb_d_utlb_valid_i           (tlb_d_utlb_valid_i),
    .tlb_d_utlb_lpae_i            (tlb_d_utlb_lpae_i),
    .tlb_d_utlb_data_i            (tlb_d_utlb_data_i[95:0]),
    .tlb_d_utlb_flush_i           (tlb_d_utlb_flush_i),
    .flush_d_utlb_i               (flush_d_utlb),
    .tlb_lpae_mode_i              (tlb_lpae_mode_i),
    .dpu_dacr_i                   (dpu_dacr),
    .dpu_dacr_ns_i                (dpu_dacr_ns),
    .dpu_default_cacheable_i      (dpu_default_cacheable),
    .dpu_dacr_mmu_on_i            (dpu_dacr_mmu_on),
    .dpu_mmu_on_el1_i             (dpu_mmu_on_el1),
    .ns_state_i                   (ns_state),
    .raw_cp_valid_wr_i            (raw_cp_valid_wr),
    .neon_instr_iss_i             (neon_instr_iss[1:0]),
    // Outputs
    .dpu_agu_a_operand_iss_o      (dpu_agu_a_operand_iss_o),
    .dpu_agu_b_operand_iss_o      (dpu_agu_b_operand_iss_o),
    .dpu_agu_carry_out_64b_iss_o  (dpu_agu_carry_out_64b_iss_o),
    .dcu_not_ready_iss_o          (dcu_not_ready_iss),
    .first_lsm_skidding_o         (first_lsm_skidding),
    .inter_lsm_skidding_o         (inter_lsm_skidding),
    .lsm_skidding_o               (lsm_skidding),
    .lsm_64b_be_o                 (lsm_64b_be),
    .lsm_64b_be_skidding_o        (lsm_64b_be_skidding),
    .lsm_n64b_be_skidding_o       (lsm_n64b_be_skidding),
    .last_lsm_skidding_o          (last_lsm_skidding),
    .ls_128b_be_o                 (ls_128b_be),
    .force_extra_lsm_cycle_o      (force_extra_lsm_cycle),
    .extra_lsm_cycle_o            (extra_lsm_cycle),
    .ldr_no_early_fwd_iss_o       (ldr_no_early_fwd_iss),
    .ls_stall_wr_o                (ls_stall_wr),
    .first_x64_iss_o              (first_x64_iss),
    .agu_data_a_sel_iss_o         (agu_data_a_sel_iss[`CA53_SEL_DCU_A_W-1:0]),
    .agu_data_b_sel_iss_o         (agu_data_b_sel_iss[`CA53_SEL_DCU_B_W-1:0]),
    .v_addr_ex2_o                 (v_addr_ex2[3:0]),
    .ls_size_wr_o                 (ls_size_wr[1:0]),
    .ls_elem_size_ex2_o           (ls_elem_size_ex2[1:0]),
    .ls_elem_size_wr_o            (ls_elem_size_wr[1:0]),
    .ls_store_ex2_o               (ls_store_ex2),
    .ls_store_wr_o                (ls_store_wr),
    .ls_store_neon_ex2_o          (ls_store_neon_ex2),
    .ls_instr_type_wr_o           (ls_instr_type_wr[`CA53_LS_INSTR_TYPE_W-1:0]),
    .ls_isv_set_wr_o              (ls_isv_set_wr),
    .ls_synd_sf_wr_o              (ls_synd_sf_wr),
    .ls_synd_srt_wr_o             (ls_synd_srt_wr[4:0]),
    .ldc_ex2_o                    (ldc_ex2),
    .ldc_stc_wr_o                 (ldc_stc_wr),
    .srs_wr_o                     (srs_wr),
    .ls_valid_iss_o               (ls_valid_iss),
    .ls_valid_ex1_o               (ls_valid_ex1),
    .ls_valid_ex2_o               (ls_valid_ex2),
    .ls_valid_wr_o                (ls_valid_wr),
    .first_x64_wr_o               (first_x64_wr),
    .ongoing_ldm_wr_o             (ongoing_ldm_wr),
    .dpu_valid_iss_o              (dpu_valid_iss_o),
    .dpu_valid_cp_iss_o           (dpu_valid_cp_iss_o),
    .dpu_store_iss_o              (dpu_store_iss_o),
    .dpu_strobe_iss_o             (dpu_strobe_iss_o[15:0]),
    .dpu_excl_iss_o               (dpu_excl_iss_o),
    .dpu_ldar_stlr_iss_o          (dpu_ldar_stlr_iss_o),
    .dpu_non_temporal_iss_o       (dpu_non_temporal_iss_o),
    .dpu_pld_iss_o                (dpu_pld_iss_o),
    .dpu_pld_level_iss_o          (dpu_pld_level_iss_o),
    .dpu_priv_iss_o               (dpu_priv_iss_o),
    .dpu_first_iss_o              (dpu_first_iss_o),
    .dpu_force_first_iss_o        (dpu_force_first_iss_o),
    .dpu_neon_access_iss_o        (dpu_neon_access_iss_o),
    .second_x64_iss_o             (second_x64_iss),
    .dpu_length_iss_o             (dpu_length_iss_o[4:0]),
    .dpu_size_iss_o               (dpu_size_iss_o[1:0]),
    .dpu_req_align_iss_o          (dpu_req_align_iss_o),
    .dpu_align_size_iss_o         (dpu_align_size_iss_o[2:0]),
    .ls_multiple_iss_o            (ls_multiple_iss),
    .ls_store_iss_o               (ls_store_iss),
    .dpu_cross_64_iss_o           (dpu_cross_64_iss_o),
    .dpu_burst_iss_o              (dpu_burst_iss_o),
    .dpu_cp_op_iss_o              (dpu_cp_op_iss_o),
    .fwd_ld_data_int_wr_o         (fwd_ld_data_int_wr[63:0]),
    .ld_data0_wr_o                (ld_data0_wr[63:0]),
    .ld_data1_wr_o                (ld_data1_wr[63:0]),
    .dpu_cc_fail_wr_o             (dpu_cc_fail_wr_o),
    .dpu_ready_wr_o               (dpu_ready_wr_o),
    .dpu_ready_cc_fail_wr_o       (dpu_ready_cc_fail_wr_o),
    .dpu_ready_cc_pass_wr_o       (dpu_ready_cc_pass_wr_o),
    .enable_base_restore_iss_o    (enable_base_restore_iss),
    .dpu_utlb_hit_dc1_o           (dpu_utlb_hit_dc1_o),
    .dpu_utlb_hit_entry_dc1_o     (dpu_utlb_hit_entry_dc1_o),
    .dpu_domain_dc1_o             (dpu_domain_dc1_o[3:0]),
    .dpu_abort_dc1_o              (dpu_abort_dc1_o),
    .dpu_stack_align_expt_dc1_o   (dpu_stack_align_expt_dc1_o),
    .dpu_level_dc1_o              (dpu_level_dc1_o),
    .dpu_lpae_dc1_o               (dpu_lpae_dc1_o),
    .dpu_attributes_dc1_o         (dpu_attributes_dc1_o[12:0]),
    .dpu_fault_dc1_o              (dpu_fault_dc1_o[8:0]),
    .dpu_ns_dsc_dc1_o             (dpu_ns_dsc_dc1_o),
    .dpu_pa_dc1_o                 (dpu_pa_dc1_o[39:12]),
    .dpu_va_dc1_o                 (dpu_va_dc1_o[63:0]),
    .evnt_data_rd_wr_o            (evnt_data_rd_wr),
    .evnt_data_wr_wr_o            (evnt_data_wr_wr),
    .evnt_unaligned_ls_o          (evnt_unaligned_ls),
    .evnt_data_mem_access_o       (evnt_data_mem_access)
  );

  // ------------------------------------------------------
  // Branch pipeline
  // ------------------------------------------------------

  ca53dpu_br u_dpu_br (
    // Inputs
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .aarch64_state_i                 (aarch64_state),
    .pc_instr0_ex2_i                 (pc_instr0_ex2[48:1]),
    .isa_switch_br_ex2_i             (isa_switch_br_ex2),
    .rtn_addr_valid_de_i             (rtn_addr_valid_de),
    .br_offset_de_i                  (br_offset_de[27:1]),
    .br_pipectl_de_i                 (br_pipectl_de[(`CA53_BR_PIPECTL_W-1):0]),
    .br_valid_de_i                   (br_valid_de),
    .st0_data_wr_i                   (st0_data_wr[63:0]),
    .st1_data_wr_i                   (st1_data_wr[63:0]),
    .ld_data0_wr_i                   (ld_data0_wr[15:0]),
    .fwd_ld_data_int_wr_i            (fwd_ld_data_int_wr[63:0]),
    .alu0_fwd_data_early_wr_i        (alu0_fwd_data_early_wr[31:0]),
    .isa_instr0_ex2_i                (isa_instr0_ex2[1:0]),
    .size_instr0_ex2_i               (size_instr0_ex2),
    .size_instr1_ex2_i               (size_instr1_ex2),
    .br_pred_takenness_de_i          (br_pred_takenness_de),
    .cc_pass_instr0_cbz_ex2_i        (cc_pass_instr0_cbz_ex2),
    .cc_pass_instr1_cbz_ex2_i        (cc_pass_instr1_cbz_ex2),
    .cc_pass_instr0_wr_i             (cc_pass_instr0_wr),
    .cc_pass_instr1_wr_i             (cc_pass_instr1_wr),
    .dpu_pred_br_de_i                (dpu_pred_br_de),
    .dpu_br_return_de_i              (dpu_br_return_de),
    .dpu_br_call_de_i                (dpu_br_call_de),
    .br_btac_de_i                    (br_btac_de),
    .slot1_branch_ex2_i              (slot1_branch_ex2),
    .slot1_branch_wr_i               (slot1_branch_wr),
    .issue_to_ex1_i                  (issue_to_ex1),
    .issue_to_ex2_i                  (issue_to_ex2),
    .issue_to_wr_i                   (issue_to_wr),
    .stall_wr_i                      (stall_wr),
    .stall_iss_i                     (stall_iss),
    .stall_br_iss_i                  (stall_br_iss),
    .exception_valid_ex1_i           (exception_valid_ex1),
    .isb_wr_i                        (isb_wr),
    .expt_rtn_wr_i                   (expt_rtn_wr),
    .insert_forceop_wr_i             (insert_forceop_wr),
    .insert_forceop_ret_i            (insert_forceop_ret),
    .forceop_pc_ret_i                (forceop_pc_ret[63:0]),
    .forceop_pc_offset_ret_i         (forceop_pc_offset_ret[17:1]),
    .in_halt_i                       (in_halt),
    .quash_ex2_i                     (quash_ex2),
    .expt_quash_wr_i                 (expt_quash_wr),
    .pc_instr0_wr_i                  (pc_instr0_wr[63:0]),
    .flush_wr_i                      (flush_wr),
    .flush_ret_i                     (flush_ret),
    .advance_pipeline_i              (advance_pipeline),
    .quash_wr_i                      (quash_wr),
    .nxt_wfx_ifu_halt_i              (nxt_wfx_ifu_halt),
    .wfx_ifu_halt_i                  (wfx_ifu_halt),
    .force_wfx_nop_i                 (force_wfx_nop),
    .nxt_cpsr_tbit_ret_pre_i         (nxt_cpsr_tbit_ret_pre),
    .ongoing_ldm_wr_i                (ongoing_ldm_wr),
    .sel_rf_wr_w0_wr_i               (sel_rf_wr_w0_wr),
    .ifu_pred_addr_if4_i             (ifu_pred_addr_if4_i[48:0]),
    .ifu_pred_addr_valid_if4_i       (ifu_pred_addr_valid_if4_i),
    .branch_align_pc_wr_i            (branch_align_pc_wr),
    .debug_exit_aa32_i               (debug_exit_aa32),
    .dpu_exception_level_i           (dpu_exception_level[1:0]),
    .tlb_d_tcr_el1_tbi_i             (tlb_d_tcr_el1_tbi_i[1:0]),
    .tlb_d_tcr_el2_tbi0_i            (tlb_d_tcr_el2_tbi0_i),
    .tlb_d_tcr_el3_tbi0_i            (tlb_d_tcr_el3_tbi0_i),
    // Outputs
    .rtn_addr_iss_o                  (rtn_addr_iss[48:1]),
    .br_offset_iss_o                 (br_offset_iss[27:1]),
    .tbit_btac_rtn_instr_iss_o       (tbit_btac_rtn_instr_iss),
    .dpu_pred_br_ex2_o               (dpu_pred_br_ex2_o),
    .dpu_br_addr_ex2_o               (dpu_br_addr_ex2_o[12:3]),
    .dpu_pred_br_wr_o                (dpu_pred_br_wr),
    .dpu_br_return_wr_o              (dpu_br_return_wr),
    .dpu_br_call_wr_o                (dpu_br_call_wr_o),
    .dpu_btac_ret_o                  (dpu_btac_ret_o),
    .dpu_mispred_wr_o                (dpu_mispred_wr),
    .dpu_br_taken_wr_o               (dpu_br_taken_wr),
    .dpu_fe_valid_ret_o              (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_ret_o           (dpu_fe_addr_opa_ret[63:0]),
    .dpu_fe_addr_opb_ret_o           (dpu_fe_addr_opb_ret[17:1]),
    .dpu_fe_context_sync_ret_o       (dpu_fe_context_sync_ret_o),
    .dpu_valid_branch_instr_wr_o     (dpu_valid_branch_instr_wr),
    .prefetch_flush_wr_o             (prefetch_flush_wr),
    .br_direct_wr_o                  (br_direct_wr),
    .br_pred_takenness_wr_o          (br_pred_takenness_wr),
    .mis_predicted_branch_wr_o       (mis_predicted_branch_wr),
    .br_call_wr_o                    (br_call_wr),
    .evnt_br_valid_wr_o              (evnt_br_valid_wr),
    .evnt_br_mispred_o               (evnt_br_mispred),
    .evnt_br_direct_wr_o             (evnt_br_direct_wr),
    .evnt_br_indirect_o              (evnt_br_indirect),
    .evnt_br_indirect_mispred_o      (evnt_br_indirect_mispred),
    .evnt_br_indirect_mispred_addr_o (evnt_br_indirect_mispred_addr),
    .evnt_sw_change_pc_o             (evnt_sw_change_pc),
    .br_flush_wr_o                   (br_flush_wr),
    .slot0_br_flush_wr_o             (slot0_br_flush_wr),
    .br_flush_ret_o                  (br_flush_ret),
    .btac_rtn_instr_iss_o            (btac_rtn_instr_iss),
    .taken_br_instr_iss_o            (taken_br_instr_iss),
    .ld_t_bit_wr_o                   (ld_t_bit_wr),
    .incr_pc_halt_mode_ret_o         (incr_pc_halt_mode_ret),
    .dpu_fe_valid_wr_o               (dpu_fe_valid_wr),
    .dpu_fe_addr_opa_wr_o            (dpu_fe_addr_opa_wr[48:1]),
    .dpu_fe_addr_opb_wr_o            (dpu_fe_addr_opb_wr[27:1]),
    .paq_full_o                      (paq_full),
    .paq_stall_iss_o                 (paq_stall_iss)
  );

  // ------------------------------------------------------
  // Integer Register File
  // ------------------------------------------------------

  ca53dpu_regbank u_dpu_regbank (
    // Inputs
    .clk                       (clk),
    .reset_n                   (reset_n),
    .DFTSE                     (DFTSE),
    .aarch64_state_i           (aarch64_state),
    .aarch64_state_iss_i       (aarch64_state_iss),
    .long_rf_rd_addr_r0_de_i   (long_rf_rd_addr_r0_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r1_de_i   (long_rf_rd_addr_r1_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r0_agu_de_i    (rf_rd_addr_r0_agu_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_addr_r1_agu_de_i    (rf_rd_addr_r1_agu_de[`CA53_LONG_RF_ADDR_W-1:0]),
    .rf_rd_r0_agu_de_i         (rf_rd_r0_agu_de[2:0]),
    .rf_rd_r1_agu_de_i         (rf_rd_r1_agu_de[2:0]),
    .en_rf_rd_r0_agu_de_i      (en_rf_rd_r0_agu_de),
    .en_rf_rd_r1_agu_de_i      (en_rf_rd_r1_agu_de),
    .issue_to_iss_i            (issue_to_iss),
    .ilock_stall_iss_i         (ilock_stall_iss),
    .ls_valid_de_i             (ls_valid_de),
    .rf_rd_en_r0_de_i          (rf_rd_en_r0_de),
    .rf_rd_en_r1_de_i          (rf_rd_en_r1_de),
    .long_rf_rd_addr_r2_iss_i  (long_rf_rd_addr_r2_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r3_iss_i  (long_rf_rd_addr_r3_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .long_rf_rd_addr_r4_iss_i  (long_rf_rd_addr_r4_iss[`CA53_LONG_RF_ADDR_W-1:0]),
    .sel_rf_wr_w0_wr_i         (sel_rf_wr_w0_wr),
    .sel_rf_wr_w1_wr_i         (sel_rf_wr_w1_wr),
    .sel_rf_wr_w2_wr_i         (sel_rf_wr_w2_wr),
    .rf_wr_en_hi_wr_i          (rf_wr_en_hi_wr),
    .rf_wr_en_lo_wr_i          (rf_wr_en_lo_wr),
    .rf_wr_en_w0_wr_i          (rf_wr_en_w0_wr),
    .rf_wr_en_w1_wr_i          (rf_wr_en_w1_wr),
    .rf_wr_en_w2_wr_i          (rf_wr_en_w2_wr),
    .rf_wr_64b_w0_wr_i         (rf_wr_64b_w0_wr),
    .rf_wr_64b_w1_wr_i         (rf_wr_64b_w1_wr),
    .rf_wr_64b_w2_wr_i         (rf_wr_64b_w2_wr),
    .rf_wr_addr_w0_wr_i        (rf_wr_addr_w0_wr[5:0]),
    .rf_wr_addr_w1_wr_i        (rf_wr_addr_w1_wr[5:0]),
    .rf_wr_addr_w2_wr_i        (rf_wr_addr_w2_wr[5:0]),
    .rf_wr_data_w0_wr_i        (rf_wr_data_w0_wr[63:0]),
    .rf_wr_data_w1_wr_i        (rf_wr_data_w1_wr[63:0]),
    .rf_wr_data_w2_wr_i        (rf_wr_data_w2_wr[63:0]),
    // Outputs
    .rf_rd_data_r0_iss_o       (rf_rd_data_r0_iss[63:0]),
    .rf_rd_data_r0_agu_iss_o   (rf_rd_data_r0_agu_iss[63:0]),
    .rf_rd_data_r1_iss_o       (rf_rd_data_r1_iss[63:0]),
    .rf_rd_data_r1_agu_iss_o   (rf_rd_data_r1_agu_iss[63:0]),
    .rf_rd_data_r2_iss_o       (rf_rd_data_r2_iss[63:0]),
    .rf_rd_data_r3_iss_o       (rf_rd_data_r3_iss[63:0]),
    .rf_rd_data_r4_iss_o       (rf_rd_data_r4_iss[63:0])
  );

  // ------------------------------------------------------
  // ETM Interface
  // ------------------------------------------------------

  ca53dpu_etmif `CA53_DPU_PARAM_INST u_dpu_etmif (
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .po_reset_n                   (po_reset_n),
    .DFTSE                        (DFTSE),
    .etm_if_en_i                  (etm_if_en_i),
    .valid_instrs_wr_i            (valid_instrs_wr[1:0]),
    .end_instr_no_quash_wr_i      (end_instr_no_quash_wr),
    .pc_instr0_wr_i               (pc_instr0_wr[63:1]),
    .pc_instr0_ret_i              (pc_instr0_ret[63:1]),
    .cpsr_tbit_ret_i              (cpsr_tbit_ret),
    .cpsr_mode_ret_i              (cpsr_mode_ret[4:0]),
    .dpu_exception_level_i        (dpu_exception_level[1:0]),
    .size_instr0_wr_i             (size_instr0_wr),
    .size_instr1_wr_i             (size_instr1_wr),
    .size_instr0_ret_i            (size_instr0_ret),
    .size_instr1_ret_i            (size_instr1_ret),
    .isa_instr0_wr_i              (isa_instr0_wr[1:0]),
    .isa_instr0_ret_i             (isa_instr0_ret[1:0]),
    .quash_wr_i                   (quash_wr),
    .quash_slot0_wr_i             (quash_slot0_wr),
    .slot0_br_flush_wr_i          (slot0_br_flush_wr),
    .isb_wr_i                     (isb_wr),
    .expt_rtn_wr_i                (expt_rtn_wr),
    .dpu_valid_branch_instr_wr_i  (dpu_valid_branch_instr_wr),
    .slot1_branch_wr_i            (slot1_branch_wr),
    .br_direct_wr_i               (br_direct_wr),
    .br_pred_takenness_wr_i       (br_pred_takenness_wr),
    .mis_predicted_branch_wr_i    (mis_predicted_branch_wr),
    .br_call_wr_i                 (br_call_wr),
    .dpu_fe_valid_ret_i           (dpu_fe_valid_ret),
    .dpu_fe_addr_opa_ret_i        (dpu_fe_addr_opa_ret[63:1]),
    .dpu_fe_addr_opb_ret_i        (dpu_fe_addr_opb_ret[17:1]),
    .dpu_fe_addr_opb_wr_i         (dpu_fe_addr_opb_wr[27:1]),
    .etm_trace_expt_i             (etm_trace_expt),
    .etm_trace_dbgentry_i         (etm_trace_dbgentry),
    .expt_dbgexit_i               (expt_dbgexit),
    .expt_slot1_ret_i             (expt_slot1_ret),
    .stall_wr_i                   (stall_wr),
    .expt_type_i                  (expt_type[`CA53_EXPT_TYPE_W-1:0]),
    .expt_cpsr_mode_ret_i         (expt_cpsr_mode_ret[4:0]),
    .dbgdscr_halted_i             (dbgdscr_halted),
    .ns_state_i                   (ns_state),
    .dbg_non_inv_perm_us_i        (dbg_non_inv_perm_us),
    .dbg_non_inv_perm_synced_i    (dbg_non_inv_perm_synced),
    // Outputs
    .dpu_wpt_valid_o              (dpu_wpt_valid_o),
    .dpu_wpt_addr_o               (dpu_wpt_addr_o),
    .dpu_wpt_target_addr_opa_o    (dpu_wpt_target_addr_opa_o[63:1]),
    .dpu_wpt_target_addr_opb_o    (dpu_wpt_target_addr_opb_o[27:1]),
    .dpu_wpt_advance_o            (dpu_wpt_advance_o),
    .dpu_wpt_range_o              (dpu_wpt_range_o),
    .dpu_wpt_type_o               (dpu_wpt_type_o),
    .dpu_wpt_link_o               (dpu_wpt_link_o),
    .dpu_wpt_taken_o              (dpu_wpt_taken_o),
    .dpu_wpt_target_isa_o         (dpu_wpt_target_isa_o),
    .dpu_wpt_t32_nt16_o           (dpu_wpt_t32_nt16_o),
    .dpu_wpt_exception_type_o     (dpu_wpt_exception_type_o),
    .dpu_wpt_non_secure_o         (dpu_wpt_non_secure_o),
    .dpu_wpt_exlevel_o            (dpu_wpt_exlevel_o),
    .dpu_wpt_prohibited_o         (dpu_wpt_prohibited_o)
  );

  // ------------------------------------------------------
  // Debug Interface
  // ------------------------------------------------------

  ca53dpu_dbg `CA53_DPU_PARAM_INST u_dpu_dbg (
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .po_reset_n                       (po_reset_n),
    .DFTSE                            (DFTSE),
    .aarch64_state_i                  (aarch64_state),
    .aarch64_at_el_i                  (aarch64_at_el),
    .dpu_exception_level_i            (dpu_exception_level[1:0]),
    .target_exception_level_i         (target_exception_level),
    .pre_valid_instrs_wr_i            (pre_valid_instrs_wr),
    .end_instr_wr_i                   (end_instr_dbg_wr),
    .expt_status_moe_data_wr_i        (expt_status_moe_data_wr[3:0]),
    .expt_quash_wr_i                  (expt_quash_wr),
    .expt_idle_i                      (expt_idle),
    .no_interrupt_wr_i                (no_interrupt_wr),
    .gov_dbgromaddr_i                 (gov_dbgromaddr_i[39:12]),
    .gov_dbgromaddrv_i                (gov_dbgromaddrv_i),
    .gov_edecr_osuce_i                (gov_edecr_osuce_i),
    .gov_edecr_rce_i                  (gov_edecr_rce_i),
    .gov_edecr_ss_i                   (gov_edecr_ss_i),
    .gov_edlsr_slk_i                  (gov_edlsr_slk_i),
    .gov_pmlsr_slk_i                  (gov_pmlsr_slk_i),
    .gov_dbgpwrupreq_i                (gov_dbgpwrupreq_i),
    .cp_valid_wr_i                    (cp_valid_wr),
    .nxt_cp_valid_wr_i                (nxt_cp_valid_wr),
    .raw_cp_decode_wr_i               (raw_cp_decode_wr[8:0]),
    .mcr_data_wr_i                    (mcr_data_wr[63:0]),
    .dpu_fe_valid_ret_i               (dpu_fe_valid_ret),
    .expt_in_halt_i                   (expt_in_halt),
    .end_expt_in_halt_i               (end_expt_in_halt),
    .expt_fault_reg_sel_wr_i          (expt_fault_reg_sel_wr),
    .dbg_event_i                      (dbg_event),
    .dbg_event_halt_wr_i              (dbg_event_halt_wr),
    .dbg_ss_vld_expt_type_ret_i       (dbg_ss_vld_expt_type_ret),
    .dbg_expt_i                       (dbg_expt),
    .expt_dbgexit_i                   (expt_dbgexit),
    .stall_wr_i                       (stall_wr),
    .quash_wr_i                       (quash_wr),
    .flush_wr_i                       (flush_wr),
    .first_x64_wr_i                   (first_x64_wr),
    .fwd_ld_data_int_wr_i             (fwd_ld_data_int_wr[31:0]),
    .pc_instr0_ret_i                  (pc_instr0_ret[48:0]),
    .pc_sample_perm_i                 (pc_sample_perm),
    .isa_instr0_ret_i                 (isa_instr0_ret[1:0]),
    .cc_pass_instr0_wr_i              (cc_pass_instr0_wr),
    .dcu_dbg_dsb_ack_i                (dcu_dbg_dsb_ack_i),
    .ifu_dbg_ready_i                  (ifu_dbg_ready_i),
    .gov_dbgen_i                      (gov_dbgen_i),
    .gov_niden_i                      (gov_niden_i),
    .gov_spiden_i                     (gov_spiden_i),
    .gov_spniden_i                    (gov_spniden_i),
    .cp_sder_i                        (cp_sder[1:0]),
    .gov_edbgrq_i                     (gov_edbgrq_i),
    .gov_dbgrestart_i                 (gov_dbgrestart_i),
    .cpsr_dbit_ret_i                  (cpsr_dbit_ret),
    .cpsr_mode_ret_i                  (cpsr_mode_ret[4:0]),
    .ns_state_i                       (ns_state),
    .ns_scr_i                         (ns_scr),
    .gov_pseldbg_dbg_i                (gov_pseldbg_dbg_i),
    .gov_pseldbg_pmu_i                (gov_pseldbg_pmu_i),
    .gov_pwritedbg_i                  (gov_pwritedbg_i),
    .gov_paddrdbg_i                   (gov_paddrdbg_i[11:2]),
    .gov_paddrdbg31_i                 (gov_paddrdbg31_i),
    .gov_pwdatadbg_i                  (gov_pwdatadbg_i[31:0]),
    .ldc_ex2_i                        (ldc_ex2),
    .ls_store_wr_i                    (ls_store_wr),
    .ldc_stc_wr_i                     (ldc_stc_wr),
    .tlb_dbg_rdata_i                  (tlb_dbg_rdata_i[31:0]),
    .pmu_apb_rdata_i                  (pmu_apb_rdata[31:0]),
    .apb_pmu_access_i                 (apb_pmu_access),
    .hdcr_tde_i                       (hdcr_tde),
    .cp_mdcr_el3_sdd_i                (cp_mdcr_el3_sdd),
    .cp_mdcr_el3_spd32_i              (cp_mdcr_el3_spd32),
    .cp_mdcr_el3_spme_i               (cp_mdcr_el3_spme),
    .cp_mdcr_el3_epmad_i              (cp_mdcr_el3_epmad),
    .cp_mdcr_el3_edad_i               (cp_mdcr_el3_edad),
    .expt_serr_pending_i              (expt_serr_pending),
    .dspsr_reg_i                      (dspsr_reg),
    .forceop_valid_wr_i               (forceop_valid_wr),
    .dcu_va_dc3_i                     (dcu_va_dc3_i[63:0]),
    .expt_type_l1_ecc_i               (expt_type_l1_ecc),
    // Outputs
    .in_halt_o                        (in_halt),
    .dbg_hw_halt_req_o                (dbg_hw_halt_req),
    .held_dbg_hw_halt_req_o           (held_dbg_hw_halt_req),
    .held_dbg_osuc_halt_req_o         (held_dbg_osuc_halt_req),
    .held_dbg_ext_hw_halt_req_o       (held_dbg_ext_hw_halt_req),
    .dbg_restart_qual_o               (dbg_restart_qual),
    .dbg_cancel_biu_o                 (dbg_cancel_biu),
    .dbg_cp_rd_data_o                 (dbg_cp_rd_data[63:0]),
    .cpsr_flag_update_nzcv_o          (cpsr_flag_update_nzcv[3:0]),
    .cpsr_flag_update_cp_dscr_wr_o    (cpsr_flag_update_cp_dscr_wr),
    .dpu_dbg_ins_o                    (dpu_dbg_ins_o[31:0]),
    .dpu_dbg_valid_o                  (dpu_dbg_valid_o),
    .dbgdscr_halted_o                 (dbgdscr_halted),
    .edscr_sdd_o                      (edscr_sdd),
    .edscr_tda_o                      (edscr_tda),
    .edscr_intdis_o                   (edscr_intdis[1:0]),
    .dbgen_synced_o                   (dbgen_synced),
    .spiden_synced_o                  (spiden_synced),
    .dbg_hlt_en_o                     (dbg_hlt_en),
    .dbg_bkpt_wpt_en_o                (dbg_bkpt_wpt_en),
    .dbg_dtrrx_data_o                 (dbg_dtrrx_data[31:0]),
    .dpu_apb_active_o                 (dpu_apb_active_o),
    .dpu_dbg_dsb_req_o                (dpu_dbg_dsb_req_o),
    .dpu_dbg_tlb_sw_bkpt_wpt_en_o     (dpu_dbg_tlb_sw_bkpt_wpt_en_o),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_o     (dpu_dbg_tlb_hw_bkpt_wpt_en_o),
    .dpu_dbg_sample_contextid_o       (dpu_dbg_sample_contextid_o),
    .dpu_dbgtrigger_o                 (dpu_dbgtrigger_o),
    .dpu_dbgack_o                     (dpu_dbgack_o),
    .dpu_commrx_o                     (dpu_commrx_o),
    .dpu_commtx_o                     (dpu_commtx_o),
    .dpu_ncommirq_o                   (dpu_ncommirq_o),
    .dpu_prdatadbg_o                  (dpu_prdatadbg_o[31:0]),
    .dpu_preadydbg_o                  (dpu_preadydbg_o),
    .dpu_pslverrdbg_o                 (dpu_pslverrdbg_o),
    .dpu_dbg_wr_o                     (dpu_dbg_wr_o),
    .apb_addr_o                       (apb_addr[11:2]),
    .apb_wdata_o                      (apb_wdata[31:0]),
    .dpu_dbgnopwrdwn_o                (dpu_dbgnopwrdwn_o),
    .dpu_dbgrstreq_o                  (dpu_dbgrstreq_o),
    .dbg_non_inv_perm_us_o            (dbg_non_inv_perm_us),
    .dbg_non_inv_perm_synced_o        (dbg_non_inv_perm_synced),
    .dbg_os_lock_synced_o             (dbg_os_lock_synced),
    .dbg_double_lock_set_o            (dbg_double_lock_set),
    .pmu_apb_wr_o                     (pmu_apb_wr),
    .nxt_pmu_apb_wr_o                 (nxt_pmu_apb_wr),
    .dbg_halting_allowed_o            (dbg_halting_allowed),
    .cp14_wr_dspsr_o                  (cp14_wr_dspsr),
    .dbg_starting_o                   (dbg_starting),
    .ss_enter_halt_o                  (ss_enter_halt),
    .edecr_ss_reg_o                   (edecr_ss_reg),
    .exception_level_debug_o          (exception_level_debug[1:0]),
    .debug_enabled_from_el_o          (debug_enabled_from_el[3:0]),
    .mdscr_el1_tdcc_o                 (mdscr_el1_tdcc),
    .mdscr_el1_ss_o                   (mdscr_el1_ss),
    .dbg_soft_step_active_o           (dbg_soft_step_active),
    .dbg_halt_step_active_not_pend_o  (dbg_halt_step_active_not_pend),
    .dpu_reset_catch_pending_o        (dpu_reset_catch_pending_o),
    .dpu_expt_catch_pending_o         (dpu_expt_catch_pending_o),
    .nxt_pc_sample_perm_o             (nxt_pc_sample_perm)
  );

  // ------------------------------------------------------
  // CPSR Pipeline
  // ------------------------------------------------------

  ca53dpu_cpsr `CA53_DPU_PARAM_INST u_dpu_cpsr (
    // Inputs
    .clk                        (clk),
    .reset_n                    (reset_n),
    .DFTSE                      (DFTSE),
    .expt_cpsr_wr_en_ret_i      (expt_cpsr_wr_en_ret[`CA53_SEL_CPSR_EN_W-1:0]),
    .expt_cpsr_wr_src_ret_i     (expt_cpsr_wr_src_ret[`CA53_SEL_CPSR_SRC_W-1:0]),
    .expt_cpsr_mode_ret_i       (expt_cpsr_mode_ret[4:0]),
    .it_cpsr_v_de_i             (t16o_it_cpsr_valid_de),
    .it_cpsr_mask_de_i          (t16o_it_cpsr_mask_de[7:0]),
    .mul_qbit_wr_i              (new_mac_qflag_wr),
    .insert_forceop_wr_i        (insert_forceop_wr),
    .insert_forceop_ret_i       (insert_forceop_ret),
    .issue_to_iss_i             (issue_to_iss),
    .cpsr_ebit_value_de_i       (cpsr_ebit_value_de),
    .ccflags_wr_i               (ccflags_wr[3:0]),
    .geflags_wr_i               (geflags_wr[3:0]),
    .aarch64_at_el_i            (aarch64_at_el[3:1]),
    .sctlr_endian_el1_i         (sctlr_endian_el1),
    .sctlr_endian_el2_i         (sctlr_endian_el2),
    .sctlr_endian_el3_i         (sctlr_endian_el3),
    .sctlr_el1_e0e_i            (sctlr_el1_e0e),
    .sctlr_el3_itd_i            (sctlr_el3_itd),
    .sctlr_el2_itd_i            (sctlr_el2_itd),
    .sctlr_el1_itd_i            (sctlr_el1_itd),
    .hsctlr_te_i                (hsctlr_te),
    .sctlr_ns_te_i              (sctlr_ns_te),
    .sctlr_s_te_i               (sctlr_s_te),
    .cpsr_aifbits_val_i         (cpsr_aifbits_val[5:0]),
    .stall_slot0_iss_i          (stall_slot0_iss),
    .stall_iss_i                (stall_iss),
    .stall_wr_i                 (stall_wr),
    .alu0_fwd_data_early_ex2_i  (alu0_fwd_data_early_ex2[5:0]),
    .alu0_fwd_data_early_wr_i   (alu0_fwd_data_early_wr[31:0]),
    .rfe_data_wr_i              (fwd_ld_data_int_wr[63:32]),
    .alu0_qbit_wr_i             (alu0_qbit_wr),
    .alu1_qbit_wr_i             (alu1_qbit_wr),
    .end_instr_wr_i             (end_instr_wr),
    .pre_end_instr_wr_i         (pre_end_instr_wr),
    .valid_instrs_wr_i          (valid_instrs_wr[1:0]),
    .cc_pass_instr0_wr_i        (cc_pass_instr0_wr),
    .cc_pass_instr1_wr_i        (cc_pass_instr1_wr),
    .flush_wr_i                 (flush_wr),
    .advance_pipeline_i         (advance_pipeline),
    .quash_wr_i                 (quash_wr),
    .quash_slot0_wr_i           (quash_slot0_wr),
    .expt_slot1_wr_i            (expt_slot1_wr),
    .ld_t_bit_wr_i              (ld_t_bit_wr),
    .prefetch_flush_wr_i        (prefetch_flush_wr),
    .in_halt_i                  (in_halt),
    .cpsr_flag_update_nzcv_i    (cpsr_flag_update_nzcv[3:0]),
    .hcr_tge_i                  (hcr_tge),
    .scr_ea_i                   (scr_ea),
    .scr_fiq_i                  (scr_fiq),
    .scr_irq_i                  (scr_irq),
    .wr_scr_i                   (wr_scr),
    .ns_scr_i                   (ns_scr),
    .ns_state_i                 (ns_state),
    .nxt_ns_scr_i               (nxt_ns_scr),
    .msr_mrs_data_wr_i          (msr_mrs_data_wr[3:0]),
    .psr_wr_operation_de_i      (psr_wr_operation_de),
    .psr_wr_en_de_i             (psr_wr_en_de),
    .psr_wr_src_de_i            (psr_wr_src_de),
    .slot1_blx_ex2_i            (slot1_blx_ex2),
    .slot1_bx_wr_i              (slot1_bx_wr),
    .slot1_blx_wr_i             (slot1_blx_wr),
    .slot1_mul_wr_i             (slot1_mul_wr),
    .flag_en_instr1_wr_i        (flag_en_instr1_wr[(`CA53_FLAGEN_INSTR1_W-1):0]),
    .br_flush_wr_i              (br_flush_wr),
    .raw_cp_decode_wr_i         (raw_cp_decode_wr[8:0]),
    .cp14_wr_dspsr_i            (cp14_wr_dspsr),
    .mcr_data_wr_i              (mcr_data_wr[31:0]),
    .dbg_starting_i             (dbg_starting),
    .exception_level_debug_i    (exception_level_debug[1:0]),
    .debug_enabled_from_el_i    (debug_enabled_from_el[3:0]),
    .mdscr_el1_ss_i             (mdscr_el1_ss),
    // Outputs
    .cpsr_ret_o                 (cpsr_ret[31:0]),
    .spsr_ret_o                 (spsr_ret[31:0]),
    .isa_switch_br_ex2_o        (isa_switch_br_ex2),
    .cpsr_masked_ret_o          (cpsr_masked_ret[31:0]),
    .psr_cp_rd_data_o           (psr_cp_rd_data[31:0]),
    .cpsr_ssbit_ret_o           (cpsr_ssbit_ret),
    .cpsr_ilbit_ret_o           (cpsr_ilbit_ret),
    .cpsr_dbit_ret_o            (cpsr_dbit_ret),
    .cpsr_abit_ret_o            (cpsr_abit_ret),
    .cpsr_ibit_ret_o            (cpsr_ibit_ret),
    .cpsr_fbit_ret_o            (cpsr_fbit_ret),
    .cpsr_tbit_wr_o             (cpsr_tbit_wr),
    .nxt_cpsr_tbit_ret_pre_o    (nxt_cpsr_tbit_ret_pre),
    .dpu_fe_isa_wr_o            (dpu_fe_isa_wr_o[1:0]),
    .dpu_fe_isa_ret_o           (dpu_fe_isa_ret_o[1:0]),
    .dpu_fe_itstate_ret_o       (dpu_fe_itstate_ret_o[7:0]),
    .spec_cpsr_mode_iss_o       (spec_cpsr_mode_iss[4:0]),
    .spec_cpsr_mode_usr_iss_o   (spec_cpsr_mode_usr_iss),
    .spec_cpsr_mode_sys_iss_o   (spec_cpsr_mode_sys_iss),
    .spec_cpsr_mode_mon_iss_o   (spec_cpsr_mode_mon_iss),
    .spec_cpsr_mode_hyp_iss_o   (spec_cpsr_mode_hyp_iss),
    .nxt_mon_el3_mode_ret_o     (nxt_mon_el3_mode_ret),
    .dpu_exception_level_o      (dpu_exception_level[1:0]),
    .cpsr_tbit_ret_o            (cpsr_tbit_ret),
    .branch_align_pc_wr_o       (branch_align_pc_wr),
    .debug_exit_aa32_o          (debug_exit_aa32),
    .expt_rtn_wr_o              (expt_rtn_wr),
    .expt_rtn_ret_o             (expt_rtn_ret),
    .spec_endianness_iss_o      (spec_endianness_iss),
    .spec_endianness_ex2_o      (spec_endianness_ex2),
    .dspsr_reg_o                (dspsr_reg)
  );

generate if (NEON_FP) begin : FPU1

  // ------------------------------------------------------
  // Floating-point clock gates
  // ------------------------------------------------------

  ca53dpu_fp_cg `CA53_DPU_PARAM_INST u_dpu_fp_cg (
    // Inputs
    .clk                 (clk),
    .reset_n             (reset_n),
    .DFTSE               (DFTSE),
    .stall_wr_i          (stall_wr),
    .ctl_fp_dp_en_i      (ctl_fp_dp_en),
    .fp_dp_active_i      (fp_dp_en_active),
    .fp_alu_en_i         (fp_alu_en),
    .fp_mul_en_i         (fp_mul_en),
    .rf_wr_en_fw_f5_i    (rf_wr_en_fw_f5),
    .fp_ex_pipe_iss_i    (fp_ex_pipe_iss[`CA53_FP_EX_PIPE_W-1:0]),
    .fp_ex_pipe_f1_i     (fp_ex_pipe_f1[`CA53_FP_EX_PIPE_W-1:0]),
    .crypto_enable_iss_i (crypto_enable_iss),
    .crypto_enable_f1_i  (crypto_enable_f1),
    .crypto_active_i     (crypto_active),
    .fp_div_active_i     (fp_div_active[1:0]),
    .fp_div_enb_f1_i     (fp_div_enb_ex1[1:0]),
    // Outputs
    .clk_fp              (clk_fp),
    .clk_fp_alu0         (clk_fp_alu0),
    .clk_fp_alu1         (clk_fp_alu1),
    .clk_fp_mul0         (clk_fp_mul0),
    .clk_fp_mul1         (clk_fp_mul1),
    .clk_crypto          (clk_crypto),
    .clk_fp_nrf          (clk_fp_nrf)
  );

  // ------------------------------------------------------
  // Floating-point datapath
  // ------------------------------------------------------

  ca53dpu_fp `CA53_DPU_PARAM_INST u_dpu_fp (
    // Inputs
    .clk_fp                   (clk_fp),
    .clk_fp_alu0              (clk_fp_alu0),
    .clk_fp_alu1              (clk_fp_alu1),
    .clk_fp_mul0              (clk_fp_mul0),
    .clk_fp_mul1              (clk_fp_mul1),
    .clk_crypto               (clk_crypto),
    .clk_fp_nrf               (clk_fp_nrf),
    .reset_n                  (reset_n),
    .issue_to_ex1_i           (issue_to_ex1),
    .stall_wr_i               (stall_wr),
    .flush_ret_i              (flush_ret),
    .advance_pipeline_i       (advance_pipeline),
    .cp_fpcr_ahp_i            (cp_fpcr_ahp),
    .cp_fpcr_dn_i             (cp_fpcr_dn),
    .cp_fpcr_fz_i             (cp_fpcr_fz),
    .cp_fpcr_rmode_i          (cp_fpcr_rmode[1:0]),
    .rf_rd_addr_fr0_iss_i     (rf_rd_addr_fr0_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr1_iss_i     (rf_rd_addr_fr1_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr2_iss_i     (rf_rd_addr_fr2_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr3_iss_i     (rf_rd_addr_fr3_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr4_iss_i     (rf_rd_addr_fr4_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_addr_fr5_iss_i     (rf_rd_addr_fr5_iss[(`CA53_FP_RF_RD_ADDR_W-1):0]),
    .rf_rd_en_fr0_iss_i       (rf_rd_en_fr0_iss),
    .rf_rd_en_fr1_iss_i       (rf_rd_en_fr1_iss),
    .rf_rd_en_fr2_iss_i       (rf_rd_en_fr2_iss),
    .rf_rd_en_fr3_iss_i       (rf_rd_en_fr3_iss),
    .rf_rd_en_fr4_iss_i       (rf_rd_en_fr4_iss),
    .rf_rd_en_fr5_iss_i       (rf_rd_en_fr5_iss),
    .rf_rd_en_fr0_f1_i        (rf_rd_en_fr0_ex1),
    .rf_rd_en_fr1_f1_i        (rf_rd_en_fr1_ex1),
    .rf_rd_en_fr2_f1_i        (rf_rd_en_fr2_ex1),
    .rf_rd_en_fr3_f1_i        (rf_rd_en_fr3_ex1),
    .rf_rd_en_fr4_f1_i        (rf_rd_en_fr4_ex1),
    .rf_rd_en_fr5_f1_i        (rf_rd_en_fr5_ex1),
    .rf_rd_en_fr0_f2_i        (rf_rd_en_fr0_ex2),
    .rf_rd_en_fr1_f2_i        (rf_rd_en_fr1_ex2),
    .rf_rd_en_fr2_f2_i        (rf_rd_en_fr2_ex2),
    .rf_rd_en_fr3_f2_i        (rf_rd_en_fr3_ex2),
    .rf_rd_en_fr4_f2_i        (rf_rd_en_fr4_ex2),
    .rf_rd_en_fr5_f2_i        (rf_rd_en_fr5_ex2),
    .fr0_fwd_f1_i             (fr0_fwd_ex1[5:0]),
    .fr1_fwd_f1_i             (fr1_fwd_ex1[5:0]),
    .fr2_fwd_f1_i             (fr2_fwd_ex1[5:0]),
    .fr3_fwd_f1_i             (fr3_fwd_ex1[5:0]),
    .fr4_fwd_f1_i             (fr4_fwd_ex1[5:0]),
    .fr5_fwd_f1_i             (fr5_fwd_ex1[5:0]),
    .sel_fad0_a_f1_i          (sel_fad0_a_f1[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad0_b_f1_i          (sel_fad0_b_f1[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad0_c_f1_i          (sel_fad0_c_f1[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fad1_a_f1_i          (sel_fad1_a_f1[`CA53_SEL_FAD_A_W-1:0]),
    .sel_fad1_b_f1_i          (sel_fad1_b_f1[`CA53_SEL_FAD_B_W-1:0]),
    .sel_fad1_c_f1_i          (sel_fad1_c_f1[`CA53_SEL_FAD_C_W-1:0]),
    .sel_fml0_a_f1_i          (sel_fml0_a_f1),
    .sel_fml0_b_f1_i          (sel_fml0_b_f1[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml0_c_f1_i          (sel_fml0_c_f1),
    .sel_fml1_a_f1_i          (sel_fml1_a_f1),
    .sel_fml1_b_f1_i          (sel_fml1_b_f1[`CA53_SEL_FML_B_W-1:0]),
    .sel_fml1_c_f1_i          (sel_fml1_c_f1),
    .fr0_fwd_f2_i             (fr0_fwd_ex2[5:0]),
    .fr1_fwd_f2_i             (fr1_fwd_ex2[5:0]),
    .fr2_fwd_f2_i             (fr2_fwd_ex2[5:0]),
    .fr3_fwd_f2_i             (fr3_fwd_ex2[5:0]),
    .fr4_fwd_f2_i             (fr4_fwd_ex2[5:0]),
    .fr5_fwd_f2_i             (fr5_fwd_ex2[5:0]),
    .fp_mul_fwd_f2_i          (fp_mul_fwd_ex2[1:0]),
    .str0_sel_fp_f1_i         (str0_sel_fp_f1[1:0]),
    .str1_sel_fp_f1_i         (str1_sel_fp_f1[1:0]),
    .str0_sel_fp_f2_i         (str0_sel_fp_f2[1:0]),
    .str1_sel_fp_f2_i         (str1_sel_fp_f2[1:0]),
    .rf_wr_en_fw_f3_i         (rf_wr_en_fw_f3),
    .rf_wr_src_fw0_f3_i       (rf_wr_src_fw0_f3[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f4_i       (rf_wr_src_fw0_f4[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw0_f5_i       (rf_wr_src_fw0_f5[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f3_i       (rf_wr_src_fw1_f3[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f4_i       (rf_wr_src_fw1_f4[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_src_fw1_f5_i       (rf_wr_src_fw1_f5[`CA53_RF_FWR_SRC_W-1:0]),
    .rf_wr_when_fw0_f4_i      (rf_wr_when_fw0_f4[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_when_fw1_f4_i      (rf_wr_when_fw1_f4[`CA53_RF_FWR_WHEN_W-1:0]),
    .rf_wr_en_fw0_f5_i        (rf_wr_en_fw0_f5),
    .rf_wr_en_fw1_f5_i        (rf_wr_en_fw1_f5),
    .rf_wr_addr_fw0_f5_i      (rf_wr_addr_fw0_f5[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .rf_wr_addr_fw1_f5_i      (rf_wr_addr_fw1_f5[(`CA53_FP_RF_WR_ADDR_W-1):0]),
    .fp0_imm_data_f1_i        (fp0_imm_data_f1[12:0]),
    .fp1_imm_data_f1_i        (fp1_imm_data_f1[12:0]),
    .fp_ex_pipe_f1_i          (fp_ex_pipe_f1[(`CA53_FP_EX_PIPE_W-1):0]),
    .crypto_enable_f1_i       (crypto_enable_f1),
    .fp0_pipectl_f1_i         (fp0_pipectl_f1[`CA53_FP_PIPECTL_W-1:0]),
    .fp1_pipectl_f1_i         (fp1_pipectl_f1[`CA53_FP_PIPECTL_W-1:0]),
    .fp_div_enb_f1_i          (fp_div_enb_ex1[1:0]),
    .alu0_csel_pass_ex2_i     (alu0_csel_pass_ex2),
    .instr_is_cp10_cp11_wr_i  (instr_is_cp10_cp11_wr),
    .neon_vld_ctl_f3_i        (neon_vld_ctl_f3[(`CA53_NEON_VLD_CTL_W-1):0]),
    .valid_instrs_wr_i        (valid_instrs_wr[0]),
    .issue_to_ex2_fpu_i       (issue_to_ex2_fpu),
    .issue_to_f4_i            (issue_to_f4),
    .first_x64_wr_i           (first_x64_wr),
    .fwd_ld_data_int_wr_i     (fwd_ld_data_int_wr[63:0]),
    .st0_data_ex1_i           (st0_data_ex1[63:0]),
    .st0_data_wr_i            (st0_data_wr[63:0]),
    .st1_data_ex1_i           (st1_data_ex1[63:0]),
    .st1_data_wr_i            (st1_data_wr[63:0]),
    .ls_elem_size_wr_i        (ls_elem_size_wr[1:0]),
    // Outputs
    .fp_alu_en_o              (fp_alu_en),
    .fp_mul_en_o              (fp_mul_en),
    .fp_div_busy_nxt_cyc_o    (fp_div_busy_nxt_cyc[1:0]),
    .fp_str0_data_f1_o        (fp_str0_data_f1[63:0]),
    .fp_str1_data_f1_o        (fp_str1_data_f1[63:0]),
    .fp_str0_data_f2_o        (fp_str0_data_f2[63:0]),
    .fp_str1_data_f2_o        (fp_str1_data_f2[63:0]),
    .fp_alu0_f2i_res_f3_o     (fp_alu0_f2i_res_f3[63:0]),
    .fp_alu1_f2i_res_f3_o     (fp_alu1_f2i_res_f3[63:0]),
    .fp_cflags_add0_f2_o      (fp_cflags_add0_f2[3:0]),
    .fp_cflags_add1_f2_o      (fp_cflags_add1_f2[3:0]),
    .fp_xflags_mul0_f5_o      (fp_xflags_mul0_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_mul1_f5_o      (fp_xflags_mul1_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add0_f5_o      (fp_xflags_add0_f5[`CA53_XFLAGS_W-1:0]),
    .fp_xflags_add1_f5_o      (fp_xflags_add1_f5[`CA53_XFLAGS_W-1:0]),
    .fp_dp_en_active_o        (fp_dp_en_active),
    .crypto_active_o          (crypto_active)
  );

end else begin : FPU1_STUBS
  assign clk_fp                                 = 1'b0;
  assign clk_fp_alu0                            = 1'b0;
  assign clk_fp_alu1                            = 1'b0;
  assign clk_fp_mul0                            = 1'b0;
  assign clk_fp_mul1                            = 1'b0;
  assign clk_crypto                             = 1'b0;
  assign clk_fp_nrf                             = 1'b0;
  assign fp_alu_en                              = 2'b00;
  assign fp_mul_en                              = 2'b00;
  assign fp_div_busy_nxt_cyc                    = 2'b00;
  assign fp_str0_data_f1[63:0]                  = {64{1'b0}};
  assign fp_str1_data_f1[63:0]                  = {64{1'b0}};
  assign fp_str0_data_f2[63:0]                  = {64{1'b0}};
  assign fp_str1_data_f2[63:0]                  = {64{1'b0}};
  assign fp_alu0_f2i_res_f3[63:0]               = {64{1'b0}};
  assign fp_alu1_f2i_res_f3[63:0]               = {64{1'b0}};
  assign fp_cflags_add0_f2[3:0]                 = 4'b0000;
  assign fp_cflags_add1_f2[3:0]                 = 4'b0000;
  assign fp_xflags_mul0_f5[`CA53_XFLAGS_W-1:0]  = {`CA53_XFLAGS_W{1'b0}};
  assign fp_xflags_mul1_f5[`CA53_XFLAGS_W-1:0]  = {`CA53_XFLAGS_W{1'b0}};
  assign fp_xflags_add0_f5[`CA53_XFLAGS_W-1:0]  = {`CA53_XFLAGS_W{1'b0}};
  assign fp_xflags_add1_f5[`CA53_XFLAGS_W-1:0]  = {`CA53_XFLAGS_W{1'b0}};
  assign fp_dp_en_active                        = 1'b0;
  assign crypto_active                          = 1'b0;
end endgenerate

  // ------------------------------------------------------
  // General assignments
  // ------------------------------------------------------

  assign dpu_second_x64_iss_o       = second_x64_iss;
  assign dpu_pred_br_wr_o           = dpu_pred_br_wr;
  assign dpu_mispred_wr_o           = dpu_mispred_wr;
  assign dpu_br_taken_wr_o          = dpu_br_taken_wr;
  assign dpu_br_return_wr_o         = dpu_br_return_wr;
  assign dpu_halt_ifu_o             = dpu_halt_ifu;
  assign dpu_fe_valid_wr_o          = dpu_fe_valid_wr;
  assign dpu_fe_addr_opa_wr_o       = dpu_fe_addr_opa_wr[48:1];
  assign dpu_fe_addr_opb_wr_o       = dpu_fe_addr_opb_wr[27:1];
  assign dpu_fe_valid_ret_o         = dpu_fe_valid_ret;
  assign dpu_fe_addr_opa_ret_o      = dpu_fe_addr_opa_ret[63:0];
  assign dpu_fe_addr_opb_ret_o      = dpu_fe_addr_opb_ret[17:1];
  assign dpu_dacr_o                 = dpu_dacr;
  assign dpu_cp_data_wr_o           = mcr_data_wr;
  assign dpu_mode_iss_o             = spec_cpsr_mode_iss;
  assign dpu_exception_level_o      = dpu_exception_level;
  assign dpu_aarch64_at_el_o        = aarch64_at_el[3:1];
  assign dpu_aarch64_state_o        = aarch64_state_ext;
  assign dpu_monitor_mode_o         = spec_cpsr_mode_mon_iss;
  assign dpu_vec_base_s_dc1_o       = cp_vbar_el3[31:5];
  assign dpu_vec_base_ns_dc1_o      = cp_vbar_el1[31:5];
  assign dpu_mon_vec_base_dc1_o     = cp_mvbar[31:5];
  assign dpu_endian_el3_o           = sctlr_endian_el3;
  assign dpu_endian_el1_o           = sctlr_endian_el1;
  assign dpu_endian_el2_o           = sctlr_endian_el2;
  assign dpu_ns_state_o             = ns_state;
  assign dpu_scr_el3_fiq_o          = scr_fiq;
  assign dpu_scr_el3_irq_o          = scr_irq;
  assign dpu_scr_el3_ns_o           = ns_scr;
  assign dpu_dbg_addr_o             = apb_addr[11:2];
  assign dpu_dbg_wdata_o            = apb_wdata[31:0];
  assign dpu_default_cacheable_o    = dpu_default_cacheable;
  assign dpu_mmu_on_o               = dpu_mmu_on;
  assign dpu_mmu_on_el1_o           = dpu_mmu_on_el1;
  assign dpu_dbg_double_lock_set_o  = dbg_double_lock_set;
  assign dpu_dscr_halted_o          = dbgdscr_halted;
  assign dpu_clear_excl_mon_o       = expt_rtn_ret; // Clear on exception return
  assign dpu_hcr_el2_fmo_o          = hcr_fmo;  // Forced in cp block if HCR.TGE set
  assign dpu_hcr_el2_imo_o          = hcr_imo;
  assign dpu_hcr_el2_amo_o          = hcr_amo;

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_fe_valid_ret_o")
  u_ovl_x_dpu_fe_valid_ret_o (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_fe_valid_ret_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: insert_forceop_wr")
  u_ovl_x_insert_forceop_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (insert_forceop_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex1")
  u_ovl_x_issue_to_ex1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (issue_to_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_ex2")
  u_ovl_x_issue_to_ex2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (issue_to_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss")
  u_ovl_x_issue_to_iss (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (issue_to_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_wr")
  u_ovl_x_issue_to_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (issue_to_wr));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check setting PSTATE.SS from SPSR_ELx.SS
  // Implement as described in Debug Arch Tables 6 to 8
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  wire ovl_spsr_ss_mask;
  wire ovl_spsr_ss_mask_el1_aarch64;
  wire ovl_spsr_ss_mask_el2_aarch64;

  // Debug Architecture Table 7
  assign ovl_spsr_ss_mask_el1_aarch64 = (dpu_exception_level == `CA53_EL3) ? 
                                                  ((u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL3) ? 1'b0 :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL2) ? 1'b0 :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL1) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b0 : 
                                                                                                                                   ~u_dpu_cpsr.spsr_ret_reg[`CA53_SPSR_RET_D_BITS]) :
                                                                                                       1'b1) :
                                        (dpu_exception_level == `CA53_EL2) ? 
                                                  ((u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL2) ? 1'b0 :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL1) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b0 : 
                                                                                                                                   ~u_dpu_cpsr.spsr_ret_reg[`CA53_SPSR_RET_D_BITS]) :
                                               /*  (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL0)*/ 1'b1) :
                                     // (dpu_exception_level == `CA53_EL1)
                                                  ((u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL1) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b0 :
                                                                                                                                   ~cpsr_ret[`CA53_CPSR_RET_D_BITS] ? 1'b0 : 
                                                                                                                                                                      ~u_dpu_cpsr.spsr_ret_reg[`CA53_SPSR_RET_D_BITS]) :  
                                               /*  (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL0)*/  (~u_dpu_dbg.mdscr_el1_kde ? 1'b1 :
                                                                                                                                   ~cpsr_ret[`CA53_CPSR_RET_D_BITS] ? 1'b0 : 
                                                                                                                                                                      1'b1));

  // Debug Architecture Table 8
  assign ovl_spsr_ss_mask_el2_aarch64 = (dpu_exception_level == `CA53_EL3) ? 
                                                  ((u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL3) ? 1'b0 :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL2) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b0 : 
                                                                                                                                   ~u_dpu_cpsr.spsr_ret_reg[`CA53_SPSR_RET_D_BITS]) :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL1) ? 1'b1 :
                                                                                                       1'b1) :
                                        (dpu_exception_level == `CA53_EL2) ? 
                                                  ((u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL2) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b0 : 
                                                                                                                                   ~cpsr_ret[`CA53_CPSR_RET_D_BITS] ? 1'b0 :
                                                                                                                                                                      ~u_dpu_cpsr.spsr_ret_reg[`CA53_SPSR_RET_D_BITS]) :
                                                   (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL1) ? (~u_dpu_dbg.mdscr_el1_kde ? 1'b1 : 
                                                                                                                                   cpsr_ret[`CA53_SPSR_RET_D_BITS]) :
                                               /*  (u_dpu_cpsr.nxt_dpu_exception_level == `CA53_EL0)*/ (~u_dpu_dbg.mdscr_el1_kde ? 1'b1 : 
                                                                                                                                   cpsr_ret[`CA53_SPSR_RET_D_BITS])) :
                                     // (dpu_exception_level == `CA53_EL1)
                                                    1'b0;

  assign ovl_spsr_ss_mask = ~mdscr_el1_ss                                                      ? 1'b0 :
                             (u_dpu_dbg.dbg_os_lock_set | u_dpu_dbg.dbg_double_lock_status_us) ? 1'b0 :
                               (~ns_scr ? (cp_mdcr_el3_sdd                                   ? 1'b0 :
                                            (~aarch64_at_el[1]                             ? 1'b0 :
                                                                                             ovl_spsr_ss_mask_el1_aarch64)) :  // Table 8                                              :
                                          (~hdcr_tde ?
                                            (~aarch64_at_el[1]                             ? 1'b0 :
                                                                                             ovl_spsr_ss_mask_el1_aarch64)  :  // Table 8                                              :
                                            (~aarch64_at_el[2]                             ? 1'b0 :
                                                                                             ovl_spsr_ss_mask_el2_aarch64)));  // Table 9
  

  assert_implication #(`OVL_FATAL, 1, `OVL_ASSERT, "Setting PSTATE.SS from SPSR_ELx.SS not as expected")
  ovl_debug_pstate_ss (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (u_dpu_cpsr.cpsr_regfile_en_wr & (u_dpu_cpsr.sel_cpsr_ssbit_wr == 4'b0101)),
    .consequent_expr ((ovl_spsr_ss_mask & ~in_halt) == u_dpu_cpsr.spsr_ss_mask)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Debug exception routing using AArch64 - See Debug Arch Table 13
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire       ovl_lock;
  wire       ovl_aarch64_dest;
  wire [1:0] ovl_dbg_expt_el_64;
  reg        ovl_hdcr_tde_synced;
  reg        ovl_mdscr_el1_kde_synced;
  reg  [1:0] ovl_mdcr_el3_spd32_synced;
  reg        ovl_suiden_synced;

  assign ovl_lock         = u_dpu_dbg.dbg_os_lock_synced | u_dpu_dbg.dbg_double_lock_status_synced;
  assign ovl_aarch64_dest = ~u_dpu_ctl.u_dpu_exception.exception_mode_wr[4];

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n) begin
      ovl_hdcr_tde_synced       <= 1'b0;
      ovl_mdscr_el1_kde_synced  <= 1'b0;
      ovl_mdcr_el3_spd32_synced <= 2'b00;
      ovl_suiden_synced         <= 1'b0;
    end
    else if (u_dpu_dbg.dscr_dbg_en_synced_en) begin
      ovl_hdcr_tde_synced       <= hdcr_tde;
      ovl_mdscr_el1_kde_synced  <= u_dpu_dbg.mdscr_el1_kde;
      ovl_mdcr_el3_spd32_synced <= cp_mdcr_el3_spd32;
      ovl_suiden_synced         <= cp_sder[0];
    end

  // Exceptions never taken to EL3 so using EL3 to indicate illegal state
  assign ovl_dbg_expt_el_64 = in_halt   ? `CA53_EL3 :
                              ovl_lock  ? `CA53_EL3 :
                              ~ns_state ? (cp_mdcr_el3_sdd ? `CA53_EL3 :
                                                             (((dpu_exception_level == `CA53_EL0) |
                                                               (dpu_exception_level == `CA53_EL1) & ovl_mdscr_el1_kde_synced & ~cpsr_dbit_ret)  ? `CA53_EL1 : `CA53_EL3)) :
                             /*ns_state*/ ((dpu_exception_level == `CA53_EL0) & ovl_hdcr_tde_synced                                             ? `CA53_EL2 :
                                           (dpu_exception_level == `CA53_EL0)                                                                   ? `CA53_EL1 :
                                           (dpu_exception_level == `CA53_EL1) & ovl_hdcr_tde_synced                                             ? `CA53_EL2 :
                                           (dpu_exception_level == `CA53_EL1) & ovl_mdscr_el1_kde_synced & ~cpsr_dbit_ret                       ? `CA53_EL1 :
                                           (dpu_exception_level == `CA53_EL2) & ovl_hdcr_tde_synced & ovl_mdscr_el1_kde_synced & ~cpsr_dbit_ret ? `CA53_EL2 : `CA53_EL3);
                                                              
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception not as predicted by Debug Arch Table 13")
    ovl_dbg_el_aa64 (.clk              (clk),
                     .reset_n          (reset_n),
                     .antecedent_expr  (u_dpu_ctl.u_dpu_exception.exception_valid_wr & ovl_aarch64_dest &
                                        (u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT) & 
                                        (u_dpu_ctl.u_dpu_exception.debug_status_wr != `CA53_DBG_STATUS_BKPT_INSTR)),
                     .consequent_expr  (ovl_dbg_expt_el_64 == u_dpu_ctl.u_dpu_exception.exception_el_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception not as predicted by Debug Arch Table 13")
    ovl_dbg_valid_aa64 (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  ((ovl_dbg_expt_el_64 == `CA53_EL3) & u_dpu_ctl.u_dpu_exception.exception_valid_wr & ovl_aarch64_dest &
                                           (u_dpu_ctl.u_dpu_exception.debug_status_wr != `CA53_DBG_STATUS_BKPT_INSTR)),
                        .consequent_expr  (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXPT));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Debug exception routing using AArch32 - See Debug Arch Table 14
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire       ovl_auth;
  wire [5:0] ovl_dbg_expt_mode_32;

  assign ovl_auth   = dbgen_synced & spiden_synced;

  // Exceptions never taken to mode USR so using CA53_FULL_MODE_USR to indicate illegal state
  assign ovl_dbg_expt_mode_32 = in_halt   ? `CA53_FULL_MODE_USR :
                                ovl_lock  ? `CA53_FULL_MODE_USR :
                                ~ns_state ? (((dpu_exception_level == `CA53_EL0) & ~ovl_mdcr_el3_spd32_synced[1] & ~ovl_auth & ovl_suiden_synced) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level == `CA53_EL0) & ~ovl_mdcr_el3_spd32_synced[1] &  ovl_auth                    ) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level == `CA53_EL0) & (ovl_mdcr_el3_spd32_synced == 2'b10)      & ovl_suiden_synced) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level == `CA53_EL0) & (ovl_mdcr_el3_spd32_synced == 2'b11)                         ) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level[0] == 1'b1)   & ~ovl_mdcr_el3_spd32_synced[1] &  ovl_auth                    ) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level[0] == 1'b1)   & (ovl_mdcr_el3_spd32_synced == 2'b11)                         ) ? `CA53_FULL_MODE_ABT : `CA53_FULL_MODE_USR) :
                               /*ns_state*/ (((dpu_exception_level == `CA53_EL0) & ovl_hdcr_tde_synced                                          ) ? `CA53_FULL_MODE_HYP :
                                             ((dpu_exception_level == `CA53_EL0)                                                                ) ? `CA53_FULL_MODE_ABT :
                                             ((dpu_exception_level[0] == 1'b1)   & ovl_hdcr_tde_synced                                          ) ? `CA53_FULL_MODE_HYP :
                                             ((dpu_exception_level[0] == 1'b1)                                                                  ) ? `CA53_FULL_MODE_ABT : `CA53_FULL_MODE_USR);
                                                              
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception not as predicted by Debug Arch Table 14")
    ovl_dbg_el_aa32 (.clk              (clk),
                     .reset_n          (reset_n),
                     .antecedent_expr  (u_dpu_ctl.u_dpu_exception.exception_valid_wr & ~ovl_aarch64_dest &
                                        (u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT) & 
                                        (u_dpu_ctl.u_dpu_exception.debug_status_wr != `CA53_DBG_STATUS_BKPT_INSTR)),
                     .consequent_expr  (ovl_dbg_expt_mode_32 == u_dpu_ctl.u_dpu_exception.exception_mode_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception not as predicted by Debug Arch Table 14")
    ovl_dbg_valid_aa32 (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  ((ovl_dbg_expt_mode_32 == `CA53_FULL_MODE_USR) & u_dpu_ctl.u_dpu_exception.exception_valid_wr & ~ovl_aarch64_dest &
                                           (u_dpu_ctl.u_dpu_exception.debug_status_wr != `CA53_DBG_STATUS_BKPT_INSTR)),
                        .consequent_expr  (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXPT));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Debug exception software breakpoint routing - See Debug Arch Table 15
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire [1:0] ovl_dbg_sw_bkpt_el;
  wire [5:0] ovl_dbg_sw_bkpt_mode;

  assign ovl_dbg_sw_bkpt_mode = ~ns_state ? `CA53_FULL_MODE_ABT :
                               /*ns_state*/ (((dpu_exception_level[1] == 1'b0) & ovl_hdcr_tde_synced) ? `CA53_FULL_MODE_HYP :
                                             ((dpu_exception_level[1] == 1'b0)                      ) ? `CA53_FULL_MODE_ABT : `CA53_FULL_MODE_HYP);

  assign ovl_dbg_sw_bkpt_el   = ~ns_state ? (((dpu_exception_level[1] == 1'b0)                      ) ? `CA53_EL1 : `CA53_EL3) :
                               /*ns_state*/ (((dpu_exception_level[1] == 1'b0) & ovl_hdcr_tde_synced) ? `CA53_EL2 :
                                             ((dpu_exception_level[1] == 1'b0)                      ) ? `CA53_EL1 : `CA53_EL2);
                                                              
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception AArch32 software breakpoint not as predicted by Debug Arch Table 15")
    ovl_dbg_sw_bkpt_mode_aa32 (.clk              (clk),
                               .reset_n          (reset_n),
                               .antecedent_expr  (u_dpu_ctl.u_dpu_exception.exception_valid_wr & ~ovl_aarch64_dest &
                                                  (u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT) & 
                                                  (u_dpu_ctl.u_dpu_exception.debug_status_wr == `CA53_DBG_STATUS_BKPT_INSTR)),
                               .consequent_expr  (ovl_dbg_sw_bkpt_mode == u_dpu_ctl.u_dpu_exception.exception_mode_wr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug exception AArch64 software breakpoint not as predicted by Debug Arch Table 15")
    ovl_dbg_sw_bkpt_el_aa64   (.clk              (clk),
                               .reset_n          (reset_n),
                               .antecedent_expr  (u_dpu_ctl.u_dpu_exception.exception_valid_wr & ovl_aarch64_dest &
                                                  (u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT) & 
                                                  (u_dpu_ctl.u_dpu_exception.debug_status_wr == `CA53_DBG_STATUS_BKPT_INSTR)),
                               .consequent_expr  (ovl_dbg_sw_bkpt_el == u_dpu_ctl.u_dpu_exception.exception_el_wr));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Store data on CP op mismatch
  //
  // The STB relies on the DPU presenting the store data for a CP OP on
  // dpu_st_data_wr, so that it does not need to mux it in separately. This
  // is really an interface property, but it relies on signals not available
  // in any single interface, so is checked here.
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"dpu_st_data_wr_o[63:0] should match dpu_cp_data_wr_o on CP op sent to DCU")
    u_ovl_cp_data_match (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (cp_valid_wr & ls_valid_wr & dpu_ready_cc_pass_wr_o & ls_store_wr),
      .consequent_expr (({{32{ls_size_wr == 2'b11}}, {32{1'b1}}} & dpu_st_data_wr_o[63:0]) == ({{32{ls_size_wr == 2'b11}}, {32{1'b1}}} & dpu_cp_data_wr_o)));
  // OVL_ASSERT_END

  reg    ovl_in_debug_state;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_in_debug_state <= 1'b0;
    else if (dpu_fe_valid_ret_o)
      ovl_in_debug_state <= dpu_halt_ifu_o;

  //----------------------------------------------------------------------------
  // The CPU exception level must only change on a Ret-stage force
  //----------------------------------------------------------------------------

  reg [1:0] ovl_last_dpu_exception_level;

  always @(posedge clk)
    ovl_last_dpu_exception_level <= dpu_exception_level;

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Change of exception level without IFU force")
  ovl_excep_level_change (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((ovl_last_dpu_exception_level !== dpu_exception_level) & ~ovl_in_debug_state),
    .consequent_expr (dpu_fe_valid_ret_o)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The CPU operating mode must only change on a Ret-stage force
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg [4:0] ovl_last_dpu_mode;

  always @(posedge clk)
    ovl_last_dpu_mode <= cpsr_mode_ret;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Change of mode without IFU force")
  ovl_mode_change (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((ovl_last_dpu_mode !== cpsr_mode_ret) & ~ovl_in_debug_state),
    .consequent_expr (dpu_fe_valid_ret_o)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Effect of entering Debug state on PSTATE and EDSCR
  // Section 8.3.4 & 8.3.5 in Debug Architecture Specification
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  // Capture PSTATE before entering halt state
  
  reg [`CA53_CPSR_RET_W-1:0] ovl_cpsr_before_halt;
  reg  ovl_in_halt_r1;
  reg  ovl_dscr_halted_r1;
  wire ovl_cpsr_before_halt_en;
  
  always @(posedge clk) begin
    ovl_in_halt_r1     <= u_dpu_dbg.in_halt;
    ovl_dscr_halted_r1 <= u_dpu_dbg.dscr_halted;
  end

  assign ovl_cpsr_before_halt_en = u_dpu_dbg.in_halt & ~ovl_in_halt_r1;

  always @(posedge clk)
    if (ovl_cpsr_before_halt_en)
      ovl_cpsr_before_halt <= u_dpu_cpsr.cpsr_ret_reg;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE stored in DSPSR_EL0 on entering debug state")
    ovl_dbg_pstate_dspsr (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (u_dpu_dbg.dscr_halted & ~ovl_dscr_halted_r1),
                          .consequent_expr  ((ovl_cpsr_before_halt == u_dpu_cpsr.dspsr_ret_reg)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE.{M, nRW, EL, SP} unchanged on entering debug state")
    ovl_dbg_pstate_unchanged (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (u_dpu_dbg.dscr_halted & ~ovl_dscr_halted_r1),
                              .consequent_expr  ((ovl_cpsr_before_halt[`CA53_CPSR_RET_MODE_BITS] == u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS])));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE.{N, Z, C, V, Q, GE} notionally unchanged on entering debug state")
    ovl_dbg_pstate_unchanged2 (.clk              (clk),
                               .reset_n          (reset_n),
                               .antecedent_expr  (u_dpu_dbg.dscr_halted & ~ovl_dscr_halted_r1),
                               .consequent_expr  ((ovl_cpsr_before_halt[`CA53_CPSR_RET_NZCVQ_BITS] == u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_NZCVQ_BITS]) &
                                                 (ovl_cpsr_before_halt[`CA53_CPSR_RET_GE_BITS]     == u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_GE_BITS])));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE.{IT, J, T, SS, E/D, A, I, F} new values on entering debug state")
    ovl_dbg_pstate_changed (.clk              (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (u_dpu_dbg.dscr_halted & ~ovl_dscr_halted_r1),
                            .consequent_expr  ((u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_T_BITS]       == aarch64_state ? 1'b0 : 1'b1) &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_IT_LOW_BITS]  == 2'b00)                       &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_IT_HICM_BITS] == 6'b000000)                   &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_IL_BITS]      == 1'b0)                        &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_A_BITS]       == 1'b1)                        &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_I_BITS]       == 1'b1)                        &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_F_BITS]       == 1'b1)                        &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS]      == 1'b0)                        &
                                               (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_D_BITS]       == aarch64_state ? 1'b1 : ovl_cpsr_before_halt[`CA53_CPSR_RET_D_BITS])));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"EDSCR.ITE and EDSCR.ITO new values on entering debug state")
    ovl_dbg_edscr_changed (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (u_dpu_dbg.dscr_halted & ~ovl_dscr_halted_r1),
                           .consequent_expr  ((u_dpu_dbg.edscr_ite == 1'b1) &
                                              (u_dpu_dbg.edscr_ito == 1'b0)));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Maintain PSTATE.{IT, J, T, E/D, A, I, F} in debug state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE.{IT, J, T, A, I, F} must not change in debug state")
    ovl_dbg_pstate_static (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (u_dpu_dbg.dscr_halted),
                           .consequent_expr  ((u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_T_BITS]       == aarch64_state ? 1'b0 : 1'b1) &
                                              (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_IT_LOW_BITS]  == 2'b00)                       &
                                              (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_IT_HICM_BITS] == 6'b000000)                   &
                                              (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_A_BITS]       == 1'b1)                        &
                                              (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_I_BITS]       == 1'b1)                        &
                                              (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_F_BITS]       == 1'b1)));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Set PSTATE.SS to zero when taking an exception in debug state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PSTATE.SS not set to zero when taking an exception in debug state")
    ovl_dbg_pstate_ss     (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (u_dpu_dbg.dscr_halted & (u_dpu_ctl.u_dpu_exception.current_state == 4'b1001)), // ST_EXPT_WR_FORCEOP
                           .consequent_expr  (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_SS_BITS] == 1'b0));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Check exception types while in debug state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Check exception types while in debug state")
    ovl_expt_dbg_state (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (u_dpu_dbg.dscr_halted),
                        .consequent_expr  ((u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_FIQ)         &
                                           (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_IRQ)         &
                                           (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_DEBUG_HLT)   &
                                           (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_INSTR_FAULT) &
                                           (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_IMPRECISE)   &
                                           (u_dpu_ctl.u_dpu_exception.expt_type_wr != `CA53_EXPT_TYPE_WPT)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // In debug state if EL3 is using AArch32 and the exception is taken from Monitor mode, SCR.NS is set to 0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  reg ovl_monitor_mode;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_monitor_mode <= 1'b0;
    else if (u_dpu_ctl.u_dpu_exception.exception_valid_wr)
      ovl_monitor_mode <= (u_dpu_cpsr.cpsr_ret_reg[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_MON);

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"In debug state if EL3 is using AArch32 and the exception is taken from Monitor mode, SCR.NS is set to 0")
    ovl_expt_mon_mode (.clk              (clk),
                       .reset_n          (reset_n),
                       .antecedent_expr  (u_dpu_dbg.dscr_halted & ~aarch64_at_el[`CA53_EL3] & ovl_monitor_mode & 
                                          (u_dpu_ctl.u_dpu_exception.current_state == 4'b1001)), // ST_EXPT_WR_FORCEOP),
                       .consequent_expr  (~ns_state));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // In debug state endianness switches to that set in EE in the system control register for the target EL
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"In debug state endianness switches to that set in EE in the system control register for the target EL")
    ovl_expt_endian   (.clk              (clk),
                       .reset_n          (reset_n),
                       .antecedent_expr  (u_dpu_dbg.dscr_halted & ~aarch64_state & (expt_type != `CA53_EXPT_TYPE_ECC_REEXEC) & forceop_valid_wr), 
                       .consequent_expr  (cpsr_ret[`CA53_CPSR_RET_E_BITS] == (dpu_exception_level == `CA53_EL3 ? sctlr_endian_el3 : 
                                                                              dpu_exception_level == `CA53_EL2 ? sctlr_endian_el2 :
                                                                                                                 sctlr_endian_el1)));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Mode should be consistent with configured register width
  //----------------------------------------------------------------------------

  reg ovl_seen_reset_force;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_seen_reset_force <= 1'b0;
    else
      ovl_seen_reset_force <= ovl_seen_reset_force | insert_forceop_ret;

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch64 EL0/1 mode not consistent with configured register width of AArch32 EL1")
    ovl_mode_el_aa64_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             ((cpsr_mode_ret == `CA53_FULL_MODE_EL0T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1H))),
                          .consequent_expr  (aarch64_at_el[1]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch32 PL1 mode not consistent with configured register width of AArch64 EL1")
    ovl_mode_el_aa32_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             ((cpsr_mode_ret == `CA53_FULL_MODE_SVC) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_SYS) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_UND) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_FIQ) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_IRQ) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_ABT))),
                          .consequent_expr  (~aarch64_at_el[1]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch64 EL0/1/2 mode not consistent with configured register width of AArch32 EL2")
    ovl_mode_el_aa64_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             ((cpsr_mode_ret == `CA53_FULL_MODE_EL0T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1H) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL2T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL2H))),
                          .consequent_expr  (aarch64_at_el[2]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch32 PL2 mode not consistent with configured register width of AArch64 EL2")
    ovl_mode_el_aa32_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             (cpsr_mode_ret == `CA53_FULL_MODE_HYP)),
                          .consequent_expr  (~aarch64_at_el[2]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch64 mode not consistent with configured register width of AArch32 EL3")
    ovl_mode_el_aa64_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             ((cpsr_mode_ret == `CA53_FULL_MODE_EL0T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL1H) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL2T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL2H) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL3T) |
                                              (cpsr_mode_ret == `CA53_FULL_MODE_EL3H))),
                          .consequent_expr  (aarch64_at_el[3]));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"AArch32 Monitor mode not consistent with configured register width of AArch64 EL3")
    ovl_mode_el_aa32_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (ovl_seen_reset_force &
                                             (cpsr_mode_ret == `CA53_FULL_MODE_MON)),
                          .consequent_expr  (~aarch64_at_el[3]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: If the dpu_ns_state changes the Ret stage force signal must
  // be asserted, unless the processor is in debug state.
  //----------------------------------------------------------------------------
  reg ovl_last_dpu_ns_state;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_last_dpu_ns_state <= 1'b0;
    else
      ovl_last_dpu_ns_state <= dpu_ns_state_o;

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"TrustZone: Illegal change on dpu_ns_state signal")
    ovl_tz_dpu_ns_state_change (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr ((dpu_ns_state_o ^ ovl_last_dpu_ns_state) & ~ovl_in_debug_state),
      .consequent_expr (dpu_fe_valid_ret_o));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: If the dpu_ns_state changes the micro-TLB flush signal must
  // be asserted.
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"TrustZone: Micro-TLBs not flushed on security state change")
    ovl_tz_dpu_flush_utlb (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (dpu_ns_state_o ^ ovl_last_dpu_ns_state),
      .consequent_expr (flush_d_utlb & dpu_flush_i_utlb_o));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.1.2.b If MMU is off: NS-attr = NS-req
  // OVL_ASSERT: ovl_tz_mmu_off_ns_attr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg ovl_mmu_off;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_mmu_off <= 1'b0;
    else
      ovl_mmu_off <= ~dpu_mmu_on_o & dpu_valid_iss_o & ~dpu_flush_o & dcu_ready_iss_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"If MMU is off: NS-attr = NS-req")
    ovl_tz_mmu_off_ns_attr (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (ovl_mmu_off & dpu_utlb_hit_dc1_o & ~flush_wr),
      .consequent_expr (dpu_ns_state_o == dpu_ns_dsc_dc1_o));
    // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.1.c R13_mon can only be modified, or used internally, by
  // secure privilege modes
  // OVL_ASSERT: ovl_tz_r13_mon_access_rd, ovl_tz_r13_mon_access_wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R13_mon can only be read when at EL3")
    ovl_tz_r13_mon_access_rd (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr ((((u_dpu_ctl.rf_rd_addr_r0_iss == `CA53_ADDR_R13_MON) & u_dpu_ctl.rf_rd_en_r0_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r1_iss == `CA53_ADDR_R13_MON) & u_dpu_ctl.rf_rd_en_r1_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r2_iss == `CA53_ADDR_R13_MON) & u_dpu_ctl.rf_rd_en_r2_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r3_iss == `CA53_ADDR_R13_MON) & u_dpu_ctl.rf_rd_en_r3_iss)) & ~flush_wr),
      .consequent_expr (((dpu_exception_level == `CA53_EL3) |
                         ((dpu_exception_level == `CA53_EL1) &
                          u_dpu_ctl.u_dpu_early_exception.exception_valid_iss &
                          (u_dpu_ctl.u_dpu_early_exception.expt_type_iss == `CA53_EXPT_TYPE_TRAP))) &
                        ~ns_state));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R13_mon can only be written when in at EL3")
    ovl_tz_r13_mon_access_wr (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (u_dpu_regbank.regbank_en_lo[`CA53_ADDR_BIT_R13_MON]),
      .consequent_expr ((dpu_exception_level == `CA53_EL3) & ~ns_state));
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.1.c R14_mon can only be modified, or used internally, by
  // secure privilege modes
  // OVL_ASSERT: ovl_tz_r14_mon_access_rd, ovl_tz_r14_mon_access_wr
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R14_mon can only be read when at EL3")
    ovl_tz_r14_mon_access_rd (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr ((((u_dpu_ctl.rf_rd_addr_r0_iss == `CA53_ADDR_R14_MON) & u_dpu_ctl.rf_rd_en_r0_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r1_iss == `CA53_ADDR_R14_MON) & u_dpu_ctl.rf_rd_en_r1_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r2_iss == `CA53_ADDR_R14_MON) & u_dpu_ctl.rf_rd_en_r2_iss)  |
                         ((u_dpu_ctl.rf_rd_addr_r3_iss == `CA53_ADDR_R14_MON) & u_dpu_ctl.rf_rd_en_r3_iss)) & ~flush_wr),
      .consequent_expr (((dpu_exception_level == `CA53_EL3) |
                         ((dpu_exception_level == `CA53_EL1) &
                          u_dpu_ctl.u_dpu_early_exception.exception_valid_iss &
                          (u_dpu_ctl.u_dpu_early_exception.expt_type_iss == `CA53_EXPT_TYPE_TRAP))) &
                        ~ns_state));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"R14_mon can only be written when at EL3")
    ovl_tz_r14_mon_access_wr (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (u_dpu_regbank.regbank_en_lo[`CA53_ADDR_BIT_R14_MON]),
      .consequent_expr ((dpu_exception_level == `CA53_EL3) & ~ns_state));
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.3.2.d On Non-Secure to Secure state change, FIQ, IRQ and
  // imprecise aborts must be disabled and J bit must be clear and T bit must
  // be set to the value of secure TE bit.
  // OVL_ASSERT: ovl_tz_secure_JAIFT_bits_init
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg last_ns_state;
  reg crnt_ns_state;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      last_ns_state <= 1'b0;
    else
      last_ns_state <= ns_state;

  always @(posedge clk)
    if (insert_forceop_wr)
      crnt_ns_state <= last_ns_state & ~ns_state;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"JAIF == 4'b0111 and T = secure_TE on Non-Secure to Secure state change")
    ovl_tz_secure_JAIFT_bits_init (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (crnt_ns_state & forceop_valid_wr),
      .consequent_expr (({cpsr_ret[24],cpsr_ret[8:6]} == 4'b0111) &
                        (cpsr_ret[5] == u_dpu_cp.cp_sctlr_el3[9])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.3.2.e On Non-Secure to Secure state change, the NS-bit
  // must remain set.
  // OVL_ASSERT: ovl_tz_nsbit_unchanged
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always_on_edge #(`OVL_FATAL,2,`OVL_ASSERT,"NS-bit must remain set on Non-Secure to Secure state change")
    ovl_tz_nsbit_unchanged(
      .clk            (clk),
      .reset_n        (reset_n),
      .sampling_event (ns_state),
      .test_expr      (ns_scr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.3.2.f On Non-Secure to Secure state change, the E-bit must
  //  be set to the value of the Secure EE-bit.
  // OVL_ASSERT: ovl_tz_change_cpsr_e_bit
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"CPSR E-bit must be set to the Secure EE-bit when state changes from Non-Secure to Secure")
    ovl_tz_change_cpsr_e_bit(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (crnt_ns_state & forceop_valid_wr),
      .consequent_expr ((cpsr_ret[9] == u_dpu_cp.cp_sctlr_el3[6])));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.4.1.a Changing from Secure to Non-Secure state can only
  // occur as a result of the following operations:
  // RFE,MSR,CPS or copy SPSR to CPSR in Secure Monitor mode that changes mode
  // when NS-bit=NS or MCR to write SCR.NS bit in Secure Privilege Modes excluding
  // Monitor mode
  // OVL_ASSERT: ovl_tz_valid_change_to_ns_state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Only MSR,CPS,RFE,copy SPSR to CPSR instructions in monitor mode or MCR in SPXM modes can change secure to non-secure state")
    ovl_tz_valid_change_to_ns_state (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (~ns_state & u_dpu_ctl.u_dpu_exception.nxt_ns_state),
      .consequent_expr ((~ns_state &
                         (cpsr_mode_ret != `CA53_FULL_MODE_MON)  &
                         (cpsr_mode_ret != `CA53_FULL_MODE_EL3H) &
                         (cpsr_mode_ret != `CA53_FULL_MODE_EL3T) &
                         (raw_cp_decode_wr == {1'b1, `CA53_CRN1_SCR})) |                            // Write to SCR from non-Monitor/el3x
                        (((cpsr_mode_ret == `CA53_FULL_MODE_MON) |
                          (cpsr_mode_ret == `CA53_FULL_MODE_EL3H) |
                          (cpsr_mode_ret == `CA53_FULL_MODE_EL3T)) &
                         (((u_dpu_cpsr.psr_wr_en_wr[5:3] == 3'b101) & ~aarch64_state)             | // CPS changing mode
                          ({u_dpu_cpsr.psr_wr_en_wr[5:4], u_dpu_cpsr.psr_wr_en_wr[0]} == 3'b01_1) | // MSR to CPSR
                          ((u_dpu_cpsr.psr_wr_en_wr == `CA53_SEL_CPSR_EN_SPSR) &
                           ((u_dpu_cpsr.psr_wr_src_wr == `CA53_SEL_CPSR_SRC_RFE)  |                 // RFE
                            (u_dpu_cpsr.psr_wr_src_wr == `CA53_SEL_CPSR_SRC_SPSR) |                 // Exception return
                            (u_dpu_cpsr.psr_wr_src_wr == `CA53_SEL_CPSR_SRC_DSPSR))))))             // Debug state exit
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.4.a Trace events in Secure User mode are disabled if
  // both SPNIDEN and SUNIDEN are disabled
  // OVL_ASSERT: ovl_tz_user_trace_event_disable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg       ovl_dpu_wpt_valid;
  reg       ovl_dpu_wpt_prohibited;
  reg [4:0] ovl_cpsr_mode;
  reg       ovl_ns_state;
  reg       ovl_sder_suniden_synced;
  wire      ovl_sder_suniden;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_dpu_wpt_valid       <= 1'b0;
      ovl_dpu_wpt_prohibited  <= 1'b0;
      ovl_cpsr_mode           <= 5'b00000;
      ovl_ns_state            <= 1'b0;
    end else begin
      ovl_dpu_wpt_valid       <= dpu_wpt_valid_o;
      ovl_dpu_wpt_prohibited  <= dpu_wpt_prohibited_o;
      ovl_cpsr_mode           <= cpsr_mode_ret;
      ovl_ns_state            <= ns_state;
    end
  
  assign ovl_sder_suniden = cp_sder[1] & ~aarch64_at_el[1];

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      ovl_sder_suniden_synced <= 1'b0;
    else if (u_dpu_dbg.dscr_dbg_en_synced_en)
      ovl_sder_suniden_synced <= ovl_sder_suniden;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Indicate that enters prohibited region when in Secure User mode and SPNIDEN and SUNIDEN are disabled")
    ovl_tz_user_trace_event_disable(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (ovl_dpu_wpt_valid & ((ovl_cpsr_mode == `CA53_FULL_MODE_USR) & ~ovl_ns_state &
                        ~((u_dpu_dbg.dbgen_synced | u_dpu_dbg.niden_synced) & (u_dpu_dbg.spiden_synced | u_dpu_dbg.spniden_synced | ovl_sder_suniden_synced)))),
      .consequent_expr (ovl_dpu_wpt_prohibited)
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.4.a Trace events in Secure Privilege mode are disabled
  // if SPNIDEN is disabled
  // OVL_ASSERT: ovl_tz_priv_trace_event_disable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Indicate that enters prohibited region when in Secure Privilege mode and SPNIDEN is disabled")
    ovl_tz_priv_trace_event_disable(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (ovl_dpu_wpt_valid & ((ovl_cpsr_mode != `CA53_FULL_MODE_USR) & ~ovl_ns_state &
                        ~((u_dpu_dbg.dbgen_synced | u_dpu_dbg.niden_synced) & (u_dpu_dbg.spiden_synced | u_dpu_dbg.spniden_synced)))),
      .consequent_expr (ovl_dpu_wpt_prohibited)
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.4.c PC sampling register must be  0xffffffff when in
  // Secure User mode and SPNIDEN and SUNIDEN are disabled.
  // OVL_ASSERT: ovl_tz_pcsr_s_user_mode
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg  ovl_user_sniden_disable;
  wire nxt_ovl_user_sniden_disable;
  
  assign nxt_ovl_user_sniden_disable = (cpsr_mode_ret == `CA53_FULL_MODE_USR) & ~ns_state &
                                       ~u_dpu_dbg.spiden_synced & ~u_dpu_dbg.spniden_synced & ~ovl_sder_suniden_synced;

  // Sample the permited signal on the same cycle as the program counter updates
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_user_sniden_disable <= 1'b0;
    else if (u_dpu_ctl.en_btm_pc_ret)
      ovl_user_sniden_disable <= nxt_ovl_user_sniden_disable;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"pcsr_lo_rd=0xffffffff when in Secure User mode and SPNIDEN and SUNIDEN are disabled")
    ovl_tz_pcsr_s_user_mode(.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_user_sniden_disable),
                            .consequent_expr (u_dpu_dbg.pcsr_lo_rd == 32'hffffffff));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.4.c PC sampling register must be 0xffffffff when in
  // Secure Privilege modes and SPNIDEN is disabled
  // OVL_ASSERT: ovl_tz_pcsr_s_priv_mode
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg  ovl_priv_sniden_disable;
  wire nxt_ovl_priv_sniden_disable;

  assign nxt_ovl_priv_sniden_disable = (cpsr_mode_ret != `CA53_FULL_MODE_USR) & ~ns_state &
                                       ~u_dpu_dbg.spiden_synced & ~u_dpu_dbg.spniden_synced;

  // Sample the permited signal on the same cycle as the program counter updates
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_priv_sniden_disable <= 1'b0;
    else if (u_dpu_ctl.en_btm_pc_ret)
      ovl_priv_sniden_disable <= nxt_ovl_priv_sniden_disable;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"pcsr_lo_rd=0xffffffff when in Secure Privilege modes and SPNIDEN is disabled")
    ovl_tz_pcsr_s_priv_mode(.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_priv_sniden_disable),
                            .consequent_expr (u_dpu_dbg.pcsr_lo_rd == 32'hffffffff));

  // OVL_ASSERT_END

//----------------------------------------------------------------------------
// ARMv8 Debug Architecture. Section 6.4 Performance Monitors and security
// Specifies event and cycle counting security enables
//----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  wire   ovl_pmu_secure_access_allowed;
  wire   ovl_pmu_secure_access_allowed_init;
  reg    ovl_pmu_secure_access_allowed_init_synced;

  // ovl_pmu_secure_access_allowed generation matches synchronisation in the RTL
  assign ovl_pmu_secure_access_allowed_init = ns_state |
                                              ((~aarch64_at_el[1] | ~aarch64_at_el[3]) & (dpu_exception_level == `CA53_EL0) & ovl_sder_suniden) |
                                              ((u_dpu_dbg.dbgen_reg | u_dpu_dbg.niden_reg) & (u_dpu_dbg.spiden_reg | u_dpu_dbg.spniden_reg));

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      ovl_pmu_secure_access_allowed_init_synced <= 1'b0;
    else if (u_dpu_dbg.dscr_dbg_en_synced_en)
      ovl_pmu_secure_access_allowed_init_synced <= ovl_pmu_secure_access_allowed_init;

  assign ovl_pmu_secure_access_allowed = cp_mdcr_el3_spme | ovl_pmu_secure_access_allowed_init_synced;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PMU event counting is disabled when in Secure mode when SPNIDEN, SUNIDEN and MDCR_EL3.SPME are disabled")
    ovl_secure_pmu_event_disable(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (~(ovl_pmu_secure_access_allowed | ns_state)),
      .consequent_expr (~(|u_dpu_pmu.en_pmevcntr_early_inc)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"PMU cycle counter is disabled when in Secure mode when SPNIDEN, SUNIDEN and MDCR_EL3.SPME are disabled")
    ovl_secure_pmu_cycle_disable(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (~((~u_dpu_pmu.pmn_disable_ccnt_when_prohibited | ovl_pmu_secure_access_allowed | ns_state) & ~dbgdscr_halted)),
      .consequent_expr (~u_dpu_pmu.en_pmccntr_early_inc));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.6.4.a On reset, the Core must start up in SVC mode and
  // secure state
  // OVL_ASSERT: ovl_tz_svc_after_reset
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg first_force_after_reset;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      first_force_after_reset <= 1'b1;
    else if (dpu_fe_valid_ret_o)
      first_force_after_reset <= 1'b0;

  
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Core in SVC/EL3H mode & secure state after reset")
    ovl_tz_svc_after_reset (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (dpu_fe_valid_ret_o & first_force_after_reset),
      .consequent_expr (~ns_state & ((cpsr_mode_ret == `CA53_FULL_MODE_SVC) |
                                     (cpsr_mode_ret == `CA53_FULL_MODE_EL3H))));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.6.4.b Boot address is configured with VINITH
  // initialisation pin when booting to AArch32:
  // - VINITH=1 then PC=0xFFFF0000 else PC=0x00000000
  // OVL_ASSERT: ovl_tz_vinith_pc
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"When booting to AArch32, PC should be 0xFFFF0000 when VINITH=1 else 0x00000000")
    ovl_tz_vinith_pc(
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (first_force_after_reset & dpu_fe_valid_ret_o & ~u_dpu_cp.cp_rmr_el3_aa64),
      .consequent_expr ((dpu_fe_addr_opa_ret_o == {{32{1'b0}}, {16{dpu_hivecs_o}}, 16'h0000}) & (dpu_fe_addr_opb_ret_o == {18{1'b0}})));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  // A double change of dpu_cach eon can only happen if a dpu_force is seen
  reg ovl_dpu_cache_on_reg1;
  reg ovl_dpu_cache_on_reg2;
  reg ovl_dpu_force_reg;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_dpu_cache_on_reg1 <= 1'b0;
      ovl_dpu_cache_on_reg2 <= 1'b0;
      ovl_dpu_force_reg     <= 1'b0;
    end else begin
      ovl_dpu_cache_on_reg1 <= dpu_icache_on_o;
      ovl_dpu_cache_on_reg2 <= ovl_dpu_cache_on_reg1;
      ovl_dpu_force_reg     <= dpu_fe_valid_ret | dpu_fe_valid_wr;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Unexpected dpu_cache_on change")
  ovl_dpu_cache_on (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((ovl_dpu_cache_on_reg2 ^ ovl_dpu_cache_on_reg1) & ~ovl_dpu_force_reg),
    .consequent_expr (ovl_dpu_cache_on_reg1 == dpu_icache_on_o));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  // When the Neon unit is in retention, none of the associated clocks should be active
  reg ovl_stall_neon_rs1;
  reg ovl_stall_neon_rs2;
  reg ovl_neon_is_in_retention;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_stall_neon_rs1        <= 1'b0;
      ovl_stall_neon_rs2        <= 1'b0;
      ovl_neon_is_in_retention  <= 1'b0;
    end else begin
      ovl_stall_neon_rs1        <= gov_stall_neon_i;
      ovl_stall_neon_rs2        <= ovl_stall_neon_rs1;
      ovl_neon_is_in_retention  <= ovl_stall_neon_rs1 & ovl_stall_neon_rs2 & (ovl_neon_is_in_retention | ~dpu_neon_active_o);
    end

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp active while Neon in retention")
  u_ovl_clk_fp_in_ret (
    .clk       (clk_fp),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp_nrf active while Neon in retention")
  u_ovl_clk_fp_nrf_in_ret (
    .clk       (clk_fp_nrf),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp_alu0 active while Neon in retention")
  u_ovl_clk_fp_alu0_in_ret (
    .clk       (clk_fp_alu0),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp_alu1 active while Neon in retention")
  u_ovl_clk_fp_alu1_in_ret (
    .clk       (clk_fp_alu1),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp_mul0 active while Neon in retention")
  u_ovl_clk_fp_mul0_in_ret (
    .clk       (clk_fp_mul0),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_fp_mul1 active while Neon in retention")
  u_ovl_clk_fp_mul1_in_ret (
    .clk       (clk_fp_mul1),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "clk_crypto active while Neon in retention")
  u_ovl_clk_crypto_in_ret (
    .clk       (clk_crypto),
    .reset_n   (reset_n),
    .test_expr (ovl_neon_is_in_retention)
  );
  
  // OVL_ASSERT_END
  
`endif

endmodule // ca53dpu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
