//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
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

//
// Overview
// ========
//

// ETM View Instruction
// This block does the following operations:
// 1) View Inst enable logic.
// 2) Idle State Machine for trace.
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_viewinst (



//
// Interface Signals
// =================
//

// Global inputs
  input wire          clk_gated,                                      // CPU clock
  input wire          po_reset_n,                                     // Power on reset

// Inputs
  input wire          viewinst_write_i,                               // ViewInst register write
  input wire  [4:0]   viewinst_event_reg_i,                           // View Instruction Event
  input wire  [2:0]   viewinst_exlevel_ns_reg_i,                      // ViewInst Non Secure Exception Level Disable
  input wire  [2:0]   viewinst_exlevel_s_reg_i,                       // ViewInst Secure Exception Level Disable
  input wire  [3:0]   viewinst_inc_ranges_reg_i,                      // View Instruction Exclude Control Enable
  input wire  [3:0]   viewinst_exc_ranges_reg_i,                      // View Instruction Control ARC
  input wire  [7:0]   viewinst_stop_cmp_reg_i,                        // View Instruction Stop SAC
  input wire  [7:0]   viewinst_start_cmp_reg_i,                       // View Instruction Start SAC
  input wire          apb_pwdatadbg_9_i,                              // ViewInst Start Stop write value

  input wire          bb_mode_reg_i,                                  // Branch Broadcast ARC Include/Exclude mode
  input wire  [3:0]   bb_range_reg_i,                                 // Branch Broadcast ARC

  input wire  [22:2]  evt_resources_t2_i,                             // Resource Bus
  input wire          comp0_match_t2_i,                               // SAC 0 match
  input wire          comp1_match_t2_i,                               // SAC 1 match
  input wire          comp2_match_t2_i,                               // SAC 2 match
  input wire          comp3_match_t2_i,                               // SAC 3 match
  input wire          comp4_match_t2_i,                               // SAC 4 match
  input wire          comp5_match_t2_i,                               // SAC 5 match
  input wire          comp6_match_t2_i,                               // SAC 6 match
  input wire          comp7_match_t2_i,                               // SAC 7 match
  input wire          range0_match_t2_i,                              // ARC 0 include match
  input wire          range1_match_t2_i,                              // ARC 1 include match
  input wire          range2_match_t2_i,                              // ARC 2 include match
  input wire          range3_match_t2_i,                              // ARC 3 include match
  input wire          range0_excl_t2_i,                               // ARC 0 exclude match
  input wire          range1_excl_t2_i,                               // ARC 1 exclude match
  input wire          range2_excl_t2_i,                               // ARC 2 exclude match
  input wire          range3_excl_t2_i,                               // ARC 3 exclude match

  input wire          wpt_valid_t1_i,                                 // Valid waypoint
  input wire          wpt_valid_t2_i,                                 // Valid waypoint
  input wire          wpt_adv_t2_i,                                   // Instructions executed between waypoints
  input wire  [3:0]   wpt_exlevel_t2_i,                               // Waypoint exception level
  input wire          wpt_non_secure_t2_i,                            // Waypoint target non secure state
  input wire          wpt_dbg_entry_t2_i,                             // Waypoint for Debug Entry
  input wire          wpt_dbg_exit_t2_i,                              // Waypoint for Debug Exit
  input wire          wpt_prohibited_t2_i,                            // Prohibited region

  input wire          trace_enable_reg_i,                             // Trace Enable from Control register
  input wire          etm_oslock_i,                                   // ETM OS Lock Status
  input wire          gov_dbgen_i,
  input wire          gov_niden_i,
  input wire          auxctlr_frc_idleack_reg_i,
  input wire          auxctlr_frc_auth_noflush_reg_i,
  input wire          gov_wfx_drain_req_t2_i,                         // WFX Entry request from Core
  input wire          trcgen_idle_ack_i,                              // Tracegen in idle state

  input wire          lp_override_reg_i,                              // low power state override register
  input wire          trace_overflow_i,
  input wire          fifo_idle_ack_i,                                // Idle Acknowledgement from FIFO. Safe to de-assert idle req
  input wire          at_idle_ack_i,                                  // Idle Acknowledgement from ATCLK. ATB FIFO is empty
  input wire          at_active_state_i,                              // ATCLK Idle stae machine in Active State. ATB i/f is active

// Outputs
  output wire         viewinst_en_t2_o,                               // View Instruction Enable aka Trace Active
  output wire         viewinst_sstatus_o,                             // Start Stop bit read value in Status Register
  output wire         trace_active_1st_wpt_t4_o,                      // 1st wpt after trace enabled

  output wire         bb_en_t2_o,                                     // Branch Broadcast Enable
  output wire         viewinst_idle_req_t2_o,                         // Idle Request to trace gen
  output wire         resource_active_t2_o,                           // Resource control
  output wire         trace_req_t0_o,                                 // Primary trace control
  output wire         wfx_resource_t3_o,                              // WFX state entered
  output wire         fifo_idle_req_t2_o,                             // Idle request so that FIFO can drain
  output wire         core_at_main_run_t2_o,                          // ETM Main State Machine Running state to ATCLK state machine

  output wire         trcstatr_idle_o,                                // Idle status bit in trace status register

  output wire         etm_wfx_ready_o                                 // ETM Idle (i.e WFX ) ACK Output Signal

 );

