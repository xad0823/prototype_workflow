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
// Abstract : Store data pipeline.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This is a simple, 64-bit wide data pipeline, used to pipeline the store
// data to the wr-stage, where it is passed to the STB or DCU.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_store #(parameter IS_PIPE0 = 1'b1, NEON_FP = 1'b0) (
  // Inputs
  input  wire                        clk,
  input  wire                        reset_n,
  input  wire                        DFTSE,
  input  wire                        stall_wr_i,
  input  wire                        ctl_64bit_op_store_iss_i,
  input  wire                 [31:0] st_data_a_iss_i,
  input  wire                 [31:0] st_data_b_iss_i,
  input  wire                        str_valid_de_i,
  input  wire                        raw_str_valid_iss_i,
  input  wire                        str_a_valid_iss_i,
  input  wire                        str_b_valid_iss_i,
  input  wire                 [63:0] alu0_fwd_data_ex2_i,
  input  wire                 [63:0] rf_wr_data_w0_wr_i,
  input  wire                 [63:0] rf_wr_data_w1_wr_i,
  input  wire                 [63:0] rf_wr_data_w2_wr_i,
  input  wire                 [63:0] fp_str_data_f1_i,
  input  wire                 [63:0] fp_str_data_f2_i,
  input  wire      [`CA53_FWD_W-1:0] str_a_fwd_ex1_i,
  input  wire      [`CA53_FWD_W-1:0] str_b_fwd_ex1_i,
  input  wire      [`CA53_FWD_W-1:0] str_a_fwd_ex2_i,
  input  wire      [`CA53_FWD_W-1:0] str_b_fwd_ex2_i,
  // Outputs      
  output wire                 [63:0] st_data_ex1_o,
  output wire                 [63:0] st_data_ex2_o,
  output wire                 [63:0] st_data_wr_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         str_a_en;
  reg         str_b_en;
  reg  [31:0] st_a_data_ex1;
  reg  [31:0] st_b_data_ex1;
  reg  [31:0] st_a_data_fwd_ex1;
  reg  [31:0] st_b_data_fwd_ex1;
  reg  [31:0] st_a_data_ex2;
  reg  [31:0] st_b_data_ex2;
  reg  [31:0] st_a_data_fwd_ex2;
  reg  [31:0] st_b_data_fwd_ex2;
  reg  [63:0] st_data_wr;
  reg         str_a_valid_ex1;
  reg         str_b_valid_ex1;
  reg         str_a_valid_ex2;
  reg         str_b_valid_ex2;
  reg         ctl_64bit_op_store_ex1;
  reg         ctl_64bit_op_store_ex2;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        en_st_a_data_ex2;
  wire        en_st_b_data_ex2;
  wire        en_st_a_data_wr;
  wire        en_st_b_data_wr;
  wire        en_valid;
  wire        nxt_str_a_en;
  wire        nxt_str_b_en;
  wire        clk_str_a;
  wire        clk_str_b;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gates
  // ------------------------------------------------------

  assign nxt_str_a_en = str_valid_de_i | raw_str_valid_iss_i | str_a_valid_ex1 | str_a_valid_ex2;
  assign nxt_str_b_en = str_valid_de_i | raw_str_valid_iss_i | str_b_valid_ex1 | str_b_valid_ex2;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      str_a_en <= 1'b1;
      str_b_en <= 1'b1;
    end
    else begin
      str_a_en <= nxt_str_a_en;
      str_b_en <= nxt_str_b_en;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_str_a (
    .clk_i         (clk),
    .clk_enable_i  (str_a_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_str_a)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_str_b (
    .clk_i         (clk),
    .clk_enable_i  (str_b_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_str_b)
  );

  // ------------------------------------------------------
  // Pipeline registers for the valid signals
  // ------------------------------------------------------

  assign en_valid = ~stall_wr_i;

  always @(posedge clk_str_a or negedge reset_n)
    if (~reset_n) begin
      str_a_valid_ex1         <= 1'b0;
      str_a_valid_ex2         <= 1'b0;
      ctl_64bit_op_store_ex1  <= 1'b0;
      ctl_64bit_op_store_ex2  <= 1'b0;
    end else if (en_valid) begin
      str_a_valid_ex1         <= str_a_valid_iss_i;
      str_a_valid_ex2         <= str_a_valid_ex1;
      ctl_64bit_op_store_ex1  <= ctl_64bit_op_store_iss_i;
      ctl_64bit_op_store_ex2  <= ctl_64bit_op_store_ex1;
    end

  always @(posedge clk_str_b or negedge reset_n)
    if (~reset_n) begin
      str_b_valid_ex1         <= 1'b0;
      str_b_valid_ex2         <= 1'b0;
    end else if (en_valid) begin
      str_b_valid_ex1         <= str_b_valid_iss_i;
      str_b_valid_ex2         <= str_b_valid_ex1;
    end

  // ------------------------------------------------------
  // Ex1 Stage registers
  // ------------------------------------------------------

  always @(posedge clk_str_a)
    if (str_a_valid_iss_i)
      st_a_data_ex1[31:0] <= st_data_a_iss_i[31:0];

  always @(posedge clk_str_b)
    if (str_b_valid_iss_i)
      st_b_data_ex1[31:0] <= st_data_b_iss_i[31:0];

  always @*
    case (str_a_fwd_ex1_i)
      `CA53_FWD_FP    : st_a_data_fwd_ex1 = NEON_FP  ? fp_str_data_f1_i[31:0]     : {32{1'bx}};
      `CA53_FWD_W0    : st_a_data_fwd_ex1 = rf_wr_data_w0_wr_i[31:0];
      `CA53_FWD_W1    : st_a_data_fwd_ex1 = rf_wr_data_w1_wr_i[31:0];
      `CA53_FWD_W2    : st_a_data_fwd_ex1 = rf_wr_data_w2_wr_i[31:0];
      `CA53_FWD_NULL  : st_a_data_fwd_ex1 = st_a_data_ex1[31:0];
      default         : st_a_data_fwd_ex1 = {32{1'bx}};
    endcase

  always @*
    case (ctl_64bit_op_store_ex1)
      1'b0: case (str_b_fwd_ex1_i)
              `CA53_FWD_FP    : st_b_data_fwd_ex1 = NEON_FP  ? fp_str_data_f1_i[63:32] : {32{1'bx}};
              `CA53_FWD_W0    : st_b_data_fwd_ex1 = rf_wr_data_w0_wr_i[31:0];
              `CA53_FWD_W1    : st_b_data_fwd_ex1 = rf_wr_data_w1_wr_i[31:0];
              `CA53_FWD_W2    : st_b_data_fwd_ex1 = rf_wr_data_w2_wr_i[31:0];
              `CA53_FWD_NULL  : st_b_data_fwd_ex1 = st_b_data_ex1[31:0];
              default         : st_b_data_fwd_ex1 = {32{1'bx}};
            endcase
      1'b1: case (str_a_fwd_ex1_i)
              `CA53_FWD_FP    : st_b_data_fwd_ex1 = NEON_FP ? fp_str_data_f1_i[63:32] : {32{1'bx}};
              `CA53_FWD_W0    : st_b_data_fwd_ex1 = rf_wr_data_w0_wr_i[63:32];
              `CA53_FWD_W1    : st_b_data_fwd_ex1 = rf_wr_data_w1_wr_i[63:32];
              `CA53_FWD_W2    : st_b_data_fwd_ex1 = rf_wr_data_w2_wr_i[63:32];
              `CA53_FWD_NULL  : st_b_data_fwd_ex1 = st_b_data_ex1[31:0];
              default         : st_b_data_fwd_ex1 = {32{1'bx}};
            endcase
      default: st_b_data_fwd_ex1 = {32{1'bx}};
    endcase

  // ------------------------------------------------------
  // Ex2 Stage registers
  // ------------------------------------------------------

  assign en_st_a_data_ex2 = str_a_valid_ex1 & ~stall_wr_i;
  assign en_st_b_data_ex2 = str_b_valid_ex1 & ~stall_wr_i;

  always @(posedge clk_str_a)
    if (en_st_a_data_ex2)
      st_a_data_ex2[31:0] <= st_a_data_fwd_ex1[31:0];

  always @(posedge clk_str_b)
    if (en_st_b_data_ex2)
      st_b_data_ex2[31:0] <= st_b_data_fwd_ex1[31:0];

  // ------------------------------------------------------
  // Ex2 Stage forwarding
  // ------------------------------------------------------

  always @*
    case (str_a_fwd_ex2_i)
      `CA53_FWD_FP,
      `CA53_FWD_FP_LO    : st_a_data_fwd_ex2 = NEON_FP ? fp_str_data_f2_i[31:0] : {32{1'bx}};
      `CA53_FWD_FP_HI    : st_a_data_fwd_ex2 = NEON_FP ? st_a_data_ex2[31:0]    : {32{1'bx}};
      `CA53_FWD_ALU0_EX2 : st_a_data_fwd_ex2 = alu0_fwd_data_ex2_i[31:0];
      `CA53_FWD_W0       : st_a_data_fwd_ex2 = rf_wr_data_w0_wr_i[31:0];
      `CA53_FWD_W1       : st_a_data_fwd_ex2 = rf_wr_data_w1_wr_i[31:0];
      `CA53_FWD_W2       : st_a_data_fwd_ex2 = rf_wr_data_w2_wr_i[31:0];
      `CA53_FWD_NULL     : st_a_data_fwd_ex2 = st_a_data_ex2[31:0];
      default            : st_a_data_fwd_ex2 = {32{1'bx}};
    endcase

  always @*
    case (ctl_64bit_op_store_ex2)
      1'b0: case (str_b_fwd_ex2_i)
              `CA53_FWD_FP       : st_b_data_fwd_ex2 = NEON_FP     ? fp_str_data_f2_i[63:32]   : {32{1'bx}};
              `CA53_FWD_ALU0_EX2 : st_b_data_fwd_ex2 = (!IS_PIPE0) ? alu0_fwd_data_ex2_i[31:0] : {32{1'bx}};
              `CA53_FWD_W0       : st_b_data_fwd_ex2 = rf_wr_data_w0_wr_i[31:0];
              `CA53_FWD_W1       : st_b_data_fwd_ex2 = rf_wr_data_w1_wr_i[31:0];
              `CA53_FWD_W2       : st_b_data_fwd_ex2 = rf_wr_data_w2_wr_i[31:0];
              `CA53_FWD_NULL     : st_b_data_fwd_ex2 = st_b_data_ex2[31:0];
              default            : st_b_data_fwd_ex2 = {32{1'bx}};
            endcase
      1'b1: case (str_a_fwd_ex2_i)
              `CA53_FWD_FP,
              `CA53_FWD_FP_HI    : st_b_data_fwd_ex2 = NEON_FP     ? fp_str_data_f2_i[63:32] : {32{1'bx}};
              `CA53_FWD_FP_LO    : st_b_data_fwd_ex2 = NEON_FP     ? st_b_data_ex2[31:0]     : {32{1'bx}};
              `CA53_FWD_ALU0_EX2 : st_b_data_fwd_ex2 = alu0_fwd_data_ex2_i[63:32];
              `CA53_FWD_W0       : st_b_data_fwd_ex2 = rf_wr_data_w0_wr_i[63:32];
              `CA53_FWD_W1       : st_b_data_fwd_ex2 = rf_wr_data_w1_wr_i[63:32];
              `CA53_FWD_W2       : st_b_data_fwd_ex2 = rf_wr_data_w2_wr_i[63:32];
              `CA53_FWD_NULL     : st_b_data_fwd_ex2 = st_b_data_ex2[31:0];
              default            : st_b_data_fwd_ex2 = {32{1'bx}};
            endcase
      default: st_b_data_fwd_ex2 = {32{1'bx}};
    endcase

  // ------------------------------------------------------
  // Wr Stage registers
  // ------------------------------------------------------

  assign en_st_a_data_wr = str_a_valid_ex2 & ~stall_wr_i;
  assign en_st_b_data_wr = str_b_valid_ex2 & ~stall_wr_i;

  // Data registers are not reset
  always @(posedge clk_str_a)
    if (en_st_a_data_wr)
      st_data_wr[31:0]   <= st_a_data_fwd_ex2[31:0];

  always @(posedge clk_str_b)
    if (en_st_b_data_wr)
      st_data_wr[63:32] <= st_b_data_fwd_ex2[31:0];

  // ------------------------------------------------------
  // Output port aliasing
  // ------------------------------------------------------

  assign st_data_ex1_o            = {st_b_data_ex1, st_a_data_ex1};
  assign st_data_ex2_o            = {st_b_data_ex2, st_a_data_ex2};
  assign st_data_wr_o             = st_data_wr;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_st_a_data_ex2")
  u_ovl_x_en_st_a_data_ex2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_st_a_data_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_st_a_data_wr")
  u_ovl_x_en_st_a_data_wr (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_st_a_data_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_st_b_data_ex2")
  u_ovl_x_en_st_b_data_ex2 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_st_b_data_ex2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_st_b_data_wr")
  u_ovl_x_en_st_b_data_wr (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_st_b_data_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_valid")
  u_ovl_x_en_valid (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (en_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: str_a_valid_iss_i")
  u_ovl_x_str_a_valid_iss_i (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (str_a_valid_iss_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: str_b_valid_iss_i")
  u_ovl_x_str_b_valid_iss_i (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (str_b_valid_iss_i));


`endif

endmodule // ca53dpu_store

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
