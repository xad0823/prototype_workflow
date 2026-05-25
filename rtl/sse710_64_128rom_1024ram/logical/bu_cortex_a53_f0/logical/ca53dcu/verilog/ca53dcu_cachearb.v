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
// Abstract : DCU Cache Arbiter and Dcache interface
//
// RAM accesses are performed in two pipeline stages: The control signals are
// sent to the RAMs early in the M1 cycle, and any data is returned late
// in M2. To improve the M1 timing to ensure that the control signals are
// early enough, the arbitration for RAM accesses is split over two cycles,
// with lower priority accesses arbitrated in M0 before entering the
// pipeline. For load requests, the M1 and M2 stages correspond to DC1 and
// DC2 in the load store pipeline respectively.
//
// Arbitration is done separately for each of the Data, Tag and Dirty RAMs,
// and a simple fixed priority scheme is used. For resources which may access
// more than one resource, arbitration will only be granted when all can be
// accessed, so the requestor gets access to all its requested resources at
// the same time. If a higher priority request is blocked waiting for a
// resource, then a lower priority request will be granted arbitration if it has
// all its resources available.
//
// --------------------------------------------------
// Priority | Source                  | Arbitrated In
// --------------------------------------------------
//    0     | MBIST                   |      M0
//    1     | CCB                     |      M1
//    2     | Loads                   |      M1
//    3     | Linefill allocations    |      M0
//    4     | TLB lookups             |      M0
//    5     | STB lookups and writes  |      M0
//    6     | Prefetcher lookups      |      M0
//    7     | CP15 accesses           |      M0
// --------------------------------------------------
//
//
// MBIST accesses can occur at any time and take priority over any other
// accesses. Some blocks will suppress their requests to the cache arbiter
// when MBIST is ongoing, and priority will be suppressed in the cache
// arbiter for others. Therefore whenever there is an MBIST request, no
// other request can be granted arbitration, so MBIST requests do not need
// to be arbitrated. MBIST can leave the DCU in an indeterminate state but
// this is OK because the core will be reset following MBIST.
//
// For requests which do a tag lookup, the cache arbiter will perform the
// tag comparison and hit detection in M2, and return a hit signal to the
// requestor. For misses which will start a linefill, the cache arbiter
// will also indicate a victim way to use for the subsequent allocation.
// For TLB and load requests, which do a tag lookup and request data, the
// cache arbiter will also select the correct data from the output of the
// data RAM based on the tag lookup result.
//
// To improve power efficiency, the cache arbiter contains logic to track
// the result of load tag lookups. This means that the tag lookup and all
// but the necessary data RAM bank enables can be suppressed on loads which
// hit in tracker.
//
//-----------------------------------------------------------------------------

`include "ca53dcu_defs.v"
`include "cortexa53params.v"

