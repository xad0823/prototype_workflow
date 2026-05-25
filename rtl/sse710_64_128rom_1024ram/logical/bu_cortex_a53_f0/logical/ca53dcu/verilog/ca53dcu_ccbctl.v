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
// Abstract : DCU Coherency Control Block (CCB)
//
// Responds to snoop requests from the SCU and accesses the cache arbiter for
// cacheable snoop requests. Also contains the DVM logic for responding to
// DVM snoop requests.
//
//-----------------------------------------------------------------------------

`include "ca53_scu_dcu_defs.v"
`include "ca53dcu_defs.v"
`include "cortexa53params.v"

module ca53dcu_ccbctl `CA53_DCU_PARAM_DECL
  (
   input   wire                             clk,
   input   wire                             reset_n,
   input   wire                             DFTSE,


   //--------------------------------------------------------------------------
   // SCU Interface
   //--------------------------------------------------------------------------

   input   wire                     [40:0]  scu_ac_addr_i,
   input   wire                      [2:0]  scu_ac_id_i,
   input   wire                      [3:0]  scu_ac_l2db_id_i,
   input   wire                      [3:0]  scu_ac_snoop_i,
   input   wire                             scu_ac_valid_i,
   input   wire                      [3:0]  scu_ac_way_i,
   input   wire                      [7:0]  scu_reqbufs_busy_i,

   output  wire                             dcu_ac_ready_o,
   output  wire                             dcu_cr_alloc_o,
   output  wire                             dcu_cr_dirty_o,
   output  wire                      [2:0]  dcu_cr_id_o,
   output  wire                             dcu_cr_migratory_o,
   output  wire                             dcu_cr_age_o,
   output  wire                             dcu_cr_valid_o,

   output  wire                             dcu_dvm_complete_o,


   //--------------------------------------------------------------------------
   // Governor Interface
   //--------------------------------------------------------------------------

   input   wire                             gov_wfx_drain_req_i,
   input   wire                             gov_standbywfe_i,
   input   wire                             gov_standbywfi_i,


   //--------------------------------------------------------------------------
   // BIU Interface
   //--------------------------------------------------------------------------

   input   wire                             biu_ccb_lf_hazard_i,
   input   wire                      [7:0]  biu_lf_in_progress_i,
   input   wire                      [3:0]  biu_pf_in_progress_i,

   output  wire                      [3:0]  dcu_ccb_ways_o,
   output  wire                     [13:6]  dcu_ccb_index_o,
   output  wire                             dcu_ccb_req_active_o,
   output  wire                             dvm_stop_pf_o,
   output  wire                             dcu_drain_stb_lf_o,
   output  wire                             dcu_snoop_dw_active_o,
   output  wire                             dcu_snoop_valid_m2_o,
   output  wire                      [1:0]  dcu_snoop_chunk_m2_o,
   output  wire                      [1:0]  dcu_snoop_rotate_m2_o,
   output  wire                      [3:0]  dcu_snoop_l2db_id_m2_o,
   output  wire                             dcu_snoop_last_m2_o,


   //--------------------------------------------------------------------------
   // Cache arbiter
   //--------------------------------------------------------------------------

   input  wire                       [3:0]  ccb_hit_dirty_m2_i,
   input  wire                              dc_ccb_data_has_priorty_m1_i,
   input  wire                              dc_throttle_snoops_i,

   output wire                              ccb_data_req_m1_o,
   output wire                              ccb_valid_data_req_m1_o,
   output wire                              ccb_tag_req_m1_o,
   output wire                              ccb_dirty_req_m1_o,
   output wire                      [40:6]  ccb_write_addr_m1_o,
   output wire                      [13:6]  ccb_dirty_addr_m1_o,
   output wire                      [13:5]  ccb_data_addr_m1_o,
   output wire                       [3:0]  ccb_write_way_m1_o,
   output wire                       [3:0]  ccb_dirty_way_m1_o,
   output wire                              ccb_ecc_make_inv_o,
   output wire                       [3:0]  ccb_lookup_way_o,
   output wire                      [13:6]  ccb_lookup_addr_o,
   output wire                              ccb_inv_snoop_m2_o,
   output wire                       [1:0]  ccb_tag_moesi_m1_o,
   output wire                       [3:0]  ccb_dirty_wdata_m1_o,
   output wire                              ccb_block_prearb_tag_m1_o,
   output wire                              ccb_dirty_m2_o,
   output wire                              mbist_sel_mb3_o,
   output wire                              mbist_cfg_mb3_o,
   output wire                              mbist_read_en_mb3_o,
   output wire                              mbist_write_en_mb3_o,
   output wire  [(`CA53_DDIRTY_RAM_W-1):0]  mbist_be_mb3_o,
   output wire                       [8:0]  mbist_array_mb3_o,
   output wire                      [10:0]  mbist_addr_mb3_o,


   //--------------------------------------------------------------------------
   // CP15 state machine interface
   //--------------------------------------------------------------------------

   input wire                               cp15_inv_all_req_i,
   input wire                               inv_all_tlb_ifu_i,
   input wire                               force_reset_i,


   //--------------------------------------------------------------------------
   // STB interface
   //--------------------------------------------------------------------------

   input   wire                             stb_defer_ccb_i,
   input   wire                             stb_block_ccb_i,
   input   wire                      [4:0]  stb_slots_valid_i,
   input   wire                      [4:0]  stb_slots_dsb_i,

   output  wire                      [4:0]  dcu_drain_slots_o,
   output  wire                             dcu_ccb_req_valid_o,


   //--------------------------------------------------------------------------
   // LSPipe Interface
   //--------------------------------------------------------------------------

   input   wire                             block_dvm_dc3_i,
   input   wire                             dcu_ongoing_burst_dc1_i,
   input   wire                             dsb_dc1_i,
   input   wire                             dsb_dc2_i,
   input   wire                             dsb_dc3_i,
   input   wire                             next_valid_dc2_i,
   input   wire                             next_valid_dc3_i,
   input   wire                             v_enable_dc1_i,
   input   wire                             v_enable_dc2_i,
   input   wire                             v_enable_dc3_i,
   input   wire                             valid_dc1_i,
   input   wire                             valid_dc2_i,
   input   wire                             valid_dc3_i,

   output  wire                             dcu_dvm_valid_ifu_o,
   output  wire                             dcu_dvm_valid_tlb_o,
   output  wire                             dvm_ns_o,
   output  wire                     [61:0]  dvm_cp_addr_o,
   output  wire                      [4:0]  dvm_tlb_cp_op_o,
   output  wire                      [2:0]  dvm_ifu_cp_op_o,
   output  wire                             dvm_in_progress_o,
   output  wire                             ccb_invalidating_tag_m1_o,
   output  wire                             ccb_throttle_loads_o,
   output  wire                     [34:0]  mbist_ctl_data_mb3_o,


   //--------------------------------------------------------------------------
   // DCU Top-Level Interface
   //--------------------------------------------------------------------------

   output  wire                             ccb_wfx_ready_o,


   //--------------------------------------------------------------------------
   // IFU Interface
   //--------------------------------------------------------------------------

   input   wire                             ifu_cp_ack_i,
   input   wire                             ifu_valid_if2_i,
   input   wire                       [2:0] ifu_outstanding_lfb_i,


   //--------------------------------------------------------------------------
   // TLB Interface
   //--------------------------------------------------------------------------

   input   wire                             tlb_cp_ack_i,
   input   wire                             tlb_pagewalk_invalidated_i,


   //--------------------------------------------------------------------------
   // MBIST Interface
   //--------------------------------------------------------------------------

   input   wire                             mbist_en_i

  );


  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  localparam                         CCB_TIMEOUT_CNT_W  = 2;
  localparam [CCB_TIMEOUT_CNT_W-1:0] CCB_TIMEOUT_CNT    = 2'b11;

  localparam                   [2:0] ST_IDLE            = 3'b000;
  localparam                   [2:0] ST_M1              = 3'b010;
  localparam                   [2:0] ST_M2              = 3'b011;
  localparam                   [2:0] ST_DONE            = 3'b100;
  localparam                   [2:0] ST_DVM_FIRST       = 3'b101;
  localparam                   [2:0] ST_DVM_ALL         = 3'b110;
  localparam                   [2:0] ST_WFX             = 3'b111;
  localparam                   [2:0] ST_X               = 3'bxxx;

  // Data read state machine encoded such that request can be taken from a
  // single bit (to improve timing)
  localparam                   [1:0] D_IDLE             = 2'b00;
  localparam                   [1:0] D_REQ1             = 2'b10;
  localparam                   [1:0] D_REQ2             = 2'b11;
  localparam                   [1:0] D_X                = 2'bxx;


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  wire                           data_req_completing;
  wire                           ac_no_data_transfer;
  reg   [                  1:0]  data_state;
  reg   [                  1:0]  next_data_state;
  reg   [                 40:0]  ac_addr;
  wire                           ac_handshake;
  reg   [                  2:0]  ac_id;
  reg   [                  3:0]  ac_l2db_id;
  wire                           ac_ready;
  reg   [                  3:0]  ac_snoop;
  reg   [                  3:0]  ac_way;
  wire                           block_ccb;
  wire                           ccb_req_valid;
  wire  [                  2:0]  ccb_start_state;
  reg   [                  2:0]  lookup_state;
  wire                           dirty_req_m1;
  wire                           lookup_m1_valid;
  wire                           lookup_m2_valid;
  wire                           tag_write_en;
  wire                           dirty_lookup_req_m1;
  wire                           clk_ccb;
  reg                            clk_ccb_enable;
  reg   [                  2:0]  cr_id;
  reg                            cr_dirty;
  reg                            cr_migratory;
  reg                            cr_valid;
  wire  [                 13:5]  data_addr_m1;
  wire                           data_first_m2;
  wire                           data_m1_valid;
  wire                           data_first_m1;
  reg                            data_m2_valid;
  wire                           defer_ac_ready;
  reg                            cr_invalidating_snoop;
  reg                            dirty_write_moesi_m2;
  wire                           invalidating_snoop_m2;
  reg                            dirty_write_moesi;
  reg                            dirty_write_needed;
  reg                            dirty_write_reqd_m2;
  wire                           dvm_is_done;
  wire                           dvm_valid;
  reg                            early_block_ccb;
  reg   [                  2:0]  next_lookup_state;
  wire                           next_lookup_m1;
  wire                           next_clk_ccb_enable;
  wire                           next_early_block_ccb;
  wire                           next_tag_write_m1_valid;
  wire                           req_outstanding;
  wire  [                  1:0]  next_snoop_chunk_m2;
  reg   [                  1:0]  snoop_chunk_m2;
  reg   [                  3:0]  data_l2db_id_m2;
  wire  [                  1:0]  snoop_rotate_m2;
  wire                           sync_lists_active;
  reg   [                  3:0]  tag_write_way;
  reg                            next_cr_migratory;
  reg                            cr_age;
  reg                            cr_alloc;
  reg                            next_cr_age;
  reg                            next_cr_alloc;
  reg   [                 40:6]  tag_write_addr;
  reg   [                  3:0]  tag_write_addr_lo;
  wire                           tag_write_addr_upper_en;
  wire                           tag_write_addr_lower_en;
  wire  [                 40:6]  next_tag_write_addr_upper;
  reg                            tag_write_m1_valid;
  reg                            tag_write_shared;
  reg                            tag_write_reqd_m2;
  reg                            tag_write_shared_m2;
  wire                           tlb_ifu_inv_all_ongoing;
  wire                           use_wfx;
  wire                           data_req_m1;
  reg                            tag_req_m1;
  wire                           next_tag_req_m1;
  wire                           next_ccb_block_prearb_tag_m1;
  reg                            ccb_block_prearb_tag_m1;
  wire  [CCB_TIMEOUT_CNT_W-1:0]  next_timeout_count;
  reg   [CCB_TIMEOUT_CNT_W-1:0]  timeout_count;
  wire                           timeout_count_en;
  wire                           next_stb_needs_write_channel;
  reg                            stb_needs_write_channel;


  //---------------------------------------------------------------------------
  // Intermediate Clock Gate
  //---------------------------------------------------------------------------
  // The CCB contains an intermediate clock gate which is used to disable the
  // clock to many of the registers (including their local clock gates, if
  // present) in the block. This cannot be used for the registers which
  // capture a new request from the SCU, or for the state machine registers,
  // as the DCU needs to be able to accept a request from idle with no delay,
  // and the enable to the ICG is registered. These registers are therefore
  // clocked off the main DCU clock (which is still gated during WFx), with
  // the rest of the CCB registers using the gated clock. The gated clock is
  // also used by several registers in the DVM block.
  //
  // The clock enable signal is reset to 1 so that the gated clock will pulse
  // on the first clock after reset, which means that synchronously reset
  // flops can still use the gated clock, as can the invalidate TLB/IFU on
  // reset registers in the DVM block.

  assign next_clk_ccb_enable = ((lookup_state != ST_IDLE) &                   // Enable when state machine active
                                (lookup_state != ST_WFX)) |
                               req_outstanding   |                            // When previous request still in progress
                               inv_all_tlb_ifu_i | tlb_ifu_inv_all_ongoing |  // When TLB/IFU invalidate all on reset in progress
                               sync_lists_active |                            // When DVM Sync lists being used
                               scu_ac_valid_i    |                            // When new request driven by SCU
                               mbist_en_i;                                    // During MBIST

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      clk_ccb_enable <= 1'b1;
    else
      clk_ccb_enable <= next_clk_ccb_enable;

  ca53_cell_inter_clkgate u_inter_clkgate_ccb (.clk_i         (clk),
                                               .clk_enable_i  (clk_ccb_enable),
                                               .clk_senable_i (DFTSE),
                                               .clk_gated_o   (clk_ccb));


  //---------------------------------------------------------------------------
  // Snoop/Store arbitration for write channel
  //---------------------------------------------------------------------------
  // By default, CCB data transfers have higher priority than stores in the STB
  // when sending data to the BIU. To ensure stores in the STB continue to make
  // progress, their priority is increased when they are seen to have been held
  // up by a CCB transfer.
  assign next_stb_needs_write_channel = stb_defer_ccb_i &
                                        (stb_needs_write_channel |
                                         (data_state != D_IDLE));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      stb_needs_write_channel <= 1'b0;
    else
      stb_needs_write_channel <= next_stb_needs_write_channel;


  //---------------------------------------------------------------------------
  // AC Interface
  //---------------------------------------------------------------------------
  // New snoop requests are issued by the SCU on the AC channel. The request
  // data is registered on the cycle a new request is accepted, to be used
  // throughout the lookup phase of the request.

  // Indicate when a new request can be accepted by the DCU. Requests can be
  // accepted back to back from the M2 state for the previous lookup.
  assign defer_ac_ready = cp15_inv_all_req_i | inv_all_tlb_ifu_i |
                          tlb_ifu_inv_all_ongoing | dc_throttle_snoops_i |
                          stb_needs_write_channel;

  assign ac_ready = (lookup_state == ST_DVM_FIRST) |
                     (~defer_ac_ready &
                      ((lookup_state == ST_IDLE) |
                       // or when an outstanding request is about to complete:
                       (((lookup_state == ST_M2)  | (lookup_state == ST_DONE)) &
                        ((data_state   == D_IDLE) | ((data_state  == D_REQ2) & dc_ccb_data_has_priorty_m1_i)))));

  assign dcu_ac_ready_o = ac_ready; // Drive the handshake signal to the SCU.

  // Register the AC information whenever a new request is accepted by the
  // DCU, as indicated by a handshake on AC.
  // - Don't overwrite first half data on second half of two-part DVM
  // - Enable during MBIST as AC flops used to pipeline MBIST data
  assign ac_handshake = (ac_ready & scu_ac_valid_i & (lookup_state != ST_DVM_FIRST)) | mbist_en_i;

  always @(posedge clk)
    if (ac_handshake) begin
      ac_addr      <= scu_ac_addr_i;
      ac_snoop     <= scu_ac_snoop_i;
      ac_id        <= scu_ac_id_i;
      ac_l2db_id   <= scu_ac_l2db_id_i;
      ac_way       <= scu_ac_way_i;
    end

  // MBIST control signals are pipelined on the AC interface flops
  assign mbist_sel_mb3_o      = ac_l2db_id[0];

generate if (CPU_CACHE_PROTECTION) begin : g_mbist_ecc
  assign mbist_be_mb3_o       = ac_addr[38:27];
end else begin : g_mbist_no_ecc
  assign mbist_be_mb3_o       = ac_addr[34:27];
end endgenerate

  assign mbist_array_mb3_o    = ac_addr[26:18];
  assign mbist_addr_mb3_o     = ac_addr[16:6];
  assign mbist_cfg_mb3_o      = ac_addr[2];
  assign mbist_read_en_mb3_o  = ac_addr[1];
  assign mbist_write_en_mb3_o = ac_addr[0];

  // - MBIST control data to IFU/TLB
  assign mbist_ctl_data_mb3_o = {ac_l2db_id[0],  // MBIST select
                                 ac_addr[2],     // MBIST config mode
                                 ac_addr[1],     // MBIST read enable
                                 ac_addr[0],     // MBIST write enable
                                 ac_addr[30:27], // MBIST strobes
                                 ac_addr[26:18], // MBIST array
                                 ac_addr[17:6],  // MBIST address
                                 6'b000000};


  //---------------------------------------------------------------------------
  // CCB Hazard Detection
  //---------------------------------------------------------------------------
  // As snoop requests are higher priority in the cache arbiter than STB/BIU
  // requests, if the snoop request hazards against an STB/BIU transaction then
  // the CCB block must suppress its request to allow the hazarded transaction
  // to complete.
  // The following hazards need to be accounted for:
  // - STB Requests: If the STB is writing the tag in response to
  //   a CleanUnique completing then this write needs to happen before
  //   a snoop request to the same address can write the tag, to ensure that
  //   the line ends up in the correct state.
  // - BIU: There are several cases around linefills where once the BIU has
  //   started an operation to an address, it cannot be interrupted by a snoop
  //   request.
  // The STB and BIU hazard signals are too late to factor into the cache
  // arbiter request directly, and so are registered. This means that if
  // there is an STB or BIU hazard, the CCB block will initially make
  // a request, but will subsequently suppress the request until the cycle
  // after the hazard is removed, ensuring that the hazarding STB/BIU
  // transaction completes first.
  // The STB and BIU hazards depend on the address of the snoop request, and so
  // should be ignored when there is no request. This also means that the
  // hazards are only valid on non-DVM snoop requests.
  // If the STB/BIU indicates a hazard after a snoop request has started (i.e.
  // it has left M1), then the snoop request is ordered first and completes
  // without being blocked.
  //
  // Note that if a request hazards and then is throttled by a prearb request in
  // the cache arbiter, the block is extended to allow the prearb request to
  // complete without having to wait for the whole snoop request to drain. This
  // reduces the maximum stall for a prearb request without adversely affecting
  // snoop performance.
  assign next_early_block_ccb = (stb_block_ccb_i | biu_ccb_lf_hazard_i | (early_block_ccb & dc_throttle_snoops_i)) &
                                lookup_m1_valid;

  always @(posedge clk_ccb)
    early_block_ccb <= next_early_block_ccb;

  // The full version of the block signal takes the STB and BIU block signals
  // directly and is used to stop the state machine from advancing.
  assign block_ccb = early_block_ccb | next_early_block_ccb;


  //---------------------------------------------------------------------------
  // Lookup pipeline
  //---------------------------------------------------------------------------
  // For normal snoop requests, the lookup state machine will generate a dirty
  // read transaction (the tag RAM does not need to be read as the duplicate
  // tags in the SCU are guaranteed to be accurate). Any data RAM reads required
  // by the snoop request are dealt with by the data state machine.
  //
  // For DVM requests, the state machine controls the registering of the
  // request information from the SCU, but then separate logic controls the
  // progress of the request.
  //
  // The state machine can process back-to-back requests in certain
  // circumstances, in which case the idle state will be skipped and the
  // state machine will go straight to the starting state for a new request.
  // The starting state depends on the request type, and is calculated here
  // for convenience.
  assign ccb_start_state = // DVM Messages use a dedicated state, but the starting state depends on how many AC
                           // transactions are required to convey the request. The SCU indicates when two
                           // messages are required by setting ACADDR[0].
                           (scu_ac_snoop_i == `CA53_SNOOP_DVM)  ? (scu_ac_addr_i[0] ? ST_DVM_FIRST
                                                                                    : ST_DVM_ALL)
                                                                : ST_M1;

  // The CCB asserts ac_ready when the state machine is idle. This presents
  // a problem for WFx, as the DCU cannot indicate it can accept
  // a transaction when the core is in WFx, as the clock will be stopped and
  // so the new request cannot be accepted. Therefore, when the governor
  // indicates that the core is waiting to go into WFx, the state machine waits
  // for any outstanding snoops to complete, then goes into a special WFx state,
  // from where ac_ready is deasserted.
  // If a snoop request is presented whilst the core is in WFx, the governor
  // sees ac_valid asserted and temporarily enables the clock whilst the snoop
  // request is dealt with. The core remains in WFx in this time, so the state
  // machine must go back to the WFx state after the request has been processed
  // to allow the clock to be turned off again.
  assign use_wfx = gov_wfx_drain_req_i |  // The core wants to go into WFx
                   gov_standbywfe_i  |    // The core is currently in WFE
                   gov_standbywfi_i;      // The core is currently in WFI

  // Detect when a request is still outstanding after the lookup state
  // machine finishes processing it.
  assign req_outstanding = cr_valid | tag_write_m1_valid;

  // Detect when a request does not need to stall on the data state machine
  // (either because it does not need to access the data RAM, or its data
  // requests have been accepted).
  assign data_req_completing = (data_state == D_IDLE) |
                               ((data_state == D_REQ2) & dc_ccb_data_has_priorty_m1_i);

  // Calculate next state
  always @*
    if (mbist_en_i) begin
      // Go to the idle state when in MBIST, so that mbist_en_i does not need
      // factoring into the critical requests to the cache arbiter.
      next_lookup_state = ST_IDLE;
    end else begin
      case (lookup_state)
        ST_IDLE: begin
          case (scu_ac_valid_i)
            1'b1: begin
              // Start processing a new request when it can be accepted
              next_lookup_state = ac_ready ? ccb_start_state : ST_IDLE;
            end
            1'b0: begin
              // If there are no new requests, either remain in idle, or go
              // into WFX when required (only go to wfx when any previous
              // request has completed).
              next_lookup_state = (use_wfx & ~req_outstanding) ? ST_WFX : ST_IDLE;
            end
            default: begin
              next_lookup_state = ST_X;
            end
          endcase
        end
        ST_M1: begin
          // Stall in M1 while blocked
          next_lookup_state = block_ccb ? ST_M1 : ST_M2;
        end
        ST_M2,
        ST_DONE: begin
          // M2 corresponds to the M2 cycle for the dirty RAM read, Done is used
          // when the lookup has completed but the lookup state machine must
          // wait for the data state machine to finish.
          // When no longer need to wait for data state machine can accept a new
          // request back to back by skipping idle.
          case ({data_req_completing, (scu_ac_valid_i & ~defer_ac_ready)})
            2'b00, 2'b01: begin
              // Current request not completing - stall
              next_lookup_state = ST_DONE;
            end
            2'b10: begin
              // Current request completing but no back to back request
              // - Go back to idle
              next_lookup_state = ST_IDLE;
            end
            2'b11: begin
              // Current request completing and accepting back to back request
              next_lookup_state = ccb_start_state;
            end
            default: next_lookup_state = ST_X;
          endcase
        end
        ST_DVM_FIRST: begin
          // Wait for the SCU to drive the second half of the DVM packet.
          next_lookup_state = scu_ac_valid_i ? ST_DVM_ALL : ST_DVM_FIRST;
        end
        ST_DVM_ALL : begin
          // Remain in this state until the DVM command is completed.
          next_lookup_state = dvm_is_done ? ST_IDLE : ST_DVM_ALL;
        end
        ST_WFX: begin
          // Remain in this state with ac_ready deasserted until a snoop
          // request is received, or the DPU indicates that WFX is no longer
          // required.
          next_lookup_state = (scu_ac_valid_i | ~use_wfx) ? ST_IDLE : ST_WFX;
        end
        default: next_lookup_state = ST_X;
      endcase
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      lookup_state <= ST_IDLE;
    else
      lookup_state <= next_lookup_state;


  //----
  // M1
  //----
  // In M1, the dirty lookup request is made to the cache arbiter.
  assign lookup_m1_valid = (lookup_state == ST_M1);

  // The M1 request to the cache arbiter will be made whenever there is a valid
  // M1 request and it is not being blocked.
  assign dirty_lookup_req_m1 = lookup_m1_valid & ~early_block_ccb;


  //----
  // M2
  //----
  // In M2 the dirty lookup result is available from the cache arbiter.
  assign lookup_m2_valid = (lookup_state == ST_M2);

  // Determine whether the tag/dirty RAM needs writing in response to the snoop,
  // and what the response should be
  always @* begin
    // - tag_write_reqd_m2:     A tag write is required
    // - tag_write_shared_m2:   Write to Shared (write to Invalid if not set)
    // - dirty_write_reqd_m2:   A dirty write is required
    // - next_cr_migratory:     For CR response
    // - next_cr_age:           For CR response
    // - next_cr_alloc:         For CR response
    case (ac_snoop)
      `CA53_SNOOP_GETDIRTY: begin
        tag_write_reqd_m2     = 1'b0;                             // Never write tag
        tag_write_shared_m2   = 1'b0;
        dirty_write_reqd_m2   = 1'b0;                             // Never writes dirty
        dirty_write_moesi_m2  = 1'b0;

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_READONCE: begin
        tag_write_reqd_m2     = 1'b0;                             // Never write tag
        tag_write_shared_m2   = 1'b0;
        dirty_write_reqd_m2   = 1'b0;                             // Never writes dirty
        dirty_write_moesi_m2  = 1'b0;

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_READSHARED: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = ~ccb_hit_dirty_m2_i[1];           // - to shared unless migrating
        dirty_write_reqd_m2   = 1'b0;                             // Either migrate or maintain dirty, so never need to write
        dirty_write_moesi_m2  = 1'b0;

        next_cr_migratory     = ccb_hit_dirty_m2_i[1];            // Only ReadShared sets cr_migratory
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_READMAKESHARED: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = 1'b1;                             // - to shared
        dirty_write_reqd_m2   = ccb_hit_dirty_m2_i[1];            // Write dirty if need to clear migratory bit
                                                                  // - clear migratory, maintain dirty (must be set if migratory)
                                                                  //   (migratory may be set by ECC error if CACHE_PROTECTION,
                                                                  //   so preserve dirty bit in that case)
        dirty_write_moesi_m2  = CPU_CACHE_PROTECTION ? ccb_hit_dirty_m2_i[0] : 1'b1;

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_CLEANSHARED: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = 1'b1;                             // - to shared
        dirty_write_reqd_m2   = ccb_hit_dirty_m2_i[0];            // Write dirty to clear dirty bit
        dirty_write_moesi_m2  = 1'b0;                             // - clear migratory and dirty

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_CLEANINVALID: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = 1'b0;                             // - to invalid
        dirty_write_reqd_m2   = 1'b0;                             // Never write dirty
        dirty_write_moesi_m2  = 1'b0;

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_MAKEINVALID: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = 1'b0;                             // - to invalid
        dirty_write_reqd_m2   = 1'b0;                             // Never write dirty
        dirty_write_moesi_m2  = 1'b0;

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      `CA53_SNOOP_MAKECLEANSHARED: begin
        tag_write_reqd_m2     = 1'b1;                             // Always write tag
        tag_write_shared_m2   = 1'b1;                             // - to shared
        dirty_write_reqd_m2   = ccb_hit_dirty_m2_i[0];            // Write dirty to clear dirty bit
        dirty_write_moesi_m2  = 1'b0;                             // - clear migratory and dirty

        next_cr_migratory     = 1'b0;
        next_cr_age           = ccb_hit_dirty_m2_i[2];
        next_cr_alloc         = ccb_hit_dirty_m2_i[3];
      end
      default: begin
        tag_write_reqd_m2     = 1'bx;
        tag_write_shared_m2   = 1'bx;
        dirty_write_reqd_m2   = 1'bx;
        dirty_write_moesi_m2  = 1'bx;

        next_cr_migratory     = 1'bx;
        next_cr_age           = 1'bx;
        next_cr_alloc         = 1'bx;
      end
    endcase
  end


  //----
  // CR
  //----
  // Register M2 data being pipelined to CR

  // It is not possible to determine if there is a valid transaction in CR
  // combinatorially, so pipeline the valid bit from M2.
  always @(posedge clk_ccb or negedge reset_n)
    if (!reset_n)
      cr_valid <= 1'b0;
    else
      cr_valid <= lookup_m2_valid;

  // Pipeline relevant M2 data to CR whenever there is a valid transaction in
  // M2. Some dirty read M2 data is shared with other pipelines after the
  // lookup is complete, so this is pipelined to CR with the other CR data.
  always @(posedge clk_ccb)
    if (lookup_m2_valid) begin
      cr_id           <= ac_id;
      cr_dirty        <= ccb_hit_dirty_m2_i[0]; // cr_dirty always returns whether the line was dirty
      cr_migratory    <= next_cr_migratory;
      cr_age          <= next_cr_age;
      cr_alloc        <= next_cr_alloc;
    end

  assign dcu_cr_valid_o     = cr_valid;
  assign dcu_cr_alloc_o     = cr_alloc;
  assign dcu_cr_dirty_o     = cr_dirty;
  assign dcu_cr_id_o        = cr_id;
  assign dcu_cr_migratory_o = cr_migratory;
  assign dcu_cr_age_o       = cr_age;

  // Indicate to the cachearb when the snoop request in M2 is for an
  // invalidating snoop (including a ReadShared which is migrating the line)
  // - This is used for both dirty and data requests, so must be valid on both
  // - As the data state machine is only active for the M1 requests, this must
  // be registered for use in the M2 of the second request (or for the first
  // request if it stalled). If this register is valid whenever the CR flops are
  // valid it can be used in all cases by the cachearb, so a CR flop is used
  // even though this is not part of the CR response.
  assign invalidating_snoop_m2 = tag_write_reqd_m2 & ~tag_write_shared_m2;

  always @(posedge clk_ccb)
    if (lookup_m2_valid)
      cr_invalidating_snoop <= invalidating_snoop_m2;

  assign ccb_inv_snoop_m2_o = lookup_m2_valid ? invalidating_snoop_m2 : cr_invalidating_snoop;


  //---------------------------------------------------------------------------
  // Tag Write Pipeline
  //---------------------------------------------------------------------------
  // The tag write pipeline sits at the end of the lookup pipeline, parallel
  // with the CR state. The tag write pipeline has one stage, corresponding to
  // the M1 request to the cache arbiter, as the M2 stage of the RAM access is
  // not interesting for writes.

  //-------------------------------
  // Dirty Read M2 -> Tag Write M1
  //-------------------------------

  // Tag Write M1 Valid Flag
  // - This is set by the lookup pipeline when it issues a new tag write to
  // the tag write pipeline, and remains set until the tag write is able to
  // proceed (i.e. when it is not being blocked by a subsequent dirty read M1).
  assign next_tag_write_m1_valid = (lookup_m2_valid & tag_write_reqd_m2) |                    // Set when a tag write is required
                                   (tag_write_m1_valid & lookup_m1_valid & ~early_block_ccb); // Maintain until can write

  always @(posedge clk_ccb or negedge reset_n)
    if (!reset_n)
      tag_write_m1_valid <= 1'b0;
    else
      tag_write_m1_valid <= next_tag_write_m1_valid;

  // The tag write M1 needs the new MOESI state for the dirty RAM, the outer
  // attributes (shared with the CR stage), and the address to use when writing
  // the tag.
  assign tag_write_en = lookup_m2_valid & tag_write_reqd_m2;

  always @(posedge clk_ccb)
    if (tag_write_en) begin
      tag_write_shared      <= tag_write_shared_m2;
      dirty_write_needed    <= dirty_write_reqd_m2;
      dirty_write_moesi     <= dirty_write_moesi_m2;
    end

  // The tag address is shared with the DVM logic where it is reused for storing
  // the data for the second half of a two part DVM message
  assign tag_write_addr_upper_en    = ((lookup_state == ST_DVM_FIRST) & scu_ac_valid_i) | tag_write_en;
  // - Lower 4-bits only used on DVM requests ([5:4] never used)
  assign tag_write_addr_lower_en    =  (lookup_state == ST_DVM_FIRST) & scu_ac_valid_i;

  // - Tag writes use curent snoop address, DVM uses new AC address
  assign next_tag_write_addr_upper  =  (lookup_state == ST_DVM_FIRST) ? scu_ac_addr_i[40:6] : ac_addr[40:6];

  always @(posedge clk_ccb)
    if (tag_write_addr_upper_en)
      tag_write_addr[40:6]    <= next_tag_write_addr_upper[40:6];

  always @(posedge clk_ccb)
    if (tag_write_addr_lower_en)
      tag_write_addr_lo[3:0]  <= scu_ac_addr_i[3:0];

  // The tag way is shared with the data read pipeline M2 stage, so enable
  // whenever a request is completing, even if it does not need to do a tag
  // write.
  always @(posedge clk_ccb)
    if (lookup_m2_valid)
      tag_write_way         <= ac_way;


  //--------------
  // Tag write M1
  //--------------
  // Make tag request for a write
  // - Because requests can be accepted back to back, a tag write which also
  // needs to write the dirty RAM could conflict with the dirty lookup for the
  // next request. To avoid this, the tag write for a previous request is never
  // done on the first cycle of a new request (for simplicity this is always the
  // case, even if the tag write doesn't need to do a dirty write or the new
  // request doesn't need to do a dirty lookup).
  // - This means the tag write request is never made when the lookup state
  // machine is in the M1 state, unless it is being blocked.

  // The request is registered to improve timing into the cache arbiter
  assign next_lookup_m1 = (ac_ready & scu_ac_valid_i & (scu_ac_snoop_i != `CA53_SNOOP_DVM)) |
                          ((lookup_state == ST_M1) & block_ccb);

  assign next_tag_req_m1 = next_tag_write_m1_valid & ~(next_lookup_m1 & ~next_early_block_ccb);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      tag_req_m1 <= 1'b0;
    else
      tag_req_m1 <= next_tag_req_m1;

  assign ccb_tag_req_m1_o     = tag_req_m1;
  assign ccb_tag_moesi_m1_o   = tag_write_shared ? `CA53_MOESI_SHARED : `CA53_MOESI_INVALID;
  assign ccb_write_addr_m1_o  = tag_write_addr[40:6];
  assign ccb_write_way_m1_o   = tag_write_way;


  //---------------------------------------------------------------------------
  // Cache arbiter dirty RAM interface
  //---------------------------------------------------------------------------
  // Dirty request will always be asserted for reads, and for tag writes which
  // also need a dirty write.
  assign dirty_req_m1 = dirty_lookup_req_m1 |
                        (tag_req_m1 & dirty_write_needed);

  assign ccb_dirty_req_m1_o = dirty_req_m1;

  // - Mux between reads and writes on common signals
  assign ccb_dirty_addr_m1_o    = tag_req_m1 ? tag_write_addr[13:6] : ac_addr[13:6];
  assign ccb_dirty_way_m1_o     = tag_req_m1 ? tag_write_way        : ac_way;

  // - Outer attrs need to be preserved, will always be valid on CR when writing
  assign ccb_dirty_wdata_m1_o = {cr_alloc, cr_age, 1'b0, dirty_write_moesi}; // Never write dirty to set migratory


  //---------------------------------------------------------------------------
  // Data read pipeline
  //---------------------------------------------------------------------------
  // The lookup state machine handles most of the control needed for dealing
  // with a snoop request. However, since snoop data requests can be stalled in
  // the cache arbiter but dirty requests cannot, the data requests can get out
  // of step with the main lookup. Therefore data requests are controlled by a
  // separate state machine.

  assign ac_no_data_transfer = (scu_ac_snoop_i == `CA53_SNOOP_DVM)         |
                               (scu_ac_snoop_i == `CA53_SNOOP_GETDIRTY)    |
                               (scu_ac_snoop_i == `CA53_SNOOP_MAKEINVALID) |
                               (scu_ac_snoop_i == `CA53_SNOOP_MAKECLEANSHARED);

  always @*
    case (data_state)
      D_IDLE:
        // Start state machine when accepting new request which needs data transfer
        next_data_state = (scu_ac_valid_i & ac_ready & ~ac_no_data_transfer) ? D_REQ1 : D_IDLE;
      D_REQ1:
        // Stall in Req1 while blocked or request not accepted by cachearb
        next_data_state = (block_ccb | ~dc_ccb_data_has_priorty_m1_i) ? D_REQ1 : D_REQ2;
      D_REQ2:
        // Stall in Req2 while request not accepted by cachearb
        // - can start new request back to back, otherwise go back to idle
        next_data_state = ~dc_ccb_data_has_priorty_m1_i                             ? D_REQ2 :
                          (scu_ac_valid_i & ~defer_ac_ready & ~ac_no_data_transfer) ? D_REQ1 :
                                                                                      D_IDLE;
      default: next_data_state = D_X;
    endcase

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      data_state <= D_IDLE;
    else
      data_state <= next_data_state;


  //----
  // M1
  //----
  // In M1, the first request is made to the cache arbiter. This feeds
  // directly into the RAM enable and so needs to be early in the cycle.

  // The data state machine indicates when a data read M1 is required
  // directly, so a valid M1 transaction can be determined combinatorially.
  // The valid flag for M1 factors in the full, late, hazard signal and so
  // a transaction is only marked as valid if it will not be dropped. Note
  // that only the first request can hazard.
  assign data_m1_valid = (((data_state == D_REQ1) & ~block_ccb) |
                          (data_state == D_REQ2)) &
                         dc_ccb_data_has_priorty_m1_i;

  // The valid signal is too late to send to the cache arbiter, as it factors
  // in the full hazard signal. The request to the cache arbiter is similar,
  // but only looks at the early hazard signal. This means that if there is
  // an STB or BIU hazard, the CCB will make an initial request which is
  // dropped, but this should be sufficiently rare as not to affect overall
  // power efficiency.
  // - The state machine encodings are designed such that the request into the
  // cache arbiter can be taken from a single bit, improving timing.
  assign data_req_m1 = data_state[1] & ~early_block_ccb;

  // The address for the data read is supplied by the SCU. The address will
  // always be half-line aligned, so only bits [13:5] of the snoop request
  // address are passed to the cache arbiter for the data requests. Bits
  // [13:6] will be constant throughout the request, but on the second
  // request bit [5] needs to address the second half-line.
  assign data_addr_m1 = {ac_addr[13:6],
                         ac_addr[5] ^ data_first_m2};  // The second is in M1 when the first is in M2

  // Drive outputs to cache arbiter
  assign ccb_data_req_m1_o        = data_req_m1;
  assign ccb_valid_data_req_m1_o  = data_req_m1 & ~block_ccb; // Indicate when request will not be dropped (used for ECC)
  assign ccb_data_addr_m1_o       = data_addr_m1;
  // - Lookup way and addr are used in M1 and M2, but do not change between
  // those two stages
  assign ccb_lookup_way_o         = ac_way;
  assign ccb_lookup_addr_o        = ac_addr[13:6];

  // Throttle load requests to ensure cache arbiter abitration
  // - Data requests are blocked by load requests, so the CCB block can throttle
  // loads to ensure snoops are not held up indefinitely. To avoid blocking a
  // load when there may be a natual gap in load requests soon anyway, snoop
  // requests count down a number of cycles before throttling loads, to try and
  // fit into a natural gap.
  // - Because the SCU cannot return data to a requestor until both halves have
  // been returned, the timeout value at the end of the first request is carried
  // forward to the second request, to avoid the second half stalling again if
  // the first half has already stalled.
  assign next_timeout_count = ac_handshake      ? CCB_TIMEOUT_CNT           :
                              (~|timeout_count) ? {CCB_TIMEOUT_CNT_W{1'b0}} : // Saturate at 0
                                                  (timeout_count - 1'b1);

  assign timeout_count_en = ac_handshake | (data_state[1] & ~block_ccb & ~dc_ccb_data_has_priorty_m1_i);

  always @(posedge clk)
    if (timeout_count_en)
      timeout_count <= next_timeout_count;

  assign ccb_throttle_loads_o = data_req_m1 & ~dc_ccb_data_has_priorty_m1_i & (~|timeout_count);


  //----------
  // M1 -> M2
  //----------
  // Pipeline the request to M2.
  always @(posedge clk_ccb or negedge reset_n)
    if (!reset_n)
      data_m2_valid <= 1'b0;
    else
      data_m2_valid <= data_m1_valid;

  // The ID needs to be returned in M2, but will not change throughout a burst
  assign data_first_m1 = data_m1_valid & (data_state != D_REQ2);

  always @(posedge clk_ccb)
    if (data_first_m1)
      data_l2db_id_m2 <= ac_l2db_id;

  // Return the bottom bits of the address to the BIU in M2
  assign next_snoop_chunk_m2 = {data_addr_m1[5], ac_addr[4]};

  always @(posedge clk_ccb)
    if (data_m1_valid)
      snoop_chunk_m2 <= next_snoop_chunk_m2;


  //----
  // M2
  //----
  // The M2 valid flag is qualified such that it is only set for requests
  // which are not being dropped.

  // Determine whether the transaction in M2 is the first (of either 1 or
  // 2 transactions).
  assign data_first_m2 = (data_state == D_REQ2); // M2 for first data request when in M1 for Req2

  // Indicate to way to the BIU so it knows how to rotate the data to return to
  // the SCU.
  // - After the state machine has completed for a burst the request address and
  // way are available from the tag write flops.
  assign snoop_rotate_m2 = (data_state == D_REQ2) ? `CA53_ONEH4_TO_BIN(ac_way) : `CA53_ONEH4_TO_BIN(tag_write_way);

  // Early indication to BIU that DCU may write snoop data in the next cycle
  assign dcu_snoop_dw_active_o  = dc_ccb_data_has_priorty_m1_i &
                                  ((data_state == D_REQ1) |
                                   (data_state == D_REQ2));

  assign dcu_snoop_valid_m2_o   = data_m2_valid;
  assign dcu_snoop_l2db_id_m2_o = data_l2db_id_m2;
  assign dcu_snoop_chunk_m2_o   = snoop_chunk_m2;
  assign dcu_snoop_rotate_m2_o  = snoop_rotate_m2;
  assign dcu_snoop_last_m2_o    = ~data_first_m2;


  //---------------------------------------------------------------------------
  // DVM
  //---------------------------------------------------------------------------
  // The CCB block is used to respond to DVM Messages and register the
  // request information, but the requests are processed by a separate unit,
  // as the functionality is distinct from the main D-Cache snoop operations.

  // Indicate to the DVM block when a DVM Message is valid
  assign dvm_valid = (lookup_state == ST_DVM_ALL);

  // Instantiate DVM control block
  ca53dcu_dvm u_dvm (
    /*ARMAUTO*/
    // Inputs
    .clk                        (clk),
    .clk_ccb                    (clk_ccb),
    .reset_n                    (reset_n),
    .dvm_valid_i                (dvm_valid),
    .dvm_addr_first_i           (ac_addr[40:0]),        // First part address uses snoop address flops
    .dvm_addr_second_hi_i       (tag_write_addr[40:6]), // Second part address uses tag write flops
    .dvm_addr_second_lo_i       (tag_write_addr_lo[3:0]),
    .inv_all_tlb_ifu_i          (inv_all_tlb_ifu_i),
    .force_reset_i              (force_reset_i),
    .block_dvm_dc3_i            (block_dvm_dc3_i),
    .valid_dc1_i                (valid_dc1_i),
    .valid_dc2_i                (valid_dc2_i),
    .valid_dc3_i                (valid_dc3_i),
    .dsb_dc1_i                  (dsb_dc1_i),
    .dsb_dc2_i                  (dsb_dc2_i),
    .dsb_dc3_i                  (dsb_dc3_i),
    .next_valid_dc2_i           (next_valid_dc2_i),
    .next_valid_dc3_i           (next_valid_dc3_i),
    .v_enable_dc1_i             (v_enable_dc1_i),
    .v_enable_dc2_i             (v_enable_dc2_i),
    .v_enable_dc3_i             (v_enable_dc3_i),
    .dcu_ongoing_burst_dc1_i    (dcu_ongoing_burst_dc1_i),
    .tlb_cp_ack_i               (tlb_cp_ack_i),
    .tlb_pagewalk_invalidated_i (tlb_pagewalk_invalidated_i),
    .ifu_cp_ack_i               (ifu_cp_ack_i),
    .ifu_valid_if2_i            (ifu_valid_if2_i),
    .ifu_outstanding_lfb_i      (ifu_outstanding_lfb_i[2:0]),
    .stb_slots_valid_i          (stb_slots_valid_i[4:0]),
    .stb_slots_dsb_i            (stb_slots_dsb_i[4:0]),
    .biu_lf_in_progress_i       (biu_lf_in_progress_i[7:0]),
    .biu_pf_in_progress_i       (biu_pf_in_progress_i[3:0]),
    .scu_reqbufs_busy_i         (scu_reqbufs_busy_i[7:0]),
    // Outputs
    .dvm_is_done_o              (dvm_is_done),
    .sync_lists_active_o        (sync_lists_active),
    .tlb_ifu_inv_all_ongoing_o  (tlb_ifu_inv_all_ongoing),
    .dcu_dvm_valid_tlb_o        (dcu_dvm_valid_tlb_o),
    .dcu_dvm_valid_ifu_o        (dcu_dvm_valid_ifu_o),
    .dvm_in_progress_o          (dvm_in_progress_o),
    .dvm_tlb_cp_op_o            (dvm_tlb_cp_op_o[4:0]),
    .dvm_ifu_cp_op_o            (dvm_ifu_cp_op_o[2:0]),
    .dvm_cp_addr_o              (dvm_cp_addr_o[61:0]),
    .dvm_ns_o                   (dvm_ns_o),
    .dcu_drain_slots_o          (dcu_drain_slots_o[4:0]),
    .dvm_stop_pf_o              (dvm_stop_pf_o),
    .dcu_drain_stb_lf_o         (dcu_drain_stb_lf_o),
    .dcu_dvm_complete_o         (dcu_dvm_complete_o)
  );  // u_dvm


  //---------------------------------------------------------------------------
  // Interfaces to other blocks
  //---------------------------------------------------------------------------
  // The STB needs to know when there is a valid snoop request being
  // processed, so it can check for hazards.
  assign ccb_req_valid = lookup_m1_valid | lookup_m2_valid;

  assign dcu_ccb_req_valid_o = ccb_req_valid;

  // Indicate to the cache arbiter when there is a dirty lookup in M2 and when
  // the current snoop is a MakeInvalid for ECC (used for calculating ECC errors)
  assign ccb_dirty_m2_o     = lookup_m2_valid;
  assign ccb_ecc_make_inv_o = (ac_snoop == `CA53_SNOOP_MAKEINVALID) & ac_addr[0];

  // Indicate to BIU when a snoop request is active in order to enable the
  // snoop data interface with the BIU. In the case of a linefill that has
  // all of its data, but has not been fully allocated and its address matches
  // this signal is low until lf_hazard disappears.
  assign dcu_ccb_req_active_o = (lookup_m1_valid & ~early_block_ccb) | lookup_m2_valid;

  // Send the set/way to the BIU and STB to hazard against. This should always
  // be the address for the latest transaction currently being processed, not
  // any previous request which is still transferring data or writing the
  // cache. This is because the cache write is guaranteed to happen before
  // anyone else can read the tag, so as soon as the CCB finishes processing
  // the request the external world is guaranteed to see the new state of the
  // line, even if it isn't written straight away. So the hazard can be removed
  // at that point.
  assign dcu_ccb_ways_o   = ac_way;
  assign dcu_ccb_index_o  = ac_addr[13:6];

  // To prevent an STB tag lookup from seeing the old value for a line which is
  // about to be written by a snoop request, the CCB block forces the cachearb
  // to block prearb tag requests in M1 after the point at which an STB slot
  // would see an eviciton hazard against a snoop request, until the tag is
  // written. The STB can only detect hazards against snoop requests when the
  // request lookup is active (i.e. the lookup state machine is in M1/M2), and
  // when the STB request is in M2. This means an STB request in M1 before or on
  // the cycle a snoop lookup is in M1 will correctly see a hazard, however an
  // STB request after the lookup M1 and before the tag write must be hazarded.
  // This means prearb tag requests must be blocked when in the lookup M2 stage,
  // or when there is a valid tag write pending.

  // - To improve timing this is registered
  assign next_ccb_block_prearb_tag_m1 = next_tag_write_m1_valid |
                                        ((next_lookup_state == ST_M2) & ~next_early_block_ccb);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ccb_block_prearb_tag_m1 <= 1'b0;
    else
      ccb_block_prearb_tag_m1 <= next_ccb_block_prearb_tag_m1;

  assign ccb_block_prearb_tag_m1_o = ccb_block_prearb_tag_m1;

  // Indicate to the load/store pipe when invalidating the tag RAM for an
  // address
  assign ccb_invalidating_tag_m1_o = tag_req_m1 & ~tag_write_shared;

  // Indicate to the DCU top level that the CCB is ready to enter WFx.
  // - When the core indicates WFx is required, the CCB state machine goes
  // into the WFX state, which suppresses ac_ready. This means that if
  // a snoop request is received whilst in WFx when the clock has been
  // disabled, the request is not accepted until the clock is reactivated and
  // the state machine returns to idle (the governor sees when scu_ac_valid is
  // asserted during WFx, and handles reactivating the clock).
  assign ccb_wfx_ready_o = (lookup_state == ST_WFX) &
                           ~tlb_ifu_inv_all_ongoing &
                           ~sync_lists_active;


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //-------------------
  // Cache arbiter QoS
  //-------------------

  // The throttle_loads logic means that load requests should not be able to
  // block snoop requests for more than a fixed number of cycles. Since loads
  // are throttled after the request timeout reaches zero, the maximum number of
  // cycles a request can be stalled for is 1 cycle longer than that (there
  // should never be a load request after throttle_load is asserted).
  // - Note that since the second data request inherits the timeout value from
  // the first request, the same proprty applies to pair of data requests
  // comprising a snoop request.

  // - When a load request is throttled the CCB block should have priority on the
  // next cycle
  reg ovl_load_throttled;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_load_throttled <= 1'b0;
    else
      ovl_load_throttled <= ccb_throttle_loads_o;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Load request blocking CCB data when throttled")
  u_ovl_load_throttle_req  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_load_throttled),
                            .consequent_expr (dc_ccb_data_has_priorty_m1_i));

  reg [3:0] ovl_data_req_stall_count;
  reg [3:0] ovl_both_data_req_stall_count;

  wire ovl_data_req_not_dropped = ccb_data_req_m1_o & ~(stb_block_ccb_i | biu_ccb_lf_hazard_i);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_data_req_stall_count      <= {4{1'b0}};
      ovl_both_data_req_stall_count <= {4{1'b0}};
    end else begin
      ovl_data_req_stall_count      <= (ovl_data_req_not_dropped & ~dc_ccb_data_has_priorty_m1_i) ? (ovl_data_req_stall_count + 1'b1) : {4{1'b0}};
      ovl_both_data_req_stall_count <= ac_handshake                                               ? {4{1'b0}}                               :
                                       (ovl_data_req_not_dropped & ~dc_ccb_data_has_priorty_m1_i) ? (ovl_both_data_req_stall_count + 1'b1)  :
                                                                                                    ovl_both_data_req_stall_count;
    end

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "CCB data request stalled longer than theoretical maximum")
  u_ovl_ccb_data_req_stall_max     (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_data_req_stall_count <= (CCB_TIMEOUT_CNT + 1)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Total CCB data request stall (over both requests) longer than theoretical maximum")
  u_ovl_ccb_data_reqboth__stall_max(.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_data_req_stall_count <= (CCB_TIMEOUT_CNT + 1)));

  // Snoop requests being throttled by prearb requests in the cache arbiter
  // should not cause ac_ready to be deasserted indefinitely. AC ready can be
  // throttled by up to 2 cycles, because although prearb requests will always
  // be granted immediately when the snoop requests are removed (because loads
  // are also blocked when snoops are), on the first cycle ac_ready is throttled
  // the tag/dirty write for a previous snoop could still be active.
  wire ovl_could_assert_ac_ready = (lookup_state == ST_DVM_FIRST) |
                                   (~(cp15_inv_all_req_i | inv_all_tlb_ifu_i | tlb_ifu_inv_all_ongoing) &
                                    ((lookup_state == ST_IDLE) |
                                     // or when an outstanding request is about to complete:
                                     (((lookup_state == ST_M2)  | (lookup_state == ST_DONE)) &
                                      ((data_state   == D_IDLE) | ((data_state  == D_REQ2) & dc_ccb_data_has_priorty_m1_i)))));

  reg [3:0] ovl_ac_ready_stall_count;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_ac_ready_stall_count <= {4{1'b0}};
    else
      ovl_ac_ready_stall_count <= (ovl_could_assert_ac_ready & dc_throttle_snoops_i) ? (ovl_ac_ready_stall_count + 1'b1) : {4{1'b0}};

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "ac_ready throttled for longer than theoretical maximum")
  u_ovl_ac_ready_stall_max         (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_ac_ready_stall_count <= 2));


  //----------------
  // CCB Properties
  //----------------

  // early_block should only be updated when there is a valid
  // transaction, and so should never be asserted on the first cycle of
  // a transaction.
  reg ovl_first_cycle_of_req;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_first_cycle_of_req <= 1'b0;
    else
      ovl_first_cycle_of_req <= ac_handshake; // New request starts on the cycle after is accepted from AC

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "early_block should never be asserted on the first cycle of a request")
  u_ovl_early_block_update      (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (ovl_first_cycle_of_req),
                                 .consequent_expr (~early_block_ccb));

  // next_lookup_m1 should be equivalent to (next_lookup_state == ST_M1)
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "next_lookup_m1 not equivalent to next_lookup_state == ST_M1")
  u_ovl_next_lookup_m1_valid       (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (next_lookup_m1 == (next_lookup_state == ST_M1)));


  //---------------------
  // Non-reset Registers
  //---------------------
  // Registers which do not have asynchronous resets should never be X when
  // their outputs are used.

  // ac_snoop
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac_snoop never x when used")
  u_ovl_x_ac_snoop     (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  ((lookup_state != ST_IDLE) & (lookup_state != ST_WFX)),
                        .test_expr  (ac_snoop));

  // ac_addr
  assert_never_unknown #(`OVL_FATAL, 41, `OVL_ASSERT, "ac_addr never x when used")
  u_ovl_x_ac_addr      (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  ((lookup_state != ST_IDLE) & (lookup_state != ST_WFX)),
                        .test_expr  (ac_addr));

  // ac_id
  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "ac_id never x when used")
  u_ovl_x_ac_id        (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  ((lookup_state != ST_IDLE) & (lookup_state != ST_WFX) &
                                     (lookup_state != ST_DVM_FIRST) & (lookup_state != ST_DVM_ALL)),
                        .test_expr  (ac_id));

  // ac_way
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac_way never x when used")
  u_ovl_x_ac_way       (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  ((lookup_state != ST_IDLE) & (lookup_state != ST_WFX) &
                                     (lookup_state != ST_DVM_FIRST) & (lookup_state != ST_DVM_ALL)),
                        .test_expr  (ac_way));

  // early_block_ccb
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "early_block_ccb never x when used")
  u_ovl_x_early_block  (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  (ccb_req_valid),
                        .test_expr  (early_block_ccb));

  // tag_write_way
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "tag_write_way never x when used")
  u_ovl_x_tag_write_way  (.clk        (clk),
                          .reset_n    (reset_n),
                          .qualifier  (tag_write_m1_valid),
                          .test_expr  (tag_write_way));

  // dirty_write_moesi
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dirty_write_moesi never x when used")
  u_ovl_x_dirty_moesi  (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  (dirty_req_m1 & tag_req_m1),
                        .test_expr  (dirty_write_moesi));

  // tag_write_addr
  reg ovl_dvm_is_two_part;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_dvm_is_two_part <= 1'b0;
    else
      ovl_dvm_is_two_part <= (scu_ac_valid_i ? (next_lookup_state == ST_DVM_FIRST) : ovl_dvm_is_two_part);

  assert_never_unknown #(`OVL_FATAL, 35, `OVL_ASSERT, "tag_write_addr_upper never x when used")
  u_ovl_x_tag_wr_addr_hi (.clk        (clk),
                          .reset_n    (reset_n),
                          .qualifier  (tag_write_m1_valid | ((lookup_state == ST_DVM_ALL) & ovl_dvm_is_two_part)),
                          .test_expr  (tag_write_addr[40:6]));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "tag_write_addr_lower never x when used")
  u_ovl_x_tag_wr_addr_lo (.clk        (clk),
                          .reset_n    (reset_n),
                          .qualifier  ((lookup_state == ST_DVM_ALL) & ovl_dvm_is_two_part),
                          .test_expr  (tag_write_addr_lo[3:0]));

  // tag_write_shared
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tag_write_shared never x when used")
  u_ovl_x_tag_wr_moesi (.clk        (clk),
                        .reset_n    (reset_n),
                        .qualifier  (tag_write_m1_valid),
                        .test_expr  (tag_write_shared));


  //---------------------------
  // State machine transitions
  //---------------------------
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_idle_transition (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lookup_state == ST_IDLE),
                             .test_expr   ((lookup_state == ST_IDLE)      |
                                           (lookup_state == ST_M1)        |
                                           (lookup_state == ST_WFX)       |
                                           (lookup_state == ST_DVM_FIRST) |
                                           (lookup_state == ST_DVM_ALL)) );


  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_m1_transition   (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lookup_state == ST_M1),
                             .test_expr   ((lookup_state == ST_M1)    |
                                           (lookup_state == ST_M2)) );

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_m2_transition   (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lookup_state == ST_M2),
                             .test_expr   ((lookup_state == ST_IDLE)      |
                                           (lookup_state == ST_M1)        |
                                           (lookup_state == ST_DONE)      |
                                           (lookup_state == ST_DVM_FIRST) |
                                           (lookup_state == ST_DVM_ALL)) );

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_done_transition (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (lookup_state == ST_DONE),
                             .test_expr   ((lookup_state == ST_IDLE)      |
                                           (lookup_state == ST_M1)        |
                                           (lookup_state == ST_DONE)      |
                                           (lookup_state == ST_DVM_FIRST) |
                                           (lookup_state == ST_DVM_ALL)) );

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_wfx_transition      (.clk         (clk),
                                 .reset_n     (reset_n),
                                 .start_event (lookup_state == ST_WFX),
                                 .test_expr   ((lookup_state == ST_WFX) |
                                               (lookup_state == ST_IDLE)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_dvm_first_transition (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (lookup_state == ST_DVM_FIRST),
                                  .test_expr   ((lookup_state == ST_DVM_ALL) |
                                                (lookup_state == ST_DVM_FIRST) |
                                                (lookup_state == ST_IDLE)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid lookup state transition")
  u_ovl_ccb_dvm_all_transition (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (lookup_state == ST_DVM_ALL),
                                .test_expr   ((lookup_state == ST_DVM_ALL) |
                                              (lookup_state == ST_IDLE)) );

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "lookup_state has reached an illegal state")
  u_ovl_lookup_state_illegal_state (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr ((lookup_state == ST_IDLE)      |
                                                (lookup_state == ST_M1)        |
                                                (lookup_state == ST_M2)        |
                                                (lookup_state == ST_DONE)      |
                                                (lookup_state == ST_DVM_FIRST) |
                                                (lookup_state == ST_DVM_ALL)   |
                                                (lookup_state == ST_WFX)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid data state transition")
  u_ovl_data_idle_transition   (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (data_state == D_IDLE),
                                .test_expr   ((data_state == D_IDLE) |
                                              (data_state == D_REQ1)) );

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid data state transition")
  u_ovl_data_req1_transition   (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (data_state == D_REQ1),
                                .test_expr   ((data_state == D_REQ1) |
                                              (data_state == D_REQ2)) );

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid data state transition")
  u_ovl_data_req2_transition   (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (data_state == D_REQ2),
                                .test_expr   ((data_state == D_REQ1) |
                                              (data_state == D_REQ2) |
                                              (data_state == D_IDLE)) );

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "data_state has reached an illegal state")
  u_ovl_data_state_illegal_state (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ((data_state == D_IDLE) |
                                              (data_state == D_REQ1) |
                                              (data_state == D_REQ2)) );


  //-----------------
  // One hot signals
  //-----------------
  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "Way onehot when reading data")
  u_ovl_data_way_onehot (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr ({4{data_req_m1}} & ac_way));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "Way onehot when writing tag")
  u_ovl_tag_wr_way_onehot (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr ({4{ccb_tag_req_m1_o}} & tag_write_way));


  //-----------------------------------------------
  // X-Check on signals used in if/case statements
  //-----------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_first_m1")
  u_ovl_x_data_first_m1 (.clk       (clk_ccb),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (data_first_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_m1_valid")
  u_ovl_x_data_m1_valid (.clk       (clk_ccb),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (data_m1_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_write_addr_lower_en")
  u_ovl_x_tag_write_addr_lower_en (.clk       (clk_ccb),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (tag_write_addr_lower_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_write_addr_upper_en")
  u_ovl_x_tag_write_addr_upper_en (.clk       (clk_ccb),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (tag_write_addr_upper_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_write_en")
  u_ovl_x_tag_write_en (.clk       (clk_ccb),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (tag_write_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: timeout_count_en")
  u_ovl_x_timeout_count_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (timeout_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ac_handshake never x")
  u_ovl_x_ac_handshake        (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (ac_handshake));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "lookup_state never x")
  u_ovl_x_lookup_state        (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (lookup_state));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_m2_valid never x")
  u_ovl_x_ccb_m2_valid   (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (lookup_m2_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "data_m2_valid never x")
  u_ovl_x_data_m2_valid (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (data_m2_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "data_first_m2 never x")
  u_ovl_x_data_first_m2       (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (data_first_m2));

`endif

endmodule // ca53dcu_ccbctl

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dcu_defs.v"
`include "ca53_scu_dcu_defs.v"
`undef CA53_UNDEFINE
/*END*/
