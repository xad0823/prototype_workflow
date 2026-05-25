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
// Description:
//  The tag control pipeline serialises accesses before allowing them to read
//  or write the tag RAMs, and then allocates the request to an AFB ready for
//  forwarding on to the master, L2 data RAMs, or snooping CPUs.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_scu_dcu_defs.v"
`include "cortexa53params.v"

// For snoop lookups, the line must be shareable outside of the cluster for the
// snoop to hit.
`define CA53_SCU_TAG_VALID(tag1, tag0, valid_ctl) ((valid_ctl[0] & tag0 & tag1) | (valid_ctl[1] & tag1) | (valid_ctl[2] & tag0))


module ca53scu_tagctl #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                                     CLKIN,
  input  wire                                     clk,
  input  wire                                     reset_n,
  input  wire                                     DFTSE,
  input  wire                                     DFTRAMHOLD,

  input  wire                                     gov_l2teien_i,

  output wire                                     tagctl_active_o,
  output wire                                     tagctl_master_active_o,
  output wire                                     tagctl_ramctl_active_o,

  // Tag RAM interface
  input  wire [`CA53_L1DC_SIZE_W-1:0]             config_l1_dc_size_i,
  input  wire [`CA53_L2_SIZE_W-1:0]               config_l2_size_i,

  output wire                                     l1d_tagram_clken_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu0_en_o,
  output wire                                     l1d_tagram_cpu0_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu0_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu1_en_o,
  output wire                                     l1d_tagram_cpu1_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu1_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu2_en_o,
  output wire                                     l1d_tagram_cpu2_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu2_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_wdata_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]           l1d_tagram_cpu3_en_o,
  output wire                                     l1d_tagram_cpu3_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]   l1d_tagram_cpu3_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_wdata_o,
  output wire                                     l2_tagram_clken_o,
  output wire [`CA53_SCU_L2_ASSOC-1:0]            l2_tagram_en_o,
  output wire                                     l2_tagram_wr_o,
  output wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]    l2_tagram_addr_o,
  output wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_wdata_o,

  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu0_way3_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu1_way3_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu2_way3_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]   l1d_tagram_cpu3_way3_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way0_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way1_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way2_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way3_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way4_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way5_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way6_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way7_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way8_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way9_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way10_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way11_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way12_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way13_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way14_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]    l2_tagram_way15_rdata_i,

  input  wire                                     leaving_reset_i,
  input  wire                                     config_l2rstdisable_i,
  input  wire                                     config_broadcastinner_i,
  input  wire                                     config_broadcastouter_i,
  input  wire                                     config_broadcastcachemaint_i,
  input  wire                                     gov_disable_evict_i,
  input  wire                                     gov_enable_writeevict_i,
  input  wire                                     gov_l2_in_retention_i,
  input  wire                                     gov_cpu0_smp_en_i,
  input  wire                                     gov_cpu1_smp_en_i,
  input  wire                                     gov_cpu2_smp_en_i,
  input  wire                                     gov_cpu3_smp_en_i,
  input  wire                                     cpuslv0_wfx_active_i,
  input  wire                                     cpuslv1_wfx_active_i,
  input  wire                                     cpuslv2_wfx_active_i,
  input  wire                                     cpuslv3_wfx_active_i,
  input  wire                                     cpuslv0_active_i,
  input  wire                                     cpuslv1_active_i,
  input  wire                                     cpuslv2_active_i,
  input  wire                                     cpuslv3_active_i,
  input  wire                                     acpslv_active_i,
  input  wire                                     snpslv_active_i,
  input  wire                                     l2_reached_retention_i,
  output wire [3:0]                               tagctl_wfx_ready_o,

  // cpuslv requests
  input  wire                                     cpuslv0_tagctl_valid_tc0_i,
  input  wire                                     cpuslv0_tagctl_early_valid_tc0_i,
  input  wire                                     cpuslv0_tagctl_spec_valid_tc0_i,
  output wire                                     tagctl_cpuslv0_ready_tc0_o,
  input  wire [2:0]                               cpuslv0_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               cpuslv0_tagctl_pass_tc0_i,
  input  wire [40:0]                              cpuslv0_tagctl_addr1_tc0_i,
  input  wire                                     cpuslv0_tagctl_dvm_sync_tc0_i,
  input  wire [16:0]                              cpuslv0_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              cpuslv0_tagctl_ecc_tc0_i,
  input  wire [31:0]                              cpuslv0_tagctl_ways_tc0_i,
  input  wire [4:0]                               cpuslv0_tagctl_write_tc0_i,
  input  wire [4:0]                               cpuslv0_tagctl_type_tc0_i,
  input  wire                                     cpuslv0_tagctl_l2flushreq_tc0_i,
  input  wire                                     cpuslv0_tagctl_reqbuf_dcu_tc1_i,
  input  wire [40:0]                              cpuslv0_tagctl_addr2_tc1_i,
  input  wire [1:0]                               cpuslv0_tagctl_len_tc1_i,
  input  wire [2:0]                               cpuslv0_tagctl_size_tc1_i,
  input  wire                                     cpuslv0_tagctl_lock_tc1_i,
  input  wire                                     cpuslv0_tagctl_dirty_tc1_i,
  input  wire                                     cpuslv0_tagctl_cluster_unique_tc1_i,
  input  wire [7:0]                               cpuslv0_tagctl_attrs_tc1_i,
  input  wire [1:0]                               cpuslv0_tagctl_prot_tc1_i,
  input  wire [3:0]                               cpuslv0_tagctl_l2db_tc1_i,
  input  wire                                     cpuslv0_tagctl_l2db_full_tc1_i,
  input  wire                                     cpuslv0_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               cpuslv0_tagctl_pcrdtype_tc1_i,
  input  wire [3:0]                               cpuslv0_tagctl_victim_way_tc1_i,
  output wire                                     tagctl_cpuslv0_noncoh_only_o,
  input  wire                                     cpuslv0_inv_all_starting_i,

  input  wire                                     cpuslv1_tagctl_valid_tc0_i,
  input  wire                                     cpuslv1_tagctl_early_valid_tc0_i,
  input  wire                                     cpuslv1_tagctl_spec_valid_tc0_i,
  output wire                                     tagctl_cpuslv1_ready_tc0_o,
  input  wire [2:0]                               cpuslv1_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               cpuslv1_tagctl_pass_tc0_i,
  input  wire [40:0]                              cpuslv1_tagctl_addr1_tc0_i,
  input  wire                                     cpuslv1_tagctl_dvm_sync_tc0_i,
  input  wire [16:0]                              cpuslv1_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              cpuslv1_tagctl_ecc_tc0_i,
  input  wire [31:0]                              cpuslv1_tagctl_ways_tc0_i,
  input  wire [4:0]                               cpuslv1_tagctl_write_tc0_i,
  input  wire [4:0]                               cpuslv1_tagctl_type_tc0_i,
  input  wire                                     cpuslv1_tagctl_l2flushreq_tc0_i,
  input  wire                                     cpuslv1_tagctl_reqbuf_dcu_tc1_i,
  input  wire [40:0]                              cpuslv1_tagctl_addr2_tc1_i,
  input  wire [1:0]                               cpuslv1_tagctl_len_tc1_i,
  input  wire [2:0]                               cpuslv1_tagctl_size_tc1_i,
  input  wire                                     cpuslv1_tagctl_lock_tc1_i,
  input  wire                                     cpuslv1_tagctl_dirty_tc1_i,
  input  wire                                     cpuslv1_tagctl_cluster_unique_tc1_i,
  input  wire [7:0]                               cpuslv1_tagctl_attrs_tc1_i,
  input  wire [1:0]                               cpuslv1_tagctl_prot_tc1_i,
  input  wire [3:0]                               cpuslv1_tagctl_l2db_tc1_i,
  input  wire                                     cpuslv1_tagctl_l2db_full_tc1_i,
  input  wire                                     cpuslv1_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               cpuslv1_tagctl_pcrdtype_tc1_i,
  input  wire [3:0]                               cpuslv1_tagctl_victim_way_tc1_i,
  output wire                                     tagctl_cpuslv1_noncoh_only_o,
  input  wire                                     cpuslv1_inv_all_starting_i,

  input  wire                                     cpuslv2_tagctl_valid_tc0_i,
  input  wire                                     cpuslv2_tagctl_early_valid_tc0_i,
  input  wire                                     cpuslv2_tagctl_spec_valid_tc0_i,
  output wire                                     tagctl_cpuslv2_ready_tc0_o,
  input  wire [2:0]                               cpuslv2_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               cpuslv2_tagctl_pass_tc0_i,
  input  wire [40:0]                              cpuslv2_tagctl_addr1_tc0_i,
  input  wire                                     cpuslv2_tagctl_dvm_sync_tc0_i,
  input  wire [16:0]                              cpuslv2_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              cpuslv2_tagctl_ecc_tc0_i,
  input  wire [31:0]                              cpuslv2_tagctl_ways_tc0_i,
  input  wire [4:0]                               cpuslv2_tagctl_write_tc0_i,
  input  wire [4:0]                               cpuslv2_tagctl_type_tc0_i,
  input  wire                                     cpuslv2_tagctl_l2flushreq_tc0_i,
  input  wire                                     cpuslv2_tagctl_reqbuf_dcu_tc1_i,
  input  wire [40:0]                              cpuslv2_tagctl_addr2_tc1_i,
  input  wire [1:0]                               cpuslv2_tagctl_len_tc1_i,
  input  wire [2:0]                               cpuslv2_tagctl_size_tc1_i,
  input  wire                                     cpuslv2_tagctl_lock_tc1_i,
  input  wire                                     cpuslv2_tagctl_dirty_tc1_i,
  input  wire                                     cpuslv2_tagctl_cluster_unique_tc1_i,
  input  wire [7:0]                               cpuslv2_tagctl_attrs_tc1_i,
  input  wire [1:0]                               cpuslv2_tagctl_prot_tc1_i,
  input  wire [3:0]                               cpuslv2_tagctl_l2db_tc1_i,
  input  wire                                     cpuslv2_tagctl_l2db_full_tc1_i,
  input  wire                                     cpuslv2_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               cpuslv2_tagctl_pcrdtype_tc1_i,
  input  wire [3:0]                               cpuslv2_tagctl_victim_way_tc1_i,
  output wire                                     tagctl_cpuslv2_noncoh_only_o,
  input  wire                                     cpuslv2_inv_all_starting_i,

  input  wire                                     cpuslv3_tagctl_valid_tc0_i,
  input  wire                                     cpuslv3_tagctl_early_valid_tc0_i,
  input  wire                                     cpuslv3_tagctl_spec_valid_tc0_i,
  output wire                                     tagctl_cpuslv3_ready_tc0_o,
  input  wire [2:0]                               cpuslv3_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               cpuslv3_tagctl_pass_tc0_i,
  input  wire [40:0]                              cpuslv3_tagctl_addr1_tc0_i,
  input  wire                                     cpuslv3_tagctl_dvm_sync_tc0_i,
  input  wire [16:0]                              cpuslv3_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              cpuslv3_tagctl_ecc_tc0_i,
  input  wire [31:0]                              cpuslv3_tagctl_ways_tc0_i,
  input  wire [4:0]                               cpuslv3_tagctl_write_tc0_i,
  input  wire [4:0]                               cpuslv3_tagctl_type_tc0_i,
  input  wire                                     cpuslv3_tagctl_l2flushreq_tc0_i,
  input  wire                                     cpuslv3_tagctl_reqbuf_dcu_tc1_i,
  input  wire [40:0]                              cpuslv3_tagctl_addr2_tc1_i,
  input  wire [1:0]                               cpuslv3_tagctl_len_tc1_i,
  input  wire [2:0]                               cpuslv3_tagctl_size_tc1_i,
  input  wire                                     cpuslv3_tagctl_lock_tc1_i,
  input  wire                                     cpuslv3_tagctl_dirty_tc1_i,
  input  wire                                     cpuslv3_tagctl_cluster_unique_tc1_i,
  input  wire [7:0]                               cpuslv3_tagctl_attrs_tc1_i,
  input  wire [1:0]                               cpuslv3_tagctl_prot_tc1_i,
  input  wire [3:0]                               cpuslv3_tagctl_l2db_tc1_i,
  input  wire                                     cpuslv3_tagctl_l2db_full_tc1_i,
  input  wire                                     cpuslv3_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               cpuslv3_tagctl_pcrdtype_tc1_i,
  input  wire [3:0]                               cpuslv3_tagctl_victim_way_tc1_i,
  output wire                                     tagctl_cpuslv3_noncoh_only_o,
  input  wire                                     cpuslv3_inv_all_starting_i,

  input  wire                                     acpslv_tagctl_valid_tc0_i,
  input  wire                                     acpslv_tagctl_early_valid_tc0_i,
  input  wire                                     acpslv_tagctl_spec_valid_tc0_i,
  input  wire                                     acpslv_tagctl_active_tc0_i,
  output wire                                     tagctl_acpslv_ready_tc0_o,
  input  wire [2:0]                               acpslv_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               acpslv_tagctl_pass_tc0_i,
  input  wire [40:0]                              acpslv_tagctl_addr1_tc0_i,
  input  wire [16:0]                              acpslv_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              acpslv_tagctl_ecc_tc0_i,
  input  wire [31:0]                              acpslv_tagctl_ways_tc0_i,
  input  wire [4:0]                               acpslv_tagctl_write_tc0_i,
  input  wire [4:0]                               acpslv_tagctl_type_tc0_i,
  input  wire [1:0]                               acpslv_tagctl_len_tc1_i,
  input  wire                                     acpslv_tagctl_single_tc1_i,
  input  wire [2:0]                               acpslv_tagctl_size_tc1_i,
  input  wire                                     acpslv_tagctl_dirty_tc1_i,
  input  wire                                     acpslv_tagctl_cluster_unique_tc1_i,
  input  wire [7:0]                               acpslv_tagctl_attrs_tc1_i,
  input  wire [1:0]                               acpslv_tagctl_prot_tc1_i,
  input  wire [3:0]                               acpslv_tagctl_l2db_tc1_i,
  input  wire                                     acpslv_tagctl_l2db_full_tc1_i,
  input  wire                                     acpslv_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               acpslv_tagctl_pcrdtype_tc1_i,
  input  wire [3:0]                               acpslv_tagctl_victim_way_tc1_i,
  input  wire                                     acpslv_tagctl_slverr_tc1_i,
  output wire                                     tagctl_acpslv_noncoh_only_o,

  input  wire                                     snpslv_tagctl_valid_tc0_i,
  input  wire                                     snpslv_tagctl_early_valid_tc0_i,
  input  wire                                     snpslv_tagctl_spec_valid_tc0_i,
  input  wire                                     snpslv_tagctl_active_tc0_i,
  output wire                                     tagctl_snpslv_ready_tc0_o,
  input  wire [2:0]                               snpslv_tagctl_reqbufid_tc0_i,
  input  wire [3:0]                               snpslv_tagctl_pass_tc0_i,
  input  wire [41:0]                              snpslv_tagctl_addr1_tc0_i,
  input  wire                                     snpslv_tagctl_dvm_sync_tc0_i,
  input  wire [16:0]                              snpslv_tagctl_wr_state_tc0_i,
  input  wire [34:0]                              snpslv_tagctl_ecc_tc0_i,
  input  wire [31:0]                              snpslv_tagctl_ways_tc0_i,
  input  wire [4:0]                               snpslv_tagctl_write_tc0_i,
  input  wire [4:0]                               snpslv_tagctl_type_tc0_i,
  input  wire [40:0]                              snpslv_tagctl_addr2_tc1_i,
  input  wire [7:0]                               snpslv_tagctl_attrs_tc1_i,
  input  wire                                     snpslv_tagctl_dirty_tc1_i,
  input  wire                                     snpslv_tagctl_cluster_unique_tc1_i,
  input  wire [3:0]                               snpslv_tagctl_l2db_tc1_i,
  input  wire                                     snpslv_tagctl_static_pcredit_tc1_i,
  input  wire [1:0]                               snpslv_tagctl_pcrdtype_tc1_i,

  output wire [3:0]                               tagctl_slv_l2db_tc1_o,
  output wire                                     tagctl_slv_l2db_hit_tc3_o,
  output wire                                     tagctl_slv_l2db_dirty_tc3_o,
  output wire                                     tagctl_slv_l2db_cu_tc3_o,
  output wire [3:0]                               tagctl_slv_l2db_tc4_o,
  output wire [3:0]                               tagctl_slv_l2db_tc3_o,
  output wire [3:0]                               tagctl_slv_victim_l2db_tc4_o,
  output wire                                     tagctl_slv_snp_hz_tc4_o,
  output wire [4:0]                               tagctl_slv_snp_hz_id_tc4_o,
  output wire                                     tagctl_slv_l2db_invalidated_tc4_o,
  output wire                                     tagctl_slv_l2db_cleaned_tc4_o,

  output wire [15:0]                              tagctl_l1_hit_ways_tc3_o,
  output wire [15:0]                              tagctl_l2_hit_ways_tc3_o,
  output wire                                     tagctl_l2_dirty_tc3_o,
  output wire                                     tagctl_l2_alloc_tc3_o,
  output wire [1:0]                               tagctl_shareability_tc3_o,
  output wire                                     tagctl_cluster_unique_tc3_o,
  output wire                                     tagctl_l1_victim_cluster_unique_tc3_o,
  output wire [1:0]                               tagctl_l1_victim_shareability_tc3_o,
  output wire                                     tagctl_l2_victim_valid_tc3_o,
  output wire                                     tagctl_l2_victim_dirty_tc3_o,
  output wire [1:0]                               tagctl_l2_victim_shareability_tc3_o,
  output wire                                     tagctl_l2_victim_alloc_tc3_o,
  output wire                                     tagctl_l2_victim_cu_tc3_o,
  output wire [3:0]                               tagctl_l2_victim_way_tc3_o,
  output wire [1:0]                               tagctl_snoop_data_cpu_tc4_o,

  output wire                                     tagctl_slv_flush_tc1_o,
  output wire                                     tagctl_slv_flush_tc2_o,
  output wire                                     tagctl_slv_flush_tc3_o,
  output wire                                     tagctl_slv_flush_tc4_o,
  output wire                                     tagctl_slv_early_flush_tc4_o,

  output wire                                     tagctl_ecc_err_tc3_o,

  output wire                                     afb0_done_o,
  output wire                                     afb1_done_o,
  output wire                                     afb2_done_o,
  output wire                                     afb3_done_o,
  output wire                                     afb4_done_o,
  output wire                                     afb5_done_o,
  output wire                                     afb0_snoop_resp_valid_o,
  output wire                                     afb1_snoop_resp_valid_o,
  output wire                                     afb2_snoop_resp_valid_o,
  output wire                                     afb3_snoop_resp_valid_o,
  output wire                                     afb4_snoop_resp_valid_o,
  output wire                                     afb5_snoop_resp_valid_o,
  output wire                                     afb0_snoop_resp_dirty_o,
  output wire                                     afb1_snoop_resp_dirty_o,
  output wire                                     afb2_snoop_resp_dirty_o,
  output wire                                     afb3_snoop_resp_dirty_o,
  output wire                                     afb4_snoop_resp_dirty_o,
  output wire                                     afb5_snoop_resp_dirty_o,
  output wire                                     afb0_snoop_resp_alloc_o,
  output wire                                     afb1_snoop_resp_alloc_o,
  output wire                                     afb2_snoop_resp_alloc_o,
  output wire                                     afb3_snoop_resp_alloc_o,
  output wire                                     afb4_snoop_resp_alloc_o,
  output wire                                     afb5_snoop_resp_alloc_o,
  output wire                                     afb0_snoop_resp_migratory_o,
  output wire                                     afb1_snoop_resp_migratory_o,
  output wire                                     afb2_snoop_resp_migratory_o,
  output wire                                     afb3_snoop_resp_migratory_o,
  output wire                                     afb4_snoop_resp_migratory_o,
  output wire                                     afb5_snoop_resp_migratory_o,
  output wire                                     afb0_snoop_resp_victim_valid_o,
  output wire                                     afb1_snoop_resp_victim_valid_o,
  output wire                                     afb2_snoop_resp_victim_valid_o,
  output wire                                     afb3_snoop_resp_victim_valid_o,
  output wire                                     afb4_snoop_resp_victim_valid_o,
  output wire                                     afb5_snoop_resp_victim_valid_o,
  output wire                                     afb0_snoop_resp_victim_dirty_o,
  output wire                                     afb1_snoop_resp_victim_dirty_o,
  output wire                                     afb2_snoop_resp_victim_dirty_o,
  output wire                                     afb3_snoop_resp_victim_dirty_o,
  output wire                                     afb4_snoop_resp_victim_dirty_o,
  output wire                                     afb5_snoop_resp_victim_dirty_o,
  output wire                                     afb0_snoop_resp_victim_age_o,
  output wire                                     afb1_snoop_resp_victim_age_o,
  output wire                                     afb2_snoop_resp_victim_age_o,
  output wire                                     afb3_snoop_resp_victim_age_o,
  output wire                                     afb4_snoop_resp_victim_age_o,
  output wire                                     afb5_snoop_resp_victim_age_o,
  output wire                                     afb0_snoop_resp_victim_alloc_o,
  output wire                                     afb1_snoop_resp_victim_alloc_o,
  output wire                                     afb2_snoop_resp_victim_alloc_o,
  output wire                                     afb3_snoop_resp_victim_alloc_o,
  output wire                                     afb4_snoop_resp_victim_alloc_o,
  output wire                                     afb5_snoop_resp_victim_alloc_o,
  output wire                                     afb0_write_done_o,
  output wire                                     afb1_write_done_o,
  output wire                                     afb2_write_done_o,
  output wire                                     afb3_write_done_o,
  output wire                                     afb4_write_done_o,
  output wire                                     afb5_write_done_o,
  output wire [2:0]                               tagctl_slv_afb_tc1_o,

  // Hazarding
  output wire [41:6]                              tagctl_addr_tc1_o,
  output wire                                     tagctl_valid_tc1_o,
  output wire                                     tagctl_addr_valid_tc1_o,
  output wire                                     tagctl_index_valid_tc1_o,
  output wire                                     tagctl_l1_set_way_op_tc1_o,
  output wire                                     tagctl_l1_lf_tc1_o,
  output wire                                     tagctl_serialising_tc1_o,
  output wire                                     tagctl_ecc_wr_tc1_o,
  output wire [15:0]                              tagctl_ecc_way_tc1_o,
  output wire                                     tagctl_snp_sync_tc1_o,
  output wire                                     tagctl_cpu_sync_tc1_o,
  output wire [5:0]                               tagctl_reqbufid_tc1_o,
  output wire                                     tagctl_mn_op_tc2_o,
  output wire [39:6]                              tagctl_sam_addr_tc2_o,
  input  wire                                     cpuslv0_hz_tc2_i,
  input  wire                                     cpuslv1_hz_tc2_i,
  input  wire                                     cpuslv2_hz_tc2_i,
  input  wire                                     cpuslv3_hz_tc2_i,
  input  wire                                     acpslv_hz_tc2_i,
  input  wire                                     snpslv_hz_tc2_i,
  input  wire                                     master_hz_tc2_i,
  input  wire                                     master_hz_dev_tc2_i,
  input  wire                                     master_hz_l2db_tc2_i,
  input  wire                                     master_hz_dirty_tc2_i,
  input  wire                                     master_hz_cu_tc2_i,
  input  wire [3:0]                               master_l2db_tc2_i,
  input  wire [6:0]                               sam_tgtid_tc2_i,
  input  wire                                     cpuslv0_snp_hz_tc2_i,
  input  wire                                     cpuslv1_snp_hz_tc2_i,
  input  wire                                     cpuslv2_snp_hz_tc2_i,
  input  wire                                     cpuslv3_snp_hz_tc2_i,
  input  wire [2:0]                               cpuslv0_snp_hz_id_tc2_i,
  input  wire [2:0]                               cpuslv1_snp_hz_id_tc2_i,
  input  wire [2:0]                               cpuslv2_snp_hz_id_tc2_i,
  input  wire [2:0]                               cpuslv3_snp_hz_id_tc2_i,
  input  wire                                     cpuslv0_snp_l2db_hz_tc2_i,
  input  wire                                     cpuslv1_snp_l2db_hz_tc2_i,
  input  wire                                     cpuslv2_snp_l2db_hz_tc2_i,
  input  wire                                     cpuslv3_snp_l2db_hz_tc2_i,
  input  wire                                     cpuslv0_snp_l2db_dirty_tc2_i,
  input  wire                                     cpuslv1_snp_l2db_dirty_tc2_i,
  input  wire                                     cpuslv2_snp_l2db_dirty_tc2_i,
  input  wire                                     cpuslv3_snp_l2db_dirty_tc2_i,
  input  wire [3:0]                               cpuslv0_snp_l2db_tc2_i,
  input  wire [3:0]                               cpuslv1_snp_l2db_tc2_i,
  input  wire [3:0]                               cpuslv2_snp_l2db_tc2_i,
  input  wire [3:0]                               cpuslv3_snp_l2db_tc2_i,
  input  wire                                     cpuslv0_ecc_hz_tc2_i,
  input  wire                                     cpuslv1_ecc_hz_tc2_i,
  input  wire                                     cpuslv2_ecc_hz_tc2_i,
  input  wire                                     cpuslv3_ecc_hz_tc2_i,
  input  wire                                     snpslv_ecc_hz_tc2_i,
  input  wire [31:0]                              cpuslv0_force_miss_tc2_i,
  input  wire [31:0]                              cpuslv1_force_miss_tc2_i,
  input  wire [31:0]                              cpuslv2_force_miss_tc2_i,
  input  wire [31:0]                              cpuslv3_force_miss_tc2_i,
  input  wire [15:0]                              acpslv_force_miss_tc2_i,
  input  wire [15:0]                              cpuslv0_l2_way_used_tc2_i,
  input  wire [15:0]                              cpuslv1_l2_way_used_tc2_i,
  input  wire [15:0]                              cpuslv2_l2_way_used_tc2_i,
  input  wire [15:0]                              cpuslv3_l2_way_used_tc2_i,
  input  wire [15:0]                              acpslv_l2_way_used_tc2_i,
  input  wire [15:0]                              snpslv_l2_way_used_tc2_i,
  output wire [40:6]                              tagctl_addr_tc3_o,
  output wire                                     tagctl_addr_valid_tc3_o,
  output wire [5:0]                               tagctl_reqbufid_tc3_o,
  output wire                                     tagctl_noncoh_serialised_tc3_o,
  input  wire                                     cpuslv0_hz_tc4_i,
  input  wire                                     cpuslv1_hz_tc4_i,
  input  wire                                     cpuslv2_hz_tc4_i,
  input  wire                                     cpuslv3_hz_tc4_i,
  input  wire                                     acpslv_hz_tc4_i,
  input  wire                                     snpslv_hz_tc4_i,
  input  wire                                     master_hz_tc4_i,
  input  wire                                     master_ncoh_db_i,
  input  wire [3:0]                               master_hz_waddr_tc4_i,
  input  wire [15:0]                              master_waddr_valid_i,

  // Snoops to CPUs
  output wire                                     tagctl_cpuslv0_ac_valid_o,
  input  wire                                     cpuslv0_ac_ready_i,
  output wire [3:0]                               tagctl_cpuslv0_ac_snoop_o,
  output wire [2:0]                               tagctl_cpuslv0_ac_id_o,
  output wire [3:0]                               tagctl_cpuslv0_ac_l2db_id_o,
  output wire [40:0]                              tagctl_cpuslv0_ac_addr_o,
  output wire [3:0]                               tagctl_cpuslv0_ac_way_o,
  input  wire                                     cpuslv0_cr_valid_i,
  input  wire [2:0]                               cpuslv0_cr_id_i,
  input  wire                                     cpuslv0_cr_dirty_i,
  input  wire                                     cpuslv0_cr_age_i,
  input  wire                                     cpuslv0_cr_alloc_i,
  input  wire                                     cpuslv0_cr_migratory_i,

  output wire                                     tagctl_cpuslv1_ac_valid_o,
  input  wire                                     cpuslv1_ac_ready_i,
  output wire [3:0]                               tagctl_cpuslv1_ac_snoop_o,
  output wire [2:0]                               tagctl_cpuslv1_ac_id_o,
  output wire [3:0]                               tagctl_cpuslv1_ac_l2db_id_o,
  output wire [40:0]                              tagctl_cpuslv1_ac_addr_o,
  output wire [3:0]                               tagctl_cpuslv1_ac_way_o,
  input  wire                                     cpuslv1_cr_valid_i,
  input  wire [2:0]                               cpuslv1_cr_id_i,
  input  wire                                     cpuslv1_cr_dirty_i,
  input  wire                                     cpuslv1_cr_age_i,
  input  wire                                     cpuslv1_cr_alloc_i,
  input  wire                                     cpuslv1_cr_migratory_i,

  output wire                                     tagctl_cpuslv2_ac_valid_o,
  input  wire                                     cpuslv2_ac_ready_i,
  output wire [3:0]                               tagctl_cpuslv2_ac_snoop_o,
  output wire [2:0]                               tagctl_cpuslv2_ac_id_o,
  output wire [3:0]                               tagctl_cpuslv2_ac_l2db_id_o,
  output wire [40:0]                              tagctl_cpuslv2_ac_addr_o,
  output wire [3:0]                               tagctl_cpuslv2_ac_way_o,
  input  wire                                     cpuslv2_cr_valid_i,
  input  wire [2:0]                               cpuslv2_cr_id_i,
  input  wire                                     cpuslv2_cr_dirty_i,
  input  wire                                     cpuslv2_cr_age_i,
  input  wire                                     cpuslv2_cr_alloc_i,
  input  wire                                     cpuslv2_cr_migratory_i,

  output wire                                     tagctl_cpuslv3_ac_valid_o,
  input  wire                                     cpuslv3_ac_ready_i,
  output wire [3:0]                               tagctl_cpuslv3_ac_snoop_o,
  output wire [2:0]                               tagctl_cpuslv3_ac_id_o,
  output wire [3:0]                               tagctl_cpuslv3_ac_l2db_id_o,
  output wire [40:0]                              tagctl_cpuslv3_ac_addr_o,
  output wire [3:0]                               tagctl_cpuslv3_ac_way_o,
  input  wire                                     cpuslv3_cr_valid_i,
  input  wire [2:0]                               cpuslv3_cr_id_i,
  input  wire                                     cpuslv3_cr_dirty_i,
  input  wire                                     cpuslv3_cr_age_i,
  input  wire                                     cpuslv3_cr_alloc_i,
  input  wire                                     cpuslv3_cr_migratory_i,

  output wire                                     tagctl_cpuslv0_snp_active_o,
  output wire                                     tagctl_cpuslv1_snp_active_o,
  output wire                                     tagctl_cpuslv2_snp_active_o,
  output wire                                     tagctl_cpuslv3_snp_active_o,

  // Master address requests
  output wire                                     afb0_master_req_o,
  output wire                                     afb0_master_flush_o,
  output wire [6:0]                               afb0_master_id_o,
  output wire [40:0]                              afb0_master_addr_o,
  output wire [4:0]                               afb0_master_opcode_o,
  output wire [1:0]                               afb0_master_len_o,
  output wire [2:0]                               afb0_master_size_o,
  output wire                                     afb0_master_lock_o,
  output wire [7:0]                               afb0_master_attrs_o,
  output wire [1:0]                               afb0_master_prot_o,
  output wire [6:0]                               afb0_master_tgtid_o,
  output wire [3:0]                               afb0_master_l2db_o,
  output wire                                     afb0_master_static_pcredit_o,
  output wire [1:0]                               afb0_master_pcrdtype_o,
  input  wire                                     master_afb0_ack_i,

  output wire                                     afb1_master_req_o,
  output wire                                     afb1_master_flush_o,
  output wire [6:0]                               afb1_master_id_o,
  output wire [40:0]                              afb1_master_addr_o,
  output wire [4:0]                               afb1_master_opcode_o,
  output wire [1:0]                               afb1_master_len_o,
  output wire [2:0]                               afb1_master_size_o,
  output wire                                     afb1_master_lock_o,
  output wire [7:0]                               afb1_master_attrs_o,
  output wire [1:0]                               afb1_master_prot_o,
  output wire [6:0]                               afb1_master_tgtid_o,
  output wire [3:0]                               afb1_master_l2db_o,
  output wire                                     afb1_master_static_pcredit_o,
  output wire [1:0]                               afb1_master_pcrdtype_o,
  input  wire                                     master_afb1_ack_i,

  output wire                                     afb2_master_req_o,
  output wire                                     afb2_master_flush_o,
  output wire [6:0]                               afb2_master_id_o,
  output wire [40:0]                              afb2_master_addr_o,
  output wire [4:0]                               afb2_master_opcode_o,
  output wire [1:0]                               afb2_master_len_o,
  output wire [2:0]                               afb2_master_size_o,
  output wire                                     afb2_master_lock_o,
  output wire [7:0]                               afb2_master_attrs_o,
  output wire [1:0]                               afb2_master_prot_o,
  output wire [6:0]                               afb2_master_tgtid_o,
  output wire [3:0]                               afb2_master_l2db_o,
  output wire                                     afb2_master_static_pcredit_o,
  output wire [1:0]                               afb2_master_pcrdtype_o,
  input  wire                                     master_afb2_ack_i,

  output wire                                     afb3_master_req_o,
  output wire                                     afb3_master_flush_o,
  output wire [6:0]                               afb3_master_id_o,
  output wire [40:0]                              afb3_master_addr_o,
  output wire [4:0]                               afb3_master_opcode_o,
  output wire [1:0]                               afb3_master_len_o,
  output wire [2:0]                               afb3_master_size_o,
  output wire                                     afb3_master_lock_o,
  output wire [7:0]                               afb3_master_attrs_o,
  output wire [1:0]                               afb3_master_prot_o,
  output wire [6:0]                               afb3_master_tgtid_o,
  output wire [3:0]                               afb3_master_l2db_o,
  output wire                                     afb3_master_static_pcredit_o,
  output wire [1:0]                               afb3_master_pcrdtype_o,
  input  wire                                     master_afb3_ack_i,

  output wire                                     afb4_master_req_o,
  output wire                                     afb4_master_flush_o,
  output wire [6:0]                               afb4_master_id_o,
  output wire [40:0]                              afb4_master_addr_o,
  output wire [4:0]                               afb4_master_opcode_o,
  output wire [1:0]                               afb4_master_len_o,
  output wire [2:0]                               afb4_master_size_o,
  output wire                                     afb4_master_lock_o,
  output wire [7:0]                               afb4_master_attrs_o,
  output wire [1:0]                               afb4_master_prot_o,
  output wire [6:0]                               afb4_master_tgtid_o,
  output wire [3:0]                               afb4_master_l2db_o,
  output wire                                     afb4_master_static_pcredit_o,
  output wire [1:0]                               afb4_master_pcrdtype_o,
  input  wire                                     master_afb4_ack_i,

  output wire                                     afb5_master_req_o,
  output wire                                     afb5_master_flush_o,
  output wire [6:0]                               afb5_master_id_o,
  output wire [40:0]                              afb5_master_addr_o,
  output wire [4:0]                               afb5_master_opcode_o,
  output wire [1:0]                               afb5_master_len_o,
  output wire [2:0]                               afb5_master_size_o,
  output wire                                     afb5_master_lock_o,
  output wire [7:0]                               afb5_master_attrs_o,
  output wire [1:0]                               afb5_master_prot_o,
  output wire [6:0]                               afb5_master_tgtid_o,
  output wire [3:0]                               afb5_master_l2db_o,
  output wire                                     afb5_master_static_pcredit_o,
  output wire [1:0]                               afb5_master_pcrdtype_o,
  input  wire                                     master_afb5_ack_i,

  output wire                                     tagctl_err_valid_o,
  output wire                                     tagctl_err_fatal_o,
  output wire [10:0]                              tagctl_err_index_o,
  output wire [4:0]                               tagctl_err_way_o,

  // L2DB control
  output wire                                     tagctl_alloc_for_snoop_o,
  output wire                                     tagctl_alloc_for_write_o,

  input  wire                                     l2db0_tagctl_available_i,
  input  wire                                     l2db0_tagctl_for_snoop_i,
  input  wire                                     l2db0_tagctl_for_write_i,
  output wire                                     tagctl_l2db0_alloc_o,
  output wire                                     tagctl_l2db0_release_o,
  output wire                                     tagctl_l2db0_snoops_done_o,
  output wire                                     tagctl_l2db0_fill_strbs_o,

  input  wire                                     l2db1_tagctl_available_i,
  input  wire                                     l2db1_tagctl_for_snoop_i,
  input  wire                                     l2db1_tagctl_for_write_i,
  output wire                                     tagctl_l2db1_alloc_o,
  output wire                                     tagctl_l2db1_release_o,
  output wire                                     tagctl_l2db1_snoops_done_o,
  output wire                                     tagctl_l2db1_fill_strbs_o,

  input  wire                                     l2db2_tagctl_available_i,
  input  wire                                     l2db2_tagctl_for_snoop_i,
  input  wire                                     l2db2_tagctl_for_write_i,
  output wire                                     tagctl_l2db2_alloc_o,
  output wire                                     tagctl_l2db2_release_o,
  output wire                                     tagctl_l2db2_snoops_done_o,
  output wire                                     tagctl_l2db2_fill_strbs_o,

  input  wire                                     l2db3_tagctl_available_i,
  input  wire                                     l2db3_tagctl_for_snoop_i,
  input  wire                                     l2db3_tagctl_for_write_i,
  output wire                                     tagctl_l2db3_alloc_o,
  output wire                                     tagctl_l2db3_release_o,
  output wire                                     tagctl_l2db3_snoops_done_o,
  output wire                                     tagctl_l2db3_fill_strbs_o,

  input  wire                                     l2db4_tagctl_available_i,
  input  wire                                     l2db4_tagctl_for_snoop_i,
  input  wire                                     l2db4_tagctl_for_write_i,
  output wire                                     tagctl_l2db4_alloc_o,
  output wire                                     tagctl_l2db4_release_o,
  output wire                                     tagctl_l2db4_snoops_done_o,
  output wire                                     tagctl_l2db4_fill_strbs_o,

  input  wire                                     l2db5_tagctl_available_i,
  input  wire                                     l2db5_tagctl_for_snoop_i,
  input  wire                                     l2db5_tagctl_for_write_i,
  output wire                                     tagctl_l2db5_alloc_o,
  output wire                                     tagctl_l2db5_release_o,
  output wire                                     tagctl_l2db5_snoops_done_o,
  output wire                                     tagctl_l2db5_fill_strbs_o,

  input  wire                                     l2db6_tagctl_available_i,
  input  wire                                     l2db6_tagctl_for_snoop_i,
  input  wire                                     l2db6_tagctl_for_write_i,
  output wire                                     tagctl_l2db6_alloc_o,
  output wire                                     tagctl_l2db6_release_o,
  output wire                                     tagctl_l2db6_snoops_done_o,
  output wire                                     tagctl_l2db6_fill_strbs_o,

  input  wire                                     l2db7_tagctl_available_i,
  input  wire                                     l2db7_tagctl_for_snoop_i,
  input  wire                                     l2db7_tagctl_for_write_i,
  output wire                                     tagctl_l2db7_alloc_o,
  output wire                                     tagctl_l2db7_release_o,
  output wire                                     tagctl_l2db7_snoops_done_o,
  output wire                                     tagctl_l2db7_fill_strbs_o,

  input  wire                                     l2db8_tagctl_available_i,
  input  wire                                     l2db8_tagctl_for_snoop_i,
  input  wire                                     l2db8_tagctl_for_write_i,
  output wire                                     tagctl_l2db8_alloc_o,
  output wire                                     tagctl_l2db8_release_o,
  output wire                                     tagctl_l2db8_snoops_done_o,
  output wire                                     tagctl_l2db8_fill_strbs_o,

  input  wire                                     l2db9_tagctl_available_i,
  input  wire                                     l2db9_tagctl_for_snoop_i,
  input  wire                                     l2db9_tagctl_for_write_i,
  output wire                                     tagctl_l2db9_alloc_o,
  output wire                                     tagctl_l2db9_release_o,
  output wire                                     tagctl_l2db9_snoops_done_o,
  output wire                                     tagctl_l2db9_fill_strbs_o,

  input  wire                                     l2db10_tagctl_available_i,
  input  wire                                     l2db10_tagctl_for_snoop_i,
  input  wire                                     l2db10_tagctl_for_write_i,
  output wire                                     tagctl_l2db10_alloc_o,
  output wire                                     tagctl_l2db10_release_o,
  output wire                                     tagctl_l2db10_snoops_done_o,
  output wire                                     tagctl_l2db10_fill_strbs_o,

  output wire                                     afb0_l2dbs_transfer_o,
  output wire [3:0]                               afb0_l2dbs_id_o,
  output wire [23:0]                              afb0_l2dbs_transfer_info_o,

  output wire                                     afb1_l2dbs_transfer_o,
  output wire [3:0]                               afb1_l2dbs_id_o,
  output wire [23:0]                              afb1_l2dbs_transfer_info_o,

  output wire                                     afb2_l2dbs_transfer_o,
  output wire [3:0]                               afb2_l2dbs_id_o,
  output wire [23:0]                              afb2_l2dbs_transfer_info_o,

  output wire                                     afb3_l2dbs_transfer_o,
  output wire [3:0]                               afb3_l2dbs_id_o,
  output wire [23:0]                              afb3_l2dbs_transfer_info_o,

  output wire                                     afb4_l2dbs_transfer_o,
  output wire [3:0]                               afb4_l2dbs_id_o,
  output wire [23:0]                              afb4_l2dbs_transfer_info_o,

  output wire                                     afb5_l2dbs_transfer_o,
  output wire [3:0]                               afb5_l2dbs_id_o,
  output wire [23:0]                              afb5_l2dbs_transfer_info_o,

  input  wire                                     l2db0_slv_done_i,
  input  wire                                     l2db1_slv_done_i,
  input  wire                                     l2db2_slv_done_i,
  input  wire                                     l2db3_slv_done_i,
  input  wire                                     l2db4_slv_done_i,
  input  wire                                     l2db5_slv_done_i,
  input  wire                                     l2db6_slv_done_i,
  input  wire                                     l2db7_slv_done_i,
  input  wire                                     l2db8_slv_done_i,
  input  wire                                     l2db9_slv_done_i,
  input  wire                                     l2db10_slv_done_i,

  input  wire                                     l2db0_rmw_line_i,
  input  wire                                     l2db1_rmw_line_i,
  input  wire                                     l2db2_rmw_line_i,
  input  wire                                     l2db3_rmw_line_i,
  input  wire                                     l2db4_rmw_line_i,
  input  wire                                     l2db5_rmw_line_i,
  input  wire                                     l2db6_rmw_line_i,
  input  wire                                     l2db7_rmw_line_i,
  input  wire                                     l2db8_rmw_line_i,
  input  wire                                     l2db9_rmw_line_i,
  input  wire                                     l2db10_rmw_line_i,

  // L2 RAM controller requests
  output wire                                     tagctl_ramctl_valid_o,
  output wire                                     tagctl_ramctl_cancel_o,
  output wire                                     tagctl_ramctl_flush_o,
  output wire [10:0]                              tagctl_ramctl_index_o,
  output wire [3:0]                               tagctl_ramctl_way_o,
  output wire [3:0]                               tagctl_ramctl_l2db_o,
  output wire [1:0]                               tagctl_ramctl_crit_chunk_o,
  output wire [7:0]                               tagctl_ramctl_banks_o,
  input  wire                                     ramctl_tagctl_ready_i,
  output wire                                     tagctl_l2dataram_req_tc2_o,
  output wire [10:0]                              tagctl_l2dataram_index_o,
  output wire [15:0]                              tagctl_l2dataram_way_o,
  output wire [7:0]                               tagctl_l2dataram_banks_o,
  input  wire                                     ramctl_mask_tc2_i,

  // DVM syncs
  output wire                                     tagctl_dvm_sync_tc3_o,
  output wire                                     tagctl_snp_dvm_sync_tc4_o,
  output wire [3:0]                               tagctl_cpu_dvm_sync_tc4_o,
  output wire [3:0]                               tagctl_dvm_complete_o,
  input  wire                                     dcu_cpu0_dvm_complete_i,
  input  wire                                     dcu_cpu1_dvm_complete_i,
  input  wire                                     dcu_cpu2_dvm_complete_i,
  input  wire                                     dcu_cpu3_dvm_complete_i,

  // MBIST
  input  wire                                     gov_mbistreq_i,
  input  wire [`CA53_MBIST0_RAMARRAY_W-1:0]       gov_mbistarray0_i,
  input  wire                                     gov_mbistwriteen0_i,
  input  wire                                     gov_mbistreaden0_i,
  input  wire [`CA53_MBIST0_ADDR_W-1:0]           gov_mbistaddr0_i,
  input  wire [`CA53_MBIST0_BE_W-1:0]             gov_mbistbe0_i,
  input  wire                                     gov_mbistcfg0_i,
  input  wire [39:0]                              gov_mbistindata0_i,
  output wire                                     tagctl_mbistreq_o,
  output wire                                     tagctl_mbist_sel_o,
  output wire [39:0]                              tagctl_mbistoutdata_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam MAX_UNSERIALISED_L2DBS = (NUM_L2DBS - 3);

  genvar i;

  reg                     clk_enable;
  reg                     clk_enable_early_tc1;
  reg                     tagctl_mbistreq;
  reg [2:0]               tagctl_l1_dc_size;
  reg [3:0]               tagctl_l2_size;
  reg                     tagctl_broadcastinner;
  reg                     tagctl_broadcastouter;
  reg                     tagctl_broadcastcachemaint;
  reg                     l2_in_retention;
  reg [10:0]              inval_count_tc0;

  wire                    clk_tagctl;
  wire                    clk_tc1;
  wire                    next_clk_enable;
  wire                    next_clk_enable_early_tc1;
  wire                    clk_enable_tc1;
  wire [5:0]              slv_valid_req_tc0;
  wire [5:0]              slv_early_req_tc0;
  wire [5:0]              slv_spec_req_tc0;
  wire [5:0]              slv_req_tc0;
  wire [13:0]             slv_grant_tc0;
  wire [5:0]              afb_tagctl_valid_tc0;
  wire [5:0]              afb_req_tc0;
  wire [5:0]              afb_grant_tc0;
  wire                    afb_rr_en_tc0;
  wire                    lfsr_enable_tc0;
  wire [NUM_CPUS+ACP+1:0] lfsr_req_tc0;
  wire [NUM_CPUS+ACP+1:0] lfsr_grant_tc0;
  wire                    valid_tc0;
  wire                    flush_tc0;
  wire [3:0]              smp_en_tc0;
  wire [5:0]              req_id_tc0;
  wire [3:0]              req_pass_tc0;
  wire [41:0]             req_addr_tc0;
  wire                    req_addr13_tc0;
  wire                    req_dvm_sync_tc0;
  wire [16:0]             req_wr_state_tc0;
  wire [34:0]             req_ecc_tc0;
  wire [31:0]             req_ways_tc0;
  wire [4:0]              req_write_tc0;
  wire [5:0]              req_type_tc0;
  wire                    req_l2flushreq_tc0;
  wire [3:0]              force_smp_en_tc0;
  wire [31:0]             mbist_tagram_en_tc0;
  wire [40:0]             mbist_addr_tc0;
  wire [40:0]             ecc_addr_tc0;
  wire                    force_ecc_mbist_arb_tc0;
  wire                    force_arb_tc0;
  wire [4:0]              inval_tags_tc0;
  wire [31:0]             inval_tag_ways_tc0;

  reg                     valid_tc1;
  reg [4:0]               valid_ways_tc1;
  reg [6+NUM_CPUS+ACP:0]  slv_grant_comp_tc1;
  reg                     tagram_clken_tc1;
  reg [5:0]               req_id_tc1;
  reg [5:0]               req_type_tc1;
  reg                     req_l2flushreq_tc1;
  reg [3:0]               req_pass_tc1;
  reg [41:0]              req_addr_tc1;
  reg [1:0]               req_addr_tc1_err;
  reg                     req_addr13_tc1;
  reg                     req_dvm_sync_tc1;
  wire [40:0]             req_addr1_tc1;
  wire [40:0]             req_master_addr_tc1;
  reg [16:0]              req_wr_state_tc1;
  reg [34:0]              req_ecc_tc1;
  wire [40:0]             req_addr2_tc1;
  reg [31:0]              req_ways_tc1;
  reg [4:0]               req_write_tc1;
  wire [1:0]              req_len_tc1;
  wire                    req_single_tc1;
  wire [2:0]              req_size_tc1;
  wire                    req_lock_tc1;
  wire                    req_dirty_tc1;
  wire                    req_cluster_unique_tc1;
  wire [7:0]              req_attrs_tc1;
  wire [1:0]              req_prot_tc1;
  wire [3:0]              req_l2db_tc1;
  reg                     req_l2db_rmw_tc1;
  wire                    req_l2db_full_tc1;
  wire                    req_static_pcredit_tc1;
  wire [1:0]              req_pcrdtype_tc1;
  wire [3:0]              req_victim_way_tc1;
  reg [3:0]               smp_en_tc1;
  reg [10:0]              inval_count_tc1;
  reg [4:0]               inval_tags_tc1;
  reg [3:0]               unserialised_l2dbs_tc1;
  reg [7:0]               l2db_hz_count_tc1;
  reg                     prevent_write_alloc_tc1;

  wire                    flush_tc1;
  wire [5:0]              afb_tc1;
  wire [31:0]             tagram_en_tc1;
  wire [31:0]             req_ways_read_tc1;
  wire [39:0]             l1d0_write_data_tc1;
  wire [39:0]             l1d1_write_data_tc1;
  wire [39:0]             l1d2_write_data_tc1;
  wire [39:0]             l1d3_write_data_tc1;
  wire [39:0]             l2_write_data_tc1;
  wire [39:0]             inval_data_tc1;
  wire                    req_id_dcu_tc1;
  wire                    next_valid_tc1;
  wire [4:0]              next_valid_ways_tc1;
  wire [11:0]             slv_grant_tc1;
  wire [6+NUM_CPUS+ACP:0] next_slv_grant_comp_tc1;
  wire                    next_tagram_clken_tc1;
  wire                    alloc_afb0_tc1;
  wire                    alloc_afb1_tc1;
  wire                    alloc_afb2_tc1;
  wire                    alloc_afb3_tc1;
  wire                    alloc_afb4_tc1;
  wire                    alloc_afb5_tc1;
  wire                    acp_slverr_tc1;
  wire                    l2db_used_for_snoop_tc1;
  wire                    first_l2db_valid_tc1;
  wire                    second_l2db_valid_tc1;
  wire                    third_l2db_valid_tc1;
  wire                    alloc_l2db_for_read_tc1;
  wire                    alloc_l2db_for_victim_tc1;
  wire                    alloc_second_l2db_tc1;
  wire                    valid_second_l2db_tc1;
  wire                    alloc_l2db_for_write_tc1;
  wire                    alloc_l2db_for_acp_read_tc1;
  wire                    alloc_first_l2db_tc1;
  wire                    first_l2db_avail_tc1;
  wire                    first_l2db_avail_for_write_tc1;
  wire                    first_l2db_avail_for_acp_read_tc1;
  wire                    afb_required_tc1;
  wire                    afb_available_tc1;
  wire [5:0]              afb_lowest_available_tc1;
  wire [MAX_L2DBS-1:0]    l2db_avail_lower_tc1;
  wire [MAX_L2DBS-1:0]    l2db_avail_higher_tc1;
  wire [MAX_L2DBS-1:0]    first_l2db_tc1;
  wire [MAX_L2DBS-1:0]    second_l2db_tc1;
  wire [MAX_L2DBS-1:0]    l2db_available_tc1;
  wire [NUM_CPUS-1:0]     next_inval_l1_tags;
  wire [4:0]              inval_tags_complete;
  wire [10:0]             next_inval_count_tc0;
  wire                    inval_count_en;
  wire [3:0]              first_l2db_enc_tc1;
  wire [3:0]              second_l2db_enc_tc1;
  wire                    req_dev_hz_tc1;
  wire                    req_tc1_en;
  wire [3:0]              next_unserialised_l2dbs_tc1;
  wire                    unserialised_l2db_tc1;
  wire                    unserialised_l2dbs_tc1_en;
  wire                    allow_unserialised_l2db_tc1;
  wire                    victim_hz_tc1;
  wire                    tagctl_addr_valid_tc1;
  wire                    afb_hz_tc1;
  wire                    afb0_hz_tc1;
  wire                    afb1_hz_tc1;
  wire                    afb2_hz_tc1;
  wire                    afb3_hz_tc1;
  wire                    afb4_hz_tc1;
  wire                    afb5_hz_tc1;
  wire [4:0]              req_l2_write_state_tc1;
  wire [7:0]              next_l2db_hz_count_tc1;
  wire                    l2db_hz_count_reset_tc1;
  wire                    l2db_hz_count_incr_tc1;
  wire                    l2db_hz_count_tc1_en;
  wire                    prevent_single_alloc_tc1;
  wire [3:0]              l2dbs_used_for_write;
  wire                    next_prevent_write_alloc_tc1;
  wire [41:6]             tagctl_addr_tc1;

  reg                     valid_tc2;
  reg [5:0]               afb_tc2;
  reg [5:0]               req_id_tc2;
  reg [5:0]               req_type_tc2;
  reg [3:0]               req_pass_tc2;
  reg [40:0]              req_addr1_tc2;
  reg [31:0]              req_ways_read_tc2;
  reg                     req_dev_hz_tc2;
  reg                     req_victim_hz_tc2;
  reg                     afb_hz_tc2;
  reg [3:0]               smp_en_tc2;
  reg [3:0]               req_victim_way_tc2;
  reg [4:0]               req_l2_write_state_tc2;

  wire                    flush_tc2;
  wire                    flush_raw_tc2;
  wire                    flush_allowed_tc2;
  wire                    next_valid_tc2;
  wire [5:0]              next_afb_tc2;
  wire                    tagctl_l2dataram_req_tc2;
  wire                    l2_data_access_tc2;
  wire                    req_single_tc2;
  wire                    flush_afb0_tc2;
  wire                    flush_afb1_tc2;
  wire                    flush_afb2_tc2;
  wire                    flush_afb3_tc2;
  wire                    flush_afb4_tc2;
  wire                    flush_afb5_tc2;
  wire                    active_afb0_tc2;
  wire                    active_afb1_tc2;
  wire                    active_afb2_tc2;
  wire                    active_afb3_tc2;
  wire                    active_afb4_tc2;
  wire                    active_afb5_tc2;
  wire                    cpuslv_snp_hz_tc2;
  wire [4:0]              cpuslv_snp_hz_id_tc2;
  wire                    cpuslv_snp_l2db_hz_tc2;
  wire                    cpuslv_snp_l2db_dirty_tc2;
  wire                    cpuslv_snp_l2db_cu_tc2;
  wire [3:0]              cpuslv_snp_l2db_tc2;
  wire                    tagctl_ecc_hz_tc2;
  wire [2:0]              tag_valid_ctl_tc2;
  wire [15:0]             l1_comp_ways_tc2;
  wire [15:0]             l1_cu_ways_tc2;
  wire [15:0]             l1_valid_ways_tc2;
  wire [15:0]             l1_state0_ways_tc2;
  wire [15:0]             l1_state1_ways_tc2;
  wire [3:0]              l1_ecc_victim_way_tc2;
  wire [29:0]             l1_tag_value_tc2;
  wire [27:0]             l2_tag_value_tc2;
  wire [15:0]             l2_comp_ways_tc2;
  wire [15:0]             l2_valid_ways_tc2;
  wire [15:0]             l2_hit_ways_tc2;
  wire [15:0]             l2_dirty_ways_tc2;
  wire [15:0]             l2_cu_ways_tc2;
  wire [15:0]             l2_state0_ways_tc2;
  wire [15:0]             l2_state1_ways_tc2;
  wire [15:0]             l2_alloc_ways_tc2;
  wire [3:0]              l1_lookup_cpu_en_tc2;
  wire [3:0]              l1_victim_cpu_en_tc2;
  wire [3:0]              requestor_cpu_tc2;
  wire [15:0]             l1_victim_way_tc2;
  wire [15:0]             l2_victim_way_tc2;
  wire [3:0]              l2_victim_valid_way_tc2;
  wire                    l2_victim_valid_tc2;
  wire [32:0]             l2_victim_tag_tc2;
  wire [15:0]             l2_victim_eligible_ways_tc2;
  wire [15:0]             l2_victim_invalid_eligible_ways_tc2;
  wire [15:0]             l2_victim_invalid_ways_tc2;
  wire [3:0]              l2_victim_invalid_way_tc2;
  wire                    victim_tag_sel_req_tc2;
  wire                    victim_tag_sel_l1_tc2;
  wire                    victim_tag_sel_l2_tc2;
  wire [34:0]             victim_tag_tc2;
  wire [32:0]             l1_victim_tag_tc2;
  wire [5:0]              victim_index_tc2;
  wire                    victim_hz_tc2;
  wire [6:0]              l1_victim_tag_ecc_tc2;
  wire [6:0]              l2_victim_tag_ecc_tc2;
  wire [6:0]              victim_tag_ecc_tc2;
  wire [32:0]             l1_tagram_rdata_tc2     [15:0];
  wire [32:0]             l2_tagram_rdata_tc2     [15:0];
  wire [6:0]              l1_tagram_rdata_ecc_tc2 [15:0];
  wire [6:0]              l2_tagram_rdata_ecc_tc2 [15:0];
  wire [111:0]            l1_tag_syndrome_tc2;
  wire [111:0]            l2_tag_syndrome_tc2;
  wire [32:0]             req_l2_write_data_tc2;
  wire [6:0]              req_l2_ecc_tc2;

  reg                     valid_tc3;
  reg [5:0]               afb_tc3;
  reg [5:0]               req_id_tc3;
  reg [5:0]               req_type_tc3;
  reg [3:0]               req_pass_tc3;
  reg [16:6]              req_addr1_tc3;
  reg [31:0]              req_ways_read_tc3;
  reg [15:0]              l1_comp_ways_tc3;
  reg [15:0]              l1_cu_ways_tc3;
  reg [15:0]              l1_state0_ways_tc3;
  reg [15:0]              l1_state1_ways_tc3;
  reg [3:0]               l1_lookup_cpu_en_tc3;
  reg [3:0]               l1_victim_cpu_en_tc3;
  reg [3:0]               l1_ecc_victim_way_tc3;
  reg [3:0]               l2_victim_valid_way_tc3;
  reg [3:0]               l2_victim_invalid_way_tc3;
  reg [15:0]              l2_victim_invalid_eligible_ways_tc3;
  reg [15:0]              l2_hit_ways_tc3;
  reg [15:0]              l2_dirty_ways_tc3;
  reg [15:0]              l2_cu_ways_tc3;
  reg [15:0]              l2_state0_ways_tc3;
  reg [15:0]              l2_state1_ways_tc3;
  reg [15:0]              l2_alloc_ways_tc3;
  reg                     l2_victim_valid_tc3;
  reg                     req_victim_hz_tc3;
  reg [34:0]              victim_tag_tc3;
  reg [5:0]               victim_index_tc3;
  reg [1:0]               round_robin_tc3;
  reg                     tagctl_disable_evict_tc3;
  reg                     tagctl_enable_writeevict_tc3;
  reg [6:0]               victim_tag_ecc_tc3;
  reg [28*NUM_CPUS-1:0]   l1_tag_syndrome_cpu_tc3;
  reg [111:0]             l2_tag_syndrome_tc3;
  reg [3:0]               ncoh_writes_tc3;

  wire                    flush_tc3;
  wire                    flush_raw_tc3;
  wire                    next_valid_tc3;
  wire [5:0]              next_afb_tc3;
  wire [15:0]             l1_lookup_ways_en_tc3;
  wire [15:0]             l1_lookup_hit_ways_tc3;
  wire [3:0]              l1_lookup_hit_cpus_tc3;
  wire                    l1_lookup_hit_tc3;
  wire [15:0]             l1_hit_ways_tc3;
  wire [3:0]              l2_victim_way_tc3;
  wire [15:0]             l1_victim_hit_ways_tc3;
  wire [3:0]              l1_victim_hit_cpus_tc3;
  wire                    l1_victim_hit_tc3;
  wire [111:0]            l1_tag_syndrome_tc3;
  wire                    l2_hit_tc3;
  wire                    l2_hit_dirty_tc3;
  wire                    l2_dirty_tc3;
  wire                    tagctl_inner_sh_tc3;
  wire                    tagctl_outer_sh_tc3;
  wire [1:0]              tagctl_hit_shareability_tc3;
  wire                    tagctl_force_cluster_unique_tc3;
  wire                    cluster_unique_tc3;
  wire [40:6]             victim_addr_tc3;
  wire                    tagctl_addr_valid_tc3;
  wire                    l2_victim_dirty_tc3;
  wire                    l2_victim_alloc_tc3;
  wire                    l2_victim_cu_tc3;
  wire [1:0]              l2_victim_shareability_tc3;
  wire                    afb0_force_cluster_unique_tc3;
  wire                    afb1_force_cluster_unique_tc3;
  wire                    afb2_force_cluster_unique_tc3;
  wire                    afb3_force_cluster_unique_tc3;
  wire                    afb4_force_cluster_unique_tc3;
  wire                    afb5_force_cluster_unique_tc3;
  wire                    active_afb0_tc3;
  wire                    active_afb1_tc3;
  wire                    active_afb2_tc3;
  wire                    active_afb3_tc3;
  wire                    active_afb4_tc3;
  wire                    active_afb5_tc3;
  wire                    flush_afb0_tc3;
  wire                    flush_afb1_tc3;
  wire                    flush_afb2_tc3;
  wire                    flush_afb3_tc3;
  wire                    flush_afb4_tc3;
  wire                    flush_afb5_tc3;
  wire                    ecc_err_tc3;
  wire [1:0]              next_round_robin_tc3;
  wire                    round_robin_tc3_en;
  wire                    afb0_l2db_hazard_tc3;
  wire                    afb1_l2db_hazard_tc3;
  wire                    afb2_l2db_hazard_tc3;
  wire                    afb3_l2db_hazard_tc3;
  wire                    afb4_l2db_hazard_tc3;
  wire                    afb5_l2db_hazard_tc3;
  wire                    afb0_update_rr_tc3;
  wire                    afb1_update_rr_tc3;
  wire                    afb2_update_rr_tc3;
  wire                    afb3_update_rr_tc3;
  wire                    afb4_update_rr_tc3;
  wire                    afb5_update_rr_tc3;
  wire                    afb0_l2db_hazard_both_tc4;
  wire                    afb1_l2db_hazard_both_tc4;
  wire                    afb2_l2db_hazard_both_tc4;
  wire                    afb3_l2db_hazard_both_tc4;
  wire                    afb4_l2db_hazard_both_tc4;
  wire                    afb5_l2db_hazard_both_tc4;
  wire [1:0]              afb0_snoop_data_cpu_tc4;
  wire [1:0]              afb1_snoop_data_cpu_tc4;
  wire [1:0]              afb2_snoop_data_cpu_tc4;
  wire [1:0]              afb3_snoop_data_cpu_tc4;
  wire [1:0]              afb4_snoop_data_cpu_tc4;
  wire [1:0]              afb5_snoop_data_cpu_tc4;
  wire                    l2db_flush_tc3;
  wire                    victim_flush_tc3;
  wire                    serialised_l2db_tc3;
  wire [15:0]             l1_tag_err_tc3;
  wire [15:0]             l2_tag_err_tc3;
  wire                    afb0_hz_tc3;
  wire                    afb1_hz_tc3;
  wire                    afb2_hz_tc3;
  wire                    afb3_hz_tc3;
  wire                    afb4_hz_tc3;
  wire                    afb5_hz_tc3;
  wire                    ncoh_write_hz_tc3;
  wire [3:0]              next_ncoh_writes_tc3;
  wire                    ncoh_writes_en_tc3;
  wire                    ncoh_write_tc3;
  wire [40:6]             tagctl_addr_tc3;

  reg                     valid_tc4;
  reg [5:0]               afb_tc4;
  reg                     l2db_flush_tc4;
  reg                     allow_flush_tc4;
  reg                     early_flush_tc4;
  reg                     serialised_l2db_tc4;

  wire                    next_valid_tc4;
  wire                    next_allow_flush_tc4;
  wire                    next_early_flush_tc4;
  wire                    next_l2db_flush_tc4;
  wire [5:0]              next_afb_tc4;
  wire                    flush_tc4;
  wire                    active_afb0_tc4;
  wire                    active_afb1_tc4;
  wire                    active_afb2_tc4;
  wire                    active_afb3_tc4;
  wire                    active_afb4_tc4;
  wire                    active_afb5_tc4;
  wire                    flush_afb0_tc4;
  wire                    flush_afb1_tc4;
  wire                    flush_afb2_tc4;
  wire                    flush_afb3_tc4;
  wire                    flush_afb4_tc4;
  wire                    flush_afb5_tc4;


  wire [1:0]              cpu_count;
  wire                    zero;
  wire                    victim_way_rr_en;
  wire [6:0]              snoop_reqs_cpu [NUM_CPUS-1:0];
  wire [6:0]              dvm_mask [NUM_CPUS-1:0];
  wire [3:0]              afb0_snoop_second_dvm;
  wire [3:0]              afb1_snoop_second_dvm;
  wire [3:0]              afb2_snoop_second_dvm;
  wire [3:0]              afb3_snoop_second_dvm;
  wire [3:0]              afb4_snoop_second_dvm;
  wire [3:0]              afb5_snoop_second_dvm;
  wire [6:0]              afb_sel_cpu [3:0];
  wire [3:0]              ac_valid_cpu;
  wire [3:0]              ac_ready_cpu;
  wire [NUM_CPUS-1:0]     snoop_accepted;
  wire [5:0]              flush_afb;
  wire                    afb0_cpu0_ac_ready;
  wire                    afb1_cpu0_ac_ready;
  wire                    afb2_cpu0_ac_ready;
  wire                    afb3_cpu0_ac_ready;
  wire                    afb4_cpu0_ac_ready;
  wire                    afb5_cpu0_ac_ready;
  wire                    afb0_cpu1_ac_ready;
  wire                    afb1_cpu1_ac_ready;
  wire                    afb2_cpu1_ac_ready;
  wire                    afb3_cpu1_ac_ready;
  wire                    afb4_cpu1_ac_ready;
  wire                    afb5_cpu1_ac_ready;
  wire                    afb0_cpu2_ac_ready;
  wire                    afb1_cpu2_ac_ready;
  wire                    afb2_cpu2_ac_ready;
  wire                    afb3_cpu2_ac_ready;
  wire                    afb4_cpu2_ac_ready;
  wire                    afb5_cpu2_ac_ready;
  wire                    afb0_cpu3_ac_ready;
  wire                    afb1_cpu3_ac_ready;
  wire                    afb2_cpu3_ac_ready;
  wire                    afb3_cpu3_ac_ready;
  wire                    afb4_cpu3_ac_ready;
  wire                    afb5_cpu3_ac_ready;
  wire [3:0]              ecc_snoop_req;
  wire                    ecc_ac_ready;
  wire [40:0]             ecc_ac_addr;
  wire [3:0]              ecc_ac_way;
  reg [NUM_CPUS-1:0]      inval_l1_tags;
  reg                     inval_l2_tags;
  wire                    tagctl_active;
  wire [3:0]              cpus_inv_all_starting;
  wire                    start_inval;
  wire                    inval_active;
  wire                    next_inval_l2_tags;
  wire                    afb0_valid;
  wire                    afb1_valid;
  wire                    afb2_valid;
  wire                    afb3_valid;
  wire                    afb4_valid;
  wire                    afb5_valid;
  wire                    afb0_requires_master;
  wire                    afb1_requires_master;
  wire                    afb2_requires_master;
  wire                    afb3_requires_master;
  wire                    afb4_requires_master;
  wire                    afb5_requires_master;
  wire [5:0]              ramctl_req;
  wire [5:0]              ramctl_arb;
  wire                    round_robin_ramctl_en;
  wire [3:0]              afb0_snoop_req;
  wire [3:0]              afb1_snoop_req;
  wire [3:0]              afb2_snoop_req;
  wire [3:0]              afb3_snoop_req;
  wire [3:0]              afb4_snoop_req;
  wire [3:0]              afb5_snoop_req;
  wire [3:0]              afb0_cpu0_ac_snoop;
  wire [3:0]              afb1_cpu0_ac_snoop;
  wire [3:0]              afb2_cpu0_ac_snoop;
  wire [3:0]              afb3_cpu0_ac_snoop;
  wire [3:0]              afb4_cpu0_ac_snoop;
  wire [3:0]              afb5_cpu0_ac_snoop;
  wire [3:0]              afb0_cpu1_ac_snoop;
  wire [3:0]              afb1_cpu1_ac_snoop;
  wire [3:0]              afb2_cpu1_ac_snoop;
  wire [3:0]              afb3_cpu1_ac_snoop;
  wire [3:0]              afb4_cpu1_ac_snoop;
  wire [3:0]              afb5_cpu1_ac_snoop;
  wire [3:0]              afb0_cpu2_ac_snoop;
  wire [3:0]              afb1_cpu2_ac_snoop;
  wire [3:0]              afb2_cpu2_ac_snoop;
  wire [3:0]              afb3_cpu2_ac_snoop;
  wire [3:0]              afb4_cpu2_ac_snoop;
  wire [3:0]              afb5_cpu2_ac_snoop;
  wire [3:0]              afb0_cpu3_ac_snoop;
  wire [3:0]              afb1_cpu3_ac_snoop;
  wire [3:0]              afb2_cpu3_ac_snoop;
  wire [3:0]              afb3_cpu3_ac_snoop;
  wire [3:0]              afb4_cpu3_ac_snoop;
  wire [3:0]              afb5_cpu3_ac_snoop;
  wire [3:0]              afb0_cpu0_ac_l2db_id;
  wire [3:0]              afb1_cpu0_ac_l2db_id;
  wire [3:0]              afb2_cpu0_ac_l2db_id;
  wire [3:0]              afb3_cpu0_ac_l2db_id;
  wire [3:0]              afb4_cpu0_ac_l2db_id;
  wire [3:0]              afb5_cpu0_ac_l2db_id;
  wire [3:0]              afb0_cpu1_ac_l2db_id;
  wire [3:0]              afb1_cpu1_ac_l2db_id;
  wire [3:0]              afb2_cpu1_ac_l2db_id;
  wire [3:0]              afb3_cpu1_ac_l2db_id;
  wire [3:0]              afb4_cpu1_ac_l2db_id;
  wire [3:0]              afb5_cpu1_ac_l2db_id;
  wire [3:0]              afb0_cpu2_ac_l2db_id;
  wire [3:0]              afb1_cpu2_ac_l2db_id;
  wire [3:0]              afb2_cpu2_ac_l2db_id;
  wire [3:0]              afb3_cpu2_ac_l2db_id;
  wire [3:0]              afb4_cpu2_ac_l2db_id;
  wire [3:0]              afb5_cpu2_ac_l2db_id;
  wire [3:0]              afb0_cpu3_ac_l2db_id;
  wire [3:0]              afb1_cpu3_ac_l2db_id;
  wire [3:0]              afb2_cpu3_ac_l2db_id;
  wire [3:0]              afb3_cpu3_ac_l2db_id;
  wire [3:0]              afb4_cpu3_ac_l2db_id;
  wire [3:0]              afb5_cpu3_ac_l2db_id;
  wire [40:0]             afb0_cpu0_ac_addr;
  wire [40:0]             afb1_cpu0_ac_addr;
  wire [40:0]             afb2_cpu0_ac_addr;
  wire [40:0]             afb3_cpu0_ac_addr;
  wire [40:0]             afb4_cpu0_ac_addr;
  wire [40:0]             afb5_cpu0_ac_addr;
  wire [40:0]             afb0_cpu1_ac_addr;
  wire [40:0]             afb1_cpu1_ac_addr;
  wire [40:0]             afb2_cpu1_ac_addr;
  wire [40:0]             afb3_cpu1_ac_addr;
  wire [40:0]             afb4_cpu1_ac_addr;
  wire [40:0]             afb5_cpu1_ac_addr;
  wire [40:0]             afb0_cpu2_ac_addr;
  wire [40:0]             afb1_cpu2_ac_addr;
  wire [40:0]             afb2_cpu2_ac_addr;
  wire [40:0]             afb3_cpu2_ac_addr;
  wire [40:0]             afb4_cpu2_ac_addr;
  wire [40:0]             afb5_cpu2_ac_addr;
  wire [40:0]             afb0_cpu3_ac_addr;
  wire [40:0]             afb1_cpu3_ac_addr;
  wire [40:0]             afb2_cpu3_ac_addr;
  wire [40:0]             afb3_cpu3_ac_addr;
  wire [40:0]             afb4_cpu3_ac_addr;
  wire [40:0]             afb5_cpu3_ac_addr;
  wire [3:0]              afb0_cpu0_ac_way;
  wire [3:0]              afb1_cpu0_ac_way;
  wire [3:0]              afb2_cpu0_ac_way;
  wire [3:0]              afb3_cpu0_ac_way;
  wire [3:0]              afb4_cpu0_ac_way;
  wire [3:0]              afb5_cpu0_ac_way;
  wire [3:0]              afb0_cpu1_ac_way;
  wire [3:0]              afb1_cpu1_ac_way;
  wire [3:0]              afb2_cpu1_ac_way;
  wire [3:0]              afb3_cpu1_ac_way;
  wire [3:0]              afb4_cpu1_ac_way;
  wire [3:0]              afb5_cpu1_ac_way;
  wire [3:0]              afb0_cpu2_ac_way;
  wire [3:0]              afb1_cpu2_ac_way;
  wire [3:0]              afb2_cpu2_ac_way;
  wire [3:0]              afb3_cpu2_ac_way;
  wire [3:0]              afb4_cpu2_ac_way;
  wire [3:0]              afb5_cpu2_ac_way;
  wire [3:0]              afb0_cpu3_ac_way;
  wire [3:0]              afb1_cpu3_ac_way;
  wire [3:0]              afb2_cpu3_ac_way;
  wire [3:0]              afb3_cpu3_ac_way;
  wire [3:0]              afb4_cpu3_ac_way;
  wire [3:0]              afb5_cpu3_ac_way;
  wire                    afb0_cpuslv0_snp_active;
  wire                    afb1_cpuslv0_snp_active;
  wire                    afb2_cpuslv0_snp_active;
  wire                    afb3_cpuslv0_snp_active;
  wire                    afb4_cpuslv0_snp_active;
  wire                    afb5_cpuslv0_snp_active;
  wire                    afb0_cpuslv1_snp_active;
  wire                    afb1_cpuslv1_snp_active;
  wire                    afb2_cpuslv1_snp_active;
  wire                    afb3_cpuslv1_snp_active;
  wire                    afb4_cpuslv1_snp_active;
  wire                    afb5_cpuslv1_snp_active;
  wire                    afb0_cpuslv2_snp_active;
  wire                    afb1_cpuslv2_snp_active;
  wire                    afb2_cpuslv2_snp_active;
  wire                    afb3_cpuslv2_snp_active;
  wire                    afb4_cpuslv2_snp_active;
  wire                    afb5_cpuslv2_snp_active;
  wire                    afb0_cpuslv3_snp_active;
  wire                    afb1_cpuslv3_snp_active;
  wire                    afb2_cpuslv3_snp_active;
  wire                    afb3_cpuslv3_snp_active;
  wire                    afb4_cpuslv3_snp_active;
  wire                    afb5_cpuslv3_snp_active;
  wire [MAX_L2DBS-1:0]    afb0_l2db_release;
  wire [MAX_L2DBS-1:0]    afb1_l2db_release;
  wire [MAX_L2DBS-1:0]    afb2_l2db_release;
  wire [MAX_L2DBS-1:0]    afb3_l2db_release;
  wire [MAX_L2DBS-1:0]    afb4_l2db_release;
  wire [MAX_L2DBS-1:0]    afb5_l2db_release;
  wire [MAX_L2DBS-1:0]    afb0_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb1_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb2_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb3_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb4_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb5_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    tagctl_l2db_release;
  wire [MAX_L2DBS-1:0]    tagctl_l2db_snoops_done;
  wire [MAX_L2DBS-1:0]    afb0_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    afb1_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    afb2_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    afb3_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    afb4_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    afb5_l2db_fill_strbs;
  wire [MAX_L2DBS-1:0]    tagctl_l2db_fill_strbs;
  wire                    afb0_req_single;
  wire                    afb1_req_single;
  wire                    afb2_req_single;
  wire                    afb3_req_single;
  wire                    afb4_req_single;
  wire                    afb5_req_single;
  wire                    ramctl_afb0_ready;
  wire                    ramctl_afb1_ready;
  wire                    ramctl_afb2_ready;
  wire                    ramctl_afb3_ready;
  wire                    ramctl_afb4_ready;
  wire                    ramctl_afb5_ready;
  wire [5:0]              ramctl_l2db_arb;
  wire                    afb0_ramctl_valid;
  wire                    afb1_ramctl_valid;
  wire                    afb2_ramctl_valid;
  wire                    afb3_ramctl_valid;
  wire                    afb4_ramctl_valid;
  wire                    afb5_ramctl_valid;
  wire                    afb0_ramctl_cancel;
  wire                    afb1_ramctl_cancel;
  wire                    afb2_ramctl_cancel;
  wire                    afb3_ramctl_cancel;
  wire                    afb4_ramctl_cancel;
  wire                    afb5_ramctl_cancel;
  wire                    afb0_ramctl_flush;
  wire                    afb1_ramctl_flush;
  wire                    afb2_ramctl_flush;
  wire                    afb3_ramctl_flush;
  wire                    afb4_ramctl_flush;
  wire                    afb5_ramctl_flush;
  wire [10:0]             afb0_ramctl_index;
  wire [10:0]             afb1_ramctl_index;
  wire [10:0]             afb2_ramctl_index;
  wire [10:0]             afb3_ramctl_index;
  wire [10:0]             afb4_ramctl_index;
  wire [10:0]             afb5_ramctl_index;
  wire [3:0]              afb0_ramctl_way;
  wire [3:0]              afb1_ramctl_way;
  wire [3:0]              afb2_ramctl_way;
  wire [3:0]              afb3_ramctl_way;
  wire [3:0]              afb4_ramctl_way;
  wire [3:0]              afb5_ramctl_way;
  wire [1:0]              afb0_ramctl_crit_chunk;
  wire [1:0]              afb1_ramctl_crit_chunk;
  wire [1:0]              afb2_ramctl_crit_chunk;
  wire [1:0]              afb3_ramctl_crit_chunk;
  wire [1:0]              afb4_ramctl_crit_chunk;
  wire [1:0]              afb5_ramctl_crit_chunk;
  wire [7:0]              afb0_ramctl_banks;
  wire [7:0]              afb1_ramctl_banks;
  wire [7:0]              afb2_ramctl_banks;
  wire [7:0]              afb3_ramctl_banks;
  wire [7:0]              afb4_ramctl_banks;
  wire [7:0]              afb5_ramctl_banks;
  wire [3:0]              afb0_slv_l2db;
  wire [3:0]              afb1_slv_l2db;
  wire [3:0]              afb2_slv_l2db;
  wire [3:0]              afb3_slv_l2db;
  wire [3:0]              afb4_slv_l2db;
  wire [3:0]              afb5_slv_l2db;
  wire [3:0]              afb0_slv_victim_l2db_tc4;
  wire [3:0]              afb1_slv_victim_l2db_tc4;
  wire [3:0]              afb2_slv_victim_l2db_tc4;
  wire [3:0]              afb3_slv_victim_l2db_tc4;
  wire [3:0]              afb4_slv_victim_l2db_tc4;
  wire [3:0]              afb5_slv_victim_l2db_tc4;
  wire                    afb0_slv_l2db_hit_tc3;
  wire                    afb1_slv_l2db_hit_tc3;
  wire                    afb2_slv_l2db_hit_tc3;
  wire                    afb3_slv_l2db_hit_tc3;
  wire                    afb4_slv_l2db_hit_tc3;
  wire                    afb5_slv_l2db_hit_tc3;
  wire                    afb0_slv_l2db_dirty_tc3;
  wire                    afb1_slv_l2db_dirty_tc3;
  wire                    afb2_slv_l2db_dirty_tc3;
  wire                    afb3_slv_l2db_dirty_tc3;
  wire                    afb4_slv_l2db_dirty_tc3;
  wire                    afb5_slv_l2db_dirty_tc3;
  wire                    afb0_slv_l2db_cu_tc3;
  wire                    afb1_slv_l2db_cu_tc3;
  wire                    afb2_slv_l2db_cu_tc3;
  wire                    afb3_slv_l2db_cu_tc3;
  wire                    afb4_slv_l2db_cu_tc3;
  wire                    afb5_slv_l2db_cu_tc3;
  wire                    afb0_slv_snp_hz_tc4;
  wire                    afb1_slv_snp_hz_tc4;
  wire                    afb2_slv_snp_hz_tc4;
  wire                    afb3_slv_snp_hz_tc4;
  wire                    afb4_slv_snp_hz_tc4;
  wire                    afb5_slv_snp_hz_tc4;
  wire [4:0]              afb0_slv_snp_hz_id_tc4;
  wire [4:0]              afb1_slv_snp_hz_id_tc4;
  wire [4:0]              afb2_slv_snp_hz_id_tc4;
  wire [4:0]              afb3_slv_snp_hz_id_tc4;
  wire [4:0]              afb4_slv_snp_hz_id_tc4;
  wire [4:0]              afb5_slv_snp_hz_id_tc4;
  wire                    afb0_slv_l2db_invalidated_tc4;
  wire                    afb1_slv_l2db_invalidated_tc4;
  wire                    afb2_slv_l2db_invalidated_tc4;
  wire                    afb3_slv_l2db_invalidated_tc4;
  wire                    afb4_slv_l2db_invalidated_tc4;
  wire                    afb5_slv_l2db_invalidated_tc4;
  wire                    afb0_slv_l2db_cleaned_tc4;
  wire                    afb1_slv_l2db_cleaned_tc4;
  wire                    afb2_slv_l2db_cleaned_tc4;
  wire                    afb3_slv_l2db_cleaned_tc4;
  wire                    afb4_slv_l2db_cleaned_tc4;
  wire                    afb5_slv_l2db_cleaned_tc4;
  wire                    afb0_master_active;
  wire                    afb1_master_active;
  wire                    afb2_master_active;
  wire                    afb3_master_active;
  wire                    afb4_master_active;
  wire                    afb5_master_active;
  wire                    afb0_ramctl_active;
  wire                    afb1_ramctl_active;
  wire                    afb2_ramctl_active;
  wire                    afb3_ramctl_active;
  wire                    afb4_ramctl_active;
  wire                    afb5_ramctl_active;
  wire                    afb0_dvm_sync_tc3;
  wire                    afb1_dvm_sync_tc3;
  wire                    afb2_dvm_sync_tc3;
  wire                    afb3_dvm_sync_tc3;
  wire                    afb4_dvm_sync_tc3;
  wire                    afb5_dvm_sync_tc3;
  wire                    afb0_snp_dvm_sync_tc4;
  wire                    afb1_snp_dvm_sync_tc4;
  wire                    afb2_snp_dvm_sync_tc4;
  wire                    afb3_snp_dvm_sync_tc4;
  wire                    afb4_snp_dvm_sync_tc4;
  wire                    afb5_snp_dvm_sync_tc4;
  wire [3:0]              afb0_cpu_dvm_sync_tc4;
  wire [3:0]              afb1_cpu_dvm_sync_tc4;
  wire [3:0]              afb2_cpu_dvm_sync_tc4;
  wire [3:0]              afb3_cpu_dvm_sync_tc4;
  wire [3:0]              afb4_cpu_dvm_sync_tc4;
  wire [3:0]              afb5_cpu_dvm_sync_tc4;
  wire [3:0]              afb0_smp_en;
  wire [3:0]              afb1_smp_en;
  wire [3:0]              afb2_smp_en;
  wire [3:0]              afb3_smp_en;
  wire [3:0]              afb4_smp_en;
  wire [3:0]              afb5_smp_en;
  wire [3:0]              ecc_smp_en;
  wire [3:0]              afb0_dvm_complete;
  wire [3:0]              afb1_dvm_complete;
  wire [3:0]              afb2_dvm_complete;
  wire [3:0]              afb3_dvm_complete;
  wire [3:0]              afb4_dvm_complete;
  wire [3:0]              afb5_dvm_complete;
  wire                    afb0_tagctl_valid_tc0;
  wire                    afb1_tagctl_valid_tc0;
  wire                    afb2_tagctl_valid_tc0;
  wire                    afb3_tagctl_valid_tc0;
  wire                    afb4_tagctl_valid_tc0;
  wire                    afb5_tagctl_valid_tc0;
  wire                    tagctl_afb0_ready_tc0;
  wire                    tagctl_afb1_ready_tc0;
  wire                    tagctl_afb2_ready_tc0;
  wire                    tagctl_afb3_ready_tc0;
  wire                    tagctl_afb4_ready_tc0;
  wire                    tagctl_afb5_ready_tc0;
  wire [40:0]             afb0_tagctl_addr1_tc0;
  wire [40:0]             afb1_tagctl_addr1_tc0;
  wire [40:0]             afb2_tagctl_addr1_tc0;
  wire [40:0]             afb3_tagctl_addr1_tc0;
  wire [40:0]             afb4_tagctl_addr1_tc0;
  wire [40:0]             afb5_tagctl_addr1_tc0;
  wire                    afb0_tagctl_addr13_tc0;
  wire                    afb1_tagctl_addr13_tc0;
  wire                    afb2_tagctl_addr13_tc0;
  wire                    afb3_tagctl_addr13_tc0;
  wire                    afb4_tagctl_addr13_tc0;
  wire                    afb5_tagctl_addr13_tc0;
  wire [16:0]             afb0_tagctl_wr_state_tc0;
  wire [16:0]             afb1_tagctl_wr_state_tc0;
  wire [16:0]             afb2_tagctl_wr_state_tc0;
  wire [16:0]             afb3_tagctl_wr_state_tc0;
  wire [16:0]             afb4_tagctl_wr_state_tc0;
  wire [16:0]             afb5_tagctl_wr_state_tc0;
  wire [34:0]             afb0_tagctl_ecc_tc0;
  wire [34:0]             afb1_tagctl_ecc_tc0;
  wire [34:0]             afb2_tagctl_ecc_tc0;
  wire [34:0]             afb3_tagctl_ecc_tc0;
  wire [34:0]             afb4_tagctl_ecc_tc0;
  wire [34:0]             afb5_tagctl_ecc_tc0;
  wire [31:0]             afb0_tagctl_ways_tc0;
  wire [31:0]             afb1_tagctl_ways_tc0;
  wire [31:0]             afb2_tagctl_ways_tc0;
  wire [31:0]             afb3_tagctl_ways_tc0;
  wire [31:0]             afb4_tagctl_ways_tc0;
  wire [31:0]             afb5_tagctl_ways_tc0;
  wire [4:0]              afb0_tagctl_type_tc0;
  wire [4:0]              afb1_tagctl_type_tc0;
  wire [4:0]              afb2_tagctl_type_tc0;
  wire [4:0]              afb3_tagctl_type_tc0;
  wire [4:0]              afb4_tagctl_type_tc0;
  wire [4:0]              afb5_tagctl_type_tc0;
  wire [3:0]              afb0_tagctl_requestor_tc0;
  wire [3:0]              afb1_tagctl_requestor_tc0;
  wire [3:0]              afb2_tagctl_requestor_tc0;
  wire [3:0]              afb3_tagctl_requestor_tc0;
  wire [3:0]              afb4_tagctl_requestor_tc0;
  wire [3:0]              afb5_tagctl_requestor_tc0;
  wire [40:0]             afb0_tagctl_addr2_tc1;
  wire [40:0]             afb1_tagctl_addr2_tc1;
  wire [40:0]             afb2_tagctl_addr2_tc1;
  wire [40:0]             afb3_tagctl_addr2_tc1;
  wire [40:0]             afb4_tagctl_addr2_tc1;
  wire [40:0]             afb5_tagctl_addr2_tc1;
  wire [3:0]              gov_smp_en;
  wire [8:0]              tagctl_mbistarray;
  wire                    ecc_in_progress;
  wire                    ecc_tagctl_valid_tc0;
  wire                    ecc_tagctl_wr_tc0;
  wire                    ecc_tagctl_l2_tc0;
  wire [10:0]             ecc_tagctl_index_tc0;
  wire [31:0]             ecc_tagctl_ways_tc0;
  wire [39:0]             ecc_tagctl_wr_data_tc0;
  wire [3:0]              ecc_tagctl_pass_tc0;

  // Tie off used for configurable logic.
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  assign tagctl_active = (valid_tc1 | valid_tc2 | valid_tc3 | valid_tc4 |
                          afb0_valid | afb1_valid | afb2_valid | afb3_valid |
                          afb4_valid | afb5_valid |
                          (|inval_tags_tc0) |
                          leaving_reset_i |
                          ecc_in_progress |
                          gov_mbistreq_i);

  assign tagctl_active_o = tagctl_active;

  // Indicate to the master when we might me making a request in the next cycle.
  assign tagctl_master_active_o = (afb0_master_active |
                                   afb1_master_active |
                                   afb2_master_active |
                                   afb3_master_active |
                                   afb4_master_active |
                                   afb5_master_active);

  // Avoid clocking tc2 to tc4 and the AFBs if there are no requests. tc1 cannot
  // be gated with this because requests might arrive directly from the BIU
  // before we have time to wake up.
  assign next_clk_enable = tagctl_active | valid_tc0;

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b1;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate (
    .clk_i         (clk),
    .clk_enable_i  (clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_tagctl));

  assign next_clk_enable_early_tc1 = (cpuslv0_active_i |
                                      cpuslv1_active_i |
                                      cpuslv2_active_i |
                                      cpuslv3_active_i |
                                      acpslv_active_i |
                                      snpslv_active_i |
                                      inval_active);

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    clk_enable_early_tc1 <= 1'b0;
  end else begin
    clk_enable_early_tc1 <= next_clk_enable_early_tc1;
  end

  assign clk_enable_tc1 = (clk_enable_early_tc1 |
                           cpuslv0_tagctl_spec_valid_tc0_i |
                           cpuslv1_tagctl_spec_valid_tc0_i |
                           cpuslv2_tagctl_spec_valid_tc0_i |
                           cpuslv3_tagctl_spec_valid_tc0_i |
                           acpslv_tagctl_active_tc0_i |
                           snpslv_tagctl_active_tc0_i);

  ca53_cell_inter_clkgate u_inter_clkgate_tc1 (
    .clk_i         (CLKIN),
    .clk_enable_i  (clk_enable_tc1),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_tc1));


  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    tagctl_mbistreq <= 1'b0;
  end else if (leaving_reset_i) begin
    tagctl_mbistreq <= gov_mbistreq_i;
  end

  always @(posedge clk_tagctl)
  if (leaving_reset_i) begin
    tagctl_l1_dc_size          <= config_l1_dc_size_i;
    tagctl_broadcastinner      <= config_broadcastinner_i;
    tagctl_broadcastouter      <= config_broadcastouter_i;
    tagctl_broadcastcachemaint <= config_broadcastcachemaint_i;
  end

  generate if (L2_CACHE) begin : g_l2cc_size

    always @(posedge clk_tagctl)
    if (leaving_reset_i) begin
      tagctl_l2_size <= config_l2_size_i;
    end

  end else begin : g_n_l2cc_size

    always @*
      tagctl_l2_size = {4{zero}};

  end endgenerate

  //----------------------------------------------------------------------------
  //  WFI logic for CPUs
  //----------------------------------------------------------------------------

  // We must prevent a CPU going into WFI if it has taken itself out of
  // coherency, but we have a transaction in progress that might need to snoop
  // into the CPU (and hence power must not be removed to the CPU until the
  // snoop has completed). Transactions that start after the CPU has cleared
  // smp_en will not want to snoop, unless they are from the requestor CPU.

  assign gov_smp_en = {gov_cpu3_smp_en_i & (NUM_CPUS > 3),
                       gov_cpu2_smp_en_i & (NUM_CPUS > 2),
                       gov_cpu1_smp_en_i & (NUM_CPUS > 1),
                       gov_cpu0_smp_en_i & (NUM_CPUS > 0)};

  assign tagctl_wfx_ready_o = (gov_smp_en |
                               ~({cpuslv3_wfx_active_i,
                                  cpuslv2_wfx_active_i,
                                  cpuslv1_wfx_active_i,
                                  cpuslv0_wfx_active_i} |
                                 ({4{valid_tc1}} & smp_en_tc1) |
                                 ({4{afb0_valid}} & afb0_smp_en) |
                                 ({4{afb1_valid}} & afb1_smp_en) |
                                 ({4{afb2_valid}} & afb2_smp_en) |
                                 ({4{afb3_valid}} & afb3_smp_en) |
                                 ({4{afb4_valid}} & afb4_smp_en) |
                                 ({4{afb5_valid}} & afb5_smp_en) |
                                 ecc_smp_en));

  //----------------------------------------------------------------------------
  //  tc0
  //----------------------------------------------------------------------------

  // In tc0, we arbitrate between all request buffers in the cpuslv, acpslv and
  // snpslv. Arbitration between request buffers in the same slv is done within
  // the slv.
  assign slv_valid_req_tc0 = {snpslv_tagctl_valid_tc0_i,
                              acpslv_tagctl_valid_tc0_i,
                              cpuslv3_tagctl_valid_tc0_i,
                              cpuslv2_tagctl_valid_tc0_i,
                              cpuslv1_tagctl_valid_tc0_i,
                              cpuslv0_tagctl_valid_tc0_i};

  // The slv provides an early request if it has a non-speculative request
  // waiting.
  assign slv_early_req_tc0 = {snpslv_tagctl_early_valid_tc0_i,
                              acpslv_tagctl_early_valid_tc0_i,
                              cpuslv3_tagctl_early_valid_tc0_i,
                              cpuslv2_tagctl_early_valid_tc0_i,
                              cpuslv1_tagctl_early_valid_tc0_i,
                              cpuslv0_tagctl_early_valid_tc0_i};

  // The slv provides a speculative request if it does not have an early
  // request, but may be getting a new request this cycle from the BIU.
  assign slv_spec_req_tc0 = {snpslv_tagctl_spec_valid_tc0_i,
                             acpslv_tagctl_spec_valid_tc0_i,
                             cpuslv3_tagctl_spec_valid_tc0_i,
                             cpuslv2_tagctl_spec_valid_tc0_i,
                             cpuslv1_tagctl_spec_valid_tc0_i,
                             cpuslv0_tagctl_spec_valid_tc0_i};

  assign afb_tagctl_valid_tc0 = {afb5_tagctl_valid_tc0,
                                 afb4_tagctl_valid_tc0,
                                 afb3_tagctl_valid_tc0,
                                 afb2_tagctl_valid_tc0,
                                 afb1_tagctl_valid_tc0,
                                 afb0_tagctl_valid_tc0};

  // Force the arbitration output if we do not want any slv requests.
  // ECC and MBIST have highest priority (and are mutually exclusive), follwed
  // by the AFBs.
  assign force_ecc_mbist_arb_tc0 = ecc_in_progress | tagctl_mbistreq;

  assign force_arb_tc0 = |afb_tagctl_valid_tc0 | force_ecc_mbist_arb_tc0;

  assign afb_req_tc0 = afb_tagctl_valid_tc0 & ~{6{force_ecc_mbist_arb_tc0}};

  assign afb_rr_en_tc0 = |afb_req_tc0;

  ca53_rr_reg_arb #(.WIDTH(6)) u_afb_arb (
    .clk        (clk_tagctl),
    .reset_n    (reset_n),
    .enable_i   (afb_rr_en_tc0),
    .requests_i (afb_req_tc0),
    .arb_o      (afb_grant_tc0)
  );

  assign tagctl_afb0_ready_tc0 = afb_grant_tc0[0] & ~flush_tc0;
  assign tagctl_afb1_ready_tc0 = afb_grant_tc0[1] & ~flush_tc0;
  assign tagctl_afb2_ready_tc0 = afb_grant_tc0[2] & ~flush_tc0;
  assign tagctl_afb3_ready_tc0 = afb_grant_tc0[3] & ~flush_tc0;
  assign tagctl_afb4_ready_tc0 = afb_grant_tc0[4] & ~flush_tc0;
  assign tagctl_afb5_ready_tc0 = afb_grant_tc0[5] & ~flush_tc0;

  // Arbitrate between all slaves making an early request. Only if none of then
  // are making an early request, then include speculative requests as well.
  assign slv_req_tc0 = ((slv_early_req_tc0 & ~{6{force_arb_tc0}}) |
                        (slv_spec_req_tc0 & ~{6{|slv_early_req_tc0 | force_arb_tc0}}));



  // If any pipe stage is being flushed, then don't arbitrate anything new in
  // tc0. Although only initial passes must be flushed, we don't know early
  // enough if the arbitrated request is on its initial pass.
  assign flush_tc0 = (flush_tc1 | flush_tc2 | flush_tc3 | flush_tc4) & ~tagctl_mbistreq;

  // Compress the request down to only those that can be active.
  // Snoop requests get higher priority than other requests, as several other
  // masters may be sharing the snoop channel, and the snoop latency can
  // become critical.
  assign lfsr_req_tc0 = {slv_req_tc0[5], slv_req_tc0[5:ACP ? 4 : 5], slv_req_tc0[NUM_CPUS-1:0]};

  // The arbiter must not be enabled if tc0 is being flushed, as the request in
  // tc0 could then be starved.
  assign lfsr_enable_tc0 = |lfsr_req_tc0 & ~flush_tc0;

  ca53scu_lfsr_arb #(.WIDTH(NUM_CPUS + ACP + 2)) u_reqarb (
    .clk      (clk_tc1),
    .reset_n  (reset_n),
    .enable_i (lfsr_enable_tc0),
    .req_i    (lfsr_req_tc0),
    .grant_o  (lfsr_grant_tc0)
  );

  // Decompress the granted slv.
  generate for (i = 0; i < 4; i = i + 1) begin : g_cpu_arb
    if (i < NUM_CPUS) begin : g_cpu
      assign slv_grant_tc0[i] = lfsr_grant_tc0[i];
    end else begin : g_n_cpu
      assign slv_grant_tc0[i] = 1'b0;
    end
  end endgenerate

  generate if (ACP) begin : g_acp
    assign slv_grant_tc0[5:4] = {|lfsr_grant_tc0[NUM_CPUS+2:NUM_CPUS+1], lfsr_grant_tc0[NUM_CPUS]};
  end else begin : g_n_acp
    assign slv_grant_tc0[5:4] = {|lfsr_grant_tc0[NUM_CPUS+1:NUM_CPUS], 1'b0};
  end endgenerate

  assign slv_grant_tc0[6] = ecc_tagctl_valid_tc0 & ~tagctl_mbistreq;
  assign slv_grant_tc0[7] = tagctl_mbistreq;
  assign slv_grant_tc0[13:8] = afb_grant_tc0;

  assign valid_tc0 = |({8'b11111111, slv_valid_req_tc0} & slv_grant_tc0);

  assign tagctl_cpuslv0_ready_tc0_o = slv_grant_tc0[0] & ~flush_tc0;
  assign tagctl_cpuslv1_ready_tc0_o = slv_grant_tc0[1] & ~flush_tc0;
  assign tagctl_cpuslv2_ready_tc0_o = slv_grant_tc0[2] & ~flush_tc0;
  assign tagctl_cpuslv3_ready_tc0_o = slv_grant_tc0[3] & ~flush_tc0;
  assign tagctl_acpslv_ready_tc0_o  = slv_grant_tc0[4] & ~flush_tc0;
  assign tagctl_snpslv_ready_tc0_o  = slv_grant_tc0[5] & ~flush_tc0;

  // MBIST enables are based on the array, or if we are in ALL mode.
  assign mbist_tagram_en_tc0 = ({32{gov_mbistreaden0_i | gov_mbistwriteen0_i}} &
                                ({32{gov_mbistcfg0_i}} |
                                 {{16{tagctl_mbistarray[6:4] == 3'b011}} & (16'h0001 << tagctl_mbistarray[3:0]),
                                  {4{tagctl_mbistarray[8:2] == 7'b1110000}} & (4'h1 << tagctl_mbistarray[1:0]),
                                  {4{tagctl_mbistarray[8:2] == 7'b1010000}} & (4'h1 << tagctl_mbistarray[1:0]),
                                  {4{tagctl_mbistarray[8:2] == 7'b0110000}} & (4'h1 << tagctl_mbistarray[1:0]),
                                  {4{tagctl_mbistarray[8:2] == 7'b0010000}} & (4'h1 << tagctl_mbistarray[1:0])}));

  // Construct the address from the index and tag, so that it can use the
  // functional data path to extract the parts in the following cycle.
  assign mbist_addr_tc0 = (tagctl_mbistarray[6:4] == 3'b011) ? {gov_mbistindata0_i[27:4],
                                                                (gov_mbistindata0_i[3:0] & ~tagctl_l2_size) |
                                                                (gov_mbistaddr0_i[10:7]  &  tagctl_l2_size),
                                                                gov_mbistaddr0_i[6:0], {6{1'b0}}} :
                                                               {gov_mbistindata0_i[29:3],
                                                                (gov_mbistindata0_i[2:0] & ~tagctl_l1_dc_size) |
                                                                (gov_mbistaddr0_i[7:5]   &  tagctl_l1_dc_size),
                                                                gov_mbistaddr0_i[4:0], {6{1'b0}}};

  assign ecc_addr_tc0 = ecc_tagctl_l2_tc0 ? {ecc_tagctl_wr_data_tc0[27:4],
                                             (ecc_tagctl_wr_data_tc0[3:0] & ~tagctl_l2_size) |
                                             (ecc_tagctl_index_tc0[10:7]  &  tagctl_l2_size),
                                             ecc_tagctl_index_tc0[6:0], {6{1'b0}}} :
                                            {ecc_tagctl_wr_data_tc0[29:3],
                                             (ecc_tagctl_wr_data_tc0[2:0] & ~tagctl_l1_dc_size) |
                                             (ecc_tagctl_index_tc0[7:5]   &  tagctl_l1_dc_size),
                                             ecc_tagctl_index_tc0[4:0], {6{1'b0}}};

  // Mux the information from the slvs based on which one was arbitrated.
  assign req_id_tc0 = (({6{slv_grant_tc0[13]}} & 6'b111101) |
                       ({6{slv_grant_tc0[12]}} & 6'b111100) |
                       ({6{slv_grant_tc0[11]}} & 6'b111011) |
                       ({6{slv_grant_tc0[10]}} & 6'b111010) |
                       ({6{slv_grant_tc0[9]}}  & 6'b111001) |
                       ({6{slv_grant_tc0[8]}}  & 6'b111000) |
                       ({6{slv_grant_tc0[6]}}  & 6'b111111) |
                       ({6{slv_grant_tc0[5]}}  & {3'b101, snpslv_tagctl_reqbufid_tc0_i}) |
                       ({6{slv_grant_tc0[4]}}  & {3'b100, acpslv_tagctl_reqbufid_tc0_i}) |
                       ({6{slv_grant_tc0[3]}}  & {3'b011, cpuslv3_tagctl_reqbufid_tc0_i}) |
                       ({6{slv_grant_tc0[2]}}  & {3'b010, cpuslv2_tagctl_reqbufid_tc0_i}) |
                       ({6{slv_grant_tc0[1]}}  & {3'b001, cpuslv1_tagctl_reqbufid_tc0_i}) |
                       ({6{slv_grant_tc0[0]}}  & {3'b000, cpuslv0_tagctl_reqbufid_tc0_i}));

  assign req_pass_tc0 = (({4{|slv_grant_tc0[13:8]}} & `CA53_TAGCTL_PASS_VICTIM) |
                         ({4{slv_grant_tc0[6]}}     & ecc_tagctl_pass_tc0) |
                         ({4{slv_grant_tc0[5]}}     &  snpslv_tagctl_pass_tc0_i) |
                         ({4{slv_grant_tc0[4]}}     &  acpslv_tagctl_pass_tc0_i) |
                         ({4{slv_grant_tc0[3]}}     & cpuslv3_tagctl_pass_tc0_i) |
                         ({4{slv_grant_tc0[2]}}     & cpuslv2_tagctl_pass_tc0_i) |
                         ({4{slv_grant_tc0[1]}}     & cpuslv1_tagctl_pass_tc0_i) |
                         ({4{slv_grant_tc0[0]}}     & cpuslv0_tagctl_pass_tc0_i));

  assign req_addr_tc0 = (({42{slv_grant_tc0[13]}} & {1'b0, afb5_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[12]}} & {1'b0, afb4_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[11]}} & {1'b0, afb3_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[10]}} & {1'b0, afb2_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[9]}}  & {1'b0, afb1_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[8]}}  & {1'b0, afb0_tagctl_addr1_tc0}) |
                         ({42{slv_grant_tc0[7]}}  & {1'b0, mbist_addr_tc0}) |
                         ({42{slv_grant_tc0[6]}}  & {1'b0, ecc_addr_tc0}) |
                         ({42{slv_grant_tc0[5]}}  & snpslv_tagctl_addr1_tc0_i) |
                         ({42{slv_grant_tc0[4]}}  & {1'b0,  acpslv_tagctl_addr1_tc0_i}) |
                         ({42{slv_grant_tc0[3]}}  & {1'b0, cpuslv3_tagctl_addr1_tc0_i}) |
                         ({42{slv_grant_tc0[2]}}  & {1'b0, cpuslv2_tagctl_addr1_tc0_i}) |
                         ({42{slv_grant_tc0[1]}}  & {1'b0, cpuslv1_tagctl_addr1_tc0_i}) |
                         ({42{slv_grant_tc0[0]}}  & {1'b0, cpuslv0_tagctl_addr1_tc0_i}));

  assign req_addr13_tc0 = ((slv_grant_tc0[13] & afb5_tagctl_addr13_tc0) |
                           (slv_grant_tc0[12] & afb4_tagctl_addr13_tc0) |
                           (slv_grant_tc0[11] & afb3_tagctl_addr13_tc0) |
                           (slv_grant_tc0[10] & afb2_tagctl_addr13_tc0) |
                           (slv_grant_tc0[9]  & afb1_tagctl_addr13_tc0) |
                           (slv_grant_tc0[8]  & afb0_tagctl_addr13_tc0) |
                           (slv_grant_tc0[7]  & gov_mbistaddr0_i[7]) |
                           (slv_grant_tc0[6]  & ecc_tagctl_index_tc0[7]) |
                           (slv_grant_tc0[5]  &  snpslv_tagctl_addr1_tc0_i[13]) |
                           (slv_grant_tc0[4]  &  acpslv_tagctl_addr1_tc0_i[13]) |
                           (slv_grant_tc0[3]  & cpuslv3_tagctl_addr1_tc0_i[13]) |
                           (slv_grant_tc0[2]  & cpuslv2_tagctl_addr1_tc0_i[13]) |
                           (slv_grant_tc0[1]  & cpuslv1_tagctl_addr1_tc0_i[13]) |
                           (slv_grant_tc0[0]  & cpuslv0_tagctl_addr1_tc0_i[13]));

  assign req_dvm_sync_tc0 = ((slv_grant_tc0[5]  &  snpslv_tagctl_dvm_sync_tc0_i) |
                             (slv_grant_tc0[3]  & cpuslv3_tagctl_dvm_sync_tc0_i) |
                             (slv_grant_tc0[2]  & cpuslv2_tagctl_dvm_sync_tc0_i) |
                             (slv_grant_tc0[1]  & cpuslv1_tagctl_dvm_sync_tc0_i) |
                             (slv_grant_tc0[0]  & cpuslv0_tagctl_dvm_sync_tc0_i));

  assign req_wr_state_tc0 = (({17{slv_grant_tc0[13]}} & afb5_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[12]}} & afb4_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[11]}} & afb3_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[10]}} & afb2_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[9]}}  & afb1_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[8]}}  & afb0_tagctl_wr_state_tc0) |
                             ({17{slv_grant_tc0[7]}}  & {gov_mbistindata0_i[32:28],
                                                         {4{gov_mbistindata0_i[32:30]}}}) |
                             ({17{slv_grant_tc0[6]}}  & {ecc_tagctl_wr_data_tc0[32:28],
                                                         {4{ecc_tagctl_wr_data_tc0[32:30]}}}) |
                             ({17{slv_grant_tc0[5]}}  &  snpslv_tagctl_wr_state_tc0_i) |
                             ({17{slv_grant_tc0[4]}}  &  acpslv_tagctl_wr_state_tc0_i) |
                             ({17{slv_grant_tc0[3]}}  & cpuslv3_tagctl_wr_state_tc0_i) |
                             ({17{slv_grant_tc0[2]}}  & cpuslv2_tagctl_wr_state_tc0_i) |
                             ({17{slv_grant_tc0[1]}}  & cpuslv1_tagctl_wr_state_tc0_i) |
                             ({17{slv_grant_tc0[0]}}  & cpuslv0_tagctl_wr_state_tc0_i));

  assign req_ecc_tc0 = (({35{slv_grant_tc0[13]}} & afb5_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[12]}} & afb4_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[11]}} & afb3_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[10]}} & afb2_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[9]}}  & afb1_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[8]}}  & afb0_tagctl_ecc_tc0) |
                        ({35{slv_grant_tc0[7]}}  & {5{gov_mbistindata0_i[39:33]}}) |
                        ({35{slv_grant_tc0[6]}}  & {5{ecc_tagctl_wr_data_tc0[39:33]}}) |
                        ({35{slv_grant_tc0[5]}}  &  snpslv_tagctl_ecc_tc0_i) |
                        ({35{slv_grant_tc0[4]}}  &  acpslv_tagctl_ecc_tc0_i) |
                        ({35{slv_grant_tc0[3]}}  & cpuslv3_tagctl_ecc_tc0_i) |
                        ({35{slv_grant_tc0[2]}}  & cpuslv2_tagctl_ecc_tc0_i) |
                        ({35{slv_grant_tc0[1]}}  & cpuslv1_tagctl_ecc_tc0_i) |
                        ({35{slv_grant_tc0[0]}}  & cpuslv0_tagctl_ecc_tc0_i));

  assign req_ways_tc0 = ((inval_tag_ways_tc0 & ~{32{l2_in_retention}}) |
                         ({32{slv_grant_tc0[13]}} & afb5_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[12]}} & afb4_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[11]}} & afb3_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[10]}} & afb2_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[9]}}  & afb1_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[8]}}  & afb0_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[7]}}  & mbist_tagram_en_tc0) |
                         ({32{slv_grant_tc0[6]}}  & ecc_tagctl_ways_tc0) |
                         ({32{slv_grant_tc0[5]}}  &  snpslv_tagctl_ways_tc0_i) |
                         ({32{slv_grant_tc0[4]}}  &  acpslv_tagctl_ways_tc0_i) |
                         ({32{slv_grant_tc0[3]}}  & cpuslv3_tagctl_ways_tc0_i) |
                         ({32{slv_grant_tc0[2]}}  & cpuslv2_tagctl_ways_tc0_i) |
                         ({32{slv_grant_tc0[1]}}  & cpuslv1_tagctl_ways_tc0_i) |
                         ({32{slv_grant_tc0[0]}}  & cpuslv0_tagctl_ways_tc0_i));

  assign req_write_tc0 = (inval_tags_tc0 |
                          ({5{|slv_grant_tc0[13:8]}} & 5'b10000) |
                          ({5{slv_grant_tc0[7]}}     & {5{gov_mbistwriteen0_i}}) |
                          ({5{slv_grant_tc0[6]}}     & {5{ecc_tagctl_wr_tc0}}) |
                          ({5{slv_grant_tc0[5]}}     &  snpslv_tagctl_write_tc0_i) |
                          ({5{slv_grant_tc0[4]}}     &  acpslv_tagctl_write_tc0_i) |
                          ({5{slv_grant_tc0[3]}}     & cpuslv3_tagctl_write_tc0_i) |
                          ({5{slv_grant_tc0[2]}}     & cpuslv2_tagctl_write_tc0_i) |
                          ({5{slv_grant_tc0[1]}}     & cpuslv1_tagctl_write_tc0_i) |
                          ({5{slv_grant_tc0[0]}}     & cpuslv0_tagctl_write_tc0_i));

  assign req_type_tc0 = (({6{slv_grant_tc0[13]}} & {1'b0,    afb5_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[12]}} & {1'b0,    afb4_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[11]}} & {1'b0,    afb3_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[10]}} & {1'b0,    afb2_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[9]}}  & {1'b0,    afb1_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[8]}}  & {1'b0,    afb0_tagctl_type_tc0}) |
                         ({6{slv_grant_tc0[5]}}  & {1'b1,  snpslv_tagctl_type_tc0_i}) |
                         ({6{slv_grant_tc0[4]}}  & {1'b0,  acpslv_tagctl_type_tc0_i}) |
                         ({6{slv_grant_tc0[3]}}  & {1'b0, cpuslv3_tagctl_type_tc0_i}) |
                         ({6{slv_grant_tc0[2]}}  & {1'b0, cpuslv2_tagctl_type_tc0_i}) |
                         ({6{slv_grant_tc0[1]}}  & {1'b0, cpuslv1_tagctl_type_tc0_i}) |
                         ({6{slv_grant_tc0[0]}}  & {1'b0, cpuslv0_tagctl_type_tc0_i}));

  assign req_l2flushreq_tc0 = ((slv_grant_tc0[3] & cpuslv3_tagctl_l2flushreq_tc0_i) |
                               (slv_grant_tc0[2] & cpuslv2_tagctl_l2flushreq_tc0_i) |
                               (slv_grant_tc0[1] & cpuslv1_tagctl_l2flushreq_tc0_i) |
                               (slv_grant_tc0[0] & cpuslv0_tagctl_l2flushreq_tc0_i));

  assign force_smp_en_tc0 = slv_grant_tc0[3:0] & ~{cpuslv3_tagctl_l2flushreq_tc0_i,
                                                   cpuslv2_tagctl_l2flushreq_tc0_i,
                                                   cpuslv1_tagctl_l2flushreq_tc0_i,
                                                   cpuslv0_tagctl_l2flushreq_tc0_i};

  // smp_en is implicitly set for the CPU making a request, to ensure that it
  // can snoop itself if required.
  assign smp_en_tc0 = (gov_smp_en | force_smp_en_tc0 |
                       ({4{slv_grant_tc0[13]}} & afb5_tagctl_requestor_tc0) |
                       ({4{slv_grant_tc0[12]}} & afb4_tagctl_requestor_tc0) |
                       ({4{slv_grant_tc0[11]}} & afb3_tagctl_requestor_tc0) |
                       ({4{slv_grant_tc0[10]}} & afb2_tagctl_requestor_tc0) |
                       ({4{slv_grant_tc0[9]}}  & afb1_tagctl_requestor_tc0) |
                       ({4{slv_grant_tc0[8]}}  & afb0_tagctl_requestor_tc0));

  // Tell the slv we can only accept non-coherent requests if we will not be
  // able to access some tag banks that coherent requests may need to read or
  // write. Lookups do not matter, because a tag being invalidated will be
  // forced to miss.
  assign tagctl_cpuslv0_noncoh_only_o = inval_tags_tc0[0] | inval_tags_tc0[4];
  assign tagctl_cpuslv1_noncoh_only_o = inval_tags_tc0[1] | inval_tags_tc0[4];
  assign tagctl_cpuslv2_noncoh_only_o = inval_tags_tc0[2] | inval_tags_tc0[4];
  assign tagctl_cpuslv3_noncoh_only_o = inval_tags_tc0[3] | inval_tags_tc0[4];
  assign tagctl_acpslv_noncoh_only_o  = inval_tags_tc0[4];


  //----------------------------------------------------------------------------
  //  tc1
  //----------------------------------------------------------------------------

  // tc1 flops must use the ungated clock because if a new request is arriving
  // directly from the BIU then the gated clock will not have woken up on the
  // first cycle.
  // Always move the tc0 contents into tc1 unless flushed.
  assign next_valid_tc1 = valid_tc0 & ~flush_tc0;

  always @(posedge clk_tc1 or negedge reset_n)
  if (~reset_n) begin
    valid_tc1 <= 1'b0;
  end else begin
    valid_tc1 <= next_valid_tc1;
  end

  // Which CPU/L2 ways to enable if the request wants them. Registered
  // separately from valid_tc1 to help timing on the RAM enables.
  assign next_valid_ways_tc1 = ((inval_tags_tc0 & ~{5{l2_in_retention}}) |
                                ({5{valid_tc0}} &
                                 ({L2_CACHE != 0, smp_en_tc0 | req_write_tc0[3:0]} |
                                  {5{force_ecc_mbist_arb_tc0}}) &
                                 ~{5{flush_tc0}}));

  always @(posedge clk_tc1 or negedge reset_n)
  if (~reset_n) begin
    valid_ways_tc1 <= 5'b00000;
  end else begin
    valid_ways_tc1 <= next_valid_ways_tc1;
  end

  // Enable tc1 registers speculatively if we might have a new request.
  assign req_tc1_en = ((|slv_req_tc0) |
                       (|afb_req_tc0) |
                       ecc_tagctl_valid_tc0 |
                       inval_active |
                       tagctl_mbistreq);

  // If still in the process of entering retention then there may be a new
  // access that does need to access the RAMs which must not be blocked.
  assign next_tagram_clken_tc1 = (req_tc1_en | inval_active) & ~(l2_reached_retention_i & gov_l2_in_retention_i);

  assign next_slv_grant_comp_tc1 = {slv_grant_tc0[13:8], slv_grant_tc0[5:5-ACP], slv_grant_tc0[NUM_CPUS-1:0]};

  always @(posedge clk_tc1)
  if (req_tc1_en) begin
    req_id_tc1         <= req_id_tc0;
    req_pass_tc1       <= req_pass_tc0;
    req_addr_tc1       <= req_addr_tc0;
    req_addr13_tc1     <= req_addr13_tc0;
    req_dvm_sync_tc1   <= req_dvm_sync_tc0;
    req_wr_state_tc1   <= req_wr_state_tc0;
    req_ways_tc1       <= req_ways_tc0;
    req_type_tc1       <= req_type_tc0;
    req_l2flushreq_tc1 <= req_l2flushreq_tc0;
    smp_en_tc1         <= smp_en_tc0;
    slv_grant_comp_tc1 <= next_slv_grant_comp_tc1;
  end

  // Inject ECC fatal errors on the L2 tag RAMs (req_addr_tc1[18:17]) for the
  // SCU_CACHE_PROTECTION configurations when L2TEIEN is set, MBIST not enable 

  generate if (SCU_CACHE_PROTECTION) begin : g_scu_l2_ecc_tc1

    wire [1:0] next_req_addr_tc1_err;

    assign next_req_addr_tc1_err = req_addr_tc0[18:17] ^ {2{~tagctl_mbistreq & gov_l2teien_i}};

    always @(posedge clk_tc1)
    if (req_tc1_en) begin
      req_addr_tc1_err <= next_req_addr_tc1_err;
    end

  end else begin : g_n_scu_l2_ecc_tc1

    always @*
    begin
      req_addr_tc1_err = req_addr_tc1[18:17];
    end

  end endgenerate

  generate if (ACP) begin : g_acp_gnt
    assign slv_grant_tc1[11:4] = slv_grant_comp_tc1[7+NUM_CPUS:NUM_CPUS];                            
  end else begin : g_n_acp_gnt
    assign slv_grant_tc1[11:4] = {slv_grant_comp_tc1[6+NUM_CPUS:NUM_CPUS], 1'b0};
  end endgenerate

  generate for (i = NUM_CPUS; i < 4; i = i + 1) begin : g_cpus
    assign slv_grant_tc1[i] = 1'b0;
  end endgenerate

  assign slv_grant_tc1[NUM_CPUS-1:0] = slv_grant_comp_tc1[NUM_CPUS-1:0];

  always @(posedge clk_tc1 or negedge reset_n)
  if (~reset_n) begin
    req_write_tc1 <= 5'b00000;
  end else if (req_tc1_en) begin
    req_write_tc1 <= req_write_tc0;
  end

  always @(posedge clk_tc1 or negedge reset_n)
  if (~reset_n) begin
    tagram_clken_tc1 <= 1'b1;
  end else begin
    tagram_clken_tc1 <= next_tagram_clken_tc1;
  end

  generate if (CPU_CACHE_PROTECTION) begin : g_cpu_ecc_tc1

    always @(posedge clk_tc1)
    if (req_tc1_en) begin
      req_ecc_tc1[27:0] <= req_ecc_tc0[27:0];
    end

  end else begin : g_n_cpu_ecc_tc1

    always @*
      req_ecc_tc1[27:0] = {28{zero}};

  end endgenerate

  generate if (SCU_CACHE_PROTECTION) begin : g_scu_ecc_tc1

    always @(posedge clk_tc1)
    if (req_tc1_en) begin
      req_ecc_tc1[34:28] <= req_ecc_tc0[34:28];
    end

  end else begin : g_n_scu_ecc_tc1

    always @*
      req_ecc_tc1[34:28] = {7{zero}};

  end endgenerate

  // Flush if there is no AFB available. Also flush if there is no L2DB and it
  // is definitely needed. If it will not be known if one is needed then defer
  // the flush until tc3 when it will be known, in order to avoid flushing
  // unnecessarily.
  assign flush_tc1 = (valid_tc1 &
                      ((afb_required_tc1 & ~afb_available_tc1) |
                       (alloc_l2db_for_write_tc1 &
                        (~allow_unserialised_l2db_tc1 |
                         ~first_l2db_avail_for_write_tc1)) |
                       (alloc_l2db_for_acp_read_tc1 & ~first_l2db_avail_for_acp_read_tc1) |
                       ((req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) &
                        (flush_raw_tc2 |
                         flush_raw_tc3 |
                         (flush_tc4 & ~(l2db_flush_tc4 & `CA53_REQBUF_IS_SNOOP(req_id_tc1)))))));

  assign tagctl_slv_flush_tc1_o = flush_tc1;

  // Mux the remaining attributes from the slaves, that weren't needed in tc0.

  // ACP does not support DVMs, or L1 victims, and so has no need to provide
  // the second address.
  assign req_addr2_tc1 = (({41{slv_grant_tc1[11]}} &    afb5_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[10]}} &    afb4_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[9]}}  &    afb3_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[8]}}  &    afb2_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[7]}}  &    afb1_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[6]}}  &    afb0_tagctl_addr2_tc1) |
                          ({41{slv_grant_tc1[5]}}  &  snpslv_tagctl_addr2_tc1_i) |
                          ({41{slv_grant_tc1[3]}}  & cpuslv3_tagctl_addr2_tc1_i) |
                          ({41{slv_grant_tc1[2]}}  & cpuslv2_tagctl_addr2_tc1_i) |
                          ({41{slv_grant_tc1[1]}}  & cpuslv1_tagctl_addr2_tc1_i) |
                          ({41{slv_grant_tc1[0]}}  & cpuslv0_tagctl_addr2_tc1_i));

  assign req_id_dcu_tc1 = ((slv_grant_tc1[3] & cpuslv3_tagctl_reqbuf_dcu_tc1_i) |
                           (slv_grant_tc1[2] & cpuslv2_tagctl_reqbuf_dcu_tc1_i) |
                           (slv_grant_tc1[1] & cpuslv1_tagctl_reqbuf_dcu_tc1_i) |
                           (slv_grant_tc1[0] & cpuslv0_tagctl_reqbuf_dcu_tc1_i));

  assign req_len_tc1 = (({2{slv_grant_tc1[4]}} &  acpslv_tagctl_len_tc1_i) |
                        ({2{slv_grant_tc1[3]}} & cpuslv3_tagctl_len_tc1_i) |
                        ({2{slv_grant_tc1[2]}} & cpuslv2_tagctl_len_tc1_i) |
                        ({2{slv_grant_tc1[1]}} & cpuslv1_tagctl_len_tc1_i) |
                        ({2{slv_grant_tc1[0]}} & cpuslv0_tagctl_len_tc1_i));

  assign req_single_tc1 = slv_grant_tc1[4] & acpslv_tagctl_single_tc1_i;

  assign req_size_tc1 = (({3{slv_grant_tc1[5]}} & 3'b100) |
                         ({3{slv_grant_tc1[4]}} &  acpslv_tagctl_size_tc1_i) |
                         ({3{slv_grant_tc1[3]}} & cpuslv3_tagctl_size_tc1_i) |
                         ({3{slv_grant_tc1[2]}} & cpuslv2_tagctl_size_tc1_i) |
                         ({3{slv_grant_tc1[1]}} & cpuslv1_tagctl_size_tc1_i) |
                         ({3{slv_grant_tc1[0]}} & cpuslv0_tagctl_size_tc1_i));

  assign req_lock_tc1 = ((slv_grant_tc1[3] & cpuslv3_tagctl_lock_tc1_i) |
                         (slv_grant_tc1[2] & cpuslv2_tagctl_lock_tc1_i) |
                         (slv_grant_tc1[1] & cpuslv1_tagctl_lock_tc1_i) |
                         (slv_grant_tc1[0] & cpuslv0_tagctl_lock_tc1_i));

  assign req_dirty_tc1 = ((slv_grant_tc1[5] & snpslv_tagctl_dirty_tc1_i) |
                          (slv_grant_tc1[4] & acpslv_tagctl_dirty_tc1_i) |
                          (slv_grant_tc1[3] & cpuslv3_tagctl_dirty_tc1_i) |
                          (slv_grant_tc1[2] & cpuslv2_tagctl_dirty_tc1_i) |
                          (slv_grant_tc1[1] & cpuslv1_tagctl_dirty_tc1_i) |
                          (slv_grant_tc1[0] & cpuslv0_tagctl_dirty_tc1_i));

  assign req_cluster_unique_tc1 = ((slv_grant_tc1[5] & snpslv_tagctl_cluster_unique_tc1_i) |
                                   (slv_grant_tc1[4] & acpslv_tagctl_cluster_unique_tc1_i) |
                                   (slv_grant_tc1[3] & cpuslv3_tagctl_cluster_unique_tc1_i) |
                                   (slv_grant_tc1[2] & cpuslv2_tagctl_cluster_unique_tc1_i) |
                                   (slv_grant_tc1[1] & cpuslv1_tagctl_cluster_unique_tc1_i) |
                                   (slv_grant_tc1[0] & cpuslv0_tagctl_cluster_unique_tc1_i));

  assign req_attrs_tc1 = (({8{slv_grant_tc1[5]}} &  snpslv_tagctl_attrs_tc1_i) |
                          ({8{slv_grant_tc1[4]}} &  acpslv_tagctl_attrs_tc1_i) |
                          ({8{slv_grant_tc1[3]}} & cpuslv3_tagctl_attrs_tc1_i) |
                          ({8{slv_grant_tc1[2]}} & cpuslv2_tagctl_attrs_tc1_i) |
                          ({8{slv_grant_tc1[1]}} & cpuslv1_tagctl_attrs_tc1_i) |
                          ({8{slv_grant_tc1[0]}} & cpuslv0_tagctl_attrs_tc1_i));

  assign req_prot_tc1 = (({2{slv_grant_tc1[4]}} &  acpslv_tagctl_prot_tc1_i) |
                         ({2{slv_grant_tc1[3]}} & cpuslv3_tagctl_prot_tc1_i) |
                         ({2{slv_grant_tc1[2]}} & cpuslv2_tagctl_prot_tc1_i) |
                         ({2{slv_grant_tc1[1]}} & cpuslv1_tagctl_prot_tc1_i) |
                         ({2{slv_grant_tc1[0]}} & cpuslv0_tagctl_prot_tc1_i));

  assign req_l2db_tc1 = (({4{slv_grant_tc1[5]}} &  snpslv_tagctl_l2db_tc1_i) |
                         ({4{slv_grant_tc1[4]}} &  acpslv_tagctl_l2db_tc1_i) |
                         ({4{slv_grant_tc1[3]}} & cpuslv3_tagctl_l2db_tc1_i) |
                         ({4{slv_grant_tc1[2]}} & cpuslv2_tagctl_l2db_tc1_i) |
                         ({4{slv_grant_tc1[1]}} & cpuslv1_tagctl_l2db_tc1_i) |
                         ({4{slv_grant_tc1[0]}} & cpuslv0_tagctl_l2db_tc1_i));

  assign req_l2db_full_tc1 = ((slv_grant_tc1[4] &  acpslv_tagctl_l2db_full_tc1_i) |
                              (slv_grant_tc1[3] & cpuslv3_tagctl_l2db_full_tc1_i) |
                              (slv_grant_tc1[2] & cpuslv2_tagctl_l2db_full_tc1_i) |
                              (slv_grant_tc1[1] & cpuslv1_tagctl_l2db_full_tc1_i) |
                              (slv_grant_tc1[0] & cpuslv0_tagctl_l2db_full_tc1_i));

  assign req_static_pcredit_tc1 = ((slv_grant_tc1[5] &  snpslv_tagctl_static_pcredit_tc1_i) |
                                   (slv_grant_tc1[4] &  acpslv_tagctl_static_pcredit_tc1_i) |
                                   (slv_grant_tc1[3] & cpuslv3_tagctl_static_pcredit_tc1_i) |
                                   (slv_grant_tc1[2] & cpuslv2_tagctl_static_pcredit_tc1_i) |
                                   (slv_grant_tc1[1] & cpuslv1_tagctl_static_pcredit_tc1_i) |
                                   (slv_grant_tc1[0] & cpuslv0_tagctl_static_pcredit_tc1_i));

  assign req_pcrdtype_tc1 = (({2{slv_grant_tc1[5]}} &  snpslv_tagctl_pcrdtype_tc1_i) |
                             ({2{slv_grant_tc1[4]}} &  acpslv_tagctl_pcrdtype_tc1_i) |
                             ({2{slv_grant_tc1[3]}} & cpuslv3_tagctl_pcrdtype_tc1_i) |
                             ({2{slv_grant_tc1[2]}} & cpuslv2_tagctl_pcrdtype_tc1_i) |
                             ({2{slv_grant_tc1[1]}} & cpuslv1_tagctl_pcrdtype_tc1_i) |
                             ({2{slv_grant_tc1[0]}} & cpuslv0_tagctl_pcrdtype_tc1_i));

  assign req_victim_way_tc1 = (({4{slv_grant_tc1[4]}} &  acpslv_tagctl_victim_way_tc1_i) |
                               ({4{slv_grant_tc1[3]}} & cpuslv3_tagctl_victim_way_tc1_i) |
                               ({4{slv_grant_tc1[2]}} & cpuslv2_tagctl_victim_way_tc1_i) |
                               ({4{slv_grant_tc1[1]}} & cpuslv1_tagctl_victim_way_tc1_i) |
                               ({4{slv_grant_tc1[0]}} & cpuslv0_tagctl_victim_way_tc1_i));

  assign acp_slverr_tc1 = slv_grant_tc1[4] & acpslv_tagctl_slverr_tc1_i;

  always @*
  case (req_l2db_tc1)
    4'b0000: req_l2db_rmw_tc1 = l2db0_rmw_line_i;
    4'b0001: req_l2db_rmw_tc1 = l2db1_rmw_line_i;
    4'b0010: req_l2db_rmw_tc1 = l2db2_rmw_line_i;
    4'b0011: req_l2db_rmw_tc1 = l2db3_rmw_line_i;
    4'b0100: req_l2db_rmw_tc1 = l2db4_rmw_line_i;
    4'b0101: req_l2db_rmw_tc1 = l2db5_rmw_line_i;
    4'b0110: req_l2db_rmw_tc1 = l2db6_rmw_line_i;
    4'b0111: req_l2db_rmw_tc1 = l2db7_rmw_line_i;
    4'b1000: req_l2db_rmw_tc1 = l2db8_rmw_line_i;
    4'b1001: req_l2db_rmw_tc1 = l2db9_rmw_line_i;
    4'b1010: req_l2db_rmw_tc1 = l2db10_rmw_line_i;
    default: req_l2db_rmw_tc1 = 1'bx;
  endcase

  // For victim passes, we are writing one tag value and looking up others.
  // Therefore unlike other lookups, in this case the lookup address is provided
  // in addr2. The index used is the same for both however, and so only one
  // address needs providing in tc0 (other than bit 13, which is provided separately).
  assign req_master_addr_tc1 = ((L2_CACHE != 0) &
                                (req_pass_tc1 == `CA53_TAGCTL_PASS_VICTIM) &
                                ~slv_grant_tc1[4]) ? req_addr2_tc1 : req_addr_tc1[40:0];

  assign req_addr1_tc1 = tagctl_mbistreq ? {gov_mbistbe0_i[13:0],
                                            gov_mbistarray0_i, gov_mbistaddr0_i,
                                            1'b0, gov_mbistbe0_i[15:14], gov_mbistcfg0_i,
                                            gov_mbistreaden0_i, gov_mbistwriteen0_i} : req_master_addr_tc1;

  // Only some request passes require an AFB. Requests coming from an AFB or
  // ECC correction must never allocate an AFB.
  assign afb_required_tc1 = (valid_tc1 & (req_id_tc1[5:3] != 3'b111) &
                             ((req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) |
                              (req_pass_tc1 == `CA53_TAGCTL_PASS_LOOKUP) |
                              (req_pass_tc1 == `CA53_TAGCTL_PASS_L2_VICTIM) |
                              (req_pass_tc1 == `CA53_TAGCTL_PASS_MASTER_R) |
                              (req_pass_tc1 == `CA53_TAGCTL_PASS_MASTER_W) |
                              (req_pass_tc1 == `CA53_TAGCTL_PASS_VICTIM)));

  // Because snoops must make forward progress, one AFB must be reserved for
  // snoops or other accesses that are guaranteed to not require a master read access.
  // We also reserve one AFB for snoops, to improve snoop performance
  // when tagctl is congested. This is shared with ReadOnce/ReadNone victim
  // lookups which must make progress even if the ACE write channel is blocked.
  assign afb_available_tc1 = (((~afb0_valid | ~afb1_valid | ~afb2_valid | ~afb3_valid | ~afb4_valid) &
                               (~(((req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) &
                                   ~`CA53_REQBUF_IS_SNOOP(req_id_tc1)) |
                                  (req_pass_tc1 == `CA53_TAGCTL_PASS_MASTER_R)) |
                                (~afb0_requires_master & ~afb1_requires_master) |
                                (~afb0_requires_master & ~afb2_requires_master) |
                                (~afb0_requires_master & ~afb3_requires_master) |
                                (~afb0_requires_master & ~afb4_requires_master) |
                                (~afb1_requires_master & ~afb2_requires_master) |
                                (~afb1_requires_master & ~afb3_requires_master) |
                                (~afb1_requires_master & ~afb4_requires_master) |
                                (~afb2_requires_master & ~afb3_requires_master) |
                                (~afb2_requires_master & ~afb4_requires_master) |
                                (~afb3_requires_master & ~afb4_requires_master))) |
                              (~afb5_valid & (`CA53_REQBUF_IS_SNOOP(req_id_tc1) |
                                              (((req_type_tc1 == `CA53_AFB_REQ_READONCE) |
                                                (req_type_tc1 == `CA53_AFB_REQ_READNONE)) &
                                               (req_pass_tc1 == `CA53_TAGCTL_PASS_LOOKUP)))));

  assign afb_lowest_available_tc1 = ({6{afb_available_tc1}} &
                                     {~afb5_valid & afb0_valid & afb1_valid & afb2_valid & afb3_valid & afb4_valid,
                                      ~afb4_valid & afb0_valid & afb1_valid & afb2_valid & afb3_valid,
                                      ~afb3_valid & afb0_valid & afb1_valid & afb2_valid,
                                      ~afb2_valid & afb0_valid & afb1_valid,
                                      ~afb1_valid & afb0_valid,
                                      ~afb0_valid});

  // Allocate the first free AFB.
  assign alloc_afb0_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[0]) | tagctl_mbistreq;
  assign alloc_afb1_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[1]);
  assign alloc_afb2_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[2]);
  assign alloc_afb3_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[3]);
  assign alloc_afb4_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[4]);
  assign alloc_afb5_tc1 = (afb_required_tc1 & ~flush_tc1 & afb_lowest_available_tc1[5]);

  assign afb_tc1 = {alloc_afb5_tc1, alloc_afb4_tc1, alloc_afb3_tc1, alloc_afb2_tc1, alloc_afb1_tc1, alloc_afb0_tc1};

  // Send the allocated AFB ID to the slaves to that they can track when their AFB is done.
  assign tagctl_slv_afb_tc1_o = {alloc_afb5_tc1 | alloc_afb4_tc1,
                                 alloc_afb3_tc1 | alloc_afb2_tc1,
                                 alloc_afb5_tc1 | alloc_afb3_tc1 | alloc_afb1_tc1};

  // Send the address to the slvs and master for hazard checking.
  assign tagctl_addr_tc1 = {req_addr_tc1[41:14], req_addr13_tc1, req_addr_tc1[12:6]};

  assign tagctl_addr_tc1_o = tagctl_addr_tc1;

  assign tagctl_ecc_way_tc1_o = req_ways_tc1[15:0] & ~{{4{inval_tags_tc1[3]}},
                                                       {4{inval_tags_tc1[2]}},
                                                       {4{inval_tags_tc1[1]}},
                                                       {4{inval_tags_tc1[0]}}};

  assign tagctl_valid_tc1_o = valid_tc1;

  assign tagctl_addr_valid_tc1 = valid_tc1 & ~((req_type_tc1 == `CA53_AFB_REQ_DMB) |
                                               (req_type_tc1 == `CA53_AFB_REQ_DSB) |
                                               (req_type_tc1 == `CA53_AFB_REQ_DVM) |
                                               (req_type_tc1 == `CA53_AFB_SNP_DVM_MESSAGE) |
                                               (req_type_tc1 == `CA53_AFB_SNP_DVM_COMPLETE) |
                                               ((req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) &
                                                ((req_type_tc1 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                                 (req_type_tc1 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                                 (req_type_tc1 == `CA53_AFB_REQ_CLEANSETWAY) |
                                                 (req_type_tc1 == `CA53_AFB_REQ_ECCCLEAN))));

  assign tagctl_addr_valid_tc1_o = tagctl_addr_valid_tc1;

  // The index is valid for all address based operations, and also L2 set/way ops.
  assign tagctl_index_valid_tc1_o = valid_tc1 & ~((req_type_tc1 == `CA53_AFB_REQ_DMB) |
                                                  (req_type_tc1 == `CA53_AFB_REQ_DSB) |
                                                  (req_type_tc1 == `CA53_AFB_REQ_DVM) |
                                                  (req_type_tc1 == `CA53_AFB_SNP_DVM_MESSAGE) |
                                                  (req_type_tc1 == `CA53_AFB_SNP_DVM_COMPLETE) |
                                                  ((req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) &
                                                   ((req_type_tc1 == `CA53_AFB_REQ_ECCCLEAN) |
                                                    (((req_type_tc1 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                                      (req_type_tc1 == `CA53_AFB_REQ_CLEANSETWAY)) & ~req_addr_tc1[1]))));

  // The L1 index must be checked for L1 set/way ops.
  assign tagctl_l1_set_way_op_tc1_o = valid_tc1 & ((req_type_tc1 == `CA53_AFB_REQ_ECCCLEAN) |
                                                   (((req_type_tc1 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                                     (req_type_tc1 == `CA53_AFB_REQ_CLEANSETWAY)) & ~req_addr_tc1[1]));

  assign tagctl_l1_lf_tc1_o = valid_tc1 & ((req_type_tc1 == `CA53_AFB_REQ_READSHARED) |
                                           (req_type_tc1 == `CA53_AFB_REQ_READUNIQUE) |
                                           (req_type_tc1 == `CA53_AFB_REQ_ECCCLEAN));

  assign tagctl_serialising_tc1_o = (req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE);

  // Tell the snpslv if this is a DVM sync from a CPU, so it can ensure only
  // one of those is outstanding at once.
  assign tagctl_cpu_sync_tc1_o = (valid_tc1 &
                                  (req_type_tc1 == `CA53_AFB_REQ_DVM) &
                                  req_dvm_sync_tc1);

  assign tagctl_snp_sync_tc1_o = (valid_tc1 &
                                  (req_type_tc1 == `CA53_AFB_SNP_DVM_MESSAGE) &
                                  req_dvm_sync_tc1);

  assign tagctl_reqbufid_tc1_o = req_id_tc1;

  // When the CPU notifies the SCU that it is starting an invalidate all, we
  // must invalidate all the duplicate tags for that CPU as well.
  assign cpus_inv_all_starting = {cpuslv3_inv_all_starting_i,
                                  cpuslv2_inv_all_starting_i,
                                  cpuslv1_inv_all_starting_i,
                                  cpuslv0_inv_all_starting_i};

  assign start_inval = |cpus_inv_all_starting | leaving_reset_i;

  assign inval_active = (|inval_tags_tc0) | (|inval_tags_tc1) | start_inval | tagctl_mbistreq;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    l2_in_retention <= 1'b1;
  end else if (inval_active) begin
    l2_in_retention <= gov_l2_in_retention_i;
  end

  generate for (i = 0; i < 4; i = i + 1) begin : g_inval
    if (i < NUM_CPUS) begin : g_inval_cpu

      assign next_inval_l1_tags[i] = tagctl_mbistreq ? 1'b0 : (cpus_inv_all_starting[i] |
                                                               (inval_l1_tags[i] & ~inval_tags_complete[i]));

      always @(posedge clk or negedge reset_n)
      if (~reset_n) begin
        inval_l1_tags[i] <= 1'b0;
      end else if (inval_active) begin
        inval_l1_tags[i] <= next_inval_l1_tags[i];
      end

      assign inval_tags_tc0[i] = inval_l1_tags[i];

    end else begin : g_inval_n_cpu

      assign inval_tags_tc0[i] = 1'b0;

    end
  end endgenerate

  generate if (L2_CACHE) begin : g_inval_l2
    assign next_inval_l2_tags = tagctl_mbistreq ? 1'b0 :
                                leaving_reset_i ? ~config_l2rstdisable_i :
                                                  (inval_l2_tags & ~inval_tags_complete[4]);

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      inval_l2_tags <= 1'b0;
    end else if (inval_active) begin
      inval_l2_tags <= next_inval_l2_tags;
    end

    assign inval_tags_tc0[4] = inval_l2_tags;

  end else begin : g_inval_n_l2
    assign inval_tags_tc0[4] = 1'b0;
  end endgenerate

  assign next_inval_count_tc0 = start_inval ? 11'h000 : (inval_count_tc0 + 11'h001);

  assign inval_count_en = start_inval | (inval_active & ~l2_in_retention);

  always @(posedge clk)
  if (inval_count_en) begin
    inval_count_tc0 <= next_inval_count_tc0;
    inval_count_tc1 <= inval_count_tc0;
  end

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    inval_tags_tc1 <= 5'b00000;
  end else if (inval_active) begin
    inval_tags_tc1 <= inval_tags_tc0;
  end

  assign inval_tags_complete = ({&{inval_count_tc0[10:7] | ~tagctl_l2_size, inval_count_tc0[6:5]},
                                 {4{&{inval_count_tc0[7:5] | ~tagctl_l1_dc_size}}}} &
                                {5{&inval_count_tc0[4:0] & inval_count_en}});

  assign inval_tag_ways_tc0 = {{16{inval_tags_tc0[4]}},
                               { 4{inval_tags_tc0[3]}},
                               { 4{inval_tags_tc0[2]}},
                               { 4{inval_tags_tc0[1]}},
                               { 4{inval_tags_tc0[0]}}};

  // Enable all ways that the request wants, unless smp_en is low for a CPU in
  // which case the RAM is not enabled and in tc2 the access is assumed to have
  // missed. smp_en will be low for any CPU not present, so that does not need
  // to be factored in here. If the way is being invalidated then that takes
  // priority over the request, and the request assumes in tc2 that the way
  // missed.
  assign tagram_en_tc1 = (req_ways_tc1 & {{16{valid_ways_tc1[4]}},
                                          { 4{valid_ways_tc1[3]}},
                                          { 4{valid_ways_tc1[2]}},
                                          { 4{valid_ways_tc1[1]}},
                                          { 4{valid_ways_tc1[0]}}});

  // If a snoop is looking up any of bits [43:40] of the snoop address set then force it to miss.
  assign req_ways_read_tc1 = tagram_en_tc1 & ~{32{req_addr_tc1[41]}} & ~{{16{req_write_tc1[4]}},
                                                                         { 4{req_write_tc1[3]}},
                                                                         { 4{req_write_tc1[2]}},
                                                                         { 4{req_write_tc1[1]}},
                                                                         { 4{req_write_tc1[0]}}};

  assign l1d_tagram_clken_o   = tagram_clken_tc1;
  assign l2_tagram_clken_o    = tagram_clken_tc1;

  assign l1d_tagram_cpu0_en_o = tagram_en_tc1[3:0]   & ~{4{DFTRAMHOLD}};
  assign l1d_tagram_cpu1_en_o = tagram_en_tc1[7:4]   & ~{4{DFTRAMHOLD}};
  assign l1d_tagram_cpu2_en_o = tagram_en_tc1[11:8]  & ~{4{DFTRAMHOLD}};
  assign l1d_tagram_cpu3_en_o = tagram_en_tc1[15:12] & ~{4{DFTRAMHOLD}};
  assign l2_tagram_en_o       = tagram_en_tc1[31:16] & ~{16{DFTRAMHOLD}};

  assign l1d_tagram_cpu0_wr_o = req_write_tc1[0];
  assign l1d_tagram_cpu1_wr_o = req_write_tc1[1];
  assign l1d_tagram_cpu2_wr_o = req_write_tc1[2];
  assign l1d_tagram_cpu3_wr_o = req_write_tc1[3];
  assign l2_tagram_wr_o       = req_write_tc1[4];

  // RAM index muxes.
  assign l1d_tagram_cpu0_addr_o = (inval_tags_tc1[0] ? inval_count_tc1[7:0] :
                                                       {req_addr13_tc1, req_addr_tc1[12:6]});

  assign l1d_tagram_cpu1_addr_o = (inval_tags_tc1[1] ? inval_count_tc1[7:0] :
                                                       {req_addr13_tc1, req_addr_tc1[12:6]});

  assign l1d_tagram_cpu2_addr_o = (inval_tags_tc1[2] ? inval_count_tc1[7:0] :
                                                       {req_addr13_tc1, req_addr_tc1[12:6]});

  assign l1d_tagram_cpu3_addr_o = (inval_tags_tc1[3] ? inval_count_tc1[7:0] :
                                                       {req_addr13_tc1, req_addr_tc1[12:6]});

  assign l2_tagram_addr_o = (inval_tags_tc1[4] ? inval_count_tc1[10:0] :
                                                 req_addr_tc1[16:6]);

  assign l1d0_write_data_tc1 = {req_ecc_tc1[6:0],
                                req_wr_state_tc1[2:0],
                                req_addr_tc1[40:14],
                                req_addr_tc1[13:11] & ~tagctl_l1_dc_size};

  assign l1d1_write_data_tc1 = {req_ecc_tc1[13:7],
                                req_wr_state_tc1[5:3],
                                req_addr_tc1[40:14],
                                req_addr_tc1[13:11] & ~tagctl_l1_dc_size};

  assign l1d2_write_data_tc1 = {req_ecc_tc1[20:14],
                                req_wr_state_tc1[8:6],
                                req_addr_tc1[40:14],
                                req_addr_tc1[13:11] & ~tagctl_l1_dc_size};

  assign l1d3_write_data_tc1 = {req_ecc_tc1[27:21],
                                req_wr_state_tc1[11:9],
                                req_addr_tc1[40:14],
                                req_addr_tc1[13:11] & ~tagctl_l1_dc_size};

  assign l2_write_data_tc1 = {req_ecc_tc1[34:28],
                              req_wr_state_tc1[16:12],
                              req_addr_tc1[40:19],
                              req_addr_tc1_err[1:0],
                              req_addr_tc1[16:13] & ~tagctl_l2_size};

  assign inval_data_tc1 = {`CA53_TAG_NULL_ECC, {33{1'b0}}};

  // Write data muxes.
  assign l1d_tagram_cpu0_wdata_o = (inval_tags_tc1[0] ? inval_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] :
                                                        l1d0_write_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]);

  assign l1d_tagram_cpu1_wdata_o = (inval_tags_tc1[1] ? inval_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] :
                                                        l1d1_write_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]);

  assign l1d_tagram_cpu2_wdata_o = (inval_tags_tc1[2] ? inval_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] :
                                                        l1d2_write_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]);

  assign l1d_tagram_cpu3_wdata_o = (inval_tags_tc1[3] ? inval_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0] :
                                                        l1d3_write_data_tc1[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]);

  assign l2_tagram_wdata_o = (inval_tags_tc1[4] ? inval_data_tc1[`CA53_SCU_L2_TAGRAM_DATA_W-1:0] :
                                                  l2_write_data_tc1[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]);

  // Select one or two available L2DBs for use by this request if required by
  // the request type.
  assign l2db_available_tc1 = {l2db10_tagctl_available_i,
                               l2db9_tagctl_available_i,
                               l2db8_tagctl_available_i,
                               l2db7_tagctl_available_i,
                               l2db6_tagctl_available_i,
                               l2db5_tagctl_available_i,
                               l2db4_tagctl_available_i,
                               l2db3_tagctl_available_i,
                               l2db2_tagctl_available_i,
                               l2db1_tagctl_available_i,
                               l2db0_tagctl_available_i};

  // Identify if any L2DBs are currently in use by a snoop. If none are, then
  // we must reserve one of the empty buffers for a snoop to ensure snoops can
  // always make progress.
  assign l2db_used_for_snoop_tc1 = |{l2db10_tagctl_for_snoop_i,
                                     l2db9_tagctl_for_snoop_i,
                                     l2db8_tagctl_for_snoop_i,
                                     l2db7_tagctl_for_snoop_i,
                                     l2db6_tagctl_for_snoop_i,
                                     l2db5_tagctl_for_snoop_i,
                                     l2db4_tagctl_for_snoop_i,
                                     l2db3_tagctl_for_snoop_i,
                                     l2db2_tagctl_for_snoop_i,
                                     l2db1_tagctl_for_snoop_i,
                                     l2db0_tagctl_for_snoop_i};

  // Find the L2DBs that either have a lower numbered L2DB available, or a
  // higher numbered one.
  generate for (i = 1; i < MAX_L2DBS; i = i + 1) begin : g_l2db_avail
    assign l2db_avail_lower_tc1[i]    = l2db_avail_lower_tc1[i-1] | l2db_available_tc1[i-1];
    assign l2db_avail_higher_tc1[i-1] = l2db_avail_higher_tc1[i]  | l2db_available_tc1[i];
  end endgenerate

  assign l2db_avail_lower_tc1[0] = 1'b0;
  assign l2db_avail_higher_tc1[MAX_L2DBS-1] = 1'b0;

  // Select the lowest and the highest numbered available L2DB. Note that these
  // could be the same L2DB if there is only one available.
  assign first_l2db_tc1  = l2db_available_tc1 & ~l2db_avail_lower_tc1;
  assign second_l2db_tc1 = l2db_available_tc1 & ~l2db_avail_higher_tc1;

  // Calculate how many L2DBs are available. A request may want up to two, but
  // we also need to know if more than two are available in case one needs to
  // be kept reserved for a snoop.
  assign first_l2db_valid_tc1 = |first_l2db_tc1;
  assign second_l2db_valid_tc1 = |(second_l2db_tc1 & ~first_l2db_tc1);
  assign third_l2db_valid_tc1 = |(l2db_available_tc1 & ~second_l2db_tc1 & ~first_l2db_tc1);


  // Calculate how many L2DBs are in use by writes that have not been
  // serialised yet. We must ensure that unserialised requests cannot use up all
  // of the L2DBs, so that there are at least 3 remaining to allow one other
  // request and a snoop to progress. This is because we cannot rely on any
  // unserialised request progressing independently.

  // New unserialised L2DBs are only allocated in TC1, and cannot be flushed after this point.
  assign unserialised_l2db_tc1 = valid_tc1 & ~flush_tc1 & alloc_l2db_for_write_tc1 & ~acp_slverr_tc1;

  // An unserialised L2DB gets converted to a serialised one when the request
  // reaches TC4.
  assign unserialised_l2dbs_tc1_en = unserialised_l2db_tc1 ^ (valid_tc4 & ~flush_tc4 & serialised_l2db_tc4);

  assign next_unserialised_l2dbs_tc1 = unserialised_l2dbs_tc1 + (unserialised_l2db_tc1 ? 4'b0001 : 4'b1111);

  always @(posedge clk_tc1 or negedge reset_n)
  if (~reset_n) begin
    unserialised_l2dbs_tc1 <= 4'b0000;
  end else if (unserialised_l2dbs_tc1_en) begin
    unserialised_l2dbs_tc1 <= next_unserialised_l2dbs_tc1;
  end

  assign allow_unserialised_l2db_tc1 = unserialised_l2dbs_tc1 < MAX_UNSERIALISED_L2DBS[3:0];

  // Identify classes of request that require an L2DB allocation.
  assign alloc_l2db_for_write_tc1 = ((req_pass_tc1 == `CA53_TAGCTL_PASS_L2DB) &
                                     (req_type_tc1 != `CA53_AFB_REQ_READONCE));

  assign alloc_l2db_for_acp_read_tc1 = ((req_pass_tc1 == `CA53_TAGCTL_PASS_L2DB) &
                                        (req_type_tc1 == `CA53_AFB_REQ_READONCE));

  assign alloc_l2db_for_read_tc1 = (((req_type_tc1 == `CA53_AFB_REQ_READSHARED) |
                                     (req_type_tc1 == `CA53_AFB_REQ_READUNIQUE) |
                                     (req_type_tc1 == `CA53_AFB_REQ_READONCE) |
                                     (req_type_tc1 == `CA53_AFB_REQ_READNONE) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READONCE) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READSHARED) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READCLEAN) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READUNIQUE) |
                                     (req_type_tc1 == `CA53_AFB_SNP_CLEANSHARED) |
                                     (req_type_tc1 == `CA53_AFB_SNP_CLEANINVALID)) &
                                    (req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE));

  assign alloc_l2db_for_victim_tc1 = (((req_type_tc1 == `CA53_AFB_REQ_READSHARED) |
                                       (req_type_tc1 == `CA53_AFB_REQ_READUNIQUE) |
                                       (req_type_tc1 == `CA53_AFB_REQ_CLEANUNIQUE) |
                                       (req_type_tc1 == `CA53_AFB_REQ_CLEANSHARED) |
                                       (req_type_tc1 == `CA53_AFB_REQ_CLEANINVALID) |
                                       (req_type_tc1 == `CA53_AFB_REQ_MAKEINVALID) |
                                       (req_type_tc1 == `CA53_AFB_REQ_CLEANSETWAY) |
                                       (req_type_tc1 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                       (req_type_tc1 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                       (req_type_tc1 == `CA53_AFB_REQ_ECCCLEAN)) &
                                      (req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE));

  // Because some requests require one L2DB, and others require two L2DBs, it is
  // possible that a request that is waiting for two L2DBs cannot make progress
  // because every time an L2DB becomes free it is used by a request that only
  // requires one L2DB, and so there is never a time when two L2DBs are free.
  // To avoid this situation, we count the number of times a request requiring
  // two L2DBs is flushed, since the last successfull allocation. If this
  // counter saturates, then we prevent requests only requiring one L2DB from
  // being serialised, until there are at least two L2DBs available.
  assign l2db_hz_count_reset_tc1 = (first_l2db_valid_tc1 &
                                    second_l2db_valid_tc1 &
                                    (third_l2db_valid_tc1 |
                                     l2db_used_for_snoop_tc1));

  assign l2db_hz_count_incr_tc1 = (afb0_l2db_hazard_both_tc4 |
                                   afb1_l2db_hazard_both_tc4 |
                                   afb2_l2db_hazard_both_tc4 |
                                   afb3_l2db_hazard_both_tc4 |
                                   afb4_l2db_hazard_both_tc4 |
                                   afb5_l2db_hazard_both_tc4);

  assign l2db_hz_count_tc1_en = (l2db_hz_count_reset_tc1 |
                                 (l2db_hz_count_incr_tc1 & ~prevent_single_alloc_tc1));

  assign next_l2db_hz_count_tc1 = l2db_hz_count_reset_tc1 ? 8'b00000000 : (l2db_hz_count_tc1 + 8'b00000001);

  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    l2db_hz_count_tc1 <= 8'b00000000;
  end else if (l2db_hz_count_tc1_en) begin
    l2db_hz_count_tc1 <= next_l2db_hz_count_tc1;
  end

  assign prevent_single_alloc_tc1 = l2db_hz_count_tc1[7];

  assign l2dbs_used_for_write = (l2db10_tagctl_for_write_i +
                                 l2db9_tagctl_for_write_i +
                                 l2db8_tagctl_for_write_i +
                                 l2db7_tagctl_for_write_i +
                                 l2db6_tagctl_for_write_i +
                                 l2db5_tagctl_for_write_i +
                                 l2db4_tagctl_for_write_i +
                                 l2db3_tagctl_for_write_i +
                                 l2db2_tagctl_for_write_i +
                                 l2db1_tagctl_for_write_i +
                                 l2db0_tagctl_for_write_i);

  // If all L2DBs are allocated for writes, then this can prevent linefills
  // from making progress. While this is not a functional problem, better
  // performance can sometime be achieved if one L2DB is reserved for the
  // linefill, by preventing all of them being used for writes.
  assign next_prevent_write_alloc_tc1 = ((l2dbs_used_for_write > 4'b1001) |
                                         ((l2dbs_used_for_write > 4'b1000) &
                                          alloc_l2db_for_write_tc1 & alloc_first_l2db_tc1));
                                       
  always @(posedge clk_tagctl)
  if (req_tc1_en) begin
    prevent_write_alloc_tc1 <= next_prevent_write_alloc_tc1;
  end

  assign first_l2db_avail_tc1 = (first_l2db_valid_tc1 &
                                 (((`CA53_REQBUF_IS_SNOOP(req_id_tc1) |
                                    alloc_l2db_for_acp_read_tc1) &
                                   ~(prevent_single_alloc_tc1 & l2db_used_for_snoop_tc1)) |
                                  ((l2db_used_for_snoop_tc1 |
                                    second_l2db_valid_tc1 |
                                    third_l2db_valid_tc1) &
                                   ~prevent_single_alloc_tc1 &
                                   ~(alloc_l2db_for_write_tc1 & prevent_write_alloc_tc1))));

  // A slightly earlier version of first_l2db_avail_tc1 for writes and ACP reads
  // that only need one L2DB.
  assign first_l2db_avail_for_acp_read_tc1 = (|l2db_available_tc1 &
                                              ~(prevent_single_alloc_tc1 & l2db_used_for_snoop_tc1));

  assign first_l2db_avail_for_write_tc1 = ((|l2db_available_tc1 &
                                            (l2db_used_for_snoop_tc1 |
                                             (|(l2db_available_tc1 & l2db_avail_lower_tc1)))) &
                                           ~prevent_single_alloc_tc1 &
                                           ~prevent_write_alloc_tc1);

  assign alloc_first_l2db_tc1 = (valid_tc1 & ~flush_tc1 & (alloc_l2db_for_write_tc1 |
                                                           alloc_l2db_for_acp_read_tc1 |
                                                           alloc_l2db_for_read_tc1 |
                                                           alloc_l2db_for_victim_tc1) &
                                 first_l2db_avail_tc1);

  assign alloc_second_l2db_tc1 = (valid_tc1 & ~flush_tc1 & (alloc_l2db_for_read_tc1 &
                                                            alloc_l2db_for_victim_tc1) &
                                  second_l2db_valid_tc1 &
                                  (l2db_used_for_snoop_tc1 |
                                   third_l2db_valid_tc1) &
                                  ~prevent_single_alloc_tc1);

  // Encode the L2DB number being allocated, to reduce the amount of storage required.
  assign first_l2db_enc_tc1 = {|first_l2db_tc1[10:8],
                               |first_l2db_tc1[7:4],
                               |{first_l2db_tc1[10], first_l2db_tc1[7:6], first_l2db_tc1[3:2]},
                               |{first_l2db_tc1[9], first_l2db_tc1[7], first_l2db_tc1[5],
                                 first_l2db_tc1[3], first_l2db_tc1[1]}};

  // On the serialise pass of WriteUnique, the reqbuf provides the already allocated L2DB.
  assign valid_second_l2db_tc1 = alloc_second_l2db_tc1 | (req_type_tc1 == `CA53_AFB_REQ_WRITEUNIQUE);

  assign second_l2db_enc_tc1 = (tagctl_mbistreq ? {2'b00, tagctl_mbistarray[8:7]} :
                                ((req_pass_tc1 != `CA53_TAGCTL_PASS_SERIALISE) |
                                 (req_type_tc1 == `CA53_AFB_REQ_WRITEUNIQUE) |
                                 (req_type_tc1 == `CA53_AFB_REQ_WRITENOSNOOP) |
                                 (req_type_tc1 == `CA53_AFB_REQ_CLEANSHARED) |
                                 (req_type_tc1 == `CA53_AFB_REQ_CLEANINVALID) |
                                 (req_type_tc1 == `CA53_AFB_REQ_MAKEINVALID)) ? req_l2db_tc1 :
                                {|second_l2db_tc1[10:8],
                                 |second_l2db_tc1[7:4],
                                 |{second_l2db_tc1[10], second_l2db_tc1[7:6], second_l2db_tc1[3:2]},
                                 |{second_l2db_tc1[9], second_l2db_tc1[7], second_l2db_tc1[5],
                                   second_l2db_tc1[3], second_l2db_tc1[1]}});

  // Return the allocated L2DB to the cpuslv for write requests, so that the
  // CPU knows where to start sending the write data.
  assign tagctl_slv_l2db_tc1_o = first_l2db_enc_tc1;

  // Tell the L2DB that it has been allocated.
  assign tagctl_l2db0_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[0])  | (alloc_second_l2db_tc1 & second_l2db_tc1[0]));
  assign tagctl_l2db1_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[1])  | (alloc_second_l2db_tc1 & second_l2db_tc1[1]));
  assign tagctl_l2db2_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[2])  | (alloc_second_l2db_tc1 & second_l2db_tc1[2]));
  assign tagctl_l2db3_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[3])  | (alloc_second_l2db_tc1 & second_l2db_tc1[3]));
  assign tagctl_l2db4_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[4])  | (alloc_second_l2db_tc1 & second_l2db_tc1[4]));
  assign tagctl_l2db5_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[5])  | (alloc_second_l2db_tc1 & second_l2db_tc1[5]));
  assign tagctl_l2db6_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[6])  | (alloc_second_l2db_tc1 & second_l2db_tc1[6]));
  assign tagctl_l2db7_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[7])  | (alloc_second_l2db_tc1 & second_l2db_tc1[7]));
  assign tagctl_l2db8_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[8])  | (alloc_second_l2db_tc1 & second_l2db_tc1[8]));
  assign tagctl_l2db9_alloc_o  = ((alloc_first_l2db_tc1 & first_l2db_tc1[9])  | (alloc_second_l2db_tc1 & second_l2db_tc1[9]));
  assign tagctl_l2db10_alloc_o = ((alloc_first_l2db_tc1 & first_l2db_tc1[10]) | (alloc_second_l2db_tc1 & second_l2db_tc1[10]));

  assign tagctl_alloc_for_snoop_o = `CA53_REQBUF_IS_SNOOP(req_id_tc1);

  assign tagctl_alloc_for_write_o = ((req_type_tc1 == `CA53_AFB_REQ_WRITENOSNOOP) |
                                     (req_type_tc1 == `CA53_AFB_REQ_WRITEUNIQUE) |
                                     (req_type_tc1 == `CA53_AFB_REQ_DVM));

  // Exclusive writes use a different AXI ID to other non-reorderable writes, and
  // therefore must hazard to prevent reordering.
  assign req_dev_hz_tc1 = (((req_type_tc1 == `CA53_AFB_REQ_READNOSNOOP) & ~`CA53_MEM_REORDERABLE(req_attrs_tc1)) |
                           ((req_type_tc1 == `CA53_AFB_REQ_WRITENOSNOOP) & req_lock_tc1));

  // Requests must hazard against victim addresses if the victim is just being
  // read and hence hasn't reached the reqbuf yet. L2 index hazarding is
  // required if both requests need to pick an L2 victim way, and so the second
  // one will happen before the first knows which way it has picked.
  assign victim_hz_tc1 = (valid_tc3 &
                          (((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                            (((req_type_tc3 == `CA53_AFB_REQ_READSHARED) |
                              (req_type_tc3 == `CA53_AFB_REQ_READUNIQUE) |
                              (req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                              (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                              (req_type_tc3 == `CA53_AFB_REQ_ECCCLEAN)) &
                             l1_victim_hit_tc3)) |
                           ((((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                              ((req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                               (req_type_tc3 == `CA53_AFB_SNP_CLEANINVSETWAY))) |
                             ((req_pass_tc3 == `CA53_TAGCTL_PASS_L2_VICTIM) &
                              (req_type_tc3 == `CA53_AFB_REQ_READSHARED) |
                              (req_type_tc3 == `CA53_AFB_REQ_READUNIQUE) |
                              (req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                              (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                              (req_type_tc3 == `CA53_AFB_REQ_ECCCLEAN))) &
                             l2_victim_valid_tc3)) &
                          ({tagctl_l2_size & req_addr_tc1[16:13], req_addr_tc1[12:6]} ==
                           {tagctl_l2_size & victim_addr_tc3[16:13], victim_addr_tc3[12:6]}) &
                          tagctl_addr_valid_tc1);

  assign afb_hz_tc1 = afb0_hz_tc1 | afb1_hz_tc1 | afb2_hz_tc1 | afb3_hz_tc1 | afb4_hz_tc1 | afb5_hz_tc1;

  //----------------------------------------------------------------------------
  //  tc2
  //----------------------------------------------------------------------------


  // Move the tc1 contents into tc2 unless flushed, except for requests that
  // have already done all their work.
  assign next_valid_tc2 = (valid_tc1 & ~flush_tc1 & ~((req_pass_tc1 == `CA53_TAGCTL_PASS_UPDATE) |
                                                      (req_pass_tc1 == `CA53_TAGCTL_PASS_VICTIM_UPDATE) |
                                                      (req_pass_tc1 == `CA53_TAGCTL_PASS_L2DB))) | tagctl_mbistreq;

  assign next_afb_tc2 = afb_tc1 & {6{next_valid_tc2}};

  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    valid_tc2 <= 1'b0;
    afb_tc2   <= 6'b000000;
  end else if (tagctl_active) begin
    valid_tc2 <= next_valid_tc2;
    afb_tc2   <= next_afb_tc2;
  end

  always @(posedge clk_tagctl)
  if (valid_tc1) begin
    req_id_tc2        <= req_id_tc1;
    req_type_tc2      <= req_type_tc1;
    req_pass_tc2      <= req_pass_tc1;
    req_addr1_tc2     <= req_addr1_tc1;
    req_dev_hz_tc2    <= req_dev_hz_tc1;
    req_ways_read_tc2 <= req_ways_read_tc1;
    smp_en_tc2        <= smp_en_tc1;
    req_victim_hz_tc2 <= victim_hz_tc1;
    afb_hz_tc2        <= afb_hz_tc1;
  end

  generate if (L2_CACHE) begin : g_l2cc

    always @(posedge clk_tagctl)
    if (valid_tc1) begin
      req_victim_way_tc2 <= req_victim_way_tc1;
    end

  end else begin : g_n_l2cc

    always @*
      req_victim_way_tc2 = {4{zero}};

  end endgenerate

  assign flush_allowed_tc2 = (valid_tc2 &
                              ((req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) |
                               ((req_pass_tc2 == `CA53_TAGCTL_PASS_LOOKUP) &
                                ((req_type_tc2 == `CA53_AFB_REQ_WRITEUNIQUE) |
                                 (req_type_tc2 == `CA53_AFB_REQ_CLEANUNIQUE)))));

  assign flush_raw_tc2 = (flush_allowed_tc2 &
                          (req_victim_hz_tc2 |
                           afb_hz_tc2 |
                           cpuslv0_hz_tc2_i |
                           cpuslv1_hz_tc2_i |
                           cpuslv2_hz_tc2_i |
                           cpuslv3_hz_tc2_i |
                           acpslv_hz_tc2_i |
                           snpslv_hz_tc2_i |
                           master_hz_tc2_i |
                           (master_hz_dev_tc2_i & req_dev_hz_tc2)));

  assign flush_tc2 = ((flush_allowed_tc2 &
                       (flush_raw_tc2 |
                        flush_raw_tc3 |
                        (flush_tc4 & ~(l2db_flush_tc4 & `CA53_REQBUF_IS_SNOOP(req_id_tc2))))));

  assign tagctl_slv_flush_tc2_o = flush_tc2;

  assign cpuslv_snp_hz_tc2 = req_type_tc2[5] & (cpuslv3_snp_hz_tc2_i |
                                                cpuslv2_snp_hz_tc2_i |
                                                cpuslv1_snp_hz_tc2_i |
                                                cpuslv0_snp_hz_tc2_i);

  assign cpuslv_snp_hz_id_tc2 = (({5{cpuslv3_snp_hz_tc2_i}} & {2'b11, cpuslv3_snp_hz_id_tc2_i}) |
                                 ({5{cpuslv2_snp_hz_tc2_i}} & {2'b10, cpuslv2_snp_hz_id_tc2_i}) |
                                 ({5{cpuslv1_snp_hz_tc2_i}} & {2'b01, cpuslv1_snp_hz_id_tc2_i}) |
                                 ({5{cpuslv0_snp_hz_tc2_i}} & {2'b00, cpuslv0_snp_hz_id_tc2_i}));

  assign cpuslv_snp_l2db_hz_tc2 = req_type_tc2[5] & (cpuslv3_snp_l2db_hz_tc2_i |
                                                     cpuslv2_snp_l2db_hz_tc2_i |
                                                     cpuslv1_snp_l2db_hz_tc2_i |
                                                     cpuslv0_snp_l2db_hz_tc2_i |
                                                     master_hz_l2db_tc2_i);

  assign cpuslv_snp_l2db_dirty_tc2 = (master_hz_l2db_tc2_i ? master_hz_dirty_tc2_i :
                                      ((cpuslv3_snp_l2db_hz_tc2_i & cpuslv3_snp_l2db_dirty_tc2_i) |
                                       (cpuslv2_snp_l2db_hz_tc2_i & cpuslv2_snp_l2db_dirty_tc2_i) |
                                       (cpuslv1_snp_l2db_hz_tc2_i & cpuslv1_snp_l2db_dirty_tc2_i) |
                                       (cpuslv0_snp_l2db_hz_tc2_i & cpuslv0_snp_l2db_dirty_tc2_i)));

  assign cpuslv_snp_l2db_cu_tc2 = master_hz_l2db_tc2_i & master_hz_cu_tc2_i;

  assign cpuslv_snp_l2db_tc2 = (master_hz_l2db_tc2_i ? master_l2db_tc2_i :
                                (({4{cpuslv3_snp_l2db_hz_tc2_i}} & cpuslv3_snp_l2db_tc2_i) |
                                 ({4{cpuslv2_snp_l2db_hz_tc2_i}} & cpuslv2_snp_l2db_tc2_i) |
                                 ({4{cpuslv1_snp_l2db_hz_tc2_i}} & cpuslv1_snp_l2db_tc2_i) |
                                 ({4{cpuslv0_snp_l2db_hz_tc2_i}} & cpuslv0_snp_l2db_tc2_i)));

  assign tagctl_ecc_hz_tc2 = (snpslv_ecc_hz_tc2_i |
                              cpuslv3_ecc_hz_tc2_i |
                              cpuslv2_ecc_hz_tc2_i |
                              cpuslv1_ecc_hz_tc2_i |
                              cpuslv0_ecc_hz_tc2_i);

  // Only some request passes require an AFB, and for those we must tell the
  // AFB it has reached tc2 and if it has been flushed.

  assign active_afb0_tc2 = afb_tc2[0];
  assign active_afb1_tc2 = afb_tc2[1];
  assign active_afb2_tc2 = afb_tc2[2];
  assign active_afb3_tc2 = afb_tc2[3];
  assign active_afb4_tc2 = afb_tc2[4];
  assign active_afb5_tc2 = afb_tc2[5];

  assign flush_afb0_tc2 = active_afb0_tc2 & flush_tc2;
  assign flush_afb1_tc2 = active_afb1_tc2 & flush_tc2;
  assign flush_afb2_tc2 = active_afb2_tc2 & flush_tc2;
  assign flush_afb3_tc2 = active_afb3_tc2 & flush_tc2;
  assign flush_afb4_tc2 = active_afb4_tc2 & flush_tc2;
  assign flush_afb5_tc2 = active_afb5_tc2 & flush_tc2;

  // Tell the SAM if this op needs to be sent to the MN.
  assign tagctl_mn_op_tc2_o = ((req_type_tc2 == `CA53_AFB_REQ_DMB) |
                               (req_type_tc2 == `CA53_AFB_REQ_DSB) |
                               (req_type_tc2 == `CA53_AFB_REQ_DVM) |
                               (req_type_tc2 == `CA53_AFB_SNP_DSB));

  assign tagctl_sam_addr_tc2_o = req_addr1_tc2[39:6];

  assign l1_tagram_rdata_tc2[0]  = l1d_tagram_cpu0_way0_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[1]  = l1d_tagram_cpu0_way1_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[2]  = l1d_tagram_cpu0_way2_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[3]  = l1d_tagram_cpu0_way3_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[4]  = l1d_tagram_cpu1_way0_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[5]  = l1d_tagram_cpu1_way1_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[6]  = l1d_tagram_cpu1_way2_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[7]  = l1d_tagram_cpu1_way3_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[8]  = l1d_tagram_cpu2_way0_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[9]  = l1d_tagram_cpu2_way1_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[10] = l1d_tagram_cpu2_way2_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[11] = l1d_tagram_cpu2_way3_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[12] = l1d_tagram_cpu3_way0_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[13] = l1d_tagram_cpu3_way1_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[14] = l1d_tagram_cpu3_way2_rdata_i[32:0];
  assign l1_tagram_rdata_tc2[15] = l1d_tagram_cpu3_way3_rdata_i[32:0];

  generate if (CPU_CACHE_PROTECTION) begin : g_cpu_rdata
    assign l1_tagram_rdata_ecc_tc2[0]  = l1d_tagram_cpu0_way0_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[1]  = l1d_tagram_cpu0_way1_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[2]  = l1d_tagram_cpu0_way2_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[3]  = l1d_tagram_cpu0_way3_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[4]  = l1d_tagram_cpu1_way0_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[5]  = l1d_tagram_cpu1_way1_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[6]  = l1d_tagram_cpu1_way2_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[7]  = l1d_tagram_cpu1_way3_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[8]  = l1d_tagram_cpu2_way0_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[9]  = l1d_tagram_cpu2_way1_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[10] = l1d_tagram_cpu2_way2_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[11] = l1d_tagram_cpu2_way3_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[12] = l1d_tagram_cpu3_way0_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[13] = l1d_tagram_cpu3_way1_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[14] = l1d_tagram_cpu3_way2_rdata_i[39:33];
    assign l1_tagram_rdata_ecc_tc2[15] = l1d_tagram_cpu3_way3_rdata_i[39:33];
  end else begin : g_n_cpu_rdata
    for (i = 0; i < 16; i = i + 1) begin : g_n_cpu_rdata_loop
      assign l1_tagram_rdata_ecc_tc2[i] = {7{1'b0}};
    end
  end endgenerate

  assign l2_tagram_rdata_tc2[0]  = l2_tagram_way0_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[1]  = l2_tagram_way1_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[2]  = l2_tagram_way2_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[3]  = l2_tagram_way3_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[4]  = l2_tagram_way4_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[5]  = l2_tagram_way5_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[6]  = l2_tagram_way6_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[7]  = l2_tagram_way7_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[8]  = l2_tagram_way8_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[9]  = l2_tagram_way9_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[10] = l2_tagram_way10_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[11] = l2_tagram_way11_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[12] = l2_tagram_way12_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[13] = l2_tagram_way13_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[14] = l2_tagram_way14_rdata_i[32:0];
  assign l2_tagram_rdata_tc2[15] = l2_tagram_way15_rdata_i[32:0];

  generate if (SCU_CACHE_PROTECTION) begin : g_scu_rdata
    assign l2_tagram_rdata_ecc_tc2[0]  = l2_tagram_way0_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[1]  = l2_tagram_way1_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[2]  = l2_tagram_way2_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[3]  = l2_tagram_way3_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[4]  = l2_tagram_way4_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[5]  = l2_tagram_way5_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[6]  = l2_tagram_way6_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[7]  = l2_tagram_way7_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[8]  = l2_tagram_way8_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[9]  = l2_tagram_way9_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[10] = l2_tagram_way10_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[11] = l2_tagram_way11_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[12] = l2_tagram_way12_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[13] = l2_tagram_way13_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[14] = l2_tagram_way14_rdata_i[39:33];
    assign l2_tagram_rdata_ecc_tc2[15] = l2_tagram_way15_rdata_i[39:33];
  end else begin : g_n_scu_rdata
    for (i = 0; i < 16; i = i + 1) begin : g_n_scu_rdata_loop
      assign l2_tagram_rdata_ecc_tc2[i] = {7{1'b0}};
    end
  end endgenerate

  // Mask the address we are searching for based on the cache size. The value
  // in the RAM will have been masked when written, and therefore does not need
  // masking again here.
  assign l1_tag_value_tc2 = {req_addr1_tc2[40:14], req_addr1_tc2[13:11] & ~tagctl_l1_dc_size};

  generate for (i = 0; i < 16; i = i + 1) begin : g_l1_tag_loop

    // L1 tag hit comparators. The outputs are registered and then combined with
    // the valid bits in the following cycle.
    assign l1_comp_ways_tc2[i] = (l1_tagram_rdata_tc2[i][29:0] == l1_tag_value_tc2);

    assign l1_cu_ways_tc2[i] = (l1_tagram_rdata_tc2[i][30] &
                                req_ways_read_tc2[i] &
                                ~(cpuslv3_force_miss_tc2_i[i] |
                                  cpuslv2_force_miss_tc2_i[i] |
                                  cpuslv1_force_miss_tc2_i[i] |
                                  cpuslv0_force_miss_tc2_i[i]));

    assign l1_valid_ways_tc2[i] = (`CA53_SCU_TAG_VALID(l1_tagram_rdata_tc2[i][32],
                                                       l1_tagram_rdata_tc2[i][31],
                                                       tag_valid_ctl_tc2) &
                                   req_ways_read_tc2[i]);

    assign l1_state0_ways_tc2[i] = (l1_tagram_rdata_tc2[i][31] &
                                    l1_valid_ways_tc2[i] &
                                    ~(cpuslv3_force_miss_tc2_i[i] |
                                      cpuslv2_force_miss_tc2_i[i] |
                                      cpuslv1_force_miss_tc2_i[i] |
                                      cpuslv0_force_miss_tc2_i[i]));

    assign l1_state1_ways_tc2[i] = (l1_tagram_rdata_tc2[i][32] &
                                    l1_valid_ways_tc2[i] &
                                    ~(cpuslv3_force_miss_tc2_i[i] |
                                      cpuslv2_force_miss_tc2_i[i] |
                                      cpuslv1_force_miss_tc2_i[i] |
                                      cpuslv0_force_miss_tc2_i[i]));
  end endgenerate

  // For ECC Clean requests, we need to know which way is being accessed even
  // when it doesn't hit. For this type of request only one way in total will
  // be enabled, so we can just combine all the CPUs ways together.
  assign l1_ecc_victim_way_tc2 = (req_ways_read_tc2[15:12] |
                                  req_ways_read_tc2[11:8] |
                                  req_ways_read_tc2[7:4] |
                                  req_ways_read_tc2[3:0]);

  // Mask the address we are searching for based on the cache size. The value
  // in the RAM will have been masked when written, and therefore does not need
  // masking again here.
  assign l2_tag_value_tc2 = {req_addr1_tc2[40:17], req_addr1_tc2[16:13] & ~tagctl_l2_size};

  assign tag_valid_ctl_tc2 = `CA53_REQBUF_IS_SNOOP(req_id_tc2) ? {1'b0,
                                                                  tagctl_broadcastinner,
                                                                  tagctl_broadcastouter} :
                                                                 3'b111;

  generate for (i = 0; i < 16; i = i + 1) begin : g_l2_tag_loop
    // L2 tag hit comparators. Unlike the L1 comparators, the outputs are used in
    // tc2 to calculate the L2 data RAM address if required, so that the data RAM
    // can be enabled at the start of tc3.
    assign l2_comp_ways_tc2[i] = (l2_tagram_rdata_tc2[i][27:0] == l2_tag_value_tc2);

    assign l2_valid_ways_tc2[i] = (`CA53_SCU_TAG_VALID(l2_tagram_rdata_tc2[i][32],
                                                       l2_tagram_rdata_tc2[i][31],
                                                       tag_valid_ctl_tc2) &
                                   req_ways_read_tc2[i+16] &
                                   ~(acpslv_force_miss_tc2_i[i] |
                                     cpuslv3_force_miss_tc2_i[i+16] |
                                     cpuslv2_force_miss_tc2_i[i+16] |
                                     cpuslv1_force_miss_tc2_i[i+16] |
                                     cpuslv0_force_miss_tc2_i[i+16]));

    if (L2_CACHE) begin : g_l2_hit
      assign l2_hit_ways_tc2[i] = (l2_valid_ways_tc2[i] & l2_comp_ways_tc2[i] &
                                   (((req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                                     ~((req_type_tc2 == `CA53_AFB_REQ_CLEANSETWAY) |
                                       (req_type_tc2 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                       (req_type_tc2 == `CA53_AFB_REQ_ECCCLEAN) |
                                       (req_type_tc2 == `CA53_AFB_SNP_CLEANINVSETWAY))) |
                                    (req_pass_tc2 == `CA53_TAGCTL_PASS_L2_VICTIM) |
                                    (req_pass_tc2 == `CA53_TAGCTL_PASS_LOOKUP)));

    end else begin : g_nl2_hit
      assign l2_hit_ways_tc2[i] = 1'b0;
    end

    assign l2_alloc_ways_tc2[i]  = l2_tagram_rdata_tc2[i][28] & req_ways_read_tc2[i + 16];
    assign l2_dirty_ways_tc2[i]  = l2_tagram_rdata_tc2[i][29] & req_ways_read_tc2[i + 16];
    assign l2_cu_ways_tc2[i]     = l2_tagram_rdata_tc2[i][30] & req_ways_read_tc2[i + 16];
    assign l2_state0_ways_tc2[i] = l2_tagram_rdata_tc2[i][31] & req_ways_read_tc2[i + 16];
    assign l2_state1_ways_tc2[i] = l2_tagram_rdata_tc2[i][32] & req_ways_read_tc2[i + 16];

  end endgenerate


  assign requestor_cpu_tc2 = {req_id_tc2[5:3] == 3'b011,
                              req_id_tc2[5:3] == 3'b010,
                              req_id_tc2[5:3] == 3'b001,
                              req_id_tc2[5:3] == 3'b000};

  // Which CPUs have been enabled for a lookup, and so we should look at the
  // comparator outputs in the following cycle.
  assign l1_lookup_cpu_en_tc2 = ((({4{req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE}} &
                                   (((req_type_tc2 == `CA53_AFB_REQ_READSHARED) |
                                     (req_type_tc2 == `CA53_AFB_REQ_READUNIQUE)) ? ~requestor_cpu_tc2 : 4'b1111)) |
                                  {4{req_pass_tc2 == `CA53_TAGCTL_PASS_LOOKUP}} |
                                  ({4{req_pass_tc2 == `CA53_TAGCTL_PASS_VICTIM}} &
                                   (L2_CACHE[0] ? 4'b1111 : ~requestor_cpu_tc2))) &
                                 smp_en_tc2);

  assign l1_victim_cpu_en_tc2 = ({4{(req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                                    ((req_type_tc2 == `CA53_AFB_REQ_READSHARED) |
                                     (req_type_tc2 == `CA53_AFB_REQ_READUNIQUE) |
                                     (req_type_tc2 == `CA53_AFB_REQ_ECCCLEAN) |
                                     (((req_type_tc2 == `CA53_AFB_REQ_CLEANSETWAY) |
                                      (req_type_tc2 == `CA53_AFB_REQ_CLEANINVSETWAY)) &
                                      ~req_addr1_tc2[1]))}} &
                                 requestor_cpu_tc2);


  assign l1_victim_way_tc2 = (tagctl_mbistreq ? ({16{tagctl_mbistarray[6:5] == 2'b10}} &
                                                (16'h0001 << {tagctl_mbistarray[8:7], tagctl_mbistarray[1:0]})) :
                              `CA53_REQBUF_IS_TAGECC(req_id_tc2) ? ecc_tagctl_ways_tc0[15:0] :
                                                                   ((l1_state0_ways_tc2 |
                                                                     l1_state1_ways_tc2) &
                                                                    {{4{req_id_tc2[4:3] == 2'b11}},
                                                                     {4{req_id_tc2[4:3] == 2'b10}},
                                                                     {4{req_id_tc2[4:3] == 2'b01}},
                                                                     {4{req_id_tc2[4:3] == 2'b00}}}));

  assign l1_victim_tag_tc2 = (({33{l1_victim_way_tc2[15]}} & l1d_tagram_cpu3_way3_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[14]}} & l1d_tagram_cpu3_way2_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[13]}} & l1d_tagram_cpu3_way1_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[12]}} & l1d_tagram_cpu3_way0_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[11]}} & l1d_tagram_cpu2_way3_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[10]}} & l1d_tagram_cpu2_way2_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[9]}}  & l1d_tagram_cpu2_way1_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[8]}}  & l1d_tagram_cpu2_way0_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[7]}}  & l1d_tagram_cpu1_way3_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[6]}}  & l1d_tagram_cpu1_way2_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[5]}}  & l1d_tagram_cpu1_way1_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[4]}}  & l1d_tagram_cpu1_way0_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[3]}}  & l1d_tagram_cpu0_way3_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[2]}}  & l1d_tagram_cpu0_way2_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[1]}}  & l1d_tagram_cpu0_way1_rdata_i[32:0]) |
                              ({33{l1_victim_way_tc2[0]}}  & l1d_tagram_cpu0_way0_rdata_i[32:0]));

  // Increment round robin counter whenever a victim way is picked. The counter
  // is only used if multiple ways need choosing from, and it gives a random
  // selection when distributed over all indexes.
  assign victim_way_rr_en = (valid_tc2 &
                             (((req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                               ((req_type_tc2 == `CA53_AFB_REQ_READONCE) |
                                (req_type_tc2 == `CA53_AFB_REQ_READNONE) |
                                (req_type_tc2 == `CA53_AFB_REQ_WRITEUNIQUE))) |
                              (req_pass_tc2 == `CA53_TAGCTL_PASS_L2_VICTIM)) &
                             ~tagctl_mbistreq);

  assign l2_victim_invalid_eligible_ways_tc2 = ({16{valid_tc2}} & req_ways_read_tc2[31:16] &
                                                ~cpuslv0_l2_way_used_tc2_i &
                                                ~cpuslv1_l2_way_used_tc2_i &
                                                ~cpuslv2_l2_way_used_tc2_i &
                                                ~cpuslv3_l2_way_used_tc2_i &
                                                ~acpslv_l2_way_used_tc2_i &
                                                ~snpslv_l2_way_used_tc2_i);

  assign l2_victim_eligible_ways_tc2 = (tagctl_mbistreq ? ({16{~tagctl_mbistarray[6]}} &
                                                          (16'h0001 << tagctl_mbistarray[3:0])) :
                                        (req_pass_tc2 == `CA53_TAGCTL_PASS_L2_VICTIM) ? ({16{valid_tc2}} &
                                                                                         `CA53_L2_WAY_DEC(req_victim_way_tc2)) :
                                        (req_pass_tc2 == `CA53_TAGCTL_PASS_LOOKUP) ? ({16{valid_tc2}} & req_ways_read_tc2[31:16]) :
                                        l2_victim_invalid_eligible_ways_tc2);

  // Pick one of the eligible ways, assuming that the are all valid. If one or
  // more is invalid then this result will not be used.
  ca53_rr_reg_arb #(.WIDTH(16)) u_l2_victim_arb (
    .clk        (clk_tagctl),
    .reset_n    (reset_n),
    .enable_i   (victim_way_rr_en),
    .requests_i (l2_victim_eligible_ways_tc2),
    .arb_o      (l2_victim_way_tc2)
  );

  // Encode the way to use if all eligible victim ways are valid.
  assign l2_victim_valid_way_tc2 = `CA53_L2_WAY_ENC(l2_victim_way_tc2);

  assign l2_victim_tag_tc2 = (({33{l2_victim_way_tc2[15]}} & l2_tagram_way15_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[14]}} & l2_tagram_way14_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[13]}} & l2_tagram_way13_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[12]}} & l2_tagram_way12_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[11]}} & l2_tagram_way11_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[10]}} & l2_tagram_way10_rdata_i[32:0]) |
                              ({33{l2_victim_way_tc2[9]}}  & l2_tagram_way9_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[8]}}  & l2_tagram_way8_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[7]}}  & l2_tagram_way7_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[6]}}  & l2_tagram_way6_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[5]}}  & l2_tagram_way5_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[4]}}  & l2_tagram_way4_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[3]}}  & l2_tagram_way3_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[2]}}  & l2_tagram_way2_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[1]}}  & l2_tagram_way1_rdata_i[32:0])  |
                              ({33{l2_victim_way_tc2[0]}}  & l2_tagram_way0_rdata_i[32:0]));

  assign l2_victim_invalid_ways_tc2 = l2_victim_invalid_eligible_ways_tc2 & ~l2_valid_ways_tc2;

  // Choose one of the invalid ways (if any), it doesn't matter which, and encode the way.
  assign l2_victim_invalid_way_tc2 = `CA53_L2_WAY_PICK(l2_victim_invalid_ways_tc2);

  assign l2_victim_valid_tc2 = ~|l2_victim_invalid_ways_tc2;

  assign victim_tag_sel_req_tc2 = ((req_pass_tc2 == `CA53_TAGCTL_PASS_VICTIM) & ~tagctl_mbistreq);

  assign victim_tag_sel_l1_tc2 = tagctl_mbistreq ? tagctl_mbistarray[6] :
                                                   (((req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                                                     ~((req_type_tc2 == `CA53_AFB_REQ_READONCE) |
                                                       (req_type_tc2 == `CA53_AFB_REQ_READNONE) |
                                                       (req_type_tc2 == `CA53_AFB_REQ_WRITEUNIQUE) |
                                                       (req_type_tc2 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                                       (((req_type_tc2 == `CA53_AFB_REQ_CLEANSETWAY) |
                                                         (req_type_tc2 == `CA53_AFB_REQ_CLEANINVSETWAY)) &
                                                        req_addr1_tc2[1]))) |
                                                    (`CA53_REQBUF_IS_TAGECC(req_id_tc2) & ~ecc_tagctl_l2_tc0));

  assign victim_tag_sel_l2_tc2 = tagctl_mbistreq ? ~tagctl_mbistarray[6] :
                                                   ~(victim_tag_sel_l1_tc2 | victim_tag_sel_req_tc2);

  // Construct the victim address from the tag and index, according to the cache size.
  assign victim_tag_tc2 = (({35{victim_tag_sel_req_tc2}} & {5'b00000, l2_tag_value_tc2, 2'b00}) |
                           ({35{victim_tag_sel_l1_tc2}}  & {2'b00, l1_victim_tag_tc2}) |
                           ({35{victim_tag_sel_l2_tc2}}  & {l2_victim_tag_tc2, 2'b00}));

  assign victim_index_tc2 = ((req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                             ~((req_type_tc2 == `CA53_AFB_REQ_READONCE) |
                               (req_type_tc2 == `CA53_AFB_REQ_READNONE) |
                               (req_type_tc2 == `CA53_AFB_REQ_WRITEUNIQUE) |
                               (((req_type_tc2 == `CA53_AFB_REQ_CLEANSETWAY) |
                                 (req_type_tc2 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                 (req_type_tc2 == `CA53_AFB_SNP_CLEANINVSETWAY)) &
                                ~|l1_victim_cpu_en_tc2))) ? {3'b000, req_addr1_tc2[13:11] & tagctl_l1_dc_size} :
                                                            {req_addr1_tc2[16:13] & tagctl_l2_size, req_addr1_tc2[12:11]};

  generate if (CPU_CACHE_PROTECTION) begin : g_ecc_l1_tag_tc2
    assign l1_victim_tag_ecc_tc2 = (({7{l1_victim_way_tc2[15]}} & l1d_tagram_cpu3_way3_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[14]}} & l1d_tagram_cpu3_way2_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[13]}} & l1d_tagram_cpu3_way1_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[12]}} & l1d_tagram_cpu3_way0_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[11]}} & l1d_tagram_cpu2_way3_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[10]}} & l1d_tagram_cpu2_way2_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[9]}}  & l1d_tagram_cpu2_way1_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[8]}}  & l1d_tagram_cpu2_way0_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[7]}}  & l1d_tagram_cpu1_way3_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[6]}}  & l1d_tagram_cpu1_way2_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[5]}}  & l1d_tagram_cpu1_way1_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[4]}}  & l1d_tagram_cpu1_way0_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[3]}}  & l1d_tagram_cpu0_way3_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[2]}}  & l1d_tagram_cpu0_way2_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[1]}}  & l1d_tagram_cpu0_way1_rdata_i[39:33]) |
                                    ({7{l1_victim_way_tc2[0]}}  & l1d_tagram_cpu0_way0_rdata_i[39:33]));
  end else begin : g_n_ecc_l1_tag_tc2
    assign l1_victim_tag_ecc_tc2 = {7{1'b0}};
  end endgenerate

  generate if (SCU_CACHE_PROTECTION) begin : g_ecc_l2_tag_tc2
    assign l2_victim_tag_ecc_tc2 = (({7{l2_victim_way_tc2[15]}} & l2_tagram_way15_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[14]}} & l2_tagram_way14_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[13]}} & l2_tagram_way13_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[12]}} & l2_tagram_way12_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[11]}} & l2_tagram_way11_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[10]}} & l2_tagram_way10_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[9]}}  & l2_tagram_way9_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[8]}}  & l2_tagram_way8_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[7]}}  & l2_tagram_way7_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[6]}}  & l2_tagram_way6_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[5]}}  & l2_tagram_way5_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[4]}}  & l2_tagram_way4_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[3]}}  & l2_tagram_way3_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[2]}}  & l2_tagram_way2_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[1]}}  & l2_tagram_way1_rdata_i[39:33]) |
                                    ({7{l2_victim_way_tc2[0]}}  & l2_tagram_way0_rdata_i[39:33]));
  end else begin : g_n_ecc_l2_tag_tc2
    assign l2_victim_tag_ecc_tc2 = {7{1'b0}};
  end endgenerate

  assign victim_tag_ecc_tc2 = (tagctl_mbistreq ? tagctl_mbistarray[6] :
                                                 ~ecc_tagctl_l2_tc0) ? l1_victim_tag_ecc_tc2 :
                                                                       l2_victim_tag_ecc_tc2;

  // Start an L2 data RAM access speculatively for requests that benefit from
  // returning the critical word to the CPU as early as possible, provided that
  // nothing else is accessing the RAM this cycle.
  assign tagctl_l2dataram_req_tc2 = (valid_tc2 &
                                     ((req_type_tc2 == `CA53_AFB_REQ_READSHARED) |
                                      (req_type_tc2 == `CA53_AFB_REQ_READUNIQUE) |
                                      (req_type_tc2 == `CA53_AFB_REQ_READONCE) |
                                      (req_type_tc2 == `CA53_AFB_SNP_READONCE) |
                                      (req_type_tc2 == `CA53_AFB_SNP_READSHARED) |
                                      (req_type_tc2 == `CA53_AFB_SNP_READCLEAN) |
                                      (req_type_tc2 == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                      (req_type_tc2 == `CA53_AFB_SNP_READUNIQUE)) &
                                     (req_pass_tc2 == `CA53_TAGCTL_PASS_SERIALISE) &
                                     ~|ramctl_req &
                                     ~cpuslv_snp_l2db_hz_tc2 &
                                     ~flush_tc2);

  assign tagctl_l2dataram_req_tc2_o = tagctl_l2dataram_req_tc2;

  assign l2_data_access_tc2 = tagctl_l2dataram_req_tc2 & ~ramctl_mask_tc2_i;

  // Send the data RAM request to the RAM controller. These outputs should be
  // zero when the ramctl asks us to mask them, so that they can be combined
  // with other requests with a single gate.
  assign tagctl_l2dataram_index_o = req_addr1_tc2[16:6] & ~{11{ramctl_mask_tc2_i}};

  assign tagctl_l2dataram_way_o = ({16{l2_data_access_tc2}} &
                                   l2_valid_ways_tc2 &
                                   l2_comp_ways_tc2);

  assign req_single_tc2 = ((active_afb0_tc2 & afb0_req_single) |
                           (active_afb1_tc2 & afb1_req_single) |
                           (active_afb2_tc2 & afb2_req_single) |
                           (active_afb3_tc2 & afb3_req_single) |
                           (active_afb4_tc2 & afb4_req_single) |
                           (active_afb5_tc2 & afb5_req_single));

  assign tagctl_l2dataram_banks_o = req_single_tc2 ? (8'h03 << {req_addr1_tc2[5:4], 1'b0}) : 8'hff;

  // If the L2 index matches a request in tc3 that is in the process of picking
  // an L2 victim then this request must hazard to ensure it doesn't also pick
  // the same victim. If an L2 set/way op is being serialised and its way
  // matches one already in use then it must hazard. If any request that might
  // need to pick a victim way will also hazard if all ways of that index are
  // currently in use.
  assign victim_hz_tc2 = ((valid_tc3 &
                           (((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                             (((req_type_tc3 == `CA53_AFB_REQ_READSHARED) |
                               (req_type_tc3 == `CA53_AFB_REQ_READUNIQUE) |
                               (req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                               (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                               (req_type_tc3 == `CA53_AFB_REQ_ECCCLEAN)) &
                              l1_victim_hit_tc3)) |
                            ((((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                               ((req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                                (req_type_tc3 == `CA53_AFB_SNP_CLEANINVSETWAY))) |
                              ((req_pass_tc3 == `CA53_TAGCTL_PASS_L2_VICTIM) &
                               (req_type_tc3 == `CA53_AFB_REQ_READSHARED) |
                               (req_type_tc3 == `CA53_AFB_REQ_READUNIQUE) |
                               (req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                               (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                               (req_type_tc3 == `CA53_AFB_REQ_ECCCLEAN))) &
                             l2_victim_valid_tc3)) &
                           ({tagctl_l2_size & req_addr1_tc2[16:13], req_addr1_tc2[12:6]} ==
                            {tagctl_l2_size & victim_addr_tc3[16:13], victim_addr_tc3[12:6]}) &
                           ~((req_type_tc2 == `CA53_AFB_REQ_DMB) |
                             (req_type_tc2 == `CA53_AFB_REQ_DSB) |
                             (req_type_tc2 == `CA53_AFB_REQ_DVM) |
                             (req_type_tc2 == `CA53_AFB_SNP_DVM_MESSAGE) |
                             (req_type_tc2 == `CA53_AFB_SNP_DVM_COMPLETE) |
                             (req_type_tc2 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                             (req_type_tc2 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                             (req_type_tc2 == `CA53_AFB_REQ_CLEANSETWAY) |
                             (req_type_tc2 == `CA53_AFB_REQ_ECCCLEAN))) |
                          (~((req_type_tc2 == `CA53_AFB_REQ_DMB) |
                             (req_type_tc2 == `CA53_AFB_REQ_DSB) |
                             (req_type_tc2 == `CA53_AFB_REQ_DVM) |
                             `CA53_REQBUF_IS_SNOOP(req_id_tc2) |
                             (L2_CACHE == 0)) &
                           |req_ways_read_tc2[31:16] &
                           ~|l2_victim_invalid_eligible_ways_tc2));

  assign tagctl_mbistarray = req_addr1_tc2[`CA53_MBIST0_ADDR_W+6 +: 9];

  assign tagctl_mbistreq_o = tagctl_mbistreq;

  // Select between SCU tag RAMs, or anything else
  assign tagctl_mbist_sel_o = ((tagctl_mbistarray[6:4] == 3'b011) |
                               (tagctl_mbistarray[6:4] == 3'b100));

  // ECC checking. The syndrome is calculated in tc2, then qualified in tc3 to
  // decide if there was an error.
  generate if (CPU_CACHE_PROTECTION) begin : g_cpu_ecc
    for (i = 0; i < 16; i = i + 1) begin : g_cpu_ecc_check
      if (i < (NUM_CPUS*4)) begin : g_cpu

        ca53_ecc_check33 u_ecc_check (
          .data_i     (l1_tagram_rdata_tc2[i]),
          .ecc_i      (l1_tagram_rdata_ecc_tc2[i]),
          .syndrome_o (l1_tag_syndrome_tc2[7*i+:7])
        );

      end else begin : g_n_cpu
        assign l1_tag_syndrome_tc2[7*i+:7] = {7{zero}};
      end
    end

  end endgenerate

  generate if (SCU_CACHE_PROTECTION) begin : g_scu_ecc
    for (i = 0; i < 16; i = i + 1) begin : g_scu_ecc_check

      ca53_ecc_check33 u_ecc_check (
        .data_i     (l2_tagram_rdata_tc2[i]),
        .ecc_i      (l2_tagram_rdata_ecc_tc2[i]),
        .syndrome_o (l2_tag_syndrome_tc2[7*i+:7])
      );

    end


    assign req_l2_write_state_tc1 = {req_attrs_tc1[1], ~req_attrs_tc1[0],
                                     req_cluster_unique_tc1,
                                     req_dirty_tc1,
                                     `CA53_MEM_OUTER_WA(req_attrs_tc1)};

    always @(posedge clk_tagctl)
    if (valid_tc1) begin
      req_l2_write_state_tc2 <= req_l2_write_state_tc1;
    end

    assign req_l2_write_data_tc2 = {req_l2_write_state_tc2,
                                    req_addr1_tc2[40:17],
                                    req_addr1_tc2[16:13] & ~tagctl_l2_size};

    ca53_ecc_generate33 u_ecc_generate (
      .data_i (req_l2_write_data_tc2),
      .ecc_o  (req_l2_ecc_tc2)
    );

  end else begin : g_n_scu_ecc_calc_tc2

    assign req_l2_ecc_tc2 = {7{1'b0}};

  end endgenerate

  //----------------------------------------------------------------------------
  //  tc3
  //----------------------------------------------------------------------------


  // Move the tc2 contents into tc3.
  assign next_valid_tc3 = valid_tc2 & ~flush_tc2;

  assign next_afb_tc3 = afb_tc2 & ~{6{flush_tc2}};

  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    valid_tc3 <= 1'b0;
    afb_tc3   <= 6'b000000;
  end else if (tagctl_active) begin
    valid_tc3 <= next_valid_tc3;
    afb_tc3   <= next_afb_tc3;
  end

  always @(posedge clk_tagctl)
  if (valid_tc2) begin
    req_id_tc3                   <= req_id_tc2;
    req_type_tc3                 <= req_type_tc2;
    req_pass_tc3                 <= req_pass_tc2;
    req_addr1_tc3                <= req_addr1_tc2[16:6];
    l1_cu_ways_tc3               <= l1_cu_ways_tc2;
    l1_state0_ways_tc3           <= l1_state0_ways_tc2;
    l1_state1_ways_tc3           <= l1_state1_ways_tc2;
    l1_comp_ways_tc3             <= l1_comp_ways_tc2;
    l1_lookup_cpu_en_tc3         <= l1_lookup_cpu_en_tc2;
    l1_victim_cpu_en_tc3         <= l1_victim_cpu_en_tc2;
    l1_ecc_victim_way_tc3        <= l1_ecc_victim_way_tc2;
    victim_tag_tc3               <= victim_tag_tc2;
    victim_index_tc3             <= victim_index_tc2;
    req_victim_hz_tc3            <= victim_hz_tc2;
    tagctl_disable_evict_tc3     <= gov_disable_evict_i;
    tagctl_enable_writeevict_tc3 <= gov_enable_writeevict_i;
  end

  generate if (L2_CACHE) begin : g_l2cc_tc3

    always @(posedge clk_tagctl)
    if (valid_tc2) begin
      l2_hit_ways_tc3                     <= l2_hit_ways_tc2;
      l2_dirty_ways_tc3                   <= l2_dirty_ways_tc2;
      l2_cu_ways_tc3                      <= l2_cu_ways_tc2;
      l2_state0_ways_tc3                  <= l2_state0_ways_tc2;
      l2_state1_ways_tc3                  <= l2_state1_ways_tc2;
      l2_alloc_ways_tc3                   <= l2_alloc_ways_tc2;
      l2_victim_valid_tc3                 <= l2_victim_valid_tc2;
      l2_victim_valid_way_tc3             <= l2_victim_valid_way_tc2;
      l2_victim_invalid_way_tc3           <= l2_victim_invalid_way_tc2;
      l2_victim_invalid_eligible_ways_tc3 <= l2_victim_invalid_eligible_ways_tc2;
    end

  end else begin : g_n_l2cc_tc3

    always @*
    begin
      l2_hit_ways_tc3                     = {16{zero}};
      l2_dirty_ways_tc3                   = {16{zero}};
      l2_cu_ways_tc3                      = {16{zero}};
      l2_state0_ways_tc3                  = {16{zero}};
      l2_state1_ways_tc3                  = {16{zero}};
      l2_alloc_ways_tc3                   = {16{zero}};
      l2_victim_valid_tc3                 = zero;
      l2_victim_valid_way_tc3             = {4{zero}};
      l2_victim_invalid_way_tc3           = {4{zero}};
      l2_victim_invalid_eligible_ways_tc3 = {16{zero}};
    end

  end endgenerate

  generate for (i = 0; i < 16; i = i + 1) begin : g_cpu_tc3

    if ((i < (4*NUM_CPUS)) && (CPU_CACHE_PROTECTION != 0)) begin : g_cpu_ecc_tc3

      always @(posedge clk_tagctl)
      if (valid_tc2) begin
        l1_tag_syndrome_cpu_tc3[7*i+:7] <= l1_tag_syndrome_tc2[7*i+:7];
      end

      assign l1_tag_syndrome_tc3[7*i+:7] = l1_tag_syndrome_cpu_tc3[7*i+:7];

    end else begin : g_n_cpu_ecc_tc3

      assign l1_tag_syndrome_tc3[7*i+:7] = {7{1'b0}};

    end

  end endgenerate

  generate if (SCU_CACHE_PROTECTION[0] || CPU_CACHE_PROTECTION[0]) begin : g_scu_ecc_tc3

    always @(posedge clk_tagctl)
    if (valid_tc2) begin
      req_ways_read_tc3   <= req_ways_read_tc2;
      victim_tag_ecc_tc3  <= victim_tag_ecc_tc2;
    end

  end else begin : g_n_scu_ecc_tc3

    always @*
    begin
      req_ways_read_tc3   = {32{zero}};
      victim_tag_ecc_tc3  = {7{zero}};
    end

  end endgenerate

  generate if (SCU_CACHE_PROTECTION) begin : g_scu_l2_ecc_tc3

    always @(posedge clk_tagctl)
    if (valid_tc2) begin
      l2_tag_syndrome_tc3 <= l2_tag_syndrome_tc2;
    end

  end else begin : g_n_scu_l2_ecc_tc3

    always @*
    begin
      l2_tag_syndrome_tc3 = {112{zero}};
    end

  end endgenerate

  generate for (i = 0; i < 16; i = i + 1) begin : g_ecc_tc3
    assign l1_tag_err_tc3[i] = req_ways_read_tc3[i]    & |l1_tag_syndrome_tc3[7*i+:7];
    assign l2_tag_err_tc3[i] = req_ways_read_tc3[i+16] & |l2_tag_syndrome_tc3[7*i+:7];
  end endgenerate

  assign ecc_err_tc3 = valid_tc3 & ((|l1_tag_err_tc3) | (|l2_tag_err_tc3)) & ~`CA53_REQBUF_IS_TAGECC(req_id_tc3);

  assign tagctl_ecc_err_tc3_o = ecc_err_tc3;

  assign flush_raw_tc3 = (valid_tc3 &
                          (((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                            (req_victim_hz_tc3 | ncoh_write_hz_tc3)) |
                           (((req_pass_tc3 == `CA53_TAGCTL_PASS_LOOKUP) &
                             (req_type_tc3 == `CA53_AFB_REQ_WRITEUNIQUE)) &
                            req_victim_hz_tc3)));

  // If tc4 is being flushed then any unserialised requests in tc3 must also be
  // flushed.
  assign flush_tc3 = (flush_raw_tc3 |
                      (valid_tc3 &
                       ((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                        flush_tc4 &
                        ~(l2db_flush_tc4 & `CA53_REQBUF_IS_SNOOP(req_id_tc3)))));

  assign l2db_flush_tc3 = (afb0_l2db_hazard_tc3 |
                           afb1_l2db_hazard_tc3 |
                           afb2_l2db_hazard_tc3 |
                           afb3_l2db_hazard_tc3 |
                           afb4_l2db_hazard_tc3 |
                           afb5_l2db_hazard_tc3);

  assign tagctl_slv_flush_tc3_o = flush_tc3;

  // Because a WriteUnique may need a second lookup, and may hazard on L2 way on
  // the second lookup, we must detect and flush on the first lookup if the way
  // that hit is already in use.
  assign victim_flush_tc3 = (valid_tc3 &
                             (req_type_tc3 == `CA53_AFB_REQ_WRITEUNIQUE) &
                             (req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                             |(l2_hit_ways_tc3 & ~l2_victim_invalid_eligible_ways_tc3));

  // Only some request passes require an AFB, and for those we must tell the
  // AFB it has reached tc3 and if it has been flushed.

  assign active_afb0_tc3 = afb_tc3[0];
  assign active_afb1_tc3 = afb_tc3[1];
  assign active_afb2_tc3 = afb_tc3[2];
  assign active_afb3_tc3 = afb_tc3[3];
  assign active_afb4_tc3 = afb_tc3[4];
  assign active_afb5_tc3 = afb_tc3[5];

  assign flush_afb0_tc3 = active_afb0_tc3 & flush_tc3;
  assign flush_afb1_tc3 = active_afb1_tc3 & flush_tc3;
  assign flush_afb2_tc3 = active_afb2_tc3 & flush_tc3;
  assign flush_afb3_tc3 = active_afb3_tc3 & flush_tc3;
  assign flush_afb4_tc3 = active_afb4_tc3 & flush_tc3;
  assign flush_afb5_tc3 = active_afb5_tc3 & flush_tc3;

  generate if (ACE) begin : g_ace
    // Keep a count of the number of serialised non-coherent writes, that have
    // not recieved a write response. This is used to prevent more than 15 such
    // writes being outstanding at a time, so that there is always at least one
    // waddr free for coherent requests to make progress, and thus snoops cannot
    // block indefinitely even if non-coherent writes do not make progress.
    assign ncoh_write_tc3 = (valid_tc3 & ~flush_tc3 &
                             (req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                             (req_type_tc3 == `CA53_AFB_REQ_WRITENOSNOOP));

    assign ncoh_writes_en_tc3 = ncoh_write_tc3 ^ master_ncoh_db_i;

    assign next_ncoh_writes_tc3 = ncoh_writes_tc3 + (ncoh_write_tc3 ? 4'b0001 : 4'b1111);

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ncoh_writes_tc3 <= 4'b0000;
    end else if (ncoh_writes_en_tc3) begin
      ncoh_writes_tc3 <= next_ncoh_writes_tc3;
    end

    assign ncoh_write_hz_tc3 = &ncoh_writes_tc3 & (req_type_tc3 == `CA53_AFB_REQ_WRITENOSNOOP);

  end else begin : g_skyros

    assign ncoh_write_hz_tc3 = 1'b0;
    assign ncoh_writes_en_tc3 = 1'b0;

  end endgenerate

  assign l1_lookup_ways_en_tc3 = {{4{l1_lookup_cpu_en_tc3[3]}},
                                  {4{l1_lookup_cpu_en_tc3[2]}},
                                  {4{l1_lookup_cpu_en_tc3[1]}},
                                  {4{l1_lookup_cpu_en_tc3[0]}}};

  // Combine the valid bits and the comparator outputs in tc3, to help the timing in tc2.
  assign l1_lookup_hit_ways_tc3 = l1_lookup_ways_en_tc3 & l1_comp_ways_tc3 & (l1_state0_ways_tc3 | l1_state1_ways_tc3);

  assign l1_lookup_hit_cpus_tc3 = {|l1_lookup_hit_ways_tc3[15:12],
                                   |l1_lookup_hit_ways_tc3[11:8],
                                   |l1_lookup_hit_ways_tc3[7:4],
                                   |l1_lookup_hit_ways_tc3[3:0]};

  assign l1_lookup_hit_tc3 = |l1_lookup_hit_cpus_tc3;

  // For the requestor's victim lookup, we don't need the comparator outputs,
  // just the valid bits.
  assign l1_victim_hit_ways_tc3 = {{4{l1_victim_cpu_en_tc3[3]}},
                                   {4{l1_victim_cpu_en_tc3[2]}},
                                   {4{l1_victim_cpu_en_tc3[1]}},
                                   {4{l1_victim_cpu_en_tc3[0]}}} & (l1_state0_ways_tc3 | l1_state1_ways_tc3);

  assign l1_victim_hit_cpus_tc3 = {|l1_victim_hit_ways_tc3[15:12],
                                   |l1_victim_hit_ways_tc3[11:8],
                                   |l1_victim_hit_ways_tc3[7:4],
                                   |l1_victim_hit_ways_tc3[3:0]};

  assign l1_victim_hit_tc3 = |l1_victim_hit_cpus_tc3;

  assign l1_hit_ways_tc3 = l1_lookup_hit_ways_tc3 | l1_victim_hit_ways_tc3;

  assign tagctl_l1_hit_ways_tc3_o = l1_hit_ways_tc3;
  assign tagctl_l2_hit_ways_tc3_o = l2_hit_ways_tc3;

  assign l2_hit_tc3 = |l2_hit_ways_tc3;

  // Work out if an L2 hit is a dirty line. We cannot know if L1 hits are dirty
  // or not until a snoop has been done.
  assign l2_hit_dirty_tc3 = |(l2_hit_ways_tc3 & l2_dirty_ways_tc3);

  assign l2_dirty_tc3 = (((req_pass_tc3 == `CA53_TAGCTL_PASS_L2_VICTIM) & ~|l2_hit_ways_tc3) |
                         (req_type_tc3 == `CA53_AFB_REQ_READONCE) |
                         (req_type_tc3 == `CA53_AFB_REQ_READNONE) |
                         (req_type_tc3 == `CA53_AFB_REQ_WRITEUNIQUE)) ? l2_victim_dirty_tc3 :
                        (((req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                          (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                          (req_type_tc3 == `CA53_AFB_SNP_CLEANINVSETWAY)) &
                         (req_pass_tc3 != `CA53_TAGCTL_PASS_L2_VICTIM)) ? |l2_dirty_ways_tc3 :
                                                                          l2_hit_dirty_tc3;
  assign tagctl_l2_dirty_tc3_o = l2_dirty_tc3;


  assign tagctl_inner_sh_tc3 = ((|(l1_lookup_hit_ways_tc3 & l1_state1_ways_tc3)) |
                                (|(l2_hit_ways_tc3        & l2_state1_ways_tc3)));
  assign tagctl_outer_sh_tc3 = ((|(l1_lookup_hit_ways_tc3 & l1_state1_ways_tc3 & l1_state0_ways_tc3)) |
                                (|(l2_hit_ways_tc3        & l2_state1_ways_tc3 & l2_state0_ways_tc3)));

  // Output the shareability, in the standard attributes format.
  assign tagctl_hit_shareability_tc3 = {tagctl_inner_sh_tc3, tagctl_inner_sh_tc3 & ~tagctl_outer_sh_tc3};

  assign tagctl_shareability_tc3_o = tagctl_hit_shareability_tc3;

  // If there is an invalid way available, pick that as the victim way, otherwise use the way selected in tc2.
  assign l2_victim_way_tc3 = l2_victim_valid_tc3 ? l2_victim_valid_way_tc3 : l2_victim_invalid_way_tc3;

  assign tagctl_l2_victim_way_tc3_o = l2_victim_way_tc3;


  assign l2_victim_shareability_tc3 = {l2_state1_ways_tc3[l2_victim_way_tc3], ~l2_state0_ways_tc3[l2_victim_way_tc3]};

  assign tagctl_l2_victim_shareability_tc3_o = l2_victim_shareability_tc3;

  // Output the outer allocation hint.
  assign l2_victim_alloc_tc3 = l2_alloc_ways_tc3[l2_victim_way_tc3];

  assign tagctl_l2_victim_alloc_tc3_o = l2_victim_alloc_tc3; 

  assign tagctl_l2_alloc_tc3_o = |(l2_hit_ways_tc3 & l2_alloc_ways_tc3);

  assign tagctl_l2_victim_valid_tc3_o = l2_victim_valid_tc3;

  assign l2_victim_dirty_tc3 = l2_dirty_ways_tc3[l2_victim_way_tc3];

  assign tagctl_l2_victim_dirty_tc3_o = l2_victim_dirty_tc3;

  assign l2_victim_cu_tc3 = l2_cu_ways_tc3[l2_victim_way_tc3];

  assign tagctl_l2_victim_cu_tc3_o = l2_victim_cu_tc3;

  assign tagctl_force_cluster_unique_tc3 = ((|l1_lookup_hit_ways_tc3) |
                                            (|l2_hit_ways_tc3)) ? (~tagctl_broadcastouter |
                                                                   (~tagctl_broadcastinner & ~tagctl_outer_sh_tc3) |
                                                                   ~tagctl_inner_sh_tc3) :
                                                                  ((active_afb0_tc3 & afb0_force_cluster_unique_tc3) |
                                                                   (active_afb1_tc3 & afb1_force_cluster_unique_tc3) |
                                                                   (active_afb2_tc3 & afb2_force_cluster_unique_tc3) |
                                                                   (active_afb3_tc3 & afb3_force_cluster_unique_tc3) |
                                                                   (active_afb4_tc3 & afb4_force_cluster_unique_tc3) |
                                                                   (active_afb5_tc3 & afb5_force_cluster_unique_tc3));

  // If any L1 or L2 line hits then the cluster unique status must be
  // consistent across all hits.
  assign cluster_unique_tc3 = (|{l1_lookup_hit_ways_tc3 & l1_cu_ways_tc3,
                                 l2_hit_ways_tc3 & l2_cu_ways_tc3} |
                               tagctl_force_cluster_unique_tc3);

  assign tagctl_cluster_unique_tc3_o = cluster_unique_tc3;

  assign tagctl_l1_victim_cluster_unique_tc3_o = |({{4{l1_victim_cpu_en_tc3[3]}},
                                                    {4{l1_victim_cpu_en_tc3[2]}},
                                                    {4{l1_victim_cpu_en_tc3[1]}},
                                                    {4{l1_victim_cpu_en_tc3[0]}}} & l1_cu_ways_tc3);

  assign tagctl_l1_victim_shareability_tc3_o = {|({{4{l1_victim_cpu_en_tc3[3]}},
                                                   {4{l1_victim_cpu_en_tc3[2]}},
                                                   {4{l1_victim_cpu_en_tc3[1]}},
                                                   {4{l1_victim_cpu_en_tc3[0]}}} & l1_state1_ways_tc3),
                                                |({{4{l1_victim_cpu_en_tc3[3]}},
                                                   {4{l1_victim_cpu_en_tc3[2]}},
                                                   {4{l1_victim_cpu_en_tc3[1]}},
                                                   {4{l1_victim_cpu_en_tc3[0]}}} & (l1_state1_ways_tc3 &
                                                                                    ~l1_state0_ways_tc3))};

  assign victim_addr_tc3 = {victim_tag_tc3[29:6],
                            victim_tag_tc3[5:0] | victim_index_tc3,
                            req_addr1_tc3[10:6]};

  // Send the victim address to the slvs and master for hazard checking.
  assign tagctl_addr_tc3 = victim_addr_tc3[40:6];

  assign tagctl_addr_tc3_o = tagctl_addr_tc3;

  assign tagctl_addr_valid_tc3 = valid_tc3 & ~((req_type_tc3 == `CA53_AFB_REQ_DMB) |
                                               (req_type_tc3 == `CA53_AFB_REQ_DSB) |
                                               (req_type_tc3 == `CA53_AFB_REQ_DVM) |
                                               (req_type_tc3 == `CA53_AFB_SNP_DVM_MESSAGE) |
                                               (req_type_tc3 == `CA53_AFB_SNP_DVM_COMPLETE));

  assign tagctl_addr_valid_tc3_o = tagctl_addr_valid_tc3;

  assign tagctl_reqbufid_tc3_o = req_id_tc3;

  assign tagctl_noncoh_serialised_tc3_o = (valid_tc3 & ~flush_tc3 &
                                           (req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                                           ((req_type_tc3 == `CA53_AFB_REQ_WRITENOSNOOP) |
                                            (req_type_tc3 == `CA53_AFB_REQ_CLEANSHARED) |
                                            (req_type_tc3 == `CA53_AFB_REQ_CLEANINVALID) |
                                            (req_type_tc3 == `CA53_AFB_REQ_MAKEINVALID) |
                                            (req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                                            (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY)));

  // Maintain a round robin counter to share between the AFBs for picking one
  // CPU in preference, if a snoop must arbitrarily pick one of several CPUs.
  // Because this decision is made in the AFB in tc3, and then stored, we can
  // share the counter because only one AFB can be in tc3 at a time.
  assign round_robin_tc3_en = (afb0_update_rr_tc3 |
                               afb1_update_rr_tc3 |
                               afb2_update_rr_tc3 |
                               afb3_update_rr_tc3 |
                               afb4_update_rr_tc3 |
                               afb5_update_rr_tc3);

  assign cpu_count = NUM_CPUS[1:0] - 2'b01;

  assign next_round_robin_tc3 = (round_robin_tc3 == cpu_count) ? 2'b00 : (round_robin_tc3 + 2'b01);

  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    round_robin_tc3 <= 2'b00;
  end else if (round_robin_tc3_en) begin
    round_robin_tc3 <= next_round_robin_tc3;
  end

  assign tagctl_snoop_data_cpu_tc4_o = (({2{active_afb0_tc4}} & afb0_snoop_data_cpu_tc4) |
                                        ({2{active_afb1_tc4}} & afb1_snoop_data_cpu_tc4) |
                                        ({2{active_afb2_tc4}} & afb2_snoop_data_cpu_tc4) |
                                        ({2{active_afb3_tc4}} & afb3_snoop_data_cpu_tc4) |
                                        ({2{active_afb4_tc4}} & afb4_snoop_data_cpu_tc4) |
                                        ({2{active_afb5_tc4}} & afb5_snoop_data_cpu_tc4));

  assign tagctl_mbistoutdata_o = {victim_tag_ecc_tc3, tagctl_mbistarray[6] ? victim_tag_tc3[32:0] :
                                                                             victim_tag_tc3[34:2]};

  assign serialised_l2db_tc3 = (valid_tc3 & ~flush_tc3 &
                                (req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                                ((req_type_tc3 == `CA53_AFB_REQ_WRITENOSNOOP) |
                                 (req_type_tc3 == `CA53_AFB_REQ_WRITEUNIQUE) |
                                 (req_type_tc3 == `CA53_AFB_REQ_DVM)));

  //----------------------------------------------------------------------------
  //  tc4
  //----------------------------------------------------------------------------

  // Always move the tc3 contents into tc4 unless flushed.
  assign next_valid_tc4 = valid_tc3 & ~flush_tc3;

  assign next_afb_tc4 = afb_tc3 & ~{6{flush_tc3}};

  assign next_allow_flush_tc4 = (next_valid_tc4 &
                                 (l2db_flush_tc3 | ecc_err_tc3 | victim_flush_tc3 |
                                  ((req_pass_tc3 == `CA53_TAGCTL_PASS_SERIALISE) &
                                   ((l1_victim_hit_tc3 &
                                     ((req_type_tc3 == `CA53_AFB_REQ_READSHARED) |
                                      (req_type_tc3 == `CA53_AFB_REQ_READUNIQUE))) |
                                    ((l1_victim_hit_tc3 | l2_victim_valid_tc3) &
                                     ((req_type_tc3 == `CA53_AFB_REQ_CLEANSETWAY) |
                                      (req_type_tc3 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                      (req_type_tc3 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                      (req_type_tc3 == `CA53_AFB_REQ_ECCCLEAN)))))));

  assign next_early_flush_tc4 = (next_allow_flush_tc4 &
                                 (l2db_flush_tc3 | ecc_err_tc3 | victim_flush_tc3 |
                                  afb0_hz_tc3 | afb1_hz_tc3 | afb2_hz_tc3 |
                                  afb3_hz_tc3 | afb4_hz_tc3 | afb5_hz_tc3));

  assign next_l2db_flush_tc4 = l2db_flush_tc3 & ~`CA53_REQBUF_IS_SNOOP(req_id_tc3);

  always @(posedge clk_tagctl or negedge reset_n)
  if (~reset_n) begin
    valid_tc4       <= 1'b0;
    afb_tc4         <= 6'b000000;
    allow_flush_tc4 <= 1'b0;
    l2db_flush_tc4  <= 1'b0;
  end else if (tagctl_active) begin
    valid_tc4       <= next_valid_tc4;
    afb_tc4         <= next_afb_tc4;
    allow_flush_tc4 <= next_allow_flush_tc4;
    l2db_flush_tc4  <= next_l2db_flush_tc4;
  end

  always @(posedge clk_tagctl)
  if (tagctl_active) begin
    early_flush_tc4     <= next_early_flush_tc4;
    serialised_l2db_tc4 <= serialised_l2db_tc3;
  end

  // Only request types that read an L1 victim on the initial pass need to hazard in tc4.
  assign flush_tc4 = (allow_flush_tc4 &
                      (early_flush_tc4 |
                       cpuslv0_hz_tc4_i |
                       cpuslv1_hz_tc4_i |
                       cpuslv2_hz_tc4_i |
                       cpuslv3_hz_tc4_i |
                       acpslv_hz_tc4_i |
                       snpslv_hz_tc4_i |
                       master_hz_tc4_i));

  assign tagctl_slv_flush_tc4_o = flush_tc4;

  assign tagctl_slv_early_flush_tc4_o = early_flush_tc4;

  // Only some request passes require an AFB, and for those we must tell the
  // AFB it has reached tc4 and if it has been flushed.
  assign active_afb0_tc4 = afb_tc4[0];
  assign active_afb1_tc4 = afb_tc4[1];
  assign active_afb2_tc4 = afb_tc4[2];
  assign active_afb3_tc4 = afb_tc4[3];
  assign active_afb4_tc4 = afb_tc4[4];
  assign active_afb5_tc4 = afb_tc4[5];

  assign flush_afb0_tc4 = active_afb0_tc4 & flush_tc4;
  assign flush_afb1_tc4 = active_afb1_tc4 & flush_tc4;
  assign flush_afb2_tc4 = active_afb2_tc4 & flush_tc4;
  assign flush_afb3_tc4 = active_afb3_tc4 & flush_tc4;
  assign flush_afb4_tc4 = active_afb4_tc4 & flush_tc4;
  assign flush_afb5_tc4 = active_afb5_tc4 & flush_tc4;

  assign tagctl_slv_l2db_hit_tc3_o = (afb0_slv_l2db_hit_tc3 |
                                      afb1_slv_l2db_hit_tc3 |
                                      afb2_slv_l2db_hit_tc3 |
                                      afb3_slv_l2db_hit_tc3 |
                                      afb4_slv_l2db_hit_tc3 |
                                      afb5_slv_l2db_hit_tc3);

  assign tagctl_slv_l2db_dirty_tc3_o = (afb0_slv_l2db_dirty_tc3 |
                                        afb1_slv_l2db_dirty_tc3 |
                                        afb2_slv_l2db_dirty_tc3 |
                                        afb3_slv_l2db_dirty_tc3 |
                                        afb4_slv_l2db_dirty_tc3 |
                                        afb5_slv_l2db_dirty_tc3);

  assign tagctl_slv_l2db_cu_tc3_o = (afb0_slv_l2db_cu_tc3 |
                                     afb1_slv_l2db_cu_tc3 |
                                     afb2_slv_l2db_cu_tc3 |
                                     afb3_slv_l2db_cu_tc3 |
                                     afb4_slv_l2db_cu_tc3 |
                                     afb5_slv_l2db_cu_tc3);

  assign tagctl_slv_l2db_tc3_o = (({4{active_afb0_tc3}} & afb0_slv_l2db) |
                                  ({4{active_afb1_tc3}} & afb1_slv_l2db) |
                                  ({4{active_afb2_tc3}} & afb2_slv_l2db) |
                                  ({4{active_afb3_tc3}} & afb3_slv_l2db) |
                                  ({4{active_afb4_tc3}} & afb4_slv_l2db) |
                                  ({4{active_afb5_tc3}} & afb5_slv_l2db));

  assign tagctl_slv_l2db_tc4_o = (({4{active_afb0_tc4}} & afb0_slv_l2db) |
                                  ({4{active_afb1_tc4}} & afb1_slv_l2db) |
                                  ({4{active_afb2_tc4}} & afb2_slv_l2db) |
                                  ({4{active_afb3_tc4}} & afb3_slv_l2db) |
                                  ({4{active_afb4_tc4}} & afb4_slv_l2db) |
                                  ({4{active_afb5_tc4}} & afb5_slv_l2db));

  assign tagctl_slv_victim_l2db_tc4_o = (({4{active_afb0_tc4}} & afb0_slv_victim_l2db_tc4) |
                                         ({4{active_afb1_tc4}} & afb1_slv_victim_l2db_tc4) |
                                         ({4{active_afb2_tc4}} & afb2_slv_victim_l2db_tc4) |
                                         ({4{active_afb3_tc4}} & afb3_slv_victim_l2db_tc4) |
                                         ({4{active_afb4_tc4}} & afb4_slv_victim_l2db_tc4) |
                                         ({4{active_afb5_tc4}} & afb5_slv_victim_l2db_tc4));

  assign tagctl_slv_snp_hz_tc4_o = (afb0_slv_snp_hz_tc4 |
                                    afb1_slv_snp_hz_tc4 |
                                    afb2_slv_snp_hz_tc4 |
                                    afb3_slv_snp_hz_tc4 |
                                    afb4_slv_snp_hz_tc4 |
                                    afb5_slv_snp_hz_tc4);

  assign tagctl_slv_snp_hz_id_tc4_o = (({5{active_afb0_tc4}} & afb0_slv_snp_hz_id_tc4) |
                                       ({5{active_afb1_tc4}} & afb1_slv_snp_hz_id_tc4) |
                                       ({5{active_afb2_tc4}} & afb2_slv_snp_hz_id_tc4) |
                                       ({5{active_afb3_tc4}} & afb3_slv_snp_hz_id_tc4) |
                                       ({5{active_afb4_tc4}} & afb4_slv_snp_hz_id_tc4) |
                                       ({5{active_afb5_tc4}} & afb5_slv_snp_hz_id_tc4));

  assign tagctl_slv_l2db_invalidated_tc4_o = (afb0_slv_l2db_invalidated_tc4 |
                                              afb1_slv_l2db_invalidated_tc4 |
                                              afb2_slv_l2db_invalidated_tc4 |
                                              afb3_slv_l2db_invalidated_tc4 |
                                              afb4_slv_l2db_invalidated_tc4 |
                                              afb5_slv_l2db_invalidated_tc4);

  assign tagctl_slv_l2db_cleaned_tc4_o = (afb0_slv_l2db_cleaned_tc4 |
                                          afb1_slv_l2db_cleaned_tc4 |
                                          afb2_slv_l2db_cleaned_tc4 |
                                          afb3_slv_l2db_cleaned_tc4 |
                                          afb4_slv_l2db_cleaned_tc4 |
                                          afb5_slv_l2db_cleaned_tc4);

  //----------------------------------------------------------------------------
  //  AFBs
  //----------------------------------------------------------------------------

  // Snoop requests from flushed AFBs will be suppressed, but to help
  // timing this is only done after arbitration.
  assign flush_afb = {flush_afb5_tc3 | flush_afb5_tc4,
                      flush_afb4_tc3 | flush_afb4_tc4,
                      flush_afb3_tc3 | flush_afb3_tc4,
                      flush_afb2_tc3 | flush_afb2_tc4,
                      flush_afb1_tc3 | flush_afb1_tc4,
                      flush_afb0_tc3 | flush_afb0_tc4};

  assign ac_ready_cpu = {cpuslv3_ac_ready_i,
                         cpuslv2_ac_ready_i,
                         cpuslv1_ac_ready_i,
                         cpuslv0_ac_ready_i};

  generate for (i = 0; i < 4; i = i + 1) begin : g_snoop_arb
    if (i < NUM_CPUS) begin : g_snoop_arb_cpu

      // If we have already arbitrated the first part of a two part DVM then we
      // must not arbitrate anything else until the second part is sent.
      assign dvm_mask[i] = {afb0_snoop_second_dvm[i] | afb1_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] |
                            afb3_snoop_second_dvm[i] | afb4_snoop_second_dvm[i] | afb5_snoop_second_dvm[i],
                            afb0_snoop_second_dvm[i] | afb1_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] |
                            afb3_snoop_second_dvm[i] | afb4_snoop_second_dvm[i],
                            afb0_snoop_second_dvm[i] | afb1_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] |
                            afb3_snoop_second_dvm[i] | afb5_snoop_second_dvm[i],
                            afb0_snoop_second_dvm[i] | afb1_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] |
                            afb4_snoop_second_dvm[i] | afb5_snoop_second_dvm[i],
                            afb0_snoop_second_dvm[i] | afb1_snoop_second_dvm[i] | afb3_snoop_second_dvm[i] |
                            afb4_snoop_second_dvm[i] | afb5_snoop_second_dvm[i],
                            afb0_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] | afb3_snoop_second_dvm[i] |
                            afb4_snoop_second_dvm[i] | afb5_snoop_second_dvm[i],
                            afb1_snoop_second_dvm[i] | afb2_snoop_second_dvm[i] | afb3_snoop_second_dvm[i] |
                            afb4_snoop_second_dvm[i] | afb5_snoop_second_dvm[i]};

      // Collate the AFBs making a request for this CPU.
      assign snoop_reqs_cpu[i] = {ecc_snoop_req[i],
                                  afb5_snoop_req[i],
                                  afb4_snoop_req[i],
                                  afb3_snoop_req[i],
                                  afb2_snoop_req[i],
                                  afb1_snoop_req[i],
                                  afb0_snoop_req[i]} & ~dvm_mask[i];

      // Only update the round robin counter when a snoop to the relevant CPU is
      // accepted. It must only be updated once on two part DVMs, otherwise it can
      // unfairly skip the next AFB.
      assign snoop_accepted[i] = ac_valid_cpu[i] & ac_ready_cpu[i] & ~|dvm_mask[i];

      // Select the highest priority AFB requesting access to the CPU.
      // Update the round robin counter every time a snoop is accepted to this CPU.
      ca53_rr_reg_arb #(.WIDTH(7)) u_cpu_snoop_arb (
        .clk        (clk_tagctl),
        .reset_n    (reset_n),
        .enable_i   (snoop_accepted[i]),
        .requests_i (snoop_reqs_cpu[i]),
        .arb_o      (afb_sel_cpu[i])
      );

    end else begin : g_n_snoop_arb_cpu
      // Tie-off selection for unused CPUs
      assign afb_sel_cpu[i] = 7'b0000000;
    end

    assign ac_valid_cpu[i] = |(afb_sel_cpu[i] & ~{1'b0, flush_afb});

  end endgenerate


  // Mux the snoop requests from each AFB, based on the arbitration.

  assign tagctl_cpuslv0_ac_valid_o = ac_valid_cpu[0];
  assign tagctl_cpuslv1_ac_valid_o = ac_valid_cpu[1];
  assign tagctl_cpuslv2_ac_valid_o = ac_valid_cpu[2];
  assign tagctl_cpuslv3_ac_valid_o = ac_valid_cpu[3];

  assign afb0_cpu0_ac_ready = afb_sel_cpu[0][0] & cpuslv0_ac_ready_i;
  assign afb1_cpu0_ac_ready = afb_sel_cpu[0][1] & cpuslv0_ac_ready_i;
  assign afb2_cpu0_ac_ready = afb_sel_cpu[0][2] & cpuslv0_ac_ready_i;
  assign afb3_cpu0_ac_ready = afb_sel_cpu[0][3] & cpuslv0_ac_ready_i;
  assign afb4_cpu0_ac_ready = afb_sel_cpu[0][4] & cpuslv0_ac_ready_i;
  assign afb5_cpu0_ac_ready = afb_sel_cpu[0][5] & cpuslv0_ac_ready_i;
  assign afb0_cpu1_ac_ready = afb_sel_cpu[1][0] & cpuslv1_ac_ready_i;
  assign afb1_cpu1_ac_ready = afb_sel_cpu[1][1] & cpuslv1_ac_ready_i;
  assign afb2_cpu1_ac_ready = afb_sel_cpu[1][2] & cpuslv1_ac_ready_i;
  assign afb3_cpu1_ac_ready = afb_sel_cpu[1][3] & cpuslv1_ac_ready_i;
  assign afb4_cpu1_ac_ready = afb_sel_cpu[1][4] & cpuslv1_ac_ready_i;
  assign afb5_cpu1_ac_ready = afb_sel_cpu[1][5] & cpuslv1_ac_ready_i;
  assign afb0_cpu2_ac_ready = afb_sel_cpu[2][0] & cpuslv2_ac_ready_i;
  assign afb1_cpu2_ac_ready = afb_sel_cpu[2][1] & cpuslv2_ac_ready_i;
  assign afb2_cpu2_ac_ready = afb_sel_cpu[2][2] & cpuslv2_ac_ready_i;
  assign afb3_cpu2_ac_ready = afb_sel_cpu[2][3] & cpuslv2_ac_ready_i;
  assign afb4_cpu2_ac_ready = afb_sel_cpu[2][4] & cpuslv2_ac_ready_i;
  assign afb5_cpu2_ac_ready = afb_sel_cpu[2][5] & cpuslv2_ac_ready_i;
  assign afb0_cpu3_ac_ready = afb_sel_cpu[3][0] & cpuslv3_ac_ready_i;
  assign afb1_cpu3_ac_ready = afb_sel_cpu[3][1] & cpuslv3_ac_ready_i;
  assign afb2_cpu3_ac_ready = afb_sel_cpu[3][2] & cpuslv3_ac_ready_i;
  assign afb3_cpu3_ac_ready = afb_sel_cpu[3][3] & cpuslv3_ac_ready_i;
  assign afb4_cpu3_ac_ready = afb_sel_cpu[3][4] & cpuslv3_ac_ready_i;
  assign afb5_cpu3_ac_ready = afb_sel_cpu[3][5] & cpuslv3_ac_ready_i;

  assign ecc_ac_ready = ((afb_sel_cpu[3][6] & cpuslv3_ac_ready_i) |
                         (afb_sel_cpu[2][6] & cpuslv2_ac_ready_i) |
                         (afb_sel_cpu[1][6] & cpuslv1_ac_ready_i) |
                         (afb_sel_cpu[0][6] & cpuslv0_ac_ready_i));

  assign tagctl_cpuslv0_ac_snoop_o = (({4{afb_sel_cpu[0][6]}} & `CA53_SNOOP_MAKEINVALID) |
                                      ({4{afb_sel_cpu[0][5]}} & afb5_cpu0_ac_snoop) |
                                      ({4{afb_sel_cpu[0][4]}} & afb4_cpu0_ac_snoop) |
                                      ({4{afb_sel_cpu[0][3]}} & afb3_cpu0_ac_snoop) |
                                      ({4{afb_sel_cpu[0][2]}} & afb2_cpu0_ac_snoop) |
                                      ({4{afb_sel_cpu[0][1]}} & afb1_cpu0_ac_snoop) |
                                      ({4{afb_sel_cpu[0][0]}} & afb0_cpu0_ac_snoop));
  assign tagctl_cpuslv1_ac_snoop_o = (({4{afb_sel_cpu[1][6]}} & `CA53_SNOOP_MAKEINVALID) |
                                      ({4{afb_sel_cpu[1][5]}} & afb5_cpu1_ac_snoop) |
                                      ({4{afb_sel_cpu[1][4]}} & afb4_cpu1_ac_snoop) |
                                      ({4{afb_sel_cpu[1][3]}} & afb3_cpu1_ac_snoop) |
                                      ({4{afb_sel_cpu[1][2]}} & afb2_cpu1_ac_snoop) |
                                      ({4{afb_sel_cpu[1][1]}} & afb1_cpu1_ac_snoop) |
                                      ({4{afb_sel_cpu[1][0]}} & afb0_cpu1_ac_snoop));
  assign tagctl_cpuslv2_ac_snoop_o = (({4{afb_sel_cpu[2][6]}} & `CA53_SNOOP_MAKEINVALID) |
                                      ({4{afb_sel_cpu[2][5]}} & afb5_cpu2_ac_snoop) |
                                      ({4{afb_sel_cpu[2][4]}} & afb4_cpu2_ac_snoop) |
                                      ({4{afb_sel_cpu[2][3]}} & afb3_cpu2_ac_snoop) |
                                      ({4{afb_sel_cpu[2][2]}} & afb2_cpu2_ac_snoop) |
                                      ({4{afb_sel_cpu[2][1]}} & afb1_cpu2_ac_snoop) |
                                      ({4{afb_sel_cpu[2][0]}} & afb0_cpu2_ac_snoop));
  assign tagctl_cpuslv3_ac_snoop_o = (({4{afb_sel_cpu[3][6]}} & `CA53_SNOOP_MAKEINVALID) |
                                      ({4{afb_sel_cpu[3][5]}} & afb5_cpu3_ac_snoop) |
                                      ({4{afb_sel_cpu[3][4]}} & afb4_cpu3_ac_snoop) |
                                      ({4{afb_sel_cpu[3][3]}} & afb3_cpu3_ac_snoop) |
                                      ({4{afb_sel_cpu[3][2]}} & afb2_cpu3_ac_snoop) |
                                      ({4{afb_sel_cpu[3][1]}} & afb1_cpu3_ac_snoop) |
                                      ({4{afb_sel_cpu[3][0]}} & afb0_cpu3_ac_snoop));

  assign tagctl_cpuslv0_ac_id_o = (({3{afb_sel_cpu[0][6]}} & 3'b111) |
                                   ({3{afb_sel_cpu[0][5]}} & 3'b101) |
                                   ({3{afb_sel_cpu[0][4]}} & 3'b100) |
                                   ({3{afb_sel_cpu[0][3]}} & 3'b011) |
                                   ({3{afb_sel_cpu[0][2]}} & 3'b010) |
                                   ({3{afb_sel_cpu[0][1]}} & 3'b001) |
                                   ({3{afb_sel_cpu[0][0]}} & 3'b000));
  assign tagctl_cpuslv1_ac_id_o = (({3{afb_sel_cpu[1][6]}} & 3'b111) |
                                   ({3{afb_sel_cpu[1][5]}} & 3'b101) |
                                   ({3{afb_sel_cpu[1][4]}} & 3'b100) |
                                   ({3{afb_sel_cpu[1][3]}} & 3'b011) |
                                   ({3{afb_sel_cpu[1][2]}} & 3'b010) |
                                   ({3{afb_sel_cpu[1][1]}} & 3'b001) |
                                   ({3{afb_sel_cpu[1][0]}} & 3'b000));
  assign tagctl_cpuslv2_ac_id_o = (({3{afb_sel_cpu[2][6]}} & 3'b111) |
                                   ({3{afb_sel_cpu[2][5]}} & 3'b101) |
                                   ({3{afb_sel_cpu[2][4]}} & 3'b100) |
                                   ({3{afb_sel_cpu[2][3]}} & 3'b011) |
                                   ({3{afb_sel_cpu[2][2]}} & 3'b010) |
                                   ({3{afb_sel_cpu[2][1]}} & 3'b001) |
                                   ({3{afb_sel_cpu[2][0]}} & 3'b000));
  assign tagctl_cpuslv3_ac_id_o = (({3{afb_sel_cpu[3][6]}} & 3'b111) |
                                   ({3{afb_sel_cpu[3][5]}} & 3'b101) |
                                   ({3{afb_sel_cpu[3][4]}} & 3'b100) |
                                   ({3{afb_sel_cpu[3][3]}} & 3'b011) |
                                   ({3{afb_sel_cpu[3][2]}} & 3'b010) |
                                   ({3{afb_sel_cpu[3][1]}} & 3'b001) |
                                   ({3{afb_sel_cpu[3][0]}} & 3'b000));

  assign tagctl_cpuslv0_ac_l2db_id_o = (({4{afb_sel_cpu[0][5]}} & afb5_cpu0_ac_l2db_id) |
                                        ({4{afb_sel_cpu[0][4]}} & afb4_cpu0_ac_l2db_id) |
                                        ({4{afb_sel_cpu[0][3]}} & afb3_cpu0_ac_l2db_id) |
                                        ({4{afb_sel_cpu[0][2]}} & afb2_cpu0_ac_l2db_id) |
                                        ({4{afb_sel_cpu[0][1]}} & afb1_cpu0_ac_l2db_id) |
                                        ({4{afb_sel_cpu[0][0]}} & afb0_cpu0_ac_l2db_id));
  assign tagctl_cpuslv1_ac_l2db_id_o = (({4{afb_sel_cpu[1][5]}} & afb5_cpu1_ac_l2db_id) |
                                        ({4{afb_sel_cpu[1][4]}} & afb4_cpu1_ac_l2db_id) |
                                        ({4{afb_sel_cpu[1][3]}} & afb3_cpu1_ac_l2db_id) |
                                        ({4{afb_sel_cpu[1][2]}} & afb2_cpu1_ac_l2db_id) |
                                        ({4{afb_sel_cpu[1][1]}} & afb1_cpu1_ac_l2db_id) |
                                        ({4{afb_sel_cpu[1][0]}} & afb0_cpu1_ac_l2db_id));
  assign tagctl_cpuslv2_ac_l2db_id_o = (({4{afb_sel_cpu[2][5]}} & afb5_cpu2_ac_l2db_id) |
                                        ({4{afb_sel_cpu[2][4]}} & afb4_cpu2_ac_l2db_id) |
                                        ({4{afb_sel_cpu[2][3]}} & afb3_cpu2_ac_l2db_id) |
                                        ({4{afb_sel_cpu[2][2]}} & afb2_cpu2_ac_l2db_id) |
                                        ({4{afb_sel_cpu[2][1]}} & afb1_cpu2_ac_l2db_id) |
                                        ({4{afb_sel_cpu[2][0]}} & afb0_cpu2_ac_l2db_id));
  assign tagctl_cpuslv3_ac_l2db_id_o = (({4{afb_sel_cpu[3][5]}} & afb5_cpu3_ac_l2db_id) |
                                        ({4{afb_sel_cpu[3][4]}} & afb4_cpu3_ac_l2db_id) |
                                        ({4{afb_sel_cpu[3][3]}} & afb3_cpu3_ac_l2db_id) |
                                        ({4{afb_sel_cpu[3][2]}} & afb2_cpu3_ac_l2db_id) |
                                        ({4{afb_sel_cpu[3][1]}} & afb1_cpu3_ac_l2db_id) |
                                        ({4{afb_sel_cpu[3][0]}} & afb0_cpu3_ac_l2db_id));

  assign tagctl_cpuslv0_ac_addr_o = (({41{afb_sel_cpu[0][6]}} & ecc_ac_addr) |
                                     ({41{afb_sel_cpu[0][5]}} & afb5_cpu0_ac_addr) |
                                     ({41{afb_sel_cpu[0][4]}} & afb4_cpu0_ac_addr) |
                                     ({41{afb_sel_cpu[0][3]}} & afb3_cpu0_ac_addr) |
                                     ({41{afb_sel_cpu[0][2]}} & afb2_cpu0_ac_addr) |
                                     ({41{afb_sel_cpu[0][1]}} & afb1_cpu0_ac_addr) |
                                     ({41{afb_sel_cpu[0][0]}} & afb0_cpu0_ac_addr));
  assign tagctl_cpuslv1_ac_addr_o = (({41{afb_sel_cpu[1][6]}} & ecc_ac_addr) |
                                     ({41{afb_sel_cpu[1][5]}} & afb5_cpu1_ac_addr) |
                                     ({41{afb_sel_cpu[1][4]}} & afb4_cpu1_ac_addr) |
                                     ({41{afb_sel_cpu[1][3]}} & afb3_cpu1_ac_addr) |
                                     ({41{afb_sel_cpu[1][2]}} & afb2_cpu1_ac_addr) |
                                     ({41{afb_sel_cpu[1][1]}} & afb1_cpu1_ac_addr) |
                                     ({41{afb_sel_cpu[1][0]}} & afb0_cpu1_ac_addr));
  assign tagctl_cpuslv2_ac_addr_o = (({41{afb_sel_cpu[2][6]}} & ecc_ac_addr) |
                                     ({41{afb_sel_cpu[2][5]}} & afb5_cpu2_ac_addr) |
                                     ({41{afb_sel_cpu[2][4]}} & afb4_cpu2_ac_addr) |
                                     ({41{afb_sel_cpu[2][3]}} & afb3_cpu2_ac_addr) |
                                     ({41{afb_sel_cpu[2][2]}} & afb2_cpu2_ac_addr) |
                                     ({41{afb_sel_cpu[2][1]}} & afb1_cpu2_ac_addr) |
                                     ({41{afb_sel_cpu[2][0]}} & afb0_cpu2_ac_addr));
  assign tagctl_cpuslv3_ac_addr_o = (({41{afb_sel_cpu[3][6]}} & ecc_ac_addr) |
                                     ({41{afb_sel_cpu[3][5]}} & afb5_cpu3_ac_addr) |
                                     ({41{afb_sel_cpu[3][4]}} & afb4_cpu3_ac_addr) |
                                     ({41{afb_sel_cpu[3][3]}} & afb3_cpu3_ac_addr) |
                                     ({41{afb_sel_cpu[3][2]}} & afb2_cpu3_ac_addr) |
                                     ({41{afb_sel_cpu[3][1]}} & afb1_cpu3_ac_addr) |
                                     ({41{afb_sel_cpu[3][0]}} & afb0_cpu3_ac_addr));

  assign tagctl_cpuslv0_ac_way_o = (({4{afb_sel_cpu[0][6]}} & ecc_ac_way) |
                                    ({4{afb_sel_cpu[0][5]}} & afb5_cpu0_ac_way) |
                                    ({4{afb_sel_cpu[0][4]}} & afb4_cpu0_ac_way) |
                                    ({4{afb_sel_cpu[0][3]}} & afb3_cpu0_ac_way) |
                                    ({4{afb_sel_cpu[0][2]}} & afb2_cpu0_ac_way) |
                                    ({4{afb_sel_cpu[0][1]}} & afb1_cpu0_ac_way) |
                                    ({4{afb_sel_cpu[0][0]}} & afb0_cpu0_ac_way));
  assign tagctl_cpuslv1_ac_way_o = (({4{afb_sel_cpu[1][6]}} & ecc_ac_way) |
                                    ({4{afb_sel_cpu[1][5]}} & afb5_cpu1_ac_way) |
                                    ({4{afb_sel_cpu[1][4]}} & afb4_cpu1_ac_way) |
                                    ({4{afb_sel_cpu[1][3]}} & afb3_cpu1_ac_way) |
                                    ({4{afb_sel_cpu[1][2]}} & afb2_cpu1_ac_way) |
                                    ({4{afb_sel_cpu[1][1]}} & afb1_cpu1_ac_way) |
                                    ({4{afb_sel_cpu[1][0]}} & afb0_cpu1_ac_way));
  assign tagctl_cpuslv2_ac_way_o = (({4{afb_sel_cpu[2][6]}} & ecc_ac_way) |
                                    ({4{afb_sel_cpu[2][5]}} & afb5_cpu2_ac_way) |
                                    ({4{afb_sel_cpu[2][4]}} & afb4_cpu2_ac_way) |
                                    ({4{afb_sel_cpu[2][3]}} & afb3_cpu2_ac_way) |
                                    ({4{afb_sel_cpu[2][2]}} & afb2_cpu2_ac_way) |
                                    ({4{afb_sel_cpu[2][1]}} & afb1_cpu2_ac_way) |
                                    ({4{afb_sel_cpu[2][0]}} & afb0_cpu2_ac_way));
  assign tagctl_cpuslv3_ac_way_o = (({4{afb_sel_cpu[3][6]}} & ecc_ac_way) |
                                    ({4{afb_sel_cpu[3][5]}} & afb5_cpu3_ac_way) |
                                    ({4{afb_sel_cpu[3][4]}} & afb4_cpu3_ac_way) |
                                    ({4{afb_sel_cpu[3][3]}} & afb3_cpu3_ac_way) |
                                    ({4{afb_sel_cpu[3][2]}} & afb2_cpu3_ac_way) |
                                    ({4{afb_sel_cpu[3][1]}} & afb1_cpu3_ac_way) |
                                    ({4{afb_sel_cpu[3][0]}} & afb0_cpu3_ac_way));

  assign tagctl_cpuslv0_snp_active_o = (ecc_in_progress |
                                        afb0_cpuslv0_snp_active |
                                        afb1_cpuslv0_snp_active |
                                        afb2_cpuslv0_snp_active |
                                        afb3_cpuslv0_snp_active |
                                        afb4_cpuslv0_snp_active |
                                        afb5_cpuslv0_snp_active);
  assign tagctl_cpuslv1_snp_active_o = (ecc_in_progress |
                                        afb0_cpuslv1_snp_active |
                                        afb1_cpuslv1_snp_active |
                                        afb2_cpuslv1_snp_active |
                                        afb3_cpuslv1_snp_active |
                                        afb4_cpuslv1_snp_active |
                                        afb5_cpuslv1_snp_active);
  assign tagctl_cpuslv2_snp_active_o = (ecc_in_progress |
                                        afb0_cpuslv2_snp_active |
                                        afb1_cpuslv2_snp_active |
                                        afb2_cpuslv2_snp_active |
                                        afb3_cpuslv2_snp_active |
                                        afb4_cpuslv2_snp_active |
                                        afb5_cpuslv2_snp_active);
  assign tagctl_cpuslv3_snp_active_o = (ecc_in_progress |
                                        afb0_cpuslv3_snp_active |
                                        afb1_cpuslv3_snp_active |
                                        afb2_cpuslv3_snp_active |
                                        afb3_cpuslv3_snp_active |
                                        afb4_cpuslv3_snp_active |
                                        afb5_cpuslv3_snp_active);


  // L2DB control
  assign tagctl_l2db_release = (afb0_l2db_release |
                                afb1_l2db_release |
                                afb2_l2db_release |
                                afb3_l2db_release |
                                afb4_l2db_release |
                                afb5_l2db_release);

  assign tagctl_l2db_snoops_done = (afb0_l2db_snoops_done |
                                    afb1_l2db_snoops_done |
                                    afb2_l2db_snoops_done |
                                    afb3_l2db_snoops_done |
                                    afb4_l2db_snoops_done |
                                    afb5_l2db_snoops_done);

  assign tagctl_l2db_fill_strbs = (afb0_l2db_fill_strbs |
                                   afb1_l2db_fill_strbs |
                                   afb2_l2db_fill_strbs |
                                   afb3_l2db_fill_strbs |
                                   afb4_l2db_fill_strbs |
                                   afb5_l2db_fill_strbs);

  assign tagctl_l2db0_release_o  = tagctl_l2db_release[0];
  assign tagctl_l2db1_release_o  = tagctl_l2db_release[1];
  assign tagctl_l2db2_release_o  = tagctl_l2db_release[2];
  assign tagctl_l2db3_release_o  = tagctl_l2db_release[3];
  assign tagctl_l2db4_release_o  = tagctl_l2db_release[4];
  assign tagctl_l2db5_release_o  = tagctl_l2db_release[5];
  assign tagctl_l2db6_release_o  = tagctl_l2db_release[6];
  assign tagctl_l2db7_release_o  = tagctl_l2db_release[7];
  assign tagctl_l2db8_release_o  = tagctl_l2db_release[8];
  assign tagctl_l2db9_release_o  = tagctl_l2db_release[9];
  assign tagctl_l2db10_release_o = tagctl_l2db_release[10];

  assign tagctl_l2db0_snoops_done_o  = tagctl_l2db_snoops_done[0];
  assign tagctl_l2db1_snoops_done_o  = tagctl_l2db_snoops_done[1];
  assign tagctl_l2db2_snoops_done_o  = tagctl_l2db_snoops_done[2];
  assign tagctl_l2db3_snoops_done_o  = tagctl_l2db_snoops_done[3];
  assign tagctl_l2db4_snoops_done_o  = tagctl_l2db_snoops_done[4];
  assign tagctl_l2db5_snoops_done_o  = tagctl_l2db_snoops_done[5];
  assign tagctl_l2db6_snoops_done_o  = tagctl_l2db_snoops_done[6];
  assign tagctl_l2db7_snoops_done_o  = tagctl_l2db_snoops_done[7];
  assign tagctl_l2db8_snoops_done_o  = tagctl_l2db_snoops_done[8];
  assign tagctl_l2db9_snoops_done_o  = tagctl_l2db_snoops_done[9];
  assign tagctl_l2db10_snoops_done_o = tagctl_l2db_snoops_done[10];

  assign tagctl_l2db0_fill_strbs_o  = tagctl_l2db_fill_strbs[0];
  assign tagctl_l2db1_fill_strbs_o  = tagctl_l2db_fill_strbs[1];
  assign tagctl_l2db2_fill_strbs_o  = tagctl_l2db_fill_strbs[2];
  assign tagctl_l2db3_fill_strbs_o  = tagctl_l2db_fill_strbs[3];
  assign tagctl_l2db4_fill_strbs_o  = tagctl_l2db_fill_strbs[4];
  assign tagctl_l2db5_fill_strbs_o  = tagctl_l2db_fill_strbs[5];
  assign tagctl_l2db6_fill_strbs_o  = tagctl_l2db_fill_strbs[6];
  assign tagctl_l2db7_fill_strbs_o  = tagctl_l2db_fill_strbs[7];
  assign tagctl_l2db8_fill_strbs_o  = tagctl_l2db_fill_strbs[8];
  assign tagctl_l2db9_fill_strbs_o  = tagctl_l2db_fill_strbs[9];
  assign tagctl_l2db10_fill_strbs_o = tagctl_l2db_fill_strbs[10];

  assign tagctl_dvm_sync_tc3_o = (afb0_dvm_sync_tc3 |
                                  afb1_dvm_sync_tc3 |
                                  afb2_dvm_sync_tc3 |
                                  afb3_dvm_sync_tc3 |
                                  afb4_dvm_sync_tc3 |
                                  afb5_dvm_sync_tc3);

  assign tagctl_snp_dvm_sync_tc4_o = (afb0_snp_dvm_sync_tc4 |
                                      afb1_snp_dvm_sync_tc4 |
                                      afb2_snp_dvm_sync_tc4 |
                                      afb3_snp_dvm_sync_tc4 |
                                      afb4_snp_dvm_sync_tc4 |
                                      afb5_snp_dvm_sync_tc4);

  assign tagctl_cpu_dvm_sync_tc4_o = (afb0_cpu_dvm_sync_tc4 |
                                      afb1_cpu_dvm_sync_tc4 |
                                      afb2_cpu_dvm_sync_tc4 |
                                      afb3_cpu_dvm_sync_tc4 |
                                      afb4_cpu_dvm_sync_tc4 |
                                      afb5_cpu_dvm_sync_tc4);

  // Only one DVM sync can be serialised at a time, therefore only one AFB can
  // be generating completes.
  assign tagctl_dvm_complete_o = (afb0_dvm_complete |
                                  afb1_dvm_complete |
                                  afb2_dvm_complete |
                                  afb3_dvm_complete |
                                  afb4_dvm_complete |
                                  afb5_dvm_complete);

  //----------------------------------------------------------------------------
  //  L2 data RAM requests
  //----------------------------------------------------------------------------

  // Collate the AFBs making a request for ramctl.
  assign ramctl_req = {afb5_ramctl_valid,
                       afb4_ramctl_valid,
                       afb3_ramctl_valid,
                       afb2_ramctl_valid,
                       afb1_ramctl_valid,
                       afb0_ramctl_valid};

  // Update the round robin counter every time a request is accepted.
  assign round_robin_ramctl_en = |ramctl_req & ramctl_tagctl_ready_i;

  // Select the highest priority AFB requesting access to ramctl.
  ca53_rr_reg_arb #(.WIDTH(6)) u_afb_ramctl_arb (
    .clk        (clk_tagctl),
    .reset_n    (reset_n),
    .enable_i   (round_robin_ramctl_en),
    .requests_i (ramctl_req),
    .arb_o      (ramctl_arb)
  );

  // Indicate back to the AFB when the request has been accepted.
  assign ramctl_afb0_ready = ramctl_arb[0] & ramctl_tagctl_ready_i;
  assign ramctl_afb1_ready = ramctl_arb[1] & ramctl_tagctl_ready_i;
  assign ramctl_afb2_ready = ramctl_arb[2] & ramctl_tagctl_ready_i;
  assign ramctl_afb3_ready = ramctl_arb[3] & ramctl_tagctl_ready_i;
  assign ramctl_afb4_ready = ramctl_arb[4] & ramctl_tagctl_ready_i;
  assign ramctl_afb5_ready = ramctl_arb[5] & ramctl_tagctl_ready_i;

  // Send the arbitrated request on to ramctl.
  assign tagctl_ramctl_valid_o = |ramctl_req;

  assign tagctl_ramctl_cancel_o = ((ramctl_arb[5] & afb5_ramctl_cancel) |
                                   (ramctl_arb[4] & afb4_ramctl_cancel) |
                                   (ramctl_arb[3] & afb3_ramctl_cancel) |
                                   (ramctl_arb[2] & afb2_ramctl_cancel) |
                                   (ramctl_arb[1] & afb1_ramctl_cancel) |
                                   (ramctl_arb[0] & afb0_ramctl_cancel));

  assign tagctl_ramctl_flush_o = (afb5_ramctl_flush |
                                  afb4_ramctl_flush |
                                  afb3_ramctl_flush |
                                  afb2_ramctl_flush |
                                  afb1_ramctl_flush |
                                  afb0_ramctl_flush);

  assign tagctl_ramctl_index_o = (({11{ramctl_arb[5]}} & afb5_ramctl_index) |
                                  ({11{ramctl_arb[4]}} & afb4_ramctl_index) |
                                  ({11{ramctl_arb[3]}} & afb3_ramctl_index) |
                                  ({11{ramctl_arb[2]}} & afb2_ramctl_index) |
                                  ({11{ramctl_arb[1]}} & afb1_ramctl_index) |
                                  ({11{ramctl_arb[0]}} & afb0_ramctl_index));

  assign tagctl_ramctl_way_o = (({4{ramctl_arb[5]}} & afb5_ramctl_way) |
                                ({4{ramctl_arb[4]}} & afb4_ramctl_way) |
                                ({4{ramctl_arb[3]}} & afb3_ramctl_way) |
                                ({4{ramctl_arb[2]}} & afb2_ramctl_way) |
                                ({4{ramctl_arb[1]}} & afb1_ramctl_way) |
                                ({4{ramctl_arb[0]}} & afb0_ramctl_way));

  assign ramctl_l2db_arb = |ramctl_req ? ramctl_arb : afb_tc2;

  assign tagctl_ramctl_l2db_o = (({4{ramctl_l2db_arb[5]}} & afb5_slv_l2db) |
                                 ({4{ramctl_l2db_arb[4]}} & afb4_slv_l2db) |
                                 ({4{ramctl_l2db_arb[3]}} & afb3_slv_l2db) |
                                 ({4{ramctl_l2db_arb[2]}} & afb2_slv_l2db) |
                                 ({4{ramctl_l2db_arb[1]}} & afb1_slv_l2db) |
                                 ({4{ramctl_l2db_arb[0]}} & afb0_slv_l2db));

  assign tagctl_ramctl_crit_chunk_o = (({2{ramctl_arb[5]}} & afb5_ramctl_crit_chunk) |
                                       ({2{ramctl_arb[4]}} & afb4_ramctl_crit_chunk) |
                                       ({2{ramctl_arb[3]}} & afb3_ramctl_crit_chunk) |
                                       ({2{ramctl_arb[2]}} & afb2_ramctl_crit_chunk) |
                                       ({2{ramctl_arb[1]}} & afb1_ramctl_crit_chunk) |
                                       ({2{ramctl_arb[0]}} & afb0_ramctl_crit_chunk) |
                                       ({2{~|ramctl_req}}  & req_addr1_tc2[5:4]));

  assign tagctl_ramctl_banks_o = (({8{ramctl_arb[5]}} & afb5_ramctl_banks) |
                                  ({8{ramctl_arb[4]}} & afb4_ramctl_banks) |
                                  ({8{ramctl_arb[3]}} & afb3_ramctl_banks) |
                                  ({8{ramctl_arb[2]}} & afb2_ramctl_banks) |
                                  ({8{ramctl_arb[1]}} & afb1_ramctl_banks) |
                                  ({8{ramctl_arb[0]}} & afb0_ramctl_banks));

  assign tagctl_ramctl_active_o = (afb0_ramctl_active |
                                   afb1_ramctl_active |
                                   afb2_ramctl_active |
                                   afb3_ramctl_active |
                                   afb4_ramctl_active |
                                   afb5_ramctl_active |
                                   (valid_tc1 &
                                    (req_pass_tc1 == `CA53_TAGCTL_PASS_SERIALISE) &
                                    ((req_type_tc1 == `CA53_AFB_REQ_READSHARED) |
                                     (req_type_tc1 == `CA53_AFB_REQ_READUNIQUE) |
                                     (req_type_tc1 == `CA53_AFB_REQ_READONCE) |
                                     (req_type_tc1 == `CA53_AFB_REQ_CLEANSETWAY) |
                                     (req_type_tc1 == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                     (req_type_tc1 == `CA53_AFB_REQ_CLEANSHARED) |
                                     (req_type_tc1 == `CA53_AFB_REQ_CLEANINVALID) |
                                     (req_type_tc1 == `CA53_AFB_REQ_MAKEINVALID) |
                                     (req_type_tc1 == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READONCE) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READSHARED) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READCLEAN) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                     (req_type_tc1 == `CA53_AFB_SNP_READUNIQUE) |
                                     (req_type_tc1 == `CA53_AFB_SNP_CLEANSHARED) |
                                     (req_type_tc1 == `CA53_AFB_SNP_CLEANINVALID))));

  //----------------------------------------------------------------------------
  //  AFB instantiations
  //----------------------------------------------------------------------------

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b000)) u_scu_afb0 (
    // TEMPLATE s/afb/afb0/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb0_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb0_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb0_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb0_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb0_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb0_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb0_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb0_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb0_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb0_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb0_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb0_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb0_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb0_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb0_valid),
    .afb_requires_master_o          (afb0_requires_master),
    .afb_l2db_hazard_tc3_o          (afb0_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb0_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb0_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb0_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb0_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb0_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb0_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb0_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb0_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb0_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb0_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb0_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb0_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb0_done_o),
    .afb_snoop_resp_valid_o         (afb0_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb0_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb0_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb0_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb0_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb0_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb0_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb0_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb0_write_done_o),
    .afb_req_single_o               (afb0_req_single),
    .afb_smp_en_o                   (afb0_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb0_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb0_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb0_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb0_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb0_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb0_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb0_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb0_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb0_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb0_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb0_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb0_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb0_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb0_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb0_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb0_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb0_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb0_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb0_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb0_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb0_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb0_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb0_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb0_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb0_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb0_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb0_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb0_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb0_cpuslv3_snp_active),
    .afb_master_active_o            (afb0_master_active),
    .afb_master_req_o               (afb0_master_req_o),
    .afb_master_flush_o             (afb0_master_flush_o),
    .afb_master_id_o                (afb0_master_id_o[6:0]),
    .afb_master_addr_o              (afb0_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb0_master_opcode_o[4:0]),
    .afb_master_len_o               (afb0_master_len_o[1:0]),
    .afb_master_size_o              (afb0_master_size_o[2:0]),
    .afb_master_lock_o              (afb0_master_lock_o),
    .afb_master_attrs_o             (afb0_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb0_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb0_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb0_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb0_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb0_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb0_ramctl_active),
    .afb_ramctl_valid_o             (afb0_ramctl_valid),
    .afb_ramctl_cancel_o            (afb0_ramctl_cancel),
    .afb_ramctl_index_o             (afb0_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb0_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb0_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb0_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb0_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb0_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb0_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb0_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb0_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb0_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb0_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb0_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb0_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb0_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb0_hz_tc1),
    .afb_hz_tc3_o                   (afb0_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb0_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb0_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb0_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb0_dvm_complete[3:0])
  );  // u_scu_afb0

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b001)) u_scu_afb1 (
    // TEMPLATE s/afb/afb1/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb1_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb1_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb1_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb1_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb1_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb1_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb1_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb1_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb1_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb1_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb1_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb1_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb1_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb1_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb1_valid),
    .afb_requires_master_o          (afb1_requires_master),
    .afb_l2db_hazard_tc3_o          (afb1_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb1_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb1_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb1_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb1_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb1_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb1_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb1_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb1_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb1_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb1_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb1_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb1_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb1_done_o),
    .afb_snoop_resp_valid_o         (afb1_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb1_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb1_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb1_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb1_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb1_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb1_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb1_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb1_write_done_o),
    .afb_req_single_o               (afb1_req_single),
    .afb_smp_en_o                   (afb1_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb1_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb1_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb1_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb1_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb1_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb1_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb1_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb1_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb1_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb1_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb1_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb1_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb1_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb1_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb1_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb1_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb1_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb1_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb1_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb1_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb1_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb1_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb1_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb1_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb1_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb1_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb1_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb1_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb1_cpuslv3_snp_active),
    .afb_master_active_o            (afb1_master_active),
    .afb_master_req_o               (afb1_master_req_o),
    .afb_master_flush_o             (afb1_master_flush_o),
    .afb_master_id_o                (afb1_master_id_o[6:0]),
    .afb_master_addr_o              (afb1_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb1_master_opcode_o[4:0]),
    .afb_master_len_o               (afb1_master_len_o[1:0]),
    .afb_master_size_o              (afb1_master_size_o[2:0]),
    .afb_master_lock_o              (afb1_master_lock_o),
    .afb_master_attrs_o             (afb1_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb1_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb1_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb1_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb1_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb1_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb1_ramctl_active),
    .afb_ramctl_valid_o             (afb1_ramctl_valid),
    .afb_ramctl_cancel_o            (afb1_ramctl_cancel),
    .afb_ramctl_index_o             (afb1_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb1_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb1_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb1_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb1_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb1_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb1_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb1_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb1_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb1_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb1_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb1_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb1_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb1_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb1_hz_tc1),
    .afb_hz_tc3_o                   (afb1_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb1_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb1_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb1_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb1_dvm_complete[3:0])
  );  // u_scu_afb1

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b010)) u_scu_afb2 (
    // TEMPLATE s/afb/afb2/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb2_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb2_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb2_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb2_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb2_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb2_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb2_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb2_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb2_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb2_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb2_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb2_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb2_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb2_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb2_valid),
    .afb_requires_master_o          (afb2_requires_master),
    .afb_l2db_hazard_tc3_o          (afb2_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb2_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb2_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb2_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb2_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb2_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb2_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb2_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb2_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb2_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb2_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb2_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb2_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb2_done_o),
    .afb_snoop_resp_valid_o         (afb2_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb2_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb2_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb2_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb2_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb2_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb2_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb2_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb2_write_done_o),
    .afb_req_single_o               (afb2_req_single),
    .afb_smp_en_o                   (afb2_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb2_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb2_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb2_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb2_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb2_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb2_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb2_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb2_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb2_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb2_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb2_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb2_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb2_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb2_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb2_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb2_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb2_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb2_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb2_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb2_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb2_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb2_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb2_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb2_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb2_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb2_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb2_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb2_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb2_cpuslv3_snp_active),
    .afb_master_active_o            (afb2_master_active),
    .afb_master_req_o               (afb2_master_req_o),
    .afb_master_flush_o             (afb2_master_flush_o),
    .afb_master_id_o                (afb2_master_id_o[6:0]),
    .afb_master_addr_o              (afb2_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb2_master_opcode_o[4:0]),
    .afb_master_len_o               (afb2_master_len_o[1:0]),
    .afb_master_size_o              (afb2_master_size_o[2:0]),
    .afb_master_lock_o              (afb2_master_lock_o),
    .afb_master_attrs_o             (afb2_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb2_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb2_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb2_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb2_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb2_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb2_ramctl_active),
    .afb_ramctl_valid_o             (afb2_ramctl_valid),
    .afb_ramctl_cancel_o            (afb2_ramctl_cancel),
    .afb_ramctl_index_o             (afb2_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb2_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb2_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb2_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb2_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb2_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb2_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb2_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb2_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb2_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb2_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb2_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb2_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb2_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb2_hz_tc1),
    .afb_hz_tc3_o                   (afb2_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb2_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb2_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb2_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb2_dvm_complete[3:0])
  );  // u_scu_afb2

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b011)) u_scu_afb3 (
    // TEMPLATE s/afb/afb3/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb3_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb3_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb3_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb3_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb3_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb3_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb3_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb3_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb3_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb3_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb3_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb3_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb3_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb3_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb3_valid),
    .afb_requires_master_o          (afb3_requires_master),
    .afb_l2db_hazard_tc3_o          (afb3_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb3_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb3_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb3_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb3_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb3_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb3_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb3_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb3_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb3_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb3_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb3_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb3_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb3_done_o),
    .afb_snoop_resp_valid_o         (afb3_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb3_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb3_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb3_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb3_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb3_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb3_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb3_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb3_write_done_o),
    .afb_req_single_o               (afb3_req_single),
    .afb_smp_en_o                   (afb3_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb3_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb3_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb3_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb3_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb3_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb3_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb3_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb3_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb3_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb3_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb3_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb3_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb3_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb3_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb3_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb3_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb3_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb3_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb3_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb3_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb3_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb3_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb3_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb3_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb3_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb3_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb3_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb3_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb3_cpuslv3_snp_active),
    .afb_master_active_o            (afb3_master_active),
    .afb_master_req_o               (afb3_master_req_o),
    .afb_master_flush_o             (afb3_master_flush_o),
    .afb_master_id_o                (afb3_master_id_o[6:0]),
    .afb_master_addr_o              (afb3_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb3_master_opcode_o[4:0]),
    .afb_master_len_o               (afb3_master_len_o[1:0]),
    .afb_master_size_o              (afb3_master_size_o[2:0]),
    .afb_master_lock_o              (afb3_master_lock_o),
    .afb_master_attrs_o             (afb3_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb3_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb3_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb3_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb3_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb3_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb3_ramctl_active),
    .afb_ramctl_valid_o             (afb3_ramctl_valid),
    .afb_ramctl_cancel_o            (afb3_ramctl_cancel),
    .afb_ramctl_index_o             (afb3_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb3_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb3_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb3_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb3_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb3_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb3_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb3_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb3_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb3_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb3_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb3_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb3_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb3_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb3_hz_tc1),
    .afb_hz_tc3_o                   (afb3_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb3_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb3_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb3_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb3_dvm_complete[3:0])
  );  // u_scu_afb3

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b100)) u_scu_afb4 (
    // TEMPLATE s/afb/afb4/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb4_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb4_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb4_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb4_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb4_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb4_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb4_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb4_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb4_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb4_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb4_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb4_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb4_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb4_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb4_valid),
    .afb_requires_master_o          (afb4_requires_master),
    .afb_l2db_hazard_tc3_o          (afb4_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb4_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb4_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb4_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb4_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb4_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb4_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb4_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb4_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb4_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb4_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb4_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb4_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb4_done_o),
    .afb_snoop_resp_valid_o         (afb4_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb4_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb4_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb4_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb4_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb4_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb4_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb4_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb4_write_done_o),
    .afb_req_single_o               (afb4_req_single),
    .afb_smp_en_o                   (afb4_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb4_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb4_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb4_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb4_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb4_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb4_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb4_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb4_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb4_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb4_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb4_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb4_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb4_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb4_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb4_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb4_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb4_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb4_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb4_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb4_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb4_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb4_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb4_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb4_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb4_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb4_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb4_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb4_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb4_cpuslv3_snp_active),
    .afb_master_active_o            (afb4_master_active),
    .afb_master_req_o               (afb4_master_req_o),
    .afb_master_flush_o             (afb4_master_flush_o),
    .afb_master_id_o                (afb4_master_id_o[6:0]),
    .afb_master_addr_o              (afb4_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb4_master_opcode_o[4:0]),
    .afb_master_len_o               (afb4_master_len_o[1:0]),
    .afb_master_size_o              (afb4_master_size_o[2:0]),
    .afb_master_lock_o              (afb4_master_lock_o),
    .afb_master_attrs_o             (afb4_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb4_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb4_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb4_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb4_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb4_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb4_ramctl_active),
    .afb_ramctl_valid_o             (afb4_ramctl_valid),
    .afb_ramctl_cancel_o            (afb4_ramctl_cancel),
    .afb_ramctl_index_o             (afb4_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb4_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb4_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb4_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb4_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb4_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb4_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb4_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb4_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb4_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb4_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb4_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb4_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb4_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb4_hz_tc1),
    .afb_hz_tc3_o                   (afb4_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb4_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb4_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb4_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb4_dvm_complete[3:0])
  );  // u_scu_afb4

  ca53scu_afb #(`CA53_SCU_INT_PARAM_INST, .AFB_NUM(3'b101)) u_scu_afb5 (
    // TEMPLATE s/afb/afb5/
    /*ARMAUTO*/
    .clk                            (clk_tagctl),
    // Inputs
    .reset_n                        (reset_n),
    .tagctl_broadcastinner_i        (tagctl_broadcastinner),
    .tagctl_broadcastouter_i        (tagctl_broadcastouter),
    .tagctl_broadcastcachemaint_i   (tagctl_broadcastcachemaint),
    .alloc_afb_tc1_i                (alloc_afb5_tc1),
    .flush_tc1_i                    (flush_tc1),
    .req_addr1_tc1_i                (req_addr1_tc1[40:0]),
    .req_addr2_tc1_i                (req_addr2_tc1[40:0]),
    .first_l2db_enc_tc1_i           (first_l2db_enc_tc1[3:0]),
    .second_l2db_enc_tc1_i          (second_l2db_enc_tc1[3:0]),
    .alloc_first_l2db_tc1_i         (alloc_first_l2db_tc1),
    .valid_second_l2db_tc1_i        (valid_second_l2db_tc1),
    .req_type_tc1_i                 (req_type_tc1[4:0]),
    .req_pass_tc1_i                 (req_pass_tc1[3:0]),
    .req_id_tc1_i                   (req_id_tc1[5:0]),
    .req_id_dcu_tc1_i               (req_id_dcu_tc1),
    .req_len_tc1_i                  (req_len_tc1[1:0]),
    .req_single_tc1_i               (req_single_tc1),
    .req_size_tc1_i                 (req_size_tc1[2:0]),
    .req_lock_tc1_i                 (req_lock_tc1),
    .req_dirty_tc1_i                (req_dirty_tc1),
    .req_cluster_unique_tc1_i       (req_cluster_unique_tc1),
    .req_attrs_tc1_i                (req_attrs_tc1[7:0]),
    .req_prot_tc1_i                 (req_prot_tc1[1:0]),
    .req_l2db_full_tc1_i            (req_l2db_full_tc1),
    .req_l2db_rmw_tc1_i             (req_l2db_rmw_tc1),
    .req_static_pcredit_tc1_i       (req_static_pcredit_tc1),
    .req_pcrdtype_tc1_i             (req_pcrdtype_tc1[1:0]),
    .req_l2flushreq_tc1_i           (req_l2flushreq_tc1),
    .smp_en_tc1_i                   (smp_en_tc1[3:0]),
    .sam_tgtid_tc2_i                (sam_tgtid_tc2_i[6:0]),
    .active_afb_tc2_i               (active_afb5_tc2),
    .flush_tc2_i                    (flush_tc2),
    .flush_afb_tc2_i                (flush_afb5_tc2),
    .l2_data_access_tc2_i           (l2_data_access_tc2),
    .req_l2_ecc_tc2_i               (req_l2_ecc_tc2[6:0]),
    .active_afb_tc3_i               (active_afb5_tc3),
    .flush_tc3_i                    (flush_tc3),
    .flush_afb_tc3_i                (flush_afb5_tc3),
    .victim_addr_tc3_i              (victim_addr_tc3[40:6]),
    .l1_lookup_hit_ways_tc3_i       (l1_lookup_hit_ways_tc3[15:0]),
    .l1_lookup_hit_cpus_tc3_i       (l1_lookup_hit_cpus_tc3[3:0]),
    .l1_lookup_hit_tc3_i            (l1_lookup_hit_tc3),
    .l1_victim_hit_ways_tc3_i       (l1_victim_hit_ways_tc3[15:0]),
    .l1_victim_hit_cpus_tc3_i       (l1_victim_hit_cpus_tc3[3:0]),
    .l1_victim_hit_tc3_i            (l1_victim_hit_tc3),
    .l1_ecc_victim_way_tc3_i        (l1_ecc_victim_way_tc3[3:0]),
    .l2_hit_tc3_i                   (l2_hit_tc3),
    .l2_hit_ways_tc3_i              (l2_hit_ways_tc3[15:0]),
    .l2_victim_way_tc3_i            (l2_victim_way_tc3[3:0]),
    .l2_hit_dirty_tc3_i             (l2_hit_dirty_tc3),
    .l2_dirty_tc3_i                 (l2_dirty_tc3),
    .l2_victim_valid_tc3_i          (l2_victim_valid_tc3),
    .l2_victim_dirty_tc3_i          (l2_victim_dirty_tc3),
    .l2_victim_alloc_tc3_i          (l2_victim_alloc_tc3),
    .l2_victim_cu_tc3_i             (l2_victim_cu_tc3),
    .l2_victim_shareability_tc3_i   (l2_victim_shareability_tc3[1:0]),
    .cluster_unique_tc3_i           (cluster_unique_tc3),
    .tagctl_hit_shareability_tc3_i  (tagctl_hit_shareability_tc3[1:0]),
    .active_afb_tc4_i               (active_afb5_tc4),
    .flush_tc4_i                    (flush_tc4),
    .flush_afb_tc4_i                (flush_afb5_tc4),
    .master_hz_tc4_i                (master_hz_tc4_i),
    .master_hz_waddr_tc4_i          (master_hz_waddr_tc4_i[3:0]),
    .master_waddr_valid_i           (master_waddr_valid_i[15:0]),
    .tagctl_disable_evict_tc3_i     (tagctl_disable_evict_tc3),
    .tagctl_enable_writeevict_tc3_i (tagctl_enable_writeevict_tc3),
    .cpuslv_snp_hz_tc2_i            (cpuslv_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_i         (cpuslv_snp_hz_id_tc2[4:0]),
    .cpuslv_snp_l2db_hz_tc2_i       (cpuslv_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_i    (cpuslv_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_cu_tc2_i       (cpuslv_snp_l2db_cu_tc2),
    .cpuslv_snp_l2db_tc2_i          (cpuslv_snp_l2db_tc2[3:0]),
    .l2db0_slv_done_i               (l2db0_slv_done_i),
    .l2db1_slv_done_i               (l2db1_slv_done_i),
    .l2db2_slv_done_i               (l2db2_slv_done_i),
    .l2db3_slv_done_i               (l2db3_slv_done_i),
    .l2db4_slv_done_i               (l2db4_slv_done_i),
    .l2db5_slv_done_i               (l2db5_slv_done_i),
    .l2db6_slv_done_i               (l2db6_slv_done_i),
    .l2db7_slv_done_i               (l2db7_slv_done_i),
    .l2db8_slv_done_i               (l2db8_slv_done_i),
    .l2db9_slv_done_i               (l2db9_slv_done_i),
    .l2db10_slv_done_i              (l2db10_slv_done_i),
    .round_robin_tc3_i              (round_robin_tc3[1:0]),
    .afb_cpu0_ac_ready_i            (afb5_cpu0_ac_ready),
    .cpuslv0_cr_valid_i             (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i                (cpuslv0_cr_id_i[2:0]),
    .cpuslv0_cr_dirty_i             (cpuslv0_cr_dirty_i),
    .cpuslv0_cr_age_i               (cpuslv0_cr_age_i),
    .cpuslv0_cr_alloc_i             (cpuslv0_cr_alloc_i),
    .cpuslv0_cr_migratory_i         (cpuslv0_cr_migratory_i),
    .afb_cpu1_ac_ready_i            (afb5_cpu1_ac_ready),
    .cpuslv1_cr_valid_i             (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i                (cpuslv1_cr_id_i[2:0]),
    .cpuslv1_cr_dirty_i             (cpuslv1_cr_dirty_i),
    .cpuslv1_cr_age_i               (cpuslv1_cr_age_i),
    .cpuslv1_cr_alloc_i             (cpuslv1_cr_alloc_i),
    .cpuslv1_cr_migratory_i         (cpuslv1_cr_migratory_i),
    .afb_cpu2_ac_ready_i            (afb5_cpu2_ac_ready),
    .cpuslv2_cr_valid_i             (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i                (cpuslv2_cr_id_i[2:0]),
    .cpuslv2_cr_dirty_i             (cpuslv2_cr_dirty_i),
    .cpuslv2_cr_age_i               (cpuslv2_cr_age_i),
    .cpuslv2_cr_alloc_i             (cpuslv2_cr_alloc_i),
    .cpuslv2_cr_migratory_i         (cpuslv2_cr_migratory_i),
    .afb_cpu3_ac_ready_i            (afb5_cpu3_ac_ready),
    .cpuslv3_cr_valid_i             (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i                (cpuslv3_cr_id_i[2:0]),
    .cpuslv3_cr_dirty_i             (cpuslv3_cr_dirty_i),
    .cpuslv3_cr_age_i               (cpuslv3_cr_age_i),
    .cpuslv3_cr_alloc_i             (cpuslv3_cr_alloc_i),
    .cpuslv3_cr_migratory_i         (cpuslv3_cr_migratory_i),
    .master_afb_ack_i               (master_afb5_ack_i),
    .ramctl_afb_ready_i             (ramctl_afb5_ready),
    .tagctl_afb_ready_tc0_i         (tagctl_afb5_ready_tc0),
    .tagctl_addr_tc1_i              (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i              (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3),
    .dcu_cpu0_dvm_complete_i        (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i        (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i        (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i        (dcu_cpu3_dvm_complete_i),
    .tagctl_mbistreq_i              (tagctl_mbistreq),
    // Outputs
    .afb_valid_o                    (afb5_valid),
    .afb_requires_master_o          (afb5_requires_master),
    .afb_l2db_hazard_tc3_o          (afb5_l2db_hazard_tc3),
    .afb_force_cluster_unique_tc3_o (afb5_force_cluster_unique_tc3),
    .afb_snoop_data_cpu_tc4_o       (afb5_snoop_data_cpu_tc4[1:0]),
    .afb_l2db_hazard_both_tc4_o     (afb5_l2db_hazard_both_tc4),
    .afb_slv_l2db_hit_tc3_o         (afb5_slv_l2db_hit_tc3),
    .afb_slv_l2db_dirty_tc3_o       (afb5_slv_l2db_dirty_tc3),
    .afb_slv_l2db_cu_tc3_o          (afb5_slv_l2db_cu_tc3),
    .afb_slv_l2db_o                 (afb5_slv_l2db[3:0]),
    .afb_slv_victim_l2db_tc4_o      (afb5_slv_victim_l2db_tc4[3:0]),
    .afb_slv_snp_hz_tc4_o           (afb5_slv_snp_hz_tc4),
    .afb_slv_snp_hz_id_tc4_o        (afb5_slv_snp_hz_id_tc4[4:0]),
    .afb_slv_l2db_invalidated_tc4_o (afb5_slv_l2db_invalidated_tc4),
    .afb_slv_l2db_cleaned_tc4_o     (afb5_slv_l2db_cleaned_tc4),
    .afb_done_o                     (afb5_done_o),
    .afb_snoop_resp_valid_o         (afb5_snoop_resp_valid_o),
    .afb_snoop_resp_dirty_o         (afb5_snoop_resp_dirty_o),
    .afb_snoop_resp_alloc_o         (afb5_snoop_resp_alloc_o),
    .afb_snoop_resp_migratory_o     (afb5_snoop_resp_migratory_o),
    .afb_snoop_resp_victim_valid_o  (afb5_snoop_resp_victim_valid_o),
    .afb_snoop_resp_victim_dirty_o  (afb5_snoop_resp_victim_dirty_o),
    .afb_snoop_resp_victim_age_o    (afb5_snoop_resp_victim_age_o),
    .afb_snoop_resp_victim_alloc_o  (afb5_snoop_resp_victim_alloc_o),
    .afb_write_done_o               (afb5_write_done_o),
    .afb_req_single_o               (afb5_req_single),
    .afb_smp_en_o                   (afb5_smp_en[3:0]),
    .afb_l2dbs_transfer_o           (afb5_l2dbs_transfer_o),
    .afb_l2dbs_id_o                 (afb5_l2dbs_id_o[3:0]),
    .afb_l2dbs_transfer_info_o      (afb5_l2dbs_transfer_info_o[23:0]),
    .afb_l2db_release_o             (afb5_l2db_release[MAX_L2DBS-1:0]),
    .afb_l2db_snoops_done_o         (afb5_l2db_snoops_done[MAX_L2DBS-1:0]),
    .afb_l2db_fill_strbs_o          (afb5_l2db_fill_strbs[MAX_L2DBS-1:0]),
    .afb_snoop_req_o                (afb5_snoop_req[3:0]),
    .afb_snoop_second_dvm_o         (afb5_snoop_second_dvm[3:0]),
    .afb_update_rr_tc3_o            (afb5_update_rr_tc3),
    .afb_cpu0_ac_snoop_o            (afb5_cpu0_ac_snoop[3:0]),
    .afb_cpu0_ac_l2db_id_o          (afb5_cpu0_ac_l2db_id[3:0]),
    .afb_cpu0_ac_addr_o             (afb5_cpu0_ac_addr[40:0]),
    .afb_cpu0_ac_way_o              (afb5_cpu0_ac_way[3:0]),
    .afb_cpu1_ac_snoop_o            (afb5_cpu1_ac_snoop[3:0]),
    .afb_cpu1_ac_l2db_id_o          (afb5_cpu1_ac_l2db_id[3:0]),
    .afb_cpu1_ac_addr_o             (afb5_cpu1_ac_addr[40:0]),
    .afb_cpu1_ac_way_o              (afb5_cpu1_ac_way[3:0]),
    .afb_cpu2_ac_snoop_o            (afb5_cpu2_ac_snoop[3:0]),
    .afb_cpu2_ac_l2db_id_o          (afb5_cpu2_ac_l2db_id[3:0]),
    .afb_cpu2_ac_addr_o             (afb5_cpu2_ac_addr[40:0]),
    .afb_cpu2_ac_way_o              (afb5_cpu2_ac_way[3:0]),
    .afb_cpu3_ac_snoop_o            (afb5_cpu3_ac_snoop[3:0]),
    .afb_cpu3_ac_l2db_id_o          (afb5_cpu3_ac_l2db_id[3:0]),
    .afb_cpu3_ac_addr_o             (afb5_cpu3_ac_addr[40:0]),
    .afb_cpu3_ac_way_o              (afb5_cpu3_ac_way[3:0]),
    .afb_cpuslv0_snp_active_o       (afb5_cpuslv0_snp_active),
    .afb_cpuslv1_snp_active_o       (afb5_cpuslv1_snp_active),
    .afb_cpuslv2_snp_active_o       (afb5_cpuslv2_snp_active),
    .afb_cpuslv3_snp_active_o       (afb5_cpuslv3_snp_active),
    .afb_master_active_o            (afb5_master_active),
    .afb_master_req_o               (afb5_master_req_o),
    .afb_master_flush_o             (afb5_master_flush_o),
    .afb_master_id_o                (afb5_master_id_o[6:0]),
    .afb_master_addr_o              (afb5_master_addr_o[40:0]),
    .afb_master_opcode_o            (afb5_master_opcode_o[4:0]),
    .afb_master_len_o               (afb5_master_len_o[1:0]),
    .afb_master_size_o              (afb5_master_size_o[2:0]),
    .afb_master_lock_o              (afb5_master_lock_o),
    .afb_master_attrs_o             (afb5_master_attrs_o[7:0]),
    .afb_master_prot_o              (afb5_master_prot_o[1:0]),
    .afb_master_tgtid_o             (afb5_master_tgtid_o[6:0]),
    .afb_master_l2db_o              (afb5_master_l2db_o[3:0]),
    .afb_master_static_pcredit_o    (afb5_master_static_pcredit_o),
    .afb_master_pcrdtype_o          (afb5_master_pcrdtype_o[1:0]),
    .afb_ramctl_active_o            (afb5_ramctl_active),
    .afb_ramctl_valid_o             (afb5_ramctl_valid),
    .afb_ramctl_cancel_o            (afb5_ramctl_cancel),
    .afb_ramctl_index_o             (afb5_ramctl_index[10:0]),
    .afb_ramctl_way_o               (afb5_ramctl_way[3:0]),
    .afb_ramctl_crit_chunk_o        (afb5_ramctl_crit_chunk[1:0]),
    .afb_ramctl_banks_o             (afb5_ramctl_banks[7:0]),
    .afb_ramctl_flush_o             (afb5_ramctl_flush),
    .afb_tagctl_valid_tc0_o         (afb5_tagctl_valid_tc0),
    .afb_tagctl_addr1_tc0_o         (afb5_tagctl_addr1_tc0[40:0]),
    .afb_tagctl_addr13_tc0_o        (afb5_tagctl_addr13_tc0),
    .afb_tagctl_wr_state_tc0_o      (afb5_tagctl_wr_state_tc0[16:0]),
    .afb_tagctl_ecc_tc0_o           (afb5_tagctl_ecc_tc0[34:0]),
    .afb_tagctl_ways_tc0_o          (afb5_tagctl_ways_tc0[31:0]),
    .afb_tagctl_type_tc0_o          (afb5_tagctl_type_tc0[4:0]),
    .afb_tagctl_requestor_tc0_o     (afb5_tagctl_requestor_tc0[3:0]),
    .afb_tagctl_addr2_tc1_o         (afb5_tagctl_addr2_tc1[40:0]),
    .afb_hz_tc1_o                   (afb5_hz_tc1),
    .afb_hz_tc3_o                   (afb5_hz_tc3),
    .afb_dvm_sync_tc3_o             (afb5_dvm_sync_tc3),
    .afb_snp_dvm_sync_tc4_o         (afb5_snp_dvm_sync_tc4),
    .afb_cpu_dvm_sync_tc4_o         (afb5_cpu_dvm_sync_tc4[3:0]),
    .afb_dvm_complete_o             (afb5_dvm_complete[3:0])
  );  // u_scu_afb5

  ca53scu_tagctl_ecc #(`CA53_SCU_INT_PARAM_INST) u_scu_tagctl_ecc (
    /*ARMAUTO*/
    .clk                      (clk_tagctl),
    // Inputs
    .reset_n                  (reset_n),
    .ecc_err_tc3_i            (ecc_err_tc3),
    .l1_tag_err_tc3_i         (l1_tag_err_tc3[15:0]),
    .l2_tag_err_tc3_i         (l2_tag_err_tc3[15:0]),
    .l1_tag_syndrome_tc3_i    (l1_tag_syndrome_tc3[111:0]),
    .l2_tag_syndrome_tc3_i    (l2_tag_syndrome_tc3[111:0]),
    .req_addr1_tc3_i          (req_addr1_tc3[16:6]),
    .victim_tag_tc3_i         (victim_tag_tc3[34:0]),
    .victim_tag_ecc_tc3_i     (victim_tag_ecc_tc3[6:0]),
    .req_ways_read_tc3_i      (req_ways_read_tc3[31:0]),
    .flush_tc0_i              (flush_tc0),
    .tagctl_l1_dc_size_i      (tagctl_l1_dc_size[2:0]),
    .tagctl_l2_size_i         (tagctl_l2_size[3:0]),
    .tagctl_ecc_hz_tc2_i      (tagctl_ecc_hz_tc2),
    .tagctl_mbistreq_i        (tagctl_mbistreq),
    .ecc_ac_ready_i           (ecc_ac_ready),
    .cpuslv0_cr_valid_i       (cpuslv0_cr_valid_i),
    .cpuslv0_cr_id_i          (cpuslv0_cr_id_i[2:0]),
    .cpuslv1_cr_valid_i       (cpuslv1_cr_valid_i),
    .cpuslv1_cr_id_i          (cpuslv1_cr_id_i[2:0]),
    .cpuslv2_cr_valid_i       (cpuslv2_cr_valid_i),
    .cpuslv2_cr_id_i          (cpuslv2_cr_id_i[2:0]),
    .cpuslv3_cr_valid_i       (cpuslv3_cr_valid_i),
    .cpuslv3_cr_id_i          (cpuslv3_cr_id_i[2:0]),
    // Outputs
    .ecc_in_progress_o        (ecc_in_progress),
    .ecc_tagctl_valid_tc0_o   (ecc_tagctl_valid_tc0),
    .ecc_tagctl_wr_tc0_o      (ecc_tagctl_wr_tc0),
    .ecc_tagctl_l2_tc0_o      (ecc_tagctl_l2_tc0),
    .ecc_tagctl_pass_tc0_o    (ecc_tagctl_pass_tc0[3:0]),
    .ecc_tagctl_index_tc0_o   (ecc_tagctl_index_tc0[10:0]),
    .ecc_tagctl_ways_tc0_o    (ecc_tagctl_ways_tc0[31:0]),
    .ecc_tagctl_wr_data_tc0_o (ecc_tagctl_wr_data_tc0[39:0]),
    .tagctl_ecc_wr_tc1_o      (tagctl_ecc_wr_tc1_o),
    .tagctl_err_valid_o       (tagctl_err_valid_o),
    .tagctl_err_fatal_o       (tagctl_err_fatal_o),
    .tagctl_err_index_o       (tagctl_err_index_o[10:0]),
    .tagctl_err_way_o         (tagctl_err_way_o[4:0]),
    .ecc_smp_en_o             (ecc_smp_en[3:0]),
    .ecc_snoop_req_o          (ecc_snoop_req[3:0]),
    .ecc_ac_addr_o            (ecc_ac_addr[40:0]),
    .ecc_ac_way_o             (ecc_ac_way[3:0])
  );  // u_scu_tagctl_ecc

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "afb_tc1 must be zero or onehot")
  u_ovl_afb_tc1_zoh (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (afb_tc1)
  );

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "afb_tc2 must be zero or onehot")
  u_ovl_afb_tc2_zoh (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (afb_tc2)
  );

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "afb_tc3 must be zero or onehot")
  u_ovl_afb_tc3_zoh (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (afb_tc3)
  );

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "afb_tc4 must be zero or onehot")
  u_ovl_afb_tc4_zoh (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (afb_tc4)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "afb_tc1 must only be set if stage is valid")
  u_ovl_afb_tc1 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|afb_tc1),
    .consequent_expr (valid_tc1)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "afb_tc2 must only be set if stage is valid")
  u_ovl_afb_tc2 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|afb_tc2),
    .consequent_expr (valid_tc2)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "afb_tc3 must only be set if stage is valid")
  u_ovl_afb_tc3 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|afb_tc3),
    .consequent_expr (valid_tc3)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "afb_tc4 must only be set if stage is valid")
  u_ovl_afb_tc4 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|afb_tc4),
    .consequent_expr (valid_tc4)
  );

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "Only one cpuslv may indicate an l2db snp hazard")
  u_ovl_snp_l2db_hz (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{valid_tc2 & req_type_tc2[5]}} & {cpuslv3_snp_l2db_hz_tc2_i,
                                                    cpuslv2_snp_l2db_hz_tc2_i,
                                                    cpuslv1_snp_l2db_hz_tc2_i,
                                                    cpuslv0_snp_l2db_hz_tc2_i})
  );

  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "Only one cpuslv may indicate a snp hazard")
  u_ovl_snp_hz (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({4{valid_tc2 & req_type_tc2[5]}} & {cpuslv3_snp_hz_tc2_i,
                                                    cpuslv2_snp_hz_tc2_i,
                                                    cpuslv1_snp_hz_tc2_i,
                                                    cpuslv0_snp_hz_tc2_i})
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Cannot serialise an L2DB that waas not previously unserialised")
  u_ovl_serialised_l2db (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc4 & ~flush_tc4 & serialised_l2db_tc4),
    .consequent_expr (unserialised_l2dbs_tc1 > 0)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Cannot exceed number of unserialsed L2DBs")
  u_ovl_unserialised_l2db (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (unserialised_l2db_tc1),
    .consequent_expr (unserialised_l2dbs_tc1 < (NUM_L2DBS - 3))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Invalid way selection must pick an invalid way")
  u_ovl_invalid_way_pick (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|l2_victim_invalid_ways_tc2),
    .consequent_expr (l2_victim_invalid_ways_tc2[l2_victim_invalid_way_tc2])
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim way provided must be an eligible way")
  u_ovl_valid_way_pick (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc2 & (req_pass_tc2 == `CA53_TAGCTL_PASS_L2_VICTIM)),
    .consequent_expr (|(l2_victim_eligible_ways_tc2 & (16'h0001 << req_victim_way_tc2)))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Ways must only be enabled when tc1 is valid")
  u_ovl_valid_ways (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|(req_ways_tc1 & {{16{valid_ways_tc1[4]}},
                                        {4{valid_ways_tc1[3]}},
                                        {4{valid_ways_tc1[2]}},
                                        {4{valid_ways_tc1[1]}},
                                        {4{valid_ways_tc1[0]}}})),
    .consequent_expr (valid_tc1 | inval_active)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "first_l2db_avail_for_write_tc1 correct for writes")
  u_ovl_l2db_avail (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc1 & alloc_l2db_for_write_tc1),
    .consequent_expr (first_l2db_avail_for_write_tc1 == first_l2db_avail_tc1)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "first_l2db_avail_for_acp_read_tc1 correct for acp reads")
  u_ovl_acp_l2db_avail (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc1 & alloc_l2db_for_acp_read_tc1),
    .consequent_expr (first_l2db_avail_for_acp_read_tc1 == first_l2db_avail_tc1)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Ways must not be suppressed on an L2 victim pass")
  u_ovl_l2_way_used (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc2 & (req_pass_tc2 == `CA53_TAGCTL_PASS_L2_VICTIM)),
    .consequent_expr (~|(`CA53_L2_WAY_DEC(req_victim_way_tc2) & (cpuslv0_l2_way_used_tc2_i |
                                                                 cpuslv1_l2_way_used_tc2_i |
                                                                 cpuslv2_l2_way_used_tc2_i |
                                                                 cpuslv3_l2_way_used_tc2_i |
                                                                 acpslv_l2_way_used_tc2_i |
                                                                 snpslv_l2_way_used_tc2_i)))
  );

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Cannot select a CPU that is not present")
  u_ovl_round_robin_tc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (round_robin_tc3 < NUM_CPUS)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "No L2 data index may be selected when another access is in progress")
  u_ovl_l2_dataram_index (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ramctl_mask_tc2_i),
    .consequent_expr (~|tagctl_l2dataram_index_o)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "No L2 data way may be selected when another access is in progress")
  u_ovl_l2_dataram_way (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ramctl_mask_tc2_i),
    .consequent_expr (~|tagctl_l2dataram_way_o)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only some requests types can make an L2DB pass")
  u_ovl_write_l2db (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (valid_tc1 & (req_pass_tc1 == `CA53_TAGCTL_PASS_L2DB)),
    .consequent_expr ((req_type_tc1 == `CA53_AFB_REQ_WRITENOSNOOP) |
                      (req_type_tc1 == `CA53_AFB_REQ_WRITEUNIQUE) |
                      (req_type_tc1 == `CA53_AFB_REQ_DVM) |
                      ((req_type_tc1 == `CA53_AFB_REQ_READONCE) &
                       (req_id_tc1[5:3] == 3'b100)))
  );


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: inval_count_en")
  u_ovl_x_inval_count_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (inval_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_hz_count_tc1_en")
  u_ovl_x_l2db_hz_count_tc1_en (.clk       (clk_tagctl),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (l2db_hz_count_tc1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ncoh_writes_en_tc3")
  u_ovl_x_ncoh_writes_en_tc3 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ncoh_writes_en_tc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_mbistreq")
  u_ovl_x_tagctl_mbistreq (.clk       (clk_tagctl),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (tagctl_mbistreq));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: unserialised_l2dbs_tc1_en")
  u_ovl_x_unserialised_l2dbs_tc1_en (.clk       (clk_tc1),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (unserialised_l2dbs_tc1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victim_way_rr_en")
  u_ovl_x_victim_way_rr_en (.clk       (clk_tagctl),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (victim_way_rr_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: inval_active")
  u_ovl_x_inval_active (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (inval_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: req_tc1_en")
  u_ovl_x_req_tc1_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (req_tc1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: round_robin_tc3_en")
  u_ovl_x_round_robin_tc3_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (round_robin_tc3_en));

  assert_never_unknown #(`OVL_FATAL, NUM_CPUS, `OVL_ASSERT, "Register enable x-check: snoop_accepted")
  u_ovl_x_snoop_accepted (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (snoop_accepted[NUM_CPUS-1:0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_active")
  u_ovl_x_tagctl_active (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (tagctl_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_tc1")
  u_ovl_x_valid_tc1 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (valid_tc1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_tc2")
  u_ovl_x_valid_tc2 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (valid_tc2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: valid_tc3")
  u_ovl_x_valid_tc3 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (valid_tc3));

`endif


endmodule // ca53scu_tagctl

/*ARMAUTO_UNDEF*/
`undef CA53_SCU_TAG_VALID
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_scu_dcu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
