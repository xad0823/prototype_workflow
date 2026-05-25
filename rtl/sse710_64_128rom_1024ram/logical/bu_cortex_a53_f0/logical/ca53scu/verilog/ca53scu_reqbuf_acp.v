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
//  The ACP slave request buffers store and control each request from the ACP
//  interface.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"


module ca53scu_reqbuf_acp #(`CA53_SCU_INT_PARAM_DECL, parameter NUM_REQBUFS = 1, parameter REQBUF_ID = 6'b000000)
 (
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire                   acpslv_broadcastinner_i,
  input  wire                   acpslv_broadcastouter_i,
  input  wire [2:0]             acpslv_l1_dc_size_i,
  input  wire [3:0]             acpslv_l2_size_i,
  input  wire                   acpslv_enable_writeevict_i,

  // BIU interface
  output wire                   reqbuf_busy_o,
  input  wire                   reqbuf_alloc_i,
  input  wire [4:0]             acp_addr_id_i,
  input  wire                   acp_addr_read_i,
  input  wire                   acp_addr_alloc_i,
  input  wire [40:4]            acp_addr_addr_i,
  input  wire                   acp_addr_len_i,
  input  wire [1:0]             acp_addr_domain_i,
  input  wire                   acp_addr_slverr_i,

  // Write responses
  output wire                   reqbuf_db_valid_o,
  input  wire                   reqbuf_db_ready_i,
  output wire [1:0]             reqbuf_db_resp_o,

  output wire                   reqbuf_suppress_dr_o,
  output wire [3:0]             reqbuf_early_dr_ready_o,

  // Read responses
  output wire                   reqbuf_dr_valid_o,
  input  wire                   reqbuf_dr_ready_i,

  // Write data
  input  wire                   acpslv_wdata_valid_i,
  input  wire                   acpslv_wdata_last_i,
  output wire [1:0]             reqbuf_wdata_chunk_o,
  output wire                   reqbuf_wait_data_o,

  // Hazarding
  input  wire [41:6]            tagctl_addr_tc1_i,
  input  wire                   tagctl_addr_valid_tc1_i,
  input  wire [5:0]             tagctl_reqbufid_tc1_i,
  input  wire                   tagctl_index_valid_tc1_i,
  input  wire                   tagctl_serialising_tc1_i,
  input  wire                   tagctl_l1_lf_tc1_i,
  input  wire [15:0]            tagctl_ecc_way_tc1_i,
  output wire                   reqbuf_hz_tc1_o,
  output wire [15:0]            reqbuf_force_miss_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_vc1_o,
  input  wire [10:0]            victimctl_index_vc1_i,
  input  wire [40:6]            tagctl_addr_tc3_i,
  input  wire                   tagctl_addr_valid_tc3_i,
  input  wire [5:0]             tagctl_reqbufid_tc3_i,
  output wire                   reqbuf_hz_tc3_o,
  output wire                   reqbuf_id_hazard_o,

  // Tagctl requests
  input  wire                   next_acpslv_noncoh_only_i,
  input  wire                   reqbuf_tagctl_prearb_primary_i,
  input  wire                   reqbuf_tagctl_prearb_victim_i,
  output wire                   reqbuf_tagctl_valid_tc0_o,
  output wire                   reqbuf_tagctl_prearb_req_o,
  output wire                   reqbuf_tagctl_prearb_pri1_o,
  output wire                   reqbuf_tagctl_prearb_pri2_o,
  output wire                   reqbuf_tagctl_primary_tc0_o,
  output wire                   reqbuf_update_primary_pass_o,
  output wire                   reqbuf_update_victim_pass_o,
  output wire [3:0]             reqbuf_tagctl_pass_tc0_o,
  output wire [40:0]            reqbuf_tagctl_addr1_tc0_o,
  output wire [16:0]            reqbuf_tagctl_wr_state_tc0_o,
  output wire [31:0]            reqbuf_tagctl_ways_tc0_o,
  output wire [4:0]             reqbuf_tagctl_write_tc0_o,
  input  wire                   reqbuf_arb_tc1_i,
  output wire [4:0]             reqbuf_type_o,
  output wire [1:0]             reqbuf_len_o,
  output wire [1:0]             reqbuf_len_tc1_o,
  output wire                   reqbuf_dirty_o,
  output wire                   reqbuf_cluster_unique_o,
  output wire [7:0]             reqbuf_attrs_o,
  output wire [1:0]             reqbuf_prot_o,
  output wire [4:0]             reqbuf_acp_id_o,
  output wire                   reqbuf_l2db_full_o,
  output wire                   reqbuf_static_pcredit_tc1_o,
  output wire [1:0]             reqbuf_pcrdtype_tc1_o,
  output wire [3:0]             reqbuf_victim_way_tc1_o,
  output wire [3:0]             reqbuf_l2db_tc1_o,
  output wire                   reqbuf_slverr_o,
  output wire                   reqbuf_dr_last_o,

  input  wire                   tagctl_slv_flush_tc1_i,
  input  wire                   tagctl_slv_flush_tc2_i,
  input  wire                   tagctl_slv_flush_tc3_i,
  input  wire                   tagctl_slv_flush_tc4_i,
  input  wire                   tagctl_slv_early_flush_tc4_i,
  input  wire [2:0]             tagctl_slv_afb_tc1_i,
  input  wire [3:0]             tagctl_slv_l2db_tc1_i,
  input  wire [3:0]             tagctl_slv_l2db_tc4_i,
  input  wire [15:0]            tagctl_l1_hit_ways_tc3_i,
  input  wire [15:0]            tagctl_l2_hit_ways_tc3_i,
  input  wire                   tagctl_l2_dirty_tc3_i,
  input  wire [1:0]             tagctl_shareability_tc3_i,
  input  wire                   tagctl_cluster_unique_tc3_i,
  input  wire                   tagctl_l2_victim_valid_tc3_i,
  input  wire [1:0]             tagctl_l2_victim_shareability_tc3_i,
  input  wire                   tagctl_l2_victim_alloc_tc3_i,
  input  wire                   tagctl_l2_victim_cu_tc3_i,
  input  wire [3:0]             tagctl_l2_victim_way_tc3_i,
  input  wire                   tagctl_ecc_err_tc3_i,
  input  wire [1:0]             tagctl_snoop_data_cpu_tc4_i,
  input  wire                   afb0_done_i,
  input  wire                   afb1_done_i,
  input  wire                   afb2_done_i,
  input  wire                   afb3_done_i,
  input  wire                   afb4_done_i,
  input  wire                   afb5_done_i,
  input  wire                   afb0_write_done_i,
  input  wire                   afb1_write_done_i,
  input  wire                   afb2_write_done_i,
  input  wire                   afb3_write_done_i,
  input  wire                   afb4_write_done_i,
  input  wire                   afb5_write_done_i,
  input  wire                   acpslv_ecc_err_tc4_i,

  // Victimctl requests
  output wire                   reqbuf_victimctl_active_o,
  output wire                   reqbuf_victimctl_valid_o,
  output wire [10:0]            reqbuf_victimctl_index_o,
  output wire                   reqbuf_victimctl_wr_o,
  output wire                   reqbuf_victimctl_age_o,
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
  output wire                   reqbuf_l2db_victim_transfer_o,
  output wire [3:0]             reqbuf_l2db_primary_id_o,
  output wire [3:0]             reqbuf_l2db_victim_id_o,
  output wire [2:0]             reqbuf_l2db_primary_transfer_type_o,
  output wire [2:0]             reqbuf_l2db_victim_transfer_type_o,
  output wire [25:0]            reqbuf_l2db_primary_transfer_info_o,
  output wire [25:0]            reqbuf_l2db_victim_transfer_info_o,
  output wire                   reqbuf_l2db_primary_release_o,
  output wire                   reqbuf_l2db_victim_release_o,

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

  output wire                   reqbuf_ramctl_active_o,

  // Master read data
  input  wire                   master_early_dr_valid_i,
  input  wire                   master_early_dr_barrier_i,
  input  wire [5:0]             master_early_dr_id_i,
  input  wire [7:0]             master_early_dr_dbid_i,
  input  wire [6:0]             master_early_dr_srcid_i,
  input  wire [1:0]             master_early_dr_chunk_i,
  input  wire [3:0]             master_early_dr_resp_i,
  input  wire                   master_early_dr_same_i,
  input  wire                   master_early_dr_ready_i,
  output wire                   reqbuf_early_dr_l2_o,
  output wire [10:0]            reqbuf_early_dr_index_o,
  output wire [3:0]             reqbuf_early_dr_way_o,
  output wire                   reqbuf_delay_allocation_o,

  input  wire                   master_acpslv_dr_valid_i,
  input  wire                   acpslv_master_dr_ready_i,
  input  wire [5:0]             master_dr_id_i,
  input  wire [3:0]             master_dr_resp_i,

  input  wire                   master_rsp_comp_valid_i,
  input  wire [6:0]             master_rsp_txnid_i,
  input  wire [7:0]             master_rsp_dbid_i,
  input  wire [6:0]             master_rsp_srcid_i,
  input  wire [3:0]             master_rsp_resp_i,

  input  wire                   reqbuf_retry_i,
  input  wire [1:0]             reqbuf_retry_pcrdtype_i,

  input  wire                   master_acpslv_l2_waiting_i,

  output wire                   reqbuf_ext_err_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE             = 4'b0000;
  localparam STATE_TC0_TC1          = 4'b0001;
  localparam STATE_TC2              = 4'b0010;
  localparam STATE_TC3              = 4'b0011;
  localparam STATE_TC4              = 4'b0100;
  localparam STATE_WAIT_AFB         = 4'b0101;
  localparam STATE_WAIT_L2DB        = 4'b0110;
  localparam STATE_WAIT_EXT         = 4'b0111;
  localparam STATE_COMPACK          = 4'b1000;
  localparam STATE_WAIT_VICTIM      = 4'b1001;
  localparam STATE_RESP             = 4'b1010;
  localparam STATE_UPDATE_VICTIM    = 4'b1011;
  localparam STATE_PICK_VICTIM_REQ  = 4'b1100;
  localparam STATE_PICK_VICTIM_ACK  = 4'b1101;
  localparam STATE_WAIT_DATA        = 4'b1110;
  localparam STATE_X                = 4'bxxxx;

  localparam STATE_VICTIM_IDLE      = 4'b0000;
  localparam STATE_VICTIM_TC0       = 4'b1100;
  localparam STATE_VICTIM_TC0_TC1   = 4'b0001;
  localparam STATE_VICTIM_TC2       = 4'b0010;
  localparam STATE_VICTIM_TC3       = 4'b0011;
  localparam STATE_VICTIM_TC4       = 4'b0100;
  localparam STATE_VICTIM_WAIT_AFB  = 4'b0110;
  localparam STATE_VICTIM_WAIT_L2DB = 4'b0111;
  localparam STATE_VICTIM_PICK_REQ  = 4'b1000;
  localparam STATE_VICTIM_PICK_ACK  = 4'b1001;
  localparam STATE_VICTIM_X         = 4'bxxxx;

  localparam PASS_INITIAL           = 3'b000;
  localparam PASS_X                 = 3'bxxx;

  localparam PASS_READ_SERIALISE    = 3'b000;
  localparam PASS_READ_MISS         = 3'b001;
  localparam PASS_READ_RETRY        = 3'b010;
  localparam PASS_READ_REORDER1     = 3'b011;
  localparam PASS_READ_REORDER2     = 3'b100;

  localparam PASS_WRITE_L2DB        = 3'b000;
  localparam PASS_WRITE_SERIALISE   = 3'b001;
  localparam PASS_WRITE_MISS_RETRY  = 3'b010;
  localparam PASS_WRITE_MISS        = 3'b011;
  localparam PASS_WRITE_HIT_RETRY   = 3'b100;
  localparam PASS_WRITE_N_UNIQUE    = 3'b101;
  localparam PASS_WRITE_UNIQUE1     = 3'b110;
  localparam PASS_WRITE_UNIQUE2     = 3'b111;

  localparam PASS_VICTIM_INITIAL    = 2'b00;
  localparam PASS_VICTIM_READ       = 2'b01;
  localparam PASS_VICTIM_WRITE      = 2'b10;
  localparam PASS_VICTIM_X          = 2'bxx;

  reg [3:0]            reqbuf_state;
  reg [3:0]            reqbuf_victim_state;
  reg [2:0]            reqbuf_pass;
  reg [1:0]            reqbuf_victim_pass;
  reg [3:0]            primary_l2db;
  reg [3:0]            victim_l2db;
  reg [4:0]            reqbuf_acp_id;
  reg                  reqbuf_read;
  reg                  reqbuf_rwalloc;
  reg [40:4]           reqbuf_addr1;
  reg [40:6]           reqbuf_addr2;
  reg                  reqbuf_len;
  reg [1:0]            reqbuf_domain;
  reg                  reqbuf_slverr;
  reg [2:0]            reqbuf_afb;
  reg [2:0]            reqbuf_victim_afb;
  reg                  reqbuf_l2_hit;
  reg [3:0]            reqbuf_l1_hit_cpus;
  reg [7:0]            reqbuf_l1_hit_ways;
  reg                  reqbuf_cluster_unique;
  reg [1:0]            reqbuf_snoop_data_cpu;
  reg [1:0]            reqbuf_shareability;
  reg                  reqbuf_l1_victim_hit;
  reg                  reqbuf_l2_victim_valid;
  reg                  reqbuf_l2_victim_dirty;
  reg [1:0]            reqbuf_l2_victim_shareability;
  reg                  reqbuf_l2_victim_alloc;
  reg                  reqbuf_l2_victim_cu;
  reg [3:0]            reqbuf_l2_victim_way;
  reg                  reqbuf_l2db_full;
  reg [1:0]            reqbuf_wdata_chunk;
  reg [2:0]            ext_beats_received;
  reg [8:0]            ext_beats_returned;
  reg [1:0]            ext_beats_resp;
  reg                  ext_beats_shared;
  reg                  ext_beats_dirty;
  reg                  hazard_snoops;
  reg                  victim_hazard_snoops;
  reg                  l1_snoops_done;
  reg                  reqbuf_l2db_primary_transfer;
  reg                  reqbuf_l2db_victim_transfer;
  reg                  reqbuf_tagctl_req_tc0;
  reg                  reqbuf_tagctl_prearb_req;
  reg                  reqbuf_beats_reordered;
  reg [2:0]            reqbuf_l2db_primary_transfer_type;

  wire                 reqbuf_en;
  wire                 update_reqbuf_pass;
  wire                 update_reqbuf_victim_pass;
  reg [3:0]            next_reqbuf_state;
  reg [3:0]            next_reqbuf_victim_state;
  reg [2:0]            next_reqbuf_pass;
  wire [1:0]           next_reqbuf_victim_pass;
  wire                 require_resp_after_l2db;
  wire                 require_tagctl_after_l2db;
  wire                 require_l2db_after_l2db;
  wire                 require_tagctl_after_ext;
  wire                 require_resp_after_ext;
  wire                 require_compack_after_ext;
  wire                 require_compack_after_l2db;
  wire                 require_victim_pick_after_ext;
  wire                 require_tagctl_after_compack;
  wire                 require_l2db_after_afb;
  wire                 require_victim_pick_after_afb;
  wire                 require_tagctl_after_resp;
  wire                 require_tagctl_after_update;
  wire                 require_ext_after_afb;
  wire                 require_data_after_tc2;
  wire                 require_victim_pick_after_l2db;
  wire                 require_update_victim_after_l2db;
  wire                 require_update_victim_after_tc1;
  wire                 require_tagctl_after_tc1;
  wire                 require_l2db_after_tc1;
  wire                 victim_require_idle_after_tc3;
  wire                 victim_require_l2db_after_afb;
  wire                 victim_require_tagctl_after_l2db;
  wire                 reqbuf_addr2_en;
  wire                 reqbuf_l1_hit;
  wire                 next_reqbuf_l2_hit;
  wire [3:0]           next_reqbuf_l1_hit_cpus;
  wire [7:0]           next_reqbuf_l1_hit_ways;
  wire                 next_reqbuf_l1_victim_hit;
  wire                 reqbuf_l1_resp_en;
  wire                 l1_victim_hit_en;
  wire                 hit_state_en_tc3;
  wire                 hit_state_en_tc4;
  wire                 l2_victim_hit_en;
  wire                 victimctl_victim_ack;
  wire                 l2_victim_way_en;
  wire                 reqbuf_shareability_en;
  wire                 use_hit_shareability;
  wire [1:0]           next_reqbuf_shareability;
  wire [3:0]           next_reqbuf_l2_victim_way;
  wire [3:0]           reqbuf_tagctl_pass_tc0;
  reg [3:0]            reqbuf_primary_pass_tc0;
  wire [3:0]           reqbuf_victim_pass_tc0;
  wire [1:0]           next_reqbuf_wdata_chunk;
  reg                  next_reqbuf_l2db_full;
  reg                  reqbuf_l2db_rmw;
  wire                 afb_done;
  wire                 victim_afb_done;
  wire                 afb_primary_write;
  wire                 afb_victim_write;
  wire [2:0]           next_reqbuf_afb;
  wire [2:0]           next_reqbuf_victim_afb;
  wire [MAX_L2DBS-1:0] l2dbs_slv_done;
  wire                 primary_l2db_done;
  wire                 victim_l2db_done;
  wire [3:0]           next_primary_l2db;
  wire                 primary_l2db_en;
  wire                 l2db_valid_tc1;
  wire                 l2db_valid_tc4;
  wire [2:0]           next_ext_beats_received;
  wire                 receiving_ext_beat;
  wire [8:0]           next_ext_beats_returned;
  wire                 next_reqbuf_beats_reordered;
  wire [1:0]           reqbuf_write_len;
  wire [1:0]           reqbuf_real_len;
  wire                 reqbuf_ext_ret_en;
  wire                 all_ext_beats_returned;
  wire                 reqbuf_dr_last;
  wire                 reqbuf_delay_allocation;
  wire                 next_hazard_snoops;
  wire                 next_victim_hazard_snoops;
  wire                 next_l1_snoops_done;
  wire                 early_dr_match;
  wire                 reqbuf_serialised_tc1;
  wire                 addr_hz_tc1;
  wire [3:0]           tagctl_l1_hit_ways_tc3_0;
  wire [3:0]           tagctl_l1_hit_ways_tc3_1;
  wire [3:0]           tagctl_l1_hit_ways_tc3_2;
  wire [3:0]           tagctl_l1_hit_ways_tc3_3;
  wire [7:0]           victim_attrs;
  wire [4:0]           tag_state_l2_tc0;
  wire                 reqbuf_tagctl_primary_write_tc0;
  wire                 reqbuf_tagctl_valid_tc0;
  wire                 reqbuf_shareable;
  wire                 reqbuf_ext_en;
  wire [1:0]           next_ext_beats_resp;
  wire                 next_ext_beats_shared;
  wire                 next_ext_beats_dirty;
  wire [3:0]           master_ext_resp;
  wire                 ext_decerr;
  wire                 ext_slverr;
  wire                 ext_exokayerr;
  wire                 start_victim;
  wire                 start_victim_no_flush;
  reg [31:0]           reqbuf_primary_tagctl_ways_tc0;
  wire [31:0]          reqbuf_victim_tagctl_ways_tc0;
  wire [1:0]           reqbuf_l1_hit_ways_0;
  wire [1:0]           reqbuf_l1_hit_ways_1;
  wire [1:0]           reqbuf_l1_hit_ways_2;
  wire [1:0]           reqbuf_l1_hit_ways_3;
  wire [31:0]          reqbuf_hit_ways;
  wire                 next_reqbuf_l2db_primary_transfer;
  wire                 next_reqbuf_l2db_victim_transfer;
  wire [2:0]           reqbuf_l2db_victim_transfer_type;
  wire [2:0]           victim_opcode;
  wire                 reqbuf_state_tc0;
  wire                 reqbuf_state_tc1;
  wire                 reqbuf_victim_state_tc1;
  wire                 reqbuf_next_state_tc0_tc1;
  wire                 reqbuf_victim_next_state_tc0_tc1;
  reg [2:0]            next_reqbuf_l2db_primary_transfer_type;
  wire [1:0]           primary_slv_transfer_crit;
  wire [25:0]          primary_slv_transfer_info;
  wire [25:0]          primary_master_transfer_info;
  wire [25:0]          primary_ram_transfer_info;
  reg [25:0]           reqbuf_l2db_primary_transfer_info;
  wire [25:0]          victim_master_transfer_info;
  wire [25:0]          victim_ram_transfer_info;
  wire                 reqbuf_l2db_full_en;
  wire [3:0]           reqbuf_suppress_skyros_dr_beats;
  wire [3:0]           reqbuf_early_dr_ready;
  wire                 reqbuf_suppress_dr;
  wire                 reqbuf_write;
  wire [7:0]           reqbuf_attrs;
  wire                 reqbuf_read_alloc;
  wire                 reqbuf_retry_seen;
  wire                 reqbuf_retry_received_en;
  wire                 zero;
  wire                 reqbuf_dbid_en;
  wire                 reqbuf_rsp_comp_valid;
  wire                 addr1_l1_index_hz_tc1;
  wire                 addr1_l2_index_hz_tc1;
  wire                 addr1_addr_hz_tc1;
  wire                 addr2_l2_index_hz_tc1;
  wire                 addr2_addr_hz_tc1;
  wire                 addr1_l2_index_hz_tc3;
  wire                 addr1_addr_hz_tc3;
  wire                 addr2_l2_index_hz_tc3;
  wire                 addr2_addr_hz_tc3;
  wire                 reqbuf_addr2_serialised;
  wire                 snoop_tc1;
  wire                 addr2_l2_way_unknown;
  wire                 addr1_l2_way_unknown_tc1;
  wire                 way_used_valid_tc1;
  wire [15:0]          requestor_way_tc1;
  wire                 l2_index_hz_tc1;
  wire                 l1_index_way_hz_tc1;
  wire                 way_used_l2_hit_tc1;
  wire                 way_used_l2_miss_tc1;
  wire                 way_used_victim_tc1;
  wire                 addr1_l2_index_hz_vc1;
  wire                 addr2_l2_index_hz_vc1;
  wire                 reqbuf_addr1_serialised_tc3;
  wire                 addr1_l2_way_unknown_tc3;
  wire                 snoop_tc3;
  wire                 l2_index_hz_tc3;
  wire                 reqbuf_tagctl_primary_tc0;
  wire                 next_reqbuf_tagctl_req_tc0;
  wire                 next_reqbuf_tagctl_prearb_req;

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
          if (acp_addr_read_i & acp_addr_slverr_i) begin
            next_reqbuf_state = STATE_RESP;
          end else begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end
      end
      STATE_RESP: begin
        if ((reqbuf_write & reqbuf_db_ready_i) |
            (reqbuf_read & reqbuf_dr_ready_i & reqbuf_dr_last)) begin
          if (require_tagctl_after_resp) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end
      end
      STATE_TC0_TC1: begin
        // This is either the TC0 or TC1 state, depending on whether we got
        // arbitrated in the previous cycle. If the victim state machine was
        // in TC0 in the previous cycle then the primary state machine cannot be
        // in TC1 because if anything was arbitrated in the previous cycle it
        // would have been the victim state machine.
        if (reqbuf_state_tc1) begin
          if (tagctl_slv_flush_tc1_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_tagctl_after_tc1) begin
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
        end else if (require_data_after_tc2) begin
          next_reqbuf_state = STATE_WAIT_DATA;
        end else begin
          next_reqbuf_state = STATE_TC3;
        end
      end
      STATE_TC3: begin
        if (tagctl_slv_flush_tc3_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
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
          end else if (require_victim_pick_after_afb) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else begin
            next_reqbuf_state = STATE_WAIT_EXT;
          end
        end
      end
      STATE_WAIT_L2DB: begin
        if (primary_l2db_done) begin
          if (require_tagctl_after_l2db) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_l2db_after_l2db) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else if (require_update_victim_after_l2db) begin
            next_reqbuf_state = STATE_UPDATE_VICTIM;
          end else if (require_compack_after_l2db) begin
            next_reqbuf_state = STATE_COMPACK;
          end else if (require_victim_pick_after_l2db) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (require_resp_after_l2db) begin
            next_reqbuf_state = STATE_RESP;
          end else if (reqbuf_victim_state != STATE_VICTIM_IDLE) begin
            next_reqbuf_state = STATE_WAIT_VICTIM;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end else if (reqbuf_retry_seen) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_WAIT_DATA: begin
        if (acpslv_wdata_valid_i & acpslv_wdata_last_i) begin
          if (reqbuf_slverr) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end
      end
      STATE_WAIT_EXT: begin
        if (all_ext_beats_returned & ~master_acpslv_l2_waiting_i) begin
          if (require_compack_after_ext) begin
            next_reqbuf_state = STATE_COMPACK;
          end else if (require_victim_pick_after_ext) begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
          end else if (require_resp_after_ext) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_tagctl_after_ext) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end else if (reqbuf_retry_seen) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_COMPACK: begin
        if (reqbuf_compack_ready_i) begin
          if (require_tagctl_after_compack) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_PICK_VICTIM_REQ;
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
            next_reqbuf_state = STATE_IDLE;
          end
        end
      end
      STATE_WAIT_VICTIM: begin
        if (reqbuf_victim_state == STATE_VICTIM_IDLE) begin
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
          next_reqbuf_victim_state = STATE_VICTIM_PICK_REQ;
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
        if (victim_require_idle_after_tc3) begin
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
          if (victim_require_l2db_after_afb) begin
            next_reqbuf_victim_state = STATE_VICTIM_WAIT_L2DB;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_IDLE;
          end
        end
      end
      STATE_VICTIM_WAIT_L2DB: begin
        if (victim_l2db_done) begin
          if (victim_require_tagctl_after_l2db) begin
            next_reqbuf_victim_state = STATE_VICTIM_TC0;
          end else begin
            next_reqbuf_victim_state = STATE_VICTIM_IDLE;
          end
        end
      end
      default: next_reqbuf_victim_state = STATE_VICTIM_X;
    endcase
  end

  // Decode some states that are more than just the state variable.
  assign reqbuf_state_tc0 = (reqbuf_state == STATE_TC0_TC1) & ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) | ~reqbuf_arb_tc1_i);

  assign reqbuf_state_tc1 = (reqbuf_state == STATE_TC0_TC1) & (reqbuf_victim_state != STATE_VICTIM_TC0_TC1) & reqbuf_arb_tc1_i;

  assign reqbuf_victim_state_tc1 = (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) & reqbuf_arb_tc1_i;

  assign reqbuf_next_state_tc0_tc1 = (((reqbuf_state == STATE_IDLE) &
                                       reqbuf_alloc_i & ~(acp_addr_read_i & acp_addr_slverr_i)) |
                                      ((reqbuf_state == STATE_RESP) &
                                       reqbuf_write & reqbuf_db_ready_i & require_tagctl_after_resp) |
                                      ((reqbuf_state == STATE_TC0_TC1) & ~(reqbuf_state_tc1 &
                                                                           ~tagctl_slv_flush_tc1_i &
                                                                           ~require_tagctl_after_tc1)) |
                                      ((reqbuf_state == STATE_TC2) & tagctl_slv_flush_tc2_i) |
                                      ((reqbuf_state == STATE_TC3) & tagctl_slv_flush_tc3_i) |
                                      ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i) |
                                      ((reqbuf_state == STATE_WAIT_L2DB) & ((primary_l2db_done &
                                                                             require_tagctl_after_l2db) |
                                                                            reqbuf_retry_seen)) |
                                      ((reqbuf_state == STATE_WAIT_DATA) & (acpslv_wdata_valid_i &
                                                                            acpslv_wdata_last_i &
                                                                            ~reqbuf_slverr)) |
                                      ((reqbuf_state == STATE_WAIT_EXT) & ((all_ext_beats_returned &
                                                                            ~master_acpslv_l2_waiting_i &
                                                                            require_tagctl_after_ext &
                                                                            ~require_compack_after_ext &
                                                                            ~require_resp_after_ext) |
                                                                           reqbuf_retry_seen)) |
                                      ((reqbuf_state == STATE_PICK_VICTIM_ACK) & victimctl_victim_ack) |
                                      ((reqbuf_state == STATE_UPDATE_VICTIM) & (reqbuf_victimctl_ready_i &
                                                                                require_tagctl_after_update)) |
                                      ((reqbuf_state == STATE_COMPACK) & (reqbuf_compack_ready_i &
                                                                          require_tagctl_after_compack)));

   assign reqbuf_victim_next_state_tc0_tc1 = ((reqbuf_victim_state == STATE_VICTIM_TC0) |
                                             ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) &
                                              ~(reqbuf_arb_tc1_i & ~tagctl_slv_flush_tc1_i)) |
                                             ((reqbuf_victim_state == STATE_VICTIM_TC4) &
                                              tagctl_slv_flush_tc4_i) |
                                             ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                              victim_l2db_done & victim_require_tagctl_after_l2db) |
                                             ((reqbuf_victim_state == STATE_VICTIM_PICK_ACK) &
                                              victimctl_victim_ack));

  assign reqbuf_wait_data_o = &reqbuf_state[3:1];

  // Enable various state only when active. The victim state machine will never
  // be active unless the main state machine is also active.
  assign reqbuf_en = reqbuf_alloc_i | (reqbuf_state != STATE_IDLE);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_state        <= STATE_IDLE;
    reqbuf_victim_state <= STATE_VICTIM_IDLE;
  end else if (reqbuf_en) begin
    reqbuf_state        <= next_reqbuf_state;
    reqbuf_victim_state <= next_reqbuf_victim_state;
  end

  assign start_victim_no_flush = ((reqbuf_state == STATE_TC4) & ~acpslv_ecc_err_tc4_i &
                                  reqbuf_read &
                                  (reqbuf_pass == PASS_READ_SERIALISE) &
                                  reqbuf_read_alloc &
                                  reqbuf_l2_victim_valid &
                                  ~(reqbuf_l1_hit | reqbuf_l2_hit));

  assign start_victim = start_victim_no_flush & ~tagctl_slv_flush_tc4_i;

  // State machine control logic.
  assign require_tagctl_after_l2db = (reqbuf_write & ~reqbuf_slverr &
                                      ((reqbuf_pass == PASS_WRITE_L2DB) |
                                       ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                        (ACE != 0) &
                                        ((reqbuf_l1_hit | reqbuf_l2_hit) ? ~reqbuf_cluster_unique :
                                                                           (`CA53_MEM_WBWA(reqbuf_attrs) &
                                                                            (reqbuf_shareable | ~reqbuf_l2db_full))) &
                                        (reqbuf_l2_hit | ~reqbuf_l2_victim_valid))));

  assign require_l2db_after_l2db = reqbuf_read & (reqbuf_pass == PASS_READ_REORDER1);

  assign require_resp_after_l2db = reqbuf_write & (reqbuf_slverr |
                                                   (reqbuf_pass == PASS_WRITE_MISS_RETRY) |
                                                   (reqbuf_pass == PASS_WRITE_N_UNIQUE) |
                                                   ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                    ((reqbuf_l2_hit & reqbuf_cluster_unique) |
                                                     (reqbuf_l1_hit & reqbuf_cluster_unique &
                                                      (~reqbuf_l2db_full |
                                                       ~reqbuf_l2_victim_valid)) |
                                                     (`CA53_MEM_WBWA(reqbuf_attrs) &
                                                      ~reqbuf_shareable &
                                                      ~reqbuf_l2_victim_valid) |
                                                     (((ACE == 0) | ~reqbuf_shareable) &
                                                      ~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                                      ~`CA53_MEM_WBWA(reqbuf_attrs)))));

  assign require_resp_after_ext = reqbuf_write & ~reqbuf_l1_hit & ~reqbuf_l2_hit & ~`CA53_MEM_WBWA(reqbuf_attrs);

  assign require_tagctl_after_ext = (reqbuf_read & reqbuf_read_alloc) | (reqbuf_write & ~require_victim_pick_after_ext);

  assign require_victim_pick_after_ext = (reqbuf_write &
                                          reqbuf_l2_victim_valid & ~reqbuf_l2_hit &
                                          ((reqbuf_pass == PASS_WRITE_HIT_RETRY) |
                                           ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                            (reqbuf_l1_hit | reqbuf_l2_hit |
                                             `CA53_MEM_WBWA(reqbuf_attrs)))));

  assign require_compack_after_ext = (ACE == 0);

  assign require_compack_after_l2db = ((ACE == 0) &
                                       reqbuf_write &
                                       ((reqbuf_pass == PASS_WRITE_HIT_RETRY) |
                                        ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                         ((reqbuf_l1_hit |
                                           reqbuf_l2_hit) ? ~reqbuf_cluster_unique :
                                                            (`CA53_MEM_WBWA(reqbuf_attrs) &
                                                             (reqbuf_shareable |
                                                              ~reqbuf_l2db_full))))));


  assign require_tagctl_after_compack = (reqbuf_read |
                                         (reqbuf_write & (reqbuf_l2_hit | ~reqbuf_l2_victim_valid)));

  assign require_l2db_after_afb = ((reqbuf_write & ((reqbuf_pass == PASS_WRITE_MISS) |
                                                    (reqbuf_pass == PASS_WRITE_MISS_RETRY) |
                                                    (reqbuf_pass == PASS_WRITE_N_UNIQUE) |
                                                    (reqbuf_pass == PASS_WRITE_UNIQUE1) |
                                                    (reqbuf_pass == PASS_WRITE_UNIQUE2) |
                                                    ((reqbuf_pass == PASS_WRITE_HIT_RETRY) &
                                                     ~reqbuf_l2db_full) |
                                                    ((reqbuf_pass == PASS_WRITE_SERIALISE) &

                                                     (((reqbuf_l2_hit | (reqbuf_l1_hit &
                                                                         (~reqbuf_l2_victim_valid |
                                                                          ~reqbuf_l2db_full))) &
                                                       reqbuf_cluster_unique) |
                                                      (((reqbuf_l1_hit & ~reqbuf_cluster_unique) |
                                                        reqbuf_l2_hit) &
                                                       ~reqbuf_l2db_full) |
                                                      (~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                                       ((`CA53_MEM_WBWA(reqbuf_attrs)) ?
                                                        ((~reqbuf_shareable & ~reqbuf_l2_victim_valid) |
                                                         ~reqbuf_l2db_full) :
                                                        ((ACE == 0) | ~reqbuf_shareable))))))) |
                                   (reqbuf_read & (reqbuf_l1_hit | reqbuf_l2_hit)));

  assign require_ext_after_afb = ((reqbuf_read & ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                  (reqbuf_write &
                                   (((reqbuf_pass == PASS_WRITE_HIT_RETRY) & reqbuf_l2db_full) |
                                    ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                     ((reqbuf_l1_hit | reqbuf_l2_hit) ? (reqbuf_l2db_full & ~reqbuf_cluster_unique) :
                                                                        ((ACE != 0) ? ((reqbuf_shareable &
                                                                                        ~(~reqbuf_l2db_full &
                                                                                          `CA53_MEM_WBWA(reqbuf_attrs)))) :
                                                                                      (reqbuf_shareable &
                                                                                       reqbuf_l2db_full &
                                                                                       `CA53_MEM_WBWA(reqbuf_attrs))))))));

  assign require_victim_pick_after_afb = (reqbuf_write &
                                          (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                          ~reqbuf_l2_hit &
                                          reqbuf_l2_victim_valid &
                                          reqbuf_l2db_full &
                                          (reqbuf_l1_hit ? reqbuf_cluster_unique :
                                           (`CA53_MEM_WBWA(reqbuf_attrs) &
                                            ~reqbuf_shareable)));

  assign require_victim_pick_after_l2db = (reqbuf_write &
                                           (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                           ~reqbuf_l2_hit &
                                           reqbuf_l2_victim_valid &
                                           (ACE != 0) &
                                           (reqbuf_l1_hit ? ~reqbuf_cluster_unique :
                                                            `CA53_MEM_WBWA(reqbuf_attrs)));

  assign require_tagctl_after_resp = reqbuf_write & ~reqbuf_slverr & ~((reqbuf_pass == PASS_WRITE_MISS_RETRY) |
                                                                       ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                                        ~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                                                        ((ACE == 0) |
                                                                         ~reqbuf_shareable) &
                                                                        ~`CA53_MEM_WBWA(reqbuf_attrs)));

  assign require_l2db_after_tc1 = ((reqbuf_write & (reqbuf_pass == PASS_WRITE_UNIQUE1)) |
                                   (reqbuf_read & (reqbuf_pass == PASS_READ_REORDER1)));

  assign require_data_after_tc2 = reqbuf_write & (reqbuf_pass == PASS_WRITE_L2DB);

  assign require_update_victim_after_l2db = ((reqbuf_read &
                                              (((reqbuf_pass == PASS_READ_SERIALISE) &
                                                reqbuf_l2_hit) |
                                               (reqbuf_pass == PASS_READ_REORDER2))) |
                                             (reqbuf_write &
                                              (reqbuf_pass == PASS_WRITE_UNIQUE1)));

  assign require_tagctl_after_tc1 = reqbuf_read & (reqbuf_pass == PASS_READ_MISS) & reqbuf_beats_reordered;

  assign require_update_victim_after_tc1 = reqbuf_read & (reqbuf_pass == PASS_READ_MISS) & ~reqbuf_beats_reordered;

  assign require_tagctl_after_update = (reqbuf_write &
                                        (reqbuf_pass == PASS_WRITE_UNIQUE1) &
                                        reqbuf_l2_victim_valid &
                                        ~reqbuf_l2_hit);


  assign victim_require_idle_after_tc3 = ((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                          ~tagctl_l2_victim_valid_tc3_i) & ~tagctl_ecc_err_tc3_i;

  assign victim_require_l2db_after_afb = ((reqbuf_victim_pass == PASS_VICTIM_READ) |
                                          afb_victim_write);

  assign victim_require_tagctl_after_l2db = (reqbuf_victim_pass == PASS_VICTIM_READ);

  assign reqbuf_busy_o = (reqbuf_state != STATE_IDLE);

  // Keep track of what stage the request is at, and therefore what it needs
  // to do the next time it goes down tagctl.
  assign update_reqbuf_pass = (reqbuf_alloc_i |
                               ((reqbuf_state == STATE_WAIT_L2DB) & (reqbuf_retry_seen |
                                                                     (primary_l2db_done &
                                                                      (require_tagctl_after_l2db |
                                                                       require_l2db_after_l2db)))) |
                               ((reqbuf_state == STATE_WAIT_EXT) & (reqbuf_retry_seen |
                                                                    (all_ext_beats_returned &
                                                                     ~master_acpslv_l2_waiting_i &
                                                                     ~require_compack_after_ext &
                                                                     ~require_victim_pick_after_ext &
                                                                     ~require_resp_after_ext))) |
                               ((reqbuf_state == STATE_WAIT_DATA) & (acpslv_wdata_valid_i &
                                                                     acpslv_wdata_last_i &
                                                                     ~reqbuf_slverr)) |
                               ((reqbuf_state == STATE_COMPACK) & (reqbuf_compack_ready_i &
                                                                   require_tagctl_after_compack)) |
                               ((reqbuf_state == STATE_PICK_VICTIM_ACK) & victimctl_victim_ack) |
                               ((reqbuf_state == STATE_UPDATE_VICTIM) & (reqbuf_victimctl_ready_i &
                                                                         require_tagctl_after_update)) |
                                ((reqbuf_state == STATE_RESP) & reqbuf_db_ready_i & require_tagctl_after_resp) |
                               (reqbuf_state_tc1 & ~tagctl_slv_flush_tc1_i & require_tagctl_after_tc1));

  always @*
  if (reqbuf_state == STATE_IDLE) begin
    next_reqbuf_pass = PASS_INITIAL;
  end else if (reqbuf_read) begin
    case (reqbuf_pass)
      PASS_READ_SERIALISE:   next_reqbuf_pass = reqbuf_retry_seen ? PASS_READ_RETRY :
                                                                    PASS_READ_MISS;
      PASS_READ_RETRY:       next_reqbuf_pass = PASS_READ_MISS;
      PASS_READ_MISS:        next_reqbuf_pass = PASS_READ_REORDER1;
      PASS_READ_REORDER1:    next_reqbuf_pass = PASS_READ_REORDER2;
      default:               next_reqbuf_pass = PASS_X;
    endcase
  end else begin
    case (reqbuf_pass)
      PASS_WRITE_L2DB:       next_reqbuf_pass = PASS_WRITE_SERIALISE;
      PASS_WRITE_SERIALISE:  next_reqbuf_pass = (reqbuf_l1_hit |
                                                 reqbuf_l2_hit) ?
                                                (((reqbuf_l2_hit |
                                                   (reqbuf_l1_hit & (~reqbuf_l2db_full |
                                                                     ~reqbuf_l2_victim_valid))) &
                                                  reqbuf_cluster_unique) ? PASS_WRITE_UNIQUE1 :
                                                 reqbuf_retry_seen       ? PASS_WRITE_HIT_RETRY :
                                                                           PASS_WRITE_N_UNIQUE) :
                                                (~reqbuf_shareable &
                                                 reqbuf_l2db_full &
                                                 `CA53_MEM_WBWA(reqbuf_attrs) &
                                                 ~reqbuf_l2_victim_valid) ? PASS_WRITE_UNIQUE1 :
                                                ~`CA53_MEM_WBWA(reqbuf_attrs) ?
                                                (reqbuf_retry_seen ? PASS_WRITE_MISS_RETRY :
                                                                     PASS_WRITE_MISS) :
                                                reqbuf_retry_seen  ? PASS_WRITE_HIT_RETRY :
                                                                     PASS_WRITE_N_UNIQUE;
      PASS_WRITE_MISS_RETRY: next_reqbuf_pass = PASS_WRITE_MISS;
      PASS_WRITE_HIT_RETRY:  next_reqbuf_pass = PASS_WRITE_N_UNIQUE;
      PASS_WRITE_N_UNIQUE:   next_reqbuf_pass = PASS_WRITE_UNIQUE1;
      PASS_WRITE_UNIQUE1:    next_reqbuf_pass = PASS_WRITE_UNIQUE2;
      default:               next_reqbuf_pass = PASS_X;
    endcase
  end

  always @(posedge clk)
  if (update_reqbuf_pass) begin
    reqbuf_pass <= next_reqbuf_pass;
  end

  assign update_reqbuf_victim_pass = (((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                       (reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) & victim_l2db_done) |
                                      ((reqbuf_victim_state == STATE_VICTIM_PICK_ACK) & victimctl_victim_ack));

  assign next_reqbuf_victim_pass = ((reqbuf_state == STATE_IDLE) ? 2'b00 :
                                    update_reqbuf_victim_pass ? (reqbuf_victim_pass + 2'b01) :
                                    reqbuf_victim_pass);

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_victim_pass <= next_reqbuf_victim_pass;
  end

  // Tell the tagctl arbitration when to throw away any cached data for this
  // tagctl pass.
  assign reqbuf_update_primary_pass_o = update_reqbuf_pass;
  assign reqbuf_update_victim_pass_o  = update_reqbuf_victim_pass;

  assign reqbuf_shareable = ((`CA53_MEM_SHAREABLE(reqbuf_attrs) & acpslv_broadcastinner_i) |
                             (`CA53_MEM_O_SHAREABLE(reqbuf_attrs) & acpslv_broadcastouter_i));


  //----------------------------------------------------------------------------
  //  Request storage
  //----------------------------------------------------------------------------

  always @(posedge clk)
  if (reqbuf_alloc_i) begin
    reqbuf_acp_id  <= acp_addr_id_i;
    reqbuf_read    <= acp_addr_read_i;
    reqbuf_rwalloc <= acp_addr_alloc_i;
    reqbuf_addr1   <= acp_addr_addr_i;
    reqbuf_len     <= acp_addr_len_i;
    reqbuf_domain  <= acp_addr_domain_i;
    reqbuf_slverr  <= acp_addr_slverr_i;
  end

  assign reqbuf_write = ~reqbuf_read;

  // Skyros reads must allocate, because we use the L2 cache to buffer the
  // data if it arrives back from the interconnect out or order.
  assign reqbuf_attrs = {2'b10,
                         {4{reqbuf_rwalloc}},
                         |reqbuf_domain, reqbuf_domain[0]};

  assign reqbuf_read_alloc = reqbuf_rwalloc | (ACE == 0);

  // The second address holds the L2 victim address.
  assign reqbuf_addr2_en = ((((reqbuf_state == STATE_TC3) &
                              (reqbuf_read ? (reqbuf_pass == PASS_READ_SERIALISE) :
                                             ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                              (reqbuf_pass == PASS_WRITE_N_UNIQUE)))) |
                             ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                              (reqbuf_victim_pass == PASS_VICTIM_READ))) &
                            ~tagctl_ecc_err_tc3_i);

  always @(posedge clk)
  if (reqbuf_addr2_en) begin
    reqbuf_addr2 <= tagctl_addr_tc3_i[40:6];
  end

  // Encode and store where in L1 and L2 the request hit.
  assign next_reqbuf_l2_hit = |tagctl_l2_hit_ways_tc3_i;

  assign next_reqbuf_l1_hit_cpus = {|tagctl_l1_hit_ways_tc3_i[15:12],
                                    |tagctl_l1_hit_ways_tc3_i[11:8],
                                    |tagctl_l1_hit_ways_tc3_i[7:4],
                                    |tagctl_l1_hit_ways_tc3_i[3:0]};

  assign tagctl_l1_hit_ways_tc3_0 = tagctl_l1_hit_ways_tc3_i[3:0];
  assign tagctl_l1_hit_ways_tc3_1 = tagctl_l1_hit_ways_tc3_i[7:4];
  assign tagctl_l1_hit_ways_tc3_2 = tagctl_l1_hit_ways_tc3_i[11:8];
  assign tagctl_l1_hit_ways_tc3_3 = tagctl_l1_hit_ways_tc3_i[15:12];

  assign next_reqbuf_l1_hit_ways = {`CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_3),
                                    `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_2),
                                    `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_1),
                                    `CA53_L1_WAY_ENC(tagctl_l1_hit_ways_tc3_0)};

  assign hit_state_en_tc3 = ((reqbuf_state == STATE_TC3) &
                             ~tagctl_slv_flush_tc3_i & ~tagctl_ecc_err_tc3_i &
                             (reqbuf_write ? ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                              (reqbuf_pass == PASS_WRITE_N_UNIQUE)) :
                                             (reqbuf_pass == PASS_READ_SERIALISE)));

  always @(posedge clk)
  if (hit_state_en_tc3) begin
    reqbuf_l2_hit         <= next_reqbuf_l2_hit;
    reqbuf_l1_hit_cpus    <= next_reqbuf_l1_hit_cpus;
    reqbuf_l1_hit_ways    <= next_reqbuf_l1_hit_ways;
    reqbuf_cluster_unique <= tagctl_cluster_unique_tc3_i;
  end

  assign hit_state_en_tc4 = ((reqbuf_state == STATE_TC4) &
                             ~tagctl_slv_flush_tc4_i &
                             (reqbuf_write ? ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                              (reqbuf_pass == PASS_WRITE_N_UNIQUE)) :
                                             (reqbuf_pass == PASS_READ_SERIALISE)));


  always @(posedge clk)
  if (hit_state_en_tc4) begin
    reqbuf_snoop_data_cpu <= tagctl_snoop_data_cpu_tc4_i;
  end

  // For requests that can both hit in the cluster and still need to make an
  // external request, or update the tags, we alter the shareability of the
  // original request to match that of the lines that hit, to ensure consistent
  // behaviour for the line in the cache (i.e. the line cannot change its
  // shareability once allocated to the cluster).
  assign reqbuf_shareability_en = (reqbuf_alloc_i |
                                   ((reqbuf_state == STATE_TC3) &
                                    reqbuf_write &
                                    (reqbuf_pass == PASS_WRITE_SERIALISE)));

  // If the request doesn't hit then we must keep the original shareability.
  // This must include the case when the request hits but is flushed, and then
  // misses when it retries the lookup.
  assign use_hit_shareability = |next_reqbuf_l1_hit_cpus | next_reqbuf_l2_hit;

  assign next_reqbuf_shareability = (reqbuf_alloc_i       ? {|acp_addr_domain_i, acp_addr_domain_i[0]} :
                                     use_hit_shareability ? tagctl_shareability_tc3_i :
                                                            {|reqbuf_domain, reqbuf_domain[0]});

  always @(posedge clk)
  if (reqbuf_shareability_en) begin
    reqbuf_shareability <= next_reqbuf_shareability;
  end

  assign reqbuf_l1_hit = |reqbuf_l1_hit_cpus;

  assign next_reqbuf_wdata_chunk = reqbuf_alloc_i       ? acp_addr_addr_i[5:4] :
                                   acpslv_wdata_valid_i ? (reqbuf_wdata_chunk + 2'b01) :
                                                          reqbuf_wdata_chunk;

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_wdata_chunk <= next_reqbuf_wdata_chunk;
  end

  assign reqbuf_wdata_chunk_o = reqbuf_wdata_chunk;

  // WriteUniques need to know if the request is for a full cache line of data,
  // to determine what type of request to send.
  always @*
  case (primary_l2db)
    4'b0000: next_reqbuf_l2db_full = l2db0_full_line_i;
    4'b0001: next_reqbuf_l2db_full = l2db1_full_line_i;
    4'b0010: next_reqbuf_l2db_full = l2db2_full_line_i;
    4'b0011: next_reqbuf_l2db_full = l2db3_full_line_i;
    4'b0100: next_reqbuf_l2db_full = l2db4_full_line_i;
    4'b0101: next_reqbuf_l2db_full = l2db5_full_line_i;
    4'b0110: next_reqbuf_l2db_full = l2db6_full_line_i;
    4'b0111: next_reqbuf_l2db_full = l2db7_full_line_i;
    4'b1000: next_reqbuf_l2db_full = l2db8_full_line_i;
    4'b1001: next_reqbuf_l2db_full = l2db9_full_line_i;
    4'b1010: next_reqbuf_l2db_full = l2db10_full_line_i;
    default: next_reqbuf_l2db_full = 1'bx;
  endcase

  // We must only capture the original full state of the L2DB after the CPU has
  // written but before serialisation. This allows us to work out which tagctl
  // pass were are on without it changing when further data is merged in.
  assign reqbuf_l2db_full_en = (reqbuf_state_tc0 &
                                reqbuf_write &
                                (reqbuf_pass == PASS_WRITE_SERIALISE));

  always @(posedge clk)
  if (reqbuf_l2db_full_en) begin
    reqbuf_l2db_full <= next_reqbuf_l2db_full;
  end

  assign reqbuf_l2db_full_o = reqbuf_l2db_full;

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

  // Store the results of the victim lookup.
  assign l1_victim_hit_en = (((reqbuf_victim_state == STATE_VICTIM_TC3) &
                              (reqbuf_victim_pass == PASS_VICTIM_WRITE)) |
                             ((reqbuf_state == STATE_TC3) &
                              reqbuf_write &
                              (reqbuf_pass == PASS_WRITE_UNIQUE2)));

  assign next_reqbuf_l1_victim_hit = |next_reqbuf_l1_hit_cpus;

  always @(posedge clk)
  if (l1_victim_hit_en) begin
    reqbuf_l1_victim_hit <= next_reqbuf_l1_victim_hit;
  end

  assign l2_victim_hit_en = (((reqbuf_state == STATE_TC3) & ~tagctl_slv_flush_tc3_i &
                              ((reqbuf_read & (reqbuf_pass == PASS_READ_SERIALISE)) |
                               (reqbuf_write & ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                                (reqbuf_pass == PASS_WRITE_N_UNIQUE))))) |
                             ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                              (reqbuf_victim_pass == PASS_VICTIM_READ)));

  always @(posedge clk)
  if (l2_victim_hit_en) begin
    reqbuf_l2_victim_valid        <= tagctl_l2_victim_valid_tc3_i;
    reqbuf_l2_victim_dirty        <= tagctl_l2_dirty_tc3_i;
    reqbuf_l2_victim_shareability <= tagctl_l2_victim_shareability_tc3_i;
    reqbuf_l2_victim_alloc        <= tagctl_l2_victim_alloc_tc3_i;
    reqbuf_l2_victim_cu           <= tagctl_l2_victim_cu_tc3_i;
  end

  assign victimctl_victim_ack = victimctl_ack_i & (victimctl_ack_id_i == REQBUF_ID[5:0]);

  assign l2_victim_way_en = ((l2_victim_hit_en & (reqbuf_victim_state != STATE_VICTIM_TC3)) |
                             victimctl_victim_ack);

  assign next_reqbuf_l2_victim_way = (victimctl_victim_ack ? victimctl_victim_way_i : 
                                      next_reqbuf_l2_hit   ? `CA53_L2_WAY_ENC(tagctl_l2_hit_ways_tc3_i) :
                                                             tagctl_l2_victim_way_tc3_i);

  always @(posedge clk)
  if (l2_victim_way_en) begin
    reqbuf_l2_victim_way <= next_reqbuf_l2_victim_way;
  end


  assign reqbuf_type_o = reqbuf_read ? `CA53_REQ_READONCE : `CA53_REQ_WRITEUNIQUE;
  assign reqbuf_len_o  = (reqbuf_write | reqbuf_len) ? 2'b11 : 2'b00;

  // All ACP requests are coherent and therefore may be cached and so are
  // marked as privileged and data
  assign reqbuf_prot_o   = 2'b01;
  assign reqbuf_acp_id_o = reqbuf_acp_id;
  assign reqbuf_slverr_o = reqbuf_slverr;

  //----------------------------------------------------------------------------
  //  Tagctl requests
  //----------------------------------------------------------------------------

  // Make a request if either the primary or victim state machines want to.
  // Victim requests must have priority over primary requests because they may
  // need to make progress to allow a hazarding snoop to progress, but the
  // primary request may not be able to progress if it needs to make a master
  // read access.
  assign next_reqbuf_tagctl_req_tc0 = ((reqbuf_victim_next_state_tc0_tc1 ? (reqbuf_tagctl_prearb_victim_i &
                                                                            ~update_reqbuf_victim_pass) :
                                        (reqbuf_next_state_tc0_tc1 &
                                         ((reqbuf_state == STATE_IDLE) |
                                          ((update_reqbuf_pass ? next_reqbuf_pass :
                                                                 reqbuf_pass) <= {2'b00, reqbuf_write}) |
                                          (reqbuf_tagctl_prearb_primary_i &
                                           ~update_reqbuf_pass &
                                           reqbuf_tagctl_primary_tc0)))) &
                                       ~next_acpslv_noncoh_only_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_tagctl_req_tc0 <= 1'b0;
  end else begin
    reqbuf_tagctl_req_tc0 <= next_reqbuf_tagctl_req_tc0;
  end

  assign reqbuf_tagctl_valid_tc0 = reqbuf_tagctl_req_tc0 & ~reqbuf_arb_tc1_i;

  assign reqbuf_tagctl_valid_tc0_o = reqbuf_tagctl_valid_tc0;

  assign next_reqbuf_tagctl_prearb_req = (reqbuf_victim_next_state_tc0_tc1 ? (~reqbuf_tagctl_prearb_victim_i |
                                                                              update_reqbuf_victim_pass) :
                                          (reqbuf_next_state_tc0_tc1 &
                                           (reqbuf_state != STATE_IDLE) &
                                           ((update_reqbuf_pass ? next_reqbuf_pass :
                                                                  reqbuf_pass) > {2'b00, reqbuf_write}) &
                                           (~reqbuf_tagctl_prearb_primary_i |
                                            update_reqbuf_pass)));

  always @(posedge clk or negedge reset_n)
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

  always @*
  case (reqbuf_read)
    1'b1: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:   reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_SERIALISE;
        PASS_READ_MISS:        reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_UPDATE;
        PASS_READ_RETRY:       reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_MASTER_R;
        PASS_READ_REORDER1:    reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_L2DB;
        default:               reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_X;
      endcase
    end
    1'b0: begin
      case (reqbuf_pass)
        PASS_WRITE_L2DB:       reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_L2DB;
        PASS_WRITE_SERIALISE:  reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_SERIALISE;
        PASS_WRITE_N_UNIQUE:   reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_LOOKUP;
        PASS_WRITE_UNIQUE1:    reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_UPDATE;
        PASS_WRITE_UNIQUE2:    reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_VICTIM;
        PASS_WRITE_HIT_RETRY:  reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_MASTER_R;
        PASS_WRITE_MISS_RETRY: reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_MASTER_W;
        PASS_WRITE_MISS:       reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_MASTER_W;
        default:               reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_X;
      endcase
    end
    default: reqbuf_primary_pass_tc0 = `CA53_TAGCTL_PASS_X;
  endcase

  assign reqbuf_victim_pass_tc0 = ((reqbuf_victim_pass == PASS_VICTIM_WRITE) ? `CA53_TAGCTL_PASS_VICTIM :
                                   (reqbuf_victim_pass == PASS_VICTIM_READ)  ? `CA53_TAGCTL_PASS_LOOKUP :
                                                                               `CA53_TAGCTL_PASS_VICTIM_UPDATE);

  assign reqbuf_tagctl_pass_tc0 = reqbuf_tagctl_primary_tc0 ? reqbuf_primary_pass_tc0 : reqbuf_victim_pass_tc0;

  assign reqbuf_tagctl_pass_tc0_o = reqbuf_tagctl_pass_tc0;

  // Send the address to tagctl. This can be the address being looked up
  // (either primary or victim), or the address being written for a tag update.
  assign reqbuf_tagctl_addr1_tc0_o = (reqbuf_tagctl_primary_tc0 &
                                      ~(reqbuf_write &
                                        (reqbuf_pass == PASS_WRITE_UNIQUE2))) ? {reqbuf_addr1, 4'b0000} :
                                                                                {reqbuf_addr2, 6'b000000};

  // Provide the state bits for tag RAM writes.
  assign tag_state_l2_tc0 = {{2{ext_beats_resp == `CA53_ACE_RESP_OKAY}} &
                             {`CA53_MEM_SHAREABLE(reqbuf_shareability),
                              `CA53_MEM_O_SHAREABLE(reqbuf_shareability) |
                              ~`CA53_MEM_SHAREABLE(reqbuf_shareability)},
                             ~ext_beats_shared | reqbuf_write,
                             ext_beats_dirty   | reqbuf_write,
                             `CA53_MEM_OUTER_WA(reqbuf_attrs)};

  assign reqbuf_tagctl_wr_state_tc0_o = {tag_state_l2_tc0, 12'h000};


  assign reqbuf_victim_tagctl_ways_tc0 = (reqbuf_victim_pass == PASS_VICTIM_WRITE) ? 32'h0000ffff :
                                                                                     {`CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                                                                      16'h0000};

  assign reqbuf_l1_hit_ways_0 = reqbuf_l1_hit_ways[1:0];
  assign reqbuf_l1_hit_ways_1 = reqbuf_l1_hit_ways[3:2];
  assign reqbuf_l1_hit_ways_2 = reqbuf_l1_hit_ways[5:4];
  assign reqbuf_l1_hit_ways_3 = reqbuf_l1_hit_ways[7:6];

  assign reqbuf_hit_ways = {{16{reqbuf_l2_hit}} & `CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                            {4{reqbuf_l1_hit_cpus[3]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_3),
                            {4{reqbuf_l1_hit_cpus[2]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_2),
                            {4{reqbuf_l1_hit_cpus[1]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_1),
                            {4{reqbuf_l1_hit_cpus[0]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_0)};

  always @*
  case (reqbuf_read)
    1'b1: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:  reqbuf_primary_tagctl_ways_tc0 = 32'hffffffff;
        PASS_READ_RETRY:      reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_READ_REORDER1:   reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_READ_MISS:       reqbuf_primary_tagctl_ways_tc0 = {`CA53_L2_WAY_DEC(reqbuf_l2_victim_way), 16'h0000};
        default:              reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    1'b0:  begin
      case (reqbuf_pass)
        PASS_WRITE_SERIALISE: reqbuf_primary_tagctl_ways_tc0 = 32'hffffffff;
        PASS_WRITE_L2DB,
        PASS_WRITE_MISS_RETRY,
        PASS_WRITE_HIT_RETRY,
        PASS_WRITE_MISS:      reqbuf_primary_tagctl_ways_tc0 = 32'h00000000;
        PASS_WRITE_UNIQUE2:   reqbuf_primary_tagctl_ways_tc0 = 32'h0000ffff;
        PASS_WRITE_UNIQUE1,
        PASS_WRITE_N_UNIQUE:  reqbuf_primary_tagctl_ways_tc0 = {reqbuf_l2_hit ? reqbuf_hit_ways[31:16] :
                                                                                `CA53_L2_WAY_DEC(reqbuf_l2_victim_way),
                                                                reqbuf_hit_ways[15:0]};
        default:              reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
      endcase
    end
    default:                  reqbuf_primary_tagctl_ways_tc0 = 32'hxxxxxxxx;
  endcase

  assign reqbuf_tagctl_ways_tc0_o = reqbuf_tagctl_primary_tc0 ? reqbuf_primary_tagctl_ways_tc0 : 
                                                                reqbuf_victim_tagctl_ways_tc0;

  assign reqbuf_tagctl_primary_write_tc0 = ((reqbuf_read &
                                             (reqbuf_pass != PASS_READ_SERIALISE)) |
                                            (reqbuf_write &
                                             (reqbuf_pass == PASS_WRITE_UNIQUE1)));

  assign reqbuf_tagctl_write_tc0_o = {5{reqbuf_tagctl_primary_tc0 & reqbuf_tagctl_primary_write_tc0}};

  // TC1 data
  assign reqbuf_dirty_o = reqbuf_l2_victim_dirty;

  assign reqbuf_cluster_unique_o = reqbuf_l2_victim_cu;

  assign reqbuf_victim_way_tc1_o = reqbuf_l2_victim_way;

  assign reqbuf_l2db_tc1_o = reqbuf_state_tc1 ? primary_l2db : victim_l2db;

  assign victim_attrs = {4'b1011, 1'b1, reqbuf_l2_victim_alloc, reqbuf_l2_victim_shareability};

  assign reqbuf_attrs_o = (reqbuf_state_tc1 &
                           ~((reqbuf_pass == PASS_WRITE_UNIQUE2) &
                             reqbuf_write)) ? {reqbuf_attrs[7:2],
                                               (reqbuf_pass <= {2'b00, reqbuf_write}) ? reqbuf_attrs[1:0] :
                                                                                        reqbuf_shareability} :
                                              victim_attrs;

  assign reqbuf_len_tc1_o  = (reqbuf_write |
                              (reqbuf_read & (reqbuf_len |      
                                              reqbuf_read_alloc))) ? 2'b11 : 2'b00;

  // The AFB is allocated in tc1, and we must record it so that we know when it
  // has completed all snoops or master requests.
  assign next_reqbuf_afb = reqbuf_state_tc1 ? tagctl_slv_afb_tc1_i : reqbuf_afb;

  assign next_reqbuf_victim_afb = (reqbuf_victim_state_tc1 |
                                   (reqbuf_state_tc1 &
                                    (reqbuf_pass == PASS_READ_SERIALISE))) ? tagctl_slv_afb_tc1_i : reqbuf_victim_afb;

  always @(posedge clk)
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

  assign afb_victim_write = ((afb0_done_i & (reqbuf_victim_afb == 3'b000) & afb0_write_done_i) |
                             (afb1_done_i & (reqbuf_victim_afb == 3'b001) & afb1_write_done_i) |
                             (afb2_done_i & (reqbuf_victim_afb == 3'b010) & afb2_write_done_i) |
                             (afb3_done_i & (reqbuf_victim_afb == 3'b011) & afb3_write_done_i) |
                             (afb4_done_i & (reqbuf_victim_afb == 3'b100) & afb4_write_done_i) |
                             (afb5_done_i & (reqbuf_victim_afb == 3'b101) & afb5_write_done_i));

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
                                      ((reqbuf_state == STATE_WAIT_AFB) &
                                       afb_done & require_victim_pick_after_afb) |
                                      ((reqbuf_state == STATE_WAIT_EXT) &
                                       all_ext_beats_returned &
                                       require_victim_pick_after_ext &
                                       ~require_compack_after_ext) |
                                      ((reqbuf_state == STATE_COMPACK) &
                                       reqbuf_compack_ready_i & ~require_tagctl_after_compack) |
                                      (reqbuf_state_tc1 & require_update_victim_after_tc1) |
                                      (start_victim_no_flush &
                                       ~tagctl_slv_early_flush_tc4_i));

  assign reqbuf_victimctl_valid_o = ((reqbuf_state == STATE_UPDATE_VICTIM) |
                                     (reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                     (reqbuf_victim_state == STATE_VICTIM_PICK_REQ));

  assign reqbuf_victimctl_index_o = reqbuf_addr1[16:6];

  assign reqbuf_victimctl_wr_o = (reqbuf_state == STATE_UPDATE_VICTIM);

  assign reqbuf_victimctl_age_o = reqbuf_l2_hit;

  assign reqbuf_victimctl_way_o = reqbuf_l2_victim_way;

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
    assign reqbuf_retry_seen = 1'b0;
    assign reqbuf_retry_received_en = 1'b0;

  end else begin : g_skyros
    reg [7:0]  reqbuf_dbid;
    reg [6:0]  reqbuf_tgtid;
    reg [1:0]  reqbuf_pcrdtype;
    reg        reqbuf_retry_received;
    wire       reqbuf_static_pcredit_tc1;
    wire [7:0] next_reqbuf_dbid;
    wire [6:0] next_reqbuf_tgtid;
    wire       next_reqbuf_retry_received;

    assign reqbuf_rsp_comp_valid = master_rsp_comp_valid_i & (master_rsp_txnid_i == {1'b0, REQBUF_ID[5:0]});

    assign reqbuf_dbid_en = ((master_early_dr_valid_i & (master_early_dr_id_i == REQBUF_ID[5:0])) |
                             reqbuf_rsp_comp_valid);

    assign next_reqbuf_dbid  = reqbuf_rsp_comp_valid ? master_rsp_dbid_i : master_early_dr_dbid_i;
    assign next_reqbuf_tgtid = reqbuf_rsp_comp_valid ? master_rsp_srcid_i : master_early_dr_srcid_i;

    always @(posedge clk)
    if (reqbuf_dbid_en) begin
      reqbuf_dbid  <= next_reqbuf_dbid;
      reqbuf_tgtid <= next_reqbuf_tgtid;
    end

    assign reqbuf_compack_active_o = ((reqbuf_state == STATE_COMPACK) |
                                      ((reqbuf_state == STATE_WAIT_EXT) &
                                       require_compack_after_ext &
                                       all_ext_beats_returned) |
                                      ((reqbuf_state == STATE_WAIT_L2DB) &
                                       require_compack_after_l2db &
                                       primary_l2db_done));

    assign reqbuf_compack_valid_o = (reqbuf_state == STATE_COMPACK);
    assign reqbuf_compack_tgtid_o = reqbuf_tgtid;
    assign reqbuf_compack_txnid_o = reqbuf_dbid;

    assign reqbuf_static_pcredit_tc1 = (reqbuf_state_tc1 &
                                        ((reqbuf_read & (reqbuf_pass == PASS_READ_RETRY)) |
                                         (reqbuf_write & ((reqbuf_pass == PASS_WRITE_HIT_RETRY) |
                                                          (reqbuf_pass == PASS_WRITE_MISS_RETRY)))));

    assign reqbuf_static_pcredit_tc1_o = reqbuf_static_pcredit_tc1;

    always @(posedge clk)
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

    always @(posedge clk)
    if (reqbuf_retry_received_en) begin
      reqbuf_retry_received <= next_reqbuf_retry_received;
    end
    
    assign reqbuf_retry_seen = reqbuf_retry_received | reqbuf_retry_i;

  end endgenerate

  //----------------------------------------------------------------------------
  //  L2DB control
  //----------------------------------------------------------------------------


  // L2DBs are allocated in tc1 for writes that need to recieve data from the
  // CPU. This allows the ID to be returned to the CPU as soon as possible.
  assign l2db_valid_tc1 = (reqbuf_state_tc1 &
                           ((reqbuf_write & (reqbuf_pass == PASS_WRITE_L2DB)) |
                            (reqbuf_read & (reqbuf_pass == PASS_READ_REORDER1))));

  // All other L2DBs are allocated in tc1, but not assigned to the primary or
  // victim requests until after it is known which of the two are needed.
  assign l2db_valid_tc4 = (reqbuf_state == STATE_TC4) & (reqbuf_pass == PASS_READ_SERIALISE);


  // Record the L2DBs allocated to this request when tagctl has allocated them
  // and confirmed they are needed. If the request is then flushed due to a
  // hazard tagctl is responsible for releasing them, but if the initial tagctl
  // pass is successful then the reqbuf is responsible for the L2DB after that.
  assign primary_l2db_en = l2db_valid_tc1 | l2db_valid_tc4;

  assign next_primary_l2db = l2db_valid_tc1 ? tagctl_slv_l2db_tc1_i : tagctl_slv_l2db_tc4_i;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    primary_l2db <= 4'b0000;
  end else if (primary_l2db_en) begin
    primary_l2db <= next_primary_l2db;
  end

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    victim_l2db <= 4'b0000;
  end else if (l2db_valid_tc4) begin
    victim_l2db <= tagctl_slv_l2db_tc4_i;
  end

  // Most transfers are done the cycle after we know there are no hazards, but
  // a few must be started earlier so that the L2DB is ready in time for the
  // data to arrive.
  assign next_reqbuf_l2db_primary_transfer = (((reqbuf_state == STATE_TC4) &
                                               ~tagctl_slv_flush_tc4_i &
                                               ((reqbuf_read &
                                                 (reqbuf_pass == PASS_READ_SERIALISE) &
                                                 (reqbuf_l1_hit | reqbuf_l2_hit)) |
                                                (reqbuf_write &
                                                 ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                                  (reqbuf_l1_hit ? ~reqbuf_l2db_full :
                                                   reqbuf_l2_hit ? (reqbuf_cluster_unique ? reqbuf_l2db_rmw :
                                                                                            ~reqbuf_l2db_full) :
                                                   (`CA53_MEM_WBWA(reqbuf_attrs) ? ~reqbuf_l2db_full :
                                                                                   ((ACE == 0) | ~reqbuf_shareable)))) |
                                                 ((reqbuf_pass == PASS_WRITE_N_UNIQUE) &
                                                  (reqbuf_l1_hit ? ~reqbuf_l2db_full :
                                                   reqbuf_l2_hit ? reqbuf_l2db_rmw :
                                                                   1'b0))))) |
                                              (l2db_valid_tc1 & ~tagctl_slv_flush_tc1_i) |
                                              ((reqbuf_state == STATE_TC0_TC1) &
                                               reqbuf_arb_tc1_i &
                                               ~tagctl_slv_flush_tc1_i &
                                               reqbuf_write &
                                               (reqbuf_pass == PASS_WRITE_UNIQUE1)) |
                                              ((reqbuf_state == STATE_WAIT_L2DB) &
                                               primary_l2db_done &
                                               reqbuf_read &
                                               (reqbuf_pass == PASS_READ_REORDER1)) |
                                              ((reqbuf_state == STATE_TC3) &
                                               ~tagctl_slv_flush_tc3_i &
                                               ~tagctl_ecc_err_tc3_i &
                                               reqbuf_write &
                                               ((reqbuf_pass == PASS_WRITE_MISS) |
                                                (reqbuf_pass == PASS_WRITE_UNIQUE1) |
                                                (reqbuf_pass == PASS_WRITE_UNIQUE2))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_primary_transfer <= 1'b0;
  end else if (reqbuf_en) begin
    reqbuf_l2db_primary_transfer <= next_reqbuf_l2db_primary_transfer;
  end

  assign reqbuf_l2db_primary_transfer_o = reqbuf_l2db_primary_transfer;
  assign reqbuf_l2db_victim_transfer_o = reqbuf_l2db_victim_transfer;

  assign reqbuf_l2db_primary_id_o = primary_l2db;
  assign reqbuf_l2db_victim_id_o = victim_l2db;

  // Slv to slv in some cases is actually L2DB to slv, but the behaviour is
  // identical if the L2DB already has the data.
  always @*
  case (reqbuf_read)
    1'b0: begin
      case (reqbuf_pass)
        PASS_WRITE_L2DB:      next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_SLV_L2DB;
        PASS_WRITE_SERIALISE: next_reqbuf_l2db_primary_transfer_type = (reqbuf_l1_hit &
                                                                        reqbuf_cluster_unique)         ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                       (reqbuf_l2_hit &
                                                                        reqbuf_cluster_unique)         ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                       (`CA53_MEM_WBWA(reqbuf_attrs) |
                                                                        reqbuf_l1_hit | reqbuf_l2_hit) ? `CA53_L2DB_TRNSFR_MASTER_L2DB :
                                                                                                         `CA53_L2DB_TRNSFR_L2DB_MASTER;
        PASS_WRITE_N_UNIQUE:  next_reqbuf_l2db_primary_transfer_type = reqbuf_l1_hit ? `CA53_L2DB_TRNSFR_SLV_L2DB :
                                                                                       `CA53_L2DB_TRNSFR_RAM_L2DB;
        PASS_WRITE_UNIQUE1:   next_reqbuf_l2db_primary_transfer_type = (reqbuf_l2_victim_valid &
                                                                        ~reqbuf_l2_hit) ? `CA53_L2DB_TRNSFR_RAM_SWAP :
                                                                                          `CA53_L2DB_TRNSFR_L2DB_RAM;
        PASS_WRITE_UNIQUE2:   next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_L2DB_MASTER;
        PASS_WRITE_MISS:      next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_L2DB_MASTER;
        default:              next_reqbuf_l2db_primary_transfer_type = 3'bxxx;
      endcase
    end
    1'b1: begin
      case (reqbuf_pass)
        PASS_READ_SERIALISE:  next_reqbuf_l2db_primary_transfer_type = reqbuf_l2_hit ? `CA53_L2DB_TRNSFR_RAM_SLV :
                                                                                       `CA53_L2DB_TRNSFR_SLV_SLV;
        PASS_READ_REORDER1:   next_reqbuf_l2db_primary_transfer_type = update_reqbuf_pass ? `CA53_L2DB_TRNSFR_SLV_SLV :
                                                                                            `CA53_L2DB_TRNSFR_RAM_L2DB;
        PASS_READ_REORDER2:   next_reqbuf_l2db_primary_transfer_type = `CA53_L2DB_TRNSFR_SLV_SLV;
        default:              next_reqbuf_l2db_primary_transfer_type = 3'bxxx;
      endcase
    end
  endcase

  always @(posedge clk)
  if (next_reqbuf_l2db_primary_transfer) begin
    reqbuf_l2db_primary_transfer_type <= next_reqbuf_l2db_primary_transfer_type;
  end

  assign reqbuf_l2db_primary_transfer_type_o = reqbuf_l2db_primary_transfer_type;

  assign primary_slv_transfer_crit = (reqbuf_read &
                                      ((reqbuf_pass == PASS_READ_REORDER1) |
                                       (reqbuf_pass == PASS_READ_REORDER2))) ? (ext_beats_received[1:0] - 2'b01) :
                                                                               reqbuf_addr1[5:4];

  assign primary_slv_transfer_info = {reqbuf_read & (reqbuf_pass == PASS_READ_REORDER2),
                                      reqbuf_read & reqbuf_l1_hit & ~reqbuf_len,
                                      {10{1'b0}},
                                      ((reqbuf_pass == PASS_WRITE_L2DB) &
                                       reqbuf_write) ? REQBUF_ID[5:0] :
                                                       {1'b0, reqbuf_snoop_data_cpu, 3'b000},
                                      primary_slv_transfer_crit,
                                      REQBUF_ID[5:0]};

  assign primary_master_transfer_info = {2'b00,
                                         (reqbuf_write &
                                          (reqbuf_pass == PASS_WRITE_UNIQUE2)) ? reqbuf_l2_victim_cu : 1'b1,
                                         1'b0,
                                         1'b1, 1'b1,
                                         1'b0,
                                         (reqbuf_write &
                                          (reqbuf_pass == PASS_WRITE_UNIQUE2)) ? victim_opcode :
                                         (reqbuf_write &
                                          (ACE == 0) &
                                          ((reqbuf_pass == PASS_WRITE_SERIALISE) |
                                           (reqbuf_pass == PASS_WRITE_MISS_RETRY) |
                                           (reqbuf_pass == PASS_WRITE_MISS))) ? `CA53_DATA_OPCODE_WRITEUNIQUE :
                                                                                `CA53_DATA_OPCODE_WRITEBACK,
                                         (reqbuf_write &
                                          (reqbuf_pass == PASS_WRITE_UNIQUE2)) ? victim_attrs : reqbuf_attrs,
                                         primary_slv_transfer_crit,
                                         (ACE != 0) ? {REQBUF_ID[5:3], reqbuf_afb} : REQBUF_ID[5:0]};

  assign primary_ram_transfer_info = {1'b0,
                                      reqbuf_read & ((reqbuf_l2_hit & ~reqbuf_len) |
                                                     (reqbuf_pass == PASS_READ_REORDER1)),
                                      1'b0,
                                      reqbuf_l2_victim_way,
                                      reqbuf_addr1[16:6],
                                      primary_slv_transfer_crit,
                                      REQBUF_ID[5:0]};

  always @*
  case (reqbuf_l2db_primary_transfer_type)
    `CA53_L2DB_TRNSFR_SLV_L2DB,
    `CA53_L2DB_TRNSFR_SLV_SLV:     reqbuf_l2db_primary_transfer_info = primary_slv_transfer_info;
    `CA53_L2DB_TRNSFR_MASTER_L2DB: reqbuf_l2db_primary_transfer_info = {12'h000, REQBUF_ID[5:0], reqbuf_addr1[5:4], 6'h00};
    `CA53_L2DB_TRNSFR_L2DB_MASTER: reqbuf_l2db_primary_transfer_info = primary_master_transfer_info;
    `CA53_L2DB_TRNSFR_L2DB_RAM,
    `CA53_L2DB_TRNSFR_RAM_SLV,
    `CA53_L2DB_TRNSFR_RAM_SWAP,
    `CA53_L2DB_TRNSFR_RAM_L2DB:    reqbuf_l2db_primary_transfer_info = primary_ram_transfer_info;
    default:                       reqbuf_l2db_primary_transfer_info = {26{1'bx}};
  endcase

  assign reqbuf_l2db_primary_transfer_info_o = reqbuf_l2db_primary_transfer_info;

  assign reqbuf_l2db_primary_release_o = (((reqbuf_state == STATE_WAIT_AFB) &
                                           afb_done &
                                           reqbuf_write &
                                           (reqbuf_pass == PASS_WRITE_UNIQUE2) &
                                           ~afb_primary_write) |
                                          ((reqbuf_state == STATE_WAIT_L2DB) &
                                           primary_l2db_done &
                                           ((reqbuf_write & reqbuf_slverr) |
                                            reqbuf_read & (reqbuf_pass != PASS_READ_REORDER1))));

  assign next_reqbuf_l2db_victim_transfer = ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                             ~tagctl_ecc_err_tc3_i &
                                             (((reqbuf_victim_pass == PASS_VICTIM_WRITE) &
                                               reqbuf_l2_victim_valid & (reqbuf_l2_victim_dirty |
                                                                         ~next_reqbuf_l1_victim_hit)) |
                                              ((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                               tagctl_l2_victim_valid_tc3_i)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_victim_transfer <= 1'b0;
  end else if (reqbuf_en) begin
    reqbuf_l2db_victim_transfer <= next_reqbuf_l2db_victim_transfer;
  end

  assign reqbuf_l2db_victim_transfer_type = (reqbuf_victim_pass == PASS_VICTIM_READ) ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                                       `CA53_L2DB_TRNSFR_L2DB_MASTER;

  assign reqbuf_l2db_victim_transfer_type_o = reqbuf_l2db_victim_transfer_type;

  assign victim_opcode = ((reqbuf_l2_victim_dirty &  reqbuf_l1_victim_hit)      ? `CA53_DATA_OPCODE_WRITECLEAN :
                          (reqbuf_l2_victim_dirty & ~reqbuf_l1_victim_hit)      ? `CA53_DATA_OPCODE_WRITEBACK :
                          (reqbuf_l2_victim_cu    & acpslv_enable_writeevict_i) ? `CA53_DATA_OPCODE_EVICTDATA :
                                                                                  `CA53_DATA_OPCODE_EVICT);

  assign victim_master_transfer_info = {2'b00, reqbuf_l2_victim_cu, 2'b01, 1'b1, 1'b0, victim_opcode,
                                        victim_attrs, 2'b00,
                                        (ACE != 0) ? {REQBUF_ID[5:3], reqbuf_victim_afb} : REQBUF_ID[5:0]};

  assign victim_ram_transfer_info = {3'b000, reqbuf_l2_victim_way,
                                     reqbuf_addr2[16:6], 2'b00, REQBUF_ID[5:0]};

  assign reqbuf_l2db_victim_transfer_info_o = (reqbuf_victim_pass == PASS_VICTIM_READ) ? victim_ram_transfer_info :
                                                                                         victim_master_transfer_info;

  assign reqbuf_l2db_victim_release_o = (((reqbuf_victim_state == STATE_VICTIM_WAIT_AFB) &
                                          (reqbuf_victim_pass != PASS_VICTIM_INITIAL) & victim_afb_done &
                                          ~victim_require_l2db_after_afb) |
                                         ((reqbuf_victim_state == STATE_VICTIM_WAIT_L2DB) &
                                          (reqbuf_victim_pass == PASS_VICTIM_INITIAL) &
                                          victim_l2db_done &
                                          ~victim_require_tagctl_after_l2db) |
                                         ((reqbuf_victim_state == STATE_VICTIM_TC3) &
                                          (victim_require_idle_after_tc3 |
                                           ((reqbuf_victim_pass == PASS_VICTIM_WRITE) &
                                            next_reqbuf_l2_hit))));

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
  assign primary_l2db_done = |(l2dbs_slv_done & (11'b0000_0000_001 << primary_l2db)) & ~reqbuf_l2db_primary_transfer;
  assign victim_l2db_done  = |(l2dbs_slv_done & (11'b0000_0000_001 << victim_l2db)) & ~reqbuf_l2db_victim_transfer;

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
  //  Write responses
  //----------------------------------------------------------------------------

  assign reqbuf_db_valid_o = (reqbuf_state == STATE_RESP) & reqbuf_write;
  assign reqbuf_db_resp_o = reqbuf_slverr ? `CA53_ACE_RESP_SLVERR : ext_beats_resp;

  //----------------------------------------------------------------------------
  //  Read responses
  //----------------------------------------------------------------------------

  generate if (ACE) begin : g_ace_reorder

    always @*
      reqbuf_beats_reordered = zero;

    assign next_reqbuf_beats_reordered = 1'b0;

  end else begin : g_skyros_reorder

    assign next_reqbuf_beats_reordered = ((reqbuf_beats_reordered & ~reqbuf_alloc_i) |
                                          (reqbuf_read & reqbuf_len & reqbuf_suppress_dr));

    always @(posedge clk)
    if (reqbuf_en) begin
      reqbuf_beats_reordered <= next_reqbuf_beats_reordered;
    end

  end endgenerate

  assign reqbuf_suppress_skyros_dr_beats = ({4{reqbuf_write |
                                               (reqbuf_len & reqbuf_beats_reordered)}} |
                                            ~(4'b0001 << (reqbuf_len ? ext_beats_received[1:0] : reqbuf_addr1[5:4])));

  assign reqbuf_early_dr_ready = (ACE != 0) ? {4{reqbuf_write | (|ext_beats_received & ~reqbuf_len)}} :
                                              reqbuf_suppress_skyros_dr_beats;

  assign reqbuf_early_dr_ready_o = reqbuf_early_dr_ready;

  assign reqbuf_suppress_dr = ((reqbuf_state != STATE_IDLE) &
                               master_early_dr_valid_i &
                               ~master_early_dr_barrier_i &
                               early_dr_match &
                               |(reqbuf_early_dr_ready & (4'b0001 << master_early_dr_chunk_i)));

  assign reqbuf_suppress_dr_o = reqbuf_suppress_dr;

  // Count how many beats of read response have been received, so that we can
  // tell when we have seen all of them.
  assign receiving_ext_beat = ((master_acpslv_dr_valid_i & acpslv_master_dr_ready_i &
                                (master_dr_id_i == REQBUF_ID[5:0])) |
                               reqbuf_rsp_comp_valid);


  // Store when we have received an external beat. This must be done on the
  // early dr, so that it is accurate for hazarding snoops even if the dr
  // channel is stalled.
  // For reads with Skyros this tracks the next expected beat, if the beats
  // were to come back in order. This allows detection of when the beats start
  // arriving out of order, and then records the first beat that hasn't yet
  // been returned to ACP.
  assign next_ext_beats_received =  (reqbuf_alloc_i               ? 3'b000 :
                                     (((master_early_dr_valid_i &
                                        early_dr_match &
                                        (master_early_dr_ready_i |
                                         reqbuf_suppress_dr |
                                         (receiving_ext_beat &
                                          master_early_dr_same_i))) |
                                       reqbuf_rsp_comp_valid) &
                                      ~reqbuf_beats_reordered)    ? (ext_beats_received + 3'b001) :
                                                                    ext_beats_received);

  always @(posedge clk)
  if (reqbuf_en) begin
    ext_beats_received <= next_ext_beats_received;
  end

  // Record what reponse the external read got. If different beats get
  // different responses, then we take the 'strongest' of the responses. DECERR
  // takes priority over SLVERR, which takes priority over OKAY or EXOKAY. If
  // the access is an exclusive, then a failure (OKAY) takes priority over
  // success (EXOKAY), but for non-exclusives it is the other way round.

  assign master_ext_resp = reqbuf_rsp_comp_valid ? master_rsp_resp_i : master_dr_resp_i;

  assign ext_decerr = ((receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_DECERR)) |
                       (reqbuf_suppress_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_DECERR)));

  assign ext_slverr = ((receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_SLVERR)) |
                       (reqbuf_suppress_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_SLVERR)));

  assign ext_exokayerr = (((receiving_ext_beat & (master_ext_resp[1:0] == `CA53_ACE_RESP_EXOKAY)) |
                           (reqbuf_suppress_dr & (master_early_dr_resp_i[1:0] == `CA53_ACE_RESP_EXOKAY))) &
                          ~ext_beats_resp[1]);

  assign next_ext_beats_resp = (reqbuf_alloc_i ? `CA53_ACE_RESP_OKAY :
                                ext_decerr     ? `CA53_ACE_RESP_DECERR :
                                ext_slverr     ? {1'b1, &ext_beats_resp} :
                                ext_exokayerr  ? `CA53_ACE_RESP_EXOKAY :
                                                 ext_beats_resp);

  assign next_ext_beats_shared = (ext_beats_shared |
                                  (receiving_ext_beat & master_ext_resp[3]) |
                                  (reqbuf_suppress_dr & master_early_dr_resp_i[3])) & ~reqbuf_alloc_i;

  assign next_ext_beats_dirty = (ext_beats_dirty |
                                 (receiving_ext_beat & master_ext_resp[2]) |
                                 (reqbuf_suppress_dr & master_early_dr_resp_i[2])) & ~reqbuf_alloc_i;

  assign reqbuf_ext_en = reqbuf_alloc_i | receiving_ext_beat | reqbuf_suppress_dr;

  always @(posedge clk)
  if (reqbuf_ext_en) begin
    ext_beats_resp     <= next_ext_beats_resp;
    ext_beats_shared   <= next_ext_beats_shared;
    ext_beats_dirty    <= next_ext_beats_dirty;
  end

  assign reqbuf_ext_err_o = ((ext_beats_resp != `CA53_ACE_RESP_OKAY) &
                             ((reqbuf_write &
                               (((reqbuf_pass == PASS_WRITE_N_UNIQUE) &
                                 (reqbuf_state == STATE_WAIT_AFB) &
                                 afb_done) |
                                (((reqbuf_pass == PASS_WRITE_MISS) |
                                  (reqbuf_pass == PASS_WRITE_MISS_RETRY) |
                                  ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                   ~reqbuf_l1_hit & ~reqbuf_l2_hit &
                                   ~(`CA53_MEM_WBWA(reqbuf_attrs)) &
                                   ((ACE == 0) | ~reqbuf_shareable))) &
                                 (reqbuf_state == STATE_WAIT_L2DB) &
                                 primary_l2db_done))) |
                              (reqbuf_read &
                               (reqbuf_pass == PASS_READ_MISS) &
                               (ACE != 0) &
                               reqbuf_state_tc1 &
                               ~tagctl_slv_flush_tc1_i &
                               ext_beats_dirty)));

  assign reqbuf_write_len = ((reqbuf_l1_hit | reqbuf_l2_hit) ? (~reqbuf_cluster_unique &
                                                                ~reqbuf_l2db_full) :
                                                               (`CA53_MEM_WBWA(reqbuf_attrs) &
                                                                (~reqbuf_shareable |
                                                                 ~reqbuf_l2db_full))) ? 2'b11 : 2'b00;

  // The length of some requests on ACE is not the same as the beat of response that are returned.
  assign reqbuf_real_len = ((reqbuf_write &
                             (reqbuf_pass == PASS_WRITE_SERIALISE)) ? reqbuf_write_len : 
                            (reqbuf_write &
                             (reqbuf_pass == PASS_WRITE_HIT_RETRY)) ? 2'b00 :
                            (reqbuf_read &
                             reqbuf_read_alloc)                     ? 2'b11 :
                                                                      {2{reqbuf_len}});

  assign all_ext_beats_returned = (ext_beats_returned > {7'h00, reqbuf_real_len});

  // When returning a slverr, we must count the number of beats that have been returned.
  assign next_ext_beats_returned = (reqbuf_alloc_i            ? 9'b000000000 :
                                    (receiving_ext_beat &
                                     reqbuf_suppress_dr &
                                     ~master_early_dr_same_i) ? ({6'b000000, ext_beats_returned[2:0] + 3'b010}) :
                                                                (ext_beats_returned + 9'b000000001));

  assign reqbuf_ext_ret_en = reqbuf_alloc_i | ((reqbuf_state != STATE_IDLE) &
                                               (reqbuf_dr_ready_i |
                                                receiving_ext_beat |
                                                reqbuf_rsp_comp_valid |
                                                reqbuf_suppress_dr));

  always @(posedge clk)
  if (reqbuf_ext_ret_en) begin
    ext_beats_returned <= next_ext_beats_returned;
  end

  assign reqbuf_dr_last = (ext_beats_returned[7:0] == reqbuf_addr1[11:4]);
  assign reqbuf_dr_last_o = reqbuf_dr_last;

  assign reqbuf_dr_valid_o = (reqbuf_state == STATE_RESP) & reqbuf_read;

  //----------------------------------------------------------------------------
  //  Hazarding
  //----------------------------------------------------------------------------


  // The master sends details of what read data/response has just arrived.
  assign early_dr_match = (master_early_dr_id_i == REQBUF_ID[5:0]);

  // Return information to the master about whether and where this data should
  // be allocated into the L2 cache.
  assign reqbuf_early_dr_l2_o = (early_dr_match &
                                 reqbuf_read &
                                 reqbuf_read_alloc);
  assign reqbuf_early_dr_index_o = {11{early_dr_match}} & reqbuf_addr1[16:6];
  assign reqbuf_early_dr_way_o = {4{early_dr_match}} & reqbuf_l2_victim_way;

  // If the L2 RAMs have not been read for the eviction yet, then we must
  // prevent overwriting the data with the newly allocated data.
  assign reqbuf_delay_allocation = (reqbuf_read &
                                    reqbuf_read_alloc &
                                    (reqbuf_victim_state != STATE_VICTIM_IDLE) &
                                    ((reqbuf_victim_pass == PASS_VICTIM_INITIAL) |
                                     (reqbuf_victim_pass == PASS_VICTIM_READ)));

  assign reqbuf_delay_allocation_o = reqbuf_delay_allocation;

  // For coherent request types, snoops must be hazarded from the point this
  // request is serialised, until an external request is made. Once the last
  // beat is received (on ACE) we must start hazarding again, although we
  // actually start hazarding on the first beat for simplicity.
  assign next_hazard_snoops = ((reqbuf_alloc_i |
                                ((hazard_snoops |
                                  (|ext_beats_received & ~((ACE == 0) &
                                                           reqbuf_write &
                                                           ((reqbuf_pass == PASS_WRITE_N_UNIQUE) |
                                                            (reqbuf_pass == PASS_WRITE_UNIQUE1) |
                                                            (reqbuf_pass == PASS_WRITE_UNIQUE2)))) |
                                  (master_early_dr_valid_i & early_dr_match)))) &
                               ~(reqbuf_state_tc0 &
                                 reqbuf_write &
                                 (reqbuf_pass == PASS_WRITE_UNIQUE2)) &
                               ~(((reqbuf_state == STATE_WAIT_AFB) &
                                  ~|ext_beats_received &
                                  (((afb_done |
                                     ((reqbuf_victim_state != STATE_VICTIM_WAIT_AFB) &
                                      ~(reqbuf_l1_hit & ~l1_snoops_done))) &
                                    require_ext_after_afb) |
                                   ((reqbuf_write &
                                     (reqbuf_pass == PASS_WRITE_SERIALISE) &
                                     ((ACE != 0) | afb_done) &
                                     ((reqbuf_l1_hit | reqbuf_l2_hit) ? ~reqbuf_cluster_unique :
                                                                        (((ACE == 0) & ~(`CA53_MEM_WBWA(reqbuf_attrs) &
                                                                                         ~reqbuf_shareable &
                                                                                         reqbuf_l2db_full)) |
                                                                         reqbuf_shareable |
                                                                         (`CA53_MEM_WBWA(reqbuf_attrs) &
                                                                          ~reqbuf_l2db_full)))))))));

  assign reqbuf_l1_resp_en = afb_done & (reqbuf_state == STATE_WAIT_AFB) & (reqbuf_pass == PASS_READ_SERIALISE);

  assign next_l1_snoops_done = (l1_snoops_done | reqbuf_l1_resp_en) & ~reqbuf_alloc_i;

  always @(posedge clk)
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
                                           (reqbuf_victim_pass == PASS_VICTIM_WRITE) &
                                           victim_afb_done & victim_require_l2db_after_afb) |
                                          (reqbuf_write &
                                           (reqbuf_pass == PASS_WRITE_UNIQUE2) &
                                           (reqbuf_state == STATE_WAIT_AFB) &
                                           afb_done & require_l2db_after_afb)));

    always @(posedge clk)
    if (reqbuf_en) begin
      victim_hazard_snoops <= next_victim_hazard_snoops;
    end

  end endgenerate
  
  // TC1 address and index comparators. The compare the primary address of a
  // new request being serialised against this request.

  assign addr1_l1_index_hz_tc1 = ({acpslv_l1_dc_size_i & tagctl_addr_tc1_i[13:11], tagctl_addr_tc1_i[10:6]} ==
                                  {acpslv_l1_dc_size_i & reqbuf_addr1[13:11], reqbuf_addr1[10:6]});

  assign addr1_l2_index_hz_tc1 = ({acpslv_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {acpslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]});
  assign addr1_addr_hz_tc1     = (tagctl_addr_valid_tc1_i &
                                  (tagctl_addr_tc1_i[41:13] == {1'b0, reqbuf_addr1[40:13]}) &
                                  addr1_l2_index_hz_tc1);

  assign addr2_l2_index_hz_tc1 = ({acpslv_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {acpslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]});
  assign addr2_addr_hz_tc1     = (tagctl_addr_valid_tc1_i &
                                  (tagctl_addr_tc1_i[41:13] == {1'b0, reqbuf_addr2[40:13]}) &
                                  addr2_l2_index_hz_tc1);


  // TC3 address and index comparators. These compare the victim address of a
  // new request being serialised against this request.
  assign addr1_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                  ({acpslv_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                   {acpslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]}));
  assign addr1_addr_hz_tc3     = (tagctl_addr_tc3_i[40:13] == reqbuf_addr1[40:13]) & addr1_l2_index_hz_tc3;

  assign addr2_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                  ({acpslv_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                   {acpslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]}));
  assign addr2_addr_hz_tc3     = (tagctl_addr_tc3_i[40:13] == reqbuf_addr2[40:13]) & addr2_l2_index_hz_tc3;


  // This request buffer has been serialised, or will be serialised before the
  // request in tc1.
  assign reqbuf_serialised_tc1 = (~((reqbuf_state == STATE_IDLE) |
                                    (reqbuf_state == STATE_WAIT_VICTIM) |
                                    reqbuf_slverr |
                                    (reqbuf_write & (reqbuf_pass == PASS_WRITE_L2DB)) |
                                    (((reqbuf_state == STATE_TC0_TC1) |
                                      (((reqbuf_state == STATE_TC2) |
                                        (reqbuf_state == STATE_TC3) |
                                        (reqbuf_state == STATE_TC4)) &
                                       ~tagctl_serialising_tc1_i)) &
                                     (reqbuf_write ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                     (reqbuf_pass == PASS_READ_SERIALISE)))));

  // The victim address is serialised from TC4 on the serialisation pass until
  // either the victim state machine is complete, or the L1 victim has been
  // written into L2 and we are just waiting for the L2 victim.
  assign reqbuf_addr2_serialised = ((start_victim_no_flush |
                                     (reqbuf_victim_state != STATE_VICTIM_IDLE)) |
                                    (reqbuf_write &
                                     (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                       (((reqbuf_state == STATE_TC4) & ~acpslv_ecc_err_tc4_i) |
                                        (reqbuf_state == STATE_WAIT_AFB) |
                                        (reqbuf_state == STATE_WAIT_L2DB) |
                                        (reqbuf_state == STATE_RESP)) &
                                       ((reqbuf_l1_hit & ~reqbuf_l2db_full & reqbuf_cluster_unique) |
                                        (reqbuf_l2_hit & reqbuf_cluster_unique))) |
                                      ((reqbuf_pass == PASS_WRITE_N_UNIQUE) &
                                       ((reqbuf_state == STATE_TC4) |
                                        (reqbuf_state == STATE_WAIT_AFB) |
                                        (reqbuf_state == STATE_WAIT_L2DB) |
                                        (reqbuf_state == STATE_RESP))) |
                                      (((reqbuf_pass == PASS_WRITE_UNIQUE1) |
                                        (reqbuf_pass == PASS_WRITE_UNIQUE2)) &
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
                        ((reqbuf_serialised_tc1 &
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
  assign addr2_l2_way_unknown = (reqbuf_addr2_serialised &
                                 (((start_victim |
                                    (reqbuf_victim_state != STATE_VICTIM_IDLE)) &
                                   (reqbuf_victim_pass == PASS_VICTIM_INITIAL)) |
                                  ((reqbuf_victim_pass == PASS_VICTIM_READ) &
                                   ((reqbuf_victim_state == STATE_VICTIM_PICK_REQ) |
                                    (reqbuf_victim_state == STATE_VICTIM_PICK_ACK) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC0) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC0_TC1) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC2) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC3) |
                                    (reqbuf_victim_state == STATE_VICTIM_TC4)))));

  assign addr1_l2_way_unknown_tc1 = ((reqbuf_state != STATE_IDLE) &
                                     ((reqbuf_read &
                                       (reqbuf_pass == PASS_READ_SERIALISE) &
                                       ((reqbuf_state == STATE_TC2) |
                                        (reqbuf_state == STATE_TC3))) |
                                      (reqbuf_write &
                                       (((reqbuf_pass == PASS_WRITE_N_UNIQUE) &
                                         ((reqbuf_state == STATE_TC0_TC1) |
                                          (reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3))) |
                                        ((reqbuf_pass == PASS_WRITE_HIT_RETRY) &
                                         ((reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                          (reqbuf_state == STATE_PICK_VICTIM_ACK) |
                                          ~snoop_tc1)) |
                                        ((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                         ~(reqbuf_state == STATE_TC0_TC1) &
                                         ((reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3) |
                                          (reqbuf_state == STATE_PICK_VICTIM_REQ) |
                                          (reqbuf_state == STATE_PICK_VICTIM_ACK) |
                                          (~((reqbuf_l1_hit & ~reqbuf_l2db_full & reqbuf_cluster_unique) |
                                             (reqbuf_l2_hit & reqbuf_cluster_unique)) &
                                           ~snoop_tc1)))))));

  assign l2_index_hz_tc1 = ((tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                            tagctl_index_valid_tc1_i &
                            ((addr1_l2_way_unknown_tc1 & addr1_l2_index_hz_tc1) |
                             (addr2_l2_way_unknown     & addr2_l2_index_hz_tc1)));


  assign requestor_way_tc1 = {{4{tagctl_reqbufid_tc1_i[4:3] == 2'b11}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b10}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b01}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b00}}} & tagctl_ecc_way_tc1_i;

  // If there was a fatal ECC error on the duplicate tags then the normal
  // address hazarding may not catch an L1 eviction to the same index/way
  // as an existing request that is going to update the tag, so detect that
  // case here.
  assign l1_index_way_hz_tc1 = (reqbuf_addr1_serialised_tc3 &
                                tagctl_serialising_tc1_i &
                                tagctl_l1_lf_tc1_i &
                                addr1_l1_index_hz_tc1 &
                                |(reqbuf_hit_ways[15:0] & requestor_way_tc1) &
                                reqbuf_write);

  // Collate the hazarding hazarding information. It will then be combined with
  // the other reqbuf outputs and registered in the slv before sending back to
  // tagctl in tc2.
  assign reqbuf_hz_tc1_o = addr_hz_tc1 | l2_index_hz_tc1 | l1_index_way_hz_tc1;

  // Indicate that a way has an old value that has been evicted, but the
  // requestor has not updated the tag yet.
  assign reqbuf_force_miss_tc1_o = ({16{reqbuf_read &
                                        reqbuf_read_alloc &
                                        reqbuf_serialised_tc1 &
                                        (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) &
                                        ~((reqbuf_pass == PASS_READ_SERIALISE) &
                                          ((reqbuf_state == STATE_TC2) |
                                           (reqbuf_state == STATE_TC3) |
                                           ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i) |
                                           (reqbuf_state == STATE_RESP))) &
                                        ~(reqbuf_state == STATE_UPDATE_VICTIM) &
                                        ~(reqbuf_pass == PASS_READ_REORDER1) &
                                        ~(reqbuf_pass == PASS_READ_REORDER2) &
                                        ~(reqbuf_l1_hit | reqbuf_l2_hit) &
                                        tagctl_addr_valid_tc1_i &
                                        addr1_l2_index_hz_tc1}} &
                                    `CA53_L2_WAY_DEC(reqbuf_l2_victim_way));

  // Indicate that an L2 way is in use by this transaction, and so shouldn't
  // be picked as a victim way.
  // When in tc2 and tc3 we don't know which way hit, and so rely on the index
  // hazarding to prevent serialisation if we might hit a way being picked for
  // a victim.
  assign way_used_l2_hit_tc1 = (reqbuf_l2_hit &
                                reqbuf_serialised_tc1 &
                                ~((reqbuf_write ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                  (reqbuf_pass == PASS_READ_SERIALISE)) &
                                  ((reqbuf_state == STATE_TC2) |
                                   (reqbuf_state == STATE_TC3) |
                                   ((reqbuf_state == STATE_TC4) & acpslv_ecc_err_tc4_i))));

  assign way_used_l2_miss_tc1 = (((reqbuf_read &
                                   reqbuf_read_alloc &
                                   ~(reqbuf_l1_hit | reqbuf_l2_hit)) |
                                  reqbuf_write) &
                                 ~reqbuf_l2_hit &
                                 reqbuf_serialised_tc1 &
                                 ~(reqbuf_write & (reqbuf_pass == PASS_WRITE_UNIQUE2)) &
                                 ~((reqbuf_write ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                   (reqbuf_pass == PASS_READ_SERIALISE)) &
                                   ((reqbuf_state == STATE_TC2) |
                                    (reqbuf_state == STATE_TC3) |
                                    ((reqbuf_state == STATE_TC4) & acpslv_ecc_err_tc4_i))));

  assign way_used_victim_tc1 = (reqbuf_read &
                                (reqbuf_victim_state != STATE_VICTIM_IDLE) &
                                ((reqbuf_victim_pass == PASS_VICTIM_READ) |
                                 (reqbuf_victim_pass == PASS_VICTIM_WRITE)));

  assign way_used_valid_tc1 = (tagctl_reqbufid_tc1_i != REQBUF_ID[5:0]) & ~`CA53_REQBUF_IS_TAGECC(tagctl_reqbufid_tc1_i);

  assign reqbuf_l2_way_used_tc1_o = ({16{(way_used_valid_tc1 &
                                          way_used_l2_hit_tc1 &
                                          addr1_l2_index_hz_tc1) |
                                         (way_used_valid_tc1 &
                                          way_used_l2_miss_tc1 &
                                          addr1_l2_index_hz_tc1) |
                                         (way_used_valid_tc1 &
                                          way_used_victim_tc1 &
                                          addr2_l2_index_hz_tc1)}} &
                                     `CA53_L2_WAY_DEC(reqbuf_l2_victim_way));

  assign addr1_l2_index_hz_vc1 = ({acpslv_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                  {acpslv_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]});

  assign addr2_l2_index_hz_vc1 = ({acpslv_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                  {acpslv_l2_size_i & reqbuf_addr2[16:13], reqbuf_addr2[12:6]});

  assign reqbuf_l2_way_used_vc1_o = ({16{(way_used_l2_hit_tc1 &
                                          addr1_l2_index_hz_vc1) |
                                         (way_used_l2_miss_tc1 &
                                          addr1_l2_index_hz_vc1) |
                                         (way_used_victim_tc1 &
                                          addr2_l2_index_hz_vc1)}} &
                                     `CA53_L2_WAY_DEC(reqbuf_l2_victim_way));

  // This request buffer has been serialised, or will be serialised before the
  // request in tc3.
  assign reqbuf_addr1_serialised_tc3 = ~((reqbuf_state == STATE_IDLE) |
                                         (reqbuf_state == STATE_WAIT_VICTIM) |
                                         (reqbuf_state == STATE_TC3) |
                                         (((reqbuf_state == STATE_TC2) |
                                           (reqbuf_state == STATE_TC0_TC1)) &
                                          (reqbuf_write ? (reqbuf_pass == PASS_WRITE_SERIALISE) :
                                                          (reqbuf_pass == PASS_READ_SERIALISE))) |
                                         (reqbuf_write & (reqbuf_pass == PASS_WRITE_L2DB)));

  assign addr1_l2_way_unknown_tc3 = ((reqbuf_state != STATE_IDLE) &
                                     (reqbuf_write &
                                      (((reqbuf_pass == PASS_WRITE_SERIALISE) &
                                        ~((reqbuf_state == STATE_TC0_TC1) |
                                          (reqbuf_state == STATE_TC2) |
                                          (reqbuf_state == STATE_TC3))) |
                                       (reqbuf_pass == PASS_WRITE_N_UNIQUE) |
                                       (reqbuf_pass == PASS_WRITE_HIT_RETRY)) &
                                      ~snoop_tc3));

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

  // If a new request from ACP has the same ID as this one, then it must be
  // prevented from starting until this one is complete, to ensure ordering.
  assign reqbuf_id_hazard_o = ((reqbuf_state != STATE_IDLE) &
                               (acp_addr_id_i == reqbuf_acp_id) &
                               (acp_addr_read_i == reqbuf_read));

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A reqbuf may only be allocated when idle")
  u_ovl_alloc_idle (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_alloc_i),
    .consequent_expr (reqbuf_state == STATE_IDLE));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Valid ACP requests must not be system domain")
  u_ovl_sys_domain (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state != STATE_IDLE) & ~reqbuf_slverr),
    .consequent_expr (reqbuf_domain != 2'b11));

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

  wire ovl_reqbuf_victim_state_tc0 = ((reqbuf_victim_state == STATE_VICTIM_TC0) |
                                      ((reqbuf_victim_state == STATE_VICTIM_TC0_TC1) & ~reqbuf_arb_tc1_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl valid must match with the rebuf state")
  u_ovl_tagctl_valid (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_tagctl_valid_tc0),
    .consequent_expr (reqbuf_state_tc0 | ovl_reqbuf_victim_state_tc0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl valid must match with the rebuf state")
  u_ovl_tagctl_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (reqbuf_tagctl_req_tc0),
    .consequent_expr (reqbuf_state_tc0 | reqbuf_state_tc1 | ovl_reqbuf_victim_state_tc0 | reqbuf_victim_state_tc1));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a decerr, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_dec (.clk         (clk),
                            .reset_n     (reset_n),
                            .start_event ((reqbuf_state != STATE_IDLE) & (ext_beats_resp == `CA53_ACE_RESP_DECERR)),
                            .test_expr   ((reqbuf_state == STATE_IDLE) | (ext_beats_resp == `CA53_ACE_RESP_DECERR)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a slverr, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_slv (.clk         (clk),
                            .reset_n     (reset_n),
                            .start_event ((reqbuf_state != STATE_IDLE) & (ext_beats_resp == `CA53_ACE_RESP_SLVERR)),
                            .test_expr   ((reqbuf_state == STATE_IDLE) | ((ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                                                          (ext_beats_resp == `CA53_ACE_RESP_SLVERR))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once set to a exokay, ext_beats_resp must remain set until the reqbuf is idle")
  u_ovl_ext_beats_resp_exokay (.clk         (clk),
                               .reset_n     (reset_n),
                               .start_event ((reqbuf_state != STATE_IDLE) & (ext_beats_resp == `CA53_ACE_RESP_EXOKAY)),
                               .test_expr   ((reqbuf_state == STATE_IDLE) | ((ext_beats_resp == `CA53_ACE_RESP_DECERR) |
                                                                             (ext_beats_resp == `CA53_ACE_RESP_SLVERR) |
                                                                             (ext_beats_resp == `CA53_ACE_RESP_EXOKAY))));

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
                (reqbuf_state == STATE_TC0_TC1) |
                (reqbuf_state == STATE_TC2) |
                (reqbuf_state == STATE_TC3) |
                (reqbuf_state == STATE_TC4) |
                (reqbuf_state == STATE_WAIT_AFB) |
                (reqbuf_state == STATE_WAIT_L2DB) |
                (reqbuf_state == STATE_WAIT_EXT) |
                (reqbuf_state == STATE_WAIT_DATA) |
                (reqbuf_state == STATE_COMPACK) |
                (reqbuf_state == STATE_WAIT_VICTIM) |
                (reqbuf_state == STATE_RESP) |
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
                (reqbuf_victim_state == STATE_VICTIM_PICK_REQ) |
                (reqbuf_victim_state == STATE_VICTIM_PICK_ACK)));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "reqbuf_wait_data optimisation correct")
  u_ovl_reqbuf_wait_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (reqbuf_wait_data_o == (reqbuf_state == STATE_WAIT_DATA)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from wait ext")
  u_ovl_victim_idle_ext (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_WAIT_EXT) & (next_reqbuf_state == STATE_IDLE)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from compack")
  u_ovl_victim_idle_compack (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_COMPACK) & (next_reqbuf_state == STATE_IDLE)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));
  
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The victim state machine must be idle when completing from resp")
  u_ovl_victim_idle_resp (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((reqbuf_state == STATE_RESP) & (next_reqbuf_state == STATE_IDLE)),
    .consequent_expr (reqbuf_victim_state == STATE_VICTIM_IDLE));
  
  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_reqbuf_l2db_primary_transfer")
  u_ovl_x_next_reqbuf_l2db_primary_transfer (.clk       (clk),
                                             .reset_n   (reset_n),
                                             .qualifier (1'b1),
                                             .test_expr (next_reqbuf_l2db_primary_transfer));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_state_en_tc3")
  u_ovl_x_hit_state_en_tc3 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (hit_state_en_tc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hit_state_en_tc4")
  u_ovl_x_hit_state_en_tc4 (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (hit_state_en_tc4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l1_victim_hit_en")
  u_ovl_x_l1_victim_hit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l1_victim_hit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_victim_way_en")
  u_ovl_x_l2_victim_way_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l2_victim_way_en));

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

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_retry_received_en")
  u_ovl_x_reqbuf_retry_received_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (reqbuf_retry_received_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_shareability_en")
  u_ovl_x_reqbuf_shareability_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (reqbuf_shareability_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: update_reqbuf_pass")
  u_ovl_x_update_reqbuf_pass (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (update_reqbuf_pass));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_l2db_full_en")
  u_ovl_x_reqbuf_l2db_full_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (reqbuf_l2db_full_en));

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

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_victim_hit_en")
  u_ovl_x_l2_victim_hit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (l2_victim_hit_en));


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
