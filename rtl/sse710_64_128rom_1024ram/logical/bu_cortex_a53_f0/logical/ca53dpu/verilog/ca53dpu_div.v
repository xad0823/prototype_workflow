//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2009-11-13 13:49:58 +0000 (Fri, 13 Nov 2009) $
//
//      Revision            : $Revision: 123483 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : 4-bits per cycle (radix-16) SRT divider.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Divide block.
// Generates result of division.
// radix-16 made up of 4 consecutive radix-2 stages.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_div `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         clk,
  input  wire         reset_n,
  input  wire         DFTSE,
  input  wire         div_flush_i,
  input  wire         div_valid_de_i,        // triggers div_clk_gate
  input  wire         raw_div_valid_iss_i,   // triggers div_clk_gate
  input  wire         div_valid_iss_i,       // ready to start division (load operand registers)
  input  wire         div_signed_iss_i,      // signed/~unsigned
  input  wire         ctl_64bit_op_iss_i,    // 64 bit operation
  input  wire  [63:0] div_opa_iss_i,         // operand a
  input  wire  [63:0] div_opb_iss_i,         // operand b
  // Outputs
  output wire  [63:0] div_res_wr_o,
  output wire         div_busy_iss_o,        // shows that divider is busy in order to stall the iss stage
  output wire         nxt_div_busy_wr_o      // shows that divider is busy in order to stall the wr stage
);

  // -------------------------------
  // Constant declarations
  // -------------------------------

  localparam FSM_MOD_CLZ  = 0;
  localparam FSM_CLZ      = 1;
  localparam FSM_ZERO     = 2;
  localparam FSM_STEP     = 3;
  localparam FSM_CORR     = 4;

  localparam DIV_FSM_W = 5;

  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_IDLE    = 5'b00000;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_MOD_CLZ = 5'b00001;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_CLZ     = 5'b00010;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_ZERO    = 5'b00100;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_STEP    = 5'b01000;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_CORR    = 5'b10000;
  localparam [DIV_FSM_W-1:0] CA53_DIV_ST_X       = 5'bxxxxx;

  // -----------------------------
  // Genvar declaration
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------
  reg   [DIV_FSM_W-1:0] fsm_reg;
  reg   [DIV_FSM_W-1:0] nxt_fsm_reg_noflush;
  reg   [DIV_FSM_W-1:0] nxt_fsm_reg;
  reg            [63:0] divisor;
  reg                   neg_res_reg;
  reg                   sign_reg;
  reg             [5:0] iters_required;
  reg            [65:0] rem_sum;
  reg            [65:0] rem_carry;
  reg                   final_rem_negative;
  reg            [63:0] quotient;
  reg            [63:0] quotient_m1;
  reg             [1:0] prev_quot_dig;
  reg                   div_clk_en;

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire                  zero;
  wire           [65:0] nxt_remainder;
  wire           [63:0] nxt_divisor;
  wire            [6:0] clz_remainder;
  wire            [5:0] clz_diff;
  wire            [6:0] clz_divisor;
  wire                  remainder_wr_en;
  wire                  rem_carry_wr_en;
  wire                  divisor_wr_en;
  wire           [65:0] new_opa_operand;
  wire           [63:0] new_opb_operand;
  wire           [63:0] div_opa_ext_iss;
  wire           [63:0] div_opb_ext_iss;
  wire                  divisor_eq_zero;
  wire                  divisor_gt_remainder;
  wire            [6:0] clz_remainder_divisor_delta;
  wire                  neg_remainder;
  wire                  neg_res;
  wire           [63:0] negated_remainder;
  wire                  neg_divisor;
  wire           [63:0] negated_divisor;
  wire                  quot_enable;
  wire           [63:0] remainder_norm;
  wire           [63:0] divisor_norm;
  wire            [5:0] nxt_iters_required;
  wire                  iters_required_en;
  wire            [5:0] iters_required_m1;
  wire                  final_cycle;
  wire           [65:0] new_rem_sum;
  wire           [65:0] nxt_rem_carry;
  wire           [65:0] new_rem_carry;
  wire           [65:0] rem_cpa;
  wire           [63:0] n_quotient_step;
  wire           [63:0] n_quotient_m1_step;
  wire                  skip_corr;
  wire           [63:0] final_quotient;
  wire                  nxt_final_rem_negative;
  wire                  final_rem_negative_en;
  wire           [63:0] nxt_quotient;
  wire           [63:0] nxt_quotient_m1;
  wire           [63:0] n_quotient        [3:0];
  wire           [63:0] n_quotient_m1     [3:0];
  wire           [10:0] rem_sum_zero      [3:0];
  wire           [10:0] rem_carry_zero    [3:0];
  wire           [10:0] rem_sum_minus_d   [3:0];
  wire           [10:0] rem_carry_minus_d [3:0];
  wire           [10:0] rem_sum_plus_d    [3:0];
  wire           [10:0] rem_carry_plus_d  [3:0];
  wire            [1:0] quot_dig_zero     [3:0];
  wire            [1:0] quot_dig_minus_d  [3:0];
  wire            [1:0] quot_dig_plus_d   [3:0];
  wire            [1:0] quot_dig          [4:0];
  wire           [10:0] rem_sum_cp        [4:0];
  wire           [10:0] rem_carry_cp      [4:0];
  wire            [1:0] n_prev_quot_dig;
  wire           [62:0] mux_divisor       [2:0];
  wire           [65:0] rem_sum_dp        [4:0];
  wire           [65:0] rem_carry_dp      [4:0];
  wire           [64:0] rem_sum_zero_dp;
  wire           [64:0] rem_carry_zero_dp;
  wire           [64:0] rem_sum_minus_d_dp;
  wire           [64:0] rem_carry_minus_d_dp;
  wire           [64:0] rem_sum_plus_d_dp;
  wire           [64:0] rem_carry_plus_d_dp;
  wire                  div_clk_en_nxt;
  wire                  clk_div;
  wire                  nxt_div_busy_wr;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // Keep divider gated whilst no divide operations are scheduled.
  ca53_cell_inter_clkgate u_inter_clkgate_div  (
    .clk_i         (clk),
    .clk_enable_i  (div_clk_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_div)
  );

  assign div_clk_en_nxt = div_valid_de_i | raw_div_valid_iss_i |
                          ~(fsm_reg==CA53_DIV_ST_IDLE) | nxt_div_busy_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      div_clk_en <= 1'b1;
    else
      div_clk_en <= div_clk_en_nxt;

  // ------------------------------------------------------
  // FSM
  // ------------------------------------------------------
  always @(posedge clk_div or negedge reset_n)
    if (~reset_n)
      fsm_reg <= CA53_DIV_ST_IDLE;
    else
      fsm_reg <= nxt_fsm_reg;

  always @*
    case (fsm_reg)
      CA53_DIV_ST_IDLE    : nxt_fsm_reg_noflush = CA53_DIV_ST_IDLE;
      CA53_DIV_ST_MOD_CLZ : nxt_fsm_reg_noflush = (neg_divisor |
                                                   neg_remainder) ? CA53_DIV_ST_CLZ  :
                                                  zero            ? CA53_DIV_ST_ZERO :
                                                                    CA53_DIV_ST_STEP;
      CA53_DIV_ST_CLZ     : nxt_fsm_reg_noflush = zero ? CA53_DIV_ST_ZERO : CA53_DIV_ST_STEP;
      CA53_DIV_ST_ZERO    : nxt_fsm_reg_noflush = CA53_DIV_ST_IDLE;
      CA53_DIV_ST_STEP    : nxt_fsm_reg_noflush = final_cycle ? (skip_corr ? CA53_DIV_ST_IDLE : CA53_DIV_ST_CORR)
                                                              : CA53_DIV_ST_STEP;
      CA53_DIV_ST_CORR    : nxt_fsm_reg_noflush = CA53_DIV_ST_IDLE;
      default : nxt_fsm_reg_noflush = CA53_DIV_ST_X;
    endcase

  always @*
    case ({div_flush_i, div_valid_iss_i})
      2'b10, 2'b11: // Flush, stop divider (Takes priority over valid)
        nxt_fsm_reg = CA53_DIV_ST_IDLE;
      2'b01: // New operation starting
        nxt_fsm_reg = CA53_DIV_ST_MOD_CLZ;
      2'b00: // Normal operation
        nxt_fsm_reg = nxt_fsm_reg_noflush;
      default : nxt_fsm_reg = CA53_DIV_ST_X;
    endcase

  //----------------------------------------------------------------------------
  // For a 32-bit operation, left-align the operands
  //----------------------------------------------------------------------------

  assign div_opa_ext_iss = ctl_64bit_op_iss_i ? div_opa_iss_i :
                                                {div_opa_iss_i[31:0], 32'h00000000};
  assign div_opb_ext_iss = ctl_64bit_op_iss_i ? div_opb_iss_i :
                                                {div_opb_iss_i[31:0], 32'h00000000};

  //----------------------------------------------------------------------------
  // Divider Prescaling stage.
  //----------------------------------------------------------------------------

  // Enable input operands
  assign remainder_wr_en = (raw_div_valid_iss_i & (fsm_reg == CA53_DIV_ST_IDLE))   |
                           (fsm_reg[FSM_MOD_CLZ] & (~neg_divisor | neg_remainder)) |
                           fsm_reg[FSM_CLZ]                                        |
                           fsm_reg[FSM_STEP];

  assign nxt_remainder   = ({66{neg_remainder}}                                               & {2'b00, negated_remainder})  |
                           ({66{(fsm_reg[FSM_MOD_CLZ] & ~neg_remainder) | fsm_reg[FSM_CLZ]}}  & {2'b00, remainder_norm})     |
                           ({66{fsm_reg[FSM_STEP]}}                                           & new_rem_sum);

  assign new_opa_operand = (fsm_reg == CA53_DIV_ST_IDLE) ? {2'b00,div_opa_ext_iss} : nxt_remainder;

  always @(posedge clk_div)
    if (remainder_wr_en)
      rem_sum <= new_opa_operand;

  assign divisor_wr_en   = (raw_div_valid_iss_i & (fsm_reg == CA53_DIV_ST_IDLE))   |
                           (fsm_reg[FSM_MOD_CLZ] & (neg_divisor | ~neg_remainder)) |
                           fsm_reg[FSM_CLZ];

  assign nxt_divisor     = neg_divisor ? negated_divisor : divisor_norm;

  assign new_opb_operand = (fsm_reg == CA53_DIV_ST_IDLE) ? div_opb_ext_iss : nxt_divisor;

  always @(posedge clk_div)
    if (divisor_wr_en)
      divisor <= new_opb_operand;

  always @(posedge clk_div)
    if (raw_div_valid_iss_i & (fsm_reg == CA53_DIV_ST_IDLE))
      sign_reg <= div_signed_iss_i;

  // Negate result's sign if required
  assign neg_res = sign_reg & (rem_sum[63] ^ divisor[63]);

  always @(posedge clk_div)
    if (fsm_reg[FSM_MOD_CLZ])
      neg_res_reg <= neg_res;

  //
  // Sign convert block
  //

  assign negated_remainder = -rem_sum[63:0];
  assign neg_remainder     = fsm_reg[FSM_MOD_CLZ] & sign_reg & rem_sum[63];


  assign negated_divisor   = -divisor[63:0];
  assign neg_divisor       = fsm_reg[FSM_MOD_CLZ] & sign_reg & divisor[63];

  //
  // CLZ and LS block
  //

  // Calculate the distance between dividend and divisor to determine
  // iterations of algorithm required or whether divisor is greater than
  // dividend
  ca53dpu_alu_clz u_clz_remainder (
    // Inputs
    .data_i           (rem_sum[63:0]),
    .ctl_64bit_op_i   (1'b1),
    .sel_sign_count_i (1'b0),
    .sel_zero_count_i (1'b1),
    // Outputs
    .clz_res_o        (clz_remainder)
  );

  ca53dpu_alu_clz u_clz_divisor (
    // Inputs
    .data_i           (divisor[63:0]),
    .ctl_64bit_op_i   (1'b1),
    .sel_sign_count_i (1'b0),
    .sel_zero_count_i (1'b1),
    // Outputs
    .clz_res_o        (clz_divisor)
  );

  assign clz_remainder_divisor_delta     = clz_divisor - clz_remainder;
  assign {divisor_gt_remainder,clz_diff} = clz_remainder_divisor_delta;

  // Check if divisor or dividend is zero and make result equal to zero
  assign divisor_eq_zero = clz_divisor[6];
  assign zero = divisor_gt_remainder | divisor_eq_zero;

  // normalise dividend and divisor before applying SRT algorithm
  assign remainder_norm = rem_sum[63:0] << clz_remainder;

  assign divisor_norm   = divisor[63:0] << clz_divisor;

  // calculate iterations of SRT required to run - decrements whilst in
  // fsm_step state. 4 bits retired per cycle - must keep iters_required in
  // full format to allow for less than 4 bits in final cycle
  assign iters_required_m1  = iters_required[5:0] - 6'h04;
  assign nxt_iters_required = (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ]) ? (clz_diff) : iters_required_m1;
  assign final_cycle        = ~|(iters_required[5:2]); // iters == 0, 1, 2 or 3
  assign iters_required_en  = fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ] | fsm_reg[FSM_STEP];

  always @(posedge clk_div)
    if (iters_required_en)
      iters_required <= nxt_iters_required;

//----------------------------------------------------------------------------
// Iteration stage
//----------------------------------------------------------------------------

  assign rem_carry_wr_en = fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ] | fsm_reg[FSM_STEP];

  always @(posedge clk_div)
    if (rem_carry_wr_en)
      rem_carry <= nxt_rem_carry;

  assign nxt_rem_carry = (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ]) ? {66{1'b0}} : new_rem_carry;

  // When less than 3 iterations required in final cycle must choose appropriate
  // remainder value. This is important as remainder must be checked in fsm state
  // FSM_CORR whether it is positive/negative.
  assign new_rem_carry = ~|(iters_required[5:2]) ?
    (iters_required[0] ? rem_carry_dp[4] : rem_carry_dp[3]) : rem_carry_dp[4];
  // if iters_reqd == 0 or 1 load 2nd rem version because when equal to
  // 0 or 1 correction state is skipped (is done in step state instead)
  assign new_rem_sum   = ~|(iters_required[5:2]) ?
    (iters_required[0] ? rem_sum_dp[4] : rem_sum_dp[3]) : rem_sum_dp[4];


  //----------------------------------------------------------------------------
  // SRT control path
  //----------------------------------------------------------------------------

  assign rem_sum_cp[0] = rem_sum[65:55];
  assign rem_carry_cp[0] = rem_carry[65:55];
  assign quot_dig[0] = prev_quot_dig;

  generate for (i = 0 ; i < 4; i = i+1) begin : g_srt_control_path

    // 3 CSAs generate 3 possible results before outcome of quotient selection
    // logic - and then MUX between them.
    // Each CSA includes MSB Compression logic so that no information is lost
    // in 1-bit left shift.
    // These become successively narrower through each SRT iteration within
    // a cycle - this is because only 3 bits are required for final quotient
    // selection - however an extra 2 bits (1 thrown away for LS and 1 needed
    // from carry input) are required at each iteration. Therefore 11 bits are
    // input at first CSA - going down to 3 bits out of last CSA.
    ca53dpu_div_csa #(.CSA_WIDTH(11-(2*i)))
    u_div_csa (
      .csa_plus_i           (divisor        [62:(55+(2*i))]),
      .csa_minus_i          (divisor        [62:(55+(2*i))]),
      .rem_sum_i            (rem_sum_cp[i]  [9:(2*i)]),
      .rem_carry_i          (rem_carry_cp[i][9:(2*i)]),

      .rem_sum_zero_o       (rem_sum_zero[i]     [10:((2*i)+1)]),
      .rem_carry_zero_o     (rem_carry_zero[i]   [10:((2*i)+1)]),
      .rem_sum_minus_d_o    (rem_sum_minus_d[i]  [10:((2*i)+1)]),
      .rem_carry_minus_d_o  (rem_carry_minus_d[i][10:((2*i)+1)]),
      .rem_sum_plus_d_o     (rem_sum_plus_d[i]   [10:((2*i)+1)]),
      .rem_carry_plus_d_o   (rem_carry_plus_d[i] [10:((2*i)+1)])
    );
    // Set unused array bits to zero - LINT warnings
    assign rem_sum_zero[i]     [((2*i)):0] = {((2*i)+1){1'b0}};
    assign rem_carry_zero[i]   [((2*i)):0] = {((2*i)+1){1'b0}};
    assign rem_sum_minus_d[i]  [((2*i)):0] = {((2*i)+1){1'b0}};
    assign rem_carry_minus_d[i][((2*i)):0] = {((2*i)+1){1'b0}};
    assign rem_sum_plus_d[i]   [((2*i)):0] = {((2*i)+1){1'b0}};
    assign rem_carry_plus_d[i] [((2*i)):0] = {((2*i)+1){1'b0}};

    // Determine potential quotient digits before outcome of previous quotient
    // selection logic is apparent - and then MUX between them
    ca53dpu_div_quot u_div_quot_zero (
      .rem_sum_msb_i    (rem_sum_zero[i][10:8]),
      .rem_carry_msb_i  (rem_carry_zero[i][10:8]),

      .quot_dig_o       (quot_dig_zero[i])
    );
    ca53dpu_div_quot u_div_quot_plus_d (
      .rem_sum_msb_i    (rem_sum_plus_d[i][10:8]),
      .rem_carry_msb_i  (rem_carry_plus_d[i][10:8]),

      .quot_dig_o       (quot_dig_plus_d[i])
    );
    ca53dpu_div_quot u_div_quot_minus_d (
      .rem_sum_msb_i    (rem_sum_minus_d[i][10:8]),
      .rem_carry_msb_i  (rem_carry_minus_d[i][10:8]),

      .quot_dig_o       (quot_dig_minus_d[i])
    );

    assign rem_sum_cp[i+1]    = quot_dig[i][0] ? rem_sum_minus_d[i]   :
                                quot_dig[i][1] ? rem_sum_plus_d[i]    :
                                                 rem_sum_zero[i];

    assign rem_carry_cp[i+1]  = quot_dig[i][0] ? rem_carry_minus_d[i] :
                                quot_dig[i][1] ? rem_carry_plus_d[i]  :
                                                 rem_carry_zero[i];

    assign quot_dig[i+1]      = quot_dig[i][0] ? quot_dig_minus_d[i]  :
                                quot_dig[i][1] ? quot_dig_plus_d[i]   :
                                                 quot_dig_zero[i];

  end endgenerate

  // initialise Q0 = 1 due to knowledge of normalised rem and divisor.
  assign n_prev_quot_dig = (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ]) ? 2'b01 : quot_dig[4];

  always @(posedge clk_div)
    prev_quot_dig <= n_prev_quot_dig;

  //----------------------------------------------------------------------------
  // SRT data path
  //----------------------------------------------------------------------------

  assign rem_sum_dp[0] = rem_sum;
  assign rem_carry_dp[0] = rem_carry;

  generate for (i = 0 ; i < 3; i = i+1) begin : g_srt_data_path

    assign mux_divisor[i][59+i:0] = quot_dig[i][0] ? ~divisor[59+i:0]  :
                                    quot_dig[i][1] ?  divisor[59+i:0]  :
                                                     {(60+i){1'b0}};
    if (i < 3) begin : g_srt_data_path_set_unused_to_zero
      assign mux_divisor[i][62:60+i] = {(3-i){1'b0}};
    end

    assign rem_sum_dp[i+1][60+i:0] = {rem_sum_dp[i][59+i:0]   ^
                                      rem_carry_dp[i][59+i:0] ^
                                      mux_divisor[i][59+i:0],
                                      1'b0}; // Left shift for SRT

    assign rem_carry_dp[i+1][61+i:0] =
      {(rem_sum_dp[i][59+i:0]   & rem_carry_dp[i][59+i:0]) |
       (rem_sum_dp[i][59+i:0]   & mux_divisor[i][59+i:0])  |
       (rem_carry_dp[i][59+i:0] & mux_divisor[i][59+i:0]),
       quot_dig[i][0], // to account for subtract divisor case
       1'b0}; // Left shift for SRT

    // Take MSBs from Control Path outputs to reduce repetitive logic
    assign rem_sum_dp[i+1][65:61+i]   = rem_sum_cp[i+1][10:6+i];
    assign rem_carry_dp[i+1][65:62+i] = rem_carry_cp[i+1][10:7+i];
  end endgenerate

  // Speculatively calculate full width CSA for final iteration to reduce
  // critical path (ie. so CSA does not occur after quot_dig[3] is ready)
  ca53dpu_div_csa #(.CSA_WIDTH(66))
  u_div_csa_full_width (
    .csa_plus_i           (divisor        [62:0]),
    .csa_minus_i          (divisor        [62:0]),
    .rem_sum_i            (rem_sum_dp[3]  [64:0]),
    .rem_carry_i          (rem_carry_dp[3][64:0]),

    .rem_sum_zero_o       (rem_sum_zero_dp     [64:0]),
    .rem_carry_zero_o     (rem_carry_zero_dp   [64:0]),
    .rem_sum_minus_d_o    (rem_sum_minus_d_dp  [64:0]),
    .rem_carry_minus_d_o  (rem_carry_minus_d_dp[64:0]),
    .rem_sum_plus_d_o     (rem_sum_plus_d_dp   [64:0]),
    .rem_carry_plus_d_o   (rem_carry_plus_d_dp [64:0])
  );

  assign rem_sum_dp[4][65:0] =
    {(quot_dig[3][0] ? rem_sum_minus_d_dp :
      quot_dig[3][1] ? rem_sum_plus_d_dp  :
                       rem_sum_zero_dp), 1'b0};

  assign rem_carry_dp[4][65:0] =
    {(quot_dig[3][0] ? rem_carry_minus_d_dp :
      quot_dig[3][1] ? rem_carry_plus_d_dp  :
                       rem_carry_zero_dp), 1'b0};

  //----------------------------------------------------------------------------
  // SRT Correction
  //----------------------------------------------------------------------------

  // full carry add required for final correction step to determine whether
  // final remainder is positive or negative. If positive, result is quotient
  // and if negative, result is (quotient - 1).
  // If only 1 or 2 iterations required in final step cycle, we have time to
  // perform full CPA on these and perform correction step without one cycle
  // penalty.
  assign rem_cpa =  ~|(iters_required[5:1]) ?
    (iters_required[0] ?
      (rem_sum_dp[2] + rem_carry_dp[2])  :
      (rem_sum_dp[1] + rem_carry_dp[1])) :
    (rem_sum + rem_carry);

  assign skip_corr =  ~|(iters_required[5:1]); // if iters_reqd == 0 or 1

  assign nxt_final_rem_negative = rem_cpa[65];
  assign final_rem_negative_en  = fsm_reg[FSM_STEP] | fsm_reg[FSM_CORR];

  always @(posedge clk_div)
    if (final_rem_negative_en)
      final_rem_negative <= nxt_final_rem_negative;

  assign final_quotient = final_rem_negative ? quotient_m1 : quotient;

  //----------------------------------------------------------------------------
  // Quotient Logic
  //  - Decodes quotient digits to fill quotient (result) register
  //----------------------------------------------------------------------------
  assign  nxt_quotient    = fsm_reg[FSM_STEP] ? n_quotient_step    : {64{1'b0}};
  assign  nxt_quotient_m1 = fsm_reg[FSM_STEP] ? n_quotient_m1_step : {64{1'b0}};

    // quotient and quotient-1 (quotient_m1) are stored so next quotient can
    // be determined without a subtractor and for easy correction after
    // final iteration. From Ercegovac "on the fly quotient conversion".

    // Must select different quotient value dependent on number of SRT
    // iterations still required.
  assign n_quotient_step    = ~|(iters_required[5:2]) ?
      (iters_required[1] ?
        (iters_required[0] ? n_quotient[3] : n_quotient[2]) :
        (iters_required[0] ? n_quotient[1] : n_quotient[0])) :
    n_quotient[3];

  assign n_quotient_m1_step = ~|(iters_required[5:2]) ?
      (iters_required[1] ?
        (iters_required[0] ? n_quotient_m1[3] : n_quotient_m1[2]) :
        (iters_required[0] ? n_quotient_m1[1] : n_quotient_m1[0])) :
    n_quotient_m1[3];

  // nxt_quotient logic when 1 bit is retired in a cycle
  assign n_quotient[0]    = quot_dig[0][0] ? {quotient[62:0] , 1'b1} :
    (quot_dig[0][1] ? {quotient_m1[62:0] , 1'b1} :
                      {quotient[62:0]    , 1'b0});

  assign n_quotient_m1[0] = quot_dig[0][0] ? {quotient[62:0] , 1'b0} :
    (quot_dig[0][1] ? {quotient_m1[62:0] , 1'b0} :
                      {quotient_m1[62:0] , 1'b1});

  // nxt_quotient logic when more than 1 bit is retired in a cycle
  generate for (i = 1 ; i < 4; i = i+1) begin : g_n_quotient

    assign n_quotient[i]    = quot_dig[i][0] ? {n_quotient[i-1][62:0] , 1'b1} :
      (quot_dig[i][1] ? {n_quotient_m1[i-1][62:0] , 1'b1} :
                        {n_quotient[i-1][62:0]    , 1'b0});

    assign n_quotient_m1[i] = quot_dig[i][0] ? {n_quotient[i-1][62:0] , 1'b0} :
      (quot_dig[i][1] ? {n_quotient_m1[i-1][62:0] , 1'b0} :
                        {n_quotient_m1[i-1][62:0] , 1'b1});

  end endgenerate

  assign quot_enable = fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ] | fsm_reg[FSM_STEP];

  always @(posedge clk_div)
    if (quot_enable) begin
      quotient    <= nxt_quotient;
      quotient_m1 <= nxt_quotient_m1;
    end

  //----------------------------------------------------------------------------
  // Outputs of Divider Unit
  //----------------------------------------------------------------------------

  assign div_busy_iss_o     = (fsm_reg != CA53_DIV_ST_IDLE);

  // Do not need to consider start or flush, as this signal isn't used
  // in those cases
  assign nxt_div_busy_wr    = (nxt_fsm_reg_noflush != CA53_DIV_ST_IDLE);

  assign nxt_div_busy_wr_o  = nxt_div_busy_wr;
  assign div_res_wr_o       = fsm_reg[FSM_ZERO] ? {64{1'b0}}      : 
                              neg_res_reg       ? -final_quotient : 
                                                  final_quotient;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: div_valid_iss_i")
  u_ovl_x_div_valid_iss_i (.clk       (clk_div),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (div_valid_iss_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: divisor_wr_en")
  u_ovl_x_divisor_wr_en (.clk       (clk_div),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (divisor_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: final_rem_negative_en")
  u_ovl_x_final_rem_negative_en (.clk       (clk_div),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (final_rem_negative_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iters_required_en")
  u_ovl_x_iters_required_en (.clk       (clk_div),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (iters_required_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: quot_enable")
  u_ovl_x_quot_enable (.clk       (clk_div),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (quot_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rem_carry_wr_en")
  u_ovl_x_rem_carry_wr_en (.clk       (clk_div),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (rem_carry_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: remainder_wr_en")
  u_ovl_x_remainder_wr_en (.clk       (clk_div),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (remainder_wr_en));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fsm_reg_zoh
  // cc_pass_instr0 has taken an unknown (X?) value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Divider FSM must be one-hot or zero")
    ovl_fsm_reg_zoh (.clk              (clk_div),
                     .reset_n          (reset_n),
                     .test_expr        (fsm_reg)
                     );

  // Divider can only accept a new transaction when it is in the idle state
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A new divide must not be issued when one is already in progress")
    ovl_start_when_idle (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (div_valid_iss_i),
                         .consequent_expr (fsm_reg == CA53_DIV_ST_IDLE)
                        );

  // Assert quot_dig signals are ZOH (can never be 2'b11) so that
  // quotient decode logic will work

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "prev_quot_dig must not be 2'b11 during SRT iteration")
    ovl_prev_quot_step (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg[FSM_STEP]),
                     .consequent_expr (prev_quot_dig!=2'b11));
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "quot_dig[0] must not be 2'b11 during SRT iteration")
    ovl_quot_0_step (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg[FSM_STEP]),
                     .consequent_expr (quot_dig[0]!=2'b11));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "quot_dig[1] must not be 2'b11 during SRT iteration")
    ovl_quot_1_step (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg[FSM_STEP]),
                     .consequent_expr (quot_dig[1]!=2'b11));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "quot_dig[2] must not be 2'b11 during SRT iteration")
    ovl_quot_2_step (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg[FSM_STEP]),
                     .consequent_expr (quot_dig[2]!=2'b11));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "quot_dig[3] must not be 2'b11 during SRT iteration")
    ovl_quot_3_step (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg[FSM_STEP]),
                     .consequent_expr (quot_dig[3]!=2'b11));

  // Assert that each SRT iteration is performing the CSA correctly.
  generate for (i = 0 ; i < 4; i = i+1) begin : g_ovl_iter_checker

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Partial Remainder not equal to (2*(previous_remainder) + or - divisor)")
      u_ovl_srt_rem_check (.clk   (clk_div),
                    .reset_n  (reset_n),
                    .antecedent_expr(fsm_reg[FSM_STEP]),
                    .consequent_expr(
         // Qi = 1
         (quot_dig[i][0] &
         (rem_sum_dp[i+1]+rem_carry_dp[i+1])==
         2*((rem_sum_dp[i] + rem_carry_dp[i])-{2'b00,divisor})) |
         // Qi = -1
         (quot_dig[i][1] &
         (rem_sum_dp[i+1]+rem_carry_dp[i+1])==
         2*((rem_sum_dp[i] + rem_carry_dp[i])+{2'b00,divisor})) |
         // Qi = 0
         ((rem_sum_dp[i+1]+rem_carry_dp[i+1])==
         2*(rem_sum_dp[i] + rem_carry_dp[i]))
         )
       );

  end
  endgenerate

  // Assert that remainder cannot be out of range - defined by SRT algorithm

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "(rem_sum + rem_carry) must be within -2d to 2d")
  u_ovl_rem_srt_bounds (.clk (clk_div),
                        .reset_n (reset_n),
                        .antecedent_expr(fsm_reg[FSM_STEP]),
                        .consequent_expr(
    ((rem_sum[65] & rem_carry[65]) // both sum and carry negative
    & ((rem_sum[64:0]+rem_carry[64:0]) >= (67'h4_0000_0000_0000_0000-(2*divisor)))) |
    ((rem_sum[65] ^ rem_carry[65]) // either sum or carry negative
    & ((rem_sum[64:0]+rem_carry[64:0]) >= (66'h2_0000_0000_0000_0000-(2*divisor)))
    & ((rem_sum[64:0]+rem_carry[64:0]) <= (66'h2_0000_0000_0000_0000+(2*divisor))))|
    ((~rem_sum[65] & ~rem_carry[65]) // neither sum or carry negative
    & ((rem_sum[64:0] + rem_carry[64:0]) <= (2*divisor)))
   ));

  // Assertion to prove division result is correct
  reg [63:0]  ovl_assert_result;
  reg [4:0]   ovl_prev_fsm;
  reg         ovl_prev_div_busy;
  reg         ovl_prev_valid_iss;
  reg         ovl_prev_flush;
  wire [63:0] ovl_nxt_assert_result;

  assign ovl_nxt_assert_result = ~|(divisor[63:0]) ? {64{1'b0}} : (rem_sum[63:0]/divisor);

  always @(posedge clk_div)
    if (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ])
      ovl_assert_result <= ovl_nxt_assert_result;

  always @(posedge clk_div) begin
    ovl_prev_fsm       <= fsm_reg;
    ovl_prev_div_busy  <= nxt_div_busy_wr;
    ovl_prev_valid_iss <= div_valid_iss_i;
    ovl_prev_flush     <= div_flush_i;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unsigned Division result must equal positive rem / positive divisor")
  u_ovl_div_res_check (.clk (clk_div),
                       .reset_n (reset_n),
                       .antecedent_expr(
    ((ovl_prev_fsm != CA53_DIV_ST_IDLE) & (fsm_reg == CA53_DIV_ST_IDLE) & ~ovl_prev_flush) |
    ((ovl_prev_fsm != CA53_DIV_ST_IDLE) & ~ovl_prev_div_busy & ovl_prev_valid_iss & ~ovl_prev_flush)),
                       .consequent_expr(
    ( ovl_assert_result == final_quotient) |
    ((ovl_assert_result == {64{1'b0}}) & fsm_reg[FSM_ZERO])));

  // Assert quotient_m1 is equal to quotient-1 after STEP state
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "quotient_m1 must equal quotient-1")
    ovl_quotient_m1 (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (ovl_prev_fsm == CA53_DIV_ST_STEP),
                     .consequent_expr (quotient_m1==(quotient-1)));


  // Assert: remainder = dividend - divisor*quotient
  // (With some shifts toaccount for normalised remainder and quotient
  //  fill mechanism)
  reg  [63:0] ovl_divisor; //Un-normalised divisor after sign removal
  reg  [6:0]  ovl_rem_shift; //How far to shift remainder to normalised remainder
  reg  [63:0] ovl_dividend; // Un-normalised dividend after sign removal
  wire [6:0]  ovl_nxt_rem_shift;
  wire [65:0] ovl_rem;

  always @(posedge clk_div)
    if (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ]) begin
      ovl_divisor <= divisor;
      ovl_dividend <= rem_sum[63:0];
    end

  assign ovl_nxt_rem_shift = (fsm_reg[FSM_MOD_CLZ] | fsm_reg[FSM_CLZ]) ? clz_remainder :
    (final_cycle ? (ovl_rem_shift + iters_required + 7'h01) : (ovl_rem_shift + 7'h04));

  always @(posedge clk_div)
    ovl_rem_shift <= ovl_nxt_rem_shift;

  assign ovl_rem = rem_sum+rem_carry;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dividend - quotient*divisor = remainder")
    ovl_quot_rem    (.clk             (clk_div),
                     .reset_n         (reset_n),
                     .antecedent_expr (fsm_reg == CA53_DIV_ST_STEP),
                     .consequent_expr (ovl_rem[63:0] == ((ovl_dividend - ovl_divisor*(quotient<<(iters_required+1))<<ovl_rem_shift)))
                   );

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
