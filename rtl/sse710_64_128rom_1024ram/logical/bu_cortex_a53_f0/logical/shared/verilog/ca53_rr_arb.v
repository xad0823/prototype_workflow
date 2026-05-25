//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
//  Round robin priority arbitration logic.
//-----------------------------------------------------------------------------
//
`include "cortexa53params.v"


module ca53_rr_arb #(parameter WIDTH = 6) (
  input  wire                         clk,
  input  wire                         reset_n,
  input  wire [`CA53_LOG2(WIDTH)-1:0] rr_counter_i,
  input  wire [WIDTH-1:0]             requests_i,
  output wire [WIDTH-1:0]             arb_o
);

  wire [WIDTH-1:0]    req_below_counter;
  wire [WIDTH*2-1:0]  req_long;
  wire [WIDTH*2-1:0]  req_long_lower_set;

  genvar              i;

  // Determine which requests are above the current counter value and which are below.
  generate for (i = 0; i < WIDTH; i = i + 1) begin : g_req_below
    assign req_below_counter[i] = i < rr_counter_i;
  end endgenerate

  // Rearrange requests so that they are in priority order with the highest
  // priority at the lowest bit position.
  assign req_long = {requests_i & req_below_counter, requests_i & ~req_below_counter};

  // Work out if each request has another request in a lower bit position set.
  assign req_long_lower_set[0] = 1'b0;

  generate for (i = 1; i < 2*WIDTH; i = i + 1) begin : g_pri
    assign req_long_lower_set[i] = req_long[i-1] | req_long_lower_set[i-1];
  end endgenerate

  // Select the first request that does not have a higher priority bit set.
  assign arb_o = ((req_long[WIDTH-1:0] & ~req_long_lower_set[WIDTH-1:0]) |
                  (req_long[2*WIDTH-1:WIDTH] & ~req_long_lower_set[2*WIDTH-1:WIDTH]));

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Round robin counter must be inside the range of requests")
  u_ovl_rr_range (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (rr_counter_i >= WIDTH)
  );

  assert_zero_one_hot #(`OVL_FATAL, WIDTH, `OVL_ASSERT, "Arbitration output must be one hot")
  u_ovl_arb_onehot (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (arb_o)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "When there are any requests, one must be granted")
  u_ovl_arb_when_req (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (|requests_i),
    .consequent_expr  (|arb_o)
  );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Arbitration output can not have a bit set for an invalid request")
  u_ovl_arb_must_have_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (|(arb_o & ~requests_i))
  );

  reg [WIDTH-1:0] ovl_highest;

  generate if (WIDTH > 1) begin : g_ovl_highest
    reg ovl_highest_found;
    integer k;

    always @*
    begin
      ovl_highest_found = 1'b0;
      ovl_highest = (1'b1 << rr_counter_i);
      for (k = 0; k < WIDTH; k = k + 1) begin
        if (~ovl_highest_found) begin
          if (|(requests_i & ovl_highest)) begin
            ovl_highest_found = 1'b1;
          end else begin
            ovl_highest = {ovl_highest[WIDTH-2:0], ovl_highest[WIDTH-1]};
          end
        end
      end
    end
  end else begin : g_ovl_highest2
    always @*
      ovl_highest = requests_i;
  end endgenerate

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Arbitration output correct")
  u_ovl_rr_correct (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|requests_i),
    .consequent_expr (arb_o == ovl_highest)
  );

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
