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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : MAC block.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Handles all the integer ISA multiply, multiply-accumulate and
// sum-of-absolute-differences instructions
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_mac (
  // Inputs
  input  wire                           clk,
  input  wire                           reset_n,
  input  wire                           DFTSE,
  input  wire                           stall_wr_i,           // don't progress pipe
  input  wire                           flush_wr_i,           // Clear on flush
  input  wire                           mac_valid_de_i,       // command and data valid
  input  wire                           raw_mac_valid_iss_i,  // command and data valid (unqualified)
  input  wire                           mac_valid_iss_i,      // command and data valid
  input  wire [`CA53_MAC_ISS_CTL_W-1:0] mac_cmd_iss_i,        // mac unit comannd
  input  wire                           slot1_mul_iss_i,      // Multiply is in slot 1
  input  wire                     [5:0] mac_fwd_ctl_ex1_i,    // forwarding control for the Ex2 stage (use internal acc)
  input  wire                    [63:0] mac_opa_iss_i,        // first operand
  input  wire                    [63:0] mac_opb_iss_i,        // second operand
  input  wire                    [63:0] st0_data_ex2_i,       // Data from store pipe 0
  input  wire                    [63:0] st1_data_ex2_i,       // Data from store pipe 0
  // Outputs
  output wire                           mac_stall_iss_o,      // A multi-cycle 64x64 multiply is Iss
  output wire                    [31:0] mac_res_lo_wr_o,      // low part of result
  output wire                    [31:0] mac_res_hi_wr_o,      // high part of result
  output wire                           mac_q_wr_o,           // cspr Q bit
  output wire                           mac_n_wr_o,           // N bit
  output wire                           mac_z_wr_o            // Z bit
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           valid_ex1;
  reg           valid_ex2;
  reg    [3:0]  mult_type_ex1;
  reg           neg_second_ex1;
  reg           neg_second_ex2;
  reg           acc_high_ex1;
  reg           acc_high_ex2;
  reg           acc_high_wr;
  reg           negate_mul_ex1;
  reg           negate_mul_ex2;
  reg           round_ex1;
  reg           round_ex2;
  reg           signed_ex1;
  reg           signed_ex2;
  reg           accum_lo_ex1;
  reg           accum_hi_ex1;
  reg           slot1_mul_ex1;
  reg   [15:0]  a_lo_iss;
  reg   [15:0]  a_hi_iss;
  reg   [15:0]  b_lo_iss;
  reg   [15:0]  b_hi_iss;
  reg   [15:0]  a_lo_ex1;
  reg   [15:0]  a_hi_ex1;
  reg   [15:0]  b_lo_ex1;
  reg   [15:0]  b_hi_ex1;
  reg   [31:0]  a_other_iss;
  reg   [31:0]  b_other_iss;
  reg   [31:0]  a_other_ex1;
  reg   [31:0]  b_other_ex1;
  reg           a_lo_sign_iss;
  reg           a_hi_sign_iss;
  reg           b_lo_sign_iss;
  reg           b_hi_sign_iss;
  reg           a_lo_sign_ex1;
  reg           a_hi_sign_ex1;
  reg           b_lo_sign_ex1;
  reg           b_hi_sign_ex1;
  reg           sel_lo_lo_ex1;
  reg           sel_hi_ex1;
  reg           sel_hi_hi_dual_ex1;
  reg           raw_sel_feed_ex1;
  reg           sel_usad_ex1;
  reg           sel_accu_right_ex1;
  reg           sel_mul_left_ex1;
  reg           sel_feed_lo_ex2;
  reg           sel_feed_hi_ex2;
  reg           sel_acc0_lo_ex2;
  reg           sel_acc1_lo_ex2;
  reg           sel_acc0_hi_ex2;
  reg           sel_acc1_hi_ex2;
  reg           sel_accu_right_ex2;
  reg           sel_mul_left_ex2;
  reg   [48:0]  partial_1_ex2;
  reg   [56:8]  partial_2_ex2;
  reg   [64:0]  partial_3_ex2;
  reg   [48:8]  partial_4_ex2;
  reg   [39:16] partial_5_hi_ex2;
  reg           mult_sign_ex2;
  reg           mult_sign_wr;
  reg   [65:0]  accum_res_wr;
  reg           acc_sign_wr;
  reg           mac_clock_en;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire          advance_mac_pipeline;
  wire          issue_mac_to_ex1;
  wire          step_mac_ex1;
  wire          en_other_ex1;
  wire          issue_mac_to_ex2;
  wire          en_acc_sel_ex2;
  wire          issue_mac_to_wr;
  wire          valid_iss;
  wire          go_to_64x64_lh;
  wire          go_to_64x64_hl;
  wire          go_to_64x64_hh;
  wire          mac_stall_iss;
  wire   [3:0]  raw_mult_type_iss;
  wire   [3:0]  mult_type_iss;
  wire          neg_second_iss;
  wire          acc_high_iss;
  wire          negate_mul_iss;
  wire          mac_b_sel_iss;
  wire          mac_a_sel_iss;
  wire          signed_iss;
  wire          round_iss;
  wire          accum_lo_iss;
  wire          accum_hi_iss;
  wire          a_other_zero_ex1;
  wire          b_other_zero_ex1;
  wire   [9:0]  adif_ex1;
  wire  [23:0]  prod_a_lo_b_lo0_ex1;
  wire  [23:0]  prod_a_lo_b_lo1_ex1;
  wire  [23:0]  prod_a_lo_b_hi0_ex1;
  wire  [24:0]  prod_a_lo_b_hi1_ex1;
  wire  [23:0]  prod_a_hi0_b_lo_ex1;
  wire  [24:0]  prod_a_hi1_b_lo_ex1;
  wire  [24:0]  prod_a_hi_b_hi0_ex1;
  wire  [24:0]  prod_a_hi_b_hi1_ex1;
  wire          prod_a_lo_b_lo0_sign_ex1;
  wire          prod_a_lo_b_lo1_sign_ex1;
  wire          prod_a_hi_b_hi0_sign_ex1;
  wire          prod_a_hi_b_hi1_sign_ex1;
  wire          raw_sel_acc0_lo_ex1;
  wire          raw_sel_acc1_lo_ex1;
  wire          raw_sel_acc0_hi_ex1;
  wire          raw_sel_acc1_hi_ex1;
  wire          sel_feed_lo_ex1;
  wire          sel_feed_hi_ex1;
  wire          sel_acc0_lo_ex1;
  wire          sel_acc1_lo_ex1;
  wire          sel_acc0_hi_ex1;
  wire          sel_acc1_hi_ex1;
  wire  [65:0]  accum_val;
  wire  [48:0]  partial_1_ex1;
  wire  [56:8]  partial_2_ex1;
  wire  [64:0]  partial_3_ex1;
  wire  [48:8]  partial_4_ex1;
  wire  [39:16] partial_5_hi_ex1;
  wire  [39:0]  partial_5_ex2;
  wire  [65:0]  partial_7_ex2;
  wire          mult_sign_ex1;
  wire  [65:0]  mult_res;
  wire  [65:0]  raw_accum_res_ex2;
  wire  [65:0]  accum_res_ex2;
  wire          acc_sign_ex2;
  wire          mac_q_lo;
  wire          mac_q_hi;
  wire          mac_z_lo;
  wire          mac_z_hi;
  wire          clk_mac;
  wire          nxt_mac_clock_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  //---------------------------------------------------------------------------
  // All stages
  // Regional clock gate
  //---------------------------------------------------------------------------

  assign nxt_mac_clock_en = mac_valid_de_i | raw_mac_valid_iss_i | valid_ex1 | valid_ex2;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      mac_clock_en <= 1'b1;
    else
      mac_clock_en <= nxt_mac_clock_en;

  ca53_cell_inter_clkgate u_inter_clkgate_mac (
    .clk_i         (clk),
    .clk_enable_i  (mac_clock_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_mac)
  );

  //---------------------------------------------------------------------------
  // Iss stage
  // Formats input operands for Ex1 multipliers
  //---------------------------------------------------------------------------

  assign advance_mac_pipeline = ~stall_wr_i | flush_wr_i;

  assign raw_mult_type_iss  = mac_cmd_iss_i[3:0];

  assign neg_second_iss   = mac_cmd_iss_i[4];   // sub 2'nd (Ax x By) for 2x16x16
  assign negate_mul_iss   = mac_cmd_iss_i[5];   // neg
  assign mac_b_sel_iss    = mac_cmd_iss_i[6];   // y
  assign mac_a_sel_iss    = mac_cmd_iss_i[7];   // x
  assign signed_iss       = mac_cmd_iss_i[8];   // signed / ~unsigned
  assign acc_high_iss     = mac_cmd_iss_i[9];   // accumulate into high half, extract flags from high half
  assign round_iss        = mac_cmd_iss_i[10];  // add rnd
  assign accum_lo_iss     = mac_cmd_iss_i[11];  // Accumulate low 32 bits
  assign accum_hi_iss     = mac_cmd_iss_i[12];  // Accumulate high 32 bits

  // 64x64 multiplies are synthesized using 32x32 multiplies over multiple cycles
  // The mult_type_ex1 field is used as a state machine to control this

  assign go_to_64x64_lh = valid_ex1 &   (mult_type_ex1 == `CA53_MULT_TYPE_64x64)    & (acc_high_ex1 | ~b_other_zero_ex1);
  assign go_to_64x64_hl = valid_ex1 & (((mult_type_ex1 == `CA53_MULT_TYPE_64x64)    & ~acc_high_ex1 &  b_other_zero_ex1) |
                                       ((mult_type_ex1 == `CA53_MULT_TYPE_64x64_LH) & (acc_high_ex1 | ~a_other_zero_ex1)));
  assign go_to_64x64_hh = valid_ex1 &   (mult_type_ex1 == `CA53_MULT_TYPE_64x64_HL) &  acc_high_ex1;

  assign valid_iss     = (mac_valid_iss_i | go_to_64x64_lh | go_to_64x64_hl) & ~flush_wr_i;

  assign mult_type_iss = go_to_64x64_lh ? `CA53_MULT_TYPE_64x64_LH :
                         go_to_64x64_hl ? `CA53_MULT_TYPE_64x64_HL :
                         go_to_64x64_hh ? `CA53_MULT_TYPE_64x64_HH :
                                          raw_mult_type_iss;

  // Stall pipeline if this multiply needs to take multiple cycles
  assign mac_stall_iss = (raw_mac_valid_iss_i & (mult_type_iss == `CA53_MULT_TYPE_64x64)) |
                         (go_to_64x64_lh & (acc_high_ex1 | ~a_other_zero_ex1))      |
                         (go_to_64x64_hl &  acc_high_ex1);

  // Generate the operands based on the type of instruction

  always @*
    case (mult_type_iss)
      `CA53_MULT_TYPE_ACCONLY : begin
        a_lo_iss = mac_opa_iss_i[15: 0];
        a_hi_iss = mac_opa_iss_i[31:16];

        b_lo_iss = 16'h0001;
        b_hi_iss = {16{1'b0}};
      end

      `CA53_MULT_TYPE_USAD,
      `CA53_MULT_TYPE_32x32: begin
        a_lo_iss = mac_opa_iss_i[15: 0];
        a_hi_iss = mac_opa_iss_i[31:16];

        b_lo_iss = mac_opb_iss_i[15: 0];
        b_hi_iss = mac_opb_iss_i[31:16];
      end

      `CA53_MULT_TYPE_32x16: begin
        a_lo_iss = mac_opa_iss_i[15: 0];
        a_hi_iss = mac_opa_iss_i[31:16];

        b_lo_iss = {16{1'b0}};
        b_hi_iss = mac_b_sel_iss ? mac_opb_iss_i[31:16] : mac_opb_iss_i[15: 0];
      end

      `CA53_MULT_TYPE_16x16: begin
        a_lo_iss = mac_a_sel_iss ? mac_opa_iss_i[31:16] : mac_opa_iss_i[15: 0];
        b_lo_iss = mac_b_sel_iss ? mac_opb_iss_i[31:16] : mac_opb_iss_i[15: 0];

        a_hi_iss = {16{1'b0}};
        b_hi_iss = {16{1'b0}};
      end

      `CA53_MULT_TYPE_2x16x16: begin
        a_lo_iss = mac_opa_iss_i[15: 0];
        a_hi_iss = mac_opa_iss_i[31:16];

        b_lo_iss = mac_b_sel_iss ? mac_opb_iss_i[31:16] : mac_opb_iss_i[15: 0];
        b_hi_iss = mac_b_sel_iss ? mac_opb_iss_i[15: 0] : mac_opb_iss_i[31:16];
      end

      `CA53_MULT_TYPE_64x64: begin
        a_lo_iss = mac_opa_iss_i[15: 0];
        a_hi_iss = mac_opa_iss_i[31:16];

        b_lo_iss = mac_opb_iss_i[15: 0];
        b_hi_iss = mac_opb_iss_i[31:16];
      end

      `CA53_MULT_TYPE_64x64_LH: begin
        a_lo_iss = a_lo_ex1;
        a_hi_iss = a_hi_ex1;

        b_lo_iss = b_other_ex1[15: 0];
        b_hi_iss = b_other_ex1[31:16];
      end

      `CA53_MULT_TYPE_64x64_HL: begin
        a_lo_iss = a_other_ex1[15: 0];
        a_hi_iss = a_other_ex1[31:16];

        b_lo_iss = (mult_type_ex1 == `CA53_MULT_TYPE_64x64) ? b_lo_ex1 : b_other_ex1[15: 0];
        b_hi_iss = (mult_type_ex1 == `CA53_MULT_TYPE_64x64) ? b_hi_ex1 : b_other_ex1[31:16];
      end

      `CA53_MULT_TYPE_64x64_HH: begin
        a_lo_iss = a_lo_ex1;
        a_hi_iss = a_hi_ex1;

        b_lo_iss = b_other_ex1[15: 0];
        b_hi_iss = b_other_ex1[31:16];
      end

      default: begin
        a_lo_iss = {16{1'bx}};
        a_hi_iss = {16{1'bx}};

        b_lo_iss = {16{1'bx}};
        b_hi_iss = {16{1'bx}};
      end
    endcase

  // Multiplex the "spare" 32 bits of a 64-bit operand, for use in later cycles

  always @*
    case (mult_type_iss)
      `CA53_MULT_TYPE_64x64: begin
        a_other_iss = mac_opa_iss_i[63:32];
        b_other_iss = mac_opb_iss_i[63:32];
      end

      `CA53_MULT_TYPE_64x64_LH: begin
        a_other_iss = a_other_ex1;
        b_other_iss = {b_hi_ex1, b_lo_ex1};
      end

      `CA53_MULT_TYPE_64x64_HL: begin
        a_other_iss = {a_hi_ex1, a_lo_ex1};
        b_other_iss = {b_hi_ex1, b_lo_ex1};
      end

      default: begin
        a_other_iss = {32{1'bx}};
        b_other_iss = {32{1'bx}};
      end
    endcase

  // Calculate signs of multiplier operands
  // For unsigned instructions, the operands are always positive

  always @*
    case (mult_type_iss)
      `CA53_MULT_TYPE_ACCONLY,
      `CA53_MULT_TYPE_USAD: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = 1'b0;
        b_hi_sign_iss = 1'b0;
      end

      `CA53_MULT_TYPE_32x32: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = a_hi_iss[15] & signed_iss;
        b_hi_sign_iss = b_hi_iss[15] & signed_iss;
      end

      `CA53_MULT_TYPE_32x16: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = a_hi_iss[15];
        b_hi_sign_iss = b_hi_iss[15];
      end

      `CA53_MULT_TYPE_16x16,
      `CA53_MULT_TYPE_2x16x16: begin
        a_lo_sign_iss = a_lo_iss[15];
        b_lo_sign_iss = b_lo_iss[15];
        a_hi_sign_iss = a_hi_iss[15];
        b_hi_sign_iss = b_hi_iss[15];
      end

      `CA53_MULT_TYPE_64x64: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = 1'b0;
        b_hi_sign_iss = 1'b0;
      end

      `CA53_MULT_TYPE_64x64_LH: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = 1'b0;
        b_hi_sign_iss = b_hi_iss[15] & signed_ex1; // Need to use Ex1 signal as this is a subsequent cycle
      end

      `CA53_MULT_TYPE_64x64_HL: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = a_hi_iss[15] & signed_ex1; // Need to use Ex1 signal as this is a subsequent cycle
        b_hi_sign_iss = 1'b0;
      end

      `CA53_MULT_TYPE_64x64_HH: begin
        a_lo_sign_iss = 1'b0;
        b_lo_sign_iss = 1'b0;
        a_hi_sign_iss = a_hi_iss[15] & signed_ex1; // Need to use Ex1 signal as this is a subsequent cycle
        b_hi_sign_iss = b_hi_iss[15] & signed_ex1;
      end

      default: begin
        a_lo_sign_iss = 1'bx;
        b_lo_sign_iss = 1'bx;
        a_hi_sign_iss = 1'bx;
        b_hi_sign_iss = 1'bx;
      end
    endcase

  always @(posedge clk_mac)
    if (advance_mac_pipeline)
      valid_ex1 <= valid_iss;

  assign issue_mac_to_ex1 = mac_valid_iss_i & advance_mac_pipeline;
  assign step_mac_ex1     =       valid_iss & advance_mac_pipeline;

  always @(posedge clk_mac or negedge reset_n)
    if (~reset_n)
      mult_type_ex1    <= {4{1'b0}};
    else if (step_mac_ex1)
      mult_type_ex1    <= mult_type_iss;

  always @(posedge clk_mac)
    if (issue_mac_to_ex1) begin
      signed_ex1       <= signed_iss;
      neg_second_ex1   <= neg_second_iss;
      negate_mul_ex1   <= negate_mul_iss;
      acc_high_ex1     <= acc_high_iss;
      round_ex1        <= round_iss;
      accum_lo_ex1     <= accum_lo_iss;
      accum_hi_ex1     <= accum_hi_iss;
      slot1_mul_ex1    <= slot1_mul_iss_i;
    end

  always @(posedge clk_mac)
    if (step_mac_ex1) begin
      a_lo_ex1         <= a_lo_iss;
      a_hi_ex1         <= a_hi_iss;
      b_lo_ex1         <= b_lo_iss;
      b_hi_ex1         <= b_hi_iss;
      a_lo_sign_ex1    <= a_lo_sign_iss;
      a_hi_sign_ex1    <= a_hi_sign_iss;
      b_lo_sign_ex1    <= b_lo_sign_iss;
      b_hi_sign_ex1    <= b_hi_sign_iss;
    end

  assign en_other_ex1 = step_mac_ex1 & mac_stall_iss;

  always @(posedge clk_mac)
    if (en_other_ex1) begin
      a_other_ex1      <= a_other_iss;
      b_other_ex1      <= b_other_iss;
    end

  //---------------------------------------------------------------------------
  // Ex1 stage
  // Performs initial multiplies
  //---------------------------------------------------------------------------

  // Calculate if the high 32 bits of the operands was zero
  assign a_other_zero_ex1 = (a_other_ex1 == {32{1'b0}});
  assign b_other_zero_ex1 = (b_other_ex1 == {32{1'b0}});

  // To perform signed multiplication, sign-extend the inputs of some of
  // the multipliers. The outputs also require sign-extension, so some multipliers
  // generate an extra bit - this avoids the need to factor in whether the
  // instruction is signed or not when extending

  // Multipliers
  assign prod_a_lo_b_lo0_ex1 = { { 8{a_lo_sign_ex1}}, a_lo_ex1}       *                        b_lo_ex1[ 7:0];
  assign prod_a_lo_b_lo1_ex1 = { { 8{a_lo_sign_ex1}}, a_lo_ex1}       * { {16{b_lo_sign_ex1}}, b_lo_ex1[15:8]};
  assign prod_a_lo_b_hi0_ex1 =                        a_lo_ex1        *                        b_hi_ex1[ 7:0];
  assign prod_a_lo_b_hi1_ex1 =                        a_lo_ex1        * { {17{b_hi_sign_ex1}}, b_hi_ex1[15:8]};
  assign prod_a_hi0_b_lo_ex1 =                        a_hi_ex1[ 7:0]  *                        b_lo_ex1;
  assign prod_a_hi1_b_lo_ex1 = { {17{a_hi_sign_ex1}}, a_hi_ex1[15:8]} *                        b_lo_ex1;
  assign prod_a_hi_b_hi0_ex1 = { { 9{a_hi_sign_ex1}}, a_hi_ex1}       *                        b_hi_ex1[ 7:0];
  assign prod_a_hi_b_hi1_ex1 = { { 9{a_hi_sign_ex1}}, a_hi_ex1}       * { {17{b_hi_sign_ex1}}, b_hi_ex1[15:8]};

  // Calculate signs for dual 16x16 multiplies
  // These signals have a reasonable fanout as they are used for sign-extension,
  // so they are calculated in parallel to the multiplication rather than using
  // the sign out of the multipliers

  assign prod_a_lo_b_lo0_sign_ex1 =  a_lo_sign_ex1                                           & (b_lo_ex1[ 7:0] != 8'h00);
  assign prod_a_lo_b_lo1_sign_ex1 = (a_lo_sign_ex1 ^ b_lo_sign_ex1) & (a_lo_ex1 != 16'h0000) & (b_lo_ex1[15:8] != 8'h00);
  assign prod_a_hi_b_hi0_sign_ex1 =  a_hi_sign_ex1                                           & (b_hi_ex1[ 7:0] != 8'h00);
  assign prod_a_hi_b_hi1_sign_ex1 = (a_hi_sign_ex1 ^ b_hi_sign_ex1) & (a_hi_ex1 != 16'h0000) & (b_hi_ex1[15:8] != 8'h00);

  // Need sign of multiplied value for calculating overflow on 32x16 operations
  assign mult_sign_ex1 = a_hi_ex1[15] ^ b_hi_ex1[15];

  // Calculate sum of absolute differences
  function [7:0] adif;
  // returns an absolute difference of a and b i.e |a-b|
    input [7:0] a;
    input [7:0] b;
    reg   [8:0] dif;
    begin
      dif  = a - b;
      adif = ~dif[8] ? dif[7:0] : b - a;
    end
  endfunction

  assign adif_ex1 = adif(a_hi_ex1[15:8], b_hi_ex1[15:8]) +
                    adif(a_hi_ex1 [7:0], b_hi_ex1 [7:0]) +
                    adif(a_lo_ex1[15:8], b_lo_ex1[15:8]) +
                    adif(a_lo_ex1 [7:0], b_lo_ex1 [7:0]);

  // Generate the partial product terms for the accumulator in ex2

  always @* begin
    sel_lo_lo_ex1      = 1'b0;
    sel_hi_ex1         = 1'b0;
    sel_hi_hi_dual_ex1 = 1'b0;
    raw_sel_feed_ex1   = 1'b0;
    sel_usad_ex1       = 1'b0;
    sel_accu_right_ex1 = 1'b0;
    sel_mul_left_ex1   = 1'b0;

    case (mult_type_ex1)
      `CA53_MULT_TYPE_USAD:
        sel_usad_ex1       = 1'b1;

      `CA53_MULT_TYPE_ACCONLY: begin
        raw_sel_feed_ex1   = 1'b1;
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
      end

      `CA53_MULT_TYPE_32x32,
      `CA53_MULT_TYPE_32x16,
      `CA53_MULT_TYPE_16x16: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
      end

      `CA53_MULT_TYPE_2x16x16: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_hi_dual_ex1 = 1'b1;
      end

      `CA53_MULT_TYPE_64x64: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
      end

      `CA53_MULT_TYPE_64x64_LH: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
        raw_sel_feed_ex1   = 1'b1;
        sel_mul_left_ex1   = ~acc_high_ex1;
        sel_accu_right_ex1 = 1'b1;
      end

      `CA53_MULT_TYPE_64x64_HL: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
        raw_sel_feed_ex1   = 1'b1;
        sel_mul_left_ex1   = ~acc_high_ex1;
        sel_accu_right_ex1 = ~acc_high_ex1;
      end

      `CA53_MULT_TYPE_64x64_HH: begin
        sel_lo_lo_ex1      = 1'b1;
        sel_hi_ex1         = 1'b1;
        raw_sel_feed_ex1   = 1'b1;
        sel_accu_right_ex1 = 1'b1;
      end

      default: begin
        sel_lo_lo_ex1      = 1'bx;
        sel_hi_ex1         = 1'bx;
        sel_hi_hi_dual_ex1 = 1'bx;
        raw_sel_feed_ex1   = 1'bx;
        sel_usad_ex1       = 1'bx;
        sel_accu_right_ex1 = 1'bx;
        sel_mul_left_ex1   = 1'bx;
      end
    endcase
  end

  assign partial_1_ex1[23:0]     = ({24{sel_lo_lo_ex1}}      & prod_a_lo_b_lo0_ex1) |
                                   ({24{sel_usad_ex1}}       & {14'h0000, adif_ex1});

  assign partial_1_ex1[48:24]    = ({25{sel_hi_ex1}}         & prod_a_hi1_b_lo_ex1) |
                                   ({25{sel_lo_lo_ex1}}      & {25{prod_a_lo_b_lo0_sign_ex1}});

  assign partial_2_ex1[31:8]     = ({24{sel_lo_lo_ex1}}      & prod_a_lo_b_lo1_ex1);

  assign partial_2_ex1[56:32]    = ({25{sel_hi_ex1}}         & prod_a_hi_b_hi0_ex1) |
                                   ({25{sel_lo_lo_ex1}}      & {25{prod_a_lo_b_lo1_sign_ex1}});

  assign partial_3_ex1[64:40]    = ({25{sel_hi_ex1}}         & prod_a_hi_b_hi1_ex1) |
                                   ({25{sel_hi_hi_dual_ex1}} & {25{prod_a_hi_b_hi0_sign_ex1 ^ neg_second_ex1}});

  assign partial_3_ex1[39:0]     = ({40{sel_hi_ex1}}         & {prod_a_lo_b_hi0_ex1, 16'h0000}) |
                                   ({40{sel_hi_hi_dual_ex1}} & ({ {16{prod_a_hi_b_hi0_sign_ex1}},
                                                                prod_a_hi_b_hi0_ex1[23:0]} ^ {40{neg_second_ex1}}));

  assign partial_4_ex1[48:8]     = ({41{sel_hi_ex1}}         & {prod_a_lo_b_hi1_ex1, 16'h0000}) |
                                   ({41{sel_hi_hi_dual_ex1}} & ({ {16{prod_a_hi_b_hi1_sign_ex1}},
                                                                 prod_a_hi_b_hi1_ex1} ^ {41{neg_second_ex1}}));

  assign partial_5_hi_ex1[39:16] = ({24{sel_hi_ex1}}         & prod_a_hi0_b_lo_ex1);

  assign raw_sel_acc0_lo_ex1 = valid_ex1 & accum_lo_ex1 & ~slot1_mul_ex1;
  assign raw_sel_acc1_lo_ex1 = valid_ex1 & accum_lo_ex1 &  slot1_mul_ex1;

  assign raw_sel_acc0_hi_ex1 = valid_ex1 & accum_hi_ex1 & ~slot1_mul_ex1;
  assign raw_sel_acc1_hi_ex1 = valid_ex1 & accum_hi_ex1 &  slot1_mul_ex1;

  assign sel_feed_lo_ex1 = raw_sel_feed_ex1 |
                           (raw_sel_acc0_lo_ex1 & mac_fwd_ctl_ex1_i[0]) |
                           (raw_sel_acc1_lo_ex1 & mac_fwd_ctl_ex1_i[1]);
  assign sel_feed_hi_ex1 = raw_sel_feed_ex1 |
                           (raw_sel_acc0_hi_ex1 & mac_fwd_ctl_ex1_i[4]) |
                           (raw_sel_acc1_hi_ex1 & mac_fwd_ctl_ex1_i[5]);

  assign sel_acc0_lo_ex1 = raw_sel_acc0_lo_ex1 & ~raw_sel_feed_ex1 & ~mac_fwd_ctl_ex1_i[0];
  assign sel_acc1_lo_ex1 = raw_sel_acc1_lo_ex1 & ~raw_sel_feed_ex1 & ~mac_fwd_ctl_ex1_i[1];

  assign sel_acc0_hi_ex1 = raw_sel_acc0_hi_ex1 & ~raw_sel_feed_ex1 & ~mac_fwd_ctl_ex1_i[2];
  assign sel_acc1_hi_ex1 = raw_sel_acc1_hi_ex1 & ~raw_sel_feed_ex1 & ~mac_fwd_ctl_ex1_i[3];


  // Ex2 pipeline registers

  always @(posedge clk_mac)
    if (advance_mac_pipeline)
      valid_ex2 <= valid_ex1;

  assign issue_mac_to_ex2 = valid_ex1 & advance_mac_pipeline;

  always @(posedge clk_mac)
    if (issue_mac_to_ex2) begin
      signed_ex2         <= signed_ex1;
      neg_second_ex2     <= neg_second_ex1;
      negate_mul_ex2     <= negate_mul_ex1;
      acc_high_ex2       <= acc_high_ex1;
      round_ex2          <= round_ex1;
      mult_sign_ex2      <= mult_sign_ex1;
      sel_feed_lo_ex2    <= sel_feed_lo_ex1;
      sel_feed_hi_ex2    <= sel_feed_hi_ex1;
      sel_accu_right_ex2 <= sel_accu_right_ex1;
      sel_mul_left_ex2   <= sel_mul_left_ex1;
      partial_1_ex2      <= partial_1_ex1;
      partial_2_ex2      <= partial_2_ex1;
      partial_3_ex2      <= partial_3_ex1;
      partial_4_ex2      <= partial_4_ex1;
      partial_5_hi_ex2   <= partial_5_hi_ex1;
    end

  // Drive the sel_acc signals back to zero to prevent toggling in the multiplier
  // when the store pipe outputs change
  assign en_acc_sel_ex2 = issue_mac_to_ex2 |
                          (sel_acc0_lo_ex2 | sel_acc1_lo_ex2 | sel_acc0_hi_ex2 | sel_acc1_hi_ex2) & advance_mac_pipeline;

  always @(posedge clk_mac or negedge reset_n)
    if (~reset_n) begin
      sel_acc0_lo_ex2    <= 1'b0;
      sel_acc1_lo_ex2    <= 1'b0;
      sel_acc0_hi_ex2    <= 1'b0;
      sel_acc1_hi_ex2    <= 1'b0;
    end else if (en_acc_sel_ex2) begin
      sel_acc0_lo_ex2    <= sel_acc0_lo_ex1;
      sel_acc1_lo_ex2    <= sel_acc1_lo_ex1;
      sel_acc0_hi_ex2    <= sel_acc0_hi_ex1;
      sel_acc1_hi_ex2    <= sel_acc1_hi_ex1;
    end

  //---------------------------------------------------------------------------
  // Ex2 stage
  // Arranges bits and adds everything together
  // Extend the accumulator by 2 bits to allow for word growth for 64bit multiplies
  //---------------------------------------------------------------------------

  // Allow a MAC following a MUL/MAC to forward the accumulator value Wr->Ex2
  assign accum_val[31: 0] = ({32{sel_feed_lo_ex2}} & accum_res_wr[31: 0]) |
                            ({32{sel_acc0_lo_ex2}} & st0_data_ex2_i[31: 0]) |
                            ({32{sel_acc1_lo_ex2}} & st1_data_ex2_i[31: 0]);

  assign accum_val[65:32] = ({34{sel_feed_hi_ex2}} &         accum_res_wr[65:32])  |
                            ({34{sel_acc0_hi_ex2}} & {2'b00, st0_data_ex2_i[63:32]}) |
                            ({34{sel_acc1_hi_ex2}} & {2'b00, st1_data_ex2_i[63:32]});

  // Generate the inputs to the big adder
  assign partial_5_ex2 = {partial_5_hi_ex2, {7{1'b0}}, neg_second_ex2, {7{1'b0}}, neg_second_ex2};

  assign partial_7_ex2 = (sel_accu_right_ex2 ? { {32{signed_ex2 & accum_val[65]}}, accum_val[65:32]}
                                             : (accum_val[65:0] | { {34{1'b0}}, round_ex2, {31{1'b0}} })) ^ {66{negate_mul_ex2}};

  // Add together the partial products. Some require sign-extension
  assign mult_res = { {18{partial_1_ex2[48]}}, partial_1_ex2[47:0]}            +
                    { {10{partial_2_ex2[56]}}, partial_2_ex2[55:8], 8'h00}     +
                    { { 2{partial_3_ex2[64]}}, partial_3_ex2[63:0]}            +
                    { {18{partial_4_ex2[48]}}, partial_4_ex2[47:8], 8'h00}     +
                                               partial_5_ex2[39:0];

  assign raw_accum_res_ex2 = partial_7_ex2 + mult_res;

  assign accum_res_ex2[31: 0] = sel_mul_left_ex2    ? accum_val[31: 0]                              :
                                                      (raw_accum_res_ex2[31: 0] ^ {32{negate_mul_ex2}});

  assign accum_res_ex2[65:32] = sel_mul_left_ex2    ? (raw_accum_res_ex2[33: 0] ^ {34{negate_mul_ex2}}) :
                                                      (raw_accum_res_ex2[65:32] ^ {34{negate_mul_ex2}});

  assign acc_sign_ex2 = acc_high_ex2 ? accum_val[63] : accum_val[31];

  // Wr stage pipeline registers
  assign issue_mac_to_wr = valid_ex2 & advance_mac_pipeline;

  always @(posedge clk_mac)
    if (issue_mac_to_wr) begin
      acc_high_wr  <= acc_high_ex2;
      accum_res_wr <= accum_res_ex2;
      acc_sign_wr  <= acc_sign_ex2;
      mult_sign_wr <= mult_sign_ex2;
    end

  //---------------------------------------------------------------------------
  // Wr stage
  // Calculate final flag values
  //---------------------------------------------------------------------------

  assign mac_res_lo_wr_o = accum_res_wr[31:0];
  assign mac_res_hi_wr_o = accum_res_wr[63:32];

  // N,Z,Q bits generation

  assign mac_z_lo = accum_res_wr[31:0] == 32'h00000000;
  assign mac_z_hi = (accum_res_wr[63:32] == 32'h00000000) & mac_z_lo;

  assign mac_q_lo = (accum_res_wr[32] ^ acc_sign_wr) != accum_res_wr[31];
  assign mac_q_hi = (mult_sign_wr == acc_sign_wr) && (mult_sign_wr != accum_res_wr[63]);

  assign mac_q_wr_o = acc_high_wr ? mac_q_hi         : mac_q_lo;
  assign mac_n_wr_o = acc_high_wr ? accum_res_wr[63] : accum_res_wr[31];
  assign mac_z_wr_o = acc_high_wr ? mac_z_hi         : mac_z_lo;


  assign mac_stall_iss_o = mac_stall_iss;

  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_acc_sel_ex2")
  u_ovl_x_en_acc_sel_ex2 (.clk       (clk_mac),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_acc_sel_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_other_ex1")
  u_ovl_x_en_other_ex1 (.clk       (clk_mac),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_other_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: step_mac_ex1")
  u_ovl_x_step_mac_ex1 (.clk       (clk_mac),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (step_mac_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_mac_pipeline")
  u_ovl_x_advance_mac_pipeline (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (advance_mac_pipeline));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_mac_to_ex1")
  u_ovl_x_issue_mac_to_ex1 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (issue_mac_to_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_mac_to_ex2")
  u_ovl_x_issue_mac_to_ex2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (issue_mac_to_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_mac_to_wr")
  u_ovl_x_issue_mac_to_wr (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (issue_mac_to_wr));


  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_dpu_mac_invalid_mult_type
  // Check the mult_type field is valid
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Invalid mult_type specified")
    ovl_dpu_mac_invalid_mult_type (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((raw_mult_type_iss == `CA53_MULT_TYPE_ACCONLY)  |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_USAD)     |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_32x32)    |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_32x16)    |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_16x16)    |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_2x16x16)  |
                                               (raw_mult_type_iss == `CA53_MULT_TYPE_64x64)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_mult_typ_iss_illegal
  // Check the mult_type field is valid in Ex1
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"mult_type_ex1 has an illegal value when it is valid")
    ovl_mult_typ_iss_illegal(.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (valid_ex1),
                             .consequent_expr ((mult_type_ex1 == `CA53_MULT_TYPE_ACCONLY)  |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_USAD)     |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_32x32)    |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_32x16)    |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_16x16)    |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_2x16x16)  |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_64x64)    |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_64x64_LH) |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_64x64_HL) |
                                               (mult_type_ex1 == `CA53_MULT_TYPE_64x64_HH)));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_mac

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