//IDLE request state machine states
localparam CA53_ETM_ST_IDLE       =3'b000;
localparam CA53_ETM_ST_RUN        =3'b001;
localparam CA53_ETM_ST_TRC_STOP   =3'b010;
localparam CA53_ETM_ST_PIPEWAIT0  =3'b011;
localparam CA53_ETM_ST_PIPEWAIT1  =3'b100;
localparam CA53_ETM_ST_FIFO_FLUSH =3'b101;
localparam CA53_ETM_ST_FIFO_RESET =3'b110;
localparam CA53_ETM_ST_UNUSED     =3'b111;


  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           core_at_main_run_t1;
  reg            core_at_main_run_t2;
  wire           viewinst_idle_req_t1;
  reg            viewinst_idle_req_t2;
  wire [  1:  0] dbgniden_flush_t2;
  wire           dbgniden_flush_req_t3;
  reg  [  1:  0] dbgniden_flush_t3;
  reg            gov_niden_t1;
  reg            gov_dbgen_t1;
  wire           gov_auth_en_t1;
  reg            et_idle_ack_q;
  wire           et_idle_ack;
  wire           idle_removed;
  reg            idle_removed_q;
  wire           idle_state_control_t2;
  reg  [  2:  0] idle_state_t0;
  reg  [  2:  0] idle_state_t1;
  wire           trace_been_active;
  reg            trace_been_active_q;
  wire           include_exclude_arc_t2;
  wire           main_idle_req_t2;
  wire           start_enable_t2;
  wire           start_match_t2;
  wire           start_stop_reg_t2;
  reg            start_stop_reg_t3;
  wire           start_stop_state_t2;
  wire           start_stop_t2;
  reg            start_stop_t3;
  reg            stop_match_next_t3;
  wire           stop_match_t2;
  wire           trace_active_1st_wpt_t2;
  reg            trace_active_1st_wpt_t3;
  reg            trace_active_1st_wpt_t4;
  wire           resource_active_t2;
  wire           trace_req_t0;
  wire           trace_prog_enabled_t0;
  wire           viewinst_by_wpt_t2;
  reg            viewinst_by_wpt_t3;
  wire           viewinst_condition_t2;
  wire           viewinst_en_t2;
  wire           viewinst_event_t2;
  reg            viewinst_event_t3;
  wire           viewinst_exlevel_t1;
  reg            viewinst_exlevel_t2;
  wire           wpt_no_trace_t2;
  reg            wpt_no_trace_t3;
  wire           wfx_resource_t2;
  reg            wfx_resource_t3;
  reg            trace_wait_idle_t2;
  reg            trace_wait_idle_t1;
  wire           trace_wait_idle_t0;
  wire           trcstatr_idle;


//
// Main Code
// =========
//

// Trace is enabled whenever trace enable bit in control register is set
// and OS Lock is not set
  assign gov_auth_en_t1        = gov_dbgen_t1 | gov_niden_t1;
  assign trace_prog_enabled_t0 = trace_enable_reg_i & ~etm_oslock_i;
  assign trace_req_t0          = trace_prog_enabled_t0 & gov_auth_en_t1 & ~trace_wait_idle_t2;
  assign resource_active_t2    = core_at_main_run_t2 & ~viewinst_idle_req_t2 & ~trace_wait_idle_t2;


  assign trace_wait_idle_t0 = (~gov_auth_en_t1 | etm_oslock_i | ~trace_enable_reg_i | trace_wait_idle_t1) & ~trcstatr_idle;
  always @(posedge clk_gated or negedge po_reset_n)
  begin: u_trace_wait_idle_t2
    if (!po_reset_n) begin
      trace_wait_idle_t1 <= 1'b1;
      trace_wait_idle_t2 <= 1'b1;
    end
    else begin
      trace_wait_idle_t1 <= trace_wait_idle_t0;
      trace_wait_idle_t2 <= trace_wait_idle_t1;
    end
  end


//---------------------------------------------------------------------------
// ViewInst Security State and Exception Level Control
//---------------------------------------------------------------------------

  assign viewinst_exlevel_t1 = (wpt_non_secure_t2_i) ?
                               ~|(viewinst_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]) :                          // Non secure exception level match
                               ~|(viewinst_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});      // Secure exception level match

  always @(posedge clk_gated)
  begin: uviewinst_exlevel_t2
    if (wpt_valid_t1_i)
      viewinst_exlevel_t2 <= viewinst_exlevel_t1;
  end


//---------------------------------------------------------------------------
// ViewInst Enable Event
//---------------------------------------------------------------------------
  ca53etm_event u_viewinst_event (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (viewinst_event_reg_i[4]),
    .event_sel_i        (viewinst_event_reg_i[3:0]),

    .event_out_o        (viewinst_event_t2)
  );

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uviewinst_event_t3
    if (!po_reset_n)
      viewinst_event_t3 <= 1'b0;
    else
      viewinst_event_t3 <= viewinst_event_t2;
  end

//---------------------------------------------------------------------------
// View Inst Start Stop block
//
// Start Stop block is controlled by Single Address Comparators.
//
// If a block has start point(s) then
//    1) Trace that block
//
// If a block has stop point(s) and startstop is already on then
//    1) Trace that block
//    2) Do not trace next block unless there is a start point in next block
//
// If a block has both start point(s) and stop point(s) then
//    1) Trace that block and
//    2) Do not trace next block unless there is a start point in next block
//---------------------------------------------------------------------------

  assign start_match_t2 = |(viewinst_start_cmp_reg_i[7:0] & {comp7_match_t2_i,
                                                             comp6_match_t2_i,
                                                             comp5_match_t2_i,
                                                             comp4_match_t2_i,
                                                             comp3_match_t2_i,
                                                             comp2_match_t2_i,
                                                             comp1_match_t2_i,
                                                             comp0_match_t2_i});

  assign stop_match_t2  = |(viewinst_stop_cmp_reg_i[7:0] &  {comp7_match_t2_i,
                                                             comp6_match_t2_i,
                                                             comp5_match_t2_i,
                                                             comp4_match_t2_i,
                                                             comp3_match_t2_i,
                                                             comp2_match_t2_i,
                                                             comp1_match_t2_i,
                                                             comp0_match_t2_i});

// Start stop status in View Inst register
// If stop seen this cycle then clear start_stop_reg_t3 on next cycle
// unless there is a new start on next cycle.
  assign start_stop_reg_t2 = (viewinst_write_i & apb_pwdatadbg_9_i) |              // APB Register write value or
                             (start_match_t2);                                     // Start seen this cycle.

// Start Stop state for View Inst enable
  assign start_stop_t2 = (viewinst_write_i & apb_pwdatadbg_9_i) |                  // APB Register write value or
                         (start_match_t2 & ~stop_match_t2);                        // Trace Enabled with Start and no Stop. Hold it on for next cycle.

  assign start_stop_state_t2 = start_stop_t3 |                                     // Hold condition true from previous cycle or
                               start_match_t2;                                     // Turn on this cycle


