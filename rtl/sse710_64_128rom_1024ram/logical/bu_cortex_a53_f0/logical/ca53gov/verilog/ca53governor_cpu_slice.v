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
// Description: Register slice CPU inputs and outputs
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_slice `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  clk_cpu,
  input  wire                                  reset_n_gov,
  input  wire                                  po_reset_n_gov,
  input  wire                                  dpu_warmrstreq_i,
  input  wire                                  nfiq_i,
  input  wire                                  nirq_i,
  input  wire                                  nsei_i,
  input  wire                                  nrei_i,
  input  wire                                  nvfiq_i,
  input  wire                                  nvirq_i,
  input  wire                                  nvsei_i,
  input  wire                                  dpu_rei_level_ack_i,
  input  wire                                  dpu_sei_level_ack_i,
  input  wire                                  dpu_vsei_level_ack_i,
  input  wire                                  cfgend_i,
  input  wire                                  vinithi_i,
  input  wire                                  cfgte_i,
  input  wire                                  cp15sdisable_i,
  input  wire                                  aa64naa32_i,
  input  wire [ 39: 2]                         rvbaraddr_i,
  input  wire                                  cryptodisable_i,
  input  wire                                  dcu_excl_mon_cleared_i,
  input  wire                                  dpu_sev_req_i,
  input  wire                                  dpu_smp_en_i,
  input  wire                                  dpu_dbgack_i,
  input  wire                                  dbgen_i,
  input  wire                                  niden_i,
  input  wire                                  spiden_i,
  input  wire                                  spniden_i,
  input  wire                                  dpu_dbgrstreq_i,
  input  wire                                  dpu_dbgnopwrdwn_i,
  input  wire                                  dpu_commrx_i,
  input  wire                                  dpu_commtx_i,
  input  wire                                  dpu_ncommirq_i,
  input  wire                                  edbgrq_i,
  input  wire [(`CA53_CPADDR_W-1):0]           dcu_cp_gov_addr_i,
  input  wire                                  dcu_cp_gov_ns_i,
  input  wire                                  dcu_cp_gov_req_i,
  input  wire [(`CA53_CPSEL_W-1):0]            dcu_cp_gov_sel_i,
  input  wire [(`CA53_CPDATA_W-1):0]           dcu_cp_gov_wdata_i,
  input  wire                                  dcu_cp_gov_wenable_i,
  input  wire [(`CA53_GOV_CPDATA_W-1):0]       cp_l2_rdata_i,
  input  wire                                  gic_cp_ack_i,
  input  wire [(`CA53_CPDATA_W-1):0]           gic_cp_rdata_i,
  input  wire [(`CA53_CPDATA_W-1):0]           timer_cp_rdata_i,
  input  wire                                  etm_oslock_i,
  input  wire                                  dpu_npmuirq_i,
  input  wire [(`CA53_PMUEVNT_CPU_W-1): 0]     dpu_pmuevent_i,
  input  wire                                  gic_nxt_int_active_i,
  input  wire                                  ctiirqack_i,
  input  wire                                  event_cpu_ret_i,
  input  wire                                  event_neon_ret_i,
  input  wire                                  scu_inv_all_ack_i,
  input  wire                                  evnt_scu_err_i,
  input  wire                                  evnt_l2_err_i,
  input  wire                                  mbistreq_rs_i,
  input  wire                                  dbgl1rstdisable_i,
  // Outputs
  output reg                                   warmrstreq_o,
  output wire                                  nfiq_rs_o,
  output wire                                  nirq_rs_o,
  output wire                                  nvfiq_rs_o,
  output wire                                  nvirq_rs_o,
  output wire                                  sei_level_req_o,
  output wire                                  vsei_level_req_o,
  output wire                                  rei_level_req_o,
  output wire                                  gov_int_active_o,
  output reg                                   gov_cfgend_o,
  output reg                                   gov_vinithi_o,
  output reg                                   gov_cfgte_o,
  output reg                                   gov_cp15sdisable_o,
  output reg                                   gov_aa64naa32_o,
  output reg  [ 39: 2]                         gov_rvbaraddr_o,
  output wire                                  gov_cryptodisable_o,
  output reg                                   gov_smpen_o,
  output reg                                   excl_mon_cleared_o,
  output reg                                   sev_req_rs_o,
  output reg                                   dbgack_rs_o,
  output wire                                  gov_dbgen_o,
  output wire                                  gov_niden_o,
  output wire                                  gov_spiden_o,
  output wire                                  gov_spniden_o,
  output reg                                   dbgrstreq_o,
  output reg                                   dbgnopwrdwn_o,
  output reg                                   commrx_rs_o,
  output reg                                   commtx_rs_o,
  output reg                                   ncommirq_rs_o,
  output wire                                  edbgrq_rs_o,
  output reg  [(`CA53_CPADDR_W-1):0]           cp_gov_addr_rs_o,
  output reg                                   cp_gov_ns_rs_o,
  output wire                                  cp_gov_req_rs_o,
  output wire [(`CA53_CPSEL_W-1):0]            cp_gov_sel_rs_o,
  output reg  [(`CA53_CPDATA_W-1):0]           cp_gov_wdata_rs_o,
  output reg                                   cp_gov_wenable_rs_o,
  output wire                                  gov_cp_ack_o,
  output reg  [(`CA53_CPDATA_W-1):0]           gov_cp_rdata_o,
  output reg                                   valid_timer_en_o,
  output reg                                   valid_l2_en_o,
  output reg                                   etm_oslock_rs_o,
  output wire                                  ctiirqack_rs_o,
  output reg                                   npmuirq_rs_o,
  output reg  [(`CA53_PMUEVNT_W-1):0]          pmuevent_o,
  output reg                                   gov_inv_all_req_o,
  output wire                                  gov_dbgl1rstdisable_o,
  output reg                                   gov_mbistreq_cpu_o
);

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam CP_FSM_IDLE = 1'b0;
  localparam CP_FSM_WAIT = 1'b1;

  localparam TAG_INV_RESET_OR_IDLE = 1'b0;
  localparam TAG_INV_ACTIVE        = 1'b1;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [(`CA53_CPSEL_W-1):0]            cp_gov_sel_rs;
  reg                                  cp_gov_req_rs;
  reg                                  cp_state;
  reg                                  gov_cp_ack;
  reg                                  load_initial;
  reg                                  non_gic_cp_ack;
  reg                                  nxt_cp_state;
  reg                                  rei_level_req;
  reg                                  sei_level_req;
  reg                                  vsei_level_req;
  reg                                  gov_int_active;
  reg                                  inv_scu_tag_state;
  reg                                  nxt_inv_scu_tag_state;
  reg                                  gov_dbgl1rstdisable;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                 cp15_request_is_timer;
  wire                                 cp15_request_is_gic;
  wire                                 cp15_request_is_l2;
  wire                                 enable_cp;
  wire                                 interrupt_level_en;
  wire                                 nrei_rs;
  wire                                 nsei_rs;
  wire                                 nvsei_rs;
  wire [63:0]                          nxt_cp_rdata;
  wire                                 nxt_cp_ack;
  wire                                 nxt_sei_level_req;
  wire                                 nxt_vsei_level_req;
  wire                                 nxt_rei_level_req;
  wire                                 nxt_gov_int_active;
  wire                                 pmu_free_run_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // The reset values of some registers depend on top-level inputs which are sampled
  // at reset time. Therefore the load_initial register is reset to 1, then used as an
  // enable to load these values in on the first clock cycle during reset.
  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov)
      load_initial <= 1'b1;
    else if (load_initial)
      load_initial <= 1'b0;

  // ------------------------------------------------------
  // Register slice for CPU signals captured at reset
  // ------------------------------------------------------

  always @(posedge clk_cpu)
    if (load_initial) begin
      gov_cfgend_o        <= cfgend_i;
      gov_vinithi_o       <= vinithi_i;
      gov_cfgte_o         <= cfgte_i;
      gov_aa64naa32_o     <= aa64naa32_i;
      gov_rvbaraddr_o     <= rvbaraddr_i[39:2];
      gov_dbgl1rstdisable <= dbgl1rstdisable_i;
    end

  generate if (CRYPTO) begin : g_cryptodisable
    reg cryptodisable_rs;

    always @(posedge clk_cpu)
      if (load_initial)
        cryptodisable_rs <= cryptodisable_i;

    assign gov_cryptodisable_o = cryptodisable_rs;
  end else begin : g_cryptodisable_stubs
    assign gov_cryptodisable_o = 1'b1;
  end endgenerate

  // ------------------------------------------------------
  // SCU tag RAM invalidation control
  // ------------------------------------------------------
  //
  // After reset has been asserted the tag RAMs for the CPU need to be invalidated.
  // Once the invalidate handshake is complete the SCU will respond and the state
  // machine will move back to idle.
  //
  // If the external debug L1 reset disable input is asserted the tag invalidation
  // procedure is disabled.
  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov)
      inv_scu_tag_state <= TAG_INV_RESET_OR_IDLE;
    else
      inv_scu_tag_state <= nxt_inv_scu_tag_state;

  always @*
    case (inv_scu_tag_state)
      TAG_INV_RESET_OR_IDLE : begin
        nxt_inv_scu_tag_state  = load_initial & ~gov_dbgl1rstdisable ? TAG_INV_ACTIVE : TAG_INV_RESET_OR_IDLE;
        gov_inv_all_req_o = 1'b0;
      end
      TAG_INV_ACTIVE : begin
        nxt_inv_scu_tag_state  = scu_inv_all_ack_i ? TAG_INV_RESET_OR_IDLE : TAG_INV_ACTIVE;
        gov_inv_all_req_o = 1'b1;
      end
      default : begin
        nxt_inv_scu_tag_state  = 1'bx;
        gov_inv_all_req_o = 1'bx;
      end
    endcase

  // ------------------------------------------------------
  // Register slice using STANDBYWFx clock
  // ------------------------------------------------------
  //
  // By using the clk_cpu input the STANDBYWFx signals are not needed as the clock is already gated.
  //
  // It is necessary for most of the signals leaving the DPU to use this clock to ensure that the values
  // used in the governor are the 'last' values rather than default values.  This is important for
  // retention to function correctly.

  always @(posedge clk_cpu)
    // Inputs to CPU using the STANDBYWFx gated clock
    gov_cp15sdisable_o <= cp15sdisable_i;

  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      // Inputs to CPU using the STANDBYWFx gated clock
      gov_mbistreq_cpu_o <= 1'b0;
      // Inputs/Outputs from CPU using the STANDBYWFx gated clock
      warmrstreq_o       <= 1'b0;
      excl_mon_cleared_o <= 1'b0;
      sev_req_rs_o       <= 1'b0;
      gov_smpen_o        <= 1'b0;
      npmuirq_rs_o       <= 1'b1;
      ncommirq_rs_o      <= 1'b1;
      pmuevent_o[25:0]   <= {`CA53_PMUEVNT_CPU_W{1'b0}};
    end
    else begin
      // Inputs to CPU using the STANDBYWFx gated clock
      gov_mbistreq_cpu_o <= mbistreq_rs_i;
      // Outputs from CPU using the STANDBYWFx gated clock
      warmrstreq_o       <= dpu_warmrstreq_i;
      excl_mon_cleared_o <= dcu_excl_mon_cleared_i;
      sev_req_rs_o       <= dpu_sev_req_i;
      gov_smpen_o        <= dpu_smp_en_i;
      npmuirq_rs_o       <= dpu_npmuirq_i;
      ncommirq_rs_o      <= dpu_ncommirq_i;
      pmuevent_o[25:0]   <= dpu_pmuevent_i[(`CA53_PMUEVNT_CPU_W-1):0]; // NOTE: This is not the full width of the PMUEVENT bus
    end

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov) begin
      // Outputs from CPU using the STANDBYWFx gated clock
      dbgrstreq_o     <= 1'b0;
      dbgnopwrdwn_o   <= 1'b0;
      dbgack_rs_o     <= 1'b0;
      commrx_rs_o     <= 1'b0;
      commtx_rs_o     <= 1'b1;  // 1'b1 is "empty" (i.e. value from core out of reset)
      etm_oslock_rs_o <= 1'b1;
    end
    else begin
      // Outputs from CPU using the STANDBYWFx gated clock
      dbgrstreq_o     <= dpu_dbgrstreq_i;
      dbgnopwrdwn_o   <= dpu_dbgnopwrdwn_i;
      dbgack_rs_o     <= dpu_dbgack_i;
      commrx_rs_o     <= dpu_commrx_i;
      commtx_rs_o     <= dpu_commtx_i;
      etm_oslock_rs_o <= etm_oslock_i;
    end

  // Interrupt request signals that can be gated in WFx
  assign nxt_sei_level_req  = ~nsei_rs  | (sei_level_req  & ~dpu_sei_level_ack_i);
  assign nxt_vsei_level_req = ~nvsei_rs | (vsei_level_req & ~dpu_vsei_level_ack_i);
  assign nxt_rei_level_req  = ~nrei_rs  | (rei_level_req  & ~dpu_rei_level_ack_i);

  assign nxt_gov_int_active = nxt_sei_level_req | nxt_vsei_level_req | nxt_rei_level_req | gic_nxt_int_active_i;

  assign interrupt_level_en = nxt_gov_int_active | gov_int_active;

  // The SEI/REI interrupt signals must use the free-running clock, as these
  // interrupts must be observed while in WFx
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov) begin
      sei_level_req  <= 1'b0;
      vsei_level_req <= 1'b0;
      rei_level_req  <= 1'b0;
      gov_int_active <= 1'b0;
    end
    else if (interrupt_level_en) begin
      sei_level_req  <= nxt_sei_level_req;
      vsei_level_req <= nxt_vsei_level_req;
      rei_level_req  <= nxt_rei_level_req;
      gov_int_active <= nxt_gov_int_active;
    end

  // ------------------------------------------------------
  // Register slice using the main clock
  // ------------------------------------------------------
  //
  // Interrupt signals must be clocked continuously so that the CPU can wake up from retention/WFx.
  //
  // The nFIQ, nIRQ, nVFIQ and nVIRQ inputs are legacy interrupts and active-low, level-sensitive
  // The nSEI, nVSEI and nREI inputs are new interrupts and active-low, edge-sensitive.

  // Active-low, level sensitive interrupts
  ca53_cell_sync u_ca53_cell_sync00 (.out_o    (nfiq_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nfiq_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync01 (.out_o    (nirq_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nirq_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync02 (.out_o    (nvfiq_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nvfiq_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync03 (.out_o    (nvirq_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nvirq_i),
                                     .resetn_i (1'b1));

  // Active-low, edge sensitive interrupts
  ca53_cell_sync u_ca53_cell_sync04 (.out_o    (nsei_rs),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nsei_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync05 (.out_o    (nvsei_rs),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nvsei_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync06 (.out_o    (nrei_rs),
                                     .clk_i    (CLKIN),
                                     .inp_i    (nrei_i),
                                     .resetn_i (1'b1));

  // Debug signals must be continuously clocked as they are consumed by the debug over
  // power down wrapper.
  ca53_cell_sync u_ca53_cell_sync07 (.out_o    (gov_dbgen_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (dbgen_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync08 (.out_o    (gov_niden_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (niden_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync09 (.out_o    (gov_spiden_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (spiden_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync10 (.out_o    (gov_spniden_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (spniden_i),
                                     .resetn_i (1'b1));

  ca53_cell_sync u_ca53_cell_sync11 (.out_o    (edbgrq_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (edbgrq_i),
                                     .resetn_i (1'b1));

  // CTI synchronisation
  ca53_cell_sync u_ca53_cell_sync12 (.out_o    (ctiirqack_rs_o),
                                     .clk_i    (CLKIN),
                                     .inp_i    (ctiirqack_i),
                                     .resetn_i (1'b1));

  // CPU/NEON retention events and SCU/L2 ECC error events.
  // These must use the free running clock as the CPU will be in WFx when retention begins and may be in
  // WFx when SCU/L2 ECC error events occur
  assign pmu_free_run_en = (|pmuevent_o[29:26]) | event_cpu_ret_i | event_neon_ret_i | evnt_scu_err_i | evnt_l2_err_i;

  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov) begin
      pmuevent_o[29] <= 1'b0;
      pmuevent_o[28] <= 1'b0;
      pmuevent_o[27] <= 1'b0;
      pmuevent_o[26] <= 1'b0;
    end
    else if (pmu_free_run_en) begin
      pmuevent_o[29] <= event_cpu_ret_i;
      pmuevent_o[28] <= event_neon_ret_i;
      pmuevent_o[27] <= evnt_scu_err_i;
      pmuevent_o[26] <= evnt_l2_err_i;
    end

  // ------------------------------------------------------
  // Register slice the DCU-GOV CP15 Interface
  // ------------------------------------------------------

  // CP15 request path
  assign enable_cp = dcu_cp_gov_req_i | cp_gov_req_rs | (cp_state != CP_FSM_IDLE);

  always @(posedge clk_cpu or negedge reset_n_gov)
    if (~reset_n_gov) begin
      cp_gov_addr_rs_o    <= {`CA53_CPADDR_W{1'b0}};
      cp_gov_ns_rs_o      <= 1'b0;
      cp_gov_req_rs       <= 1'b0;
      cp_gov_sel_rs       <= {`CA53_CPSEL_W{1'b0}};
      cp_gov_wdata_rs_o   <= {`CA53_CPDATA_W{1'b0}};
      cp_gov_wenable_rs_o <= 1'b0;
      cp_state            <= CP_FSM_IDLE;
      gov_cp_ack          <= 1'b0;
    end
    else if (enable_cp) begin
      cp_gov_addr_rs_o    <= dcu_cp_gov_addr_i[(`CA53_CPADDR_W-1):0];
      cp_gov_ns_rs_o      <= dcu_cp_gov_ns_i;
      cp_gov_req_rs       <= dcu_cp_gov_req_i;
      cp_gov_sel_rs       <= dcu_cp_gov_sel_i[(`CA53_CPSEL_W-1):0];
      cp_gov_wdata_rs_o   <= dcu_cp_gov_wdata_i[(`CA53_CPDATA_W-1):0];
      cp_gov_wenable_rs_o <= dcu_cp_gov_wenable_i;
      cp_state            <= nxt_cp_state;
      gov_cp_ack          <= nxt_cp_ack;
    end

  // Identify the target for the CP15 request
  assign cp15_request_is_timer = cp_gov_sel_rs[2:0] == 3'b101;
  assign cp15_request_is_gic   = ~cp_gov_sel_rs[2];
  assign cp15_request_is_l2    = cp_gov_sel_rs[2:0] == 3'b100;

  // The GIC needs to be able to hold off requests until it is ready to deal
  // with them so prefers the 'request' to be held.
  //
  // The Architectural Timers and L2 registers should be read and written
  // atomically so a pulsed 'req' must be generated for these.
  //
  // Also, the Architectural Timers and L2 registers will update immediately
  // and do not generate a pulsed 'ack'.  This is generated here.
  //
  // So this state machine is not needed for the GIC, only the Architectural
  // timers and L2 registers.
  always @*
    begin
      // Defaults
      valid_timer_en_o = 1'b0;
      valid_l2_en_o    = 1'b0;
      non_gic_cp_ack   = 1'b0;

      case (cp_state)
        CP_FSM_IDLE : begin
          // Wait for a non-GIC CP15 read/write request to be made then send an enable
          // to the Architectural Timer or L2 registers for the CP15 read/write
          nxt_cp_state     = (cp_gov_req_rs & ~cp15_request_is_gic) ? CP_FSM_WAIT : CP_FSM_IDLE;
          non_gic_cp_ack   = (cp_gov_req_rs & ~cp15_request_is_gic);
          valid_timer_en_o =  cp_gov_req_rs & cp15_request_is_timer;
          valid_l2_en_o    =  cp_gov_req_rs & cp15_request_is_l2;
        end
        CP_FSM_WAIT : begin
          // Wait for the DCU to receive and deassert the request
          nxt_cp_state     = cp_gov_req_rs ? CP_FSM_WAIT : CP_FSM_IDLE;
        end
        default : begin
          nxt_cp_state     = 1'bx;
          valid_timer_en_o = 1'bx;
          valid_l2_en_o    = 1'bx;
          non_gic_cp_ack   = 1'bx;
        end
      endcase
    end

  // CP15 response path
  assign nxt_cp_ack   = gic_cp_ack_i | non_gic_cp_ack;
  assign nxt_cp_rdata = (({64{cp15_request_is_timer}} & timer_cp_rdata_i[63:0]) |
                         ({64{cp15_request_is_gic}}   & gic_cp_rdata_i[63:0]) |
                         ({64{cp15_request_is_l2}}    & cp_l2_rdata_i));

  always @(posedge clk_cpu)
    if (nxt_cp_ack)
      gov_cp_rdata_o <= nxt_cp_rdata;

  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign cp_gov_sel_rs_o       = cp_gov_sel_rs;
  assign cp_gov_req_rs_o       = cp_gov_req_rs;
  assign gov_cp_ack_o          = gov_cp_ack;
  assign sei_level_req_o       = sei_level_req;
  assign vsei_level_req_o      = vsei_level_req;
  assign rei_level_req_o       = rei_level_req;
  assign gov_int_active_o      = gov_int_active;
  assign gov_dbgl1rstdisable_o = gov_dbgl1rstdisable;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: interrupt_level_en")
  u_ovl_x_interrupt_level_en (.clk       (clk_cpu),
                              .reset_n   (reset_n_gov),
                              .qualifier (1'b1),
                              .test_expr (interrupt_level_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_cp")
  u_ovl_x_enable_cp (.clk       (clk_cpu),
                     .reset_n   (reset_n_gov),
                     .qualifier (1'b1),
                     .test_expr (enable_cp));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial")
  u_ovl_x_load_initial (.clk       (clk_cpu),
                        .reset_n   (reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (load_initial));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cp_ack")
  u_ovl_x_nxt_cp_ack (.clk       (clk_cpu),
                      .reset_n   (reset_n_gov),
                      .qualifier (1'b1),
                      .test_expr (nxt_cp_ack));

  //----------------------------------------------------------------------------
  // State machine X-Checks
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "State-machine: nxt_cp_state x-check")
  u_ovl_x_nxt_cp_state (.clk       (CLKIN),
                        .reset_n   (reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (nxt_cp_state));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "State-machine: nxt_inv_scu_tag_state x-check")
  u_ovl_x_nxt_inv_scu_tag_state (.clk       (CLKIN),
                                 .reset_n   (reset_n_gov),
                                 .qualifier (1'b1),
                                 .test_expr (nxt_inv_scu_tag_state));

`endif

endmodule // ca53governor_cpu_slice

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
