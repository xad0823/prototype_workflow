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
// Abstract : BIU data read channel
//-----------------------------------------------------------------------------
//
// Overview
// -------
// SCU read data is buffered in this module before it is forwarded to the
// requesting block.

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_data_read_buffers
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
   output wire [52:0]                                              biu_mbist_in_data_hi_mb3_o,

   //----------------------------------------------------------------------------
   // BIU-SCU Address Request Channel
   //----------------------------------------------------------------------------

   input  wire                                                     biu_ar_valid_i,
   input  wire [4:0]                                               biu_ar_id_i,
   input  wire [1:0]                                               biu_ar_len_i,

   //------------------------------------------------------------------------------
   // BIU-SCU Read Data Channel
   //------------------------------------------------------------------------------

   output wire                                                     biu_dr_credit_o,
   input  wire                                                     scu_dr_valid_i,
   input  wire [4:0]                                               scu_dr_id_i,
   input  wire [5:0]                                               scu_dr_resp_i,
   input  wire [1:0]                                               scu_dr_chunk_i,
   input  wire [127:0]                                             scu_dr_data_i,

   //------------------------------------------------------------------------------
   // BIU-SCU Read Response Channel
   //------------------------------------------------------------------------------

   input  wire                                                     scu_rr_valid_i,
   input  wire [4:0]                                               scu_rr_id_i,
   input  wire [1:0]                                               scu_rr_resp_i,
   input  wire [3:0]                                               scu_rr_l2db_id_i,

   //------------------------------------------------------------------------------
   // IFU Interface
   //------------------------------------------------------------------------------

   output wire                                                     biu_i_rvalid_o,
   output wire [1:0]                                               biu_i_rid_o,
   output wire [127:0]                                             biu_i_rdata_o,
   output wire [2:0]                                               biu_i_rresp_o,
   output wire [1:0]                                               biu_i_rchunk_o,
   input  wire                                                     ifu_rready_i,
   input  wire [2:0]                                               ifu_outstanding_lfb_i,

   //------------------------------------------------------------------------------
   // TLB Read Data Channel
   //------------------------------------------------------------------------------

   output wire                                                     biu_walk_ack_o,
   output wire [2:0]                                               biu_walk_resp_o,
   output wire [63:0]                                              biu_walk_data_o,

   //------------------------------------------------------------------------------
   // DCU Read Addr Req Channel (DC2/DC3 NC & Dev)
   //------------------------------------------------------------------------------

   input  wire                                                     dcu_load_dc2_i,
   input  wire                                                     dcu_load_dc3_i,
   input  wire                                                     dcu_biu_req_dc2_i,
   input  wire                                                     dcu_biu_req_dc3_i,
   input  wire                                                     dcu_exclusive_dc2_i,
   input  wire                                                     dcu_exclusive_dc3_i,

   //------------------------------------------------------------------------------
   // DCU Read Data Channel (DC2/DC3)
   //------------------------------------------------------------------------------

   output wire                                                     biu_read_data_valid_dc2_o,
   output wire [63:0]                                              biu_read_data_dc2_o,
   output wire                                                     biu_read_abort_dc2_o,
   output wire [1:0]                                               biu_read_fault_dc2_o,
   output wire                                                     biu_read_data_valid_dc3_dev_o,
   output wire                                                     biu_read_data_valid_dc3_o,
   output wire [63:0]                                              biu_read_data_dc3_o,
   output wire                                                     biu_read_abort_dc3_o,
   output wire [1:0]                                               biu_read_fault_dc3_o,
   output wire                                                     biu_ecc_cinv_complete_o,

   //------------------------------------------------------------------------------
   // STB Interface
   //------------------------------------------------------------------------------

   output wire                                                     biu_stb_ar_resp_valid_o,
   output wire [1:0]                                               biu_stb_ar_resp_o,
   output wire [4:0]                                               biu_stb_ar_resp_id_o,
   output wire [3:0]                                               biu_stb_ar_resp_l2dbid_o,

   //------------------------------------------------------------------------------
   // BIU AR Arbiter
   //------------------------------------------------------------------------------

   output wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_ar_id_used_o,
   output wire                                                     pld_l2_ar_id_used_o,
   input  wire                                                     dc2_trans_valid_i,
   input  wire [1:0]                                               dc2_trans_id_i,
   input  wire [5:3]                                               dc2_trans_pa_i,
   input  wire                                                     dc2_trans_last_beat_i,
   input  wire                                                     dc3_trans_valid_i,
   input  wire [1:0]                                               dc3_trans_id_i,
   input  wire [5:3]                                               dc3_trans_pa_i,
   input  wire                                                     dc3_trans_last_beat_i,
   input  wire                                                     tlb_nc_trans_valid_i,
   input  wire [5:3]                                               tlb_trans_pa_i,

   //-----------------------------------------------------------------------------
   // Device Loads Management
   //-----------------------------------------------------------------------------

   input  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dev_id_outstanding_i,
   input  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dev_id_pending_i,

   //-----------------------------------------------------------------------------
   // LFs Management
   //-----------------------------------------------------------------------------

   output wire [128*`CA53_BIU_RBUFS_NUM-1:0]                       rbuf_data_packed_o,
   output wire [2*`CA53_BIU_RBUFS_NUM-1:0]                         rbuf_chunk_packed_o,
   output wire [`CA53_BIU_LF_DESCR_NUM_W*`CA53_BIU_RBUFS_NUM-1:0]  rbuf_id_packed_o,
   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_age_o,
   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_valid_o,
   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_oldest_sel_o,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_dc2_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_dc3_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_for_tlb_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        lf_descr_evict_done_i,
   input  wire [`CA53_BIU_RBUFS_NUM-1:0]                           biu_alloc_rbuf_clr_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m0_i,
   input  wire [3:0]                                               biu_alloc_chunk_req_m0_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_alloc_lf_descr_m1_i,
   input  wire [3:0]                                               biu_alloc_chunk_req_m1_i,
   input  wire [`CA53_BIU_LF_DESCR_NUM-1:0]                        biu_lf_in_progress_i,

   //-----------------------------------------------------------------------------
   // Gov Management
   //-----------------------------------------------------------------------------

   output wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_valid_o,

   //-----------------------------------------------------------------------------
   // CP15 Aborts Management
   //-----------------------------------------------------------------------------

   output wire                                                     cp15_coh_imp_abort_o,
   output wire                                                     cp15_coh_imp_fault_o
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                                                      clk_enable;
  reg                                                      biu_stb_ar_resp_valid;
  reg  [1:0]                                               biu_stb_ar_resp;
  reg  [2:0]                                               biu_stb_ar_resp_id;
  reg  [3:0]                                               biu_stb_ar_resp_l2dbid;
  reg  [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_id_matches_rbuf;
  reg  [2:0]                                               dcu_nc_id_beats [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  reg  [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_ar_id_used;
  reg  [2:0]                                               biu_dr_credits;
  reg  [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_valid;
  reg  [127:0]                                             rbuf_data [`CA53_BIU_RBUFS_NUM-1:0];
  reg  [1:0]                                               rbuf_chunk [`CA53_BIU_RBUFS_NUM-1:0];
  reg  [1:0]                                               rbuf_resp [`CA53_BIU_RBUFS_NUM-1:0];
  reg  [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_age;
  reg  [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_ecc;
  reg  [4:0]                                               rbuf_id [`CA53_BIU_RBUFS_NUM-1:0];
  reg  [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_clr_del;
  reg  [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_ifu;
  reg                                                      scu_dr_valid_prev_cycle;
  reg  [3:0]                                               scu_dr_id_prev_cycle;
  reg                                                      pld_l2_ar_id_used;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                                     clk_dr;
  wire                                                     next_clk_enable;
  wire                                                     biu_stb_ar_resp_sel;
  wire                                                     next_biu_stb_ar_resp_valid;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_id_set_match;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_id_set_sel;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_id_dec_sel;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_id_beats_en;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       next_dcu_nc_ar_id_used;
  wire [2:0]                                               dcu_nc_id_set;
  wire [2:0]                                               next_dcu_nc_id_beats [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]                       dcu_nc_ar_id_clr;
  wire [2:0]                                               next_biu_dr_credits;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fill_sel;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_en;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           next_rbuf_valid;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           next_rbuf_fwd_ifu;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_nc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_lf;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_dev;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_dev_all;
  wire [1:0]                                               rbuf_dc3_fault [`CA53_BIU_RBUFS_NUM-1:0];
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_nc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_lf;
  wire [1:0]                                               rbuf_dc2_fault [`CA53_BIU_RBUFS_NUM-1:0];
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_tlb_nc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_tlb_lf;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_ifu;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_lf;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_chunk_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_nc_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_nc_chunk_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_dev_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_dev_chunk_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc3_lf_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_chunk_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_nc_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_nc_chunk_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_dc2_lf_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_tlb_chunk_match;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc3_nc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc3_dev;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc3_lf;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc3;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc2_nc;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc2_lf;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_dc2;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_fwd_tlb;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_clr;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_clr_ifu;
  wire [2:0]                                               rbuf_resp_ecc [`CA53_BIU_RBUFS_NUM-1:0];
  wire                                                     rbuf_tlb_upper_dword;
  wire                                                     rbuf_dc2_upper_dword;
  wire                                                     rbuf_dc3_upper_dword;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_order_bits [`CA53_BIU_RBUFS_NUM-1:0];
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_evict_done;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_valid;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_lf_oldest_sel;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_ifu_valid;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_for_ifu_oldest_sel;
  wire [`CA53_BIU_RBUFS_NUM-1:0]                           rbuf_alloc_pend;
  wire [128*`CA53_BIU_RBUFS_NUM-1:0]                       rbuf_data_packed;
  wire [2*`CA53_BIU_RBUFS_NUM-1:0]                         rbuf_chunk_packed;
  wire [`CA53_BIU_LF_DESCR_NUM_W*`CA53_BIU_RBUFS_NUM-1:0]  rbuf_id_packed;
  wire [63:0]                                              rbuf_data_dword_dc2 [`CA53_BIU_RBUFS_NUM-1:0];
  wire [63:0]                                              rbuf_data_dword_dc3 [`CA53_BIU_RBUFS_NUM-1:0];
  wire [63:0]                                              rbuf_data_dword_tlb [`CA53_BIU_RBUFS_NUM-1:0];
  wire                                                     biu_read_data_valid_dc2;
  wire [63:0]                                              biu_read_data_dc2;
  wire [2:0]                                               biu_read_resp_dc2;
  wire [1:0]                                               biu_read_fault_dc2;
  wire                                                     biu_read_data_valid_dc3;
  wire                                                     biu_read_data_valid_dc3_dev;
  wire [63:0]                                              biu_read_data_dc3;
  wire [2:0]                                               biu_read_resp_dc3;
  wire [1:0]                                               biu_read_fault_dc3;
  wire [63:0]                                              biu_read_data_tlb;
  wire [2:0]                                               biu_read_resp_tlb;
  wire                                                     next_scu_dr_valid_prev_cycle;
  wire [3:0]                                               next_scu_dr_id_prev_cycle;
  wire [4:0]                                               scu_dr_id_prev_cycle_mask;
  wire                                                     pld_l2_ar_id_set;
  wire                                                     pld_l2_ar_id_clr;
  wire                                                     next_pld_l2_ar_id_used;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                                   index_i;
  genvar                                                   index_j;

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Avoid clocking data read registers when there isn't any transaction outstanding
  // which requires to fetch data from the SCU or when there isn't any dropped
  // load transaction which didn't receive all required data from the SCU.
  // The clock is enabled during the MBIST mode, too.

  assign next_clk_enable = |{// IFU transactions validity status
                             ifu_outstanding_lfb_i,
                             // TLB transaction validity status
                             tlb_nc_trans_valid_i,
                             // BIU linefill descriptors validity status
                             biu_lf_in_progress_i,
                             // BIU-SCU AR for read
                             biu_ar_valid_i & `CA53_BIU_RID_IS_FOR_READ(biu_ar_id_i),
                             // BIU-DCU non-caheable IDs validity status
                             dcu_nc_ar_id_used,
                             // BIU-SCU DR credit status
                             biu_dr_credits,
                             rbuf_clr_del,
                             // BIU read buffers validity status
                             rbuf_valid,
                             // MBIST mode enabled
                             biu_mbist_req_i};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_dr (.clk_i         (clk),
                                              .clk_enable_i  (clk_enable),
                                              .clk_senable_i (DFTSE),
                                              .clk_gated_o   (clk_dr));

  //-----------------------------------------------------------------------------
  // DCU NC IDs pool management
  //-----------------------------------------------------------------------------

  // The remaining beats required to be received from the SCU per each DCU NC ID
  // o set when transaction is issued to the SCU
  // o decremented each time a data beat is received from the SCU

  // Compute the selection of the ID required to be set

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : gen_sel_dcu_nc_id_set_match_01
      assign dcu_nc_id_set_match[index_i] = (biu_ar_id_i[`CA53_BIU_DCU_NC_ID_NUM_W-1:0] == index_i[`CA53_BIU_DCU_NC_ID_NUM_W-1:0]);
    end
  endgenerate

  assign dcu_nc_id_set_sel = dcu_nc_id_set_match                                                                &
                             {`CA53_BIU_DCU_NC_ID_NUM{biu_ar_valid_i & `CA53_BIU_RID_IS_FOR_DCU_NC(biu_ar_id_i)}};

  // Compute the initial value of the number of beats expected to be received from the SCU

  assign dcu_nc_id_set     = {1'b0, biu_ar_len_i} + 3'h1;

  // Compute the selection of the ID required to be decremented

  // Register the scu_dr_valid_i and scu_dr_id_i in order to ease the timing closure

  assign next_scu_dr_valid_prev_cycle = scu_dr_valid_i;
  assign next_scu_dr_id_prev_cycle    = {scu_dr_id_i[4:3], scu_dr_id_i[1:0]};

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      scu_dr_valid_prev_cycle <= 1'b0;
      scu_dr_id_prev_cycle    <= {4{1'b0}};
    end else begin
      scu_dr_valid_prev_cycle <= next_scu_dr_valid_prev_cycle;
      scu_dr_id_prev_cycle    <= next_scu_dr_id_prev_cycle;
    end

  assign scu_dr_id_prev_cycle_mask = {scu_dr_id_prev_cycle[3:2], 3'b000};

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : gen_nc_id_rbuf
      assign dcu_nc_id_dec_sel[index_i]    = scu_dr_valid_prev_cycle                                                                       &
                                             `CA53_BIU_RID_IS_FOR_DCU_NC(scu_dr_id_prev_cycle_mask)                                        &
                                             (scu_dr_id_prev_cycle[`CA53_BIU_DCU_NC_ID_NUM_W-1:0] == index_i[`CA53_BIU_DCU_NC_ID_NUM_W-1:0]);

      assign dcu_nc_id_beats_en[index_i]   = dcu_nc_id_set_sel[index_i] ^ dcu_nc_id_dec_sel[index_i];

      assign next_dcu_nc_id_beats[index_i] = dcu_nc_id_set_sel[index_i] ? dcu_nc_id_set : (dcu_nc_id_beats[index_i] - 3'b001);

      always @(posedge clk or negedge reset_n)
        if (~reset_n) begin
          dcu_nc_id_beats[index_i] <= {3{1'b0}};
        end else if (dcu_nc_id_beats_en[index_i]) begin
          dcu_nc_id_beats[index_i] <= next_dcu_nc_id_beats[index_i];
        end

      always @* begin : id_rbuf_mux
        integer indek_k;
        reg     tmp_dcu_nc_id_matches_rbuf;

        tmp_dcu_nc_id_matches_rbuf = 1'b0;

        for (indek_k = 0; indek_k < `CA53_BIU_RBUFS_NUM; indek_k = indek_k + 1) begin
          tmp_dcu_nc_id_matches_rbuf = tmp_dcu_nc_id_matches_rbuf                                                                  |
                                       (rbuf_valid[indek_k] & `CA53_BIU_RID_IS_FOR_DCU_NC(rbuf_id[indek_k])                       &
                                        (rbuf_id[indek_k][`CA53_BIU_DCU_NC_ID_NUM_W-1:0] == index_i[`CA53_BIU_DCU_NC_ID_NUM_W-1:0]));
        end

        dcu_nc_id_matches_rbuf[index_i] = tmp_dcu_nc_id_matches_rbuf;
      end

      // Compute the DCU NC ID clear
      // o set when no more SCU data beats expected to be received and
      //   no more outstanding RBUFs containing the coresponding DCU NC ID
      assign dcu_nc_ar_id_clr[index_i] = ((~dcu_nc_id_beats_en[index_i] & (     dcu_nc_id_beats[index_i] == 3'b000)) |
                                           ( dcu_nc_id_beats_en[index_i] & (next_dcu_nc_id_beats[index_i] == 3'b000)  )) &
                                          ~dcu_nc_id_matches_rbuf[index_i];
    end
  endgenerate

  // Compute the next valid DCU NC IDs

  assign next_dcu_nc_ar_id_used = dcu_nc_id_set_sel | (dcu_nc_ar_id_used & ~dcu_nc_ar_id_clr);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dcu_nc_ar_id_used <= {`CA53_BIU_DCU_NC_ID_NUM{1'b0}};
    end else begin
      dcu_nc_ar_id_used <= next_dcu_nc_ar_id_used;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign dcu_nc_ar_id_used_o = dcu_nc_ar_id_used;

  //-----------------------------------------------------------------------------
  // PLD L2 ID management
  //-----------------------------------------------------------------------------

  assign pld_l2_ar_id_set = biu_ar_valid_i & `CA53_BIU_RID_IS_FOR_PLD_L2(biu_ar_id_i);

  assign pld_l2_ar_id_clr = scu_rr_valid_i & `CA53_BIU_RID_IS_FOR_PLD_L2(scu_rr_id_i);

  assign next_pld_l2_ar_id_used = pld_l2_ar_id_set | (pld_l2_ar_id_used & ~pld_l2_ar_id_clr);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pld_l2_ar_id_used <= 1'b0;
    end else begin
      pld_l2_ar_id_used <= next_pld_l2_ar_id_used;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign pld_l2_ar_id_used_o = pld_l2_ar_id_used;

  //-----------------------------------------------------------------------------
  // Read data credits
  //-----------------------------------------------------------------------------

  // The BIU must return a credit for every response that it receives, once any
  // buffer used by that response has been cleared.
  // Because multiple buffers could be cleared in the same cycle, but only one
  // credit can be returned per cycle, we must keep a count of the number of
  // credits that are waiting to be returned.

  // Register the read buffers release info in order to ease the timing closure

  always @(posedge clk_dr or negedge reset_n)
    if (~reset_n) begin
      rbuf_clr_del <= {`CA53_BIU_RBUFS_NUM{1'b0}};
    end else begin
      rbuf_clr_del <= rbuf_clr;
    end

  assign next_biu_dr_credits = biu_dr_credits                         +
                               {2'b00, rbuf_clr_del[0]}               +
                               {2'b00, rbuf_clr_del[1]}               +
                               {2'b00, rbuf_clr_del[2]}               +
                               {2'b00, rbuf_clr_del[3]}               -
                               {2'b00, |{rbuf_clr_del, biu_dr_credits}};

  always @(posedge clk_dr or negedge reset_n)
    if (~reset_n) begin
      biu_dr_credits <= 3'b000;
    end else begin
      biu_dr_credits <= next_biu_dr_credits;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_dr_credit_o = |{rbuf_clr_del, biu_dr_credits};

  //-----------------------------------------------------------------------------
  // Shared instruction/data side read buffers
  //-----------------------------------------------------------------------------

  // Compute the RBUF valid (starts from the LSB index of the rbuf_valid array)
  // Select which RBUF will store the incoming SCU data

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_read_data_buffers_01
      if (index_i == 0) begin : gen_read_data_buffers_01_nested_01
        assign rbuf_fill_sel[0] = ~rbuf_valid[0];
      end else begin : gen_read_data_buffers_01_nested_01_else
        assign rbuf_fill_sel[index_i] = ~rbuf_valid[index_i] & (&rbuf_valid[index_i-1:0]);
      end
    end
  endgenerate

  // Enable the corresponding RBUF when SCU data is stored.
  // During MBIST mode, the RBUF[0] gets enabled, too.

  assign rbuf_en = ({`CA53_BIU_RBUFS_NUM{scu_dr_valid_i}} & rbuf_fill_sel) |
                   {{(`CA53_BIU_RBUFS_NUM-1){1'b0}}, biu_mbist_req_i};

  // Compute the next RBUF valid flags

  assign next_rbuf_valid = rbuf_en | (rbuf_valid & ~rbuf_clr);

  // Update the RBUF valid bits

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      rbuf_valid <= {`CA53_BIU_RBUFS_NUM{1'b0}};
    end else begin
      rbuf_valid <= next_rbuf_valid;
    end

  // Update the RBUF data, chunk, resp & id fields

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_read_data_buffers_02
      always @(posedge clk_dr)
        begin
          if (rbuf_en[index_i]) begin
            rbuf_data[index_i]  <= scu_dr_data_i;
            rbuf_chunk[index_i] <= scu_dr_chunk_i;
            rbuf_resp[index_i]  <= scu_dr_resp_i[`CA53_ACE_RRESP_RESP_B];
            rbuf_age[index_i]   <= scu_dr_resp_i[`CA53_BIU_DR_RESP_AGE_B];
            rbuf_ecc[index_i]   <= scu_dr_resp_i[`CA53_BIU_DR_RESP_ECC_B];
            rbuf_id[index_i]    <= scu_dr_id_i;
          end
        end
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Read buffers status
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_read_data_buffers_03
      // Read buffer contains valid data per ID

      assign rbuf_dc3_nc[index_i]              = rbuf_valid[index_i]                                                                                         &
                                                 `CA53_BIU_RID_IS_FOR_DCU_NC(rbuf_id[index_i]) & dc3_trans_valid_i & (rbuf_id[index_i][1:0] == dc3_trans_id_i);

      assign rbuf_dc3_dev[index_i]             = rbuf_valid[index_i]                                                                                                             &
                                                 `CA53_BIU_RID_IS_FOR_DCU_NC(rbuf_id[index_i]) & (|(dev_id_outstanding_i & (`CA53_BIU_DCU_NC_ID_NUM'h1 << rbuf_id[index_i][1:0])));

      assign rbuf_dc3_dev_all[index_i]         = rbuf_valid[index_i]                                                                                                         &
                                                 `CA53_BIU_RID_IS_FOR_DCU_NC(rbuf_id[index_i]) & (|(dev_id_pending_i & (`CA53_BIU_DCU_NC_ID_NUM'h1 << rbuf_id[index_i][1:0])));

      assign rbuf_dc3_lf[index_i]              = rbuf_valid[index_i]                                                                                                      &
                                                 `CA53_BIU_RID_IS_FOR_LF(rbuf_id[index_i]) & (|((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_i][2:0]) & lf_descr_for_dc3_i));

      assign rbuf_dc2_nc[index_i]              = rbuf_valid[index_i]                                                                                         &
                                                 `CA53_BIU_RID_IS_FOR_DCU_NC(rbuf_id[index_i]) & dc2_trans_valid_i & (rbuf_id[index_i][1:0] == dc2_trans_id_i);

      assign rbuf_dc2_lf[index_i]              = rbuf_valid[index_i]                                                                                                      &
                                                 `CA53_BIU_RID_IS_FOR_LF(rbuf_id[index_i]) & (|((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_i][2:0]) & lf_descr_for_dc2_i));

      assign rbuf_tlb_nc[index_i]              = rbuf_valid[index_i]                                             &
                                                 `CA53_BIU_RID_IS_FOR_TLB(rbuf_id[index_i]) & tlb_nc_trans_valid_i;

      assign rbuf_tlb_lf[index_i]              = rbuf_valid[index_i]                                                                                                      &
                                                 `CA53_BIU_RID_IS_FOR_LF(rbuf_id[index_i]) & (|((`CA53_BIU_LF_DESCR_NUM'd1 << rbuf_id[index_i][2:0]) & lf_descr_for_tlb_i));

      assign rbuf_ifu[index_i]                 = rbuf_valid[index_i]                      &
                                                 `CA53_BIU_RID_IS_FOR_IFU(rbuf_id[index_i]);

      assign rbuf_lf[index_i]                  = rbuf_valid[index_i]                     &
                                                 `CA53_BIU_RID_IS_FOR_LF(rbuf_id[index_i]);

      assign rbuf_dc3_chunk_match[index_i]     = (rbuf_chunk[index_i] == dc3_trans_pa_i[5:4]);

      assign rbuf_dc3_chunk_done[index_i]      = (rbuf_chunk[index_i] < dc3_trans_pa_i[5:4]) | (dc3_trans_last_beat_i & (rbuf_chunk[index_i] > dc3_trans_pa_i[5:4]));

      assign rbuf_dc3_nc_chunk_match[index_i]  = dcu_biu_req_dc3_i           &
                                                 rbuf_dc3_chunk_match[index_i];

      assign rbuf_dc3_nc_chunk_done[index_i]   = dcu_load_dc3_i                                    &
                                                 rbuf_dc3_nc[index_i] & rbuf_dc3_chunk_done[index_i];

      assign rbuf_dc3_dev_chunk_match[index_i] = rbuf_dc3_nc_chunk_match[index_i];

      assign rbuf_dc3_dev_chunk_done[index_i]  = dcu_load_dc3_i                                         &
                                                 rbuf_dc3_dev_all[index_i] & rbuf_dc3_chunk_done[index_i];

      assign rbuf_dc3_lf_chunk_match[index_i]  = ~dcu_biu_req_dc3_i          &
                                                 ~dc3_trans_valid_i          &
                                                 rbuf_dc3_chunk_match[index_i];

      assign rbuf_dc3_fault[index_i]           = rbuf_ecc[index_i]                                                 ? 2'b10 :
                                                 (rbuf_resp[index_i][`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR) ? 2'b01 :
                                                 (rbuf_resp[index_i][`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_SLVERR) ? 2'b00 :
                                                                                                                     2'b11;

      assign rbuf_dc2_chunk_match[index_i]     = (rbuf_chunk[index_i] == dc2_trans_pa_i[5:4]);

      assign rbuf_dc2_chunk_done[index_i]      = (rbuf_chunk[index_i] < dc2_trans_pa_i[5:4]);

      assign rbuf_dc2_nc_chunk_match[index_i]  = dcu_biu_req_dc2_i           &
                                                 rbuf_dc2_chunk_match[index_i];

      assign rbuf_dc2_nc_chunk_done[index_i]   = dcu_load_dc2_i                                    &
                                                 rbuf_dc2_nc[index_i] & rbuf_dc2_chunk_done[index_i];

      assign rbuf_dc2_lf_chunk_match[index_i]  = ~dcu_biu_req_dc2_i           &
                                                 ~dc2_trans_valid_i           &
                                                 rbuf_dc2_chunk_match[index_i];

      assign rbuf_dc2_fault[index_i]           = rbuf_ecc[index_i]                                                 ? 2'b10 :
                                                 (rbuf_resp[index_i][`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR) ? 2'b01 :
                                                                                                                     2'b00;

      assign rbuf_tlb_chunk_match[index_i]     = (rbuf_chunk[index_i] == tlb_trans_pa_i[5:4]);
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Determine which read buffer has data forwarding priority
  //-----------------------------------------------------------------------------

  // IFU: dedicated fwd path
  // MBIST IFU MB3 data fwd-ed from the read buffer 0

  assign next_rbuf_fwd_ifu = ({`CA53_BIU_RBUFS_NUM{~biu_mbist_req_i}}             &
                              rbuf_ifu & rbuf_for_ifu_oldest_sel                  &
                              ~(rbuf_fwd_ifu & {`CA53_BIU_RBUFS_NUM{ifu_rready_i}})) |
                             {{(`CA53_BIU_RBUFS_NUM-1){1'b0}}, biu_mbist_req_i};

  always @(posedge clk_dr or negedge reset_n)
    if (~reset_n) begin
      rbuf_fwd_ifu <= {`CA53_BIU_RBUFS_NUM{1'b0}};
    end else begin
      rbuf_fwd_ifu <= next_rbuf_fwd_ifu;
    end

  // DC3: dedicated fwd path
  // Data accepted by the DCU in the same cycle

  assign rbuf_fwd_dc3_nc  = rbuf_dc3_nc & rbuf_dc3_nc_chunk_match;

  assign rbuf_fwd_dc3_dev = rbuf_dc3_dev & rbuf_dc3_dev_chunk_match;

  assign rbuf_fwd_dc3_lf  = rbuf_dc3_lf & rbuf_dc3_lf_chunk_match;

  assign rbuf_fwd_dc3     = rbuf_fwd_dc3_nc  |
                            rbuf_fwd_dc3_dev |
                            rbuf_fwd_dc3_lf;

  // DC2: dedicated fwd path
  // Data accepted by the DCU in the same cycle

  assign rbuf_fwd_dc2_nc = rbuf_dc2_nc & rbuf_dc2_nc_chunk_match;

  assign rbuf_fwd_dc2_lf = rbuf_dc2_lf & rbuf_dc2_lf_chunk_match;

  assign rbuf_fwd_dc2    = rbuf_fwd_dc2_nc |
                           rbuf_fwd_dc2_lf;

  // TLB: dedicated fwd path
  // Data accepted by the TLB in the same cycle
  // MBIST TLB MB3 data fwd-ed from the read buffer 0

  assign rbuf_fwd_tlb = ({`CA53_BIU_RBUFS_NUM{~biu_mbist_req_i}} & (rbuf_tlb_nc | rbuf_tlb_lf) & rbuf_tlb_chunk_match) |
                        {{(`CA53_BIU_RBUFS_NUM-1){1'b0}}, biu_mbist_req_i                                              };

  //-----------------------------------------------------------------------------
  // Determine which read buffer(s) can be released next cycle
  //-----------------------------------------------------------------------------

  // IFU read buffer forwarding this cycle

  assign rbuf_clr_ifu = rbuf_fwd_ifu & {`CA53_BIU_RBUFS_NUM{ifu_rready_i}};

  // Read buffer is being invalidated this cycle:
  // o IFU drains a chunk at a time
  // o DCU normal NC in DC2: last access to the current chunk from dc2
  // o DCU normal NC or device in DC3: last access to the current chunk from dc3 or chunk fwd-ed from the STB
  // o TLB (NC) fetches one outsanding descriptor which fits within a chunk which is guaranteed to be drained
  //   by the TLB in the same clock cycle when the corresponding chunk is available
  // o Linefill's chunk release when the corresponding chunk merged by STB reaches M0 DCU allocation or
  //   when a chunk gets allocated into the DCU cache (ie when the acknowledge is received in M1)

  assign rbuf_clr = rbuf_valid                                                                                                                                             &
                    (~rbuf_dc2_nc      | (rbuf_fwd_dc2_nc  & {`CA53_BIU_RBUFS_NUM{dc2_trans_last_beat_i | dc2_trans_pa_i[`CA53_BIU_UPPER_DW]}}) | rbuf_dc2_nc_chunk_done)  &
                    (~rbuf_dc3_nc      | (rbuf_fwd_dc3_nc  & {`CA53_BIU_RBUFS_NUM{dc3_trans_last_beat_i | dc3_trans_pa_i[`CA53_BIU_UPPER_DW]}}) | rbuf_dc3_nc_chunk_done)  &
                    (~rbuf_dc3_dev_all | (rbuf_fwd_dc3_dev & {`CA53_BIU_RBUFS_NUM{dc3_trans_last_beat_i | dc3_trans_pa_i[`CA53_BIU_UPPER_DW]}}) | rbuf_dc3_dev_chunk_done) &
                    (~rbuf_ifu         | rbuf_clr_ifu)                                                                                                                     &
                    (~rbuf_lf          | biu_alloc_rbuf_clr_i                                                                                                              );

  //-----------------------------------------------------------------------------
  // IFU data forwarding
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_resp_ecc
      assign rbuf_resp_ecc[index_i][2:0] = {rbuf_ecc[index_i], rbuf_resp[index_i][1:0]};
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_i_rvalid_o = |rbuf_fwd_ifu;

  `CA53_BIU_ONEHOT_MUX(biu_i_rid_o,     2, 0, rbuf_fwd_ifu,       rbuf_id, `CA53_BIU_RBUFS_NUM, 0, g_mux_ifu_rid)
  `CA53_BIU_ONEHOT_MUX(biu_i_rdata_o, 128, 0, rbuf_fwd_ifu,     rbuf_data, `CA53_BIU_RBUFS_NUM, 0, g_mux_ifu_rdata)
  `CA53_BIU_ONEHOT_MUX(biu_i_rresp_o,   3, 0, rbuf_fwd_ifu, rbuf_resp_ecc, `CA53_BIU_RBUFS_NUM, 0, g_mux_ifu_rresp)
  `CA53_BIU_ONEHOT_MUX(biu_i_rchunk_o,  2, 0, rbuf_fwd_ifu,    rbuf_chunk, `CA53_BIU_RBUFS_NUM, 0, g_mux_ifu_rchunk)

  //-----------------------------------------------------------------------------
  // DC3 data forwarding
  //-----------------------------------------------------------------------------

  assign rbuf_dc3_upper_dword = dc3_trans_pa_i[`CA53_BIU_UPPER_DW];

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_dword_dc3
      assign rbuf_data_dword_dc3[index_i][63:0] = (rbuf_data[index_i][63:0]   & {64{~rbuf_dc3_upper_dword}}) |
                                                  (rbuf_data[index_i][127:64] & {64{ rbuf_dc3_upper_dword}}  );
    end
  endgenerate

  `CA53_BIU_ONEHOT_MUX(biu_read_data_dc3,  64, 0, rbuf_fwd_dc3, rbuf_data_dword_dc3, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc3_rdata)
  `CA53_BIU_ONEHOT_MUX(biu_read_resp_dc3,   3, 0, rbuf_fwd_dc3,       rbuf_resp_ecc, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc3_rresp)
  `CA53_BIU_ONEHOT_MUX(biu_read_fault_dc3,  2, 0, rbuf_fwd_dc3,      rbuf_dc3_fault, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc3_rfault)

  assign biu_read_data_valid_dc3 = |rbuf_fwd_dc3;

  assign biu_read_data_valid_dc3_dev = |rbuf_fwd_dc3_dev;


  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_read_data_valid_dc3_dev_o = biu_read_data_valid_dc3_dev;
  assign biu_read_data_valid_dc3_o     = biu_read_data_valid_dc3;
  assign biu_read_data_dc3_o           = biu_read_data_dc3;

  // OKAY for exclusive are treated as slave errors for non-cacheable.
  // OKAY for exclusive are NOT treated as slave errors for cacheable.
  // EXOKAY for non-exclusive are treated as slave errors for non-cacheable.
  // EXOKAY for non-exclusive are NOT treated as slave errors for cacheable as the linefill may have been initiated by an exclusive access.
  // Decoder and ECC fatal error overwrite the slave error

  assign biu_read_abort_dc3_o = biu_read_data_valid_dc3                                                  &
                                ((~|rbuf_dc3_lf & dcu_exclusive_dc3_i                            &
                                  (biu_read_resp_dc3[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_EXOKAY))     |
                                 (~|rbuf_dc3_lf & ~dcu_exclusive_dc3_i                         &
                                  (biu_read_resp_dc3[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_OKAY))       |
                                 ((|rbuf_dc3_lf)                                                     &
                                  ((biu_read_resp_dc3[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR) |
                                   (biu_read_resp_dc3[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_SLVERR  ))) |
                                 // ECC fatal error
                                 biu_read_resp_dc3[2]                                                    );
  assign biu_read_fault_dc3_o = biu_read_fault_dc3;

  //-----------------------------------------------------------------------------
  // DC2 data forwarding
  //-----------------------------------------------------------------------------

  assign rbuf_dc2_upper_dword = dc2_trans_pa_i[`CA53_BIU_UPPER_DW];

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_dword_dc2
      assign rbuf_data_dword_dc2[index_i][63:0] = (rbuf_data[index_i][63:0]   & {64{~rbuf_dc2_upper_dword}}) |
                                                  (rbuf_data[index_i][127:64] & {64{ rbuf_dc2_upper_dword}}  );
    end
  endgenerate

  `CA53_BIU_ONEHOT_MUX(biu_read_data_dc2,  64, 0, rbuf_fwd_dc2, rbuf_data_dword_dc2, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc2_rdata)
  `CA53_BIU_ONEHOT_MUX(biu_read_resp_dc2,   3, 0, rbuf_fwd_dc2,       rbuf_resp_ecc, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc2_rresp)
  `CA53_BIU_ONEHOT_MUX(biu_read_fault_dc2,  2, 0, rbuf_fwd_dc2,      rbuf_dc2_fault, `CA53_BIU_RBUFS_NUM, 0, g_mux_dc2_rfault)

  assign biu_read_data_valid_dc2 = |rbuf_fwd_dc2;

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  // DC2 data resp

  assign biu_read_data_valid_dc2_o = biu_read_data_valid_dc2;
  assign biu_read_data_dc2_o       = biu_read_data_dc2;

  // OKAY for exclusive are treated as slave errors for non-cacheable.
  // OKAY for exclusive are NOT treated as slave errors for cacheable.
  // EXOKAY for non-exclusive are treated as slave errors for non-cacheable.
  // EXOKAY for non-exclusive are NOT treated as slave errors for cacheable as the linefill may have been initiated by an exclusive access.
  // Decoder and ECC fatal error overwrite the slave error

  assign biu_read_abort_dc2_o = biu_read_data_valid_dc2                                                  &
                                ((~|rbuf_dc2_lf & dcu_exclusive_dc2_i                            &
                                  (biu_read_resp_dc2[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_EXOKAY))     |
                                 (~|rbuf_dc2_lf & ~dcu_exclusive_dc2_i                         &
                                  (biu_read_resp_dc2[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_OKAY))       |
                                 ((|rbuf_dc2_lf)                                                     &
                                  ((biu_read_resp_dc2[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR) |
                                   (biu_read_resp_dc2[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_SLVERR  ))) |
                                 // ECC fatal error
                                 biu_read_resp_dc2[2]                                                    );
  assign biu_read_fault_dc2_o = biu_read_fault_dc2;

  //-----------------------------------------------------------------------------
  // TLB data forwarding
  //-----------------------------------------------------------------------------

  assign rbuf_tlb_upper_dword = tlb_trans_pa_i[`CA53_BIU_UPPER_DW] & ~biu_mbist_req_i;

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_dword_tlb
      assign rbuf_data_dword_tlb[index_i][63:0] = (rbuf_data[index_i][63:0]   & {64{~rbuf_tlb_upper_dword}}) |
                                                  (rbuf_data[index_i][127:64] & {64{ rbuf_tlb_upper_dword}}  );
    end
  endgenerate

  `CA53_BIU_ONEHOT_MUX(biu_read_data_tlb, 64, 0, rbuf_fwd_tlb, rbuf_data_dword_tlb, `CA53_BIU_RBUFS_NUM, 0, g_mux_tlb_rdata)
  `CA53_BIU_ONEHOT_MUX(biu_read_resp_tlb,  3, 0, rbuf_fwd_tlb,       rbuf_resp_ecc, `CA53_BIU_RBUFS_NUM, 0, g_mux_tlb_rresp)

  // TLB data resp

  assign biu_walk_ack_o  = |rbuf_fwd_tlb;
  assign biu_walk_data_o = biu_read_data_tlb;
  assign biu_walk_resp_o = biu_read_resp_tlb;

  // MBIST TLB MB3 high data

  assign biu_mbist_in_data_hi_mb3_o = rbuf_data[0][116:64];

  //-----------------------------------------------------------------------------
  // STB (Cache maintenance, CleanUnique, and write address response) and
  // ECC complete acknowledge shared logic
  //-----------------------------------------------------------------------------

  // The STB AR resp and ECC complete acknowledge share the same fwd path:
  // o the corresponding responses are mutually exclusive
  // o the reponse is guaranteed to drain in the following cycle

  assign next_biu_stb_ar_resp_valid = scu_rr_valid_i & (`CA53_BIU_RID_IS_FOR_STB(scu_rr_id_i) | `CA53_BIU_RID_IS_FOR_ECC(scu_rr_id_i));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_stb_ar_resp_valid <= 1'b0;
    end else begin
      biu_stb_ar_resp_valid <= next_biu_stb_ar_resp_valid;
    end

  always @(posedge clk)
    if (scu_rr_valid_i) begin
      biu_stb_ar_resp        <= scu_rr_resp_i;
      biu_stb_ar_resp_id     <= scu_rr_id_i[2:0];
      biu_stb_ar_resp_l2dbid <= scu_rr_l2db_id_i[3:0];
    end

  assign biu_stb_ar_resp_sel = ~&biu_stb_ar_resp_id[2:1];

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  // BIU STB AR response

  assign biu_stb_ar_resp_valid_o  = biu_stb_ar_resp_valid & biu_stb_ar_resp_sel;
  assign biu_stb_ar_resp_o        = biu_stb_ar_resp;
  assign biu_stb_ar_resp_id_o     = {2'b11, biu_stb_ar_resp_id};
  assign biu_stb_ar_resp_l2dbid_o = biu_stb_ar_resp_l2dbid;

  // BIU Clean/Invalidate complete for the ECC Error Correction State machine

  assign biu_ecc_cinv_complete_o = biu_stb_ar_resp_valid & ~biu_stb_ar_resp_sel;

  //-----------------------------------------------------------------------------
  // RBUF oldest ordering (IFU and LFs management)
  //-----------------------------------------------------------------------------

  // In order to maintain ordering between the read data received,
  // the read buffers ordering bits are maintained. These form a matrix.
  // The ordering bit in the i-th row and j-th column indicates that
  // the i-th read buffer is ordered after the j-th if it is set,
  // or the reverse otherwise. For example, if there were five request IDs:
  //
  //      A  B  C  D  E
  //   A  0  0  1  0  0
  //   B  1  0  1  1  1
  //   C  0  0  0  0  0
  //   D  1  0  1  0  0
  //   E  1  0  1  1  0
  //
  // This set of bits indicates that the rbuf received are ordered C (oldest), A, D, E, B (youngest).
  // It can be observed that the bits on the diagonal (where i == j) are always zero, and that
  // the bits in the lower-left triangle are a complement of those in the upper-right triangle.
  // As such, it is only necessary to actually register the upper-right triangle of bits.
  //
  // When a read buffer is allocated, it becomes the youngest ID, and so all bits in
  // the row corresponding to that ID are set, and all bits in the corresponding column
  // are cleared.

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_ordering_outer
      for (index_j = 0; index_j < `CA53_BIU_RBUFS_NUM; index_j = index_j + 1) begin : gen_rbuf_ordering_inner
        if (index_i < index_j) begin : gen_rbuf_ordering_nested_0
          reg   rbuf_ordering_bit;
          wire  next_rbuf_ordering_bit;

          assign next_rbuf_ordering_bit = rbuf_fill_sel[index_i]                      |
                                          (rbuf_ordering_bit & ~rbuf_fill_sel[index_j]);

          always @(posedge clk)
            if (scu_dr_valid_i) begin
              rbuf_ordering_bit <= next_rbuf_ordering_bit;
            end

          assign rbuf_order_bits[index_i][index_j] = rbuf_ordering_bit;

        end else if (index_i == index_j) begin : gen_rbuf_ordering_nested_0_else_0

          assign rbuf_order_bits[index_i][index_j] = 1'b0;

        end else begin : gen_rbuf_ordering_nested_0_else_1

          assign rbuf_order_bits[index_i][index_j] = ~rbuf_order_bits[index_j][index_i];

        end
      end
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Valid read buffers which contains data for LF descriptors
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_for_lf
      // Compute the read buffers containing linefill data

      assign rbuf_for_lf_valid[index_i] = rbuf_valid[index_i] & `CA53_BIU_RID_IS_FOR_LF(rbuf_id[index_i]);

      // Compute the read buffers containing linefill data for eviction has been done or not needed

      assign rbuf_evict_done[index_i] = |((`CA53_BIU_LF_DESCR_NUM'h01 << rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & lf_descr_evict_done_i);

      // Compute the read buffers containing linefill data pending in the BIU M0/M1 DCU alloc stages

      assign rbuf_alloc_pend[index_i] = ((|((`CA53_BIU_LF_DESCR_NUM'h01 << rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & biu_alloc_lf_descr_m0_i)) &
                                          (|((4'h1 << rbuf_chunk[index_i][1:0]) & biu_alloc_chunk_req_m0_i)                                            )) |
                                         ((|((`CA53_BIU_LF_DESCR_NUM'h01 << rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0]) & biu_alloc_lf_descr_m1_i)) &
                                          (|((4'h1 << rbuf_chunk[index_i][1:0]) & biu_alloc_chunk_req_m1_i)                                             ) );

      // Get the oldest read buffer which contains data for a linefill descriptor
      // for which the eviction has been performed and not pending in M0/M1 DCU alloc stages

      assign rbuf_for_lf_oldest_sel[index_i] = ~|(rbuf_order_bits[index_i][`CA53_BIU_RBUFS_NUM-1:0] &
                                                  rbuf_for_lf_valid[`CA53_BIU_RBUFS_NUM-1:0]        &
                                                  rbuf_evict_done[`CA53_BIU_RBUFS_NUM-1:0]          &
                                                  ~rbuf_alloc_pend[`CA53_BIU_RBUFS_NUM-1:0]          ) &
                                                rbuf_for_lf_valid[index_i]                             &
                                                rbuf_evict_done[index_i]                               &
                                                ~rbuf_alloc_pend[index_i];
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign rbuf_for_lf_valid_o      = rbuf_for_lf_valid;
  assign rbuf_for_lf_oldest_sel_o = rbuf_for_lf_oldest_sel;

  //-----------------------------------------------------------------------------
  // Valid read buffers which contains data for IFU
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_for_ifu_valid
      assign rbuf_for_ifu_valid[index_i] = rbuf_valid[index_i] & `CA53_BIU_RID_IS_FOR_IFU(rbuf_id[index_i]);
    end
  endgenerate

  // Get the oldest read buffer which contains data for the IFU

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_rbuf_for_ifu_oldest_sel
      assign rbuf_for_ifu_oldest_sel[index_i] = ~|(rbuf_order_bits[index_i][`CA53_BIU_RBUFS_NUM-1:0] &
                                                     rbuf_for_ifu_valid[`CA53_BIU_RBUFS_NUM-1:0]     &
                                                     ~rbuf_clr_ifu[`CA53_BIU_RBUFS_NUM-1:0]           ) &
                                                  rbuf_for_ifu_valid[index_i]                           &
                                                  ~rbuf_clr_ifu[index_i];
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Pack read buffers content (LFs management)
  //-----------------------------------------------------------------------------

  generate
    for (index_i = 0; index_i < `CA53_BIU_RBUFS_NUM; index_i = index_i + 1) begin : gen_pack_rbuf
      assign rbuf_data_packed[128*index_i+127:128*index_i]                                                                = rbuf_data[index_i][127:0];
      assign rbuf_chunk_packed[2*index_i+1:2*index_i]                                                                     = rbuf_chunk[index_i][1:0];
      assign rbuf_id_packed[`CA53_BIU_LF_DESCR_NUM_W*index_i+`CA53_BIU_LF_DESCR_NUM_W-1:`CA53_BIU_LF_DESCR_NUM_W*index_i] = rbuf_id[index_i][`CA53_BIU_LF_DESCR_NUM_W-1:0];
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign rbuf_data_packed_o  = rbuf_data_packed;
  assign rbuf_chunk_packed_o = rbuf_chunk_packed;
  assign rbuf_id_packed_o    = rbuf_id_packed;
  assign rbuf_age_o          = rbuf_age;

  //-----------------------------------------------------------------------------
  // Gov Management
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign rbuf_valid_o = rbuf_valid;

  //-----------------------------------------------------------------------------
  // CP15 Imprecise Aborts Management
  //-----------------------------------------------------------------------------

  // The BIU triggers an imprecise abort/fault if there is an error
  // received along the response provided by the SCU on the read response channel.
  // The BIU does not keep track of the transaction IDs of the outstanding
  // CP15 coherent requests, as only for these type of requests there can be
  // an error response provided by the SCU on the read response channel.
  // The SCU registered response is used to compute the CP15 imprecise abort.

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign cp15_coh_imp_abort_o = biu_stb_ar_resp_valid                                            &
                                ((biu_stb_ar_resp[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_SLVERR) |
                                 (biu_stb_ar_resp[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR  ));

  assign cp15_coh_imp_fault_o = (biu_stb_ar_resp[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_DECERR);

`ifdef ARM_ASSERT_ON

  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown  #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_rr_valid_i")
  u_ovl_x_scu_rr_valid_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (scu_rr_valid_i));

  assert_never_unknown      #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "Register enable x-check: dcu_nc_id_beats_en[index_i]")
  u_ovl_x_dcu_nc_id_beats_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dcu_nc_id_beats_en));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "Register enable x-check: rbuf_en")
  u_ovl_x_rbuf_enindex_o (.clk       (clk_dr),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (rbuf_en));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_dr_valid_i")
  u_ovl_x_scu_dr_valid_i   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (scu_dr_valid_i));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_zero_one_hot     #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "dcu_nc_id_set_sel must be one hot")
  u_ovl_biu_read_data_01   (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (dcu_nc_id_set_sel));

  assert_zero_one_hot     #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "dcu_nc_id_dec_sel must be one hot")
  u_ovl_biu_read_data_02   (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (dcu_nc_id_dec_sel));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "dcu_nc_ar_id_used should never be unknown")
  u_ovl_biu_read_data_03   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (dcu_nc_ar_id_used));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "rbuf_fwd_ifu should never be unknown")
  u_ovl_biu_read_data_04   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rbuf_fwd_ifu));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "rbuf_fwd_dc3 should never be unknown")
  u_ovl_biu_read_data_05   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rbuf_fwd_dc3));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "rbuf_fwd_dc2 should never be unknown")
  u_ovl_biu_read_data_06   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rbuf_fwd_dc2));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "rbuf_fwd_tlb should never be unknown")
  u_ovl_biu_read_data_07   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rbuf_fwd_tlb));

  assert_zero_one_hot     #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM, `OVL_ASSERT, "only one read buffer should contain data for TLB NC")
  u_ovl_biu_read_data_08   (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (rbuf_tlb_nc));

  assert_implication      #(`OVL_FATAL, `OVL_ASSERT, "read buffer for TLB NC should not be valid more than one clock cycle")
  u_ovl_biu_read_data_09   (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (|rbuf_tlb_nc),
                            .consequent_expr (|(rbuf_tlb_nc & rbuf_clr)));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_stb_ar_resp_valid should never be unknown")
  u_ovl_biu_read_data_10   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (biu_stb_ar_resp_valid));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_ecc_cinv_complete_o should never be unknown")
  u_ovl_biu_read_data_11   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (biu_ecc_cinv_complete_o));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "cp15_coh_imp_abort_o should never be unknown")
  u_ovl_biu_read_data_12   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp15_coh_imp_abort_o));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "cp15_coh_imp_fault_o should never be unknown when the cp15_coh_imp_abort_o is set")
  u_ovl_biu_read_data_13   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (cp15_coh_imp_abort_o),
                            .test_expr (cp15_coh_imp_fault_o));

  assert_never            #(`OVL_FATAL, `OVL_ASSERT, "biu_dr_credits cannot hold more than 4 credits")
  u_ovl_biu_read_data_14   (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (biu_dr_credits > 4));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "The clock enable must never be unknown")
  u_ovl_biu_read_data_15   (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (clk_enable));

  assert_implication      #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is a potential access to the data read registers")
  u_ovl_biu_read_data_16   (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (|{rbuf_en,
                                                rbuf_valid,
                                                rbuf_clr,
                                                rbuf_clr_del,
                                                biu_dr_credits,
                                                next_rbuf_fwd_ifu,
                                                rbuf_fwd_ifu,
                                                rbuf_fwd_tlb,
                                                rbuf_fwd_dc3,
                                                rbuf_fwd_dc2}),
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

endmodule // ca53biu_data_read_buffers
