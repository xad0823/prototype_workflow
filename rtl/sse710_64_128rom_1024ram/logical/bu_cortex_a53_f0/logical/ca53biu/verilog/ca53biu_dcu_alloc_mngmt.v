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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : BIU DCU allocation management
//-----------------------------------------------------------------------------
//
// Overview
// -------
// Management of the linefills allocation into the DCU
// Release of the linefill read buffers

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_dcu_alloc_mngmt
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                                                     clk,
   input  wire                                                     reset_n,
   input  wire                                                     DFTSE,

   //----------------------------------------------------------------------------
   // MBIST
   //----------------------------------------------------------------------------

   input  wire                                                     biu_mbist_req_i,

   //------------------------------------------------------------------------------
   // BIU linefill active
   //------------------------------------------------------------------------------

   input  wire                                                     biu_lf_active_i,

   //------------------------------------------------------------------------------
   // DCU allocation interface
   //------------------------------------------------------------------------------

   output wire [255:0]                                             biu_alloc_data_m0_o,
   output wire                                                     biu_alloc_tag_req_m0_o,
   output wire                                                     biu_alloc_data_req_m0_o,
   output wire                                                     biu_alloc_halfline_m0_o,
   output wire                                                     biu_alloc_dirty_req_m0_o,
   output wire [39:4]                                              biu_alloc_addr_m0_o,
   output wire                                                     biu_alloc_ns_dsc_m0_o,
   output wire [3:0]                                               biu_alloc_way_m0_o,
   output wire [1:0]                                               biu_alloc_tag_moesi_m0_o,
   input  wire                                                     dcu_alloc_has_priority_m0_i,
   output wire [1:0]                                               biu_alloc_dirty_moesi_m1_o,
   output wire                                                     biu_alloc_dirty_age_m1_o,
   output wire [7:0]                                               biu_alloc_attrs_m1_o,
   input  wire                                                     dcu_alloc_ack_m1_i,

   //------------------------------------------------------------------------------
   // STB Interface
   //------------------------------------------------------------------------------

   input  wire [5:4]                                               stb_slot0_addr_i,
   input  wire [5:4]                                               stb_slot1_addr_i,
   input  wire [5:4]                                               stb_slot2_addr_i,
   input  wire [5:4]                                               stb_slot3_addr_i,
   input  wire [5:4]                                               stb_slot4_addr_i,
   input  wire [4:0]                                               stb_slot_cachewrite_m1_i,

   //------------------------------------------------------------------------------
   // BIU Read buffers interface
   //------------------------------------------------------------------------------

   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_valid_i,
   input  wire [128*`CA53_BIU_RBUFS_NUM-1:0]                       rbuf_data_packed_i,
   input  wire [2*`CA53_BIU_RBUFS_NUM-1:0]                         rbuf_chunk_packed_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM_W*`CA53_BIU_RBUFS_NUM-1:0]  rbuf_id_packed_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_age_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_valid_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_oldest_sel_i,
   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           biu_alloc_rbuf_clr_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m0_o,
   output wire [3:0]                                               biu_alloc_chunk_req_m0_o,
   output wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m1_o,
   output wire [3:0]                                               biu_alloc_chunk_req_m1_o,
   output wire                                                     biu_alloc_last_m1_o,

   //------------------------------------------------------------------------------
   // Linefill descriptors interface
   //------------------------------------------------------------------------------

   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_valid_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_unique_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_evict_done_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_fetched_none_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_tag_done_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_tag_err_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_err_from_scu_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_migratory_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_passed_as_dirty_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_ns_dsc_i,
   input  wire [34*`CA53_BIU_LF_DESCR_NUM-1:0]                     lf_descr_addr_packed_i,
   input  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_way_packed_i,
   input  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_chunk_fetched_from_scu_packed_i,
   input  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_chunk_allocated_from_stb_packed_i,
   input  wire [4*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_chunk_need_release_packed_i,
   input  wire [5*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_match_stb_packed_i,
   input  wire [8*`CA53_BIU_LF_DESCR_NUM-1:0]                      lf_descr_attrs_packed_i
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                                           clk_enable;
  reg  [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_alloc_lf_descr_m0;
  reg  [4:0]                                    biu_alloc_stb_slot_pend_m0;
  reg  [3:0]                                    biu_alloc_chunk_req_m0;
  reg  [5:4]                                    biu_alloc_addr_qw_m0;
  reg  [255:0]                                  biu_alloc_data_m0;
  reg                                           biu_alloc_last_m0;
  reg                                           biu_alloc_halfline_m0;
  reg                                           biu_alloc_age_m0;
  reg                                           biu_alloc_tag_err_m0;
  reg  [`CA53_BIU_LF_DESCR_NUM-1:0]             biu_alloc_lf_descr_m1;
  reg  [3:0]                                    biu_alloc_chunk_req_m1;
  reg                                           biu_alloc_last_m1;
  reg                                           biu_alloc_age_m1;
  reg  [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_alloc_nodata_rr_sel;
  reg  [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_err_nodata_rr_sel;
  reg  [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_rbuf_oldest_sel;
  reg  [3:0]                                    rbuf_chunk_fetched_from_scu [`CA53_BIU_RBUFS_NUM-1:0];
  reg  [3:0]                                    rbuf_chunk_need_release [`CA53_BIU_RBUFS_NUM-1:0];

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                          clk_dcu_alloc;
  wire                                          next_clk_enable;
  wire [3:0]                                    rbuf_chunk_contiguous [`CA53_BIU_RBUFS_NUM-1:0];
  wire [1:0]                                    rbuf_chunk_addr [`CA53_BIU_RBUFS_NUM-1:0];
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_hl_left;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_hl_right;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_hl_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_last_alloc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_fetched_last;
  wire                                          rbuf_oldest_halfline;
  wire                                          rbuf_oldest_last_alloc;
  wire                                          rbuf_oldest_age;
  wire [3:0]                                    rbuf_oldest_chunk_contiguous;
  wire [1:0]                                    rbuf_oldest_chunk_addr;
  wire                                          rbuf_oldest_valid;
  wire [127:0]                                  rbuf_data [`CA53_BIU_RBUFS_NUM-1:0];
  wire [3:0]                                    rbuf_chunk [`CA53_BIU_RBUFS_NUM-1:0];
  wire [1:0]                                    rbuf_chunk_bin [`CA53_BIU_RBUFS_NUM-1:0];
  wire [`CA53_BIU_LF_DESCR_NUM_W-1:0]           rbuf_id [`CA53_BIU_RBUFS_NUM-1:0];
  wire                                          rbuf_for_lf_oldest_valid;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_for_mbist_valid;
  wire [39:6]                                   biu_alloc_addr_m0;
  wire                                          biu_alloc_ns_dsc_m0;
  wire [3:0]                                    biu_alloc_way_m0;
  wire [3:0]                                    biu_alloc_chunk_allocated_from_stb_m0;
  wire                                          biu_alloc_data_req_m0;
  wire                                          biu_alloc_tag_req_m0;
  wire                                          biu_alloc_dirty_req_m0;
  wire [1:0]                                    biu_alloc_tag_moesi_m0;
  wire                                          biu_alloc_err_from_scu_m0;
  wire                                          biu_alloc_unique_m0;
  wire                                          biu_alloc_migratory_m0;
  wire                                          biu_alloc_lf_descr_m0_stall;
  wire                                          biu_alloc_lf_descr_valid_m0;
  wire                                          biu_alloc_leave_m0;
  wire                                          biu_alloc_rdy_m0;
  wire                                          biu_alloc_en_m0;
  wire [7:0]                                    biu_alloc_attrs_m1;
  wire [3:0]                                    biu_alloc_chunk_allocated_from_stb_m1;
  wire [3:0]                                    biu_alloc_chunk_alloc_stb_m1;
  wire                                          biu_alloc_lf_descr_valid_m1;
  wire                                          biu_alloc_en_m1;
  wire                                          biu_alloc_migratory_m1;
  wire                                          biu_alloc_passed_as_dirty_m1;
  wire [1:0]                                    biu_alloc_dirty_moesi_m1;
  wire [3:0]                                    next_biu_alloc_chunk_req_m0;
  wire                                          next_biu_alloc_last_m0;
  wire [5:4]                                    next_biu_alloc_addr_qw_m0;
  wire                                          next_biu_alloc_halfline_m0;
  wire                                          next_biu_alloc_age_m0;
  wire                                          next_biu_alloc_tag_err_m0;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             next_biu_alloc_lf_descr_m0;
  wire [4:0]                                    next_biu_alloc_stb_slot_pend_m0;
  wire                                          next_biu_alloc_last_m1;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             next_biu_alloc_lf_descr_m1;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             current_biu_alloc_lf_descr_m0;
  wire [3:0]                                    current_biu_alloc_chunk_req_m0;
  wire                                          current_biu_alloc_halfline_m0;
  wire [5:4]                                    current_biu_alloc_addr_qw_m0;
  wire [4:0]                                    current_biu_alloc_stb_slot_pend_m0;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_alloc_sel;
  wire [39:6]                                   lf_descr_addr [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_way [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [7:0]                                    lf_descr_attrs [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_fetched_from_scu [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_need_release [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [3:0]                                    lf_descr_chunk_allocated_from_stb [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [4:0]                                    lf_descr_match_stb [`CA53_BIU_LF_DESCR_NUM-1:0];
  wire [4:0]                                    lf_descr_match_stb_oldest;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_alloc_nodata_valid;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_alloc_nodata_arb;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_alloc_nodata_sel;
  wire [`CA53_BIU_LF_DESCR_NUM_W-1:0]           lf_descr_tag_alloc_nodata_rr_sel_bin;
  wire                                          lf_descr_tag_alloc_nodata_rr_sel_en;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_err_nodata_valid;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_err_nodata_arb;
  wire [`CA53_BIU_LF_DESCR_NUM-1:0]             lf_descr_tag_err_nodata_sel;
  wire [`CA53_BIU_LF_DESCR_NUM_W-1:0]           lf_descr_tag_err_nodata_rr_sel_bin;
  wire                                          lf_descr_tag_err_nodata_rr_sel_en;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_clr_from_m0;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                rbuf_clr_from_m1;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                        index_i;

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Enable the DCU alloc clock when there is a potential access to the DCU alloc next clock cycle

  assign next_clk_enable = biu_lf_active_i   |
                           (|lf_descr_valid_i);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_lf_descr (.clk_i         (clk),
                                                    .clk_enable_i  (clk_enable),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_dcu_alloc));

  //------------------------------------------------------------------------------
  // BIU's L1 data cache allocation management handles:
  // - Arbitration for the M0 stage in between the valid read buffers and tag only allocation
  // - BIU M0 L1 data cache allocation pending transaction:
  //   o update the M0 stage status upon the M0 prioririty given to the BIU or new allocation
  //   transaction moved to the M0 stage
  //   o re-compute the current M0 addr[5:4], chunks and halfline for lines uniques which got
  //   merged from the STB in M1
  //   o stalls the M0 stage if the M0 registered chunks don't match the current M0 status
  //   and thus allow usage of the registered M0 chunks and address for the forward paths from
  //   the read buffers in order to ease the timing closure
  //   o allocate the valid TAG along the first L1 cache allocation to the corresponding
  //   line from the BIU (TAG only or TAG/data L1 data cache allocation)
  //   o determine if the Dirty update is needed once the last chunk is pending in MO, if there
  //   isn't an abort pending to the corresponding linefill
  //   o invalidte the Tag, if there is an abort pending to the corresponding linefill,
  //   decoupled from the Data/Dirty update in order to allow the STB to assert a potential
  //   LF merge
  // - BIU M1 L1 data cache allocation pending transaction:
  //   o progress the M0 to M1 following the M0 prioririty given to the BIU
  //   o update the M1 stage status upon the M1 acknowledge received from the DCU
  // - Release of the linefill read buffers when:
  //   o the corresponding chunks reached M0 and STB merged them
  //   o the corresponding chunks are allocated in L1 cache
  //     (done in M1 upon the acknowledge received from the DCU)
  //------------------------------------------------------------------------------

  // Unpack the linefill descriptors arrays
  generate
    for (index_i = 0; index_i < `CA53_BIU_LF_DESCR_NUM; index_i = index_i + 1) begin : gen_unpack_lf_descr_arrays
      assign lf_descr_addr                     [index_i] = lf_descr_addr_packed_i                     [34*index_i+33:34*index_i];
      assign lf_descr_way                      [index_i] = lf_descr_way_packed_i                      [4*index_i+3:4*index_i];
      assign lf_descr_chunk_fetched_from_scu   [index_i] = lf_descr_chunk_fetched_from_scu_packed_i   [4*index_i+3:4*index_i];
      assign lf_descr_chunk_allocated_from_stb [index_i] = lf_descr_chunk_allocated_from_stb_packed_i [4*index_i+3:4*index_i];
      assign lf_descr_chunk_need_release       [index_i] = lf_descr_chunk_need_release_packed_i       [4*index_i+3:4*index_i];
      assign lf_descr_match_stb                [index_i] = lf_descr_match_stb_packed_i                [5*index_i+4:5*index_i];
      assign lf_descr_attrs                    [index_i] = lf_descr_attrs_packed_i                    [8*index_i+7:8*index_i];
    end
  endgenerate

  // Unpack the read buffer arrays
  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_unpack_rbuf_arrays
      assign rbuf_id        [index_i] = rbuf_id_packed_i            [`CA53_BIU_LF_DESCR_NUM_W*index_i+`CA53_BIU_LF_DESCR_NUM_W-1:`CA53_BIU_LF_DESCR_NUM_W*index_i];
      assign rbuf_data      [index_i] = rbuf_data_packed_i          [128*index_i+127:128*index_i];
      assign rbuf_chunk     [index_i] = 4'h1 << rbuf_chunk_packed_i [2*index_i+1:2*index_i];
      assign rbuf_chunk_bin [index_i] = rbuf_chunk_packed_i         [2*index_i+1:2*index_i];
    end
  endgenerate

  // Get the linefill descriptor ID of the oldest read buffer which contains cacheable data
  // (direct mapped with the corresponding transaction ID from the read buffer)

  assign rbuf_for_lf_oldest_valid = |rbuf_for_lf_oldest_sel_i;

  always @* begin : rbuf_oldest_mux
    integer                            index_k;
    reg [`CA53_BIU_LF_DESCR_NUM_W-1:0] tmp_rbuf_oldest_id;

    tmp_rbuf_oldest_id = {`CA53_BIU_LF_DESCR_NUM_W{1'b0}};

    for (index_k = 0; index_k < `CA53_BIU_RBUFS_NUM; index_k = index_k + 1) begin
      tmp_rbuf_oldest_id = tmp_rbuf_oldest_id                                               |
                           ({`CA53_BIU_LF_DESCR_NUM_W{rbuf_for_lf_oldest_sel_i[index_k]}} &
                            rbuf_id[index_k][`CA53_BIU_LF_DESCR_NUM_W-1:0]                 );
    end

    lf_descr_rbuf_oldest_sel = (`CA53_BIU_LF_DESCR_NUM'd1 << tmp_rbuf_oldest_id);
  end

  // Compute the linefill descriptors which require tag allocation for unique lines which haven't received any chunk from the SCU

  assign lf_descr_tag_alloc_nodata_valid = lf_descr_valid_i        &
                                           lf_descr_unique_i       &
                                           lf_descr_evict_done_i   &
                                           lf_descr_fetched_none_i &
                                           ~lf_descr_tag_done_i    &
                                           ~biu_alloc_lf_descr_m0  &
                                           ~biu_alloc_lf_descr_m1;

  // Pick one of the linefill descriptors which require tag allocation for unique lines based on round robin basis

  assign lf_descr_tag_alloc_nodata_rr_sel_bin = `CA53_BIU_ONEHOT2BIN_8_3(lf_descr_tag_alloc_nodata_rr_sel);

  ca53_rr_arb #(.WIDTH(`CA53_BIU_LF_DESCR_NUM)) u_biu_lf_descr_tag_alloc_nodata_arb (
    .clk          (clk_dcu_alloc),
    .reset_n      (reset_n),
    .rr_counter_i (lf_descr_tag_alloc_nodata_rr_sel_bin),
    .requests_i   (lf_descr_tag_alloc_nodata_valid[`CA53_BIU_LF_DESCR_NUM-1:0]),
    .arb_o        (lf_descr_tag_alloc_nodata_arb[`CA53_BIU_LF_DESCR_NUM-1:0])
  );

  assign lf_descr_tag_alloc_nodata_rr_sel_en   = ~|(lf_descr_tag_alloc_nodata_valid & lf_descr_tag_alloc_nodata_rr_sel);

  always @(posedge clk_dcu_alloc or negedge reset_n)
  if (~reset_n) begin
    lf_descr_tag_alloc_nodata_rr_sel <= {`CA53_BIU_LF_DESCR_NUM{1'b0}};
  end else if (lf_descr_tag_alloc_nodata_rr_sel_en) begin
    lf_descr_tag_alloc_nodata_rr_sel <= lf_descr_tag_alloc_nodata_arb;
  end

  assign lf_descr_tag_alloc_nodata_sel = lf_descr_tag_alloc_nodata_valid & lf_descr_tag_alloc_nodata_rr_sel;

  // Compute the linefill descriptors which require tag invalidation for lines which allocated all chunks,
  // received all chunks from SCU and no chunk pending into the read buffers.

  assign lf_descr_tag_err_nodata_valid = lf_descr_valid_i       &
                                         lf_descr_tag_err_i     &
                                         ~biu_alloc_lf_descr_m0 &
                                         ~biu_alloc_lf_descr_m1;

  // Pick one of the linefill descriptors which require tag invalidation based on round robin basis

  assign lf_descr_tag_err_nodata_rr_sel_bin = `CA53_BIU_ONEHOT2BIN_8_3(lf_descr_tag_err_nodata_rr_sel);

  ca53_rr_arb #(.WIDTH(`CA53_BIU_LF_DESCR_NUM)) u_biu_lf_descr_tag_err_nodata_arb (
    .clk          (clk_dcu_alloc),
    .reset_n      (reset_n),
    .rr_counter_i (lf_descr_tag_err_nodata_rr_sel_bin),
    .requests_i   (lf_descr_tag_err_nodata_valid[`CA53_BIU_LF_DESCR_NUM-1:0]),
    .arb_o        (lf_descr_tag_err_nodata_arb[`CA53_BIU_LF_DESCR_NUM-1:0])
  );

  assign lf_descr_tag_err_nodata_rr_sel_en = ~|(lf_descr_tag_err_nodata_valid & lf_descr_tag_err_nodata_rr_sel);

  always @(posedge clk_dcu_alloc or negedge reset_n)
  if (~reset_n) begin
    lf_descr_tag_err_nodata_rr_sel <= {`CA53_BIU_LF_DESCR_NUM{1'b0}};
  end else if (lf_descr_tag_err_nodata_rr_sel_en) begin
    lf_descr_tag_err_nodata_rr_sel <= lf_descr_tag_err_nodata_arb;
  end

  assign lf_descr_tag_err_nodata_sel = lf_descr_tag_err_nodata_valid & lf_descr_tag_err_nodata_rr_sel;

  // Work out the last alloc, halfline match and contiguous chunks pending for each RBUF.
  // Factorize the oldest RBUF in the backend of the paths in order to ease the timing closure.

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_flags_outer
      always @* begin : rbuf_flags_mux
        integer    index_j2;
        reg [3:0]  tmp_rbuf_chunk_need_release;
        reg [3:0]  tmp_rbuf_chunk_fetched_from_scu;

        tmp_rbuf_chunk_need_release     = 4'h0;
        tmp_rbuf_chunk_fetched_from_scu = 4'h0;

        for (index_j2 = 0; index_j2 < `CA53_BIU_LF_DESCR_NUM; index_j2 = index_j2 + 1) begin
          tmp_rbuf_chunk_need_release     = tmp_rbuf_chunk_need_release                                                                     |
                                            (lf_descr_chunk_need_release[index_j2][3:0]                                                    &
                                             {4{(rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0] == index_j2[`CA53_BIU_LF_DESCR_NUM_W-1:0])}});
          tmp_rbuf_chunk_fetched_from_scu = tmp_rbuf_chunk_fetched_from_scu                                                                 |
                                            (lf_descr_chunk_fetched_from_scu[index_j2][3:0]                                                &
                                             {4{(rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0] == index_j2[`CA53_BIU_LF_DESCR_NUM_W-1:0])}});

        end

        rbuf_chunk_need_release[index_i]     = tmp_rbuf_chunk_need_release;
        rbuf_chunk_fetched_from_scu[index_i] = tmp_rbuf_chunk_fetched_from_scu;
      end
    end
  endgenerate

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_dcu_alloc_flags_computation
      assign rbuf_fetched_last[index_i]          = &rbuf_chunk_fetched_from_scu[index_i][3:0];

      assign rbuf_hl_left[index_i]               = |(rbuf_chunk_need_release[index_i][3:0]            &
                                                     rbuf_chunk_fetched_from_scu[index_i][3:0]        &
                                                     {rbuf_chunk[index_i][2:0], rbuf_chunk[index_i][3]});

      assign rbuf_hl_right[index_i]              = |(rbuf_chunk_need_release[index_i][3:0]            &
                                                     rbuf_chunk_fetched_from_scu[index_i][3:0]        &
                                                     {rbuf_chunk[index_i][0], rbuf_chunk[index_i][3:1]});

      assign rbuf_hl_match[index_i]              = rbuf_hl_left[index_i] | rbuf_hl_right[index_i];

      assign rbuf_chunk_contiguous[index_i][3:0] = rbuf_chunk[index_i][3:0]       |
                                                   ({4{ rbuf_hl_left[index_i]}} &
                                                    {rbuf_chunk[index_i][2:0],
                                                     rbuf_chunk[index_i][3]     })|
                                                   ({4{~rbuf_hl_left[index_i] &
                                                       rbuf_hl_right[index_i] }} &
                                                       {rbuf_chunk[index_i][0],
                                                        rbuf_chunk[index_i][3:1] });

      assign rbuf_last_alloc[index_i]            = rbuf_fetched_last[index_i]                 &
                                                   ~|(rbuf_chunk_need_release[index_i][3:0]  &
                                                      {rbuf_chunk_need_release[index_i][1:0],
                                                       rbuf_chunk_need_release[index_i][3:2] });

      assign rbuf_chunk_addr[index_i][1:0]       = {(~rbuf_chunk_contiguous[index_i][1] & ~rbuf_chunk_contiguous[index_i][0]) | (rbuf_chunk_contiguous[index_i][3] & ~rbuf_chunk_contiguous[index_i][2]),
                                                    ( rbuf_chunk_contiguous[index_i][1] & ~rbuf_chunk_contiguous[index_i][0]) | (rbuf_chunk_contiguous[index_i][3] & ~rbuf_chunk_contiguous[index_i][2])};

    end
  endgenerate

  assign rbuf_oldest_halfline   = |(rbuf_hl_match & rbuf_for_lf_oldest_sel_i);

  assign rbuf_oldest_last_alloc = |(rbuf_last_alloc & rbuf_for_lf_oldest_sel_i);

  assign rbuf_oldest_age        = |(rbuf_age_i & rbuf_for_lf_oldest_sel_i);

  `CA53_BIU_ONEHOT_MUX(rbuf_oldest_chunk_contiguous, 4, 0, rbuf_for_lf_oldest_sel_i, rbuf_chunk_contiguous, `CA53_BIU_RBUFS_NUM, 0, g_mux_oldest_chunk)
  `CA53_BIU_ONEHOT_MUX(rbuf_oldest_chunk_addr,       2, 0, rbuf_for_lf_oldest_sel_i,       rbuf_chunk_addr, `CA53_BIU_RBUFS_NUM, 0, g_mux_oldest_addr)

  // Compute the STB pending slots to the linefill descriptor entering the M0 stage

  `CA53_BIU_ONEHOT_MUX(lf_descr_match_stb_oldest, 5, 0, lf_descr_rbuf_oldest_sel, lf_descr_match_stb, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_oldest_stb)

  //-----------------------------------------------------------------------------
  // BIU's L1 data cache allocation M0 arbiter:
  //
  // Priority 1: Tag invalidation for lines which have all chunks allocated,
  //             all chunks fetched from the SCU and which received an error from the SCU.
  // Priority 2: Oldest valid data from the read buffers requiring DCU data allocation,
  //             and either of the conditions being met:
  //               o all RBUFs used;
  //               o last linefill's allocation pending into the oldest RBUF;
  //               o halfline allocation pending into the oldest RBUF;
  //               o last linefill chunk(s) pending into the RBUFs.
  // Priority 3: Tag allocation for lines in unique state for which evict has been done
  //             and without any chunk fetched from the SCU. This is decoupled from
  //             data alloc in order to allow potential STB slots merges to take
  //             place before any data is fetched from the SCU, and thus preventing
  //             the STB slots becoming full.
  //
  //   Note: Priority 1 [highest priority] > 2 > 3 [lowest priority]
  //-----------------------------------------------------------------------------

  assign rbuf_oldest_valid = (// all RBUFs used
                              (&rbuf_valid_i)                              |
                              // last allocation into the oldest RBUF
                              rbuf_oldest_last_alloc                       |
                              // halfline allocation into the oldest RBUF
                              rbuf_oldest_halfline                         |
                              // last chunk(s) pending into the RBUFs
                              (|(rbuf_fetched_last & rbuf_for_lf_valid_i)  )) &
                             // any RBUF for a LF descriptor
                             rbuf_for_lf_oldest_valid;

  assign lf_descr_alloc_sel = (|lf_descr_tag_err_nodata_valid) ? lf_descr_tag_err_nodata_sel :
                              rbuf_oldest_valid                ? lf_descr_rbuf_oldest_sel    :
                                                                 lf_descr_tag_alloc_nodata_sel;

  //-----------------------------------------------------------------------------
  // M0's L1 data cache allocation arbitration winner mux
  //-----------------------------------------------------------------------------

  assign biu_alloc_lf_descr_valid_m0     = |biu_alloc_lf_descr_m0;

  assign biu_alloc_leave_m0              = ~biu_alloc_lf_descr_m0_stall & dcu_alloc_has_priority_m0_i;

  assign biu_alloc_rdy_m0                = ~biu_alloc_lf_descr_valid_m0 | biu_alloc_leave_m0;

  assign next_biu_alloc_lf_descr_m0      = biu_alloc_rdy_m0 ? lf_descr_alloc_sel :
                                                              current_biu_alloc_lf_descr_m0;

  assign next_biu_alloc_stb_slot_pend_m0 = biu_alloc_rdy_m0 ? lf_descr_match_stb_oldest :
                                                              current_biu_alloc_stb_slot_pend_m0;

  assign next_biu_alloc_chunk_req_m0     = biu_alloc_rdy_m0 ? ({4{(~|lf_descr_tag_err_nodata_valid) & rbuf_oldest_valid}} & rbuf_oldest_chunk_contiguous) :
                                                              current_biu_alloc_chunk_req_m0;

  assign next_biu_alloc_halfline_m0      = biu_alloc_rdy_m0 ? (rbuf_oldest_valid & rbuf_oldest_halfline) :
                                                              current_biu_alloc_halfline_m0;

  assign next_biu_alloc_age_m0           = biu_alloc_rdy_m0 ? (rbuf_oldest_valid & rbuf_oldest_age) :
                                                              biu_alloc_age_m0;

  assign next_biu_alloc_last_m0          = biu_alloc_rdy_m0 ? ((~|lf_descr_tag_err_nodata_valid) & rbuf_oldest_valid & rbuf_oldest_last_alloc) :
                                                              biu_alloc_last_m0;

  assign next_biu_alloc_tag_err_m0       = biu_alloc_rdy_m0 ? (|lf_descr_tag_err_nodata_valid) :
                                                              biu_alloc_tag_err_m0;

  assign next_biu_alloc_addr_qw_m0       = biu_alloc_rdy_m0 ? ({2{rbuf_oldest_valid}} & rbuf_oldest_chunk_addr) :
                                                              current_biu_alloc_addr_qw_m0;

  assign biu_alloc_en_m0                 = biu_alloc_lf_descr_valid_m0        |
                                           rbuf_oldest_valid                  |
                                           (|lf_descr_tag_alloc_nodata_valid) |
                                           (|lf_descr_tag_err_nodata_valid    );

  always @(posedge clk_dcu_alloc or negedge reset_n)
    if (~reset_n) begin
      biu_alloc_lf_descr_m0 <= {`CA53_BIU_LF_DESCR_NUM{1'b0}};
    end else if (biu_alloc_en_m0) begin
      biu_alloc_lf_descr_m0 <= next_biu_alloc_lf_descr_m0;
    end

  always @(posedge clk_dcu_alloc)
    if (biu_alloc_en_m0) begin
      biu_alloc_stb_slot_pend_m0 <= next_biu_alloc_stb_slot_pend_m0;
      biu_alloc_chunk_req_m0     <= next_biu_alloc_chunk_req_m0;
      biu_alloc_halfline_m0      <= next_biu_alloc_halfline_m0;
      biu_alloc_age_m0           <= next_biu_alloc_age_m0;
      biu_alloc_last_m0          <= next_biu_alloc_last_m0;
      biu_alloc_tag_err_m0       <= next_biu_alloc_tag_err_m0;
      biu_alloc_addr_qw_m0[5:4]  <= next_biu_alloc_addr_qw_m0[5:4];
    end

  `CA53_BIU_ONEHOT_MUX(biu_alloc_addr_m0,                    34, 6, biu_alloc_lf_descr_m0, lf_descr_addr,                     `CA53_BIU_LF_DESCR_NUM, 0, g_mux_alloc_m0_addr)
  `CA53_BIU_ONEHOT_MUX(biu_alloc_way_m0,                      4, 0, biu_alloc_lf_descr_m0, lf_descr_way,                      `CA53_BIU_LF_DESCR_NUM, 0, g_mux_alloc_m0_way)
  `CA53_BIU_ONEHOT_MUX(biu_alloc_chunk_allocated_from_stb_m0, 4, 0, biu_alloc_lf_descr_m0, lf_descr_chunk_allocated_from_stb, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_alloc_m0_from_stb)

  assign biu_alloc_ns_dsc_m0 = |(lf_descr_ns_dsc_i & biu_alloc_lf_descr_m0);

  // STB chunk M1 merge matching the current linefill descriptor in M0

  assign biu_alloc_chunk_alloc_stb_m1 = ({4{biu_alloc_stb_slot_pend_m0[0] & stb_slot_cachewrite_m1_i[0]}} & (4'h1 << stb_slot0_addr_i[5:4])) |
                                        ({4{biu_alloc_stb_slot_pend_m0[1] & stb_slot_cachewrite_m1_i[1]}} & (4'h1 << stb_slot1_addr_i[5:4])) |
                                        ({4{biu_alloc_stb_slot_pend_m0[2] & stb_slot_cachewrite_m1_i[2]}} & (4'h1 << stb_slot2_addr_i[5:4])) |
                                        ({4{biu_alloc_stb_slot_pend_m0[3] & stb_slot_cachewrite_m1_i[3]}} & (4'h1 << stb_slot3_addr_i[5:4])) |
                                        ({4{biu_alloc_stb_slot_pend_m0[4] & stb_slot_cachewrite_m1_i[4]}} & (4'h1 << stb_slot4_addr_i[5:4])  );

  // Compute current chunk req in M0

  assign current_biu_alloc_chunk_req_m0 = biu_alloc_chunk_req_m0                 &
                                          ~biu_alloc_chunk_allocated_from_stb_m0 &
                                          ~biu_alloc_chunk_alloc_stb_m1;

  assign current_biu_alloc_lf_descr_m0 = biu_alloc_lf_descr_m0                                   &
                                         {`CA53_BIU_LF_DESCR_NUM{biu_alloc_lf_descr_m0_stall   |
                                                                 ((biu_alloc_data_req_m0 |
                                                                   biu_alloc_tag_req_m0  |
                                                                   biu_alloc_dirty_req_m0 )   &
                                                                  ~dcu_alloc_has_priority_m0_i )}};

  // Compute the halfline info from the ongoing chunks being written

  assign current_biu_alloc_halfline_m0 = |({current_biu_alloc_chunk_req_m0[0], current_biu_alloc_chunk_req_m0[3:1]} & current_biu_alloc_chunk_req_m0);

  // Compute addr[5:4] based on the chunks being allocated
  // current_biu_alloc_chunk_req_m0    current_biu_alloc_addr_qw_m0
  //  o 4'b0001 | 4'b0011           => 2'b00
  //  o 4'b0010 | 4'b0110           => 2'b01
  //  o 4'b0100 | 4'b1100           => 2'b10
  //  o 4'b1000 | 4'b1001           => 2'b11

  assign current_biu_alloc_addr_qw_m0[5:4] = {(~current_biu_alloc_chunk_req_m0[1] & ~current_biu_alloc_chunk_req_m0[0]) | (current_biu_alloc_chunk_req_m0[3] & ~current_biu_alloc_chunk_req_m0[2]),
                                              ( current_biu_alloc_chunk_req_m0[1] & ~current_biu_alloc_chunk_req_m0[0]) | (current_biu_alloc_chunk_req_m0[3] & ~current_biu_alloc_chunk_req_m0[2])};

  // Compute the STB pending slots to the linefill descriptor from the M0 stage

  `CA53_BIU_ONEHOT_MUX(current_biu_alloc_stb_slot_pend_m0, 5, 0, biu_alloc_lf_descr_m0, lf_descr_match_stb, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pend_stb_m0)

  // Decide if we have to stall M0, if the registered M0 alloc chunks does not match the current M0 allocation chunks
  // This allows to use the registered M0 alloc chunks for the forward path from the read buffers

  assign biu_alloc_lf_descr_m0_stall = (current_biu_alloc_chunk_req_m0 != biu_alloc_chunk_req_m0);

  // Discard the Data alloc if the corresponding chunk(s) merged from STB

  assign biu_alloc_data_req_m0 = |biu_alloc_chunk_req_m0;

  // Compute the Tag request

  assign biu_alloc_tag_req_m0 = // Tag not written nor pending in M1
                                ~|(biu_alloc_lf_descr_m0                       &
                                   (biu_alloc_lf_descr_m1 | lf_descr_tag_done_i)) |
                                // Error received from SCU
                                biu_alloc_tag_err_m0;

  // Discard the Dirty req, if last chunk received and error received from the SCU

  assign biu_alloc_dirty_req_m0 = // Last allocation
                                  biu_alloc_last_m0        &
                                  // no Error received from SCU
                                  ~biu_alloc_err_from_scu_m0;

  assign biu_alloc_err_from_scu_m0 = |(biu_alloc_lf_descr_m0 & lf_descr_err_from_scu_i);

  assign biu_alloc_unique_m0       = |(biu_alloc_lf_descr_m0 & lf_descr_unique_i);

  assign biu_alloc_migratory_m0    = |(biu_alloc_lf_descr_m0 & lf_descr_migratory_i);

  // MOESI information passed to the L1 data cache in M0 of an allocation request.
  // This tells the DCU if the linefill aborted, was passed as shared or unique,
  // and in the case of unique says whether the line is migratory.

  assign biu_alloc_tag_moesi_m0 = biu_alloc_tag_err_m0   ? `CA53_MOESI_INVALID       :
                                  ~biu_alloc_unique_m0   ? `CA53_MOESI_SHARED        :
                                  biu_alloc_migratory_m0 ? `CA53_MOESI_UNIQUE_MIG    :
                                                           `CA53_MOESI_UNIQUE_NOT_MIG;

  // M0 select RBUF data and map it to the biu_alloc_data_m0
  // MBIST DCU MB3 fwd-ed from the read buffer 0

  assign rbuf_for_mbist_valid = {{(`CA53_BIU_RBUFS_NUM-1){1'b0}}, biu_mbist_req_i};

  always @* begin : data_m0_mux
    integer     index_k;
    reg [127:0] tmp_biu_alloc_data_m0_0;
    reg [127:0] tmp_biu_alloc_data_m0_1;

    tmp_biu_alloc_data_m0_0 = {128{1'b0}};
    tmp_biu_alloc_data_m0_1 = {128{1'b0}};

    for (index_k = 0; index_k < `CA53_BIU_RBUFS_NUM; index_k = index_k + 1) begin
      tmp_biu_alloc_data_m0_0 = tmp_biu_alloc_data_m0_0                                                                                                 |
                                (rbuf_data[index_k]                                                                                                    &
                                 {128{(~biu_mbist_req_i & rbuf_for_lf_valid_i[index_k]                                                            &
                                       (|((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_k][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & biu_alloc_lf_descr_m0)) &
                                       (|(rbuf_chunk[index_k][3:0] & biu_alloc_chunk_req_m0[3:0])                                               ) &
                                       (biu_alloc_addr_qw_m0[4] ^ ~rbuf_chunk_bin[index_k][0]                                                      )) |
                                      rbuf_for_mbist_valid[index_k]                                                                                   }});
      tmp_biu_alloc_data_m0_1 = tmp_biu_alloc_data_m0_1                                                                                              |
                                (rbuf_data[index_k]                                                                                                 &
                                 {128{rbuf_for_lf_valid_i[index_k]                                                                               &
                                      (|((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_k][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & biu_alloc_lf_descr_m0)) &
                                      (|(rbuf_chunk[index_k][3:0] & biu_alloc_chunk_req_m0[3:0])                                               ) &
                                      (biu_alloc_addr_qw_m0[4] ^ rbuf_chunk_bin[index_k][0]                                                       )}});
    end

    biu_alloc_data_m0 = {tmp_biu_alloc_data_m0_1, tmp_biu_alloc_data_m0_0};
  end

  //-----------------------------------------------------------------------------
  // Move to the M1 the ongoing M0 transaction, if M0 got priority from the L1 data cache and not stalled
  //-----------------------------------------------------------------------------

  assign biu_alloc_lf_descr_valid_m1 = |biu_alloc_lf_descr_m1;

  assign next_biu_alloc_lf_descr_m1  = {`CA53_BIU_LF_DESCR_NUM{biu_alloc_leave_m0 & (biu_alloc_tag_req_m0 | biu_alloc_data_req_m0 | biu_alloc_dirty_req_m0)}} & biu_alloc_lf_descr_m0;

  assign next_biu_alloc_last_m1      = (biu_alloc_last_m0 & ~biu_alloc_err_from_scu_m0) | biu_alloc_tag_err_m0;

  assign biu_alloc_en_m1             = (biu_alloc_lf_descr_valid_m0 & dcu_alloc_has_priority_m0_i) |
                                       (biu_alloc_lf_descr_valid_m1 & dcu_alloc_ack_m1_i);

  always @(posedge clk_dcu_alloc or negedge reset_n)
    if (~reset_n) begin
      biu_alloc_lf_descr_m1 <= {`CA53_BIU_LF_DESCR_NUM{1'b0}};
    end else if (biu_alloc_en_m1) begin
      biu_alloc_lf_descr_m1 <= next_biu_alloc_lf_descr_m1;
    end

  always @(posedge clk_dcu_alloc)
    if (biu_alloc_en_m1) begin
      biu_alloc_chunk_req_m1 <= biu_alloc_chunk_req_m0;
      biu_alloc_age_m1       <= biu_alloc_age_m0;
      biu_alloc_last_m1      <= next_biu_alloc_last_m1;
    end

  // M1 mux for the attributes and allocation from STB fields

  `CA53_BIU_ONEHOT_MUX(biu_alloc_attrs_m1,                    8, 0, biu_alloc_lf_descr_m1, lf_descr_attrs,                    `CA53_BIU_LF_DESCR_NUM, 0, g_mux_attrs_m1)
  `CA53_BIU_ONEHOT_MUX(biu_alloc_chunk_allocated_from_stb_m1, 4, 0, biu_alloc_lf_descr_m1, lf_descr_chunk_allocated_from_stb, `CA53_BIU_LF_DESCR_NUM, 0, g_mux_pend_stb_m1)

  // MOESI information passed to the L1 data cache in M1 of an allocation request.
  // For migratory lines, this says whether the line was passed as dirty and whether
  // it has been locally modified.  For non-migratory lines, it says whether the
  // line is is dirty.

  assign biu_alloc_migratory_m1       = |(biu_alloc_lf_descr_m1 & lf_descr_migratory_i);

  assign biu_alloc_passed_as_dirty_m1 = |(biu_alloc_lf_descr_m1 & lf_descr_passed_as_dirty_i);

  assign biu_alloc_dirty_moesi_m1     = {biu_alloc_migratory_m1 & (|biu_alloc_chunk_allocated_from_stb_m1),
                                         biu_alloc_passed_as_dirty_m1 | (|biu_alloc_chunk_allocated_from_stb_m1)};

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_alloc_tag_req_m0_o     = biu_alloc_lf_descr_valid_m0 & ~biu_alloc_lf_descr_m0_stall & biu_alloc_tag_req_m0;
  assign biu_alloc_data_req_m0_o    = biu_alloc_lf_descr_valid_m0 & ~biu_alloc_lf_descr_m0_stall & biu_alloc_data_req_m0;
  assign biu_alloc_halfline_m0_o    = biu_alloc_halfline_m0;
  assign biu_alloc_dirty_req_m0_o   = biu_alloc_lf_descr_valid_m0 & ~biu_alloc_lf_descr_m0_stall & biu_alloc_dirty_req_m0;
  assign biu_alloc_addr_m0_o        = {biu_alloc_addr_m0[39:6], biu_alloc_addr_qw_m0[5:4]};
  assign biu_alloc_ns_dsc_m0_o      = biu_alloc_ns_dsc_m0;
  assign biu_alloc_way_m0_o         = biu_alloc_way_m0;
  assign biu_alloc_tag_moesi_m0_o   = biu_alloc_tag_moesi_m0;
  assign biu_alloc_data_m0_o        = biu_alloc_data_m0;
  assign biu_alloc_dirty_moesi_m1_o = biu_alloc_dirty_moesi_m1;
  assign biu_alloc_dirty_age_m1_o   = biu_alloc_age_m1;
  assign biu_alloc_attrs_m1_o       = biu_alloc_attrs_m1;

  //-----------------------------------------------------------------------------
  // Read buffers containing linefill data are cleared if the data has been allocated,
  // or if the data does not need to be allocated because of an STB write or error
  // received from SCU
  //-----------------------------------------------------------------------------

  // Clear the read buffers containing linefill data which do not need to be allocated because of an STB merge

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_lf_descr_rbuf_clr_from_m0
      assign rbuf_clr_from_m0[index_i] = rbuf_for_lf_valid_i[index_i]                                                       &
                                         |((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0]) &
                                           biu_alloc_lf_descr_m0                                                          ) &
                                         |(rbuf_chunk[index_i][3:0]                &
                                           biu_alloc_chunk_req_m0                  &
                                           (biu_alloc_chunk_allocated_from_stb_m0 |
                                            biu_alloc_chunk_alloc_stb_m1           )                                        );
    end
  endgenerate

  // Clear the read buffers containing linefill data once the corresponding data has been written into the L1 data cache

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_lf_descr_rbuf_clr_from_m1
      assign rbuf_clr_from_m1[index_i] = rbuf_for_lf_valid_i[index_i]                                                                             &
                                         dcu_alloc_ack_m1_i                                                                                       &
                                         |((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & biu_alloc_lf_descr_m1) &
                                         |(rbuf_chunk[index_i][3:0] & biu_alloc_chunk_req_m1                                                      );
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_alloc_rbuf_clr_o     = rbuf_clr_from_m0 | rbuf_clr_from_m1;
  assign biu_alloc_lf_descr_m0_o  = biu_alloc_lf_descr_m0;
  assign biu_alloc_chunk_req_m0_o = biu_alloc_chunk_req_m0;
  assign biu_alloc_lf_descr_m1_o  = biu_alloc_lf_descr_m1;
  assign biu_alloc_chunk_req_m1_o = biu_alloc_chunk_req_m1;
  assign biu_alloc_last_m1_o      = biu_alloc_last_m1;

`ifdef ARM_ASSERT_ON
  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_alloc_en_m0")
  u_ovl_x_biu_alloc_en_m0 (.clk       (clk_dcu_alloc),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (biu_alloc_en_m0));

  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_alloc_en_m1")
  u_ovl_x_biu_alloc_en_m1 (.clk       (clk_dcu_alloc),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (biu_alloc_en_m1));

  assert_never_unknown                       #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lf_descr_tag_alloc_nodata_rr_sel_en")
  u_ovl_x_lf_descr_tag_alloc_nodata_rr_sel_en (.clk       (clk_dcu_alloc),
                                               .reset_n   (reset_n),
                                               .qualifier (1'b1),
                                               .test_expr (lf_descr_tag_alloc_nodata_rr_sel_en));

  assert_never_unknown                     #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lf_descr_tag_err_nodata_rr_sel_en")
  u_ovl_x_lf_descr_tag_err_nodata_rr_sel_en (.clk       (clk_dcu_alloc),
                                             .reset_n   (reset_n),
                                             .qualifier (1'b1),
                                             .test_expr (lf_descr_tag_err_nodata_rr_sel_en));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Chunk(s) required to be allocated have to be either single qword or contiguous qwords!")
  u_ovl_dcu_alloc_01  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_alloc_data_req_m0_o),
                       .consequent_expr ((current_biu_alloc_chunk_req_m0 == 4'b0001) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b0010) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b0100) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b1000) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b0011) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b0110) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b1100) |
                                         (current_biu_alloc_chunk_req_m0 == 4'b1001  )));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU cache alloc address[5:4] has to correspond to the first chunk being allocated")
  u_ovl_dcu_alloc_02  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_alloc_data_req_m0_o                       &
                                         ((current_biu_alloc_chunk_req_m0 == 4'b0001) |
                                          (current_biu_alloc_chunk_req_m0 == 4'b0011  ))),
                       .consequent_expr ((biu_alloc_addr_m0_o[5:4] == 2'b00)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU cache alloc address[5:4] has to correspond to the first chunk being allocated")
  u_ovl_dcu_alloc_03  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_alloc_data_req_m0_o                       &
                                         ((current_biu_alloc_chunk_req_m0 == 4'b0010) |
                                          (current_biu_alloc_chunk_req_m0 == 4'b0110  ))),
                       .consequent_expr ((biu_alloc_addr_m0_o[5:4] == 2'b01)));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU cache alloc address[5:4] has to correspond to the first chunk being allocated")
  u_ovl_dcu_alloc_04  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_alloc_data_req_m0_o                       &
                                         ((current_biu_alloc_chunk_req_m0 == 4'b0100) |
                                          (current_biu_alloc_chunk_req_m0 == 4'b1100  ))),
                       .consequent_expr ((biu_alloc_addr_m0_o[5:4] == 2'b10)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU cache alloc address[5:4] has to correspond to the first chunk being allocated")
  u_ovl_dcu_alloc_05  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_alloc_data_req_m0_o                       &
                                         ((current_biu_alloc_chunk_req_m0 == 4'b1000) |
                                          (current_biu_alloc_chunk_req_m0 == 4'b1001  ))),
                       .consequent_expr ((biu_alloc_addr_m0_o[5:4] == 2'b11)));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "lf_descr_rbuf_clr_o must never be unknown")
  u_ovl_dcu_alloc_06    (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_alloc_rbuf_clr_o));


  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_LF_DESCR_NUM, `OVL_ASSERT, "lf_descr_alloc_sel must be zero or one hot")
  u_ovl_dcu_alloc_07   (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (lf_descr_alloc_sel));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_alloc_rdy_m0 must never be unknown")
  u_ovl_dcu_alloc_08    (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_alloc_rdy_m0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DCU alloc M0 cannot progress to M1, if M1 stage occupied or not draining")
  u_ovl_dcu_alloc_09  (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (dcu_alloc_has_priority_m0_i),
                       .consequent_expr (~|biu_alloc_lf_descr_m0 |
                                         ~|biu_alloc_lf_descr_m1 |
                                         dcu_alloc_ack_m1_i));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is a potential access to/from the data prefetch stream")
  u_ovl_dcu_alloc_10    (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr ((|lf_descr_valid_i)      |
                                           (|biu_alloc_lf_descr_m0) |
                                           (|biu_alloc_lf_descr_m1  )),
                         .consequent_expr (clk_enable));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_dcu_alloc_mngmt
