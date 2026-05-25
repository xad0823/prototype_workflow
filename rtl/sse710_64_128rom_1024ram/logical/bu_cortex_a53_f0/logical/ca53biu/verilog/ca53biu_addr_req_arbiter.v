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
// Abstract : BIU address request arbiter
//-----------------------------------------------------------------------------
//
// Overview
// --------
// The address request arbiter selects which address request has priority for the BIU-SCU
// address request channel.  Read requests can come from the DCU, TLB, IFU and LFs.
// The STB can make coherency requests that also require use
// of the address channel. The ECC Clean correction is issued by the DCU.

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_addr_req_arbiter
  (

   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                               clk,
   input  wire                               reset_n,

   //------------------------------------------------------------------------------
   // DPU read alloc mode interface
   //------------------------------------------------------------------------------

   input  wire [1:0]                         dpu_ramode_cnt_l1_i,
   input  wire [1:0]                         dpu_ramode_cnt_l2_i,

   //------------------------------------------------------------------------------
   // DPU misc
   //------------------------------------------------------------------------------

   input  wire                               dpu_dcache_on_i,
   input  wire                               dpu_kill_wr_i,
   input  wire                               dpu_flush_i,
   input  wire                               dpu_ready_wr_i,
   input  wire                               dpu_ready_cc_fail_wr_i,

   //-----------------------------------------------------------------------------
   // IFU Address Request
   //-----------------------------------------------------------------------------

   input  wire                               ifu_arvalid_i,
   input  wire [1:0]                         ifu_arid_i,
   input  wire [39:0]                        ifu_araddr_i,
   input  wire [1:0]                         ifu_arlen_i,
   input  wire [7:0]                         ifu_attrs_i,
   input  wire [1:0]                         ifu_arprot_i,
   output wire                               biu_i_arready_o,

   //-----------------------------------------------------------------------------
   // TLB Address Request
   //-----------------------------------------------------------------------------

   input  wire                               tlb_walk_nc_req_i,
   input  wire                               tlb_walk_lf_req_i,
   input  wire [39:0]                        tlb_walk_addr_i,
   input  wire                               tlb_walk_ns_dsc_i,
   input  wire                               tlb_walk_size_i,
   input  wire [7:0]                         tlb_walk_attrs_i,

   //-----------------------------------------------------------------------------
   // ECC Clean request
   //-----------------------------------------------------------------------------

   input  wire                               dcu_ecc_cinv_req_i,
   output wire                               biu_ecc_cinv_ack_o,
   input  wire [7:0]                         dcu_ecc_cinv_index_i,
   input  wire [1:0]                         dcu_ecc_cinv_way_i,

   //-----------------------------------------------------------------------------
   // DC2 NC Address Request (non-cacheable)
   //-----------------------------------------------------------------------------

   input  wire                               dcu_biu_active_i,
   input  wire                               dcu_load_dc2_i,
   input  wire                               dcu_biu_req_dc2_i,
   input  wire [39:0]                        dcu_pa_dc2_i,
   input  wire                               dcu_ns_dsc_dc2_i,
   input  wire [7:0]                         dcu_attrs_dc2_i,
   input  wire [1:0]                         dcu_size_dc2_i,
   input  wire [3:0]                         dcu_length_dc2_i,
   input  wire                               dcu_pld_l2_req_dc2_i,
   input  wire                               dcu_leaving_dc2_i,

   //-----------------------------------------------------------------------------
   // DC3 Address Request (non-cacheable & device)
   //-----------------------------------------------------------------------------

   input  wire                               dcu_load_dc3_i,
   input  wire                               dcu_biu_req_dc3_i,
   input  wire [39:6]                        dcu_pa_dc3_i,
   input  wire                               dcu_pipe_valid_dc3_i,
   input  wire                               dcu_valid_dc3_i,
   input  wire                               dcu_ns_dsc_dc3_i,
   input  wire                               dcu_priv_dc3_i,
   input  wire [7:0]                         dcu_attrs_dc3_i,
   input  wire [1:0]                         dcu_size_dc3_i,
   input  wire [3:0]                         dcu_length_dc3_i,
   input  wire                               dcu_pld_l2_req_dc3_i,
   input  wire                               dcu_exclusive_dc3_i,

   //-----------------------------------------------------------------------------
   // PLD L2 next ready
   //-----------------------------------------------------------------------------

   output wire                               biu_pld_l2_next_ready_o,

   //-----------------------------------------------------------------------------
   // DC3 Flush/CC fail/leaving and the outstanding load address [5:0]
   //-----------------------------------------------------------------------------

   output wire                               biu_cc_fail_or_flush_dc3_o,
   output wire                               biu_leaving_dc3_o,
   output wire                               biu_load_dc3_o,
   output wire [5:0]                         biu_load_pa_dc3_o,

   //-----------------------------------------------------------------------------
   // Device Address Request
   //-----------------------------------------------------------------------------

   input  wire                               dev_active_i,
   input  wire                               dev_req_i,
   input  wire [5:0]                         dev_addr_i,
   input  wire [2:0]                         dev_size_i,
   input  wire [1:0]                         dev_length_i,

   //-----------------------------------------------------------------------------
   // LFs Address Request
   //-----------------------------------------------------------------------------

   input  wire                               biu_lf_req_i,
   input  wire [39:4]                        biu_lf_addr_i,
   input  wire                               biu_lf_ns_dsc_i,
   input  wire [7:0]                         biu_lf_attrs_i,
   input  wire [3:0]                         biu_lf_way_i,
   input  wire [2:0]                         biu_lf_descr_id_i,
   input  wire [2:0]                         biu_lf_master_i,
   output wire                               biu_lf_ack_o,

   //----------------------------------------------------------------------------
   // LFs dirty in progress (STB barriers can start qualifier)
   //----------------------------------------------------------------------------

   input  wire                               biu_dirty_lf_in_progress_i,

   //----------------------------------------------------------------------------
   // STB Address Request (Cache maintenance, DVM, CleanUnique, and write address requests)
   //----------------------------------------------------------------------------

   input  wire                               stb_ar_req_i,
   input  wire                               stb_ar_early_req_i,
   input  wire [4:0]                         stb_ar_id_i,
   input  wire [1:0]                         stb_ar_way_i,
   input  wire [7:0]                         stb_ar_type_i,
   input  wire [39:0]                        stb_ar_addr_i,
   input  wire                               stb_ar_ns_dsc_i,
   input  wire [7:0]                         stb_ar_attrs_i,
   input  wire                               stb_ar_priv_i,
   input  wire                               stb_ar_excl_i,
   input  wire [15:0]                        stb_ar_asid_i,
   input  wire [7:0]                         stb_ar_vmid_i,
   input  wire [24:0]                        stb_ar_va_i,
   output wire                               biu_stb_ar_ack_o,

   //----------------------------------------------------------------------------
   // STB LF hazards (factorize into AR req output)
   //----------------------------------------------------------------------------

   input  wire [4:0]                         biu_lf_hazard_i,

   //----------------------------------------------------------------------------
   // Prefetchers LF request active (factorize into AR active output)
   //----------------------------------------------------------------------------

   input  wire                               pf_lf_active_i,

   //----------------------------------------------------------------------------
   // BIU-SCU Address Request
   //----------------------------------------------------------------------------

   input  wire                               scu_ar_credit_i,
   input  wire                               scu_ar_block_i,
   output wire                               biu_ar_active_o,
   output wire                               biu_ar_valid_o,
   output wire  [4:0]                        biu_ar_id_o,
   output wire  [4:0]                        biu_ar_type_o,
   output wire  [7:0]                        biu_ar_attrs_o,
   output wire  [4:0]                        biu_ar_way_o,
   output wire  [40:0]                       biu_ar_addr_o,
   output wire  [1:0]                        biu_ar_len_o,
   output wire  [2:0]                        biu_ar_size_o,
   output wire                               biu_ar_lock_o,
   output wire                               biu_ar_priv_o,
   output wire  [2:0]                        biu_ar_lf_master_o,

   //----------------------------------------------------------------------------
   // Read allocate mode
   //----------------------------------------------------------------------------

   input  wire                               scu_leave_ramode_i,
   input  wire                               lf_descr_inc_ramode_i,
   input  wire                               lf_descr_leave_ramode_i,
   output wire                               biu_read_alloc_pend_o,
   output wire                               biu_evnt_ramode_o,
   output wire                               biu_evnt_ramode_enter_o,

   //-----------------------------------------------------------------------------
   // DCU NC IDs status
   //-----------------------------------------------------------------------------

   input  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0] dcu_nc_ar_id_used_i,

   //-----------------------------------------------------------------------------
   // PLD L2 ID status
   //-----------------------------------------------------------------------------

   input  wire                               pld_l2_ar_id_used_i,

   //------------------------------------------------------------------------------
   // Outstanding reads
   //------------------------------------------------------------------------------

   input  wire                               data_fwd_dc2_i,
   input  wire                               data_fwd_dc3_i,
   input  wire                               data_fwd_tlb_i,
   output wire                               dc2_trans_outstanding_o,
   output wire [1:0]                         dc2_trans_outstanding_id_o,
   output wire                               dc2_trans_last_beat_o,
   output wire                               dc3_trans_outstanding_o,
   output wire [1:0]                         dc3_trans_outstanding_id_o,
   output wire [1:0]                         dc3_trans_cross128_o,
   output wire                               dc3_trans_last_beat_o,
   output wire                               tlb_nc_load_outstanding_o,
   output wire                               biu_ar_ready_dev_o,
   output wire [2:0]                         biu_ar_id_dev_o,

   //-----------------------------------------------------------------------------
   // PLD L1 sideband signals
   //-----------------------------------------------------------------------------

   output wire                               ar_block_o,
   output wire [3:0]                         ar_credits_used_o,
   output wire                               stb_is_dvm_o,

   //------------------------------------------------------------------------------
   // Performance monitors
   //------------------------------------------------------------------------------

   output wire [1:0]                         biu_evnt_ext_mem_req_o,
   output wire [1:0]                         biu_evnt_ext_mem_req_nc_o
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                                      ar_credit;
  reg  [3:0]                               ar_credits_used;
  reg                                      ar_block;
  reg                                      ar_block_prev_cycle;
  reg                                      biu_ar_valid;
  reg  [4:0]                               biu_ar_id;
  reg  [4:0]                               biu_ar_type;
  reg  [7:0]                               biu_ar_attrs;
  reg  [4:0]                               biu_ar_way;
  reg  [40:0]                              biu_ar_addr;
  reg  [1:0]                               biu_ar_len;
  reg  [2:0]                               biu_ar_size;
  reg                                      biu_ar_lock;
  reg                                      biu_ar_priv;
  reg  [2:0]                               biu_ar_lf_master;
  reg                                      biu_i_arready;
  reg                                      biu_ecc_cinv_ack;
  reg                                      biu_stb_ar_ack;
  reg                                      dc2_trans_outstanding;
  reg  [1:0]                               dc2_trans_id;
  reg                                      dc3_trans_outstanding;
  reg  [1:0]                               dc3_trans_id;
  reg  [1:0]                               dc3_trans_cross128;
  reg                                      dc3_last_beat;
  reg                                      tlb_nc_load_outstanding;
  reg                                      dvm_in_progress;
  reg  [5:0]                               biu_load_pa_dc3;
  reg                                      biu_load_dc3;
  reg                                      pld_l2_ready;
  reg                                      pld_l2_accepted_prev_cycle;
  reg                                      new_read_event;
  reg                                      new_read_event_nc;
  reg                                      new_write_event;
  reg                                      new_write_event_nc;
  reg  [8:0]                               read_alloc_count;
  reg                                      scu_leave_ramode_prev_cycle;
  reg                                      read_alloc_mode_prev_cycle;
  reg  [1:0]                               dpu_ramode_cnt_l1_prev_cycle;
  reg  [1:0]                               dpu_ramode_cnt_l2_prev_cycle;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                     ar_credit_available;
  wire                                     ar_credits_used_en;
  wire [3:0]                               next_ar_credits_used;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]       dcu_nc_ar_id_pend;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]       dcu_nc_ar_id_used;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]       dcu_nc_ar_id_available_sel;
  wire                                     ifu_wants_ar_pri;
  wire                                     tlb_wants_ar_pri;
  wire                                     ecc_wants_ar_pri;
  wire                                     dc2_wants_ar_pri;
  wire                                     dc3_wants_ar_pri;
  wire                                     lf_wants_ar_pri;
  wire                                     stb_wants_ar_pri;
  wire                                     stb_ar_req_suppress;
  wire                                     dc2_nc_load;
  wire                                     dc2_load_leaving;
  wire                                     dc2_last_beat;
  wire [5:0]                               dc2_trans_last_pa;
  wire [1:0]                               dc2_trans_cross128;
  wire                                     next_dc2_trans_outstanding;
  wire [1:0]                               next_dc2_trans_id;
  wire                                     dc3_nc_load;
  wire                                     dc2_trans_outstanding_pend;
  wire                                     dc3_trans_outstanding_pend;
  wire                                     next_dc3_trans_outstanding;
  wire [1:0]                               next_dc3_trans_id;
  wire                                     next_tlb_nc_load_outstanding;
  wire                                     next_biu_i_arready;
  wire                                     next_biu_ecc_cinv_ack;
  wire                                     next_biu_stb_ar_ack;
  wire                                     next_new_read_event;
  wire                                     next_new_read_event_nc;
  wire                                     next_new_write_event;
  wire                                     next_new_write_event_nc;
  wire                                     new_event_en;
  wire                                     stb_is_dvm;
  wire                                     stb_is_multipart_dvm;
  wire                                     next_dvm_in_progress;
  wire [40:0]                              dvm_msg_1;
  wire [40:0]                              dvm_msg_2;
  wire [`CA53_BIU_REQ_NUM-1:0]             arb_req;
  wire [`CA53_BIU_REQ_NUM-1:0]             arb_sel;
  wire [`CA53_BIU_REQ_NUM-1:0]             arb_has_ar_pri;
  wire                                     arb_ar_req;
  wire [4:0]                               ar_id        [`CA53_BIU_REQ_NUM-1:0];
  wire [4:0]                               ar_type      [`CA53_BIU_REQ_NUM-1:0];
  wire [7:0]                               ar_attrs     [`CA53_BIU_REQ_NUM-1:0];
  wire [4:0]                               ar_way       [`CA53_BIU_REQ_NUM-1:0];
  wire [40:0]                              ar_addr      [`CA53_BIU_REQ_NUM-1:0];
  wire [1:0]                               ar_len       [`CA53_BIU_REQ_NUM-1:0];
  wire [2:0]                               ar_size      [`CA53_BIU_REQ_NUM-1:0];
  wire [`CA53_BIU_REQ_NUM-1:0]             ar_lock;
  wire [`CA53_BIU_REQ_NUM-1:0]             ar_priv;
  wire [2:0]                               ar_lf_master [`CA53_BIU_REQ_NUM-1:0];
  wire [4:0]                               arb_ar_id;
  wire [4:0]                               arb_ar_type;
  wire [7:0]                               arb_ar_attrs;
  wire [4:0]                               arb_ar_way;
  wire [40:0]                              arb_ar_addr;
  wire [1:0]                               arb_ar_len;
  wire [2:0]                               arb_ar_size;
  wire                                     arb_ar_lock;
  wire                                     arb_ar_priv;
  wire [2:0]                               arb_ar_lf_master;
  wire                                     biu_ar_ready;
  wire                                     next_biu_ar_valid;
  wire                                     biu_ar_enable;
  wire                                     flush_dc2;
  wire                                     flush_dc3;
  wire                                     cc_fail_or_flush_dc2;
  wire                                     cc_fail_or_flush_dc3;
  wire                                     leaving_dc3;
  wire                                     next_biu_load_dc3;
  wire                                     biu_stb_ar_coh_done;
  wire                                     pld_l2_ar_id_pend;
  wire                                     pld_l2_ar_id_used;
  wire                                     pld_l2_accepted;
  wire                                     next_pld_l2_accepted_prev_cycle;
  wire                                     next_pld_l2_ready;
  wire                                     read_alloc_count_en;
  wire [8:0]                               next_read_alloc_count;
  wire                                     cancel_read_alloc;
  wire                                     read_alloc_mode;
  wire                                     read_alloc_mode_disabled;
  wire                                     read_alloc_saturate_mode;
  wire                                     read_alloc_saturate_mode_disabled;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                   index_i;

  //-----------------------------------------------------------------------------
  // Management of the AR credits
  //-----------------------------------------------------------------------------
  // There are a total of 8 credits, and on reset the BIU holds them all.
  // Every time the BIU sends an address request, it uses a credit (except
  // for the second half of 2 part DVMs, which don't need a credit). When all
  // credits are used, it must not send any more requests. The SCU will return
  // credits when it has freed up a request buffer.

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ar_credit <= 1'b0;
    end else begin
      ar_credit <= scu_ar_credit_i;
    end

  // Keep a counter of how many AR channel credits are in use.

  assign ar_credits_used_en = (next_biu_ar_valid & ~dvm_in_progress) ^ ar_credit;

  assign next_ar_credits_used = ar_credits_used + (ar_credit ? 4'b1111 : 4'b0001);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ar_credits_used <= 4'b0000;
    end else if (ar_credits_used_en) begin
      ar_credits_used <= next_ar_credits_used;
    end

  // The SCU can request to block all transactions, if it is using the request
  // buffers for requests not allocated by the BIU. This will only happen if
  // the CPU is reset or is in WFI, however it may remain blocked for a while
  // after this.
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ar_block            <= 1'b1;
      ar_block_prev_cycle <= 1'b1;
    end else begin
      ar_block            <= scu_ar_block_i;
      ar_block_prev_cycle <= ar_block;
    end

  // There are 8 credits that can be used. Once they are all used we must wait
  // for one to be returned before sending another AR command.

  assign ar_credit_available = (ar_credit | ~ar_credits_used[3]) &
                               (~ar_block | ~ar_block_prev_cycle );

  //-----------------------------------------------------------------------------
  // Valid DCU NC ID winner
  //-----------------------------------------------------------------------------
  // Compute the DCU NC ID which can be used for the next DCU NC transaction

  // Factorize the pending DCU NC transaction on the BIU-SCU AR channel

  assign dcu_nc_ar_id_pend  = (biu_ar_valid & `CA53_BIU_RID_IS_FOR_DCU_NC(biu_ar_id)) ?
                               ({{(`CA53_BIU_DCU_NC_ID_NUM-1){1'b0}}, 1'b1} << biu_ar_id[1:0]) :
                               {`CA53_BIU_DCU_NC_ID_NUM{1'b0}};

  assign dcu_nc_ar_id_used = dcu_nc_ar_id_used_i | dcu_nc_ar_id_pend;

  // Select the first unused DCU NC ID which can be used for the next DCU NC transaction

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : g_id_sel_req_0
      if (index_i == 0) begin : g_id_sel_req_0_nested_0
        assign dcu_nc_ar_id_available_sel[0] = ~dcu_nc_ar_id_used[0];
      end else begin : g_id_sel_req_0_nested_0_else
        assign dcu_nc_ar_id_available_sel[index_i] = ~dcu_nc_ar_id_used[index_i] & (&dcu_nc_ar_id_used[index_i-1:0]);
      end
    end
  endgenerate

  //-----------------------------------------------------------------------------
  // BIU-SCU AR requests
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // The IFU requests direct AR priority for all accesses.
  // The request remains asserted until address req ack is received from BIU.
  //-----------------------------------------------------------------------------

  assign ifu_wants_ar_pri = ifu_arvalid_i &
                            ~biu_i_arready;

  //-----------------------------------------------------------------------------
  // The TLB requests direct AR priority for accesses that will not allocate
  // into the L1 cache.  The request remains asserted until data is received.
  //-----------------------------------------------------------------------------

  assign tlb_wants_ar_pri = tlb_walk_nc_req_i &
                            ~tlb_nc_load_outstanding;

  //-----------------------------------------------------------------------------
  // The ECC Clean requests direct AR priority for all accesses.
  // The request remains asserted until address req ack is received from BIU.
  //-----------------------------------------------------------------------------

  assign ecc_wants_ar_pri = dcu_ecc_cinv_req_i &
                            ~biu_ecc_cinv_ack;

  //-----------------------------------------------------------------------------
  // The DC2/DC3 requests direct AR read priority for bursts that will not allocate
  // into the L1 cache and for which a valid ID is ready
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // DC2 normal non-cacheable loads
  // Speculative data fetches allowed, if required due to the Skyros transactions alignment.
  //-----------------------------------------------------------------------------

  assign dc2_nc_load = dcu_biu_req_dc2_i;

  // DC2 load leaving

  assign dc2_load_leaving = dcu_load_dc2_i & dcu_leaving_dc2_i;

  // Last beat computation:
  // o (one word left to be fetched) OR
  // o (two words left AND addr is double word aligned)

  assign dc2_last_beat = (~|dcu_length_dc2_i[3:1]) & (~dcu_length_dc2_i[0] | ~dcu_pa_dc2_i[2]);

  // Compute the last beat addr of the transaction (ie relative to the current line)

  assign dc2_trans_last_pa = {(dcu_pa_dc2_i[5:2] + dcu_length_dc2_i[3:0]), 2'b00};

  // Compute how many times the transaction crosses the 128-bit boundary

  assign dc2_trans_cross128 = dc2_trans_last_pa[5:4] - dcu_pa_dc2_i[5:4];

  // Issue normal non-cacheable loads in DC2 for single accesses in order to guarantee forward progress.
  // Check that the DC2 normal non-cacheable request does not block DC3 in order to avoid either of the
  // following deadlock scenarios:
  // o if a non-cacheable normal load requires four read buffers while there is another DC3 transaction
  //   waiting for the last beat to be received from SCU, it can happen that the SCU provides all four beats of
  //   data for the DC2 transaction before the DC3 beat. If none of the DC2 read buffers can be released
  //   until DC2 progresses to DC3, then the DC3 data from the SCU won't be accepted by the BIU as there
  //   isn't any read buffer available.
  // o load multiple issued from DC2 may occupy all read buffers without being able to guarantee
  // the buffers release until the load transaction progresses to DC3 leading to potential blockage of
  // the SCU response channel.

  assign dc2_wants_ar_pri = (dc2_nc_load                          &
                             dc2_last_beat                        &
                             ~`CA53_MEM_COHERENT(dcu_attrs_dc2_i) &
                             ~(&dcu_nc_ar_id_used)                &
                             ~dc2_trans_outstanding                )  |
                            (dcu_pld_l2_req_dc2_i & ~pld_l2_ar_id_used);

  //-----------------------------------------------------------------------------
  // DC3 normal non-cacheable & device
  //-----------------------------------------------------------------------------

  assign dc3_nc_load = dcu_biu_req_dc3_i & `CA53_MEM_NORMAL(dcu_attrs_dc3_i);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dc3_last_beat      <= 1'b0;
      dc3_trans_cross128 <= 2'b00;
    end else if (dc2_load_leaving) begin
      dc3_last_beat      <= dc2_last_beat;
      dc3_trans_cross128 <= dc2_trans_cross128;
    end

  assign dc3_wants_ar_pri = (((dc3_nc_load & ~dc3_trans_outstanding) |
                              dev_req_i                               ) &
                             ~(&dcu_nc_ar_id_used                       )) |
                            (dcu_pld_l2_req_dc3_i & ~pld_l2_ar_id_used     );

  //-----------------------------------------------------------------------------
  // The STB requests direct AR req channel priority for CP15 broadcasts and DVM
  // messages. The barriers must wait for the dirty linefills to complete before
  // requesting priority.
  //-----------------------------------------------------------------------------

  assign stb_ar_req_suppress = `CA53_BIU_STB_IS_WRITEUNIQUE(stb_ar_type_i, stb_ar_attrs_i) &
                               |(biu_lf_hazard_i & {stb_ar_id_i == `CA53_RID_STB4,
                                                    stb_ar_id_i == `CA53_RID_STB3,
                                                    stb_ar_id_i == `CA53_RID_STB2,
                                                    stb_ar_id_i == `CA53_RID_STB1,
                                                    stb_ar_id_i == `CA53_RID_STB0 }        );

  assign stb_wants_ar_pri    = stb_ar_req_i                          &
                               (~biu_dirty_lf_in_progress_i       |
                                ~`CA53_CPOP_8_IS_BAR(stb_ar_type_i)) &
                               ~stb_ar_req_suppress                  &
                               ~biu_stb_ar_ack;

  //-----------------------------------------------------------------------------
  // The LF requests direct AR priority for accesses that will allocate
  // into the L1 cache.  The request remains asserted until it gains priority to AR channel.
  //-----------------------------------------------------------------------------

  assign lf_wants_ar_pri = biu_lf_req_i;

  //-----------------------------------------------------------------------------
  // BIU-SCU AR Address Request Channel Arbiter
  //-----------------------------------------------------------------------------

  // Priority for the AR address request channel is as follows:
  // DC3 Dev/NC > DC2 Dev/NC > LF > TLB > IFU > ECCClean > STB (DVMs/D-Cache maintenance/Barriers/Wr NC/Wr Dev)
  // where > implies "has greater priority than".
  //
  // Multi-part DVM messages are an exception, as once the first part has been
  // accepted onto the read address channel there can be no other transactions
  // until the final part of the DVM message has been accepted.
  //
  // If the DCU (DC2/DC3) wanted priority for non-cachable request but the request
  // gets killed then nothing else gets arbitrated.
  // If the DCU (DC2/DC3) wanted priority for cachable request but the request
  // gets killed then no linefill nor new STB request gets arbitrated.
  // This helps timing as the relatively late kill signal then doesn't need
  // to factor into the arbitration.
  // Because the kill implies a pipeline flush the DCU (DC2/DC3) won't be making
  // a request in the following few cycles.
  //
  // The dvm_in_progress is factored into the has priority rather than the wants priority signal.
  // This is because dvm_in_progress makes the has priority signal too late to factor into the
  // read request mux but we still need to prevent any initiator getting priority if we're in the
  // middle of a multi-part DVM message.

  assign arb_req[`CA53_BIU_DC3_REQ] = dc3_wants_ar_pri;
  assign arb_req[`CA53_BIU_DC2_REQ] = dc2_wants_ar_pri;
  assign arb_req[`CA53_BIU_LF_REQ]  = lf_wants_ar_pri;
  assign arb_req[`CA53_BIU_TLB_REQ] = tlb_wants_ar_pri;
  assign arb_req[`CA53_BIU_IFU_REQ] = ifu_wants_ar_pri;
  assign arb_req[`CA53_BIU_ECC_REQ] = ecc_wants_ar_pri;
  assign arb_req[`CA53_BIU_STB_REQ] = stb_wants_ar_pri;

  generate
    for (index_i = 0; index_i < `CA53_BIU_REQ_NUM; index_i = index_i + 1) begin : g_arb_sel_req_0
      if (index_i == 0) begin : g_arb_sel_req_0_nested_0
        assign arb_sel[0] = arb_req[0];
      end else begin : g_arb_sel_req_0_nested_0_else
        assign arb_sel[index_i] = arb_req[index_i] & ~(|arb_req[index_i-1:0]);
      end
    end
  endgenerate

  assign arb_has_ar_pri[`CA53_BIU_DC3_REQ] = arb_sel[`CA53_BIU_DC3_REQ] & ~dvm_in_progress & ~cc_fail_or_flush_dc3;
  assign arb_has_ar_pri[`CA53_BIU_DC2_REQ] = arb_sel[`CA53_BIU_DC2_REQ] & ~dvm_in_progress & ~cc_fail_or_flush_dc2;
  assign arb_has_ar_pri[`CA53_BIU_LF_REQ]  = arb_sel[`CA53_BIU_LF_REQ]  & ~dvm_in_progress & ~cc_fail_or_flush_dc2 & ~cc_fail_or_flush_dc3;
  assign arb_has_ar_pri[`CA53_BIU_TLB_REQ] = arb_sel[`CA53_BIU_TLB_REQ] & ~dvm_in_progress;
  assign arb_has_ar_pri[`CA53_BIU_IFU_REQ] = arb_sel[`CA53_BIU_IFU_REQ] & ~dvm_in_progress;
  assign arb_has_ar_pri[`CA53_BIU_ECC_REQ] = arb_sel[`CA53_BIU_ECC_REQ] & ~dvm_in_progress;
  assign arb_has_ar_pri[`CA53_BIU_STB_REQ] = arb_sel[`CA53_BIU_STB_REQ] | dvm_in_progress;

  //-----------------------------------------------------------------------------
  // Arbitrated address request information
  // o The SCU_BIU address includes the NS bit
  //-----------------------------------------------------------------------------

  // IFU requests
  // o The IFU always requests one, two or four 128-bit beats,
  //   trans aligned to 128 bits and power of two bytes requested.

  assign ar_id        [`CA53_BIU_IFU_REQ] = `CA53_RID_IFU_MASK | {{3{1'b0}}, ifu_arid_i};
  assign ar_type      [`CA53_BIU_IFU_REQ] = `CA53_MEM_COHERENT(ifu_attrs_i) ? `CA53_REQ_READONCE : `CA53_REQ_READNOSNOOP;
  assign ar_attrs     [`CA53_BIU_IFU_REQ] = {ifu_attrs_i[7:6],
                                             // The inner allocation hints are disabled for the cacheable IFU transactions when D-cache is off
                                             {2{~(// D-cache off
                                                  ~dpu_dcache_on_i              &
                                                  // coherent IFU request
                                                  `CA53_MEM_COHERENT(ifu_attrs_i))}} &
                                             ifu_attrs_i[5:4],
                                             // The outer allocation hints are disabled for the cacheable IFU transactions when D-cache is off
                                             {2{~(// D-cache off
                                                  ~dpu_dcache_on_i                 &
                                                  // no Outer NC IFU request
                                                  ~`CA53_MEM_OUTER_NC(ifu_attrs_i) &
                                                  // normal memory type IFU request
                                                  `CA53_MEM_NORMAL(ifu_attrs_i     ))}} &
                                             ifu_attrs_i[3:2],
                                             ifu_attrs_i[1:0]};
  assign ar_way       [`CA53_BIU_IFU_REQ] = `CA53_MEM_COHERENT(ifu_attrs_i) ? {5{1'b1}} : {5{1'b0}};
  assign ar_addr      [`CA53_BIU_IFU_REQ] = {ifu_arprot_i[1], ifu_araddr_i[39:0]};
  assign ar_len       [`CA53_BIU_IFU_REQ] = ifu_arlen_i;
  assign ar_size      [`CA53_BIU_IFU_REQ] = `CA53_ACE_SIZE_128BIT;
  assign ar_lock      [`CA53_BIU_IFU_REQ] = `CA53_ACE_LOCK_NORMAL;
  assign ar_priv      [`CA53_BIU_IFU_REQ] = ifu_arprot_i[0];
  assign ar_lf_master [`CA53_BIU_IFU_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // ECC Clean requests

  assign ar_id        [`CA53_BIU_ECC_REQ] = `CA53_RID_ECC;
  assign ar_type      [`CA53_BIU_ECC_REQ] = `CA53_REQ_ECCCLEAN;
  assign ar_attrs     [`CA53_BIU_ECC_REQ] = {1'b1, {7{1'b0}}};
  assign ar_way       [`CA53_BIU_ECC_REQ] = {5{1'b0}};
  assign ar_addr      [`CA53_BIU_ECC_REQ] = {{9{1'b0}}, dcu_ecc_cinv_way_i, {16{1'b0}}, dcu_ecc_cinv_index_i, {6{1'b0}}};
  assign ar_len       [`CA53_BIU_ECC_REQ] = 2'b11;
  assign ar_size      [`CA53_BIU_ECC_REQ] = `CA53_ACE_SIZE_128BIT;
  assign ar_lock      [`CA53_BIU_ECC_REQ] = 1'b0;
  assign ar_priv      [`CA53_BIU_ECC_REQ] = 1'b1;
  assign ar_lf_master [`CA53_BIU_ECC_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // TLB NC requests

  assign ar_id        [`CA53_BIU_TLB_REQ] = `CA53_RID_TLB;
  assign ar_type      [`CA53_BIU_TLB_REQ] = `CA53_REQ_READNOSNOOP;
  assign ar_attrs     [`CA53_BIU_TLB_REQ] = tlb_walk_attrs_i;
  assign ar_way       [`CA53_BIU_TLB_REQ] = {5{1'b0}};
  assign ar_addr      [`CA53_BIU_TLB_REQ] = {tlb_walk_ns_dsc_i, tlb_walk_addr_i[39:0]};
  assign ar_len       [`CA53_BIU_TLB_REQ] = `CA53_REQ_LEN0;
  assign ar_size      [`CA53_BIU_TLB_REQ] = tlb_walk_size_i ? `CA53_ACE_SIZE_64BIT : `CA53_ACE_SIZE_32BIT;
  assign ar_lock      [`CA53_BIU_TLB_REQ] = `CA53_ACE_LOCK_NORMAL;
  assign ar_priv      [`CA53_BIU_TLB_REQ] = 1'b1;
  assign ar_lf_master [`CA53_BIU_TLB_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // STB non-LF requests

  assign ar_id        [`CA53_BIU_STB_REQ] = stb_ar_id_i;
  assign ar_type      [`CA53_BIU_STB_REQ] = `CA53_BIU_STB_TO_ARTYPE(stb_ar_type_i, stb_ar_attrs_i);
  assign ar_attrs     [`CA53_BIU_STB_REQ] = `CA53_CPOP_8_IS_BAR(stb_ar_type_i) ?
                                            {1'b1, {5{1'b0}},
                                             (stb_ar_type_i[1:0] == 2'b00) ? 2'b00 :
                                             (stb_ar_type_i[1:0] == 2'b01) ? 2'b11 :
                                             (stb_ar_type_i[1:0] == 2'b10) ? 2'b10 :
                                                                             2'b01  } :
                                            {stb_ar_attrs_i[7:5],
                                             // Inner write alloc disabled for the coherent writes while in read alloc saturate mode
                                             ~(read_alloc_saturate_mode & `CA53_BIU_STB_IS_WRITEUNIQUE(stb_ar_type_i, stb_ar_attrs_i)) & stb_ar_attrs_i[4],
                                             stb_ar_attrs_i[3:0]};
  assign ar_way       [`CA53_BIU_STB_REQ] = (`CA53_BIU_STB_IS_DVM(stb_ar_type_i)                          |
                                             `CA53_BIU_STB_IS_WRITENOSNOOP(stb_ar_type_i, stb_ar_attrs_i) |
                                             `CA53_BIU_STB_IS_WRITEUNIQUE(stb_ar_type_i, stb_ar_attrs_i)  |
                                             `CA53_BIU_STB_IS_CLEANSETWAY(stb_ar_type_i)                  |
                                             `CA53_BIU_STB_IS_CLEANINVSETWAY(stb_ar_type_i)               |
                                             `CA53_CPOP_8_IS_BAR(stb_ar_type_i                            )) ?
                                              // STB non cacheable related requests
                                              {5{1'b0}} :
                                            (`CA53_BIU_STB_IS_CLEANSHARED(stb_ar_type_i)  |
                                             `CA53_BIU_STB_IS_CLEANINVALID(stb_ar_type_i) |
                                             `CA53_BIU_STB_IS_MAKEINVALID(stb_ar_type_i   )) ?
                                              // STB CleanShared, CleanInvalid & MakeInvalid
                                              {5{1'b1}} :
                                              // STB CleanUnique
                                              {1'b1, (4'h1 << stb_ar_way_i[1:0])};
  assign ar_addr      [`CA53_BIU_STB_REQ] = `CA53_CPOP_8_IS_BAR(stb_ar_type_i) ?
                                             {41{1'b0}} :
                                            `CA53_BIU_STB_IS_DVM(stb_ar_type_i) ?
                                             // STB DVM requests
                                             {dvm_in_progress ? dvm_msg_2 : dvm_msg_1} :
                                            (`CA53_BIU_STB_IS_CLEANUNIQUE(stb_ar_type_i)  |
                                             `CA53_BIU_STB_IS_CLEANSHARED(stb_ar_type_i)  |
                                             `CA53_BIU_STB_IS_CLEANINVALID(stb_ar_type_i) |
                                             `CA53_BIU_STB_IS_MAKEINVALID(stb_ar_type_i   )) ?
                                             // STB CleanUnique, CleanShared, CleanInvalid, MakeInvalid
                                             {stb_ar_ns_dsc_i, stb_ar_addr_i[39:6], {6{1'b0}}} :
                                            (`CA53_BIU_STB_IS_WRITENOSNOOP(stb_ar_type_i, stb_ar_attrs_i) |
                                             `CA53_BIU_STB_IS_WRITEUNIQUE(stb_ar_type_i, stb_ar_attrs_i   )) ?
                                             // STB WriteNoSnoop, WriteUnique
                                             {stb_ar_ns_dsc_i, stb_ar_addr_i[39:4], 4'h0} :
                                             // STB set-way D-cache maintenance
                                             {stb_ar_ns_dsc_i, stb_ar_addr_i[39:0]};
  assign ar_len       [`CA53_BIU_STB_REQ] = (`CA53_BIU_STB_IS_DVM(stb_ar_type_i)                          |
                                             `CA53_BIU_STB_IS_WRITENOSNOOP(stb_ar_type_i, stb_ar_attrs_i) |
                                             `CA53_BIU_STB_IS_WRITEUNIQUE(stb_ar_type_i, stb_ar_attrs_i)  |
                                             `CA53_CPOP_8_IS_BAR(stb_ar_type_i                           )) ?
                                              // STB DVM, WriteNoSnoop, WriteUnique & barrier requests
                                              2'b00 :
                                              // STB CleanUnique, CleanShared, CleanInvalid, MakeInvalid, CleanSetWay & CleanInvSetWay
                                              2'b11;
  assign ar_size      [`CA53_BIU_STB_REQ] = `CA53_ACE_SIZE_128BIT;
  assign ar_lock      [`CA53_BIU_STB_REQ] = stb_ar_excl_i;
  assign ar_priv      [`CA53_BIU_STB_REQ] = stb_ar_priv_i                          |
                                            // Set the priv bit for DVM, D-cache maintanence and barriers
                                            ~`CA53_BIU_STB_IS_WRITE(stb_ar_type_i) |
                                            // Set the priv bit for mergeable stores which are not exclusive
                                            (`CA53_MEM_MERGEABLE(stb_ar_attrs_i) &
                                             ~stb_ar_excl_i                        );
  assign ar_lf_master [`CA53_BIU_STB_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // DC2 normal NC requests
  //
  // Load exclusives are not issued in DC2 for normal NC loads

  assign ar_id        [`CA53_BIU_DC2_REQ] = dcu_pld_l2_req_dc2_i ? `CA53_RID_RNONE                                                                 :
                                                                   (`CA53_RID_DCU_MASK | {3'b000, `CA53_BIU_ONEHOT2BIN(dcu_nc_ar_id_available_sel)});
  assign ar_type      [`CA53_BIU_DC2_REQ] = dcu_pld_l2_req_dc2_i                ? `CA53_REQ_READNONE :
                                            `CA53_MEM_COHERENT(dcu_attrs_dc2_i) ? `CA53_REQ_READONCE :
                                                                                  `CA53_REQ_READNOSNOOP;
  assign ar_attrs     [`CA53_BIU_DC2_REQ] = dcu_attrs_dc2_i;
  assign ar_way       [`CA53_BIU_DC2_REQ] = `CA53_MEM_COHERENT(dcu_attrs_dc2_i) ? {5{1'b1}} : {5{1'b0}};
  assign ar_addr      [`CA53_BIU_DC2_REQ] = {dcu_ns_dsc_dc2_i, dcu_pa_dc2_i[39:4], {4{~`CA53_MEM_COHERENT(dcu_attrs_dc2_i)}} & dcu_pa_dc2_i[3:0]};
  assign ar_len       [`CA53_BIU_DC2_REQ] = `CA53_MEM_COHERENT(dcu_attrs_dc2_i) ? `CA53_REQ_LEN3 : `CA53_REQ_LEN0;
  assign ar_size      [`CA53_BIU_DC2_REQ] = `CA53_MEM_COHERENT(dcu_attrs_dc2_i) ? `CA53_ACE_SIZE_128BIT :
                                            (dcu_size_dc2_i == 2'b00)           ? `CA53_ACE_SIZE_8BIT   :
                                            (dcu_size_dc2_i == 2'b01)           ? `CA53_ACE_SIZE_16BIT  :
                                            (dcu_size_dc2_i == 2'b10)           ? `CA53_ACE_SIZE_32BIT  :
                                                                                  `CA53_ACE_SIZE_64BIT;
  assign ar_lock      [`CA53_BIU_DC2_REQ] = 1'b0;
  assign ar_priv      [`CA53_BIU_DC2_REQ] = 1'b1;
  assign ar_lf_master [`CA53_BIU_DC2_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // DC3 normal NC & device requests
  //
  // Normal NC and device NEON accesses:
  //  o The transaction is optimized to fetch minimum data, still fulfilling the alignment and power of two bytes.
  //   (speculative data might be fetched)
  //
  // Device non-NEON accesses:
  //  o The transaction is optimized to issue minimum transactions, still fulfilling the alignment and power of two bytes.
  //    (speculative data must not be fetched, so the burst might be split in multiple transactions)

  assign ar_id        [`CA53_BIU_DC3_REQ] = dcu_pld_l2_req_dc3_i ? `CA53_RID_RNONE                                                                 :
                                                                   (`CA53_RID_DCU_MASK | {3'b000, `CA53_BIU_ONEHOT2BIN(dcu_nc_ar_id_available_sel)});
  assign ar_type      [`CA53_BIU_DC3_REQ] = dcu_pld_l2_req_dc3_i                ? `CA53_REQ_READNONE   :
                                            `CA53_MEM_COHERENT(dcu_attrs_dc3_i) ? `CA53_REQ_READONCE   :
                                                                                  `CA53_REQ_READNOSNOOP;
  assign ar_attrs     [`CA53_BIU_DC3_REQ] = dcu_attrs_dc3_i;
  assign ar_way       [`CA53_BIU_DC3_REQ] = `CA53_MEM_COHERENT(dcu_attrs_dc3_i) ? {5{1'b1}} : {5{1'b0}};
  assign ar_addr      [`CA53_BIU_DC3_REQ] = {                                      dcu_ns_dsc_dc3_i,
                                                                                   dcu_pa_dc3_i[39:6],
                                             // PLD L2
                                             dcu_pld_l2_req_dc3_i                ? {biu_load_pa_dc3[5:4], 4'h0} :
                                             // NORMAL NC exclusive
                                             (dc3_nc_load & dcu_exclusive_dc3_i) ? biu_load_pa_dc3[5:0] :
                                             // NORMAL non NC exclusive and transient loads
                                             `CA53_MEM_NORMAL(dcu_attrs_dc3_i)   ? {{2{~(dc3_trans_cross128[1] | (dc3_trans_cross128[0] & biu_load_pa_dc3[4]))}} & biu_load_pa_dc3[5:4],
                                                                                    4'h0} :
                                             // DEVICES
                                                                                   dev_addr_i[5:0]};
  assign ar_lock      [`CA53_BIU_DC3_REQ] = dcu_exclusive_dc3_i;
  assign ar_priv      [`CA53_BIU_DC3_REQ] = dcu_priv_dc3_i;
  assign ar_len       [`CA53_BIU_DC3_REQ] = // PLD L2 and transient loads
                                            `CA53_MEM_COHERENT(dcu_attrs_dc3_i) ? `CA53_REQ_LEN3                                                           :
                                            // NORMAL NC
                                            `CA53_MEM_NORMAL(dcu_attrs_dc3_i)   ?
                                            (((dc3_trans_cross128[1] | (dc3_trans_cross128[0] & biu_load_pa_dc3[4])) & ~dc3_last_beat) ? `CA53_REQ_LEN3 :
                                             (dc3_trans_cross128[0] & ~dc3_last_beat)                                                  ? `CA53_REQ_LEN1 :
                                                                                                                                         `CA53_REQ_LEN0  ) :
                                            // DEVICES
                                                                                  dev_length_i[1:0];
  assign ar_size      [`CA53_BIU_DC3_REQ] = // NORMAL NC exclusive
                                            (dc3_nc_load & dcu_exclusive_dc3_i) ? {dcu_length_dc3_i[1], {2{~dcu_length_dc3_i[1]}} & dcu_size_dc3_i[1:0]} :
                                            // PLD L2 or transient or NORMAL NC non-exclusive
                                            (`CA53_MEM_NORMAL(dcu_attrs_dc3_i)) ? `CA53_ACE_SIZE_128BIT                                                  :
                                            // DEVICES
                                                                                  dev_size_i;
  assign ar_lf_master [`CA53_BIU_DC3_REQ] = `CA53_BIU_LF_MASTER_NONE;

  // BIU LF requests

  assign ar_id        [`CA53_BIU_LF_REQ] = `CA53_RID_LF_MASK | {2'b00, biu_lf_descr_id_i};
  assign ar_type      [`CA53_BIU_LF_REQ] = `CA53_BIU_LF_FOR_WRITE(biu_lf_master_i) ? `CA53_REQ_READUNIQUE : `CA53_REQ_READSHARED;
  assign ar_attrs     [`CA53_BIU_LF_REQ] = biu_lf_attrs_i;
  assign ar_way       [`CA53_BIU_LF_REQ] = {1'b1, biu_lf_way_i};
  assign ar_addr      [`CA53_BIU_LF_REQ] = {biu_lf_ns_dsc_i, biu_lf_addr_i[39:4], 4'h0};
  assign ar_len       [`CA53_BIU_LF_REQ] = `CA53_REQ_LEN3;
  assign ar_size      [`CA53_BIU_LF_REQ] = `CA53_ACE_SIZE_128BIT;
  assign ar_lock      [`CA53_BIU_LF_REQ] = `CA53_BIU_LF_FOR_LDREX(biu_lf_master_i);
  assign ar_priv      [`CA53_BIU_LF_REQ] = 1'b1;
  assign ar_lf_master [`CA53_BIU_LF_REQ] = biu_lf_master_i[2:0];

  //-----------------------------------------------------------------------------
  // BIU-SCU AR arbitration winner
  //-----------------------------------------------------------------------------

  `CA53_BIU_ONEHOT_MUX(arb_ar_id,        5, 0, arb_has_ar_pri, ar_id,        `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_id)
  `CA53_BIU_ONEHOT_MUX(arb_ar_type,      5, 0, arb_has_ar_pri, ar_type,      `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_type)
  `CA53_BIU_ONEHOT_MUX(arb_ar_attrs,     8, 0, arb_has_ar_pri, ar_attrs,     `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_attrs)
  `CA53_BIU_ONEHOT_MUX(arb_ar_way,       5, 0, arb_has_ar_pri, ar_way,       `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_way)
  `CA53_BIU_ONEHOT_MUX(arb_ar_addr,     41, 0, arb_has_ar_pri, ar_addr,      `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_addr)
  `CA53_BIU_ONEHOT_MUX(arb_ar_len,       2, 0, arb_has_ar_pri, ar_len,       `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_len)
  `CA53_BIU_ONEHOT_MUX(arb_ar_size,      3, 0, arb_has_ar_pri, ar_size,      `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_size)
  `CA53_BIU_ONEHOT_MUX(arb_ar_lf_master, 3, 0, arb_has_ar_pri, ar_lf_master, `CA53_BIU_REQ_NUM, 0, g_mux_arb_ar_lf_master)

  assign arb_ar_lock = |(ar_lock & arb_has_ar_pri);

  assign arb_ar_priv = |(ar_priv & arb_has_ar_pri);

  assign arb_ar_req = |arb_has_ar_pri;

  //-----------------------------------------------------------------------------
  // Read address channel
  //-----------------------------------------------------------------------------

  // The read address channel is updated when there is a new request and
  // there is at least an AR credit available

  assign biu_ar_ready = ar_credit_available;

  assign next_biu_ar_valid = arb_ar_req & (ar_credit_available | dvm_in_progress);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_ar_valid <= 1'b0;
    end else begin
      biu_ar_valid <= next_biu_ar_valid;
    end

  assign biu_ar_enable = (|arb_req[`CA53_BIU_REQ_NUM-1:0]) & (ar_credit_available | dvm_in_progress);

  always @(posedge clk)
    if (biu_ar_enable) begin
      biu_ar_id        <= arb_ar_id;
      biu_ar_type      <= arb_ar_type;
      biu_ar_attrs     <= arb_ar_attrs;
      biu_ar_way       <= arb_ar_way;
      biu_ar_addr      <= arb_ar_addr;
      biu_ar_len       <= arb_ar_len;
      biu_ar_size      <= arb_ar_size;
      biu_ar_lock      <= arb_ar_lock;
      biu_ar_priv      <= arb_ar_priv;
      biu_ar_lf_master <= arb_ar_lf_master;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  // A request can be presented to the SCU in the cycle following a request being
  // made to the BIU.  For timing, the address request channel active signal is driven
  // without factoring in hazards that might prevent a request from propagating.

  assign biu_ar_active_o         = ifu_arvalid_i      |
                                   dcu_biu_active_i   |
                                   dev_active_i       |
                                   tlb_walk_nc_req_i  |
                                   tlb_walk_lf_req_i  |
                                   stb_ar_early_req_i |
                                   pf_lf_active_i;
  assign biu_ar_valid_o          = biu_ar_valid;
  assign biu_ar_id_o             = biu_ar_id;
  assign biu_ar_type_o           = biu_ar_type;
  assign biu_ar_attrs_o          = biu_ar_attrs;
  assign biu_ar_way_o            = biu_ar_way;
  assign biu_ar_addr_o           = biu_ar_addr;
  assign biu_ar_len_o            = biu_ar_len;
  assign biu_ar_size_o           = biu_ar_size;
  assign biu_ar_lock_o           = biu_ar_lock;
  assign biu_ar_priv_o           = biu_ar_priv;
  assign biu_ar_lf_master_o      = biu_ar_lf_master;
  assign biu_lf_ack_o            = biu_ar_ready & arb_has_ar_pri[`CA53_BIU_LF_REQ];
  assign biu_ar_ready_dev_o      = biu_ar_ready & dev_req_i & ~(&dcu_nc_ar_id_used) & ~dvm_in_progress;
  assign biu_ar_id_dev_o         = ar_id[`CA53_BIU_DC3_REQ][2:0];

  //-----------------------------------------------------------------------------
  // DC2/3 flush and DC3 leaving computation
  //-----------------------------------------------------------------------------

  assign flush_dc2            = (dpu_kill_wr_i & ~dcu_pipe_valid_dc3_i)                |
                                (dpu_flush_i & (~dpu_ready_wr_i | dcu_pipe_valid_dc3_i));

  assign flush_dc3            = dpu_kill_wr_i | (dpu_flush_i & ~dpu_ready_wr_i);

  assign cc_fail_or_flush_dc2 = flush_dc2 | (dpu_ready_cc_fail_wr_i & ~dcu_pipe_valid_dc3_i);

  assign cc_fail_or_flush_dc3 = flush_dc3 | dpu_ready_cc_fail_wr_i;

  assign leaving_dc3          = dcu_valid_dc3_i & dpu_ready_wr_i;

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_cc_fail_or_flush_dc3_o = cc_fail_or_flush_dc3;
  assign biu_leaving_dc3_o          = leaving_dc3;

  //-------------------------------------------------------------------------------------------------------
  // DC3 load status and load outstanding address[5:0]
  //-------------------------------------------------------------------------------------------------------
  // Register the DC3 load qualifier and address[5:0] of the load transactions only
  // (ease the timing closure and also for the GRE device multiple load handling)

  assign next_biu_load_dc3 = dc2_load_leaving                               |
                             (biu_load_dc3 & ~(leaving_dc3 | data_fwd_dc3_i));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_load_dc3 <= 1'b0;
    end else begin
      biu_load_dc3 <= next_biu_load_dc3;
    end

  always @(posedge clk)
    if (dc2_load_leaving) begin
      biu_load_pa_dc3 <= dcu_pa_dc2_i[5:0];
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_load_dc3_o    = biu_load_dc3;
  assign biu_load_pa_dc3_o = biu_load_pa_dc3;

  //-----------------------------------------------------------------------------
  // Outstanding DC2/DC3/TLB reads
  //-----------------------------------------------------------------------------

  // The per-ID load_outstanding flags are set when the address is presented to
  // the SCU and cleared as the last beat of data is forwarded to the requesting
  // block.

  //-----------------------------------------------------------------------------
  // DC2 NC or Read once
  //-----------------------------------------------------------------------------

  // dc2_trans_outstanding:
  // o Set when the address is presented to the SCU (either from dc2 or dc3)
  // o Cleared when the last beat of the transaction is forwarded to the requesting block, moved from dc2 or flushed

  assign next_dc2_trans_outstanding = ((((dc2_nc_load & arb_has_ar_pri[`CA53_BIU_DC2_REQ])                |
                                         (dc3_nc_load & arb_has_ar_pri[`CA53_BIU_DC3_REQ] & ~dc3_last_beat)) &
                                        biu_ar_ready                                                          ) |
                                       (dc2_trans_outstanding & ~cc_fail_or_flush_dc2                           )) &
                                      ~(dcu_load_dc2_i & dc2_last_beat & (data_fwd_dc2_i | dcu_leaving_dc2_i)      );

  // dc2_trans_id:
  // o Set when the address is presented to the SCU (either from dc2 or dc3)
  // o Cleared when the last beat of the transaction is forwarded to the requesting block or flushed

  assign next_dc2_trans_id = (biu_ar_ready                                         &
                              (arb_has_ar_pri[`CA53_BIU_DC2_REQ]                  |
                               (arb_has_ar_pri[`CA53_BIU_DC3_REQ] & ~dc3_last_beat))) ? `CA53_BIU_ONEHOT2BIN(dcu_nc_ar_id_available_sel) :
                                                                                        dc2_trans_id;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dc2_trans_outstanding <= 1'b0;
      dc2_trans_id          <= 2'b00;
    end else begin
      dc2_trans_outstanding <= next_dc2_trans_outstanding;
      dc2_trans_id          <= next_dc2_trans_id;
    end

  //-----------------------------------------------------------------------------
  // DC3 NC or Read once
  //-----------------------------------------------------------------------------

  // DC3 transaction outstanding:
  // o Set when the address is presented to the SCU (either from dc2 or dc3)
  // o Cleared when the last beat of the transaction is forwarded
  //   to the requesting block, moved from dc3 or flushed.

  assign dc2_trans_outstanding_pend = ((dc2_nc_load & arb_has_ar_pri[`CA53_BIU_DC2_REQ] & biu_ar_ready) |
                                       (dc2_trans_outstanding & ~cc_fail_or_flush_dc2                   )) &
                                      ~(dc2_last_beat & data_fwd_dc2_i                                     );

  assign dc3_trans_outstanding_pend = ((dc3_nc_load & arb_has_ar_pri[`CA53_BIU_DC3_REQ] & biu_ar_ready)  |
                                       (dc3_trans_outstanding & ~cc_fail_or_flush_dc3                    )) &
                                      ~(dc3_last_beat & dcu_load_dc3_i & (leaving_dc3 | data_fwd_dc3_i)     );

  assign next_dc3_trans_outstanding = (dc2_trans_outstanding_pend & dcu_leaving_dc2_i) | dc3_trans_outstanding_pend;

  // DC3 transaction ID:
  // o Set when the address is presented to the SCU (either from dc2 or dc3)
  // o Cleared when the last beat of the transaction is forwarded to the requesting block or flushed

  assign next_dc3_trans_id = (dcu_leaving_dc2_i & dc2_trans_outstanding)                              ? dc2_trans_id                                     :
                             ((arb_has_ar_pri[`CA53_BIU_DC3_REQ] & biu_ar_ready)                   |
                              (dcu_leaving_dc2_i & arb_has_ar_pri[`CA53_BIU_DC2_REQ] & biu_ar_ready)) ? `CA53_BIU_ONEHOT2BIN(dcu_nc_ar_id_available_sel) :
                                                                                                        dc3_trans_id;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dc3_trans_outstanding <= 1'b0;
      dc3_trans_id          <= 2'b00;
    end else begin
      dc3_trans_outstanding <= next_dc3_trans_outstanding;
      dc3_trans_id          <= next_dc3_trans_id;
    end

  //-----------------------------------------------------------------------------
  // TLB NC
  //-----------------------------------------------------------------------------

  // TLB NC transaction outstanding:
  // o Set when the address is presented to the SCU
  // o Cleared when the TLB NC descriptor is provided by the BIU
  // Note: the TLB cannot abandon a TLB NC transaction

  assign next_tlb_nc_load_outstanding = ((arb_has_ar_pri[`CA53_BIU_TLB_REQ] & biu_ar_ready) |
                                         tlb_nc_load_outstanding                             ) &
                                        ~data_fwd_tlb_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      tlb_nc_load_outstanding <= 1'b0;
    end else begin
      tlb_nc_load_outstanding <= next_tlb_nc_load_outstanding;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign dc2_trans_outstanding_o    = dc2_trans_outstanding;
  assign dc2_trans_outstanding_id_o = dc2_trans_id;
  assign dc2_trans_last_beat_o      = dc2_last_beat;
  assign dc3_trans_outstanding_o    = dc3_trans_outstanding;
  assign dc3_trans_outstanding_id_o = dc3_trans_id;
  assign dc3_trans_cross128_o       = dc3_trans_cross128;
  assign dc3_trans_last_beat_o      = dc3_last_beat;
  assign tlb_nc_load_outstanding_o  = tlb_nc_load_outstanding;

  //-----------------------------------------------------------------------------
  // IFU request acknowledgement
  //-----------------------------------------------------------------------------

  // For timing purposes, the BIU asserts biu_i_arready in the first cycle that read address
  // information is available on BIU_SCU AR channel.

  assign next_biu_i_arready = arb_has_ar_pri[`CA53_BIU_IFU_REQ] & biu_ar_ready;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_i_arready <= 1'b0;
    end else begin
      biu_i_arready <= next_biu_i_arready;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_i_arready_o = biu_i_arready;

  //-----------------------------------------------------------------------------
  // ECC Clean request acknowledgement
  //-----------------------------------------------------------------------------

  // For timing purposes, the BIU asserts biu_ecc_cinv_ack in the first cycle that read address
  // information is available on BIU_SCU AR channel.

  assign next_biu_ecc_cinv_ack = arb_has_ar_pri[`CA53_BIU_ECC_REQ] & biu_ar_ready;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_ecc_cinv_ack <= 1'b0;
    end else begin
      biu_ecc_cinv_ack <= next_biu_ecc_cinv_ack;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_ecc_cinv_ack_o = biu_ecc_cinv_ack;

  //-----------------------------------------------------------------------------
  // STB request acknowledgement
  //-----------------------------------------------------------------------------

  // Acknowledge request when it is accepted onto the read address channel.
  // For multi-part DVM messages, only send the acknowledge when accepting
  // the final part.

  assign next_biu_stb_ar_ack = arb_has_ar_pri[`CA53_BIU_STB_REQ]      &
                               (dvm_in_progress                      |
                                (biu_ar_ready & ~stb_is_multipart_dvm));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_stb_ar_ack <= 1'b0;
    end else begin
      biu_stb_ar_ack <= next_biu_stb_ar_ack;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_stb_ar_ack_o = biu_stb_ar_ack;

  // Construct DVM messages.

  assign stb_is_dvm           = `CA53_BIU_STB_IS_DVM(stb_ar_type_i);
  assign stb_is_multipart_dvm = stb_is_dvm & dvm_msg_1[0];

  ca53biu_dvm_enc u_dvm_enc (
    // Inputs
    .stb_ar_type_i   (stb_ar_type_i[7:0]),
    .stb_ar_asid_i   (stb_ar_asid_i[15:0]),
    .stb_ar_vmid_i   (stb_ar_vmid_i[7:0]),
    .stb_ar_va_i     ({stb_ar_va_i[24:16], stb_ar_addr_i[39:28], stb_ar_va_i[15:0], stb_ar_addr_i[11:0]}),
    .stb_ar_addr_i   (stb_ar_addr_i[39:0]),
    .stb_ar_attrs_i  (stb_ar_attrs_i[7:0]),
    .stb_ar_ns_dsc_i (stb_ar_ns_dsc_i),
    .stb_ar_ns_scr_i (stb_ar_priv_i),
    // Outputs
    .dvm_msg_1_o     (dvm_msg_1[40:0]),
    .dvm_msg_2_o     (dvm_msg_2[40:0])
  );  // u_dvm_enc

  // Flag when we have accepted the first part of a multi-part DVM message.

  assign next_dvm_in_progress = ~dvm_in_progress                  &
                                arb_has_ar_pri[`CA53_BIU_STB_REQ] &
                                stb_is_multipart_dvm              &
                                biu_ar_ready;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dvm_in_progress <= 1'b0;
    end else begin
      dvm_in_progress <= next_dvm_in_progress;
    end

  //-----------------------------------------------------------------------------
  // Read allocate counter
  //-----------------------------------------------------------------------------

  // dpu_ramode_cnt_l2: Write streaming no-allocate threshold Write streaming no-allocate threshold. The possible values are:
  //   o 2'b00 16th consecutive streaming cache line does not allocate in the L1 or L2 cache.
  //   o 2'b01 128th consecutive streaming cache line does not allocate in the L1 or L2 cache. This is the reset value.
  //   o 2'b10 512th consecutive streaming cache line does not allocate in the L1 or L2 cache.
  //   o 2'b11 Disables streaming. All write-allocate lines allocate in the L1 or L2 cache.
  //
  // dpu_ramode_cnt_l1: Write streaming no-L1-allocate threshold Write streaming no-L1-allocate threshold. The possible values are:
  //   o 2'b00 4th consecutive streaming cache line does not allocate in the L1 cache. This is the reset value.
  //   o 2'b01 64th consecutive streaming cache line does not allocate in the L1 cache.
  //   o 2'b10 128th consecutive streaming cache line does not allocate in the L1 cache.
  //   o 2'b11 Disables streaming. All write-allocate lines allocate in the L1 cache.

  assign biu_stb_ar_coh_done               = biu_stb_ar_ack                       &
                                             (biu_ar_type == `CA53_REQ_WRITEUNIQUE);

  assign read_alloc_mode                   = (dpu_ramode_cnt_l1_prev_cycle == 2'b00) ? (|read_alloc_count[8:2]) :
                                             (dpu_ramode_cnt_l1_prev_cycle == 2'b01) ? (|read_alloc_count[8:6]) :
                                             (dpu_ramode_cnt_l1_prev_cycle == 2'b10) ? (|read_alloc_count[8:7]) :
                                                                                       1'b0;

  assign read_alloc_mode_disabled          = (dpu_ramode_cnt_l1_prev_cycle == 2'b11);

  assign read_alloc_saturate_mode          = (dpu_ramode_cnt_l2_prev_cycle == 2'b00) ? (|read_alloc_count[8:4]) :
                                             (dpu_ramode_cnt_l2_prev_cycle == 2'b01) ? (|read_alloc_count[8:7]) :
                                             (dpu_ramode_cnt_l2_prev_cycle == 2'b10) ? (&read_alloc_count[8:0]) :
                                                                                       1'b0;

  assign read_alloc_saturate_mode_disabled = (dpu_ramode_cnt_l2_prev_cycle == 2'b11);


  assign cancel_read_alloc                 = read_alloc_mode_disabled                   |
                                             scu_leave_ramode_prev_cycle                |
                                             (~read_alloc_mode & lf_descr_leave_ramode_i);

  assign next_read_alloc_count             = {9{~cancel_read_alloc}}  &
                                             (read_alloc_count + 9'd1);

  assign read_alloc_count_en               = // Clear the read allocate counter
                                             cancel_read_alloc                                                                                      |
                                             // Increment while not in read allocate mode
                                             (~read_alloc_mode & lf_descr_inc_ramode_i)                                                             |
                                             // Increment while in read allocate mode and not in read allocate saturate mode
                                             (~read_alloc_saturate_mode_disabled & ~read_alloc_saturate_mode & read_alloc_mode & biu_stb_ar_coh_done);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      read_alloc_count <= {9{1'b0}};
    end else if (read_alloc_count_en) begin
      read_alloc_count <= next_read_alloc_count;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      read_alloc_mode_prev_cycle <= 1'b0;
    end else begin
      read_alloc_mode_prev_cycle <= read_alloc_mode;
    end

  // Register the DPU config and the SCU leave RA mode in order to ease the timing closure

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_ramode_cnt_l1_prev_cycle <= 2'b00;
      dpu_ramode_cnt_l2_prev_cycle <= 2'b01;
      scu_leave_ramode_prev_cycle  <= 1'b0;
    end else begin
      dpu_ramode_cnt_l1_prev_cycle <= dpu_ramode_cnt_l1_i;
      dpu_ramode_cnt_l2_prev_cycle <= dpu_ramode_cnt_l2_i;
      scu_leave_ramode_prev_cycle  <= scu_leave_ramode_i;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_read_alloc_pend_o   = |read_alloc_count;
  assign biu_evnt_ramode_o       = read_alloc_mode;
  assign biu_evnt_ramode_enter_o = ~read_alloc_mode_prev_cycle & read_alloc_mode;

  //-----------------------------------------------------------------------------
  // PLD L2 sideband signals
  //-----------------------------------------------------------------------------

  assign pld_l2_ar_id_pend = // AR valid
                             biu_ar_valid                         &
                             // PLD L2 arbitration won
                             `CA53_BIU_RID_IS_FOR_PLD_L2(biu_ar_id);

  assign pld_l2_ar_id_used = pld_l2_ar_id_used_i | pld_l2_ar_id_pend;

  // Compute if a PLD L2 is accepted this cycle.
  // In order to ease the timing closure the corresponding dc2/3 cc_fail/flush are not factorized

  assign pld_l2_accepted = pld_l2_ready                                &
                           (dcu_pld_l2_req_dc2_i | dcu_pld_l2_req_dc3_i);

  // Compute if a PLD L2 was accepted previous cycle

  assign next_pld_l2_accepted_prev_cycle = pld_l2_ready                                                 &
                                           ((dcu_pld_l2_req_dc2_i & arb_has_ar_pri[`CA53_BIU_DC2_REQ]) |
                                            (dcu_pld_l2_req_dc3_i & arb_has_ar_pri[`CA53_BIU_DC3_REQ]  ));

  assign next_pld_l2_ready = (// PLD L2 arbitration won
                              pld_l2_ar_id_pend                          |
                              (// ReadNone AR ID available
                               ~pld_l2_ar_id_used                       &
                               // AR credits available
                               (ar_credits_used < 4'h7)                 &
                               // AR not blocked
                               ~ar_block                                &
                               // DC2/3 non PLD L2 loads not pending
                               (dcu_pld_l2_req_dc2_i | ~dcu_load_dc2_i) &
                               (dcu_pld_l2_req_dc3_i | ~dcu_load_dc3_i) &
                               // STB multipart DVM request not pending
                               ~(stb_ar_req_i & stb_is_multipart_dvm    ))) &
                              // Avoid back to back PLD L2 accepted
                              ~pld_l2_accepted                              &
                              ~pld_l2_accepted_prev_cycle;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pld_l2_ready               <= 1'b0;
      pld_l2_accepted_prev_cycle <= 1'b0;
    end else begin
      pld_l2_ready               <= next_pld_l2_ready;
      pld_l2_accepted_prev_cycle <= next_pld_l2_accepted_prev_cycle;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_pld_l2_next_ready_o = next_pld_l2_ready;

  //-----------------------------------------------------------------------------
  // PLD L1 sideband signals
  //-----------------------------------------------------------------------------

  assign ar_block_o        = ar_block;
  assign ar_credits_used_o = ar_credits_used;
  assign stb_is_dvm_o      = stb_is_dvm;

  //-----------------------------------------------------------------------------
  // Performance monitors
  //-----------------------------------------------------------------------------

  // Update read event counters when a new read is presented to the SCU.
  // Read events include all requests on the DCU, TLB, LFB, and IFU read ids.

  assign next_new_read_event = biu_ar_valid                       &
                               `CA53_BIU_RID_IS_FOR_READ(biu_ar_id);

  // Non-cacheable read events on the dside include:
  // - inner WT, NC, Dev reads
  // - inner WB reads when the cache is off
  //
  // Non-cacheable read events on the iside include:
  // - inner NC, Dev reads
  // - inner WB/WT reads when the cache is off

  assign next_new_read_event_nc = next_new_read_event                     &
                                  ~(`CA53_MEM_WB(biu_ar_attrs)           |
                                    (`CA53_MEM_WT(biu_ar_attrs)         &
                                     ~`CA53_BIU_RID_IS_FOR_IFU(biu_ar_id)));

  // Increment write event counters when the SCU accepts a write address.

  assign next_new_write_event = biu_ar_valid                             &
                                ((biu_ar_type == `CA53_REQ_WRITEUNIQUE) |
                                 (biu_ar_type == `CA53_REQ_WRITENOSNOOP ));

  // Non-cacheable write events include:
  // - inner WT, NC, Dev writes

  assign next_new_write_event_nc = next_new_write_event      &
                                   ~`CA53_MEM_WB(biu_ar_attrs);

  assign new_event_en = biu_ar_valid   |
                        new_read_event |
                        new_write_event;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      new_read_event     <= 1'b0;
      new_read_event_nc  <= 1'b0;
      new_write_event    <= 1'b0;
      new_write_event_nc <= 1'b0;
    end else if (new_event_en) begin
      new_read_event     <= next_new_read_event;
      new_read_event_nc  <= next_new_read_event_nc;
      new_write_event    <= next_new_write_event;
      new_write_event_nc <= next_new_write_event_nc;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_evnt_ext_mem_req_o    = {new_read_event,    new_write_event};
  assign biu_evnt_ext_mem_req_nc_o = {new_read_event_nc, new_write_event_nc};

`ifdef ARM_ASSERT_ON

  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown      #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ar_credits_used_en")
  u_ovl_x_ar_credits_used_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ar_credits_used_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_ar_enable")
  u_ovl_x_ar_enable     (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_ar_enable));

  assert_never_unknown    #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dc2_load_leaving")
  u_ovl_x_dc2_load_leaving (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (dc2_load_leaving));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: new_event_en")
  u_ovl_x_new_event_en  (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (new_event_en));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_zero_one_hot #(`OVL_FATAL, `CA53_BIU_REQ_NUM, `OVL_ASSERT, "AR has priority signals must be one hot")
  u_ovl_ar_arbiter_01  (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (arb_has_ar_pri));

  assert_never_unknown #(`OVL_FATAL, 71, `OVL_ASSERT, "If a request has been given priority then the arbitrated request information is never unknown")
  u_ovl_ar_arbiter_02   (.clk             (clk),
                         .reset_n         (reset_n),
                         .qualifier       (|arb_has_ar_pri),
                         .test_expr       ({arb_ar_id,
                                            arb_ar_type,
                                            arb_ar_attrs,
                                            arb_ar_way,
                                            arb_ar_addr,
                                            arb_ar_len,
                                            arb_ar_size,
                                            arb_ar_lock,
                                            arb_ar_priv}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only some IDs on the read address channel correspond to reads")
  u_ovl_ar_arbiter_03 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (biu_ar_valid_o & `CA53_BIU_RID_IS_FOR_READ(biu_ar_id_o)),
                       .consequent_expr ((biu_ar_id_o == `CA53_RID_DCU0)  |
                                         (biu_ar_id_o == `CA53_RID_DCU1)  |
                                         (biu_ar_id_o == `CA53_RID_DCU2)  |
                                         (biu_ar_id_o == `CA53_RID_DCU3)  |
                                         (biu_ar_id_o == `CA53_RID_LFB0)  |
                                         (biu_ar_id_o == `CA53_RID_LFB1)  |
                                         (biu_ar_id_o == `CA53_RID_LFB2)  |
                                         (biu_ar_id_o == `CA53_RID_LFB3)  |
                                         (biu_ar_id_o == `CA53_RID_LFB4)  |
                                         (biu_ar_id_o == `CA53_RID_LFB5)  |
                                         (biu_ar_id_o == `CA53_RID_LFB6)  |
                                         (biu_ar_id_o == `CA53_RID_LFB7)  |
                                         (biu_ar_id_o == `CA53_RID_RNONE) |
                                         (biu_ar_id_o == `CA53_RID_ICU0)  |
                                         (biu_ar_id_o == `CA53_RID_ICU1)  |
                                         (biu_ar_id_o == `CA53_RID_ICU2)  |
                                         (biu_ar_id_o == `CA53_RID_TLB)));

  assert_never       #(`OVL_FATAL, `OVL_ASSERT, "Memory read and write events are mutually exclusive")
  u_ovl_ar_arbiter_04 (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr ((new_read_event | new_read_event_nc) & (new_write_event | new_write_event_nc)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A read NC event should be counted as a read event, too")
  u_ovl_ar_arbiter_05 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (new_read_event_nc),
                       .consequent_expr (new_read_event));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A write NC event should be counted as a write event, too")
  u_ovl_ar_arbiter_06 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (new_write_event_nc),
                       .consequent_expr (new_write_event));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "stb_is_dvm must be consistent with the operation type")
  u_ovl_ar_arbiter_07 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (stb_ar_req_i),
                       .consequent_expr (stb_is_dvm ==
                                         (// AA64 TLB ops
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE1)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE1IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE1)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAAE1)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAAE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAALE1)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAALE1IS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2E1)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2E1IS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2LE1)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2LE1IS)   |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE2)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE2IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE2)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE3)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE3IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE3)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE3IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASIDE1)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASIDE1IS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLE1)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLE1IS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLS12E1)   |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLS12E1IS) |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE1)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE2)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE3)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE3IS)      |
                                          // AA32 TLB ops
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVA)          |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAIS)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAL)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVALIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAA)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAAIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAAL)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAALIS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2L)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2LIS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAH)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAHIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVALH)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVALHIS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASID)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASIDIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALL)          |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLIS)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLNSNH)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLNSNHIS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLH)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLHIS)       |
                                          // IC ops
                                          (stb_ar_type_i == `CA53_CPOP_8_ICIALLUIS)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_ICIALLU)          |
                                          (stb_ar_type_i == `CA53_CPOP_8_ICIMVAU)          |
                                          // BP ops
                                          (stb_ar_type_i == `CA53_CPOP_8_BPIALLIS)         |
                                          (stb_ar_type_i == `CA53_CPOP_8_BPIMVA)           |
                                          // Sync
                                          (stb_ar_type_i == `CA53_CPOP_8_SYNC)             )));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DVM for IS detection must be consistent with the operation type")
  u_ovl_ar_arbiter_08 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (stb_ar_req_i & stb_is_dvm & (stb_ar_type_i != `CA53_CPOP_8_ICIVAU)),
                       .consequent_expr (`CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ==
                                         (// AA64 TLB ops
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE1IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAAE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAALE1IS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2E1IS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2LE1IS)   |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE2IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVAE3IS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVALE3IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASIDE1IS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLE1IS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIVMALLS12E1IS) |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE1IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLE3IS)      |
                                          // AA32 TLB ops
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAIS)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVALIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAAIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAALIS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2IS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIIPAS2LIS)     |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVAHIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIMVALHIS)      |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIASIDIS)       |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLIS)        |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLNSNHIS)    |
                                          (stb_ar_type_i == `CA53_CPOP_8_TLBIALLHIS)       |
                                          // IC ops
                                          (stb_ar_type_i == `CA53_CPOP_8_ICIALLUIS)        |
                                          // BP ops
                                          (stb_ar_type_i == `CA53_CPOP_8_BPIMVA)           |
                                          (stb_ar_type_i == `CA53_CPOP_8_BPIALLIS)         )));

  assert_never_unknown #(`OVL_FATAL, `CA53_BIU_REQ_NUM, `OVL_ASSERT, "arb_has_ar_pri should never be unknown")
  u_ovl_ar_arbiter_09   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (arb_has_ar_pri));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_dvm_in_progress should never be unknown")
  u_ovl_ar_arbiter_10   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_dvm_in_progress));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_tlb_nc_load_outstanding should never be unknown")
  u_ovl_ar_arbiter_11   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_tlb_nc_load_outstanding));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_dc2_trans_outstanding should never be unknown")
  u_ovl_ar_arbiter_12   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_dc2_trans_outstanding));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_dc3_trans_outstanding should never be unknown")
  u_ovl_ar_arbiter_13   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_dc3_trans_outstanding));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_new_read_event should never be unknown")
  u_ovl_ar_arbiter_14   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_new_read_event));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_biu_stb_ar_ack should never be unknown")
  u_ovl_ar_arbiter_15   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_biu_stb_ar_ack));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "next_dc2_trans_id should never be unknown")
  u_ovl_ar_arbiter_16   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_dc2_trans_id));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "next_dc3_trans_id should never be unknown")
  u_ovl_ar_arbiter_17   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_dc3_trans_id));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "read_alloc_count_en should never be unknown")
  u_ovl_ar_arbiter_18   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (read_alloc_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "read_alloc_saturate_mode should never be unknown")
  u_ovl_ar_arbiter_19   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (read_alloc_saturate_mode));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "read_alloc_mode should never be unknown")
  u_ovl_ar_arbiter_20  (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (read_alloc_mode));

  assert_never_unknown #(`OVL_FATAL, 9, `OVL_ASSERT, "read_alloc_count should never be unknown")
  u_ovl_ar_arbiter_21   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (read_alloc_count));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_new_write_event should never be unknown")
  u_ovl_ar_arbiter_22   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (next_new_write_event));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "next_new_write_event_nc should never be unknown when next_new_write_event is set")
  u_ovl_ar_arbiter_23   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (next_new_write_event),
                         .test_expr (next_new_write_event_nc));

  assert_never         #(`OVL_FATAL, `OVL_ASSERT, "ar_credits_used cannot hold more than 8 credits")
  u_ovl_ar_arbiter_24   (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr (ar_credits_used > 8));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_addr_req_arbiter
