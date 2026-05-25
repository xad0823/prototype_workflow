//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module firewall_f0_clkctrl (
  input        clk,
  input        rstn,

  input        gate_busy_i,
  output       gate_hold_req_o,
  input        gate_hold_ack_i,

  input        cfg_busy_i,
  output       cfg_clk_hold_o,

  input        clk_request_i,

  output reg   clk_gate_en,

  input        qreqn_i,
  output reg   qacceptn_o,
  output reg   qdeny_o,
  output reg   qactive_o
  );

reg [2:0] current_state_r, next_state;

wire active;
reg fsm_needs_clk;
reg fsm_hold_req;
reg qacceptn_nxt;
reg qdeny_nxt;

reg cg_hold_req;
reg [1:0] cg_curr_state_r;
reg [1:0] cg_next_state;
wire clk_req;

localparam Q_STOPPED  = 3'h0;
localparam Q_EXIT     = 3'h1;
localparam Q_RUN      = 3'h2;
localparam Q_REQUEST  = 3'h3;
localparam GATE_WAIT  = 3'h4;
localparam Q_DENIED   = 3'h5;
localparam Q_CONTINUE = 3'h6;

localparam CG_GATED   = 2'h0;
localparam CG_RUNNING = 2'h1;
localparam CG_GATE1   = 2'h2;

assign active = gate_busy_i | cfg_busy_i | clk_request_i;

assign clk_req = (active && (current_state_r == Q_RUN)) | fsm_needs_clk;

always @(*)
begin
  cg_next_state = cg_curr_state_r;

  case (cg_curr_state_r)

  CG_GATED:
  begin
    cg_hold_req = 1'b1;
    clk_gate_en = 1'b0;
    if (clk_req)
      cg_next_state = CG_RUNNING;
  end

  CG_RUNNING:
  begin
    cg_hold_req = 1'b0;
    clk_gate_en = 1'b1;
    if (!clk_req)
      cg_next_state = CG_GATE1;
  end

  CG_GATE1:
  begin
    cg_hold_req = 1'b1;
    clk_gate_en = 1'b1;
    if (clk_req)
      cg_next_state = CG_RUNNING;
    else if (gate_hold_ack_i)
      cg_next_state = CG_GATED;
  end

  default:
  begin
    cg_hold_req = 1'bx;
    clk_gate_en = 1'bx;
    cg_next_state = 2'bxx;
  end

  endcase
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    cg_curr_state_r <= CG_GATED;
  else
    cg_curr_state_r <= cg_next_state;
end

always @(*)
begin
qacceptn_nxt = 1'b0;
qdeny_nxt = 1'b0;
fsm_hold_req = 1'b0;
next_state = current_state_r;
fsm_needs_clk = 1'b0;

case (current_state_r)

Q_STOPPED:
begin
  qacceptn_nxt = 1'b0;
  qdeny_nxt = 1'b0;
  fsm_hold_req = 1'b1;
  if (qreqn_i)
  begin
    next_state = Q_EXIT;
  end
end

Q_EXIT:
begin
  qacceptn_nxt = 1'b1;
  qdeny_nxt = 1'b0;
  fsm_hold_req = 1'b1;
  next_state = Q_RUN;
end

Q_RUN:
begin
  qacceptn_nxt = 1'b1;
  qdeny_nxt = 1'b0;
  fsm_hold_req = 1'b0;
  if (!qreqn_i)
  begin
    fsm_needs_clk = 1'b1;
    next_state = Q_REQUEST;
  end
end

Q_REQUEST:
begin
  fsm_hold_req = 1'b0;
  fsm_needs_clk = 1'b1;
  if (active)
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b1;
    next_state = Q_DENIED;
  end
  else
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b0;
    next_state = GATE_WAIT;
  end
end

GATE_WAIT:
begin
  qacceptn_nxt = 1'b1;
  qdeny_nxt = 1'b0;
  fsm_hold_req = 1'b1;
  fsm_needs_clk = 1'b1;
  if (active)
  begin
    qdeny_nxt = 1'b1;
    next_state = Q_DENIED;
  end
  else
    if (gate_hold_ack_i) next_state = Q_STOPPED;
end

Q_DENIED:
begin
  qacceptn_nxt = 1'b1;
  qdeny_nxt = 1'b1;
  fsm_hold_req = 1'b0;
  fsm_needs_clk = 1'b1;
  if (qreqn_i) next_state = Q_CONTINUE;
end

Q_CONTINUE:
begin
  qacceptn_nxt = 1'b1;
  qdeny_nxt = 1'b0;
  fsm_hold_req = 1'b0;
  fsm_needs_clk = 1'b1;
  next_state = Q_RUN;
end

default:
begin
  qacceptn_nxt = 1'bx;
  qdeny_nxt = 1'bx;
  fsm_hold_req = 1'bx;
  fsm_needs_clk = 1'bx;
  next_state = 3'bxxx;
end

endcase
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    current_state_r <= Q_STOPPED;
    qacceptn_o <= 1'b0;
    qdeny_o <= 1'b0;
  end
  else
  begin
    current_state_r <= next_state;
    qacceptn_o <= qacceptn_nxt;
    qdeny_o <= qdeny_nxt;
  end
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    qactive_o <= 1'b0;
  else
    qactive_o <= active;
end

assign gate_hold_req_o = fsm_hold_req | cg_hold_req;
assign cfg_clk_hold_o  = fsm_hold_req | cg_hold_req;

endmodule
