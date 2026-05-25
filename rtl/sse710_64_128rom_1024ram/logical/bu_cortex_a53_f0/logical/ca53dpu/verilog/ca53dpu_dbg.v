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
// DPU Debug block
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_dbg `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                         clk,                             // Clock
  input  wire                         reset_n,                         // Reset
  input  wire                         po_reset_n,                      // Power-on reset
  input  wire                         DFTSE,                           // DFT Scan Enable
  input  wire                         aarch64_state_i,                 // AArch64 state
  input  wire                  [3:1]  aarch64_at_el_i,                 // EL at AArch64
  input  wire                  [1:0]  dpu_exception_level_i,           // Current EL
  input  wire                  [1:0]  target_exception_level_i,        // Target EL
  input  wire                         cp_valid_wr_i,                   // Co-processor register write enable
  input  wire                         nxt_cp_valid_wr_i,               // Early Co-processor register write enable
  input  wire                  [8:0]  raw_cp_decode_wr_i,              // Co-processor register write address
  input  wire                 [63:0]  mcr_data_wr_i,                   // Co-processor register write data
  input  wire                         dpu_fe_valid_ret_i,              // Fetch address valid ret
  input  wire                         expt_quash_wr_i,                 // Exception quashed
  input  wire                         expt_in_halt_i,                  // Exception occured in halting debug
  input  wire                         end_expt_in_halt_i,              // End of exception in halting debug
  input  wire                         expt_fault_reg_sel_wr_i,         // Exception initiate 
  input  wire                         dbg_event_i,                     // Debug event
  input  wire                         dbg_event_halt_wr_i,             // Debug halt event
  input  wire                         dbg_ss_vld_expt_type_ret_i,      // Valid exception type for setting EDESR.SS
  input  wire                         dbg_expt_i,                      // Exception in halt - used in Memory Access Mode
  input  wire                         expt_dbgexit_i,                  // Exception logic debug exit
  input  wire                 [39:12] gov_dbgromaddr_i,                // Debug ROM address
  input  wire                         gov_dbgromaddrv_i,               // Debug ROM address valid
  input  wire                         gov_edecr_osuce_i,               // Un-lock catch event enable
  input  wire                         gov_edecr_rce_i,                 // Reset catch debug event enable
  input  wire                         gov_edecr_ss_i,                  // Halting step debug event enable
  input  wire                         gov_edlsr_slk_i,                 // Lock status register - software lock (restricts access to debug registers)
  input  wire                         gov_pmlsr_slk_i,                 // Performance monitor status register - software lock (restricts access to perf mon registers)
  input  wire                         gov_dbgpwrupreq_i,               // Debug power-up request
  input  wire                         pre_valid_instrs_wr_i,           // Instructions present in write back (wr)
  input  wire                         stall_wr_i,                      // Stall the processor
  input  wire                         quash_wr_i,                      // Exception detected in wr - triggers and exception
  input  wire                         flush_wr_i,                      // Flush everything before we
  input  wire                         first_x64_wr_i,                  // Load/store that crosses a 64 boundary
  input  wire                         end_instr_wr_i,                  // Last instruction cycle that can change state
  input  wire                  [3:0]  expt_status_moe_data_wr_i,       // Debug entry value (MOE)
  input  wire                         expt_idle_i,                     // Exception state machine idle
  input  wire                         no_interrupt_wr_i,               // Interrupt mask
  input  wire                 [31:0]  fwd_ld_data_int_wr_i,            // Forwarded Load data
  input  wire                 [48:0]  pc_instr0_ret_i,                 // Program counter
  input  wire                         pc_sample_perm_i,                // PC (Program Counter) Sampling Permitted
  input  wire                  [1:0]  isa_instr0_ret_i,                // Instr Set Arch for slot 0 in ret
  input  wire                         cc_pass_instr0_wr_i,             // Condition code pass
  input  wire                         dcu_dbg_dsb_ack_i,               // DCU Data Sync Barrier completed
  input  wire                         ifu_dbg_ready_i,                 // IFU ready for debug events
  input  wire                         gov_dbgen_i,                     // Debug invasive enable
  input  wire                         gov_niden_i,                     // Non-invasive debug enable
  input  wire                         gov_spiden_i,                    // Secure PL1 invasive debug enable
  input  wire                         gov_spniden_i,                   // Secure PL1 non-invasive debug enable
  input  wire                  [1:0]  cp_sder_i,                       // Secure debug enable register
  input  wire                         gov_edbgrq_i,                    // External debug request from Embedded Cross Trigger (ECT) via the GOV
  input  wire                         gov_dbgrestart_i,                // External debug re-start request
  input  wire                         cpsr_dbit_ret_i,                 // CPSR D bit
  input  wire                  [4:0]  cpsr_mode_ret_i,                 // CPSR - processor mode
  input  wire                         ldc_ex2_i,                       // Instruction in Ex2 is an LDC
  input  wire                         ls_store_wr_i,                   // Load/store store
  input  wire                         ldc_stc_wr_i,                    // Instruction in WR is LDC or STC
  input  wire                         ns_state_i,                      // Non-secure state
  input  wire                         ns_scr_i,                        // SCR_EL3.NS
  input  wire                         hdcr_tde_i,                      // Route debug exceptions from Non-secure
  input  wire                         cp_mdcr_el3_sdd_i,               // Secure debug disable
  input  wire                  [1:0]  cp_mdcr_el3_spd32_i,             // Debug security enable
  input  wire                         cp_mdcr_el3_spme_i,              // Secure performance monitors enable
  input  wire                         cp_mdcr_el3_epmad_i,             // External perf mon register access disable
  input  wire                         cp_mdcr_el3_edad_i,              // External debugger register access disable
  input  wire                         expt_serr_pending_i,             // System Error interrupt pending
  input  wire [`CA53_CPSR_RET_W-1:0]  dspsr_reg_i,                     // DSPSR Debug Processor Status Register
  input  wire                         forceop_valid_wr_i,              // Force Operation for the PC and PSR complete
  input  wire                 [63:0]  dcu_va_dc3_i,                    // Virtual address for transaction in dc3-stage
  input  wire                         expt_type_l1_ecc_i,              // L1 cache ECC error exception
  // Outputs
  output wire                         in_halt_o,                       // In halting debug state
  output wire                 [63:0]  dbg_cp_rd_data_o,                // Co-processor register read data
  output wire                  [3:0]  cpsr_flag_update_nzcv_o,         // CPSR new flag values
  output wire                         cpsr_flag_update_cp_dscr_wr_o,   // CPSR flag write enable
  output wire                 [31:0]  dpu_dbg_ins_o,                   // Debug instruction to DPU
  output wire                         dpu_dbg_valid_o,                 // Debug instruction valid to DPU
  output wire                         dbgdscr_halted_o,                // Processor in debug state (DBGDSCR.halted)
  output wire                         edscr_sdd_o,                     // Secure debug disabled
  output wire                         edscr_tda_o,                     // Trap accesses to debug registers
  output wire                  [1:0]  edscr_intdis_o,                  // EDSCR.INTdis for exception logic
  output wire                         dbgen_synced_o,                  // Debug enabled (for exception logic)
  output wire                         spiden_synced_o,                 // Secure debug enabled (for exception logic)
  output wire                         dbg_hlt_en_o,                    // HLT instruction enabled
  output wire                         dbg_bkpt_wpt_en_o,               // HW BKPT enabled
  output wire                 [31:0]  dbg_dtrrx_data_o,                // Debug transfer register output
  output wire                         dbg_hw_halt_req_o,               // Internal or External Halt request
  output wire                         held_dbg_hw_halt_req_o,          // Internal or External Halt request Held
  output wire                         held_dbg_osuc_halt_req_o,        // OS lock withdrawn
  output wire                         held_dbg_ext_hw_halt_req_o,      // Request external hardware debug Held
  output wire                         dbg_restart_qual_o,              // Request end of debug state
  output wire                         dbg_cancel_biu_o,                // Cancel debug bus request
  output wire                         dpu_apb_active_o,                // Debug APB transfer is active
  output reg                          dpu_dbg_dsb_req_o,               // Debug Data Sync Barrier Request
  output reg                          dpu_dbg_tlb_sw_bkpt_wpt_en_o,    // Software Breakpoint and watchpoint enabled
  output reg                          dpu_dbg_tlb_hw_bkpt_wpt_en_o,    // Hardware Breakpoint and watchpoint enabled
  output wire                         dpu_dbg_sample_contextid_o,      // Sampled context ID
  output reg                          dpu_dbgtrigger_o,                // Debug acknowledge
  output reg                          dpu_dbgack_o,                    // External debug acknoledge
  output wire                         dpu_commrx_o,                    // Debug Communications Channel can accept a write
  output wire                         dpu_commtx_o,                    // Debug Communications Channel can accept a read
  output wire                         dpu_ncommirq_o,                  // Debug Communications Channel interrupt
  output wire                         dpu_dbgnopwrdwn_o,               // Core no power-down request (DBGPRCR.CORENPDRQ)
  output wire                         dbg_non_inv_perm_us_o,           // Debug non-invasive permitted (unsynced)
  output wire                         dbg_non_inv_perm_synced_o,       // Debug non-invasive permitted (synced)
  output wire                         dbg_os_lock_synced_o,            // Debug OS lock
  output wire                         dbg_double_lock_set_o,           // Debug Double lock Status
  output wire                         dpu_dbgrstreq_o,                 // Core warm reset request (DBGPRCR.CWRR)
  output wire                         dbg_halting_allowed_o,           // Debug external Halting allowed (HLT instruction)
  output wire                         cp14_wr_dspsr_o,                 // Write enable to DSPSR status register
  output wire                         dbg_starting_o,                  // Processor starting in halt mode
  output wire                         ss_enter_halt_o,                 // Single step complete - re enter halt mode
  output wire                         edecr_ss_reg_o,                  // Halting step debug event enable - registered
  output wire                  [1:0]  exception_level_debug_o,         // ELd
  output wire                  [3:0]  debug_enabled_from_el_o,         // Whether debug exceptions are enabled from each EL
  output wire                         mdscr_el1_tdcc_o,                // MDSCR_EL1.TDCC
  output wire                         mdscr_el1_ss_o,                  // MDSCR_EL1.SS
  output wire                         dbg_soft_step_active_o,          // Software step state machine is in one of the active states
  output wire                         dbg_halt_step_active_not_pend_o, // Halting step state machine is in the active-not-pending state
  output reg                          dpu_reset_catch_pending_o,       // A reset catch debug event is pending (to IFU)
  output reg                          dpu_expt_catch_pending_o,        // An exception catch debug event is pending (to IFU)
  output wire                         nxt_pc_sample_perm_o,            // PC Sample Permitted - ready for registering 
  // APBv3 Inputs
  input  wire                         gov_pseldbg_dbg_i,               // APB PSELDBG (debug logic)
  input  wire                         gov_pseldbg_pmu_i,               // APB PSELDBG (PMU)
  input  wire                         gov_pwritedbg_i,                 // APB PWRITEDBG
  input  wire                 [11:2]  gov_paddrdbg_i,                  // APB PADDRDBG
  input  wire                         gov_paddrdbg31_i,                // APB PADDRDBG31 (external debugger when 1)
  input  wire                 [31:0]  gov_pwdatadbg_i,                 // APB PWDATADBG
  // APBv3 Outputs
  output wire                 [31:0]  dpu_prdatadbg_o,                 // APB PRDATADBG
  output wire                         dpu_preadydbg_o,                 // APB PREADYDBG
  output wire                         dpu_pslverrdbg_o,                // APB PSLVERRDBG
  // APB read data from TLB/PMU
  input  wire                 [31:0]  tlb_dbg_rdata_i,                 // APB read data from TLB
  input  wire                 [31:0]  pmu_apb_rdata_i,                 // APB read data from PMU
  input  wire                         apb_pmu_access_i,                // APB PMU access
  // APB bus to TLB/PMU
  output wire                         dpu_dbg_wr_o,                    // APB TLB write enable
  output wire                 [11:2]  apb_addr_o,                      // APB address
  output wire                 [31:0]  apb_wdata_o,                     // APB write data
  output wire                         pmu_apb_wr_o,                    // APB PMU write enable
  output wire                         nxt_pmu_apb_wr_o                 // APB PMU early write enable - used for clock gate enable
);

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  localparam [2:0] DBG_STATE_RUN          = 3'b000;
  localparam [2:0] DBG_STATE_DCU_DRAIN    = 3'b001;
  localparam [2:0] DBG_STATE_IFU_DRAIN    = 3'b010;
  localparam [2:0] DBG_STATE_HALTED       = 3'b011;
  localparam [2:0] DBG_STATE_RESTART_HELD = 3'b100;
  localparam [2:0] DBG_STATE_RESTARTING   = 3'b101;

  localparam [3:0] MA_STATE_WAIT          = 4'b0000;
  localparam [3:0] MA_STATE_READ_LDR      = 4'b0001;
  localparam [3:0] MA_STATE_READ_LDR_W    = 4'b0010;
  localparam [3:0] MA_STATE_READ_LDR_E    = 4'b0011;
  localparam [3:0] MA_STATE_READ_MSR      = 4'b0100;
  localparam [3:0] MA_STATE_READ_MSR_W    = 4'b0101;
  localparam [3:0] MA_STATE_READ_ECC_W    = 4'b0110;
  localparam [3:0] MA_STATE_WRITE_MRS     = 4'b1001;
  localparam [3:0] MA_STATE_WRITE_MRS_W   = 4'b1010;
  localparam [3:0] MA_STATE_WRITE_MRS_E   = 4'b1011;
  localparam [3:0] MA_STATE_WRITE_STR     = 4'b1100;
  localparam [3:0] MA_STATE_WRITE_STR_W   = 4'b1101;
  localparam [3:0] MA_STATE_WRITE_STR_E   = 4'b1110;
  
  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg    [3:0]  nxt_ma_state;
  reg    [3:0]  ma_state;
  reg           ma_wait;
  reg   [31:0]  editr_ma_val;
  reg           editr_ma_wr;
  reg           ma_read_cmplt;
  reg           ma_write_cmplt;
  reg           ma_expt_cmplt;
  reg           ma_clr_ite;
  reg           ma_active;
  reg           dbgen_reg;
  reg           niden_reg;
  reg           spiden_reg;
  reg           spniden_reg;
  reg           dbgen_synced;
  reg           niden_synced;
  reg           spiden_synced;
  reg           spniden_synced;
  reg           dbg_double_lock_status_synced;
  reg           dbg_halting_allowed_synced;
  reg           edbgrq_reg;
  reg           dbgrestart_reg;
  reg           edecr_osuce_reg;
  reg           edecr_ss_reg;
  reg           edecr_rce_reg;
  reg           edlsr_slk_reg;
  reg           pmlsr_slk_reg;
  reg           dbgpwrupreq_reg;
  reg           dbg_non_inv_perm_synced;
  reg           nxt_in_halt;
  reg           in_halt;
  reg           dscr_halted;
  reg           dbg_restarting;
  reg           dbg_starting;
  reg    [3:0]  dscr_moe;
  reg           dscr_udcc_dis;
  reg           edscr_ite;
  reg           dscr_dtrtx_full;
  reg           dscr_dtrrx_full;
  reg           mdscr_el1_ss;
  reg           mdscr_el1_kde;
  reg           edscr_err;
  reg           dbg_cint_rx;
  reg           dbg_cint_tx;
  reg           dbg_trigger;
  reg    [3:0]  dbg_entry_status;
  reg           edscr_hde_synced;
  reg           dscr_mdbg_en;
  reg           dbg_os_lock_synced;
  reg           edrcr_cbrrq;
  reg           l1_ecc_detect;
  reg   [31:0]  editr;
  reg   [31:0]  dtrrx;
  reg   [31:0]  dtrtx;
  reg           pwritedbg_reg;
  reg   [11:2]  paddrdbg_reg;
  reg           paddrdbg31_reg;
  reg   [31:0]  pwdatadbg_reg;
  reg           preadydbg;
  reg   [31:0]  prdatadbg;
  reg           pslverrdbg;
  reg           edprcr_corenpdrq;
  reg           edprcr_reset_req;
  reg    [1:0]  edeccr_nse;
  reg    [1:0]  edeccr_se;
  reg           edesr_ss;
  reg           edesr_rc;
  reg           edesr_osuc;
  reg           edscr_hde;
  reg           edprsr_sdr;
  reg           edprsr_spmad;
  reg           edprsr_sdad;
  reg           edprsr_sr;
  reg           edprsr_spd;
  reg    [7:0]  claim_reg;
  reg           dbg_os_lock_set;
  reg           osdlr_el1_dlk;
  reg   [16:0]  pcsr_hi;
  reg   [63:0]  edwar_rd;
  reg    [2:0]  dbg_state;
  reg    [2:0]  nxt_dbg_state;
  reg   [39:12] dbgromaddr_reg;
  reg           dbgromaddrv_reg;
  reg           forceop_cmpt;
  reg           apb_dbg_active;
  reg           apb_pmu_active;
  reg           apb_strobe;
  reg           load_initial_cold;
  reg           load_initial_warm;
  reg           dbg_regs_clken;
  reg           dbg_halt_clken;
  reg           dpu_dbg_valid;
  reg           held_dbg_hw_halt_req;
  reg           held_dbg_osuc_halt_req;
  reg           held_dbg_ext_hw_halt_req;
  reg           edscr_ma;
  reg           edscr_sdd;
  reg           edscr_tda;
  reg    [1:0]  edscr_intdis;
  reg           edscr_txu;
  reg           edscr_rxo;
  reg           edscr_ito;
  reg           edscr_pipeadv;
  reg    [3:0]  debug_enabled_from_el_us;
  reg           dbg_soft_step_active;
  reg           expt_catch_pending;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire          nxt_dbg_regs_clken;
  wire          nxt_dbg_halt_clken;
  wire          clk_dbg_regs;
  wire          clk_dbg_halt;
  wire          apb_dbg_rd_req;
  wire          apb_pmu_rd_req;
  wire          apb_dbg_wr_req;
  wire          apb_pmu_wr_req;
  wire          nxt_dscr_mdbg_en;
  wire          nxt_mdscr_el1_kde;
  wire          nxt_dscr_udcc_dis;
  wire   [1:0]  nxt_edeccr_nse;
  wire   [1:0]  nxt_edeccr_se;
  wire  [16:0]  nxt_pcsr_hi;
  wire  [31:0]  pcsr_lo_rd;
  wire  [48:0]  pc_instr0_no_offset_ret;
  wire          dscr_load_en;
  wire          edeccr_en;
  wire  [31:0]  edeccr_rd;
  wire  [31:0]  oseccr_rd;
  wire          nxt_edesr_ss;
  wire          nxt_edesr_rc;
  wire          nxt_edesr_osuc;
  wire  [31:0]  edesr_rd;
  wire          dbg_hw_halt_req;
  wire          dbg_ext_hw_halt_req;
  wire          dbg_osuc_halt_req;
  wire  [31:0]  dbg_mdccint;
  wire  [31:0]  dspsr_rd;
  wire          dbg_double_lock_status_us;
  wire  [31:0]  edscr_rd;
  wire          ifu_drain_state_en;
  wire  [31:0]  nxt_prdatadbg;
  wire          prdatadbg_en;
  wire          nxt_forceop_cmpt;
  wire          dbg_restart_qual;
  wire          valid_apb_dbg;
  wire          valid_apb_pmu;
  wire          nxt_pslverrdbg;
  wire          apb_wr_edscr;
  wire          nxt_edscr_hde;
  wire          cp14_wr_dscr_ext;
  wire          cp14_wr_oseccr_el1;
  wire          cp14_wr_mdscr_el1;
  wire          cp14_wr_dtrrx_ext;
  wire          load_dscr_moe;
  wire          load_mdscr_el1_ss;
  wire          load_edscr_err;
  wire   [3:0]  nxt_dscr_moe;
  wire          nxt_dscr_dtrrx_full;
  wire          nxt_dscr_dtrtx_full;
  wire          nxt_edscr_err;
  wire          dpu_instr_retire;
  wire          nxt_edscr_ite;
  wire          nxt_edscr_txu;
  wire          set_edscr_txu;
  wire          nxt_edscr_rxo;
  wire          set_edscr_rxo;
  wire          nxt_edprsr_spd;
  wire          nxt_edprsr_sr;
  wire          apb_wr_edrcr;
  wire          cp14_wr_oslar;
  wire          cp14_wr_osdlr;
  wire          edrcr_cse;
  wire          edrcr_cspa;
  wire          set_edrcr_cbrrq;
  wire          clr_edrcr_cbrrq;
  wire          nxt_edrcr_cbrrq;
  wire          apb_wr_editr;
  wire          load_editr;
  wire          load_editr_apb;
  wire          nxt_dpu_dbg_valid;
  wire          nxt_ma_wait;
  wire          nxt_l1_ecc_detect;
  wire          l1_ecc_resend;
  wire  [31:0]  nxt_editr;
  wire          apb_wr_edesr;
  wire          apb_wr_edeccr;
  wire          apb_wr_dtrrx;
  wire          apb_rd_edesr;
  wire          apb_rd_dtrrx;
  wire          apb_rd_edscr;
  wire          apb_rd_dtrtx;
  wire          apb_rd_edeccr;
  wire          apb_rd_edpcsrlo;
  wire          apb_rd_edpcsrhi;
  wire          apb_rd_edprcr;
  wire          apb_rd_edprsr;
  wire          apb_rd_claimset;
  wire          apb_rd_claimclr;
  wire          apb_rd_edwar_lo;
  wire          apb_rd_edwar_hi;
  wire          apb_rd_tlb;
  wire          apb_rd_pmu;
  wire          cp14_wr_dtr;
  wire          load_dtrrx;
  wire          load_dtrrx_flag;
  wire  [31:0]  nxt_dtrrx;
  wire          apb_rd_se_dtrtx;
  wire          apb_wr_dtrtx;
  wire          cp14_wr_dtrtx_ext;
  wire          load_dtrtx;
  wire          load_dtrtx_flag;
  wire  [31:0]  nxt_dtrtx;
  wire          cp14_wr_dtrtx_int;
  wire          cp14_rd_drar;
  wire          cp14_rd_dtr_el0;
  wire          cp14_rd_didr;
  wire          cp14_rd_dscr_int;
  wire          cp14_rd_mdccsr_el0;
  wire          cp14_rd_dscr_flags;
  wire          cp14_rd_dtrrx_int;
  wire          cp14_rd_dtrrx_ext;
  wire          cp14_rd_dscr_ext;
  wire          cp14_rd_mdscr_el1;
  wire          cp14_rd_dtrtx_ext;
  wire          cp14_rd_osdlr;
  wire          cp14_rd_oslsr;
  wire          cp14_rd_prcr;
  wire          cp14_rd_claimset;
  wire          cp14_rd_claimclr;
  wire          cp14_rd_authstatus;
  wire          cp14_rd_devid;
  wire          cp14_rd_devid1;
  wire          cp14_rd_mdccint_el1;
  wire          cp14_rd_oseccr_el1;
  wire          cp14_rd_dspsr;
  wire          ldc_wr_dtrtx_int;
  wire          stc_rd_dtrrx_int;
  wire          nxt_edprcr_corenpdrq;
  wire          load_edwar;
  wire          nxt_edprcr_reset_req;
  wire          left_debug;
  wire          nxt_edprsr_sdr;
  wire          nxt_edprsr_spmad;
  wire          set_edprsr_sdad;
  wire          nxt_edprsr_sdad;
  wire  [31:0]  oslsr_rd;
  wire  [31:0]  edprcr_rd;
  wire          edprsr_epmad;
  wire          allow_ext_debug_access;
  wire          edprsr_edad;
  wire          edprsr_r;
  wire          apb_wr_edprcr;
  wire          cp14_wr_prcr;
  wire          apb_rd_se_edprsr;
  wire          apb_rd_se_edpcsrlo;
  wire          apb_wr_claimset;
  wire          apb_wr_claimclr;
  wire          apb_dbgbwr;
  wire          apb_wr_dbgbvr;
  wire          apb_wr_dbgwvr;
  wire          cp14_wr_claimset;
  wire          cp14_wr_claimclr;
  wire          cp14_wr_mdccint;
  wire   [7:0]  claim_setbits;
  wire   [7:0]  claim_clrbits;
  wire          en_claim_reg;
  wire   [7:0]  nxt_claim_reg;
  wire   [5:0]  edscr_status;
  wire          apb_wr_oslar;
  wire          nxt_os_lock_set;
  wire  [31:0]  claimset_rd;
  wire  [31:0]  claimclr_rd;
  wire  [31:0]  didr_rd;
  wire  [63:0]  drar_rd;
  wire  [31:0]  dscr_int;
  wire  [31:0]  mdccsr_el0;
  wire  [31:0]  mdscr_el1;
  wire  [31:0]  dscr_ext;
  wire  [31:0]  osdlr_rd;
  wire  [31:0]  edprsr_rd;
  wire  [31:0]  dbg_authstatus_rd;
  wire  [31:0]  dbg_devid_rd;
  wire  [31:0]  dbg_devid1_rd;
  wire          dbg_apb_slk;
  wire          dbg_apb_full_lock;
  wire          dbg_apb_dbl_lock;  
  wire          pmu_apb_slk;
  wire          dbg_halting_allowed_us;
  wire          dbg_non_inv_perm_us;
  wire  [31:0]  pcsr_hi_rd;
  wire          nxt_apb_dbg_active;
  wire          nxt_apb_pmu_active;
  wire          nxt_apb_strobe;
  wire          dscr_dbg_en_synced_en;
  wire          spid_dis;
  wire          debug_entry;
  wire          nxt_edscr_ma;
  wire          edscr_ma_qual;
  wire          edscr_ma_extend;
  wire          edscr_ns;
  wire          nxt_edscr_sdd;
  wire          spnid_dis;
  wire          nxt_edscr_tda;
  wire          nxt_edscr_pipeadv;
  wire   [1:0]  edscr_el;
  wire   [3:0]  edscr_rw;
  wire   [1:0]  nxt_edscr_intdis;
  wire          clr_edscr_ito;
  wire          set_edscr_ito;
  wire          nxt_edscr_ito;
  wire          ss_enter_halt;
  wire          dbg_halt_step_active_not_pend;
  wire          nxt_dbg_soft_step_active;
  wire          clear_oslk;
  wire          allow_ext_pmu_access;
  wire          aarch32_secure_debug_auth;
  wire   [1:0]  exception_level_debug;
  wire          dpu_dbg_tlb_hw_bkpt_wpt_en_us;
  wire          dpu_dbg_tlb_sw_bkpt_wpt_en_us;
  wire          nxt_expt_catch_pending;
  wire          nxt_reset_catch_pending;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ---------------------------------------------------------
  // Initialise registers on reset
  // ---------------------------------------------------------
  // The reset values of some CP14 registers depend on top-level inputs.
  // Therefore the load_initial_cold and load_initial_warm registers are 
  // reset to 1, then used as an enable to load these values in on the 
  // first clock cycle during reset.
  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      load_initial_cold <= 1'b1;
    else if (load_initial_cold)
      load_initial_cold <= 1'b0;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      load_initial_warm <= 1'b1;
    else if (load_initial_warm)
      load_initial_warm <= 1'b0;

  // ------------------------------------------------------
  // Intermediate clock gates
  // ------------------------------------------------------
  // Registers that are only written using MCR or LDC instructions or via the
  // APB interface can be gated using an intermediate clock gate
  assign nxt_dbg_regs_clken = nxt_cp_valid_wr_i | ldc_ex2_i | (ldc_stc_wr_i & ~ls_store_wr_i) |
                              nxt_apb_strobe | apb_strobe | nxt_apb_dbg_active | nxt_apb_pmu_active;

  // Other registers are enabled when halt is active or registers accesses
  assign nxt_dbg_halt_clken = in_halt | dbg_event_halt_wr_i | dbg_event_halt_wr_i | load_initial_warm | nxt_dbg_regs_clken;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dbg_regs_clken <= 1'b1;
      dbg_halt_clken <= 1'b1;
    end else begin
      dbg_regs_clken <= nxt_dbg_regs_clken;
      dbg_halt_clken <= nxt_dbg_halt_clken;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_dbg_regs (
    .clk_i         (clk),
    .clk_enable_i  (dbg_regs_clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_dbg_regs)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_pmu_halt (
    .clk_i         (clk),
    .clk_enable_i  (dbg_halt_clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_dbg_halt)
  );

  // ------------------------------------------------------
  // Synchronise the halting debug control signals with insert_forceop_ret_i and PC change.
  // ------------------------------------------------------
  assign dscr_dbg_en_synced_en = dpu_fe_valid_ret_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dbg_non_inv_perm_synced      <= 1'b0;
    end else if (dscr_dbg_en_synced_en) begin
      dbg_non_inv_perm_synced      <= dbg_non_inv_perm_us;
    end

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n) begin
      dbgen_synced                  <= 1'b0;
      niden_synced                  <= 1'b0;
      spiden_synced                 <= 1'b0;
      spniden_synced                <= 1'b0;
      edscr_hde_synced              <= 1'b0;
      dbg_os_lock_synced            <= 1'b1;
      dpu_expt_catch_pending_o      <= 1'b0;
      dpu_reset_catch_pending_o     <= 1'b0;
      dbg_double_lock_status_synced <= 1'b0;
      dbg_halting_allowed_synced    <= 1'b0;
      dpu_dbg_tlb_hw_bkpt_wpt_en_o  <= 1'b0;
      dpu_dbg_tlb_sw_bkpt_wpt_en_o  <= 1'b0;
      dbg_soft_step_active          <= 1'b0;
    end else if (dscr_dbg_en_synced_en) begin
      dbgen_synced                  <= dbgen_reg;
      niden_synced                  <= niden_reg;
      spiden_synced                 <= spiden_reg;
      spniden_synced                <= spniden_reg;
      edscr_hde_synced              <= edscr_hde;
      dbg_os_lock_synced            <= dbg_os_lock_set;
      dpu_expt_catch_pending_o      <= nxt_expt_catch_pending;
      dpu_reset_catch_pending_o     <= nxt_reset_catch_pending;
      dbg_double_lock_status_synced <= dbg_double_lock_status_us;
      dbg_halting_allowed_synced    <= dbg_halting_allowed_us;
      dpu_dbg_tlb_hw_bkpt_wpt_en_o  <= dpu_dbg_tlb_hw_bkpt_wpt_en_us;
      dpu_dbg_tlb_sw_bkpt_wpt_en_o  <= dpu_dbg_tlb_sw_bkpt_wpt_en_us;
      dbg_soft_step_active          <= nxt_dbg_soft_step_active;
    end

  // ------------------------------------------------------
  // Debug authentication signals
  // ------------------------------------------------------

  // Register the top-level authentication inputs
  always @(posedge clk) begin
    edbgrq_reg      <= gov_edbgrq_i;
    dbgrestart_reg  <= gov_dbgrestart_i;
    dbgpwrupreq_reg <= gov_dbgpwrupreq_i;
    edecr_osuce_reg <= gov_edecr_osuce_i;
    edecr_ss_reg    <= gov_edecr_ss_i;
    edecr_rce_reg   <= gov_edecr_rce_i;
    dbgen_reg       <= gov_dbgen_i;
    niden_reg       <= gov_niden_i;
    spiden_reg      <= gov_spiden_i;
    spniden_reg     <= gov_spniden_i;
  end

  // Secure user halting debug is not supported, so generated a more restrictive
  // permission signal for halting debug 
  // See Function 39 HaltingAllowed
  assign dbg_halting_allowed_us = dbgen_reg & (ns_state_i | spiden_reg) & ~dbg_double_lock_status_us & ~in_halt;

  // Register different versions of the halt permissions prior to use in the exception logic
  assign dbg_hw_halt_req     = (edesr_osuc & dbg_halting_allowed_synced) | (edbgrq_reg & dbg_halting_allowed_synced); // Internal or External Halt request
  assign dbg_ext_hw_halt_req = edbgrq_reg & dbg_halting_allowed_us;                                                   // External Halt request only
  assign dbg_osuc_halt_req   = edesr_osuc & dbg_halting_allowed_synced;

  always @(posedge clk) begin
    held_dbg_hw_halt_req     <= dbg_hw_halt_req;
    held_dbg_osuc_halt_req   <= dbg_osuc_halt_req;
    held_dbg_ext_hw_halt_req <= dbg_ext_hw_halt_req;
  end

  always @*
    case (dpu_exception_level_i)
      `CA53_EL0: expt_catch_pending = 1'b0;
      `CA53_EL1: expt_catch_pending = (ns_state_i ? edeccr_nse[0] : edeccr_se[0]);
      `CA53_EL2: expt_catch_pending = edeccr_nse[1];
      `CA53_EL3: expt_catch_pending = edeccr_se[1];
      default:   expt_catch_pending = 1'bx;
    endcase

  assign nxt_expt_catch_pending  = expt_catch_pending & dbg_halting_allowed_us;
  assign nxt_reset_catch_pending = edesr_rc & dbg_halting_allowed_us;
  
  // Function 59: CreatePCSample plus SUNIDEN
  assign dbg_non_inv_perm_us = (dbgen_reg | niden_reg) &                      // Non-invasive debug enabled and
                               (ns_state_i |                                  // non-secure state, or
                                spiden_reg   |                                // secure invasive debug permitted, or
                                spniden_reg  |                                // secure non-invasive debug permitted, or
                                (cp_sder_i[1] &
                                 (cpsr_mode_ret_i == `CA53_FULL_MODE_USR) & 
                                 ~aarch64_at_el_i[1]));                       // secure user non-invasive debug permitted and in user mode

  // ------------------------------------------------------
  // Memory Access Mode - State Machine
  // ------------------------------------------------------
  // When EDSCR.MA is high a read from DBGDTRTX_EL0 or write to DBGTRRX_EL0 triggers a memory access.
  // If EDSCR.MA returns low the current memory accesses will be completed.
  // When a request is made to exit halting debug, the exit is delayed until the current memory access is complete.

  always @* begin
    nxt_ma_state   = ma_state;
    editr_ma_val   = 32'h00000000;
    editr_ma_wr    = 1'b0;
    ma_read_cmplt  = 1'b0;
    ma_write_cmplt = 1'b0;
    ma_expt_cmplt  = 1'b0;
    ma_clr_ite     = 1'b0;
    ma_active      = 1'b1;

    case (ma_state)
      MA_STATE_WAIT: begin
        ma_active    = 1'b0;
        if (apb_rd_se_dtrtx & dscr_dtrtx_full & edscr_ma_qual) begin
          nxt_ma_state = MA_STATE_READ_LDR;
          ma_clr_ite   = 1'b1;
          ma_active    = 1'b1;
        end
        else if (apb_wr_dtrrx & ~dscr_dtrrx_full & edscr_ma_qual) begin
          nxt_ma_state = MA_STATE_WRITE_MRS;
          ma_clr_ite   = 1'b1;
          ma_active    = 1'b1;
        end
      end

      MA_STATE_READ_LDR:
        if (edscr_err) begin
          ma_expt_cmplt = 1'b1;
          nxt_ma_state  = MA_STATE_WAIT;
        end
        else begin
          editr_ma_val  = aarch64_state_i ? 32'hb8404401  // LDR w1,[x0],#4
                                          : 32'h1b04f850; // LDR r1,[r0],#4
          editr_ma_wr   = 1'b1;
          nxt_ma_state  = MA_STATE_READ_LDR_W;
        end

      MA_STATE_READ_LDR_W:
        if (dbg_expt_i)
          nxt_ma_state = MA_STATE_READ_LDR_E;
        else if (dpu_instr_retire) begin
          if (expt_type_l1_ecc_i)
            nxt_ma_state = MA_STATE_READ_ECC_W;
          else
            nxt_ma_state = MA_STATE_READ_MSR;
        end

      MA_STATE_READ_LDR_E:
        if (expt_idle_i) begin
          nxt_ma_state  = MA_STATE_WAIT;
          ma_expt_cmplt = 1'b1;
        end

      MA_STATE_READ_ECC_W: // If ECC ocurres wait till exception complete then retry access
        if (expt_idle_i)
          nxt_ma_state   = MA_STATE_READ_LDR_W;

      MA_STATE_READ_MSR:
        if (edscr_err) begin
          ma_expt_cmplt = 1'b1;
          nxt_ma_state  = MA_STATE_WAIT;
        end
        else begin
          editr_ma_val  = aarch64_state_i ? 32'hd5130501  // MSR DBGDTRTX_EL0,x1
                                          : 32'h1e15ee00; // MCR p14,#0x0,r1,c0,c5,#0 //DBGDTRTXint
          editr_ma_wr   = 1'b1;
          nxt_ma_state  = MA_STATE_READ_MSR_W;
        end

      MA_STATE_READ_MSR_W:
        if (dpu_instr_retire) begin
          nxt_ma_state  = MA_STATE_WAIT;
          ma_read_cmplt = 1'b1;
        end

      MA_STATE_WRITE_MRS:
        if (edscr_err) begin
          ma_expt_cmplt = 1'b1;
          nxt_ma_state  = MA_STATE_WAIT;
        end
        else begin
          editr_ma_val  = aarch64_state_i ? 32'hd5330501  // MRS x1,DBGDTRRX_EL0
                                          : 32'h1e15ee10; // MRC p14,#0x0,r1,c0,c5,#0 // DBGDTRRXint
          editr_ma_wr   = 1'b1;
          nxt_ma_state  = MA_STATE_WRITE_MRS_W;
        end

      MA_STATE_WRITE_MRS_W:
        if (dbg_expt_i)
          nxt_ma_state = MA_STATE_WRITE_MRS_E;
        else if (dpu_instr_retire)
          nxt_ma_state = MA_STATE_WRITE_STR;

      MA_STATE_WRITE_MRS_E:
        if (expt_idle_i) begin
          nxt_ma_state  = MA_STATE_WAIT;
          ma_expt_cmplt = 1'b1;
        end

      MA_STATE_WRITE_STR:
        if (edscr_err) begin
          ma_expt_cmplt = 1'b1;
          nxt_ma_state  = MA_STATE_WAIT;
        end
        else begin
          editr_ma_val  = aarch64_state_i ? 32'hb8004401  // STR w1,[x0],#4
                                          : 32'h1b04f840; // STR r1,[r0],#4
          editr_ma_wr   = 1'b1;
          nxt_ma_state  = MA_STATE_WRITE_STR_W;
        end

      MA_STATE_WRITE_STR_W:
        if (dbg_expt_i)
          nxt_ma_state = MA_STATE_WRITE_STR_E;
        else if (dpu_instr_retire) begin
          nxt_ma_state   = MA_STATE_WAIT;
          ma_write_cmplt = 1'b1;
        end

      MA_STATE_WRITE_STR_E: 
        if (expt_idle_i) begin
          nxt_ma_state   = MA_STATE_WAIT;
          ma_expt_cmplt = 1'b1;
        end

      default: begin
        nxt_ma_state   = 4'bxxxx;
        editr_ma_val   = {32{1'bx}};
        editr_ma_wr    = 1'bx;
        ma_read_cmplt  = 1'bx;
        ma_write_cmplt = 1'bx;
        ma_clr_ite     = 1'bx;
        ma_active      = 1'bx;
      end
    endcase
  end

  always @(posedge clk_dbg_halt or negedge reset_n)
    if (~reset_n)
      ma_state <= MA_STATE_WAIT;
    else if (in_halt)
      ma_state <= nxt_ma_state;
  
  // ------------------------------------------------------
  // APB interface
  // ------------------------------------------------------

  // An APB transaction starts with PSEL going high, and ends when the core asserts PREADY
  assign nxt_apb_dbg_active = gov_pseldbg_dbg_i & ~preadydbg;
  assign nxt_apb_pmu_active = gov_pseldbg_pmu_i & ~preadydbg;

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n) begin
      apb_dbg_active <= 1'b0;
      apb_pmu_active <= 1'b0;
    end else begin
      apb_dbg_active <= nxt_apb_dbg_active;
      apb_pmu_active <= nxt_apb_pmu_active;
    end

  assign nxt_apb_strobe = (apb_dbg_active | apb_pmu_active) & ~apb_strobe & ~preadydbg;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      apb_strobe <= 1'b0;
    else
      apb_strobe <= nxt_apb_strobe;

  // Register inputs on APB interface
  always @(posedge clk_dbg_regs)
    if (nxt_apb_strobe) begin
      pwritedbg_reg  <= gov_pwritedbg_i;
      paddrdbg_reg   <= gov_paddrdbg_i;
      paddrdbg31_reg <= gov_paddrdbg31_i;
      pwdatadbg_reg  <= gov_pwdatadbg_i;
      edlsr_slk_reg  <= gov_edlsr_slk_i;
      pmlsr_slk_reg  <= gov_pmlsr_slk_i;
    end

  // Ready signal generation
  // preadydbg reset to one when the core power is off
  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      preadydbg <= 1'b1;
    else
      preadydbg <= apb_strobe;

  assign apb_dbg_rd_req = apb_dbg_active & apb_strobe & ~pwritedbg_reg;
  assign apb_pmu_rd_req = apb_pmu_active & apb_strobe & ~pwritedbg_reg;

  assign apb_dbg_wr_req = apb_dbg_active & apb_strobe &  pwritedbg_reg;
  assign apb_pmu_wr_req = apb_pmu_active & apb_strobe &  pwritedbg_reg;

  assign dbg_apb_slk    = edlsr_slk_reg & ~paddrdbg31_reg;
  assign pmu_apb_slk    = pmlsr_slk_reg & ~paddrdbg31_reg;

  assign dbg_apb_full_lock = dbg_os_lock_set | dbg_double_lock_status_synced | dbg_apb_slk;
  assign dbg_apb_dbl_lock  = dbg_double_lock_status_synced | dbg_apb_slk;

  // Signals indicating whether a read with side-effects has occured
  assign apb_rd_se_dtrtx    = (paddrdbg_reg[11:2] == `CA53_DBG_DTRTX)    & apb_dbg_rd_req & ~dbg_apb_full_lock & ~edscr_err;
  assign apb_rd_se_edprsr   = (paddrdbg_reg[11:2] == `CA53_DBG_EDPRSR)   & apb_dbg_rd_req & ~dbg_apb_dbl_lock;
  assign apb_rd_se_edpcsrlo = (paddrdbg_reg[11:2] == `CA53_DBG_EDPCSRlo) & apb_dbg_rd_req & ~dbg_apb_dbl_lock;

  // Read enables
  assign apb_rd_edesr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDESR)      & apb_dbg_rd_req;
  assign apb_rd_dtrrx     = (paddrdbg_reg[11:2] == `CA53_DBG_DTRRX)      & apb_dbg_rd_req;
  assign apb_rd_edscr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDSCR)      & apb_dbg_rd_req;
  assign apb_rd_dtrtx     = (paddrdbg_reg[11:2] == `CA53_DBG_DTRTX)      & apb_dbg_rd_req;
  assign apb_rd_edeccr    = (paddrdbg_reg[11:2] == `CA53_DBG_EDECCR)     & apb_dbg_rd_req;
  assign apb_rd_edpcsrlo  = (paddrdbg_reg[11:2] == `CA53_DBG_EDPCSRlo)   & apb_dbg_rd_req;
  assign apb_rd_edpcsrhi  = (paddrdbg_reg[11:2] == `CA53_DBG_EDPCSRhi)   & apb_dbg_rd_req;
  assign apb_rd_edprcr    = (paddrdbg_reg[11:2] == `CA53_DBG_EDPRCR)     & apb_dbg_rd_req;
  assign apb_rd_edprsr    = (paddrdbg_reg[11:2] == `CA53_DBG_EDPRSR)     & apb_dbg_rd_req;
  assign apb_rd_claimset  = (paddrdbg_reg[11:2] == `CA53_DBG_CLAIMSET)   & apb_dbg_rd_req;
  assign apb_rd_claimclr  = (paddrdbg_reg[11:2] == `CA53_DBG_CLAIMCLR)   & apb_dbg_rd_req;
  assign apb_rd_edwar_lo  = (paddrdbg_reg[11:2] == `CA53_DBG_EDWAR_LO)   & apb_dbg_rd_req;
  assign apb_rd_edwar_hi  = (paddrdbg_reg[11:2] == `CA53_DBG_EDWAR_HI)   & apb_dbg_rd_req;

  assign apb_rd_tlb       =                                                apb_dbg_rd_req;
  assign apb_rd_pmu       =                                                apb_pmu_rd_req;

  // Write enables
  assign apb_wr_edesr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDESR)      & apb_dbg_wr_req & ~dbg_apb_dbl_lock;
  assign apb_wr_dtrrx     = (paddrdbg_reg[11:2] == `CA53_DBG_DTRRX)      & apb_dbg_wr_req & ~dbg_apb_full_lock & ~edscr_err;
  assign apb_wr_editr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDITR)      & apb_dbg_wr_req & ~dbg_apb_full_lock & ~edscr_err;
  assign apb_wr_edscr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDSCR)      & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_dtrtx     = (paddrdbg_reg[11:2] == `CA53_DBG_DTRTX)      & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_edrcr     = (paddrdbg_reg[11:2] == `CA53_DBG_EDRCR)      & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_edeccr    = (paddrdbg_reg[11:2] == `CA53_DBG_EDECCR)     & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_oslar     = (paddrdbg_reg[11:2] == `CA53_DBG_OSLAR)      & apb_dbg_wr_req & ~dbg_apb_dbl_lock;
  assign apb_wr_edprcr    = (paddrdbg_reg[11:2] == `CA53_DBG_EDPRCR)     & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_claimset  = (paddrdbg_reg[11:2] == `CA53_DBG_CLAIMSET)   & apb_dbg_wr_req & ~dbg_apb_full_lock;
  assign apb_wr_claimclr  = (paddrdbg_reg[11:2] == `CA53_DBG_CLAIMCLR)   & apb_dbg_wr_req & ~dbg_apb_full_lock;

  // Breakpoint & Watchpoint TLB write enable
  assign apb_dbgbwr       = (paddrdbg_reg[2] == 1'b0) | (paddrdbg_reg[3] == 1'b0);
  assign apb_wr_dbgbvr    = (paddrdbg_reg[11:8] == `CA53_DBG_BVR)        & apb_dbg_wr_req & ~dbg_apb_full_lock & apb_dbgbwr;
  assign apb_wr_dbgwvr    = (paddrdbg_reg[11:8] == `CA53_DBG_WVR)        & apb_dbg_wr_req & ~dbg_apb_full_lock & apb_dbgbwr;

  // Generate PSLVERR from Section 15.6.5 External debug interface register access permissions summary
  assign valid_apb_dbg  = apb_dbg_active & ~set_edprsr_sdad &
                          ((~dbg_os_lock_set & ~dbg_double_lock_status_synced)                                            |
                           ((paddrdbg_reg[11:2] == `CA53_DBG_EDESR)  & dbg_os_lock_set & ~dbg_double_lock_status_synced)  |
                           ((paddrdbg_reg[11:2] == `CA53_DBG_OSLAR)  & dbg_os_lock_set & ~dbg_double_lock_status_synced)  |
                            (paddrdbg_reg[11:2] == `CA53_DBG_EDPRCR)                                                      |
                            (paddrdbg_reg[11:2] == `CA53_DBG_EDPRSR));

  assign valid_apb_pmu  = apb_pmu_active & ~dbg_os_lock_set & ~dbg_double_lock_status_synced & (~edprsr_epmad | ~apb_pmu_access_i);

  assign nxt_pslverrdbg = ~(valid_apb_dbg | valid_apb_pmu);

  // pslverrdbg reset to one when the core power is off
  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      pslverrdbg <= 1'b1;
    else if (apb_strobe)
      pslverrdbg <= nxt_pslverrdbg;

  assign nxt_prdatadbg = ({32{apb_rd_edesr}}    & edesr_rd)         |
                         ({32{apb_rd_dtrrx}}    & dtrrx)            |
                         ({32{apb_rd_edscr}}    & edscr_rd)         |
                         ({32{apb_rd_dtrtx}}    & dtrtx)            |
                         ({32{apb_rd_edeccr}}   & edeccr_rd)        |
                         ({32{apb_rd_edpcsrlo}} & pcsr_lo_rd)       |
                         ({32{apb_rd_edpcsrhi}} & pcsr_hi_rd)       |
                         ({32{apb_rd_edprcr}}   & edprcr_rd)        |
                         ({32{apb_rd_edprsr}}   & edprsr_rd)        |
                         ({32{apb_rd_claimset}} & claimset_rd)      |
                         ({32{apb_rd_claimclr}} & claimclr_rd)      |
                         ({32{apb_rd_edwar_lo}} & edwar_rd[31:0])   |
                         ({32{apb_rd_edwar_hi}} & edwar_rd[63:32])  |
                         // Debug data from TLB
                         ({32{apb_rd_tlb}}      & tlb_dbg_rdata_i)  |
                         // PMU data from PMU block 
                         ({32{apb_rd_pmu}}      & pmu_apb_rdata_i);

  assign prdatadbg_en = apb_strobe & ~pwritedbg_reg;

  always @(posedge clk_dbg_regs)
    if (prdatadbg_en)
      prdatadbg <= nxt_prdatadbg;

  assign dpu_prdatadbg_o  = prdatadbg;
  assign dpu_preadydbg_o  = preadydbg;
  assign dpu_pslverrdbg_o = pslverrdbg;

  // Output registered APB signals to TLB and CP
  assign dpu_dbg_wr_o     = (apb_wr_dbgbvr | apb_wr_dbgwvr) & ~(dbg_apb_slk | edprsr_edad);
  assign apb_addr_o       = paddrdbg_reg;
  assign apb_wdata_o      = pwdatadbg_reg;
  assign pmu_apb_wr_o     = apb_pmu_wr_req & ~pmu_apb_slk & ~edprsr_epmad;
  assign nxt_pmu_apb_wr_o = apb_pmu_active;

  // ------------------------------------------------------
  // CP14 bus interface
  // ------------------------------------------------------

  assign dbg_cp_rd_data_o = ({64{cp14_rd_drar}}         & drar_rd)           |
                            ({64{cp14_rd_dtr_el0}}      & {dtrtx, dtrrx})    |
               ({{32{1'b0}},({32{cp14_rd_didr}}         & didr_rd)           |
                            ({32{cp14_rd_dscr_int}}     & dscr_int)          |
                            ({32{cp14_rd_mdccsr_el0}}   & mdccsr_el0)        |
                            ({32{cp14_rd_dscr_flags}}   & dscr_int)          |
                            ({32{cp14_rd_dtrrx_int}}    & dtrrx)             |
                            ({32{cp14_rd_dtrrx_ext}}    & dtrrx)             |
                            ({32{cp14_rd_dscr_ext}}     & dscr_ext)          |
                            ({32{cp14_rd_mdscr_el1}}    & mdscr_el1)         |
                            ({32{cp14_rd_dtrtx_ext}}    & dtrtx)             |
                            ({32{cp14_rd_oseccr_el1}}   & oseccr_rd)         |
                            ({32{cp14_rd_osdlr}}        & osdlr_rd)          |
                            ({32{cp14_rd_oslsr}}        & oslsr_rd)          |
                            ({32{cp14_rd_prcr}}         & edprcr_rd)         |
                            ({32{cp14_rd_claimset}}     & claimset_rd)       |
                            ({32{cp14_rd_claimclr}}     & claimclr_rd)       |
                            ({32{cp14_rd_authstatus}}   & dbg_authstatus_rd) |
                            ({32{cp14_rd_devid}}        & dbg_devid_rd)      |
                            ({32{cp14_rd_devid1}}       & dbg_devid1_rd)     |
                            ({32{cp14_rd_mdccint_el1}}  & dbg_mdccint)       |
                            ({32{cp14_rd_dspsr}}        & dspsr_rd)});

  // Write enables
  assign cp14_wr_dtrtx_int   = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_DTR_INT});    // DBGDTRTX_EL0
  assign cp14_wr_prcr        = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_PRCR});
  assign cp14_wr_dtrrx_ext   = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_DTRRX_EXT});  // OSDTRRX_EL1
  assign cp14_wr_dtr         = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_DTR_EL0});    // DBGDTR_EL0
  assign cp14_wr_dtrtx_ext   = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_DTRTX_EXT});  // OSDTRTX_EL1
  assign cp14_wr_dscr_ext    = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_DSCR_EXT});
  assign cp14_wr_oseccr_el1  = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_OSECCR_EL1}) & dbg_os_lock_synced;
  assign cp14_wr_oslar       = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_OSLAR});
  assign cp14_wr_osdlr       = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_OSDLR});
  assign cp14_wr_claimset    = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_CLAIMSET});
  assign cp14_wr_claimclr    = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_CLAIMCLR});
  assign cp14_wr_mdccint     = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_MDCCINT_EL1});
  assign cp14_wr_mdscr_el1   = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP14_DBG_MDSCR_EL1});
  assign cp14_wr_dspsr_o     = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CP15_DBG_DSPSR_EL0});

  // Read enables
  assign cp14_rd_drar        = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DRAR};
  assign cp14_rd_dtr_el0     = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DTR_EL0};                      // DBGDTR_EL0
  assign cp14_rd_didr        = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DIDR};
  assign cp14_rd_dscr_int    = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DSCR_INT}    & ~aarch64_state_i;
  assign cp14_rd_mdccsr_el0  = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DSCR_INT}    &  aarch64_state_i;
  assign cp14_rd_dscr_flags  = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DSCR_FLAGS};
  assign cp14_rd_dtrrx_int   = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DTR_INT};                      // DBGDTRRX_EL0
  assign cp14_rd_dtrrx_ext   = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DTRRX_EXT};                    // OSDTRRX_EL1
  assign cp14_rd_dscr_ext    = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DSCR_EXT};
  assign cp14_rd_oseccr_el1  = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_OSECCR_EL1}  & dbg_os_lock_synced;
  assign cp14_rd_mdscr_el1   = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_MDSCR_EL1};
  assign cp14_rd_dtrtx_ext   = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DTRTX_EXT};                    // OSDTRTX_EL1
  assign cp14_rd_osdlr       = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_OSDLR};
  assign cp14_rd_oslsr       = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_OSLSR};
  assign cp14_rd_prcr        = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_PRCR};
  assign cp14_rd_claimset    = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_CLAIMSET};
  assign cp14_rd_claimclr    = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_CLAIMCLR};
  assign cp14_rd_authstatus  = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_AUTHSTATUS};
  assign cp14_rd_devid       = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DEVID};
  assign cp14_rd_devid1      = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DEVID1};
  assign cp14_rd_mdccint_el1 = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_MDCCINT_EL1};
  assign cp14_rd_dspsr       = raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP15_DBG_DSPSR_EL0};

  // ------------------------------------------------------
  // LDC/STC interface
  // ------------------------------------------------------

  // Data bus for data to be stored from rDTR.
  assign dbg_dtrrx_data_o = dtrrx;

  // - Ignore first half of cross 64 in case it has an abort which will not be reported until second half
  assign ldc_wr_dtrtx_int = ldc_stc_wr_i & ~ls_store_wr_i & cc_pass_instr0_wr_i & ~quash_wr_i & ~stall_wr_i & ~first_x64_wr_i;
  assign stc_rd_dtrrx_int = ldc_stc_wr_i &  ls_store_wr_i & cc_pass_instr0_wr_i & ~quash_wr_i & ~stall_wr_i;

  // ------------------------------------------------------
  // MRC flag update
  // ------------------------------------------------------

  assign cpsr_flag_update_nzcv_o[3:0]  = {1'b0, dscr_dtrrx_full, dscr_dtrtx_full, 1'b0};
  assign cpsr_flag_update_cp_dscr_wr_o = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CP14_DBG_DSCR_FLAGS});

  // ------------------------------------------------------
  // DBGDIDR: Debug ID register
  // ------------------------------------------------------

  assign didr_rd = `CA53_DIDR_READ_VALUE;

  // ------------------------------------------------------
  // DBGDRAR: Debug ROM Address Register
  // ------------------------------------------------------
  // Notes Arch Spec shows romaddr can be 47:12 but only 39:12 are required to support CA53 max address range

  always @(posedge clk_dbg_halt)
    if (load_initial_cold) begin
      dbgromaddrv_reg <= gov_dbgromaddrv_i;
      dbgromaddr_reg  <= gov_dbgromaddr_i;
    end

  assign drar_rd  = {{24{1'b0}}, dbgromaddr_reg[39:12], {10{1'b0}}, {2{dbgromaddrv_reg}}};

  // ------------------------------------------------------
  // MDCCSR_EL0 / DBGDSCRint: Internal Debug Status and Control Register
  // MDSCR_EL0  / DBGDSCRext: External Debug Status and Control Register
  // ------------------------------------------------------
  // dbg_trigger:  internal version of the DBGTRIGGER primary output.
  //               Indicates the next stage of entering debug state where
  //               the DPU has flushed the pipeline (i.e., has taken the
  //               halt request) but the memory system has not been
  //               synchronized yet.
  // dscr_halted:  The v7 spec requires that InstrCompl is set when debug
  //               state is entered so when the halt request goes to the
  //               IFU we must wait until the pipeline has emptied.
  // ------------------------------------------------------
  // Debug State Machine
  // ------------------------------------------------------

  assign ifu_drain_state_en = (dcu_dbg_dsb_ack_i & ~flush_wr_i) | edrcr_cbrrq;

  always @* begin
    nxt_dbg_state     = dbg_state;
    dbg_trigger       = 1'b0;
    dscr_halted       = 1'b0;
    nxt_in_halt       = 1'b0;
    dpu_dbg_dsb_req_o = 1'b0;
    dbg_restarting    = 1'b0;
    dbg_starting      = 1'b0;

    case (dbg_state)
      DBG_STATE_RUN: begin

        if (dbg_event_halt_wr_i) begin
          nxt_dbg_state = DBG_STATE_DCU_DRAIN;
          nxt_in_halt   = 1'b1;
        end
      end

      DBG_STATE_DCU_DRAIN: begin
        dbg_trigger       = 1'b1;
        nxt_in_halt       = 1'b1;
        dpu_dbg_dsb_req_o = ~flush_wr_i;
        dbg_starting      = 1'b1;

        if (ifu_drain_state_en)
          nxt_dbg_state = DBG_STATE_IFU_DRAIN;
      end

      DBG_STATE_IFU_DRAIN: begin
        dbg_trigger       = 1'b1;
        nxt_in_halt       = 1'b1;
        dbg_starting      = 1'b1;

        if (ifu_dbg_ready_i & forceop_cmpt)
          nxt_dbg_state   = DBG_STATE_HALTED;
      end

      DBG_STATE_HALTED: begin
        dbg_trigger       = 1'b1;
        dscr_halted       = 1'b1;
        nxt_in_halt       = 1'b1;

        if (dbgrestart_reg) begin
          if (edscr_ite & ~load_editr & ~ma_active)
            nxt_dbg_state   = DBG_STATE_RESTARTING;
          else
            // Hold the restart request if exception occuring
            nxt_dbg_state   = DBG_STATE_RESTART_HELD;
        end
      end

      DBG_STATE_RESTART_HELD: begin
        dbg_trigger       = 1'b1;
        dscr_halted       = 1'b1;
        nxt_in_halt       = 1'b1;

        if (edscr_ite & ~load_editr & ~ma_active)
          nxt_dbg_state   = DBG_STATE_RESTARTING;
      end

      DBG_STATE_RESTARTING: begin
        dbg_trigger       = 1'b1;
        dscr_halted       = 1'b1;
        nxt_in_halt       = ~expt_dbgexit_i;
        dbg_restarting    = 1'b1;

        if (expt_dbgexit_i)
          nxt_dbg_state   = DBG_STATE_RUN;
      end

      default: begin
        dbg_trigger       = 1'bx;
        dscr_halted       = 1'bx;
        nxt_in_halt       = 1'bx;
        dpu_dbg_dsb_req_o = 1'bx;
        dbg_restarting    = 1'bx;
        dbg_starting      = 1'bx;
        nxt_dbg_state     = {3{1'bx}};
      end
    endcase
  end

  assign dbg_restart_qual = dbg_restarting & ~dpu_fe_valid_ret_i & ~no_interrupt_wr_i;

  assign nxt_forceop_cmpt = (forceop_valid_wr_i & dbg_starting) | (forceop_cmpt & ~dbg_restarting);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      forceop_cmpt <= 1'b0;
    else
      forceop_cmpt <= nxt_forceop_cmpt;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dbg_state <= DBG_STATE_RUN;
      in_halt   <= 1'b0;
    end
    else begin
      dbg_state <= nxt_dbg_state;
      in_halt   <= nxt_in_halt;
    end

  assign debug_entry = ~dscr_halted & (nxt_dbg_state == DBG_STATE_HALTED);
  assign left_debug  = (dbg_state == DBG_STATE_RESTARTING) & expt_dbgexit_i;

  // These top level signals are a direct reflection of the dscr registers
  always @(posedge clk_dbg_halt or negedge po_reset_n)
    if (~po_reset_n)
      dpu_dbgack_o <= 1'b0;
    else
      dpu_dbgack_o <= dscr_halted;

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      dpu_dbgtrigger_o <= 1'b0;
    else
      dpu_dbgtrigger_o <= dbg_trigger;

  // EDSCR[5:0] - STATUS - reason for entering debug state
  assign edscr_status =   dbg_restarting ? 6'b0000_01   // Processor restarting (exiting debug)
                        : ~dscr_halted   ? 6'b0000_10   // Processor in Non-debug state
                        :    {dbg_entry_status, 2'b11}; // Processor in debug state

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      dbg_entry_status <= 4'b0000;
    else if (dbg_event_halt_wr_i)
      dbg_entry_status <= expt_status_moe_data_wr_i;

  // MDSCR_EL1[0] - Single Step
  assign load_mdscr_el1_ss = cp14_wr_dscr_ext | cp14_wr_mdscr_el1;

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n)
      mdscr_el1_ss <= 1'b0;
    else if (load_mdscr_el1_ss)
      mdscr_el1_ss <= mcr_data_wr_i[0];

  // DBGDSCR[5:2] - MOE - Method of entry register
  assign nxt_dscr_moe  = (cp14_wr_dscr_ext | cp14_wr_mdscr_el1) ? mcr_data_wr_i[5:2] : expt_status_moe_data_wr_i;
  assign load_dscr_moe = (dbg_event_i & ~aarch64_state_i) | cp14_wr_dscr_ext | cp14_wr_mdscr_el1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dscr_moe <= {4{1'b0}};
    else if (load_dscr_moe)
      dscr_moe <= nxt_dscr_moe;

  // EDSCR.ERR[6] - Cumulative error flag
  // Set to 1 following exceptions in Debug state and on any signaled overrun or underrun on the DTR or EDITR.
  assign nxt_edscr_err  = (set_edscr_rxo | set_edscr_txu | set_edscr_ito | expt_in_halt_i) ?  1'b1 : edrcr_cse ? 1'b0 : mcr_data_wr_i[6];
  assign load_edscr_err = ((cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) & dbg_os_lock_synced) |
                          set_edscr_rxo | set_edscr_txu | set_edscr_ito | edrcr_cse | expt_in_halt_i;

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      edscr_err <= 1'b0;
    else if (load_edscr_err)
      edscr_err <= nxt_edscr_err;

  // EDSCR[9:8] EL - Exception level
  assign edscr_el = dscr_halted ? dpu_exception_level_i : 2'b00;

  // Gated register used for bits 12:13 & 15 & 21:23
  assign dscr_load_en =  apb_wr_edscr | cp14_wr_dscr_ext | cp14_wr_mdscr_el1;

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n) begin
      dscr_udcc_dis <= 1'b0;
      mdscr_el1_kde <= 1'b0;
      dscr_mdbg_en  <= 1'b0;
    end
    else if (dscr_load_en) begin
      dscr_udcc_dis <= nxt_dscr_udcc_dis;
      mdscr_el1_kde <= nxt_mdscr_el1_kde;
      dscr_mdbg_en  <= nxt_dscr_mdbg_en;
    end

  // Gated register used for bits 14 & 21:23
  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n) begin
      edscr_hde    <= 1'b0;
      edscr_tda    <= 1'b0;
      edscr_intdis <= 2'b00;
    end
    else if (dscr_load_en) begin
      edscr_hde    <= nxt_edscr_hde;
      edscr_tda    <= nxt_edscr_tda;
      edscr_intdis <= nxt_edscr_intdis;
    end

  // DSCR[12] - UDCC disable (TDCC)
  assign nxt_dscr_udcc_dis = (cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) ? mcr_data_wr_i[12] : dscr_udcc_dis;

  // MDSCR_EL1[13] KDE - Kernal debug mode enable
  assign nxt_mdscr_el1_kde = (cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) ? mcr_data_wr_i[13] : mdscr_el1_kde;

  // EDSCR[13:10] RW - Exception level register-width status
  assign edscr_rw[0] = dscr_halted ? ((dpu_exception_level_i != 2'b00) ? aarch64_at_el_i[1] : aarch64_state_i) : 1'b1;
  assign edscr_rw[1] = dscr_halted ? aarch64_at_el_i[1]                                                        : 1'b1;
  assign edscr_rw[2] = dscr_halted ? (ns_scr_i ? aarch64_at_el_i[2] : aarch64_at_el_i[1])                      : 1'b1;
  assign edscr_rw[3] = dscr_halted ? aarch64_at_el_i[3]                                                        : 1'b1;

  // DSCR[14] - Hardware debug enable - EDSCR.HDE
  assign nxt_edscr_hde   = apb_wr_edscr                                                  ? pwdatadbg_reg[14] : 
                           ((cp14_wr_dscr_ext | cp14_wr_mdscr_el1) & dbg_os_lock_synced) ? mcr_data_wr_i[14] :
                                                                                           edscr_hde;

  // DSCR[15] - Monitor debug enable - MDSCR_EL1.MDE
  assign nxt_dscr_mdbg_en = (cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) ? mcr_data_wr_i[15] : dscr_mdbg_en;

  // EDSCR.SDD [16] - Secure Debug Disabled
  assign nxt_edscr_sdd  = (dscr_halted & ~expt_dbgexit_i) ? edscr_sdd : // Must not change when halted. Not waiting for a CSO event.
                          (debug_entry & ~ns_state_i)     ? 1'b0      : 
                                                            ~(dbgen_synced & spiden_synced);

  always @(posedge clk)
    edscr_sdd <= nxt_edscr_sdd;

  // SPIDdis [16] - Secure privileged AArch32 invasive debug (self-hosted) disabled status bit
  assign spid_dis = ~(cp_mdcr_el3_spd32_i[1] ? cp_mdcr_el3_spd32_i[0] :
                                             (dbgen_synced & spiden_synced));

  // SPNIDdis [17] - Secure privileged non-invasive debug (profiling) disabled status bit
  assign spnid_dis = ~(cp_mdcr_el3_spme_i | ((dbgen_synced | niden_synced) & (spiden_synced | spniden_synced)));

  // EDSCR.NS [18] - Non-Secure
  assign edscr_ns = (dscr_halted & ~expt_dbgexit_i) ? ns_state_i : 1'b0;

  // EDSCR.MA [20] - Memory access mode
  assign nxt_edscr_ma   = apb_wr_edscr ? pwdatadbg_reg[20] :
                          debug_entry  ? 1'b0              : edscr_ma;

  always @(posedge clk_dbg_halt or negedge po_reset_n)
    if (~po_reset_n)
      edscr_ma <= 1'b0;
    else
      edscr_ma <= nxt_edscr_ma;
      
  assign edscr_ma_qual   = edscr_ma & ~ma_wait & ~dbg_restarting & dscr_halted;
  assign edscr_ma_extend = (edscr_ma & ~dbg_restarting & dscr_halted) | ma_active;

  // EDSCR.TDA [21] - Trap debug registers accesses
  assign nxt_edscr_tda = apb_wr_edscr                                                  ? pwdatadbg_reg[21] :
                         ((cp14_wr_dscr_ext | cp14_wr_mdscr_el1) & dbg_os_lock_synced) ? mcr_data_wr_i[21] :
                                                                                         edscr_tda;

  // EDSCR.INTdis [23:22] - Interrupt disable
  assign nxt_edscr_intdis   = apb_wr_edscr                                                  ? pwdatadbg_reg[23:22] :
                              ((cp14_wr_dscr_ext | cp14_wr_mdscr_el1) & dbg_os_lock_synced) ? mcr_data_wr_i[23:22] :
                                                                                              edscr_intdis;

  // EDSCR.ITE [24] - ITR empty - Processor is ready to accept an instruction via the EDITR
  assign nxt_edscr_ite = debug_entry                                                                 |
                         (dpu_instr_retire & dscr_halted & ~expt_fault_reg_sel_wr_i & ~ma_active)    |
                         (end_expt_in_halt_i &                                        ~ma_active)    |
                         (edscr_ite & dscr_halted & ~dbg_restarting & ~(load_editr | ma_clr_ite))    |
                         (ma_read_cmplt  & ~dbg_restarting)                                          |
                         (ma_write_cmplt & ~dbg_restarting)                                          |
                         (ma_expt_cmplt  & ~dbg_restarting);

  always @(posedge clk_dbg_halt)
    edscr_ite <= nxt_edscr_ite;

  // EDSCR.PipeAdv [25] - Sticky Pipeline Advance flag
  assign dpu_instr_retire = pre_valid_instrs_wr_i & end_instr_wr_i & ~(stall_wr_i & ~flush_wr_i);
  assign nxt_edscr_pipeadv = ~edrcr_cspa & (edscr_pipeadv | dpu_instr_retire);

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      edscr_pipeadv <= 1'b0;
    else
      edscr_pipeadv <= nxt_edscr_pipeadv;

  // EDSCR.TXU [26] - TX underrun flag
  // Sticky status flag set if the register is accessed via the external debug interface when the corresponding ready flag is not in the "ready" state

  assign set_edscr_txu   = apb_rd_se_dtrtx & ((~dscr_dtrtx_full & ~dbg_restarting) | (edscr_ma_extend & ~edscr_ite));
  assign nxt_edscr_txu   = ((cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) & dbg_os_lock_synced) ? mcr_data_wr_i[26] : edrcr_cse ? 1'b0 : (edscr_txu | set_edscr_txu);

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      edscr_txu <= 1'b0;
    else
      edscr_txu <= nxt_edscr_txu;

  // EDSCR.RXO [27] - RX overrun flag
  // Sticky status flag set if the register is accessed via the external debug interface when the corresponding ready flag is not in the "ready" state

  assign set_edscr_rxo   = apb_wr_dtrrx & ((dscr_dtrrx_full & ~dbg_restarting) | (edscr_ma_extend & ~edscr_ite));
  assign nxt_edscr_rxo   = ((cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) & dbg_os_lock_synced) ? mcr_data_wr_i[27] : edrcr_cse ? 1'b0 : (edscr_rxo | set_edscr_rxo);

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      edscr_rxo <= 1'b0;
    else
      edscr_rxo <= nxt_edscr_rxo;

  // EDSCR.ITO [28] - ITR Overrun Flag
  // Write EDITR && Halted() && (EDSCR.ITE == '0' || EDSCR.MA == '1')
  // EDSCR.{ITE, ITO, ERR} are unchanged by a memory-mapped write to EDITR, which is ignored.
  assign clr_edscr_ito = edrcr_cse | ~dscr_halted | expt_dbgexit_i;
  assign set_edscr_ito = apb_wr_editr & dscr_halted & ~dbg_restarting & (~edscr_ite | edscr_ma_extend);
  assign nxt_edscr_ito = (edscr_ito | set_edscr_ito) & ~clr_edscr_ito;

  always @(posedge clk)
    edscr_ito <= nxt_edscr_ito;

  // DBGDSCR[30:29] - DTR RXfull and TXfull flags
  assign nxt_dscr_dtrrx_full = ((cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) & dbg_os_lock_synced) ? mcr_data_wr_i[30]
                                 : (load_dtrrx_flag | (dscr_dtrrx_full & ~((cp14_rd_dtrrx_int & cp_valid_wr_i) |
                                                                           (cp14_rd_dtr_el0   & cp_valid_wr_i) |
                                                                            stc_rd_dtrrx_int)));

  assign nxt_dscr_dtrtx_full = ((cp14_wr_mdscr_el1 | cp14_wr_dscr_ext) & dbg_os_lock_synced) ? mcr_data_wr_i[29]
                                 : (load_dtrtx_flag | ldc_wr_dtrtx_int | ma_read_cmplt |
                                    (dscr_dtrtx_full & (dbg_restarting | ~(apb_rd_se_dtrtx & (~edscr_ma_extend | edscr_ma_extend & edscr_ite)))));  
                                     
  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n) begin
      dscr_dtrrx_full <= 1'b0;
      dscr_dtrtx_full <= 1'b0;
    end
    else begin
      dscr_dtrrx_full <= nxt_dscr_dtrrx_full;
      dscr_dtrtx_full <= nxt_dscr_dtrtx_full;
    end

  assign dpu_commrx_o   =  dscr_dtrrx_full;
  assign dpu_commtx_o   = ~dscr_dtrtx_full;
  assign dpu_ncommirq_o = ~((dscr_dtrrx_full & dbg_cint_rx) | (~dscr_dtrtx_full & dbg_cint_tx));

  // DBGDSCR bits used in DPU
  assign dbgdscr_halted_o     = dscr_halted;
  assign dbg_hlt_en_o         = edscr_hde_synced & dbg_halting_allowed_synced;
  assign dbg_bkpt_wpt_en_o    = edscr_hde_synced & dbg_halting_allowed_synced & ~dbg_os_lock_synced;

  // DBGDSCR internal read data
  assign dscr_int   = {1'b0,                // 31    RES0
                       dscr_dtrrx_full,     // 30    RXfull
                       dscr_dtrtx_full,     // 29    TXfull
                       1'b0,                // 28    RES0
                       4'b0000,             // 27:24 RES0
                       4'b0000,             // 23:20 RES0
                       1'b0,                // 19    RES0
                       ns_state_i,          // 18    NS
                       spnid_dis,           // 17    SPNIDdis
                       spid_dis,            // 16    SPIDdis
                       dscr_mdbg_en,        // 15    MDBGen
                       2'b00,               // 14:13 RES0
                       dscr_udcc_dis,       // 12    UDCCdis
                       4'b0000,             // 11:8  RES0
                       2'b00,               //  7:6  RES0
                       dscr_moe,            //  5:2  MOE
                       2'b00};              //  1:0  RES0

  // MDCCSR_EL0 read data
  assign mdccsr_el0 = {1'b0,                // 31    RES0
                       dscr_dtrrx_full,     // 30    RXfull
                       dscr_dtrtx_full,     // 29    TXfull
                       1'b0,                // 28    RES0
                       4'b0000,             // 27:24 RES0
                       4'b0000,             // 23:20 RES0
                       1'b0,                // 19    RES0
                       1'b0,                // 18    RES0 (NS)
                       1'b0,                // 17    RES0 (SPNIDdis)
                       1'b0,                // 16    RES0 (SPIDdis)
                       1'b0,                // 15    RES0 (MDBGen)
                       2'b00,               // 14:13 RES0
                       1'b0,                // 12    RES0 (UDCCdis)
                       4'b0000,             // 11:8  RES0
                       2'b00,               //  7:6  RES0
                       4'b0000,             //  5:2  RES0 (MOE)
                       2'b00};              //  1:0  RES0

  // MDSCR_EL1
  assign mdscr_el1  = {1'b0,                // 31    RES0
                       dscr_dtrrx_full,     // 30    RXfull
                       dscr_dtrtx_full,     // 29    TXfull
                       1'b0,                // 28    RES0
                       edscr_rxo,           // 27    RXO
                       edscr_txu,           // 26    TXU
                       {2{1'b0}},           // 25:24 RES0
                       edscr_intdis,        // 23:22 INTdis
                       edscr_tda,           // 21    TDA
                       1'b0,                // 20    RES0
                       {4{1'b0}},           // 19:16 RES0
                       dscr_mdbg_en,        // 15    MDE
                       edscr_hde,           // 14    HDE
                       mdscr_el1_kde,       // 13    KDE
                       dscr_udcc_dis,       // 12    UDCCdis (TDCC)
                       {4{1'b0}},           // 11:8  RES0
                       1'b0,                //  7    RES0
                       edscr_err,           //  6    ERR
                       dscr_moe,            //  5:2  MOE
                       1'b0,                //  1    RES0
                       mdscr_el1_ss};       //  0    SS

  // DBGDSCRext
  assign dscr_ext   = {1'b0,                // 31    RES0
                       dscr_dtrrx_full,     // 30    RXfull
                       dscr_dtrtx_full,     // 29    TXfull
                       1'b0,                // 28    RES0
                       edscr_rxo,           // 27    RXO
                       edscr_txu,           // 26    TXU
                       {2{1'b0}},           // 25:24 RES0
                       edscr_intdis,        // 23:22 INTdis
                       edscr_tda,           // 21    TDA
                       1'b0,                // 20    RES0
                       1'b0,                // 19    RES0
                       ns_state_i,          // 18    NS
                       spnid_dis,           // 17    SPNIDdis
                       spid_dis,            // 16    SPIDdis
                       dscr_mdbg_en,        // 15    MDBGen
                       edscr_hde,           // 14    HDE
                       mdscr_el1_kde,       // 13    KDE
                       dscr_udcc_dis,       // 12    UDCCdis (TDCC)
                       {4{1'b0}},           // 11:8  RES0
                       1'b0,                //  7    RES0
                       edscr_err,           //  6    ERR
                       dscr_moe,            //  5:2  MOE
                       1'b0,                //  1    RES0
                       mdscr_el1_ss};       //  0    SS

  // EDSCR
  assign edscr_rd   = {1'b0,                // 31    RES0
                       dscr_dtrrx_full,     // 30    RXfull
                       dscr_dtrtx_full,     // 29    TXfull
                       edscr_ito,           // 28    ITO
                       edscr_rxo,           // 27    RXO
                       edscr_txu,           // 26    TXU
                       edscr_pipeadv,       // 25    PipeAdv
                       edscr_ite,           // 24    ITE
                       edscr_intdis,        // 23:22 INTdis
                       edscr_tda,           // 21    TDA
                       edscr_ma,            // 20    MA
                       1'b0,                // 19    RES0
                       edscr_ns,            // 18    NS
                       1'b0,                // 17    RES0
                       edscr_sdd,           // 16    SDD
                       1'b0,                // 15    RES0
                       edscr_hde,           // 14    HDE
                       edscr_rw,            // 13:10 RW
                       edscr_el,            //  9:8  EL
                       expt_serr_pending_i, //  7    A
                       edscr_err,           //  6    ERR
                       edscr_status};       //  5:0  STATUS

  // To TLB
  // Software breakpoint and watchpoint events are enabled
  assign dpu_dbg_tlb_sw_bkpt_wpt_en_us = debug_enabled_from_el_us[dpu_exception_level_i] &
                                         (~(dpu_exception_level_i == exception_level_debug) | ~cpsr_dbit_ret_i) &
                                         dscr_mdbg_en & ~in_halt;

  // Hardware (halting) breakpoint and watchpoint events are enabled
  assign dpu_dbg_tlb_hw_bkpt_wpt_en_us = edscr_hde & dbg_halting_allowed_us & ~dbg_os_lock_set;


  assign exception_level_debug = aarch64_at_el_i[3] ? ((ns_scr_i & hdcr_tde_i) ? `CA53_EL2 :
                                                                                 `CA53_EL1)  :
                                 ~ns_state_i        ? `CA53_EL3                              :
                                 hdcr_tde_i         ? `CA53_EL2                              :
                                                      `CA53_EL1;

  // Calculate if software debug exceptions are enabled from each EL
  // Based on tables 13 and 14 in the v8 Debug specification
  // NOTE: debug_enabled_from_el_us[2] does not factor in PSTATE.D
  // NOTE: debug_enabled_from_el_us[1], AArch64 - does not factor in PSTATE.D
  
  assign aarch32_secure_debug_auth = cp_mdcr_el3_spd32_i[1] ? cp_mdcr_el3_spd32_i[0] : (dbgen_reg & spiden_reg);
  
  always @*
    case ({(dbg_os_lock_set | dbg_double_lock_status_us), aarch64_at_el_i[3]})
      2'b10,
      2'b11:   debug_enabled_from_el_us[3] = 1'b0;
      2'b00:   debug_enabled_from_el_us[3] = aarch32_secure_debug_auth;
      2'b01:   debug_enabled_from_el_us[3] = 1'b0;
      default: debug_enabled_from_el_us[3] = 1'bx;
    endcase

  always @*
    case ({(dbg_os_lock_set | dbg_double_lock_status_us), aarch64_at_el_i[2]})
      2'b10,
      2'b11:  debug_enabled_from_el_us[2] = 1'b0;
      2'b00:  debug_enabled_from_el_us[2] = 1'b0;
      2'b01:  debug_enabled_from_el_us[2] = hdcr_tde_i & mdscr_el1_kde;
      default:debug_enabled_from_el_us[2] = 1'bx;
    endcase

  always @*
    case ({(dbg_os_lock_set | dbg_double_lock_status_us), aarch64_at_el_i[1], ns_scr_i})
      `ca53dpu_sel_1xx: debug_enabled_from_el_us[1:0] = 2'b00;
      3'b000:           debug_enabled_from_el_us[1:0] = {aarch32_secure_debug_auth, aarch32_secure_debug_auth | cp_sder_i[0]};
      3'b001:           debug_enabled_from_el_us[1:0] = 2'b11;
      3'b010:           debug_enabled_from_el_us[1:0] = {~cp_mdcr_el3_sdd_i & mdscr_el1_kde, ~cp_mdcr_el3_sdd_i};
      3'b011:           debug_enabled_from_el_us[1:0] = {hdcr_tde_i | mdscr_el1_kde, 1'b1};
      default           debug_enabled_from_el_us[1:0] = 2'bxx;
    endcase

  assign nxt_dbg_soft_step_active = ~in_halt &
                                    (((exception_level_debug == `CA53_EL2) & aarch64_at_el_i[2]) |
                                     ((exception_level_debug == `CA53_EL1) & aarch64_at_el_i[1])) &
                                    debug_enabled_from_el_us[dpu_exception_level_i] & mdscr_el1_ss &
                                    ~((dpu_exception_level_i == exception_level_debug) & cpsr_dbit_ret_i);

  // ------------------------------------------------------
  // MDCCINT_EL1 / DBGDCCINT: Debug Comms Channel Interrupt Enable Register
  // ------------------------------------------------------

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n) begin
      dbg_cint_rx <= 1'b0;
      dbg_cint_tx <= 1'b0;
    end else if (cp14_wr_mdccint) begin
      dbg_cint_rx <= mcr_data_wr_i[30];
      dbg_cint_tx <= mcr_data_wr_i[29];
    end

  assign dbg_mdccint = {1'b0,           // 31   RES0
                        dbg_cint_rx,    // 30   RXfull
                        dbg_cint_tx,    // 29   TXfull
                        29'h00000000};  // 28:0 RES0

  // ------------------------------------------------------
  // EDRCR: Debug Run Control Register
  // ------------------------------------------------------

  // EDRCR[2] - Clear Sticky Exception Flags
  assign edrcr_cse  = apb_wr_edrcr & pwdatadbg_reg[2];

  // EDRCR[3] - Clear Sticky Pipeline Advance Flag
  assign edrcr_cspa = apb_wr_edrcr & pwdatadbg_reg[3];

  // EDRCR[4] - Cancel BIU requests
  assign set_edrcr_cbrrq = apb_wr_edrcr & pwdatadbg_reg[4] & // EDRCR.CBR is set
                           edbgrq_reg &                      // and a debug request is pending
                           dbgen_synced & spiden_synced;     // and DBGEN and SPIDEN are asserted

  // Clear uses dscr_halted (and not in_halt) as this is set after the debug state machine has responded to edrcr_cbrrq
  assign clr_edrcr_cbrrq = edrcr_cbrrq & (dscr_halted | ~(dbgen_synced & spiden_synced));

  assign nxt_edrcr_cbrrq = set_edrcr_cbrrq | (edrcr_cbrrq & ~clr_edrcr_cbrrq);

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      edrcr_cbrrq <= 1'b0;
    else
      edrcr_cbrrq <= nxt_edrcr_cbrrq;

  // ------------------------------------------------------
  // EDECCR OSECCR_EL1 DBGECCR: External Debug Exception Catch Control Register
  // ------------------------------------------------------

  assign nxt_edeccr_nse = cp14_wr_oseccr_el1 ? mcr_data_wr_i[6:5] : pwdatadbg_reg[6:5];
  assign nxt_edeccr_se  = cp14_wr_oseccr_el1 ? {mcr_data_wr_i[3], mcr_data_wr_i[1]} : {pwdatadbg_reg[3], pwdatadbg_reg[1]};

  assign edeccr_en      = apb_wr_edeccr | cp14_wr_oseccr_el1;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n) begin
      edeccr_nse <= 2'b00;
      edeccr_se  <= 2'b00;
    end else if (edeccr_en) begin
      edeccr_nse <= nxt_edeccr_nse;
      edeccr_se  <= nxt_edeccr_se;
    end

  assign edeccr_rd = {{24{1'b0}}, 1'b0, edeccr_nse, 1'b0, edeccr_se[1], 1'b0, edeccr_se[0], 1'b0};
  assign oseccr_rd = {{24{1'b0}}, 1'b0, edeccr_nse, 1'b0, edeccr_se[1], 1'b0, edeccr_se[0], 1'b0};

  // ------------------------------------------------------
  // EDESR: External Debug Event Status Register
  // ------------------------------------------------------
  // Clear all bits when exiting halting debug
  // Writing a 1 clears the respective bit

  assign nxt_edesr_ss    = load_initial_warm                                                           ? edecr_ss_reg : // Initialisation
                           left_debug                                                                  ? 1'b0         : // exit halt
                           (dpu_instr_retire & dbg_halt_step_active_not_pend & ~expt_quash_wr_i)       ? 1'b1         : // Execute an instruction
                           (dbg_halt_step_active_not_pend & dbg_ss_vld_expt_type_ret_i &                                // Sync & Async Exception
                            ((target_exception_level_i != 2'b11) | (dbgen_synced & spiden_synced)))    ? 1'b1         :
                           (apb_wr_edesr & (pwdatadbg_reg[2] == 1'b1))                                 ? 1'b0         : // APB write
                           edesr_ss;                                                                                    // Maintain current value

  assign nxt_edesr_rc    = load_initial_warm                                            ? edecr_rce_reg :
                           left_debug                                                   ? 1'b0          :
                           (apb_wr_edesr & (pwdatadbg_reg[1] == 1'b1))                  ? 1'b0          :
                           edesr_rc;

  assign nxt_edesr_osuc  = left_debug                                  ? 1'b0 :
                           (apb_wr_edesr & (pwdatadbg_reg[0] == 1'b1)) ? 1'b0 :
                           (edecr_osuce_reg & clear_oslk & ~in_halt)   ? 1'b1 : edesr_osuc;

  always @(posedge clk) begin
    edesr_ss <= nxt_edesr_ss;
    edesr_rc <= nxt_edesr_rc;
  end

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      edesr_osuc <= 1'b0;
    else
      edesr_osuc <= nxt_edesr_osuc;

  assign edesr_rd = {29'h00000000, // 31:3  RES0
                     edesr_ss,     //  2    SS
                     edesr_rc,     //  1    RC
                     edesr_osuc};  //  0    OSUC

  assign ss_enter_halt = edesr_ss & dbg_halting_allowed_synced;

  assign dbg_halt_step_active_not_pend   = dbg_halting_allowed_synced & edecr_ss_reg & ~edesr_ss;
  assign dbg_halt_step_active_not_pend_o = dbg_halt_step_active_not_pend;

  // ------------------------------------------------------
  // EDITR: Instruction Transfer Register
  // ------------------------------------------------------
  // When L1 ECC exception detected wait until after the exception has completed then resend the instruction
  assign nxt_l1_ecc_detect = (expt_type_l1_ecc_i & dscr_halted) | l1_ecc_detect & ~l1_ecc_resend;
  assign l1_ecc_resend     = l1_ecc_detect & expt_idle_i;
  
  always @(posedge clk_dbg_halt or negedge reset_n)
    if (~reset_n)
      l1_ecc_detect <= 1'b0;
    else
      l1_ecc_detect <= nxt_l1_ecc_detect;

  // The EDITR can only be updated when halted and EDSCR.ERR is clear.
  assign load_editr_apb = apb_wr_editr & dscr_halted & ~dbg_restarting & edscr_ite & ~edscr_ma_extend;
  assign load_editr     = load_editr_apb | editr_ma_wr;

  assign nxt_editr  = editr_ma_wr ? editr_ma_val : pwdatadbg_reg;

  always @(posedge clk_dbg_halt)
    if (load_editr)
      editr <= nxt_editr;

  // Send instruction to the IFU via editr
  // Send again if a ECC error detected
  assign nxt_dpu_dbg_valid = load_editr | l1_ecc_resend;

  always @(posedge clk_dbg_halt or negedge reset_n)
    if (~reset_n)
      dpu_dbg_valid <= 1'b0;
    else
      dpu_dbg_valid <= nxt_dpu_dbg_valid;

  // Delay internal use of edscr_ma until current instruction transfer is complete
  assign nxt_ma_wait = load_editr_apb | ma_wait & ~edscr_ite; 

  always  @(posedge clk_dbg_halt or negedge reset_n)
    if (~reset_n)
      ma_wait <= 1'b0;
    else
      ma_wait <= nxt_ma_wait;
    
  // Drive instruction to IFU
  assign dpu_dbg_valid_o = dpu_dbg_valid;
  assign dpu_dbg_ins_o = editr;

  // ------------------------------------------------------
  // DBGDTRRX / DBGDTRRX_EL0: Host to Target Data Transfer Register
  // DBGDTR: Half duplex transfer register
  // ------------------------------------------------------
  // There are two different modes of operation to complete an update:
  //
  // Normal access mode (EDSCR.MA = 0 or in non-debug state)
  //  Writes to DBGDTRRX are stalled if dscr_dtrrx_full is set
  //
  // Memory access mode (EDSCR.MA = 1 and in debug state)
  //  Writes to DBGDTRRX triggers the execution of an
  //  MRS X1,DBGDTRRX_EL0 / MRC R1,DBGDTRRXint instruction
  //  which writes the value into memory.

  assign load_dtrrx_flag = apb_wr_dtrrx & ~edscr_err & ~dbg_restarting & ~dscr_dtrrx_full & 
                            ~(edscr_ma_extend & ~edscr_ite);

  assign load_dtrrx      = load_dtrrx_flag | cp14_wr_dtrrx_ext | (cp14_wr_dtr & ~dscr_dtrtx_full);

  assign nxt_dtrrx       = apb_wr_dtrrx ? pwdatadbg_reg :
                           cp14_wr_dtr  ? mcr_data_wr_i[63:32]
                                        : mcr_data_wr_i[31:0];

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      dtrrx <= 32'h00000000;
    else if (load_dtrrx)
      dtrrx <= nxt_dtrrx;

  // ------------------------------------------------------
  // DBGDTRTX / DBGDTRTX_EL0: Target to Host Data Transfer Register
  // DBGDTR: Half duplex transfer register
  // ------------------------------------------------------
  // There are two different modes of operation to complete an update:
  //
  // Memory access mode (EDSCR.MA = 1 and in debug state)
  //  Read from DBGDTRRX triggers the execution of
  //  LDR W1,[X0],#4 / LDR R1,[R0],#4 followed by
  //  MSR DBGDTRTX_EL0,X1 / MCR DBGDTRTXint,R1 instructions
  //  which reads a new value from memory.

  assign load_dtrtx_flag = (cp14_wr_dtrtx_int | cp14_wr_dtr | ldc_wr_dtrtx_int) & ~dscr_dtrtx_full;

  assign load_dtrtx      = load_dtrtx_flag | apb_wr_dtrtx | cp14_wr_dtrtx_ext;

  assign nxt_dtrtx       = (cp14_wr_dtrtx_int | cp14_wr_dtr | cp14_wr_dtrtx_ext) ? mcr_data_wr_i[31:0]  :
                           apb_wr_dtrtx                                          ? pwdatadbg_reg        :
                                                                                   fwd_ld_data_int_wr_i;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      dtrtx <= 32'h00000000;
    else if (load_dtrtx)
      dtrtx <= nxt_dtrtx;

  // ------------------------------------------------------
  // EDPCSR: Program Counter Sampling Register
  // ------------------------------------------------------

  // Sample the permited signal on the same cycle as the program counter updates
  assign nxt_pc_sample_perm_o = ~dscr_halted & dbg_non_inv_perm_synced;

  assign pc_instr0_no_offset_ret = pc_instr0_ret_i - (isa_instr0_ret_i[1] ? 4'b0000 : // AArch64
                                                      isa_instr0_ret_i[0] ? 4'b0100 : // Thumb
                                                                            4'b1000); // ARM

  assign pcsr_lo_rd  =  ~pc_sample_perm_i                     ? 32'hFFFF_FFFF :  pc_instr0_no_offset_ret[31:0];
  assign nxt_pcsr_hi = (~pc_sample_perm_i | ~aarch64_state_i) ? 17'h0_0000    :  pc_instr0_no_offset_ret[48:32];

  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      pcsr_hi       <= {17{1'b0}};
    else if (apb_rd_se_edpcsrlo)
      pcsr_hi       <= nxt_pcsr_hi;

  assign pcsr_hi_rd  = {{15{pcsr_hi[16]}}, pcsr_hi[16:0]};
  
  // ------------------------------------------------------
  // EDCIDSR : Context ID Sampling Register
  // ------------------------------------------------------

  // Instruct TLB to sample Context ID when DBGPCSR_LO is read
  assign dpu_dbg_sample_contextid_o = apb_rd_se_edpcsrlo & pc_sample_perm_i;

  // ------------------------------------------------------
  // EDPRCR / DBGPRCR_EL1: Power-down and Reset Control Register
  // ------------------------------------------------------

  // EDPRCR[1]: Core Warm Reset Request.
  assign nxt_edprcr_reset_req    = edprcr_reset_req | (apb_wr_edprcr & pwdatadbg_reg[1] & dbgen_synced & spiden_synced);

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n)
      edprcr_reset_req <= 1'b0;
    else
      edprcr_reset_req <= nxt_edprcr_reset_req;

  // EDPRCR[0]:Core No Power-down Request
  assign nxt_edprcr_corenpdrq    = load_initial_cold ? dbgpwrupreq_reg    :
                                   apb_wr_edprcr     ? pwdatadbg_reg[0]   :
                                   cp14_wr_prcr      ? mcr_data_wr_i[0]   :
                                                       edprcr_corenpdrq;

  always @(posedge clk_dbg_regs)
    edprcr_corenpdrq <= nxt_edprcr_corenpdrq;

  assign dpu_dbgnopwrdwn_o  = edprcr_corenpdrq;
  assign dpu_dbgrstreq_o    = edprcr_reset_req;
  assign edprcr_rd          = {28'h0000000, 2'b00, 1'b0, edprcr_corenpdrq};

  // ------------------------------------------------------
  // EDWAR: External Debug Watchpoint Address Register
  // ------------------------------------------------------
  assign load_edwar = dbg_event_halt_wr_i & (expt_status_moe_data_wr_i == `CA53_DBG_STATUS_WPT);

  always @(posedge clk)
    if (load_edwar)
      edwar_rd <= dcu_va_dc3_i;

  // ------------------------------------------------------
  // EDPRSR: Device Power-down and Reset Status Register
  // ------------------------------------------------------

  // EDPRSR[11] SDR Sticky debug restart bit
  assign nxt_edprsr_sdr = left_debug       ? 1'b1 :
                          apb_rd_se_edprsr ? 1'b0 : edprsr_sdr;

  always @(posedge clk_dbg_halt or negedge reset_n)
    if (~reset_n)
      edprsr_sdr <= 1'b0;
    else
      edprsr_sdr <= nxt_edprsr_sdr;

  // EDPRSR[10] SPMAD Sticky failed performance monitor read bit
  assign nxt_edprsr_spmad = apb_rd_se_edprsr ? 1'b0 : (((apb_pmu_wr_req | apb_pmu_rd_req) & apb_pmu_access_i & edprsr_epmad & 
                                                         ~dbg_os_lock_set & ~dbg_double_lock_status_synced & ~pmu_apb_slk) | edprsr_spmad); 

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      edprsr_spmad <= 1'b0;
    else
      edprsr_spmad <= nxt_edprsr_spmad;

  // EDPRSR[9] EPMAD external performance monitor access disabled bit
  assign allow_ext_pmu_access = ~dbg_double_lock_status_synced & ~dbg_os_lock_set & 
                                (dbgen_synced | niden_synced) & (spiden_synced | spniden_synced | ~cp_mdcr_el3_epmad_i);
  assign edprsr_epmad = ~allow_ext_pmu_access;

  // EDPRSR[8] SDAD Sticky EDAD error bit
  assign set_edprsr_sdad = edprsr_edad & ((paddrdbg_reg[11:8] == `CA53_DBG_BVR) | (paddrdbg_reg[11:8] == `CA53_DBG_WVR));
  assign nxt_edprsr_sdad = apb_rd_se_edprsr ? 1'b0 : ((set_edprsr_sdad & ~dbg_apb_full_lock & apb_dbg_active & apb_strobe) | edprsr_sdad); 

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      edprsr_sdad <= 1'b0;
    else
      edprsr_sdad <= nxt_edprsr_sdad;

  // EDPRSR[7] EDAD external debug access disabled bit
  assign allow_ext_debug_access = ~dbg_double_lock_status_synced & ~dbg_os_lock_set & dbgen_synced & (spiden_synced | ~cp_mdcr_el3_edad_i);
  assign edprsr_edad = ~allow_ext_debug_access;

  // EDPRSR[6] DLK Double-lock Status bit
  assign dbg_double_lock_status_us = osdlr_el1_dlk & ~edprcr_corenpdrq & ~in_halt;

  // EDPRSR[3] SR Sticky reset bit
  assign nxt_edprsr_sr = edprsr_sr & ~apb_rd_se_edprsr;

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n)
      edprsr_sr <= 1'b1;
    else
      edprsr_sr <= nxt_edprsr_sr;

  // EDPRSR[2] R Used to detect reset_n getting asserted
  assign edprsr_r = load_initial_warm;

  // EDPRSR[1] SPD Sticky power-down bit
  assign nxt_edprsr_spd = edprsr_spd & ~apb_rd_se_edprsr;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      edprsr_spd <= 1'b1;
    else
      edprsr_spd <= nxt_edprsr_spd;

  // When core power domain is off reads EDPRSR[3:0] as {0, 0, 1, 0}
  assign edprsr_rd = dbg_double_lock_status_synced ? {20'h00000, 12'b0000_0100_0001}
                                                   : {20'h00000,
                                                      edprsr_sdr,         // 11 SDR   
                                                      edprsr_spmad,       // 10 SPMAD 
                                                      edprsr_epmad,       //  9 EPMAD 
                                                      edprsr_sdad,        //  8 SDAD  
                                                      edprsr_edad,        //  7 EDAD  
                                                      1'b0,               //  6 DLK   
                                                      dbg_os_lock_set,    //  5 OSLK  
                                                      dscr_halted,        //  4 HALTED
                                                      edprsr_sr,          //  3 SR    
                                                      edprsr_r,           //  2 R     
                                                      edprsr_spd,         //  1 SPD   
                                                      1'b1};              //  0 PU    

  // ------------------------------------------------------
  // DBGCLAIMSET/DBGCLAIMCLR: Claim Tag Set/Clear Registers
  // DBGCLAIMSET_EL1/DBGCLAIMCLR_EL1
  // ------------------------------------------------------

  // This register is controlled by two addresses - DBGCLAIMSET and DBGCLAIMCLR. There are 8 bits
  // which are set by writing a '1' to that bit of the register at the DBGCLAIMSET address, and
  // cleared by writing a '1' to that bit at the DBGCLAIMCLR address.
  assign claim_setbits = ({8{apb_wr_claimset}}  & pwdatadbg_reg[7:0]) |
                         ({8{cp14_wr_claimset}} & mcr_data_wr_i[7:0]);
  assign claim_clrbits = ({8{apb_wr_claimclr}}  & pwdatadbg_reg[7:0]) |
                         ({8{cp14_wr_claimclr}} & mcr_data_wr_i[7:0]);

  assign en_claim_reg  = apb_wr_claimset | cp14_wr_claimset | apb_wr_claimclr | cp14_wr_claimclr;
  assign nxt_claim_reg = (claim_reg | claim_setbits) & ~claim_clrbits;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      claim_reg <= 8'h00;
    else if (en_claim_reg)
      claim_reg <= nxt_claim_reg;

  assign claimset_rd = 32'h000000FF;
  assign claimclr_rd = {24'h000000, claim_reg};

  // ------------------------------------------------------
  // DBGOSLAR / OSLAR_EL1: OS Lock Access Register
  // ------------------------------------------------------

  assign nxt_os_lock_set = apb_wr_oslar  ? pwdatadbg_reg[0] :
                           cp14_wr_oslar ? (aarch64_state_i ? mcr_data_wr_i[0] : (mcr_data_wr_i[31:0] == 32'hC5ACCE55))
                                         : dbg_os_lock_set;

  always @(posedge clk_dbg_regs or negedge po_reset_n)
    if (~po_reset_n)
      dbg_os_lock_set <= 1'b1;
    else
      dbg_os_lock_set <= nxt_os_lock_set;

  assign clear_oslk = (apb_wr_oslar | cp14_wr_oslar) & dbg_os_lock_set & ~nxt_os_lock_set;

  // ------------------------------------------------------
  // DBGAUTHSTATUS / DBGAUTHSTATUS_EL1: Authentication Status Register
  // ------------------------------------------------------

  assign dbg_authstatus_rd[31:8] = 24'h000000;
  assign dbg_authstatus_rd[7]    = 1'b1;
  assign dbg_authstatus_rd[6]    = (niden_synced | dbgen_synced) & (spniden_synced | spiden_synced);
  assign dbg_authstatus_rd[5]    = 1'b1;
  assign dbg_authstatus_rd[4]    = dbgen_synced & spiden_synced;
  assign dbg_authstatus_rd[3]    = 1'b1;
  assign dbg_authstatus_rd[2]    = niden_synced | dbgen_synced;
  assign dbg_authstatus_rd[1]    = 1'b1;
  assign dbg_authstatus_rd[0]    = dbgen_synced;

  // ------------------------------------------------------
  // DBGDEVID: Debug Device ID Register
  // ------------------------------------------------------

  assign dbg_devid_rd = `CA53_DBGDEVID_READ_VALUE;

  // ------------------------------------------------------
  // DBGDEVID1: Debug Device ID1 Register
  // ------------------------------------------------------

  assign dbg_devid1_rd = `CA53_DBGDEVID1_READ_VALUE;

  // ------------------------------------------------------
  // DBGOSDLR / OSDLR_EL1 : Double-Lock Register
  // ------------------------------------------------------

  always @(posedge clk_dbg_regs or negedge reset_n)
    if (~reset_n)
      osdlr_el1_dlk <= 1'b0;
    else if (cp14_wr_osdlr)
      osdlr_el1_dlk <= mcr_data_wr_i[0];

  assign osdlr_rd = {{31{1'b0}}, osdlr_el1_dlk};

  // ------------------------------------------------------
  // DBGOSLSR / OSLSR_EL1 : OS Lock Status Register
  // ------------------------------------------------------

  assign oslsr_rd = {{28{1'b0}}, 2'b10, dbg_os_lock_set, 1'b0};

  // ------------------------------------------------------
  // DSPSR_EL0 & DSPSR : Debug Processor Status Register
  // ------------------------------------------------------

  assign dspsr_rd = {dspsr_reg_i[28:22], 3'b000, dspsr_reg_i[21:0]};

  // ------------------------------------------------------
  // Assignments
  // ------------------------------------------------------

  assign in_halt_o                  = in_halt;
  assign dbg_hw_halt_req_o          = dbg_hw_halt_req;
  assign held_dbg_hw_halt_req_o     = held_dbg_hw_halt_req;
  assign held_dbg_osuc_halt_req_o   = held_dbg_osuc_halt_req;
  assign held_dbg_ext_hw_halt_req_o = held_dbg_ext_hw_halt_req;
  assign dbg_restart_qual_o         = dbg_restart_qual;
  assign dbg_cancel_biu_o           = edrcr_cbrrq;
  assign dpu_apb_active_o           = apb_dbg_active;
  assign dbg_non_inv_perm_us_o      = dbg_non_inv_perm_us;
  assign dbg_non_inv_perm_synced_o  = dbg_non_inv_perm_synced;
  assign dbg_os_lock_synced_o       = dbg_os_lock_synced;
  assign dbg_double_lock_set_o      = dbg_double_lock_status_synced;
  assign dbg_halting_allowed_o      = dbg_halting_allowed_synced;
  assign dbg_starting_o             = dbg_starting;
  assign edecr_ss_reg_o             = edecr_ss_reg;
  assign edscr_sdd_o                = edscr_sdd;
  assign edscr_tda_o                = edscr_tda;
  assign ss_enter_halt_o            = ss_enter_halt;
  assign exception_level_debug_o    = exception_level_debug;
  assign debug_enabled_from_el_o    = debug_enabled_from_el_us;
  assign mdscr_el1_tdcc_o           = dscr_udcc_dis;
  assign mdscr_el1_ss_o             = mdscr_el1_ss;
  assign dbg_soft_step_active_o     = dbg_soft_step_active;
  assign edscr_intdis_o             = edscr_intdis;
  assign dbgen_synced_o             = dbgen_synced;
  assign spiden_synced_o            = spiden_synced;

  // ------------------------------------------------------
  //                     OVL definitions
  // ------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_rd_se_edpcsrlo")
  u_ovl_x_apb_rd_se_edpcsrlo (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (apb_rd_se_edpcsrlo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_strobe")
  u_ovl_x_apb_strobe (.clk       (clk_dbg_regs),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (apb_strobe));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dscr_load_en")
  u_ovl_x_dscr_load_en (.clk       (clk_dbg_regs),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (dscr_load_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: in_halt")
  u_ovl_x_in_halt (.clk       (clk_dbg_halt),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (in_halt));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_edwar")
  u_ovl_x_load_edwar (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (load_edwar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_apb_strobe")
  u_ovl_x_nxt_apb_strobe (.clk       (clk_dbg_regs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (nxt_apb_strobe));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp14_wr_mdccint")
  u_ovl_x_cp14_wr_mdccint (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp14_wr_mdccint));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp14_wr_osdlr")
  u_ovl_x_cp14_wr_osdlr (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp14_wr_osdlr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dbg_event_halt_wr_i")
  u_ovl_x_dbg_event_halt_wr_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (dbg_event_halt_wr_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dscr_dbg_en_synced_en")
  u_ovl_x_dscr_dbg_en_synced_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (dscr_dbg_en_synced_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: edeccr_en")
  u_ovl_x_edeccr_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (edeccr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_claim_reg")
  u_ovl_x_en_claim_reg (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_claim_reg));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_dscr_moe")
  u_ovl_x_load_dscr_moe (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (load_dscr_moe));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_dtrrx")
  u_ovl_x_load_dtrrx (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (load_dtrrx));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_dtrtx")
  u_ovl_x_load_dtrtx (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (load_dtrtx));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_editr")
  u_ovl_x_load_editr (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (load_editr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_edscr_err")
  u_ovl_x_load_edscr_err (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (load_edscr_err));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_cold")
  u_ovl_x_load_initial_cold (.clk       (clk),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (load_initial_cold));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_warm")
  u_ovl_x_load_initial_warm (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (load_initial_warm));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_mdscr_el1_ss")
  u_ovl_x_load_mdscr_el1_ss (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (load_mdscr_el1_ss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prdatadbg_en")
  u_ovl_x_prdatadbg_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (prdatadbg_en));

  //----------------------------------------------------------------------------
  // X-check asserts for signals used in if statements which are not register enables
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: ifu_drain_state_en")
  u_ovl_x_ifu_drain_state_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ifu_drain_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: (ifu_dbg_ready_i & forceop_cmpt)")
  u_ovl_x_ifu_dbg_ready_i    (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ifu_dbg_ready_i & forceop_cmpt));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: dbgrestart_reg")
  u_ovl_x_dbgrestart_reg     (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dbgrestart_reg));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: (expt_idle_i & edscr_ite & ~load_editr)")
  u_ovl_x_expt_idle          (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (expt_idle_i & edscr_ite & ~load_editr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: (apb_rd_se_dtrtx & dscr_dtrtx_full & edscr_ma_qual & ~edscr_err)")
  u_ovl_x_apb_rd_se_dtr      (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (apb_rd_se_dtrtx & dscr_dtrtx_full & edscr_ma_qual & ~edscr_err));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: (apb_wr_dtrrx & ~dscr_dtrrx_full & edscr_ma_qual & ~edscr_err)")
  u_ovl_x_apb_wr_dtrrx       (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (apb_wr_dtrrx & ~dscr_dtrrx_full & edscr_ma_qual & ~edscr_err));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: expt_type_l1_ecc_i")
  u_ovl_x_expt_type_l1_ecc_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (expt_type_l1_ecc_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: edscr_err")
  u_ovl_x_edscr_err          (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (edscr_err));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: dbg_expt_i")
  u_ovl_x_dbg_expt_i         (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dbg_expt_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: dpu_instr_retire")
  u_ovl_x_dpu_instr_retire   (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dpu_instr_retire));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: expt_idle_i")
  u_ovl_x_expt_idle_i        (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (expt_idle_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: (edscr_ite & ~load_editr & ~ma_active)")
  u_ovl_x_edscr_ite_load_edi (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (edscr_ite & ~load_editr & ~ma_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: expt_dbgexit_i")
  u_ovl_x_expt_dbg_exit_i    (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (expt_dbgexit_i));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Never access DBGDTR_EL0 in AArch32 state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, 1, `OVL_ASSERT, "Access DBGDTR_EL0 detected in AArch32 state")
  ovl_debug_dbgdtr_aarch32 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (~aarch64_state_i),
    .consequent_expr (~(cp14_wr_dtr | (cp14_rd_dtr_el0 & cp_valid_wr_i)))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Once OSDLR_EL1.DLK has been sychronised must not enter debug state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, 1, `OVL_ASSERT, "Once OSDLR_EL1.DLK has been sychronised must not enter debug state")
  ovl_debug_dlk_enter_halt (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (dbg_double_lock_status_synced),
    .consequent_expr (~debug_entry)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that the instructions not sent from ITR when EDSCR.ERR set
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Check that the instructions not sent from ITR when EDSCR.ERR set")
    ovl_bkpt_itr_to_dpu_edscr_err(.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (load_editr),
                                  .consequent_expr (~edscr_err));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that the debug state machine is always in a valid state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"DPU Debug block: State machine in invalid state")
    ovl_debug_valid_state (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr ((dbg_state[2:0] == DBG_STATE_RUN)          |
                                       (dbg_state[2:0] == DBG_STATE_DCU_DRAIN)    |
                                       (dbg_state[2:0] == DBG_STATE_IFU_DRAIN)    |
                                       (dbg_state[2:0] == DBG_STATE_HALTED)       |
                                       (dbg_state[2:0] == DBG_STATE_RESTART_HELD) |
                                       (dbg_state[2:0] == DBG_STATE_RESTARTING)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that the dbg_event_i signal can not be asserted in drain
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"MOE bits overwritten as dbg_event_i asserted while state machine is in IFU/DCU drain")
    ovl_debug_moe_overwrite (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (dbg_event_i & ((dbg_state[2:0] == DBG_STATE_DCU_DRAIN) |
                                                        (dbg_state[2:0] == DBG_STATE_IFU_DRAIN))));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // No software BKPT or WPT while ~dscr_mdbg_en_synced
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  // Make events last just once cycle
  reg  ovl_dbg_sw_event_dly;
  wire ovl_dbg_sw_event_dly_pulse;
  wire ovl_nxt_dbg_sw_event_dly;

  reg  dscr_mdbg_en_synced;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dscr_mdbg_en_synced <= 1'b0;
    else if (dscr_dbg_en_synced_en)
      dscr_mdbg_en_synced <= dscr_mdbg_en;

  assign ovl_nxt_dbg_sw_event_dly = dbg_event_i & ((expt_status_moe_data_wr_i == `CA53_DBG_STATUS_BKPT) |
                                                   (expt_status_moe_data_wr_i == `CA53_DBG_STATUS_WPT));

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_dbg_sw_event_dly <= 1'b0;
    else
      ovl_dbg_sw_event_dly <= ovl_nxt_dbg_sw_event_dly;

  assign ovl_dbg_sw_event_dly_pulse = ovl_nxt_dbg_sw_event_dly & ~ovl_dbg_sw_event_dly;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No software BKPT or WPT while ~dscr_mdbg_en_synced")
    ovl_bkpt_wpt_dbg_sw_entry(.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_dbg_sw_event_dly_pulse),
                              .consequent_expr (dscr_mdbg_en_synced));
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // No halting BKPT or WPT while ~edscr_hde
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  // Make events last just once cycle
  reg  ovl_dbg_halting_event_dly;
  wire ovl_dbg_halting_event_dly_pulse;
  wire ovl_nxt_dbg_halting_event_dly;

  assign ovl_nxt_dbg_halting_event_dly = dbg_event_halt_wr_i & ((expt_status_moe_data_wr_i == `CA53_DBG_STATUS_BKPT) |
                                                                (expt_status_moe_data_wr_i == `CA53_DBG_STATUS_WPT));

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_dbg_halting_event_dly <= 1'b0;
    else
      ovl_dbg_halting_event_dly <= ovl_nxt_dbg_halting_event_dly;

  assign ovl_dbg_halting_event_dly_pulse = ovl_nxt_dbg_halting_event_dly & ~ovl_dbg_halting_event_dly;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No halting BKPT or WPT while edscr_hde_synced")
    ovl_bkpt_wpt_dbg_halting_entry(.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_dbg_halting_event_dly_pulse),
                                   .consequent_expr (edscr_hde_synced));
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // Must not hit default on debug_enabled_from_el case statement
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Invalid input combination to debug_enabled_from_el case statement")
  ovl_debug_enabled_from_el (
    .clk        (clk),
    .reset_n    (reset_n),
    .qualifier  (1'b1),
    .test_expr  (debug_enabled_from_el_us)
  );

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Check that the clock enable term for PMU APB writes is correct
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg ovl_last_nxt_pmu_apb_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_last_nxt_pmu_apb_wr <= 1'b0;
    else
      ovl_last_nxt_pmu_apb_wr <= nxt_pmu_apb_wr_o;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"nxt_pmu_apb_wr_o was incorrect on previous cycle")
    ovl_debug_pmu_apb_wr_en (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (pmu_apb_wr_o),
                             .consequent_expr (ovl_last_nxt_pmu_apb_wr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Memory Access Mode state machine state should never be X
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Memory Access Mode state machine state X")
  u_ovl_current_state_x      (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ma_state));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Memory Access Mode state machine should never be in invalid state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Memory Access Mode state machine in invalid state")
    ovl_current_state_valid (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ((ma_state == MA_STATE_WAIT)        |
                                         (ma_state == MA_STATE_READ_LDR)    |
                                         (ma_state == MA_STATE_READ_LDR_W)  |
                                         (ma_state == MA_STATE_READ_LDR_E)  |
                                         (ma_state == MA_STATE_READ_MSR)    |
                                         (ma_state == MA_STATE_READ_MSR_W)  |
                                         (ma_state == MA_STATE_READ_ECC_W)  |
                                         (ma_state == MA_STATE_WRITE_MRS)   |
                                         (ma_state == MA_STATE_WRITE_MRS_W) |
                                         (ma_state == MA_STATE_WRITE_MRS_E) |
                                         (ma_state == MA_STATE_WRITE_STR)   |
                                         (ma_state == MA_STATE_WRITE_STR_W) |
                                         (ma_state == MA_STATE_WRITE_STR_E)));
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // Memory Access Mode state machine 
  // Must not get an exception in state MA_STATE_READ_MSR_W
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Must not get an exception in MA_STATE_READ_MSR_W")
    ovl_debug_expt_in_ma_read_msr (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ma_state == MA_STATE_READ_MSR_W),
                                   .consequent_expr (dbg_expt_i == 1'b0));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Must not enter halt state without dbg_halting_allowed_synced except for external debug request.
  // OVL_ASSERT: ovl_debug_enter_halt_state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  wire   ovl_early_debug_entry;

  assign ovl_early_debug_entry = nxt_in_halt & ~in_halt;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Must not enter halt state without dbg_halting_allowed_synced except for external debug request")
    ovl_debug_enter_halt_state (.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (~dbg_halting_allowed_synced),
                                .consequent_expr (~(ovl_early_debug_entry & (expt_status_moe_data_wr_i != `CA53_DBG_STATUS_EXT_DBG_REQ))));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Must not enter halt state without dbg_halting_allowed_us for external debug request.
  // OVL_ASSERT: ovl_debug_enter_halt_state_ext
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  reg ovl_dbg_halting_allowed_us_reg;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_dbg_halting_allowed_us_reg <= 1'b0;
    else
      ovl_dbg_halting_allowed_us_reg <= dbg_halting_allowed_us;
  

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Must not enter halt state without dbg_halting_allowed_us for external debug request")
    ovl_debug_enter_halt_state_ext (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (~ovl_dbg_halting_allowed_us_reg),
                                    .consequent_expr (~(ovl_early_debug_entry & (expt_status_moe_data_wr_i == `CA53_DBG_STATUS_EXT_DBG_REQ))));

  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.2.a Debug events in Secure User mode cannot cause an
  // entry into debug state if both SPIDEN and SUIDEN are disabled.
  // OVL_ASSERT: ovl_tz_dbg_events_user_mode
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire   ovl_sticky_spiden_wr_en;
  reg    ovl_sticky_spiden;

  assign ovl_sticky_spiden_wr_en    = dpu_fe_valid_ret_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_sticky_spiden <= 1'b0;
    else if (ovl_sticky_spiden_wr_en)
      ovl_sticky_spiden <= spiden_synced;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No DBG entry when in Secure User mode and SPIDEN and SUIDEN are disabled")
    ovl_tz_dbg_events_user_mode(.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr ((cpsr_mode_ret_i == `CA53_FULL_MODE_USR) & ~ns_state_i & ~spiden_synced & ~cp_sder_i[0] & dbg_event_i),
                                .consequent_expr (~dbg_event_halt_wr_i));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.2.a Debug events in Secure Privileged modes cannot cause
  // an entry into debug state if SPIDEN is disabled.
  // OVL_ASSERT: ovl_tz_dbg_events_priv_mode
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No DBG entry when in Secure Privileged modes and SPIDEN is disabled")
    ovl_tz_dbg_events_priv_mode(.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr ((cpsr_mode_ret_i != `CA53_FULL_MODE_USR) & ~ns_state_i & ~spiden_synced & dbg_event_i),
                                .consequent_expr (~dbg_event_halt_wr_i));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.2.b Debug state is entered with the CPSR mode and NS-bit
  // at the same value as when the debug event occured.
  // OVL_ASSERT: ovl_tz_no_change_in_dbg_entry
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg [4:0] ovl_ovl_cpsr_mode_ret;
  reg       ovl_ns_state;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_ovl_cpsr_mode_ret <= `CA53_FULL_MODE_SVC;
      ovl_ns_state      <= 1'b0;
    end
    else begin
      ovl_ovl_cpsr_mode_ret <= cpsr_mode_ret_i;
      ovl_ns_state      <= ns_state_i;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"CPSR mode and state should remain unchanged when dbg entry")
    ovl_tz_no_change_in_dbg_entry(.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr ((dbg_state == DBG_STATE_DCU_DRAIN) | (dbg_state == DBG_STATE_IFU_DRAIN)),
                                  .consequent_expr ((cpsr_mode_ret_i == ovl_ovl_cpsr_mode_ret) & (ns_state_i == ovl_ns_state)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.2.c While in Debug state, change from  Non-Secure state
  // is possible only if SPIDEN is asserted.
  // OVL_ASSERT: ovl_tz_ns_to_s_state_in_dbg_state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
    assert_implication #(`OVL_FATAL,`OVL_ASSERT,"While in DBG state, change from Non-Secure to Secure state is possible only if SPIDEN is asserted")
    ovl_tz_ns_to_s_state_in_dbg_state(.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr ((dbg_state != 3'b000) & edscr_sdd & ovl_ns_state),
                                      .consequent_expr (ns_state_i == ovl_ns_state));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.5.2.e While in debug state and in Non-Secure state, the
  // secure CP15 registers cannot be accessed
  // OVL_ASSERT: ovl_tz_scp15_no_access_in_ns
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No access in secure CP15 registers when in ns_state")
    ovl_tz_scp15_no_access_in_ns(.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr ((dbg_state != 3'b000) & ns_state_i),
                                 .consequent_expr (u_dpu_cp.secure_cp15_rd_wr == 1'b0));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // ARMv8 Section 8.4.5 Security in Debug State
  // The value of EDSCR.SDD must not change while in debug state
  // OVL_ASSERT: ovl_armv8_edscr_sdd_not_change
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg  ovl_edscr_sdd;
  reg  ovl_dscr_halted;

  // Delay edscr_sdd and dscr_halted by one clock cycle
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_edscr_sdd   <= 1'b0;
      ovl_dscr_halted <= 1'b0;
    end
    else begin
      ovl_edscr_sdd   <= edscr_sdd;
      ovl_dscr_halted <= dscr_halted;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"edscr_sdd must not change while in debug state")
    ovl_armv8_edscr_sdd_not_change(.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_dscr_halted & dscr_halted),
                                   .consequent_expr (ovl_edscr_sdd == edscr_sdd));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // ARMv8 Section 8.4.5 Security in Debug State
  // EDSCR.SDD must be set to 0 on entry debug state in secure state
  // OVL_ASSERT: ovl_armv8_edscr_sdd_debug_entry
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  reg  ovl_debug_entry;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_debug_entry<= 1'b0;
    else
      ovl_debug_entry <= debug_entry;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"edscr_sdd must be set to 0 on entry to debug state when secure")
    ovl_armv8_edscr_sdd_debug_entry_sec(.clk             (clk),
                                        .reset_n         (reset_n),
                                        .antecedent_expr (ovl_debug_entry & ~ns_state_i),
                                        .consequent_expr (edscr_sdd == 1'b0));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // ARMv8 Section 8.4.5 Security in Debug State
  // EDSCR.SDD must be set to ExternalSecureInvasiveDebugEnabled on entry debug state in non-secure state
  // OVL_ASSERT: ovl_armv8_edscr_sdd_debug_entry
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  wire ext_sec_inv_debug_en;

  assign ext_sec_inv_debug_en = ~(dbgen_synced & spiden_synced);

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"edscr_sdd must be set to ExternalSecureInvasiveDebugEnabled on entry to debug state when non-secure")
    ovl_armv8_edscr_sdd_debug_entry_ns(.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr (ovl_debug_entry & ns_state_i),
                                       .consequent_expr (ovl_edscr_sdd == ext_sec_inv_debug_en));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // ARMv8 Section 8.4.5 Security in Debug State
  // EDSCR.SDD must be set to ExternalSecureInvasiveDebugEnabled when not in debug state
  // OVL_ASSERT: ovl_armv8_edscr_sdd_not_debug_state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  reg ovl_ext_sec_inv_debug_en;
  reg ovl_in_halt;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_ext_sec_inv_debug_en <= ext_sec_inv_debug_en;
      ovl_in_halt              <= 1'b0;
    end
    else begin
      ovl_ext_sec_inv_debug_en <= ext_sec_inv_debug_en;
      ovl_in_halt              <= in_halt;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"edscr_sdd must be set to ExternalSecureInvasiveDebugEnabled when not in debug state")
    ovl_armv8_edscr_sdd_not_debug_state(.clk             (clk),
                                        .reset_n         (reset_n),
                                        .antecedent_expr (~ovl_in_halt),
                                        .consequent_expr (edscr_sdd == ovl_ext_sec_inv_debug_en));
  // OVL_ASSERT_END



`endif

endmodule // ca53dpu_dbg

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
