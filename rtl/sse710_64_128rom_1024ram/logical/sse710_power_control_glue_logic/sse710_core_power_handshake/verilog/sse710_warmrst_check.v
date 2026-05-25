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
module sse710_warmrst_check #(
  parameter SYNC_ENABLE = 1'b0
) (
  input  wire       clk,
  input  wire       resetn,

  input  wire       preq_i,
  input  wire [3:0] pstate_i,
  output wire       pdeny_o,
  output wire       paccept_o,

  input  wire       warmrstreq_i

);

localparam IDLE     = 2'b00;
localparam DENIED   = 2'b01;
localparam ACCEPTED = 2'b10;

wire warmrstreq_ss;

reg       pdeny_nxt;
reg       paccept_nxt;
reg [1:0] state_nxt;

reg [1:0] current_state_r;
reg       pdeny_r;
reg       paccept_r;

genvar i;

if (SYNC_ENABLE == 1'b1)
begin:sync_en
  arm_element_cdc_capt_sync u_cpuqacceptn_sync (
    .clk      (clk),
    .nreset   (resetn),

    .d_async  (warmrstreq_i),
    .q        (warmrstreq_ss)
  );
end

always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    current_state_r <= IDLE;
    pdeny_r         <= 1'b0;
    paccept_r       <= 1'b0;
  end
  else
  begin
    current_state_r <= state_nxt;
    pdeny_r         <= pdeny_nxt;
    paccept_r       <= paccept_nxt;
  end
end

always @(*)
begin
  case (current_state_r)
  IDLE:
  if (preq_i)
  begin
    if (pstate_i == 4'h0)
    begin
      if (warmrstreq_ss)
      begin
        pdeny_nxt   = 1'b1;
        paccept_nxt = 1'b0;
        state_nxt   = DENIED;
      end
      else
      begin
        pdeny_nxt   = 1'b0;
        paccept_nxt = 1'b1;
        state_nxt   = ACCEPTED;
      end
    end
    else
    begin
      pdeny_nxt   = 1'b0;
      paccept_nxt = 1'b1;
      state_nxt   = ACCEPTED;
    end
  end
  else
  begin
    state_nxt   = IDLE;
    pdeny_nxt   = 1'b0;
    paccept_nxt = 1'b0;
  end

  DENIED:
  if (preq_i)
  begin
    pdeny_nxt   = 1'b1;
    paccept_nxt = 1'b0;
    state_nxt   = DENIED;
  end
  else
  begin
    pdeny_nxt   = 1'b0;
    paccept_nxt = 1'b0;
    state_nxt   = IDLE;
  end

  ACCEPTED:
  if (preq_i)
  begin
    pdeny_nxt   = 1'b0;
    paccept_nxt = 1'b1;
    state_nxt   = ACCEPTED;
  end
  else
  begin
    pdeny_nxt   = 1'b0;
    paccept_nxt = 1'b0;
    state_nxt   = IDLE;
  end

  default:
  begin
    pdeny_nxt   = 1'bx;
    paccept_nxt = 1'bx;
    state_nxt   = 2'bxx;
  end
  endcase
end

assign pdeny_o   = pdeny_r;
assign paccept_o = paccept_r;

endmodule
