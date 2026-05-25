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

//------------------------------------------------------------------------------
// Cortex-A53 LFB control entry.
//
//   This controls one of the LFB entries that can be in flight.  It:
//
//     - stores the state associated with an LFB entry;
//     - contains hit logic;
//     - contains cache RAM allocation request logic.
//------------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_lfb_ctl #(parameter [1:0] LFB_ID = 2'b00)
(
  // Clocks and resets
  input wire          clk,
  input wire          reset_n,

  // Entry activation (if3)
  input wire          activate_i,
  input wire [14:1]   activate_va_i,
  input wire [39:4]   activate_pa_i,
  input wire          activate_curr_cacheable_i, // Current cacheable status for this request
  input wire          activate_init_cacheable_i, // Initial cacheable status for this request
  input wire          activate_speculative_i,
  input wire [1:0]    activate_way_i,

  // PFB interface
  input wire [2:0]    ic_size_i,
  input wire [14:4]   pfb_va_if2_i,
  input wire [39:12]  pfb_pa_if2_i,
  input wire [7:0]    pfb_attributes_if2_i,
  input wire          pfb_ns_dsc_if2_i,
  input wire [1:0]    pfb_state_if2_i,
  input wire          pfb_kill_if2_i,
  input wire          pfb_utlb_hit_if2_i,
  input wire          pfb_force_if1_i,
  input wire          pfb_in_debug_or_wfx_i,
  input wire          pfb_context_sync_i,
  input wire          ctl_cache_on_if2_i,
  input wire          ctl_hit_f_if3_i,

  // BIU interface
  input wire          biu_rvalid_i,
  input wire [1:0]    biu_rid_i,
  input wire [1:0]    biu_rchunk_i,
  input wire [2:0]    biu_rresp_i,
  input wire          ifu_rready_i,
  input wire          ifu_arvalid_i,
  input wire [1:0]    ifu_arid_i,
  input wire [1:0]    ifu_arlen_i,
  input wire          biu_arready_i,

  // PD1 stage
  input wire [1:0]    rchunk_pd1_i,

  // Entry status
  output wire         active_o,
  output wire [14:6]  va_o,
  output wire [39:12] pa_o,
  output wire         cacheable_o,
  output wire [1:0]   state_o,
  output wire         ns_o,
  output wire         any_pp_o,
  output wire [1:0]   way_o,
  output wire [7:0]   pd_o,

  // LFB lookup
  input wire          lookup_i,
  input wire          lookup_first_i,
  output wire         hit_raw_o,
  output wire         hit_past_o,
  output wire         hit_pres_o,
  output wire         hit_fut_o,
  output wire         hit_ppf_o,
  output wire [2:0]   hit_resp_o,
  output wire [1:0]   va_hazard_o,
  output wire         lfb_done_o,

  // Stalls
  input wire          ctl_stall_pfb_i,
  input wire          ctl_stall_lfb_pd0_i,
  input wire          ctl_stall_lfb_if0_i,
  input wire          ctl_stall_if3_i,

  // CP15
  input wire          cp15_active_i,
  input wire [1:0]    cp15_hazard_ack_i,
  input wire [11:6]   cp15_addr_i,

  // Cache allocation and pre-decode
  output wire         lfb_match_pd0_o,       // This entry matches data in pd0
  output wire         lfb_match_pd1_o,       // This entry matches data in pd1
  output wire         lfb_hittable_pd1_o,    // This entry matches data in pd1 and will hit
  output wire         lfb_biu_outstanding_o, // Handshake with BIU active
  input wire          ctl_lfb_alloc_i        // Written to cache
);

  //----------------------------------------------------------------------------
  // Module interface notes:
  //
  //   pd_o[7:0]
  //
  //     This is the LFB entry state that is provided to the pre-decoder.  The
  //     bits forming this bus are defined as follows:
  //
  //         [0]  Enable.  Set when the LFB entry is allocated (address
  //              handshake issued.)  Cleared the cycle after the last data has
  //              arrived, or when the entry is abandoned.
  //
  //       [2:1]  PC offset (VA bits[2:1])
  //
  //       [5:3]  Fetch line (VA bits[2:1])
  //
  //       [7:6]  Architectural state
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Constants
  //----------------------------------------------------------------------------

  localparam integer BIU_CHUNKS = 4;

  localparam [1:0] PPF_FUT = 2'b00;   // Future:  beat not yet received
  localparam [1:0] PPF_PRE = 2'b01;   // Present: beat is currently buffered
  localparam [1:0] PPF_PAS = 2'b11;   // Past:    beat is in the cache
  localparam [1:0] PPF_NA  = 2'b10;   // N/A:     beat is to be ignored


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Entry status
  reg        active;         // Entry is active
  wire       active_clr;
  wire       active_we;
  reg        abandoned;      // Entry is abandoned
  wire [2:0] can_abandon;
  wire       set_abandoned;
  wire       abandoned_we;
  wire       nxt_abandoned;
  reg        speculative;    // Speculative entry
  reg        pfb_first_q;
  wire       pfb_first_if2;
  wire       pfb_first_valid;
  wire       set_pfb_first_seen;
  wire       clr_pfb_first_seen;
  reg        pfb_first_seen_q;
  wire       pfb_first_seen_we;
  wire       nxt_pfb_first_seen;
  wire       pfb_first_seen;

  // Entry transaction state
  reg [14:6] va;             // Virtual address [14:6] = base VA of this entry
  reg [39:6] pa;             // Physical address
  reg        ns;             // Non-secure
  reg  [1:0] state;          // Architectural state
  reg        init_cacheable; // Initially-cacheable transaction
  reg  [1:0] way;            // Allocate to {way1, way0}
  reg  [2:0] crit_line;      // Critical $line (from VA[5:3])
  reg  [1:0] crit_pc;        // Critical PC offset (from VA[2:1])
  wire       crit_en;        // Enable for critical line/pc

  // PPF state
  reg  [1:0] ppf     [0:BIU_CHUNKS-1];  // State for each chunk
  reg  [1:0] nxt_ppf [0:BIU_CHUNKS-1];  // Next state for each chunk
  reg        ppf_en  [0:BIU_CHUNKS-1];  // State transition enable for each chunk
  wire       ppf_last_pres;             // Last applicable chunk is 'present'

  // RLAST tracker
  wire       biu_ar_hs;   // AR handshake, final cycle
  wire       biu_r_hs;    //  R handshake, final cycle
  reg  [1:0] beat;
  wire [1:0] nxt_beat;
  wire       beat_we;
  wire       rlast;
  reg        rlast_seen;
  wire       nxt_rlast_seen;
  reg        first_seen;
  wire       nxt_first_seen;
  wire       first_seen_we;

  // pd0 allow
  wire       lfb_match_pd0;

  // Hit logic
  wire       pfb_attrs_cacheable;
  wire       hit_raw;
  wire       hit;
  wire [1:0] hit_ppf;
  wire [2:0] hit_resp;
  wire [1:0] va_hazard;

  // External aborts
  reg  [2:0] lfb_rresp     [BIU_CHUNKS-1:0];
  wire       lfb_rresp_we  [BIU_CHUNKS-1:0];

  // Cacheable state
  reg  [3:0] activate_chunks;     // New activation, chunks to consider
  reg        cacheable;           // NB 'real' cacheables can be treated as non-cacheable
  wire       cacheable2nc;        // A cacheable request will turn non-cacheable
  wire       cacheable_we;
  wire       nxt_cacheable;
  wire       committed;           // This entry is committed and can't abandon
  reg        committed_q;
  wire       committed_we;
  wire       nxt_committed;

  // Hittable state - CP15 hazards
  reg        cp15_hazard_seen;      // CP15 hazard seen while entry was active
  wire       nxt_cp15_hazard_seen;
  wire       set_cp15_hazard_seen;
  wire       cp15_hazard_seen_we;
  reg        unhittable;            // The entry has become 'unhittable'
  wire       set_unhittable;
  wire       nxt_unhittable;
  wire       unhittable_we;
  reg        cp15_hazard;

  // Cache allocation requests
  reg        lfb_match_pd1_q;
  wire       lfb_match_pd1;
  wire       lfb_hittable_pd1;

  // DCU control signal
  reg        lfb_biu_outstanding;
  wire       lfb_biu_outstanding_we;


  //----------------------------------------------------------------------------
  // Entry lifecycle (active bit)
  //
  //   This entry becomes active when the following conditions hold:
  //
  //     1. Either:
  //       a. A pre-fetch request missed in the if3 stage and the uTLB hit; OR
  //       b. A speculative cacheable request has been issued and no kill has
  //          been seen during the current (real cacheable) BIU address
  //          handshake.
  //     2. There is at least one inactive LFB entry
  //     3. This entry is the lowest inactive entry.
  //
  //   These conditions are managed in the main LFB module.
  //
  //   The entry de-activates depending on whether it is cacheable or
  //   non-cacheable, and abandoned or not.
  //
  //   NOT ABANDONED entries cease to become active after:
  //
  //    a. Non-cacheable: the last beat has been received from the BIU and the
  //       pre-fetch block has made a new (first), valid pre-fetch request or
  //       has entered debug
  //
  //    b. Cacheable: the final beat from the BIU has been allocated to the
  //       cache RAMs.
  //
  //   ABANDONED entries cease to be active after:
  //
  //    a. Non-cacheable: The last beat has been received from the BIU
  //
  //    b. Real cacheable: N/A because real cacheables can not abandon
  //
  //    c. Speculative cacheable: behave as non-cacheable (however, note that
  //       a speculative cacheable entry will only abandon if no allocation
  //       requests have been made yet; once any allocation has been requested
  //       they never abandon and behave like real cacheable entries.)
  //----------------------------------------------------------------------------

  // Active bit
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      active <= 1'b0;
    else if (active_we)
      active <= activate_i;

  assign active_we  = activate_i | (active & active_clr);
  assign active_clr = abandoned ? (rlast | rlast_seen) :
                      cacheable ? (ppf_last_pres & ctl_lfb_alloc_i) :
                                  ((rlast | rlast_seen) & (pfb_first_seen | pfb_in_debug_or_wfx_i | pfb_context_sync_i));


  // Track when a valid PFB first request has been seen over the lifecycle of
  // this entry, controlling when a non-cacheable entry can de-activate.  We
  // de-activate when an RLAST as well as an applicable PFB 'first' has been
  // seen, applicable meaning that the 'first' missed this entry in if2.  This
  // prevents a first following a uTLB flush from closing the entry when it can
  // still hit.
  //
  // The pfb_first_seen signal can be withdrawn if there is a 'first' that hits
  // this entry.  In this case a subsequent first was made to the same entry,
  // and while the entry is still active we can service these requests.

  // A real PFB first, i.e. PFB requesting a first and we are not stalling
  assign pfb_first_valid = lookup_i & lookup_first_i;

  // Registered first is valid in if2 when the uTLB hits and is not killed
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      pfb_first_q <= 1'b0;
    else
      pfb_first_q <= pfb_first_valid;

  assign pfb_first_if2 = pfb_first_q & pfb_utlb_hit_if2_i & ~pfb_kill_if2_i;

  // Record first seen when the first did not hit in the past present or future
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      pfb_first_seen_q <= 1'b0;
    else if (pfb_first_seen_we)
      pfb_first_seen_q <= nxt_pfb_first_seen;

  assign set_pfb_first_seen = active & pfb_first_if2 & ~ctl_stall_if3_i & ~hit;
  assign clr_pfb_first_seen = (pfb_first_if2 & hit) | active_clr;

  assign pfb_first_seen_we  = (set_pfb_first_seen & ~active_clr) | (clr_pfb_first_seen & pfb_first_seen_q);
  assign nxt_pfb_first_seen = set_pfb_first_seen & ~clr_pfb_first_seen;

  // Recover the entry if we are in if2 and we hit on the first that was in if1
  assign pfb_first_seen = set_pfb_first_seen | (pfb_first_seen_q & ~(pfb_first_if2 & hit));


  //----------------------------------------------------------------------------
  // BIU request outstanding
  //
  //   Signal to the DCU that the entry has an outstanding BIU request.
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_biu_outstanding <= 1'b0;
    else if (lfb_biu_outstanding_we)
      lfb_biu_outstanding <= activate_i;

  assign lfb_biu_outstanding_we = activate_i | rlast;


  //----------------------------------------------------------------------------
  // Abandoned state
  //
  //   An abandoned transfer is one that remains active but will not allocate to
  //   the cache RAMs.  This is an energy saving technique to ensure that killed
  //   requests don't needlessly allocate.
  //
  //   Cacheable transfers never abandon, because even if killed it's likely
  //   that the requested data (which we have already started to fetch and
  //   possibly allocate) will be re-used, e.g. at the end of a loop when the
  //   branch outcome changes.
  //
  //   Non-cacheable transfers abandon when there's a kill or a force, or the
  //   entry becomes unhittable due to a CP15 hazard.  As the tags were already
  //   invalidated no cache corruption occurs.
  //
  //   Speculative cacheable transfers behave as cacheable if any data has
  //   already been committed to the cache; otherwise they behave as
  //   non-cacheable.
  //
  //   Although the basic rules above hold, it must be noted that a cacheable
  //   transfer (speculative or not) can be turned non-cacheable due to a CP15
  //   operation.  In turning non-cacheable, if there's a CP15 hazard then the
  //   request will also abandon and become unhittable.  Thus it's possible
  //   for a cacheable transfer to indirectly abandon upon turning
  //   non-cacheable.
  //
  //----------------------------------------------------------------------------

  // Detect when we have each type of request (cacheable, non-cacheable,
  // speculative) that is in a situation where it can possibly abandon
  //
  //   [0] Non-cacheable:         when active or activating
  //   [1] Speculative cacheable: when activating or active and not committed
  //   [2] Real cacheable:        when active and not committed
  assign can_abandon[0] = (active & ~cacheable)                            | (activate_i & ~activate_curr_cacheable_i);
  assign can_abandon[1] = (active &  cacheable & speculative & ~committed) | (activate_i &  activate_curr_cacheable_i & activate_speculative_i);
  assign can_abandon[2] =  active &  cacheable &               ~committed;

  // Detect the actual cases that triggers abandonment
  //   [0] Non-cacheable:         kill, force or setting unhittable
  //   [1] Speculative cacheable: kill, force, setting inhittable when turning non-cacheable
  //   [2] Real cacheable:        setting unhittable when turning non-cacheable
  assign set_abandoned = (can_abandon[0] & (pfb_kill_if2_i | pfb_force_if1_i |  set_unhittable))                 |
                         (can_abandon[1] & (pfb_kill_if2_i | pfb_force_if1_i | (set_unhittable & cacheable2nc))) |
                         (can_abandon[2] &                                      set_unhittable & cacheable2nc);

  // Abandoned bit
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      abandoned <= 1'b0;
    else if (abandoned_we)
      abandoned <= nxt_abandoned;

  assign abandoned_we  = set_abandoned | active_clr;
  assign nxt_abandoned = set_abandoned & ~active_clr;

  //----------------------------------------------------------------------------
  // Entry transaction state
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      va             <= { 9{1'b0}};
      pa             <= {34{1'b0}};
      way            <= 2'b00;
      ns             <= 1'b0;
      state          <= 2'b11;       // Inital value marked invalid
      speculative    <= 1'b0;
      init_cacheable <= 1'b0;
    end else if (activate_i) begin
      va             <= activate_va_i[14:6];
      pa             <= activate_pa_i[39:6];
      way            <= activate_way_i[1:0];
      ns             <= pfb_ns_dsc_if2_i;
      state          <= pfb_state_if2_i;
      speculative    <= activate_speculative_i;
      init_cacheable <= activate_init_cacheable_i;
    end


  // As an optimisation, if this LFB hits with a 'future' hit prior to the
  // arrival of the entry's first beat of data then we change the recorded
  // critical line and PC offset.
  //
  // A future hit prior to the arrival of the first data beat indicates that
  // we've seen a branch to the same cache line.  (The future hit refers to
  // a lookup besides the one that initiated the activation of the LFB entry.)
  // As such we don't pre-decode the part of the cache line that has been
  // branched over and this is done by modifying the record of the critical line
  // and PC which is sent to the pre-decoder.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      crit_line <= 3'b000;
      crit_pc   <= 2'b00;
    end else if (crit_en) begin
      crit_line <= activate_va_i[5:3];
      crit_pc   <= activate_va_i[2:1];
    end

  // Note we suppress the update when the first data is just arriving as by this
  // point it's too late to update pre-decode.
  assign crit_en = activate_i | (~first_seen & ctl_hit_f_if3_i & hit & (hit_ppf == PPF_FUT) & ~biu_r_hs);


  //----------------------------------------------------------------------------
  // Entry cacheable state
  //
  //   When an entry is activated, it is marked as cacheable/non-cacheable based
  //   on the attributes from the pre-fetch request (and whether the cache is
  //   on).  At any time up to the point where the first chunk is received, this
  //   state can be updated in response to CP15 operations.
  //----------------------------------------------------------------------------

  // Identify the chunks that will be processed, based on the cacheability.
  // For cacheable transactions all chunks are processed.  For non-cacheable
  // transactions, only the chunks started at the original request will be
  // processed (although the others will be received they are set to N/A and
  // ignored.)  Valid when activate_i is high.
  always @ (*)
    case ({2{~activate_curr_cacheable_i}} & activate_pa_i[5:4])
      2'b00:   activate_chunks = 4'b1111;  // 4 beats
      2'b01:   activate_chunks = 4'b1110;  // 3 beats (receive 4 but discard one)
      2'b10:   activate_chunks = 4'b1100;  // 2 beats
      2'b11:   activate_chunks = 4'b1000;  // 1 beat
      default: activate_chunks = 4'bXXXX;
    endcase

  // A cacheable request becomes non-cacheable when there's a CP15 request
  // before the first BIU chunk is received
  assign cacheable2nc = cp15_active_i & ~first_seen;

  // Entry's cacheable state.  This state is constructed initially on activation
  // based on the attributes and CP15 activity at the time.  After activation,
  // if the entry is cacheable it will become non-cacheable if there's a CP15
  // operation at any point up to when the first data is returned (RREADY, pd0.)
  // After the first data has been returned, the state is fixed.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      cacheable <= 1'b0;
    else if (cacheable_we)
      cacheable <= nxt_cacheable;

  assign cacheable_we  = activate_i | (active & cacheable & cacheable2nc);
  assign nxt_cacheable = activate_i & activate_curr_cacheable_i;

  // An entry becomes committed to complete once the first if0 allocation
  // request for the entry has advanced into if1.  At this stage the tag ram
  // will be written (in if1, although this can be stalled by a lookup) and we
  // must then complete the line otherwise the cache will be corrupt.  (This
  // applies only to cacheable entries as non-cacheable entries would have
  // invalidated the tag.)
  //
  // Once committed, a cacheable transaction can not be abandoned.
  //
  // The committed flag is cleared when active goes low.  This ensures that new
  // entries are marked as not committed.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      committed_q <= 1'b0;
    else if (committed_we)
      committed_q <= nxt_committed;

  assign committed_we  = active_clr | (lfb_match_pd1 & ~ctl_stall_lfb_if0_i & ~committed_q);
  assign nxt_committed = ~active_clr & (lfb_match_pd1 & ~ctl_stall_lfb_if0_i);

  assign committed = (lfb_match_pd1 & ~ctl_stall_lfb_if0_i) | // if0 req accepted
                     committed_q;


  //----------------------------------------------------------------------------
  // Hittable state
  //
  //   Due to CP15 hazards, an entry can become 'unhittable'.  This is
  //   determined by the cp15_hazard_ack_i input:
  //
  //     2'b00 : No hazard
  //     2'b01 : Possible hazard due to invalidate all secure
  //     2'b10 : Possible hazard due to invalidate all non-secure
  //     2'b11 : Possible hazard due to short invalidate operation
  //
  //   The course of action depends on the type of hazard:
  //
  //     2'b00 : No action
  //     2'b01 : Suppress hits
  //     2'b10 : Suppress hits if the entry is marked as non-secure
  //     2'b11 : Suppress hits if the entry's VA[11:6] matches the CP15 op index
  //----------------------------------------------------------------------------

  // Decide whether cp15_hazard_ack_i, which indicates possible hazards,
  // translates to a possible hazard for THIS entry.
  always @ (*)
    case ({active, activate_i, cp15_hazard_ack_i})
      // Inactive, not activating: no hazard
      4'b0000, 4'b0001, 4'b0010, 4'b0011: cp15_hazard = 1'b0;

      // Active: calculate hazard based on registered state
      4'b1000: cp15_hazard = 1'b0;
      4'b1001: cp15_hazard = 1'b1;
      4'b1010: cp15_hazard = ns;
      4'b1011: cp15_hazard = (va[11:6] == cp15_addr_i[11:6]);

      // Activating this cycle: calculate based on activation inputs
      4'b0100: cp15_hazard = 1'b0;
      4'b0101: cp15_hazard = 1'b1;
      4'b0110: cp15_hazard = pfb_ns_dsc_if2_i;
      4'b0111: cp15_hazard = (activate_va_i[11:6] == cp15_addr_i[11:6]);

      // Illegal cases: can't be active and activating
      4'b1100, 4'b1101, 4'b1110, 4'b1111: cp15_hazard = 1'b0;

      // Propagate X
      default: cp15_hazard = 1'bX;
    endcase

  // Record when an actual CP15 hazard is seen.
  //   Set whenever an applicable CP15 hazard is seen during the lifecycle of the
  //   entry.  Cleared on de-activation.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      cp15_hazard_seen <= 1'b0;
    else if (cp15_hazard_seen_we)
      cp15_hazard_seen <= nxt_cp15_hazard_seen;

  assign set_cp15_hazard_seen = cp15_hazard;
  assign nxt_cp15_hazard_seen = set_cp15_hazard_seen & ~active_clr;
  assign cp15_hazard_seen_we  = set_cp15_hazard_seen | active_clr;


  // Turn the entry unhittable due to CP15 hazards
  //   Set the cycle after a hit if any hazard has been seen during the lifecycle
  //   of this entry (including this cycle).  Cleared on de-activation.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      unhittable <= 1'b0;
    else if (unhittable_we)
      unhittable <= nxt_unhittable;

  // NB. ~ctl_stall_pfb_i indicates a hit of any type
  assign set_unhittable = (cp15_hazard | cp15_hazard_seen) & ~ctl_stall_pfb_i;
  assign nxt_unhittable = set_unhittable & ~active_clr;
  assign unhittable_we  = set_unhittable | active_clr;


  //----------------------------------------------------------------------------
  // PPF state
  //
  //   Each of the four chunks of the cache line has a a PPF
  //   (Past/Present/Future) state, recording the current location of that data.
  //   This state also factors into the completion logic.
  //
  //   A new LFB entry has PPF set to FUTURE for all chunks, meaning that the
  //   chunks will be received.  The exception is for non-cacheable transfers,
  //   which can have some chunks set to N/A because non-cacheable transfers are
  //   non-wrapping and may have a transfer fewer than 4 beats.
  //----------------------------------------------------------------------------

  genvar i;

  generate for (i = 0; i < BIU_CHUNKS; i = i+1) begin : gen_ppf

    // State register
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        ppf[i] <= PPF_FUT;
      else if (ppf_en[i])
        ppf[i] <= nxt_ppf[i];

    // Next state logic.
    //   New activation:                 PPF = Future / NA
    //   Chunk received from pre-decode: PPF = Present
    //   LFB data will allocate to I$:   PPF = Past
    always @ (*)
      if (activate_i) begin
        // INACTIVE -> Future or NA
        nxt_ppf[i] = activate_curr_cacheable_i | activate_chunks[i] ? PPF_FUT : PPF_NA;
        ppf_en[i]  = 1'b1;
      end else if (lfb_match_pd1 & (rchunk_pd1_i == i[1:0])) begin
        // FUTURE -> Present
        nxt_ppf[i] = PPF_PRE;
        ppf_en[i]  = ~ctl_stall_lfb_if0_i;
      end else if (ctl_lfb_alloc_i) begin
        // PRESENT -> Past
        nxt_ppf[i] = PPF_PAS;
        ppf_en[i]  = (ppf[i] == PPF_PRE); // Only the entry in the LFB advances
      end else begin
        nxt_ppf[i] = ppf[i];
        ppf_en[i]  = 1'b0;
      end

  end endgenerate

  // The final applicable chunk is in the present state, to be allocated.  (This
  // means that all other chunks are either 'past' or 'N/A'.)
  assign ppf_last_pres = (ppf[3][1] & ppf[2][1] & ppf[1][1] & (ppf[0] == 2'b01)) |
                         (ppf[3][1] & ppf[2][1] & (ppf[1] == 2'b01) & ppf[0][1]) |
                         (ppf[3][1] & (ppf[2] == 2'b01) & ppf[1][1] & ppf[0][1]) |
                         ((ppf[3] == 2'b01) & ppf[2][1] & ppf[1][1] & ppf[0][1]);


  //----------------------------------------------------------------------------
  // BIU first and last tracker
  //
  //   Detect when the first beat and the last beat has been received from the
  //   BIU.  These are sticky status flags that are cleared when the entry is no
  //   longer active.
  //
  //   The 'first' indication is used to determine whether the cacheable state
  //   can be updated, and the 'last' indication is used to determine whether
  //   the entry can be closed.
  //----------------------------------------------------------------------------

  // Detect handshakes on BIU AR and R channels
  assign biu_ar_hs = ifu_arvalid_i & biu_arready_i & (ifu_arid_i == LFB_ID);
  assign biu_r_hs  = biu_rvalid_i  & ifu_rready_i  & (biu_rid_i  == LFB_ID);

  // Beat indicator is initialised to the length of the burst and then
  // decrements on each beat.  When it reaches zero this means that all beats
  // have been received.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      beat <= 2'b00;
    else if (beat_we)
      beat <= nxt_beat;

  assign beat_we  = biu_ar_hs | biu_r_hs;
  assign nxt_beat = biu_ar_hs ? ifu_arlen_i : (beat - 2'b01);

  // RLAST is when there's a read handshake completing for the final beat
  assign rlast = biu_r_hs & (beat == 2'b00);

  // Register RLAST, clear when the entry goes inactive
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rlast_seen <= 1'b0;
    else
      rlast_seen <= nxt_rlast_seen;

  assign nxt_rlast_seen = (rlast | rlast_seen) & ~active_clr;

  // Record when the first beat has been received (set cycle after BIU handshake
  // for first beat.)
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      first_seen <= 1'b0;
    else if (first_seen_we)
      first_seen <= nxt_first_seen;

  assign first_seen_we  = activate_i | (biu_r_hs & ~first_seen);
  assign nxt_first_seen = ~activate_i;


  //----------------------------------------------------------------------------
  // pd0 and pd1 matching
  //
  //   Match pd0 BIU responses against the entry state to determine whether the
  //   request will be handled.  We don't match when the entry is abandoned or
  //   the PPF state is N/A because such transfers do not allocate to the cache.
  //
  //   Pipeline this to pd1 (if0), forming the cache allocation request for this
  //   entry.
  //
  //----------------------------------------------------------------------------

  // pd0 match
  assign lfb_match_pd0 = biu_r_hs & active & ~abandoned & (ppf[biu_rchunk_i] != PPF_NA);

  // Pipeline into pd1
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_match_pd1_q <= 1'b0;
    else if (!ctl_stall_lfb_pd0_i)
      lfb_match_pd1_q <= lfb_match_pd0;

  // pd1 match
  //   This is used to form an allocation request.  We factor active into the
  //   final term again because the entry could have de-activated on entering
  //   pd1 (e.g. new non-cacheable request).
  assign lfb_match_pd1 = lfb_match_pd1_q & active & ~abandoned;

  // pd1 hittable
  //   This is similar to lfb_match_pd1 but, rather then being used for
  //   allocations, determines that it's POSSIBLE that there will be an
  //   if3-stage hit on the next cycle.  The hit will happen when the chunk
  //   requested by the pre-fetch unit matches the chunk that is currently in
  //   pd1.
  assign lfb_hittable_pd1 = lfb_match_pd1_q & ~active_clr & hit & (hit_ppf == PPF_FUT) & ~set_unhittable;


  //----------------------------------------------------------------------------
  // LFB entry lookup
  //----------------------------------------------------------------------------

  // Lookup has cacheable attributes
  assign pfb_attrs_cacheable = ctl_cache_on_if2_i & (`CA53_MEM_WB(pfb_attributes_if2_i) | `CA53_MEM_WT(pfb_attributes_if2_i));

  // Hit detection.  Note:
  //
  //   1. the hit logic is separated into a 'raw' hit and a qualified hit.  The
  //   raw hit signal does not factor in the 'unhittable' state and is used to
  //   suppress cache hits when there is a matching LFB.  The fully-qualified
  //   hit signal is used to indicate LFB hits.
  //
  //   2. The cacheable state must match for the entry to hit.  The 'initial'
  //   cacheable state is used here, i.e. the state when the entry was first
  //   activated, rather than the 'current' cacheable state which can change
  //   cacheable transactions to non-cacheable in response to CP15 operations.
  //   While the 'initial' cacheable state is used to determine a hit, the
  //   'current' cacheable state determines the entry lifecycle.
  assign hit_raw = (active & ~abandoned)                   &
                   ({pfb_va_if2_i[14:12] & ic_size_i,pfb_va_if2_i[11:6]} == {va[14:12] & ic_size_i, va[11:6]}) &
                   (pfb_pa_if2_i[39:12] == pa[39:12])      &
                   (pfb_attrs_cacheable == init_cacheable) &
                   (pfb_ns_dsc_if2_i    == ns)             &
                   (pfb_state_if2_i     == state);

  assign hit     = hit_raw & ~unhittable;

  // Past, present, future state (valid on hit)
  assign hit_ppf = ppf[pfb_va_if2_i[5:4]];

  // RRESP status on hit
  assign hit_resp = lfb_rresp[pfb_va_if2_i[5:4]];

  // A VA hazard hit is when a lookup matches the VA of an outstanding entry.
  // One bit per way.
  //
  // Disregard if the entry is abandoned because this means it's not going to
  // allocate anything to the cache.  Disregard if RLAST has been seen because
  // after this point it's not possible for data from a new request with the
  // same VA to write to the same way before the original completes.  (Before
  // RLAST is seen the bus could return data from the two requests in an
  // interleaved manner and it wouldn't be possible to guarantee that the first
  // request completes first.)
  assign va_hazard = {2{(active & ~abandoned & ~rlast_seen & (activate_va_i[11:6] == va[11:6]))}} & way[1:0];


  //----------------------------------------------------------------------------
  // External aborts
  //
  //   The BIU response information for each chunk is stored in the LFB.
  //   An external abort reported on any chunk causes the TAG to be invalidated.
  //   (If this happens on the first chunk of a cacheable request then this
  //   replaces the usual TAG valid write.)
  //
  //   External aborts don't influence the data RAM; the data is still written
  //   when it aborts.  This is so that if there's an LFB hit on an aborting
  //   chunk the abort information can be provided back to the pre-fetch block.
  //----------------------------------------------------------------------------

  // RRESP recorded for each chunk.  The PPF state indicates which of these are
  // valid.
  generate for (i = 0; i < BIU_CHUNKS; i = i+1) begin : gen_rresp

    always @ (posedge clk)
      if (lfb_rresp_we[i])
        lfb_rresp[i] <= biu_rresp_i;

    assign lfb_rresp_we[i] = biu_r_hs & (biu_rchunk_i == i[1:0]);

  end endgenerate

  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign active_o              = active;
  assign cacheable_o           = cacheable;
  assign va_o                  = va;
  assign pa_o                  = pa[39:12];
  assign way_o                 = way;
  assign state_o               = state;
  assign ns_o                  = ns;
  assign pd_o                  = {state, crit_line, crit_pc, (active & ~abandoned)};
  assign any_pp_o              = ppf[3][0] | ppf[2][0] | ppf[1][0] | ppf[0][0];
  assign hit_raw_o             = hit_raw & (hit_ppf != PPF_NA);
  assign hit_past_o            = hit & (hit_ppf == PPF_PAS);
  assign hit_pres_o            = hit & (hit_ppf == PPF_PRE);
  assign hit_fut_o             = hit & (hit_ppf == PPF_FUT);
  assign hit_ppf_o             = hit & (hit_ppf != PPF_NA );
  assign hit_resp_o            = hit_resp;
  assign va_hazard_o           = va_hazard;
  assign lfb_done_o            = active & ~abandoned & active_clr;
  assign lfb_match_pd0_o       = lfb_match_pd0;
  assign lfb_match_pd1_o       = lfb_match_pd1;
  assign lfb_hittable_pd1_o    = lfb_hittable_pd1;
  assign lfb_biu_outstanding_o = lfb_biu_outstanding;

  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Registered signals for OVLs
  reg       ovl_activate_reg;
  reg       ovl_active_reg;
  reg       ovl_cacheable_reg;
  reg       ovl_first_seen_reg;
  reg [1:0] ovl_ppf_reg        [0:BIU_CHUNKS-1];

  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_activate_reg  <= 1'b0;
      ovl_active_reg    <= 1'b0;
      ovl_cacheable_reg <= 1'b0;
      ovl_first_seen_reg<= 1'b0;
    end else begin
      ovl_activate_reg  <= activate_i;
      ovl_active_reg    <= active;
      ovl_cacheable_reg <= cacheable;
      ovl_first_seen_reg<= first_seen;
    end

  // X checks
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lfb_biu_outstanding_we")
  u_ovl_x_lfb_biu_outstanding_we (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (lfb_biu_outstanding_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: crit_en")
  u_ovl_x_crit_en (.clk       (clk),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (crit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: abandoned_we")
  u_ovl_x_abandoned_we (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (abandoned_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: activate_i")
  u_ovl_x_activate_i (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (activate_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_we")
  u_ovl_x_active_we (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (active_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: beat_we")
  u_ovl_x_beat_we (.clk       (clk),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (beat_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cacheable_we")
  u_ovl_x_cacheable_we (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (cacheable_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: committed_we")
  u_ovl_x_committed_we (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (committed_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp15_hazard_seen_we")
  u_ovl_x_cp15_hazard_seen_we (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (cp15_hazard_seen_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: first_seen_we")
  u_ovl_x_first_seen_we (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (first_seen_we));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_first_seen_we")
  u_ovl_x_pfb_first_seen_we (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (pfb_first_seen_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: unhittable_we")
  u_ovl_x_unhittable_we (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (unhittable_we));


  generate for (i = 0; i < BIU_CHUNKS; i = i+1) begin : gen_ovl_we_x

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lfb_rresp_we[i]")
    u_ovl_x_lfb_rresp_we (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (lfb_rresp_we[i]));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ppf_en[i]")
    u_ovl_x_ppf_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (ppf_en[i]));

  end endgenerate



  // Between activations (i.e. when an entry de-activates and gets re-used for
  // a different transaction) there must be at least one cycle where active is
  // LOW.  In other words, the activate_i signal, which sets active, must only
  // be set when active is LOW.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Active must be LOW between activations")
    ovl_active_low
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (activate_i),
       .consequent_expr (~active)
      );

  // Only cacheable transactions can be speculative.  This is checked using the
  // activation-time cacheable status, as an entry that started cacheable and
  // sepculative can become non-speculative if there's a CP15 operation.
  //
  // There's one case where a speculative entry can activate as non-cacheable,
  // and this is when the cp15 operation is signalled on the same cycle that we
  // activate the LFB entry.  It's too late to stop it at this point, though we
  // can set it to non-cacheable.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Speculative transactions can only start as cacheable")
    ovl_nc_spec
      (.clk       (clk),
       .reset_n   (reset_n),
       .antecedent_expr (activate_i && activate_speculative_i && ~cp15_active_i),
       .consequent_expr (activate_curr_cacheable_i)
      );

  // A non-speculative cacheable entry can not abandon
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "A non-speculative cacheable entry must never be abandoned")
    ovl_c_nonspec_abandon
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr (active && cacheable && !speculative && abandoned)
      );

  // A cacheable entry that is committed can not abandon (regardless of whether
  // it is speculative or not.)  Note that a committed non-cacheable can
  // abandon, but as the committed flag has no meaning for non-cacheable
  // entries.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "A committed cacheable entry must not abandon.")
    ovl_c_comm_abandon
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr (active && cacheable && committed && abandoned)
      );

  // PPF related assertions requiring an assertion per chunk
  generate for (i=0; i<3; i=i+1) begin : gen_ovl_ppf
    // Registered signals for OVLs
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        ovl_ppf_reg[i] <= 2'b00;
      else
        ovl_ppf_reg[i] <= ppf[i];

    // The PPF N/A state can only be reached for non-cacheable transactions and
    // only when the initial fetch line requested is not at the base of a cache
    // line.
    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "PPF N/A state should not be reached for this transaction")
      ovl_ppf_na_nc
        (.clk             (clk),
         .reset_n         (reset_n),
         .antecedent_expr (active && (ppf[i]==PPF_NA)),
         .consequent_expr (~cacheable && (crit_line != 2'b00))
        );

    // A PPF can only transition to N/A the cycle after an activation.  This OVL
    // achieves the check by comparing the PPF against the previous cycle's PPF
    // and if it moved into N/A from a non-NA state, then in the previous cycle
    // activate_i must have been high.
    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "PPF N/A only possible after an activation")
      ovl_ppf_na_actv
        (.clk             (clk),
         .reset_n         (reset_n),
         .antecedent_expr ((ppf[i] == PPF_NA) && (ovl_ppf_reg[i] != PPF_NA)),
         .consequent_expr (ovl_activate_reg)
        );

    // The N/A state can only move to 'Future' (when there's a new activation)
    assert_transition #(`OVL_FATAL, 2, `OVL_ASSERT, "PPF N/A state can only transition to Future state")
      ovl_ppf_na_trans
        (.clk             (clk),
         .reset_n         (reset_n),
         .test_expr       (ppf[i]),
         .start_state     (PPF_NA),
         .next_state      (PPF_FUT)
        );

    if (i > 0) begin : gt_0
      // If ppf[N] is N/A, then PPF[N-1] must be N/A for N>0.  This means that N/A
      // PPFs must be contiguous from PPF[0] upwards.
      assert_implication #(`OVL_FATAL, `OVL_ASSERT, "N/A PPFs must be contiguous from PPF[0]")
        ovl_ppf_na_cont
          (.clk             (clk),
           .reset_n         (reset_n),
           .antecedent_expr ((i > 0) && (ppf[i] == PPF_NA)),
           .consequent_expr (ppf[i-1] == PPF_NA)
          );
    end
  end endgenerate

  // Only one chunk (at most) can be in the PRESENT state
  assert_zero_one_hot #(`OVL_FATAL, BIU_CHUNKS, `OVL_ASSERT, "At most one chunk PPF can be PRESENT")
    u_ovl_pres_oh
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr ({(ppf[3] == PPF_PRE), (ppf[2] == PPF_PRE), (ppf[1] == PPF_PRE), (ppf[0] == PPF_PRE)})
      );

  // An active entry must relate to one way.  This means that the way select
  // must be either 2'b01 (way 0) or 2'b10 (way 1).  2'b00 would mean that no
  // way is selected, and 2'b11 would mean that both ways are selected and both
  // these cases are invalid.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Active entry needs valid way selection")
    ovl_assert_active_way
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr (active && !(^way[1:0]))
      );

  // A cacheable entry can turn non-cacheable at any time until the first beat
  // has been received, but not afterwards.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Entry cacheable -> non-cacheable possible only until first beat arrives")
    ovl_c2nc
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (active & ovl_active_reg &        // Active on this and prev cycles
                         ~cacheable & ovl_cacheable_reg), // Cacheable -> non-cacheable
       .consequent_expr (~ovl_first_seen_reg)
      );

  // A non-cacheable transaction never becomes cacheable.
  // Note that there's always at least one cycle where active is LOW when an
  // entry is re-activated for a different transaction which allows the OVL to
  // be written as it is.
  assert_no_transition #(`OVL_FATAL, 2, `OVL_ASSERT, "A non-cacheable tranaction can't become cacheable")
    ovl_nc2c
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   ({active & ~abandoned, cacheable}),
       .start_state (2'b10),  // Active, non-cacheable
       .next_state  (2'b11)   // Active, cacheable
      );

  // If a transaction is treated as non-cacheable and it's non-hittable, then it
  // must be abandoned.  (For non-cacheable tracactions abandoned == !hittable).
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Non-hittable non-cacheable transactions must be abandoned")
    ovl_nc_nonhit
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (active && unhittable && !cacheable),
       .consequent_expr (abandoned)
      );

  // activate_i and active_clr must not be high on the same cycle, meaning that
  // the lifecycle of two transactions using this entry overlap.  Some state
  // fields are cleared by the active_clr signal so this assertion also ensures
  // that they have time to clear before the next activation.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "activate_i and active_clr must never both be set")
    ovl_activate_clr
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       (activate_i && active_clr)
      );

  // If lfb_hittable_pd1 is high then lfb_match_pd1 is high.  If there's a hit
  // then we always allocate but not vice-versa (because we can allocate data
  // out of order.)
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "If lfb_hittable_pd1 is high then lfb_match_pd1 must be high")
    ovl_hittable_match
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (lfb_hittable_pd1),
       .consequent_expr (lfb_match_pd1)
      );

  // activate_chunks case statement should not hit the default case
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "activate_chunks case statement X")
    ovl_activate_chunks_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       (1'b1),
       .test_expr       (activate_chunks)
      );

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

