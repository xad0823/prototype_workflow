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
//  The ACP slave sits between the SCU and the external ACP interface.
//  It buffers read and write data, and also keeps track of all requests
//  in request buffers.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"


module ca53scu_acpslv #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire         CLKIN,
  input  wire         clk,
  input  wire         reset_n,
  input  wire         DFTSE,

  output wire         acpslv_active_o,
  output wire         acpslv_ramctl_active_o,

  input  wire         leaving_reset_i,
  input  wire         config_broadcastinner_i,
  input  wire         config_broadcastouter_i,
  input  wire [2:0]   config_l1_dc_size_i,
  input  wire [3:0]   config_l2_size_i,

  input  wire         gov_enable_writeevict_i,
  input  wire         gov_l2_in_retention_i,

  // External interface
  input  wire         clean_aclkens_i,
  input  wire         acp_ainact_rs_i,
  output wire         scu_acp_awready_o,
  input  wire         ext_acp_awvalid_i,
  input  wire [4:0]   ext_acp_awid_i,
  input  wire [39:0]  ext_acp_awaddr_i,
  input  wire [7:0]   ext_acp_awlen_i,
  input  wire [3:0]   ext_acp_awcache_i,
  input  wire [1:0]   ext_acp_awuser_i,
  input  wire [2:0]   ext_acp_awprot_i,
  output wire         scu_acp_wready_o,
  input  wire         ext_acp_wvalid_i,
  input  wire [127:0] ext_acp_wdata_i,
  input  wire [15:0]  ext_acp_wstrb_i,
  input  wire         ext_acp_wlast_i,
  input  wire         ext_acp_bready_i,
  output wire         scu_acp_bvalid_o,
  output wire [4:0]   scu_acp_bid_o,
  output wire [1:0]   scu_acp_bresp_o,
  output wire         scu_acp_arready_o,
  input  wire         ext_acp_arvalid_i,
  input  wire [4:0]   ext_acp_arid_i,
  input  wire [39:0]  ext_acp_araddr_i,
  input  wire [7:0]   ext_acp_arlen_i,
  input  wire [3:0]   ext_acp_arcache_i,
  input  wire [1:0]   ext_acp_aruser_i,
  input  wire [2:0]   ext_acp_arprot_i,
  input  wire         ext_acp_rready_i,
  output wire         scu_acp_rvalid_o,
  output wire [4:0]   scu_acp_rid_o,
  output wire [127:0] scu_acp_rdata_o,
  output wire [1:0]   scu_acp_rresp_o,
  output wire         scu_acp_rlast_o,

  // Tagctl requests
  output wire         acpslv_tagctl_valid_tc0_o,
  output wire         acpslv_tagctl_early_valid_tc0_o,
  output wire         acpslv_tagctl_spec_valid_tc0_o,
  output wire         acpslv_tagctl_active_tc0_o,
  input  wire         tagctl_acpslv_ready_tc0_i,
  input  wire         tagctl_acpslv_noncoh_only_i,
  output wire [2:0]   acpslv_tagctl_reqbufid_tc0_o,
  output wire [3:0]   acpslv_tagctl_pass_tc0_o,
  output wire [40:0]  acpslv_tagctl_addr1_tc0_o,
  output wire [16:0]  acpslv_tagctl_wr_state_tc0_o,
  output wire [34:0]  acpslv_tagctl_ecc_tc0_o,
  output wire [31:0]  acpslv_tagctl_ways_tc0_o,
  output wire [4:0]   acpslv_tagctl_write_tc0_o,
  output wire [4:0]   acpslv_tagctl_type_tc0_o,
  output wire [1:0]   acpslv_tagctl_len_tc1_o,
  output wire         acpslv_tagctl_single_tc1_o,
  output wire [2:0]   acpslv_tagctl_size_tc1_o,
  output wire [7:0]   acpslv_tagctl_attrs_tc1_o,
  output wire         acpslv_tagctl_dirty_tc1_o,
  output wire         acpslv_tagctl_cluster_unique_tc1_o,
  output wire [1:0]   acpslv_tagctl_prot_tc1_o,
  output wire [3:0]   acpslv_tagctl_l2db_tc1_o,
  output wire         acpslv_tagctl_l2db_full_tc1_o,
  output wire         acpslv_tagctl_static_pcredit_tc1_o,
  output wire [1:0]   acpslv_tagctl_pcrdtype_tc1_o,
  output wire [3:0]   acpslv_tagctl_victim_way_tc1_o,
  output wire         acpslv_tagctl_slverr_tc1_o,

  input  wire         tagctl_slv_flush_tc1_i,
  input  wire         tagctl_slv_flush_tc2_i,
  input  wire         tagctl_slv_flush_tc3_i,
  input  wire         tagctl_slv_flush_tc4_i,
  input  wire         tagctl_slv_early_flush_tc4_i,
  input  wire [2:0]   tagctl_slv_afb_tc1_i,
  input  wire [3:0]   tagctl_slv_l2db_tc1_i,
  input  wire [3:0]   tagctl_slv_l2db_tc4_i,
  input  wire [15:0]  tagctl_l1_hit_ways_tc3_i,
  input  wire [15:0]  tagctl_l2_hit_ways_tc3_i,
  input  wire         tagctl_l2_dirty_tc3_i,
  input  wire [1:0]   tagctl_shareability_tc3_i,
  input  wire         tagctl_cluster_unique_tc3_i,
  input  wire         tagctl_l2_victim_valid_tc3_i,
  input  wire [1:0]   tagctl_l2_victim_shareability_tc3_i,
  input  wire         tagctl_l2_victim_alloc_tc3_i,
  input  wire         tagctl_l2_victim_cu_tc3_i,
  input  wire [3:0]   tagctl_l2_victim_way_tc3_i,
  input  wire         tagctl_ecc_err_tc3_i,
  input  wire [1:0]   tagctl_snoop_data_cpu_tc4_i,

  input  wire         afb0_done_i,
  input  wire         afb1_done_i,
  input  wire         afb2_done_i,
  input  wire         afb3_done_i,
  input  wire         afb4_done_i,
  input  wire         afb5_done_i,
  input  wire         afb0_write_done_i,
  input  wire         afb1_write_done_i,
  input  wire         afb2_write_done_i,
  input  wire         afb3_write_done_i,
  input  wire         afb4_write_done_i,
  input  wire         afb5_write_done_i,

  input  wire [41:6]  tagctl_addr_tc1_i,
  input  wire         tagctl_addr_valid_tc1_i,
  input  wire [5:0]   tagctl_reqbufid_tc1_i,
  input  wire         tagctl_index_valid_tc1_i,
  input  wire         tagctl_serialising_tc1_i,
  input  wire         tagctl_l1_lf_tc1_i,
  input  wire [15:0]  tagctl_ecc_way_tc1_i,
  output wire         acpslv_hz_tc2_o,
  output wire [15:0]  acpslv_force_miss_tc2_o,
  output wire [15:0]  acpslv_l2_way_used_tc2_o,
  input  wire [40:6]  tagctl_addr_tc3_i,
  input  wire         tagctl_addr_valid_tc3_i,
  input  wire [5:0]   tagctl_reqbufid_tc3_i,
  output wire         acpslv_hz_tc4_o,

  // Victimctl requests
  output wire         acpslv_victimctl_active_o,
  output wire         acpslv_victimctl_valid_o,
  output wire [10:0]  acpslv_victimctl_index_o,
  output wire         acpslv_victimctl_wr_o,
  output wire         acpslv_victimctl_age_o,
  output wire [3:0]   acpslv_victimctl_way_o,
  output wire [2:0]   acpslv_victimctl_id_o,
  input  wire         victimctl_ready_i,
  input  wire [5:0]   victimctl_ready_id_i,

  input  wire         victimctl_ack_i,
  input  wire [5:0]   victimctl_ack_id_i,
  input  wire [3:0]   victimctl_victim_way_i,

  input  wire [10:0]  victimctl_index_vc1_i,
  output wire [15:0]  acpslv_l2_way_used_vc2_o,

  // L2DB control
  output wire         acpslv_l2dbs_active_o,

  output wire         acpslv_l2db0_transfer_o,
  output wire [2:0]   acpslv_l2db0_transfer_type_o,
  output wire [25:0]  acpslv_l2db0_transfer_info_o,
  output wire         acpslv_l2db0_release_o,

  output wire         acpslv_l2db1_transfer_o,
  output wire [2:0]   acpslv_l2db1_transfer_type_o,
  output wire [25:0]  acpslv_l2db1_transfer_info_o,
  output wire         acpslv_l2db1_release_o,

  output wire         acpslv_l2db2_transfer_o,
  output wire [2:0]   acpslv_l2db2_transfer_type_o,
  output wire [25:0]  acpslv_l2db2_transfer_info_o,
  output wire         acpslv_l2db2_release_o,

  output wire         acpslv_l2db3_transfer_o,
  output wire [2:0]   acpslv_l2db3_transfer_type_o,
  output wire [25:0]  acpslv_l2db3_transfer_info_o,
  output wire         acpslv_l2db3_release_o,

  output wire         acpslv_l2db4_transfer_o,
  output wire [2:0]   acpslv_l2db4_transfer_type_o,
  output wire [25:0]  acpslv_l2db4_transfer_info_o,
  output wire         acpslv_l2db4_release_o,

  output wire         acpslv_l2db5_transfer_o,
  output wire [2:0]   acpslv_l2db5_transfer_type_o,
  output wire [25:0]  acpslv_l2db5_transfer_info_o,
  output wire         acpslv_l2db5_release_o,

  output wire         acpslv_l2db6_transfer_o,
  output wire [2:0]   acpslv_l2db6_transfer_type_o,
  output wire [25:0]  acpslv_l2db6_transfer_info_o,
  output wire         acpslv_l2db6_release_o,

  output wire         acpslv_l2db7_transfer_o,
  output wire [2:0]   acpslv_l2db7_transfer_type_o,
  output wire [25:0]  acpslv_l2db7_transfer_info_o,
  output wire         acpslv_l2db7_release_o,

  output wire         acpslv_l2db8_transfer_o,
  output wire [2:0]   acpslv_l2db8_transfer_type_o,
  output wire [25:0]  acpslv_l2db8_transfer_info_o,
  output wire         acpslv_l2db8_release_o,

  output wire         acpslv_l2db9_transfer_o,
  output wire [2:0]   acpslv_l2db9_transfer_type_o,
  output wire [25:0]  acpslv_l2db9_transfer_info_o,
  output wire         acpslv_l2db9_release_o,

  output wire         acpslv_l2db10_transfer_o,
  output wire [2:0]   acpslv_l2db10_transfer_type_o,
  output wire [25:0]  acpslv_l2db10_transfer_info_o,
  output wire         acpslv_l2db10_release_o,

  input  wire         l2db0_slv_done_i,
  input  wire         l2db1_slv_done_i,
  input  wire         l2db2_slv_done_i,
  input  wire         l2db3_slv_done_i,
  input  wire         l2db4_slv_done_i,
  input  wire         l2db5_slv_done_i,
  input  wire         l2db6_slv_done_i,
  input  wire         l2db7_slv_done_i,
  input  wire         l2db8_slv_done_i,
  input  wire         l2db9_slv_done_i,
  input  wire         l2db10_slv_done_i,

  input  wire         l2db0_full_line_i,
  input  wire         l2db1_full_line_i,
  input  wire         l2db2_full_line_i,
  input  wire         l2db3_full_line_i,
  input  wire         l2db4_full_line_i,
  input  wire         l2db5_full_line_i,
  input  wire         l2db6_full_line_i,
  input  wire         l2db7_full_line_i,
  input  wire         l2db8_full_line_i,
  input  wire         l2db9_full_line_i,
  input  wire         l2db10_full_line_i,

  input  wire         l2db0_rmw_line_i,
  input  wire         l2db1_rmw_line_i,
  input  wire         l2db2_rmw_line_i,
  input  wire         l2db3_rmw_line_i,
  input  wire         l2db4_rmw_line_i,
  input  wire         l2db5_rmw_line_i,
  input  wire         l2db6_rmw_line_i,
  input  wire         l2db7_rmw_line_i,
  input  wire         l2db8_rmw_line_i,
  input  wire         l2db9_rmw_line_i,
  input  wire         l2db10_rmw_line_i,

  // CompAck requests
  output wire         acpslv_compack_active_o,
  output wire         acpslv_compack_valid_o,
  output wire [6:0]   acpslv_compack_tgtid_o,
  output wire [7:0]   acpslv_compack_txnid_o,
  input  wire         snpslv_acpslv_compack_ready_i,

  // Master read data
  input  wire         master_early_dr_valid_i,
  input  wire         master_early_dr_barrier_i,
  input  wire [5:0]   master_early_dr_id_i,
  input  wire [7:0]   master_early_dr_dbid_i,
  input  wire [6:0]   master_early_dr_srcid_i,
  input  wire [1:0]   master_early_dr_chunk_i,
  input  wire [3:0]   master_early_dr_resp_i,
  input  wire         master_early_dr_same_i,
  input  wire         master_early_dr_ready_i,
  output wire [15:0]  acpslv_early_dr_ready_o,
  output wire         acpslv_early_dr_l2_o,
  output wire [10:0]  acpslv_early_dr_index_o,
  output wire [3:0]   acpslv_early_dr_way_o,
  output wire [3:0]   acpslv_delay_allocation_o,

  input  wire         master_acpslv_dr_valid_i,
  output wire         acpslv_master_dr_ready_o,
  input  wire [5:0]   master_acpslv_dr_id_i,
  input  wire [1:0]   master_dr_chunk_i,
  input  wire [127:0] master_dr_data_i,
  input  wire [3:0]   master_dr_resp_i,
  input  wire [3:0]   master_acpslv_l2_waiting_i,

  input  wire         master_rsp_comp_valid_i,
  input  wire [6:0]   master_rsp_txnid_i,
  input  wire [7:0]   master_rsp_dbid_i,
  input  wire [6:0]   master_rsp_srcid_i,
  input  wire [3:0]   master_rsp_resp_i,

  input  wire [3:0]   master_acpslv_reqbuf_retry_i,
  input  wire [1:0]   master_acpslv_pcrdtype_i,
  output wire         acpslv_master_sactive_o,

  output wire         acpslv_ext_err_o,

  // L2DB read data
  input  wire         l2db0_slv_valid_i,
  input  wire [5:0]   l2db0_slv_id_i,
  input  wire [127:0] l2db0_slv_data_i,
  input  wire         l2db0_slv_err_i,
  input  wire         l2db0_slv_last_i,
  output wire         acpslv_l2db0_ready_o,

  input  wire         l2db1_slv_valid_i,
  input  wire [5:0]   l2db1_slv_id_i,
  input  wire [127:0] l2db1_slv_data_i,
  input  wire         l2db1_slv_err_i,
  input  wire         l2db1_slv_last_i,
  output wire         acpslv_l2db1_ready_o,

  input  wire         l2db2_slv_valid_i,
  input  wire [5:0]   l2db2_slv_id_i,
  input  wire [127:0] l2db2_slv_data_i,
  input  wire         l2db2_slv_err_i,
  input  wire         l2db2_slv_last_i,
  output wire         acpslv_l2db2_ready_o,

  input  wire         l2db3_slv_valid_i,
  input  wire [5:0]   l2db3_slv_id_i,
  input  wire [127:0] l2db3_slv_data_i,
  input  wire         l2db3_slv_err_i,
  input  wire         l2db3_slv_last_i,
  output wire         acpslv_l2db3_ready_o,

  input  wire         l2db4_slv_valid_i,
  input  wire [5:0]   l2db4_slv_id_i,
  input  wire [127:0] l2db4_slv_data_i,
  input  wire         l2db4_slv_err_i,
  input  wire         l2db4_slv_last_i,
  output wire         acpslv_l2db4_ready_o,

  input  wire         l2db5_slv_valid_i,
  input  wire [5:0]   l2db5_slv_id_i,
  input  wire [127:0] l2db5_slv_data_i,
  input  wire         l2db5_slv_err_i,
  input  wire         l2db5_slv_last_i,
  output wire         acpslv_l2db5_ready_o,

  input  wire         l2db6_slv_valid_i,
  input  wire [5:0]   l2db6_slv_id_i,
  input  wire [127:0] l2db6_slv_data_i,
  input  wire         l2db6_slv_err_i,
  input  wire         l2db6_slv_last_i,
  output wire         acpslv_l2db6_ready_o,

  input  wire         l2db7_slv_valid_i,
  input  wire [5:0]   l2db7_slv_id_i,
  input  wire [127:0] l2db7_slv_data_i,
  input  wire         l2db7_slv_err_i,
  input  wire         l2db7_slv_last_i,
  output wire         acpslv_l2db7_ready_o,

  input  wire         l2db8_slv_valid_i,
  input  wire [5:0]   l2db8_slv_id_i,
  input  wire [127:0] l2db8_slv_data_i,
  input  wire         l2db8_slv_err_i,
  input  wire         l2db8_slv_last_i,
  output wire         acpslv_l2db8_ready_o,

  input  wire         l2db9_slv_valid_i,
  input  wire [5:0]   l2db9_slv_id_i,
  input  wire [127:0] l2db9_slv_data_i,
  input  wire         l2db9_slv_err_i,
  input  wire         l2db9_slv_last_i,
  output wire         acpslv_l2db9_ready_o,

  input  wire         l2db10_slv_valid_i,
  input  wire [5:0]   l2db10_slv_id_i,
  input  wire [127:0] l2db10_slv_data_i,
  input  wire         l2db10_slv_err_i,
  input  wire         l2db10_slv_last_i,
  output wire         acpslv_l2db10_ready_o,

  // L2DB write data
  output wire         acpslv_l2dbs_dw_valid_o,
  output wire [3:0]   acpslv_l2dbs_dw_id_o,
  output wire [1:0]   acpslv_l2dbs_dw_chunk_o,
  output wire         acpslv_l2dbs_dw_last_o,
  output wire [127:0] acpslv_l2dbs_dw_data_o,
  output wire [15:0]  acpslv_l2dbs_dw_strb_o
);

  localparam NUM_REQBUFS = 4;

