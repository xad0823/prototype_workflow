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
module sse710_hierarchical_pd_dependency #(
  parameter PACTIVE_WIDTH = 4
)  (

  input  wire                      clk,
  input  wire                      resetn,

  input  wire [PACTIVE_WIDTH-1:0]  pactive,
  input  wire                      ppuhwstat_not_off,

  input  wire                      pwr_qreqn,
  output reg                       pwr_qacceptn,
  output reg                       pwr_qdeny,

  output wire                      clk_qactive,

  output reg [PACTIVE_WIDTH-1:0]   pactive_en
);

localparam IDLE     = 2'b00;
localparam Q_DENY   = 2'b01;
localparam Q_ACCEPT = 2'b10;

reg qdeny_nxt;
reg qacceptn_nxt;

reg [1:0]               state_r;
reg [1:0]               state_nxt;
reg [PACTIVE_WIDTH-1:0] pactive_en_nxt;


always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    pwr_qdeny      <= 1'b0;
    pwr_qacceptn   <= 1'b0;

    state_r    <= Q_ACCEPT;
    pactive_en <= {PACTIVE_WIDTH{1'b0}};
  end
  else
  begin
    pwr_qdeny      <= qdeny_nxt;
    pwr_qacceptn   <= qacceptn_nxt;

    state_r    <= state_nxt;
    pactive_en <= pactive_en_nxt;
  end
end

always @*
begin
  case (state_r)
  IDLE:
  if (~pwr_qreqn)
  begin
    state_nxt      = (|(pactive) | ppuhwstat_not_off) ? Q_DENY : Q_ACCEPT;
    qdeny_nxt      = (|(pactive) | ppuhwstat_not_off) ? 1'b1 : 1'b0;
    qacceptn_nxt   = (|(pactive) | ppuhwstat_not_off) ? 1'b1 : 1'b0;
    pactive_en_nxt = (|(pactive) | ppuhwstat_not_off) ? {PACTIVE_WIDTH{1'b1}} : {PACTIVE_WIDTH{1'b0}};
  end
  else
  begin
    state_nxt      = state_r;
    qdeny_nxt      = pwr_qdeny;
    qacceptn_nxt   = pwr_qacceptn;
    pactive_en_nxt = {PACTIVE_WIDTH{1'b1}};
  end

  Q_ACCEPT:
  if (pwr_qreqn)
  begin
    state_nxt      = IDLE;
    qdeny_nxt      = 1'b0;
    qacceptn_nxt   = 1'b1;
    pactive_en_nxt = {PACTIVE_WIDTH{1'b1}};
  end
  else
  begin
    state_nxt      = Q_ACCEPT;
    qdeny_nxt      = 1'b0;
    qacceptn_nxt   = 1'b0;
    pactive_en_nxt = {PACTIVE_WIDTH{1'b0}};
  end

  Q_DENY:
  if (pwr_qreqn)
  begin
    state_nxt      = IDLE;
    qdeny_nxt      = 1'b0;
    qacceptn_nxt   = 1'b1;
    pactive_en_nxt = {PACTIVE_WIDTH{1'b1}};
  end
  else
  begin
    state_nxt      = Q_DENY;
    qdeny_nxt      = 1'b1;
    qacceptn_nxt   = 1'b1;
    pactive_en_nxt = {PACTIVE_WIDTH{1'b1}};
  end

  default:
  begin
    state_nxt      = 2'bxx;
    qdeny_nxt      = 1'bx;
    qacceptn_nxt   = 1'bx;
    pactive_en_nxt = {PACTIVE_WIDTH{1'bx}};
  end
  endcase
end

assign clk_qactive = ((state_r == IDLE) & ~pwr_qreqn) | (((state_r == Q_DENY) | (state_r == Q_ACCEPT)) & pwr_qreqn);

endmodule
