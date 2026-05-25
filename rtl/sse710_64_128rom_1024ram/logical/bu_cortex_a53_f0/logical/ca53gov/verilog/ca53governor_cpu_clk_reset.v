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
// Description: Clock and reset block
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_clk_reset (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  DFTSE,
  input  wire                                  DFTRSTDISABLE,
  input  wire                                  ncpuporeset,
  input  wire                                  ncorereset,
  input  wire                                  nl2reset_synced_pipelined,
  input  wire                                  nl2reset_synced,
  input  wire                                  nmbistreset_synced_pipelined,
  input  wire                                  nmbistreset_synced,
  input  wire                                  gate_clk_req_i,
  input  wire                                  mbistreq_rs_i,
  // Outputs
  output wire                                  clk_cpu,
  output wire                                  reset_n_cpu,
  output wire                                  reset_n_gov,
  output wire                                  po_reset_n_cpu,
  output wire                                  po_reset_n_gov
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           stop_clk;
  reg           ncpuporeset_pipeline_stage_0;
  reg           ncpuporeset_pipeline_stage_1;
  reg           ncpuporeset_pipeline_stage_2;
  reg           ncpuporeset_synced_pipelined;
  reg           ncorereset_pipeline_stage_0;
  reg           ncorereset_pipeline_stage_1;
  reg           ncorereset_pipeline_stage_2;
  reg           ncorereset_synced_pipelined;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire          clk_enable;
  wire          can_stop_clk;
  wire          ncpuporeset_pipeline_en;
  wire          ncpuporeset_synced;
  wire          ncorereset_pipeline_en;
  wire          ncorereset_synced;
  wire          po_reset_n_gov_clk;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Clock control
  // ------------------------------------------------------

  assign can_stop_clk = gate_clk_req_i & ~mbistreq_rs_i;

  always @(posedge CLKIN or negedge po_reset_n_gov_clk)
    if (~po_reset_n_gov_clk)
      stop_clk <= 1'b1;
    else
      stop_clk <= can_stop_clk;

  assign clk_enable = ~stop_clk;

  ca53_cell_clkgate u_ca53_cell_clkgate (.clk_i         (CLKIN),
                                         .clk_enable_i  (clk_enable),
                                         .clk_senable_i (DFTSE),
                                         .clk_gated_o   (clk_cpu));

  // ------------------------------------------------------
  // Reset control
  // ------------------------------------------------------
  //
  // The synchronisers are only concerned with synchronising the
  // deassertion of reset.
  //
  // After the synchronisers there is a reset pipeline of four
  // registers for each reset which we use to trigger the clock
  // to the CPU.
  //
  // This approach ensures that when a CPU is held in reset the
  // governor logic clocked by the WFI gated clock is gated off.
  // Also the clock to the CPU is turned off while the power
  // domain is being powered-on.

  // CPU power-on reset synchronisation and pipeline
  ca53_cell_sync u_ca53_cell_sync0 (.out_o    (ncpuporeset_synced),
                                    .clk_i    (CLKIN),
                                    .inp_i    (ncpuporeset),
                                    .resetn_i (ncpuporeset));

  assign ncpuporeset_pipeline_en = ~ncpuporeset_synced_pipelined | ~nmbistreset_synced_pipelined | ~nl2reset_synced_pipelined;

  always @(posedge CLKIN or negedge ncpuporeset)
    if (~ncpuporeset) begin
      ncpuporeset_pipeline_stage_0 <= 1'b0;
      ncpuporeset_pipeline_stage_1 <= 1'b0;
      ncpuporeset_pipeline_stage_2 <= 1'b0;
      ncpuporeset_synced_pipelined <= 1'b0;
    end
    else if (ncpuporeset_pipeline_en) begin
      ncpuporeset_pipeline_stage_0 <= ncpuporeset_synced;
      ncpuporeset_pipeline_stage_1 <= ncpuporeset_pipeline_stage_0;
      ncpuporeset_pipeline_stage_2 <= ncpuporeset_pipeline_stage_1;
      ncpuporeset_synced_pipelined <= ncpuporeset_pipeline_stage_2;
    end

  // Core reset synchronisation and pipeline
  ca53_cell_sync u_ca53_cell_sync1 (.out_o    (ncorereset_synced),
                                    .clk_i    (CLKIN),
                                    .inp_i    (ncorereset),
                                    .resetn_i (ncorereset));

  assign ncorereset_pipeline_en = ~ncorereset_synced_pipelined | ~ncpuporeset_synced_pipelined | ~nmbistreset_synced_pipelined | ~nl2reset_synced_pipelined;

  always @(posedge CLKIN or negedge ncorereset)
    if (~ncorereset) begin
      ncorereset_pipeline_stage_0 <= 1'b0;
      ncorereset_pipeline_stage_1 <= 1'b0;
      ncorereset_pipeline_stage_2 <= 1'b0;
      ncorereset_synced_pipelined <= 1'b0;
    end
    else if (ncorereset_pipeline_en) begin
      ncorereset_pipeline_stage_0 <= ncorereset_synced;
      ncorereset_pipeline_stage_1 <= ncorereset_pipeline_stage_0;
      ncorereset_pipeline_stage_2 <= ncorereset_pipeline_stage_1;
      ncorereset_synced_pipelined <= ncorereset_pipeline_stage_2;
    end

  // ------------------------------------------------------
  // Reset generation
  // ------------------------------------------------------

  // Primary reset for the CPU
  assign reset_n_cpu    = DFTRSTDISABLE | (ncpuporeset_synced_pipelined & nmbistreset_synced_pipelined & ncorereset_synced_pipelined);

  // Primary reset for the governor that includes the L2 reset to prevent 'x' generation
  assign reset_n_gov    = DFTRSTDISABLE | (ncpuporeset_synced_pipelined & nmbistreset_synced_pipelined & ncorereset_synced_pipelined  & nl2reset_synced_pipelined);

  // Power-on reset for the governor clock block that includes the L2 reset to prevent 'x' generation, but uses
  // non-pipelined resets to bring the clock back earlier.  Power-on reset must be used to allow the clock to
  // continue on a warm reset so that debug can remain active.
  assign po_reset_n_gov_clk = DFTRSTDISABLE | (ncpuporeset_synced           & nmbistreset_synced                                      & nl2reset_synced);

  // Power-on reset for the CPU
  assign po_reset_n_cpu = DFTRSTDISABLE | (ncpuporeset_synced_pipelined & nmbistreset_synced_pipelined);

  // Power-on reset for the governor that includes the L2 reset to prevent 'x' generation
  assign po_reset_n_gov = DFTRSTDISABLE | (ncpuporeset_synced_pipelined & nmbistreset_synced_pipelined                                & nl2reset_synced_pipelined);

endmodule // ca53governor_cpu_clk_reset

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
