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

module firewall_f0_comp_pwrctrl (
  input        clk,
  input        rstn,

  input        gate_busy_i,
  output reg   gate_hold_req_o,
  input        gate_hold_ack_i,

  input        rb_pwr_deny_i,
  output reg   default_state_o,

  input        cfg_busy_i,
  output reg   cfg_dis_o,
  output reg [1:0] cfg_con_o,
  input        cfg_accept_i,

  input        clk_hold_i,
  output wire  clk_request_o,

  input wire   qreqn_i,
  output reg   qacceptn_o,
  output reg   qdeny_o,
  output reg   qactive_o
  );

reg [2:0] current_q_state_r, next_q_state;
reg [2:0] current_i_state_r, next_i_state;
reg qacceptn_nxt;
reg qdeny_nxt;
reg gate_hold_req_nxt;
reg cfg_dis_nxt;

wire active;
reg exit_req;
reg exit_ack;
reg stop_req;
reg stop_ack;
reg stop_deny;

localparam Q_STOPPED = 3'h0;
localparam Q_EXIT = 3'h1;
localparam Q_RUN = 3'h2;
localparam Q_REQUEST = 3'h3;
localparam Q_DENIED = 3'h4;
localparam Q_CONTINUE = 3'h5;

localparam DISCONNECTED = 3'h0;
localparam CON = 3'h1;
localparam CONNECTED = 3'h2;
localparam GATING = 3'h3;
localparam DISCON = 3'h4;
localparam DISCON_ABORT = 3'h5;
localparam RECON0 = 3'h6;
localparam RECON1 = 3'h7;

assign active = gate_busy_i | cfg_busy_i | rb_pwr_deny_i;

always @(*)
begin
  next_q_state = current_q_state_r;

  case (current_q_state_r)

  Q_STOPPED:
  begin
    qacceptn_nxt = 1'b0;
    qdeny_nxt = 1'b0;
    exit_req = 1'b0;
    stop_req = 1'b0;
    default_state_o = 1'b0;
    if (qreqn_i)
      next_q_state = Q_EXIT;
  end

  Q_EXIT:
  begin
    qacceptn_nxt = 1'b0;
    qdeny_nxt = 1'b0;
    exit_req = 1'b1;
    stop_req = 1'b0;
    default_state_o = 1'b0;
    if (exit_ack)
    begin
      qacceptn_nxt = 1'b1;
      qdeny_nxt = 1'b0;
      next_q_state = Q_RUN;
    end
  end

  Q_RUN:
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b0;
    exit_req = 1'b0;
    stop_req = 1'b0;
    default_state_o = 1'b0;
    if (!qreqn_i)
      next_q_state = Q_REQUEST;
  end

  Q_REQUEST:
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b0;
    exit_req = 1'b0;
    stop_req = 1'b1;
    default_state_o = 1'b0;
    if (stop_deny)
    begin
      qdeny_nxt = 1'b1;
      next_q_state = Q_DENIED;
    end
    else if (stop_ack)
    begin
      qacceptn_nxt = 1'b0;
      default_state_o = 1'b1;
      next_q_state = Q_STOPPED;
    end
  end

  Q_DENIED:
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b1;
    exit_req = 1'b0;
    stop_req = 1'b0;
    default_state_o = 1'b0;
    if (qreqn_i)
      next_q_state = Q_CONTINUE;
  end

  Q_CONTINUE:
  begin
    qacceptn_nxt = 1'b1;
    qdeny_nxt = 1'b1;
    exit_req = 1'b0;
    stop_req = 1'b0;
    default_state_o = 1'b0;
    if (current_i_state_r == CONNECTED)
    begin
      qdeny_nxt = 1'b0;
      next_q_state = Q_RUN;
    end
  end

  default:
  begin
    qacceptn_nxt = 1'bx;
    qdeny_nxt = 1'bx;
    next_q_state = 3'bxxx;
    exit_req = 1'bx;
    stop_req = 1'bx;
    default_state_o = 1'bx;
  end

  endcase
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    current_q_state_r <= Q_STOPPED;
    qacceptn_o <= 1'b0;
    qdeny_o <= 1'b0;
    cfg_dis_o <= 1'b0;
  end
  else if (!clk_hold_i)
  begin
    current_q_state_r <= next_q_state;
    qacceptn_o <= qacceptn_nxt;
    qdeny_o <= qdeny_nxt;
    cfg_dis_o <= cfg_dis_nxt;
  end
