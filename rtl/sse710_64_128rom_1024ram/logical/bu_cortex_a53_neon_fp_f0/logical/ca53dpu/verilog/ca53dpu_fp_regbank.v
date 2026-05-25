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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Register Bank for the Floating Point Unit.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block contains the main working register set for the FPU.
//
// The FPU register file is a 3 read port, 2 write port register file.  There
// are 32 entries in the register file and each entry is 64 bits wide.
// In single precision mode in AArch32 odd/even adjacent registers are taken
// from the low/high halves of the registers (e.g. D0 = {S1,S0} etc).
// There are two 64-bit write ports, but in AArch64 each port can zero any
// upper bits in a 128-bit register not otherwise written
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_regbank (
  // Inputs
  input  wire                             clk_fp,
  input  wire                             clk_fp_nrf,
  input  wire                             reset_n,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_iss_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_iss_i,
  input  wire                             issue_to_ex1_i,
  input  wire                       [1:0] rf_rd_en_fr0_iss_i,
  input  wire                       [1:0] rf_rd_en_fr1_iss_i,
  input  wire                       [1:0] rf_rd_en_fr2_iss_i,
  input  wire                       [1:0] rf_rd_en_fr3_iss_i,
  input  wire                       [1:0] rf_rd_en_fr4_iss_i,
  input  wire                       [1:0] rf_rd_en_fr5_iss_i,
  input  wire                       [3:0] rf_wr_en_fw0_f5_i,
  input  wire                       [3:0] rf_wr_en_fw1_f5_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f5_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f5_i,
  input  wire                      [63:0] rf_wr_data_fw0_f5_i,
  input  wire                      [63:0] rf_wr_data_fw1_f5_i,
  // Outputs
  output wire                      [63:0] rf_rd_data_fr0_ex1_o,
  output wire                      [63:0] rf_rd_data_fr1_ex1_o,
  output wire                      [63:0] rf_rd_data_fr2_ex1_o,
  output wire                      [63:0] rf_rd_data_fr3_ex1_o,
  output wire                      [63:0] rf_rd_data_fr4_ex1_o,
  output wire                      [63:0] rf_rd_data_fr5_ex1_o
);

  // -----------------------------
  // Genvar declaration
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [63:0] rbank [63:0];
  reg  [63:0] long_rf_rd_addr_fr0_f1;
  reg  [63:0] long_rf_rd_addr_fr1_f1;
  reg  [63:0] long_rf_rd_addr_fr2_f1;
  reg  [63:0] long_rf_rd_addr_fr3_f1;
  reg  [63:0] long_rf_rd_addr_fr4_f1;
  reg  [63:0] long_rf_rd_addr_fr5_f1;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] long_rf_rd_addr_fr0_iss;
  wire [63:0] long_rf_rd_addr_fr1_iss;
  wire [63:0] long_rf_rd_addr_fr2_iss;
  wire [63:0] long_rf_rd_addr_fr3_iss;
  wire [63:0] long_rf_rd_addr_fr4_iss;
  wire [63:0] long_rf_rd_addr_fr5_iss;
  wire [63:0] regbank_en_lo;
  wire [63:0] regbank_en_hi;
  wire [63:0] wdata [63:0];
  wire [63:0] wrmask_fw0;
  wire [63:0] wrmask_fw1;
  wire [63:0] wrmask_fw0_lo_qual;
  wire [63:0] wrmask_fw0_hi_qual;
  wire [63:0] wrmask_fw1_lo_qual;
  wire [63:0] wrmask_fw1_hi_qual;
  wire [63:0] zero_upper;
  wire        long_rf_rd_addr_fr0_f1_en;
  wire        long_rf_rd_addr_fr1_f1_en;
  wire        long_rf_rd_addr_fr2_f1_en;
  wire        long_rf_rd_addr_fr3_f1_en;
  wire        long_rf_rd_addr_fr4_f1_en;
  wire        long_rf_rd_addr_fr5_f1_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // -----------------------------------------------------------
  // Register file
  // -----------------------------------------------------------
  // 64 entries, 64 bits per entry

  generate for (i = 0; i < 64; i = i + 1) begin : g_reg

    // Write enable generation
    assign wrmask_fw0[i] = (rf_wr_addr_fw0_f5_i == i[`CA53_FP_RF_WR_ADDR_W-1:0]);
    assign wrmask_fw1[i] = (rf_wr_addr_fw1_f5_i == i[`CA53_FP_RF_WR_ADDR_W-1:0]);

    if (i[0]) begin : g_odd
      reg entry_lo_is_zero;
      reg entry_hi_is_zero;

      assign zero_upper[i] = (wrmask_fw0[i-1] & rf_wr_en_fw0_f5_i[3]) |
                             (wrmask_fw1[i-1] & rf_wr_en_fw1_f5_i[3]);

      assign wrmask_fw0_lo_qual[i] = (wrmask_fw0[i] & rf_wr_en_fw0_f5_i[0]) | (wrmask_fw0[i-1] & rf_wr_en_fw0_f5_i[2]);
      assign wrmask_fw0_hi_qual[i] = (wrmask_fw0[i] & rf_wr_en_fw0_f5_i[1]) | (wrmask_fw0[i-1] & rf_wr_en_fw0_f5_i[2]);
      assign wrmask_fw1_lo_qual[i] = (wrmask_fw1[i] & rf_wr_en_fw1_f5_i[0]) | (wrmask_fw1[i-1] & rf_wr_en_fw1_f5_i[2]);
      assign wrmask_fw1_hi_qual[i] = (wrmask_fw1[i] & rf_wr_en_fw1_f5_i[1]) | (wrmask_fw1[i-1] & rf_wr_en_fw1_f5_i[2]);

      assign regbank_en_lo[i] = wrmask_fw0_lo_qual[i] | wrmask_fw1_lo_qual[i] | (zero_upper[i] & ~entry_lo_is_zero);
      assign regbank_en_hi[i] = wrmask_fw0_hi_qual[i] | wrmask_fw1_hi_qual[i] | (zero_upper[i] & ~entry_hi_is_zero);

      always @(posedge clk_fp_nrf or negedge reset_n)
        if (~reset_n)
          entry_lo_is_zero <= 1'b0;
        else if (regbank_en_lo[i])
          entry_lo_is_zero <= zero_upper[i];

      always @(posedge clk_fp_nrf or negedge reset_n)
        if (~reset_n)
          entry_hi_is_zero <= 1'b0;
        else if (regbank_en_hi[i])
          entry_hi_is_zero <= zero_upper[i];
    end else begin : g_even
      reg entry_hi_is_zero;

      assign zero_upper[i] = (wrmask_fw0[i] & rf_wr_en_fw0_f5_i[3] & ~rf_wr_en_fw0_f5_i[1]) |
                             (wrmask_fw1[i] & rf_wr_en_fw1_f5_i[3] & ~rf_wr_en_fw1_f5_i[1]);

      assign wrmask_fw0_lo_qual[i] = wrmask_fw0[i] & rf_wr_en_fw0_f5_i[0];
      assign wrmask_fw0_hi_qual[i] = wrmask_fw0[i] & rf_wr_en_fw0_f5_i[1];
      assign wrmask_fw1_lo_qual[i] = wrmask_fw1[i] & rf_wr_en_fw1_f5_i[0];
      assign wrmask_fw1_hi_qual[i] = wrmask_fw1[i] & rf_wr_en_fw1_f5_i[1];

      assign regbank_en_lo[i] = wrmask_fw0_lo_qual[i] | wrmask_fw1_lo_qual[i];
      assign regbank_en_hi[i] = wrmask_fw0_hi_qual[i] | wrmask_fw1_hi_qual[i] | (zero_upper[i] & ~entry_hi_is_zero);

      always @(posedge clk_fp_nrf or negedge reset_n)
        if (~reset_n)
          entry_hi_is_zero <= 1'b0;
        else if (regbank_en_hi[i])
          entry_hi_is_zero <= zero_upper[i];
    end

    // Write mux
    assign wdata[i][31: 0] = ({32{wrmask_fw0_lo_qual[i]}} & rf_wr_data_fw0_f5_i[31: 0]) |
                             ({32{wrmask_fw1_lo_qual[i]}} & rf_wr_data_fw1_f5_i[31: 0]);
    assign wdata[i][63:32] = ({32{wrmask_fw0_hi_qual[i]}} & rf_wr_data_fw0_f5_i[63:32]) |
                             ({32{wrmask_fw1_hi_qual[i]}} & rf_wr_data_fw1_f5_i[63:32]);

    always @(posedge clk_fp_nrf)
      if (regbank_en_lo[i])
        rbank[i][31: 0] <= wdata[i][31: 0];

    always @(posedge clk_fp_nrf)
      if (regbank_en_hi[i])
        rbank[i][63:32] <= wdata[i][63:32];

  end endgenerate

  // ------------------------------------------------------
  // Read path
  // ------------------------------------------------------

  generate for (i = 0; i < 64; i = i + 1) begin : g_rd
    assign long_rf_rd_addr_fr0_iss[i] = (rf_rd_addr_fr0_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
    assign long_rf_rd_addr_fr1_iss[i] = (rf_rd_addr_fr1_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
    assign long_rf_rd_addr_fr2_iss[i] = (rf_rd_addr_fr2_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
    assign long_rf_rd_addr_fr3_iss[i] = (rf_rd_addr_fr3_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
    assign long_rf_rd_addr_fr4_iss[i] = (rf_rd_addr_fr4_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
    assign long_rf_rd_addr_fr5_iss[i] = (rf_rd_addr_fr5_iss_i == i[`CA53_FP_RF_RD_ADDR_W-1:0]);
  end endgenerate
  
  assign long_rf_rd_addr_fr0_f1_en = issue_to_ex1_i & (|rf_rd_en_fr0_iss_i);
  assign long_rf_rd_addr_fr1_f1_en = issue_to_ex1_i & (|rf_rd_en_fr1_iss_i);
  assign long_rf_rd_addr_fr2_f1_en = issue_to_ex1_i & (|rf_rd_en_fr2_iss_i);
  assign long_rf_rd_addr_fr3_f1_en = issue_to_ex1_i & (|rf_rd_en_fr3_iss_i);
  assign long_rf_rd_addr_fr4_f1_en = issue_to_ex1_i & (|rf_rd_en_fr4_iss_i);
  assign long_rf_rd_addr_fr5_f1_en = issue_to_ex1_i & (|rf_rd_en_fr5_iss_i);

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr0_f1_en)
      long_rf_rd_addr_fr0_f1 <= long_rf_rd_addr_fr0_iss;

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr1_f1_en)
      long_rf_rd_addr_fr1_f1 <= long_rf_rd_addr_fr1_iss;

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr2_f1_en)
      long_rf_rd_addr_fr2_f1 <= long_rf_rd_addr_fr2_iss;

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr3_f1_en)
      long_rf_rd_addr_fr3_f1 <= long_rf_rd_addr_fr3_iss;

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr4_f1_en)
      long_rf_rd_addr_fr4_f1 <= long_rf_rd_addr_fr4_iss;

  always @(posedge clk_fp)
    if (long_rf_rd_addr_fr5_f1_en)
      long_rf_rd_addr_fr5_f1 <= long_rf_rd_addr_fr5_iss;

  `define CA53_READ_PORT(sel) (({64{sel[ 0]}} & rbank[ 0]) | \
                               ({64{sel[ 1]}} & rbank[ 1]) | \
                               ({64{sel[ 2]}} & rbank[ 2]) | \
                               ({64{sel[ 3]}} & rbank[ 3]) | \
                               ({64{sel[ 4]}} & rbank[ 4]) | \
                               ({64{sel[ 5]}} & rbank[ 5]) | \
                               ({64{sel[ 6]}} & rbank[ 6]) | \
                               ({64{sel[ 7]}} & rbank[ 7]) | \
                               ({64{sel[ 8]}} & rbank[ 8]) | \
                               ({64{sel[ 9]}} & rbank[ 9]) | \
                               ({64{sel[10]}} & rbank[10]) | \
                               ({64{sel[11]}} & rbank[11]) | \
                               ({64{sel[12]}} & rbank[12]) | \
                               ({64{sel[13]}} & rbank[13]) | \
                               ({64{sel[14]}} & rbank[14]) | \
                               ({64{sel[15]}} & rbank[15]) | \
                               ({64{sel[16]}} & rbank[16]) | \
                               ({64{sel[17]}} & rbank[17]) | \
                               ({64{sel[18]}} & rbank[18]) | \
                               ({64{sel[19]}} & rbank[19]) | \
                               ({64{sel[20]}} & rbank[20]) | \
                               ({64{sel[21]}} & rbank[21]) | \
                               ({64{sel[22]}} & rbank[22]) | \
                               ({64{sel[23]}} & rbank[23]) | \
                               ({64{sel[24]}} & rbank[24]) | \
                               ({64{sel[25]}} & rbank[25]) | \
                               ({64{sel[26]}} & rbank[26]) | \
                               ({64{sel[27]}} & rbank[27]) | \
                               ({64{sel[28]}} & rbank[28]) | \
                               ({64{sel[29]}} & rbank[29]) | \
                               ({64{sel[30]}} & rbank[30]) | \
                               ({64{sel[31]}} & rbank[31]) | \
                               ({64{sel[32]}} & rbank[32]) | \
                               ({64{sel[33]}} & rbank[33]) | \
                               ({64{sel[34]}} & rbank[34]) | \
                               ({64{sel[35]}} & rbank[35]) | \
                               ({64{sel[36]}} & rbank[36]) | \
                               ({64{sel[37]}} & rbank[37]) | \
                               ({64{sel[38]}} & rbank[38]) | \
                               ({64{sel[39]}} & rbank[39]) | \
                               ({64{sel[40]}} & rbank[40]) | \
                               ({64{sel[41]}} & rbank[41]) | \
                               ({64{sel[42]}} & rbank[42]) | \
                               ({64{sel[43]}} & rbank[43]) | \
                               ({64{sel[44]}} & rbank[44]) | \
                               ({64{sel[45]}} & rbank[45]) | \
                               ({64{sel[46]}} & rbank[46]) | \
                               ({64{sel[47]}} & rbank[47]) | \
                               ({64{sel[48]}} & rbank[48]) | \
                               ({64{sel[49]}} & rbank[49]) | \
                               ({64{sel[50]}} & rbank[50]) | \
                               ({64{sel[51]}} & rbank[51]) | \
                               ({64{sel[52]}} & rbank[52]) | \
                               ({64{sel[53]}} & rbank[53]) | \
                               ({64{sel[54]}} & rbank[54]) | \
                               ({64{sel[55]}} & rbank[55]) | \
                               ({64{sel[56]}} & rbank[56]) | \
                               ({64{sel[57]}} & rbank[57]) | \
                               ({64{sel[58]}} & rbank[58]) | \
                               ({64{sel[59]}} & rbank[59]) | \
                               ({64{sel[60]}} & rbank[60]) | \
                               ({64{sel[61]}} & rbank[61]) | \
                               ({64{sel[62]}} & rbank[62]) | \
                               ({64{sel[63]}} & rbank[63]))

  assign rf_rd_data_fr0_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr0_f1);
  assign rf_rd_data_fr1_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr1_f1);
  assign rf_rd_data_fr2_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr2_f1);
  assign rf_rd_data_fr3_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr3_f1);
  assign rf_rd_data_fr4_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr4_f1);
  assign rf_rd_data_fr5_ex1_o = `CA53_READ_PORT(long_rf_rd_addr_fr5_f1);

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr0_f1_en")
  u_ovl_x_long_rf_rd_addr_fr0_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr0_f1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr1_f1_en")
  u_ovl_x_long_rf_rd_addr_fr1_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr1_f1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr2_f1_en")
  u_ovl_x_long_rf_rd_addr_fr2_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr2_f1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr3_f1_en")
  u_ovl_x_long_rf_rd_addr_fr3_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr3_f1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr4_f1_en")
  u_ovl_x_long_rf_rd_addr_fr4_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr4_f1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: long_rf_rd_addr_fr5_f1_en")
  u_ovl_x_long_rf_rd_addr_fr5_f1_en (.clk       (clk_fp),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (long_rf_rd_addr_fr5_f1_en));

  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "Register enable x-check: regbank_en_lo")
  u_ovl_x_regbank_en_lo (
    .clk       (clk_fp_nrf),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (regbank_en_lo)
  );

  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "Register enable x-check: regbank_en_hi")
  u_ovl_x_regbank_en_hi (
    .clk       (clk_fp_nrf),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (regbank_en_hi)
  );

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retire_data_fw0_lo
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the FPU RF port FW0 low half")
    ovl_fpu_regbank_retire_data_fw0_lo (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .qualifier (rf_wr_en_fw0_f5_i[0]),
      .test_expr (rf_wr_data_fw0_f5_i[31:0])
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retite_data_fw0_hi
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the FPU RF port FW0 high half")
    ovl_fpu_regbank_retire_data_fw0_hi (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .qualifier (rf_wr_en_fw0_f5_i[1]),
      .test_expr (rf_wr_data_fw0_f5_i[63:32])
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retire_data_fw1_lo
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the FPU RF port FW1 low half")
    ovl_fpu_regbank_retire_data_fw1_lo (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .qualifier (rf_wr_en_fw1_f5_i[0]),
      .test_expr (rf_wr_data_fw1_f5_i[31:0])
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retite_data_fw1_hi
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the FPU RF port FW1 high half")
    ovl_fpu_regbank_retire_data_fw1_hi (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .qualifier (rf_wr_en_fw1_f5_i[1]),
      .test_expr (rf_wr_data_fw1_f5_i[63:32])
    );
  // OVL_ASSERT_END

  // The enable bit [2] indicating a zero-extended 128-bit write should only be set
  // when the write address is even and bit [0] is also set
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW0 attempting 128-bit write to odd index")
    ovl_fpu_regbank_128b_wr_fw0_even (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (|rf_wr_en_fw0_f5_i[3:2]),
      .consequent_expr (rf_wr_addr_fw0_f5_i[0] == 1'b0)
    );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW1 attempting 128-bit write to odd index")
    ovl_fpu_regbank_128b_wr_fw1_even (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (|rf_wr_en_fw1_f5_i[3:2]),
      .consequent_expr (rf_wr_addr_fw1_f5_i[0] == 1'b0)
    );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW0 write enable invalid")
    ovl_fpu_regbank_128b_wr_fw0_en1 (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (rf_wr_en_fw0_f5_i[2]),
      .consequent_expr (~rf_wr_en_fw0_f5_i[3] & (&rf_wr_en_fw0_f5_i[1:0]))
    );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW0 write enable invalid")
    ovl_fpu_regbank_128b_wr_fw0_en2 (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (rf_wr_en_fw0_f5_i[3]),
      .consequent_expr (~rf_wr_en_fw0_f5_i[2] & (|rf_wr_en_fw0_f5_i[1:0]))
    );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW1 write enable invalid")
    ovl_fpu_regbank_128b_wr_fw1_en1 (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (rf_wr_en_fw1_f5_i[2]),
      .consequent_expr (~rf_wr_en_fw1_f5_i[3] & (&rf_wr_en_fw1_f5_i[1:0]))
    );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "FW1 write enable invalid")
    ovl_fpu_regbank_128b_wr_fw1_en2 (
      .clk             (clk_fp),
      .reset_n         (reset_n),
      .antecedent_expr (rf_wr_en_fw1_f5_i[3]),
      .consequent_expr (~rf_wr_en_fw1_f5_i[2] & (|rf_wr_en_fw1_f5_i[1:0]))
    );

  // FW0 and FW1 must not attempt to write to the same registers
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Writes to ports FW0 and FW1 conflict")
    ovl_fpu_regbank_overlapping_wr (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .test_expr ((rf_wr_addr_fw0_f5_i == rf_wr_addr_fw1_f5_i) &
                  (|(rf_wr_en_fw0_f5_i[1:0] & rf_wr_en_fw1_f5_i[1:0])))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "FW1 attempting to write to high half of register written with 128-bit write from FW0")
    ovl_fpu_regbank_128b_overlap_fw0_fw1 (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .test_expr (((rf_wr_addr_fw0_f5_i + 1) == rf_wr_addr_fw1_f5_i) &
                  (|rf_wr_en_fw0_f5_i[3:2]) & (|rf_wr_en_fw1_f5_i[1:0]))
    );

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "FW0 attempting to write to high half of register written with 128-bit write from FW1")
    ovl_fpu_regbank_128b_overlap_fw1_fw0 (
      .clk       (clk_fp),
      .reset_n   (reset_n),
      .test_expr (((rf_wr_addr_fw1_f5_i + 1) == rf_wr_addr_fw0_f5_i) &
                  (|rf_wr_en_fw1_f5_i[3:2]) & (|rf_wr_en_fw0_f5_i[1:0]))
    );

`endif

endmodule // ca53dpu_fp_regbank

/*ARMAUTO_UNDEF*/
`undef CA53_READ_PORT
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
