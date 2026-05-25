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
//  The CPU slave interfaces between the SCU and a CPU. There is one CPUslv per
//  CPU. It buffers read and write data, and also keeps track of all requests
//  from the CPU in request buffers.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_scu_dcu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"


module ca53scu_cpuslv #(`CA53_SCU_INT_PARAM_DECL, parameter CPU_NUM = 2'b00)
 (
  input  wire                CLKIN,
  input  wire                clk,
  input  wire                reset_n,
  input  wire                DFTSE,

  input  wire                leaving_reset_i,
  input  wire                config_broadcastinner_i,
  input  wire                config_broadcastouter_i,
  input  wire                config_broadcastcachemaint_i,
  input  wire                config_sysbardisable_i,
  input  wire [2:0]          config_l1_dc_size_i,
  input  wire [3:0]          config_l2_size_i,
  input  wire                gov_enable_writeevict_i,
  input  wire                gov_l2_in_retention_i,

  output wire                cpuslv_active_o,
  output wire                cpuslv_wfx_active_o,

  input  wire                gov_inv_all_req_i,
  output wire                scu_inv_all_ack_o,

  // BIU interface
  input  wire                biu_ar_active_i,
  output wire                scu_ar_credit_o,
  output wire                scu_ar_block_o,
  input  wire                biu_ar_valid_i,
  input  wire [4:0]          biu_ar_id_i,
  input  wire [4:0]          biu_ar_type_i,
  input  wire [7:0]          biu_ar_attrs_i,
  input  wire [4:0]          biu_ar_way_i,
  input  wire [40:0]         biu_ar_addr_i,
  input  wire [1:0]          biu_ar_len_i,
  input  wire [2:0]          biu_ar_size_i,
  input  wire                biu_ar_lock_i,
  input  wire                biu_ar_priv_i,
  input  wire                biu_dr_credit_i,
  output wire                scu_dr_valid_o,
  output wire [4:0]          scu_dr_id_o,
  output wire [5:0]          scu_dr_resp_o,
  output wire [1:0]          scu_dr_chunk_o,
  output wire [127:0]        scu_dr_data_o,
  output wire                scu_rr_valid_o,
  output wire [4:0]          scu_rr_id_o,
  output wire [1:0]          scu_rr_resp_o,
  output wire [3:0]          scu_rr_l2db_id_o,
  output wire [7:0]          scu_ev_done_o,
  input  wire                biu_dw_valid_i,
  input  wire [3:0]          biu_dw_l2db_id_i,
  input  wire [3:0]          biu_dw_chunks_valid_i,
  input  wire                biu_dw_last_i,
  input  wire [31:0]         biu_dw_strb_i,
  input  wire [255:0]        biu_dw_data_i,
  input  wire                biu_dw_err_i,
  input  wire                biu_dw_fatal_i,
  output wire                scu_db_excl_valid_o,
  output wire [1:0]          scu_db_excl_resp_o,
  output wire                scu_db_decerr_o,
  output wire                scu_db_slverr_o,
  output wire                scu_leave_ramode_o,

  // L2 external flush request
  input  wire                l2flushreq_rs_i,
  output wire                cpuslv_l2flushdone_o,
  output wire                cpuslv_l2flush_active_o,
  input  wire [NUM_CPUS-1:0] gov_standbywfi_i,
  input  wire                acp_ainact_rs_i,
  input  wire                master_writes_active_i,

  // DCU snoop requests
  output wire                scu_ac_valid_o,
  input  wire                dcu_ac_ready_i,
  output wire [3:0]          scu_ac_snoop_o,
  output wire [2:0]          scu_ac_id_o,
  output wire [3:0]          scu_ac_l2db_id_o,
  output wire [40:0]         scu_ac_addr_o,
  output wire [3:0]          scu_ac_way_o,

  input  wire                dcu_cr_valid_i,
  input  wire [2:0]          dcu_cr_id_i,
  input  wire                dcu_cr_dirty_i,
  input  wire                dcu_cr_age_i,
  input  wire                dcu_cr_alloc_i,
  input  wire                dcu_cr_migratory_i,

  // Tagctl requests
  output wire                cpuslv_tagctl_valid_tc0_o,
  output wire                cpuslv_tagctl_early_valid_tc0_o,
  output wire                cpuslv_tagctl_spec_valid_tc0_o,
  input  wire                tagctl_cpuslv_ready_tc0_i,
  output wire [2:0]          cpuslv_tagctl_reqbufid_tc0_o,
  output wire [3:0]          cpuslv_tagctl_pass_tc0_o,
  output wire [40:0]         cpuslv_tagctl_addr1_tc0_o,
  output wire                cpuslv_tagctl_dvm_sync_tc0_o,
  output wire [16:0]         cpuslv_tagctl_wr_state_tc0_o,
  output wire [34:0]         cpuslv_tagctl_ecc_tc0_o,
  output wire [31:0]         cpuslv_tagctl_ways_tc0_o,
  output wire [4:0]          cpuslv_tagctl_write_tc0_o,
  output wire [4:0]          cpuslv_tagctl_type_tc0_o,
  output wire                cpuslv_tagctl_l2flushreq_tc0_o,
  output wire                cpuslv_tagctl_reqbuf_dcu_tc1_o,
  output wire [40:0]         cpuslv_tagctl_addr2_tc1_o,
  output wire [1:0]          cpuslv_tagctl_len_tc1_o,
  output wire [2:0]          cpuslv_tagctl_size_tc1_o,
  output wire                cpuslv_tagctl_lock_tc1_o,
  output wire                cpuslv_tagctl_dirty_tc1_o,
  output wire                cpuslv_tagctl_cluster_unique_tc1_o,
  output wire [7:0]          cpuslv_tagctl_attrs_tc1_o,
  output wire [1:0]          cpuslv_tagctl_prot_tc1_o,
  output wire [3:0]          cpuslv_tagctl_l2db_tc1_o,
  output wire                cpuslv_tagctl_l2db_full_tc1_o,
  output wire                cpuslv_tagctl_static_pcredit_tc1_o,
  output wire [1:0]          cpuslv_tagctl_pcrdtype_tc1_o,
  output wire [3:0]          cpuslv_tagctl_victim_way_tc1_o,
  output wire                cpuslv_inv_all_starting_o,
  input  wire                tagctl_cpuslv_noncoh_only_i,

  input  wire                tagctl_slv_flush_tc1_i,
  input  wire                tagctl_slv_flush_tc2_i,
  input  wire                tagctl_slv_flush_tc3_i,
  input  wire                tagctl_slv_flush_tc4_i,
  input  wire                tagctl_slv_early_flush_tc4_i,
  input  wire                tagctl_ecc_err_tc3_i,
  input  wire [3:0]          tagctl_slv_l2db_tc1_i,
  input  wire [3:0]          tagctl_slv_l2db_tc4_i,
  input  wire                tagctl_slv_snp_hz_tc4_i,
  input  wire [4:0]          tagctl_slv_snp_hz_id_tc4_i,
  input  wire                tagctl_slv_l2db_invalidated_tc4_i,
  input  wire                tagctl_slv_l2db_cleaned_tc4_i,
  input  wire [3:0]          tagctl_slv_victim_l2db_tc4_i,

  input  wire                afb0_done_i,
  input  wire                afb1_done_i,
  input  wire                afb2_done_i,
  input  wire                afb3_done_i,
  input  wire                afb4_done_i,
  input  wire                afb5_done_i,
  input  wire                afb0_snoop_resp_valid_i,
  input  wire                afb1_snoop_resp_valid_i,
  input  wire                afb2_snoop_resp_valid_i,
  input  wire                afb3_snoop_resp_valid_i,
  input  wire                afb4_snoop_resp_valid_i,
  input  wire                afb5_snoop_resp_valid_i,
  input  wire                afb0_snoop_resp_dirty_i,
  input  wire                afb1_snoop_resp_dirty_i,
  input  wire                afb2_snoop_resp_dirty_i,
  input  wire                afb3_snoop_resp_dirty_i,
  input  wire                afb4_snoop_resp_dirty_i,
  input  wire                afb5_snoop_resp_dirty_i,
  input  wire                afb0_snoop_resp_victim_valid_i,
  input  wire                afb1_snoop_resp_victim_valid_i,
  input  wire                afb2_snoop_resp_victim_valid_i,
  input  wire                afb3_snoop_resp_victim_valid_i,
  input  wire                afb4_snoop_resp_victim_valid_i,
  input  wire                afb5_snoop_resp_victim_valid_i,
  input  wire                afb0_snoop_resp_victim_dirty_i,
  input  wire                afb1_snoop_resp_victim_dirty_i,
  input  wire                afb2_snoop_resp_victim_dirty_i,
  input  wire                afb3_snoop_resp_victim_dirty_i,
  input  wire                afb4_snoop_resp_victim_dirty_i,
  input  wire                afb5_snoop_resp_victim_dirty_i,
  input  wire                afb0_snoop_resp_victim_age_i,
  input  wire                afb1_snoop_resp_victim_age_i,
  input  wire                afb2_snoop_resp_victim_age_i,
  input  wire                afb3_snoop_resp_victim_age_i,
  input  wire                afb4_snoop_resp_victim_age_i,
  input  wire                afb5_snoop_resp_victim_age_i,
  input  wire                afb0_snoop_resp_victim_alloc_i,
  input  wire                afb1_snoop_resp_victim_alloc_i,
  input  wire                afb2_snoop_resp_victim_alloc_i,
  input  wire                afb3_snoop_resp_victim_alloc_i,
  input  wire                afb4_snoop_resp_victim_alloc_i,
  input  wire                afb5_snoop_resp_victim_alloc_i,
  input  wire                afb0_snoop_resp_alloc_i,
  input  wire                afb1_snoop_resp_alloc_i,
  input  wire                afb2_snoop_resp_alloc_i,
  input  wire                afb3_snoop_resp_alloc_i,
  input  wire                afb4_snoop_resp_alloc_i,
  input  wire                afb5_snoop_resp_alloc_i,
  input  wire                afb0_snoop_resp_migratory_i,
  input  wire                afb1_snoop_resp_migratory_i,
  input  wire                afb2_snoop_resp_migratory_i,
  input  wire                afb3_snoop_resp_migratory_i,
  input  wire                afb4_snoop_resp_migratory_i,
  input  wire                afb5_snoop_resp_migratory_i,
  input  wire                afb0_write_done_i,
  input  wire                afb1_write_done_i,
  input  wire                afb2_write_done_i,
  input  wire                afb3_write_done_i,
  input  wire                afb4_write_done_i,
  input  wire                afb5_write_done_i,
  input  wire  [2:0]         tagctl_slv_afb_tc1_i,

  input  wire [41:6]         tagctl_addr_tc1_i,
  input  wire                tagctl_valid_tc1_i,
  input  wire                tagctl_addr_valid_tc1_i,
  input  wire                tagctl_index_valid_tc1_i,
  input  wire                tagctl_l1_set_way_op_tc1_i,
  input  wire                tagctl_l1_lf_tc1_i,
  input  wire                tagctl_serialising_tc1_i,
  input  wire                tagctl_ecc_wr_tc1_i,
  input  wire [15:0]         tagctl_ecc_way_tc1_i,
  input  wire [5:0]          tagctl_reqbufid_tc1_i,
  input  wire                tagctl_cpu_sync_tc1_i,
  input  wire                tagctl_snp_sync_tc1_i,
  output wire                cpuslv_hz_tc2_o,
  output wire                cpuslv_snp_hz_tc2_o,
  output wire [2:0]          cpuslv_snp_hz_id_tc2_o,
  output wire                cpuslv_snp_l2db_hz_tc2_o,
  output wire                cpuslv_snp_l2db_dirty_tc2_o,
  output wire [3:0]          cpuslv_snp_l2db_tc2_o,
  output wire                cpuslv_ecc_hz_tc2_o,
  output wire [31:0]         cpuslv_force_miss_tc2_o,
  output wire [15:0]         cpuslv_l2_way_used_tc2_o,
  input  wire [40:6]         tagctl_addr_tc3_i,
  input  wire                tagctl_addr_valid_tc3_i,
  input  wire [5:0]          tagctl_reqbufid_tc3_i,
  input  wire                tagctl_noncoh_serialised_tc3_i,
  input  wire [15:0]         tagctl_l1_hit_ways_tc3_i,
  input  wire [15:0]         tagctl_l2_hit_ways_tc3_i,
  input  wire                tagctl_l2_dirty_tc3_i,
  input  wire                tagctl_l2_alloc_tc3_i,
  input  wire [1:0]          tagctl_shareability_tc3_i,
  input  wire                tagctl_cluster_unique_tc3_i,
  input  wire                tagctl_l1_victim_cluster_unique_tc3_i,
  input  wire [1:0]          tagctl_l1_victim_shareability_tc3_i,
  input  wire                tagctl_l2_victim_valid_tc3_i,
  input  wire [1:0]          tagctl_l2_victim_shareability_tc3_i,
  input  wire                tagctl_l2_victim_alloc_tc3_i,
  input  wire                tagctl_l2_victim_cu_tc3_i,
  input  wire [3:0]          tagctl_l2_victim_way_tc3_i,
  input  wire [1:0]          tagctl_snoop_data_cpu_tc4_i,
  output wire                cpuslv_hz_tc4_o,
  output wire                scu_drain_stb_o,
  output wire                cpuslv_noncoh_since_barrier_o,
  output wire                cpuslv_dvm_sync_resp_o,
  input  wire                dvm_comp_sync_outstanding_i,

  input  wire                tagctl_cpuslv_ac_valid_i,
  output wire                cpuslv_ac_ready_o,
  input  wire [3:0]          tagctl_cpuslv_ac_snoop_i,
  input  wire [2:0]          tagctl_cpuslv_ac_id_i,
  input  wire [3:0]          tagctl_cpuslv_ac_l2db_id_i,
  input  wire [40:0]         tagctl_cpuslv_ac_addr_i,
  input  wire [3:0]          tagctl_cpuslv_ac_way_i,
  input  wire                tagctl_cpuslv_snp_active_i,

  output wire                cpuslv_cr_valid_o,
  output wire [2:0]          cpuslv_cr_id_o,
  output wire                cpuslv_cr_dirty_o,
  output wire                cpuslv_cr_age_o,
  output wire                cpuslv_cr_alloc_o,
  output wire                cpuslv_cr_migratory_o,

  // CompAck requests
  output wire                cpuslv_compack_active_o,
  output wire                cpuslv_compack_valid_o,
  output wire [6:0]          cpuslv_compack_tgtid_o,
  output wire [7:0]          cpuslv_compack_txnid_o,
  input  wire                snpslv_cpuslv_compack_ready_i,

  // Victimctl requests
  output wire                cpuslv_victimctl_active_o,
  output wire                cpuslv_victimctl_valid_o,
  output wire [10:0]         cpuslv_victimctl_index_o,
  output wire                cpuslv_victimctl_wr_o,
  output wire                cpuslv_victimctl_age_o,
  output wire                cpuslv_victimctl_iside_o,
  output wire                cpuslv_victimctl_nontemp_o,
  output wire [3:0]          cpuslv_victimctl_way_o,
  output wire [2:0]          cpuslv_victimctl_id_o,
  input  wire                victimctl_ready_i,
  input  wire [5:0]          victimctl_ready_id_i,

  input  wire                victimctl_ack_i,
  input  wire [5:0]          victimctl_ack_id_i,
  input  wire [3:0]          victimctl_victim_way_i,

  input  wire [10:0]         victimctl_index_vc1_i,
  output wire [15:0]         cpuslv_l2_way_used_vc2_o,

  // L2DB control
  output wire                cpuslv_l2dbs_active_o,
  output wire                cpuslv_ramctl_active_o,

  output wire                cpuslv_l2db0_transfer_o,
  output wire [2:0]          cpuslv_l2db0_transfer_type_o,
  output wire [23:0]         cpuslv_l2db0_transfer_info_o,
  output wire                cpuslv_l2db0_release_o,

  output wire                cpuslv_l2db1_transfer_o,
  output wire [2:0]          cpuslv_l2db1_transfer_type_o,
  output wire [23:0]         cpuslv_l2db1_transfer_info_o,
  output wire                cpuslv_l2db1_release_o,

  output wire                cpuslv_l2db2_transfer_o,
  output wire [2:0]          cpuslv_l2db2_transfer_type_o,
  output wire [23:0]         cpuslv_l2db2_transfer_info_o,
  output wire                cpuslv_l2db2_release_o,

  output wire                cpuslv_l2db3_transfer_o,
  output wire [2:0]          cpuslv_l2db3_transfer_type_o,
  output wire [23:0]         cpuslv_l2db3_transfer_info_o,
  output wire                cpuslv_l2db3_release_o,

  output wire                cpuslv_l2db4_transfer_o,
  output wire [2:0]          cpuslv_l2db4_transfer_type_o,
  output wire [23:0]         cpuslv_l2db4_transfer_info_o,
  output wire                cpuslv_l2db4_release_o,

  output wire                cpuslv_l2db5_transfer_o,
  output wire [2:0]          cpuslv_l2db5_transfer_type_o,
  output wire [23:0]         cpuslv_l2db5_transfer_info_o,
  output wire                cpuslv_l2db5_release_o,

  output wire                cpuslv_l2db6_transfer_o,
  output wire [2:0]          cpuslv_l2db6_transfer_type_o,
  output wire [23:0]         cpuslv_l2db6_transfer_info_o,
  output wire                cpuslv_l2db6_release_o,

  output wire                cpuslv_l2db7_transfer_o,
  output wire [2:0]          cpuslv_l2db7_transfer_type_o,
  output wire [23:0]         cpuslv_l2db7_transfer_info_o,
  output wire                cpuslv_l2db7_release_o,

  output wire                cpuslv_l2db8_transfer_o,
  output wire [2:0]          cpuslv_l2db8_transfer_type_o,
  output wire [23:0]         cpuslv_l2db8_transfer_info_o,
  output wire                cpuslv_l2db8_release_o,

  output wire                cpuslv_l2db9_transfer_o,
  output wire [2:0]          cpuslv_l2db9_transfer_type_o,
  output wire [23:0]         cpuslv_l2db9_transfer_info_o,
  output wire                cpuslv_l2db9_release_o,

  output wire                cpuslv_l2db10_transfer_o,
  output wire [2:0]          cpuslv_l2db10_transfer_type_o,
  output wire [23:0]         cpuslv_l2db10_transfer_info_o,
  output wire                cpuslv_l2db10_release_o,

  input  wire                l2db0_slv_done_i,
  input  wire                l2db1_slv_done_i,
  input  wire                l2db2_slv_done_i,
  input  wire                l2db3_slv_done_i,
  input  wire                l2db4_slv_done_i,
  input  wire                l2db5_slv_done_i,
  input  wire                l2db6_slv_done_i,
  input  wire                l2db7_slv_done_i,
  input  wire                l2db8_slv_done_i,
  input  wire                l2db9_slv_done_i,
  input  wire                l2db10_slv_done_i,

  input  wire                l2db0_full_line_i,
  input  wire                l2db1_full_line_i,
  input  wire                l2db2_full_line_i,
  input  wire                l2db3_full_line_i,
  input  wire                l2db4_full_line_i,
  input  wire                l2db5_full_line_i,
  input  wire                l2db6_full_line_i,
  input  wire                l2db7_full_line_i,
  input  wire                l2db8_full_line_i,
  input  wire                l2db9_full_line_i,
  input  wire                l2db10_full_line_i,

  input  wire                l2db0_rmw_line_i,
  input  wire                l2db1_rmw_line_i,
  input  wire                l2db2_rmw_line_i,
  input  wire                l2db3_rmw_line_i,
  input  wire                l2db4_rmw_line_i,
  input  wire                l2db5_rmw_line_i,
  input  wire                l2db6_rmw_line_i,
  input  wire                l2db7_rmw_line_i,
  input  wire                l2db8_rmw_line_i,
  input  wire                l2db9_rmw_line_i,
  input  wire                l2db10_rmw_line_i,

  input  wire                l2db0_cpuslv_data_active_i,
  input  wire                l2db1_cpuslv_data_active_i,
  input  wire                l2db2_cpuslv_data_active_i,
  input  wire                l2db3_cpuslv_data_active_i,
  input  wire                l2db4_cpuslv_data_active_i,
  input  wire                l2db5_cpuslv_data_active_i,
  input  wire                l2db6_cpuslv_data_active_i,
  input  wire                l2db7_cpuslv_data_active_i,
  input  wire                l2db8_cpuslv_data_active_i,
  input  wire                l2db9_cpuslv_data_active_i,
  input  wire                l2db10_cpuslv_data_active_i,

  // Master interface
  input  wire                master_early_dr_valid_i,
  input  wire [5:0]          master_early_dr_id_i,
  input  wire [7:0]          master_early_dr_dbid_i,
  input  wire [6:0]          master_early_dr_srcid_i,
  input  wire                master_early_dr_barrier_i,
  input  wire [3:0]          master_early_dr_resp_i,
  input  wire                master_early_dr_same_i,
  output wire                cpuslv_early_dr_l2_o,
  output wire [10:0]         cpuslv_early_dr_index_o,
  output wire [3:0]          cpuslv_early_dr_way_o,
  output wire [7:0]          cpuslv_early_dr_ready_o,
  output wire [7:0]          cpuslv_delay_allocation_o,

  input  wire                master_cpuslv_dr_valid_i,
  output wire                cpuslv_master_dr_ready_o,
  input  wire [5:0]          master_cpuslv_dr_id_i,
  input  wire [1:0]          master_dr_chunk_i,
  input  wire [127:0]        master_dr_data_i,
  input  wire [3:0]          master_dr_resp_i,

  input  wire                master_afb0_ack_i,
  input  wire                master_afb1_ack_i,
  input  wire                master_afb2_ack_i,
  input  wire                master_afb3_ack_i,
  input  wire                master_afb4_ack_i,
  input  wire                master_afb5_ack_i,
  input  wire [3:0]          master_afb_waddr_id_i,

  input  wire                master_cpuslv_waddrs_valid_i,
  input  wire                master_cpuslv_barrier_db_valid_i,
  input  wire                master_cpuslv_strex_db_valid_i,
  input  wire                master_cpuslv_dev_db_valid_i,
  input  wire [1:0]          master_db_resp_i,
  input  wire                master_db_waddr_valid_i,
  input  wire [3:0]          master_db_waddr_i,

  input  wire [7:0]          master_cpuslv_l2_waiting_i,

  input  wire                master_rsp_readreceipt_valid_i,
  input  wire                master_rsp_comp_valid_i,
  input  wire                master_rsp_dbid_valid_i,
  input  wire [6:0]          master_rsp_txnid_i,
  input  wire [7:0]          master_rsp_dbid_i,
  input  wire [6:0]          master_rsp_srcid_i,
  input  wire [3:0]          master_rsp_resp_i,

  input  wire [7:0]          master_cpuslv_reqbuf_retry_i,
  input  wire [1:0]          master_cpuslv_pcrdtype_i,
  output wire                cpuslv_master_sactive_o,
  output wire                cpuslv_sample_waddrs_o,
  output wire                cpuslv_sample_waddrs_dsb_o,
  output wire [7:0]          scu_reqbufs_busy_o,

  // L2DB read data
  input  wire                l2db0_slv_valid_i,
  input  wire [5:0]          l2db0_slv_id_i,
  input  wire [4:0]          l2db0_slv_biuid_i,
  input  wire [127:0]        l2db0_slv_data_i,
  input  wire [1:0]          l2db0_slv_chunk_i,
  input  wire                l2db0_slv_bypass_i,
  input  wire                l2db0_slv_err_i,
  output wire                cpuslv_l2db0_ready_o,

  input  wire                l2db1_slv_valid_i,
  input  wire [5:0]          l2db1_slv_id_i,
  input  wire [4:0]          l2db1_slv_biuid_i,
  input  wire [127:0]        l2db1_slv_data_i,
  input  wire [1:0]          l2db1_slv_chunk_i,
  input  wire                l2db1_slv_bypass_i,
  input  wire                l2db1_slv_err_i,
  output wire                cpuslv_l2db1_ready_o,

  input  wire                l2db2_slv_valid_i,
  input  wire [5:0]          l2db2_slv_id_i,
  input  wire [4:0]          l2db2_slv_biuid_i,
  input  wire [127:0]        l2db2_slv_data_i,
  input  wire [1:0]          l2db2_slv_chunk_i,
  input  wire                l2db2_slv_bypass_i,
  input  wire                l2db2_slv_err_i,
  output wire                cpuslv_l2db2_ready_o,

  input  wire                l2db3_slv_valid_i,
  input  wire [5:0]          l2db3_slv_id_i,
  input  wire [4:0]          l2db3_slv_biuid_i,
  input  wire [127:0]        l2db3_slv_data_i,
  input  wire [1:0]          l2db3_slv_chunk_i,
  input  wire                l2db3_slv_bypass_i,
  input  wire                l2db3_slv_err_i,
  output wire                cpuslv_l2db3_ready_o,

  input  wire                l2db4_slv_valid_i,
  input  wire [5:0]          l2db4_slv_id_i,
  input  wire [4:0]          l2db4_slv_biuid_i,
  input  wire [127:0]        l2db4_slv_data_i,
  input  wire [1:0]          l2db4_slv_chunk_i,
  input  wire                l2db4_slv_bypass_i,
  input  wire                l2db4_slv_err_i,
  output wire                cpuslv_l2db4_ready_o,

  input  wire                l2db5_slv_valid_i,
  input  wire [5:0]          l2db5_slv_id_i,
  input  wire [4:0]          l2db5_slv_biuid_i,
  input  wire [127:0]        l2db5_slv_data_i,
  input  wire [1:0]          l2db5_slv_chunk_i,
  input  wire                l2db5_slv_bypass_i,
  input  wire                l2db5_slv_err_i,
  output wire                cpuslv_l2db5_ready_o,

  input  wire                l2db6_slv_valid_i,
  input  wire [5:0]          l2db6_slv_id_i,
  input  wire [4:0]          l2db6_slv_biuid_i,
  input  wire [127:0]        l2db6_slv_data_i,
  input  wire [1:0]          l2db6_slv_chunk_i,
  input  wire                l2db6_slv_bypass_i,
  input  wire                l2db6_slv_err_i,
  output wire                cpuslv_l2db6_ready_o,

  input  wire                l2db7_slv_valid_i,
  input  wire [5:0]          l2db7_slv_id_i,
  input  wire [4:0]          l2db7_slv_biuid_i,
  input  wire [127:0]        l2db7_slv_data_i,
  input  wire [1:0]          l2db7_slv_chunk_i,
  input  wire                l2db7_slv_bypass_i,
  input  wire                l2db7_slv_err_i,
  output wire                cpuslv_l2db7_ready_o,

  input  wire                l2db8_slv_valid_i,
  input  wire [5:0]          l2db8_slv_id_i,
  input  wire [4:0]          l2db8_slv_biuid_i,
  input  wire [127:0]        l2db8_slv_data_i,
  input  wire [1:0]          l2db8_slv_chunk_i,
  input  wire                l2db8_slv_bypass_i,
  input  wire                l2db8_slv_err_i,
  output wire                cpuslv_l2db8_ready_o,

  input  wire                l2db9_slv_valid_i,
  input  wire [5:0]          l2db9_slv_id_i,
  input  wire [4:0]          l2db9_slv_biuid_i,
  input  wire [127:0]        l2db9_slv_data_i,
  input  wire [1:0]          l2db9_slv_chunk_i,
  input  wire                l2db9_slv_bypass_i,
  input  wire                l2db9_slv_err_i,
  output wire                cpuslv_l2db9_ready_o,

  input  wire                l2db10_slv_valid_i,
  input  wire [5:0]          l2db10_slv_id_i,
  input  wire [4:0]          l2db10_slv_biuid_i,
  input  wire [127:0]        l2db10_slv_data_i,
  input  wire [1:0]          l2db10_slv_chunk_i,
  input  wire                l2db10_slv_bypass_i,
  input  wire                l2db10_slv_err_i,
  output wire                cpuslv_l2db10_ready_o,

  // L2DB write data
  output wire                cpuslv_l2dbs_dw_valid_o,
  output wire [3:0]          cpuslv_l2dbs_dw_id_o,
  output wire [3:0]          cpuslv_l2dbs_dw_chunks_valid_o,
  output wire                cpuslv_l2dbs_dw_last_o,
  output wire [255:0]        cpuslv_l2dbs_dw_data_o,
  output wire [31:0]         cpuslv_l2dbs_dw_strb_o,
  output wire                cpuslv_l2dbs_dw_err_o,
  output wire                cpuslv_l2dbs_dw_fatal_o,

  // RAMCtl read bypass data
  input  wire [127:0]        ramctl_bypass_data_i,
  input  wire                ramctl_bypass_err_i,

  output wire                scu_evnt_eviction_o,
  output wire                scu_evnt_snooped_data_o,
  output wire                scu_evnt_l2_access_o,

  input  wire                gov_mbistreq_i
);

  localparam NUM_REQBUFS = 8;

