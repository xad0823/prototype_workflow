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
// Abstract: GIC Arbiter Master (CPU Interfaces to Distributor)
//-----------------------------------------------------------------------------


`include "cortexa53params.v"


module ca53gic_arb_m `CA53_GIC_PARAM_DECL (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire  [(`CA53_TDATA_PKDED_W-1):0] gic_tdata_i,
  input   wire  [(NUM_CPUS-1):0]            gic_tlast_i,
  input   wire  [(NUM_CPUS-1):0]            gic_tvalid_i,
  input   wire                              icctready_i,
  // Outputs
  output  wire  [NUM_CPUS-1:0]              arb_tready_o,
  output  wire  [(`CA53_TDATA_W-1):0]       icctdata_o,
  output  wire  [1:0]                       icctid_o,
  output  wire                              icctlast_o,
  output  wire                              icctvalid_o,
  output  wire                              master_active_o
);

  // ------------------------------------------------------
  // Constant declarations
  // ------------------------------------------------------

  localparam                  NUM_CPUS_LOG2           = `CA53_LOG2(NUM_CPUS);
  localparam                  STATE_W                 = 2;
  localparam [(STATE_W-1):0]  S_IDLE                  = 2'b00;
  localparam [(STATE_W-1):0]  S_CPU_TRANSFER          = 2'b01;
  localparam [(STATE_W-1):0]  S_DISTRIBUTOR_TRANSFER  = 2'b10;


  // ------------------------------------------------------
  // Variable declarations
  // ------------------------------------------------------

  genvar cpu;
  genvar tdata_bit;


  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg   [(STATE_W-1):0]       nxt_state;
  reg   [(STATE_W-1):0]       state;
  reg   [(`CA53_TDATA_W-1):0] tdata;
  reg                         tlast;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire                        arb_tready_selected;
  wire                        gic_tvalid_selected;
  wire                        icctvalid;
  wire  [(`CA53_TDATA_W-1):0] nxt_tdata;
  wire                        nxt_tlast;
  wire                        tid_en;
  wire                        transfer_en;


  // ------------------------------------------------------
  // Arbiter CPU Interface Bus Multiplexing
  // ------------------------------------------------------

  generate

    if ( NUM_CPUS > 1 ) begin : mux_present

      wire  [(NUM_CPUS-1):0]      arb;
      wire  [(NUM_CPUS-1):0]      gic_tlast_valid;
      wire  [(NUM_CPUS-1):0]      gic_tvalid_valid;
      reg   [(NUM_CPUS_LOG2-1):0] nxt_tid;
      reg   [(NUM_CPUS_LOG2-1):0] tid;


      // ------------------------------------------------------
      // I/O Mux
      // ------------------------------------------------------

      // AND-OR parameterized number of multi-bit inputs mux
      for ( tdata_bit = 0; tdata_bit <`CA53_TDATA_W; tdata_bit = tdata_bit + 1 ) begin : mux_tdata
        wire [(NUM_CPUS-1):0] nxt_tdata_bit;
        for ( cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1 ) begin : mux_tdata_bit
          assign nxt_tdata_bit[cpu] = ( cpu[(NUM_CPUS_LOG2-1):0] == tid ) & gic_tdata_i[( cpu * `CA53_TDATA_W ) + tdata_bit];
        end
        assign nxt_tdata[tdata_bit]  = |nxt_tdata_bit;
      end

      // AND-OR parameterized number of single-bit inputs mux
      for ( cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1 ) begin : mux_tlast_tready_tvalid
        assign arb_tready_o[cpu]      = ( cpu[(NUM_CPUS_LOG2-1):0] == tid ) & arb_tready_selected;
        assign gic_tlast_valid[cpu]   = ( cpu[(NUM_CPUS_LOG2-1):0] == tid ) & gic_tlast_i[cpu];
        assign gic_tvalid_valid[cpu]  = ( cpu[(NUM_CPUS_LOG2-1):0] == tid ) & gic_tvalid_i[cpu];
      end

      assign nxt_tlast            = |gic_tlast_valid;
      assign gic_tvalid_selected  = |gic_tvalid_valid;


      // ------------------------------------------------------
      // Select the next ID
      // ------------------------------------------------------

      // Round-Robin Arbiter to calculate next TID
      ca53_rr_arb #( .WIDTH(NUM_CPUS) )
      u_ca53_rr_arb (
        .clk          (clk),
        .reset_n      (reset_n),
        .rr_counter_i (tid[(NUM_CPUS_LOG2-1):0]),
        .requests_i   (gic_tvalid_i[(NUM_CPUS-1):0]),
        .arb_o        (arb[(NUM_CPUS-1):0])
      ); // u_ca53_rr_arb

      // Convert one-hot TVALID to binary to use as current TID
      integer k;
      always @* begin
        nxt_tid = {NUM_CPUS_LOG2{1'b0}};
        for ( k = 0; k < NUM_CPUS; k = k + 1 ) begin
          if ( arb[k] ) begin
            nxt_tid = nxt_tid | k[(NUM_CPUS_LOG2-1):0];
          end
        end
      end

      // TID should only be updated before any or at the end of a transaction.
      assign tid_en = ( state == S_IDLE ) & |gic_tvalid_i;

      always @ ( posedge clk or negedge reset_n )
        if ( !reset_n ) begin
          tid <= {NUM_CPUS_LOG2{1'b0}};
        end else if ( tid_en ) begin
          tid <= nxt_tid;
        end


      if ( NUM_CPUS_LOG2 < 2 ) begin : tid_size_lt
        assign icctid_o = { 1'b0 , tid};
      end else begin : tid_size_eq
        assign icctid_o = tid;
      end

    end else begin : mux_not_present

      assign arb_tready_o         = arb_tready_selected;
      assign gic_tvalid_selected  = gic_tvalid_i;
      assign icctid_o             = {2{1'b0}};
      assign nxt_tdata            = gic_tdata_i;
      assign nxt_tlast            = gic_tlast_i;

    end

  endgenerate


  // ------------------------------------------------------
  // Transfer FSM
  // ------------------------------------------------------

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
        if ( |gic_tvalid_i ) begin
          nxt_state = S_CPU_TRANSFER;
        end
      end

      S_CPU_TRANSFER : begin
        if ( gic_tvalid_selected ) begin
          nxt_state = S_DISTRIBUTOR_TRANSFER;
        end
      end

      S_DISTRIBUTOR_TRANSFER : begin
        if ( icctready_i ) begin
          if ( tlast ) begin
            nxt_state = ( NUM_CPUS == 1 ) ? S_CPU_TRANSFER : S_IDLE;
          end else begin
            nxt_state = S_CPU_TRANSFER;
          end
        end
      end

      default : begin
        nxt_state = {STATE_W{1'bx}};
      end

    endcase

  end


  assign { icctvalid , arb_tready_selected } = state;


  // ------------------------------------------------------
  // Transfer register slice
  // ------------------------------------------------------

  assign transfer_en = arb_tready_selected & gic_tvalid_selected;

  always @ ( posedge clk )
    if ( transfer_en ) begin
      tdata <= nxt_tdata;
      tlast <= nxt_tlast;
    end


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign icctdata_o       = tdata;
  assign icctlast_o       = tlast;
  assign icctvalid_o      = icctvalid;
  assign master_active_o  = state != S_IDLE;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  wire fsm_state_known;

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "FSM: State unknown")
  u_ovl_fsm_state_known (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (( state == S_IDLE ) |
                                     ( state == S_CPU_TRANSFER ) |
                                     ( state == S_DISTRIBUTOR_TRANSFER )));


  // ------------------------------------------------------
  // X-check
  // ------------------------------------------------------

  // FSM
  assert_never_unknown #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "FSM x-check: gic_tvalid")
  u_ovl_x_fsm_gic_tvalid (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (gic_tvalid_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM x-check: gic_tvalid_selected")
  u_ovl_x_fsm_gic_tvalid_selected (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (gic_tvalid_selected));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM x-check: tlast")
  u_ovl_x_fsm_tlast (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier ((state==S_DISTRIBUTOR_TRANSFER)),
                     .test_expr (tlast));

  // Register enables
  generate

    if ( NUM_CPUS > 1 ) begin : ovl_mux_present

      assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tid_en")
      u_ovl_x_tid_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (tid_en));
    end

  endgenerate

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: transfer_en")
  u_ovl_x_transfer_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (transfer_en));

  // OVL_ASSERT_END

`endif


endmodule // ca53gic_arb_m


`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE

