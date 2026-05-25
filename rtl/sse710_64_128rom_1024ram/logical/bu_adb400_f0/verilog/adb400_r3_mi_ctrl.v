//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-10 23:00:03 +0000 (Wed, 10 Feb 2016)
// Revision : 206679
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_mi_ctrl.v
//-----------------------------------------------------------------------------
// Purpose : The state machine contolling the powerdown of the master interface
//           side of the bridge and coordination with the slave interface side.
//-----------------------------------------------------------------------------

module adb400_r3_mi_ctrl
  #(
    parameter SYNC_LEVELS = 2
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // Clock control
    input  wire                   clkqreqn_i,
    output wire                   clkqacceptn_o,
    output wire                   clkqdeny_o,

    // Clock requirement
    output wire                   clkqactive_o,

    // Power requirement
    output wire                   pwrqactive_o,

    // Wake-up
    input  wire                   wakeup_i,
    output wire                   wakeup_o,
    // the local driver of wakeup_o
    input  wire                   wakeup_sync_i,

    // Master Interface power state control
    input  wire                   slvmustacceptreqn_async_i,
    input  wire                   slvcandenyreqn_async_i,
    output wire                   slvacceptn_o,
    output wire                   slvdeny_o,

    // Cross-domain wakeup
    input  wire                   wakeup_async_i,
    output wire                   wakeup_async_o,

    // Local status and control signals
    // NOTE: the quiescence indicators below are assumed to be driven
    //       in a manner compliant with the LPI spec - i.e. only using
    //       cell-library OR2 between driving registers and here.
    input  wire                   ar_dvm_multipart_quiescent_i,     // No multi-part DVMs are ongoing on AR
    input  wire                   ac_dvm_multipart_quiescent_i,     // No multi-part DVMs are ongoing on AC
    input  wire                   dvm_sync_complete_quiescent_i, // No AR-Sync without AC-Complete or AC-Sync without AR-Complete
    input  wire                   initiator_quiescent_i,  // Quiescent for things initiated on this side
    input  wire                   responder_quiescent_i,  // Quiescent for things not initiated on this side
    input  wire                   initiator_quiescent_and_stalled_i,  // Quiescent and stalled for things initiated on this side
    input  wire                   responder_quiescent_and_stalled_i,  // Quiescent and stalled for things not initiated on this side
    output wire                   initiator_fencen_o,     // (not) Stall things initiated on this side to achieve quiescence 
    output wire                   responder_fencen_o,     // (not) Stall things initiated on not this side to achieve quiescence 
    output wire                   inner_fencen_o,         // (not) Stall the egress of channels so the other side's reset cannot
                                                          // make things appear to be valid on it (only matters for quiescence
                                                          // tracking between the start and end of power state STOP as channel
                                                          // traffic cannot 
    output wire                   outer_fencen_o,         // (not) Stall things on the periphery to allow clock removal
    output wire                   internal_resetn_o       // Drive the async crossings into the reset state
  );

  // Synchronise async inputs
  wire clkqreqn_ss;
  wire slvmustacceptreqn_ss;
  wire slvcandenyreqn_ss;

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_clkqreqn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (clkqreqn_i),
      .dout    (clkqreqn_ss)
    );

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_slvmustacceptreqn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (slvmustacceptreqn_async_i),
      .dout    (slvmustacceptreqn_ss)
    );

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_slvcandenyreqn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (slvcandenyreqn_async_i),
      .dout    (slvcandenyreqn_ss)
    );


  // State encoding for the clock Q channel

  localparam ST_Q_WIDTH = 3;
  localparam ST_Q_MSB = (ST_Q_WIDTH-1);

  // States are encoded as {QDENY,QACCEPTn,QREQn}
  localparam ST_Q_STOPPED         = 3'b000;
  localparam ST_Q_RUN             = 3'b001;
  localparam ST_Q_REQUEST_PAUSE   = 3'b010;
  localparam ST_Q_REQUEST         = 3'b011;
  localparam ST_Q_DENIED          = 3'b100;

  // The CLK state
  reg  [ST_Q_MSB:0] state_clkq_q;
  reg  [ST_Q_MSB:0] state_clkq_nxt;


  // The state machine
  always @*
    begin : p_state_clkq_nxt
      case (state_clkq_q)
        // Idle. Start up when requested and egress is allowed 
        ST_Q_STOPPED:
          case (clkqreqn_ss)
            1'b0:
              state_clkq_nxt = ST_Q_STOPPED;
            1'b1:
              state_clkq_nxt = ST_Q_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_clkq_nxt = {ST_Q_WIDTH{1'bx}};
          endcase
        ST_Q_RUN:
          case (clkqreqn_ss)
            1'b0:
              state_clkq_nxt = ST_Q_REQUEST_PAUSE;
            1'b1:
              state_clkq_nxt = ST_Q_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_clkq_nxt = {ST_Q_WIDTH{1'bx}};
          endcase
        ST_Q_REQUEST_PAUSE:
          state_clkq_nxt = ST_Q_REQUEST;
        ST_Q_REQUEST:
          case (initiator_quiescent_and_stalled_i &
                responder_quiescent_and_stalled_i & 
                dvm_sync_complete_quiescent_i &
                ar_dvm_multipart_quiescent_i &
                ac_dvm_multipart_quiescent_i)
            1'b0:
              state_clkq_nxt = ST_Q_DENIED;
            1'b1:
              state_clkq_nxt = ST_Q_STOPPED;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_clkq_nxt = {ST_Q_WIDTH{1'bx}};
          endcase
        ST_Q_DENIED:
          case (clkqreqn_ss)
            1'b0:
              state_clkq_nxt = ST_Q_DENIED;
            1'b1:
              state_clkq_nxt = ST_Q_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_clkq_nxt = {ST_Q_WIDTH{1'bx}};
          endcase
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT X_ASSIGNMENT Unreachable, present for X-prop detection
          state_clkq_nxt = {ST_Q_WIDTH{1'bx}};
      endcase
    end

  wire state_clkq_upd_en = ((clkqreqn_ss ^ clkqacceptn_o) | clkqdeny_o);

  reg  clkqacceptn_q;
  wire clkqacceptn_nxt = ~(ST_Q_STOPPED == state_clkq_nxt);
  reg  clkqdeny_q;
  wire clkqdeny_nxt    =  (ST_Q_DENIED  == state_clkq_nxt);
  reg  responder_fencen_q;
  wire responder_fencen_nxt = (
                               (ST_Q_RUN    == state_clkq_nxt) |
                               (ST_Q_DENIED == state_clkq_nxt)
                              );

  always @(posedge aclk or negedge aresetn)
    begin : p_state_clkq_q
      if (!aresetn)
        begin
          state_clkq_q       <= ST_Q_STOPPED;
          clkqacceptn_q      <= 1'b0;
          clkqdeny_q         <= 1'b0;
          responder_fencen_q <= 1'b0;
        end
      else if (state_clkq_upd_en)
        begin
          state_clkq_q       <= state_clkq_nxt;
          clkqacceptn_q      <= clkqacceptn_nxt;
          clkqdeny_q         <= clkqdeny_nxt;
          responder_fencen_q <= responder_fencen_nxt;
        end
    end

  // State maching for the power control (internal) interface

  // Starting
  // ( 1)      ST_STOPPED
  //      (+)  slvmustacceptreqn_i &&
  //      (+)  slvcandenyreqn_i
  // ( 2)  ->  ST_RUN
  //       +   internal_resetn_o
  //       +   slvacceptn_o
  //       +   initiator_fencen_o
  //       +   inner_fencen_o
  //       +   outer_fencen_o

  // Denying because of the local state
  // ( 1)      ST_RUN
  //      (-)  slvcandenyrenq_i
  // ( 2)  ->  ST_REQUEST_PRE_CANDENY
  // ( 3)  ->  ST_REQUEST_CANDENY
  //       -   initiator_fencen_o         # Not required, but common to deny and accept modes - which is not known at this point
  // [not quiescent]
  // ( 4)  ->  ST_DENIED
  //       +   slvdeny_o
  //      (+)  slvcandenyreqn_i
  // ( 5)  ->  ST_RUN
  //       -   slvdeny_o
  //  =>   +   initiator_fencen_o

  // Denying despite non-permission because snoops were not quesced before starting powerdown on ACE-Lite+DVM or ACE protocols
  // ( 1)      ST_RUN
  //      (-)  slvmustacceptreqn_i
  // ( 2)  ->  ST_REQUEST_MUSTACCEPT
  //       -   initiator_fencen_o         # Not required, but common to deny and accept modes - which is not known at this point
  // [not quiescent]
  // ( 4)  ->  ST_DENIED
  //       +   slvdeny_o
  //      (+)  slvmustacceptreqn_i
  // ( 5)  ->  ST_RUN
  //       -   slvdeny_o
  //  =>   +   initiator_fencen_o

  // Accepting
  // ( 1)      ST_RUN
  //      (-)  slvcandenyreqn_i ||
  //      (-)  slvmustacceptreqn_i
  // ( 2)  ->  ST_REQUEST_PRE_CANDENY->ST_REQUEST_CANDENY ||
  //           ST_REQUEST_MUSTACCEPT
  //       -   initiator_fencen_o        # Cause protocol and ultimately local quiescence
  // [quiescent or cannot deny so wait for quiescence]
  // ( 3)  ->  ST_QUIESCENT
  //       -   slvacceptn_o
  //       -   inner_fencen_o
  //       -   outer_fencen_o
  //      (+)  slvmustacceptreqn_o ||
  //      (+)  slvcandenyreqn_o
  // ( 4)  ->  ST_READY_RESET
  //       +   slvacceptn_o
  //      (-)  slvmustacceptreqn_i &&
  //      (-)  slvcandenyreqn_i
  // ( 5)  ->  ST_STOPPED
  //       -   slvacceptn_o
  //       -   internal_resetn_o

  localparam ST_WIDTH = 3;
  localparam ST_MSB = (ST_WIDTH-1);

  localparam ST_STOPPED             = 3'b000;
  localparam ST_RUN                 = 3'b001;
  localparam ST_REQUEST_PRE_CANDENY = 3'b010;
  localparam ST_REQUEST_CANDENY     = 3'b011;
  localparam ST_REQUEST_MUSTACCEPT  = 3'b100;
  localparam ST_DENIED              = 3'b101;
  localparam ST_QUIESCENT           = 3'b110;
  localparam ST_READY_RESET         = 3'b111;

  reg  [ST_MSB:0] internal_state_q;
  reg  [ST_MSB:0] internal_state_nxt;

  // The state machine
  always @*
    begin : p_internal_state_nxt
      case (internal_state_q)
        ST_STOPPED:
          case (slvcandenyreqn_ss & slvmustacceptreqn_ss)
            1'b0:
              internal_state_nxt = ST_STOPPED;
            1'b1:
              internal_state_nxt = ST_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
        ST_RUN:
          case (slvcandenyreqn_ss)
            1'b0:
              internal_state_nxt = ST_REQUEST_PRE_CANDENY;
            1'b1:
              case (slvmustacceptreqn_ss)
                1'b0:
                  internal_state_nxt = ST_REQUEST_MUSTACCEPT;
                1'b1:
                  internal_state_nxt = ST_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                  internal_state_nxt = {ST_WIDTH{1'bx}};
              endcase
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
        ST_REQUEST_PRE_CANDENY:
          internal_state_nxt = ST_REQUEST_CANDENY;
        ST_REQUEST_CANDENY:
          case (initiator_quiescent_and_stalled_i &
                responder_quiescent_i &
                dvm_sync_complete_quiescent_i &
                ar_dvm_multipart_quiescent_i &
                ac_dvm_multipart_quiescent_i)
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
            1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when DVM support absent
              internal_state_nxt = ST_DENIED;
            1'b1:
              internal_state_nxt = ST_QUIESCENT;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
// ACS_off UNREACHABLE_BRANCH (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
        ST_DENIED:
          case (slvcandenyreqn_ss & slvmustacceptreqn_ss)
// ACS_off UNREACHABLE_BRANCH (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
            1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
              internal_state_nxt = ST_DENIED;
// ACS_off UNREACHABLE_BRANCH (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
            1'b1:
// ACS_off UNREACHABLE_STATEMENT (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
              internal_state_nxt = ST_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
        ST_REQUEST_MUSTACCEPT:
          case (dvm_sync_complete_quiescent_i &
                ar_dvm_multipart_quiescent_i &
                ac_dvm_multipart_quiescent_i)
            // ACE-Lite+DVM and ACE variants might *have* to do this if snoops
            // have not been correctly disabled and completed. Others *cannot* do this
            // as the inputs enabling it are tied high.
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
            1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when DVM support absent
              internal_state_nxt = ST_DENIED;
            1'b1:
              case (initiator_quiescent_and_stalled_i & responder_quiescent_i)
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
                1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when DVM support absent
                  internal_state_nxt = ST_REQUEST_MUSTACCEPT;
                1'b1:
                  internal_state_nxt = ST_QUIESCENT;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                  internal_state_nxt = {ST_WIDTH{1'bx}};
              endcase
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
        ST_QUIESCENT:
          case (slvcandenyreqn_ss & slvmustacceptreqn_ss)
            1'b0:
              internal_state_nxt = ST_QUIESCENT;
            1'b1:
              internal_state_nxt = ST_READY_RESET;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
        ST_READY_RESET:
          case (slvcandenyreqn_ss | slvmustacceptreqn_ss)
            1'b0:
              internal_state_nxt = ST_STOPPED;
            1'b1:
              internal_state_nxt = ST_READY_RESET;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              internal_state_nxt = {ST_WIDTH{1'bx}};
          endcase
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT X_ASSIGNMENT Unreachable, present for X-prop detection
          internal_state_nxt = {ST_WIDTH{1'bx}};
      endcase
    end

  wire            internal_state_upd_en = (
                                           (slvcandenyreqn_ss ^ slvacceptn_o) |
                                           (slvmustacceptreqn_ss ^ slvacceptn_o) |
                                          slvdeny_o
                                          );

  reg             slvdeny_q;
  wire            slvdeny_nxt          =  (
                                           (ST_DENIED      == internal_state_nxt)
                                          );

  reg             slvacceptn_q;
  wire            slvacceptn_nxt       = ~(
                                           (ST_QUIESCENT   == internal_state_nxt) |
                                           (ST_STOPPED     == internal_state_nxt)
                                          );

  reg             internal_resetn_q;
  wire            internal_resetn_nxt  = ~( 
                                           (ST_STOPPED     == internal_state_nxt)
                                          );

  reg             inner_fencen_q;
  wire            inner_fencen_nxt = ~( 
                                       (ST_QUIESCENT       == internal_state_nxt) |
                                       (ST_READY_RESET     == internal_state_nxt) |
                                       (ST_STOPPED         == internal_state_nxt)
                                      );

  always @(posedge aclk or negedge aresetn)
    begin : p_internal_state_q
      if (!aresetn)
        begin
          internal_state_q      <= ST_STOPPED;
          slvdeny_q             <= 1'b0;
          slvacceptn_q          <= 1'b0;
          internal_resetn_q     <= 1'b0;
          inner_fencen_q        <= 1'b0;
        end
      else if (internal_state_upd_en)
        begin
          internal_state_q      <= internal_state_nxt;
          slvdeny_q             <= slvdeny_nxt;
          slvacceptn_q          <= slvacceptn_nxt;
          internal_resetn_q     <= internal_resetn_nxt;
          inner_fencen_q        <= inner_fencen_nxt;
        end
    end

  // NOTE: this needs to use glitch-free OR and XOR gates as it
  //       is a component of *QACTIVE signals below
  wire slv_if_can_deny_active_async;
  wire slv_if_must_accept_active_async;
  wire slv_if_req_active_async;

  adb400_r3_xor2 
    u_can_deny_xor_preserve_gate
  (
    .din0 (slvcandenyreqn_async_i),
    .din1 (slvacceptn_o),
    .dout (slv_if_can_deny_active_async)
  );

  adb400_r3_xor2 
    u_must_accept_xor_preserve_gate
  (
    .din0 (slvmustacceptreqn_async_i),
    .din1 (slvacceptn_o),
    .dout (slv_if_must_accept_active_async)
  );

  adb400_r3_or2 
    u_req_preserve_gate
  (
    .din0 (slv_if_can_deny_active_async),
    .din1 (slv_if_must_accept_active_async),
    .dout (slv_if_req_active_async)
  );

  wire slv_if_state_active = internal_state_q[2];
  wire slv_if_active_async;

  adb400_r3_or2 
    u_slv_if_active_preserve_gate
  (
    .din0 (slv_if_req_active_async),
    .din1 (slv_if_state_active),
    .dout (slv_if_active_async)
  );


  // NOTE: the *QACTIVE outputs need to be built from
  //       glitch-free OR gates
  wire non_dvm_quiescentn;
  wire multipart_dvm_quiescentn;
  wire dvm_quiescentn;
  wire quiescentn;
  wire qactive_sync;

  adb400_r3_or2 
    u_non_dvm_quiescentn_preserve_gate
  (
    .din0 (~initiator_quiescent_i),
    .din1 (~responder_quiescent_i),
    .dout (non_dvm_quiescentn)
  );

  adb400_r3_or2 
    u_multipart_dvm_quiescentn_preserve_gate
  (
    .din0 (~ar_dvm_multipart_quiescent_i),
    .din1 (~ac_dvm_multipart_quiescent_i),
    .dout (multipart_dvm_quiescentn)
  );

  adb400_r3_or2 
    u_dvm_quiescentn_preserve_gate
  (
    .din0 (multipart_dvm_quiescentn),
    .din1 (~dvm_sync_complete_quiescent_i),
    .dout (dvm_quiescentn)
  );

  adb400_r3_or2 
    u_quiescentn_preserve_gate
  (
    .din0 (non_dvm_quiescentn),
    .din1 (dvm_quiescentn),
    .dout (quiescentn)
  );

  adb400_r3_or2 
    u_qactive_sync_preserve_gate
  (
    .din0 (quiescentn),
    .din1 (wakeup_i),
    .dout (qactive_sync)
  );

  adb400_r3_or2 
    u_pwrqactive_preserve_gate
  (
    .din0 (qactive_sync),
    .din1 (wakeup_async_i),
    .dout (pwrqactive_o)
  );
  
  adb400_r3_or2 
    u_clkqactive_preserve_gate
  (
    .din0 (pwrqactive_o),
    .din1 (slv_if_active_async),
    .dout (clkqactive_o)
  );
  
  reg  wakeup_q;
  wire wakeup_nxt = wakeup_sync_i;

  wire wakeup_upd_en = 1'b1;
  always @(posedge aclk or negedge aresetn)
    begin : p_wakeup_q
      if (!aresetn)
        wakeup_q <= 1'b0;
      else if (wakeup_upd_en)
        wakeup_q <= wakeup_nxt;
    end
  assign wakeup_o = wakeup_q;

  assign          slvdeny_o     = slvdeny_q;
  assign          slvacceptn_o  = slvacceptn_q;

  assign          clkqacceptn_o = clkqacceptn_q;
  assign          clkqdeny_o    = clkqdeny_q;

  assign          wakeup_async_o = qactive_sync;

  assign          internal_resetn_o  = internal_resetn_q;

  assign          responder_fencen_o = responder_fencen_q;

  assign          inner_fencen_o     = inner_fencen_q;

  // The fences depend on both the PWRQ and the CLKQ interface states
  reg             initiator_fencen_q;
  wire            initiator_fencen_nxt  =  (
                                            ((ST_RUN    == internal_state_nxt) |
                                             (ST_DENIED == internal_state_nxt)) &
                                            ((ST_Q_RUN    == state_clkq_nxt) |
                                             (ST_Q_DENIED == state_clkq_nxt))
                                           );

  reg             outer_fencen_q;
  wire            outer_fencen_nxt = ~( 
                                       (ST_Q_STOPPED       == state_clkq_nxt) |
                                       (ST_QUIESCENT       == internal_state_nxt) |
                                       (ST_READY_RESET     == internal_state_nxt) |
                                       (ST_STOPPED         == internal_state_nxt)
                                      );
  wire            fencen_upd_en = (state_clkq_upd_en | internal_state_upd_en);

  always @(posedge aclk or negedge aresetn)
    begin : p_outer_fencen_q
      if (!aresetn)
        begin
          initiator_fencen_q <= 1'b0;
          outer_fencen_q     <= 1'b0;
        end
      else if (fencen_upd_en)
        begin
          initiator_fencen_q <= initiator_fencen_nxt;
          outer_fencen_q     <= outer_fencen_nxt;
        end
    end

  assign          initiator_fencen_o = initiator_fencen_q;
  assign          outer_fencen_o     = outer_fencen_q;

endmodule
