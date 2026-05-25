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
// Description: L2 power control block
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_power `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                CLKIN,
  input  wire                                reset_n_arb,
  input  wire                                DFTSE,
  input  wire [  9: 0]                       cntvalueb_rs_i,
  input  wire [  2: 0]                       cp_l2ectlr_ret_delay_i,
  input  wire [(NUM_CPUS-1): 0]              gov_standbywfi_i,
  input  wire [(NUM_CPUS-1): 0]              gov_standbywfe_i,
  input  wire [(NUM_CPUS-1): 0]              gov_wfx_wake_i,
  input  wire                                l2qreqn_i,
  input  wire                                scu_l2_retention_ready_i,
  // Outputs
  output wire                                gov_l2_in_retention_o,
  output reg                                 l2qactive_o,
  output wire                                l2qdeny_o,
  output reg                                 l2qacceptn_o
);

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam                      RET_L2_FSM_W            = 4;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_RESET        = 4'b0000;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_IDLE         = 4'b0001;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_COUNT   = 4'b0010;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_STALL_1 = 4'b0011;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_STALL_2 = 4'b0100;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_STALL_3 = 4'b0101;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_STALL_4 = 4'b0110;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_WAIT_STALL_5 = 4'b0111;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_RET_REQ      = 4'b1000;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_IN_RET       = 4'b1001;
  localparam [(RET_L2_FSM_W-1):0] RET_L2_FSM_RET_EXIT     = 4'b1010;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                        in_standbywfx;
  reg                        ret_ready_rs1;
  reg                        ret_ready_rs2;
  reg                        l2qdeny;
  reg                        l2_in_retention;
  reg                        nxt_l2qacceptn;
  reg                        nxt_l2qactive;
  reg                        nxt_l2qdeny;
  reg                        nxt_l2_in_retention;
  reg [(RET_L2_FSM_W-1):0]   nxt_ret_l2_fsm;
  reg                        ret_l2_clock_en;
  reg [(RET_L2_FSM_W-1):0]   ret_l2_fsm;
  reg [9:0]                  ret_l2_target_value;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                       clk_ret_l2;
  wire                       l2_exit_retention;
  wire                       l2qreqn_rs;
  wire                       nxt_ret_l2_clock_en;
  wire [9:0]                 nxt_ret_l2_target_value;
  wire                       ret_l2_count_start;
  wire                       ret_l2_ctl_en;
  wire                       ret_l2_enabled;
  wire                       ret_l2_target_hit;
  wire                       ret_ready;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // L2 retention
  // ------------------------------------------------------

  // Regionally gate if retention is not enabled.  Also have to deal with reset condition
  // and spurious powerdown requests when retention is disabled.
  assign nxt_ret_l2_clock_en = (cp_l2ectlr_ret_delay_i[2:0] != 3'b000) | (ret_l2_fsm != RET_L2_FSM_IDLE) | ~l2qreqn_rs;

  always @(posedge CLKIN or negedge reset_n_arb)
    if (!reset_n_arb)
      ret_l2_clock_en <= 1'b1;
    else
      ret_l2_clock_en <= nxt_ret_l2_clock_en;

  ca53_cell_inter_clkgate u_inter_clkgate_ret_l2 (.clk_i         (CLKIN),
                                                  .clk_enable_i  (ret_l2_clock_en),
                                                  .clk_senable_i (DFTSE),
                                                  .clk_gated_o   (clk_ret_l2));

  // Identify if all CPUs are in WFI, WFE or a mix of the above
  always @* begin : g_in_wfx
    integer i;
    reg     tmp_in_standbywfx;

    tmp_in_standbywfx = 1'b1;

    for (i =0; i < NUM_CPUS; i = i + 1) begin
      tmp_in_standbywfx = tmp_in_standbywfx & (gov_standbywfi_i[i] | gov_standbywfe_i[i]);
    end

    in_standbywfx = tmp_in_standbywfx;
  end

  // Indicate that retention is ready when all CPUs are in WFx, there are no L2 accesses
  // and there is not a wakeup signal being sent by one of the individual CPU governors.
  assign ret_ready = in_standbywfx & scu_l2_retention_ready_i & ~(|gov_wfx_wake_i);

  always @(posedge clk_ret_l2 or negedge reset_n_arb)
    if (!reset_n_arb) begin
      ret_ready_rs1 <= 1'b0;
      ret_ready_rs2 <= 1'b0;
    end
    else begin
      ret_ready_rs1 <= ret_ready;
      ret_ready_rs2 <= ret_ready_rs1;
    end

  // L2 exit criteria
  assign l2_exit_retention = ~ret_ready_rs1;

  // L2 retention enabled
  assign ret_l2_enabled = cp_l2ectlr_ret_delay_i[2:0] != 3'b000;

  // Trigger the start of the retention entry process
  assign ret_l2_count_start = ret_l2_enabled & (ret_ready_rs1 & ~ret_ready_rs2);

  // Create a target retention value for when retention entry should begin.  This approach
  // means we only have to set the registers once and only toggle the adder once.
  assign nxt_ret_l2_target_value = ({10{ret_l2_count_start}} & cntvalueb_rs_i[9:0]) + {(cp_l2ectlr_ret_delay_i[2:0] == 3'b111), // 512 Timer Ticks
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b110), // 256 Timer Ticks
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b101), // 128 Timer Ticks
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b100), //  64 Timer Ticks
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b011), //  32 Timer Ticks
                                                                                       1'b0,
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b010), //   8 Timer Ticks
                                                                                       1'b0,
                                                                                       (cp_l2ectlr_ret_delay_i[2:0] == 3'b001), //   2 Timer Ticks
                                                                                       1'b0};

  // Capture the target retention value
  always @(posedge clk_ret_l2 or negedge reset_n_arb)
    if (~reset_n_arb)
      ret_l2_target_value <= {10{1'b0}};
    else if (ret_l2_count_start)
      ret_l2_target_value <= nxt_ret_l2_target_value;

  // Signal that the counter value has hit the target retention value
  assign ret_l2_target_hit = (ret_l2_fsm == RET_L2_FSM_WAIT_COUNT) & ret_l2_target_value[9:0] == cntvalueb_rs_i[9:0];

  // Retention state machine
  //
  always @*
    begin
      // Defaults
      nxt_l2qactive       = 1'b1;
      nxt_l2qdeny         = ~l2qreqn_rs; // By default, QDENY is asserted for any QREQn requests until we are ready to signal QACCEPTn
      nxt_l2qacceptn      = 1'b1;
      nxt_l2_in_retention = 1'b0;

      case (ret_l2_fsm)
        RET_L2_FSM_RESET : begin
          // The reset state is:
          //  - QACCEPTn & QDENY reset low
          //  - QACTIVE reset high
          //  - QREQn can be reset to any state
          nxt_ret_l2_fsm = l2qreqn_rs ? RET_L2_FSM_IDLE : RET_L2_FSM_RESET; // Stay in reset state while QREQn is low
          nxt_l2qactive  = 1'b1;                                            // Maintain QACTIVE high reset state
          nxt_l2qacceptn = l2qreqn_rs;                                      // If QREQn resets high then transition QACCEPTn high, otherwise hold in reset low state
          nxt_l2qdeny    = 1'b0;                                            // Maintain QDENY low reset state
        end

        RET_L2_FSM_IDLE : begin
          // Wait in this state until we are ready to start the retention entry process.
          nxt_ret_l2_fsm = ret_l2_count_start ? RET_L2_FSM_WAIT_COUNT : RET_L2_FSM_IDLE;
        end

        RET_L2_FSM_WAIT_COUNT : begin
          // Wait in this state until the target counter value is hit.  If the WFx state machine drops
          // out of WFx then move back to idle.
          nxt_ret_l2_fsm = l2_exit_retention ? RET_L2_FSM_IDLE         :
                           ret_l2_target_hit ? RET_L2_FSM_WAIT_STALL_1 : RET_L2_FSM_WAIT_COUNT;
        end

        // Wait for the stall signal to propagate to the L2 to prevent a boundary condition where an L2
        // access is about to occur and will miss the stall.  This ensures that even if QREQn is
        // already low and retention entry will be almost immediate any L2 access will either
        // be stalled or prevent retention entry.
        RET_L2_FSM_WAIT_STALL_1 : begin
          nxt_ret_l2_fsm      = l2_exit_retention ? RET_L2_FSM_IDLE : RET_L2_FSM_WAIT_STALL_2;
          nxt_l2_in_retention = 1'b1;
        end
        RET_L2_FSM_WAIT_STALL_2 : begin
          nxt_ret_l2_fsm      = l2_exit_retention ? RET_L2_FSM_IDLE : RET_L2_FSM_WAIT_STALL_3;
          nxt_l2_in_retention = 1'b1;
        end
        RET_L2_FSM_WAIT_STALL_3 : begin
          nxt_ret_l2_fsm      = l2_exit_retention ? RET_L2_FSM_IDLE : RET_L2_FSM_WAIT_STALL_4;
          nxt_l2_in_retention = 1'b1;
        end
        RET_L2_FSM_WAIT_STALL_4 : begin
          nxt_ret_l2_fsm      = l2_exit_retention ? RET_L2_FSM_IDLE : RET_L2_FSM_WAIT_STALL_5;
          nxt_l2_in_retention = 1'b1;
        end
        RET_L2_FSM_WAIT_STALL_5 : begin
          nxt_ret_l2_fsm      = l2_exit_retention ? RET_L2_FSM_IDLE : RET_L2_FSM_RET_REQ;
          nxt_l2_in_retention = 1'b1;
        end

        RET_L2_FSM_RET_REQ : begin
          // Wait in this state until the external power controller sends the QREQn response.  If L2 becomes
          // active again then move back to idle (which will happen if the power controller never deasserts
          // QREQn).  Once QREQn is asserted either accept and move in to retention or deny and move back to idle.
          nxt_ret_l2_fsm      =  l2_exit_retention                      ? RET_L2_FSM_IDLE    :
                                 (l2qreqn_rs | (~l2qreqn_rs & l2qdeny)) ? RET_L2_FSM_RET_REQ : RET_L2_FSM_IN_RET;
          nxt_l2qactive       =  l2_exit_retention;
          nxt_l2qacceptn      =  l2_exit_retention | l2qdeny  |  l2qreqn_rs;
          nxt_l2qdeny         = (l2_exit_retention | l2qdeny) & ~l2qreqn_rs;
          nxt_l2_in_retention = 1'b1;
        end

        RET_L2_FSM_IN_RET : begin
          // Wait in this state until a retention exit event occurs or the power controller requests exit
          nxt_ret_l2_fsm      = (l2qreqn_rs | l2_exit_retention) ? RET_L2_FSM_RET_EXIT : RET_L2_FSM_IN_RET;
          nxt_l2qactive       = (l2qreqn_rs | l2_exit_retention);
          nxt_l2qacceptn      =  l2qreqn_rs;
          nxt_l2qdeny         = 1'b0;
          nxt_l2_in_retention = 1'b1;
        end

        RET_L2_FSM_RET_EXIT : begin
          // Wait in this state until QREQn is asserted
          nxt_ret_l2_fsm      = l2qreqn_rs ? RET_L2_FSM_IDLE : RET_L2_FSM_RET_EXIT;
          nxt_l2qactive       = 1'b1;
          nxt_l2qacceptn      = l2qreqn_rs;
          nxt_l2qdeny         = 1'b0;
          nxt_l2_in_retention = 1'b1;
        end

        default : begin
          nxt_ret_l2_fsm      = {RET_L2_FSM_W{1'bx}};
          nxt_l2qactive       = 1'bx;
          nxt_l2qacceptn      = 1'bx;
          nxt_l2qdeny         = 1'bx;
          nxt_l2_in_retention = 1'bx;
        end
      endcase
    end

  // L2 retention control registers
  //
  // Note that a reset will result in the state machine moving to the reset state.  In reality if a reset has
  // occured while a L2 is in retention any of the dirty state in the cache has been lost.  However the retention
  // state machine is robust in that it will handshake to exit retention (RET_L2_FSM_RESET == RET_L2_FSM_RET_EXIT).
  // The external reset controller must hold reset until the L2 has exited retention and the state can be
  // initialised.
  assign ret_l2_ctl_en = ret_ready_rs1 | (ret_l2_fsm != RET_L2_FSM_IDLE) | l2_in_retention;

  always @(posedge clk_ret_l2 or negedge reset_n_arb)
    if (~reset_n_arb) begin
      ret_l2_fsm      <= RET_L2_FSM_RESET;
      l2qactive_o     <= 1'b1;
      l2qacceptn_o    <= 1'b0;
      l2_in_retention <= 1'b0;
    end
    else if (ret_l2_ctl_en) begin
      ret_l2_fsm      <= nxt_ret_l2_fsm;
      l2qactive_o     <= nxt_l2qactive;
      l2qacceptn_o    <= nxt_l2qacceptn;
      l2_in_retention <= nxt_l2_in_retention;
    end

  // QREQn will not have a defined value at L2 reset and must be free running to initialise the state machine
  // QREQn is synchronised to assist the timing path coming in to the cluster from the system
  ca53_cell_sync u_ca53_cell_sync0 (.out_o    (l2qreqn_rs),
                                    .clk_i    (CLKIN),
                                    .inp_i    (l2qreqn_i),
                                    .resetn_i (1'b1));

  // QDENY must be in a free-running register so that we can deny spurious QREQn requests from the power controller
  always @(posedge CLKIN or negedge reset_n_arb)
    if (~reset_n_arb)
      l2qdeny <= 1'b0;
    else
      l2qdeny <= nxt_l2qdeny;

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  assign gov_l2_in_retention_o = l2_in_retention;
  assign l2qdeny_o             = l2qdeny;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_l2_count_start")
  u_ovl_x_ret_l2_count_start (.clk       (clk_ret_l2),
                              .reset_n   (reset_n_arb),
                              .qualifier (1'b1),
                              .test_expr (ret_l2_count_start));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ret_l2_ctl_en")
  u_ovl_x_ret_l2_ctl_en (.clk       (clk_ret_l2),
                         .reset_n   (reset_n_arb),
                         .qualifier (1'b1),
                         .test_expr (ret_l2_ctl_en));

  //----------------------------------------------------------------------------
  // State machine X-Checks
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "State-machine: nxt_ret_l2_fsm x-check")
  u_ovl_x_nxt_ret_l2_fsm (.clk       (CLKIN),
                          .reset_n   (reset_n_arb),
                          .qualifier (1'b1),
                          .test_expr (nxt_ret_l2_fsm[3:0]));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Illegal state: ret_l2_fsm")
  u_ovl_ret_l2_fsm_ill (.clk       (CLKIN),
                        .reset_n   (reset_n_arb),
                        .test_expr ((ret_l2_fsm[3:0] == 4'b1011) |
                                    (ret_l2_fsm[3:0] == 4'b1100) |
                                    (ret_l2_fsm[3:0] == 4'b1101) |
                                    (ret_l2_fsm[3:0] == 4'b1110) |
                                    (ret_l2_fsm[3:0] == 4'b1111)));

`endif

endmodule // ca53governor_power

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
