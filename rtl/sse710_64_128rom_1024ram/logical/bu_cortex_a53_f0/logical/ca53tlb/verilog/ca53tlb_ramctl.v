//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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
// Abstract : TLB RAM control and arbitration
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"


module ca53tlb_ramctl `CA53_TLB_PARAM_DECL
 (
  input  wire                          clk,
  input  wire                          reset_n,
  input  wire                          DFTRAMHOLD,

  // RAM interface
  output wire [3:0]                    tlb_ram_en_o,
  output wire                          tlb_ram_wr_o,
  output wire [7:0]                    tlb_ram_addr_o,
  output wire [`CA53_TLB_RAM_W-1:0]    tlb_ram_wdata_o,
  input  wire [`CA53_TLB_RAM_W-1:0]    tlb_ram_rdata0_i,
  input  wire [`CA53_TLB_RAM_W-1:0]    tlb_ram_rdata1_i,
  input  wire [`CA53_TLB_RAM_W-1:0]    tlb_ram_rdata2_i,
  input  wire [`CA53_TLB_RAM_W-1:0]    tlb_ram_rdata3_i,

  // Lookup requests
  input  wire                          lookup_ram_req_i,
  input  wire [3:0]                    lookup_ram_way_i,
  input  wire                          lookup_ram_next_req_i,
  input  wire                          lookup_ram_wr_i,
  input  wire                          lookup_ram_ready_i,
  input  wire [7:0]                    lookup_ram_next_addr_i,
  input  wire [2:0]                    lookup_ram_d_size_i,
  input  wire [2:0]                    lookup_ram_i_size_i,
  input  wire                          lookup_state_lookup_i,
  input  wire                          dcu_va_valid_early_dc1_i,
  input  wire                          dpu_utlb_hit_dc1_i,
  input  wire [35:12]                  dpu_va_dc1_i,
  input  wire [2:0]                    dcu_transl_type_dc1_i,
  input  wire                          ifu_utlb_miss_req_i,
  input  wire [35:12]                  ifu_va_if2_i,

  // Lookup results
  input  wire [48:12]                  lookup_compare_va_i,
  input  wire                          lookup_va_sign_err_i,
  input  wire [2:0]                    lookup_compare_size_i,
  input  wire                          lookup_compare_size_ipa_i,
  input  wire                          lookup_compare_ns_i,
  input  wire                          lookup_compare_hyp_i,
  input  wire                          lookup_compare_el3_i,
  input  wire [`CA53_ASID_W-1:0]       lookup_compare_asid_i,
  input  wire [7:0]                    lookup_compare_vmid_i,
  input  wire                          lookup_s1s2_a64_g64_i,// Support for granule calculation

  input  wire                          lookup_compare_use_va_i,
  input  wire                          lookup_compare_use_asid_i,
  input  wire                          lookup_compare_use_global_i,
  input  wire                          lookup_compare_use_vmid_i,

  input  wire                          lookup_i_utlb_might_enable_i,
  input  wire                          lookup_d_utlb_might_enable_i,
  input  wire                          lookup_i_utlb_next_might_enable_i,
  input  wire                          lookup_d_utlb_next_might_enable_i,
  input  wire                          pagewalk_i_utlb_enable_i,
  input  wire                          pagewalk_d_utlb_enable_i,
  input  wire                          pagewalk_i_utlb_next_might_enable_i,
  input  wire                          pagewalk_d_utlb_next_might_enable_i,
  input  wire [`CA53_DUTLB_DATA_W-1:0] pagewalk_d_utlb_data_i,
  input  wire [`CA53_IUTLB_DATA_W-1:0] pagewalk_i_utlb_data_i,
  output wire [`CA53_DUTLB_DATA_W-1:0] tlb_d_utlb_data_o,
  output wire [`CA53_IUTLB_DATA_W-1:0] tlb_i_utlb_data_o,
  output wire                          tlb_i_utlb_might_enable_o,
  output wire                          tlb_d_utlb_might_enable_o,
  output wire                          tlb_i_utlb_enable_o,
  output wire                          tlb_d_utlb_enable_o,
  output wire                          tlb_i_utlb_valid_o,
  output wire                          tlb_d_utlb_valid_o,
  output wire                          tlb_i_utlb_lpae_o,
  output wire                          tlb_d_utlb_lpae_o,

  output wire [3:0]                    cp_lookup_hit_way_o,
  output wire                          lookup_hit_o,
  output wire                          sel_victim_round_robin_o,
  output wire [1:0]                    first_available_way_o,

  // Pagewalk walk cache lookups
  input  wire                          pagewalk_va_sign_i,
  input  wire [23:0]                   walk_ram_masked_va_i,
  input  wire                          pagewalk_hyp_i,
  input  wire                          pagewalk_a64_i,
  input  wire [1:0]                    pagewalk_exception_level_i,
  input  wire                          pagewalk_ns_i,
  input  wire                          pagewalk_lpae_i,
  input  wire                          pagewalk_enable_walk_compare_i,
  input  wire [`CA53_ASID_W-1:0]       asid_pagewalk_i,
  input  wire [7:0]                    pagewalk_vmid_i,
  input  wire [1:0]                    walk_ram_arch_i,

  output wire                          walk_cache_hit_o,
  output wire [46:0]                   walk_cache_data_o,

  // Pagewalk IPA cache lookups
  input  wire [39:16]                  pagewalk_ipa_compare_ipa_i,
  input  wire [2:0]                    pagewalk_ipa_compare_size_i,
  input  wire                          stage2_pagewalk_a64_g64_i,
  input  wire                          pagewalk_state_ipa_compare_i,
  output wire [3:0]                    ipa_cache_hit_way_o,
  output wire [37:0]                   ipa_cache_data_o,

  // Pagewalk write requests
  input  wire                          pagewalk_ram_req_i,
  input  wire [3:0]                    pagewalk_ram_way_i,
  input  wire                          pagewalk_ram_wr_i,
  input  wire [7:0]                    pagewalk_ram_addr_i,
  input  wire [`CA53_TLB_RAM_W-1:0]    pagewalk_ram_wr_data_i,

  // Arbitration
  input  wire                          pagewalk_busy_iside_i,
  input  wire                          pagewalk_busy_dside_i,
  output wire                          pagewalk_ram_pri_o,
  output wire                          lookup_ram_pri_o,

  // MBIST
  input  wire                          mbist_en_i,
  input  wire [1:0]                    dcu_mbist_array_mb3_i,
  input  wire [7:0]                    dcu_mbist_addr_mb3_i,
  input  wire [`CA53_TLB_RAM_W-1:0]    mbist_in_data_mb4_i,
  input  wire [3:0]                    mbist_read_en_mb4_i,
  input  wire [3:0]                    mbist_write_en_mb4_i,

  input  wire [1:0]                    dbgdr_ram_way_i,
  output wire [`CA53_TLB_RAM_W-1:0]    dbgdr_reg_wr_data_o,

  output wire                          lookup_ecc_err_o,
  output wire [3:0]                    lookup_ecc_err_way_o,
  output wire [6:0]                    lookup_ecc_err_addr_o,
  output wire [3:0]                    walk_ipa_ecc_err_addr_o,
 
  // Support for ECC reporting
  input  wire                          tlb_pty_valid_cp_i,
  input  wire                          tlb_pty_valid_non_cp_i,
  input  wire [2:0]                    tlb_pty_way_cp_i,
  input  wire [2:0]                    tlb_pty_way_non_cp_i,

  output wire                          tlb_pty_valid_o,
  output wire [1:0]                    tlb_pty_way_bank_id_o,
  output wire [7:0]                    tlb_pty_index_o
);

  //------------------------------------------------------------------------------
  // Flop and Wire declarations
  //------------------------------------------------------------------------------

  reg [7:0]    ram_addr_early;
  reg [7:0]    tlb_ram_compare_addr;
  reg          tlb_i_utlb_might_enable;
  reg          tlb_d_utlb_might_enable;
  reg  [6:0]   lookup_index_iside;
  reg  [6:0]   lookup_index_dside;
  wire         ram_addr_early_en;
  wire [7:0]   next_ram_addr_early;
  wire [7:0]   tlb_ram_addr_other;
  wire [95:0]  dutlb_full_data;
  wire [52:0]  i_utlb_partial_data0;
  wire [52:0]  i_utlb_partial_data1;
  wire [52:0]  i_utlb_partial_data2;
  wire [52:0]  i_utlb_partial_data3;
  wire [52:0]  i_utlb_partial_data;
  wire [96:0]  i_utlb_full_data;

  reg  [27:0]  lower_va_bits;
  reg  [28:0]  masked_va;
  wire [23:0]  masked_walk_va;
  reg  [23:0]  masked_ipa_va;
  wire [3:0]   valid_bit;
  wire [3:0]   ng_bit;
  wire [3:0]   ns_match;
  wire [3:0]   hyp_match;
  wire [3:0]   el3_match;
  wire [3:0]   asid_match;
  wire [3:0]   vmid_match;
  wire [3:0]   va_match;
  // Support for granule calculation
  wire [3:0]   va_only_match;
  wire [3:0]   size_only_match;
  wire [3:0]   va_sign_match;
  wire [3:0]   walk_va_sign_match;
  wire [3:0]   cp_va_match;
  wire [3:0]   walk_va_match;

  wire [3:0]   walk_va_only_match;
  wire [3:0]   walk_size_only_match;
  wire [3:0]   walk_s1_g64_s2_g4_match;
  
  wire [3:0]   ipa_va_match;
  wire [3:0]   ipa_va_only_match;
  wire [3:0]   ipa_any_sizes_match;
  wire [3:0]   ipa_512m_size_match;

  wire [3:0]   lookup_hit_way;
  wire [1:0]   mbist_dbgdr_way;
  wire         walk_lookup;
  wire         ipa_lookup;
  wire [7:0]   tlb_ram_addr;
  wire [55:0]  walk_compare_data;
  wire [3:0]   walk_cache_hit_way;
  wire [46:0]  walk_ram_data0;
  wire [46:0]  walk_ram_data1;
  wire [46:0]  walk_ram_data2;
  wire [46:0]  walk_ram_data3;
  wire [37:0]  ipa_compare_data;
  wire [3:0]   ipa_cache_hit_way;
  wire [37:0]  ipa_ram_data0;
  wire [37:0]  ipa_ram_data1;
  wire [37:0]  ipa_ram_data2;
  wire [37:0]  ipa_ram_data3;
  wire         next_tlb_i_utlb_might_enable;
  wire         next_tlb_d_utlb_might_enable;
  wire         pagewalk_ram_pri;
  wire         lookup_ram_pri;
  reg [1:0]    s1level0;
  reg [1:0]    s1level1;
  reg [1:0]    s1level2;
  reg [1:0]    s1level3;
  reg [35:0]   va_mask0;
  reg [35:0]   va_mask1;
  reg [35:0]   va_mask2;
  reg [35:0]   va_mask3;
  reg [35:0]   ram_va0;
  reg [35:0]   ram_va1;
  reg [35:0]   ram_va2;
  reg [35:0]   ram_va3;
  wire         lookup_select_dside;
  wire         lookup_select_iside;

  wire [1:0]   i_utlb_partial_data_excp;

  wire         tlb_ram_rdata3_hyp;
  wire         tlb_ram_rdata2_hyp;
  wire         tlb_ram_rdata1_hyp;
  wire         tlb_ram_rdata0_hyp;
  wire         tlb_ram_rdata3_el3;
  wire         tlb_ram_rdata2_el3;
  wire         tlb_ram_rdata1_el3;
  wire         tlb_ram_rdata0_el3;
  wire         lookup_hit;

  wire [3:0]   tlb_ram_en;
  wire         lookup_ecc_err;
  wire [3:0]   lookup_ecc_err_way;

  //----------------------------------------------------------------------------
  // Arbitration
  //----------------------------------------------------------------------------

  // Lookups already in progress have highest priority, then pagewalk writes,
  // and finally new lookups.
  assign pagewalk_ram_pri = ~lookup_ram_req_i;
  assign pagewalk_ram_pri_o = pagewalk_ram_pri;
  assign lookup_ram_pri = ~pagewalk_ram_req_i;
  assign lookup_ram_pri_o = lookup_ram_pri;

  assign lookup_select_dside = (lookup_ram_ready_i &
                                ~pagewalk_busy_dside_i &
                                lookup_ram_pri &
                                ~mbist_en_i &
                                dcu_va_valid_early_dc1_i &
                                ~dpu_utlb_hit_dc1_i);

  assign lookup_select_iside = (lookup_ram_ready_i &
                                ~pagewalk_busy_iside_i &
                                ifu_utlb_miss_req_i);

  //----------------------------------------------------------------------------
  // Calculate the RAM control signals
  //----------------------------------------------------------------------------

  // - lookup only reads RAM and always enables all ways
  // - debug operation from lookup block can only read (all ways) from
  //   main/walk/IPA  RAM
  // - lookup cp operations always enable all ways for reading and on hit, write
  //   only the selected way
  // - pagewalk can read  walk/IPA RAM and always enables all ways
  // - pagewalk can write walk/IPA/main RAM and writes to one selected way
  // - MBIST can enable one or more RAM ways for simultaneous read, although it
  //   can choose only one way to pass through the read MUX.
  assign tlb_ram_en   = ((lookup_ram_way_i & ~{4{mbist_en_i}}) |
                         ({4{pagewalk_ram_pri & ~mbist_en_i}} & pagewalk_ram_way_i) |
                         ({4{lookup_ram_pri & ~mbist_en_i}} & {4{lookup_select_dside |
                                                                 lookup_select_iside}}) |
                         ({4{mbist_en_i}} & (mbist_read_en_mb4_i |
                                             mbist_write_en_mb4_i))) & ~{4{DFTRAMHOLD}};

  assign tlb_ram_en_o = tlb_ram_en;


  assign tlb_ram_wr_o = (mbist_en_i ? (|mbist_write_en_mb4_i) :
                         lookup_ram_req_i ? lookup_ram_wr_i :
                         pagewalk_ram_wr_i);

  // For MBIST and CP invalidation operations, instead of clearing only valid
  // bit of RAM line, clear all the bits in RAM line. This is to avoid inducing
  // ECC error during invalidation operation. For all other operations, write 
  // the desired data with correct ECC value
  assign tlb_ram_wdata_o = ((lookup_ram_req_i | mbist_en_i) ?
                             (mbist_in_data_mb4_i & {`CA53_TLB_RAM_W{mbist_en_i}}) :
                             pagewalk_ram_wr_data_i);

  // The first cycle of an iside lookup always uses the page size that hit on
  // the last iside lookup.
  always @*
  case (lookup_ram_i_size_i)
    3'b000,
    3'b001:  lookup_index_iside = ifu_va_if2_i[18:12]; // 4k
    3'b010,
    3'b011:  lookup_index_iside = ifu_va_if2_i[22:16]; // 64k
    3'b100:  lookup_index_iside = ifu_va_if2_i[26:20]; // 1M
    3'b101:  lookup_index_iside = ifu_va_if2_i[27:21]; // 2M
    3'b110:  lookup_index_iside = ifu_va_if2_i[30:24]; // 16M
    3'b111:  lookup_index_iside = ifu_va_if2_i[35:29]; // 512M
    default: lookup_index_iside = {7{1'bx}};
  endcase

  // The first cycle of an dside lookup always uses the page size that hit on
  // the last dside lookup.
  always @*
  case (lookup_ram_d_size_i)
    3'b000,
    3'b001:  lookup_index_dside = dpu_va_dc1_i[18:12]; // 4k
    3'b010,
    3'b011:  lookup_index_dside = dpu_va_dc1_i[22:16]; // 64k
    3'b100:  lookup_index_dside = dpu_va_dc1_i[26:20]; // 1M
    3'b101:  lookup_index_dside = dpu_va_dc1_i[27:21]; // 2M
    3'b110:  lookup_index_dside = dpu_va_dc1_i[30:24]; // 16M
    3'b111:  lookup_index_dside = dpu_va_dc1_i[35:29]; // 512M
    default: lookup_index_dside = {7{1'bx}};
  endcase

  // For all but the first cycle of a lookup, and for all cycles of a CP maint
  // op, calculate the RAM address the cycle before the access to reduce the
  // amount of muxing needed on the RAM input.

  // - For lookups, lookup block reads only main TLB RAM, hence
  //   lookup_index_d/iside are [6:0] and bit[7] is set to zero
  // - For CP15 invalidation operations, Lookup block reads/writes TLB
  //   RAM, WALK and IPA RAMs and hence ram_addr_early is 8-bit address
  // - For pagewalk, pagewalk block can read WALK,IPA RAMs and
  //   write main TLB RAM, hence pagewalk_ram_addr_i is 8-bit

  assign next_ram_addr_early = (mbist_en_i ? dcu_mbist_addr_mb3_i[7:0] :
                                lookup_ram_next_addr_i);

  assign ram_addr_early_en = (lookup_ram_next_req_i | mbist_en_i);

  always @(posedge clk)
  if (ram_addr_early_en) begin
    ram_addr_early <= next_ram_addr_early;
  end

  // Calculate the address for all sources other than the dside.
  assign tlb_ram_addr_other = ((lookup_ram_req_i | mbist_en_i) ? ram_addr_early :
                               pagewalk_ram_req_i ? pagewalk_ram_addr_i :
                               {1'b0, lookup_index_iside});

  assign tlb_ram_addr = lookup_select_dside ? {1'b0, lookup_index_dside} : tlb_ram_addr_other;
  assign tlb_ram_addr_o = tlb_ram_addr;

  always @(posedge clk)
  if (ram_addr_early_en) begin
    tlb_ram_compare_addr <= tlb_ram_addr;
  end

  // Indicate whether the lookup comparison is for the main TLB, walk cache or IPA cache.
  assign walk_lookup = (tlb_ram_compare_addr[7:4] == `CA53_RAM_WALK_PREFIX_ADDR);
  assign ipa_lookup  = (tlb_ram_compare_addr[7:4] == `CA53_RAM_IPA_PREFIX_ADDR);

  //-----------------------------------------------------------------------------
  // Comparators for working out if a lookup hit
  //-----------------------------------------------------------------------------

  // The virtual address must be masked based on the size we are comparing
  // against. The value read from the RAM will have been masked before writing
  // into the RAM, and so we can avoid masking it again here when it is on the
  // critical path.

  // For AArch32, bits lookup_compare_va_i[47:32] are zero when sent by DPU and
  // stored in TLB RAM
  always @*
  case (lookup_compare_size_i)
    3'b000,
    3'b001:  masked_va =  lookup_compare_va_i[47:19]; // 4k
    3'b010,
    3'b011:  masked_va = {lookup_compare_va_i[47:23], {4{1'b0 }}}; // 64k
    3'b100:  masked_va = {lookup_compare_va_i[47:27], {8{1'b0 }}}; // 1M
    3'b101:  masked_va = {lookup_compare_va_i[47:28], {9{1'b0 }}}; // 2M
    3'b110:  masked_va = {lookup_compare_va_i[47:31], {12{1'b0}}}; // 16M
    3'b111:  masked_va = {lookup_compare_va_i[47:36], {17{1'b0}}}; // 512M
    default: masked_va = {29{1'bx}};
  endcase

  // For CP15 invalidate ops, we must mask the virtual address based on the
  // original stage1 page size, not the combined size. This cannot rely on
  // the address being masked before writing into the RAM, as that masking is
  // done based on the combined size. However this is not as timing critical
  // as the lookup comparison.

  // Combined page size used for masking VA before saving to TLB RAM can be
  // same or smaller than S1 size.
  //  - Same combined size means same number of LS VA bits were masked before
  //    saving to TLB RAM.
  //  - Smaller combined size means less number of LS VA bits were masked before
  //    saving to TLB RAM and hence no error is introduced when remasking with S1 size.
  // S1 page size for CortexA53 is 3-bit signal and all sizes are encoded within
  // it, so no other signal (e.g. LPAE) is required while masking

  always @*
  case (tlb_ram_rdata0_i[`CA53_RAM_S1SIZE_BITS])
    3'b000:  va_mask0 = 36'hFFFFFFFFF; // 4k
    3'b001:  va_mask0 = 36'hFFFFFFFF0; // 64k
    3'b010:  va_mask0 = 36'hFFFFFFF00; // 1M
    3'b011:  va_mask0 = 36'hFFFFFFE00; // 2M
    3'b100:  va_mask0 = 36'hFFFFFF000; // 16M
    3'b101,
    3'b110,
    3'b111:  va_mask0 = 36'hFFFFC0000; // undefined is also encoded as 512M
    default: va_mask0 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata1_i[`CA53_RAM_S1SIZE_BITS])
    3'b000:  va_mask1 = 36'hFFFFFFFFF; // 4k
    3'b001:  va_mask1 = 36'hFFFFFFFF0; // 64k
    3'b010:  va_mask1 = 36'hFFFFFFF00; // 1M
    3'b011:  va_mask1 = 36'hFFFFFFE00; // 2M
    3'b100:  va_mask1 = 36'hFFFFFF000; // 16M
    3'b101,
    3'b110,
    3'b111:  va_mask1 = 36'hFFFFC0000; // undefined is also encoded as 512M
    default: va_mask1 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata2_i[`CA53_RAM_S1SIZE_BITS])
    3'b000:  va_mask2 = 36'hFFFFFFFFF; // 4k
    3'b001:  va_mask2 = 36'hFFFFFFFF0; // 64k
    3'b010:  va_mask2 = 36'hFFFFFFF00; // 1M
    3'b011:  va_mask2 = 36'hFFFFFFE00; // 2M
    3'b100:  va_mask2 = 36'hFFFFFF000; // 16M
    3'b101,
    3'b110,
    3'b111:  va_mask2 = 36'hFFFFC0000; // undefined is also encoded as 512M
    default: va_mask2 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata3_i[`CA53_RAM_S1SIZE_BITS])
    3'b000:  va_mask3 = 36'hFFFFFFFFF; // 4k
    3'b001:  va_mask3 = 36'hFFFFFFFF0; // 64k
    3'b010:  va_mask3 = 36'hFFFFFFF00; // 1M
    3'b011:  va_mask3 = 36'hFFFFFFE00; // 2M
    3'b100:  va_mask3 = 36'hFFFFFF000; // 16M
    3'b101,
    3'b110,
    3'b111:  va_mask3 = 36'hFFFFC0000; // undefined is also encoded as 512M
    default: va_mask3 = {36{1'bx}};
  endcase

  // Reconstruct the full virtual address for the entries being read from the RAM.
  always @*
  case (tlb_ram_rdata0_i[`CA53_RAM_SIZE_BITS])
    3'b000,
    3'b001:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 29], tlb_ram_compare_addr[6:0]};             // 4k
    3'b010,
    3'b011:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 25], tlb_ram_compare_addr[6:0], {4{1'b0}}};  // 64k
    3'b100:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 21], tlb_ram_compare_addr[6:0], {8{1'b0}}};  // 1M
    3'b101:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 20], tlb_ram_compare_addr[6:0], {9{1'b0}}};  // 2M
    3'b110:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 17], tlb_ram_compare_addr[6:0], {12{1'b0}}}; // 16M
    3'b111:  ram_va0 = {tlb_ram_rdata0_i[`CA53_RAM_VA_MAX_BITS -: 12], tlb_ram_compare_addr[6:0], {17{1'b0}}}; // 512M
    default: ram_va0 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata1_i[`CA53_RAM_SIZE_BITS])
    3'b000,
    3'b001:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 29], tlb_ram_compare_addr[6:0]};             // 4k
    3'b010,
    3'b011:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 25], tlb_ram_compare_addr[6:0], {4{1'b0}}};  // 64k
    3'b100:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 21], tlb_ram_compare_addr[6:0], {8{1'b0}}};  // 1M
    3'b101:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 20], tlb_ram_compare_addr[6:0], {9{1'b0}}};  // 2M
    3'b110:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 17], tlb_ram_compare_addr[6:0], {12{1'b0}}}; // 16M
    3'b111:  ram_va1 = {tlb_ram_rdata1_i[`CA53_RAM_VA_MAX_BITS -: 12], tlb_ram_compare_addr[6:0], {17{1'b0}}}; // 512M
    default: ram_va1 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata2_i[`CA53_RAM_SIZE_BITS])
    3'b000,
    3'b001:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 29], tlb_ram_compare_addr[6:0]};             // 4k
    3'b010,
    3'b011:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 25], tlb_ram_compare_addr[6:0], {4{1'b0}}};  // 64k
    3'b100:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 21], tlb_ram_compare_addr[6:0], {8{1'b0}}};  // 1M
    3'b101:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 20], tlb_ram_compare_addr[6:0], {9{1'b0}}};  // 2M
    3'b110:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 17], tlb_ram_compare_addr[6:0], {12{1'b0}}}; // 16M
    3'b111:  ram_va2 = {tlb_ram_rdata2_i[`CA53_RAM_VA_MAX_BITS -: 12], tlb_ram_compare_addr[6:0], {17{1'b0}}}; // 512M
    default: ram_va2 = {36{1'bx}};
  endcase

  always @*
  case (tlb_ram_rdata3_i[`CA53_RAM_SIZE_BITS])
    3'b000,
    3'b001:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 29], tlb_ram_compare_addr[6:0]};             // 4k
    3'b010,
    3'b011:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 25], tlb_ram_compare_addr[6:0], {4{1'b0}}};  // 64k
    3'b100:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 21], tlb_ram_compare_addr[6:0], {8{1'b0}}};  // 1M
    3'b101:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 20], tlb_ram_compare_addr[6:0], {9{1'b0}}};  // 2M
    3'b110:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 17], tlb_ram_compare_addr[6:0], {12{1'b0}}}; // 16M
    3'b111:  ram_va3 = {tlb_ram_rdata3_i[`CA53_RAM_VA_MAX_BITS -: 12], tlb_ram_compare_addr[6:0], {17{1'b0}}}; // 512M
    default: ram_va3 = {36{1'bx}};
  endcase

  // lookup_compare_size_i[0] gives LPAE status. When set, mode is LPAE, when clear, mode is VMSA
  // For A32 VMSA 1M case, bits VA[47:24] is compared
  // For A32-LPAE and A64-4K 2M case, bits VA[47:25] are compared, masking rest of the bits
  // For A64-64K 512M case, bits VA[47:33] are compared, masking rest of the bits
  assign masked_walk_va = (lookup_compare_size_i[1:0] == 2'b00) ?  lookup_compare_va_i[47:24] :
                          (lookup_compare_size_i[1:0] == 2'b01) ? {lookup_compare_va_i[47:25],1'b0} :
                                                                  {lookup_compare_va_i[47:33],{9{1'b0}}};

  // Extract and compare the individual fields from the RAM.
  // Same bit position in main,walk and IPA RAM
  assign valid_bit = {tlb_ram_rdata3_i[`CA53_RAM_VALID_BITS],
                      tlb_ram_rdata2_i[`CA53_RAM_VALID_BITS],
                      tlb_ram_rdata1_i[`CA53_RAM_VALID_BITS],
                      tlb_ram_rdata0_i[`CA53_RAM_VALID_BITS]};

  assign ng_bit = {tlb_ram_rdata3_i[`CA53_RAM_NG_BITS],
                   tlb_ram_rdata2_i[`CA53_RAM_NG_BITS],
                   tlb_ram_rdata1_i[`CA53_RAM_NG_BITS],
                   tlb_ram_rdata0_i[`CA53_RAM_NG_BITS]};

  assign asid_match = { lookup_compare_asid_i == tlb_ram_rdata3_i[`CA53_RAM_ASID_BITS],
                        lookup_compare_asid_i == tlb_ram_rdata2_i[`CA53_RAM_ASID_BITS],
                        lookup_compare_asid_i == tlb_ram_rdata1_i[`CA53_RAM_ASID_BITS],
                        lookup_compare_asid_i == tlb_ram_rdata0_i[`CA53_RAM_ASID_BITS]};

  assign vmid_match = {lookup_compare_vmid_i == tlb_ram_rdata3_i[`CA53_RAM_VMID_BITS],
                       lookup_compare_vmid_i == tlb_ram_rdata2_i[`CA53_RAM_VMID_BITS],
                       lookup_compare_vmid_i == tlb_ram_rdata1_i[`CA53_RAM_VMID_BITS],
                       lookup_compare_vmid_i == tlb_ram_rdata0_i[`CA53_RAM_VMID_BITS]};

  assign ns_match = ({4{ipa_lookup}} |
                     {lookup_compare_ns_i == tlb_ram_rdata3_i[`CA53_RAM_NS_WALK_BITS],
                      lookup_compare_ns_i == tlb_ram_rdata2_i[`CA53_RAM_NS_WALK_BITS],
                      lookup_compare_ns_i == tlb_ram_rdata1_i[`CA53_RAM_NS_WALK_BITS],
                      lookup_compare_ns_i == tlb_ram_rdata0_i[`CA53_RAM_NS_WALK_BITS]});

  // For A32, when APHYP is 3'b100, HAP[0] will always be clear
  // For A64, when APHYP is 3'b100, HAP[0] can be clear or set depending on EL2 or EL3 respectively
  assign tlb_ram_rdata3_hyp = (tlb_ram_rdata3_i[`CA53_RAM_APHYP_BITS] == 3'b100) & ~tlb_ram_rdata3_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata2_hyp = (tlb_ram_rdata2_i[`CA53_RAM_APHYP_BITS] == 3'b100) & ~tlb_ram_rdata2_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata1_hyp = (tlb_ram_rdata1_i[`CA53_RAM_APHYP_BITS] == 3'b100) & ~tlb_ram_rdata1_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata0_hyp = (tlb_ram_rdata0_i[`CA53_RAM_APHYP_BITS] == 3'b100) & ~tlb_ram_rdata0_i[`CA53_RAM_HAP0_BITS];

  assign hyp_match = {4{ipa_lookup}} |
                     {(lookup_compare_hyp_i == (walk_lookup ? tlb_ram_rdata3_i[`CA53_RAM_WALK_EL2_BITS] : tlb_ram_rdata3_hyp)),
                      (lookup_compare_hyp_i == (walk_lookup ? tlb_ram_rdata2_i[`CA53_RAM_WALK_EL2_BITS] : tlb_ram_rdata2_hyp)),
                      (lookup_compare_hyp_i == (walk_lookup ? tlb_ram_rdata1_i[`CA53_RAM_WALK_EL2_BITS] : tlb_ram_rdata1_hyp)),
                      (lookup_compare_hyp_i == (walk_lookup ? tlb_ram_rdata0_i[`CA53_RAM_WALK_EL2_BITS] : tlb_ram_rdata0_hyp))};

  // For A32, when APHYP is 3'b100, HAP[0] will always be clear
  // For A64, when APHYP is 3'b100, HAP[0] can be clear or set depending on EL2 or EL3 respectively
  assign tlb_ram_rdata3_el3 = (tlb_ram_rdata3_i[`CA53_RAM_APHYP_BITS] == 3'b100) & tlb_ram_rdata3_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata2_el3 = (tlb_ram_rdata2_i[`CA53_RAM_APHYP_BITS] == 3'b100) & tlb_ram_rdata2_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata1_el3 = (tlb_ram_rdata1_i[`CA53_RAM_APHYP_BITS] == 3'b100) & tlb_ram_rdata1_i[`CA53_RAM_HAP0_BITS];
  assign tlb_ram_rdata0_el3 = (tlb_ram_rdata0_i[`CA53_RAM_APHYP_BITS] == 3'b100) & tlb_ram_rdata0_i[`CA53_RAM_HAP0_BITS];

  assign el3_match = {4{ipa_lookup}} |
                     {(lookup_compare_el3_i == (walk_lookup ? tlb_ram_rdata3_i[`CA53_RAM_WALK_EL3_BITS] : tlb_ram_rdata3_el3)),
                      (lookup_compare_el3_i == (walk_lookup ? tlb_ram_rdata2_i[`CA53_RAM_WALK_EL3_BITS] : tlb_ram_rdata2_el3)),
                      (lookup_compare_el3_i == (walk_lookup ? tlb_ram_rdata1_i[`CA53_RAM_WALK_EL3_BITS] : tlb_ram_rdata1_el3)),
                      (lookup_compare_el3_i == (walk_lookup ? tlb_ram_rdata0_i[`CA53_RAM_WALK_EL3_BITS] : tlb_ram_rdata0_el3))};

  // For lookups, VA must only match if the entry is for the same size as
  // we are currently searching for.

  //------------------------------------------------------
  // Support for granule calculation
  assign va_only_match = {(masked_va == tlb_ram_rdata3_i[`CA53_RAM_VA_BITS]),
                          (masked_va == tlb_ram_rdata2_i[`CA53_RAM_VA_BITS]),
                          (masked_va == tlb_ram_rdata1_i[`CA53_RAM_VA_BITS]),
                          (masked_va == tlb_ram_rdata0_i[`CA53_RAM_VA_BITS])};

  assign size_only_match = {4{lookup_s1s2_a64_g64_i ? (lookup_compare_size_i[2:1] != 2'b00) : 1'b1}} &
                           {(lookup_compare_size_i == tlb_ram_rdata3_i[`CA53_RAM_SIZE_BITS]),
                            (lookup_compare_size_i == tlb_ram_rdata2_i[`CA53_RAM_SIZE_BITS]),
                            (lookup_compare_size_i == tlb_ram_rdata1_i[`CA53_RAM_SIZE_BITS]),
                            (lookup_compare_size_i == tlb_ram_rdata0_i[`CA53_RAM_SIZE_BITS])};

  assign va_match = (va_only_match & size_only_match);

  //------------------------------------------------------

  assign va_sign_match = {(lookup_compare_va_i[48] == tlb_ram_rdata3_i[`CA53_RAM_SIGN_BITS]),
                          (lookup_compare_va_i[48] == tlb_ram_rdata2_i[`CA53_RAM_SIGN_BITS]),
                          (lookup_compare_va_i[48] == tlb_ram_rdata1_i[`CA53_RAM_SIGN_BITS]),
                          (lookup_compare_va_i[48] == tlb_ram_rdata0_i[`CA53_RAM_SIGN_BITS])};

  // For CP invalidates, the VA match ignores the size, because the masking is
  // done based on the original stage1 size (which will always be equal or
  // larger than the combined size).
  assign cp_va_match = {(lookup_compare_va_i[47:12] & va_mask3) == (ram_va3 & va_mask3),
                        (lookup_compare_va_i[47:12] & va_mask2) == (ram_va2 & va_mask2),
                        (lookup_compare_va_i[47:12] & va_mask1) == (ram_va1 & va_mask1),
                        (lookup_compare_va_i[47:12] & va_mask0) == (ram_va0 & va_mask0)};

  assign walk_va_sign_match = {(lookup_compare_va_i[48] == tlb_ram_rdata3_i[`CA53_RAM_WALK_VA_SIGN_BITS]),
                               (lookup_compare_va_i[48] == tlb_ram_rdata2_i[`CA53_RAM_WALK_VA_SIGN_BITS]),
                               (lookup_compare_va_i[48] == tlb_ram_rdata1_i[`CA53_RAM_WALK_VA_SIGN_BITS]),
                               (lookup_compare_va_i[48] == tlb_ram_rdata0_i[`CA53_RAM_WALK_VA_SIGN_BITS])};

  assign walk_va_only_match = {(masked_walk_va == tlb_ram_rdata3_i[`CA53_RAM_WALK_VA_BITS]),
                               (masked_walk_va == tlb_ram_rdata2_i[`CA53_RAM_WALK_VA_BITS]),
                               (masked_walk_va == tlb_ram_rdata1_i[`CA53_RAM_WALK_VA_BITS]),
                               (masked_walk_va == tlb_ram_rdata0_i[`CA53_RAM_WALK_VA_BITS])};

  assign walk_size_only_match = {4{(lookup_compare_size_i[1:0] != 2'b10)}} &
                                {(lookup_compare_size_i[1:0] == tlb_ram_rdata3_i[`CA53_RAM_WALK_ARCH_BITS]),
                                 (lookup_compare_size_i[1:0] == tlb_ram_rdata2_i[`CA53_RAM_WALK_ARCH_BITS]),
                                 (lookup_compare_size_i[1:0] == tlb_ram_rdata1_i[`CA53_RAM_WALK_ARCH_BITS]),
                                 (lookup_compare_size_i[1:0] == tlb_ram_rdata0_i[`CA53_RAM_WALK_ARCH_BITS])};

  // For S1-A64-64K granule, S2-A64-4K granule/S2-LPAE, entry in Walk cache has ARCH field set
  // to 2'b10 (encoding otherwise unused), i.e. saved as 2M size for 2nd last stage.
  // For invalidation operation, lookup_compare_size_i[1:0] = 2'b01 corresponds to 2M comparison
  // It is checked against 
  //  - ARCH field 2'b01 as normal, in walk_size_only_match
  //  - ARCH field 2'b10 in walk_s1_g64_s2_g4_match
  assign walk_s1_g64_s2_g4_match = {4{(lookup_compare_size_i[1:0] == 2'b01)}} & 
                                   {(tlb_ram_rdata3_i[`CA53_RAM_WALK_ARCH_BITS] == 2'b10),
                                    (tlb_ram_rdata2_i[`CA53_RAM_WALK_ARCH_BITS] == 2'b10),
                                    (tlb_ram_rdata1_i[`CA53_RAM_WALK_ARCH_BITS] == 2'b10),
                                    (tlb_ram_rdata0_i[`CA53_RAM_WALK_ARCH_BITS] == 2'b10)};

  assign walk_va_match = walk_va_only_match & (walk_size_only_match | walk_s1_g64_s2_g4_match);


  always @*
  case ({lookup_compare_size_ipa_i,lookup_compare_size_i[2:1]})
    3'b000:  masked_ipa_va =  lookup_compare_va_i[39:16]; // 4k
    3'b001:  masked_ipa_va = {lookup_compare_va_i[39:20], {4{1'b0 }}}; // 64k
    3'b010:  masked_ipa_va = {lookup_compare_va_i[39:25], {9{1'b0 }}}; // 2M
    3'b011, 
    3'b100,
    3'b101:  masked_ipa_va = {lookup_compare_va_i[39:33], {17{1'b0}}}; // 512M
    default: masked_ipa_va = {24{1'bx}};
  endcase

  assign ipa_va_only_match = {(masked_ipa_va == tlb_ram_rdata3_i[`CA53_RAM_IPA_IPA_BITS]),
                              (masked_ipa_va == tlb_ram_rdata2_i[`CA53_RAM_IPA_IPA_BITS]),
                              (masked_ipa_va == tlb_ram_rdata1_i[`CA53_RAM_IPA_IPA_BITS]),
                              (masked_ipa_va == tlb_ram_rdata0_i[`CA53_RAM_IPA_IPA_BITS])};

  assign ipa_any_sizes_match = {4{~lookup_compare_size_ipa_i}} &
                               {(lookup_compare_size_i[2:0] == tlb_ram_rdata3_i[`CA53_RAM_IPA_SIZE_BITS]),
                                (lookup_compare_size_i[2:0] == tlb_ram_rdata2_i[`CA53_RAM_IPA_SIZE_BITS]),
                                (lookup_compare_size_i[2:0] == tlb_ram_rdata1_i[`CA53_RAM_IPA_SIZE_BITS]),
                                (lookup_compare_size_i[2:0] == tlb_ram_rdata0_i[`CA53_RAM_IPA_SIZE_BITS])};

  assign ipa_512m_size_match = {4{lookup_compare_size_ipa_i}} &
                               {(tlb_ram_rdata3_i[`CA53_RAM_IPA_SIZE_BITS] == 3'b111),
                                (tlb_ram_rdata2_i[`CA53_RAM_IPA_SIZE_BITS] == 3'b111),
                                (tlb_ram_rdata1_i[`CA53_RAM_IPA_SIZE_BITS] == 3'b111),
                                (tlb_ram_rdata0_i[`CA53_RAM_IPA_SIZE_BITS] == 3'b111)};

  assign ipa_va_match = ipa_va_only_match & (ipa_any_sizes_match | ipa_512m_size_match);

  // For lookups (including CP15), various fields must match depending on the operation type.
  // For ASID matching, it is a match if
  //  - ASID comparison is not required
  //  - ASID comparison is required and the page is global (~ng_bit)
  //  - ASID comparison is required and ASID matches
  assign cp_lookup_hit_way_o = lookup_ecc_err_way | (valid_bit &
                                ns_match  &
                                hyp_match &
                                el3_match &
                                ({4{~lookup_compare_use_va_i}}   |
                                  (ipa_lookup  ? ipa_va_match :
                                   walk_lookup ? (walk_va_match & walk_va_sign_match) : (cp_va_match & va_sign_match))) &
                                ({4{~lookup_compare_use_vmid_i}} | vmid_match) &
                                ({4{~lookup_compare_use_asid_i}} | ((ng_bit & asid_match) |
                                                                    ({4{lookup_compare_use_global_i}} & ~ng_bit))));

  // For lookups that might update the uTLB, use a slightly faster version.
  assign lookup_hit_way = valid_bit     &
                          ns_match      &
                          hyp_match     &
                          el3_match     &
                          va_match      &
                          va_sign_match &
                          vmid_match    &
                          (asid_match | ~ng_bit);

  // If there was a VA[63:48] sign error, any lookup hits are disregarded
  assign lookup_hit = |lookup_hit_way & ~lookup_va_sign_err_i;
  assign lookup_hit_o = lookup_hit;

  //-----------------------------------------------------------------------------
  // TLB RAM parity error detection
  //-----------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_ramctl0
  
    // local declarations
    wire       lookup_rd_req;
    wire       lookup_ecc_err_addr_en;
    reg  [6:0] lookup_ecc_err_addr;
    wire       pagewalk_rd_req;
    wire       next_pagewalk_rd_req_dly;
    reg        pagewalk_rd_req_dly;
    wire       pagewalk_ecc_err_addr_en;
    reg  [3:0] walk_ipa_ecc_err_addr;
  
  
    // Register ECC error address. Addresses from lookup and pagewalk have to 
    // be registered separately, as WALK cache/IPA cache ECC error can come in
    // parallel with lookup ECC error.
    assign lookup_rd_req = ((lookup_select_iside | 
                             lookup_select_dside | 
                             lookup_ram_req_i) & ~lookup_ram_wr_i);
  
    assign pagewalk_rd_req = (pagewalk_ram_req_i & ~pagewalk_ram_wr_i);
  
    assign next_pagewalk_rd_req_dly = pagewalk_rd_req & pagewalk_ram_pri;
  
    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      pagewalk_rd_req_dly <= 1'b0;
    end else begin
      pagewalk_rd_req_dly <= next_pagewalk_rd_req_dly;
    end
  
    assign lookup_ecc_err_addr_en = (lookup_rd_req & ~lookup_state_lookup_i) |
                                    (lookup_rd_req & lookup_state_lookup_i & ~lookup_ecc_err);
  
    assign pagewalk_ecc_err_addr_en = (pagewalk_rd_req & ~pagewalk_rd_req_dly) |
                                      (pagewalk_rd_req & pagewalk_rd_req_dly & ~lookup_ecc_err);
  
    always @(posedge clk)
    if (lookup_ecc_err_addr_en) begin
      lookup_ecc_err_addr <= tlb_ram_addr[6:0];
    end
  
    always @(posedge clk) 
    if (pagewalk_ecc_err_addr_en) begin
      walk_ipa_ecc_err_addr <= tlb_ram_addr[3:0];
    end
  
    assign lookup_ecc_err_way = {((^{tlb_ram_rdata3_i[116],tlb_ram_rdata3_i[113:62]} |
                                   ^{tlb_ram_rdata3_i[115],tlb_ram_rdata3_i[61:31]}  |
                                   ^{tlb_ram_rdata3_i[114],tlb_ram_rdata3_i[30:0]})),
                                 (
                                  (^{tlb_ram_rdata2_i[116],tlb_ram_rdata2_i[113:62]} |
                                   ^{tlb_ram_rdata2_i[115],tlb_ram_rdata2_i[61:31]}  |
                                   ^{tlb_ram_rdata2_i[114],tlb_ram_rdata2_i[30:0]})),
                                 (
                                  (^{tlb_ram_rdata1_i[116],tlb_ram_rdata1_i[113:62]} |
                                   ^{tlb_ram_rdata1_i[115],tlb_ram_rdata1_i[61:31]}  |
                                   ^{tlb_ram_rdata1_i[114],tlb_ram_rdata1_i[30:0]})),
                                 (
                                  (^{tlb_ram_rdata0_i[116],tlb_ram_rdata0_i[113:62]} |
                                   ^{tlb_ram_rdata0_i[115],tlb_ram_rdata0_i[61:31]}  |
                                   ^{tlb_ram_rdata0_i[114],tlb_ram_rdata0_i[30:0]}))};
  
    assign lookup_ecc_err        = |(lookup_ecc_err_way);
  
    assign lookup_ecc_err_o        = lookup_ecc_err;
    assign lookup_ecc_err_way_o    = lookup_ecc_err_way;
    assign lookup_ecc_err_addr_o   = lookup_ecc_err_addr;
    assign walk_ipa_ecc_err_addr_o = walk_ipa_ecc_err_addr;
  
  end else begin : g_protection_stubs_ramctl0
  
    assign lookup_ecc_err          = 1'b0;
    assign lookup_ecc_err_way      = 4'b0000;
    assign lookup_ecc_err_o        = lookup_ecc_err;
    assign lookup_ecc_err_way_o    = lookup_ecc_err_way; 
    assign lookup_ecc_err_addr_o   = {7{1'b0}};
    assign walk_ipa_ecc_err_addr_o = {4{1'b0}};
  
  end endgenerate

  //-----------------------------------------------------------------------------
  // Signals to help select victim way in Lookup and Pagewalk blocks
  //-----------------------------------------------------------------------------

  assign sel_victim_round_robin_o = (valid_bit == 4'h0) | (valid_bit == 4'hF);

  assign first_available_way_o = (~valid_bit[0]) ? 2'b00 :
                                 (~valid_bit[1]) ? 2'b01 :
                                 (~valid_bit[2]) ? 2'b10 : 2'b11;

  //-----------------------------------------------------------------------------
  // Format and mux the data ready for writing into the uTLBs
  //-----------------------------------------------------------------------------


  // The lower bits of the PA are set to the same as the VA for sizes larger than
  // 4k, because the dside uTLB only supports 4k page sizes. The iside also
  // supports 1M sizes, but bits [19:12] are ignored when matching that size.
  always @*
  case (lookup_compare_size_i)
    3'b000,
    3'b001:  lower_va_bits =  {28{1'b0}};                              // 4k
    3'b010,
    3'b011:  lower_va_bits = {{24{1'b0}}, lookup_compare_va_i[15:12]}; // 64k
    3'b100:  lower_va_bits = {{20{1'b0}}, lookup_compare_va_i[19:12]}; // 1M
    3'b101:  lower_va_bits = {{19{1'b0}}, lookup_compare_va_i[20:12]}; // 2M
    3'b110:  lower_va_bits = {{16{1'b0}}, lookup_compare_va_i[23:12]}; // 16M
    3'b111:  lower_va_bits = {{11{1'b0}}, lookup_compare_va_i[28:12]}; // 512M
    default: lower_va_bits =  {28{1'bx}};
  endcase

  // The S1Level field indicates how many levels of stage1 were needed for the translation
  // Although VMSA SuperSection (16M) is level1, it is encoded as level0 to distinguish from level1 section
  //  00 - first level, SuperSection (VMSAv7 only)
  //  01 - first level
  //  10 - second level
  //  11 - third level (LPAE only)
  always @*
    case (tlb_ram_rdata0_i[`CA53_RAM_S1SIZE_BITS])
      `CA53_STAGE_4K  : s1level0  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11; // VMSA ? L2 : L3
      `CA53_STAGE_64K : s1level0  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11; // VMSA ? L2 : L3
      `CA53_STAGE_1M  : s1level0  = 2'b01;
       //A64-64K granule contiguous bit set case
      `CA53_STAGE_2M  : s1level0  = (lookup_compare_size_i[0] &
                                   tlb_ram_rdata0_i[`CA53_RAM_A64_64K_CONTG_BITS]) ? 2'b11 : 2'b10;
      `CA53_STAGE_16M : s1level0  = 2'b00;
      `CA53_STAGE_512M: s1level0  = 2'b10;
      `CA53_STAGE_1G  : s1level0  = 2'b01;
      default         : s1level0  = 2'bxx;
    endcase

  always @*
    case (tlb_ram_rdata1_i[`CA53_RAM_S1SIZE_BITS])
      `CA53_STAGE_4K  : s1level1  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_64K : s1level1  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_1M  : s1level1  = 2'b01;
      `CA53_STAGE_2M  : s1level1  = (lookup_compare_size_i[0] &
                                   tlb_ram_rdata1_i[`CA53_RAM_A64_64K_CONTG_BITS]) ? 2'b11 : 2'b10;
      `CA53_STAGE_16M : s1level1  = 2'b00;
      `CA53_STAGE_512M: s1level1  = 2'b10;
      `CA53_STAGE_1G  : s1level1  = 2'b01;
      default         : s1level1  = 2'bxx;
    endcase

  always @*
    case (tlb_ram_rdata2_i[`CA53_RAM_S1SIZE_BITS])
      `CA53_STAGE_4K  : s1level2  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_64K : s1level2  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_1M  : s1level2  = 2'b01;
      `CA53_STAGE_2M  : s1level2  = (lookup_compare_size_i[0] &
                                   tlb_ram_rdata2_i[`CA53_RAM_A64_64K_CONTG_BITS]) ? 2'b11 : 2'b10;
      `CA53_STAGE_16M : s1level2  = 2'b00;
      `CA53_STAGE_512M: s1level2  = 2'b10;
      `CA53_STAGE_1G  : s1level2  = 2'b01;
      default         : s1level2  = 2'bxx;
    endcase

  always @*
    case (tlb_ram_rdata3_i[`CA53_RAM_S1SIZE_BITS])
      `CA53_STAGE_4K  : s1level3  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_64K : s1level3  = (~lookup_compare_size_i[0]) ? 2'b10 : 2'b11;
      `CA53_STAGE_1M  : s1level3  = 2'b01;
      `CA53_STAGE_2M  : s1level3  = (lookup_compare_size_i[0] &
                                   tlb_ram_rdata3_i[`CA53_RAM_A64_64K_CONTG_BITS]) ? 2'b11 : 2'b10;
      `CA53_STAGE_16M : s1level3  = 2'b00;
      `CA53_STAGE_512M: s1level3  = 2'b10;
      `CA53_STAGE_1G  : s1level3  = 2'b01;
      default         : s1level3  = 2'bxx;
    endcase


  // duTLB data encoding:
  // ---- Bit Fields --       --Bits---
  // Domain     [95:92]        4-bits
  // Fault type [91:85]        7-bits
  // Fault      [84:83]        2-bits
  // S2Level    [82:81]        2-bits
  // S1Level    [80:79]        2-bits
  // MemAttrs   [78:71]        8-bits
  // HAP        [70:69]        2-bits
  // AP/HYP     [68:66]        3-bits
  // NS         [65]           1-bit
  // PA         [64:37]        28-bits
  // VA         [36:0]         37-bits

  // Dside uTLB is a subset of Iside uTLB, hence values used are from I uTLB
  assign dutlb_full_data = {i_utlb_partial_data[49:46],
                            7'b0000000,
                            2'b00, // No fault
                            i_utlb_partial_data[45:44],
                            i_utlb_partial_data[43:42],
                            i_utlb_partial_data[41:34],
                            i_utlb_partial_data[33:32],
                            i_utlb_partial_data[31:29],
                            i_utlb_partial_data[28],
                            i_utlb_partial_data[27:0],
                            lookup_compare_va_i[48:12]};


  // Extract the RAM data that needs to be muxed depending on which way hit.

  assign i_utlb_partial_data0 ={tlb_ram_rdata0_i[`CA53_RAM_XS1NUSR_BITS],   // i_utlb_partial_data0[52]
                               tlb_ram_rdata0_i[`CA53_RAM_XS2_BITS],        // i_utlb_partial_data0[51]
                               tlb_ram_rdata0_i[`CA53_RAM_XS1USR_BITS],     // i_utlb_partial_data0[50]
                               tlb_ram_rdata0_i[`CA53_RAM_DOMAIN_BITS],     // i_utlb_partial_data0[49:46]
                               tlb_ram_rdata0_i[`CA53_RAM_S2LEVEL_BITS],    // i_utlb_partial_data0[45:44]
                               s1level0,                                    // i_utlb_partial_data0[43:42]
                               tlb_ram_rdata0_i[`CA53_RAM_MEMATTR_BITS],    // i_utlb_partial_data0[41:34]
                               tlb_ram_rdata0_i[`CA53_RAM_HAP_BITS],        // i_utlb_partial_data0[33:32]
                               tlb_ram_rdata0_i[`CA53_RAM_APHYP_BITS],      // i_utlb_partial_data0[31:29]
                               tlb_ram_rdata0_i[`CA53_RAM_NS_DESC_BITS],    // i_utlb_partial_data0[28]
                               tlb_ram_rdata0_i[`CA53_RAM_PA_BITS] | lower_va_bits}; // i_utlb_partial_data0[27:0]

  assign i_utlb_partial_data1 ={tlb_ram_rdata1_i[`CA53_RAM_XS1NUSR_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_XS2_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_XS1USR_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_DOMAIN_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_S2LEVEL_BITS],
                               s1level1,
                               tlb_ram_rdata1_i[`CA53_RAM_MEMATTR_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_HAP_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_APHYP_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_NS_DESC_BITS],
                               tlb_ram_rdata1_i[`CA53_RAM_PA_BITS] | lower_va_bits};

  assign i_utlb_partial_data2 ={tlb_ram_rdata2_i[`CA53_RAM_XS1NUSR_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_XS2_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_XS1USR_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_DOMAIN_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_S2LEVEL_BITS],
                               s1level2,
                               tlb_ram_rdata2_i[`CA53_RAM_MEMATTR_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_HAP_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_APHYP_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_NS_DESC_BITS],
                               tlb_ram_rdata2_i[`CA53_RAM_PA_BITS] | lower_va_bits};

  assign i_utlb_partial_data3 ={tlb_ram_rdata3_i[`CA53_RAM_XS1NUSR_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_XS2_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_XS1USR_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_DOMAIN_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_S2LEVEL_BITS],
                               s1level3,
                               tlb_ram_rdata3_i[`CA53_RAM_MEMATTR_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_HAP_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_APHYP_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_NS_DESC_BITS],
                               tlb_ram_rdata3_i[`CA53_RAM_PA_BITS] | lower_va_bits};

  // Select the way based on the hit information. Note that it is possible
  // for more than one ways to hit, and if this happens we prefer lowest number way
  assign i_utlb_partial_data = lookup_hit_way[0] ? i_utlb_partial_data0:
                               lookup_hit_way[1] ? i_utlb_partial_data1:
                               lookup_hit_way[2] ? i_utlb_partial_data2:
                                                   i_utlb_partial_data3;

  // iuTLB data encoding:
  // ----Bit Fields---
  // Size       [96]
  // XS1Nonusr  [95]
  // XS2        [94]
  // XS1Usr     [93]
  // Domain     [92:89]
  // Fault type [88:82]
  // Fault      [81:80]
  // S2Level    [79:78]
  // S1Level    [77:76]
  // MemAttrs   [75:68]
  // ExcpLevel  [67:66]
  // NS         [65]
  // PA         [64:37]
  // VA         [36:0]

  // If TLB RAM [APHYP] = 3'b100, mode is hypervisor
  assign i_utlb_partial_data_excp = (i_utlb_partial_data[31:29] == 3'b100) ?     // AR64-EL3 OR AR32/AR64-EL2 detected
                                      (i_utlb_partial_data[32] ? 2'b11 : 2'b10): // AR64-EL3 if HAP[0] is set else AR32/AR64-EL2
                                      2'b00;                                     // else EL0/EL1

  assign i_utlb_full_data = {lookup_compare_size_i[2],
                             i_utlb_partial_data[52],        // XS1Nonusr
                             i_utlb_partial_data[51],        // XS2
                             i_utlb_partial_data[50],        // XS1Usr
                             i_utlb_partial_data[49:46],     // Domain
                             7'b0000000,                     // Fault type
                             2'b00,                          // Fault
                             i_utlb_partial_data[45:44],     // S2Level
                             i_utlb_partial_data[43:42],     // S1Level
                             i_utlb_partial_data[41:34],     // S1Level
                             i_utlb_partial_data_excp,       // ExcpLevel
                             i_utlb_partial_data[28],        // NS
                             i_utlb_partial_data[27:0],      // PA
                             lookup_compare_va_i[48:12]};    // VA

  // Select between lookup and pagewalk data to return to the uTLB. While we
  // can't have both at the same time for the same side, it is possible for one
  // to be returned to the iside while the other is returned to the dside.

  assign tlb_i_utlb_data_o = pagewalk_i_utlb_enable_i ? pagewalk_i_utlb_data_i[`CA53_IUTLB_DATA_W-1:0] : i_utlb_full_data;
  assign tlb_d_utlb_data_o = pagewalk_d_utlb_enable_i ? pagewalk_d_utlb_data_i[`CA53_DUTLB_DATA_W-1:0] : dutlb_full_data;

  assign tlb_i_utlb_enable_o = ((lookup_i_utlb_might_enable_i & lookup_hit & ~lookup_ecc_err) |
                                pagewalk_i_utlb_enable_i);
  assign tlb_d_utlb_enable_o = ((lookup_d_utlb_might_enable_i & lookup_hit & ~lookup_ecc_err) |
                                pagewalk_d_utlb_enable_i);

  // Provide the speculative might_enable signals out of a flop so that they
  // can be used in an intermediate clock gate in the DPU/IFU.
  assign next_tlb_i_utlb_might_enable = lookup_i_utlb_next_might_enable_i | pagewalk_i_utlb_next_might_enable_i;
  assign next_tlb_d_utlb_might_enable = lookup_d_utlb_next_might_enable_i | pagewalk_d_utlb_next_might_enable_i;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    tlb_i_utlb_might_enable <= 1'b0;
    tlb_d_utlb_might_enable <= 1'b0;
  end else begin
    tlb_i_utlb_might_enable <= next_tlb_i_utlb_might_enable;
    tlb_d_utlb_might_enable <= next_tlb_d_utlb_might_enable;
  end

  assign tlb_i_utlb_might_enable_o = tlb_i_utlb_might_enable;
  assign tlb_d_utlb_might_enable_o = tlb_d_utlb_might_enable;

  // V2P ops must not set the valid bit because the DPU will have forced them
  // to miss in the uTLB and so we must prevent a duplicate entry being marked
  // valid. Additionally, some operations return a result from the other
  // security state which must not be marked as valid for this state, or are
  // writing an IPA rather than a PA.
  assign tlb_d_utlb_valid_o = ((dcu_transl_type_dc1_i == `CA53_TRANSL_NORMAL) &
                               ~(pagewalk_d_utlb_enable_i & |pagewalk_d_utlb_data_i[`CA53_DUTLB_FAULT_BITS]));

  assign tlb_i_utlb_valid_o = ~(pagewalk_i_utlb_enable_i & |pagewalk_i_utlb_data_i[`CA53_IUTLB_FAULT_BITS]);

  assign tlb_d_utlb_lpae_o = pagewalk_d_utlb_enable_i ? pagewalk_lpae_i : lookup_compare_size_i[0];
  assign tlb_i_utlb_lpae_o = pagewalk_i_utlb_enable_i ? pagewalk_lpae_i : lookup_compare_size_i[0];

  //----------------------------------------------------------------------------
  // Walk cache hit comparators
  //----------------------------------------------------------------------------

  // For VMSAv7 each walk cache entry maps 1M of virtual address space, while
  // in LAPE it maps 2M. The lower bit of the address will have been masked
  // before writing to the RAM.

  assign walk_compare_data = {pagewalk_va_sign_i, // Pagewalk VA[48]
                              walk_ram_masked_va_i,
                              asid_pagewalk_i,
                              pagewalk_vmid_i,
                              pagewalk_ns_i,
                              walk_ram_arch_i,
                              ((pagewalk_exception_level_i == 2'b11) & pagewalk_a64_i),
                              pagewalk_hyp_i,
                              1'b1,
                              1'b1};

  assign walk_cache_hit_way[0] = {tlb_ram_rdata0_i[`CA53_RAM_WALK_VA_SIGN_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_VA_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_ASID_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_VMID_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_NS_WALK_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_ARCH_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_EL3_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_EL2_BITS],
                                  tlb_ram_rdata0_i[`CA53_RAM_WALK_VALID_BITS],
                                  pagewalk_enable_walk_compare_i} == walk_compare_data;

  assign walk_cache_hit_way[1] = {tlb_ram_rdata1_i[`CA53_RAM_WALK_VA_SIGN_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_VA_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_ASID_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_VMID_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_NS_WALK_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_ARCH_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_EL3_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_EL2_BITS],
                                  tlb_ram_rdata1_i[`CA53_RAM_WALK_VALID_BITS],
                                  pagewalk_enable_walk_compare_i} == walk_compare_data;

  assign walk_cache_hit_way[2] = {tlb_ram_rdata2_i[`CA53_RAM_WALK_VA_SIGN_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_VA_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_ASID_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_VMID_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_NS_WALK_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_ARCH_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_EL3_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_EL2_BITS],
                                  tlb_ram_rdata2_i[`CA53_RAM_WALK_VALID_BITS],
                                  pagewalk_enable_walk_compare_i} == walk_compare_data;

  assign walk_cache_hit_way[3] = {tlb_ram_rdata3_i[`CA53_RAM_WALK_VA_SIGN_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_VA_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_ASID_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_VMID_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_NS_WALK_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_ARCH_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_EL3_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_EL2_BITS],
                                  tlb_ram_rdata3_i[`CA53_RAM_WALK_VALID_BITS],
                                  pagewalk_enable_walk_compare_i} == walk_compare_data;

  assign walk_cache_hit_o = |walk_cache_hit_way;

  assign walk_ram_data0 = {tlb_ram_rdata0_i[`CA53_RAM_WALK_DOMAIN_BITS],   // [46:43]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_PA_BITS],       // [42:13]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_NSTABLE_BITS],  // [12]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_PXNTABLE_BITS], // [11]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_XNTABLE_BITS],  // [10]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_APTABLE_BITS],  // [9:8]
                           tlb_ram_rdata0_i[`CA53_RAM_WALK_MEMATTR_BITS]}; // [7:0]

  assign walk_ram_data1 = {tlb_ram_rdata1_i[`CA53_RAM_WALK_DOMAIN_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_PA_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_NSTABLE_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_PXNTABLE_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_XNTABLE_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_APTABLE_BITS],
                           tlb_ram_rdata1_i[`CA53_RAM_WALK_MEMATTR_BITS]};

  assign walk_ram_data2 = {tlb_ram_rdata2_i[`CA53_RAM_WALK_DOMAIN_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_PA_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_NSTABLE_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_PXNTABLE_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_XNTABLE_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_APTABLE_BITS],
                           tlb_ram_rdata2_i[`CA53_RAM_WALK_MEMATTR_BITS]};

  assign walk_ram_data3 = {tlb_ram_rdata3_i[`CA53_RAM_WALK_DOMAIN_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_PA_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_NSTABLE_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_PXNTABLE_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_XNTABLE_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_APTABLE_BITS],
                           tlb_ram_rdata3_i[`CA53_RAM_WALK_MEMATTR_BITS]};

  assign walk_cache_data_o = (({47{walk_cache_hit_way[3]}} & walk_ram_data3) |
                              ({47{walk_cache_hit_way[2]}} & walk_ram_data2) |
                              ({47{walk_cache_hit_way[1]}} & walk_ram_data1) |
                              ({47{walk_cache_hit_way[0]}} & walk_ram_data0));

  //----------------------------------------------------------------------------
  // IPA cache hit comparators
  //----------------------------------------------------------------------------


  // The lower bit of the address will have been masked before writing to the RAM.
  assign ipa_compare_data = {pagewalk_ipa_compare_ipa_i[39:16],
                            pagewalk_vmid_i,
                            pagewalk_ipa_compare_size_i,
                            stage2_pagewalk_a64_g64_i,
                            1'b1,
                            1'b1};

  assign ipa_cache_hit_way[0] = {tlb_ram_rdata0_i[`CA53_RAM_IPA_IPA_BITS],    // [37:14]
                                 tlb_ram_rdata0_i[`CA53_RAM_IPA_VMID_BITS],   // [13:6]
                                 tlb_ram_rdata0_i[`CA53_RAM_IPA_SIZE_BITS],   // [5:3]
                                 tlb_ram_rdata0_i[`CA53_RAM_IPA_CONTG_BITS],  // [2]
                                 tlb_ram_rdata0_i[`CA53_RAM_IPA_VALID_BITS],  // [1]
                                 (pagewalk_state_ipa_compare_i &              // [0]
                                 pagewalk_ram_pri)} == ipa_compare_data;

  assign ipa_cache_hit_way[1] = {tlb_ram_rdata1_i[`CA53_RAM_IPA_IPA_BITS],
                                 tlb_ram_rdata1_i[`CA53_RAM_IPA_VMID_BITS],
                                 tlb_ram_rdata1_i[`CA53_RAM_IPA_SIZE_BITS],
                                 tlb_ram_rdata1_i[`CA53_RAM_IPA_CONTG_BITS],
                                 tlb_ram_rdata1_i[`CA53_RAM_IPA_VALID_BITS],
                                 (pagewalk_state_ipa_compare_i &
                                 pagewalk_ram_pri)} == ipa_compare_data;

  assign ipa_cache_hit_way[2] = {tlb_ram_rdata2_i[`CA53_RAM_IPA_IPA_BITS],
                                 tlb_ram_rdata2_i[`CA53_RAM_IPA_VMID_BITS],
                                 tlb_ram_rdata2_i[`CA53_RAM_IPA_SIZE_BITS],
                                 tlb_ram_rdata2_i[`CA53_RAM_IPA_CONTG_BITS],
                                 tlb_ram_rdata2_i[`CA53_RAM_IPA_VALID_BITS],
                                 (pagewalk_state_ipa_compare_i &
                                 pagewalk_ram_pri)} == ipa_compare_data;

  assign ipa_cache_hit_way[3] = {tlb_ram_rdata3_i[`CA53_RAM_IPA_IPA_BITS],
                                 tlb_ram_rdata3_i[`CA53_RAM_IPA_VMID_BITS],
                                 tlb_ram_rdata3_i[`CA53_RAM_IPA_SIZE_BITS],
                                 tlb_ram_rdata3_i[`CA53_RAM_IPA_CONTG_BITS],
                                 tlb_ram_rdata3_i[`CA53_RAM_IPA_VALID_BITS],
                                 (pagewalk_state_ipa_compare_i &
                                 pagewalk_ram_pri)} == ipa_compare_data;

  assign ipa_cache_hit_way_o = ipa_cache_hit_way;



  assign ipa_ram_data0 = {tlb_ram_rdata0_i[`CA53_RAM_IPA_CONTG_BITS],
                          tlb_ram_rdata0_i[`CA53_RAM_IPA_PA_BITS],
                          tlb_ram_rdata0_i[`CA53_RAM_IPA_XN_BIT],
                          tlb_ram_rdata0_i[`CA53_RAM_IPA_HAP_BITS],
                          tlb_ram_rdata0_i[`CA53_RAM_IPA_SH_BITS],
                          tlb_ram_rdata0_i[`CA53_RAM_IPA_MEMATTR_BITS]};

  assign ipa_ram_data1 = {tlb_ram_rdata1_i[`CA53_RAM_IPA_CONTG_BITS],
                          tlb_ram_rdata1_i[`CA53_RAM_IPA_PA_BITS],
                          tlb_ram_rdata1_i[`CA53_RAM_IPA_XN_BIT],
                          tlb_ram_rdata1_i[`CA53_RAM_IPA_HAP_BITS],
                          tlb_ram_rdata1_i[`CA53_RAM_IPA_SH_BITS],
                          tlb_ram_rdata1_i[`CA53_RAM_IPA_MEMATTR_BITS]};

  assign ipa_ram_data2 = {tlb_ram_rdata2_i[`CA53_RAM_IPA_CONTG_BITS],
                          tlb_ram_rdata2_i[`CA53_RAM_IPA_PA_BITS],
                          tlb_ram_rdata2_i[`CA53_RAM_IPA_XN_BIT],
                          tlb_ram_rdata2_i[`CA53_RAM_IPA_HAP_BITS],
                          tlb_ram_rdata2_i[`CA53_RAM_IPA_SH_BITS],
                          tlb_ram_rdata2_i[`CA53_RAM_IPA_MEMATTR_BITS]};

  assign ipa_ram_data3 = {tlb_ram_rdata3_i[`CA53_RAM_IPA_CONTG_BITS],
                          tlb_ram_rdata3_i[`CA53_RAM_IPA_PA_BITS],
                          tlb_ram_rdata3_i[`CA53_RAM_IPA_XN_BIT],
                          tlb_ram_rdata3_i[`CA53_RAM_IPA_HAP_BITS],
                          tlb_ram_rdata3_i[`CA53_RAM_IPA_SH_BITS],
                          tlb_ram_rdata3_i[`CA53_RAM_IPA_MEMATTR_BITS]};

  assign ipa_cache_data_o = (({38{ipa_cache_hit_way[3]}} & ipa_ram_data3) |
                             ({38{ipa_cache_hit_way[2]}} & ipa_ram_data2) |
                             ({38{ipa_cache_hit_way[1]}} & ipa_ram_data1) |
                             ({38{ipa_cache_hit_way[0]}} & ipa_ram_data0));

  //----------------------------------------------------------------------------
  // Cache debug and MBIST
  //----------------------------------------------------------------------------

  // For cache debug ops and MBIST, the full RAM data needs to be read, but the
  // mux control does not depend on the RAM contents.
  assign mbist_dbgdr_way = mbist_en_i ? dcu_mbist_array_mb3_i[1:0] : dbgdr_ram_way_i;

  assign dbgdr_reg_wr_data_o = (mbist_dbgdr_way == 2'b00) ? tlb_ram_rdata0_i:
                               (mbist_dbgdr_way == 2'b01) ? tlb_ram_rdata1_i:
                               (mbist_dbgdr_way == 2'b10) ? tlb_ram_rdata2_i:
                                                            tlb_ram_rdata3_i;

  //----------------------------------------------------------------------------
  // Support for ECC reporting
  //----------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_ramctl1

    wire [2:0] tlb_pty_way;
  
    assign tlb_pty_valid_o = (tlb_pty_valid_non_cp_i | tlb_pty_valid_cp_i);
  
    assign tlb_pty_way = tlb_pty_valid_cp_i ? tlb_pty_way_cp_i : tlb_pty_way_non_cp_i;
  
    assign tlb_pty_way_bank_id_o = tlb_pty_way[0] ? 2'b00 :
                                   tlb_pty_way[1] ? 2'b01 :
                                   tlb_pty_way[2] ? 2'b10 : 2'b11;
  
    assign tlb_pty_index_o = tlb_pty_valid_cp_i ? ram_addr_early : pagewalk_ram_addr_i;
  
  end else begin : g_protection_stubs_ramctl1
  
    assign tlb_pty_valid_o       = 1'b0;
    assign tlb_pty_way_bank_id_o = 2'b00;
    assign tlb_pty_index_o       = {8{1'b0}};
  
  end endgenerate

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  reg    ovl_lookup_ram_next_req_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_lookup_ram_next_req_reg <= 1'b0;
  end else begin
    ovl_lookup_ram_next_req_reg <= lookup_ram_next_req_i;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A new lookup must not start at the same time as an existing lookup")
  u_ovl_new_lookup1 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (lookup_select_iside),
                     .consequent_expr (~lookup_ram_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A new lookup must not start at the same time as an existing lookup")
  u_ovl_new_lookup2 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (lookup_select_dside),
                     .consequent_expr (~lookup_ram_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Pagewalks must not access the RAMs at the same time as a lookup")
  u_ovl_pagewalk_lookup (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (pagewalk_ram_req_i),
                         .consequent_expr (~lookup_select_dside));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Pagewalk way must be zero when not making a request")
  u_ovl_pagewalk_way (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (~pagewalk_ram_req_i),
                      .consequent_expr (pagewalk_ram_way_i == 4'h0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Lookup way must be zero when not making a request")
  u_ovl_lookup_way (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr (~lookup_ram_req_i),
                    .consequent_expr (lookup_ram_way_i == 2'b00));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_ram_req_i must be preceeded by lookup_ram_next_req_i")
  u_ovl_lookup_ram_next_req (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (lookup_ram_req_i),
                             .consequent_expr (ovl_lookup_ram_next_req_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Pagewalks must not enable both uTLB at the same time")
  u_ovl_pagewalk_enables (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (pagewalk_i_utlb_enable_i),
                          .consequent_expr (~pagewalk_d_utlb_enable_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ram_addr_early_en")
  u_ovl_x_ram_addr_early_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (ram_addr_early_en));

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_ramctl2
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lookup_ecc_err_addr_en")
    u_ovl_x_lookup_ecc_err_addr_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (g_protection_ramctl0.lookup_rd_req),
                                    .test_expr (g_protection_ramctl0.lookup_ecc_err_addr_en));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pagewalk_ecc_err_addr_en")
    u_ovl_x_pagewalk_ecc_err_addr_en (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .qualifier (g_protection_ramctl0.pagewalk_rd_req),
                                      .test_expr (g_protection_ramctl0.pagewalk_ecc_err_addr_en));
  end endgenerate

  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "At most one ECC error at a time")
  u_ovl_one_hot_tlb_pty_valid (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({tlb_pty_valid_non_cp_i,tlb_pty_valid_cp_i}));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tlb_pty_valid_o should not be X")
  u_ovl_x_tlb_pty_valid (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (tlb_pty_valid_o));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "tlb_pty_way_bank_id_o should not be X when valid")
  u_ovl_x_tlb_pty_way (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (tlb_pty_valid_o),
                       .test_expr (tlb_pty_way_bank_id_o));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "tlb_pty_way_bank_id_o should not be X when valid")
  u_ovl_x_tlb_pty_index (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (tlb_pty_valid_o),
                         .test_expr (tlb_pty_index_o));

`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53tlb_defs.v"
`undef CA53_UNDEFINE
/*END*/
