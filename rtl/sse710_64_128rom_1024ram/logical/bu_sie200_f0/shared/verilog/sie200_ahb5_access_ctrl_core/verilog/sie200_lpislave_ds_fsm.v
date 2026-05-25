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
//      Checked In          : Fri Sep 30 15:46:24 2016 +0100
//
//      Revision            : a2eb54f
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_lpislave_ds_fsm # (
  parameter QS_POWER_EN = 1
)
(
  input  wire                     clk,
  input  wire                     reset_n,
  input  wire                     qreq_sync_n,
  output wire                     qaccept_n,
  output wire                     qdeny,

  input  wire                     us_pwr_req,
  output wire                     us_pwr_ack,

  output wire                     ds_pwr_req,
  input  wire                     ds_pwr_ack,

  output reg                      lp_request,
  input  wire                     dev_active,
  input  wire                     lp_done,
  output reg                      dev_run,
  output reg                      cg_en
);

  reg [3:0] state,
            next_state;

  reg       pwr_ack;
  localparam Q_STOPPED      = 4'b0001;
  localparam Q_EXIT         = 4'b0000;
  localparam Q_RUN          = 4'b0100;
  localparam Q_LOOP         = 4'b1100;
  localparam Q_RUN_PWR      = 4'b1101;
  localparam Q_REQUEST      = 4'b0101;
  localparam Q_STOPPED_PWR  = 4'b1001;
  localparam Q_DENY_HOLD    = 4'b0111;
  localparam Q_DENY         = 4'b0110;
  localparam UNUSED_2       = 4'b0010;
  localparam UNUSED_3       = 4'b0011;
  localparam UNUSED_8       = 4'b1000;
  localparam UNUSED_10      = 4'b1010;
  localparam UNUSED_11      = 4'b1011;
  localparam UNUSED_14      = 4'b1110;
  localparam UNUSED_15      = 4'b1111;

  always @(*) begin
    next_state = state;
    dev_run    = 1'b1;
    cg_en      = 1'b1;
    lp_request = 1'b0;
    pwr_ack    = 1'b0;
    case (state)
      Q_STOPPED_PWR: begin
        dev_run     = 1'b0;
        cg_en       = qreq_sync_n;
        lp_request  = 1'b1;
        pwr_ack     = 1'b1;
        if(qreq_sync_n) begin
          next_state = Q_RUN_PWR;
        end
      end
      Q_RUN_PWR: begin
        cg_en       = !qreq_sync_n;
        lp_request  = us_pwr_req;
        pwr_ack     = 1'b1;
        if(!us_pwr_req) begin
          next_state = Q_LOOP;
        end
        else if (!qreq_sync_n) begin
          next_state = Q_STOPPED_PWR;
        end
      end
      Q_LOOP: begin
        lp_request  = us_pwr_req;
        pwr_ack     = lp_done;
        if(lp_done == us_pwr_req) begin
          if(lp_done) begin
            next_state = Q_RUN_PWR;
          end
          else begin
            next_state = Q_RUN;
          end
        end
      end
      Q_STOPPED: begin
        dev_run     = 1'b0;
        cg_en       = qreq_sync_n;
        lp_request  = !qreq_sync_n | us_pwr_req;
        pwr_ack     = 1'b0;
        if (qreq_sync_n) begin
          if (us_pwr_req) begin
            next_state = Q_RUN_PWR;
          end
          else if (lp_done) begin
            next_state = Q_EXIT;
          end
          else begin
            next_state = Q_RUN;
          end
        end
      end
      Q_EXIT: begin
        dev_run = 1'b0;
        if (!lp_done) begin
          next_state = Q_RUN;
        end
      end
      Q_RUN: begin
        cg_en       = !qreq_sync_n;
        lp_request  = (!qreq_sync_n & !dev_active) | (qreq_sync_n & us_pwr_req);
        if (!qreq_sync_n) begin
          if (dev_active) begin
            next_state = Q_DENY;
          end
          else begin
            if (us_pwr_req) begin
              next_state = Q_LOOP;
            end
            else if (lp_done) begin
              next_state = Q_STOPPED;
            end
            else begin
              next_state = Q_REQUEST;
            end
          end
        end
        else if (us_pwr_req) begin
          next_state = Q_LOOP;
        end
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
        lp_request= 1'b1;
        if (lp_done) begin
          next_state = Q_DENY;
        end
      end
      Q_DENY: begin
        if (qreq_sync_n && !lp_done) begin
          if (us_pwr_req) begin
             next_state = Q_LOOP;
          end
          else begin
             next_state = Q_RUN;
          end
        end
      end
      UNUSED_2,
      UNUSED_3,
      UNUSED_8,
      UNUSED_10,
      UNUSED_11,
      UNUSED_14,
      UNUSED_15: begin
        next_state = QS_POWER_EN ? Q_STOPPED_PWR :Q_STOPPED;
      end
      default: begin
        next_state = 4'bxxxx;
        dev_run    = 1'bx;
        cg_en      = 1'bx;
        lp_request = 1'bx;
      end
    endcase
  end

  wire state_en = (next_state != state);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      state <= QS_POWER_EN ? Q_STOPPED_PWR : Q_STOPPED;
    else if (state_en)
      state <= next_state;
  end

  assign qaccept_n = state[2];
  assign qdeny     = state[1];


  assign ds_pwr_req = us_pwr_req;
  assign us_pwr_ack = (pwr_ack ^ ds_pwr_ack) ? ~us_pwr_req : pwr_ack;







endmodule
