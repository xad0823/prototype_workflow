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
module sse710_clustop_l2_qch_handshake 
(
  input  wire       clk,
  input  wire       resetn,

  input  wire       qreqn_i,
  input  wire [3:0] pstate_i,
  output wire       qdeny_o,
  output wire       qacceptn_o,

  output wire       l2_qreqn_o,
  input  wire       l2_qacceptn_i,
  input  wire       l2_qdeny_i
);

localparam Q_STOPPED     = 2'b00;
localparam CLUSTOP_L2_ON = 2'b01;
localparam L2_Q_DENIED   = 2'b10;

reg [1:0] state_r;
reg qdeny_r;
reg qacceptn_r;
reg l2_qreqn_r;

reg [1:0] state_nxt;
reg qdeny_nxt;
reg qacceptn_nxt;
reg l2_qreqn_nxt;

always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    state_r    <= Q_STOPPED;
    qdeny_r    <= 1'b0;
    qacceptn_r <= 1'b0;

    l2_qreqn_r <= 1'b0;
  end
  else
  begin
    state_r    <= state_nxt;
    qdeny_r    <= qdeny_nxt;
    qacceptn_r <= qacceptn_nxt;

    l2_qreqn_r <= l2_qreqn_nxt;
  end
end

always @(*)
begin
  case (state_r)
  Q_STOPPED:
  if (qreqn_i)
  begin
    l2_qreqn_nxt = 1'b1;
    if ((l2_qacceptn_i) & ~(l2_qdeny_i))
    begin
      state_nxt    = CLUSTOP_L2_ON;
      qacceptn_nxt = 1'b1;
      qdeny_nxt    = 1'b0;
    end
    else
    begin
      state_nxt    = state_r;
      qacceptn_nxt = qacceptn_r;
      qdeny_nxt    = qdeny_r;
    end
  end
  else
  begin
    l2_qreqn_nxt = 1'b0;
    state_nxt    = state_r;
    qacceptn_nxt = qacceptn_r;
    qdeny_nxt    = qdeny_r;
  end

  CLUSTOP_L2_ON:
  if (~qreqn_i)
  begin
    l2_qreqn_nxt = 1'b0;
    if ((pstate_i == 4'b0111) & (l2_qacceptn_i == 1'b0))
    begin
      state_nxt    = Q_STOPPED;
      qacceptn_nxt = l2_qacceptn_i;
      qdeny_nxt    = l2_qdeny_i;
    end
    else if ((pstate_i == 4'b0111) & (l2_qdeny_i == 1'b1))
    begin
      state_nxt    = L2_Q_DENIED;
      qacceptn_nxt = l2_qacceptn_i;
      qdeny_nxt    = l2_qdeny_i;
    end
    else if ((pstate_i != 4'b0111) & (l2_qdeny_i | (~l2_qacceptn_i)))
    begin
      state_nxt    = Q_STOPPED;
      qacceptn_nxt = 1'b0;
      qdeny_nxt    = 1'b0;
    end
    else
    begin
      state_nxt    = CLUSTOP_L2_ON;
      qacceptn_nxt = qacceptn_r;
      qdeny_nxt    = qdeny_r;
    end
  end
  else
  begin
    l2_qreqn_nxt = 1'b1;
    state_nxt    = CLUSTOP_L2_ON;
    qacceptn_nxt = l2_qacceptn_i;
    qdeny_nxt    = l2_qdeny_i;
  end

  L2_Q_DENIED:
  if (qreqn_i)
  begin
    l2_qreqn_nxt = 1'b1;
    if (~l2_qdeny_i)
    begin
      state_nxt    = CLUSTOP_L2_ON;
      qacceptn_nxt = 1'b1;
      qdeny_nxt    = 1'b0;
    end
    else 
    begin
      state_nxt    = L2_Q_DENIED;
      qacceptn_nxt = qacceptn_r;
      qdeny_nxt    = qdeny_r;
    end
  end
  else 
  begin
    l2_qreqn_nxt = 1'b0;
    state_nxt    = L2_Q_DENIED;
    qacceptn_nxt = qacceptn_r;
    qdeny_nxt    = qdeny_r;
  end

  default:
  begin
    l2_qreqn_nxt = 1'bx;
    state_nxt    = 2'bxx;
    qacceptn_nxt = 1'bx;
    qdeny_nxt    = 1'bx;
  end
  endcase
end

assign l2_qreqn_o = l2_qreqn_r;
assign qacceptn_o = qacceptn_r;
assign qdeny_o    = qdeny_r;

endmodule