module ca53dcu_cachearb `CA53_DCU_PARAM_DECL
  (
   input    wire                              clk,
   input    wire                              reset_n,
   input    wire                              DFTRAMHOLD,


   //--------------------------------------------------------------------------
   // LSPipe Interface
   //--------------------------------------------------------------------------

   input    wire                              dc_load_req_m1_i,
   input    wire                              dc_load_tag_req_only_m1_i,
   input    wire                              dc_valid_load_req_m1_i,
   input    wire                              dc_load_first_m1_i,
   input    wire                              dc_force_non_seq_i,
   input    wire                              dc_force_first_i,
   input    wire                      [39:3]  dc_load_addr_m1_i,
   input    wire                              dc_load_tag_ns_dsc_m1_i,
   input    wire                       [7:0]  dc_load_bls_m1_i,
   input    wire                              dcu_ready_iss_i,

   output   wire                              dc_ecc_tag_err_m2_o,
   output   wire                              dc_ecc_err_m3_o,
   output   wire                              dc_load_has_priority_m1_o,
   output   wire                              dc_load_index_match_m1_o,
   output   wire                              dc_load_hit_m2_o,
   output   wire                              dc_load_raw_hit_m2_o,
   output   wire                      [63:0]  dc_load_data_m2_o,
   output   wire                      [63:0]  dc_debug_tag_data_m2_o,
   output   wire                       [1:0]  dc_load_victim_way_m2_o,
   output   wire                              alloc_invalidating_tag_m1_o,
   output   wire                              load_lookup_m2_o,
   output   wire                              dc_throttle_loads_o,


   //--------------------------------------------------------------------------
   // CP15 Interface
   //--------------------------------------------------------------------------

   input   wire                               cp15_tag_req_m0_i,
   input   wire                               cp15_data_req_m0_i,
   input   wire                               dc_inv_all_in_progress_i,
   input   wire                        [3:0]  cp15_way_m0_i,
   input   wire                       [13:3]  cp15_addr_m0_i,
   input   wire                               cp15_wr_m0_i,

   output wire                                dc_cp15_ack_m1_o,
   output wire                                cp15_data_has_priority_m0_o,
   output wire                                cp15_tag_has_priority_m0_o,


   //--------------------------------------------------------------------------
   // CCB Interface
   //--------------------------------------------------------------------------

   input  wire                                ccb_tag_req_m1_i,
   input  wire                                ccb_block_prearb_tag_m1_i,
   input  wire                                ccb_dirty_req_m1_i,
   input  wire                         [3:0]  ccb_dirty_wdata_m1_i,
   input  wire                        [13:6]  ccb_dirty_addr_m1_i,
   input  wire                         [3:0]  ccb_dirty_way_m1_i,
   input  wire                        [40:6]  ccb_write_addr_m1_i,
   input  wire                         [3:0]  ccb_write_way_m1_i,
   input  wire                         [1:0]  ccb_tag_moesi_m1_i,
   input  wire                                ccb_data_req_m1_i,
   input  wire                                ccb_valid_data_req_m1_i,
   input  wire                                ccb_ecc_make_inv_i,
   input  wire                         [3:0]  ccb_lookup_way_i,
   input  wire                        [13:6]  ccb_lookup_addr_i,
   input  wire                                ccb_inv_snoop_m2_i,
   input  wire                        [13:5]  ccb_data_addr_m1_i,
   input  wire                                ccb_dirty_m2_i,

   output wire                         [3:0]  ccb_hit_dirty_m2_o,
   output wire                                dc_ccb_data_has_priorty_m1_o,
   output wire                                dc_throttle_snoops_o,


   //--------------------------------------------------------------------------
   // DPU Interface
   //--------------------------------------------------------------------------

   input  wire                                dpu_l1deien_i,
   input  wire                                dpu_force_first_iss_i,
   input  wire                                dpu_exception_level_1_i,
   input  wire                        [48:6]  dpu_va_dc1_i,
   input  wire                                dpu_valid_iss_i,
   input  wire                                dpu_flush_i,
   input  wire                                dpu_aarch64_state_i,
   input  wire                        [48:6]  dpu_agu_a_operand_iss_i,
   input  wire                        [48:6]  dpu_agu_b_operand_iss_i,
   input  wire                                dpu_agu_carry_out_64b_iss_i,

   output wire                                dcu_ecc_valid_o,
   output wire                                dcu_ecc_fatal_o,
   output wire                         [1:0]  dcu_ecc_ramid_o,
   output wire                         [2:0]  dcu_ecc_way_bank_id_o,
   output wire                        [10:0]  dcu_ecc_index_o,


   //--------------------------------------------------------------------------
   // BIU Interface
   //--------------------------------------------------------------------------

   input   wire                               biu_alloc_tag_req_m0_i,
   input   wire                               biu_alloc_data_req_m0_i,
   input   wire                               biu_alloc_halfline_m0_i,
   input   wire                               biu_alloc_dirty_req_m0_i,
   input   wire                        [1:0]  biu_alloc_tag_moesi_m0_i,
   input   wire                      [255:0]  biu_alloc_data_m0_i,
   input   wire                        [1:0]  biu_alloc_dirty_moesi_m1_i,
   input   wire                               biu_alloc_dirty_age_m1_i,
   input   wire                        [7:0]  biu_alloc_attrs_m1_i,
   input   wire                               biu_ecc_cinv_ack_i,
   input   wire                               biu_ecc_cinv_complete_i,
   input   wire                               biu_pf_tag_req_m0_i,
   input   wire                       [39:4]  biu_alloc_addr_m0_i,
   input   wire                       [39:6]  biu_pf_tag_addr_m0_i,
   input   wire                               biu_alloc_ns_dsc_m0_i,
   input   wire                               biu_pf_tag_ns_dsc_m0_i,
   input   wire                        [3:0]  biu_alloc_way_m0_i,
   input   wire                               biu_suppress_load_hit_dc2_i,
   input   wire                               biu_suppress_tlb_hit_i,

   output  wire                               dcu_alloc_has_priority_m0_o,
   output  wire                               dcu_alloc_ack_m1_o,
   output  wire                        [7:0]  dcu_ecc_cinv_index_o,
   output  wire                               dcu_ecc_cinv_req_o,
   output  wire                        [1:0]  dcu_ecc_cinv_way_o,
   output  wire                               dcu_ecc_fatal_m3_o,
   output  wire                       [55:0]  dcu_ecc_syndrome_m3_o,
   output  wire                               dcu_ecc_tag_err_m3_o,
   output  wire                               dcu_pf_tag_has_priority_m0_o,
   output  wire                               dcu_pf_tag_ack_m1_o,
   output  wire                               dcu_pf_tag_hit_m2_o,
   output  wire                      [255:0]  dcu_snoop_data_m2_o,
   output  wire                        [6:0]  dcu_mbist_data_checkbits_mb6_o,


   //--------------------------------------------------------------------------
   // STB Interface
   //--------------------------------------------------------------------------

   input   wire                               stb_cache_tag_req_m0_i,     // Wants tag access (for reading or writing)
   input   wire                               stb_cache_tag_wr_m0_i,      // Tag access is for a write
   input   wire                        [3:0]  stb_cache_tag_way_m0_i,
   input   wire                       [39:6]  stb_cache_tag_addr_m0_i,
   input   wire                               stb_cache_tag_ns_dsc_m0_i,
   input   wire                               stb_cache_data_req_m0_i,
   input   wire                       [13:4]  stb_cache_data_addr_m0_i,
   input   wire                        [3:0]  stb_cache_data_way_m0_i,
   input   wire                               stb_cache_data_wr_m0_i,
   input   wire                        [15:0] stb_cache_data_bls_m0_i,
   input   wire                        [7:0]  stb_cache_data_attrs_m0_i,
   input   wire                               stb_cache_data_migratory_m0_i,
   input   wire                       [127:0] stb_cache_write_data_m0_i,

   output  wire                               dcu_ecc_data_err_m3_o,
   output  wire                               dcu_ecc_in_progress_o,
   output  wire                               dcu_ecc_tag_err_m2_o,
   output  wire                               dcu_stb_tag_has_priority_m0_o,
   output  wire                               dcu_stb_tag_ack_m1_o,
   output  wire                        [3:0]  dcu_stb_tag_hit_m2_o,
   output  wire                               dcu_stb_tag_migratory_m2_o,
   output  wire                        [3:0]  dcu_stb_victim_way_m2_o,
   output  wire                               dcu_stb_tag_shared_m2_o,
   output  wire                               dcu_stb_data_has_priority_m0_o,
   output  wire                               dcu_stb_data_ack_m1_o,
   output  wire                       [127:0] dcu_stb_read_data_m2_o,

   //--------------------------------------------------------------------------
   // TLB Interface
   //--------------------------------------------------------------------------

   input   wire                       [39:3]  tlb_cache_walk_addr_i,
   input   wire                        [1:0]  tlb_cache_walk_lookup_req_m0_i,
   input   wire                               tlb_cache_walk_ns_dsc_i,

   output  wire                               dcu_cache_walk_has_priority_m0_o,
   output  wire                               dcu_cache_walk_ack_m1_o,
   output  wire                       [63:0]  dcu_cache_walk_data_m2_o,
   output  wire                               dcu_cache_walk_hit_m2_o,
   output  wire                        [3:0]  dcu_cache_walk_victim_way_m2_o,
   output  wire                               dcu_ecc_err_m3_o,

   //--------------------------------------------------------------------------
   // RAMS Interface
   //--------------------------------------------------------------------------

   input   wire                        [2:0]  dc_size_i,
   input   wire     [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata0_i,
   input   wire     [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata1_i,
   input   wire     [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata2_i,
   input   wire     [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_rdata3_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata0_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata1_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata2_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata3_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata4_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata5_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata6_i,
   input   wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_rdata7_i,
   input   wire   [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_rdata_i,

   output  wire                        [3:0]  dc_tagram_en_o,
   output  wire                               dc_tagram_wr_o,
   output  wire     [(`CA53_DTAG_RAM_W-1):0]  dc_tagram_wdata_o,
   output  wire                        [7:0]  dc_tagram_addr_o,
   output  wire                        [7:0]  dc_dataram_en_o,
   output  wire                               dc_dataram_wr_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb0_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb1_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb2_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb3_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb4_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb5_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb6_o,
   output  wire    [(`CA53_DDATA_WEN_W-1):0]  dc_dataram_strb7_o,
   output  wire                       [10:0]  dc_dataram_addr0_o,
   output  wire                       [10:0]  dc_dataram_addr1_o,
   output  wire                       [10:0]  dc_dataram_addr2_o,
   output  wire                       [10:0]  dc_dataram_addr3_o,
   output  wire                       [10:0]  dc_dataram_addr4_o,
   output  wire                       [10:0]  dc_dataram_addr5_o,
   output  wire                       [10:0]  dc_dataram_addr6_o,
   output  wire                       [10:0]  dc_dataram_addr7_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata0_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata1_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata2_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata3_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata4_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata5_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata6_o,
   output  wire    [(`CA53_DDATA_RAM_W-1):0]  dc_dataram_wdata7_o,
   output  wire                               dc_dirtyram_en_o,
   output  wire                               dc_dirtyram_wr_o,
   output  wire   [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_strb_o,
   output  wire                        [8:0]  dc_dirtyram_addr_o,
   output  wire   [(`CA53_DDIRTY_RAM_W-1):0]  dc_dirtyram_wdata_o,


   //--------------------------------------------------------------------------
   // MBIST Interface
   //--------------------------------------------------------------------------

   input   wire                               mbist_en_i,
   input   wire                               mbist_sel_mb3_i,
   input   wire                               mbist_cfg_mb3_i,
   input   wire                               mbist_read_en_mb3_i,
   input   wire                               mbist_write_en_mb3_i,
   input   wire   [(`CA53_DDIRTY_RAM_W-1):0]  mbist_be_mb3_i,
   input   wire                        [6:0]  mbist_array_mb3_i,
   input   wire                       [10:0]  mbist_addr_mb3_i

  );


  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  localparam                     SEQ_STATE_ENTRIES  = 4;
  localparam                     SEQ_VICTIM_CNT_W   = `CA53_LOG2(SEQ_STATE_ENTRIES);
  localparam                     SEQ_VICTIM_CNT_MAX = SEQ_STATE_ENTRIES - 1;

  localparam                     TIMEOUT_CNT_W      = 2;
  localparam [TIMEOUT_CNT_W-1:0] TIMEOUT_CNT        = 2'b11;

  localparam               [2:0] REQ_NONE           = 3'b000;
  localparam               [2:0] REQ_ALLOC          = 3'b001;
  localparam               [2:0] REQ_TLB            = 3'b011;
  localparam               [2:0] REQ_STB            = 3'b100;
  localparam               [2:0] REQ_PF             = 3'b101;
  localparam               [2:0] REQ_CP15           = 3'b110;
  localparam               [2:0] REQ_MBIST          = 3'b111;

  localparam                     ROTATION_W         = 6;
  localparam               [5:0] ROTATION_0         = 6'b000001;
  localparam               [5:0] ROTATION_1         = 6'b000010;
  localparam               [5:0] ROTATION_2         = 6'b000100;
  localparam               [5:0] ROTATION_3         = 6'b001000;
  localparam               [5:0] ROTATION_STB_0     = 6'b010000;
  localparam               [5:0] ROTATION_STB_1     = 6'b100000;
  localparam               [5:0] ROTATION_X         = 6'bxxxxxx;

  localparam               [1:0] LOOKUP_LOAD        = 2'b01;
  localparam               [1:0] LOOKUP_TLB         = 2'b10;
  localparam               [1:0] LOOKUP_STB         = 2'b11;
  localparam               [1:0] LOOKUP_PF          = 2'b00;  // Not used directly but need others not to be set on PF lookup



  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------

  reg                                             ccb_inv_snoop_m3;
  wire                                            ecc_data_err_correct_m3;
  wire                                            ecc_data_err_merrsr_m3;
  reg                                             ecc_dirty_err_m3;
  wire                                            ecc_dirty_err_correct_m3;
  wire                                            ecc_dirty_err_merrsr_m3;
  wire                                            alloc_data_granted_m0;
  reg                  [(`CA53_DCU_DATA_W-1): 0]  prearb_data_wdata_m1;
  wire                                            alloc_data_priority_m0;
  wire                                            alloc_data_req_m1;
  wire                                            alloc_dirty_granted_m0;
  wire                                            alloc_dirty_priority_m0;
  wire                                            alloc_dirty_req_m1;
  wire                                    [3: 0]  alloc_dirty_wdata_m1;
  wire                                    [3: 0]  alloc_lower_two_data_bank_pairs_m0;
  wire                                            alloc_req_outstanding_m1;
  wire                                            alloc_tag_granted_m0;
  wire                                            alloc_tag_priority_m0;
  wire                                            alloc_tag_req_m1;
  wire                                    [3: 0]  dword_data_banksel_m2;
  reg                                     [2: 0]  ccb_data_addr01_m1;
  reg                                     [2: 0]  ccb_data_addr23_m1;
  reg                                     [2: 0]  ccb_data_addr45_m1;
  reg                                     [2: 0]  ccb_data_addr67_m1;
  wire                                            cp15_data_priority_m0;
  wire                                            cp15_tag_priority_m0;
  wire                                            cp15_tag_granted_m0;
  wire                                            cp15_data_granted_m0;
  wire                                            cp15_data_req_m1;
  wire                                            cp15_tag_req_m1;
  wire                                    [5: 3]  data_addr01_m0;
  wire                                    [5: 3]  data_addr23_m0;
  wire                                    [5: 3]  data_addr45_m0;
  wire                                    [5: 3]  data_addr67_m0;
  reg                                     [7: 0]  data_bank_en_m0;
  reg                                     [1: 0]  dword_data_offset_m2;
  wire                                    [3: 0]  dword_data_seq_banksel_m1;
  wire                                    [3: 0]  load_data_banksel_m1;
  wire                                    [3: 0]  cp15_data_banksel_m1;
  wire                                            qword_data_offset_m1;
  wire                                            data_m0_en;
  wire                                            data_wdata_m0_en_any;
  wire                                            data_wdata_m0_en_hi;
  wire                                            data_req_outstanding_m1;
  wire                                    [2: 0]  data_req_type_m0;
  wire                                    [5: 4]  data_seq_req_qword_offset_m0;
  wire                                   [13: 6]  data_set_addr_m0;
  wire                                   [15: 0]  data_strb_m0;
  reg                          [ROTATION_W-1: 0]  data_rotation_m0;
  wire                                    [3: 0]  data_way_m0;
  wire                                   [10: 0]  dataram_addr01_m1;
  wire                                   [10: 0]  dataram_addr23_m1;
  wire                                   [10: 0]  dataram_addr45_m1;
  wire                                   [10: 0]  dataram_addr67_m1;
  wire                                    [7: 0]  dataram_en_m1;
  wire                                    [7: 0]  early_dataram_en_m1;
  wire                                    [7: 0]  load_data_en_way0_m1;
  wire                                    [7: 0]  load_data_en_way1_m1;
  wire                                    [7: 0]  load_data_en_way2_m1;
  wire                                    [7: 0]  load_data_en_way3_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb0_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb1_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb2_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb3_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb4_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb5_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb6_m1;
  wire                [(`CA53_DDATA_WEN_W-1): 0]  dataram_strb7_m1;
  wire                                  [255: 0]  raw_data_wdata_m0;
  reg                  [(`CA53_DCU_DATA_W-1): 0]  dataram_wdata_m1;
  wire                                            dataram_wr_m1;
  reg                                             ccb_data_req_m2;
  reg                                             ccb_data_req_m3;
  wire                                            ecc_data_err_m3;
  wire                                            ecc_dirty_err_m2;
  wire                                            ecc_in_progress;
  wire                                            load_has_priority_m1;
  wire                                   [13: 5]  dirty_addr_m0;
  wire                                            dirty_m0_en;
  wire                                            dirty_req_outstanding_m1;
  wire                                    [2: 0]  dirty_req_type_m0;
  wire                                    [3: 0]  dirty_way_m0;
  wire                                    [1: 0]  dirty_wdata_m0;
  wire                                            dirty_wr_m0;
  wire                                    [8: 0]  dirtyram_addr_m1;
  wire                                            dirtyram_en_m1;
  wire               [(`CA53_DDIRTY_RAM_W-1): 0]  dirtyram_strb_m1;
  wire               [(`CA53_DDIRTY_RAM_W-1): 0]  snoop_dirty_strb_m1;
  wire               [(`CA53_DDIRTY_RAM_W-1): 0]  prearb_dirty_strb_m1;
  wire               [(`CA53_DDIRTY_RAM_W-1): 0]  dirtyram_wdata_m1;
  wire                                            dirtyram_wr_m1;
  wire                                   [63: 0]  dword_data_m2;
  wire                                    [3: 0]  qword_data_seq_way_m1;
  wire                                    [3: 0]  data_seq_way_m1;
  wire                                    [1: 0]  data_seq_way_bin_m1;
  wire                                            seq_load_data_granted_m1;
  reg                                     [3: 0]  dword_data_seq_banksel_m2;
  reg                                     [1: 0]  data_seq_way_bin_m2;
  wire                                    [3: 0]  qword_data_banksel_m1;
  reg                                     [3: 0]  qword_data_banksel_m2;
  wire                                    [6: 0]  ecc_check_bits0_m0;
  wire                                    [6: 0]  ecc_check_bits1_m0;
  wire                                    [6: 0]  ecc_check_bits2_m0;
  wire                                    [6: 0]  ecc_check_bits3_m0;
  wire                                    [6: 0]  ecc_check_bits4_m0;
  wire                                    [6: 0]  ecc_check_bits5_m0;
  wire                                    [6: 0]  ecc_check_bits6_m0;
  wire                                    [6: 0]  ecc_check_bits7_m0;
  wire                                            ecc_err_correct_m3;
  reg                                             seq_exception_level;
  reg                                             force_dc_load_first_m1;
  wire                                            force_non_seq;
  wire                                    [7: 0]  load_data_en_m1;
  wire                                            load_data_granted_m1;
  wire                                            load_hit_m2;
  wire                                            load_raw_hit_m2;
  wire                                            load_lookup_m2;
  wire                                            load_needs_tag_early_m1;
  wire                                            dword_data_nseq_sel_m1;
  wire                                            dword_data_m2_en;
  wire                                            qword_data_m2_en;
  wire                                            load_or_tlb_tag_req_m2;
  reg                                             dword_data_nseq_sel_m2;
  wire                                            load_tag_granted_m1;
  wire                                   [29: 0]  load_tag_m1;
  wire                                            load_tag_priority_m1;
  wire                                            load_tag_req_early_m1;
  wire                                            load_tag_req_m1;
  wire                                            valid_load_lookup_m1;
  wire                                            lookup_can_start_lf_m2;
  wire                                   [29: 0]  lookup_tag_m1;
  reg                                    [29: 0]  lookup_tag_m2;
  wire                                            tag_sel_m2_en;
  wire                                     [3:0]  next_tag_sel_m2;
  reg                                      [3:0]  tag_sel_m2;
  wire                                    [3: 0]  lowest_way_invalid_m2;
  reg                                     [2: 0]  lowest_bank_data_fatal_m3;
  reg                                     [2: 0]  lowest_bank_data_err_m3;
  wire                                    [7: 0]  mbist_bank_m0;
  reg                [(`CA53_DDIRTY_RAM_W-1): 0]  mbist_be_m1;
  wire                                    [7: 0]  mbist_data_en_m0;
  wire                                            mbist_data_req_m0;
  wire                                            mbist_dc_data_sel_m0;
  wire                                            mbist_dc_dirty_sel_m0;
  wire                                            mbist_dc_tag_sel_m0;
  wire                                            mbist_dirty_req_m0;
  wire                                    [3: 0]  mbist_tag_en_m0;
  wire                                            mbist_tag_req_m0;
  wire                                    [3: 0]  mbist_way_m0;
  wire                 [(`CA53_DCU_DATA_W-1): 0]  data_wdata_m0;
  wire                                            next_force_dc_load_first_m1;
  wire                   [SEQ_VICTIM_CNT_W-1: 0]  next_seq_victim_select_count;
  wire                                    [1: 0]  next_victim_way_count;
  wire                                    [3: 0]  dword_data_nseq_banksel_m2;
  wire                                    [7: 0]  nonseq_load_data_en_m1;
  wire                                    [5: 3]  nseq_data_addr_m0;
  wire                                            pf_granted_m0;
  wire                                            pf_priority_m0;
  wire                                            pf_tag_req_m1;
  reg                                     [2: 0]  prearb_data_addr01_m1;
  reg                                     [1: 0]  tag_lookup_type_m2;
  wire                                    [1: 0]  next_tag_lookup_type_m2;
  reg                                     [2: 0]  prearb_data_addr23_m1;
  reg                                     [2: 0]  prearb_data_addr45_m1;
  reg                                     [2: 0]  prearb_data_addr67_m1;
  reg                                    [13: 6]  prearb_data_addr_m1;
  reg                                     [7: 0]  prearb_data_en_m1;
  wire                                            prearb_data_granted_m1;
  wire                                            prearb_data_needs_dirty_m1;
  wire                                            prearb_data_needs_tag_m1;
  wire                                            prearb_data_priority_m1;
  wire                                            prearb_data_req_m1;
  reg                                     [2: 0]  prearb_data_req_type_m1;
  wire                                            prearb_data_req_type_m1_en;
  reg                                    [15: 0]  prearb_data_strb_m1;
  reg                          [ROTATION_W-1: 0]  prearb_data_rotation_m1;
  reg                                     [3: 0]  prearb_data_way_m1;
  reg                                    [13: 5]  prearb_dirty_addr_m1;
  wire                                            prearb_dirty_granted_m1;
  wire                                            prearb_dirty_priority_m1;
  wire                                            prearb_dirty_req_m1;
  reg                                     [2: 0]  prearb_dirty_req_type_m1;
  wire                                            prearb_dirty_req_type_m1_en;
  reg                                     [3: 0]  prearb_dirty_way_m1;
  reg                                     [1: 0]  stb_dirty_wdata_m1;
  wire                                    [3: 0]  stb_dirty_wdata_full_m1;
  wire                                            ecc_dirty_bit_err_even_m2;
  wire                                            ecc_dirty_bit_err_odd_m2;
  wire                                            ecc_dirty_err_even_m2;
  wire                                            ecc_dirty_err_odd_m2;
  wire                                    [3: 0]  prearb_dirty_wdata_m1;
  reg                                             prearb_dirty_wr_m1;
  reg                                    [39:14]  prearb_tag_addr_m1;
  wire                                            prearb_tag_granted_m1;
  wire                                   [31: 0]  prearb_tag_m1;
  reg                                     [1: 0]  prearb_tag_moesi_m1;
  wire                                            prearb_tag_needs_dirty_m1;
  reg                                             prearb_tag_ns_m1;
  wire                                            prearb_tag_priority_m1;
  wire                                            prearb_tag_req_m1;
  reg                                     [2: 0]  prearb_tag_req_type_m1;
  wire                                            prearb_tag_req_type_m1_en;
  reg                                    [13: 6]  prearb_tag_set_m1;
  reg                                     [3: 0]  prearb_tag_way_m1;
  reg                                             prearb_tag_wr_m1;
  reg                                     [2: 0]  seq_data_addr01_m0;
  reg                                     [2: 0]  seq_data_addr23_m0;
  reg                                     [2: 0]  seq_data_addr45_m0;
  reg                                     [2: 0]  seq_data_addr67_m0;
  wire                                            seq_miss_m1;
  wire                  [SEQ_STATE_ENTRIES-1: 0]  seq_suppress_data_entry_m1;
  wire                                            seq_suppress_data_m1;
  wire                                    [3: 0]  seq_load_way_m1;
  wire                  [SEQ_STATE_ENTRIES-1: 0]  seq_suppress_tag_entry_m1;
  wire                                            seq_suppress_tag_m1;
  wire                  [SEQ_STATE_ENTRIES-1: 0]  seq_victim_select;
  reg                    [SEQ_VICTIM_CNT_W-1: 0]  seq_victim_select_count;
  wire                                    [3: 0]  seq_way_entry_m1         [SEQ_STATE_ENTRIES-1: 0];
  reg                                     [3: 0]  seq_way_m1;
  wire                                    [3: 0]  single_data_bank_pair_m0;
  wire                                   [31: 0]  snoop_tag_m1;
  wire                  [SEQ_STATE_ENTRIES-1: 0]  start_seq_entry_m1;
  wire                                            start_seq_m1;
  wire                                            data_wr_m0;
  reg                                             prearb_data_wr_m1;
  wire                                            stb_data_priority_m0;
  wire                                            stb_data_req_m1;
  wire                                   [15: 0]  stb_data_strb_m0;
  wire                                            stb_dirty_priority_m0;
  wire                                            stb_dirty_req_m1;
  wire                                    [3: 0]  stb_lower_data_bank_pair_m0;
  wire                                            stb_tag_granted_m0;
  wire                                            stb_tag_priority_m0;
  wire                                            stb_tag_req_m1;
  wire                                    [3: 0]  stb_upper_data_bank_pair_m0;
  wire                                            stb_data_granted_m0;
  wire                                            stb_dirty_granted_m0;
  wire                                            stb_tag_write_m1;
  wire                                   [39:14]  tag_addr_m0;
  wire                                            tag_addr_m0_en;
  wire                                            tag_m0_en;
  wire                                    [1: 0]  tag_moesi_m0;
  wire                                            tag_ns_m0;
  wire                                            tag_req_outstanding_m1;
  wire                                    [2: 0]  tag_req_type_m0;
  wire                                   [13: 6]  tag_set_m0;
  wire                                    [3: 0]  tag_way_comp_m2;
  wire                                    [3: 0]  tag_way_m0;
  wire                                    [3: 0]  tag_way_valid_m2;
  wire                                            tag_wr_m0;
  wire                                    [1: 0]  tagram0_moesi_m2;
  wire                                    [1: 0]  tagram1_moesi_m2;
  wire                                    [1: 0]  tagram2_moesi_m2;
  wire                                    [1: 0]  tagram3_moesi_m2;
  wire                                    [7: 0]  tagram_addr_m1;
  wire                                    [3: 0]  tagram_en_m1;
  wire                                            tagram_wr_m1;
  wire                                            tlb_data_priority_m0;
  wire                                            tlb_granted_m0;
  wire                                            tlb_priority_m0;
  wire                                            tlb_req_m1;
  wire                                            tlb_tag_priority_m0;
  wire                                            tlb_req_m2;
  wire                                            victim_count_en_m2;
  reg                                     [1: 0]  victim_way_count;
  wire                                    [3: 0]  victim_way_m2;
  wire                                   [48: 6]  dpu_agu_a_xor_b_iss;
  wire                                   [47: 6]  dpu_agu_a_and_b_iss;
  wire                                   [48: 6]  csa_sum;
  wire                                   [47: 6]  csa_carry;
  wire                                   [48: 6]  csa_combine;
  wire                                    [2: 0]  back_to_back_hit_iss;
  wire                                            entering_dcu;
  wire                                            ccb_data_priority_m1;
  wire                                            ccb_data_granted_m1;
  wire                                            load_tag_granted_early_m1;
  reg                        [TIMEOUT_CNT_W-1:0]  prearb_dirty_count_m1;
  reg                        [TIMEOUT_CNT_W-1:0]  prearb_data_count_m1;
  reg                        [TIMEOUT_CNT_W-1:0]  prearb_tag_count_m1;
  wire                       [TIMEOUT_CNT_W-1:0]  next_prearb_dirty_count_m1;
  wire                       [TIMEOUT_CNT_W-1:0]  next_prearb_data_count_m1;
  wire                       [TIMEOUT_CNT_W-1:0]  next_prearb_tag_count_m1;
  wire                                            prearb_count_en_m1;
  wire                                    [3: 0]  ecc_tag_err_way_m2;
  wire                                            ecc_en;
  wire                                            ecc_tag_err_m2;
  reg                                             ecc_tag_err_m3;
  wire                                            tag_lookup_m1;
  reg                                             tag_lookup_m2;
  reg                                    [13: 6]  tag_index_m2;
  reg                                    [13: 3]  data_index_m2;
  wire                                   [13: 3]  next_data_index_m3;
  reg                                    [13: 3]  data_index_m3;
  reg                                     [1: 0]  data_index_adj_m3;
  wire                                    [1: 0]  ecc_data_bank_offset_m3;
  wire                                    [6: 0]  ecc_data_syndrome_m2 [7:0];
  reg                                     [6: 0]  raw_ecc_data_syndrome_m3 [7:0];
  wire                                    [6: 0]  ecc_data_syndrome_m3 [7:0];
  wire                                    [7: 0]  raw_ecc_data_fatal_m3;
  wire                                    [7: 0]  ecc_data_err_bank_m3;
  wire                                    [2: 0]  ecc_data_bank_m3;
  wire                                            ecc_data_is_fatal_m3;
  wire                                    [7: 0]  ecc_data_syndrome_m3_en;
  reg                                             load_req_m2;
  wire                                    [1: 0]  tag_way_comp_bin_m2;
  wire                                    [1: 0]  data_way_bin_m2;
  reg                                     [1: 0]  data_way_m3;
  wire                                    [3: 0]  lowest_way_tag_err_m2;
  wire                                    [3: 0]  ecc_tag_dirty_way_m2;
  wire                                    [1: 0]  ecc_tag_dirty_way_bin_m2;
  wire                                   [13: 6]  ecc_tag_dirty_index_m2;
  reg                                     [7: 0]  ecc_tag_dirty_index_m3;
  wire                                    [7: 0]  ecc_correction_index_m3;
  wire                                    [1: 0]  ecc_correction_way_m3;
  wire                                            ecc_tag_dirty_m3_en;
  reg                                     [1: 0]  ecc_tag_dirty_way_m3;
  reg                                     [7: 0]  ecc_data_bank_read_m2;
  reg                                     [7: 0]  ecc_data_bank_read_m3;
  wire                                    [7: 0]  next_ecc_data_bank_read_m3;
  wire                                    [7: 0]  next_ecc_data_bank_read_m2;
  wire                                            valid_ecc_data_read_m1;
  reg                                             valid_ecc_data_read_m2;
  reg                                             valid_ecc_data_read_m3;

  genvar seq_entry;
  genvar data_m0_lane;
  genvar data_bank;


  //---------------------------------------------------------------------------
  // Function Declarations
  //---------------------------------------------------------------------------
  // Rotate a 4-bit value left by a specified number of places - this is
  // useful both for calculating which Data RAM bank to enable, and which
  // to select data from.
  function [3:0] rotate_left_4bit (
    input [3:0] value,      // 4-bit value to be rotated
    input [1:0] rotation    // Binary value of rotation
  );

    case (rotation)
      2'b00: rotate_left_4bit = value;
      2'b01: rotate_left_4bit = {value[2:0], value[3]};
      2'b10: rotate_left_4bit = {value[1:0], value[3:2]};
      2'b11: rotate_left_4bit = {value[0],   value[3:1]};
      default: rotate_left_4bit = 4'bxxxx;
    endcase

  endfunction


  //---------------------------------------------------------------------------
  // Arbitrate M0 requests to the cache
  //---------------------------------------------------------------------------
  // Access to resources is arbitrated on a per resource and per requestor
  // basis - if two requests require access to different resources then they
  // may be able to proceed in parallel, but if a single request requires
  // access to multiple resources then it will be granted access to all its
  // requested resources simultaneously.
  // Some requestors can make different types of request, and therefore need
  // access to different resources depending on the request type:
  //
  // MBIST:         MBIST only accesses one resource at a time, but as other
  //                requests are blocked during MBIST, this has no effect
  //                on arbitration.
  // Allocations:   Allocations only accesses one or two resources at a time.
  //                The allocation request must be granted access to all the
  //                resources it asks for simultaneously.
  // TLB Lookups:   The TLB always requests access to the Tag and Data RAMs
  //                when doing a lookup, and must be granted access to both
  //                simultaneously.
  // STB Requests:  The STB makes four types of request - Tag lookups, Tag
  //                writes, and Data reads and writes. When writing Data,
  //                the STB always also writes the Dirty RAM. As there are multiple
  //                independent slots in the STB, it is possible for one slot
  //                to be requesting Tag access (for a lookup or write) at
  //                the same time another slot is requesting Data and Dirty
  //                access. In this case the Tag request is not dependent on
  //                the other requests and so can be granted independently of
  //                any Data and Dirty request, but the Data and Dirty
  //                requests must be granted simultaneously.
  // Prefetcher:    The prefetcher only ever requests Tag lookups, so it
  //                never has any interdependency.
  // CP15 Requests: These access either the tag and dirty RAM together, or the
  //                data RAM on its own.
  //
  // To enable the interdependencies between resources for each request to be
  // calculated, the M0 arbitration is split into a priority signal for each
  // request to each resource. Priority for each requestor is calculated
  // as a cascade, where each request determines that it has priority for
  // a resource when the next highest priority request has priority for that
  // resource but isn't being granted arbitration (either because it isn't
  // making a request or because of an interdependency). The separate
  // priority signals for each resource for a particular request can then be
  // combined to form a single priority signal for the request which takes
  // the interdependency between resources into account but does not factor
  // into the priority cascade. This can then be used with the request signal
  // to determine whether arbitration is granted for a particular request.


  //--------------------------
  // Arbitrate MBIST Requests
  //--------------------------

  // MBIST requests are provided by the SCU and registered in MBIST pipeline stage MB3,
  // which corresponds to M0 in the cache arbiter pipeline. Requests go
  // through the cache arbiter pipeline, and the M2 result is driven to the BIU in MB5.
  //
  // Cache Arbiter Pipeline | M0  | M1  | M2  |
  //         MBIST Pipeline | MB3 | MB4 | MB5 | MB6 |
  //

  // Decode the MBIST signals
  assign mbist_dc_data_sel_m0  = mbist_sel_mb3_i & (mbist_array_mb3_i[6:3] == 4'b0000);
  assign mbist_dc_tag_sel_m0   = mbist_sel_mb3_i & (mbist_array_mb3_i[6:2] == 5'b00010);
  assign mbist_dc_dirty_sel_m0 = mbist_sel_mb3_i & (mbist_array_mb3_i[6:2] == 5'b00011);

  assign mbist_way_m0   = 4'b0001     << mbist_array_mb3_i[1:0];
  assign mbist_bank_m0  = 8'b00000001 << mbist_array_mb3_i[2:0];

  // When the core is selected, the tag or data RAM enabled normally
  // corresponds to the way/bank specified on the array. An MBIST ALL mode is
  // also supported, during which all RAMs are enabled for all MBIST
  // accesses, regardless of the core and RAM selected by the array.
  assign mbist_tag_en_m0  = mbist_way_m0 |        // Select indicated way when core selected
                            {4{mbist_cfg_mb3_i}}; // Select all ways in MBIST ALL mode

  assign mbist_data_en_m0 = mbist_bank_m0 |
                            {8{mbist_cfg_mb3_i}};

  // MBIST will be granted arbitration in M0 whenever it makes a request, so
  // it is only necessary to decode whether there is an MBIST request for
  // a particular block to determine if it will be granted arbitration for
  // that block.
  // Requests are put into M1 for all the RAMs in MBIST ALL mode, to ensure
  // that they are enabled.
  assign mbist_data_req_m0  = mbist_en_i & ((mbist_dc_data_sel_m0  | mbist_cfg_mb3_i) & (mbist_write_en_mb3_i | mbist_read_en_mb3_i));
  assign mbist_tag_req_m0   = mbist_en_i & ((mbist_dc_tag_sel_m0   | mbist_cfg_mb3_i) & (mbist_write_en_mb3_i | mbist_read_en_mb3_i));
  assign mbist_dirty_req_m0 = mbist_en_i & ((mbist_dc_dirty_sel_m0 | mbist_cfg_mb3_i) & (mbist_write_en_mb3_i | mbist_read_en_mb3_i));


  //-------------------------------
  // Arbitrate Allocation Requests
  //-------------------------------
  // No M0 requests for a particular resource can be accepted when there is
  // already an M0 request outstanding in M1 which is not being granted
  // arbitration.
  assign tag_req_outstanding_m1   = (prearb_tag_req_type_m1   != REQ_NONE) & // There is a previous M0 request in M1
                                    ~prearb_tag_granted_m1;                  // It is not being granted arbitration

  assign data_req_outstanding_m1  = (prearb_data_req_type_m1  != REQ_NONE) & // There is a previous M0 request in M1
                                    ~prearb_data_granted_m1;                 // It is not being granted arbitration

  assign dirty_req_outstanding_m1 = (prearb_dirty_req_type_m1 != REQ_NONE) & // There is a previous M0 request in M1
                                    ~prearb_dirty_granted_m1;                // It is not being granted arbitration

  // No allocation request can move to M1 if there is already an allocation
  // request to any resource in M1. This is because allocation requests share
  // priority and acknowledge signals. There must be no confusion over which
  // linefill buffer has a dirty RAM write in M1, as the BIU needs to know
  // which linefill buffer to send dirty information from.
  assign alloc_req_outstanding_m1 = ((prearb_tag_req_type_m1   == REQ_ALLOC) & ~prearb_tag_granted_m1)  |
                                    ((prearb_data_req_type_m1  == REQ_ALLOC) & ~prearb_data_granted_m1) |
                                    ((prearb_dirty_req_type_m1 == REQ_ALLOC) & ~prearb_dirty_granted_m1);

  // Determine whether allocations have priority for each separate resource.
  assign alloc_tag_priority_m0    = ~mbist_en_i &
                                    ~dc_inv_all_in_progress_i &
                                    ~tag_req_outstanding_m1 &
                                    ~alloc_req_outstanding_m1;

  assign alloc_data_priority_m0   = ~mbist_en_i &
                                    ~dc_inv_all_in_progress_i &
                                    ~data_req_outstanding_m1 &
                                    ~alloc_req_outstanding_m1;

  assign alloc_dirty_priority_m0  = ~mbist_en_i &
                                    ~dc_inv_all_in_progress_i &
                                    ~dirty_req_outstanding_m1 &
                                    ~alloc_req_outstanding_m1;

  // Determine whether to grant access to an allocation request based on what
  // the request is asking for. This is done on a per-resource basis, as
  // other requests may be able to be granted in parallel if the allocation
  // does not need access to all resources.
  assign alloc_data_granted_m0  = biu_alloc_data_req_m0_i & alloc_data_priority_m0  &     // Allocations always need to access data
                                  (alloc_tag_priority_m0   | ~biu_alloc_tag_req_m0_i) &   // Either have tag priority or don't need it
                                  (alloc_dirty_priority_m0 | ~biu_alloc_dirty_req_m0_i);  // Either have dirty priority or don't need it

  assign alloc_tag_granted_m0   = biu_alloc_tag_req_m0_i & alloc_tag_priority_m0 &
                                  (alloc_data_priority_m0  | ~biu_alloc_data_req_m0_i) &  // Either have data priority or don't need it
                                  (alloc_dirty_priority_m0 | ~biu_alloc_dirty_req_m0_i);  // Either have dirty priority or don't need it

  assign alloc_dirty_granted_m0 = biu_alloc_dirty_req_m0_i & alloc_dirty_priority_m0 &
                                  (alloc_data_priority_m0 | ~biu_alloc_data_req_m0_i) &   // Either have data priority or don't need it
                                  (alloc_tag_priority_m0  | ~biu_alloc_tag_req_m0_i);     // Either have dirty priority or don't need it


  //------------------------
  // Arbitrate TLB Requests
  //------------------------
  // Determine the priority for each resource
  assign tlb_tag_priority_m0  = alloc_tag_priority_m0   & ~biu_alloc_tag_req_m0_i;
  assign tlb_data_priority_m0 = alloc_data_priority_m0  & ~biu_alloc_data_req_m0_i;

  // The TLB always needs to access both the tag and data RAMs.
  assign tlb_priority_m0 = tlb_tag_priority_m0 & tlb_data_priority_m0; // TLB has priority when it has both tag and data priority

  assign tlb_granted_m0 = (|tlb_cache_walk_lookup_req_m0_i) & tlb_priority_m0;


  //------------------------
  // Arbitrate STB Requests
  //------------------------
  // Determine the priority for each resource
  assign stb_tag_priority_m0    = tlb_tag_priority_m0  & ~tlb_granted_m0;
  assign stb_data_priority_m0   = tlb_data_priority_m0 & ~tlb_granted_m0;
  assign stb_dirty_priority_m0  = alloc_dirty_priority_m0 & ~biu_alloc_dirty_req_m0_i;  // TLB doesn't access dirty

  // The STB can make four types of request:
  // - tag reads and tag writes (which both just access the tag RAM)
  // - data writes (which access the dirty and data RAMs)
  // - data reads (only possible when ECC present - only accesses data RAM)

  // Tag requests can be considered as one request, as the arbitration does
  // not look at whether the request is for a read or write.
  assign stb_tag_granted_m0 = stb_cache_tag_req_m0_i &
                              stb_tag_priority_m0;

  // Data writes needs priority for data and dirty. They also need to stall
  // if there is an STB tag write stalled in M1 to ensure that a data write
  // for a slot cannot overtake a previous tag write for the same slot, as
  // snoop requests are only hazarded whilst the tag write is in M0 or the
  // data request is in M0 or M1.
  // Data reads only need priority for the data RAM.
  assign stb_tag_write_m1 = (prearb_tag_req_type_m1 == REQ_STB) & prearb_tag_wr_m1 & ~prearb_tag_granted_m1;

generate if (CPU_CACHE_PROTECTION) begin : g_stb_granted_m0_ecc
  // When ECC is present, can access data without dirty, so arbitrate
  // separately
  assign stb_data_granted_m0 = stb_cache_data_req_m0_i & stb_data_priority_m0 &
                               (~stb_cache_data_wr_m0_i | (stb_dirty_priority_m0 & ~stb_tag_write_m1));

  // Dirty writes need priority for data and dirty.
  assign stb_dirty_granted_m0 = stb_cache_data_req_m0_i & stb_cache_data_wr_m0_i &
                                stb_data_priority_m0 & stb_dirty_priority_m0 &
                                ~stb_tag_write_m1;

end else begin : g_stb_granted_m0_no_ecc
  // When ECC is not present, always access data and dirty together
  assign stb_data_granted_m0 = stb_cache_data_req_m0_i & stb_data_priority_m0 &
                               stb_dirty_priority_m0 & ~stb_tag_write_m1;

  assign stb_dirty_granted_m0 = stb_data_granted_m0;

end endgenerate

  //-------------------------------
  // Arbitrate Prefetcher Requests
  //-------------------------------
  // The prefetcher just does tag lookups, so it does not have any
  // interdependencies.
  assign pf_priority_m0 = stb_tag_priority_m0 & ~stb_tag_granted_m0;

  assign pf_granted_m0 = biu_pf_tag_req_m0_i & pf_priority_m0;


  //-------------------------
  // Arbitrate CP15 Requests
  //-------------------------
  // Only cp15 cache debug operations will be dealt locally by the DCU and they
  // get the lower priority. CP15 debug ops need priority for tag and dirty or data.
  assign cp15_tag_priority_m0   = pf_priority_m0        & ~pf_granted_m0 &        // Tag debug also reads dirty
                                  stb_dirty_priority_m0 & ~stb_dirty_granted_m0;
  assign cp15_data_priority_m0  = stb_data_priority_m0  & ~stb_data_granted_m0;

  // For CP15 operations the tag and dirty are read at the same time so the
  // priority is granted only if they can be both accessed.
  assign cp15_tag_granted_m0  = (cp15_tag_priority_m0  | dc_inv_all_in_progress_i) & cp15_tag_req_m0_i;
  assign cp15_data_granted_m0 = (cp15_data_priority_m0 | dc_inv_all_in_progress_i) & cp15_data_req_m0_i;


  //---------------------------------------------------------------------------
  // Register M0 Request Types
  //---------------------------------------------------------------------------
  // Set type of request granted M0 arbitration for each resource.

  //--------------
  // Tag Requests
  //--------------
  assign tag_req_type_m0    = ({3{mbist_tag_req_m0}}      & REQ_MBIST) | // No granted signal for MBIST as it has highest priority
                              ({3{alloc_tag_granted_m0}}  & REQ_ALLOC) |
                              ({3{tlb_granted_m0}}        & REQ_TLB)   |
                              ({3{stb_tag_granted_m0}}    & REQ_STB)   |
                              ({3{pf_granted_m0}}         & REQ_PF)    |
                              ({3{cp15_tag_granted_m0}}   & REQ_CP15);

  // Pipeline a new request to M1 whenever a previous request is not
  // stalled in M1, or on every cycle during MBIST.
  assign prearb_tag_req_type_m1_en = ~tag_req_outstanding_m1 | mbist_en_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      prearb_tag_req_type_m1 <= REQ_NONE;
    else if (prearb_tag_req_type_m1_en)
      prearb_tag_req_type_m1 <= tag_req_type_m0;


  //----------------
  // Dirty Requests
  //----------------
  assign dirty_req_type_m0  = ({3{mbist_dirty_req_m0}}                              & REQ_MBIST) |
                              ({3{alloc_dirty_granted_m0}}                          & REQ_ALLOC) |
                              ({3{stb_dirty_granted_m0}}                            & REQ_STB)   |
                              ({3{cp15_tag_granted_m0 & ~dc_inv_all_in_progress_i}} & REQ_CP15);

  // Pipeline a new request to M1 whenever a previous request is not
  // stalled in M1.
  assign prearb_dirty_req_type_m1_en = ~dirty_req_outstanding_m1 | mbist_en_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      prearb_dirty_req_type_m1 <= REQ_NONE;
    else if (prearb_dirty_req_type_m1_en)
      prearb_dirty_req_type_m1 <= dirty_req_type_m0;


  //---------------
  // Data Requests
  //---------------
  assign data_req_type_m0   = ({3{mbist_data_req_m0}}     & REQ_MBIST) |
                              ({3{alloc_data_granted_m0}} & REQ_ALLOC) |
                              ({3{tlb_granted_m0}}        & REQ_TLB)   |
                              ({3{stb_data_granted_m0}}   & REQ_STB)   |
                              ({3{cp15_data_granted_m0}}  & REQ_CP15);

  // Pipeline a new request to M1 whenever a previous request is not
  // stalled in M1.
  assign prearb_data_req_type_m1_en = ~data_req_outstanding_m1 | mbist_en_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      prearb_data_req_type_m1 <= REQ_NONE;
    else if (prearb_data_req_type_m1_en)
      prearb_data_req_type_m1 <= data_req_type_m0;


  //---------------------------------------------------------------------------
  // Register M0 Request Data
  //---------------------------------------------------------------------------

  //--------------
  // Tag Requests
  //--------------
  // When accessing the tag, all the necessary control signals are registered in
  // M0 and pipelined to M1.

  // The tag RAM has four banks, which correspond to the four ways. Therefore
  // just register the way(s) being accessed to be able to generate the bank
  // enables in M1.
  assign tag_way_m0     = ({4{mbist_en_i}}            & mbist_tag_en_m0)        |
                          ({4{alloc_tag_granted_m0}}  & biu_alloc_way_m0_i)     |
                          ({4{tlb_granted_m0}}        & 4'b1111)                | // TLB looks up in all ways
                          ({4{stb_tag_granted_m0}}    & stb_cache_tag_way_m0_i) |
                          ({4{pf_granted_m0}}         & 4'b1111)                | // PF looks up in all ways
                          ({4{cp15_tag_granted_m0}}   & cp15_way_m0_i);

  // Each entry in the tag contains the address used for tag hit comparisons,
  // the nS bit for the entry, which is also used in lookup comparisons, and
  // 2 bits used to encode the partial state of the entry (the full state is
  // obtained by combining with the locally modified bit from the Dirty RAM).

  // Bits[5:0] of the physical address form the offset within the 64Byte
  // cache line and so are not required when accessing the tag RAM.
  // Bits[39:N] of the physical address are stored in the tag RAM and are
  // used in hit comparisons, and bits[N-1:6] correspond to the set address
  // of the cache line and are used to address the tag RAM.
  //
  // The value of N depends on the cache size, but will be between 11 and 14.
  // The set address is registered for all tag addresses, so uses the largest
  // set size of [13:6] to cover all cases.

  assign tag_addr_m0    = ({26{alloc_tag_granted_m0}} & biu_alloc_addr_m0_i[39:14])     |
                          ({26{pf_granted_m0}}        & biu_pf_tag_addr_m0_i[39:14])    |
                          ({26{tlb_granted_m0}}       & tlb_cache_walk_addr_i[39:14])   |
                          ({26{stb_tag_granted_m0}}   & stb_cache_tag_addr_m0_i[39:14]);

  assign tag_set_m0     = ({8{mbist_en_i}}            & mbist_addr_mb3_i[7:0])        |
                          ({8{alloc_tag_granted_m0}}  & biu_alloc_addr_m0_i[13:6])     |
                          ({8{pf_granted_m0}}         & biu_pf_tag_addr_m0_i[13:6])    |
                          ({8{tlb_granted_m0}}        & tlb_cache_walk_addr_i[13:6])   |
                          ({8{stb_tag_granted_m0}}    & stb_cache_tag_addr_m0_i[13:6]) |
                          ({8{cp15_tag_granted_m0}}   & cp15_addr_m0_i[13:6]);

  assign tag_ns_m0      = (alloc_tag_granted_m0 & biu_alloc_ns_dsc_m0_i)      |
                          (pf_granted_m0        & biu_pf_tag_ns_dsc_m0_i)     |
                          (tlb_granted_m0       & tlb_cache_walk_ns_dsc_i)    |
                          (stb_tag_granted_m0   & stb_cache_tag_ns_dsc_m0_i);

  // For lookups, the cache arbiter will either pass the MOESI state to the
  // requestor, or decode it internally. Therefore the MOESI state only needs
  // generating in M0 when the tag is being written.
  // - The STB only writes the tag to set the MOESI state to unique, after
  // completing a CleanUnique. The Unique Not Migratory state is used, because
  // if a CleanUnique was required the line must have been shared before the
  // write, and so the line is not migratory.
  assign tag_moesi_m0   = ({2{alloc_tag_granted_m0}}  & biu_alloc_tag_moesi_m0_i)  |
                          ({2{stb_tag_granted_m0}}    & `CA53_MOESI_UNIQUE_NOT_MIG);

  assign tag_wr_m0      = (mbist_en_i           & mbist_write_en_mb3_i)     |
                          (alloc_tag_granted_m0 & 1'b1)                     | // Allocations always write tag
                          (stb_tag_granted_m0   & stb_cache_tag_wr_m0_i) |
                          (cp15_tag_granted_m0  & cp15_wr_m0_i);

  // Register the data required by all types of request whenever a new
  // request is being accepted. Always enable during MBIST and CP15 dirty
  // accesses, as dirty RAM accesses reuse the set address.
  assign tag_m0_en = (tag_req_type_m0 != REQ_NONE) | mbist_en_i;

  // Only register tag address for requests which are doing an address
  // lookup/tag write. This is also used for enabling the MOESI registers, as
  // they are too small to warrant an individual clock gate, and the MOESI
  // data is only required on a subset of the address lookup/tag write
  // transactions.
  assign tag_addr_m0_en = alloc_tag_granted_m0  |
                          pf_granted_m0         |
                          tlb_granted_m0        |
                          stb_tag_granted_m0    |
                          cp15_tag_granted_m0;

  // The tag data signals do not need to be reset
  always @(posedge clk)
    if (tag_m0_en) begin
      prearb_tag_way_m1    <= tag_way_m0;
      prearb_tag_set_m1    <= tag_set_m0;
      prearb_tag_ns_m1     <= tag_ns_m0;
      prearb_tag_wr_m1     <= tag_wr_m0;
    end

  always @(posedge clk)
    if (tag_addr_m0_en) begin
      prearb_tag_addr_m1   <= tag_addr_m0;
      prearb_tag_moesi_m1  <= tag_moesi_m0;
    end


  //----------------
  // Dirty Requests
  //----------------
  // The dirty RAM stores the following:
  // - Outer allocation hint
  // - Line age hint
  // - Migratory bit
  // - The dirty bit
  //
  // Each address stores the data for two ways, one even and one odd. Two
  // sequential addresses therefore store the data for each way of a single
  // cache line.
  //
  // When ECC is present, each dirty RAM line stores two copies of the dirty
  // bit for each way, allowing single bit errors to be detected and corrected
  // (the other bits are all hints so errors in them can be tollerated without
  // affecting functionality).
  //
  // Of the M0 requests, only CP15, Allocation, and STB requests can write
  // the dirty RAM. Allocations provide the data to be written in M1, so only
  // the CP15 and STB dirty values need to be registered here. The write
  // enable for all three is generated in M0.

  // Determine the way being accessed
  // - MBIST specifies the bank to enable directly, so the way doesn't need
  // pipelining for MBIST data requests.
  assign dirty_way_m0 = ({4{cp15_tag_granted_m0}}    & cp15_way_m0_i)            | // Used for dirty strobes
                        ({4{alloc_dirty_granted_m0}} & biu_alloc_way_m0_i)       |
                        ({4{stb_dirty_granted_m0}}   & stb_cache_data_way_m0_i);
                        // NB - this is not used for TLB requests

  // Allocation write data is provided in M1, so only STB data needs pipelining
  // - Some bits not written/always written with same value so do not need
  // pipelining
  assign dirty_wdata_m0 = ({2{stb_dirty_granted_m0}}  & {stb_cache_data_attrs_m0_i[2],    // Write allocation hint
                                                                                          // STB doesn't update the age information
                                                         stb_cache_data_migratory_m0_i}); // STB writes to tell if the line is migratory
                                                                                          // STB only writes dirty to set dirty bit

  // Each line in the dirty RAM contains entries for an odd and even way (either
  // 0-1 or 2-3), so the bottom bit of the address depends on which way is being
  // accessed.
  assign dirty_addr_m0 = ({9{mbist_en_i}}             & mbist_addr_mb3_i[8:0])                                                                       |
                         ({9{cp15_tag_granted_m0}}    & {cp15_addr_m0_i[13:6],           (cp15_way_m0_i[3]           | cp15_way_m0_i[2])})           |
                         ({9{alloc_dirty_granted_m0}} & {biu_alloc_addr_m0_i[13:6],      (biu_alloc_way_m0_i[3]      | biu_alloc_way_m0_i[2])})      |
                         ({9{stb_dirty_granted_m0}}   & {stb_cache_data_addr_m0_i[13:6], (stb_cache_data_way_m0_i[3] | stb_cache_data_way_m0_i[2])});

  assign dirty_wr_m0   = (mbist_en_i             & mbist_write_en_mb3_i) |
                         (alloc_dirty_granted_m0 & 1'b1)                 |  // Allocations always access dirty to write it
                         (stb_dirty_granted_m0   & 1'b1);                   // STB always accesses dirty to write it

  // Register the new data whenever a new request is granted, or on every
  // cycle when MBIST is enabled (to ensure wr valid for data RAM accesses).
  assign dirty_m0_en = (dirty_req_type_m0 != REQ_NONE) | mbist_en_i;

  always @(posedge clk)
    if (dirty_m0_en) begin
      prearb_dirty_addr_m1  <= dirty_addr_m0;
      prearb_dirty_way_m1   <= dirty_way_m0;
      prearb_dirty_wr_m1    <= dirty_wr_m0;
      stb_dirty_wdata_m1    <= dirty_wdata_m0;
    end

  // The strobes to use for the dirty RAM during MBIST are pipelined separately,
  // as for normal requests the strobes are formed in M1 by replication.
  always @(posedge clk)
    if (mbist_en_i)
      mbist_be_m1   <= mbist_be_mb3_i;


  //---------------
  // Data Requests
  //---------------
  // The address and way to be enabled is complicated by the corkscrew
  // arrangement used in data RAM. This means the location of a particular
  // word in the RAM is a function of the lower bits of the address and the
  // way.

  // Determine the way being accessed
  // - MBIST specifies the bank to enable directly, so the way doesn't need
  // pipelining for MBIST data requests. The data way is used for MBIST dirty
  // requests however.
  assign data_way_m0 =  ({4{cp15_data_granted_m0}}  & cp15_way_m0_i)            |
                        ({4{alloc_data_granted_m0}} & biu_alloc_way_m0_i)       |
                        ({4{stb_data_granted_m0}}   & stb_cache_data_way_m0_i);
                        // NB - this is not used for TLB requests

  // Determine the address for each bank-pair
  // - The Data RAM address notionally corresponds to PA[13:3], however the
  // lower three bits may be adjusted to account for the corkscrew on
  // sequential accesses. The set address (PA[13:6]) is always the same for
  // all banks however, and used by all requestors.
  assign data_set_addr_m0 = ({8{mbist_en_i}}             & mbist_addr_mb3_i[10:3])          |  // Data address is used for data and dirty MBIST
                            ({8{cp15_data_granted_m0}}   & cp15_addr_m0_i[13:6])            |
                            ({8{alloc_data_granted_m0}}  & biu_alloc_addr_m0_i[13:6])       |
                            ({8{stb_data_granted_m0}}    & stb_cache_data_addr_m0_i[13:6])  |
                            ({8{tlb_granted_m0}}         & tlb_cache_walk_addr_i[13:6]);

  // - For requests which access a quadword or halfline, the bottom bits of
  // the bank address will be different for each bank-pair and depend on the
  // offset of the first quad-word being accessed, and the way. These
  // requests are allocations or STB writes.
  assign data_seq_req_qword_offset_m0 = ({2{alloc_data_granted_m0}} & biu_alloc_addr_m0_i[5:4]) |
                                        ({2{stb_data_granted_m0}}   & stb_cache_data_addr_m0_i[5:4]);

  // - The half-line accesses address 4 doublewords in a wrapping fashion.
  // The offset determines which doublewords are being accessed by the
  // request, and the way determines in which banks they are contained.
  // Quadword accesses from the STB address 2 doublewords in a wrapping
  // fashion and reuse this logic.
  always @*
    case ({data_seq_req_qword_offset_m0, data_way_m0})
      // Offset 0: Dwords 0-3
      6'b00_0001: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b011, 3'b010, 3'b001, 3'b000};
      6'b00_0010: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b010, 3'b001, 3'b000, 3'b011};
      6'b00_0100: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b001, 3'b000, 3'b011, 3'b010};
      6'b00_1000: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b000, 3'b011, 3'b010, 3'b001};
      // Offset 1: Dwords 2-5
      6'b01_0001: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b011, 3'b010, 3'b101, 3'b100};
      6'b01_0010: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b010, 3'b101, 3'b100, 3'b011};
      6'b01_0100: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b101, 3'b100, 3'b011, 3'b010};
      6'b01_1000: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b100, 3'b011, 3'b010, 3'b101};
      // Offset 2: Dwords 4-7
      6'b10_0001: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b111, 3'b110, 3'b101, 3'b100};
      6'b10_0010: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b110, 3'b101, 3'b100, 3'b111};
      6'b10_0100: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b101, 3'b100, 3'b111, 3'b110};
      6'b10_1000: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b100, 3'b111, 3'b110, 3'b101};
      // Offset 3: Dwords 6-7, 0-1
      6'b11_0001: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b111, 3'b110, 3'b001, 3'b000};
      6'b11_0010: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b110, 3'b001, 3'b000, 3'b111};
      6'b11_0100: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b001, 3'b000, 3'b111, 3'b110};
      6'b11_1000: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'b000, 3'b111, 3'b110, 3'b001};
      default: {seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0} = {3'bxxx, 3'bxxx, 3'bxxx, 3'bxxx};
    endcase

  // - For non-sequential requests, which access a single doubleword, the
  // address for each bank is the same, and is formed from bits[5:3] of the
  // PA (i.e. the doubleword offset within the set). The non-sequential
  // requests are: MBIST, TLB and CP15 debug ops.
  // - Note that MBIST addresses a doubleword, but only enables a single bank
  // of a bank-pair and so actually accesses a word.
  assign nseq_data_addr_m0 = ({3{mbist_en_i}}            & mbist_addr_mb3_i[2:0])        |
                             ({3{cp15_data_granted_m0}}  & cp15_addr_m0_i[5:3])          |
                             ({3{tlb_granted_m0}}        & tlb_cache_walk_addr_i[5:3]);

  // - Form the address for each bank-pair from the set address, and by
  // selecting from the sequential or non-sequential lower address bits
  // depending on the request type.
  assign data_addr01_m0 = ({3{alloc_data_granted_m0 | stb_data_granted_m0}} & seq_data_addr01_m0) | nseq_data_addr_m0;
  assign data_addr23_m0 = ({3{alloc_data_granted_m0 | stb_data_granted_m0}} & seq_data_addr23_m0) | nseq_data_addr_m0;
  assign data_addr45_m0 = ({3{alloc_data_granted_m0 | stb_data_granted_m0}} & seq_data_addr45_m0) | nseq_data_addr_m0;
  assign data_addr67_m0 = ({3{alloc_data_granted_m0 | stb_data_granted_m0}} & seq_data_addr67_m0) | nseq_data_addr_m0;

  // Determine the strobes to use when writing the data RAM. The RAM is only
  // written by the STB, allocations and MBIST. The strobes for a double
  // bank-pair are generated in M0 then replicated across two double bank-pairs
  // in M1. The STB strobes need to be rotated by one doubleword if the STB is
  // writing to a double data bank pair where the lower one is an odd numbered
  // pair.
  assign stb_data_strb_m0 = (stb_lower_data_bank_pair_m0[1] | stb_lower_data_bank_pair_m0[3]) ? {stb_cache_data_bls_m0_i[7:0], stb_cache_data_bls_m0_i[15:8]} :
                                                                                                stb_cache_data_bls_m0_i;

  assign data_strb_m0 = ({16{mbist_en_i & mbist_write_en_mb3_i}}  & {4{mbist_be_mb3_i[3:0]}}) | // MBIST provides strobes for bank being accessed
                        ({16{alloc_data_granted_m0}}              & 16'hFFFF)                 | // Allocations write all lanes
                        ({16{stb_data_granted_m0}}                & stb_data_strb_m0)         | // STB supplies its own strobes
                        ({16{cp15_data_granted_m0}}               & 16'hFFFF);                  // When writing CP15 writes all lanes

  // Calculate the write enable for the data RAM
  // - This depends on whether ECC is present or not, as the STB can only read
  // the data RAM when ECC is present
generate if (CPU_CACHE_PROTECTION) begin : g_data_wr_m0_ecc

  assign data_wr_m0 = (mbist_en_i             & mbist_write_en_mb3_i)   |
                      (alloc_data_granted_m0  & 1'b1)                   | // Allocations always write RAM
                      (stb_data_granted_m0    & stb_cache_data_wr_m0_i) |
                      (cp15_data_granted_m0   & cp15_wr_m0_i);

end else begin : g_data_wr_m0_no_ecc

  assign data_wr_m0 = (mbist_en_i             & mbist_write_en_mb3_i)   |
                      (alloc_data_granted_m0  & 1'b1)                   | // Allocations always write RAM
                      (stb_data_granted_m0    & 1'b1)                   |
                      (cp15_data_granted_m0   & cp15_wr_m0_i);

end endgenerate

  // Calculate the bank enable

  // - For requests which access a single doubleword, determine the
  // bank-pair containing the doubleword being addressed. Due to the
  // corkscrew arrangement, this will be a function of the way and the
  // doubleword offset within the set. The interaction of the two has the
  // effect that the one-hot value for the bank-pair containing the data (i.e.
  // {6-7, 4-5, 2-3, 0-1}), can be determined by rotating left the way based
  // on the address offset. The value wraps after half a cache line, so the
  // half-line offset can be ignored in the calculation.
  assign single_data_bank_pair_m0 = rotate_left_4bit(data_way_m0, nseq_data_addr_m0[4:3]);

  // - Allocation requests access two or four data bank pairs. The lower two
  // data bank pairs calculated from the address are always accessed.
  assign alloc_lower_two_data_bank_pairs_m0 = rotate_left_4bit(biu_alloc_way_m0_i, {biu_alloc_addr_m0_i[4], 1'b0}) |
                                              rotate_left_4bit(biu_alloc_way_m0_i, {biu_alloc_addr_m0_i[4], 1'b1});

  // - STB requests access two sequential data bank pairs.
  assign stb_lower_data_bank_pair_m0 = rotate_left_4bit(stb_cache_data_way_m0_i, {stb_cache_data_addr_m0_i[4], 1'b0});
  assign stb_upper_data_bank_pair_m0 = rotate_left_4bit(stb_cache_data_way_m0_i, {stb_cache_data_addr_m0_i[4], 1'b1});

  // - Calculate the bank enable based on the request type.
  always @*
    case (data_req_type_m0)
      REQ_STB:
        // STB accesses up to 128-bits, but if it isn't accessing any bytes in
        // one of the banks it is addressing, then suppress the enable to
        // save power.
        data_bank_en_m0 = {stb_upper_data_bank_pair_m0[3] & (|stb_cache_data_bls_m0_i[15:12]) |
                           stb_lower_data_bank_pair_m0[3] & (|stb_cache_data_bls_m0_i[ 7: 4]),
                           stb_upper_data_bank_pair_m0[3] & (|stb_cache_data_bls_m0_i[11: 8]) |
                           stb_lower_data_bank_pair_m0[3] & (|stb_cache_data_bls_m0_i[ 3: 0]),
                           stb_upper_data_bank_pair_m0[2] & (|stb_cache_data_bls_m0_i[15:12]) |
                           stb_lower_data_bank_pair_m0[2] & (|stb_cache_data_bls_m0_i[ 7: 4]),
                           stb_upper_data_bank_pair_m0[2] & (|stb_cache_data_bls_m0_i[11: 8]) |
                           stb_lower_data_bank_pair_m0[2] & (|stb_cache_data_bls_m0_i[ 3: 0]),
                           stb_upper_data_bank_pair_m0[1] & (|stb_cache_data_bls_m0_i[15:12]) |
                           stb_lower_data_bank_pair_m0[1] & (|stb_cache_data_bls_m0_i[ 7: 4]),
                           stb_upper_data_bank_pair_m0[1] & (|stb_cache_data_bls_m0_i[11: 8]) |
                           stb_lower_data_bank_pair_m0[1] & (|stb_cache_data_bls_m0_i[ 3: 0]),
                           stb_upper_data_bank_pair_m0[0] & (|stb_cache_data_bls_m0_i[15:12]) |
                           stb_lower_data_bank_pair_m0[0] & (|stb_cache_data_bls_m0_i[ 7: 4]),
                           stb_upper_data_bank_pair_m0[0] & (|stb_cache_data_bls_m0_i[11: 8]) |
                           stb_lower_data_bank_pair_m0[0] & (|stb_cache_data_bls_m0_i[ 3: 0])};
      REQ_ALLOC:
        // Allocations access two or four sequential bank-pairs.
        data_bank_en_m0 = {8{biu_alloc_halfline_m0_i}} |
                          {{2{alloc_lower_two_data_bank_pairs_m0[3]}},
                           {2{alloc_lower_two_data_bank_pairs_m0[2]}},
                           {2{alloc_lower_two_data_bank_pairs_m0[1]}},
                           {2{alloc_lower_two_data_bank_pairs_m0[0]}}};
      REQ_TLB:
        // TLB does a non-sequential lookup, so all bank-pairs need to be
        // enabled. If the TLB is just accessing a single word, then the
        // enable for the half of the bank pair containing the other word can
        // be suppressed.
        data_bank_en_m0 = {4{tlb_cache_walk_lookup_req_m0_i}};
      REQ_CP15:
        // CP15 data request enables one bank pair on a data debug op, and all
        // banks on an invalidate all on reset
        data_bank_en_m0 = cp15_wr_m0_i ? 8'hff
                                       : {{2{single_data_bank_pair_m0[3]}},
                                          {2{single_data_bank_pair_m0[2]}},
                                          {2{single_data_bank_pair_m0[1]}},
                                          {2{single_data_bank_pair_m0[0]}}};
      REQ_MBIST:
        data_bank_en_m0 = mbist_data_en_m0;
      default: data_bank_en_m0 = 8'bxxxx_xxxx;
    endcase

  // For allocations which write a full half-line into the cache, the data
  // needs to be rotated before writing into the RAMs, because of the
  // corkscrew. The rotation is applied in M1, but is calculated in M0 to
  // improve timing.
  // The rotation depends on the way being written, and whether the data is
  // aligned to a half-line boundary or a quarter-line boundary.
  // STB writes write 128-bits into the cache and are similarly rotated in
  // M1 based on the rotation calculated in M0.
  always @*
    case (data_req_type_m0)
      REQ_MBIST:
        data_rotation_m0 = ({ROTATION_W{|mbist_bank_m0[1:0]}} & ROTATION_0) | // [63:0] -> Banks0-1
                           ({ROTATION_W{|mbist_bank_m0[3:2]}} & ROTATION_1) | // [63:0] -> Banks2-3
                           ({ROTATION_W{|mbist_bank_m0[5:4]}} & ROTATION_2) | // [63:0] -> Banks4-5
                           ({ROTATION_W{|mbist_bank_m0[7:6]}} & ROTATION_3);  // [63:0] -> Banks6-7
      REQ_ALLOC:
        data_rotation_m0 = ({ROTATION_W{biu_alloc_way_m0_i[0]}} & (biu_alloc_addr_m0_i[4] ? ROTATION_2 : ROTATION_0)) |
                           ({ROTATION_W{biu_alloc_way_m0_i[1]}} & (biu_alloc_addr_m0_i[4] ? ROTATION_3 : ROTATION_1)) |
                           ({ROTATION_W{biu_alloc_way_m0_i[2]}} & (biu_alloc_addr_m0_i[4] ? ROTATION_0 : ROTATION_2)) |
                           ({ROTATION_W{biu_alloc_way_m0_i[3]}} & (biu_alloc_addr_m0_i[4] ? ROTATION_1 : ROTATION_3));
      REQ_STB:
        data_rotation_m0 = ({ROTATION_W{stb_cache_data_way_m0_i[1] | stb_cache_data_way_m0_i[3]}} & ROTATION_STB_1) |
                           ({ROTATION_W{stb_cache_data_way_m0_i[0] | stb_cache_data_way_m0_i[2]}} & ROTATION_STB_0);
      REQ_CP15:
        data_rotation_m0 = ROTATION_0;
      default:
        data_rotation_m0 = ROTATION_X;
    endcase

  // Select write data between MBIST, BIU allocation and STB data
  // - do not use full granted signals to improve timing, but do use or-of-and
  // style mux for data gating to improve power.
  // - masked to zero on invalidate all on reset.
  assign raw_data_wdata_m0 = ({256{(biu_alloc_data_req_m0_i | mbist_en_i) &
                                   ~dc_inv_all_in_progress_i}}                & biu_alloc_data_m0_i) |
                             ({256{stb_cache_data_req_m0_i &
                                   ~(biu_alloc_data_req_m0_i | mbist_en_i |
                                     dc_inv_all_in_progress_i)}}              & {2{stb_cache_write_data_m0_i}});

  // Calculate ECC bits for write data (allocation or store write data)
generate if (CPU_CACHE_PROTECTION) begin : g_dataram_checkbits_ecc
  ca53_ecc_generate32 u_generate32_wdata0 (.data_i (raw_data_wdata_m0[31:0]),
                                           .ecc_o  (ecc_check_bits0_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata1 (.data_i (raw_data_wdata_m0[63:32]),
                                           .ecc_o  (ecc_check_bits1_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata2 (.data_i (raw_data_wdata_m0[95:64]),
                                           .ecc_o  (ecc_check_bits2_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata3 (.data_i (raw_data_wdata_m0[127:96]),
                                           .ecc_o  (ecc_check_bits3_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata4 (.data_i (raw_data_wdata_m0[159:128]),
                                           .ecc_o  (ecc_check_bits4_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata5 (.data_i (raw_data_wdata_m0[191:160]),
                                           .ecc_o  (ecc_check_bits5_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata6 (.data_i (raw_data_wdata_m0[223:192]),
                                           .ecc_o  (ecc_check_bits6_m0[6:0]));

  ca53_ecc_generate32 u_generate32_wdata7 (.data_i (raw_data_wdata_m0[255:224]),
                                           .ecc_o  (ecc_check_bits7_m0[6:0]));

  // Assemble the write data with the calculated checkbits
  // - MBIST write data needs to be duplicated for the rotation in M1
  // - Inject ECC fatal errors on a single bank L1DEIEN is set.
  //   Given that the entire cache line has to eventually be written,
  //   and thus inject two fatal errors per cache line.

  assign data_wdata_m0[38:0]  = {(mbist_en_i ? raw_data_wdata_m0[38: 32] : ecc_check_bits0_m0[6:0]),
                                 raw_data_wdata_m0[31:2], raw_data_wdata_m0[1:0] ^ {2{(~mbist_en_i & dpu_l1deien_i)}}};

  assign data_wdata_m0[77:39] = mbist_en_i ? raw_data_wdata_m0[38:0]
                                           : {ecc_check_bits1_m0[6:0], raw_data_wdata_m0[63: 32]};

  assign data_wdata_m0[311:78] = {ecc_check_bits7_m0[6:0], raw_data_wdata_m0[255:224],
                                  ecc_check_bits6_m0[6:0], raw_data_wdata_m0[223:192],
                                  ecc_check_bits5_m0[6:0], raw_data_wdata_m0[191:160],
                                  ecc_check_bits4_m0[6:0], raw_data_wdata_m0[159:128],
                                  ecc_check_bits3_m0[6:0], raw_data_wdata_m0[127:96],
                                  ecc_check_bits2_m0[6:0], raw_data_wdata_m0[95:64]};

end else begin : g_dataram_checkbits_no_ecc
  // MBIST write data needs to be duplicated for the rotation in M1
  assign data_wdata_m0[255:64] = raw_data_wdata_m0[255:64];
  assign data_wdata_m0[63:0]   = mbist_en_i ? {2{raw_data_wdata_m0[31:0]}}
                                            : raw_data_wdata_m0[63:0];
end endgenerate

  // Register the new data whenever a new request is granted or on every
  // cycle during MBIST, as dirty RAM writes reuse the data way.
  assign data_m0_en = (data_req_type_m0 != REQ_NONE) | mbist_en_i;

  always @(posedge clk)
    if (data_m0_en) begin
      prearb_data_en_m1       <= data_bank_en_m0;
      prearb_data_way_m1      <= data_way_m0;
      prearb_data_wr_m1       <= data_wr_m0;
      prearb_data_addr_m1     <= data_set_addr_m0;
      prearb_data_addr01_m1   <= data_addr01_m0;
      prearb_data_addr23_m1   <= data_addr23_m0;
      prearb_data_addr45_m1   <= data_addr45_m0;
      prearb_data_addr67_m1   <= data_addr67_m0;
    end

  // Wdata register enables
  // - Enable upper half during MBIST and on allocations which are writing a
  // full half line
  assign data_wdata_m0_en_hi = mbist_en_i | (alloc_data_granted_m0 & biu_alloc_halfline_m0_i) | cp15_data_granted_m0;

generate if (CPU_CACHE_PROTECTION) begin : g_data_wdata_m0_en_ecc
  wire [3: 0]  data_wdata_m0_en_lo;

  // Enable lower half during MBIST, on all allocations, and on STB writes
  // - On STB writes the strobes mean can write a individual RAMs, so enable
  // data for each RAM separately
  assign data_wdata_m0_en_lo  = {4{mbist_en_i | alloc_data_granted_m0 | cp15_data_granted_m0}} |
                                ({4{stb_data_granted_m0 & stb_cache_data_wr_m0_i}} & {|stb_cache_data_bls_m0_i[15:12], // STB can write individual words
                                                                                      |stb_cache_data_bls_m0_i[11: 8],
                                                                                      |stb_cache_data_bls_m0_i[ 7: 4],
                                                                                      |stb_cache_data_bls_m0_i[ 3: 0]});

  // Enable data RAM control signals on anything which can write any part of
  // data RAM
  assign data_wdata_m0_en_any = mbist_en_i | alloc_data_granted_m0 | (stb_data_granted_m0 & stb_cache_data_wr_m0_i) | cp15_data_granted_m0;

  always @(posedge clk)
    if (data_wdata_m0_en_hi)
      prearb_data_wdata_m1[311:156] <= data_wdata_m0[311:156];

  for (data_m0_lane=0; data_m0_lane<4; data_m0_lane=data_m0_lane+1) begin : g_prearb_data_wdata_m1_lo
    always @(posedge clk)
      if (data_wdata_m0_en_lo[data_m0_lane])
        prearb_data_wdata_m1[(data_m0_lane*39)+:39] <= data_wdata_m0[(data_m0_lane*39)+:39];
  end

end else begin : g_data_wdata_m0_en_no_ecc
  wire [15: 0]  data_wdata_m0_en_lo;

  // Enable lower half during MBIST, on all allocations, and on STB writes
  // - On STB writes the strobes mean can write a individual bytes, so enable
  // data for each byte separately
  assign data_wdata_m0_en_lo  = {16{mbist_en_i | alloc_data_granted_m0 | cp15_data_granted_m0}} | // MBIST/alloc/inv all writes all bytes
                                ({16{stb_data_granted_m0}} & stb_cache_data_bls_m0_i);            // STB can write individual bytes

  // Enable data RAM control signals on anything which can write any part of
  // data RAM
  assign data_wdata_m0_en_any = mbist_en_i | alloc_data_granted_m0 |  stb_data_granted_m0 | cp15_data_granted_m0;  // All STB reqs are writes if no ECC

  always @(posedge clk)
    if (data_wdata_m0_en_hi)
      prearb_data_wdata_m1[255:128] <= data_wdata_m0[255:128];

  for (data_m0_lane=0; data_m0_lane<16; data_m0_lane=data_m0_lane+1) begin : g_prearb_data_wdata_m1_lo
    always @(posedge clk)
      if (data_wdata_m0_en_lo[data_m0_lane])
        prearb_data_wdata_m1[(data_m0_lane*8)+:8] <= data_wdata_m0[(data_m0_lane*8)+:8];
  end

end endgenerate

  always @(posedge clk)
    if (data_wdata_m0_en_any) begin
      prearb_data_rotation_m1 <= data_rotation_m0;
      prearb_data_strb_m1     <= data_strb_m0;
    end


  //---------------------------------------------------------------------------
  // Drive M0 Output Signals
  //---------------------------------------------------------------------------
  // Indicate to each requestor when it has priority so it can detect when
  // a request has been accepted. The priority signals are used rather than
  // the granted signals as the priority signals are earlier and have the
  // same value when a request is being made.
  assign dcu_alloc_has_priority_m0_o      = alloc_tag_granted_m0 | alloc_data_granted_m0 | alloc_dirty_granted_m0;
  assign dcu_pf_tag_has_priority_m0_o     = pf_priority_m0;
  assign dcu_stb_tag_has_priority_m0_o    = stb_tag_priority_m0;
  assign dcu_stb_data_has_priority_m0_o   = stb_data_granted_m0;
  assign dcu_cache_walk_has_priority_m0_o = tlb_priority_m0;
  assign cp15_data_has_priority_m0_o      = cp15_data_priority_m0;
  assign cp15_tag_has_priority_m0_o       = cp15_tag_priority_m0;


  //---------------------------------------------------------------------------
  // Arbitrate M1 requests to the cache
  //---------------------------------------------------------------------------
  // Decode some common pipelined request types
  // - Tag Requests
  assign tlb_req_m1         = (prearb_tag_req_type_m1 == REQ_TLB); // TLB always requests tag and data, so can look at either
  assign stb_tag_req_m1     = (prearb_tag_req_type_m1 == REQ_STB);
  assign pf_tag_req_m1      = (prearb_tag_req_type_m1 == REQ_PF);
  assign alloc_tag_req_m1   = (prearb_tag_req_type_m1 == REQ_ALLOC);
  assign cp15_tag_req_m1    = (prearb_tag_req_type_m1 == REQ_CP15);
  // - Data Requests
  assign alloc_data_req_m1  = (prearb_data_req_type_m1 == REQ_ALLOC);
  assign stb_data_req_m1    = (prearb_data_req_type_m1 == REQ_STB);
  assign cp15_data_req_m1   = (prearb_data_req_type_m1 == REQ_CP15);
  // - Dirty Requests
  assign stb_dirty_req_m1   = (prearb_dirty_req_type_m1 == REQ_STB);
  assign alloc_dirty_req_m1 = (prearb_dirty_req_type_m1 == REQ_ALLOC);


  //--------------------------
  // Arbitrate Snoop Requests
  //--------------------------
  // Snoop tag and dirty requests are always the highest priority request and so
  // do not need to be arbitrated.
  // Snoop data requests are lower priority than load data requests.
  // All snoop requests are suppressed during MBIST, so that does not need
  // factoring in here.

  // Load could be blocked by snoop tag write, at same time as snoop data request
  assign ccb_data_priority_m1 = ~dc_load_req_m1_i | (load_needs_tag_early_m1 & ~load_tag_priority_m1);
  assign ccb_data_granted_m1  = ccb_data_req_m1_i & ccb_data_priority_m1;

  // Indicate to CCB block when a data request has priorty and does not need to
  // stall.
  assign dc_ccb_data_has_priorty_m1_o  = ccb_data_priority_m1;


  //-------------------------
  // Arbitrate Load Requests
  //-------------------------
  // The lspipe can make a request for the tag RAM only (for a DC1 linefill
  // lookup), by asserting dc_load_tag_req_only_m1.
  // - Note that for simplicity although the lookup request only needs to access
  // the tag RAM it arbitrates for access to both the tag and data RAMs and just
  // suppresses the data RAM enable.

  // Load requests do not need to access the tag RAM when the load hits in
  // the cache way tracker logic.
  assign load_tag_req_m1 = dc_load_req_m1_i & (~seq_suppress_tag_m1 | dc_load_tag_req_only_m1_i);

  // The full load_tag_req_m1 signal is too late to use in arbitration, but
  // can calculate that a load will definitely not need a tag lookup early in
  // the cycle based on whether it is a first.
  assign load_needs_tag_early_m1 = dc_load_first_m1_i | force_dc_load_first_m1 | dc_load_tag_req_only_m1_i;

  assign load_tag_req_early_m1 = dc_load_req_m1_i & load_needs_tag_early_m1;

  // Loads have priority for the Tag RAM whenever there is no snoop request
  assign load_tag_priority_m1  = ~ccb_tag_req_m1_i;

  // Loads will be granted arbitration to each resource when they need it,
  // have priority, and any interdependencies can be met.
  // - The tag request will always happen with a data request, so it always
  // needs access to both.
  assign load_tag_granted_m1       = load_tag_req_m1 &        // Wants access to tag
                                     load_tag_priority_m1;    // Has tag priority
                                                              // (always have data priority)

  assign load_tag_granted_early_m1 = load_tag_req_early_m1 &  // Wants access to tag
                                     load_tag_priority_m1;    // Has tag priority
                                                              // (always have data priority)

  // - The data request may not need a tag lookup, but must have priority for
  // both if it does. Note that the tag request depends on the cache way
  // tracker hit, which is too late to factor into the arbitration logic.
  // However, as the cache way tracker must hit for non-first accesses, and
  // this can be calculated from early signals, tag suppression can be detected
  // in some cases.
  assign load_has_priority_m1 = (load_tag_priority_m1 |      // Have tag priority
                                 ~load_needs_tag_early_m1);  // - or don't need it
                                                             // (always have data priority)

  assign load_data_granted_m1  = dc_load_req_m1_i & load_has_priority_m1;

  // Indicate to load/store pipe when a load has priority and can leave DC1.
  assign dc_load_has_priority_m1_o = load_has_priority_m1;


  //---------------------------------
  // Arbitrate Pipelined M0 Requests
  //---------------------------------
  // Calculate the interdependencies between requests to different resources
  // for pipelined requests in M1.
  // - For the STB, it is possible for one slot to be doing a tag read or write
  // at the same time as another slot is doing a data and dirty write, in
  // which case the data and dirty access are dependent, but the tag access
  // is not.
  assign prearb_data_needs_dirty_m1  = (prearb_data_req_type_m1 == prearb_dirty_req_type_m1);

  // - Tag and Data are not interdependent for STB.
  assign prearb_data_needs_tag_m1    = (prearb_data_req_type_m1 == prearb_tag_req_type_m1) &
                                       ~(prearb_data_req_type_m1 == REQ_STB);

  // - Tag and Dirty aren't interdependent for STB.
  assign prearb_tag_needs_dirty_m1   = (prearb_tag_req_type_m1 == prearb_dirty_req_type_m1) &
                                       ~(prearb_dirty_req_type_m1 == REQ_STB);

  // Determine when there is a prearbitrated request waiting for each
  // resource.
  assign prearb_tag_req_m1    = (prearb_tag_req_type_m1   != REQ_NONE);
  assign prearb_dirty_req_m1  = (prearb_dirty_req_type_m1 != REQ_NONE);
  assign prearb_data_req_m1   = (prearb_data_req_type_m1  != REQ_NONE);

  // Determine priority for each resource.
  // - During MBIST, snoop requests and loads will be suppressed, therefore
  // prearbitrated requests will always have priority.

  assign prearb_tag_priority_m1   = ~ccb_tag_req_m1_i &           // No CCB request accessing tag
                                    ~ccb_block_prearb_tag_m1_i &  // CCB not blocking prearb
                                    (~dc_load_req_m1_i |          // No load request accessing tag
                                     ~load_needs_tag_early_m1);

  assign prearb_dirty_priority_m1 = ~ccb_dirty_req_m1_i;  // Loads never access dirty, so have priority whenever there is no snoop

  assign prearb_data_priority_m1  = ~ccb_data_req_m1_i &        // No CCB request accessing data
                                    (~dc_load_req_m1_i |        // No load request accessing data
                                     (load_needs_tag_early_m1 & // - or load blocked by CCB tag req
                                      ccb_tag_req_m1_i));

  // Grant arbitration to pipelined M0 requests taking into account the
  // interdependencies calculated above.
  assign prearb_tag_granted_m1   = prearb_tag_req_m1 & prearb_tag_priority_m1 &               // Want to access tag and have priority
                                   (prearb_dirty_priority_m1 | ~prearb_tag_needs_dirty_m1) &  // - Have dirty priority or don't need it
                                   (prearb_data_priority_m1  | ~prearb_data_needs_tag_m1);    // - Have data priority or don't need it

  assign prearb_dirty_granted_m1 = prearb_dirty_req_m1 & prearb_dirty_priority_m1 &           // Want to access dirty and have priority
                                   (prearb_tag_priority_m1  | ~prearb_tag_needs_dirty_m1) &   // - Have tag priority or don't need it
                                   (prearb_data_priority_m1 | ~prearb_data_needs_dirty_m1);   // - Have data priority or don't need it

  assign prearb_data_granted_m1  = prearb_data_req_m1 & prearb_data_priority_m1 &             // Want to access data and have priority
                                   (prearb_tag_priority_m1   | ~prearb_data_needs_tag_m1) &   // - Have tag priority or don't need it
                                   (prearb_dirty_priority_m1 | ~prearb_data_needs_dirty_m1);  // - Have dirty priority or don't need it


  //----------------------------------------------
  // Throttle requests to ensure fair arbitration
  //----------------------------------------------
  // Since the priority for different requests is fixed, the cache arbiter tells
  // the load/store pipe and CCB blocks to throttle their requests when lower
  // priority requests are blocked, to ensure that all requests can make forward
  // progress.

  // Pre-arbitrated requests are low priority and so only cause throttling of
  // higher priorty requests when they have been stalled for a number of cycles.
  // This is implemented using a timeout counter for each of the data, dirty and
  // tag requests, which is set when a request moves from M0 to M1 and
  // decrements for every cycle the request is stalled. When the counter reaches
  // zero, the cache arbiter tells other blocks to start throttling requests.
  function [TIMEOUT_CNT_W-1:0] next_prearb_count (
    input                     granted_m0,
    input                     blocked_m1,
    input [TIMEOUT_CNT_W-1:0] crnt_count
  );

    case ({granted_m0, blocked_m1}) // Note cannot be granted and blocked
      2'b10  : next_prearb_count = TIMEOUT_CNT;
      2'b01  : next_prearb_count = (~|crnt_count) ? {TIMEOUT_CNT_W{1'b0}} : (crnt_count - 1'b1);
      2'b00  : next_prearb_count = crnt_count;
      default: next_prearb_count = {TIMEOUT_CNT_W{1'bx}};
    endcase

  endfunction

  assign next_prearb_data_count_m1  = next_prearb_count((data_req_type_m0  != REQ_NONE), (prearb_data_req_m1  & ~prearb_data_granted_m1 ), prearb_data_count_m1);
  assign next_prearb_dirty_count_m1 = next_prearb_count((dirty_req_type_m0 != REQ_NONE), (prearb_dirty_req_m1 & ~prearb_dirty_granted_m1), prearb_dirty_count_m1);
  assign next_prearb_tag_count_m1   = next_prearb_count((tag_req_type_m0   != REQ_NONE), (prearb_tag_req_m1   & ~prearb_tag_granted_m1  ), prearb_tag_count_m1);

  assign prearb_count_en_m1 = (data_req_type_m0   != REQ_NONE) |
                              (dirty_req_type_m0  != REQ_NONE) |
                              (tag_req_type_m0    != REQ_NONE) |
                              prearb_data_req_m1               |
                              prearb_dirty_req_m1              |
                              prearb_tag_req_m1;

  always @(posedge clk)
    if (prearb_count_en_m1) begin
      prearb_data_count_m1  <= next_prearb_data_count_m1;
      prearb_dirty_count_m1 <= next_prearb_dirty_count_m1;
      prearb_tag_count_m1   <= next_prearb_tag_count_m1;
    end

  // Throttle snoops when they are blocking prearb requests. The throttling is
  // implemented by suppressing ac_ready on the SCU interface, so it can take
  // several cycles for snoop requests to drain. The cachearb will continue to
  // tell the CCB block to throttle whilst the request is stalled.
  // - Although there cannot be back to back CCB tag requests, the CCB block can
  // block prearb tag requests when not making a request, so this needs to be
  // factored in to the throttle logic.
  // - When a prearb request is throttling a load to get access to the data RAM,
  // snoops are also throttled to prevent a snoop being accepted on the cycle
  // the throttle is asserted, and then taking several cycles to drain.
  // - Note loads blocking prearb tag requests do not need factoring in:
  //   * CCB can only assert block_prearb_tag in lookup M1 for a previous tag
  //     write
  //   * That previous tag write would be blocking snoops on the cycle before a
  //     new request is accepted
  //   * So would already be being throttled regardless of whether a load is
  //     also being throttled
  assign dc_throttle_snoops_o = (prearb_data_req_m1  & (~|prearb_data_count_m1)  & (ccb_data_req_m1_i | dc_load_req_m1_i))  |
                                (prearb_dirty_req_m1 & (~|prearb_dirty_count_m1) & ccb_dirty_req_m1_i)                      |
                                (prearb_tag_req_m1   & (~|prearb_tag_count_m1)   & ccb_block_prearb_tag_m1_i);

  // Throttle loads when they are blocking prearb or snoop requests. Loads are
  // also throttled when there is not currently a load, but snoops are being
  // throttled because they are blocking prearb requests. This guarantees the
  // snoop request will drain as quickly as possible and not be blocked by
  // subsequent loads.
  // - Note that although loads cannot access the dirty RAM, it is possible to
  // have a prearb data request which is interdependent with a dirty request
  // which is being blocked by a snoop dirty write and snoop requests are being
  // throttled. In this case loads are also throttled to ensure that on the next
  // cycle the prearb request is not blocked by a subsequent load data request.
  assign dc_throttle_loads_o  = (prearb_data_req_m1 & (~|prearb_data_count_m1) & (dc_load_req_m1_i  |
                                                                                  ccb_data_req_m1_i |
                                                                                  (prearb_data_needs_dirty_m1 & ccb_dirty_req_m1_i & ccb_tag_req_m1_i))) |
                                (prearb_tag_req_m1  & (~|prearb_tag_count_m1)  & (load_tag_req_early_m1 |
                                                                                  ccb_block_prearb_tag_m1_i));


  //--------------------------------
  // Check for DC1 linefill hazards
  //--------------------------------
  // As there is no handshake with the BIU for DC1 linefill requests, the lspipe
  // needs to know when a data write for the same index as the linefill request
  // is granted arbitration in M1, so it can stop making the linefill request.
  // - This must be done in M1, as this is point at which the BIU/STB will stop
  // providing data for a load directly and expect it to hit in the cache.
  // - This must be done for STB write as well as allocations, as the BIU
  // expects the STB to do the write when it has merged with a linefill.

  // Note the address matching can only be done on index and not way, as the DCU
  // does not know the way the linefill will be allocated into (it could be
  // different from the victim way indicated by the DCU).
  assign dc_load_index_match_m1_o = (alloc_data_req_m1 | stb_data_req_m1) & prearb_data_wr_m1 &
                                    prearb_data_granted_m1 &
                                    ((prearb_data_addr_m1[13:6] & {dc_size_i, 5'b11111}) ==
                                     (dc_load_addr_m1_i[13:6]   & {dc_size_i, 5'b11111}));


  //---------------------------------------------------------------------------
  // M1 Datapath
  //---------------------------------------------------------------------------

  //---------
  // Tag RAM
  //---------

  // Generate the write data for the Tag RAM. This is also pipelined (without
  // the MOESI bits) to M2 to use in hit detection for lookup requests.
  // - Form the complete tag for snoop requests.
  assign snoop_tag_m1  = {ccb_tag_moesi_m1_i,
                          ccb_write_addr_m1_i[40:14],
                          (ccb_write_addr_m1_i[13:11] & ~dc_size_i)}; // Mask bottom bits to zero depending on cache size

  // - Form the complete tag for pre-arbitrated requests. The lower bits of
  // the tag come from the set for smaller cache sizes.
  assign prearb_tag_m1 = {prearb_tag_moesi_m1,
                          prearb_tag_ns_m1,
                          prearb_tag_addr_m1[39:14],
                          (prearb_tag_set_m1[13:11] & ~dc_size_i)};   // Mask bottom bits to zero depending on cache size

  // Form the control outputs to the Tag RAM
  assign tagram_en_m1    = ({4{ccb_tag_req_m1_i}}      & ccb_write_way_m1_i) |
                           ({4{load_tag_granted_m1}}   & 4'b1111)            | // Load always looks up all ways
                           ({4{prearb_tag_granted_m1}} & prearb_tag_way_m1);

  assign tagram_addr_m1  = ({8{ccb_tag_req_m1_i}}           & ccb_write_addr_m1_i[13:6]) |
                           ({8{load_tag_granted_early_m1}}  & dc_load_addr_m1_i[13:6]) |
                           ({8{~ccb_tag_req_m1_i &
                               ~load_tag_granted_early_m1}} & prearb_tag_set_m1[13:6]);

  assign tagram_wr_m1    = (ccb_tag_req_m1_i       & 1'b1) |  // CCB only accesses tag to write
                           (prearb_tag_granted_m1  & prearb_tag_wr_m1);
                           // Loads never write tag, so don't need
                           // factoring in.

  // Select write data for Tag RAM and generate parity (if ECC present)
generate if (CPU_CACHE_PROTECTION) begin : g_tag_wdata_ecc
  wire prearb_tag_parity_m1;
  wire snoop_tag_parity_m1;

  // Calculate ECC check parity bit for Tag RAM write data
  // - calculated for each source separately to improve timing
  assign prearb_tag_parity_m1 = ^prearb_tag_m1[31:0];
  assign snoop_tag_parity_m1  = ^snoop_tag_m1[31:0];

  assign dc_tagram_wdata_o = ({33{mbist_en_i}}          & prearb_data_wdata_m1[32:0]) |  // MBIST write data supplied on biu_alloc_data
                             ({33{ccb_tag_req_m1_i}}    & {snoop_tag_parity_m1,  snoop_tag_m1}) |
                             ({33{~(mbist_en_i |
                                    ccb_tag_req_m1_i)}} & {prearb_tag_parity_m1, prearb_tag_m1});

end else begin : g_tag_wdata_no_ecc
  // Tag RAM write data
  assign dc_tagram_wdata_o = ({32{mbist_en_i}}          & prearb_data_wdata_m1[31:0]) |  // MBIST write data supplied on biu_alloc_data
                             ({32{ccb_tag_req_m1_i}}    & snoop_tag_m1)               |
                             ({32{~(mbist_en_i |
                                    ccb_tag_req_m1_i)}} & prearb_tag_m1);
end endgenerate

  // Assign M1 outputs to Tag RAM
  assign  dc_tagram_en_o    = tagram_en_m1 & {4{~DFTRAMHOLD}};
  assign  dc_tagram_addr_o  = tagram_addr_m1;
  assign  dc_tagram_wr_o    = tagram_wr_m1;


  //-----------
  // Dirty RAM
  //-----------
  // As well as the dirty bit, the dirty RAM also contains the Outer Allocation
  // Hint, Age and migratory information for the line. When cache protection is
  // present, it also stores two copies of the dirty bit.
  // For optimal RAM geometry, each line in the dirty RAM contains data for two
  // different ways, one even and one odd. The bottom bit of the address selects
  // between the upper and lower pairs of ways.
  // The dirty RAM is organised as follows:
  //
  // Config:  |---------- ECC Only -----------|------------------------ Always Present -----------------------|
  // Way:     |----- 1/3 -----|----- 0/2 -----|------------- 1/3 -------------|------------- 0/2 -------------|
  // Bit:     |  11   |  10   |   9   |   8   |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
  // Meaning: | Dirty Copy x2 | Dirty Copy x2 |  OAH  |  Age  |  Mig. | Dirty |  OAH  |  Age  |  Mig. | Dirty |
  //          |-----------------------------------------------------------------------------------------------|

  // Form the control outputs to the Dirty RAM
  assign dirtyram_en_m1   = ccb_dirty_req_m1_i |
                            prearb_dirty_granted_m1;

  assign dirtyram_addr_m1 = ccb_dirty_req_m1_i ? {ccb_dirty_addr_m1_i[13:6], (ccb_dirty_way_m1_i[3] | ccb_dirty_way_m1_i[2])}
                                               : prearb_dirty_addr_m1[13:5];

  assign dirtyram_wr_m1   = (ccb_dirty_req_m1_i       & ccb_tag_req_m1_i) |  // CCB writes dirty when writing tag (and will always be arbitrated)
                            (prearb_dirty_granted_m1  & prearb_dirty_wr_m1);

  // Form the write data
  // - For pipelined requests, the source of the data depends on the request
  // type. STB dirty writes provide their data in M0, which is pipelined to M1,
  // but for allocations the BIU provides the data directly in M1.
  assign alloc_dirty_wdata_m1     = {biu_alloc_attrs_m1_i[2],     // Dirty RAM stores write allocation hint
                                     biu_alloc_dirty_age_m1_i,    // - age information
                                     biu_alloc_dirty_moesi_m1_i}; // - and with MOESI and dirty bits

  // - Expand pipelined STB data with bits which are constant for STB writes
  assign stb_dirty_wdata_full_m1  = {stb_dirty_wdata_m1[1],
                                     1'b0,                        // STB doesn't write Age
                                     stb_dirty_wdata_m1[0],
                                     1'b1};                       // STB always sets dirty

  // STB data is pipelined from M0, but is set to 0 on allocations so it can be
  // muxed just by ORing with the allocation data in M1
  assign prearb_dirty_wdata_m1 = ({4{alloc_dirty_req_m1}} & alloc_dirty_wdata_m1) |
                                 ({4{stb_dirty_req_m1}}   & stb_dirty_wdata_full_m1);

  // - Select the correct write data based on the request type and factor in
  // the MBIST write data. MBIST specifies the value to be written to each
  // bit, but for other requests, the four bit value for each way needs to
  // be replicated across the width of the RAM, as the strobes will ensure
  // that only the portion of the RAM for the relevant way is written.
generate if (CPU_CACHE_PROTECTION) begin : g_dirty_wdata_m1_ecc
  // - Duplicate dirty bit over top four bits
  assign dirtyram_wdata_m1  = ({12{mbist_en_i}}          & prearb_data_wdata_m1[11:0])                                  |
                              ({12{ccb_dirty_req_m1_i}}  & {{4{ccb_dirty_wdata_m1_i[0]}},  {2{ccb_dirty_wdata_m1_i}}})  |
                              ({12{~ccb_dirty_req_m1_i}} & {{4{prearb_dirty_wdata_m1[0]}}, {2{prearb_dirty_wdata_m1}}});

end else begin : g_dirty_wdata_m1_no_ecc

  assign dirtyram_wdata_m1  = ({8{mbist_en_i}}          & prearb_data_wdata_m1[7:0]) |
                              ({8{ccb_dirty_req_m1_i}}  & {2{ccb_dirty_wdata_m1_i}}) |
                              ({8{~ccb_dirty_req_m1_i}} & {2{prearb_dirty_wdata_m1}});

end endgenerate

  // Generate the strobes
  // - The strobes enable the parts of the RAM corresponding to the way being
  // written
  // - STB writes do not write the age bit, so that strobe is set to 0 on STB
  // writes
  // - MBIST specifies directly the strobes to be enabled
generate if (CPU_CACHE_PROTECTION) begin : g_dirty_strb_m1_ecc

  assign snoop_dirty_strb_m1  = { {2{ccb_dirty_way_m1_i[3] | ccb_dirty_way_m1_i[1]}},   // Odd duplicate dirty
                                  {2{ccb_dirty_way_m1_i[2] | ccb_dirty_way_m1_i[0]}},   // Even duplicate dirty
                                  {4{ccb_dirty_way_m1_i[3] | ccb_dirty_way_m1_i[1]}},   // Odd dirty data
                                  {4{ccb_dirty_way_m1_i[2] | ccb_dirty_way_m1_i[0]}} }; // Even dirty data

  assign prearb_dirty_strb_m1 = mbist_en_i ? mbist_be_m1 :
                                { {2{prearb_dirty_way_m1[3] | prearb_dirty_way_m1[1]}},       // Odd duplicate entry
                                  {2{prearb_dirty_way_m1[2] | prearb_dirty_way_m1[0]}},       // Even duplicate entry
                                  ({{4{prearb_dirty_way_m1[3] | prearb_dirty_way_m1[1]}},     // Odd dirty data
                                    {4{prearb_dirty_way_m1[2] | prearb_dirty_way_m1[0]}}} &   // Even dirty data
                                   // STB doesn't write age bit, so don't set that strobe bit
                                   {2{1'b1, ~stb_dirty_req_m1, 2'b11}}) };

end else begin : g_dirty_strb_m1_no_ecc

  assign snoop_dirty_strb_m1  = { {4{ccb_dirty_way_m1_i[3] | ccb_dirty_way_m1_i[1]}},   // Odd dirty data
                                  {4{ccb_dirty_way_m1_i[2] | ccb_dirty_way_m1_i[0]}} }; // Even dirty data

  assign prearb_dirty_strb_m1 = mbist_en_i ? mbist_be_m1 :
                                ({ {4{prearb_dirty_way_m1[3] | prearb_dirty_way_m1[1]}},     // Odd dirty data
                                   {4{prearb_dirty_way_m1[2] | prearb_dirty_way_m1[0]}} } &  // Even dirty data
                                   // STB doesn't write age bit, so don't set that strobe bit
                                 {2{1'b1, ~stb_dirty_req_m1, 2'b11}});

end endgenerate

  assign dirtyram_strb_m1 = ({`CA53_DDIRTY_RAM_W{ccb_dirty_req_m1_i      & ccb_tag_req_m1_i}}   & snoop_dirty_strb_m1) |
                            ({`CA53_DDIRTY_RAM_W{prearb_dirty_granted_m1 & prearb_dirty_wr_m1}} & prearb_dirty_strb_m1);

  // Assign M1 outputs to Dirty RAM
  assign dc_dirtyram_en_o    = dirtyram_en_m1 & ~DFTRAMHOLD;
  assign dc_dirtyram_wr_o    = dirtyram_wr_m1;
  assign dc_dirtyram_strb_o  = dirtyram_strb_m1;
  assign dc_dirtyram_wdata_o = dirtyram_wdata_m1;
  assign dc_dirtyram_addr_o  = dirtyram_addr_m1;


  //----------
  // Data RAM
  //----------

  // Determining the data RAM address in M1 is only complicated for snoop
  // requests - load requests access the same address in each bank, and the
  // address computation for pipelined requests is done in M0. Therefore,
  // compute the CCB data address first.

  // - The bottom bits are different for each bank, and depend on the way and
  // bit [5] of the address. Unlike allocations, which are only quarter line
  // (128-bits) aligned, snoop requests are always half-line aligned, and so
  // don't depend on bit [4] of the address.
  always @*
    case ({ccb_data_addr_m1_i[5], ccb_lookup_way_i})
      // Offset 0: Dwords 0-3
      5'b0_0001: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b011, 3'b010, 3'b001, 3'b000};
      5'b0_0010: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b010, 3'b001, 3'b000, 3'b011};
      5'b0_0100: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b001, 3'b000, 3'b011, 3'b010};
      5'b0_1000: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b000, 3'b011, 3'b010, 3'b001};
      // Offset 2: Dwords 4-7
      5'b1_0001: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b111, 3'b110, 3'b101, 3'b100};
      5'b1_0010: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b110, 3'b101, 3'b100, 3'b111};
      5'b1_0100: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b101, 3'b100, 3'b111, 3'b110};
      5'b1_1000: {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'b100, 3'b111, 3'b110, 3'b101};
      default  : {ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1} = {3'bxxx, 3'bxxx, 3'bxxx, 3'bxxx};
    endcase

  // Data RAM addresses
  assign dataram_addr01_m1  = ({11{ccb_data_granted_m1}}     & {ccb_data_addr_m1_i[13:6], ccb_data_addr01_m1}) |
                              ({11{load_data_granted_m1}}    & dc_load_addr_m1_i[13:3])                        |
                              ({11{~(ccb_data_req_m1_i |
                                     load_data_granted_m1)}} & {prearb_data_addr_m1, prearb_data_addr01_m1});

  assign dataram_addr23_m1  = ({11{ccb_data_granted_m1}}     & {ccb_data_addr_m1_i[13:6], ccb_data_addr23_m1}) |
                              ({11{load_data_granted_m1}}    & dc_load_addr_m1_i[13:3])                        |
                              ({11{~(ccb_data_req_m1_i |
                                     load_data_granted_m1)}} & {prearb_data_addr_m1, prearb_data_addr23_m1});

  assign dataram_addr45_m1  = ({11{ccb_data_granted_m1}}     & {ccb_data_addr_m1_i[13:6], ccb_data_addr45_m1}) |
                              ({11{load_data_granted_m1}}    & dc_load_addr_m1_i[13:3])                        |
                              ({11{~(ccb_data_req_m1_i |
                                     load_data_granted_m1)}} & {prearb_data_addr_m1, prearb_data_addr45_m1});

  assign dataram_addr67_m1  = ({11{ccb_data_granted_m1}}     & {ccb_data_addr_m1_i[13:6], ccb_data_addr67_m1}) |
                              ({11{load_data_granted_m1}}    & dc_load_addr_m1_i[13:3])                        |
                              ({11{~(ccb_data_req_m1_i |
                                     load_data_granted_m1)}} & {prearb_data_addr_m1, prearb_data_addr67_m1});

  // Determining the data RAM enables in M1 is only complicated for
  // loads, as snoop requests always access all banks of the Data RAM,
  // and the bank enables for pre-arbitrated requests are calculated
  // in M0.
  // - Calculate the early enables here so can mux late load enable in
  // as late as possible.
  assign early_dataram_en_m1  = ({8{ccb_data_granted_m1}}     & 8'b1111_1111)    |  // CCB always accesses all banks
                                ({8{prearb_data_granted_m1}}  & prearb_data_en_m1);

  // - For non-sequential loads, all ways need to be looked up, however if
  // the byte strobes indicate that a particular half is not required in each
  // double-word pair, then the enable for that half can be suppressed.
  assign nonseq_load_data_en_m1 = { (|dc_load_bls_m1_i[7:4]), (|dc_load_bls_m1_i[3:0]),
                                    (|dc_load_bls_m1_i[7:4]), (|dc_load_bls_m1_i[3:0]),
                                    (|dc_load_bls_m1_i[7:4]), (|dc_load_bls_m1_i[3:0]),
                                    (|dc_load_bls_m1_i[7:4]), (|dc_load_bls_m1_i[3:0]) };

  // - For sequential loads when the registered tag lookup result is
  // available, only the bank containing the double-word for the way being
  // accessed needs to be enabled.
  // - The bank-pair containing the doubleword being addressed is a function
  // of the way and the lower bits of the doubleword address, and is
  // calculated in the same way as for pipelined requests in M0.
  // - Because the result of the sequential state machine lookup is available
  // relatively late, the sequential enable is calculated speculatively for
  // each possible value with the lookup result factored in as late as
  // possible.
  // - Note that when the lookup misses, the seq_way signal will be 'b1111,
  // which means the separate enables will combine to form the non-sequential
  // enable value, so the hit signal does not need factoring in separately.
  function [7:0] seq_load_data_mask_way_m1 (
    // Does same as rotate_left_4bit, but expands each bit of result by 2
    input [3:0] value,      // 4-bit value to be rotated
    input [1:0] rotation    // Binary value of rotation
  );

    case (rotation)
      2'b00  : seq_load_data_mask_way_m1 = { {2{value[3]}}, {2{value[2]}}, {2{value[1]}}, {2{value[0]}} };
      2'b01  : seq_load_data_mask_way_m1 = { {2{value[2]}}, {2{value[1]}}, {2{value[0]}}, {2{value[3]}} };
      2'b10  : seq_load_data_mask_way_m1 = { {2{value[1]}}, {2{value[0]}}, {2{value[3]}}, {2{value[2]}} };
      2'b11  : seq_load_data_mask_way_m1 = { {2{value[0]}}, {2{value[3]}}, {2{value[2]}}, {2{value[1]}} };
      default: seq_load_data_mask_way_m1 = 8'bxxxxxxxx;
    endcase

  endfunction

  assign load_data_en_way0_m1 = {8{load_data_granted_m1}} & nonseq_load_data_en_m1 & seq_load_data_mask_way_m1(4'b0001, dc_load_addr_m1_i[4:3]);
  assign load_data_en_way1_m1 = {8{load_data_granted_m1}} & nonseq_load_data_en_m1 & seq_load_data_mask_way_m1(4'b0010, dc_load_addr_m1_i[4:3]);
  assign load_data_en_way2_m1 = {8{load_data_granted_m1}} & nonseq_load_data_en_m1 & seq_load_data_mask_way_m1(4'b0100, dc_load_addr_m1_i[4:3]);
  assign load_data_en_way3_m1 = {8{load_data_granted_m1}} & nonseq_load_data_en_m1 & seq_load_data_mask_way_m1(4'b1000, dc_load_addr_m1_i[4:3]);

  assign load_data_en_m1 = ({8{seq_way_m1[0]}} & load_data_en_way0_m1) |
                           ({8{seq_way_m1[1]}} & load_data_en_way1_m1) |
                           ({8{seq_way_m1[2]}} & load_data_en_way2_m1) |
                           ({8{seq_way_m1[3]}} & load_data_en_way3_m1);

  // - Mux the early and late (load) dataram enable signals (note each is
  // qualified separately so do not need qualifying here).
  assign dataram_en_m1 = early_dataram_en_m1 | (load_data_en_m1 & {8{~dc_load_tag_req_only_m1_i}});

  // Data RAM Write Data
  // - Data is supplied in M0, but is rotated in M1
  // - The size of the data depends on whether ECC is present or not
generate if (CPU_CACHE_PROTECTION) begin : g_dataram_wdata_m1_ecc

  always @*
    case (prearb_data_rotation_m1)
      ROTATION_0     : dataram_wdata_m1 = {prearb_data_wdata_m1[234+:78],
                                           prearb_data_wdata_m1[156+:78],
                                           prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78]};

      ROTATION_1     : dataram_wdata_m1 = {prearb_data_wdata_m1[156+:78],
                                           prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[234+:78]};

      ROTATION_2     : dataram_wdata_m1 = {prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[234+:78],
                                           prearb_data_wdata_m1[156+:78]};

      ROTATION_3     : dataram_wdata_m1 = {prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[234+:78],
                                           prearb_data_wdata_m1[156+:78],
                                           prearb_data_wdata_m1[78 +:78]};

      ROTATION_STB_0 : dataram_wdata_m1 = {prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78]};

      ROTATION_STB_1 : dataram_wdata_m1 = {prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[78 +:78],
                                           prearb_data_wdata_m1[0  +:78],
                                           prearb_data_wdata_m1[78 +:78]};

      default        : dataram_wdata_m1 = {312{1'bx}};
    endcase

  assign  dc_dataram_wdata0_o = dataram_wdata_m1[0  +:39];
  assign  dc_dataram_wdata1_o = dataram_wdata_m1[39 +:39];
  assign  dc_dataram_wdata2_o = dataram_wdata_m1[78 +:39];
  assign  dc_dataram_wdata3_o = dataram_wdata_m1[117+:39];
  assign  dc_dataram_wdata4_o = dataram_wdata_m1[156+:39];
  assign  dc_dataram_wdata5_o = dataram_wdata_m1[195+:39];
  assign  dc_dataram_wdata6_o = dataram_wdata_m1[234+:39];
  assign  dc_dataram_wdata7_o = dataram_wdata_m1[273+:39];

end else begin : g_dataram_wdata_m1_no_ecc

  always @*
    case (prearb_data_rotation_m1)
      ROTATION_0     : dataram_wdata_m1 = {prearb_data_wdata_m1[192+:64],
                                           prearb_data_wdata_m1[128+:64],
                                           prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64]};

      ROTATION_1     : dataram_wdata_m1 = {prearb_data_wdata_m1[128+:64],
                                           prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[192+:64]};

      ROTATION_2     : dataram_wdata_m1 = {prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[192+:64],
                                           prearb_data_wdata_m1[128+:64]};

      ROTATION_3     : dataram_wdata_m1 = {prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[192+:64],
                                           prearb_data_wdata_m1[128+:64],
                                           prearb_data_wdata_m1[64 +:64]};

      ROTATION_STB_0 : dataram_wdata_m1 = {prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64]};

      ROTATION_STB_1 : dataram_wdata_m1 = {prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[64 +:64],
                                           prearb_data_wdata_m1[0  +:64],
                                           prearb_data_wdata_m1[64 +:64]};

      default        : dataram_wdata_m1 = {256{1'bx}};
    endcase

  assign  dc_dataram_wdata0_o = dataram_wdata_m1[0  +:32];
  assign  dc_dataram_wdata1_o = dataram_wdata_m1[32 +:32];
  assign  dc_dataram_wdata2_o = dataram_wdata_m1[64 +:32];
  assign  dc_dataram_wdata3_o = dataram_wdata_m1[96 +:32];
  assign  dc_dataram_wdata4_o = dataram_wdata_m1[128+:32];
  assign  dc_dataram_wdata5_o = dataram_wdata_m1[160+:32];
  assign  dc_dataram_wdata6_o = dataram_wdata_m1[192+:32];
  assign  dc_dataram_wdata7_o = dataram_wdata_m1[224+:32];

end endgenerate

  // Data RAM wr
  // - The data RAM can only be written by MBIST, allocations or the
  // STB, which are all pipelined from M0.
  assign dataram_wr_m1 = prearb_data_granted_m1 & prearb_data_wr_m1;

  // Data RAM write strobes
  // - The data RAM is only ever written by M0 requests, and the byte strobes
  // for these requires are calculated in M0 for a double bank, and
  // replicated here over all banks.
  // - Strobes are only ever set for banks which are enabled, so if a
  // prearb request is not being granted this cycle, or is not enabling
  // a particular bank, then the strobes for that bank are suppressed.
  assign dataram_strb7_m1 = prearb_data_strb_m1[15:12] & {4{dataram_wr_m1 & prearb_data_en_m1[7]}};
  assign dataram_strb6_m1 = prearb_data_strb_m1[11:8]  & {4{dataram_wr_m1 & prearb_data_en_m1[6]}};
  assign dataram_strb5_m1 = prearb_data_strb_m1[7:4]   & {4{dataram_wr_m1 & prearb_data_en_m1[5]}};
  assign dataram_strb4_m1 = prearb_data_strb_m1[3:0]   & {4{dataram_wr_m1 & prearb_data_en_m1[4]}};
  assign dataram_strb3_m1 = prearb_data_strb_m1[15:12] & {4{dataram_wr_m1 & prearb_data_en_m1[3]}};
  assign dataram_strb2_m1 = prearb_data_strb_m1[11:8]  & {4{dataram_wr_m1 & prearb_data_en_m1[2]}};
  assign dataram_strb1_m1 = prearb_data_strb_m1[7:4]   & {4{dataram_wr_m1 & prearb_data_en_m1[1]}};
  assign dataram_strb0_m1 = prearb_data_strb_m1[3:0]   & {4{dataram_wr_m1 & prearb_data_en_m1[0]}};

  // Assign output signals to data RAMs
  assign  dc_dataram_en_o     = dataram_en_m1 & {8{~DFTRAMHOLD}};
  assign  dc_dataram_addr0_o  = dataram_addr01_m1;
  assign  dc_dataram_addr1_o  = dataram_addr01_m1;
  assign  dc_dataram_addr2_o  = dataram_addr23_m1;
  assign  dc_dataram_addr3_o  = dataram_addr23_m1;
  assign  dc_dataram_addr4_o  = dataram_addr45_m1;
  assign  dc_dataram_addr5_o  = dataram_addr45_m1;
  assign  dc_dataram_addr6_o  = dataram_addr67_m1;
  assign  dc_dataram_addr7_o  = dataram_addr67_m1;
  assign  dc_dataram_wr_o     = dataram_wr_m1;
  assign  dc_dataram_strb0_o  = dataram_strb0_m1;
  assign  dc_dataram_strb1_o  = dataram_strb1_m1;
  assign  dc_dataram_strb2_o  = dataram_strb2_m1;
  assign  dc_dataram_strb3_o  = dataram_strb3_m1;
  assign  dc_dataram_strb4_o  = dataram_strb4_m1;
  assign  dc_dataram_strb5_o  = dataram_strb5_m1;
  assign  dc_dataram_strb6_o  = dataram_strb6_m1;
  assign  dc_dataram_strb7_o  = dataram_strb7_m1;


  //---------------------------------------------------------------------------
  // Load Way Caching
  //---------------------------------------------------------------------------
  // To reduce the number of RAM toggles required by loads, and therefore
  // reduce power, the cache arbiter stores the way in which a load hit, so
  // that subsequent loads to the same cache line can be treated as sequential
  // and do not need to redo a tag lookup.
  //
  // This is done with an array of state machines, each of which is tagged
  // with the address of a load. Each state machine then tracks the result of
  // a load lookup, and checks the address of new loads. If there is a match,
  // then the tag RAM enable can be suppressed, and the result of the lookup
  // taken from the state machine.
  //
  // To avoid needing to do a full address comparison on the load address to
  // see if there is a hit in any of the state machines, which would not be
  // possible to do and meet timing on the RAM enables, the logic uses the
  // hit_entry signal from the DPU to determine the top bits of the address.
  // When two accesses hit in the same uTLB entry, they must have the same
  // PA[39:12], so this does not need to be checked. This means that only the
  // cache line offset within the page (address[11:6]) and the uTLB entry
  // (4-bits) need to be compared. The downside to this approach is that if
  // there is a uTLB miss (which will overwrite an entry in the uTLB changing
  // its PA), then the state needs to be flushed. The uTLB is expected to have
  // a good hit rate in common cases however.
  //
  // Even with the reduced size of the address comparison, the result of the
  // lookup is too late to factor into the M1 arbitration logic and can only
  // be used to suppress the RAM enables for the load. To enable the
  // throughput of prearbitrated requests to be improved when loads will not
  // need to access the tag RAM, the cache arbiter contains logic to predict
  // when a load is guaranteed to hit in a state machine entry, without
  // needing to do an address comparison. This relies on the fact that for
  // multi-part load instructions (e.g. LDM), the DPU indicates when
  // subsequent beats are within the same cache line as the previous beat (by
  // deasserting load_first). Therefore, any load with that signal suppress
  // must hit in a state machine entry, and therefore will not need to do
  // a tag lookup. This is known early enough in the cycle to enable to
  // factor in to the M1 arbitration logic.
  //
  // To further simplify the load way caching logic, the state is flushed
  // whenever a line is added or removed from the cache by a snoop request or
  // allocation.

  // Reset state machines if:
  // - The load/store pipe indicates the state machine should be reset (i.e.
  // there is a uTLB miss)
  // - There is an ECC error
  // - A line is invalidated or there is an allocation, as this can change the
  // state of the cache
  // - The exception level changes, as there can be multiple entries in the DPU
  // uTLB mapping the same VA to different PAs, as the uTLB entries are

  // - As EL0-1 always use the same translations, and the uTLB is flushed on
  // security state changes (so it will flush on transitions between EL2/3), it
  // is only necessary to flush when bit[1] of the exception level changes.
  always @(posedge clk)
    seq_exception_level <= dpu_exception_level_1_i;

  assign force_non_seq = dc_force_non_seq_i                                         |
                         ecc_err_correct_m3 | ecc_in_progress                       |
                         (seq_exception_level != dpu_exception_level_1_i)           |
                         (ccb_tag_req_m1_i & `CA53_TAG_INVALID(ccb_tag_moesi_m1_i)) |
                         // - need to ensure do not issue load at same time as invalidating
                         // allocation writes the cache, as BIU will not assert
                         // biu_suppress_load_hit in that case.
                         // - so flush when alloc granted in M0 so load will always arbitrate
                         // for tag.
                         alloc_tag_granted_m0 | alloc_tag_req_m1;

  // The state being reset can cause a load marked as ~first to miss in the
  // state machines, so set a flag after the state is reset and keep it set
  // until the next load. This can then be used to force ~first loads to be
  // treated as if they were marked first.
  assign next_force_dc_load_first_m1 = force_non_seq |                                      // Set when reset state
                                       dc_force_first_i | (entering_dcu & dpu_force_first_iss_i) |
                                       (force_dc_load_first_m1 & ~dc_valid_load_req_m1_i);  // Clear on next lookup

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      force_dc_load_first_m1 <= 1'b0;
    else
      force_dc_load_first_m1 <= next_force_dc_load_first_m1;

  // An entry needs to be allocated to a new load when it misses in all the
  // existing entries.
  assign seq_miss_m1  = ~seq_suppress_tag_m1;  // Hitting entry will always suppress tag
  assign start_seq_m1 = dc_valid_load_req_m1_i & seq_miss_m1 & ~force_non_seq;

  // Use simple round robin replacement strategy for picking an entry to
  // replace when none hit.
  // - Since when one entry is cleared all are cleared, if the counter points
  // to a valid entry then all other entries must be valid, so the counter
  // value can always be used to select a victim.
  assign next_seq_victim_select_count = (seq_victim_select_count == SEQ_VICTIM_CNT_MAX[SEQ_VICTIM_CNT_W-1:0]) ? {SEQ_VICTIM_CNT_W{1'b0}}
                                                                                                              : (seq_victim_select_count + 1'b1);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      seq_victim_select_count <= {SEQ_VICTIM_CNT_W{1'b0}};
    else if (start_seq_m1)
      seq_victim_select_count <= next_seq_victim_select_count;

  // - Convert to one-hot to generate start signal for each entry
  assign seq_victim_select  = { {SEQ_STATE_ENTRIES-1{1'b0}}, 1'b1 } << seq_victim_select_count;
  assign start_seq_entry_m1 = {SEQ_STATE_ENTRIES{start_seq_m1}} & seq_victim_select;

  // Detect when address in Iss matches address in DC1
  // - required because of pipelined seq state lookup
  // - Compare done with CSA comparator to improve timing
  assign dpu_agu_a_xor_b_iss  = dpu_agu_a_operand_iss_i[48:6] ^ dpu_agu_b_operand_iss_i[48:6];
  assign dpu_agu_a_and_b_iss  = dpu_agu_a_operand_iss_i[47:6] & dpu_agu_b_operand_iss_i[47:6];
  assign csa_sum              = dpu_agu_a_xor_b_iss[48:6] ^ ~dpu_va_dc1_i[48:6];
  assign csa_carry            = dpu_agu_a_and_b_iss[47:6]                                    |
                                (dpu_agu_a_operand_iss_i[47:6] & ~dpu_va_dc1_i[47:6]) |
                                (dpu_agu_b_operand_iss_i[47:6] & ~dpu_va_dc1_i[47:6]);
  assign csa_combine          = (csa_sum[48:6] ^ {csa_carry[47:6], dpu_agu_carry_out_64b_iss_i}) | { {17{~dpu_aarch64_state_i}}, {26{1'b0}} };

  assign back_to_back_hit_iss[2] = &csa_combine[48:34];
  assign back_to_back_hit_iss[1] = &csa_combine[33:20];
  assign back_to_back_hit_iss[0] = &csa_combine[19: 6];

  // Detect when new transaction entering DC1 from Iss (used by seq state entries)
  assign entering_dcu = dpu_valid_iss_i & dcu_ready_iss_i & ~dpu_flush_i;

  // Instantiate individual entries
  generate for (seq_entry=0; seq_entry<SEQ_STATE_ENTRIES; seq_entry=seq_entry+1) begin : g_seq_state

    ca53dcu_cachearb_seq_state u_seq_state_entry (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .dpu_aarch64_state_i          (dpu_aarch64_state_i),
      .dpu_agu_a_operand_iss_i      (dpu_agu_a_operand_iss_i[47:6]),
      .dpu_agu_b_operand_iss_i      (dpu_agu_b_operand_iss_i[47:6]),
      .dpu_agu_a_xor_b_iss_i        (dpu_agu_a_xor_b_iss),
      .dpu_agu_a_and_b_iss_i        (dpu_agu_a_and_b_iss),
      .dpu_agu_carry_out_64b_iss_i  (dpu_agu_carry_out_64b_iss_i),
      .entering_dcu_i               (entering_dcu),
      .back_to_back_hit_iss_i       (back_to_back_hit_iss),
      .start_seq_m1_i               (start_seq_entry_m1[seq_entry]),
      .dpu_va_dc1_i                 (dpu_va_dc1_i[48:6]),
      .force_non_seq_i              (force_non_seq),
      .tag_way_comp_m2_i            (tag_way_comp_m2),
      .seq_suppress_tag_m1_o        (seq_suppress_tag_entry_m1[seq_entry]),
      .seq_suppress_data_m1_o       (seq_suppress_data_entry_m1[seq_entry]),
      .seq_way_m1_o                 (seq_way_entry_m1[seq_entry][3:0])
    );

  end endgenerate

  // The outputs of each entry are masked inside the module, and so can just
  // be OR'd together here to form the muxed value
  assign seq_suppress_tag_m1  = |seq_suppress_tag_entry_m1;
  assign seq_suppress_data_m1 = |seq_suppress_data_entry_m1;

  // The seq_way_entry output from each state machine is force to 4'b1111
  // (i.e. non-sequential) when the entry misses, so just need to AND all
  // outputs together to get the correct hit way, which will be 4'b1111 if
  // all entries miss. This means do not need to further qualify the way
  // when it is used in the dataram enable calculation.
  always @* begin : g_seq_way_or
    integer   i;
    reg [3:0] seq_way_m1_tmp;
    seq_way_m1_tmp = 4'b1111;

    for (i=0; i<SEQ_STATE_ENTRIES; i=i+1)
      seq_way_m1_tmp = seq_way_m1_tmp & seq_way_entry_m1[i][3:0];

    seq_way_m1 = seq_way_m1_tmp;
  end


  //---------------------------------------------------------------------------
  // Drive M1 Output Signals (to other blocks)
  //---------------------------------------------------------------------------
  // Acknowledge handshakes to blocks which were arbitrated in M0 to say that
  // their M1 request has been granted.
  assign dcu_alloc_ack_m1_o       = (alloc_data_req_m1  & prearb_data_granted_m1)  |
                                    (alloc_dirty_req_m1 & prearb_dirty_granted_m1) |
                                    (alloc_tag_req_m1   & prearb_tag_granted_m1);
  assign dcu_stb_data_ack_m1_o    = stb_data_req_m1   & prearb_data_granted_m1;
  assign dcu_stb_tag_ack_m1_o     = stb_tag_req_m1    & prearb_tag_granted_m1;
  assign dcu_pf_tag_ack_m1_o      = pf_tag_req_m1     & prearb_tag_granted_m1;
  assign dcu_cache_walk_ack_m1_o  = tlb_req_m1        & prearb_tag_granted_m1;  // Can use either tag or data granted, as both will be true simultaneously for TLB

  // Indicate to  when CP15 has priority and can leave M1.
  assign dc_cp15_ack_m1_o         = (cp15_tag_req_m1  & prearb_tag_granted_m1) |
                                    (cp15_data_req_m1 & prearb_data_granted_m1);

  // Indicate to load/store pipe when an allocation is writing the tag as
  // invalid because it got an external abort
  assign alloc_invalidating_tag_m1_o = alloc_tag_req_m1 & prearb_tag_granted_m1 & `CA53_TAG_INVALID(prearb_tag_moesi_m1);


  //---------------------------------------------------------------------------
  // Pipeline M1 Data to M2
  //---------------------------------------------------------------------------

  // Tag lookup information
  // - Only consider a load lookup if it is not being dropped
  assign valid_load_lookup_m1 = load_tag_granted_m1 & (dc_valid_load_req_m1_i | dc_load_tag_req_only_m1_i);

  assign tag_lookup_m1 = valid_load_lookup_m1 |
                         ((stb_tag_req_m1 | tlb_req_m1 | pf_tag_req_m1) & ~prearb_tag_wr_m1 & prearb_tag_granted_m1);

  assign next_tag_lookup_type_m2 = ({2{valid_load_lookup_m1}}                                       & LOOKUP_LOAD)  |
                                   ({2{prearb_tag_granted_m1 &                     pf_tag_req_m1}}  & LOOKUP_PF)    |
                                   ({2{prearb_tag_granted_m1 &                     tlb_req_m1}}     & LOOKUP_TLB)   |
                                   ({2{prearb_tag_granted_m1 & ~prearb_tag_wr_m1 & stb_tag_req_m1}} & LOOKUP_STB);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      tag_lookup_m2 <= 1'b0;
    else
      tag_lookup_m2 <= tag_lookup_m1;

  always @(posedge clk)
    if (tag_lookup_m1)
      tag_lookup_type_m2 <= next_tag_lookup_type_m2;

  // - The tag used for a lookup comparison will either be the bottom bits of
  // the prearb tag, or the load tag.
  assign load_tag_m1   = {dc_load_tag_ns_dsc_m1_i,
                          dc_load_addr_m1_i[39:14],
                          (dc_load_addr_m1_i[13:11] & ~dc_size_i)};   // Mask bottom bits to zero depending on cache size

  assign lookup_tag_m1 = load_tag_granted_m1 ? load_tag_m1 : prearb_tag_m1[29:0];

  always @(posedge clk)
    if (tag_lookup_m1)
      lookup_tag_m2   <= lookup_tag_m1;

  // Doubleword data read information
  // - The multiplexing on doubleword data reads is timing critical in M2, as
  // for non-sequential loads the tag result must factor into the data RAM
  // output multiplexer, both of which are late in the cycle. To ease the timing
  // on this path, for requests which do not need the way information from the
  // RAM outputs in M2, the bank select is calculated in M1 and pipelined. This
  // applies to sequential loads and CP15 data debug operations. The bank select
  // is masked in M1 if a suitable transaction is not being pipelined to M2, so
  // it does not need to be masked in M2.

  // - When a load in M1 hits in the cache way tracker on an entry for a load
  // whose lookup is in M2, the way comes from the result of that lookup.
  // Otherwise, the sequential way comes from the cache way tracker entry.
  assign seq_load_way_m1  = seq_suppress_data_m1 ? seq_way_m1 : tag_way_comp_m2;

  assign load_data_banksel_m1 = rotate_left_4bit(seq_load_way_m1,    dc_load_addr_m1_i[4:3]);
  assign cp15_data_banksel_m1 = rotate_left_4bit(prearb_data_way_m1, prearb_data_addr01_m1[1:0]);

  assign seq_load_data_granted_m1  = load_data_granted_m1 & ~dc_load_tag_req_only_m1_i & seq_suppress_tag_m1;

  assign dword_data_seq_banksel_m1 = ({4{seq_load_data_granted_m1}}                   & load_data_banksel_m1) |
                                     ({4{prearb_data_granted_m1 & cp15_data_req_m1}}  & cp15_data_banksel_m1);

  // - To further ease timing on this path in M2, the enable term for the
  // non-sequential case is calculated here. The non-sequential path needs to
  // be used for non-sequential loads (characterised by a tag request), and
  // TLB lookups.
  assign dword_data_nseq_sel_m1 = valid_load_lookup_m1 | (prearb_tag_granted_m1 & tlb_req_m1);

  // - enable on any data read, to clock banksel to 0 if not being used
  assign dword_data_m2_en = load_data_granted_m1 | (prearb_data_granted_m1 & ~prearb_data_wr_m1) | ccb_data_granted_m1;

  always @(posedge clk)
    if (dword_data_m2_en) begin
      dword_data_offset_m2      <= dataram_addr01_m1[1:0];  // PA[4:3]
      dword_data_seq_banksel_m2 <= dword_data_seq_banksel_m1;
      dword_data_nseq_sel_m2    <= dword_data_nseq_sel_m1;
    end

  // For STB reads (ECC only), the qword offset needs pipelining to rotate the
  // data with
  // - This cannot simply be determined by looking at any of the data RAM
  // addresses, as STB reads are sequential so use a different address for each
  // of the data RAM banks.
generate if (CPU_CACHE_PROTECTION) begin : g_qword_data_offset_ecc
  assign qword_data_offset_m1 = (|prearb_data_en_m1[7:6] & prearb_data_addr67_m1[1]) | // PA[4]
                                (|prearb_data_en_m1[5:4] & prearb_data_addr45_m1[1]) |
                                (|prearb_data_en_m1[3:2] & prearb_data_addr23_m1[1]) |
                                (|prearb_data_en_m1[1:0] & prearb_data_addr01_m1[1]);

  // The bank select control for STB reads is calculated in M1 and pipelined on
  // seperate flops to allow the STB data output to be data gated when there is
  // no STB read.
  assign qword_data_seq_way_m1 = {4{stb_data_req_m1 & ~prearb_data_wr_m1 & prearb_data_granted_m1}} & prearb_data_way_m1;
  assign qword_data_banksel_m1 = rotate_left_4bit(qword_data_seq_way_m1, {qword_data_offset_m1, 1'b0});

  assign qword_data_m2_en = (prearb_data_granted_m1 & stb_data_req_m1) |
                            // Re-enable when set to clear:
                            (|qword_data_banksel_m2);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      qword_data_banksel_m2 <= 4'b0000;
    else if (qword_data_m2_en)
      qword_data_banksel_m2 <= qword_data_banksel_m1;

end endgenerate

  // Pipeline tag way to use for selecting MBIST and tag debug op data
  assign tag_sel_m2_en    = mbist_en_i | ((prearb_tag_req_type_m1 == REQ_CP15) & prearb_tag_granted_m1);
  // Using m0 pipeline signal in m1 tag_sel as these signals are made from MBIST ARRAY 
  assign next_tag_sel_m2  = (mbist_en_i & mbist_dc_dirty_sel_m0) ? 4'b0001 : (mbist_en_i ? mbist_way_m0 : prearb_tag_way_m1);

  always @(posedge clk)
    if (tag_sel_m2_en)
      tag_sel_m2  <= next_tag_sel_m2;


  //---------------------------------------------------------------------------
  // M2 Lookup Logic
  //---------------------------------------------------------------------------
  // Decode various lookup types for convinience.
  assign load_lookup_m2         = tag_lookup_m2 &  (tag_lookup_type_m2 == LOOKUP_LOAD);
  assign load_or_tlb_tag_req_m2 = tag_lookup_m2 & ((tag_lookup_type_m2 == LOOKUP_LOAD) |
                                                   (tag_lookup_type_m2 == LOOKUP_TLB));
  assign lookup_can_start_lf_m2 = tag_lookup_m2 & ((tag_lookup_type_m2 == LOOKUP_LOAD) |
                                                   (tag_lookup_type_m2 == LOOKUP_TLB)  |
                                                   (tag_lookup_type_m2 == LOOKUP_STB));

  // Get the MOESI bits for each tag RAM into separate signals so can use
  // with tag decode macros.
  assign tagram3_moesi_m2 = dc_tagram_rdata3_i[31:30];
  assign tagram2_moesi_m2 = dc_tagram_rdata2_i[31:30];
  assign tagram1_moesi_m2 = dc_tagram_rdata1_i[31:30];
  assign tagram0_moesi_m2 = dc_tagram_rdata0_i[31:30];


  //---------------
  // Hit Detection
  //---------------
  // Detect the current hit way, which will usually be the result of
  // the lookup currently in M2, however for loads which have gone
  // sequential, it could be the registered hit way which was determined
  // previously.

  // Tag comparison for each way
  assign tag_way_comp_m2 = {({`CA53_TAG_VALID(tagram3_moesi_m2), dc_tagram_rdata3_i[29:0]} == {1'b1, lookup_tag_m2}),
                            ({`CA53_TAG_VALID(tagram2_moesi_m2), dc_tagram_rdata2_i[29:0]} == {1'b1, lookup_tag_m2}),
                            ({`CA53_TAG_VALID(tagram1_moesi_m2), dc_tagram_rdata1_i[29:0]} == {1'b1, lookup_tag_m2}),
                            ({`CA53_TAG_VALID(tagram0_moesi_m2), dc_tagram_rdata0_i[29:0]} == {1'b1, lookup_tag_m2})};

  // Determine which ways are marked as valid (this is only valid when a way
  // has been enabled).
  assign tag_way_valid_m2 = {`CA53_TAG_VALID(tagram3_moesi_m2),
                             `CA53_TAG_VALID(tagram2_moesi_m2),
                             `CA53_TAG_VALID(tagram1_moesi_m2),
                             `CA53_TAG_VALID(tagram0_moesi_m2)};

  // For loads, the hit can be from either a new lookup or the sequential
  // lookup, and either could be suppressed by the BIU.
  assign load_raw_hit_m2 = |(load_lookup_m2 ? tag_way_comp_m2 : dword_data_seq_banksel_m2);
  assign load_hit_m2     = load_raw_hit_m2 & ~biu_suppress_load_hit_dc2_i;  // Load hits are not being suppressed by the BIU


  //-------------------
  // Lookup Miss Logic
  //-------------------
  // When a TLB, STB or Load lookup misses in the cache, it will start
  // a linefill.(Prefetches which miss may also start a linefill, but for
  // these, the BIU will determine itself which way to allocate into).

  // Normally the miss will be detected when the tag lookup is in M2, however
  // it is possible for a sequential load to miss after it has done its
  // lookup, due to the BIU suppressing the hit. This can only happen when
  // the BIU has allocated half of the line into the cache but is stalled
  // waiting for the second half from AXI. In this case a new linefill is not
  // needed, but the cache arbiter returns a miss to the load/store pipe,
  // which will cause it to try and start a linefill, which the BIU will
  // ignore. This causes the load/store pipe to wait for the data to be
  // available from AXI and forwarded from the BIU. As the linefill request
  // is ignored in this case, the victim way indicated doesn't matter.

  // When a victim way is indicated, the lowest invalid way will be chosen,
  // if one is available. If all ways are valid, then the cache arbiter will
  // use a counter to indicate a way, and increment it every time it is used.

  // Determine the lowest way invalid
  assign lowest_way_invalid_m2 = {~tag_way_valid_m2[3] & (&tag_way_valid_m2[2:0]),
                                  ~tag_way_valid_m2[2] & (&tag_way_valid_m2[1:0]),
                                  ~tag_way_valid_m2[1] & tag_way_valid_m2[0],
                                  ~tag_way_valid_m2[0]};

  // If all ways are valid then a counter is used to select the victim way.
  // - The counter is updated whenever a tag lookup in M2 indicates a miss,
  // and will subsequently start a linefill, and a previously invalid way
  // couldn't be found to be used as the victim.
  // - Hits are detected using tag_way_hit, which does not factor in
  // biu_suppress_load_hit, so if there is a hit but it is suppressed by the
  // BIU using that signal then the counter will not be enabled. This is
  // correct, as an actual linefill will not be started in this case, as the
  // BIU is already doing the linefill, it has just not allocated the second
  // half into the cache yet.
  // - If the a non-sequential load misses and starts a linefill, the counter
  // will be updated if all ways are valid. If the sequential state machine
  // gets reset and there is a subsequent sequential load, before the linefill
  // has allocated into the cache, and all ways are still valid then the
  // counter will be enabled again, even though another linefill will not be
  // started. This will happen relatively rarely, so will not cause any issues.
  assign victim_count_en_m2 = (~|tag_way_comp_m2) &   // There is no lookup hit
                              (&tag_way_valid_m2) &   // All the tag ways are valid
                              lookup_can_start_lf_m2; // There is a lookup which will start a linefill in M2:

  assign next_victim_way_count = victim_way_count + 2'b01;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      victim_way_count <= 2'b00;
    else if (victim_count_en_m2)
      victim_way_count <= next_victim_way_count;

  // Indicate the victim way to the TLB/STB/LS Pipe, so they can pass it to
  // the BIU when starting their linefill.
  assign victim_way_m2 = (&tag_way_valid_m2) ? (4'b0001 << victim_way_count)  // All ways are valid, use counter
                                             : lowest_way_invalid_m2;         // Otherwise use the lowest invalid way


  //----------------
  // Lookup Outputs
  //----------------

  // - Load/store
  assign load_lookup_m2_o        = load_lookup_m2;
  assign dc_load_hit_m2_o        = load_hit_m2;
  assign dc_load_raw_hit_m2_o    = load_raw_hit_m2;
  assign dc_load_victim_way_m2_o = `CA53_ONEH4_TO_BIN(victim_way_m2);

  // - TLB
  assign dcu_cache_walk_hit_m2_o        = (|tag_way_comp_m2) & ~biu_suppress_tlb_hit_i;
  assign dcu_cache_walk_victim_way_m2_o = victim_way_m2;

  // - STB
  assign dcu_stb_tag_hit_m2_o       = tag_way_comp_m2;
  assign dcu_stb_tag_migratory_m2_o = ((tag_way_comp_m2[3] & `CA53_TAG_MIGRATORY(tagram3_moesi_m2)) |
                                       (tag_way_comp_m2[2] & `CA53_TAG_MIGRATORY(tagram2_moesi_m2)) |
                                       (tag_way_comp_m2[1] & `CA53_TAG_MIGRATORY(tagram1_moesi_m2)) |
                                       (tag_way_comp_m2[0] & `CA53_TAG_MIGRATORY(tagram0_moesi_m2)));
  assign dcu_stb_victim_way_m2_o    = victim_way_m2;
  assign dcu_stb_tag_shared_m2_o    = |(tag_way_comp_m2 & {`CA53_TAG_SHARED(tagram3_moesi_m2),
                                                           `CA53_TAG_SHARED(tagram2_moesi_m2),
                                                           `CA53_TAG_SHARED(tagram1_moesi_m2),
                                                           `CA53_TAG_SHARED(tagram0_moesi_m2)});

  // - Prefetcher
  assign dcu_pf_tag_hit_m2_o = |tag_way_comp_m2;


  //---------------------------------------------------------------------------
  // M2 Data/Dirty Outputs
  //---------------------------------------------------------------------------

  //-------------------------------------------
  // Loads, TLB Lookups and Data RAM Debug Ops
  //-------------------------------------------
  // These operations read a 64-bit value from a Data RAM bank-pair.
  //
  // TLB lookups will always do a tag lookup in parallel with the data
  // read, and will enable all banks of the data RAM. The data returned to
  // the TLB will then be selected from one of the bank-pairs based on the
  // tag lookup result.
  //
  // Non-sequential loads also read the data RAM in this way, however for
  // sequential loads, only one bank-pair will be enabled as the way is
  // known in advance. The selecting of the data is done in the same way
  // for each.
  //
  // Data RAM debug ops are similar to sequential loads, as the way being
  // looked up is known in advance, however the way is indicated by the CP15
  // block rather than the sequential state machine.

  // Determine the bank-pair containing the data being accessed. This depends
  // on both the way and the lower bits of the address. As this multiplexing
  // is critical, the selection is done separately for non-sequential lookups
  // (TLB and non-sequential loads), and sequential loads and CP15 debug
  // operations.
  assign dword_data_nseq_banksel_m2  = rotate_left_4bit(tag_way_comp_m2, dword_data_offset_m2);

  // - The early banksel is calculated in M1 based on the transaction being
  // pipelined to M2, and is masked when there is not an early source (i.e.
  // a sequential load or CP15 debug op) being pipelined.
  assign dword_data_banksel_m2 = ({4{dword_data_nseq_sel_m2}} & dword_data_nseq_banksel_m2) | // Enable calculated in M1 in correct format to ease timing
                                                                dword_data_seq_banksel_m2;    // Will be zero when not valid, so no need to qualify

  // Select the data from the correct bank-pair
  assign dword_data_m2 = ({64{dword_data_banksel_m2[3]}} & {dc_dataram_rdata7_i[31:0], dc_dataram_rdata6_i[31:0]}) |
                         ({64{dword_data_banksel_m2[2]}} & {dc_dataram_rdata5_i[31:0], dc_dataram_rdata4_i[31:0]}) |
                         ({64{dword_data_banksel_m2[1]}} & {dc_dataram_rdata3_i[31:0], dc_dataram_rdata2_i[31:0]}) |
                         ({64{dword_data_banksel_m2[0]}} & {dc_dataram_rdata1_i[31:0], dc_dataram_rdata0_i[31:0]});

  // Return the data to the TLB and load/store pipe
  assign dc_load_data_m2_o         = dword_data_m2; // For loads and CP15 Data Debug ops
  assign dcu_cache_walk_data_m2_o  = dword_data_m2;


  //---------------
  // STB Read Data
  //---------------
  // When ECC is present, the STB does a read-modify-write when it writes the
  // cache.

generate if (CPU_CACHE_PROTECTION) begin : g_stb_read_data_m2_ecc
  // STB reads are always sequential and are always to 128-bit aligned
  // addresses. They use the same way rotation algorithm as load/TLB data
  // reads (calculated in M1), but read data from four banks rather than two.
  assign dcu_stb_read_data_m2_o = ({128{qword_data_banksel_m2[3]}} & {dc_dataram_rdata1_i[31:0], dc_dataram_rdata0_i[31:0],
                                                                      dc_dataram_rdata7_i[31:0], dc_dataram_rdata6_i[31:0]}) |
                                  ({128{qword_data_banksel_m2[2]}} & {dc_dataram_rdata7_i[31:0], dc_dataram_rdata6_i[31:0],
                                                                      dc_dataram_rdata5_i[31:0], dc_dataram_rdata4_i[31:0]}) |
                                  ({128{qword_data_banksel_m2[1]}} & {dc_dataram_rdata5_i[31:0], dc_dataram_rdata4_i[31:0],
                                                                      dc_dataram_rdata3_i[31:0], dc_dataram_rdata2_i[31:0]}) |
                                  ({128{qword_data_banksel_m2[0]}} & {dc_dataram_rdata3_i[31:0], dc_dataram_rdata2_i[31:0],
                                                                      dc_dataram_rdata1_i[31:0], dc_dataram_rdata0_i[31:0]});

end else begin : g_stb_read_data_m2_no_ecc

  assign dcu_stb_read_data_m2_o = {128{1'b0}};

end endgenerate


  //-------------------
  // Tag RAM Debug Ops
  //-------------------
  // For tag debug operations, the same way is used to access the tag and
  // dirty RAM. As the dirty RAM isn't banked, the way data is selected from
  // a bit slice in the read data.
  // - This is also used for MBIST data, which uses the same path through
  // data_m2 in the lspipe.

  // - Note that as the width of the RAMs depends on whether ECC is present, the
  // data returned also depends on whether ECC is present.
generate if (CPU_CACHE_PROTECTION) begin : g_debug_tag_data_m2_ecc
  assign dc_debug_tag_data_m2_o = ({64{tag_sel_m2[3]}} & {dc_tagram_rdata3_i, {25{1'b0}}, dc_dirtyram_rdata_i[11:10], dc_dirtyram_rdata_i[7:4]})|
                                  ({64{tag_sel_m2[2]}} & {dc_tagram_rdata2_i, {25{1'b0}}, dc_dirtyram_rdata_i[9:8],   dc_dirtyram_rdata_i[3:0]})|
                                  ({64{tag_sel_m2[1]}} & {dc_tagram_rdata1_i, {25{1'b0}}, dc_dirtyram_rdata_i[11:10], dc_dirtyram_rdata_i[7:4]})|
                                  ({64{tag_sel_m2[0]}} & {dc_tagram_rdata0_i, {19{1'b0}}, (mbist_en_i ? dc_dirtyram_rdata_i[11:0]
                                                                                                      : {6'b000000, dc_dirtyram_rdata_i[9:8], dc_dirtyram_rdata_i[3:0]})});

end else begin : g_debug_tag_data_m2_no_ecc
  assign dc_debug_tag_data_m2_o = ({64{tag_sel_m2[3]}} & {1'b0, dc_tagram_rdata3_i, {27{1'b0}}, dc_dirtyram_rdata_i[7:4]})|
                                  ({64{tag_sel_m2[2]}} & {1'b0, dc_tagram_rdata2_i, {27{1'b0}}, dc_dirtyram_rdata_i[3:0]})|
                                  ({64{tag_sel_m2[1]}} & {1'b0, dc_tagram_rdata1_i, {27{1'b0}}, dc_dirtyram_rdata_i[7:4]})|
                                  ({64{tag_sel_m2[0]}} & {1'b0, dc_tagram_rdata0_i, {23{1'b0}}, ({4{mbist_en_i}} & dc_dirtyram_rdata_i[7:4]), dc_dirtyram_rdata_i[3:0]});
end endgenerate


  //---------------
  // Snoop Outputs
  //---------------
  // Snoop requests access a full half line of the data cache by enabling
  // all banks in parallel. Because of the corkscrew effect, the data returned
  // is rotated in 64-bit quantities by 0-3 positions dependent on the way
  // and/or address being accessed. However, the data is not rotated back to
  // its logical order here, to improve timing.
  // - This is also used for MBIST data.
  assign dcu_snoop_data_m2_o = {dc_dataram_rdata7_i[31:0],
                                dc_dataram_rdata6_i[31:0],
                                dc_dataram_rdata5_i[31:0],
                                dc_dataram_rdata4_i[31:0],
                                dc_dataram_rdata3_i[31:0],
                                dc_dataram_rdata2_i[31:0],
                                dc_dataram_rdata1_i[31:0],
                                dc_dataram_rdata0_i[31:0]};

  // The dirty read data is returned to the CCB block in M2, which is requires
  // to determine the response to the snoop request. When ECC is present, the
  // dirty bit is corrected before being sent if there is an error.
generate if (CPU_CACHE_PROTECTION) begin : g_ccb_dirty_ecc
  // Correct the Dirty bit in case of an ECC error
  assign ccb_hit_dirty_m2_o = ({4{ccb_lookup_way_i[3]}} & {dc_dirtyram_rdata_i[7:5], ecc_dirty_bit_err_odd_m2  ^ dc_dirtyram_rdata_i[4]}) |
                              ({4{ccb_lookup_way_i[2]}} & {dc_dirtyram_rdata_i[3:1], ecc_dirty_bit_err_even_m2 ^ dc_dirtyram_rdata_i[0]}) |
                              ({4{ccb_lookup_way_i[1]}} & {dc_dirtyram_rdata_i[7:5], ecc_dirty_bit_err_odd_m2  ^ dc_dirtyram_rdata_i[4]}) |
                              ({4{ccb_lookup_way_i[0]}} & {dc_dirtyram_rdata_i[3:1], ecc_dirty_bit_err_even_m2 ^ dc_dirtyram_rdata_i[0]});

end else begin : g_ccb_dirty_no_ecc

  assign ccb_hit_dirty_m2_o = ({4{ccb_lookup_way_i[3]}} & dc_dirtyram_rdata_i[7:4]) |
                              ({4{ccb_lookup_way_i[2]}} & dc_dirtyram_rdata_i[3:0]) |
                              ({4{ccb_lookup_way_i[1]}} & dc_dirtyram_rdata_i[7:4]) |
                              ({4{ccb_lookup_way_i[0]}} & dc_dirtyram_rdata_i[3:0]);
end endgenerate


  //---------------------------------------------------------------------------
  // ECC Detection & Correction
  //---------------------------------------------------------------------------
generate if (CPU_CACHE_PROTECTION) begin : g_ecc_detect_correct
  // Errors are detected separately for each of the tag, dirty and data RAMs, in
  // either M2 or M3, and an error is selected to be corrected in M3. When there
  // are multiple errors, the logic prioritises a single error to correct.
  //
  // The logic also indicates when there has been an ECC error to the DPU, to
  // update the CPUMERRSR register.
  //
  // Dirty and data errors are not corrected when they are for an invalidating
  // snoop, as the snoop will remove the line so there is nothing to correct.
  // Since corrections cause snoops requests, *only* data/dirty errors for
  // invalidating snoops are indicated to the DPU - this prevents errors being
  // counted twice (once when they are initially detected and correction is
  // started, and again on the snoop which removes them from the cache). Tag
  // errors are always both reported and corrected, as snoops do not read the
  // tag RAM, so do not see tag errors.

  // Enable for registers too small to justify their own clock gate.
  assign ecc_en = tag_lookup_m2 | ccb_dirty_m2_i |
                  valid_ecc_data_read_m1 | valid_ecc_data_read_m2 | valid_ecc_data_read_m3 |
                  ecc_tag_err_m3 | ecc_data_err_m3 | ecc_dirty_err_m3;


  //-----------------
  // ECC for Tag RAM
  //-----------------
  // Check the parity is correct for each tag RAM bank.
  assign ecc_tag_err_way_m2 = {(^dc_tagram_rdata3_i[31:0] != dc_tagram_rdata3_i[32]),
                               (^dc_tagram_rdata2_i[31:0] != dc_tagram_rdata2_i[32]),
                               (^dc_tagram_rdata1_i[31:0] != dc_tagram_rdata1_i[32]),
                               (^dc_tagram_rdata0_i[31:0] != dc_tagram_rdata0_i[32])};

  assign ecc_tag_err_m2  = (|ecc_tag_err_way_m2) & tag_lookup_m2;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ecc_tag_err_m3 <= 1'b0;
    else if (ecc_en)
      ecc_tag_err_m3 <= ecc_tag_err_m2;


  //-------------------
  // ECC for Dirty RAM
  //-------------------

  // Calculate if there is an error in any of the dirty bits in the dirty RAM
  // (used for deciding whether there is an error).
  assign ecc_dirty_err_even_m2     = (dc_dirtyram_rdata_i[9]  != dc_dirtyram_rdata_i[8])  | (dc_dirtyram_rdata_i[9]  != dc_dirtyram_rdata_i[0]);
  assign ecc_dirty_err_odd_m2      = (dc_dirtyram_rdata_i[11] != dc_dirtyram_rdata_i[10]) | (dc_dirtyram_rdata_i[11] != dc_dirtyram_rdata_i[4]);

  // Calculate if there is an error in the dirty bit (i.e. the dirty copies
  // agree with each other, but the main dirty bit is different). Used for
  // correcting the dirty bit as it is sent to the CCB block.
  assign ecc_dirty_bit_err_even_m2 = (dc_dirtyram_rdata_i[9]  == dc_dirtyram_rdata_i[8])  & (dc_dirtyram_rdata_i[9]  != dc_dirtyram_rdata_i[0]);
  assign ecc_dirty_bit_err_odd_m2  = (dc_dirtyram_rdata_i[11] == dc_dirtyram_rdata_i[10]) & (dc_dirtyram_rdata_i[11] != dc_dirtyram_rdata_i[4]);

  // - Ignore dirty reads for Make Invalid snoops for ECC correction, as these
  // can be sent for lines which are not actually in the cache
  assign ecc_dirty_err_m2          = ccb_dirty_m2_i & ~ccb_ecc_make_inv_i &
                                     ((ecc_dirty_err_odd_m2  & (ccb_lookup_way_i[3] | ccb_lookup_way_i[1])) |
                                      (ecc_dirty_err_even_m2 & (ccb_lookup_way_i[2] | ccb_lookup_way_i[0])));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ecc_dirty_err_m3    <= 1'b0;
    else if (ecc_en)
      ecc_dirty_err_m3    <= ecc_dirty_err_m2;

  // Pipeline when an invalidating snoop is in M3, as this determines whether a
  // dirty or data error is corrected.
  always @(posedge clk)
    if (ecc_en)
      ccb_inv_snoop_m3  <= ccb_inv_snoop_m2_i;

  // Indicate there is an ECC error in Dirty RAM:
  // - which should be corrected
  assign ecc_dirty_err_correct_m3 = ecc_dirty_err_m3 & ~ccb_inv_snoop_m3;
  // - which should be reported in CPUMERRSR in DPU
  assign ecc_dirty_err_merrsr_m3  = ecc_dirty_err_m3 &  ccb_inv_snoop_m3;


  //------------------
  // ECC for Data RAM
  //------------------
  // For the data RAM, the syndrome is calculated for each bank in M2, then
  // pipelined to M3 where errors are detected based on the syndrome.

  // Register when there is a data read which could cause ECC correction in M2
  // or M3
  // - only consider requests which will not be dropped
  assign valid_ecc_data_read_m1 = (load_data_granted_m1 & dc_valid_load_req_m1_i)  |
                                  (ccb_data_granted_m1  & ccb_valid_data_req_m1_i) |
                                  (prearb_data_granted_m1 & ~prearb_data_wr_m1 & (stb_data_req_m1 | tlb_req_m1));

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      valid_ecc_data_read_m2 <= 1'b0;
      valid_ecc_data_read_m3 <= 1'b0;
    end else if (ecc_en) begin
      valid_ecc_data_read_m2 <= valid_ecc_data_read_m1;
      valid_ecc_data_read_m3 <= valid_ecc_data_read_m2;
    end

  // Pipeline which banks of the dataram have been read, to qualify the syndrome
  // with.
  assign next_ecc_data_bank_read_m2 = ({8{dc_valid_load_req_m1_i}} & load_data_en_m1)   |
                                      ({8{prearb_data_granted_m1}} & prearb_data_en_m1) |
                                      ({8{ccb_data_granted_m1}}    & 8'b11111111);  // CCB always reads all banks

  // - On non-sequential reads, this is updated in M2 based on which way
  // actually hit, so that only errors in ways which actually contain data used
  // are recognised by the logic.
  assign tlb_req_m2 = tag_lookup_m2 & (tag_lookup_type_m2 == LOOKUP_TLB);

  assign next_ecc_data_bank_read_m3 = ecc_data_bank_read_m2 &
                                      // Ignore data RAM if hit suppressed by BIU:
                                      ({8{~((load_req_m2 & biu_suppress_load_hit_dc2_i) |
                                            (tlb_req_m2  & biu_suppress_tlb_hit_i))}}) &
                                      // Clear enable for banks which do not hit:
                                      ({8{~(load_req_m2 | tlb_req_m2)}} |
                                       ({ {2{dword_data_banksel_m2[3]}},
                                          {2{dword_data_banksel_m2[2]}},
                                          {2{dword_data_banksel_m2[1]}},
                                          {2{dword_data_banksel_m2[0]}} }));

  always @(posedge clk)
    if (valid_ecc_data_read_m1) begin
      ecc_data_bank_read_m2     <= next_ecc_data_bank_read_m2;
      load_req_m2               <= load_data_granted_m1;
      ccb_data_req_m2           <= ccb_data_granted_m1;
    end

  always @(posedge clk)
    if (valid_ecc_data_read_m2) begin
      ecc_data_bank_read_m3     <= next_ecc_data_bank_read_m3;
      ccb_data_req_m3           <= ccb_data_req_m2;
    end

  // Calculate the syndrome for each bank in parallel in M2
  ca53_ecc_check32 u_ecc_check0 (.data_i     (dc_dataram_rdata0_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata0_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[0]));

  ca53_ecc_check32 u_ecc_check1 (.data_i     (dc_dataram_rdata1_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata1_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[1]));

  ca53_ecc_check32 u_ecc_check2 (.data_i     (dc_dataram_rdata2_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata2_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[2]));

  ca53_ecc_check32 u_ecc_check3 (.data_i     (dc_dataram_rdata3_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata3_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[3]));

  ca53_ecc_check32 u_ecc_check4 (.data_i     (dc_dataram_rdata4_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata4_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[4]));

  ca53_ecc_check32 u_ecc_check5 (.data_i     (dc_dataram_rdata5_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata5_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[5]));

  ca53_ecc_check32 u_ecc_check6 (.data_i     (dc_dataram_rdata6_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata6_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[6]));

  ca53_ecc_check32 u_ecc_check7 (.data_i     (dc_dataram_rdata7_i[31:0]),
                                 .ecc_i      (dc_dataram_rdata7_i[38:32]),
                                 .syndrome_o (ecc_data_syndrome_m2[7]));

  // - Pipeline to M3 for detection
  assign ecc_data_syndrome_m3_en = {8{valid_ecc_data_read_m2}} & ecc_data_bank_read_m2[7:0];

  for (data_bank=0; data_bank<8; data_bank=data_bank+1) begin : g_ecc_syndrome_m3

    always @(posedge clk)
      if (ecc_data_syndrome_m3_en[data_bank])
        raw_ecc_data_syndrome_m3[data_bank] <= ecc_data_syndrome_m2[data_bank];

  end

  // Send syndrome information to BIU in M3 to use on snoop data (reads all
  // banks so no need to qualify)
  assign dcu_ecc_syndrome_m3_o = {raw_ecc_data_syndrome_m3[7], raw_ecc_data_syndrome_m3[6],
                                  raw_ecc_data_syndrome_m3[5], raw_ecc_data_syndrome_m3[4],
                                  raw_ecc_data_syndrome_m3[3], raw_ecc_data_syndrome_m3[2],
                                  raw_ecc_data_syndrome_m3[1], raw_ecc_data_syndrome_m3[0]};

  // Detect and indicate if an error is fatal
  for (data_bank=0; data_bank<8; data_bank=data_bank+1) begin : g_ecc_fatal_m3
    ca53_ecc_fatal32 u_data_ecc_ccb_fatal (.syndrome_i (raw_ecc_data_syndrome_m3[data_bank]),
                                           .fatal_o    (raw_ecc_data_fatal_m3[data_bank]));
  end

  // - used on snoop requests, which always enable all banks, so can use
  // unqualified signal
  assign ecc_data_is_fatal_m3 = |raw_ecc_data_fatal_m3;
  assign dcu_ecc_fatal_m3_o   = ecc_data_is_fatal_m3;

  // Qualify syndrome with whether that data RAM bank was read
  for (data_bank=0; data_bank<8; data_bank=data_bank+1) begin : g_ecc_syndrome_qual
    assign ecc_data_syndrome_m3[data_bank] = raw_ecc_data_syndrome_m3[data_bank] & {7{ecc_data_bank_read_m3[data_bank]}};
  end

  // Indicate there is an ECC error in Data RAM
  // - A bank has an error in it if its syndrome is non-zero
  assign ecc_data_err_bank_m3 = {|ecc_data_syndrome_m3[7], |ecc_data_syndrome_m3[6],
                                 |ecc_data_syndrome_m3[5], |ecc_data_syndrome_m3[4],
                                 |ecc_data_syndrome_m3[3], |ecc_data_syndrome_m3[2],
                                 |ecc_data_syndrome_m3[1], |ecc_data_syndrome_m3[0]} &
                                {8{valid_ecc_data_read_m3}};

  // - There is a data error if there is an error in any bank
  assign ecc_data_err_m3 = |ecc_data_err_bank_m3;

  // Indicate there is an ECC error in Data RAM:
  // - which should be corrected
  assign ecc_data_err_correct_m3 = ecc_data_err_m3 & ~(ccb_data_req_m3 & ccb_inv_snoop_m3);
  // - which should be reported in CPUMERRSR in DPU
  assign ecc_data_err_merrsr_m3  = ecc_data_err_m3 &  (ccb_data_req_m3 & ccb_inv_snoop_m3);


  //------------------
  // Error correction
  //------------------
  // When there are multiple errors, the cachearb must pick one to be corrected.
  // - Tag errors are given highest priority as if there is a tag error,
  // non-sequential data reads do not know which way to select data from, so
  // data errors cannot always be calculated if there is a tag error.
  // - Data errors are the next highest priority.
  // - Dirty errors are lowest priority.
  //
  // Note there is no need to prioritise data errors over dirty errors, but for
  // simplicity a fixed priority is used.
  //
  // Tag errors are detected in M2 and prioritised over dirty errors there. The
  // prioritised error is then pipelined to M3, where it is prioritised with
  // data errors (which are detected in M3).

  // Pipeline the tag and data index from M1 to use in case of an error (the
  // dirty address does not need to be pipelined, as it is only used on CCB
  // requests and the CCB lookup address is still available in M2).
  always @(posedge clk)
    if (tag_lookup_m1)
      tag_index_m2 <= tagram_addr_m1;

  assign data_seq_way_m1 = ({4{seq_load_data_granted_m1}} & seq_load_way_m1) |
                           ({4{prearb_data_granted_m1}}   & prearb_data_way_m1);

  assign data_seq_way_bin_m1 = `CA53_ONEH4_TO_BIN(data_seq_way_m1);

  always @(posedge clk)
    if (valid_ecc_data_read_m1) begin
      data_index_m2       <= dataram_addr01_m1[10:0]; // PA [13:3]
      data_seq_way_bin_m2 <= data_seq_way_bin_m1;
    end

  // Form the way being read in M2 for data reads
  // - on a non-sequential lookup this will be the hit way, otherwise it is the
  // way pipelined from M1.
  assign tag_way_comp_bin_m2 = `CA53_ONEH4_TO_BIN(tag_way_comp_m2);

  assign data_way_bin_m2 = load_or_tlb_tag_req_m2 ? tag_way_comp_bin_m2 : data_seq_way_bin_m2;

  // Select the tag way in M2
  // - It is possible to get simulteneous errors in different ways of the tag RAM,
  // in which case the DCU must select a way to be corrected. Since the hit/miss
  // result is not valid on an error, the logic just picks the lowest way with
  // an error to correct.
  // - All tag reads are non-sequential, so all ways are valid on read. Therefore
  // just need to select lowest way with an error to decide which way to
  // correct.
  assign lowest_way_tag_err_m2 = {ecc_tag_err_way_m2[3] & (~|ecc_tag_err_way_m2[2:0]),
                                  ecc_tag_err_way_m2[2] & (~|ecc_tag_err_way_m2[1:0]),
                                  ecc_tag_err_way_m2[1] &   ~ecc_tag_err_way_m2[0],
                                  ecc_tag_err_way_m2[0]};

  // Prioritise between tag and dirty errors in M2
  // - mask top bits of address for smaller cache sizes
  assign ecc_tag_dirty_index_m2  = (ecc_tag_err_m2 ? tag_index_m2      :
                                                     ccb_lookup_addr_i) & {dc_size_i, 5'b11111};

  assign ecc_tag_dirty_way_m2    = ecc_tag_err_m2 ? lowest_way_tag_err_m2 :
                                                    ccb_lookup_way_i;

  // - to save area, the correction way is binary encoded before being pipelined
  assign ecc_tag_dirty_way_bin_m2 = `CA53_ONEH4_TO_BIN(ecc_tag_dirty_way_m2);

  // Pipeline error information to M3
  // - enable when a transaction in M2 which may generate an error
  assign ecc_tag_dirty_m3_en = tag_lookup_m2 | ccb_dirty_m2_i;

  always @(posedge clk)
    if (ecc_tag_dirty_m3_en) begin
      ecc_tag_dirty_index_m3   <= ecc_tag_dirty_index_m2;
      ecc_tag_dirty_way_m3     <= ecc_tag_dirty_way_bin_m2;
    end

  // - have not yet prioritised data errors, so pipeline data index/way
  // separately
  // - mask top bits of address for smaller cache sizes
  assign next_data_index_m3 = data_index_m2 & {dc_size_i, 8'b11111111};
  always @(posedge clk)
    if (valid_ecc_data_read_m2) begin
      data_index_m3 <= next_data_index_m3;
      data_way_m3   <= data_way_bin_m2;
    end

  // Prioritise error to correct in M3
  assign ecc_correction_index_m3 = ecc_tag_err_m3           ? ecc_tag_dirty_index_m3  : // Tag
                                   ecc_data_err_correct_m3  ? data_index_m3[13:6]     : // Data
                                                              ecc_tag_dirty_index_m3;   // Dirty

  assign ecc_correction_way_m3   = ecc_tag_err_m3           ? ecc_tag_dirty_way_m3    :
                                   ecc_data_err_correct_m3  ? data_way_m3             :
                                                              ecc_tag_dirty_way_m3;

  // Indicate there is an ECC error which needs correction to start the ECC
  // correction state machine.
  assign ecc_err_correct_m3 = ecc_tag_err_m3            |  // Tag errors always corrected
                              ecc_data_err_correct_m3   |
                              ecc_dirty_err_correct_m3;


  // Instantiate ECC correction state machine block
  ca53dcu_ecc_correction u_ecc_correction (
    // Inputs
    .clk                      (clk),
    .reset_n                  (reset_n),
    .ecc_err_i                (ecc_err_correct_m3),
    .ecc_err_index_i          (ecc_correction_index_m3[7:0]),
    .ecc_err_way_i            (ecc_correction_way_m3[1:0]),
    .ecc_cinv_ack_i           (biu_ecc_cinv_ack_i),
    .ecc_cinv_complete_i      (biu_ecc_cinv_complete_i),
    // Outputs
    .ecc_cinv_index_o         (dcu_ecc_cinv_index_o[7:0]),
    .ecc_cinv_req_o           (dcu_ecc_cinv_req_o),
    .ecc_cinv_way_o           (dcu_ecc_cinv_way_o[1:0]),
    .ecc_in_progress_o        (ecc_in_progress)
  );  // u_ecc_correction


  //----------------------------
  // Indicate ECC errors to DPU
  //----------------------------
  // These signals are to update the CPU Memory Error Syndrome Register
  // (CPUMERRSR) which is used for recording ECC errors on all CPU RAMs

  // Indicate that there is an ECC error on the L1 Data cache RAMs.
  assign dcu_ecc_valid_o  = ecc_tag_err_m3 | ecc_data_err_merrsr_m3 | ecc_dirty_err_merrsr_m3;

  // Indicate the RAM where the prioritised memory error occured
  // -2'b00 L1 Tag RAM
  // -2'b01 L1 Data RAM
  // -2'b10 L1 Dirty RAM
  // -2'b11 Illegal
  assign dcu_ecc_ramid_o = ecc_tag_err_m3         ? 2'b00 :
                           ecc_data_err_merrsr_m3 ? 2'b01 :
                                                    2'b10;

  // Indicate that there is a non correctable ECC error
  // - only possible on data errors
  assign dcu_ecc_fatal_o = ecc_data_err_merrsr_m3 & ecc_data_is_fatal_m3 &
                           // Data errors are lower priority than tag errors:
                           ~ecc_tag_err_m3;

  // Select bank to indicate to DPU on data error
  // - Select lowest way with fatal error if there is a fatal error, otherwise
  // select lowest way with an error
  always @*
    case (raw_ecc_data_fatal_m3)
      8'b0000_0000,
      `ca53dcu_sel_xxxx_xxx1 : lowest_bank_data_fatal_m3 = 3'b000;
      `ca53dcu_sel_xxxx_xx10 : lowest_bank_data_fatal_m3 = 3'b001;
      `ca53dcu_sel_xxxx_x100 : lowest_bank_data_fatal_m3 = 3'b010;
      `ca53dcu_sel_xxxx_1000 : lowest_bank_data_fatal_m3 = 3'b011;
      `ca53dcu_sel_xxx1_0000 : lowest_bank_data_fatal_m3 = 3'b100;
      `ca53dcu_sel_xx10_0000 : lowest_bank_data_fatal_m3 = 3'b101;
      `ca53dcu_sel_x100_0000 : lowest_bank_data_fatal_m3 = 3'b110;
      8'b1000_0000           : lowest_bank_data_fatal_m3 = 3'b111;
      default                : lowest_bank_data_fatal_m3 = 3'bxxx;
    endcase

  always @*
    case (ecc_data_err_bank_m3)
      8'b0000_0000,
      `ca53dcu_sel_xxxx_xxx1 : lowest_bank_data_err_m3   = 3'b000;
      `ca53dcu_sel_xxxx_xx10 : lowest_bank_data_err_m3   = 3'b001;
      `ca53dcu_sel_xxxx_x100 : lowest_bank_data_err_m3   = 3'b010;
      `ca53dcu_sel_xxxx_1000 : lowest_bank_data_err_m3   = 3'b011;
      `ca53dcu_sel_xxx1_0000 : lowest_bank_data_err_m3   = 3'b100;
      `ca53dcu_sel_xx10_0000 : lowest_bank_data_err_m3   = 3'b101;
      `ca53dcu_sel_x100_0000 : lowest_bank_data_err_m3   = 3'b110;
      8'b1000_0000           : lowest_bank_data_err_m3   = 3'b111;
      default                : lowest_bank_data_err_m3   = 3'bxxx;
    endcase

  assign ecc_data_bank_m3 = ecc_data_is_fatal_m3 ? lowest_bank_data_fatal_m3
                                                 : lowest_bank_data_err_m3;

  // Indicate which bank/way of the RAM produced the first memory error
  assign dcu_ecc_way_bank_id_o = ecc_tag_err_m3         ? {1'b0, ecc_tag_dirty_way_m3} :  // Tag error
                                 ecc_data_err_merrsr_m3 ? ecc_data_bank_m3             :  // Data error
                                                          3'b000;                         // Dirty error

  // Indicate the index address of the first memory error
  // - The full width is only used on data errors, with the top bits zero padded
  // where not required.
  // - For the dirty RAM the bottom bit of the RAM address comes from the way.
  // - The lower bits on data errors correspond to the address read from the
  // bank which has the error. Note only the address for bank 0 is pipelined, so
  // for other banks the bottom bits need to be calculated based on the
  // corkscrew used for sequential reads. Each bank-pair reads the same address,
  // and the addresses increment in a wrapping fashion on incrementing
  // bank-pairs.
  always @*
    case (ecc_data_bank_m3)
      3'b000, 3'b001: data_index_adj_m3 = 2'b00;
      3'b010, 3'b011: data_index_adj_m3 = 2'b01;
      3'b100, 3'b101: data_index_adj_m3 = 2'b10;
      3'b110, 3'b111: data_index_adj_m3 = 2'b11;
      default       : data_index_adj_m3 = 2'bxx;
    endcase
  assign ecc_data_bank_offset_m3 = data_index_m3[4:3] + data_index_adj_m3;

  assign dcu_ecc_index_o = ecc_tag_err_m3         ? {3'b000, ecc_tag_dirty_index_m3}                :
                           ecc_data_err_merrsr_m3 ? {data_index_m3[13:5], ecc_data_bank_offset_m3}  :
                                                    {2'b00, ecc_tag_dirty_index_m3, ecc_tag_dirty_way_m3[1]};


  //-------------------------
  // Outputs to other blocks
  //-------------------------

  // Indicate to the load/store pipe when there is an ECC error in a load
  // - keep this asserted whilst the ECC correction state machine is active, to
  // ensure that any loads already in the pipeline behind the load which got the
  // error also see an error, as they may hit in the cache way tracker before it
  // is flushed and so not do a new tag lookup (such loads will normally be
  // flushed by the DPU but will not be if the inital load is cc failed).
  // - note that a tag error in M3 may not be for a load in M3 (if it was ~first
  // and issued with a prearb tag read), but since errors are reported whenever
  // any error is being corrected anyway this is not a problem.
  assign dc_ecc_err_m3_o = ecc_data_err_correct_m3 | ecc_tag_err_m3 | ecc_in_progress;

  // Indicate to the load/store pipe when there is a tag error in M2, to use for
  // suppressing DC1 linefills.
  assign dc_ecc_tag_err_m2_o = ecc_tag_err_m2;

  // Indicate tag ECC error to STB in M2
  assign dcu_ecc_tag_err_m2_o = ecc_tag_err_m2;

  // Indicate tag ECC error to BIU in M3
  assign dcu_ecc_tag_err_m3_o = ecc_tag_err_m3;

  // Indicate to the STB when there is an ECC error in Data
  assign dcu_ecc_data_err_m3_o = ecc_data_err_correct_m3;

  // Indicate the TLB when there is an ECC error in Data or Tag
  assign dcu_ecc_err_m3_o = ecc_data_err_correct_m3 | ecc_tag_err_m3;

  // Indicate when ECC correction is in progress or starting
  assign dcu_ecc_in_progress_o = ecc_in_progress | ecc_err_correct_m3;

  // Mux ECC data from data RAM for MBIST
  // - note MBIST bank does not need pipelining, so can use M0 signal
  assign dcu_mbist_data_checkbits_mb6_o = ({7{mbist_en_i & mbist_bank_m0[0]}} & dc_dataram_rdata0_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[1]}} & dc_dataram_rdata1_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[2]}} & dc_dataram_rdata2_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[3]}} & dc_dataram_rdata3_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[4]}} & dc_dataram_rdata4_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[5]}} & dc_dataram_rdata5_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[6]}} & dc_dataram_rdata6_i[38:32]) |
                                          ({7{mbist_en_i & mbist_bank_m0[7]}} & dc_dataram_rdata7_i[38:32]);

end else begin : g_ecc_detect_correct_no_ecc

  assign dcu_ecc_tag_err_m2_o           = 1'b0;
  assign dcu_ecc_tag_err_m3_o           = 1'b0;
  assign dc_ecc_err_m3_o                = 1'b0;
  assign dc_ecc_tag_err_m2_o            = 1'b0;
  assign dcu_ecc_err_m3_o               = 1'b0;
  assign dcu_ecc_data_err_m3_o          = 1'b0;
  assign dcu_ecc_fatal_m3_o             = 1'b0;
  assign dcu_ecc_syndrome_m3_o          = {56{1'b0}};
  assign dcu_ecc_in_progress_o          = 1'b0;
  assign dcu_ecc_cinv_index_o           = {8{1'b0}};
  assign dcu_ecc_cinv_req_o             = 1'b0;
  assign dcu_ecc_cinv_way_o             = 2'b00;
  assign dcu_mbist_data_checkbits_mb6_o = {7{1'b0}};
  assign dcu_ecc_valid_o                = 1'b0;
  assign dcu_ecc_fatal_o                = 1'b0;
  assign dcu_ecc_ramid_o                = 2'b00;
  assign dcu_ecc_way_bank_id_o          = 3'b000;
  assign dcu_ecc_index_o                = {11{1'b0}};
  assign ecc_err_correct_m3             = 1'b0;
  assign ecc_in_progress                = 1'b0;

end endgenerate


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // When there are interdependent prearb requests in M1, the timeout counters
  // for the interdependent resources must be the same
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Interdependent prearb timeout counter mismatch: Tag+Data")
  u_ovl_timeout_tag_data   (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (prearb_tag_req_m1 & prearb_data_needs_tag_m1),
                            .consequent_expr (prearb_tag_count_m1 == prearb_data_count_m1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Interdependent prearb timeout counter mismatch: Tag+Dirty")
  u_ovl_timeout_tag_dirty  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (prearb_tag_req_m1 & prearb_tag_needs_dirty_m1),
                            .consequent_expr (prearb_tag_count_m1 == prearb_dirty_count_m1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Interdependent prearb timeout counter mismatch: Data+Dirty")
  u_ovl_timeout_data_dirty (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (prearb_data_req_m1 & prearb_data_needs_dirty_m1),
                            .consequent_expr (prearb_data_count_m1 == prearb_dirty_count_m1));

  // When a load request is throttled there should not be a load request on the next cycle
  reg ovl_load_throttled;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_load_throttled <= 1'b0;
    else
      ovl_load_throttled <= dc_throttle_loads_o;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Load request when throttled")
  u_ovl_load_throttle_req  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_load_throttled),
                            .consequent_expr (~dc_load_req_m1_i));

  // When a snoop request is throttled, it can take up to 3 cycles for the
  // request to drain.
  reg ovl_snoop_throttled_0;
  reg ovl_snoop_throttled_1;
  reg ovl_snoop_throttled_2;
  reg ovl_snoop_throttled_3;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_snoop_throttled_0 <= 1'b0;
      ovl_snoop_throttled_1 <= 1'b0;
      ovl_snoop_throttled_2 <= 1'b0;
      ovl_snoop_throttled_3 <= 1'b0;
    end else begin
      ovl_snoop_throttled_0 <= dc_throttle_snoops_o;
      ovl_snoop_throttled_1 <= ovl_snoop_throttled_0;
      ovl_snoop_throttled_2 <= ovl_snoop_throttled_1;
      ovl_snoop_throttled_3 <= ovl_snoop_throttled_2;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop data request when throttled")
  u_ovl_ccb_data_throttle  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_snoop_throttled_0 & ovl_snoop_throttled_1 & ovl_snoop_throttled_2 & ovl_snoop_throttled_3),
                            .consequent_expr (~ccb_data_req_m1_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop block_prearb_tag when throttled")
  u_ovl_ccb_tag_throttle (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_snoop_throttled_0 & ovl_snoop_throttled_1 & ovl_snoop_throttled_2),
                            .consequent_expr (~ccb_block_prearb_tag_m1_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop dirty request when throttled")
  u_ovl_ccb_dirty_throttle (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_snoop_throttled_0 & ovl_snoop_throttled_1 & ovl_snoop_throttled_2),
                            .consequent_expr (~ccb_dirty_req_m1_i));

  // Snoops should never make back to back tag requests for more than 2 cycles
  reg ovl_prev_ccb_tag_reg_0;
  reg ovl_prev_ccb_tag_reg_1;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prev_ccb_tag_reg_0 <= 1'b0;
      ovl_prev_ccb_tag_reg_1 <= 1'b0;
    end else begin
      ovl_prev_ccb_tag_reg_0 <= ccb_tag_req_m1_i;
      ovl_prev_ccb_tag_reg_1 <= ovl_prev_ccb_tag_reg_0;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "More than 2 back to back snoop tag requests")
  u_ovl_ccb_tag_back2back  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_prev_ccb_tag_reg_0 & ovl_prev_ccb_tag_reg_1),
                            .consequent_expr (~ccb_tag_req_m1_i));

  // The CCB block should only make a tag request when it is asserting
  // block_prearb_tag, so it is not necessary to factor both into the throttle
  // logic.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "CCB tag req without block_prearb_tag")
  u_ovl_ccb_tag_req_block  (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ccb_tag_req_m1_i),
                            .consequent_expr (ccb_block_prearb_tag_m1_i));


  // Can have 3 cycle with throttle asserted before snoops drain
  reg [3:0] ovl_prearb_data_stall_count;
  reg [3:0] ovl_prearb_dirty_stall_count;
  reg [3:0] ovl_prearb_tag_stall_count;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_prearb_data_stall_count   <= {4{1'b0}};
      ovl_prearb_dirty_stall_count  <= {4{1'b0}};
      ovl_prearb_tag_stall_count    <= {4{1'b0}};
    end else begin
      ovl_prearb_data_stall_count   <= data_req_outstanding_m1  ? (ovl_prearb_data_stall_count  + 1'b1) : {4{1'b0}};
      ovl_prearb_dirty_stall_count  <= dirty_req_outstanding_m1 ? (ovl_prearb_dirty_stall_count + 1'b1) : {4{1'b0}};
      ovl_prearb_tag_stall_count    <= tag_req_outstanding_m1   ? (ovl_prearb_tag_stall_count   + 1'b1) : {4{1'b0}};
    end

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Prearb data request stalled longer than theoretical maximum")
  u_ovl_prearb_data_stall_max      (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_prearb_data_stall_count <= (TIMEOUT_CNT + 3)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Prearb dirty request stalled longer than theoretical maximum")
  u_ovl_prearb_dirty_stall_max     (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_prearb_dirty_stall_count <= (TIMEOUT_CNT + 3)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Prearb tag request stalled longer than theoretical maximum")
  u_ovl_prearb_tag_stall_max       (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (ovl_prearb_tag_stall_count <= (TIMEOUT_CNT + 3)));

  // There can never be a CCB/load request into the cache arbiter on the
  // cycle after the last invalidate all on reset M0 request (i.e .the M1 for
  // the last request), so the CP15 block does not need to explicitly block
  // them in this case.
  reg ovl_inv_all_m1;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_inv_all_m1 <= 1'b0;
    else
      ovl_inv_all_m1 <= dc_inv_all_in_progress_i & cp15_tag_req_m0_i;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Load/CCB request during invalidate all on reset M1")
  u_ovl_inv_all_m1_arb    (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (ovl_inv_all_m1),
                           .consequent_expr (~(ccb_tag_req_m1_i | dc_load_req_m1_i)));

  // Load way caching

  // - There should never be two valid entries for the same address
  // - Assert this by having N^2 asserts (for N entries), to compare each
  // entry against every other entry.
  genvar entry;
  genvar other_entry;
  generate
    for (entry=0; entry<SEQ_STATE_ENTRIES; entry=entry+1) begin : g_seq_state_ovl_outer
      wire [48:6] entry_addr  = g_seq_state[entry].u_seq_state_entry.seq_addr;
      wire [1:0]  entry_state = g_seq_state[entry].u_seq_state_entry.state;

      for (other_entry=0; other_entry<SEQ_STATE_ENTRIES; other_entry=other_entry+1) begin : g_seq_state_ovl_inner
        wire [48:6] other_entry_addr  = g_seq_state[other_entry].u_seq_state_entry.seq_addr;
        wire [1:0]  other_entry_state = g_seq_state[other_entry].u_seq_state_entry.state;

        assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Two valid seq state entries with same address")
        u_ovl_seq_state_same_addr  (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr ((|entry_state) & (|other_entry_state) &
                                                      (entry != other_entry)),  // Don't compare with self
                                    .consequent_expr (entry_addr != other_entry_addr));
      end
    end
  endgenerate

  // - Round-robin victim selection should ensure that a valid entry is never
  // overwritten when there is a spare invalid entry
  wire [SEQ_STATE_ENTRIES-1:0] ovl_seq_entry_valid;
  generate for (entry=0; entry<SEQ_STATE_ENTRIES; entry=entry+1) begin : g_seq_state_ovl_entry_valid
    assign ovl_seq_entry_valid[entry] = |g_seq_state[entry].u_seq_state_entry.state;
  end endgenerate

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "When overwriting valid seq state entry, must not have invalid entry available")
  u_ovl_seq_state_overwrite_valid  (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (|(ovl_seq_entry_valid & start_seq_entry_m1)),
                                    .consequent_expr (&ovl_seq_entry_valid));

  // - lspipe should only indicate valid load when there is a load request
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lspipe should only indicate load when there is a load request")
  u_ovl_dc_valid_load_req_m1_request       (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (dc_valid_load_req_m1_i),
                                            .consequent_expr (dc_load_req_m1_i));

  // - lspipe should never make tag_only request for final load req
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lspipe should never make tag_only valid_load_req")
  u_ovl_dc_valid_load_tag_only_req         (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (dc_valid_load_req_m1_i),
                                            .consequent_expr (~dc_load_tag_req_only_m1_i));

  // - When the cache way tracker misses, the sequential way should be set to
  // 4'b1111, to indicate non-sequential
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "When cache way tracker misses, should set way to 4'b1111 (non-seq)")
  u_ovl_seq_way_set_on_miss                (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (dc_load_req_m1_i & ~seq_suppress_data_m1),
                                            .consequent_expr (seq_way_m1 == 4'b1111));

  // - When the cache way tracker misses, the load enable should be for
  // non-sequential
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "When cache way tracker misses, load enable should be correct for non-sequential load")
  u_ovl_load_enable_seq_way_miss           (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (dc_load_req_m1_i & ~dc_load_tag_req_only_m1_i & ~seq_suppress_data_m1 & load_data_granted_m1),
                                            .consequent_expr (dataram_en_m1 == nonseq_load_data_en_m1));

  // - The logic to combine the load and early dataram enables relies on the load
  // enable being qualified such that it doesn't need to qualify it where the
  // signals are combined.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "When early load request granted, should not set load data enable")
  u_ovl_load_enable_not_granted            (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (|early_dataram_en_m1),
                                            .consequent_expr (~|load_data_en_m1));

  // - MBIST request types are one hot between resources (cannot have MBIST tag and
  // data at same time etc).
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "MBIST can only be applied to one resource at a time")
  u_ovl_mbist_onehot (.clk       (clk),
                      .reset_n   (reset_n),
                      .test_expr ({mbist_tag_req_m0,
                                   mbist_data_req_m0,
                                   mbist_dirty_req_m0}));

  // - Allocations should be granted access to whatever they request
  // simultaneously.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M0 Request Interdependency - Allocations")
  u_ovl_interdep_m0_alloc (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (alloc_tag_granted_m0 | alloc_dirty_granted_m0 | alloc_data_granted_m0),  // An allocation request has been granted
                           .consequent_expr ((alloc_tag_granted_m0   | ~biu_alloc_tag_req_m0_i)   & // Tag granted or not requested
                                             (alloc_dirty_granted_m0 | ~biu_alloc_dirty_req_m0_i) &
                                             (alloc_data_granted_m0  | ~biu_alloc_data_req_m0_i)));

  // - TLB lookups should be granted access to both the tag and data
  // simultaneously
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M0 Request Interdependency - TLB")
  u_ovl_interdep_m0_tlb   (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (tlb_granted_m0),
                           .consequent_expr ((tag_req_type_m0 == REQ_TLB) & (data_req_type_m0 == REQ_TLB)));

  // - STB writes should be granted access to both the tag and dirty
  // simultaneously
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M0 Request Interdependency - STB")
  u_ovl_interdep_m0_stb   (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (stb_data_granted_m0 & stb_cache_data_wr_m0_i),
                           .consequent_expr ((data_req_type_m0 == REQ_STB) & (dirty_req_type_m0 == REQ_STB)));

  // M1
  // - Allocations - always interdependent when requesting more than one
  // resource.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Interdependency - Allocation Data/Tag")
  u_ovl_interdep_m1_alloc_tag_data    (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr ((prearb_data_req_type_m1 == REQ_ALLOC) & (prearb_tag_req_type_m1 == REQ_ALLOC) &
                                                         (prearb_data_granted_m1 | prearb_tag_granted_m1)),
                                       .consequent_expr (prearb_data_granted_m1 & prearb_tag_granted_m1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Interdependency - Allocation Data/Dirty")
  u_ovl_interdep_m1_alloc_dirty_data  (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr ((prearb_data_req_type_m1 == REQ_ALLOC) & (prearb_dirty_req_type_m1 == REQ_ALLOC) &
                                                         (prearb_data_granted_m1 | prearb_dirty_granted_m1)),
                                       .consequent_expr (prearb_data_granted_m1 & prearb_dirty_granted_m1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Interdependency - Allocation Tag/Dirty")
  u_ovl_interdep_m1_alloc_dirty_tag   (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr ((prearb_tag_req_type_m1 == REQ_ALLOC) & (prearb_dirty_req_type_m1 == REQ_ALLOC) &
                                                         (prearb_tag_granted_m1 | prearb_dirty_granted_m1)),
                                       .consequent_expr (prearb_tag_granted_m1 & prearb_dirty_granted_m1));

  // - TLB - always ask for tag and data, so whenever have one
  // request in M1 must also have the other, and they must be granted
  // together.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Interdependency - TLB")
  u_ovl_interdep_m1_tlb_req     (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (prearb_data_req_type_m1  == REQ_TLB),   // TLB request for data in M1
                                 .consequent_expr (prearb_tag_req_type_m1   == REQ_TLB));  // Must be accompanied by request for tag

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Granted Interdependency - TLB")
  u_ovl_interdep_m1_tlb_granted (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (prearb_data_granted_m1 & (prearb_data_req_type_m1 == REQ_TLB)), // TLB request granted for data
                                 .consequent_expr (prearb_tag_granted_m1));                                        // Must also be granted for tag

  // - STB - writes always ask for data and dirty (and no other
  // STB request types access those resources), so whenever have one
  // request in M1 must also have the other, and they must be granted
  // together.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Interdependency - STB")
  u_ovl_interdep_m1_stb_req     (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (prearb_dirty_req_type_m1 == REQ_STB),   // STB request for dirty in M1
                                 .consequent_expr (prearb_data_req_type_m1  == REQ_STB));  // Must be accompanied by request for tag

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "M1 Request Granted Interdependency - STB")
  u_ovl_interdep_m1_stb_granted (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (prearb_dirty_granted_m1 & (prearb_dirty_req_type_m1 == REQ_STB)), // STB write request granted for dirty
                                 .consequent_expr (prearb_data_granted_m1));                                         // Must also be granted for data

  // Various way signals are only valid as zero, all-hot or one-hot
  // - prearb_data_way_m1 is set for arbitrated requests from M0, and could
  // be either zero (for requests which do not use the data way), one-hot
  // (for some lookups and reads/writes where the way is known in advance),
  // or all-hot (for some lookups, non-sequential reads where the way is not
  // known, and sequential reads).
  reg ovl_alloc_dirty_granted_m1;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_alloc_dirty_granted_m1 <= 1'b0;
    else
      ovl_alloc_dirty_granted_m1 <= alloc_dirty_granted_m0;

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "prearb_data_way_m1 not one-hot/all-hot/zero")
  u_ovl_prearb_data_way_m1_onehot  (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr ({4{prearb_data_req_m1 & ~ovl_alloc_dirty_granted_m1}} & prearb_data_way_m1 & {4{~&prearb_data_way_m1}})); // Mask all-one to all-zero

  // - The logic in M2 depends on dword_data_seq_banksel_m2 being zero when there is a
  // non-seq data read in M2.
  reg ovl_nseq_data_read_m2;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_nseq_data_read_m2 <= 1'b0;
    end else begin
      ovl_nseq_data_read_m2 <= (tlb_req_m1 & prearb_data_granted_m1) | (dc_valid_load_req_m1_i & ~dc_load_tag_req_only_m1_i & ~seq_suppress_tag_m1);
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "dword_data_seq_banksel_m2 should be zero when non-seq data read in M2")
  u_ovl_data_seq_on_nseq_m2       (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (ovl_nseq_data_read_m2),
                                   .consequent_expr (dword_data_seq_banksel_m2 == 4'b0000));

  // The mux selects for dword_data_m2 should be one hot when there is a load
  // or TLB request in M2.
  reg ovl_load_or_tlb_m2;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_load_or_tlb_m2 <= 1'b0;
    else
      ovl_load_or_tlb_m2 <= ((dc_valid_load_req_m1_i & load_data_granted_m1) | (tlb_req_m1 & prearb_data_granted_m1));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "dword data mux select should be one hot when there is a dword read in M2")
  u_ovl_dword_read_oneh  (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr ({4{ovl_load_or_tlb_m2 & ~(dcu_ecc_tag_err_m2_o | dcu_ecc_in_progress_o)}} & dword_data_banksel_m2));

  // The dataram strobes should only be anything other than all-hot or
  // all-zero for STB writes. If set for an STB write, then the strobes may
  // remain set until a new M0 request enters M1, i.e. whilst the prearb
  // request is NONE.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only the STB can set the data strobes to anything other than all-hot or zero")
  u_ovl_data_strobes_set_by_stb  (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (|dc_dataram_en_o & dc_dataram_wr_o & (prearb_data_strb_m1 != 16'h0000) & (prearb_data_strb_m1 != 16'hffff)),
                                  .consequent_expr ((prearb_data_req_type_m1 == REQ_NONE) | (prearb_data_req_type_m1 == REQ_STB)));

  // data_req_type_m0 should be valid when pipelining data_bank_en_m0 to M1,
  // so that the case statement which generates it does not have reachable
  // x-assignment.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "data_req_type_m0 should be valid when pipelining M0 data request")
  u_ovl_data_req_type_m0_valid   (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (data_m0_en),
                                  .consequent_expr ((data_req_type_m0 == REQ_STB)   |
                                                    (data_req_type_m0 == REQ_ALLOC) |
                                                    (data_req_type_m0 == REQ_TLB)   |
                                                    (data_req_type_m0 == REQ_CP15)  |
                                                    (data_req_type_m0 == REQ_MBIST)));

  // data_way_m0 should be one hot when the sequential M0 address is used, so
  // that the case statement which generates it does not have reachable
  // x-assignment.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "data_way_m0 should be one hot when seq_data_addr generated")
  u_ovl_data_way_m0_one_hot      (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (alloc_data_granted_m0),
                                  .consequent_expr ((data_way_m0 == 4'b0001) |
                                                    (data_way_m0 == 4'b0010) |
                                                    (data_way_m0 == 4'b0100) |
                                                    (data_way_m0 == 4'b1000)));

  // The data way provided by the CCB block should be one-hot when there is
  // a CCB data request in M1, so that the case statement to assign
  // ccb_data_addrNN_m1 does not have reachable x-assignment when the result
  // is used.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ccb_lookup_way should be one hot when used")
  u_ovl_ccb_lookup_way_one_hot     (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (ccb_data_req_m1_i),
                                  .consequent_expr ((ccb_lookup_way_i == 4'b0001) |
                                                    (ccb_lookup_way_i == 4'b0010) |
                                                    (ccb_lookup_way_i == 4'b0100) |
                                                    (ccb_lookup_way_i == 4'b1000)));

  // Rotation signal in M0 must be valid when being pipelined to M1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "data_rotation_m0 invalid encoding")
  u_ovl_wdata_rotation_m0        (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (data_wdata_m0_en_any),
                                  .consequent_expr ((data_rotation_m0 == ROTATION_0) |
                                                    (data_rotation_m0 == ROTATION_1) |
                                                    (data_rotation_m0 == ROTATION_2) |
                                                    (data_rotation_m0 == ROTATION_3) |
                                                    (data_rotation_m0 == ROTATION_STB_0) |
                                                    (data_rotation_m0 == ROTATION_STB_1)));

  // Rotation signal in M0 must be valid when dataram write in M1
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "prearb_data_rotation_m1 invalid encoding")
  u_ovl_wdata_rotation_m1        (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .antecedent_expr (|dc_dataram_en_o & dc_dataram_wr_o),
                                  .consequent_expr ((prearb_data_rotation_m1 == ROTATION_0) |
                                                    (prearb_data_rotation_m1 == ROTATION_1) |
                                                    (prearb_data_rotation_m1 == ROTATION_2) |
                                                    (prearb_data_rotation_m1 == ROTATION_3) |
                                                    (prearb_data_rotation_m1 == ROTATION_STB_0) |
                                                    (prearb_data_rotation_m1 == ROTATION_STB_1)));

  // - the lower two data bank-pairs for an allocation must be sequential
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The lower two data bank-pairs for an allocation must be sequential")
  u_ovl_alloc_bank_pairs_sequential  (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .antecedent_expr (alloc_data_granted_m0),
                                      .consequent_expr ((alloc_lower_two_data_bank_pairs_m0 == 4'b0011) |
                                                        (alloc_lower_two_data_bank_pairs_m0 == 4'b0110) |
                                                        (alloc_lower_two_data_bank_pairs_m0 == 4'b1100) |
                                                        (alloc_lower_two_data_bank_pairs_m0 == 4'b1001)));

  // - data_bank_en_m0 should never be x when it is being registered
  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "data_bank_en_m0 never x when registered")
  u_ovl_data_bank_en_m0_x (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (data_m0_en),
                           .test_expr (data_bank_en_m0));

  // Signals used in if statements in register enables should never be X

  // - data_m0_en
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "data_m0_en is used as a register enable and so should never be X")
  u_ovl_reg_en_x_data_m0_en                (.clk        (clk),
                                            .reset_n    (reset_n),
                                            .qualifier  (1'b1),
                                            .test_expr  (data_m0_en));

  // - alloc_data_req_m1
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "alloc_data_req_m1 is used as a register enable and so should never be X")
  u_ovl_reg_en_x_alloc_data_req_m1         (.clk        (clk),
                                            .reset_n    (reset_n),
                                            .qualifier  (1'b1),
                                            .test_expr  (alloc_data_req_m1));

  // - victim_count_en_m2
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "victim_count_en_m2 is used as a register enable and so should never be X")
  u_ovl_reg_en_x_victim_count_en_m2        (.clk        (clk),
                                            .reset_n    (reset_n),
                                            .qualifier  (1'b1),
                                            .test_expr  (victim_count_en_m2));

  /* ARMAUTO_X */
generate if (CPU_CACHE_PROTECTION) begin : g_xcheck_ovl_ecc

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: data_wdata_m0_en_lo")
  u_ovl_x_data_wdata_m0_en_lo (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (g_data_wdata_m0_en_ecc.data_wdata_m0_en_lo[3:0]));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Register enable x-check: ecc_data_syndrome_m3_en")
  u_ovl_x_ecc_data_syndrome_m3_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (ecc_data_syndrome_m3_en[7:0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ecc_tag_dirty_m3_en")
  u_ovl_x_ecc_correction_m3_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (ecc_tag_dirty_m3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ecc_en")
  u_ovl_x_ecc_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ecc_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: qword_data_m2_en")
  u_ovl_x_qword_data_m2_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (qword_data_m2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_ecc_data_read_m1")
  u_ovl_x_valid_ecc_data_read_m1 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (valid_ecc_data_read_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_ecc_data_read_m2")
  u_ovl_x_valid_ecc_data_read_m2 (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (valid_ecc_data_read_m2));

end else begin : g_xcheck_ovl_no_ecc

  assert_never_unknown #(`OVL_FATAL, 16, `OVL_ASSERT, "Register enable x-check: data_wdata_m0_en_lo")
  u_ovl_x_data_wdata_m0_en_lo (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (g_data_wdata_m0_en_no_ecc.data_wdata_m0_en_lo[15:0]));

end endgenerate

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_wdata_m0_en_any")
  u_ovl_x_data_wdata_m0_en_any (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (data_wdata_m0_en_any));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_wdata_m0_en_hi")
  u_ovl_x_data_wdata_m0_en_hi (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (data_wdata_m0_en_hi));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dword_data_m2_en")
  u_ovl_x_dword_data_m2_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (dword_data_m2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prearb_count_en_m1")
  u_ovl_x_prearb_count_en_m1 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (prearb_count_en_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_lookup_m1")
  u_ovl_x_tag_lookup_m1 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (tag_lookup_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_sel_m2_en")
  u_ovl_x_tag_sel_m2_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (tag_sel_m2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: start_seq_m1")
  u_ovl_x_start_seq_m1 (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (start_seq_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_tag_granted_m1")
  u_ovl_x_load_tag_granted_m1 (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (load_tag_granted_m1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prearb_data_req_type_m1_en")
  u_ovl_x_prearb_data_req_type_m1_en (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .qualifier (1'b1),
                                      .test_expr (prearb_data_req_type_m1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prearb_dirty_req_type_m1_en")
  u_ovl_x_prearb_dirty_req_type_m1_en (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (prearb_dirty_req_type_m1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prearb_tag_req_type_m1_en")
  u_ovl_x_prearb_tag_req_type_m1_en (.clk       (clk),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (prearb_tag_req_type_m1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dirty_m0_en")
  u_ovl_x_dirty_m0_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (dirty_m0_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: mbist_en_i")
  u_ovl_x_mbist_en_i (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (mbist_en_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_addr_m0_en")
  u_ovl_x_tag_addr_m0_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (tag_addr_m0_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tag_m0_en")
  u_ovl_x_tag_m0_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (tag_m0_en));

  // Case statements with reachable X assignment should never assign X when
  // the output is used
  // - data_seq_addr_m0
  assert_never_unknown #(`OVL_FATAL, 12, `OVL_ASSERT, "seq_data_addr_m0 never X when used")
  u_ovl_seq_data_addr_x   (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (alloc_data_granted_m0),
                           .test_expr ({seq_data_addr67_m0, seq_data_addr45_m0, seq_data_addr23_m0, seq_data_addr01_m0}));

  // - ccb_data_addr_m1
  assert_never_unknown #(`OVL_FATAL, 12, `OVL_ASSERT, "ccb_data_addr_m1 never X when used")
  u_ovl_ccb_data_addr_x   (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (ccb_data_req_m1_i),
                           .test_expr ({ccb_data_addr67_m1, ccb_data_addr45_m1, ccb_data_addr23_m1, ccb_data_addr01_m1}));

  // Only one request should be granted for each resource in any cycle

  // - M0 Tag
  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "Only one request should be granted for a resource: M0 Tag")
  u_ovl_tag_req_m0_granted  (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ({mbist_en_i,
                                          alloc_tag_granted_m0,
                                          tlb_granted_m0,
                                          stb_tag_granted_m0,
                                          pf_granted_m0,
                                          cp15_tag_granted_m0}));

  // - M0 Data
  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one request should be granted for a resource: M0 Data")
  u_ovl_data_req_m0_granted  (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr ({mbist_en_i,
                                           alloc_data_granted_m0,
                                           tlb_granted_m0,
                                           stb_data_granted_m0,
                                           cp15_data_granted_m0}));

  // - M0 Dirty
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Only one request should be granted for a resource: M0 Dirty")
  u_ovl_dirty_req_m0_granted  (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({mbist_en_i,
                                            alloc_dirty_granted_m0,
                                            stb_dirty_granted_m0}));

  // - M1 Tag
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Only one request should be granted for a resource: M1 Tag")
  u_ovl_tag_req_m1_granted    (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({ccb_tag_req_m1_i,
                                            load_tag_granted_m1,
                                            prearb_tag_granted_m1}));

  // - M1 Data
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Only one request should be granted for a resource: M1 Data")
  u_ovl_data_req_m1_granted   (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({ccb_data_granted_m1,
                                            load_data_granted_m1,
                                            prearb_data_granted_m1}));

  // - M1 Dirty
  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "Only one request should be granted for a resource: M1 Dirty")
  u_ovl_dirty_req_m1_granted  (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({ccb_dirty_req_m1_i,
                                            prearb_dirty_granted_m1}));

  // The MBIST request signals should only be asserted when MBIST is enabled
   assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: tag_req_m0")
   u_ovl_mbist_tag_m0       (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (tag_req_type_m0 == REQ_MBIST),
                             .consequent_expr (mbist_en_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: dirty_req_m0")
  u_ovl_mbist_dirty_m0     (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (dirty_req_type_m0 == REQ_MBIST),
                            .consequent_expr (mbist_en_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: data_req_m0")
  u_ovl_mbist_data_m0      (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (data_req_type_m0 == REQ_MBIST),
                            .consequent_expr (mbist_en_i));

   assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: tag_req_m1")
   u_ovl_mbist_tag_m1       (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (prearb_tag_req_type_m1 == REQ_MBIST),
                             .consequent_expr (mbist_en_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: dirty_req_m1")
  u_ovl_mbist_dirty_m1     (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (prearb_dirty_req_type_m1 == REQ_MBIST),
                            .consequent_expr (mbist_en_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "MBIST request set when MBIST not enabled: data_req_m1")
  u_ovl_mbist_data_m1      (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (prearb_data_req_type_m1 == REQ_MBIST),
                            .consequent_expr (mbist_en_i));

  //-----------------------------------------------
  // Additional properties for Formal Verification
  //-----------------------------------------------
  // The following assertions are required for DCU formal verification and
  // are converted to assumes when running the formal tool. They are
  // included here rather than in the interface files because they either
  // rely on signals that are not available on the interfaces, or rely on
  // properties of several blocks in combination.

  // There should never be more than one entry in the cache for a particular
  // tag address (but more than one way can hit when there is an ECC error).
  // This cannot be proven formally, as it relies on the behaviour of the
  // cache RAMs, and the properties of the DCU, STB, TLB and BIU when
  // accessing the cache.

  reg ovl_tag_lu_m2;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_tag_lu_m2 <= 1'b0;
    else
      ovl_tag_lu_m2 <= (&tagram_en_m1) & ~tagram_wr_m1 & ~(load_tag_granted_m1 & ~(dc_valid_load_req_m1_i | dc_load_tag_req_only_m1_i));

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "Only one way should hit in the cache")
  u_ovl_one_way_hit  (.clk       (clk),
                      .reset_n   (reset_n),
                      .test_expr ({4{ovl_tag_lu_m2}} & tag_way_comp_m2 & {4{~dcu_ecc_tag_err_m2_o}}));

  // - a non-first load should always hit in the cache way tracker
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Non-first load should hit in cache way tracker")
  u_ovl_non_first_seq_hit          (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (dc_load_req_m1_i & ~dc_load_first_m1_i & ~force_dc_load_first_m1),
                                    .consequent_expr (seq_suppress_tag_m1));

`endif

endmodule // ca53dcu_cachearb

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dcu_defs.v"
`undef CA53_UNDEFINE
/*END*/
