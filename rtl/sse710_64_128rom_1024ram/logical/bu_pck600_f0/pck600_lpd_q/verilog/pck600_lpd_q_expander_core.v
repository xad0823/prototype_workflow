// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_lpd_q_expander_core
#(
  parameter NUM_QCHL = 2
)
(
  input  wire                 clk,
  input  wire                 reset_n,

  input  wire                 ctrl_qreqn_i,
  output wire                 ctrl_qacceptn_o,
  output wire                 ctrl_qdeny_o,

  output wire [NUM_QCHL-1:0]  dev_qreqn_o,
  input  wire [NUM_QCHL-1:0]  dev_qacceptn_i,
  input  wire [NUM_QCHL-1:0]  dev_qdeny_i,

  input  wire                 active_denied_i,

  output wire                 int_clken_o

);

localparam Q_STOPPED  = 3'b000;
localparam Q_EXIT     = 3'b001;
localparam Q_RUN      = 3'b010;
localparam Q_REQUEST  = 3'b011;
localparam Q_CONTINUE = 3'b100;
localparam Q_DENIED   = 3'b101;


  reg  [2:0]                  state;
  reg  [2:0]                  nxt_state;
  reg                         state_en;
  reg                         ack_log_clear;

  wire                        all_accepted_exit;
  wire                        all_accepted_request;
  wire                        cont_exit;
  wire                        request_denied;

  reg  [NUM_QCHL-1:0]         dev_qreqn_r;
  reg                         ctrl_qacceptn_r;
  reg                         ctrl_qdeny_r;
  reg  [NUM_QCHL-1:0]         nxt_dev_qreqn;
  reg                         nxt_ctrl_qacceptn;
  reg                         nxt_ctrl_qdeny;

  reg  [NUM_QCHL-1:0]         dev_ack_log_r;
  wire [NUM_QCHL-1:0]         nxt_dev_ack_log;

  wire                        int_clken;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state           <= Q_STOPPED;
      ctrl_qacceptn_r <= 1'b0;
      ctrl_qdeny_r    <= 1'b0;
      dev_qreqn_r     <= {NUM_QCHL{1'b0}};
    end
    else if(state_en)
    begin
      state           <= nxt_state;
      ctrl_qacceptn_r <= nxt_ctrl_qacceptn;
      ctrl_qdeny_r    <= nxt_ctrl_qdeny;
      dev_qreqn_r     <= nxt_dev_qreqn;
    end
  end

  always@*
  begin
    case(state)
    Q_STOPPED:
    begin
      nxt_state         = Q_EXIT;
      state_en          = ctrl_qreqn_i;
      nxt_ctrl_qacceptn = 1'b0;
      nxt_ctrl_qdeny    = 1'b0;
      nxt_dev_qreqn     = {NUM_QCHL{1'b1}};
      ack_log_clear     = 1'b0;
    end
    Q_EXIT:
    begin
      nxt_state         = Q_RUN;
      state_en          = all_accepted_exit;
      nxt_ctrl_qacceptn = 1'b1;
      nxt_ctrl_qdeny    = 1'b0;
      nxt_dev_qreqn     = {NUM_QCHL{1'b1}};
      ack_log_clear     = 1'b0;
    end
    Q_RUN:
    begin
      nxt_state         = (active_denied_i)? Q_DENIED:Q_REQUEST;
      state_en          = ~ctrl_qreqn_i;
      nxt_ctrl_qacceptn = 1'b1;
      nxt_ctrl_qdeny    = active_denied_i;
      nxt_dev_qreqn     = {NUM_QCHL{active_denied_i}};
      ack_log_clear     = 1'b0;
    end
    Q_REQUEST:
    begin
      nxt_state         = (request_denied)? Q_CONTINUE:Q_STOPPED;
      state_en          = all_accepted_request | request_denied;
      nxt_ctrl_qacceptn = request_denied;
      nxt_ctrl_qdeny    = request_denied;
      nxt_dev_qreqn     = {NUM_QCHL{request_denied}} & ((~dev_qacceptn_i) | dev_qdeny_i);
      ack_log_clear     = request_denied;
    end
    Q_CONTINUE:
    begin
      nxt_state         = (cont_exit)? Q_RUN:Q_CONTINUE;
      state_en          = 1'b1;
      nxt_ctrl_qacceptn = 1'b1;
      nxt_ctrl_qdeny    = ~cont_exit;
      nxt_dev_qreqn     = nxt_dev_ack_log[NUM_QCHL-1:0];
      ack_log_clear     = 1'b0;
    end
    Q_DENIED:
    begin
      nxt_state         = Q_RUN;
      state_en          = ctrl_qreqn_i;
      nxt_ctrl_qacceptn = 1'b1;
      nxt_ctrl_qdeny    = 1'b0;
      nxt_dev_qreqn     = {NUM_QCHL{1'b1}};
      ack_log_clear     = 1'b0;
    end
    default:
    begin
      nxt_state         = 3'bxxx;
      state_en          = 1'bx;
      nxt_ctrl_qacceptn = 1'bx;
      nxt_ctrl_qdeny    = 1'bx;
      nxt_dev_qreqn     = {NUM_QCHL{1'bx}};
      ack_log_clear     = 1'bx;
    end
    endcase
  end

  assign all_accepted_exit = (&dev_qacceptn_i);
  assign all_accepted_request = ~(|dev_qacceptn_i);
  assign request_denied = (|dev_qdeny_i[NUM_QCHL-1:0]) | active_denied_i;
  assign cont_exit = ctrl_qreqn_i & (&(dev_qacceptn_i & (~dev_qdeny_i) & nxt_dev_ack_log));


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dev_ack_log_r <= {NUM_QCHL{1'b0}};
    end
    else if(state_en)
    begin
      dev_ack_log_r <= nxt_dev_ack_log;
    end
  end

  assign nxt_dev_ack_log = ((~dev_qacceptn_i) | dev_qdeny_i) |
                            ((ack_log_clear) ? {NUM_QCHL{1'b0}} : dev_ack_log_r);


  assign int_clken = ((state == Q_STOPPED) &  ctrl_qreqn_i) |
                     ((state == Q_RUN)     & ~ctrl_qreqn_i) |
                     ((state != Q_STOPPED) & (state != Q_RUN));

  assign ctrl_qacceptn_o = ctrl_qacceptn_r;
  assign ctrl_qdeny_o    = ctrl_qdeny_r;

  assign dev_qreqn_o     = dev_qreqn_r;

  assign int_clken_o     = int_clken;

endmodule
