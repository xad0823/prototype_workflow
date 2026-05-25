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

//-----------------------------------------------------------------------------
// Abstract : BIU linefill descriptor
//-----------------------------------------------------------------------------
//
// Overview
// -------
// Record linefill descriptor related fields.
// Other features:
//  o perform linefill, index and index-way match hazards check
//  o manage the DCU allocations at the linefill descriptor level

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_linefill_descriptor #(parameter LF_DESCR_ID = {`CA53_BIU_LF_DESCR_NUM_W{1'b0}})
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                                      clk,
   input  wire                                      reset_n,
   input  wire                                      DFTSE,

   //------------------------------------------------------------------------------
   // DCU Interface
   //------------------------------------------------------------------------------

   input  wire [13:6]                               dcu_index_mask_i,

   //------------------------------------------------------------------------------
   // Linefill descriptor initialization
   //------------------------------------------------------------------------------

   input  wire                                      biu_lf_active_i,
   input  wire                                      biu_lf_init_i,
   input  wire [7:0]                                biu_lf_attrs_i,
   input  wire [4:0]                                biu_lf_master_i,
   input  wire [3:0]                                biu_lf_way_i,
   input  wire [40:6]                               biu_lf_addr_i,

   //------------------------------------------------------------------------------
   // SCU DR Interface
   //------------------------------------------------------------------------------

   input  wire                                      scu_dr_valid_i,
   input  wire [4:0]                                scu_dr_id_i,
   input  wire [4:0]                                scu_dr_resp_i,
   input  wire [1:0]                                scu_dr_chunk_i,
   input  wire                                      scu_ev_done_i,

   //------------------------------------------------------------------------------
   // STB line fill merge
   //------------------------------------------------------------------------------

   input  wire [4:0]                                stb_lf_merge_i,

   //------------------------------------------------------------------------------
   // STB M1 Cache Write Interface
   //------------------------------------------------------------------------------

   input  wire [4:0]                                stb_slot_cachewrite_m1_i,
   input  wire                                      dcu_stb_data_ack_m1_i,

   //-----------------------------------------------------------------------------
   // Linefill index, way & status check (for hazard checking)
   //-----------------------------------------------------------------------------

   input  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]       master_valid_i,
   input  wire [2*`CA53_BIU_LF_MASTERS_NUM-1:0]     master_lf_addr_packed_i,
   input  wire [35*`CA53_BIU_LF_MASTERS_NUM-1:0]    master_lf_addr_hz_packed_i,
   input  wire [4*`CA53_BIU_LF_MASTERS_NUM-1:0]     master_lf_way_packed_i,
   output wire [`CA53_BIU_LF_MASTERS_NUM-1:0]       lf_descr_index_match_o,
   output wire [`CA53_BIU_LF_MASTERS_NUM-1:0]       lf_descr_index_way_match_o,
   output wire [`CA53_BIU_LF_MASTERS_NUM-1:0]       lf_descr_match_o,
   output wire [`CA53_BIU_LF_MASTERS_NUM-1:0]       lf_descr_pf_match_o,

   //------------------------------------------------------------------------------
   // Linefill descriptor last chunks from SCU status
   //------------------------------------------------------------------------------

   output wire                                      lf_descr_fetched_none_o,
   output wire                                      lf_descr_fetched_last_o,
   output wire                                      lf_descr_fetched_last_prev_cycle_o,

   //------------------------------------------------------------------------------
   // Linefill descriptor validity, master & way
   //------------------------------------------------------------------------------

   output wire                                      lf_descr_valid_o,
   output wire [4:0]                                lf_descr_master_o,
   output wire [3:0]                                lf_descr_way_o,

   //------------------------------------------------------------------------------
   // Linefill descriptor sideband signals
   //------------------------------------------------------------------------------

   output wire [39:6]                               lf_descr_addr_o,
   output wire                                      lf_descr_ns_dsc_o,
   output wire [7:0]                                lf_descr_attrs_o,
   output wire                                      lf_descr_tag_done_o,
   output wire                                      lf_descr_tag_err_o,
   output wire                                      lf_descr_unique_o,
   output wire                                      lf_descr_exclusive_o,
   output wire                                      lf_descr_evict_done_o,
   output wire                                      lf_descr_err_from_scu_o,
   output wire                                      lf_descr_passed_as_dirty_o,
   output wire                                      lf_descr_migratory_o,
   output wire [3:0]                                lf_descr_chunk_fetched_from_scu_o,
   output wire [3:0]                                lf_descr_chunk_need_release_o,
   output wire [3:0]                                lf_descr_chunk_allocated_from_stb_o,
   output wire [3:0]                                lf_descr_chunk_allocated_from_biu_o,
   output wire [4:0]                                lf_descr_stb_can_merge_o,

   //------------------------------------------------------------------------------
   // DCU allocation
   //------------------------------------------------------------------------------

   input  wire [3:0]                                biu_alloc_chunk_pend_m0_i,
   input  wire [3:0]                                biu_alloc_chunk_pend_m1_i,
   input  wire                                      biu_alloc_last_pend_m1_i,
   input  wire                                      dcu_alloc_ack_m1_i,

   //-----------------------------------------------------------------------------
   // Read allocate mode
   //-----------------------------------------------------------------------------

   output wire                                      lf_descr_inc_ramode_o,
   output wire                                      lf_descr_leave_ramode_o,

   //-----------------------------------------------------------------------------
   // Imprecise aborts
   //-----------------------------------------------------------------------------

   output wire                                      lf_descr_imp_abort_o,
   output wire                                      lf_descr_imp_fault_dec_o,
   output wire                                      lf_descr_imp_fault_ecc_o,

   //-----------------------------------------------------------------------------
   // Prefetch stream stride detection
   //-----------------------------------------------------------------------------

   input  wire                                      dpu_data_prefetch_stride_detect_i,
   input  wire                                      dpu_disable_data_prefetch_stores_pattern_i,
   input  wire                                      read_alloc_mode_i,

   //------------------------------------------------------------------------------
   // AR req channel
   //------------------------------------------------------------------------------

   input  wire                                      biu_ar_valid_i,
   input  wire [40:6]                               biu_ar_addr_i,
   input  wire [2:0]                                biu_ar_lf_master_i,

   //------------------------------------------------------------------------------
   // LF descr prefetch pf_stride match ingress channel
   //------------------------------------------------------------------------------

   input  wire                                      lf_descr_pf_stride_ingress_en_i,
   input  wire [1:0]                                lf_descr_pf_stride_ingress_cnt_i,
   input  wire [3:0]                                lf_descr_pf_stride_ingress_stride_i,

   //------------------------------------------------------------------------------
   // LF descr prefetch pf_stride match egress channel
   //------------------------------------------------------------------------------

   output wire                                      lf_descr_pf_stride_egress_en_o,
   output wire [1:0]                                lf_descr_pf_stride_egress_cnt_o,
   output wire [3:0]                                lf_descr_pf_stride_egress_stride_o,

   //------------------------------------------------------------------------------
   // Prefetcher stream allocation channel
   //------------------------------------------------------------------------------

   output wire                                      lf_descr_pf_stream_alloc_active_o,
   output wire                                      lf_descr_pf_stream_alloc_req_o,
   output wire                                      lf_descr_pf_stream_alloc_hz_req_o,
   output wire [40:6]                               lf_descr_pf_stream_alloc_addr_o,
   output wire [3:0]                                lf_descr_pf_stream_alloc_stride_o,
   output wire [7:0]                                lf_descr_pf_stream_alloc_attrs_o,
   input  wire                                      pf_stream_alloc_ack_i,
   input  wire                                      pf_stream_alloc_hz_i,
   input  wire                                      pf_streams_drop_i,

   //------------------------------------------------------------------------------
   // LF performance counters
   //------------------------------------------------------------------------------

   output wire                                      lf_descr_biu_evnt_rw_lf_o,
   output wire                                      lf_descr_biu_evnt_pf_lf_o
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                                     clk_enable;
  reg                                     lf_descr_valid;
  reg  [40:6]                             lf_descr_addr;
  reg  [7:0]                              lf_descr_attrs;
  reg  [3:0]                              lf_descr_way;
  reg  [4:0]                              lf_descr_master;
  reg                                     lf_descr_exclusive;
  reg                                     lf_descr_unique;
  reg                                     lf_descr_passed_as_dirty;
  reg                                     lf_descr_init_prev_cycle;
  reg                                     lf_descr_err_from_scu;
  reg                                     lf_descr_dec_err_from_scu;
  reg                                     lf_descr_ecc_err_from_scu;
  reg                                     lf_descr_tag_alloc_done;
  reg                                     lf_descr_last_done;
  reg                                     lf_descr_evict_done;
  reg                                     lf_descr_tag_err;
  reg  [3:0]                              lf_descr_chunk_need_release;
  reg  [3:0]                              lf_descr_chunk_allocated_from_stb;
  reg  [3:0]                              lf_descr_chunk_allocated_from_biu;
  reg  [3:0]                              lf_descr_chunk_fetched_from_scu;
  reg  [4:0]                              lf_descr_stb_slot_pend;
  reg  [4:0]                              lf_descr_stb_can_merge;
  reg                                     lf_descr_fetched_last_prev_cycle;
  reg  [3:0]                              pf_ingress_stride;
  reg  [1:0]                              pf_stride_match_cnt;
  reg                                     pf_stride_valid;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                   clk_lf_descr;
  wire                                   next_clk_enable;
  wire                                   dr_beat_valid;
  wire                                   lf_descr_release;
  wire                                   lf_descr_migratory;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_index_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_way_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_index_way_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_addr_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_match;
  wire [`CA53_BIU_LF_MASTERS_NUM-1:0]    lf_descr_pf_match;
  wire [4:0]                             lf_descr_stb_lf_merge;
  wire [3:0]                             lf_descr_chunk_alloc_stb_m1;
  wire [5:4]                             master_lf_addr [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [40:6]                            master_lf_addr_hz [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire [3:0]                             master_lf_way [`CA53_BIU_LF_MASTERS_NUM-1:0];
  wire                                   next_lf_descr_valid;
  wire [4:0]                             next_lf_descr_master;
  wire                                   next_lf_descr_exclusive;
  wire                                   next_lf_descr_unique;
  wire                                   next_lf_descr_passed_as_dirty;
  wire                                   next_lf_descr_init_prev_cycle;
  wire                                   next_lf_descr_tag_alloc_done;
  wire                                   next_lf_descr_last_done;
  wire                                   next_lf_descr_err_from_scu;
  wire                                   next_lf_descr_dec_err_from_scu;
  wire                                   next_lf_descr_ecc_err_from_scu;
  wire [3:0]                             next_lf_descr_chunk_need_release;
  wire [3:0]                             next_lf_descr_chunk_allocated_from_stb;
  wire [3:0]                             next_lf_descr_chunk_allocated_from_biu;
  wire [3:0]                             next_lf_descr_chunk_fetched_from_scu;
  wire                                   next_lf_descr_evict_done;
  wire                                   next_lf_descr_tag_err;
  wire [4:0]                             next_lf_descr_stb_slot_pend;
  wire [4:0]                             next_lf_descr_stb_can_merge;
  wire                                   lf_descr_stb_block_new_merge;
  wire                                   lf_descr_en;
  wire                                   dr_beat_en;
  wire                                   lf_descr_fetched_last;
  wire                                   lf_descr_fetched_none;
  wire                                   pf_egress_stride_eligible;
  wire [6:0]                             pf_egress_stride;
  wire                                   pf_egress_stride_valid;
  wire                                   pf_stride_match;
  wire                                   pf_pattern_found;
  wire                                   pf_pattern_found_minus1;
  wire                                   pf_ingress_stride_en;
  wire                                   pf_stride_match_cnt_en;
  wire [1:0]                             next_pf_stride_match_cnt;
  wire                                   lf_descr_from_pf;
  wire                                   next_pf_stride_valid;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                 index_i;

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Avoid clocking linefill descriptor registers when the linefill descriptor
  // is not valid or when there is no possibility of issuing a new linefill

  assign next_clk_enable = biu_lf_active_i |
                           lf_descr_valid;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_lf_descr (.clk_i         (clk),
                                                    .clk_enable_i  (clk_enable),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_lf_descr));

  //-----------------------------------------------------------------------------
  // Linefill descriptor status
  //-----------------------------------------------------------------------------

  // Valid LF data received from SCU

  assign dr_beat_valid = scu_dr_valid_i & `CA53_BIU_RID_IS_FOR_LF(scu_dr_id_i)                                  &
                         (scu_dr_id_i[`CA53_BIU_LF_DESCR_NUM_W-1:0] == LF_DESCR_ID[`CA53_BIU_LF_DESCR_NUM_W-1:0]);

  // Release the linefill descriptor

  assign lf_descr_release = // Linefill descriptor valid
                            lf_descr_valid                                      &
                            ((// Last alloc ack-ed in M1
                              biu_alloc_last_pend_m1_i & dcu_alloc_ack_m1_i) |
                             // Last alloc done
                             lf_descr_last_done                               ) &
                            // STB linefill merge not pending or line is not unique or error received from the SCU
                            (~|lf_descr_stb_can_merge | ~lf_descr_unique        );

  // Linefill descriptor migratory status
  // o ReadShared lines which are unique are migratory
  // o ReadUnique lines are not migratory

  assign lf_descr_migratory = lf_descr_unique                        &
                              `CA53_MEM_SHAREABLE(lf_descr_attrs)    &
                              ~`CA53_BIU_LF_FOR_WRITE(lf_descr_master);

  // STB linefill merge pending to the same linefill descriptor

  assign lf_descr_stb_lf_merge = {lf_descr_match[`CA53_BIU_STB4_LF] & stb_lf_merge_i[4],
                                  lf_descr_match[`CA53_BIU_STB3_LF] & stb_lf_merge_i[3],
                                  lf_descr_match[`CA53_BIU_STB2_LF] & stb_lf_merge_i[2],
                                  lf_descr_match[`CA53_BIU_STB1_LF] & stb_lf_merge_i[1],
                                  lf_descr_match[`CA53_BIU_STB0_LF] & stb_lf_merge_i[0]};

  // STB chunk M1 merge matching the current linefill descriptor

  assign lf_descr_chunk_alloc_stb_m1 = {4{dcu_stb_data_ack_m1_i}}                                                                                          &
                                       (({4{lf_descr_stb_slot_pend[0] & stb_slot_cachewrite_m1_i[0]}} & (4'h1 << master_lf_addr[`CA53_BIU_STB0_LF][5:4])) |
                                        ({4{lf_descr_stb_slot_pend[1] & stb_slot_cachewrite_m1_i[1]}} & (4'h1 << master_lf_addr[`CA53_BIU_STB1_LF][5:4])) |
                                        ({4{lf_descr_stb_slot_pend[2] & stb_slot_cachewrite_m1_i[2]}} & (4'h1 << master_lf_addr[`CA53_BIU_STB2_LF][5:4])) |
                                        ({4{lf_descr_stb_slot_pend[3] & stb_slot_cachewrite_m1_i[3]}} & (4'h1 << master_lf_addr[`CA53_BIU_STB3_LF][5:4])) |
                                        ({4{lf_descr_stb_slot_pend[4] & stb_slot_cachewrite_m1_i[4]}} & (4'h1 << master_lf_addr[`CA53_BIU_STB4_LF][5:4])  ));

  // Compute next linefill descriptor initiazation flag

  assign next_lf_descr_init_prev_cycle = biu_lf_init_i;

  // Compute next linefill descriptor valid status

  assign next_lf_descr_valid = biu_lf_init_i | (lf_descr_valid & ~lf_descr_release);

  // Compute next linefill descriptor master status

  assign next_lf_descr_master = ~lf_descr_valid                                        ? biu_lf_master_i                                            :
                                (lf_descr_init_prev_cycle            &
                                 lf_descr_match[`CA53_BIU_TLB_LF]    &
                                 `CA53_BIU_LF_FOR_TLB(lf_descr_master))                ? {`CA53_BIU_LF_MASTER_TLB_LD_PENDING, lf_descr_master[2:0]} :
                                (`CA53_BIU_LF_FOR_TLB_LD_PENDING(lf_descr_master)   &
                                 (|(lf_descr_chunk_fetched_from_scu               &
                                    (4'h1 << master_lf_addr[`CA53_BIU_TLB_LF][5:4])))) ? {`CA53_BIU_LF_MASTER_TLB_LD_DONE, lf_descr_master[2:0]}    :
                                                                                         lf_descr_master;

  // Compute if the linefill descriptor was initiated by an exclusive load

  assign next_lf_descr_exclusive = ~lf_descr_valid ? `CA53_BIU_LF_FOR_LDREX(biu_lf_master_i) :
                                                     lf_descr_exclusive;

  // Read data passShared information is captured here for use in determining the
  // correct MOESI information to propagate to the DCU and whether or not the STB
  // is allowed to merge data.  The STB can only merge data if the line is
  // unique.  The line is guaranteed to be unique if the linefill was started by
  // a write, otherwise we have to look at the passShared bit that is returned
  // with the first beat of read data.

  assign next_lf_descr_unique = ~lf_descr_valid ? `CA53_BIU_LF_FOR_WRITE(biu_lf_master_i)                        :
                                dr_beat_valid   ? (lf_descr_unique | ~scu_dr_resp_i[`CA53_ACE_RRESP_ISSHARED_B]) :
                                                  lf_descr_unique;

  // Compute next linefill descriptor passed as dirty

  assign next_lf_descr_passed_as_dirty = lf_descr_valid                                                        &
                                         (lf_descr_passed_as_dirty | scu_dr_resp_i[`CA53_ACE_RRESP_PASSDIRTY_B]);

  // Compute next linefill descriptor Tag allocation status flags

  assign next_lf_descr_tag_alloc_done = lf_descr_valid                               &
                                        (dcu_alloc_ack_m1_i | lf_descr_tag_alloc_done);

  // Compute next linefill descriptor Tag needs invalidation

  assign next_lf_descr_tag_err = lf_descr_valid                              &
                                 lf_descr_err_from_scu                       &
                                 ~|lf_descr_chunk_need_release               &
                                 (~|lf_descr_stb_can_merge | ~lf_descr_unique);

  // Compute next linefill descriptor last allocation status flags

  assign next_lf_descr_last_done = lf_descr_valid                                                       &
                                   ((biu_alloc_last_pend_m1_i & dcu_alloc_ack_m1_i) | lf_descr_last_done);

  // Compute next linefill descriptor error received from SCU:
  // o ECCERR
  // o SLVERR or DECERR
  // o EXOKAY on a non-exclusive (exclusive loads allow OKAY or EXOKAY)

  assign next_lf_descr_err_from_scu = lf_descr_valid                                                                            &
                                      (( lf_descr_exclusive & ~((scu_dr_resp_i[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_OKAY) |
                                                                (scu_dr_resp_i[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_EXOKAY))) |
                                       (~lf_descr_exclusive & (scu_dr_resp_i[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_OKAY))      |
                                       scu_dr_resp_i[`CA53_BIU_DR_RESP_ECC_B]                                                  |
                                       lf_descr_err_from_scu                                                                    );

  // Compute next linefill descriptor decoder error received from SCU

  assign next_lf_descr_dec_err_from_scu = lf_descr_valid                                                 &
                                          ((scu_dr_resp_i[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR) |
                                           lf_descr_dec_err_from_scu                                     );

  // Compute next linefill descriptor ECC error received from SCU
  // Note that next_lf_descr_ecc_err_from_scu is not expected to toggle during the non-ECC configuration
  // and thus allowing the lf_descr_ecc_err_from_scu DFF removal

  assign next_lf_descr_ecc_err_from_scu = lf_descr_valid                           &
                                          (scu_dr_resp_i[`CA53_BIU_DR_RESP_ECC_B] |
                                           lf_descr_ecc_err_from_scu               );

  // Compute next linefill descriptor eviction done

  assign next_lf_descr_evict_done = lf_descr_valid                      &
                                    (scu_ev_done_i | lf_descr_evict_done);

  // Compute next linefill descriptor chunk fetched from SCU

  assign next_lf_descr_chunk_fetched_from_scu = {4{lf_descr_valid}}               &
                                                (lf_descr_chunk_fetched_from_scu |
                                                 (4'h1 << scu_dr_chunk_i[1:0]    ));

  // Compute next linefill descriptor chunk allocated from STB

  assign next_lf_descr_chunk_allocated_from_stb = {4{lf_descr_valid}}                                             &
                                                  (lf_descr_chunk_alloc_stb_m1 | lf_descr_chunk_allocated_from_stb);

  // Compute next linefill descriptor chunk which needs release

  assign next_lf_descr_chunk_need_release = {4{~lf_descr_valid}}                                     |
                                            (lf_descr_chunk_need_release & ~biu_alloc_chunk_pend_m0_i);

  // Compute next linefill descriptor chunk allocated from BIU

  assign next_lf_descr_chunk_allocated_from_biu = ~lf_descr_valid    ? 4'h0                                  :
                                                  dcu_alloc_ack_m1_i ? (lf_descr_chunk_allocated_from_biu |
                                                                        biu_alloc_chunk_pend_m1_i          ) :
                                                                       (lf_descr_chunk_allocated_from_biu   &
                                                                        ~(lf_descr_chunk_alloc_stb_m1      |
                                                                          lf_descr_chunk_allocated_from_stb ));

  // Compute STB slot pending to the linefill descriptor

  assign next_lf_descr_stb_slot_pend = lf_descr_match[`CA53_BIU_STB4_LF:`CA53_BIU_STB0_LF];

  // Compute STB slot can merge info

  assign lf_descr_stb_block_new_merge = ~|lf_descr_chunk_need_release;

  assign next_lf_descr_stb_can_merge = {5{~lf_descr_valid}}                                        |
                                       (lf_descr_stb_can_merge & lf_descr_stb_lf_merge)            |
                                       (lf_descr_stb_can_merge & {5{~lf_descr_stb_block_new_merge}});

  // Register the linefill descriptor fields

  assign lf_descr_en = lf_descr_valid | biu_lf_init_i;

  always @(posedge clk_lf_descr or negedge reset_n)
    if (~reset_n) begin
      lf_descr_valid                   <= 1'b0;
      lf_descr_master                  <= {5{1'b0}};
      lf_descr_init_prev_cycle         <= 1'b0;
      lf_descr_fetched_last_prev_cycle <= 1'b0;
    end else if (lf_descr_en) begin
      lf_descr_valid                   <= next_lf_descr_valid;
      lf_descr_master                  <= next_lf_descr_master;
      lf_descr_init_prev_cycle         <= next_lf_descr_init_prev_cycle;
      lf_descr_fetched_last_prev_cycle <= lf_descr_fetched_last;
    end

  always @(posedge clk_lf_descr)
    if (biu_lf_init_i) begin
      lf_descr_addr  <= biu_lf_addr_i[40:6];
      lf_descr_attrs <= biu_lf_attrs_i;
      lf_descr_way   <= biu_lf_way_i;
    end

  always @(posedge clk_lf_descr)
    if (lf_descr_en) begin
      lf_descr_exclusive                <= next_lf_descr_exclusive;
      lf_descr_tag_alloc_done           <= next_lf_descr_tag_alloc_done;
      lf_descr_last_done                <= next_lf_descr_last_done;
      lf_descr_evict_done               <= next_lf_descr_evict_done;
      lf_descr_tag_err                  <= next_lf_descr_tag_err;
      lf_descr_chunk_need_release       <= next_lf_descr_chunk_need_release;
      lf_descr_chunk_allocated_from_stb <= next_lf_descr_chunk_allocated_from_stb;
      lf_descr_chunk_allocated_from_biu <= next_lf_descr_chunk_allocated_from_biu;
      lf_descr_stb_slot_pend            <= next_lf_descr_stb_slot_pend;
      lf_descr_stb_can_merge            <= next_lf_descr_stb_can_merge;
    end

  assign dr_beat_en = dr_beat_valid | biu_lf_init_i;

  always @(posedge clk_lf_descr)
    if (dr_beat_en) begin
      lf_descr_unique                 <= next_lf_descr_unique;
      lf_descr_passed_as_dirty        <= next_lf_descr_passed_as_dirty;
      lf_descr_err_from_scu           <= next_lf_descr_err_from_scu;
      lf_descr_dec_err_from_scu       <= next_lf_descr_dec_err_from_scu;
      lf_descr_ecc_err_from_scu       <= next_lf_descr_ecc_err_from_scu;
      lf_descr_chunk_fetched_from_scu <= next_lf_descr_chunk_fetched_from_scu;
    end

  //-----------------------------------------------------------------------------
  // Linefill addr, index & way hazard checking
  //-----------------------------------------------------------------------------

  // Unpack master_lf_addr & master_lf_way

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : g_unpack_master_lf_addr
      assign master_lf_addr[index_i]    = master_lf_addr_packed_i[2*index_i+1:2*index_i];
      assign master_lf_addr_hz[index_i] = master_lf_addr_hz_packed_i[35*index_i+34:35*index_i];
      assign master_lf_way[index_i]     = master_lf_way_packed_i[4*index_i+3:4*index_i];
    end
  endgenerate

  // Perform hazard checking against linefill masters

  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_MASTERS_NUM; index_i = index_i + 1) begin : g_lf_descr_hazard_status
      if (index_i == `CA53_BIU_CCB) begin : g_lf_descr_hazard_nested_0
        assign lf_descr_index_match[index_i]     = ({lf_descr_valid, master_valid_i[index_i], (master_lf_addr_hz[index_i][13:6] & dcu_index_mask_i)} == {2'b11, (lf_descr_addr[13:6] & dcu_index_mask_i)});
        assign lf_descr_way_match[index_i]       = ({lf_descr_valid, master_valid_i[index_i], master_lf_way[index_i]} == {2'b11, lf_descr_way});
        assign lf_descr_index_way_match[index_i] = lf_descr_index_match[index_i] & lf_descr_way_match[index_i];
        assign lf_descr_addr_match[index_i]      = 1'b0;
        assign lf_descr_match[index_i]           = 1'b0;
        assign lf_descr_pf_match[index_i]        = 1'b0;
      end else if (index_i == `CA53_BIU_TLB_LF) begin : g_lf_descr_hazard_nested_0_else_1
        assign lf_descr_index_match[index_i]     = ({lf_descr_valid, (master_lf_addr_hz[index_i][13:6] & dcu_index_mask_i)} == {1'b1, (lf_descr_addr[13:6] & dcu_index_mask_i)});
        assign lf_descr_way_match[index_i]       = ({lf_descr_valid, master_lf_way[index_i]} == {1'b1, lf_descr_way});
        assign lf_descr_index_way_match[index_i] = lf_descr_index_match[index_i] & lf_descr_way_match[index_i];
        assign lf_descr_addr_match[index_i]      = (master_lf_addr_hz[index_i][40:6] == lf_descr_addr[40:6]);
        assign lf_descr_match[index_i]           = lf_descr_valid & lf_descr_addr_match[index_i];
        assign lf_descr_pf_match[index_i]        = 1'b0;
      end else begin : g_lf_descr_hazard_nested_0_else_2
        assign lf_descr_index_match[index_i]     = ({lf_descr_valid, master_valid_i[index_i], (master_lf_addr_hz[index_i][13:6] & dcu_index_mask_i)} == {2'b11, (lf_descr_addr[13:6] & dcu_index_mask_i)});
        assign lf_descr_way_match[index_i]       = ({lf_descr_valid, master_valid_i[index_i], master_lf_way[index_i]} == {2'b11, lf_descr_way});
        assign lf_descr_index_way_match[index_i] = lf_descr_index_match[index_i] & lf_descr_way_match[index_i];
        assign lf_descr_addr_match[index_i]      = (master_lf_addr_hz[index_i][40:6] == lf_descr_addr[40:6]);
        assign lf_descr_match[index_i]           = lf_descr_valid & master_valid_i[index_i] & lf_descr_addr_match[index_i];
        assign lf_descr_pf_match[index_i]        = pf_stride_valid & master_valid_i[index_i] & lf_descr_addr_match[index_i];
      end
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_index_match_o     = lf_descr_index_match;
  assign lf_descr_index_way_match_o = lf_descr_index_way_match;
  assign lf_descr_match_o           = lf_descr_match;
  assign lf_descr_pf_match_o        = lf_descr_pf_match;

  //-----------------------------------------------------------------------------
  // DCU allocation management
  //-----------------------------------------------------------------------------

  assign lf_descr_fetched_last = &lf_descr_chunk_fetched_from_scu;

  assign lf_descr_fetched_none = ~|lf_descr_chunk_fetched_from_scu;

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_valid_o                    = lf_descr_valid;

  assign lf_descr_master_o                   = lf_descr_master;

  assign lf_descr_way_o                      = lf_descr_way;

  assign lf_descr_tag_done_o                 = lf_descr_tag_alloc_done;

  assign lf_descr_tag_err_o                  = lf_descr_tag_err;

  assign lf_descr_unique_o                   = lf_descr_unique;

  assign lf_descr_exclusive_o                = lf_descr_exclusive;

  assign lf_descr_migratory_o                = lf_descr_migratory;

  assign lf_descr_passed_as_dirty_o          = lf_descr_passed_as_dirty;

  assign lf_descr_evict_done_o               = lf_descr_evict_done;

  assign lf_descr_err_from_scu_o             = lf_descr_err_from_scu;

  assign lf_descr_chunk_fetched_from_scu_o   = lf_descr_chunk_fetched_from_scu;

  assign lf_descr_chunk_need_release_o       = lf_descr_chunk_need_release & ~biu_alloc_chunk_pend_m0_i;

  assign lf_descr_chunk_allocated_from_stb_o = lf_descr_chunk_allocated_from_stb;

  assign lf_descr_chunk_allocated_from_biu_o = lf_descr_chunk_allocated_from_biu;

  assign lf_descr_stb_can_merge_o            = lf_descr_stb_can_merge;

  assign lf_descr_fetched_none_o             = lf_descr_fetched_none;

  assign lf_descr_fetched_last_o             = lf_descr_fetched_last;

  assign lf_descr_fetched_last_prev_cycle_o  = lf_descr_fetched_last_prev_cycle;

  assign lf_descr_addr_o[39:6]               = lf_descr_addr[39:6];

  assign lf_descr_ns_dsc_o                   = lf_descr_addr[40];

  assign lf_descr_attrs_o                    = lf_descr_attrs;

  //-----------------------------------------------------------------------------
  // Read allocate mode
  //-----------------------------------------------------------------------------

  // o Provide flag to increment the read allocate mode counter when the STB merges all chunks
  // o Clear the read allocate mode counter when a line initiated by STB completes without all
  //   chunks being merged by the STB

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_inc_ramode_o   = lf_descr_valid & (~&lf_descr_chunk_allocated_from_stb)             &
                                   (&(lf_descr_chunk_allocated_from_stb | lf_descr_chunk_alloc_stb_m1));
  assign lf_descr_leave_ramode_o = lf_descr_valid & lf_descr_release                                   &
                                   `CA53_BIU_LF_ELIGIBLE_FOR_RAMODE_LEAVE(lf_descr_master)             &
                                   (~&(lf_descr_chunk_allocated_from_stb | lf_descr_chunk_alloc_stb_m1));

  //-----------------------------------------------------------------------------
  // Imprecise aborts
  //-----------------------------------------------------------------------------

  // Raise an imprecise abort if a linefill containing dirty data aborted.
  // The imprecise abort is raised upon release of the linefill descriptor
  // (ie once we have collected abort information for all beats in the burst
  //  so that it is only raised once)

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_imp_abort_o     = // release the linefill descr
                                    lf_descr_release                     &
                                    // SCU slave or decoder error received
                                    lf_descr_err_from_scu                &
                                    (// passed as dirty
                                     lf_descr_passed_as_dirty           |
                                     // any chunk merged from the STB
                                     (|lf_descr_chunk_allocated_from_stb));

  assign lf_descr_imp_fault_dec_o = lf_descr_dec_err_from_scu;
  assign lf_descr_imp_fault_ecc_o = lf_descr_ecc_err_from_scu;

  //-----------------------------------------------------------------------------
  // Prefetch stream detection
  //-----------------------------------------------------------------------------
  // Used the registered version of the AR channel for pf_stride detection related logic (ease the timing closure)

  // Compute if the transaction on the AR channel is eligible for the prefetch detection

  assign pf_egress_stride_eligible = biu_ar_valid_i                                                                                                  &
                                     `CA53_BIU_LF_ELIGIBLE_FOR_PF(biu_ar_lf_master_i, read_alloc_mode_i, dpu_disable_data_prefetch_stores_pattern_i) &
                                     (biu_ar_addr_i[40:12] == lf_descr_addr[40:12]                                                                   );

  // Calculate the stride of the new linefill from the last linefill request.

  assign pf_egress_stride = (biu_ar_addr_i[11:6] - lf_descr_addr[11:6]);

  // Determine whether the stride is within the supported range of -4 to 4.

  assign pf_egress_stride_valid = (pf_egress_stride == 7'b0000100) |  // +4
                                  (pf_egress_stride == 7'b0000011) |  // +3
                                  (pf_egress_stride == 7'b0000010) |  // +2
                                  (pf_egress_stride == 7'b0000001) |  // +1
                                  (pf_egress_stride == 7'b1111111) |  // -1
                                  (pf_egress_stride == 7'b1111110) |  // -2
                                  (pf_egress_stride == 7'b1111101) |  // -3
                                  (pf_egress_stride == 7'b1111100  ); // -4

  // Check if the incoming AR trans is matching the LF descr stored stride

  assign pf_stride_match = pf_egress_stride_eligible & pf_egress_stride_valid &
                           ((pf_egress_stride[3:0] == pf_ingress_stride)     |
                            (~|pf_stride_match_cnt                           ));

  // Compute prefetch pattern detection flag
  // (ie two or three strides matched based on the dpu_data_prefetch_stride_detect_i)

  assign pf_pattern_found        = pf_stride_match_cnt[1] & (~dpu_data_prefetch_stride_detect_i | pf_stride_match_cnt[0]);

  assign pf_pattern_found_minus1 = (pf_stride_match_cnt == {dpu_data_prefetch_stride_detect_i, ~dpu_data_prefetch_stride_detect_i});

  // Compute the next pf_stride matched counter value:
  // o 2'b00 when linefill initialization and no ingress stride detected, prefetch stride match,
  //         when a prefetch stream is initiated from the corresponding linefill descriptor or
  //         when all prefetch streams get aborted.
  // o (lf_descr_pf_stride_ingress_cnt_i + 1'b1) when the stride is recorded upon linefill initialization and ingress stride detected
  // o lf_descr_pf_stride_ingress_cnt_i when others

  assign next_pf_stride_match_cnt = // Reset the pf_stride_match_cnt:
                                    // o upon linefill initialization;
                                    // o when a prefetch stream is initialized from the corresponding linefill descriptor;
                                    // o when all prefetch streams get aborted.
                                    (pf_stream_alloc_ack_i | pf_stream_alloc_hz_i | pf_streams_drop_i |
                                     (lf_descr_init_prev_cycle & ~lf_descr_pf_stride_ingress_en_i           )) ? 2'b00 :
                                    // Get the winning linefill descriptor's pf_stride_match_cnt incremented value
                                                                                                                 (lf_descr_pf_stride_ingress_cnt_i + 1'b1);

  // Compute the enable term of the pf_stride_match_cnt

  assign pf_stride_match_cnt_en = (lf_descr_init_prev_cycle |
                                   pf_stream_alloc_ack_i    |
                                   pf_stream_alloc_hz_i     | 
                                   pf_streams_drop_i        );

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pf_stride_match_cnt <= 2'b00;
    end else if (pf_stride_match_cnt_en) begin
      pf_stride_match_cnt <= next_pf_stride_match_cnt;
    end

  // The pf_stride is stored when the pf_stride is inactive and a new linefill
  // request is made that might trigger prefetching.

  assign pf_ingress_stride_en = lf_descr_init_prev_cycle & lf_descr_pf_stride_ingress_en_i;

  always @(posedge clk_lf_descr or negedge reset_n)
    if (~reset_n) begin
      pf_ingress_stride <= 4'b0000;
    end else if (pf_ingress_stride_en) begin
      pf_ingress_stride <= lf_descr_pf_stride_ingress_stride_i;
    end

  assign next_pf_stride_valid = ~pf_streams_drop_i & (lf_descr_valid | pf_stride_valid);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pf_stride_valid <= 1'b0;
    end else begin
      pf_stride_valid <= next_pf_stride_valid;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  // LF descr prefetch pf_stride match egress channel

  assign lf_descr_pf_stride_egress_en_o     = pf_stride_valid & pf_stride_match & ~pf_pattern_found;
  assign lf_descr_pf_stride_egress_cnt_o    = pf_stride_match_cnt[1:0];
  assign lf_descr_pf_stride_egress_stride_o = pf_egress_stride[3:0];

  // Prefetcher stream allocation channel

  assign lf_descr_pf_stream_alloc_active_o  = pf_stride_valid & pf_pattern_found_minus1;
  assign lf_descr_pf_stream_alloc_req_o     = pf_stride_valid & pf_pattern_found;
  assign lf_descr_pf_stream_alloc_hz_req_o  = lf_descr_init_prev_cycle;
  assign lf_descr_pf_stream_alloc_addr_o    = lf_descr_addr[40:6];
  assign lf_descr_pf_stream_alloc_stride_o  = pf_ingress_stride[3:0];
  assign lf_descr_pf_stream_alloc_attrs_o   = lf_descr_attrs[7:0];

  //-----------------------------------------------------------------------------
  // Performance counters
  //-----------------------------------------------------------------------------

  assign lf_descr_from_pf = (lf_descr_master[2:0] == `CA53_BIU_LF_MASTER_PF)    |
                            (lf_descr_master[2:0] == `CA53_BIU_LF_MASTER_PF_PLDW);

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign lf_descr_biu_evnt_rw_lf_o = lf_descr_init_prev_cycle & ~lf_descr_from_pf;
  assign lf_descr_biu_evnt_pf_lf_o = lf_descr_init_prev_cycle & lf_descr_from_pf;

`ifdef ARM_ASSERT_ON
  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_beat_en")
  u_ovl_x_dr_beat_en    (.clk       (clk_lf_descr),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dr_beat_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lf_descr_en")
  u_ovl_x_lf_descr_en   (.clk       (clk_lf_descr),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_en));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "biu_alloc_chunk_pend_m0_i must never be unknown")
  u_ovl_lf_descr_01     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_alloc_chunk_pend_m0_i));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "biu_alloc_chunk_pend_m1_i must never be unknown")
  u_ovl_lf_descr_02     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_alloc_chunk_pend_m1_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_lf_init_i must never be unknown")
  u_ovl_lf_descr_03     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_lf_init_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_release must never be unknown")
  u_ovl_lf_descr_04     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_release));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dr_beat_valid must never be unknown")
  u_ovl_lf_descr_05     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dr_beat_valid));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "lf_descr_index_match_o[2:1] must never be unknown")
  u_ovl_lf_descr_06     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_index_match_o[2:1]));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "lf_descr_match_o[2:1] must never be unknown")
  u_ovl_lf_descr_07     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_match_o[2:1]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Read buffer pending in M0/M1 must not match a chunk already allocated by the BIU")
  u_ovl_lf_descr_08   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (lf_descr_valid),
                       .consequent_expr (~|((biu_alloc_chunk_pend_m0_i | biu_alloc_chunk_pend_m1_i) & lf_descr_chunk_allocated_from_biu)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Read data must not be received for a corresponding LF descr which is not valid")
  u_ovl_lf_descr_09   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (dr_beat_valid),
                       .consequent_expr (lf_descr_valid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Imprecise abort must not be sent from a LF descr which is not valid")
  u_ovl_lf_descr_10   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (lf_descr_imp_abort_o),
                       .consequent_expr (lf_descr_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Imprecise dec fault must not must be unknown when lf_descr_imp_abort_o is set")
  u_ovl_lf_descr_11     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_imp_abort_o),
                         .test_expr (lf_descr_imp_fault_dec_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "The clock enable must never be unknown")
  u_ovl_lf_descr_12     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (clk_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is a potential access to the LF descr")
  u_ovl_lf_descr_13   (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr ((biu_lf_init_i | lf_descr_en | dr_beat_en)),
                       .consequent_expr (clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pf_ingress_stride_en must never be unknown")
  u_ovl_lf_descr_14     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_ingress_stride_en));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "pf_ingress_stride must never be unknown")
  u_ovl_lf_descr_15     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_ingress_stride));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pf_stride_match_cnt_en must never be unknown")
  u_ovl_lf_descr_16     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_stride_match_cnt_en));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "pf_stride_match_cnt must never be unknown")
  u_ovl_lf_descr_17     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_stride_match_cnt));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_pf_stride_egress_en_o must never be unknown")
  u_ovl_lf_descr_18     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_pf_stride_egress_en_o));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "lf_descr_pf_stride_egress_cnt_o must never be unknown when lf_descr_pf_stride_egress_en_o is set")
  u_ovl_lf_descr_19     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_pf_stride_egress_en_o),
                         .test_expr (lf_descr_pf_stride_egress_cnt_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "lf_descr_pf_stride_egress_stride_o must never be unknown when lf_descr_pf_stride_egress_en_o is set")
  u_ovl_lf_descr_20     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_pf_stride_egress_en_o),
                         .test_expr (lf_descr_pf_stride_egress_stride_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_pf_stream_alloc_req_o must never be unknown")
  u_ovl_lf_descr_21     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_pf_stream_alloc_req_o));

  assert_never_unknown #(`OVL_FATAL, 35, `OVL_ASSERT, "lf_descr_pf_stream_alloc_addr_o must never be unknown when lf_descr_pf_stream_alloc_req_o is set")
  u_ovl_lf_descr_22     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_pf_stream_alloc_req_o),
                         .test_expr (lf_descr_pf_stream_alloc_addr_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "lf_descr_pf_stream_alloc_stride_o must never be unknown when lf_descr_pf_stream_alloc_req_o is set")
  u_ovl_lf_descr_23     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_pf_stream_alloc_req_o),
                         .test_expr (lf_descr_pf_stride_egress_stride_o));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "lf_descr_pf_stream_alloc_attrs_o must never be unknown when lf_descr_pf_stream_alloc_req_o is set")
  u_ovl_lf_descr_24     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_pf_stream_alloc_req_o),
                         .test_expr (lf_descr_pf_stream_alloc_attrs_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_biu_evnt_rw_lf_o must never be unknown")
  u_ovl_lf_descr_25     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_biu_evnt_rw_lf_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lf_descr_biu_evnt_pf_lf_o must never be unknown")
  u_ovl_lf_descr_26     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_biu_evnt_pf_lf_o));

  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "lf_descr_biu_evnt_rw_lf_o and lf_descr_biu_evnt_pf_lf_o are mutual exclusive")
  u_ovl_lf_descr_27    (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ({lf_descr_biu_evnt_rw_lf_o, lf_descr_biu_evnt_pf_lf_o}));

  assert_never_unknown #(`OVL_FATAL, 6, `OVL_ASSERT, "lf_descr_index_match_o[9:4] must never be unknown")
  u_ovl_lf_descr_28     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_index_match_o[9:4]));

  assert_never_unknown #(`OVL_FATAL, 6, `OVL_ASSERT, "lf_descr_match_o[9:4] must never be unknown")
  u_ovl_lf_descr_29     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (lf_descr_match_o[9:4]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Imprecise ecc fault must not must be unknown when lf_descr_imp_abort_o is set")
  u_ovl_lf_descr_30     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (lf_descr_imp_abort_o),
                         .test_expr (lf_descr_imp_fault_ecc_o));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_linefill_descriptor
