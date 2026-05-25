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
// Checked In :  2016-02-12 14:23:46 +0000 (Fri, 12 Feb 2016)
// Revision : 206763
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_si_ctrl.v
//-----------------------------------------------------------------------------
// Purpose : The state machine contolling the powerdown of the slave interface
//           side of the bridge and coordination with the master interface side.
//-----------------------------------------------------------------------------

module adb400_r3_si_ctrl
  #(
    parameter SYNC_LEVELS = 2
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // Configuration inputs
    input  wire                   pwrq_permit_deny_i,

    // Clock control
    input  wire                   clkqreqn_i,
    output wire                   clkqacceptn_o,
    output wire                   clkqdeny_o,

    // Clock requirement
    output wire                   clkqactive_o,

    // Power state control
    input  wire                   pwrqreqn_i,
    output wire                   pwrqacceptn_o,
    output wire                   pwrqdeny_o,

    // Power requirement
    output wire                   pwrqactive_o,

    // Wake-up
    input  wire                   wakeup_i,
    output wire                   wakeup_o,
    // the local driver of wakeup_o
    input  wire                   wakeup_sync_i,

    // Master Interface power state control
    output wire                   slvmustacceptreqn_o,
    output wire                   slvcandenyreqn_o,
    input  wire                   slvacceptn_async_i,
    input  wire                   slvdeny_async_i,

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
    output wire                   responder_fencen_o,     // (not) Stall things initiated not on this side to achieve quiescence 
    output wire                   inner_fencen_o,         // (not) Stall the egress of channels so the other side's reset cannot
                                                          // make things appear to be valid on it (only matters for quiescence
                                                          // tracking between the start and end of power state STOP as channel
                                                          // traffic cannot 
    output wire                   outer_fencen_o,         // (not) Stall things on the periphery to allow clock removal
    output wire                   internal_resetn_o       // Drive the async crossings into the reset state
  );

  // Synchronise async inputs
  wire clkqreqn_ss;
  wire pwrqreqn_ss;
  wire slvacceptn_ss;
  wire slvdeny_ss;

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
    u_syncn_pwrqreqn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (pwrqreqn_i),
      .dout    (pwrqreqn_ss)
    );

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_slvacceptn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (slvacceptn_async_i),
      .dout    (slvacceptn_ss)
    );

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_slvdeny
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (slvdeny_async_i),
      .dout    (slvdeny_ss)
    );


  // The CLK state

  localparam ST_Q_WIDTH = 3;
  localparam ST_Q_MSB = (ST_Q_WIDTH-1);

  localparam ST_Q_STOPPED         = 3'b000;
  localparam ST_Q_RUN             = 3'b001;
  localparam ST_Q_REQUEST_PAUSE   = 3'b010;
  localparam ST_Q_REQUEST         = 3'b011;
  localparam ST_Q_DENIED          = 3'b100;

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
  wire clkqacceptn_nxt      = ~(ST_Q_STOPPED == state_clkq_nxt);
  reg  clkqdeny_q;
  wire clkqdeny_nxt         =  (ST_Q_DENIED  == state_clkq_nxt);
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


  // The PWR state

  localparam ST_P_WIDTH = 4;
  localparam ST_P_MSB = (ST_P_WIDTH-1);

  localparam ST_P_STOPPED              = 4'b0000;
  localparam ST_P_EXIT                 = 4'b0001;
  localparam ST_P_RUN                  = 4'b0010;
  localparam ST_P_REQUEST_QUIESCE_MUST_ACCEPT        = 4'b0011;
  localparam ST_P_REQUEST_QUIESCE_PRE_CAN_DENY       = 4'b0100;
  localparam ST_P_REQUEST_QUIESCE_CAN_DENY           = 4'b0101;
  localparam ST_P_REQUEST_QUIESCE_REMOTE_MUST_ACCEPT = 4'b0110;
  localparam ST_P_REQUEST_QUIESCE_REMOTE_CAN_DENY    = 4'b0111;
  localparam ST_P_REQUEST_RESET_REMOTE = 4'b1000;
  localparam ST_P_REQUEST_RESET        = 4'b1001;
  localparam ST_P_DENIED               = 4'b1010;

  // Coming out of P_STOPPED
  //           ST_P_STOPPED
  //      (+)  pwrqreqn_i               // Start up
  // ( 1) (->) ST_P_EXIT
  //       +   slvmustacceptreqn_o AND  // Tell the other side to come out of powerdown
  //       +   slvcandenyreqn_o
  //       +   internal_resetn_o        // Cease resetting
  //       +   inner_fencen_o           // All resetting has finished
  //      (+)  slvacceptn_async_i       // The other side is started
  // ( 2)  ->  ST_P_RUN
  //       +   initiator_fencen_o       // Allow transaction in
  //       +   outer_fencen_o           // ... and out

  // Denying because of the local state
  //           ST_P_RUN
  //      (-)  pwrqreqn_i               // Shut down
  // ( 1) (->) ST_P_REQUEST_QUIESCE_PRE_CAN_DENY
  //       -   initiator_fencen_o       // Cause protocol quiescence
  // ( 2)  ->  ST_P_REQUEST_QUIESCE_CAN_DENY
  // [not quiescent]
  // ( 3)  ->  ST_P_DENIED
  //       +   pwrqdeny_o               // Report DENY
  //      (+)  pwrqreqn_i               // Denial accepted
  // ( 4) (->) ST_P_RUN
  //       -   pwrqdeny_o               // Denial complete
  //       +   initiator_fencen_o       // Allow transactions in again

  // Not denying because of local state
  //           ST_P_RUN
  //      (-)  pwrqreqn_i               // Shut down
  // ( 1) (->) ST_P_REQUEST_QUIESCE_PRE_CAN_DENY->ST_P_REQUEST_QUIESCE_CAN_DENY ||
  //           ST_P_REQUEST_QUIESCE_MUST_ACCEPT
  //       -   initiator_fencen_o       // Cause protocol quiescence
  // [quiescent or cannot deny so wait for quiescence]
  // ( 2) (->) ST_P_REQUEST_QUIESCE
  //       +   initiator_quiescent_i    // Wait for local quiescence
  // ( 3) (->) ST_P_REQUEST_QUIESCE_REMOTE
  //       -   slvmustacceptreqn_o OR   // Tell other side to cause protocol and local quiescence
  //       -   slvcandenyreqn_o

  // If the other side indicates deny
  //      (+)  slvdeny_async_i          // The other side indicates it will not stop
  // ( 4)  ->  ST_P_DENIED          
  //       +   slvcandenyreqn_o         // Start to bring the other side out of the stall
  //       +   pwrqdeny_o               // Report DENY
  //      (-)  slvdeny_async_i          // Other side indicates it is out of stall
  //      (+)  pwrqreqn_i               // Denial accepted
  // ( 5) (->) ST_P_RUN
  //       -   pwrqdeny_o               // Denial complete
  //       +   initiator_fencen_o       // Allow transaction in again

  // If the other side indicates accept - it will be quiescent and have blocked for draining
  //      (-)  slvacceptn_async_i       // Other side quiescent
  //      (+)  responder_quiescent_i    // Locally quiescent as a responder
  // ( 4) (->) ST_P_REQUEST_RESET_REMOTE
  //       -   inner_fencen_o           // Prevent bogus activity from the channel downstreams
  //       -   outer_fencen_o           // Prevent bogus transactions occurring
  //       +   slvmustacceptreqn_o OR   // (whichever one was used to start quiescence) Tell the other side that quiescence is reached, now drain
  //       +   slvcandenyreqn_o
  //      (+)  slvacceptn_async_i       // Other side able to reset
  // ( 5)  ->  ST_P_REQUEST_RESET
  //       -   slvmustacceptreqn_o AND  // Complete powerdown
  //       -   slvcandenyreqn_o
  //       -   internal_resetn_o        // Reset thisside
  //      (-)  slvacceptn_async_i       // Other side is shut down
  // ( 6)  ->  ST_P_STOPPED
  //       -   pwrqaccenptn_o           // Report shutdown


  reg  [ST_P_MSB:0] state_pwrq_q;
  reg  [ST_P_MSB:0] state_pwrq_nxt;

  // The state machine
  always @*
    begin : p_state_pwrq_nxt
      case (state_pwrq_q)
        ST_P_STOPPED:
          case (pwrqreqn_ss)
            1'b0:
              state_pwrq_nxt = ST_P_STOPPED;
            1'b1:
              state_pwrq_nxt = ST_P_EXIT;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_EXIT:
          case (slvacceptn_ss)
            1'b0:
              state_pwrq_nxt = ST_P_EXIT;
            1'b1:
              state_pwrq_nxt = ST_P_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_RUN:
          case (pwrqreqn_ss)
            1'b0:
              case (pwrq_permit_deny_i)
                1'b0:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_MUST_ACCEPT;
                1'b1:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_PRE_CAN_DENY;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                 state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
              endcase
            1'b1:
              state_pwrq_nxt = ST_P_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_QUIESCE_MUST_ACCEPT:
          case (dvm_sync_complete_quiescent_i &
                ar_dvm_multipart_quiescent_i &
                ac_dvm_multipart_quiescent_i)
            // ACE-Lite+DVM and ACE variants might *have* to do this if snoops
            // hove not been correctly disabled and completed
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
            1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when DVM support absent
              state_pwrq_nxt = ST_P_DENIED;
            1'b1:
              case (initiator_quiescent_and_stalled_i)
                1'b0:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_MUST_ACCEPT;
                1'b1:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_REMOTE_MUST_ACCEPT;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                  state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
              endcase

// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_QUIESCE_PRE_CAN_DENY: // Only stays in this state 1 cycle
          state_pwrq_nxt = ST_P_REQUEST_QUIESCE_CAN_DENY;
        ST_P_REQUEST_QUIESCE_CAN_DENY: // Only stays in this state 1 cycle
          // If deniable and not idle, go to DENIED, otherwise start quiescing
          case (initiator_quiescent_and_stalled_i &
                responder_quiescent_i &
                dvm_sync_complete_quiescent_i &
                ar_dvm_multipart_quiescent_i &
                ac_dvm_multipart_quiescent_i)
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
            1'b0:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when DVM support absent
              state_pwrq_nxt = ST_P_DENIED;
            1'b1:
              state_pwrq_nxt = ST_P_REQUEST_QUIESCE_REMOTE_CAN_DENY;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_QUIESCE_REMOTE_MUST_ACCEPT:
          case (slvdeny_ss)
            1'b0:
              case (slvacceptn_ss | ~responder_quiescent_i)
                1'b0:
                  state_pwrq_nxt = ST_P_REQUEST_RESET_REMOTE;
                1'b1:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_REMOTE_MUST_ACCEPT;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                  state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
              endcase
            // ACE-Lite+DVM and ACE variants might *have* to do this if snoops
            // hove not been correctly disabled and completed