// State Enable signal

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ustop_match_next_t3
    if (!po_reset_n)
      stop_match_next_t3 <= 1'b0;
    else
      stop_match_next_t3 <= stop_match_t2;
  end


  assign start_enable_t2 = (start_match_t2 | stop_match_t2) |                      // Trace enabled with Start or Stop this cycle
                            stop_match_next_t3 |                                   // Trace enabled with stop seen last cycle
                            viewinst_write_i;                                      // Trace disabled with write to status bit in viewinst register

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ustart_stop_q
    if (!po_reset_n) begin
      start_stop_t3     <= 1'b0;
      start_stop_reg_t3 <= 1'b0;
    end
    else if (start_enable_t2) begin
      start_stop_t3     <= start_stop_t2;
      start_stop_reg_t3 <= start_stop_reg_t2;
    end
  end


  assign viewinst_sstatus_o = start_stop_reg_t3;

//---------------------------------------------------------------------------
// ViewInst Address Range Comparators
//---------------------------------------------------------------------------
// View Instruction with Include/Exclude control for Address Range Comparators
//
// Trace instructions if
//  (Exclude range is false or Exclude range is none) and
//  (Include range is true or Include range is none)

  assign include_exclude_arc_t2 = ( ~|({range3_excl_t2_i,range2_excl_t2_i,range1_excl_t2_i,range0_excl_t2_i} & viewinst_exc_ranges_reg_i[3:0])) &
                                  (  |({range3_match_t2_i,range2_match_t2_i,range1_match_t2_i,range0_match_t2_i} & viewinst_inc_ranges_reg_i[3:0]) |
                                     ~|viewinst_inc_ranges_reg_i[3:0]
                                  );

//---------------------------------------------------------------------------
//   View Inst Enable
//
//   View Inst Enable is controlled by
//    1) ViewInst Enable Event
//    2) ViewInst Include/Exclude address range comparators
//    3) ViewInst Start/Stop single address comparators
//    4) ViewInst Security State and Exception Control
//
//   ViewInst Enable can become active anytime. However for starting generation
//   of trace, a waypoint is required with trace enabled and with processor not
//   in halting debug or prohibited.
//
//   View Inst Enable can become inactive only at a waypoint with following exceptions
//   1) Trace Disabled
//   2) Idle Entry request from core due to WFI like event
//---------------------------------------------------------------------------

// After trace is enabled wait for a waypoint
// incase view inst enable event is true immediately
// Trace gen should already wait for waypoint for ISYNC address
  assign trace_active_1st_wpt_t2 = (~resource_active_t2 & ~wfx_resource_t2) |
                                   (trace_active_1st_wpt_t3 & ~wpt_valid_t2_i);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_active_1st_wpt_t3
    if (!po_reset_n) begin
      trace_active_1st_wpt_t3 <= 1'b0;
      trace_active_1st_wpt_t4 <= 1'b0;
    end
    else begin
      trace_active_1st_wpt_t3 <= trace_active_1st_wpt_t2;
      trace_active_1st_wpt_t4 <= trace_active_1st_wpt_t3;
    end
  end

  assign trace_active_1st_wpt_t4_o = trace_active_1st_wpt_t4;

