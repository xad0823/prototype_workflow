//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited.
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
// Description:
// Track DVM Sync message completion
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53scu_dvmcomp #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire         clk,
  input  wire         reset_n,
  input  wire         config_broadcastinner_i,
  output wire         dvmcomp_active_o,

  input  wire         tagctl_snp_dvm_sync_tc4_i,
  input  wire [3:0]   tagctl_cpu_dvm_sync_tc4_i,
  input  wire         snpslv_sync_reqbuf_alloc_i,
  output wire         dvmcomp_start_comp_o,
  input  wire         snpslv_dvm_complete_i,
  output wire         dvm_comp_sync_outstanding_o,

  input  wire         dcu_cpu0_dvm_complete_i,
  input  wire         dcu_cpu1_dvm_complete_i,
  input  wire         dcu_cpu2_dvm_complete_i,
  input  wire         dcu_cpu3_dvm_complete_i,
  output wire         scu_cpu0_dvm_complete_o,
  output wire         scu_cpu1_dvm_complete_o,
  output wire         scu_cpu2_dvm_complete_o,
  output wire         scu_cpu3_dvm_complete_o,
  input  wire [3:0]   tagctl_dvm_complete_i
);

  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  reg [8:0]           ext_sync_counter;
  reg [8:0]           ext_complete_counter;
  reg                 ext_sync_outstanding;
  reg [8:0]           ext_sync_snapshot;
  reg [1:0]           cpu_sync_id;

  wire [8:0]          next_ext_sync_counter;
  wire [8:0]          next_ext_complete_counter;
  wire [3:0]          dcu_cpu_dvm_complete;
  wire [3:0]          scu_cpu_dvm_complete;
  wire [3:0]          cpu_complete_ready;
  wire [4:0]          sync_outstanding;
  wire [4:0]          sync_completing;
  wire                next_ext_sync_outstanding;
  wire                cpu_dvm_sync_serialised;
  wire [1:0]          next_cpu_sync_id;
  wire [NUM_CPUS-1:0] cpu_complete_counter_en;

  genvar i;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  // If the CPU and tagctl send a complete for the same CPU in the same cycle,
  // then tagctl will send its complete again in the following cycle, so it is
  // safe to only count one of them.
  assign dcu_cpu_dvm_complete = {dcu_cpu3_dvm_complete_i,
                                 dcu_cpu2_dvm_complete_i,
                                 dcu_cpu1_dvm_complete_i,
                                 dcu_cpu0_dvm_complete_i} | tagctl_dvm_complete_i;

  // The external sync counter tracks how many DVM syncs from the external
  // interface have been serialised (modulo the size of the counter).
  // It must be big enough to hold all 256 syncs that the interconnect might
  // have outstanding at any one time.
  assign next_ext_sync_counter = ext_sync_counter + 9'b000000001;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ext_sync_counter <= {9{1'b0}};
  end else if (tagctl_snp_dvm_sync_tc4_i) begin
    ext_sync_counter <= next_ext_sync_counter;
  end

  // The external complete counter tracks how many DVM completes have been sent
  // to the external interface. If its value is different to the external sync
  // counter, then that indicates that there are one or more DVM syncs in
  // progress.
  assign next_ext_complete_counter = ext_complete_counter + 9'b000000001;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ext_complete_counter <= {9{1'b0}};
  end else if (snpslv_sync_reqbuf_alloc_i) begin
    ext_complete_counter <= next_ext_complete_counter;
  end

  generate for (i = 0; i < 4; i = i + 1) begin : g_cpus
    if (i < NUM_CPUS) begin : g_cpu
      reg        cpu_sync_outstanding;
      reg [8:0]  cpu_complete_counter;
      reg        cpu_dvm_complete;

      wire       next_cpu_sync_outstanding;
      wire       expect_cpu_sync;
      wire [8:0] next_cpu_complete_counter;
      wire       next_cpu_dvm_complete;

      // Store when a DVM sync from a CPU has been sent to this CPU, and hasn't
      // received a complete yet. If SMP enable is low, then tagctl will
      // generate a complete on behalf of the CPU, so we do not have to treat
      // the CPUs any differently here.
      assign next_cpu_sync_outstanding = (cpu_dvm_sync_serialised |
                                          (cpu_sync_outstanding & ~sync_completing[i]));

      always @(posedge clk or negedge reset_n)
      if (~reset_n) begin
        cpu_sync_outstanding <= 1'b0;
      end else begin
        cpu_sync_outstanding <= next_cpu_sync_outstanding;
      end

      assign sync_outstanding[i] = cpu_sync_outstanding;

      // If there is a sync outstanding to this CPU, and the complete counter
      // matches the snapshot of the external sync counter when this sync
      // started, then all earlier external syncs must have now completed and
      // so the next complete from the CPU must relate to this sync.
      assign expect_cpu_sync = cpu_sync_outstanding & (ext_sync_snapshot == cpu_complete_counter);

      assign sync_completing[i] = dcu_cpu_dvm_complete[i] & expect_cpu_sync;


      // The CPU complete counter tracks how many DVM completes have been
      // received from the CPU that were due to external DVM syncs.
      assign next_cpu_complete_counter = cpu_complete_counter + 9'b000000001;

      assign cpu_complete_counter_en[i] = dcu_cpu_dvm_complete[i] & ~expect_cpu_sync;

      always @(posedge clk or negedge reset_n)
      if (~reset_n) begin
        cpu_complete_counter <= {9{1'b0}};
      end else if (cpu_complete_counter_en[i]) begin
        cpu_complete_counter <= next_cpu_complete_counter;
      end

      // If the cpu complete counter is different to the external complete
      // counter then that means the CPU has completed more syncs than have
      // been sent externally, and so this CPU is ready to send the complete
      // externally.
      assign cpu_complete_ready[i] = (cpu_complete_counter != ext_complete_counter);


      // Send a complete back to the CPU when all outstanding completes from
      // other CPUs and external have been received.
      assign next_cpu_dvm_complete = (|sync_outstanding &
                                      (&(sync_completing | ~sync_outstanding)) &
                                      (cpu_sync_id == i[1:0]));

      always @(posedge clk or negedge reset_n)
      if (~reset_n) begin
        cpu_dvm_complete <= 1'b0;
      end else begin
        cpu_dvm_complete <= next_cpu_dvm_complete;
      end

      assign scu_cpu_dvm_complete[i] = cpu_dvm_complete;

    end else begin : g_n_cpu
      assign sync_outstanding[i] = 1'b0;
      assign sync_completing[i] = 1'b0;
      assign cpu_complete_ready[i] = 1'b1;
      assign scu_cpu_dvm_complete[i] = 1'b0;
    end
  end endgenerate

  assign cpu_dvm_sync_serialised = |tagctl_cpu_dvm_sync_tc4_i;

  assign sync_completing[4] = snpslv_dvm_complete_i;

  // Store when a DVM sync from a CPU has been sent to the external
  // interconnect, and hasn't received a complete yet.
  assign next_ext_sync_outstanding = ((cpu_dvm_sync_serialised & config_broadcastinner_i) |
                                      (ext_sync_outstanding & ~snpslv_dvm_complete_i));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ext_sync_outstanding <= 1'b0;
  end else begin
    ext_sync_outstanding <= next_ext_sync_outstanding;
  end

  assign sync_outstanding[4] = ext_sync_outstanding;


  // If all cpu complete counters are ready, then the external complete can be sent.
  assign dvmcomp_start_comp_o = &cpu_complete_ready;

  // The CPU external sync snapshot holds the value of the external sync
  // counter at the time a CPU serialises a DVM sync. A CPU can only have
  // one sync in progress at a time.

  // Store the CPU that is currently has a serialised sync outstanding, so that
  // we can return the complete back to the same place.
  assign next_cpu_sync_id = {|tagctl_cpu_dvm_sync_tc4_i[3:2],
                             tagctl_cpu_dvm_sync_tc4_i[3] |
                             tagctl_cpu_dvm_sync_tc4_i[1]};

  always @(posedge clk)
  if (cpu_dvm_sync_serialised) begin
    ext_sync_snapshot <= ext_sync_counter;
    cpu_sync_id       <= next_cpu_sync_id;
  end


  assign scu_cpu0_dvm_complete_o = scu_cpu_dvm_complete[0];
  assign scu_cpu1_dvm_complete_o = scu_cpu_dvm_complete[1];
  assign scu_cpu2_dvm_complete_o = scu_cpu_dvm_complete[2];
  assign scu_cpu3_dvm_complete_o = scu_cpu_dvm_complete[3];

  assign dvmcomp_active_o = |sync_outstanding | (ext_sync_counter != ext_complete_counter);

  assign dvm_comp_sync_outstanding_o = |sync_outstanding;

  //-----------------------------------------------------------------------------
  //  Assertions
  //-----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "There can be only one outstanding CPU Sync")
  u_ovl_cpu_one_sync (.clk              (clk),
                      .reset_n          (reset_n),
                      .antecedent_expr  (|sync_outstanding),
                      .consequent_expr  (~cpu_dvm_sync_serialised));


  assert_never_unknown #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "Register enable x-check: cpu_complete_counter_en")
  u_ovl_x_cpu_complete_counter_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (cpu_complete_counter_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpu_dvm_sync_serialised")
  u_ovl_x_cpu_dvm_sync_serialised (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (cpu_dvm_sync_serialised));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: snpslv_sync_reqbuf_alloc_i")
  u_ovl_x_snpslv_sync_reqbuf_alloc (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (snpslv_sync_reqbuf_alloc_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_snp_dvm_sync_tc4_i")
  u_ovl_x_tagctl_snp_dvm_sync_tc4_i (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (tagctl_snp_dvm_sync_tc4_i));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/




