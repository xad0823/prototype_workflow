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
// Abstract : Integer Core register bank
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_regbank (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             DFTSE,
  input  wire                             aarch64_state_i,
  input  wire                             aarch64_state_iss_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r0_de_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r1_de_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r0_agu_de_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r1_agu_de_i,
  input  wire                       [2:0] rf_rd_r0_agu_de_i,
  input  wire                       [2:0] rf_rd_r1_agu_de_i,
  input  wire                             en_rf_rd_r0_agu_de_i,
  input  wire                             en_rf_rd_r1_agu_de_i,
  input  wire                             issue_to_iss_i,
  input  wire                             ilock_stall_iss_i,
  input  wire                             ls_valid_de_i,
  input  wire                             rf_rd_en_r0_de_i,
  input  wire                             rf_rd_en_r1_de_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r2_iss_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r3_iss_i,
  input  wire  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r4_iss_i,
  input  wire                             sel_rf_wr_w0_wr_i,
  input  wire                             sel_rf_wr_w1_wr_i,
  input  wire                             sel_rf_wr_w2_wr_i,
  input  wire                             rf_wr_en_hi_wr_i,
  input  wire                             rf_wr_en_lo_wr_i,
  input  wire                             rf_wr_en_w0_wr_i,
  input  wire                             rf_wr_en_w1_wr_i,
  input  wire                             rf_wr_en_w2_wr_i,
  input  wire                             rf_wr_64b_w0_wr_i,
  input  wire                             rf_wr_64b_w1_wr_i,
  input  wire                             rf_wr_64b_w2_wr_i,
  input  wire                       [5:0] rf_wr_addr_w0_wr_i,
  input  wire                       [5:0] rf_wr_addr_w1_wr_i,
  input  wire                       [5:0] rf_wr_addr_w2_wr_i,
  input  wire                      [63:0] rf_wr_data_w0_wr_i,
  input  wire                      [63:0] rf_wr_data_w1_wr_i,
  input  wire                      [63:0] rf_wr_data_w2_wr_i,
  // Outputs
  output wire                      [63:0] rf_rd_data_r0_iss_o,
  output wire                      [63:0] rf_rd_data_r0_agu_iss_o,
  output wire                      [63:0] rf_rd_data_r1_iss_o,
  output wire                      [63:0] rf_rd_data_r1_agu_iss_o,
  output wire                      [63:0] rf_rd_data_r2_iss_o,
  output wire                      [63:0] rf_rd_data_r3_iss_o,
  output wire                      [63:0] rf_rd_data_r4_iss_o
);

  // -----------------------------
  // Genvar declaration
  // -----------------------------

  genvar rf_entry;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                      [63:0] rbank [`CA53_LONG_RF_ADDR_W-1:0];
  reg  [`CA53_LONG_RF_ADDR_W-1:0] rbank_top_zero;
  reg  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r0_lo_iss;
  reg  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r0_hi_iss;
  reg  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r1_lo_iss;
  reg  [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r1_hi_iss;
  reg                       [3:0] rf_rd_data_r0_agu_de;
  reg                       [3:0] rf_rd_data_r1_agu_de;
  reg                       [3:0] rf_rd_data_r0_agu_iss;
  reg                       [3:0] rf_rd_data_r1_agu_iss;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                            clk_irf_hi;
  wire                            clk_irf_lo;
  wire                      [3:0] agu_r0_regbank_de;
  wire                      [3:0] agu_r1_regbank_de;
  wire                            en_rf_rd_addr_r0_lo_iss;
  wire                            en_rf_rd_addr_r0_hi_iss;
  wire                            en_rf_rd_addr_r1_lo_iss;
  wire                            en_rf_rd_addr_r1_hi_iss;
  wire                            en_rf_rd_data_r0_agu_iss;
  wire                            en_rf_rd_data_r1_agu_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] nxt_long_rf_rd_addr_r0_hi_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] nxt_long_rf_rd_addr_r1_hi_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r2_hi_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r3_hi_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_r4_hi_iss;
  wire [`CA53_LONG_RF_ADDR_W-1:0] wrmask_0;
  wire [`CA53_LONG_RF_ADDR_W-1:0] wrmask_1;
  wire [`CA53_LONG_RF_ADDR_W-1:0] wrmask_2;
  wire [`CA53_LONG_RF_ADDR_W-1:0] wr_top_zero;
  wire [`CA53_LONG_RF_ADDR_W-1:0] regbank_en_lo;
  wire [`CA53_LONG_RF_ADDR_W-1:0] regbank_en_hi;
  wire                     [63:0] wdata [`CA53_LONG_RF_ADDR_W-1:0];
  wire                     [63:0] rf_rd_data_r0_iss;
  wire                     [63:0] rf_rd_data_r1_iss;
  wire                     [63:0] rf_rd_data_r2_iss;
  wire                     [63:0] rf_rd_data_r3_iss;
  wire                     [63:0] rf_rd_data_r4_iss;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Read port multiplexors
  // ------------------------------------------------------

  `define CA53_READ_PORT_LO(sel)   (({32{sel[`CA53_ADDR_BIT_X0]}}      & rbank[`CA53_ADDR_BIT_X0][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X1]}}      & rbank[`CA53_ADDR_BIT_X1][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X2]}}      & rbank[`CA53_ADDR_BIT_X2][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X3]}}      & rbank[`CA53_ADDR_BIT_X3][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X4]}}      & rbank[`CA53_ADDR_BIT_X4][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X5]}}      & rbank[`CA53_ADDR_BIT_X5][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X6]}}      & rbank[`CA53_ADDR_BIT_X6][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X7]}}      & rbank[`CA53_ADDR_BIT_X7][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X8]}}      & rbank[`CA53_ADDR_BIT_X8][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X9]}}      & rbank[`CA53_ADDR_BIT_X9][31: 0]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X10]}}     & rbank[`CA53_ADDR_BIT_X10][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X11]}}     & rbank[`CA53_ADDR_BIT_X11][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X12]}}     & rbank[`CA53_ADDR_BIT_X12][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X13]}}     & rbank[`CA53_ADDR_BIT_X13][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X14]}}     & rbank[`CA53_ADDR_BIT_X14][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X15]}}     & rbank[`CA53_ADDR_BIT_X15][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X16]}}     & rbank[`CA53_ADDR_BIT_X16][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X17]}}     & rbank[`CA53_ADDR_BIT_X17][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X18]}}     & rbank[`CA53_ADDR_BIT_X18][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X19]}}     & rbank[`CA53_ADDR_BIT_X19][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X20]}}     & rbank[`CA53_ADDR_BIT_X20][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X21]}}     & rbank[`CA53_ADDR_BIT_X21][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X22]}}     & rbank[`CA53_ADDR_BIT_X22][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X23]}}     & rbank[`CA53_ADDR_BIT_X23][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X24]}}     & rbank[`CA53_ADDR_BIT_X24][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X25]}}     & rbank[`CA53_ADDR_BIT_X25][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X26]}}     & rbank[`CA53_ADDR_BIT_X26][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X27]}}     & rbank[`CA53_ADDR_BIT_X27][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X28]}}     & rbank[`CA53_ADDR_BIT_X28][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X29]}}     & rbank[`CA53_ADDR_BIT_X29][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X30]}}     & rbank[`CA53_ADDR_BIT_X30][31: 0]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL0]}}  & rbank[`CA53_ADDR_BIT_SP_EL0][31: 0] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL1]}}  & rbank[`CA53_ADDR_BIT_SP_EL1][31: 0] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL2]}}  & rbank[`CA53_ADDR_BIT_SP_EL2][31: 0] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL3]}}  & rbank[`CA53_ADDR_BIT_SP_EL3][31: 0] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL1]}} & rbank[`CA53_ADDR_BIT_ELR_EL1][31: 0]) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL2]}} & rbank[`CA53_ADDR_BIT_ELR_EL2][31: 0]) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL3]}} & rbank[`CA53_ADDR_BIT_ELR_EL3][31: 0]))

  `define CA53_READ_PORT_HI(sel)   (({32{sel[`CA53_ADDR_BIT_X0]}}      & rbank[`CA53_ADDR_BIT_X0][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X1]}}      & rbank[`CA53_ADDR_BIT_X1][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X2]}}      & rbank[`CA53_ADDR_BIT_X2][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X3]}}      & rbank[`CA53_ADDR_BIT_X3][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X4]}}      & rbank[`CA53_ADDR_BIT_X4][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X5]}}      & rbank[`CA53_ADDR_BIT_X5][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X6]}}      & rbank[`CA53_ADDR_BIT_X6][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X7]}}      & rbank[`CA53_ADDR_BIT_X7][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X8]}}      & rbank[`CA53_ADDR_BIT_X8][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X9]}}      & rbank[`CA53_ADDR_BIT_X9][63:32]     ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X10]}}     & rbank[`CA53_ADDR_BIT_X10][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X11]}}     & rbank[`CA53_ADDR_BIT_X11][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X12]}}     & rbank[`CA53_ADDR_BIT_X12][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X13]}}     & rbank[`CA53_ADDR_BIT_X13][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X14]}}     & rbank[`CA53_ADDR_BIT_X14][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X15]}}     & rbank[`CA53_ADDR_BIT_X15][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X16]}}     & rbank[`CA53_ADDR_BIT_X16][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X17]}}     & rbank[`CA53_ADDR_BIT_X17][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X18]}}     & rbank[`CA53_ADDR_BIT_X18][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X19]}}     & rbank[`CA53_ADDR_BIT_X19][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X20]}}     & rbank[`CA53_ADDR_BIT_X20][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X21]}}     & rbank[`CA53_ADDR_BIT_X21][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X22]}}     & rbank[`CA53_ADDR_BIT_X22][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X23]}}     & rbank[`CA53_ADDR_BIT_X23][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X24]}}     & rbank[`CA53_ADDR_BIT_X24][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X25]}}     & rbank[`CA53_ADDR_BIT_X25][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X26]}}     & rbank[`CA53_ADDR_BIT_X26][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X27]}}     & rbank[`CA53_ADDR_BIT_X27][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X28]}}     & rbank[`CA53_ADDR_BIT_X28][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X29]}}     & rbank[`CA53_ADDR_BIT_X29][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_X30]}}     & rbank[`CA53_ADDR_BIT_X30][63:32]    ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL0]}}  & rbank[`CA53_ADDR_BIT_SP_EL0][63:32] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL1]}}  & rbank[`CA53_ADDR_BIT_SP_EL1][63:32] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL2]}}  & rbank[`CA53_ADDR_BIT_SP_EL2][63:32] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_SP_EL3]}}  & rbank[`CA53_ADDR_BIT_SP_EL3][63:32] ) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL1]}} & rbank[`CA53_ADDR_BIT_ELR_EL1][63:32]) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL2]}} & rbank[`CA53_ADDR_BIT_ELR_EL2][63:32]) | \
                                    ({32{sel[`CA53_ADDR_BIT_ELR_EL3]}} & rbank[`CA53_ADDR_BIT_ELR_EL3][63:32]))

  `define CA53_4BIT_READ_PORT(sel) (({ 4{sel[`CA53_ADDR_BIT_X0]}}      & rbank[`CA53_ADDR_BIT_X0][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X1]}}      & rbank[`CA53_ADDR_BIT_X1][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X2]}}      & rbank[`CA53_ADDR_BIT_X2][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X3]}}      & rbank[`CA53_ADDR_BIT_X3][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X4]}}      & rbank[`CA53_ADDR_BIT_X4][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X5]}}      & rbank[`CA53_ADDR_BIT_X5][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X6]}}      & rbank[`CA53_ADDR_BIT_X6][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X7]}}      & rbank[`CA53_ADDR_BIT_X7][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X8]}}      & rbank[`CA53_ADDR_BIT_X8][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X9]}}      & rbank[`CA53_ADDR_BIT_X9][3:0]     ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X10]}}     & rbank[`CA53_ADDR_BIT_X10][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X11]}}     & rbank[`CA53_ADDR_BIT_X11][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X12]}}     & rbank[`CA53_ADDR_BIT_X12][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X13]}}     & rbank[`CA53_ADDR_BIT_X13][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X14]}}     & rbank[`CA53_ADDR_BIT_X14][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X15]}}     & rbank[`CA53_ADDR_BIT_X15][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X16]}}     & rbank[`CA53_ADDR_BIT_X16][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X17]}}     & rbank[`CA53_ADDR_BIT_X17][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X18]}}     & rbank[`CA53_ADDR_BIT_X18][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X19]}}     & rbank[`CA53_ADDR_BIT_X19][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X20]}}     & rbank[`CA53_ADDR_BIT_X20][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X21]}}     & rbank[`CA53_ADDR_BIT_X21][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X22]}}     & rbank[`CA53_ADDR_BIT_X22][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X23]}}     & rbank[`CA53_ADDR_BIT_X23][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X24]}}     & rbank[`CA53_ADDR_BIT_X24][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X25]}}     & rbank[`CA53_ADDR_BIT_X25][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X26]}}     & rbank[`CA53_ADDR_BIT_X26][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X27]}}     & rbank[`CA53_ADDR_BIT_X27][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X28]}}     & rbank[`CA53_ADDR_BIT_X28][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X29]}}     & rbank[`CA53_ADDR_BIT_X29][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_X30]}}     & rbank[`CA53_ADDR_BIT_X30][3:0]    ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_SP_EL0]}}  & rbank[`CA53_ADDR_BIT_SP_EL0][3:0] ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_SP_EL1]}}  & rbank[`CA53_ADDR_BIT_SP_EL1][3:0] ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_SP_EL2]}}  & rbank[`CA53_ADDR_BIT_SP_EL2][3:0] ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_SP_EL3]}}  & rbank[`CA53_ADDR_BIT_SP_EL3][3:0] ) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_ELR_EL1]}} & rbank[`CA53_ADDR_BIT_ELR_EL1][3:0]) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_ELR_EL2]}} & rbank[`CA53_ADDR_BIT_ELR_EL2][3:0]) | \
                                    ({ 4{sel[`CA53_ADDR_BIT_ELR_EL3]}} & rbank[`CA53_ADDR_BIT_ELR_EL3][3:0]))

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // All registers in the register bank can be architecturally gated using
  // an intermediate clock gate
  ca53_cell_inter_clkgate u_inter_clkgate_irf_hi (
    .clk_i         (clk),
    .clk_enable_i  (rf_wr_en_hi_wr_i),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_irf_hi)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_irf_lo (
    .clk_i         (clk),
    .clk_enable_i  (rf_wr_en_lo_wr_i),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_irf_lo)
  );

  // ------------------------------------------------------
  // Write address decoders
  // ------------------------------------------------------

  // Write-port 0 raw enables
  assign wrmask_0[`CA53_ADDR_BIT_X0]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X0;
  assign wrmask_0[`CA53_ADDR_BIT_X1]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X1;
  assign wrmask_0[`CA53_ADDR_BIT_X2]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X2;
  assign wrmask_0[`CA53_ADDR_BIT_X3]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X3;
  assign wrmask_0[`CA53_ADDR_BIT_X4]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X4;
  assign wrmask_0[`CA53_ADDR_BIT_X5]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X5;
  assign wrmask_0[`CA53_ADDR_BIT_X6]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X6;
  assign wrmask_0[`CA53_ADDR_BIT_X7]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X7;
  assign wrmask_0[`CA53_ADDR_BIT_X8]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X8;
  assign wrmask_0[`CA53_ADDR_BIT_X9]      = rf_wr_addr_w0_wr_i == `CA53_ADDR_X9;
  assign wrmask_0[`CA53_ADDR_BIT_X10]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X10;
  assign wrmask_0[`CA53_ADDR_BIT_X11]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X11;
  assign wrmask_0[`CA53_ADDR_BIT_X12]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X12;
  assign wrmask_0[`CA53_ADDR_BIT_X13]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X13;
  assign wrmask_0[`CA53_ADDR_BIT_X14]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X14;
  assign wrmask_0[`CA53_ADDR_BIT_X15]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X15;
  assign wrmask_0[`CA53_ADDR_BIT_X16]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X16;
  assign wrmask_0[`CA53_ADDR_BIT_X17]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X17;
  assign wrmask_0[`CA53_ADDR_BIT_X18]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X18;
  assign wrmask_0[`CA53_ADDR_BIT_X19]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X19;
  assign wrmask_0[`CA53_ADDR_BIT_X20]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X20;
  assign wrmask_0[`CA53_ADDR_BIT_X21]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X21;
  assign wrmask_0[`CA53_ADDR_BIT_X22]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X22;
  assign wrmask_0[`CA53_ADDR_BIT_X23]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X23;
  assign wrmask_0[`CA53_ADDR_BIT_X24]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X24;
  assign wrmask_0[`CA53_ADDR_BIT_X25]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X25;
  assign wrmask_0[`CA53_ADDR_BIT_X26]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X26;
  assign wrmask_0[`CA53_ADDR_BIT_X27]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X27;
  assign wrmask_0[`CA53_ADDR_BIT_X28]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X28;
  assign wrmask_0[`CA53_ADDR_BIT_X29]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X29;
  assign wrmask_0[`CA53_ADDR_BIT_X30]     = rf_wr_addr_w0_wr_i == `CA53_ADDR_X30;
  assign wrmask_0[`CA53_ADDR_BIT_SP_EL0]  = rf_wr_addr_w0_wr_i == `CA53_ADDR_SP_EL0;
  assign wrmask_0[`CA53_ADDR_BIT_SP_EL1]  = rf_wr_addr_w0_wr_i == `CA53_ADDR_SP_EL1;
  assign wrmask_0[`CA53_ADDR_BIT_SP_EL2]  = rf_wr_addr_w0_wr_i == `CA53_ADDR_SP_EL2;
  assign wrmask_0[`CA53_ADDR_BIT_SP_EL3]  = rf_wr_addr_w0_wr_i == `CA53_ADDR_SP_EL3;
  assign wrmask_0[`CA53_ADDR_BIT_ELR_EL1] = rf_wr_addr_w0_wr_i == `CA53_ADDR_ELR_EL1;
  assign wrmask_0[`CA53_ADDR_BIT_ELR_EL2] = rf_wr_addr_w0_wr_i == `CA53_ADDR_ELR_EL2;
  assign wrmask_0[`CA53_ADDR_BIT_ELR_EL3] = rf_wr_addr_w0_wr_i == `CA53_ADDR_ELR_EL3;

  // Write-port 1 raw enables
  assign wrmask_1[`CA53_ADDR_BIT_X0]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X0;
  assign wrmask_1[`CA53_ADDR_BIT_X1]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X1;
  assign wrmask_1[`CA53_ADDR_BIT_X2]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X2;
  assign wrmask_1[`CA53_ADDR_BIT_X3]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X3;
  assign wrmask_1[`CA53_ADDR_BIT_X4]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X4;
  assign wrmask_1[`CA53_ADDR_BIT_X5]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X5;
  assign wrmask_1[`CA53_ADDR_BIT_X6]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X6;
  assign wrmask_1[`CA53_ADDR_BIT_X7]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X7;
  assign wrmask_1[`CA53_ADDR_BIT_X8]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X8;
  assign wrmask_1[`CA53_ADDR_BIT_X9]      = rf_wr_addr_w1_wr_i == `CA53_ADDR_X9;
  assign wrmask_1[`CA53_ADDR_BIT_X10]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X10;
  assign wrmask_1[`CA53_ADDR_BIT_X11]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X11;
  assign wrmask_1[`CA53_ADDR_BIT_X12]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X12;
  assign wrmask_1[`CA53_ADDR_BIT_X13]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X13;
  assign wrmask_1[`CA53_ADDR_BIT_X14]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X14;
  assign wrmask_1[`CA53_ADDR_BIT_X15]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X15;
  assign wrmask_1[`CA53_ADDR_BIT_X16]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X16;
  assign wrmask_1[`CA53_ADDR_BIT_X17]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X17;
  assign wrmask_1[`CA53_ADDR_BIT_X18]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X18;
  assign wrmask_1[`CA53_ADDR_BIT_X19]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X19;
  assign wrmask_1[`CA53_ADDR_BIT_X20]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X20;
  assign wrmask_1[`CA53_ADDR_BIT_X21]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X21;
  assign wrmask_1[`CA53_ADDR_BIT_X22]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X22;
  assign wrmask_1[`CA53_ADDR_BIT_X23]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X23;
  assign wrmask_1[`CA53_ADDR_BIT_X24]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X24;
  assign wrmask_1[`CA53_ADDR_BIT_X25]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X25;
  assign wrmask_1[`CA53_ADDR_BIT_X26]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X26;
  assign wrmask_1[`CA53_ADDR_BIT_X27]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X27;
  assign wrmask_1[`CA53_ADDR_BIT_X28]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X28;
  assign wrmask_1[`CA53_ADDR_BIT_X29]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X29;
  assign wrmask_1[`CA53_ADDR_BIT_X30]     = rf_wr_addr_w1_wr_i == `CA53_ADDR_X30;
  assign wrmask_1[`CA53_ADDR_BIT_SP_EL0]  = rf_wr_addr_w1_wr_i == `CA53_ADDR_SP_EL0;
  assign wrmask_1[`CA53_ADDR_BIT_SP_EL1]  = rf_wr_addr_w1_wr_i == `CA53_ADDR_SP_EL1;
  assign wrmask_1[`CA53_ADDR_BIT_SP_EL2]  = rf_wr_addr_w1_wr_i == `CA53_ADDR_SP_EL2;
  assign wrmask_1[`CA53_ADDR_BIT_SP_EL3]  = rf_wr_addr_w1_wr_i == `CA53_ADDR_SP_EL3;
  assign wrmask_1[`CA53_ADDR_BIT_ELR_EL1] = rf_wr_addr_w1_wr_i == `CA53_ADDR_ELR_EL1;
  assign wrmask_1[`CA53_ADDR_BIT_ELR_EL2] = rf_wr_addr_w1_wr_i == `CA53_ADDR_ELR_EL2;
  assign wrmask_1[`CA53_ADDR_BIT_ELR_EL3] = rf_wr_addr_w1_wr_i == `CA53_ADDR_ELR_EL3;

  // Write-port 2 raw enables
  assign wrmask_2[`CA53_ADDR_BIT_X0]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X0;
  assign wrmask_2[`CA53_ADDR_BIT_X1]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X1;
  assign wrmask_2[`CA53_ADDR_BIT_X2]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X2;
  assign wrmask_2[`CA53_ADDR_BIT_X3]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X3;
  assign wrmask_2[`CA53_ADDR_BIT_X4]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X4;
  assign wrmask_2[`CA53_ADDR_BIT_X5]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X5;
  assign wrmask_2[`CA53_ADDR_BIT_X6]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X6;
  assign wrmask_2[`CA53_ADDR_BIT_X7]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X7;
  assign wrmask_2[`CA53_ADDR_BIT_X8]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X8;
  assign wrmask_2[`CA53_ADDR_BIT_X9]      = rf_wr_addr_w2_wr_i == `CA53_ADDR_X9;
  assign wrmask_2[`CA53_ADDR_BIT_X10]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X10;
  assign wrmask_2[`CA53_ADDR_BIT_X11]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X11;
  assign wrmask_2[`CA53_ADDR_BIT_X12]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X12;
  assign wrmask_2[`CA53_ADDR_BIT_X13]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X13;
  assign wrmask_2[`CA53_ADDR_BIT_X14]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X14;
  assign wrmask_2[`CA53_ADDR_BIT_X15]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X15;
  assign wrmask_2[`CA53_ADDR_BIT_X16]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X16;
  assign wrmask_2[`CA53_ADDR_BIT_X17]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X17;
  assign wrmask_2[`CA53_ADDR_BIT_X18]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X18;
  assign wrmask_2[`CA53_ADDR_BIT_X19]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X19;
  assign wrmask_2[`CA53_ADDR_BIT_X20]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X20;
  assign wrmask_2[`CA53_ADDR_BIT_X21]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X21;
  assign wrmask_2[`CA53_ADDR_BIT_X22]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X22;
  assign wrmask_2[`CA53_ADDR_BIT_X23]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X23;
  assign wrmask_2[`CA53_ADDR_BIT_X24]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X24;
  assign wrmask_2[`CA53_ADDR_BIT_X25]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X25;
  assign wrmask_2[`CA53_ADDR_BIT_X26]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X26;
  assign wrmask_2[`CA53_ADDR_BIT_X27]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X27;
  assign wrmask_2[`CA53_ADDR_BIT_X28]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X28;
  assign wrmask_2[`CA53_ADDR_BIT_X29]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X29;
  assign wrmask_2[`CA53_ADDR_BIT_X30]     = rf_wr_addr_w2_wr_i == `CA53_ADDR_X30;
  assign wrmask_2[`CA53_ADDR_BIT_SP_EL0]  = rf_wr_addr_w2_wr_i == `CA53_ADDR_SP_EL0;
  assign wrmask_2[`CA53_ADDR_BIT_SP_EL1]  = rf_wr_addr_w2_wr_i == `CA53_ADDR_SP_EL1;
  assign wrmask_2[`CA53_ADDR_BIT_SP_EL2]  = rf_wr_addr_w2_wr_i == `CA53_ADDR_SP_EL2;
  assign wrmask_2[`CA53_ADDR_BIT_SP_EL3]  = rf_wr_addr_w2_wr_i == `CA53_ADDR_SP_EL3;
  assign wrmask_2[`CA53_ADDR_BIT_ELR_EL1] = rf_wr_addr_w2_wr_i == `CA53_ADDR_ELR_EL1;
  assign wrmask_2[`CA53_ADDR_BIT_ELR_EL2] = rf_wr_addr_w2_wr_i == `CA53_ADDR_ELR_EL2;
  assign wrmask_2[`CA53_ADDR_BIT_ELR_EL3] = rf_wr_addr_w2_wr_i == `CA53_ADDR_ELR_EL3;

  // ------------------------------------------------------
  // Regbank write muxes
  // ------------------------------------------------------

  generate for (rf_entry=0; rf_entry<`CA53_LONG_RF_ADDR_W; rf_entry=rf_entry+1) begin : g_wdata

    assign wdata[rf_entry][63:0] = ({64{sel_rf_wr_w0_wr_i & wrmask_0[rf_entry]}} & rf_wr_data_w0_wr_i) |
                                   ({64{sel_rf_wr_w1_wr_i & wrmask_1[rf_entry]}} & rf_wr_data_w1_wr_i) |
                                   ({64{sel_rf_wr_w2_wr_i & wrmask_2[rf_entry]}} & rf_wr_data_w2_wr_i);

    // Determine if the top 32 bits are being written as zero due to a 32-bit
    // operation in AArch64
    assign wr_top_zero[rf_entry] = (sel_rf_wr_w0_wr_i & wrmask_0[rf_entry] & ~rf_wr_64b_w0_wr_i) |
                                   (sel_rf_wr_w1_wr_i & wrmask_1[rf_entry] & ~rf_wr_64b_w1_wr_i) |
                                   (sel_rf_wr_w2_wr_i & wrmask_2[rf_entry] & ~rf_wr_64b_w2_wr_i);

    assign regbank_en_lo[rf_entry]  = (rf_wr_en_w0_wr_i & wrmask_0[rf_entry]) |
                                      (rf_wr_en_w1_wr_i & wrmask_1[rf_entry]) |
                                      (rf_wr_en_w2_wr_i & wrmask_2[rf_entry]);

    assign regbank_en_hi[rf_entry]  = regbank_en_lo[rf_entry] & rf_wr_en_hi_wr_i &
                                      ~(wr_top_zero[rf_entry] & rbank_top_zero[rf_entry]);

  end endgenerate

  // ------------------------------------------------------
  // Regbank registers
  // ------------------------------------------------------

  generate for (rf_entry=0; rf_entry<`CA53_LONG_RF_ADDR_W; rf_entry=rf_entry+1) begin : g_rbank

    always @(posedge clk_irf_lo)
      if (regbank_en_lo[rf_entry])
        rbank[rf_entry][31: 0] <= wdata[rf_entry][31: 0];

    always @(posedge clk_irf_hi)
      if (regbank_en_hi[rf_entry])
        rbank[rf_entry][63:32] <= wdata[rf_entry][63:32];

    always @(posedge clk_irf_hi or negedge reset_n)
      if (~reset_n)
        rbank_top_zero[rf_entry] <= 1'b0;
      else if (regbank_en_hi[rf_entry])
        rbank_top_zero[rf_entry] <= wr_top_zero[rf_entry];

  end endgenerate

  // ------------------------------------------------------
  // Read path
  // ------------------------------------------------------

  assign en_rf_rd_addr_r0_lo_iss = issue_to_iss_i & rf_rd_en_r0_de_i;
  assign en_rf_rd_addr_r0_hi_iss = issue_to_iss_i & rf_rd_en_r0_de_i & (aarch64_state_i | (|long_rf_rd_addr_r0_hi_iss));
  assign en_rf_rd_addr_r1_lo_iss = issue_to_iss_i & rf_rd_en_r1_de_i;
  assign en_rf_rd_addr_r1_hi_iss = issue_to_iss_i & rf_rd_en_r1_de_i & (aarch64_state_i | (|long_rf_rd_addr_r1_hi_iss));

  // Suppress reads of upper half of registers in AArch32
  assign nxt_long_rf_rd_addr_r0_hi_iss = long_rf_rd_addr_r0_de_i & {`CA53_LONG_RF_ADDR_W{aarch64_state_i}};
  assign nxt_long_rf_rd_addr_r1_hi_iss = long_rf_rd_addr_r1_de_i & {`CA53_LONG_RF_ADDR_W{aarch64_state_i}};

  always @(posedge clk)
    if (en_rf_rd_addr_r0_lo_iss)
      long_rf_rd_addr_r0_lo_iss <= long_rf_rd_addr_r0_de_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      long_rf_rd_addr_r0_hi_iss <= {`CA53_LONG_RF_ADDR_W{1'b0}};
    else if (en_rf_rd_addr_r0_hi_iss)
      long_rf_rd_addr_r0_hi_iss <= nxt_long_rf_rd_addr_r0_hi_iss;

  always @(posedge clk)
    if (en_rf_rd_addr_r1_lo_iss)
      long_rf_rd_addr_r1_lo_iss <= long_rf_rd_addr_r1_de_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      long_rf_rd_addr_r1_hi_iss <= {`CA53_LONG_RF_ADDR_W{1'b0}};
    else if (en_rf_rd_addr_r1_hi_iss)
      long_rf_rd_addr_r1_hi_iss <= nxt_long_rf_rd_addr_r1_hi_iss;


  // Suppress reads of upper half of registers in AArch32
  assign long_rf_rd_addr_r2_hi_iss = long_rf_rd_addr_r2_iss_i & {`CA53_LONG_RF_ADDR_W{aarch64_state_iss_i}};
  assign long_rf_rd_addr_r3_hi_iss = long_rf_rd_addr_r3_iss_i & {`CA53_LONG_RF_ADDR_W{aarch64_state_iss_i}};
  assign long_rf_rd_addr_r4_hi_iss = long_rf_rd_addr_r4_iss_i & {`CA53_LONG_RF_ADDR_W{aarch64_state_iss_i}};

  // Fast read-port using one-hot selects
  assign rf_rd_data_r0_iss[31: 0] = `CA53_READ_PORT_LO(long_rf_rd_addr_r0_lo_iss);
  assign rf_rd_data_r0_iss[63:32] = `CA53_READ_PORT_HI(long_rf_rd_addr_r0_hi_iss);

  assign rf_rd_data_r1_iss[31: 0] = `CA53_READ_PORT_LO(long_rf_rd_addr_r1_lo_iss);
  assign rf_rd_data_r1_iss[63:32] = `CA53_READ_PORT_HI(long_rf_rd_addr_r1_hi_iss);

  assign rf_rd_data_r2_iss[31: 0] = `CA53_READ_PORT_LO(long_rf_rd_addr_r2_iss_i);
  assign rf_rd_data_r2_iss[63:32] = `CA53_READ_PORT_HI(long_rf_rd_addr_r2_hi_iss);

  assign rf_rd_data_r3_iss[31: 0] = `CA53_READ_PORT_LO(long_rf_rd_addr_r3_iss_i);
  assign rf_rd_data_r3_iss[63:32] = `CA53_READ_PORT_HI(long_rf_rd_addr_r3_hi_iss);

  assign rf_rd_data_r4_iss[31: 0] = `CA53_READ_PORT_LO(long_rf_rd_addr_r4_iss_i);
  assign rf_rd_data_r4_iss[63:32] = `CA53_READ_PORT_HI(long_rf_rd_addr_r4_hi_iss);

  // ------------------------------------------------------
  // AGU Read path
  // ------------------------------------------------------
  //
  // Timing in to the AGU operands is particularly critical because of the volume of logic on
  // the path.  To counter this the lower order bits are read and registered in the De stage.

  // First read the source registers used by the AGU from the regbank
  assign agu_r0_regbank_de[3:0] = `CA53_4BIT_READ_PORT(rf_rd_addr_r0_agu_de_i);
  assign agu_r1_regbank_de[3:0] = `CA53_4BIT_READ_PORT(rf_rd_addr_r1_agu_de_i);

  // We must be able to overwrite the operands while interlocked in Iss or stalled in Iss
  always @*
    case (rf_rd_r0_agu_de_i[2:0])
      3'b100  : rf_rd_data_r0_agu_de[3:0] = rf_wr_data_w2_wr_i[3:0];
      3'b010  : rf_rd_data_r0_agu_de[3:0] = rf_wr_data_w1_wr_i[3:0];
      3'b001  : rf_rd_data_r0_agu_de[3:0] = rf_wr_data_w0_wr_i[3:0];
      3'b000  : rf_rd_data_r0_agu_de[3:0] = agu_r0_regbank_de[3:0];
      default : rf_rd_data_r0_agu_de[3:0] = 4'bxxxx;
    endcase

  always @*
    case (rf_rd_r1_agu_de_i[2:0])
      3'b100  : rf_rd_data_r1_agu_de[3:0] = rf_wr_data_w2_wr_i[3:0];
      3'b010  : rf_rd_data_r1_agu_de[3:0] = rf_wr_data_w1_wr_i[3:0];
      3'b001  : rf_rd_data_r1_agu_de[3:0] = rf_wr_data_w0_wr_i[3:0];
      3'b000  : rf_rd_data_r1_agu_de[3:0] = agu_r1_regbank_de[3:0];
      default : rf_rd_data_r1_agu_de[3:0] = 4'bxxxx;
    endcase

  // Enable the registers when moving to Iss or while stalled in Iss and a write to the
  // source operands is happening
  assign en_rf_rd_data_r0_agu_iss = (~ilock_stall_iss_i & ls_valid_de_i & rf_rd_en_r0_de_i) | en_rf_rd_r0_agu_de_i;
  assign en_rf_rd_data_r1_agu_iss = (~ilock_stall_iss_i & ls_valid_de_i & rf_rd_en_r1_de_i) | en_rf_rd_r1_agu_de_i;

  always @(posedge clk)
    if (en_rf_rd_data_r0_agu_iss)
      rf_rd_data_r0_agu_iss[3:0] <= rf_rd_data_r0_agu_de[3:0];

  always @(posedge clk)
    if (en_rf_rd_data_r1_agu_iss)
      rf_rd_data_r1_agu_iss[3:0] <= rf_rd_data_r1_agu_de[3:0];

  // ------------------------------------------------------
  // Output buses
  // ------------------------------------------------------

  assign rf_rd_data_r0_iss_o     = rf_rd_data_r0_iss[63:0];
  assign rf_rd_data_r0_agu_iss_o = {rf_rd_data_r0_iss[63:4], rf_rd_data_r0_agu_iss[3:0]};
  assign rf_rd_data_r1_iss_o     = rf_rd_data_r1_iss[63:0];
  assign rf_rd_data_r1_agu_iss_o = {rf_rd_data_r1_iss[63:4], rf_rd_data_r1_agu_iss[3:0]};
  assign rf_rd_data_r2_iss_o     = rf_rd_data_r2_iss[63:0];
  assign rf_rd_data_r3_iss_o     = rf_rd_data_r3_iss[63:0];
  assign rf_rd_data_r4_iss_o     = rf_rd_data_r4_iss[63:0];

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Register enables should never be X
  //----------------------------------------------------------------------------
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_addr_r0_lo_iss")
  u_ovl_x_en_rf_rd_addr_r0_lo_iss (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (en_rf_rd_addr_r0_lo_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_addr_r0_hi_iss")
  u_ovl_x_en_rf_rd_addr_r0_hi_iss (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (en_rf_rd_addr_r0_hi_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_addr_r1_lo_iss")
  u_ovl_x_en_rf_rd_addr_r1_lo_iss (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (en_rf_rd_addr_r1_lo_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_addr_r1_hi_iss")
  u_ovl_x_en_rf_rd_addr_r1_hi_iss (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (en_rf_rd_addr_r1_hi_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_data_r0_agu_iss")
  u_ovl_x_en_rf_rd_data_r0_agu_iss (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (en_rf_rd_data_r0_agu_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_rf_rd_data_r1_agu_iss")
  u_ovl_x_en_rf_rd_data_r1_agu_iss (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (en_rf_rd_data_r1_agu_iss));

  assert_never_unknown #(`OVL_FATAL, `CA53_LONG_RF_ADDR_W, `OVL_ASSERT, "Register enable x-check: regbank_en_hi")
  u_ovl_x_regbank_en_hi_entry (.clk       (clk_irf_hi),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (regbank_en_hi));

  assert_never_unknown #(`OVL_FATAL, `CA53_LONG_RF_ADDR_W, `OVL_ASSERT, "Register enable x-check: regbank_en_lo")
  u_ovl_x_regbank_en_lo_entry (.clk       (clk_irf_lo),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (regbank_en_lo));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port W0")
  ovl_regbank_write_data_w0_lo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w0_wr_i),
    .test_expr (rf_wr_data_w0_wr_i[31: 0])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port W0")
  ovl_regbank_write_data_w0_hi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w0_wr_i & rf_wr_en_hi_wr_i),
    .test_expr (rf_wr_data_w0_wr_i[63:32])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port w1")
  ovl_regbank_write_data_w1_lo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w1_wr_i),
    .test_expr (rf_wr_data_w1_wr_i[31: 0])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port w1")
  ovl_regbank_write_data_w1_hi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w1_wr_i & rf_wr_en_hi_wr_i),
    .test_expr (rf_wr_data_w1_wr_i[63:32])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port w2")
  ovl_regbank_write_data_w2_lo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w2_wr_i),
    .test_expr (rf_wr_data_w2_wr_i[31: 0])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Writing Xs into the RF port w2")
  ovl_regbank_write_data_w2_hi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (rf_wr_en_w2_wr_i & rf_wr_en_hi_wr_i),
    .test_expr (rf_wr_data_w2_wr_i[63:32])
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_data_w0_wr[63:32] nonzero when rf_wr_64b_w0_wr zero")
  ovl_regbank_32b_write_w0 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w0_wr_i & rf_wr_en_hi_wr_i & ~rf_wr_64b_w0_wr_i),
    .consequent_expr (rf_wr_data_w0_wr_i[63:32] == {32{1'b0}})
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_data_w1_wr[63:32] nonzero when rf_wr_64b_w1_wr zero")
  ovl_regbank_32b_write_w1 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w1_wr_i & rf_wr_en_hi_wr_i & ~rf_wr_64b_w1_wr_i),
    .consequent_expr (rf_wr_data_w1_wr_i[63:32] == {32{1'b0}})
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_data_w2_wr[63:32] nonzero when rf_wr_64b_w2_wr zero")
  ovl_regbank_32b_write_w2 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w2_wr_i & rf_wr_en_hi_wr_i & ~rf_wr_64b_w2_wr_i),
    .consequent_expr (rf_wr_data_w2_wr_i[63:32] == {32{1'b0}})
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_en_w0_wr_i asserted without sel_rf_wr_w0_wr_i")
  ovl_regbank_w0_wr_en_consistent (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w0_wr_i),
    .consequent_expr (sel_rf_wr_w0_wr_i)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_en_w1_wr_i asserted without sel_rf_wr_w1_wr_i")
  ovl_regbank_w1_wr_en_consistent (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w1_wr_i),
    .consequent_expr (sel_rf_wr_w1_wr_i)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_en_w2_wr_i asserted without sel_rf_wr_w2_wr_i")
  ovl_regbank_w2_wr_en_consistent (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w2_wr_i),
    .consequent_expr (sel_rf_wr_w2_wr_i)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rf_wr_en_wx_wr_i asserted without rf_wr_en_lo_wr_i")
  ovl_regbank_wr_en_consistent (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (rf_wr_en_w0_wr_i | rf_wr_en_w1_wr_i | rf_wr_en_w2_wr_i),
    .consequent_expr (rf_wr_en_lo_wr_i)
  );
  // OVL_ASSERT_END


`endif

endmodule // ca53dpu_regbank

/*ARMAUTO_UNDEF*/
`undef CA53_READ_PORT_LO
`undef CA53_READ_PORT_HI
`undef CA53_4BIT_READ_PORT
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
