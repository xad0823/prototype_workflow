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
// Abstract : BIU data prefetch stream management
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The data prefetch stream management is handled in this module.

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_prefetch_stream_mngmt #(parameter CPU_CACHE_PROTECTION = 1'b0, parameter PF_STREAM_ID = {`CA53_BIU_PF_STREAM_NUM_W{1'b0}})
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                               clk,
   input  wire                               reset_n,
   input  wire                               DFTSE,

   //-----------------------------------------------------------------------------
   // Memory granule: 2'b00: 4k, 2'b01: 16k, 2'b11: 64k
   //-----------------------------------------------------------------------------

   input  wire [1:0]                         tlb_mem_granule_i,

   //------------------------------------------------------------------------------
   // DCU LF descr TAG/Data/Dirty M1 alloc interface
   //------------------------------------------------------------------------------

   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]  biu_alloc_lf_descr_m0_i,
   input  wire                               biu_alloc_lf_descr_from_pf_m0_i,
   input  wire [39:6]                        biu_alloc_lf_descr_addr_m0_i,
   input  wire                               biu_alloc_lf_descr_ns_dsc_m0_i,

   //------------------------------------------------------------------------------
   // DCU Prefetch TAG interface
   //------------------------------------------------------------------------------

   output wire                               biu_pf_tag_active_o,
   output wire                               biu_pf_tag_req_m0_o,
   output wire                               biu_pf_tag_req_m1_o,
   output wire [39:6]                        biu_pf_tag_addr_m0_o,
   output wire                               biu_pf_tag_ns_dsc_m0_o,
   input  wire                               dcu_pf_tag_has_priority_m0_i,
   input  wire                               dcu_pf_tag_ack_m1_i,
   input  wire                               dcu_pf_tag_hit_m2_i,
   input  wire                               dcu_ecc_tag_err_m3_i,

   //------------------------------------------------------------------------------
   // Prefetch stream allocation
   //------------------------------------------------------------------------------

   input  wire                               pf_stream_lf_used_i,
   input  wire                               pf_stream_cancel_throttle_i,
   input  wire                               pf_stream_eligible_for_pf_lf_init_i,
   input  wire                               pf_stream_req_active_i,
   input  wire                               pf_stream_req_i,
   input  wire [40:6]                        pf_stream_addr_i,
   input  wire [3:0]                         pf_stream_stride_i,
   input  wire [7:0]                         pf_stream_attrs_i,
   input  wire                               pf_stream_pldw_i,
   output wire                               pf_stream_idle_o,
   output wire                               pf_stream_throttle_o,

   //------------------------------------------------------------------------------
   // Prefetch streams hazard
   //------------------------------------------------------------------------------

   input  wire [40:6]                        pf_stream_match_ingress_addr_i,
   output wire                               pf_stream_match_ingress_hz_o,
   input  wire                               pf_stream_match_egress_hz_i,

   //------------------------------------------------------------------------------
   // Linefill descriptors initiated by the prefetch stream
   //------------------------------------------------------------------------------

   input  wire                               lf_descr_from_pf_stream_valid_i,

   //------------------------------------------------------------------------------
   // Prefetch linefill request
   //------------------------------------------------------------------------------

   output wire                               pf_lf_active_early_o,
   output wire                               pf_lf_active_o,
   output wire                               pf_lf_req_o,
   output wire [40:6]                        pf_lf_addr_o,
   output wire [7:0]                         pf_lf_attrs_o,
   output wire [3:0]                         pf_lf_way_o,
   output wire                               pf_lf_pldw_o,
   input  wire                               pf_lf_ack_i,
   input  wire                               pf_lf_match_non_pf_i,
   input  wire                               pf_lf_match_pf_i,

   //------------------------------------------------------------------------------
   // DCU or STB request match linefill initiated by data pretecher
   //------------------------------------------------------------------------------

   input  wire                               dcu_stb_match_lf_from_pf_i,

   //------------------------------------------------------------------------------
   // BIU AR channel
   //------------------------------------------------------------------------------

   input  wire [40:6]                        biu_ar_addr_i,
   input  wire [7:0]                         biu_ar_attrs_i,
   input  wire [2:0]                         biu_ar_lf_master_i,

   //------------------------------------------------------------------------------
   // Prefetch stream abort
   //------------------------------------------------------------------------------

   input  wire                               pf_stream_abort_i
  );

  localparam STATE_W                                    = 4;
  localparam [STATE_W-1:0] STATE_IDLE                   = 4'b0000;
  localparam [STATE_W-1:0] STATE_ADDR_GEN               = 4'b0001;
  localparam [STATE_W-1:0] STATE_ADDR_GEN_LF_DONE       = 4'b0010;
  localparam [STATE_W-1:0] STATE_ADDR_PAGE_CROSSED      = 4'b0011;
  localparam [STATE_W-1:0] STATE_TAG_M0                 = 4'b0100;
  localparam [STATE_W-1:0] STATE_TAG_M1                 = 4'b0101;
  localparam [STATE_W-1:0] STATE_TAG_M2                 = 4'b0110;
  localparam [STATE_W-1:0] STATE_TAG_M3_HIT             = 4'b0111;
  localparam [STATE_W-1:0] STATE_TAG_M3_MISS            = 4'b1000;
  localparam [STATE_W-1:0] STATE_LF_REQ                 = 4'b1001;
  localparam [STATE_W-1:0] STATE_THROTTLE               = 4'b1010;
  localparam [STATE_W-1:0] STATE_THROTTLE_PF_LF_INVALID = 4'b1011;

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                      clk_enable;
  reg  [STATE_W-1:0]       pf_mngmt_state;
  reg  [STATE_W-1:0]       next_pf_mngmt_state;
  reg  [40:6]              pf_addr;
  reg  [3:0]               pf_stride;
  reg  [7:0]               pf_attrs;
  reg  [3:0]               pf_way;
  reg                      pf_pldw;
  reg  [1:0]               pf_throttle_cnt;
  reg                      pf_abort_pending;
  reg                      pf_lf_active_early;
  reg                      pf_lf_match_pf_pending;
  reg                      pf_lf_match_non_pf_pending;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                     clk_pf_stream;
  wire                     cache_protection;
  wire                     next_clk_enable;
  wire [40:6]              next_pf_addr;
  wire [1:0]               next_pf_throttle_cnt;
  wire [7:0]               next_pf_attrs;
  wire [3:0]               next_pf_way;
  wire                     next_pf_abort_pending;
  wire                     next_pf_lf_active_early;
  wire                     next_pf_lf_match_pf_pending;
  wire                     next_pf_lf_match_non_pf_pending;
  wire                     pf_abort;
  wire                     pf_addr_en;
  wire [16:6]              pf_addr_adder;
  wire                     pf_attrs_en;
  wire                     pf_addr_crosses_page_end;
  wire [3:0]               pf_addr_match_4k_16k_mask;
  wire                     pf_addr_match_biu_ar_page;
  wire                     pf_throttle;
  wire                     pf_throttle_cnt_clr;
  wire                     pf_throttle_cnt_en;
  wire                     pf_lf_active;
  wire                     pf_lf_active_early_en;
  wire [40:6]              lf_descr_alloc_m0_addr_gated;
  wire                     lf_descr_alloc_m0_match;
  wire                     lf_descr_alloc_m0_match_pf;
  wire                     lf_descr_alloc_m0_match_non_pf;
  wire                     lf_descr_alloc_m0_match_valid;
  wire [6:0]               pf_stream_stride;
  wire                     pf_stream_match_stride;
  wire                     pf_stream_match_4k;
  wire                     pf_stream_match;
  wire                     pf_mngmt_state_idle;
  wire                     pf_mngmt_state_addr_gen;
  wire                     pf_mngmt_state_addr_gen_lf_done;
  wire                     pf_mngmt_state_addr_page_crossed;
  wire                     pf_mngmt_state_tag_m0;
  wire                     pf_mngmt_state_tag_m1;
  wire                     pf_mngmt_state_tag_m2;
  wire                     pf_mngmt_state_tag_m3_miss;
  wire                     pf_mngmt_state_lf_req;
  wire                     pf_mngmt_state_throttle_pf_lf_invalid;
  wire                     resume_pf_mngmt_state_addr_page_crossed;

  //------------------------------------------------------------------------------
  // Parameter to signal conversion
  //------------------------------------------------------------------------------

