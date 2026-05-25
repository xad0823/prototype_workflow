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
//      Checked In          : $Date: 2014-07-03 13:38:42 +0100 (Thu, 03 Jul 2014) $
//
//      Revision            : $Revision: 283912 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Register slice global inputs and outputs
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_slice `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  DFTSE,
  input  wire                                  DFTRSTDISABLE,
  input  wire                                  nl2reset,
  input  wire                                  nmbistreset,
  input  wire                                  npresetdbg,
  input  wire [  7: 0]                         clusteridaff1_i,
  input  wire [  7: 0]                         clusteridaff2_i,
  input  wire [ 39:18]                         periphbase_i,
  input  wire                                  giccdisable_i,
  input  wire                                  clrexmonreq_i,
  input  wire [ 63: 0]                         cntvalueb_i,
  input  wire                                  cntclken_i,
  input  wire [ 63: 0]                         tsvalueb_i,
  input  wire                                  atclken_i,
  input  wire                                  eventi_i,
  input  wire [(NUM_CPUS-1):0]                 sev_req_rs_i,
  input  wire [(NUM_CPUS-1):0]                 gov_standbywfi_i,
  input  wire [(NUM_CPUS-1):0]                 gov_standbywfe_i,
  input  wire [ 39:12]                         dbgromaddr_i,
  input  wire                                  dbgromaddrv_i,
  input  wire [(NUM_CPUS-1):0]                 valid_l2_en_i,
  input  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_gov_wdata_rs_i,
  input  wire [(`CA53_GOV_CPADDR_PKDED_W-1):0] cp_gov_addr_rs_i,
  input  wire [(NUM_CPUS-1):0]                 cp_gov_wenable_rs_i,
  input  wire                                  scu_axierr_i,
  input  wire                                  scu_eccerr_i,
  input  wire                                  scu_l2ecc_valid_i,
  input  wire                                  scu_l2ecc_fatal_i,
  input  wire [  1: 0]                         scu_l2ecc_ramid_i,
  input  wire [  3: 0]                         scu_l2ecc_cpuid_way_i,
  input  wire [ 14: 0]                         scu_l2ecc_index_i,
  input  wire                                  mbistreq_i,
  input  wire                                  scu_mbistack0_i,
  input  wire                                  scu_mbistack1_i,
  input  wire [(`CA53_MBIST0_ADDR_W-1): 0]     mbistaddr0_i,
  input  wire [(`CA53_MBIST1_ADDR_W-1): 0]     mbistaddr1_i,
  input  wire [(`CA53_MBIST0_DATA_W-1): 0]     mbistindata0_i,
  input  wire [(`CA53_MBIST1_DATA_W-1): 0]     mbistindata1_i,
  input  wire [(`CA53_MBIST0_DATA_W-1): 0]     scu_mbistoutdata0_i,
  input  wire [(`CA53_MBIST1_DATA_W-1): 0]     scu_mbistoutdata1_i,
  input  wire                                  mbistwriteen0_i,
  input  wire                                  mbistwriteen1_i,
  input  wire                                  mbistreaden0_i,
  input  wire                                  mbistreaden1_i,
  input  wire [(`CA53_MBIST0_RAMARRAY_W-1): 0] mbistarray0_i,
  input  wire [(`CA53_MBIST1_RAMARRAY_W-1): 0] mbistarray1_i,
  input  wire [(`CA53_MBIST0_BE_W-1): 0]       mbistbe0_i,
  input  wire [(`CA53_MBIST1_BE_W-1): 0]       mbistbe1_i,
  input  wire                                  mbistcfg0_i,
  input  wire                                  mbistcfg1_i,
  // Outputs
  output wire                                  nl2reset_synced_pipelined,
  output wire                                  nl2reset_synced,
  output wire                                  nmbistreset_synced_pipelined,
  output wire                                  nmbistreset_synced,
  output wire                                  reset_n_arb,
  output wire                                  npresetdbg_gov,
  output wire [ 63: 0]                         cntvalueb_rs_o,
  output wire [ 63: 0]                         tsvalueb_rs_o,
  output reg  [  7: 0]                         clusteridaff1_rs_o,
  output reg  [  7: 0]                         clusteridaff2_rs_o,
  output reg  [ 39:18]                         gov_periphbase_o,
  output reg                                   gov_giccdisable_o,
  output wire                                  clrexmon_rs_o,
  output reg                                   clrexmonack_o,
  output wire                                  eventi_rs_o,
  output reg                                   evento_o,
  output reg  [(NUM_CPUS-1):0]                 standbywfi_o,
  output reg  [(NUM_CPUS-1):0]                 standbywfe_o,
  output reg  [ 39:12]                         gov_dbgromaddr_o,
  output reg                                   gov_dbgromaddrv_o,
  output wire                                  gov_enable_writeevict_o,
  output wire                                  gov_disable_evict_o,
  output wire [  1: 0]                         gov_l2victim_ctl_o,
  output wire                                  gov_l2deien_o,
  output wire                                  gov_l2teien_o,
  output wire [  2: 0]                         cp_l2ectlr_ret_delay_o,
  output wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_l2_rdata_o,
  output reg                                   gov_clear_axierr_o,
  output reg                                   gov_clear_eccerr_o,
  output wire                                  evnt_scu_err_o,
  output wire                                  evnt_l2_err_o,
  output reg                                   mbistreq_rs_o,
  output reg                                   mbistack0_o,
  output reg                                   mbistack1_o,
  output reg  [(`CA53_MBIST0_ADDR_W-1): 0]     gov_mbistaddr0_o,
  output reg  [(`CA53_MBIST1_ADDR_W-1): 0]     gov_mbistaddr1_o,
  output reg  [(`CA53_MBIST0_DATA_W-1): 0]     gov_mbistindata0_o,
  output reg  [(`CA53_MBIST1_DATA_W-1): 0]     gov_mbistindata1_o,
  output reg  [(`CA53_MBIST0_DATA_W-1): 0]     mbistoutdata0_o,
  output reg  [(`CA53_MBIST1_DATA_W-1): 0]     mbistoutdata1_o,
  output reg                                   gov_mbistwriteen0_o,
  output reg                                   gov_mbistwriteen1_o,
  output reg                                   gov_mbistreaden0_o,
  output reg                                   gov_mbistreaden1_o,
  output reg  [(`CA53_MBIST0_RAMARRAY_W-1): 0] gov_mbistarray0_o,
  output reg  [(`CA53_MBIST1_RAMARRAY_W-1): 0] gov_mbistarray1_o,
  output reg  [(`CA53_MBIST0_BE_W-1): 0]       gov_mbistbe0_o,
  output reg  [(`CA53_MBIST1_BE_W-1): 0]       gov_mbistbe1_o,
  output reg                                   gov_mbistcfg0_o,
  output reg                                   gov_mbistcfg1_o
);

  // -----------------------------
  // Integer declarations
  // -----------------------------

  integer cpu_i;
  integer bit_k;

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar cpu;

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam NUM_CPUS_M1 = NUM_CPUS - 1;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                                   atclken_rs;
  reg                                   cntclken_rs;
  reg [63:0]                            cntvalueb_rs;
  reg                                   cp_l2actlr_disable_evict;
  reg                                   cp_l2actlr_enable_writeevict;
  reg [1:0]                             cp_l2actlr_victim_ctl;
  reg                                   cp_l2actlr_l2deien;
  reg                                   cp_l2actlr_l2teien;
  reg                                   cp_l2ectlr_axierr;
  reg                                   cp_l2ectlr_eccerr;
  reg [2:0]                             cp_l2ectlr_ret_delay;
  reg                                   evento_stg1;
  reg                                   evento_stg2;
  reg                                   load_initial;
  reg                                   mbist_enable;
  reg                                   nxt_cp_l2actlr_disable_evict;
  reg                                   nxt_cp_l2actlr_enable_writeevict;
  reg [1:0]                             nxt_cp_l2actlr_victim_ctl;
  reg                                   nxt_cp_l2ectlr_clear_axierr;
  reg                                   nxt_cp_l2ectlr_clear_eccerr;
  reg [2:0]                             nxt_cp_l2ectlr_ret_delay;
  reg [63:0]                            tsvalueb_rs;
  reg                                   nl2reset_pipeline_stage_0;
  reg                                   nl2reset_pipeline_stage_1;
  reg                                   nl2reset_pipeline_stage_2;
  reg                                   nl2reset_synced_pipelined_local;
  reg                                   nmbistreset_pipeline_stage_0;
  reg                                   nmbistreset_pipeline_stage_1;
  reg                                   nmbistreset_pipeline_stage_2;
  reg                                   nmbistreset_synced_pipelined_local;
  reg                                   npresetdbg_pipeline_stage_0;
  reg                                   npresetdbg_pipeline_stage_1;
  reg                                   npresetdbg_pipeline_stage_2;
  reg                                   npresetdbg_synced_pipelined_local;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                  clear_axierr;
  wire                                  clear_eccerr;
  wire                                  clrexmon_rs;
  wire [NUM_CPUS-1:0]                   cp_l2actlr;
  wire                                  cp_l2actlr_en;
  wire [NUM_CPUS-1:0]                   cp_l2actlr_rd;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_l2actlr_rdata;
  wire [NUM_CPUS-1:0]                   cp_l2actlr_wr;
  wire [NUM_CPUS-1:0]                   cp_l2actlr_wr_pri;
  wire [NUM_CPUS-1:0]                   cp_l2ctlr;
  wire [NUM_CPUS-1:0]                   cp_l2ctlr_rd;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_l2ctlr_rdata;
  wire [NUM_CPUS-1:0]                   cp_l2ectlr;
  wire                                  cp_l2ectlr_en;
  wire [NUM_CPUS-1:0]                   cp_l2ectlr_rd;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_l2ectlr_rdata;
  wire [NUM_CPUS-1:0]                   cp_l2ectlr_wr;
  wire [NUM_CPUS-1:0]                   cp_l2ectlr_wr_pri;
  wire [(`CA53_GOV_CPDATA_PKDED_W-1):0] cp_l2merrsr_rdata;
  wire                                  cp_l2merrsr_en;
  wire                                  mereged_sev_req;
  wire                                  nxt_evento_stg1;
  wire                                  nxt_evento_stg2;
  wire                                  nxt_evento;
  wire                                  nl2reset_synced_local;
  wire                                  nmbistreset_synced_local;
  wire                                  npresetdbg_synced_local;
  wire                                  clk_mbist;
  wire                                  clk_initial;
  wire                                  reset_n;
  wire                                  nl2reset_pipeline_en;
  wire                                  nmbistreset_pipeline_en;
  wire                                  npresetdbg_pipeline_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Load initial
  // ------------------------------------------------------

  // The reset values of some registers depend on top-level inputs which are sampled
  // at reset time. Therefore the load_initial register is reset to 1, then used as an
  // enable to load these values in on the first clock cycle during reset.
  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n)
      load_initial <= 1'b1;
    else if (load_initial)
      load_initial <= 1'b0;

  // Load_initial regional clock gate
  ca53_cell_inter_clkgate u_inter_clkgate_initial (.clk_i         (CLKIN),
                                                   .clk_enable_i  (load_initial),
                                                   .clk_senable_i (DFTSE),
                                                   .clk_gated_o   (clk_initial));

  // ------------------------------------------------------
  // Reset synchronisation
  // ------------------------------------------------------

  // The L2 and MBIST resets only need to be synchronised in one location and distributed
  // rather than in each CPU governor block

  // L2 reset synchronisation
  ca53_cell_sync u_ca53_cell_sync0 (.out_o    (nl2reset_synced_local),
                                    .clk_i    (CLKIN),
                                    .inp_i    (nl2reset),
                                    .resetn_i (nl2reset));

  assign nl2reset_pipeline_en = ~nl2reset_synced_pipelined_local | ~nmbistreset_synced_pipelined_local;

  always @(posedge CLKIN or negedge nl2reset)
    if (~nl2reset) begin
      nl2reset_pipeline_stage_0       <= 1'b0;
      nl2reset_pipeline_stage_1       <= 1'b0;
      nl2reset_pipeline_stage_2       <= 1'b0;
      nl2reset_synced_pipelined_local <= 1'b0;
    end
    else if (nl2reset_pipeline_en) begin
      nl2reset_pipeline_stage_0       <= nl2reset_synced_local;
      nl2reset_pipeline_stage_1       <= nl2reset_pipeline_stage_0;
      nl2reset_pipeline_stage_2       <= nl2reset_pipeline_stage_1;
      nl2reset_synced_pipelined_local <= nl2reset_pipeline_stage_2;
    end

  // MBIST reset synchronisation
  ca53_cell_sync u_ca53_cell_sync1 (.out_o    (nmbistreset_synced_local),
                                    .clk_i    (CLKIN),
                                    .inp_i    (nmbistreset),
                                    .resetn_i (nmbistreset));

  assign nmbistreset_pipeline_en = ~nl2reset_synced_pipelined_local | ~nmbistreset_synced_pipelined_local;

  always @(posedge CLKIN or negedge nmbistreset)
    if (~nmbistreset) begin
      nmbistreset_pipeline_stage_0       <= 1'b0;
      nmbistreset_pipeline_stage_1       <= 1'b0;
      nmbistreset_pipeline_stage_2       <= 1'b0;
      nmbistreset_synced_pipelined_local <= 1'b0;
    end
    else if (nmbistreset_pipeline_en) begin
      nmbistreset_pipeline_stage_0       <= nmbistreset_synced_local;
      nmbistreset_pipeline_stage_1       <= nmbistreset_pipeline_stage_0;
      nmbistreset_pipeline_stage_2       <= nmbistreset_pipeline_stage_1;
      nmbistreset_synced_pipelined_local <= nmbistreset_pipeline_stage_2;
    end

  // nPRESETDBG reset synchronisation
  ca53_cell_sync u_ca53_cell_sync2 (.out_o    (npresetdbg_synced_local),
                                    .clk_i    (CLKIN),
                                    .inp_i    (npresetdbg),
                                    .resetn_i (npresetdbg));

  assign npresetdbg_pipeline_en = ~nl2reset_synced_pipelined_local | ~nmbistreset_synced_pipelined_local | ~npresetdbg_synced_pipelined_local;

  always @(posedge CLKIN or negedge npresetdbg)
    if (~npresetdbg) begin
      npresetdbg_pipeline_stage_0       <= 1'b0;
      npresetdbg_pipeline_stage_1       <= 1'b0;
      npresetdbg_pipeline_stage_2       <= 1'b0;
      npresetdbg_synced_pipelined_local <= 1'b0;
    end
    else if (npresetdbg_pipeline_en) begin
      npresetdbg_pipeline_stage_0       <= npresetdbg_synced_local;
      npresetdbg_pipeline_stage_1       <= npresetdbg_pipeline_stage_0;
      npresetdbg_pipeline_stage_2       <= npresetdbg_pipeline_stage_1;
      npresetdbg_synced_pipelined_local <= npresetdbg_pipeline_stage_2;
    end

  // Create local reset
  assign reset_n = DFTRSTDISABLE | (nmbistreset_synced_pipelined_local & nl2reset_synced_pipelined_local);

  // Create debug reset
  assign npresetdbg_gov = DFTRSTDISABLE | (nmbistreset_synced_pipelined_local & npresetdbg_synced_pipelined_local);

  // ------------------------------------------------------
  // Register slice for cluster-wide signals captured at reset
  // ------------------------------------------------------

  always @(posedge clk_initial)
    begin
      gov_periphbase_o   <= periphbase_i[39:18];
      gov_giccdisable_o  <= giccdisable_i;
      clusteridaff1_rs_o <= clusteridaff1_i[7:0];
      clusteridaff2_rs_o <= clusteridaff2_i[7:0];
      gov_dbgromaddr_o   <= dbgromaddr_i[39:12];
      gov_dbgromaddrv_o  <= dbgromaddrv_i;
    end

  // ------------------------------------------------------
  // CLREXMON synchronisation and handshake
  // ------------------------------------------------------

  // CLREXMONREQ is synchronised to assist the timing path coming in to the cluster from the system
  ca53_cell_sync u_ca53_cell_sync3 (.out_o    (clrexmon_rs),
                                    .clk_i    (CLKIN),
                                    .inp_i    (clrexmonreq_i),
                                    .resetn_i (reset_n));

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n)
      clrexmonack_o <= 1'b0;
    else
      clrexmonack_o <= clrexmon_rs;

  // ------------------------------------------------------
  // EVENTI & EVENTO
  // ------------------------------------------------------

  // EVENTI is synchronised to assist the timing path coming in to the cluster from the system
  ca53_cell_sync u_ca53_cell_sync4 (.out_o    (eventi_rs_o),
                                    .clk_i    (CLKIN),
                                    .inp_i    (eventi_i),
                                    .resetn_i (reset_n));

  // EVENTO is pulsed for three-cycles
  assign mereged_sev_req = |sev_req_rs_i;
  assign nxt_evento_stg1 = mereged_sev_req;
  assign nxt_evento_stg2 = mereged_sev_req | evento_stg1;
  assign nxt_evento      = mereged_sev_req | evento_stg2;

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      evento_stg1 <= 1'b0;
      evento_stg2 <= 1'b0;
      evento_o    <= 1'b0;
    end else begin
      evento_stg1 <= nxt_evento_stg1;
      evento_stg2 <= nxt_evento_stg2;
      evento_o    <= nxt_evento;
    end

  // ------------------------------------------------------
  // STANDBYWFI and STANDBYWFE
  // ------------------------------------------------------

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      standbywfi_o <= {NUM_CPUS{1'b1}};
      standbywfe_o <= {NUM_CPUS{1'b0}};
    end else begin
      standbywfi_o <= gov_standbywfi_i[(NUM_CPUS-1):0];
      standbywfe_o <= gov_standbywfe_i[(NUM_CPUS-1):0];
    end

  // ------------------------------------------------------
  // CPU architectural counter register slice
  // ------------------------------------------------------

  // Register the counter value clock enable
  always @(posedge CLKIN)
    cntclken_rs <= cntclken_i;

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n)
      cntvalueb_rs[63:0] <= {64{1'b0}};
    else if (cntclken_rs)
      cntvalueb_rs[63:0] <= cntvalueb_i[63:0];

  // ------------------------------------------------------
  // ETM architectural counter register slice
  // ------------------------------------------------------

  // Register the counter value clock enable
  always @(posedge CLKIN)
    atclken_rs <= atclken_i;

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n)
      tsvalueb_rs[63:0] <= {64{1'b0}};
    else if (atclken_rs)
      tsvalueb_rs[63:0] <= tsvalueb_i[63:0];

  // ------------------------------------------------------
  // System mapped L2 register read / write control
  // ------------------------------------------------------

  // Extract control signals from the CP address bus
  generate
    for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : l2_ctl_extraction
      assign cp_l2actlr[cpu] = valid_l2_en_i[cpu] & (cp_gov_addr_rs_i[((`CA53_GOV_CPADDR_W*(cpu+1))-1):(`CA53_GOV_CPADDR_W*cpu)] == `CA53_CPOP_L2_ACTLR);
      assign cp_l2ctlr[cpu]  = valid_l2_en_i[cpu] & (cp_gov_addr_rs_i[((`CA53_GOV_CPADDR_W*(cpu+1))-1):(`CA53_GOV_CPADDR_W*cpu)] == `CA53_CPOP_L2_CTLR);
      assign cp_l2ectlr[cpu] = valid_l2_en_i[cpu] & (cp_gov_addr_rs_i[((`CA53_GOV_CPADDR_W*(cpu+1))-1):(`CA53_GOV_CPADDR_W*cpu)] == `CA53_CPOP_L2_ECTLR);

      // Identify reads
      assign cp_l2actlr_rd[cpu] = ~cp_gov_wenable_rs_i[cpu] & cp_l2actlr[cpu];
      assign cp_l2ctlr_rd[cpu]  = ~cp_gov_wenable_rs_i[cpu] & cp_l2ctlr[cpu];
      assign cp_l2ectlr_rd[cpu] = ~cp_gov_wenable_rs_i[cpu] & cp_l2ectlr[cpu];

      // Identify writes.  Only the L2CTLR is not writable.
      assign cp_l2actlr_wr[cpu] =  cp_gov_wenable_rs_i[cpu] & cp_l2actlr[cpu];
      assign cp_l2ectlr_wr[cpu] =  cp_gov_wenable_rs_i[cpu] & cp_l2ectlr[cpu];
    end endgenerate

  // Prioritise writes.  If multiple CPUs are trying to write the same register than favour lower number CPUs.
  generate if (NUM_CPUS == 1) begin : cpu1_write_priority_assign
    assign cp_l2actlr_wr_pri = cp_l2actlr_wr;
    assign cp_l2ectlr_wr_pri = cp_l2ectlr_wr;
  end
  else if (NUM_CPUS == 2) begin : cpu2_write_priority_assign
    assign cp_l2actlr_wr_pri = {(cp_l2actlr_wr[1] & ~cp_l2actlr_wr[0]), cp_l2actlr_wr[0]};
    assign cp_l2ectlr_wr_pri = {(cp_l2ectlr_wr[1] & ~cp_l2ectlr_wr[0]), cp_l2ectlr_wr[0]};
  end
  else if (NUM_CPUS == 3) begin : cpu3_write_priority_assign
    assign cp_l2actlr_wr_pri = {(cp_l2actlr_wr[2] & ~(|cp_l2actlr_wr[1:0])), (cp_l2actlr_wr[1] & ~cp_l2actlr_wr[0]), cp_l2actlr_wr[0]};
    assign cp_l2ectlr_wr_pri = {(cp_l2ectlr_wr[2] & ~(|cp_l2ectlr_wr[1:0])), (cp_l2ectlr_wr[1] & ~cp_l2ectlr_wr[0]), cp_l2ectlr_wr[0]};
  end
  else begin : cpu4_write_priority_assign
    assign cp_l2actlr_wr_pri = {(cp_l2actlr_wr[3] & ~(|cp_l2actlr_wr[2:0])), (cp_l2actlr_wr[2] & ~(|cp_l2actlr_wr[1:0])), (cp_l2actlr_wr[1] & ~cp_l2actlr_wr[0]), cp_l2actlr_wr[0]};
    assign cp_l2ectlr_wr_pri = {(cp_l2ectlr_wr[3] & ~(|cp_l2ectlr_wr[2:0])), (cp_l2ectlr_wr[2] & ~(|cp_l2ectlr_wr[1:0])), (cp_l2ectlr_wr[1] & ~cp_l2ectlr_wr[0]), cp_l2ectlr_wr[0]};
  end endgenerate

  // Mux write data
  always @* begin : g_l2_write_data
    reg          tmp_nxt_cp_l2actlr_enable_writeevict;
    reg          tmp_nxt_cp_l2actlr_disable_evict;
    reg          tmp_nxt_cp_l2ectlr_clear_axierr;
    reg          tmp_nxt_cp_l2ectlr_clear_eccerr;
    reg [31:30]  tmp_nxt_cp_l2actlr_victim_ctl;
    reg [2:0]    tmp_nxt_cp_l2ectlr_ret_delay;

    tmp_nxt_cp_l2actlr_enable_writeevict =     1'b0;
    tmp_nxt_cp_l2actlr_disable_evict     =     1'b0;
    tmp_nxt_cp_l2ectlr_clear_axierr      =     1'b0;
    tmp_nxt_cp_l2ectlr_clear_eccerr      =     1'b0;
    tmp_nxt_cp_l2actlr_victim_ctl        =  {2{1'b0}};
    tmp_nxt_cp_l2ectlr_ret_delay         =  {3{1'b0}};

    for (cpu_i = 0; cpu_i < NUM_CPUS; cpu_i = cpu_i + 1) begin : g_l2_write_data_by_cpu
      tmp_nxt_cp_l2actlr_enable_writeevict   = tmp_nxt_cp_l2actlr_enable_writeevict | (cp_l2actlr_wr_pri[cpu_i] &  cp_gov_wdata_rs_i[14+(`CA53_GOV_CPDATA_W*cpu_i)]);
      tmp_nxt_cp_l2actlr_disable_evict       = tmp_nxt_cp_l2actlr_disable_evict     | (cp_l2actlr_wr_pri[cpu_i] &  cp_gov_wdata_rs_i[3+(`CA53_GOV_CPDATA_W*cpu_i)]);
      tmp_nxt_cp_l2ectlr_clear_axierr        = tmp_nxt_cp_l2ectlr_clear_axierr      | (cp_l2ectlr_wr_pri[cpu_i] & ~cp_gov_wdata_rs_i[29+(`CA53_GOV_CPDATA_W*cpu_i)]);
      tmp_nxt_cp_l2ectlr_clear_eccerr        = tmp_nxt_cp_l2ectlr_clear_eccerr      | (cp_l2ectlr_wr_pri[cpu_i] & ~cp_gov_wdata_rs_i[30+(`CA53_GOV_CPDATA_W*cpu_i)]);

      for (bit_k = 30; bit_k < 32; bit_k = bit_k + 1) begin
        tmp_nxt_cp_l2actlr_victim_ctl[bit_k] = tmp_nxt_cp_l2actlr_victim_ctl[bit_k] | (cp_l2actlr_wr_pri[cpu_i] & cp_gov_wdata_rs_i[bit_k+(`CA53_GOV_CPDATA_W*cpu_i)]);
      end

      for (bit_k = 0; bit_k < 3; bit_k = bit_k + 1) begin
        tmp_nxt_cp_l2ectlr_ret_delay[bit_k]  = tmp_nxt_cp_l2ectlr_ret_delay[bit_k]  | (cp_l2ectlr_wr_pri[cpu_i] & cp_gov_wdata_rs_i[bit_k+(`CA53_GOV_CPDATA_W*cpu_i)]);
      end
    end

    nxt_cp_l2actlr_enable_writeevict = tmp_nxt_cp_l2actlr_enable_writeevict;
    nxt_cp_l2actlr_disable_evict     = tmp_nxt_cp_l2actlr_disable_evict;
    nxt_cp_l2ectlr_clear_axierr      = tmp_nxt_cp_l2ectlr_clear_axierr;
    nxt_cp_l2ectlr_clear_eccerr      = tmp_nxt_cp_l2ectlr_clear_eccerr;
    nxt_cp_l2actlr_victim_ctl        = tmp_nxt_cp_l2actlr_victim_ctl;
    nxt_cp_l2ectlr_ret_delay         = tmp_nxt_cp_l2ectlr_ret_delay;
  end

  // Write enables
  assign cp_l2actlr_en = |(cp_l2actlr_wr);
  assign cp_l2ectlr_en = |(cp_l2ectlr_wr);

  // ------------------------------------------------------
  // L2ACTLR
  // ------------------------------------------------------

generate if (ACE) begin : ACE_CONFIG
  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      cp_l2actlr_victim_ctl        <= 2'b10;
      cp_l2actlr_enable_writeevict <= 1'b0;
      cp_l2actlr_disable_evict     <= 1'b0;
    end
    else if (cp_l2actlr_en) begin
      cp_l2actlr_victim_ctl        <= nxt_cp_l2actlr_victim_ctl;
      cp_l2actlr_enable_writeevict <= nxt_cp_l2actlr_enable_writeevict;
      cp_l2actlr_disable_evict     <= nxt_cp_l2actlr_disable_evict;
    end
end else begin : SKYROS_CONFIG
  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      cp_l2actlr_victim_ctl        <= 2'b10;
      cp_l2actlr_enable_writeevict <= 1'b1;
      cp_l2actlr_disable_evict     <= 1'b1;
    end
    else if (cp_l2actlr_en) begin
      cp_l2actlr_victim_ctl        <= nxt_cp_l2actlr_victim_ctl;
      cp_l2actlr_enable_writeevict <= nxt_cp_l2actlr_enable_writeevict;
      cp_l2actlr_disable_evict     <= nxt_cp_l2actlr_disable_evict;
    end
end endgenerate

  // Implement the L2DEIEN and L2TEIEN fields on the SCU_CACHE_PROTECTION
  // configurations, only.

generate if (SCU_CACHE_PROTECTION) begin : g_l2_err_inject
  reg nxt_cp_l2actlr_l2deien;
  reg nxt_cp_l2actlr_l2teien;

  // Mux write data
  always @* begin : g_l2_err_inject_write_data
    reg tmp_nxt_cp_l2actlr_l2deien;
    reg tmp_nxt_cp_l2actlr_l2teien;

    tmp_nxt_cp_l2actlr_l2deien = 1'b0;
    tmp_nxt_cp_l2actlr_l2teien = 1'b0;

    for (cpu_i = 0; cpu_i < NUM_CPUS; cpu_i = cpu_i + 1) begin : g_l2_err_inject_by_cpu
      tmp_nxt_cp_l2actlr_l2deien = tmp_nxt_cp_l2actlr_l2deien | (cp_l2actlr_wr_pri[cpu_i] & cp_gov_wdata_rs_i[29+(`CA53_GOV_CPDATA_W*cpu_i)]);
      tmp_nxt_cp_l2actlr_l2teien = tmp_nxt_cp_l2actlr_l2teien | (cp_l2actlr_wr_pri[cpu_i] & cp_gov_wdata_rs_i[24+(`CA53_GOV_CPDATA_W*cpu_i)]);
    end

    nxt_cp_l2actlr_l2deien = tmp_nxt_cp_l2actlr_l2deien;
    nxt_cp_l2actlr_l2teien = tmp_nxt_cp_l2actlr_l2teien;
  end

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      cp_l2actlr_l2deien <= 1'b0;
      cp_l2actlr_l2teien <= 1'b0;
    end
    else if (cp_l2actlr_en) begin
      cp_l2actlr_l2deien <= nxt_cp_l2actlr_l2deien;
      cp_l2actlr_l2teien <= nxt_cp_l2actlr_l2teien;
    end
end else begin : g_n_l2_err_inject
  wire zero;

  // Tie off used for configurable logic.
  assign zero = 1'b0;

  always @*
    begin
      cp_l2actlr_l2deien = zero;
      cp_l2actlr_l2teien = zero;
    end
end endgenerate

  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_l2actlr_rd
    assign cp_l2actlr_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)] = {{32{1'b0}},
                                                                                               ({32{cp_l2actlr_rd[cpu]}} & {cp_l2actlr_victim_ctl,        // [31:30]
                                                                                                                            cp_l2actlr_l2deien,           // [   29]
                                                                                                                            {4{1'b0}},                    // [28:25]
                                                                                                                            cp_l2actlr_l2teien,           // [   24]
                                                                                                                            {9{1'b0}},                    // [23:15]
                                                                                                                            cp_l2actlr_enable_writeevict, // [   14]
                                                                                                                            {10{1'b0}},                   // [13: 4]
                                                                                                                            cp_l2actlr_disable_evict,     // [    3]
                                                                                                                            {3{1'b0}}})};                 // [ 2: 0]
  end endgenerate

  // ------------------------------------------------------
  // L2CTLR
  // ------------------------------------------------------

  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_l2ctlr_rd
    assign cp_l2ctlr_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)] = {{32{1'b0}},
                                                                                              ({32{cp_l2ctlr_rd[cpu]}} & {{6{1'b0}},               // [31:26]
                                                                                                                          NUM_CPUS_M1[1:0],        // [25:24]
                                                                                                                          {1{1'b0}},               // [   23]
                                                                                                                          CPU_CACHE_PROTECTION[0], // [   22]
                                                                                                                          SCU_CACHE_PROTECTION[0], // [   21]
                                                                                                                          {15{1'b0}},              // [20: 6]
                                                                                                                          L2_INPUT_LATENCY[0],     // [    5]
                                                                                                                          {4{1'b0}},               // [ 4: 1]
                                                                                                                          L2_OUTPUT_LATENCY[0]})}; // [    0]
  end endgenerate

  // ------------------------------------------------------
  // L2ECTLR
  // ------------------------------------------------------

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n)
      cp_l2ectlr_ret_delay <= 3'b000;
    else if (cp_l2ectlr_en)
      cp_l2ectlr_ret_delay <= nxt_cp_l2ectlr_ret_delay;

  // Indicate to the SCU that the AXIERR signal should be cleared
  assign clear_axierr = cp_l2ectlr_en & nxt_cp_l2ectlr_clear_axierr;

  // Indicate to the SCU that the ECCERR signal should be cleared
  assign clear_eccerr = cp_l2ectlr_en & nxt_cp_l2ectlr_clear_eccerr;

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      cp_l2ectlr_axierr  <= 1'b0;
      cp_l2ectlr_eccerr  <= 1'b0;
      gov_clear_axierr_o <= 1'b0;
      gov_clear_eccerr_o <= 1'b0;
    end
    else begin
      cp_l2ectlr_axierr  <= scu_axierr_i;
      cp_l2ectlr_eccerr  <= scu_eccerr_i;
      gov_clear_axierr_o <= clear_axierr;
      gov_clear_eccerr_o <= clear_eccerr;
    end

  generate for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_l2ectlr_rd
    assign cp_l2ectlr_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)] = {{32{1'b0}},
                                                                                               ({32{cp_l2ectlr_rd[cpu]}} & {{1{1'b0}},
                                                                                                                            cp_l2ectlr_eccerr,
                                                                                                                            cp_l2ectlr_axierr,
                                                                                                                            {26{1'b0}},
                                                                                                                            cp_l2ectlr_ret_delay})};
  end endgenerate

  // ------------------------------------------------------
  // L2MERRSR
  // ------------------------------------------------------

generate if (SCU_CACHE_PROTECTION) begin : SCU_CACHE_PROTECTION_CONFIG

  // ---------------------------------
  // Declarations
  // ---------------------------------

  reg                                   cp_l2merrsr_ftl;
  reg [7:0]                             cp_l2merrsr_other_err_cnt;
  reg [1:0]                             cp_l2merrsr_ramid;
  reg [7:0]                             cp_l2merrsr_repeat_err_cnt;
  reg                                   cp_l2merrsr_vld;
  reg [3:0]                             cp_l2merrsr_cpuid_way;
  reg [14:0]                            cp_l2merrsr_index;
  reg                                   evnt_scu_err;
  reg                                   evnt_l2_err;

  wire [NUM_CPUS-1:0]                   cp_l2merrsr;
  wire [NUM_CPUS-1:0]                   cp_l2merrsr_rd;
  wire [NUM_CPUS-1:0]                   cp_l2merrsr_cpu_wr;
  wire                                  cp_l2merrsr_wr;
  wire                                  nxt_cp_l2merrsr_ftl;
  wire [7:0]                            nxt_cp_l2merrsr_other_err_cnt;
  wire [1:0]                            nxt_cp_l2merrsr_ramid;
  wire [7:0]                            nxt_cp_l2merrsr_repeat_err_cnt;
  wire                                  nxt_cp_l2merrsr_vld;
  wire [3:0]                            nxt_cp_l2merrsr_cpuid_way;
  wire [14:0]                           nxt_cp_l2merrsr_index;
  wire                                  nxt_evnt_scu_err;
  wire                                  nxt_evnt_l2_err;

  // Extract control signals from the CP address bus
  for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : l2_ctl_extraction
    assign cp_l2merrsr[cpu] = valid_l2_en_i[cpu] & (cp_gov_addr_rs_i[((`CA53_GOV_CPADDR_W*(cpu+1))-1):(`CA53_GOV_CPADDR_W*cpu)] == `CA53_CPOP_L2_MEM_ERR_SR);

    // Identify reads
    assign cp_l2merrsr_rd[cpu] = ~cp_gov_wenable_rs_i[cpu] & cp_l2merrsr[cpu];

    // Identify writes - any write to the L2MERRSR clears the entire register
    assign cp_l2merrsr_cpu_wr[cpu] =  cp_gov_wenable_rs_i[cpu] & cp_l2merrsr[cpu];
  end

  // System write indication
  assign cp_l2merrsr_wr = |(cp_l2merrsr_cpu_wr);

  // Combine system enable and ECC update enable.  Prevent further updates once a fatal is indicated so that a fatal is sticky
  assign cp_l2merrsr_en = cp_l2merrsr_wr | (scu_l2ecc_valid_i & ~cp_l2merrsr_ftl);

  // [63] - Fatal : Clear on a system write, Set on a fatal error
  assign nxt_cp_l2merrsr_ftl           =    ~cp_l2merrsr_wr   & scu_l2ecc_fatal_i;

  // [47:40] - Other Error Count : Clear on a system write, Clear on first memory error, Increment on any error that isn't tracked by 'Repeat Error Count' field
  assign nxt_cp_l2merrsr_other_err_cnt = {8{~cp_l2merrsr_wr}} & {8{cp_l2merrsr_vld}} &                            (cp_l2merrsr_other_err_cnt[7:0]  + {{7{1'b0}}, ~((cp_l2merrsr_ramid[1:0] == scu_l2ecc_ramid_i[1:0]) &
                                                                                                                                                                   (cp_l2merrsr_cpuid_way  == scu_l2ecc_cpuid_way_i))});

  // [39:32] - Repeat Error Count : Clear on a system write, first memory error or fatal, Increment on any error to the same RAM/CPU ID
  assign nxt_cp_l2merrsr_repeat_err_cnt = {8{~cp_l2merrsr_wr}} & {8{cp_l2merrsr_vld}} & {8{~scu_l2ecc_fatal_i}} & (cp_l2merrsr_repeat_err_cnt[7:0] + {{7{1'b0}},  ((cp_l2merrsr_ramid[1:0] == scu_l2ecc_ramid_i[1:0]) &
                                                                                                                                                                   (cp_l2merrsr_cpuid_way  == scu_l2ecc_cpuid_way_i))});

  // [31] - Valid : Clear on a write, Set on a valid ECC update
  assign nxt_cp_l2merrsr_vld            = ~cp_l2merrsr_wr;

  // [30:24] - RAM ID : Recirculate once valid, unless there's been a fatal error.  Note that [30:26] are constant
  assign nxt_cp_l2merrsr_ramid          = {2{~cp_l2merrsr_wr}} & ((cp_l2merrsr_vld & ~scu_l2ecc_fatal_i) ? cp_l2merrsr_ramid     : scu_l2ecc_ramid_i);

  // [21:18] - CPU ID : Recirculate once valid, unless there's been a fatal error
  assign nxt_cp_l2merrsr_cpuid_way      = {4{~cp_l2merrsr_wr}} & ((cp_l2merrsr_vld & ~scu_l2ecc_fatal_i) ? cp_l2merrsr_cpuid_way : scu_l2ecc_cpuid_way_i);

  // [17:3] - Index : Recirculate once valid, unless there's been a fatal error
  assign nxt_cp_l2merrsr_index          = {15{~cp_l2merrsr_wr}} & ((cp_l2merrsr_vld & ~scu_l2ecc_fatal_i) ? cp_l2merrsr_index    : scu_l2ecc_index_i);

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      cp_l2merrsr_ftl            <=    1'b0;
      cp_l2merrsr_other_err_cnt  <= {8{1'b0}};
      cp_l2merrsr_repeat_err_cnt <= {8{1'b0}};
      cp_l2merrsr_vld            <=    1'b0;
    end
    else if (cp_l2merrsr_en) begin
      cp_l2merrsr_ftl            <= nxt_cp_l2merrsr_ftl;
      cp_l2merrsr_other_err_cnt  <= nxt_cp_l2merrsr_other_err_cnt;
      cp_l2merrsr_repeat_err_cnt <= nxt_cp_l2merrsr_repeat_err_cnt;
      cp_l2merrsr_vld            <= nxt_cp_l2merrsr_vld;
    end

  always @(posedge CLKIN)
    if (cp_l2merrsr_en) begin
      cp_l2merrsr_ramid          <= nxt_cp_l2merrsr_ramid;
      cp_l2merrsr_cpuid_way      <= nxt_cp_l2merrsr_cpuid_way;
      cp_l2merrsr_index          <= nxt_cp_l2merrsr_index;
    end

  // Read path
  for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_l2mem_rd
    assign cp_l2merrsr_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)] = {64{cp_l2merrsr_rd[cpu]}} & {cp_l2merrsr_ftl,
                                                                                                                            {15{1'b0}},
                                                                                                                            cp_l2merrsr_other_err_cnt,
                                                                                                                            cp_l2merrsr_repeat_err_cnt,
                                                                                                                            cp_l2merrsr_vld,
                                                                                                                            5'b00100,               // Constant bits of RAM ID
                                                                                                                            cp_l2merrsr_ramid[1:0], // Variable bits of RAM ID
                                                                                                                            {2{1'b0}},
                                                                                                                            cp_l2merrsr_cpuid_way,
                                                                                                                            cp_l2merrsr_index,
                                                                                                                            {3{1'b0}}};
  end

  // Error Event indication for core eventbus
  assign nxt_evnt_scu_err = scu_l2ecc_valid_i &  scu_l2ecc_ramid_i[1];
  assign nxt_evnt_l2_err  = scu_l2ecc_valid_i & ~scu_l2ecc_ramid_i[1];

  always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      evnt_scu_err <= 1'b0;
      evnt_l2_err  <= 1'b0;
    end
    else begin
      evnt_scu_err <= nxt_evnt_scu_err;
      evnt_l2_err  <= nxt_evnt_l2_err;
    end

  assign evnt_scu_err_o = evnt_scu_err;
  assign evnt_l2_err_o  = evnt_l2_err;

end else begin : NO_SCU_CACHE_PROTECTION_CONFIG
  for (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_l2mem_rd_none
    assign cp_l2merrsr_rdata[((`CA53_GOV_CPDATA_W * (cpu+1))-1): (`CA53_GOV_CPDATA_W * cpu)] = {64{1'b0}};
  end

  // Tie-offs
  assign cp_l2merrsr_en = 1'b0;
  assign evnt_scu_err_o = 1'b0;
  assign evnt_l2_err_o  = 1'b0;
end endgenerate

  // ------------------------------------------------------
  // MBIST register slice
  // ------------------------------------------------------

  // Slice the MBIST interfaces and enable continuously once a reset has
  // occured when MBISTREQ is asserted.  To exit MBIST mode a reset is
  // required without MBISTREQ being asserted which will clear the enable.
  always @(posedge clk_initial)
    mbist_enable <= mbistreq_i;

  // Use MBIST enable in a regional clock gate
  ca53_cell_inter_clkgate u_inter_clkgate_mbist (.clk_i         (CLKIN),
                                                 .clk_enable_i  (mbist_enable),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (clk_mbist));

  always @(posedge clk_mbist or negedge reset_n)
    if (~reset_n) begin
      mbistreq_rs_o       <= 1'b0;
      mbistack0_o         <= 1'b0;
      mbistack1_o         <= 1'b0;
      gov_mbistaddr0_o    <= {`CA53_MBIST0_ADDR_W{1'b0}};
      gov_mbistaddr1_o    <= {`CA53_MBIST1_ADDR_W{1'b0}};
      gov_mbistindata0_o  <= {`CA53_MBIST0_DATA_W{1'b0}};
      gov_mbistindata1_o  <= {`CA53_MBIST1_DATA_W{1'b0}};
      mbistoutdata0_o     <= {`CA53_MBIST0_DATA_W{1'b0}};
      mbistoutdata1_o     <= {`CA53_MBIST1_DATA_W{1'b0}};
      gov_mbistwriteen0_o <= 1'b0;
      gov_mbistwriteen1_o <= 1'b0;
      gov_mbistreaden0_o  <= 1'b0;
      gov_mbistreaden1_o  <= 1'b0;
      gov_mbistarray0_o   <= {`CA53_MBIST0_RAMARRAY_W{1'b0}};
      gov_mbistarray1_o   <= {`CA53_MBIST1_RAMARRAY_W{1'b0}};
      gov_mbistbe0_o      <= {`CA53_MBIST0_BE_W{1'b0}};
      gov_mbistbe1_o      <= {`CA53_MBIST1_BE_W{1'b0}};
      gov_mbistcfg0_o     <= 1'b0;
      gov_mbistcfg1_o     <= 1'b0;
    end
    else begin
      mbistreq_rs_o       <= mbistreq_i;
      mbistack0_o         <= scu_mbistack0_i;
      mbistack1_o         <= scu_mbistack1_i;
      gov_mbistaddr0_o    <= mbistaddr0_i[(`CA53_MBIST0_ADDR_W-1):0];
      gov_mbistaddr1_o    <= mbistaddr1_i[(`CA53_MBIST1_ADDR_W-1):0];
      gov_mbistindata0_o  <= mbistindata0_i[(`CA53_MBIST0_DATA_W-1):0];
      gov_mbistindata1_o  <= mbistindata1_i[(`CA53_MBIST1_DATA_W-1):0];
      mbistoutdata0_o     <= scu_mbistoutdata0_i[(`CA53_MBIST0_DATA_W-1):0];
      mbistoutdata1_o     <= scu_mbistoutdata1_i[(`CA53_MBIST1_DATA_W-1):0];
      gov_mbistwriteen0_o <= mbistwriteen0_i;
      gov_mbistwriteen1_o <= mbistwriteen1_i;
      gov_mbistreaden0_o  <= mbistreaden0_i;
      gov_mbistreaden1_o  <= mbistreaden1_i;
      gov_mbistarray0_o   <= mbistarray0_i[(`CA53_MBIST0_RAMARRAY_W-1):0];
      gov_mbistarray1_o   <= mbistarray1_i[(`CA53_MBIST1_RAMARRAY_W-1):0];
      gov_mbistbe0_o      <= mbistbe0_i[(`CA53_MBIST0_BE_W-1):0];
      gov_mbistbe1_o      <= mbistbe1_i[(`CA53_MBIST1_BE_W-1):0];
      gov_mbistcfg0_o     <= mbistcfg0_i;
      gov_mbistcfg1_o     <= mbistcfg1_i;
    end

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign gov_l2victim_ctl_o           = cp_l2actlr_victim_ctl;
  assign gov_l2deien_o                = cp_l2actlr_l2deien;
  assign gov_l2teien_o                = cp_l2actlr_l2teien;
  assign gov_enable_writeevict_o      = cp_l2actlr_enable_writeevict;
  assign gov_disable_evict_o          = cp_l2actlr_disable_evict;
  assign nl2reset_synced_pipelined    = nl2reset_synced_pipelined_local;
  assign nl2reset_synced              = nl2reset_synced_local;
  assign nmbistreset_synced_pipelined = nmbistreset_synced_pipelined_local;
  assign nmbistreset_synced           = nmbistreset_synced_local;
  assign reset_n_arb                  = reset_n;
  assign cp_l2ectlr_ret_delay_o       = cp_l2ectlr_ret_delay;
  assign clrexmon_rs_o                = clrexmon_rs;
  assign cntvalueb_rs_o               = cntvalueb_rs[63:0];
  assign tsvalueb_rs_o                = tsvalueb_rs[63:0];
  assign cp_l2_rdata_o                = cp_l2actlr_rdata | cp_l2ctlr_rdata | cp_l2ectlr_rdata | cp_l2merrsr_rdata;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_l2actlr_en")
  u_ovl_x_cp_l2actlr_en (.clk       (CLKIN),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_l2actlr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_l2ectlr_en")
  u_ovl_x_cp_l2ectlr_en (.clk       (CLKIN),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_l2ectlr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_l2merrsr_en")
  u_ovl_x_cp_l2merrsr_en (.clk       (CLKIN),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (cp_l2merrsr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: atclken_rs")
  u_ovl_x_atclken_rs (.clk       (CLKIN),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (atclken_rs));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cntclken_rs")
  u_ovl_x_cntclken_rs (.clk       (CLKIN),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (cntclken_rs));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial")
  u_ovl_x_load_initial (.clk       (CLKIN),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (load_initial));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: mbist_enable")
  u_ovl_x_mbist_enable (.clk       (CLKIN),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (mbist_enable));

`endif

endmodule // ca53governor_slice

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
