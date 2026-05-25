//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-10-19 19:49:33 +0100 (Wed, 19 Oct 2011) $
//
//      Revision            : $Revision: 189144 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------

module gic400_priority #(parameter NUM_INTS = 256,
                                   NUM_CPUS = 4)  // Used by OVLs
(
  input  wire                  clk,
  input  wire                  clk_pri,
  input  wire                  reset_n,

  input  wire [NUM_INTS-1:0]   irqs_valid_i,
  input  wire [NUM_INTS-1:0]   irqs_nsecurity_i,
  input  wire [NUM_INTS*5-1:0] irq_priorities_i,
  input  wire [3*16-1:0]       sgi_cpus_i,

  input  wire                  int_ack_i,
  input  wire                  priority_state_en_i,
  input  wire                  suppress_high_en_i,

  output wire                  high_valid_o,
  output wire [4:0]            high_priority_o,
  output wire [8:0]            high_id_o,
  output wire                  high_nsecure_o,
  output wire [2:0]            high_cpu_o
);

  //-----------------------------------------------------------------------------
  // Declarations
  //-----------------------------------------------------------------------------

  `include "gic400_defs.v"

  localparam NUM_ID_BITS = log2(NUM_INTS);

  wire [7:0]             nxt_priority_state;
  reg  [7:0]             priority_state_q;
  reg  [15:0]            sgis_current_q;
  reg  [6:0]             ppis_current_q;
  reg  [NUM_INTS-33:0]   spis_current_q;
  wire [NUM_INTS-1:0]    irqs_current;
  wire [NUM_INTS-1:0]    nxt_irqs_current;
  reg  [4:0]             current_priority_q;
  reg                    current_nsecure_q;
  wire [4:0]             nxt_high_priority;
  wire                   high_en;
  reg  [4:0]             high_priority_q;
  reg  [NUM_ID_BITS-1:0] high_id_q;
  reg                    high_nsecure_q;
  reg  [2:0]             current_cpu_q;
  reg  [2:0]             nxt_current_cpu;
  reg  [2:0]             high_cpu_q;
  reg                    high_valid_q;
  wire                   nxt_high_valid;
  reg  [NUM_ID_BITS-1:0] current_id;
  wire [NUM_INTS-1:0]    irqs_current_priority_bit;
  wire                   current_priority_match;
  wire [NUM_INTS-1:0]    lower_still_current;

  genvar irq, pri_bit;

  //-----------------------------------------------------------------------------
  // Main code
  //-----------------------------------------------------------------------------

  // The priority logic uses an iterative algorithm taking 8 cycles to select
  // one of the highest priority pending interrupts. The logic works by ORing
  // together each priority bit for each IRQ, starting with the MSB, in turn.
  // On each cycle, if the output of the OR indicates that any IRQ has the bit set
  // (the priority inputs are inverted, so a greater priority input corresponds
  // to a higher priority IRQ), then any IRQs which do not have the bit set
  // are eliminated. After 5 cycles (one for each priority bit), the
  // algorithm has determined all the valid IRQs with the same, highest,
  // priority.
  // In the next cycle, the algorithm selects one of these valid interrupts
  // by choosing the one with the lowest ID. On the cycle after that, the
  // priority logic is reused to determine the security of the selected
  // interrupt. This saves implementing a large, NUM_IRQS:1 multiplexer to
  // perform the same job, saving area at the cost of an extra cycle in the
  // algorithm.
  // In the final cycle, the priority logic updates the outputs to the CPU
  // interface, and re-samples the pending IRQs from the distributor, ready
  // for the next iteration.

  // ----------------------
  // Priority state machine
  // ----------------------
  // The priority state machine is one-hot, where each bit corresponds to the
  // following states:
  // [7-3] - Each bit of the priority ([7] corresponds to the MSB, etc).
  // [2]   - The lowest valid ID is selected
  // [1]   - The security is calculated
  // [0]   - The output is updated and new inputs are sampled.

  // When an Ack transaction changes the state of the pending IRQs input to
  // the priority logic, the priority state machine is restarted from state
  // 0, to immediately recapture the new state of irqs_valid and reduce the
  // time required to recalculate the new valid IRQ output.
  assign nxt_priority_state = int_ack_i ? 8'b00000001
                                        : {priority_state_q[0], priority_state_q[7:1]};

  // On the last cycle before clk_pri is turned off, the state machine will
  // be in state[0], at the end of an iteration. One final clock pulse is
  // required, to update the output registers, however the state machine is
  // not enabled in this state, so that it will wait in state[0] ready to
  // capture the new input state when the clock is re-enabled.
  always @(posedge clk_pri or negedge reset_n)
    if (!reset_n)
      priority_state_q <= 8'b00000001;
    else if (priority_state_en_i)
      priority_state_q <= nxt_priority_state;

  // ----------------------
  // IRQ Current Registers
  // ----------------------

  generate for (irq=0; irq<NUM_INTS; irq=irq+1) begin : g_irqs_current

    if ((irq<16) || (irq>=25)) begin : g_valid_irqs_current

      // In each state, clear the irqs_current flag for an IRQ if the priority
      // logic determines it is no longer valid. The function of the priority
      // logic depends on the state of the priority state machine.
      assign irqs_current_priority_bit[irq] = |({~irq_priorities_i[5*irq +:5],  // States 7-3 correspond to each priority bit
                                                 1'b1,                          // State 2 is where a single IRQ is selected
                                                 irqs_nsecurity_i[irq],         // State 1 is where the security is calculated
                                                 1'b1} &                        // State 0 is where the output is generated
                                                priority_state_q[7:0]);

      // The current bit for each IRQ is cleared during the priority
      // calculation when it is determined the IRQ does not have sufficient
      // priority. After the state[2], a single IRQ will have irqs_current 
      // set, and this will remain set during the nsecurity and output 
      // states.
      assign nxt_irqs_current[irq] = (priority_state_q[7] & irqs_current[irq] & (~irq_priorities_i[5*irq+4] | ~current_priority_match)) |
                                     (priority_state_q[6] & irqs_current[irq] & (~irq_priorities_i[5*irq+3] | ~current_priority_match)) |
                                     (priority_state_q[5] & irqs_current[irq] & (~irq_priorities_i[5*irq+2] | ~current_priority_match)) |
                                     (priority_state_q[4] & irqs_current[irq] & (~irq_priorities_i[5*irq+1] | ~current_priority_match)) |
                                     (priority_state_q[3] & irqs_current[irq] & (~irq_priorities_i[5*irq]   | ~current_priority_match)) |
                                     (priority_state_q[2] & irqs_current[irq] & ~lower_still_current[irq]) |
                                     (priority_state_q[1] & irqs_current[irq]) |
                                     (priority_state_q[0] & irqs_valid_i[irq]);

      // Separate irqs_current registers are used for SGIs, PPIs and SPIs,
      // which are concatenated to form the irqs_current signal.
      if (irq<16) begin : g_sgis_current
        // SGIs (IRQ0-15)
        always @(posedge clk_pri)
          sgis_current_q[irq] <= nxt_irqs_current[irq];

        assign irqs_current[irq] = sgis_current_q[irq];
      end else if (irq<32) begin : g_ppis_current
        // PPIs (IRQ25-31)
        always @(posedge clk_pri)
          ppis_current_q[irq-25] <= nxt_irqs_current[irq];

        assign irqs_current[irq] = ppis_current_q[irq-25];
      end else begin : g_spis_current
        // SPIs (IRQ32+)
        always @(posedge clk_pri)
          spis_current_q[irq-32] <= nxt_irqs_current[irq];

        assign irqs_current[irq] = spis_current_q[irq-32];
      end

      // To calculate the lowest valid IRQ to select in state[2], an array
      // which indicates for each IRQ whether there are any lower IRQs still
      // current is created.
      if (irq == 0) begin : g_lower_still_current_tieoff
        assign lower_still_current[irq] = 1'b0;
      end else begin : g_lower_still_current
        assign lower_still_current[irq] = |irqs_current[irq-1:0];
      end

    end else begin : g_irqs_current_tieoff
      // Tie off irqs_current signals used outside of generate for IRQ IDs
      // which are not implemented.
      assign irqs_current_priority_bit[irq] = 1'b0;
      assign irqs_current[irq]              = 1'b0;
    end

  end endgenerate

  // In each state, the priority match is the OR of irqs_current and the
  // current priority bit.
  assign current_priority_match = |(irqs_current[NUM_INTS-1:0] & irqs_current_priority_bit[NUM_INTS-1:0]);

  // ----------------------
  // Output Calculation
  // ----------------------

  // Each bit of the priority of the selected interrupt is formed by
  // registering current_priority_match during each of the priority
  // arbitration states (7-3).
  generate for (pri_bit = 0; pri_bit < 5; pri_bit = pri_bit + 1) begin : g_current_priority

    always @(posedge clk_pri)
      if (priority_state_q[pri_bit+3])
        current_priority_q[pri_bit] <= current_priority_match;

  end endgenerate

  // The nsecure value is taken from current_priority_match during the
  // security stage (state [1]).
  //
  // The current_cpu_q must be from a register so that SGI pending bits can
  // change during state[0] (or else they would never be allowed to change).
  //
  // - The source CPU for SGIs is selected from the inputs based on the
  // calculated ID in state [0]. The value is ignored on non-SGI interrupts,
  // so only the bottom 4 bits of the ID are used to select. The inputs are
  // packed into 1-D array in the format:
  // {SGI15 CPU [2:0], SGI14 CPU [2:0], ... SGI0 CPU [2:0]}.
  always @* begin : g_nxt_current_cpu
    integer sgi;
    reg[2:0] nxt_current_cpu_tmp;

    nxt_current_cpu_tmp = 3'b000;

    for (sgi=0; sgi<16; sgi=sgi+1) begin
      nxt_current_cpu_tmp = nxt_current_cpu_tmp | ({3{irqs_current[sgi]}} & sgi_cpus_i[sgi*3 +: 3]);
    end

    nxt_current_cpu = nxt_current_cpu_tmp;
  end

  always @(posedge clk_pri)
    if (priority_state_q[1]) begin
      current_nsecure_q <= current_priority_match;
      current_cpu_q     <= nxt_current_cpu;
    end

  // The ID of the selected interrupt is generated in state 0, when the
  // single valid IRQ has been selected. The ID is the binary form of the
  // one-hot IRQ represented by irqs_current.
  always @* begin : g_current_id
    integer i;
    reg[NUM_ID_BITS-1:0] current_id_tmp;

    current_id_tmp = {NUM_ID_BITS{1'b0}};

    for (i=0; i<NUM_INTS; i=i+1) begin
      if (irqs_current[i])
        current_id_tmp[NUM_ID_BITS-1:0] = current_id_tmp[NUM_ID_BITS-1:0] | i[NUM_ID_BITS-1:0];
    end

    current_id[NUM_ID_BITS-1:0] = current_id_tmp[NUM_ID_BITS-1:0];
  end

  // Capture the output values in state[0]

  // - On the first cycle after the priority logic is re-enabled after being
  // idle, or the first cycle after an Ack, the state machine will be in
  // zero, but will not have performed an iteration to calculate new output
  // values. Therefore, the outputs should not be enabled in this case.
  assign high_en = priority_state_q[0] & ~suppress_high_en_i;

  // - The valid bit is cleared when there is an Ack, to reduce the time
  // taken for the IRQ output to the CPU to be deactivated (an Ack could
  // happen whilst the priority logic is idle, so the register is clocked off
  // the free running clock).
  assign nxt_high_valid = ~int_ack_i &
                          (high_en ? current_priority_match : high_valid_q);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      high_valid_q <= 1'b0;
    else
      high_valid_q <= nxt_high_valid;

  assign nxt_high_priority = ~current_priority_q[4:0]; // Priority calculated off inverted value, so invert back for output

  always @(posedge clk_pri)
    if (high_en) begin
      high_priority_q <= nxt_high_priority;
      high_id_q       <= current_id;
      high_nsecure_q  <= current_nsecure_q;
      high_cpu_q      <= current_cpu_q;
    end

  // Priority calculation result to CPU interface.
  assign high_valid_o               = high_valid_q;
  assign high_priority_o[4:0]       = high_priority_q[4:0];
  assign high_nsecure_o             = high_nsecure_q;
  assign high_id_o[NUM_ID_BITS-1:0] = high_id_q[NUM_ID_BITS-1:0];

  // - Tie off the unused ID outputs
  generate if (NUM_ID_BITS < 9) begin : g_high_id_padding
    assign high_id_o[8:NUM_ID_BITS] = {9-NUM_ID_BITS{1'b0}};
  end endgenerate

  // - The CPU interface requires that the CPU output be masked off when the
  // indicated IRQ is not an SGI. The masking is done on the output rather
  // than on current_cpu_q, as the current_id signal is late in state[0], and
  // the output is not required early in the CPU interface.
  assign high_cpu_o = high_cpu_q & {3{~|high_id_q[NUM_ID_BITS-1:4]}}; // SGIs are IDs 0-15

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // ----------------------
  // Design properties
  // ----------------------

  // The priority state machine is one hot
  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Priority state machine is one hot")
  ovl_priority_state_oneh    (.clk       (clk_pri),
                              .reset_n   (reset_n),
                              .test_expr (priority_state_q));

  // The irqs_current registers are set from the external input in state[0]
  // then progressively cleared. This means that a bit which is not set
  // after state 0 must not become set during the iteration, nor must a bit
  // which is clear become set again.
  reg [NUM_INTS-1:0] prev_irqs_current;
  always @(posedge clk_pri or negedge reset_n)
    if (!reset_n)
      prev_irqs_current <= {NUM_INTS{1'b0}};
    else
      prev_irqs_current <= irqs_current;

  // - Note that if int_ack_i is asserted when in state[0] then the state
  // machine will will stay in state[0] (with suppress_high_en_i asserted) 
  // after loading the a new value, so bits can legally become set in that 
  // case. The state machine will also stay in state[0] when the state 
  // machine is not enabled.

  wire change_allowed = priority_state_q[0] & suppress_high_en_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"A bit of irqs_current became set without new value being loaded")
  ovl_irqs_current_set   (.clk              (clk_pri),
                          .reset_n          (reset_n),
                          .antecedent_expr  (~priority_state_q[7] & ~change_allowed),  // New value loaded in [0], so can have become set in [7]
                          .consequent_expr  (~|(irqs_current & ~prev_irqs_current)));

  // After state[2], when the single valid IRQ is selected, irqs_current
  // must be one-hot (or zero, if there is no valid IRQ).
  assert_zero_one_hot #(`OVL_FATAL,NUM_INTS,`OVL_ASSERT,"More than one IRQ still valid after state[2]")
  ovl_irqs_current_oneh  (.clk       (clk_pri),
                          .reset_n   (reset_n),
                          .test_expr ({NUM_INTS{priority_state_q[1] | (priority_state_q[0] & ~change_allowed)}} & irqs_current));

  // The nsecurity value is calculated in state [1] reusing the priority
  // logic. The logic relies on the fact that this calculation cannot clear
  // irqs_current for an IRQ if it is set, regardless of the value of the
  // nsecure input. Therefore, the value of irqs_current should not change
  // between states [1] and [0].
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The value of irqs_current changed in state [1] (nsecurity calculation)")
  ovl_irqs_current_ns_change (.clk              (clk_pri),
                              .reset_n          (reset_n),
                              .antecedent_expr  (priority_state_q[0] & ~change_allowed),
                              .consequent_expr  (irqs_current == prev_irqs_current));

  // If there is at least one valid input IRQ when the input is sample in
  // state [0], then an IRQ must have been selected by the end of the
  // iteration.
  reg [NUM_INTS-1:0] irqs_initial;
  always @(posedge clk_pri or negedge reset_n)
    if (!reset_n)
      irqs_initial <= {NUM_INTS{1'b0}};
    else if (priority_state_q[0])
      irqs_initial <= irqs_valid_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"There was at least one valid input IRQ, but none was selected")
  ovl_no_irq_selected        (.clk              (clk_pri),
                              .reset_n          (reset_n),
                              .antecedent_expr  (priority_state_q[0] & ~change_allowed & (|irqs_initial)),
                              .consequent_expr  (current_priority_match));  // high_valid_q is loaded with current_priority_match in state [0]

  // The state machine should always be restarted by and Ack, so on the cycle
  // after it should always be in state[0].
  reg restarted;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      restarted <= 1'b0;
    else
      restarted <= int_ack_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"There was an Ack on the previous cycle, but the state machine is not in state[0]")
  ovl_restart_on_ack         (.clk              (clk_pri),
                              .reset_n          (reset_n),
                              .antecedent_expr  (restarted),
                              .consequent_expr  (priority_state_q[0]));

  // After the state machine is restarted following an Ack, the same CPU
  // interface cannot send another Ack until the state machine has completed
  // another iteration to send it another interrupt. As all priority blocks
  // are reset by any CPUs Ack, there can be up to NUM_CPUS Acks before a new
  // iteration has completed.
  reg recalc_pending;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      recalc_pending <= 1'b0;
    else
      recalc_pending <= restarted | (recalc_pending & ~priority_state_q[0]);

  reg [3:0] acks_seen_since_last_recalc;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      acks_seen_since_last_recalc <= 4'd0;
    else if (int_ack_i)
      acks_seen_since_last_recalc <= acks_seen_since_last_recalc + 4'd1;
    else if (!recalc_pending & !restarted)
      acks_seen_since_last_recalc <= 4'd0;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"There was an Ack when there were already NUM_CPUS Acks outstanding since the last priority calculation")
  ovl_ack_on_max_outstanding (.clk              (clk_pri),
                              .reset_n          (reset_n),
                              .antecedent_expr  (acks_seen_since_last_recalc == NUM_CPUS),
                              .consequent_expr  (~int_ack_i));


  // The high_cpu_q output should be masked when the ID indicated is not an
  // SGI.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"high_cpu_q asserted for non-SGI high_valid_q")
  ovl_high_cpu_non_sgi       (.clk              (clk_pri),
                              .reset_n          (reset_n),
                              .antecedent_expr  (high_valid_o & (high_id_o > 15)),
                              .consequent_expr  (high_cpu_o == 3'b000));

  // The outputs to the CPU interface should never be X when high_valid_q is
  // asserted.
  // - high_priority_q
  assert_never_unknown #(`OVL_FATAL,5,`OVL_ASSERT, "high_priority_o never X when high_valid_o asserted")
  u_ovl_x_high_priority      (.clk       (clk_pri),
                              .reset_n   (reset_n),
                              .qualifier (high_valid_o),
                              .test_expr (high_priority_o));

  // - high_id_q
  assert_never_unknown #(`OVL_FATAL,9,`OVL_ASSERT, "high_id_o never X when high_valid_o asserted")
  u_ovl_x_high_id            (.clk       (clk_pri),
                              .reset_n   (reset_n),
                              .qualifier (high_valid_o),
                              .test_expr (high_id_o));

  // - high_nsecure_q
  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT, "high_nsecure_o never X when high_valid_o asserted")
  u_ovl_x_high_nsecure       (.clk       (clk_pri),
                              .reset_n   (reset_n),
                              .qualifier (high_valid_o),
                              .test_expr (high_nsecure_o));

  // - high_cpu_q (this is only used for SGIs)
  assert_never_unknown #(`OVL_FATAL,3,`OVL_ASSERT, "high_cpu_o never X when high_valid_o asserted")
  u_ovl_x_high_cpu           (.clk       (clk_pri),
                              .reset_n   (reset_n),
                              .qualifier (high_valid_o & (high_id_o < 16)),
                              .test_expr (high_cpu_o));

  // ----------------------
  // Correct behaviour of priority algorithm
  // ----------------------
  reg        ovl_high_valid;
  reg [4:0]  ovl_high_priority;
  reg [NUM_ID_BITS-1:0] ovl_high_id;
  reg        ovl_high_nsecure;
  reg [2:0]  ovl_high_cpu;

  reg        captured_ovl_high_valid;
  reg [4:0]  captured_ovl_high_priority;
  reg [NUM_ID_BITS-1:0] captured_ovl_high_id;
  reg        captured_ovl_high_nsecure;
  reg [2:0]  captured_ovl_high_cpu;

  reg        expected_high_valid;
  reg [4:0]  expected_high_priority;
  reg [NUM_ID_BITS-1:0] expected_high_id;
  reg        expected_high_nsecure;
  reg [2:0]  expected_high_cpu;

  // Checking for SGI CPU inputs
  reg [15:0] captured_sgi_irqs_valid;
  reg [3*16-1:0] ovl_sgis_cpu_mask;
  reg [3*16-1:0] captured_sgis_cpu_mask;


  integer x;

  reg [7:0] priority_state_q_q;
  wire outputs_being_updated_first = priority_state_q_q[1] && priority_state_q[0] && !suppress_high_en_i;

  // Logic to work out highest priority values
  always @*
    begin
      ovl_high_valid = 0;
      ovl_high_priority = 5'h1F;
      ovl_high_id = 0;
      ovl_high_nsecure = 0;
      ovl_high_cpu = 0;
      for (x = NUM_INTS-1; x >= 0; x = x - 1) begin
        if (irqs_valid_i[x] && ((irq_priorities_i[x*5 +: 5] <= ovl_high_priority) || !ovl_high_valid)) begin
          ovl_high_valid    = 1'b1;
          ovl_high_id       = x[0 +: NUM_ID_BITS];
          ovl_high_priority = irq_priorities_i[x*5 +: 5];
          ovl_high_nsecure  = irqs_nsecurity_i[x];
          ovl_high_cpu      = (x<16) ? sgi_cpus_i[x*3 +: 3] : 0;
        end
      end
    end

 // Inputs are conceptually sampled on a priority_state_q[0]
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      captured_ovl_high_valid <= 1'b0;
    else if (int_ack_i)
      captured_ovl_high_valid <= 1'b0;
    else if (priority_state_q[0])
      captured_ovl_high_valid <= ovl_high_valid;

  always @(posedge clk)
    if (priority_state_q[0])
      begin
        captured_ovl_high_priority  <= ovl_high_priority;
        captured_ovl_high_id        <= ovl_high_id;
        captured_ovl_high_nsecure   <= ovl_high_nsecure;
        captured_ovl_high_cpu       <= ovl_high_cpu;
        captured_sgi_irqs_valid     <= irqs_valid_i[15:0];
      end

  // Outputs are driven with the correct priority values on the next priority_state_q[0]
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      expected_high_valid <= 1'b0;
    else if (int_ack_i)
      expected_high_valid <= 1'b0;
    else if (outputs_being_updated_first)
      expected_high_valid <= captured_ovl_high_valid;

  always @(posedge clk)
    if (outputs_being_updated_first)
      begin
        expected_high_priority  <= captured_ovl_high_priority;
        expected_high_id        <= captured_ovl_high_id;
        expected_high_nsecure   <= captured_ovl_high_nsecure;
        expected_high_cpu       <= captured_ovl_high_cpu;
      end

  always @*
    for (x = 0 ; x < 16; x = x+1)
      begin
        ovl_sgis_cpu_mask[x*3 +: 3]      = {3{irqs_valid_i[x]}};
        captured_sgis_cpu_mask[x*3 +: 3] = {3{captured_sgi_irqs_valid[x]}};
      end


  // OVLs aim to check equivalence of cycle-accurate (but easy-to-read) model to optimised RTL

  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Priority block had incorrect valid output bit")
  ovl_high_valid_o  (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr (expected_high_valid == high_valid_o));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Priority block had incorrect priority output for a valid interrupt")
  ovl_high_priority_o    (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (expected_high_valid),
                          .consequent_expr  (expected_high_priority == high_priority_o));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Priority block had incorrect id output for a valid interrupt")
  ovl_high_id_o          (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (expected_high_valid),
                          .consequent_expr  (expected_high_id == high_id_o));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Priority block had incorrect nsecure output for a valid interrupt")
  ovl_high_nsecure_o     (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (expected_high_valid),
                          .consequent_expr  (expected_high_nsecure == high_nsecure_o));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Priority block had incorrect cpu output for a valid SGI")
  ovl_high_cpu_o         (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (expected_high_valid & (expected_high_id < 'h10)),
                          .consequent_expr  (expected_high_cpu == high_cpu_o));

  // Assumption: security of interrupts cannot change before they are used in calculation
  
  assert_unchange #(`OVL_FATAL,NUM_INTS,7,`OVL_RESET_ON_NEW_START,`OVL_ASSERT,
                    "Security bits for an IRQ changed when it might break priority calculation")
  ovl_nsecure_unchange   (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (priority_state_q[0]),
                          .test_expr        (irqs_nsecurity_i));

  // Assumption: security of SGI input CPUs cannot change before they are used in calculation
  
  assert_unchange #(`OVL_FATAL,16*3,7,`OVL_RESET_ON_NEW_START,`OVL_ASSERT,
                    "SGI source CPU number for an interrupt IRQ changed when it might break priority calculation")
  ovl_sgi_cpu_unchange   (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (priority_state_q[0]),
                          .test_expr        (priority_state_q[0] ?
                                             (sgi_cpus_i & ovl_sgis_cpu_mask) :
                                             (sgi_cpus_i & captured_sgis_cpu_mask)));

  // Assumption: priorities cannot change before they are used in calculation
  
  assert_unchange #(`OVL_FATAL,5*NUM_INTS,5,`OVL_RESET_ON_NEW_START,`OVL_ASSERT,
                    "Priority for an interrupt changed when it might break priority calculation")
  ovl_priority_unchange  (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (priority_state_q[0]),
                          .test_expr        (irq_priorities_i));


  always @(posedge clk or negedge reset_n)
      if (!reset_n)
          priority_state_q_q <= 8'd1;
      else
          priority_state_q_q <= priority_state_q;

  reg [NUM_ID_BITS-1:0] high_id_q_q;
  reg [NUM_ID_BITS-1:0] captured_ovl_high_id_q;
  reg [NUM_ID_BITS-1:0] expected_high_id_q;
  always @(posedge clk) begin
      high_id_q_q <= high_id_q;
      captured_ovl_high_id_q <= captured_ovl_high_id;
      expected_high_id_q <= expected_high_id;
  end

  reg outputs_being_updated_first_q;
  always @(posedge clk or negedge reset_n)
      if (!reset_n)
          outputs_being_updated_first_q <= 1'b0;
      else
          outputs_being_updated_first_q <= outputs_being_updated_first;

  // Relationships between model and RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Valid bit is out of step between RTL and model")
  ovl_valid_bit_equivalence (.clk       (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  ((|priority_state_q[7:1] || outputs_being_updated_first)),
                          .consequent_expr  (|irqs_current == captured_ovl_high_valid));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The correct interrupt must be chosen by the RTL for all cycles of the prioritisation")
  ovl_correct_id_remains_chosen (.clk       (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  ((|priority_state_q[7:1] || outputs_being_updated_first) && captured_ovl_high_valid),
                          .consequent_expr  (irqs_current[captured_ovl_high_id]));
  wire [NUM_INTS-1:0] interrupts_with_lower_id = irqs_current & (('d1 << captured_ovl_high_id) - 1'b1);
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"There are other valid interrupts with a lower ID at the end of prioritisation (but should not be)")
  ovl_now_lower_id_after_prioritisation (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  ((|priority_state_q[2:1] || outputs_being_updated_first) && captured_ovl_high_valid),
                          .consequent_expr  (!interrupts_with_lower_id));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The correct ID was not selected finally in priority logic")
  ovl_correct_id_only_chosen_at_end (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  ((priority_state_q[1] || outputs_being_updated_first) && captured_ovl_high_valid),
                          .consequent_expr  (irqs_current == ('d1 << captured_ovl_high_id)));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The ID was not converted from one-hot to binary as expected")
  ovl_id_converted_correctly (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (outputs_being_updated_first && captured_ovl_high_valid),
                          .consequent_expr  (captured_ovl_high_id == current_id));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The ID from the model was not used to update the output when expected")
  ovl_id_updated_at_end_model (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (outputs_being_updated_first_q),
                          .consequent_expr  (captured_ovl_high_id_q == expected_high_id));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The correct ID was not used to update the output when expected")
  ovl_id_updated_at_end (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (outputs_being_updated_first_q),
                          .consequent_expr  (expected_high_id == high_id_o || !high_valid_o));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Updates of the prioritisation ID output should only happen when we expect")
  ovl_id_not_updated_otherwise (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (!outputs_being_updated_first_q),
                          .consequent_expr  (high_id_q_q === high_id_q));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Updates of the model prioritisation ID output should only happen when we expect")
  ovl_id_model_not_updated_otherwise (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (!outputs_being_updated_first_q),
                          .consequent_expr  (expected_high_id_q === expected_high_id));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Model-RTL ID equivance was expected to remain when updates not being performed")
  ovl_id_rtl_remain_equivalent_not_updated (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (!outputs_being_updated_first_q),
                          .consequent_expr  (expected_high_id == high_id_o || !high_valid_o));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"No valid interrupt")
  ovl_no_valid_interrupt (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  ((|priority_state_q[7:1] || outputs_being_updated_first) && !captured_ovl_high_valid),
                          .consequent_expr  (~|irqs_current));




  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: high_en")
  u_ovl_x_high_en (.clk       (clk_pri),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (high_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: int_ack_i")
  u_ovl_x_int_ack_i (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (int_ack_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_state_en_i")
  u_ovl_x_priority_state_en_i (.clk       (clk_pri),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (priority_state_en_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_state_q[0]")
  u_ovl_x_priority_state_q0 (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (priority_state_q[0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_state_q[1]")
  u_ovl_x_priority_state_q1 (.clk       (clk_pri),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (priority_state_q[1]));


`endif

endmodule
