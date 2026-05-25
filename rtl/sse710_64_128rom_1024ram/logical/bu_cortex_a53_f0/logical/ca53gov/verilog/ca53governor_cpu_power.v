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
// Description: CPU power control block
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_power (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  DFTSE,
  input  wire                                  clk_cpu,
  input  wire                                  reset_n_gov,
  input  wire [  9: 0]                         cntvalueb_rs_i,
  input  wire                                  excl_mon_cleared_i,
  input  wire                                  sev_set_event_register_i,
  input  wire                                  dpu_clr_event_register_i,
  input  wire                                  dpu_wfi_req_i,
  input  wire                                  dpu_wfe_req_i,
  input  wire [  1: 0]                         dpu_exception_level_i,
  input  wire                                  dpu_aarch64_at_el3_i,
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
  input  wire                                  dpu_hcr_el2_fmo_i,
  input  wire                                  dpu_hcr_el2_imo_i,
  input  wire                                  dpu_hcr_el2_amo_i,
  input  wire                                  dpu_monitor_mode_i,
  input  wire                                  dpu_scr_el3_irq_i,
  input  wire                                  dpu_scr_el3_fiq_i,
  input  wire                                  dpu_scr_el3_ns_i,
  input  wire                                  dpu_dbg_double_lock_set_i,
  input  wire                                  dpu_ns_state_i,
  input  wire [(`CA53_RET_CTL_W-1): 0]         dpu_cpuectlr_cpu_ret_delay_i,
  input  wire [(`CA53_RET_CTL_W-1): 0]         dpu_cpuectlr_neon_ret_delay_i,
  input  wire                                  dpu_neon_active_i,
  input  wire                                  stb_wfx_ready_i,
  input  wire                                  biu_wfx_ready_i,
  input  wire                                  dcu_wfx_ready_i,
  input  wire                                  ifu_wfx_ready_i,
  input  wire                                  tlb_wfx_ready_i,
  input  wire                                  etm_wfx_ready_i,
  input  wire                                  scu_wfx_ready_i,
  input  wire                                  dpu_imp_abort_pending_i,
  input  wire                                  timer_wfe_event_i,
  input  wire                                  clrexmon_rs_i,
  input  wire                                  gov_dbgen_i,
  input  wire                                  gov_giccdisable_i,
  input  wire                                  gov_spiden_i,
  input  wire                                  gov_edbgrq_i,
  input  wire                                  gic_irq_i,
  input  wire                                  gic_fiq_i,
  input  wire                                  gic_virq_i,
  input  wire                                  gic_vfiq_i,
  input  wire                                  sei_level_req_i,
  input  wire                                  vsei_level_req_i,
  input  wire                                  rei_level_req_i,
  input  wire                                  cpuqreqn_i,
  input  wire                                  neonqreqn_i,
  input  wire                                  scu_ac_valid_i,
  input  wire                                  atvalidm_i,
  input  wire                                  apb_bridge_pseldbg_i,
  // Outputs
  output wire                                  gov_event_reg_o,
  output wire                                  gov_standbywfi_o,
  output wire                                  gov_standbywfe_o,
  output reg                                   gov_wfx_drain_req_o,
  output wire                                  gov_wfx_wake_o,
  output reg                                   gate_clk_req_o,
  output reg                                   cpuqactive_o,
  output wire                                  cpuqdeny_o,
  output reg                                   cpuqacceptn_o,
  output reg                                   neonqactive_o,
  output wire                                  neonqdeny_o,
  output reg                                   neonqacceptn_o,
  output wire                                  event_cpu_ret_o,
  output wire                                  event_neon_ret_o,
  output wire                                  cpu_in_retention_o,
  output wire                                  gov_stall_neon_o,
  output reg [  1: 0]                          gov_exception_level_o,
  output reg                                   gov_aarch64_at_el3_o,
  output reg                                   gov_hcr_el2_fmo_o,
  output reg                                   gov_hcr_el2_imo_o,
  output reg                                   gov_hcr_el2_amo_o,
  output reg                                   gov_monitor_mode_o,
  output reg                                   gov_scr_el3_irq_o,
  output reg                                   gov_scr_el3_fiq_o,
  output reg                                   gov_scr_el3_ns_o
);

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam                   WFX_FSM_W       = 2;
  localparam [(WFX_FSM_W-1):0] WFX_FSM_AWAKE   = 2'b00;
  localparam [(WFX_FSM_W-1):0] WFX_FSM_DRAIN   = 2'b01;
  localparam [(WFX_FSM_W-1):0] WFX_FSM_STANDBY = 2'b10;
  localparam [(WFX_FSM_W-1):0] WFX_FSM_RESTART = 2'b11;

  localparam                       RET_CPU_FSM_W          = 3;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_RESET      = 3'b000;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_IDLE       = 3'b001;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_WAIT_COUNT = 3'b010;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_WAIT_NEON  = 3'b011;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_RET_REQ    = 3'b100;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_IN_RET     = 3'b101;
  localparam [(RET_CPU_FSM_W-1):0] RET_CPU_FSM_RET_EXIT   = 3'b110;

  localparam                        RET_NEON_FSM_W            = 4;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_RESET        = 4'b0000;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_IDLE         = 4'b0001;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_WAIT_COUNT   = 4'b0010;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_WAIT_STALL_1 = 4'b0011;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_WAIT_STALL_2 = 4'b0100;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_WAIT_STALL_3 = 4'b0101;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_WAIT_STALL_4 = 4'b0110;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_RET_REQ      = 4'b0111;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_IN_RET       = 4'b1000;
  localparam [(RET_NEON_FSM_W-1):0] RET_NEON_FSM_RET_EXIT     = 4'b1001;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                          ac_valid_rs;
  reg                          biu_wfx_ready_rs;
  reg                          cpuqdeny;
  reg [(`CA53_RET_CTL_W-1):0]  cpuectlr_cpu_ret_delay_rs;
  reg [(`CA53_RET_CTL_W-1):0]  cpuectlr_neon_ret_delay_rs;
  reg                          dbg_double_lock_set_rs;
  reg                          dcu_wfx_ready_rs;
  reg                          dpu_imp_abort_pending_rs;
  reg                          etm_wfx_ready_rs;
  reg                          scu_wfx_ready_rs;
  reg                          fiq_masked_rs;
  reg                          fiq_pended_rs;
  reg                          gov_wfx_wake;
  reg                          ifu_wfx_ready_rs;
  reg                          irq_masked_rs;
  reg                          irq_pended_rs;
  reg                          neon_active_rs;
  reg                          neon_in_retention;
  reg                          neonqdeny;
  reg                          ns_state_rs;
  reg                          nxt_cpuqacceptn;
  reg                          nxt_cpuqactive;
  reg                          nxt_cpuqdeny;
  reg                          nxt_neon_in_retention;
  reg                          nxt_neonqacceptn;
  reg                          nxt_neonqactive;
  reg                          nxt_neonqdeny;
  reg [(RET_CPU_FSM_W-1):0]    nxt_ret_cpu_fsm;
  reg [(RET_NEON_FSM_W-1):0]   nxt_ret_neon_fsm;
  reg                          nxt_stall_neon;
  reg                          nxt_standby_is_wfe;
  reg                          nxt_standbywfe;
  reg                          nxt_standbywfi;
  reg                          nxt_wfx_drain_req;
  reg [(WFX_FSM_W-1):0]        nxt_wfx_fsm;
  reg                          nxt_wfx_wake;
  reg                          ret_cpu_clock_en;
  reg [(RET_CPU_FSM_W-1):0]    ret_cpu_fsm;
  reg [9:0]                    ret_cpu_target_value;
  reg                          ret_neon_clock_en;
  reg [(RET_NEON_FSM_W-1):0]   ret_neon_fsm;
  reg [9:0]                    ret_neon_target_value;
  reg                          sei_masked_rs;
  reg                          sei_pended_rs;
  reg                          stall_neon;
  reg                          standby_is_wfe;
  reg                          standbywfe;
  reg                          standbywfi;
  reg                          stb_wfx_ready_rs;
  reg                          tlb_wfx_ready_rs;
  reg                          wfe_event_reg;
  reg                          wfe_req_rs;
  reg                          vfiq_masked_rs;
  reg                          virq_masked_rs;
  reg                          vsei_masked_rs;
  reg                          wfi_req_rs;
  reg                          vfiq_pended_rs;
  reg                          virq_pended_rs;
  reg                          vsei_pended_rs;
  reg [(WFX_FSM_W-1):0]        wfx_fsm;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                         clk_ret_cpu;
  wire                         clk_ret_neon;
  wire                         cpu_exit_retention;
  wire                         cpuqreqn_rs;
  wire                         dbg_halt_perm;
  wire                         wfx_entry_en;
  wire                         gic_en;
  wire                         neonqreqn_rs;
  wire                         nxt_event_register;
  wire                         nxt_ret_cpu_clock_en;
  wire [9:0]                   nxt_ret_cpu_target_value;
  wire                         nxt_ret_neon_clock_en;
  wire [9:0]                   nxt_ret_neon_target_value;
  wire                         ret_cpu_count_start;
  wire                         ret_cpu_ctl_en;
  wire                         ret_cpu_enabled;
  wire                         ret_cpu_target_hit;
  wire                         nxt_neon_active_rs;
  wire                         ret_neon_count_start;
  wire                         ret_neon_ctl_en;
  wire                         ret_neon_enabled;
  wire                         ret_neon_target_hit;
  wire                         wfe_expt_exception_pending;
  wire                         wfi_expt_exception_pending;
  wire                         wfx_control_en;
  wire                         wfx_drained;
  wire                         wfx_wakeup;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Event register
  // ------------------------------------------------------

  // The event register
  assign nxt_event_register = (~dpu_clr_event_register_i &   // Clear condition
                               (wfe_event_reg              | // The event register is already set
                                sev_set_event_register_i   | // An EVENTI top-level input or SEV on any CPU in the cluster
                                timer_wfe_event_i          | // An event triggered by the timer for this CPU
                                excl_mon_cleared_i         | // Exclusive monitor is cleared in the CPU
                                clrexmon_rs_i));             // Global exclusive monitor for this CPU is cleared

  // WFE event register must be free running, as it can be set
  // if an external event is received while this core is in WFx
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      wfe_event_reg <= 1'b0;
    else
      wfe_event_reg <= nxt_event_register;

  // ------------------------------------------------------
  // Local registers
  // ------------------------------------------------------

  // These registers can be gated when the CPU is in WFx
  //
  // Note that the following registers must be gated by WFx so that they retain their value
  // correctly during retention:
  //  - cpuectlr_cpu_ret_delay_rs
  //  - cpuectlr_neon_ret_delay_rs
  //  - dbg_double_lock_set_rs
  //  - ns_state_rs
  //  - DPU exception level
  //  - IRQ/FIQ/SEI masked
  //  - WFx VIRQ/VFIQ/VSEI masked
  //  - SCR IRQ/FIQ and ns bits
  //
  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      wfi_req_rs                      <= 1'b0;
      wfe_req_rs                      <= 1'b0;
      standby_is_wfe                  <= 1'b0;
      neon_active_rs                  <= 1'b0;
      cpuectlr_cpu_ret_delay_rs       <= {`CA53_RET_CTL_W{1'b0}};
      cpuectlr_neon_ret_delay_rs      <= {`CA53_RET_CTL_W{1'b0}};
    end
    else begin
      wfi_req_rs                      <= dpu_wfi_req_i;
      wfe_req_rs                      <= dpu_wfe_req_i;
      standby_is_wfe                  <= nxt_standby_is_wfe;
      neon_active_rs                  <= nxt_neon_active_rs;
      cpuectlr_cpu_ret_delay_rs       <= dpu_cpuectlr_cpu_ret_delay_i;
      cpuectlr_neon_ret_delay_rs      <= dpu_cpuectlr_neon_ret_delay_i;
    end

  // These registers are only used while in WFx, so can be sampled on WFx entry
  assign wfx_entry_en = wfi_req_rs | wfe_req_rs;

  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      dbg_double_lock_set_rs  <= 1'b0;
      ns_state_rs             <= 1'b0;
      irq_pended_rs           <= 1'b0;
      fiq_pended_rs           <= 1'b0;
      sei_pended_rs           <= 1'b0;
      irq_masked_rs           <= 1'b0;
      fiq_masked_rs           <= 1'b0;
      sei_masked_rs           <= 1'b0;
      virq_pended_rs          <= 1'b0;
      vfiq_pended_rs          <= 1'b0;
      vsei_pended_rs          <= 1'b0;
      virq_masked_rs          <= 1'b0;
      vfiq_masked_rs          <= 1'b0;
      vsei_masked_rs          <= 1'b0;
    end
    else if (wfx_entry_en) begin
      dbg_double_lock_set_rs  <= dpu_dbg_double_lock_set_i;
      ns_state_rs             <= dpu_ns_state_i;
      irq_pended_rs           <= dpu_irq_pended_i;
      fiq_pended_rs           <= dpu_fiq_pended_i;
      sei_pended_rs           <= dpu_sei_pended_i;
      irq_masked_rs           <= dpu_irq_masked_i;
      fiq_masked_rs           <= dpu_fiq_masked_i;
      sei_masked_rs           <= dpu_sei_masked_i;
      virq_pended_rs          <= dpu_virq_pended_i;
      vfiq_pended_rs          <= dpu_vfiq_pended_i;
      vsei_pended_rs          <= dpu_vsei_pended_i;
      virq_masked_rs          <= dpu_virq_masked_i;
      vfiq_masked_rs          <= dpu_vfiq_masked_i;
      vsei_masked_rs          <= dpu_vsei_masked_i;
    end

  // These registers only need to be clocked when the GIC is enabled
  assign gic_en = ~gov_giccdisable_i;

  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      gov_aarch64_at_el3_o  <= 1'b0;
      gov_exception_level_o <= `CA53_EL3;
      gov_hcr_el2_amo_o     <= 1'b0;
      gov_hcr_el2_fmo_o     <= 1'b0;
      gov_hcr_el2_imo_o     <= 1'b0;
      gov_monitor_mode_o    <= 1'b0;
      gov_scr_el3_fiq_o     <= 1'b0;
      gov_scr_el3_irq_o     <= 1'b0;
      gov_scr_el3_ns_o      <= 1'b0;
    end
    else if (gic_en) begin
      gov_aarch64_at_el3_o  <= dpu_aarch64_at_el3_i;
      gov_exception_level_o <= dpu_exception_level_i;
      gov_hcr_el2_amo_o     <= dpu_hcr_el2_amo_i;
      gov_hcr_el2_fmo_o     <= dpu_hcr_el2_fmo_i;
      gov_hcr_el2_imo_o     <= dpu_hcr_el2_imo_i;
      gov_monitor_mode_o    <= dpu_monitor_mode_i;
      gov_scr_el3_fiq_o     <= dpu_scr_el3_fiq_i;
      gov_scr_el3_irq_o     <= dpu_scr_el3_irq_i;
      gov_scr_el3_ns_o      <= dpu_scr_el3_ns_i;
    end

  // These WFX related registers only need to be clocked when the state machine is operating
  assign wfx_control_en = wfe_req_rs | wfi_req_rs | (wfx_fsm != WFX_FSM_AWAKE) | gov_wfx_wake;

  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov) begin
      stb_wfx_ready_rs         <= 1'b0;
      biu_wfx_ready_rs         <= 1'b0;
      dcu_wfx_ready_rs         <= 1'b0;
      ifu_wfx_ready_rs         <= 1'b0;
      tlb_wfx_ready_rs         <= 1'b0;
      etm_wfx_ready_rs         <= 1'b0;
      scu_wfx_ready_rs         <= 1'b0;
      gov_wfx_drain_req_o      <= 1'b0;
      gov_wfx_wake             <= 1'b0;
      dpu_imp_abort_pending_rs <= 1'b0;
      standbywfe               <= 1'b0;
      ac_valid_rs              <= 1'b0;
      wfx_fsm                  <= WFX_FSM_AWAKE;
    end
    else if (wfx_control_en) begin
      stb_wfx_ready_rs         <= stb_wfx_ready_i;
      biu_wfx_ready_rs         <= biu_wfx_ready_i;
      dcu_wfx_ready_rs         <= dcu_wfx_ready_i;
      ifu_wfx_ready_rs         <= ifu_wfx_ready_i;
      tlb_wfx_ready_rs         <= tlb_wfx_ready_i;
      etm_wfx_ready_rs         <= etm_wfx_ready_i;
      scu_wfx_ready_rs         <= scu_wfx_ready_i;
      gov_wfx_drain_req_o      <= nxt_wfx_drain_req;
      gov_wfx_wake             <= nxt_wfx_wake;
      dpu_imp_abort_pending_rs <= dpu_imp_abort_pending_i;
      standbywfe               <= nxt_standbywfe;
      ac_valid_rs              <= scu_ac_valid_i;
      wfx_fsm                  <= nxt_wfx_fsm;
    end

  // The WFI register must be free-running so that it can move to 1'b0 after reset is deasserted
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      standbywfi <= 1'b1; // Reset to 1'b1 to reflect the value of the CPU after it enters WFI for shut down
    else
      standbywfi <= nxt_standbywfi;

  // ------------------------------------------------------
  // Exception pending generation
  // ------------------------------------------------------

  assign dbg_halt_perm = gov_dbgen_i & (ns_state_rs | gov_spiden_i) & ~dbg_double_lock_set_rs;

  // Identify if there is an exception pending that will require the CPU to
  // be brought out of WFx or prevent it from entering WFx
  assign wfi_expt_exception_pending = ((gov_edbgrq_i              & dbg_halt_perm)   |
                                       (gic_irq_i                 & ~irq_pended_rs)  |
                                       (gic_fiq_i                 & ~fiq_pended_rs)  |
                                       (dpu_imp_abort_pending_rs  & ~sei_pended_rs)  |
                                       (sei_level_req_i           & ~sei_pended_rs)  |
                                       (rei_level_req_i           & ~sei_pended_rs)  |
                                       (gic_virq_i                & ~virq_pended_rs) |
                                       (gic_vfiq_i                & ~vfiq_pended_rs) |
                                       (vsei_level_req_i          & ~vsei_pended_rs));

  assign wfe_expt_exception_pending = ((gov_edbgrq_i              & dbg_halt_perm)                     |
                                       (gic_irq_i                 & ~irq_masked_rs  & ~irq_pended_rs)  |
                                       (gic_fiq_i                 & ~fiq_masked_rs  & ~fiq_pended_rs)  |
                                       (dpu_imp_abort_pending_rs  & ~sei_masked_rs  & ~sei_pended_rs)  |
                                       (sei_level_req_i           & ~sei_masked_rs  & ~sei_pended_rs)  |
                                       (rei_level_req_i           & ~sei_masked_rs  & ~sei_pended_rs)  |
                                       (gic_virq_i                & ~virq_masked_rs & ~virq_pended_rs) |
                                       (gic_vfiq_i                & ~vfiq_masked_rs & ~vfiq_pended_rs) |
                                       (vsei_level_req_i          & ~vsei_masked_rs & ~vsei_pended_rs));

  // ------------------------------------------------------
  // Local control
  // ------------------------------------------------------

  // Select the appropriate wakeup signal depending on the type of standby
  assign wfx_wakeup = standby_is_wfe ? (wfe_event_reg | wfe_expt_exception_pending) : wfi_expt_exception_pending;

  // Checks if the STB, BIU, DCU, IFU, TLB and ETM have been drained and are ready for WFx
  // also factors in the ACVALID signal from the SCU to the CPU so that the clock can be
  // enabled when a snoop must be serviced while in WFx (does not exit WFx)
  // The SCU must drain of all transactions that might send a snoop to the CPU if the CPU
  // has been taken out of coherency. This is so that power cannot be removed until we know
  // no more snoops will be sent to the CPU.
  //
  // Note that unregistered and registered ACVALIDs must be used to ensure that clocking is
  // maintained when in WFI and snooping
  assign wfx_drained = (stb_wfx_ready_rs & biu_wfx_ready_rs & dcu_wfx_ready_rs & ifu_wfx_ready_rs &
                        tlb_wfx_ready_rs & etm_wfx_ready_rs & scu_wfx_ready_rs & ~scu_ac_valid_i & ~ac_valid_rs & ~atvalidm_i & ~apb_bridge_pseldbg_i);

  // ------------------------------------------------------
  // WFx FSM
  // ------------------------------------------------------

  always @*
    begin
      // Defaults
      nxt_standbywfe     = 1'b0;
      nxt_standbywfi     = 1'b0;
      nxt_wfx_drain_req  = 1'b0;
      nxt_wfx_wake       = 1'b0;
      nxt_standby_is_wfe = standby_is_wfe;
      gate_clk_req_o     = 1'b0;

      case (wfx_fsm)
        WFX_FSM_AWAKE : begin
          nxt_wfx_fsm        = (wfe_req_rs | wfi_req_rs) ? WFX_FSM_DRAIN : WFX_FSM_AWAKE;
          nxt_standby_is_wfe =  wfe_req_rs;                             // Record whether this is WFE or WFI standby
        end

        WFX_FSM_DRAIN : begin
          nxt_wfx_fsm        = wfx_wakeup  ? WFX_FSM_AWAKE   :
                               wfx_drained ? WFX_FSM_STANDBY :
                                             WFX_FSM_DRAIN;
          nxt_wfx_drain_req  = ~wfx_wakeup;                             // Request all units to drain
          nxt_wfx_wake       =  wfx_wakeup;                             // Keep the DPU stalled
        end

        WFX_FSM_STANDBY : begin
          nxt_wfx_fsm        = wfx_wakeup ? WFX_FSM_RESTART : WFX_FSM_STANDBY;
          nxt_standbywfe     =  standby_is_wfe;                         // Signal WFE
          nxt_standbywfi     = ~standby_is_wfe;                         // Signal WFI
          gate_clk_req_o     = (wfx_drained |                           // Gate the clock, but allow activation in this state for snoops
                                (ret_cpu_fsm == RET_CPU_FSM_IN_RET) |   // Force the clock to be gated if in retention,
                                (ret_cpu_fsm == RET_CPU_FSM_RET_EXIT)); // or exiting from retention
        end

        WFX_FSM_RESTART : begin
          nxt_wfx_fsm        = ((ret_cpu_fsm == RET_CPU_FSM_IN_RET) |
                                (ret_cpu_fsm == RET_CPU_FSM_RET_EXIT)) ? WFX_FSM_RESTART : WFX_FSM_AWAKE;
          nxt_standbywfe     =  standby_is_wfe;                         // Continue signalling WFE until retention exit
          nxt_standbywfi     = ~standby_is_wfe;                         // Continue signalling WFI until retention exit
          nxt_wfx_wake       = 1'b1; // Send a wake signal to the DPU
          gate_clk_req_o     = ((ret_cpu_fsm == RET_CPU_FSM_IN_RET) |
                                (ret_cpu_fsm == RET_CPU_FSM_RET_EXIT));
        end

        default : begin
          nxt_wfx_fsm        = 2'bxx;
          nxt_standbywfe     = 1'bx;
          nxt_standbywfi     = 1'bx;
          nxt_wfx_drain_req  = 1'bx;
          nxt_wfx_wake       = 1'bx;
          nxt_standby_is_wfe = 1'bx;
          gate_clk_req_o     = 1'bx;
        end
      endcase
    end

  // ------------------------------------------------------
  // CPU retention
  // ------------------------------------------------------

  // Regionally gate if retention is not enabled.  Also have to deal with reset condition
  // and spurious powerdown requests when retention is disabled.
  assign nxt_ret_cpu_clock_en = (cpuectlr_cpu_ret_delay_rs[2:0] != 3'b000) | (ret_cpu_fsm != RET_CPU_FSM_IDLE) | ~cpuqreqn_rs;

  always @(posedge CLKIN or negedge reset_n_gov)
    if (!reset_n_gov)
      ret_cpu_clock_en <= 1'b1;
    else
      ret_cpu_clock_en <= nxt_ret_cpu_clock_en;

  ca53_cell_inter_clkgate u_inter_clkgate_ret_cpu (.clk_i         (CLKIN),
                                                   .clk_enable_i  (ret_cpu_clock_en),
                                                   .clk_senable_i (DFTSE),
                                                   .clk_gated_o   (clk_ret_cpu));

  // Status of WFX state machine
  //
  // We need to be able to service snoops to the CPU while in WFI.  While we won't leave WFI, we must
  // wake from retention.  The best way to achieve this is to hold off retention entry if haven't entered
  // yet and to exit from retention if we are already there.  This approach means that the entire entry
  // process must be restarted, but favours performance of snoops.
  //
  // The ACVALID signal will remain asserted until the snoop has been serviced so we can use it to
  // trigger retention exit, prevent entry and set a new target value.
  //
  // We also need to wakeup the CPU from retention if the APB bridge signals PSEL which occurs when an
  // external debugger is attempting to make a connection
  assign cpu_exit_retention = (wfx_fsm != WFX_FSM_STANDBY) | ~scu_wfx_ready_rs | scu_ac_valid_i | ac_valid_rs | apb_bridge_pseldbg_i;

  // CPU retention enabled
  assign ret_cpu_enabled = cpuectlr_cpu_ret_delay_rs[2:0] != 3'b000;

  // Trigger the start of the retention entry process when idle
  assign ret_cpu_count_start = ret_cpu_enabled                   &
                               (ret_cpu_fsm == RET_CPU_FSM_IDLE) &
                               (wfx_fsm == WFX_FSM_STANDBY)      &
                               ~wfx_wakeup                       &
                               wfx_drained;

  // Create a target retention value for when retention entry should begin.  This approach
  // means we only have to set the registers once and only toggle the adder once.
  assign nxt_ret_cpu_target_value = ({10{ret_cpu_count_start}} & cntvalueb_rs_i[9:0]) + {(cpuectlr_cpu_ret_delay_rs[2:0] == 3'b111), // 512 Timer Ticks
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b110), // 256 Timer Ticks
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b101), // 128 Timer Ticks
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b100), //  64 Timer Ticks
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b011), //  32 Timer Ticks
                                                                                         1'b0,
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b010), //   8 Timer Ticks
                                                                                         1'b0,
                                                                                         (cpuectlr_cpu_ret_delay_rs[2:0] == 3'b001), //   2 Timer Ticks
                                                                                         1'b0};

  // Capture the target retention value
  always @(posedge clk_ret_cpu or negedge reset_n_gov)
    if (~reset_n_gov)
      ret_cpu_target_value <= {10{1'b0}};
    else if (ret_cpu_count_start)
      ret_cpu_target_value <= nxt_ret_cpu_target_value;

  // Signal that the counter value has hit the target retention value
  assign ret_cpu_target_hit = (ret_cpu_fsm == RET_CPU_FSM_WAIT_COUNT) & ret_cpu_target_value[9:0] == cntvalueb_rs_i[9:0];

  // Retention state machine
  //
  always @*
    begin
      // Defaults
      nxt_cpuqactive  = 1'b1;
      nxt_cpuqdeny    = ~cpuqreqn_rs; // By default, QDENY is asserted for any QREQn requests until we are ready to signal QACCEPTn
      nxt_cpuqacceptn = 1'b1;

      case (ret_cpu_fsm)
        RET_CPU_FSM_RESET : begin
          // The reset state is:
          //  - QACCEPTn & QDENY reset low
          //  - QACTIVE reset high
          //  - QREQn can be reset to any state
          nxt_ret_cpu_fsm = cpuqreqn_rs ? RET_CPU_FSM_IDLE : RET_CPU_FSM_RESET; // Stay in reset state while QREQn is low
          nxt_cpuqactive  = 1'b1;                                               // Maintain QACTIVE high reset state
          nxt_cpuqacceptn = cpuqreqn_rs;                                        // If QREQn resets high then transition QACCEPTn high, otherwise hold in reset low state
          nxt_cpuqdeny    = 1'b0;                                               // Maintain QDENY low reset state
        end

        RET_CPU_FSM_IDLE : begin
          // Wait in this state until we are ready to start the retention entry process.
          nxt_ret_cpu_fsm = ret_cpu_count_start ? RET_CPU_FSM_WAIT_COUNT : RET_CPU_FSM_IDLE;
        end

        RET_CPU_FSM_WAIT_COUNT : begin
          // Wait in this state until the target counter value is hit.  If the WFx state machine drops
          // out of WFx then move back to idle.
          nxt_ret_cpu_fsm = cpu_exit_retention ? RET_CPU_FSM_IDLE      :
                            ret_cpu_target_hit ? RET_CPU_FSM_WAIT_NEON : RET_CPU_FSM_WAIT_COUNT;
        end

        RET_CPU_FSM_WAIT_NEON : begin
          // Wait in this state until NEON is in retention.  If NEON is disabled we'll transition through
          // this state in one cycle.  If the WFx state machine drops out of WFx then move back to idle.
          nxt_ret_cpu_fsm = cpu_exit_retention                      ? RET_CPU_FSM_IDLE    :
                            (~ret_neon_enabled | neon_in_retention) ? RET_CPU_FSM_RET_REQ : RET_CPU_FSM_WAIT_NEON;
        end

        RET_CPU_FSM_RET_REQ : begin
          // Wait in this state until the external power controller sends the QREQn response.  If the WFx
          // state machine drops out of WFx then move back to idle (which will happen if the power controller
          // never deasserts QREQn).  Once QREQn is asserted either accept and move in to retention or deny
          // and move back to idle.
          nxt_ret_cpu_fsm =  cpu_exit_retention                       ? RET_CPU_FSM_IDLE    :
                            (cpuqreqn_rs | (~cpuqreqn_rs & cpuqdeny)) ? RET_CPU_FSM_RET_REQ : RET_CPU_FSM_IN_RET;
          nxt_cpuqactive  =  cpu_exit_retention;
          nxt_cpuqacceptn =  cpu_exit_retention | cpuqdeny  |  cpuqreqn_rs;
          nxt_cpuqdeny    = (cpu_exit_retention | cpuqdeny) & ~cpuqreqn_rs;
        end

        RET_CPU_FSM_IN_RET : begin
          // Wait in this state until a retention exit event occurs or the power controller requests exit
          nxt_ret_cpu_fsm = (cpuqreqn_rs | cpu_exit_retention) ? RET_CPU_FSM_RET_EXIT : RET_CPU_FSM_IN_RET;
          nxt_cpuqactive  = (cpuqreqn_rs | cpu_exit_retention);
          nxt_cpuqacceptn =  cpuqreqn_rs;
          nxt_cpuqdeny    = 1'b0;
        end

        RET_CPU_FSM_RET_EXIT : begin
          // Wait in this state until QREQn is asserted
          nxt_ret_cpu_fsm = cpuqreqn_rs ? RET_CPU_FSM_IDLE : RET_CPU_FSM_RET_EXIT;
          nxt_cpuqactive  = 1'b1;
          nxt_cpuqacceptn = cpuqreqn_rs;
          nxt_cpuqdeny    = 1'b0;
        end

        default : begin
          nxt_ret_cpu_fsm = {RET_CPU_FSM_W{1'bx}};
          nxt_cpuqactive  = 1'bx;
          nxt_cpuqacceptn = 1'bx;
          nxt_cpuqdeny    = 1'bx;
        end
      endcase
    end

  // CPU retention control registers
  //
  // Note that a reset will result in the state machine moving to the reset state.  In reality if a reset has
  // occured while a CPU is in retention any of the dirty state in the cache has been lost.  However the retention
  // state machine is robust in that it will handshake to exit retention (RET_CPU_FSM_RESET == RET_CPU_FSM_RET_EXIT).
  // The external reset controller must hold reset until the CPU has exited retention and the state can be
  // initialised.
  assign ret_cpu_ctl_en = nxt_standbywfi | nxt_standbywfe | (ret_cpu_fsm != RET_CPU_FSM_IDLE);

  always @(posedge clk_ret_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      ret_cpu_fsm   <= RET_CPU_FSM_RESET;
      cpuqactive_o  <= 1'b1;
      cpuqacceptn_o <= 1'b0;
    end
    else if (ret_cpu_ctl_en) begin
      ret_cpu_fsm   <= nxt_ret_cpu_fsm;
      cpuqactive_o  <= nxt_cpuqactive;
      cpuqacceptn_o <= nxt_cpuqacceptn;
    end

  // QREQn will not have a defined value at CPU reset and must be free running to initialise the state machine
  // QREQn is synchronised to assist the timing path coming in to the cluster from the system
  ca53_cell_sync u_ca53_cell_sync0 (.out_o    (cpuqreqn_rs),
                                    .clk_i    (CLKIN),
                                    .inp_i    (cpuqreqn_i),
                                    .resetn_i (1'b1));

  // QDENY must be in a free-running register so that we can deny spurious QREQn requests from the power controller
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      cpuqdeny <= 1'b0;
    else
      cpuqdeny <= nxt_cpuqdeny;

  // Indicate to the debug over power down block that the CPU is in retention (or in the final entry/exit process)
  // so that PREADY can be held off until power has been returned and a connection to the debugger can be made.
  assign cpu_in_retention_o = ((ret_cpu_fsm == RET_CPU_FSM_RET_REQ) |
                               (ret_cpu_fsm == RET_CPU_FSM_IN_RET) |
                               (ret_cpu_fsm == RET_CPU_FSM_RET_EXIT));

  // ------------------------------------------------------
  // NEON retention
  // ------------------------------------------------------

  // Regionally gate if retention is not enabled.  Also have to deal with reset condition
  // and spurious powerdown requests when retention is disabled.
  assign nxt_ret_neon_clock_en = ret_neon_enabled | (ret_neon_fsm != RET_NEON_FSM_IDLE) | ~neonqreqn_rs;

  always @(posedge CLKIN or negedge reset_n_gov)
    if (!reset_n_gov)
      ret_neon_clock_en <= 1'b1;
    else
      ret_neon_clock_en <= nxt_ret_neon_clock_en;

  ca53_cell_inter_clkgate u_inter_clkgate_ret_neon (.clk_i         (CLKIN),
                                                    .clk_enable_i  (ret_neon_clock_en),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_ret_neon));

  // Hold the NEON active signal high while it is genuinely active or when the CPUECTLR is disabled.
  // This ensures that a trigger condition occurs when retention is enabled as well as when the NEON block
  // goes quiet.
  //
  // If the CPU enters WFE or WFI then suppress the NEON active signal since there could be a NEON instruction
  // in the shadow of WFx.
  assign nxt_neon_active_rs = (dpu_neon_active_i | ~ret_neon_enabled) & ~nxt_standbywfe & ~nxt_standbywfi;

  // NEON retention enabled
  assign ret_neon_enabled = cpuectlr_neon_ret_delay_rs[2:0] != 3'b000;

  // Trigger the start of the retention entry process when Neon is idle or the processor is in WFx
  assign ret_neon_count_start = ret_neon_enabled                    &
                                (ret_neon_fsm == RET_NEON_FSM_IDLE) &
                                ((wfx_fsm == WFX_FSM_STANDBY) |
                                 ~neon_active_rs);

  // Create a target retention value for when retention entry should begin.  This approach
  // means we only have to set the registers once and only toggle the adder once.
  assign nxt_ret_neon_target_value = ({10{ret_neon_count_start}} & cntvalueb_rs_i[9:0]) + {(cpuectlr_neon_ret_delay_rs[2:0] == 3'b111), // 512 Timer Ticks
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b110), // 256 Timer Ticks
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b101), // 128 Timer Ticks
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b100), //  64 Timer Ticks
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b011), //  32 Timer Ticks
                                                                                           1'b0,
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b010), //   8 Timer Ticks
                                                                                           1'b0,
                                                                                           (cpuectlr_neon_ret_delay_rs[2:0] == 3'b001), //   2 Timer Ticks
                                                                                           1'b0};

  // Capture the target retention value
  always @(posedge clk_ret_neon or negedge reset_n_gov)
    if (~reset_n_gov)
      ret_neon_target_value <= {10{1'b0}};
    else if (ret_neon_count_start)
      ret_neon_target_value <= nxt_ret_neon_target_value;

  // Signal that the counter value has hit the target retention value
  assign ret_neon_target_hit = (ret_neon_fsm == RET_NEON_FSM_WAIT_COUNT) & ret_neon_target_value[9:0] == cntvalueb_rs_i[9:0];

  // Retention state machine
  always @*
    begin
      // Defaults
      nxt_neonqactive       = 1'b1;
      nxt_neonqdeny         = ~neonqreqn_rs; // By default, QDENY is asserted for any QREQn requests until we are ready to signal QACCEPTn
      nxt_neonqacceptn      = 1'b1;
      nxt_stall_neon        = 1'b0;
      nxt_neon_in_retention = 1'b0;

      case (ret_neon_fsm)
        RET_NEON_FSM_RESET : begin
          nxt_ret_neon_fsm = neonqreqn_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_RESET; // Stay in reset state while QREQn is low
          nxt_neonqactive  = 1'b1;                                                  // Maintain QACTIVE high reset state
          nxt_neonqacceptn = neonqreqn_rs;                                          // If QREQn resets high then transition QACCEPTn high, otherwise hold in reset low state
          nxt_neonqdeny    = 1'b0;                                                  // Maintain QDENY low reset state
        end

        RET_NEON_FSM_IDLE : begin
          // Wait in this state until we are ready to start the retention entry process.
          nxt_ret_neon_fsm = ret_neon_count_start ? RET_NEON_FSM_WAIT_COUNT : RET_NEON_FSM_IDLE;
        end

        RET_NEON_FSM_WAIT_COUNT : begin
          // Wait in this state until the target counter value is hit.  If NEON becomes active again
          // then move back to idle.
          nxt_ret_neon_fsm = neon_active_rs      ? RET_NEON_FSM_IDLE         :
                             ret_neon_target_hit ? RET_NEON_FSM_WAIT_STALL_1 : RET_NEON_FSM_WAIT_COUNT;
        end

        // Wait for the stall signal to propagate to the DPU to prevent a boundary condition where a NEON
        // instruction is about to execute and will miss the stall.  This ensures that even if QREQn is
        // already low and retention entry will be almost immediate any NEON instructions will either
        // be stalled or prevent retention entry.
        RET_NEON_FSM_WAIT_STALL_1 : begin
          nxt_ret_neon_fsm = neon_active_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_WAIT_STALL_2;
          nxt_stall_neon   = 1'b1;
        end
        RET_NEON_FSM_WAIT_STALL_2 : begin
          nxt_ret_neon_fsm = neon_active_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_WAIT_STALL_3;
          nxt_stall_neon   = 1'b1;
        end
        RET_NEON_FSM_WAIT_STALL_3 : begin
          nxt_ret_neon_fsm = neon_active_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_WAIT_STALL_4;
          nxt_stall_neon   = 1'b1;
        end
        RET_NEON_FSM_WAIT_STALL_4 : begin
          nxt_ret_neon_fsm = neon_active_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_RET_REQ;
          nxt_stall_neon   = 1'b1;
        end

        RET_NEON_FSM_RET_REQ : begin
          // Wait in this state until the external power controller sends the QREQn response.  If NEON becomes
          // active again then move back to idle (which will happen if the power controller never deasserts QREQn).
          // Once QREQn is asserted either accept and move in to retention or deny and move back to idle.
          //
          // If QREQn was low when we arrived in this state then QDENY would also have been asserted.  This means
          // we need to wait for QREQn to go high and QDENY deassert before we can go through a legal retention
          // request.
          nxt_ret_neon_fsm =  neon_active_rs                              ? RET_NEON_FSM_IDLE    :
                             (neonqreqn_rs | (~neonqreqn_rs & neonqdeny)) ? RET_NEON_FSM_RET_REQ : RET_NEON_FSM_IN_RET;
          nxt_neonqactive  =  neon_active_rs;
          nxt_neonqacceptn =  neon_active_rs | neonqdeny  |  neonqreqn_rs;
          nxt_neonqdeny    = (neon_active_rs | neonqdeny) & ~neonqreqn_rs;
          nxt_stall_neon   = 1'b1;
        end

        RET_NEON_FSM_IN_RET : begin
          // Wait in this state until a retention exit event occurs or the power controller requests exit
          nxt_ret_neon_fsm      = (neonqreqn_rs | neon_active_rs) ? RET_NEON_FSM_RET_EXIT : RET_NEON_FSM_IN_RET;
          nxt_neonqactive       = (neonqreqn_rs | neon_active_rs);
          nxt_neonqacceptn      =  neonqreqn_rs;
          nxt_neonqdeny         = 1'b0;
          nxt_stall_neon        = 1'b1;
          nxt_neon_in_retention = 1'b1;
        end

        RET_NEON_FSM_RET_EXIT : begin
          // Wait in this state until QREQn is asserted
          nxt_ret_neon_fsm      = neonqreqn_rs ? RET_NEON_FSM_IDLE : RET_NEON_FSM_RET_EXIT;
          nxt_neonqactive       = 1'b1;
          nxt_neonqacceptn      = neonqreqn_rs;
          nxt_neonqdeny         = 1'b0;
          nxt_stall_neon        = 1'b1;
          nxt_neon_in_retention = 1'b1;
        end

        default : begin
          nxt_ret_neon_fsm      = {RET_NEON_FSM_W{1'bx}};
          nxt_neonqactive       = 1'bx;
          nxt_neonqacceptn      = 1'bx;
          nxt_neonqdeny         = 1'bx;
          nxt_stall_neon        = 1'bx;
          nxt_neon_in_retention = 1'bx;
        end
      endcase
    end

  // CPU retention control registers
  assign ret_neon_ctl_en = (~neon_active_rs | (ret_neon_fsm != RET_NEON_FSM_IDLE)) | stall_neon;

  always @(posedge clk_ret_neon or negedge reset_n_gov)
    if (~reset_n_gov) begin
      ret_neon_fsm      <= RET_NEON_FSM_RESET;
      neonqactive_o     <= 1'b1;
      neonqacceptn_o    <= 1'b0;
      stall_neon        <= 1'b0;
      neon_in_retention <= 1'b0;
    end
    else if (ret_neon_ctl_en) begin
      ret_neon_fsm      <= nxt_ret_neon_fsm;
      neonqactive_o     <= nxt_neonqactive;
      neonqacceptn_o    <= nxt_neonqacceptn;
      stall_neon        <= nxt_stall_neon;
      neon_in_retention <= nxt_neon_in_retention;
    end

  // QREQn will not have a defined value at reset and must be free running to initialise the state machine
  // QREQn is synchronised to assist the timing path coming in to the cluster from the system
  ca53_cell_sync u_ca53_cell_sync1 (.out_o    (neonqreqn_rs),
                                    .clk_i    (CLKIN),
                                    .inp_i    (neonqreqn_i),
                                    .resetn_i (1'b1));

  // QDENY must be in a free-running register so that we can deny spurious QREQn requests from the power controller
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      neonqdeny <= 1'b0;
    else
      neonqdeny <= nxt_neonqdeny;

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  assign gov_wfx_wake_o   = gov_wfx_wake;
  assign gov_event_reg_o  = wfe_event_reg;
  assign gov_standbywfi_o = standbywfi;
  assign gov_standbywfe_o = standbywfe;
  assign gov_stall_neon_o = stall_neon;
  assign cpuqdeny_o       = cpuqdeny;
  assign neonqdeny_o      = neonqdeny;
  assign event_cpu_ret_o  = ret_cpu_fsm == RET_CPU_FSM_IN_RET;
  assign event_neon_ret_o = ret_neon_fsm == RET_NEON_FSM_IN_RET;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_cpu_count_start")
  u_ovl_x_ret_cpu_count_start (.clk       (CLKIN),
                               .reset_n   (reset_n_gov),
                               .qualifier (1'b1),
                               .test_expr (ret_cpu_count_start));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_cpu_ctl_en")
  u_ovl_x_ret_cpu_ctl_en (.clk       (CLKIN),
                          .reset_n   (reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (ret_cpu_ctl_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_neon_count_start")
  u_ovl_x_ret_neon_count_start (.clk       (CLKIN),
                                .reset_n   (reset_n_gov),
                                .qualifier (1'b1),
                                .test_expr (ret_neon_count_start));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_neon_ctl_en")
  u_ovl_x_ret_neon_ctl_en (.clk       (CLKIN),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (ret_neon_ctl_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wfx_entry_en")
  u_ovl_x_wfx_entry_en (.clk       (CLKIN),
                        .reset_n   (reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (wfx_entry_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gic_en")
  u_ovl_x_gic_en (.clk       (CLKIN),
                  .reset_n   (reset_n_gov),
                  .qualifier (1'b1),
                  .test_expr (gic_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wfx_control_en")
  u_ovl_x_wfx_control_en (.clk       (CLKIN),
                          .reset_n   (reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (wfx_control_en));

  //----------------------------------------------------------------------------
  // State machine X-Checks
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "State-machine: nxt_wfx_fsm x-check")
  u_ovl_x_nxt_wfx_fsm (.clk       (CLKIN),
                       .reset_n   (reset_n_gov),
                       .qualifier (1'b1),
                       .test_expr (nxt_wfx_fsm[1:0]));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "State-machine: nxt_ret_cpu_fsm x-check")
  u_ovl_x_nxt_ret_cpu_fsm (.clk       (CLKIN),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (nxt_ret_cpu_fsm[2:0]));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "State-machine: nxt_ret_neon_fsm x-check")
  u_ovl_x_nxt_ret_neon_fsm (.clk       (CLKIN),
                            .reset_n   (reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (nxt_ret_neon_fsm[3:0]));

  //----------------------------------------------------------------------------
  // State machine illegal state checks
  //----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal state: ret_cpu_fsm")
  u_ovl_ret_cpu_fsm_ill (.clk       (CLKIN),
                         .reset_n   (reset_n_gov),
                         .test_expr (ret_cpu_fsm[2:0] == 3'b111));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal state: ret_neon_fsm")
  u_ovl_ret_neon_fsm_ill (.clk       (CLKIN),
                          .reset_n   (reset_n_gov),
                          .test_expr ((ret_neon_fsm[3:0] == 4'b1010) |
                                      (ret_neon_fsm[3:0] == 4'b1011) |
                                      (ret_neon_fsm[3:0] == 4'b1100) |
                                      (ret_neon_fsm[3:0] == 4'b1101) |
                                      (ret_neon_fsm[3:0] == 4'b1110) |
                                      (ret_neon_fsm[3:0] == 4'b1111)));

`endif

endmodule // ca53governor_cpu_power

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