// ACS_off UNREACHABLE_BRANCH (no_dvm) Unreachable when DVM support absent
            1'b1:
// ACS_off UNREACHABLE_STATEMENT (no_dvm) Unreachable when QVN and DVM support absent
              state_pwrq_nxt = ST_P_DENIED;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_QUIESCE_REMOTE_CAN_DENY:
          case (slvdeny_ss)
            1'b0:
              case (slvacceptn_ss | ~responder_quiescent_i)
                1'b0:
                  state_pwrq_nxt = ST_P_REQUEST_RESET_REMOTE;
                1'b1:
                  state_pwrq_nxt = ST_P_REQUEST_QUIESCE_REMOTE_CAN_DENY;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
                default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                  state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
              endcase
// ACS_off UNREACHABLE_BRANCH (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
            1'b1:
// ACS_off UNREACHABLE_STATEMENT (no_qvn_no_dvm) Unreachable when QVN and DVM support absent
              state_pwrq_nxt = ST_P_DENIED;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_RESET_REMOTE:
          case (slvacceptn_ss)
            1'b0:
              state_pwrq_nxt = ST_P_REQUEST_RESET_REMOTE;
            1'b1:
              state_pwrq_nxt = ST_P_REQUEST_RESET;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_REQUEST_RESET:
          case (slvacceptn_ss)
            1'b0:
              state_pwrq_nxt = ST_P_STOPPED;
            1'b1:
              state_pwrq_nxt = ST_P_REQUEST_RESET;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
        ST_P_DENIED:
          case (pwrqreqn_ss & ~slvdeny_ss)
            1'b0:
              state_pwrq_nxt = ST_P_DENIED;
            1'b1:
              state_pwrq_nxt = ST_P_RUN;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
            default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
              state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
          endcase
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT X_ASSIGNMENT Unreachable, present for X-prop detection
          state_pwrq_nxt = {ST_P_WIDTH{1'bx}};
      endcase
    end

  wire            state_pwrq_upd_en     = ((pwrqreqn_ss ^ pwrqacceptn_o) | pwrqdeny_o);

  reg             pwrqacceptn_q;
  wire            pwrqacceptn_nxt       = ~(
                                            (ST_P_STOPPED == state_pwrq_nxt) |
                                            (ST_P_EXIT    == state_pwrq_nxt)
                                           );

  reg             pwrqdeny_q;
  wire            pwrqdeny_nxt          =  (
                                            (ST_P_DENIED   == state_pwrq_nxt)
                                           );

  reg             slvmustacceptreqn_q;
  wire            slvmustacceptreqn_nxt = ~( 
                                            (ST_P_STOPPED         == state_pwrq_nxt) |
                                            (ST_P_REQUEST_QUIESCE_REMOTE_MUST_ACCEPT == state_pwrq_nxt) |
                                            (ST_P_REQUEST_RESET   == state_pwrq_nxt)
                                           );

  reg             slvcandenyreqn_q;
  wire            slvcandenyreqn_nxt    = ~( 
                                            (ST_P_STOPPED         == state_pwrq_nxt) |
                                            (ST_P_REQUEST_QUIESCE_REMOTE_CAN_DENY == state_pwrq_nxt) |
                                            (ST_P_REQUEST_RESET   == state_pwrq_nxt)
                                           );

  reg             internal_resetn_q;
  wire            internal_resetn_nxt   = ~( 
                                            (ST_P_REQUEST_RESET   == state_pwrq_nxt) |
                                            (ST_P_STOPPED         == state_pwrq_nxt)
                                           );
  reg             inner_fencen_q;
  wire            inner_fencen_nxt = ~( 
                                       (ST_P_REQUEST_RESET_REMOTE == state_pwrq_nxt) |
                                       (ST_P_REQUEST_RESET   == state_pwrq_nxt) |
                                       (ST_P_STOPPED         == state_pwrq_nxt)
                                      );

  always @(posedge aclk or negedge aresetn)
    begin : p_state_pwrq_q
      if (!aresetn)
        begin
          state_pwrq_q          <= ST_P_STOPPED;
          pwrqacceptn_q         <= 1'b0;
          pwrqdeny_q            <= 1'b0;
          slvmustacceptreqn_q   <= 1'b0;
          slvcandenyreqn_q      <= 1'b0;
          internal_resetn_q     <= 1'b0;
          inner_fencen_q        <= 1'b0;
        end
      else if (state_pwrq_upd_en)
        begin
          state_pwrq_q          <= state_pwrq_nxt;
          pwrqacceptn_q         <= pwrqacceptn_nxt;
          pwrqdeny_q            <= pwrqdeny_nxt;
          slvmustacceptreqn_q   <= slvmustacceptreqn_nxt;
          slvcandenyreqn_q      <= slvcandenyreqn_nxt;
          internal_resetn_q     <= internal_resetn_nxt;
          inner_fencen_q        <= inner_fencen_nxt;
        end
    end


  // NOTE: this needs to use a glitch-free XOR gate as it
  //       is a component of *QACTIVE signals below
  wire            pwrq_if_req_active_async;
  wire            pwrq_if_active_async;
  adb400_r3_xor2 
    u_pwrq_xor_preserve_gate
  (
    .din0 (pwrqreqn_i),
    .din1 (pwrqacceptn_o),
    .dout (pwrq_if_req_active_async)
  );

  adb400_r3_or2 
    u_pwrq_if_active_preserve_gate
  (
    .din0 (pwrq_if_req_active_async),
    .din1 (pwrqdeny_o),
    .dout (pwrq_if_active_async)
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
    .din1 (pwrq_if_active_async),
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

  
  assign          pwrqacceptn_o = pwrqacceptn_q;
  assign          pwrqdeny_o    = pwrqdeny_q;

  assign          clkqacceptn_o = clkqacceptn_q;
  assign          clkqdeny_o    = clkqdeny_q;

  assign          slvmustacceptreqn_o    = slvmustacceptreqn_q;
  assign          slvcandenyreqn_o   = slvcandenyreqn_q;

  assign          wakeup_async_o = qactive_sync;

  assign          internal_resetn_o  = internal_resetn_q;

  assign          responder_fencen_o = responder_fencen_q;

  assign          inner_fencen_o     = inner_fencen_q;

  // The fences depend on both the PWRQ and the CLKQ interface states
  reg             initiator_fencen_q;
  wire            initiator_fencen_nxt  =  (
                                            ((ST_P_RUN    == state_pwrq_nxt) |
                                             (ST_P_DENIED == state_pwrq_nxt)) &
                                            ((ST_Q_RUN    == state_clkq_nxt) |
                                             (ST_Q_DENIED == state_clkq_nxt))
                                           );

  reg             outer_fencen_q;
  wire            outer_fencen_nxt = ~( 
                                       (ST_Q_STOPPED         == state_clkq_nxt) |
                                       (ST_P_REQUEST_RESET_REMOTE == state_pwrq_nxt) |
                                       (ST_P_REQUEST_RESET   == state_pwrq_nxt) |
                                       (ST_P_STOPPED         == state_pwrq_nxt) |
                                       (ST_P_EXIT            == state_pwrq_nxt)
                                      );
  wire            fencen_upd_en = (state_clkq_upd_en | state_pwrq_upd_en);

  always @(posedge aclk or negedge aresetn)
    begin : p_fencen_q
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
