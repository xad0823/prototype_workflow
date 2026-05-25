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
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      STM Q Channel Low Power Interface
//-----------------------------------------------------------------------------

module cxstm500_stm_qchanif (

  input  CLK,            //Clock
  input  STMRESETn,      //Reset

  input  STMQREQn,       //Quiscence Request
  output STMQACCEPTn,    //Quiscence Request Acknowledge
  output STMQDENY,       //Quiscence Request Deny
  output STMQACTIVE,     //STM Active

  input  PWAKEUP,        //APB Active Signal

  input  apb_busy_i,     //APB Busy
  input  hw_busy_i,      //HW Busy
  input  tgu_busy_i,     //TGU Busy (Tracegen, FIFO, Packer, ATB)
  input  AFVALIDM,       //Flush Request
  input  hw_enable_i,    //HW IF Enabled
  input  qhwevoverride_i,//Q-Channel HW Event Override
  input  qforcedeny_i,   //Q-Channel Force Deny Override
  input  itctl_i,        //Integration mode

  output q_stopped_o,    //Q-Channel is in Q_STOPPED
  output q_stop_o,       //Q-Channel is in Q_STOPPED or Q_STOPPING
  output q_flush_o       //Q-Channel initiated auto-flush
);

  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------

  wire qreqn_sync;

  wire nxt_qactive;
  wire qactive_ext;

  wire nxt_q_autoflush;
  wire q_autoflush_we;

  //----------------------------------------------------------------------------
  // Registers
  //----------------------------------------------------------------------------

  reg [1:0] state;
  reg [1:0] nxt_state;

  reg nxt_qacceptn;
  reg nxt_qdeny;
  reg nxt_q_flush;

  reg [1:0] nxt_q_stop_count;

  reg qacceptn_reg;
  reg qacceptn_reg2;
  reg qdeny_reg;
  reg qactive_reg;
  reg qflush_reg;

  reg q_autoflush_reg;

  reg [1:0] q_stop_count;

  //----------------------------------------------------------------------------
  // Parameters
  //----------------------------------------------------------------------------

  //State Values
  localparam Q_RUN      = 2'b00;
  localparam Q_DENIED   = 2'b01;
  localparam Q_STOPPING = 2'b10;
  localparam Q_STOPPED  = 2'b11;

  //Signal Values
  localparam Q_ACCEPT = 1'b0;
  localparam Q_DENY   = 1'b1;

  //----------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //----------------------------------------------------------------------------

  //State Machine state
  always @(posedge CLK or negedge STMRESETn) begin
    if (~STMRESETn)
      state <= Q_STOPPED;
    else
      state <= nxt_state;
  end

  //Counter to abort Q_STOPPED request to AXI, APB, DMA, ATB, HW IFs
  //if the sub-blocks are no longer idle
  always @(posedge CLK or negedge STMRESETn) begin
    if (~STMRESETn)
      q_stop_count <= 2'b00;
    else if (state == Q_STOPPING)
      q_stop_count <= nxt_q_stop_count;
  end

  //Internal STMQACTIVE (excludes PWAKEUP)
  assign nxt_qactive = apb_busy_i |                      //APB IF Active
                       hw_busy_i  |                      //HW IF Active
                       tgu_busy_i |                      //TGU Active (Tracegen, FIFO, Packer, ATB IF)
                       AFVALIDM   |                      //Flush request underway
                       qforcedeny_i |                    //Force deny overrides QACTIVE to high
                       itctl_i |                         //Integration mode overrides QACTIVE to high
                       (hw_enable_i & qhwevoverride_i);  //HW IF Enabled and force denial override active (see STMAUXR)

  //----------------------------------------------------------------------------
  // Synchronize STMQREQn
  //----------------------------------------------------------------------------

  cxstm500_synchronizer u_cxstm500_synchronizer (
    .CLK      (CLK),
    .RESETn   (STMRESETn),
    .sync_i   (STMQREQn),
    .sync_o   (qreqn_sync)
  );

  //----------------------------------------------------------------------------
  // Q-Channel State Machine
  //----------------------------------------------------------------------------

  //If STMQACTIVE and QFORCEDENY are low, then Q-channel will attempt to
  //ACCEPT a quiesence request. The next state will be Q_STOPPING in which the STM attempts to
  //ensure all interfaces are held idle. If all interfaces succesfully go idle then the
  //next state will be Q_STOPPED and STMQACCEPTn will be taken low.
  //
  //If the STM fails to go idle on all interfaces (for example, a new transaction arrives), or
  //STMQACTIVE is high at the time of STMQREQn, then the STM will DENY the request
  //
  //If a request is DENIED the Q-Channel will initiate autoflush of STM (nxt_q_flush is set)
  //until the STM goes idle, at which point autoflush will be removed

  always @(*) begin
    case(state)

      Q_RUN : begin //Q Channel in RUN state (qreqn_sync high, STMQACCEPTn high, STMQDENY low)

        if(~qreqn_sync) begin

          //If qreqn_sync is asserted then transition to Q_DENIED or Q_STOPPING
          nxt_state    = ~(nxt_qactive) ?  Q_STOPPING :  Q_DENIED;
          nxt_qacceptn =                                ~Q_ACCEPT;
          nxt_qdeny    = ~(nxt_qactive) ? ~Q_DENY     :  Q_DENY;
          nxt_q_flush  = ~(nxt_qactive) ?  1'b0       :  1'b1;
          nxt_q_stop_count = 2'b00;

        end else begin

          //Else maintain current state
          nxt_state    = state;
          nxt_qacceptn = qacceptn_reg;
          nxt_qdeny    = qdeny_reg;
          nxt_q_flush  = qflush_reg;
          nxt_q_stop_count = 2'b00;

        end
      end

      Q_DENIED : begin //Q Channel in DENIED state (qreqn_sync low, STMQACCEPTn high, STMQDENY high)

        //If qreqn_sync is de-asserted then exit Q_DENIED into Q_RUN
        nxt_state    = qreqn_sync ?  Q_RUN  :  Q_DENIED;
        nxt_qacceptn =                        ~Q_ACCEPT;
        nxt_qdeny    = qreqn_sync ? ~Q_DENY :  Q_DENY;
        nxt_q_flush  =                         1'b0;
        nxt_q_stop_count = 2'b00;

      end

      Q_STOPPING : begin //Q Channel in temporary STOPPING state prior to STMQACCEPTn being de-asserted

        //If STM has gone active or force deny has been set then transition to DENIED.
        //If the q_stop_count timer is reached and all interfaces are still idle and then transition to Q_STOPPED
        //Else remain in Q_STOPPING until all interface have gone idle or timeout reached
        nxt_state    =                               (nxt_qactive)  ?  Q_DENIED  :
                                           (q_stop_count == 2'b11)  ?  Q_STOPPED :  Q_STOPPING;
        nxt_qacceptn =     (~nxt_qactive & (q_stop_count == 2'b11)) ?  Q_ACCEPT  : ~Q_ACCEPT;
        nxt_qdeny    =                              (nxt_qactive)   ?  Q_DENY    : ~Q_DENY;
        nxt_q_flush  =                              (nxt_qactive)   ?  1'b1      :  1'b0;
        nxt_q_stop_count =  (nxt_qactive | (q_stop_count == 2'b11)) ?  2'b00 : q_stop_count + 2'b01;

      end

      Q_STOPPED : begin //Q Channel in STOPPED state (qreqn_sync low, STMQACCEPTn low, STMQDENY low)

        //If qreqn_sync is de-asserted then exit Q_STOPPED into Q_RUN
        nxt_state    = qreqn_sync ?  Q_RUN    :  Q_STOPPED;
        nxt_qacceptn = qreqn_sync ? ~Q_ACCEPT :  Q_ACCEPT;
        nxt_qdeny    =                          ~Q_DENY;
        nxt_q_flush  =                           1'b0;
        nxt_q_stop_count = 2'b00;

      end

      default : begin

        nxt_state    = 2'bxx;
        nxt_qacceptn = 1'bx;
        nxt_qdeny    = 1'bx;
        nxt_q_flush  = 1'bx;
        nxt_q_stop_count = 2'bxx;

      end

    endcase
  end

  //----------------------------------------------------------------------------
  // Register State Machine Outputs
  //----------------------------------------------------------------------------

  //STMQACCEPTn
  always @(posedge CLK or negedge STMRESETn) begin
    if(~STMRESETn)
      qacceptn_reg <= Q_ACCEPT;
    else
      qacceptn_reg <= nxt_qacceptn;
  end

  //STMQACCEPTn
  //Delayed by an additional clock cycle before output to allow time for the
  //registered output AFREADYM to be held high before the clock controller is
  //able to remove the clock
  always @(posedge CLK or negedge STMRESETn) begin
    if(~STMRESETn)
      qacceptn_reg2 <= Q_ACCEPT;
    else
      qacceptn_reg2 <= qacceptn_reg;
  end

  //STMQDENY
  always @(posedge CLK or negedge STMRESETn) begin
    if(~STMRESETn)
      qdeny_reg <= ~Q_DENY;
    else
      qdeny_reg <= nxt_qdeny;
  end

  //STMQACTIVE (internal)
  always @(posedge CLK or negedge STMRESETn) begin
    if(~STMRESETn)
      qactive_reg <= 1'b0;
    else
      qactive_reg <= nxt_qactive;
  end

  //Q-Channel Initiated AUTOFLUSH
  always @(posedge CLK or negedge STMRESETn) begin
    if(~STMRESETn)
      qflush_reg <= 1'b0;
    else
      qflush_reg <= nxt_q_flush;
  end

  //----------------------------------------------------------------------------
  // AUTOFLUSH on QDENIED
  //----------------------------------------------------------------------------

  //When a Q Channel request is denied the STM will enable AUTOFLUSH
  //until the TGU is idle - q_autoflush is set for the duration of the flush

  assign q_autoflush_we  = qflush_reg | ~tgu_busy_i;
  assign nxt_q_autoflush = qflush_reg;

  always @(posedge CLK or negedge STMRESETn) begin

    if(~STMRESETn)
      q_autoflush_reg <= 1'b0;

    else if(q_autoflush_we)
      q_autoflush_reg <= nxt_q_autoflush;

  end

  //----------------------------------------------------------------------------
  // OR STMQACTIVE with PWAKEUP
  // Instanced OR gate used to allow "glitch free" gate to be inserted during
  // implementation
  //----------------------------------------------------------------------------

  cxstm500_qactive_or_gate u_cxstm500_qactive_or_gate (
    .qactive_i      (qactive_reg),
    .wakeup_i       (PWAKEUP),
    .qactive_o      (qactive_ext)
  );

  //----------------------------------------------------------------------------
  // Output Assignment
  //----------------------------------------------------------------------------

  assign STMQACCEPTn  = qacceptn_reg2;
  assign STMQDENY     = qdeny_reg;
  assign STMQACTIVE   = qactive_ext;

  assign q_stopped_o = (state == Q_STOPPED);
  assign q_stop_o    = (state[1] == 1'b1);
  assign q_flush_o   = q_autoflush_reg;

  `ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // Illegal State Transitions
  reg [1:0] state_prev;
  always @(posedge CLK or negedge STMRESETn) begin
    if (~STMRESETn)
      state_prev <= Q_STOPPED;
    else
      state_prev <= state;
  end

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopping_to_run (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_STOPPING) & (state == Q_RUN))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_run_to_stopped (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_RUN) & (state == Q_STOPPED))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopped_to_denied (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_STOPPED) & (state == Q_DENIED))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopped_to_stopping (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_STOPPED) & (state == Q_STOPPING))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_denied_to_stopping (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_DENIED) & (state == Q_STOPPING))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_denied_to_stopped (
      .clk        (CLK),
      .reset_n    (STMRESETn),
      .test_expr  ((state_prev == Q_DENIED) & (state == Q_STOPPING))
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "Q-Channel State is X")
    ovl_never_unknown_qchan_state (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (state)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qacceptn_reg is X")
    ovl_never_unknown_qchan_qacceptn_reg (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (qacceptn_reg)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qacceptn_reg2 is X")
    ovl_never_unknown_qchan_qacceptn_reg2 (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (qacceptn_reg2)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qdeny_reg is X")
    ovl_never_unknown_qchan_qdeny_reg (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (qdeny_reg)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qflush_reg is X")
    ovl_never_unknown_qchan_qflush_reg (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (qflush_reg)
    );

`endif


endmodule
