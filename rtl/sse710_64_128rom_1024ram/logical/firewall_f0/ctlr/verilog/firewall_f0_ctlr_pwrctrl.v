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

module firewall_f0_ctlr_pwrctrl #(
  parameter FW_SRE_LVL = 1
)(
  input              clk,
  input              rstn,

  input              tinit_delay,

  output             gate_hold_req_o,
  input              gate_busy_i,

  input              rb_fc_con_i,
  input              rb_fc_sr_pwr_i,
  input              rb_pwr_deny_i,
  output wire        rb_prot_en_o,
  output reg         default_state_o,

  output wire        cfg_hold_o,
  input              cfg_busy_i,
  input              cfg_ram_req_i,
  output wire        cfg_ram_ack_o,
  output wire        cfg_ram_init_o,
  input              cfg_ram_init_done_i,

  input              clk_hold_i,
  output wire        clk_request_o,

  input              preq_i,
  output reg         paccept_o,
  output reg         pdeny_o,
  input      [3:0]   pstate_i,
  output reg [10:0]  pactive_o
  );

reg [3:0] next_state, current_state_r;
reg [3:0] pwr_mode_r;
wire [3:0] next_pwr_mode;
wire trans_ok;
wire [10:0] i_pactive;
wire busy;
reg post_resetn;
reg paccept_nxt;
reg pdeny_nxt;

wire i_off_blocked;

reg fsm_pwr_en;
reg [3:0] fsm_next_pwr_mode;

reg ram_ack_r, ram_ack_nxt;
reg hold_r, hold_nxt;

localparam P_OFF      = 4'b0000;
localparam P_MEM_RET  = 4'b0010;
localparam P_FUNC_RET = 4'b0111;
localparam P_ON       = 4'b1000;

localparam TINIT      = 4'h0;
localparam TINIT_WAIT = 4'h1;
localparam P_STABLE   = 4'h2;
localparam P_REQUEST  = 4'h3;
localparam P_ACCEPT   = 4'h4;
localparam P_DENIED   = 4'h5;
localparam RINIT_WAIT = 4'h6;
localparam P_COMPLETE = 4'h7;
localparam P_CONTINUE = 4'h8;

reg tinit_del_r;
wire tinit_req;

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    tinit_del_r <= 1'b0;
  else if (!clk_hold_i)
    tinit_del_r <= tinit_delay;
end

assign tinit_req = (tinit_delay & ~clk_hold_i) & ~tinit_del_r;

always @(*)
begin
fsm_pwr_en = 1'b0;
fsm_next_pwr_mode = pwr_mode_r;
paccept_nxt = 1'b0;
pdeny_nxt = 1'b0;
default_state_o = 1'b0;
ram_ack_nxt = ram_ack_r;
hold_nxt = hold_r;
next_state = current_state_r;

