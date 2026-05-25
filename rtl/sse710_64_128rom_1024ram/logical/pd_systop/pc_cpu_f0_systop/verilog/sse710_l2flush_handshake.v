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
module sse710_l2flush_handshake (
  input  wire       clk,
  input  wire       resetn,

  input  wire       l2_flush_qreqn,
  output wire       l2_flush_qacceptn,

  input  wire [3:0] clustop_dev_pstate,
  input  wire       hostcpu_standbywfil2,
  input  wire       clustop_ppuhwstat_0,
  input  wire       clustop_ppuhwstat_2,

  input  wire       l2flushdone,
  output wire       l2flushreq


);

reg       l2flushreq_r;
reg [2:0] state_current_r;
reg       l2flushreq_nxt;
reg [2:0] state_nxt;

reg       l2_flush_qacceptn_nxt;
reg       l2_flush_qacceptn_r;

localparam FLUSH_IDLE = 3'b000;
localparam FLUSHREQ = 3'b001;
localparam FLUSHREQ_DEASSERT = 3'b010;
localparam STANDBYWFIL2_ASSERTED = 3'b011;
localparam FLUSH_DONE = 3'b100;

always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    l2flushreq_r <= 1'b0;
    l2_flush_qacceptn_r <= 1'b0;
    state_current_r <= FLUSH_IDLE;
  end
  else
  begin
    l2flushreq_r <= l2flushreq_nxt;
    l2_flush_qacceptn_r <= l2_flush_qacceptn_nxt;
    state_current_r <= state_nxt;
  end
end

always @*
begin
  case (state_current_r)
  FLUSH_IDLE:
  begin
    if ((l2_flush_qreqn == 1'b0) & (clustop_dev_pstate == 4'b0000) & ~clustop_ppuhwstat_0 & ~clustop_ppuhwstat_2)
    begin
      l2flushreq_nxt = 1'b1;
      l2_flush_qacceptn_nxt = 1'b1;
      state_nxt = FLUSHREQ;
    end
    else
    begin
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = l2_flush_qreqn;
      state_nxt = FLUSH_IDLE;
    end
  end
  
  FLUSHREQ:
  begin
    if (l2flushdone)
    begin
      state_nxt = FLUSHREQ_DEASSERT;
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = 1'b1;
    end
    else
    begin
      state_nxt = state_current_r;
      l2flushreq_nxt = l2flushreq_r;
      l2_flush_qacceptn_nxt = 1'b1;
    end
  end

  FLUSHREQ_DEASSERT:
  begin
    if (~l2flushdone)
    begin
      state_nxt = STANDBYWFIL2_ASSERTED;
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = 1'b1;
    end
    else
    begin
      state_nxt = FLUSHREQ_DEASSERT;
      l2flushreq_nxt = l2flushreq_r;
      l2_flush_qacceptn_nxt = 1'b1;
    end
  end

  STANDBYWFIL2_ASSERTED:
  begin
    if (hostcpu_standbywfil2)
    begin
      state_nxt = FLUSH_DONE;
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = 1'b0;
    end
    else
    begin
      state_nxt = state_current_r;
      l2flushreq_nxt = l2flushreq_r;
      l2_flush_qacceptn_nxt = 1'b1;
    end
  end

  FLUSH_DONE:
  begin
    if (l2_flush_qreqn)
    begin
      state_nxt = FLUSH_IDLE;
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = 1'b1;
    end
    else
    begin
      state_nxt = FLUSH_DONE;
      l2flushreq_nxt = 1'b0;
      l2_flush_qacceptn_nxt = 1'b0;
    end
  end

  default:
  begin
    state_nxt = 3'bxxx;
    l2flushreq_nxt = 1'bx;
    l2_flush_qacceptn_nxt = 1'bx;
  end
  endcase
end

assign l2flushreq = l2flushreq_r;
assign l2_flush_qacceptn = l2_flush_qacceptn_r;

endmodule
