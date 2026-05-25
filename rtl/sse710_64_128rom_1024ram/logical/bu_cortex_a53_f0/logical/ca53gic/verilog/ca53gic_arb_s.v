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
// Abstract: GIC Arbiter Slave (Distributor to CPU Interface)
//-----------------------------------------------------------------------------


`include "cortexa53params.v"


module ca53gic_arb_s `CA53_GIC_PARAM_DECL (
  // Inputs
  input   wire                        clk,
  input   wire                        reset_n,
  input   wire  [(NUM_CPUS-1):0]      gic_arb_ack_i,
  input   wire  [(`CA53_TDATA_W-1):0] icdtdata_i,
  input   wire  [1:0]                 icdtdest_i,
  input   wire                        icdtlast_i,
  input   wire                        icdtvalid_rs_i,
  // Outputs
  output  wire  [31:0]                arb_data_o,
  output  wire  [(NUM_CPUS-1):0]      arb_req_o,
  output  wire                        icdtready_o,
  output  wire                        slave_active_o
);

  // ------------------------------------------------------
  // Constant declarations
  // ------------------------------------------------------

  localparam                      MAX_TRANSFERS       = 2;
  localparam                      MAX_TRANSFERS_LOG2  = `CA53_LOG2(MAX_TRANSFERS);
  localparam                      NUM_CPUS_LOG2       = `CA53_LOG2(NUM_CPUS);
  localparam                      STATE_WIDTH         = 2;
  localparam [(STATE_WIDTH-1):0]  S_IDLE              = 2'b00;
  localparam [(STATE_WIDTH-1):0]  S_READY             = 2'b01;
  localparam [(STATE_WIDTH-1):0]  S_REQUEST_OR_WAIT   = 2'b10;


  // ------------------------------------------------------
  // Variable declarations
  // ------------------------------------------------------

  genvar cpu;
  genvar transfer;


  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg   [(MAX_TRANSFERS_LOG2-1):0]  count;
  reg   [(STATE_WIDTH-1):0]         nxt_state;
  reg   [(STATE_WIDTH-1):0]         state;
  reg   [(`CA53_TDATA_W-1):0]       tdata [(MAX_TRANSFERS-1):0];
  reg                               tlast;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire  [(NUM_CPUS-1):0]            arb_req;
  wire  [(MAX_TRANSFERS_LOG2-1):0]  nxt_count;
  wire                              packet_received;
  wire  [(NUM_CPUS-1):0]            selected_cpu;
  wire                              store_transfer;
  wire  [(MAX_TRANSFERS-1):0]       tdata_en;
  wire  [(NUM_CPUS_LOG2-1):0]       tdest;
  wire                              transfer_received;


  // ------------------------------------------------------
  // Transfer FSM
  // ------------------------------------------------------

  // The transfer FSM must account for the extra cycle delay for TVALID.  After
  // registering each transfer there is an added state the FSM must transition
  // through before returning to S_IDLE.

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      state <= S_IDLE;
    end else begin
      state <= nxt_state;
    end

  always @* begin

    nxt_state = state;

    case ( state )

      S_IDLE : begin
        if ( icdtvalid_rs_i ) begin
          nxt_state = S_READY;
        end
      end

      S_READY : begin
        nxt_state = S_REQUEST_OR_WAIT;
      end

      S_REQUEST_OR_WAIT : begin
        if ( ( |gic_arb_ack_i ) | ~tlast ) begin
          nxt_state = S_IDLE;
        end
      end

      default : begin
        nxt_state = {STATE_WIDTH{1'bx}};
      end

    endcase

  end

  assign { transfer_received , store_transfer } = state;


  // ------------------------------------------------------
  // Transfer count tracking
  // ------------------------------------------------------

  // Track number of packets received per packet:
  // - Generate TDATA write enable
  // - Prevent buffer overruns for unknown Downstream Write packets exceeding two transfers

  assign nxt_count = tlast      ? {MAX_TRANSFERS_LOG2{1'b0}} :
                     ( &count ) ? count :
                                  ( count + 1'b1 );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      count <= {MAX_TRANSFERS_LOG2{1'b0}};
    end else if ( transfer_received ) begin
      count <= nxt_count;
    end


  // ------------------------------------------------------
  // Packet buffer
  // ------------------------------------------------------

  generate

    for ( transfer = 0; transfer < MAX_TRANSFERS; transfer = transfer + 1 ) begin : packet_tdata

      assign tdata_en[transfer] = store_transfer & ( count == transfer[(MAX_TRANSFERS_LOG2-1):0] );

      always @ ( posedge clk )
        if ( tdata_en[transfer] ) begin
          tdata[transfer] <= icdtdata_i;
        end

      assign arb_data_o[(transfer*`CA53_TDATA_W)+:`CA53_TDATA_W] = tdata[transfer];

    end

  endgenerate

  generate

    if ( NUM_CPUS > 1 ) begin : transfer_tdest_present

      reg [(NUM_CPUS_LOG2-1):0] tdest_impl;

      always @ ( posedge clk )
        if ( store_transfer ) begin
          tdest_impl <= icdtdest_i[(NUM_CPUS_LOG2-1):0];
        end

      assign tdest = tdest_impl;

    end else begin : gic_ack_without_tdest

      assign tdest = 1'b0;

    end

  endgenerate

  always @ ( posedge clk )
    if ( store_transfer ) begin
      tlast <= icdtlast_i;
    end

  assign packet_received = transfer_received & tlast;


  // ------------------------------------------------------
  // One-hot encoding for TDEST
  // ------------------------------------------------------

  generate

    for ( cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1 ) begin : destination_cpu

      assign selected_cpu[cpu] = tdest == cpu[(NUM_CPUS_LOG2-1):0];

    end

  endgenerate

  assign arb_req = selected_cpu & {NUM_CPUS{packet_received}};


  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign arb_req_o      = arb_req;
  assign icdtready_o    = store_transfer;
  assign slave_active_o = state != S_IDLE;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "FSM: State unknown")
  u_ovl_fsm_state_known (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr ((state == S_IDLE) |
                                     (state == S_READY) |
                                     (state == S_REQUEST_OR_WAIT)));

  assert_zero_one_hot #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "Only one CPU Interface should assert ACK")
  u_ovl_zoh_gic_arb_ack_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr (gic_arb_ack_i));

  assert_zero_one_hot #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "Only one CPU Interface should receive a REQ")
  u_ovl_zoh_arb_req (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr (arb_req));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only the CPU that was sent an ACK should send a REQ")
  u_ovl_match_ack_req (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (|gic_arb_ack_i),
                       .consequent_expr (|(gic_arb_ack_i & arb_req)));


  // ------------------------------------------------------
  // X-check
  // ------------------------------------------------------

  // FSM inputs
  assert_never_unknown #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "FSM input x-check: gic_arb_ack_i")
  u_fsm_x_gic_arb_ack_i (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (gic_arb_ack_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: icdtvalid_rs_i")
  u_fsm_x_icdtvalid_rs_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (icdtvalid_rs_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: tlast")
  u_fsm_x_tlast (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (state == S_REQUEST_OR_WAIT),
                 .test_expr (tlast));

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: store_transfer")
  u_ovl_x_store_transfer (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (store_transfer));

  assert_never_unknown #(`OVL_FATAL, MAX_TRANSFERS, `OVL_ASSERT, "Register enable x-check: tdata_en")
  u_ovl_x_tdata_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (tdata_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: transfer_received")
  u_ovl_x_transfer_received (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (transfer_received));

  // OVL_ASSERT_END

`endif

endmodule // ca53gic_arb_s


`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE

