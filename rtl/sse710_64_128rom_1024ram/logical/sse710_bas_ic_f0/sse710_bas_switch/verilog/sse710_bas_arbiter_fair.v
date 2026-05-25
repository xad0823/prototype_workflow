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

module sse710_bas_arbiter_fair

  #(
  parameter WAYS = 4,
  parameter ARBITER_POLICY = 4
   )

(
  input   wire                        clk,
  input   wire                        resetn,
  input   wire                        update_i,
  input   wire  [WAYS-1:0]            request_i,
  output  wire  [WAYS-1:0]            grant_o
);







reg [WAYS-1:0] arb_mask_q;

wire [WAYS-1:0] arb_mask_q_nxt;

generate

    case (ARBITER_POLICY)

    0 :
      begin : g_fixed_pri_hi
        assign arb_mask_q_nxt = {WAYS{1'b1}};
      end

    1 :
      begin : g_fixed_pri_lo
        assign arb_mask_q_nxt = {WAYS{1'b0}};
      end

    2 :
      begin : g_rr_mask
        assign arb_mask_q_nxt = {1'b0,    arb_mask_q[WAYS-1:1]
                                        | {{WAYS-1}{~arb_mask_q[0]}}};
      end

    3 :
      begin : g_rr_mask_strong_fair
        assign arb_mask_q_nxt = {1'b0,   grant_o[WAYS-1:1]
                                       | arb_mask_q_nxt[WAYS-1:1]};
      end

    4 :
      begin : g_rr_mask_cyclic_pri
        assign arb_mask_q_nxt = {arb_mask_q[0+:(WAYS-1)], arb_mask_q[WAYS-1]};
      end

    default :
      begin : g_default
        assign arb_mask_q_nxt = {1'b0,   arb_mask_q[WAYS-1:1]
                                       | {{WAYS-1}{~arb_mask_q[0]}}};
      end

    endcase

endgenerate

always @(negedge resetn or posedge clk)
  if (!resetn)
    arb_mask_q <= {1'b1, {(WAYS-1){1'b0}}};
  else if (update_i)
    arb_mask_q <= arb_mask_q_nxt;

wire [WAYS-1:0] request_hi = arb_mask_q & request_i;
wire [WAYS-1:0] request_lo = ~arb_mask_q & request_i;
wire [WAYS-1:0] sel_hi;

sse710_bas_arbiter_pri
#(
  .WAYS      (WAYS),
  .LSB_N_MSB (0)
)
u_pri_hi
(
  .request_i (request_hi),
  .grant_o   (sel_hi)
);

wire [WAYS-1:0] sel_lo;
sse710_bas_arbiter_pri
#(
  .WAYS      (WAYS),
  .LSB_N_MSB (0)
)
u_pri_lo
(
  .request_i (request_lo),
  .grant_o   (sel_lo)
);

assign grant_o = sel_hi | {WAYS{~(|request_hi)}} & sel_lo;

endmodule