case (current_state_r)
TINIT:
begin
  ram_ack_nxt = 1'b0;
  hold_nxt = 1'b1;
  if (tinit_req)
  begin
    if (preq_i == 1'b0)
    begin
      if (pstate_i == P_ON)
      begin
        next_state = TINIT_WAIT;
      end
      else
        next_state = P_STABLE;
    end
    else 
    begin
      next_state = P_REQUEST;
    end
  end
end

TINIT_WAIT: 
begin
  if (cfg_ram_init_done_i)
  begin
    ram_ack_nxt = 1'b1;
    hold_nxt = 1'b0;
    next_state = P_STABLE;
  end
end

P_STABLE:
begin
  if (preq_i)
    next_state = P_REQUEST;
end

P_REQUEST:
begin
  if (trans_ok)
  begin
    paccept_nxt = 1'b1;
    pdeny_nxt = 1'b0;
    next_state = P_ACCEPT;
    if (pstate_i != P_ON)
      ram_ack_nxt = 1'b0;
    if (pstate_i == P_OFF)
      hold_nxt = 1'b1;
  end
  else
  begin
    paccept_nxt = 1'b0;
    pdeny_nxt = 1'b1;
    next_state = P_DENIED;
  end
end

P_ACCEPT:
begin
  paccept_nxt = 1'b1;
  pdeny_nxt = 1'b0;
  if (!preq_i)
  begin
    fsm_pwr_en = 1'b1;
    fsm_next_pwr_mode = pstate_i;
    if ((pwr_mode_r == P_OFF) && (pstate_i == P_ON) && (FW_SRE_LVL == 1))
    begin
      next_state = RINIT_WAIT;
      ram_ack_nxt = 1'b1;
    end
    else
      next_state = P_COMPLETE;
  end
end

RINIT_WAIT:
begin
  paccept_nxt = 1'b1;
  pdeny_nxt = 1'b0;
  hold_nxt = 1'b0;
  if (cfg_ram_init_done_i)
    next_state = P_COMPLETE;
end

P_COMPLETE:
begin
  paccept_nxt = 1'b0;
  pdeny_nxt = 1'b0;
  if (pwr_mode_r != P_OFF)
    hold_nxt = 1'b0;
  else
    default_state_o = 1'b1;
  if (pstate_i == P_ON)
    ram_ack_nxt = 1'b1;
  next_state = P_STABLE;
end

P_DENIED:
begin
  paccept_nxt = 1'b0;
  pdeny_nxt = 1'b1;
  if (!preq_i)
    next_state = P_CONTINUE;
end

P_CONTINUE:
begin
  paccept_nxt = 1'b0;
  pdeny_nxt = 1'b0;
  next_state = P_STABLE;
end

default:
begin
  fsm_pwr_en = 1'bx;
  fsm_next_pwr_mode = 4'bxxxx;
  paccept_nxt = 1'bx;
  pdeny_nxt = 1'bx;
  ram_ack_nxt = 1'bx;
  hold_nxt = 1'bx;
  next_state = 4'bxxxx;
end

endcase
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    current_state_r <= TINIT;
    paccept_o <= 1'b0;
    pdeny_o <= 1'b0;
    ram_ack_r <= 1'b0;
  end
  else if (!clk_hold_i)
  begin
    current_state_r <= next_state;
    paccept_o <= paccept_nxt;
    pdeny_o <= pdeny_nxt;
    ram_ack_r <= ram_ack_nxt;
  end
end

assign next_pwr_mode = (tinit_req & !preq_i) ? pstate_i : fsm_next_pwr_mode;

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    pwr_mode_r <= P_OFF;
  else if ((tinit_req & !preq_i) | fsm_pwr_en)
    pwr_mode_r <= next_pwr_mode;
end


assign i_off_blocked = cfg_ram_req_i  | rb_pwr_deny_i | rb_fc_con_i |
                       rb_fc_sr_pwr_i | gate_busy_i   | cfg_busy_i;

assign trans_ok = (pstate_i == P_ON) || ((pstate_i == P_FUNC_RET) && ~cfg_ram_req_i) ||
                  ((pstate_i == P_OFF) && (pwr_mode_r == P_OFF)) ||
                  ((pstate_i == P_OFF) && !(i_off_blocked));

assign rb_prot_en_o = (pwr_mode_r == P_OFF) && (next_pwr_mode == P_ON);

generate
if (FW_SRE_LVL == 1'b1)
  begin : SRE_1_CFG
reg ram_init;

assign cfg_ram_ack_o = ram_ack_r;

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    ram_init <= 1'b0;
  else
    ram_init <= rb_prot_en_o;
end

assign cfg_ram_init_o = ram_init;
  end
else
  begin : SRE_0_CFG
assign cfg_ram_ack_o = 1'b0;
assign cfg_ram_init_o = 1'b0;
  end
endgenerate

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    post_resetn <= 1'b0;
  else if (cfg_ram_init_done_i)
    post_resetn <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    hold_r <= 1'b1;
  else
    hold_r <= hold_nxt;
end

assign busy = gate_busy_i | cfg_busy_i | rb_fc_sr_pwr_i;

assign i_pactive[10:9] = 2'b0;
assign i_pactive[6:5]  = 2'b0;
assign i_pactive[3:1]  = 3'b0;
assign i_pactive[0]    = 1'b1;

generate
  if (FW_SRE_LVL == 1'b1)
    begin : SRE_1_PACTIVE
      assign i_pactive[8] = cfg_ram_req_i | ~post_resetn;
      assign i_pactive[7] = rb_fc_con_i | busy;
      assign i_pactive[4] = 1'b0;
    end
  else
    begin : SRE_0_PACTIVE
      assign i_pactive[8] = rb_fc_con_i | busy;
      assign i_pactive[7] = 1'b0;
      assign i_pactive[4] = 1'b0;
    end
endgenerate

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
    pactive_o <= 11'b0;
  else
    pactive_o <= i_pactive;
end


assign gate_hold_req_o = hold_r;
assign cfg_hold_o = hold_r;

assign clk_request_o = (current_state_r != P_STABLE) ||
                        ((current_state_r == P_STABLE) && preq_i) ||
                        ~tinit_delay;

endmodule
