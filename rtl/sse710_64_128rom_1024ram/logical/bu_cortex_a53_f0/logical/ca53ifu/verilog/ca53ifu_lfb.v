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
// Abstract : Linefill buffer
//
//   The linefill buffer contains three entries that track outstanding requests,
//   but there is only a single data buffer for incoming data.  Instead of
//   adding extra buffering for non-cacheable transfers we instead re-use the
//   instruction cache to buffer the non-cacheable data.
//
//   There are two de-coupled paths through the LFB.  The first is the
//   lookup/allocation that is started from a pre-fetch request in if1 and can
//   either result in a hit or activating a new LFB entry.  The second path is
//   writing data to an active LFB entry, which is initiated from BIU R channel,
//   through pre-decode and finally resulting in an allocation to the
//   instruction cache.
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_lfb
  (// Clocks and resets
   input wire          clk,
   input wire          reset_n,
   input wire          DFTSE,
   // LFB pipeline
   input wire [1:0]    biu_i_rid_i,           // pd0: BIU read id
   input wire          biu_i_rvalid_i,        //      BIU read valid
   input wire [2:0]    biu_i_rresp_i,         //      BIU read resp
   input wire [1:0]    biu_i_rchunk_i,        //      BIU read line number
   output wire         ifu_rready_o,          //      BIU read ready
   input wire [159:0]  pd_data_i,             // pd1: data
   input wire          pd_req_i,              //      data req
   input wire          dpu_dbg_valid_i,       //      debug
   input wire          ctl_stall_lfb_if0_i,   //      stall (~ack)
   input wire          ctl_start_lfb_i,       // if2: start LFB entry clocks
   input wire          ctl_lfb_activate_i,    // if3: activate new LFB entry
   input wire          ctl_lfb_speculative_i, //      activation is speculative
   input wire [1:0]    ctl_tag_valid_if3_i,   //      tag RAMs were valid
   input wire [1:0]    ctl_almost_hit_if3_i,  //      ways that almost hit
   input wire          ctl_stall_if3_i,       //      stall
   output wire [1:0]   ifu_arid_o,            //      BIU read address id
   output wire         ifu_arvalid_o,         //      BIU read address valid
   output wire [39:0]  ifu_araddr_o,          //      BIU read address addr
   output wire [1:0]   ifu_arlen_o,           //      BIU read address length
   output wire [7:0]   ifu_attrs_o,           //      BIU read address attributes
   output wire [1:0]   ifu_arprot_o,          //      BIU read address prot
   input wire          biu_i_arready_i,       //      BIU read address ready

   // Pre-fetch block interface
   input wire [2:0]    ic_size_i,
   input wire [39:12]  pfb_pa_if2_i,
   input wire [14:4]   pfb_va_if2_i,
   input wire [7:0]    pfb_attributes_if2_i,
   input wire          pfb_ns_dsc_if2_i,
   input wire [1:0]    pfb_state_if2_i,
   input wire          pfb_kill_if2_i,
   input wire          pfb_utlb_hit_if2_i,
   input wire          pfb_force_if1_i,
   input wire          ctl_pfb_valid_if1_i,
   input wire          pfb_first_if1_i,
   input wire          pfb_in_debug_or_wfx_i,
   input wire          pfb_context_sync_i,

   // if3 transaction
   input wire [14:1]   ctl_pfb_va_if3_i,
   input wire [39:4]   ctl_pfb_pa_if3_i,
   input wire [7:0]    ctl_pfb_attributes_if3_i,
   input wire          ctl_pfb_ns_dsc_if3_i,
   input wire          ctl_pfb_priv_if3_i,

   // Cache allocation
   output wire [1:0]   lfb_tagram_en_if0_o,
   output wire [8:0]   lfb_tagram_addr_if0_o,
   output wire         lfb_tagram_wr_if0_o,
   output wire [30:0]  lfb_tagram_wdata_if0_o,
   output wire         lfb_dataram_en_if0_o,
   output wire         lfb_dataram_wr_if0_o,
   output wire [11:0]  lfb_dataram_addr0_if0_o,
   output wire [11:0]  lfb_dataram_addr1_if0_o,
   output wire [3:0]   lfb_dataram_strb0_if0_o,
   output wire [3:0]   lfb_dataram_strb1_if0_o,
   input wire          ctl_lfb_alloc_i,       // I$ allocation has been performed

   // LFB data
   output wire [159:0] lfb_data_o,
   output wire         lfb_data_way_o,
   output wire [7:0]   lfb_pd_0_o,
   output wire [7:0]   lfb_pd_1_o,
   output wire [7:0]   lfb_pd_2_o,

   // CP15
   input wire          cp15_active_i,
   input wire          ctl_cp15_active_if3_i,
   input wire [11:6]   cp15_addr_i,
   input wire [1:0]    cp15_hazard_ack_i,

   // Hits
   output wire         lfb_hit_raw_o,
   output wire         lfb_hit_past_o,
   output wire         lfb_hit_pres_o,
   output wire         lfb_hit_fut_o,
   output wire         lfb_hit_ppf_o,
   output wire [2:0]   lfb_hit_resp_o,
   output wire [1:0]   lfb_hit_way_o,
   output wire         lfb_hit_cacheable_o,
   output wire         icb_dbg_hit_if2_o,

   // Control interface
   input wire          ctl_stall_pfb_i,
   input wire          ctl_stall_lfb_pd0_i,
   input wire          ctl_random_way_i,
   input wire          ctl_cache_on_if2_i,
   input wire          ctl_hit_f_if3_i,
   output wire         lfb_in_progress_o,
   output wire [2:0]   ifu_outstanding_lfb_o,
   output wire [1:0]   lfb_available_o,
   output wire         lfb_comp_hazard_o,
   output wire         lfb_can_hit_pd1_o,   // The requested (critical) chunk is in pd1

   // Events
   output wire         ifu_evnt_ic_lf_o
  );


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  localparam LFB_ENTRIES = 3;

  // Intermediate clock gate
  reg                        clk_lfb_en;
  reg                  [2:0] clk_lfb_ctl_en;
  wire                       nxt_clk_lfb_en;
  wire                 [2:0] nxt_clk_lfb_ctl_en;
  wire                 [2:0] clk_lfb_ctl;
  wire                       clk_lfb;
  reg                        lfb_pending;
  wire                       nxt_lfb_pending;

  // pd0-stage transfer
  wire                       ifu_rready;

  // pd1-stage transfer
  wire                       pd1_en;
  reg                  [1:0] rchunk_pd1;
  reg                        ext_abrt_pd1;
  wire                       nxt_ext_abrt_pd1;
  wire                       ext_abrt_tag_inval;
  wire                       lfb_can_hit_pd1;
  reg                        dbg_req_pd1;
  wire                       dbg_req_pd1_we;
  wire                       nxt_dbg_req_pd1;

  // LFB data
  reg                [159:0] lfb_data;
  wire               [159:0] nxt_lfb_data;
  wire                       lfb_data_en;
  reg                        lfb_data_way;

  // LFB entry state
  wire                       lfb_active     [0:LFB_ENTRIES-1];
  wire                [14:6] lfb_va         [0:LFB_ENTRIES-1];
  wire               [39:12] lfb_pa         [0:LFB_ENTRIES-1];
  wire                 [1:0] lfb_way        [0:LFB_ENTRIES-1];
  wire                       lfb_cacheable  [0:LFB_ENTRIES-1];
  wire                       lfb_ns         [0:LFB_ENTRIES-1];
  wire                 [1:0] lfb_state      [0:LFB_ENTRIES-1];
  wire                       lfb_any_pp     [0:LFB_ENTRIES-1];
  wire                       lfb_hit_raw    [0:LFB_ENTRIES-1];
  wire                       lfb_hit_past   [0:LFB_ENTRIES-1];
  wire                       lfb_hit_pres   [0:LFB_ENTRIES-1];
  wire                       lfb_hit_fut    [0:LFB_ENTRIES-1];
  wire                       lfb_hit_ppf    [0:LFB_ENTRIES-1];
  wire                 [2:0] lfb_hit_resp   [0:LFB_ENTRIES-1];
  wire                 [1:0] lfb_va_hazard  [0:LFB_ENTRIES-1];
  wire                 [7:0] lfb_pd         [0:LFB_ENTRIES-1];
  wire                       lfb_done       [LFB_ENTRIES-1:0];

  // LFB entry matching
  wire   [(LFB_ENTRIES-1):0] lfb_match_pd0;
  wire   [(LFB_ENTRIES-1):0] lfb_match_pd1;
  wire   [(LFB_ENTRIES-1):0] lfb_hittable_pd1;
  wire                       match_pd0;
  reg                        any_pp_pd1; // ~First chunk received for current pd1 resp
  reg                 [14:6] va_pd1;     // VA of LFB entry matched in pd1
  reg                        cacheable_pd1;
  reg                        ns_pd1;
  reg                [39:12] pa_pd1;
  reg                  [1:0] state_pd1;
  reg                  [1:0] way_pd1;

  // I$ allocation
  wire                       ic_alloc_req_if0;
  wire                [11:0] ic_alloc_addr;
  wire                [11:0] ic_alloc_addr_p1;
  wire                 [1:0] lfb_tagram_en_if0;
  wire                 [8:0] lfb_tagram_addr_if0;
  wire                       lfb_tagram_wr_if0;
  wire                [30:0] lfb_tagram_wdata_if0;
  wire                       lfb_dataram_en_if0;
  wire                       lfb_dataram_wr_if0;
  wire                [11:0] lfb_dataram_addr0_if0;
  wire                [11:0] lfb_dataram_addr1_if0;
  wire                 [3:0] lfb_dataram_strb0_if0;
  wire                 [3:0] lfb_dataram_strb1_if0;


  // LFB activation
  reg                  [2:0] lfb_active_reg;
  reg    [(LFB_ENTRIES-1):0] lfb_activate;
  wire                 [1:0] activate_way;
  wire                 [1:0] hazard_hit;
  wire                 [1:0] va_hazard;     // VA match in an LFB entry, {way1, way0}
  wire                [14:1] activate_va;
  wire                [39:4] activate_pa;

  // BIU requests
  reg                        ifu_arvalid_q;
  wire                       ifu_arvalid;
  reg                        biu_arready_q;
  reg                  [1:0] arid_d;
  reg                  [1:0] arid_q;
  wire                 [1:0] ifu_arid;
  wire                [39:4] araddr_d;
  reg                 [39:4] araddr_q;
  reg                  [1:0] arlen_d;
  reg                  [1:0] arlen_q;
  wire                [39:0] ifu_araddr;
  reg                  [7:0] attrs_q;
  wire                 [7:0] ifu_attrs;
  reg                  [1:0] arprot_q;
  wire                 [1:0] arprot_d;
  wire                 [1:0] ifu_arprot;
  wire                 [1:0] ifu_arlen;

  wire                       curr_cacheable_if3;
  wire                       attrs_cacheable_if3;
  wire                       init_cacheable_if3;

  // Hits (combined)
  wire                       hit_raw;
  wire                       hit_past;
  wire                       hit_pres;
  wire                       hit_fut;
  wire                       hit_ppf;
  wire                 [1:0] hit_way;
  wire                 [2:0] hit_resp;
  wire                       hit_cacheable;
  reg                        lfb_dbg_hit;

  // Control signals
  wire                 [2:0] lfb_biu_outstanding;
  reg                 [13:0] lfb_avail_ctl;
  wire                       lfb_avail_cmp;
  wire                       lfb_available_r;
  wire                       lfb_available_s;
  wire                       lfb_comp_hazard;

  // Events
  wire                       ifu_event_ic_lf;

  genvar                     i;


  //----------------------------------------------------------------------------
  // Intermediate clock gate
  //----------------------------------------------------------------------------

  // The LFB buffer only needs to be enabled from the end of a BIU address
  // handshake until all control entries have cleared.
  assign nxt_clk_lfb_en = (ifu_arvalid & biu_i_arready_i) |
                          dpu_dbg_valid_i                 |
                          (clk_lfb_en & (lfb_active[2] | lfb_active[1] | lfb_active[0] | dbg_req_pd1));

  // All LFB entries are enabled following a miss (real or speculative); we only
  // know in if3 which one will be selected for activation.  When one of the LFB
  // entries activates, that one will continue to have its clock enabled but the
  // other ones will have their clock disabled, unless they are already active.
  assign nxt_clk_lfb_ctl_en[2] = ctl_start_lfb_i | lfb_pending | lfb_active[2];
  assign nxt_clk_lfb_ctl_en[1] = ctl_start_lfb_i | lfb_pending | lfb_active[1];
  assign nxt_clk_lfb_ctl_en[0] = ctl_start_lfb_i | lfb_pending | lfb_active[0];

  // An LFB activation can be delayed such as when there's an ongoing BIU
  // request.  In this case we must record the pending activation until it is
  // determined which entry will activate.
  assign nxt_lfb_pending = ctl_start_lfb_i | (lfb_pending & ~ctl_lfb_activate_i);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      clk_lfb_en     <= 1'b0;
      clk_lfb_ctl_en <= 3'b000;
      lfb_pending    <= 1'b0;
    end else begin
      clk_lfb_en     <= nxt_clk_lfb_en;
      clk_lfb_ctl_en <= nxt_clk_lfb_ctl_en;
      lfb_pending    <= nxt_lfb_pending;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_lfb (.clk_i         (clk),
                                               .clk_enable_i  (clk_lfb_en),
                                               .clk_senable_i (DFTSE),
                                               .clk_gated_o   (clk_lfb));

  ca53_cell_inter_clkgate u_inter_clkgate_lfb_ctl0 (.clk_i          (clk),
                                                    .clk_enable_i   (clk_lfb_ctl_en[0]),
                                                    .clk_senable_i  (DFTSE),
                                                    .clk_gated_o    (clk_lfb_ctl[0]));
  ca53_cell_inter_clkgate u_inter_clkgate_lfb_ctl1 (.clk_i          (clk),
                                                    .clk_enable_i   (clk_lfb_ctl_en[1]),
                                                    .clk_senable_i  (DFTSE),
                                                    .clk_gated_o    (clk_lfb_ctl[1]));
  ca53_cell_inter_clkgate u_inter_clkgate_lfb_ctl2 (.clk_i          (clk),
                                                    .clk_enable_i   (clk_lfb_ctl_en[2]),
                                                    .clk_senable_i  (DFTSE),
                                                    .clk_gated_o    (clk_lfb_ctl[2]));


  //============================================================================
  // BIU/PRE-DECODE DATA HANDLING
  //
  //   The logic in this section matches incoming BIU read data against active
  //   LFB entries, tracks through pre-decode, and allocates to the instruction
  //   cache.
  //============================================================================

  //----------------------------------------------------------------------------
  // pd0 matching
  //----------------------------------------------------------------------------

  // One of the LFBs match pd0 (data is returned from the BIU and the associated
  // LFB entry is not abandoned and the chunk is not marked as N/A)
  assign match_pd0 = |lfb_match_pd0;


  //----------------------------------------------------------------------------
  // pd1 matching
  //
  //   Get the state of the active LFB entry corresponding to the BIU response
  //   that is now in pd1 (if0).
  //
  //   This state is used by the ICB control block in the if0-stage cache access
  //   aribitration logic.
  //----------------------------------------------------------------------------

  always @ (*)
    case ({lfb_match_pd1[2], lfb_match_pd1[1], lfb_match_pd1[0]})
      // LFB[0] matches
      3'b001: begin
        any_pp_pd1      = lfb_any_pp[0];
        va_pd1          = lfb_va[0];
        cacheable_pd1   = lfb_cacheable[0];
        ns_pd1          = lfb_ns[0];
        pa_pd1          = lfb_pa[0][39:12];
        state_pd1       = lfb_state[0];
        way_pd1         = lfb_way[0];
      end

      // LFB[1] matches
      3'b010: begin
        any_pp_pd1      = lfb_any_pp[1];
        va_pd1          = lfb_va[1];
        cacheable_pd1   = lfb_cacheable[1];
        ns_pd1          = lfb_ns[1];
        pa_pd1          = lfb_pa[1][39:12];
        state_pd1       = lfb_state[1];
        way_pd1         = lfb_way[1];
      end

      // LFB[2] matches
      3'b100: begin
        any_pp_pd1      = lfb_any_pp[2];
        va_pd1          = lfb_va[2];
        cacheable_pd1   = lfb_cacheable[2];
        ns_pd1          = lfb_ns[2];
        pa_pd1          = lfb_pa[2][39:12];
        state_pd1       = lfb_state[2];
        way_pd1         = lfb_way[2];
      end

      // No entries match
      // Also include the non-one-hot input cases here to complete the case
      // statement.  These cases are covered by an OVL assertion.
      3'b000, 3'b011, 3'b101, 3'b110, 3'b111: begin
        any_pp_pd1      = 1'b0;
        va_pd1          = {9{1'b0}};
        cacheable_pd1   = 1'b0;
        ns_pd1          = 1'b0;
        pa_pd1          = {28{1'b0}};
        state_pd1       = 2'b00;
        way_pd1         = 2'b00;
      end

      // Propagate X
      default: begin
        va_pd1          = {9{1'bX}};
        cacheable_pd1   = 1'bX;
        ns_pd1          = 1'bX;
        pa_pd1          = {28{1'bX}};
        state_pd1       = 2'bXX;
        way_pd1         = 2'bXX;
      end
    endcase


  //----------------------------------------------------------------------------
  // pd0-stage transfer
  //----------------------------------------------------------------------------

  // Bring down RREADY when pd0 is stalling.  This happens when the control
  // block indicates there are other requests queued up in if0 and if1.
  assign ifu_rready = ~(ctl_stall_lfb_pd0_i);


  //----------------------------------------------------------------------------
  // pd1-stage transfer
  //----------------------------------------------------------------------------

  // Enable pd1 registers when there's a complete handshake that matches an
  // active LFB entry that is accepting this data.  Note that the handshake is
  // already included in the match signals from each entry.
  assign pd1_en = match_pd0;

  always @ (posedge clk)
    if (pd1_en) begin
      rchunk_pd1   <= biu_i_rchunk_i;
      ext_abrt_pd1 <= nxt_ext_abrt_pd1;
    end

  // Any type of external abort indicated by RRESP, including L2 ECC errors
  assign nxt_ext_abrt_pd1 = |biu_i_rresp_i[2:0];

  // When there's an external abort the tagram must be invalidated.  This only
  // needs to be done for cacheable requests; the tags for non-cacheable
  // requests are already invalidated.
  assign ext_abrt_tag_inval = ext_abrt_pd1 & cacheable_pd1;

  // Indicate to the control logic that the current PFB request can not hit yet,
  // but will hit as soon as the current LFB buffer drains.  This happens when
  // an LFB entry is indicating a 'future' hit (data isn't yet in the data
  // buffer) but we detect that the requested data is in pd1.
  assign lfb_can_hit_pd1 = (|lfb_hittable_pd1[2:0]) & (pfb_va_if2_i[5:4] == rchunk_pd1);

  // Debug request in if1
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      dbg_req_pd1 <= 1'b0;
    else if (dbg_req_pd1_we)
      dbg_req_pd1 <= nxt_dbg_req_pd1;

  assign nxt_dbg_req_pd1 = dpu_dbg_valid_i;
  assign dbg_req_pd1_we  = dpu_dbg_valid_i | dbg_req_pd1;


  //----------------------------------------------------------------------------
  // if0 cache allocation
  //
  //   The cache RAM allocation is formed in if0.  This gets pipelined into if1
  //   where the allocation takes place, subject to arbitration.  Where the if0
  //   stage arbitration in the ICB control logic did not select the LFB then
  //   a stall will be sent in the form of ctl_stall_lfb_if0_i.
  //----------------------------------------------------------------------------

  // All data from pre-decode is requested for cache allocation unless the
  // applicable LFB entry indicates that it must not be allocated (because it
  // is abandoned.)  Each individial LFB entry tracks whether it 'owns' data
  // in each stage of the pre-decode pipeline, and we use this to determine
  // whether anything will need to allocate to the cache RAMs.
  assign ic_alloc_req_if0 = |lfb_match_pd1;

  // The address into the virtually-indexed data RAM is the LFB entry's VA
  // offset by the chunk number that's being allocated.  But the corkscrew
  // methodology means that half of the data is allocated to one data bank at
  // this address, while the other half is allocated to the other data bank at
  // an incremented address.
  assign ic_alloc_addr    = {va_pd1[14:6], rchunk_pd1[1:0], 1'b0};
  assign ic_alloc_addr_p1 = {va_pd1[14:6], rchunk_pd1[1:0], 1'b1};

  // Tag RAM control.  Only write to tag on allocation of first-received chunk,
  // which is indicated by ~any_pp_pd1 (any PPF in the entry was past or
  // present, meaning that something has already been received,) or when there
  // is an external abort.
  assign lfb_tagram_en_if0[0]  = way_pd1[0] & ic_alloc_req_if0 & (~any_pp_pd1 | ext_abrt_tag_inval );
  assign lfb_tagram_en_if0[1]  = way_pd1[1] & ic_alloc_req_if0 & (~any_pp_pd1 | ext_abrt_tag_inval );
  assign lfb_tagram_addr_if0   = va_pd1[14:6];
  assign lfb_tagram_wr_if0     = ic_alloc_req_if0 & (~any_pp_pd1 | ext_abrt_tag_inval);
  assign lfb_tagram_wdata_if0  = {({2{~cacheable_pd1 | ext_abrt_tag_inval}} | state_pd1), ns_pd1, pa_pd1[39:12]};

  // Data RAM control, using corkscrew.
  assign lfb_dataram_en_if0    = ic_alloc_req_if0;
  assign lfb_dataram_wr_if0    = ic_alloc_req_if0;
  assign lfb_dataram_addr0_if0 = way_pd1[0] ? ic_alloc_addr    : ic_alloc_addr_p1;
  assign lfb_dataram_addr1_if0 = way_pd1[0] ? ic_alloc_addr_p1 : ic_alloc_addr;
  assign lfb_dataram_strb0_if0 = {4{ic_alloc_req_if0}};
  assign lfb_dataram_strb1_if0 = {4{ic_alloc_req_if0}};


  //----------------------------------------------------------------------------
  // Linefill buffer storage (if1)
  //
  //   The whole bufer is enabled when new pre-decoded data is available and the
  //   LFB is not stalling.  Data in the buffer is in the 'present' state.
  //
  //   The transaction information (ID, chunk) is pipelined from pd1 and used to
  //   form the cache RAM allocation requests.
  //----------------------------------------------------------------------------

  assign lfb_data_en = pd_req_i & ~ctl_stall_lfb_if0_i & (|lfb_match_pd1 | dbg_req_pd1);

  always @ (posedge clk_lfb)
    if (lfb_data_en) begin
      lfb_data     <= nxt_lfb_data;
      lfb_data_way <= way_pd1[1];  // LFB orientation is for way1/~way0
    end

  // The data itself has corkscrew applied before being clocked into the buffer.
  // This way it can be presented to the RAMs directly without further
  // processing.  Corkscrew means that data to be allocated to way0 has its
  // lower half allocated to bank0 and the upper half allocated to bank1.
  // Allocations to way1 have the lower half of the data allocated to bank1 and
  // the upper half to bank0.
  assign nxt_lfb_data = (way_pd1[0] | dbg_req_pd1) ? pd_data_i[159:0] : {pd_data_i[79:0], pd_data_i[159:80]};


  //----------------------------------------------------------------------------
  // LFB entry control
  //
  //   Three entries store the state of an in-flight request
  //----------------------------------------------------------------------------

  generate for (i=0; i<LFB_ENTRIES; i=i+1) begin : gen_lfb_ctl

    ca53ifu_lfb_ctl #(.LFB_ID(i[1:0])) u_ca53ifu_lfb_ctl
      (// Clocks and resets
       .clk                        (clk_lfb_ctl[i]),
       .reset_n                    (reset_n),
       // Entry activation
       .activate_i                 (lfb_activate[i]),
       .activate_va_i              (activate_va[14:1]),
       .activate_pa_i              (activate_pa[39:4]),
       .activate_curr_cacheable_i  (curr_cacheable_if3),
       .activate_init_cacheable_i  (init_cacheable_if3),
       .activate_speculative_i     (ctl_lfb_speculative_i),
       .activate_way_i             (activate_way[1:0]),

       // PFB interface
       .ic_size_i                  (ic_size_i[2:0]),
       .pfb_va_if2_i               (pfb_va_if2_i[14:4]),
       .pfb_pa_if2_i               (pfb_pa_if2_i[39:12]),
       .pfb_attributes_if2_i       (pfb_attributes_if2_i),
       .pfb_ns_dsc_if2_i           (pfb_ns_dsc_if2_i),
       .pfb_state_if2_i            (pfb_state_if2_i),
       .pfb_kill_if2_i             (pfb_kill_if2_i),
       .pfb_utlb_hit_if2_i         (pfb_utlb_hit_if2_i),
       .pfb_force_if1_i            (pfb_force_if1_i),
       .pfb_in_debug_or_wfx_i      (pfb_in_debug_or_wfx_i),
       .pfb_context_sync_i         (pfb_context_sync_i),
       .ctl_cache_on_if2_i         (ctl_cache_on_if2_i),
       .ctl_hit_f_if3_i            (ctl_hit_f_if3_i),

       // BIU interface
       .biu_rvalid_i               (biu_i_rvalid_i),
       .biu_rid_i                  (biu_i_rid_i),
       .biu_rchunk_i               (biu_i_rchunk_i),
       .biu_rresp_i                (biu_i_rresp_i),
       .ifu_rready_i               (ifu_rready),
       .ifu_arvalid_i              (ifu_arvalid),
       .ifu_arid_i                 (ifu_arid),
       .ifu_arlen_i                (ifu_arlen),
       .biu_arready_i              (biu_i_arready_i),

       // PD1 status
       .rchunk_pd1_i               (rchunk_pd1),

       // Entry status
       .active_o                   (lfb_active[i]),
       .va_o                       (lfb_va[i]),
       .pa_o                       (lfb_pa[i]),
       .way_o                      (lfb_way[i]),
       .cacheable_o                (lfb_cacheable[i]),
       .ns_o                       (lfb_ns[i]),
       .state_o                    (lfb_state[i]),
       .any_pp_o                   (lfb_any_pp[i]),
       .pd_o                       (lfb_pd[i]),

       // Lookup and hit
       .lookup_i                   (ctl_pfb_valid_if1_i), // PFB request; lookup in LFB
       .lookup_first_i             (pfb_first_if1_i),     // PFB first lookup
       .hit_raw_o                  (lfb_hit_raw[i]),
       .hit_past_o                 (lfb_hit_past[i]),
       .hit_pres_o                 (lfb_hit_pres[i]),
       .hit_fut_o                  (lfb_hit_fut[i]),
       .hit_ppf_o                  (lfb_hit_ppf[i]),
       .hit_resp_o                 (lfb_hit_resp[i]),
       .va_hazard_o                (lfb_va_hazard[i]),
       .lfb_done_o                 (lfb_done[i]),

       // Stalls
       .ctl_stall_pfb_i            (ctl_stall_pfb_i),
       .ctl_stall_lfb_pd0_i        (ctl_stall_lfb_pd0_i),
       .ctl_stall_lfb_if0_i        (ctl_stall_lfb_if0_i),
       .ctl_stall_if3_i            (ctl_stall_if3_i),

       // CP15
       .cp15_active_i              (cp15_active_i),
       .cp15_addr_i                (cp15_addr_i[11:6]),
       .cp15_hazard_ack_i          (cp15_hazard_ack_i),

       // Cache allocation and pre-decode
       .lfb_match_pd0_o            (lfb_match_pd0[i]),
       .lfb_match_pd1_o            (lfb_match_pd1[i]),
       .lfb_hittable_pd1_o         (lfb_hittable_pd1[i]),
       .lfb_biu_outstanding_o      (lfb_biu_outstanding[i]),
       .ctl_lfb_alloc_i            (ctl_lfb_alloc_i)
      );

  end endgenerate


  //============================================================================
  // PRE-FETCH REQUEST HANDLING
  //
  //   The logic in this section responds to pre-fetch requests, initiated in
  //   if1.   This results in an LFB lookup in if2 and, if necessary, a new LFB
  //   activation and BIU request in if3.
  //
  //============================================================================

  //----------------------------------------------------------------------------
  // LFB entry activation
  //
  //   The entry at the lowest index is chosen for activation
  //----------------------------------------------------------------------------

  // Use a registered version of active to determine which LFB to activate next.
  // This is because we must leave at least one cycle before re-using an LFB for
  // the next activation.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_active_reg <= 3'b000;
    else
      lfb_active_reg <= {lfb_active[2], lfb_active[1], lfb_active[0]};

  // Select the LFB entry
  always @ (*)
    case ({lfb_active_reg[2], lfb_active_reg[1], lfb_active_reg[0]})
      3'b000, 3'b010, 3'b100, 3'b110: lfb_activate = {2'b00, ctl_lfb_activate_i       };
      3'b001, 3'b101:                 lfb_activate = { 1'b0, ctl_lfb_activate_i,  1'b0};
      3'b011:                         lfb_activate = {       ctl_lfb_activate_i, 2'b00};
      3'b111:                         lfb_activate = 3'b000;
      default:                        lfb_activate = 3'bXXX;
    endcase

  // Choose which way will be used for allocations
  assign hazard_hit[1] = (ctl_almost_hit_if3_i[1] & ~ctl_almost_hit_if3_i[0]) |
                         va_hazard[1];
  assign hazard_hit[0] = (~ctl_almost_hit_if3_i[1] & ctl_almost_hit_if3_i[0]) |
                         va_hazard[0];

  assign activate_way[0] = ~va_hazard[0] &  // Never choose way0 if there's a way0 VA hzard
                           // Choose way0 if...
                            // ... both tags are invalid, or
                           ((~ctl_tag_valid_if3_i[1] & ~ctl_tag_valid_if3_i[0]) |
                            // ... only way1 is valid, or
                            ( ctl_tag_valid_if3_i[1] & ~ctl_tag_valid_if3_i[0]) |
                            // ... there's a way1 hazard
                            hazard_hit[1] |
                            // ... fall back to random selection if both ways valid, no hazard
                            (&ctl_tag_valid_if3_i & ~hazard_hit[0] & ~ctl_random_way_i));
  assign activate_way[1] = ~va_hazard[1] &
                           ((~ctl_tag_valid_if3_i[1]  & ctl_tag_valid_if3_i[0])  |
                            hazard_hit[0] |
                            (&ctl_tag_valid_if3_i & ~hazard_hit[1] & ctl_random_way_i));

  assign va_hazard = {lfb_va_hazard[2][1] | lfb_va_hazard[1][1] | lfb_va_hazard[0][1],
                      lfb_va_hazard[2][0] | lfb_va_hazard[1][0] | lfb_va_hazard[0][0]};

  // The VA used for activation depends on whether it's a normal or specualtive
  // activation.  Speculative activations use the next sequential cache line's
  // VA from the current if3 VA.
  assign activate_va = ctl_lfb_speculative_i ?
                         ({(ctl_pfb_va_if3_i[14:6] + 1'b1), 5'b00_000}) :
                         ctl_pfb_va_if3_i[14:1];

  // Similarly use the next sequential PA for speculative activations
  assign activate_pa = ctl_lfb_speculative_i ?
                         ({(ctl_pfb_pa_if3_i[39:6] + 1'b1), 2'b00}) :
                         ctl_pfb_pa_if3_i[39:4];

  //----------------------------------------------------------------------------
  // BIU requests
  //
  //   A BIU request is made after a miss, from the if3 stage.  This occurs in
  //   the same cycle that an LFB entry is activated.
  //----------------------------------------------------------------------------

  // In if3, when the entry is activated and the BIU request is sent, we make
  // an initial decision on whether the request is cacheable.  This is based on
  // the attributes from the PFB request as well as the cache_on bit.
  assign attrs_cacheable_if3 = `CA53_MEM_WB(ctl_pfb_attributes_if3_i) | `CA53_MEM_WT(ctl_pfb_attributes_if3_i);
  assign init_cacheable_if3  = ctl_cache_on_if2_i & attrs_cacheable_if3;

  // Additionally, we factor in CP15 activity to determine whether the request
  // is 'currently' considered cacheable.  The LFB entry will handle the request
  // as cacheable or non-cacheable based on this result.
  assign curr_cacheable_if3  = init_cacheable_if3     &
                               ~cp15_active_i         &
                               ~ctl_cp15_active_if3_i;


  // ARVALID is high on the same cycle as miss_if3, remaining high until the BIU
  // handshake is complete.  The earliest the BIU will complete the handshake is
  // on the second cycle, so it's possible to use miss_if3 to start the
  // handshake.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ifu_arvalid_q <= 1'b0;
    else
      ifu_arvalid_q <= ifu_arvalid;

  always @ (posedge clk)
    biu_arready_q <= biu_i_arready_i;

  assign ifu_arvalid = ctl_lfb_activate_i | (ifu_arvalid_q & ~biu_arready_q);


  // BIU request signals are constructed on the first cycle of the handshake
  // (the miss_if3 cycle for PFB requests, or the equivalent cycle for
  // specualtive lookups) and registered.  The registered versions are used for
  // subsequent handshake cycles.
  //
  //   ARID:   based on the selected LFB entry that handles the transaction
  //   ARADDR: from the PFB/speculative request, affected by cacheability
  //   ATTRS:  from the PFB (specualtive requests use the same attributes)
  //   ARPROT: from the PFB request, affected by resolved cacheability
  //   ARLEN:  depends on the cacheability

  // ID construction, based on selected LFB entry
  always @ (*)
    case (lfb_activate[2:0])
      3'b001: arid_d = 2'b00;
      3'b010: arid_d = 2'b01;
      3'b100: arid_d = 2'b10;
      // No activation: set to unused ID
      3'b000: arid_d = 2'b11;
      // lfb_activate is one-hot so the following values are illegal
      3'b011, 3'b101, 3'b110, 3'b111: arid_d = 2'b11;
      // Propagate X
      default: arid_d = 2'bXX;
    endcase

  // The transaction length depends on whether the PFB request is marked as
  // cacheable or non-cacheable (based on its attributes.)
  //
  // Non-cacheable bursts do not wrap.  Because we can't request a
  // non-power-of-two number of beats, ARADDR bits[5:4] are cleared for
  // non-cacheable requests that started at beat 1.  This means that we request
  // an extra beat and subsequently ignore it.
  assign araddr_d   = {activate_pa[39:6], (activate_pa[5:4] & {2{(attrs_cacheable_if3 | (activate_va[5:4] != 2'b01))}})};

  // Cacheable transfers are always 4 beats.  As noted above, we request an
  // extra beat for non-cacheable requests that would have started at beat 1 so
  // as not to break the power-of-two ARLEN rule.
  always @ (*)
    case (~{2{attrs_cacheable_if3}} & activate_pa[5:4])
      2'b00:   arlen_d = 2'b11;  // 4 beats
      2'b01:   arlen_d = 2'b11;  // 4 beats (3 + extra beat)
      2'b10:   arlen_d = 2'b01;  // 2 beats
      2'b11:   arlen_d = 2'b00;  // 1 beat
      default: arlen_d = 2'bXX;
    endcase

  // ARPROT bit[0] (privileged/not user) set based on the privilege of the PFB
  // request, and also set when a transaction is resolved as cacheable
  // regardless of the requested privilege.
  assign arprot_d   = {ctl_pfb_ns_dsc_if3_i, ctl_pfb_priv_if3_i};

  // Final BIU request terms
  assign ifu_arid   = ctl_lfb_activate_i ? arid_d                    : arid_q;
  assign ifu_araddr = ctl_lfb_activate_i ? {araddr_d[39:4], 4'b0000} : {araddr_q[39:4], 4'b0000};
  assign ifu_attrs  = ctl_lfb_activate_i ? ctl_pfb_attributes_if3_i  : attrs_q;
  assign ifu_arprot = ctl_lfb_activate_i ? arprot_d                  : arprot_q;
  assign ifu_arlen  = ctl_lfb_activate_i ? arlen_d                   : arlen_q;

  // Registered BIU request signals for second and subsequent cycles
  always @ (posedge clk)
    if (ctl_lfb_activate_i) begin
      arid_q   <= ifu_arid;
      araddr_q <= araddr_d;
      arlen_q  <= arlen_d;
      attrs_q  <= ctl_pfb_attributes_if3_i;
      arprot_q <= arprot_d;
    end


  //----------------------------------------------------------------------------
  // LFB hits
  //----------------------------------------------------------------------------

  // Overall past/present/future hit status for control logic
  assign hit_raw  =  lfb_hit_raw[2] |  lfb_hit_raw[1] |  lfb_hit_raw[0];
  assign hit_past = lfb_hit_past[2] | lfb_hit_past[1] | lfb_hit_past[0];
  assign hit_pres = lfb_hit_pres[2] | lfb_hit_pres[1] | lfb_hit_pres[0];
  assign hit_fut  =  lfb_hit_fut[2] |  lfb_hit_fut[1] |  lfb_hit_fut[0];
  assign hit_ppf  =  lfb_hit_ppf[2] |  lfb_hit_ppf[1] |  lfb_hit_ppf[0];

  // Way recorded by the LFB that hits (any type of hit)
  assign hit_way = ({2{lfb_hit_ppf[2]}} & lfb_way[2][1:0]) |
                   ({2{lfb_hit_ppf[1]}} & lfb_way[1][1:0]) |
                   ({2{lfb_hit_ppf[0]}} & lfb_way[0][1:0]);

  // Error response for the LFB that hit.  This always gives the 'OK' response
  // for 'future' hits (where the BIU has not yet given a response.)
  assign hit_resp = ({3{(lfb_hit_past[2] | lfb_hit_pres[2])}} & lfb_hit_resp[2]) |
                    ({3{(lfb_hit_past[1] | lfb_hit_pres[1])}} & lfb_hit_resp[1]) |
                    ({3{(lfb_hit_past[0] | lfb_hit_pres[0])}} & lfb_hit_resp[0]);

  // Report to the control logic whether this is a cacheable entry
  assign hit_cacheable = (lfb_hit_ppf[2] & lfb_cacheable[2]) |
                         (lfb_hit_ppf[1] & lfb_cacheable[1]) |
                         (lfb_hit_ppf[0] & lfb_cacheable[0]);

  // A debug hit occurs the same cycle that debug data is valid in the data
  // buffer
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_dbg_hit <= 1'b0;
    else
      lfb_dbg_hit <= dbg_req_pd1;


  //----------------------------------------------------------------------------
  // Control interface
  //----------------------------------------------------------------------------

  // Determine if there's space to activate any more LFB entries.  Used when
  // there is a real (not speculative) pre-fetch activation required.
  // We can activate if there are zero or one LFBs already active, never if
  // there are three active.  If there are two active, we can activate only if
  // their VA index and that of the new request are not all the same (because we
  // only have two cache ways.)
  always @ (*)
    case ({lfb_active[2], lfb_active[1], lfb_active[0]})
      // Zero or one LFBs used: available for allocation
      3'b000:  lfb_avail_ctl = {1'b1, 1'b0, {6{1'b0}}, {6{1'b0}}}; // {zero_or_one, full, comp0_va[11:6], comp1_va[11:6]}
      3'b001:  lfb_avail_ctl = {1'b1, 1'b0, {6{1'b0}}, {6{1'b0}}};
      3'b010:  lfb_avail_ctl = {1'b1, 1'b0, {6{1'b0}}, {6{1'b0}}};
      3'b100:  lfb_avail_ctl = {1'b1, 1'b0, {6{1'b0}}, {6{1'b0}}};

      // Two LFBs used: available if VA's do not match
      // Only use VA[11:6] (larger cache sizes won't increase LFB availability.)
      3'b011:  lfb_avail_ctl = {1'b0, 1'b0, lfb_va[1][11:6], lfb_va[0][11:6]};
      3'b101:  lfb_avail_ctl = {1'b0, 1'b0, lfb_va[2][11:6], lfb_va[0][11:6]};
      3'b110:  lfb_avail_ctl = {1'b0, 1'b0, lfb_va[2][11:6], lfb_va[1][11:6]};

      // Three LFBs used: not available for further activation
      3'b111:  lfb_avail_ctl = {1'b0, 1'b1, {6{1'b0}}, {6{1'b0}}};

      // Propagate X
      default: lfb_avail_ctl = {14{1'bX}};
    endcase

  // Comparator to determine whether it's OK to activate when there are two
  // outstanding LFBs.  This signal is high when all three VAs match.
  assign lfb_avail_cmp = ~|(lfb_avail_ctl[11:6] ^ lfb_avail_ctl[5:0]) &  // comp0_va == comp1_va
                         ~|(lfb_avail_ctl[11:6] ^ pfb_va_if2_i[11:6]);   // comp0_va == pfb_va

  // Final availability term (for real PFB requests)
  assign lfb_available_r = lfb_avail_ctl[13] | (~lfb_avail_ctl[13] & ~lfb_avail_ctl[12] & ~lfb_avail_cmp);

  // For speculative activations we only go ahead if there is precisely one LFB
  // active when the activation is requested
  assign lfb_available_s = lfb_avail_ctl[13];

  // Indicate when there's a hazard caused by a completing LFB entry that
  // matches the current VA.  Such a case resets the cache lookup state machine
  // in the control block.
  assign lfb_comp_hazard = (lfb_done[2] & (lfb_va[2][11:6] == pfb_va_if2_i[11:6])) |
                           (lfb_done[1] & (lfb_va[1][11:6] == pfb_va_if2_i[11:6])) |
                           (lfb_done[0] & (lfb_va[0][11:6] == pfb_va_if2_i[11:6]));

  //----------------------------------------------------------------------------
  // Events
  //----------------------------------------------------------------------------

  // ifu_event_ic_lf is a pulse that is set during an address handshake for
  // a cacheable request
  assign ifu_event_ic_lf = ctl_lfb_activate_i & curr_cacheable_if3;


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  // Indicate when any LFB is in progress
  assign lfb_in_progress_o       = lfb_active[2] | lfb_activate[2] |
                                   lfb_active[1] | lfb_activate[1] |
                                   lfb_active[0] | lfb_activate[0];
  // Events
  assign ifu_evnt_ic_lf_o        = ifu_event_ic_lf;

  // RAM control interface
  assign lfb_tagram_en_if0_o     = lfb_tagram_en_if0;
  assign lfb_tagram_addr_if0_o   = lfb_tagram_addr_if0;
  assign lfb_tagram_wr_if0_o     = lfb_tagram_wr_if0;
  assign lfb_tagram_wdata_if0_o  = lfb_tagram_wdata_if0;
  assign lfb_dataram_en_if0_o    = lfb_dataram_en_if0;
  assign lfb_dataram_wr_if0_o    = lfb_dataram_wr_if0;
  assign lfb_dataram_addr0_if0_o = lfb_dataram_addr0_if0;
  assign lfb_dataram_addr1_if0_o = lfb_dataram_addr1_if0;
  assign lfb_dataram_strb0_if0_o = lfb_dataram_strb0_if0;
  assign lfb_dataram_strb1_if0_o = lfb_dataram_strb1_if0;

  // Current LFB contents
  assign lfb_data_o              = lfb_data;
  assign lfb_data_way_o          = lfb_data_way;

  // Hits
  assign lfb_hit_raw_o           = hit_raw;
  assign lfb_hit_past_o          = hit_past;
  assign lfb_hit_pres_o          = hit_pres;
  assign lfb_hit_fut_o           = hit_fut;
  assign lfb_hit_ppf_o           = hit_ppf;
  assign lfb_hit_resp_o          = hit_resp;
  assign lfb_hit_way_o           = hit_way;
  assign lfb_hit_cacheable_o     = hit_cacheable;
  assign icb_dbg_hit_if2_o       = lfb_dbg_hit;

  // Future-hit data is queued in pd1
  assign lfb_can_hit_pd1_o       = lfb_can_hit_pd1;

  // Pre-decode interface
  assign lfb_pd_0_o              = lfb_pd[0];
  assign lfb_pd_1_o              = lfb_pd[1];
  assign lfb_pd_2_o              = lfb_pd[2];

  // BIU interface
  assign ifu_rready_o            = ifu_rready;
  assign ifu_arid_o              = ifu_arid;
  assign ifu_arvalid_o           = ifu_arvalid;
  assign ifu_araddr_o            = ifu_araddr;
  assign ifu_arlen_o             = ifu_arlen;
  assign ifu_attrs_o             = ifu_attrs;
  assign ifu_arprot_o            = ifu_arprot;

  // Control
  assign ifu_outstanding_lfb_o   = lfb_biu_outstanding;
  assign lfb_available_o         = {lfb_available_s, lfb_available_r};
  assign lfb_comp_hazard_o       = lfb_comp_hazard;

  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Signals used by OVLs
  wire [2:0] ovl_lfb_ana;             // LFBs active and not abandoned
  wire [2:0] ovl_lfb_act_way0;        // Active LFBs using way0
  wire [2:0] ovl_lfb_act_way1;        // Active LFBs using way1
  wire       ovl_va_eq_01;            // LFB[0] and LFB[1] VAs equal
  wire       ovl_va_eq_02;            // LFB[0] and LFB[2] VAs equal
  wire       ovl_va_eq_12;            // LFB[1] and LFB[2] VAs equal
  wire [2:0] ovl_way0_va_uniq;        // LFBs using way0 have unique VA
  wire [2:0] ovl_way1_va_uniq;        // LFBs using way1 have unique VA
  reg [2:0]  ovl_outstanding_lfb_ext; // ifu_outstanding_lfb previous cycle
  wire [2:0] ovl_lfb_pres;            // Any PPF is PRESENT, one bit per entry

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dbg_req_pd1_we")
  u_ovl_x_dbg_req_pd1_we (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (dbg_req_pd1_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ctl_lfb_activate_i")
  u_ovl_x_ctl_lfb_activate_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ctl_lfb_activate_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lfb_data_en")
  u_ovl_x_lfb_data_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (lfb_data_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd1_en")
  u_ovl_x_pd1_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (pd1_en));


  // Only one LFB control entry can command the LFB data register at a time
  assign ovl_lfb_pres[2] = lfb_active[2] &
                           ((gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.ppf[3][1:0] == 2'b01) |  // LFB[2] PPF[3] is PRESENT
                            (gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.ppf[2][1:0] == 2'b01) |  // LFB[2] PPF[2] is PRESENT
                            (gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.ppf[1][1:0] == 2'b01) |  // LFB[2] PPF[1] is PRESENT
                            (gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.ppf[0][1:0] == 2'b01));  // LFB[2] PPF[0] is PRESENT
  assign ovl_lfb_pres[1] = lfb_active[1] &
                           ((gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.ppf[3][1:0] == 2'b01) |  // LFB[1] PPF[3] is PRESENT
                            (gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.ppf[2][1:0] == 2'b01) |  // LFB[1] PPF[2] is PRESENT
                            (gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.ppf[1][1:0] == 2'b01) |  // LFB[1] PPF[1] is PRESENT
                            (gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.ppf[0][1:0] == 2'b01));  // LFB[1] PPF[0] is PRESENT
  assign ovl_lfb_pres[0] = lfb_active[0] &
                           ((gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.ppf[3][1:0] == 2'b01) |  // LFB[0] PPF[3] is PRESENT
                            (gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.ppf[2][1:0] == 2'b01) |  // LFB[0] PPF[2] is PRESENT
                            (gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.ppf[1][1:0] == 2'b01) |  // LFB[0] PPF[1] is PRESENT
                            (gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.ppf[0][1:0] == 2'b01));  // LFB[0] PPF[0] is PRESENT

  assert_zero_one_hot #(`OVL_FATAL, LFB_ENTRIES, `OVL_ASSERT, "Only one LFB control entry can command the LFB data")
    u_ovl_lfb_pres_oh
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (ovl_lfb_pres[2:0])
      );

  // LFBs that are active and not abandoned.  Such entries are expected to
  // allocate to the caches during their lifecycle.
  assign ovl_lfb_ana = {(lfb_active[2] & ~gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.abandoned),
                        (lfb_active[1] & ~gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.abandoned),
                        (lfb_active[0] & ~gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.abandoned)};

  // LFBs that are expected to allocate to way0 and way1.  The way information
  // recorded in the LFBs is only valid if the entry is active and not
  // abandoned because an abandoned entry will not allocate.
  // Disregard once RLAST is seen because after this point it's possible for two
  // LFBs at the same VA to indicate that same way: after RLAST there's no chance
  // that interleaved data from another request can alloate before the cache line
  // completes.  (Because the arbitration logic will stall the second request
  // until the first has been accepted; they cannot overlap.)
  assign ovl_lfb_act_way0 = {(ovl_lfb_ana[2] & ~gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[2] == 2'b01)),
                             (ovl_lfb_ana[1] & ~gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[1] == 2'b01)),
                             (ovl_lfb_ana[0] & ~gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[0] == 2'b01))};
  assign ovl_lfb_act_way1 = {(ovl_lfb_ana[2] & ~gen_lfb_ctl[2].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[2] == 2'b10)),
                             (ovl_lfb_ana[1] & ~gen_lfb_ctl[1].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[1] == 2'b10)),
                             (ovl_lfb_ana[0] & ~gen_lfb_ctl[0].u_ca53ifu_lfb_ctl.rlast_seen & (lfb_way[0] == 2'b10))};

  assign ovl_va_eq_01 = lfb_va[0] == lfb_va[1];
  assign ovl_va_eq_02 = lfb_va[0] == lfb_va[2];
  assign ovl_va_eq_12 = lfb_va[1] == lfb_va[2];

  assign ovl_way0_va_uniq = ({1'b0, {2{ovl_va_eq_01}}}          & ovl_lfb_act_way0) |
                            ({ovl_va_eq_02, 1'b0, ovl_va_eq_02} & ovl_lfb_act_way0) |
                            ({{2{ovl_va_eq_12}}, 1'b0}          & ovl_lfb_act_way0);
  assign ovl_way1_va_uniq = ({1'b0, {2{ovl_va_eq_01}}}          & ovl_lfb_act_way1) |
                            ({ovl_va_eq_02, 1'b0, ovl_va_eq_02} & ovl_lfb_act_way1) |
                            ({{2{ovl_va_eq_12}}, 1'b0}          & ovl_lfb_act_way1);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_outstanding_lfb_ext <= {3{1'b0}};
    else
      ovl_outstanding_lfb_ext <= ifu_outstanding_lfb_o;

  // The LFB entry match signals for each pipeline stage must be one-hot
  assert_zero_one_hot #(`OVL_FATAL, LFB_ENTRIES, `OVL_ASSERT, "LFB entry pd0 match must be one-hot")
    ovl_lfb_match_pd0_oh (.clk(clk), .reset_n(reset_n), .test_expr(lfb_match_pd0));
  assert_zero_one_hot #(`OVL_FATAL, LFB_ENTRIES, `OVL_ASSERT, "LFB entry pd1 match must be one-hot")
    ovl_lfb_match_pd1_oh (.clk(clk), .reset_n(reset_n), .test_expr(lfb_match_pd1));

  // An allocation request must be to precisely one way
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "LFB allocation request must be to precisely one way")
    ovl_alloc_way
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (ic_alloc_req_if0),
       .consequent_expr (^way_pd1[1:0])
      );

  // Any two active LFB entries with the same VA must allocate to different ways
  assert_zero_one_hot #(`OVL_FATAL, LFB_ENTRIES, `OVL_ASSERT, "Must not have >1 active LFB with same VA using way0 until RLAST seen")
    ovl_alloc_way0_oh
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       (ovl_way0_va_uniq)
      );
  assert_zero_one_hot #(`OVL_FATAL, LFB_ENTRIES, `OVL_ASSERT, "Must not have >1 active LFB with same VA using way1 until RLAST seen")
    ovl_alloc_way1_oh
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       (ovl_way1_va_uniq)
      );

  // When any bit of lfb_activate goes high, the corresponding bit of
  // ifu_outstanding_lfb must have been LOW on the previous cycle.  This is
  // because there needs to be at least one LOW cycle on ifu_outstanding_lfb
  // between activations, and this signal goes high on the same cycle as
  // lfb_activate.
  generate for (i=0; i<LFB_ENTRIES; i=i+1) begin : gen_ovl_outstanding_lfb
    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Must be one LOW cycle on ifu_outstanding_lfb between activations")
    ovl_outstanding_lfb
        (.clk             (clk),
         .reset_n         (reset_n),
         .antecedent_expr (lfb_activate[i]),
         .consequent_expr (~ovl_outstanding_lfb_ext[i])
        );
  end endgenerate

  // Event signal ifu_event_ic_lf must be a pulse.  As we always have at least
  // one idle cycle between address handshakes there should never be a case
  // where this signal is high for two consecutive cycles.
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "ifu_event_ic_lf must be a pulse")
    ovl_event_ic_lf_pulse
      (.clk             (clk),
       .reset_n         (reset_n),
       .start_event     (ifu_event_ic_lf),
       .test_expr       (~ifu_event_ic_lf)
      );

  // Check that the write enable to the LFB data doesn't go high when
  // clk_lfb_en is LOW (during which time the LFB data clock is gated)
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "LFB data enable went high when the clock was gated")
    ovl_lfb_data_en
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       (lfb_data_en & ~clk_lfb_en)
      );

  // arlen_d case statement should not hit the default case and become X
  // when there is an LFB activation
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "arlen_d case output X")
    ovl_arlen_d_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       (ctl_lfb_activate_i),
       .test_expr       (arlen_d)
      );

  // arid_d case statement should not hit the default case and become X when
  // there is an LFB activation
  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "arid_d case output X")
    ovl_arid_d_d_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       (ctl_lfb_activate_i),
       .test_expr       (arid_d)
      );

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

