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
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"


module ca53scu_reqbuf_cpu #(`CA53_SCU_INT_PARAM_DECL, parameter NUM_REQBUFS = 1, parameter REQBUF_ID = 6'b000000)
 (
  input  wire                   clk,
  input  wire                   reset_n,
  input  wire                   DFTSE,

  input  wire                   cpuslv_broadcastinner_i,
  input  wire                   cpuslv_broadcastouter_i,
  input  wire                   cpuslv_broadcastcachemaint_i,
  input  wire                   config_sysbardisable_i,
  input  wire [2:0]             cpuslv_l1_dc_size_i,
  input  wire [3:0]             cpuslv_l2_size_i,
  input  wire                   cpuslv_enable_writeevict_i,

  // BIU interface
  output wire                   reqbuf_active_o,
  output wire                   reqbuf_busy_o,
  output wire                   reqbuf_dvm_sync_busy_o,
  output wire                   reqbuf_ar_return_credit_o,
  input  wire                   reqbuf_ar_credit_ready_i,
  output wire                   reqbuf_dvm_part_two_o,
  input  wire                   reqbuf_enable_i,
  input  wire                   reqbuf_spec_enable_i,
  input  wire                   reqbuf_alloc_i,
  input  wire                   reqbuf_allocated_i,
  input  wire                   ar_valid_i,
  input  wire [4:0]             ar_id_i,
  input  wire [4:0]             ar_type_i,
  input  wire [7:0]             ar_attrs_i,
  input  wire [3:0]             ar_way_i,
  input  wire [40:0]            ar_addr_i,
  input  wire [1:0]             ar_len_i,
  input  wire [2:0]             ar_size_i,
  input  wire                   ar_lock_i,
  input  wire                   ar_priv_i,

  input  wire                   cpuslv_l2dbs_dw_valid_i,
  input  wire                   cpuslv_l2dbs_dw_last_i,
  input  wire [3:0]             cpuslv_l2dbs_dw_id_i,

  // Hazarding
  input  wire [41:6]            tagctl_addr_tc1_i,
  input  wire                   tagctl_valid_tc1_i,
  input  wire                   tagctl_addr_valid_tc1_i,
  input  wire                   tagctl_index_valid_tc1_i,
  input  wire                   tagctl_l1_set_way_op_tc1_i,
  input  wire                   tagctl_l1_lf_tc1_i,
  input  wire                   tagctl_serialising_tc1_i,
  input  wire                   tagctl_ecc_wr_tc1_i,
  input  wire [15:0]            tagctl_ecc_way_tc1_i,
  input  wire [5:0]             tagctl_reqbufid_tc1_i,
  input  wire                   tagctl_cpu_sync_tc1_i,
  input  wire                   tagctl_snp_sync_tc1_i,
  output wire                   reqbuf_hz_tc1_o,
  output wire                   reqbuf_snp_hz_tc1_o,
  output wire                   reqbuf_snp_l2db_hz_tc1_o,
  output wire                   reqbuf_snp_l2db_dirty_tc1_o,
  output wire                   reqbuf_ecc_hz_tc1_o,
  output wire [31:0]            reqbuf_force_miss_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_vc1_o,
  input  wire [10:0]            victimctl_index_vc1_i,
  input  wire [40:6]            tagctl_addr_tc3_i,
  input  wire                   tagctl_addr_valid_tc3_i,
  input  wire [5:0]             tagctl_reqbufid_tc3_i,
  output wire                   reqbuf_hz_tc3_o,
  output wire                   reqbuf_drain_stb_o,
  input  wire [NUM_REQBUFS-1:0] reqbufs_older_i,
  input  wire [NUM_REQBUFS-1:0] reqbufs_keep_order_i,
  input  wire [NUM_REQBUFS-1:0] reqbufs_busy_i,
  input  wire [NUM_REQBUFS-1:0] reqbufs_dvm_i,
  input  wire [NUM_REQBUFS-1:0] reqbufs_coh_i,
  output wire                   reqbuf_keep_order_o,
  output wire                   reqbuf_dvm_o,
  output wire                   reqbuf_coh_o,
  output wire                   reqbuf_noncoh_only_o,
  output wire                   reqbuf_dvm_sync_o,
  input  wire                   dvm_comp_sync_outstanding_i,

  // Tagctl requests
  input  wire                   cpuslv_noncoh_only_i,
  input  wire [NUM_REQBUFS-1:0] reqbufs_noncoh_only_i,
  input  wire                   reqbuf_tagctl_prearb_primary_i,
  input  wire                   reqbuf_tagctl_prearb_victim_i,
  input  wire                   cpuslv_tagctl_spec_valid_tc0_i,
  output wire                   reqbuf_tagctl_valid_tc0_o,
  output wire                   reqbuf_tagctl_prearb_req_o,
  output wire                   reqbuf_tagctl_prearb_pri1_o,
  output wire                   reqbuf_tagctl_prearb_pri2_o,
  output wire                   reqbuf_tagctl_primary_tc0_o,
  output wire                   reqbuf_update_primary_pass_o,
  output wire                   reqbuf_update_victim_pass_o,
  output wire                   reqbuf_l2dbs_active_o,
  output wire [3:0]             reqbuf_tagctl_pass_tc0_o,
  output wire [40:0]            reqbuf_tagctl_addr1_tc0_o,
  output wire [16:0]            reqbuf_tagctl_wr_state_tc0_o,
  output wire [31:0]            reqbuf_tagctl_ways_tc0_o,
  output wire [4:0]             reqbuf_tagctl_write_tc0_o,
  input  wire                   reqbuf_arb_tc1_i,
  output wire [4:0]             reqbuf_type_o,
  output wire                   reqbuf_l2flushreq_o,
  output wire                   reqbuf_dcu_o,
  output wire [40:0]            reqbuf_addr2_o,
  output wire [1:0]             reqbuf_len_o,
  output wire [2:0]             reqbuf_size_o,
  output wire                   reqbuf_lock_o,
  output wire                   reqbuf_dirty_o,
  output wire                   reqbuf_cluster_unique_o,
  output wire [7:0]             reqbuf_attrs_o,
  output wire [1:0]             reqbuf_prot_o,
  output wire [4:0]             reqbuf_biu_id_o,
  output wire                   reqbuf_l2db_full_o,
  output wire                   reqbuf_static_pcredit_tc1_o,
  output wire [1:0]             reqbuf_pcrdtype_tc1_o,
  output wire [3:0]             reqbuf_victim_way_tc1_o,
  output wire [3:0]             reqbuf_l2db_tc1_o,

  input  wire                   tagctl_slv_flush_tc1_i,
  input  wire                   tagctl_slv_flush_tc2_i,
  input  wire                   tagctl_slv_flush_tc3_i,
  input  wire                   tagctl_slv_flush_tc4_i,
  input  wire                   tagctl_slv_early_flush_tc4_i,
  input  wire                   tagctl_ecc_err_tc3_i,
  input  wire [2:0]             tagctl_slv_afb_tc1_i,
  input  wire [3:0]             tagctl_slv_l2db_tc1_i,
  input  wire [3:0]             tagctl_slv_l2db_tc4_i,
  input  wire                   tagctl_slv_snp_hz_tc4_i,
  input  wire [4:0]             tagctl_slv_snp_hz_id_tc4_i,
  input  wire                   tagctl_slv_l2db_invalidated_tc4_i,
  input  wire                   tagctl_slv_l2db_cleaned_tc4_i,
  input  wire [3:0]             tagctl_slv_victim_l2db_tc4_i,
  input  wire [15:0]            tagctl_l1_hit_ways_tc3_i,
  input  wire [15:0]            tagctl_l2_hit_ways_tc3_i,
  input  wire                   tagctl_l2_dirty_tc3_i,
  input  wire                   tagctl_l2_alloc_tc3_i,
  input  wire [1:0]             tagctl_shareability_tc3_i,
  input  wire                   tagctl_cluster_unique_tc3_i,
  input  wire                   tagctl_l1_victim_cluster_unique_tc3_i,
  input  wire [1:0]             tagctl_l1_victim_shareability_tc3_i,
  input  wire                   tagctl_l2_victim_valid_tc3_i,
  input  wire [1:0]             tagctl_l2_victim_shareability_tc3_i,
  input  wire                   tagctl_l2_victim_alloc_tc3_i,
  input  wire                   tagctl_l2_victim_cu_tc3_i,
  input  wire [3:0]             tagctl_l2_victim_way_tc3_i,
  input  wire [1:0]             tagctl_snoop_data_cpu_tc4_i,
  input  wire                   afb0_done_i,
  input  wire                   afb1_done_i,
  input  wire                   afb2_done_i,
  input  wire                   afb3_done_i,
  input  wire                   afb4_done_i,
  input  wire                   afb5_done_i,
  input  wire                   afb0_snoop_resp_valid_i,
  input  wire                   afb1_snoop_resp_valid_i,
  input  wire                   afb2_snoop_resp_valid_i,
  input  wire                   afb3_snoop_resp_valid_i,
  input  wire                   afb4_snoop_resp_valid_i,
  input  wire                   afb5_snoop_resp_valid_i,
  input  wire                   afb0_snoop_resp_dirty_i,
  input  wire                   afb1_snoop_resp_dirty_i,
  input  wire                   afb2_snoop_resp_dirty_i,
  input  wire                   afb3_snoop_resp_dirty_i,
  input  wire                   afb4_snoop_resp_dirty_i,
  input  wire                   afb5_snoop_resp_dirty_i,
  input  wire                   afb0_snoop_resp_alloc_i,
  input  wire                   afb1_snoop_resp_alloc_i,
  input  wire                   afb2_snoop_resp_alloc_i,
  input  wire                   afb3_snoop_resp_alloc_i,
  input  wire                   afb4_snoop_resp_alloc_i,
  input  wire                   afb5_snoop_resp_alloc_i,
  input  wire                   afb0_snoop_resp_migratory_i,
  input  wire                   afb1_snoop_resp_migratory_i,
  input  wire                   afb2_snoop_resp_migratory_i,
  input  wire                   afb3_snoop_resp_migratory_i,
  input  wire                   afb4_snoop_resp_migratory_i,
  input  wire                   afb5_snoop_resp_migratory_i,
  input  wire                   afb0_snoop_resp_victim_valid_i,
  input  wire                   afb1_snoop_resp_victim_valid_i,
  input  wire                   afb2_snoop_resp_victim_valid_i,
  input  wire                   afb3_snoop_resp_victim_valid_i,
  input  wire                   afb4_snoop_resp_victim_valid_i,
  input  wire                   afb5_snoop_resp_victim_valid_i,
  input  wire                   afb0_snoop_resp_victim_dirty_i,
  input  wire                   afb1_snoop_resp_victim_dirty_i,
  input  wire                   afb2_snoop_resp_victim_dirty_i,
  input  wire                   afb3_snoop_resp_victim_dirty_i,
  input  wire                   afb4_snoop_resp_victim_dirty_i,
  input  wire                   afb5_snoop_resp_victim_dirty_i,
  input  wire                   afb0_snoop_resp_victim_age_i,
  input  wire                   afb1_snoop_resp_victim_age_i,
  input  wire                   afb2_snoop_resp_victim_age_i,
  input  wire                   afb3_snoop_resp_victim_age_i,
  input  wire                   afb4_snoop_resp_victim_age_i,
  input  wire                   afb5_snoop_resp_victim_age_i,
  input  wire                   afb0_snoop_resp_victim_alloc_i,
  input  wire                   afb1_snoop_resp_victim_alloc_i,
  input  wire                   afb2_snoop_resp_victim_alloc_i,
  input  wire                   afb3_snoop_resp_victim_alloc_i,
  input  wire                   afb4_snoop_resp_victim_alloc_i,
  input  wire                   afb5_snoop_resp_victim_alloc_i,
  input  wire                   afb0_write_done_i,
  input  wire                   afb1_write_done_i,
  input  wire                   afb2_write_done_i,
  input  wire                   afb3_write_done_i,
  input  wire                   afb4_write_done_i,
  input  wire                   afb5_write_done_i,
  input  wire                   cpuslv_ecc_err_tc4_i,

  // Victimctl requests
  output wire                   reqbuf_victimctl_active_o,
  output wire                   reqbuf_victimctl_valid_o,
  output wire [10:0]            reqbuf_victimctl_index_o,
  output wire                   reqbuf_victimctl_wr_o,
  output wire                   reqbuf_victimctl_age_o,
  output wire                   reqbuf_victimctl_nontemp_o,
  output wire [3:0]             reqbuf_victimctl_way_o,
  input  wire                   reqbuf_victimctl_ready_i,

  input  wire                   victimctl_ack_i,
  input  wire [5:0]             victimctl_ack_id_i,
  input  wire [3:0]             victimctl_victim_way_i,

  // CompAck requests
  output wire                   reqbuf_compack_active_o,
  output wire                   reqbuf_compack_valid_o,
  output wire [6:0]             reqbuf_compack_tgtid_o,
  output wire [7:0]             reqbuf_compack_txnid_o,
  input  wire                   reqbuf_compack_ready_i,

  // L2DB control
  output wire                   reqbuf_l2db_primary_transfer_o,
  output wire [3:0]             reqbuf_l2db_primary_id_o,
  output wire [2:0]             reqbuf_l2db_primary_transfer_type_o,
  output wire [23:0]            reqbuf_l2db_primary_transfer_info_o,
  output wire                   reqbuf_l2db_primary_release_o,
  output wire                   reqbuf_l2db_primary_dr_valid_o,

  output wire                   reqbuf_l2db_victim_transfer_o,
  output wire [3:0]             reqbuf_l2db_victim_id_o,
  output wire [2:0]             reqbuf_l2db_victim_transfer_type_o,
  output wire [23:0]            reqbuf_l2db_victim_transfer_info_o,
  output wire                   reqbuf_l2db_victim_release_o,
  output wire                   reqbuf_l2db_victim_release_tc3_o,

  input  wire                   l2db0_slv_done_i,
  input  wire                   l2db1_slv_done_i,
  input  wire                   l2db2_slv_done_i,
  input  wire                   l2db3_slv_done_i,
  input  wire                   l2db4_slv_done_i,
  input  wire                   l2db5_slv_done_i,
  input  wire                   l2db6_slv_done_i,
  input  wire                   l2db7_slv_done_i,
  input  wire                   l2db8_slv_done_i,
  input  wire                   l2db9_slv_done_i,
  input  wire                   l2db10_slv_done_i,

  input  wire                   l2db0_full_line_i,
  input  wire                   l2db1_full_line_i,
  input  wire                   l2db2_full_line_i,
  input  wire                   l2db3_full_line_i,
  input  wire                   l2db4_full_line_i,
  input  wire                   l2db5_full_line_i,
  input  wire                   l2db6_full_line_i,
  input  wire                   l2db7_full_line_i,
  input  wire                   l2db8_full_line_i,
  input  wire                   l2db9_full_line_i,
  input  wire                   l2db10_full_line_i,

  input  wire                   l2db0_rmw_line_i,
  input  wire                   l2db1_rmw_line_i,
  input  wire                   l2db2_rmw_line_i,
  input  wire                   l2db3_rmw_line_i,
  input  wire                   l2db4_rmw_line_i,
  input  wire                   l2db5_rmw_line_i,
  input  wire                   l2db6_rmw_line_i,
  input  wire                   l2db7_rmw_line_i,
  input  wire                   l2db8_rmw_line_i,
  input  wire                   l2db9_rmw_line_i,
  input  wire                   l2db10_rmw_line_i,

  input  wire                   l2db0_slv_err_i,
  input  wire                   l2db1_slv_err_i,
  input  wire                   l2db2_slv_err_i,
  input  wire                   l2db3_slv_err_i,
  input  wire                   l2db4_slv_err_i,
  input  wire                   l2db5_slv_err_i,
  input  wire                   l2db6_slv_err_i,
  input  wire                   l2db7_slv_err_i,
  input  wire                   l2db8_slv_err_i,
  input  wire                   l2db9_slv_err_i,
  input  wire                   l2db10_slv_err_i,

  output wire                   reqbuf_ramctl_active_o,

  // Master read data
  input  wire                   master_early_dr_valid_i,
  input  wire [5:0]             master_early_dr_id_i,
  input  wire [7:0]             master_early_dr_dbid_i,
  input  wire [6:0]             master_early_dr_srcid_i,
  input  wire                   master_early_dr_barrier_i,
  input  wire [3:0]             master_early_dr_resp_i,
  output wire                   reqbuf_early_dr_l2_o,
  output wire [10:0]            reqbuf_early_dr_index_o,
  output wire [3:0]             reqbuf_early_dr_way_o,
  output wire                   reqbuf_delay_allocation_o,

  input  wire                   master_cpuslv_dr_valid_i,
  input  wire                   cpuslv_master_dr_ready_i,
  input  wire [5:0]             master_dr_id_i,
  input  wire [3:0]             master_dr_resp_i,

  input  wire                   master_cpuslv_waddrs_valid_i,
  input  wire                   master_cpuslv_barrier_db_valid_i,
  input  wire [1:0]             master_db_resp_i,
  input  wire                   master_db_waddr_valid_i,
  input  wire [3:0]             master_db_waddr_i,
  output wire                   reqbuf_ext_strex_o,
  output wire                   reqbuf_ext_decerr_o,
  output wire                   reqbuf_ext_slverr_o,

  input  wire                   master_afb0_ack_i,
  input  wire                   master_afb1_ack_i,
  input  wire                   master_afb2_ack_i,
  input  wire                   master_afb3_ack_i,
  input  wire                   master_afb4_ack_i,
  input  wire                   master_afb5_ack_i,
  input  wire [3:0]             master_afb_waddr_id_i,

  input  wire                   master_cpuslv_l2_waiting_i,

  input  wire                   master_rsp_readreceipt_valid_i,
  input  wire                   master_rsp_comp_valid_i,
  input  wire                   master_rsp_dbid_valid_i,
  input  wire [6:0]             master_rsp_txnid_i,
  input  wire [7:0]             master_rsp_dbid_i,
  input  wire [6:0]             master_rsp_srcid_i,
  input  wire [3:0]             master_rsp_resp_i,

  input  wire                   reqbuf_retry_i,
  input  wire [1:0]             reqbuf_retry_pcrdtype_i,

  // CPU responses
  output wire                   reqbuf_rr_valid_o,
  output wire                   reqbuf_rr_cancel_o,
  input  wire                   reqbuf_rr_ready_i,
  output wire [3:0]             reqbuf_rr_l2db_id_o,
  output wire [1:0]             reqbuf_rr_resp_o,
  output wire                   reqbuf_ev_done_o,
  output wire [7:0]             reqbuf_ev_done_id_o,
  output wire                   reqbuf_leave_ramode_o,

  output wire                   reqbuf_early_dr_ready_o,
  output wire                   reqbuf_suppress_dr_o,
  output wire [3:0]             reqbuf_dr_resp_o,

  input  wire                   scu_dr_valid_i,
  input  wire                   scu_rr_valid_i,
  input  wire [4:0]             scu_dr_id_i,
  input  wire [4:0]             scu_rr_id_i,

  output wire                   reqbuf_dmb_resp_o,
  output wire                   reqbuf_dsb_resp_o,
  output wire                   reqbuf_sample_waddrs_o,
  output wire                   reqbuf_sample_waddrs_dsb_o,
  input  wire                   cpuslv_noncoh_since_dmb_i,
  input  wire                   cpuslv_noncoh_since_dsb_i,

  // Events
  output wire                   reqbuf_evnt_snooped_data_o,
  output wire                   reqbuf_evnt_l2_access_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE            = 5'b00000;
  localparam STATE_INITIAL         = 5'b00001;
  localparam STATE_TC0_TC1         = 5'b00011;
  localparam STATE_TC2             = 5'b00100;
  localparam STATE_TC3             = 5'b00101;
  localparam STATE_TC4             = 5'b00110;
  localparam STATE_WAIT_AFB        = 5'b00111;
  localparam STATE_WAIT_L2DB       = 5'b01000;
  localparam STATE_WAIT_EXT        = 5'b01001;
  localparam STATE_COMPACK         = 5'b01010;
  localparam STATE_WAIT_WADDR      = 5'b01011;
  localparam STATE_WAIT_VICTIM     = 5'b01100;
  localparam STATE_RESP            = 5'b01101;
  localparam STATE_WAIT_REQBUFS    = 5'b01110;
  localparam STATE_WAIT_WADDRS     = 5'b01111;
  localparam STATE_CREDIT_RETURN   = 5'b10000;
  localparam STATE_WAIT_INITIAL    = 5'b10001;
  localparam STATE_WAIT_COH        = 5'b10010;
  localparam STATE_UPDATE_VICTIM   = 5'b10011;
  localparam STATE_PICK_VICTIM_REQ = 5'b10100;
  localparam STATE_PICK_VICTIM_ACK = 5'b10101;
  localparam STATE_X               = 5'bxxxxx;

  localparam STATE_VICTIM_IDLE      = 4'b0000;
  localparam STATE_VICTIM_TC0       = 4'b0001;
  localparam STATE_VICTIM_TC0_TC1   = 4'b0010;
  localparam STATE_VICTIM_TC2       = 4'b0011;
  localparam STATE_VICTIM_TC3       = 4'b0100;
  localparam STATE_VICTIM_TC4       = 4'b0101;
  localparam STATE_VICTIM_WAIT_AFB  = 4'b0110;
  localparam STATE_VICTIM_WAIT_L2DB = 4'b0111;
  localparam STATE_VICTIM_UPDATE    = 4'b1001;
  localparam STATE_VICTIM_PICK_REQ  = 4'b1010;
  localparam STATE_VICTIM_PICK_ACK  = 4'b1011;
  localparam STATE_VICTIM_X         = 4'bxxxx;

  // Tagctl passes, tracked by reqbuf_pass. The meaning of reqbuf_pass depends
  // on the type of request.
  localparam PASS_INITIAL                   = 3'b000;
  localparam PASS_READ_SERIALISE            = 3'b000;
  localparam PASS_WRITE_L2DB                = 3'b000;
  localparam PASS_WRITE_SERIALISE           = 3'b001;
  localparam PASS_X                         = 3'bxxx;

  localparam PASS_READNOSNOOP_RETRY         = 3'b001;

  localparam PASS_READSHARED_L1_HIT         = 3'b001;
  localparam PASS_READSHARED_L2_HIT         = 3'b010;
  localparam PASS_READSHARED_RETRY          = 3'b011;
  localparam PASS_READSHARED_MISS           = 3'b100;

  localparam PASS_READUNIQUE_HIT1           = 3'b001;
  localparam PASS_READUNIQUE_HIT2           = 3'b010;
  localparam PASS_READUNIQUE_HIT_RETRY      = 3'b011;
  localparam PASS_READUNIQUE_MISS           = 3'b100;
  localparam PASS_READUNIQUE_MISS_RETRY     = 3'b101;

  localparam PASS_READONCE_RETRY            = 3'b011;
  localparam PASS_READONCE_MISS             = 3'b100;

  localparam PASS_CLEANUNIQUE_MASTER_W      = 3'b001;
  localparam PASS_CLEANUNIQUE_MASTER_R      = 3'b010;
  localparam PASS_CLEANUNIQUE_UNIQUE_UPDATE = 3'b011;
  localparam PASS_CLEANUNIQUE_CHECK         = 3'b100;
  localparam PASS_CLEANUNIQUE_UPDATE        = 3'b101;
  localparam PASS_CLEANUNIQUE_RETRY         = 3'b110;

  localparam PASS_ADDRMAINT_MASTER_W        = 3'b001;
  localparam PASS_ADDRMAINT_MASTER_R        = 3'b010;
  localparam PASS_ADDRMAINT_UPDATE          = 3'b011;
  localparam PASS_ADDRMAINT_RETRY           = 3'b100;

  localparam PASS_WRITENOSNOOP_RETRY        = 3'b010;

  localparam PASS_WRITEUNIQUE_MISS_RETRY    = 3'b010;
  localparam PASS_WRITEUNIQUE_MISS          = 3'b011;
  localparam PASS_WRITEUNIQUE_HIT_RETRY     = 3'b100;
  localparam PASS_WRITEUNIQUE_N_UNIQUE      = 3'b101;
  localparam PASS_WRITEUNIQUE_UNIQUE1       = 3'b110;
  localparam PASS_WRITEUNIQUE_UNIQUE2       = 3'b111;

  localparam PASS_DVM_RETRY                 = 3'b010;

  localparam PASS_BARRIER_RETRY             = 3'b001;

  localparam PASS_VICTIM_INITIAL = 3'b000;
  localparam PASS_VICTIM_WRITE   = 3'b001;
  localparam PASS_VICTIM_LOOKUP  = 3'b010;
  localparam PASS_VICTIM_UPDATE  = 3'b011;
  localparam PASS_VICTIM_READ    = 3'b100;
  localparam PASS_VICTIM_X       = 3'bxxx;

  reg                  clk_enable;
  reg                  clk_spec_enable;
  reg [4:0]            reqbuf_state;
  reg [3:0]            reqbuf_victim_state;

  reg [2:0]            reqbuf_pass;
  reg [2:0]            reqbuf_victim_pass;

  reg [3:0]            primary_l2db;
  reg [3:0]            victim_l2db;

  reg [4:0]            reqbuf_biu_id;
  reg [4:0]            reqbuf_type;
  reg [7:0]            reqbuf_attrs;
  reg [1:0]            reqbuf_req_way;
  reg [40:0]           reqbuf_addr1;
  reg [40:0]           reqbuf_addr2;
  reg [1:0]            reqbuf_len;
  reg [2:0]            reqbuf_size;
  reg                  reqbuf_lock;
  reg                  reqbuf_priv;

  reg [2:0]            reqbuf_afb;
  reg [2:0]            reqbuf_victim_afb;

  reg                  reqbuf_l2_hit;
  reg [3:0]            reqbuf_l2_hit_way;
  reg                  reqbuf_l2_dirty;
  reg [3:0]            reqbuf_l1_hit_cpus;
  reg [7:0]            reqbuf_l1_hit_ways;
  reg                  reqbuf_cluster_unique;
  reg [1:0]            reqbuf_shareability;
  reg                  reqbuf_victim_cu;
  reg [1:0]            reqbuf_snoop_data_cpu;
  reg                  reqbuf_l1_dirty;
  reg                  reqbuf_l1_migratory;
  reg                  reqbuf_victim_dirty;
  reg [1:0]            reqbuf_victim_shareability;
  reg                  reqbuf_victim_alloc;
  reg                  reqbuf_victim_age;
  reg                  reqbuf_l1_victim_hit;
  reg                  reqbuf_l2_victim_hit;
  reg                  reqbuf_l2_victim_valid;
  reg                  reqbuf_l2_victim_dirty;
  reg [3:0]            reqbuf_l2_victim_way;
  reg                  reqbuf_l2db_full_err;

  reg                  rr_valid_pending;
  reg                  ext_beats_received;
  reg [2:0]            ext_beats_returned;
  reg [1:0]            ext_beats_resp;
  reg                  ext_beats_shared;
  reg                  ext_beats_dirty;
  reg                  ext_snoop_invalidated;
  reg                  ext_snoop_cleaned;
  reg                  ext_readreceipt_received;
  reg                  ext_dbid_received;

  reg                  hazard_snoops;
  reg                  victim_hazard_snoops;
  reg                  reqbuf_l2db_primary_transfer;
  reg                  reqbuf_l2db_victim_transfer;
  reg                  l1_snoops_done;
  reg                  reqbuf_tagctl_req_tc0;
  reg                  reqbuf_tagctl_prearb_req;
  reg                  tag_write_needed;
  reg                  reqbuf_dvm_sync_busy;
  reg                  reqbuf_ecc_hz;
  reg [2:0]            reqbuf_l2db_primary_transfer_type;
  reg [2:0]            reqbuf_l2db_victim_transfer_type;

  wire                 clk_reqbuf;
  wire                 reqbuf_clk_enable;
  wire                 reqbuf_en;
  reg [4:0]            next_reqbuf_state;
  reg [3:0]            next_reqbuf_victim_state;
  wire                 update_reqbuf_pass;
  wire                 update_reqbuf_victim_pass;
  reg [2:0]            next_reqbuf_pass;
  reg [2:0]            next_reqbuf_victim_pass;
  wire                 require_resp_after_l2db;
  wire                 require_tagctl_after_l2db;
  wire                 require_waddr_after_l2db;
  wire                 require_update_victim_after_l2db;
  wire                 require_compack_after_l2db;
  wire                 require_victim_pick_after_l2db;
  wire                 require_tagctl_after_ext;
  wire                 require_l2db_after_ext;
  wire                 require_waddr_after_ext;
  wire                 require_resp_after_ext;
  wire                 require_compack_after_ext;
  wire                 require_victim_pick_after_ext;
  wire                 require_tagctl_after_compack;
  wire                 require_resp_after_compack;
  wire                 require_l2db_after_afb;
  wire                 require_tagctl_after_afb;
  wire                 require_victim_pick_after_afb;
  wire                 require_tagctl_after_tc2;
  wire                 require_l2db_after_tc1;
  wire                 require_update_victim_after_tc1;
  wire                 require_l2db_after_tc2;
  wire                 require_idle_after_tc2;
  wire                 require_afb_after_tc3;
  wire                 require_tagctl_after_resp;
  wire                 require_compack_after_resp;
  wire                 require_tagctl_after_update;
  wire                 require_ext_after_afb;
  wire                 require_ext_after_l2db;
  wire                 require_resp_after_afb;
  wire                 require_resp_after_tc2;
  wire                 victim_require_idle_after_tc3;
  wire                 victim_require_update_after_tc3;
  wire                 victim_require_l2db_after_afb;
  wire                 victim_require_update_after_afb;
  wire                 victim_require_tagctl_after_afb;
  wire                 victim_require_tagctl_after_l2db;
  wire                 victim_require_update_after_l2db;
  wire                 victim_require_victim_pick_after_l2db;
  wire                 reqbuf_initial;
  wire                 reqbuf_dvm_part_two;
  wire [1:0]           reqbuf_prot;
  wire                 reqbuf_addr1_en;
  wire                 reqbuf_addr2_en;
  wire [40:0]          next_reqbuf_addr2;
  wire                 reqbuf_l2_hit_tc3;
  wire                 next_reqbuf_l2_hit;
  wire [3:0]           next_reqbuf_l2_hit_way;
  wire [3:0]           reqbuf_l1_hit_cpus_tc3;
  wire [3:0]           next_reqbuf_l1_hit_cpus;
  wire [7:0]           next_reqbuf_l1_hit_ways;
  wire                 next_reqbuf_l1_dirty;
  wire                 next_reqbuf_l1_migratory;
  wire                 next_reqbuf_l1_victim_hit;
  wire                 next_reqbuf_victim_cu;
  wire [1:0]           next_reqbuf_victim_shareability;
  wire                 next_reqbuf_victim_dirty;
  wire                 next_reqbuf_victim_alloc;
  wire                 next_reqbuf_victim_age;
  wire [1:0]           next_reqbuf_shareability;
  wire                 reqbuf_l1_resp_valid;
  wire                 reqbuf_l1_resp_en;
  wire                 reqbuf_l1_resp_victim_en;
  wire                 reqbuf_l1_cleanop_resp_en;
  wire                 reqbuf_resp_victim_en;
  wire                 hit_state_en_tc3;
  wire                 hit_state_en_tc4;
  wire                 hit_state_en;
  wire                 victim_hit_state_en;
  wire                 reqbuf_shareability_en;
  wire                 use_hit_shareability;
  wire                 l1_victim_hit_en;
  wire                 l2_victim_hit_en;
  wire                 l2_victim_way_en;
  wire                 victimctl_victim_ack;
  wire [3:0]           next_reqbuf_l2_victim_way;
  wire [1:0]           ar_way_enc;
  wire [3:0]           reqbuf_tagctl_pass_tc0;
  reg [3:0]            reqbuf_primary_pass_tc0;
  wire [3:0]           reqbuf_victim_pass_tc0;
  wire                 reqbuf_l2db_full_err_en;
  reg                  next_reqbuf_l2db_full_err;
  reg                  reqbuf_l2db_rmw;
  wire                 next_tag_write_needed;
  wire                 afb_done;
  wire                 victim_afb_done;
  wire                 afb_victim_write;
  wire                 afb_primary_write;
  wire [2:0]           next_reqbuf_afb;
  wire [2:0]           next_reqbuf_victim_afb;
  wire [MAX_L2DBS-1:0] l2dbs_slv_done;
  wire                 primary_l2db_done;
  wire                 victim_l2db_done;
  wire [3:0]           next_primary_l2db;
  wire                 primary_l2db_en;
  wire                 l2db_valid_tc1;
  wire                 l2db_valid_tc4;
  wire                 next_rr_valid_pending;
  wire                 new_rr_valid;
  wire                 reqbuf_rr_cancel;
  wire                 reqbuf_sample_waddrs;
  wire                 barrier_db_resp;
  wire [1:0]           cleanunique_resp;
  wire                 next_ext_beats_received;
  wire                 next_ext_snoop_invalidated;
  wire                 next_ext_snoop_cleaned;
  wire                 receiving_ext_beat;
  wire                 returning_ext_dr_beat;
  wire                 returning_ext_beat;
  wire [2:0]           next_ext_beats_returned;
  wire [1:0]           reqbuf_real_len;
  wire                 reqbuf_ext_ret_en;
  wire                 all_ext_beats_returned;
  wire                 ext_wait_done;
  wire                 reqbuf_ext_abort;
  wire                 next_ext_readreceipt_received;
  wire                 readreceipt_wait;
  wire                 reqbuf_delay_allocation;
  wire                 next_hazard_snoops;
  wire                 next_victim_hazard_snoops;
  wire                 next_l1_snoops_done;
  wire                 early_dr_match;
  wire                 snoop_tc1;
  wire                 snoop_tc3;
  wire                 addr1_l1_index_hz_tc1;
  wire                 addr1_l2_index_hz_tc1;
  wire                 addr1_addr_hz_tc1;
  wire                 addr2_l2_index_hz_tc1;
  wire                 addr2_addr_hz_tc1;
  wire                 addr1_l2_index_hz_tc3;
  wire                 addr1_addr_hz_tc3;
  wire                 addr2_l2_index_hz_tc3;
  wire                 addr2_addr_hz_tc3;
  wire                 reqbuf_hz_addr;
  wire                 reqbuf_hz_cpu_addr;
  wire                 reqbuf_keep_order;
  wire                 reqbuf_serialised_tc1;
  wire                 reqbuf_addr1_serialised_tc1;
  wire                 reqbuf_addr1_serialised_tc3;
  wire                 reqbuf_addr2_serialised;
  wire                 reqbuf_older_than_tc1;
  wire                 addr1_l2_way_unknown_tc1;
  wire                 addr1_l2_way_unknown_tc3;
  wire                 addr2_l2_way_unknown;
  wire [15:0]          requestor_way_tc1;
  wire                 l2_index_hz_tc1;
  wire                 l2_index_hz_tc3;
  wire                 addr_hz_tc1;
  wire                 cpu_hz_tc1;
  wire                 sync_hz_tc1;
  wire                 cpu_index_hz_tc1;
  wire                 l1_index_way_hz_tc1;
  wire                 reqbuf_snp_hz_tc1;
  wire                 reqbuf_snp_l2db_hz_tc1;
  wire                 reqbuf_requestor_ecc_hz_tc1;
  wire                 reqbuf_cleanunique_ecc_hz_tc1;
  wire                 reqbuf_ecc_hz_tc1;
  wire                 addr1_l2_index_hz_vc1;
  wire                 addr2_l2_index_hz_vc1;
  wire                 way_used_valid_tc1;
  wire                 way_used_l2_hit_tc1;
  wire                 way_used_l2_miss_tc1;
  wire                 way_used_victim_tc1;
  wire [3:0]           tagctl_l1_hit_ways_tc3_0;
  wire [3:0]           tagctl_l1_hit_ways_tc3_1;
  wire [3:0]           tagctl_l1_hit_ways_tc3_2;
  wire [3:0]           tagctl_l1_hit_ways_tc3_3;
  wire [3:0]           reqbuf_requestor_cpu;
  wire [15:0]          reqbuf_requestor_l1_mask;
  wire                 reqbuf_l1_hit_requestor;
  wire                 reqbuf_l1_hit_other_cpus;
  wire [7:0]           victim_attrs;
  wire [1:0]           tag_state_l1_sh_tc0;
  wire [1:0]           tag_state_l1_tc0;
  wire [4:0]           tag_state_l2_tc0;
  wire                 reqbuf_tagctl_primary_write_tc0;
  wire [3:0]           reqbuf_tagctl_l1_write_tc0;
  wire                 reqbuf_tagctl_l2_write_tc0;
  wire                 reqbuf_tagctl_valid_tc0;
  wire                 reqbuf_dvm_sync;
  wire                 dvm_sync_hazard;
  wire                 next_reqbuf_ecc_hz;
  wire                 next_reqbuf_tagctl_req_tc0;
  wire                 next_reqbuf_tagctl_prearb_req;
  wire                 reqbuf_shareable;
  wire                 set_way_nop;
  wire                 set_way_op_l1;
  wire                 set_way_op_l2;
  wire                 dvm_ext;
  wire                 cleanunique_excl_fail;
  wire                 reqbuf_ext_en;
  wire [1:0]           next_ext_beats_resp;
  wire                 next_ext_beats_shared;
  wire                 next_ext_beats_dirty;
  wire [3:0]           master_ext_resp;
  wire                 reqbuf_rsp_comp_valid;
  wire                 reqbuf_read_comp_valid;
  wire                 reqbuf_retry_seen;
  wire                 reqbuf_retry_received_en;
  wire                 ext_decerr;
  wire                 ext_slverr;
  wire                 ext_okayerr;
  wire                 ext_exokayerr;
  wire                 ev_done;
  wire                 start_victim;
  wire                 start_victim_no_flush;
  wire [15:0]          reqbuf_l1_lookup_ways_tc0;
  wire [15:0]          reqbuf_l1_requestor_update_ways_tc0;
  wire [15:0]          reqbuf_l1_other_update_ways_tc0;
  reg  [31:0]          reqbuf_primary_tagctl_ways_tc0;
  reg [31:0]           reqbuf_victim_tagctl_ways_tc0;
  wire [31:0]          reqbuf_setway_ways_tc0;
  wire                 reqbuf_l1_hit;
  wire [1:0]           reqbuf_l1_hit_ways_0;
  wire [1:0]           reqbuf_l1_hit_ways_1;
  wire [1:0]           reqbuf_l1_hit_ways_2;
  wire [1:0]           reqbuf_l1_hit_ways_3;
  wire [31:0]          reqbuf_hit_ways;
  wire                 reqbuf_l2db_primary_transfer_tc3;
  wire                 reqbuf_l2db_primary_transfer_tc4;
  wire                 reqbuf_l2db_victim_transfer_tc3;
  wire                 reqbuf_l2db_victim_transfer_tc4;
  wire                 next_reqbuf_l2db_primary_transfer;
  wire                 next_reqbuf_l2db_victim_transfer;
  reg [2:0]            next_reqbuf_l2db_victim_transfer_type;
  wire [2:0]           victim_opcode;
  wire [1:0]           set_way_l1_way;
  wire [3:0]           set_way_l2_way;
  wire                 reqbuf_state_tc1;
  wire                 reqbuf_state_tc0_tc1;
  wire                 reqbuf_next_state_tc0_tc1;
  wire                 reqbuf_victim_state_tc1;
  wire                 reqbuf_victim_next_state_tc0_tc1;
  wire                 reqbuf_tagctl_primary_tc0;
  reg [2:0]            next_reqbuf_l2db_primary_transfer_type;
  wire [23:0]          primary_slv_transfer_info;
  wire [23:0]          primary_master_transfer_info;
  wire [23:0]          primary_ram_transfer_info;
  reg [23:0]           reqbuf_l2db_primary_transfer_info;
  wire [23:0]          victim_slv_transfer_info;
  wire [23:0]          victim_master_transfer_info;
  wire [23:0]          victim_ram_transfer_info;
  reg [23:0]           reqbuf_l2db_victim_transfer_info;
  wire                 victim_l2db_en;
  wire [3:0]           next_victim_l2db;
  wire                 primary_master_ack;
  wire                 reqbuf_suppress_early_dr;
  wire                 reqbuf_suppress_barrier_dr;
  wire                 reqbuf_suppress_dr;
  wire                 reqbuf_suppressed_dr;
  wire                 reqbuf_busy;
  wire                 next_reqbuf_dvm_sync_busy;
  wire [1:0]           tag_l1_update_shareability_tc0;
  wire                 tag_state_l1_cu_tc0;
  wire [1:0]           tag_state_l1_cpu0_tc0;
  wire [1:0]           tag_state_l1_cpu1_tc0;
  wire [1:0]           tag_state_l1_cpu2_tc0;
  wire [1:0]           tag_state_l1_cpu3_tc0;
  wire                 reqbuf_dbid_en;
  wire                 zero;
  wire                 sel_err;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable      <= 1'b1;
    clk_spec_enable <= 1'b1;
  end else begin
    clk_enable      <= reqbuf_enable_i;
    clk_spec_enable <= reqbuf_spec_enable_i;
  end

  assign reqbuf_clk_enable = clk_enable | (clk_spec_enable & cpuslv_tagctl_spec_valid_tc0_i);

  ca53_cell_inter_clkgate u_inter_clkgate_reqbuf (
    .clk_i         (clk),
    .clk_enable_i  (reqbuf_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_reqbuf));

  // Tie-off for configurable logic.
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  //  State machines
  //----------------------------------------------------------------------------

  // Main state machine controlling the primary address associated with this
  // request.
  always @*
  begin
    next_reqbuf_state = reqbuf_state;
    case (reqbuf_state)
      STATE_IDLE: begin
        if (reqbuf_alloc_i) begin
          if (cpuslv_noncoh_only_i) begin
            next_reqbuf_state = STATE_WAIT_INITIAL;
          end else begin
            next_reqbuf_state = STATE_INITIAL;
          end
        end
      end
      STATE_INITIAL: begin
        if (~reqbuf_allocated_i) begin
          if (reqbuf_alloc_i) begin
            if (cpuslv_noncoh_only_i) begin
              next_reqbuf_state = STATE_WAIT_INITIAL;
            end else begin
              next_reqbuf_state = STATE_INITIAL;
            end
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end else if (reqbuf_state_tc1) begin
          // This is the tc1 cycle
          if (tagctl_slv_flush_tc1_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_TC2;
          end
        end else if (set_way_nop |
                     (reqbuf_type == `CA53_REQ_READNONE)) begin
          next_reqbuf_state = STATE_RESP;
        end else if ((reqbuf_type == `CA53_REQ_DMB) |
                     (reqbuf_type == `CA53_REQ_DSB) |
                     (reqbuf_type == `CA53_REQ_ECCCLEAN)) begin
          next_reqbuf_state = STATE_WAIT_REQBUFS;
        end else begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_RESP: begin
        if (reqbuf_rr_ready_i) begin
          if (require_compack_after_resp) begin
            next_reqbuf_state = STATE_COMPACK;
          end else if (require_tagctl_after_resp) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (reqbuf_victim_state != STATE_VICTIM_IDLE) begin
            next_reqbuf_state = STATE_WAIT_VICTIM;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_TC0_TC1: begin
        // This is either the TC0 state or the TC1 state, depending on whether
        // this reqbuf got arbitrated in the previous cycle. If the victim state
        // machine was in TC0 in the previous cycle then the primary state
        // machine cannot be in TC1 because if anything was arbitrated in the
        // previous cycle it would have been the victim state machine.
        if (reqbuf_state_tc1) begin
          if (tagctl_slv_flush_tc1_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_update_victim_after_tc1) begin
            next_reqbuf_state = STATE_UPDATE_VICTIM;
          end else if (require_l2db_after_tc1) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else begin
            next_reqbuf_state = STATE_TC2;
          end
        end
      end
      STATE_TC2: begin
        if (tagctl_slv_flush_tc2_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else if (require_l2db_after_tc2) begin
          next_reqbuf_state = STATE_WAIT_L2DB;
        end else if (require_resp_after_tc2) begin
          next_reqbuf_state = STATE_RESP;
        end else if (require_tagctl_after_tc2) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else if (require_idle_after_tc2) begin
          // These operations must wait until tc2 to ensure any other access
          // that started a tag read before this write will still detect an
          // address hazard when it is in tc3.
          if (reqbuf_victim_state != STATE_VICTIM_IDLE) begin
            next_reqbuf_state = STATE_WAIT_VICTIM;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end else begin
          next_reqbuf_state = STATE_TC3;
        end
      end
      STATE_TC3: begin
        if (tagctl_slv_flush_tc3_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else if (require_afb_after_tc3) begin
          next_reqbuf_state = STATE_WAIT_AFB;
        end else begin
          next_reqbuf_state = STATE_TC4;
        end
      end
      STATE_TC4: begin
        if (tagctl_slv_flush_tc4_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else begin
          next_reqbuf_state = STATE_WAIT_AFB;
        end
      end
      STATE_WAIT_AFB: begin
        if (afb_done) begin
          if (require_l2db_after_afb) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else if (require_ext_after_afb) begin
            next_reqbuf_state = STATE_WAIT_EXT;
          end else if (require_resp_after_afb) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_tagctl_after_afb) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_victim_pick_after_afb) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (reqbuf_victim_state != STATE_VICTIM_IDLE) begin
            next_reqbuf_state = STATE_WAIT_VICTIM;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_WAIT_L2DB: begin
        if (primary_l2db_done) begin
          if (require_tagctl_after_l2db) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_resp_after_l2db) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_waddr_after_l2db) begin
            next_reqbuf_state = STATE_WAIT_WADDR;
          end else if (require_ext_after_l2db) begin
            next_reqbuf_state = STATE_WAIT_EXT;
          end else if (require_update_victim_after_l2db) begin
            next_reqbuf_state = STATE_UPDATE_VICTIM;
          end else if (require_victim_pick_after_l2db) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (require_compack_after_l2db) begin
            next_reqbuf_state = STATE_COMPACK;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end else if (reqbuf_retry_seen) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_WAIT_EXT: begin
        if (ext_wait_done) begin
          if (require_compack_after_ext) begin
            next_reqbuf_state = STATE_COMPACK;
          end else if (require_victim_pick_after_ext) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (require_l2db_after_ext) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else if (require_waddr_after_ext) begin
            next_reqbuf_state = STATE_WAIT_WADDRS;
          end else if (require_resp_after_ext) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_tagctl_after_ext) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end else if (reqbuf_retry_seen) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_COMPACK: begin
        if (reqbuf_compack_ready_i) begin
          if (require_tagctl_after_compack) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_resp_after_compack) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_victim_pick_after_ext) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (require_l2db_after_ext) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_PICK_VICTIM_REQ: begin
        if (reqbuf_victimctl_ready_i) begin
          next_reqbuf_state = STATE_PICK_VICTIM_ACK;
        end
      end
      STATE_PICK_VICTIM_ACK: begin
        if (victimctl_victim_ack) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_UPDATE_VICTIM: begin
        if (reqbuf_victimctl_ready_i) begin
          if (require_tagctl_after_update) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (reqbuf_victim_state != STATE_VICTIM_IDLE) begin
            next_reqbuf_state = STATE_WAIT_VICTIM;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_WAIT_INITIAL: begin
        // We come to this state on a speculative allocation, when coherent
        // requests must not be sent to tagctl.
        if (~reqbuf_allocated_i) begin
          if (reqbuf_alloc_i) begin
            if (cpuslv_noncoh_only_i) begin
              next_reqbuf_state = STATE_WAIT_INITIAL;
            end else begin
              next_reqbuf_state = STATE_INITIAL;
            end
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end else begin
          next_reqbuf_state = STATE_WAIT_COH;
        end
      end
      STATE_WAIT_COH: begin
        // Non-coherent requests may progress from this state, all other must
        // wait here until tagctl is ready. However a non-coherent request must
        // not overtake a coherent request when the coherent request is blocked,
        // because if the non-coherent request holds resources that the coherent
        // request might need, such as an L2DB, then neither might be able to
        // make progress.
        if ((reqbuf_type == `CA53_REQ_DMB) |
            (reqbuf_type == `CA53_REQ_DSB)) begin
          next_reqbuf_state = STATE_WAIT_REQBUFS;
        end else if (((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                      (reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                      (reqbuf_type == `CA53_REQ_DVM)) &
                     ~|(reqbufs_older_i & reqbufs_coh_i)) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else if (~cpuslv_noncoh_only_i) begin
          if (reqbuf_type == `CA53_REQ_ECCCLEAN) begin
            next_reqbuf_state = STATE_WAIT_REQBUFS;
          end else if ((reqbuf_type == `CA53_REQ_READNONE) |
                       set_way_nop) begin
            next_reqbuf_state = STATE_RESP;
          end else begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end
      end
      STATE_WAIT_REQBUFS: begin
        if (reqbuf_type == `CA53_REQ_ECCCLEAN) begin
          // Wait for all earlier coherent reqbufs to drain.
          if (~|(reqbufs_older_i & reqbufs_coh_i)) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end else begin
          // Wait for all earlier reqbufs to drain.
          if (~|(reqbufs_older_i & reqbufs_busy_i)) begin
            if (~((reqbuf_type == `CA53_REQ_DMB) ? cpuslv_noncoh_since_dmb_i :
                                                   cpuslv_noncoh_since_dsb_i)) begin
              next_reqbuf_state = STATE_RESP;
            end else if (config_sysbardisable_i) begin
              next_reqbuf_state = STATE_WAIT_WADDRS;
            end else begin
              next_reqbuf_state = STATE_TC0_TC1;
            end
          end
        end
      end
      STATE_WAIT_WADDRS: begin
        // Wait for all waddrs from this CPU to drain.
        if (~master_cpuslv_waddrs_valid_i) begin
          next_reqbuf_state = STATE_RESP;
        end
      end
      STATE_WAIT_WADDR: begin
        // Wait for a specific waddr to drain. This is required for address
        // based cache maintenance ops, and some clean uniques, to ensure we do
        // not sent the read part of the operation until any associated eviction
        // has completed.
        if (master_db_waddr_valid_i & (master_db_waddr_i == victim_l2db)) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_WAIT_VICTIM: begin
        if (reqbuf_victim_state == STATE_VICTIM_IDLE) begin
          next_reqbuf_state = STATE_CREDIT_RETURN;
        end
      end
      STATE_CREDIT_RETURN: begin
        if (reqbuf_ar_credit_ready_i) begin
          next_reqbuf_state = STATE_IDLE;
        end
      end
      default: next_reqbuf_state = STATE_X;
    endcase
  end


  // Victim state machine, dealing with the L1 and/or L2 victim address.
  always @*
  begin
    next_reqbuf_victim_state = reqbuf_victim_state;
    case (reqbuf_victim_state)
      STATE_VICTIM_IDLE: begin
        if (start_victim) begin
          if ((reqbuf_type == `CA53_REQ_READONCE) |
              (reqbuf_type == `CA53_REQ_READNONE)) begin
            next_reqbuf_victim_state = STATE_VICTIM_PICK_REQ;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_WAIT_AFB;
          end
        end
      end
      STATE_VICTIM_TC0: begin
        next_reqbuf_victim_state = STATE_VICTIM_TC0_TC1;
      end
      STATE_VICTIM_TC0_TC1: begin
        // This is either the TC0 or TC1 state, depending on whether we got
        // arbitrated in the previous cycle.
        if (reqbuf_arb_tc1_i) begin
          if (tagctl_slv_flush_tc1_i) begin
            next_reqbuf_victim_state = STATE_VICTIM_TC0;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_TC2;
          end
        end
      end
      STATE_VICTIM_TC2: begin
        next_reqbuf_victim_state = STATE_VICTIM_TC3;
      end
      STATE_VICTIM_TC3: begin
        if (victim_require_update_after_tc3) begin
          next_reqbuf_victim_state = STATE_VICTIM_UPDATE;
        end else if (victim_require_idle_after_tc3) begin
          next_reqbuf_victim_state = STATE_VICTIM_IDLE;
        end else begin
          next_reqbuf_victim_state = STATE_VICTIM_TC4;
        end
      end
      STATE_VICTIM_TC4: begin
        if (tagctl_slv_flush_tc4_i) begin
          next_reqbuf_victim_state = STATE_VICTIM_TC0;
        end else begin
          next_reqbuf_victim_state = STATE_VICTIM_WAIT_AFB;
        end
      end
      STATE_VICTIM_WAIT_AFB: begin
        if (victim_afb_done) begin
          if (victim_require_tagctl_after_afb) begin
            next_reqbuf_victim_state = STATE_VICTIM_TC0;
          end else if (victim_require_l2db_after_afb) begin
            next_reqbuf_victim_state = STATE_VICTIM_WAIT_L2DB;
          end else if (victim_require_update_after_afb) begin
            next_reqbuf_victim_state = STATE_VICTIM_UPDATE;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_IDLE;
          end
        end else if (reqbuf_l1_resp_victim_en &
                     (reqbuf_victim_pass == PASS_VICTIM_INITIAL)) begin
          // If the AFB is being used for a primary master request and the
          // victim snoop then we must not wait for the the master request
          // to complete as we cannot rely on it completing without blocking
          // on a request that hazards against this victim address.
          next_reqbuf_victim_state = STATE_VICTIM_WAIT_L2DB;
        end
      end
      STATE_VICTIM_WAIT_L2DB: begin
        if (victim_l2db_done) begin
          if (victim_require_victim_pick_after_l2db) begin
            next_reqbuf_victim_state = STATE_VICTIM_PICK_REQ;
          end else if (victim_require_tagctl_after_l2db) begin
            next_reqbuf_victim_state = STATE_VICTIM_TC0;
          end else if (victim_require_update_after_l2db) begin
            next_reqbuf_victim_state = STATE_VICTIM_UPDATE;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_IDLE;
          end
        end
      end
      STATE_VICTIM_UPDATE: begin
        if (reqbuf_victimctl_ready_i) begin
          next_reqbuf_victim_state = STATE_VICTIM_IDLE;
        end
      end
      STATE_VICTIM_PICK_REQ: begin
        if (reqbuf_victimctl_ready_i) begin
          next_reqbuf_victim_state = STATE_VICTIM_PICK_ACK;
        end
      end
      STATE_VICTIM_PICK_ACK: begin
        if (victimctl_victim_ack) begin
          next_reqbuf_victim_state = STATE_VICTIM_TC0;
        end
      end
      default: next_reqbuf_victim_state = STATE_VICTIM_X;
    endcase
  end

  // Decode some states that are more than just the state variable.
  assign reqbuf_state_tc1 = ((((reqbuf_state == STATE_INITIAL) &
                               reqbuf_allocated_i & ~reqbuf_type[3]) |
                              (reqbuf_state == STATE_TC0_TC1)) &
                             (reqbuf_victim_state != STATE_VICTIM_TC0_TC1) &
                             reqbuf_arb_tc1_i);

  assign reqbuf_next_state_tc0_tc1 = (((reqbuf_state == STATE_INITIAL) &
                                       reqbuf_allocated_i & (reqbuf_state_tc1 ? tagctl_slv_flush_tc1_i :
                                                             ~(set_way_nop |
                                                               (reqbuf_type == `CA53_REQ_READNONE) |
                                                               (reqbuf_type == `CA53_REQ_DMB) |
                                                               (reqbuf_type == `CA53_REQ_DSB) |
                                                               (reqbuf_type == `CA53_REQ_ECCCLEAN)))) |
                                      ((reqbuf_state == STATE_RESP) &
                                       reqbuf_rr_ready_i & require_tagctl_after_resp) |
                                      ((reqbuf_state == STATE_TC0_TC1) & ~(reqbuf_state_tc1 &
                                                                           ~tagctl_slv_flush_tc1_i)) |
                                      ((reqbuf_state == STATE_TC2) & (tagctl_slv_flush_tc2_i |
                                                                      require_tagctl_after_tc2)) |
                                      ((reqbuf_state == STATE_TC3) & tagctl_slv_flush_tc3_i) |
                                      ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i) |
                                      ((reqbuf_state == STATE_WAIT_AFB) & (afb_done &
                                                                           require_tagctl_after_afb)) |
                                      ((reqbuf_state == STATE_WAIT_L2DB) & ((primary_l2db_done &
                                                                             require_tagctl_after_l2db) |
                                                                            reqbuf_retry_seen)) |
                                      ((reqbuf_state == STATE_WAIT_EXT) & ((ext_wait_done &
                                                                            require_tagctl_after_ext &
                                                                            ~require_compack_after_ext) |
                                                                           reqbuf_retry_seen)) |
                                      ((reqbuf_state == STATE_COMPACK) & (reqbuf_compack_ready_i &
                                                                          require_tagctl_after_compack)) |
                                      ((reqbuf_state == STATE_PICK_VICTIM_ACK) & victimctl_victim_ack) |
                                      ((reqbuf_state == STATE_UPDATE_VICTIM) & (reqbuf_victimctl_ready_i &
                                                                                require_tagctl_after_update)) |
                                      ((reqbuf_state == STATE_WAIT_COH) & ((((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                                                                             (reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                                                             (reqbuf_type == `CA53_REQ_DVM)) &
                                                                            ~|(reqbufs_older_i & reqbufs_coh_i)) |
                                                                           ~(cpuslv_noncoh_only_i |
                                                                             (reqbuf_type == `CA53_REQ_DMB) |
                                                                             (reqbuf_type == `CA53_REQ_DSB) |
                                                                             (reqbuf_type == `CA53_REQ_ECCCLEAN) |
                                                                             (reqbuf_type == `CA53_REQ_READNONE) |
                                                                             set_way_nop))) |
                                      ((reqbuf_state == STATE_WAIT_REQBUFS) & ((reqbuf_type == `CA53_REQ_ECCCLEAN) ?
                                                                               ~|(reqbufs_older_i & reqbufs_coh_i) :
                                                                               (~|(reqbufs_older_i & reqbufs_busy_i) &
                                                                                ~((~((reqbuf_type == `CA53_REQ_DMB) ?
                                                                                     cpuslv_noncoh_since_dmb_i :
                                                                                     cpuslv_noncoh_since_dsb_i)) |
                                                                                  config_sysbardisable_i)))) |
                                      ((reqbuf_state == STATE_WAIT_WADDR) &
                                       master_db_waddr_valid_i & (master_db_waddr_i == victim_l2db)));

   assign reqbuf_victim_next_state_tc0_tc1 = ((reqbuf_victim_state == STATE_VICTIM_TC0) |
                                             ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) &
                                              ~(reqbuf_arb_tc1_i & ~tagctl_slv_flush_tc1_i)) |
                                             ((reqbuf_victim_state == STATE_VICTIM_TC4) &
                                              tagctl_slv_flush_tc4_i) |
                                             ((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                              victim_afb_done & victim_require_tagctl_after_afb) |
                                             ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                              victim_l2db_done & victim_require_tagctl_after_l2db) |
                                             ((reqbuf_victim_state == STATE_VICTIM_PICK_ACK) &
                                              victimctl_victim_ack));


  // An earlier, slightly speculative indication if the state is tc0 or tc1.
  // If this is set but the state is not actually in tc0 or tc1, then the victim
  // state machine cannot be active, and so this is sufficient for anything that
  // just wants to select between the two.
  assign reqbuf_state_tc0_tc1 = ((reqbuf_state == STATE_INITIAL) |
                                 (reqbuf_state == STATE_TC0_TC1));

  assign reqbuf_victim_state_tc1 = (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) & reqbuf_arb_tc1_i;

  // Enable various state only when active. The victim state machine will never
  // be active unless the main state machine is also active.
  assign reqbuf_en = reqbuf_alloc_i | (reqbuf_state != STATE_IDLE);

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_state        <= STATE_IDLE;
    reqbuf_victim_state <= STATE_VICTIM_IDLE;
  end else if (reqbuf_en) begin
    reqbuf_state        <= next_reqbuf_state;
    reqbuf_victim_state <= next_reqbuf_victim_state;
  end

  // Indicate that this request buffer has completed and a credit should be
  // returned to the BIU. Because multiple reqbufs may complete in the same
  // cycle, we may have to remain in this state until the credit can be sent.
  assign reqbuf_ar_return_credit_o = ((reqbuf_state == STATE_CREDIT_RETURN) &
                                      (reqbuf_biu_id != `CA53_RID_L2FLUSH));

  // If we have received the first half of a 2 part DVM, then the second half
  // will arrive on the next cycle. We must tell the cpuslv we are expecting
  // it, so that it doesn't allocate the second half to a different reqbuf.
  assign reqbuf_initial = (((reqbuf_state == STATE_INITIAL) |
                            (reqbuf_state == STATE_WAIT_INITIAL)) &
                           reqbuf_allocated_i);

  assign reqbuf_dvm_part_two = reqbuf_initial & (reqbuf_type == `CA53_REQ_DVM) & reqbuf_addr1[0];

  assign reqbuf_dvm_part_two_o = reqbuf_dvm_part_two;

  // Start the victim state machine when the request has been serialised and we
  // know there is something to evict.
  assign start_victim_no_flush = ((reqbuf_state == STATE_TC4) & ~cpuslv_ecc_err_tc4_i &
                                  (reqbuf_pass == PASS_READ_SERIALISE) &
                                  ((((reqbuf_type == `CA53_REQ_READSHARED) |
                                     (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                     (reqbuf_type == `CA53_REQ_ECCCLEAN)) &
                                    reqbuf_l1_hit_requestor) |
                                   ((reqbuf_type == `CA53_REQ_CLEANSETWAY) &
                                    (reqbuf_addr1[1] ? (reqbuf_l2_victim_valid & reqbuf_l2_dirty) : reqbuf_l1_hit_requestor)) |
                                   ((reqbuf_type == `CA53_REQ_CLEANINVSETWAY) &
                                    (reqbuf_addr1[1] ? reqbuf_l2_victim_valid : reqbuf_l1_hit_requestor)) |
                                   ((((reqbuf_type == `CA53_REQ_READONCE) &
                                      `CA53_MEM_WBRA(reqbuf_attrs)) |
                                     (reqbuf_type == `CA53_REQ_READNONE)) &
                                    (L2_CACHE[0] ? (reqbuf_l2_victim_valid &
                                                    ~(reqbuf_l1_hit | reqbuf_l2_hit)) : 1'b0))));

  assign start_victim = start_victim_no_flush & ~tagctl_slv_flush_tc4_i;

  // Indicate back to the CPU when the eviction snoop has completed, or wasn't
  // needed. The CPU uses this to know when it can start allocating the new
  // line into the cache.
  assign ev_done = (((reqbuf_type == `CA53_REQ_READSHARED) |
                     (reqbuf_type == `CA53_REQ_READUNIQUE)) &
                    (((reqbuf_state == STATE_TC4) & (reqbuf_pass == PASS_READ_SERIALISE) &
                      ~tagctl_slv_flush_tc4_i & ~reqbuf_l1_hit_requestor) |
                     (((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) |
                       (reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB)) &
                      (reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                      cpuslv_l2dbs_dw_valid_i & cpuslv_l2dbs_dw_last_i &
                      (cpuslv_l2dbs_dw_id_i == victim_l2db))));

  assign reqbuf_ev_done_o = ev_done;

  // The signal is sent as one bit per linefill ID, because multiple request
  // buffers could be signalling different IDs on the same cycle.
  assign reqbuf_ev_done_id_o = {8{ev_done}} & (8'b0000_0001 << reqbuf_biu_id[2:0]);

  // If the CPU has sent a WriteUnique with less than a full line, then
  // indicate to the CPU that it may want to leave read allocate mode.
  assign reqbuf_leave_ramode_o = ((reqbuf_state == STATE_TC4) &
                                  (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                  (reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                  ~reqbuf_l2db_full_err);

  // If the cache level of a set/way op is greater than our maximum implemented
  // cache level, then treat the operation as a nop.
  assign set_way_nop = (((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                         (reqbuf_type == `CA53_REQ_CLEANINVSETWAY)) &
                        (reqbuf_addr1[3:1] > (L2_CACHE[0] ? 3'b001 : 3'b000)));

  assign set_way_op_l1 = ((reqbuf_type == `CA53_REQ_ECCCLEAN) |
                          (((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                            (reqbuf_type == `CA53_REQ_CLEANINVSETWAY)) & ~reqbuf_addr1[1]));

  assign set_way_op_l2 = ((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                          (reqbuf_type == `CA53_REQ_CLEANINVSETWAY)) & reqbuf_addr1[1];

  // Only some types of DVM message need sending externally.
  assign dvm_ext = cpuslv_broadcastinner_i & ~((reqbuf_addr2[14:12] == `CA53_DVM_TLBINV) |
                                               (reqbuf_addr2[14:12] == `CA53_DVM_ICINV));

  assign cleanunique_excl_fail = (reqbuf_lock & (ext_snoop_invalidated |
                                                 (ext_beats_resp == `CA53_ACE_RESP_OKAY)));

  // State machine control logic.
  assign require_tagctl_after_l2db = ((((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                        (reqbuf_type == `CA53_REQ_DVM)) & (reqbuf_pass == PASS_WRITE_L2DB)) |
                                      ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                       ((reqbuf_pass == PASS_WRITE_L2DB) |
                                        ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) & ((L2_CACHE != 0) | reqbuf_l1_hit)) |
                                        ((reqbuf_pass == PASS_WRITE_SERIALISE) & ~((~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                                                                    ((ACE == 0) |
                                                                                     ~reqbuf_shareable) &
                                                                                    ~((L2_CACHE != 0) &
                                                                                      `CA53_MEM_WBWA(reqbuf_attrs))) |
                                                                                   require_compack_after_l2db |
                                                                                   require_victim_pick_after_l2db)))) |
                                      (reqbuf_type == `CA53_REQ_READSHARED) |
                                      (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                      (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                        (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                        (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                        (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                       ~require_resp_after_l2db &
                                       ~require_waddr_after_l2db));

  assign require_waddr_after_l2db = ((ACE != 0) & ((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                                     (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                                     (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                                    (reqbuf_pass == PASS_ADDRMAINT_MASTER_W) &
                                                    ~require_resp_after_l2db) |
                                                   ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                                    (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W))));

  assign require_update_victim_after_l2db = ((((reqbuf_type == `CA53_REQ_READONCE) |
                                               (reqbuf_type == `CA53_REQ_READNONE)) &
                                              (reqbuf_pass == PASS_READ_SERIALISE) &
                                              reqbuf_l2_hit) |
                                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                              (L2_CACHE != 0) &
                                              (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1)));

  assign require_victim_pick_after_l2db = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                           (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                           ~reqbuf_l2_hit &
                                           reqbuf_l2_victim_valid &
                                           (ACE != 0) &
                                           (reqbuf_l1_hit ? ~reqbuf_cluster_unique :
                                                            `CA53_MEM_WBWA(reqbuf_attrs)));

  assign require_resp_after_l2db = (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                     (reqbuf_pass == PASS_READ_SERIALISE) &
                                     reqbuf_cluster_unique &
                                     reqbuf_lock &
                                     ~(reqbuf_l1_hit_other_cpus & reqbuf_l1_dirty) &
                                     ~(reqbuf_l2_hit & reqbuf_l2_dirty)) |
                                    (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                      (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                     ~(reqbuf_shareable | cpuslv_broadcastcachemaint_i) &
                                     (((reqbuf_pass == PASS_READ_SERIALISE) &
                                       ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                      (reqbuf_pass == PASS_ADDRMAINT_MASTER_W))));

  assign require_ext_after_l2db = ((ACE == 0) &
                                   ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                    (reqbuf_type == `CA53_REQ_DVM)) &
                                   (reqbuf_pass != PASS_WRITE_L2DB) &
                                   ~ext_beats_received);

  assign require_compack_after_l2db = ((ACE == 0) &
                                       (reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                       ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) |
                                        ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                         ((reqbuf_l1_hit |
                                           reqbuf_l2_hit) ? ~reqbuf_cluster_unique :
                                                            ((L2_CACHE != 0) &
                                                             `CA53_MEM_WBWA(reqbuf_attrs) &
                                                             (reqbuf_shareable |
                                                              ~reqbuf_l2db_full_err))))));

  assign require_l2db_after_ext = ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                   (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit) &
                                   ~ext_snoop_invalidated);

  assign require_waddr_after_ext = (ACE != 0) & (reqbuf_type == `CA53_REQ_DSB);

  assign require_resp_after_ext = (((reqbuf_type == `CA53_REQ_DSB) & (ACE == 0)) |
                                   (reqbuf_type == `CA53_REQ_DMB) |
                                   (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                   (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                   (reqbuf_type == `CA53_REQ_MAKEINVALID) |
                                   ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                    (~reqbuf_lock | cleanunique_excl_fail)));

  assign require_tagctl_after_ext = ((reqbuf_type == `CA53_REQ_READSHARED) |
                                     ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                      ~((reqbuf_l1_hit_other_cpus | reqbuf_l2_hit) &
                                        ~ext_snoop_invalidated)) |
                                     ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                      reqbuf_lock & ~cleanunique_excl_fail) |
                                     ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                      ~((L2_CACHE != 0) &
                                        reqbuf_l2_victim_valid & ~reqbuf_l2_hit &
                                        ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) |
                                         ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                          (reqbuf_l1_hit | reqbuf_l2_hit |
                                           `CA53_MEM_WBWA(reqbuf_attrs)))))) |
                                     ((((reqbuf_type == `CA53_REQ_READONCE) & `CA53_MEM_WBRA(reqbuf_attrs)) |
                                       (reqbuf_type == `CA53_REQ_READNONE)) &
                                      (L2_CACHE != 0)));

  assign require_compack_after_ext = (ACE == 0) & ((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                                                   (reqbuf_type == `CA53_REQ_READONCE) |
                                                   (reqbuf_type == `CA53_REQ_READNONE) |
                                                   (reqbuf_type == `CA53_REQ_READSHARED) |
                                                   (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                                   (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                                   (reqbuf_type == `CA53_REQ_WRITEUNIQUE));

  assign require_victim_pick_after_ext = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                          (L2_CACHE != 0) &
                                          reqbuf_l2_victim_valid & ~reqbuf_l2_hit &
                                          ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) |
                                           ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                            (reqbuf_l1_hit | reqbuf_l2_hit |
                                             `CA53_MEM_WBWA(reqbuf_attrs)))));

  assign require_tagctl_after_compack = require_tagctl_after_ext;

  assign require_resp_after_compack = ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                       (~reqbuf_lock | cleanunique_excl_fail));

  assign require_l2db_after_afb = (((reqbuf_type == `CA53_REQ_READSHARED)  & (reqbuf_pass == PASS_READ_SERIALISE) &
                                    (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit)) |
                                   ((reqbuf_type == `CA53_REQ_READUNIQUE)  & (reqbuf_pass == PASS_READ_SERIALISE) &
                                    (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit)) |
                                   ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & (((reqbuf_pass == PASS_READ_SERIALISE) &
                                                                               (reqbuf_l1_hit_requestor &
                                                                                ((reqbuf_l1_hit_other_cpus |
                                                                                  (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                                                                                 ~reqbuf_cluster_unique))) |
                                                                              (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W))) |
                                   ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) & ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) |
                                                                              (reqbuf_pass == PASS_WRITEUNIQUE_MISS) |
                                                                              (reqbuf_pass == PASS_WRITEUNIQUE_MISS_RETRY) |
                                                                              ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) &
                                                                               ~reqbuf_l2db_full_err) |
                                                                              (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) |
                                                                              ((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2) &
                                                                               afb_primary_write) |
                                                                              ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                                               (((reqbuf_l2_hit | (reqbuf_l1_hit &
                                                                                                   (~reqbuf_l2_victim_valid |
                                                                                                    ~reqbuf_l2db_full_err))) &
                                                                                 reqbuf_cluster_unique) |
                                                                                (((reqbuf_l1_hit & ~reqbuf_cluster_unique) |
                                                                                  reqbuf_l2_hit) &
                                                                                 ~(((ACE != 0) & (L2_CACHE == 0)) |
                                                                                   reqbuf_l2db_full_err)) |
                                                                                (~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                                                                 (((L2_CACHE != 0) &
                                                                                   `CA53_MEM_WBWA(reqbuf_attrs)) ?
                                                                                  ((~reqbuf_shareable & ~reqbuf_l2_victim_valid) |
                                                                                   ~reqbuf_l2db_full_err) :
                                                                                  ((ACE == 0) | ~reqbuf_shareable))))))) |
                                   (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                     (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                     (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                    (((reqbuf_pass == PASS_READ_SERIALISE) &
                                      (reqbuf_l1_hit | (reqbuf_l2_hit & reqbuf_l2_dirty))) |
                                     (reqbuf_pass == PASS_ADDRMAINT_MASTER_W))) |
                                   ((reqbuf_type == `CA53_REQ_READONCE)    & (reqbuf_l1_hit | reqbuf_l2_hit)) |
                                   (reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                   ((reqbuf_type == `CA53_REQ_DVM) & ((((ACE == 0) & dvm_ext) |
                                                                      (reqbuf_pass == PASS_WRITE_L2DB)))));

  assign require_ext_after_afb = ((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                                  (((reqbuf_type == `CA53_REQ_READONCE) |
                                    (reqbuf_type == `CA53_REQ_READNONE)) & ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                  ((reqbuf_type == `CA53_REQ_READSHARED) &
                                   (((reqbuf_pass == PASS_READ_SERIALISE) &
                                     ~(reqbuf_l1_hit_other_cpus | reqbuf_l2_hit)) |
                                    (reqbuf_pass == PASS_READSHARED_RETRY))) |
                                  ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                   ((reqbuf_pass != PASS_READ_SERIALISE) |
                                    ~(reqbuf_l1_hit_other_cpus | reqbuf_l2_hit))) |
                                  ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & (((reqbuf_pass == PASS_READ_SERIALISE) &
                                                                              reqbuf_l1_hit_requestor &
                                                                              ~reqbuf_cluster_unique &
                                                                              ~reqbuf_l1_hit_other_cpus &
                                                                              (~reqbuf_l2_hit | ~reqbuf_l2_dirty)) |
                                                                             (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_R) |
                                                                             (reqbuf_pass == PASS_CLEANUNIQUE_RETRY))) |
                                  ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) & (((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) &
                                                                              reqbuf_l2db_full_err) |
                                                                             ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                                              ((reqbuf_l1_hit |
                                                                                reqbuf_l2_hit) ? ((((ACE != 0) & (L2_CACHE == 0)) |
                                                                                                   reqbuf_l2db_full_err) &
                                                                                                  ~reqbuf_cluster_unique) :
                                                                               ((ACE != 0) ? ((reqbuf_shareable &
                                                                                               ~(~reqbuf_l2db_full_err &
                                                                                                 (L2_CACHE != 0) &
                                                                                                 `CA53_MEM_WBWA(reqbuf_attrs)))) :
                                                                                             (reqbuf_shareable &
                                                                                              reqbuf_l2db_full_err &
                                                                                              (L2_CACHE != 0) &
                                                                                              `CA53_MEM_WBWA(reqbuf_attrs))))))) |
                                  (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                    (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                    (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                   afb_primary_write &
                                   (((reqbuf_pass == PASS_READ_SERIALISE) &
                                     ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                    (reqbuf_pass == PASS_ADDRMAINT_MASTER_R) |
                                    (reqbuf_pass == PASS_ADDRMAINT_RETRY))) |
                                  (reqbuf_type == `CA53_REQ_DMB) |
                                  (reqbuf_type == `CA53_REQ_DSB) |
                                  ((reqbuf_type == `CA53_REQ_DVM) & (ACE != 0) &
                                   (reqbuf_pass == PASS_WRITE_SERIALISE) & dvm_ext));

  assign require_victim_pick_after_afb = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                          (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                          ~reqbuf_l2_hit &
                                          reqbuf_l2_victim_valid &
                                          (L2_CACHE != 0) &
                                          reqbuf_l2db_full_err &
                                          (reqbuf_l1_hit ? reqbuf_cluster_unique :
                                           (`CA53_MEM_WBWA(reqbuf_attrs) &
                                            ~reqbuf_shareable)));

  assign require_resp_after_afb = (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & ((reqbuf_pass == PASS_CLEANUNIQUE_CHECK) |
                                                                              ((reqbuf_pass == PASS_READ_SERIALISE) &
                                                                               (~reqbuf_l1_hit_requestor |
                                                                                reqbuf_cluster_unique)))) |
                                   (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                     (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                     (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                    ((reqbuf_pass == PASS_ADDRMAINT_MASTER_R) |
                                     (reqbuf_pass == PASS_ADDRMAINT_RETRY) |
                                     ((reqbuf_pass == PASS_READ_SERIALISE) &
                                      ~(reqbuf_l1_hit | reqbuf_l2_hit))) &
                                    ~afb_primary_write) |
                                   (((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                     (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                     (reqbuf_type == `CA53_REQ_ECCCLEAN)) &
                                    (reqbuf_biu_id != `CA53_RID_L2FLUSH)));

  assign require_tagctl_after_afb = ((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                       (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                      (reqbuf_pass == PASS_READ_SERIALISE) &
                                      reqbuf_l2_hit & ~reqbuf_l2_dirty &
                                      ~reqbuf_l1_hit));

  assign require_l2db_after_tc1 = (reqbuf_type == `CA53_REQ_WRITEUNIQUE) & ((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) &
                                                                            (L2_CACHE != 0));

  assign require_update_victim_after_tc1 = (((reqbuf_type == `CA53_REQ_READONCE) |
                                             (reqbuf_type == `CA53_REQ_READNONE)) & (reqbuf_pass == PASS_READONCE_MISS));

  assign require_l2db_after_tc2 = (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                    (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                    (reqbuf_type == `CA53_REQ_DVM)) &
                                   (reqbuf_pass == PASS_WRITE_L2DB));

  assign require_resp_after_tc2 = (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                    (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                    (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                   (reqbuf_pass == PASS_ADDRMAINT_UPDATE) &
                                   ~(reqbuf_shareable | cpuslv_broadcastcachemaint_i));

  assign require_tagctl_after_tc2 = (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                      (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                     (reqbuf_pass == PASS_ADDRMAINT_UPDATE) &
                                     (reqbuf_shareable | cpuslv_broadcastcachemaint_i));

  assign require_idle_after_tc2 = ((((reqbuf_type == `CA53_REQ_READSHARED) & ((reqbuf_pass == PASS_READSHARED_L1_HIT) |
                                                                              (reqbuf_pass == PASS_READSHARED_L2_HIT) |
                                                                              (reqbuf_pass == PASS_READSHARED_MISS))) |
                                    ((reqbuf_type == `CA53_REQ_READUNIQUE) & ((reqbuf_pass == PASS_READUNIQUE_MISS) |
                                                                              (reqbuf_pass == PASS_READUNIQUE_HIT2))) |
                                    ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & ((reqbuf_pass == PASS_CLEANUNIQUE_UNIQUE_UPDATE) |
                                                                               (reqbuf_pass == PASS_CLEANUNIQUE_UPDATE)))) &
                                   ~require_l2db_after_tc2);

  assign require_afb_after_tc3 = ((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                                  (reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                  ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                   (reqbuf_pass != PASS_READ_SERIALISE)));

  assign require_tagctl_after_resp = (((reqbuf_type == `CA53_REQ_READNONE) & (L2_CACHE != 0)) |
                                      ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                       ((reqbuf_pass == PASS_CLEANUNIQUE_CHECK) |
                                        (reqbuf_l1_hit_requestor &
                                         (((reqbuf_pass == PASS_READ_SERIALISE) &
                                           reqbuf_cluster_unique) |
                                          ~cleanunique_excl_fail)))));

  assign require_compack_after_resp = (ACE == 0) & (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                                     (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                                     (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                                    ext_beats_received);

  assign require_tagctl_after_update = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                        (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) &
                                        (L2_CACHE != 0) &
                                        reqbuf_l2_victim_valid &
                                        ~reqbuf_l2_hit);

  assign victim_require_idle_after_tc3 = ((set_way_op_l1 & (L2_CACHE == 0) &
                                           ((|reqbuf_l1_hit_cpus_tc3 |
                                             (reqbuf_type == `CA53_REQ_CLEANSETWAY)) &
                                            ~reqbuf_victim_dirty)) |
                                          ((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                           ~tagctl_l2_victim_valid_tc3_i)) & ~tagctl_ecc_err_tc3_i;

  assign victim_require_update_after_tc3 = (reqbuf_victim_pass == PASS_VICTIM_UPDATE);

  assign victim_require_l2db_after_afb = (((reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                           ((((reqbuf_type == `CA53_REQ_READONCE) |
                                              (reqbuf_type == `CA53_REQ_READNONE)) &
                                             reqbuf_l2_victim_valid) |
                                            set_way_op_l2)) |
                                          (reqbuf_victim_pass == PASS_VICTIM_READ) |
                                          afb_victim_write |
                                          ((L2_CACHE != 0) &
                                           (reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                           ~reqbuf_l2_victim_hit &
                                           ~reqbuf_l2_victim_valid));

  assign victim_require_update_after_afb = ((L2_CACHE != 0) &
                                            (reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                            ~afb_victim_write &
                                            ((~reqbuf_l2_victim_hit &
                                              reqbuf_l2_victim_valid) |
                                             (reqbuf_l2_victim_hit & (reqbuf_l2_victim_dirty |
                                                                      ~reqbuf_victim_dirty))));

  assign victim_require_tagctl_after_afb = (((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                             (reqbuf_l2_victim_hit & (reqbuf_victim_dirty &
                                                                      ~reqbuf_l2_victim_dirty))));

  assign victim_require_tagctl_after_l2db = L2_CACHE ? ((reqbuf_victim_pass == PASS_VICTIM_READ) |
                                                        ((reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                                         ((reqbuf_type == `CA53_REQ_READONCE) |
                                                          (reqbuf_type == `CA53_REQ_READNONE) |
                                                          set_way_op_l2)) |
                                                        ((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                                         ~reqbuf_l2_victim_hit & ~reqbuf_l2_victim_valid)) :
                                                       ((reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                                        (set_way_op_l1 |
                                                         reqbuf_victim_dirty |
                                                         ((`CA53_MEM_O_SHAREABLE(victim_attrs) & cpuslv_broadcastouter_i) |
                                                          (`CA53_MEM_SHAREABLE(victim_attrs)   & cpuslv_broadcastinner_i))));

  assign victim_require_victim_pick_after_l2db = ((L2_CACHE != 0) & (reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                                  ~((reqbuf_type == `CA53_REQ_READONCE) |
                                                    (reqbuf_type == `CA53_REQ_READNONE) |
                                                    set_way_op_l2));

  assign victim_require_update_after_l2db = ((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                             ~reqbuf_l2_victim_hit & reqbuf_l2_victim_valid);

  assign reqbuf_active_o = (reqbuf_state != STATE_IDLE);

  assign reqbuf_busy = ~((reqbuf_state == STATE_IDLE) |
                         ((reqbuf_state == STATE_INITIAL) |
                          (reqbuf_state == STATE_WAIT_INITIAL)) & ~reqbuf_allocated_i);

  assign reqbuf_busy_o = reqbuf_busy;

  // Indicate to the DCU when the reqbuf is busy, for tracking when DVM syncs
  // can complete. This must not include CPU DVM syncs at they will not progress
  // until the external sync has completed.
  assign next_reqbuf_dvm_sync_busy = (reqbuf_busy &
                                      (reqbuf_state != STATE_CREDIT_RETURN) &
                                      ~reqbuf_dvm_sync);

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_dvm_sync_busy <= 1'b0;
  end else if (reqbuf_en) begin
    reqbuf_dvm_sync_busy <= next_reqbuf_dvm_sync_busy;
  end

  assign reqbuf_dvm_sync_busy_o = reqbuf_dvm_sync_busy;

  // Keep track of what stage the request is at, and therefore what it needs
  // to do the next time it goes down tagctl.
  assign update_reqbuf_pass = (reqbuf_alloc_i | 
                               ((reqbuf_state == STATE_WAIT_AFB) & (afb_done &
                                                                    require_tagctl_after_afb)) |
                               ((reqbuf_state == STATE_WAIT_L2DB) & (reqbuf_retry_seen |
                                                                     (primary_l2db_done &
                                                                      require_tagctl_after_l2db))) |
                               ((reqbuf_state == STATE_WAIT_EXT) & (reqbuf_retry_seen |
                                                                    (ext_wait_done &
                                                                     require_tagctl_after_ext &
                                                                     ~require_compack_after_ext))) |
                               ((reqbuf_state == STATE_COMPACK) & (reqbuf_compack_ready_i &
                                                                   require_tagctl_after_compack)) |
                               ((reqbuf_state == STATE_WAIT_WADDR) & (master_db_waddr_valid_i &
                                                                      (master_db_waddr_i == victim_l2db))) |
                               ((reqbuf_state == STATE_TC2) & (require_tagctl_after_tc2 &
                                                               ~tagctl_slv_flush_tc2_i)) |
                               ((reqbuf_state == STATE_PICK_VICTIM_ACK) & victimctl_victim_ack) |
                               ((reqbuf_state == STATE_UPDATE_VICTIM) & (reqbuf_victimctl_ready_i &
                                                                         require_tagctl_after_update)) |
                               ((reqbuf_state == STATE_RESP) & (reqbuf_rr_ready_i &
                                                                require_tagctl_after_resp &
                                                                (reqbuf_type != `CA53_REQ_READNONE))));

  // Tell the tagctl arbitration when to throw away any cached data for this
  // tagctl pass.
  assign reqbuf_update_primary_pass_o = update_reqbuf_pass;
  assign reqbuf_update_victim_pass_o  = update_reqbuf_victim_pass;

  always @*
  if (~reqbuf_busy) begin
    next_reqbuf_pass = PASS_INITIAL;
  end else begin
    case (reqbuf_type)
      `CA53_REQ_CLEANUNIQUE: begin
        case (reqbuf_pass)
          PASS_READ_SERIALISE:         next_reqbuf_pass = reqbuf_cluster_unique             ? PASS_CLEANUNIQUE_UNIQUE_UPDATE :
                                                          (reqbuf_l2_hit & reqbuf_l2_dirty) ? PASS_CLEANUNIQUE_MASTER_W :
                                                          reqbuf_l1_hit_other_cpus          ?
                                                          (reqbuf_l1_dirty                  ? PASS_CLEANUNIQUE_MASTER_W :
                                                                                              PASS_CLEANUNIQUE_MASTER_R) :
                                                          reqbuf_retry_seen                 ? PASS_CLEANUNIQUE_RETRY :
                                                          reqbuf_lock                       ? PASS_CLEANUNIQUE_CHECK : 
                                                                                              PASS_CLEANUNIQUE_UPDATE;
          PASS_CLEANUNIQUE_MASTER_W:   next_reqbuf_pass = PASS_CLEANUNIQUE_MASTER_R;
          PASS_CLEANUNIQUE_MASTER_R:   next_reqbuf_pass = reqbuf_retry_seen ? PASS_CLEANUNIQUE_RETRY :
                                                          reqbuf_lock       ? PASS_CLEANUNIQUE_CHECK :
                                                                              PASS_CLEANUNIQUE_UPDATE;
          PASS_CLEANUNIQUE_RETRY:      next_reqbuf_pass = reqbuf_lock ? PASS_CLEANUNIQUE_CHECK : PASS_CLEANUNIQUE_UPDATE;
          PASS_CLEANUNIQUE_CHECK:      next_reqbuf_pass = PASS_CLEANUNIQUE_UPDATE;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_CLEANSHARED,
      `CA53_REQ_CLEANINVALID,
      `CA53_REQ_MAKEINVALID: begin
        case (reqbuf_pass)
          PASS_READ_SERIALISE:         next_reqbuf_pass = ((reqbuf_l1_hit &
                                                            reqbuf_l1_dirty) |
                                                           (reqbuf_l2_hit &
                                                            reqbuf_l2_dirty))              ? PASS_ADDRMAINT_MASTER_W :
                                                          (reqbuf_l1_hit | reqbuf_l2_hit)  ? PASS_ADDRMAINT_UPDATE :
                                                          reqbuf_retry_seen                ? PASS_ADDRMAINT_RETRY :
                                                                                             PASS_ADDRMAINT_MASTER_R;
          PASS_ADDRMAINT_UPDATE:       next_reqbuf_pass = PASS_ADDRMAINT_MASTER_R;
          PASS_ADDRMAINT_MASTER_W:     next_reqbuf_pass = PASS_ADDRMAINT_MASTER_R;
          PASS_ADDRMAINT_MASTER_R:     next_reqbuf_pass = PASS_ADDRMAINT_RETRY;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_WRITEUNIQUE: begin
        case (reqbuf_pass)
          PASS_WRITE_L2DB:             next_reqbuf_pass = PASS_WRITE_SERIALISE;
          PASS_WRITE_SERIALISE:        next_reqbuf_pass = (reqbuf_l1_hit |
                                                           reqbuf_l2_hit) ?
                                                          (((reqbuf_l2_hit |
                                                             (reqbuf_l1_hit & (~reqbuf_l2db_full_err |
                                                                               ~reqbuf_l2_victim_valid))) &
                                                            reqbuf_cluster_unique) ? PASS_WRITEUNIQUE_UNIQUE1 :
                                                           reqbuf_retry_seen       ? PASS_WRITEUNIQUE_HIT_RETRY :
                                                                                     PASS_WRITEUNIQUE_N_UNIQUE) :
                                                          (~reqbuf_shareable &
                                                           reqbuf_l2db_full_err &
                                                           `CA53_MEM_WBWA(reqbuf_attrs) &
                                                           ~reqbuf_l2_victim_valid &
                                                           (L2_CACHE != 0)) ? PASS_WRITEUNIQUE_UNIQUE1 :
                                                          (~`CA53_MEM_WBWA(reqbuf_attrs) |
                                                           (L2_CACHE == 0)) ?
                                                          (reqbuf_retry_seen ? PASS_WRITEUNIQUE_MISS_RETRY :
                                                                               PASS_WRITEUNIQUE_MISS) :
                                                          reqbuf_retry_seen  ? PASS_WRITEUNIQUE_HIT_RETRY :
                                                                               PASS_WRITEUNIQUE_N_UNIQUE;
          PASS_WRITEUNIQUE_MISS_RETRY: next_reqbuf_pass = PASS_WRITEUNIQUE_MISS;
          PASS_WRITEUNIQUE_HIT_RETRY:  next_reqbuf_pass = PASS_WRITEUNIQUE_N_UNIQUE;
          PASS_WRITEUNIQUE_N_UNIQUE:   next_reqbuf_pass = PASS_WRITEUNIQUE_UNIQUE1;
          PASS_WRITEUNIQUE_UNIQUE1:    next_reqbuf_pass = PASS_WRITEUNIQUE_UNIQUE2;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_READSHARED: begin
        case (reqbuf_pass)
          PASS_READ_SERIALISE:         next_reqbuf_pass = reqbuf_l2_hit            ? PASS_READSHARED_L2_HIT :
                                                          reqbuf_l1_hit_other_cpus ? PASS_READSHARED_L1_HIT :
                                                          reqbuf_retry_seen        ? PASS_READSHARED_RETRY :
                                                                                     PASS_READSHARED_MISS;
          PASS_READSHARED_RETRY:       next_reqbuf_pass = PASS_READSHARED_MISS;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_READUNIQUE: begin
        case (reqbuf_pass)
          PASS_READ_SERIALISE:         next_reqbuf_pass = (reqbuf_l1_hit_other_cpus |
                                                           reqbuf_l2_hit) ?
                                                          (reqbuf_cluster_unique ? PASS_READUNIQUE_HIT2 :
                                                                                   PASS_READUNIQUE_HIT1) :
                                                          reqbuf_retry_seen      ? PASS_READUNIQUE_MISS_RETRY :
                                                                                   PASS_READUNIQUE_MISS;
          PASS_READUNIQUE_MISS_RETRY:  next_reqbuf_pass = PASS_READUNIQUE_MISS;
          PASS_READUNIQUE_HIT1:        next_reqbuf_pass = reqbuf_retry_seen ? PASS_READUNIQUE_HIT_RETRY :
                                                                              PASS_READUNIQUE_HIT2;
          PASS_READUNIQUE_HIT_RETRY:   next_reqbuf_pass = PASS_READUNIQUE_HIT2;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_READONCE,
      `CA53_REQ_READNONE: begin
        case (reqbuf_pass)
          PASS_READ_SERIALISE:         next_reqbuf_pass = reqbuf_retry_seen ? PASS_READONCE_RETRY :
                                                                              PASS_READONCE_MISS;
          PASS_READONCE_RETRY:         next_reqbuf_pass = PASS_READONCE_MISS;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_READNOSNOOP: begin
                                       next_reqbuf_pass = PASS_READNOSNOOP_RETRY;
      end
      `CA53_REQ_WRITENOSNOOP: begin
        case (reqbuf_pass)
          PASS_WRITE_L2DB:             next_reqbuf_pass = PASS_WRITE_SERIALISE;
          PASS_WRITE_SERIALISE:        next_reqbuf_pass = PASS_WRITENOSNOOP_RETRY;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_DVM: begin
        case (reqbuf_pass)
          PASS_WRITE_L2DB:             next_reqbuf_pass = PASS_WRITE_SERIALISE;
          PASS_WRITE_SERIALISE:        next_reqbuf_pass = PASS_DVM_RETRY;
          default:                     next_reqbuf_pass = PASS_X;
        endcase
      end
      `CA53_REQ_DMB,
      `CA53_REQ_DSB: begin
                                       next_reqbuf_pass = PASS_BARRIER_RETRY;
      end
      default:                         next_reqbuf_pass = PASS_X;
    endcase
  end

  always @(posedge clk_reqbuf)
  if (update_reqbuf_pass) begin
    reqbuf_pass <= next_reqbuf_pass;
  end

  // The victim passes are simpler than for the main request, and so are just
  // a counter. The first pass is started by the main state machine, and the
  // victim state machine is only activated after reaching tc4.
  assign update_reqbuf_victim_pass = (reqbuf_alloc_i |
                                      ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                       victim_l2db_done & victim_require_tagctl_after_l2db) |
                                      ((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                       ((victim_afb_done & victim_require_tagctl_after_afb) |
                                        (afb_done &
                                         ((reqbuf_type == `CA53_REQ_READONCE) |
                                          (reqbuf_type == `CA53_REQ_READNONE)) & ~reqbuf_l2_victim_valid))) |
                                      ((reqbuf_victim_state == STATE_VICTIM_PICK_ACK) & victimctl_victim_ack));

  always @*
  if (~reqbuf_busy) begin
    next_reqbuf_victim_pass = PASS_VICTIM_INITIAL;
  end else begin
    case (reqbuf_victim_pass)
      PASS_VICTIM_INITIAL: next_reqbuf_victim_pass = ((L2_CACHE != 0) &
                                                      (set_way_op_l1 |
                                                       (reqbuf_type == `CA53_REQ_READSHARED) |
                                                       (reqbuf_type == `CA53_REQ_READUNIQUE))) ? PASS_VICTIM_LOOKUP :
                                                     ((reqbuf_type == `CA53_REQ_READONCE) |
                                                      (reqbuf_type == `CA53_REQ_READNONE))     ? PASS_VICTIM_READ :
                                                                                                 PASS_VICTIM_WRITE;
      PASS_VICTIM_READ:    next_reqbuf_victim_pass = PASS_VICTIM_WRITE;
      PASS_VICTIM_LOOKUP:  next_reqbuf_victim_pass = PASS_VICTIM_UPDATE;
      default:             next_reqbuf_victim_pass = PASS_VICTIM_X;
    endcase
  end

  always @(posedge clk_reqbuf)
  if (update_reqbuf_victim_pass) begin
    reqbuf_victim_pass <= next_reqbuf_victim_pass;
  end

  // The request is only shareable outside the cluster if the shareability is
  // greated than the shareability domain boundary set by the external broadcast
  // configuration pins.
  assign reqbuf_shareable = ((`CA53_MEM_SHAREABLE(reqbuf_attrs) & cpuslv_broadcastinner_i) |
                             (`CA53_MEM_O_SHAREABLE(reqbuf_attrs) & cpuslv_broadcastouter_i));

  //----------------------------------------------------------------------------
  //  Request storage
  //----------------------------------------------------------------------------

  assign ar_way_enc = `CA53_L1_WAY_ENC(ar_way_i);

  always @(posedge clk_reqbuf)
  if (reqbuf_alloc_i) begin
    reqbuf_biu_id  <= ar_id_i;
    reqbuf_type    <= ar_type_i;
    reqbuf_attrs   <= ar_attrs_i;
    reqbuf_req_way <= ar_way_enc;
    reqbuf_len     <= ar_len_i;
    reqbuf_size    <= ar_size_i;
    reqbuf_lock    <= ar_lock_i;
    reqbuf_priv    <= ar_priv_i;
  end

  assign reqbuf_type_o  = reqbuf_type;
  assign reqbuf_len_o   = (reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? 2'b11 : reqbuf_len;
  assign reqbuf_size_o  = reqbuf_size;
  assign reqbuf_lock_o  = reqbuf_lock;
  assign reqbuf_prot    = {(reqbuf_biu_id == `CA53_RID_ICU0) |
                           (reqbuf_biu_id == `CA53_RID_ICU1) |
                           (reqbuf_biu_id == `CA53_RID_ICU2), reqbuf_priv};
  assign reqbuf_prot_o = reqbuf_prot;

  assign reqbuf_dcu_o = ((reqbuf_biu_id == `CA53_RID_DCU0) |
                         (reqbuf_biu_id == `CA53_RID_DCU1) |
                         (reqbuf_biu_id == `CA53_RID_DCU2) |
                         (reqbuf_biu_id == `CA53_RID_DCU3));

  assign reqbuf_biu_id_o = reqbuf_biu_id;

  assign reqbuf_l2flushreq_o = (reqbuf_biu_id == `CA53_RID_L2FLUSH);

  // The first address hold the request address for most operations, or the
  // second half of a two part DVM.
  assign reqbuf_addr1_en = reqbuf_alloc_i | reqbuf_dvm_part_two;

  always @(posedge clk_reqbuf)
  if (reqbuf_addr1_en) begin
    reqbuf_addr1 <= ar_addr_i;
  end

  // The second address holds either the first part of a DVM message, or the
  // L1 victim address.
  assign next_reqbuf_addr2 = reqbuf_initial ? reqbuf_addr1 : {tagctl_addr_tc3_i[40:6], 6'b000000};

  assign reqbuf_addr2_en = ((reqbuf_initial & (reqbuf_type == `CA53_REQ_DVM)) |
                            ((reqbuf_state == STATE_TC3) &
                             (((reqbuf_pass == PASS_READ_SERIALISE) &
                               ((reqbuf_type == `CA53_REQ_READSHARED) |
                                (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                (reqbuf_type == `CA53_REQ_READONCE) |
                                (reqbuf_type == `CA53_REQ_READNONE) |
                                (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                (reqbuf_type == `CA53_REQ_ECCCLEAN))) |
                              (((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)) &
                               (reqbuf_type == `CA53_REQ_WRITEUNIQUE))) &
                             ~tagctl_ecc_err_tc3_i) |
                            ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                             (reqbuf_victim_pass == PASS_VICTIM_READ) &
                             ~tagctl_ecc_err_tc3_i));

  always @(posedge clk_reqbuf)
  if (reqbuf_addr2_en) begin
    reqbuf_addr2 <= next_reqbuf_addr2;
  end

  assign reqbuf_addr2_o = reqbuf_addr2;

  // Encode and store where in L1 and L2 the request hit.
  assign reqbuf_l2_hit_tc3 = |tagctl_l2_hit_ways_tc3_i;

  assign next_reqbuf_l2_hit = reqbuf_l2_hit_tc3 & (reqbuf_state == STATE_TC3);

  assign next_reqbuf_l2_hit_way = set_way_op_l2 ? set_way_l2_way : `CA53_L2_WAY_ENC(tagctl_l2_hit_ways_tc3_i);

  assign reqbuf_l1_hit_cpus_tc3 = {|tagctl_l1_hit_ways_tc3_i[15:12],
                                   |tagctl_l1_hit_ways_tc3_i[11:8],
                                   |tagctl_l1_hit_ways_tc3_i[7:4],
                                   |tagctl_l1_hit_ways_tc3_i[3:0]};

  assign next_reqbuf_l1_hit_cpus = reqbuf_l1_hit_cpus_tc3 & {4{reqbuf_state == STATE_TC3}};

  assign tagctl_l1_hit_ways_tc3_0 = tagctl_l1_hit_ways_tc3_i[3:0];
  assign tagctl_l1_hit_ways_tc3_1 = tagctl_l1_hit_ways_tc3_i[7:4];
  assign tagctl_l1_hit_ways_tc3_2 = tagctl_l1_hit_ways_tc3_i[11:8];
  assign tagctl_l1_hit_ways_tc3_3 = tagctl_l1_hit_ways_tc3_i[15:12];

  assign next_reqbuf_l1_hit_ways = {set_way_op_l1 ? set_way_l1_way : `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_3),
                                    set_way_op_l1 ? set_way_l1_way : `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_2),
                                    set_way_op_l1 ? set_way_l1_way : `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_1),
                                    set_way_op_l1 ? set_way_l1_way : `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_0)};

  assign next_reqbuf_victim_cu = ((reqbuf_type == `CA53_REQ_READONCE) |
                                  (reqbuf_type == `CA53_REQ_READNONE) |
                                  (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                  set_way_op_l2) ? tagctl_l2_victim_cu_tc3_i : tagctl_l1_victim_cluster_unique_tc3_i;

  assign next_reqbuf_victim_shareability = (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                             (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                             (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                             (reqbuf_type == `CA53_REQ_MAKEINVALID)) ? tagctl_shareability_tc3_i :
                                            ((reqbuf_type == `CA53_REQ_READONCE) |
                                             (reqbuf_type == `CA53_REQ_READNONE) |
                                             (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                             set_way_op_l2) ? tagctl_l2_victim_shareability_tc3_i :
                                                              tagctl_l1_victim_shareability_tc3_i);

  assign hit_state_en_tc3 = ((reqbuf_state == STATE_TC3) &
                             ~tagctl_slv_flush_tc3_i & ~tagctl_ecc_err_tc3_i &
                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                                                        (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)) :
                              (reqbuf_type == `CA53_REQ_CLEANUNIQUE) ? ((reqbuf_pass == PASS_READ_SERIALISE) |
                                                                        (reqbuf_pass == PASS_CLEANUNIQUE_CHECK)) :
                                                                       (reqbuf_pass == PASS_READ_SERIALISE)));

  // Because some requests update the tags and allocate an AFB in the same
  // tagctl pass, it is possible for the request to be flushed at the same
  // time as the tags are being written. If this happens, we must detect it
  // and prevent the tag write from happening a second time because other
  // requests may have read the now invalidated lines and start to use them.
  // If the lookup gets an ECC error then we must not update the state because
  // for some passes the ways looked up depend on what previously hit and so we
  // need to keep this state for when the pass that got the error is retried.
  assign hit_state_en = (hit_state_en_tc3 |
                         (reqbuf_state_tc1 &
                          (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                            (L2_CACHE == 0) &
                            (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1)) |
                           ((ACE != 0) &
                            ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                             (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                             (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                            ((reqbuf_pass == PASS_ADDRMAINT_MASTER_W) |
                             (reqbuf_pass == PASS_ADDRMAINT_UPDATE))))));

  always @(posedge clk_reqbuf)
  if (hit_state_en) begin
    reqbuf_l1_hit_cpus <= next_reqbuf_l1_hit_cpus;
    reqbuf_l1_hit_ways <= next_reqbuf_l1_hit_ways;
  end

  always @(posedge clk_reqbuf)
  if (hit_state_en_tc3) begin
    reqbuf_cluster_unique <= tagctl_cluster_unique_tc3_i;
  end

  assign hit_state_en_tc4 = ((reqbuf_state == STATE_TC4) &
                             ~tagctl_slv_flush_tc4_i &
                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                                                        (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)) :
                              (reqbuf_type == `CA53_REQ_CLEANUNIQUE) ? ((reqbuf_pass == PASS_READ_SERIALISE) |
                                                                        (reqbuf_pass == PASS_CLEANUNIQUE_CHECK)) :
                                                                       (reqbuf_pass == PASS_READ_SERIALISE)));

  always @(posedge clk_reqbuf)
  if (hit_state_en_tc4) begin
    reqbuf_snoop_data_cpu <= tagctl_snoop_data_cpu_tc4_i;
  end

  assign victim_hit_state_en = hit_state_en_tc3 | ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                                   (reqbuf_victim_pass == PASS_VICTIM_READ));

  always @(posedge clk_reqbuf)
  if (victim_hit_state_en) begin
    reqbuf_victim_cu           <= next_reqbuf_victim_cu;
    reqbuf_victim_shareability <= next_reqbuf_victim_shareability;
  end

  // For requests that can both hit in the cluster and still need to make an
  // external request, or update the tags, we alter the shareability of the
  // original request to match that of the lines that hit, to ensure consistent
  // behaviour for the line in the cache (i.e. the line cannot change its
  // shareability once allocated to the cluster).
  assign reqbuf_shareability_en = (reqbuf_alloc_i |
                                   ((reqbuf_state == STATE_TC3) &
                                    (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) & (reqbuf_pass == PASS_WRITE_SERIALISE)) |
                                     ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_READSHARED)) & (reqbuf_pass == PASS_READ_SERIALISE))));

  // If the request doesn't hit then we must keep the original shareability.
  // This must include the case when the request hits but is flushed, and then
  // misses when it retries the lookup.
  assign use_hit_shareability = (reqbuf_l2_hit_tc3 |
                                 (((reqbuf_type == `CA53_REQ_READUNIQUE) |
                                   (reqbuf_type == `CA53_REQ_READSHARED)) ? |(reqbuf_l1_hit_cpus_tc3 &
                                                                              ~reqbuf_requestor_cpu) :
                                                                            |reqbuf_l1_hit_cpus_tc3));

  assign next_reqbuf_shareability = (reqbuf_alloc_i       ? ar_attrs_i[1:0] :
                                     use_hit_shareability ? tagctl_shareability_tc3_i :
                                                            reqbuf_attrs[1:0]);

  always @(posedge clk_reqbuf)
  if (reqbuf_shareability_en) begin
    reqbuf_shareability <= next_reqbuf_shareability;
  end

  assign reqbuf_l1_hit = |reqbuf_l1_hit_cpus;

  assign reqbuf_requestor_cpu = {REQBUF_ID[5:3] == 3'b011,
                                 REQBUF_ID[5:3] == 3'b010,
                                 REQBUF_ID[5:3] == 3'b001,
                                 REQBUF_ID[5:3] == 3'b000};

  assign reqbuf_requestor_l1_mask = {{4{reqbuf_requestor_cpu[3]}},
                                     {4{reqbuf_requestor_cpu[2]}},
                                     {4{reqbuf_requestor_cpu[1]}},
                                     {4{reqbuf_requestor_cpu[0]}}};

  assign reqbuf_l1_hit_requestor = |(reqbuf_l1_hit_cpus & reqbuf_requestor_cpu);
  assign reqbuf_l1_hit_other_cpus = |(reqbuf_l1_hit_cpus & ~reqbuf_requestor_cpu);


  generate if (L2_CACHE) begin : g_l2cc_hit

    always @(posedge clk_reqbuf)
    if (hit_state_en) begin
      reqbuf_l2_hit          <= next_reqbuf_l2_hit;
      reqbuf_l2_hit_way      <= next_reqbuf_l2_hit_way;
      reqbuf_l2_dirty        <= tagctl_l2_dirty_tc3_i;
    end

  end else begin : g_n_l2cc_hit

    always @*
    begin
      reqbuf_l2_hit          =    zero;
      reqbuf_l2_hit_way      = {4{zero}};
      reqbuf_l2_dirty        =    zero;
    end

  end endgenerate

  assign sel_err = ((reqbuf_type == `CA53_REQ_READUNIQUE) |
                    (reqbuf_type == `CA53_REQ_READSHARED));

  // WriteUniques need to know if the request is for a full cache line of data,
  // to determine what type of request to send.
  always @*
  case (primary_l2db)
    4'b0000: next_reqbuf_l2db_full_err = sel_err ? l2db0_slv_err_i  : l2db0_full_line_i;
    4'b0001: next_reqbuf_l2db_full_err = sel_err ? l2db1_slv_err_i  : l2db1_full_line_i;
    4'b0010: next_reqbuf_l2db_full_err = sel_err ? l2db2_slv_err_i  : l2db2_full_line_i;
    4'b0011: next_reqbuf_l2db_full_err = sel_err ? l2db3_slv_err_i  : l2db3_full_line_i;
    4'b0100: next_reqbuf_l2db_full_err = sel_err ? l2db4_slv_err_i  : l2db4_full_line_i;
    4'b0101: next_reqbuf_l2db_full_err = sel_err ? l2db5_slv_err_i  : l2db5_full_line_i;
    4'b0110: next_reqbuf_l2db_full_err = sel_err ? l2db6_slv_err_i  : l2db6_full_line_i;
    4'b0111: next_reqbuf_l2db_full_err = sel_err ? l2db7_slv_err_i  : l2db7_full_line_i;
    4'b1000: next_reqbuf_l2db_full_err = sel_err ? l2db8_slv_err_i  : l2db8_full_line_i;
    4'b1001: next_reqbuf_l2db_full_err = sel_err ? l2db9_slv_err_i  : l2db9_full_line_i;
    4'b1010: next_reqbuf_l2db_full_err = sel_err ? l2db10_slv_err_i : l2db10_full_line_i;
    default: next_reqbuf_l2db_full_err = 1'bx;
  endcase

  // For writes, the L2DB full information must be captured after all the data
  // has arrived from the CPU, but then must not change when external data is
  // merged into the L2DB.
  assign reqbuf_l2db_full_err_en = (((reqbuf_state == STATE_WAIT_L2DB) & ((reqbuf_type == `CA53_REQ_READUNIQUE) |
                                                                          (reqbuf_type == `CA53_REQ_READSHARED))) |
                                    (reqbuf_state_tc0_tc1 & ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                                              (reqbuf_type == `CA53_REQ_WRITENOSNOOP)))));

  always @(posedge clk_reqbuf)
  if (reqbuf_l2db_full_err_en) begin
    reqbuf_l2db_full_err <= next_reqbuf_l2db_full_err;
  end

  assign reqbuf_l2db_full_o = reqbuf_l2db_full_err;

  // If the data is an exact number of 64 bit chunks, then no read-modify-write
  // is needed for ECC calculations.
  always @*
  case (primary_l2db)
    4'b0000: reqbuf_l2db_rmw = l2db0_rmw_line_i;
    4'b0001: reqbuf_l2db_rmw = l2db1_rmw_line_i;
    4'b0010: reqbuf_l2db_rmw = l2db2_rmw_line_i;
    4'b0011: reqbuf_l2db_rmw = l2db3_rmw_line_i;
    4'b0100: reqbuf_l2db_rmw = l2db4_rmw_line_i;
    4'b0101: reqbuf_l2db_rmw = l2db5_rmw_line_i;
    4'b0110: reqbuf_l2db_rmw = l2db6_rmw_line_i;
    4'b0111: reqbuf_l2db_rmw = l2db7_rmw_line_i;
    4'b1000: reqbuf_l2db_rmw = l2db8_rmw_line_i;
    4'b1001: reqbuf_l2db_rmw = l2db9_rmw_line_i;
    4'b1010: reqbuf_l2db_rmw = l2db10_rmw_line_i;
    default: reqbuf_l2db_rmw = 1'bx;
  endcase

  // Store the responses from primary and victim snoops.

  assign next_reqbuf_l1_dirty = (((reqbuf_afb == 3'b000) & afb0_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b001) & afb1_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b010) & afb2_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b011) & afb3_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b100) & afb4_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b101) & afb5_snoop_resp_dirty_i)) & ~reqbuf_alloc_i;

  assign next_reqbuf_l1_migratory = (((reqbuf_afb == 3'b000) & afb0_snoop_resp_migratory_i) |
                                     ((reqbuf_afb == 3'b001) & afb1_snoop_resp_migratory_i) |
                                     ((reqbuf_afb == 3'b010) & afb2_snoop_resp_migratory_i) |
                                     ((reqbuf_afb == 3'b011) & afb3_snoop_resp_migratory_i) |
                                     ((reqbuf_afb == 3'b100) & afb4_snoop_resp_migratory_i) |
                                     ((reqbuf_afb == 3'b101) & afb5_snoop_resp_migratory_i)) & ~reqbuf_alloc_i;

  assign reqbuf_l1_resp_valid = ((((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i) |
                                  (reqbuf_state == STATE_WAIT_AFB)) &
                                 ((reqbuf_pass == PASS_READ_SERIALISE) |
                                  ((reqbuf_type == `CA53_REQ_DVM) &
                                   (reqbuf_pass == PASS_WRITE_SERIALISE))) &
                                 (((reqbuf_afb == 3'b000) & afb0_snoop_resp_valid_i) |
                                  ((reqbuf_afb == 3'b001) & afb1_snoop_resp_valid_i) |
                                  ((reqbuf_afb == 3'b010) & afb2_snoop_resp_valid_i) |
                                  ((reqbuf_afb == 3'b011) & afb3_snoop_resp_valid_i) |
                                  ((reqbuf_afb == 3'b100) & afb4_snoop_resp_valid_i) |
                                  ((reqbuf_afb == 3'b101) & afb5_snoop_resp_valid_i)));

  assign reqbuf_l1_resp_en = reqbuf_l1_resp_valid | reqbuf_alloc_i;

  always @(posedge clk_reqbuf)
  if (reqbuf_l1_resp_en) begin
    reqbuf_l1_dirty     <= next_reqbuf_l1_dirty;
    reqbuf_l1_migratory <= next_reqbuf_l1_migratory;
  end

  assign reqbuf_l1_resp_victim_en = ((reqbuf_state == STATE_WAIT_AFB) &
                                     ~((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                       (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                     (((reqbuf_afb == 3'b000) & afb0_snoop_resp_victim_valid_i) |
                                      ((reqbuf_afb == 3'b001) & afb1_snoop_resp_victim_valid_i) |
                                      ((reqbuf_afb == 3'b010) & afb2_snoop_resp_victim_valid_i) |
                                      ((reqbuf_afb == 3'b011) & afb3_snoop_resp_victim_valid_i) |
                                      ((reqbuf_afb == 3'b100) & afb4_snoop_resp_victim_valid_i) |
                                      ((reqbuf_afb == 3'b101) & afb5_snoop_resp_victim_valid_i)));

  assign reqbuf_l1_cleanop_resp_en = (reqbuf_l1_resp_valid &
                                      ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                       (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                      ~(reqbuf_l2_hit & reqbuf_l2_dirty));

  assign reqbuf_resp_victim_en = (reqbuf_l1_resp_victim_en |
                                  reqbuf_l1_cleanop_resp_en |
                                  ((reqbuf_state == STATE_TC3) &
                                   (((reqbuf_pass == PASS_READ_SERIALISE) &
                                     ((reqbuf_type == `CA53_REQ_READONCE) |
                                      (reqbuf_type == `CA53_REQ_READNONE) |
                                      (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                      (reqbuf_type == `CA53_REQ_MAKEINVALID) |
                                      (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVSETWAY))) |
                                    (((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                      (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)) &
                                     (reqbuf_type == `CA53_REQ_WRITEUNIQUE)))) |
                                  ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                   (reqbuf_victim_pass == PASS_VICTIM_READ)));

  assign next_reqbuf_victim_dirty = reqbuf_l1_resp_victim_en ? (((reqbuf_afb == 3'b000) & afb0_snoop_resp_victim_dirty_i) |
                                                                ((reqbuf_afb == 3'b001) & afb1_snoop_resp_victim_dirty_i) |
                                                                ((reqbuf_afb == 3'b010) & afb2_snoop_resp_victim_dirty_i) |
                                                                ((reqbuf_afb == 3'b011) & afb3_snoop_resp_victim_dirty_i) |
                                                                ((reqbuf_afb == 3'b100) & afb4_snoop_resp_victim_dirty_i) |
                                                                ((reqbuf_afb == 3'b101) & afb5_snoop_resp_victim_dirty_i)) :
                                                               tagctl_l2_dirty_tc3_i;
  
  assign next_reqbuf_victim_alloc = (reqbuf_l1_resp_victim_en  ? (((reqbuf_afb == 3'b000) & afb0_snoop_resp_victim_alloc_i) |
                                                                  ((reqbuf_afb == 3'b001) & afb1_snoop_resp_victim_alloc_i) |
                                                                  ((reqbuf_afb == 3'b010) & afb2_snoop_resp_victim_alloc_i) |
                                                                  ((reqbuf_afb == 3'b011) & afb3_snoop_resp_victim_alloc_i) |
                                                                  ((reqbuf_afb == 3'b100) & afb4_snoop_resp_victim_alloc_i) |
                                                                  ((reqbuf_afb == 3'b101) & afb5_snoop_resp_victim_alloc_i)) :
                                     reqbuf_l1_cleanop_resp_en ? (((reqbuf_afb == 3'b000) & afb0_snoop_resp_alloc_i) |
                                                                  ((reqbuf_afb == 3'b001) & afb1_snoop_resp_alloc_i) |
                                                                  ((reqbuf_afb == 3'b010) & afb2_snoop_resp_alloc_i) |
                                                                  ((reqbuf_afb == 3'b011) & afb3_snoop_resp_alloc_i) |
                                                                  ((reqbuf_afb == 3'b100) & afb4_snoop_resp_alloc_i) |
                                                                  ((reqbuf_afb == 3'b101) & afb5_snoop_resp_alloc_i)) :
                                     ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                      (reqbuf_type == `CA53_REQ_MAKEINVALID)) ? tagctl_l2_alloc_tc3_i :
                                                                                tagctl_l2_victim_alloc_tc3_i);

  assign next_reqbuf_victim_age = reqbuf_l1_resp_victim_en ? (((reqbuf_afb == 3'b000) & afb0_snoop_resp_victim_age_i) |
                                                              ((reqbuf_afb == 3'b001) & afb1_snoop_resp_victim_age_i) |
                                                              ((reqbuf_afb == 3'b010) & afb2_snoop_resp_victim_age_i) |
                                                              ((reqbuf_afb == 3'b011) & afb3_snoop_resp_victim_age_i) |
                                                              ((reqbuf_afb == 3'b100) & afb4_snoop_resp_victim_age_i) |
                                                              ((reqbuf_afb == 3'b101) & afb5_snoop_resp_victim_age_i)) :
                                                               1'b0;


  always @(posedge clk_reqbuf)
  if (reqbuf_resp_victim_en) begin
    reqbuf_victim_dirty <= next_reqbuf_victim_dirty;
    reqbuf_victim_alloc <= next_reqbuf_victim_alloc;
    reqbuf_victim_age   <= next_reqbuf_victim_age;
  end

  // Store the results of the victim lookup.
  assign l1_victim_hit_en = (((reqbuf_victim_state == STATE_VICTIM_TC3) &
                              (reqbuf_victim_pass == PASS_VICTIM_WRITE)) |
                             ((reqbuf_state == STATE_TC3) &
                              (reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                              (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)));

  assign next_reqbuf_l1_victim_hit = |reqbuf_l1_hit_cpus_tc3;

  always @(posedge clk_reqbuf)
  if (l1_victim_hit_en) begin
    reqbuf_l1_victim_hit <= next_reqbuf_l1_victim_hit;
  end

  generate if (L2_CACHE) begin : g_l2cc

    assign l2_victim_hit_en = (((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                (reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                ~tagctl_ecc_err_tc3_i) |
                               ((reqbuf_state == STATE_TC3) & ~tagctl_slv_flush_tc3_i &
                                (((reqbuf_pass == PASS_READ_SERIALISE) &
                                  ((reqbuf_type == `CA53_REQ_READONCE) |
                                   (reqbuf_type == `CA53_REQ_READNONE) |
                                   (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                   (reqbuf_type == `CA53_REQ_CLEANINVSETWAY))) |
                                 (((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                   (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)) &
                                  (reqbuf_type == `CA53_REQ_WRITEUNIQUE)))));


    always @(posedge clk_reqbuf)
    if (l2_victim_hit_en) begin
      reqbuf_l2_victim_hit   <= reqbuf_l2_hit_tc3;
      reqbuf_l2_victim_valid <= tagctl_l2_victim_valid_tc3_i;
      reqbuf_l2_victim_dirty <= tagctl_l2_dirty_tc3_i;
    end

    assign victimctl_victim_ack = victimctl_ack_i & (victimctl_ack_id_i == REQBUF_ID[5:0]);

    assign l2_victim_way_en = l2_victim_hit_en | victimctl_victim_ack;

    assign next_reqbuf_l2_victim_way = (set_way_op_l2        ? set_way_l2_way :
                                        victimctl_victim_ack ? victimctl_victim_way_i : 
                                        reqbuf_l2_hit_tc3    ? `CA53_L2_WAY_ENC(tagctl_l2_hit_ways_tc3_i) :
                                                               tagctl_l2_victim_way_tc3_i);

    always @(posedge clk_reqbuf)
    if (l2_victim_way_en) begin
      reqbuf_l2_victim_way <= next_reqbuf_l2_victim_way;
    end

  end else begin : g_n_l2cc

    assign l2_victim_hit_en = 1'b0;
    assign victimctl_victim_ack = 1'b0;
    assign l2_victim_way_en = 1'b0;

    always @*
    begin
      reqbuf_l2_victim_hit   = zero;
      reqbuf_l2_victim_valid = zero;
      reqbuf_l2_victim_dirty = zero;
      reqbuf_l2_victim_way   = {4{zero}};
    end

  end endgenerate

  assign reqbuf_victim_way_tc1_o = reqbuf_l2_victim_way;

  //----------------------------------------------------------------------------
  //  Tagctl requests
  //----------------------------------------------------------------------------

  assign reqbuf_dvm_sync = ((reqbuf_state != STATE_IDLE) &
                            (reqbuf_state != STATE_INITIAL) &
                            (reqbuf_state != STATE_WAIT_INITIAL) &
                            (reqbuf_type == `CA53_REQ_DVM) &
                            (reqbuf_addr2[14:12] == `CA53_ACE_DVM_SYNC));

  assign reqbuf_dvm_sync_o = reqbuf_dvm_sync;

  // If this request is a DVM sync and it will definitely hazard if it goes down
  // tagctl then we must prevent it from arbitrating so that any later
  // transactions can overtake it.
  assign dvm_sync_hazard = (dvm_comp_sync_outstanding_i &
                            reqbuf_dvm_sync &
                            (reqbuf_pass == PASS_WRITE_SERIALISE));

  // Make a request if either the primary or victim state machines want to.
  // Victim requests must have priority over primary requests because they may
  // need to make progress to allow a hazarding snoop to progress, but the
  // primary request may not be able to progress if it needs to make a master
  // read access.
  assign next_reqbuf_tagctl_req_tc0 = ((reqbuf_alloc_i & ~cpuslv_noncoh_only_i & ~|reqbufs_noncoh_only_i &
                                        ar_valid_i & ~ar_type_i[3]) |
                                       ((reqbuf_victim_next_state_tc0_tc1 ? (reqbuf_tagctl_prearb_victim_i &
                                                                             ~update_reqbuf_victim_pass) :
                                         (reqbuf_next_state_tc0_tc1 &
                                          (((update_reqbuf_pass ? next_reqbuf_pass :
                                                                  reqbuf_pass) <= {2'b00, reqbuf_type[4]}) |
                                           (reqbuf_tagctl_prearb_primary_i &
                                            ~update_reqbuf_pass &
                                            reqbuf_tagctl_primary_tc0)))) &
                                        ~dvm_sync_hazard));

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_tagctl_req_tc0 <= 1'b0;
  end else begin
    reqbuf_tagctl_req_tc0 <= next_reqbuf_tagctl_req_tc0;
  end

  assign reqbuf_tagctl_valid_tc0 = reqbuf_tagctl_req_tc0 & ~reqbuf_arb_tc1_i;

  assign reqbuf_tagctl_valid_tc0_o = reqbuf_tagctl_valid_tc0;

  assign next_reqbuf_tagctl_prearb_req = ((reqbuf_victim_next_state_tc0_tc1 ? (~reqbuf_tagctl_prearb_victim_i |
                                                                               update_reqbuf_victim_pass) :
                                           (reqbuf_next_state_tc0_tc1 &
                                            (((update_reqbuf_pass ? next_reqbuf_pass :
                                                                    reqbuf_pass) > {2'b00, reqbuf_type[4]}) &
                                             (~reqbuf_tagctl_prearb_primary_i |
                                              update_reqbuf_pass)))) &
                                          ~dvm_sync_hazard);

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_tagctl_prearb_req <= 1'b0;
  end else begin
    reqbuf_tagctl_prearb_req <= next_reqbuf_tagctl_prearb_req;
  end

  assign reqbuf_tagctl_prearb_req_o = reqbuf_tagctl_prearb_req & ~reqbuf_arb_tc1_i;

  assign reqbuf_tagctl_primary_tc0 = ~((reqbuf_victim_state == STATE_VICTIM_TC0) |
                                       (reqbuf_victim_state == STATE_VICTIM_TC0_TC1));

  assign reqbuf_tagctl_primary_tc0_o = reqbuf_tagctl_primary_tc0;

  // If this reqbuf could be blocking snoops then it must have a higher
  // priority than reqbufs that are not blocking snoops and hence which
  // may not be guaranteed to be able to proceed.
  // If it is delaying an L2 allocation then it must have an even higher
  // priority.
  assign reqbuf_tagctl_prearb_pri1_o = reqbuf_delay_allocation & ~reqbuf_tagctl_primary_tc0;
  assign reqbuf_tagctl_prearb_pri2_o = hazard_snoops | ~reqbuf_tagctl_primary_tc0;

  // Tell tagctl what type pass of the request this is, and hence what the
  // AFBs should do based on the lookup results.
  always @*
  case (reqbuf_type)
    `CA53_REQ_READNOSNOOP: reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                                                                   `CA53_TAGCTL_PASS_MASTER_R;
    `CA53_REQ_READONCE,
    `CA53_REQ_READNONE:    reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     (reqbuf_pass == PASS_READONCE_RETRY)        ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_UPDATE;
    `CA53_REQ_READSHARED:  reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     (reqbuf_pass == PASS_READSHARED_RETRY)      ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_UPDATE;
    `CA53_REQ_READUNIQUE:  reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     ((reqbuf_pass == PASS_READUNIQUE_HIT_RETRY) |
                                                      (reqbuf_pass == PASS_READUNIQUE_MISS_RETRY) |
                                                      (reqbuf_pass == PASS_READUNIQUE_HIT1))     ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_UPDATE;
    `CA53_REQ_CLEANUNIQUE: reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     (reqbuf_pass == PASS_CLEANUNIQUE_RETRY)     ? `CA53_TAGCTL_PASS_MASTER_R :
                                                     (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_R)  ? `CA53_TAGCTL_PASS_MASTER_R :
                                                     (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)  ? `CA53_TAGCTL_PASS_MASTER_W :
                                                     (reqbuf_pass == PASS_CLEANUNIQUE_CHECK)     ? `CA53_TAGCTL_PASS_LOOKUP :
                                                                                                   `CA53_TAGCTL_PASS_UPDATE;
    `CA53_REQ_WRITENOSNOOP,
    `CA53_REQ_DVM:         reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_WRITE_L2DB)            ? `CA53_TAGCTL_PASS_L2DB :
                                                     (reqbuf_pass == PASS_WRITE_SERIALISE)       ? `CA53_TAGCTL_PASS_SERIALISE :
                                                                                                   `CA53_TAGCTL_PASS_MASTER_W;
    `CA53_REQ_WRITEUNIQUE: reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_WRITE_L2DB)            ? `CA53_TAGCTL_PASS_L2DB :
                                                     (reqbuf_pass == PASS_WRITE_SERIALISE)       ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE)  ? `CA53_TAGCTL_PASS_LOOKUP :
                                                     ((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) &
                                                      (L2_CACHE != 0))                           ? `CA53_TAGCTL_PASS_UPDATE :
                                                     (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)   ? `CA53_TAGCTL_PASS_VICTIM :
                                                     (reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_MASTER_W;
    `CA53_REQ_CLEANSETWAY,
    `CA53_REQ_CLEANINVSETWAY,
    `CA53_REQ_ECCCLEAN:    reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_SERIALISE;
    `CA53_REQ_DMB,
    `CA53_REQ_DSB:         reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_BARRIER_RETRY)         ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_SERIALISE;
    `CA53_REQ_CLEANSHARED,
    `CA53_REQ_CLEANINVALID,
    `CA53_REQ_MAKEINVALID: reqbuf_primary_pass_tc0 = (reqbuf_pass == PASS_READ_SERIALISE)        ? `CA53_TAGCTL_PASS_SERIALISE :
                                                     (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)    ? `CA53_TAGCTL_PASS_MASTER_W :
                                                     ((reqbuf_pass == PASS_ADDRMAINT_MASTER_R) |
                                                      (reqbuf_pass == PASS_ADDRMAINT_RETRY))     ? `CA53_TAGCTL_PASS_MASTER_R :
                                                                                                   `CA53_TAGCTL_PASS_UPDATE;
    default:               reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_X;
  endcase

  assign reqbuf_victim_pass_tc0 = ((reqbuf_victim_pass == PASS_VICTIM_WRITE)        ? `CA53_TAGCTL_PASS_VICTIM :
                                   (reqbuf_victim_pass == PASS_VICTIM_LOOKUP)       ? `CA53_TAGCTL_PASS_L2_VICTIM :
                                   (reqbuf_victim_pass == PASS_VICTIM_READ)         ? `CA53_TAGCTL_PASS_LOOKUP :
                                                                                      `CA53_TAGCTL_PASS_VICTIM_UPDATE);


  assign reqbuf_tagctl_pass_tc0 = reqbuf_tagctl_primary_tc0 ? reqbuf_primary_pass_tc0 : reqbuf_victim_pass_tc0;

  assign reqbuf_tagctl_pass_tc0_o = reqbuf_tagctl_pass_tc0;

  // If this is a read serialise pass, or write L2DB pass, then we might need
  // to allocate an L2DB.
  assign reqbuf_l2dbs_active_o = reqbuf_tagctl_primary_tc0 & (reqbuf_pass == PASS_INITIAL);

  // Send the address to tagctl. This can be the address being looked up
  // (either primary or victim), or the address being written for a tag update.
  assign reqbuf_tagctl_addr1_tc0_o = (reqbuf_tagctl_primary_tc0 &
                                      ~((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                        (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2))) ? reqbuf_addr1 : reqbuf_addr2;


  assign tag_l1_update_shareability_tc0 = (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                            set_way_op_l1) ? reqbuf_victim_shareability :
                                                             reqbuf_shareability);

  // Provide the state bits for tag RAM writes.
  assign tag_state_l1_sh_tc0 = (`CA53_MEM_O_SHAREABLE(tag_l1_update_shareability_tc0) ? 2'b11 :
                                `CA53_MEM_SHAREABLE(tag_l1_update_shareability_tc0)   ? 2'b10 :
                                                                                        2'b01);

  assign tag_state_l1_tc0 = (((reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                              (reqbuf_type == `CA53_REQ_ECCCLEAN) |
                              (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                              (reqbuf_type == `CA53_REQ_MAKEINVALID) |
                              (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                              (((reqbuf_type == `CA53_REQ_READSHARED) |
                                (reqbuf_type == `CA53_REQ_READUNIQUE)) &
                               (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit) &
                               reqbuf_l2db_full_err &
                               ~ext_snoop_invalidated) |
                              (((reqbuf_type == `CA53_REQ_READSHARED) |
                                ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                 (ext_snoop_invalidated |
                                  ~(reqbuf_l1_hit_other_cpus | reqbuf_l2_hit)))) &
                               ((ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                (ext_beats_resp == `CA53_ACE_RESP_SLVERR)))) ? 2'b00 : tag_state_l1_sh_tc0);

  assign tag_state_l1_cu_tc0 = (((reqbuf_type == `CA53_REQ_READUNIQUE) |
                                 (reqbuf_type == `CA53_REQ_CLEANUNIQUE)) ? 1'b1 :
                                ((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                 (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                 (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                 (reqbuf_type == `CA53_REQ_ECCCLEAN) |
                                 (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                 (reqbuf_type == `CA53_REQ_MAKEINVALID) |
                                 (ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                 (ext_beats_resp == `CA53_ACE_RESP_SLVERR) |
                                 ((ext_beats_resp == `CA53_ACE_RESP_EXOKAY) & ~reqbuf_lock)) ? 1'b0 :
                                ext_beats_received ? ~ext_beats_shared :
                                                     reqbuf_cluster_unique);

  assign tag_state_l2_tc0 = (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                              (reqbuf_type == `CA53_REQ_READONCE) |
                              (reqbuf_type == `CA53_REQ_READNONE)) ? {{2{ext_beats_resp == `CA53_ACE_RESP_OKAY}} &
                                                                      {`CA53_MEM_SHAREABLE(reqbuf_shareability),
                                                                       `CA53_MEM_O_SHAREABLE(reqbuf_shareability) |
                                                                       ~`CA53_MEM_SHAREABLE(reqbuf_shareability)},
                                                                      ~ext_beats_shared | (reqbuf_type == `CA53_REQ_WRITEUNIQUE),
                                                                      ext_beats_dirty   | (reqbuf_type == `CA53_REQ_WRITEUNIQUE),
                                                                      `CA53_MEM_OUTER_WA(reqbuf_attrs)} :
                             ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                              set_way_op_l2) ? ({5{(reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                                   (reqbuf_type == `CA53_REQ_CLEANSHARED)}} &
                                               {reqbuf_victim_shareability[1],
                                                ~reqbuf_victim_shareability[0],
                                                1'b0, 1'b0, reqbuf_victim_alloc}) :
                             ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                              (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)) ? {reqbuf_shareability[1],
                                                                             ~reqbuf_shareability[0],
                                                                             1'b0,
                                                                             1'b0,
                                                                             reqbuf_victim_alloc} :
                             reqbuf_tagctl_primary_tc0 ? 5'b00000 :
                                                    {reqbuf_victim_shareability[1],
                                                     ~reqbuf_victim_shareability[0],
                                                     reqbuf_victim_cu,
                                                     reqbuf_victim_dirty,
                                                     reqbuf_victim_alloc});

  assign tag_state_l1_cpu0_tc0 = ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                  ((reqbuf_type == `CA53_REQ_READSHARED) &
                                   reqbuf_ecc_hz &
                                   ~(reqbuf_l1_migratory &
                                     (reqbuf_snoop_data_cpu == 2'b00)))) ? tag_state_l1_sh_tc0 : 2'b00;

  assign tag_state_l1_cpu1_tc0 = ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                  ((reqbuf_type == `CA53_REQ_READSHARED) &
                                   reqbuf_ecc_hz &
                                   ~(reqbuf_l1_migratory &
                                     (reqbuf_snoop_data_cpu == 2'b01)))) ? tag_state_l1_sh_tc0 : 2'b00;

  assign tag_state_l1_cpu2_tc0 = ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                  ((reqbuf_type == `CA53_REQ_READSHARED) &
                                   reqbuf_ecc_hz &
                                   ~(reqbuf_l1_migratory &
                                     (reqbuf_snoop_data_cpu == 2'b10)))) ? tag_state_l1_sh_tc0 : 2'b00;

  assign tag_state_l1_cpu3_tc0 = ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                  ((reqbuf_type == `CA53_REQ_READSHARED) &
                                   reqbuf_ecc_hz &
                                   ~(reqbuf_l1_migratory &
                                     (reqbuf_snoop_data_cpu == 2'b11)))) ? tag_state_l1_sh_tc0 : 2'b00;

  assign reqbuf_tagctl_wr_state_tc0_o = {tag_state_l2_tc0,
                                         {reqbuf_requestor_cpu[3] ? tag_state_l1_tc0 : tag_state_l1_cpu3_tc0, tag_state_l1_cu_tc0},
                                         {reqbuf_requestor_cpu[2] ? tag_state_l1_tc0 : tag_state_l1_cpu2_tc0, tag_state_l1_cu_tc0},
                                         {reqbuf_requestor_cpu[1] ? tag_state_l1_tc0 : tag_state_l1_cpu1_tc0, tag_state_l1_cu_tc0},
                                         {reqbuf_requestor_cpu[0] ? tag_state_l1_tc0 : tag_state_l1_cpu0_tc0, tag_state_l1_cu_tc0}};


  // Calculate the ways that need accessing on each type of tagctl pass.

  assign set_way_l1_way = reqbuf_addr1[31:30];
  assign set_way_l2_way = reqbuf_addr1[31:28];

  assign reqbuf_setway_ways_tc0 = set_way_op_l2 ? {`CA53_L2_WAY_DEC(set_way_l2_way), 16'h0000} :
                                                  {16'h0000, {`CA53_L1_WAY_DEC(set_way_l1_way),
                                                              `CA53_L1_WAY_DEC(set_way_l1_way),
                                                              `CA53_L1_WAY_DEC(set_way_l1_way),
                                                              `CA53_L1_WAY_DEC(set_way_l1_way)} &
                                                   reqbuf_requestor_l1_mask};

  assign reqbuf_l1_lookup_ways_tc0 = ({`CA53_L1_WAY_DEC(reqbuf_req_way),
                                       `CA53_L1_WAY_DEC(reqbuf_req_way),
                                       `CA53_L1_WAY_DEC(reqbuf_req_way),
                                       `CA53_L1_WAY_DEC(reqbuf_req_way)} | ~reqbuf_requestor_l1_mask);

  assign reqbuf_l1_hit_ways_0 = reqbuf_l1_hit_ways[1:0];
  assign reqbuf_l1_hit_ways_1 = reqbuf_l1_hit_ways[3:2];
  assign reqbuf_l1_hit_ways_2 = reqbuf_l1_hit_ways[5:4];
  assign reqbuf_l1_hit_ways_3 = reqbuf_l1_hit_ways[7:6];

  assign reqbuf_hit_ways = {{16{reqbuf_l2_hit}} & `CA53_L2_WAY_DEC(reqbuf_l2_hit_way),
                            {4{reqbuf_l1_hit_cpus[3]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_3),
                            {4{reqbuf_l1_hit_cpus[2]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_2),
                            {4{reqbuf_l1_hit_cpus[1]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_1),
                            {4{reqbuf_l1_hit_cpus[0]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_0)};

  assign reqbuf_l1_requestor_update_ways_tc0 = {`CA53_L1_WAY_DEC(reqbuf_req_way),
                                                `CA53_L1_WAY_DEC(reqbuf_req_way),
                                                `CA53_L1_WAY_DEC(reqbuf_req_way),
                                                `CA53_L1_WAY_DEC(reqbuf_req_way)} & reqbuf_requestor_l1_mask;

  assign reqbuf_l1_other_update_ways_tc0 = reqbuf_hit_ways[15:0] & ~reqbuf_requestor_l1_mask;

  always @*
  case (reqbuf_type)
    `CA53_REQ_READSHARED: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:            reqbuf_primary_tagctl_ways_tc0 = {16'hffff, reqbuf_l1_lookup_ways_tc0};
        PASS_READSHARED_RETRY:          reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_READSHARED_MISS,
        PASS_READSHARED_L1_HIT,
        PASS_READSHARED_L2_HIT:         reqbuf_primary_tagctl_ways_tc0 = {reqbuf_hit_ways[31:16],
                                                                          reqbuf_l1_requestor_update_ways_tc0 |
                                                                          ({16{reqbuf_l1_migratory | reqbuf_ecc_hz}} &
                                                                           reqbuf_l1_other_update_ways_tc0 &
                                                                           ({{4{reqbuf_snoop_data_cpu == 2'b11}},
                                                                             {4{reqbuf_snoop_data_cpu == 2'b10}},
                                                                             {4{reqbuf_snoop_data_cpu == 2'b01}},
                                                                             {4{reqbuf_snoop_data_cpu == 2'b00}}} |
                                                                            {16{reqbuf_ecc_hz}}))};
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_READUNIQUE: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:            reqbuf_primary_tagctl_ways_tc0 = {16'hffff, reqbuf_l1_lookup_ways_tc0};
        PASS_READUNIQUE_HIT_RETRY,
        PASS_READUNIQUE_MISS_RETRY,
        PASS_READUNIQUE_HIT1:           reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_READUNIQUE_HIT2,
        PASS_READUNIQUE_MISS:           reqbuf_primary_tagctl_ways_tc0 = {reqbuf_hit_ways[31:16],
                                                                          reqbuf_l1_requestor_update_ways_tc0 |
                                                                          reqbuf_l1_other_update_ways_tc0};
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_READONCE,
    `CA53_REQ_READNONE: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:            reqbuf_primary_tagctl_ways_tc0 = 32'hffffffff;
        PASS_READONCE_RETRY:            reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_READONCE_MISS:             reqbuf_primary_tagctl_ways_tc0 = {`CA53_L2_WAY_DEC(reqbuf_l2_victim_way), 16'h0000};
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_WRITEUNIQUE: begin
      case (reqbuf_pass)
        PASS_WRITE_SERIALISE:           reqbuf_primary_tagctl_ways_tc0 = 32'hffffffff;
        PASS_WRITE_L2DB,
        PASS_WRITEUNIQUE_MISS_RETRY,
        PASS_WRITEUNIQUE_HIT_RETRY,
        PASS_WRITEUNIQUE_MISS:          reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_WRITEUNIQUE_UNIQUE2:       reqbuf_primary_tagctl_ways_tc0 = 32'h0000ffff;
        PASS_WRITEUNIQUE_UNIQUE1,
        PASS_WRITEUNIQUE_N_UNIQUE:      reqbuf_primary_tagctl_ways_tc0 = {reqbuf_l2_hit ? reqbuf_hit_ways[31:16] :
                                                                                          `CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                                                          reqbuf_hit_ways[15:0]};
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_CLEANUNIQUE: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:            reqbuf_primary_tagctl_ways_tc0 = {16'hffff, reqbuf_l1_lookup_ways_tc0};
        PASS_CLEANUNIQUE_MASTER_W:      reqbuf_primary_tagctl_ways_tc0 = {(reqbuf_l2_hit &
                                                                           reqbuf_l2_dirty &
                                                                           reqbuf_lock &
                                                                           tag_write_needed) ? reqbuf_hit_ways[31:16] :
                                                                                          16'h0000,
                                                                          16'h0000};
        PASS_CLEANUNIQUE_MASTER_R,
        PASS_CLEANUNIQUE_RETRY:         reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_CLEANUNIQUE_CHECK:         reqbuf_primary_tagctl_ways_tc0 = {reqbuf_hit_ways[31:16], reqbuf_l1_other_update_ways_tc0};
        PASS_CLEANUNIQUE_UNIQUE_UPDATE,
        PASS_CLEANUNIQUE_UPDATE:        reqbuf_primary_tagctl_ways_tc0 = {reqbuf_hit_ways[31:16],
                                                                          (reqbuf_l1_requestor_update_ways_tc0 &
                                                                           ~{16{ext_snoop_invalidated}}) |
                                                                          reqbuf_l1_other_update_ways_tc0};
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_CLEANSHARED,
    `CA53_REQ_CLEANINVALID,
    `CA53_REQ_MAKEINVALID: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:            reqbuf_primary_tagctl_ways_tc0 = 32'hffffffff;
        PASS_ADDRMAINT_UPDATE,
        PASS_ADDRMAINT_MASTER_W:        reqbuf_primary_tagctl_ways_tc0 = ((ACE != 0) | tag_write_needed) ? reqbuf_hit_ways : 32'h00000000;
        PASS_ADDRMAINT_RETRY,
        PASS_ADDRMAINT_MASTER_R:        reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        default:                        reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    `CA53_REQ_CLEANSETWAY,
    `CA53_REQ_CLEANINVSETWAY,
    `CA53_REQ_ECCCLEAN:                 reqbuf_primary_tagctl_ways_tc0 = reqbuf_setway_ways_tc0;
    `CA53_REQ_READNOSNOOP,
    `CA53_REQ_WRITENOSNOOP,
    `CA53_REQ_DMB,
    `CA53_REQ_DSB,
    `CA53_REQ_DVM:                      reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
    default:                            reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
  endcase

  // Because L1 set/way ops write the L1 tag at the same time as reading the
  // L2 tags, it is possible for the pass to get flushed due to an ECC error
  // on the read. If this happens, we must not repeat the L1 tag write because
  // another request may have since read that tag and seen the updated value.
  // Similarly CleanUniques must update the L2 tag at the same time as doing a
  // master write which may not be able to allocate an AFB.
  assign next_tag_write_needed = (reqbuf_alloc_i |
                                  (tag_write_needed &
                                   ~((reqbuf_victim_state_tc1 &
                                      ((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) |
                                       (reqbuf_victim_pass == PASS_VICTIM_WRITE))) |
                                     (reqbuf_state_tc1 &
                                      (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                        (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)) |
                                       ((ACE == 0) &
                                        ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                         (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                         (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                        ((reqbuf_pass == PASS_ADDRMAINT_MASTER_W) |
                                         (reqbuf_pass == PASS_ADDRMAINT_UPDATE))))))));

  always @(posedge clk_reqbuf)
  if (reqbuf_en) begin
    tag_write_needed <= next_tag_write_needed;
  end

  always @*
  case (reqbuf_victim_pass)
    PASS_VICTIM_LOOKUP: reqbuf_victim_tagctl_ways_tc0 = {16'hffff, {16{set_way_op_l1 & tag_write_needed}} &
                                                                   reqbuf_setway_ways_tc0[15:0]};
    PASS_VICTIM_READ:   reqbuf_victim_tagctl_ways_tc0 = {`CA53_L2_WAY_DEC(reqbuf_l2_victim_way), 16'h0000};
    PASS_VICTIM_WRITE:  reqbuf_victim_tagctl_ways_tc0 = {{16{set_way_op_l2 & tag_write_needed}} &
                                                         `CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                                         {16{(reqbuf_type == `CA53_REQ_READONCE) |
                                                             (reqbuf_type == `CA53_REQ_READNONE) |
                                                             set_way_op_l2}} |
                                                         ({16{set_way_op_l1 & tag_write_needed}} &
                                                          reqbuf_setway_ways_tc0[15:0]) |
                                                         ~reqbuf_requestor_l1_mask};
    PASS_VICTIM_UPDATE: reqbuf_victim_tagctl_ways_tc0 = {`CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                                         {16{reqbuf_l2_victim_valid & ~reqbuf_l2_victim_hit}}};
    default:            reqbuf_victim_tagctl_ways_tc0 = {32{1'bx}};
  endcase

  assign reqbuf_tagctl_ways_tc0_o = reqbuf_tagctl_primary_tc0 ? reqbuf_primary_tagctl_ways_tc0 : reqbuf_victim_tagctl_ways_tc0;


  assign reqbuf_tagctl_primary_write_tc0 = ((((reqbuf_type == `CA53_REQ_READSHARED) |
                                              (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                              (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                              (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                              (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                             reqbuf_tagctl_primary_tc0 &
                                             (reqbuf_pass != PASS_READ_SERIALISE)) |
                                            ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                             ((reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W) |
                                              (reqbuf_pass == PASS_CLEANUNIQUE_UNIQUE_UPDATE) |
                                              (reqbuf_pass == PASS_CLEANUNIQUE_UPDATE))) |
                                            (((reqbuf_type == `CA53_REQ_READONCE) |
                                              (reqbuf_type == `CA53_REQ_READNONE)) &
                                             reqbuf_tagctl_primary_tc0 &
                                             (reqbuf_pass != PASS_READ_SERIALISE)) |
                                            ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                             (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1)));

  assign reqbuf_tagctl_l1_write_tc0 = ({4{reqbuf_tagctl_primary_write_tc0}} |
                                       ({4{set_way_op_l1 & ((reqbuf_victim_pass == PASS_VICTIM_WRITE) |
                                                            (reqbuf_victim_pass == PASS_VICTIM_LOOKUP))}} & reqbuf_requestor_cpu));

  assign reqbuf_tagctl_l2_write_tc0 = (reqbuf_tagctl_primary_write_tc0 |
                                       (~reqbuf_tagctl_primary_tc0 & ((reqbuf_victim_pass == PASS_VICTIM_UPDATE) |
                                                                      (reqbuf_victim_pass == PASS_VICTIM_WRITE))));

  assign reqbuf_tagctl_write_tc0_o = {reqbuf_tagctl_l2_write_tc0,
                                      reqbuf_tagctl_l1_write_tc0};

  // TC1 data

  // Tell tagctl if the line this request relates to is dirty, so that it can
  // pick the write type of external request to make.
  assign reqbuf_dirty_o = reqbuf_victim_dirty;

  assign reqbuf_cluster_unique_o = reqbuf_victim_cu;

  assign victim_attrs = {4'b1011, 1'b1, reqbuf_victim_alloc, reqbuf_victim_shareability};

  assign reqbuf_attrs_o = (((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                              (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                              (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                             (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)) |
                            ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                             (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)) |
                            ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                             (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2))) ? victim_attrs :
                           reqbuf_state_tc1 ? {reqbuf_attrs[7:2],
                                               (reqbuf_pass <= {2'b00, reqbuf_type[4]}) ? reqbuf_attrs[1:0] :
                                                                                          reqbuf_shareability} :
                                              victim_attrs);

  assign reqbuf_l2db_tc1_o = reqbuf_state_tc1 ? primary_l2db : victim_l2db;

  // The AFB is allocated in tc1, and we must record it so that we know when it
  // has completed all snoops or master requests.
  assign next_reqbuf_afb = reqbuf_state_tc1 ? tagctl_slv_afb_tc1_i : reqbuf_afb;

  assign next_reqbuf_victim_afb = (reqbuf_victim_state_tc1 |
                                   (reqbuf_state_tc1 &
                                    (reqbuf_pass == PASS_READ_SERIALISE))) ? tagctl_slv_afb_tc1_i : reqbuf_victim_afb;

  always @(posedge clk_reqbuf)
  if (reqbuf_en) begin
    reqbuf_afb        <= next_reqbuf_afb;
    reqbuf_victim_afb <= next_reqbuf_victim_afb;
  end

  assign afb_done = ((afb0_done_i & (reqbuf_afb == 3'b000)) |
                     (afb1_done_i & (reqbuf_afb == 3'b001)) |
                     (afb2_done_i & (reqbuf_afb == 3'b010)) |
                     (afb3_done_i & (reqbuf_afb == 3'b011)) |
                     (afb4_done_i & (reqbuf_afb == 3'b100)) |
                     (afb5_done_i & (reqbuf_afb == 3'b101)));

  assign victim_afb_done = ((afb0_done_i & (reqbuf_victim_afb == 3'b000)) |
                            (afb1_done_i & (reqbuf_victim_afb == 3'b001)) |
                            (afb2_done_i & (reqbuf_victim_afb == 3'b010)) |
                            (afb3_done_i & (reqbuf_victim_afb == 3'b011)) |
                            (afb4_done_i & (reqbuf_victim_afb == 3'b100)) |
                            (afb5_done_i & (reqbuf_victim_afb == 3'b101)));

  assign afb_victim_write = (((reqbuf_victim_afb == 3'b000) & afb0_write_done_i) |
                             ((reqbuf_victim_afb == 3'b001) & afb1_write_done_i) |
                             ((reqbuf_victim_afb == 3'b010) & afb2_write_done_i) |
                             ((reqbuf_victim_afb == 3'b011) & afb3_write_done_i) |
                             ((reqbuf_victim_afb == 3'b100) & afb4_write_done_i) |
                             ((reqbuf_victim_afb == 3'b101) & afb5_write_done_i));

  assign afb_primary_write = (((reqbuf_afb == 3'b000) & afb0_write_done_i) |
                              ((reqbuf_afb == 3'b001) & afb1_write_done_i) |
                              ((reqbuf_afb == 3'b010) & afb2_write_done_i) |
                              ((reqbuf_afb == 3'b011) & afb3_write_done_i) |
                              ((reqbuf_afb == 3'b100) & afb4_write_done_i) |
                              ((reqbuf_afb == 3'b101) & afb5_write_done_i));

  //----------------------------------------------------------------------------
  //  Victimctl requests
  //----------------------------------------------------------------------------

  assign reqbuf_victimctl_active_o = (((reqbuf_state == STATE_WAIT_L2DB) &
                                       primary_l2db_done & (require_update_victim_after_l2db |
                                                            require_victim_pick_after_l2db)) |
                                      ((reqbuf_state == STATE_WAIT_EXT) &
                                       ext_wait_done & require_victim_pick_after_ext &
                                       ~require_compack_after_ext) |
                                      ((reqbuf_state == STATE_WAIT_AFB) &
                                       afb_done & require_victim_pick_after_afb) |
                                      ((reqbuf_state == STATE_COMPACK) &
                                       require_victim_pick_after_ext) |
                                      (reqbuf_state_tc1 & require_update_victim_after_tc1) |
                                      ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                       victim_l2db_done & (victim_require_update_after_l2db |
                                                           victim_require_victim_pick_after_l2db)) |
                                      ((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                       victim_afb_done & victim_require_update_after_afb) |
                                      ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                       victim_require_update_after_tc3) |
                                      (start_victim_no_flush & ~tagctl_slv_early_flush_tc4_i &
                                       ((reqbuf_type == `CA53_REQ_READONCE) |
                                        (reqbuf_type == `CA53_REQ_READNONE))));

  assign reqbuf_victimctl_valid_o = ((reqbuf_state == STATE_UPDATE_VICTIM) |
                                     (reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                     (reqbuf_victim_state == STATE_VICTIM_UPDATE) |
                                     (reqbuf_victim_state == STATE_VICTIM_PICK_REQ));

  assign reqbuf_victimctl_index_o = (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_READONCE) |
                                      (reqbuf_type == `CA53_REQ_READNONE)) ? reqbuf_addr1[16:6] : reqbuf_addr2[16:6]);

  assign reqbuf_victimctl_wr_o = ((reqbuf_state == STATE_UPDATE_VICTIM) |
                                  (reqbuf_victim_state == STATE_VICTIM_UPDATE));

  assign reqbuf_victimctl_age_o = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                   (((reqbuf_type == `CA53_REQ_READONCE) |
                                     (reqbuf_type == `CA53_REQ_READNONE)) ? reqbuf_l2_hit : reqbuf_victim_age));

  assign reqbuf_victimctl_nontemp_o = (((reqbuf_type == `CA53_REQ_READONCE) |
                                        (reqbuf_type == `CA53_REQ_READNONE)) &
                                       `CA53_MEM_TRANSIENT(reqbuf_attrs));

  assign reqbuf_victimctl_way_o = (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                    (reqbuf_type == `CA53_REQ_READONCE) |
                                    (reqbuf_type == `CA53_REQ_READNONE)) &
                                   reqbuf_l2_hit) ? reqbuf_l2_hit_way : reqbuf_l2_victim_way;

  //----------------------------------------------------------------------------
  //  CompAck requests and retries
  //----------------------------------------------------------------------------

  generate if (ACE) begin : g_ace

    assign reqbuf_compack_active_o = 1'b0;
    assign reqbuf_compack_valid_o = 1'b0;
    assign reqbuf_compack_tgtid_o = {7{1'b0}};
    assign reqbuf_compack_txnid_o = {8{1'b0}};
    assign reqbuf_static_pcredit_tc1_o = 1'b0;
    assign reqbuf_pcrdtype_tc1_o = 2'b00;
    assign reqbuf_dbid_en = 1'b0;
    assign reqbuf_rsp_comp_valid = 1'b0;
    assign reqbuf_read_comp_valid = 1'b0;
    assign reqbuf_retry_seen = 1'b0;
    assign reqbuf_retry_received_en = 1'b0;

    always @*
      ext_dbid_received = zero;

  end else begin : g_skyros
    reg [7:0]  reqbuf_dbid;
    reg [6:0]  reqbuf_tgtid;
    reg [1:0]  reqbuf_pcrdtype;
    reg        reqbuf_retry_received;
    wire       reqbuf_static_pcredit_tc1;
    wire [7:0] next_reqbuf_dbid;
    wire [6:0] next_reqbuf_tgtid;
    wire       next_reqbuf_retry_received;
    wire       reqbuf_rsp_dbid_valid;
    wire       next_ext_dbid_received;

    assign reqbuf_rsp_comp_valid = master_rsp_comp_valid_i & (master_rsp_txnid_i == {1'b0, REQBUF_ID[5:0]});

    assign reqbuf_read_comp_valid = reqbuf_rsp_comp_valid & ~(((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                                               (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                                               (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                                              (reqbuf_pass == PASS_ADDRMAINT_MASTER_W));

    assign reqbuf_dbid_en = ((master_early_dr_valid_i & (master_early_dr_id_i == REQBUF_ID[5:0])) |
                             reqbuf_rsp_comp_valid);

    assign next_reqbuf_dbid  = reqbuf_rsp_comp_valid ? master_rsp_dbid_i : master_early_dr_dbid_i;
    assign next_reqbuf_tgtid = reqbuf_rsp_comp_valid ? master_rsp_srcid_i : master_early_dr_srcid_i;

    always @(posedge clk_reqbuf)
    if (reqbuf_dbid_en) begin
      reqbuf_dbid  <= next_reqbuf_dbid;
      reqbuf_tgtid <= next_reqbuf_tgtid;
    end

    assign reqbuf_compack_active_o = ((reqbuf_state == STATE_COMPACK) |
                                      ((reqbuf_state == STATE_WAIT_EXT) &
                                       require_compack_after_ext &
                                       (all_ext_beats_returned &
                                        ~readreceipt_wait)) |
                                      ((reqbuf_state == STATE_WAIT_L2DB) &
                                       require_compack_after_l2db &
                                       primary_l2db_done) |
                                      ((reqbuf_state == STATE_RESP) &
                                       require_compack_after_resp));

    assign reqbuf_compack_valid_o = (reqbuf_state == STATE_COMPACK);
    assign reqbuf_compack_tgtid_o = reqbuf_tgtid;
    assign reqbuf_compack_txnid_o = reqbuf_dbid;

    assign reqbuf_static_pcredit_tc1 = (reqbuf_state_tc1 &
                                        (((reqbuf_type == `CA53_REQ_READNOSNOOP)   & (reqbuf_pass == PASS_READNOSNOOP_RETRY)) |
                                         ((reqbuf_type == `CA53_REQ_WRITENOSNOOP)  & (reqbuf_pass == PASS_WRITENOSNOOP_RETRY)) |
                                         ((reqbuf_type == `CA53_REQ_DVM)           & (reqbuf_pass == PASS_DVM_RETRY)) |
                                         (((reqbuf_type == `CA53_REQ_READONCE) |
                                           (reqbuf_type == `CA53_REQ_READNONE))    & (reqbuf_pass == PASS_READONCE_RETRY)) |
                                         ((reqbuf_type == `CA53_REQ_READSHARED)    & (reqbuf_pass == PASS_READSHARED_RETRY)) |
                                         ((reqbuf_type == `CA53_REQ_READUNIQUE)    & ((reqbuf_pass == PASS_READUNIQUE_HIT_RETRY) |
                                                                                      (reqbuf_pass == PASS_READUNIQUE_MISS_RETRY))) |
                                         ((reqbuf_type == `CA53_REQ_WRITEUNIQUE)   & ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) |
                                                                                      (reqbuf_pass == PASS_WRITEUNIQUE_MISS_RETRY))) |
                                         ((reqbuf_type == `CA53_REQ_CLEANUNIQUE)   & (reqbuf_pass == PASS_CLEANUNIQUE_RETRY)) |
                                         (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                           (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                           (reqbuf_type == `CA53_REQ_MAKEINVALID)) & (reqbuf_pass == PASS_ADDRMAINT_RETRY)) |
                                         ((reqbuf_type == `CA53_REQ_DMB) |
                                          (reqbuf_type == `CA53_REQ_DSB))          & (reqbuf_pass == PASS_BARRIER_RETRY)));

    assign reqbuf_static_pcredit_tc1_o = reqbuf_static_pcredit_tc1;

    always @(posedge clk_reqbuf)
    if (reqbuf_retry_i) begin
      reqbuf_pcrdtype <= reqbuf_retry_pcrdtype_i;
    end

    assign reqbuf_pcrdtype_tc1_o = {2{reqbuf_static_pcredit_tc1}} & reqbuf_pcrdtype;

    // If a retry is received before the reqbuf reaches the wait ext state,
    // then remember the retry until it can be acted upon.
    assign reqbuf_retry_received_en = (reqbuf_alloc_i | reqbuf_retry_i |
                                       (reqbuf_state == STATE_WAIT_EXT) |
                                       (reqbuf_state == STATE_WAIT_L2DB));

    assign next_reqbuf_retry_received = reqbuf_retry_i & ~((reqbuf_state == STATE_WAIT_EXT) |
                                                           (reqbuf_state == STATE_WAIT_L2DB));

    always @(posedge clk_reqbuf)
    if (reqbuf_retry_received_en) begin
      reqbuf_retry_received <= next_reqbuf_retry_received;
    end
    
    assign reqbuf_retry_seen = reqbuf_retry_received | reqbuf_retry_i;

    assign reqbuf_rsp_dbid_valid = master_rsp_dbid_valid_i & (master_rsp_txnid_i == {1'b0, REQBUF_ID[5:0]});

    assign next_ext_dbid_received = (reqbuf_rsp_dbid_valid | ext_dbid_received) & ~reqbuf_alloc_i;

    always @(posedge clk_reqbuf)
    if (reqbuf_en) begin
      ext_dbid_received <= next_ext_dbid_received;
    end

  end endgenerate


  //----------------------------------------------------------------------------
  //  L2DB control
  //----------------------------------------------------------------------------


  // L2DBs are allocated in tc1 for writes that need to recieve data from the
  // CPU. This allows the ID to be returned to the CPU as soon as possible.
  assign l2db_valid_tc1 = (reqbuf_state_tc1 &
                           ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                            (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                            (reqbuf_type == `CA53_REQ_DVM)) &
                           (reqbuf_pass == PASS_WRITE_L2DB));

  // All other L2DBs are allocated in tc1, but not assigned to the primary or
  // victim requests until after it is known which of the two are needed.
  assign l2db_valid_tc4 = (reqbuf_state == STATE_TC4) & (reqbuf_pass == PASS_READ_SERIALISE);


  // Record the L2DBs allocated to this request when tagctl has allocated them
  // and confirmed they are needed. If the request is then flushed due to a
  // hazard tagctl is responsible for releasing them, but if the initial tagctl
  // pass is successful then the reqbuf is responsible for the L2DB after that.
  assign primary_l2db_en = l2db_valid_tc1 | l2db_valid_tc4;

  assign next_primary_l2db = l2db_valid_tc1 ? tagctl_slv_l2db_tc1_i : tagctl_slv_l2db_tc4_i;

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    primary_l2db <= 4'b0000;
  end else if (primary_l2db_en) begin
    primary_l2db <= next_primary_l2db;
  end

  // Indicate when the primary L2DB is valid and might be returning a response
  // on the DR channel.
  assign reqbuf_l2db_primary_dr_valid_o = (((reqbuf_type == `CA53_REQ_READSHARED) |
                                            (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                            (reqbuf_type == `CA53_REQ_READONCE)) &
                                           ((reqbuf_state == STATE_WAIT_L2DB) |
                                            ((reqbuf_state == STATE_WAIT_AFB) &
                                             (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit))));

  // For requests that do an eviction from the primary state machine, we reuse
  // the L2DB storage to hold the master waddr instead.
  assign next_victim_l2db = ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                             (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                             (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                             (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                             (reqbuf_type == `CA53_REQ_MAKEINVALID)) ? master_afb_waddr_id_i :
                                                                       tagctl_slv_victim_l2db_tc4_i;

  // Cache maintenance ops must record the waddr used for an eviction so that
  // they can know when the eviction is complete.
  assign primary_master_ack = ((reqbuf_state == STATE_WAIT_AFB) &
                               ((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                  (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                  (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                 (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)) |
                                ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                 (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)) |
                                ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                 (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2))) &
                               ((master_afb0_ack_i & (reqbuf_afb == 3'b000)) |
                                (master_afb1_ack_i & (reqbuf_afb == 3'b001)) |
                                (master_afb2_ack_i & (reqbuf_afb == 3'b010)) |
                                (master_afb3_ack_i & (reqbuf_afb == 3'b011)) |
                                (master_afb4_ack_i & (reqbuf_afb == 3'b100)) |
                                (master_afb5_ack_i & (reqbuf_afb == 3'b101))));

  assign victim_l2db_en = l2db_valid_tc4 |  primary_master_ack;

  always @(posedge clk_reqbuf)
  if (victim_l2db_en) begin
    victim_l2db <= next_victim_l2db;
  end

  // Most transfers are done the cycle after we know there are no hazards, but
  // a few must be started earlier so that the L2DB is ready in time for the
  // data to arrive.

  assign reqbuf_l2db_primary_transfer_tc3 = ((((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                               ((reqbuf_type == `CA53_REQ_DVM) & (ACE == 0) & dvm_ext)) &
                                              (reqbuf_pass == PASS_WRITE_SERIALISE)) |
                                             (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                               (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                               (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                              (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)) |
                                             ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                              (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W)) |
                                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                              ((reqbuf_pass == PASS_WRITEUNIQUE_MISS) |
                                               (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) |
                                               (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2))));


  assign reqbuf_l2db_primary_transfer_tc4 = (((reqbuf_pass == PASS_READ_SERIALISE) &
                                              ((((reqbuf_type == `CA53_REQ_READSHARED) |
                                                 (reqbuf_type == `CA53_REQ_READUNIQUE)) & (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit)) |
                                               ((reqbuf_type == `CA53_REQ_READONCE)     & (reqbuf_l1_hit | reqbuf_l2_hit)) |
                                               ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & (reqbuf_l1_hit_requestor &
                                                                                          ~reqbuf_cluster_unique &
                                                                                          (reqbuf_l1_hit_other_cpus |
                                                                                           (reqbuf_l2_hit & reqbuf_l2_dirty)))) |
                                               (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                                 (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                                 (reqbuf_type == `CA53_REQ_MAKEINVALID)) & (reqbuf_l1_hit |
                                                                                            (reqbuf_l2_hit & reqbuf_l2_dirty))))) |
                                             ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                              (L2_CACHE[0] ? (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                               ((|reqbuf_l1_hit_cpus) ? ~reqbuf_l2db_full_err :
                                                                reqbuf_l2_hit ? (reqbuf_cluster_unique ? reqbuf_l2db_rmw :
                                                                                                         ~reqbuf_l2db_full_err) :
                                                                (`CA53_MEM_WBWA(reqbuf_attrs) ? ~reqbuf_l2db_full_err :
                                                                                                ((ACE == 0) | ~reqbuf_shareable)))) |
                                                              ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) &
                                                               ((|reqbuf_l1_hit_cpus) ? ~reqbuf_l2db_full_err :
                                                                reqbuf_l2_hit         ? reqbuf_l2db_rmw :
                                                                                        1'b0))) :
                                                             (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                               ~(|reqbuf_l1_hit_cpus ? (((ACE != 0) & ~reqbuf_cluster_unique) |
                                                                                        reqbuf_l2db_full_err) :
                                                                                       ((ACE != 0) & reqbuf_shareable))) |
                                                              ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) &
                                                               ~(|reqbuf_l1_hit_cpus & reqbuf_l2db_full_err))))));

  assign next_reqbuf_l2db_primary_transfer = ((l2db_valid_tc1 & ~tagctl_slv_flush_tc1_i) |
                                              ((reqbuf_state == STATE_TC3) & ~tagctl_slv_flush_tc3_i &
                                               ~tagctl_ecc_err_tc3_i &
                                               reqbuf_l2db_primary_transfer_tc3) |
                                              ((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i &
                                               reqbuf_l2db_primary_transfer_tc4) |
                                              ((reqbuf_state == STATE_WAIT_EXT) &
                                               all_ext_beats_returned & require_l2db_after_ext &
                                               ~require_compack_after_ext) |
                                              ((reqbuf_state == STATE_COMPACK) & reqbuf_compack_ready_i &
                                               require_compack_after_ext & require_l2db_after_ext) |
                                              (reqbuf_state_tc1 &
                                               ~tagctl_slv_flush_tc1_i &
                                               (reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                               (L2_CACHE != 0) & (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1)));


  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_primary_transfer <= 1'b0;
  end else begin
    reqbuf_l2db_primary_transfer <= next_reqbuf_l2db_primary_transfer;
  end

  assign reqbuf_l2db_primary_transfer_o = reqbuf_l2db_primary_transfer;

  assign reqbuf_l2db_primary_id_o = primary_l2db;

  // Slv to slv in some cases is actually L2DB to slv, but the behaviour is
  // identical if the L2DB already has the data.
  always @*
  case (reqbuf_type)
    `CA53_REQ_WRITENOSNOOP,
    `CA53_REQ_DVM: next_reqbuf_l2db_primary_transfer_type = (reqbuf_pass == PASS_WRITE_L2DB) ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                                               `CA53_L2DB_TRNSFR_L2DB_MASTER;
    `CA53_REQ_WRITEUNIQUE: begin
      case (reqbuf_pass)
        PASS_WRITE_L2DB:           next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_SLV_L2DB;
        PASS_WRITE_SERIALISE:      next_reqbuf_l2db_primary_transfer_type = (reqbuf_l1_hit &
                                                                             reqbuf_cluster_unique)          ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                            (reqbuf_l2_hit &
                                                                             reqbuf_cluster_unique)          ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                            (((L2_CACHE != 0) &
                                                                              `CA53_MEM_WBWA(reqbuf_attrs)) |
                                                                             reqbuf_l1_hit | reqbuf_l2_hit) ?  `CA53_L2DB_TRNSFR_MASTER_L2DB :
                                                                                                               `CA53_L2DB_TRNSFR_L2DB_MASTER;
        PASS_WRITEUNIQUE_N_UNIQUE: next_reqbuf_l2db_primary_transfer_type = reqbuf_l1_hit   ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                            (L2_CACHE != 0) ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                                              `CA53_L2DB_TRNSFR_L2DB_MASTER;
        PASS_WRITEUNIQUE_UNIQUE1:  next_reqbuf_l2db_primary_transfer_type = (L2_CACHE == 0)  ? `CA53_L2DB_TRNSFR_L2DB_MASTER :
                                                                            (reqbuf_l2_victim_valid &
                                                                             ~reqbuf_l2_hit) ? `CA53_L2DB_TRNSFR_RAM_SWAP :
                                                                                               `CA53_L2DB_TRNSFR_L2DB_RAM;
        PASS_WRITEUNIQUE_UNIQUE2:  next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_L2DB_MASTER;
        PASS_WRITEUNIQUE_MISS:     next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_L2DB_MASTER;
        default:                   next_reqbuf_l2db_primary_transfer_type = 3'bxxx;
      endcase
    end
    `CA53_REQ_CLEANSHARED,
    `CA53_REQ_CLEANINVALID,
    `CA53_REQ_MAKEINVALID: next_reqbuf_l2db_primary_transfer_type = (reqbuf_pass != PASS_READ_SERIALISE) ? `CA53_L2DB_TRNSFR_L2DB_MASTER :
                                                                    (reqbuf_l2_hit & reqbuf_l2_dirty)    ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                                                           `CA53_L2DB_TRNSFR_SLV_L2DB;
    `CA53_REQ_READONCE,
    `CA53_REQ_READSHARED:  next_reqbuf_l2db_primary_transfer_type = reqbuf_l2_hit ? `CA53_L2DB_TRNSFR_RAM_SLV :
                                                                                    `CA53_L2DB_TRNSFR_SLV_SLV;
    `CA53_REQ_READUNIQUE:  next_reqbuf_l2db_primary_transfer_type = (reqbuf_pass != PASS_READ_SERIALISE)      ? `CA53_L2DB_TRNSFR_SLV_SLV :
                                                                    (reqbuf_l2_hit &  reqbuf_cluster_unique)  ? `CA53_L2DB_TRNSFR_RAM_SLV :
                                                                    (reqbuf_l2_hit & ~reqbuf_cluster_unique)  ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                    (~reqbuf_l2_hit & ~reqbuf_cluster_unique) ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                                                                `CA53_L2DB_TRNSFR_SLV_SLV;
    `CA53_REQ_CLEANUNIQUE: next_reqbuf_l2db_primary_transfer_type = (reqbuf_pass != PASS_READ_SERIALISE) ? `CA53_L2DB_TRNSFR_L2DB_MASTER :
                                                                    (reqbuf_l2_hit & reqbuf_l2_dirty)    ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                                                           `CA53_L2DB_TRNSFR_SLV_L2DB;
    default:               next_reqbuf_l2db_primary_transfer_type = 3'bxxx;
  endcase

  always @(posedge clk_reqbuf)
  if (next_reqbuf_l2db_primary_transfer) begin
    reqbuf_l2db_primary_transfer_type <= next_reqbuf_l2db_primary_transfer_type;
  end

  assign reqbuf_l2db_primary_transfer_type_o = reqbuf_l2db_primary_transfer_type;


  assign primary_slv_transfer_info = {(reqbuf_type == `CA53_REQ_READUNIQUE),
                                      ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                       (reqbuf_type == `CA53_REQ_WRITEUNIQUE)) &
                                      (reqbuf_pass == PASS_WRITE_L2DB),
                                      {3{1'b0}},
                                      reqbuf_biu_id,
                                      (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                        (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                        (reqbuf_type == `CA53_REQ_DVM)) &
                                       (reqbuf_pass == PASS_WRITE_L2DB)) ? REQBUF_ID[5:0] :
                                                                           {1'b0, reqbuf_snoop_data_cpu, 3'b000},
                                      reqbuf_addr1[5:4],
                                      REQBUF_ID[5:0]};

  assign primary_master_transfer_info = {(reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? 
                                         ((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2) ? reqbuf_victim_cu : 1'b1) :
                                         reqbuf_cluster_unique,
                                         (reqbuf_type == `CA53_REQ_WRITENOSNOOP) & reqbuf_lock,
                                         reqbuf_prot[0],
                                         (reqbuf_type != `CA53_REQ_DVM),
                                         1'b0,
                                         ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                          (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)) ? victim_opcode :
                                         ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                          (ACE == 0) &
                                          ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                           (reqbuf_pass == PASS_WRITEUNIQUE_MISS_RETRY) |
                                           (reqbuf_pass == PASS_WRITEUNIQUE_MISS)))  ? `CA53_DATA_OPCODE_WRITEUNIQUE :
                                         ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                          (reqbuf_type == `CA53_REQ_DVM))            ? `CA53_DATA_OPCODE_WRITENOSNOOP :
                                         ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                          (reqbuf_type == `CA53_REQ_CLEANUNIQUE))    ? `CA53_DATA_OPCODE_WRITECLEAN :
                                                                                       `CA53_DATA_OPCODE_WRITEBACK,
                                         ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                          (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                          (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                          (reqbuf_type == `CA53_REQ_MAKEINVALID) |
                                          ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                           (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2))) ? victim_attrs :
                                         {reqbuf_attrs[7:2], reqbuf_shareability},
                                         reqbuf_addr1[5:4],
                                         (ACE != 0) ? {REQBUF_ID[5:3], reqbuf_afb} : REQBUF_ID[5:0]};

  assign primary_ram_transfer_info = {(reqbuf_type == `CA53_REQ_READUNIQUE),
                                      reqbuf_l2_hit ? reqbuf_l2_hit_way : reqbuf_l2_victim_way,
                                      (reqbuf_pass == PASS_READ_SERIALISE) ? reqbuf_biu_id : reqbuf_addr1[16:12],
                                      reqbuf_addr1[11:4],
                                      REQBUF_ID[5:0]};

  always @*
  case (reqbuf_l2db_primary_transfer_type)
    `CA53_L2DB_TRNSFR_SLV_L2DB,
    `CA53_L2DB_TRNSFR_SLV_SLV:     reqbuf_l2db_primary_transfer_info = primary_slv_transfer_info;
    `CA53_L2DB_TRNSFR_MASTER_L2DB: reqbuf_l2db_primary_transfer_info = {{10{1'b0}},
                                                                        REQBUF_ID[5:0], reqbuf_addr1[5:4], 6'h00};
    `CA53_L2DB_TRNSFR_L2DB_MASTER: reqbuf_l2db_primary_transfer_info = primary_master_transfer_info;
    `CA53_L2DB_TRNSFR_L2DB_RAM,
    `CA53_L2DB_TRNSFR_RAM_SLV,
    `CA53_L2DB_TRNSFR_RAM_SWAP,
    `CA53_L2DB_TRNSFR_RAM_L2DB:    reqbuf_l2db_primary_transfer_info = primary_ram_transfer_info;
    default:                       reqbuf_l2db_primary_transfer_info = {24{1'bx}};
  endcase

  assign reqbuf_l2db_primary_transfer_info_o = reqbuf_l2db_primary_transfer_info;


  assign reqbuf_l2db_primary_release_o = (((reqbuf_state == STATE_WAIT_L2DB) &
                                           primary_l2db_done &
                                           ((reqbuf_type == `CA53_REQ_READSHARED) |
                                            (reqbuf_type == `CA53_REQ_READONCE) |
                                            ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                             (((reqbuf_pass == PASS_READ_SERIALISE) & reqbuf_cluster_unique) |
                                              (reqbuf_pass == PASS_READUNIQUE_HIT1) |
                                              (reqbuf_pass == PASS_READUNIQUE_HIT_RETRY))) |
                                            (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                              (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                              (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                             (reqbuf_pass == PASS_READ_SERIALISE) &
                                             (reqbuf_l1_hit & ~reqbuf_l1_dirty) &
                                             ~(reqbuf_l2_hit & reqbuf_l2_dirty)) |
                                            ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                             (reqbuf_pass == PASS_READ_SERIALISE) &
                                             (reqbuf_l1_hit_other_cpus & ~reqbuf_l1_dirty) &
                                             ~(reqbuf_l2_hit & reqbuf_l2_dirty)) |
                                            ((reqbuf_type == `CA53_REQ_DVM) &
                                             ((((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                                (reqbuf_pass == PASS_DVM_RETRY)) & (ACE == 0)) |
                                              ((reqbuf_pass == PASS_WRITE_L2DB) &
                                               ((ACE != 0) | ~dvm_ext)))))) |
                                          ((reqbuf_state == STATE_WAIT_AFB) &
                                           afb_done &
                                           (((reqbuf_type == `CA53_REQ_CLEANSETWAY) & set_way_op_l2 &
                                             reqbuf_l2_victim_valid & ~reqbuf_victim_dirty) |
                                            ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                             (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2) &
                                             ~afb_primary_write))) |
                                          ((reqbuf_state == STATE_WAIT_EXT) &
                                           all_ext_beats_returned &
                                           (reqbuf_type == `CA53_REQ_READUNIQUE) &
                                           (reqbuf_l1_hit_other_cpus | reqbuf_l2_hit) &
                                           ext_snoop_invalidated));


  assign reqbuf_l2db_victim_transfer_tc3 = (((((reqbuf_type == `CA53_REQ_READSHARED) |
                                               (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                               set_way_op_l1) &
                                              ((reqbuf_victim_pass == PASS_VICTIM_WRITE) |
                                               ((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) & ~reqbuf_l2_hit_tc3)) &
                                              ~victim_require_idle_after_tc3) |
                                             ((reqbuf_victim_pass == PASS_VICTIM_WRITE) &
                                              ((reqbuf_type == `CA53_REQ_READONCE) |
                                               (reqbuf_type == `CA53_REQ_READNONE) |
                                               set_way_op_l2) &
                                              reqbuf_l2_victim_valid & (reqbuf_victim_dirty |
                                                                        ~next_reqbuf_l1_victim_hit)) |
                                             ((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                              tagctl_l2_victim_valid_tc3_i)) &
                                            ~tagctl_ecc_err_tc3_i);

  assign reqbuf_l2db_victim_transfer_tc4 = ((reqbuf_pass == PASS_READ_SERIALISE) &
                                            ((set_way_op_l2 & reqbuf_l2_victim_valid &
                                              ((reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                               reqbuf_victim_dirty)) |
                                             (((reqbuf_type == `CA53_REQ_READSHARED) |
                                               (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                               (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                               (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                               (reqbuf_type == `CA53_REQ_ECCCLEAN)) & reqbuf_l1_hit_requestor)));

  assign next_reqbuf_l2db_victim_transfer = (((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                              reqbuf_l2db_victim_transfer_tc3) |
                                             ((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i &
                                              reqbuf_l2db_victim_transfer_tc4));


  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_victim_transfer <= 1'b0;
  end else begin
    reqbuf_l2db_victim_transfer <= next_reqbuf_l2db_victim_transfer;
  end

  assign reqbuf_l2db_victim_transfer_o = reqbuf_l2db_victim_transfer;

  assign reqbuf_l2db_victim_id_o = victim_l2db;

  always @*
  case (reqbuf_victim_pass)
    PASS_VICTIM_INITIAL: next_reqbuf_l2db_victim_transfer_type = ((reqbuf_type == `CA53_REQ_READONCE) |
                                                                  (reqbuf_type == `CA53_REQ_READNONE) |
                                                                  set_way_op_l2) ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                                   `CA53_L2DB_TRNSFR_SLV_L2DB;
    PASS_VICTIM_WRITE:   next_reqbuf_l2db_victim_transfer_type = `CA53_L2DB_TRNSFR_L2DB_MASTER;
    PASS_VICTIM_READ:    next_reqbuf_l2db_victim_transfer_type = `CA53_L2DB_TRNSFR_RAM_L2DB;
    PASS_VICTIM_LOOKUP:  next_reqbuf_l2db_victim_transfer_type = ((reqbuf_victim_state == STATE_VICTIM_TC3) ?
                                                                  tagctl_l2_victim_valid_tc3_i :
                                                                  reqbuf_l2_victim_valid) ? `CA53_L2DB_TRNSFR_RAM_SWAP :
                                                                                            `CA53_L2DB_TRNSFR_L2DB_RAM;
    default:             next_reqbuf_l2db_victim_transfer_type = {3{1'bx}};
  endcase


  always @(posedge clk_reqbuf)
  if (next_reqbuf_l2db_victim_transfer) begin
    reqbuf_l2db_victim_transfer_type <= next_reqbuf_l2db_victim_transfer_type;
  end

  assign reqbuf_l2db_victim_transfer_type_o = reqbuf_l2db_victim_transfer_type;

  assign victim_opcode = (((reqbuf_type == `CA53_REQ_CLEANSETWAY) &
                           ((L2_CACHE == 0) | set_way_op_l2))              ? `CA53_DATA_OPCODE_WRITECLEAN :
                          ((reqbuf_victim_dirty &  reqbuf_l1_victim_hit)   ? `CA53_DATA_OPCODE_WRITECLEAN :
                           (reqbuf_victim_dirty & ~reqbuf_l1_victim_hit)   ? `CA53_DATA_OPCODE_WRITEBACK :
                           (reqbuf_victim_cu &
                            ~((reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                              (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                              (reqbuf_type == `CA53_REQ_ECCCLEAN)) &
                            cpuslv_enable_writeevict_i)                    ? `CA53_DATA_OPCODE_EVICTDATA :
                                                                             `CA53_DATA_OPCODE_EVICT));

  assign victim_slv_transfer_info = {10'h000, REQBUF_ID[5:0], reqbuf_addr2[5:4], 6'b000000};

  assign victim_master_transfer_info = {reqbuf_victim_cu, 2'b01, 1'b1, 1'b0, victim_opcode,
                                        victim_attrs, reqbuf_addr2[5:4], (ACE != 0) ? {REQBUF_ID[5:3], reqbuf_victim_afb} : REQBUF_ID[5:0]};

  assign victim_ram_transfer_info = {1'b0, reqbuf_l2_victim_way, reqbuf_addr2[16:4], REQBUF_ID[5:0]};

  always @*
  case (reqbuf_l2db_victim_transfer_type)
    `CA53_L2DB_TRNSFR_SLV_L2DB,
    `CA53_L2DB_TRNSFR_SLV_SLV:     reqbuf_l2db_victim_transfer_info = victim_slv_transfer_info;
    `CA53_L2DB_TRNSFR_MASTER_L2DB,
    `CA53_L2DB_TRNSFR_L2DB_MASTER: reqbuf_l2db_victim_transfer_info = victim_master_transfer_info;
    `CA53_L2DB_TRNSFR_L2DB_RAM,
    `CA53_L2DB_TRNSFR_RAM_SLV,
    `CA53_L2DB_TRNSFR_RAM_SWAP,
    `CA53_L2DB_TRNSFR_RAM_L2DB:    reqbuf_l2db_victim_transfer_info = victim_ram_transfer_info;
    default:                       reqbuf_l2db_victim_transfer_info = {24{1'bx}};
  endcase

  assign reqbuf_l2db_victim_transfer_info_o = reqbuf_l2db_victim_transfer_info;

  assign reqbuf_l2db_victim_release_o = (((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                          victim_afb_done &
                                          (((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) & reqbuf_l2_victim_hit) |
                                           ((reqbuf_victim_pass == PASS_VICTIM_WRITE) & ~afb_victim_write))) |
                                         ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                          victim_l2db_done & (reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                          ~victim_require_tagctl_after_l2db &
                                          ~victim_require_victim_pick_after_l2db) |
                                         ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                          (((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                            ~tagctl_l2_victim_valid_tc3_i) |
                                           ((set_way_op_l1 & (L2_CACHE == 0) &
                                             ((|reqbuf_l1_hit_cpus_tc3 |
                                               (reqbuf_type == `CA53_REQ_CLEANSETWAY)) &
                                              ~reqbuf_victim_dirty))))));

  assign reqbuf_l2db_victim_release_tc3_o = (reqbuf_victim_state == STATE_VICTIM_TC3);

  // The L2DB is reporting that it has completed its transfer.
  assign l2dbs_slv_done = {l2db10_slv_done_i,
                           l2db9_slv_done_i,
                           l2db8_slv_done_i,
                           l2db7_slv_done_i,
                           l2db6_slv_done_i,
                           l2db5_slv_done_i,
                           l2db4_slv_done_i,
                           l2db3_slv_done_i,
                           l2db2_slv_done_i,
                           l2db1_slv_done_i,
                           l2db0_slv_done_i};

  // Let the state machines know when they can move on to the next state if
  // they are waiting for an L2DB.
  assign primary_l2db_done = (|(l2dbs_slv_done & (11'b0000_0000_001 << primary_l2db)) &
                              ~reqbuf_l2db_primary_transfer);
  assign victim_l2db_done  = (|(l2dbs_slv_done & (11'b0000_0000_001 << victim_l2db)) &
                              ~reqbuf_l2db_victim_transfer);

  // Let ramctl know if an L2DB might be making a request in the following cycle.
  assign reqbuf_ramctl_active_o = ((reqbuf_l2db_primary_transfer &
                                    ((reqbuf_l2db_primary_transfer_type == `CA53_L2DB_TRNSFR_RAM_SLV) |
                                     (reqbuf_l2db_primary_transfer_type == `CA53_L2DB_TRNSFR_RAM_L2DB) |
                                     (reqbuf_l2db_primary_transfer_type == `CA53_L2DB_TRNSFR_RAM_SWAP) |
                                     (reqbuf_l2db_primary_transfer_type == `CA53_L2DB_TRNSFR_L2DB_RAM))) |
                                   (reqbuf_l2db_victim_transfer &
                                    ((reqbuf_l2db_victim_transfer_type == `CA53_L2DB_TRNSFR_RAM_SLV) |
                                     (reqbuf_l2db_victim_transfer_type == `CA53_L2DB_TRNSFR_RAM_L2DB) |
                                     (reqbuf_l2db_victim_transfer_type == `CA53_L2DB_TRNSFR_RAM_SWAP) |
                                     (reqbuf_l2db_victim_transfer_type == `CA53_L2DB_TRNSFR_L2DB_RAM))));

  //----------------------------------------------------------------------------
  //  CPU responses
  //----------------------------------------------------------------------------

  // A new response is ready to be sent, to return the L2DB ID for writes.
  assign new_rr_valid = l2db_valid_tc1 | (reqbuf_state == STATE_RESP);

  // The flush is too late to factor it into the request, so just cancel the
  // request if we do get arbitrated.
  assign reqbuf_rr_cancel = l2db_valid_tc1 & tagctl_slv_flush_tc1_i;
  assign reqbuf_rr_cancel_o = reqbuf_rr_cancel;

  // If the RR channel is not available this cycle then remember the request
  // until it can be sent.
  assign next_rr_valid_pending = ((new_rr_valid & ~reqbuf_rr_cancel) |
                                  rr_valid_pending) & ~reqbuf_rr_ready_i;

  always @(posedge clk_reqbuf or negedge reset_n)
  if (~reset_n) begin
    rr_valid_pending <= 1'b0;
  end else begin
    rr_valid_pending <= next_rr_valid_pending;
  end

  assign reqbuf_rr_valid_o = new_rr_valid | rr_valid_pending;

  assign reqbuf_rr_l2db_id_o = reqbuf_state_tc0_tc1 ? tagctl_slv_l2db_tc1_i : primary_l2db;

  assign cleanunique_resp = (((~reqbuf_l1_hit_requestor & (reqbuf_pass != PASS_CLEANUNIQUE_CHECK)) |
                              ext_snoop_invalidated) ? (reqbuf_lock ? `CA53_ACE_RESP_OKAY : `CA53_ACE_RESP_EXOKAY) :
                             ext_beats_received      ? ext_beats_resp :
                                                       (reqbuf_lock ? `CA53_ACE_RESP_EXOKAY : `CA53_ACE_RESP_OKAY));

  assign reqbuf_rr_resp_o = (reqbuf_type == `CA53_REQ_CLEANUNIQUE) ? cleanunique_resp : ext_beats_resp;

  assign reqbuf_dsb_resp_o = (reqbuf_state == STATE_RESP) & (reqbuf_type == `CA53_REQ_DSB);

  assign reqbuf_dmb_resp_o = (reqbuf_state == STATE_RESP) & (reqbuf_type == `CA53_REQ_DMB);

  assign reqbuf_sample_waddrs = (reqbuf_state == STATE_WAIT_REQBUFS) & ~|(reqbufs_older_i & reqbufs_busy_i);

  assign reqbuf_sample_waddrs_o = reqbuf_sample_waddrs;
  assign reqbuf_sample_waddrs_dsb_o = reqbuf_sample_waddrs & (reqbuf_type == `CA53_REQ_DSB);

  // Count how many beats of read response have been received, so that we can
  // tell when we have seen all of them.
  assign receiving_ext_beat = ((master_cpuslv_dr_valid_i & cpuslv_master_dr_ready_i &
                                (master_dr_id_i == REQBUF_ID[5:0])) |
                               reqbuf_read_comp_valid);


  // Store when we have received an external beat. This must be done on the
  // early dr, so that it is accurate for hazarding snoops even if the dr
  // channel is stalled.
  assign next_ext_beats_received =  ((ext_beats_received |
                                      (master_early_dr_valid_i & early_dr_match) |
                                      reqbuf_read_comp_valid) &
                                     ~reqbuf_alloc_i);

  // When a ReadUnique has data from L1 or L2 in an L2DB but is doing an
  // external request to get unique access to the line, we need to record if
  // an external snoop has invalidated our copy of the line, so we do not use
  // that data anymore.
  assign next_ext_snoop_invalidated = ((ext_snoop_invalidated |
                                        reqbuf_cleanunique_ecc_hz_tc1 |
                                        (~hazard_snoops &
                                         (((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                           tagctl_slv_l2db_invalidated_tc4_i &
                                           (tagctl_slv_l2db_tc4_i == primary_l2db)) |
                                          (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                            (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                            (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                            (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                           tagctl_slv_snp_hz_tc4_i &
                                           (tagctl_slv_snp_hz_id_tc4_i == REQBUF_ID[4:0]))))) &
                                       ~reqbuf_alloc_i);

  assign next_ext_snoop_cleaned = ((ext_snoop_cleaned |
                                    (~hazard_snoops &
                                     ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                      tagctl_slv_l2db_cleaned_tc4_i &
                                      (tagctl_slv_l2db_tc4_i == primary_l2db)))) &
                                   ~reqbuf_alloc_i);

  always @(posedge clk_reqbuf)
  if (reqbuf_en) begin
    ext_beats_received    <= next_ext_beats_received;
    ext_snoop_invalidated <= next_ext_snoop_invalidated;
    ext_snoop_cleaned     <= next_ext_snoop_cleaned;
  end

  // Suppress some responses from the master, for cases when the response has
  // either been returned already, or more work needs doing before the response
  // can be returned.
  // Barriers need supressing in WAIT_AFB because the read part may have been
  // sent and returned before the write part has been sent.
  assign reqbuf_suppress_early_dr = ((((reqbuf_state == STATE_WAIT_AFB) |
                                       (reqbuf_state == STATE_WAIT_EXT)) &
                                      (((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                        ((reqbuf_pass == PASS_READUNIQUE_HIT1) |
                                         (reqbuf_pass == PASS_READUNIQUE_HIT_RETRY)) &
                                        ~ext_snoop_invalidated) |
                                       (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                       (reqbuf_type == `CA53_REQ_MAKEINVALID))) |
                                     ((reqbuf_state != STATE_IDLE) &
                                      (reqbuf_state != STATE_INITIAL) &
                                      (reqbuf_state != STATE_WAIT_INITIAL) &
                                      ((reqbuf_type == `CA53_REQ_READNONE) |
                                       (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_DVM))));
                                      
  assign reqbuf_suppress_barrier_dr = (((reqbuf_state == STATE_WAIT_AFB) |
                                        (reqbuf_state == STATE_WAIT_EXT)) &
                                       ((reqbuf_type == `CA53_REQ_DMB) |
                                        (reqbuf_type == `CA53_REQ_DSB)));

  assign reqbuf_suppress_dr = ((reqbuf_suppress_early_dr &
                                (master_early_dr_id_i == REQBUF_ID[5:0])) |
                               (reqbuf_suppress_barrier_dr &
                                (master_early_dr_id_i[4:3] == REQBUF_ID[4:3]) &
                                master_early_dr_barrier_i));

  assign reqbuf_suppress_dr_o = reqbuf_suppress_dr;

  assign reqbuf_early_dr_ready_o = reqbuf_suppress_early_dr;

  assign reqbuf_suppressed_dr = master_early_dr_valid_i & reqbuf_suppress_dr;

  // Calculate the read response for data being returned that does not come directly from the master.
  assign reqbuf_dr_resp_o = ({4{(reqbuf_type == `CA53_REQ_READSHARED) |
                                (reqbuf_type == `CA53_REQ_READUNIQUE)}} &
                             {(reqbuf_type == `CA53_REQ_READSHARED) &
                              (~reqbuf_cluster_unique |
                               ((CPU_CACHE_PROTECTION != 0) & |(reqbuf_l1_hit_cpus &
                                                                ~reqbuf_requestor_cpu &
                                                                ~{reqbuf_snoop_data_cpu == 2'b11,
                                                                  reqbuf_snoop_data_cpu == 2'b10,
                                                                  reqbuf_snoop_data_cpu == 2'b01,
                                                                  reqbuf_snoop_data_cpu == 2'b00})) |
                               (reqbuf_l1_hit_other_cpus & ~reqbuf_l1_migratory)),
                              (((reqbuf_l1_hit_other_cpus & reqbuf_l1_dirty) |
                                (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                               ~ext_snoop_cleaned) |
                              ext_beats_dirty,
                              reqbuf_lock ? `CA53_ACE_RESP_EXOKAY : `CA53_ACE_RESP_OKAY});

  // Record what response the external read got. If different beats get
  // different responses, then we take the 'strongest' of the responses. DECERR
  // takes priority over SLVERR, which takes priority over OKAY or EXOKAY. If
  // the access is an exclusive, then a failure (OKAY) takes priority over
  // success (EXOKAY), but for non-exclusives it is the other way round.

  assign master_ext_resp = reqbuf_read_comp_valid ? master_rsp_resp_i : master_dr_resp_i;

  assign ext_decerr = ((barrier_db_resp & (master_db_resp_i == `CA53_ACE_RESP_DECERR)) |
                       (receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_DECERR)) |
                       (reqbuf_suppressed_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_DECERR)));

  assign ext_slverr = ((barrier_db_resp & (master_db_resp_i == `CA53_ACE_RESP_SLVERR)) |
                       (receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_SLVERR)) |
                       (reqbuf_suppressed_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_SLVERR)));

  assign ext_okayerr = (reqbuf_lock &
                        ((receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_OKAY)) |
                         (reqbuf_suppressed_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_OKAY))) &
                        ~ext_beats_resp[1]);

  assign ext_exokayerr = ((barrier_db_resp & (master_db_resp_i == `CA53_ACE_RESP_EXOKAY)) |
                          (~(reqbuf_lock & ext_beats_received) &
                           ((receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_EXOKAY)) |
                            (reqbuf_suppressed_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_EXOKAY))) &
                           ~ext_beats_resp[1]));

  assign next_ext_beats_resp = (reqbuf_alloc_i ? `CA53_ACE_RESP_OKAY :
                                ext_decerr     ? `CA53_ACE_RESP_DECERR :
                                ext_slverr     ? {1'b1, &ext_beats_resp} :
                                ext_okayerr    ? `CA53_ACE_RESP_OKAY :
                                ext_exokayerr  ? `CA53_ACE_RESP_EXOKAY :
                                                 ext_beats_resp);

  assign next_ext_beats_shared = (ext_beats_shared |
                                  (receiving_ext_beat & master_ext_resp[3]) |
                                  (reqbuf_suppressed_dr & master_early_dr_resp_i[3])) & ~reqbuf_alloc_i;

  assign next_ext_beats_dirty = (ext_beats_dirty |
                                 (receiving_ext_beat & master_ext_resp[2]) |
                                 (reqbuf_suppressed_dr & master_early_dr_resp_i[2])) & ~reqbuf_alloc_i;

  assign reqbuf_ext_en = reqbuf_alloc_i | receiving_ext_beat | reqbuf_suppressed_dr;

  always @(posedge clk_reqbuf)
  if (reqbuf_ext_en) begin
    ext_beats_resp     <= next_ext_beats_resp;
    ext_beats_shared   <= next_ext_beats_shared;
    ext_beats_dirty    <= next_ext_beats_dirty;
  end

  // The master cannot tell which reqbuf a barrier write response is destined
  // for, but as there can only be one outstanding barrier per cpuslv, the
  // reqbuf knows if the response if for it or not.
  assign barrier_db_resp = (((reqbuf_type == `CA53_REQ_DMB) |
                             (reqbuf_type == `CA53_REQ_DSB)) &
                            ((reqbuf_state == STATE_WAIT_AFB) |
                             (reqbuf_state == STATE_WAIT_EXT)) &
                            master_cpuslv_barrier_db_valid_i);

  // Count how many beats of read response have been returned to the CPU, so
  // that we can tell when we have sent all of them.
  // Once all of them have been seen, then that ID can be reused, and so any
  // further beats with the same ID must be for another transaction.
  assign returning_ext_dr_beat = ((((scu_dr_valid_i &
                                     (scu_dr_id_i == reqbuf_biu_id)) |
                                    (scu_rr_valid_i &
                                     (scu_rr_id_i == reqbuf_biu_id))) &
                                   ~(all_ext_beats_returned |
                                     (reqbuf_type == `CA53_REQ_READNONE) |
                                     (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                     (reqbuf_type == `CA53_REQ_DVM))) |
                                  reqbuf_suppressed_dr |
                                  reqbuf_read_comp_valid);

  assign returning_ext_beat = returning_ext_dr_beat | barrier_db_resp;

  // Only a barrier can receive a read and write response on the same cycle.
  assign next_ext_beats_returned = (reqbuf_alloc_i    ? 3'b000 :
                                    (reqbuf_suppressed_dr &
                                     barrier_db_resp) ? (ext_beats_returned + 3'b010) :
                                                        (ext_beats_returned + 3'b001));

  assign reqbuf_ext_ret_en = reqbuf_alloc_i | (reqbuf_busy & returning_ext_beat);

  always @(posedge clk_reqbuf)
  if (reqbuf_ext_ret_en) begin
    ext_beats_returned <= next_ext_beats_returned;
  end

  // The length of some requests on ACE is not the same as the beat of response that are returned.
  assign reqbuf_real_len = (((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                             (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                             (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                             (reqbuf_type == `CA53_REQ_MAKEINVALID)) ? 2'b00 :
                            ((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                             (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                             (reqbuf_type == `CA53_REQ_ECCCLEAN)) ? 2'b11 :
                           ((((reqbuf_type == `CA53_REQ_DMB) |
                              (reqbuf_type == `CA53_REQ_DSB)) & (ACE != 0)) |
                            ((reqbuf_type == `CA53_REQ_DVM) &
                             ~reqbuf_initial &
                             reqbuf_addr2[0])) ? 2'b01 : reqbuf_len);

  assign all_ext_beats_returned = (ext_beats_returned > {1'b0, reqbuf_real_len});

  generate if (ACE) begin : g_receipt_ace

    assign readreceipt_wait = 1'b0;

  end else begin : g_receipt_skyros

    assign next_ext_readreceipt_received = ((ext_readreceipt_received |
                                             (master_rsp_readreceipt_valid_i & (master_rsp_txnid_i == {1'b0, REQBUF_ID[5:0]}))) &
                                            ~reqbuf_alloc_i);

    always @(posedge clk_reqbuf)
    if (reqbuf_en) begin
      ext_readreceipt_received <= next_ext_readreceipt_received;
    end

    assign readreceipt_wait = ((reqbuf_type == `CA53_REQ_READNOSNOOP) &
                               ~`CA53_MEM_REORDERABLE(reqbuf_attrs) &
                               ~ext_readreceipt_received);
  end endgenerate

  assign ext_wait_done = ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                          ((ACE == 0) &
                           (reqbuf_type == `CA53_REQ_DVM))) ? ext_beats_received :
                                                              (all_ext_beats_returned &
                                                               ~master_cpuslv_l2_waiting_i &
                                                               ~readreceipt_wait);

  // Indicate if this is an exclusive write, that must return a write response to the CPU.
  assign reqbuf_ext_strex_o = (reqbuf_type == `CA53_REQ_WRITENOSNOOP) & reqbuf_lock;

  // Transactions that allocate into L2 and perform an external read must
  // report an abort if the read got an error which causes dirty data to be lost.
  assign reqbuf_ext_abort = (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                              (((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) &
                                (reqbuf_state == STATE_WAIT_AFB) &
                                afb_done) |
                               (((reqbuf_pass == PASS_WRITEUNIQUE_MISS) |
                                 (reqbuf_pass == PASS_WRITEUNIQUE_MISS_RETRY) |
                                 ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                  ~|reqbuf_l1_hit_cpus & ~reqbuf_l2_hit &
                                  ~(`CA53_MEM_WBWA(reqbuf_attrs) & (L2_CACHE != 0)) &
                                  ((ACE == 0) | ~reqbuf_shareable))) &
                                (reqbuf_state == STATE_WAIT_L2DB) &
                                primary_l2db_done))) |
                             ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) &
                              (ACE == 0) &
                              ~reqbuf_lock &
                              ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                               (reqbuf_pass == PASS_WRITENOSNOOP_RETRY)) &
                              (reqbuf_state == STATE_WAIT_L2DB) &
                              primary_l2db_done) |
                             (((reqbuf_type == `CA53_REQ_READONCE) |
                               (reqbuf_type == `CA53_REQ_READNONE)) &
                              (ACE != 0) &
                              (reqbuf_pass == PASS_READONCE_MISS) &
                              reqbuf_state_tc1 &
                              ~tagctl_slv_flush_tc1_i &
                              ext_beats_dirty));

  assign reqbuf_ext_decerr_o = reqbuf_ext_abort & (ext_beats_resp == `CA53_ACE_RESP_DECERR);
  assign reqbuf_ext_slverr_o = reqbuf_ext_abort & (ext_beats_resp == `CA53_ACE_RESP_SLVERR);

  //----------------------------------------------------------------------------
  //  Hazarding
  //----------------------------------------------------------------------------


  // The master sends details of what read data/response has just arrived.
  assign early_dr_match = (master_early_dr_id_i == REQBUF_ID[5:0]);

  // Return information to the master about whether and where this data should
  // be allocated into the L2 cache.
  assign reqbuf_early_dr_l2_o = (early_dr_match &
                                 (L2_CACHE != 0) &
                                 (((reqbuf_type == `CA53_REQ_READONCE) &
                                   `CA53_MEM_WBRA(reqbuf_attrs)) |
                                  (reqbuf_type == `CA53_REQ_READNONE)));
  assign reqbuf_early_dr_index_o = {11{early_dr_match}} & reqbuf_addr1[16:6];
  assign reqbuf_early_dr_way_o = {4{early_dr_match}} & reqbuf_l2_victim_way;

  // If the L2 RAMs have not been read for the eviction yet, then we must
  // prevent overwriting the data with the newly allocated data.
  assign reqbuf_delay_allocation = ((L2_CACHE != 0) &
                                    (((reqbuf_type == `CA53_REQ_READONCE) &
                                      `CA53_MEM_WBRA(reqbuf_attrs)) |
                                     (reqbuf_type == `CA53_REQ_READNONE)) &
                                    (reqbuf_victim_state != STATE_VICTIM_IDLE) &
                                    ((reqbuf_victim_pass == PASS_VICTIM_INITIAL) |
                                     (reqbuf_victim_pass == PASS_VICTIM_READ)));

  assign reqbuf_delay_allocation_o = reqbuf_delay_allocation;

  // For coherent request types, snoops must be hazarded from the point this
  // request is serialised, until an external request is made. Once the last
  // beat is received (on ACE) we must start hazarding again, although we
  // actually start hazarding on the first beat for simplicity.
  assign next_hazard_snoops = ((reqbuf_alloc_i |
                                (reqbuf_hz_addr & (hazard_snoops |
                                                   (ext_beats_received & ~((ACE == 0) &
                                                                           (reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                                                           ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) |
                                                                            (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) |
                                                                            (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)))) |
                                                   (master_early_dr_valid_i & early_dr_match) |
                                                   ((ACE == 0) &
                                                    (reqbuf_state == STATE_WAIT_L2DB) &
                                                    primary_l2db_done &
                                                    ((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                                       (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                                      (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)) |
                                                     ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                                      (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W))))))) &
                               ~(reqbuf_state_tc0_tc1 &
                                 (((reqbuf_type == `CA53_REQ_READUNIQUE) &
                                   ((reqbuf_pass == PASS_READUNIQUE_HIT1) |
                                    (reqbuf_pass == PASS_READUNIQUE_HIT_RETRY))) |
                                  ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                   ((reqbuf_pass == PASS_CLEANUNIQUE_MASTER_R) |
                                    (reqbuf_pass == PASS_CLEANUNIQUE_RETRY))) |
                                  (((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                    (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                    (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                   ((reqbuf_pass == PASS_ADDRMAINT_MASTER_R) |
                                    (reqbuf_pass == PASS_ADDRMAINT_RETRY))) |
                                  ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                   (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)))) &
                               ~(((reqbuf_state == STATE_WAIT_AFB) &
                                  ~ext_beats_received &
                                  (((afb_done |
                                     ((reqbuf_victim_state != STATE_VICTIM_WAIT_AFB) &
                                      ~(reqbuf_l1_hit_other_cpus & ~l1_snoops_done))) &
                                    require_ext_after_afb) |
                                   ((((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                      (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                      (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                     (reqbuf_pass == PASS_ADDRMAINT_MASTER_W) &
                                     afb_done &
                                     (ACE == 0)) |
                                    ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                     (reqbuf_pass == PASS_CLEANUNIQUE_MASTER_W) &
                                     afb_done &
                                     (ACE == 0)) |
                                    ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                     (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                     ((ACE != 0) | afb_done) &
                                     ((reqbuf_l1_hit | reqbuf_l2_hit) ? ~reqbuf_cluster_unique :
                                                                        (((ACE == 0) & ~((L2_CACHE != 0) &
                                                                                         `CA53_MEM_WBWA(reqbuf_attrs) &
                                                                                         ~reqbuf_shareable &
                                                                                         reqbuf_l2db_full_err)) |
                                                                         reqbuf_shareable |
                                                                         ((L2_CACHE != 0) & `CA53_MEM_WBWA(reqbuf_attrs) &
                                                                          ~reqbuf_l2db_full_err))))))) |
                                 ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                  (L2_CACHE == 0) & (ACE == 0) &
                                  ((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) |
                                   ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) & ~reqbuf_l1_hit)) &
                                  (reqbuf_state == STATE_WAIT_AFB) &
                                  afb_done & require_l2db_after_afb)));

  assign next_l1_snoops_done = (l1_snoops_done | reqbuf_l1_resp_en) & ~reqbuf_alloc_i;

  always @(posedge clk_reqbuf)
  if (reqbuf_en) begin
    hazard_snoops <= next_hazard_snoops;
    l1_snoops_done <= next_l1_snoops_done;
  end

  generate if (ACE) begin : g_hazard_ace

    always @*
      victim_hazard_snoops = ~zero;

  end else begin : g_hazard_skyros      

    assign next_victim_hazard_snoops = ((reqbuf_alloc_i |
                                         victim_hazard_snoops |
                                         ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) & victim_l2db_done)) &
                                        ~(((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                           ((reqbuf_victim_pass == PASS_VICTIM_WRITE) |
                                            ((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) & reqbuf_l2_victim_valid)) &
                                           victim_afb_done & victim_require_l2db_after_afb) |
                                          ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                           (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2) &
                                           (reqbuf_state == STATE_WAIT_AFB) &
                                           afb_done & require_l2db_after_afb)));

    always @(posedge clk_reqbuf)
    if (reqbuf_en) begin
      victim_hazard_snoops <= next_victim_hazard_snoops;
    end

  end endgenerate

  // TC1 address and index comparators. The compare the primary address of a
  // new request being serialised against this request.
  assign addr1_l1_index_hz_tc1 = ({cpuslv_l1_dc_size_i & tagctl_addr_tc1_i[13:11], tagctl_addr_tc1_i[10:6]} ==
                                  {cpuslv_l1_dc_size_i & reqbuf_addr1[13:11], reqbuf_addr1[10:6]});
  assign addr1_l2_index_hz_tc1 = ({cpuslv_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {cpuslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]});
  assign addr1_addr_hz_tc1     = (tagctl_addr_valid_tc1_i &
                                  (tagctl_addr_tc1_i[41:13] == {1'b0, reqbuf_addr1[40:13]}) &
                                  addr1_l2_index_hz_tc1);

  assign addr2_l2_index_hz_tc1 = ({cpuslv_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {cpuslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]});
  assign addr2_addr_hz_tc1     = (tagctl_addr_valid_tc1_i &
                                  (tagctl_addr_tc1_i[41:13] == {1'b0, reqbuf_addr2[40:13]}) &
                                  addr2_l2_index_hz_tc1);


  // TC3 address and index comparators. These compare the victim address of a
  // new request being serialised against this request.
  assign addr1_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                  ({cpuslv_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                   {cpuslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]}));
  assign addr1_addr_hz_tc3     = (tagctl_addr_tc3_i[40:13] == reqbuf_addr1[40:13]) & addr1_l2_index_hz_tc3;

  assign addr2_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                  ({cpuslv_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                   {cpuslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]}));
  assign addr2_addr_hz_tc3     = (tagctl_addr_tc3_i[40:13] == reqbuf_addr2[40:13]) & addr2_l2_index_hz_tc3;


  // Hazard this request based on serialised addresses.
  assign reqbuf_hz_addr = ((reqbuf_type != `CA53_REQ_READNOSNOOP) &
                           (reqbuf_type != `CA53_REQ_WRITENOSNOOP) &
                           (reqbuf_type != `CA53_REQ_DMB) &
                           (reqbuf_type != `CA53_REQ_DSB) &
                           (reqbuf_type != `CA53_REQ_DVM));

  // Hazard this request based on addresses from the same CPU only. For device
  // reads, the only time there can be more than one from a CPU is an LDM where
  // all the reads are to the same cache line but different addresses within the
  // line.
  assign reqbuf_hz_cpu_addr = ((reqbuf_state != STATE_IDLE) &
                               (reqbuf_type != `CA53_REQ_CLEANSETWAY) &
                               (reqbuf_type != `CA53_REQ_CLEANINVSETWAY) &
                               (reqbuf_type != `CA53_REQ_DMB) &
                               (reqbuf_type != `CA53_REQ_DSB) &
                               (reqbuf_type != `CA53_REQ_DVM) &
                               ~(((reqbuf_type == `CA53_REQ_READNOSNOOP) &
                                  `CA53_MEM_DEVICE(reqbuf_attrs) &
                                  (reqbuf_state == STATE_WAIT_EXT) &
                                  ~readreceipt_wait) |
                                 ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) &
                                  ~`CA53_MEM_REORDERABLE(reqbuf_attrs) &
                                  ext_dbid_received)));

  // Hazard this request based on ordering against other requests from the same CPU.
  assign reqbuf_keep_order = ((reqbuf_state != STATE_IDLE) &
                              (reqbuf_state != STATE_CREDIT_RETURN) &
                              ((reqbuf_type == `CA53_REQ_ECCCLEAN) |
                               (((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                 (reqbuf_type == `CA53_REQ_CLEANINVSETWAY)) &
                                ~(reqbuf_serialised_tc1 |
                                  (reqbuf_state == STATE_WAIT_VICTIM))) |
                               ((((reqbuf_type == `CA53_REQ_READNOSNOOP) &
                                  ((reqbuf_state != STATE_WAIT_EXT) |
                                   readreceipt_wait)) |
                                 ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) &
                                  ~ext_dbid_received)) &
                                ~`CA53_MEM_REORDERABLE(reqbuf_attrs))));

  assign reqbuf_keep_order_o = reqbuf_keep_order;

  assign reqbuf_dvm_o = (reqbuf_type == `CA53_REQ_DVM);

  assign reqbuf_coh_o = (reqbuf_busy &
                         ~((reqbuf_type == `CA53_REQ_READNOSNOOP) |
                           (reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                           (reqbuf_type == `CA53_REQ_DVM)));

  // If this reqbuf cannot arbitrate yet, then we must prevent any new request
  // from arbitrating on the cycle it arrives as it could then overtake this
  // reqbuf.
  assign reqbuf_noncoh_only_o = ((reqbuf_state == STATE_WAIT_INITIAL) |
                                 (reqbuf_state == STATE_WAIT_COH));

  // This request buffer has been serialised, or will be serialised before the
  // request in tc1.
  assign reqbuf_serialised_tc1 = (~((reqbuf_state == STATE_IDLE) |
                                    (reqbuf_state == STATE_INITIAL) |
                                    (reqbuf_state == STATE_WAIT_INITIAL) |
                                    (reqbuf_state == STATE_WAIT_COH) |
                                    (reqbuf_state == STATE_WAIT_VICTIM) |
                                    (reqbuf_state == STATE_CREDIT_RETURN) |
                                    (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                      (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                      (reqbuf_type == `CA53_REQ_DVM)) &
                                     (reqbuf_pass == PASS_WRITE_L2DB)) |
                                    ((reqbuf_state_tc0_tc1 |
                                      (((reqbuf_state == STATE_TC2) |
                                        (reqbuf_state == STATE_TC3) |
                                        (reqbuf_state == STATE_TC4)) &
                                       ~tagctl_serialising_tc1_i)) &
                                     (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                       (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                       (reqbuf_type == `CA53_REQ_DVM)) ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                                         (reqbuf_pass == PASS_READ_SERIALISE)))));

  assign reqbuf_addr1_serialised_tc1 = (reqbuf_serialised_tc1 &
                                        reqbuf_hz_addr &
                                        ~((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                          (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                          (reqbuf_type == `CA53_REQ_ECCCLEAN)));

  // The victim address is serialised from TC4 on the serialisation pass until
  // either the victim state machine is complete, or the L1 victim has been
  // written into L2 and we are just waiting for the L2 victim.
  assign reqbuf_addr2_serialised = (((start_victim_no_flush |
                                      (reqbuf_victim_state != STATE_VICTIM_IDLE)) &
                                     ~((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                       (reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                       reqbuf_l2_victim_valid & ~reqbuf_l2_victim_hit)) |
                                    ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                     (L2_CACHE != 0) &
                                     (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                       (((reqbuf_state == STATE_TC4) & ~cpuslv_ecc_err_tc4_i) |
                                        (reqbuf_state == STATE_WAIT_AFB) |
                                        (reqbuf_state == STATE_WAIT_L2DB)) &
                                       ((reqbuf_l1_hit & ~reqbuf_l2db_full_err & reqbuf_cluster_unique) |
                                        (reqbuf_l2_hit & reqbuf_cluster_unique))) |
                                      ((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) &
                                       ((reqbuf_state == STATE_TC4) |
                                        (reqbuf_state == STATE_WAIT_AFB) |
                                        (reqbuf_state == STATE_WAIT_L2DB))) |
                                      (((reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE1) |
                                        (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)) &
                                       (reqbuf_state != STATE_IDLE)))));

  // Snoops only use some of the snpslv reqbufs.
  assign snoop_tc1 = `CA53_REQBUF_IS_SNOOP(tagctl_reqbufid_tc1_i);

  // The request in tc1 must hazard because this is an earlier serialised
  // request to the same address. If the request in tc1 is a snoop then the
  // hazarding is relaxed if this reqbuf is currently waiting for an external
  // request to complete (because the external request will block in the
  // interconnect on the snoop and so the snoop must be allowed to progress to
  // avoid deadlock).
  assign addr_hz_tc1 = ((tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                        ((reqbuf_addr1_serialised_tc1 &
                          (hazard_snoops | ~snoop_tc1) & 
                          addr1_addr_hz_tc1) |
                         (reqbuf_addr2_serialised &
                          (victim_hazard_snoops | ~snoop_tc1) &
                          addr2_addr_hz_tc1)));

  // If this is a serialised request that is in the process of picking an L2
  // victim, then we must hazard any unserialised requests to the same index in
  // case they hit in the way we pick, but before we have started hazarding
  // that address.
  // This must include the time from when we know the L1 victim address, to the
  // point when we know the L2 victim address.
  assign addr2_l2_way_unknown = ((L2_CACHE != 0) &
                                 reqbuf_addr2_serialised &
                                 (((start_victim |
                                    (reqbuf_victim_state != STATE_VICTIM_IDLE)) &
                                   (reqbuf_victim_pass == PASS_VICTIM_INITIAL)) |
                                  (((reqbuf_victim_pass == PASS_VICTIM_READ) |
                                    (reqbuf_victim_pass == PASS_VICTIM_LOOKUP)) &
                                   ((reqbuf_victim_state == STATE_VICTIM_PICK_REQ) |
                                    (reqbuf_victim_state == STATE_VICTIM_PICK_ACK) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC0) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC2) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC3) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC4)))) &
                                 ~set_way_op_l2);

  assign addr1_l2_way_unknown_tc1 = ((L2_CACHE != 0) &
                                     reqbuf_busy &
                                     (((set_way_op_l2 |
                                        (reqbuf_type == `CA53_REQ_READONCE) |
                                        (reqbuf_type == `CA53_REQ_READNONE) |
                                        (reqbuf_type == `CA53_REQ_READSHARED) |
                                        (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                        (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                        (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                        (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                        (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                       (reqbuf_pass == PASS_READ_SERIALISE) &
                                       ((reqbuf_state == STATE_TC2) |
                                        (reqbuf_state == STATE_TC3))) |
                                      ((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                       (((reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) &
                                         ((reqbuf_state == STATE_TC0_TC1) |
                                          (reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3))) |
                                        ((reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY) &
                                         ((reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                          (reqbuf_state == STATE_PICK_VICTIM_ACK) |
                                          ~snoop_tc1)) |
                                        ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                         ~(reqbuf_state == STATE_TC0_TC1) &
                                         ((reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3) |
                                          (reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                          (reqbuf_state == STATE_PICK_VICTIM_ACK) |
                                          (~((reqbuf_l1_hit & ~reqbuf_l2db_full_err & reqbuf_cluster_unique) |
                                             (reqbuf_l2_hit & reqbuf_cluster_unique)) &
                                           ~snoop_tc1)))) |
                                       ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                        reqbuf_lock &
                                        ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                          (reqbuf_state == STATE_TC0_TC1)) &
                                        ~snoop_tc1))));

  assign l2_index_hz_tc1 = ((tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                            tagctl_index_valid_tc1_i &
                            ((addr1_l2_way_unknown_tc1 & addr1_l2_index_hz_tc1) |
                             (addr2_l2_way_unknown     & addr2_l2_index_hz_tc1)));


  assign reqbuf_older_than_tc1 = ((tagctl_reqbufid_tc1_i[2:0] != REQBUF_ID[2:0]) &
                                  ~reqbufs_older_i[tagctl_reqbufid_tc1_i[2:0]]);

  // The request in tc1 must hazard if it is from the same CPU and is
  // younger than this request and must be kept in order (either because it
  // is to the same address, or because it is a non-reorderable memory type
  // or request type).
  // DVM syncs must not overtake older transactions, however newer non-DVM
  // transactions must be able to overtake DVM syncs as the sync may be
  // indirectly waiting for the newer transaction to complete.
  // Nothing can overtake an ECCClean request, because that might send a
  // snoop to an invalid address and so the normal hazarding is not sufficient.
  assign cpu_hz_tc1 = (tagctl_valid_tc1_i &
                       (tagctl_reqbufid_tc1_i[5:3] == REQBUF_ID[5:3]) &
                       ((reqbuf_hz_cpu_addr & addr1_addr_hz_tc1 & reqbuf_older_than_tc1) |
                        (reqbuf_keep_order & reqbuf_older_than_tc1 &
                         reqbufs_keep_order_i[tagctl_reqbufid_tc1_i[2:0]] &
                         ~((reqbuf_type == `CA53_REQ_DVM) &
                           (reqbuf_addr2[14:12] == `CA53_ACE_DVM_SYNC) &
                           ~reqbufs_dvm_i[tagctl_reqbufid_tc1_i[2:0]])) |
                        (reqbuf_busy &
                         reqbuf_older_than_tc1 &
                         ((reqbuf_type == `CA53_REQ_ECCCLEAN) |
                          ((reqbuf_type == `CA53_REQ_DVM) & tagctl_cpu_sync_tc1_i)))));

  // If a linefill has returned its response to the CPU but not updated the tags
  // then we must prevent a new linefill to the same index and way from looking
  // up in the outdated tags.
  // Set/way ops must not overtake linefills that may be to the same location.
  assign cpu_index_hz_tc1 = ((tagctl_reqbufid_tc1_i[5:3] == REQBUF_ID[5:3]) &
                             tagctl_serialising_tc1_i &
                             (reqbuf_state != STATE_IDLE) &
                             (((reqbuf_type == `CA53_REQ_READSHARED) &
                               (tagctl_l1_set_way_op_tc1_i |
                                (reqbuf_pass == PASS_READSHARED_L1_HIT) |
                                (reqbuf_pass == PASS_READSHARED_L2_HIT) |
                                (reqbuf_pass == PASS_READSHARED_MISS) |
                                (reqbuf_pass == PASS_READSHARED_RETRY) |
                                ((reqbuf_pass == PASS_READ_SERIALISE) &
                                 (reqbuf_state == STATE_COMPACK)))) |
                              ((reqbuf_type == `CA53_REQ_READUNIQUE) &
                               (tagctl_l1_set_way_op_tc1_i |
                                (reqbuf_pass == PASS_READUNIQUE_HIT1) |
                                (reqbuf_pass == PASS_READUNIQUE_HIT2) |
                                (reqbuf_pass == PASS_READUNIQUE_HIT_RETRY) |
                                (reqbuf_pass == PASS_READUNIQUE_MISS_RETRY) |
                                (reqbuf_pass == PASS_READUNIQUE_MISS) |
                                ((reqbuf_pass == PASS_READ_SERIALISE) &
                                 (reqbuf_state == STATE_COMPACK)))) |
                              ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                               reqbuf_serialised_tc1 &
                               tagctl_l1_lf_tc1_i &
                               |({4{`CA53_L1_WAY_DEC(reqbuf_req_way)}} & reqbuf_requestor_l1_mask & tagctl_ecc_way_tc1_i))) &
                             addr1_l1_index_hz_tc1 &
                             reqbuf_older_than_tc1);

  assign requestor_way_tc1 = {{4{tagctl_reqbufid_tc1_i[4:3] == 2'b11}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b10}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b01}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b00}}} & tagctl_ecc_way_tc1_i;

  // If there was a fatal ECC error on the duplicate tags then the normal
  // address hazarding may not catch an L1 eviction to the same index/way
  // as an existing request that is going to update the tag, so detect that
  // case here.
  assign l1_index_way_hz_tc1 = (reqbuf_addr1_serialised_tc3 &
                                ~((reqbuf_state == STATE_TC4) & cpuslv_ecc_err_tc4_i) &
                                tagctl_serialising_tc1_i &
                                tagctl_l1_lf_tc1_i &
                                addr1_l1_index_hz_tc1 &
                                |(reqbuf_hit_ways[15:0] & requestor_way_tc1) &
                                ((reqbuf_type == `CA53_REQ_READSHARED) |
                                 (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                 (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                 (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                 (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                 (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                 (reqbuf_type == `CA53_REQ_MAKEINVALID)));

  // Only one DVM sync may be serialised at a time, as ACE does not permit
  // more than one to be outstanding externally.
  assign sync_hz_tc1 = (reqbuf_serialised_tc1 &
                        (reqbuf_type == `CA53_REQ_DVM) &
                        (reqbuf_addr2[14:12] == `CA53_ACE_DVM_SYNC) &
                        (tagctl_cpu_sync_tc1_i |
                         (tagctl_snp_sync_tc1_i &
                          ~((reqbuf_state == STATE_WAIT_EXT) |
                            ((reqbuf_state == STATE_WAIT_L2DB) & (ACE == 0)) |
                            ((reqbuf_state == STATE_WAIT_AFB) & l1_snoops_done)))));

  // Collate the hazarding hazarding information. It will then be combined with
  // the other reqbuf outputs and registered in the slv before sending back to
  // tagctl in tc2.
  assign reqbuf_hz_tc1_o = addr_hz_tc1 | cpu_hz_tc1 | sync_hz_tc1 | cpu_index_hz_tc1 | l1_index_way_hz_tc1 | l2_index_hz_tc1;

  assign reqbuf_snp_hz_tc1 = (reqbuf_addr1_serialised_tc1 & addr1_addr_hz_tc1 &
                              ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                               (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                               (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                               (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                              ((`CA53_MEM_SHAREABLE(reqbuf_victim_shareability) & cpuslv_broadcastinner_i) |
                               (`CA53_MEM_O_SHAREABLE(reqbuf_victim_shareability) & cpuslv_broadcastouter_i)) &
                              ~hazard_snoops);

  assign reqbuf_snp_hz_tc1_o = reqbuf_snp_hz_tc1;

  // Indicate that this request is using a request buffer then a snoop might need to get data from.
  assign reqbuf_snp_l2db_hz_tc1 = (reqbuf_addr1_serialised_tc1 & addr1_addr_hz_tc1 &
                                   (reqbuf_type == `CA53_REQ_READUNIQUE) &
                                   ~hazard_snoops &
                                   ~ext_snoop_invalidated &
                                   ((reqbuf_l1_hit_other_cpus | reqbuf_l2_hit) & ~reqbuf_cluster_unique));

  assign reqbuf_snp_l2db_hz_tc1_o = reqbuf_snp_l2db_hz_tc1;

  assign reqbuf_snp_l2db_dirty_tc1_o = (reqbuf_snp_l2db_hz_tc1 &
                                        ((reqbuf_l1_hit_other_cpus & reqbuf_l1_dirty) |
                                         (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                                        ~ext_snoop_cleaned);

  assign reqbuf_requestor_ecc_hz_tc1 = |(reqbuf_requestor_l1_mask &
                                         {4{`CA53_L1_WAY_DEC(reqbuf_req_way)}} &
                                         tagctl_ecc_way_tc1_i);

  // If this request is going to be updating the duplicate tags to a
  // non-invalid value, and there is a fatal ECC error on the duplicate tags
  // then that fatal error must not cause a MakeInvalid snoop to the CPU because
  // then when we update the tags they will be inconsistent with the CPU. So
  // detect this case and tell tagctl not to send a snoop.
  assign reqbuf_ecc_hz_tc1 = (tagctl_ecc_wr_tc1_i &
                              reqbuf_addr1_serialised_tc1 & addr1_l1_index_hz_tc1 &
                              ((((reqbuf_type == `CA53_REQ_READSHARED) |
                                 (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                 (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                 ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                  ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                    ((reqbuf_state == STATE_TC2) |
                                     (reqbuf_state == STATE_TC3) |
                                     (reqbuf_state == STATE_TC4))) &
                                  (reqbuf_cluster_unique |
                                   (ext_beats_received & ~ext_snoop_invalidated)))) &
                                reqbuf_requestor_ecc_hz_tc1) |
                               ((((reqbuf_type == `CA53_REQ_CLEANSHARED) &
                                  ((ACE != 0) | tag_write_needed)) | 
                                 (reqbuf_type == `CA53_REQ_READSHARED)) &
                                |(reqbuf_hit_ways[15:0] & tagctl_ecc_way_tc1_i))));

  assign reqbuf_ecc_hz_tc1_o = reqbuf_ecc_hz_tc1;

  // As it is not known if a CleanUnique will update its requestor tag, because
  // this depends on if there is an external snoop in the future, then it cannot
  // factor into the ecc_hz logic. Instead, we allow the ECC logic to do the
  // snoop, and then prevent the CleanUnique from updating the tags.
  assign reqbuf_cleanunique_ecc_hz_tc1 = (tagctl_ecc_wr_tc1_i &
                                          reqbuf_addr1_serialised_tc1 & addr1_l1_index_hz_tc1 &
                                          (reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                          ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                            ((reqbuf_state == STATE_TC2) |
                                             (reqbuf_state == STATE_TC3) |
                                             (reqbuf_state == STATE_TC4))) &
                                          ~reqbuf_cluster_unique &
                                          ~ext_beats_received &
                                          reqbuf_requestor_ecc_hz_tc1);

  assign next_reqbuf_ecc_hz = (reqbuf_ecc_hz_tc1 | reqbuf_ecc_hz) & ~reqbuf_alloc_i;

  always @(posedge clk_reqbuf)
  if (reqbuf_en) begin
    reqbuf_ecc_hz <= next_reqbuf_ecc_hz;
  end

  // Indicate that a way has an old value that has been evicted, but the
  // requestor has not updated the tag yet.
  assign reqbuf_force_miss_tc1_o = (({{16{(((reqbuf_type == `CA53_REQ_READONCE) &
                                            `CA53_MEM_WBRA(reqbuf_attrs)) |
                                           (reqbuf_type == `CA53_REQ_READNONE)) &
                                          reqbuf_addr1_serialised_tc1 &
                                          (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                          ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                            ((reqbuf_state == STATE_TC2) |
                                             (reqbuf_state == STATE_TC3) |
                                             ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i) |
                                             (reqbuf_state == STATE_RESP))) &
                                          ~(reqbuf_state == STATE_UPDATE_VICTIM) &
                                          ~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                          tagctl_addr_valid_tc1_i &
                                          addr1_l2_index_hz_tc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                      {16{((reqbuf_type == `CA53_REQ_READSHARED) |
                                           (reqbuf_type == `CA53_REQ_READUNIQUE)) &
                                          reqbuf_addr1_serialised_tc1 &
                                          (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                          ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                            ((reqbuf_state == STATE_TC2) |
                                             (reqbuf_state == STATE_TC3) |
                                             ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i))) &
                                          ~((reqbuf_state == STATE_TC2) & require_idle_after_tc2) &
                                          addr1_l1_index_hz_tc1}} &
                                      reqbuf_requestor_l1_mask &
                                      {4{`CA53_L1_WAY_DEC(reqbuf_req_way)}}}) |
                                    ({32{(((reqbuf_type == `CA53_REQ_CLEANUNIQUE) & ~reqbuf_lock) |
                                          (reqbuf_type == `CA53_REQ_READUNIQUE)) &
                                         reqbuf_addr1_serialised_tc1 &
                                         (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                         ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                           ((reqbuf_state == STATE_TC2) |
                                            (reqbuf_state == STATE_TC3) |
                                            ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i))) &
                                         addr1_addr_hz_tc1 &
                                         ~hazard_snoops &
                                         (tagctl_reqbufid_tc1_i[5:3] == 3'b101)}} &
                                     ({{16{reqbuf_l2_hit}} & `CA53_L2_WAY_DEC(reqbuf_l2_hit_way),
                                       {4{reqbuf_l1_hit_cpus[3]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_3),
                                       {4{reqbuf_l1_hit_cpus[2]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_2),
                                       {4{reqbuf_l1_hit_cpus[1]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_1),
                                       {4{reqbuf_l1_hit_cpus[0]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_0)} &
                                      ~({16'h0000,
                                         {16{(reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                             (reqbuf_type == `CA53_REQ_READUNIQUE)}} &
                                        reqbuf_requestor_l1_mask}))));

  // Indicate that an L2 way is in use by this transaction, and so shouldn't
  // be picked as a victim way.
  // When in tc2 and tc3 we don't know which way hit, and so rely on the index
  // hazarding to prevent serialisation if we might hit a way being picked for
  // a victim.
  assign way_used_l2_hit_tc1 = (((((reqbuf_type == `CA53_REQ_READONCE) |
                                   (reqbuf_type == `CA53_REQ_READSHARED) |
                                   (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                   (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                   (reqbuf_type == `CA53_REQ_CLEANUNIQUE) |
                                   (reqbuf_type == `CA53_REQ_CLEANSHARED) |
                                   (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                                   (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                                  reqbuf_l2_hit) |
                                 (set_way_op_l2 & ~set_way_nop & reqbuf_l2_victim_valid)) &
                                reqbuf_serialised_tc1 &
                                reqbuf_hz_addr &
                                ~(((reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                                            (reqbuf_pass == PASS_READ_SERIALISE)) &
                                  ((reqbuf_state == STATE_TC2) |
                                   (reqbuf_state == STATE_TC3) |
                                   ((reqbuf_state == STATE_TC4) & cpuslv_ecc_err_tc4_i))));

  assign way_used_l2_miss_tc1 = ((((((reqbuf_type == `CA53_REQ_READONCE) &
                                     `CA53_MEM_WBRA(reqbuf_attrs)) |
                                    (reqbuf_type == `CA53_REQ_READNONE)) &
                                   ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                  (reqbuf_type == `CA53_REQ_WRITEUNIQUE)) &
                                 ~reqbuf_l2_hit &
                                 reqbuf_serialised_tc1 &
                                 reqbuf_hz_addr &
                                 ~((reqbuf_type == `CA53_REQ_WRITEUNIQUE) & (reqbuf_pass == PASS_WRITEUNIQUE_UNIQUE2)) &
                                 ~(((reqbuf_type == `CA53_REQ_WRITEUNIQUE) ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                                             (reqbuf_pass == PASS_READ_SERIALISE)) &
                                   ((reqbuf_state == STATE_TC2) |
                                    (reqbuf_state == STATE_TC3) |
                                    ((reqbuf_state == STATE_TC4) & cpuslv_ecc_err_tc4_i) |
                                    (reqbuf_state == STATE_RESP))));

  assign way_used_victim_tc1 = ((((reqbuf_type == `CA53_REQ_READSHARED) |
                                  (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                  (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                  (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                  (reqbuf_type == `CA53_REQ_ECCCLEAN)) &
                                 (reqbuf_victim_state != STATE_VICTIM_IDLE) &
                                 (((reqbuf_victim_pass == PASS_VICTIM_LOOKUP) &
                                   ~((reqbuf_victim_state == STATE_VICTIM_PICK_REQ) |
                                     (reqbuf_victim_state == STATE_VICTIM_PICK_ACK) |
                                     (reqbuf_victim_state == STATE_VICTIM_TC0) |
                                     (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) |
                                     (reqbuf_victim_state == STATE_VICTIM_TC2) |
                                     (reqbuf_victim_state == STATE_VICTIM_TC3))) |
                                  (reqbuf_victim_pass == PASS_VICTIM_UPDATE) |
                                  set_way_op_l2)) |
                                (((reqbuf_type == `CA53_REQ_READONCE) |
                                  (reqbuf_type == `CA53_REQ_READNONE)) &
                                 (reqbuf_victim_state != STATE_VICTIM_IDLE) &
                                 ((reqbuf_victim_pass == PASS_VICTIM_READ) |
                                  (reqbuf_victim_pass == PASS_VICTIM_WRITE) |
                                  (reqbuf_victim_pass == PASS_VICTIM_UPDATE))));

  assign way_used_valid_tc1 = ~`CA53_REQBUF_IS_TAGECC(tagctl_reqbufid_tc1_i) & ~reqbuf_state_tc1;

  assign reqbuf_l2_way_used_tc1_o = (({16{way_used_valid_tc1 &
                                          way_used_l2_hit_tc1 &
                                          addr1_l2_index_hz_tc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_hit_way)) |
                                     ({16{way_used_valid_tc1 &
                                          (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                          way_used_l2_miss_tc1 &
                                          addr1_l2_index_hz_tc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_victim_way)) |
                                     ({16{way_used_valid_tc1 &
                                          (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                          way_used_victim_tc1 &
                                          addr2_l2_index_hz_tc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_victim_way)));

  assign addr1_l2_index_hz_vc1 = ({cpuslv_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                  {cpuslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]});

  assign addr2_l2_index_hz_vc1 = ({cpuslv_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                  {cpuslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]});

  assign reqbuf_l2_way_used_vc1_o = (({16{way_used_l2_hit_tc1 &
                                          addr1_l2_index_hz_vc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_hit_way)) |
                                     ({16{way_used_l2_miss_tc1 &
                                          addr1_l2_index_hz_vc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_victim_way)) |
                                     ({16{way_used_victim_tc1 &
                                          addr2_l2_index_hz_vc1}} &
                                      `CA53_L2_WAY_DEC(reqbuf_l2_victim_way)));

  // This request buffer has been serialised, or will be serialised before the
  // request in tc3.
  assign reqbuf_addr1_serialised_tc3 = (reqbuf_hz_addr &
                                        ~((reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                                          (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                                          (reqbuf_type == `CA53_REQ_ECCCLEAN)) &
                                        ~((reqbuf_state == STATE_IDLE) |
                                          (reqbuf_state == STATE_INITIAL) |
                                          (reqbuf_state == STATE_WAIT_INITIAL) |
                                          (reqbuf_state == STATE_WAIT_COH) |
                                          (reqbuf_state == STATE_WAIT_VICTIM) |
                                          (reqbuf_state == STATE_CREDIT_RETURN) |
                                          (((reqbuf_state == STATE_TC3) |
                                            (reqbuf_state == STATE_TC2) |
                                            reqbuf_state_tc0_tc1) &
                                           (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                             (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                             (reqbuf_type == `CA53_REQ_DVM)) ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                                               (reqbuf_pass == PASS_READ_SERIALISE))) |
                                          (((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                            (reqbuf_type == `CA53_REQ_WRITEUNIQUE) |
                                            (reqbuf_type == `CA53_REQ_DVM)) & (reqbuf_pass == PASS_WRITE_L2DB))));

  assign addr1_l2_way_unknown_tc3 = ((L2_CACHE != 0) &
                                     reqbuf_busy &
                                     (((reqbuf_type == `CA53_REQ_WRITEUNIQUE) &
                                       (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                         ~((reqbuf_state == STATE_TC0_TC1) |
                                           (reqbuf_state == STATE_TC2) |
                                           (reqbuf_state == STATE_TC3))) |
                                        (reqbuf_pass == PASS_WRITEUNIQUE_N_UNIQUE) |
                                        (reqbuf_pass == PASS_WRITEUNIQUE_HIT_RETRY))) |
                                      ((reqbuf_type == `CA53_REQ_CLEANUNIQUE) &
                                       reqbuf_lock &
                                       ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                         ((reqbuf_state == STATE_TC0_TC1) |
                                          (reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3))))) &
                                     ~snoop_tc3);

  assign l2_index_hz_tc3 = ((addr1_l2_way_unknown_tc3 & addr1_l2_index_hz_tc3) |
                            (addr2_l2_way_unknown     & addr2_l2_index_hz_tc3));

  // Snoops only use some of the snpslv reqbufs.
  assign snoop_tc3 = `CA53_REQBUF_IS_SNOOP(tagctl_reqbufid_tc3_i);

  // The request in tc3 must hazard because this is an earlier serialised
  // request to the same address. If the request in tc3 is a snoop then the
  // hazarding is relaxed if this reqbuf is currently waiting for an external
  // request to complete (because the external request will block in the
  // interconnect on the snoop and so the snoop must be allowed to progress to
  // avoid deadlock).
  assign reqbuf_hz_tc3_o = ((reqbuf_addr1_serialised_tc3 &
                             (hazard_snoops | ~snoop_tc3) &
                             addr1_addr_hz_tc3) |
                            (reqbuf_addr2_serialised &
                             (victim_hazard_snoops | ~snoop_tc3) &
                             addr2_addr_hz_tc3) |
                            l2_index_hz_tc3);

  // If a later request hazards on a write, then tell the STB to drain the
  // write so that the later request can make progress. Without this, the STB
  // would drain eventually, so this is just a performance optimisation.
  assign reqbuf_drain_stb_o = cpu_hz_tc1 & ((reqbuf_type == `CA53_REQ_WRITENOSNOOP) |
                                            (reqbuf_type == `CA53_REQ_WRITEUNIQUE));

  //----------------------------------------------------------------------------
  //  Performance counter events
  //----------------------------------------------------------------------------

  // Count events at serialisation, so that we know only one reqbuf can generate
  // an event on any cycle.

  // Reads that are satisfied from another CPU's L1 cache.
  assign reqbuf_evnt_snooped_data_o = ((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i &
                                       (reqbuf_pass == PASS_READ_SERIALISE) &
                                       ((reqbuf_type == `CA53_REQ_READSHARED) |
                                        (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                        (reqbuf_type == `CA53_REQ_READONCE)) &
                                       reqbuf_l1_hit_other_cpus & ~reqbuf_l2_hit);

  // Read and write operations that access the L2 cache, including L1 writebacks.
  assign reqbuf_evnt_l2_access_o = ((L2_CACHE != 0) &
                                    (((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i &
                                      (((reqbuf_pass == PASS_READ_SERIALISE) &
                                        ((reqbuf_type == `CA53_REQ_READSHARED) |
                                         (reqbuf_type == `CA53_REQ_READUNIQUE) |
                                         (reqbuf_type == `CA53_REQ_READONCE) |
                                         (reqbuf_type == `CA53_REQ_READNONE))) |
                                       ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                        (reqbuf_type == `CA53_REQ_WRITEUNIQUE)))) |
                                     (reqbuf_l2db_victim_transfer &
                                      (reqbuf_victim_pass == PASS_VICTIM_LOOKUP))));

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A reqbuf may only be allocated when not busy")
  u_ovl_alloc_idle (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_alloc_i),
    .consequent_expr (~reqbuf_busy));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A reqbuf may only be allocated when the clock is enabled")
  u_ovl_alloc_enable (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_alloc_i),
    .consequent_expr (reqbuf_clk_enable));

  wire ovl_reqbuf_victim_state_tc0 = ((reqbuf_victim_state == STATE_VICTIM_TC0) |
                                      ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) &
                                       ~reqbuf_arb_tc1_i));

  wire ovl_reqbuf_state_tc0 = (((reqbuf_state == STATE_INITIAL) &
                                reqbuf_allocated_i & ~reqbuf_arb_tc1_i &
                                ~reqbuf_dvm_part_two & ~set_way_nop &
                                (reqbuf_type != `CA53_REQ_READNONE) &
                                (reqbuf_type != `CA53_REQ_DMB) &
                                (reqbuf_type != `CA53_REQ_DSB)) |
                               ((reqbuf_state == STATE_TC0_TC1) &
                                ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) |
                                 ~reqbuf_arb_tc1_i)));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl valid must match with the rebuf state")
  u_ovl_tagctl_valid (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_tagctl_valid_tc0),
    .consequent_expr (ovl_reqbuf_state_tc0 | ovl_reqbuf_victim_state_tc0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl valid must match with the rebuf state")
  u_ovl_tagctl_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_tagctl_req_tc0),
    .consequent_expr (ovl_reqbuf_state_tc0 | reqbuf_state_tc1 | ovl_reqbuf_victim_state_tc0 | reqbuf_victim_state_tc1));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine may only be active when the main state machine is also active")
  u_ovl_victim_active (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_victim_state != STATE_VICTIM_IDLE),
    .consequent_expr (reqbuf_state != STATE_IDLE));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only certain types of request may start the victim state machine")
  u_ovl_victim_type (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_victim_state != STATE_VICTIM_IDLE),
    .consequent_expr ((reqbuf_type == `CA53_REQ_READSHARED) |
                      (reqbuf_type == `CA53_REQ_READUNIQUE) |
                      (reqbuf_type == `CA53_REQ_READONCE) |
                      (reqbuf_type == `CA53_REQ_READNONE) |
                      (reqbuf_type == `CA53_REQ_CLEANSETWAY) |
                      (reqbuf_type == `CA53_REQ_CLEANINVSETWAY) |
                      (reqbuf_type == `CA53_REQ_ECCCLEAN)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set, all_ext_beats_returned must remain set until the reqbuf is idle")
  u_ovl_all_beats (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (reqbuf_busy & all_ext_beats_returned),
                   .test_expr   ((reqbuf_state == STATE_IDLE) | all_ext_beats_returned));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a decerr, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_dec (.clk         (clk),
                            .reset_n     (reset_n),
                            .start_event (reqbuf_busy & (ext_beats_resp == `CA53_ACE_RESP_DECERR)),
                            .test_expr   ((reqbuf_state == STATE_IDLE) | (ext_beats_resp == `CA53_ACE_RESP_DECERR)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a slverr, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_slv (.clk         (clk),
                            .reset_n     (reset_n),
                            .start_event (reqbuf_busy & (ext_beats_resp == `CA53_ACE_RESP_SLVERR)),
                            .test_expr   ((reqbuf_state == STATE_IDLE) | ((ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                                                          (ext_beats_resp == `CA53_ACE_RESP_SLVERR))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a exokay, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_exokay (.clk         (clk),
                               .reset_n     (reset_n),
                               .start_event (reqbuf_busy & ~reqbuf_lock & (ext_beats_resp == `CA53_ACE_RESP_EXOKAY)),
                               .test_expr   ((reqbuf_state == STATE_IDLE) | ((ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                                                             (ext_beats_resp == `CA53_ACE_RESP_SLVERR) |
                                                                             (ext_beats_resp == `CA53_ACE_RESP_EXOKAY))));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "An addr maint op may not be flushed from TC4 on some passes")
  u_ovl_addr_maint_no_tc4_flush (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_TC4) &
                      ((reqbuf_type == `CA53_REQ_CLEANSHARED) |
                       (reqbuf_type == `CA53_REQ_CLEANINVALID) |
                       (reqbuf_type == `CA53_REQ_MAKEINVALID)) &
                      (reqbuf_pass == PASS_ADDRMAINT_MASTER_W)),
    .consequent_expr (~tagctl_slv_flush_tc4_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A victim request cannot be flushed from tc2")
  u_ovl_victim_no_tc2_flush (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_victim_state == STATE_VICTIM_TC2),
    .consequent_expr (~tagctl_slv_flush_tc2_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A victim request cannot be flushed from tc2")
  u_ovl_victim_no_tc3_flush (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_victim_state == STATE_VICTIM_TC3),
    .consequent_expr (~tagctl_slv_flush_tc3_i));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Main state machine can only be in valid states")
  u_ovl_reqbuf_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((reqbuf_state == STATE_IDLE) |
                (reqbuf_state == STATE_INITIAL) |
                (reqbuf_state == STATE_TC0_TC1) |
                (reqbuf_state == STATE_TC2) |
                (reqbuf_state == STATE_TC3) |
                (reqbuf_state == STATE_TC4) |
                (reqbuf_state == STATE_WAIT_AFB) |
                (reqbuf_state == STATE_WAIT_L2DB) |
                (reqbuf_state == STATE_WAIT_EXT) |
                (reqbuf_state == STATE_COMPACK) |
                (reqbuf_state == STATE_WAIT_WADDR) |
                (reqbuf_state == STATE_WAIT_VICTIM) |
                (reqbuf_state == STATE_RESP) |
                (reqbuf_state == STATE_WAIT_REQBUFS) |
                (reqbuf_state == STATE_WAIT_WADDRS) |
                (reqbuf_state == STATE_CREDIT_RETURN) |
                (reqbuf_state == STATE_WAIT_INITIAL) |
                (reqbuf_state == STATE_WAIT_COH) |
                (reqbuf_state == STATE_PICK_VICTIM_REQ) |
                (reqbuf_state == STATE_PICK_VICTIM_ACK) |
                (reqbuf_state == STATE_UPDATE_VICTIM)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Victim state machine can only be in valid states")
  u_ovl_reqbuf_victim_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((reqbuf_victim_state == STATE_VICTIM_IDLE) |
                (reqbuf_victim_state == STATE_VICTIM_TC0) |
                (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) |
                (reqbuf_victim_state == STATE_VICTIM_TC2) |
                (reqbuf_victim_state == STATE_VICTIM_TC3) |
                (reqbuf_victim_state == STATE_VICTIM_TC4) |
                (reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) |
                (reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) |
                (reqbuf_victim_state == STATE_VICTIM_UPDATE) |
                (reqbuf_victim_state == STATE_VICTIM_PICK_REQ) |
                (reqbuf_victim_state == STATE_VICTIM_PICK_ACK)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "reqbuf_next_state_tc0_tc1 optimisation correct")
  u_ovl_reqbuf_next_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (reqbuf_next_state_tc0_tc1 == (next_reqbuf_state == STATE_TC0_TC1)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "reqbuf_victim_next_state_tc0_tc1 optimisation correct")
  u_ovl_reqbuf_victim_next_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (reqbuf_victim_next_state_tc0_tc1 == ((next_reqbuf_victim_state == STATE_VICTIM_TC0) |
                                                     (next_reqbuf_victim_state == STATE_VICTIM_TC0_TC1))));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from wait L2DB")
  u_ovl_victim_idle_l2db (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_WAIT_L2DB) & (next_reqbuf_state == STATE_CREDIT_RETURN)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from wait ext")
  u_ovl_victim_idle_ext (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_WAIT_EXT) & (next_reqbuf_state == STATE_CREDIT_RETURN)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from compack")
  u_ovl_victim_idle_compack (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_COMPACK) & (next_reqbuf_state == STATE_CREDIT_RETURN)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_reqbuf_l2db_primary_transfer")
  u_ovl_x_next_reqbuf_l2db_primary_transfer (.clk       (clk_reqbuf),
                                             .reset_n   (reset_n),
                                             .qualifier (1'b1),
                                             .test_expr (next_reqbuf_l2db_primary_transfer));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_reqbuf_l2db_victim_transfer")
  u_ovl_x_next_reqbuf_l2db_victim_transfer (.clk       (clk_reqbuf),
                                            .reset_n   (reset_n),
                                            .qualifier (1'b1),
                                            .test_expr (next_reqbuf_l2db_victim_transfer));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_state_en_tc3")
  u_ovl_x_hit_state_en_tc3 (.clk       (clk_reqbuf),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (hit_state_en_tc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_state_en_tc4")
  u_ovl_x_hit_state_en_tc4 (.clk       (clk_reqbuf),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (hit_state_en_tc4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_victim_way_en")
  u_ovl_x_l2_victim_way_en (.clk       (clk_reqbuf),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l2_victim_way_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_retry_received_en")
  u_ovl_x_reqbuf_retry_received_en (.clk       (clk_reqbuf),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (reqbuf_retry_received_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: update_reqbuf_pass")
  u_ovl_x_update_reqbuf_pass (.clk       (clk_reqbuf),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (update_reqbuf_pass));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: update_reqbuf_victim_pass")
  u_ovl_x_update_reqbuf_victim_pass (.clk       (clk_reqbuf),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (update_reqbuf_victim_pass));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victim_hit_state_en")
  u_ovl_x_victim_hit_state_en (.clk       (clk_reqbuf),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (victim_hit_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable x-check")
  u_ovl_x_clk_enable (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (clk_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_shareability_en")
  u_ovl_x_reqbuf_shareability_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (reqbuf_shareability_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_addr1_en")
  u_ovl_x_reqbuf_addr1_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (reqbuf_addr1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_dbid_en")
  u_ovl_x_reqbuf_dbid_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (reqbuf_dbid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_retry_i")
  u_ovl_x_reqbuf_retry_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (reqbuf_retry_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_l2db_full_err_en")
  u_ovl_x_reqbuf_l2db_full_err_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (reqbuf_l2db_full_err_en));


  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "reqbuf_pass x-check")
  u_ovl_x_reqbuf_pass (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier ((reqbuf_state != STATE_IDLE)),
                       .test_expr (reqbuf_pass));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_state_en")
  u_ovl_x_hit_state_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (hit_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_valid_tc4")
  u_ovl_x_l2db_valid_tc4 (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (l2db_valid_tc4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: primary_l2db_en")
  u_ovl_x_primary_l2db_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (primary_l2db_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_addr2_en")
  u_ovl_x_reqbuf_addr2_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (reqbuf_addr2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_alloc_i")
  u_ovl_x_reqbuf_alloc_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (reqbuf_alloc_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_en")
  u_ovl_x_reqbuf_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (reqbuf_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_ext_en")
  u_ovl_x_reqbuf_ext_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (reqbuf_ext_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_ext_ret_en")
  u_ovl_x_reqbuf_ext_ret_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_ext_ret_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_l1_resp_en")
  u_ovl_x_reqbuf_l1_resp_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_l1_resp_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_resp_victim_en")
  u_ovl_x_reqbuf_resp_victim_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (reqbuf_resp_victim_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l1_victim_hit_en")
  u_ovl_x_l1_victim_hit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l1_victim_hit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_victim_hit_en")
  u_ovl_x_l2_victim_hit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l2_victim_hit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victim_l2db_en")
  u_ovl_x_victim_l2db_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (victim_l2db_en));


`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
