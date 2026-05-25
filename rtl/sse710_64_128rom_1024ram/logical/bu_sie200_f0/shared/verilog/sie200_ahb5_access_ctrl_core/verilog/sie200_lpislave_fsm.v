// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Sep 2 12:22:10 2016 +0100
//
//      Revision            : 9b3072b
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_lpislave_fsm
(
  input  wire                     clk,
  input  wire                     reset_n,
  input  wire                     qreq_sync_n,
  output wire                     qaccept_n,
  output wire                     qdeny,
  output reg                      lp_request,
  input  wire                     dev_active,
  input  wire                     lp_done,
  output reg                      dev_run,
  output reg                      cg_en
);

  reg [2:0] state,
            next_state;

  localparam Q_STOPPED   = 3'b000;
  localparam Q_RUN       = 3'b101;
  localparam Q_REQUEST   = 3'b100;
  localparam Q_EXIT      = 3'b001;
  localparam Q_DENY_HOLD = 3'b111;
  localparam Q_DENY      = 3'b110;
  localparam UNUSED_2    = 3'b010;
  localparam UNUSED_3    = 3'b011;

  always @(state or qreq_sync_n or lp_done or dev_active) begin
    next_state = state;
    dev_run    = 1'b1;
    cg_en      = 1'b1;
    lp_request = 1'b0;
    case (state)
      Q_STOPPED: begin
        dev_run = 1'b0;
        cg_en = qreq_sync_n;
        lp_request = !qreq_sync_n;
        if (qreq_sync_n)
          if (lp_done)
            next_state = Q_EXIT;
          else
            next_state = Q_RUN;
      end
      Q_EXIT: begin
        dev_run = 1'b0;
        if (!lp_done)
          next_state = Q_RUN;
      end
      Q_RUN: begin
        cg_en = !qreq_sync_n;
        lp_request = !qreq_sync_n & !dev_active;
        if (!qreq_sync_n)
          if (dev_active)
            next_state = Q_DENY;
          else
            if (lp_done)
              next_state = Q_STOPPED;
            else
              next_state = Q_REQUEST;
      end
      Q_REQUEST: begin
        lp_request = 1'b1;
        if (!qreq_sync_n)
          if (dev_active)
            if (lp_done)
              next_state = Q_DENY;
            else
              next_state = Q_DENY_HOLD;
          else if (lp_done)
            next_state = Q_STOPPED;
      end
      Q_DENY_HOLD: begin
        lp_request = 1'b1;
        if (lp_done)
          next_state = Q_DENY;
      end
      Q_DENY: begin
        if (qreq_sync_n && !lp_done)
          next_state = Q_RUN;
      end
      UNUSED_2: begin
        next_state = Q_STOPPED;
      end
      UNUSED_3: begin
        next_state = Q_STOPPED;
      end
      default: begin
        next_state = 3'bxxx;
        dev_run    = 1'bx;
        cg_en      = 1'bx;
        lp_request = 1'bx;
      end
    endcase
  end

  wire state_en = (next_state != state);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      state <= Q_STOPPED;
    else if (state_en)
      state <= next_state;
  end

  assign qaccept_n = state[2];
  assign qdeny     = state[1];

endmodule
