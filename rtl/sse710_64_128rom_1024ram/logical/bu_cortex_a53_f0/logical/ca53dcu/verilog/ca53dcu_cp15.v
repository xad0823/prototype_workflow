//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2015 ARM Limited.
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
// Abstract : Data cache CP15 debug control logic. Also used to control
//            invalidate on reset functionality.
//
// This block contains a state machine used to control lookups into the cache
// arbiter to process data cache debug ops. The state machine also contains
// states for controlling the invalidate on reset functionality.
//
//-----------------------------------------------------------------------------

module ca53dcu_cp15
  (
   input    wire            clk,
   input    wire            reset_n,


   //--------------------------------------------------------------------------
   // LSPipe Interface
   //--------------------------------------------------------------------------

   input   wire             dc_cp15_start_dc3_i,
   input   wire             dc_cp15_op_data_dc3_i,
   input   wire     [13:3]  dc_cp15_addr_dc3_i,
   input   wire     [ 1:0]  dc_cp15_way_dc3_i,

   output  wire             cp15_inv_all_force_miss_o,
   output  wire             dc_inv_all_in_progress_o,
   output  wire             dc_cp15_ack_o,
   output  wire             tag_debug_op_ack_o,
   output  wire             data_debug_op_ack_o,
   output  wire             force_reset_o,


   //--------------------------------------------------------------------------
   // Cache Arbiter Interface
   //--------------------------------------------------------------------------

   input   wire             dc_cp15_ack_m1_i,
   input   wire             cp15_data_has_priority_m0_i,
   input   wire             cp15_tag_has_priority_m0_i,

   output  wire             cp15_tag_req_m0_o,
   output  wire             cp15_data_req_m0_o,
   output  wire             cp15_wr_m0_o,
   output  wire      [3:0]  cp15_way_m0_o,
   output  wire     [13:3]  cp15_addr_m0_o,
   output  wire             cp15_inv_all_req_o,


   //--------------------------------------------------------------------------
   // CCB Interface
   //--------------------------------------------------------------------------

   output  wire             inv_all_tlb_ifu_o,


   //--------------------------------------------------------------------------
   // Governor Interface
   //--------------------------------------------------------------------------

   input   wire             dbgl1rstdisable_rs_i,

   //--------------------------------------------------------------------------
   // MBIST Interface
   //--------------------------------------------------------------------------

   input   wire             mbist_en_i,


   //--------------------------------------------------------------------------
   // RAMs Interface
   //--------------------------------------------------------------------------

   input   wire     [2:0]  dc_size_i

  );


  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  localparam [2:0] ST_IDLE       = 3'b000;
  localparam [2:0] ST_M0         = 3'b001;
  localparam [2:0] ST_M1         = 3'b010;
  localparam [2:0] ST_M2         = 3'b011;
  localparam [2:0] ST_END        = 3'b100;
  localparam [2:0] ST_INV_IDLE   = 3'b110;
  localparam [2:0] ST_INV_INC    = 3'b111;
  localparam [2:0] ST_INV_WAIT   = 3'b101;
  localparam [2:0] ST_X          = 3'bxxx;


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  wire          cp15_en;
  wire          cp15_has_priority;
  wire          inv_all_active;
  reg           inv_all_force_miss;
  wire          inv_all_req;
  wire          inv_all_tag_req;
  reg   [ 2:0]  lookup_state;
  wire          next_inv_all_force_miss;
  reg   [ 2:0]  next_lookup_state;
  wire  [13:3]  next_inv_all_addr;
  reg   [13:3]  inv_all_addr;
  wire          tag_lookup_m0;
  wire          data_lookup_m0;


  //---------------------------------------------------------------------------
  // Lookup State Machine
  //---------------------------------------------------------------------------

  // Register enable for registers which are too small to warrant their own
  // enable (e.g. state machine). Set whenever there is a CP15 operation in
  // progress, or starting.
  assign cp15_en = dc_cp15_start_dc3_i        |
                   (lookup_state != ST_IDLE)  |
                   inv_all_force_miss;

  // CP15 has priority in the cache arbiter
  assign cp15_has_priority = dc_cp15_op_data_dc3_i ? cp15_data_has_priority_m0_i
                                                   : cp15_tag_has_priority_m0_i;

  // Lookup state machine
  always @* begin
    if (mbist_en_i) begin
      // When MBIST is enabled, the state machine returns to idle, to ensure
      // that there will never be a CP15 request when MBIST is in progress
      // and so the MBIST requests do not need factoring into the CP15
      // requests in the cache arbiter.
      next_lookup_state = ST_IDLE;
    end else begin
      case (lookup_state)
        ST_IDLE: begin
          // When there is a CP15 request for a debug operation go to M0.
          next_lookup_state =  dc_cp15_start_dc3_i ? ST_M0
                                                   : ST_IDLE;
        end
        ST_M0: begin
          // A CP15 request will remain stalled in M0 until it takes priority
          // in the cache arbiter.
          next_lookup_state = cp15_has_priority ? ST_M1
                                                : ST_M0;
        end
        ST_M1: begin
          // A CP15 request will remain stalled in M1 until it gets ack from
          // cache arbiter.
          next_lookup_state = dc_cp15_ack_m1_i ? ST_M2 :
                                                 ST_M1;
        end
        ST_M2: begin
          // CP15 requests can never stall in M2 so it always go straight to IDLE.
          next_lookup_state = ST_IDLE;
        end

        // Invalidate all on reset functionality states:
        ST_INV_IDLE: begin
          // The state machine always resets into this state.  Move to idle
          // if debug L1 reset disable is asserted.
          next_lookup_state = dbgl1rstdisable_rs_i ? ST_IDLE : ST_INV_INC;
        end
        ST_INV_INC: begin
          // From this state, the invalidate address register will increment
          // until all lines have been invalidated.
          next_lookup_state = ((inv_all_addr | {~dc_size_i, 8'b00000000}) == 11'h7FF)
                              ? ST_INV_WAIT
                              : ST_INV_INC;
        end
        ST_INV_WAIT: begin
          // Wait for a cycle while the last request is in M1, to suppress any
          // load request from making a request to the cache arbiter on that
          // cycle, ensuring that the invalidate all request cannot be blocked.
          next_lookup_state = ST_IDLE;
        end
        default: next_lookup_state = ST_X;
      endcase
    end
  end

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      lookup_state <= ST_INV_IDLE;
    else if (cp15_en)
      lookup_state <= next_lookup_state;

  // The inv_all_addr address is forced to zero on the first cycle out of reset,
  // then increments during invalidate all on reset.
  assign next_inv_all_addr = {11{inv_all_req}} & (inv_all_addr[13:3] + 11'h001);

  always @(posedge clk)
    if (inv_all_active)
      inv_all_addr <= next_inv_all_addr;

  // Make tag and dirty requests to the cache arbiter.
  assign inv_all_req      = (lookup_state == ST_INV_INC);
  // - invalidate tag RAM when address is aligned to a set address
  assign inv_all_tag_req  = inv_all_req & (inv_all_addr[5:3] == 3'b000);

  assign tag_lookup_m0    = (lookup_state == ST_M0) & ~dc_cp15_op_data_dc3_i;
  assign data_lookup_m0   = (lookup_state == ST_M0) &  dc_cp15_op_data_dc3_i;

  // Outputs to cache arbiter
  assign cp15_data_req_m0_o   = data_lookup_m0 | inv_all_req;
  assign cp15_tag_req_m0_o    = tag_lookup_m0  | inv_all_tag_req;

  // - common between tag and data requests
  assign cp15_wr_m0_o         = inv_all_req;
  assign cp15_way_m0_o        = inv_all_req ? 4'b1111                               // Access all ways for invalidate all on reset
                                            : (4'b0001 << dc_cp15_way_dc3_i);       // or indicated way on debug ops
  assign cp15_addr_m0_o       = (lookup_state == ST_M0) ? dc_cp15_addr_dc3_i[13:3]  // Use lspipe set addr on debug reads
                                                        : inv_all_addr[13:3];       // Set address on invalidate writes


  //---------------------------------------------------------------------------
  // Outputs to other blocks
  //---------------------------------------------------------------------------

  // The cache arbiter and CCB will not accept new transactions when there is an
  // invalidate all in progress, and the lspipe will not make cachearb requests.
  // This means there will always be at least a cycle between the signal being
  // deasserted and a new request being able to make a request to the cache
  // arbiter, so the signal only needs to be asserted when there is an M0 in.
  // progress, as this automatically ensures there can be no conflict in M1.
  assign inv_all_active = &lookup_state[2:1]; // INV_ALL_IDLE, INV_ALL_INC

  assign dc_inv_all_in_progress_o = inv_all_active;

  // Block new CCB requests being accepted when there is an invalidate all
  // request
  assign cp15_inv_all_req_o = inv_all_req | (lookup_state == ST_INV_WAIT);


  //-----------------
  // Load/Store Pipe
  //-----------------

  // Indicate to the lspipe when a debug op is in M2 so it knows to capture the
  // data from the cache arbiter.
  assign dc_cp15_ack_o       = (lookup_state == ST_M2);
  assign tag_debug_op_ack_o  = (lookup_state == ST_M2) & ~dc_cp15_op_data_dc3_i;
  assign data_debug_op_ack_o = (lookup_state == ST_M2) &  dc_cp15_op_data_dc3_i;

  // Cacheable loads do not stall when the invalidate all on reset is in
  // progress. They progress down the pipeline as normal, but do not make
  // a request to the cache arbiter in DC1, and have the CP15 block force
  // the load to miss in DC2. The miss should be asserted whenever there may
  // be an invalidate request in M2.
  assign next_inv_all_force_miss = inv_all_active |               // Covers invalidate all M0s
                                   (lookup_state == ST_INV_WAIT); // Covers last invalidate all M1

  always @(posedge clk)
    if (cp15_en)
      inv_all_force_miss <= next_inv_all_force_miss;

  assign cp15_inv_all_force_miss_o = inv_all_force_miss;

  // Indicate when the core has just been reset - used to synchronously reset
  // flops in other blocks.
  assign force_reset_o = (lookup_state == ST_INV_IDLE);


  //----------
  // DVM
  //----------

  // Indicate when a Dcache invalidate all on reset is starting, so that
  // the DVM block can start the corresponding Icache and TLB invalidate all.
  assign inv_all_tlb_ifu_o = (lookup_state == ST_INV_IDLE) &  // In invalidate all start state
                             ~mbist_en_i;                     // and not in MBIST mode


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //-----------------------------------
  // Invalid State Machine Transitions
  //-----------------------------------

  // Lookup state machine
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_idle         (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_IDLE),
                                    .test_expr   (((lookup_state == ST_IDLE) |
                                                   (lookup_state == ST_M0))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_m0           (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_M0),
                                    .test_expr   (((lookup_state == ST_M0) |
                                                   (lookup_state == ST_M1))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_m1           (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_M1),
                                    .test_expr   ((lookup_state == ST_M1) |
                                                  (lookup_state == ST_M2))); // (MBIST)

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_m2           (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_M2),
                                    .test_expr   (lookup_state == ST_IDLE)); // (MBIST)


  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_inv_idle     (.clk         (clk),
                                    .reset_n     (reset_n),
`ifdef OVL_SVA
                                    .start_event (reset_n & (lookup_state == ST_INV_IDLE)),
`else
                                    .start_event (lookup_state == ST_INV_IDLE),
`endif
                                    .test_expr   (((lookup_state == ST_IDLE) |
                                                   (lookup_state == ST_INV_INC))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_inv_inc      (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_INV_INC),
                                    .test_expr   (((lookup_state == ST_INV_INC) |
                                                   (lookup_state == ST_INV_WAIT) |
                                                   (lookup_state == ST_IDLE)))); // (MBIST)

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state machine state transition")
  u_ovl_lu_transition_inv_wait     (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event (lookup_state == ST_INV_WAIT),
                                    .test_expr   (lookup_state == ST_IDLE));

  //----------
  // X-Checks
  //----------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp15_en")
  u_ovl_x_cp15_en (.clk       (clk),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (cp15_en));

  // Register Enables
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "X-check - inv_all_active")
  u_ovl_x_inv_all_active           (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (1'b1),
                                    .test_expr  (inv_all_active));

  // Outputs to other blocks
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "X-check - cp15_tag_req_m0_o")
  u_ovl_x_cp15_tag_req_m0_o        (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (1'b1),
                                    .test_expr  (cp15_tag_req_m0_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "X-check - cp15_data_req_m0_o")
  u_ovl_x_cp15_data_req_m0_o       (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (1'b1),
                                    .test_expr  (cp15_data_req_m0_o));

  assert_never_unknown #(`OVL_FATAL, 11, `OVL_ASSERT, "X-check - cp15_addr_m0_o")
  u_ovl_x_cp15_addr_m0_o           (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (cp15_tag_req_m0_o | cp15_data_req_m0_o),
                                    .test_expr  (cp15_addr_m0_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "X-check - cp15_way_m0_o")
  u_ovl_x_cp15_way_m0_o            (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (cp15_tag_req_m0_o | cp15_data_req_m0_o),
                                    .test_expr  (cp15_way_m0_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "X-check - cp15_wr_m0_o")
  u_ovl_x_cp15_wr_m0_o             (.clk        (clk),
                                    .reset_n    (reset_n),
                                    .qualifier  (cp15_tag_req_m0_o | cp15_data_req_m0_o),
                                    .test_expr  (cp15_wr_m0_o));

`endif

endmodule // ca53dcu_cp15
