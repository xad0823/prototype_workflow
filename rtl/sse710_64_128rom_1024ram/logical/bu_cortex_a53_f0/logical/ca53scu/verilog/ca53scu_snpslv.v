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
//  The snoop slave interfaces between the SCU and the external snoop channel.
//  It buffers requests and responses, but not snoop data (which is transfered
//  via the master).
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"


module ca53scu_snpslv #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                            clk,
  input  wire                            clk_ext_master,
  input  wire                            reset_n,
  input  wire                            DFTSE,

  output wire                            snpslv_active_o,
  output wire                            snpslv_retention_active_o,
  output wire                            snpslv_ramctl_active_o,
  output wire                            snpslv_master_active_o,

  input  wire                            config_broadcastinner_i,
  input  wire                            config_sysbardisable_i,
  input  wire [2:0]                      config_l1_dc_size_i,
  input  wire [3:0]                      config_l2_size_i,
  input  wire [6:0]                      config_nodeid_i,

  input  wire                            gov_l2_in_retention_i,
  input  wire                            inactm_rs_i,

  // External snoop channel (ACE)
  input  wire                            clean_aclken_i,
  output wire                            scu_ext_ac_ready_o,
  input  wire                            scu_ext_ac_valid_i,
  input  wire [`CA53_ACE_ACSNOOP_W-1:0]  scu_ext_ac_snoop_i,
  input  wire [`CA53_SCU_EXT_ADDR_W-1:0] scu_ext_ac_addr_i,
  input  wire [`CA53_ACE_ACPROT_W-1:0]   scu_ext_ac_prot_i,
  output wire                            scu_ext_cr_valid_o,
  input  wire                            scu_ext_cr_ready_i,
  output wire [`CA53_ACE_CRRESP_W-1:0]   scu_ext_cr_resp_o,

  // External snoop channel (Skyros)
  input  wire                            ext_rxsnpflitpend_i,
  input  wire                            ext_rxsnpflitv_i,
  input  wire [64:0]                     ext_rxsnpflit_i,
  output wire                            scu_rxsnplcrdv_o,

  output wire                            scu_txrspflitpend_o,
  output wire                            scu_txrspflitv_o,
  output wire [44:0]                     scu_txrspflit_o,
  input  wire                            ext_txrsplcrdv_i,

  // L2 set/way ops
  input  wire                            ramctl_ecc_flush_req_i,
  input  wire                            ramctl_ecc_flush_active_i,
  input  wire [10:0]                     ramctl_ecc_flush_index_i,
  input  wire [3:0]                      ramctl_ecc_flush_way_i,

  // Tagctl requests
  output wire                            snpslv_tagctl_valid_tc0_o,
  output wire                            snpslv_tagctl_early_valid_tc0_o,
  output wire                            snpslv_tagctl_spec_valid_tc0_o,
  output wire                            snpslv_tagctl_active_tc0_o,
  input  wire                            tagctl_snpslv_ready_tc0_i,
  output wire [2:0]                      snpslv_tagctl_reqbufid_tc0_o,
  output wire [3:0]                      snpslv_tagctl_pass_tc0_o,
  output wire [41:0]                     snpslv_tagctl_addr1_tc0_o,
  output wire                            snpslv_tagctl_dvm_sync_tc0_o,
  output wire [16:0]                     snpslv_tagctl_wr_state_tc0_o,
  output wire [34:0]                     snpslv_tagctl_ecc_tc0_o,
  output wire [31:0]                     snpslv_tagctl_ways_tc0_o,
  output wire [4:0]                      snpslv_tagctl_write_tc0_o,
  output wire [4:0]                      snpslv_tagctl_type_tc0_o,
  output wire [40:0]                     snpslv_tagctl_addr2_tc1_o,
  output wire [7:0]                      snpslv_tagctl_attrs_tc1_o,
  output wire                            snpslv_tagctl_dirty_tc1_o,
  output wire                            snpslv_tagctl_cluster_unique_tc1_o,
  output wire [3:0]                      snpslv_tagctl_l2db_tc1_o,
  output wire                            snpslv_tagctl_static_pcredit_tc1_o,
  output wire [1:0]                      snpslv_tagctl_pcrdtype_tc1_o,

  input wire [5:0]                       tagctl_reqbufid_tc1_i,
  input wire [2:0]                       tagctl_slv_afb_tc1_i,
  input wire                             tagctl_slv_l2db_hit_tc3_i,
  input wire                             tagctl_slv_l2db_dirty_tc3_i,
  input wire                             tagctl_slv_l2db_cu_tc3_i,
  input wire [3:0]                       tagctl_slv_l2db_tc3_i,
  input wire [15:0]                      tagctl_l1_hit_ways_tc3_i,
  input wire [15:0]                      tagctl_l2_hit_ways_tc3_i,
  input wire                             tagctl_l2_dirty_tc3_i,
  input wire                             tagctl_l2_alloc_tc3_i,
  input wire [1:0]                       tagctl_shareability_tc3_i,
  input wire                             tagctl_cluster_unique_tc3_i,
  input wire                             tagctl_l2_victim_valid_tc3_i,
  input wire                             tagctl_l2_victim_cu_tc3_i,
  input wire                             tagctl_l2_victim_dirty_tc3_i,
  input wire                             tagctl_l2_victim_alloc_tc3_i,
  input wire [1:0]                       tagctl_l2_victim_shareability_tc3_i,
  input wire [1:0]                       tagctl_snoop_data_cpu_tc4_i,
  input wire                             tagctl_slv_flush_tc1_i,
  input wire                             tagctl_slv_flush_tc2_i,
  input wire                             tagctl_slv_flush_tc3_i,
  input wire                             tagctl_slv_flush_tc4_i,
  input  wire                            tagctl_ecc_err_tc3_i,
  input wire                             afb0_done_i,
  input wire                             afb1_done_i,
  input wire                             afb2_done_i,
  input wire                             afb3_done_i,
  input wire                             afb4_done_i,
  input wire                             afb5_done_i,
  input wire                             afb0_write_done_i,
  input wire                             afb1_write_done_i,
  input wire                             afb2_write_done_i,
  input wire                             afb3_write_done_i,
  input wire                             afb4_write_done_i,
  input wire                             afb5_write_done_i,
  input wire                             afb0_snoop_resp_dirty_i,
  input wire                             afb1_snoop_resp_dirty_i,
  input wire                             afb2_snoop_resp_dirty_i,
  input wire                             afb3_snoop_resp_dirty_i,
  input wire                             afb4_snoop_resp_dirty_i,
  input wire                             afb5_snoop_resp_dirty_i,

  input  wire [41:6]                     tagctl_addr_tc1_i,
  input  wire                            tagctl_addr_valid_tc1_i,
  input  wire                            tagctl_serialising_tc1_i,
  input  wire                            tagctl_l1_lf_tc1_i,
  input  wire [15:0]                     tagctl_ecc_way_tc1_i,
  input  wire                            tagctl_cpu_sync_tc1_i,
  output wire                            snpslv_hz_tc2_o,
  output wire                            snpslv_ecc_hz_tc2_o,
  output wire [15:0]                     snpslv_l2_way_used_tc2_o,
  input  wire [40:6]                     tagctl_addr_tc3_i,
  input  wire                            tagctl_addr_valid_tc3_i,
  output wire                            snpslv_hz_tc4_o,
  output wire                            dvm_comp_sync_outstanding_o,

  // Victimctl hazarding
  input  wire [10:0]                     victimctl_index_vc1_i,
  output wire [15:0]                     snpslv_l2_way_used_vc2_o,

  // CompAck requests
  input  wire                            cpuslv0_compack_active_i,
  input  wire                            cpuslv1_compack_active_i,
  input  wire                            cpuslv2_compack_active_i,
  input  wire                            cpuslv3_compack_active_i,
  input  wire                            acpslv_compack_active_i,
  input  wire                            cpuslv0_compack_valid_i,
  input  wire                            cpuslv1_compack_valid_i,
  input  wire                            cpuslv2_compack_valid_i,
  input  wire                            cpuslv3_compack_valid_i,
  input  wire                            acpslv_compack_valid_i,
  input  wire [6:0]                      cpuslv0_compack_tgtid_i,
  input  wire [6:0]                      cpuslv1_compack_tgtid_i,
  input  wire [6:0]                      cpuslv2_compack_tgtid_i,
  input  wire [6:0]                      cpuslv3_compack_tgtid_i,
  input  wire [6:0]                      acpslv_compack_tgtid_i,
  input  wire [7:0]                      cpuslv0_compack_txnid_i,
  input  wire [7:0]                      cpuslv1_compack_txnid_i,
  input  wire [7:0]                      cpuslv2_compack_txnid_i,
  input  wire [7:0]                      cpuslv3_compack_txnid_i,
  input  wire [7:0]                      acpslv_compack_txnid_i,
  output wire                            snpslv_cpuslv0_compack_ready_o,
  output wire                            snpslv_cpuslv1_compack_ready_o,
  output wire                            snpslv_cpuslv2_compack_ready_o,
  output wire                            snpslv_cpuslv3_compack_ready_o,
  output wire                            snpslv_acpslv_compack_ready_o,

  // Master link control
  output wire                            snpslv_txrsp_req_o,
  output wire                            snpslv_rxsnp_active_o,
  input  wire                            master_rxla_run_i,
  input  wire                            master_rxla_deactivate_i,
  input  wire                            master_rxla_stop_i,
  input  wire                            master_txla_run_i,
  input  wire                            master_txla_deactivate_i,

  // L2DB control
  output wire                            snpslv_l2dbs_active_o,

  output wire                            snpslv_l2db0_invalidate_o,
  output wire                            snpslv_l2db0_makeshared_o,
  output wire                            snpslv_l2db0_transfer_o,
  output wire [2:0]                      snpslv_l2db0_transfer_type_o,
  output wire [28:0]                     snpslv_l2db0_transfer_info_o,
  output wire                            snpslv_l2db0_release_o,

  output wire                            snpslv_l2db1_invalidate_o,
  output wire                            snpslv_l2db1_makeshared_o,
  output wire                            snpslv_l2db1_transfer_o,
  output wire [2:0]                      snpslv_l2db1_transfer_type_o,
  output wire [28:0]                     snpslv_l2db1_transfer_info_o,
  output wire                            snpslv_l2db1_release_o,

  output wire                            snpslv_l2db2_invalidate_o,
  output wire                            snpslv_l2db2_makeshared_o,
  output wire                            snpslv_l2db2_transfer_o,
  output wire [2:0]                      snpslv_l2db2_transfer_type_o,
  output wire [28:0]                     snpslv_l2db2_transfer_info_o,
  output wire                            snpslv_l2db2_release_o,

  output wire                            snpslv_l2db3_invalidate_o,
  output wire                            snpslv_l2db3_makeshared_o,
  output wire                            snpslv_l2db3_transfer_o,
  output wire [2:0]                      snpslv_l2db3_transfer_type_o,
  output wire [28:0]                     snpslv_l2db3_transfer_info_o,
  output wire                            snpslv_l2db3_release_o,

  output wire                            snpslv_l2db4_invalidate_o,
  output wire                            snpslv_l2db4_makeshared_o,
  output wire                            snpslv_l2db4_transfer_o,
  output wire [2:0]                      snpslv_l2db4_transfer_type_o,
  output wire [28:0]                     snpslv_l2db4_transfer_info_o,
  output wire                            snpslv_l2db4_release_o,

  output wire                            snpslv_l2db5_invalidate_o,
  output wire                            snpslv_l2db5_makeshared_o,
  output wire                            snpslv_l2db5_transfer_o,
  output wire [2:0]                      snpslv_l2db5_transfer_type_o,
  output wire [28:0]                     snpslv_l2db5_transfer_info_o,
  output wire                            snpslv_l2db5_release_o,

  output wire                            snpslv_l2db6_invalidate_o,
  output wire                            snpslv_l2db6_makeshared_o,
  output wire                            snpslv_l2db6_transfer_o,
  output wire [2:0]                      snpslv_l2db6_transfer_type_o,
  output wire [28:0]                     snpslv_l2db6_transfer_info_o,
  output wire                            snpslv_l2db6_release_o,

  output wire                            snpslv_l2db7_invalidate_o,
  output wire                            snpslv_l2db7_makeshared_o,
  output wire                            snpslv_l2db7_transfer_o,
  output wire [2:0]                      snpslv_l2db7_transfer_type_o,
  output wire [28:0]                     snpslv_l2db7_transfer_info_o,
  output wire                            snpslv_l2db7_release_o,

  output wire                            snpslv_l2db8_invalidate_o,
  output wire                            snpslv_l2db8_makeshared_o,
  output wire                            snpslv_l2db8_transfer_o,
  output wire [2:0]                      snpslv_l2db8_transfer_type_o,
  output wire [28:0]                     snpslv_l2db8_transfer_info_o,
  output wire                            snpslv_l2db8_release_o,

  output wire                            snpslv_l2db9_invalidate_o,
  output wire                            snpslv_l2db9_makeshared_o,
  output wire                            snpslv_l2db9_transfer_o,
  output wire [2:0]                      snpslv_l2db9_transfer_type_o,
  output wire [28:0]                     snpslv_l2db9_transfer_info_o,
  output wire                            snpslv_l2db9_release_o,

  output wire                            snpslv_l2db10_invalidate_o,
  output wire                            snpslv_l2db10_makeshared_o,
  output wire                            snpslv_l2db10_transfer_o,
  output wire [2:0]                      snpslv_l2db10_transfer_type_o,
  output wire [28:0]                     snpslv_l2db10_transfer_info_o,
  output wire                            snpslv_l2db10_release_o,

  input  wire                            l2db0_slv_done_i,
  input  wire                            l2db1_slv_done_i,
  input  wire                            l2db2_slv_done_i,
  input  wire                            l2db3_slv_done_i,
  input  wire                            l2db4_slv_done_i,
  input  wire                            l2db5_slv_done_i,
  input  wire                            l2db6_slv_done_i,
  input  wire                            l2db7_slv_done_i,
  input  wire                            l2db8_slv_done_i,
  input  wire                            l2db9_slv_done_i,
  input  wire                            l2db10_slv_done_i,

  input  wire                            l2db0_snpslv_done_i,
  input  wire                            l2db1_snpslv_done_i,
  input  wire                            l2db2_snpslv_done_i,
  input  wire                            l2db3_snpslv_done_i,
  input  wire                            l2db4_snpslv_done_i,
  input  wire                            l2db5_snpslv_done_i,
  input  wire                            l2db6_snpslv_done_i,
  input  wire                            l2db7_snpslv_done_i,
  input  wire                            l2db8_snpslv_done_i,
  input  wire                            l2db9_snpslv_done_i,
  input  wire                            l2db10_snpslv_done_i,

  input  wire                            l2db0_slv_err_i,
  input  wire                            l2db1_slv_err_i,
  input  wire                            l2db2_slv_err_i,
  input  wire                            l2db3_slv_err_i,
  input  wire                            l2db4_slv_err_i,
  input  wire                            l2db5_slv_err_i,
  input  wire                            l2db6_slv_err_i,
  input  wire                            l2db7_slv_err_i,
  input  wire                            l2db8_slv_err_i,
  input  wire                            l2db9_slv_err_i,
  input  wire                            l2db10_slv_err_i,

  input  wire                            l2db0_slv_master_arb_i,
  input  wire                            l2db1_slv_master_arb_i,
  input  wire                            l2db2_slv_master_arb_i,
  input  wire                            l2db3_slv_master_arb_i,
  input  wire                            l2db4_slv_master_arb_i,
  input  wire                            l2db5_slv_master_arb_i,
  input  wire                            l2db6_slv_master_arb_i,
  input  wire                            l2db7_slv_master_arb_i,
  input  wire                            l2db8_slv_master_arb_i,
  input  wire                            l2db9_slv_master_arb_i,
  input  wire                            l2db10_slv_master_arb_i,

  input  wire                            ramctl_l2dbs_valid_i,
  input  wire [3:0]                      ramctl_l2dbs_id_i,
  input  wire                            ramctl_l2dbs_last_i,
  input  wire                            ramctl_bypassed_err_i,

  // DVM syncs
  input  wire                            tagctl_snp_sync_tc1_i,
  input  wire                            tagctl_dvm_sync_tc3_i,
  input  wire                            tagctl_snp_dvm_sync_tc4_i,
  input  wire [3:0]                      tagctl_cpu_dvm_sync_tc4_i,

  output wire                            snpslv_sample_waddrs_o,
  input  wire                            master_snpslv_waddrs_valid_i,
  input  wire                            master_snpslv_db_valid_i,
  input  wire                            master_snpslv_dr_valid_i,
  input  wire                            master_rsp_comp_valid_i,
  input  wire [6:0]                      master_rsp_txnid_i,
  input  wire                            master_snpslv_reqbuf_retry_i,
  input  wire [1:0]                      master_snpslv_pcrdtype_i,

  input  wire                            cpuslv0_noncoh_since_barrier_i,
  input  wire                            cpuslv1_noncoh_since_barrier_i,
  input  wire                            cpuslv2_noncoh_since_barrier_i,
  input  wire                            cpuslv3_noncoh_since_barrier_i,
  input  wire                            cpuslv0_dvm_sync_resp_i,
  input  wire                            cpuslv1_dvm_sync_resp_i,
  input  wire                            cpuslv2_dvm_sync_resp_i,
  input  wire                            cpuslv3_dvm_sync_resp_i,
  input  wire                            dcu_cpu0_dvm_complete_i,
  input  wire                            dcu_cpu1_dvm_complete_i,
  input  wire                            dcu_cpu2_dvm_complete_i,
  input  wire                            dcu_cpu3_dvm_complete_i,
  output wire                            scu_cpu0_dvm_complete_o,
  output wire                            scu_cpu1_dvm_complete_o,
  output wire                            scu_cpu2_dvm_complete_o,
  output wire                            scu_cpu3_dvm_complete_o,
  input  wire [3:0]                      tagctl_dvm_complete_i
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam NUM_REQBUFS = 5;
  localparam NUM_FLITQ = 4;
  localparam NUM_CREDITS = NUM_REQBUFS + NUM_FLITQ + 1;
  localparam TXRSP_RR_WIDTH = NUM_CPUS + ACP + 1;
  localparam TXRSP_RR_INCR = 6'b000001;

  genvar i;
  genvar j;

  reg                                   reqbuf_int_clk_enable;
  reg [NUM_REQBUFS+1:0]                 reqbuf_arb_tc1;
  reg [NUM_REQBUFS:0]                   tagctl_prearb_tc0;
  reg                                   snpslv_hz_tc2;
  reg                                   snpslv_ecc_hz_tc2;
  reg [15:0]                            snpslv_l2_way_used_tc2;
  reg [15:0]                            snpslv_l2_way_used_vc2;
  reg                                   snpslv_hz_tc4;
  reg [NUM_L2DBS-1:0]                   l2db_buf_release;
  reg                                   scu_ext_cr_valid;
  reg [4:0]                             scu_ext_cr_resp;
  reg                                   cr_skid_valid;
  reg [4:0]                             cr_skid_resp;
  reg                                   scu_ext_ac_ready;
  reg                                   rxsnpflitpend;
  reg                                   scu_rxsnplcrdv;
  reg                                   ac_ext_valid;
  reg                                   ac_ext_valid_sent;
  reg [3:0]                             ac_snoop;
  reg [43:0]                            ac_addr;
  reg                                   ac_prot;
  reg                                   l2_in_retention;
  reg                                   txrsplcrdv;
  reg [3:0]                             txrsp_credits;
  reg                                   scu_txrspflitpend;
  reg                                   scu_txrspflitv;
  reg [3:0]                             scu_txrspflit_qos;
  reg [6:0]                             scu_txrspflit_tgtid;
  reg [7:0]                             scu_txrspflit_txnid;
  reg [3:0]                             scu_txrspflit_opcode;
  reg [1:0]                             scu_txrspflit_resperr;
  reg [2:0]                             scu_txrspflit_resp;
  reg [6:0]                             reqbufs_l1_ecc_tc0;
  reg [6:0]                             reqbufs_l2_ecc_tc0;
  reg                                   rxsnpflitv;
  reg [3:0]                             rxsnpflit_qos;
  reg [6:0]                             rxsnpflit_srcid;
  reg [7:0]                             rxsnpflit_txnid;
  reg [3:0]                             rxsnpflit_opcode;
  reg [40:0]                            rxsnpflit_addr;
  reg                                   rxsnpflit_ns;
  reg [`CA53_LOG2(NUM_CREDITS)-1:0]     rxsnp_credits;
  reg [3:0]                             rxsnpflitq_qos    [NUM_FLITQ-1:0];
  reg [6:0]                             rxsnpflitq_srcid  [NUM_FLITQ-1:0];
  reg [7:0]                             rxsnpflitq_txnid  [NUM_FLITQ-1:0];
  reg [3:0]                             rxsnpflitq_opcode [NUM_FLITQ-1:0];
  reg [40:0]                            rxsnpflitq_addr   [NUM_FLITQ-1:0];
  reg                                   rxsnpflitq_ns     [NUM_FLITQ-1:0];
  reg [`CA53_LOG2(NUM_FLITQ):0]         rxsnpflitq_head;
  reg [`CA53_LOG2(NUM_FLITQ):0]         rxsnpflitq_tail;
  reg                                   rxsnpflitq_valid;
  reg                                   rxsnpflitq_valid_non_dvm;


  wire                                  clk_reqbufs;
  wire                                  next_reqbuf_int_clk_enable;
  wire                                  reqbuf_clk_enable;
  wire                                  snpslv_hz_tc1;
  wire                                  snpslv_ecc_hz_tc1;
  wire                                  snpslv_hz_tc3;
  wire [15:0]                           snpslv_l2_way_used_tc1;
  wire [15:0]                           snpslv_l2_way_used_vc1;
  wire [NUM_REQBUFS-1:0]                reqbuf_early_alloc;
  wire [NUM_REQBUFS+1:0]                reqbuf_alloc;
  wire [NUM_REQBUFS-1:0]                reqbuf_second_dvm;
  wire [NUM_REQBUFS+1:0]                reqbuf_busy;
  wire [NUM_REQBUFS-1:0]                reqbuf_dvm_part_two;
  wire [`CA53_LOG2(NUM_REQBUFS)-1:0]    reqbuf_alloc_enc;
  wire [NUM_REQBUFS+2:0]                tagctl_arb_tc0;
  wire [NUM_REQBUFS:0]                  tagctl_sel_prearb_tc0;
  wire [NUM_REQBUFS:0]                  reqbuf_update_pass;
  wire [NUM_REQBUFS+1:0]                next_reqbuf_arb_tc1;
  wire [2:0]                            reqbuf_req;
  wire [2:0]                            reqbuf_arb;
  wire                                  reqbuf_arb_en;
  wire                                  reqbuf_arb_tc1_en;
  wire [NUM_REQBUFS-1:0]                l2db_invalidate    [MAX_L2DBS-1:0];
  wire [NUM_REQBUFS-1:0]                l2db_makeshared    [MAX_L2DBS-1:0];
  wire [NUM_REQBUFS:0]                  l2db_transfer      [MAX_L2DBS-1:0];
  wire [2:0]                            l2db_transfer_type [MAX_L2DBS-1:0];
  wire [28:0]                           l2db_transfer_info [MAX_L2DBS-1:0];
  wire [NUM_REQBUFS:0]                  l2db_release       [MAX_L2DBS-1:0];
  wire [NUM_REQBUFS-1:0]                reqbuf_wait_sync;
  wire [NUM_REQBUFS-1:0]                reqbuf_credit_return;
  wire [NUM_REQBUFS-1:0]                reqbuf_credit_ready;
  wire                                  rxsnp_linkflit;
  wire                                  rxsnp_dvmflit;
  wire [NUM_L2DBS-1:0]                  next_l2db_buf_release;
  wire [MAX_L2DBS-1:0]                  snpslv_l2db_release;
  wire [3:0]                            snpslv_tagctl_pass_tc0;
  wire [NUM_REQBUFS*NUM_REQBUFS-1:0]    reqbuf_older_pkd;
  wire                                  tagctl_prearb_en;
  wire [NUM_REQBUFS+1:0]                reqbuf_tagctl_valid_tc0;
  wire [NUM_REQBUFS:0]                  reqbuf_tagctl_prearb_req;
  wire [NUM_REQBUFS:0]                  tagctl_prearb;
  wire [NUM_REQBUFS-1:0]                next_reqbuf_ready;
  wire [NUM_REQBUFS:0]                  reqbuf_hz_tc1;
  wire [NUM_REQBUFS-1:0]                reqbuf_ecc_hz_tc1;
  wire [NUM_REQBUFS:0]                  reqbuf_hz_tc3;
  wire [15:0]                           reqbuf_l2_way_used_tc1      [NUM_REQBUFS:0];
  wire [15:0]                           reqbuf_l2_way_used_vc1      [NUM_REQBUFS:0];
  wire [3:0]                            reqbuf_tagctl_pass_tc0      [NUM_REQBUFS+1:0];
  wire [41:0]                           reqbuf_tagctl_addr1_tc0     [NUM_REQBUFS:0];
  wire [16:0]                           reqbuf_tagctl_wr_state_tc0  [NUM_REQBUFS-1:0];
  wire [40:0]                           reqbuf_addr2                [NUM_REQBUFS:0];
  wire                                  reqbuf_dirty                [NUM_REQBUFS:0];
  wire [31:0]                           reqbuf_tagctl_ways_tc0      [NUM_REQBUFS:0];
  wire [4:0]                            reqbuf_tagctl_write_tc0     [NUM_REQBUFS:0];
  wire [4:0]                            reqbuf_type                 [NUM_REQBUFS+1:0];
  wire                                  reqbuf_l2db_invalidate      [NUM_REQBUFS-1:0];
  wire                                  reqbuf_l2db_makeshared      [NUM_REQBUFS-1:0];
  wire                                  reqbuf_l2db_transfer        [NUM_REQBUFS:0];
  wire [3:0]                            reqbuf_l2db_id              [NUM_REQBUFS:0];
  wire [2:0]                            reqbuf_l2db_transfer_type   [NUM_REQBUFS:0];
  wire [28:0]                           reqbuf_l2db_transfer_info   [NUM_REQBUFS:0];
  wire                                  reqbuf_l2db_release         [NUM_REQBUFS:0];
  wire [7:0]                            reqbuf_attrs                [NUM_REQBUFS+1:0];
  wire                                  reqbuf_cluster_unique;
  wire                                  reqbuf_static_pcredit_tc1;
  wire [1:0]                            reqbuf_pcrdtype_tc1;
  wire [NUM_REQBUFS-1:0]                reqbuf_ramctl_active;
  wire [NUM_REQBUFS:0]                  reqbuf_master_active;
  wire                                  ac_en;
  wire [41:0]                           snpslv_tagctl_addr1_tc0;
  wire                                  ac_ready;
  wire                                  ac_valid_en;
  wire                                  next_ac_ext_valid_sent;
  wire                                  ac_valid;
  wire                                  next_scu_rxsnplcrdv;
  wire                                  next_scu_ext_ac_ready;
  wire [4:0]                            reqbuf_cr_resp_muxed;
  wire [6:0]                            reqbuf_cr_tgtid_muxed;
  wire [7:0]                            reqbuf_cr_txnid_muxed;
  wire [3:0]                            reqbuf_cr_qos_muxed;
  wire [4:0]                            next_scu_ext_cr_resp;
  wire                                  next_scu_ext_cr_valid;
  wire                                  cr_en;
  wire                                  snpslv_tagctl_valid_tc0;
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_valid;
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_active;
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_cancel;
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_ready;
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_arb;
  wire [4:0]                            reqbuf_cr_resp [NUM_REQBUFS-1:0];
  wire [6:0]                            reqbuf_tgtid [NUM_REQBUFS-1:0];
  wire [7:0]                            reqbuf_txnid [NUM_REQBUFS-1:0];
  wire [3:0]                            reqbuf_qos [NUM_REQBUFS-1:0];
  wire [NUM_REQBUFS-1:0]                reqbuf_cr_unsent;
  wire [NUM_REQBUFS-1:0]                reqbuf_cd_unsent;
  wire [NUM_REQBUFS-1:0]                reqbuf_snp_cd_l2db;
  wire                                  cr_skid_en;
  wire                                  next_cr_skid_valid;
  wire                                  snpslv_dvm_complete;
  wire                                  dvmcomp_active;
  wire                                  dvmcomp_start_comp;
  wire [41:0]                           ac_addr_int;
  wire [41:0]                           ac_addr_early;
  wire [41:0]                           ac_addr_dvm_first;
  wire [41:0]                           ac_addr_dvm_second;
  wire [41:0]                           ac_addr_dvm;
  wire                                  ac_valid_non_dvm;
  wire                                  rxsnpflitq_head_non_dvm;
  wire                                  rxsnpflitq_next_non_dvm;
  wire                                  rxsnpflit_opcode_non_dvm;
  wire                                  next_rxsnpflitq_valid_non_dvm;
  wire [9:0]                            dvm_cmd;
  wire                                  invalid_dvm;
  wire                                  reqbuf_available;
  wire                                  dvm_comp_sync_outstanding;
  wire                                  txrsp_credits_en;
  wire [3:0]                            next_txrsp_credits;
  wire                                  txrsp_credit_avail;
  wire                                  scu_txrspflit_en;
  wire                                  next_scu_txrspflitv;
  wire                                  next_scu_txrspflitpend;
  wire                                  compack_active;
  wire [5:0]                            txrsp_req;
  wire [5:0]                            txrsp_comp_arb;
  wire [5:0]                            txrsp_arb;
  wire [6:0]                            next_scu_txrspflit_tgtid;
  wire [7:0]                            next_scu_txrspflit_txnid;
  wire [3:0]                            next_scu_txrspflit_opcode;
  wire [3:0]                            next_scu_txrspflit_qos;
  wire [1:0]                            next_scu_txrspflit_resperr;
  wire [2:0]                            next_scu_txrspflit_resp;
  wire                                  zero;
  wire [40:0]                           reqbufs_prearb_addr;
  wire [`CA53_LOG2(NUM_CREDITS)-1:0]    next_rxsnp_credits;
  wire [`CA53_LOG2(NUM_CREDITS)-1:0]    rxsnp_avail_credits;
  wire                                  rxsnp_credit_incr;
  wire                                  rxsnp_credit_decr;
  wire                                  rxsnp_credits_en;
  wire                                  ac_ext_valid_not_sent;
  wire                                  dvm_part;
  wire                                  sync_bar_completed;
  wire                                  next_rxsnpflitq_valid;
  wire                                  rxsnpflitq_full;
  wire                                  rxsnpflitq_push;
  wire                                  rxsnpflitq_pop;
  wire [NUM_FLITQ-1:0]                  rxsnpflitq_en;
  wire [`CA53_LOG2(NUM_FLITQ):0]        next_rxsnpflitq_head;
  wire [`CA53_LOG2(NUM_FLITQ):0]        next_rxsnpflitq_tail;
  wire [`CA53_LOG2(NUM_FLITQ):0]        rxsnpflitq_credits;
  wire [3:0]                            ac_opcode;
  wire [6:0]                            ac_srcid;
  wire [7:0]                            ac_txnid;
  wire [3:0]                            ac_qos;


  // Tie-off for unused logic.
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  // Avoid clocking the request buffers and response channel if they are all idle.
  assign next_reqbuf_int_clk_enable = (|reqbuf_busy |
                                       ac_valid |
                                       scu_ext_cr_valid |
                                       cr_skid_valid |
                                       tagctl_dvm_sync_tc3_i |
                                       (|tagctl_cpu_dvm_sync_tc4_i) |
                                       dvmcomp_active |
                                       compack_active |
                                       (|txrsp_req) |
                                       rxsnpflitpend |
                                       (rxsnpflitv & ~ac_ext_valid_sent) |
                                       ramctl_ecc_flush_req_i |
                                       ramctl_ecc_flush_active_i |
                                       master_txla_deactivate_i);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    reqbuf_int_clk_enable <= 1'b0;
  end else begin
    reqbuf_int_clk_enable <= next_reqbuf_int_clk_enable;
  end

  assign reqbuf_clk_enable = reqbuf_int_clk_enable | (ACE[0] ? ac_ext_valid : rxsnpflitpend);

  // This gate uses clk_ext_master rather than clk because clk may not be active on the
  // first cycle that a snoop arrives.
  ca53_cell_inter_clkgate u_inter_clkgate_reqbufs (
    .clk_i         (clk_ext_master),
    .clk_enable_i  (reqbuf_clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_reqbufs));

  // The main SCU clock gate must be enabled if there is anything in or entering
  // the request buffers. Responses can also remain after the reqbuf has completed.
  assign snpslv_active_o = (|reqbuf_busy |
                            (ACE[0] ? ac_valid : (rxsnpflitv & ~ac_ext_valid_sent)) |
                            scu_ext_cr_valid |
                            cr_skid_valid |
                            dvmcomp_active |
                            (rxsnpflitpend & ~master_rxla_stop_i) |
                            scu_txrspflitpend |
                            scu_txrspflitv);

  // The external master clock gate must be woken up if there is a change in retention
  // status
  assign snpslv_retention_active_o = l2_in_retention ^ gov_l2_in_retention_i;

  //----------------------------------------------------------------------------
  //  Snoop request channel
  //----------------------------------------------------------------------------

  assign next_ac_ext_valid_sent = (ac_ext_valid_sent |
                                   (ac_ext_valid & ac_ready & ~rxsnpflitq_valid) |
                                   rxsnp_linkflit |
                                   ((|reqbuf_dvm_part_two) & ~rxsnpflitq_valid)) & ~ac_valid_en;

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    ac_ext_valid_sent <= 1'b0;
  end else begin
    ac_ext_valid_sent <= next_ac_ext_valid_sent;
  end

  generate if (ACE) begin : g_snp_req_ace

    assign ac_valid = ac_ext_valid & ~ac_ext_valid_sent;

    assign ac_valid_en = clean_aclken_i & scu_ext_ac_ready;

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      ac_ext_valid <= 1'b0;
    end else if (ac_valid_en) begin
      ac_ext_valid <= scu_ext_ac_valid_i;
    end

    assign ac_en = ac_valid_en & scu_ext_ac_valid_i;

    always @(posedge clk_ext_master)
    if (ac_en) begin
      ac_snoop <= scu_ext_ac_snoop_i;
      ac_addr  <= scu_ext_ac_addr_i;
      ac_prot  <= scu_ext_ac_prot_i[1];
    end

    // The SCU can accept a new request if there will be a request buffer empty, or
    // the interface registers will be empty.
    // If a flush request is in progress then we are a bit more pessimistic about
    // when we can accept a new request, because it is harder to predict if there
    // will be a reqbuf available.
    assign next_scu_ext_ac_ready = ((|next_reqbuf_ready |
                                     (~ac_valid & (|reqbuf_dvm_part_two | ~(scu_ext_ac_valid_i & scu_ext_ac_ready)))) &
                                    ~(inactm_rs_i & ~|reqbuf_busy & ~dvmcomp_active));

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      scu_ext_ac_ready <= 1'b0;
    end else if (clean_aclken_i) begin
      scu_ext_ac_ready <= next_scu_ext_ac_ready;
    end

    assign scu_ext_ac_ready_o = scu_ext_ac_ready;

    // Tell the DVM complete tracking when a complete message is received.
    assign snpslv_dvm_complete = ac_valid & ac_ready & (ac_snoop == `CA53_ACE_DVM_COMPLETE);

    // Compress DVM messages into 41 bits of address for storing internally.
    assign ac_addr_dvm_first  = {1'b0, ac_addr[40:16],
                                 ac_addr[43], ac_addr[14:8],
                                 ac_addr[42], ac_addr[6:2],
                                 ac_addr[41], ac_addr[0]};

    assign ac_addr_dvm_second = {1'b0, ac_addr[40:3], ac_addr[43:41]};

    // Map invalid DVM messages to Hint (i.e. a nop)
    assign dvm_cmd     = {ac_addr_dvm_first[11:8], ac_addr_dvm_first[6:2], ac_addr_dvm_first[0]};
    assign invalid_dvm = (((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_TLBINV) &
                           ~((dvm_cmd == 10'b01_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b01_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b01_10_0_0_1_00_1) |
                             (dvm_cmd == 10'b10_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b10_10_0_0_1_00_1) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_1) |
                             (dvm_cmd == 10'b10_10_0_1_1_00_1) |
                             (dvm_cmd == 10'b10_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_1_00_1) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_1_1_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_0_01_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_10_1) |
                             (dvm_cmd == 10'b10_11_1_0_1_10_1) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_1) |
                             (dvm_cmd == 10'b11_11_0_0_1_00_1))) |
                          ((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_PHYSICINV) &
                           ~((dvm_cmd == 10'b00_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b00_10_1_1_0_00_1) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_1) |
                             (dvm_cmd == 10'b00_11_1_1_0_00_1))) |
                          ((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_VIRTICINV) &
                           ~((dvm_cmd == 10'b00_00_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_1) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_1))) |
                          // Invalid command encodings
                          (ac_addr_dvm_first[14:12] == 3'b101) |
                          (ac_addr_dvm_first[14:12] == 3'b111));

    assign ac_addr_dvm = (|reqbuf_dvm_part_two) ? ac_addr_dvm_second :
                                                  {ac_addr_dvm_first[41:15],
                                                   invalid_dvm ? 3'b110 : ac_addr_dvm_first[14:12],
                                                   ac_addr_dvm_first[11:0]};

    assign ac_valid_non_dvm = ac_valid & ~((ac_snoop == `CA53_ACE_DVM_MESSAGE) |
                                           (ac_snoop == `CA53_ACE_DVM_COMPLETE));

    // Tie-off Skyros signals which have no equivalent in ACE
    assign scu_rxsnplcrdv_o = 1'b0;

    always @*
      begin
        rxsnpflitpend    = zero;
        rxsnpflitv       = zero;
        rxsnpflit_qos    = {4{zero}};
        rxsnpflit_srcid  = {7{zero}};
        rxsnpflit_txnid  = {8{zero}};
        rxsnpflitq_valid = zero;
      end

    assign reqbuf_credit_ready = {NUM_REQBUFS{1'b0}};
    assign ac_srcid            = {7{1'b0}};
    assign ac_txnid            = {8{1'b0}};
    assign ac_qos              = {4{1'b0}};
    assign rxsnp_linkflit      = 1'b0;
    assign rxsnp_dvmflit       = 1'b0;
    assign dvm_part            = 1'b0;
    assign rxsnp_credits_en    = 1'b0;
    assign rxsnpflitq_en       = {NUM_FLITQ{1'b0}};
    assign rxsnpflitq_push     = 1'b0;
    assign rxsnpflitq_pop      = 1'b0;

  end else begin : g_snp_req_skyros

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      rxsnpflitpend <= 1'b0;
    end else if (clean_aclken_i) begin
      rxsnpflitpend <= ext_rxsnpflitpend_i;
    end

    assign ac_valid_en = clean_aclken_i & scu_ext_ac_ready & rxsnpflitpend;
    assign ac_en = ac_valid_en;

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      rxsnpflitv <= 1'b0;
    end else if (ac_valid_en) begin
      rxsnpflitv <= ext_rxsnpflitv_i;
    end

    always @(posedge clk_reqbufs)
    if (ac_valid_en) begin
      rxsnpflit_qos    <= ext_rxsnpflit_i[3:0];
      rxsnpflit_srcid  <= ext_rxsnpflit_i[10:4];
      rxsnpflit_txnid  <= ext_rxsnpflit_i[18:11];
      rxsnpflit_opcode <= ext_rxsnpflit_i[22:19];
      rxsnpflit_addr   <= ext_rxsnpflit_i[63:23];
      rxsnpflit_ns     <= ext_rxsnpflit_i[64];
    end

    assign rxsnpflitq_full  = (rxsnpflitq_head == (rxsnpflitq_tail ^ {1'b1, {`CA53_LOG2(NUM_FLITQ){1'b0}}}));

    assign rxsnpflitq_push = (ac_valid_en & ac_ext_valid & ~ac_ext_valid_sent &
                              ~(ac_ready & ~rxsnpflitq_valid) &
                              ~rxsnp_linkflit &
                              ~((|reqbuf_dvm_part_two) & ~rxsnpflitq_valid));

    assign rxsnpflitq_pop = rxsnpflitq_valid & ac_ready & ~rxsnp_linkflit;

    assign next_rxsnpflitq_head = rxsnpflitq_head + {{`CA53_LOG2(NUM_FLITQ){1'b0}}, 1'b1};
    assign next_rxsnpflitq_tail = rxsnpflitq_tail + {{`CA53_LOG2(NUM_FLITQ){1'b0}}, 1'b1};

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      rxsnpflitq_head <= {(`CA53_LOG2(NUM_FLITQ)+1){1'b0}};
    end else if (rxsnpflitq_pop) begin
      rxsnpflitq_head <= next_rxsnpflitq_head;
    end

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      rxsnpflitq_tail <= {(`CA53_LOG2(NUM_FLITQ)+1){1'b0}};
    end else if (rxsnpflitq_push) begin
      rxsnpflitq_tail <= next_rxsnpflitq_tail;
    end

    assign next_rxsnpflitq_valid = (rxsnpflitq_push |
                                    (rxsnpflitq_valid & ~(rxsnpflitq_pop &
                                                          (next_rxsnpflitq_head == rxsnpflitq_tail))));

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      rxsnpflitq_valid <= 1'b0;
    end else begin
      rxsnpflitq_valid <= next_rxsnpflitq_valid;
    end

    for (i = 0; i < NUM_FLITQ; i = i + 1) begin : g_rxsnpflitq

      assign rxsnpflitq_en[i] = rxsnpflitq_push & (rxsnpflitq_tail[`CA53_LOG2(NUM_FLITQ)-1:0] == i[`CA53_LOG2(NUM_FLITQ)-1:0]);

      always @(posedge clk_reqbufs)
      if (rxsnpflitq_en[i]) begin
        rxsnpflitq_qos[i]    <= rxsnpflit_qos;
        rxsnpflitq_srcid[i]  <= rxsnpflit_srcid;
        rxsnpflitq_txnid[i]  <= rxsnpflit_txnid;
        rxsnpflitq_opcode[i] <= rxsnpflit_opcode;
        rxsnpflitq_addr[i]   <= rxsnpflit_addr;
        rxsnpflitq_ns[i]     <= rxsnpflit_ns;
      end

    end

    always @*
    begin
      ac_ext_valid = rxsnpflitv & (rxsnpflit_opcode != `CA53_SKYROS_SNP_LINKFLIT);
      ac_addr = {rxsnpflitq_valid ? rxsnpflitq_addr[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] : rxsnpflit_addr, 3'b000};
      ac_prot = rxsnpflitq_valid ? rxsnpflitq_ns[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] : rxsnpflit_ns;
    end

    assign ac_srcid = rxsnpflitq_valid ? rxsnpflitq_srcid[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] : rxsnpflit_srcid;
    assign ac_txnid = rxsnpflitq_valid ? rxsnpflitq_txnid[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] : rxsnpflit_txnid;
    assign ac_qos   = rxsnpflitq_valid ? rxsnpflitq_qos[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]]   : rxsnpflit_qos;

    assign ac_opcode = rxsnpflitq_valid ? rxsnpflitq_opcode[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] : rxsnpflit_opcode;

    // Convert to ACE encodings for use in the reqbufs.
    always @*
    case (ac_opcode)
      `CA53_SKYROS_SNP_SHARED:       ac_snoop = `CA53_ACE_READSHARED;
      `CA53_SKYROS_SNP_CLEAN:        ac_snoop = `CA53_ACE_READCLEAN;
      `CA53_SKYROS_SNP_ONCE:         ac_snoop = `CA53_ACE_READONCE;
      `CA53_SKYROS_SNP_UNIQUE:       ac_snoop = `CA53_ACE_READUNIQUE;
      `CA53_SKYROS_SNP_CLEANSHARED:  ac_snoop = `CA53_ACE_CLEANSHARED;
      `CA53_SKYROS_SNP_CLEANINVALID: ac_snoop = `CA53_ACE_CLEANINVALID;
      `CA53_SKYROS_SNP_MAKEINVALID:  ac_snoop = `CA53_ACE_MAKEINVALID;
      `CA53_SKYROS_SNP_DVMOP:        ac_snoop = `CA53_ACE_DVM_MESSAGE;
      default:                       ac_snoop = 4'bxxxx;
    endcase

    assign rxsnpflitq_head_non_dvm = (rxsnpflitq_opcode[rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] != `CA53_SKYROS_SNP_DVMOP);
    assign rxsnpflitq_next_non_dvm = (rxsnpflitq_opcode[next_rxsnpflitq_head[`CA53_LOG2(NUM_FLITQ)-1:0]] != `CA53_SKYROS_SNP_DVMOP);
    assign rxsnpflit_opcode_non_dvm = ac_ext_valid & ~ac_ext_valid_sent & (rxsnpflit_opcode != `CA53_SKYROS_SNP_DVMOP);

    assign next_rxsnpflitq_valid_non_dvm = ((rxsnpflitq_valid &
                                             ~rxsnpflitq_pop)        ? rxsnpflitq_head_non_dvm :
                                            (rxsnpflitq_valid &
                                             (rxsnpflitq_tail !=
                                              next_rxsnpflitq_head)) ? rxsnpflitq_next_non_dvm :
                                                                       rxsnpflit_opcode_non_dvm);

    always @(posedge clk_reqbufs)
    begin
      rxsnpflitq_valid_non_dvm <= next_rxsnpflitq_valid_non_dvm;
    end

    assign ac_valid_non_dvm = rxsnpflitq_valid ? (rxsnpflitq_valid_non_dvm & ~rxsnp_linkflit) : rxsnpflit_opcode_non_dvm;

    // If there is a link flit then don't send the head of the flit queue to
    // ensure that if it is a DVM we don't have to count two credits in the
    // same cycle.
    assign ac_valid = (ac_ext_valid & ~ac_ext_valid_sent) | (rxsnpflitq_valid & ~rxsnp_linkflit);

    // Credit management. Keep a count of all L-credits not in use.
    assign rxsnp_linkflit = (rxsnpflitv & ~ac_ext_valid_sent &
                             (rxsnpflit_opcode == `CA53_SKYROS_SNP_LINKFLIT));

    assign rxsnp_dvmflit = ac_valid & |reqbuf_dvm_part_two;

    assign reqbuf_credit_ready[0] = ~(rxsnp_linkflit | rxsnp_dvmflit);

    for (i = 1; i < NUM_REQBUFS; i = i + 1) begin : g_credit_arb
      assign reqbuf_credit_ready[i] = ~(rxsnp_linkflit | rxsnp_dvmflit) & ~|reqbuf_credit_return[i-1:0];
    end

    assign rxsnp_credit_incr = |reqbuf_credit_return | rxsnp_linkflit | rxsnp_dvmflit;

    assign rxsnp_credit_decr = clean_aclken_i & next_scu_rxsnplcrdv;

    assign next_rxsnp_credits = rxsnp_credits + (rxsnp_credit_decr ? {`CA53_LOG2(NUM_CREDITS){1'b1}} :
                                                                     {{(`CA53_LOG2(NUM_CREDITS)-1){1'b0}}, 1'b1});

    assign rxsnp_credits_en = rxsnp_credit_incr ^ rxsnp_credit_decr;

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      rxsnp_credits <= NUM_CREDITS[`CA53_LOG2(NUM_CREDITS)-1:0];
    end else if (rxsnp_credits_en) begin
      rxsnp_credits <= next_rxsnp_credits;
    end

    assign next_scu_rxsnplcrdv = master_rxla_run_i & |rxsnp_credits;

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      scu_rxsnplcrdv <= 1'b0;
    end else if (clean_aclken_i) begin
      scu_rxsnplcrdv <= next_scu_rxsnplcrdv;
    end

    assign scu_rxsnplcrdv_o = scu_rxsnplcrdv;

    assign rxsnpflitq_credits = (rxsnpflitq_tail - rxsnpflitq_head);

    // We must not delay link deactivation if there are uncompleted snoops, only
    // if there are credits outstanding in the interconnect.
    assign ac_ext_valid_not_sent = ac_ext_valid & ~ac_ext_valid_sent;

    assign rxsnp_avail_credits = (rxsnp_credits +
                                  ac_ext_valid_not_sent +
                                  rxsnpflitq_credits +
                                  reqbuf_busy[4] +
                                  reqbuf_busy[3] +
                                  reqbuf_busy[2] +
                                  reqbuf_busy[1] +
                                  reqbuf_busy[0]);

    assign snpslv_rxsnp_active_o = (rxsnp_avail_credits != NUM_CREDITS[`CA53_LOG2(NUM_CREDITS)-1:0]);

    // We must not clock the interface registers if everything is full. There
    // will not be a new flit because there will not be any credits outstanding.
    always @*
      scu_ext_ac_ready = ~(&reqbuf_busy[NUM_REQBUFS-1:0] & rxsnpflitq_full & ac_ext_valid & ~ac_ext_valid_sent);

    assign scu_ext_ac_ready_o = 1'b0;

    // Tell the DVM complete tracking when a response to a DVM sync is received.
    assign snpslv_dvm_complete = (cpuslv0_dvm_sync_resp_i |
                                  cpuslv1_dvm_sync_resp_i |
                                  cpuslv2_dvm_sync_resp_i |
                                  cpuslv3_dvm_sync_resp_i);

    assign dvm_part = ac_addr[3];

    // Compress DVM messages into 41 bits of address for storing internally.
    assign ac_addr_dvm_first  = {2'b00, ac_addr[37:30], ac_addr[21:14], ac_addr[29:22],
                                 ac_addr[43], ac_addr[13:7], ac_addr[42], ac_addr[5],
                                 ac_addr[6], ac_addr[40], ac_addr[39:38],
                                 ac_addr[41], ac_addr[4]};

    assign ac_addr_dvm_second = {ac_addr[43], ac_addr[39], ac_addr[37:4], 2'b00, ac_addr[38], ac_addr[42:40]};

    // Map invalid DVM messages to Hint (i.e. a nop)
    assign dvm_cmd     = {ac_addr_dvm_first[11:8], ac_addr_dvm_first[6:2], ac_addr_dvm_first[0]};
    assign invalid_dvm = (((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_TLBINV) &
                           ~((dvm_cmd == 10'b01_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b01_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b01_10_0_0_1_00_1) |
                             (dvm_cmd == 10'b10_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b10_10_0_0_1_00_1) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_1) |
                             (dvm_cmd == 10'b10_10_0_1_1_00_1) |
                             (dvm_cmd == 10'b10_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_1_00_1) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_1_1_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_0_01_0) |
                             (dvm_cmd == 10'b10_11_1_0_0_10_1) |
                             (dvm_cmd == 10'b10_11_1_0_1_10_1) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_1) |
                             (dvm_cmd == 10'b11_11_0_0_1_00_1))) |
                          ((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_PHYSICINV) &
                           ~((dvm_cmd == 10'b00_10_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_10_0_0_0_00_1) |
                             (dvm_cmd == 10'b00_10_1_1_0_00_1) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_1) |
                             (dvm_cmd == 10'b00_11_1_1_0_00_1))) |
                          ((ac_addr_dvm_first[14:12] == `CA53_ACE_DVM_VIRTICINV) &
                           ~((dvm_cmd == 10'b00_00_0_0_0_00_0) |
                             (dvm_cmd == 10'b00_11_0_0_0_00_0) |
                             (dvm_cmd == 10'b10_10_0_1_0_00_1) |
                             (dvm_cmd == 10'b10_11_1_0_0_00_0) |
                             (dvm_cmd == 10'b10_11_1_1_0_00_1) |
                             (dvm_cmd == 10'b11_11_0_0_0_00_1))) |
                          // Invalid command encodings
                          (ac_addr_dvm_first[14:12] == 3'b101) |
                          (ac_addr_dvm_first[14:12] == 3'b111));

    assign ac_addr_dvm = dvm_part ? ac_addr_dvm_second :
                                    {ac_addr_dvm_first[41:15],
                                     invalid_dvm ? 3'b110 : ac_addr_dvm_first[14:12],
                                     ac_addr_dvm_first[11:0]};

  end endgenerate

  
  // Non-DVMs compress the upper 4 bits into one bit to indicate zero or not,
  // as we don't care about the exact value if those bits are non-zero.
  assign ac_addr_early = {|ac_addr[43:40], ac_prot, ac_addr[39:0]};

  assign ac_addr_int = (ac_snoop == `CA53_ACE_DVM_MESSAGE) ? ac_addr_dvm : ac_addr_early;

  assign reqbuf_available = ~&reqbuf_busy[NUM_REQBUFS-1:0];

  // The current ac request can be moved out of the interface registers if
  // there is a reqbuf to accept it, and a flush request doesn't have higher
  // priority.
  assign ac_ready = |reqbuf_dvm_part_two | reqbuf_available;

  //----------------------------------------------------------------------------
  //  Snoop response channel
  //----------------------------------------------------------------------------

  assign reqbuf_cr_resp_muxed = (({5{reqbuf_cr_arb[4]}} & reqbuf_cr_resp[4]) |
                                 ({5{reqbuf_cr_arb[3]}} & reqbuf_cr_resp[3]) |
                                 ({5{reqbuf_cr_arb[2]}} & reqbuf_cr_resp[2]) |
                                 ({5{reqbuf_cr_arb[1]}} & reqbuf_cr_resp[1]) |
                                 ({5{reqbuf_cr_arb[0]}} & reqbuf_cr_resp[0]));

  generate if (ACE) begin : g_snp_rsp_ace

    // For ACE, only one reqbuf will be asking to send a response.
    assign reqbuf_cr_arb = reqbuf_cr_valid & ~reqbuf_cr_cancel;

    assign reqbuf_cr_ready = reqbuf_cr_arb & {NUM_REQBUFS{~cr_skid_valid}};

    assign next_scu_ext_cr_valid = (((|reqbuf_cr_arb | cr_skid_valid) & ~|reqbuf_snp_cd_l2db) |
                                    (scu_ext_cr_valid & ~scu_ext_cr_ready_i));

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      scu_ext_cr_valid <= 1'b0;
    end else if (clean_aclken_i) begin
      scu_ext_cr_valid <= next_scu_ext_cr_valid;
    end

    assign cr_en = (clean_aclken_i &
                    (scu_ext_cr_ready_i | ~scu_ext_cr_valid) &
                    (|reqbuf_cr_arb | cr_skid_valid) &
                    ~|reqbuf_snp_cd_l2db);

    assign next_scu_ext_cr_resp = cr_skid_valid ? cr_skid_resp : reqbuf_cr_resp_muxed;

    always @(posedge clk_reqbufs)
    if (cr_en) begin
      scu_ext_cr_resp <= next_scu_ext_cr_resp;
    end

    assign scu_ext_cr_valid_o = scu_ext_cr_valid;
    assign scu_ext_cr_resp_o = scu_ext_cr_resp;

    // The skid buffer holds one response if the external interface cannot accept
    // it, in order to decouple the timing on scu_ext_cr_ready_i.
    assign next_cr_skid_valid = (|reqbuf_cr_arb | cr_skid_valid) & ~cr_en;

    always @(posedge clk_reqbufs or negedge reset_n)
    if (~reset_n) begin
      cr_skid_valid <= 1'b0;
    end else begin
      cr_skid_valid <= next_cr_skid_valid;
    end

    assign cr_skid_en = (|reqbuf_cr_arb & ~cr_skid_valid) & ~cr_en;

    always @(posedge clk_reqbufs)
    if (cr_skid_en) begin
      cr_skid_resp <= reqbuf_cr_resp_muxed;
    end

    assign scu_txrspflitpend_o = 1'b0;
    assign scu_txrspflitv_o = 1'b0;
    assign scu_txrspflit_o = {45{1'b0}};
    assign txrsp_credits_en = 1'b0; 
    assign next_scu_txrspflitv = 1'b0;
    assign scu_txrspflit_en = 1'b0;
    assign txrsp_req = {6{1'b0}};
    assign compack_active = 1'b0;

    assign snpslv_acpslv_compack_ready_o  = 1'b0;
    assign snpslv_cpuslv0_compack_ready_o = 1'b0;
    assign snpslv_cpuslv1_compack_ready_o = 1'b0;
    assign snpslv_cpuslv2_compack_ready_o = 1'b0;
    assign snpslv_cpuslv3_compack_ready_o = 1'b0;
    assign snpslv_txrsp_req_o = 1'b0;
    assign snpslv_rxsnp_active_o = 1'b0;

    always @*
    begin
      scu_txrspflitpend = zero;
      scu_txrspflitv = zero;
    end

  end else begin : g_snp_rsp_skyros

    // Credit management. Keep a count of all L-credits received, and not yet used.

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      txrsplcrdv <= 1'b0;
    end else if (clean_aclken_i) begin
      txrsplcrdv <= ext_txrsplcrdv_i;
    end

    assign txrsp_credits_en = clean_aclken_i & (txrsplcrdv ^ next_scu_txrspflitv);

    assign next_txrsp_credits = txrsplcrdv ? (txrsp_credits + 4'b0001) : (txrsp_credits - 4'b0001);

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      txrsp_credits <= 4'b0000;
    end else if (txrsp_credits_en) begin
      txrsp_credits <= next_txrsp_credits;
    end

    assign txrsp_credit_avail = ((|txrsp_credits | txrsplcrdv) &
                                 master_txla_run_i & ~master_rxla_deactivate_i &
                                 scu_txrspflitpend) & clean_aclken_i;

    // Response arbitration. The oldest reqbuf wanting to make a response is
    // arbitrated with any compack request.
    for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_cr_arb
      assign reqbuf_cr_arb[i] = reqbuf_cr_valid[i] & ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] & reqbuf_cr_valid);
    end

    assign compack_active = (cpuslv3_compack_active_i |
                             cpuslv2_compack_active_i |
                             cpuslv1_compack_active_i |
                             cpuslv0_compack_active_i |
                             acpslv_compack_active_i);

    assign txrsp_req = ACP ? {cpuslv3_compack_valid_i,
                              cpuslv2_compack_valid_i,
                              cpuslv1_compack_valid_i,
                              cpuslv0_compack_valid_i,
                              acpslv_compack_valid_i,
                              |reqbuf_cr_valid} :
                             {1'b0,
                              cpuslv3_compack_valid_i,
                              cpuslv2_compack_valid_i,
                              cpuslv1_compack_valid_i,
                              cpuslv0_compack_valid_i,
                              |reqbuf_cr_valid};

    // Round robin counter for selecting between requests.
    ca53_rr_reg_arb #(.WIDTH(TXRSP_RR_WIDTH)) u_txreq_arb (
      .clk          (clk_reqbufs),
      .reset_n      (reset_n),
      .enable_i     (scu_txrspflit_en),
      .requests_i   (txrsp_req[TXRSP_RR_WIDTH-1:0]),
      .arb_o        (txrsp_comp_arb[TXRSP_RR_WIDTH-1:0])
    );

    for (i = TXRSP_RR_WIDTH; i < 6; i = i + 1) begin : g_txrsp_arb
      assign txrsp_comp_arb[i] = 1'b0;
    end

    assign txrsp_arb = ACP ? txrsp_comp_arb : {txrsp_comp_arb[4:1], 1'b0, txrsp_comp_arb[0]};

    assign reqbuf_cr_ready = reqbuf_cr_arb & {NUM_REQBUFS{txrsp_arb[0] & txrsp_credit_avail}};

    assign snpslv_acpslv_compack_ready_o  = txrsp_arb[1] & txrsp_credit_avail;
    assign snpslv_cpuslv0_compack_ready_o = txrsp_arb[2] & txrsp_credit_avail;
    assign snpslv_cpuslv1_compack_ready_o = txrsp_arb[3] & txrsp_credit_avail;
    assign snpslv_cpuslv2_compack_ready_o = txrsp_arb[4] & txrsp_credit_avail;
    assign snpslv_cpuslv3_compack_ready_o = txrsp_arb[5] & txrsp_credit_avail;

    // Tell the master that we need the link to be active.
    assign snpslv_txrsp_req_o = |reqbuf_cr_valid;

    assign next_scu_txrspflitpend = (master_txla_deactivate_i |
                                     (master_txla_run_i & (|reqbuf_cr_valid |
                                                           (|reqbuf_cr_active) |
                                                           compack_active)));

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      scu_txrspflitpend <= 1'b0;
    end else if (clean_aclken_i) begin
      scu_txrspflitpend <= next_scu_txrspflitpend;
    end

    assign scu_txrspflitpend_o = scu_txrspflitpend;

    assign next_scu_txrspflitv = ((|txrsp_req & ~(txrsp_arb[0] & |(reqbuf_cr_arb & reqbuf_cr_cancel)) & txrsp_credit_avail) |
                                  (master_txla_deactivate_i & |txrsp_credits & scu_txrspflitpend));

    always @(posedge clk_ext_master or negedge reset_n)
    if (~reset_n) begin
      scu_txrspflitv <= 1'b0;
    end else if (clean_aclken_i) begin
      scu_txrspflitv <= next_scu_txrspflitv;
    end

    assign scu_txrspflitv_o = scu_txrspflitv;

    assign reqbuf_cr_tgtid_muxed = (({7{reqbuf_cr_arb[4]}} & reqbuf_tgtid[4]) |
                                    ({7{reqbuf_cr_arb[3]}} & reqbuf_tgtid[3]) |
                                    ({7{reqbuf_cr_arb[2]}} & reqbuf_tgtid[2]) |
                                    ({7{reqbuf_cr_arb[1]}} & reqbuf_tgtid[1]) |
                                    ({7{reqbuf_cr_arb[0]}} & reqbuf_tgtid[0]));

    assign next_scu_txrspflit_tgtid = (({7{txrsp_arb[0]}} & reqbuf_cr_tgtid_muxed) |
                                       ({7{txrsp_arb[1]}} &  acpslv_compack_tgtid_i) |
                                       ({7{txrsp_arb[2]}} & cpuslv0_compack_tgtid_i) |
                                       ({7{txrsp_arb[3]}} & cpuslv1_compack_tgtid_i) |
                                       ({7{txrsp_arb[4]}} & cpuslv2_compack_tgtid_i) |
                                       ({7{txrsp_arb[5]}} & cpuslv3_compack_tgtid_i));

    assign reqbuf_cr_txnid_muxed = (({8{reqbuf_cr_arb[4]}} & reqbuf_txnid[4]) |
                                    ({8{reqbuf_cr_arb[3]}} & reqbuf_txnid[3]) |
                                    ({8{reqbuf_cr_arb[2]}} & reqbuf_txnid[2]) |
                                    ({8{reqbuf_cr_arb[1]}} & reqbuf_txnid[1]) |
                                    ({8{reqbuf_cr_arb[0]}} & reqbuf_txnid[0]));

    assign next_scu_txrspflit_txnid = (master_txla_deactivate_i ? 8'h00 :
                                       (({8{txrsp_arb[0]}} & reqbuf_cr_txnid_muxed) |
                                        ({8{txrsp_arb[1]}} &  acpslv_compack_txnid_i) |
                                        ({8{txrsp_arb[2]}} & cpuslv0_compack_txnid_i) |
                                        ({8{txrsp_arb[3]}} & cpuslv1_compack_txnid_i) |
                                        ({8{txrsp_arb[4]}} & cpuslv2_compack_txnid_i) |
                                        ({8{txrsp_arb[5]}} & cpuslv3_compack_txnid_i)));

    assign reqbuf_cr_qos_muxed = (({4{reqbuf_cr_arb[4]}} & reqbuf_qos[4]) |
                                  ({4{reqbuf_cr_arb[3]}} & reqbuf_qos[3]) |
                                  ({4{reqbuf_cr_arb[2]}} & reqbuf_qos[2]) |
                                  ({4{reqbuf_cr_arb[1]}} & reqbuf_qos[1]) |
                                  ({4{reqbuf_cr_arb[0]}} & reqbuf_qos[0]));

    assign next_scu_txrspflit_qos = (master_txla_deactivate_i ? 4'h0 :
                                     ({4{txrsp_arb[0]}} & reqbuf_cr_qos_muxed));

    assign next_scu_txrspflit_opcode = (master_txla_deactivate_i ? `CA53_SKYROS_RSP_LINKFLIT :
                                        txrsp_arb[0]             ? `CA53_SKYROS_RSP_SNPRESP :
                                                                   `CA53_SKYROS_RSP_COMPACK);

    assign next_scu_txrspflit_resperr = {2{txrsp_arb[0]}} & reqbuf_cr_resp_muxed[1:0];
    assign next_scu_txrspflit_resp    = {3{txrsp_arb[0]}} & reqbuf_cr_resp_muxed[4:2];

    assign scu_txrspflit_en = clean_aclken_i & next_scu_txrspflitv;

    always @(posedge clk)
    if (scu_txrspflit_en) begin
      scu_txrspflit_qos     <= next_scu_txrspflit_qos;
      scu_txrspflit_tgtid   <= next_scu_txrspflit_tgtid;
      scu_txrspflit_txnid   <= next_scu_txrspflit_txnid;
      scu_txrspflit_opcode  <= next_scu_txrspflit_opcode;
      scu_txrspflit_resperr <= next_scu_txrspflit_resperr;
      scu_txrspflit_resp    <= next_scu_txrspflit_resp;
    end

    assign scu_txrspflit_o = {2'b00,
                              8'h00,
                              scu_txrspflit_resp,
                              scu_txrspflit_resperr,
                              scu_txrspflit_opcode,
                              scu_txrspflit_txnid,
                              config_nodeid_i,
                              scu_txrspflit_tgtid,
                              scu_txrspflit_qos};

    assign scu_ext_cr_valid_o = 1'b0;
    assign scu_ext_cr_resp_o = {5{1'b0}};
    assign cr_en = 1'b0;
    assign cr_skid_en = 1'b0;
  
    always @*
    begin
      cr_skid_valid = zero;
      scu_ext_cr_valid = zero;
    end

  end endgenerate

  //----------------------------------------------------------------------------
  //  Request buffer control
  //----------------------------------------------------------------------------

  // Select the lowest unused reqbuf to allocate for a new request.
  assign reqbuf_early_alloc[0] = ac_valid & ~reqbuf_busy[0];
  assign reqbuf_early_alloc[1] = ac_valid & ~reqbuf_busy[1] &   reqbuf_busy[0];
  assign reqbuf_early_alloc[2] = ac_valid & ~reqbuf_busy[2] & (&reqbuf_busy[1:0]);
  assign reqbuf_early_alloc[3] = ac_valid & ~reqbuf_busy[3] & (&reqbuf_busy[2:0]);
  assign reqbuf_early_alloc[4] = ac_valid & ~reqbuf_busy[4] & (&reqbuf_busy[3:0]);

  assign reqbuf_alloc[4:0] = reqbuf_early_alloc & ~{5{|reqbuf_dvm_part_two}};
  assign reqbuf_alloc[5] = ramctl_ecc_flush_req_i & ~reqbuf_busy[5];
  assign reqbuf_alloc[6] = dvmcomp_start_comp & ~reqbuf_busy[6];

  // Tell the master that a barrier is starting, and so it must take a snapshot
  // of the outstanding waddrs.
  assign snpslv_sample_waddrs_o = reqbuf_alloc[6];

  assign reqbuf_alloc_enc = {reqbuf_alloc[4],
                             |reqbuf_alloc[3:2],
                             |{reqbuf_alloc[3], reqbuf_alloc[1]}};

  assign reqbuf_second_dvm = {NUM_REQBUFS{ac_valid}} & reqbuf_dvm_part_two;

  // Keep track of the order in which reqbufs were allocated.
  ca53scu_buf_age #(.NUM_BUFS(NUM_REQBUFS)) u_reqbuf_age (
    .clk         (clk_reqbufs),
    .reset_n     (reset_n),
    .buf_alloc_i (reqbuf_alloc[NUM_REQBUFS-1:0]),
    .buf_older_o (reqbuf_older_pkd)
  );

  // Tagctl request arbitration. The oldest serialised reqbuf making a request
  // is always granted. If no serialised reqbuf is requesting, then the oldest
  // non-serialised reqbuf is granted. If no reqbuf is requesting, then any new
  // request is granted priority, unless it is a DVM which may need to wait for
  // the second part of a 2 part DVM.
  assign snpslv_tagctl_valid_tc0 = ((|reqbuf_tagctl_valid_tc0 |
                                     (ac_valid_non_dvm & reqbuf_available)) &
                                    ~l2_in_retention);

  assign snpslv_tagctl_valid_tc0_o = snpslv_tagctl_valid_tc0;
  assign snpslv_tagctl_early_valid_tc0_o = snpslv_tagctl_valid_tc0;
  assign snpslv_tagctl_spec_valid_tc0_o = 1'b0;
  assign snpslv_tagctl_active_tc0_o = ac_ext_valid;

  generate for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_tagctl_prearb
    assign tagctl_prearb[i] = (reqbuf_tagctl_prearb_req[i] &
                               ~reqbuf_tagctl_prearb_req[NUM_REQBUFS] &
                               ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                  reqbuf_tagctl_prearb_req[NUM_REQBUFS-1:0]));
  end endgenerate

  assign tagctl_prearb[NUM_REQBUFS] = reqbuf_tagctl_prearb_req[NUM_REQBUFS];

  assign tagctl_prearb_en = |(tagctl_prearb_tc0 & reqbuf_update_pass) | (|tagctl_prearb);

  // The prearb register keeps a cache of the last prearbitrated reqbuf. If that
  // request is flushed while in tagctl then we must not let a non-serialised
  // request get rearbitrated for tagctl before the serialised one (because the
  // unserialised request could be the one causing the flush).
  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    tagctl_prearb_tc0 <= {(NUM_REQBUFS+1){1'b0}};
  end else if (tagctl_prearb_en) begin
    tagctl_prearb_tc0 <= tagctl_prearb;
  end

  generate for (i = 0; i <= NUM_REQBUFS; i = i + 1) begin : g_tagctl_prearb_tc0
    assign tagctl_sel_prearb_tc0[i] = reqbuf_tagctl_valid_tc0[i] & tagctl_prearb_tc0[i];
  end endgenerate

  generate for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_tagctl_arb
    assign tagctl_arb_tc0[i] = (reqbuf_arb[0] &
                                (tagctl_sel_prearb_tc0[i] |
                                 (reqbuf_tagctl_valid_tc0[i] &
                                  ~|tagctl_sel_prearb_tc0 &
                                  ~|(reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS] &
                                     reqbuf_tagctl_valid_tc0[NUM_REQBUFS-1:0]))));
  end endgenerate

  // Arbitrate between DVM complete and other snoops. We cannot just give
  // highest priority to DVM completes because they need to make a master
  // request and so might get repeatedly flushed if there is no AFB available
  // to make the request.
  assign reqbuf_req = {reqbuf_tagctl_valid_tc0[NUM_REQBUFS+1:NUM_REQBUFS], |reqbuf_tagctl_valid_tc0[NUM_REQBUFS-1:0]};

  assign reqbuf_arb_en = (&reqbuf_req[2:1] | (|reqbuf_req[2:1] & reqbuf_req[0])) & tagctl_snpslv_ready_tc0_i;

  ca53_rr_reg_arb #(.WIDTH(3)) u_reqbuf_arb (
    .clk        (clk),
    .reset_n    (reset_n),
    .enable_i   (reqbuf_arb_en),
    .requests_i (reqbuf_req),
    .arb_o      (reqbuf_arb)
  );

  assign tagctl_arb_tc0[NUM_REQBUFS]   = reqbuf_arb[1] | (reqbuf_arb[0] & tagctl_sel_prearb_tc0[NUM_REQBUFS]);
  assign tagctl_arb_tc0[NUM_REQBUFS+1] = reqbuf_arb[2];
  assign tagctl_arb_tc0[NUM_REQBUFS+2] = ~|reqbuf_req;


  assign snpslv_tagctl_reqbufid_tc0_o = (({3{tagctl_arb_tc0[7]}} & reqbuf_alloc_enc) |
                                         ({3{tagctl_arb_tc0[6]}} & 3'b110) |
                                         ({3{tagctl_arb_tc0[5]}} & 3'b101) |
                                         ({3{tagctl_arb_tc0[4]}} & 3'b100) |
                                         ({3{tagctl_arb_tc0[3]}} & 3'b011) |
                                         ({3{tagctl_arb_tc0[2]}} & 3'b010) |
                                         ({3{tagctl_arb_tc0[1]}} & 3'b001) |
                                         ({3{tagctl_arb_tc0[0]}} & 3'b000));

  assign snpslv_tagctl_pass_tc0 = (({4{tagctl_arb_tc0[6]}} & reqbuf_tagctl_pass_tc0[6]) |
                                   ({4{tagctl_arb_tc0[5]}} & reqbuf_tagctl_pass_tc0[5]) |
                                   ({4{tagctl_arb_tc0[4]}} & reqbuf_tagctl_pass_tc0[4]) |
                                   ({4{tagctl_arb_tc0[3]}} & reqbuf_tagctl_pass_tc0[3]) |
                                   ({4{tagctl_arb_tc0[2]}} & reqbuf_tagctl_pass_tc0[2]) |
                                   ({4{tagctl_arb_tc0[1]}} & reqbuf_tagctl_pass_tc0[1]) |
                                   ({4{tagctl_arb_tc0[0]}} & reqbuf_tagctl_pass_tc0[0]));

  assign snpslv_tagctl_pass_tc0_o = snpslv_tagctl_pass_tc0;

  assign snpslv_tagctl_addr1_tc0 = (({42{tagctl_arb_tc0[7]}} & ac_addr_early) |
                                    ({42{tagctl_arb_tc0[5]}} & reqbuf_tagctl_addr1_tc0[5]) |
                                    ({42{tagctl_arb_tc0[4]}} & reqbuf_tagctl_addr1_tc0[4]) |
                                    ({42{tagctl_arb_tc0[3]}} & reqbuf_tagctl_addr1_tc0[3]) |
                                    ({42{tagctl_arb_tc0[2]}} & reqbuf_tagctl_addr1_tc0[2]) |
                                    ({42{tagctl_arb_tc0[1]}} & reqbuf_tagctl_addr1_tc0[1]) |
                                    ({42{tagctl_arb_tc0[0]}} & reqbuf_tagctl_addr1_tc0[0]));

  assign snpslv_tagctl_addr1_tc0_o = snpslv_tagctl_addr1_tc0;

  assign snpslv_tagctl_dvm_sync_tc0_o = ((tagctl_arb_tc0[4] & (reqbuf_addr2[4][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[3] & (reqbuf_addr2[3][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[2] & (reqbuf_addr2[2][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[1] & (reqbuf_addr2[1][14:12] == `CA53_ACE_DVM_SYNC)) |
                                         (tagctl_arb_tc0[0] & (reqbuf_addr2[0][14:12] == `CA53_ACE_DVM_SYNC)));

  assign snpslv_tagctl_wr_state_tc0_o = (({17{tagctl_arb_tc0[4]}} & reqbuf_tagctl_wr_state_tc0[4]) |
                                         ({17{tagctl_arb_tc0[3]}} & reqbuf_tagctl_wr_state_tc0[3]) |
                                         ({17{tagctl_arb_tc0[2]}} & reqbuf_tagctl_wr_state_tc0[2]) |
                                         ({17{tagctl_arb_tc0[1]}} & reqbuf_tagctl_wr_state_tc0[1]) |
                                         ({17{tagctl_arb_tc0[0]}} & reqbuf_tagctl_wr_state_tc0[0]));

  assign reqbufs_prearb_addr = (({41{tagctl_prearb[5]}} & reqbuf_tagctl_addr1_tc0[5][40:0]) |
                                ({41{tagctl_prearb[4]}} & reqbuf_tagctl_addr1_tc0[4][40:0]) |
                                ({41{tagctl_prearb[3]}} & reqbuf_tagctl_addr1_tc0[3][40:0]) |
                                ({41{tagctl_prearb[2]}} & reqbuf_tagctl_addr1_tc0[2][40:0]) |
                                ({41{tagctl_prearb[1]}} & reqbuf_tagctl_addr1_tc0[1][40:0]) |
                                ({41{tagctl_prearb[0]}} & reqbuf_tagctl_addr1_tc0[0][40:0]));

  // Calculate the ECC bits for writing to the tag RAMs. Writes can only come
  // from the reqbufs, so no need to factor the new BIU request in. The L2, and
  // most of the L1 calcuations are done based on the prearbitrated address, the
  // cycle before tc0, as there is not time in tc0 to do the arbitration and ECC
  // generation.
  generate if (SCU_CACHE_PROTECTION) begin : g_scu_ecc
    wire [4:0]  reqbufs_prearb_l2_wr_state;
    wire [32:0] reqbufs_prearb_l2_data;
    wire [6:0]  next_reqbufs_l2_ecc_tc0;

    assign reqbufs_prearb_l2_wr_state = (({5{tagctl_prearb[4]}} & reqbuf_tagctl_wr_state_tc0[4][16:12]) |
                                         ({5{tagctl_prearb[3]}} & reqbuf_tagctl_wr_state_tc0[3][16:12]) |
                                         ({5{tagctl_prearb[2]}} & reqbuf_tagctl_wr_state_tc0[2][16:12]) |
                                         ({5{tagctl_prearb[1]}} & reqbuf_tagctl_wr_state_tc0[1][16:12]) |
                                         ({5{tagctl_prearb[0]}} & reqbuf_tagctl_wr_state_tc0[0][16:12]));

    assign reqbufs_prearb_l2_data = {reqbufs_prearb_l2_wr_state,
                                     reqbufs_prearb_addr[40:17],
                                     reqbufs_prearb_addr[16:13] & ~config_l2_size_i};

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
  end endgenerate

  // For the L1 tags, the value being written is the same for all CPUs.
  generate if (CPU_CACHE_PROTECTION) begin : g_cpu_ecc
    wire [2:0]  reqbufs_prearb_l1_wr_state;
    wire [32:0] reqbufs_l1_prearb_addr;
    wire [6:0]  next_reqbufs_l1_ecc_tc0;

    assign reqbufs_prearb_l1_wr_state = (({3{tagctl_prearb[4]}} & reqbuf_tagctl_wr_state_tc0[4][2:0]) |
                                         ({3{tagctl_prearb[3]}} & reqbuf_tagctl_wr_state_tc0[3][2:0]) |
                                         ({3{tagctl_prearb[2]}} & reqbuf_tagctl_wr_state_tc0[2][2:0]) |
                                         ({3{tagctl_prearb[1]}} & reqbuf_tagctl_wr_state_tc0[1][2:0]) |
                                         ({3{tagctl_prearb[0]}} & reqbuf_tagctl_wr_state_tc0[0][2:0]));

    assign reqbufs_l1_prearb_addr = {reqbufs_prearb_l1_wr_state,
                                     reqbufs_prearb_addr[40:14],
                                     reqbufs_prearb_addr[13:11] & ~config_l1_dc_size_i};

    ca53_ecc_generate33 u_ecc_generate (
      .data_i (reqbufs_l1_prearb_addr),
      .ecc_o  (next_reqbufs_l1_ecc_tc0)
    );


    always @(posedge clk_reqbufs)
    if (tagctl_prearb_en) begin
      reqbufs_l1_ecc_tc0 <= next_reqbufs_l1_ecc_tc0;
    end

  end else begin : g_n_cpu_ecc
    always @*
      reqbufs_l1_ecc_tc0 = {7{zero}};
  end endgenerate

  assign snpslv_tagctl_ecc_tc0_o = {reqbufs_l2_ecc_tc0, {4{reqbufs_l1_ecc_tc0}}};

  assign snpslv_tagctl_ways_tc0_o = (({32{tagctl_arb_tc0[7]}} & {32{1'b1}}) |
                                     ({32{tagctl_arb_tc0[5]}} & reqbuf_tagctl_ways_tc0[5]) |
                                     ({32{tagctl_arb_tc0[4]}} & reqbuf_tagctl_ways_tc0[4]) |
                                     ({32{tagctl_arb_tc0[3]}} & reqbuf_tagctl_ways_tc0[3]) |
                                     ({32{tagctl_arb_tc0[2]}} & reqbuf_tagctl_ways_tc0[2]) |
                                     ({32{tagctl_arb_tc0[1]}} & reqbuf_tagctl_ways_tc0[1]) |
                                     ({32{tagctl_arb_tc0[0]}} & reqbuf_tagctl_ways_tc0[0]));

  // No requests write the tag on their first pass.
  assign snpslv_tagctl_write_tc0_o = (({5{tagctl_arb_tc0[5]}} & reqbuf_tagctl_write_tc0[5]) |
                                      ({5{tagctl_arb_tc0[4]}} & reqbuf_tagctl_write_tc0[4]) |
                                      ({5{tagctl_arb_tc0[3]}} & reqbuf_tagctl_write_tc0[3]) |
                                      ({5{tagctl_arb_tc0[2]}} & reqbuf_tagctl_write_tc0[2]) |
                                      ({5{tagctl_arb_tc0[1]}} & reqbuf_tagctl_write_tc0[1]) |
                                      ({5{tagctl_arb_tc0[0]}} & reqbuf_tagctl_write_tc0[0]));

  assign snpslv_tagctl_type_tc0_o = (({5{tagctl_arb_tc0[7]}} & {1'b0, ac_snoop}) |
                                     ({5{tagctl_arb_tc0[6]}} & reqbuf_type[6]) |
                                     ({5{tagctl_arb_tc0[5]}} & reqbuf_type[5]) |
                                     ({5{tagctl_arb_tc0[4]}} & reqbuf_type[4]) |
                                     ({5{tagctl_arb_tc0[3]}} & reqbuf_type[3]) |
                                     ({5{tagctl_arb_tc0[2]}} & reqbuf_type[2]) |
                                     ({5{tagctl_arb_tc0[1]}} & reqbuf_type[1]) |
                                     ({5{tagctl_arb_tc0[0]}} & reqbuf_type[0]));

  // Many of the attributes are not required in tc0, so register the
  // arbitration then send them in tc1 which is less timing critical.
  assign next_reqbuf_arb_tc1 = ((tagctl_arb_tc0[NUM_REQBUFS+2] ? {2'b00, reqbuf_alloc[NUM_REQBUFS-1:0]} :
                                                                 tagctl_arb_tc0[NUM_REQBUFS+1:0]) &
                                {(NUM_REQBUFS+2){tagctl_snpslv_ready_tc0_i}});

  // The TC1 arbitration result must be cleared if nothing is arbitrated, so
  // that the reqbufs can work out if they are in TC0 or TC1.
  assign reqbuf_arb_tc1_en = (|reqbuf_arb_tc1 |
                              snpslv_tagctl_valid_tc0);

  always @(posedge clk_reqbufs or negedge reset_n)
  if (~reset_n) begin
    reqbuf_arb_tc1 <= {(NUM_REQBUFS+2){1'b0}};
  end else if (reqbuf_arb_tc1_en) begin
    reqbuf_arb_tc1 <= next_reqbuf_arb_tc1;
  end


  // Send the remaining information to tagctl in TC1
  assign snpslv_tagctl_addr2_tc1_o = (({41{reqbuf_arb_tc1[5]}} & reqbuf_addr2[5]) |
                                      ({41{reqbuf_arb_tc1[4]}} & reqbuf_addr2[4]) |
                                      ({41{reqbuf_arb_tc1[3]}} & reqbuf_addr2[3]) |
                                      ({41{reqbuf_arb_tc1[2]}} & reqbuf_addr2[2]) |
                                      ({41{reqbuf_arb_tc1[1]}} & reqbuf_addr2[1]) |
                                      ({41{reqbuf_arb_tc1[0]}} & reqbuf_addr2[0]));

  assign snpslv_tagctl_attrs_tc1_o = (({8{reqbuf_arb_tc1[6]}} & reqbuf_attrs[6]) |
                                      ({8{reqbuf_arb_tc1[5]}} & reqbuf_attrs[5]) |
                                      ({8{reqbuf_arb_tc1[4]}} & reqbuf_attrs[4]) |
                                      ({8{reqbuf_arb_tc1[3]}} & reqbuf_attrs[3]) |
                                      ({8{reqbuf_arb_tc1[2]}} & reqbuf_attrs[2]) |
                                      ({8{reqbuf_arb_tc1[1]}} & reqbuf_attrs[1]) |
                                      ({8{reqbuf_arb_tc1[0]}} & reqbuf_attrs[0]));

  assign snpslv_tagctl_dirty_tc1_o = ((reqbuf_arb_tc1[5] & reqbuf_dirty[5]) |
                                      (reqbuf_arb_tc1[4] & reqbuf_dirty[4]) |
                                      (reqbuf_arb_tc1[3] & reqbuf_dirty[3]) |
                                      (reqbuf_arb_tc1[2] & reqbuf_dirty[2]) |
                                      (reqbuf_arb_tc1[1] & reqbuf_dirty[1]) |
                                      (reqbuf_arb_tc1[0] & reqbuf_dirty[0]));

  assign snpslv_tagctl_cluster_unique_tc1_o = reqbuf_arb_tc1[5] & reqbuf_cluster_unique;

  assign snpslv_tagctl_l2db_tc1_o = {4{reqbuf_arb_tc1[5]}} & reqbuf_l2db_id[5];

  assign snpslv_tagctl_static_pcredit_tc1_o = reqbuf_arb_tc1[6] & reqbuf_static_pcredit_tc1;

  assign snpslv_tagctl_pcrdtype_tc1_o = {2{reqbuf_arb_tc1[6]}} & reqbuf_pcrdtype_tc1;

  // If the RAMs are put into retention while the SCU is idle, then we must
  // still have the correct registered version on the first cycle that a snoop
  // arrives. This is achieved by asserting snpslv_active if the retention
  // state changes.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    l2_in_retention <= 1'b0;
  end else begin
    l2_in_retention <= gov_l2_in_retention_i;
  end

  // Send transfer requests to each L2DB.
  generate for (i = 0; i < MAX_L2DBS; i = i + 1) begin : g_l2db_mux
    for (j = 0; j <= NUM_REQBUFS; j = j + 1) begin : g_l2db_reqbuf
      assign l2db_transfer[i][j] = reqbuf_l2db_transfer[j] & (reqbuf_l2db_id[j] == i[3:0]);
      assign l2db_release[i][j]  = reqbuf_l2db_release[j]  & (reqbuf_l2db_id[j] == i[3:0]);
    end

    for (j = 0; j < NUM_REQBUFS; j = j + 1) begin : g_l2db_snp_reqbuf
      assign l2db_invalidate[i][j] = reqbuf_l2db_invalidate[j] & (reqbuf_l2db_id[j] == i[3:0]);
      assign l2db_makeshared[i][j] = reqbuf_l2db_makeshared[j] & (reqbuf_l2db_id[j] == i[3:0]);
    end

    if (i < NUM_L2DBS) begin : g_l2db

      assign next_l2db_buf_release[i] = |l2db_release[i];

      always @(posedge clk_reqbufs or negedge reset_n)
      if (~reset_n) begin
        l2db_buf_release[i] <= 1'b0;
      end else begin
        l2db_buf_release[i] <= next_l2db_buf_release[i];
      end

      assign snpslv_l2db_release[i] = l2db_buf_release[i];

      assign l2db_transfer_type[i] = (({3{l2db_transfer[i][5]}}  & reqbuf_l2db_transfer_type[5]) |
                                      ({3{l2db_transfer[i][4]}}  & reqbuf_l2db_transfer_type[4]) |
                                      ({3{l2db_transfer[i][3]}}  & reqbuf_l2db_transfer_type[3]) |
                                      ({3{l2db_transfer[i][2]}}  & reqbuf_l2db_transfer_type[2]) |
                                      ({3{l2db_transfer[i][1]}}  & reqbuf_l2db_transfer_type[1]) |
                                      ({3{l2db_transfer[i][0]}}  & reqbuf_l2db_transfer_type[0]));

      assign l2db_transfer_info[i] = (({29{l2db_transfer[i][5]}}  & reqbuf_l2db_transfer_info[5]) |
                                      ({29{l2db_transfer[i][4]}}  & reqbuf_l2db_transfer_info[4]) |
                                      ({29{l2db_transfer[i][3]}}  & reqbuf_l2db_transfer_info[3]) |
                                      ({29{l2db_transfer[i][2]}}  & reqbuf_l2db_transfer_info[2]) |
                                      ({29{l2db_transfer[i][1]}}  & reqbuf_l2db_transfer_info[1]) |
                                      ({29{l2db_transfer[i][0]}}  & reqbuf_l2db_transfer_info[0]));

    end else begin : g_n_l2db
      assign snpslv_l2db_release[i] = 1'b0;
      assign l2db_transfer_type[i] = 3'b000;
      assign l2db_transfer_info[i] = {29{1'b0}};
    end
  end endgenerate

  assign snpslv_l2db0_invalidate_o  = |l2db_invalidate[0];
  assign snpslv_l2db1_invalidate_o  = |l2db_invalidate[1];
  assign snpslv_l2db2_invalidate_o  = |l2db_invalidate[2];
  assign snpslv_l2db3_invalidate_o  = |l2db_invalidate[3];
  assign snpslv_l2db4_invalidate_o  = |l2db_invalidate[4];
  assign snpslv_l2db5_invalidate_o  = |l2db_invalidate[5];
  assign snpslv_l2db6_invalidate_o  = |l2db_invalidate[6];
  assign snpslv_l2db7_invalidate_o  = |l2db_invalidate[7];
  assign snpslv_l2db8_invalidate_o  = |l2db_invalidate[8];
  assign snpslv_l2db9_invalidate_o  = |l2db_invalidate[9];
  assign snpslv_l2db10_invalidate_o = |l2db_invalidate[10];

  assign snpslv_l2db0_makeshared_o  = |l2db_makeshared[0];
  assign snpslv_l2db1_makeshared_o  = |l2db_makeshared[1];
  assign snpslv_l2db2_makeshared_o  = |l2db_makeshared[2];
  assign snpslv_l2db3_makeshared_o  = |l2db_makeshared[3];
  assign snpslv_l2db4_makeshared_o  = |l2db_makeshared[4];
  assign snpslv_l2db5_makeshared_o  = |l2db_makeshared[5];
  assign snpslv_l2db6_makeshared_o  = |l2db_makeshared[6];
  assign snpslv_l2db7_makeshared_o  = |l2db_makeshared[7];
  assign snpslv_l2db8_makeshared_o  = |l2db_makeshared[8];
  assign snpslv_l2db9_makeshared_o  = |l2db_makeshared[9];
  assign snpslv_l2db10_makeshared_o = |l2db_makeshared[10];

  assign snpslv_l2db0_transfer_o  = |l2db_transfer[0];
  assign snpslv_l2db1_transfer_o  = |l2db_transfer[1];
  assign snpslv_l2db2_transfer_o  = |l2db_transfer[2];
  assign snpslv_l2db3_transfer_o  = |l2db_transfer[3];
  assign snpslv_l2db4_transfer_o  = |l2db_transfer[4];
  assign snpslv_l2db5_transfer_o  = |l2db_transfer[5];
  assign snpslv_l2db6_transfer_o  = |l2db_transfer[6];
  assign snpslv_l2db7_transfer_o  = |l2db_transfer[7];
  assign snpslv_l2db8_transfer_o  = |l2db_transfer[8];
  assign snpslv_l2db9_transfer_o  = |l2db_transfer[9];
  assign snpslv_l2db10_transfer_o = |l2db_transfer[10];

  assign snpslv_l2db0_transfer_type_o  = l2db_transfer_type[0];
  assign snpslv_l2db1_transfer_type_o  = l2db_transfer_type[1];
  assign snpslv_l2db2_transfer_type_o  = l2db_transfer_type[2];
  assign snpslv_l2db3_transfer_type_o  = l2db_transfer_type[3];
  assign snpslv_l2db4_transfer_type_o  = l2db_transfer_type[4];
  assign snpslv_l2db5_transfer_type_o  = l2db_transfer_type[5];
  assign snpslv_l2db6_transfer_type_o  = l2db_transfer_type[6];
  assign snpslv_l2db7_transfer_type_o  = l2db_transfer_type[7];
  assign snpslv_l2db8_transfer_type_o  = l2db_transfer_type[8];
  assign snpslv_l2db9_transfer_type_o  = l2db_transfer_type[9];
  assign snpslv_l2db10_transfer_type_o = l2db_transfer_type[10];

  assign snpslv_l2db0_transfer_info_o  = l2db_transfer_info[0];
  assign snpslv_l2db1_transfer_info_o  = l2db_transfer_info[1];
  assign snpslv_l2db2_transfer_info_o  = l2db_transfer_info[2];
  assign snpslv_l2db3_transfer_info_o  = l2db_transfer_info[3];
  assign snpslv_l2db4_transfer_info_o  = l2db_transfer_info[4];
  assign snpslv_l2db5_transfer_info_o  = l2db_transfer_info[5];
  assign snpslv_l2db6_transfer_info_o  = l2db_transfer_info[6];
  assign snpslv_l2db7_transfer_info_o  = l2db_transfer_info[7];
  assign snpslv_l2db8_transfer_info_o  = l2db_transfer_info[8];
  assign snpslv_l2db9_transfer_info_o  = l2db_transfer_info[9];
  assign snpslv_l2db10_transfer_info_o = l2db_transfer_info[10];

  assign snpslv_l2db0_release_o  = snpslv_l2db_release[0];
  assign snpslv_l2db1_release_o  = snpslv_l2db_release[1];
  assign snpslv_l2db2_release_o  = snpslv_l2db_release[2];
  assign snpslv_l2db3_release_o  = snpslv_l2db_release[3];
  assign snpslv_l2db4_release_o  = snpslv_l2db_release[4];
  assign snpslv_l2db5_release_o  = snpslv_l2db_release[5];
  assign snpslv_l2db6_release_o  = snpslv_l2db_release[6];
  assign snpslv_l2db7_release_o  = snpslv_l2db_release[7];
  assign snpslv_l2db8_release_o  = snpslv_l2db_release[8];
  assign snpslv_l2db9_release_o  = snpslv_l2db_release[9];
  assign snpslv_l2db10_release_o = snpslv_l2db_release[10];

  // Indicate if an L2DB may need to be allocate in the following cycle.
  assign snpslv_l2dbs_active_o = snpslv_tagctl_valid_tc0 & (snpslv_tagctl_pass_tc0 == `CA53_TAGCTL_PASS_SERIALISE);

  // Indicate if ramctl might get a request from an L2DB in the following cycle.
  assign snpslv_ramctl_active_o = |reqbuf_ramctl_active;

  // Indicate if the master might get a request from an L2DB in the following cycle.
  assign snpslv_master_active_o = |reqbuf_master_active;


  // Combine hazard results from each reqbuf, then register before returning
  // to tagctl in the following cycle.
  assign snpslv_hz_tc1 = |reqbuf_hz_tc1 | (tagctl_cpu_sync_tc1_i & dvm_comp_sync_outstanding);

  assign snpslv_ecc_hz_tc1 = |reqbuf_ecc_hz_tc1;

  assign snpslv_l2_way_used_tc1 = (reqbuf_l2_way_used_tc1[5] |
                                   reqbuf_l2_way_used_tc1[4] |
                                   reqbuf_l2_way_used_tc1[3] |
                                   reqbuf_l2_way_used_tc1[2] |
                                   reqbuf_l2_way_used_tc1[1] |
                                   reqbuf_l2_way_used_tc1[0]);

  assign snpslv_l2_way_used_vc1 = (reqbuf_l2_way_used_vc1[5] |
                                   reqbuf_l2_way_used_vc1[4] |
                                   reqbuf_l2_way_used_vc1[3] |
                                   reqbuf_l2_way_used_vc1[2] |
                                   reqbuf_l2_way_used_vc1[1] |
                                   reqbuf_l2_way_used_vc1[0]);

  assign snpslv_hz_tc3 = |reqbuf_hz_tc3;

  always @(posedge clk)
  begin
    snpslv_hz_tc2          <= snpslv_hz_tc1;
    snpslv_ecc_hz_tc2      <= snpslv_ecc_hz_tc1;
    snpslv_l2_way_used_tc2 <= snpslv_l2_way_used_tc1;
    snpslv_l2_way_used_vc2 <= snpslv_l2_way_used_vc1;
    snpslv_hz_tc4          <= snpslv_hz_tc3;
  end

  assign snpslv_hz_tc2_o = snpslv_hz_tc2;

  assign snpslv_ecc_hz_tc2_o = snpslv_ecc_hz_tc2;

  assign snpslv_l2_way_used_tc2_o = snpslv_l2_way_used_tc2;
  assign snpslv_l2_way_used_vc2_o = snpslv_l2_way_used_vc2;

  assign snpslv_hz_tc4_o = snpslv_hz_tc4;

  assign dvm_comp_sync_outstanding_o = dvm_comp_sync_outstanding;


  //----------------------------------------------------------------------------
  //  Request buffers
  //----------------------------------------------------------------------------

  generate for (i = 0; i < NUM_REQBUFS; i = i + 1) begin : g_reqbuf

    ca53scu_reqbuf_snp #(`CA53_SCU_INT_PARAM_INST, .NUM_REQBUFS(NUM_REQBUFS), .REQBUF_ID({3'b101, i[2:0]})) u_reqbuf (
      // Inputs
      .clk                                   (clk_reqbufs),
      .reset_n                               (reset_n),
      .config_l1_dc_size_i                   (config_l1_dc_size_i),
      .config_l2_size_i                      (config_l2_size_i),
      .reqbuf_early_alloc_i                  (reqbuf_early_alloc[i]),
      .reqbuf_alloc_i                        (reqbuf_alloc[i]),
      .reqbuf_second_dvm_i                   (reqbuf_second_dvm[i]),
      .ac_snoop_i                            (ac_snoop),
      .ac_addr_int_i                         (ac_addr_int),
      .dvm_part_i                            (dvm_part),
      .ac_srcid_i                            (ac_srcid),
      .ac_txnid_i                            (ac_txnid),
      .ac_qos_i                              (ac_qos),
      .sync_bar_completed_i                  (sync_bar_completed),
      .reqbuf_cr_ready_i                     (reqbuf_cr_ready[i]),
      .reqbufs_cr_unsent_i                   (reqbuf_cr_unsent),
      .reqbufs_cd_unsent_i                   (reqbuf_cd_unsent),
      .tagctl_addr_tc1_i                     (tagctl_addr_tc1_i),
      .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1_i),
      .tagctl_serialising_tc1_i              (tagctl_serialising_tc1_i),
      .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1_i),
      .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1_i),
      .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1_i),
      .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1_i),
      .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1_i),
      .victimctl_index_vc1_i                 (victimctl_index_vc1_i),
      .tagctl_addr_tc3_i                     (tagctl_addr_tc3_i),
      .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3_i),
      .reqbuf_arb_tc1_i                      (reqbuf_arb_tc1[i]),
      .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1_i),
      .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2_i),
      .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3_i),
      .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4_i),
      .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1_i),
      .tagctl_slv_l2db_hit_tc3_i             (tagctl_slv_l2db_hit_tc3_i),
      .tagctl_slv_l2db_dirty_tc3_i           (tagctl_slv_l2db_dirty_tc3_i),
      .tagctl_slv_l2db_cu_tc3_i              (tagctl_slv_l2db_cu_tc3_i),
      .tagctl_slv_l2db_tc3_i                 (tagctl_slv_l2db_tc3_i),
      .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3_i),
      .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3_i),
      .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3_i),
      .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3_i),
      .tagctl_shareability_tc3_i             (tagctl_shareability_tc3_i),
      .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3_i),
      .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4_i),
      .afb0_done_i                           (afb0_done_i),
      .afb1_done_i                           (afb1_done_i),
      .afb2_done_i                           (afb2_done_i),
      .afb3_done_i                           (afb3_done_i),
      .afb4_done_i                           (afb4_done_i),
      .afb5_done_i                           (afb5_done_i),
      .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty_i),
      .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty_i),
      .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty_i),
      .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty_i),
      .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty_i),
      .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty_i),
      .l2db0_snpslv_done_i                   (l2db0_snpslv_done_i),
      .l2db1_snpslv_done_i                   (l2db1_snpslv_done_i),
      .l2db2_snpslv_done_i                   (l2db2_snpslv_done_i),
      .l2db3_snpslv_done_i                   (l2db3_snpslv_done_i),
      .l2db4_snpslv_done_i                   (l2db4_snpslv_done_i),
      .l2db5_snpslv_done_i                   (l2db5_snpslv_done_i),
      .l2db6_snpslv_done_i                   (l2db6_snpslv_done_i),
      .l2db7_snpslv_done_i                   (l2db7_snpslv_done_i),
      .l2db8_snpslv_done_i                   (l2db8_snpslv_done_i),
      .l2db9_snpslv_done_i                   (l2db9_snpslv_done_i),
      .l2db10_snpslv_done_i                  (l2db10_snpslv_done_i),
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
      .l2db0_slv_master_arb_i                (l2db0_slv_master_arb_i),
      .l2db1_slv_master_arb_i                (l2db1_slv_master_arb_i),
      .l2db2_slv_master_arb_i                (l2db2_slv_master_arb_i),
      .l2db3_slv_master_arb_i                (l2db3_slv_master_arb_i),
      .l2db4_slv_master_arb_i                (l2db4_slv_master_arb_i),
      .l2db5_slv_master_arb_i                (l2db5_slv_master_arb_i),
      .l2db6_slv_master_arb_i                (l2db6_slv_master_arb_i),
      .l2db7_slv_master_arb_i                (l2db7_slv_master_arb_i),
      .l2db8_slv_master_arb_i                (l2db8_slv_master_arb_i),
      .l2db9_slv_master_arb_i                (l2db9_slv_master_arb_i),
      .l2db10_slv_master_arb_i               (l2db10_slv_master_arb_i),
      .ramctl_l2dbs_valid_i                  (ramctl_l2dbs_valid_i),
      .ramctl_l2dbs_id_i                     (ramctl_l2dbs_id_i),
      .ramctl_l2dbs_last_i                   (ramctl_l2dbs_last_i),
      .ramctl_bypassed_err_i                 (ramctl_bypassed_err_i),
      .reqbuf_tagctl_prearb_tc0_i            (tagctl_prearb_tc0[i]),
      .reqbufs_older_i                       (reqbuf_older_pkd[i*NUM_REQBUFS+:NUM_REQBUFS]),
      .reqbuf_credit_ready_i                 (reqbuf_credit_ready[i]),
      .reqbufs_wait_sync_i                   (reqbuf_wait_sync),
      // Outputs
      .reqbuf_busy_o                         (reqbuf_busy[i]),
      .next_reqbuf_ready_o                   (next_reqbuf_ready[i]),
      .reqbuf_dvm_part_two_o                 (reqbuf_dvm_part_two[i]),
      .reqbuf_hz_tc1_o                       (reqbuf_hz_tc1[i]),
      .reqbuf_ecc_hz_tc1_o                   (reqbuf_ecc_hz_tc1[i]),
      .reqbuf_hz_tc3_o                       (reqbuf_hz_tc3[i]),
      .reqbuf_l2_way_used_tc1_o              (reqbuf_l2_way_used_tc1[i]),
      .reqbuf_l2_way_used_vc1_o              (reqbuf_l2_way_used_vc1[i]),
      .reqbuf_tagctl_valid_tc0_o             (reqbuf_tagctl_valid_tc0[i]),
      .reqbuf_tagctl_prearb_req_o            (reqbuf_tagctl_prearb_req[i]),
      .reqbuf_update_pass_o                  (reqbuf_update_pass[i]),
      .reqbuf_tagctl_pass_tc0_o              (reqbuf_tagctl_pass_tc0[i]),
      .reqbuf_tagctl_addr1_tc0_o             (reqbuf_tagctl_addr1_tc0[i]),
      .reqbuf_tagctl_wr_state_tc0_o          (reqbuf_tagctl_wr_state_tc0[i]),
      .reqbuf_tagctl_ways_tc0_o              (reqbuf_tagctl_ways_tc0[i]),
      .reqbuf_tagctl_write_tc0_o             (reqbuf_tagctl_write_tc0[i]),
      .reqbuf_type_o                         (reqbuf_type[i]),
      .reqbuf_attrs_o                        (reqbuf_attrs[i]),
      .reqbuf_addr2_o                        (reqbuf_addr2[i]),
      .reqbuf_dirty_o                        (reqbuf_dirty[i]),
      .reqbuf_cr_valid_o                     (reqbuf_cr_valid[i]),
      .reqbuf_cr_active_o                    (reqbuf_cr_active[i]),
      .reqbuf_cr_cancel_o                    (reqbuf_cr_cancel[i]),
      .reqbuf_cr_resp_o                      (reqbuf_cr_resp[i]),
      .reqbuf_tgtid_o                        (reqbuf_tgtid[i]),
      .reqbuf_txnid_o                        (reqbuf_txnid[i]),
      .reqbuf_qos_o                          (reqbuf_qos[i]),
      .reqbuf_cr_unsent_o                    (reqbuf_cr_unsent[i]),
      .reqbuf_cd_unsent_o                    (reqbuf_cd_unsent[i]),
      .reqbuf_snp_cd_l2db_o                  (reqbuf_snp_cd_l2db[i]),
      .reqbuf_l2db_invalidate_o              (reqbuf_l2db_invalidate[i]),
      .reqbuf_l2db_makeshared_o              (reqbuf_l2db_makeshared[i]),
      .reqbuf_l2db_transfer_o                (reqbuf_l2db_transfer[i]),
      .reqbuf_l2db_id_o                      (reqbuf_l2db_id[i]),
      .reqbuf_l2db_transfer_type_o           (reqbuf_l2db_transfer_type[i]),
      .reqbuf_l2db_transfer_info_o           (reqbuf_l2db_transfer_info[i]),
      .reqbuf_l2db_release_o                 (reqbuf_l2db_release[i]),
      .reqbuf_wait_sync_o                    (reqbuf_wait_sync[i]),
      .reqbuf_credit_return_o                (reqbuf_credit_return[i]),
      .reqbuf_ramctl_active_o                (reqbuf_ramctl_active[i]),
      .reqbuf_master_active_o                (reqbuf_master_active[i])
    );
  end endgenerate

  ca53scu_reqbuf_ecc #(`CA53_SCU_INT_PARAM_INST, .NUM_REQBUFS(NUM_REQBUFS), .REQBUF_ID(6'b101101)) u_reqbuf_ecc (
    // Inputs
    .clk                                   (clk_reqbufs),
    .reset_n                               (reset_n),
    .config_l2_size_i                      (config_l2_size_i),
    .reqbuf_alloc_i                        (reqbuf_alloc[5]),
    .ramctl_ecc_flush_index_i              (ramctl_ecc_flush_index_i),
    .ramctl_ecc_flush_way_i                (ramctl_ecc_flush_way_i),
    .tagctl_addr_tc1_i                     (tagctl_addr_tc1_i),
    .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1_i),
    .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1_i),
    .victimctl_index_vc1_i                 (victimctl_index_vc1_i),
    .tagctl_addr_tc3_i                     (tagctl_addr_tc3_i),
    .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3_i),
    .reqbuf_tagctl_prearb_tc0_i            (tagctl_prearb_tc0[5]),
    .reqbuf_arb_tc1_i                      (reqbuf_arb_tc1[5]),
    .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1_i),
    .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2_i),
    .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3_i),
    .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4_i),
    .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3_i),
    .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1_i),
    .tagctl_slv_l2db_tc3_i                 (tagctl_slv_l2db_tc3_i),
    .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3_i),
    .tagctl_l2_victim_dirty_tc3_i          (tagctl_l2_victim_dirty_tc3_i),
    .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3_i),
    .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3_i),
    .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3_i),
    .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3_i),
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
    // Outputs
    .reqbuf_busy_o                         (reqbuf_busy[5]),
    .reqbuf_hz_tc1_o                       (reqbuf_hz_tc1[5]),
    .reqbuf_hz_tc3_o                       (reqbuf_hz_tc3[5]),
    .reqbuf_l2_way_used_tc1_o              (reqbuf_l2_way_used_tc1[5]),
    .reqbuf_l2_way_used_vc1_o              (reqbuf_l2_way_used_vc1[5]),
    .reqbuf_tagctl_valid_tc0_o             (reqbuf_tagctl_valid_tc0[5]),
    .reqbuf_tagctl_prearb_req_o            (reqbuf_tagctl_prearb_req[5]),
    .reqbuf_update_pass_o                  (reqbuf_update_pass[5]),
    .reqbuf_tagctl_pass_tc0_o              (reqbuf_tagctl_pass_tc0[5]),
    .reqbuf_tagctl_addr1_tc0_o             (reqbuf_tagctl_addr1_tc0[5]),
    .reqbuf_tagctl_ways_tc0_o              (reqbuf_tagctl_ways_tc0[5]),
    .reqbuf_tagctl_write_tc0_o             (reqbuf_tagctl_write_tc0[5]),
    .reqbuf_type_o                         (reqbuf_type[5]),
    .reqbuf_attrs_o                        (reqbuf_attrs[5]),
    .reqbuf_addr2_o                        (reqbuf_addr2[5]),
    .reqbuf_dirty_o                        (reqbuf_dirty[5]),
    .reqbuf_cluster_unique_o               (reqbuf_cluster_unique),
    .reqbuf_l2db_transfer_o                (reqbuf_l2db_transfer[5]),
    .reqbuf_l2db_id_o                      (reqbuf_l2db_id[5]),
    .reqbuf_l2db_transfer_type_o           (reqbuf_l2db_transfer_type[5]),
    .reqbuf_l2db_transfer_info_o           (reqbuf_l2db_transfer_info[5]),
    .reqbuf_l2db_release_o                 (reqbuf_l2db_release[5]),
    .reqbuf_master_active_o                (reqbuf_master_active[5])
  );

  ca53scu_reqbuf_sync #(`CA53_SCU_INT_PARAM_INST) u_reqbuf_sync (
    // Inputs
    .clk                            (clk_reqbufs),
    .reset_n                        (reset_n),
    .config_sysbardisable_i         (config_sysbardisable_i),
    .reqbuf_alloc_i                 (reqbuf_alloc[6]),
    .reqbuf_arb_tc1_i               (reqbuf_arb_tc1[6]),
    .tagctl_slv_flush_tc1_i         (tagctl_slv_flush_tc1_i),
    .tagctl_slv_afb_tc1_i           (tagctl_slv_afb_tc1_i),
    .afb0_done_i                    (afb0_done_i),
    .afb1_done_i                    (afb1_done_i),
    .afb2_done_i                    (afb2_done_i),
    .afb3_done_i                    (afb3_done_i),
    .afb4_done_i                    (afb4_done_i),
    .afb5_done_i                    (afb5_done_i),
    .master_snpslv_waddrs_valid_i   (master_snpslv_waddrs_valid_i),
    .master_snpslv_db_valid_i       (master_snpslv_db_valid_i),
    .master_snpslv_dr_valid_i       (master_snpslv_dr_valid_i),
    .master_rsp_comp_valid_i        (master_rsp_comp_valid_i),
    .master_rsp_txnid_i             (master_rsp_txnid_i),
    .master_snpslv_reqbuf_retry_i   (master_snpslv_reqbuf_retry_i),
    .master_snpslv_pcrdtype_i       (master_snpslv_pcrdtype_i),
    .cpuslv0_noncoh_since_barrier_i (cpuslv0_noncoh_since_barrier_i),
    .cpuslv1_noncoh_since_barrier_i (cpuslv1_noncoh_since_barrier_i),
    .cpuslv2_noncoh_since_barrier_i (cpuslv2_noncoh_since_barrier_i),
    .cpuslv3_noncoh_since_barrier_i (cpuslv3_noncoh_since_barrier_i),
    // Outputs
    .reqbuf_busy_o                  (reqbuf_busy[6]),
    .sync_bar_completed_o           (sync_bar_completed),
    .reqbuf_tagctl_valid_tc0_o      (reqbuf_tagctl_valid_tc0[6]),
    .reqbuf_tagctl_pass_tc0_o       (reqbuf_tagctl_pass_tc0[6]),
    .reqbuf_type_o                  (reqbuf_type[6]),
    .reqbuf_attrs_o                 (reqbuf_attrs[6]),
    .reqbuf_static_pcredit_tc1_o    (reqbuf_static_pcredit_tc1),
    .reqbuf_pcrdtype_tc1_o          (reqbuf_pcrdtype_tc1)
  );

  ca53scu_dvmcomp #(`CA53_SCU_INT_PARAM_INST) u_dvmcomp (
    /*ARMAUTO*/
    .clk                         (clk_reqbufs),
    .snpslv_sync_reqbuf_alloc_i  (reqbuf_alloc[6]),
    // Inputs
    .reset_n                     (reset_n),
    .config_broadcastinner_i     (config_broadcastinner_i),
    .tagctl_snp_dvm_sync_tc4_i   (tagctl_snp_dvm_sync_tc4_i),
    .tagctl_cpu_dvm_sync_tc4_i   (tagctl_cpu_dvm_sync_tc4_i[3:0]),
    .snpslv_dvm_complete_i       (snpslv_dvm_complete),
    .dcu_cpu0_dvm_complete_i     (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i     (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i     (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i     (dcu_cpu3_dvm_complete_i),
    .tagctl_dvm_complete_i       (tagctl_dvm_complete_i[3:0]),
    // Outputs
    .dvmcomp_active_o            (dvmcomp_active),
    .dvmcomp_start_comp_o        (dvmcomp_start_comp),
    .dvm_comp_sync_outstanding_o (dvm_comp_sync_outstanding),
    .scu_cpu0_dvm_complete_o     (scu_cpu0_dvm_complete_o),
    .scu_cpu1_dvm_complete_o     (scu_cpu1_dvm_complete_o),
    .scu_cpu2_dvm_complete_o     (scu_cpu2_dvm_complete_o),
    .scu_cpu3_dvm_complete_o     (scu_cpu3_dvm_complete_o)
  );  // u_dvmcomp

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_zero_one_hot #(`OVL_FATAL, NUM_REQBUFS + 2, `OVL_ASSERT, "reqbuf_arb_tc1 should be zero or one hot")
  u_ovl_reqbuf_arb_tc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (reqbuf_arb_tc1)
  );

  generate if (ACE) begin : g_ovl_ace

    assert_zero_one_hot #(`OVL_FATAL, NUM_REQBUFS, `OVL_ASSERT, "reqbuf_cr_valid must be zero or onehot for ACE")
    u_ovl_reqbuf_cr_valid (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr (reqbuf_cr_valid)
    );

  end else begin : g_ovl_skyros

    assert_always #(`OVL_FATAL, `OVL_ASSERT, "rxsnp_avail_credits must never be greater than the number of credits")
    u_ovl_rxsnp_credits (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr (rxsnp_avail_credits <= NUM_CREDITS)
    );

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A flit must not arrive when we are not ready")
    u_ovl_flitv_ready (
      .clk             (clk),
      .reset_n         (reset_n),
      .antecedent_expr (clean_aclken_i & ext_rxsnpflitv_i),
      .consequent_expr (scu_ext_ac_ready)
    );

    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "When a credit is used, the flit must be sent in the following cycle")
    u_ovl_txrspflitv (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (clean_aclken_i & next_scu_txrspflitv),
                      .test_expr   (scu_txrspflitv));

    assert_always #(`OVL_FATAL, `OVL_ASSERT, "rxsnpflitq_valid consistant")
    u_ovl_rxsnpflitq_valid (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr (rxsnpflitq_valid == (rxsnpflitq_head != rxsnpflitq_tail)));

  end endgenerate

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxsnp_credits_en")
  u_ovl_x_rxsnp_credits_en (.clk       (clk_ext_master),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rxsnp_credits_en));

  assert_never_unknown #(`OVL_FATAL, NUM_FLITQ, `OVL_ASSERT, "Register enable x-check: rxsnpflitq_en")
  u_ovl_x_rxsnpflitq_en (.clk       (clk_reqbufs),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (rxsnpflitq_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxsnpflitq_pop")
  u_ovl_x_rxsnpflitq_pop (.clk       (clk_reqbufs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (rxsnpflitq_pop));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxsnpflitq_push")
  u_ovl_x_rxsnpflitq_push (.clk       (clk_reqbufs),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (rxsnpflitq_push));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tagctl_prearb_en")
  u_ovl_x_tagctl_prearb_en (.clk       (clk_reqbufs),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (tagctl_prearb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_txrspflit_en")
  u_ovl_x_scu_txrspflit_en (.clk       (clk_reqbufs),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (scu_txrspflit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: txrsp_credits_en")
  u_ovl_x_txrsp_credits_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (txrsp_credits_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ac_en")
  u_ovl_x_ac_en (.clk       (clk_ext_master),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (ac_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ac_valid_en")
  u_ovl_x_ac_valid_en (.clk       (clk_ext_master),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ac_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclken_i")
  u_ovl_x_clean_aclken_i (.clk       (clk_reqbufs),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (clean_aclken_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cr_en")
  u_ovl_x_cr_en (.clk       (clk_reqbufs),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (cr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cr_skid_en")
  u_ovl_x_cr_skid_en (.clk       (clk_reqbufs),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (cr_skid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_arb_tc1_en")
  u_ovl_x_reqbuf_arb_tc1_en (.clk       (clk_reqbufs),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_arb_tc1_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable x-check: reqbuf_clk_enable")
  u_ovl_x_reqbuf_clk_enable (.clk       (clk_ext_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_clk_enable));

`endif

endmodule // ca53scu_snpslv

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
