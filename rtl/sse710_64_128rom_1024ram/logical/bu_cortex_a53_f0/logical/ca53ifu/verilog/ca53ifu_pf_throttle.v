//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2013-01-23 14:16:41 +0000 (Wed, 23 Jan 2013) $
//
//      Revision            : $Revision: 234588 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Fetch throttle predictor
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_throttle (
  // Inputs
  input wire        clk,
  input wire        reset_n,
  input wire        DFTSE,
  input wire        throttle_enable_nxt_cyc_i,
  input wire        dpu_iq_full_i,
  input wire        dpu_pfu_force_i,
  input wire  [2:1] ip_if3_i,
  input wire        instr0_brn_i,
  input wire        force_if0_i,
  input wire        force_if1_i,
  input wire        force_if1_pf_i,
  input wire        force_if3_i,
  input wire        pfb_valid_if1_i,
  input wire [12:2] va_if1_i,
  input wire        valid_if2_i,
  input wire        avalid_if3_i,
  input wire        bvalid_if3_i,
  input wire        cvalid_if3_i,
  input wire        next64_if3_i,
  input wire        iutlb_miss_req_i,
  // Outputs
  output wire       throttle_if1_o,
  output wire       ifu_evnt_throttle_o);

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  // Throttle predictor table
  localparam THROTTLE_ENTRIES = 32; // 32-entry per way
  localparam THROTTLE_ENTRY_W = 12; // 12-bits per entry

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [3:0]                     fetch_counter;
  reg [(THROTTLE_ENTRY_W-1):0]  nxt_throttle_predictor_way0;
  reg [(THROTTLE_ENTRY_W-1):0]  nxt_throttle_predictor_way1;
  reg [(THROTTLE_ENTRY_W-1):0]  nxt_throttle_predictor_way2;
  reg [3:0]                     perturb_replace_ctr;
  reg [1:0]                     pseudo_random_2way;
  reg [2:0]                     pseudo_random_3way;
  reg [3:0]                     request_counter;
  reg [4:0]                     target_throttle_addr;
  reg [3:0]                     target_way0_count;
  reg [1:0]                     target_way0_strength_raw;
  reg [5:0]                     target_way0_tag;
  reg                           target_way0_tag_hit_raw;
  reg [3:0]                     target_way1_count;
  reg [1:0]                     target_way1_strength_raw;
  reg [5:0]                     target_way1_tag;
  reg                           target_way1_tag_hit_raw;
  reg [3:0]                     target_way2_count;
  reg [1:0]                     target_way2_strength_raw;
  reg [5:0]                     target_way2_tag;
  reg                           target_way2_tag_hit_raw;
  reg [5:0]                     target_tag;
  reg                           throttle;
  reg                           throttle_cycle_x;
  reg                           throttle_done;
  reg                           throttle_enabled;
  reg [(THROTTLE_ENTRY_W-1):0]  throttle_predictor_way0 [(THROTTLE_ENTRIES-1):0];
  reg [(THROTTLE_ENTRY_W-1):0]  throttle_predictor_way1 [(THROTTLE_ENTRIES-1):0];
  reg [(THROTTLE_ENTRY_W-1):0]  throttle_predictor_way2 [(THROTTLE_ENTRIES-1):0];
  reg                           throttle_valid;
  reg [2:0]                     throttle_way_valid;
  reg [2:0]                     update_priority_strength;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                          clk_throttle_ctl;
  wire                          clk_throttle_way0;
  wire                          clk_throttle_way1;
  wire                          clk_throttle_way2;
  wire                          fetch_counter_missmatch;
  wire                          fetch_counter_en;
  wire                          fetch_counter_saturate;
  wire [4:0]                    lookup_addr_if1;
  wire [3:0]                    lookup_way0_count_if1;
  wire [1:0]                    lookup_way0_strength_if1;
  wire [5:0]                    lookup_way0_tag_if1;
  wire                          lookup_way0_tag_hit_if1;
  wire [3:0]                    lookup_way1_count_if1;
  wire [1:0]                    lookup_way1_strength_if1;
  wire [5:0]                    lookup_way1_tag_if1;
  wire                          lookup_way1_tag_hit_if1;
  wire [3:0]                    lookup_way2_count_if1;
  wire [1:0]                    lookup_way2_strength_if1;
  wire [5:0]                    lookup_way2_tag_if1;
  wire                          lookup_way2_tag_hit_if1;
  wire                          new_allocation;
  wire [3:0]                    new_fetch_count;
  wire [3:0]                    new_request_count;
  wire [3:0]                    new_target_count;
  wire [3:0]                    nxt_fetch_counter;
  wire [3:0]                    nxt_perturb_replace_ctr;
  wire [1:0]                    nxt_pseudo_random_2way;
  wire [2:0]                    nxt_pseudo_random_3way;
  wire [3:0]                    nxt_request_counter;
  wire [5:0]                    nxt_target_tag;
  wire                          nxt_throttle;
  wire                          nxt_throttle_done;
  wire                          nxt_throttle_valid;
  wire [2:0]                    nxt_throttle_way_valid;
  wire                          perturb_replace;
  wire                          reduce_strength;
  wire                          request_counter_en;
  wire                          request_counter_not_two;
  wire                          request_counter_not_zero_one;
  wire [3:0]                    target_count;
  wire                          target_count_is_one;
  wire                          target_count_is_two;
  wire                          target_enable_if1;
  wire [1:0]                    target_strength;
  wire                          target_way0_tag_hit;
  wire                          target_way1_tag_hit;
  wire                          target_way2_tag_hit;
  wire                          throttle_allowed;
  wire                          throttle_en;
  wire [(THROTTLE_ENTRIES-1):0] throttle_predictor_way0_en;
  wire [(THROTTLE_ENTRIES-1):0] throttle_predictor_way1_en;
  wire [(THROTTLE_ENTRIES-1):0] throttle_predictor_way2_en;
  wire                          throttle_trigger;
  wire                          update_priority_hit;
  wire [2:0]                    update_way;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  // All control registers in the predictor can be regionally gated whenever the throttle
  // predictor is not valid
  ca53_cell_inter_clkgate u_inter_clkgate_throttle_ctl (.clk_i         (clk),
                                                        .clk_enable_i  (throttle_valid),
                                                        .clk_senable_i (DFTSE),
                                                        .clk_gated_o   (clk_throttle_ctl));

  // All registers in the predictor table ways can be regionally gated unless an update
  // may occur to them.  The gate won't activate until the first fetch after a force makes
  // it to the IF3 stage and will shut off as soon as the global valid signal is suppressed.
  ca53_cell_inter_clkgate u_inter_clkgate_throttle_way0 (.clk_i         (clk),
                                                         .clk_enable_i  (throttle_way_valid[0]),
                                                         .clk_senable_i (DFTSE),
                                                         .clk_gated_o   (clk_throttle_way0));

  ca53_cell_inter_clkgate u_inter_clkgate_throttle_way1 (.clk_i         (clk),
                                                         .clk_enable_i  (throttle_way_valid[1]),
                                                         .clk_senable_i (DFTSE),
                                                         .clk_gated_o   (clk_throttle_way1));

  ca53_cell_inter_clkgate u_inter_clkgate_throttle_way2 (.clk_i         (clk),
                                                         .clk_enable_i  (throttle_way_valid[2]),
                                                         .clk_senable_i (DFTSE),
                                                         .clk_gated_o   (clk_throttle_way2));

  // ------------------------------------------------------
  // Valid throttle prediction
  // ------------------------------------------------------
  //
  // Set the valid flag when
  //  - We are in the process of making a throttle prediction/allocation due a predicted branch from IF3
  //
  // Clear the valid flag when
  //  - If a request is not allowed
  //  - The fetch counter has saturated
  //  - The DPU has forced the IFU
  //  - The micro-TLB has missed
  assign nxt_throttle_valid = (force_if3_i & ~dpu_pfu_force_i) | (throttle_enabled &
                                                                  throttle_valid  &
                                                                  ~fetch_counter_saturate &
                                                                  ~force_if3_i &
                                                                  ~dpu_pfu_force_i &
                                                                  ~iutlb_miss_req_i);

  assign nxt_throttle_way_valid = {(throttle_valid & request_counter_not_zero_one & (update_priority_hit ? target_way2_tag_hit : update_priority_strength[2])),
                                   (throttle_valid & request_counter_not_zero_one & (update_priority_hit ? target_way1_tag_hit : update_priority_strength[1])),
                                   (throttle_valid & request_counter_not_zero_one & (update_priority_hit ? target_way0_tag_hit : update_priority_strength[0]))};

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      throttle_valid     <= 1'b0;
      throttle_way_valid <= {3{1'b0}};
    end
    else begin
      throttle_valid     <= nxt_throttle_valid;
      throttle_way_valid <= nxt_throttle_way_valid;
    end

  // ------------------------------------------------------
  // IF1 lookup
  // ------------------------------------------------------

  // Create lookup by hashing the history with the address in IF1.  Mask with the force_if1 signal
  // so that we aren't toggling when we don't need to
  assign lookup_addr_if1 = {5{force_if1_pf_i}} & va_if1_i[7:3];

  // Assign the next target tag (include bit [2] to help remove false hits on thumb with tight branches)
  assign nxt_target_tag = {va_if1_i[12:8], va_if1_i[2]};

  // Extract the tag value of the entry that was hit in the throttle predictor
  assign lookup_way0_tag_if1 = throttle_predictor_way0[lookup_addr_if1][5:0];
  assign lookup_way1_tag_if1 = throttle_predictor_way1[lookup_addr_if1][5:0];
  assign lookup_way2_tag_if1 = throttle_predictor_way2[lookup_addr_if1][5:0];

  assign lookup_way0_tag_hit_if1 = lookup_way0_tag_if1 == {va_if1_i[12:8], va_if1_i[2]};
  assign lookup_way1_tag_hit_if1 = lookup_way1_tag_if1 == {va_if1_i[12:8], va_if1_i[2]};
  assign lookup_way2_tag_hit_if1 = lookup_way2_tag_if1 == {va_if1_i[12:8], va_if1_i[2]};

  // Extract the strength level of the entry that was hit in the throttle predictor
  assign lookup_way0_strength_if1 = throttle_predictor_way0[lookup_addr_if1][7:6];
  assign lookup_way1_strength_if1 = throttle_predictor_way1[lookup_addr_if1][7:6];
  assign lookup_way2_strength_if1 = throttle_predictor_way2[lookup_addr_if1][7:6];

  // Extract the target count before the next branch from the entry that was hit in the throttle predictor
  assign lookup_way0_count_if1 = throttle_predictor_way0[lookup_addr_if1][11:8];
  assign lookup_way1_count_if1 = throttle_predictor_way1[lookup_addr_if1][11:8];
  assign lookup_way2_count_if1 = throttle_predictor_way2[lookup_addr_if1][11:8];

  // Randomisation
  assign nxt_pseudo_random_3way = {pseudo_random_3way[1:0], pseudo_random_3way[2]};
  assign nxt_pseudo_random_2way = {pseudo_random_2way[0],   pseudo_random_2way[1]};

  // Replacement perturbation.  This helps add some uncertainty in to replacement and move stale values
  // out of prediction tables.  To avoid falling in to a pattern use a couple of different compare
  // values based on prime numbers and spaced unevenly.
  assign nxt_perturb_replace_ctr[3:0] = perturb_replace_ctr[3:0] + 4'b0001;
  assign perturb_replace = ((perturb_replace_ctr[3:0] == 4'b0101) | // Perturb on count of 5
                            (perturb_replace_ctr[3:0] == 4'b1011)); // Perturb on count of 11

  // ------------------------------------------------------
  // Capture target values
  // ------------------------------------------------------

  // Enable whenever there is a force due to a predicted taken branch in IF3
  assign target_enable_if1 = force_if1_pf_i;

  always @(posedge clk_throttle_ctl or negedge reset_n)
    if (!reset_n) begin
      throttle_enabled          <= 1'b1;
      perturb_replace_ctr       <= 4'b0000;
      pseudo_random_2way        <= 2'b01;
      pseudo_random_3way        <= 3'b001;
      target_tag                <= {6{1'b0}};
      target_throttle_addr      <= {5{1'b0}};
      target_way0_strength_raw  <= {2{1'b0}};
      target_way0_count         <= {4{1'b0}};
      target_way0_tag           <= {6{1'b0}};
      target_way0_tag_hit_raw   <= 1'b0;
      target_way1_strength_raw  <= {2{1'b0}};
      target_way1_count         <= {4{1'b0}};
      target_way1_tag           <= {6{1'b0}};
      target_way1_tag_hit_raw   <= 1'b0;
      target_way2_strength_raw  <= {2{1'b0}};
      target_way2_count         <= {4{1'b0}};
      target_way2_tag           <= {6{1'b0}};
      target_way2_tag_hit_raw   <= 1'b0;
    end
    else if (target_enable_if1) begin
      throttle_enabled          <= throttle_enable_nxt_cyc_i;
      perturb_replace_ctr       <= nxt_perturb_replace_ctr;
      pseudo_random_2way        <= nxt_pseudo_random_2way;
      pseudo_random_3way        <= nxt_pseudo_random_3way;
      target_tag                <= nxt_target_tag;
      target_throttle_addr      <= lookup_addr_if1;
      target_way0_strength_raw  <= lookup_way0_strength_if1;
      target_way0_count         <= lookup_way0_count_if1;
      target_way0_tag           <= lookup_way0_tag_if1;
      target_way0_tag_hit_raw   <= lookup_way0_tag_hit_if1;
      target_way1_strength_raw  <= lookup_way1_strength_if1;
      target_way1_count         <= lookup_way1_count_if1;
      target_way1_tag           <= lookup_way1_tag_if1;
      target_way1_tag_hit_raw   <= lookup_way1_tag_hit_if1;
      target_way2_strength_raw  <= lookup_way2_strength_if1;
      target_way2_count         <= lookup_way2_count_if1;
      target_way2_tag           <= lookup_way2_tag_if1;
      target_way2_tag_hit_raw   <= lookup_way2_tag_hit_if1;
    end

  // Qualify the tag hit signal with whether this is a valid address
  assign target_way0_tag_hit = target_way0_tag_hit_raw & (target_way0_strength_raw != 2'b00);
  assign target_way1_tag_hit = target_way1_tag_hit_raw & (target_way1_strength_raw != 2'b00);
  assign target_way2_tag_hit = target_way2_tag_hit_raw & (target_way2_strength_raw != 2'b00);

  // Qualify the strength with whether we hit the entry or not
  assign target_strength = (({2{target_way0_tag_hit}} & target_way0_strength_raw) |
                            ({2{target_way1_tag_hit}} & target_way1_strength_raw) |
                            ({2{target_way2_tag_hit}} & target_way2_strength_raw));

  // Identify the target count
  assign target_count = (({4{target_way0_tag_hit}} & target_way0_count[3:0]) |
                         ({4{target_way1_tag_hit}} & target_way1_count[3:0]) |
                         ({4{target_way2_tag_hit}} & target_way2_count[3:0]));

  // Target counter compare signals
  assign target_count_is_one = target_count == 4'b0001;
  assign target_count_is_two = target_count == 4'b0010;

  // ------------------------------------------------------
  // Throttle predictor table
  // ------------------------------------------------------

  // Identify which way to update or allocate too with the following priority
  //  - Hit:                  Priorities the way that was hit
  //  - Miss, strength:       Prioritise the way with the lowest stregnth, unless one entry is at 2'b11
  //                          in which case we reduce the strength in all ways instead.
  assign update_priority_hit = target_way2_tag_hit | target_way1_tag_hit | target_way0_tag_hit;

  always @*
    case ({target_way2_strength_raw, target_way1_strength_raw, target_way0_strength_raw})
      6'b00_00_00,
      6'b00_00_01,
      6'b00_00_10,
      6'b00_00_11,
      6'b00_01_00,
      6'b00_01_01,
      6'b00_01_10,
      6'b00_01_11,
      6'b00_10_00,
      6'b00_10_01,
      6'b00_10_10,
      6'b00_10_11,
      6'b00_11_00,
      6'b00_11_01,
      6'b00_11_10,
      6'b00_11_11 : update_priority_strength = 3'b100;
      //
      6'b01_00_00,
      6'b01_00_01,
      6'b01_00_10,
      6'b01_00_11 : update_priority_strength = 3'b010;
      6'b01_01_00 : update_priority_strength = 3'b001;
      6'b01_01_01 : update_priority_strength =                            {pseudo_random_3way[2], pseudo_random_3way[1], pseudo_random_3way[0]};
      6'b01_01_10 : update_priority_strength = perturb_replace ? 3'b001 : {pseudo_random_2way[1], pseudo_random_2way[0], 1'b0                 };
      6'b01_01_11 : update_priority_strength = perturb_replace ? 3'b011 : {pseudo_random_2way[1], pseudo_random_2way[0], 1'b0                 };
      6'b01_10_00 : update_priority_strength = 3'b001;
      6'b01_10_01 : update_priority_strength = perturb_replace ? 3'b010 : {pseudo_random_2way[1], 1'b0,                  pseudo_random_2way[0]};
      6'b01_10_10 : update_priority_strength = perturb_replace ? 3'b100 : {pseudo_random_3way[2], pseudo_random_3way[1], pseudo_random_3way[0]};
      6'b01_10_11 : update_priority_strength = perturb_replace ? 3'b011 : {pseudo_random_2way[1], pseudo_random_2way[0], 1'b0                 };
      6'b01_11_00 : update_priority_strength = 3'b001;
      6'b01_11_01 : update_priority_strength = perturb_replace ? 3'b011 : {pseudo_random_2way[1], 1'b0,                  pseudo_random_2way[0]};
      6'b01_11_10 : update_priority_strength = perturb_replace ? 3'b011 : {pseudo_random_2way[1], 1'b0,                  pseudo_random_2way[0]};
      6'b01_11_11 : update_priority_strength = 3'b011;
      //
      6'b10_00_00,
      6'b10_00_01,
      6'b10_00_10,
      6'b10_00_11 : update_priority_strength = 3'b010;
      6'b10_01_00 : update_priority_strength = 3'b001;
      6'b10_01_01 : update_priority_strength = perturb_replace ? 3'b100 : {1'b0,                  pseudo_random_2way[1], pseudo_random_2way[0]};
      6'b10_01_10 : update_priority_strength = perturb_replace ? 3'b010 : {pseudo_random_3way[2], pseudo_random_3way[1], pseudo_random_3way[0]};
      6'b10_01_11 : update_priority_strength = perturb_replace ? 3'b101 : {pseudo_random_2way[1], pseudo_random_2way[0], 1'b0                 };
      6'b10_10_00 : update_priority_strength = 3'b001;
      6'b10_10_01 : update_priority_strength = perturb_replace ? 3'b001 : {pseudo_random_3way[2], pseudo_random_3way[1], pseudo_random_3way[0]};
      6'b10_10_10 : update_priority_strength =                            {pseudo_random_3way[2], pseudo_random_3way[1], pseudo_random_3way[0]};
      6'b10_10_11 : update_priority_strength = perturb_replace ? 3'b111 : 3'b011;
      6'b10_11_00 : update_priority_strength = 3'b001;
      6'b10_11_01 : update_priority_strength = perturb_replace ? 3'b110 : {pseudo_random_2way[1], 1'b0,                  pseudo_random_2way[0]};
      6'b10_11_10 : update_priority_strength = perturb_replace ? 3'b111 : 3'b011;
      6'b10_11_11 : update_priority_strength = perturb_replace ? 3'b111 : 3'b011;
      //
      6'b11_00_00,
      6'b11_00_01,
      6'b11_00_10,
      6'b11_00_11 : update_priority_strength = 3'b010;
      6'b11_01_00 : update_priority_strength = 3'b001;
      6'b11_01_01 : update_priority_strength = perturb_replace ? 3'b101 : {1'b0,                  pseudo_random_2way[1], pseudo_random_2way[0]};
      6'b11_01_10 : update_priority_strength = perturb_replace ? 3'b101 : {1'b0,                  pseudo_random_2way[1], pseudo_random_2way[0]};
      6'b11_01_11 : update_priority_strength = 3'b101;
      6'b11_10_00 : update_priority_strength = 3'b001;
      6'b11_10_01 : update_priority_strength = perturb_replace ? 3'b110 : {1'b0,                  pseudo_random_2way[1], pseudo_random_2way[0]};
      6'b11_10_10 : update_priority_strength = perturb_replace ? 3'b111 : 3'b101;
      6'b11_10_11 : update_priority_strength = perturb_replace ? 3'b111 : 3'b101;
      6'b11_11_00 : update_priority_strength = 3'b001;
      6'b11_11_01 : update_priority_strength = 3'b110;
      6'b11_11_10 : update_priority_strength = perturb_replace ? 3'b111 : 3'b110;
      6'b11_11_11 : update_priority_strength = 3'b111;
      default     : update_priority_strength = 3'bxxx;
    endcase

  assign update_way = ({3{request_counter_not_zero_one &   // If the request counter isn't above 2 we can't have a fetch in IF3 yet
                          request_counter_not_two}}) &     // or we're hitting in the BTIC.  Either way we don't want to update.
                      (update_priority_hit ? {target_way2_tag_hit, target_way1_tag_hit, target_way0_tag_hit} : update_priority_strength);

  assign reduce_strength = ~update_priority_hit & ((update_priority_strength[2] & update_priority_strength[1]) |
                                                   (update_priority_strength[2] & update_priority_strength[0]) |
                                                   (update_priority_strength[1] & update_priority_strength[0]));

  assign new_allocation = ~update_priority_hit & ((update_priority_strength[2:0] == 3'b100) |
                                                  (update_priority_strength[2:0] == 3'b010) |
                                                  (update_priority_strength[2:0] == 3'b001));

  always @*
    begin
      // Defaults
      nxt_throttle_predictor_way0[11:0] = {12{1'b0}};
      nxt_throttle_predictor_way1[11:0] = {12{1'b0}};
      nxt_throttle_predictor_way2[11:0] = {12{1'b0}};

      if (update_way[0]) begin
        nxt_throttle_predictor_way0[11:8] = reduce_strength ? target_way0_count : new_target_count[3:0];
        nxt_throttle_predictor_way0[5:0]  = reduce_strength ? target_way0_tag   : target_tag;
        case (target_way0_strength_raw)
          // Invalid entry, allocation
          2'b00   : nxt_throttle_predictor_way0[7:6] = {2{~dpu_pfu_force_i}} & 2'b01;
          // Increase strength on entry providing the counter matches
          2'b01   : nxt_throttle_predictor_way0[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b00 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b10);
          // Increase strength on entry providing the counter matches
          2'b10   : nxt_throttle_predictor_way0[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b01 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b11);
          // Maintain full strength while the counter matches (unless we want to reduce strength)
          2'b11   : nxt_throttle_predictor_way0[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength          ? 2'b10 :
                                                                                fetch_counter_missmatch  ? 2'b01 : 2'b11);
          default : nxt_throttle_predictor_way0[7:6] = 2'bxx;
        endcase
      end

      if (update_way[1]) begin
        nxt_throttle_predictor_way1[11:8] = reduce_strength ? target_way1_count : new_target_count[3:0];
        nxt_throttle_predictor_way1[5:0]  = reduce_strength ? target_way1_tag   : target_tag;
        case (target_way1_strength_raw)
          // Invalid entry, allocation
          2'b00   : nxt_throttle_predictor_way1[7:6] = {2{~dpu_pfu_force_i}} & 2'b01;
          // Increase strength on entry providing the counter matches
          2'b01   : nxt_throttle_predictor_way1[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b00 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b10);
          // Increase strength on entry providing the counter matches
          2'b10   : nxt_throttle_predictor_way1[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b01 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b11);
          // Maintain full strength while the counter matches (unless we want to reduce strength)
          2'b11   : nxt_throttle_predictor_way1[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength          ? 2'b10 :
                                                                                fetch_counter_missmatch  ? 2'b01 : 2'b11);
          default : nxt_throttle_predictor_way1[7:6] = 2'bxx;
        endcase
      end

      if (update_way[2]) begin
        nxt_throttle_predictor_way2[11:8] = reduce_strength ? target_way2_count : new_target_count[3:0];
        nxt_throttle_predictor_way2[5:0]  = reduce_strength ? target_way2_tag   : target_tag;
        case (target_way2_strength_raw)
          // Invalid entry, allocation
          2'b00   : nxt_throttle_predictor_way2[7:6] = {2{~dpu_pfu_force_i}} & 2'b01;
          // Increase strength on entry providing the counter matches
          2'b01   : nxt_throttle_predictor_way2[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b00 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b10);
          // Increase strength on entry providing the counter matches
          2'b10   : nxt_throttle_predictor_way2[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength                            ? 2'b01 :
                                                                                (fetch_counter_missmatch | new_allocation) ? 2'b01 : 2'b11);
          // Maintain full strength while the counter matches (unless we want to reduce strength)
          2'b11   : nxt_throttle_predictor_way2[7:6] = {2{~dpu_pfu_force_i}} & (reduce_strength          ? 2'b10 :
                                                                                fetch_counter_missmatch  ? 2'b01 : 2'b11);
          default : nxt_throttle_predictor_way2[7:6] = 2'bxx;
        endcase
      end
    end

  // Throttle prediction table encoding
  //
  // [5:0] Tag
  //   - Assuming a 32-entry table, {va_if1[12:8], va_if1[2]}
  // [7:6] Strength
  //   - 2'b00, Invalid
  //   - 2'b01, New alloc
  //   - 2'b10, Hit once & correct, can throttle
  //   - 2'b11, Hit twice & correct, can throttle, high-confidence
  // [11:8] Count
  //   - 4'b0000, Saturated beyond 15-fetches
  //   - 4'b0001, 1-fetch
  //   - 4'b0010, 2-fetches
  //   ...
  //   - 4'b1111, 15-fetches
  //
  // The target tables are updated on a force_if3 and it should be observed that if the
  // fetch counter saturates or the dpu forces the IFU the throttle_valid signal will be
  // suppressed and no update will occur
  generate for (i = 0; i < THROTTLE_ENTRIES; i = i+1) begin : throttle_predictor_loop

    // Way-0
    assign throttle_predictor_way0_en[i] = (target_throttle_addr == i[4:0]) & update_way[0] & throttle_valid & force_if3_i;

    always @(posedge clk_throttle_way0 or negedge reset_n)
      if (!reset_n)
        throttle_predictor_way0[i] <= {THROTTLE_ENTRY_W{1'b0}};
      else if (throttle_predictor_way0_en[i])
        throttle_predictor_way0[i] <= nxt_throttle_predictor_way0;

    // Way-1
    assign throttle_predictor_way1_en[i] = (target_throttle_addr == i[4:0]) & update_way[1] & throttle_valid & force_if3_i;

    always @(posedge clk_throttle_way1 or negedge reset_n)
      if (!reset_n)
        throttle_predictor_way1[i] <= {THROTTLE_ENTRY_W{1'b0}};
      else if (throttle_predictor_way1_en[i])
        throttle_predictor_way1[i] <= nxt_throttle_predictor_way1;

    // Way-2
    assign throttle_predictor_way2_en[i] = (target_throttle_addr == i[4:0]) & update_way[2] & throttle_valid & force_if3_i;

    always @(posedge clk_throttle_way2 or negedge reset_n)
      if (!reset_n)
        throttle_predictor_way2[i] <= {THROTTLE_ENTRY_W{1'b0}};
      else if (throttle_predictor_way2_en[i])
        throttle_predictor_way2[i] <= nxt_throttle_predictor_way2;
  end
  endgenerate

  // ------------------------------------------------------
  // IF3 Fetch counter
  // ------------------------------------------------------
  //
  // Count the number of fetches processed by the ABuffer after a force to get to a taken branch.
  assign new_fetch_count = ({4{throttle_valid}} & fetch_counter[3:0]) + 4'b0001;

  assign nxt_fetch_counter = force_if0_i ? 4'b0001 : new_fetch_count;

  assign fetch_counter_en  = force_if0_i | (avalid_if3_i & next64_if3_i);

  always @(posedge clk or negedge reset_n) // Note, this can not be regionally gated or it will not clear when saturated
    if (!reset_n)
      fetch_counter <= 4'b0001;
    else if (fetch_counter_en)
      fetch_counter <= nxt_fetch_counter[3:0];

  // Identify fetch counter saturation
  assign fetch_counter_saturate = fetch_counter[3:0] == 4'b1111;

  // ------------------------------------------------------
  // IF3 Request counter
  // ------------------------------------------------------

  // Count the number of fetch requests made to the instruction cache after a force
  assign new_request_count = ({4{throttle_valid}} & request_counter[3:0]) + 4'b0001;

  assign nxt_request_counter = force_if0_i ? 4'b0001 : new_request_count;

  assign request_counter_en  = force_if0_i | pfb_valid_if1_i;

  always @(posedge clk or negedge reset_n) // Note, this can not be regionally gated or it will not clear when saturated
    if (!reset_n)
      request_counter <= 4'b0001;
    else if (request_counter_en)
      request_counter <= nxt_request_counter[3:0];

  // Request counter compare signals
  assign request_counter_not_zero_one = request_counter[3:1] != 3'b000;
  assign request_counter_not_two      = request_counter[3:0] != 4'b0010;

  // ------------------------------------------------------
  // Target count
  // ------------------------------------------------------

  // Generate the target count which is used to update the array and also look for a miss-match.
  // This approach minimises the number of times an extra fetch is needed to fill up the BBuf
  // which is necessary when the branch crosses in to the BBuffer, but the fetch is unwanted if
  // the exit branch is in the ABuf and anything behind can be throttled.
  assign new_target_count = ((~ip_if3_i[2] & ~ip_if3_i[1]) |
                             ((ip_if3_i[2] ^  ip_if3_i[1]) & instr0_brn_i)) ? fetch_counter[3:0] : new_fetch_count;

  // Identify fetch counter missmatch - this can be underflow or overflow.
  assign fetch_counter_missmatch = new_target_count[3:0] != target_count[3:0];

  // ------------------------------------------------------
  // Throttle detection
  // ------------------------------------------------------

  // Allow a throttle only if there are already enough fetches in flight for the FQ or
  // if there is throttle in progress already and the IQ is stalled
  assign throttle_allowed = (target_count_is_one |
                             target_count_is_two |
                             (avalid_if3_i & (bvalid_if3_i | valid_if2_i)) |
                             (avalid_if3_i & throttle_cycle_x & dpu_iq_full_i));

  // Throttle trigger
  assign throttle_trigger = (throttle_enabled &
                             throttle_valid &
                             throttle_allowed &
                             (~throttle_done | (avalid_if3_i & throttle_cycle_x & dpu_iq_full_i)) &
                             ~force_if1_i &
                             ~iutlb_miss_req_i &
                             target_strength[1] &
                             (// Throttle the next cycle if we throttled the last
                              throttle_cycle_x |
                              // If the branch is in the first fetch, throttle immediately
                              target_count_is_one |
                              // If the branch is in the second fetch, throttle immediately
                              target_count_is_two |
                              // If the request count matches the target count and there is
                              // a valid fetch, begin throttling on the next cycle
                              (target_count == request_counter & pfb_valid_if1_i)));

  assign nxt_throttle      = ~force_if0_i & throttle_trigger;

  assign nxt_throttle_done = ~force_if0_i & (throttle_done |                                        // Maintain 'done' once triggered
                                             (throttle_cycle_x & ~(dpu_iq_full_i |                  // Set 'done' unless the IQ is full, or
                                                                   cvalid_if3_i  |                  // the CBuf is valid, or
                                                                   (bvalid_if3_i & valid_if2_i)))); // the BBuf is valid and there is a fetch in flight

  // Throttle enable
  assign throttle_en       = throttle_enabled & target_strength[1];

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      throttle         <= 1'b0;
      throttle_cycle_x <= 1'b0;
      throttle_done    <= 1'b0;
    end
    else if (throttle_en) begin
      throttle         <= nxt_throttle;
      throttle_cycle_x <= nxt_throttle;
      throttle_done    <= nxt_throttle_done;
    end

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign throttle_if1_o      = throttle;
  assign ifu_evnt_throttle_o = throttle_cycle_x;

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: fetch_counter_en")
  u_ovl_x_fetch_counter_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (fetch_counter_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: request_counter_en")
  u_ovl_x_request_counter_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (request_counter_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: target_enable_if1")
  u_ovl_x_target_enable_if1 (.clk       (clk_throttle_ctl),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (target_enable_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: throttle_en")
  u_ovl_x_throttle_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (throttle_en));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Register enable x-check: throttle_predictor_way0_en[i]")
  u_ovl_x_throttle_predictor_way0_eni (.clk       (clk_throttle_way0),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (throttle_predictor_way0_en[31:0]));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Register enable x-check: throttle_predictor_way1_en[i]")
  u_ovl_x_throttle_predictor_way1_eni (.clk       (clk_throttle_way1),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (throttle_predictor_way1_en[31:0]));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Register enable x-check: throttle_predictor_way2_en[i]")
  u_ovl_x_throttle_predictor_way2_eni (.clk       (clk_throttle_way2),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (throttle_predictor_way2_en[31:0]));

  //----------------------------------------------------------------------------
  // Pseudo random 3-way is not one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Pseudo random 3-way is not one-hot")
    ovl_throttle_pseudo_rand_3_one_hot (.clk       (clk),
                                        .reset_n   (reset_n),
                                        .test_expr (pseudo_random_3way[2:0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Pseudo random 2-way is not one-hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "Pseudo random 2-way is not one-hot")
    ovl_throttle_pseudo_rand_2_one_hot (.clk       (clk),
                                        .reset_n   (reset_n),
                                        .test_expr (pseudo_random_2way[1:0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Tag hit should be one-hot or zero
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Tag hit is not one-hot / zero")
    ovl_throttle_tag_hit_one_hot (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ({target_way2_tag_hit, target_way1_tag_hit, target_way0_tag_hit}));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Deafult of case statements should not be hittable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "Default X of nxt_throttle_prdictor_way0 case has been hit")
    ovl_x_nxt_throttle_pred_way0 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (nxt_throttle_predictor_way2[7:6]));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "Default X of nxt_throttle_prdictor_way1 case has been hit")
    ovl_x_nxt_throttle_pred_way1 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (nxt_throttle_predictor_way1[7:6]));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "Default X of nxt_throttle_prdictor_way2 case has been hit")
    ovl_x_nxt_throttle_pred_way2 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (nxt_throttle_predictor_way2[7:6]));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "Default X of update_priority_strength case has been hit")
    ovl_x_update_priority_strength (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (update_priority_strength[2:0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Throttle should never be asserted if there's nothing in-flight in the IFU
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg    ovl_empty_cycle1;
  reg    ovl_empty_cycle2;
  reg    ovl_empty_cycle3;

  // Set the OVL to allow for three cycles with the FQ empty, because there are some cases around aborts which
  // mean that the 'done' signal is not set so quickly as all of the FQ is full
  wire nxt_ovl_empty_cycle1 = ~avalid_if3_i & ~valid_if2_i & ~dpu_iq_full_i & throttle_if1_o;

  always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
      ovl_empty_cycle1 <= 1'b0;
      ovl_empty_cycle2 <= 1'b0;
      ovl_empty_cycle3 <= 1'b0;
    end
    else begin
      ovl_empty_cycle1 <= nxt_ovl_empty_cycle1;
      ovl_empty_cycle2 <= ovl_empty_cycle1;
      ovl_empty_cycle3 <= ovl_empty_cycle2;
    end

  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Throttle while nothing is in flight in the IFU")
    ovl_throttle_assertion (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (ovl_empty_cycle1 & ovl_empty_cycle2 & ovl_empty_cycle3));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Strength progression
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Strength is progressing in an illegal manner")
    ovl_strength_progression (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (// Way 0
                                          ((target_way0_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way0[7:6] == 2'b10)) |
                                          ((target_way0_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way0[7:6] == 2'b11)) |
                                          ((target_way0_strength_raw[1:0] == 2'b01) & (nxt_throttle_predictor_way0[7:6] == 2'b11)) |
                                          // Way 1
                                          ((target_way1_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way1[7:6] == 2'b10)) |
                                          ((target_way1_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way1[7:6] == 2'b11)) |
                                          ((target_way1_strength_raw[1:0] == 2'b01) & (nxt_throttle_predictor_way1[7:6] == 2'b11)) |
                                          // Way 2
                                          ((target_way2_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way2[7:6] == 2'b10)) |
                                          ((target_way2_strength_raw[1:0] == 2'b00) & (nxt_throttle_predictor_way2[7:6] == 2'b11)) |
                                          ((target_way2_strength_raw[1:0] == 2'b01) & (nxt_throttle_predictor_way2[7:6] == 2'b11))));
  // OVL_ASSERT_END

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