generate if (ACP) begin : g_acpslv
  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  genvar i;
  genvar j;

  reg                                acp_int_clk_enable;
  reg                                acp_ext_clk_enable;
  reg                                ext_acp_clk_enable;
  reg [NUM_REQBUFS-1:0]              tagctl_prearb_tc0;
  reg [NUM_REQBUFS-1:0]              tagctl_prearb_mask;
  reg [NUM_REQBUFS-1:0]              reqbuf_arb_tc1;
  reg                                tagctl_prearb_primary;
  reg [6:0]                          reqbufs_l1_ecc_tc0;
  reg [6:0]                          reqbufs_l2_ecc_tc0;
  reg [NUM_L2DBS-1:0]                l2db_buf_release;
  reg                                scu_acp_ar_ready;
  reg                                acp_ar_valid;
  reg                                ar_valid_sent;
  reg [4:0]                          ar_id;
  reg [39:0]                         ar_addr;
  reg [7:0]                          ar_len;
  reg [3:0]                          ar_cache;
  reg [1:0]                          ar_user;
  reg                                ar_prot;
  reg                                scu_acp_aw_ready;
  reg                                acp_aw_valid;
  reg                                aw_valid_sent;
  reg [4:0]                          aw_id;
  reg [39:0]                         aw_addr;
  reg [7:0]                          aw_len;
  reg [3:0]                          aw_cache;
  reg [1:0]                          aw_user;
  reg                                aw_prot;
  reg                                addr_rr;
  reg                                scu_acp_dr_valid;
  reg                                scu_acp_db_valid;
  reg                                dr_skid_valid;
  reg [4:0]                          dr_skid_id;
  reg [1:0]                          dr_skid_resp;
  reg [127:0]                        dr_skid_data;
  reg                                dr_skid_last;
  reg [4:0]                          scu_acp_dr_id;
  reg [1:0]                          scu_acp_dr_resp;
  reg [127:0]                        scu_acp_dr_data;
  reg                                scu_acp_dr_last;
  reg                                dw_oldest;
  reg                                acp_dw0_valid;
  reg                                acp_dw1_valid;
  reg                                dw0_valid_sent;
  reg                                dw1_valid_sent;
  reg                                scu_acp_dw_ready;
  reg [127:0]                        dw0_data;
  reg [127:0]                        dw1_data;
  reg [15:0]                         dw0_strb;
  reg [15:0]                         dw1_strb;
  reg                                dw0_last;
  reg                                dw1_last;
  reg [1:0]                          scu_acp_db_resp;
  reg [4:0]                          scu_acp_db_id;
  reg                                db_skid_valid;
  reg [1:0]                          db_skid_resp;
  reg [4:0]                          db_skid_id;
  reg                                acpslv_hz_tc2;
  reg                                acpslv_hz_tc4;
  reg                                acpslv_ecc_err_tc4;
  reg                                acpslv_enable_writeevict;
  reg                                acpslv_noncoh_only;
  reg                                acpslv_broadcastinner;
  reg                                acpslv_broadcastouter;
  reg [2:0]                          acpslv_l1_dc_size;
  reg [3:0]                          acpslv_l2_size;
  reg [15:0]                         acpslv_force_miss_tc2;
  reg [15:0]                         acpslv_l2_way_used_tc2;
  reg [15:0]                         acpslv_l2_way_used_vc2;
  reg                                acpslv_ext_err;
  reg [NUM_REQBUFS-1:0]              reqbuf_compack_ready;

  wire                               clk_acp;
  wire                               clk_ext_acp;
  wire                               acpslv_int_active;
  wire                               next_acp_int_clk_enable;
  wire                               next_acp_ext_clk_enable;
  wire                               next_ext_acp_clk_enable;
  wire                               acp_clk_enable;
  wire [MAX_L2DBS+NUM_REQBUFS:0]     dr_req;
  wire [MAX_L2DBS+NUM_REQBUFS:0]     dr_arb;
  wire [NUM_REQBUFS-1:0]             l2db_slv_id;
  wire [NUM_REQBUFS-1:0]             dr_slv_id;
  wire [MAX_L2DBS+NUM_REQBUFS:0]     dr_ready;
  wire                               dr_en;
  wire [NUM_REQBUFS-1:0]             reqbuf_alloc;
  wire [NUM_REQBUFS-1:0]             reqbuf_busy;
  wire [`CA53_LOG2(NUM_REQBUFS)-1:0] reqbuf_alloc_enc;
  wire [NUM_REQBUFS-1:0]             tagctl_sel_prearb_tc0;
  wire [NUM_REQBUFS:0]               tagctl_arb_tc0;
  wire [NUM_REQBUFS-1:0]             next_reqbuf_arb_tc1;
  wire                               reqbuf_arb_tc1_en;
  wire                               acpslv_tagctl_early_valid_tc0;
  wire [2*NUM_REQBUFS-1:0]           l2db_transfer      [MAX_L2DBS-1:0];
  wire [2:0]                         l2db_transfer_type [MAX_L2DBS-1:0];
  wire [25:0]                        l2db_transfer_info [MAX_L2DBS-1:0];
  wire [2*NUM_REQBUFS-1:0]           l2db_release       [MAX_L2DBS-1:0];
  wire [NUM_L2DBS-1:0]               next_l2db_buf_release;
  wire [NUM_REQBUFS*NUM_REQBUFS-1:0] reqbuf_older_pkd;
  wire                               tagctl_prearb_en;
  wire                               next_tagctl_prearb_primary;
  wire [NUM_REQBUFS-1:0]             tagctl_prearb;
  wire [NUM_REQBUFS-1:0]             next_tagctl_prearb_mask;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_primary;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_victim;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_valid_tc0;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_req;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_pri1;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_pri2;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_primary_tc0;
  wire [NUM_REQBUFS-1:0]             reqbuf_update_primary_pass;
  wire [NUM_REQBUFS-1:0]             reqbuf_update_victim_pass;
  wire [NUM_REQBUFS-1:0]             reqbuf_ext_err;
  wire                               next_acpslv_ext_err;
  wire [NUM_REQBUFS-1:0]             reqbuf_hz_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_hz_tc3;
  wire [15:0]                        reqbuf_force_miss_tc1             [NUM_REQBUFS-1:0];
  wire [15:0]                        reqbuf_l2_way_used_tc1            [NUM_REQBUFS-1:0];
  wire [15:0]                        reqbuf_l2_way_used_vc1            [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_early_dr_l2;
  wire [10:0]                        reqbuf_early_dr_index             [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_early_dr_way               [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_tagctl_pass_tc0            [NUM_REQBUFS-1:0];
  wire [40:0]                        reqbuf_tagctl_addr1_tc0           [NUM_REQBUFS-1:0];
  wire [16:0]                        reqbuf_tagctl_wr_state_tc0        [NUM_REQBUFS-1:0];
  wire [31:0]                        reqbuf_tagctl_ways_tc0            [NUM_REQBUFS-1:0];
  wire [4:0]                         reqbuf_tagctl_write_tc0           [NUM_REQBUFS-1:0];
  wire [4:0]                         reqbuf_type                       [NUM_REQBUFS-1:0];
  wire                               reqbuf_slverr                     [NUM_REQBUFS-1:0];
  wire                               reqbuf_static_pcredit_tc1         [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_pcrdtype_tc1               [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_victim_way_tc1             [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_tc1                   [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_primary_transfer      [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_victim_transfer       [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_primary_id            [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_victim_id             [NUM_REQBUFS-1:0];
  wire [2:0]                         reqbuf_l2db_primary_transfer_type [NUM_REQBUFS-1:0];
  wire [25:0]                        reqbuf_l2db_primary_transfer_info [NUM_REQBUFS-1:0];
  wire [2:0]                         reqbuf_l2db_victim_transfer_type  [NUM_REQBUFS-1:0];
  wire [25:0]                        reqbuf_l2db_victim_transfer_info  [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_primary_release       [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_victim_release        [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_wdata_chunk                [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_arb;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_valid;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_wr;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_age;
  wire [10:0]                        reqbuf_victimctl_index [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_victimctl_way   [NUM_REQBUFS-1:0];
  wire                               zero;
  wire [40:0]                        reqbufs_prearb_addr;
  wire [NUM_REQBUFS-1:0]             reqbuf_dw_arb;
  wire                               next_acpslv_noncoh_only;
  wire [NUM_REQBUFS-1:0]             acpslv_wdata_valid;
  wire                               acpslv_wdata_last;
  wire [NUM_REQBUFS-1:0]             reqbuf_wait_data;
  wire [NUM_REQBUFS-1:0]             reqbuf_ramctl_active;
  wire                               ar_valid_en;
  wire                               next_ar_valid_sent;
  wire                               ar_valid;
  wire                               ar_en;
  wire                               ar_ready;
  wire                               acpslv_inact;
  wire                               next_scu_acp_ar_ready;
  wire                               aw_valid_en;
  wire                               next_aw_valid_sent;
  wire                               aw_valid;
  wire                               aw_en;
  wire                               aw_ready;
  wire                               next_scu_acp_aw_ready;
  wire                               dr_arb_req;
  wire                               dr_arb_en;
  wire [4:0]                         dr_id;
  wire [4:0]                         reqbuf_acp_id         [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_len            [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_len_tc1        [NUM_REQBUFS-1:0];
  wire                               reqbuf_dirty          [NUM_REQBUFS-1:0];
  wire                               reqbuf_cluster_unique [NUM_REQBUFS-1:0];
  wire [7:0]                         reqbuf_attrs          [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_prot           [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_full      [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_dr_last;
  wire [NUM_REQBUFS-1:0]             reqbuf_suppress_dr;
  wire [NUM_REQBUFS-1:0]             reqbuf_id_hazard;
  wire [1:0]                         dr_resp;
  wire [127:0]                       dr_data;
  wire                               dr_last;
  wire                               master_dr_last;
  wire                               acpslv_master_dr_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_dr_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_dr_valid;
  wire                               next_dr_skid_valid;
  wire                               dr_skid_en;
  wire                               next_scu_acp_dr_valid;
  wire [4:0]                         next_scu_acp_dr_id;
  wire [1:0]                         next_scu_acp_dr_resp;
  wire [127:0]                       next_scu_acp_dr_data;
  wire                               next_scu_acp_dr_last;
  wire                               next_acp_dw0_valid;
  wire                               next_acp_dw1_valid;
  wire                               dw0_valid;
  wire                               dw1_valid;
  wire                               dw_valid;
  wire                               dw_sel;
  wire                               dw_ready;
  wire                               next_dw0_valid_sent;
  wire                               next_dw1_valid_sent;
  wire                               dw0_en;
  wire                               dw1_en;
  wire                               next_dw_oldest;
  wire                               next_scu_acp_dw_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_db_valid;
  wire [NUM_REQBUFS-1:0]             reqbuf_db_arb;
  wire [NUM_REQBUFS-1:0]             reqbuf_db_ready;
  wire [1:0]                         reqbuf_db_resp [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_db_resp_muxed;
  wire [4:0]                         reqbuf_db_id_muxed;
  wire                               next_scu_acp_db_valid;
  wire                               db_en;
  wire [1:0]                         next_scu_acp_db_resp;
  wire [4:0]                         next_scu_acp_db_id;
  wire                               next_db_skid_valid;
  wire                               db_skid_en;
  wire                               next_addr_rr;
  wire                               acpslv_tagctl_valid_tc0;
  wire [3:0]                         acpslv_tagctl_pass_tc0;
  wire [40:0]                        acpslv_tagctl_addr1_tc0;
  wire [MAX_L2DBS-1:0]               acpslv_l2db_release;
  wire [15:0]                        acpslv_force_miss_tc1;
  wire [15:0]                        acpslv_l2_way_used_tc1;
  wire [15:0]                        acpslv_l2_way_used_vc1;

  wire                               acpslv_hz_tc1;
  wire                               acpslv_hz_tc3;
  wire                               acp_addr_valid;
  wire [4:0]                         acp_addr_id;
  wire                               acp_addr_read;
  wire                               acp_addr_alloc;
  wire [40:0]                        acp_addr_addr;
  wire                               acp_addr_len;
  wire [1:0]                         acp_addr_domain;
  wire                               acp_addr_slverr;
  wire                               dr_req_available;
  wire                               ar_slverr;
  wire                               aw_slverr;
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_valid;
  wire [NUM_REQBUFS-1:0]             next_reqbuf_compack_ready;
  wire                               reqbuf_compack_ready_en;
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_arb;
  wire [6:0]                         reqbuf_compack_tgtid [NUM_REQBUFS-1:0];
  wire [7:0]                         reqbuf_compack_txnid [NUM_REQBUFS-1:0];

  // Tie off for configurable logic
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  // Avoid clocking the request buffers and response channel if they are all idle.
  assign acpslv_int_active = (|reqbuf_busy |
                              scu_acp_dr_valid | dr_skid_valid |
                              scu_acp_db_valid | db_skid_valid |
                              acp_ar_valid | acp_aw_valid |
                              acp_dw0_valid | acp_dw1_valid);

  assign next_acp_int_clk_enable = (acpslv_int_active |
                                    (acp_int_clk_enable & acp_ext_clk_enable) |
                                    (scu_acp_dw_ready &
                                     ~(clean_aclkens_i & ~next_scu_acp_dw_ready)));

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    acp_int_clk_enable <= 1'b1;
  end else begin
    acp_int_clk_enable <= next_acp_int_clk_enable;
  end

  // External signals must use a separate register as we can only look at
  // them in aclkens cycles.
  assign next_acp_ext_clk_enable = (ext_acp_arvalid_i |
                                    ext_acp_awvalid_i |
                                    ext_acp_wvalid_i);

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    acp_ext_clk_enable <= 1'b1;
  end else if (clean_aclkens_i) begin
    acp_ext_clk_enable <= next_acp_ext_clk_enable;
  end

  assign acp_clk_enable = acp_int_clk_enable | acp_ext_clk_enable;

  // This gate uses CLKIN rather than clk because clk may not be active on the
  // first cycle of a new request.
  ca53_cell_inter_clkgate u_inter_clkgate_reqbufs (
    .clk_i         (CLKIN),
    .clk_enable_i  (acp_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_acp));

  // If the system is telling us that ACP is inactive, and there are no
  // requests in progress, then deassert all the ready signals.
  assign acpslv_inact = acp_ainact_rs_i & ~acp_int_clk_enable;

  assign next_ext_acp_clk_enable = scu_acp_ar_ready | scu_acp_aw_ready | scu_acp_dw_ready | ~acpslv_inact | acpslv_int_active;

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    ext_acp_clk_enable <= 1'b1;
  end else if (clean_aclkens_i) begin
    ext_acp_clk_enable <= next_ext_acp_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_ext_acp (
    .clk_i         (CLKIN),
    .clk_enable_i  (ext_acp_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ext_acp));

  // The main SCU clock gate must be enabled if there is anything in or entering
  // the request buffers. Responses can also remain after the reqbuf has completed.
  assign acpslv_active_o = acpslv_int_active | (acp_ext_clk_enable & ~acp_ainact_rs_i);

  // Reregister some config signals locally to help timing.
  always @(posedge clk_acp)
  if (leaving_reset_i) begin
    acpslv_broadcastinner <= config_broadcastinner_i;
    acpslv_broadcastouter <= config_broadcastouter_i;
    acpslv_l1_dc_size     <= config_l1_dc_size_i;
  end

  if (L2_CACHE) begin : g_l2cc

    always @(posedge clk_acp)
    if (leaving_reset_i) begin
      acpslv_l2_size <= config_l2_size_i;
    end

  end else begin : g_n_l2cc

    always @*
      acpslv_l2_size = {4{zero}};
  
  end

  //----------------------------------------------------------------------------
  //  Read address channel
  //----------------------------------------------------------------------------

  assign ar_valid_en = clean_aclkens_i & scu_acp_ar_ready;

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    acp_ar_valid <= 1'b0;
  end else if (ar_valid_en) begin
    acp_ar_valid <= ext_acp_arvalid_i;
  end

  assign next_ar_valid_sent = (ar_valid_sent | (acp_ar_valid & ar_ready)) & ~ar_valid_en;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    ar_valid_sent <= 1'b0;
  end else begin
    ar_valid_sent <= next_ar_valid_sent;
  end

  assign ar_valid = acp_ar_valid & ~ar_valid_sent;

  assign ar_en = clean_aclkens_i & ext_acp_arvalid_i & scu_acp_ar_ready;

  always @(posedge clk_ext_acp)
  if (ar_en) begin
    ar_addr  <= ext_acp_araddr_i;
    ar_id    <= ext_acp_arid_i;
    ar_len   <= ext_acp_arlen_i;
    ar_cache <= ext_acp_arcache_i;
    ar_user  <= ext_acp_aruser_i;
    ar_prot  <= ext_acp_arprot_i[1];
  end


  // Any access that is not WB cacheable, and is not 1 or 4 beats, or is system domain, will get a slverr.
  assign ar_slverr = ~(|ar_cache[3:2] & (&ar_cache[1:0]) &
                       ~|ar_len[7:2] & ~^ar_len[1:0] &
                       ~&ar_user &
                       ~|ar_addr[3:0] &
                       (~|ar_len[1:0] | ~|ar_addr[5:4]));

  // The current ar request can be moved out of the interface registers if
  // there is a reqbuf to accept it, and that reqbuf isn't being used by an aw request.
  assign ar_ready = ~&reqbuf_busy & (~addr_rr | ~aw_valid) & ~|reqbuf_id_hazard;

  assign next_scu_acp_ar_ready = ~(ar_valid & ~ar_ready) & ~(ar_valid_en & ext_acp_arvalid_i) & ~acpslv_inact;

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    scu_acp_ar_ready <= 1'b0;
  end else if (clean_aclkens_i) begin
    scu_acp_ar_ready <= next_scu_acp_ar_ready;
  end

  assign scu_acp_arready_o = scu_acp_ar_ready;


  //----------------------------------------------------------------------------
  //  Read data channel
  //----------------------------------------------------------------------------


  assign dr_req = {l2db10_slv_valid_i & (l2db10_slv_id_i[5:3] == 3'b100),
                   l2db9_slv_valid_i  & (l2db9_slv_id_i[5:3]  == 3'b100),
                   l2db8_slv_valid_i  & (l2db8_slv_id_i[5:3]  == 3'b100),
                   l2db7_slv_valid_i  & (l2db7_slv_id_i[5:3]  == 3'b100),
                   l2db6_slv_valid_i  & (l2db6_slv_id_i[5:3]  == 3'b100),
                   l2db5_slv_valid_i  & (l2db5_slv_id_i[5:3]  == 3'b100),
                   l2db4_slv_valid_i  & (l2db4_slv_id_i[5:3]  == 3'b100),
                   l2db3_slv_valid_i  & (l2db3_slv_id_i[5:3]  == 3'b100),
                   l2db2_slv_valid_i  & (l2db2_slv_id_i[5:3]  == 3'b100),
                   l2db1_slv_valid_i  & (l2db1_slv_id_i[5:3]  == 3'b100),
                   l2db0_slv_valid_i  & (l2db0_slv_id_i[5:3]  == 3'b100),
                   reqbuf_dr_valid,
                   master_acpslv_dr_valid_i};

  assign dr_arb_req = |dr_req;

  // Select between dr requests on a round robin basis.
  assign dr_arb_en = dr_arb_req & clean_aclkens_i & ~dr_skid_valid;

  ca53_rr_reg_arb #(.WIDTH(NUM_L2DBS + NUM_REQBUFS + 1)) u_dr_arb (
    .clk        (clk_acp),
    .reset_n    (reset_n),
    .enable_i   (dr_arb_en),
    .requests_i (dr_req[NUM_L2DBS + NUM_REQBUFS:0]),
    .arb_o      (dr_arb[NUM_L2DBS + NUM_REQBUFS:0])
  );

  for (i = NUM_L2DBS + NUM_REQBUFS + 1; i < MAX_L2DBS + NUM_REQBUFS + 1; i = i + 1) begin : g_dr_arb
    assign dr_arb[i] = 1'b0;
  end

  // Identify which reqbuf the L2DB or master response relates to.
  assign l2db_slv_id = (({4{dr_arb[15]}} & (4'h1 << l2db10_slv_id_i[1:0])) |
                        ({4{dr_arb[14]}} & (4'h1 << l2db9_slv_id_i[1:0]))  |
                        ({4{dr_arb[13]}} & (4'h1 << l2db8_slv_id_i[1:0]))  |
                        ({4{dr_arb[12]}} & (4'h1 << l2db7_slv_id_i[1:0]))  |
                        ({4{dr_arb[11]}} & (4'h1 << l2db6_slv_id_i[1:0]))  |
                        ({4{dr_arb[10]}} & (4'h1 << l2db5_slv_id_i[1:0]))  |
                        ({4{dr_arb[9]}}  & (4'h1 << l2db4_slv_id_i[1:0]))  |
                        ({4{dr_arb[8]}}  & (4'h1 << l2db3_slv_id_i[1:0]))  |
                        ({4{dr_arb[7]}}  & (4'h1 << l2db2_slv_id_i[1:0]))  |
                        ({4{dr_arb[6]}}  & (4'h1 << l2db1_slv_id_i[1:0]))  |
                        ({4{dr_arb[5]}}  & (4'h1 << l2db0_slv_id_i[1:0])));

  assign dr_slv_id = (l2db_slv_id |
                      ({4{dr_arb[4]}}  & (4'b1000)) |
                      ({4{dr_arb[3]}}  & (4'b0100)) |
                      ({4{dr_arb[2]}}  & (4'b0010)) |
                      ({4{dr_arb[1]}}  & (4'b0001)) |
                      ({4{dr_arb[0]}}  & (4'h1 << master_acpslv_dr_id_i[1:0])));

  // Find the original BIU id for the request as stored in the controlling reqbuf.
  assign dr_id = (({5{dr_slv_id[3]}} & reqbuf_acp_id[3]) |
                  ({5{dr_slv_id[2]}} & reqbuf_acp_id[2]) |
                  ({5{dr_slv_id[1]}} & reqbuf_acp_id[1]) |
                  ({5{dr_slv_id[0]}} & reqbuf_acp_id[0]));


  assign dr_resp = (({2{(dr_arb[15] & l2db10_slv_err_i) |
                        (dr_arb[14] & l2db9_slv_err_i)  |
                        (dr_arb[13] & l2db8_slv_err_i)  |
                        (dr_arb[12] & l2db7_slv_err_i)  |
                        (dr_arb[11] & l2db6_slv_err_i)  |
                        (dr_arb[10] & l2db5_slv_err_i)  |
                        (dr_arb[9]  & l2db4_slv_err_i)  |
                        (dr_arb[8]  & l2db3_slv_err_i)  |
                        (dr_arb[7]  & l2db2_slv_err_i)  |
                        (dr_arb[6]  & l2db1_slv_err_i)  |
                        (dr_arb[5]  & l2db0_slv_err_i)  |
                        (|dr_arb[4:1])}} & `CA53_ACE_RESP_SLVERR) |
                    ({2{l2db_slv_id[3]}} & reqbuf_db_resp[3]) |
                    ({2{l2db_slv_id[2]}} & reqbuf_db_resp[2]) |
                    ({2{l2db_slv_id[1]}} & reqbuf_db_resp[1]) |
                    ({2{l2db_slv_id[0]}} & reqbuf_db_resp[0]) |
                    ({2{dr_arb[0]}} & master_dr_resp_i[1:0]));

  assign dr_data = (({128{dr_arb[15]}} & l2db10_slv_data_i) |
                    ({128{dr_arb[14]}} & l2db9_slv_data_i)  |
                    ({128{dr_arb[13]}} & l2db8_slv_data_i)  |
                    ({128{dr_arb[12]}} & l2db7_slv_data_i)  |
                    ({128{dr_arb[11]}} & l2db6_slv_data_i)  |
                    ({128{dr_arb[10]}} & l2db5_slv_data_i)  |
                    ({128{dr_arb[9]}}  & l2db4_slv_data_i)  |
                    ({128{dr_arb[8]}}  & l2db3_slv_data_i)  |
                    ({128{dr_arb[7]}}  & l2db2_slv_data_i)  |
                    ({128{dr_arb[6]}}  & l2db1_slv_data_i)  |
                    ({128{dr_arb[5]}}  & l2db0_slv_data_i)  |
                    ({128{dr_arb[0]}}  & master_dr_data_i));

  assign master_dr_last = ((dr_slv_id[3] & ~|reqbuf_len[3]) |
                           (dr_slv_id[2] & ~|reqbuf_len[2]) |
                           (dr_slv_id[1] & ~|reqbuf_len[1]) |
                           (dr_slv_id[0] & ~|reqbuf_len[0]) |
                           (master_dr_chunk_i == 2'b11));

  assign dr_last = ((dr_arb[15] & l2db10_slv_last_i) |
                    (dr_arb[14] & l2db9_slv_last_i)  |
                    (dr_arb[13] & l2db8_slv_last_i)  |
                    (dr_arb[12] & l2db7_slv_last_i)  |
                    (dr_arb[11] & l2db6_slv_last_i)  |
                    (dr_arb[10] & l2db5_slv_last_i)  |
                    (dr_arb[9]  & l2db4_slv_last_i)  |
                    (dr_arb[8]  & l2db3_slv_last_i)  |
                    (dr_arb[7]  & l2db2_slv_last_i)  |
                    (dr_arb[6]  & l2db1_slv_last_i)  |
                    (dr_arb[5]  & l2db0_slv_last_i)  |
                    (dr_arb[4]  & reqbuf_dr_last[3]) |
                    (dr_arb[3]  & reqbuf_dr_last[2]) |
                    (dr_arb[2]  & reqbuf_dr_last[1]) |
                    (dr_arb[1]  & reqbuf_dr_last[0]) |
                    (dr_arb[0]  & master_dr_last));

  assign dr_ready = dr_arb & {(MAX_L2DBS + NUM_REQBUFS + 1){clean_aclkens_i & ~dr_skid_valid}};

  assign acpslv_l2db10_ready_o  = dr_ready[15];
  assign acpslv_l2db9_ready_o   = dr_ready[14];
  assign acpslv_l2db8_ready_o   = dr_ready[13];
  assign acpslv_l2db7_ready_o   = dr_ready[12];
  assign acpslv_l2db6_ready_o   = dr_ready[11];
  assign acpslv_l2db5_ready_o   = dr_ready[10];
  assign acpslv_l2db4_ready_o   = dr_ready[9];
  assign acpslv_l2db3_ready_o   = dr_ready[8];
  assign acpslv_l2db2_ready_o   = dr_ready[7];
  assign acpslv_l2db1_ready_o   = dr_ready[6];
  assign acpslv_l2db0_ready_o   = dr_ready[5];
  assign acpslv_master_dr_ready = dr_ready[0];

  assign acpslv_master_dr_ready_o = acpslv_master_dr_ready;

  assign reqbuf_dr_ready = dr_ready[4:1];

  assign acpslv_master_sactive_o = |reqbuf_busy;

  // Suppressed responses from the master can always be accepted, even if the
  // response is not arbitrated this cycle.
  assign dr_req_available = dr_arb_req & ~(dr_arb[0] & |reqbuf_suppress_dr & master_early_dr_same_i);

  // The skid buffer is only used when aclkens is high, to avoid skidding the
  // data on every access if aclkens is not 1:1
  assign next_dr_skid_valid = (dr_req_available | dr_skid_valid) & scu_acp_dr_valid & ~ext_acp_rready_i;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    dr_skid_valid <= 1'b0;
  end else if (clean_aclkens_i) begin
    dr_skid_valid <= next_dr_skid_valid;
  end

  assign dr_skid_en = dr_req_available & ~dr_skid_valid & clean_aclkens_i & scu_acp_dr_valid & ~ext_acp_rready_i;

  always @(posedge clk_acp)
  if (dr_skid_en) begin
    dr_skid_id   <= dr_id;
    dr_skid_resp <= dr_resp;
    dr_skid_data <= dr_data;
    dr_skid_last <= dr_last;
  end

  assign next_scu_acp_dr_valid = (dr_req_available | dr_skid_valid) | (scu_acp_dr_valid & ~ext_acp_rready_i);

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    scu_acp_dr_valid <= 1'b0;
  end else if (clean_aclkens_i) begin
    scu_acp_dr_valid <= next_scu_acp_dr_valid;
  end

  assign next_scu_acp_dr_id   = dr_skid_valid ? dr_skid_id   : dr_id;
  assign next_scu_acp_dr_resp = dr_skid_valid ? dr_skid_resp : dr_resp;
  assign next_scu_acp_dr_data = dr_skid_valid ? dr_skid_data : dr_data;
  assign next_scu_acp_dr_last = dr_skid_valid ? dr_skid_last : dr_last;

  assign dr_en = clean_aclkens_i & (dr_req_available | dr_skid_valid) & (ext_acp_rready_i | ~scu_acp_dr_valid);

  always @(posedge clk_acp)
  if (dr_en) begin
    scu_acp_dr_id   <= next_scu_acp_dr_id;
    scu_acp_dr_resp <= next_scu_acp_dr_resp;
    scu_acp_dr_data <= next_scu_acp_dr_data;
    scu_acp_dr_last <= next_scu_acp_dr_last;
  end

  assign scu_acp_rvalid_o = scu_acp_dr_valid;
  assign scu_acp_rid_o    = scu_acp_dr_id;
  assign scu_acp_rresp_o  = scu_acp_dr_resp;
  assign scu_acp_rdata_o  = scu_acp_dr_data;
  assign scu_acp_rlast_o  = scu_acp_dr_last;

  //----------------------------------------------------------------------------
  //  Write address channel
  //----------------------------------------------------------------------------

  assign aw_valid_en = clean_aclkens_i & scu_acp_aw_ready;

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    acp_aw_valid <= 1'b0;
  end else if (aw_valid_en) begin
    acp_aw_valid <= ext_acp_awvalid_i;
  end

  assign next_aw_valid_sent = (aw_valid_sent | (acp_aw_valid & aw_ready)) & ~aw_valid_en;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    aw_valid_sent <= 1'b0;
  end else begin
    aw_valid_sent <= next_aw_valid_sent;
  end

  assign aw_valid = acp_aw_valid & ~aw_valid_sent;

  assign aw_en = clean_aclkens_i & ext_acp_awvalid_i & scu_acp_aw_ready;

  always @(posedge clk_ext_acp)
  if (aw_en) begin
    aw_id    <= ext_acp_awid_i;
    aw_cache <= ext_acp_awcache_i;
    aw_addr  <= ext_acp_awaddr_i;
    aw_len   <= ext_acp_awlen_i;
    aw_prot  <= ext_acp_awprot_i[1];
    aw_user  <= ext_acp_awuser_i;
  end

  // Any access that is not WB cacheable, and is not 1 or 4 beats, will get a slverr.
  assign aw_slverr = ~(|aw_cache[3:2] & (&aw_cache[1:0]) &
                       ~|aw_len[7:2] & ~^aw_len[1:0] &
                       ~&aw_user &
                       ~|aw_addr[3:0] &
                       (~|aw_len[1:0] | ~|aw_addr[5:4]));

  // The current aw request can be moved out of the interface registers if
  // there is a reqbuf to accept it, and that reqbuf isn't being used by an ar request.
  assign aw_ready = ~&reqbuf_busy & (addr_rr | ~ar_valid) & ~|reqbuf_id_hazard;

  assign next_scu_acp_aw_ready = ~(aw_valid & ~aw_ready) & ~(aw_valid_en & ext_acp_awvalid_i) & ~acpslv_inact;

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    scu_acp_aw_ready <= 1'b0;
  end else if (clean_aclkens_i) begin
    scu_acp_aw_ready <= next_scu_acp_aw_ready;
  end

  assign scu_acp_awready_o = scu_acp_aw_ready;

  //----------------------------------------------------------------------------
  //  Write data channel
  //----------------------------------------------------------------------------

  // Select the oldest of the two buffers, unless that is already valid.
  assign dw_sel = dw_oldest ^ ((dw0_valid & ~dw0_valid_sent) ^ (dw1_valid & ~dw1_valid_sent));

  assign next_acp_dw0_valid = (ext_acp_wvalid_i & scu_acp_dw_ready & ~dw_sel) | (dw0_valid & ~dw0_valid_sent & ~(dw_ready & ~dw_oldest));
  assign next_acp_dw1_valid = (ext_acp_wvalid_i & scu_acp_dw_ready &  dw_sel) | (dw1_valid & ~dw1_valid_sent & ~(dw_ready &  dw_oldest));

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    acp_dw0_valid <= 1'b0;
    acp_dw1_valid <= 1'b0;
  end else if (clean_aclkens_i) begin
    acp_dw0_valid <= next_acp_dw0_valid;
    acp_dw1_valid <= next_acp_dw1_valid;
  end

  assign next_dw0_valid_sent = (dw0_valid_sent | (acp_dw0_valid & dw_ready & ~dw_oldest)) & ~clean_aclkens_i;
  assign next_dw1_valid_sent = (dw1_valid_sent | (acp_dw1_valid & dw_ready &  dw_oldest)) & ~clean_aclkens_i;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    dw0_valid_sent <= 1'b0;
    dw1_valid_sent <= 1'b0;
  end else begin
    dw0_valid_sent <= next_dw0_valid_sent;
    dw1_valid_sent <= next_dw1_valid_sent;
  end

  assign dw0_valid = acp_dw0_valid & ~dw0_valid_sent;
  assign dw1_valid = acp_dw1_valid & ~dw1_valid_sent;

  assign dw_valid = dw0_valid | dw1_valid;

  assign dw0_en = clean_aclkens_i & ext_acp_wvalid_i & scu_acp_dw_ready & ~dw_sel;
  assign dw1_en = clean_aclkens_i & ext_acp_wvalid_i & scu_acp_dw_ready &  dw_sel;

  always @(posedge clk_acp)
  if (dw0_en) begin
    dw0_data <= ext_acp_wdata_i;
    dw0_strb <= ext_acp_wstrb_i;
    dw0_last <= ext_acp_wlast_i;
  end

  always @(posedge clk_acp)
  if (dw1_en) begin
    dw1_data <= ext_acp_wdata_i;
    dw1_strb <= ext_acp_wstrb_i;
    dw1_last <= ext_acp_wlast_i;
  end

  // The current aw request can be moved out of the interface registers if
  // there is a reqbuf allocated to accept it.
  assign dw_ready = |reqbuf_wait_data;

  assign next_dw_oldest = dw_oldest ^ (dw_valid & dw_ready);

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    dw_oldest <= 1'b0;
  end else begin
    dw_oldest <= next_dw_oldest;
  end

  // The write data always belongs to the oldest request buffer that is still
  // waiting for write data.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_dw_arb
    assign reqbuf_dw_arb[i] = reqbuf_wait_data[i] & ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] & reqbuf_wait_data);
  end

  assign acpslv_l2dbs_dw_valid_o = dw_valid & dw_ready;

  assign acpslv_l2dbs_dw_id_o    = (({4{reqbuf_dw_arb[3]}} & reqbuf_l2db_primary_id[3]) |
                                    ({4{reqbuf_dw_arb[2]}} & reqbuf_l2db_primary_id[2]) |
                                    ({4{reqbuf_dw_arb[1]}} & reqbuf_l2db_primary_id[1]) |
                                    ({4{reqbuf_dw_arb[0]}} & reqbuf_l2db_primary_id[0]));

  assign acpslv_l2dbs_dw_chunk_o = (({2{reqbuf_dw_arb[3]}} & reqbuf_wdata_chunk[3]) |
                                    ({2{reqbuf_dw_arb[2]}} & reqbuf_wdata_chunk[2]) |
                                    ({2{reqbuf_dw_arb[1]}} & reqbuf_wdata_chunk[1]) |
                                    ({2{reqbuf_dw_arb[0]}} & reqbuf_wdata_chunk[0]));

  assign acpslv_l2dbs_dw_data_o  = dw_oldest ? dw1_data : dw0_data;
  assign acpslv_l2dbs_dw_strb_o  = dw_oldest ? dw1_strb : dw0_strb;
  assign acpslv_wdata_last       = dw_oldest ? dw1_last : dw0_last;
  assign acpslv_l2dbs_dw_last_o  = acpslv_wdata_last;

  assign acpslv_wdata_valid = reqbuf_dw_arb & {NUM_REQBUFS{dw_valid}};

  // If the acp_clk is going to be gated, then deassert dw_ready so that we
  // have time to wake up before accepting the data.
  assign next_scu_acp_dw_ready = (((~dw0_valid & ~dw1_valid) |
                                   ((~dw0_valid | ~dw1_valid) & (dw_ready | ~ext_acp_wvalid_i)) |
                                   (dw_ready & ~ext_acp_wvalid_i)) &
                                  ~acpslv_inact &
                                  (acp_ext_clk_enable | acpslv_int_active | ext_acp_wvalid_i));

  always @(posedge clk_ext_acp or negedge reset_n)
  if (~reset_n) begin
    scu_acp_dw_ready <= 1'b0;
  end else if (clean_aclkens_i) begin
    scu_acp_dw_ready <= next_scu_acp_dw_ready;
  end

  assign scu_acp_wready_o = scu_acp_dw_ready;

  //----------------------------------------------------------------------------
  //  Write response channel
  //----------------------------------------------------------------------------

  // Response arbitration. The oldest reqbuf wanting to make a response is
  // always granted.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_db_arb
    assign reqbuf_db_arb[i] = reqbuf_db_valid[i] & ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] & reqbuf_db_valid);
  end

  assign reqbuf_db_ready = reqbuf_db_arb & {NUM_REQBUFS{~db_skid_valid}};

  assign reqbuf_db_resp_muxed = (({2{reqbuf_db_arb[3]}} & reqbuf_db_resp[3]) |
                                 ({2{reqbuf_db_arb[2]}} & reqbuf_db_resp[2]) |
                                 ({2{reqbuf_db_arb[1]}} & reqbuf_db_resp[1]) |
                                 ({2{reqbuf_db_arb[0]}} & reqbuf_db_resp[0]));

  assign reqbuf_db_id_muxed = (({5{reqbuf_db_arb[3]}} & reqbuf_acp_id[3]) |
                               ({5{reqbuf_db_arb[2]}} & reqbuf_acp_id[2]) |
                               ({5{reqbuf_db_arb[1]}} & reqbuf_acp_id[1]) |
                               ({5{reqbuf_db_arb[0]}} & reqbuf_acp_id[0]));

  assign next_scu_acp_db_valid = |reqbuf_db_valid | db_skid_valid | (scu_acp_db_valid & ~ext_acp_bready_i);

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    scu_acp_db_valid <= 1'b0;
  end else if (clean_aclkens_i) begin
    scu_acp_db_valid <= next_scu_acp_db_valid;
  end

  assign db_en = (clean_aclkens_i &
                  (ext_acp_bready_i | ~scu_acp_db_valid) &
                  (|reqbuf_db_valid | db_skid_valid));

  assign next_scu_acp_db_resp = db_skid_valid ? db_skid_resp : reqbuf_db_resp_muxed;

  assign next_scu_acp_db_id = db_skid_valid ? db_skid_id : reqbuf_db_id_muxed;

  always @(posedge clk_acp)
  if (db_en) begin
    scu_acp_db_resp <= next_scu_acp_db_resp;
    scu_acp_db_id   <= next_scu_acp_db_id;
  end

  assign scu_acp_bvalid_o = scu_acp_db_valid;
  assign scu_acp_bresp_o  = scu_acp_db_resp;
  assign scu_acp_bid_o    = scu_acp_db_id;

  // The skid buffer holds one response if the external interface cannot accept
  // it, in order to decouple the timing on ext_acp_bready_i.
  assign next_db_skid_valid = (|reqbuf_db_valid | db_skid_valid) & ~db_en;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    db_skid_valid <= 1'b0;
  end else begin
    db_skid_valid <= next_db_skid_valid;
  end

  assign db_skid_en = (|reqbuf_db_valid & ~db_skid_valid) & ~db_en;

  always @(posedge clk_acp)
  if (db_skid_en) begin
    db_skid_resp <= reqbuf_db_resp_muxed;
    db_skid_id   <= reqbuf_db_id_muxed;
  end

  //----------------------------------------------------------------------------
  //  Request buffer control
  //----------------------------------------------------------------------------

  // If there is both a read and write address request want to allocate a
  // request buffer then select based on a round robin counter.
  assign next_addr_rr = addr_rr ^ (ar_valid & aw_valid & ~&reqbuf_busy);

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    addr_rr <= 1'b0;
  end else begin
    addr_rr <= next_addr_rr;
  end

  assign acp_addr_valid = (ar_valid | aw_valid) & ~|reqbuf_id_hazard;

  assign acp_addr_read = ar_valid & ~(aw_valid & addr_rr);

  assign acp_addr_id     = acp_addr_read ? ar_id  : aw_id;
  assign acp_addr_len    = acp_addr_read ? ar_len[0] : aw_len[0];
  assign acp_addr_addr   = acp_addr_read ? {ar_prot, ar_addr[39:12], ar_slverr ? ar_len : ar_addr[11:4], 4'b0000} :
                                           {aw_prot, aw_addr[39:4], 4'b0000};
  assign acp_addr_alloc  = acp_addr_read ? ar_cache[2] : aw_cache[3];
  assign acp_addr_domain = acp_addr_read ? ar_user : aw_user;
  assign acp_addr_slverr = acp_addr_read ? ar_slverr : aw_slverr;

  // Select the lowest unused reqbuf to allocate for a new request.
  assign reqbuf_alloc[0] = acp_addr_valid & ~reqbuf_busy[0];
  assign reqbuf_alloc[1] = acp_addr_valid & ~reqbuf_busy[1] &   reqbuf_busy[0];
  assign reqbuf_alloc[2] = acp_addr_valid & ~reqbuf_busy[2] & (&reqbuf_busy[1:0]);
  assign reqbuf_alloc[3] = acp_addr_valid & ~reqbuf_busy[3] & (&reqbuf_busy[2:0]);

  assign reqbuf_alloc_enc = {|reqbuf_alloc[3:2],
                             |{reqbuf_alloc[3], reqbuf_alloc[1]}};

  // Keep track of the order in which reqbufs were allocated.
  ca53scu_buf_age #(.NUM_BUFS(NUM_REQBUFS)) u_reqbuf_age (
    .clk         (clk_acp),
    .reset_n     (reset_n),
    .buf_alloc_i (reqbuf_alloc[NUM_REQBUFS-1:0]),
    .buf_older_o (reqbuf_older_pkd)
  );

  // Tagctl request arbitration. The oldest serialised reqbuf making a request,
  // and is guaranteed to progress eventually, is always granted. Otherwise the
  // oldest serialised request that may not be able to progress (for example due
  // to it needing to make an external read request) is granted. If no
  // serialised reqbuf is requesting, then the oldest non-serialised reqbuf is
  // granted. If no reqbuf is requesting, then any new request from the BIU is
  // granted priority.
  // This must ensure that a serialised reqbuf cannot continually be arbitrated
  // behind an older unserialised reqbuf, because the unserialised one might
  // hazard and flush both requests, and the cause of the hazard could be
  // waiting for the serialised reqbuf to complete.
  assign acpslv_tagctl_early_valid_tc0 = |reqbuf_tagctl_valid_tc0;

  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_tagctl_prearb
    assign tagctl_prearb[i] = (reqbuf_tagctl_prearb_req[i] &
                               ~tagctl_prearb_mask[i] &
                               ~tagctl_prearb_tc0[i] &
                               ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                  reqbuf_tagctl_prearb_req &
                                  ~tagctl_prearb_mask &
                                  ~tagctl_prearb_tc0));
  end

  // If the highest priority request does not get arbitrated in this cycle,
  // then record that and use it in the follow cycle to mask out all lower
  // priority requests.
  assign next_tagctl_prearb_mask = (({NUM_REQBUFS{|(reqbuf_tagctl_prearb_req &
                                                    reqbuf_tagctl_prearb_pri1 &
                                                    ~tagctl_prearb_tc0 &
                                                    ~tagctl_prearb)}} &
                                     ~(reqbuf_tagctl_prearb_req & reqbuf_tagctl_prearb_pri1)) |
                                    ({NUM_REQBUFS{|(reqbuf_tagctl_prearb_req &
                                                    reqbuf_tagctl_prearb_pri2 &
                                                    ~tagctl_prearb_tc0 &
                                                    ~tagctl_prearb)}} &
                                     ~(reqbuf_tagctl_prearb_req & (reqbuf_tagctl_prearb_pri1 |
                                                                   reqbuf_tagctl_prearb_pri2))));

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    tagctl_prearb_mask <= {NUM_REQBUFS{1'b0}};
  end else if (tagctl_prearb_en) begin
    tagctl_prearb_mask <= next_tagctl_prearb_mask;
  end

  assign reqbuf_tagctl_prearb_primary = |tagctl_prearb ? tagctl_prearb : (tagctl_prearb_tc0 &  {NUM_REQBUFS{tagctl_prearb_primary}});
  assign reqbuf_tagctl_prearb_victim  = |tagctl_prearb ? tagctl_prearb : (tagctl_prearb_tc0 & ~{NUM_REQBUFS{tagctl_prearb_primary}});

  assign tagctl_prearb_en = (|(tagctl_prearb_tc0 & ((reqbuf_update_primary_pass & {NUM_REQBUFS{tagctl_prearb_primary}}) |
                                                    (reqbuf_update_victim_pass & ~{NUM_REQBUFS{tagctl_prearb_primary}}) |
                                                    (reqbuf_tagctl_prearb_req &
                                                     (reqbuf_tagctl_primary_tc0 ^ {NUM_REQBUFS{tagctl_prearb_primary}})))) |
                             (|tagctl_prearb));

  // The prearb register keeps a cache of the last prearbitrated reqbuf. If that
  // request is flushed while in tagctl then we must not let a non-serialised
  // request get rearbitrated for tagctl before the serialised one (because the
  // unserialised request could be the one causing the flush).
  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    tagctl_prearb_tc0 <= {NUM_REQBUFS{1'b0}};
  end else if (tagctl_prearb_en) begin
    tagctl_prearb_tc0 <= tagctl_prearb;
  end

  assign next_tagctl_prearb_primary = |(tagctl_prearb & reqbuf_tagctl_primary_tc0);

  always @(posedge clk_acp)
  if (tagctl_prearb_en) begin
    tagctl_prearb_primary <= next_tagctl_prearb_primary;
  end

  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_tagctl_arb
    assign tagctl_sel_prearb_tc0[i] = (reqbuf_tagctl_valid_tc0[i] &
                                       tagctl_prearb_tc0[i] &
                                       (reqbuf_tagctl_primary_tc0[i] == tagctl_prearb_primary));

    assign tagctl_arb_tc0[i] = (tagctl_sel_prearb_tc0[i] |
                                (reqbuf_tagctl_valid_tc0[i] &
                                 ~|tagctl_sel_prearb_tc0 &
                                 ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                    reqbuf_tagctl_valid_tc0)));
  end

  assign tagctl_arb_tc0[NUM_REQBUFS] = (~acpslv_tagctl_early_valid_tc0 &
                                        ~acpslv_noncoh_only);

  assign acpslv_tagctl_valid_tc0 = (|reqbuf_tagctl_valid_tc0 |
                                    (acp_addr_valid & ~(acp_addr_read & ar_slverr) &
                                     ~&reqbuf_busy & ~acpslv_noncoh_only));

  assign acpslv_tagctl_valid_tc0_o = acpslv_tagctl_valid_tc0;
  assign acpslv_tagctl_early_valid_tc0_o = acpslv_tagctl_early_valid_tc0;
  assign acpslv_tagctl_spec_valid_tc0_o = (ar_valid | aw_valid) & ~&reqbuf_busy;
  assign acpslv_tagctl_active_tc0_o = acp_ar_valid | acp_aw_valid;

  assign acpslv_tagctl_reqbufid_tc0_o = (({3{tagctl_arb_tc0[4]}} & {1'b1, reqbuf_alloc_enc}) |
                                         ({3{tagctl_arb_tc0[3]}} & 3'b111) |
                                         ({3{tagctl_arb_tc0[2]}} & 3'b110) |
                                         ({3{tagctl_arb_tc0[1]}} & 3'b101) |
                                         ({3{tagctl_arb_tc0[0]}} & 3'b100));

  assign acpslv_tagctl_pass_tc0 = (({4{tagctl_arb_tc0[4]}} & {3'b000, ~acp_addr_read}) |
                                   ({4{tagctl_arb_tc0[3]}} & reqbuf_tagctl_pass_tc0[3]) |
                                   ({4{tagctl_arb_tc0[2]}} & reqbuf_tagctl_pass_tc0[2]) |
                                   ({4{tagctl_arb_tc0[1]}} & reqbuf_tagctl_pass_tc0[1]) |
                                   ({4{tagctl_arb_tc0[0]}} & reqbuf_tagctl_pass_tc0[0]));

  assign acpslv_tagctl_pass_tc0_o = acpslv_tagctl_pass_tc0;

  assign acpslv_tagctl_addr1_tc0 = (({41{tagctl_arb_tc0[4]}} & acp_addr_addr) |
                                    ({41{tagctl_arb_tc0[3]}} & reqbuf_tagctl_addr1_tc0[3]) |
                                    ({41{tagctl_arb_tc0[2]}} & reqbuf_tagctl_addr1_tc0[2]) |
                                    ({41{tagctl_arb_tc0[1]}} & reqbuf_tagctl_addr1_tc0[1]) |
                                    ({41{tagctl_arb_tc0[0]}} & reqbuf_tagctl_addr1_tc0[0]));

  assign acpslv_tagctl_addr1_tc0_o = acpslv_tagctl_addr1_tc0;

  assign acpslv_tagctl_wr_state_tc0_o = (({17{tagctl_arb_tc0[3]}} & reqbuf_tagctl_wr_state_tc0[3]) |
                                         ({17{tagctl_arb_tc0[2]}} & reqbuf_tagctl_wr_state_tc0[2]) |
                                         ({17{tagctl_arb_tc0[1]}} & reqbuf_tagctl_wr_state_tc0[1]) |
                                         ({17{tagctl_arb_tc0[0]}} & reqbuf_tagctl_wr_state_tc0[0]));

  assign reqbufs_prearb_addr = (({41{tagctl_prearb[3]}} & reqbuf_tagctl_addr1_tc0[3]) |
                                ({41{tagctl_prearb[2]}} & reqbuf_tagctl_addr1_tc0[2]) |
                                ({41{tagctl_prearb[1]}} & reqbuf_tagctl_addr1_tc0[1]) |
                                ({41{tagctl_prearb[0]}} & reqbuf_tagctl_addr1_tc0[0]));

  // Calculate the ECC bits for writing to the tag RAMs. Writes can only come
  // from the reqbufs, so no need to factor the new ACP request in. The L2, and
  // most of the L1 calcuations are done based on the prearbitrated address, the
  // cycle before tc0, as there is not time in tc0 to do the arbitration and ECC
  // generation.
  if (SCU_CACHE_PROTECTION) begin : g_scu_ecc
    wire [4:0]  reqbufs_prearb_l2_wr_state;
    wire [32:0] reqbufs_prearb_l2_data;
    wire [6:0]  next_reqbufs_l2_ecc_tc0;

    assign reqbufs_prearb_l2_wr_state = (({5{tagctl_prearb[3]}} & reqbuf_tagctl_wr_state_tc0[3][16:12]) |
                                         ({5{tagctl_prearb[2]}} & reqbuf_tagctl_wr_state_tc0[2][16:12]) |
                                         ({5{tagctl_prearb[1]}} & reqbuf_tagctl_wr_state_tc0[1][16:12]) |
                                         ({5{tagctl_prearb[0]}} & reqbuf_tagctl_wr_state_tc0[0][16:12]));

    assign reqbufs_prearb_l2_data = {reqbufs_prearb_l2_wr_state,
                                     reqbufs_prearb_addr[40:17],
                                     reqbufs_prearb_addr[16:13] & ~acpslv_l2_size};

    ca53_ecc_generate33 u_ecc_generate (
      .data_i (reqbufs_prearb_l2_data),
      .ecc_o  (next_reqbufs_l2_ecc_tc0)
    );

    always @(posedge clk_acp)
    if (tagctl_prearb_en) begin
      reqbufs_l2_ecc_tc0 <= next_reqbufs_l2_ecc_tc0;
    end

  end else begin : g_n_scu_ecc
    always @*
      reqbufs_l2_ecc_tc0 = {7{zero}};
  end

  // For the L1 tags, the value being written is the same for all CPUs,
  // so we can share the generation logic.
  if (CPU_CACHE_PROTECTION) begin : g_cpu_ecc

    wire [32:0] reqbufs_l1_prearb_addr;
    wire [6:0]  next_reqbufs_l1_ecc_tc0;

    assign reqbufs_l1_prearb_addr = {3'b000,
                                     reqbufs_prearb_addr[40:14],
                                     reqbufs_prearb_addr[13:11] & ~acpslv_l1_dc_size};

    ca53_ecc_generate33 u_ecc_generate (
      .data_i (reqbufs_l1_prearb_addr),
      .ecc_o  (next_reqbufs_l1_ecc_tc0)
    );


    always @(posedge clk_acp)
    if (tagctl_prearb_en) begin
      reqbufs_l1_ecc_tc0 <= next_reqbufs_l1_ecc_tc0;
    end

  end else begin : g_n_cpu_ecc
    always @*
      reqbufs_l1_ecc_tc0 = {7{zero}};
  end

  assign acpslv_tagctl_ecc_tc0_o = {reqbufs_l2_ecc_tc0,
                                    {4{reqbufs_l1_ecc_tc0}}};

  assign acpslv_tagctl_ways_tc0_o = (({32{tagctl_arb_tc0[4]}} & {32{acp_addr_read}}) |
                                     ({32{tagctl_arb_tc0[3]}} & reqbuf_tagctl_ways_tc0[3]) |
                                     ({32{tagctl_arb_tc0[2]}} & reqbuf_tagctl_ways_tc0[2]) |
                                     ({32{tagctl_arb_tc0[1]}} & reqbuf_tagctl_ways_tc0[1]) |
                                     ({32{tagctl_arb_tc0[0]}} & reqbuf_tagctl_ways_tc0[0]));

  // No requests write the tag on their first pass.
  assign acpslv_tagctl_write_tc0_o = (({5{tagctl_arb_tc0[3]}} & reqbuf_tagctl_write_tc0[3]) |
                                      ({5{tagctl_arb_tc0[2]}} & reqbuf_tagctl_write_tc0[2]) |
                                      ({5{tagctl_arb_tc0[1]}} & reqbuf_tagctl_write_tc0[1]) |
                                      ({5{tagctl_arb_tc0[0]}} & reqbuf_tagctl_write_tc0[0]));

  assign acpslv_tagctl_type_tc0_o = (({5{tagctl_arb_tc0[4]}} & (acp_addr_read ? `CA53_REQ_READONCE :
                                                                                `CA53_REQ_WRITEUNIQUE)) |
                                     ({5{tagctl_arb_tc0[3]}} & reqbuf_type[3]) |
                                     ({5{tagctl_arb_tc0[2]}} & reqbuf_type[2]) |
                                     ({5{tagctl_arb_tc0[1]}} & reqbuf_type[1]) |
                                     ({5{tagctl_arb_tc0[0]}} & reqbuf_type[0]));

  // Many of the attributes are not required in tc0, so register the
  // arbitration then send them in tc1 which is less timing critical.
  assign next_reqbuf_arb_tc1 = ((tagctl_arb_tc0[NUM_REQBUFS] ? reqbuf_alloc :
                                                               tagctl_arb_tc0[NUM_REQBUFS-1:0]) &
                                {NUM_REQBUFS{tagctl_acpslv_ready_tc0_i}});

  // The TC1 arbitration result must be cleared if nothing is arbitrated, so
  // that the reqbufs can work out if they are in TC0 or TC1.
  assign reqbuf_arb_tc1_en = (|reqbuf_arb_tc1 |
                              acpslv_tagctl_valid_tc0);

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    reqbuf_arb_tc1 <= {NUM_REQBUFS{1'b0}};
  end else if (reqbuf_arb_tc1_en) begin
    reqbuf_arb_tc1 <= next_reqbuf_arb_tc1;
  end


  // Send the remaining information to tagctl in TC1
  assign acpslv_tagctl_attrs_tc1_o = (({8{reqbuf_arb_tc1[3]}} & reqbuf_attrs[3]) |
                                      ({8{reqbuf_arb_tc1[2]}} & reqbuf_attrs[2]) |
                                      ({8{reqbuf_arb_tc1[1]}} & reqbuf_attrs[1]) |
                                      ({8{reqbuf_arb_tc1[0]}} & reqbuf_attrs[0]));

  assign acpslv_tagctl_dirty_tc1_o = ((reqbuf_arb_tc1[3] & reqbuf_dirty[3]) |
                                      (reqbuf_arb_tc1[2] & reqbuf_dirty[2]) |
                                      (reqbuf_arb_tc1[1] & reqbuf_dirty[1]) |
                                      (reqbuf_arb_tc1[0] & reqbuf_dirty[0]));

  assign acpslv_tagctl_cluster_unique_tc1_o = ((reqbuf_arb_tc1[3] & reqbuf_cluster_unique[3]) |
                                               (reqbuf_arb_tc1[2] & reqbuf_cluster_unique[2]) |
                                               (reqbuf_arb_tc1[1] & reqbuf_cluster_unique[1]) |
                                               (reqbuf_arb_tc1[0] & reqbuf_cluster_unique[0]));

  assign acpslv_tagctl_len_tc1_o = (({2{reqbuf_arb_tc1[3]}} & reqbuf_len_tc1[3]) |
                                    ({2{reqbuf_arb_tc1[2]}} & reqbuf_len_tc1[2]) |
                                    ({2{reqbuf_arb_tc1[1]}} & reqbuf_len_tc1[1]) |
                                    ({2{reqbuf_arb_tc1[0]}} & reqbuf_len_tc1[0]));

  assign acpslv_tagctl_single_tc1_o = ((reqbuf_arb_tc1[3] & ~reqbuf_len[3][0]) |
                                       (reqbuf_arb_tc1[2] & ~reqbuf_len[2][0]) |
                                       (reqbuf_arb_tc1[1] & ~reqbuf_len[1][0]) |
                                       (reqbuf_arb_tc1[0] & ~reqbuf_len[0][0]));

  assign acpslv_tagctl_size_tc1_o = 3'b100;

  assign acpslv_tagctl_prot_tc1_o = (({2{reqbuf_arb_tc1[3]}} & reqbuf_prot[3]) |
                                     ({2{reqbuf_arb_tc1[2]}} & reqbuf_prot[2]) |
                                     ({2{reqbuf_arb_tc1[1]}} & reqbuf_prot[1]) |
                                     ({2{reqbuf_arb_tc1[0]}} & reqbuf_prot[0]));

  assign acpslv_tagctl_l2db_tc1_o = (({4{reqbuf_arb_tc1[3]}} & reqbuf_l2db_tc1[3]) |
                                     ({4{reqbuf_arb_tc1[2]}} & reqbuf_l2db_tc1[2]) |
                                     ({4{reqbuf_arb_tc1[1]}} & reqbuf_l2db_tc1[1]) |
                                     ({4{reqbuf_arb_tc1[0]}} & reqbuf_l2db_tc1[0]));

  assign acpslv_tagctl_l2db_full_tc1_o = ((reqbuf_arb_tc1[3] & reqbuf_l2db_full[3]) |
                                          (reqbuf_arb_tc1[2] & reqbuf_l2db_full[2]) |
                                          (reqbuf_arb_tc1[1] & reqbuf_l2db_full[1]) |
                                          (reqbuf_arb_tc1[0] & reqbuf_l2db_full[0]));

  assign acpslv_tagctl_static_pcredit_tc1_o = ((reqbuf_arb_tc1[3] & reqbuf_static_pcredit_tc1[3]) |
                                               (reqbuf_arb_tc1[2] & reqbuf_static_pcredit_tc1[2]) |
                                               (reqbuf_arb_tc1[1] & reqbuf_static_pcredit_tc1[1]) |
                                               (reqbuf_arb_tc1[0] & reqbuf_static_pcredit_tc1[0]));

  assign acpslv_tagctl_pcrdtype_tc1_o = (({2{reqbuf_arb_tc1[3]}} & reqbuf_pcrdtype_tc1[3]) |
                                         ({2{reqbuf_arb_tc1[2]}} & reqbuf_pcrdtype_tc1[2]) |
                                         ({2{reqbuf_arb_tc1[1]}} & reqbuf_pcrdtype_tc1[1]) |
                                         ({2{reqbuf_arb_tc1[0]}} & reqbuf_pcrdtype_tc1[0]));

  assign acpslv_tagctl_victim_way_tc1_o = (({4{reqbuf_arb_tc1[3]}} & reqbuf_victim_way_tc1[3]) |
                                           ({4{reqbuf_arb_tc1[2]}} & reqbuf_victim_way_tc1[2]) |
                                           ({4{reqbuf_arb_tc1[1]}} & reqbuf_victim_way_tc1[1]) |
                                           ({4{reqbuf_arb_tc1[0]}} & reqbuf_victim_way_tc1[0]));

  assign acpslv_tagctl_slverr_tc1_o = ((reqbuf_arb_tc1[3] & reqbuf_slverr[3]) |
                                       (reqbuf_arb_tc1[2] & reqbuf_slverr[2]) |
                                       (reqbuf_arb_tc1[1] & reqbuf_slverr[1]) |
                                       (reqbuf_arb_tc1[0] & reqbuf_slverr[0]));

  assign next_acpslv_noncoh_only = gov_l2_in_retention_i | tagctl_acpslv_noncoh_only_i;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    acpslv_noncoh_only <= 1'b1;
  end else begin
    acpslv_noncoh_only <= next_acpslv_noncoh_only;
  end

  always @(posedge clk_acp)
  begin
    acpslv_enable_writeevict <= gov_enable_writeevict_i;
  end

  // Send transfer requests to each L2DB.
  for (i = 0; i < MAX_L2DBS; i = i + 1) begin : g_l2db_mux
    for (j = 0; j < NUM_REQBUFS; j = j + 1) begin : g_l2db_reqbuf
      assign l2db_transfer[i][j]               = reqbuf_l2db_primary_transfer[j] & (reqbuf_l2db_primary_id[j] == i[3:0]);
      assign l2db_transfer[i][j + NUM_REQBUFS] = reqbuf_l2db_victim_transfer[j]  & (reqbuf_l2db_victim_id[j]  == i[3:0]);
      assign l2db_release[i][j]                = reqbuf_l2db_primary_release[j]  & (reqbuf_l2db_primary_id[j] == i[3:0]);
      assign l2db_release[i][j + NUM_REQBUFS]  = reqbuf_l2db_victim_release[j]   & (reqbuf_l2db_victim_id[j]  == i[3:0]);
    end

    if (i < NUM_L2DBS) begin : g_l2db

      assign next_l2db_buf_release[i] = |l2db_release[i];

      always @(posedge clk_acp or negedge reset_n)
      if (~reset_n) begin
        l2db_buf_release[i] <= 1'b0;
      end else begin
        l2db_buf_release[i] <= next_l2db_buf_release[i];
      end

      assign acpslv_l2db_release[i] = l2db_buf_release[i];

      assign l2db_transfer_type[i] = (({3{l2db_transfer[i][7]}}  & reqbuf_l2db_victim_transfer_type[3]) |
                                      ({3{l2db_transfer[i][6]}}  & reqbuf_l2db_victim_transfer_type[2]) |
                                      ({3{l2db_transfer[i][5]}}  & reqbuf_l2db_victim_transfer_type[1]) |
                                      ({3{l2db_transfer[i][4]}}  & reqbuf_l2db_victim_transfer_type[0]) |
                                      ({3{l2db_transfer[i][3]}}  & reqbuf_l2db_primary_transfer_type[3]) |
                                      ({3{l2db_transfer[i][2]}}  & reqbuf_l2db_primary_transfer_type[2]) |
                                      ({3{l2db_transfer[i][1]}}  & reqbuf_l2db_primary_transfer_type[1]) |
                                      ({3{l2db_transfer[i][0]}}  & reqbuf_l2db_primary_transfer_type[0]));

      assign l2db_transfer_info[i] = (({26{l2db_transfer[i][7]}}  & reqbuf_l2db_victim_transfer_info[3]) |
                                      ({26{l2db_transfer[i][6]}}  & reqbuf_l2db_victim_transfer_info[2]) |
                                      ({26{l2db_transfer[i][5]}}  & reqbuf_l2db_victim_transfer_info[1]) |
                                      ({26{l2db_transfer[i][4]}}  & reqbuf_l2db_victim_transfer_info[0]) |
                                      ({26{l2db_transfer[i][3]}}  & reqbuf_l2db_primary_transfer_info[3]) |
                                      ({26{l2db_transfer[i][2]}}  & reqbuf_l2db_primary_transfer_info[2]) |
                                      ({26{l2db_transfer[i][1]}}  & reqbuf_l2db_primary_transfer_info[1]) |
                                      ({26{l2db_transfer[i][0]}}  & reqbuf_l2db_primary_transfer_info[0]));

    end else begin : g_n_l2db
      assign acpslv_l2db_release[i] = 1'b0;
      assign l2db_transfer_type[i] = 3'b000;
      assign l2db_transfer_info[i] = {26{1'b0}};
    end
  end

  assign acpslv_l2db0_transfer_o  = |l2db_transfer[0];
  assign acpslv_l2db1_transfer_o  = |l2db_transfer[1];
  assign acpslv_l2db2_transfer_o  = |l2db_transfer[2];
  assign acpslv_l2db3_transfer_o  = |l2db_transfer[3];
  assign acpslv_l2db4_transfer_o  = |l2db_transfer[4];
  assign acpslv_l2db5_transfer_o  = |l2db_transfer[5];
  assign acpslv_l2db6_transfer_o  = |l2db_transfer[6];
  assign acpslv_l2db7_transfer_o  = |l2db_transfer[7];
  assign acpslv_l2db8_transfer_o  = |l2db_transfer[8];
  assign acpslv_l2db9_transfer_o  = |l2db_transfer[9];
  assign acpslv_l2db10_transfer_o = |l2db_transfer[10];

  assign acpslv_l2db0_transfer_type_o  = l2db_transfer_type[0];
  assign acpslv_l2db1_transfer_type_o  = l2db_transfer_type[1];
  assign acpslv_l2db2_transfer_type_o  = l2db_transfer_type[2];
  assign acpslv_l2db3_transfer_type_o  = l2db_transfer_type[3];
  assign acpslv_l2db4_transfer_type_o  = l2db_transfer_type[4];
  assign acpslv_l2db5_transfer_type_o  = l2db_transfer_type[5];
  assign acpslv_l2db6_transfer_type_o  = l2db_transfer_type[6];
  assign acpslv_l2db7_transfer_type_o  = l2db_transfer_type[7];
  assign acpslv_l2db8_transfer_type_o  = l2db_transfer_type[8];
  assign acpslv_l2db9_transfer_type_o  = l2db_transfer_type[9];
  assign acpslv_l2db10_transfer_type_o = l2db_transfer_type[10];

  assign acpslv_l2db0_transfer_info_o  = l2db_transfer_info[0];
  assign acpslv_l2db1_transfer_info_o  = l2db_transfer_info[1];
  assign acpslv_l2db2_transfer_info_o  = l2db_transfer_info[2];
  assign acpslv_l2db3_transfer_info_o  = l2db_transfer_info[3];
  assign acpslv_l2db4_transfer_info_o  = l2db_transfer_info[4];
  assign acpslv_l2db5_transfer_info_o  = l2db_transfer_info[5];
  assign acpslv_l2db6_transfer_info_o  = l2db_transfer_info[6];
  assign acpslv_l2db7_transfer_info_o  = l2db_transfer_info[7];
  assign acpslv_l2db8_transfer_info_o  = l2db_transfer_info[8];
  assign acpslv_l2db9_transfer_info_o  = l2db_transfer_info[9];
  assign acpslv_l2db10_transfer_info_o = l2db_transfer_info[10];

  assign acpslv_l2db0_release_o  = acpslv_l2db_release[0];
  assign acpslv_l2db1_release_o  = acpslv_l2db_release[1];
  assign acpslv_l2db2_release_o  = acpslv_l2db_release[2];
  assign acpslv_l2db3_release_o  = acpslv_l2db_release[3];
  assign acpslv_l2db4_release_o  = acpslv_l2db_release[4];
  assign acpslv_l2db5_release_o  = acpslv_l2db_release[5];
  assign acpslv_l2db6_release_o  = acpslv_l2db_release[6];
  assign acpslv_l2db7_release_o  = acpslv_l2db_release[7];
  assign acpslv_l2db8_release_o  = acpslv_l2db_release[8];
  assign acpslv_l2db9_release_o  = acpslv_l2db_release[9];
  assign acpslv_l2db10_release_o = acpslv_l2db_release[10];

  // Indicate if an L2DB may need to be allocate in the following cycle.
  assign acpslv_l2dbs_active_o = acpslv_tagctl_valid_tc0 & ((acpslv_tagctl_pass_tc0 == `CA53_TAGCTL_PASS_SERIALISE) |
                                                            (acpslv_tagctl_pass_tc0 == `CA53_TAGCTL_PASS_L2DB));

  // Indicate if ramctl might get a request from an L2DB in the following cycle.
  assign acpslv_ramctl_active_o = |reqbuf_ramctl_active;

  // Combine hazard results from each reqbuf, then register before returning
  // to tagctl in the following cycle.
  assign acpslv_hz_tc1 = |reqbuf_hz_tc1;

  assign acpslv_force_miss_tc1 = (reqbuf_force_miss_tc1[3] |
                                  reqbuf_force_miss_tc1[2] |
                                  reqbuf_force_miss_tc1[1] |
                                  reqbuf_force_miss_tc1[0]);

  assign acpslv_l2_way_used_tc1 = (reqbuf_l2_way_used_tc1[3] |
                                   reqbuf_l2_way_used_tc1[2] |
                                   reqbuf_l2_way_used_tc1[1] |
                                   reqbuf_l2_way_used_tc1[0]);

  assign acpslv_l2_way_used_vc1 = (reqbuf_l2_way_used_vc1[3] |
                                   reqbuf_l2_way_used_vc1[2] |
                                   reqbuf_l2_way_used_vc1[1] |
                                   reqbuf_l2_way_used_vc1[0]);

  assign acpslv_hz_tc3 = |reqbuf_hz_tc3;

  always @(posedge clk_acp)
  begin
    acpslv_force_miss_tc2  <= acpslv_force_miss_tc1;
    acpslv_l2_way_used_tc2 <= acpslv_l2_way_used_tc1;
    acpslv_l2_way_used_vc2 <= acpslv_l2_way_used_vc1;
    acpslv_hz_tc2          <= acpslv_hz_tc1;
    acpslv_hz_tc4          <= acpslv_hz_tc3;
    acpslv_ecc_err_tc4     <= tagctl_ecc_err_tc3_i;
  end

  assign acpslv_hz_tc2_o = acpslv_hz_tc2;

  assign acpslv_hz_tc4_o = acpslv_hz_tc4;

  assign acpslv_l2_way_used_tc2_o = acpslv_l2_way_used_tc2;

  assign acpslv_l2_way_used_vc2_o = acpslv_l2_way_used_vc2;

  assign acpslv_force_miss_tc2_o = acpslv_force_miss_tc2;

  // Combine L2 allocation information to the master. At most only one reqbuf
  // will match the request, and so there is no need to mux between them.
  assign acpslv_early_dr_l2_o = |reqbuf_early_dr_l2;

  assign acpslv_early_dr_index_o = (reqbuf_early_dr_index[3] |
                                    reqbuf_early_dr_index[2] |
                                    reqbuf_early_dr_index[1] |
                                    reqbuf_early_dr_index[0]);

  assign acpslv_early_dr_way_o = (reqbuf_early_dr_way[3] |
                                  reqbuf_early_dr_way[2] |
                                  reqbuf_early_dr_way[1] |
                                  reqbuf_early_dr_way[0]);

  assign next_acpslv_ext_err = |reqbuf_ext_err;

  always @(posedge clk_acp or negedge reset_n)
  if (~reset_n) begin
    acpslv_ext_err <= 1'b0;
  end else begin
    acpslv_ext_err <= next_acpslv_ext_err;
  end

  assign acpslv_ext_err_o = acpslv_ext_err;

  //----------------------------------------------------------------------------
  //  Skyros CompAck responses
  //----------------------------------------------------------------------------

  // The oldest reqbuf wanting to send a compack is given priority.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_compack_arb
    assign reqbuf_compack_arb[i] = (reqbuf_compack_valid[i] & ~reqbuf_compack_ready[i] &
                                    ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                       reqbuf_compack_valid & ~reqbuf_compack_ready));
  end

  assign acpslv_compack_active_o = |reqbuf_compack_active;

  assign acpslv_compack_valid_o = |(reqbuf_compack_valid & ~reqbuf_compack_ready);

  assign acpslv_compack_tgtid_o = (({7{reqbuf_compack_arb[3]}} & reqbuf_compack_tgtid[3]) |
                                   ({7{reqbuf_compack_arb[2]}} & reqbuf_compack_tgtid[2]) |
                                   ({7{reqbuf_compack_arb[1]}} & reqbuf_compack_tgtid[1]) |
                                   ({7{reqbuf_compack_arb[0]}} & reqbuf_compack_tgtid[0]));

  assign acpslv_compack_txnid_o = (({8{reqbuf_compack_arb[3]}} & reqbuf_compack_txnid[3]) |
                                   ({8{reqbuf_compack_arb[2]}} & reqbuf_compack_txnid[2]) |
                                   ({8{reqbuf_compack_arb[1]}} & reqbuf_compack_txnid[1]) |
                                   ({8{reqbuf_compack_arb[0]}} & reqbuf_compack_txnid[0]));

  assign next_reqbuf_compack_ready = {NUM_REQBUFS{snpslv_acpslv_compack_ready_i}} & reqbuf_compack_arb;

  assign reqbuf_compack_ready_en = |reqbuf_compack_valid;

  if (ACE) begin : g_compack_ace

    always @*
      reqbuf_compack_ready = {NUM_REQBUFS{zero}};

  end else begin : g_compack_skyros

    always @(posedge clk_acp or negedge reset_n)
    if (~reset_n) begin
      reqbuf_compack_ready <= {NUM_REQBUFS{1'b0}};
    end else if (reqbuf_compack_ready_en) begin
      reqbuf_compack_ready <= next_reqbuf_compack_ready;
    end

  end

  //----------------------------------------------------------------------------
  //  Victimctl requests
  //----------------------------------------------------------------------------

  assign acpslv_victimctl_active_o = |reqbuf_victimctl_active;

  assign acpslv_victimctl_valid_o = |reqbuf_victimctl_valid;

  // The oldest reqbuf wanting to access the victim RAM is given priority.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_victimctl_arb
    assign reqbuf_victimctl_arb[i] = (reqbuf_victimctl_valid[i] &
                                      ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                         reqbuf_victimctl_valid));

    assign reqbuf_victimctl_ready[i] = victimctl_ready_i & (victimctl_ready_id_i == {4'b1001, i[1:0]});
  end

  assign acpslv_victimctl_wr_o = |(reqbuf_victimctl_arb & reqbuf_victimctl_wr);

  assign acpslv_victimctl_age_o = |(reqbuf_victimctl_arb & reqbuf_victimctl_age);

  assign acpslv_victimctl_index_o = (({11{reqbuf_victimctl_arb[0]}} & reqbuf_victimctl_index[0]) |
                                     ({11{reqbuf_victimctl_arb[1]}} & reqbuf_victimctl_index[1]) |
                                     ({11{reqbuf_victimctl_arb[2]}} & reqbuf_victimctl_index[2]) |
                                     ({11{reqbuf_victimctl_arb[3]}} & reqbuf_victimctl_index[3]));

  assign acpslv_victimctl_way_o = (({4{reqbuf_victimctl_arb[0]}} & reqbuf_victimctl_way[0]) |
                                   ({4{reqbuf_victimctl_arb[1]}} & reqbuf_victimctl_way[1]) |
                                   ({4{reqbuf_victimctl_arb[2]}} & reqbuf_victimctl_way[2]) |
                                   ({4{reqbuf_victimctl_arb[3]}} & reqbuf_victimctl_way[3]));

  assign acpslv_victimctl_id_o = (({3{reqbuf_victimctl_arb[0]}} & 3'b100) |
                                  ({3{reqbuf_victimctl_arb[1]}} & 3'b101) |
                                  ({3{reqbuf_victimctl_arb[2]}} & 3'b110) |
                                  ({3{reqbuf_victimctl_arb[3]}} & 3'b111));

  //----------------------------------------------------------------------------
  //  Request buffers
  //----------------------------------------------------------------------------

  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_reqbuf


    ca53scu_reqbuf_acp #(`CA53_SCU_INT_PARAM_INST, .NUM_REQBUFS(NUM_REQBUFS), .REQBUF_ID({4'b1001, i[1:0]})) u_reqbuf (
      // Inputs
      .clk                                   (clk_acp),
      .reset_n                               (reset_n),
      .acpslv_broadcastinner_i               (acpslv_broadcastinner),
      .acpslv_broadcastouter_i               (acpslv_broadcastouter),
      .acpslv_l1_dc_size_i                   (acpslv_l1_dc_size),
      .acpslv_l2_size_i                      (acpslv_l2_size),
      .reqbuf_alloc_i                        (reqbuf_alloc[i]),
      .reqbuf_db_ready_i                     (reqbuf_db_ready[i]),
      .tagctl_addr_tc1_i                     (tagctl_addr_tc1_i),
      .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1_i),
      .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1_i),
      .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1_i),
      .tagctl_serialising_tc1_i              (tagctl_serialising_tc1_i),
      .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1_i),
      .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1_i),
      .victimctl_index_vc1_i                 (victimctl_index_vc1_i),
      .tagctl_addr_tc3_i                     (tagctl_addr_tc3_i),
      .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3_i),
      .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3_i),
      .reqbuf_arb_tc1_i                      (reqbuf_arb_tc1[i]),
      .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1_i),
      .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2_i),
      .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3_i),
      .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4_i),
      .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4_i),
      .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1_i),
      .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4_i),
      .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3_i),
      .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3_i),
      .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3_i),
      .tagctl_shareability_tc3_i             (tagctl_shareability_tc3_i),
      .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3_i),
      .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3_i),
      .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3_i),
      .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3_i),
      .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3_i),
      .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3_i),
      .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3_i),
      .acpslv_ecc_err_tc4_i                  (acpslv_ecc_err_tc4),
      .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4_i),
      .afb0_done_i                           (afb0_done_i),
      .afb1_done_i                           (afb1_done_i),
      .afb2_done_i                           (afb2_done_i),
      .afb3_done_i                           (afb3_done_i),
      .afb4_done_i                           (afb4_done_i),
      .afb5_done_i                           (afb5_done_i),
      .afb0_write_done_i                     (afb0_write_done_i),
      .afb1_write_done_i                     (afb1_write_done_i),
      .afb2_write_done_i                     (afb2_write_done_i),
      .afb3_write_done_i                     (afb3_write_done_i),
      .afb4_write_done_i                     (afb4_write_done_i),
      .afb5_write_done_i                     (afb5_write_done_i),
      .l2db0_slv_done_i                      (l2db0_slv_done_i),
      .l2db1_slv_done_i                      (l2db1_slv_done_i),
      .l2db2_slv_done_i                      (l2db2_slv_done_i),
      .l2db3_slv_done_i                      (l2db3_slv_done_i),
      .l2db4_slv_done_i                      (l2db4_slv_done_i),
      .l2db5_slv_done_i                      (l2db5_slv_done_i),
      .l2db6_slv_done_i                      (l2db6_slv_done_i),
      .l2db7_slv_done_i                      (l2db7_slv_done_i),
      .l2db8_slv_done_i                      (l2db8_slv_done_i),
      .l2db9_slv_done_i                      (l2db9_slv_done_i),
      .l2db10_slv_done_i                     (l2db10_slv_done_i),
      .l2db0_full_line_i                     (l2db0_full_line_i),
      .l2db1_full_line_i                     (l2db1_full_line_i),
      .l2db2_full_line_i                     (l2db2_full_line_i),
      .l2db3_full_line_i                     (l2db3_full_line_i),
      .l2db4_full_line_i                     (l2db4_full_line_i),
      .l2db5_full_line_i                     (l2db5_full_line_i),
      .l2db6_full_line_i                     (l2db6_full_line_i),
      .l2db7_full_line_i                     (l2db7_full_line_i),
      .l2db8_full_line_i                     (l2db8_full_line_i),
      .l2db9_full_line_i                     (l2db9_full_line_i),
      .l2db10_full_line_i                    (l2db10_full_line_i),
      .l2db0_rmw_line_i                      (l2db0_rmw_line_i),
      .l2db1_rmw_line_i                      (l2db1_rmw_line_i),
      .l2db2_rmw_line_i                      (l2db2_rmw_line_i),
      .l2db3_rmw_line_i                      (l2db3_rmw_line_i),
      .l2db4_rmw_line_i                      (l2db4_rmw_line_i),
      .l2db5_rmw_line_i                      (l2db5_rmw_line_i),
      .l2db6_rmw_line_i                      (l2db6_rmw_line_i),
      .l2db7_rmw_line_i                      (l2db7_rmw_line_i),
      .l2db8_rmw_line_i                      (l2db8_rmw_line_i),
      .l2db9_rmw_line_i                      (l2db9_rmw_line_i),
      .l2db10_rmw_line_i                     (l2db10_rmw_line_i),
      .reqbuf_victimctl_ready_i              (reqbuf_victimctl_ready[i]),
      .victimctl_ack_i                       (victimctl_ack_i),
      .victimctl_ack_id_i                    (victimctl_ack_id_i),
      .victimctl_victim_way_i                (victimctl_victim_way_i),
      .reqbuf_compack_ready_i                (reqbuf_compack_ready[i]),
      .acpslv_enable_writeevict_i            (acpslv_enable_writeevict),
      .acp_addr_id_i                         (acp_addr_id),
      .acp_addr_read_i                       (acp_addr_read),
      .acp_addr_alloc_i                      (acp_addr_alloc),
      .acp_addr_domain_i                     (acp_addr_domain),
      .acp_addr_slverr_i                     (acp_addr_slverr),
      .acp_addr_addr_i                       (acp_addr_addr[40:4]),
      .acp_addr_len_i                        (acp_addr_len),
      .next_acpslv_noncoh_only_i             (next_acpslv_noncoh_only),
      .reqbuf_tagctl_prearb_primary_i        (reqbuf_tagctl_prearb_primary[i]),
      .reqbuf_tagctl_prearb_victim_i         (reqbuf_tagctl_prearb_victim[i]),
      .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1_i),
      .master_early_dr_valid_i               (master_early_dr_valid_i),
      .master_early_dr_barrier_i             (master_early_dr_barrier_i),
      .master_early_dr_id_i                  (master_early_dr_id_i),
      .master_early_dr_dbid_i                (master_early_dr_dbid_i),
      .master_early_dr_srcid_i               (master_early_dr_srcid_i),
      .master_early_dr_chunk_i               (master_early_dr_chunk_i),
      .master_early_dr_resp_i                (master_early_dr_resp_i),
      .master_early_dr_same_i                (master_early_dr_same_i),
      .master_early_dr_ready_i               (master_early_dr_ready_i),
      .master_acpslv_dr_valid_i              (master_acpslv_dr_valid_i),
      .acpslv_master_dr_ready_i              (acpslv_master_dr_ready),
      .master_dr_id_i                        (master_acpslv_dr_id_i),
      .master_dr_resp_i                      (master_dr_resp_i),
      .master_acpslv_l2_waiting_i            (master_acpslv_l2_waiting_i[i]),
      .master_rsp_comp_valid_i               (master_rsp_comp_valid_i),
      .master_rsp_txnid_i                    (master_rsp_txnid_i),
      .master_rsp_dbid_i                     (master_rsp_dbid_i),
      .master_rsp_srcid_i                    (master_rsp_srcid_i),
      .master_rsp_resp_i                     (master_rsp_resp_i),
      .reqbuf_retry_i                        (master_acpslv_reqbuf_retry_i[i]),
      .reqbuf_retry_pcrdtype_i               (master_acpslv_pcrdtype_i),
      .acpslv_wdata_valid_i                  (acpslv_wdata_valid[i]),
      .acpslv_wdata_last_i                   (acpslv_wdata_last),
      .reqbuf_dr_ready_i                     (reqbuf_dr_ready[i]),
      // Outputs
      .reqbuf_busy_o                         (reqbuf_busy[i]),
      .reqbuf_hz_tc1_o                       (reqbuf_hz_tc1[i]),
      .reqbuf_hz_tc3_o                       (reqbuf_hz_tc3[i]),
      .reqbuf_force_miss_tc1_o               (reqbuf_force_miss_tc1[i]),
      .reqbuf_l2_way_used_tc1_o              (reqbuf_l2_way_used_tc1[i]),
      .reqbuf_l2_way_used_vc1_o              (reqbuf_l2_way_used_vc1[i]),
      .reqbuf_id_hazard_o                    (reqbuf_id_hazard[i]),
      .reqbuf_tagctl_valid_tc0_o             (reqbuf_tagctl_valid_tc0[i]),
      .reqbuf_tagctl_prearb_req_o            (reqbuf_tagctl_prearb_req[i]),
      .reqbuf_tagctl_prearb_pri1_o           (reqbuf_tagctl_prearb_pri1[i]),
      .reqbuf_tagctl_prearb_pri2_o           (reqbuf_tagctl_prearb_pri2[i]),
      .reqbuf_tagctl_primary_tc0_o           (reqbuf_tagctl_primary_tc0[i]),
      .reqbuf_update_primary_pass_o          (reqbuf_update_primary_pass[i]),
      .reqbuf_update_victim_pass_o           (reqbuf_update_victim_pass[i]),
      .reqbuf_tagctl_pass_tc0_o              (reqbuf_tagctl_pass_tc0[i]),
      .reqbuf_tagctl_addr1_tc0_o             (reqbuf_tagctl_addr1_tc0[i]),
      .reqbuf_tagctl_wr_state_tc0_o          (reqbuf_tagctl_wr_state_tc0[i]),
      .reqbuf_tagctl_ways_tc0_o              (reqbuf_tagctl_ways_tc0[i]),
      .reqbuf_tagctl_write_tc0_o             (reqbuf_tagctl_write_tc0[i]),
      .reqbuf_type_o                         (reqbuf_type[i]),
      .reqbuf_slverr_o                       (reqbuf_slverr[i]),
      .reqbuf_static_pcredit_tc1_o           (reqbuf_static_pcredit_tc1[i]),
      .reqbuf_pcrdtype_tc1_o                 (reqbuf_pcrdtype_tc1[i]),
      .reqbuf_victim_way_tc1_o               (reqbuf_victim_way_tc1[i]),
      .reqbuf_l2db_tc1_o                     (reqbuf_l2db_tc1[i]),
      .reqbuf_db_valid_o                     (reqbuf_db_valid[i]),
      .reqbuf_db_resp_o                      (reqbuf_db_resp[i]),
      .reqbuf_dr_valid_o                     (reqbuf_dr_valid[i]),
      .reqbuf_l2db_primary_transfer_o        (reqbuf_l2db_primary_transfer[i]),
      .reqbuf_l2db_victim_transfer_o         (reqbuf_l2db_victim_transfer[i]),
      .reqbuf_l2db_primary_id_o              (reqbuf_l2db_primary_id[i]),
      .reqbuf_l2db_victim_id_o               (reqbuf_l2db_victim_id[i]),
      .reqbuf_l2db_primary_transfer_type_o   (reqbuf_l2db_primary_transfer_type[i]),
      .reqbuf_l2db_victim_transfer_type_o    (reqbuf_l2db_victim_transfer_type[i]),
      .reqbuf_l2db_primary_transfer_info_o   (reqbuf_l2db_primary_transfer_info[i]),
      .reqbuf_l2db_victim_transfer_info_o    (reqbuf_l2db_victim_transfer_info[i]),
      .reqbuf_l2db_primary_release_o         (reqbuf_l2db_primary_release[i]),
      .reqbuf_l2db_victim_release_o          (reqbuf_l2db_victim_release[i]),
      .reqbuf_victimctl_active_o             (reqbuf_victimctl_active[i]),
      .reqbuf_victimctl_valid_o              (reqbuf_victimctl_valid[i]),
      .reqbuf_victimctl_index_o              (reqbuf_victimctl_index[i]),
      .reqbuf_victimctl_wr_o                 (reqbuf_victimctl_wr[i]),
      .reqbuf_victimctl_age_o                (reqbuf_victimctl_age[i]),
      .reqbuf_victimctl_way_o                (reqbuf_victimctl_way[i]),
      .reqbuf_compack_active_o               (reqbuf_compack_active[i]),
      .reqbuf_compack_valid_o                (reqbuf_compack_valid[i]),
      .reqbuf_compack_tgtid_o                (reqbuf_compack_tgtid[i]),
      .reqbuf_compack_txnid_o                (reqbuf_compack_txnid[i]),
      .reqbuf_ramctl_active_o                (reqbuf_ramctl_active[i]),
      .reqbuf_ext_err_o                      (reqbuf_ext_err[i]),
      .reqbuf_suppress_dr_o                  (reqbuf_suppress_dr[i]),
      .reqbuf_early_dr_ready_o               (acpslv_early_dr_ready_o[i*4+:4]),
      .reqbuf_len_o                          (reqbuf_len[i]),
      .reqbuf_len_tc1_o                      (reqbuf_len_tc1[i]),
      .reqbuf_dirty_o                        (reqbuf_dirty[i]),
      .reqbuf_cluster_unique_o               (reqbuf_cluster_unique[i]),
      .reqbuf_attrs_o                        (reqbuf_attrs[i]),
      .reqbuf_prot_o                         (reqbuf_prot[i]),
      .reqbuf_acp_id_o                       (reqbuf_acp_id[i]),
      .reqbuf_l2db_full_o                    (reqbuf_l2db_full[i]),
      .reqbuf_dr_last_o                      (reqbuf_dr_last[i]),
      .reqbuf_early_dr_l2_o                  (reqbuf_early_dr_l2[i]),
      .reqbuf_early_dr_index_o               (reqbuf_early_dr_index[i]),
      .reqbuf_early_dr_way_o                 (reqbuf_early_dr_way[i]),
      .reqbuf_delay_allocation_o             (acpslv_delay_allocation_o[i]),
      .reqbuf_wait_data_o                    (reqbuf_wait_data[i]),
      .reqbuf_wdata_chunk_o                  (reqbuf_wdata_chunk[i])
    );
  end


  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Write data can only be accepted when the clock is not gated")
  u_ovl_dw0_en_clk (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (dw0_en),
    .consequent_expr (acp_clk_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Write data can only be accepted when the clock is not gated")
  u_ovl_dw1_en_clk (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (dw1_en),
    .consequent_expr (acp_clk_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The external clock must always be enabled when there is internal activity")
  u_ovl_ext_clk_en (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (acpslv_int_active),
    .consequent_expr (ext_acp_clk_enable));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_compack_ready_en")
  u_ovl_x_reqbuf_compack_ready_en (.clk       (clk_acp),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (reqbuf_compack_ready_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: leaving_reset_i")
  u_ovl_x_leaving_reset_i (.clk       (clk_acp),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (leaving_reset_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_prearb_en")
  u_ovl_x_tagctl_prearb_en (.clk       (clk_acp),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (tagctl_prearb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ar_en")
  u_ovl_x_ar_en (.clk       (CLKIN),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (ar_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ar_valid_en")
  u_ovl_x_ar_valid_en (.clk       (CLKIN),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ar_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: aw_en")
  u_ovl_x_aw_en (.clk       (CLKIN),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (aw_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: aw_valid_en")
  u_ovl_x_aw_valid_en (.clk       (CLKIN),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (aw_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclkens_i")
  u_ovl_x_clean_aclkens_i (.clk       (clk_acp),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (clean_aclkens_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: db_en")
  u_ovl_x_db_en (.clk       (clk_acp),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (db_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: db_skid_en")
  u_ovl_x_db_skid_en (.clk       (clk_acp),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (db_skid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_arb_en")
  u_ovl_x_dr_arb_en (.clk       (clk_acp),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (dr_arb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_en")
  u_ovl_x_dr_en (.clk       (clk_acp),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (dr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_skid_en")
  u_ovl_x_dr_skid_en (.clk       (clk_acp),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (dr_skid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dw0_en")
  u_ovl_x_dw0_en (.clk       (CLKIN),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (dw0_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dw1_en")
  u_ovl_x_dw1_en (.clk       (CLKIN),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (dw1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_arb_tc1_en")
  u_ovl_x_reqbuf_arb_tc1_en (.clk       (clk_acp),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_arb_tc1_en));


`endif

end else begin : g_no_acpslv
  // ACP not present, so tie off all outputs
  assign acpslv_active_o = 1'b0;
  assign acpslv_ramctl_active_o = 1'b0;
  assign scu_acp_awready_o = 1'b0;
  assign scu_acp_wready_o = 1'b0;
  assign scu_acp_bvalid_o = 1'b0;
  assign scu_acp_bid_o = {5{1'b0}};
  assign scu_acp_bresp_o = {2{1'b0}};
  assign scu_acp_arready_o = 1'b0;
  assign scu_acp_rvalid_o = 1'b0;
  assign scu_acp_rid_o = {5{1'b0}};
  assign scu_acp_rdata_o = {128{1'b0}};
  assign scu_acp_rresp_o = {2{1'b0}};
  assign scu_acp_rlast_o = 1'b0;
  assign acpslv_tagctl_valid_tc0_o = 1'b0;
  assign acpslv_tagctl_early_valid_tc0_o = 1'b0;
  assign acpslv_tagctl_spec_valid_tc0_o = 1'b0;
  assign acpslv_tagctl_active_tc0_o = 1'b0;
  assign acpslv_tagctl_reqbufid_tc0_o = {3{1'b0}};
  assign acpslv_tagctl_pass_tc0_o = {4{1'b0}};
  assign acpslv_tagctl_addr1_tc0_o = {41{1'b0}};
  assign acpslv_tagctl_wr_state_tc0_o = {17{1'b0}};
  assign acpslv_tagctl_ecc_tc0_o = {35{1'b0}};
  assign acpslv_tagctl_ways_tc0_o = {32{1'b0}};
  assign acpslv_tagctl_write_tc0_o = {5{1'b0}};
  assign acpslv_tagctl_type_tc0_o = {5{1'b0}};
  assign acpslv_tagctl_len_tc1_o = {2{1'b0}};
  assign acpslv_tagctl_single_tc1_o = 1'b0;
  assign acpslv_tagctl_dirty_tc1_o = 1'b0;
  assign acpslv_tagctl_cluster_unique_tc1_o = 1'b0;
  assign acpslv_tagctl_static_pcredit_tc1_o = 1'b0;
  assign acpslv_tagctl_pcrdtype_tc1_o = {2{1'b0}};
  assign acpslv_tagctl_size_tc1_o = {3{1'b0}};
  assign acpslv_tagctl_attrs_tc1_o = {8{1'b0}};
  assign acpslv_tagctl_prot_tc1_o = {2{1'b0}};
  assign acpslv_tagctl_l2db_tc1_o = {4{1'b0}};
  assign acpslv_tagctl_l2db_full_tc1_o = 1'b0;
  assign acpslv_tagctl_victim_way_tc1_o = {4{1'b0}};
  assign acpslv_tagctl_slverr_tc1_o = 1'b0;
  assign acpslv_hz_tc2_o = 1'b0;
  assign acpslv_hz_tc4_o = 1'b0;
  assign acpslv_l2_way_used_tc2_o = {16{1'b0}};
  assign acpslv_l2dbs_active_o = 1'b0;
  assign acpslv_l2db0_transfer_o = 1'b0;
  assign acpslv_l2db0_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db0_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db0_release_o = 1'b0;
  assign acpslv_l2db1_transfer_o = 1'b0;
  assign acpslv_l2db1_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db1_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db1_release_o = 1'b0;
  assign acpslv_l2db2_transfer_o = 1'b0;
  assign acpslv_l2db2_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db2_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db2_release_o = 1'b0;
  assign acpslv_l2db3_transfer_o = 1'b0;
  assign acpslv_l2db3_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db3_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db3_release_o = 1'b0;
  assign acpslv_l2db4_transfer_o = 1'b0;
  assign acpslv_l2db4_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db4_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db4_release_o = 1'b0;
  assign acpslv_l2db5_transfer_o = 1'b0;
  assign acpslv_l2db5_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db5_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db5_release_o = 1'b0;
  assign acpslv_l2db6_transfer_o = 1'b0;
  assign acpslv_l2db6_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db6_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db6_release_o = 1'b0;
  assign acpslv_l2db7_transfer_o = 1'b0;
  assign acpslv_l2db7_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db7_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db7_release_o = 1'b0;
  assign acpslv_l2db8_transfer_o = 1'b0;
  assign acpslv_l2db8_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db8_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db8_release_o = 1'b0;
  assign acpslv_l2db9_transfer_o = 1'b0;
  assign acpslv_l2db9_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db9_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db9_release_o = 1'b0;
  assign acpslv_l2db10_transfer_o = 1'b0;
  assign acpslv_l2db10_transfer_type_o = {3{1'b0}};
  assign acpslv_l2db10_transfer_info_o = {26{1'b0}};
  assign acpslv_l2db10_release_o = 1'b0;
  assign acpslv_early_dr_l2_o = 1'b0;
  assign acpslv_early_dr_index_o = {11{1'b0}};
  assign acpslv_early_dr_way_o = {4{1'b0}};
  assign acpslv_early_dr_ready_o = {16{1'b0}};
  assign acpslv_delay_allocation_o = {4{1'b0}};
  assign acpslv_master_dr_ready_o = 1'b0;
  assign acpslv_master_sactive_o = 1'b0;
  assign acpslv_l2db0_ready_o = 1'b0;
  assign acpslv_l2db1_ready_o = 1'b0;
  assign acpslv_l2db2_ready_o = 1'b0;
  assign acpslv_l2db3_ready_o = 1'b0;
  assign acpslv_l2db4_ready_o = 1'b0;
  assign acpslv_l2db5_ready_o = 1'b0;
  assign acpslv_l2db6_ready_o = 1'b0;
  assign acpslv_l2db7_ready_o = 1'b0;
  assign acpslv_l2db8_ready_o = 1'b0;
  assign acpslv_l2db9_ready_o = 1'b0;
  assign acpslv_l2db10_ready_o = 1'b0;
  assign acpslv_l2dbs_dw_valid_o = 1'b0;
  assign acpslv_l2dbs_dw_id_o = {4{1'b0}};
  assign acpslv_l2dbs_dw_chunk_o = {2{1'b0}};
  assign acpslv_l2dbs_dw_last_o = 1'b0;
  assign acpslv_l2dbs_dw_data_o = {128{1'b0}};
  assign acpslv_l2dbs_dw_strb_o = {16{1'b0}};
  assign acpslv_compack_active_o = 1'b0;
  assign acpslv_compack_valid_o = 1'b0;
  assign acpslv_compack_tgtid_o = {7{1'b0}};
  assign acpslv_compack_txnid_o = {8{1'b0}};
  assign acpslv_victimctl_active_o = 1'b0;
  assign acpslv_victimctl_valid_o = 1'b0;
  assign acpslv_victimctl_index_o = {11{1'b0}};
  assign acpslv_victimctl_wr_o = 1'b0;
  assign acpslv_victimctl_age_o = 1'b0;
  assign acpslv_victimctl_way_o = {4{1'b0}};
  assign acpslv_victimctl_id_o = {3{1'b0}};
  assign acpslv_l2_way_used_vc2_o = {16{1'b0}};
  assign acpslv_force_miss_tc2_o = {16{1'b0}};
  assign acpslv_ext_err_o = 1'b0;
end endgenerate


endmodule // ca53scu_acpslv

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_biu_scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