end

always @(*)
begin
  next_i_state = current_i_state_r;

  case (current_i_state_r)

  DISCONNECTED:
  begin
    gate_hold_req_nxt = 1'b1;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (exit_req)
    begin
      cfg_con_o = 2'b11; 
      next_i_state = CON;
    end
  end

  CON:
  begin
    gate_hold_req_nxt = 1'b1;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (cfg_accept_i)
    begin
      gate_hold_req_nxt = 1'b0;
      exit_ack = 1'b1;
      next_i_state = CONNECTED;
    end
  end

  CONNECTED:
  begin
    gate_hold_req_nxt = 1'b0;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (stop_req)
    begin
      if (active)
      begin
        stop_deny = 1'b1;
        gate_hold_req_nxt = 1'b0;
      end
      else
      begin
        gate_hold_req_nxt = 1'b1;
        next_i_state = GATING;
      end
    end
  end

  GATING:
  begin
    gate_hold_req_nxt = 1'b1;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (gate_busy_i | rb_pwr_deny_i)
    begin
      gate_hold_req_nxt = 1'b0;
      stop_deny = 1'b1;
      next_i_state = CONNECTED;
    end
    else if (gate_hold_ack_i)
    begin
      gate_hold_req_nxt = 1'b1;
      cfg_dis_nxt = 1'b1;
      next_i_state = DISCON;
    end
  end

  DISCON:
  begin
    gate_hold_req_nxt = 1'b1;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (gate_busy_i | rb_pwr_deny_i) 
    begin
      stop_deny = 1'b1;
      if (cfg_accept_i)
        next_i_state = RECON0;
      else
        next_i_state = DISCON_ABORT;
    end
    else if (cfg_accept_i)
    begin
      stop_ack = 1'b1;
      next_i_state = DISCONNECTED;
    end
  end

  DISCON_ABORT:
  begin
    gate_hold_req_nxt = 1'b1;
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (cfg_accept_i)
      next_i_state = RECON0;
  end

  RECON0:
  begin
    gate_hold_req_nxt = 1'b1; 
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b01; 
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    next_i_state = RECON1;
  end

  RECON1:
  begin
    gate_hold_req_nxt = 1'b1; 
    cfg_dis_nxt = 1'b0;
    cfg_con_o = 2'b00;
    exit_ack = 1'b0;
    stop_ack = 1'b0;
    stop_deny = 1'b0;
    if (cfg_accept_i)
    begin
      gate_hold_req_nxt = 1'b0;
      next_i_state = CONNECTED;
    end
  end

  default:
  begin
    gate_hold_req_nxt = 1'bx;
    cfg_dis_nxt = 1'bx;
    cfg_con_o = 2'bxx;
    exit_ack = 1'bx;
    stop_ack = 1'bx;
    stop_deny = 1'bx;
    next_i_state = 3'bxxx;
  end

  endcase
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    current_i_state_r <= DISCONNECTED;
  end
  else
  begin
    current_i_state_r <= next_i_state;
  end
end


always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    gate_hold_req_o <= 1'b1;
  end
  else
  begin
    gate_hold_req_o <= gate_hold_req_nxt;
  end
end

assign clk_request_o = ~(((current_q_state_r == Q_STOPPED) & ~qreqn_i) ||
                         ((current_q_state_r == Q_RUN) & qreqn_i));

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    qactive_o <= 1'b0;
  else
    qactive_o <= active;
end

endmodule