generate if (CPU_CACHE_PROTECTION) begin : gen_biu_cache_protection_01
  assign cache_protection = 1'b1;
end else begin : gen_biu_01_else
  assign cache_protection = 1'b0;
end endgenerate

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Avoid clocking prefetch stream registers when there isn't an outstanding
  // prefetch stream or when there is no possibility of starting a new prefetch stream

  assign next_clk_enable = pf_stream_req_active_i |
                           ~pf_mngmt_state_idle;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_lf_descr (.clk_i         (clk),
                                                    .clk_enable_i  (clk_enable),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_pf_stream));

  //-----------------------------------------------------------------------------
  // Prefetch DCU M1 alloc hazard check
  // o used to cover the hazard period from the DCU TAG look-up done and until
  //   the eventual PF's LF request gets acknowledged
  //-----------------------------------------------------------------------------

  assign lf_descr_alloc_m0_addr_gated   = pf_mngmt_state_idle ? {35{1'b0}}                                                         :
                                                                {biu_alloc_lf_descr_ns_dsc_m0_i, biu_alloc_lf_descr_addr_m0_i[39:6]};
  assign lf_descr_alloc_m0_match_valid  = ~pf_mngmt_state_idle & (|biu_alloc_lf_descr_m0_i);
  assign lf_descr_alloc_m0_match        = (lf_descr_alloc_m0_addr_gated == pf_addr[40:6]);
  assign lf_descr_alloc_m0_match_pf     = lf_descr_alloc_m0_match_valid & lf_descr_alloc_m0_match &  biu_alloc_lf_descr_from_pf_m0_i;
  assign lf_descr_alloc_m0_match_non_pf = lf_descr_alloc_m0_match_valid & lf_descr_alloc_m0_match & ~biu_alloc_lf_descr_from_pf_m0_i;

  //-----------------------------------------------------------------------------
  // Prefetch stream hazard check
  //-----------------------------------------------------------------------------

  // Calculate the stride of the linefill descriptor address and the current prefetch stream address

  assign pf_stream_stride = pf_addr[11:6] - pf_stream_match_ingress_addr_i[11:6];

  // Determine whether the stride is within the matching range of -8 to 7.

  assign pf_stream_match_stride = (pf_stream_stride[6:3] == 4'hF) | (pf_stream_stride[6:3] == 4'h0);

  assign pf_stream_match_4k = (pf_stream_match_ingress_addr_i[40:12] == pf_addr[40:12]);

  assign pf_stream_match = pf_stream_match_4k & pf_stream_match_stride;

  //-----------------------------------------------------------------------------
  // Prefetch address calculation
  //-----------------------------------------------------------------------------

  // pf_addr[39:16] does not change so only need to calculate pf_addr[15:6].
  // This is based on bits [15:6] of the prev address and the pf_stride, with
  // carry bits indicating that the prefetch address is to a different page (4k, 16k or 64k).

  assign pf_addr_adder[16:6] = pf_addr[15:6]                     +
                               {{6{pf_stride[3]}}, pf_stride[3:0]};

  assign pf_addr_crosses_page_end = // 64k memory granule
                                    tlb_mem_granule_i[1] ? (pf_addr[16] ^ pf_addr_adder[16]) :
                                    // 16k memory granule
                                    tlb_mem_granule_i[0] ? (pf_addr[14] ^ pf_addr_adder[14]) :
                                    // 4k memory granule
                                                           (pf_addr[12] ^ pf_addr_adder[12]);

  assign pf_addr_match_4k_16k_mask = {{2{tlb_mem_granule_i[1]}}, {2{tlb_mem_granule_i[0]}}};

  assign pf_addr_match_biu_ar_page = (pf_addr[11:6] == biu_ar_addr_i[11:6])                                                             &
                                     ((pf_addr[15:12] & pf_addr_match_4k_16k_mask) == (biu_ar_addr_i[15:12] & pf_addr_match_4k_16k_mask));

  assign resume_pf_mngmt_state_addr_page_crossed = pf_addr_match_biu_ar_page & pf_stream_eligible_for_pf_lf_init_i;

  assign next_pf_addr[40:16] = pf_mngmt_state_idle                                                          ? pf_stream_addr_i[40:16] :
                               (pf_mngmt_state_addr_page_crossed & resume_pf_mngmt_state_addr_page_crossed) ? biu_ar_addr_i[40:16]    :
                                                                                                              pf_addr[40:16];

  assign next_pf_addr[15:6] = pf_mngmt_state_idle                                                          ? pf_stream_addr_i[15:6] :
                              (pf_mngmt_state_addr_page_crossed & resume_pf_mngmt_state_addr_page_crossed) ? biu_ar_addr_i[15:6]    :
                                                                                                             pf_addr_adder[15:6];

  // Update the prefetch address when:
  // o FSM state is STATE_IDLE/STATE_ADDR_GEN/STATE_ADDR_GEN_LF_DONE
  // o FSM state is STATE_ADDR_PAGE_CROSSED and the resume condition has been met

  assign pf_addr_en = pf_mngmt_state_idle                                                        |
                      pf_mngmt_state_addr_gen                                                    |
                      pf_mngmt_state_addr_gen_lf_done                                            |
                      (pf_mngmt_state_addr_page_crossed & resume_pf_mngmt_state_addr_page_crossed);

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_addr[40:6] <= {35{1'b0}};
    end else if (pf_addr_en) begin
      pf_addr[40:6] <= next_pf_addr[40:6];
    end

  //-----------------------------------------------------------------------------
  // Prefetch linefill way computation
  //-----------------------------------------------------------------------------

  // Round-robin counter used to compute the linefill way of the prefetch stream:
  // o select a random way when a new prefetch stream is started
  // o keep the same way once a prefetch stream started

  assign next_pf_way = {pf_way[2:0], pf_way[3]};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pf_way <= 4'h1;
    end else if (pf_mngmt_state_idle) begin
      pf_way <= next_pf_way;
    end

  //-----------------------------------------------------------------------------
  // Prefetch mem attributes, way and LF master info
  //-----------------------------------------------------------------------------

  // Initialize the mem attributes upon starting a new prefetch stream or when
  // resuming from the STATE_ADDR_PAGE_CROSSED state

  assign pf_attrs_en = pf_mngmt_state_idle                                                        |
                       (pf_mngmt_state_addr_page_crossed & resume_pf_mngmt_state_addr_page_crossed);

  assign next_pf_attrs = pf_mngmt_state_idle ? pf_stream_attrs_i :
                                               biu_ar_attrs_i;

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_attrs <= {8{1'b0}};
    end else if (pf_attrs_en) begin
      pf_attrs <= next_pf_attrs;
    end

  // Initialize the way and the linefill master upon starting a new prefetch stream

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_stride <= {4{1'b0}};
      pf_pldw   <= 1'b0;
    end else if (pf_mngmt_state_idle) begin
      pf_stride <= pf_stream_stride_i;
      pf_pldw   <= pf_stream_pldw_i;
    end

  //-----------------------------------------------------------------------------
  // Prefetch abort control state
  //-----------------------------------------------------------------------------

  assign pf_abort              = pf_stream_abort_i | pf_abort_pending;

  assign next_pf_abort_pending = (pf_stream_abort_i | pf_abort_pending)        &
                                 (pf_mngmt_state_tag_m0 | pf_mngmt_state_tag_m1);

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_abort_pending <= 1'b0;
    end else begin
      pf_abort_pending <= next_pf_abort_pending;
    end

  //-----------------------------------------------------------------------------
  // Prefetch linefills descriptors hazard control state
  //-----------------------------------------------------------------------------

  assign next_pf_lf_match_pf_pending     = (lf_descr_alloc_m0_match_pf |
                                            pf_lf_match_pf_pending      ) &
                                           (pf_mngmt_state_tag_m0 |
                                            pf_mngmt_state_tag_m1 |
                                            pf_mngmt_state_tag_m2         );

  assign next_pf_lf_match_non_pf_pending = (lf_descr_alloc_m0_match_non_pf |
                                            pf_lf_match_non_pf_pending      ) &
                                           (pf_mngmt_state_tag_m0 |
                                            pf_mngmt_state_tag_m1 |
                                            pf_mngmt_state_tag_m2             );

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_lf_match_pf_pending     <= 1'b0;
      pf_lf_match_non_pf_pending <= 1'b0;
    end else begin
      pf_lf_match_pf_pending     <= next_pf_lf_match_pf_pending;
      pf_lf_match_non_pf_pending <= next_pf_lf_match_non_pf_pending;
    end

  //-----------------------------------------------------------------------------
  // Prefetch throttle counter
  //-----------------------------------------------------------------------------

  // Set the throttle flag when the counter reaches three consecutive linefills
  // initiated by the prefetcher.

  assign pf_throttle          = (pf_throttle_cnt == 2'b10);

  // The throttle counter is cleared when a new prefetch streams is started or
  // when a prefetch stream hits a linefill iniated by the DCU or STB.

  assign pf_throttle_cnt_clr  = pf_mngmt_state_idle              |
                                pf_mngmt_state_addr_page_crossed |
                                dcu_stb_match_lf_from_pf_i       |
                                pf_lf_match_non_pf_i             |
                                lf_descr_alloc_m0_match_non_pf;

  assign next_pf_throttle_cnt = {2{~pf_throttle_cnt_clr}} &
                                (pf_throttle_cnt + 1'b1   );

  assign pf_throttle_cnt_en   = pf_throttle_cnt_clr                            |
                                (~pf_throttle & pf_mngmt_state_addr_gen_lf_done);

  always @(posedge clk_pf_stream)
    if (pf_throttle_cnt_en) begin
      pf_throttle_cnt <= next_pf_throttle_cnt;
    end

  //-----------------------------------------------------------------------------
  // Prefetch linefill request active
  //-----------------------------------------------------------------------------

  assign pf_lf_active = (~cache_protection & pf_mngmt_state_tag_m2)      |
                        (cache_protection  & pf_mngmt_state_tag_m3_miss) |
                        pf_mngmt_state_lf_req;

  // In order to ease the timing closure, provide a speculative/earlier version of the
  // active signal which needs to be factorized to the BIU AR active sent to the SCU.
  
  assign next_pf_lf_active_early = (~cache_protection                             &
                                     (pf_mngmt_state_tag_m1 | pf_mngmt_state_tag_m2))      |
                                    (cache_protection                                   &
                                     (pf_mngmt_state_tag_m2 | pf_mngmt_state_tag_m3_miss)) |
                                    pf_mngmt_state_lf_req;

  assign pf_lf_active_early_en   = ~pf_mngmt_state_idle | pf_lf_active_early;

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_lf_active_early <= 1'b0;
    end else if (pf_lf_active_early_en) begin
      pf_lf_active_early <= next_pf_lf_active_early;
    end

  //-----------------------------------------------------------------------------
  // Data prefetcher management FSM
  //-----------------------------------------------------------------------------

  always @* begin
    case (pf_mngmt_state)
      STATE_IDLE:
        if (pf_abort                 ||
            pf_stream_match_egress_hz_i) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_stream_req_i) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else begin
          next_pf_mngmt_state = STATE_IDLE;
        end

      STATE_ADDR_GEN_LF_DONE:
        if (pf_abort) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_addr_crosses_page_end) begin
          next_pf_mngmt_state = STATE_ADDR_PAGE_CROSSED;
        end else if (pf_throttle) begin
          next_pf_mngmt_state = STATE_THROTTLE;
        end else begin
          next_pf_mngmt_state = STATE_TAG_M0;
        end

      STATE_ADDR_GEN:
        if (pf_abort                ||
            pf_lf_match_pf_i        ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_addr_crosses_page_end) begin
          next_pf_mngmt_state = STATE_ADDR_PAGE_CROSSED;
        end else begin
          next_pf_mngmt_state = STATE_TAG_M0;
        end

      STATE_ADDR_PAGE_CROSSED:
        if (pf_abort                                               ||
            (resume_pf_mngmt_state_addr_page_crossed              &&
             (`CA53_BIU_LF_FOR_WRITE(biu_ar_lf_master_i) != pf_pldw))) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (resume_pf_mngmt_state_addr_page_crossed) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else if (pf_stream_lf_used_i) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else begin
          next_pf_mngmt_state = STATE_ADDR_PAGE_CROSSED;
        end

      STATE_TAG_M0:
        if (dcu_pf_tag_has_priority_m0_i) begin
          next_pf_mngmt_state = STATE_TAG_M1;
        end else if (lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (lf_descr_alloc_m0_match_non_pf) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else begin
          next_pf_mngmt_state = STATE_TAG_M0;
        end

      STATE_TAG_M1:
        if (dcu_pf_tag_ack_m1_i) begin
          next_pf_mngmt_state = STATE_TAG_M2;
        end else begin
          next_pf_mngmt_state = STATE_TAG_M1;
        end

      STATE_TAG_M2:
        if (pf_abort) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_lf_match_pf_pending  ||
                     lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (!cache_protection) begin
          // ECC disabled branch
          if (dcu_pf_tag_hit_m2_i         ||
              pf_lf_match_non_pf_pending  ||
              lf_descr_alloc_m0_match_non_pf) begin
            next_pf_mngmt_state = STATE_ADDR_GEN;
          end else begin
            next_pf_mngmt_state = STATE_LF_REQ;
          end
        end else begin
          // ECC enabled branch
          if (dcu_pf_tag_hit_m2_i) begin
            next_pf_mngmt_state = STATE_TAG_M3_HIT;
          end else begin
            next_pf_mngmt_state = STATE_TAG_M3_MISS;
          end
        end

      // ECC enabled FSM state, only.
      STATE_TAG_M3_HIT:
        if (pf_abort                ||
            dcu_ecc_tag_err_m3_i    ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end

      // ECC enabled FSM state, only.
      STATE_TAG_M3_MISS:
        if (pf_abort                ||
            dcu_ecc_tag_err_m3_i    ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_lf_match_non_pf_pending  ||
                     lf_descr_alloc_m0_match_non_pf) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else begin
          next_pf_mngmt_state = STATE_LF_REQ;
        end

      STATE_LF_REQ:
        if (pf_abort                ||
            pf_lf_match_pf_i        ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (pf_lf_match_non_pf_i        ||
                     lf_descr_alloc_m0_match_non_pf) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else if (pf_lf_ack_i) begin
          next_pf_mngmt_state = STATE_ADDR_GEN_LF_DONE;
        end else begin
          next_pf_mngmt_state = STATE_LF_REQ;
        end

      STATE_THROTTLE:
        if (pf_abort                ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (lf_descr_alloc_m0_match_non_pf     ||
                     (pf_stream_match_4k               &&
                      pf_addr_match_biu_ar_page        &&
                      pf_stream_eligible_for_pf_lf_init_i)) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else if (!pf_throttle            ||
                     dcu_stb_match_lf_from_pf_i) begin
          next_pf_mngmt_state = STATE_TAG_M0;
        end else if (~lf_descr_from_pf_stream_valid_i) begin
          next_pf_mngmt_state = STATE_THROTTLE_PF_LF_INVALID;
        end else begin
          next_pf_mngmt_state = STATE_THROTTLE;
        end

      STATE_THROTTLE_PF_LF_INVALID:
        if (pf_abort                ||
            lf_descr_alloc_m0_match_pf) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else if (lf_descr_alloc_m0_match_non_pf     ||
                     (pf_stream_match_4k               &&
                      pf_addr_match_biu_ar_page        &&
                      pf_stream_eligible_for_pf_lf_init_i)) begin
          next_pf_mngmt_state = STATE_ADDR_GEN;
        end else if (dcu_stb_match_lf_from_pf_i) begin
          next_pf_mngmt_state = STATE_TAG_M0;
        end else if (pf_stream_cancel_throttle_i) begin
          next_pf_mngmt_state = STATE_IDLE;
        end else begin
          next_pf_mngmt_state = STATE_THROTTLE_PF_LF_INVALID;
        end

      default: begin
        next_pf_mngmt_state = {STATE_W{1'bx}};
      end
    endcase
  end

  always @(posedge clk_pf_stream or negedge reset_n)
    if (~reset_n) begin
      pf_mngmt_state <= STATE_IDLE;
    end else begin
      pf_mngmt_state <= next_pf_mngmt_state;
    end

  //-----------------------------------------------------------------------------
  // Decode states
  //-----------------------------------------------------------------------------

  assign pf_mngmt_state_idle                   = (pf_mngmt_state == STATE_IDLE);
  assign pf_mngmt_state_addr_gen               = (pf_mngmt_state == STATE_ADDR_GEN);
  assign pf_mngmt_state_addr_gen_lf_done       = (pf_mngmt_state == STATE_ADDR_GEN_LF_DONE);
  assign pf_mngmt_state_addr_page_crossed      = (pf_mngmt_state == STATE_ADDR_PAGE_CROSSED);
  assign pf_mngmt_state_tag_m0                 = (pf_mngmt_state == STATE_TAG_M0);
  assign pf_mngmt_state_tag_m1                 = (pf_mngmt_state == STATE_TAG_M1);
  assign pf_mngmt_state_tag_m2                 = (pf_mngmt_state == STATE_TAG_M2);
  assign pf_mngmt_state_tag_m3_miss            = (pf_mngmt_state == STATE_TAG_M3_MISS);
  assign pf_mngmt_state_lf_req                 = (pf_mngmt_state == STATE_LF_REQ);
  assign pf_mngmt_state_throttle_pf_lf_invalid = (pf_mngmt_state == STATE_THROTTLE_PF_LF_INVALID);

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  // PF stream status

  assign pf_stream_idle_o     = pf_mngmt_state_idle;
  assign pf_stream_throttle_o = pf_mngmt_state_throttle_pf_lf_invalid;

  // PF stream hazards interface

  assign pf_stream_match_ingress_hz_o = ~pf_mngmt_state_idle & pf_stream_match;

  // PF DCU TAG interface

  assign biu_pf_tag_active_o    = pf_mngmt_state_addr_gen_lf_done |
                                  pf_mngmt_state_addr_gen         |
                                  pf_mngmt_state_tag_m0;
  assign biu_pf_tag_req_m0_o    = pf_mngmt_state_tag_m0;
  assign biu_pf_tag_req_m1_o    = pf_mngmt_state_tag_m1;
  assign biu_pf_tag_addr_m0_o   = pf_addr[39:6];
  assign biu_pf_tag_ns_dsc_m0_o = pf_addr[40];

  // PF LF req interface

  assign pf_lf_active_early_o = pf_lf_active_early;
  assign pf_lf_active_o       = pf_lf_active;
  assign pf_lf_req_o          = pf_mngmt_state_lf_req & ~pf_stream_abort_i;
  assign pf_lf_addr_o         = pf_addr[40:6];
  assign pf_lf_attrs_o        = pf_attrs;
  assign pf_lf_way_o          = pf_way;
  assign pf_lf_pldw_o         = pf_pldw;

`ifdef ARM_ASSERT_ON

  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_addr_en")
  u_ovl_x_pf_addr_en    (.clk       (clk_pf_stream),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_addr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_attrs_en")
  u_ovl_x_pf_attrs_en   (.clk       (clk_pf_stream),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_attrs_en));

  assert_never_unknown  #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_mngmt_state_idle")
  u_ovl_x_pf_mngmt_state_idle (.clk       (clk_pf_stream),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (pf_mngmt_state_idle));

  assert_never_unknown      #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_throttle_cnt_en")
  u_ovl_x_pf_throttle_cnt_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (pf_throttle_cnt_en));

  assert_never_unknown          #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pf_lf_active_early_en")
  u_ovl_x_pf_lf_active_early_en  (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (pf_lf_active_early_en));

  assert_never_unknown   #(`OVL_FATAL, STATE_W, `OVL_ASSERT, "Register enable x-check: pf_mngmt_state")
  u_ovl_x_pf_mngmt_state  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (pf_mngmt_state));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is a potential access to/from the data prefetch stream")
  u_ovl_pf_mngmt_01     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr ((pf_stream_req_i     |
                                            biu_pf_tag_req_m0_o |
                                            pf_lf_req_o          )),
                         .consequent_expr (clk_enable));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled or prefetch stream idle when the linefill active is asserted")
  u_ovl_pf_mngmt_02     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_lf_active_o),
                         .consequent_expr (clk_enable | pf_mngmt_state_idle));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pf_abort_pending must never be unknown")
  u_ovl_pf_mngmt_03     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_abort_pending));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "pf_way must never be unknown")
  u_ovl_pf_mngmt_04     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_way));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "pf_throttle_cnt must never be unknown when the prefetch stream is not idle")
  u_ovl_pf_mngmt_05     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (~pf_mngmt_state_idle),
                         .test_expr (pf_throttle_cnt));

  assert_never_unknown #(`OVL_FATAL, 35, `OVL_ASSERT, "pf_addr must never be unknown when the prefetch stream is not idle")
  u_ovl_pf_mngmt_06     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (~pf_mngmt_state_idle),
                         .test_expr (pf_addr));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "pf_attrs must never be unknown when the prefetch stream is not idle")
  u_ovl_pf_mngmt_07     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (~pf_mngmt_state_idle),
                         .test_expr (pf_attrs));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "pf_stride must never be unknown when the prefetch stream is not idle")
  u_ovl_pf_mngmt_08     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (~pf_mngmt_state_idle),
                         .test_expr (pf_stride));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "Only some pf_mngmt_state states are valid when ECC enabled")
  u_ovl_pf_mngmt_09     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (cache_protection),
                         .consequent_expr ((pf_mngmt_state == STATE_IDLE                  ) ||
                                           (pf_mngmt_state == STATE_ADDR_GEN              ) ||
                                           (pf_mngmt_state == STATE_ADDR_GEN_LF_DONE      ) ||
                                           (pf_mngmt_state == STATE_ADDR_PAGE_CROSSED     ) ||
                                           (pf_mngmt_state == STATE_TAG_M0                ) ||
                                           (pf_mngmt_state == STATE_TAG_M1                ) ||
                                           (pf_mngmt_state == STATE_TAG_M2                ) ||
                                           (pf_mngmt_state == STATE_TAG_M3_HIT            ) ||
                                           (pf_mngmt_state == STATE_TAG_M3_MISS           ) ||
                                           (pf_mngmt_state == STATE_LF_REQ                ) ||
                                           (pf_mngmt_state == STATE_THROTTLE              ) ||
                                           (pf_mngmt_state == STATE_THROTTLE_PF_LF_INVALID)   ));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "Only some pf_mngmt_state states are valid when ECC disabled")
  u_ovl_pf_mngmt_10     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (!cache_protection),
                         .consequent_expr ((pf_mngmt_state == STATE_IDLE                  ) ||
                                           (pf_mngmt_state == STATE_ADDR_GEN              ) ||
                                           (pf_mngmt_state == STATE_ADDR_GEN_LF_DONE      ) ||
                                           (pf_mngmt_state == STATE_ADDR_PAGE_CROSSED     ) ||
                                           (pf_mngmt_state == STATE_TAG_M0                ) ||
                                           (pf_mngmt_state == STATE_TAG_M1                ) ||
                                           (pf_mngmt_state == STATE_TAG_M2                ) ||
                                           (pf_mngmt_state == STATE_LF_REQ                ) ||
                                           (pf_mngmt_state == STATE_THROTTLE              ) ||
                                           (pf_mngmt_state == STATE_THROTTLE_PF_LF_INVALID)   ));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pf_lf_active must never be unknown")
  u_ovl_pf_mngmt_11     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pf_lf_active));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "PF hazards not expected while in STATE_ADDR_GEN_LF_DONE")
  u_ovl_pf_mngmt_12     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_lf_match_pf_i           ||
                                           pf_lf_match_non_pf_i       ||
                                           lf_descr_alloc_m0_match_pf ||
                                           lf_descr_alloc_m0_match_non_pf),
                         .consequent_expr ((pf_mngmt_state != STATE_ADDR_GEN_LF_DONE)));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "PF hazards not expected while in STATE_TAG_M3_HIT")
  u_ovl_pf_mngmt_13     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_lf_match_pf_i    ||
                                           pf_lf_match_pf_pending),
                         .consequent_expr ((pf_mngmt_state != STATE_TAG_M3_HIT)));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "PF hazards not expected while in STATE_TAG_M3_MISS")
  u_ovl_pf_mngmt_14     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_lf_match_pf_i       ||
                                           pf_lf_match_pf_pending ||
                                           pf_lf_match_non_pf_i),
                         .consequent_expr ((pf_mngmt_state != STATE_TAG_M3_MISS)));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "PF stream cancel not expected while in STATE_ADDR_PAGE_CROSSED")
  u_ovl_pf_mngmt_15     (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pf_stream_cancel_throttle_i),
                         .consequent_expr ((pf_mngmt_state != STATE_ADDR_PAGE_CROSSED)));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_prefetch_stream_mngmt
