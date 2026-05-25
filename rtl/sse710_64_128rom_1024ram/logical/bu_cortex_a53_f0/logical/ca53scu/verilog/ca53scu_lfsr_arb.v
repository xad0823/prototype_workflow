//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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
//  Pseudo random request arbiter
//  Supports widths between 2 and 6 inclusive.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53scu_lfsr_arb #(parameter WIDTH = 5) (
  input wire              clk,
  input wire              reset_n,
  input wire              enable_i,
  input wire [WIDTH-1:0]  req_i,
  output wire [WIDTH-1:0] grant_o
);

  localparam WIDTH_LOG = `CA53_LOG2(WIDTH);

  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  wire                  arb_dir;
  wire [WIDTH_LOG-1:0]  random_lp;
  wire [WIDTH-1:0]      random_lp_onehot;
  wire [3:0]            pick_random;
  wire                  shift_enable_lp;
  wire [WIDTH*2-2:1]    req_long;
  reg  [WIDTH-1:0]      last_granted;
  wire [WIDTH-1:0]      lowest_priority;
  wire [WIDTH-1:0]      grant_if_lp_norm [WIDTH-1:0];
  wire [WIDTH-1:0]      grant_if_lp_rev  [WIDTH-1:0];
  wire [WIDTH-1:0]      grant_if_lp      [WIDTH-1:0];
  wire [WIDTH-1:0]      grant;

  genvar req;
  genvar lp;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  ca53scu_lfsr #(.RADIX(2), .LFSR_LEN(7)) u_lfsr_dir (
    .clk            (clk),
    .reset_n        (reset_n),
    .shift_enable_i (enable_i),
    .lfsr_out_o     (arb_dir)
  );

  generate if (WIDTH < 6) begin : g_width

    ca53scu_lfsr #(.RADIX(WIDTH), .LFSR_LEN(6)) u_lfsr_lp (
      .clk            (clk),
      .reset_n        (reset_n),
      .shift_enable_i (shift_enable_lp),
      .lfsr_out_o     (random_lp)
    );

  end else begin : g_width_6

    // For a width of 6, the size is not a power of 2, 3, or 5, and hence is
    // not supported directly by the LFSR. Therefore create out of two smaller
    // LFSRs multiplied together.
    ca53scu_lfsr #(.RADIX(3), .LFSR_LEN(6)) u_lfsr_lp1 (
      .clk            (clk),
      .reset_n        (reset_n),
      .shift_enable_i (shift_enable_lp),
      .lfsr_out_o     (random_lp[2:1])
    );

    ca53scu_lfsr #(.RADIX(2), .LFSR_LEN(6)) u_lfsr_lp0 (
      .clk            (clk),
      .reset_n        (reset_n),
      .shift_enable_i (shift_enable_lp),
      .lfsr_out_o     (random_lp[0])
    );

  end endgenerate

  ca53scu_lfsr #(.RADIX(16), .LFSR_LEN(3)) u_lfsr_pick_rand (
    .clk            (clk),
    .reset_n        (reset_n),
    .shift_enable_i (enable_i),
    .lfsr_out_o     (pick_random)
  );

  generate for (req = 0; req < WIDTH; req = req + 1) begin : g_rand_lp
    assign random_lp_onehot[req] = random_lp == req[WIDTH_LOG-1:0];
  end endgenerate

  assign shift_enable_lp = enable_i & (&pick_random);

  // Most of the time we pick the last granted request as the lowest priority,
  // but there is a 1 in 16 chance that we will instead pick a random request
  // as the lowest, to perturb the arbitration and break any repetitive patterns.
  assign lowest_priority = &pick_random ? random_lp_onehot : last_granted;

  assign req_long = {req_i[WIDTH-2:0], req_i[WIDTH-1:1]};

  generate for (req = 0; req < WIDTH; req = req + 1) begin : g_req
    for (lp = 0; lp < WIDTH; lp = lp + 1) begin : g_pri
      if (req == ((lp + 1) % WIDTH)) begin : g_grant_norm_0
        assign grant_if_lp_norm[req][lp] = 1'b1;
      end else if (req > lp + 1) begin : g_grant_norm_1
        assign grant_if_lp_norm[req][lp] = ~|req_long[req-1:lp+1];
      end else begin : g_grant_norm_2 /* req <= lp */
        assign grant_if_lp_norm[req][lp] = ~|req_long[req[`CA53_LOG2(WIDTH)-1:0]+WIDTH-1:lp+1];
      end

      if (((req + 1) % WIDTH) == lp) begin : g_grant_rev_0
        assign grant_if_lp_rev[req][lp] = 1'b1;
      end else if (req >= lp) begin : g_grant_rev_1
        assign grant_if_lp_rev[req][lp] = ~|req_long[lp[`CA53_LOG2(WIDTH)-1:0]+WIDTH-1:req+1];
      end else begin : g_grant_rev_2 /* req < lp */
        assign grant_if_lp_rev[req][lp] = ~|req_long[lp[`CA53_LOG2(WIDTH)-1:0]+WIDTH-1:req[`CA53_LOG2(WIDTH)-1:0]+WIDTH+1];
      end
    end

    // Randomly choose which direction we should search in from the lowest
    // priority to find the next request.
    assign grant_if_lp[req] = arb_dir ? grant_if_lp_rev[req] : grant_if_lp_norm[req];

    assign grant[req] = req_i[req] & |(grant_if_lp[req] & lowest_priority);
  end endgenerate

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    last_granted <= {1'b1, {WIDTH-1{1'b0}} };
  end else if (enable_i) begin
    last_granted <= grant;
  end

  //-----------------------------------------------------------------------------
  //  Assign outputs
  //-----------------------------------------------------------------------------

  assign grant_o = grant;

  //-----------------------------------------------------------------------------
  //  Assertions
  //-----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_one_hot #(`OVL_FATAL, WIDTH, `OVL_ASSERT, "one and only one lowest_priority will be set")
  u_ovl_prisel_oh
  (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (lowest_priority)
  );

  assert_zero_one_hot #(`OVL_FATAL, WIDTH, `OVL_ASSERT, "only one (at most) grant bit can be set")
  u_ovl_grant_zoh
  (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (grant)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "If any requests are made, at least one must be granted")
  u_ovl_req_must_grant
  (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|req_i),
    .consequent_expr (|grant)
  );

  genvar i_gen_req_ovl;
  generate for (i_gen_req_ovl=0; i_gen_req_ovl < WIDTH; i_gen_req_ovl=i_gen_req_ovl+1)
  begin : l_gen_req_ovl
    assert_implication #(`OVL_FATAL, `OVL_ASSERT,
            "A source can only be granted if it is making a request")
    u_ovl_grant_must_req
    (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (grant[i_gen_req_ovl]),
      .consequent_expr (req_i[i_gen_req_ovl])
    );
  end
  endgenerate

  assert_one_hot #(`OVL_FATAL, WIDTH, `OVL_ASSERT, "The random LFSR output must be onehot")
  u_ovl_random_oh
  (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (random_lp_onehot)
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_i")
  u_ovl_x_enable_i (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (enable_i));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
