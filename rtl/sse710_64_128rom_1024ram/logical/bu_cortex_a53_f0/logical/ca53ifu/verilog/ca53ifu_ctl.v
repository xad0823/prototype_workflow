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
// Abstract : IFU control
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_ctl `CA53_IFU_PARAM_DECL
(
  // Clocks and resets
  input wire                            clk,
  input wire                            reset_n,
  input wire                            DFTRAMHOLD,

  // PFB-ICB interface
  input wire [14:2]                     pfb_va_if1_i,
  input wire                            pfb_first_if1_i,
  input wire                            pfb_force_if1_i,
  input wire                            pfb_valid_if1_i,
  input wire                            pfb_utlb_hit_if2_i,
  input wire [1:0]                      pfb_state_if2_i,
  input wire                            pfb_ns_dsc_if2_i,
  input wire [14:1]                     pfb_va_if2_i,
  input wire [39:4]                     pfb_pa_if2_i,
  input wire                            pfb_kill_if2_i,
  input wire [7:0]                      pfb_attributes_if2_i,
  input wire                            pfb_priv_if2_i,
  input wire [79:0]                     pfb_mbist_data_i,
  output wire                           icb_flush_btic_o,
  output wire                           icb_cacheable_if2_o,
  output wire                           icb_busy_if1_o,
  output wire [79:0]                    icb_data_if2_o,
  output wire [79:0]                    icb_lfb_data_if2_o,
  output wire                           icb_hit_if2_o,
  output wire                           icb_lfb_hit_if2_o,
  output wire [1:0]                     icb_way_if2_o,
  output wire                           icb_pdc_hazard_if2_o,
  output wire                           icb_ext_abort_if2_o,
  output wire [1:0]                     icb_ext_abort_type_if2_o,
  output wire [3:0]                     icb_parity_err_if2_o,
  output wire [2:0]                     icb_mbist_en_o,

  // DPU interface
  input wire                            dpu_icache_on_i,
  input wire                            dpu_flush_i_utlb_i,
  output wire                           ifu_dbg_ready_o,
  output wire                           ifu_wfx_ready_o,
  output wire                           ifu_evnt_ic_access_o,
  output wire                           ifu_pty_valid_o,
  output wire                           ifu_pty_ramid_o,
  output wire                           ifu_pty_way_bank_id_o,
  output wire [11:0]                    ifu_pty_index_o,
  // TLB interface
  input wire                            tlb_i_utlb_flush_i,

  // BIU interface
  input wire                            ifu_arvalid_i,
  input wire                            biu_i_arready_i,
  input wire [(`CA53_IDATA_RAM_W-1):0]  biu_i_rdata_i, // Used for MBIST write data

  // MBIST
  input wire                            gov_mbist_req_i,
  input wire [11:0]                     mbist_addr_mb3_i,
  input wire                            mbist_write_en_mb3_i,
  input wire                            mbist_read_en_mb3_i,
  input wire [6:0]                      mbist_array_mb3_i,
  input wire [3:0]                      mbist_be_mb3_i,
  input wire                            mbist_cfg_mb3_i,
  input wire                            mbist_sel_i,
  output wire [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6_o,
  output wire                           ctl_mbist_req_o,
  output wire [1:0]                     ctl_mbist_btac_en_mb4_o,
  output wire [6:0]                     ctl_mbist_btac_addr_mb4_o,
  output wire                           ctl_mbist_btac_wr_mb4_o,
  output wire [58:0]                    ctl_mbist_btac_wdata_mb4_o,

  // RAM interface
  input wire [2:0]                      ic_size_i,
  input wire [(`CA53_ITAG_RAM_W-1):0]   ic_tagram_rdata0_i,
  input wire [(`CA53_ITAG_RAM_W-1):0]   ic_tagram_rdata1_i,
  input wire [(`CA53_IDATA_RAM_W-1):0]  ic_dataram_rdata0_i,
  input wire [(`CA53_IDATA_RAM_W-1):0]  ic_dataram_rdata1_i,
  output wire [1:0]                     ic_tagram_en_o,
  output wire                           ic_tagram_wr_o,
  output wire [(`CA53_ITAG_RAM_W-1):0]  ic_tagram_wdata_o,
  output wire [8:0]                     ic_tagram_addr_o,
  output wire [3:0]                     ic_dataram_en_o,
  output wire                           ic_dataram_wr_o,
  output wire [11:0]                    ic_dataram_addr0_o,
  output wire [11:0]                    ic_dataram_addr1_o,
  output wire [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0_o,
  output wire [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1_o,
  output wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0_o,
  output wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1_o,

  // Internal ICB interface
  input wire [1:0]                      cp15_busy_if1_i,
  input wire [1:0]                      cp15_active_i,
  input wire [1:0]                      cp15_tag_en_i,
  input wire                            cp15_tag_wr_i,
  input wire [1:0]                      cp15_data_en_i,
  input wire                            cp15_data_wr_i,
  input wire [11:0]                     cp15_addr_i,
  input wire                            cp15_pty_ack_i,
  input wire [1:0]                      lfb_tagram_en_if0_i,
  input wire [8:0]                      lfb_tagram_addr_if0_i,
  input wire                            lfb_tagram_wr_if0_i,
  input wire [30:0]                     lfb_tagram_wdata_if0_i,
  input wire                            lfb_dataram_en_if0_i,
  input wire                            lfb_dataram_wr_if0_i,
  input wire [11:0]                     lfb_dataram_addr0_if0_i,
  input wire [11:0]                     lfb_dataram_addr1_if0_i,
  input wire [3:0]                      lfb_dataram_strb0_if0_i,
  input wire [3:0]                      lfb_dataram_strb1_if0_i,
  input wire [159:0]                    lfb_data_i,
  input wire                            lfb_data_way_i,
  input wire                            lfb_hit_raw_i,
  input wire                            lfb_hit_past_i,
  input wire                            lfb_hit_pres_i,
  input wire                            lfb_hit_fut_i,
  input wire                            lfb_hit_ppf_i,
  input wire [2:0]                      lfb_hit_resp_i,
  input wire [1:0]                      lfb_hit_way_i,
  input wire                            lfb_comp_hazard_i,
  input wire                            lfb_hit_cacheable_i,
  input wire                            lfb_can_hit_pd1_i,
  input wire [1:0]                      lfb_available_i,
  input wire                            lfb_in_progress_i,
  input wire                            icb_dbg_hit_if2_i,
  input wire                            pdc_req_i,
  input wire [3:0]                      pdc_en_if0_i,
  input wire [14:3]                     pdc_addr0_if0_i,
  input wire [14:3]                     pdc_addr1_if0_i,
  input wire [159:0]                    pdc_wdata_if0_i,
  input wire [7:0]                      pdc_strb_if0_i,
  output wire                           ctl_pfb_valid_if1_o,
  output wire                           ctl_lfb_alloc_o,
  output wire [14:1]                    ctl_pfb_va_if3_o,
  output wire [39:4]                    ctl_pfb_pa_if3_o,
  output wire [7:0]                     ctl_pfb_attributes_if3_o,
  output wire                           ctl_pfb_ns_dsc_if3_o,
  output wire                           ctl_pfb_priv_if3_o,
  output wire                           ctl_seq_miss_if3_o,
  output wire                           ctl_stall_pfb_o,
  output wire                           ctl_stall_lfb_pd0_o,
  output wire                           ctl_stall_lfb_if0_o,
  output wire                           ctl_stall_if3_o,
  output wire                           ctl_stall_pdc_o,
  output wire                           ctl_stall_tag_cp15_o,
  output wire                           ctl_stall_tag_cp15_if1_o,
  output wire                           ctl_stall_data_cp15_if1_o,
  output wire                           ctl_stall_data_cp15_o,
  output wire                           ctl_cache_on_if2_o,
  output wire                           ctl_cp15_active_if3_o,
  output wire                           ctl_pty_inv_req_o,
  output wire [14:6]                    ctl_pty_inv_addr_o,
  output wire                           ctl_pd_ack_o,
  output wire                           ctl_start_lfb_o,        // Enable the LFB entries
  output wire                           ctl_lfb_activate_o,     // Activate new LFB entry (and BIU req)
  output wire                           ctl_lfb_speculative_o,  // Activation is a speculative one
  output wire                           ctl_random_way_o,       // A random way for LFB activation
  output wire [1:0]                     ctl_tag_valid_if3_o,    // Tag RAMs had valid entries
  output wire [1:0]                     ctl_almost_hit_if3_o,   // A lookup almost hit ($ways or LFB)
  output wire                           ctl_hit_f_if3_o,
  output wire                           ctl_valid_if2_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  // Types of cache access request that are arbitrated.  The values correspond
  // to the bit position of the request type in the ic_req_valid_if0 bus.
  localparam integer REQ_MBIST = 0;
  localparam integer REQ_PDC   = 1;
  localparam integer REQ_ALLOC = 2;
  localparam integer REQ_CP15  = 3;

  // Tag RAM entry for invalid tag
  localparam [30:0] TAG_INVALID  = {31{1'b1}};
  localparam [79:0] DATA_INVALID = {80{1'b0}};

  // RAM lookup state
  localparam [1:0] LUP_NORMAL    = 2'b00; // Lookup tag and data RAMs
  localparam [1:0] LUP_SKIP_TAG  = 2'b01; // Skip lookup of tag RAM
  localparam [1:0] LUP_SKIP_DATA = 2'b10; // Skip lookup of tag and one data RAM

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // pd0 stalls
  wire                          ctl_stall_lfb_pd0;

  // if0 arbitration
  reg                             ctl_mbist_req;
  wire                      [1:0] mbist_sel_ifu_tag;
  wire                      [3:0] mbist_sel_ifu_data;
  wire                      [1:0] mbist_sel_ifu_btac;
  wire                      [1:0] mbist_btac_en_if0;
  wire                      [3:0] ic_req_tag_raw_if0;        // Cache tag access requests, unarbitrated
  wire                      [3:0] ic_req_data_raw_if0;       // Cache data access requests, unarbitrated
  wire                      [3:0] ic_req_tag_arb_if0;        // Cache tag access requests, arbitrated
  wire                      [3:0] ic_req_data_arb_if0;       // Cache data access requests, arbitrated
  wire                      [1:0] mbist_tagram_en_if0;       // Qualified: MBIST tagram enable
  wire                      [8:0] mbist_tagram_addr_if0;     //            MBIST tagram addr
  wire                            mbist_tagram_wr_if0;       //            MBIST tagram write enable
  wire                     [30:0] mbist_tagram_wdata_if0;    //            MBIST tagram write data
  wire                      [3:0] mbist_dataram_en_if0;      //            MBIST dataram enable
  wire                            mbist_dataram_wr_if0;      //            MBIST dataram write enable
  wire                     [11:0] mbist_dataram_addr_if0;    //            MBIST dataram addr
  wire                      [3:0] mbist_dataram_strb_if0;    //            MBIST dataram strobes
  wire                     [79:0] mbist_dataram_wdata_if0;   //            MBIST dataram write data
  wire                      [8:0] cp15_tagram_addr_if0;      //            CP15 tagram addr
  wire                      [1:0] cp15_tagram_en_if0;        //            CP15 tagram enable
  wire                            cp15_tagram_wr_if0;        //            CP15 tagram write enable
  wire                     [30:0] cp15_tagram_wdata_if0;     //            CP15 tagram write data
  wire                     [11:0] cp15_dataram_addr_if0;     //            CP15 dataram addr
  wire                      [1:0] cp15_data_bank_en_if0;     //            CP15 bank enable (corkscrew)
  wire                      [3:0] cp15_dataram_en_if0;       //            CP15 dataram enable
  wire                            cp15_dataram_wr_if0;       //            CP15 dataram write enable
  wire                      [3:0] cp15_dataram_strb0_if0;    //            CP15  dataram bank0 strobes
  wire                      [3:0] cp15_dataram_strb1_if0;    //            CP15  dataram bank1 strobes
  wire                     [79:0] cp15_dataram_wdata_if0;    //            CP15  dataram write data
  wire                      [3:0] pdc_dataram_en_if0;        //            PDC  dataram enable
  wire                            pdc_dataram_wr_if0;        //            PDC  dataram write enable
  wire                     [11:0] pdc_dataram_addr0_if0;     //            PDC  dataram bank0 addr
  wire                     [11:0] pdc_dataram_addr1_if0;     //            PDC  dataram bank1 addr
  wire                      [3:0] pdc_dataram_strb0_if0;     //            PDC  dataram bank0 strobes
  wire                      [3:0] pdc_dataram_strb1_if0;     //            PDC  dataram bank1 strobes
  wire                     [79:0] pdc_dataram_wdata0_if0;    //            PDC  dataram bank0 write data
  wire                     [79:0] pdc_dataram_wdata1_if0;    //            PDC  dataram bank1 write data
  wire                      [8:0] lfb_tagram_addr_if0;       //            LFB tagram addr
  wire                            lfb_tagram_wr_if0;         //            LFB tagram write enable
  wire                     [30:0] lfb_tagram_wdata_if0;      //            LFB tagram write data
  wire                            lfb_dataram_wr_if0;        //            LFB dataram write enable
  wire                     [11:0] lfb_dataram_addr0_if0;     //            LFB dataram bank0 addr
  wire                     [11:0] lfb_dataram_addr1_if0;     //            LFB dataram bank1 addr
  wire                      [3:0] lfb_dataram_strb0_if0;     //            LFB dataram bank0 strb
  wire                      [3:0] lfb_dataram_strb1_if0;     //            LFB dataram bank1 strb
  wire                      [1:0] tagram_en_if0;             // Combined if0: tagram enable
  wire                      [8:0] tagram_addr_if0;           //               tagram address
  wire                            tagram_wr_if0;             //               tagram write/not read
  wire                     [30:0] tagram_wdata_if0;          //               tagram write data
  wire                      [3:0] dataram_en_if0;            //               dataram enable
  wire                            dataram_wr_if0;            //               dataram write/not read
  wire                     [11:0] dataram_addr0_if0;         //               dataram bank0 address
  wire                     [11:0] dataram_addr1_if0;         //               dataram bank1 address
  wire                      [3:0] dataram_strb0_if0;         //               dataram bank0 strobes
  wire                      [3:0] dataram_strb1_if0;         //               dataram bank1 strobes
  wire                     [79:0] dataram_wdata0_if0;        //               dataram bank0 write data
  wire                     [79:0] dataram_wdata1_if0;        //               dataram bank1 write data
  reg                       [1:0] tagram_en_prearb_if1;      // Pre-arbitrated if1: tagram enable
  reg                       [8:0] tagram_addr_prearb_if1;    //                     tagram address
  reg                             tagram_wr_prearb_if1;      //                     tagram write/not read
  reg                      [30:0] tagram_wdata_prearb_if1;   //                     tagram write data
  reg                       [3:0] dataram_en_prearb_if1;     //                     dataram enable
  reg                             dataram_wr_prearb_if1;     //                     dataram write/not read
  reg                      [11:0] dataram_addr0_prearb_if1;  //                     dataram bank0 address
  reg                      [11:0] dataram_addr1_prearb_if1;  //                     dataram bank1 address
  reg                       [3:0] dataram_strb0_prearb_if1;  //                     dataram bank0 strobes
  reg                       [3:0] dataram_strb1_prearb_if1;  //                     dataram bank1 strobes
  reg                      [79:0] dataram_wdata0_prearb_if1; //                     dataram bank0 write data
  reg                      [79:0] dataram_wdata1_prearb_if1; //                     dataram bank1 write data
  reg                             mbist_read_if1;            // MBIST in if1: Read
  reg                             mbist_write_if1;           //               Write
  reg                       [2:0] mbist_ram_sel_if1;         //               RAM selector for reads
  reg                       [1:0] mbist_btac_en_if1;         //               Enable for BTAC {stage1, stage0}
  wire                            nxt_mbist_read_if1;
  wire                            nxt_mbist_write_if1;
  reg                             lfb_alloc_req_data_if1;    // LFB alloc arbitrated if0 -> if1 (data access required)
  reg                       [3:0] dataram_wait_cnt;
  wire                      [3:0] nxt_dataram_wait_cnt;
  wire                            dataram_wait_cnt_we;
  reg                             cp15_req_if1;              // CP15 arbitrated if0 -> if1
  wire                            cp15_req_if0;
  wire                            if0_if1_tag_en;
  wire                            if0_if1_data_en;

  // if0 stalls
  wire                            ctl_stall_lfb_if0;
  wire                            ctl_stall_tag_cp15;
  wire                            ctl_stall_tag_cp15_if1;
  wire                            ctl_stall_data_cp15_if1;
  wire                            ctl_stall_data_cp15;
  wire                            ctl_stall_pdc_if0;

  // if1 requests
  reg                             evaluate_pfb_q;
  wire                            nxt_evaluate_pfb;
  wire                            evaluate_pfb;
  wire                            evaluate_pfb_now;
  wire                            ctl_pfb_valid_if1;
  reg                             ctl_pfb_valid_if2;

  // if1 arbitration
  wire                            tagram_avail_if1;     // if1 tagram  slot available for new request
  wire                            dataram_avail_if1;    // if1 dataram slot available for new request
  wire                      [1:0] tagram_en_if1;
  wire                      [8:0] tagram_addr_if1;
  wire                            tagram_wr_if1;
  wire                     [30:0] tagram_wdata_if1;
  wire  [(`CA53_ITAG_RAM_W-1):0] tagram_wdata_if1_pty;
  wire                      [3:0] dataram_en_if1;
  wire                            dataram_wr_if1;
  wire                     [11:0] dataram_addr0_if1;
  wire                     [11:0] dataram_addr1_if1;
  wire  [(`CA53_IDATA_WEN_W-1):0] dataram_strb0_if1;
  wire  [(`CA53_IDATA_WEN_W-1):0] dataram_strb1_if1;
  wire                     [79:0] dataram_wdata0_if1;
  wire                     [79:0] dataram_wdata1_if1;
  wire  [(`CA53_IDATA_RAM_W-1):0] dataram_wdata0_if1_pty;
  wire  [(`CA53_IDATA_RAM_W-1):0] dataram_wdata1_if1_pty;
  wire                            ctl_lfb_alloc;        // Allocating contents of LFB

  // Pre-fetch cache lookups and cache hit detection
  wire                            pfb_ic_lookup;           // Regular $lookup due to PFB request
  wire                            ic_lookup;               // $lookup including PFB and speculative
  wire                            ic_lookup_tag;           // 'Optimised' lookup term for tagram enables
  wire                      [3:0] ic_lookup_data;          // 'Optimised' lookup term for dataram enables
  wire                      [1:0] ic_lookup_tagram_en;
  wire                      [8:0] ic_lookup_tagram_addr;
  wire                      [3:0] ic_lookup_dataram_en;
  wire                     [11:0] ic_lookup_dataram_addr0;
  wire                     [11:0] ic_lookup_dataram_addr1;
  wire                            pfb_ic_compare_d;
  reg                             pfb_ic_compare_q;
  wire                            pfb_ic_compare_we;
  wire                            pfb_ic_compare;
  wire                            pfb_attrs_cacheable;
  wire                            pfb_priv_if2;
  wire                      [7:0] pfb_attributes_if2;
  wire                            ic_compare;
  wire                      [1:0] ic_tag_valid_if2;     // Cache tag entry is valid      (one bit per way)
  wire                      [1:0] ic_almost_hit_if2;    // Cache almost hit              (one bit per way)
  wire                      [1:0] ic_hit_raw_if2;       // Cache 'raw' (no priority) hit (one bit per way)
  wire                      [1:0] ic_hit_if2;           // Cache hit (and not LFB hit)   (one bit per way)
  wire                      [1:0] spec_ic_tag_valid;
  wire                      [1:0] spec_ic_almost_hit;
  wire                      [1:0] spec_ic_hit;
  wire                            icb_hit_if2;          // Cache hit (not LFB hit)
  wire                      [1:0] ic_data_sel_if2;      // Cache hit bank0/bank1 select
  wire                     [79:0] icb_data_if2;         // Cache hit (not LFB 'past' hit) data for PFB
  wire                            lfb_hit_if2;          // LFB hit

  // if2 request
  wire                            stall_pfb;            // PFB pipeline stall, until hit returned
  reg                             pfb_valid_if2;
  reg                             pfb_first_if2;
  wire                            nxt_pfb_first_if2;
  reg                             pfb_va_3_if2;
  wire                            pfb_valid_if2_we;

  // Cacheability
  wire                            icb_cache_on_if1;
  reg                             icb_cache_on_if2;
  wire                            dpu_cache_on_if1;
  reg                             dpu_cache_on_if2;
  wire                            cache_on_if2_we;
  reg                             icache_on;

  // Hit/miss detection
  wire                            miss_if2;          // Miss in if2 (pulse)
  wire                            hit_f_if2;         // Future hit in if2 (pulse)
  wire                            if2_if3_en;        // Possible for if2 miss to start if3
  reg                      [79:0] icb_lfb_data_if2;

  // External aborts
  wire                            ext_abort_if2;
  wire                      [1:0] ext_abort_type_if2;

  // MBIST read pipeline
  reg                             mbist_read_if2;
  reg                       [2:0] mbist_ram_sel_if2;
  wire                      [1:0] mbist_btac_rd_if2;
  wire                      [1:0] mbist_tag_rd_if2;
  reg                             mbist_read_if3;
  reg                             mbist_tag_rd_if3;
  wire  [(`CA53_IDATA_RAM_W-1):0] mbist_rdata_if3;
  wire  [(`CA53_IDATA_RAM_W-1):0] pfb_mbist_data;

  // if3: hit/miss
  reg                             miss_if3;          // Miss in if3, first cycle (pulse)
  wire                            nxt_miss_if3;
  wire                            miss_if3_we;
  reg                             hit_f_if3;
  wire                            hit_f_if3_we;
  wire                            nxt_hit_f_if3;
  reg                             hit_if3;           // Data returned in if3 (final cycle)
  wire                            nxt_hit_if3;
  wire                            way_sel_en;
  reg                       [1:0] ic_tag_valid_if3;
  reg                       [1:0] ic_almost_hit_if3;
  wire                      [1:0] nxt_ic_tag_valid_if3;
  wire                      [1:0] nxt_ic_almost_hit_if3;

  // if3: LFB activation
  reg                             lfb_activate_q;
  wire                            nxt_lfb_activate;
  wire                            lfb_activate_we;
  wire                            lfb_activate;
  reg                             started_hs;
  wire                            started_hs_we;
  wire                            nxt_started_hs;
  reg                             ctl_random_way;

  // if3 stalls (following miss or LFB future)
  reg                             stall_m_if3_q;
  reg                             stall_f_if3_q;
  wire                            stall_m_if3;
  wire                            stall_f_if3;
  wire                            stall_if3;         // if3 stalling
  reg                             kill_stall_if3;    // if3 stall should be killed
  wire                            nxt_kill_stall_if3;
  reg                             lfb_wait_if3;
  wire                            lfb_wait_if3_we;
  wire                            nxt_lfb_wait_if3;
  reg                             cp15_active_if3;
  wire                            set_cp15_active_if3;
  wire                            cp15_active_if3_we;

  // if3 request registers
  reg                      [14:1] pfb_va_if3;
  reg                      [39:4] pfb_pa_if3;
  reg                       [7:0] pfb_attributes_if3;
  reg                             pfb_ns_dsc_if3;
  reg                             pfb_priv_if3;
  reg                       [1:0] pfb_state_if3;
  reg                             pfb_first_if3;
  wire                            pfb_req_if3_we;
  wire                     [39:4] nxt_pfb_pa_if3;

  // Speculative
  wire                            attrs_cacheable_if3;
  reg                             flush_seen;
  wire                            nxt_flush_seen;
  reg                             flush_under_miss_seen;
  wire                            set_flush_under_miss_seen;
  wire                            clr_flush_under_miss_seen;
  wire                            nxt_flush_under_miss_seen;
  wire                            flush_under_miss_seen_we;
  wire                            spec_lup_allowed_d;
  reg                             spec_lup_allowed;
  wire                            spec_lup_block;
  wire                            spec_lup_eval;
  reg                             spec_ic_lookup_q;
  wire                            spec_ic_lookup;
  wire                            spec_ic_lookup_we;
  wire                            nxt_spec_ic_lookup;
  wire                     [14:6] spec_va;
  reg                             spec_ic_compare;
  wire                            spec_ic_compare_we;
  reg                             spec_lup_done;
  wire                            spec_lup_done_we;
  wire                            spec_lfb_block;
  wire                            early_spec_miss_d;   // Speculative lookup missed (RAM cycle), early version
  wire                            spec_miss_d;         // Speculative lookup missed (RAM cycle), late version
  reg                             spec_miss;           // Speculative miss - triggers LFB activation
  wire                            spec_miss_we;

  // RAM access optimisation
  reg                       [1:0] lookup_state;
  reg                       [1:0] nxt_lookup_state;
  wire                            revert_lookup_state;
  wire                            lfb_alloc_hazard;
  reg                       [1:0] tracked_hit;
  wire                            tracked_hit_we;
  wire                      [1:0] tracked_bank_en;
  wire                      [3:0] tracked_bank_en_hi_lo;
  wire                            ic_lookup_tag_mask_if1;
  reg                             ic_lookup_tag_mask_if2;
  wire                      [3:0] ic_lookup_data_mask_if1;

  // IFU control signals
  wire                      [1:0] icb_way_if2;
  reg                             icb_pdc_hazard_if2;
  wire                            pdc_hazard_we;
  reg                             ifu_wfx_ready;
  wire                            ifu_wfx_ready_d;
  wire                            ifu_dbg_ready;
  wire                            icb_busy_if1;
  wire                            ctl_seq_miss_if3;
  wire                            ctl_start_lfb;

  // Parity
  wire                     [79:0] ic_dataram_rdata0;    // I$ bank0 rdata without parity bits
  wire                     [79:0] ic_dataram_rdata1;    // I$ bank1 rdata without parity bits
  wire                     [30:0] ic_tagram_rdata0;     // I$ bank0 tag rdata without parity bits
  wire                     [30:0] ic_tagram_rdata1;     // I$ bank1 tag rdata without parity bits
  wire                      [1:0] spec_tagram_pty_err;  // Parity error on speculative tag read
  wire                      [3:0] icb_parity_err_if2;   // Instruction abort from parity error {tagram, dataram}
  wire                      [3:0] ctl_pty_inv_req;
  wire                      [8:0] ctl_pty_inv_addr;
  wire                            ifu_pty_valid;
  wire                            ifu_pty_ramid;
  wire                            ifu_pty_way_bank_id;
  wire                     [11:0] ifu_pty_index;
  wire                            lfb_check_pty_err;
  // Events
  reg                             ifu_evnt_ic_access;   // PMU event 0x14
  wire                            nxt_ifu_evnt_ic_access;


  //----------------------------------------------------------------------------
  // Functions
  //----------------------------------------------------------------------------

  // Apply the corkscrew technique to transform a two-bit way select, plus
  // bit[3] of the VA, into a dataram bank select
  function [1:0] corkscrew;
    input [1:0] way;
    input       va3;

    begin
      corkscrew = {((way[1] & ~va3) | (way[0] &  va3)),
                   ((way[1] &  va3) | (way[0] & ~va3))
                   };
    end
  endfunction

  //----------------------------------------------------------------------------
  // Parity bits
  //
  //   If configured with parity, extract the parity bits from the read data
  //----------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION > 0) begin : genif_cache_protection_rdata
    assign ic_dataram_rdata0 = {ic_dataram_rdata0_i[82:63], ic_dataram_rdata0_i[61:42], ic_dataram_rdata0_i[40:21], ic_dataram_rdata0_i[19:0]};
    assign ic_dataram_rdata1 = {ic_dataram_rdata1_i[82:63], ic_dataram_rdata1_i[61:42], ic_dataram_rdata1_i[40:21], ic_dataram_rdata1_i[19:0]};
    assign ic_tagram_rdata0  = ic_tagram_rdata0_i[30:0];
    assign ic_tagram_rdata1  = ic_tagram_rdata1_i[30:0];

  end else begin : genif_cache_protection_rdata_stubs
    // No parity - direct assignment
    assign ic_dataram_rdata0 = ic_dataram_rdata0_i[79:0];
    assign ic_dataram_rdata1 = ic_dataram_rdata1_i[79:0];
    assign ic_tagram_rdata0  = ic_tagram_rdata0_i[30:0];
    assign ic_tagram_rdata1  = ic_tagram_rdata1_i[30:0];
  end endgenerate


  //----------------------------------------------------------------------------
  // pd0: Stalls
  //----------------------------------------------------------------------------

  // pd0 must be stalled in the LFB when if0 (pd1) is stalled.  if0 only stalls
  // when there's valid data that can't advance, which means that any data in
  // pd0 must also stall.
  assign ctl_stall_lfb_pd0 = ctl_stall_lfb_if0;


  //----------------------------------------------------------------------------
  // if0: Arbitration
  //
  //   We use if0 to arbitrate between the various requests that will use the
  //   cache in if1.  This is possible for all types of request other than
  //   pre-fetch request lookups, which can only be determined in if1.
  //
  //   The types of requests arbitrated are as follows, from lowest priority to
  //   highest priority.  Pre-fetch is shown in brackets because it is not
  //   handled in the if0 cycle.
  //
  //     CP15
  //     $ allocation (pd1/if0 LFB valid means that $alloc required next cycle)
  //     PDC
  //     (Pre-fetch: determined in if1)
  //     MBIST
  //
  //   The tagram and dataram control signals for each type of request are all
  //   set up in if0 so that they can be selected quickly in if1, using a simple
  //   mux, to improve timing on the RAM interface.
  //----------------------------------------------------------------------------

  // Use registered MBIST signal.  This is safe as there will be no MBIST
  // transactions on the first cycle of gov_mbist_req_i being asserted.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ctl_mbist_req <= 1'b0;
    else
      ctl_mbist_req <= gov_mbist_req_i;

  // Shared terms for MBIST accesses, indicating whether any IFU RAM is selected
  // for an operation and which individual RAM.  These versions are not
  // qualified with the global MBIST request signal.
  assign mbist_sel_ifu_tag[1]  = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_101)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | mbist_write_en_mb3_i);
  assign mbist_sel_ifu_tag[0]  = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_100)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | mbist_write_en_mb3_i);

  assign mbist_sel_ifu_data[3] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_001)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | (mbist_write_en_mb3_i & (mbist_be_mb3_i[3:2] != 2'b00)));
  assign mbist_sel_ifu_data[2] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_001)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | (mbist_write_en_mb3_i & (mbist_be_mb3_i[1:0] != 2'b00)));
  assign mbist_sel_ifu_data[1] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_000)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | (mbist_write_en_mb3_i & (mbist_be_mb3_i[3:2] != 2'b00)));
  assign mbist_sel_ifu_data[0] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_000)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | (mbist_write_en_mb3_i & (mbist_be_mb3_i[1:0] != 2'b00)));

  assign mbist_sel_ifu_btac[1] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_011)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | mbist_write_en_mb3_i);
  assign mbist_sel_ifu_btac[0] = ((mbist_sel_i & (mbist_array_mb3_i[6:0] == 7'b0010_010)) | mbist_cfg_mb3_i) &
                                 (mbist_read_en_mb3_i | mbist_write_en_mb3_i);

  // Indication of cache access requests in if0, for both tag and data.
  // These are not aribitrated, but show all present requests.
  // - Tag
  assign ic_req_tag_raw_if0[REQ_MBIST]  = ctl_mbist_req;
  assign ic_req_tag_raw_if0[REQ_PDC]    = 1'b0;  // No tag operations for PDC
  assign ic_req_tag_raw_if0[REQ_ALLOC]  = |lfb_tagram_en_if0_i[1:0];
  assign ic_req_tag_raw_if0[REQ_CP15]   = |cp15_tag_en_i[1:0];
  // - Data
  assign ic_req_data_raw_if0[REQ_MBIST] = ctl_mbist_req;
  assign ic_req_data_raw_if0[REQ_PDC]   = pdc_req_i;
  assign ic_req_data_raw_if0[REQ_ALLOC] = lfb_dataram_en_if0_i;
  assign ic_req_data_raw_if0[REQ_CP15]  = |cp15_data_en_i[1:0];

  // Arbitrate the if0 requests.  These tag and data requests are each zero or
  // one-hot, showing the highest-priority request.  Note that there will be no
  // other requests while in MBIST mode so this simplifies the logic.
  // - Tag
  assign ic_req_tag_arb_if0[REQ_MBIST]  = ic_req_tag_raw_if0[REQ_MBIST];
  assign ic_req_tag_arb_if0[REQ_PDC]    = 1'b0;  // No tag operations for PDC
  assign ic_req_tag_arb_if0[REQ_ALLOC]  = ic_req_tag_raw_if0[REQ_ALLOC];
  assign ic_req_tag_arb_if0[REQ_CP15]   = ic_req_tag_raw_if0[REQ_CP15] & ~ic_req_tag_raw_if0[REQ_ALLOC];
  // - Data
  assign ic_req_data_arb_if0[REQ_MBIST] = ic_req_data_raw_if0[REQ_MBIST];
  assign ic_req_data_arb_if0[REQ_PDC]   = ic_req_data_raw_if0[REQ_PDC];
  assign ic_req_data_arb_if0[REQ_ALLOC] = ic_req_data_raw_if0[REQ_ALLOC] & ~ic_req_data_raw_if0[REQ_PDC];
  assign ic_req_data_arb_if0[REQ_CP15]  = ic_req_data_raw_if0[REQ_CP15]  & ~ic_req_data_raw_if0[REQ_PDC] & ~ic_req_data_raw_if0[REQ_ALLOC];


  // MBIST
  //  - Tag and data
  assign mbist_tagram_en_if0    = { 2{ ic_req_tag_arb_if0[REQ_MBIST]}} & mbist_sel_ifu_tag;
  assign mbist_tagram_addr_if0  = { 9{ ic_req_tag_arb_if0[REQ_MBIST]}} & mbist_addr_mb3_i[8:0];
  assign mbist_tagram_wr_if0    =      ic_req_tag_arb_if0[REQ_MBIST]   & mbist_write_en_mb3_i;
  assign mbist_tagram_wdata_if0 = {31{ ic_req_tag_arb_if0[REQ_MBIST]}} & biu_i_rdata_i[30:0];  // Lower bits only when l1ecc
  assign mbist_dataram_en_if0   = { 4{ic_req_data_arb_if0[REQ_MBIST]}} & mbist_sel_ifu_data[3:0];
  assign mbist_dataram_wr_if0   =     ic_req_data_arb_if0[REQ_MBIST]   & mbist_write_en_mb3_i;
  assign mbist_dataram_addr_if0 = {12{ic_req_data_arb_if0[REQ_MBIST]}} & mbist_addr_mb3_i[11:0];
  assign mbist_dataram_strb_if0 = { 4{ic_req_data_arb_if0[REQ_MBIST]}} & mbist_be_mb3_i & {4{mbist_write_en_mb3_i}};
  assign mbist_dataram_wdata_if0= {80{ic_req_data_arb_if0[REQ_MBIST]}} & biu_i_rdata_i[79:0];  // Lower bits only when l1ecc
  //  - BTAC
  assign mbist_btac_en_if0      = {2{ctl_mbist_req}} & mbist_sel_ifu_btac;

  // CP15
  assign cp15_tagram_en_if0      = { 2{ ic_req_tag_arb_if0[REQ_CP15]}}  & cp15_tag_en_i;
  assign cp15_tagram_addr_if0    = { 9{ ic_req_tag_arb_if0[REQ_CP15]}}  & cp15_addr_i[11:3];
  assign cp15_tagram_wr_if0      =      ic_req_tag_arb_if0[REQ_CP15]    & cp15_tag_wr_i;
  assign cp15_tagram_wdata_if0   = {31{ ic_req_tag_arb_if0[REQ_CP15]}}  & TAG_INVALID;
  assign cp15_data_bank_en_if0   = corkscrew(cp15_data_en_i[1:0], cp15_addr_i[0]);
  assign cp15_dataram_en_if0     = { 4{ic_req_data_arb_if0[REQ_CP15]}}  & {{2{cp15_data_bank_en_if0[1]}}, {2{cp15_data_bank_en_if0[0]}}};
  assign cp15_dataram_wr_if0     =     ic_req_data_arb_if0[REQ_CP15]    & cp15_data_wr_i;
  assign cp15_dataram_strb0_if0  = {4 {ic_req_data_arb_if0[REQ_CP15]    & cp15_data_wr_i}};
  assign cp15_dataram_strb1_if0  = {4 {ic_req_data_arb_if0[REQ_CP15]    & cp15_data_wr_i}};
  assign cp15_dataram_addr_if0   = {12{ic_req_data_arb_if0[REQ_CP15]}}  & cp15_addr_i[11:0];
  assign cp15_dataram_wdata_if0  = {80{ic_req_data_arb_if0[REQ_CP15]}}  & DATA_INVALID;

  // PDC
  assign pdc_dataram_en_if0     = { 4{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_en_if0_i;
  assign pdc_dataram_wr_if0     =     ic_req_data_arb_if0[REQ_PDC];
  assign pdc_dataram_addr0_if0  = {12{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_addr0_if0_i;
  assign pdc_dataram_addr1_if0  = {12{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_addr1_if0_i;
  assign pdc_dataram_strb0_if0  = { 4{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_strb_if0_i[3:0];
  assign pdc_dataram_strb1_if0  = { 4{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_strb_if0_i[7:4];
  assign pdc_dataram_wdata0_if0 = {80{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_wdata_if0_i[79:0];
  assign pdc_dataram_wdata1_if0 = {80{ic_req_data_arb_if0[REQ_PDC]}}   & pdc_wdata_if0_i[159:80];

  // Allocation
  assign lfb_tagram_addr_if0    = { 9{ ic_req_tag_arb_if0[REQ_ALLOC]}} & lfb_tagram_addr_if0_i;
  assign lfb_tagram_wr_if0      =      ic_req_tag_arb_if0[REQ_ALLOC]   & lfb_tagram_wr_if0_i;
  assign lfb_tagram_wdata_if0   = {31{ ic_req_tag_arb_if0[REQ_ALLOC]}} & lfb_tagram_wdata_if0_i;
  assign lfb_dataram_wr_if0     =     ic_req_data_arb_if0[REQ_ALLOC]   & lfb_dataram_wr_if0_i;
  assign lfb_dataram_addr0_if0  = {12{ic_req_data_arb_if0[REQ_ALLOC]}} & lfb_dataram_addr0_if0_i;
  assign lfb_dataram_addr1_if0  = {12{ic_req_data_arb_if0[REQ_ALLOC]}} & lfb_dataram_addr1_if0_i;
  assign lfb_dataram_strb0_if0  = { 4{ic_req_data_arb_if0[REQ_ALLOC]}} & lfb_dataram_strb0_if0_i;
  assign lfb_dataram_strb1_if0  = { 4{ic_req_data_arb_if0[REQ_ALLOC]}} & lfb_dataram_strb1_if0_i;

  // Combine aribitrated control signals
  //   Note that the dataram WDATA for allocation from the LFB is only available
  //   on the next cycle so it is not included here.
  assign tagram_addr_if0    = lfb_tagram_addr_if0   | cp15_tagram_addr_if0                            | mbist_tagram_addr_if0;
  assign tagram_wr_if0      = lfb_tagram_wr_if0     | cp15_tagram_wr_if0                              | mbist_tagram_wr_if0;
  assign tagram_wdata_if0   = lfb_tagram_wdata_if0  | cp15_tagram_wdata_if0                           | mbist_tagram_wdata_if0;
  assign dataram_wr_if0     = lfb_dataram_wr_if0    | cp15_dataram_wr_if0    | pdc_dataram_wr_if0     | mbist_dataram_wr_if0;
  assign dataram_addr0_if0  = lfb_dataram_addr0_if0 | cp15_dataram_addr_if0  | pdc_dataram_addr0_if0  | mbist_dataram_addr_if0;
  assign dataram_addr1_if0  = lfb_dataram_addr1_if0 | cp15_dataram_addr_if0  | pdc_dataram_addr1_if0  | mbist_dataram_addr_if0;
  assign dataram_strb0_if0  = lfb_dataram_strb0_if0 | cp15_dataram_strb0_if0 | pdc_dataram_strb0_if0  | mbist_dataram_strb_if0;
  assign dataram_strb1_if0  = lfb_dataram_strb1_if0 | cp15_dataram_strb1_if0 | pdc_dataram_strb1_if0  | mbist_dataram_strb_if0;
  assign dataram_wdata0_if0 =                         cp15_dataram_wdata_if0 | pdc_dataram_wdata0_if0 | mbist_dataram_wdata_if0;
  assign dataram_wdata1_if0 =                         cp15_dataram_wdata_if0 | pdc_dataram_wdata1_if0 | mbist_dataram_wdata_if0;

  // Arbitrated enable signals.  These need to be held off if the if1 bus cannot
  // accept new data (except MBIST which always goes ahead.)  When an LFB
  // allocation requires both a tag+data write we keep these writes in
  // lock-step, so in this case an outstanding data access will stall both the
  // data and tag.
  assign tagram_en_if0  = ({2{(ic_req_tag_arb_if0[REQ_ALLOC]  & tagram_avail_if1 & dataram_avail_if1 & ~ic_req_data_arb_if0[REQ_PDC])}} & lfb_tagram_en_if0_i) |
                          ({2{(ic_req_tag_arb_if0[REQ_CP15]   & tagram_avail_if1                                                    )}} & cp15_tagram_en_if0 ) |
                          ({2{(ic_req_tag_arb_if0[REQ_MBIST]                                                                        )}} & mbist_tagram_en_if0);

  assign dataram_en_if0 = ({4{(ic_req_data_arb_if0[REQ_ALLOC] & tagram_avail_if1 & dataram_avail_if1)}} & {4{lfb_dataram_en_if0_i}}) |
                          ({4{(ic_req_data_arb_if0[REQ_CP15]  & dataram_avail_if1                   )}} &    cp15_dataram_en_if0   ) |
                          ({4{(ic_req_data_arb_if0[REQ_PDC]   & dataram_avail_if1                   )}} &    pdc_dataram_en_if0    ) |
                          ({4{(ic_req_data_arb_if0[REQ_MBIST] & dataram_avail_if1                   )}} &    mbist_dataram_en_if0  );

  // Enable if0 -> if1 tag/data registers when the if1 stage is available to
  // take new data, and either there's new data to provide (i.e. an if0 request)
  // or the if1 register needs to be cleared (i.e. no new if0 request and the
  // if1 stage still asserted.)
  //
  // An MBIST request will enable the registers regardless, as any other data is
  // discarded.
  assign if0_if1_tag_en  = ic_req_tag_arb_if0[REQ_MBIST]  | (tagram_avail_if1  & (|{ic_req_tag_raw_if0,  tagram_en_prearb_if1 }));  // {new if0, clear if1}
  assign if0_if1_data_en = ic_req_data_arb_if0[REQ_MBIST] | (dataram_avail_if1 & (|{ic_req_data_raw_if0, dataram_en_prearb_if1}));  // {new if0, clear if1}
  assign cp15_req_if0    = ic_req_tag_arb_if0[REQ_CP15] & cp15_active_i[1]; // cp15 in if0 excluding debug ops

  // Tag RAM if0 -> if1
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      tagram_en_prearb_if1  <= 2'b00;
      tagram_wr_prearb_if1  <= 1'b0;
      cp15_req_if1          <= 1'b0;
    end else if (if0_if1_tag_en) begin
      tagram_en_prearb_if1  <= tagram_en_if0;
      tagram_wr_prearb_if1  <= tagram_wr_if0;
      cp15_req_if1          <= cp15_req_if0;
    end

  always @ (posedge clk)
    if (if0_if1_tag_en) begin
      tagram_addr_prearb_if1  <= tagram_addr_if0;
      tagram_wdata_prearb_if1 <= tagram_wdata_if0;
    end

  // Data RAM if0 -> if1
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      dataram_en_prearb_if1    <= 4'b0000;
      dataram_wr_prearb_if1    <= 1'b0;
      dataram_strb0_prearb_if1 <= 4'b0000;
      dataram_strb1_prearb_if1 <= 4'b0000;
      lfb_alloc_req_data_if1   <= 1'b0;
    end else if (if0_if1_data_en) begin
      dataram_en_prearb_if1    <= dataram_en_if0;
      dataram_wr_prearb_if1    <= dataram_wr_if0;
      dataram_strb0_prearb_if1 <= dataram_strb0_if0;
      dataram_strb1_prearb_if1 <= dataram_strb1_if0;
      lfb_alloc_req_data_if1   <= ic_req_data_arb_if0[REQ_ALLOC];
    end

  always @ (posedge clk)
    if (if0_if1_data_en) begin
      dataram_addr0_prearb_if1  <= dataram_addr0_if0;
      dataram_addr1_prearb_if1  <= dataram_addr1_if0;
      dataram_wdata0_prearb_if1 <= dataram_wdata0_if0;
      dataram_wdata1_prearb_if1 <= dataram_wdata1_if0;
    end

  // MBIST
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      mbist_read_if1    <= 1'b0;
      mbist_write_if1   <= 1'b0;
      mbist_ram_sel_if1 <= 3'b000;
      mbist_btac_en_if1 <= 2'b00;
    end else if (ctl_mbist_req) begin
      mbist_read_if1    <= nxt_mbist_read_if1;
      mbist_write_if1   <= nxt_mbist_write_if1;
      mbist_ram_sel_if1 <= mbist_array_mb3_i[2:0];
      mbist_btac_en_if1 <= mbist_btac_en_if0;
    end

  // Indicate MBIST read/write only when the MBIST op targets the IFU
  assign nxt_mbist_read_if1  = mbist_read_en_mb3_i  & (((mbist_array_mb3_i[6:3] == 4'b0010) & mbist_sel_i) | mbist_cfg_mb3_i);
  assign nxt_mbist_write_if1 = mbist_write_en_mb3_i & (((mbist_array_mb3_i[6:3] == 4'b0010) & mbist_sel_i) | mbist_cfg_mb3_i);

  // If any pre-arbitrated dataram operation (allocation, PDC or debug data
  // read) is queueing for 16 cycles in if1 and has still not gone ahead,
  // then temporarily stop the pre-fetch block to let it through.  This ensures
  // that such operations will not be locked out for a long time.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      dataram_wait_cnt <= 4'b0000;
    else if (dataram_wait_cnt_we)
      dataram_wait_cnt <= nxt_dataram_wait_cnt;

  assign nxt_dataram_wait_cnt = ((|dataram_en_prearb_if1) & ic_lookup) ? (dataram_wait_cnt + 4'b0001) : 4'b0000;
  assign dataram_wait_cnt_we  =  (|dataram_en_prearb_if1) | (dataram_wait_cnt != 4'b0000);


  //----------------------------------------------------------------------------
  // if0: Stalls
  //
  //   Stall various blocks based on cache access requests in if0 and if1.  Note
  //   that:
  //
  //     LFB allocation always requires data access, sometimes also tag access
  //     CP15 requires tag (invalidate, dbg tag) or data access (dbg data)
  //     PDC only requires data access
  //
  //   As such we can sometimes allow two different operations to proceed in
  //   if1, hence reducing the stalls in if0, if the two operations are not
  //   interfering.
  //----------------------------------------------------------------------------

  // The LFB stalls when the if1 bus is occuped with either a tag or data
  // operation that can't yet proceed due to a lookup (we stall for both tag and
  // data because if0 LFB tag/data requests are kept in lockstep.)  A PDC in if0
  // also stalls the LFB because this is higher priority.  The stall is only
  // indicated when there is actually an LFB request in if0.
  assign ctl_stall_lfb_if0 = ic_req_data_raw_if0[REQ_ALLOC] &
                             (ic_req_data_raw_if0[REQ_PDC] |
                              (pfb_ic_lookup & (|{tagram_en_prearb_if1, dataram_en_prearb_if1})));

  // CP15 tag:
  //   Must stall when the if0 bus has a higher priority request (allocation)
  //   or CP15 can't move to if1 because the if1 bus already has an
  //   outstanding tag operation that's waiting due to a lookup
  // CP15 data:
  //   Stall when there's a higher priority data op in if0 (allocation, PDC) or
  //   there's any tag/data operation on the if1 bus that's waiting due to
  //   a lookup.
  assign ctl_stall_tag_cp15      = ic_req_tag_arb_if0[REQ_ALLOC] | (pfb_ic_lookup & (|tagram_en_prearb_if1));
  assign ctl_stall_data_cp15     = ic_req_data_arb_if0[REQ_ALLOC] | ic_req_data_arb_if0[REQ_PDC] | (pfb_ic_lookup & (|{tagram_en_prearb_if1,dataram_en_prearb_if1}));
  assign ctl_stall_tag_cp15_if1  = ic_lookup;     // Both speculative and non-speculative lookups
  assign ctl_stall_data_cp15_if1 = pfb_ic_lookup; // Non-speculative lookups only (speculative don't read the data RAM)

  // PDC will only stall if the if1 bus is busy and cannot drained due to a lookup in progress
  assign ctl_stall_pdc_if0 = pfb_ic_lookup & (|dataram_en_prearb_if1);


  //----------------------------------------------------------------------------
  // if1: Pre-fetch requests
  //
  //   We evaluate a pre-fetch request in if1 when we are not stalling while the
  //   data for the previous request is outstanding.  At this point an evaluated
  //   request is considered valid.
  //
  //   The instruction caches are read when there is a valid if1 request.
  //
  //   The cache hit signal is too late to factor into this logic, so we use
  //   a registered evaluate term that was constructed on the previous cycle.
  //   For stalling transactions, this leads to a spurious request that will
  //   look up in the RAMs and will be followed by another lookup at the end of
  //   the stall.
  //----------------------------------------------------------------------------

  // A kill or force from the PFB, or an if3 hit (fast signal) means that any
  // stall will end this cycle and we can evaluate the request immediately.
  assign evaluate_pfb_now = pfb_kill_if2_i | pfb_force_if1_i | hit_if3;

  // Register using previous cycle for everything else
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      evaluate_pfb_q <= 1'b1;
    else
      evaluate_pfb_q <= nxt_evaluate_pfb;

  // On the next cycle:
  //   - Set evaluation if there's a kill/force/hit_if3 on this cycle.  This is
  //     required in case there's an if2 hit (which is too late to use directly,)
  //     but will result in a spurious request if there's not.
  //   - Clear if there's an if2 miss or future hit this cycle.  The stall
  //     arising from this means that we'll not need to do another lookup until
  //     the hit_if3 arrives.
  assign nxt_evaluate_pfb = evaluate_pfb_now |
                            (evaluate_pfb_q & ~(miss_if2 | hit_f_if2));

  // Final evaluate term
  assign evaluate_pfb = evaluate_pfb_q | evaluate_pfb_now;

  // Perform if1 lookup
  assign ctl_pfb_valid_if1 = pfb_valid_if1_i & evaluate_pfb;

  // Record for next cycle that a lookup was performed
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ctl_pfb_valid_if2 <= 1'b0;
    else
      ctl_pfb_valid_if2 <= ctl_pfb_valid_if1;


  //----------------------------------------------------------------------------
  // if1: Arbitration
  //
  //   Arbitrate between pre-fetch requests that need to perform instruction
  //   cache lookups and and other requests that were aribtrated in if0.
  //
  //   Any PFB I$ lookup will stall other requests in if1.  Even if the PFB
  //   lookup is to the data RAM only, we still stall any non-PFB tag requests
  //   in if1.
  //----------------------------------------------------------------------------

  // Tag RAM
  assign tagram_en_if1      = ic_lookup_tagram_en | (tagram_en_prearb_if1 & {2{~ic_lookup}});
  assign tagram_wr_if1      = ~ic_lookup & tagram_wr_prearb_if1;
  assign tagram_addr_if1    =  ic_lookup ? ic_lookup_tagram_addr : tagram_addr_prearb_if1;
  assign tagram_wdata_if1   = tagram_wdata_prearb_if1;

  // Data RAM
  //   As well as arbitrating in cache lookups, a small amount of arbitration
  //   for allocation from the LFB is included here because the LFB data was not
  //   available in the if0 arbitration stage.
  assign dataram_en_if1     =  ic_lookup_dataram_en | (dataram_en_prearb_if1 & {4{~pfb_ic_lookup}});
  assign dataram_wr_if1     = ~pfb_ic_lookup & dataram_wr_prearb_if1;
  assign dataram_addr0_if1  =  pfb_ic_lookup ? ic_lookup_dataram_addr0 : dataram_addr0_prearb_if1;
  assign dataram_addr1_if1  =  pfb_ic_lookup ? ic_lookup_dataram_addr1 : dataram_addr1_prearb_if1;
  assign dataram_strb0_if1  = {`CA53_IDATA_WEN_W{~pfb_ic_lookup & (|dataram_en_prearb_if1[1:0])}} & dataram_strb0_prearb_if1;
  assign dataram_strb1_if1  = {`CA53_IDATA_WEN_W{~pfb_ic_lookup & (|dataram_en_prearb_if1[3:2])}} & dataram_strb1_prearb_if1;
  assign dataram_wdata0_if1 = dataram_wdata0_prearb_if1 | ({80{lfb_alloc_req_data_if1}} & lfb_data_i[ 79: 0]);
  assign dataram_wdata1_if1 = dataram_wdata1_prearb_if1 | ({80{lfb_alloc_req_data_if1}} & lfb_data_i[159:80]);

  // Based on the contents of the pre-arbitrated if1 requests, and whether
  // a lookup is being performed, indicate back to if0 whether any additional
  // tag/data requests can be accepted.  A request can always be accepted if
  // the if1 slot is currently empty, or if there's no PFB lookup being
  // performed.  In the latter case anything currently in the if1 slot will
  // drain.
  assign tagram_avail_if1  = ~(|tagram_en_prearb_if1)  | ~ic_lookup;     // Real or speculative lookup drains the if1 tag bus
  assign dataram_avail_if1 = ~(|{tagram_en_prearb_if1,dataram_en_prearb_if1}) | ~pfb_ic_lookup; // Only real lookups drain the if1 tag bus (speculative ones are tag-only)

  // Inform the LFB logic that the LFB will be allocated this cycle
  assign ctl_lfb_alloc = lfb_alloc_req_data_if1 & ~ic_lookup;

  // Add parity bits to RAM write data when parity is configured.  Parity bits
  // are not computed for MBIST requests and instead the extra data bits that
  // are present in the l1ecc config are added here.
  generate if (CPU_CACHE_PROTECTION > 0) begin : genif_parity_wdata
    // MBIST write data is taken from biu_i_rdata_i and pushed through the
    // standard arbitration logic, re-using the pipeline registers.  However
    // when CPU_CACHE_PROTECTION is on one extra bit is required for the tagram
    // wdata, and four extra bits for the dataram wdata.  These bits don't exist
    // in the arbitration pipeline because parity bits are inserted at the end,
    // so we use some dedicated registers for the extra bits here.
    reg [4:0] mbist_wdata_l1ecc;  // bits [4:1] used for dataram, bit[0] for tagram

    always @ (posedge clk)
      if (ctl_mbist_req)
        mbist_wdata_l1ecc <= {biu_i_rdata_i[83:80], biu_i_rdata_i[31]};

    // For MBIST requests inject the additional bits into the final write data.
    // For other requests compute and insert parity bits.
    assign tagram_wdata_if1_pty   = ctl_mbist_req ? { mbist_wdata_l1ecc[0],   tagram_wdata_if1[30:0]} :
                                                    {^tagram_wdata_if1[30:0], tagram_wdata_if1[30:0]};

    assign dataram_wdata0_if1_pty = ctl_mbist_req ? { mbist_wdata_l1ecc[4:1],    dataram_wdata0_if1[79:0]} :
                                                    {^dataram_wdata0_if1[79:60], dataram_wdata0_if1[79:60],
                                                     ^dataram_wdata0_if1[59:40], dataram_wdata0_if1[59:40],
                                                     ^dataram_wdata0_if1[39:20], dataram_wdata0_if1[39:20],
                                                     ^dataram_wdata0_if1[19: 0], dataram_wdata0_if1[19: 0]};
    assign dataram_wdata1_if1_pty = ctl_mbist_req ? { mbist_wdata_l1ecc[4:1],    dataram_wdata1_if1[79:0]} :
                                                    {^dataram_wdata1_if1[79:60], dataram_wdata1_if1[79:60],
                                                     ^dataram_wdata1_if1[59:40], dataram_wdata1_if1[59:40],
                                                     ^dataram_wdata1_if1[39:20], dataram_wdata1_if1[39:20],
                                                     ^dataram_wdata1_if1[19: 0], dataram_wdata1_if1[19: 0]};
  end else begin : genif_parity_wdata_stubs
    assign tagram_wdata_if1_pty   = tagram_wdata_if1;
    assign dataram_wdata0_if1_pty = dataram_wdata0_if1;
    assign dataram_wdata1_if1_pty = dataram_wdata1_if1;
  end endgenerate

  //----------------------------------------------------------------------------
  // if1 -> if2 pipeline registers and stall terms
  //----------------------------------------------------------------------------

  // Indicate that the pre-fetch block is stalled.  This stall is high from the
  // start of an if2 cycle until the hit is provided.  It is a late signal
  // because the cache hit needs to be factored in.
  assign stall_pfb = pfb_valid_if2 & pfb_utlb_hit_if2_i & ~(pfb_kill_if2_i | pfb_force_if1_i) &
                     ~(lfb_hit_past_i | lfb_hit_pres_i | icb_hit_if2);

  // Pre-fetch request in if2
  always @ (posedge clk or negedge reset_n)
   if (!reset_n) begin
      pfb_valid_if2 <= 1'b0;
      pfb_first_if2 <= 1'b0;
    end else if (pfb_valid_if2_we) begin
      pfb_valid_if2 <= pfb_valid_if1_i;
      pfb_first_if2 <= nxt_pfb_first_if2;
    end

  assign pfb_valid_if2_we = ~stall_pfb;
  assign nxt_pfb_first_if2 = pfb_valid_if1_i & pfb_first_if1_i;

  // Register various if1 signals into if2 for timing improvement
  always @ (posedge clk)
    if (pfb_valid_if2_we)
      pfb_va_3_if2 <= pfb_va_if1_i[3];


  //----------------------------------------------------------------------------
  // if1: Determine cacheability of pre-fetch requests
  //----------------------------------------------------------------------------

  // The cacheable attributes must be evaluated in both if1 and if2 because the
  // HCR.id bit could change between if1 and if2 causing a request to change
  // cacheability. Furthermore we must keep the if2 version stable because it is
  // used by the LFB to evaluate incoming requests.
  //
  // The definition of cacheability is:
  //   - dpu_icache_on TRUE
  //   - HCR.id and ns and EL inside EL0|EL1 not true
  //   - uTLB attributs WB|WT (only available in if2)
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      icache_on    <= 1'b0;
    end else begin
      icache_on    <= dpu_icache_on_i;
    end

  // Create an if1 cache on signal which to be used when evaluating a PFB
  // request with 'first' high.  This is always used with pfb_ic_lookup so does
  // not need to be qualified further.
  //
  // When there is an invalidate operation during a first_if1, we force cache on
  // LOW so that in if2 for this and subsequent sequential requests the
  // transaction will be made non-cacheable.  Where the invalidate operation was
  // in the middle of a set of sequential requests, the if2 cache on signal
  // remains HIGH because the power saving technique means that we don't need to
  // access the tags for the remaining sequential accesses so there's no chance
  // of data corruption.
  //
  //   Note: cp15_active_i indicates a CP15 operation in if0 but we still need
  //   to turn non-cacheable if the CP15 has gone into if1 and there's a lookup.
  //   We therefore need to register cp15_active.
  assign icb_cache_on_if1 = pfb_first_if1_i ? (icache_on & ~(cp15_active_i[1] | cp15_req_if1)) : icb_cache_on_if2;
  assign dpu_cache_on_if1 = pfb_first_if1_i ? icache_on : dpu_cache_on_if2;

  // if2
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      icb_cache_on_if2 <= 1'b0;
      dpu_cache_on_if2 <= 1'b0;
    end else if (cache_on_if2_we) begin
      icb_cache_on_if2 <= icb_cache_on_if1;
      dpu_cache_on_if2 <= dpu_cache_on_if1;
    end

  assign cache_on_if2_we = ctl_pfb_valid_if1 & pfb_first_if1_i & ~stall_pfb;


  //----------------------------------------------------------------------------
  // Instruction cache lookup (if1/3) and hit detection (if2)
  //----------------------------------------------------------------------------

  // I$ lookups always occur:
  //   - in if1 when the PFB request is valid, just before moving into if2
  //   - the last cycle of if3, when there was a previous miss in the pipeline
  //
  // When caches are off (e.g. CP15 operation) the if1 lookup is still
  // performed, but only to the data RAM.  The data RAMs are accessedin case
  // there is a non-cacheable LFB hit that has stored data in the RAMs.
  //
  // Even when there is a $miss in if2 we will still go ahead and make the new
  // lookup in if1, even though the current miss means that we will be in no
  // position to use the result of the lookup.  We treat this as a suprious
  // lookup because the cache miss signal is too late to be used to suppress it.
  //
  // We'll perform the lookup again in if3 when the stall has cleared; the if3
  // hit signal is much less critical.

  // Note pfb_ic_lookup is high even if caches are off in if1 because a dataram
  // lookup is still performed in case there's an LFB 'past' hit.  The lookup
  // signal is used together with the cache on signal to determine whether a tag
  // lookup is performed and whether a tag comparison will be performed.
  assign pfb_ic_lookup = ctl_pfb_valid_if1;
  assign ic_lookup     = pfb_ic_lookup | spec_ic_lookup;

  // Optimised lookup terms for tag and data RAMs, avoiding unnecessary accesses
  // during sequential requests
  assign ic_lookup_tag  = (pfb_ic_lookup & ic_lookup_tag_mask_if1) | spec_ic_lookup;
  assign ic_lookup_data = {4{pfb_ic_lookup}} & ic_lookup_data_mask_if1;

  // Lookup
  assign ic_lookup_tagram_en      = {2{ic_lookup_tag & icb_cache_on_if1}}; // Caches off => no tag read
  assign ic_lookup_tagram_addr    = ({9{pfb_ic_lookup}} & pfb_va_if1_i[14:6]) | ({9{spec_ic_lookup}} & spec_va[14:6]);
  assign ic_lookup_dataram_en     = ic_lookup_data;
  assign ic_lookup_dataram_addr0  = pfb_va_if1_i[14:3];
  assign ic_lookup_dataram_addr1  = pfb_va_if1_i[14:3];

  // ic_compare is a pulse that's set in an if2-cycle where a comparison of
  // cache RAM tags will be made to determine whether there's a cache hit.  When
  // the caches are off in if1 we don't do a compare in if2.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      pfb_ic_compare_q <= 1'b0;
    else if (pfb_ic_compare_we)
      pfb_ic_compare_q <= pfb_ic_compare_d;

  assign pfb_ic_compare_we = (pfb_ic_lookup & icb_cache_on_if1) | pfb_ic_compare_q;
  assign pfb_ic_compare_d  = pfb_ic_lookup & icb_cache_on_if1;

  // Don't compare on a spurious lookup.  The lookup was spurious when:
  //   - we are still stalling, so the lookup was not for a real request; or
  //   - an LFB wait is indicated, so the real lookup is still waiting for if3
  assign pfb_ic_compare = pfb_ic_compare_q & ~(stall_if3 | lfb_wait_if3 | hit_if3);

  // Combined compare signal for both PFB and speculative lookups
  assign ic_compare = pfb_ic_compare | spec_ic_compare;

  // Determine whether the lookup is cacheable and privileged
  assign pfb_attributes_if2  = (dpu_cache_on_if2 | ~(`CA53_MEM_NORMAL(pfb_attributes_if2_i))) ? pfb_attributes_if2_i : `CA53_MEM_ICACHE_DISABLED;
  assign pfb_attrs_cacheable = icb_cache_on_if2 &  (`CA53_MEM_WB(pfb_attributes_if2) | `CA53_MEM_WT(pfb_attributes_if2));
  assign pfb_priv_if2        = pfb_priv_if2_i |  (`CA53_MEM_WB(pfb_attributes_if2) | `CA53_MEM_WT(pfb_attributes_if2));

  // Tag RAM entries valid (per bank, not per way).  Note that when caches were
  // off, the ic_compare signal will be low and this logic will report both tags
  // invalid.
  assign ic_tag_valid_if2[1]  = pfb_ic_compare  & ~(ic_tagram_rdata1[30] & ic_tagram_rdata1[29]);
  assign ic_tag_valid_if2[0]  = pfb_ic_compare  & ~(ic_tagram_rdata0[30] & ic_tagram_rdata0[29]);
  assign spec_ic_tag_valid[1] = spec_ic_compare & ~(ic_tagram_rdata1[30] & ic_tagram_rdata1[29]);
  assign spec_ic_tag_valid[0] = spec_ic_compare & ~(ic_tagram_rdata0[30] & ic_tagram_rdata0[29]);

  // Almost hit is a hit calculation involving everything except the state bits.
  // Where there was a miss, the 'almost hit' signals factor into the way
  // selection algorithm for the new LFB entry where we'll allocate the new
  // entry to the opposite way to the one that almost hit.
  assign ic_almost_hit_if2[1]  = ic_tag_valid_if2[1]                             & // Valid on compare cycle
                                 (ic_tagram_rdata1[28]   == pfb_ns_dsc_if2_i)    & // Secure bit
                                 (ic_tagram_rdata1[27:0] == pfb_pa_if2_i[39:12]) & // PA
                                 pfb_attrs_cacheable;                              // Cacheable
  assign ic_almost_hit_if2[0]  = ic_tag_valid_if2[0]                             & // Valid on compare cycle
                                 (ic_tagram_rdata0[28]   == pfb_ns_dsc_if2_i)    & // Secure bit
                                 (ic_tagram_rdata0[27:0] == pfb_pa_if2_i[39:12]) & // PA
                                 pfb_attrs_cacheable;                              // Cacheable
  assign spec_ic_almost_hit[1] = spec_ic_tag_valid[1]                            & // Valid on compare cycle
                                 (ic_tagram_rdata1[28]   == pfb_ns_dsc_if3)      & // Secure bit
                                 (ic_tagram_rdata1[27:0] == pfb_pa_if3[39:12])   & // PA
                                 pfb_attrs_cacheable;                              // Cacheable
  assign spec_ic_almost_hit[0] = spec_ic_tag_valid[0]                            & // Valid on compare cycle
                                 (ic_tagram_rdata0[28]   == pfb_ns_dsc_if3)      & // Secure bit
                                 (ic_tagram_rdata0[27:0] == pfb_pa_if3[39:12])   & // PA
                                 pfb_attrs_cacheable;                              // Cacheable

  // Final hit terms including state match.  Valid on an if2 cache compare
  // cycle (not a speculative compare cycle).  A cache hit is masked by an LFB
  // hit because in the case of a 'raw' hit in both the I$ and LFB we cannot
  // rely on the I$ tags.  This is because the LFB allocates the tags early,
  // before all of the data chunks have been allocated.
  //
  // A hit on way 0 takes priority over a hit on way 1.  Normally only one way
  // will hit, however due to CP15 hazards a new LFB activation can occur for
  // the same cache line but to the opposite way due to the original request
  // becoming non-hittable.  This is a rare case.
  assign ic_hit_raw_if2[1] = ( ic_lookup_tag_mask_if2 & ic_almost_hit_if2[1] & (ic_tagram_rdata1[30:29] == pfb_state_if2_i)) |  // Tag was read
                             (~ic_lookup_tag_mask_if2 &       tracked_hit[1] & pfb_ic_compare & pfb_attrs_cacheable);           // Tag not read
  assign ic_hit_raw_if2[0] = ( ic_lookup_tag_mask_if2 & ic_almost_hit_if2[0] & (ic_tagram_rdata0[30:29] == pfb_state_if2_i)) |
                             (~ic_lookup_tag_mask_if2 &       tracked_hit[0] & pfb_ic_compare & pfb_attrs_cacheable);
  assign ic_hit_if2[1]     = ic_hit_raw_if2[1] & ~ic_hit_raw_if2[0] & ~lfb_hit_raw_i;
  assign ic_hit_if2[0]     = ic_hit_raw_if2[0]                      & ~lfb_hit_raw_i;

  // Cache hit term for speculative lookups
  assign spec_ic_hit[1] = spec_ic_almost_hit[1] & (ic_tagram_rdata1[30:29] == pfb_state_if3);
  assign spec_ic_hit[0] = spec_ic_almost_hit[0] & (ic_tagram_rdata0[30:29] == pfb_state_if3);

  // Combined, actual cache hit indication (hit purely from the cache, not LFB
  // 'past' hit.)  Any hit indications from the LFB take priority over the
  // cache, because when an LFB entry is active then the data RAM has not yet
  // been fully allocated.
  assign icb_hit_if2 = (|ic_hit_if2[1:0]);

  // Select whether dataram bank0 or bank1 data is being used and assign the
  // correct value to be sent to the pre-fetch block.  This data is for cache
  // hits, not LFB 'past' hits.
  assign ic_data_sel_if2[0] = (mbist_read_if2 & (mbist_ram_sel_if2 == 3'b000)) |                 // MBIST bank 0
                              (ic_hit_if2[0] & ~pfb_va_3_if2) | (ic_hit_if2[1] &  pfb_va_3_if2); // Bank 0 via corkscrew
  assign ic_data_sel_if2[1] = (mbist_read_if2 & (mbist_ram_sel_if2 == 3'b001)) |                 // MBIST bank 1
                              (ic_hit_if2[0] &  pfb_va_3_if2) | (ic_hit_if2[1] & ~pfb_va_3_if2); // Bank 1 via corkscrew

  assign icb_data_if2 = ({80{ic_data_sel_if2[0]}} & ic_dataram_rdata0) |
                        ({80{ic_data_sel_if2[1]}} & ic_dataram_rdata1);


  // Raw hit signal from LFB (past or present, i.e. data is available now) is
  // indicated as an actual hit when there's a valid request in if2 that's not
  // being killed and hits in the uTLB
  assign lfb_hit_if2 = pfb_valid_if2                     &
                       (lfb_hit_pres_i | lfb_hit_past_i) &
                       pfb_utlb_hit_if2_i                &
                       ~pfb_kill_if2_i;


  //----------------------------------------------------------------------------
  // if2: Global hit/miss detection
  //----------------------------------------------------------------------------

  // Create a miss_if2 pulse.  Clears when if3 starts.
  assign miss_if2 = pfb_valid_if2      & // Valid PFB req in if2
                    pfb_utlb_hit_if2_i & // uTLB hits
                    ~icb_hit_if2       & // Neither cache way hits
                    ~lfb_hit_ppf_i     & // No LFB hits of any type
                    // Make a pulse by clearing once if3 is entered or if3 is
                    // is only waiting for the LFB to become available
                    ~(stall_m_if3 | lfb_wait_if3 | hit_if3);

  // Future hit in if2.  Although a future hit is not a miss (because there's an
  // LFB entry for it) it behaves like a miss in many ways except for activating
  // a new LFB.
  assign hit_f_if2 = pfb_valid_if2 & lfb_hit_fut_i & pfb_utlb_hit_if2_i & ~(hit_f_if3 | stall_f_if3);

  // if2 moves to if3 on a miss provided that it's not being killed, and there's
  // a spare LFB entry to handle the if3 stage.  This is only for misses, not
  // future hits, because for future hits there's already an active LFB to deal
  // with the request.
  assign if2_if3_en = (miss_if2 | lfb_wait_if3) & lfb_available_i[0] & ~(pfb_kill_if2_i | pfb_force_if1_i);

  // On an LFB hit the data is returned either from the cache ('past' hits) or
  // the LFB data buffer.  In either case, the data must be swizzled to get the
  // correct half and also account for corkscrew (even when the data comes from
  // the LFB corkscrew must be applied because it was swizzled before being
  // written into the LFB buffer.)
  always @ (*)
    case({icb_dbg_hit_if2_i, lfb_hit_past_i, pfb_va_3_if2})
      3'b100, 3'b101, 3'b110, 3'b111: icb_lfb_data_if2 = lfb_data_i[79:0];

      // 'Past' hit cases: data from cache RAMs using the way specified by the LFB
      3'b010: icb_lfb_data_if2 = lfb_hit_way_i[1] ? ic_dataram_rdata1 : ic_dataram_rdata0;
      3'b011: icb_lfb_data_if2 = lfb_hit_way_i[1] ? ic_dataram_rdata0 : ic_dataram_rdata1;

      // Other cases: data from LFB buffer
      3'b000: icb_lfb_data_if2 = lfb_data_way_i ? lfb_data_i[159:80] : lfb_data_i[ 79: 0];
      3'b001: icb_lfb_data_if2 = lfb_data_way_i ? lfb_data_i[ 79: 0] : lfb_data_i[159:80];

      // Propagate X
      default: icb_lfb_data_if2 = {80{1'bX}};
    endcase


  //----------------------------------------------------------------------------
  // if2: External abort and parity error indication
  //----------------------------------------------------------------------------

  // Indicate an external abort only when the LFB hits on a chunk that aborted.
  // This is determined from the hit_resp signal.
  //
  //    RESP   | ext_abort_if2   | ext_abort_type_if2
  //    ---------------------------------------------
  //    3'b000 | 1'b0 (no abort) | -
  //    3'b001 | 1'b1 (abort)    | 2'b00 (slave)
  //    3'b010 | 1'b1 (abort)    | 2'b00 (slave)
  //    3'b011 | 1'b1 (abort)    | 2'b01 (decode)
  //    3'b1xx | 1'b1 (abort)    | 2'b10 (ECC)
  assign ext_abort_if2      = lfb_hit_if2 & |lfb_hit_resp_i[2:0];
  assign ext_abort_type_if2 = {lfb_hit_resp_i[2], (lfb_hit_resp_i[2:0] == 3'b011)};

  // Parity errors reported in if2 if parity has been configured:
  //   Tag: signal error if a lookup reads a valid tag with a parity mismatch
  //  Data: signal error if a hitting way has a parity bit mismatch
  generate if (CPU_CACHE_PROTECTION) begin : gen_parity_err
    reg  [3:0] dataram_en_if2;
    wire       ic_tagram_pty_bits0;
    wire       ic_tagram_pty_bits1;
    wire [3:0] ic_dataram_pty_bits0; // I$ bank0 rdata parity bits
    wire [3:0] ic_dataram_pty_bits1; // I$ bank1 rdata parity bits
    wire       ic_tagram_pty_chk0;
    wire       ic_tagram_pty_chk1;
    wire [3:0] ic_dataram_pty_chk0;
    wire [3:0] ic_dataram_pty_chk1;
    wire [1:0] tagram_pty_err;       // Parity error on tagram read
    wire [1:0] tagram_pty_err_raw;   // Unqualified tag parity comparison per bank
    wire [1:0] dataram_pty_err;      // Parity error on dataram read
    wire [1:0] dataram_pty_err_raw;  // Unqualified data parity comparison per bank
    reg  [1:0] tracked_tag_valid;
    wire       tracked_tag_valid_we;
    wire       pty_inv_req_we;
    wire       pty_inv_addr_we;
    reg [3:0]  ctl_pty_inv_req_if3;
    reg [14:6] ctl_pty_inv_addr_if3;
    reg        pty_cpumemerrsr_valid;
    reg [3:0]  pty_cpumemerrsr_err_if3;
    reg [14:3] pty_cpumemerrsr_addr_if3;
    wire [14:3] ctl_pty_inv_addr_if2;


    // if2 indication of which data RAMs were enabled, so that we know which
    // parts of the data to include in the parity calculations.  (Some parts of
    // the data RAM might have been turned off as part of the power-saving
    // techniques.)
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        dataram_en_if2 <= 4'b0000;
      else if (pfb_ic_lookup)
        dataram_en_if2 <= dataram_en_if1;

    //
    // Parity Error Calculation Start
    //
    assign ic_dataram_pty_bits0 = {{2{dataram_en_if2[1]}}, {2{dataram_en_if2[0]}}} &
                                  {ic_dataram_rdata0_i[83], ic_dataram_rdata0_i[62], ic_dataram_rdata0_i[41], ic_dataram_rdata0_i[20]};
    assign ic_dataram_pty_bits1 = {{2{dataram_en_if2[3]}}, {2{dataram_en_if2[2]}}} &
                                  {ic_dataram_rdata1_i[83], ic_dataram_rdata1_i[62], ic_dataram_rdata1_i[41], ic_dataram_rdata1_i[20]};
    assign ic_tagram_pty_bits0  = ic_tagram_rdata0_i[31];
    assign ic_tagram_pty_bits1  = ic_tagram_rdata1_i[31];

    // XOR reduce the read tag and data and compare with the stored parity bits
    assign ic_tagram_pty_chk0   = ^ic_tagram_rdata0_i[30:0];
    assign ic_tagram_pty_chk1   = ^ic_tagram_rdata1_i[30:0];
    assign ic_dataram_pty_chk0  = {{2{dataram_en_if2[1]}}, {2{dataram_en_if2[0]}}} &
                                  {^ic_dataram_rdata0_i[82:63], ^ic_dataram_rdata0_i[61:42], ^ic_dataram_rdata0_i[40:21], ^ic_dataram_rdata0_i[19:0]};
    assign ic_dataram_pty_chk1  = {{2{dataram_en_if2[3]}}, {2{dataram_en_if2[2]}}} &
                                  {^ic_dataram_rdata1_i[82:63], ^ic_dataram_rdata1_i[61:42], ^ic_dataram_rdata1_i[40:21], ^ic_dataram_rdata1_i[19:0]};

    // Parity error on tagram access, one bit per bank.
    assign tagram_pty_err_raw = {(ic_tagram_pty_bits1 != ic_tagram_pty_chk1),   // Way 1 check
                                 (ic_tagram_pty_bits0 != ic_tagram_pty_chk0)};  // Way 0 check

    // Parity error on dataram access, one bit per bank.
    assign dataram_pty_err_raw = {(ic_dataram_pty_bits1 != ic_dataram_pty_chk1),  // Bank 1 check
                                  (ic_dataram_pty_bits0 != ic_dataram_pty_chk0)}; // Bank 0 check
    //
    // Parity Error Calculation End
    //

    //
    // Parity Error to PFB Start
    //
    assign tracked_tag_valid_we = pfb_ic_compare & ic_lookup_tag_mask_if2;

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        tracked_tag_valid <= 2'b00;
      else if (tracked_tag_valid_we)
        tracked_tag_valid <= ic_tag_valid_if2;
    // Checking is performed whenever tags are accessed through a real (not speculative)
    // lookup and access to the RAM was not skipped by the the lookup FSM or
    // the cache way tracker.
    assign tagram_pty_err  = tagram_pty_err_raw & {2{pfb_ic_compare & ic_lookup_tag_mask_if2}};

    // Checking is only performed when a hit is indicated in the tag lookup or there is an LFB
    // 'past' hit.  Power-saving optimisations are implicitly included in the
    // tagram hit terms.
    assign lfb_check_pty_err = pfb_valid_if2 & ((lfb_hit_fut_i & ~hit_f_if3) |
                                                lfb_hit_pres_i | lfb_hit_past_i);

    assign dataram_pty_err = dataram_pty_err_raw &
                             (lfb_check_pty_err      ? ({2{lfb_hit_past_i}} & corkscrew(lfb_hit_way_i[1:0],     pfb_va_3_if2)) : // errors related to lfb cache read
                              ic_lookup_tag_mask_if2 ? (                      corkscrew(ic_tag_valid_if2[1:0], pfb_va_3_if2)) : // errors related with TAG valid (currently read)
                                                       ({2{pfb_ic_compare}} & corkscrew(tracked_tag_valid[1:0], pfb_va_3_if2))); // errors related with TAG valid (currently not read)

    // Combined error signal for pre-fetch, reported when there's a parity error
    // on a hitting entry.  This causes the DPU correction mechanism.
    assign icb_parity_err_if2 = {tagram_pty_err[1:0], dataram_pty_err[1:0]};
    //
    // Parity Error to PFB End
    //

    //
    // Parity Error to CP15 Start
    //
    // Overall invalidate signal for CP15 logic to invalidate the tag of an
    // entry that has a parity error.  If an LFB is about to the activated for
    // the same entry then we skip this invalidate step because the tag will be
    // re-written as part of the LFB allocation.  One bit per way.

    // Create the req side of the req/ack handshake and register the address and
    // way information for the CP15 logic.  The write enable is based on
    // pfb_ic_compare rather than pty_invalidate_if2 to avoid the parity
    // calculation, which includes the data RAM outputs, from factoring into the
    // reg's enable term.
    assign pty_inv_req_we  = (pfb_ic_compare & ~(|ctl_pty_inv_req_if3)) | cp15_pty_ack_i;
    assign pty_inv_addr_we =  pfb_ic_compare & ~(|ctl_pty_inv_req_if3 & ~cp15_pty_ack_i); // change address and way on new requests

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        ctl_pty_inv_req_if3 <= 4'h0;
      else if (pty_inv_req_we)
        ctl_pty_inv_req_if3 <= icb_parity_err_if2;

    assign ctl_pty_inv_addr_if2 = {ic_size_i[2:0], 9'b111111111} & pfb_va_if2_i[14:3];
    always @ (posedge clk)
      if (pty_inv_addr_we)
        ctl_pty_inv_addr_if3 <= ctl_pty_inv_addr_if2[14:6];

    // Assign parity-related outputs
    assign ctl_pty_inv_req  = ctl_pty_inv_req_if3;
    assign ctl_pty_inv_addr = ctl_pty_inv_addr_if3[14:6];
    //
    // Parity Error to CP15 End
    //

    //
    // Parity Error to DPU Start
    //
    //
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        pty_cpumemerrsr_valid <= 1'b0;
      else
        pty_cpumemerrsr_valid <= pfb_ic_compare;

    always @ (posedge clk)
      if (pfb_ic_compare) begin
        pty_cpumemerrsr_err_if3  <= icb_parity_err_if2;
        pty_cpumemerrsr_addr_if3 <= ctl_pty_inv_addr_if2[14:3];
      end

    // single shot error detection. If it is valid and there was an error (even those not passed to the DPU)
    assign ifu_pty_valid = |pty_cpumemerrsr_err_if3 & pty_cpumemerrsr_valid;
    // To keep things in order we give priority to TAG errors and WAY0
    // Therefore the priority is TAG0 -> TAG1 -> DATA 0 -> DATA 1
    assign ifu_pty_ramid       = (|pty_cpumemerrsr_err_if3[1:0]) & ~(|pty_cpumemerrsr_err_if3[3:2]);
    assign ifu_pty_way_bank_id = ((pty_cpumemerrsr_err_if3[3]    & ~pty_cpumemerrsr_err_if3[2]) |
                                  (pty_cpumemerrsr_err_if3[1]    & ~(pty_cpumemerrsr_err_if3[0] | pty_cpumemerrsr_err_if3[2])));
    assign ifu_pty_index       = (|pty_cpumemerrsr_err_if3[3:2]) ? {3'b000,pty_cpumemerrsr_addr_if3[14:6]} : pty_cpumemerrsr_addr_if3[14:3];
    //
    // Parity Error to DPU End
    //

    // Speculative cache lookups only access the tag RAM.  We must detect parity
    // errors on the speculative tag lookups so that we do not use a corrupt tag
    // in our decision to start a speculative request.  We don't need to factor
    // in the hit signal here because the speculative parity error is only used
    // alongside the speculative hit to suppress the speculative allocation; it
    // is not used to create any instruction abort.
    assign spec_tagram_pty_err = tagram_pty_err_raw;

  end else begin : gen_parity_err_stubs
    // No parity - tie off parity error indication
    assign spec_tagram_pty_err = 2'b00;
    assign icb_parity_err_if2  = 4'b0000;
    // Parity-related outputs
    assign ctl_pty_inv_req     = 4'b0000;
    assign ctl_pty_inv_addr    = {9{1'b0}};
    assign ifu_pty_valid       = 1'b0;
    assign ifu_pty_ramid       = 1'b0;
    assign ifu_pty_way_bank_id = 1'b0;
    assign ifu_pty_index       = {12{1'b0}};
  end endgenerate


  //----------------------------------------------------------------------------
  // if2/if3: MBIST read pipeline
  //----------------------------------------------------------------------------

  // if2
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      mbist_read_if2    <= 1'b0;
      mbist_ram_sel_if2 <= 3'b000;
    end else if (ctl_mbist_req) begin
      mbist_read_if2    <= mbist_read_if1;
      mbist_ram_sel_if2 <= mbist_ram_sel_if1;
    end

  assign mbist_btac_rd_if2[1] = mbist_read_if2 & ~mbist_ram_sel_if2[2] &  mbist_ram_sel_if2[1] &  mbist_ram_sel_if2[0];
  assign mbist_btac_rd_if2[0] = mbist_read_if2 & ~mbist_ram_sel_if2[2] &  mbist_ram_sel_if2[1] & ~mbist_ram_sel_if2[0];
  assign mbist_tag_rd_if2[1]  = mbist_read_if2 &  mbist_ram_sel_if2[2] & ~mbist_ram_sel_if2[1] &  mbist_ram_sel_if2[0];
  assign mbist_tag_rd_if2[0]  = mbist_read_if2 &  mbist_ram_sel_if2[2] & ~mbist_ram_sel_if2[1] & ~mbist_ram_sel_if2[0];

  // if3
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      mbist_read_if3   <= 1'b0;
      mbist_tag_rd_if3 <= 1'b0;
    end else if (ctl_mbist_req) begin
      mbist_read_if3   <= mbist_read_if2;
      mbist_tag_rd_if3 <= |(mbist_tag_rd_if2[1:0]);  // Indicates which re-used register holds MBIST read data
    end

  assign mbist_rdata_if3 = {`CA53_IDATA_RAM_W{mbist_read_if3}} &
                           (mbist_tag_rd_if3 ? {{(`CA53_IDATA_RAM_W-`CA53_ITAG_RAM_W){1'b0}}, pfb_pa_if3[4+:`CA53_ITAG_RAM_W]} :
                                               pfb_mbist_data[0+:`CA53_IDATA_RAM_W]);


  // MBIST read data is up to 84 bits if CPU_CACHE_PROTECTION is enabled.  When
  // the read data is supplied from the PFB only 80 bits are provided; the
  // additional 4 bits for CPU_CACHE_PROTECTION configs are appended using local
  // ICB registers.
  generate if (CPU_CACHE_PROTECTION > 0) begin : gen_cache_protection_mbist_data
    reg  [3:0] mbist_rdata_l1ecc_if3;      // Local register for top 4 bits of data in l1ecc config
    wire [3:0] nxt_mbist_rdata_l1ecc_if3;
    wire [1:0] mbist_data_rd_if2;
    reg        mbist_btac_rd_if3;

    // Detect MBIST data RAM read.  Only required in l1ecc configs.
    assign mbist_data_rd_if2[1] = mbist_read_if2 & ~mbist_ram_sel_if2[2] & ~mbist_ram_sel_if2[1] &  mbist_ram_sel_if2[0];
    assign mbist_data_rd_if2[0] = mbist_read_if2 & ~mbist_ram_sel_if2[2] & ~mbist_ram_sel_if2[1] & ~mbist_ram_sel_if2[0];

    // These rdata bits are only used for MBIST dataram reads and only enabled
    // under MBIST mode.  For reads to any RAMs other than the data RAMs this
    // register will be set to 0.
    always @ (posedge clk)
      if (mbist_read_if2)
        mbist_rdata_l1ecc_if3 <= nxt_mbist_rdata_l1ecc_if3;

    assign nxt_mbist_rdata_l1ecc_if3 = ({4{mbist_data_rd_if2[0]}} & {ic_dataram_rdata0_i[83],ic_dataram_rdata0_i[62],ic_dataram_rdata0_i[41],ic_dataram_rdata0_i[20]}) |
                                       ({4{mbist_data_rd_if2[1]}} & {ic_dataram_rdata1_i[83],ic_dataram_rdata1_i[62],ic_dataram_rdata1_i[41],ic_dataram_rdata1_i[20]});

    // MBIST BTAC RAM read in if3
    always @ (posedge clk)
      if (ctl_mbist_req)
        mbist_btac_rd_if3 <= |mbist_btac_rd_if2;

    // Data from MBIST reads does not have parity bits so in the l1ecc
    // configuration the data only needs to be padded to the correct width.
    // MBIST reads from other RAMs must have the parity bits added because these
    // are not stored by the PFB.
    assign pfb_mbist_data = mbist_btac_rd_if3 ? {                    4'h0, pfb_mbist_data_i[79:0]} :
                                                {mbist_rdata_l1ecc_if3[3], pfb_mbist_data_i[79:60],
                                                 mbist_rdata_l1ecc_if3[2], pfb_mbist_data_i[59:40],
                                                 mbist_rdata_l1ecc_if3[1], pfb_mbist_data_i[39:20],
                                                 mbist_rdata_l1ecc_if3[0], pfb_mbist_data_i[19:0]};

  end else begin : gen_cache_protection_mbist_data_stubs

    assign pfb_mbist_data = pfb_mbist_data_i[79:0];

  end endgenerate


  //----------------------------------------------------------------------------
  // if3: hit and miss indication
  //
  //   An if3 miss is indicated following an if2 miss, when there is no active
  //   LFB entry for the request and it does not hit in the cache.
  //
  //   An if3 hit is indicated when the data is available after an if3 stall.
  //   The stall could have been because of a miss_if3, or a sequential request
  //   that resulted in a 'future' hit because the data had already been
  //   requested but not yet returned.
  //
  //   (Note: although a stall_if3 is indicated here before the hit_if3, and
  //   this is the general case, a hit_if3 can follow immediately after
  //   a hit_if2 in the case where the required data is in pd1 on the miss_if2
  //   cycle and there is nothing preventing this from moving into if1 on the
  //   next cycle.)
  //
  //                      ____                          ____
  //     pfb_ic_lookup  |/    |\____|_____|_____|_____|/    |\
  //                    |     |     |     |     |     |     |
  //                    |     | ____|     |     |     |     |
  //        ic_compare  |_____|/    |\____|_____|_____|_____|_
  //                    |     |     |     |     |     |     |
  //                    |     | ____|     |     |     |     |
  //          miss_if2  |_____|/    |\____|_____|_____|_____|_
  //                    |     |     |     |     |     |     |
  //                    |     |     | ____|     |     |     |
  //          miss_if3  |_____|_____|/    |\____|_____|_____|_
  //                    |     |     |     |     |     |     |
  //                    |     |     | ____|_____|_____|     |
  //         stall_if3  |_____|_____|/    |     |     |\____|_
  //                    |     |     |     |     |     |     |
  //                    |     |     |     |     |     | ____|
  //           hit_if3  |_____|_____|_____|_____|_____|/    |\
  //                    |     |     |     |     |     |     |
  //                    |     |     |     |     |     | ____|_
  //          lfb_data  |- - -|- - -|- - -|- - -|- - -|<____|_
  //                    |     |     |     |     |     |     |
  //
  //                      (1)   (2)   (3)   (4)   ...   (5)
  //
  //
  //    (1) PFB lookup valid. Cache RAMs accessed.
  //
  //    (2) Hit detection based on TAG RAM data and LFB entries.  In this case
  //        the lookup missed and miss_if2 is asserted.
  //
  //    (3) The if2 miss is registered into miss_if3, which is a pulse.  This
  //        signal causes a new LFB to activate and a new BIU address handshake
  //        to begin, in order to request the line that missed.
  //
  //    (4) Waiting for data to be returned from the BIU.  The BIU might return
  //        chunks from the requested cache line out of order.  We have to wait
  //        until the requested chunk has been returned; any out-of-order chunks
  //        will be allocated while the stall is held until the requested data
  //        is available.
  //
  //    (5) The data has been returned, pre-decoded and is now in the LFB data
  //        buffer.  The hit signal is provided back to the PFB via hit_if3.
  //        A new lookup can now occur for the next pre-fetch request.
  //
  //
  //----------------------------------------------------------------------------

  // Self-clearing if3 miss signal
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      miss_if3 <= 1'b0;
    else if (miss_if3_we)
      miss_if3 <= nxt_miss_if3;

  assign miss_if3_we  = if2_if3_en | miss_if3;  // Self-clearing
  assign nxt_miss_if3 = miss_if2 | lfb_wait_if3;

  // Self-clearing if3 'future hit' signal.  Different from a miss in that we've
  // already requested the data but we must still stall to wait for it.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      hit_f_if3 <= 1'b0;
    else if (hit_f_if3_we)
      hit_f_if3 <= nxt_hit_f_if3;

  // Don't set when there will be a hit_if3 on the next cycle; in that case the
  // stall will already be over by the next cycle.  Future hit is not asserted
  // and hence no stall started if there's a kill or uTLB miss as a new request
  // will be made.
  assign hit_f_if3_we  = (lfb_hit_fut_i & ~stall_if3 & ~nxt_hit_if3) | hit_f_if3;
  assign nxt_hit_f_if3 = pfb_valid_if2 & lfb_hit_fut_i & ~hit_f_if3 & ~pfb_kill_if2_i & pfb_utlb_hit_if2_i;


  // Create the inputs for the if3-stage way calculation on an if2-stage or
  // speculative miss
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      ic_tag_valid_if3  <= 2'b00;
      ic_almost_hit_if3 <= 2'b00;
    end else if (way_sel_en) begin
      ic_tag_valid_if3  <= nxt_ic_tag_valid_if3;
      ic_almost_hit_if3 <= nxt_ic_almost_hit_if3;
    end

  assign way_sel_en = (miss_if2 & ic_lookup_tag_mask_if2) | early_spec_miss_d;

  // if3 values can result from speculative lookup or real PFB lookup.  The tag
  // valid and almost hit indications are cleared when the caches turn off so
  // that the way selection will be based on no tag lookup.
  assign nxt_ic_tag_valid_if3  = spec_ic_compare ? (spec_ic_tag_valid  & {2{icb_cache_on_if2}}) :
                                 (pfb_ic_compare ? (ic_tag_valid_if2   & {2{icb_cache_on_if2}}) : 2'b00);
  assign nxt_ic_almost_hit_if3 = spec_ic_compare ? (spec_ic_almost_hit & {2{icb_cache_on_if2}}) :
                                 (pfb_ic_compare ? (ic_almost_hit_if2  & {2{icb_cache_on_if2}}) : 2'b00);


  // Detect when outstanding data is in pd1 and is about to move into the LFB
  // data buffer.  This indicates that we can provide the hit on the next cycle.
  // Doing it this way is faster than detecting the data from within the LFB.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      hit_if3 <= 1'b0;
    else
      hit_if3 <= nxt_hit_if3;

  // Note that a hit is suppressed when a kill or force comes in on the cycle
  // that the data is in pd1.  The kill/force will cause the entry to be
  // non-hittable from the next cycle but that is too late for this case so we
  // need to factor it in separately.
  assign nxt_hit_if3 = lfb_can_hit_pd1_i  &  // Critical chunk in pd1..
                       pfb_valid_if2      &  // .. with a valid request
                       ~ctl_stall_lfb_if0 &  // .. and can be transferred to LFB buf
                       ~pfb_kill_if2_i    &  // Suppress hit on kills..
                       ~pfb_force_if1_i;     // ..and forces


  //----------------------------------------------------------------------------
  // if3: LFB activation
  //
  //   An LFB entry is normally activated on a miss_if3 cycle and this also
  //   triggers the BIU address handshake to fetch the data.
  //
  //   But if there is already a BIU address handshake in progress we must allow
  //   this to complete, stall the new lookup and start it once the existing
  //   handshake completes.  Such a stall can occur when a transaction was
  //   killed during its address handshake; the handshake must complete
  //   regardless.
  //
  //   An LFB is also activated when a specualtive lookup misses.
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_activate_q <= 1'b0;
    else if (lfb_activate_we)
      lfb_activate_q <= nxt_lfb_activate;

  // Set triggered by miss_if2 -> miss_if3 if no h/s is already in progress
  // Sets during stall_if3 ASAP if the handshake was not already done
  // Auto-clears
  assign nxt_lfb_activate = (if2_if3_en & ~ifu_arvalid_i) | // Do on first if3 cycle
                            // Do once existing h/s completes unless killing the request
                            (stall_m_if3 & ~(pfb_kill_if2_i | pfb_force_if1_i) & ~started_hs & ~ifu_arvalid_i);
  assign lfb_activate_we  = lfb_activate_q | nxt_lfb_activate;

  // A speculative lookup only occurs after the parent handshake has completed
  // so the speculative miss signal can be used directly.
  assign lfb_activate = lfb_activate_q | spec_miss;

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      started_hs <= 1'b0;
    else if (started_hs_we)
      started_hs <= nxt_started_hs;

  // started_hs sets when an if3 handshake starts, clears on new lookup or kill/force
  assign started_hs_we  = ctl_pfb_valid_if1 | ((if2_if3_en | stall_m_if3) & ~ifu_arvalid_i & ~started_hs);
  assign nxt_started_hs = (if2_if3_en | stall_m_if3) & ~ifu_arvalid_i & ~(pfb_kill_if2_i | pfb_force_if1_i);


  // Random way allocation.  The activated LFB entry will allocate to this
  // random way in the absence of any other decisions in the way selection
  // algorithm.  The 'random' counter increments after each PFB lookup (on the
  // compare cycle, if2.)
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ctl_random_way <= 1'b0;
    else if (ic_compare)
      ctl_random_way <= ~ctl_random_way;


  //----------------------------------------------------------------------------
  // if3: stalls
  //
  //   There are two types of stalls in if3.  The first is caused by a miss, so
  //   we stall to fetch the data from the BIU and set up an LFB entry.  The
  //   second type is when there's an LFB future hit, indicating that the data
  //   has already been requested but we need to stall until it is available.
  //
  //   The overall if3 stall term is the OR of these two stall conditions as
  //   most logic is not concerned with the cause of the stall.  However some of
  //   the logic that deals with setting up the requests needs to use the
  //   individual stall condition.
  //----------------------------------------------------------------------------

  // The if3 pipeline stage only exists after a miss_if2.  It initiates the BIU
  // request and waits for data to be returned.  The if3 stage is therefore
  // stalled until the requested data has been returned (note that the BIU can
  // return data out of order so we have to stall until the requested data is
  // returned yet still cache anything returned in the meantime.)  The stall is
  // cleared by identifying that the pd1 stage contains the critical word; in
  // the next cycle this will be in the LFB buffer and the stall can be cleared.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      stall_m_if3_q <= 1'b0;
    else
      stall_m_if3_q <= stall_m_if3;

  assign stall_m_if3 = miss_if3  | // Request missed completely (I$ and LFB miss)
                       (stall_m_if3_q & ~hit_if3 & ~kill_stall_if3);  // Clear


  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      stall_f_if3_q <= 1'b0;
    else
      stall_f_if3_q <= stall_f_if3;

  assign stall_f_if3 = hit_f_if3 | // LFB hit but still waiting for data
                       (stall_f_if3_q & ~hit_if3 & ~kill_stall_if3);  // Clear

  // If there is no LFB available on the miss_if2 cycle then we have to wait
  // until an entry becomes available before asserting miss_if3.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lfb_wait_if3 <= 1'b0;
    else if (lfb_wait_if3_we)
      lfb_wait_if3 <= nxt_lfb_wait_if3;

  assign lfb_wait_if3_we  = (miss_if2 & ~lfb_available_i[0]) | (lfb_wait_if3 & lfb_available_i[0]) | pfb_kill_if2_i | pfb_force_if1_i;
  assign nxt_lfb_wait_if3 = miss_if2 & ~lfb_available_i[0] & ~(pfb_kill_if2_i | pfb_force_if1_i);

  // When an LFB activation is delayed due to a busy BIU we need to record on
  // the miss_if3 cycle the CP15 state, so that the correct cacheability state
  // can be determined when the LFB activates.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      cp15_active_if3 <= 1'b0;
    else if (cp15_active_if3_we)
      cp15_active_if3 <= set_cp15_active_if3;

  assign set_cp15_active_if3 = cp15_active_i[1] & (stall_m_if3 | lfb_wait_if3) & ~(started_hs | pfb_kill_if2_i | pfb_force_if1_i);
  assign cp15_active_if3_we  = set_cp15_active_if3  | // Set on CP15 when activation delayed (missed but can't handshake)
                               (cp15_active_if3 &     // Clear when handshake starts or a kill is seen
                                 (started_hs | pfb_kill_if2_i | pfb_force_if1_i));
  // Overall if3 stall
  assign stall_if3 = stall_m_if3 | stall_f_if3;

  // if3 stalls are killed when the PFB sends a kill or force, indicating that
  // we no longer want the data that we are stalling for.  Note that this
  // condition will also cause the outstanding LFB entry to become non-hittable.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      kill_stall_if3 <= 1'b0;
    else
      kill_stall_if3 <= nxt_kill_stall_if3;

  assign nxt_kill_stall_if3 = pfb_kill_if2_i | pfb_force_if1_i;


  //----------------------------------------------------------------------------
  // if3: Registered PFB request
  //
  //   The PFB's request signals are registered into if3 where they are used for
  //   creating the BIU request and for speculative cache lookups.
  //----------------------------------------------------------------------------

  always @ (posedge clk)
    if (pfb_req_if3_we) begin
      pfb_va_if3[14:1]        <= pfb_va_if2_i[14:1];
      pfb_pa_if3[39:4]        <= nxt_pfb_pa_if3[39:4];
      pfb_attributes_if3[7:0] <= pfb_attributes_if2[7:0];
      pfb_ns_dsc_if3          <= pfb_ns_dsc_if2_i;
      pfb_priv_if3            <= pfb_priv_if2;
      pfb_state_if3           <= pfb_state_if2_i[1:0];
      pfb_first_if3           <= pfb_first_if2;
    end

  // Register new if3 request signals when if3 is not stalling including the
  // case where the LFB is full (these signals are only used during a stall)
  assign pfb_req_if3_we = mbist_read_if2 | (~stall_if3 & ~lfb_wait_if3);

  // if3 PA storage re-used for MBIST tag RAM read data
  assign nxt_pfb_pa_if3[39:4] = {36{mbist_tag_rd_if2[1]}}       & {{(36-`CA53_ITAG_RAM_W){1'b0}}, ic_tagram_rdata1_i} |
                                {36{mbist_tag_rd_if2[0]}}       & {{(36-`CA53_ITAG_RAM_W){1'b0}}, ic_tagram_rdata0_i} |
                                {36{~(|mbist_tag_rd_if2[1:0])}} & pfb_pa_if2_i[39:4];


  //----------------------------------------------------------------------------
  // if3: speculative lookups
  //
  //   When a cacheable PFB request misses and results in a new LFB activation
  //   and BIU transaction, we can also issue a speculative lookup for the
  //   subsequent cache line once the BIU address handshake for the real request
  //   has completed.  This allows us to hit on the following cache line faster
  //   should this be requested.
  //
  //   We do a speculative tag read the cycle following the completed BIU
  //   handshake for the cacheable PFB request that missed.  We determine
  //   whether this hit/miss on the following cycle, as well as recording which
  //   ways were valid.  One cycle after a speculative lookup miss, we activate
  //   a new LFB entry and start a BIU request for the speculative cache line,
  //   assuming there's a spare LFB available.  If not we activate it as soon as
  //   one becomes available.
  //----------------------------------------------------------------------------

  assign attrs_cacheable_if3 = `CA53_MEM_WB(pfb_attributes_if3) | `CA53_MEM_WT(pfb_attributes_if3);

  // Record whether a flush was seen between miss_if2 and the start of the
  // handshake for the parent transaction.  If this happens then no speculative
  // request will be made for this transation.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      flush_under_miss_seen <= 1'b0;
    else if (flush_under_miss_seen_we)
      flush_under_miss_seen <= nxt_flush_under_miss_seen;

  assign set_flush_under_miss_seen = (miss_if2 | stall_m_if3 | lfb_wait_if3) & (dpu_flush_i_utlb_i | tlb_i_utlb_flush_i);
  assign clr_flush_under_miss_seen = flush_under_miss_seen & (started_hs | kill_stall_if3);
  assign flush_under_miss_seen_we  = set_flush_under_miss_seen | clr_flush_under_miss_seen;
  assign nxt_flush_under_miss_seen = set_flush_under_miss_seen;

  // Registered flush signal for timing
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      flush_seen <= 1'b0;
    else
      flush_seen <= nxt_flush_seen;

  assign nxt_flush_seen = dpu_flush_i_utlb_i | tlb_i_utlb_flush_i;

  // Decide whether it's possible to do a specultive lookup when the parent
  // transaction activates an LFB entry, which is when the parent transaction is
  // committed to go ahead (the parent transaction can be killed before
  // activating an LFB entry if it's waiting for the BIU to free up.)
  //
  // Keep track of whether the speculative lookup is allowed throughout the time
  // that the parent transaction occupies the BIU.  Certain events can happen
  // during this time that will prevent the speculative lookup after the
  // completed parent handshake, e.g. kill or uTLB flush.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      spec_lup_allowed <= 1'b0;
    else
      spec_lup_allowed <= spec_lup_allowed_d;

  assign spec_lup_allowed_d = ((lfb_activate_q &               // Do after the parent request's activation when ...
                                icb_cache_on_if2 &             // .. caches on
                                attrs_cacheable_if3 &          // .. cacheable request
                                (pfb_va_if3[11:6] != 6'h3F)) | // .. not top of 4k boundary where attrs can change
                               // Remain set until...
                               spec_lup_allowed) &
                              ~(spec_lup_block                        | // .. any blocking event
                                cp15_active_i[0]                      | // .. CP15 (turns parent non-cacheable)
                                cp15_active_if3                       | // .. even before the handshake
                                (spec_lup_eval & ~lfb_available_i[1]) | // .. h/s complete but no LFB available
                                spec_ic_lookup                        | // .. doing a speculative lookup
                                spec_lup_done);                         // .. done a speculative lookup

  // The following events happening any time up to the final handshake cycle of
  // the parent transaction will block any speculative lookup from going ahead.
  assign spec_lup_block = pfb_kill_if2_i     | // Kill
                          pfb_force_if1_i    | // Force
                          flush_seen         | // Seen a flush after the handshake
                          flush_under_miss_seen;  // Seen a flush before the handshake

  // Evaluate whether a speculative lookup will go ahead on the cycle that the
  // parent transaction's BIU handshake completes.  If a lookup is allowed on
  // this cycle, and if there's availability in the LFB, then we'll commit to
  // doing it.  Otherwise no speculative lookup will occur and there will be no
  // speculative LFB allocation.
  assign spec_lup_eval = ifu_arvalid_i & biu_i_arready_i;

  // Set up the lookup signal to enable the cache RAMs the cycle after the
  // parent transaction's handshake has completed.  This lookup is prevented at
  // the last moment if there is a kill or force on the cycle we would have done
  // the lookup, since a PFB lookup will be performed when there's a kill or
  // force.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      spec_ic_lookup_q <= 1'b0;
    else if (spec_ic_lookup_we)
      spec_ic_lookup_q <= nxt_spec_ic_lookup;

  // Don't lookup if no LFB available on the parent's final h/s cycle
  assign spec_ic_lookup_we  = (spec_lup_eval & spec_lup_allowed) | spec_ic_lookup_q;
  assign nxt_spec_ic_lookup = ~spec_ic_lookup & spec_lup_allowed & ~spec_lup_block & lfb_available_i[1];
  assign spec_ic_lookup     = spec_ic_lookup_q & spec_lup_allowed & ~spec_lup_block;

  // Speculative lookup occurs at the next sequential VA.
  assign spec_va = pfb_va_if3[14:6] + 9'b000_0000_01;

  // The speculative I$ result comparison cycle follows the lookup cycle.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      spec_ic_compare <= 1'b0;
    else if (spec_ic_compare_we)
      spec_ic_compare <= spec_ic_lookup;

  assign spec_ic_compare_we = (spec_ic_lookup & icb_cache_on_if1) | spec_ic_compare;

  // Record that a speculative lookup has been done.  We only do at most one
  // speculative lookup for each cacheable PFB request.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      spec_lup_done <= 1'b0;
    else if (spec_lup_done_we)
      spec_lup_done <= spec_ic_lookup;

  assign spec_lup_done_we = spec_ic_lookup |  // Set condition
                            hit_if3        |  // Clear when request hits ..
                            spec_lup_block;   // .. or a kill/force/flush leads to a new request


  // After a specualtive cache lookup we'll normally generate a speculative miss
  // signal if the lookup doesn't hit.  But this miss will be suppressed if
  // there was a kill or CP15 during the cache lookup and this will mean that
  // the miss will not turn into an LFB entry and BIU request.
  //                            ____
  //         spec_ic_lookup  _|/    |\____|_____|_
  //                          |     |     |     |
  //                          |     | ____|     |
  //        spec_ic_compare  _|_____|/    |\____|_
  //                          |     |     |     |
  //                         _|_____|     |     |
  //       spec_lup_allowed   |     |\____|_____|_
  //                          |     |     |     |
  //                          |     | ____|     |
  //            spec_miss_d  _|_____|/    |\____|_
  //                          |     |     |     |
  //                          |     |     | ____|
  //              spec_miss  _|_____|_____|/    |\
  //
  //                            (1)   (2)   (3)
  //
  // Any kills or CP15 arriving in cycles 1-2 must prevent activation being
  // requested on cycle 3.  Any of these events occurring on cycle 3 are too
  // late to prevent activation.

  // Events that can block a speculative LFB activation if they occur after the
  // lookup
  assign spec_lfb_block = dpu_flush_i_utlb_i | tlb_i_utlb_flush_i | cp15_active_i[0] | spec_lup_block;

  // Determine whether a speculative lookup missed.  Such a miss is registered
  // for the next cycle where it activates a new LFB entry.  Any parity errors
  // in the tag will block the miss indication and there will be no speculative
  // allocation.
  //
  // The early version of the signal is used to start the LFB clocks in
  // anticipation of the registered miss in the next cycle.  The late version
  // factors in speculative-blocking events that happen in cycles 1-2 of the
  // above waveform - events in these cycles came too late to stop the
  // speculative lookup but must still block a speculative LFB activation.  This
  // late signal is used only to create the registered spec_miss.
  assign early_spec_miss_d = spec_ic_compare & ~(|(spec_ic_hit[1:0]                           ) | flush_seen                 );
  assign spec_miss_d       = spec_ic_compare & ~(|(spec_ic_hit[1:0] | spec_tagram_pty_err[1:0]) | flush_seen | spec_lfb_block);

  // Clean speculative miss pulse
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      spec_miss <= 1'b0;
    else if (spec_miss_we)
      spec_miss <= spec_miss_d;

  assign spec_miss_we = spec_miss_d | (spec_miss & (lfb_available_i[1] | spec_lfb_block));


  //----------------------------------------------------------------------------
  // RAM lookup state machine
  //
  //   On sequential cacheable accesses we save power by only reading the tag
  //   RAM on the first access.  The tag can be saved and re-used for subsequent
  //   sequential accesses in the same cache line, thus reducing the number of
  //   lookups to the tag RAM.  We can also reduce the number of data RAM
  //   lookups from the third access, reading only the data RAM that hit.  (We
  //   can't suppress the extra data RAM read on the second accesses because the
  //   hit signal from the previous lookup is too late.)
  //----------------------------------------------------------------------------

  // Lookup states:
  //   LUP_NORMAL:    Do both a tag and data access
  //   LUP_SKIP_TAG:  Skip the tag lookup but read both data RAMs
  //   LUP_SKIP_DATA: Skip the tag and the data RAM that did't previously hit
  //
  // Note that when there's a pfb_first in the LUP_SKIP_TAG or LUP_SKIP_DATA
  // states then we stay in or move to LUP_SKIP_TAG rather than LUP_NORMAL
  // because the pfb_first will have already triggered the tag read.
  always @ (*)
    case (lookup_state)
      LUP_NORMAL:     nxt_lookup_state = (ctl_pfb_valid_if1 & ~stall_pfb & ~revert_lookup_state) ? LUP_SKIP_TAG : LUP_NORMAL;
      LUP_SKIP_TAG:   nxt_lookup_state = revert_lookup_state ? LUP_NORMAL : (pfb_first_if1_i ? LUP_SKIP_TAG : LUP_SKIP_DATA);
      LUP_SKIP_DATA:  nxt_lookup_state = revert_lookup_state ? LUP_NORMAL : (pfb_first_if1_i ? LUP_SKIP_TAG : LUP_SKIP_DATA);
      default:        nxt_lookup_state = 2'bXX;
    endcase

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      lookup_state <= LUP_NORMAL;
    else
      lookup_state <= nxt_lookup_state;

  // The lookup state must be reverted in certain scenarios that may result in
  // the contents of the cache changing between sequential requests
  assign revert_lookup_state = cp15_active_i[0] | // any CP15 operation
                               cp15_req_if1     | // even the last one
                               lfb_alloc_hazard | // Hazarding LFB allocates
                               lfb_comp_hazard_i; // Hazarding LFB completes

  // Detect when there's an LFB allocation hazard.  This is when the LFB is
  // allocating and there's a lookup to the same address.  As the RAM contents
  // have changed we need to reset the lookup state machine.  We do the hazard
  // detection here rather than in the LFB because once the allocation request
  // is in if1 it's possible for the originating LFB control entry to close
  // leading to an allocation that is 'orphaned' but still valid.
  assign lfb_alloc_hazard = ctl_lfb_alloc & (tagram_addr_if1[5:0] == pfb_va_if2_i[11:6]);


  // Store the result of the cache hit (i.e. the types of hit that use the cache read data)
  // on a real if2 request (not a spurious if2 request).
  //  We use this result to:
  //
  //   - determine which data ram to read for subsequent sequential accesses;
  //   - determine which way hit for subsequent sequential accesses where the
  //     tag read was skipped.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      tracked_hit <= 2'b00;
    else if (tracked_hit_we)
      tracked_hit <= ic_hit_if2;

  // Enable on a compare cycle where the lookup was performed in the RAMs
  assign tracked_hit_we = ctl_pfb_valid_if2 & ic_lookup_tag_mask_if2;

  // if1 and if2 indications of whether tag RAMs will be accessed on lookup.
  // The same term is used for both ways.  (NB. tag RAMs are never accessed when
  // the caches are off)
  assign ic_lookup_tag_mask_if1 = pfb_first_if1_i | cp15_active_i[0] | (lookup_state == LUP_NORMAL);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ic_lookup_tag_mask_if2 <= 1'b0;
    else
      ic_lookup_tag_mask_if2 <= ic_lookup_tag_mask_if1;

  // if1 indication of whether data RAMs will be accessed on a lookup.  Two
  // enables per way, enabling the hi/lo halves of each way to be enabled
  // independently:
  //   - when the request is to the upper half of the cache line the lower half
  //     is not enabled because this data will never be used;
  //   - our power-saving techniques allow an entire way to be disabled when we
  //     are able to determine in advance which way contains the data that will
  //     hit.
  //
  // NB. data RAMs can be accessed when caches are off so we need to account for
  // the cache off cases.
  assign tracked_bank_en         = corkscrew(tracked_hit[1:0], pfb_va_if1_i[3]);
  assign tracked_bank_en_hi_lo   = {{2{tracked_bank_en[1]}}, {2{tracked_bank_en[0]}}};

  assign ic_lookup_data_mask_if1 = // On a first never unnecessarily read the lower half of a bank
                                   ({4{pfb_first_if1_i}} & {1'b1, ~pfb_va_if1_i[2], 1'b1, ~pfb_va_if1_i[2]}) |
                                   // Read everything on CP15 or when lookup FSM not skipping data reads
                                   {4{(cp15_active_i[1] | (lookup_state != LUP_SKIP_DATA))}} |
                                   // Must apply corkscrew to read the correct bank after either a cache hit
                                   // or an LFB 'past' hit
                                   ({4{~pfb_first_if1_i}} & tracked_bank_en_hi_lo) |
                                   // If there was no hit we have to read both banks because an LFB 'past' hit could
                                   // still follow.
                                   {4{~|tracked_hit[1:0]}};


  //----------------------------------------------------------------------------
  // IFU control signals
  //----------------------------------------------------------------------------

  // Way notification to pre-fetch:
  //   LFB hit: Way as recorded by hitting LFB, but clear when it's not
  //            cacheable.  This is to prevent corrections for non-cacheable
  //            data being written to the RAMs.
  //   $ hit  : Way as per the cache hit logic, but clear when there's a PDC
  //            hazard.  This is to prevent the PDC logic writing old data into
  //            a new cache line.
  assign icb_way_if2[1:0] = lfb_hit_ppf_i ? ({2{lfb_hit_cacheable_i}} & lfb_hit_way_i) : ic_hit_if2;

  // PDC hazard indicates that pre-decode corrections should not be written to
  // the cache.  The hazard occurs following a miss, until a force is seen and
  // no LFB is outstanding.  This ensures that corrections are only written to
  // the caches when the code is running purely from the caches, not when
  // there's a chance that a PDC write will conflict with an outstanding LFB.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      icb_pdc_hazard_if2 <= 1'b0;
    else if (pdc_hazard_we)
      icb_pdc_hazard_if2 <= miss_if2;

  assign pdc_hazard_we = miss_if2 | (pfb_force_if1_i & ~lfb_in_progress_i);

  // WFX and debug ready indication
  assign ifu_dbg_ready   = ~(lfb_in_progress_i | pfb_valid_if2);
  assign ifu_wfx_ready_d = ~(lfb_in_progress_i | pfb_valid_if2 | cp15_active_i[0] | pfb_valid_if1_i);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ifu_wfx_ready <= 1'b1;
    else
      ifu_wfx_ready <= ifu_wfx_ready_d;

  assign icb_busy_if1  = (cp15_busy_if1_i[1]) |
                         (cp15_busy_if1_i[0] & icache_on) |
                         (dataram_wait_cnt == 4'b1111) |
                         ctl_mbist_req; // use register version which still gives us enough time to block the PFB

  // Indicate to pre-fetch that there's a miss in if3 (cacheable request) that
  // was a sequential request (i.e. pfb_first was low).
  assign ctl_seq_miss_if3 = miss_if3 & ~pfb_first_if3 & attrs_cacheable_if3;

  // Following a miss (either real or speculative) in if2 we must start the LFB
  // clocks so that one of the entries can be activated in if3.
  assign ctl_start_lfb = (miss_if2 & ~(pfb_kill_if2_i | pfb_force_if1_i)) | early_spec_miss_d;


  //----------------------------------------------------------------------------
  // PMU events
  //----------------------------------------------------------------------------

  // Event 0x14: L1 instruction cache access
  //   We register this in the if2 cycle when either the I$ has been accessed
  //   or we use LFB data for cacheable requests.
  always @ (posedge clk)
    ifu_evnt_ic_access <= nxt_ifu_evnt_ic_access;

  assign nxt_ifu_evnt_ic_access = pfb_ic_compare & pfb_utlb_hit_if2_i & pfb_attrs_cacheable;


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign icb_flush_btic_o         = cp15_active_i[0];
  assign icb_cacheable_if2_o      = icb_cache_on_if2;
  assign icb_busy_if1_o           = icb_busy_if1;
  assign icb_data_if2_o           = icb_data_if2;
  assign icb_lfb_data_if2_o       = icb_lfb_data_if2;
  assign icb_hit_if2_o            = icb_hit_if2;
  assign icb_lfb_hit_if2_o        = lfb_hit_if2;
  assign icb_way_if2_o            = icb_way_if2;
  assign icb_pdc_hazard_if2_o     = icb_pdc_hazard_if2;
  assign icb_ext_abort_if2_o      = ext_abort_if2;
  assign icb_ext_abort_type_if2_o = ext_abort_type_if2;
  assign icb_parity_err_if2_o     = icb_parity_err_if2;
  assign icb_mbist_en_o           = {mbist_btac_rd_if2[1:0], mbist_read_if2};

  assign ifu_dbg_ready_o          = ifu_dbg_ready;
  assign ifu_wfx_ready_o          = ifu_wfx_ready;
  assign ifu_evnt_ic_access_o     = ifu_evnt_ic_access;

  assign ctl_mbist_req_o            = ctl_mbist_req;
  assign ctl_mbist_btac_en_mb4_o    = mbist_btac_en_if1;
  assign ctl_mbist_btac_addr_mb4_o  = dataram_addr0_prearb_if1[6:0];
  assign ctl_mbist_btac_wr_mb4_o    = mbist_write_if1;
  assign ctl_mbist_btac_wdata_mb4_o = dataram_wdata0_prearb_if1 [58:0];
  assign ifu_mbist_out_data_mb6_o   = mbist_rdata_if3;

  assign ctl_pty_inv_req_o     = |ctl_pty_inv_req;
  assign ctl_pty_inv_addr_o    = ctl_pty_inv_addr;
  assign ifu_pty_valid_o       = ifu_pty_valid;
  assign ifu_pty_ramid_o       = ifu_pty_ramid;
  assign ifu_pty_way_bank_id_o = ifu_pty_way_bank_id;
  assign ifu_pty_index_o       = ifu_pty_index;

  // Instruction cache interface
  assign ic_tagram_en_o           = tagram_en_if1 & ~{2{DFTRAMHOLD}};
  assign ic_tagram_wr_o           = tagram_wr_if1;
  assign ic_tagram_wdata_o        = tagram_wdata_if1_pty;
  assign ic_tagram_addr_o         = tagram_addr_if1;
  assign ic_dataram_en_o          = dataram_en_if1 & ~{4{DFTRAMHOLD}};
  assign ic_dataram_wr_o          = dataram_wr_if1;
  assign ic_dataram_addr0_o       = dataram_addr0_if1;
  assign ic_dataram_addr1_o       = dataram_addr1_if1;
  assign ic_dataram_strb0_o       = dataram_strb0_if1;
  assign ic_dataram_strb1_o       = dataram_strb1_if1;
  assign ic_dataram_wdata0_o      = dataram_wdata0_if1_pty;
  assign ic_dataram_wdata1_o      = dataram_wdata1_if1_pty;

  assign ctl_pfb_valid_if1_o      = ctl_pfb_valid_if1;
  assign ctl_lfb_alloc_o          = ctl_lfb_alloc;
  assign ctl_pfb_va_if3_o         = pfb_va_if3[14:1];
  assign ctl_pfb_pa_if3_o         = pfb_pa_if3[39:4];
  assign ctl_pfb_attributes_if3_o = pfb_attributes_if3[7:0];
  assign ctl_pfb_ns_dsc_if3_o     = pfb_ns_dsc_if3;
  assign ctl_pfb_priv_if3_o       = pfb_priv_if3;
  assign ctl_seq_miss_if3_o       = ctl_seq_miss_if3;
  assign ctl_stall_pfb_o          = stall_pfb;
  assign ctl_stall_lfb_pd0_o      = ctl_stall_lfb_pd0;
  assign ctl_stall_lfb_if0_o      = ctl_stall_lfb_if0;
  assign ctl_stall_if3_o          = stall_if3;
  assign ctl_stall_pdc_o          = ctl_stall_pdc_if0;
  assign ctl_stall_tag_cp15_o     = ctl_stall_tag_cp15;
  assign ctl_stall_tag_cp15_if1_o = ctl_stall_tag_cp15_if1;
  assign ctl_stall_data_cp15_if1_o= ctl_stall_data_cp15_if1;
  assign ctl_stall_data_cp15_o    = ctl_stall_data_cp15;
  assign ctl_cache_on_if2_o       = icb_cache_on_if2;
  assign ctl_cp15_active_if3_o    = cp15_active_if3;
  assign ctl_pd_ack_o             = ~ctl_stall_lfb_if0;
  assign ctl_lfb_activate_o       = lfb_activate;
  assign ctl_lfb_speculative_o    = spec_miss;
  assign ctl_random_way_o         = ctl_random_way;
  assign ctl_tag_valid_if3_o      = ic_tag_valid_if3;
  assign ctl_almost_hit_if3_o     = ic_almost_hit_if3;
  assign ctl_hit_f_if3_o          = hit_f_if3;
  assign ctl_valid_if2_o          = pfb_valid_if2;
  assign ctl_start_lfb_o          = ctl_start_lfb;


  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // Signals used by OVLs
  reg  ovl_if2_stall;
  wire ovl_if2_stall_we;
  wire ovl_nxt_if2_stall;
  reg  ovl_hit_reg;
  reg  ovl_pfb_valid_if1_reg;
  reg  ovl_cache_on_if1_reg;
  reg  ovl_lfb_wait_if3_reg;
  reg  ovl_miss_if2_reg;
  reg  ovl_stall_m_if3_reg;
  reg  ovl_stall_f_if3_reg;
  reg  ovl_hit_f_if2_reg;

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_ic_compare")
  u_ovl_x_pfb_ic_compare (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (pfb_ic_compare));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ctl_mbist_req")
  u_ovl_x_ctl_mbist_req (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (ctl_mbist_req));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dataram_wait_cnt_we")
  u_ovl_x_dataram_wait_cnt_we (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (dataram_wait_cnt_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: mbist_read_if2")
  u_ovl_x_mbist_read_if2 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (mbist_read_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pdc_hazard_we")
  u_ovl_x_pdc_hazard_we (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pdc_hazard_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_ic_lookup")
  u_ovl_x_pfb_ic_lookup (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (pfb_ic_lookup));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_req_if3_we")
  u_ovl_x_pfb_req_if3_we (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (pfb_req_if3_we));

  generate if (CPU_CACHE_PROTECTION) begin : gen_parity_err_ovl
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pty_inv_addr_we")
    u_ovl_x_pty_inv_addr_we (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (gen_parity_err.pty_inv_addr_we));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pty_inv_req_we")
    u_ovl_x_pty_inv_req_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (gen_parity_err.pty_inv_req_we));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tracked_tag_valid_we")
    u_ovl_x_tracked_tag_valid_we (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (gen_parity_err.tracked_tag_valid_we));
  end endgenerate

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tracked_hit_we")
  u_ovl_x_tracked_hit_we (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (tracked_hit_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cache_on_if2_we")
  u_ovl_x_cache_on_if2_we (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cache_on_if2_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp15_active_if3_we")
  u_ovl_x_cp15_active_if3_we (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (cp15_active_if3_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: flush_under_miss_seen_we")
  u_ovl_x_flush_under_miss_seen_we (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (flush_under_miss_seen_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_f_if3_we")
  u_ovl_x_hit_f_if3_we (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (hit_f_if3_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ic_compare")
  u_ovl_x_ic_compare (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (ic_compare));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: if0_if1_data_en")
  u_ovl_x_if0_if1_data_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (if0_if1_data_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: if0_if1_tag_en")
  u_ovl_x_if0_if1_tag_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (if0_if1_tag_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lfb_activate_we")
  u_ovl_x_lfb_activate_we (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (lfb_activate_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lfb_wait_if3_we")
  u_ovl_x_lfb_wait_if3_we (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (lfb_wait_if3_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: miss_if3_we")
  u_ovl_x_miss_if3_we (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (miss_if3_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ovl_if2_stall_we")
  u_ovl_x_ovl_if2_stall_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (ovl_if2_stall_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_ic_compare_we")
  u_ovl_x_pfb_ic_compare_we (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (pfb_ic_compare_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pfb_valid_if2_we")
  u_ovl_x_pfb_valid_if2_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pfb_valid_if2_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: spec_ic_compare_we")
  u_ovl_x_spec_ic_compare_we (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (spec_ic_compare_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: spec_ic_lookup_we")
  u_ovl_x_spec_ic_lookup_we (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (spec_ic_lookup_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: spec_lup_done_we")
  u_ovl_x_spec_lup_done_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (spec_lup_done_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: spec_miss_we")
  u_ovl_x_spec_miss_we (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (spec_miss_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: started_hs_we")
  u_ovl_x_started_hs_we (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (started_hs_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: way_sel_en")
  u_ovl_x_way_sel_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (way_sel_en));



  // PFB stalled due to a miss.  This uses the if2 miss signal directly from the
  // caches/LFBs, which the RTL does not use directly for timing reasons.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_if2_stall <= 1'b0;
    else if (ovl_if2_stall_we)
      ovl_if2_stall <= ovl_nxt_if2_stall;

  assign ovl_if2_stall_we  = miss_if2 | icb_hit_if2_o | icb_lfb_hit_if2_o;
  assign ovl_nxt_if2_stall = miss_if2;

  // Hit (cache or LFB) on the previous cycle
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_hit_reg <= 1'b0;
    else
      ovl_hit_reg <= icb_hit_if2_o | icb_lfb_hit_if2_o;

  // Valid PFB request (if1) in the previous cycle
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_pfb_valid_if1_reg <= 1'b0;
    else
      ovl_pfb_valid_if1_reg <= ctl_pfb_valid_if1;

  // Cache was on (if1 request) on the previous cycle.  This tells us whether,
  // on a cycle where cache data is returned, the tags were accessed or not.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_cache_on_if1_reg <= 1'b0;
    else
      ovl_cache_on_if1_reg <= icb_cache_on_if1;

  // Register various miss and stall signals for checking on next cycle
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_lfb_wait_if3_reg <= 1'b0;
      ovl_miss_if2_reg     <= 1'b0;
      ovl_stall_m_if3_reg  <= 1'b0;
      ovl_stall_f_if3_reg  <= 1'b0;
      ovl_hit_f_if2_reg    <= 1'b0;
    end else begin
      ovl_lfb_wait_if3_reg <= lfb_wait_if3;
      ovl_miss_if2_reg     <= miss_if2;
      ovl_stall_m_if3_reg  <= stall_m_if3;
      ovl_stall_f_if3_reg  <= stall_f_if3;
      ovl_hit_f_if2_reg    <= hit_f_if2;
    end

  // A real PFB lookup and a speculative lookup can not occur on the same cycle
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Real and speculative lookups can't be on same cycle")
    ovl_real_spec_cycle
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (pfb_ic_lookup & spec_ic_lookup)
      );

  // A speculative lookup must not happen on a cycle that a hit is signalled to
  // the prefetch block, or on the cycle after a hit.  This means that the
  // speculative lookup conflicts with a new PFB lookup or a spurious lookup.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "Speculative lookup conflicts with non-speculative")
    ovl_real_spec_conflict
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (spec_ic_lookup & (icb_hit_if2_o | icb_lfb_hit_if2_o | ovl_hit_reg))
      );


  // miss_if2 can only be reported one cycle after a PFB lookup
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "miss_if2 without PFB lookup")
    ovl_mif2_lookup
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (miss_if2),
       .consequent_expr (ovl_pfb_valid_if1_reg)
      );

  // miss_if2 must never be reported on the same cycle as hit_if3 or stall_if3.
  // hit_if3 indicates that the data (which stalled) is now available so this
  // will be provided this cycle, meaning we can't miss.  stall_if3 means we are
  // waiting for the data and since miss_if2 is a pulse it must not be high
  // during this time.
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "miss_if2 must not be set during stall_if3 or hit_if3")
    ovl_mif2_if3
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (miss_if2 & (hit_if3 | stall_if3))
      );

  // miss_if2 and hit_f_if2 can not be reported on the same cycle
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "miss_if2 and hit_f_if2 should be mutually exclusive")
    ovl_mif2_hfif2
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (miss_if2 && hit_f_if2)
      );

  // miss_if3 and hit_f_if3 can not be reported on the same cycle
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "miss_if3 and hit_f_if3 should be mutually exclusive")
    ovl_mif3_hfif3
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   (miss_if3 && hit_f_if3)
      );

  // stall_m_if3, stall_f_if3 and lfb_wait_if3 represent different parts and/or
  // different types of the if3 stall process and at most one should be high on
  // any given cycle
  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "if3 stalls should be zero or one-hot")
    ovl_if3_stall_oh
      (.clk         (clk),
       .reset_n     (reset_n),
       .test_expr   ({stall_m_if3, stall_f_if3, lfb_wait_if3})
      );

  // The if3 stall process on a miss is miss_if2 followed by 0 or more cycles of
  // lfb_wait_if3 followed by 0 or more cycles of stall_m_if3.  The following
  // OVLs check this by asserting that a rising edge of lfb_wait_if3 is
  // preceeded by a miss_if3, and that a rising edge of stall_m_if3 is preceeded
  // by either a miss_if2 or a falling edge of lfb_wait_if3.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Improper if3 stall following miss; lfb_wait_if3 must be preceeded by miss_if2")
    ovl_stall_m_if3_a
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (lfb_wait_if3 && ~ovl_lfb_wait_if3_reg),  // Rising edge of lfb_wait_if3
       .consequent_expr (ovl_miss_if2_reg)
      );
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Improper if3 stall following miss; stall_m_if3 must be preceeded by miss_if2 or lfb_wait_if3")
    ovl_stall_m_if3_b
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (stall_m_if3 && ~ovl_stall_m_if3_reg),   // Rising edge of stall_m_if3
       .consequent_expr (ovl_miss_if2_reg || (~lfb_wait_if3 && ovl_lfb_wait_if3_reg))
      );

  // The if3 stall process on a future hit is hit_f_if2 followed by 0 or more
  // cycles of stall_f_if3.  The following OVL checks this process by ensuring
  // that a rising edge of stall_f_if3 is preceeded by a hit_f_if2.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Improper if3 stall following future hit; stall_f_if3 must be preceeded by hit_f_if2")
    ovl_stall_f_if3
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (stall_f_if3 && ~ovl_stall_f_if3_reg),  // Rising edge of stall_f_if3
       .consequent_expr (ovl_hit_f_if2_reg)
      );

  // If hit_if3 is high, then lfb_hit_pres must also be high.  (hit_if3 is
  // calculated based on CWF coming back from BIU/pre-decode, while lfb_hit_pres
  // is calculated based on the PFB interface signals.)  Note that lfb_hit_pres
  // can be high without hit_if3 if there was no stall involved.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lfb_hit_pres must be high if hit_if3 is high")
    ovl_hif3_lfb_pres
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (hit_if3 & ~pfb_kill_if2_i),
       .consequent_expr (lfb_hit_pres_i)
      );

  // The lookup_state state machine must not enter state 2'b11, which is not
  // a legal state.
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "lookup_state is in an illegal state")
    ovl_lookup_state
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr ((lookup_state == LUP_NORMAL)   ||
                   (lookup_state == LUP_SKIP_TAG) ||
                   (lookup_state == LUP_SKIP_DATA))
      );

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