generate if (CPU_NUM < NUM_CPUS) begin : g_cpuslv
  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  genvar i;
  genvar j;

  reg                                reqbuf_clk_enable;
  reg                                dr_clk_enable;
  reg                                snp_clk_enable;
  reg                                cpuslv_l2dbs_dw_valid;
  reg [3:0]                          cpuslv_l2dbs_dw_id;
  reg [3:0]                          cpuslv_l2dbs_dw_chunks_valid;
  reg                                cpuslv_l2dbs_dw_last;
  reg [255:0]                        cpuslv_l2dbs_dw_data;
  reg [31:0]                         cpuslv_l2dbs_dw_strb;
  reg                                cpuslv_l2dbs_dw_err;
  reg                                cpuslv_l2dbs_dw_fatal;
  reg                                scu_ar_credit;
  reg                                dr_credit;
  reg [2:0]                          dr_credits_used;
  reg                                scu_dr_early_valid;
  reg [4:0]                          scu_dr_id;
  reg [5:0]                          scu_dr_resp;
  reg [1:0]                          scu_dr_chunk;
  reg [127:0]                        scu_dr_data;
  reg                                scu_rr_valid;
  reg [4:0]                          scu_rr_id;
  reg [1:0]                          scu_rr_resp;
  reg [3:0]                          scu_rr_l2db_id;
  reg [NUM_REQBUFS-1:0]              tagctl_prearb_tc0;
  reg [NUM_REQBUFS-1:0]              tagctl_prearb_mask;
  reg [NUM_REQBUFS-1:0]              reqbuf_arb_tc1;
  reg                                tagctl_prearb_primary;
  reg                                cpuslv_hz_tc2;
  reg                                cpuslv_hz_tc4;
  reg                                cpuslv_ecc_err_tc4;
  reg                                scu_drain_stb;
  reg                                scu_ac_valid;
  reg [3:0]                          scu_ac_snoop;
  reg [2:0]                          scu_ac_id;
  reg [3:0]                          scu_ac_l2db_id;
  reg [40:0]                         scu_ac_addr;
  reg [3:0]                          scu_ac_way;
  reg                                cpuslv_cr_valid;
  reg [2:0]                          cpuslv_cr_id;
  reg                                cpuslv_cr_dirty;
  reg                                cpuslv_cr_age;
  reg                                cpuslv_cr_alloc;
  reg                                cpuslv_cr_migratory;
  reg [7:0]                          scu_ev_done;
  reg                                scu_leave_ramode;
  reg                                scu_db_excl_valid;
  reg                                scu_db_dev_valid;
  reg [1:0]                          scu_db_dev_excl_resp;
  reg                                cpuslv_tagctl_spec_valid_tc0;
  reg                                cpuslv_inv_all_pending;
  reg                                scu_inv_all_ack;
  reg                                cpuslv_noncoh_only;
  reg [NUM_L2DBS-1:0]                l2db_buf_release;
  reg                                cpuslv_snp_hz_tc2;
  reg [2:0]                          cpuslv_snp_hz_id_tc2;
  reg                                cpuslv_snp_l2db_hz_tc2;
  reg                                cpuslv_snp_l2db_dirty_tc2;
  reg [3:0]                          cpuslv_snp_l2db_tc2;
  reg                                cpuslv_ecc_hz_tc2;
  reg [(L2_CACHE?31:15):0]           cpuslv_force_miss_tc2;
  reg [15:0]                         cpuslv_l2_way_used_tc2;
  reg [15:0]                         cpuslv_l2_way_used_vc2;
  reg                                cpuslv_enable_writeevict;
  reg                                reqbuf_allocated;
  reg [6:0]                          reqbufs_l1_addr_partial_ecc_tc0;
  reg [6:0]                          reqbufs_l2_ecc_tc0;
  reg [10:0]                         l2_flush_index;
  reg [3:0]                          l2_flush_way;
  reg                                l2_flush_active;
  reg                                l2_flush_block;
  reg                                l2_flush_done;
  reg                                l2_flush_ended;
  reg                                cpuslv_noncoh_since_dsb;
  reg                                cpuslv_noncoh_since_dmb;
  reg                                scu_evnt_eviction;
  reg                                scu_evnt_snooped_data;
  reg                                scu_evnt_l2_access;
  reg                                scu_db_decerr;
  reg                                scu_db_slverr;
  reg                                cpuslv_broadcastinner;
  reg                                cpuslv_broadcastouter;
  reg                                cpuslv_broadcastcachemaint;
  reg [2:0]                          cpuslv_l1_dc_size;
  reg [3:0]                          cpuslv_l2_size;
  reg                                cpuslv_mbistreq;
  reg [NUM_REQBUFS-1:0]              reqbuf_compack_ready;

  wire                               clk_reqbufs;
  wire                               clk_dr;
  wire                               clk_snp;
  wire                               next_reqbuf_clk_enable;
  wire                               next_dr_clk_enable;
  wire                               next_snp_clk_enable;
  wire                               reqbufs_active;
  wire [MAX_L2DBS:0]                 dr_req;
  wire [MAX_L2DBS:0]                 dr_arb;
  wire                               dr_arb_req;
  wire [4:0]                         master_dr_biu_id;
  wire [3:0]                         l2db_dr_resp [MAX_L2DBS-1:0];
  wire [4:0]                         next_scu_dr_id;
  wire [5:0]                         next_scu_dr_resp;
  wire [1:0]                         next_scu_dr_chunk;
  wire                               next_scu_dr_bypass;
  wire [127:0]                       next_scu_dr_data;
  wire [MAX_L2DBS:0]                 dr_ready;
  wire                               scu_dr_valid;
  wire                               block_dr_arb;
  wire                               next_scu_dr_early_valid;
  wire                               scu_dr_en;
  wire                               next_scu_rr_valid;
  wire                               dr_arb_en;
  wire                               scu_db_dev_excl_en;
  wire                               cpuslv_hz_tc1;
  wire                               cpuslv_hz_tc3;
  wire                               next_scu_drain_stb;
  wire [NUM_REQBUFS-1:0]             reqbuf_enable;
  wire [NUM_REQBUFS-1:0]             reqbuf_spec_enable;
  wire [NUM_REQBUFS-1:0]             reqbuf_lowest_unused;
  wire [NUM_REQBUFS-1:0]             reqbuf_second_lowest_unused;
  wire [NUM_REQBUFS-1:0]             reqbuf_next_unused;
  wire [NUM_REQBUFS-1:0]             reqbuf_alloc;
  wire [NUM_REQBUFS-1:0]             reqbuf_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_busy;
  wire [NUM_REQBUFS-1:0]             reqbuf_dvm_part_two;
  wire [`CA53_LOG2(NUM_REQBUFS)-1:0] reqbuf_alloc_enc;
  wire [NUM_REQBUFS:0]               tagctl_arb_tc0;
  wire [NUM_REQBUFS-1:0]             tagctl_sel_prearb_tc0;
  wire [NUM_REQBUFS-1:0]             next_reqbuf_arb_tc1;
  wire                               reqbuf_arb_tc1_en;
  wire [2*NUM_REQBUFS-1:0]           l2db_transfer      [MAX_L2DBS-1:0];
  wire [2:0]                         l2db_transfer_type [MAX_L2DBS-1:0];
  wire [23:0]                        l2db_transfer_info [MAX_L2DBS-1:0];
  wire [2*NUM_REQBUFS-1:0]           l2db_release       [MAX_L2DBS-1:0];
  wire [NUM_REQBUFS-1:0]             l2db_release_tc3   [MAX_L2DBS-1:0];
  wire [NUM_L2DBS-1:0]               next_l2db_buf_release;
  wire [MAX_L2DBS-1:0]               cpuslv_l2db_release;
  wire                               cpuslv_tagctl_early_valid_tc0;
  wire [31:0]                        new_req_ways_tc0;
  wire                               cpuslv_master_dr_ready;
  wire                               cpuslv_suppress_dr;
  wire [3:0]                         reqbufs_tagctl_pass_tc0;
  wire [40:0]                        reqbufs_tagctl_addr1_tc0;
  wire [16:0]                        cpuslv_tagctl_wr_state_tc0;
  wire [27:0]                        l1_state_partial_ecc_tc0;
  wire [NUM_REQBUFS-1:0]             reqbuf_rr_valid;
  wire [NUM_REQBUFS-1:0]             reqbuf_rr_cancel;
  wire [NUM_REQBUFS-1:0]             reqbuf_rr_ready;
  wire [3:0]                         reqbuf_rr_l2db_id [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_rr_resp [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_dr_resp [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS*NUM_REQBUFS-1:0] reqbuf_older_pkd;
  wire                               tagctl_prearb_en;
  wire                               next_tagctl_prearb_primary;
  wire [NUM_REQBUFS-1:0]             tagctl_prearb;
  wire [NUM_REQBUFS-1:0]             next_tagctl_prearb_mask;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_primary;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_victim;
  wire [NUM_REQBUFS-1:0]             reqbuf_keep_order;
  wire [NUM_REQBUFS-1:0]             reqbuf_dvm;
  wire [NUM_REQBUFS-1:0]             reqbuf_dvm_sync;
  wire [NUM_REQBUFS-1:0]             reqbuf_coh;
  wire [NUM_REQBUFS-1:0]             reqbuf_noncoh_only;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_valid_tc0;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_req;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_pri1;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_prearb_pri2;
  wire [NUM_REQBUFS-1:0]             reqbuf_tagctl_primary_tc0;
  wire [NUM_REQBUFS-1:0]             reqbuf_update_primary_pass;
  wire [NUM_REQBUFS-1:0]             reqbuf_update_victim_pass;
  wire [NUM_REQBUFS-1:0]             reqbuf_ar_return_credit;
  wire [NUM_REQBUFS-1:0]             reqbuf_ar_credit_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_hz_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_snp_hz_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_snp_l2db_hz_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_snp_l2db_dirty_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_ecc_hz_tc1;
  wire [NUM_REQBUFS-1:0]             reqbuf_ext_decerr;
  wire [NUM_REQBUFS-1:0]             reqbuf_ext_slverr;
  wire                               next_scu_db_decerr;
  wire                               next_scu_db_slverr;
  wire [31:0]                        reqbuf_force_miss_tc1               [NUM_REQBUFS-1:0];
  wire [15:0]                        reqbuf_l2_way_used_tc1              [NUM_REQBUFS-1:0];
  wire [15:0]                        reqbuf_l2_way_used_vc1              [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_hz_tc3;
  wire [NUM_REQBUFS-1:0]             reqbuf_drain_stb;
  wire [NUM_REQBUFS-1:0]             reqbuf_l2dbs_active;
  wire [3:0]                         reqbuf_tagctl_pass_tc0              [NUM_REQBUFS-1:0];
  wire [40:0]                        reqbuf_tagctl_addr1_tc0             [NUM_REQBUFS-1:0];
  wire [16:0]                        reqbuf_tagctl_wr_state_tc0          [NUM_REQBUFS-1:0];
  wire [40:0]                        reqbuf_addr2                        [NUM_REQBUFS-1:0];
  wire [31:0]                        reqbuf_tagctl_ways_tc0              [NUM_REQBUFS-1:0];
  wire [4:0]                         reqbuf_tagctl_write_tc0             [NUM_REQBUFS-1:0];
  wire [4:0]                         reqbuf_type                         [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2flushreq                   [NUM_REQBUFS-1:0];
  wire                               reqbuf_dcu                          [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_len                          [NUM_REQBUFS-1:0];
  wire [2:0]                         reqbuf_size                         [NUM_REQBUFS-1:0];
  wire                               reqbuf_lock                         [NUM_REQBUFS-1:0];
  wire                               reqbuf_dirty                        [NUM_REQBUFS-1:0];
  wire                               reqbuf_cluster_unique               [NUM_REQBUFS-1:0];
  wire [7:0]                         reqbuf_attrs                        [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_prot                         [NUM_REQBUFS-1:0];
  wire [4:0]                         reqbuf_biu_id                       [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_full                    [NUM_REQBUFS-1:0];
  wire                               reqbuf_static_pcredit_tc1           [NUM_REQBUFS-1:0];
  wire [1:0]                         reqbuf_pcrdtype_tc1                 [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_victim_way_tc1               [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_tc1                     [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_primary_transfer        [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_primary_id              [NUM_REQBUFS-1:0];
  wire [2:0]                         reqbuf_l2db_primary_transfer_type   [NUM_REQBUFS-1:0];
  wire [23:0]                        reqbuf_l2db_primary_transfer_info   [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_primary_release         [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_primary_dr_valid        [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_victim_transfer         [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_l2db_victim_id               [NUM_REQBUFS-1:0];
  wire [2:0]                         reqbuf_l2db_victim_transfer_type    [NUM_REQBUFS-1:0];
  wire [23:0]                        reqbuf_l2db_victim_transfer_info    [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_victim_release          [NUM_REQBUFS-1:0];
  wire                               reqbuf_l2db_victim_release_tc3      [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_early_dr_l2;
  wire [10:0]                        reqbuf_early_dr_index               [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_early_dr_way                 [NUM_REQBUFS-1:0];
  wire [7:0]                         reqbuf_ev_done_id                   [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_ev_done;
  wire [NUM_REQBUFS-1:0]             reqbuf_leave_ramode;
  wire [NUM_REQBUFS-1:0]             reqbuf_suppress_dr;
  wire [NUM_REQBUFS-1:0]             reqbuf_suppress_early_dr;
  wire [NUM_REQBUFS-1:0]             reqbuf_ramctl_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_dmb_resp;
  wire [NUM_REQBUFS-1:0]             reqbuf_dsb_resp;
  wire [NUM_REQBUFS-1:0]             reqbuf_sample_waddrs;
  wire [NUM_REQBUFS-1:0]             reqbuf_sample_waddrs_dsb;
  wire [NUM_REQBUFS-1:0]             reqbuf_dvm_sync_busy;
  wire                               next_cpuslv_noncoh_since_dsb;
  wire                               next_cpuslv_noncoh_since_dmb;
  wire                               ac_en;
  wire                               next_scu_ac_valid;
  wire [7:0]                         next_scu_ev_done;
  wire                               scu_ev_done_en;
  wire                               next_scu_leave_ramode;
  wire                               next_scu_ar_credit;
  wire [2:0]                         next_dr_credits_used;
  wire                               dr_credits_used_en;
  wire                               dr_credit_available;
  wire                               next_cpuslv_noncoh_only;
  wire                               next_cpuslv_inv_all_pending;
  wire [4:0]                         next_scu_rr_id;
  wire [1:0]                         next_scu_rr_resp;
  wire [3:0]                         next_scu_rr_l2db_id;
  wire                               cpuslv_snp_hz_tc1;
  wire [2:0]                         cpuslv_snp_hz_id_tc1;
  wire                               cpuslv_snp_l2db_hz_tc1;
  wire                               cpuslv_snp_l2db_dirty_tc1;
  wire [3:0]                         cpuslv_snp_l2db_tc1;
  wire                               cpuslv_ecc_hz_tc1;
  wire [31:0]                        cpuslv_force_miss_tc1;
  wire [15:0]                        cpuslv_l2_way_used_tc1;
  wire [15:0]                        cpuslv_l2_way_used_vc1;
  wire                               dvm_part_two;
  wire                               can_alloc;
  wire                               cpuslv_wfx_active;
  wire                               cpuslv_inv_all_starting;
  wire                               zero;
  wire [40:0]                        reqbufs_prearb_addr;
  wire [NUM_REQBUFS-1:0]             reqbuf_ext_strex;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_arb;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_valid;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_ready;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_wr;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_age;
  wire [NUM_REQBUFS-1:0]             reqbuf_victimctl_nontemp;
  wire [10:0]                        reqbuf_victimctl_index [NUM_REQBUFS-1:0];
  wire [3:0]                         reqbuf_victimctl_way   [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_active;
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_valid;
  wire [NUM_REQBUFS-1:0]             next_reqbuf_compack_ready;
  wire                               reqbuf_compack_ready_en;
  wire [NUM_REQBUFS-1:0]             reqbuf_compack_arb;
  wire [6:0]                         reqbuf_compack_tgtid [NUM_REQBUFS-1:0];
  wire [7:0]                         reqbuf_compack_txnid [NUM_REQBUFS-1:0];
  wire                               strex_comp_valid;
  wire [1:0]                         next_scu_db_dev_excl_resp;
  wire                               next_scu_db_excl_valid;
  wire                               next_reqbuf_allocated;
  wire [10:0]                        next_l2_flush_index;
  wire [3:0]                         next_l2_flush_way;
  wire                               l2_flush_index_en;
  wire                               l2_flush_way_en;
  wire                               next_l2_flush_active;
  wire                               next_l2_flush_block;
  wire                               next_l2_flush_done;
  wire                               next_l2_flush_ended;
  wire                               l2_flush_way_end;
  wire                               l2_flush_end;
  wire                               l2_flush_allowed;
  wire                               flush_ready;
  wire                               l2_flush_req;
  wire                               start_l2_flush;
  wire                               l2_flush_index_end;
  wire                               ar_valid;
  wire [4:0]                         ar_id;
  wire [4:0]                         ar_type;
  wire [40:0]                        ar_addr;
  wire                               next_scu_evnt_eviction;
  wire                               next_scu_evnt_snooped_data;
  wire                               next_scu_evnt_l2_access;
  wire [NUM_REQBUFS-1:0]             reqbuf_evnt_snooped_data;
  wire [NUM_REQBUFS-1:0]             reqbuf_evnt_l2_access;


  // Tie off for configurable logic
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  // Regional clock gates
  //----------------------------------------------------------------------------

  // Avoid clocking the request buffers and response channel if they are all idle.
  assign reqbufs_active = (cpuslv_tagctl_spec_valid_tc0 |
                           (|reqbuf_active) | scu_ar_credit |
                           scu_rr_valid |
                           leaving_reset_i |
                           l2_flush_active | l2_flush_ended |
                           l2_flush_done | l2_flush_req);

  assign next_reqbuf_clk_enable = (reqbufs_active |
                                   biu_ar_valid_i |
                                   biu_ar_active_i |
                                   gov_mbistreq_i |
                                   gov_inv_all_req_i);

  assign next_dr_clk_enable = ((|reqbuf_active) |
                               scu_dr_early_valid |
                               (|dr_credits_used) |
                               gov_mbistreq_i);

  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    reqbuf_clk_enable <= 1'b1;
    dr_clk_enable     <= 1'b1;
  end else begin
    reqbuf_clk_enable <= next_reqbuf_clk_enable;
    dr_clk_enable     <= next_dr_clk_enable;
  end

  // This gate uses CLKIN rather than clk because clk may not be active on the
  // first cycle as it only factors the registered biu_ar_active into its enable,
  // whereas the cpuslv needs the unregistered active signal.
  ca53_cell_inter_clkgate u_inter_clkgate_reqbufs (
    .clk_i         (CLKIN),
    .clk_enable_i  (reqbuf_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_reqbufs));

  ca53_cell_inter_clkgate u_inter_clkgate_dr (
    .clk_i         (clk),
    .clk_enable_i  (dr_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_dr));

  // The main SCU clock gate must be enabled if there is anything in or entering
  // the request buffers. Responses can also remain after the reqbuf has completed.
  assign cpuslv_wfx_active = (|reqbuf_active |
                              cpuslv_tagctl_spec_valid_tc0 |
                              scu_dr_early_valid |
                              scu_rr_valid |
                              scu_ac_valid |
                              scu_db_excl_valid |
                              scu_db_dev_valid |
                              cpuslv_inv_all_pending);

  assign cpuslv_wfx_active_o = cpuslv_wfx_active;

  assign cpuslv_active_o = (cpuslv_wfx_active |
                            reqbuf_clk_enable |
                            dr_clk_enable |
                            l2_flush_active |
                            l2_flush_ended |
                            l2_flush_done);

  assign next_snp_clk_enable = (gov_mbistreq_i |
                                scu_ac_valid |
                                tagctl_cpuslv_snp_active_i |
                                l2db0_cpuslv_data_active_i |
                                l2db1_cpuslv_data_active_i |
                                l2db2_cpuslv_data_active_i |
                                l2db3_cpuslv_data_active_i |
                                l2db4_cpuslv_data_active_i |
                                l2db5_cpuslv_data_active_i |
                                l2db6_cpuslv_data_active_i |
                                l2db7_cpuslv_data_active_i |
                                l2db8_cpuslv_data_active_i |
                                l2db9_cpuslv_data_active_i |
                                l2db10_cpuslv_data_active_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    snp_clk_enable <= 1'b1;
  end else begin
    snp_clk_enable <= next_snp_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_snp (
    .clk_i         (clk),
    .clk_enable_i  (snp_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_snp));

  // Reregister some config signals locally to help timing.
  always @(posedge clk_reqbufs)
  if (leaving_reset_i) begin
    cpuslv_broadcastinner      <= config_broadcastinner_i;
    cpuslv_broadcastouter      <= config_broadcastouter_i;
    cpuslv_broadcastcachemaint <= config_broadcastcachemaint_i;
    cpuslv_l1_dc_size          <= config_l1_dc_size_i;
  end

  if (L2_CACHE) begin : g_l2cc

    always @(posedge clk_reqbufs)
    if (leaving_reset_i) begin
      cpuslv_l2_size <= config_l2_size_i;
    end

  end else begin : g_n_l2cc

    always @*
      cpuslv_l2_size = {4{zero}};

  end

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    cpuslv_mbistreq <= 1'b0;
  end else if (leaving_reset_i) begin
    cpuslv_mbistreq <= gov_mbistreq_i;
  end

  //----------------------------------------------------------------------------
  //  Write data buffer
  //----------------------------------------------------------------------------

  always @(posedge clk_snp or negedge reset_n)
  if (~reset_n) begin
    cpuslv_l2dbs_dw_valid <= 1'b0;
  end else begin
    cpuslv_l2dbs_dw_valid <= biu_dw_valid_i;
  end

  always @(posedge clk_snp)
  if (biu_dw_valid_i) begin
    cpuslv_l2dbs_dw_id           <= biu_dw_l2db_id_i;
    cpuslv_l2dbs_dw_chunks_valid <= biu_dw_chunks_valid_i;
    cpuslv_l2dbs_dw_last         <= biu_dw_last_i;
    cpuslv_l2dbs_dw_data         <= biu_dw_data_i;
    cpuslv_l2dbs_dw_strb         <= biu_dw_strb_i;
    cpuslv_l2dbs_dw_err          <= biu_dw_err_i;
  end

  // The fatal error indication arrives a cycle after the data.
  always @(posedge clk_snp)
  begin
    cpuslv_l2dbs_dw_fatal <= biu_dw_fatal_i;
  end

  assign cpuslv_l2dbs_dw_valid_o        = cpuslv_l2dbs_dw_valid;
  assign cpuslv_l2dbs_dw_id_o           = cpuslv_l2dbs_dw_id;
  assign cpuslv_l2dbs_dw_chunks_valid_o = cpuslv_l2dbs_dw_chunks_valid;
  assign cpuslv_l2dbs_dw_last_o         = cpuslv_l2dbs_dw_last;
  assign cpuslv_l2dbs_dw_data_o         = cpuslv_l2dbs_dw_data;
  assign cpuslv_l2dbs_dw_strb_o         = cpuslv_l2dbs_dw_strb;
  assign cpuslv_l2dbs_dw_err_o          = cpuslv_l2dbs_dw_err;
  assign cpuslv_l2dbs_dw_fatal_o        = cpuslv_l2dbs_dw_fatal;

  //----------------------------------------------------------------------------
  //  Read data buffer
  //----------------------------------------------------------------------------

  assign dr_req = {l2db10_slv_valid_i & (l2db10_slv_id_i[5:3] == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db9_slv_valid_i  & (l2db9_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db8_slv_valid_i  & (l2db8_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db7_slv_valid_i  & (l2db7_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db6_slv_valid_i  & (l2db6_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db5_slv_valid_i  & (l2db5_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db4_slv_valid_i  & (l2db4_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db3_slv_valid_i  & (l2db3_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db2_slv_valid_i  & (l2db2_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db1_slv_valid_i  & (l2db1_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   l2db0_slv_valid_i  & (l2db0_slv_id_i[5:3]  == {1'b0, CPU_NUM[1:0]}) & ~cpuslv_mbistreq,
                   master_cpuslv_dr_valid_i | cpuslv_mbistreq};

  assign dr_arb_req = |dr_req;

  // Select between dr requests on a round robin basis.
  assign dr_arb_en = dr_arb_req & dr_credit_available;

  ca53_rr_reg_arb #(.WIDTH(NUM_L2DBS + 1)) u_dr_arb (
    .clk        (clk_dr),
    .reset_n    (reset_n),
    .enable_i   (dr_arb_en),
    .requests_i (dr_req[NUM_L2DBS:0]),
    .arb_o      (dr_arb[NUM_L2DBS:0])
  );

  for (i = NUM_L2DBS + 1; i < MAX_L2DBS + 1; i = i + 1) begin : g_dr_arb
    assign dr_arb[i] = 1'b0;
  end

  // Find the original BIU id for the master request as stored in the controlling reqbuf.
  assign master_dr_biu_id = (({5{master_cpuslv_dr_id_i[2:0] == 3'b111}} & reqbuf_biu_id[7]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b110}} & reqbuf_biu_id[6]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b101}} & reqbuf_biu_id[5]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b100}} & reqbuf_biu_id[4]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b011}} & reqbuf_biu_id[3]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b010}} & reqbuf_biu_id[2]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b001}} & reqbuf_biu_id[1]) |
                             ({5{master_cpuslv_dr_id_i[2:0] == 3'b000}} & reqbuf_biu_id[0]));

  // The L2DBs store and provide the BIU ID so that we don't have to look up in
  // the reqbuf for it here.
  assign next_scu_dr_id = (({5{dr_arb[11]}} & l2db10_slv_biuid_i) |
                           ({5{dr_arb[10]}} & l2db9_slv_biuid_i)  |
                           ({5{dr_arb[9]}}  & l2db8_slv_biuid_i)  |
                           ({5{dr_arb[8]}}  & l2db7_slv_biuid_i)  |
                           ({5{dr_arb[7]}}  & l2db6_slv_biuid_i)  |
                           ({5{dr_arb[6]}}  & l2db5_slv_biuid_i)  |
                           ({5{dr_arb[5]}}  & l2db4_slv_biuid_i)  |
                           ({5{dr_arb[4]}}  & l2db3_slv_biuid_i)  |
                           ({5{dr_arb[3]}}  & l2db2_slv_biuid_i)  |
                           ({5{dr_arb[2]}}  & l2db1_slv_biuid_i)  |
                           ({5{dr_arb[1]}}  & l2db0_slv_biuid_i)  |
                           ({5{dr_arb[0]}}  & master_dr_biu_id));

  // Find the response for requests returning data from an L2DB.
  for (i = 0; i < MAX_L2DBS; i = i + 1) begin : g_l2db_resp
    if (i < NUM_L2DBS) begin : g_l2db
      assign l2db_dr_resp[i] = (({4{reqbuf_l2db_primary_dr_valid[7] & (reqbuf_l2db_primary_id[7] == i[3:0])}} & reqbuf_dr_resp[7]) |
                                ({4{reqbuf_l2db_primary_dr_valid[6] & (reqbuf_l2db_primary_id[6] == i[3:0])}} & reqbuf_dr_resp[6]) |
                                ({4{reqbuf_l2db_primary_dr_valid[5] & (reqbuf_l2db_primary_id[5] == i[3:0])}} & reqbuf_dr_resp[5]) |
                                ({4{reqbuf_l2db_primary_dr_valid[4] & (reqbuf_l2db_primary_id[4] == i[3:0])}} & reqbuf_dr_resp[4]) |
                                ({4{reqbuf_l2db_primary_dr_valid[3] & (reqbuf_l2db_primary_id[3] == i[3:0])}} & reqbuf_dr_resp[3]) |
                                ({4{reqbuf_l2db_primary_dr_valid[2] & (reqbuf_l2db_primary_id[2] == i[3:0])}} & reqbuf_dr_resp[2]) |
                                ({4{reqbuf_l2db_primary_dr_valid[1] & (reqbuf_l2db_primary_id[1] == i[3:0])}} & reqbuf_dr_resp[1]) |
                                ({4{reqbuf_l2db_primary_dr_valid[0] & (reqbuf_l2db_primary_id[0] == i[3:0])}} & reqbuf_dr_resp[0]));
    end else begin : g_no_l2db
      assign l2db_dr_resp[i] = 4'b0000;
    end
  end

  assign next_scu_dr_resp = (({6{dr_arb[11]}} & {1'b1, l2db10_slv_err_i, l2db_dr_resp[10]}) |
                             ({6{dr_arb[10]}} & {1'b1, l2db9_slv_err_i,  l2db_dr_resp[9]})  |
                             ({6{dr_arb[9]}}  & {1'b1, l2db8_slv_err_i,  l2db_dr_resp[8]})  |
                             ({6{dr_arb[8]}}  & {1'b1, l2db7_slv_err_i,  l2db_dr_resp[7]})  |
                             ({6{dr_arb[7]}}  & {1'b1, l2db6_slv_err_i,  l2db_dr_resp[6]})  |
                             ({6{dr_arb[6]}}  & {1'b1, l2db5_slv_err_i,  l2db_dr_resp[5]})  |
                             ({6{dr_arb[5]}}  & {1'b1, l2db4_slv_err_i,  l2db_dr_resp[4]})  |
                             ({6{dr_arb[4]}}  & {1'b1, l2db3_slv_err_i,  l2db_dr_resp[3]})  |
                             ({6{dr_arb[3]}}  & {1'b1, l2db2_slv_err_i,  l2db_dr_resp[2]})  |
                             ({6{dr_arb[2]}}  & {1'b1, l2db1_slv_err_i,  l2db_dr_resp[1]})  |
                             ({6{dr_arb[1]}}  & {1'b1, l2db0_slv_err_i,  l2db_dr_resp[0]})  |
                             ({6{dr_arb[0]}}  & {2'b00, master_dr_resp_i}));

  assign next_scu_dr_chunk = (({2{dr_arb[11]}} & l2db10_slv_chunk_i) |
                              ({2{dr_arb[10]}} & l2db9_slv_chunk_i)  |
                              ({2{dr_arb[9]}}  & l2db8_slv_chunk_i)  |
                              ({2{dr_arb[8]}}  & l2db7_slv_chunk_i)  |
                              ({2{dr_arb[7]}}  & l2db6_slv_chunk_i)  |
                              ({2{dr_arb[6]}}  & l2db5_slv_chunk_i)  |
                              ({2{dr_arb[5]}}  & l2db4_slv_chunk_i)  |
                              ({2{dr_arb[4]}}  & l2db3_slv_chunk_i)  |
                              ({2{dr_arb[3]}}  & l2db2_slv_chunk_i)  |
                              ({2{dr_arb[2]}}  & l2db1_slv_chunk_i)  |
                              ({2{dr_arb[1]}}  & l2db0_slv_chunk_i)  |
                              ({2{dr_arb[0]}}  & master_dr_chunk_i));

  assign next_scu_dr_bypass = ((dr_arb[11] & l2db10_slv_bypass_i) |
                               (dr_arb[10] & l2db9_slv_bypass_i)  |
                               (dr_arb[9]  & l2db8_slv_bypass_i)  |
                               (dr_arb[8]  & l2db7_slv_bypass_i)  |
                               (dr_arb[7]  & l2db6_slv_bypass_i)  |
                               (dr_arb[6]  & l2db5_slv_bypass_i)  |
                               (dr_arb[5]  & l2db4_slv_bypass_i)  |
                               (dr_arb[4]  & l2db3_slv_bypass_i)  |
                               (dr_arb[3]  & l2db2_slv_bypass_i)  |
                               (dr_arb[2]  & l2db1_slv_bypass_i)  |
                               (dr_arb[1]  & l2db0_slv_bypass_i));

  assign next_scu_dr_data = next_scu_dr_bypass ? ramctl_bypass_data_i :
                                                 (({128{dr_arb[11]}} & l2db10_slv_data_i) |
                                                  ({128{dr_arb[10]}} & l2db9_slv_data_i)  |
                                                  ({128{dr_arb[9]}}  & l2db8_slv_data_i)  |
                                                  ({128{dr_arb[8]}}  & l2db7_slv_data_i)  |
                                                  ({128{dr_arb[7]}}  & l2db6_slv_data_i)  |
                                                  ({128{dr_arb[6]}}  & l2db5_slv_data_i)  |
                                                  ({128{dr_arb[5]}}  & l2db4_slv_data_i)  |
                                                  ({128{dr_arb[4]}}  & l2db3_slv_data_i)  |
                                                  ({128{dr_arb[3]}}  & l2db2_slv_data_i)  |
                                                  ({128{dr_arb[2]}}  & l2db1_slv_data_i)  |
                                                  ({128{dr_arb[1]}}  & l2db0_slv_data_i)  |
                                                  ({128{dr_arb[0]}}  & master_dr_data_i));

  always @(posedge clk_dr or negedge reset_n)
  if (~reset_n) begin
    dr_credit <= 1'b0;
  end else begin
    dr_credit <= biu_dr_credit_i;
  end

  // Keep a count of how many dr channel credits are in use.
  assign dr_credits_used_en = scu_dr_valid ^ dr_credit;

  assign next_dr_credits_used = dr_credits_used + (scu_dr_valid ? 3'b001 : 3'b111);

  always @(posedge clk_dr or negedge reset_n)
  if (~reset_n) begin
    dr_credits_used <= 3'b000;
  end else if (dr_credits_used_en) begin
    dr_credits_used <= next_dr_credits_used;
  end

  // There are 4 credits that can be used. Once they are all used we must wait
  // for one to be returned before sending another beat.
  // If there is a bypassed transaction that is cancelled, then prevent
  // aribtration of anything this cycle to give time for the L2DB to recover
  // from the cancellation.
  assign dr_credit_available = ((dr_credit | (~dr_credits_used[2] &
                                              ~(scu_dr_early_valid &
                                                (dr_credits_used[1:0] == 2'b11)))) &
                                ~block_dr_arb) | cpuslv_mbistreq;

  assign dr_ready = dr_arb & {(MAX_L2DBS + 1){dr_credit_available}};

  assign cpuslv_l2db10_ready_o  = dr_ready[11];
  assign cpuslv_l2db9_ready_o   = dr_ready[10];
  assign cpuslv_l2db8_ready_o   = dr_ready[9];
  assign cpuslv_l2db7_ready_o   = dr_ready[8];
  assign cpuslv_l2db6_ready_o   = dr_ready[7];
  assign cpuslv_l2db5_ready_o   = dr_ready[6];
  assign cpuslv_l2db4_ready_o   = dr_ready[5];
  assign cpuslv_l2db3_ready_o   = dr_ready[4];
  assign cpuslv_l2db2_ready_o   = dr_ready[3];
  assign cpuslv_l2db1_ready_o   = dr_ready[2];
  assign cpuslv_l2db0_ready_o   = dr_ready[1];
  assign cpuslv_master_dr_ready = dr_ready[0];

  assign cpuslv_master_dr_ready_o = cpuslv_master_dr_ready;

  // Suppressed responses from the master can always be accepted, even if the
  // response is not arbitrated this cycle.
  assign cpuslv_suppress_dr = |reqbuf_suppress_dr;

  assign cpuslv_master_sactive_o = |reqbuf_active;

  assign cpuslv_sample_waddrs_o = |reqbuf_sample_waddrs;

  assign cpuslv_sample_waddrs_dsb_o = |reqbuf_sample_waddrs_dsb;

  assign scu_reqbufs_busy_o = reqbuf_dvm_sync_busy;

  // Send the arbitrated data out whenever there is a credit, unless a reqbuf
  // suppressed it.
  assign next_scu_dr_early_valid = (dr_arb_req &
                                    ~(dr_arb[0] & cpuslv_suppress_dr & master_early_dr_same_i) &
                                    dr_credit_available);

  always @(posedge clk_dr or negedge reset_n)
  if (~reset_n) begin
    scu_dr_early_valid <= 1'b0;
  end else begin
    scu_dr_early_valid <= next_scu_dr_early_valid;
  end

  if (SCU_CACHE_PROTECTION) begin : g_ecc
    reg   scu_dr_bypass;
    reg   scu_dr_bypass_err;
    reg   scu_l2db_bypass;
    wire  next_scu_l2db_bypass;

    // If we are receiving the critical chunk of data directly from ramctl then
    // if it had an ECC error we must not send the data on to the CPU, but the
    // error indication arrives too late to factor it in the cycle before.
    // The corrected data will be sent in a later cycle.
    // If any L2DB is trying to bypass, and gets an error, then we must block
    // all arbitration in the following cycle to prevent arbitrating the
    // erroneous data from the L2DB before the L2DB realises that there has
    // been an error.

    assign next_scu_l2db_bypass = ((dr_req[11] & l2db10_slv_bypass_i) |
                                   (dr_req[10] & l2db9_slv_bypass_i) |
                                   (dr_req[9]  & l2db8_slv_bypass_i) |
                                   (dr_req[8]  & l2db7_slv_bypass_i) |
                                   (dr_req[7]  & l2db6_slv_bypass_i) |
                                   (dr_req[6]  & l2db5_slv_bypass_i) |
                                   (dr_req[5]  & l2db4_slv_bypass_i) |
                                   (dr_req[4]  & l2db3_slv_bypass_i) |
                                   (dr_req[3]  & l2db2_slv_bypass_i) |
                                   (dr_req[2]  & l2db1_slv_bypass_i) |
                                   (dr_req[1]  & l2db0_slv_bypass_i));

    always @(posedge clk_dr or negedge reset_n)
    if (~reset_n) begin
      scu_dr_bypass   <= 1'b0;
      scu_l2db_bypass <= 1'b0;
    end else begin
      scu_dr_bypass   <= next_scu_dr_bypass;
      scu_l2db_bypass <= next_scu_l2db_bypass;
    end

    always @(posedge clk_dr)
    begin
      scu_dr_bypass_err <= ramctl_bypass_err_i;
    end

    assign scu_dr_valid = scu_dr_early_valid & ~(scu_dr_bypass & scu_dr_bypass_err);

    assign block_dr_arb = scu_l2db_bypass & scu_dr_bypass_err;

  end else begin : g_n_ecc

    assign scu_dr_valid = scu_dr_early_valid;

    assign block_dr_arb = 1'b0;

  end

  assign scu_dr_en = dr_arb_req & dr_credit_available;

  always @(posedge clk_dr)
  if (scu_dr_en) begin
    scu_dr_id    <= next_scu_dr_id;
    scu_dr_resp  <= next_scu_dr_resp;
    scu_dr_chunk <= next_scu_dr_chunk;
    scu_dr_data  <= next_scu_dr_data;
  end

  assign scu_dr_valid_o = scu_dr_valid;
  assign scu_dr_id_o    = scu_dr_id;
  assign scu_dr_resp_o  = scu_dr_resp;
  assign scu_dr_chunk_o = scu_dr_chunk;
  assign scu_dr_data_o  = scu_dr_data;

  //----------------------------------------------------------------------------
  //  Request response channel
  //----------------------------------------------------------------------------

  // Response arbitration. The oldest reqbuf wanting to make a response is
  // always granted.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_rr_arb
    assign reqbuf_rr_ready[i] = reqbuf_rr_valid[i] & ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] & reqbuf_rr_valid);
  end


  // Find the original BIU id for the request as stored in the controlling reqbuf.
  assign next_scu_rr_id = (({5{reqbuf_rr_ready[7]}} & reqbuf_biu_id[7]) |
                           ({5{reqbuf_rr_ready[6]}} & reqbuf_biu_id[6]) |
                           ({5{reqbuf_rr_ready[5]}} & reqbuf_biu_id[5]) |
                           ({5{reqbuf_rr_ready[4]}} & reqbuf_biu_id[4]) |
                           ({5{reqbuf_rr_ready[3]}} & reqbuf_biu_id[3]) |
                           ({5{reqbuf_rr_ready[2]}} & reqbuf_biu_id[2]) |
                           ({5{reqbuf_rr_ready[1]}} & reqbuf_biu_id[1]) |
                           ({5{reqbuf_rr_ready[0]}} & reqbuf_biu_id[0]));


  assign next_scu_rr_resp = (({2{reqbuf_rr_ready[7]}} & reqbuf_rr_resp[7]) |
                             ({2{reqbuf_rr_ready[6]}} & reqbuf_rr_resp[6]) |
                             ({2{reqbuf_rr_ready[5]}} & reqbuf_rr_resp[5]) |
                             ({2{reqbuf_rr_ready[4]}} & reqbuf_rr_resp[4]) |
                             ({2{reqbuf_rr_ready[3]}} & reqbuf_rr_resp[3]) |
                             ({2{reqbuf_rr_ready[2]}} & reqbuf_rr_resp[2]) |
                             ({2{reqbuf_rr_ready[1]}} & reqbuf_rr_resp[1]) |
                             ({2{reqbuf_rr_ready[0]}} & reqbuf_rr_resp[0]));

  // Only write responses have an associated L2DB ID, and these can only come from reqbufs.
  assign next_scu_rr_l2db_id = (({4{reqbuf_rr_ready[7]}} & reqbuf_rr_l2db_id[7]) |
                                ({4{reqbuf_rr_ready[6]}} & reqbuf_rr_l2db_id[6]) |
                                ({4{reqbuf_rr_ready[5]}} & reqbuf_rr_l2db_id[5]) |
                                ({4{reqbuf_rr_ready[4]}} & reqbuf_rr_l2db_id[4]) |
                                ({4{reqbuf_rr_ready[3]}} & reqbuf_rr_l2db_id[3]) |
                                ({4{reqbuf_rr_ready[2]}} & reqbuf_rr_l2db_id[2]) |
                                ({4{reqbuf_rr_ready[1]}} & reqbuf_rr_l2db_id[1]) |
                                ({4{reqbuf_rr_ready[0]}} & reqbuf_rr_l2db_id[0]));

  assign next_scu_rr_valid = |(reqbuf_rr_ready & ~reqbuf_rr_cancel);

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    scu_rr_valid <= 1'b0;
  end else begin
    scu_rr_valid <= next_scu_rr_valid;
  end

  always @(posedge clk_reqbufs)
  if (next_scu_rr_valid) begin
    scu_rr_id      <= next_scu_rr_id;
    scu_rr_resp    <= next_scu_rr_resp;
    scu_rr_l2db_id <= next_scu_rr_l2db_id;
  end

  assign scu_rr_valid_o = scu_rr_valid;
  assign scu_rr_id_o = scu_rr_id;
  assign scu_rr_resp_o = scu_rr_resp;
  assign scu_rr_l2db_id_o = scu_rr_l2db_id;

  //----------------------------------------------------------------------------
  //  Request buffer control
  //----------------------------------------------------------------------------

  assign dvm_part_two = |reqbuf_dvm_part_two;

  assign can_alloc = (cpuslv_tagctl_spec_valid_tc0 & ~dvm_part_two) | l2_flush_active;

  // Select the lowest unused reqbuf to allocate for a new request.
  // If the request doesn't actually arrive then the reqbuf will go back to
  // idle in the following cycle.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_reqbuf_alloc
    if (i == 0) begin : g_alloc_0
      assign reqbuf_lowest_unused[i] = ~reqbuf_busy[i];
      assign reqbuf_second_lowest_unused[i] = 1'b0;
    end else begin : g_alloc_n_0
      assign reqbuf_lowest_unused[i] = ~reqbuf_busy[i] & (&reqbuf_busy[i-1:0]);
      assign reqbuf_second_lowest_unused[i] = (~reqbuf_busy[i] & ~reqbuf_lowest_unused[i] &
                                               (&(reqbuf_busy[i-1:0] | reqbuf_lowest_unused[i-1:0])));
    end
  end

  assign reqbuf_alloc = {NUM_REQBUFS{can_alloc}} & reqbuf_lowest_unused;

  assign reqbuf_next_unused = ({NUM_REQBUFS{can_alloc}} & reqbuf_second_lowest_unused) | reqbuf_lowest_unused;

  // Enable the regional gate for each reqbuf if is is active or becoming
  // active, if it might be allocated next cycle, or if the main clk_reqbufs
  // will be gated next cyle and this is the first reqbuf that will be
  // allocated when it wakes up again.
  assign reqbuf_enable = (reqbuf_active | reqbuf_alloc |
                          {NUM_REQBUFS{l2_flush_active | start_l2_flush}});

  assign reqbuf_spec_enable = (({NUM_REQBUFS{~reqbufs_active}} & reqbuf_lowest_unused) |
                               (biu_ar_valid_i ? reqbuf_next_unused : reqbuf_lowest_unused));

  // Because the state machine starts on a speculative allocation request,
  // record if the allocation actually happened, so we can cancel the request
  // in the next cycle.
  assign next_reqbuf_allocated = biu_ar_valid_i | l2_flush_active;

  always @(posedge clk_reqbufs)
  begin
    reqbuf_allocated <= next_reqbuf_allocated;
  end

  // Tell the lowest completed reqbuf that its credit is ready to be sent back
  // to the BIU.
  assign reqbuf_ar_credit_ready[0] = 1'b1;

  for (i = 1; i < NUM_REQBUFS; i = i + 1) begin : g_credit_ready
    assign reqbuf_ar_credit_ready[i] = ~|reqbuf_ar_return_credit[i-1:0];
  end

  // Return a credit whenever at least one reqbuf has completed its request.
  assign next_scu_ar_credit = |reqbuf_ar_return_credit;

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    scu_ar_credit <= 1'b0;
  end else begin
    scu_ar_credit <= next_scu_ar_credit;
  end

  assign scu_ar_credit_o = scu_ar_credit;

  assign scu_ar_block_o = cpuslv_inv_all_pending | l2_flush_block;

  assign reqbuf_alloc_enc = {|reqbuf_alloc[7:4],
                             |{reqbuf_alloc[7:6], reqbuf_alloc[3:2]},
                             |{reqbuf_alloc[7],   reqbuf_alloc[5],
                               reqbuf_alloc[3],   reqbuf_alloc[1]}};

  // Keep track of the order in which reqbufs were allocated.
  ca53scu_buf_age #(.NUM_BUFS(NUM_REQBUFS)) u_reqbuf_age (
    .clk         (clk_reqbufs),
    .reset_n     (reset_n),
    .buf_alloc_i (reqbuf_alloc),
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
  assign cpuslv_tagctl_early_valid_tc0 = |reqbuf_tagctl_valid_tc0;

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

  always @(posedge clk_reqbufs or negedge reset_n)
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
  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    tagctl_prearb_tc0 <= {NUM_REQBUFS{1'b0}};
  end else if (tagctl_prearb_en) begin
    tagctl_prearb_tc0 <= tagctl_prearb;
  end

  assign next_tagctl_prearb_primary = |(tagctl_prearb & reqbuf_tagctl_primary_tc0);

  always @(posedge clk_reqbufs)
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

  assign tagctl_arb_tc0[NUM_REQBUFS] = (~cpuslv_tagctl_early_valid_tc0 &
                                        ~cpuslv_noncoh_only &
                                        ~|reqbuf_noncoh_only);


  assign cpuslv_tagctl_early_valid_tc0_o = cpuslv_tagctl_early_valid_tc0;

  // This must use the ungated clock, as this is one of the terms that causes
  // the main clock gate to wake up.
  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    cpuslv_tagctl_spec_valid_tc0 <= 1'b0;
  end else begin
    cpuslv_tagctl_spec_valid_tc0 <= biu_ar_active_i;
  end

  assign cpuslv_tagctl_spec_valid_tc0_o = cpuslv_tagctl_spec_valid_tc0;

  assign cpuslv_tagctl_valid_tc0_o = (cpuslv_tagctl_early_valid_tc0 |
                                      (biu_ar_valid_i & ~biu_ar_type_i[3] &
                                       ~cpuslv_noncoh_only &
                                       ~|reqbuf_noncoh_only));

  assign cpuslv_tagctl_reqbufid_tc0_o = (({3{tagctl_arb_tc0[8]}} & reqbuf_alloc_enc) |
                                         ({3{tagctl_arb_tc0[7]}} & 3'b111) |
                                         ({3{tagctl_arb_tc0[6]}} & 3'b110) |
                                         ({3{tagctl_arb_tc0[5]}} & 3'b101) |
                                         ({3{tagctl_arb_tc0[4]}} & 3'b100) |
                                         ({3{tagctl_arb_tc0[3]}} & 3'b011) |
                                         ({3{tagctl_arb_tc0[2]}} & 3'b010) |
                                         ({3{tagctl_arb_tc0[1]}} & 3'b001) |
                                         ({3{tagctl_arb_tc0[0]}} & 3'b000));

  assign reqbufs_tagctl_pass_tc0 = (({4{tagctl_arb_tc0[7]}} & reqbuf_tagctl_pass_tc0[7]) |
                                    ({4{tagctl_arb_tc0[6]}} & reqbuf_tagctl_pass_tc0[6]) |
                                    ({4{tagctl_arb_tc0[5]}} & reqbuf_tagctl_pass_tc0[5]) |
                                    ({4{tagctl_arb_tc0[4]}} & reqbuf_tagctl_pass_tc0[4]) |
                                    ({4{tagctl_arb_tc0[3]}} & reqbuf_tagctl_pass_tc0[3]) |
                                    ({4{tagctl_arb_tc0[2]}} & reqbuf_tagctl_pass_tc0[2]) |
                                    ({4{tagctl_arb_tc0[1]}} & reqbuf_tagctl_pass_tc0[1]) |
                                    ({4{tagctl_arb_tc0[0]}} & reqbuf_tagctl_pass_tc0[0]));

  // For new requests, the first pass will always be either a serialise, or
  // for writes an L2DB allocation.
  assign cpuslv_tagctl_pass_tc0_o = tagctl_arb_tc0[8] ? {3'b000, biu_ar_type_i[4]} : reqbufs_tagctl_pass_tc0;

  assign reqbufs_tagctl_addr1_tc0 = (({41{tagctl_arb_tc0[7]}} & reqbuf_tagctl_addr1_tc0[7]) |
                                     ({41{tagctl_arb_tc0[6]}} & reqbuf_tagctl_addr1_tc0[6]) |
                                     ({41{tagctl_arb_tc0[5]}} & reqbuf_tagctl_addr1_tc0[5]) |
                                     ({41{tagctl_arb_tc0[4]}} & reqbuf_tagctl_addr1_tc0[4]) |
                                     ({41{tagctl_arb_tc0[3]}} & reqbuf_tagctl_addr1_tc0[3]) |
                                     ({41{tagctl_arb_tc0[2]}} & reqbuf_tagctl_addr1_tc0[2]) |
                                     ({41{tagctl_arb_tc0[1]}} & reqbuf_tagctl_addr1_tc0[1]) |
                                     ({41{tagctl_arb_tc0[0]}} & reqbuf_tagctl_addr1_tc0[0]));

  assign cpuslv_tagctl_addr1_tc0_o = tagctl_arb_tc0[8] ? biu_ar_addr_i : reqbufs_tagctl_addr1_tc0;

  assign cpuslv_tagctl_dvm_sync_tc0_o = ((tagctl_arb_tc0[7] & (reqbuf_addr2[7][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[6] & (reqbuf_addr2[6][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[5] & (reqbuf_addr2[5][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[4] & (reqbuf_addr2[4][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[3] & (reqbuf_addr2[3][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[2] & (reqbuf_addr2[2][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[1] & (reqbuf_addr2[1][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[0] & (reqbuf_addr2[0][14:12] == `CA53_ACE_DVM_SYNC)));

  assign cpuslv_tagctl_wr_state_tc0 = (({17{tagctl_arb_tc0[7]}} & reqbuf_tagctl_wr_state_tc0[7]) |
                                       ({17{tagctl_arb_tc0[6]}} & reqbuf_tagctl_wr_state_tc0[6]) |
                                       ({17{tagctl_arb_tc0[5]}} & reqbuf_tagctl_wr_state_tc0[5]) |
                                       ({17{tagctl_arb_tc0[4]}} & reqbuf_tagctl_wr_state_tc0[4]) |
                                       ({17{tagctl_arb_tc0[3]}} & reqbuf_tagctl_wr_state_tc0[3]) |
                                       ({17{tagctl_arb_tc0[2]}} & reqbuf_tagctl_wr_state_tc0[2]) |
                                       ({17{tagctl_arb_tc0[1]}} & reqbuf_tagctl_wr_state_tc0[1]) |
                                       ({17{tagctl_arb_tc0[0]}} & reqbuf_tagctl_wr_state_tc0[0]));

  assign cpuslv_tagctl_wr_state_tc0_o = cpuslv_tagctl_wr_state_tc0;

  assign reqbufs_prearb_addr = (({41{tagctl_prearb[7]}} & reqbuf_tagctl_addr1_tc0[7]) |
                                ({41{tagctl_prearb[6]}} & reqbuf_tagctl_addr1_tc0[6]) |
                                ({41{tagctl_prearb[5]}} & reqbuf_tagctl_addr1_tc0[5]) |
                                ({41{tagctl_prearb[4]}} & reqbuf_tagctl_addr1_tc0[4]) |
                                ({41{tagctl_prearb[3]}} & reqbuf_tagctl_addr1_tc0[3]) |
                                ({41{tagctl_prearb[2]}} & reqbuf_tagctl_addr1_tc0[2]) |
                                ({41{tagctl_prearb[1]}} & reqbuf_tagctl_addr1_tc0[1]) |
                                ({41{tagctl_prearb[0]}} & reqbuf_tagctl_addr1_tc0[0]));

  // Calculate the ECC bits for writing to the tag RAMs. Writes can only come
  // from the reqbufs, so no need to factor the new BIU request in. The L2, and
  // most of the L1 calcuations are done based on the prearbitrated address, the
  // cycle before tc0, as there is not time in tc0 to do the arbitration and ECC
  // generation.
  if (SCU_CACHE_PROTECTION) begin : g_scu_ecc
    wire [4:0]  reqbufs_prearb_l2_wr_state;
    wire [32:0] reqbufs_prearb_l2_data;
    wire [6:0]  next_reqbufs_l2_ecc_tc0;

    assign reqbufs_prearb_l2_wr_state = (({5{tagctl_prearb[7]}} & reqbuf_tagctl_wr_state_tc0[7][16:12]) |
                                         ({5{tagctl_prearb[6]}} & reqbuf_tagctl_wr_state_tc0[6][16:12]) |
                                         ({5{tagctl_prearb[5]}} & reqbuf_tagctl_wr_state_tc0[5][16:12]) |
                                         ({5{tagctl_prearb[4]}} & reqbuf_tagctl_wr_state_tc0[4][16:12]) |
                                         ({5{tagctl_prearb[3]}} & reqbuf_tagctl_wr_state_tc0[3][16:12]) |
                                         ({5{tagctl_prearb[2]}} & reqbuf_tagctl_wr_state_tc0[2][16:12]) |
                                         ({5{tagctl_prearb[1]}} & reqbuf_tagctl_wr_state_tc0[1][16:12]) |
                                         ({5{tagctl_prearb[0]}} & reqbuf_tagctl_wr_state_tc0[0][16:12]));

    assign reqbufs_prearb_l2_data = {reqbufs_prearb_l2_wr_state,
                                     reqbufs_prearb_addr[40:17],
                                     reqbufs_prearb_addr[16:13] & ~cpuslv_l2_size};

    ca53_ecc_generate33 u_ecc_generate (
      .data_i (reqbufs_prearb_l2_data),
      .ecc_o  (next_reqbufs_l2_ecc_tc0)
    );

    always @(posedge clk_reqbufs)
    if (tagctl_prearb_en) begin
      reqbufs_l2_ecc_tc0 <= next_reqbufs_l2_ecc_tc0;
    end

  end else begin : g_n_scu_ecc
    always @*
      reqbufs_l2_ecc_tc0 = {7{zero}};
  end

  // For the L1 tags, most of the value being written is the same for all CPUs,
  // so we can share some of the generation logic.
  if (CPU_CACHE_PROTECTION) begin : g_cpu_ecc

    wire [32:0] reqbufs_l1_prearb_addr;
    wire [6:0]  next_reqbufs_l1_addr_partial_ecc_tc0;

    assign reqbufs_l1_prearb_addr = {3'b000,
                                     reqbufs_prearb_addr[40:14],
                                     reqbufs_prearb_addr[13:11] & ~cpuslv_l1_dc_size};

    ca53_ecc_generate33 #(.PARTIAL(0)) u_ecc_generate (
      .data_i (reqbufs_l1_prearb_addr),
      .ecc_o  (next_reqbufs_l1_addr_partial_ecc_tc0)
    );


    always @(posedge clk_reqbufs)
    if (tagctl_prearb_en) begin
      reqbufs_l1_addr_partial_ecc_tc0 <= next_reqbufs_l1_addr_partial_ecc_tc0;
    end

    for (i = 0; i < 4; i = i + 1) begin : g_state_ecc

      ca53_ecc_generate33 #(.PARTIAL(1)) u_ecc_generate (
        .data_i ({cpuslv_tagctl_wr_state_tc0[i*3+:3], {30{1'b0}}}),
        .ecc_o  (l1_state_partial_ecc_tc0[i*7+:7])
      );

    end

  end else begin : g_n_cpu_ecc
    always @*
      reqbufs_l1_addr_partial_ecc_tc0 = {7{zero}};
    assign l1_state_partial_ecc_tc0 = {28{1'b0}};
  end

  assign cpuslv_tagctl_ecc_tc0_o = {reqbufs_l2_ecc_tc0,
                                    l1_state_partial_ecc_tc0 ^ {4{reqbufs_l1_addr_partial_ecc_tc0}}};


  if (CPU_NUM[1:0] == 2'b00) begin : g_ways_cpu1
    assign new_req_ways_tc0 = {{28{biu_ar_way_i[4]}}, biu_ar_way_i[3:0]};
  end else if (CPU_NUM[1:0] == 2'b01) begin : g_ways_cpu2
    assign new_req_ways_tc0 = {{24{biu_ar_way_i[4]}}, biu_ar_way_i[3:0], {4{biu_ar_way_i[4]}}};
  end else if (CPU_NUM[1:0] == 2'b10) begin : g_ways_cpu3
    assign new_req_ways_tc0 = {{20{biu_ar_way_i[4]}}, biu_ar_way_i[3:0], {8{biu_ar_way_i[4]}}};
  end else if (CPU_NUM[1:0] == 2'b11) begin : g_ways_cpu4
    assign new_req_ways_tc0 = {{16{biu_ar_way_i[4]}}, biu_ar_way_i[3:0], {12{biu_ar_way_i[4]}}};
  end

  assign cpuslv_tagctl_ways_tc0_o = (({32{tagctl_arb_tc0[8]}} & new_req_ways_tc0) |
                                     ({32{tagctl_arb_tc0[7]}} & reqbuf_tagctl_ways_tc0[7]) |
                                     ({32{tagctl_arb_tc0[6]}} & reqbuf_tagctl_ways_tc0[6]) |
                                     ({32{tagctl_arb_tc0[5]}} & reqbuf_tagctl_ways_tc0[5]) |
                                     ({32{tagctl_arb_tc0[4]}} & reqbuf_tagctl_ways_tc0[4]) |
                                     ({32{tagctl_arb_tc0[3]}} & reqbuf_tagctl_ways_tc0[3]) |
                                     ({32{tagctl_arb_tc0[2]}} & reqbuf_tagctl_ways_tc0[2]) |
                                     ({32{tagctl_arb_tc0[1]}} & reqbuf_tagctl_ways_tc0[1]) |
                                     ({32{tagctl_arb_tc0[0]}} & reqbuf_tagctl_ways_tc0[0]));

  // No requests write the tag on their first pass.
  assign cpuslv_tagctl_write_tc0_o = (({5{tagctl_arb_tc0[7]}} & reqbuf_tagctl_write_tc0[7]) |
                                      ({5{tagctl_arb_tc0[6]}} & reqbuf_tagctl_write_tc0[6]) |
                                      ({5{tagctl_arb_tc0[5]}} & reqbuf_tagctl_write_tc0[5]) |
                                      ({5{tagctl_arb_tc0[4]}} & reqbuf_tagctl_write_tc0[4]) |
                                      ({5{tagctl_arb_tc0[3]}} & reqbuf_tagctl_write_tc0[3]) |
                                      ({5{tagctl_arb_tc0[2]}} & reqbuf_tagctl_write_tc0[2]) |
                                      ({5{tagctl_arb_tc0[1]}} & reqbuf_tagctl_write_tc0[1]) |
                                      ({5{tagctl_arb_tc0[0]}} & reqbuf_tagctl_write_tc0[0]));

  assign cpuslv_tagctl_type_tc0_o = (({5{tagctl_arb_tc0[8]}} & biu_ar_type_i) |
                                     ({5{tagctl_arb_tc0[7]}} & reqbuf_type[7]) |
                                     ({5{tagctl_arb_tc0[6]}} & reqbuf_type[6]) |
                                     ({5{tagctl_arb_tc0[5]}} & reqbuf_type[5]) |
                                     ({5{tagctl_arb_tc0[4]}} & reqbuf_type[4]) |
                                     ({5{tagctl_arb_tc0[3]}} & reqbuf_type[3]) |
                                     ({5{tagctl_arb_tc0[2]}} & reqbuf_type[2]) |
                                     ({5{tagctl_arb_tc0[1]}} & reqbuf_type[1]) |
                                     ({5{tagctl_arb_tc0[0]}} & reqbuf_type[0]));

  assign cpuslv_tagctl_l2flushreq_tc0_o = ((tagctl_arb_tc0[7] & reqbuf_l2flushreq[7]) |
                                           (tagctl_arb_tc0[6] & reqbuf_l2flushreq[6]) |
                                           (tagctl_arb_tc0[5] & reqbuf_l2flushreq[5]) |
                                           (tagctl_arb_tc0[4] & reqbuf_l2flushreq[4]) |
                                           (tagctl_arb_tc0[3] & reqbuf_l2flushreq[3]) |
                                           (tagctl_arb_tc0[2] & reqbuf_l2flushreq[2]) |
                                           (tagctl_arb_tc0[1] & reqbuf_l2flushreq[1]) |
                                           (tagctl_arb_tc0[0] & reqbuf_l2flushreq[0]));

  // Many of the attributes are not required in tc0, so register the
  // arbitration then send them in tc1 which is less timing critical.
  assign next_reqbuf_arb_tc1 = ((tagctl_arb_tc0[NUM_REQBUFS] ? reqbuf_alloc :
                                                               tagctl_arb_tc0[NUM_REQBUFS-1:0]) &
                                {NUM_REQBUFS{tagctl_cpuslv_ready_tc0_i}});

  // The TC1 arbitration result must be cleared if nothing is arbitrated, so
  // that the reqbufs can work out if they are in TC0 or TC1.
  assign reqbuf_arb_tc1_en = (|reqbuf_arb_tc1 |
                              cpuslv_tagctl_early_valid_tc0 |
                              cpuslv_tagctl_spec_valid_tc0);

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    reqbuf_arb_tc1 <= {NUM_REQBUFS{1'b0}};
  end else if (reqbuf_arb_tc1_en) begin
    reqbuf_arb_tc1 <= next_reqbuf_arb_tc1;
  end


  // Send the remaining information to tagctl in TC1
  assign cpuslv_tagctl_reqbuf_dcu_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_dcu[7]) |
                                           (reqbuf_arb_tc1[6] & reqbuf_dcu[6]) |
                                           (reqbuf_arb_tc1[5] & reqbuf_dcu[5]) |
                                           (reqbuf_arb_tc1[4] & reqbuf_dcu[4]) |
                                           (reqbuf_arb_tc1[3] & reqbuf_dcu[3]) |
                                           (reqbuf_arb_tc1[2] & reqbuf_dcu[2]) |
                                           (reqbuf_arb_tc1[1] & reqbuf_dcu[1]) |
                                           (reqbuf_arb_tc1[0] & reqbuf_dcu[0]));

  assign cpuslv_tagctl_addr2_tc1_o = (({41{reqbuf_arb_tc1[7]}} & reqbuf_addr2[7]) |
                                      ({41{reqbuf_arb_tc1[6]}} & reqbuf_addr2[6]) |
                                      ({41{reqbuf_arb_tc1[5]}} & reqbuf_addr2[5]) |
                                      ({41{reqbuf_arb_tc1[4]}} & reqbuf_addr2[4]) |
                                      ({41{reqbuf_arb_tc1[3]}} & reqbuf_addr2[3]) |
                                      ({41{reqbuf_arb_tc1[2]}} & reqbuf_addr2[2]) |
                                      ({41{reqbuf_arb_tc1[1]}} & reqbuf_addr2[1]) |
                                      ({41{reqbuf_arb_tc1[0]}} & reqbuf_addr2[0]));

  assign cpuslv_tagctl_len_tc1_o = (({2{reqbuf_arb_tc1[7]}} & reqbuf_len[7]) |
                                    ({2{reqbuf_arb_tc1[6]}} & reqbuf_len[6]) |
                                    ({2{reqbuf_arb_tc1[5]}} & reqbuf_len[5]) |
                                    ({2{reqbuf_arb_tc1[4]}} & reqbuf_len[4]) |
                                    ({2{reqbuf_arb_tc1[3]}} & reqbuf_len[3]) |
                                    ({2{reqbuf_arb_tc1[2]}} & reqbuf_len[2]) |
                                    ({2{reqbuf_arb_tc1[1]}} & reqbuf_len[1]) |
                                    ({2{reqbuf_arb_tc1[0]}} & reqbuf_len[0]));

  assign cpuslv_tagctl_size_tc1_o = (({3{reqbuf_arb_tc1[7]}} & reqbuf_size[7]) |
                                     ({3{reqbuf_arb_tc1[6]}} & reqbuf_size[6]) |
                                     ({3{reqbuf_arb_tc1[5]}} & reqbuf_size[5]) |
                                     ({3{reqbuf_arb_tc1[4]}} & reqbuf_size[4]) |
                                     ({3{reqbuf_arb_tc1[3]}} & reqbuf_size[3]) |
                                     ({3{reqbuf_arb_tc1[2]}} & reqbuf_size[2]) |
                                     ({3{reqbuf_arb_tc1[1]}} & reqbuf_size[1]) |
                                     ({3{reqbuf_arb_tc1[0]}} & reqbuf_size[0]));

  assign cpuslv_tagctl_lock_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_lock[7]) |
                                     (reqbuf_arb_tc1[6] & reqbuf_lock[6]) |
                                     (reqbuf_arb_tc1[5] & reqbuf_lock[5]) |
                                     (reqbuf_arb_tc1[4] & reqbuf_lock[4]) |
                                     (reqbuf_arb_tc1[3] & reqbuf_lock[3]) |
                                     (reqbuf_arb_tc1[2] & reqbuf_lock[2]) |
                                     (reqbuf_arb_tc1[1] & reqbuf_lock[1]) |
                                     (reqbuf_arb_tc1[0] & reqbuf_lock[0]));

  assign cpuslv_tagctl_dirty_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_dirty[7]) |
                                      (reqbuf_arb_tc1[6] & reqbuf_dirty[6]) |
                                      (reqbuf_arb_tc1[5] & reqbuf_dirty[5]) |
                                      (reqbuf_arb_tc1[4] & reqbuf_dirty[4]) |
                                      (reqbuf_arb_tc1[3] & reqbuf_dirty[3]) |
                                      (reqbuf_arb_tc1[2] & reqbuf_dirty[2]) |
                                      (reqbuf_arb_tc1[1] & reqbuf_dirty[1]) |
                                      (reqbuf_arb_tc1[0] & reqbuf_dirty[0]));

  assign cpuslv_tagctl_cluster_unique_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_cluster_unique[7]) |
                                               (reqbuf_arb_tc1[6] & reqbuf_cluster_unique[6]) |
                                               (reqbuf_arb_tc1[5] & reqbuf_cluster_unique[5]) |
                                               (reqbuf_arb_tc1[4] & reqbuf_cluster_unique[4]) |
                                               (reqbuf_arb_tc1[3] & reqbuf_cluster_unique[3]) |
                                               (reqbuf_arb_tc1[2] & reqbuf_cluster_unique[2]) |
                                               (reqbuf_arb_tc1[1] & reqbuf_cluster_unique[1]) |
                                               (reqbuf_arb_tc1[0] & reqbuf_cluster_unique[0]));

  assign cpuslv_tagctl_attrs_tc1_o = (({8{reqbuf_arb_tc1[7]}} & reqbuf_attrs[7]) |
                                      ({8{reqbuf_arb_tc1[6]}} & reqbuf_attrs[6]) |
                                      ({8{reqbuf_arb_tc1[5]}} & reqbuf_attrs[5]) |
                                      ({8{reqbuf_arb_tc1[4]}} & reqbuf_attrs[4]) |
                                      ({8{reqbuf_arb_tc1[3]}} & reqbuf_attrs[3]) |
                                      ({8{reqbuf_arb_tc1[2]}} & reqbuf_attrs[2]) |
                                      ({8{reqbuf_arb_tc1[1]}} & reqbuf_attrs[1]) |
                                      ({8{reqbuf_arb_tc1[0]}} & reqbuf_attrs[0]));

  assign cpuslv_tagctl_prot_tc1_o = (({2{reqbuf_arb_tc1[7]}} & reqbuf_prot[7]) |
                                     ({2{reqbuf_arb_tc1[6]}} & reqbuf_prot[6]) |
                                     ({2{reqbuf_arb_tc1[5]}} & reqbuf_prot[5]) |
                                     ({2{reqbuf_arb_tc1[4]}} & reqbuf_prot[4]) |
                                     ({2{reqbuf_arb_tc1[3]}} & reqbuf_prot[3]) |
                                     ({2{reqbuf_arb_tc1[2]}} & reqbuf_prot[2]) |
                                     ({2{reqbuf_arb_tc1[1]}} & reqbuf_prot[1]) |
                                     ({2{reqbuf_arb_tc1[0]}} & reqbuf_prot[0]));

  assign cpuslv_tagctl_l2db_tc1_o = (({4{reqbuf_arb_tc1[7]}} & reqbuf_l2db_tc1[7]) |
                                     ({4{reqbuf_arb_tc1[6]}} & reqbuf_l2db_tc1[6]) |
                                     ({4{reqbuf_arb_tc1[5]}} & reqbuf_l2db_tc1[5]) |
                                     ({4{reqbuf_arb_tc1[4]}} & reqbuf_l2db_tc1[4]) |
                                     ({4{reqbuf_arb_tc1[3]}} & reqbuf_l2db_tc1[3]) |
                                     ({4{reqbuf_arb_tc1[2]}} & reqbuf_l2db_tc1[2]) |
                                     ({4{reqbuf_arb_tc1[1]}} & reqbuf_l2db_tc1[1]) |
                                     ({4{reqbuf_arb_tc1[0]}} & reqbuf_l2db_tc1[0]));

  assign cpuslv_tagctl_l2db_full_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_l2db_full[7]) |
                                          (reqbuf_arb_tc1[6] & reqbuf_l2db_full[6]) |
                                          (reqbuf_arb_tc1[5] & reqbuf_l2db_full[5]) |
                                          (reqbuf_arb_tc1[4] & reqbuf_l2db_full[4]) |
                                          (reqbuf_arb_tc1[3] & reqbuf_l2db_full[3]) |
                                          (reqbuf_arb_tc1[2] & reqbuf_l2db_full[2]) |
                                          (reqbuf_arb_tc1[1] & reqbuf_l2db_full[1]) |
                                          (reqbuf_arb_tc1[0] & reqbuf_l2db_full[0]));

  assign cpuslv_tagctl_static_pcredit_tc1_o = ((reqbuf_arb_tc1[7] & reqbuf_static_pcredit_tc1[7]) |
                                               (reqbuf_arb_tc1[6] & reqbuf_static_pcredit_tc1[6]) |
                                               (reqbuf_arb_tc1[5] & reqbuf_static_pcredit_tc1[5]) |
                                               (reqbuf_arb_tc1[4] & reqbuf_static_pcredit_tc1[4]) |
                                               (reqbuf_arb_tc1[3] & reqbuf_static_pcredit_tc1[3]) |
                                               (reqbuf_arb_tc1[2] & reqbuf_static_pcredit_tc1[2]) |
                                               (reqbuf_arb_tc1[1] & reqbuf_static_pcredit_tc1[1]) |
                                               (reqbuf_arb_tc1[0] & reqbuf_static_pcredit_tc1[0]));

  assign cpuslv_tagctl_pcrdtype_tc1_o = (({2{reqbuf_arb_tc1[7]}} & reqbuf_pcrdtype_tc1[7]) |
                                         ({2{reqbuf_arb_tc1[6]}} & reqbuf_pcrdtype_tc1[6]) |
                                         ({2{reqbuf_arb_tc1[5]}} & reqbuf_pcrdtype_tc1[5]) |
                                         ({2{reqbuf_arb_tc1[4]}} & reqbuf_pcrdtype_tc1[4]) |
                                         ({2{reqbuf_arb_tc1[3]}} & reqbuf_pcrdtype_tc1[3]) |
                                         ({2{reqbuf_arb_tc1[2]}} & reqbuf_pcrdtype_tc1[2]) |
                                         ({2{reqbuf_arb_tc1[1]}} & reqbuf_pcrdtype_tc1[1]) |
                                         ({2{reqbuf_arb_tc1[0]}} & reqbuf_pcrdtype_tc1[0]));

  assign cpuslv_tagctl_victim_way_tc1_o = (({4{reqbuf_arb_tc1[7]}} & reqbuf_victim_way_tc1[7]) |
                                           ({4{reqbuf_arb_tc1[6]}} & reqbuf_victim_way_tc1[6]) |
                                           ({4{reqbuf_arb_tc1[5]}} & reqbuf_victim_way_tc1[5]) |
                                           ({4{reqbuf_arb_tc1[4]}} & reqbuf_victim_way_tc1[4]) |
                                           ({4{reqbuf_arb_tc1[3]}} & reqbuf_victim_way_tc1[3]) |
                                           ({4{reqbuf_arb_tc1[2]}} & reqbuf_victim_way_tc1[2]) |
                                           ({4{reqbuf_arb_tc1[1]}} & reqbuf_victim_way_tc1[1]) |
                                           ({4{reqbuf_arb_tc1[0]}} & reqbuf_victim_way_tc1[0]));

  // We must only start an invalidate all when all reqbufs are idle. Normally
  // this would be the case, however if a CPU was reset after all responses had
  // been returned, but some L2 evictions or similar were still in progress then
  // there could still be reqbufs busy.
  assign cpuslv_inv_all_starting = cpuslv_inv_all_pending & ~|reqbuf_busy & ~gov_l2_in_retention_i;

  assign cpuslv_inv_all_starting_o = cpuslv_inv_all_starting;

  // Record if an invalidate all has been requested but has not started yet.
  assign next_cpuslv_inv_all_pending = ((gov_inv_all_req_i | cpuslv_inv_all_pending) &
                                        ~(cpuslv_inv_all_starting | scu_inv_all_ack));

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    cpuslv_inv_all_pending <= 1'b0;
    scu_inv_all_ack        <= 1'b0;
  end else begin
    cpuslv_inv_all_pending <= next_cpuslv_inv_all_pending;
    scu_inv_all_ack        <= cpuslv_inv_all_starting;
  end

  // Tell the governor when we have started the invalidate all, so that it can
  // drop its request.
  assign scu_inv_all_ack_o = scu_inv_all_ack;

  // Store if the tags are being invalidated, or are in retention, to avoid
  // sending coherent requests during this time.
  assign next_cpuslv_noncoh_only = (tagctl_cpuslv_noncoh_only_i |
                                    cpuslv_inv_all_starting |
                                    gov_l2_in_retention_i);

  // If the RAMs are put into retention while the SCU is idle, then we must
  // still have the correct registered version on the first cycle that a
  // request arrives. This is achieved by the snpslv asserting snpslv_active
  // if the retention state changes.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    cpuslv_noncoh_only <= 1'b1;
  end else begin
    cpuslv_noncoh_only <= next_cpuslv_noncoh_only;
  end

  // Send transfer requests to each L2DB.
  for (i = 0; i < MAX_L2DBS; i = i + 1) begin : g_l2db_mux
    for (j = 0; j < NUM_REQBUFS; j = j + 1) begin : g_l2db_reqbuf
      assign l2db_transfer[i][j]               = reqbuf_l2db_primary_transfer[j] & (reqbuf_l2db_primary_id[j] == i[3:0]);
      assign l2db_transfer[i][j + NUM_REQBUFS] = reqbuf_l2db_victim_transfer[j]  & (reqbuf_l2db_victim_id[j]  == i[3:0]);
      assign l2db_release[i][j]                = reqbuf_l2db_primary_release[j]  & (reqbuf_l2db_primary_id[j] == i[3:0]);
      assign l2db_release[i][j + NUM_REQBUFS]  = reqbuf_l2db_victim_release[j]   & (reqbuf_l2db_victim_id[j]  == i[3:0]);
      assign l2db_release_tc3[i][j]            = reqbuf_l2db_victim_release_tc3[j] & l2db_release[i][j + NUM_REQBUFS];
    end

    if (i < NUM_L2DBS) begin : g_l2db

      assign next_l2db_buf_release[i] = |l2db_release[i] & ~(|l2db_release_tc3[i] & tagctl_ecc_err_tc3_i);

      always @(posedge clk_reqbufs or negedge reset_n)
      if (~reset_n) begin
        l2db_buf_release[i] <= 1'b0;
      end else begin
        l2db_buf_release[i] <= next_l2db_buf_release[i];
      end

      assign cpuslv_l2db_release[i] = l2db_buf_release[i];

      assign l2db_transfer_type[i] = (({3{l2db_transfer[i][15]}} & reqbuf_l2db_victim_transfer_type[7]) |
                                      ({3{l2db_transfer[i][14]}} & reqbuf_l2db_victim_transfer_type[6]) |
                                      ({3{l2db_transfer[i][13]}} & reqbuf_l2db_victim_transfer_type[5]) |
                                      ({3{l2db_transfer[i][12]}} & reqbuf_l2db_victim_transfer_type[4]) |
                                      ({3{l2db_transfer[i][11]}} & reqbuf_l2db_victim_transfer_type[3]) |
                                      ({3{l2db_transfer[i][10]}} & reqbuf_l2db_victim_transfer_type[2]) |
                                      ({3{l2db_transfer[i][9]}}  & reqbuf_l2db_victim_transfer_type[1]) |
                                      ({3{l2db_transfer[i][8]}}  & reqbuf_l2db_victim_transfer_type[0]) |
                                      ({3{l2db_transfer[i][7]}}  & reqbuf_l2db_primary_transfer_type[7]) |
                                      ({3{l2db_transfer[i][6]}}  & reqbuf_l2db_primary_transfer_type[6]) |
                                      ({3{l2db_transfer[i][5]}}  & reqbuf_l2db_primary_transfer_type[5]) |
                                      ({3{l2db_transfer[i][4]}}  & reqbuf_l2db_primary_transfer_type[4]) |
                                      ({3{l2db_transfer[i][3]}}  & reqbuf_l2db_primary_transfer_type[3]) |
                                      ({3{l2db_transfer[i][2]}}  & reqbuf_l2db_primary_transfer_type[2]) |
                                      ({3{l2db_transfer[i][1]}}  & reqbuf_l2db_primary_transfer_type[1]) |
                                      ({3{l2db_transfer[i][0]}}  & reqbuf_l2db_primary_transfer_type[0]));

      assign l2db_transfer_info[i] = (({24{l2db_transfer[i][15]}} & reqbuf_l2db_victim_transfer_info[7]) |
                                      ({24{l2db_transfer[i][14]}} & reqbuf_l2db_victim_transfer_info[6]) |
                                      ({24{l2db_transfer[i][13]}} & reqbuf_l2db_victim_transfer_info[5]) |
                                      ({24{l2db_transfer[i][12]}} & reqbuf_l2db_victim_transfer_info[4]) |
                                      ({24{l2db_transfer[i][11]}} & reqbuf_l2db_victim_transfer_info[3]) |
                                      ({24{l2db_transfer[i][10]}} & reqbuf_l2db_victim_transfer_info[2]) |
                                      ({24{l2db_transfer[i][9]}}  & reqbuf_l2db_victim_transfer_info[1]) |
                                      ({24{l2db_transfer[i][8]}}  & reqbuf_l2db_victim_transfer_info[0]) |
                                      ({24{l2db_transfer[i][7]}}  & reqbuf_l2db_primary_transfer_info[7]) |
                                      ({24{l2db_transfer[i][6]}}  & reqbuf_l2db_primary_transfer_info[6]) |
                                      ({24{l2db_transfer[i][5]}}  & reqbuf_l2db_primary_transfer_info[5]) |
                                      ({24{l2db_transfer[i][4]}}  & reqbuf_l2db_primary_transfer_info[4]) |
                                      ({24{l2db_transfer[i][3]}}  & reqbuf_l2db_primary_transfer_info[3]) |
                                      ({24{l2db_transfer[i][2]}}  & reqbuf_l2db_primary_transfer_info[2]) |
                                      ({24{l2db_transfer[i][1]}}  & reqbuf_l2db_primary_transfer_info[1]) |
                                      ({24{l2db_transfer[i][0]}}  & reqbuf_l2db_primary_transfer_info[0]));

    end else begin : g_n_l2db
      assign cpuslv_l2db_release[i] = 1'b0;
      assign l2db_transfer_type[i] = 3'b000;
      assign l2db_transfer_info[i] = {24{1'b0}};
    end
  end

  assign cpuslv_l2db0_transfer_o  = |l2db_transfer[0];
  assign cpuslv_l2db1_transfer_o  = |l2db_transfer[1];
  assign cpuslv_l2db2_transfer_o  = |l2db_transfer[2];
  assign cpuslv_l2db3_transfer_o  = |l2db_transfer[3];
  assign cpuslv_l2db4_transfer_o  = |l2db_transfer[4];
  assign cpuslv_l2db5_transfer_o  = |l2db_transfer[5];
  assign cpuslv_l2db6_transfer_o  = |l2db_transfer[6];
  assign cpuslv_l2db7_transfer_o  = |l2db_transfer[7];
  assign cpuslv_l2db8_transfer_o  = |l2db_transfer[8];
  assign cpuslv_l2db9_transfer_o  = |l2db_transfer[9];
  assign cpuslv_l2db10_transfer_o = |l2db_transfer[10];

  assign cpuslv_l2db0_transfer_type_o  = l2db_transfer_type[0];
  assign cpuslv_l2db1_transfer_type_o  = l2db_transfer_type[1];
  assign cpuslv_l2db2_transfer_type_o  = l2db_transfer_type[2];
  assign cpuslv_l2db3_transfer_type_o  = l2db_transfer_type[3];
  assign cpuslv_l2db4_transfer_type_o  = l2db_transfer_type[4];
  assign cpuslv_l2db5_transfer_type_o  = l2db_transfer_type[5];
  assign cpuslv_l2db6_transfer_type_o  = l2db_transfer_type[6];
  assign cpuslv_l2db7_transfer_type_o  = l2db_transfer_type[7];
  assign cpuslv_l2db8_transfer_type_o  = l2db_transfer_type[8];
  assign cpuslv_l2db9_transfer_type_o  = l2db_transfer_type[9];
  assign cpuslv_l2db10_transfer_type_o = l2db_transfer_type[10];

  assign cpuslv_l2db0_transfer_info_o  = l2db_transfer_info[0];
  assign cpuslv_l2db1_transfer_info_o  = l2db_transfer_info[1];
  assign cpuslv_l2db2_transfer_info_o  = l2db_transfer_info[2];
  assign cpuslv_l2db3_transfer_info_o  = l2db_transfer_info[3];
  assign cpuslv_l2db4_transfer_info_o  = l2db_transfer_info[4];
  assign cpuslv_l2db5_transfer_info_o  = l2db_transfer_info[5];
  assign cpuslv_l2db6_transfer_info_o  = l2db_transfer_info[6];
  assign cpuslv_l2db7_transfer_info_o  = l2db_transfer_info[7];
  assign cpuslv_l2db8_transfer_info_o  = l2db_transfer_info[8];
  assign cpuslv_l2db9_transfer_info_o  = l2db_transfer_info[9];
  assign cpuslv_l2db10_transfer_info_o = l2db_transfer_info[10];

  assign cpuslv_l2db0_release_o  = cpuslv_l2db_release[0];
  assign cpuslv_l2db1_release_o  = cpuslv_l2db_release[1];
  assign cpuslv_l2db2_release_o  = cpuslv_l2db_release[2];
  assign cpuslv_l2db3_release_o  = cpuslv_l2db_release[3];
  assign cpuslv_l2db4_release_o  = cpuslv_l2db_release[4];
  assign cpuslv_l2db5_release_o  = cpuslv_l2db_release[5];
  assign cpuslv_l2db6_release_o  = cpuslv_l2db_release[6];
  assign cpuslv_l2db7_release_o  = cpuslv_l2db_release[7];
  assign cpuslv_l2db8_release_o  = cpuslv_l2db_release[8];
  assign cpuslv_l2db9_release_o  = cpuslv_l2db_release[9];
  assign cpuslv_l2db10_release_o = cpuslv_l2db_release[10];

  // Indicate if an L2DB may need to be allocate in the following cycle.
  assign cpuslv_l2dbs_active_o = (|(tagctl_arb_tc0[NUM_REQBUFS-1:0] & reqbuf_l2dbs_active) |
                                  cpuslv_tagctl_spec_valid_tc0);

  // Indicate if ramctl might get a request from an L2DB in the following cycle.
  assign cpuslv_ramctl_active_o = |reqbuf_ramctl_active;

  assign next_scu_ev_done = (reqbuf_ev_done_id[7] |
                             reqbuf_ev_done_id[6] |
                             reqbuf_ev_done_id[5] |
                             reqbuf_ev_done_id[4] |
                             reqbuf_ev_done_id[3] |
                             reqbuf_ev_done_id[2] |
                             reqbuf_ev_done_id[1] |
                             reqbuf_ev_done_id[0]);

  assign scu_ev_done_en = (|scu_ev_done) | (|reqbuf_ev_done);

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    scu_ev_done <= 8'h00;
  end else if (scu_ev_done_en) begin
    scu_ev_done <= next_scu_ev_done;
  end

  assign scu_ev_done_o = scu_ev_done;

  assign next_scu_leave_ramode = |reqbuf_leave_ramode;

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    scu_leave_ramode <= 1'b0;
  end else begin
    scu_leave_ramode <= next_scu_leave_ramode;
  end

  assign scu_leave_ramode_o = scu_leave_ramode;

  assign strex_comp_valid = (master_rsp_comp_valid_i &
                             (master_rsp_txnid_i[6:3] == {2'b00, CPU_NUM[1:0]}) &
                             reqbuf_ext_strex[master_rsp_txnid_i[2:0]]);

  assign next_scu_db_excl_valid = master_cpuslv_strex_db_valid_i | strex_comp_valid;

  // Register the response for exclusives and non-reorderable device writes, before passing back to the CPU.
  assign scu_db_dev_excl_en = (master_cpuslv_strex_db_valid_i |
                               master_cpuslv_dev_db_valid_i |
                               strex_comp_valid |
                               scu_db_excl_valid |
                               scu_db_dev_valid);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_db_excl_valid <= 1'b0;
  end else if (scu_db_dev_excl_en) begin
    scu_db_excl_valid <= next_scu_db_excl_valid;
  end

  if (ACE) begin : g_ace

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      scu_db_dev_valid <= 1'b0;
    end else if (scu_db_dev_excl_en) begin
      scu_db_dev_valid <= master_cpuslv_dev_db_valid_i;
    end

  end else begin : g_skyros

    always @*
      scu_db_dev_valid = zero;

  end

  assign next_scu_db_dev_excl_resp = (ACE != 0) ? master_db_resp_i : master_rsp_resp_i[1:0];

  always @(posedge clk)
  if (scu_db_dev_excl_en) begin
    scu_db_dev_excl_resp <= next_scu_db_dev_excl_resp;
  end

  assign scu_db_excl_valid_o = scu_db_excl_valid;
  assign scu_db_excl_resp_o = scu_db_dev_excl_resp;

  assign next_scu_db_decerr = (|reqbuf_ext_decerr |
                               (scu_db_dev_valid & (scu_db_dev_excl_resp == `CA53_ACE_RESP_DECERR)));
  assign next_scu_db_slverr = (|reqbuf_ext_slverr |
                               (scu_db_dev_valid & (scu_db_dev_excl_resp == `CA53_ACE_RESP_SLVERR)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_db_decerr <= 1'b0;
    scu_db_slverr <= 1'b0;
  end else begin
    scu_db_decerr <= next_scu_db_decerr;
    scu_db_slverr <= next_scu_db_slverr;
  end

  assign scu_db_decerr_o = scu_db_decerr;
  assign scu_db_slverr_o = scu_db_slverr;  

  assign cpuslv_dvm_sync_resp_o = (master_rsp_comp_valid_i &
                                   (master_rsp_txnid_i[6:3] == {2'b00, CPU_NUM[1:0]}) &
                                   reqbuf_dvm_sync[master_rsp_txnid_i[2:0]]);

  // Combine hazard results from each reqbuf, then register before returning
  // to tagctl in the following cycle.
  assign cpuslv_hz_tc1 = |reqbuf_hz_tc1;

  assign cpuslv_snp_hz_tc1 = |reqbuf_snp_hz_tc1;

  assign cpuslv_snp_hz_id_tc1 = (({3{reqbuf_snp_hz_tc1[7]}} & 3'b111) |
                                 ({3{reqbuf_snp_hz_tc1[6]}} & 3'b110) |
                                 ({3{reqbuf_snp_hz_tc1[5]}} & 3'b101) |
                                 ({3{reqbuf_snp_hz_tc1[4]}} & 3'b100) |
                                 ({3{reqbuf_snp_hz_tc1[3]}} & 3'b011) |
                                 ({3{reqbuf_snp_hz_tc1[2]}} & 3'b010) |
                                 ({3{reqbuf_snp_hz_tc1[1]}} & 3'b001) |
                                 ({3{reqbuf_snp_hz_tc1[0]}} & 3'b000));

  assign cpuslv_snp_l2db_hz_tc1 = |reqbuf_snp_l2db_hz_tc1;

  assign cpuslv_snp_l2db_dirty_tc1 = |reqbuf_snp_l2db_dirty_tc1;

  assign cpuslv_snp_l2db_tc1 = (({4{reqbuf_snp_l2db_hz_tc1[7]}} & reqbuf_l2db_primary_id[7]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[6]}} & reqbuf_l2db_primary_id[6]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[5]}} & reqbuf_l2db_primary_id[5]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[4]}} & reqbuf_l2db_primary_id[4]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[3]}} & reqbuf_l2db_primary_id[3]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[2]}} & reqbuf_l2db_primary_id[2]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[1]}} & reqbuf_l2db_primary_id[1]) |
                                ({4{reqbuf_snp_l2db_hz_tc1[0]}} & reqbuf_l2db_primary_id[0]));

  assign cpuslv_ecc_hz_tc1 = |reqbuf_ecc_hz_tc1;

  assign cpuslv_force_miss_tc1 = (reqbuf_force_miss_tc1[7] |
                                  reqbuf_force_miss_tc1[6] |
                                  reqbuf_force_miss_tc1[5] |
                                  reqbuf_force_miss_tc1[4] |
                                  reqbuf_force_miss_tc1[3] |
                                  reqbuf_force_miss_tc1[2] |
                                  reqbuf_force_miss_tc1[1] |
                                  reqbuf_force_miss_tc1[0]);

  assign cpuslv_l2_way_used_tc1 = (reqbuf_l2_way_used_tc1[7] |
                                   reqbuf_l2_way_used_tc1[6] |
                                   reqbuf_l2_way_used_tc1[5] |
                                   reqbuf_l2_way_used_tc1[4] |
                                   reqbuf_l2_way_used_tc1[3] |
                                   reqbuf_l2_way_used_tc1[2] |
                                   reqbuf_l2_way_used_tc1[1] |
                                   reqbuf_l2_way_used_tc1[0]);

  assign cpuslv_l2_way_used_vc1 = (reqbuf_l2_way_used_vc1[7] |
                                   reqbuf_l2_way_used_vc1[6] |
                                   reqbuf_l2_way_used_vc1[5] |
                                   reqbuf_l2_way_used_vc1[4] |
                                   reqbuf_l2_way_used_vc1[3] |
                                   reqbuf_l2_way_used_vc1[2] |
                                   reqbuf_l2_way_used_vc1[1] |
                                   reqbuf_l2_way_used_vc1[0]);

  assign cpuslv_hz_tc3 = |reqbuf_hz_tc3;

  assign next_scu_drain_stb = |reqbuf_drain_stb;

  always @(posedge clk)
  if (reqbufs_active) begin
    cpuslv_hz_tc2             <= cpuslv_hz_tc1;
    cpuslv_snp_hz_tc2         <= cpuslv_snp_hz_tc1;
    cpuslv_snp_hz_id_tc2      <= cpuslv_snp_hz_id_tc1;
    cpuslv_snp_l2db_hz_tc2    <= cpuslv_snp_l2db_hz_tc1;
    cpuslv_snp_l2db_dirty_tc2 <= cpuslv_snp_l2db_dirty_tc1;
    cpuslv_snp_l2db_tc2       <= cpuslv_snp_l2db_tc1;
    cpuslv_ecc_hz_tc2         <= cpuslv_ecc_hz_tc1;
    cpuslv_hz_tc4             <= cpuslv_hz_tc3;
    cpuslv_ecc_err_tc4        <= tagctl_ecc_err_tc3_i;
    scu_drain_stb             <= next_scu_drain_stb;
  end

  assign cpuslv_hz_tc2_o = cpuslv_hz_tc2;

  assign cpuslv_snp_hz_tc2_o = cpuslv_snp_hz_tc2;
  assign cpuslv_snp_hz_id_tc2_o = cpuslv_snp_hz_id_tc2;

  assign cpuslv_snp_l2db_hz_tc2_o = cpuslv_snp_l2db_hz_tc2;
  assign cpuslv_snp_l2db_dirty_tc2_o = cpuslv_snp_l2db_dirty_tc2;
  assign cpuslv_snp_l2db_tc2_o = cpuslv_snp_l2db_tc2;

  assign cpuslv_ecc_hz_tc2_o = cpuslv_ecc_hz_tc2;

  if (L2_CACHE) begin : g_l2cc_force

    always @(posedge clk_reqbufs)
    if (reqbufs_active) begin
      cpuslv_force_miss_tc2  <= cpuslv_force_miss_tc1;
      cpuslv_l2_way_used_tc2 <= cpuslv_l2_way_used_tc1;
      cpuslv_l2_way_used_vc2 <= cpuslv_l2_way_used_vc1;
    end

    assign cpuslv_force_miss_tc2_o = cpuslv_force_miss_tc2;

  end else begin : g_n_l2cc_force

    always @(posedge clk_reqbufs)
    if (reqbufs_active) begin
      cpuslv_force_miss_tc2 <= cpuslv_force_miss_tc1[15:0];
    end

    assign cpuslv_force_miss_tc2_o = {16'h0000, cpuslv_force_miss_tc2};

    always @*
    begin
      cpuslv_l2_way_used_tc2 = {16{zero}};
      cpuslv_l2_way_used_vc2 = {16{zero}};
    end

  end

  assign cpuslv_l2_way_used_tc2_o = cpuslv_l2_way_used_tc2;
  assign cpuslv_l2_way_used_vc2_o = cpuslv_l2_way_used_vc2;

  assign cpuslv_hz_tc4_o = cpuslv_hz_tc4;

  assign scu_drain_stb_o = scu_drain_stb;

  // Remember if a non-coherent request that might go to an HN-I, or a cache
  // maintenance request has been sent since the last barrier. If not, then
  // there is no need to send a barrier externally.
  assign next_cpuslv_noncoh_since_dmb = ((tagctl_noncoh_serialised_tc3_i &
                                          (tagctl_reqbufid_tc3_i[5:3] == CPU_NUM[2:0])) |
                                         (cpuslv_noncoh_since_dmb & ~|(reqbuf_dmb_resp  | reqbuf_dsb_resp)));

  assign next_cpuslv_noncoh_since_dsb = ((tagctl_noncoh_serialised_tc3_i &
                                          (tagctl_reqbufid_tc3_i[5:3] == CPU_NUM[2:0])) |
                                         (cpuslv_noncoh_since_dsb & ~|reqbuf_dsb_resp));

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    cpuslv_noncoh_since_dmb <= 1'b0;
    cpuslv_noncoh_since_dsb <= 1'b0;
  end else begin
    cpuslv_noncoh_since_dmb <= next_cpuslv_noncoh_since_dmb;
    cpuslv_noncoh_since_dsb <= next_cpuslv_noncoh_since_dsb;
  end

  assign cpuslv_noncoh_since_barrier_o = cpuslv_noncoh_since_dsb;

  // Combine L2 allocation information to the master. At most only one reqbuf
  // will match the request, and so there is no need to mux between them.
  assign cpuslv_early_dr_l2_o = |reqbuf_early_dr_l2;

  assign cpuslv_early_dr_index_o = (reqbuf_early_dr_index[7] |
                                    reqbuf_early_dr_index[6] |
                                    reqbuf_early_dr_index[5] |
                                    reqbuf_early_dr_index[4] |
                                    reqbuf_early_dr_index[3] |
                                    reqbuf_early_dr_index[2] |
                                    reqbuf_early_dr_index[1] |
                                    reqbuf_early_dr_index[0]);

  assign cpuslv_early_dr_way_o = (reqbuf_early_dr_way[7] |
                                  reqbuf_early_dr_way[6] |
                                  reqbuf_early_dr_way[5] |
                                  reqbuf_early_dr_way[4] |
                                  reqbuf_early_dr_way[3] |
                                  reqbuf_early_dr_way[2] |
                                  reqbuf_early_dr_way[1] |
                                  reqbuf_early_dr_way[0]);

  always @(posedge clk_reqbufs)
  begin
    cpuslv_enable_writeevict <= gov_enable_writeevict_i;
  end

  //----------------------------------------------------------------------------
  //  Snoop requests
  //----------------------------------------------------------------------------

  // Register the channel before sending to the CPU, to help decouple the
  // timing.

  // Once asserted, valid is kept high until the request is accepted.
  assign next_scu_ac_valid = scu_ac_valid ? ~dcu_ac_ready_i : tagctl_cpuslv_ac_valid_i;

  always @(posedge clk_snp or negedge reset_n)
  if (~reset_n) begin
    scu_ac_valid <= 1'b0;
  end else begin
    scu_ac_valid <= next_scu_ac_valid;
  end

  // Only allow a new request from tagctl when the buffer is empty. This limits
  // the throughput to one request every other cycle, however for most snoops
  // the CPU cannot process them any faster than this.
  assign cpuslv_ac_ready_o = ~scu_ac_valid;

  assign ac_en = (tagctl_cpuslv_ac_valid_i & ~scu_ac_valid) | cpuslv_mbistreq;

  always @(posedge clk_snp)
  if (ac_en) begin
    scu_ac_snoop   <= tagctl_cpuslv_ac_snoop_i;
    scu_ac_id      <= tagctl_cpuslv_ac_id_i;
    scu_ac_l2db_id <= tagctl_cpuslv_ac_l2db_id_i;
    scu_ac_addr    <= tagctl_cpuslv_ac_addr_i;
    scu_ac_way     <= tagctl_cpuslv_ac_way_i;
  end

  assign scu_ac_valid_o   = scu_ac_valid;
  assign scu_ac_snoop_o   = scu_ac_snoop;
  assign scu_ac_id_o      = scu_ac_id;
  assign scu_ac_l2db_id_o = scu_ac_l2db_id;
  assign scu_ac_addr_o    = scu_ac_addr;
  assign scu_ac_way_o     = scu_ac_way;

  // Register the snoop response channel before passing on to the AFBs.
  always @(posedge clk_snp or negedge reset_n)
  if (~reset_n) begin
    cpuslv_cr_valid <= 1'b0;
  end else begin
    cpuslv_cr_valid <= dcu_cr_valid_i;
  end

  always @(posedge clk_snp)
  if (dcu_cr_valid_i) begin
    cpuslv_cr_id        <= dcu_cr_id_i;
    cpuslv_cr_dirty     <= dcu_cr_dirty_i;
    cpuslv_cr_age       <= dcu_cr_age_i;
    cpuslv_cr_alloc     <= dcu_cr_alloc_i;
    cpuslv_cr_migratory <= dcu_cr_migratory_i;
  end

  assign cpuslv_cr_valid_o     = cpuslv_cr_valid;
  assign cpuslv_cr_id_o        = cpuslv_cr_id;
  assign cpuslv_cr_dirty_o     = cpuslv_cr_dirty;
  assign cpuslv_cr_age_o       = cpuslv_cr_age;
  assign cpuslv_cr_alloc_o     = cpuslv_cr_alloc;
  assign cpuslv_cr_migratory_o = cpuslv_cr_migratory;

  //----------------------------------------------------------------------------
  //  Skyros CompAck responses
  //----------------------------------------------------------------------------

  // The oldest reqbuf wanting to send a compack is given priority.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_compack_arb
    assign reqbuf_compack_arb[i] = (reqbuf_compack_valid[i] & ~reqbuf_compack_ready[i] &
                                    ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                       reqbuf_compack_valid & ~reqbuf_compack_ready));
  end

  assign cpuslv_compack_active_o = |reqbuf_compack_active;

  assign cpuslv_compack_valid_o = |(reqbuf_compack_valid & ~reqbuf_compack_ready);

  assign cpuslv_compack_tgtid_o = (({7{reqbuf_compack_arb[7]}} & reqbuf_compack_tgtid[7]) |
                                   ({7{reqbuf_compack_arb[6]}} & reqbuf_compack_tgtid[6]) |
                                   ({7{reqbuf_compack_arb[5]}} & reqbuf_compack_tgtid[5]) |
                                   ({7{reqbuf_compack_arb[4]}} & reqbuf_compack_tgtid[4]) |
                                   ({7{reqbuf_compack_arb[3]}} & reqbuf_compack_tgtid[3]) |
                                   ({7{reqbuf_compack_arb[2]}} & reqbuf_compack_tgtid[2]) |
                                   ({7{reqbuf_compack_arb[1]}} & reqbuf_compack_tgtid[1]) |
                                   ({7{reqbuf_compack_arb[0]}} & reqbuf_compack_tgtid[0]));

  assign cpuslv_compack_txnid_o = (({8{reqbuf_compack_arb[7]}} & reqbuf_compack_txnid[7]) |
                                   ({8{reqbuf_compack_arb[6]}} & reqbuf_compack_txnid[6]) |
                                   ({8{reqbuf_compack_arb[5]}} & reqbuf_compack_txnid[5]) |
                                   ({8{reqbuf_compack_arb[4]}} & reqbuf_compack_txnid[4]) |
                                   ({8{reqbuf_compack_arb[3]}} & reqbuf_compack_txnid[3]) |
                                   ({8{reqbuf_compack_arb[2]}} & reqbuf_compack_txnid[2]) |
                                   ({8{reqbuf_compack_arb[1]}} & reqbuf_compack_txnid[1]) |
                                   ({8{reqbuf_compack_arb[0]}} & reqbuf_compack_txnid[0]));

  assign next_reqbuf_compack_ready = {NUM_REQBUFS{snpslv_cpuslv_compack_ready_i}} & reqbuf_compack_arb;

  assign reqbuf_compack_ready_en = |reqbuf_compack_valid;

  if (ACE) begin : g_compack_ace

    always @*
      reqbuf_compack_ready = {NUM_REQBUFS{zero}};

  end else begin : g_compack_skyros

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      reqbuf_compack_ready <= {NUM_REQBUFS{1'b0}};
    end else if (reqbuf_compack_ready_en) begin
      reqbuf_compack_ready <= next_reqbuf_compack_ready;
    end

  end

  //----------------------------------------------------------------------------
  //  Victimctl requests
  //----------------------------------------------------------------------------

  assign cpuslv_victimctl_active_o = |reqbuf_victimctl_active;

  assign cpuslv_victimctl_valid_o = |reqbuf_victimctl_valid;

  // The oldest reqbuf wanting to access the victim RAM is given priority.
  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_victimctl_arb
    assign reqbuf_victimctl_arb[i] = (reqbuf_victimctl_valid[i] &
                                      ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                         reqbuf_victimctl_valid));

    assign reqbuf_victimctl_ready[i] = victimctl_ready_i & (victimctl_ready_id_i == {CPU_NUM[2:0], i[2:0]});
  end

  assign cpuslv_victimctl_wr_o = |(reqbuf_victimctl_arb & reqbuf_victimctl_wr);

  assign cpuslv_victimctl_age_o = |(reqbuf_victimctl_arb & reqbuf_victimctl_age);

  assign cpuslv_victimctl_nontemp_o = |(reqbuf_victimctl_arb & reqbuf_victimctl_nontemp);

  assign cpuslv_victimctl_iside_o = ((reqbuf_victimctl_arb[0] & reqbuf_prot[0][1]) |
                                     (reqbuf_victimctl_arb[1] & reqbuf_prot[1][1]) |
                                     (reqbuf_victimctl_arb[2] & reqbuf_prot[2][1]) |
                                     (reqbuf_victimctl_arb[3] & reqbuf_prot[3][1]) |
                                     (reqbuf_victimctl_arb[4] & reqbuf_prot[4][1]) |
                                     (reqbuf_victimctl_arb[5] & reqbuf_prot[5][1]) |
                                     (reqbuf_victimctl_arb[6] & reqbuf_prot[6][1]) |
                                     (reqbuf_victimctl_arb[7] & reqbuf_prot[7][1]));

  assign cpuslv_victimctl_index_o = (({11{reqbuf_victimctl_arb[0]}} & reqbuf_victimctl_index[0]) |
                                     ({11{reqbuf_victimctl_arb[1]}} & reqbuf_victimctl_index[1]) |
                                     ({11{reqbuf_victimctl_arb[2]}} & reqbuf_victimctl_index[2]) |
                                     ({11{reqbuf_victimctl_arb[3]}} & reqbuf_victimctl_index[3]) |
                                     ({11{reqbuf_victimctl_arb[4]}} & reqbuf_victimctl_index[4]) |
                                     ({11{reqbuf_victimctl_arb[5]}} & reqbuf_victimctl_index[5]) |
                                     ({11{reqbuf_victimctl_arb[6]}} & reqbuf_victimctl_index[6]) |
                                     ({11{reqbuf_victimctl_arb[7]}} & reqbuf_victimctl_index[7]));

  assign cpuslv_victimctl_way_o = (({4{reqbuf_victimctl_arb[0]}} & reqbuf_victimctl_way[0]) |
                                   ({4{reqbuf_victimctl_arb[1]}} & reqbuf_victimctl_way[1]) |
                                   ({4{reqbuf_victimctl_arb[2]}} & reqbuf_victimctl_way[2]) |
                                   ({4{reqbuf_victimctl_arb[3]}} & reqbuf_victimctl_way[3]) |
                                   ({4{reqbuf_victimctl_arb[4]}} & reqbuf_victimctl_way[4]) |
                                   ({4{reqbuf_victimctl_arb[5]}} & reqbuf_victimctl_way[5]) |
                                   ({4{reqbuf_victimctl_arb[6]}} & reqbuf_victimctl_way[6]) |
                                   ({4{reqbuf_victimctl_arb[7]}} & reqbuf_victimctl_way[7]));

  assign cpuslv_victimctl_id_o = (({3{reqbuf_victimctl_arb[0]}} & 3'b000) |
                                  ({3{reqbuf_victimctl_arb[1]}} & 3'b001) |
                                  ({3{reqbuf_victimctl_arb[2]}} & 3'b010) |
                                  ({3{reqbuf_victimctl_arb[3]}} & 3'b011) |
                                  ({3{reqbuf_victimctl_arb[4]}} & 3'b100) |
                                  ({3{reqbuf_victimctl_arb[5]}} & 3'b101) |
                                  ({3{reqbuf_victimctl_arb[6]}} & 3'b110) |
                                  ({3{reqbuf_victimctl_arb[7]}} & 3'b111));

  //----------------------------------------------------------------------------
  //  L2FLUSHREQ set/way ops
  //----------------------------------------------------------------------------

  if ((L2_CACHE != 0) & (CPU_NUM[1:0] == 2'b00)) begin : g_l2flushreq

    assign flush_ready = ~&reqbuf_busy;

    // Detect when we have flushed each index for the implemented cache size.
    assign l2_flush_index_end = (l2_flush_active &
                                 flush_ready &
                                 (&(l2_flush_index[10:7] | ~cpuslv_l2_size)) &
                                 (&l2_flush_index[6:0]));

    // Count up through each index, once per way. We do all indexes before
    // starting again with the next way, to try to avoid having more than one
    // request outstanding per index thus reduce the chance of any index
    // hazarding slowing the request down.
    assign l2_flush_index_en = start_l2_flush | (l2_flush_active & flush_ready);

    assign next_l2_flush_index = ((start_l2_flush |
                                   l2_flush_index_end) ? 11'h000 :
                                                         (l2_flush_index + 11'h001));

    always @(posedge clk_reqbufs)
    if (l2_flush_index_en) begin
      l2_flush_index <= next_l2_flush_index;
    end


    // Increment the way each time we have processed every index.
    assign l2_flush_way_en = start_l2_flush | l2_flush_index_end;

    assign next_l2_flush_way = start_l2_flush ? 4'h0 : (l2_flush_way + 4'h1);

    always @(posedge clk_reqbufs)
    if (l2_flush_way_en) begin
      l2_flush_way <= next_l2_flush_way;
    end

    assign l2_flush_way_end = (l2_flush_active &
                               flush_ready &
                               (&l2_flush_way));

    assign l2_flush_end = l2_flush_index_end & l2_flush_way_end;

    // Must only start a new flush when all masters are inactive and we are not
    // still waiting for an earlier one to complete.
    assign l2_flush_allowed = (&gov_standbywfi_i &
                               ((ACP == 0) | acp_ainact_rs_i) &
                               ~l2_flush_done & ~l2_flush_ended);

    // Record when we have finished inserting the operations, but they have not
    // completed yet.
    assign next_l2_flush_ended = (l2_flush_ended | l2_flush_end) & l2flushreq_rs_i & ~next_l2_flush_done;

    // Assert flush done when we have completed the flush, and keep it
    // held until the request is removed.
    assign next_l2_flush_done = l2flushreq_rs_i & (l2_flush_done | (l2_flush_ended &
                                                                    ~|reqbuf_busy &
                                                                    ~master_writes_active_i));

    // Once we have started a flush, keep it active until either done or the
    // request is dropped.
    assign start_l2_flush = l2flushreq_rs_i & ~l2_flush_active & l2_flush_allowed;

    assign next_l2_flush_active = (l2_flush_active & l2flushreq_rs_i &
                                   l2_flush_allowed & ~l2_flush_end) | start_l2_flush;

    // Once a flush starts, we must block new BIU requests until all reqbufs have drained.
    assign next_l2_flush_block = ((start_l2_flush | l2_flush_active) |
                                  (l2_flush_block & |reqbuf_busy));

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      l2_flush_ended   <= 1'b0;
      l2_flush_done    <= 1'b0;
      l2_flush_active  <= 1'b0;
      l2_flush_block   <= 1'b0;
    end else begin
      l2_flush_ended   <= next_l2_flush_ended;
      l2_flush_done    <= next_l2_flush_done;
      l2_flush_active  <= next_l2_flush_active;
      l2_flush_block   <= next_l2_flush_block;
    end

    assign cpuslv_l2flushdone_o = l2_flush_done;

    assign cpuslv_l2flush_active_o = l2_flush_active;

    // Insert the flush requests
    assign ar_valid = l2_flush_active | biu_ar_valid_i;
    assign ar_id    = l2_flush_active ? `CA53_RID_L2FLUSH : biu_ar_id_i;
    assign ar_type  = l2_flush_active ? `CA53_REQ_CLEANINVSETWAY : biu_ar_type_i;
    assign ar_addr  = {biu_ar_addr_i[40:32],
                       l2_flush_active ? l2_flush_way : biu_ar_addr_i[31:28],
                       biu_ar_addr_i[27:17],
                       l2_flush_active ? l2_flush_index : biu_ar_addr_i[16:6],
                       l2_flush_active ? 2'b00 : biu_ar_addr_i[5:4],
                       l2_flush_active ? 3'b001 : biu_ar_addr_i[3:1],
                       biu_ar_addr_i[0]};

    assign l2_flush_req = l2flushreq_rs_i;

  end else begin : g_n_l2flushreq
    assign cpuslv_l2flushdone_o = 1'b0;
    assign cpuslv_l2flush_active_o = 1'b0;

    always @*
    begin
      l2_flush_active = zero;
      l2_flush_block  = zero;
      l2_flush_ended  = zero;
      l2_flush_done   = zero;
    end

    assign l2_flush_index_en = 1'b0;
    assign l2_flush_way_en = 1'b0;

    assign ar_valid = biu_ar_valid_i;
    assign ar_id    = biu_ar_id_i;
    assign ar_type  = biu_ar_type_i;
    assign ar_addr  = biu_ar_addr_i;

    assign l2_flush_req = 1'b0;
    assign start_l2_flush = 1'b0;
  end

  //----------------------------------------------------------------------------
  //  Performance counter events
  //----------------------------------------------------------------------------
  
  assign next_scu_evnt_eviction = scu_ac_valid & dcu_ac_ready_i & (scu_ac_snoop == `CA53_SNOOP_CLEANINVALID);

  assign next_scu_evnt_snooped_data = |reqbuf_evnt_snooped_data;

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    scu_evnt_eviction     <= 1'b0;
    scu_evnt_snooped_data <= 1'b0;
  end else begin
    scu_evnt_eviction     <= next_scu_evnt_eviction;
    scu_evnt_snooped_data <= next_scu_evnt_snooped_data;
  end

  assign scu_evnt_eviction_o     = scu_evnt_eviction;
  assign scu_evnt_snooped_data_o = scu_evnt_snooped_data;

  if (L2_CACHE) begin : g_evnt_l2cc

    assign next_scu_evnt_l2_access = |reqbuf_evnt_l2_access;

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      scu_evnt_l2_access <= 1'b0;
    end else begin
      scu_evnt_l2_access <= next_scu_evnt_l2_access;
    end

  end else begin : g_n_evnt_l2cc

    always @*
      scu_evnt_l2_access = zero;

  end

  assign scu_evnt_l2_access_o = scu_evnt_l2_access;

  //----------------------------------------------------------------------------
  //  Request buffers
  //----------------------------------------------------------------------------

  for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_reqbuf

    ca53scu_reqbuf_cpu #(`CA53_SCU_INT_PARAM_INST, .NUM_REQBUFS(NUM_REQBUFS), .REQBUF_ID({CPU_NUM, i[2:0]})) u_reqbuf (
      // Inputs
      .clk                                   (clk_reqbufs),
      .reset_n                               (reset_n),
      .DFTSE                                 (DFTSE),
      .cpuslv_broadcastinner_i               (cpuslv_broadcastinner),
      .cpuslv_broadcastouter_i               (cpuslv_broadcastouter),
      .cpuslv_broadcastcachemaint_i          (cpuslv_broadcastcachemaint),
      .config_sysbardisable_i                (config_sysbardisable_i),
      .cpuslv_l1_dc_size_i                   (cpuslv_l1_dc_size),
      .cpuslv_l2_size_i                      (cpuslv_l2_size),
      .cpuslv_enable_writeevict_i            (cpuslv_enable_writeevict),
      .reqbuf_enable_i                       (reqbuf_enable[i]),
      .reqbuf_spec_enable_i                  (reqbuf_spec_enable[i]),
      .reqbuf_alloc_i                        (reqbuf_alloc[i]),
      .reqbuf_allocated_i                    (reqbuf_allocated),
      .reqbuf_ar_credit_ready_i              (reqbuf_ar_credit_ready[i]),
      .ar_valid_i                            (ar_valid),
      .ar_id_i                               (ar_id),
      .ar_type_i                             (ar_type),
      .ar_addr_i                             (ar_addr),
      .ar_attrs_i                            (biu_ar_attrs_i),
      .ar_way_i                              (biu_ar_way_i[3:0]),
      .ar_len_i                              (biu_ar_len_i),
      .ar_size_i                             (biu_ar_size_i),
      .ar_lock_i                             (biu_ar_lock_i),
      .ar_priv_i                             (biu_ar_priv_i),
      .cpuslv_l2dbs_dw_valid_i               (cpuslv_l2dbs_dw_valid),
      .cpuslv_l2dbs_dw_last_i                (cpuslv_l2dbs_dw_last),
      .cpuslv_l2dbs_dw_id_i                  (cpuslv_l2dbs_dw_id),
      .tagctl_addr_tc1_i                     (tagctl_addr_tc1_i),
      .tagctl_valid_tc1_i                    (tagctl_valid_tc1_i),
      .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1_i),
      .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1_i),
      .tagctl_l1_set_way_op_tc1_i            (tagctl_l1_set_way_op_tc1_i),
      .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1_i),
      .tagctl_serialising_tc1_i              (tagctl_serialising_tc1_i),
      .tagctl_ecc_wr_tc1_i                   (tagctl_ecc_wr_tc1_i),
      .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1_i),
      .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1_i),
      .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1_i),
      .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1_i),
      .victimctl_index_vc1_i                 (victimctl_index_vc1_i),
      .tagctl_addr_tc3_i                     (tagctl_addr_tc3_i),
      .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3_i),
      .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3_i),
      .reqbufs_keep_order_i                  (reqbuf_keep_order),
      .reqbufs_busy_i                        (reqbuf_busy),
      .reqbufs_dvm_i                         (reqbuf_dvm),
      .reqbufs_coh_i                         (reqbuf_coh),
      .cpuslv_noncoh_only_i                  (cpuslv_noncoh_only),
      .reqbufs_noncoh_only_i                 (reqbuf_noncoh_only),
      .cpuslv_noncoh_since_dmb_i             (cpuslv_noncoh_since_dmb),
      .cpuslv_noncoh_since_dsb_i             (cpuslv_noncoh_since_dsb),
      .reqbuf_tagctl_prearb_primary_i        (reqbuf_tagctl_prearb_primary[i]),
      .reqbuf_tagctl_prearb_victim_i         (reqbuf_tagctl_prearb_victim[i]),
      .cpuslv_tagctl_spec_valid_tc0_i        (cpuslv_tagctl_spec_valid_tc0),
      .reqbuf_arb_tc1_i                      (reqbuf_arb_tc1[i]),
      .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1_i),
      .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2_i),
      .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3_i),
      .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4_i),
      .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4_i),
      .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3_i),
      .cpuslv_ecc_err_tc4_i                  (cpuslv_ecc_err_tc4),
      .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1_i),
      .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1_i),
      .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4_i),
      .tagctl_slv_snp_hz_tc4_i               (tagctl_slv_snp_hz_tc4_i),
      .tagctl_slv_snp_hz_id_tc4_i            (tagctl_slv_snp_hz_id_tc4_i),
      .tagctl_slv_l2db_invalidated_tc4_i     (tagctl_slv_l2db_invalidated_tc4_i),
      .tagctl_slv_l2db_cleaned_tc4_i         (tagctl_slv_l2db_cleaned_tc4_i),
      .tagctl_slv_victim_l2db_tc4_i          (tagctl_slv_victim_l2db_tc4_i),
      .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3_i),
      .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3_i),
      .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3_i),
      .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3_i),
      .tagctl_shareability_tc3_i             (tagctl_shareability_tc3_i),
      .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3_i),
      .tagctl_l1_victim_cluster_unique_tc3_i (tagctl_l1_victim_cluster_unique_tc3_i),
      .tagctl_l1_victim_shareability_tc3_i   (tagctl_l1_victim_shareability_tc3_i),
      .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3_i),
      .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3_i),
      .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3_i),
      .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3_i),
      .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3_i),
      .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4_i),
      .afb0_done_i                           (afb0_done_i),
      .afb1_done_i                           (afb1_done_i),
      .afb2_done_i                           (afb2_done_i),
      .afb3_done_i                           (afb3_done_i),
      .afb4_done_i                           (afb4_done_i),
      .afb5_done_i                           (afb5_done_i),
      .afb0_snoop_resp_valid_i               (afb0_snoop_resp_valid_i),
      .afb1_snoop_resp_valid_i               (afb1_snoop_resp_valid_i),
      .afb2_snoop_resp_valid_i               (afb2_snoop_resp_valid_i),
      .afb3_snoop_resp_valid_i               (afb3_snoop_resp_valid_i),
      .afb4_snoop_resp_valid_i               (afb4_snoop_resp_valid_i),
      .afb5_snoop_resp_valid_i               (afb5_snoop_resp_valid_i),
      .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty_i),
      .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty_i),
      .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty_i),
      .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty_i),
      .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty_i),
      .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty_i),
      .afb0_snoop_resp_alloc_i               (afb0_snoop_resp_alloc_i),
      .afb1_snoop_resp_alloc_i               (afb1_snoop_resp_alloc_i),
      .afb2_snoop_resp_alloc_i               (afb2_snoop_resp_alloc_i),
      .afb3_snoop_resp_alloc_i               (afb3_snoop_resp_alloc_i),
      .afb4_snoop_resp_alloc_i               (afb4_snoop_resp_alloc_i),
      .afb5_snoop_resp_alloc_i               (afb5_snoop_resp_alloc_i),
      .afb0_snoop_resp_migratory_i           (afb0_snoop_resp_migratory_i),
      .afb1_snoop_resp_migratory_i           (afb1_snoop_resp_migratory_i),
      .afb2_snoop_resp_migratory_i           (afb2_snoop_resp_migratory_i),
      .afb3_snoop_resp_migratory_i           (afb3_snoop_resp_migratory_i),
      .afb4_snoop_resp_migratory_i           (afb4_snoop_resp_migratory_i),
      .afb5_snoop_resp_migratory_i           (afb5_snoop_resp_migratory_i),
      .afb0_snoop_resp_victim_valid_i        (afb0_snoop_resp_victim_valid_i),
      .afb1_snoop_resp_victim_valid_i        (afb1_snoop_resp_victim_valid_i),
      .afb2_snoop_resp_victim_valid_i        (afb2_snoop_resp_victim_valid_i),
      .afb3_snoop_resp_victim_valid_i        (afb3_snoop_resp_victim_valid_i),
      .afb4_snoop_resp_victim_valid_i        (afb4_snoop_resp_victim_valid_i),
      .afb5_snoop_resp_victim_valid_i        (afb5_snoop_resp_victim_valid_i),
      .afb0_snoop_resp_victim_dirty_i        (afb0_snoop_resp_victim_dirty_i),
      .afb1_snoop_resp_victim_dirty_i        (afb1_snoop_resp_victim_dirty_i),
      .afb2_snoop_resp_victim_dirty_i        (afb2_snoop_resp_victim_dirty_i),
      .afb3_snoop_resp_victim_dirty_i        (afb3_snoop_resp_victim_dirty_i),
      .afb4_snoop_resp_victim_dirty_i        (afb4_snoop_resp_victim_dirty_i),
      .afb5_snoop_resp_victim_dirty_i        (afb5_snoop_resp_victim_dirty_i),
      .afb0_snoop_resp_victim_age_i          (afb0_snoop_resp_victim_age_i),
      .afb1_snoop_resp_victim_age_i          (afb1_snoop_resp_victim_age_i),
      .afb2_snoop_resp_victim_age_i          (afb2_snoop_resp_victim_age_i),
      .afb3_snoop_resp_victim_age_i          (afb3_snoop_resp_victim_age_i),
      .afb4_snoop_resp_victim_age_i          (afb4_snoop_resp_victim_age_i),
      .afb5_snoop_resp_victim_age_i          (afb5_snoop_resp_victim_age_i),
      .afb0_snoop_resp_victim_alloc_i        (afb0_snoop_resp_victim_alloc_i),
      .afb1_snoop_resp_victim_alloc_i        (afb1_snoop_resp_victim_alloc_i),
      .afb2_snoop_resp_victim_alloc_i        (afb2_snoop_resp_victim_alloc_i),
      .afb3_snoop_resp_victim_alloc_i        (afb3_snoop_resp_victim_alloc_i),
      .afb4_snoop_resp_victim_alloc_i        (afb4_snoop_resp_victim_alloc_i),
      .afb5_snoop_resp_victim_alloc_i        (afb5_snoop_resp_victim_alloc_i),
      .afb0_write_done_i                     (afb0_write_done_i),
      .afb1_write_done_i                     (afb1_write_done_i),
      .afb2_write_done_i                     (afb2_write_done_i),
      .afb3_write_done_i                     (afb3_write_done_i),
      .afb4_write_done_i                     (afb4_write_done_i),
      .afb5_write_done_i                     (afb5_write_done_i),
      .reqbuf_victimctl_ready_i              (reqbuf_victimctl_ready[i]),
      .victimctl_ack_i                       (victimctl_ack_i),
      .victimctl_ack_id_i                    (victimctl_ack_id_i),
      .victimctl_victim_way_i                (victimctl_victim_way_i),
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
      .l2db0_slv_err_i                       (l2db0_slv_err_i),
      .l2db1_slv_err_i                       (l2db1_slv_err_i),
      .l2db2_slv_err_i                       (l2db2_slv_err_i),
      .l2db3_slv_err_i                       (l2db3_slv_err_i),
      .l2db4_slv_err_i                       (l2db4_slv_err_i),
      .l2db5_slv_err_i                       (l2db5_slv_err_i),
      .l2db6_slv_err_i                       (l2db6_slv_err_i),
      .l2db7_slv_err_i                       (l2db7_slv_err_i),
      .l2db8_slv_err_i                       (l2db8_slv_err_i),
      .l2db9_slv_err_i                       (l2db9_slv_err_i),
      .l2db10_slv_err_i                      (l2db10_slv_err_i),
      .reqbuf_compack_ready_i                (reqbuf_compack_ready[i]),
      .master_early_dr_valid_i               (master_early_dr_valid_i),
      .master_early_dr_id_i                  (master_early_dr_id_i),
      .master_early_dr_dbid_i                (master_early_dr_dbid_i),
      .master_early_dr_srcid_i               (master_early_dr_srcid_i),
      .master_early_dr_barrier_i             (master_early_dr_barrier_i),
      .master_early_dr_resp_i                (master_early_dr_resp_i),
      .master_cpuslv_dr_valid_i              (master_cpuslv_dr_valid_i),
      .cpuslv_master_dr_ready_i              (cpuslv_master_dr_ready),
      .master_dr_id_i                        (master_cpuslv_dr_id_i),
      .master_dr_resp_i                      (master_dr_resp_i),
      .master_afb0_ack_i                     (master_afb0_ack_i),
      .master_afb1_ack_i                     (master_afb1_ack_i),
      .master_afb2_ack_i                     (master_afb2_ack_i),
      .master_afb3_ack_i                     (master_afb3_ack_i),
      .master_afb4_ack_i                     (master_afb4_ack_i),
      .master_afb5_ack_i                     (master_afb5_ack_i),
      .master_afb_waddr_id_i                 (master_afb_waddr_id_i),
      .master_cpuslv_waddrs_valid_i          (master_cpuslv_waddrs_valid_i),
      .master_cpuslv_barrier_db_valid_i      (master_cpuslv_barrier_db_valid_i),
      .master_db_resp_i                      (master_db_resp_i),
      .master_db_waddr_valid_i               (master_db_waddr_valid_i),
      .master_db_waddr_i                     (master_db_waddr_i),
      .master_cpuslv_l2_waiting_i            (master_cpuslv_l2_waiting_i[i]),
      .master_rsp_readreceipt_valid_i        (master_rsp_readreceipt_valid_i),
      .master_rsp_comp_valid_i               (master_rsp_comp_valid_i),
      .master_rsp_dbid_valid_i               (master_rsp_dbid_valid_i),
      .master_rsp_txnid_i                    (master_rsp_txnid_i),
      .master_rsp_dbid_i                     (master_rsp_dbid_i),
      .master_rsp_srcid_i                    (master_rsp_srcid_i),
      .master_rsp_resp_i                     (master_rsp_resp_i),
      .reqbuf_retry_i                        (master_cpuslv_reqbuf_retry_i[i]),
      .reqbuf_retry_pcrdtype_i               (master_cpuslv_pcrdtype_i),
      .reqbuf_rr_ready_i                     (reqbuf_rr_ready[i]),
      .scu_dr_valid_i                        (scu_dr_valid),
      .scu_rr_valid_i                        (scu_rr_valid),
      .scu_dr_id_i                           (scu_dr_id),
      .scu_rr_id_i                           (scu_rr_id),
      .reqbufs_older_i                       (reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS]),
      .dvm_comp_sync_outstanding_i           (dvm_comp_sync_outstanding_i),
      // Outputs
      .reqbuf_active_o                       (reqbuf_active[i]),
      .reqbuf_busy_o                         (reqbuf_busy[i]),
      .reqbuf_ar_return_credit_o             (reqbuf_ar_return_credit[i]),
      .reqbuf_dvm_part_two_o                 (reqbuf_dvm_part_two[i]),
      .reqbuf_hz_tc1_o                       (reqbuf_hz_tc1[i]),
      .reqbuf_snp_hz_tc1_o                   (reqbuf_snp_hz_tc1[i]),
      .reqbuf_snp_l2db_hz_tc1_o              (reqbuf_snp_l2db_hz_tc1[i]),
      .reqbuf_snp_l2db_dirty_tc1_o           (reqbuf_snp_l2db_dirty_tc1[i]),
      .reqbuf_ecc_hz_tc1_o                   (reqbuf_ecc_hz_tc1[i]),
      .reqbuf_force_miss_tc1_o               (reqbuf_force_miss_tc1[i]),
      .reqbuf_l2_way_used_tc1_o              (reqbuf_l2_way_used_tc1[i]),
      .reqbuf_l2_way_used_vc1_o              (reqbuf_l2_way_used_vc1[i]),
      .reqbuf_hz_tc3_o                       (reqbuf_hz_tc3[i]),
      .reqbuf_drain_stb_o                    (reqbuf_drain_stb[i]),
      .reqbuf_keep_order_o                   (reqbuf_keep_order[i]),
      .reqbuf_dvm_o                          (reqbuf_dvm[i]),
      .reqbuf_dvm_sync_o                     (reqbuf_dvm_sync[i]),
      .reqbuf_coh_o                          (reqbuf_coh[i]),
      .reqbuf_noncoh_only_o                  (reqbuf_noncoh_only[i]),
      .reqbuf_tagctl_valid_tc0_o             (reqbuf_tagctl_valid_tc0[i]),
      .reqbuf_tagctl_prearb_req_o            (reqbuf_tagctl_prearb_req[i]),
      .reqbuf_tagctl_prearb_pri1_o           (reqbuf_tagctl_prearb_pri1[i]),
      .reqbuf_tagctl_prearb_pri2_o           (reqbuf_tagctl_prearb_pri2[i]),
      .reqbuf_tagctl_primary_tc0_o           (reqbuf_tagctl_primary_tc0[i]),
      .reqbuf_update_primary_pass_o          (reqbuf_update_primary_pass[i]),
      .reqbuf_update_victim_pass_o           (reqbuf_update_victim_pass[i]),
      .reqbuf_l2dbs_active_o                 (reqbuf_l2dbs_active[i]),
      .reqbuf_tagctl_pass_tc0_o              (reqbuf_tagctl_pass_tc0[i]),
      .reqbuf_tagctl_addr1_tc0_o             (reqbuf_tagctl_addr1_tc0[i]),
      .reqbuf_tagctl_wr_state_tc0_o          (reqbuf_tagctl_wr_state_tc0[i]),
      .reqbuf_tagctl_ways_tc0_o              (reqbuf_tagctl_ways_tc0[i]),
      .reqbuf_tagctl_write_tc0_o             (reqbuf_tagctl_write_tc0[i]),
      .reqbuf_type_o                         (reqbuf_type[i]),
      .reqbuf_l2flushreq_o                   (reqbuf_l2flushreq[i]),
      .reqbuf_dcu_o                          (reqbuf_dcu[i]),
      .reqbuf_addr2_o                        (reqbuf_addr2[i]),
      .reqbuf_len_o                          (reqbuf_len[i]),
      .reqbuf_size_o                         (reqbuf_size[i]),
      .reqbuf_lock_o                         (reqbuf_lock[i]),
      .reqbuf_dirty_o                        (reqbuf_dirty[i]),
      .reqbuf_cluster_unique_o               (reqbuf_cluster_unique[i]),
      .reqbuf_attrs_o                        (reqbuf_attrs[i]),
      .reqbuf_prot_o                         (reqbuf_prot[i]),
      .reqbuf_biu_id_o                       (reqbuf_biu_id[i]),
      .reqbuf_static_pcredit_tc1_o           (reqbuf_static_pcredit_tc1[i]),
      .reqbuf_pcrdtype_tc1_o                 (reqbuf_pcrdtype_tc1[i]),
      .reqbuf_victim_way_tc1_o               (reqbuf_victim_way_tc1[i]),
      .reqbuf_l2db_full_o                    (reqbuf_l2db_full[i]),
      .reqbuf_l2db_tc1_o                     (reqbuf_l2db_tc1[i]),
      .reqbuf_l2db_primary_transfer_o        (reqbuf_l2db_primary_transfer[i]),
      .reqbuf_l2db_primary_id_o              (reqbuf_l2db_primary_id[i]),
      .reqbuf_l2db_primary_transfer_type_o   (reqbuf_l2db_primary_transfer_type[i]),
      .reqbuf_l2db_primary_transfer_info_o   (reqbuf_l2db_primary_transfer_info[i]),
      .reqbuf_l2db_primary_release_o         (reqbuf_l2db_primary_release[i]),
      .reqbuf_l2db_primary_dr_valid_o        (reqbuf_l2db_primary_dr_valid[i]),
      .reqbuf_l2db_victim_transfer_o         (reqbuf_l2db_victim_transfer[i]),
      .reqbuf_l2db_victim_id_o               (reqbuf_l2db_victim_id[i]),
      .reqbuf_l2db_victim_transfer_type_o    (reqbuf_l2db_victim_transfer_type[i]),
      .reqbuf_l2db_victim_transfer_info_o    (reqbuf_l2db_victim_transfer_info[i]),
      .reqbuf_l2db_victim_release_o          (reqbuf_l2db_victim_release[i]),
      .reqbuf_l2db_victim_release_tc3_o      (reqbuf_l2db_victim_release_tc3[i]),
      .reqbuf_victimctl_active_o             (reqbuf_victimctl_active[i]),
      .reqbuf_victimctl_valid_o              (reqbuf_victimctl_valid[i]),
      .reqbuf_victimctl_index_o              (reqbuf_victimctl_index[i]),
      .reqbuf_victimctl_wr_o                 (reqbuf_victimctl_wr[i]),
      .reqbuf_victimctl_age_o                (reqbuf_victimctl_age[i]),
      .reqbuf_victimctl_nontemp_o            (reqbuf_victimctl_nontemp[i]),
      .reqbuf_victimctl_way_o                (reqbuf_victimctl_way[i]),
      .reqbuf_compack_active_o               (reqbuf_compack_active[i]),
      .reqbuf_compack_valid_o                (reqbuf_compack_valid[i]),
      .reqbuf_compack_tgtid_o                (reqbuf_compack_tgtid[i]),
      .reqbuf_compack_txnid_o                (reqbuf_compack_txnid[i]),
      .reqbuf_ext_strex_o                    (reqbuf_ext_strex[i]),
      .reqbuf_ext_decerr_o                   (reqbuf_ext_decerr[i]),
      .reqbuf_ext_slverr_o                   (reqbuf_ext_slverr[i]),
      .reqbuf_early_dr_l2_o                  (reqbuf_early_dr_l2[i]),
      .reqbuf_early_dr_index_o               (reqbuf_early_dr_index[i]),
      .reqbuf_early_dr_way_o                 (reqbuf_early_dr_way[i]),
      .reqbuf_rr_valid_o                     (reqbuf_rr_valid[i]),
      .reqbuf_rr_cancel_o                    (reqbuf_rr_cancel[i]),
      .reqbuf_rr_l2db_id_o                   (reqbuf_rr_l2db_id[i]),
      .reqbuf_rr_resp_o                      (reqbuf_rr_resp[i]),
      .reqbuf_dr_resp_o                      (reqbuf_dr_resp[i]),
      .reqbuf_dmb_resp_o                     (reqbuf_dmb_resp[i]),
      .reqbuf_dsb_resp_o                     (reqbuf_dsb_resp[i]),
      .reqbuf_sample_waddrs_o                (reqbuf_sample_waddrs[i]),
      .reqbuf_sample_waddrs_dsb_o            (reqbuf_sample_waddrs_dsb[i]),
      .reqbuf_dvm_sync_busy_o                (reqbuf_dvm_sync_busy[i]),
      .reqbuf_ev_done_o                      (reqbuf_ev_done[i]),
      .reqbuf_ev_done_id_o                   (reqbuf_ev_done_id[i]),
      .reqbuf_leave_ramode_o                 (reqbuf_leave_ramode[i]),
      .reqbuf_suppress_dr_o                  (reqbuf_suppress_dr[i]),
      .reqbuf_early_dr_ready_o               (cpuslv_early_dr_ready_o[i]),
      .reqbuf_delay_allocation_o             (cpuslv_delay_allocation_o[i]),
      .reqbuf_ramctl_active_o                (reqbuf_ramctl_active[i]),
      .reqbuf_evnt_snooped_data_o            (reqbuf_evnt_snooped_data[i]),
      .reqbuf_evnt_l2_access_o               (reqbuf_evnt_l2_access[i])
    );
  end


  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_ar_type encodings as as expected")
  u_ovl_type_enc1 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (biu_ar_valid_i & ((biu_ar_type_i == `CA53_REQ_WRITENOSNOOP) |
                                        (biu_ar_type_i == `CA53_REQ_WRITEUNIQUE) |
                                        (biu_ar_type_i == `CA53_REQ_DVM))),
    .consequent_expr ({3'b000, biu_ar_type_i[4]} == `CA53_TAGCTL_PASS_L2DB)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "biu_ar_type encodings as as expected")
  u_ovl_type_enc2 (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (biu_ar_valid_i & ~((biu_ar_type_i == `CA53_REQ_WRITENOSNOOP) |
                                         (biu_ar_type_i == `CA53_REQ_WRITEUNIQUE) |
                                         (biu_ar_type_i == `CA53_REQ_DVM))),
    .consequent_expr ({3'b000, biu_ar_type_i[4]} == `CA53_TAGCTL_PASS_SERIALISE)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "scu_ar_credit matches reqbuf states")
  u_ovl_ar_credit (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ar_credit),
    .consequent_expr (~&reqbuf_busy)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock must be enabled when snoop requests and responses are in progress")
  u_ovl_snp_clk_en (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (tagctl_cpuslv_ac_valid_i |
                      scu_ac_valid |
                      dcu_cr_valid_i |
                      cpuslv_cr_valid |
                      biu_dw_valid_i |
                      cpuslv_l2dbs_dw_valid),
    .consequent_expr (snp_clk_enable)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock must be enabled when read data returned")
  u_ovl_dr_clk_en (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (scu_dr_en |
                      scu_dr_early_valid |
                      dr_arb_req |
                      dr_credit |
                      biu_dr_credit_i),
    .consequent_expr (dr_clk_enable)
  );

  if (L2_CACHE) begin : g_ovl_l2cache

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "BIU must not send a request while an L2 flush is active")
    u_ovl_ar_valid_flush (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (l2_flush_active),
      .consequent_expr (~biu_ar_valid_i)
    );

  end

  if (!L2_CACHE) begin : g_ovl_n_l2cache

    assert_never #(`OVL_FATAL, `OVL_ASSERT, "l2_flush_active must never be asserted if no L2 present")
    u_ovl_no_l2flush_active (
      .clk             (clk),
      .reset_n         (reset_n),
      .test_expr       (l2_flush_active)
    );

  end

  if (SCU_CACHE_PROTECTION) begin : g_ovl_scu_ecc

    wire [6:0]  ovl_l2_ecc;
    wire [32:0] ovl_l2_data;

    assign ovl_l2_data = {cpuslv_tagctl_wr_state_tc0[16:12],
                          reqbufs_tagctl_addr1_tc0[40:17],
                          reqbufs_tagctl_addr1_tc0[16:13] & ~config_l2_size_i};

    ca53_ecc_generate33 u_ovl_ecc_generate (
      .data_i (ovl_l2_data),
      .ecc_o  (ovl_l2_ecc)
    );

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L2 ECC correct")
    u_ovl_l2_ecc (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (cpuslv_tagctl_valid_tc0_o & |cpuslv_tagctl_ways_tc0_o[31:16] & cpuslv_tagctl_write_tc0_o[4]),
      .consequent_expr (cpuslv_tagctl_ecc_tc0_o[34:28] == ovl_l2_ecc)
    );
  end

  if (CPU_CACHE_PROTECTION) begin : g_ovl_cpu_ecc

    for (i = 0; i < 4; i = i + 1) begin : g_state_ecc

      wire [6:0]  ovl_l1_ecc;
      wire [32:0] ovl_l1_data;

      assign ovl_l1_data = {cpuslv_tagctl_wr_state_tc0[i*3+:3],
                            reqbufs_tagctl_addr1_tc0[40:14],
                            reqbufs_tagctl_addr1_tc0[13:11] & ~config_l1_dc_size_i};

      ca53_ecc_generate33 u_ovl_ecc_generate (
        .data_i (ovl_l1_data),
        .ecc_o  (ovl_l1_ecc)
      );

      assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L1 ECC correct")
      u_ovl_l1_ecc (
        .clk             (clk),
        .reset_n         (reset_n),
        .antecedent_expr (cpuslv_tagctl_valid_tc0_o & |cpuslv_tagctl_ways_tc0_o[i*4+:4] & cpuslv_tagctl_write_tc0_o[i]),
        .consequent_expr (cpuslv_tagctl_ecc_tc0_o[i*7+:7] == ovl_l1_ecc)
      );

    end
  end

  assert_zero_one_hot #(`OVL_FATAL, NUM_REQBUFS, `OVL_ASSERT, "At most one serialised reqbuf can match a snoop")
  u_ovl_snp_hz (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (tagctl_addr_valid_tc1_i ? reqbuf_snp_hz_tc1 : {NUM_REQBUFS{1'b0}})
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_compack_ready_en")
  u_ovl_x_reqbuf_compack_ready_en (.clk       (clk_reqbufs),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (reqbuf_compack_ready_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: leaving_reset_i")
  u_ovl_x_leaving_reset_i (.clk       (clk_reqbufs),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (leaving_reset_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbufs_active")
  u_ovl_x_reqbufs_active (.clk       (clk_reqbufs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (reqbufs_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_ev_done_en")
  u_ovl_x_scu_ev_done_en (.clk       (clk_reqbufs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (scu_ev_done_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_flush_index_en")
  u_ovl_x_l2_flush_index_en (.clk       (clk_reqbufs),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (l2_flush_index_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_flush_way_en")
  u_ovl_x_l2_flush_way_en (.clk       (clk_reqbufs),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (l2_flush_way_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_prearb_en")
  u_ovl_x_tagctl_prearb_en (.clk       (clk_reqbufs),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (tagctl_prearb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_arb_en")
  u_ovl_x_dr_arb_en (.clk       (clk_reqbufs),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (dr_arb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_credits_used_en")
  u_ovl_x_dr_credits_used_en (.clk       (CLKIN),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dr_credits_used_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_arb_tc1_en")
  u_ovl_x_reqbuf_arb_tc1_en (.clk       (clk_reqbufs),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_arb_tc1_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable x-check")
  u_ovl_x_reqbuf_clk_enable (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable x-check")
  u_ovl_x_dr_clk_enable (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (dr_clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable x-check")
  u_ovl_x_snp_clk_enable (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (snp_clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ac_en")
  u_ovl_x_ac_en (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (ac_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_dw_valid_i")
  u_ovl_x_biu_dw_valid_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (biu_dw_valid_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dcu_cr_valid_i")
  u_ovl_x_dcu_cr_valid_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (dcu_cr_valid_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_scu_dr_early_valid")
  u_ovl_x_next_scu_dr_early_valid (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (next_scu_dr_early_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_dr_en")
  u_ovl_x_scu_dr_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (scu_dr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_scu_rr_valid")
  u_ovl_x_next_scu_rr_valid (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (next_scu_rr_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_db_dev_excl_en")
  u_ovl_x_scu_db_dev_excl_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (scu_db_dev_excl_en));


`endif

end else begin : g_no_cpuslv
  // CPU not present, so tie off all outputs
  assign cpuslv_active_o = 1'b0;
  assign cpuslv_wfx_active_o = 1'b0;
  assign scu_ar_credit_o = 1'b0;
  assign scu_ar_block_o = 1'b0;
  assign scu_dr_valid_o = 1'b0;
  assign scu_dr_id_o = {5{1'b0}};
  assign scu_dr_resp_o = {6{1'b0}};
  assign scu_dr_chunk_o = {2{1'b0}};
  assign scu_dr_data_o = {128{1'b0}};
  assign scu_rr_valid_o = 1'b0;
  assign scu_rr_id_o = {5{1'b0}};
  assign scu_rr_resp_o = {2{1'b0}};
  assign scu_rr_l2db_id_o = {4{1'b0}};
  assign scu_ev_done_o = {8{1'b0}};
  assign scu_db_excl_valid_o = 1'b0;
  assign scu_db_excl_resp_o = {2{1'b0}};
  assign scu_db_decerr_o = 1'b0;
  assign scu_db_slverr_o = 1'b0;
  assign scu_leave_ramode_o = 1'b0;
  assign scu_ac_valid_o = 1'b0;
  assign scu_ac_snoop_o = {4{1'b0}};
  assign scu_ac_id_o = {3{1'b0}};
  assign scu_ac_l2db_id_o = {4{1'b0}};
  assign scu_ac_addr_o = {41{1'b0}};
  assign scu_ac_way_o = {4{1'b0}};
  assign scu_inv_all_ack_o = 1'b0;
  assign cpuslv_cr_valid_o = 1'b0;
  assign cpuslv_cr_id_o = {3{1'b0}};
  assign cpuslv_cr_dirty_o = 1'b0;
  assign cpuslv_cr_age_o = 1'b0;
  assign cpuslv_cr_alloc_o = 1'b0;
  assign cpuslv_cr_migratory_o = 1'b0;
  assign cpuslv_ac_ready_o = 1'b0;
  assign cpuslv_tagctl_valid_tc0_o = 1'b0;
  assign cpuslv_tagctl_early_valid_tc0_o = 1'b0;
  assign cpuslv_tagctl_spec_valid_tc0_o = 1'b0;
  assign cpuslv_tagctl_reqbufid_tc0_o = {3{1'b0}};
  assign cpuslv_tagctl_pass_tc0_o = {4{1'b0}};
  assign cpuslv_tagctl_addr1_tc0_o = {41{1'b0}};
  assign cpuslv_tagctl_dvm_sync_tc0_o = 1'b0;
  assign cpuslv_tagctl_wr_state_tc0_o = {17{1'b0}};
  assign cpuslv_tagctl_ecc_tc0_o = {35{1'b0}};
  assign cpuslv_tagctl_ways_tc0_o = {32{1'b0}};
  assign cpuslv_tagctl_write_tc0_o = {5{1'b0}};
  assign cpuslv_tagctl_type_tc0_o = {5{1'b0}};
  assign cpuslv_tagctl_l2flushreq_tc0_o = 1'b0;
  assign cpuslv_tagctl_reqbuf_dcu_tc1_o = 1'b0;
  assign cpuslv_tagctl_addr2_tc1_o = {41{1'b0}};
  assign cpuslv_tagctl_len_tc1_o = {2{1'b0}};
  assign cpuslv_tagctl_size_tc1_o = {3{1'b0}};
  assign cpuslv_tagctl_lock_tc1_o = 1'b0;
  assign cpuslv_tagctl_dirty_tc1_o = 1'b0;
  assign cpuslv_tagctl_cluster_unique_tc1_o = 1'b0;
  assign cpuslv_tagctl_attrs_tc1_o = {8{1'b0}};
  assign cpuslv_tagctl_prot_tc1_o = {2{1'b0}};
  assign cpuslv_tagctl_l2db_tc1_o = {4{1'b0}};
  assign cpuslv_tagctl_l2db_full_tc1_o = 1'b0;
  assign cpuslv_hz_tc2_o = 1'b0;
  assign cpuslv_snp_hz_tc2_o = 1'b0;
  assign cpuslv_snp_hz_id_tc2_o = 3'b000;
  assign cpuslv_snp_l2db_hz_tc2_o = 1'b0;
  assign cpuslv_snp_l2db_dirty_tc2_o = 1'b0;
  assign cpuslv_snp_l2db_tc2_o = {4{1'b0}};
  assign cpuslv_ecc_hz_tc2_o = 1'b0;
  assign cpuslv_force_miss_tc2_o = {32{1'b0}};
  assign cpuslv_l2_way_used_tc2_o = {16{1'b0}};
  assign cpuslv_hz_tc4_o = 1'b0;
  assign scu_drain_stb_o = 1'b0;
  assign cpuslv_noncoh_since_barrier_o = 1'b0;
  assign cpuslv_dvm_sync_resp_o = 1'b0;
  assign cpuslv_ramctl_active_o = 1'b0;
  assign cpuslv_l2dbs_active_o = 1'b0;
  assign cpuslv_l2db0_transfer_o = 1'b0;
  assign cpuslv_l2db0_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db0_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db0_release_o = 1'b0;
  assign cpuslv_l2db1_transfer_o = 1'b0;
  assign cpuslv_l2db1_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db1_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db1_release_o = 1'b0;
  assign cpuslv_l2db2_transfer_o = 1'b0;
  assign cpuslv_l2db2_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db2_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db2_release_o = 1'b0;
  assign cpuslv_l2db3_transfer_o = 1'b0;
  assign cpuslv_l2db3_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db3_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db3_release_o = 1'b0;
  assign cpuslv_l2db4_transfer_o = 1'b0;
  assign cpuslv_l2db4_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db4_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db4_release_o = 1'b0;
  assign cpuslv_l2db5_transfer_o = 1'b0;
  assign cpuslv_l2db5_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db5_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db5_release_o = 1'b0;
  assign cpuslv_l2db6_transfer_o = 1'b0;
  assign cpuslv_l2db6_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db6_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db6_release_o = 1'b0;
  assign cpuslv_l2db7_transfer_o = 1'b0;
  assign cpuslv_l2db7_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db7_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db7_release_o = 1'b0;
  assign cpuslv_l2db8_transfer_o = 1'b0;
  assign cpuslv_l2db8_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db8_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db8_release_o = 1'b0;
  assign cpuslv_l2db9_transfer_o = 1'b0;
  assign cpuslv_l2db9_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db9_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db9_release_o = 1'b0;
  assign cpuslv_l2db10_transfer_o = 1'b0;
  assign cpuslv_l2db10_transfer_type_o = {3{1'b0}};
  assign cpuslv_l2db10_transfer_info_o = {24{1'b0}};
  assign cpuslv_l2db10_release_o = 1'b0;
  assign cpuslv_early_dr_l2_o = 1'b0;
  assign cpuslv_early_dr_index_o = {11{1'b0}};
  assign cpuslv_early_dr_way_o = {4{1'b0}};
  assign cpuslv_early_dr_ready_o = {8{1'b0}};
  assign cpuslv_delay_allocation_o = {8{1'b0}};
  assign cpuslv_master_dr_ready_o = 1'b0;
  assign cpuslv_master_sactive_o = 1'b0;
  assign cpuslv_sample_waddrs_o = 1'b0;
  assign cpuslv_sample_waddrs_dsb_o = 1'b0;
  assign scu_reqbufs_busy_o = {8{1'b0}};
  assign cpuslv_l2db0_ready_o = 1'b0;
  assign cpuslv_l2db1_ready_o = 1'b0;
  assign cpuslv_l2db2_ready_o = 1'b0;
  assign cpuslv_l2db3_ready_o = 1'b0;
  assign cpuslv_l2db4_ready_o = 1'b0;
  assign cpuslv_l2db5_ready_o = 1'b0;
  assign cpuslv_l2db6_ready_o = 1'b0;
  assign cpuslv_l2db7_ready_o = 1'b0;
  assign cpuslv_l2db8_ready_o = 1'b0;
  assign cpuslv_l2db9_ready_o = 1'b0;
  assign cpuslv_l2db10_ready_o = 1'b0;
  assign cpuslv_l2dbs_dw_valid_o = 1'b0;
  assign cpuslv_l2dbs_dw_id_o = {4{1'b0}};
  assign cpuslv_l2dbs_dw_chunks_valid_o = {4{1'b0}};
  assign cpuslv_l2dbs_dw_last_o = 1'b0;
  assign cpuslv_l2dbs_dw_data_o = {256{1'b0}};
  assign cpuslv_l2dbs_dw_strb_o = {32{1'b0}};
  assign cpuslv_l2dbs_dw_err_o = 1'b0;
  assign cpuslv_l2dbs_dw_fatal_o = 1'b0;
  assign cpuslv_inv_all_starting_o = 1'b0;
  assign cpuslv_compack_active_o = 1'b0;
  assign cpuslv_compack_valid_o = 1'b0;
  assign cpuslv_compack_tgtid_o = {7{1'b0}};
  assign cpuslv_compack_txnid_o = {8{1'b0}};
  assign cpuslv_tagctl_static_pcredit_tc1_o = 1'b0;
  assign cpuslv_tagctl_pcrdtype_tc1_o = {2{1'b0}};
  assign cpuslv_tagctl_victim_way_tc1_o = {4{1'b0}};
  assign cpuslv_l2flushdone_o = 1'b0;
  assign cpuslv_l2flush_active_o = 1'b0;
  assign cpuslv_victimctl_active_o = 1'b0;
  assign cpuslv_victimctl_valid_o = 1'b0;
  assign cpuslv_victimctl_index_o = {11{1'b0}};
  assign cpuslv_victimctl_wr_o = 1'b0;
  assign cpuslv_victimctl_age_o = 1'b0;
  assign cpuslv_victimctl_iside_o = 1'b0;
  assign cpuslv_victimctl_nontemp_o = 1'b0;
  assign cpuslv_victimctl_way_o = {4{1'b0}};
  assign cpuslv_victimctl_id_o = {3{1'b0}};
  assign cpuslv_l2_way_used_vc2_o = {16{1'b0}};
  assign scu_evnt_eviction_o = 1'b0;
  assign scu_evnt_snooped_data_o = 1'b0;
  assign scu_evnt_l2_access_o = 1'b0;

end endgenerate


endmodule // ca53scu_cpuslv

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_scu_dcu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
