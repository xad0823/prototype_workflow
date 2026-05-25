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
//  The Address Forwarding Buffer (AFB) takes requests as they go down the
//  tagctl pipeline and forwards the address on to the CPU snoop channels, the
//  L2 RAM controller, or the master address channel as required.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_scu_dcu_defs.v"
`include "cortexa53params.v"


module ca53scu_afb #(`CA53_SCU_INT_PARAM_DECL, parameter AFB_NUM = 3'b000)
 (
  input  wire                 clk,
  input  wire                 reset_n,
  input  wire                 tagctl_broadcastinner_i,
  input  wire                 tagctl_broadcastouter_i,
  input  wire                 tagctl_broadcastcachemaint_i,

  // AFB control
  output wire                 afb_valid_o,
  output wire                 afb_requires_master_o,
  input  wire                 alloc_afb_tc1_i,
  input  wire                 flush_tc1_i,
  input  wire [40:0]          req_addr1_tc1_i,
  input  wire [40:0]          req_addr2_tc1_i,
  input  wire [3:0]           first_l2db_enc_tc1_i,
  input  wire [3:0]           second_l2db_enc_tc1_i,
  input  wire                 alloc_first_l2db_tc1_i,
  input  wire                 valid_second_l2db_tc1_i,
  input  wire [4:0]           req_type_tc1_i,
  input  wire [3:0]           req_pass_tc1_i,
  input  wire [5:0]           req_id_tc1_i,
  input  wire                 req_id_dcu_tc1_i,
  input  wire [1:0]           req_len_tc1_i,
  input  wire                 req_single_tc1_i,
  input  wire [2:0]           req_size_tc1_i,
  input  wire                 req_lock_tc1_i,
  input  wire                 req_dirty_tc1_i,
  input  wire                 req_cluster_unique_tc1_i,
  input  wire [7:0]           req_attrs_tc1_i,
  input  wire [1:0]           req_prot_tc1_i,
  input  wire                 req_l2db_full_tc1_i,
  input  wire                 req_l2db_rmw_tc1_i,
  input  wire                 req_static_pcredit_tc1_i,
  input  wire [1:0]           req_pcrdtype_tc1_i,
  input  wire                 req_l2flushreq_tc1_i,
  input  wire [3:0]           smp_en_tc1_i,
  input  wire [6:0]           sam_tgtid_tc2_i,
  input  wire                 active_afb_tc2_i,
  input  wire                 flush_tc2_i,
  input  wire                 flush_afb_tc2_i,
  input  wire                 l2_data_access_tc2_i,
  input  wire [6:0]           req_l2_ecc_tc2_i,
  input  wire                 active_afb_tc3_i,
  input  wire                 flush_tc3_i,
  input  wire                 flush_afb_tc3_i,
  input  wire [40:6]          victim_addr_tc3_i,
  input  wire [15:0]          l1_lookup_hit_ways_tc3_i,
  input  wire [3:0]           l1_lookup_hit_cpus_tc3_i,
  input  wire                 l1_lookup_hit_tc3_i,
  input  wire [15:0]          l1_victim_hit_ways_tc3_i,
  input  wire [3:0]           l1_victim_hit_cpus_tc3_i,
  input  wire                 l1_victim_hit_tc3_i,
  input  wire [3:0]           l1_ecc_victim_way_tc3_i,
  input  wire                 l2_hit_tc3_i,
  input  wire [15:0]          l2_hit_ways_tc3_i,
  input  wire [3:0]           l2_victim_way_tc3_i,
  input  wire                 l2_hit_dirty_tc3_i,
  input  wire                 l2_dirty_tc3_i,
  input  wire                 l2_victim_valid_tc3_i,
  input  wire                 l2_victim_dirty_tc3_i,
  input  wire                 l2_victim_alloc_tc3_i,
  input  wire                 l2_victim_cu_tc3_i,
  input  wire [1:0]           l2_victim_shareability_tc3_i,
  input  wire                 cluster_unique_tc3_i,
  input  wire [1:0]           tagctl_hit_shareability_tc3_i,
  output wire                 afb_l2db_hazard_tc3_o,
  output wire                 afb_force_cluster_unique_tc3_o,
  output wire [1:0]           afb_snoop_data_cpu_tc4_o,
  output wire                 afb_l2db_hazard_both_tc4_o,
  input  wire                 active_afb_tc4_i,
  input  wire                 flush_tc4_i,
  input  wire                 flush_afb_tc4_i,
  input  wire                 master_hz_tc4_i,
  input  wire [3:0]           master_hz_waddr_tc4_i,
  input  wire [15:0]          master_waddr_valid_i,

  output wire                 afb_slv_l2db_hit_tc3_o,
  output wire                 afb_slv_l2db_dirty_tc3_o,
  output wire                 afb_slv_l2db_cu_tc3_o,
  output wire [3:0]           afb_slv_l2db_o,
  output wire [3:0]           afb_slv_victim_l2db_tc4_o,
  output wire                 afb_slv_snp_hz_tc4_o,
  output wire [4:0]           afb_slv_snp_hz_id_tc4_o,
  output wire                 afb_slv_l2db_invalidated_tc4_o,
  output wire                 afb_slv_l2db_cleaned_tc4_o,

  output wire                 afb_done_o,
  output wire                 afb_snoop_resp_valid_o,
  output wire                 afb_snoop_resp_dirty_o,
  output wire                 afb_snoop_resp_alloc_o,
  output wire                 afb_snoop_resp_migratory_o,
  output wire                 afb_snoop_resp_victim_valid_o,
  output wire                 afb_snoop_resp_victim_dirty_o,
  output wire                 afb_snoop_resp_victim_age_o,
  output wire                 afb_snoop_resp_victim_alloc_o,
  output wire                 afb_write_done_o,
  input  wire                 tagctl_disable_evict_tc3_i,
  input  wire                 tagctl_enable_writeevict_tc3_i,

  output wire                 afb_req_single_o,

  output wire [3:0]           afb_smp_en_o,

  // L2DB control
  output wire                 afb_l2dbs_transfer_o,
  output wire [3:0]           afb_l2dbs_id_o,
  output wire [23:0]          afb_l2dbs_transfer_info_o,
  output wire [MAX_L2DBS-1:0] afb_l2db_release_o,
  output wire [MAX_L2DBS-1:0] afb_l2db_snoops_done_o,
  output wire [MAX_L2DBS-1:0] afb_l2db_fill_strbs_o,

  input  wire                 cpuslv_snp_hz_tc2_i,
  input  wire [4:0]           cpuslv_snp_hz_id_tc2_i,
  input  wire                 cpuslv_snp_l2db_hz_tc2_i,
  input  wire                 cpuslv_snp_l2db_dirty_tc2_i,
  input  wire                 cpuslv_snp_l2db_cu_tc2_i,
  input  wire [3:0]           cpuslv_snp_l2db_tc2_i,

  input  wire                 l2db0_slv_done_i,
  input  wire                 l2db1_slv_done_i,
  input  wire                 l2db2_slv_done_i,
  input  wire                 l2db3_slv_done_i,
  input  wire                 l2db4_slv_done_i,
  input  wire                 l2db5_slv_done_i,
  input  wire                 l2db6_slv_done_i,
  input  wire                 l2db7_slv_done_i,
  input  wire                 l2db8_slv_done_i,
  input  wire                 l2db9_slv_done_i,
  input  wire                 l2db10_slv_done_i,

  // Snoops to CPUs
  output wire [3:0]           afb_snoop_req_o,
  output wire [3:0]           afb_snoop_second_dvm_o,
  input  wire [1:0]           round_robin_tc3_i,
  output wire                 afb_update_rr_tc3_o,

  input  wire                 afb_cpu0_ac_ready_i,
  output wire [3:0]           afb_cpu0_ac_snoop_o,
  output wire [3:0]           afb_cpu0_ac_l2db_id_o,
  output wire [40:0]          afb_cpu0_ac_addr_o,
  output wire [3:0]           afb_cpu0_ac_way_o,
  input  wire                 cpuslv0_cr_valid_i,
  input  wire [2:0]           cpuslv0_cr_id_i,
  input  wire                 cpuslv0_cr_dirty_i,
  input  wire                 cpuslv0_cr_age_i,
  input  wire                 cpuslv0_cr_alloc_i,
  input  wire                 cpuslv0_cr_migratory_i,

  input  wire                 afb_cpu1_ac_ready_i,
  output wire [3:0]           afb_cpu1_ac_snoop_o,
  output wire [3:0]           afb_cpu1_ac_l2db_id_o,
  output wire [40:0]          afb_cpu1_ac_addr_o,
  output wire [3:0]           afb_cpu1_ac_way_o,
  input  wire                 cpuslv1_cr_valid_i,
  input  wire [2:0]           cpuslv1_cr_id_i,
  input  wire                 cpuslv1_cr_dirty_i,
  input  wire                 cpuslv1_cr_age_i,
  input  wire                 cpuslv1_cr_alloc_i,
  input  wire                 cpuslv1_cr_migratory_i,

  input  wire                 afb_cpu2_ac_ready_i,
  output wire [3:0]           afb_cpu2_ac_snoop_o,
  output wire [3:0]           afb_cpu2_ac_l2db_id_o,
  output wire [40:0]          afb_cpu2_ac_addr_o,
  output wire [3:0]           afb_cpu2_ac_way_o,
  input  wire                 cpuslv2_cr_valid_i,
  input  wire [2:0]           cpuslv2_cr_id_i,
  input  wire                 cpuslv2_cr_dirty_i,
  input  wire                 cpuslv2_cr_age_i,
  input  wire                 cpuslv2_cr_alloc_i,
  input  wire                 cpuslv2_cr_migratory_i,

  input  wire                 afb_cpu3_ac_ready_i,
  output wire [3:0]           afb_cpu3_ac_snoop_o,
  output wire [3:0]           afb_cpu3_ac_l2db_id_o,
  output wire [40:0]          afb_cpu3_ac_addr_o,
  output wire [3:0]           afb_cpu3_ac_way_o,
  input  wire                 cpuslv3_cr_valid_i,
  input  wire [2:0]           cpuslv3_cr_id_i,
  input  wire                 cpuslv3_cr_dirty_i,
  input  wire                 cpuslv3_cr_age_i,
  input  wire                 cpuslv3_cr_alloc_i,
  input  wire                 cpuslv3_cr_migratory_i,

  output wire                 afb_cpuslv0_snp_active_o,
  output wire                 afb_cpuslv1_snp_active_o,
  output wire                 afb_cpuslv2_snp_active_o,
  output wire                 afb_cpuslv3_snp_active_o,

  // Master address requests
  output wire                 afb_master_active_o,
  output wire                 afb_master_req_o,
  output wire                 afb_master_flush_o,
  output wire [6:0]           afb_master_id_o,
  output wire [40:0]          afb_master_addr_o,
  output wire [4:0]           afb_master_opcode_o,
  output wire [1:0]           afb_master_len_o,
  output wire [2:0]           afb_master_size_o,
  output wire                 afb_master_lock_o,
  output wire [7:0]           afb_master_attrs_o,
  output wire [1:0]           afb_master_prot_o,
  output wire [6:0]           afb_master_tgtid_o,
  output wire [3:0]           afb_master_l2db_o,
  output wire                 afb_master_static_pcredit_o,
  output wire [1:0]           afb_master_pcrdtype_o,
  input  wire                 master_afb_ack_i,

  // L2 RAM controller requests
  output wire                 afb_ramctl_active_o,
  output wire                 afb_ramctl_valid_o,
  output wire                 afb_ramctl_cancel_o,
  output wire [10:0]          afb_ramctl_index_o,
  output wire [3:0]           afb_ramctl_way_o,
  output wire [1:0]           afb_ramctl_crit_chunk_o,
  output wire [7:0]           afb_ramctl_banks_o,
  output wire                 afb_ramctl_flush_o,
  input  wire                 ramctl_afb_ready_i,

  // Tagctl requests
  output wire                 afb_tagctl_valid_tc0_o,
  output wire [40:0]          afb_tagctl_addr1_tc0_o,
  output wire                 afb_tagctl_addr13_tc0_o,
  output wire [16:0]          afb_tagctl_wr_state_tc0_o,
  output wire [34:0]          afb_tagctl_ecc_tc0_o,
  output wire [31:0]          afb_tagctl_ways_tc0_o,
  output wire [4:0]           afb_tagctl_type_tc0_o,
  output wire [3:0]           afb_tagctl_requestor_tc0_o,
  output wire [40:0]          afb_tagctl_addr2_tc1_o,
  input  wire                 tagctl_afb_ready_tc0_i,

  // Hazarding
  input  wire [41:6]          tagctl_addr_tc1_i,
  input  wire                 tagctl_addr_valid_tc1_i,
  input  wire [40:6]          tagctl_addr_tc3_i,
  input  wire                 tagctl_addr_valid_tc3_i,
  output wire                 afb_hz_tc1_o,
  output wire                 afb_hz_tc3_o,
  
  // DVM syncs
  output wire                 afb_dvm_sync_tc3_o,
  output wire                 afb_snp_dvm_sync_tc4_o,
  output wire [3:0]           afb_cpu_dvm_sync_tc4_o,
  output wire [3:0]           afb_dvm_complete_o,
  input  wire                 dcu_cpu0_dvm_complete_i,
  input  wire                 dcu_cpu1_dvm_complete_i,
  input  wire                 dcu_cpu2_dvm_complete_i,
  input  wire                 dcu_cpu3_dvm_complete_i,

  input  wire                 tagctl_mbistreq_i
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE   = 4'b0000;
  localparam STATE_L2DB   = 4'b0001;
  localparam STATE_TC0_WR = 4'b0010;
  localparam STATE_TC0    = 4'b0011;
  localparam STATE_TC1    = 4'b0100;
  localparam STATE_TC2    = 4'b0101;
  localparam STATE_TC3    = 4'b0110;
  localparam STATE_TC4    = 4'b0111;
  localparam STATE_HZ     = 4'b1000;

  reg                afb_valid;
  reg                afb_done;
  reg                afb_write_done;
  reg [40:0]         afb_primary_addr;
  reg [3:0]          afb_first_l2db;
  reg [3:0]          afb_second_l2db;
  reg                afb_first_l2db_valid;
  reg                afb_second_l2db_valid;
  reg [4:0]          afb_req_type;
  reg [3:0]          afb_req_pass;
  reg [5:0]          afb_req_id;
  reg                afb_req_id_dcu;
  reg [1:0]          afb_req_len;
  reg                afb_req_single;
  reg [2:0]          afb_req_size;
  reg                afb_req_lock;
  reg                afb_req_dirty;
  reg                afb_req_cluster_unique;
  reg [7:0]          afb_req_attrs;
  reg [1:0]          afb_req_prot;
  reg [3:0]          afb_smp_en;
  reg [6:0]          afb_tgtid;
  reg [40:0]         afb_victim_addr;
  reg                afb_cluster_unique;
  reg                afb_l1_victim_hit;
  reg [15:0]         afb_l1_hit_ways;
  reg                afb_l2_hit;
  reg [3:0]          afb_l2_way;
  reg                afb_l2_victim_valid;
  reg                afb_l2_victim_dirty;
  reg                afb_l2_victim_alloc;
  reg                afb_l2_victim_cu;
  reg [1:0]          afb_l2_victim_shareability;
  reg                afb_l2_victim_hit_l1;
  reg [NUM_CPUS-1:0] afb_priority_snoop;
  reg [3:0]          snoops_needed_tc3;
  reg [3:0]          snoop_req;
  reg [3:0]          first_dvm_snoop_sent;
  reg [3:0]          snoop_resp_pending;
  reg                snoop_resp_dirty;
  reg                snoop_resp_alloc;
  reg                snoop_resp_migratory;
  reg                master_req;
  reg                ramctl_req;
  reg                ramctl_requested;
  reg                first_dvm_master_sent;
  reg                afb_l2db_full;
  reg                afb_l2db_rmw;
  reg                afb_static_pcredit;
  reg [1:0]          afb_pcrdtype;
  reg                afb_l2flushreq;
  reg [6:0]          afb_req_l2_ecc;
  reg                afb_snp_hz_valid;
  reg [4:0]          afb_snp_hz_id;
  reg                afb_snp_l2db_valid;
  reg                afb_snp_l2db_dirty;
  reg                afb_snp_l2db_cu;
  reg                afb_first_l2db_release_tc4;
  reg                afb_second_l2db_release_tc4;
  reg [3:0]          tagctl_state;
  reg                afb_l2_victim_waddr_hz;
  reg [3:0]          afb_l2_victim_waddr;
  reg [1:0]          afb_snoop_data_cpu_tc4;
  reg                afb_l2db_hazard_both_tc4;


  wire         next_afb_valid;
  wire         next_afb_done;
  wire         next_afb_write_done;
  wire         afb_valid_en;
  wire [3:0]   requestor_cpu;
  wire [3:0]   priority_cpu_req_tc3;
  wire [3:0]   priority_cpu_tc3;
  wire         req_might_priority_snoop_tc3;
  wire [3:0]   priority_snoop_tc3;
  wire [3:0]   afb_pri_snoop;
  wire [15:0]  l1_hit_ways_tc3;
  wire [3:0]   l2_hit_way_tc3;
  wire [3:0]   l2_way_tc3;
  wire [15:0]  next_afb_l1_hit_ways;
  wire         afb_l1_hit;
  wire [3:0]   afb_ac_ready;
  wire         two_part_dvm;
  wire [3:0]   next_snoop_req;
  wire [3:0]   next_first_dvm_snoop_sent;
  wire [3:0]   victim_snoop;
  reg [3:0]    victim_snoop_type;
  reg [3:0]    priority_snoop_type;
  reg [3:0]    default_snoop_type;
  wire [3:0]   afb_cr_valid;
  wire         snoop_resp_en;
  wire [3:0]   snoop_other_resp_pending;
  wire [3:0]   clear_snoop_resp_pending;
  wire [3:0]   next_snoop_resp_pending;
  wire         new_snoop_resp_dirty;
  wire         new_snoop_resp_alloc;
  wire         new_snoop_resp_migratory;
  wire         next_snoop_resp_dirty;
  wire         next_snoop_resp_alloc;
  wire         next_snoop_resp_migratory;
  reg          primary_l2db_needed_tc3;
  reg          victim_l2db_needed_tc3;
  wire         afb_l2db_hazard_one_tc3;
  wire         afb_l2db_hazard_both_tc3;
  wire [3:0]   primary_l2db;
  wire [3:0]   victim_l2db;
  wire         afb_first_l2db_release_tc3;
  wire         afb_second_l2db_release_tc3;
  wire         master_req_needed_tc2;
  wire         afb_clean_evict_needed_tc3;
  reg [15:0]   requestor_way_mask;
  reg          master_req_needed_tc3;
  wire         master_req_needed_tc4;
  reg [4:0]    master_req_opcode;
  wire         l2_victim_write_needed;
  wire         master_req_needed_victim;
  wire         next_master_req;
  wire         next_afb_l2_victim_hit_l1;
  wire         ac_addr0;
  wire         next_ramctl_req;
  wire         next_ramctl_requested;
  wire         afb_ramctl_valid;
  wire         afb_ramctl_cancel;
  wire         afb_ramctl_flush;
  wire         afb_ramctl_needed_tc3;
  wire         afb_ramctl_victim_needed_tc3;
  wire         afb_ramctl_needed_tc2;
  wire [40:0]  next_afb_victim_addr;
  wire         afb_victim_addr_en;
  wire         next_first_dvm_master_sent;
  wire         last_master_ack;
  wire [3:0]   snp_active;
  wire [5:0]   req_type_tc1;
  wire [5:0]   req_type;
  wire [3:0]   requestor_cpu_mask;
  wire         requestor_hit_tc3;
  wire         non_requestor_hit_tc3;
  wire         afb_second_l2db_en;
  wire [3:0]   next_afb_second_l2db;
  wire         dvm_sync;
  wire         dvm_sync_tc4;
  wire         tc1_info_en;
  wire         tc2_info_en;
  wire         afb_req_attrs_en;
  wire [7:0]   next_afb_req_attrs;
  wire         afb_req_read_alloc;
  reg [3:0]    next_tagctl_state;
  wire         tagctl_pass_needed_tc4;
  wire         l2db_done;
  wire [2:0]   l2db_master_opcode;
  wire [7:0]   l2db_master_attrs;
  wire         afb_l2_victim_hz;
  wire         zero;
  wire [15:0]  afb_l2_victim_waddr_onehot;
  wire         next_afb_l2_victim_waddr_hz;
  wire         l2_victim_waddr_hz;
  wire [1:0]   next_afb_snoop_data_cpu_tc4;

  genvar i;

  // Tie off for configurable logic
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  //  Control state
  //----------------------------------------------------------------------------

  assign next_afb_valid = (afb_valid | alloc_afb_tc1_i) & ~(flush_afb_tc2_i |
                                                            flush_afb_tc3_i |
                                                            flush_afb_tc4_i |
                                                            next_afb_done);

  assign afb_valid_en = alloc_afb_tc1_i | afb_valid | afb_done;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    afb_valid <= 1'b0;
  end else if (afb_valid_en) begin
    afb_valid <= next_afb_valid;
  end

  assign afb_valid_o = afb_valid;

  always @(posedge clk)
  if (alloc_afb_tc1_i) begin
    afb_primary_addr       <= req_addr1_tc1_i;
    afb_first_l2db         <= first_l2db_enc_tc1_i;
    afb_first_l2db_valid   <= alloc_first_l2db_tc1_i;
    afb_second_l2db_valid  <= valid_second_l2db_tc1_i;
    afb_req_type           <= req_type_tc1_i;
    afb_req_pass           <= req_pass_tc1_i;
    afb_req_id             <= req_id_tc1_i;
    afb_req_id_dcu         <= req_id_dcu_tc1_i;
    afb_req_len            <= req_len_tc1_i;
    afb_req_size           <= req_size_tc1_i;
    afb_req_lock           <= req_lock_tc1_i;
    afb_req_dirty          <= req_dirty_tc1_i;
    afb_req_cluster_unique <= req_cluster_unique_tc1_i;
    afb_req_prot           <= req_prot_tc1_i;
    afb_l2db_full          <= req_l2db_full_tc1_i;
    afb_l2flushreq         <= req_l2flushreq_tc1_i;
  end

  generate if (ACP) begin : g_acp

    always @(posedge clk)
    if (alloc_afb_tc1_i) begin
      afb_req_single <= req_single_tc1_i;
    end

  end else begin : g_n_acp

    always @*
      afb_req_single = zero;

  end endgenerate

  generate if (ACE) begin : g_afb_ace

    always @*
    begin
      afb_static_pcredit = zero;
      afb_pcrdtype       = {2{zero}};
    end

  end else begin : g_afb_skyros

    always @(posedge clk)
    if (alloc_afb_tc1_i) begin
      afb_static_pcredit     <= req_static_pcredit_tc1_i;
      afb_pcrdtype           <= req_pcrdtype_tc1_i;
    end

  end endgenerate

  generate if (SCU_CACHE_PROTECTION) begin : g_ecc

    always @(posedge clk)
    if (active_afb_tc2_i) begin
      afb_req_l2_ecc <= req_l2_ecc_tc2_i;
    end

  end else begin : g_n_ecc

    always @*
      afb_req_l2_ecc = req_l2_ecc_tc2_i;

  end endgenerate

  assign tc1_info_en = alloc_afb_tc1_i | (tagctl_state == STATE_TC1);
  assign tc2_info_en = active_afb_tc2_i | (tagctl_state == STATE_TC2);


  always @(posedge clk)
  if (tc1_info_en) begin
    afb_smp_en <= smp_en_tc1_i;
  end

  generate if (ACE) begin : g_ace

    always @*
    begin
      afb_tgtid = {7{zero}};
    end

  end else begin : g_skyros

    always @(posedge clk)
    if (tc2_info_en) begin
      afb_tgtid <= sam_tgtid_tc2_i;
    end

  end endgenerate

  assign afb_req_attrs_en = alloc_afb_tc1_i | (active_afb_tc3_i &
                                               (|l1_lookup_hit_ways_tc3_i | l2_hit_tc3_i) &
                                               ~((afb_req_pass == `CA53_TAGCTL_PASS_VICTIM) |
                                                 (afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM) |
                                                 (req_type == `CA53_AFB_REQ_CLEANSHARED) |
                                                 (req_type == `CA53_AFB_REQ_CLEANINVALID) |
                                                 (req_type == `CA53_AFB_REQ_MAKEINVALID)));

  assign next_afb_req_attrs = alloc_afb_tc1_i ? req_attrs_tc1_i : {afb_req_attrs[7:2], tagctl_hit_shareability_tc3_i};

  always @(posedge clk)
  if (afb_req_attrs_en) begin
    afb_req_attrs <= next_afb_req_attrs;
  end

  assign afb_req_read_alloc = `CA53_MEM_WBRA(afb_req_attrs) | ((ACE == 0) & (afb_req_id[5:3] == 3'b100));

  assign req_type_tc1 = {req_id_tc1_i[5:3] == 3'b101, req_type_tc1_i};
  assign req_type = {afb_req_id[5:3] == 3'b101, afb_req_type};


  always @(posedge clk)
  if (active_afb_tc2_i) begin
    afb_snp_hz_valid   <= cpuslv_snp_hz_tc2_i;
    afb_snp_hz_id      <= cpuslv_snp_hz_id_tc2_i;
    afb_snp_l2db_valid <= cpuslv_snp_l2db_hz_tc2_i;
    afb_snp_l2db_dirty <= cpuslv_snp_l2db_dirty_tc2_i;
  end

  generate if (ACE) begin : g_cu_ace

    always @*
      afb_snp_l2db_cu = zero;

  end else begin : g_cu_skyros

    always @(posedge clk)
    if (active_afb_tc2_i) begin
      afb_snp_l2db_cu <= cpuslv_snp_l2db_cu_tc2_i;
    end

  end endgenerate

  assign afb_slv_l2db_hit_tc3_o = active_afb_tc3_i & afb_snp_l2db_valid;
  assign afb_slv_l2db_dirty_tc3_o = active_afb_tc3_i & afb_snp_l2db_dirty;
  assign afb_slv_l2db_cu_tc3_o = active_afb_tc3_i & afb_snp_l2db_cu;

  // For snoops, the second L2DB may be one already allocated to another request.
  assign afb_second_l2db_en = ((alloc_afb_tc1_i & ~`CA53_REQBUF_IS_SNOOP(req_id_tc1_i)) |
                               (active_afb_tc2_i & `CA53_REQBUF_IS_SNOOP(afb_req_id)) |
                               tagctl_mbistreq_i);

  assign next_afb_second_l2db = alloc_afb_tc1_i ? second_l2db_enc_tc1_i : cpuslv_snp_l2db_tc2_i;

  always @(posedge clk)
  if (afb_second_l2db_en) begin
    afb_second_l2db <= next_afb_second_l2db;
  end

  // Tell the reqbuf when we have serialised a snoop that invalidates the tags.
  assign afb_slv_snp_hz_tc4_o = (active_afb_tc4_i & ~flush_afb_tc4_i &
                                 afb_snp_hz_valid &
                                 ((req_type == `CA53_AFB_SNP_READUNIQUE) |
                                  (req_type == `CA53_AFB_SNP_CLEANINVALID) |
                                  (req_type == `CA53_AFB_SNP_MAKEINVALID)));

  assign afb_slv_snp_hz_id_tc4_o = afb_snp_hz_id;

  // Tell the reqbuf when we have serialised a snoop that invalidates its L2DB.
  assign afb_slv_l2db_invalidated_tc4_o = (active_afb_tc4_i & ~flush_afb_tc4_i &
                                           afb_snp_l2db_valid &
                                           ((req_type == `CA53_AFB_SNP_READUNIQUE) |
                                            (req_type == `CA53_AFB_SNP_CLEANINVALID) |
                                            (req_type == `CA53_AFB_SNP_MAKEINVALID)));

  // Tell the reqbuf when we have serialised a snoop that cleans its L2DB without also invalidating it.
  assign afb_slv_l2db_cleaned_tc4_o = (active_afb_tc4_i & ~flush_afb_tc4_i &
                                       afb_snp_l2db_valid &
                                       (req_type == `CA53_AFB_SNP_CLEANSHARED));

  assign l1_hit_ways_tc3 = l1_lookup_hit_ways_tc3_i | l1_victim_hit_ways_tc3_i;

  // Because ECC clean requests perform a snoop to a line that might be invalid,
  // we must force the way here to ensure that it is picked up by the snoop.
  assign next_afb_l1_hit_ways = l1_hit_ways_tc3 | ({16{(req_type == `CA53_AFB_REQ_ECCCLEAN) &
                                                       (afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE)}} &
                                                   {4{l1_ecc_victim_way_tc3_i}});

  // The victim address is normally read from the RAMs, but for DVMs it stores
  // the second part of two part DVMs.
  assign afb_victim_addr_en = ((alloc_afb_tc1_i & ((req_type_tc1 == `CA53_AFB_REQ_DVM) |
                                                   (req_type_tc1 == `CA53_AFB_SNP_DVM_MESSAGE))) |
                               (active_afb_tc3_i & ~((req_type == `CA53_AFB_REQ_DVM) |
                                                     (req_type == `CA53_AFB_SNP_DVM_MESSAGE))));

  assign next_afb_victim_addr = alloc_afb_tc1_i ? req_addr2_tc1_i : {victim_addr_tc3_i, 6'b000000};

  always @(posedge clk)
  if (afb_victim_addr_en) begin
    afb_victim_addr <= next_afb_victim_addr;
  end

  always @(posedge clk)
  if (active_afb_tc3_i) begin
    afb_cluster_unique <= cluster_unique_tc3_i;
    afb_l1_hit_ways    <= next_afb_l1_hit_ways;
    afb_l1_victim_hit  <= l1_victim_hit_tc3_i;
  end

  assign afb_l1_hit = |afb_l1_hit_ways;

  assign l2_hit_way_tc3 = `CA53_L2_WAY_ENC(l2_hit_ways_tc3_i);

  assign l2_way_tc3 = l2_hit_tc3_i ? l2_hit_way_tc3 : l2_victim_way_tc3_i;

  generate if (L2_CACHE) begin : g_l2cc
    always @(posedge clk)
    if (active_afb_tc3_i) begin
      afb_l2_hit                 <= l2_hit_tc3_i;
      afb_l2_way                 <= l2_way_tc3;
      afb_l2_victim_valid        <= l2_victim_valid_tc3_i;
      afb_l2_victim_dirty        <= l2_victim_dirty_tc3_i;
      afb_l2_victim_cu           <= l2_victim_cu_tc3_i;
      afb_l2_victim_alloc        <= l2_victim_alloc_tc3_i;
      afb_l2_victim_shareability <= l2_victim_shareability_tc3_i;
    end

    always @(posedge clk)
    if (alloc_afb_tc1_i) begin
      afb_l2db_rmw <= req_l2db_rmw_tc1_i;
    end

  end else begin : g_n_l2cc
    always @*
    begin
      afb_l2_hit                 = zero;
      afb_l2_way                 = {4{zero}};
      afb_l2_victim_valid        = zero;
      afb_l2_victim_dirty        = zero;
      afb_l2_victim_cu           = zero;
      afb_l2_victim_alloc        = zero;
      afb_l2_victim_shareability = {2{zero}};
      afb_l2db_rmw               = zero;
    end
  end endgenerate

  assign next_afb_done = (afb_valid & ~active_afb_tc2_i & ~active_afb_tc3_i &
                          ~|next_snoop_req &
                          ~|next_snoop_resp_pending &
                          ~next_master_req &
                          ~next_ramctl_req &
                          ~tagctl_pass_needed_tc4 &
                          ~next_afb_l2_victim_waddr_hz &
                           ((tagctl_state == STATE_IDLE) |
                            ((tagctl_state == STATE_TC4) & ~flush_tc4_i)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    afb_done <= 1'b0;
  end else if (afb_valid_en) begin
    afb_done <= next_afb_done;
  end

  assign afb_done_o = afb_done;

  // Indicate if any master write was done as part of this request.
  assign next_afb_write_done = afb_valid & (afb_write_done | master_req);

  always @(posedge clk)
  if (afb_valid_en) begin
    afb_write_done <= next_afb_write_done;
  end

  assign afb_write_done_o = afb_write_done;


  assign requestor_cpu_mask = 4'b0001 << afb_req_id[4:3];

  always @*
  case (afb_req_id[4:3])
    2'b00:   requestor_way_mask = 16'hFFF0;
    2'b01:   requestor_way_mask = 16'hFF0F;
    2'b10:   requestor_way_mask = 16'hF0FF;
    2'b11:   requestor_way_mask = 16'h0FFF;
    default: requestor_way_mask = 16'hxxxx;
  endcase

  assign requestor_hit_tc3 = |(l1_lookup_hit_cpus_tc3_i & requestor_cpu_mask);

  assign non_requestor_hit_tc3 = |(l1_lookup_hit_cpus_tc3_i & ~requestor_cpu_mask);

  // Indicate if this AFB requires, or might require in the future, access to
  // the master for a read. Because snoops must make forward progress, we must ensure that
  // at all times there is at least one AFB that does not require access to the
  // master that might not make forward progress.
  assign afb_requires_master_o = afb_valid & (((afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                               ~`CA53_REQBUF_IS_SNOOP(afb_req_id)) |
                                              (afb_req_pass == `CA53_TAGCTL_PASS_MASTER_R));

  assign afb_req_single_o = afb_req_single;

  //----------------------------------------------------------------------------
  //  Snoop requests
  //----------------------------------------------------------------------------


  // Snoop requests are arbitrated in tc3, but are not sent until tc4 when the
  // result of all hazard checking is known. The address and other information
  // being sent is muxed in tc4 based on the arbitration done in tc3.


  assign requestor_cpu = {afb_req_id[5:3] == 3'b011,
                          afb_req_id[5:3] == 3'b010,
                          afb_req_id[5:3] == 3'b001,
                          afb_req_id[5:3] == 3'b000};

  // Only calculate the priority CPU if there is a valid request, to avoid
  // x propagating to the arbiter outputs (even though the output will not
  // be used).
  assign priority_cpu_req_tc3 = ({4{active_afb_tc3_i}} & l1_lookup_hit_cpus_tc3_i &
                                 ~({4{req_type == `CA53_AFB_REQ_CLEANUNIQUE}} & requestor_cpu_mask));

  // Select the highest priority CPU that hit
  ca53_rr_arb #(.WIDTH(NUM_CPUS)) u_snoop_arb (
    .clk          (clk),
    .reset_n      (reset_n),
    .rr_counter_i (round_robin_tc3_i[`CA53_LOG2(NUM_CPUS)-1:0]),
    .requests_i   (priority_cpu_req_tc3[NUM_CPUS-1:0]),
    .arb_o        (priority_cpu_tc3[NUM_CPUS-1:0])
  );

  generate for (i = NUM_CPUS; i < 4; i = i + 1) begin : g_pri_ncpu
    // Tie-offs for unused CPUs
    assign priority_cpu_tc3[i] = 1'b0;
  end endgenerate

  assign next_afb_snoop_data_cpu_tc4 = `CA53_CPU_ENC(priority_cpu_tc3);

  always @(posedge clk)
  if (active_afb_tc3_i) begin
    afb_snoop_data_cpu_tc4 <= next_afb_snoop_data_cpu_tc4;
  end
  
  assign afb_snoop_data_cpu_tc4_o = afb_snoop_data_cpu_tc4;

  assign req_might_priority_snoop_tc3 = (((((req_type == `CA53_AFB_REQ_READSHARED) |
                                            ((req_type == `CA53_AFB_REQ_READUNIQUE) & ~l2_hit_tc3_i) |
                                            (req_type == `CA53_AFB_REQ_WRITEUNIQUE) |
                                            (req_type == `CA53_AFB_REQ_READONCE) |
                                            ((req_type == `CA53_AFB_REQ_CLEANUNIQUE) &
                                             ~l2_hit_dirty_tc3_i &
                                             ~cluster_unique_tc3_i) |
                                            (((req_type == `CA53_AFB_REQ_CLEANSHARED) |
                                              (req_type == `CA53_AFB_REQ_CLEANINVALID) |
                                              (req_type == `CA53_AFB_REQ_MAKEINVALID)) &
                                             ~l2_hit_dirty_tc3_i)) |
                                           (((req_type == `CA53_AFB_SNP_READONCE) |
                                             (req_type == `CA53_AFB_SNP_READSHARED) |
                                             (req_type == `CA53_AFB_SNP_READCLEAN) |
                                             (req_type == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                             (req_type == `CA53_AFB_SNP_READUNIQUE) |
                                             (req_type == `CA53_AFB_SNP_CLEANSHARED) |
                                             (req_type == `CA53_AFB_SNP_CLEANINVALID)) & ~l2_hit_tc3_i)) &
                                          ~afb_snp_l2db_valid &
                                          (afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE)) |
                                         ((req_type == `CA53_AFB_REQ_WRITEUNIQUE) &
                                          (afb_req_pass == `CA53_TAGCTL_PASS_LOOKUP)));

  // Signal to tagctl that the round robin counter for priority snoops has been
  // used and hence should be incremented.
  assign afb_update_rr_tc3_o = (active_afb_tc3_i & req_might_priority_snoop_tc3 &
                                |(l1_lookup_hit_cpus_tc3_i & ~priority_cpu_tc3));

  // Store which CPU is being sent a priority snoop, so that we can select the
  // correct snoop type in the following cycles.
  assign priority_snoop_tc3 = {4{req_might_priority_snoop_tc3}} & priority_cpu_tc3;

  always @(posedge clk)
  if (active_afb_tc3_i) begin
    afb_priority_snoop <= priority_snoop_tc3[NUM_CPUS-1:0];
  end

  assign afb_pri_snoop[NUM_CPUS-1:0] = afb_priority_snoop;

  generate for (i = NUM_CPUS; i < 4; i = i + 1) begin : g_afb_pri_ncpu
    // Tie-offs for unused CPUs
    assign afb_pri_snoop[i] = 1'b0;
  end endgenerate

  // Modify the cluster unique status if the configuration and memory type
  // indicate that no other cluster should be coherent with this line.
  assign afb_force_cluster_unique_tc3_o = ((`CA53_MEM_O_SHAREABLE(afb_req_attrs) ? ~tagctl_broadcastouter_i :
                                            `CA53_MEM_SHAREABLE(afb_req_attrs)   ? ~tagctl_broadcastinner_i :
                                                                                   1'b1));

  always @*
  case (afb_req_pass)
    `CA53_TAGCTL_PASS_SERIALISE: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP,
        `CA53_AFB_REQ_WRITENOSNOOP:   snoops_needed_tc3 = 4'b0000;
        `CA53_AFB_REQ_READONCE:       snoops_needed_tc3 = priority_cpu_tc3 & ~{4{l2_hit_tc3_i}};
        `CA53_AFB_REQ_READNONE:       snoops_needed_tc3 = 4'b0000;
        `CA53_AFB_REQ_WRITEUNIQUE:    snoops_needed_tc3 = l1_lookup_hit_cpus_tc3_i & {4{(l2_hit_tc3_i |
                                                                                         (L2_CACHE == 0) |
                                                                                         ~afb_l2db_full |
                                                                                         ~l2_victim_valid_tc3_i) &
                                                                                        cluster_unique_tc3_i}};
        `CA53_AFB_REQ_READSHARED:     snoops_needed_tc3 = (priority_cpu_tc3 & ~{4{l2_hit_tc3_i}}) | l1_victim_hit_cpus_tc3_i;
        `CA53_AFB_REQ_READUNIQUE:     snoops_needed_tc3 = l1_lookup_hit_cpus_tc3_i | l1_victim_hit_cpus_tc3_i;
        `CA53_AFB_REQ_CLEANUNIQUE:    snoops_needed_tc3 = ({4{requestor_hit_tc3 &
                                                            ~(afb_req_lock &
                                                              ~cluster_unique_tc3_i &
                                                              l2_hit_dirty_tc3_i)}} &
                                                           l1_lookup_hit_cpus_tc3_i &
                                                           ~requestor_cpu_mask);
        `CA53_AFB_REQ_CLEANSHARED:    snoops_needed_tc3 = (l1_lookup_hit_cpus_tc3_i &
                                                           ~{4{l2_hit_dirty_tc3_i}});
        `CA53_AFB_REQ_CLEANINVALID,
        `CA53_AFB_REQ_MAKEINVALID:    snoops_needed_tc3 = l1_lookup_hit_cpus_tc3_i;
        `CA53_AFB_REQ_DMB,
        `CA53_AFB_REQ_DSB:            snoops_needed_tc3 = 4'b0000;
        `CA53_AFB_REQ_DVM:            snoops_needed_tc3 = ((afb_victim_addr[14:12] == `CA53_DVM_TLBINV) |
                                                           (afb_victim_addr[14:12] == `CA53_DVM_ICINV)) ? requestor_cpu : afb_smp_en;
        `CA53_AFB_REQ_CLEANSETWAY,
        `CA53_AFB_REQ_CLEANINVSETWAY: snoops_needed_tc3 = l1_victim_hit_cpus_tc3_i;
        `CA53_AFB_REQ_ECCCLEAN:       snoops_needed_tc3 = requestor_cpu;
        `CA53_AFB_SNP_READONCE,
        `CA53_AFB_SNP_READSHARED,
        `CA53_AFB_SNP_READNOTSHAREDDIRTY,
        `CA53_AFB_SNP_READCLEAN:      snoops_needed_tc3 = (ACE != 0) ? (priority_cpu_tc3 & ~{4{l2_hit_tc3_i | afb_snp_l2db_valid}}) :
                                                                       (l1_lookup_hit_cpus_tc3_i &
                                                                        ~{4{l2_hit_dirty_tc3_i |
                                                                            (afb_snp_l2db_valid & afb_snp_l2db_dirty)}});
        `CA53_AFB_SNP_CLEANSHARED:    snoops_needed_tc3 = (l1_lookup_hit_cpus_tc3_i &
                                                           ~{4{l2_hit_dirty_tc3_i |
                                                               (afb_snp_l2db_valid & afb_snp_l2db_dirty)}});
        `CA53_AFB_SNP_READUNIQUE,
        `CA53_AFB_SNP_CLEANINVALID,
        `CA53_AFB_SNP_MAKEINVALID:    snoops_needed_tc3 = l1_lookup_hit_cpus_tc3_i;
        `CA53_AFB_SNP_DVM_MESSAGE:    snoops_needed_tc3 = afb_smp_en;
        `CA53_AFB_SNP_CLEANINVSETWAY: snoops_needed_tc3 = 4'b0000;
        default:                      snoops_needed_tc3 = 4'bxxxx;
      endcase
    end
    `CA53_TAGCTL_PASS_LOOKUP:         snoops_needed_tc3 = l1_lookup_hit_cpus_tc3_i;
    `CA53_TAGCTL_PASS_MASTER_R,
    `CA53_TAGCTL_PASS_MASTER_W,
    `CA53_TAGCTL_PASS_VICTIM,
    `CA53_TAGCTL_PASS_L2_VICTIM:      snoops_needed_tc3 = 4'b0000;
    default:                          snoops_needed_tc3 = 4'bxxxx;
  endcase

  assign afb_ac_ready = {afb_cpu3_ac_ready_i,
                         afb_cpu2_ac_ready_i,
                         afb_cpu1_ac_ready_i,
                         afb_cpu0_ac_ready_i};

  assign two_part_dvm = ((req_type == `CA53_AFB_REQ_DVM) |
                         (req_type == `CA53_AFB_SNP_DVM_MESSAGE)) & afb_victim_addr[0];

  // Record which CPUs need to be sent snoops, and haven't accepted the snoop
  // yet. For two part DVM ops we must keep this set after the first part is
  // sent, to ensure the second part then gets sent.
  assign next_snoop_req = ((({4{active_afb_tc3_i}} & snoops_needed_tc3) | snoop_req) &
                           (~afb_ac_ready | ({4{two_part_dvm}} & ~first_dvm_snoop_sent)) &
                           ~{4{flush_afb_tc3_i |
                               flush_afb_tc4_i}});

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    snoop_req <= 4'b0000;
  end else if (afb_valid_en) begin
    snoop_req <= next_snoop_req;
  end

  // Make a request for tagctl to arbitrate snoops with other AFBs.
  assign afb_snoop_req_o = tagctl_mbistreq_i ? {4{AFB_NUM == 3'b000}} : snoop_req;

  // Record when the first snoop of a 2 part DVM has been sent to each CPU, so
  // that we know when to send the second part.
  assign next_first_dvm_snoop_sent = (({4{two_part_dvm}} & snoop_req & afb_ac_ready) |
                                      first_dvm_snoop_sent) & ~{4{alloc_afb_tc1_i}};

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    first_dvm_snoop_sent <= 4'b0000;
  end else if (afb_valid_en) begin
    first_dvm_snoop_sent <= next_first_dvm_snoop_sent;
  end

  assign afb_snoop_second_dvm_o = snoop_req & first_dvm_snoop_sent;

  // We must send a snoop to the requestor CPU to read the L1 victim line if
  // it is doing a linefill.
  assign victim_snoop = ((({4{(req_type == `CA53_AFB_REQ_READSHARED) |
                              (req_type == `CA53_AFB_REQ_READUNIQUE) |
                              (req_type == `CA53_AFB_REQ_CLEANSETWAY) |
                              (req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                              (req_type == `CA53_AFB_REQ_ECCCLEAN)}} & requestor_cpu) |
                          ({4{(req_type == `CA53_AFB_REQ_DVM) |
                              (req_type == `CA53_AFB_SNP_DVM_MESSAGE)}} & ~first_dvm_snoop_sent)) &
                         ~{4{tagctl_mbistreq_i}});

  always @*
  case (req_type)
    `CA53_AFB_REQ_READSHARED,
    `CA53_AFB_REQ_READUNIQUE:     victim_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_DVM:            victim_snoop_type = `CA53_SNOOP_DVM;
    `CA53_AFB_REQ_CLEANSETWAY:    victim_snoop_type = `CA53_SNOOP_CLEANSHARED;
    `CA53_AFB_REQ_CLEANINVSETWAY: victim_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_ECCCLEAN:       victim_snoop_type = afb_l1_victim_hit ? `CA53_SNOOP_CLEANINVALID : `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_SNP_DVM_MESSAGE:    victim_snoop_type = `CA53_SNOOP_DVM;
    default:                      victim_snoop_type = 4'bxxxx;
  endcase

  // When one CPU has priority over the rest, then either it gets sent a snoop
  // when the others don't, or it gets send a different type of snoop from the
  // others. The typical case for this is to ensure that only one CPU returns
  // data and the others just alter their state without returning data.
  always @*
  case (req_type)
    `CA53_AFB_REQ_READONCE:       priority_snoop_type = `CA53_SNOOP_READONCE;
    `CA53_AFB_REQ_WRITEUNIQUE:    priority_snoop_type = afb_l2db_full ? `CA53_SNOOP_MAKEINVALID : `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_READSHARED:     priority_snoop_type = `CA53_SNOOP_READSHARED;
    `CA53_AFB_REQ_READUNIQUE:     priority_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_CLEANUNIQUE:    priority_snoop_type = afb_req_lock ? `CA53_SNOOP_CLEANSHARED : `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_CLEANSHARED:    priority_snoop_type = `CA53_SNOOP_CLEANSHARED;
    `CA53_AFB_REQ_CLEANINVALID:   priority_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_REQ_MAKEINVALID:    priority_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_SNP_READONCE:       priority_snoop_type = `CA53_SNOOP_READONCE;
    `CA53_AFB_SNP_READSHARED,
    `CA53_AFB_SNP_READNOTSHAREDDIRTY,
    `CA53_AFB_SNP_READCLEAN:      priority_snoop_type = `CA53_SNOOP_READMAKESHARED;
    `CA53_AFB_SNP_READUNIQUE:     priority_snoop_type = `CA53_SNOOP_CLEANINVALID;
    `CA53_AFB_SNP_CLEANSHARED:    priority_snoop_type = `CA53_SNOOP_CLEANSHARED;
    `CA53_AFB_SNP_CLEANINVALID:   priority_snoop_type = `CA53_SNOOP_CLEANINVALID;
    default:                      priority_snoop_type = 4'bxxxx;
  endcase

  always @*
  case (req_type)
    `CA53_AFB_REQ_WRITEUNIQUE:    default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_REQ_READUNIQUE:     default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_REQ_CLEANUNIQUE:    default_snoop_type = (afb_req_lock &
                                                        ~afb_cluster_unique &
                                                        (afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE)) ? `CA53_SNOOP_MAKECLEANSHARED :
                                                                                                         `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_REQ_CLEANSHARED:    default_snoop_type = `CA53_SNOOP_MAKECLEANSHARED;
    `CA53_AFB_REQ_CLEANINVALID:   default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_REQ_MAKEINVALID:    default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_REQ_DVM:            default_snoop_type = `CA53_SNOOP_DVM;
    `CA53_AFB_SNP_READUNIQUE:     default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_SNP_READSHARED,
    `CA53_AFB_SNP_READCLEAN,
    `CA53_AFB_SNP_READONCE:       default_snoop_type = `CA53_SNOOP_GETDIRTY;
    `CA53_AFB_SNP_CLEANSHARED:    default_snoop_type = `CA53_SNOOP_MAKECLEANSHARED;
    `CA53_AFB_SNP_CLEANINVALID,
    `CA53_AFB_SNP_MAKEINVALID:    default_snoop_type = `CA53_SNOOP_MAKEINVALID;
    `CA53_AFB_SNP_DVM_MESSAGE:    default_snoop_type = `CA53_SNOOP_DVM;
    default:                      default_snoop_type = 4'bxxxx;
  endcase

  // Select the type of snoop to send depending on which CPU it is.
  assign afb_cpu0_ac_snoop_o = victim_snoop[0]  ? victim_snoop_type :
                               afb_pri_snoop[0] ? priority_snoop_type :
                                                  default_snoop_type;
  assign afb_cpu1_ac_snoop_o = victim_snoop[1]  ? victim_snoop_type :
                               afb_pri_snoop[1] ? priority_snoop_type :
                                                  default_snoop_type;
  assign afb_cpu2_ac_snoop_o = victim_snoop[2]  ? victim_snoop_type :
                               afb_pri_snoop[2] ? priority_snoop_type :
                                                  default_snoop_type;
  assign afb_cpu3_ac_snoop_o = victim_snoop[3]  ? victim_snoop_type :
                               afb_pri_snoop[3] ? priority_snoop_type :
                                                  default_snoop_type;

  assign afb_cpu0_ac_l2db_id_o = tagctl_mbistreq_i ? {4{afb_second_l2db[1:0] == 2'b00}} :
                                 victim_snoop[0]   ? victim_l2db : primary_l2db;
  assign afb_cpu1_ac_l2db_id_o = tagctl_mbistreq_i ? {4{afb_second_l2db[1:0] == 2'b01}} :
                                 victim_snoop[1]   ? victim_l2db : primary_l2db;
  assign afb_cpu2_ac_l2db_id_o = tagctl_mbistreq_i ? {4{afb_second_l2db[1:0] == 2'b10}} :
                                 victim_snoop[2] ? victim_l2db : primary_l2db;
  assign afb_cpu3_ac_l2db_id_o = tagctl_mbistreq_i ? {4{afb_second_l2db[1:0] == 2'b11}} :
                                 victim_snoop[3] ? victim_l2db : primary_l2db;

  // Indicate that this is an ECC clean snoop, and therefore only the index bits of the request are valid.
  assign ac_addr0 = ((req_type == `CA53_AFB_REQ_DVM) |
                     (req_type == `CA53_AFB_SNP_DVM_MESSAGE)) ? afb_victim_addr[0] : (req_type == `CA53_AFB_REQ_ECCCLEAN);

  assign afb_cpu0_ac_addr_o = victim_snoop[0] ? {afb_victim_addr[40:1], ac_addr0} : afb_primary_addr;
  assign afb_cpu1_ac_addr_o = victim_snoop[1] ? {afb_victim_addr[40:1], ac_addr0} : afb_primary_addr;
  assign afb_cpu2_ac_addr_o = victim_snoop[2] ? {afb_victim_addr[40:1], ac_addr0} : afb_primary_addr;
  assign afb_cpu3_ac_addr_o = victim_snoop[3] ? {afb_victim_addr[40:1], ac_addr0} : afb_primary_addr;

  assign afb_cpu0_ac_way_o = afb_l1_hit_ways[3:0];
  assign afb_cpu1_ac_way_o = afb_l1_hit_ways[7:4];
  assign afb_cpu2_ac_way_o = afb_l1_hit_ways[11:8];
  assign afb_cpu3_ac_way_o = afb_l1_hit_ways[15:12];

  // Only look at responses to requests made from this AFB.
  assign afb_cr_valid = {cpuslv3_cr_valid_i & (cpuslv3_cr_id_i == AFB_NUM[2:0]),
                         cpuslv2_cr_valid_i & (cpuslv2_cr_id_i == AFB_NUM[2:0]),
                         cpuslv1_cr_valid_i & (cpuslv1_cr_id_i == AFB_NUM[2:0]),
                         cpuslv0_cr_valid_i & (cpuslv0_cr_id_i == AFB_NUM[2:0])};

  // Store which CPUs we are waiting for a response from, in order to know when
  // all snoops are complete. DVMs don't get a response, so there is nothing to
  // wait for once the snoop is sent. However DVM syncs do get a complete
  // response, unless the CPU has smp_en low, and so if smp_en is low then the
  // AFB must synthesise a complete response. It records that here.
  assign next_snoop_resp_pending = ((({4{active_afb_tc3_i}} &
                                      (((req_type == `CA53_AFB_REQ_DVM) |
                                        (req_type == `CA53_AFB_SNP_DVM_MESSAGE)) ? ({4{dvm_sync}} & ~afb_smp_en) :
                                                                                   snoops_needed_tc3)) |
                                     (snoop_resp_pending & ~clear_snoop_resp_pending)) & ~{4{flush_afb_tc3_i |
                                                                                             flush_afb_tc4_i}});

  // For synthesising DVM completes, we must not send the complete on the same
  // cycle as the CPU is sending a complete, as the tracking logic will only
  // count one per cycle. This situation can only occur if there is a complete
  // outstanding at the time smp_en is deasserted.
  assign clear_snoop_resp_pending = (afb_cr_valid |
                                     ({4{dvm_sync & ~active_afb_tc4_i}} &
                                      ~{(NUM_CPUS > 3) & dcu_cpu3_dvm_complete_i,
                                        (NUM_CPUS > 2) & dcu_cpu2_dvm_complete_i,
                                        (NUM_CPUS > 1) & dcu_cpu1_dvm_complete_i,
                                        (NUM_CPUS > 0) & dcu_cpu0_dvm_complete_i}));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    snoop_resp_pending <= 4'b0000;
  end else if (afb_valid_en) begin
    snoop_resp_pending <= next_snoop_resp_pending;
  end

  // Tell the DVM complete logic that a CPU would have sent a complete.
  assign afb_dvm_complete_o = {4{dvm_sync}} & snoop_resp_pending & ~{4{active_afb_tc4_i}};

  assign snp_active = (snoop_resp_pending |
                       snoop_req |
                       first_dvm_snoop_sent |
                       ({4{active_afb_tc3_i}} & snoops_needed_tc3));

  // Indicate to the cpuslvs when we might be sending a snoop in the following
  // cycle, for use in regional clock gating.
  assign afb_cpuslv0_snp_active_o = snp_active[0];
  assign afb_cpuslv1_snp_active_o = snp_active[1];
  assign afb_cpuslv2_snp_active_o = snp_active[2];
  assign afb_cpuslv3_snp_active_o = snp_active[3];



  // Mask out snoops waiting for a response from the requestor CPU.
  assign snoop_other_resp_pending = snoop_resp_pending & ~({4{(req_type == `CA53_AFB_REQ_READSHARED) |
                                                              (req_type == `CA53_AFB_REQ_READUNIQUE)}} & requestor_cpu);

  // Record if any of the snoops indicate that the CPU held dirty data.
  // This may be a different CPU than that which is providing the data, but that
  // doesn't matter because the data must be the same in all CPUs that it is
  // present in.
  assign new_snoop_resp_dirty = (snoop_resp_dirty |
                                 (|(afb_cr_valid & {cpuslv3_cr_dirty_i,
                                                    cpuslv2_cr_dirty_i,
                                                    cpuslv1_cr_dirty_i,
                                                    cpuslv0_cr_dirty_i} &
                                    ~(({4{(req_type == `CA53_AFB_REQ_READUNIQUE)}} & requestor_cpu) |
                                      ({4{(req_type == `CA53_AFB_REQ_READSHARED)}} & (requestor_cpu |
                                                                                      ~{cpuslv3_cr_migratory_i,
                                                                                        cpuslv2_cr_migratory_i,
                                                                                        cpuslv1_cr_migratory_i,
                                                                                        cpuslv0_cr_migratory_i}))))));

  // Record the outer attributes of the snoop. This should be the same for all
  // CPUs that hold the data, although in some unpredictable cases it may not be
  // and so we always pick the one from the CPU that is returning the data.
  assign new_snoop_resp_alloc = (snoop_resp_alloc |
                                 (afb_cr_valid[3] & afb_pri_snoop[3] & cpuslv3_cr_alloc_i) |
                                 (afb_cr_valid[2] & afb_pri_snoop[2] & cpuslv2_cr_alloc_i) |
                                 (afb_cr_valid[1] & afb_pri_snoop[1] & cpuslv1_cr_alloc_i) |
                                 (afb_cr_valid[0] & afb_pri_snoop[0] & cpuslv0_cr_alloc_i));

  // Record if any of the snoops indicate that the line was migratory. This
  // can only happen if there is only one snoop.
  assign new_snoop_resp_migratory = (snoop_resp_migratory |
                                     (|(afb_cr_valid & {cpuslv3_cr_migratory_i,
                                                        cpuslv2_cr_migratory_i,
                                                        cpuslv1_cr_migratory_i,
                                                        cpuslv0_cr_migratory_i} & ~requestor_cpu)));

  assign next_snoop_resp_dirty     = new_snoop_resp_dirty     & ~alloc_afb_tc1_i;
  assign next_snoop_resp_alloc     = new_snoop_resp_alloc     & ~alloc_afb_tc1_i;
  assign next_snoop_resp_migratory = new_snoop_resp_migratory & ~alloc_afb_tc1_i;

  assign snoop_resp_en = |afb_cr_valid | alloc_afb_tc1_i;

  always @(posedge clk)
  if (snoop_resp_en) begin
    snoop_resp_dirty     <= next_snoop_resp_dirty;
    snoop_resp_alloc     <= next_snoop_resp_alloc;
    snoop_resp_migratory <= next_snoop_resp_migratory;
  end

  // When all primary snoops have been done, let the reqbuf know. This could
  // be before or after the victim snoop (if any).
  assign afb_snoop_resp_valid_o = ((|(afb_cr_valid & snoop_other_resp_pending) &
                                    ~|(snoop_other_resp_pending & ~afb_cr_valid)) |
                                   ((req_type == `CA53_AFB_REQ_DVM) &
                                    (afb_done |
                                     (afb_valid &
                                      ~active_afb_tc2_i &
                                      ~active_afb_tc3_i &
                                      ~|snoop_req))));

  assign afb_snoop_resp_dirty_o     = new_snoop_resp_dirty;
  assign afb_snoop_resp_alloc_o     = new_snoop_resp_alloc;
  assign afb_snoop_resp_migratory_o = new_snoop_resp_migratory;

  // When the L1 victim snoop completes, let the reqbuf know what the result was.
  assign afb_snoop_resp_victim_valid_o = |(afb_cr_valid & requestor_cpu);

  assign afb_snoop_resp_victim_dirty_o = |(afb_cr_valid & requestor_cpu & {cpuslv3_cr_dirty_i,
                                                                           cpuslv2_cr_dirty_i,
                                                                           cpuslv1_cr_dirty_i,
                                                                           cpuslv0_cr_dirty_i});

  assign afb_snoop_resp_victim_age_o = ((afb_cr_valid[3] & requestor_cpu[3] & cpuslv3_cr_age_i) |
                                        (afb_cr_valid[2] & requestor_cpu[2] & cpuslv2_cr_age_i) |
                                        (afb_cr_valid[1] & requestor_cpu[1] & cpuslv1_cr_age_i) |
                                        (afb_cr_valid[0] & requestor_cpu[0] & cpuslv0_cr_age_i));


  assign afb_snoop_resp_victim_alloc_o = |(afb_cr_valid & requestor_cpu & {cpuslv3_cr_alloc_i,
                                                                           cpuslv2_cr_alloc_i,
                                                                           cpuslv1_cr_alloc_i,
                                                                           cpuslv0_cr_alloc_i});

  //----------------------------------------------------------------------------
  //  L2DB control
  //----------------------------------------------------------------------------

  always @*
  case (afb_req_pass)
    `CA53_TAGCTL_PASS_SERIALISE: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP:    primary_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_WRITENOSNOOP:   primary_l2db_needed_tc3 = (afb_req_pass == `CA53_TAGCTL_PASS_L2DB);
        `CA53_AFB_REQ_READONCE:       primary_l2db_needed_tc3 = l1_lookup_hit_tc3_i | l2_hit_tc3_i;
        `CA53_AFB_REQ_READNONE:       primary_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_WRITEUNIQUE:    primary_l2db_needed_tc3 = 1'b1;
        `CA53_AFB_REQ_READSHARED,
        `CA53_AFB_REQ_READUNIQUE:     primary_l2db_needed_tc3 = l1_lookup_hit_tc3_i | l2_hit_tc3_i;
        `CA53_AFB_REQ_CLEANUNIQUE:    primary_l2db_needed_tc3 = (requestor_hit_tc3 &
                                                               (non_requestor_hit_tc3 | l2_hit_dirty_tc3_i) &
                                                               ~cluster_unique_tc3_i);
        `CA53_AFB_REQ_CLEANSHARED,
        `CA53_AFB_REQ_CLEANINVALID,
        `CA53_AFB_REQ_MAKEINVALID:    primary_l2db_needed_tc3 = l1_lookup_hit_tc3_i | l2_hit_dirty_tc3_i;
        `CA53_AFB_REQ_DMB,
        `CA53_AFB_REQ_DSB,
        `CA53_AFB_REQ_DVM,
        `CA53_AFB_REQ_CLEANSETWAY,
        `CA53_AFB_REQ_CLEANINVSETWAY,
        `CA53_AFB_SNP_CLEANINVSETWAY,
        `CA53_AFB_REQ_ECCCLEAN:       primary_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_SNP_READONCE,
        `CA53_AFB_SNP_READSHARED,
        `CA53_AFB_SNP_READCLEAN,
        `CA53_AFB_SNP_READNOTSHAREDDIRTY,
        `CA53_AFB_SNP_READUNIQUE:     primary_l2db_needed_tc3 = l1_lookup_hit_tc3_i | l2_hit_tc3_i;
        `CA53_AFB_SNP_CLEANSHARED,
        `CA53_AFB_SNP_CLEANINVALID:   primary_l2db_needed_tc3 = l1_lookup_hit_tc3_i | l2_hit_dirty_tc3_i;
        `CA53_AFB_SNP_MAKEINVALID,
        `CA53_AFB_SNP_DVM_COMPLETE,
        `CA53_AFB_SNP_DVM_MESSAGE:    primary_l2db_needed_tc3 = 1'b0;
        default:                      primary_l2db_needed_tc3 = 1'bx;
      endcase
    end
    `CA53_TAGCTL_PASS_LOOKUP,
    `CA53_TAGCTL_PASS_MASTER_R,
    `CA53_TAGCTL_PASS_MASTER_W,
    `CA53_TAGCTL_PASS_VICTIM,
    `CA53_TAGCTL_PASS_L2_VICTIM:      primary_l2db_needed_tc3 = (req_type == `CA53_AFB_REQ_WRITEUNIQUE);
    default:                          primary_l2db_needed_tc3 = 1'bx;
  endcase

  always @*
  case (afb_req_pass)
    `CA53_TAGCTL_PASS_SERIALISE: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP,
        `CA53_AFB_REQ_WRITENOSNOOP:   victim_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_READONCE:       victim_l2db_needed_tc3 = L2_CACHE ? (afb_req_read_alloc &
                                                                           l2_victim_valid_tc3_i &
                                                                           ~(l1_lookup_hit_tc3_i | l2_hit_tc3_i)) : 1'b0;
        `CA53_AFB_REQ_READNONE:       victim_l2db_needed_tc3 = L2_CACHE ? (l2_victim_valid_tc3_i &
                                                                         ~(l1_lookup_hit_tc3_i | l2_hit_tc3_i)) : 1'b0;
        `CA53_AFB_REQ_WRITEUNIQUE:    victim_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_READSHARED,
        `CA53_AFB_REQ_READUNIQUE:     victim_l2db_needed_tc3 = l1_victim_hit_tc3_i;
        `CA53_AFB_REQ_CLEANUNIQUE,
        `CA53_AFB_REQ_CLEANSHARED,
        `CA53_AFB_REQ_CLEANINVALID,
        `CA53_AFB_REQ_MAKEINVALID,
        `CA53_AFB_REQ_DMB,
        `CA53_AFB_REQ_DSB,
        `CA53_AFB_REQ_DVM:            victim_l2db_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_CLEANSETWAY,
        `CA53_AFB_REQ_CLEANINVSETWAY: victim_l2db_needed_tc3 = afb_primary_addr[1] ? l2_victim_valid_tc3_i : l1_victim_hit_tc3_i;
        `CA53_AFB_SNP_CLEANINVSETWAY: victim_l2db_needed_tc3 = l2_victim_valid_tc3_i;
        `CA53_AFB_REQ_ECCCLEAN:       victim_l2db_needed_tc3 = l1_victim_hit_tc3_i;
        `CA53_AFB_SNP_READONCE,
        `CA53_AFB_SNP_READSHARED,
        `CA53_AFB_SNP_READCLEAN,
        `CA53_AFB_SNP_READNOTSHAREDDIRTY,
        `CA53_AFB_SNP_READUNIQUE,
        `CA53_AFB_SNP_CLEANSHARED,
        `CA53_AFB_SNP_CLEANINVALID,
        `CA53_AFB_SNP_MAKEINVALID,
        `CA53_AFB_SNP_DVM_COMPLETE,
        `CA53_AFB_SNP_DVM_MESSAGE:    victim_l2db_needed_tc3 = 1'b0;
        default:                      victim_l2db_needed_tc3 = 1'bx;
      endcase
    end
    `CA53_TAGCTL_PASS_LOOKUP,
    `CA53_TAGCTL_PASS_MASTER_R,
    `CA53_TAGCTL_PASS_MASTER_W,
    `CA53_TAGCTL_PASS_VICTIM,
    `CA53_TAGCTL_PASS_L2_VICTIM:      victim_l2db_needed_tc3 = 1'b0;
    default:                          victim_l2db_needed_tc3 = 1'bx;
  endcase

  // Detect structural hazards due to lack of L2DBs once we know exactly how many are needed.
  assign afb_l2db_hazard_one_tc3 = (active_afb_tc3_i &
                                    (primary_l2db_needed_tc3 | victim_l2db_needed_tc3) &
                                    ~(afb_first_l2db_valid | afb_second_l2db_valid | afb_snp_l2db_valid));

  assign afb_l2db_hazard_both_tc3 = (active_afb_tc3_i &
                                     (primary_l2db_needed_tc3 & victim_l2db_needed_tc3) &
                                     ~(afb_first_l2db_valid & afb_second_l2db_valid));

  assign afb_l2db_hazard_tc3_o = afb_l2db_hazard_one_tc3 | afb_l2db_hazard_both_tc3;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    afb_l2db_hazard_both_tc4 <= 1'b0;
  end else if (afb_valid_en) begin
    afb_l2db_hazard_both_tc4 <= afb_l2db_hazard_both_tc3;
  end

  assign afb_l2db_hazard_both_tc4_o = active_afb_tc4_i & afb_l2db_hazard_both_tc4;

  assign primary_l2db = (afb_first_l2db_valid & (active_afb_tc2_i | ~afb_snp_l2db_valid)) ? afb_first_l2db : afb_second_l2db;
  assign victim_l2db = afb_second_l2db_valid ? afb_second_l2db : afb_first_l2db;

  assign afb_slv_l2db_o = primary_l2db;
  assign afb_slv_victim_l2db_tc4_o = victim_l2db;

  assign afb_first_l2db_release_tc3 = (active_afb_tc3_i &
                                       (afb_snp_l2db_valid | ~primary_l2db_needed_tc3) &
                                       ~(victim_l2db_needed_tc3 & ~afb_second_l2db_valid));

  assign afb_second_l2db_release_tc3 = (active_afb_tc3_i &
                                        (~victim_l2db_needed_tc3 &
                                         ~(primary_l2db_needed_tc3 & ~afb_first_l2db_valid)));

  always @(posedge clk)
  if (afb_valid_en) begin
    afb_first_l2db_release_tc4  <= afb_first_l2db_release_tc3;
    afb_second_l2db_release_tc4 <= afb_second_l2db_release_tc3;
  end

  generate for (i = 0; i < 11; i = i + 1) begin : g_l2db_ctl
    // Release when we know we don't need the L2DB, either because we don't have
    // any data for it or the request is flushed.
    assign afb_l2db_release_o[i] = (afb_valid & (req_type != `CA53_AFB_REQ_WRITEUNIQUE) &
                                    ((afb_first_l2db_valid & (afb_first_l2db == i[3:0]) &
                                      (afb_first_l2db_release_tc4 |
                                       flush_afb_tc2_i | flush_afb_tc3_i | flush_afb_tc4_i)) |
                                     (afb_second_l2db_valid & (afb_second_l2db == i[3:0]) &
                                      (afb_second_l2db_release_tc4 |
                                       flush_afb_tc2_i | flush_afb_tc3_i | flush_afb_tc4_i)) |
                                     ((tagctl_state == STATE_TC4) & ~flush_tc4_i &
                                      (afb_second_l2db == i[3:0]) &
                                      ~l2_victim_write_needed)));

    // For requests that must delay the last beat of data until all snoops to
    // other CPUs have completed, indicate when the snoops complete or are
    // not required.
    assign afb_l2db_snoops_done_o[i] = ((req_type == `CA53_AFB_REQ_READUNIQUE) &
                                        (afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                        (primary_l2db == i[3:0]) &
                                        (afb_l2_hit | (|(afb_l1_hit_ways & requestor_way_mask))) &
                                        ~flush_afb_tc4_i &
                                        ((active_afb_tc4_i & ~|snoop_other_resp_pending) |
                                         (|snoop_other_resp_pending & ~|(snoop_other_resp_pending & ~afb_cr_valid))));
  end endgenerate

  //----------------------------------------------------------------------------
  //  Master requests
  //----------------------------------------------------------------------------

  assign master_req_needed_tc2 = ((req_type == `CA53_AFB_REQ_READNOSNOOP) |
                                  (req_type == `CA53_AFB_REQ_DMB) |
                                  (req_type == `CA53_AFB_REQ_DSB) |
                                  ((req_type == `CA53_AFB_REQ_DVM) & tagctl_broadcastinner_i &
                                   ~((afb_victim_addr[14:12] == `CA53_DVM_TLBINV) |
                                     (afb_victim_addr[14:12] == `CA53_DVM_ICINV))));

  assign afb_clean_evict_needed_tc3 = (((`CA53_MEM_O_SHAREABLE(afb_req_attrs) & tagctl_broadcastouter_i) |
                                        (`CA53_MEM_SHAREABLE(afb_req_attrs)   & tagctl_broadcastinner_i)) &
                                       ((afb_req_cluster_unique &
                                         ~((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                           (req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                           (req_type == `CA53_AFB_REQ_ECCCLEAN) |
                                           (req_type == `CA53_AFB_REQ_CLEANSETWAY)) &
                                         tagctl_enable_writeevict_tc3_i) |
                                        ~tagctl_disable_evict_tc3_i));

  always @*
  case (afb_req_pass)
    `CA53_TAGCTL_PASS_SERIALISE: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP:    master_req_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_WRITENOSNOOP:   master_req_needed_tc3 = 1'b1;
        `CA53_AFB_REQ_READONCE,
        `CA53_AFB_REQ_READNONE,
        `CA53_AFB_REQ_READSHARED,
        `CA53_AFB_REQ_READUNIQUE:     master_req_needed_tc3 = ~l1_lookup_hit_tc3_i & ~l2_hit_tc3_i;
        `CA53_AFB_REQ_WRITEUNIQUE:    master_req_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_CLEANUNIQUE:    master_req_needed_tc3 = requestor_hit_tc3 &
                                                              ~non_requestor_hit_tc3 &
                                                              ~l2_hit_dirty_tc3_i &
                                                              ~cluster_unique_tc3_i;
        `CA53_AFB_REQ_CLEANSHARED,
        `CA53_AFB_REQ_CLEANINVALID,
        `CA53_AFB_REQ_MAKEINVALID:    master_req_needed_tc3 = (((`CA53_MEM_O_SHAREABLE(afb_req_attrs) &
                                                                 tagctl_broadcastouter_i) |
                                                                (`CA53_MEM_SHAREABLE(afb_req_attrs) &
                                                                 tagctl_broadcastinner_i) |
                                                                tagctl_broadcastcachemaint_i) &
                                                               ~l1_lookup_hit_tc3_i &
                                                               ~l2_hit_tc3_i);
        `CA53_AFB_REQ_DMB,
        `CA53_AFB_REQ_DSB,
        `CA53_AFB_REQ_DVM,
        `CA53_AFB_REQ_CLEANSETWAY,
        `CA53_AFB_REQ_CLEANINVSETWAY,
        `CA53_AFB_REQ_ECCCLEAN,
        `CA53_AFB_SNP_READONCE,
        `CA53_AFB_SNP_READSHARED,
        `CA53_AFB_SNP_READCLEAN,
        `CA53_AFB_SNP_READNOTSHAREDDIRTY,
        `CA53_AFB_SNP_READUNIQUE,
        `CA53_AFB_SNP_CLEANSHARED,
        `CA53_AFB_SNP_CLEANINVALID,
        `CA53_AFB_SNP_MAKEINVALID,
        `CA53_AFB_SNP_CLEANINVSETWAY,
        `CA53_AFB_SNP_DVM_MESSAGE:    master_req_needed_tc3 = 1'b0;
        default:                      master_req_needed_tc3 = 1'bx;
      endcase
    end
    `CA53_TAGCTL_PASS_LOOKUP:         master_req_needed_tc3 = 1'b0;
    `CA53_TAGCTL_PASS_MASTER_R,
    `CA53_TAGCTL_PASS_MASTER_W:       master_req_needed_tc3 = 1'b1;
    `CA53_TAGCTL_PASS_VICTIM: begin
      case (req_type)
        `CA53_AFB_REQ_READONCE,
        `CA53_AFB_REQ_READNONE,
        `CA53_AFB_REQ_WRITEUNIQUE:    master_req_needed_tc3 = 1'b0;
        `CA53_AFB_REQ_READSHARED,
        `CA53_AFB_REQ_READUNIQUE,
        `CA53_AFB_REQ_CLEANINVSETWAY,
        `CA53_AFB_SNP_CLEANINVSETWAY,
        `CA53_AFB_REQ_ECCCLEAN:       master_req_needed_tc3 = (afb_req_dirty | (afb_clean_evict_needed_tc3 & ~l1_lookup_hit_tc3_i));
        `CA53_AFB_REQ_CLEANSETWAY:    master_req_needed_tc3 = (afb_req_dirty | ((L2_CACHE != 0) &
                                                                              afb_clean_evict_needed_tc3 & ~l1_lookup_hit_tc3_i));
        default:                      master_req_needed_tc3 = 1'bx;
      endcase
    end
    `CA53_TAGCTL_PASS_L2_VICTIM:      master_req_needed_tc3 = 1'b0;
    default:                          master_req_needed_tc3 = 1'bx;
  endcase

  // Because WriteUniques can get an ECC error on the same pass as making a
  // master write request, they should not make the request until tc4, otherwise
  // the L2DB will not be ready to recieve the waddr info.
  assign master_req_needed_tc4 = (((req_type == `CA53_AFB_REQ_WRITEUNIQUE) &
                                   (((afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                     ~(afb_cluster_unique &
                                       ((afb_l1_hit | afb_l2_hit) |
                                        ((L2_CACHE != 0) & `CA53_MEM_WBWA(afb_req_attrs) &
                                         afb_l2db_full)))) |
                                    ((afb_req_pass == `CA53_TAGCTL_PASS_LOOKUP) &
                                     (L2_CACHE == 0) &
                                     ~afb_l1_hit))) |
                                  (((req_type == `CA53_AFB_REQ_READONCE) |
                                    (req_type == `CA53_AFB_REQ_READNONE) |
                                    (req_type == `CA53_AFB_REQ_WRITEUNIQUE)) &
                                   (afb_req_pass == `CA53_TAGCTL_PASS_VICTIM) &
                                   (afb_req_dirty | (afb_clean_evict_needed_tc3 & ~afb_l1_hit))));

  always @*
  case (afb_req_pass)
    `CA53_TAGCTL_PASS_SERIALISE: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP:  master_req_opcode = `CA53_REQ_OPCODE_READNOSNOOP;
        `CA53_AFB_REQ_WRITENOSNOOP: master_req_opcode = afb_l2db_full ? `CA53_REQ_OPCODE_WRITENOSNOOPFULL :
                                                                        `CA53_REQ_OPCODE_WRITENOSNOOP;
        `CA53_AFB_REQ_READONCE:     master_req_opcode = (afb_req_read_alloc &
                                                         (L2_CACHE != 0)) ? `CA53_REQ_OPCODE_READSHARED : `CA53_REQ_OPCODE_READONCE;
        `CA53_AFB_REQ_READNONE:     master_req_opcode = L2_CACHE ? `CA53_REQ_OPCODE_READSHARED : `CA53_REQ_OPCODE_READONCE;
        `CA53_AFB_REQ_WRITEUNIQUE:  master_req_opcode = (((L2_CACHE != 0) &
                                                          (`CA53_MEM_WBWA(afb_req_attrs) |
                                                           afb_l1_hit |
                                                           afb_l2_hit)) ? (afb_l2db_full ? `CA53_REQ_OPCODE_MAKEUNIQUE :
                                                                                           `CA53_REQ_OPCODE_READUNIQUE) :
                                                         ((ACE != 0) & afb_cluster_unique &
                                                          ~((L2_CACHE != 0) & `CA53_MEM_WBWA(afb_req_attrs) |
                                                            afb_l1_hit |
                                                            afb_l2_hit)) ? `CA53_REQ_OPCODE_WRITEBACK :
                                                         ((ACE != 0) &  afb_l2db_full) ? `CA53_REQ_OPCODE_MAKEUNIQUE :
                                                         ((ACE != 0) & ~afb_l2db_full) ? `CA53_REQ_OPCODE_CLEANUNIQUE :
                                                         (afb_l1_hit |
                                                          afb_l2_hit) ? (afb_l2db_full ? `CA53_REQ_OPCODE_MAKEUNIQUE :
                                                                                         `CA53_REQ_OPCODE_READUNIQUE) :
                                                         afb_l2db_full ? `CA53_REQ_OPCODE_WRITELINEUNIQUE :
                                                                         `CA53_REQ_OPCODE_WRITEUNIQUE);
        `CA53_AFB_REQ_READSHARED:   master_req_opcode = `CA53_REQ_OPCODE_READSHARED;
        `CA53_AFB_REQ_READUNIQUE:   master_req_opcode = `CA53_REQ_OPCODE_READUNIQUE;
        `CA53_AFB_REQ_CLEANUNIQUE:  master_req_opcode = `CA53_REQ_OPCODE_CLEANUNIQUE;
        `CA53_AFB_REQ_CLEANSHARED:  master_req_opcode = `CA53_REQ_OPCODE_CLEANSHARED;
        `CA53_AFB_REQ_CLEANINVALID: master_req_opcode = `CA53_REQ_OPCODE_CLEANINVALID;
        `CA53_AFB_REQ_MAKEINVALID:  master_req_opcode = `CA53_REQ_OPCODE_MAKEINVALID;
        `CA53_AFB_REQ_DVM:          master_req_opcode = `CA53_REQ_OPCODE_DVM;
        `CA53_AFB_REQ_DMB:          master_req_opcode = `CA53_REQ_OPCODE_DMB;
        `CA53_AFB_REQ_DSB:          master_req_opcode = `CA53_REQ_OPCODE_DSB;
        default:                    master_req_opcode = 5'bxxxxx;
      endcase
    end
    `CA53_TAGCTL_PASS_MASTER_R: begin
      case (req_type)
        `CA53_AFB_REQ_READNOSNOOP:  master_req_opcode = `CA53_REQ_OPCODE_READNOSNOOP;
        `CA53_AFB_REQ_READONCE:     master_req_opcode = (afb_req_read_alloc &
                                                         (L2_CACHE != 0)) ? `CA53_REQ_OPCODE_READSHARED : `CA53_REQ_OPCODE_READONCE;
        `CA53_AFB_REQ_READNONE:     master_req_opcode = L2_CACHE ? `CA53_REQ_OPCODE_READSHARED : `CA53_REQ_OPCODE_READONCE;
        `CA53_AFB_REQ_READSHARED:   master_req_opcode = `CA53_REQ_OPCODE_READSHARED;
        `CA53_AFB_REQ_READUNIQUE:   master_req_opcode = `CA53_REQ_OPCODE_READUNIQUE;
        `CA53_AFB_REQ_CLEANUNIQUE:  master_req_opcode = `CA53_REQ_OPCODE_CLEANUNIQUE;
        `CA53_AFB_REQ_CLEANSHARED:  master_req_opcode = `CA53_REQ_OPCODE_CLEANSHARED;
        `CA53_AFB_REQ_CLEANINVALID: master_req_opcode = `CA53_REQ_OPCODE_CLEANINVALID;
        `CA53_AFB_REQ_MAKEINVALID:  master_req_opcode = `CA53_REQ_OPCODE_MAKEINVALID;
        `CA53_AFB_REQ_WRITEUNIQUE:  master_req_opcode = afb_l2db_full ? `CA53_REQ_OPCODE_MAKEUNIQUE : `CA53_REQ_OPCODE_READUNIQUE;
        `CA53_AFB_REQ_DMB:          master_req_opcode = `CA53_REQ_OPCODE_DMB;
        `CA53_AFB_REQ_DSB:          master_req_opcode = `CA53_REQ_OPCODE_DSB;
        `CA53_AFB_SNP_DSB:          master_req_opcode = `CA53_REQ_OPCODE_DSB;
        `CA53_AFB_SNP_DVM_COMPLETE: master_req_opcode = `CA53_REQ_OPCODE_DVM_COMPLETE;
        default:                    master_req_opcode = 5'bxxxxx;
      endcase
    end
    `CA53_TAGCTL_PASS_MASTER_W: begin
      case (req_type)
        `CA53_AFB_REQ_WRITENOSNOOP: master_req_opcode = afb_l2db_full ? `CA53_REQ_OPCODE_WRITENOSNOOPFULL :
                                                                        `CA53_REQ_OPCODE_WRITENOSNOOP;
        `CA53_AFB_REQ_DVM:          master_req_opcode = `CA53_REQ_OPCODE_DVM;
        `CA53_AFB_REQ_CLEANUNIQUE,
        `CA53_AFB_REQ_CLEANSHARED:  master_req_opcode = `CA53_REQ_OPCODE_WRITECLEAN;
        `CA53_AFB_REQ_WRITEUNIQUE:  master_req_opcode = ((ACE != 0) |
                                                         ((L2_CACHE == 0) &
                                                          ~afb_static_pcredit)) ? `CA53_REQ_OPCODE_WRITEBACK :
                                                        afb_l2db_full           ? `CA53_REQ_OPCODE_WRITELINEUNIQUE :
                                                                                  `CA53_REQ_OPCODE_WRITEUNIQUE;
        `CA53_AFB_REQ_CLEANINVALID,
        `CA53_AFB_REQ_MAKEINVALID:  master_req_opcode = `CA53_REQ_OPCODE_WRITEBACK;
        default:                    master_req_opcode = 5'bxxxxx;
      endcase
    end
    `CA53_TAGCTL_PASS_LOOKUP:       master_req_opcode = `CA53_REQ_OPCODE_WRITEBACK;
    `CA53_TAGCTL_PASS_VICTIM: begin
      if (req_type == `CA53_AFB_REQ_CLEANSETWAY) begin
        master_req_opcode = `CA53_REQ_OPCODE_WRITECLEAN;
      end else begin
        master_req_opcode = ((afb_req_dirty &  afb_l1_hit)    ? `CA53_REQ_OPCODE_WRITECLEAN :
                             (afb_req_dirty & ~afb_l1_hit)    ? `CA53_REQ_OPCODE_WRITEBACK :
                             (afb_req_cluster_unique &
                              ~((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                (req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                (req_type == `CA53_AFB_REQ_ECCCLEAN) |
                                (req_type == `CA53_AFB_REQ_CLEANSETWAY)) &
                              tagctl_enable_writeevict_tc3_i) ? `CA53_REQ_OPCODE_EVICTDATA :
                                                                `CA53_REQ_OPCODE_EVICT);
      end
    end
    `CA53_TAGCTL_PASS_L2_VICTIM: begin
      master_req_opcode = ((afb_l2_victim_dirty &  afb_l2_victim_hit_l1)   ? `CA53_REQ_OPCODE_WRITECLEAN :
                           (afb_l2_victim_dirty & ~afb_l2_victim_hit_l1)   ? `CA53_REQ_OPCODE_WRITEBACK :
                           (afb_l2_victim_cu &
                            ~((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                              (req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                              (req_type == `CA53_AFB_REQ_ECCCLEAN) |
                              (req_type == `CA53_AFB_REQ_CLEANSETWAY)) &
                            tagctl_enable_writeevict_tc3_i)                ? `CA53_REQ_OPCODE_EVICTDATA :
                                                                             `CA53_REQ_OPCODE_EVICT);
    end
    default: master_req_opcode = 5'bxxxxx;
  endcase

  // For two part DVMs, we must make two requests to the master, so record when
  // the first request has been done.
  assign next_first_dvm_master_sent = (first_dvm_master_sent | master_afb_ack_i) & ~alloc_afb_tc1_i;

  always @(posedge clk)
  if (afb_valid_en) begin
    first_dvm_master_sent <= next_first_dvm_master_sent;
  end

  assign last_master_ack = master_afb_ack_i & (first_dvm_master_sent | ~two_part_dvm | (ACE == 0));

  // Indicate to the master when we might be making a request in the following cycle.
  assign afb_master_active_o = ((active_afb_tc2_i & master_req_needed_tc2) |
                                (active_afb_tc3_i & master_req_needed_tc3) |
                                (active_afb_tc4_i & master_req_needed_tc4) |
                                master_req_needed_victim |
                                master_req);

  assign next_master_req = (((active_afb_tc2_i & master_req_needed_tc2) |
                             (active_afb_tc3_i & master_req_needed_tc3) |
                             (active_afb_tc4_i & master_req_needed_tc4) |
                             master_req_needed_victim |
                             (master_req & ~last_master_ack)) &
                            ~(flush_afb_tc2_i |
                              flush_afb_tc3_i |
                              flush_afb_tc4_i));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    master_req <= 1'b0;
  end else if (afb_valid_en) begin
    master_req <= next_master_req;
  end

  assign afb_master_req_o            = master_req & ~afb_l2_victim_waddr_hz;
  assign afb_master_flush_o          = flush_afb_tc3_i | flush_afb_tc4_i;
  assign afb_master_id_o             = {afb_req_id_dcu, afb_req_id};
  assign afb_master_addr_o           = ((afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM) |
                                        (((req_type == `CA53_AFB_REQ_DVM) |
                                          (req_type == `CA53_AFB_SNP_DVM_MESSAGE) |
                                          (req_type == `CA53_AFB_SNP_DVM_COMPLETE)) &
                                         ~first_dvm_master_sent)) ? afb_victim_addr : afb_primary_addr;
  assign afb_master_opcode_o         = master_req_opcode;
  assign afb_master_len_o            = afb_req_len;
  assign afb_master_size_o           = afb_req_size;
  assign afb_master_lock_o           = afb_req_lock & ~((afb_req_pass == `CA53_TAGCTL_PASS_VICTIM) |
                                                        (afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM) |
                                                        ((afb_req_pass == `CA53_TAGCTL_PASS_MASTER_W) &
                                                         (req_type == `CA53_AFB_REQ_CLEANUNIQUE)));
  assign afb_master_attrs_o          = (afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM) ? l2db_master_attrs : afb_req_attrs;
  assign afb_master_prot_o           = afb_req_prot;
  assign afb_master_tgtid_o          = afb_tgtid;
  assign afb_master_l2db_o           = primary_l2db;
  assign afb_master_static_pcredit_o = afb_static_pcredit;
  assign afb_master_pcrdtype_o       = afb_pcrdtype;

  // If a Skyros WriteUnique has earlier done a ReadUnique to get the full line
  // but then did not hit in an L1 cache, it must force the strbs to be set in
  // the L2DB, so the full line is then written out.
  assign afb_l2db_fill_strbs_o = ({11{active_afb_tc4_i & ~flush_afb_tc4_i &
                                      (req_type == `CA53_AFB_REQ_WRITEUNIQUE) &
                                      (afb_req_pass == `CA53_TAGCTL_PASS_LOOKUP) &
                                      ((ACE == 0) | (L2_CACHE != 0)) &
                                      ~(afb_l1_hit | afb_l2_hit)}} &
                                  (11'h001 << primary_l2db));

  //----------------------------------------------------------------------------
  //  L2 data RAM requests
  //----------------------------------------------------------------------------

  generate if (L2_CACHE) begin : g_l2ramctl

    // Make an L2 data RAM read request if we hit in L2, and haven't already made
    // a request direct from tagctl in tc2.
    assign next_ramctl_req = (active_afb_tc2_i ? (afb_ramctl_needed_tc2 & ~flush_afb_tc2_i & ~ramctl_afb_ready_i) :
                              active_afb_tc3_i ? (((afb_ramctl_needed_tc3 & ~ramctl_requested & ~ramctl_afb_ready_i) |
                                                   afb_ramctl_victim_needed_tc3) & ~flush_afb_tc3_i) :
                                                 (ramctl_req & ~flush_afb_tc4_i & ~ramctl_afb_ready_i));

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ramctl_req <= 1'b0;
    end else if (afb_valid_en) begin
      ramctl_req <= next_ramctl_req;
    end

    assign afb_ramctl_needed_tc2 = ((afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                    ((req_type == `CA53_AFB_REQ_READSHARED) |
                                     (req_type == `CA53_AFB_REQ_READUNIQUE) |
                                     (req_type == `CA53_AFB_REQ_READONCE) |
                                     (req_type == `CA53_AFB_SNP_READONCE) |
                                     (req_type == `CA53_AFB_SNP_READSHARED) |
                                     (req_type == `CA53_AFB_SNP_READCLEAN) |
                                     (req_type == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                     (req_type == `CA53_AFB_SNP_READUNIQUE)) &
                                    ~cpuslv_snp_l2db_hz_tc2_i);

    assign afb_ramctl_needed_tc3 = (((afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                     ((((req_type == `CA53_AFB_REQ_READSHARED) |
                                        (req_type == `CA53_AFB_REQ_READUNIQUE) |
                                        (req_type == `CA53_AFB_REQ_READONCE) |
                                        (req_type == `CA53_AFB_SNP_READONCE) |
                                        (req_type == `CA53_AFB_SNP_READSHARED) |
                                        (req_type == `CA53_AFB_SNP_READCLEAN) |
                                        (req_type == `CA53_AFB_SNP_READNOTSHAREDDIRTY) |
                                        (req_type == `CA53_AFB_SNP_READUNIQUE)) &
                                       l2_hit_tc3_i & ~afb_snp_l2db_valid) |
                                      ((req_type == `CA53_AFB_REQ_WRITEUNIQUE) &
                                       l2_hit_tc3_i &
                                       cluster_unique_tc3_i &
                                       ~l1_lookup_hit_tc3_i &
                                       afb_l2db_rmw) |
                                      ((req_type == `CA53_AFB_REQ_CLEANUNIQUE) &
                                       requestor_hit_tc3 &
                                       l2_hit_dirty_tc3_i &
                                       ~cluster_unique_tc3_i) |
                                      ((req_type == `CA53_AFB_REQ_CLEANSETWAY) &
                                       afb_primary_addr[1] &
                                       l2_victim_valid_tc3_i & l2_dirty_tc3_i) |
                                      ((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) &
                                       afb_primary_addr[1] &
                                       l2_victim_valid_tc3_i) |
                                      ((req_type == `CA53_AFB_SNP_CLEANINVSETWAY) &
                                       l2_victim_valid_tc3_i) |
                                      (((req_type == `CA53_AFB_REQ_CLEANSHARED) |
                                        (req_type == `CA53_AFB_REQ_CLEANINVALID) |
                                        (req_type == `CA53_AFB_REQ_MAKEINVALID)) &
                                       l2_hit_dirty_tc3_i) |
                                      (((req_type == `CA53_AFB_SNP_CLEANSHARED) |
                                        (req_type == `CA53_AFB_SNP_CLEANINVALID)) &
                                       (l2_hit_tc3_i & (l1_lookup_hit_tc3_i | l2_hit_dirty_tc3_i) & ~afb_snp_l2db_valid)))) |
                                    ((afb_req_pass == `CA53_TAGCTL_PASS_LOOKUP) &
                                     (req_type == `CA53_AFB_REQ_WRITEUNIQUE) &
                                     l2_hit_tc3_i &
                                     ~l1_lookup_hit_tc3_i &
                                     afb_l2db_rmw));

    assign afb_ramctl_victim_needed_tc3 = ((afb_req_pass == `CA53_TAGCTL_PASS_LOOKUP) &
                                           ((req_type == `CA53_AFB_REQ_READONCE) |
                                            (req_type == `CA53_AFB_REQ_READNONE)) &
                                           l2_victim_valid_tc3_i);

    assign afb_ramctl_valid = ramctl_req & ~ramctl_requested;

    assign afb_ramctl_valid_o = afb_ramctl_valid;

    assign afb_ramctl_cancel = flush_afb_tc3_i | flush_afb_tc4_i | (active_afb_tc3_i & ~l2_hit_tc3_i);

    assign afb_ramctl_cancel_o = afb_ramctl_cancel;

    // Store if we have made a RAM request, so we can avoid making a second
    // request, and also so we know if we need to flush anything if this request
    // is flushed.
    assign next_ramctl_requested = ((active_afb_tc2_i & l2_data_access_tc2_i) |
                                    (afb_ramctl_valid & ~afb_ramctl_cancel & ramctl_afb_ready_i) |
                                    (ramctl_requested & afb_valid & ~afb_ramctl_flush));

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ramctl_requested <= 1'b0;
    end else if (afb_valid_en) begin
      ramctl_requested <= next_ramctl_requested;
    end

    // Tell ramctl if we don't want the data anymore, either because the request
    // is flushed, or based on the hit and dirty results we don't need it.
    // A ReadOnce needs to do either a primary or a victim access, but the
    // speculative access from tc2 will only be for the primary request.
    assign afb_ramctl_flush = (ramctl_requested &
                               (flush_afb_tc3_i |
                                flush_afb_tc4_i |
                                (active_afb_tc3_i & ~l2_hit_tc3_i)) &
                               ~tagctl_mbistreq_i);

    assign afb_ramctl_flush_o = afb_ramctl_flush;

    // Signal to ramctl if we might be making a request in the following cycle.
    // This does not include the tc1 cycle as tagctl includes that term.
    assign afb_ramctl_active_o = ((active_afb_tc2_i & afb_ramctl_needed_tc2) |
                                  (active_afb_tc3_i & (afb_ramctl_needed_tc3 |
                                                       afb_ramctl_victim_needed_tc3)) |
                                  ramctl_req);

    assign afb_ramctl_index_o = afb_primary_addr[16:6];

    assign afb_ramctl_way_o = (active_afb_tc3_i ? l2_hit_way_tc3 :
                               ((req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                (((req_type == `CA53_AFB_REQ_CLEANSETWAY) |
                                  (req_type == `CA53_AFB_REQ_CLEANINVSETWAY)) &
                                 afb_primary_addr[1])) ? afb_primary_addr[31:28] :
                               afb_l2_way);

    // For CPU requests indicate the critical chunk for ramctl to return first.
    assign afb_ramctl_crit_chunk_o = req_type[5] ? 2'b00 : afb_primary_addr[5:4];

    assign afb_ramctl_banks_o = ((afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE) &
                                 afb_req_single) ? (8'h03 << {afb_primary_addr[5:4], 1'b0}) : 8'hff;

  end else begin : g_n_l2ramctl

    assign afb_ramctl_active_o = 1'b0;
    assign afb_ramctl_valid = 1'b0;
    assign afb_ramctl_valid_o = 1'b0;
    assign afb_ramctl_cancel_o = 1'b0;
    assign afb_ramctl_flush_o = 1'b0;
    assign afb_ramctl_index_o = {11{1'b0}};
    assign afb_ramctl_way_o = 4'b0000;
    assign afb_ramctl_crit_chunk_o = 2'b00;
    assign afb_ramctl_banks_o = {8{1'b0}};
    assign next_ramctl_req = 1'b0;

    always @*
      ramctl_req = zero;

  end endgenerate

  //----------------------------------------------------------------------------
  //  DVM Syncs
  //----------------------------------------------------------------------------

  // Tell the DVM completion logic when a sync request is serialised.
  assign dvm_sync = (((req_type == `CA53_AFB_REQ_DVM) |
                      (req_type == `CA53_AFB_SNP_DVM_MESSAGE)) &
                     (afb_victim_addr[14:12] == `CA53_ACE_DVM_SYNC) &
                     (afb_req_pass == `CA53_TAGCTL_PASS_SERIALISE));

  assign afb_dvm_sync_tc3_o = active_afb_tc3_i & ~flush_afb_tc3_i & dvm_sync;

  assign dvm_sync_tc4 = active_afb_tc4_i & ~flush_afb_tc4_i & dvm_sync;

  assign afb_snp_dvm_sync_tc4_o = dvm_sync_tc4 & (afb_req_id[5:3] == 3'b101);

  assign afb_cpu_dvm_sync_tc4_o = {4{dvm_sync_tc4}} & requestor_cpu;

  assign afb_smp_en_o = afb_smp_en;

  //----------------------------------------------------------------------------
  //  Extra tagctl pass
  //----------------------------------------------------------------------------

  assign tagctl_pass_needed_tc4 = (active_afb_tc4_i & ~flush_afb_tc4_i &
                                   (afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM) &
                                   afb_l2_victim_valid & ~afb_l2_hit);

  // The L2DB is reporting that it has completed its transfer.
  assign l2db_done = |({l2db10_slv_done_i,
                        l2db9_slv_done_i,
                        l2db8_slv_done_i,
                        l2db7_slv_done_i,
                        l2db6_slv_done_i,
                        l2db5_slv_done_i,
                        l2db4_slv_done_i,
                        l2db3_slv_done_i,
                        l2db2_slv_done_i,
                        l2db1_slv_done_i,
                        l2db0_slv_done_i} & (11'b0000_0000_001 << afb_second_l2db));

  always @*
  case (tagctl_state)
    STATE_IDLE:   next_tagctl_state = tagctl_pass_needed_tc4 ? STATE_L2DB : STATE_IDLE;
    STATE_L2DB:   next_tagctl_state = l2db_done ? STATE_TC0_WR : STATE_L2DB;
    STATE_TC0_WR: next_tagctl_state = tagctl_afb_ready_tc0_i ? STATE_TC1 : STATE_TC0_WR;
    STATE_TC0:    next_tagctl_state = tagctl_afb_ready_tc0_i ? STATE_TC1 : STATE_TC0;
    STATE_TC1:    next_tagctl_state = flush_tc1_i ? STATE_TC0 : STATE_TC2;
    STATE_TC2:    next_tagctl_state = flush_tc2_i ? STATE_TC0 : STATE_TC3;
    STATE_TC3:    next_tagctl_state = flush_tc3_i ? STATE_TC0 : STATE_TC4;
    STATE_TC4:    next_tagctl_state = flush_tc4_i ? STATE_TC0 : next_afb_l2_victim_waddr_hz ? STATE_HZ : STATE_IDLE;
    STATE_HZ:     next_tagctl_state = next_afb_l2_victim_waddr_hz ? STATE_HZ  : STATE_IDLE;
    default:      next_tagctl_state = 4'bxxxx;
  endcase

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    tagctl_state <= STATE_IDLE;
  end else if (afb_valid_en) begin
    tagctl_state <= next_tagctl_state;
  end

  generate if (ACE) begin : g_ace_waddr
    // If the L2 victim hazards on an ACE waddr, then we must wait for the
    // earlier write to complete before sending the new write.
    assign l2_victim_waddr_hz = ((tagctl_pass_needed_tc4 |
                                  (active_afb_tc4_i & ~flush_afb_tc4_i &
                                   (((req_type == `CA53_AFB_REQ_READONCE) |
                                     (req_type == `CA53_AFB_REQ_READNONE) |
                                     (req_type == `CA53_AFB_REQ_WRITEUNIQUE)) &
                                    (afb_req_pass == `CA53_TAGCTL_PASS_VICTIM)))) &
                                 master_hz_tc4_i);

    assign next_afb_l2_victim_waddr_hz = ((l2_victim_waddr_hz |
                                           (afb_l2_victim_waddr_hz &
                                            |(master_waddr_valid_i & afb_l2_victim_waddr_onehot))) &
                                          ~((tagctl_state == STATE_TC4) &
                                            ~flush_tc4_i &
                                            ~l2_victim_write_needed));

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      afb_l2_victim_waddr_hz <= 1'b0;
    end else if (afb_valid_en) begin
      afb_l2_victim_waddr_hz <= next_afb_l2_victim_waddr_hz;
    end
  
    always @(posedge clk)
    if (l2_victim_waddr_hz) begin
      afb_l2_victim_waddr <= master_hz_waddr_tc4_i;
    end

    assign afb_l2_victim_waddr_onehot = 16'h0001 << afb_l2_victim_waddr;

  end else begin : g_skyros_waddr

    assign next_afb_l2_victim_waddr_hz = 1'b0;

    always @*
    begin
      afb_l2_victim_waddr_hz = zero;
      afb_l2_victim_waddr = {4{zero}};
    end

  end endgenerate

  assign l2_victim_write_needed = (afb_l2_victim_dirty |
                                   (((`CA53_MEM_O_SHAREABLE(afb_l2_victim_shareability) & tagctl_broadcastouter_i) |
                                     (`CA53_MEM_SHAREABLE(afb_l2_victim_shareability)   & tagctl_broadcastinner_i)) &
                                    ((afb_l2_victim_cu &
                                      ~((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                        (req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                        (req_type == `CA53_AFB_REQ_ECCCLEAN) |
                                        (req_type == `CA53_AFB_REQ_CLEANSETWAY)) &
                                      tagctl_enable_writeevict_tc3_i) |
                                     ~tagctl_disable_evict_tc3_i) &
                                    ~afb_l2_victim_hit_l1));

  assign master_req_needed_victim = (((tagctl_state == STATE_TC4) & ~flush_tc4_i & l2_victim_write_needed) |
                                     (tagctl_state == STATE_HZ)) & ~next_afb_l2_victim_waddr_hz;

  assign afb_tagctl_valid_tc0_o = ((tagctl_state == STATE_TC0) |
                                   (tagctl_state == STATE_TC0_WR));

  assign afb_tagctl_addr1_tc0_o = afb_primary_addr;

  // For victim passes, we lookup the L2 victim address in L1 while writing the
  // L1 victim address to L2. For most cases, the index used for L1 is a subset
  // the index for L2, however in one case when L1 is 64k and L2 is 128K bit 13
  // of the address is used in both and can be different, so provide that
  // separately.
  assign afb_tagctl_addr13_tc0_o = afb_victim_addr[13];

  assign afb_tagctl_wr_state_tc0_o = {afb_req_attrs[1], ~afb_req_attrs[0],
                                      afb_req_cluster_unique,
                                      afb_req_dirty,
                                      `CA53_MEM_OUTER_WA(afb_req_attrs),
                                      {12{1'b0}}};

  assign afb_tagctl_ecc_tc0_o = {afb_req_l2_ecc, {28{1'b0}}};

  assign afb_tagctl_ways_tc0_o = {{16{(tagctl_state == STATE_TC0_WR)}} & `CA53_L2_WAY_DEC(afb_l2_way), 16'hffff};

  assign afb_tagctl_requestor_tc0_o = {afb_req_id[5:3] == 3'b011,
                                       afb_req_id[5:3] == 3'b010,
                                       afb_req_id[5:3] == 3'b001,
                                       afb_req_id[5:3] == 3'b000} & ~{4{afb_l2flushreq}};

  assign afb_tagctl_type_tc0_o = afb_req_type;

  assign afb_tagctl_addr2_tc1_o = afb_victim_addr;

  // Capture information from the lookup
  assign next_afb_l2_victim_hit_l1 = (tagctl_state == STATE_TC3) ? |l1_lookup_hit_ways_tc3_i : afb_l2_victim_hit_l1;

  always @(posedge clk)
  if (afb_valid_en) begin
    afb_l2_victim_hit_l1 <= next_afb_l2_victim_hit_l1;
  end

  // Tell the L2DB when we are performing a master access.
  assign afb_l2dbs_transfer_o = master_req_needed_victim;

  assign afb_l2dbs_id_o = afb_second_l2db;

  assign l2db_master_opcode = ((afb_l2_victim_dirty &  afb_l2_victim_hit_l1)  ? `CA53_DATA_OPCODE_WRITECLEAN :
                               (afb_l2_victim_dirty & ~afb_l2_victim_hit_l1)  ? `CA53_DATA_OPCODE_WRITEBACK :
                               (afb_l2_victim_cu &
                                ~((req_type == `CA53_AFB_REQ_CLEANINVSETWAY) |
                                  (req_type == `CA53_AFB_SNP_CLEANINVSETWAY) |
                                  (req_type == `CA53_AFB_REQ_ECCCLEAN) |
                                  (req_type == `CA53_AFB_REQ_CLEANSETWAY)) &
                                tagctl_enable_writeevict_tc3_i)               ? `CA53_DATA_OPCODE_EVICTDATA :
                                                                                `CA53_DATA_OPCODE_EVICT);

  assign l2db_master_attrs = {4'b1011, 1'b1, afb_l2_victim_alloc, afb_l2_victim_shareability};

  assign afb_l2dbs_transfer_info_o = {afb_l2_victim_cu, 2'b01, 1'b1, 1'b0, l2db_master_opcode,
                                      l2db_master_attrs, 2'b00,
                                      (ACE != 0) ? {afb_req_id[5:3], AFB_NUM[2:0]} : afb_req_id[5:0]};

  // Hazarding of L2 victim address. Start hazarding as soon as we have
  // registered the address in tc4, and keep until the master ack when the
  // master has taken over hazarding from us. We must not indicate a hazard
  // on that last cycle as otherwise the hazard registers will remain set on
  // the cycles after the AFB has completed.
  assign afb_l2_victim_hz = (tagctl_pass_needed_tc4 |
                             (tagctl_state != STATE_IDLE) |
                             (master_req & ~last_master_ack & (afb_req_pass == `CA53_TAGCTL_PASS_L2_VICTIM)));

  assign afb_hz_tc1_o = (afb_l2_victim_hz &
                         tagctl_addr_valid_tc1_i &
                         (tagctl_addr_tc1_i == {1'b0, afb_victim_addr[40:6]}));

  assign afb_hz_tc3_o = (afb_l2_victim_hz &
                         tagctl_addr_valid_tc3_i &
                         (tagctl_addr_tc3_i == afb_victim_addr[40:6]));

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB must only be allocated when idle")
  u_ovl_alloc_idle (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (alloc_afb_tc1_i),
    .consequent_expr  (~afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB must only be active when valid")
  u_ovl_active_afb (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (active_afb_tc2_i | active_afb_tc3_i | active_afb_tc4_i),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB must only be flushed when valid")
  u_ovl_flush_afb (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (flush_afb_tc2_i | flush_afb_tc3_i | flush_afb_tc4_i),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "RAMCtl request may only be made by a valid AFB")
  u_ovl_ram_req_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (ramctl_req),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "RAMCtl request may only be made by a valid AFB")
  u_ovl_ramctl_valid_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (afb_ramctl_valid),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master request may only be made by a valid AFB")
  u_ovl_master_req_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (master_req),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop request may only be made by a valid AFB")
  u_ovl_snoop_req_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (|snoop_req),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop request may only be made by a valid AFB")
  u_ovl_afb_snoop_req_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (|snoop_req),
    .consequent_expr  (afb_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only snoop can have afb_snp_l2db_valid set")
  u_ovl_afb_snp_l2db_valid (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (afb_valid & ~active_afb_tc2_i & afb_snp_l2db_valid),
    .consequent_expr  (req_type[5])
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop cannot have second L2DB valid")
  u_ovl_afb_snp_l2db (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (afb_valid & ~active_afb_tc2_i),
    .consequent_expr  (~(afb_second_l2db_valid & afb_snp_l2db_valid))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Snoop responses cannot be pending until after tc3")
  u_ovl_snp_resp (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (|snoop_resp_pending),
    .consequent_expr  (afb_valid & ~active_afb_tc2_i & ~active_afb_tc3_i)
  );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac snoop x-check")
  u_ovl_x_cpu0_ac_snoop (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (snoop_req[0]),
                         .test_expr (afb_cpu0_ac_snoop_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac snoop x-check")
  u_ovl_x_cpu1_ac_snoop (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (snoop_req[1]),
                         .test_expr (afb_cpu1_ac_snoop_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac snoop x-check")
  u_ovl_x_cpu2_ac_snoop (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (snoop_req[2]),
                         .test_expr (afb_cpu2_ac_snoop_o));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "ac snoop x-check")
  u_ovl_x_cpu3_ac_snoop (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (snoop_req[3]),
                         .test_expr (afb_cpu3_ac_snoop_o));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tc2_info_en")
  u_ovl_x_tc2_info_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (tc2_info_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: tc1_info_en")
  u_ovl_x_tc1_info_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (tc1_info_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: afb_req_attrs_en")
  u_ovl_x_afb_req_attrs_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (afb_req_attrs_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_afb_tc2_i")
  u_ovl_x_active_afb_tc2_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (active_afb_tc2_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: afb_second_l2db_en")
  u_ovl_x_afb_second_l2db_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (afb_second_l2db_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_afb_tc3_i")
  u_ovl_x_active_afb_tc3_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (active_afb_tc3_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: afb_valid_en")
  u_ovl_x_afb_valid_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (afb_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: afb_victim_addr_en")
  u_ovl_x_afb_victim_addr_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (afb_victim_addr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: alloc_afb_tc1_i")
  u_ovl_x_alloc_afb_tc1_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (alloc_afb_tc1_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: snoop_resp_en")
  u_ovl_x_snoop_resp_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (snoop_resp_en));


`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_scu_dcu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
