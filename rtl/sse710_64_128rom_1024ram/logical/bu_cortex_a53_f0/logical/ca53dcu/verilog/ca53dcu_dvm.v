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
// Abstract : DCU DVM Control Block
//
// The DVM block takes IFU/TLB DVM messages from ACE, formats them correctly
// for the relevant block, and issues them through the load/store pipe
// interface. It also tracks when the DVM Complete can be sent for a DVM
// Sync.
//
//-----------------------------------------------------------------------------

`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_ifu_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_ace_defs.v"

module ca53dcu_dvm
  (
   input   wire                           clk,
   input   wire                           clk_ccb,
   input   wire                           reset_n,


   //--------------------------------------------------------------------------
   // CCB Interface
   //--------------------------------------------------------------------------

   input   wire                           dvm_valid_i,
   input   wire                    [40:0] dvm_addr_first_i,
   input   wire                    [40:6] dvm_addr_second_hi_i,
   input   wire                     [3:0] dvm_addr_second_lo_i,
   input   wire                     [7:0] scu_reqbufs_busy_i,

   output  wire                           dvm_is_done_o,
   output  wire                           sync_lists_active_o,
   output  wire                           tlb_ifu_inv_all_ongoing_o,


   //--------------------------------------------------------------------------
   // CP15 Interface
   //--------------------------------------------------------------------------

   input   wire                           inv_all_tlb_ifu_i,
   input   wire                           force_reset_i,


   //--------------------------------------------------------------------------
   // LSPipe Interface
   //--------------------------------------------------------------------------

   input   wire                           block_dvm_dc3_i,
   input   wire                           valid_dc1_i,
   input   wire                           valid_dc2_i,
   input   wire                           valid_dc3_i,
   input   wire                           dsb_dc1_i,
   input   wire                           dsb_dc2_i,
   input   wire                           dsb_dc3_i,
   input   wire                           next_valid_dc2_i,
   input   wire                           next_valid_dc3_i,
   input   wire                           v_enable_dc1_i,
   input   wire                           v_enable_dc2_i,
   input   wire                           v_enable_dc3_i,
   input   wire                           dcu_ongoing_burst_dc1_i,

   output  wire                           dcu_dvm_valid_tlb_o,
   output  wire                           dcu_dvm_valid_ifu_o,
   output  wire                           dvm_in_progress_o,
   output  wire                     [4:0] dvm_tlb_cp_op_o,
   output  wire                     [2:0] dvm_ifu_cp_op_o,
   output  wire                    [61:0] dvm_cp_addr_o,
   output  wire                           dvm_ns_o,


   //--------------------------------------------------------------------------
   // TLB Interface
   //--------------------------------------------------------------------------

   input   wire                           tlb_cp_ack_i,
   input   wire                           tlb_pagewalk_invalidated_i,


   //--------------------------------------------------------------------------
   // IFU Interface
   //--------------------------------------------------------------------------

   input   wire                           ifu_cp_ack_i,
   input   wire                           ifu_valid_if2_i,
   input   wire                     [2:0] ifu_outstanding_lfb_i,


   //--------------------------------------------------------------------------
   // STB interface
   //--------------------------------------------------------------------------

   input   wire                     [4:0] stb_slots_valid_i,
   input   wire                     [4:0] stb_slots_dsb_i,

   output  wire                     [4:0] dcu_drain_slots_o,


   //--------------------------------------------------------------------------
   // BIU Interface
   //--------------------------------------------------------------------------

   input   wire                     [7:0] biu_lf_in_progress_i,
   input   wire                     [3:0] biu_pf_in_progress_i,

   output  wire                           dvm_stop_pf_o,
   output  wire                           dcu_drain_stb_lf_o,


   //--------------------------------------------------------------------------
   // SCU Interface
   //--------------------------------------------------------------------------

   output  reg                            dcu_dvm_complete_o


  );


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  wire  [                   61:0]  cp_addr;
  wire                             cp_ns;
  wire                             dcu_dvm_valid_ifu;
  wire                             dcu_dvm_valid_tlb;
  wire  [                    2:0]  dcu_ops_initial;
  wire  [                    2:0]  dvm_cmd;
  wire                             dvm_in_progress;
  wire  [                    2:0]  dvm_p_ifu_op;
  wire                             dvm_sync;
  wire                             dvm_tlb_done;
  reg   [                    4:0]  dvm_tlb_op;
  reg   [                    2:0]  dvm_v_ifu_op;
  reg                              flush_pending;
  reg                              flush_pending_sync;
  wire  [                    2:0]  ifu_cp_op;
  wire                             ifu_req;
  reg                              inv_all_ifu_req;
  reg                              inv_all_tlb_req;
  wire                             next_dvm_complete;
  wire                             next_flush_pending;
  wire                             next_flush_pending_sync;
  wire                             next_inv_all_ifu_req;
  wire                             next_inv_all_tlb_req;
  wire  [                    2:0]  next_sync_list_biu_ifu;
  wire  [                    8:0]  next_sync_list_count;
  wire  [                    2:0]  next_sync_list_dcu_ops;
  wire                             next_sync_list_empty;
  wire  [                    7:0]  next_sync_list_lfbs;
  wire  [                    3:0]  next_sync_list_pfs;
  wire  [                    7:0]  next_sync_list_reqbuffs;
  wire                             next_sync_list_ifu;
  wire                             next_sync_list_pw_inv;
  wire  [                    4:0]  next_sync_list_stb_slots;
  wire  [                    2:0]  next_tlb_list_biu_ifu;
  wire  [                    8:0]  next_tlb_list_count;
  wire  [                    2:0]  next_tlb_list_dcu_ops;
  wire  [                    7:0]  next_tlb_list_lfbs;
  wire  [                    3:0]  next_tlb_list_pfs;
  wire  [                    7:0]  next_tlb_list_reqbuffs;
  wire                             next_tlb_list_ifu;
  wire                             next_tlb_list_pw_inv;
  wire  [                    4:0]  next_tlb_list_stb_slots;
  wire  [                   39:0]  p_ifu_cp_addr;
  wire                             set_sync_list;
  wire                             sync_list;
  reg   [                    2:0]  sync_list_biu_ifu;
  wire  [                    2:0]  sync_list_biu_ifu_track;
  reg   [                    8:0]  sync_list_count;
  wire                             sync_list_count_en;
  reg   [                    2:0]  sync_list_dcu_ops;
  wire  [                    2:0]  sync_list_dcu_ops_track;
  wire                             sync_list_en;
  reg   [                    7:0]  sync_list_lfbs;
  reg   [                    3:0]  sync_list_pfs;
  reg   [                    7:0]  sync_list_reqbuffs;
  wire  [                    7:0]  sync_list_lfbs_track;
  wire  [                    3:0]  sync_list_pfs_track;
  wire  [                    7:0]  sync_list_reqbuffs_track;
  reg                              sync_list_ifu;
  wire                             sync_list_ifu_track;
  reg                              sync_list_pw_inv;
  wire                             sync_list_pw_inv_track;
  reg   [                    4:0]  sync_list_stb_slots;
  wire  [                    4:0]  sync_list_stb_slots_track;
  wire  [                   61:0]  tlb_cp_addr;
  wire  [                    4:0]  tlb_cp_op;
  wire                             tlb_list;
  reg   [                    2:0]  tlb_list_biu_ifu;
  wire  [                    2:0]  tlb_list_biu_ifu_track;
  reg   [                    8:0]  tlb_list_count;
  wire                             tlb_list_count_en;
  wire  [                    8:0]  tlb_list_count_incd;
  reg   [                    2:0]  tlb_list_dcu_ops;
  wire  [                    2:0]  tlb_list_dcu_ops_track;
  wire                             tlb_list_en;
  reg   [                    7:0]  tlb_list_lfbs;
  reg   [                    3:0]  tlb_list_pfs;
  reg   [                    7:0]  tlb_list_reqbuffs;
  wire  [                    7:0]  tlb_list_lfbs_track;
  wire  [                    3:0]  tlb_list_pfs_track;
  wire  [                    7:0]  tlb_list_reqbuffs_track;
  reg                              tlb_list_ifu;
  wire                             tlb_list_ifu_track;
  reg                              tlb_list_pw_inv;
  wire                             tlb_list_pw_inv_track;
  reg   [                    4:0]  tlb_list_stb_slots;
  wire  [                    4:0]  tlb_list_stb_slots_track;
  wire                             tlb_req;
  wire  [                   39:0]  v_ifu_cp_addr;
  wire                             tlb_list_dcu_stb_lf_outstanding;
  wire                             tlb_list_resample_lfbs;
  wire                             sync_list_dcu_stb_lf_outstanding;
  wire                             sync_list_resample_lfbs;


  //---------------------------------------------------------------------------
  // Forwarded TLB & IFU Maintenance Operations
  //---------------------------------------------------------------------------

  //-------------------------
  // Invalidate all on reset
  //-------------------------

  // Register the request from the CP15 block and hold the request to each
  // unit until the ack is received. Note that the registers can be clocked
  // off the gated clock, as the clock is enabled immediately after reset,
  // and the enable factors in the invalidate all on reset outstanding
  // signal.

  assign next_inv_all_tlb_req = inv_all_tlb_ifu_i | (inv_all_tlb_req & ~tlb_cp_ack_i);
  assign next_inv_all_ifu_req = inv_all_tlb_ifu_i | (inv_all_ifu_req & ~ifu_cp_ack_i);

  always @(posedge clk_ccb or negedge reset_n)
    if (!reset_n) begin
      inv_all_tlb_req <= 1'b0;
      inv_all_ifu_req <= 1'b0;
    end else begin
      inv_all_tlb_req <= next_inv_all_tlb_req;
      inv_all_ifu_req <= next_inv_all_ifu_req;
    end

  // Indicate when there is an invalidate all on reset in progress, to
  // block new snoop transactions being accepted or the core entering WFx.
  assign tlb_ifu_inv_all_ongoing_o = inv_all_ifu_req | inv_all_tlb_req;


  //------------------
  // TLB DVM messages
  //------------------

  // Form the command in the correct format to send to the TLB
  always @*
    case ({dvm_addr_first_i[11:10], // OS       (11-> Hyp, 10-> Guest, 01-> El3)
           dvm_addr_first_i[8],     // Security (1-> nS,  0-> Secure)
           dvm_addr_first_i[6],     // Match VMID
           dvm_addr_first_i[5],     // Match ASID
           dvm_addr_first_i[4],     // LEAF
           dvm_addr_first_i[3:2],   // Invalidation stage
           dvm_addr_first_i[0]})    // Match MVA
      9'b010000000: // EL3 secure, Don't match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_ALLE3;
      9'b010000001: // EL3 secure, Don't match ASID or VMID, Match MVA
        dvm_tlb_op = `CA53_CP_TLBI_VAE3;
      9'b010001001: // EL3 secure, LEAF, Don't match ASID or VMID, Match MVA
        dvm_tlb_op = `CA53_CP_TLBI_VALE3;
      9'b100000000: // Guest secure, Don't match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_ALLE1;
      9'b100000001: // Guest secure, Don't match ASID or VMID, Match MVA
        dvm_tlb_op = `CA53_CP_TLBI_VAAE1;
      9'b100001001: // Guest secure, Don't match ASID, VMID, Match MVA, LEAF
        dvm_tlb_op = `CA53_CP_TLBI_VAALE1;
      9'b100010000: // Guest secure, Match ASID, Don't match VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_ASIDE1;
      9'b100010001: // Guest secure, Match ASID, MVA, Don't match VMID
        dvm_tlb_op = `CA53_CP_TLBI_VAE1;
      9'b100011001: // Guest secure, LEAF, Match ASID, MVA, Don't match VMID
        dvm_tlb_op = `CA53_CP_TLBI_VALE1;
      9'b101000000: // Guest non-secure, Don't match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_ALLE1;
      9'b101100000: // Guest non-secure, Match VMID, Don't match ASID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_VMALLS12E1;
      9'b101100010: // Guest non-secure, S1, Match VMID, Don't match ASID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_VMALLE1;
      9'b101100101: // Guest non-secure, S2, Match VMID, IPA, Don't match ASID
        dvm_tlb_op = `CA53_CP_TLBI_IPAS2LE1;
      9'b101101101: // Guest non-secure, S2, LEAF, Match VMID, IPA, Don't match ASID
        dvm_tlb_op = `CA53_CP_TLBI_IPAS2LE1;
      9'b101100001: // Guest non-secure, Match VMID, MVA, Don't match ASID
        dvm_tlb_op = `CA53_CP_TLBI_VAAE1;
      9'b101101001: // Guest non-secure, LEAF, Match VMID, MVA, Don't match ASID
        dvm_tlb_op = `CA53_CP_TLBI_VAALE1;
      9'b101110000: // Guest non-secure, Match ASID, VMID, Don't match MVA
        dvm_tlb_op = `CA53_CP_TLBI_ASIDE1;
      9'b101110001: // Guest non-secure, Match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_VAE1;
      9'b101111001: // Guest non-secure, LEAF, Match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_VALE1;
      9'b111000000: // HYP, Don't match ASID, VMID or MVA
        dvm_tlb_op = `CA53_CP_TLBI_ALLE2;
      9'b111000001: // HYP, Don't match ASID or VMID, Match MVA
        dvm_tlb_op = `CA53_CP_TLBI_VAE2;
      9'b111001001: // HYP, LEAF, Don't match ASID or VMID, Match MVA
        dvm_tlb_op = `CA53_CP_TLBI_VALE2;
      default:  dvm_tlb_op = 5'bxxxxx;  // Other encodings not possible
    endcase

  // Form the address to send to the TLB for DVM operations
  assign tlb_cp_addr = {dvm_addr_first_i[31:24],      // [61:54] VMID       - specified in first packet if valid
                        dvm_addr_first_i[6],          // [53]    VMID valid
                        dvm_addr_first_i[39:32],      // [52:45] ASID       - specified in first packet if valid
                        dvm_addr_first_i[23:16],      // [44:37] ASID       - specified in first packet if valid
                        dvm_addr_first_i[15],         // [36]    MVA[48]    - specified in first packet
                        dvm_addr_first_i[7],          // [35]    MVA[47]    - specified in first packet
                        dvm_addr_first_i[1],          // [34]    MVA[46]    - specified in first packet
                        dvm_addr_first_i[40],         // [33]    MVA[45]    - specified in first packet
                        dvm_addr_second_lo_i[2:0],    // [32:30] MVA[44:42] - specified in second packet if 2nd packet
                        dvm_addr_second_hi_i[40],     // [29]    MVA[41]    - specified in second packet if 2nd packet
                        dvm_addr_second_lo_i[3],      // [28]    MVA[40]    - specified in second packet if 2nd packet
                        dvm_addr_second_hi_i[39:12]}; // [27:0]  MVA[39:12] - specified in second packet if 2nd packet


  //------------------
  // IFU DVM messages
  //------------------

  // Form the virtual I-Cache and physical I-Cache versions separately

  // - Virtual I-Cache DVM
  always @*
    case (dvm_addr_first_i[11:10])
      `CA53_ACE_DVM_OS_BOTH:   dvm_v_ifu_op = `CA53_CP_ICACHE_INV_ALL;
      `CA53_ACE_DVM_OS_GUEST:  dvm_v_ifu_op = dvm_addr_first_i[0] ? `CA53_CP_ICACHE_INV_VA : `CA53_CP_ICACHE_INV_ALL;
      `CA53_ACE_DVM_OS_HYP:    dvm_v_ifu_op = `CA53_CP_ICACHE_INV_VA;
      default: dvm_v_ifu_op = 3'bxxx;
    endcase

  assign v_ifu_cp_addr = {{25{1'b0}},                 // [39:15] Unused
                          dvm_addr_second_hi_i[14:6], // [14:6]  VA[14:6] (specified in second packet)
                          6'b000000};                 // [5:0]   Unused

  // - Physical I-Cache DVM
  assign dvm_p_ifu_op = dvm_addr_first_i[0] ? dvm_addr_first_i[6] ? `CA53_CP_ICACHE_INV_MVA   // Match VA and PA
                                                                  : `CA53_CP_ICACHE_INV_PA    // Match PA but not VA
                                            :                       `CA53_CP_ICACHE_INV_ALL;  // Don't match either

  assign p_ifu_cp_addr = {dvm_addr_second_hi_i[39:15],  // [39:15] PA - specified in second packet if valid
                          dvm_addr_first_i[18:16],      // [14:12] VA - specified in first packet if valid
                          dvm_addr_second_hi_i[11:6],   // [11:6]  Address - specified in second packet if valid
                          3'b000,                       // [5:3]   Unused
                          dvm_addr_second_hi_i[14:12]}; // [2:0]   PA[14:12] - specified in second packet if valid


  //---------------------
  // Interface to lspipe
  //---------------------

  assign dvm_cmd = dvm_addr_first_i[14:12];

  // Requests for the IFU and TLB are sent separately.

  assign tlb_req = inv_all_tlb_req |                      // Make request for invalidate all
                   (dvm_valid_i &                         // or for a DVM request
                    ((dvm_cmd == `CA53_ACE_DVM_TLBINV) |  // - when it is either type of TLB op
                     (dvm_cmd == `CA53_DVM_TLBINV)));

  assign ifu_req = inv_all_ifu_req |                        // Make request for invalidate all
                   (dvm_valid_i &                           // or for a DVM request
                    ((dvm_cmd == `CA53_ACE_DVM_PHYSICINV) | // - when it is any type of IFU op
                     (dvm_cmd == `CA53_ACE_DVM_VIRTICINV) |
                     (dvm_cmd == `CA53_DVM_ICINV)));

  // As the interfaces to the TLB and IFU are shared between DC3 and DVM
  // requests, the lspipe will block the DVM request if there is a local
  // operation using the interface.

  assign dcu_dvm_valid_tlb = tlb_req & ~block_dvm_dc3_i;

  assign dcu_dvm_valid_ifu = ifu_req & ~block_dvm_dc3_i;

  // To prevent a stream of back-to-back local operations blocking DVM
  // requests indefinitely, and to prevent DVM requests being interrupted
  // once they have started, the lspipe will stall new CP15s in DC2 whenever
  // the DVM block is trying to make a request.
  assign dvm_in_progress = ifu_req | tlb_req;

  // The op codes for the TLB and IFU are sent separately, to allow
  // invalidate all on reset command to be sent in parallel.
  assign tlb_cp_op = inv_all_tlb_req ? `CA53_CP_TLBI_ALL_ON_RST // Invalidate all on reset uses normal invalidate all
                                     : dvm_tlb_op;              // Otherwise use internal equivalent of DVM type

  assign ifu_cp_op = inv_all_ifu_req                        ? `CA53_CP_ICACHE_INV_ALL :
                     ((dvm_cmd == `CA53_DVM_ICINV) |
                      (dvm_cmd == `CA53_ACE_DVM_PHYSICINV)) ? dvm_p_ifu_op
                                                            : dvm_v_ifu_op;

  // The address is not required for invalidate all on reset, and as normal
  // DVM requests can only access the TLB and IFU separately, the address
  // can be shared between TLB and IFU requests.
  assign cp_addr = ((dvm_cmd == `CA53_ACE_DVM_TLBINV) |
                    (dvm_cmd == `CA53_DVM_TLBINV))        ? tlb_cp_addr :
                   ((dvm_cmd == `CA53_DVM_ICINV)      |
                    (dvm_cmd == `CA53_ACE_DVM_PHYSICINV)) ? {{22{1'b0}}, p_ifu_cp_addr}
                                                          : {{22{1'b0}}, v_ifu_cp_addr}; // Biased to V IFU addr, as this will toggle least

  // The non-secure state is the same (secure) for both TLB and IFU
  // invalidate on reset, so this can also be shared between requests.
  assign cp_ns = dvm_addr_first_i[8] & ~(inv_all_tlb_req | inv_all_ifu_req); // Force invalidate all requests to be secure

  // Drive the outputs to the lspipe
  assign dcu_dvm_valid_tlb_o  = dcu_dvm_valid_tlb;
  assign dcu_dvm_valid_ifu_o  = dcu_dvm_valid_ifu;
  assign dvm_in_progress_o    = dvm_in_progress;
  assign dvm_tlb_cp_op_o      = tlb_cp_op;
  assign dvm_ifu_cp_op_o      = ifu_cp_op;
  assign dvm_cp_addr_o        = cp_addr;
  assign dvm_ns_o             = cp_ns;


  //---------------------------------------------------------------------------
  // DVM Sync/Complete Tracking Logic
  //---------------------------------------------------------------------------
  // Once a DVM Sync message is received, a DVM Complete must subsequently be
  // issued once the core can ensure that all the required actions of all
  // previous DVM Messages have completed. For BP ops this is trivial, as
  // they have no effect. IFU ops can be considered complete as soon as they
  // are accepted by the IFU, as from this point the IFU prevents any access
  // from hitting on the old data. Therefore, the only DVM Messages requiring
  // special treatment are TLB messages.
  //
  // A TLB DVM Message will retire from the CCB state machine as soon as the
  // request is accepted by the TLB. However, for the operation to be
  // considered complete, as required by a DVM Sync, all memory accesses in
  // the core which could have been using the old page tables must have
  // completed such that after the DVM Complete is sent, it can be guaranteed
  // that there will be no further accesses issued by the core which used the
  // old page tables.
  //
  // To ensure this, the DCU keeps a list of all the outstanding operations
  // in the load/store pipe, the stores in the store buffer, the outstanding
  // linefills in the BIU, the outstanding reqbuffs in the SCU and the
  // outstanding operations which may have used old pagetable values on the
  // I-Side. Once the uTLB is flushed after a TLB DVM Message, indicating that
  // no new accesses can use the old mappings, the DCU takes a snapshot of the
  // outstanding transactions and waits to see them drain. This means that when
  // a DVM Sync is received, the DVM Complete can be sent whenever the list is
  // empty.
  //
  // If a new TLB operation is received whilst the list is still active for
  // a previous operation, then the list is reset to the current state. This
  // introduces a potential for DoS, where a stream of back-to-back TLB
  // invalidates from one core could block the DVM Complete for another. To
  // avoid this, two lists are used:
  // - The main (TLB) list is updated for every TLB DVM operation, as
  //   described
  // - The TLB list is copied onto the second (Sync) list whenever a DVM Sync
  //   is received. This second list is not updated on subsequent TLB
  //   invalidates, ensuring it will always eventually drain.
  //
  // Each core is limited to one outstanding DVM Sync message at a time, but
  // as there can be multiple cores within an ACE system, new DVM Sync
  // messages can be received whilst a previous one is still outstanding. To
  // deal with this, each list has an associated counter. The TLB list
  // counter is incremented for every DVM Sync received. When the TLB counter
  // is set and the Sync list is idle, the state of the TLB list is copied to
  // the Sync list, and the value of the TLB counter is copied to the Sync
  // counter. Whenever the sync list is idle, it issues a DVM Complete at
  // a rate of one per cycle whilst decrementing its counter, until the
  // counter reaches zero.
  //
  // The size of the counter is bound by the maximum number of outstanding
  // DVM Syncs which could be received. There can be up to 256 DVM Syncs
  // received from the external system, in addition to up to 3 from within
  // the cluster, so 9-bit counters are used.
  //
  // The tracking registers use the DCU clock as the registers may be pushed
  // towards the sources they are tracking in synthesis. The counters use the
  // gated clock, as these should not need to be moved away from the DCU.

  //--------------------
  // Detect DuTLB Flush
  //--------------------
  // The D-Side uTLB is normally flushed for a TLB DVM Message on the cycle
  // after the ack is received from the TLB. This means that the instruction
  // in DC1 on the cycle the ack is received will be the last one to hit in
  // the uTLB on an old page. If there is an ongoing burst however, then the
  // flush is delayed until the burst completes. Therefore, the lists should
  // continue to be updated with new operations entering the load/store pipe
  // until the ongoing burst completes.
  //
  // If a flush is pending when the Sync list is set, then it should also
  // continue to update, however if a flush for a subsequent operation is
  // delayed by an ongoing burst, then this should not affect the Sync list.
  // Therefore, two versions of the flush pending signal are required: one
  // which indicates whenever a flush is pending, and one which indicates
  // when a flush is pending which should affect the sync list.
  //
  // Note that flush_pending is always set on the first cycle after a TLB
  // transaction is acked. This is because if ongoing_flush becomes asserted
  // on that cycle, it will still defer the flush.
  assign next_flush_pending      = dvm_tlb_done | (flush_pending & dcu_ongoing_burst_dc1_i);

  assign next_flush_pending_sync = dcu_ongoing_burst_dc1_i &
                                   (set_sync_list ? flush_pending
                                                  : flush_pending_sync);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      flush_pending      <= 1'b0;
      flush_pending_sync <= 1'b0;
    end else begin
      flush_pending      <= next_flush_pending;
      flush_pending_sync <= next_flush_pending_sync;
    end


  //----------
  // TLB List
  //----------
  // When the list of DCU operations is set, either because of a new ack, or
  // because of a pending flush which is being deferred, the operations to
  // track are the ones which will be valid in load/store pipe on the next
  // cycle and may have used the old TLB mappings. Any new operations
  // entering the load/store pipe on a cycle when the list is being set can
  // not use the old mappings, as if the uTLB is flushed on the next cycle
  // the hit for the new operation (in DC1) will be suppressed. Therefore,
  // DC1 operations are only tracked once they stall in DC1, or move to DC2.
  //
  // Note that DSBs are ignored, which is necessary to avoid deadlock, and
  // valid because they have no associated address translation.
  assign dcu_ops_initial = {v_enable_dc1_i ? 1'b0                           // New ops entering DC1 this cycle will use new mapping if flush asserted on next cycle
                                           : valid_dc1_i      & ~dsb_dc1_i, // Track if stalled in DC1
                            v_enable_dc2_i ? next_valid_dc2_i & ~dsb_dc1_i  // Only track if DC1 moving into DC2 (i.e. not being flushed/cc failed etc)
                                           : valid_dc2_i      & ~dsb_dc2_i,
                            v_enable_dc3_i ? next_valid_dc3_i & ~dsb_dc2_i
                                           : valid_dc3_i      & ~dsb_dc3_i};

  // Generate "track" values - i.e. values used when tracking the ops on
  // the list

  // - For DCU ops, continue to track new ops entering the pipeline until the
  // uTLB flush is applied. Then track the ops leaving the pipeline, either
  // because they complete or are flushed.
  assign tlb_list_dcu_ops_track   = flush_pending
                                    ? dcu_ops_initial
                                    : {v_enable_dc1_i ? 1'b0                                    // Don't track new ops entering DC1
                                                      : tlb_list_dcu_ops[2],
                                       v_enable_dc2_i ? next_valid_dc2_i & tlb_list_dcu_ops[2]  // Only track DC1 into DC2 if not being flushed
                                                      : tlb_list_dcu_ops[1],
                                       v_enable_dc3_i ? next_valid_dc3_i & tlb_list_dcu_ops[1]
                                                      : tlb_list_dcu_ops[0]};

  // - Continue to track new STB slots until the load/store pipe has drained,
  // as stores in the load/store pipe being tracked need to be tracked
  // through the STB. Note that slots containing DSBs are ignored, to avoid
  // deadlock in the same way as DSBs in the load/store pipe.
  // - Note that load/store tracking registers are cycle accurate (i.e. they
  // are tracked as being in DC1 on the cycle they are actually in DC1,
  // etc.), but STB slots are tracked a cycle behind (i.e. a slot is tracked
  // for an extra cycle after it is cleared). This means that on the cycle
  // a store leaves DC3, it will stop being tracked in the DCU on the next
  // cycle, but will not appear in the STB until then. Therefore, all slots
  // are forced to be tracked when there are still things in the load/store
  // pipe, to ensure that if something leaves the load/store pipe and enters
  // the STB that it is still picked up on the next cycle. Any slots which
  // should not be tracked will be resolved on the subsequent cycle.
  assign tlb_list_stb_slots_track  = (|tlb_list_dcu_ops) ? 5'b11111
                                                         : tlb_list_stb_slots & stb_slots_valid_i & ~stb_slots_dsb_i;

  // - Continue to track new linefills in the BIU until the STB has drained, as
  // this also implies that the load/store pipe has drained, and so no new
  // linefills can be started by loads, stores or PLDs.
  assign tlb_list_lfbs_track   = ((|tlb_list_stb_slots) | tlb_list_resample_lfbs)  ? biu_lf_in_progress_i
                                                                                   : tlb_list_lfbs & biu_lf_in_progress_i;

  // - Track outstanding prefetch streams from the point the DCU, STB and BIU
  // have drained, then when all tracked prefetch streams are completing,
  // re-sample the linefills in the BIU to track any new linefills started by
  // prefetches.
  // - Force all set while waiting for initial drain of DCU, STB and BIU, so can
  // detect when PFs which will ultimately be tracked have drained, so know when
  // to resample linefills
  assign tlb_list_dcu_stb_lf_outstanding = (|tlb_list_dcu_ops) | (|tlb_list_stb_slots) | 
                                           // Only look at LFs when not seen PFs drain yet
                                           ((|tlb_list_lfbs) & (|tlb_list_pfs));

  assign tlb_list_pfs_track = tlb_list_dcu_stb_lf_outstanding ? 4'b1111
                                                              : tlb_list_pfs & biu_pf_in_progress_i;

  assign tlb_list_resample_lfbs = (|tlb_list_pfs) & (~|tlb_list_pfs_track);

  // - Continue to track new reqbuffs in the SCU until the STB has drained, as
  // reqbuffs can be allocated by STB requests and remain busy after the slot
  // has drained.
  assign tlb_list_reqbuffs_track = (|tlb_list_stb_slots) ? scu_reqbufs_busy_i
                                                         : tlb_list_reqbuffs & scu_reqbufs_busy_i;

  // - New I-Side accesses are tracked until the TLB indicates that it has
  // completed the invalidated pagewalk, at which point it will flush the
  // IuTLB.
  assign tlb_list_pw_inv_track = tlb_list_pw_inv & tlb_pagewalk_invalidated_i;

  // - The IuTLB flush does not happen until the cycle after
  // tlb_pagewalk_invalidated goes low, so on the cycle it goes low assume
  // that something will enter IF2 on the next cycle. This will be resolved
  // on the subsequent cycle if this is not the case.
  assign tlb_list_ifu_track = tlb_list_pw_inv ? 1'b1  // Assume will become set next cycle
                                              : tlb_list_ifu & ifu_valid_if2_i;

  // - Track I-Side accesses in the BIU as long as tracking instructions in
  // the IFU.
  assign tlb_list_biu_ifu_track = tlb_list_ifu ? ifu_outstanding_lfb_i
                                               : tlb_list_biu_ifu & ifu_outstanding_lfb_i;

  // TLB List registers
  // - A DVM TLB operation is done whenever there is an ack whilst a TLB DVM
  // message is valid. This does not apply to TLB invalidate on reset
  // operations, but the done signal is forced on the first cycle after
  // reset, which causes the list to sample the system whilst it is idle,
  // which has the effect of synchronously resetting the list.
  assign dvm_tlb_done = dcu_dvm_valid_tlb & ~inv_all_tlb_req & tlb_cp_ack_i | force_reset_i;

  assign next_tlb_list_dcu_ops      = dvm_tlb_done ? dcu_ops_initial                 : tlb_list_dcu_ops_track;
  // - stb_slots_valid may become set on cycle after ack for a store leaving DC3 on same cycle as ack, so set
  // to all slots to ensure track in next cycle.
  assign next_tlb_list_stb_slots    = dvm_tlb_done ? 5'b11111                        : tlb_list_stb_slots_track;
  assign next_tlb_list_lfbs         = dvm_tlb_done ? biu_lf_in_progress_i            : tlb_list_lfbs_track;
  assign next_tlb_list_pfs          = dvm_tlb_done ? 4'b1111                         : tlb_list_pfs_track;
  assign next_tlb_list_reqbuffs     = dvm_tlb_done ? scu_reqbufs_busy_i              : tlb_list_reqbuffs_track;
  assign next_tlb_list_pw_inv       = dvm_tlb_done ? tlb_pagewalk_invalidated_i      : tlb_list_pw_inv_track;
  // - ifu_valid_if2 may become set on cycle after ack for an instruction which should be tracked, so set to 1
  // on ack to ensure track in next cycle.
  assign next_tlb_list_ifu          = dvm_tlb_done ? ~force_reset_i                  : tlb_list_ifu_track;
  assign next_tlb_list_biu_ifu      = dvm_tlb_done ? ifu_outstanding_lfb_i           : tlb_list_biu_ifu_track;

  assign tlb_list_en = dvm_tlb_done | tlb_list; // Enable to set or track

  always @(posedge clk)
    if (tlb_list_en) begin
      tlb_list_dcu_ops      <= next_tlb_list_dcu_ops;
      tlb_list_stb_slots    <= next_tlb_list_stb_slots;
      tlb_list_lfbs         <= next_tlb_list_lfbs;
      tlb_list_pfs          <= next_tlb_list_pfs;
      tlb_list_reqbuffs     <= next_tlb_list_reqbuffs;
      tlb_list_pw_inv       <= next_tlb_list_pw_inv;
      tlb_list_ifu          <= next_tlb_list_ifu;
      tlb_list_biu_ifu      <= next_tlb_list_biu_ifu;
    end

  // The TLB List is always marked as active when an ongoing burst is deferring
  // the uTLB flush, even if there are no ops currently being tracked. This
  // is because new ops could enter the load/store pipeline as part of
  // the burst and so need to be tracked, even if the pipeline is currently
  // empty. Otherwise, it is marked as active whenever there are outstanding
  // operations being tracked.
  // - Note that whenever tlb_list_pw_inv is set, tlb_list_ifu must also be
  // set, so tlb_list_pw_inv does not need factoring in.
  // - By the same token, whenever tlb_list_stb_slots is set, tlb_list_pfs must
  // be set, so this do not need factoring in.
  assign tlb_list = flush_pending             |
                    (|tlb_list_lfbs)          |
                    (|tlb_list_dcu_ops)       |
                    (|tlb_list_pfs)           |
                    (|tlb_list_reqbuffs)      |
                    tlb_list_ifu              |
                    (|tlb_list_biu_ifu);

  //-----------
  // Sync List
  //-----------
  // The Sync list is set whenever the TLB counter is non-zero, indicating an
  // outstanding DVM Sync, and the Sync list is not active.

  assign dvm_sync = dvm_valid_i & (dvm_cmd == `CA53_ACE_DVM_SYNC);

  // Generate track values - these are defined in the same way as the TLB
  // list track values, but set off the Sync list/flush pending signals.

  assign sync_list_dcu_ops_track = flush_pending_sync
                                   ? dcu_ops_initial
                                   : {v_enable_dc1_i ? 1'b0
                                                     : sync_list_dcu_ops[2],
                                      v_enable_dc2_i ? next_valid_dc2_i & sync_list_dcu_ops[2]
                                                     : sync_list_dcu_ops[1],
                                      v_enable_dc3_i ? next_valid_dc3_i & sync_list_dcu_ops[1]
                                                     : sync_list_dcu_ops[0]};

  assign sync_list_stb_slots_track = (|sync_list_dcu_ops) ? 5'b11111
                                                          : sync_list_stb_slots & stb_slots_valid_i & ~stb_slots_dsb_i;

  assign sync_list_lfbs_track   = ((|sync_list_stb_slots) | sync_list_resample_lfbs)  ? biu_lf_in_progress_i
                                                                                      : sync_list_lfbs & biu_lf_in_progress_i;

  assign sync_list_dcu_stb_lf_outstanding = (|sync_list_dcu_ops) | (|sync_list_stb_slots) | ((|sync_list_lfbs) & (|sync_list_pfs));

  assign sync_list_pfs_track = sync_list_dcu_stb_lf_outstanding ? 4'b1111
                                                                : sync_list_pfs & biu_pf_in_progress_i;

  assign sync_list_resample_lfbs = (|sync_list_pfs) & (~|sync_list_pfs_track);

  assign sync_list_reqbuffs_track = (|sync_list_stb_slots) ? scu_reqbufs_busy_i
                                                           : sync_list_reqbuffs & scu_reqbufs_busy_i;

  assign sync_list_pw_inv_track = sync_list_pw_inv & tlb_pagewalk_invalidated_i;

  assign sync_list_ifu_track = sync_list_pw_inv ? 1'b1
                                                : sync_list_ifu & ifu_valid_if2_i;

  assign sync_list_biu_ifu_track = sync_list_ifu ? ifu_outstanding_lfb_i
                                                 : sync_list_biu_ifu & ifu_outstanding_lfb_i;

  // Sync list registers
  // - set by either track values, or next tlb values if being set (from TLB list).
  // The tlb_track signals are used, rather than the next_tlb signals, as a new
  // ack in the cycle the list is copied need only update TLB list, as it must be
  // later than the Sync which has resulted in the list being copied.

  assign next_sync_list_dcu_ops      = set_sync_list ? tlb_list_dcu_ops_track      : sync_list_dcu_ops_track;
  assign next_sync_list_stb_slots    = set_sync_list ? tlb_list_stb_slots_track    : sync_list_stb_slots_track;
  assign next_sync_list_lfbs         = set_sync_list ? tlb_list_lfbs_track         : sync_list_lfbs_track;
  assign next_sync_list_pfs          = set_sync_list ? tlb_list_pfs_track          : sync_list_pfs_track;
  assign next_sync_list_reqbuffs     = set_sync_list ? tlb_list_reqbuffs_track     : sync_list_reqbuffs_track;
  assign next_sync_list_pw_inv       = set_sync_list ? tlb_list_pw_inv_track       : sync_list_pw_inv_track;
  assign next_sync_list_ifu          = set_sync_list ? tlb_list_ifu_track          : sync_list_ifu_track;
  assign next_sync_list_biu_ifu      = set_sync_list ? tlb_list_biu_ifu_track      : sync_list_biu_ifu_track;

  // - set Sync list when it is either empty, or emptying this cycle, and
  // there is a new Sync, or the TLB list counter has been used (implying
  // a sync arrived that couldn't use the sync list as it was already in use
  // for an earlier sync). By setting the list immediately for a new Sync
  // when the list is idle, the TLB counter can be bypassed in this case.

  assign next_sync_list_empty = (~|sync_list_count[8:1]) &  // 1 or 0
                                (~sync_list_count[0] |      // 0
                                 ~sync_list);               // or if 1, would be zero next cycle as counting down

  assign set_sync_list = next_sync_list_empty &           // Sync list can be updated
                         (dvm_sync | (|tlb_list_count));  // and there is a Sync, or TLB counter has been used

  // - enable to set or track
  assign sync_list_en = set_sync_list | (|sync_list_count);

  always @(posedge clk)
    if (sync_list_en) begin
      sync_list_dcu_ops      <= next_sync_list_dcu_ops;
      sync_list_stb_slots    <= next_sync_list_stb_slots;
      sync_list_lfbs         <= next_sync_list_lfbs;
      sync_list_pfs          <= next_sync_list_pfs;
      sync_list_reqbuffs     <= next_sync_list_reqbuffs;
      sync_list_pw_inv       <= next_sync_list_pw_inv;
      sync_list_ifu          <= next_sync_list_ifu;
      sync_list_biu_ifu      <= next_sync_list_biu_ifu;
    end

  // The Sync list is marked as active using the same rules as the TLB list.
  assign sync_list = flush_pending_sync         |
                     (|sync_list_lfbs)          |
                     (|sync_list_dcu_ops)       |
                     (|sync_list_pfs)           |
                     (|sync_list_reqbuffs)      |
                     sync_list_ifu              |
                     (|sync_list_biu_ifu);


  //-------------
  // TLB Counter
  //-------------

  // The increment value is the current value incremented by one if there is
  // a Sync. This is used to update the TLB counter, and also set the Sync
  // counter when the TLB list is copied onto the Sync list. In this case it
  // will normally take the current value of the TLB counter, unless there is
  // a Sync in the same cycle, in which case the new Sync can use the Sync list
  // counter, as the conditions for it to move to the Sync list counter are
  // being met this cycle (as the list is being copied, and there can't be
  // a newer TLB operation).
  assign tlb_list_count_incd = (tlb_list_count + {8'b00000000, dvm_sync});

  // The TLB counter is always cleared when copying (i.e. next_sync_list_empty
  // asserted), as a Sync in the cycle it is copied will update the Sync list counter,
  // rather than the TLB list counter. This allows new Syncs to bypass the
  // TLB list completely when a new Sync is received and the Sync list is
  // empty.
  assign next_tlb_list_count = {9{dvm_sync & ~next_sync_list_empty}} & tlb_list_count_incd; // dvm_sync is zero on reset, so can use to initialise

  assign tlb_list_count_en = force_reset_i |                              // Enable on reset to initialise
                             (dvm_sync & ~next_sync_list_empty) |         // Enable to increment when new Sync can't use Sync list
                             (next_sync_list_empty & (|tlb_list_count));  // Enable to clear when copying counter into Sync counter

  always @(posedge clk_ccb)
    if (tlb_list_count_en)
      tlb_list_count <= next_tlb_list_count;


  //--------------
  // Sync Counter
  //--------------

  // If setting, then will set to TLB list counter, unless there is a Sync
  // this cycle, in which case will use TLB list counter + 1, so use
  // tlb_list_count_incd. If setting because of a Sync which isn't having to
  // use the TLB counter, as both counters are empty, then the tlb counter
  // must be zero, so tlb_list_count_incd must be 1.
  assign next_sync_list_count = force_reset_i        ? 9'b000000000 : // Force to zero on reset to initialise
                                next_sync_list_empty ? tlb_list_count_incd
                                                     : (sync_list_count - 9'b000000001);

  assign sync_list_count_en = force_reset_i |                     // Enable on reset to initialise
                              (~sync_list & (|sync_list_count)) | // Enable when non-zero and list empty, to count down
                              set_sync_list;                      // Enable when zero and new Sync, or copying TLB count, to set

  always @(posedge clk_ccb)
    if (sync_list_count_en)
      sync_list_count <= next_sync_list_count;


  //--------------
  // DVM Complete
  //--------------
  // A DVM Complete is issued every cycle that the Sync list is empty, but
  // the Sync counter is non-zero. This results in one DVM Complete being
  // issued per DVM Sync received.
  // This signal is registered to improve timing to the SCU at the top
  // level.
  assign next_dvm_complete = ~sync_list & (|sync_list_count) & ~force_reset_i; // List/Count are X until reset forced

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      dcu_dvm_complete_o <= 1'b0;
    else
      dcu_dvm_complete_o <= next_dvm_complete;


  //---------------------------------------------------------------------------
  // Outputs to other blocks
  //---------------------------------------------------------------------------

  // Indicate when the counters are non-zero, as the counters draining
  // could be the last thing that happens in the core before WFx can be
  // entered.
  // - The lists themselves do not need factoring in, as the core will not be
  // allowed to go into WFx until all other blocks are empty.
  // - The TLB list counter does not need factoring in, as that will only be
  // used when the sync list counter is set, and will be copied on to the
  // sync list counter before it goes to idle. Therefore whenever the TLB
  // list counter is set, the sync list counter must also be set.
  assign sync_lists_active_o = ~force_reset_i & (sync_list_count != 9'b000000000);

  // Indicate when a DVM Message is complete, so the CCB state machine can
  // retire the operation. Note that this is only valid when there is a DVM
  // transaction in progress, and the CCB state machine should not look at it
  // at any other time.
  assign dvm_is_done_o = (dcu_dvm_valid_tlb & tlb_cp_ack_i) | // TLB op done when indicated by TLB
                         (dcu_dvm_valid_ifu & ifu_cp_ack_i) | // IFU op done when indicated by IFU
                         ~(tlb_req | ifu_req);                // Other ops complete immediately

  // - Indicate when a sync is no longer waiting on any tracked DCU ops, and
  // is waiting on tracked STB slots, so that the BIU can prioritise any STB
  // linefill requests over DCU requests.
  assign dcu_drain_stb_lf_o = (~|sync_list_dcu_ops) & (|sync_list_stb_slots) & (|sync_list_count);

  // - Stop the BIU prefetching if waiting for an LFB to go idle. This is
  // combined with ls_stop_pf in the DCU top level to form the dcu_stop_pf
  // signal to the BIU.
  assign dvm_stop_pf_o = (sync_list_count != 9'b000000000) & ~force_reset_i & ((|sync_list_lfbs) | (|sync_list_pfs));

  // STB
  // - Indicate which slots are being tracked, so that the STB can prioritise
  // draining them.
  assign dcu_drain_slots_o = sync_list_stb_slots & {5{|sync_list_count}};


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------
  // DVM properties
  //----------------

  // It is never possible to get a TLB done on the same cycle as a DVM Sync,
  // as the Sync should not be accepted until after the TLB done is received.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "TLB Done and DVM Sync should be mutually exclusive")
  u_ovl_tlb_done_sync_ex (.clk             (clk),
                          .reset_n         (reset_n),
                          .test_expr       (dvm_tlb_done & dvm_sync));

  // When a DVM sync is received, it must update one of the counters (it is
  // possible for both counters to be enabled at the same time, if the sync
  // list counter is counting down).
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A DVM Sync should update a counter")
  u_ovl_sync_updates_counter (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (dvm_sync),
                              .consequent_expr (sync_list_count_en | tlb_list_count_en));

  // Both counters cannot be set at the same time (but sync counter can count
  // down at the same time as the tlb counter is set).
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "TLB counter should only be updated when sync counter not being used, or counting down")
  u_ovl_counter_update_excl  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tlb_list_count_en &                     // When counter enabled
                                                ~force_reset_i &                        // Not to be initialised
                                                (next_tlb_list_count != 9'b000000000)), // and not to be cleared
                              .consequent_expr (~sync_list_count_en |                   // - Sync list counter must not be being updated
                                                (next_sync_list_count ==                // - or must be counting down
                                                 (sync_list_count - 9'b000000001))));

  // TLB list counter can only be non-zero when Sync list counter non-zero.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A DVM Sync should update a counter")
  u_ovl_tlb_list_sync_list   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (~force_reset_i & (tlb_list_count != 9'b000000000)),
                              .consequent_expr (sync_list_count != 9'b000000000));

  // The ifu_valid_if2 tracking bits are set at the same time as the pagewalk
  // invalidated tracking bits, and keep getting set until pagewalk
  // invalidated stops being tracked. Therefore, each ifu_valid_if2 tracking
  // bit should always be set when the corresponding pagewalk invalidated
  // tracking bit is set.
  // - TLB list
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "tlb_list_ifu always set when tlb_list_pw_inv set")
  u_ovl_tlb_list_ifu_pw_inv  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (~force_reset_i & tlb_list_pw_inv),
                              .consequent_expr (tlb_list_ifu));

  // - Sync list
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "sync_list_ifu always set when sync_list_pw_inv set")
  u_ovl_sync_list_ifu_pw_inv (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (~force_reset_i & (sync_list_count != 9'b000000000) & sync_list_pw_inv),
                              .consequent_expr (sync_list_ifu));

  // The biu_pf_in_progress tracking bits are forced to all set when DCU or STB
  // ops are being tracked, so do not need to factor the DCU and STB signals
  // into the tlb_list/sync_list.
  // - TLB list
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "tlb_list_pfs always set when tlb_list_dcu_ops or tlb_list_stb_slots set")
  u_ovl_tlb_list_pf_dcu_stb  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (~force_reset_i & (|tlb_list_stb_slots)),
                              .consequent_expr (|tlb_list_pfs));

  // - Sync list
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "sync_list_pfs always set when sync_list_dcu_ops or sync_list_stb_slots set")
  u_ovl_sync_list_pf_dcu_stb (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (~force_reset_i & (sync_list_count != 9'b000000000) & (|sync_list_stb_slots)),
                              .consequent_expr (|sync_list_pfs));

  // When the sync counter is set, it can only count down until it reaches
  // zero, or until the cycle when it is about to become zero.
  reg [8:0] ovl_prev_sync_list_count;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_prev_sync_list_count <= 9'b000000000;
    else
      ovl_prev_sync_list_count <= sync_list_count;

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Sync list counter should only count down when it is set")
  u_ovl_utlb_flush_hit_suppress    (.clk         (clk),
                                    .reset_n     (reset_n),
                                    .start_event ((sync_list_count[8:1] != 8'b00000000) |   // count > 1
                                                  (sync_list_count[0] & ~set_sync_list)),   // or count == 1 and not being updated
                                    .test_expr   (sync_list_count <= ovl_prev_sync_list_count));

  // The sync list should never be set when it is active
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should not be set whilst active")
  u_ovl_sync_list_set_active (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (set_sync_list),
                              .consequent_expr ((sync_list_count == 9'b000000000) | ((sync_list_count == 9'b000000001) & ~sync_list)));

  // Neither sync counter should ever have a value greater than the maximum
  // number of outstanding syncs (256 + 3).
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list counter should always be less than or equal to (256 +3 )")
  u_ovl_sync_list_count_max  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (sync_list_count > 0),
                              .consequent_expr (sync_list_count <= 9'd259));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "TLB list counter should always be less than or equal to (256 +3 )")
  u_ovl_tlb_list_count_max   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tlb_list),
                              .consequent_expr (tlb_list_count <= 9'd259));

  // The sync list should never be updated when it is in use, so once an op
  // completes, that entry on the list cannot become set again until all the
  // DVM Completes on the sync list have been issued.
  reg       ovl_prev_flush_pending_sync;
  reg [2:0] ovl_prev_sync_list_dcu_ops;
  reg [4:0] ovl_prev_sync_list_stb_slots;
  reg [7:0] ovl_prev_sync_list_lfbs;
  reg [3:0] ovl_prev_sync_list_pfs;
  reg [7:0] ovl_prev_sync_list_reqbuffs;
  reg       ovl_prev_sync_list_pw_inv;
  reg       ovl_prev_sync_list_ifu;
  reg [2:0] ovl_prev_sync_list_biu_ifu;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prev_flush_pending_sync     <= 1'b0;
      ovl_prev_sync_list_dcu_ops      <= 3'b000;
      ovl_prev_sync_list_stb_slots    <= 5'b00000;
      ovl_prev_sync_list_lfbs         <= 8'b00000000;
      ovl_prev_sync_list_pfs          <= 4'b0000;
      ovl_prev_sync_list_reqbuffs     <= 8'b00000000;
      ovl_prev_sync_list_pw_inv       <= 1'b0;
      ovl_prev_sync_list_ifu          <= 1'b0;
      ovl_prev_sync_list_biu_ifu      <= 3'b000;
    end else if (set_sync_list) begin
      // Initialise to same value as main regs when setting list
      ovl_prev_flush_pending_sync     <= next_flush_pending_sync;
      ovl_prev_sync_list_dcu_ops      <= next_sync_list_dcu_ops;
      ovl_prev_sync_list_stb_slots    <= next_sync_list_stb_slots;
      ovl_prev_sync_list_lfbs         <= next_sync_list_lfbs;
      ovl_prev_sync_list_pfs          <= next_sync_list_pfs;
      ovl_prev_sync_list_reqbuffs     <= next_sync_list_reqbuffs;
      ovl_prev_sync_list_pw_inv       <= next_sync_list_pw_inv;
      ovl_prev_sync_list_ifu          <= next_sync_list_ifu;
      ovl_prev_sync_list_biu_ifu      <= next_sync_list_biu_ifu;
    end else begin
      // Then record previous
      ovl_prev_flush_pending_sync     <= flush_pending_sync;
      ovl_prev_sync_list_dcu_ops      <= sync_list_dcu_ops;
      ovl_prev_sync_list_stb_slots    <= sync_list_stb_slots;
      ovl_prev_sync_list_lfbs         <= sync_list_lfbs;
      ovl_prev_sync_list_pfs          <= sync_list_pfs;
      ovl_prev_sync_list_reqbuffs     <= sync_list_reqbuffs;
      ovl_prev_sync_list_pw_inv       <= sync_list_pw_inv;
      ovl_prev_sync_list_ifu          <= sync_list_ifu;
      ovl_prev_sync_list_biu_ifu      <= sync_list_biu_ifu;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to sync list after it is set (DCU ops - DC1)")
  u_ovl_sync_list_clear_dc1  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((|sync_list_count) & ~ovl_prev_flush_pending_sync & sync_list_dcu_ops[2]),
                              // DC1 can only clear:
                              .consequent_expr (ovl_prev_sync_list_dcu_ops[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to sync list after it is set (DCU ops - DC2)")
  u_ovl_sync_list_clear_dc2  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((|sync_list_count) & ~ovl_prev_flush_pending_sync & sync_list_dcu_ops[1]),
                              // DC2 can clear or become set from DC1:
                              .consequent_expr (ovl_prev_sync_list_dcu_ops[1] | ovl_prev_sync_list_dcu_ops[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to sync list after it is set (DCU ops - DC3)")
  u_ovl_sync_list_clear_dc3  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((|sync_list_count) & ~ovl_prev_flush_pending_sync & sync_list_dcu_ops[0]),
                              // DC3 can clear or become set from DC2:
                              .consequent_expr (ovl_prev_sync_list_dcu_ops[0] | ovl_prev_sync_list_dcu_ops[1]));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (STB slots)")
  u_ovl_sync_list_clear_stb  (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((sync_list_dcu_ops == 3'b000) & (|sync_list_count)),
                              .test_expr       ((sync_list_stb_slots | ovl_prev_sync_list_stb_slots) == ovl_prev_sync_list_stb_slots));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (BIU LFBs)")
  u_ovl_sync_list_clear_lfb  (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((sync_list_stb_slots == 5'b00000) & (sync_list_pfs == 4'b0000) & (|sync_list_count)),
                              .test_expr       ((sync_list_lfbs | ovl_prev_sync_list_lfbs) == ovl_prev_sync_list_lfbs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (BIU PFs)")
  u_ovl_sync_list_clear_pf   (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (~sync_list_dcu_stb_lf_outstanding & (|sync_list_count)),
                              .test_expr       ((sync_list_pfs | ovl_prev_sync_list_pfs) == ovl_prev_sync_list_pfs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (SCU reqbuffs)")
  u_ovl_sync_list_clear_scu  (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((sync_list_stb_slots == 5'b00000) & (|sync_list_count)),
                              .test_expr       ((sync_list_reqbuffs | ovl_prev_sync_list_reqbuffs) == ovl_prev_sync_list_reqbuffs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (Pagewalk Invalidated)")
  u_ovl_sync_list_clear_pinv (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (|sync_list_count),
                              .test_expr       ((sync_list_pw_inv | ovl_prev_sync_list_pw_inv) == ovl_prev_sync_list_pw_inv));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (IFU)")
  u_ovl_sync_list_clear_ifu  (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (~sync_list_pw_inv & (|sync_list_count)),
                              .test_expr       ((sync_list_ifu | ovl_prev_sync_list_ifu) == ovl_prev_sync_list_ifu));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to sync list after it is set (BIU IFU Outstanding)")
  u_ovl_sync_list_clear_ifu_biu  (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .start_event     ((sync_list_ifu == 3'b000) & (|sync_list_count)),
                                  .test_expr       ((sync_list_biu_ifu | ovl_prev_sync_list_biu_ifu) == ovl_prev_sync_list_biu_ifu));

  // The TLB list should only be updated when there is a TLB ack.
  reg       ovl_prev_dvm_tlb_done;
  reg       ovl_prev_flush_pending;
  reg [2:0] ovl_prev_tlb_list_dcu_ops;
  reg [4:0] ovl_prev_tlb_list_stb_slots;
  reg [7:0] ovl_prev_tlb_list_lfbs;
  reg [3:0] ovl_prev_tlb_list_pfs;
  reg [7:0] ovl_prev_tlb_list_reqbuffs;
  reg       ovl_prev_tlb_list_pw_inv;
  reg       ovl_prev_tlb_list_ifu;
  reg [2:0] ovl_prev_tlb_list_biu_ifu;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prev_dvm_tlb_done          <= 1'b0;
      ovl_prev_flush_pending         <= 1'b0;
      ovl_prev_tlb_list_dcu_ops      <= 3'b000;
      ovl_prev_tlb_list_stb_slots    <= 5'b00000;
      ovl_prev_tlb_list_lfbs         <= 8'h00;
      ovl_prev_tlb_list_pfs          <= 4'h0;
      ovl_prev_tlb_list_reqbuffs     <= 8'h00;
      ovl_prev_tlb_list_pw_inv       <= 1'b0;
      ovl_prev_tlb_list_ifu          <= 1'b0;
      ovl_prev_tlb_list_biu_ifu      <= 3'b000;
    end else if (dvm_tlb_done) begin
      // Initialise to same value as main regs when setting list
      ovl_prev_dvm_tlb_done          <= 1'b1;
      ovl_prev_flush_pending         <= next_flush_pending;
      ovl_prev_tlb_list_dcu_ops      <= next_tlb_list_dcu_ops;
      ovl_prev_tlb_list_stb_slots    <= next_tlb_list_stb_slots;
      ovl_prev_tlb_list_lfbs         <= next_tlb_list_lfbs;
      ovl_prev_tlb_list_pfs          <= next_tlb_list_pfs;
      ovl_prev_tlb_list_reqbuffs     <= next_tlb_list_reqbuffs;
      ovl_prev_tlb_list_pw_inv       <= next_tlb_list_pw_inv;
      ovl_prev_tlb_list_ifu          <= next_tlb_list_ifu;
      ovl_prev_tlb_list_biu_ifu      <= next_tlb_list_biu_ifu;
    end else begin
      // Then record previous
      ovl_prev_dvm_tlb_done          <= dvm_tlb_done;
      ovl_prev_flush_pending         <= flush_pending;
      ovl_prev_tlb_list_dcu_ops      <= tlb_list_dcu_ops;
      ovl_prev_tlb_list_stb_slots    <= tlb_list_stb_slots;
      ovl_prev_tlb_list_lfbs         <= tlb_list_lfbs;
      ovl_prev_tlb_list_pfs          <= tlb_list_pfs;
      ovl_prev_tlb_list_reqbuffs     <= tlb_list_reqbuffs;
      ovl_prev_tlb_list_pw_inv       <= tlb_list_pw_inv;
      ovl_prev_tlb_list_ifu          <= tlb_list_ifu;
      ovl_prev_tlb_list_biu_ifu      <= tlb_list_biu_ifu;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (DCU ops - DC1)")
  u_ovl_tlb_list_clear_dc1   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tlb_list & ~ovl_prev_flush_pending & ~ovl_prev_dvm_tlb_done & tlb_list_dcu_ops[2]),
                              // DC1 can only clear:
                              .consequent_expr (ovl_prev_tlb_list_dcu_ops[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (DCU ops - DC2)")
  u_ovl_tlb_list_clear_dc2   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tlb_list & ~ovl_prev_flush_pending & ~ovl_prev_dvm_tlb_done & tlb_list_dcu_ops[1]),
                              // DC2 can clear or become set from DC1:
                              .consequent_expr (ovl_prev_tlb_list_dcu_ops[1] | ovl_prev_tlb_list_dcu_ops[2]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (DCU ops - DC3)")
  u_ovl_tlb_list_clear_dc3   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (tlb_list & ~ovl_prev_flush_pending & ~ovl_prev_dvm_tlb_done & tlb_list_dcu_ops[0]),
                              // DC3 can clear or become set from DC2:
                              .consequent_expr (ovl_prev_tlb_list_dcu_ops[0] | ovl_prev_tlb_list_dcu_ops[1]));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (STB slots)")
  u_ovl_tlb_list_clear_stb   (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((tlb_list_dcu_ops == 3'b000) & ~dvm_tlb_done),
                              .test_expr       ((tlb_list_stb_slots | ovl_prev_tlb_list_stb_slots) == ovl_prev_tlb_list_stb_slots));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (BIU LFBs)")
  u_ovl_tlb_list_clear_lfb   (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((tlb_list_stb_slots == 5'b00000) & (tlb_list_pfs == 4'b0000) & ~dvm_tlb_done),
                              .test_expr       ((tlb_list_lfbs | ovl_prev_tlb_list_lfbs) == ovl_prev_tlb_list_lfbs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (BIU PFs)")
  u_ovl_tlb_list_clear_pf    (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (~tlb_list_dcu_stb_lf_outstanding & ~dvm_tlb_done),
                              .test_expr       ((tlb_list_pfs | ovl_prev_tlb_list_pfs) == ovl_prev_tlb_list_pfs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (SCU reqbuffs)")
  u_ovl_tlb_list_clear_scu   (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     ((tlb_list_stb_slots == 5'b00000) & ~dvm_tlb_done),
                              .test_expr       ((tlb_list_reqbuffs | ovl_prev_tlb_list_reqbuffs) == ovl_prev_tlb_list_reqbuffs));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (Pagewalk Invalidated)")
  u_ovl_tlb_list_clear_pinv  (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (~dvm_tlb_done),
                              .test_expr       ((tlb_list_pw_inv | ovl_prev_tlb_list_pw_inv) == ovl_prev_tlb_list_pw_inv));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (IFU)")
  u_ovl_tlb_list_clear_ifu   (.clk             (clk),
                              .reset_n         (reset_n),
                              .start_event     (~tlb_list_pw_inv & ~dvm_tlb_done),
                              .test_expr       ((tlb_list_ifu | ovl_prev_tlb_list_ifu) == ovl_prev_tlb_list_ifu));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "New ops should not be added to tlb list after it is set (BIU IFU Outstanding)")
  u_ovl_tlb_list_clear_ifu_biu   (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .start_event     ((tlb_list_ifu == 3'b000) & ~dvm_tlb_done),
                                  .test_expr       ((tlb_list_biu_ifu | ovl_prev_tlb_list_biu_ifu) == ovl_prev_tlb_list_biu_ifu));

  // The sync list should always be a subset of the TLB list - there should
  // never be an operation being tracked by the sync list which is not also
  // being tracked by the TLB list.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - DCU ops")
  u_ovl_sync_subset_tlb_dcu  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_dcu_ops & tlb_list_dcu_ops) == sync_list_dcu_ops));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - STB slots")
  u_ovl_sync_subset_tlb_stb  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_stb_slots & tlb_list_stb_slots) == sync_list_stb_slots));

  // - The sync list can track LFs not tracked by the TLB list after it
  // resamples them when outstanding PFs have completed.
  // - but if the LFs are resampled before the TLB list is copied onto the sync
  // list, the rule should still hold while the sync list is active.
  reg ovl_sync_seen_pfs_complete;
  reg ovl_tlb_seen_pfs_complete;
  wire ovl_next_tlb_seen_pfs_complete = dvm_tlb_done ? 1'b0 : (tlb_list_resample_lfbs | ovl_tlb_seen_pfs_complete);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_tlb_seen_pfs_complete  <= 1'b0;
      ovl_sync_seen_pfs_complete <= 1'b0;
    end else begin
      ovl_tlb_seen_pfs_complete  <= ovl_next_tlb_seen_pfs_complete;
      ovl_sync_seen_pfs_complete <= set_sync_list ? ~ovl_next_tlb_seen_pfs_complete : (sync_list_resample_lfbs | ovl_sync_seen_pfs_complete);
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - BIU LFBs")
  u_ovl_sync_subset_tlb_lfb  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((|sync_list_count) & ~ovl_sync_seen_pfs_complete),
                              .consequent_expr ((sync_list_lfbs & tlb_list_lfbs) == sync_list_lfbs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - BIU pfs")
  u_ovl_sync_subset_tlb_pf   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_pfs & tlb_list_pfs) == sync_list_pfs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - SCU reqbuffs")
  u_ovl_sync_subset_tlb_scu  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_reqbuffs & tlb_list_reqbuffs) == sync_list_reqbuffs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - Pagewalk Invalidated")
  u_ovl_sync_subset_tlb_pinv (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_pw_inv & tlb_list_pw_inv) == sync_list_pw_inv));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - IFU")
  u_ovl_sync_subset_tlb_ifu  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (|sync_list_count),
                              .consequent_expr ((sync_list_ifu & tlb_list_ifu) == sync_list_ifu));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should be subset of TLB list - BIU IFU Outstanding")
  u_ovl_sync_subset_tlb_ifu_biu  (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (|sync_list_count),
                                  .consequent_expr ((sync_list_biu_ifu & tlb_list_biu_ifu) == sync_list_biu_ifu));

  // - This means that the sync list should never be set when the TLB list is
  // not set
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Sync list should not be set when TLB list not set")
  u_ovl_sync_set_tlb_not_set (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((|sync_list_count) & sync_list),
                              .consequent_expr (tlb_list));

  // The case statement used to generate dvm_tlb_op is not fully populated,
  // so it has reachable x-assignment. The output should never be assigned
  // to X when it is used.
  assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "dvm_tlb_op never X when used")
  u_ovl_x_dvm_tlb_op   (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (dcu_dvm_valid_tlb & ~inv_all_tlb_req),
                        .test_expr (dvm_tlb_op));

  // The case statement used to generate dvm_v_ifu_op is not fully populated,
  // so it has reachable x-assignment. The output should never be assigned to
  // X when it is used.
  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "dvm_v_ifu_op never X when used")
  u_ovl_x_dvm_v_ifu_op (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (dcu_dvm_valid_ifu & ~inv_all_ifu_req & (dvm_cmd != `CA53_ACE_DVM_PHYSICINV)),
                        .test_expr (dvm_v_ifu_op));


  //--------------------------
  // Register enable X-checks
  //--------------------------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dvm_tlb_done")
  u_ovl_x_dvm_tlb_done (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (dvm_tlb_done));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: set_sync_list")
  u_ovl_x_set_sync_list (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (set_sync_list));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: tlb_list_en")
  u_ovl_x_check_tlb_list_en      (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (tlb_list_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: sync_list_en")
  u_ovl_x_check_sync_list_en     (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (sync_list_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: tlb_list_count_en")
  u_ovl_x_check_tlb_list_count   (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (tlb_list_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable X-Check: sync_list_count_en")
  u_ovl_x_check_sync_list_count  (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (sync_list_count_en));


  //-------------------------------
  // Synchronously Reset Registers
  //-------------------------------
  // A number of registers do not have an asynchronous reset, and are reset
  // on the first cycle after reset by force_reset. These registers should
  // never be X, apart from on the first cycle after reset
  reg ovl_first_cycle_after_reset;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_first_cycle_after_reset <= 1'b1;
    else
      ovl_first_cycle_after_reset <= 1'b0;

  // tlb_list_dcu_ops
  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "Synchronous reset register X-Check: tlb_list_dcu_ops")
  u_ovl_sync_rst_x_tlb_dcu_ops   (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (~ovl_first_cycle_after_reset),
                                  .test_expr (tlb_list_dcu_ops));

  // tlb_list_stb_slots
  assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "Synchronous reset register X-Check: tlb_list_stb_slots")
  u_ovl_sync_rst_x_tlb_stb_slots (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (~ovl_first_cycle_after_reset),
                                  .test_expr (tlb_list_stb_slots));

  // tlb_list_lfbs
  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Synchronous reset register X-Check: tlb_list_lfbs")
  u_ovl_sync_rst_x_tlb_lfbs      (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (~ovl_first_cycle_after_reset),
                                  .test_expr (tlb_list_lfbs));

  // tlb_list_pfs
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Synchronous reset register X-Check: tlb_list_pfs")
  u_ovl_sync_rst_x_tlb_pfs       (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (~ovl_first_cycle_after_reset),
                                  .test_expr (tlb_list_pfs));

  // tlb_list_reqbuffs
  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Synchronous reset register X-Check: tlb_list_reqbuffs")
  u_ovl_sync_rst_x_tlb_reqbuffs  (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (~ovl_first_cycle_after_reset),
                                  .test_expr (tlb_list_reqbuffs));


  //----------------------------
  // Interfaces to other blocks
  //----------------------------

  // TLB/IFU Invalidate all request should only be made on the first cycle
  // after reset (so it is safe to use the gated clk, as this will always be
  // active on the first cycle after reset).

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "TLB/IFU Invalidate all request should only come of first cycle after reset")
  u_ovl_inv_all_after_reset  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (inv_all_tlb_ifu_i),
                              .consequent_expr (ovl_first_cycle_after_reset));

  // There should not be any DCU operations in the pipe on the first cycle
  // after reset, so it is safe for the TLB DCU tracking registers to be
  // reset by sampling the DCU on that cycle.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU should be empty on first cycle after reset")
  u_ovl_dcu_empty_on_reset   (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_first_cycle_after_reset),
                              .consequent_expr (~|dcu_ops_initial));


`endif

endmodule // ca53dcu_dvm

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dcu_ifu_defs.v"
`include "ca53_biu_scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
