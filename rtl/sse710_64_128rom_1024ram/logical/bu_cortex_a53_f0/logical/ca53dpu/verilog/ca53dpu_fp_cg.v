//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-24 20:28:54 +0100 (Tue, 24 Jul 2012) $
//
//      Revision            : $Revision: 216242 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Floating point datapath clock gating
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module instantiates the clock gates for the Neon/FP clocks.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_cg `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                           clk,
  input  wire                           reset_n,
  input  wire                           DFTSE,
  input  wire                           stall_wr_i,
  input  wire                           ctl_fp_dp_en_i,
  input  wire                           fp_dp_active_i,
  input  wire                     [1:0] fp_alu_en_i,
  input  wire                     [1:0] fp_mul_en_i,
  input  wire                           rf_wr_en_fw_f5_i,
  input  wire  [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_iss_i,
  input  wire  [`CA53_FP_EX_PIPE_W-1:0] fp_ex_pipe_f1_i,
  input  wire                           crypto_enable_iss_i,
  input  wire                           crypto_enable_f1_i,
  input  wire                           crypto_active_i,
  input  wire                     [1:0] fp_div_active_i,
  input  wire                     [1:0] fp_div_enb_f1_i,
  // Outputs
  output wire                           clk_fp,
  output wire                           clk_fp_alu0,
  output wire                           clk_fp_alu1,
  output wire                           clk_fp_mul0,
  output wire                           clk_fp_mul1,
  output wire                           clk_crypto,
  output wire                           clk_fp_nrf
);

  reg         fp_dp_en;
  reg   [1:0] fp_alu_en;
  reg   [1:0] fp_mul_en;

  wire  [1:0] add_enable_iss;
  wire  [1:0] add_enable_f1;
  wire  [1:0] mul_enable_iss;
  wire  [1:0] mul_enable_f1;
  wire        nxt_fp_dp_en;
  wire  [1:0] nxt_fp_alu_en;
  wire  [1:0] nxt_fp_mul_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Hold the clock enables high if stall_wr is asserted
  assign nxt_fp_dp_en   = ctl_fp_dp_en_i | fp_dp_active_i | (fp_dp_en & stall_wr_i);

  assign add_enable_iss = {fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_ADD1], fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_ADD0]};
  assign add_enable_f1  = {fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_ADD1],  fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_ADD0]};
  assign nxt_fp_alu_en  = add_enable_iss | add_enable_f1 | fp_alu_en_i | (fp_alu_en & {2{stall_wr_i}});

  assign mul_enable_iss = {fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_MUL1], fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_MUL0]};
  assign mul_enable_f1  = {fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_MUL1],  fp_ex_pipe_f1_i[`CA53_FP_EX_PIPE_MUL0]};
  assign nxt_fp_mul_en  = mul_enable_iss | mul_enable_f1 | fp_mul_en_i | (fp_mul_en & {2{stall_wr_i}}) | fp_div_active_i | fp_div_enb_f1_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      fp_dp_en  <= 1'b1;
      fp_alu_en <= 2'b11;
      fp_mul_en <= 2'b11;
    end else begin
      fp_dp_en  <= nxt_fp_dp_en;
      fp_alu_en <= nxt_fp_alu_en;
      fp_mul_en <= nxt_fp_mul_en;
    end

  // Clock gate for the registers not covered by those below
  ca53_cell_inter_clkgate u_inter_clkgate_fp (
    .clk_i         (clk),
    .clk_enable_i  (fp_dp_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp)
  );

  // All registers in the fp_alu and fp_mul can be architecturally gated using
  // an intermediate clock gate
  ca53_cell_inter_clkgate u_inter_clkgate_fp_alu0 (
    .clk_i         (clk),
    .clk_enable_i  (fp_alu_en[0]),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_alu0)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_fp_alu1 (
    .clk_i         (clk),
    .clk_enable_i  (fp_alu_en[1]),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_alu1)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_fp_mul0 (
    .clk_i         (clk),
    .clk_enable_i  (fp_mul_en[0]),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_mul0)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_fp_mul1 (
    .clk_i         (clk),
    .clk_enable_i  (fp_mul_en[1]),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_mul1)
  );

  generate if (CRYPTO) begin : g_crypto_cg
    reg  crypto_en;
    wire nxt_crypto_en;

    assign nxt_crypto_en = crypto_enable_iss_i | crypto_enable_f1_i | crypto_active_i | (crypto_en & stall_wr_i);

    always @(posedge clk or negedge reset_n)
      if (~reset_n)
        crypto_en <= 1'b1;
      else
        crypto_en <= nxt_crypto_en;

    ca53_cell_inter_clkgate u_inter_clkgate_crypto (
      .clk_i         (clk),
      .clk_enable_i  (crypto_en),
      .clk_senable_i (DFTSE),
      .clk_gated_o   (clk_crypto)
    );
  end else begin : g_crypto_cg_stubs
    assign clk_crypto = 1'b0;
  end endgenerate

  // All registers in the register bank can be architecturally gated using
  // an intermediate clock gate
  ca53_cell_inter_clkgate u_inter_clkgate_fp_nrf (
    .clk_i         (clk),
    .clk_enable_i  (rf_wr_en_fw_f5_i),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_fp_nrf)
  );

endmodule // ca53dpu_fp_dp

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
