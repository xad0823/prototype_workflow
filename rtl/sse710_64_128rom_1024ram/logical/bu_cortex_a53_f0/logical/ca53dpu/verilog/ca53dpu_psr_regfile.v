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
// Abstract : Programming Status Registers for the Integer Core
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_psr_regfile (
  // Inputs
  input  wire                         clk,
  input  wire                         reset_n,
  input  wire                         DFTSE,
  input  wire                         spsr_regfile_en_wr_i,
  input  wire                         cpsr_regfile_en_wr_i,
  input  wire                         dspsr_regfile_en_wr_i,
  input  wire                   [3:0] spsr_regfile_mask_wr_i,
  input  wire                         spsr_clock_en_ex2_i,
  input  wire                         insert_forceop_ret_i,
  input  wire                         in_halt_i,
  input  wire                   [3:0] msr_mrs_data_wr_i,
  input  wire  [`CA53_SPSR_RET_W-1:0] nxt_spsr_ret_i,
  input  wire  [`CA53_CPSR_RET_W-1:0] nxt_cpsr_ret_i,
  input  wire  [`CA53_CPSR_RET_W-1:0] nxt_dspsr_ret_i,
  // Outputs
  output wire  [`CA53_SPSR_RET_W-1:0] spsr_ret_reg_o,
  output wire  [`CA53_CPSR_RET_W-1:0] cpsr_ret_reg_o,
  output wire  [`CA53_CPSR_RET_W-1:0] dspsr_ret_reg_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [`CA53_SPSR_RET_W-1:0] spsr_ret_reg;
  reg  [`CA53_SPSR_RET_W-1:0] spsr_virtual_reg;
  reg                   [4:0] spsr_svc_nzcvq;
  reg                   [1:0] spsr_svc_it_low;
  reg                         spsr_svc_ss;
  reg                         spsr_svc_il;
  reg                   [3:0] spsr_svc_ge;
  reg                   [5:0] spsr_svc_it_high;
  reg                         spsr_svc_de;
  reg                         spsr_svc_a;
  reg                         spsr_svc_i;
  reg                         spsr_svc_f;
  reg                         spsr_svc_t;
  reg                   [4:0] spsr_svc_m;
  reg                   [4:0] spsr_abt_nzcvq;
  reg                   [1:0] spsr_abt_it_low;
  reg                         spsr_abt_il;
  reg                   [3:0] spsr_abt_ge;
  reg                   [5:0] spsr_abt_it_high;
  reg                         spsr_abt_de;
  reg                         spsr_abt_a;
  reg                         spsr_abt_i;
  reg                         spsr_abt_f;
  reg                         spsr_abt_t;
  reg                   [4:0] spsr_abt_m;
  reg                   [4:0] spsr_und_nzcvq;
  reg                   [1:0] spsr_und_it_low;
  reg                         spsr_und_il;
  reg                   [3:0] spsr_und_ge;
  reg                   [5:0] spsr_und_it_high;
  reg                         spsr_und_de;
  reg                         spsr_und_a;
  reg                         spsr_und_i;
  reg                         spsr_und_f;
  reg                         spsr_und_t;
  reg                   [4:0] spsr_und_m;
  reg                   [4:0] spsr_irq_nzcvq;
  reg                   [1:0] spsr_irq_it_low;
  reg                         spsr_irq_il;
  reg                   [3:0] spsr_irq_ge;
  reg                   [5:0] spsr_irq_it_high;
  reg                         spsr_irq_de;
  reg                         spsr_irq_a;
  reg                         spsr_irq_i;
  reg                         spsr_irq_f;
  reg                         spsr_irq_t;
  reg                   [4:0] spsr_irq_m;
  reg                   [4:0] spsr_fiq_nzcvq;
  reg                   [1:0] spsr_fiq_it_low;
  reg                         spsr_fiq_il;
  reg                   [3:0] spsr_fiq_ge;
  reg                   [5:0] spsr_fiq_it_high;
  reg                         spsr_fiq_de;
  reg                         spsr_fiq_a;
  reg                         spsr_fiq_i;
  reg                         spsr_fiq_f;
  reg                         spsr_fiq_t;
  reg                   [4:0] spsr_fiq_m;
  reg                   [4:0] spsr_mon_nzcvq;
  reg                   [1:0] spsr_mon_it_low;
  reg                         spsr_mon_ss;
  reg                         spsr_mon_il;
  reg                   [3:0] spsr_mon_ge;
  reg                   [5:0] spsr_mon_it_high;
  reg                         spsr_mon_de;
  reg                         spsr_mon_a;
  reg                         spsr_mon_i;
  reg                         spsr_mon_f;
  reg                         spsr_mon_t;
  reg                   [4:0] spsr_mon_m;
  reg                   [4:0] spsr_hyp_nzcvq;
  reg                   [1:0] spsr_hyp_it_low;
  reg                         spsr_hyp_ss;
  reg                         spsr_hyp_il;
  reg                   [3:0] spsr_hyp_ge;
  reg                   [5:0] spsr_hyp_it_high;
  reg                         spsr_hyp_de;
  reg                         spsr_hyp_a;
  reg                         spsr_hyp_i;
  reg                         spsr_hyp_f;
  reg                         spsr_hyp_t;
  reg                   [4:0] spsr_hyp_m;
  reg  [`CA53_CPSR_RET_W-1:0] cpsr_ret;
  reg                         psr_svc_sel_ret;
  reg                         psr_abt_sel_ret;
  reg                         psr_und_sel_ret;
  reg                         psr_irq_sel_ret;
  reg                         psr_fiq_sel_ret;
  reg                         psr_mon_sel_ret;
  reg                         psr_hyp_sel_ret;
  reg  [`CA53_CPSR_RET_W-1:0] dspsr_ret_reg;
  reg                         spsr_clock_en_wr;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [`CA53_SPSR_RET_W-1:0] spsr_svc;
  wire [`CA53_SPSR_RET_W-1:0] spsr_abt;
  wire [`CA53_SPSR_RET_W-1:0] spsr_und;
  wire [`CA53_SPSR_RET_W-1:0] spsr_irq;
  wire [`CA53_SPSR_RET_W-1:0] spsr_fiq;
  wire [`CA53_SPSR_RET_W-1:0] spsr_mon;
  wire [`CA53_SPSR_RET_W-1:0] spsr_hyp;
  wire                  [6:0] cpsr_sel_ret;
  wire                        psr_svc_sel_wr;
  wire                        psr_abt_sel_wr;
  wire                        psr_und_sel_wr;
  wire                        psr_irq_sel_wr;
  wire                        psr_fiq_sel_wr;
  wire                        psr_mon_sel_wr;
  wire                        psr_hyp_sel_wr;
  wire                        spsr_svc_wr_en_wr;
  wire                        spsr_abt_wr_en_wr;
  wire                        spsr_und_wr_en_wr;
  wire                        spsr_irq_wr_en_wr;
  wire                        spsr_fiq_wr_en_wr;
  wire                        spsr_mon_wr_en_wr;
  wire                        spsr_hyp_wr_en_wr;
  wire                  [3:0] spsr_svc_mask;
  wire                  [3:0] spsr_abt_mask;
  wire                  [3:0] spsr_und_mask;
  wire                  [3:0] spsr_irq_mask;
  wire                  [3:0] spsr_fiq_mask;
  wire                  [3:0] spsr_mon_mask;
  wire                  [3:0] spsr_hyp_mask;
  wire                        clk_spsr;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      spsr_clock_en_wr <= 1'b1;
    else
      spsr_clock_en_wr <= spsr_clock_en_ex2_i;

  ca53_cell_inter_clkgate u_inter_clkgate_spsr_regfile (
    .clk_i         (clk),
    .clk_enable_i  (spsr_clock_en_wr),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_spsr)
  );

  // ------------------------------------------------------
  // Generate selects
  // ------------------------------------------------------
  // 
  // The AArch64 SPSR_EL1, SPSR_EL2 and SPSR_EL3 map on to AArch32 SPSR_svc, SPSR_hyp and SPSR_mon respectively
  assign psr_abt_sel_wr =  nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_ABT;
  assign psr_und_sel_wr =  nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_UND;
  assign psr_irq_sel_wr =  nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_IRQ;
  assign psr_fiq_sel_wr =  nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_FIQ;
  assign psr_svc_sel_wr = (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_SVC)  |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL1T) |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL1H);
  assign psr_hyp_sel_wr = (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_HYP)  |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL2T) |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL2H);
  assign psr_mon_sel_wr = (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_MON)  |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL3T) |
                          (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL3H);

  // ------------------------------------------------------
  // SPSR register write
  // ------------------------------------------------------
  //
  assign spsr_svc_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_SVC) : psr_svc_sel_wr);
  assign spsr_abt_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_ABT) : psr_abt_sel_wr);
  assign spsr_und_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_UND) : psr_und_sel_wr);
  assign spsr_irq_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_IRQ) : psr_irq_sel_wr);
  assign spsr_fiq_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_FIQ) : psr_fiq_sel_wr);
  assign spsr_mon_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_MON) : psr_mon_sel_wr);
  assign spsr_hyp_wr_en_wr = spsr_regfile_en_wr_i & ((msr_mrs_data_wr_i[3] & ~insert_forceop_ret_i) ? (msr_mrs_data_wr_i[2:0] == `CA53_SPSR_HYP) : psr_hyp_sel_wr);

  // SPSR register file enables for each 8-bit portion
  assign spsr_svc_mask = {4{spsr_svc_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_abt_mask = {4{spsr_abt_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_und_mask = {4{spsr_und_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_irq_mask = {4{spsr_irq_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_fiq_mask = {4{spsr_fiq_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_mon_mask = {4{spsr_mon_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];
  assign spsr_hyp_mask = {4{spsr_hyp_wr_en_wr}} & spsr_regfile_mask_wr_i[3:0];

  // SPSR_svc/SPSR_EL1
  always @(posedge clk_spsr)
    if (spsr_svc_mask[3]) begin
      spsr_svc_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_svc_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_svc_mask[2]) begin
      spsr_svc_ss      <= nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS];
      spsr_svc_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_svc_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_svc_mask[1]) begin
      spsr_svc_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_svc_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_svc_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_svc_mask[0]) begin
      spsr_svc_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_svc_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_svc_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_svc_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_svc[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_svc_nzcvq;
  assign spsr_svc[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_svc_it_low;
  assign spsr_svc[`CA53_SPSR_RET_SS_BITS]      = spsr_svc_ss;
  assign spsr_svc[`CA53_SPSR_RET_IL_BITS]      = spsr_svc_il;
  assign spsr_svc[`CA53_SPSR_RET_GE_BITS]      = spsr_svc_ge;
  assign spsr_svc[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_svc_it_high;
  assign spsr_svc[`CA53_SPSR_RET_E_BITS]       = spsr_svc_de;
  assign spsr_svc[`CA53_SPSR_RET_A_BITS]       = spsr_svc_a;
  assign spsr_svc[`CA53_SPSR_RET_I_BITS]       = spsr_svc_i;
  assign spsr_svc[`CA53_SPSR_RET_F_BITS]       = spsr_svc_f;
  assign spsr_svc[`CA53_SPSR_RET_T_BITS]       = spsr_svc_t;
  assign spsr_svc[`CA53_SPSR_RET_MODE_BITS]    = spsr_svc_m;

  // SPSR_abt
  always @(posedge clk_spsr)
    if (spsr_abt_mask[3]) begin
      spsr_abt_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_abt_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_abt_mask[2]) begin
      spsr_abt_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_abt_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_abt_mask[1]) begin
      spsr_abt_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_abt_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_abt_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_abt_mask[0]) begin
      spsr_abt_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_abt_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_abt_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_abt_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_abt[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_abt_nzcvq;
  assign spsr_abt[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_abt_it_low;
  assign spsr_abt[`CA53_SPSR_RET_SS_BITS]      = 1'b0;
  assign spsr_abt[`CA53_SPSR_RET_IL_BITS]      = spsr_abt_il;
  assign spsr_abt[`CA53_SPSR_RET_GE_BITS]      = spsr_abt_ge;
  assign spsr_abt[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_abt_it_high;
  assign spsr_abt[`CA53_SPSR_RET_E_BITS]       = spsr_abt_de;
  assign spsr_abt[`CA53_SPSR_RET_A_BITS]       = spsr_abt_a;
  assign spsr_abt[`CA53_SPSR_RET_I_BITS]       = spsr_abt_i;
  assign spsr_abt[`CA53_SPSR_RET_F_BITS]       = spsr_abt_f;
  assign spsr_abt[`CA53_SPSR_RET_T_BITS]       = spsr_abt_t;
  assign spsr_abt[`CA53_SPSR_RET_MODE_BITS]    = spsr_abt_m;

  // SPSR_und
  always @(posedge clk_spsr)
    if (spsr_und_mask[3]) begin
      spsr_und_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_und_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_und_mask[2]) begin
      spsr_und_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_und_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_und_mask[1]) begin
      spsr_und_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_und_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_und_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_und_mask[0]) begin
      spsr_und_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_und_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_und_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_und_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_und[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_und_nzcvq;
  assign spsr_und[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_und_it_low;
  assign spsr_und[`CA53_SPSR_RET_SS_BITS]      = 1'b0;
  assign spsr_und[`CA53_SPSR_RET_IL_BITS]      = spsr_und_il;
  assign spsr_und[`CA53_SPSR_RET_GE_BITS]      = spsr_und_ge;
  assign spsr_und[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_und_it_high;
  assign spsr_und[`CA53_SPSR_RET_E_BITS]       = spsr_und_de;
  assign spsr_und[`CA53_SPSR_RET_A_BITS]       = spsr_und_a;
  assign spsr_und[`CA53_SPSR_RET_I_BITS]       = spsr_und_i;
  assign spsr_und[`CA53_SPSR_RET_F_BITS]       = spsr_und_f;
  assign spsr_und[`CA53_SPSR_RET_T_BITS]       = spsr_und_t;
  assign spsr_und[`CA53_SPSR_RET_MODE_BITS]    = spsr_und_m;

  // SPSR_irq
  always @(posedge clk_spsr)
    if (spsr_irq_mask[3]) begin
      spsr_irq_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_irq_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_irq_mask[2]) begin
      spsr_irq_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_irq_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_irq_mask[1]) begin
      spsr_irq_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_irq_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_irq_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_irq_mask[0]) begin
      spsr_irq_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_irq_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_irq_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_irq_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_irq[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_irq_nzcvq;
  assign spsr_irq[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_irq_it_low;
  assign spsr_irq[`CA53_SPSR_RET_SS_BITS]      = 1'b0;
  assign spsr_irq[`CA53_SPSR_RET_IL_BITS]      = spsr_irq_il;
  assign spsr_irq[`CA53_SPSR_RET_GE_BITS]      = spsr_irq_ge;
  assign spsr_irq[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_irq_it_high;
  assign spsr_irq[`CA53_SPSR_RET_E_BITS]       = spsr_irq_de;
  assign spsr_irq[`CA53_SPSR_RET_A_BITS]       = spsr_irq_a;
  assign spsr_irq[`CA53_SPSR_RET_I_BITS]       = spsr_irq_i;
  assign spsr_irq[`CA53_SPSR_RET_F_BITS]       = spsr_irq_f;
  assign spsr_irq[`CA53_SPSR_RET_T_BITS]       = spsr_irq_t;
  assign spsr_irq[`CA53_SPSR_RET_MODE_BITS]    = spsr_irq_m;

  // SPSR_fiq
  always @(posedge clk_spsr)
    if (spsr_fiq_mask[3]) begin
      spsr_fiq_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_fiq_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_fiq_mask[2]) begin
      spsr_fiq_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_fiq_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_fiq_mask[1]) begin
      spsr_fiq_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_fiq_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_fiq_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_fiq_mask[0]) begin
      spsr_fiq_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_fiq_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_fiq_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_fiq_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_fiq[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_fiq_nzcvq;
  assign spsr_fiq[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_fiq_it_low;
  assign spsr_fiq[`CA53_SPSR_RET_SS_BITS]      = 1'b0;
  assign spsr_fiq[`CA53_SPSR_RET_IL_BITS]      = spsr_fiq_il;
  assign spsr_fiq[`CA53_SPSR_RET_GE_BITS]      = spsr_fiq_ge;
  assign spsr_fiq[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_fiq_it_high;
  assign spsr_fiq[`CA53_SPSR_RET_E_BITS]       = spsr_fiq_de;
  assign spsr_fiq[`CA53_SPSR_RET_A_BITS]       = spsr_fiq_a;
  assign spsr_fiq[`CA53_SPSR_RET_I_BITS]       = spsr_fiq_i;
  assign spsr_fiq[`CA53_SPSR_RET_F_BITS]       = spsr_fiq_f;
  assign spsr_fiq[`CA53_SPSR_RET_T_BITS]       = spsr_fiq_t;
  assign spsr_fiq[`CA53_SPSR_RET_MODE_BITS]    = spsr_fiq_m;

  // SPSR_mon/SPSR_EL3
  always @(posedge clk_spsr)
    if (spsr_mon_mask[3]) begin
      spsr_mon_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_mon_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_mon_mask[2]) begin
      spsr_mon_ss      <= nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS];
      spsr_mon_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_mon_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_mon_mask[1]) begin
      spsr_mon_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_mon_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_mon_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_mon_mask[0]) begin
      spsr_mon_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_mon_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_mon_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_mon_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_mon[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_mon_nzcvq;
  assign spsr_mon[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_mon_it_low;
  assign spsr_mon[`CA53_SPSR_RET_SS_BITS]      = spsr_mon_ss;
  assign spsr_mon[`CA53_SPSR_RET_IL_BITS]      = spsr_mon_il;
  assign spsr_mon[`CA53_SPSR_RET_GE_BITS]      = spsr_mon_ge;
  assign spsr_mon[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_mon_it_high;
  assign spsr_mon[`CA53_SPSR_RET_E_BITS]       = spsr_mon_de;
  assign spsr_mon[`CA53_SPSR_RET_A_BITS]       = spsr_mon_a;
  assign spsr_mon[`CA53_SPSR_RET_I_BITS]       = spsr_mon_i;
  assign spsr_mon[`CA53_SPSR_RET_F_BITS]       = spsr_mon_f;
  assign spsr_mon[`CA53_SPSR_RET_T_BITS]       = spsr_mon_t;
  assign spsr_mon[`CA53_SPSR_RET_MODE_BITS]    = spsr_mon_m;

  // SPSR_hyp/SPSR_EL2
  always @(posedge clk_spsr)
    if (spsr_hyp_mask[3]) begin
      spsr_hyp_nzcvq   <= nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS];
      spsr_hyp_it_low  <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_hyp_mask[2]) begin
      spsr_hyp_ss      <= nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS];
      spsr_hyp_il      <= nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS];
      spsr_hyp_ge      <= nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_hyp_mask[1]) begin
      spsr_hyp_it_high <= nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS];
      spsr_hyp_de      <= nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS];
      spsr_hyp_a       <= nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS];
    end

  always @(posedge clk_spsr)
    if (spsr_hyp_mask[0]) begin
      spsr_hyp_i      <= nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS];
      spsr_hyp_f      <= nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS];
      spsr_hyp_t      <= nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS];
      spsr_hyp_m      <= nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS];
    end

  assign spsr_hyp[`CA53_SPSR_RET_NZCVQ_BITS]   = spsr_hyp_nzcvq;
  assign spsr_hyp[`CA53_SPSR_RET_IT_LOW_BITS]  = spsr_hyp_it_low;
  assign spsr_hyp[`CA53_SPSR_RET_SS_BITS]      = spsr_hyp_ss;
  assign spsr_hyp[`CA53_SPSR_RET_IL_BITS]      = spsr_hyp_il;
  assign spsr_hyp[`CA53_SPSR_RET_GE_BITS]      = spsr_hyp_ge;
  assign spsr_hyp[`CA53_SPSR_RET_IT_HICM_BITS] = spsr_hyp_it_high;
  assign spsr_hyp[`CA53_SPSR_RET_E_BITS]       = spsr_hyp_de;
  assign spsr_hyp[`CA53_SPSR_RET_A_BITS]       = spsr_hyp_a;
  assign spsr_hyp[`CA53_SPSR_RET_I_BITS]       = spsr_hyp_i;
  assign spsr_hyp[`CA53_SPSR_RET_F_BITS]       = spsr_hyp_f;
  assign spsr_hyp[`CA53_SPSR_RET_T_BITS]       = spsr_hyp_t;
  assign spsr_hyp[`CA53_SPSR_RET_MODE_BITS]    = spsr_hyp_m;

  // ------------------------------------------------------
  // CPSR register write
  // ------------------------------------------------------
  //
  // The CPSR Retire stage value implemented is a 28-bit value.
  // The encoding for these 28-bits is as follows:
  //
  // |2             2| 2   |2   2| 2  | 2  |1     1|1     1| | | | | |         |
  // |8-------------5| 4   |3---2| 1  | 0  |9-----6|5-----0|9|8|7|6|5|4-------0|
  // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+----+----+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  // |               |     | IT  |    |    |       |IT[7:2]| | | | | |         |
  // |{N,Z,C,V}      |  Q  |[1:0]| SS | IL |  GE   |cond,  |E|A|I|F|T|M|M|M|M|M|
  // |CC_flags       | bit |     |    |    |[3:0]  |mask[3:| | | | | |4|3|2|1|0|
  // |               |     |     |    |    |       |     2]| | | | | | | | | | |
  // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+----+----+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  //
  // Actual ARM CPSR format.
  //
  // |31          28 |27| 26  25| 24|23 22| 21 | 20 |19     16|15     10|9|8|7|6|5|4       0
  // +---------------+--+-------+---+-----+----+----+---------+---------+-+-+-+-+-+---------+
  // |               |  |       |   |     |    |    |         |         | | | | | |         |
  // | {N,Z,C,V}     |Q |IT[1:0]| J | RES | SS | IL |GE[3:0]  |IT[7:2]  |E|A|I|F|T|Mode[4:0]|
  // |               |  |mask   |   |     |    |    |         |(cond,   | | | | | |         |
  // |               |  |[1:0]  |   |     |    |    |         |mask[3:2]| | | | | |         |
  // |               |  |       |   |     |    |    |         |         | | | | | |         |
  // +---------------+--+-------+---+-----+----+----+---------+---------+-+-+-+-+-+---------+

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      cpsr_ret        <= {4'b0000,            // Clear flags
                          1'b0,               // Q bit
                          2'b00,              // IT
                          1'b0,               // SS
                          1'b0,               // IL
                          4'b0000,            // GE
                          6'b00_0000,         // IT
                          1'b0,               // E bit (initialised by reset forceop)
                          1'b1,               // Set A bit
                          1'b1,               // Set I bit
                          1'b1,               // Set F bit
                          1'b0,               // T bit (initialised by reset forceop)
                          `CA53_FULL_MODE_EL3H}; // SVC mode after reset
      psr_svc_sel_ret <= 1'b0;
      psr_abt_sel_ret <= 1'b0;
      psr_und_sel_ret <= 1'b0;
      psr_irq_sel_ret <= 1'b0;
      psr_fiq_sel_ret <= 1'b0;
      psr_mon_sel_ret <= 1'b0;
      psr_hyp_sel_ret <= 1'b0;
    end else if (cpsr_regfile_en_wr_i) begin
      cpsr_ret        <= nxt_cpsr_ret_i;
      psr_svc_sel_ret <= psr_svc_sel_wr;
      psr_abt_sel_ret <= psr_abt_sel_wr;
      psr_und_sel_ret <= psr_und_sel_wr;
      psr_irq_sel_ret <= psr_irq_sel_wr;
      psr_fiq_sel_ret <= psr_fiq_sel_wr;
      psr_mon_sel_ret <= psr_mon_sel_wr;
      psr_hyp_sel_ret <= psr_hyp_sel_wr;
    end

  // ------------------------------------------------------
  // PSR read ports
  // ------------------------------------------------------

  // A read of the SPSR in user/system modes will return the current CPSR value
  assign cpsr_sel_ret[6:0] = {psr_svc_sel_ret,
                              psr_abt_sel_ret,
                              psr_und_sel_ret,
                              psr_irq_sel_ret,
                              psr_fiq_sel_ret,
                              psr_mon_sel_ret,
                              psr_hyp_sel_ret};

  always @*
    case (cpsr_sel_ret[6:0])
      7'b1000000 : spsr_ret_reg = spsr_svc;
      7'b0100000 : spsr_ret_reg = spsr_abt;
      7'b0010000 : spsr_ret_reg = spsr_und;
      7'b0001000 : spsr_ret_reg = spsr_irq;
      7'b0000100 : spsr_ret_reg = spsr_fiq;
      7'b0000010 : spsr_ret_reg = spsr_mon;
      7'b0000001 : spsr_ret_reg = spsr_hyp;
      7'b0000000 : spsr_ret_reg = cpsr_ret;
      default    : spsr_ret_reg = {`CA53_SPSR_RET_W{1'bx}};
    endcase

  always @*
    case (msr_mrs_data_wr_i[2:0]) // The new MSR/MRS encoding for SPSR
      `CA53_SPSR_FIQ    : spsr_virtual_reg = spsr_fiq;
      `CA53_SPSR_IRQ    : spsr_virtual_reg = spsr_irq;
      `CA53_SPSR_SVC    : spsr_virtual_reg = spsr_svc;
      `CA53_SPSR_ABT    : spsr_virtual_reg = spsr_abt;
      `CA53_SPSR_UND    : spsr_virtual_reg = spsr_und;
      `CA53_SPSR_MON    : spsr_virtual_reg = spsr_mon;
      `CA53_SPSR_HYP    : spsr_virtual_reg = spsr_hyp;
      `CA53_SPSR_CRNT   : spsr_virtual_reg = cpsr_ret;
      default           : spsr_virtual_reg = {`CA53_SPSR_RET_W{1'bx}};
    endcase

  assign spsr_ret_reg_o = msr_mrs_data_wr_i[3] ? spsr_virtual_reg
                                               : spsr_ret_reg;

  assign cpsr_ret_reg_o = cpsr_ret;

  // ------------------------------------------------------
  // DSPSR register write
  // ------------------------------------------------------

  always @(posedge clk)
    if (dspsr_regfile_en_wr_i)
      dspsr_ret_reg <= nxt_dspsr_ret_i;

  assign dspsr_ret_reg_o = dspsr_ret_reg;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dspsr_regfile_en_wr_i")
  u_ovl_x_dspsr_regfile_en_wr_i (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (dspsr_regfile_en_wr_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpsr_regfile_en_wr_i")
  u_ovl_x_psr_regfile_w1_en_wr_i (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (cpsr_regfile_en_wr_i));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_abt_mask")
  u_ovl_x_spsr_abt_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_abt_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_fiq_mask")
  u_ovl_x_spsr_fiq_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_fiq_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_hyp_mask")
  u_ovl_x_spsr_hyp_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_hyp_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_irq_mask")
  u_ovl_x_spsr_irq_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_irq_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_mon_mask")
  u_ovl_x_spsr_mon_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_mon_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_svc_mask")
  u_ovl_x_spsr_svc_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_svc_mask)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: spsr_und_mask")
  u_ovl_x_spsr_und_mask (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (spsr_und_mask)
  );

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, `CA53_SPSR_RET_W, `OVL_ASSERT, "Writing Xs into the SPSR")
  ovl_regbank_write_data_spsr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (spsr_regfile_en_wr_i),
    .test_expr (nxt_spsr_ret_i)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, `CA53_CPSR_RET_W, `OVL_ASSERT, "Writing Xs into the CPSR")
  ovl_regbank_write_data_cpsr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cpsr_regfile_en_wr_i),
    .test_expr (nxt_cpsr_ret_i)
  );
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, `CA53_CPSR_RET_W, `OVL_ASSERT, "Writing Xs into the DSPSR")
  ovl_regbank_write_data_dspsr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dspsr_regfile_en_wr_i),
    .test_expr (nxt_dspsr_ret_i)
  );
  // OVL_ASSERT_END


  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_ill_mode_cpsr
  // Check that the mode encoding doesn't take an illegal value (it should
  // have already been translated into some value value before reaching this
  // logic)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Illegal mode encoding for CPSR access")
    ovl_ill_mode_cpsr (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (cpsr_regfile_en_wr_i),
                       .consequent_expr ((nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_USR)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_FIQ)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_IRQ)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_SVC)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_ABT)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_UND)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_SYS)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_MON)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_HYP)  |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL0T) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL1T) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL1H) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL2T) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL2H) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL3T) |
                                         (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] == `CA53_FULL_MODE_EL3H)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.1.b SPSR_mon register can only be modified, or used
  // internally by the Secure Monitor mode or an MSR instruction.
  // OVL_ASSERT: ovl_tz_spsr_mon_access
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"SPSR_mon register can only be modified in EL3")
    ovl_tz_spsr_mon_access (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (psr_mon_sel_wr & spsr_regfile_en_wr_i &
                                        (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] != `CA53_FULL_MODE_MON) &
                                        (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] != `CA53_FULL_MODE_EL3T) &
                                        (nxt_cpsr_ret_i[`CA53_CPSR_RET_MODE_BITS] != `CA53_FULL_MODE_EL3H) &
                                        ~msr_mrs_data_wr_i[3]));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_psr_regfile

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