// After prohibited or debug state exit wait for waypoint
// incase view inst enable event is true immediately
  assign wpt_no_trace_t2 = (wpt_prohibited_t2_i | wpt_dbg_entry_t2_i) |
                           (~wpt_valid_t1_i & wpt_no_trace_t3);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_no_trace_t3
    if (!po_reset_n)
      wpt_no_trace_t3 <= {1{1'b1}};
    else
      wpt_no_trace_t3 <= wpt_no_trace_t2;
  end


// Keep viewinst enable on between waypoints if it is already turned on.
  assign viewinst_by_wpt_t2 = (wpt_valid_t2_i & viewinst_en_t2) |                  // ViewInst on at start of instr block or
                              (viewinst_by_wpt_t3 & ~wpt_valid_t2_i);              // Hold condition i.e waiting for end of instr block.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uviewinst_by_wpt_t3
    if (!po_reset_n)
      viewinst_by_wpt_t3 <= 1'b0;
    else
      viewinst_by_wpt_t3 <= viewinst_by_wpt_t2;
  end


// Viewinst enable can become active if
//  Viewinst enable event is true and
//  SACs start_stop_state is start and
//  ARCs include/exclude condition is met and
//  No debug or prohibit region entry and
//  No WFI/WFE idle request and
//  Trace is enabled

  assign viewinst_condition_t2 = viewinst_exlevel_t2 &                        // security state and exception control is true
                                 viewinst_event_t3   &                        // enable event is true
                                 start_stop_state_t2 &                        // start stop state is start
                                 include_exclude_arc_t2;                      // include/exclude trace condition is met

  assign viewinst_en_t2 = resource_active_t2       &                          // Trace is enabled
                          ~wpt_no_trace_t3         &                          // Valid waypoint seen after debug or prohibit exit
                          ~wpt_dbg_exit_t2_i       &                          // Debug exit waypoint is not traced
                          ~trace_active_1st_wpt_t3 &                          // Valid waypoint seen after trace is enabled
                          ((viewinst_by_wpt_t3 & (~wpt_valid_t2_i |
                                                  ~wpt_adv_t2_i))  |          // Hold condition while waiting for end of instr block
                           (wpt_valid_t2_i & viewinst_condition_t2));         // New instr block and view inst condition is true

  assign viewinst_en_t2_o = viewinst_en_t2;

//---------------------------------------------------------------------------
//   Branch Broadcast ARC Control
//---------------------------------------------------------------------------

  assign bb_en_t2_o = bb_mode_reg_i ?
                       |(bb_range_reg_i[3:0] & {range3_match_t2_i,range2_match_t2_i,range1_match_t2_i,range0_match_t2_i}) : // Include match
                      ~|(bb_range_reg_i[3:0] & {range3_excl_t2_i,range2_excl_t2_i,range1_excl_t2_i,range0_excl_t2_i});      // Exclude match or Exclude None

//---------------------------------------------------------------------------
//   Flush request when tracing is disabled in all states
//---------------------------------------------------------------------------

// Register authentication control
  always @(posedge clk_gated or negedge po_reset_n)
  begin: udbgniden_q
    if (!po_reset_n) begin
      gov_niden_t1 <= {1{1'b1}};
      gov_dbgen_t1 <= {1{1'b1}};
    end
    else begin
      gov_niden_t1 <= gov_niden_i;
      gov_dbgen_t1 <= gov_dbgen_i;
    end
  end

  // here's the pla table sent to espresso:
  //
  // dbgniden_flush_t3[1:0]
  // |  trace_prog_enabled_t0
  // |  | gov_auth_en_t1
  // |  | | wpt_valid_t2
  // |  | | | wpt_prohibited_t2
  // |  | | | | dbgniden_flush_t2[1:0]
  // |  | | | | |
  // 00 0 - - - 00
  // 00 1 - 0 - 00
  // 00 1 - 1 0 00
  // 00 1 0 1 1 10
  // 00 1 1 1 1 01
  // 01 0 - - - 00
  // 01 1 0 - - 10
  // 01 1 1 0 - 01
  // 01 1 1 1 0 00
  // 01 1 1 1 1 01
  // 10 0 - - - 00
  // 10 1 0 - - 10
  // 10 1 1 0 - 01
  // 10 1 1 1 0 00
  // 10 1 1 1 1 01
  // default:
  // 11 - - - - --
  //
  // the following equations are the espresso output

  assign dbgniden_flush_t2[1] = (trace_prog_enabled_t0&!gov_auth_en_t1&wpt_valid_t2_i
    &wpt_prohibited_t2_i) | (dbgniden_flush_t3[1]&trace_prog_enabled_t0
    &!gov_auth_en_t1) | (dbgniden_flush_t3[0]&trace_prog_enabled_t0
    &!gov_auth_en_t1);

  assign dbgniden_flush_t2[0] = (trace_prog_enabled_t0&gov_auth_en_t1&wpt_valid_t2_i
    &wpt_prohibited_t2_i) | (dbgniden_flush_t3[1]&trace_prog_enabled_t0
    &gov_auth_en_t1&!wpt_valid_t2_i) | (dbgniden_flush_t3[0]
    &trace_prog_enabled_t0&gov_auth_en_t1&!wpt_valid_t2_i);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: udbgniden_flush_t3_1_0
    if (!po_reset_n)
      dbgniden_flush_t3[1:0] <= {2{1'b0}};
    else
      dbgniden_flush_t3[1:0] <= dbgniden_flush_t2[1:0];
  end


// Request flush whenever dbgniden goes low after trace is enabled.
  assign dbgniden_flush_req_t3 = (dbgniden_flush_t3[1:0] == 2'b10) & ~auxctlr_frc_auth_noflush_reg_i;

//---------------------------------------------------------------------------
//   Idle State Machine
//---------------------------------------------------------------------------

// This is the idle request state machine.
//
// The ETM can be taken into idle state for the following reasons:
// * Trace is disabled due to clearing of trace_enable_reg_i or setting of OS Lock
// * The core requests ETM to go idle, e.g. due to WFI.
//
// To ensure that the ETM goes into idle and comes out again cleanly,
// idle state entry and exit is managed by a strictly cyclic state
// machine, with 8 states.  These are documented in the state machine
// logic below.
//

// Idle condition forces viewinst_en low to stop trace and allows FIFO to drain completely.
// Debug and prohibited entry when trace is not allowed in secure state do not flush, although they stop trace.
// Entry to prohibited region when tracing is not allowed in any state will cause a flush.
  assign main_idle_req_t2 = (gov_wfx_drain_req_t2_i & ~lp_override_reg_i) |   // Idle request for wfi or wfe
                            dbgniden_flush_req_t3 |                           // Tracing not permitted
                            ~trace_req_t0;                                    // Trace is disabled

// If trace is disabled outside of run, need to go round again to flush completely
// If idle condition is removed before idle is acknowledged, must go round again
  assign idle_state_control_t2 = ~main_idle_req_t2 |
                                 (~trace_req_t0 & trace_been_active_q) |
                                 idle_removed_q;

  always @*
  begin
    case(idle_state_t1[2:0])
       // Starting state out of reset
       // The ETM is only considered to be idle when in this state.
       // Wait for the idle request to cease.
      CA53_ETM_ST_IDLE       : idle_state_t0[2:0] = idle_state_control_t2 ? CA53_ETM_ST_RUN : CA53_ETM_ST_IDLE;
       // Normal run state.  Wait for an idle request.
       // Now indicate to atclk domain that core state machine is in run mode
       // so atclk state machine can move to active state.
      CA53_ETM_ST_RUN        : idle_state_t0[2:0] = main_idle_req_t2 ? CA53_ETM_ST_TRC_STOP   : CA53_ETM_ST_RUN;
       // An idle request has been observed -- start by issuing an idle
       // request to the ETM pipeline.  This stops any more trace from
       // being produced.
      CA53_ETM_ST_TRC_STOP   : idle_state_t0[2:0] = main_idle_req_t2 ? (trcgen_idle_ack_i ? CA53_ETM_ST_PIPEWAIT0 : CA53_ETM_ST_TRC_STOP) :
                                                  CA53_ETM_ST_RUN;
       // Wait until atclk state machine actually enters active state
      CA53_ETM_ST_PIPEWAIT0  : idle_state_t0[2:0] = at_active_state_i ?CA53_ETM_ST_PIPEWAIT1 : CA53_ETM_ST_PIPEWAIT0;
       // Now indicate to atclk that core state machine is out of run mode
      CA53_ETM_ST_PIPEWAIT1  : idle_state_t0[2:0] = trace_overflow_i ? CA53_ETM_ST_PIPEWAIT1 : CA53_ETM_ST_FIFO_FLUSH;
       // Now we have stopped trace.
       // Wait for
       // -> idle request to synchronize to atclk domain
       // -> main fifo to flush
       // -> resync fifo to empty and stop taking data
       // -> at idle ack to synchronize back to clk_gated domain
      CA53_ETM_ST_FIFO_FLUSH : idle_state_t0[2:0] = (at_idle_ack_i | (idle_removed & fifo_idle_ack_i)) ? CA53_ETM_ST_FIFO_RESET : CA53_ETM_ST_FIFO_FLUSH;
       // Now we have flushed the fifo.
       // Wait for
       // -> idle deassert to synchronize to atclk domain
       // -> reset all fifo pointers to zero
       // -> at idle ack deassert to synchronize back to clk_gated domain
      CA53_ETM_ST_FIFO_RESET : idle_state_t0[2:0] = ~at_idle_ack_i ? CA53_ETM_ST_IDLE : CA53_ETM_ST_FIFO_RESET;
       // CA53_ETM_ST_UNUSED state is not reachable (has SVA)
      default     : idle_state_t0[2:0] = {3{1'bx}};
    endcase
  end


// On reset idle_state_t1 is set to CA53_ETM_ST_IDLE
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uidle_state_t1_2_0
    if (!po_reset_n)
      idle_state_t1[2:0] <= CA53_ETM_ST_IDLE;
    else
      idle_state_t1[2:0] <= idle_state_t0[2:0];
  end

  assign viewinst_idle_req_t1 = (idle_state_t1 == CA53_ETM_ST_TRC_STOP) |
                                (idle_removed_q & (main_idle_req_t2 | trace_wait_idle_t2));

// Main state machine is in run mode so that atclk can resume tracing.
  assign core_at_main_run_t1 = (idle_state_t1 == CA53_ETM_ST_RUN) |
                               (idle_state_t1 == CA53_ETM_ST_TRC_STOP) |
                                idle_removed_q;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucore_at_main_run_t2
    if (!po_reset_n) begin
      core_at_main_run_t2   <= 1'b0;
      viewinst_idle_req_t2  <= 1'b0;
      wfx_resource_t3       <= 1'b0;
    end
    else begin
      core_at_main_run_t2   <= core_at_main_run_t1;
      viewinst_idle_req_t2  <= viewinst_idle_req_t1;
      wfx_resource_t3       <= wfx_resource_t2;
    end
  end


  assign core_at_main_run_t2_o  = core_at_main_run_t2;
  assign viewinst_idle_req_t2_o = viewinst_idle_req_t2;
  assign resource_active_t2_o   = resource_active_t2;
  assign trace_req_t0_o         = trace_req_t0;

  // Some state needs to retained during WFI low power state. Trace pipe also has a version
  assign wfx_resource_t2  = (wfx_resource_t3 | (gov_wfx_drain_req_t2_i  & ~lp_override_reg_i)) &
                            trace_req_t0 & ~wpt_valid_t2_i;
  assign wfx_resource_t3_o  = wfx_resource_t3;

// Propagate Idle req to FIFO
  assign fifo_idle_req_t2_o = (idle_state_t1 == CA53_ETM_ST_FIFO_FLUSH);




//---------------------------------------------------------------------------
//   Idle bit in Status Register
//---------------------------------------------------------------------------

// Idle state read value in status register
// Sample trace disabled on exit from RUN state
// Set if trace is disabled in in CA53_ETM_TRC_STOP
// Clear if trace is enabled
// After reset, this sampled trc disabled bit will be set
// Detect entry to low power state when still enabled
  assign trace_been_active = (core_at_main_run_t2)  | (trace_been_active_q  & (trace_req_t0 | ~at_idle_ack_i));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_been_active_q
    if (!po_reset_n)
      trace_been_active_q <= {1{1'b0}};
    else
      trace_been_active_q <= trace_been_active;
  end


// After exiting run state for idle, may need to resume tracing before
// state has reached idle. Use this to re-enable pipes and ensure run state will be re-entered
  assign idle_removed = (idle_state_t1 != CA53_ETM_ST_RUN) &
                        (idle_removed_q | (~main_idle_req_t2 & (idle_state_t1 != CA53_ETM_ST_IDLE)));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uidle_removed_q
    if (!po_reset_n)
      idle_removed_q <= 1'b0;
    else
      idle_removed_q <= idle_removed;
  end


// Idle bit read value in status register (forced low in APB when enable is high)
  assign trcstatr_idle   = (idle_state_t1 == CA53_ETM_ST_IDLE) & ~idle_removed_q & ~trace_been_active_q;
  assign trcstatr_idle_o = trcstatr_idle;

//---------------------------------------------------------------------------
//   Idle State output to core
//---------------------------------------------------------------------------

// etm is idle due to trc_disable or oslock
// or wfi request
  assign et_idle_ack = auxctlr_frc_idleack_reg_i | ((idle_state_t1 == CA53_ETM_ST_IDLE) & ~idle_removed_q);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uet_idle_ack_q
    if (!po_reset_n)
      et_idle_ack_q <= {1{1'b1}};
    else
      et_idle_ack_q <= et_idle_ack;
  end

  assign etm_wfx_ready_o = et_idle_ack_q;


//--------------------------------------------------------------------------
//  ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON
`include "ca53etm_val_defs.v"
// ViewInst Enable and Trace Enable state machine

  usva_at_active_not_idle: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ((idle_state_t1 == CA53_ETM_ST_PIPEWAIT0) & at_active_state_i) |-> ~at_idle_ack_i)
    `SVA_FATAL("If idle state machine is PIPEWAIT0 and at_active_state is set, at_idle_ack cannot be active");

  usva_at_active_unused: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~(idle_state_t1 == CA53_ETM_ST_UNUSED))
    `SVA_FATAL("Idle State machine in unused state");

  usva_at_drain_wpt: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      gov_wfx_drain_req_t2_i |-> ~wpt_valid_t2_i)
    `SVA_FATAL("WFX drain request must not occur with waypoint valid");
    
  usva_at_idle_restart: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      trace_been_active & ~at_idle_ack_i |=> core_at_main_run_t2 | trace_been_active_q)
    `SVA_FATAL("Reached idle state without going through run state");
// Flush should start without acknowledge signals high
  usva_at_start_flush: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        idle_state_t1 == CA53_ETM_ST_PIPEWAIT1 |->
                                        ~at_idle_ack_i &
                                        ~fifo_idle_ack_i)
    `SVA_FATAL("Idle acknowledged before start of flush sequence");
// Leave stop state after pipe is flushed
  usva_at_idle_stop: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        idle_state_t1 == CA53_ETM_ST_TRC_STOP[*18] |=>
                                        idle_state_t1 != CA53_ETM_ST_TRC_STOP | 
                                        trace_overflow_i | 
                                       $past(trace_overflow_i,2) |
                                       $past(trace_overflow_i,4) |
                                       $past(trace_overflow_i,6) |
                                       $past(trace_overflow_i,8) |
                                       $past(trace_overflow_i,16))
    `SVA_FATAL("Idle state machine stuck in stop state");
  usva_at_idle_stop_overflow: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      (~trace_overflow_i & idle_state_t1 == CA53_ETM_ST_TRC_STOP)[*18] |=>
                                        idle_state_t1 != CA53_ETM_ST_TRC_STOP)
    `SVA_FATAL("Idle state machine stuck in stop state");
 //NIDEN
  wire   auth_notrace;
  assign auth_notrace = (dbgniden_flush_t3[1:0] == 2'b10);
  usva_auth_notrace: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     auth_notrace |-> ~$past(gov_dbgen_i | gov_niden_i,2))
    `SVA_FATAL("NIDEN input should be deasserted 2 cycle before if auth_notrace is asserted");

  usva_niden_resource: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     ~(gov_niden_i | gov_dbgen_i) |-> ##3 ~resource_active_t2)
    `SVA_FATAL("Resources must be inactive if authentication inputs are both low");

  usva_ss_redundant1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                       start_match_t2 |-> core_at_main_run_t2 & ~viewinst_idle_req_t2);

  // Coverage point is constrained
  usva_idle_corner: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
  (idle_state_t1 == CA53_ETM_ST_IDLE) & idle_removed_q & ~trace_been_active_q |-> $past(trace_been_active_q,3))
    `SVA_FATAL("Idle removed, trace_been_active_q is low, and has been log for several cycles.");

  usva_wait_idle: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    gov_auth_en_t1 & ~etm_oslock_i & trace_enable_reg_i & ~trace_wait_idle_t1 & trace_wait_idle_t2 |-> trcstatr_idle)
    `SVA_ERROR("Idle state not reached, but no longer waiting");
    
                                   
`endif

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

