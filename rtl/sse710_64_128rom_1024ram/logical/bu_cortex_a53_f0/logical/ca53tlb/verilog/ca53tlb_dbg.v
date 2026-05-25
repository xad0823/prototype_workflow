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
// Abstract : TLB debug logic (contains breakpoint and watchpoint registers)
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Logic to control access to the TLB debug registers (i.e. the breakpoint and
// watchpoint register pairs, BRPy and WRPy), and to signal to the IFU/DCU when
// a breakpoint/watchpoint is hit.
//
// The debug registers are instantiated here, i.e. BVRy, BCRy, WVRy and WCRy,
// where y is the register index. Each BVRy and BCRy form a breakpoint
// register pair (BRPy), while each WVRy and WCRy from a watchpoint register
// pair (WRPy). There are six BRPs and four WRPs.
//
// Only the last two BRPs are capable of context ID matching.
//
// The VCR is also instantiated here, and causes a "vcr" hit to be signaled
// if a IFU access is made to an exception vector that is marked in the VCR.
//

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_dbg (
  input  wire         clk,
  input  wire         clk_cpregs,
  input  wire         dbg_resetn_i,

  input  wire         dpu_dbg_tlb_sw_bkpt_wpt_en_i,
  input  wire         dpu_dbg_tlb_hw_bkpt_wpt_en_i,

  input  wire         dpu_dbg_sample_contextid_i,
  input  wire [11:2]  dpu_dbg_addr_i,
  input  wire [31:0]  dpu_dbg_wdata_i,
  input  wire         dpu_dbg_wr_i,
  output wire [31:0]  tlb_dbg_rdata_o,

  input  wire         dcu_priv_dc1_i,
  input  wire         dcu_store_dc1_i,
  input  wire         dcu_wpt_check_512_dc1_i,
  output wire [15:0]  tlb_wpt_hit_dc1_o,

  input  wire [5:0]   dcu_cp_reg_en_dc2_i,
  output wire [63:0]  dbg_cp_read_data_dc2_o,
  input  wire         dcu_cp_reg_write_dc3_i,
  input  wire [5:0]   dcu_cp_reg_en_dc3_i,
  input  wire [48:0]  dcu_cp_reg_data_i,
  input  wire         dcu_cp_reg_size_i,

  input  wire [48:3]  ifu_va_if2_i,
  output wire [3:0]   tlb_bkpt_hit_if2_o,
  output wire [1:0]   tlb_vcr_hit_if2_o,

  input  wire [48:3]  dpu_va_dc1_i,
  input  wire         dpu_hivecs_i,
  input  wire [4:0]   dpu_mode_iss_i,
  input  wire [1:0]   dpu_exception_level_i,
  input  wire [3:1]   dpu_aarch64_at_el_i,
  input  wire         dpu_current_a64_i,
  input  wire [31:5]  dpu_vec_base_s_dc1_i,
  input  wire [31:5]  dpu_vec_base_ns_dc1_i,
  input  wire [31:5]  dpu_mon_vec_base_dc1_i,
  input  wire         dpu_ns_state_i,
  input  wire [3:0]   dpu_dbg_vid_i,

  input  wire         tlb_cp_reg_write_ready_i,
  input  wire [31:0]  context_id_i,
  input  wire [7:0]   tlb_vmid_i
);

  //----------------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------------

  localparam [2:0]  LINK_BRP_NUM = 3'b010;

  //----------------------------------------------------------------------------
  // Flop declarations
  //----------------------------------------------------------------------------

  reg  [16:0] vcr_reg;
  reg  [31:0] cidsr;
  reg  [11:0] vidsr;
  reg  [1:0]  vcr_s_offset_hit;
  reg  [1:0]  vcr_ns_offset_hit;
  reg  [1:0]  vcr_mon_offset_hit;

  //----------------------------------------------------------------------------
  // Wire declarations
  //----------------------------------------------------------------------------

  wire        apb_wr_bvr0;
  wire        apb_wr_bvr1;
  wire        apb_wr_bvr2;
  wire        apb_wr_bvr3;
  wire        apb_wr_bvr4;
  wire        apb_wr_bvr5;

  wire        apb_wr_bxvr0;
  wire        apb_wr_bxvr1;
  wire        apb_wr_bxvr2;
  wire        apb_wr_bxvr3;

  wire        apb_wr_bxvr4;
  wire        apb_wr_bxvr5;

  wire        apb_wr_bcr0;
  wire        apb_wr_bcr1;
  wire        apb_wr_bcr2;
  wire        apb_wr_bcr3;
  wire        apb_wr_bcr4;
  wire        apb_wr_bcr5;
  wire        apb_wr_wvr0;
  wire        apb_wr_wvr1;
  wire        apb_wr_wvr2;
  wire        apb_wr_wvr3;

  wire        apb_wr_wvr0_high;
  wire        apb_wr_wvr1_high;
  wire        apb_wr_wvr2_high;
  wire        apb_wr_wvr3_high;

  wire        apb_wr_wcr0;
  wire        apb_wr_wcr1;
  wire        apb_wr_wcr2;
  wire        apb_wr_wcr3;
  wire        cp14_wr_vcr;
  wire        cp14_wr_bvr0;
  wire        cp14_wr_bvr1;
  wire        cp14_wr_bvr2;
  wire        cp14_wr_bvr3;
  wire        cp14_wr_bvr4;
  wire        cp14_wr_bvr5;

  wire        cp14_wr_bxvr0;
  wire        cp14_wr_bxvr1;
  wire        cp14_wr_bxvr2;
  wire        cp14_wr_bxvr3;

  wire        cp14_wr_bxvr4;
  wire        cp14_wr_bxvr5;
  wire        cp14_wr_bcr0;
  wire        cp14_wr_bcr1;
  wire        cp14_wr_bcr2;
  wire        cp14_wr_bcr3;
  wire        cp14_wr_bcr4;
  wire        cp14_wr_bcr5;
  wire        cp14_wr_wvr0;
  wire        cp14_wr_wvr1;
  wire        cp14_wr_wvr2;
  wire        cp14_wr_wvr3;

  wire        cp14_wr_wvr0_high;
  wire        cp14_wr_wvr1_high;
  wire        cp14_wr_wvr2_high;
  wire        cp14_wr_wvr3_high;

  wire        cp14_wr_wcr0;
  wire        cp14_wr_wcr1;
  wire        cp14_wr_wcr2;
  wire        cp14_wr_wcr3;

  wire [31:0] vcr;
  wire        vcr_s_base_hit;
  wire        vcr_ns_base_hit;
  wire        vcr_mon_base_hit;
  wire        ifu_va_is_hivecs;

  wire [31:0] bcr0;
  wire [31:0] bcr1;
  wire [31:0] bcr2;
  wire [31:0] bcr3;
  wire [31:0] bcr4;
  wire [31:0] bcr5;
  wire [31:0] bvr0;
  wire [31:0] bvr1;
  wire [31:0] bvr2;
  wire [31:0] bvr3;
  wire [31:0] bvr4;
  wire [31:0] bvr5;

  wire [31:0] bxvr0;
  wire [31:0] bxvr1;
  wire [31:0] bxvr2;
  wire [31:0] bxvr3;

  wire [31:0] bxvr4;
  wire [31:0] bxvr5;
  wire [3:0]  brp_hit0;
  wire [3:0]  brp_hit1;
  wire [3:0]  brp_hit2;
  wire [3:0]  brp_hit3;
  wire [3:0]  brp_hit4;
  wire [3:0]  brp_hit5;
  wire [1:0]  cid_vmid_linked_hit;
  wire [31:0] wcr0;
  wire [31:0] wcr1;
  wire [31:0] wcr2;
  wire [31:0] wcr3;
  wire [31:0] wvr0;
  wire [31:0] wvr1;
  wire [31:0] wvr2;
  wire [31:0] wvr3;

  wire [31:0] wvr0_high;
  wire [31:0] wvr1_high;
  wire [31:0] wvr2_high;
  wire [31:0] wvr3_high;


  wire [15:0] wrp_hit0;
  wire [15:0] wrp_hit1;
  wire [15:0] wrp_hit2;
  wire [15:0] wrp_hit3;

  wire [11:0] next_vidsr;
  wire [31:0] read_vidsr;

  wire        tlb_dbg_legacy_mode;
  wire        tlb_vcr_enable;
  wire        dpu_dbg_tlb_bkpt_wpt_en;


  //----------------------------------------------------------------------------
  // APB interface via DPU debug bus
  //----------------------------------------------------------------------------

  assign apb_wr_bvr0  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR0lo);
  assign apb_wr_bvr1  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR1lo);
  assign apb_wr_bvr2  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR2lo);
  assign apb_wr_bvr3  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR3lo);
  assign apb_wr_bvr4  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR4lo);
  assign apb_wr_bvr5  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR5lo);


  assign apb_wr_bxvr0 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR0hi);
  assign apb_wr_bxvr1 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR1hi);
  assign apb_wr_bxvr2 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR2hi);
  assign apb_wr_bxvr3 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR3hi);

  assign apb_wr_bxvr4 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR4hi);
  assign apb_wr_bxvr5 = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR5hi);

  assign apb_wr_bcr0  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR0);
  assign apb_wr_bcr1  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR1);
  assign apb_wr_bcr2  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR2);
  assign apb_wr_bcr3  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR3);
  assign apb_wr_bcr4  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR4);
  assign apb_wr_bcr5  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR5);

  assign apb_wr_wvr0  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR0lo);
  assign apb_wr_wvr1  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR1lo);
  assign apb_wr_wvr2  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR2lo);
  assign apb_wr_wvr3  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR3lo);

  assign apb_wr_wvr0_high = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR0hi);
  assign apb_wr_wvr1_high = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR1hi);
  assign apb_wr_wvr2_high = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR2hi);
  assign apb_wr_wvr3_high = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR3hi);

  assign apb_wr_wcr0  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR0);
  assign apb_wr_wcr1  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR1);
  assign apb_wr_wcr2  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR2);
  assign apb_wr_wcr3  = dpu_dbg_wr_i & (dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR3);

  assign tlb_dbg_rdata_o = (({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_EDCIDSR}} & cidsr) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_EDVIDSR}} & read_vidsr) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR0lo}} & bvr0) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR1lo}} & bvr1) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR2lo}} & bvr2) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR3lo}} & bvr3) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR4lo}} & bvr4) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR5lo}} & bvr5) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR0hi}} & bxvr0) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR1hi}} & bxvr1) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR2hi}} & bxvr2) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR3hi}} & bxvr3) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR4hi}} & bxvr4) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BVR5hi}} & bxvr5) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR0}} & bcr0) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR1}} & bcr1) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR2}} & bcr2) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR3}} & bcr3) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR4}} & bcr4) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_BCR5}} & bcr5) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR0lo}} & wvr0) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR1lo}} & wvr1) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR2lo}} & wvr2) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR3lo}} & wvr3) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR0hi}} & wvr0_high) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR1hi}} & wvr1_high) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR2hi}} & wvr2_high) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WVR3hi}} & wvr3_high) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR0}} & wcr0) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR1}} & wcr1) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR2}} & wcr2) |
                            ({32{dpu_dbg_addr_i[11:2] == `CA53_DBG_WCR3}} & wcr3));

  //----------------------------------------------------------------------------
  // CP14 interface via DCU
  //----------------------------------------------------------------------------

  assign cp14_wr_vcr  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGVCR);

  assign cp14_wr_bvr0  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR0);
  assign cp14_wr_bxvr0 = cp14_wr_bvr0 & dcu_cp_reg_size_i;

  assign cp14_wr_bvr1  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR1);
  assign cp14_wr_bxvr1 = cp14_wr_bvr1 & dcu_cp_reg_size_i;

  assign cp14_wr_bvr2  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR2);
  assign cp14_wr_bxvr2 = cp14_wr_bvr2 & dcu_cp_reg_size_i;

  assign cp14_wr_bvr3  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR3);
  assign cp14_wr_bxvr3 = cp14_wr_bvr3 & dcu_cp_reg_size_i;

  assign cp14_wr_bvr4  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR4);
  assign cp14_wr_bxvr4 = (cp14_wr_bvr4 & dcu_cp_reg_size_i) |
                         (dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBXVR4));

  assign cp14_wr_bvr5  = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBVR5);
  assign cp14_wr_bxvr5 = (cp14_wr_bvr5 & dcu_cp_reg_size_i) |
                         (dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBXVR5));


  assign cp14_wr_bcr0 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR0);
  assign cp14_wr_bcr1 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR1);
  assign cp14_wr_bcr2 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR2);
  assign cp14_wr_bcr3 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR3);
  assign cp14_wr_bcr4 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR4);
  assign cp14_wr_bcr5 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGBCR5);

  assign cp14_wr_wvr0 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWVR0);
  assign cp14_wr_wvr0_high = cp14_wr_wvr0 & dcu_cp_reg_size_i;

  assign cp14_wr_wvr1 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWVR1);
  assign cp14_wr_wvr1_high = cp14_wr_wvr1 & dcu_cp_reg_size_i;

  assign cp14_wr_wvr2 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWVR2);
  assign cp14_wr_wvr2_high = cp14_wr_wvr2 & dcu_cp_reg_size_i;

  assign cp14_wr_wvr3 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWVR3);
  assign cp14_wr_wvr3_high = cp14_wr_wvr3 & dcu_cp_reg_size_i;

  assign cp14_wr_wcr0 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWCR0);
  assign cp14_wr_wcr1 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWCR1);
  assign cp14_wr_wcr2 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWCR2);
  assign cp14_wr_wcr3 = dcu_cp_reg_write_dc3_i & tlb_cp_reg_write_ready_i & (dcu_cp_reg_en_dc3_i == `CA53_CP15_REG_DBGWCR3);

  assign dbg_cp_read_data_dc2_o =
           {32'h00000000,
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGVCR}}  & vcr)   |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBXVR4}} & bxvr4) |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBXVR5}} & bxvr5) |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR0}} & bcr0)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR1}} & bcr1)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR2}} & bcr2)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR3}} & bcr3)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR4}} & bcr4)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBCR5}} & bcr5)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWCR0}} & wcr0)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWCR1}} & wcr1)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWCR2}} & wcr2)  |
             ({32{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWCR3}} & wcr3)} |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR0}} & {(dpu_current_a64_i ? bxvr0 : {32{1'b0}}), bvr0}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR1}} & {(dpu_current_a64_i ? bxvr1 : {32{1'b0}}), bvr1}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR2}} & {(dpu_current_a64_i ? bxvr2 : {32{1'b0}}), bvr2}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR3}} & {(dpu_current_a64_i ? bxvr3 : {32{1'b0}}), bvr3}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR4}} & {(dpu_current_a64_i ? bxvr4 : {32{1'b0}}), bvr4}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGBVR5}} & {(dpu_current_a64_i ? bxvr5 : {32{1'b0}}), bvr5}) |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWVR0}} & {(dpu_current_a64_i ? wvr0_high : {32{1'b0}}), wvr0})  |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWVR1}} & {(dpu_current_a64_i ? wvr1_high : {32{1'b0}}), wvr1})  |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWVR2}} & {(dpu_current_a64_i ? wvr2_high : {32{1'b0}}), wvr2})  |
           ({64{dcu_cp_reg_en_dc2_i == `CA53_CP15_REG_DBGWVR3}} & {(dpu_current_a64_i ? wvr3_high : {32{1'b0}}), wvr3});

  //----------------------------------------------------------------------------
  // Vector Catch Register programming
  //----------------------------------------------------------------------------

  // VCR write
  always @(posedge clk_cpregs or negedge dbg_resetn_i)
  if (~dbg_resetn_i) begin
    vcr_reg[16: 0] <= {17{1'b0}};
  end else if (cp14_wr_vcr) begin
    vcr_reg[ 3: 0] <= dcu_cp_reg_data_i[ 4: 1];
    vcr_reg[ 5: 4] <= dcu_cp_reg_data_i[ 7: 6];
    vcr_reg[ 8: 6] <= dcu_cp_reg_data_i[12:10];
    vcr_reg[10:9]  <= dcu_cp_reg_data_i[15:14];
    vcr_reg[14:11] <= dcu_cp_reg_data_i[28:25];
    vcr_reg[16:15] <= dcu_cp_reg_data_i[31:30];
  end

  // Full VCR value
  assign vcr = {vcr_reg[16:15], // [31:30]
                1'b0,           // [29]
                vcr_reg[14:11], // [28:25]
                {9{1'b0}},      // [24:16]
                vcr_reg[10:9],  // [15:14]
                1'b0,           // [13]
                vcr_reg[8:6],   // [12:10]
                2'b00,          // [9:8]
                vcr_reg[5:4],   // [7:6]
                1'b0,           // [5]
                vcr_reg[3:0],   // [4:1]
                1'b0};          // [0]

  //----------------------------------------------------------------------------
  // VCR hit checks
  //----------------------------------------------------------------------------

  // Not supported in A64
  assign ifu_va_is_hivecs = (ifu_va_if2_i[31:5] == 27'h7fff800);

  // Check if any of the vector bases have hit

  assign vcr_s_base_hit = dpu_hivecs_i ? ifu_va_is_hivecs : (ifu_va_if2_i[31:5] == dpu_vec_base_s_dc1_i);

  assign vcr_ns_base_hit = dpu_hivecs_i ? ifu_va_is_hivecs : (ifu_va_if2_i[31:5] == dpu_vec_base_ns_dc1_i);

  assign vcr_mon_base_hit = (ifu_va_if2_i[31:5] == dpu_mon_vec_base_dc1_i);

  // Mux the VCR mask bits depending on the doubleword offset from the vector base
  always @*
    case (ifu_va_if2_i[4:3])
      2'b00:    vcr_s_offset_hit = {vcr[1],1'b0};
      2'b01:    vcr_s_offset_hit = vcr[3:2];
      2'b10:    vcr_s_offset_hit = vcr[5:4];
      2'b11:    vcr_s_offset_hit = vcr[7:6];
      default:  vcr_s_offset_hit = 2'bxx;
    endcase

  always @*
    case (ifu_va_if2_i[4:3])
      2'b00:    vcr_ns_offset_hit = vcr[25:24];
      2'b01:    vcr_ns_offset_hit = vcr[27:26];
      2'b10:    vcr_ns_offset_hit = vcr[29:28];
      2'b11:    vcr_ns_offset_hit = vcr[31:30];
      default:  vcr_ns_offset_hit = 2'bxx;
    endcase

  // These bits are RES0 if EL3 is A64
  always @*
    case (ifu_va_if2_i[4:3])
      2'b00:    vcr_mon_offset_hit = vcr[9:8]; // VCR[9:8] zero
      2'b01:    vcr_mon_offset_hit = (dpu_aarch64_at_el_i[3] ? 2'b00 : vcr[11:10]);
      2'b10:    vcr_mon_offset_hit = {vcr[13], ( dpu_aarch64_at_el_i[3] ? 1'b0: vcr[12])}; // VCR[13] is zero
      2'b11:    vcr_mon_offset_hit = (dpu_aarch64_at_el_i[3] ? 2'b00 : vcr[15:14]);
      default:  vcr_mon_offset_hit = 2'bxx;
    endcase

  // Legacy mode enable
  //  - EL1 and current exception should be A32, and it can not be EL2
  assign tlb_dbg_legacy_mode = (~dpu_current_a64_i & 
                                (dpu_exception_level_i != 2'b10) &
                                ~dpu_aarch64_at_el_i[1]);

  assign tlb_vcr_enable = dpu_dbg_tlb_sw_bkpt_wpt_en_i & tlb_dbg_legacy_mode;

  // Combine the VCR hit signals
  //  - When EL3 is A64, unbanked base address (i.e. vcr_ns_offset_hit) is used even in secure mode
  assign tlb_vcr_hit_if2_o = (({2{tlb_vcr_enable & ~dpu_ns_state_i & (dpu_aarch64_at_el_i[3] ?
                                                                                  vcr_ns_base_hit :
                                                                                  vcr_s_base_hit)}} & vcr_s_offset_hit) |
                               ({2{tlb_vcr_enable &  dpu_ns_state_i & vcr_ns_base_hit}}  & vcr_ns_offset_hit ) |
                               ({2{tlb_vcr_enable & ~dpu_ns_state_i & vcr_mon_base_hit}} & vcr_mon_offset_hit));

  //----------------------------------------------------------------------------
  // Context and Virtualization ID sampling registers
  //----------------------------------------------------------------------------

  assign next_vidsr = {dpu_dbg_vid_i, tlb_vmid_i};

  always @(posedge clk_cpregs)
  if (dpu_dbg_sample_contextid_i) begin
    cidsr <= context_id_i;
    vidsr <= next_vidsr;
  end

  assign read_vidsr = {vidsr[11:8], 
                       {20{1'b0}}, 
                       ((~vidsr[11] | vidsr[10]) ? {8{1'b0}} : vidsr[7:0])};
  //----------------------------------------------------------------------------
  // Combined hardware and software enables
  //----------------------------------------------------------------------------
  assign dpu_dbg_tlb_bkpt_wpt_en = (dpu_dbg_tlb_sw_bkpt_wpt_en_i | 
                                    dpu_dbg_tlb_hw_bkpt_wpt_en_i);

  //----------------------------------------------------------------------------
  // BRP hit checks
  //----------------------------------------------------------------------------

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b0),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt0 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr0),
    .apb_wr_bvr_i                 (apb_wr_bvr0),
    .apb_wr_bxvr_i                (apb_wr_bxvr0),
    .cp14_wr_bcr_i                (cp14_wr_bcr0),
    .cp14_wr_bvr_i                (cp14_wr_bvr0),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr0),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        (cid_vmid_linked_hit),

    .bcr_o                        (bcr0[31:0]),
    .bvr_o                        (bvr0[31:0]),
    .bxvr_o                       (bxvr0[31:0]),
    .cid_vmid_linked_hit_o        (), // unconnected intentionally
    .brp_hit_o                    (brp_hit0[3:0])
  );

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b0),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt1 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr1),
    .apb_wr_bvr_i                 (apb_wr_bvr1),
    .apb_wr_bxvr_i                (apb_wr_bxvr1),
    .cp14_wr_bcr_i                (cp14_wr_bcr1),
    .cp14_wr_bvr_i                (cp14_wr_bvr1),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr1),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        (cid_vmid_linked_hit),

    .bcr_o                        (bcr1[31:0]),
    .bvr_o                        (bvr1[31:0]),
    .bxvr_o                       (bxvr1[31:0]),
    .cid_vmid_linked_hit_o        (), // unconnected intentionally
    .brp_hit_o                    (brp_hit1[3:0])
  );

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b0),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt2 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr2),
    .apb_wr_bvr_i                 (apb_wr_bvr2),
    .apb_wr_bxvr_i                (apb_wr_bxvr2),
    .cp14_wr_bcr_i                (cp14_wr_bcr2),
    .cp14_wr_bvr_i                (cp14_wr_bvr2),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr2),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        (cid_vmid_linked_hit),

    .bcr_o                        (bcr2[31:0]),
    .bvr_o                        (bvr2[31:0]),
    .bxvr_o                       (bxvr2[31:0]),
    .cid_vmid_linked_hit_o        (), // unconnected intentionally
    .brp_hit_o                    (brp_hit2[3:0])
  );

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b0),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt3 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr3),
    .apb_wr_bvr_i                 (apb_wr_bvr3),
    .apb_wr_bxvr_i                (apb_wr_bxvr3),
    .cp14_wr_bcr_i                (cp14_wr_bcr3),
    .cp14_wr_bvr_i                (cp14_wr_bvr3),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr3),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        (cid_vmid_linked_hit),

    .bcr_o                        (bcr3[31:0]),
    .bvr_o                        (bvr3[31:0]),
    .bxvr_o                       (bxvr3[31:0]),
    .cid_vmid_linked_hit_o        (), // unconnected intentionally
    .brp_hit_o                    (brp_hit3[3:0])
  );

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b1),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt4 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr4),
    .apb_wr_bvr_i                 (apb_wr_bvr4),
    .apb_wr_bxvr_i                (apb_wr_bxvr4),
    .cp14_wr_bcr_i                (cp14_wr_bcr4),
    .cp14_wr_bvr_i                (cp14_wr_bvr4),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr4),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        ({cid_vmid_linked_hit[1], 1'b0}),

    .bcr_o                        (bcr4[31:0]),
    .bvr_o                        (bvr4[31:0]),
    .bxvr_o                       (bxvr4[31:0]),
    .cid_vmid_linked_hit_o        (cid_vmid_linked_hit[0]),
    .brp_hit_o                    (brp_hit4[3:0])
  );

  ca53tlb_dbg_bkpt #(.CID_MATCH(1'b1),
                    .LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_bkpt5 (
    .clk                          (clk),
    .clk_cpregs                   (clk_cpregs),
    .dbg_resetn_i                 (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i    (dpu_dbg_tlb_bkpt_wpt_en),
    .dpu_dbg_tlb_hw_bkpt_wpt_en_i (dpu_dbg_tlb_hw_bkpt_wpt_en_i),
    .tlb_dbg_legacy_mode_i        (tlb_dbg_legacy_mode),
    .apb_wr_bcr_i                 (apb_wr_bcr5),
    .apb_wr_bvr_i                 (apb_wr_bvr5),
    .apb_wr_bxvr_i                (apb_wr_bxvr5),
    .cp14_wr_bcr_i                (cp14_wr_bcr5),
    .cp14_wr_bvr_i                (cp14_wr_bvr5),
    .cp14_wr_bxvr_i               (cp14_wr_bxvr5),
    .dpu_dbg_wdata_i              (dpu_dbg_wdata_i[31:0]),
    .dcu_cp_reg_data_i            (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i            (dcu_cp_reg_size_i),
    .ifu_va_if2_i                 (ifu_va_if2_i[48:3]),
    .dpu_mode_iss_i               (dpu_mode_iss_i[4:0]),
    .dpu_exception_level_i        (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i          (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i            (dpu_current_a64_i),
    .dpu_ns_state_i               (dpu_ns_state_i),
    .context_id_i                 (context_id_i[31:0]),
    .tlb_vmid_i                   (tlb_vmid_i),
    .cid_vmid_linked_hit_i        ({1'b0, cid_vmid_linked_hit[0]}),

    .bcr_o                        (bcr5[31:0]),
    .bvr_o                        (bvr5[31:0]),
    .bxvr_o                       (bxvr5[31:0]),
    .cid_vmid_linked_hit_o        (cid_vmid_linked_hit[1]),
    .brp_hit_o                    (brp_hit5[3:0])
  );

  assign tlb_bkpt_hit_if2_o = (brp_hit0 |
                               brp_hit1 |
                               brp_hit2 |
                               brp_hit3 |
                               brp_hit4 |
                               brp_hit5);

  //----------------------------------------------------------------------------
  // WRP hit checks
  //----------------------------------------------------------------------------

  ca53tlb_dbg_wpt #(.LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_wpt0 (
    .clk                        (clk),
    .clk_cpregs                 (clk_cpregs),
    .dbg_resetn_i               (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i  (dpu_dbg_tlb_bkpt_wpt_en),
    .apb_wr_wcr_i               (apb_wr_wcr0),
    .apb_wr_wvr_i               (apb_wr_wvr0),
    .apb_wr_wvr_high_i          (apb_wr_wvr0_high),
    .cp14_wr_wcr_i              (cp14_wr_wcr0),
    .cp14_wr_wvr_i              (cp14_wr_wvr0),
    .cp14_wr_wvr_high_i         (cp14_wr_wvr0_high),
    .dpu_dbg_wdata_i            (dpu_dbg_wdata_i[31:0]),
    .dpu_ns_state_i             (dpu_ns_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i          (dpu_current_a64_i),
    .dcu_cp_reg_data_i          (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i          (dcu_cp_reg_size_i),
    .dpu_va_dc1_i               (dpu_va_dc1_i[48:3]),
    .dcu_priv_dc1_i             (dcu_priv_dc1_i),
    .dcu_store_dc1_i            (dcu_store_dc1_i),
    .dcu_wpt_check_512_dc1_i    (dcu_wpt_check_512_dc1_i),
    .cid_vmid_linked_hit_i      (cid_vmid_linked_hit),
    .wcr_o                      (wcr0[31:0]),
    .wvr_o                      (wvr0[31:0]),
    .wvr_high_o                 (wvr0_high[31:0]),
    .wrp_hit_o                  (wrp_hit0[15:0])
  );

  ca53tlb_dbg_wpt #(.LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_wpt1 (
    .clk                        (clk),
    .clk_cpregs                 (clk_cpregs),
    .dbg_resetn_i               (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i  (dpu_dbg_tlb_bkpt_wpt_en),
    .apb_wr_wcr_i               (apb_wr_wcr1),
    .apb_wr_wvr_i               (apb_wr_wvr1),
    .apb_wr_wvr_high_i          (apb_wr_wvr1_high),
    .cp14_wr_wcr_i              (cp14_wr_wcr1),
    .cp14_wr_wvr_i              (cp14_wr_wvr1),
    .cp14_wr_wvr_high_i         (cp14_wr_wvr1_high),
    .dpu_dbg_wdata_i            (dpu_dbg_wdata_i[31:0]),
    .dpu_ns_state_i             (dpu_ns_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i          (dpu_current_a64_i),
    .dcu_cp_reg_data_i          (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i          (dcu_cp_reg_size_i),
    .dpu_va_dc1_i               (dpu_va_dc1_i[48:3]),
    .dcu_priv_dc1_i             (dcu_priv_dc1_i),
    .dcu_store_dc1_i            (dcu_store_dc1_i),
    .dcu_wpt_check_512_dc1_i    (dcu_wpt_check_512_dc1_i),
    .cid_vmid_linked_hit_i      (cid_vmid_linked_hit),
    .wcr_o                      (wcr1[31:0]),
    .wvr_o                      (wvr1[31:0]),
    .wvr_high_o                 (wvr1_high[31:0]),
    .wrp_hit_o                  (wrp_hit1[15:0])
  );

  ca53tlb_dbg_wpt #(.LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_wpt2 (
    .clk                        (clk),
    .clk_cpregs                 (clk_cpregs),
    .dbg_resetn_i               (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i  (dpu_dbg_tlb_bkpt_wpt_en),
    .apb_wr_wcr_i               (apb_wr_wcr2),
    .apb_wr_wvr_i               (apb_wr_wvr2),
    .apb_wr_wvr_high_i          (apb_wr_wvr2_high),
    .cp14_wr_wcr_i              (cp14_wr_wcr2),
    .cp14_wr_wvr_i              (cp14_wr_wvr2),
    .cp14_wr_wvr_high_i         (cp14_wr_wvr2_high),
    .dpu_dbg_wdata_i            (dpu_dbg_wdata_i[31:0]),
    .dpu_ns_state_i             (dpu_ns_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i          (dpu_current_a64_i),
    .dcu_cp_reg_data_i          (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i          (dcu_cp_reg_size_i),
    .dpu_va_dc1_i               (dpu_va_dc1_i[48:3]),
    .dcu_priv_dc1_i             (dcu_priv_dc1_i),
    .dcu_store_dc1_i            (dcu_store_dc1_i),
    .dcu_wpt_check_512_dc1_i    (dcu_wpt_check_512_dc1_i),
    .cid_vmid_linked_hit_i      (cid_vmid_linked_hit),
    .wcr_o                      (wcr2[31:0]),
    .wvr_o                      (wvr2[31:0]),
    .wvr_high_o                 (wvr2_high[31:0]),
    .wrp_hit_o                  (wrp_hit2[15:0])
  );

  ca53tlb_dbg_wpt #(.LINK_BRP_NUM(LINK_BRP_NUM)) u_tlb_wpt3 (
    .clk                        (clk),
    .clk_cpregs                 (clk_cpregs),
    .dbg_resetn_i               (dbg_resetn_i),
    .dpu_dbg_tlb_bkpt_wpt_en_i  (dpu_dbg_tlb_bkpt_wpt_en),
    .apb_wr_wcr_i               (apb_wr_wcr3),
    .apb_wr_wvr_i               (apb_wr_wvr3),
    .apb_wr_wvr_high_i          (apb_wr_wvr3_high),
    .cp14_wr_wcr_i              (cp14_wr_wcr3),
    .cp14_wr_wvr_i              (cp14_wr_wvr3),
    .cp14_wr_wvr_high_i         (cp14_wr_wvr3_high),
    .dpu_dbg_wdata_i            (dpu_dbg_wdata_i[31:0]),
    .dpu_ns_state_i             (dpu_ns_state_i),
    .dpu_exception_level_i      (dpu_exception_level_i[1:0]),
    .dpu_aarch64_at_el_i        (dpu_aarch64_at_el_i[3:1]),
    .dpu_current_a64_i          (dpu_current_a64_i),
    .dcu_cp_reg_data_i          (dcu_cp_reg_data_i[48:0]),
    .dcu_cp_reg_size_i          (dcu_cp_reg_size_i),
    .dpu_va_dc1_i               (dpu_va_dc1_i[48:3]),
    .dcu_priv_dc1_i             (dcu_priv_dc1_i),
    .dcu_store_dc1_i            (dcu_store_dc1_i),
    .dcu_wpt_check_512_dc1_i    (dcu_wpt_check_512_dc1_i),
    .cid_vmid_linked_hit_i      (cid_vmid_linked_hit),
    .wcr_o                      (wcr3[31:0]),
    .wvr_o                      (wvr3[31:0]),
    .wvr_high_o                 (wvr3_high[31:0]),
    .wrp_hit_o                  (wrp_hit3[15:0])
  );

  assign tlb_wpt_hit_dc1_o = (wrp_hit0 |
                              wrp_hit1 |
                              wrp_hit2 |
                              wrp_hit3);

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_dbg_sample_contextid_i")
  u_ovl_x_dpu_dbg_sample_contextid_i (.clk       (clk),
                                      .reset_n   (dbg_resetn_i),
                                      .qualifier (1'b1),
                                      .test_expr (dpu_dbg_sample_contextid_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp14_wr_vcr")
  u_ovl_x_cp14_wr_vcr (.clk       (clk),
                       .reset_n   (dbg_resetn_i),
                       .qualifier (1'b1),
                       .test_expr (cp14_wr_vcr));

`endif

endmodule // ca53tlb_dbg

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
