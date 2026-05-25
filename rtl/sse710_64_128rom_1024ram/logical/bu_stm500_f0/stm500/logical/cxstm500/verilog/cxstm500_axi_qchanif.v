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

module cxstm500_axi_qchanif (

  input  CLK,            //Clock
  input  ARESETn,        //Reset

  input  AXIQREQn,       //Quiscence Request
  output AXIQACCEPTn,    //Quiscence Request Acknowledge
  output AXIQDENY,       //Quiscence Request Deny
  output AXIQACTIVE,     //STM Active

  input  AWAKEUP,        //AXI Active Signal

  input  axi_busy_i,     //AXI Busy
  input  dma_busy_i,     //DMA Busy
  input  qforcedeny_i,   //Q-Channel Force Deny Override

  output q_stop_o,       //Q-Channel is in Q_STOPPED or Q_STOPPING
  output q_stopped_o     //Q-Channel is in Q_STOPPED
);

  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------

  wire qreqn_sync;

  wire nxt_qactive;
  wire qactive_ext;

  //----------------------------------------------------------------------------
  // Registers
  //----------------------------------------------------------------------------

  reg [1:0] state;
  reg [1:0] nxt_state;

  reg nxt_qacceptn;
  reg nxt_qdeny;

  reg [1:0] nxt_q_stop_count;

  reg qacceptn_reg;
  reg qdeny_reg;
  reg qactive_reg;

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
  always @(posedge CLK or negedge ARESETn) begin
    if (~ARESETn)
      state <= Q_STOPPED;
    else
      state <= nxt_state;
  end

  //Counter to abort Q_STOPPED request to AXI + DMA IFs
  //if the sub-blocks are no longer idle
  always @(posedge CLK or negedge ARESETn) begin
    if (~ARESETn)
      q_stop_count <= 2'b00;
    else if (state == Q_STOPPING)
      q_stop_count <= nxt_q_stop_count;
  end

  //Internal AXIQACTIVE (excludes AWAKEUP)
  assign nxt_qactive = axi_busy_i |   //AXI IF Active
                       dma_busy_i |   //DMA IF Active
                       qforcedeny_i;  //Force deny overrides QACTIVE to high

  //----------------------------------------------------------------------------
  // Synchronize AXIQREQn
  //----------------------------------------------------------------------------

  cxstm500_synchronizer u_cxstm500_synchronizer (
    .CLK      (CLK),
    .RESETn   (ARESETn),
    .sync_i   (AXIQREQn),
    .sync_o   (qreqn_sync)
  );

  //----------------------------------------------------------------------------
  // Q-Channel State Machine
  //----------------------------------------------------------------------------

  //If AXIQACTIVE and QFORCEDENY are low, then Q-channel will attempt to
  //ACCEPT a quiesence request. The next state will be Q_STOPPING in which the STM attempts to
  //ensure all AXI interfaces are held idle. If all interfaces succesfully go idle then the
  //next state will be Q_STOPPED and AXIQACCEPTn will be taken low.
  //
  //If the STM fails to go idle on all interfaces (for example, a new transaction arrives), or
  //AXIQACTIVE is high at the time of AXIQREQn, then the STM will DENY the request

  always @(*) begin
    case(state)

      Q_RUN : begin //Q Channel in RUN state (qreqn_sync high, AXIQACCEPTn high, AXIQDENY low)

        if(~qreqn_sync) begin

          //If qreqn_sync is asserted then transition to Q_DENIED or Q_STOPPING
          nxt_state    = ~(nxt_qactive) ?  Q_STOPPING :  Q_DENIED;
          nxt_qacceptn =                                ~Q_ACCEPT;
          nxt_qdeny    = ~(nxt_qactive) ? ~Q_DENY     :  Q_DENY;
          nxt_q_stop_count = 2'b00;

        end else begin

          //Else maintain current state
          nxt_state    = state;
          nxt_qacceptn = qacceptn_reg;
          nxt_qdeny    = qdeny_reg;
          nxt_q_stop_count = 2'b00;

        end
      end

      Q_DENIED : begin //Q Channel in DENIED state (qreqn_sync low, AXIQACCEPTn high, AXIQDENY high)

        //If qreqn_sync is de-asserted then exit Q_DENIED into Q_RUN
        nxt_state    = qreqn_sync ?  Q_RUN  :  Q_DENIED;
        nxt_qacceptn =                        ~Q_ACCEPT;
        nxt_qdeny    = qreqn_sync ? ~Q_DENY :  Q_DENY;
        nxt_q_stop_count = 2'b00;

      end

      Q_STOPPING : begin //Q Channel in temporary STOPPING state prior to AXIQACCEPTn being de-asserted

        //If STM has gone active or force deny has been set then transition to DENIED.
        //If the q_stop_count timer is reached and all interfaces are still idle and then transition to Q_STOPPED
        //Else remain in Q_STOPPING until all interface have gone idle or timeout reached
        nxt_state    =                               (nxt_qactive)  ?  Q_DENIED  :
                                           (q_stop_count == 2'b11)  ?  Q_STOPPED :  Q_STOPPING;
        nxt_qacceptn =     (~nxt_qactive & (q_stop_count == 2'b11)) ?  Q_ACCEPT  : ~Q_ACCEPT;
        nxt_qdeny    =                              (nxt_qactive)   ?  Q_DENY    : ~Q_DENY;
        nxt_q_stop_count =  (nxt_qactive | (q_stop_count == 2'b11)) ?  2'b00 : q_stop_count + 2'b01;

      end

      Q_STOPPED : begin //Q Channel in STOPPED state (qreqn_sync low, AXIQACCEPTn low, AXIQDENY low)

        //If qreqn_sync is de-asserted then exit Q_STOPPED into Q_RUN
        nxt_state    = qreqn_sync ?  Q_RUN    :  Q_STOPPED;
        nxt_qacceptn = qreqn_sync ? ~Q_ACCEPT :  Q_ACCEPT;
        nxt_qdeny    =                          ~Q_DENY;
        nxt_q_stop_count = 2'b00;

      end

      default : begin

        nxt_state    = 2'bxx;
        nxt_qacceptn = 1'bx;
        nxt_qdeny    = 1'bx;
        nxt_q_stop_count = 2'bxx;

      end

    endcase
  end

  //----------------------------------------------------------------------------
  // Register State Machine Outputs
  //----------------------------------------------------------------------------

  //AXIQACCEPTn
  always @(posedge CLK or negedge ARESETn) begin
    if(~ARESETn)
      qacceptn_reg <= Q_ACCEPT;
    else
      qacceptn_reg <= nxt_qacceptn;
  end

  //AXIQDENY
  always @(posedge CLK or negedge ARESETn) begin
    if(~ARESETn)
      qdeny_reg <= ~Q_DENY;
    else
      qdeny_reg <= nxt_qdeny;
  end

  //AXIQACTIVE (internal)
  always @(posedge CLK or negedge ARESETn) begin
    if(~ARESETn)
      qactive_reg <= 1'b0;
    else
      qactive_reg <= nxt_qactive;
  end

  //----------------------------------------------------------------------------
  // OR AXIQACTIVE with AWAKEUP
  // Instanced OR gate used to allow "glitch free" gate to be inserted during
  // implementation
  //----------------------------------------------------------------------------

  cxstm500_qactive_or_gate u_cxstm500_qactive_or_gate (
    .qactive_i      (qactive_reg),
    .wakeup_i       (AWAKEUP),
    .qactive_o      (qactive_ext)
  );

  //----------------------------------------------------------------------------
  // Output Assignment
  //----------------------------------------------------------------------------

  assign AXIQACCEPTn  = qacceptn_reg;
  assign AXIQDENY     = qdeny_reg;
  assign AXIQACTIVE   = qactive_ext;

  assign q_stop_o    = (state[1] == 1'b1);
  assign q_stopped_o = (state == Q_STOPPED);

  `ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // Illegal State Transitions
  reg [1:0] state_prev;
  always @(posedge CLK or negedge ARESETn) begin
    if (~ARESETn)
      state_prev <= Q_STOPPED;
    else
      state_prev <= state;
  end

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopping_to_run (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_STOPPING) & (state == Q_RUN))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_run_to_stopped (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_RUN) & (state == Q_STOPPED))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopped_to_denied (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_STOPPED) & (state == Q_DENIED))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_stopped_to_stopping (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_STOPPED) & (state == Q_STOPPING))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_denied_to_stopping (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_DENIED) & (state == Q_STOPPING))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal Q-Channel State transition")
    ovl_never_illegal_state_trans_denied_to_stopped (
      .clk        (CLK),
      .reset_n    (ARESETn),
      .test_expr  ((state_prev == Q_DENIED) & (state == Q_STOPPING))
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "Q-Channel State is X")
    ovl_never_unknown_qchan_state (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (state)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qacceptn_reg is X")
    ovl_never_unknown_qchan_qacceptn_reg (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (qacceptn_reg)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "qdeny_reg is X")
    ovl_never_unknown_qchan_qdeny_reg (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (qdeny_reg)
    );

`endif


endmodule
