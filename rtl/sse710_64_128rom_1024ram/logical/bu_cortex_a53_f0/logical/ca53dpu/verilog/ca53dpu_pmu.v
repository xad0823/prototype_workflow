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
// Abstract : Performance Monitoring Unit
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_pmu `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         clk,                              // Clock
  input  wire         reset_n,                          // Reset
  input  wire         DFTSE,                            // DFT Scan Enable
  input  wire         nxt_cp_valid_wr_i,                // Early Co-processor register write enable
  input  wire         raw_cp_valid_wr_i,                // Raw Co-processor register write enable
  input  wire         cp_valid_wr_i,                    // Co-processor register write enable
  input  wire   [8:0] raw_cp_decode_wr_i,               // Co-processor register write address
  input  wire  [15:0] cp15_pmu_access_wr_i,
  input  wire  [63:0] mcr_data_wr_i,                    // Co-processor register write data
  input  wire         cp_mdcr_el3_spme_i,               // Secure Performance Monitors enable
  input  wire         hdcr_hpme_i,                      // Hypervisor Performance Monitors Enable
  input  wire   [4:0] hdcr_hpmn_i,                      // Number of Performance Monitors counters accessible from Non-secure EL0 
  input  wire         aarch64_state_i,                  // AArch64 state
  input  wire   [1:0] dpu_exception_level_i,            // Current EL
  input  wire         ns_state_i,                       // Non-secure state
  input  wire         stall_wr_i,                       // Stall the processor
  input  wire         dbg_non_inv_perm_synced_i,        // External secure non invasive debug enabled
  input  wire         dbgdscr_halted_i,                 // Processor in debug state (DBGDSCR.halted)
  input  wire   [1:0] biu_evnt_ext_mem_req_i,
  input  wire   [1:0] biu_evnt_ext_mem_req_nc_i,
  input  wire         biu_evnt_pf_lf_i,
  input  wire         biu_evnt_rw_lf_i,
  input  wire         biu_evnt_ramode_i,
  input  wire         biu_evnt_ramode_enter_i,
  input  wire         dcu_evnt_dc_access_i,
  input  wire         tlb_evnt_data_pagewalk_i,
  input  wire         tlb_evnt_instr_pagewalk_i,
  input  wire         ifu_evnt_ic_lf_i,
  input  wire         ifu_evnt_ic_access_i,
  input  wire         ifu_evnt_ic_miss_wait_i,
  input  wire         ifu_evnt_iutlb_miss_wait_i,
  input  wire         ifu_evnt_pdc_valid_i,
  input  wire         ifu_evnt_throttle_i,
  input  wire         scu_evnt_l2_access_i,
  input  wire         scu_evnt_l2_refill_i,
  input  wire         scu_evnt_l2_wb_i,
  input  wire         scu_evnt_snooped_data_i,
  input  wire         scu_evnt_bus_cycle_i,
  input  wire         scu_evnt_bus_acc_rd_i,
  input  wire         scu_evnt_bus_acc_wr_i,
  input  wire         scu_evnt_eviction_i,
  input  wire         evnt_expt_taken_i,
  input  wire         evnt_call_expt_taken_i,
  input  wire         evnt_sw_change_pc_i,
  input  wire         expt_rtn_ret_i,
  input  wire         evnt_data_rd_wr_i,
  input  wire         evnt_data_wr_wr_i,
  input  wire   [1:0] evnt_instr_exec_i,
  input  wire         interlock_iss_i,
  input  wire         evnt_fpu_interlock_iss_i,
  input  wire         evnt_agu_interlock_iss_i,
  input  wire         evnt_unaligned_ls_i,
  input  wire         evnt_data_mem_access_i,
  input  wire         evnt_br_valid_wr_i,
  input  wire         evnt_br_mispred_i,
  input  wire         evnt_br_direct_wr_i,
  input  wire         evnt_br_indirect_i,
  input  wire         evnt_br_indirect_mispred_i,
  input  wire         evnt_br_indirect_mispred_addr_i,
  input  wire         evnt_iq_empty_i,
  input  wire         evnt_mem_err_ifu_i,
  input  wire         evnt_mem_err_dcu_i,
  input  wire         evnt_mem_err_tlb_i,
  input  wire         ls_store_wr_i,
  input  wire         ls_valid_wr_i,
  input  wire         dpu_pred_br_wr_i,
  input  wire         dpu_mispred_wr_i,
  input  wire         evnt_fiq_taken_i,
  input  wire         evnt_irq_taken_i,
  input  wire         stb_evnt_stb_stall_i,
  input  wire         pmu_apb_wr_i,                     // APB PMU write enable
  input  wire         nxt_pmu_apb_wr_i,                 // Early APB PMU write enable
  input  wire  [11:2] apb_addr_i,                       // APB Address
  input  wire  [31:0] apb_wdata_i,                      // APB Write data
  // Outputs
  output wire  [63:0] pmu_cp_rd_data_o,                 // Co-processor register read data
  output wire         dpu_npmuirq_o,                    // PMU interrupt
  output wire  [25:0] dpu_pmuevent_o,
  output wire   [3:0] pmn_useren_o,
  output wire  [31:0] pmu_apb_rdata_o,                  // APB data read from PMU register
  output wire         apb_pmu_access_o                  // APB PMU access
);

  // -------------------------------
  // Constant declarations
  // -------------------------------

  localparam PMN_NUMBER = `CA53_NUM_PMN;

  // -----------------------------
  // Genvar declarations
  // -----------------------------

  genvar n; // PMU number used in generate loops

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                   pmu_regs_clken;
  reg                   pmu_cntrs_clken;
  reg  [PMN_NUMBER-1:0] int_pmovsr_p;
  reg                   pmovsr_c;
  reg  [PMN_NUMBER-1:0] int_pmcnten_p;
  reg                   pmcnten_c;
  reg  [PMN_NUMBER-1:0] int_pminten_p;
  reg                   pminten_c;
  reg                   npmuirq_reg;
  reg            [63:0] pmccntr;
  reg             [5:0] clock_divider;
  reg  [PMN_NUMBER-1:0] pmevtyper_p;
  reg  [PMN_NUMBER-1:0] pmevtyper_u;
  reg  [PMN_NUMBER-1:0] pmevtyper_nsk;
  reg  [PMN_NUMBER-1:0] pmevtyper_nsu;
  reg  [PMN_NUMBER-1:0] pmevtyper_nsh;
  reg  [PMN_NUMBER-1:0] pmevtyper_m;
  reg             [9:0] pmevtyper_evtcount [PMN_NUMBER-1:0];
  reg            [31:0] pmevcntr           [PMN_NUMBER-1:0];
  reg                   pmccfiltr_p;
  reg                   pmccfiltr_u;
  reg                   pmccfiltr_nsk;
  reg                   pmccfiltr_nsu;
  reg                   pmccfiltr_nsh;
  reg                   pmccfiltr_m;
  reg             [3:0] pmuserenr;
  reg                   dpu_pmn_evntbus_en;
  reg            [25:0] dpu_pmn_evntbus;
  reg                   pmn_en;
  reg                   pmn_clock_divide;
  reg                   pmn_export_enabled;
  reg                   pmn_disable_ccnt_when_prohibited;
  reg                   pmn_long_ccnt;
  reg             [4:0] pmselr_sel;
  reg            [31:0] pmxevtyper_rd;
  reg            [31:0] pmxevcntr_rd;
  reg                   evnt_bus_acc_rd_rs;
  reg                   evnt_bus_acc_wr_rs;
  reg                   evnt_snooped_data_rs;
  reg                   attr_evnt_iq_empty;
  reg             [2:0] attr_evnt_iutlb_miss_cycle;
  reg             [2:0] attr_evnt_icache_miss_cycle;
  reg             [2:0] attr_evnt_pdc_err_cycle;
  reg                   evnt_ic_lf_rs;
  reg                   evnt_instr_pagewalk_rs;
  reg                   evnt_rw_lf_rs;
  reg                   evnt_dc_access_rs;
  reg                   evnt_data_pagewalk_rs;
  reg                   evnt_data_rd_wr_rs;
  reg                   evnt_data_wr_wr_rs;
  reg                   evnt_instr_exec_rs;
  reg                   evnt_instr_exec_two_rs;
  reg                   evnt_expt_taken_rs;
  reg                   evnt_expt_rtn_ret_rs;
  reg                   evnt_cntxtid_write_rs;
  reg                   evnt_sw_change_pc_rs;
  reg                   evnt_br_direct_wr_rs;
  reg                   evnt_unaligned_ls_rs;
  reg                   evnt_br_mispred_rs;
  reg                   evnt_br_valid_wr_rs;
  reg                   evnt_data_mem_access_rs;
  reg                   evnt_ic_access_rs;
  reg                   evnt_eviction_rs;
  reg                   evnt_l2_access_rs;
  reg                   evnt_l2_refill_rs;
  reg                   evnt_l2_wb_rs;
  reg                   evnt_bus_acc_rs;
  reg                   evnt_bus_acc_two_rs;
  reg                   evnt_bus_cycle_rs;
  reg                   attr_evnt_ilock;
  reg                   attr_evnt_ilock_fpu;
  reg                   attr_evnt_ilock_agu;
  reg                   attr_evnt_stall_wr;
  reg                   attr_evnt_ls_valid_wr;
  reg                   attr_evnt_ls_store_wr;
  reg                   evnt_br_indirect_rs;
  reg                   evnt_irq_taken_rs;
  reg                   evnt_fiq_taken_rs;
  reg                   evnt_ext_mem_req_rs;
  reg                   evnt_ext_mem_req_two_rs;
  reg                   evnt_ext_mem_req_nc_rs;
  reg                   evnt_ext_mem_req_nc_two_rs;
  reg                   evnt_pf_lf_rs;
  reg                   evnt_ramode_enter_rs;
  reg                   evnt_ramode_rs;
  reg                   evnt_pdc_valid_rs;
  reg                   evnt_stb_stall_rs;
  reg                   evnt_br_cond_predict_rs;
  reg                   evnt_br_indirect_mispred_rs;
  reg                   evnt_br_indirect_mispred_addr_rs;
  reg                   evnt_br_cond_mispredict_rs;
  reg                   evnt_throttle_rs;
  reg            [31:0] apb_pmn_rd_data;
  reg            [31:0] cp_pmn_rd_data;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                  clk_pmu_regs;
  wire                  clk_pmu_cntrs;
  wire                  nxt_pmu_regs_clken;
  wire                  nxt_pmu_cntrs_clken;
  wire            [4:0] event_cnt_number;
  wire [PMN_NUMBER-1:0] pmn_event;
  wire           [31:0] pmselr_rd;
  wire           [31:0] pmevcntr_rd  [PMN_NUMBER-1:0];
  wire           [31:0] pmuserenr_rd;
  wire           [31:0] pmceid0_rd;
  wire           [31:0] pmn_pmcr_rd;
  wire           [31:0] apb_pmn_pmcr_rd;
  wire           [31:0] pmcnten_rd;
  wire           [31:0] apb_pmcnten_rd;
  wire           [31:0] pmovsr_rd;
  wire           [31:0] apb_pmovsr_rd;
  wire           [31:0] apb_pmevtyper_rd [PMN_NUMBER-1:0];
  wire           [31:0] pmevtyper_rd [PMN_NUMBER-1:0];
  wire           [31:0] pmccfiltr_rd;
  wire           [31:0] pminten_rd;
  wire           [31:0] apb_pminten_rd;
  wire           [30:0] pmn_hyp_mask;
  wire [PMN_NUMBER-1:0] pmn_chain;
  wire                  npmuirq;
  wire [PMN_NUMBER-1:0] pmn_cp15_wrenable;
  wire                  pmn_perf_counter_reset_int;
  wire                  pmn_perf_counter_reset_ext;
  wire                  pmn_clock_counter_reset;
  wire                  nxt_pmn_en;
  wire                  nxt_pmn_clock_divide;
  wire                  nxt_pmn_export_enabled;
  wire                  nxt_pmn_disable_ccnt_when_prohibited;
  wire                  nxt_pmn_long_ccnt;
  wire [PMN_NUMBER-1:0] nxt_pmovsr_p;
  wire                  nxt_pmovsr_c;
  wire           [30:0] pmovsr_p;
  wire                  pmn_evntbus_allowed;
  wire                  en_pminten;
  wire                  en_pmovsr;
  wire [PMN_NUMBER-1:0] pmn_wrapped;
  wire                  ccnt_wrap_lo;
  wire                  ccnt_wrap_hi;
  wire                  ccnt_wrapped;
  wire [PMN_NUMBER-1:0] nxt_pmcnten_p;
  wire                  nxt_pmcnten_c;
  wire           [30:0] pmcnten_p;
  wire [PMN_NUMBER-1:0] nxt_pminten_p;
  wire                  nxt_pminten_c;
  wire           [30:0] pminten_p;
  wire [PMN_NUMBER-1:0] pmn_swincr;
  wire           [65:0] inc_pmccntr;
  wire                  divided_tick;
  wire                  ccnt_tick;
  wire            [5:0] nxt_clock_divider;
  wire                  en_pmccntr_early_ninc;
  wire                  en_pmccntr_early_inc;
  wire                  en_pmccntr_lo;
  wire                  en_pmccntr_hi;
  wire           [63:0] nxt_pmccntr;
  wire                  en_pmcnten;
  wire [PMN_NUMBER-1:0] en_pmevtyper;
  wire                  en_pmccfiltr;
  wire                  nxt_pmccfiltr_p;
  wire                  nxt_pmccfiltr_u;
  wire                  nxt_pmccfiltr_nsk;
  wire                  nxt_pmccfiltr_nsu;
  wire                  nxt_pmccfiltr_nsh;
  wire                  nxt_pmccfiltr_m;
  wire                  nxt_pmevtyper_p         [PMN_NUMBER-1:0];
  wire                  nxt_pmevtyper_u         [PMN_NUMBER-1:0];
  wire                  nxt_pmevtyper_nsk       [PMN_NUMBER-1:0];
  wire                  nxt_pmevtyper_nsu       [PMN_NUMBER-1:0];
  wire                  nxt_pmevtyper_nsh       [PMN_NUMBER-1:0];
  wire                  nxt_pmevtyper_m         [PMN_NUMBER-1:0];
  wire            [9:0] nxt_pmevtyper_evtcount  [PMN_NUMBER-1:0];
  wire           [32:0] nxt_pmevcntr            [PMN_NUMBER-1:0];
  wire           [32:0] inc_pmevcntr            [PMN_NUMBER-1:0];
  wire [PMN_NUMBER-1:0] mask_event;
  wire                  mask_ccnt;
  wire [PMN_NUMBER-1:0] en_pmevcntr_early_ninc;
  wire [PMN_NUMBER-1:0] en_pmevcntr_early_inc;
  wire [PMN_NUMBER-1:0] en_pmevcntr_lo;
  wire [PMN_NUMBER-1:0] en_pmevcntr_hi;
  wire [PMN_NUMBER-1:0] update_pmn_en;
  wire            [3:0] nxt_pmuserenr;
  wire           [25:0] nxt_dpu_pmn_evntbus;
  wire                  rd_cp15_crn9_pmcr;
  wire                  rd_cp15_crn9_pmncntenset;
  wire                  rd_cp15_crn9_pmncntenclr;
  wire                  rd_cp15_crn9_pmovsr;
  wire                  rd_cp15_crn9_pmovsset;
  wire                  rd_cp15_crn9_pmselr;
  wire                  rd_cp15_crn9_pmccntr;
  wire                  rd_cp15_crn9_pmccntr_64;
  wire                  rd_cp15_crn9_pmxevtyper;
  wire                  rd_cp15_crn9_pmxevcntr;
  wire                  rd_cp15_crn9_pmuserenr;
  wire                  rd_cp15_crn9_pmintenset;
  wire                  rd_cp15_crn9_pmintenclr;
  wire                  rd_cp15_crn9_pmceid0;
  wire [PMN_NUMBER-1:0] rd_cp15_crn14_pmevcntr;
  wire [PMN_NUMBER-1:0] rd_cp15_crn14_pmevtyper;
  wire                  rd_cp15_crn14_pmccfiltr;
  wire                  wr_cp15_crn9_pmcr;
  wire                  wr_cp15_crn9_pmncntenset;
  wire                  wr_cp15_crn9_pmncntenclr;
  wire                  wr_cp15_crn9_pmovsr;
  wire                  wr_cp15_crn9_pmovsset;
  wire                  wr_cp15_crn9_pmswinc;
  wire                  wr_cp15_crn9_pmselr;
  wire                  wr_cp15_crn9_pmccntr;
  wire                  wr_cp15_crn9_pmccntr_64;
  wire                  wr_cp15_crn9_pmxevtyper;
  wire                  wr_cp15_crn9_pmxevcntr;
  wire                  wr_cp15_crn9_pmuserenr;
  wire                  wr_cp15_crn9_pmintenset;
  wire                  wr_cp15_crn9_pmintenclr;
  wire [PMN_NUMBER-1:0] wr_cp15_crn14_pmevcntr;
  wire [PMN_NUMBER-1:0] wr_cp15_crn14_pmevtyper;
  wire                  wr_cp15_crn14_pmccfiltr;
  wire                  evnt_cntxtid_write;
  wire [PMN_NUMBER-1:0] wr_apb_pm_evcntr;
  wire                  wr_apb_pmccntr_lo;
  wire                  wr_apb_pmccntr_hi;
  wire [PMN_NUMBER-1:0] wr_apb_pm_evtyper;
  wire                  wr_apb_pmccfiltr;
  wire                  wr_apb_pmcntenset;
  wire                  wr_apb_pmcntenclr;
  wire                  wr_apb_pmintenset;
  wire                  wr_apb_pmintenclr;
  wire                  wr_apb_pmovsr;
  wire                  wr_apb_pmovsset;
  wire                  wr_apb_pmswinc;
  wire                  wr_apb_pmcr;
  wire                  wr_pmcr;
  wire                  evnt_mem_err;
  wire            [2:0] nxt_attr_evnt_iutlb_miss_cycle;
  wire            [2:0] nxt_attr_evnt_icache_miss_cycle;
  wire            [2:0] nxt_attr_evnt_pdc_err_cycle;
  wire                  recent_attr_evnt_iutlb_miss;
  wire                  recent_attr_evnt_icache_miss;
  wire                  recent_attr_evnt_pdc_err;
  wire [PMN_NUMBER-1:0] pmn_event_00_0f_en;
  wire [PMN_NUMBER-1:0] pmn_event_10_1f_en;
  wire [PMN_NUMBER-1:0] pmn_event_20_df_en;
  wire [PMN_NUMBER-1:0] pmn_event_e0_ef_en;
  wire                  event_00_0f_en;
  wire                  event_10_1f_en;
  wire                  event_20_df_en;
  wire                  event_e0_ef_en;
  wire                  attr_evnt_e0;
  wire                  attr_evnt_e1;
  wire                  attr_evnt_e2;
  wire                  attr_evnt_e3;
  wire                  attr_evnt_e4;
  wire                  attr_evnt_e5;
  wire                  attr_evnt_e6;
  wire                  attr_evnt_e7;
  wire                  attr_evnt_e8;
  wire                  nxt_evnt_instr_exec_rs;
  wire                  nxt_evnt_instr_exec_two_rs;
  wire                  nxt_evnt_sw_change_pc_rs;
  wire                  nxt_evnt_bus_acc_rs;
  wire                  nxt_evnt_bus_acc_two_rs;
  wire                  nxt_evnt_ext_mem_req_rs;
  wire                  nxt_evnt_ext_mem_req_two_rs;
  wire                  nxt_evnt_ext_mem_req_nc_rs;
  wire                  nxt_evnt_ext_mem_req_nc_two_rs;
  wire                  profiling_prohibited;
  wire           [31:0] pmu_cp_rd_data_32bit;
  wire           [63:0] pmu_cp_rd_data_64bit;
  wire                  clock_divider_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Function definition
  // ------------------------------------------------------

  function filter_event(input [1:0] el, input ns_state, input aarch64, input p, input u, input nsk, input nsu, input nsh, input m);
    case ({el, ns_state})
      {`CA53_EL0, 1'b0}: filter_event = u;
      {`CA53_EL0, 1'b1}: filter_event = (u != nsu);
      {`CA53_EL1, 1'b0}: filter_event = p;
      {`CA53_EL1, 1'b1}: filter_event = (p != nsk);
      {`CA53_EL2, 1'b1}: filter_event = ~nsh;
      {`CA53_EL3, 1'b0}: filter_event = aarch64 ? (p != m) : p;
      default: filter_event = 1'bx;
    endcase
  endfunction

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // Registers that are only written using MCR instructions or via the
  // APB interface can be gated using an intermediate clock gate
  assign nxt_pmu_regs_clken  = nxt_cp_valid_wr_i | nxt_pmu_apb_wr_i;

  // Counter registers should be enabled when there is a register write
  // or when the PMU is enabled
  assign nxt_pmu_cntrs_clken = nxt_pmu_regs_clken | hdcr_hpme_i | pmn_en | pmn_export_enabled;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pmu_regs_clken  <= 1'b1;
      pmu_cntrs_clken <= 1'b1;
    end else begin
      pmu_regs_clken  <= nxt_pmu_regs_clken;
      pmu_cntrs_clken <= nxt_pmu_cntrs_clken;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_pmu_regs (
    .clk_i         (clk),
    .clk_enable_i  (pmu_regs_clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_pmu_regs)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_pmu_cntrs (
    .clk_i         (clk),
    .clk_enable_i  (pmu_cntrs_clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_pmu_cntrs)
  );

  // ------------------------------------------------------
  // Register slice events
  // ------------------------------------------------------
  //
  // Register slice events in blocks to decouple timing paths from other units and save power

  // Enable the register slice only when either the performance monitors are enabled
  // or the event bus is enabled.

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_event_enables
    assign pmn_event_00_0f_en[n] = update_pmn_en[n] & pmcnten_p[n] & (pmevtyper_evtcount[n][9:4] == 6'h00);
    assign pmn_event_10_1f_en[n] = update_pmn_en[n] & pmcnten_p[n] & (pmevtyper_evtcount[n][9:4] == 6'h01);
    assign pmn_event_20_df_en[n] = update_pmn_en[n] & pmcnten_p[n] & (pmevtyper_evtcount[n][9:8] == 2'b00) &
                                   (pmevtyper_evtcount[n][7:5] != 3'b000) & (pmevtyper_evtcount[n][7:5] != 3'b111);
    assign pmn_event_e0_ef_en[n] = update_pmn_en[n] & pmcnten_p[n] & (pmevtyper_evtcount[n][9:4] == 6'h0e);
  end endgenerate

  // Events 00-0F
  assign event_00_0f_en = ((|pmn_event_00_0f_en) | pmn_export_enabled) & ~profiling_prohibited;

  assign nxt_evnt_instr_exec_rs     = |evnt_instr_exec_i;
  assign nxt_evnt_instr_exec_two_rs = &evnt_instr_exec_i;
  assign nxt_evnt_sw_change_pc_rs   = evnt_sw_change_pc_i | evnt_call_expt_taken_i;
  assign evnt_cntxtid_write = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CRN13_CID}) & ~stall_wr_i;

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n) begin
      evnt_ic_lf_rs          <= 1'b0;
      evnt_instr_pagewalk_rs <= 1'b0;
      evnt_rw_lf_rs          <= 1'b0;
      evnt_dc_access_rs      <= 1'b0;
      evnt_data_pagewalk_rs  <= 1'b0;
      evnt_data_rd_wr_rs     <= 1'b0;
      evnt_data_wr_wr_rs     <= 1'b0;
      evnt_instr_exec_rs     <= 1'b0;
      evnt_instr_exec_two_rs <= 1'b0;
      evnt_expt_taken_rs     <= 1'b0;
      evnt_expt_rtn_ret_rs   <= 1'b0;
      evnt_cntxtid_write_rs  <= 1'b0;
      evnt_sw_change_pc_rs   <= 1'b0;
      evnt_br_direct_wr_rs   <= 1'b0;
      evnt_unaligned_ls_rs   <= 1'b0;
    end else if (event_00_0f_en) begin
      evnt_ic_lf_rs          <= ifu_evnt_ic_lf_i;
      evnt_instr_pagewalk_rs <= tlb_evnt_instr_pagewalk_i;
      evnt_rw_lf_rs          <= biu_evnt_rw_lf_i;
      evnt_dc_access_rs      <= dcu_evnt_dc_access_i;
      evnt_data_pagewalk_rs  <= tlb_evnt_data_pagewalk_i;
      evnt_data_rd_wr_rs     <= evnt_data_rd_wr_i;
      evnt_data_wr_wr_rs     <= evnt_data_wr_wr_i;
      evnt_instr_exec_rs     <= nxt_evnt_instr_exec_rs;
      evnt_instr_exec_two_rs <= nxt_evnt_instr_exec_two_rs;
      evnt_expt_taken_rs     <= evnt_expt_taken_i;
      evnt_expt_rtn_ret_rs   <= expt_rtn_ret_i;
      evnt_cntxtid_write_rs  <= evnt_cntxtid_write;
      evnt_sw_change_pc_rs   <= nxt_evnt_sw_change_pc_rs;
      evnt_br_direct_wr_rs   <= evnt_br_direct_wr_i;
      evnt_unaligned_ls_rs   <= evnt_unaligned_ls_i;
    end

  // Events 10-1F
  assign event_10_1f_en = ((|pmn_event_10_1f_en) | pmn_export_enabled) & ~profiling_prohibited;

  assign nxt_evnt_bus_acc_rs     = scu_evnt_bus_acc_rd_i | scu_evnt_bus_acc_wr_i;
  assign nxt_evnt_bus_acc_two_rs = scu_evnt_bus_acc_rd_i & scu_evnt_bus_acc_wr_i;

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n) begin
      evnt_br_mispred_rs      <= 1'b0;
      evnt_br_valid_wr_rs     <= 1'b0;
      evnt_data_mem_access_rs <= 1'b0;
      evnt_ic_access_rs       <= 1'b0;
      evnt_eviction_rs        <= 1'b0;
      evnt_l2_access_rs       <= 1'b0;
      evnt_l2_refill_rs       <= 1'b0;
      evnt_l2_wb_rs           <= 1'b0;
      evnt_bus_acc_rs         <= 1'b0;
      evnt_bus_acc_two_rs     <= 1'b0;
      evnt_bus_cycle_rs       <= 1'b0;
    end else if (event_10_1f_en) begin
      evnt_br_mispred_rs      <= evnt_br_mispred_i;
      evnt_br_valid_wr_rs     <= evnt_br_valid_wr_i;
      evnt_data_mem_access_rs <= evnt_data_mem_access_i;
      evnt_ic_access_rs       <= ifu_evnt_ic_access_i;
      evnt_eviction_rs        <= scu_evnt_eviction_i;
      evnt_l2_access_rs       <= scu_evnt_l2_access_i;
      evnt_l2_refill_rs       <= scu_evnt_l2_refill_i;
      evnt_l2_wb_rs           <= scu_evnt_l2_wb_i;
      evnt_bus_acc_rs         <= nxt_evnt_bus_acc_rs;
      evnt_bus_acc_two_rs     <= nxt_evnt_bus_acc_two_rs;
      evnt_bus_cycle_rs       <= scu_evnt_bus_cycle_i;
    end

  // Events 20-DF
  // None of these events feed PMUEVENT, so don't need to factor pmn_export_enabled in
  assign event_20_df_en = (|pmn_event_20_df_en) & ~profiling_prohibited;

  assign nxt_evnt_ext_mem_req_rs        = |biu_evnt_ext_mem_req_i;
  assign nxt_evnt_ext_mem_req_two_rs    = &biu_evnt_ext_mem_req_i;
  assign nxt_evnt_ext_mem_req_nc_rs     = |biu_evnt_ext_mem_req_nc_i;
  assign nxt_evnt_ext_mem_req_nc_two_rs = &biu_evnt_ext_mem_req_nc_i;

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n) begin
      evnt_bus_acc_rd_rs               <= 1'b0;
      evnt_bus_acc_wr_rs               <= 1'b0;
      evnt_br_indirect_rs              <= 1'b0;
      evnt_irq_taken_rs                <= 1'b0;
      evnt_fiq_taken_rs                <= 1'b0;
      evnt_ext_mem_req_rs              <= 1'b0;
      evnt_ext_mem_req_two_rs          <= 1'b0;
      evnt_ext_mem_req_nc_rs           <= 1'b0;
      evnt_ext_mem_req_nc_two_rs       <= 1'b0;
      evnt_pf_lf_rs                    <= 1'b0;
      evnt_throttle_rs                 <= 1'b0;
      evnt_ramode_enter_rs             <= 1'b0;
      evnt_ramode_rs                   <= 1'b0;
      evnt_pdc_valid_rs                <= 1'b0;
      evnt_stb_stall_rs                <= 1'b0;
      evnt_snooped_data_rs             <= 1'b0;
      evnt_br_cond_predict_rs          <= 1'b0;
      evnt_br_indirect_mispred_rs      <= 1'b0;
      evnt_br_indirect_mispred_addr_rs <= 1'b0;
      evnt_br_cond_mispredict_rs       <= 1'b0;
    end else if (event_20_df_en) begin
      evnt_bus_acc_rd_rs               <= scu_evnt_bus_acc_rd_i;
      evnt_bus_acc_wr_rs               <= scu_evnt_bus_acc_wr_i;
      evnt_br_indirect_rs              <= evnt_br_indirect_i;
      evnt_irq_taken_rs                <= evnt_irq_taken_i;
      evnt_fiq_taken_rs                <= evnt_fiq_taken_i;
      evnt_ext_mem_req_rs              <= nxt_evnt_ext_mem_req_rs;
      evnt_ext_mem_req_two_rs          <= nxt_evnt_ext_mem_req_two_rs;
      evnt_ext_mem_req_nc_rs           <= nxt_evnt_ext_mem_req_nc_rs;
      evnt_ext_mem_req_nc_two_rs       <= nxt_evnt_ext_mem_req_nc_two_rs;
      evnt_pf_lf_rs                    <= biu_evnt_pf_lf_i;
      evnt_throttle_rs                 <= ifu_evnt_throttle_i;
      evnt_ramode_enter_rs             <= biu_evnt_ramode_enter_i;
      evnt_ramode_rs                   <= biu_evnt_ramode_i;
      evnt_pdc_valid_rs                <= ifu_evnt_pdc_valid_i;
      evnt_stb_stall_rs                <= stb_evnt_stb_stall_i;
      evnt_snooped_data_rs             <= scu_evnt_snooped_data_i;
      evnt_br_cond_predict_rs          <= dpu_pred_br_wr_i;
      evnt_br_indirect_mispred_rs      <= evnt_br_indirect_mispred_i;
      evnt_br_indirect_mispred_addr_rs <= evnt_br_indirect_mispred_addr_i;
      evnt_br_cond_mispredict_rs       <= dpu_mispred_wr_i;
    end

  // Events e0-eF
  // None of these events feed PMUEVENT, so don't need to factor pmn_export_enabled in
  assign event_e0_ef_en = (|pmn_event_e0_ef_en) & ~profiling_prohibited;

  assign nxt_attr_evnt_iutlb_miss_cycle  = {attr_evnt_iutlb_miss_cycle[1:0],  ifu_evnt_iutlb_miss_wait_i};
  assign nxt_attr_evnt_icache_miss_cycle = {attr_evnt_icache_miss_cycle[1:0], ifu_evnt_ic_miss_wait_i};
  assign nxt_attr_evnt_pdc_err_cycle     = {attr_evnt_pdc_err_cycle[1:0],     ifu_evnt_pdc_valid_i};

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n) begin
      attr_evnt_iq_empty          <= 1'b0;
      attr_evnt_iutlb_miss_cycle  <= {3{1'b0}};
      attr_evnt_icache_miss_cycle <= {3{1'b0}};
      attr_evnt_pdc_err_cycle     <= {3{1'b0}};
      attr_evnt_ilock             <= 1'b0;
      attr_evnt_ilock_fpu         <= 1'b0;
      attr_evnt_ilock_agu         <= 1'b0;
      attr_evnt_stall_wr          <= 1'b0;
      attr_evnt_ls_valid_wr       <= 1'b0;
      attr_evnt_ls_store_wr       <= 1'b0;
    end else if (event_e0_ef_en) begin
      attr_evnt_iq_empty          <= evnt_iq_empty_i;
      attr_evnt_iutlb_miss_cycle  <= nxt_attr_evnt_iutlb_miss_cycle;
      attr_evnt_icache_miss_cycle <= nxt_attr_evnt_icache_miss_cycle;
      attr_evnt_pdc_err_cycle     <= nxt_attr_evnt_pdc_err_cycle;
      attr_evnt_ilock             <= interlock_iss_i;
      attr_evnt_ilock_fpu         <= evnt_fpu_interlock_iss_i;
      attr_evnt_ilock_agu         <= evnt_agu_interlock_iss_i;
      attr_evnt_stall_wr          <= stall_wr_i;
      attr_evnt_ls_valid_wr       <= ls_valid_wr_i;
      attr_evnt_ls_store_wr       <= ls_store_wr_i;
    end

  // Combine memory error events together for architectural counter
  assign evnt_mem_err = evnt_mem_err_ifu_i | evnt_mem_err_dcu_i | evnt_mem_err_tlb_i;

  // ------------------------------------------------------
  // Attributable performance degradation events
  // ------------------------------------------------------
  //
  // Construct indicators that allow performance degradation to be attributed to
  // specific structures or areas of the design.

  // Recent events
  assign recent_attr_evnt_iutlb_miss  = |attr_evnt_iutlb_miss_cycle[2:0];
  assign recent_attr_evnt_icache_miss = |attr_evnt_icache_miss_cycle[2:0];
  assign recent_attr_evnt_pdc_err     = |attr_evnt_pdc_err_cycle[2:0];

  // IQ is empty and there has:
  // - not been a micro-TLB miss or instruction cache miss or pre-decode error recently
  // - been an instruction cache miss recently
  // - been an instruction micro-TLB miss recently
  // - been a pre-decode error recently
  assign attr_evnt_e0 = attr_evnt_iq_empty & ~recent_attr_evnt_icache_miss & ~recent_attr_evnt_iutlb_miss & ~recent_attr_evnt_pdc_err;
  assign attr_evnt_e1 = attr_evnt_iq_empty &  recent_attr_evnt_icache_miss;
  assign attr_evnt_e2 = attr_evnt_iq_empty                                 &  recent_attr_evnt_iutlb_miss;
  assign attr_evnt_e3 = attr_evnt_iq_empty                                                                &  recent_attr_evnt_pdc_err;

  // Interlock while not stalled and:
  // - not due to the AGU or Float/NEON datapath
  // - AGU
  // - Float/NEON datapath instruction in Iss
  assign attr_evnt_e4 = attr_evnt_ilock & ~attr_evnt_stall_wr & ~attr_evnt_ilock_agu & ~attr_evnt_ilock_fpu;
  assign attr_evnt_e5 = attr_evnt_ilock & ~attr_evnt_stall_wr &  attr_evnt_ilock_agu;
  assign attr_evnt_e6 = attr_evnt_ilock & ~attr_evnt_stall_wr                        &  attr_evnt_ilock_fpu;

  // Stall in Wr due to a:
  // - Load
  // - Store
  assign attr_evnt_e7 = attr_evnt_stall_wr & attr_evnt_ls_valid_wr & ~attr_evnt_ls_store_wr;
  assign attr_evnt_e8 = attr_evnt_stall_wr & attr_evnt_ls_valid_wr &  attr_evnt_ls_store_wr;

  // ------------------------------------------------------
  // Read enable generation
  // ------------------------------------------------------

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_cp_rd_dec
    assign rd_cp15_crn14_pmevcntr[n]  = (raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CRN14_PMEVCNTRn(n)});
    assign rd_cp15_crn14_pmevtyper[n] = (raw_cp_decode_wr_i[8:0] == {1'b0, `CA53_CRN14_PMEVTYPERn(n)});
  end endgenerate

  assign rd_cp15_crn9_pmcr            = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[15];
  assign rd_cp15_crn9_pmncntenset     = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[14];
  assign rd_cp15_crn9_pmncntenclr     = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[13];
  assign rd_cp15_crn9_pmovsr          = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[12];
  assign rd_cp15_crn9_pmovsset        = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[11];
  assign rd_cp15_crn9_pmselr          = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 9];
  assign rd_cp15_crn9_pmccntr         = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 8];
  assign rd_cp15_crn9_pmccntr_64      = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 7];
  assign rd_cp15_crn9_pmxevtyper      = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 6];
  assign rd_cp15_crn9_pmxevcntr       = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 5];
  assign rd_cp15_crn9_pmuserenr       = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 4];
  assign rd_cp15_crn9_pmintenset      = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 3];
  assign rd_cp15_crn9_pmintenclr      = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 2];
  assign rd_cp15_crn9_pmceid0         = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 1];
  assign rd_cp15_crn14_pmccfiltr      = ~raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 0];

  // ------------------------------------------------------
  // Write enable generation
  // ------------------------------------------------------

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_cp_wr_dec
    assign wr_cp15_crn14_pmevcntr[n]    = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CRN14_PMEVCNTRn(n)});
    assign wr_cp15_crn14_pmevtyper[n]   = cp_valid_wr_i & (raw_cp_decode_wr_i[8:0] == {1'b1, `CA53_CRN14_PMEVTYPERn(n)});
  end endgenerate

  assign wr_cp15_crn9_pmcr            = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[15];
  assign wr_cp15_crn9_pmncntenset     = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[14];
  assign wr_cp15_crn9_pmncntenclr     = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[13];
  assign wr_cp15_crn9_pmovsr          = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[12];
  assign wr_cp15_crn9_pmovsset        = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[11];
  assign wr_cp15_crn9_pmswinc         = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[10];
  assign wr_cp15_crn9_pmselr          = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 9];
  assign wr_cp15_crn9_pmccntr         = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 8];
  assign wr_cp15_crn9_pmccntr_64      = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 7];
  assign wr_cp15_crn9_pmxevtyper      = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 6];
  assign wr_cp15_crn9_pmxevcntr       = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 5];
  assign wr_cp15_crn9_pmuserenr       = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 4];
  assign wr_cp15_crn9_pmintenset      = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 3];
  assign wr_cp15_crn9_pmintenclr      = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 2];
  assign wr_cp15_crn14_pmccfiltr      = cp_valid_wr_i & raw_cp_decode_wr_i[8] & cp15_pmu_access_wr_i[ 0];

  // ------------------------------------------------------
  // APB Memory-mapped access to PMU registers
  // ------------------------------------------------------

  always @* begin : p_apb_rd
    integer i;
    reg [31:0] tmp_apb_pmn_rd_data;

    tmp_apb_pmn_rd_data = {32{1'b0}};

    for (i = 0; i < PMN_NUMBER; i = i + 1) begin
      tmp_apb_pmn_rd_data = tmp_apb_pmn_rd_data |
                            ({32{apb_addr_i == `CA53_PMU_PMEVCNTRn_EL0(i)}}  & pmevcntr[i]) |
                            ({32{apb_addr_i == `CA53_PMU_PMEVTYPERn_EL0(i)}} & apb_pmevtyper_rd[i]);
    end

    apb_pmn_rd_data = tmp_apb_pmn_rd_data;
  end

  assign pmu_apb_rdata_o = apb_pmn_rd_data                                                          |
                           ({32{apb_addr_i == `CA53_PMU_PMCCNTR_EL0_lo}} & pmccntr[31: 0])          |
                           ({32{apb_addr_i == `CA53_PMU_PMCCNTR_EL0_hi}} & pmccntr[63:32])          |
                           ({32{apb_addr_i == `CA53_PMU_PMCCFILTR_EL0}}  & pmccfiltr_rd)            |
                           ({32{apb_addr_i == `CA53_PMU_PMCNTENSET_EL0}} & apb_pmcnten_rd)          |
                           ({32{apb_addr_i == `CA53_PMU_PMCNTENCLR_EL0}} & apb_pmcnten_rd)          |
                           ({32{apb_addr_i == `CA53_PMU_PMINTENSET_EL1}} & apb_pminten_rd)          |
                           ({32{apb_addr_i == `CA53_PMU_PMINTENCLR_EL1}} & apb_pminten_rd)          |
                           ({32{apb_addr_i == `CA53_PMU_PMOVSCLR_EL0}}   & apb_pmovsr_rd)           |
                           ({32{apb_addr_i == `CA53_PMU_PMOVSSET_EL0}}   & apb_pmovsr_rd)           |
                           ({32{apb_addr_i == `CA53_PMU_PMCFGR}}         & `CA53_PMCFGR_READ_VALUE) |
                           ({32{apb_addr_i == `CA53_PMU_PMCR_EL0}}       & apb_pmn_pmcr_rd)         |
                           ({32{apb_addr_i == `CA53_PMU_PMCEID0_EL0}}    & pmceid0_rd);

  assign apb_pmu_access_o  = ((apb_addr_i[11:8] == 4'b0000) | (apb_addr_i[11:7] == 5'b01000) |
                              (apb_addr_i == `CA53_PMU_PMCNTENSET_EL0)   |
                              (apb_addr_i == `CA53_PMU_PMCNTENCLR_EL0)   |
                              (apb_addr_i == `CA53_PMU_PMINTENSET_EL1)   |
                              (apb_addr_i == `CA53_PMU_PMINTENCLR_EL1)   |
                              (apb_addr_i == `CA53_PMU_PMOVSCLR_EL0)     |
                              (apb_addr_i == `CA53_PMU_PMSWINC_EL0)      |
                              (apb_addr_i == `CA53_PMU_PMOVSSET_EL0)     |
                              (apb_addr_i == `CA53_PMU_PMCFGR)           |
                              (apb_addr_i == `CA53_PMU_PMCR_EL0)         |
                              (apb_addr_i == `CA53_PMU_PMCEID0_EL0)      |
                              (apb_addr_i == `CA53_PMU_PMCEID1_EL0));

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_apb_dec
    assign wr_apb_pm_evcntr[n]  = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMEVCNTRn_EL0(n));
    assign wr_apb_pm_evtyper[n] = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMEVTYPERn_EL0(n));
  end endgenerate

  assign wr_apb_pmccntr_lo    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCCNTR_EL0_lo);
  assign wr_apb_pmccntr_hi    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCCNTR_EL0_hi);
  assign wr_apb_pmccfiltr     = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCCFILTR_EL0);
  assign wr_apb_pmcntenset    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCNTENSET_EL0);
  assign wr_apb_pmcntenclr    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCNTENCLR_EL0);
  assign wr_apb_pmintenset    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMINTENSET_EL1);
  assign wr_apb_pmintenclr    = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMINTENCLR_EL1);
  assign wr_apb_pmovsr        = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMOVSCLR_EL0);
  assign wr_apb_pmovsset      = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMOVSSET_EL0);
  assign wr_apb_pmswinc       = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMSWINC_EL0);
  assign wr_apb_pmcr          = pmu_apb_wr_i & (apb_addr_i == `CA53_PMU_PMCR_EL0);

  // ------------------------------------------------------
  // Permission controls for PMU
  // ------------------------------------------------------

  assign profiling_prohibited = ~(ns_state_i | cp_mdcr_el3_spme_i | dbg_non_inv_perm_synced_i);
  
  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_perms
    assign pmn_hyp_mask[n] = ~ns_state_i | (dpu_exception_level_i == `CA53_EL2) | (n[4:0] < hdcr_hpmn_i);

    assign update_pmn_en[n] = (hdcr_hpmn_i <= n[4:0]) ? hdcr_hpme_i : pmn_en;
  end endgenerate

  generate for (n = PMN_NUMBER; n < 31; n = n + 1) begin: g_perms_stubs
    assign pmn_hyp_mask[n] = 1'b0;
  end endgenerate

  // ------------------------------------------------------
  // PMCR/PMCR_EL0 Performance Monitors Control Register
  // ------------------------------------------------------

  assign pmn_perf_counter_reset_int = (wr_cp15_crn9_pmcr & mcr_data_wr_i[1]);
  assign pmn_perf_counter_reset_ext =                                          (wr_apb_pmcr & apb_wdata_i[1]);
  assign pmn_clock_counter_reset    = (wr_cp15_crn9_pmcr & mcr_data_wr_i[2]) | (wr_apb_pmcr & apb_wdata_i[2]);

  assign nxt_pmn_en                           = wr_apb_pmcr ? apb_wdata_i[0] : mcr_data_wr_i[0];
  assign nxt_pmn_clock_divide                 = wr_apb_pmcr ? apb_wdata_i[3] : mcr_data_wr_i[3];
  assign nxt_pmn_export_enabled               = wr_apb_pmcr ? apb_wdata_i[4] : mcr_data_wr_i[4];
  assign nxt_pmn_disable_ccnt_when_prohibited = wr_apb_pmcr ? apb_wdata_i[5] : mcr_data_wr_i[5];
  assign nxt_pmn_long_ccnt                    = wr_apb_pmcr ? apb_wdata_i[6] : mcr_data_wr_i[6];

  assign wr_pmcr = wr_apb_pmcr | wr_cp15_crn9_pmcr;

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n) begin
      pmn_en                           <= 1'b0;
      pmn_clock_divide                 <= 1'b0;
      pmn_export_enabled               <= 1'b0;
      pmn_disable_ccnt_when_prohibited <= 1'b0;
      pmn_long_ccnt                    <= 1'b0;
    end else if (wr_pmcr) begin
      pmn_en                           <= nxt_pmn_en;
      pmn_clock_divide                 <= nxt_pmn_clock_divide;
      pmn_export_enabled               <= nxt_pmn_export_enabled;
      pmn_disable_ccnt_when_prohibited <= nxt_pmn_disable_ccnt_when_prohibited;
      pmn_long_ccnt                    <= nxt_pmn_long_ccnt;
    end

  assign event_cnt_number = (ns_state_i & (dpu_exception_level_i < `CA53_EL2) & (hdcr_hpmn_i <= PMN_NUMBER[4:0])) ? hdcr_hpmn_i : PMN_NUMBER[4:0];

  assign pmn_pmcr_rd      = {`CA53_IMPLEMENTOR,                // 31:24 IMP Implementor code
                             `CA53_PART_NUM_7_0,               // 23:16 IDCODE
                             event_cnt_number,                 // 15:11 N Number of counters implemented
                             4'h0,                             // 10:7  RAZ
                             pmn_long_ccnt,                    // 6     LC    
                             pmn_disable_ccnt_when_prohibited, // 5     DP
                             pmn_export_enabled,               // 4     X
                             pmn_clock_divide,                 // 3     D
                             1'b0,                             // 2     C
                             1'b0,                             // 1     P
                             pmn_en};                          // 0     E

  assign apb_pmn_pmcr_rd = { {25{1'b0}},                      // 31:7  RAZ
                            pmn_long_ccnt,                    // 6     LC
                            pmn_disable_ccnt_when_prohibited, // 5     DP
                            pmn_export_enabled,               // 4     X
                            pmn_clock_divide,                 // 3     D
                            1'b0,                             // 2     C
                            1'b0,                             // 1     P
                            pmn_en};                          // 0     E

  // ------------------------------------------------------
  // PMCNTENSET/PMCNTENSET_EL0 Count Enable Set Register
  // PMCNTENCLR/PMCNTENCLR_EL0 Count Enable Clear Register
  // ------------------------------------------------------

  assign en_pmcnten = wr_apb_pmcntenset | wr_apb_pmcntenclr | wr_cp15_crn9_pmncntenset | wr_cp15_crn9_pmncntenclr;

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_pmcnten_p
    assign nxt_pmcnten_p[n] =     (  pmcnten_p[n]
                                   | (wr_apb_pmcntenset        & apb_wdata_i[n])
                                   | (wr_cp15_crn9_pmncntenset & mcr_data_wr_i[n] & pmn_hyp_mask[n]))  // Counter enable
                               & ~(  (wr_apb_pmcntenclr        & apb_wdata_i[n])
                                   | (wr_cp15_crn9_pmncntenclr & mcr_data_wr_i[n] & pmn_hyp_mask[n])); // Counter disable
  end endgenerate

  assign nxt_pmcnten_c =     (  pmcnten_c
                              | (wr_apb_pmcntenset        & apb_wdata_i[31])
                              | (wr_cp15_crn9_pmncntenset & mcr_data_wr_i[31]))  // Counter enable
                          & ~(  (wr_apb_pmcntenclr        & apb_wdata_i[31])
                              | (wr_cp15_crn9_pmncntenclr & mcr_data_wr_i[31])); // Counter disable

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n) begin
      pmcnten_c     <= 1'b0;
      int_pmcnten_p <= {PMN_NUMBER{1'b0}};
    end else if (en_pmcnten) begin
      pmcnten_c     <= nxt_pmcnten_c;
      int_pmcnten_p <= nxt_pmcnten_p;
    end

  assign pmcnten_p[PMN_NUMBER-1:0] = int_pmcnten_p;

  generate if (PMN_NUMBER < 31) begin : g_pmcnten_p_stubs
    assign pmcnten_p[30:PMN_NUMBER] = {31-PMN_NUMBER{1'b0}};
  end endgenerate

  assign pmcnten_rd = {pmcnten_c,
                       pmcnten_p & pmn_hyp_mask};

  assign apb_pmcnten_rd = {pmcnten_c,
                           pmcnten_p};

  // ------------------------------------------------------
  // PMOVSSET/PMOVSSET_EL0 Overflow Flag Status Set register
  // PMOVSR  /PMOVSCLR_EL0 Overflow Flag Status Clear register
  // ------------------------------------------------------

  assign en_pmovsr = (|pmn_wrapped) | ccnt_wrapped |
                     wr_apb_pmovsr | wr_cp15_crn9_pmovsr |
                     wr_apb_pmovsset | wr_cp15_crn9_pmovsset;

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_pmovsr_p
    assign nxt_pmovsr_p[n]   = (pmovsr_p[n] | pmn_wrapped[n] | (wr_apb_pmovsset & apb_wdata_i[n]) |
                               (wr_cp15_crn9_pmovsset & pmn_hyp_mask[n] & mcr_data_wr_i[n]))
                               & ~(wr_cp15_crn9_pmovsr & pmn_hyp_mask[n] & mcr_data_wr_i[n])
                               & ~(wr_apb_pmovsr       & apb_wdata_i[n]);
  end endgenerate

  assign nxt_pmovsr_c = (pmovsr_c | ccnt_wrapped | (wr_apb_pmovsset & apb_wdata_i[31]) |
                        (wr_cp15_crn9_pmovsset & mcr_data_wr_i[31]))
                        & ~(wr_cp15_crn9_pmovsr & mcr_data_wr_i[31])
                        & ~(wr_apb_pmovsr       & apb_wdata_i[31]);

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n) begin
      pmovsr_c     <= 1'b0;
      int_pmovsr_p <= {PMN_NUMBER{1'b0}};
    end else if (en_pmovsr) begin
      pmovsr_c     <= nxt_pmovsr_c;
      int_pmovsr_p <= nxt_pmovsr_p;
    end

  assign pmovsr_p[PMN_NUMBER-1:0] = int_pmovsr_p;

  generate if (PMN_NUMBER < 31) begin : g_pmovsr_p_stubs
    assign pmovsr_p[30:PMN_NUMBER] = {31-PMN_NUMBER{1'b0}};
  end endgenerate

  assign pmovsr_rd = {pmovsr_c,
                      pmovsr_p & pmn_hyp_mask};

  assign apb_pmovsr_rd = {pmovsr_c,
                          pmovsr_p};

  // ------------------------------------------------------
  // PMSWINC/PMSWINC_EL0 Software increment Register
  // ------------------------------------------------------

  assign pmn_swincr = ({PMN_NUMBER{wr_apb_pmswinc}}       & apb_wdata_i[PMN_NUMBER-1:0]) |
                      ({PMN_NUMBER{wr_cp15_crn9_pmswinc}} & mcr_data_wr_i[PMN_NUMBER-1:0] & pmn_hyp_mask[PMN_NUMBER-1:0]);

  // ------------------------------------------------------
  // PMSELR/PMSELR_EL0 Event Counter Selection Register
  // ------------------------------------------------------

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n)
      pmselr_sel <= 5'b00000;
    else if (wr_cp15_crn9_pmselr)
      pmselr_sel <= mcr_data_wr_i[4:0];

  assign pmselr_rd = { {27{1'b0}},
                       pmselr_sel};

  // ------------------------------------------------------
  // PMXEVTYPER/PMXEVTYPER_EL0 Selected Event Type and Filter Register
  // ------------------------------------------------------

  always @* begin: p_pmxevtyper
    integer i;
    reg [31:0] tmp_pmxevtyper_rd;

    tmp_pmxevtyper_rd = {32{1'b0}};

    for (i = 0; i < PMN_NUMBER; i = i + 1) begin
      tmp_pmxevtyper_rd = tmp_pmxevtyper_rd | ({32{pmselr_sel == i[4:0]}} & pmevtyper_rd[i]);
    end

    tmp_pmxevtyper_rd = tmp_pmxevtyper_rd | ({32{pmselr_sel == 5'b11111}} & pmccfiltr_rd);

    pmxevtyper_rd = tmp_pmxevtyper_rd;
  end

  // ------------------------------------------------------
  // PMXEVCNTR/PMXEVCNTR_EL0 Selected Counter Register
  // ------------------------------------------------------

  always @* begin: p_pmxevcntr
    integer i;
    reg [31:0] tmp_pmxevcntr_rd;

    tmp_pmxevcntr_rd = {32{1'b0}};

    for (i = 0; i < PMN_NUMBER; i = i + 1) begin
      tmp_pmxevcntr_rd = tmp_pmxevcntr_rd | ({32{pmselr_sel == i[4:0]}} & pmevcntr_rd[i]);
    end

    pmxevcntr_rd = tmp_pmxevcntr_rd;
  end

  // ------------------------------------------------------
  // PMCEIDn/PMCEIDn_EL0 Common Event Identification registers
  // ------------------------------------------------------

  assign pmceid0_rd = `CA53_PMCEID0_READ_VALUE;

  // ------------------------------------------------------
  // PMCCNTR/PMCCNTR_EL0 Performance Monitors Cycle Counter
  // ------------------------------------------------------

  assign nxt_clock_divider = clock_divider + 1'b1;

  assign clock_divider_en = pmn_en & pmn_clock_divide;

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n)
      clock_divider <= 6'h00;
    else if (clock_divider_en)
      clock_divider <= nxt_clock_divider;

  assign divided_tick = (clock_divider == 6'h00);

  assign ccnt_tick = (pmn_clock_divide & ~pmn_long_ccnt) ? divided_tick : 1'b1;

  assign inc_pmccntr = {pmccntr[63:32], 1'b1, pmccntr[31:0]} + 1'b1;

  assign {ccnt_wrap_lo, nxt_pmccntr[31: 0]} = wr_apb_pmccntr_lo         ? {1'b0, apb_wdata_i[31: 0]}              :
                                              (wr_cp15_crn9_pmccntr |
                                               wr_cp15_crn9_pmccntr_64) ? {1'b0, mcr_data_wr_i[31: 0]}            :
                                              pmn_clock_counter_reset   ? 33'h0_0000_0000                         :
                                              en_pmccntr_early_inc      ? {~inc_pmccntr[32], inc_pmccntr[31: 0]}  :
                                                                          {1'b0, pmccntr[31: 0]};

  assign {ccnt_wrap_hi, nxt_pmccntr[63:32]} = wr_apb_pmccntr_hi         ? {1'b0, apb_wdata_i[31: 0]}   :
                                              wr_cp15_crn9_pmccntr_64   ? {1'b0, mcr_data_wr_i[63:32]} :
                                              pmn_clock_counter_reset   ? 33'h0_0000_0000              :
                                              en_pmccntr_early_inc      ? inc_pmccntr[65:33]           :
                                                                          {1'b0, pmccntr[63:32]};

  assign ccnt_wrapped = (pmn_long_ccnt ? ccnt_wrap_hi : ccnt_wrap_lo) & en_pmccntr_lo;

  assign mask_ccnt = filter_event(dpu_exception_level_i, ns_state_i, aarch64_state_i, pmccfiltr_p, pmccfiltr_u,
                                  pmccfiltr_nsk, pmccfiltr_nsu, pmccfiltr_nsh, pmccfiltr_m);

  // Create hi and lo enables based on whether we're doing an increment (inc) that only needs to enable
  // the upper 56-bits if we're going to wrap, or a no-increment (ninc) on a full counter width write
  assign en_pmccntr_early_ninc = pmn_clock_counter_reset | wr_apb_pmccntr_lo | wr_apb_pmccntr_hi | wr_cp15_crn9_pmccntr | wr_cp15_crn9_pmccntr_64;
  assign en_pmccntr_early_inc  = pmn_en & ccnt_tick & pmcnten_c & ~mask_ccnt & ~dbgdscr_halted_i & ~(profiling_prohibited & pmn_disable_ccnt_when_prohibited);

  assign en_pmccntr_lo = en_pmccntr_early_ninc |  en_pmccntr_early_inc;
  assign en_pmccntr_hi = en_pmccntr_early_ninc | (en_pmccntr_early_inc & pmccntr[7:0] == {8{1'b1}});

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n)
      pmccntr[63:8] <= {56{1'b0}};
    else if (en_pmccntr_hi)
      pmccntr[63:8] <= nxt_pmccntr[63:8];

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n)
      pmccntr[7:0] <= {8{1'b0}};
    else if (en_pmccntr_lo)
      pmccntr[7:0] <= nxt_pmccntr[7:0];

  // ------------------------------------------------------
  // PMUSERENR/PMUSERENR_EL0 User Enable Register
  // ------------------------------------------------------

  assign nxt_pmuserenr = mcr_data_wr_i[3:0];

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n)
      pmuserenr <= {4{1'b0}};
    else if (wr_cp15_crn9_pmuserenr)
      pmuserenr <= nxt_pmuserenr;

  assign pmuserenr_rd = {{28{1'b0}}, pmuserenr};

  // ------------------------------------------------------
  // PMINTENSET/PMINTENSET_EL1 Interrupt Enable Set register
  // PMINTENCLR/PMINTENCLR_EL1 Interrupt Enable Clear register
  // ------------------------------------------------------

  assign en_pminten = wr_apb_pmintenset | wr_apb_pmintenclr | wr_cp15_crn9_pmintenset | wr_cp15_crn9_pmintenclr;

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_pmn_int_enable
    assign nxt_pminten_p[n] =     (  pminten_p[n]
                                   | (wr_apb_pmintenset       & apb_wdata_i[n])
                                   | (wr_cp15_crn9_pmintenset & mcr_data_wr_i[n] & pmn_hyp_mask[n]))  // Counter enable
                               & ~(  (wr_apb_pmintenclr       & apb_wdata_i[n])
                                   | (wr_cp15_crn9_pmintenclr & mcr_data_wr_i[n] & pmn_hyp_mask[n])); // Counter disable
  end endgenerate

  assign nxt_pminten_c =     (  pminten_c
                              | (wr_apb_pmintenset       & apb_wdata_i[31])
                              | (wr_cp15_crn9_pmintenset & mcr_data_wr_i[31]))  // Counter enable
                          & ~(  (wr_apb_pmintenclr       & apb_wdata_i[31])
                              | (wr_cp15_crn9_pmintenclr & mcr_data_wr_i[31])); // Counter disable

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n) begin
      pminten_c     <= 1'b0;
      int_pminten_p <= {PMN_NUMBER{1'b0}};
    end else if (en_pminten) begin
      pminten_c     <= nxt_pminten_c;
      int_pminten_p <= nxt_pminten_p;
    end

  assign pminten_p[PMN_NUMBER-1:0] = int_pminten_p;

  generate if (PMN_NUMBER < 31) begin : g_pminten_p_stubs
    assign pminten_p[30:PMN_NUMBER] = {31-PMN_NUMBER{1'b0}};
  end endgenerate

  assign npmuirq = ~(  (pminten_c                 & pmovsr_c                 & pmn_en) |
                     (|(pminten_p[PMN_NUMBER-1:0] & pmovsr_p[PMN_NUMBER-1:0] & update_pmn_en[PMN_NUMBER-1:0])));

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      npmuirq_reg <= 1'b1;
    else
      npmuirq_reg <= npmuirq;

  assign pminten_rd = {pminten_c,
                       pminten_p & pmn_hyp_mask};

  assign apb_pminten_rd = {pminten_c,
                           pminten_p};

  // ------------------------------------------------------
  // PMEVCNTRn/PMEVCNTRn_EL0 Event Counter Registers
  // ------------------------------------------------------

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_pmevcntr
    if ((n % 2) == 1) begin: g_odd
      assign pmn_chain[n] = pmn_wrapped[n-1];
    end else begin: g_even
      assign pmn_chain[n] = 1'b0;
    end

    assign pmn_event[n] =
      // Architecurally Defined
      ((pmevtyper_evtcount[n] == 10'h000) & pmn_swincr[n])                    |
      ((pmevtyper_evtcount[n] == 10'h001) & evnt_ic_lf_rs)                    |
      ((pmevtyper_evtcount[n] == 10'h002) & evnt_instr_pagewalk_rs)           |
      ((pmevtyper_evtcount[n] == 10'h003) & evnt_rw_lf_rs)                    |
      ((pmevtyper_evtcount[n] == 10'h004) & evnt_dc_access_rs)                |
      ((pmevtyper_evtcount[n] == 10'h005) & evnt_data_pagewalk_rs)            |
      ((pmevtyper_evtcount[n] == 10'h006) & evnt_data_rd_wr_rs)               |
      ((pmevtyper_evtcount[n] == 10'h007) & evnt_data_wr_wr_rs)               |
      ((pmevtyper_evtcount[n] == 10'h008) & evnt_instr_exec_rs)               |
      ((pmevtyper_evtcount[n] == 10'h009) & evnt_expt_taken_rs)               |
      ((pmevtyper_evtcount[n] == 10'h00a) & evnt_expt_rtn_ret_rs)             |
      ((pmevtyper_evtcount[n] == 10'h00b) & evnt_cntxtid_write_rs)            |
      ((pmevtyper_evtcount[n] == 10'h00c) & evnt_sw_change_pc_rs)             |
      ((pmevtyper_evtcount[n] == 10'h00d) & evnt_br_direct_wr_rs)             |
      ((pmevtyper_evtcount[n] == 10'h00f) & evnt_unaligned_ls_rs)             |
      ((pmevtyper_evtcount[n] == 10'h010) & evnt_br_mispred_rs)               |
      ((pmevtyper_evtcount[n] == 10'h011) & 1'b1)                             |
      ((pmevtyper_evtcount[n] == 10'h012) & evnt_br_valid_wr_rs)              |
      ((pmevtyper_evtcount[n] == 10'h013) & evnt_data_mem_access_rs)          |
      ((pmevtyper_evtcount[n] == 10'h014) & evnt_ic_access_rs)                |
      ((pmevtyper_evtcount[n] == 10'h015) & evnt_eviction_rs)                 |
      ((pmevtyper_evtcount[n] == 10'h016) & evnt_l2_access_rs)                |
      ((pmevtyper_evtcount[n] == 10'h017) & evnt_l2_refill_rs)                |
      ((pmevtyper_evtcount[n] == 10'h018) & evnt_l2_wb_rs)                    |
      ((pmevtyper_evtcount[n] == 10'h019) & evnt_bus_acc_rs)                  |
      ((pmevtyper_evtcount[n] == 10'h01a) & evnt_mem_err)                     |
      ((pmevtyper_evtcount[n] == 10'h01d) & evnt_bus_cycle_rs)                |
      ((pmevtyper_evtcount[n] == 10'h01e) & pmn_chain[n])                     |
      // ARM House Style
      ((pmevtyper_evtcount[n] == 10'h060) & evnt_bus_acc_rd_rs)               |
      ((pmevtyper_evtcount[n] == 10'h061) & evnt_bus_acc_wr_rs)               |
      ((pmevtyper_evtcount[n] == 10'h07a) & evnt_br_indirect_rs)              |
      ((pmevtyper_evtcount[n] == 10'h086) & evnt_irq_taken_rs)                |
      ((pmevtyper_evtcount[n] == 10'h087) & evnt_fiq_taken_rs)                |
      // Implementation Defined - General
      ((pmevtyper_evtcount[n] == 10'h0c0) & evnt_ext_mem_req_rs)              |
      ((pmevtyper_evtcount[n] == 10'h0c1) & evnt_ext_mem_req_nc_rs)           |
      ((pmevtyper_evtcount[n] == 10'h0c2) & evnt_pf_lf_rs)                    |
      ((pmevtyper_evtcount[n] == 10'h0c3) & evnt_throttle_rs)                 |
      ((pmevtyper_evtcount[n] == 10'h0c4) & evnt_ramode_enter_rs)             |
      ((pmevtyper_evtcount[n] == 10'h0c5) & evnt_ramode_rs)                   |
      ((pmevtyper_evtcount[n] == 10'h0c6) & evnt_pdc_valid_rs)                |
      ((pmevtyper_evtcount[n] == 10'h0c7) & evnt_stb_stall_rs)                |
      ((pmevtyper_evtcount[n] == 10'h0c8) & evnt_snooped_data_rs)             |
      ((pmevtyper_evtcount[n] == 10'h0c9) & evnt_br_cond_predict_rs)          |
      ((pmevtyper_evtcount[n] == 10'h0ca) & evnt_br_indirect_mispred_rs)      |
      ((pmevtyper_evtcount[n] == 10'h0cb) & evnt_br_indirect_mispred_addr_rs) |
      ((pmevtyper_evtcount[n] == 10'h0cc) & evnt_br_cond_mispredict_rs)       |
      // Implementation Defined - ECC Error
      ((pmevtyper_evtcount[n] == 10'h0d0) & evnt_mem_err_ifu_i)               |
      ((pmevtyper_evtcount[n] == 10'h0d1) & evnt_mem_err_dcu_i)               |
      ((pmevtyper_evtcount[n] == 10'h0d2) & evnt_mem_err_tlb_i)               |
      // Implementation Defined - Attributable Performance Impact Events
      ((pmevtyper_evtcount[n] == 10'h0e0) & attr_evnt_e0)                     |
      ((pmevtyper_evtcount[n] == 10'h0e1) & attr_evnt_e1)                     |
      ((pmevtyper_evtcount[n] == 10'h0e2) & attr_evnt_e2)                     |
      ((pmevtyper_evtcount[n] == 10'h0e3) & attr_evnt_e3)                     |
      ((pmevtyper_evtcount[n] == 10'h0e4) & attr_evnt_e4)                     |
      ((pmevtyper_evtcount[n] == 10'h0e5) & attr_evnt_e5)                     |
      ((pmevtyper_evtcount[n] == 10'h0e6) & attr_evnt_e6)                     |
      ((pmevtyper_evtcount[n] == 10'h0e7) & attr_evnt_e7)                     |
      ((pmevtyper_evtcount[n] == 10'h0e8) & attr_evnt_e8);

    // Increment the performance registers (increment by two when counting two
    // executed instructions).
    assign pmn_cp15_wrenable[n] = ((wr_cp15_crn9_pmxevcntr & (pmselr_sel == n[4:0])) | wr_cp15_crn14_pmevcntr[n]) & pmn_hyp_mask[n];

    assign inc_pmevcntr[n] = pmevcntr[n] +
                              ((((pmevtyper_evtcount[n] == 10'h008) & evnt_instr_exec_two_rs)  |
                                ((pmevtyper_evtcount[n] == 10'h019) & evnt_bus_acc_two_rs)     |
                                ((pmevtyper_evtcount[n] == 10'h0c0) & evnt_ext_mem_req_two_rs) |
                                ((pmevtyper_evtcount[n] == 10'h0c1) & evnt_ext_mem_req_nc_two_rs)) ?
                              32'h0000_0002 : 32'h0000_0001);

    // Select the next values of the performance registers
    // Can be either:
    //  - write data from CP bus (on MCR)
    //  - zero (if being "reset" by write to control register)
    //  - incremented value, truncated to 32 bits (wrap on overflow)
    assign nxt_pmevcntr[n] = wr_apb_pm_evcntr[n]                            ? {1'b0, apb_wdata_i[31:0]}   :
                             pmn_cp15_wrenable[n]                           ? {1'b0, mcr_data_wr_i[31:0]} :
                             pmn_perf_counter_reset_ext                     ? 33'h0_0000_0000       :
                             (pmn_perf_counter_reset_int & pmn_hyp_mask[n]) ? 33'h0_0000_0000       :
                                                                              inc_pmevcntr[n][32:0];

    // Check if the current and are in the same state
    assign mask_event[n] = filter_event(dpu_exception_level_i, ns_state_i, aarch64_state_i, pmevtyper_p[n], pmevtyper_u[n],
                                        pmevtyper_nsk[n], pmevtyper_nsu[n], pmevtyper_nsh[n], pmevtyper_m[n]);

    // Create hi and lo enables based on whether we're doing an increment (inc) that only needs to enable
    // the upper 24-bits if we're going to wrap, or a no-increment (ninc) on a full counter width write
    assign en_pmevcntr_early_ninc[n] = pmn_perf_counter_reset_ext | (pmn_perf_counter_reset_int & pmn_hyp_mask[n]) | wr_apb_pm_evcntr[n] | pmn_cp15_wrenable[n];
    assign en_pmevcntr_early_inc[n]  = ~mask_event[n] & pmn_event[n] & update_pmn_en[n] & pmcnten_p[n] & ~profiling_prohibited & ~dbgdscr_halted_i;

    assign en_pmevcntr_lo[n] = en_pmevcntr_early_ninc[n] |  en_pmevcntr_early_inc[n];
    assign en_pmevcntr_hi[n] = en_pmevcntr_early_ninc[n] | (en_pmevcntr_early_inc[n] & pmevcntr[n][7:1] == {7{1'b1}});

    always @(posedge clk_pmu_cntrs or negedge reset_n)
      if (~reset_n)
        pmevcntr[n][31:8] <= {24{1'b0}};
      else if (en_pmevcntr_hi[n])
        pmevcntr[n][31:8] <= nxt_pmevcntr[n][31:8];

    always @(posedge clk_pmu_cntrs or negedge reset_n)
      if (~reset_n)
        pmevcntr[n][7:0] <= {8{1'b0}};
      else if (en_pmevcntr_lo[n])
        pmevcntr[n][7:0] <= nxt_pmevcntr[n][7:0];

    assign pmn_wrapped[n] = nxt_pmevcntr[n][32] & en_pmevcntr_lo[n];

    assign pmevcntr_rd[n] = pmevcntr[n][31:0] & {32{pmn_hyp_mask[n]}};

  end endgenerate

  // ------------------------------------------------------
  // PMEVTYPERn/PMEVTYPERn_EL0 Event Type and Filter Registers
  // ------------------------------------------------------

  generate for (n = 0; n < PMN_NUMBER; n = n + 1) begin: g_pmevtyper
    assign en_pmevtyper[n] = wr_apb_pm_evtyper[n] | ((wr_cp15_crn9_pmxevtyper & (pmselr_sel == n[4:0])) | wr_cp15_crn14_pmevtyper[n]) & pmn_hyp_mask[n];

    assign nxt_pmevtyper_p[n]        = wr_apb_pm_evtyper[n] ? apb_wdata_i[31]  : mcr_data_wr_i[31];
    assign nxt_pmevtyper_u[n]        = wr_apb_pm_evtyper[n] ? apb_wdata_i[30]  : mcr_data_wr_i[30];
    assign nxt_pmevtyper_nsk[n]      = wr_apb_pm_evtyper[n] ? apb_wdata_i[29]  : mcr_data_wr_i[29];
    assign nxt_pmevtyper_nsu[n]      = wr_apb_pm_evtyper[n] ? apb_wdata_i[28]  : mcr_data_wr_i[28];
    assign nxt_pmevtyper_nsh[n]      = wr_apb_pm_evtyper[n] ? apb_wdata_i[27]  : mcr_data_wr_i[27];
    assign nxt_pmevtyper_m[n]        = wr_apb_pm_evtyper[n] ? apb_wdata_i[26]  : mcr_data_wr_i[26];
    assign nxt_pmevtyper_evtcount[n] = wr_apb_pm_evtyper[n] ? apb_wdata_i[9:0] : mcr_data_wr_i[9:0];

    always @(posedge clk_pmu_regs or negedge reset_n)
      if (~reset_n) begin
        pmevtyper_p[n]        <= 1'b0;
        pmevtyper_u[n]        <= 1'b0;
        pmevtyper_nsk[n]      <= 1'b0;
        pmevtyper_nsu[n]      <= 1'b0;
        pmevtyper_nsh[n]      <= 1'b0;
        pmevtyper_m[n]        <= 1'b0;
        pmevtyper_evtcount[n] <= {10{1'b0}};
      end else if (en_pmevtyper[n]) begin
        pmevtyper_p[n]        <= nxt_pmevtyper_p[n];
        pmevtyper_u[n]        <= nxt_pmevtyper_u[n];
        pmevtyper_nsk[n]      <= nxt_pmevtyper_nsk[n];
        pmevtyper_nsu[n]      <= nxt_pmevtyper_nsu[n];
        pmevtyper_nsh[n]      <= nxt_pmevtyper_nsh[n];
        pmevtyper_m[n]        <= nxt_pmevtyper_m[n];
        pmevtyper_evtcount[n] <= nxt_pmevtyper_evtcount[n];
      end

    assign pmevtyper_rd[n] = apb_pmevtyper_rd[n] & {32{pmn_hyp_mask[n]}};

    assign apb_pmevtyper_rd[n] = {pmevtyper_p[n],
                                  pmevtyper_u[n],
                                  pmevtyper_nsk[n],
                                  pmevtyper_nsu[n],
                                  pmevtyper_nsh[n],
                                  pmevtyper_m[n],
                                  16'h0000,
                                  pmevtyper_evtcount[n]};
  end endgenerate

  // ------------------------------------------------------
  // PMCCFILTR/PMCCFILTR_EL0   Cycle Counter Filter Register
  // ------------------------------------------------------

  assign en_pmccfiltr = wr_apb_pmccfiltr | wr_cp15_crn14_pmccfiltr | (wr_cp15_crn9_pmxevtyper & (pmselr_sel == 5'b11111));

  assign nxt_pmccfiltr_p   = wr_apb_pmccfiltr ? apb_wdata_i[31]  : mcr_data_wr_i[31];
  assign nxt_pmccfiltr_u   = wr_apb_pmccfiltr ? apb_wdata_i[30]  : mcr_data_wr_i[30];
  assign nxt_pmccfiltr_nsk = wr_apb_pmccfiltr ? apb_wdata_i[29]  : mcr_data_wr_i[29];
  assign nxt_pmccfiltr_nsu = wr_apb_pmccfiltr ? apb_wdata_i[28]  : mcr_data_wr_i[28];
  assign nxt_pmccfiltr_nsh = wr_apb_pmccfiltr ? apb_wdata_i[27]  : mcr_data_wr_i[27];
  assign nxt_pmccfiltr_m   = wr_apb_pmccfiltr ? apb_wdata_i[26]  : mcr_data_wr_i[26];

  always @(posedge clk_pmu_regs or negedge reset_n)
    if (~reset_n) begin
      pmccfiltr_p   <= 1'b0;
      pmccfiltr_u   <= 1'b0;
      pmccfiltr_nsk <= 1'b0;
      pmccfiltr_nsu <= 1'b0;
      pmccfiltr_nsh <= 1'b0;
      pmccfiltr_m   <= 1'b0;
    end else if (en_pmccfiltr) begin
      pmccfiltr_p   <= nxt_pmccfiltr_p;
      pmccfiltr_u   <= nxt_pmccfiltr_u;
      pmccfiltr_nsk <= nxt_pmccfiltr_nsk;
      pmccfiltr_nsu <= nxt_pmccfiltr_nsu;
      pmccfiltr_nsh <= nxt_pmccfiltr_nsh;
      pmccfiltr_m   <= nxt_pmccfiltr_m;
    end

  assign pmccfiltr_rd = {pmccfiltr_p,
                         pmccfiltr_u,
                         pmccfiltr_nsk,
                         pmccfiltr_nsu,
                         pmccfiltr_nsh,
                         pmccfiltr_m,
                         26'h0000000};

  // ------------------------------------------------------
  // ETM event bus
  // ------------------------------------------------------

  assign pmn_evntbus_allowed = pmn_export_enabled & ~profiling_prohibited & ~dbgdscr_halted_i;

  assign nxt_dpu_pmn_evntbus = {26{pmn_evntbus_allowed}} & {evnt_mem_err_tlb_i,      // [25]
                                                            evnt_mem_err_dcu_i,      // [24]
                                                            evnt_mem_err_ifu_i,      // [23]
                                                            evnt_l2_wb_rs,           // [22]
                                                            evnt_l2_refill_rs,       // [21]
                                                            evnt_l2_access_rs,       // [20]
                                                            evnt_eviction_rs,        // [19]
                                                            evnt_ic_access_rs,       // [18]
                                                            evnt_data_mem_access_rs, // [17]
                                                            evnt_br_valid_wr_rs,     // [16]
                                                            evnt_br_mispred_rs,      // [15]
                                                            evnt_unaligned_ls_rs,    // [14]
                                                            evnt_br_direct_wr_rs,    // [13]
                                                            evnt_sw_change_pc_rs,    // [12]
                                                            evnt_cntxtid_write_rs,   // [11]
                                                            evnt_expt_rtn_ret_rs,    // [10]
                                                            evnt_expt_taken_rs,      // [ 9]
                                                            evnt_instr_exec_two_rs,  // [ 8]
                                                            evnt_instr_exec_rs,      // [ 7]
                                                            evnt_data_wr_wr_rs,      // [ 6]
                                                            evnt_data_rd_wr_rs,      // [ 5]
                                                            evnt_data_pagewalk_rs,   // [ 4]
                                                            evnt_dc_access_rs,       // [ 3]
                                                            evnt_rw_lf_rs,           // [ 2]
                                                            evnt_instr_pagewalk_rs,  // [ 1]
                                                            evnt_ic_lf_rs};          // [ 0]

  // Generate a clock enable for the dpu_pmn_evntbus registers
  // Allow the incoming event bus to be masked with the export
  // enable signal then in the next cycle gate off the bus.
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dpu_pmn_evntbus_en <= 1'b0;
    else
      dpu_pmn_evntbus_en <= pmn_evntbus_allowed;

  always @(posedge clk_pmu_cntrs or negedge reset_n)
    if (~reset_n)
      dpu_pmn_evntbus <= {26{1'b0}};
    else if (dpu_pmn_evntbus_en)
      dpu_pmn_evntbus <= nxt_dpu_pmn_evntbus;

  // ------------------------------------------------------
  // Final read mux
  // ------------------------------------------------------

  always @* begin : p_cp_rd
    integer i;
    reg [31:0] tmp_cp_pmn_rd_data;

    tmp_cp_pmn_rd_data = {32{1'b0}};

    for (i = 0; i < PMN_NUMBER; i = i + 1) begin
      tmp_cp_pmn_rd_data = tmp_cp_pmn_rd_data |
                            ({32{rd_cp15_crn14_pmevcntr[i]}}  & pmevcntr[i]) |
                            ({32{rd_cp15_crn14_pmevtyper[i]}} & pmevtyper_rd[i]);
    end

    cp_pmn_rd_data = tmp_cp_pmn_rd_data;
  end

  assign pmu_cp_rd_data_32bit = {32{raw_cp_valid_wr_i}} & (cp_pmn_rd_data                                    |
                                                           ({32{rd_cp15_crn9_pmcr}}        & pmn_pmcr_rd)    |
                                                           ({32{rd_cp15_crn9_pmncntenset}} & pmcnten_rd)     |
                                                           ({32{rd_cp15_crn9_pmncntenclr}} & pmcnten_rd)     |
                                                           ({32{rd_cp15_crn9_pmintenset}}  & pminten_rd)     |
                                                           ({32{rd_cp15_crn9_pmintenclr}}  & pminten_rd)     |
                                                           ({32{rd_cp15_crn9_pmovsr}}      & pmovsr_rd)      |
                                                           ({32{rd_cp15_crn9_pmovsset}}    & pmovsr_rd)      |
                                                           ({32{rd_cp15_crn9_pmccntr}}     & pmccntr[31:0])  |
                                                           ({32{rd_cp15_crn9_pmselr}}      & pmselr_rd)      |
                                                           ({32{rd_cp15_crn9_pmxevtyper}}  & pmxevtyper_rd)  |
                                                           ({32{rd_cp15_crn9_pmxevcntr}}   & pmxevcntr_rd)   |
                                                           ({32{rd_cp15_crn9_pmuserenr}}   & pmuserenr_rd)   |
                                                           ({32{rd_cp15_crn9_pmceid0}}     & pmceid0_rd)     |
                                                           ({32{rd_cp15_crn14_pmccfiltr}}  & pmccfiltr_rd));

  assign pmu_cp_rd_data_64bit = ({64{rd_cp15_crn9_pmccntr_64}}  & pmccntr[63:0]);

  assign pmu_cp_rd_data_o = { {32{1'b0}}, pmu_cp_rd_data_32bit} | pmu_cp_rd_data_64bit;

  //-------------------------------------------------------
  // Connect Internal Signals to Outputs.
  //-------------------------------------------------------

  assign pmn_useren_o   = pmuserenr;
  assign dpu_pmuevent_o = dpu_pmn_evntbus[25:0];
  assign dpu_npmuirq_o  = npmuirq_reg;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clock_divider_en")
  u_ovl_x_clock_divider_en (.clk       (clk_pmu_cntrs),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (clock_divider_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_pmn_evntbus_en")
  u_ovl_x_dpu_pmn_evntbus_en (.clk       (clk_pmu_cntrs),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dpu_pmn_evntbus_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pmccfiltr")
  u_ovl_x_en_pmccfiltr (.clk       (clk_pmu_regs),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_pmccfiltr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pmccntr_lo")
  u_ovl_x_en_pmccntr_lo (.clk       (clk_pmu_cntrs),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_pmccntr_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pmccntr_hi")
  u_ovl_x_en_pmccntr_hi (.clk       (clk_pmu_cntrs),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (en_pmccntr_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pmcnten")
  u_ovl_x_en_pmcnten (.clk       (clk_pmu_regs),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (en_pmcnten));

  assert_never_unknown #(`OVL_FATAL, PMN_NUMBER, `OVL_ASSERT, "Register enable x-check: en_pmevcntr_lo")
  u_ovl_x_en_pmevcntr_lo (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_pmevcntr_lo));

  assert_never_unknown #(`OVL_FATAL, PMN_NUMBER, `OVL_ASSERT, "Register enable x-check: en_pmevcntr_hi")
  u_ovl_x_en_pmevcntr_hi (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (en_pmevcntr_hi));

  assert_never_unknown #(`OVL_FATAL, PMN_NUMBER, `OVL_ASSERT, "Register enable x-check: en_pmevtyper")
  u_ovl_x_en_pmevtyper (.clk       (clk_pmu_regs),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_pmevtyper));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pminten")
  u_ovl_x_en_pminten (.clk       (clk_pmu_regs),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (en_pminten));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_pmovsr")
  u_ovl_x_en_pmovsr (.clk       (clk_pmu_cntrs),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_pmovsr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: event_00_0f_en")
  u_ovl_x_event_00_0f_en (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (event_00_0f_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: event_10_1f_en")
  u_ovl_x_event_10_1f_en (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (event_10_1f_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: event_20_df_en")
  u_ovl_x_event_20_df_en (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (event_20_df_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: event_e0_ef_en")
  u_ovl_x_event_e0_ef_en (.clk       (clk_pmu_cntrs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (event_e0_ef_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pmn_en")
  u_ovl_x_pmn_en (.clk       (clk_pmu_cntrs),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (pmn_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn9_pmselr")
  u_ovl_x_wr_cp15_crn9_pmselr (.clk       (clk_pmu_regs),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_cp15_crn9_pmselr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn9_pmuserenr")
  u_ovl_x_wr_cp15_crn9_pmuserenr (.clk       (clk_pmu_regs),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn9_pmuserenr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_pmcr")
  u_ovl_x_wr_pmcr (.clk       (clk_pmu_regs),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (wr_pmcr));

`endif

endmodule // ca53dpu_pmu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
