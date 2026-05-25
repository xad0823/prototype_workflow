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
//  The reqbuf holds and controls each request from the external snoop channel.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"


module ca53scu_reqbuf_snp #(`CA53_SCU_INT_PARAM_DECL, parameter NUM_REQBUFS = 1, parameter REQBUF_ID = 6'b000000)
 (
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire [2:0]             config_l1_dc_size_i,
  input  wire [3:0]             config_l2_size_i,

  // AC channel interface
  output wire                   reqbuf_busy_o,
  output wire                   next_reqbuf_ready_o,
  output wire                   reqbuf_dvm_part_two_o,
  input  wire                   reqbuf_early_alloc_i,
  input  wire                   reqbuf_alloc_i,
  input  wire                   reqbuf_second_dvm_i,
  input  wire [3:0]             ac_snoop_i,
  input  wire [41:0]            ac_addr_int_i,
  input  wire                   dvm_part_i,
  input  wire [6:0]             ac_srcid_i,
  input  wire [7:0]             ac_txnid_i,
  input  wire [3:0]             ac_qos_i,

  // CR channel interface
  output wire                   reqbuf_cr_valid_o,
  output wire                   reqbuf_cr_active_o,
  output wire                   reqbuf_cr_cancel_o,
  input  wire                   reqbuf_cr_ready_i,
  output wire [4:0]             reqbuf_cr_resp_o,
  output wire [6:0]             reqbuf_tgtid_o,
  output wire [7:0]             reqbuf_txnid_o,
  output wire [3:0]             reqbuf_qos_o,
  output wire                   reqbuf_cr_unsent_o,
  input  wire [NUM_REQBUFS-1:0] reqbufs_cr_unsent_i,

  // Hazarding
  input  wire [41:6]            tagctl_addr_tc1_i,
  input  wire                   tagctl_addr_valid_tc1_i,
  input  wire                   tagctl_serialising_tc1_i,
  input  wire                   tagctl_l1_lf_tc1_i,
  input  wire [15:0]            tagctl_ecc_way_tc1_i,
  input  wire [5:0]             tagctl_reqbufid_tc1_i,
  input  wire                   tagctl_snp_sync_tc1_i,
  input  wire                   tagctl_cpu_sync_tc1_i,
  input  wire [10:0]            victimctl_index_vc1_i,
  output wire                   reqbuf_hz_tc1_o,
  output wire                   reqbuf_ecc_hz_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_vc1_o,
  input  wire [40:6]            tagctl_addr_tc3_i,
  input  wire                   tagctl_addr_valid_tc3_i,
  output wire                   reqbuf_hz_tc3_o,
  input  wire [NUM_REQBUFS-1:0] reqbufs_older_i,

  // Tagctl requests
  output wire                   reqbuf_tagctl_valid_tc0_o,
  output wire                   reqbuf_tagctl_prearb_req_o,
  output wire                   reqbuf_update_pass_o,
  output wire [3:0]             reqbuf_tagctl_pass_tc0_o,
  output wire [41:0]            reqbuf_tagctl_addr1_tc0_o,
  output wire [16:0]            reqbuf_tagctl_wr_state_tc0_o,
  output wire [31:0]            reqbuf_tagctl_ways_tc0_o,
  output wire [4:0]             reqbuf_tagctl_write_tc0_o,
  input  wire                   reqbuf_tagctl_prearb_tc0_i,
  input  wire                   reqbuf_arb_tc1_i,
  output wire [4:0]             reqbuf_type_o,
  output wire [7:0]             reqbuf_attrs_o,
  output wire [40:0]            reqbuf_addr2_o,
  output wire                   reqbuf_dirty_o,

  input  wire                   tagctl_slv_flush_tc1_i,
  input  wire                   tagctl_slv_flush_tc2_i,
  input  wire                   tagctl_slv_flush_tc3_i,
  input  wire                   tagctl_slv_flush_tc4_i,
  input  wire [2:0]             tagctl_slv_afb_tc1_i,
  input  wire                   tagctl_slv_l2db_hit_tc3_i,
  input  wire                   tagctl_slv_l2db_dirty_tc3_i,
  input  wire                   tagctl_slv_l2db_cu_tc3_i,
  input  wire [3:0]             tagctl_slv_l2db_tc3_i,
  input  wire [15:0]            tagctl_l1_hit_ways_tc3_i,
  input  wire [15:0]            tagctl_l2_hit_ways_tc3_i,
  input  wire                   tagctl_l2_dirty_tc3_i,
  input  wire                   tagctl_l2_alloc_tc3_i,
  input  wire [1:0]             tagctl_shareability_tc3_i,
  input  wire                   tagctl_cluster_unique_tc3_i,
  input  wire [1:0]             tagctl_snoop_data_cpu_tc4_i,
  input  wire                   afb0_done_i,
  input  wire                   afb1_done_i,
  input  wire                   afb2_done_i,
  input  wire                   afb3_done_i,
  input  wire                   afb4_done_i,
  input  wire                   afb5_done_i,
  input  wire                   afb0_snoop_resp_dirty_i,
  input  wire                   afb1_snoop_resp_dirty_i,
  input  wire                   afb2_snoop_resp_dirty_i,
  input  wire                   afb3_snoop_resp_dirty_i,
  input  wire                   afb4_snoop_resp_dirty_i,
  input  wire                   afb5_snoop_resp_dirty_i,

  // L2DB control
  output wire                   reqbuf_l2db_invalidate_o,
  output wire                   reqbuf_l2db_makeshared_o,
  output wire                   reqbuf_l2db_transfer_o,
  output wire [3:0]             reqbuf_l2db_id_o,
  output wire [2:0]             reqbuf_l2db_transfer_type_o,
  output wire [28:0]            reqbuf_l2db_transfer_info_o,
  output wire                   reqbuf_l2db_release_o,

  input  wire                   l2db0_snpslv_done_i,
  input  wire                   l2db1_snpslv_done_i,
  input  wire                   l2db2_snpslv_done_i,
  input  wire                   l2db3_snpslv_done_i,
  input  wire                   l2db4_snpslv_done_i,
  input  wire                   l2db5_snpslv_done_i,
  input  wire                   l2db6_snpslv_done_i,
  input  wire                   l2db7_snpslv_done_i,
  input  wire                   l2db8_snpslv_done_i,
  input  wire                   l2db9_snpslv_done_i,
  input  wire                   l2db10_snpslv_done_i,

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

  input  wire                   l2db0_slv_master_arb_i,
  input  wire                   l2db1_slv_master_arb_i,
  input  wire                   l2db2_slv_master_arb_i,
  input  wire                   l2db3_slv_master_arb_i,
  input  wire                   l2db4_slv_master_arb_i,
  input  wire                   l2db5_slv_master_arb_i,
  input  wire                   l2db6_slv_master_arb_i,
  input  wire                   l2db7_slv_master_arb_i,
  input  wire                   l2db8_slv_master_arb_i,
  input  wire                   l2db9_slv_master_arb_i,
  input  wire                   l2db10_slv_master_arb_i,

  input  wire                   ramctl_l2dbs_valid_i,
  input  wire [3:0]             ramctl_l2dbs_id_i,
  input  wire                   ramctl_l2dbs_last_i,
  input  wire                   ramctl_bypassed_err_i,

  output wire                   reqbuf_wait_sync_o,
  input  wire [NUM_REQBUFS-1:0] reqbufs_wait_sync_i,

  input  wire                   sync_bar_completed_i,

  output wire                   reqbuf_cd_unsent_o,
  input  wire [NUM_REQBUFS-1:0] reqbufs_cd_unsent_i,

  output wire                   reqbuf_snp_cd_l2db_o,

  output wire                   reqbuf_credit_return_o,
  input  wire                   reqbuf_credit_ready_i,

  output wire                   reqbuf_ramctl_active_o,
  output wire                   reqbuf_master_active_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE           = 4'b0000;
  localparam STATE_DVM1           = 4'b0001;
  localparam STATE_DVM2           = 4'b0010;
  localparam STATE_TC0_TC1        = 4'b0011;
  localparam STATE_TC2            = 4'b0100;
  localparam STATE_TC3            = 4'b0101;
  localparam STATE_TC4            = 4'b0110;
  localparam STATE_WAIT_AFB       = 4'b0111;
  localparam STATE_WAIT_L2DB      = 4'b1000;
  localparam STATE_WAIT_L2DB_ARB  = 4'b1001;
  localparam STATE_WAIT_CD        = 4'b1010;
  localparam STATE_WAIT_SYNC      = 4'b1011;
  localparam STATE_RESP           = 4'b1100;
  localparam STATE_RESP2          = 4'b1101;
  localparam STATE_CREDIT_RETURN  = 4'b1111;
  localparam STATE_X              = 4'bxxxx;

  localparam PASS_SERIALISE = 1'b0;
  localparam PASS_UPDATE    = 1'b1;

  reg [3:0]            reqbuf_state;
  reg                  reqbuf_pass;
  reg [3:0]            reqbuf_l2db_id;
  reg                  reqbuf_l2db_hit;
  reg                  reqbuf_l2db_dirty;
  reg [3:0]            reqbuf_type;
  reg [6:0]            reqbuf_srcid;
  reg [7:0]            reqbuf_txnid;
  reg [3:0]            reqbuf_qos;
  reg [41:0]           reqbuf_addr1;
  reg [40:0]           reqbuf_addr2;
  reg [2:0]            reqbuf_afb;
  reg                  reqbuf_l2_hit;
  reg [3:0]            reqbuf_l2_hit_way;
  reg                  reqbuf_l2_dirty;
  reg                  reqbuf_l2_alloc;
  reg [3:0]            reqbuf_l1_hit_cpus;
  reg [7:0]            reqbuf_l1_hit_ways;
  reg                  reqbuf_cluster_unique;
  reg [1:0]            reqbuf_snoop_data_cpu;
  reg                  reqbuf_l1_dirty;
  reg [1:0]            reqbuf_shareability;
  reg                  reqbuf_l2db_transfer;

  reg [3:0]            next_reqbuf_state;
  wire                 reqbuf_en;
  wire                 update_reqbuf_pass;
  wire                 next_reqbuf_pass;
  wire                 require_tagctl_after_l2db;
  wire                 require_resp_after_l2db;
  wire                 require_l2db_after_l2db;
  wire                 require_l2db_after_afb;
  wire                 require_sync_after_afb;
  wire                 require_l2db_wr_after_afb;
  wire                 require_resp_after_tagctl;
  wire                 require_tc3_after_tc2;
  wire                 require_l2db_after_resp;
  wire                 require_resp_after_resp;
  wire                 require_tagctl_after_resp;
  wire                 reqbuf_addr1_en;
  wire                 reqbuf_addr2_en;
  wire                 next_reqbuf_l2_hit;
  wire [3:0]           next_reqbuf_l2_hit_way;
  wire [3:0]           next_reqbuf_l1_hit_cpus;
  wire [7:0]           next_reqbuf_l1_hit_ways;
  wire                 next_reqbuf_l1_dirty;
  wire                 reqbuf_l1_resp_en;
  wire                 initial_hit_en;
  wire                 initial_hit_tc4_en;
  wire                 next_reqbuf_cluster_unique;
  wire                 afb_done;
  wire [2:0]           next_reqbuf_afb;
  wire [MAX_L2DBS-1:0] l2dbs_slv_done;
  wire [MAX_L2DBS-1:0] l2dbs_slv_master_arb;
  wire [MAX_L2DBS-1:0] reqbuf_l2db_id_onehot;
  wire                 addr1_l1_index_hz_tc1;
  wire                 addr_l2_index_hz_tc1;
  wire                 addr_l2_index_hz_tc3;
  wire [15:0]          requestor_way_tc1;
  wire                 l1_index_way_hz_tc1;
  wire                 l2_index_hz_tc1;
  wire                 l2_index_hz_tc3;
  wire                 hz_comp_tc1;
  wire                 hz_comp_tc3;
  wire                 reqbuf_hz_addr;
  wire                 reqbuf_serialised_tc1;
  wire                 reqbuf_serialised_tc3;
  wire                 reqbuf_older_than_tc1;
  wire                 order_hz_tc1;
  wire                 sync_hz_tc1;
  wire [15:0]          reqbuf_l2_way_used;
  wire [3:0]           tagctl_l1_hit_ways_tc3_0;
  wire [3:0]           tagctl_l1_hit_ways_tc3_1;
  wire [3:0]           tagctl_l1_hit_ways_tc3_2;
  wire [3:0]           tagctl_l1_hit_ways_tc3_3;
  wire                 invalidating_snoop;
  wire [2:0]           tag_state_l1_tc0;
  wire [4:0]           tag_state_l2_tc0;
  wire [1:0]           reqbuf_l1_hit_ways_0;
  wire [1:0]           reqbuf_l1_hit_ways_1;
  wire [1:0]           reqbuf_l1_hit_ways_2;
  wire [1:0]           reqbuf_l1_hit_ways_3;
  wire [31:0]          reqbuf_hit_ways;
  wire                 reqbuf_state_tc0;
  wire                 reqbuf_state_tc1;
  wire [28:0]          slv_transfer_info;
  wire [28:0]          master_transfer_info;
  wire [28:0]          ram_transfer_info;
  wire                 l2db_done;
  wire                 l2db_early_done;
  wire                 l2db_err;
  wire                 l2db_master_arb;
  wire                 reqbuf_l1_hit;
  wire                 next_reqbuf_l2db_transfer;
  wire                 cr_datatransfer;
  wire                 cr_err;
  wire                 cr_dirty;
  wire                 cr_passdirty;
  wire                 cr_isshared;
  wire                 cr_wasunique;
  reg [2:0]            snp_resp;
  wire [1:0]           snp_resperr;
  wire                 delay_cd_data;
  wire                 zero;


  // Tie off for configurable logic.
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  //  State machine
  //----------------------------------------------------------------------------

  always @*
  begin
    next_reqbuf_state = reqbuf_state;
    case (reqbuf_state)
      STATE_IDLE: begin
        if (reqbuf_alloc_i) begin
          if (ac_snoop_i == `CA53_ACE_DVM_MESSAGE) begin
            if (ACE) begin
              if (ac_addr_int_i[0]) begin
                // For ACE, we always receive the first part of a 2 part DVM before the second part.
                next_reqbuf_state = STATE_DVM1;
              end else begin
                next_reqbuf_state = STATE_TC0_TC1;
              end
            end else begin
              // For Skyros, all DVMs are 2 part, but the parts may arrive in either order.
              if (dvm_part_i) begin
                next_reqbuf_state = STATE_DVM2;
              end else begin
                next_reqbuf_state = STATE_DVM1;
              end
            end
          end else if (ac_snoop_i == `CA53_ACE_DVM_COMPLETE) begin
            next_reqbuf_state = STATE_RESP;
          end else begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end
      end
      STATE_DVM1,
      STATE_DVM2: begin
        if (reqbuf_second_dvm_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end
      end
      STATE_TC0_TC1: begin
        // This is either the TC0 state or the TC1 state, depending on whether
        // this reqbuf got arbitrated in the previous cycle.
        if (reqbuf_arb_tc1_i) begin
          if (tagctl_slv_flush_tc1_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_TC2;
          end
        end
      end
      STATE_TC2: begin
        if (tagctl_slv_flush_tc2_i) begin
          next_reqbuf_state = STATE_TC0_TC1;
        end else if (require_tc3_after_tc2) begin
          // These operations must wait until tc2 to ensure any other access
          // that started a tag read before this write will still detect an
          // address hazard when it is in tc3.
          next_reqbuf_state = STATE_TC3;
        end else if (ACE) begin
          next_reqbuf_state = STATE_IDLE;
        end else begin
          next_reqbuf_state = STATE_CREDIT_RETURN;
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
        end else if (require_resp_after_tagctl) begin
          if (reqbuf_cr_ready_i) begin
            if (ACE) begin
              next_reqbuf_state = STATE_IDLE;
            end else begin
              next_reqbuf_state = STATE_CREDIT_RETURN;
            end
          end else begin
            next_reqbuf_state = STATE_RESP;
          end
        end else begin
          next_reqbuf_state = STATE_WAIT_AFB;
        end
      end
      STATE_WAIT_AFB: begin
        if (afb_done) begin
          if (require_l2db_after_afb) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else if (require_sync_after_afb) begin
            next_reqbuf_state = STATE_WAIT_SYNC;
          end else begin
            next_reqbuf_state = STATE_RESP;
          end
        end
      end
      STATE_WAIT_CD: begin
        // Wait for other reqbufs to send their data on the CD channel before
        // this one can.
        if (~delay_cd_data) begin
          next_reqbuf_state = STATE_WAIT_L2DB_ARB;
        end
      end
      STATE_WAIT_L2DB_ARB: begin
        // Wait for this reqbuf's L2DB to get arbitrated for access to the master.
        if (~l2db_master_arb) begin
          next_reqbuf_state = STATE_WAIT_L2DB;
        end
      end
      STATE_WAIT_L2DB: begin
        if (l2db_early_done) begin
          if (require_tagctl_after_l2db) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (require_resp_after_l2db) begin
            next_reqbuf_state = STATE_RESP;
          end else if (require_l2db_after_l2db) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else if (ACE) begin
            next_reqbuf_state = STATE_IDLE;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_WAIT_SYNC: begin
        if (sync_bar_completed_i & ~|(reqbufs_older_i & reqbufs_wait_sync_i)) begin
          next_reqbuf_state = STATE_RESP;
        end
      end
      STATE_RESP: begin
        if (reqbuf_cr_ready_i) begin
          if (require_resp_after_resp) begin
            next_reqbuf_state = STATE_RESP2;
          end else if (require_l2db_after_resp) begin
            if (delay_cd_data) begin
              next_reqbuf_state = STATE_WAIT_CD;
            end else begin
              next_reqbuf_state = STATE_WAIT_L2DB_ARB;
            end
          end else if (require_tagctl_after_resp) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if (ACE) begin
            next_reqbuf_state = STATE_IDLE;
          end else begin
            next_reqbuf_state = STATE_CREDIT_RETURN;
          end
        end
      end
      STATE_RESP2: begin
        // Two part ACE DVM messages require two responses.
        if (reqbuf_cr_ready_i) begin
          next_reqbuf_state = STATE_IDLE;
        end
      end
      STATE_CREDIT_RETURN: begin
        if (reqbuf_credit_ready_i) begin
          next_reqbuf_state = STATE_IDLE;
        end
      end
      default: next_reqbuf_state = STATE_X;
    endcase
  end

  // Decode some states that are more than just the state variable.
  assign reqbuf_state_tc0 = (reqbuf_state == STATE_TC0_TC1) & ~reqbuf_arb_tc1_i;

  assign reqbuf_state_tc1 = (reqbuf_state == STATE_TC0_TC1) & reqbuf_arb_tc1_i;

  assign reqbuf_credit_return_o = (reqbuf_state == STATE_CREDIT_RETURN);

  assign reqbuf_wait_sync_o = (reqbuf_state == STATE_WAIT_SYNC);

  // Enable various state only when active.
  assign reqbuf_en = reqbuf_alloc_i | (reqbuf_state != STATE_IDLE);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_state <= STATE_IDLE;
  end else if (reqbuf_en) begin
    reqbuf_state <= next_reqbuf_state;
  end

  // Indicate if this request buffer will be ready to accept a new request in the following cycle.
  assign next_reqbuf_ready_o = ((ACE != 0) &
                                (((reqbuf_state == STATE_TC2) & (~tagctl_slv_flush_tc2_i &
                                                                 ~require_tc3_after_tc2)) |
                                 ((reqbuf_state == STATE_TC4) & (~tagctl_slv_flush_tc4_i &
                                                                 require_resp_after_tagctl &
                                                                 reqbuf_cr_ready_i)) |
                                 ((reqbuf_state == STATE_WAIT_L2DB) & (l2db_done &
                                                                       ~require_tagctl_after_l2db &
                                                                       ~require_resp_after_l2db &
                                                                       ~require_l2db_after_l2db)) |
                                 ((reqbuf_state == STATE_RESP) & (reqbuf_cr_ready_i &
                                                                  ~require_resp_after_resp &
                                                                  ~require_l2db_after_resp &
                                                                  ~require_tagctl_after_resp)) |
                                 ((reqbuf_state == STATE_RESP2) & reqbuf_cr_ready_i)));


  // State machine control logic.
  assign require_tagctl_after_l2db = ((reqbuf_pass == PASS_UPDATE) &
                                      (reqbuf_l1_hit | reqbuf_l2_hit) &
                                      ((reqbuf_type == `CA53_ACE_MAKEINVALID) |
                                       (reqbuf_type == `CA53_ACE_READUNIQUE) |
                                       (reqbuf_type == `CA53_ACE_CLEANINVALID) |
                                       (reqbuf_type == `CA53_ACE_READSHARED) |
                                       (reqbuf_type == `CA53_ACE_READCLEAN) |
                                       (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                       (reqbuf_type == `CA53_ACE_CLEANSHARED)));

  assign require_resp_after_l2db = ((reqbuf_pass == PASS_SERIALISE) &
                                    ((ACE != 0) | 
                                     (((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                       (reqbuf_type == `CA53_ACE_CLEANINVALID)) &
                                      ~cr_dirty)));

  assign require_l2db_after_l2db = ((reqbuf_pass == PASS_SERIALISE) &
                                    (ACE == 0) &
                                    ~(((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                       (reqbuf_type == `CA53_ACE_CLEANINVALID)) &
                                      ~cr_dirty));

  assign require_tagctl_after_resp = ((reqbuf_l1_hit | reqbuf_l2_hit) &
                                      ~((reqbuf_type == `CA53_ACE_DVM_COMPLETE) |
                                        (reqbuf_type == `CA53_ACE_DVM_MESSAGE)));

  assign require_l2db_after_resp = cr_datatransfer;

  assign require_resp_after_resp = (ACE != 0) & (reqbuf_type == `CA53_ACE_DVM_MESSAGE) & reqbuf_addr2[0];

  assign require_l2db_wr_after_afb = ((ACE == 0) & reqbuf_l2db_hit &
                                      ((reqbuf_type == `CA53_ACE_READONCE) |
                                       (reqbuf_type == `CA53_ACE_READSHARED) |
                                       (reqbuf_type == `CA53_ACE_READCLEAN) |
                                       (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                       (reqbuf_type == `CA53_ACE_READUNIQUE) |
                                       ((reqbuf_l2db_dirty |
                                         (reqbuf_l1_hit & next_reqbuf_l1_dirty) |
                                         (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                                        ((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                         (reqbuf_type == `CA53_ACE_CLEANINVALID)))));
  
  assign require_l2db_after_afb = ((((((reqbuf_type == `CA53_ACE_READONCE) |
                                       (reqbuf_type == `CA53_ACE_READSHARED) |
                                       (reqbuf_type == `CA53_ACE_READCLEAN) |
                                       (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                       (reqbuf_type == `CA53_ACE_READUNIQUE)) &
                                      (reqbuf_l1_hit | reqbuf_l2_hit)) |
                                    (((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                      (reqbuf_type == `CA53_ACE_CLEANINVALID)) &
                                     (reqbuf_l1_hit |
                                      (reqbuf_l2_hit & reqbuf_l2_dirty)))) &
                                    ~reqbuf_l2db_hit) |
                                   require_l2db_wr_after_afb);

  assign require_sync_after_afb = (ACE == 0) & (reqbuf_type == `CA53_ACE_DVM_MESSAGE) & (reqbuf_addr2[14:12] == `CA53_ACE_DVM_SYNC);

  assign require_resp_after_tagctl = (~(reqbuf_l1_hit | reqbuf_l2_hit | reqbuf_l2db_hit) &
                                      ~((reqbuf_type == `CA53_ACE_DVM_COMPLETE) |
                                        (reqbuf_type == `CA53_ACE_DVM_MESSAGE)));

  assign require_tc3_after_tc2 = (reqbuf_pass == PASS_SERIALISE);

  assign reqbuf_busy_o = (reqbuf_state != STATE_IDLE);

  // Keep track of what stage the request is at, and therefore what it needs
  // to do the next time it goes down tagctl.
  assign update_reqbuf_pass = (((reqbuf_state == STATE_RESP) & reqbuf_cr_ready_i & ~require_resp_after_resp) |
                               ((reqbuf_state == STATE_WAIT_L2DB) & l2db_done & require_l2db_after_l2db) |
                               ((reqbuf_state == STATE_WAIT_AFB) & afb_done & require_l2db_wr_after_afb));

  assign reqbuf_update_pass_o = update_reqbuf_pass | reqbuf_early_alloc_i;

  assign next_reqbuf_pass = ((reqbuf_state == STATE_IDLE) ? PASS_SERIALISE :
                             update_reqbuf_pass ? PASS_UPDATE :
                             reqbuf_pass);

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_pass <= next_reqbuf_pass;
  end


  //----------------------------------------------------------------------------
  //  Request storage
  //----------------------------------------------------------------------------

  always @(posedge clk)
  if (reqbuf_alloc_i) begin
    reqbuf_type <= ac_snoop_i;
  end

  generate if (ACE) begin : g_ace

    always @*
    begin
      reqbuf_srcid = {7{zero}};
      reqbuf_txnid = {8{zero}};
      reqbuf_qos   = {4{zero}};
    end

    assign reqbuf_tgtid_o = {7{1'b0}};
    assign reqbuf_txnid_o = {8{1'b0}};
    assign reqbuf_qos_o   = {4{1'b0}};

    assign reqbuf_dvm_part_two_o = (reqbuf_state == STATE_DVM1);

  end else begin : g_skyros

    always @(posedge clk)
    if (reqbuf_alloc_i) begin
      reqbuf_srcid <= ac_srcid_i;
      reqbuf_txnid <= ac_txnid_i;
      reqbuf_qos   <= ac_qos_i;
    end

    assign reqbuf_tgtid_o = reqbuf_srcid;
    assign reqbuf_txnid_o = reqbuf_txnid;
    assign reqbuf_qos_o   = reqbuf_qos;

    assign reqbuf_dvm_part_two_o = (((reqbuf_state == STATE_DVM1) |
                                     (reqbuf_state == STATE_DVM2)) &
                                    (reqbuf_srcid == ac_srcid_i) &
                                    (reqbuf_txnid == ac_txnid_i));

  end endgenerate

  assign reqbuf_type_o  = {1'b0, reqbuf_type};

  // We don't know the exact attributes for snoops, however only the
  // shareability matters and we assume that is outer shareable.
  assign reqbuf_attrs_o = 8'h02;

  // The first address holds the snoop address, or the second part of a two part
  // DVM message (the order is swapped to match the CPU rebufs).
  assign reqbuf_addr1_en = ((reqbuf_alloc_i & ~(((ac_snoop_i == `CA53_ACE_DVM_MESSAGE) |
                                                 (ac_snoop_i == `CA53_ACE_DVM_COMPLETE)) & ~dvm_part_i)) |
                            (reqbuf_second_dvm_i & (reqbuf_state == STATE_DVM1)));

  always @(posedge clk)
  if (reqbuf_addr1_en) begin
    reqbuf_addr1 <= ac_addr_int_i;
  end

  // The second address holds the first part of a two part DVM message.
  assign reqbuf_addr2_en = ((reqbuf_alloc_i & ((ac_snoop_i == `CA53_ACE_DVM_MESSAGE) |
                                               (ac_snoop_i == `CA53_ACE_DVM_COMPLETE)) & ~dvm_part_i) |
                            (reqbuf_second_dvm_i & (reqbuf_state == STATE_DVM2)));

  always @(posedge clk)
  if (reqbuf_addr2_en) begin
    reqbuf_addr2 <= ac_addr_int_i[40:0];
  end

  assign reqbuf_addr2_o = {((reqbuf_type == `CA53_ACE_DVM_MESSAGE) &
                            (ACE == 0)) ? reqbuf_addr1[41] : reqbuf_addr2[40],
                           reqbuf_addr2[39:0]};

  // Encode and store where in L1 and L2 the request hit.
  assign next_reqbuf_l2_hit = |tagctl_l2_hit_ways_tc3_i;

  assign next_reqbuf_l2_hit_way = `CA53_L2_WAY_ENC(tagctl_l2_hit_ways_tc3_i);

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

  assign initial_hit_en = (reqbuf_state == STATE_TC3) & (reqbuf_pass == PASS_SERIALISE);

  assign next_reqbuf_cluster_unique = tagctl_cluster_unique_tc3_i | (tagctl_slv_l2db_hit_tc3_i & tagctl_slv_l2db_cu_tc3_i);

  always @(posedge clk)
  if (initial_hit_en) begin
    reqbuf_l1_hit_cpus     <= next_reqbuf_l1_hit_cpus;
    reqbuf_l1_hit_ways     <= next_reqbuf_l1_hit_ways;
    reqbuf_shareability    <= tagctl_shareability_tc3_i;
    reqbuf_cluster_unique  <= next_reqbuf_cluster_unique;
  end

  generate if (L2_CACHE) begin : g_l2cc

    always @(posedge clk)
    if (initial_hit_en) begin
      reqbuf_l2_hit     <= next_reqbuf_l2_hit;
      reqbuf_l2_hit_way <= next_reqbuf_l2_hit_way;
      reqbuf_l2_dirty   <= tagctl_l2_dirty_tc3_i;
      reqbuf_l2_alloc   <= tagctl_l2_alloc_tc3_i;
    end

  end else begin : g_n_l2cc

    always @*
    begin
      reqbuf_l2_hit     = zero;
      reqbuf_l2_hit_way = {4{zero}};
      reqbuf_l2_dirty   = zero;
      reqbuf_l2_alloc   = zero;
    end

  end endgenerate

  assign initial_hit_tc4_en = (reqbuf_state == STATE_TC4) & (reqbuf_pass == PASS_SERIALISE);

  always @(posedge clk)
  if (initial_hit_tc4_en) begin
    reqbuf_snoop_data_cpu <= tagctl_snoop_data_cpu_tc4_i;
  end

  assign reqbuf_l1_hit = |reqbuf_l1_hit_cpus;

  // Store the responses from primary and victim snoops.

  assign next_reqbuf_l1_dirty = (((reqbuf_afb == 3'b000) & afb0_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b001) & afb1_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b010) & afb2_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b011) & afb3_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b100) & afb4_snoop_resp_dirty_i) |
                                 ((reqbuf_afb == 3'b101) & afb5_snoop_resp_dirty_i));

  assign reqbuf_l1_resp_en = afb_done & (reqbuf_state == STATE_WAIT_AFB);

  always @(posedge clk)
  if (reqbuf_l1_resp_en) begin
    reqbuf_l1_dirty <= next_reqbuf_l1_dirty;
  end

  assign reqbuf_dirty_o = reqbuf_l2_dirty;


  //----------------------------------------------------------------------------
  //  Tagctl requests
  //----------------------------------------------------------------------------

  assign reqbuf_tagctl_valid_tc0_o = reqbuf_state_tc0 & ((reqbuf_pass == PASS_SERIALISE) | reqbuf_tagctl_prearb_tc0_i);

  assign reqbuf_tagctl_prearb_req_o = reqbuf_state_tc0 & (reqbuf_pass == PASS_UPDATE) & ~reqbuf_tagctl_prearb_tc0_i;

  assign reqbuf_tagctl_pass_tc0_o = (reqbuf_pass == PASS_SERIALISE) ? `CA53_TAGCTL_PASS_SERIALISE :
                                                                      `CA53_TAGCTL_PASS_UPDATE;

  // Send the address to tagctl.
  assign reqbuf_tagctl_addr1_tc0_o = reqbuf_addr1;

  assign invalidating_snoop = ((reqbuf_type == `CA53_ACE_CLEANINVALID) |
                               (reqbuf_type == `CA53_ACE_READUNIQUE) |
                               (reqbuf_type == `CA53_ACE_MAKEINVALID));

  // Provide the state bits for tag RAM writes.
  assign tag_state_l1_tc0 = invalidating_snoop ? 3'b000 : {1'b1, ~reqbuf_shareability[0], 1'b0};

  assign tag_state_l2_tc0 = {invalidating_snoop ? 2'b00 : {1'b1, ~reqbuf_shareability[0]},
                             1'b0,
                             reqbuf_l2_dirty & (reqbuf_type != `CA53_ACE_CLEANSHARED),
                             reqbuf_l2_alloc};

  assign reqbuf_tagctl_wr_state_tc0_o = {tag_state_l2_tc0, {4{tag_state_l1_tc0}}};

  assign reqbuf_l1_hit_ways_0 = reqbuf_l1_hit_ways[1:0];
  assign reqbuf_l1_hit_ways_1 = reqbuf_l1_hit_ways[3:2];
  assign reqbuf_l1_hit_ways_2 = reqbuf_l1_hit_ways[5:4];
  assign reqbuf_l1_hit_ways_3 = reqbuf_l1_hit_ways[7:6];

  assign reqbuf_hit_ways = {{16{reqbuf_l2_hit}}        & `CA53_L2_WAY_DEC(reqbuf_l2_hit_way),
                            {4{reqbuf_l1_hit_cpus[3]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_3),
                            {4{reqbuf_l1_hit_cpus[2]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_2),
                            {4{reqbuf_l1_hit_cpus[1]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_1),
                            {4{reqbuf_l1_hit_cpus[0]}} & `CA53_L1_WAY_DEC(reqbuf_l1_hit_ways_0)};

  assign reqbuf_tagctl_ways_tc0_o = (((reqbuf_type == `CA53_ACE_DVM_COMPLETE) |
                                      (reqbuf_type == `CA53_ACE_DVM_MESSAGE))  ? 32'h00000000 :
                                     (reqbuf_pass == PASS_SERIALISE)           ? 32'hffffffff :
                                                                                 reqbuf_hit_ways);

  assign reqbuf_tagctl_write_tc0_o = {5{reqbuf_pass == PASS_UPDATE}};

  // The AFB is allocated in tc1, and we must record it so that we know when it
  // has completed all snoops or master requests.
  assign next_reqbuf_afb = reqbuf_state_tc1 ? tagctl_slv_afb_tc1_i : reqbuf_afb;

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_afb <= next_reqbuf_afb;
  end

  assign afb_done = ((afb0_done_i & (reqbuf_afb == 3'b000)) |
                     (afb1_done_i & (reqbuf_afb == 3'b001)) |
                     (afb2_done_i & (reqbuf_afb == 3'b010)) |
                     (afb3_done_i & (reqbuf_afb == 3'b011)) |
                     (afb4_done_i & (reqbuf_afb == 3'b100)) |
                     (afb5_done_i & (reqbuf_afb == 3'b101)));

  //----------------------------------------------------------------------------
  //  L2DB control
  //----------------------------------------------------------------------------


  // Record the L2DB allocated to this request when tagctl has allocated it
  // and confirmed it is needed. If the request is then flushed due to a
  // hazard tagctl is responsible for releasing them, but if the initial tagctl
  // pass is successful then the reqbuf is responsible for the L2DB after that.

  always @(posedge clk)
  if (initial_hit_en) begin
    reqbuf_l2db_hit   <= tagctl_slv_l2db_hit_tc3_i;
    reqbuf_l2db_dirty <= tagctl_slv_l2db_dirty_tc3_i;
    reqbuf_l2db_id    <= tagctl_slv_l2db_tc3_i;
  end

  assign reqbuf_l2db_id_o = reqbuf_l2db_id;

  // If the snoop hits an L2DB, but will not transfer data, then we need to
  // tell the L2DB that its state has changed.
  assign reqbuf_l2db_invalidate_o = ((reqbuf_state == STATE_RESP) &
                                     reqbuf_l2db_hit &
                                     ((reqbuf_type == `CA53_ACE_MAKEINVALID) |
                                      (reqbuf_type == `CA53_ACE_CLEANINVALID)));

  assign reqbuf_l2db_makeshared_o = ((reqbuf_state == STATE_RESP) &
                                     reqbuf_l2db_hit &
                                     (reqbuf_type == `CA53_ACE_CLEANSHARED));

  // Transfers are done the cycle after we know there are no hazards.
  assign next_reqbuf_l2db_transfer = (((reqbuf_state == STATE_TC4) &
                                       ~tagctl_slv_flush_tc4_i &
                                       (((reqbuf_l1_hit | reqbuf_l2_hit) &
                                         ~reqbuf_l2db_hit &
                                         ((reqbuf_type == `CA53_ACE_READONCE) |
                                          (reqbuf_type == `CA53_ACE_READSHARED) |
                                          (reqbuf_type == `CA53_ACE_READCLEAN) |
                                          (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                          (reqbuf_type == `CA53_ACE_READUNIQUE))) |
                                        ((reqbuf_l1_hit | (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                                         ~reqbuf_l2db_hit &
                                         ((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                          (reqbuf_type == `CA53_ACE_CLEANINVALID))))) |
                                      ((reqbuf_state == STATE_WAIT_AFB) &
                                       afb_done &
                                       require_l2db_wr_after_afb) |
                                      ((((reqbuf_state == STATE_RESP) &
                                         reqbuf_cr_ready_i) |
                                        (reqbuf_state == STATE_WAIT_CD)) &
                                       ~delay_cd_data &
                                       (((reqbuf_l1_hit | reqbuf_l2_hit | reqbuf_l2db_hit) &
                                         ((reqbuf_type == `CA53_ACE_READONCE) |
                                          (reqbuf_type == `CA53_ACE_READSHARED) |
                                          (reqbuf_type == `CA53_ACE_READCLEAN) |
                                          (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                          (reqbuf_type == `CA53_ACE_READUNIQUE))) |
                                        (((reqbuf_l1_hit & reqbuf_l1_dirty) |
                                          (reqbuf_l2_hit & reqbuf_l2_dirty) |
                                          (reqbuf_l2db_hit & reqbuf_l2db_dirty)) &
                                         ((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                          (reqbuf_type == `CA53_ACE_CLEANINVALID))))) |
                                      ((reqbuf_state == STATE_WAIT_L2DB) &
                                       l2db_early_done &
                                       require_l2db_after_l2db));


  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_transfer <= 1'b0;
  end else begin
    reqbuf_l2db_transfer <= next_reqbuf_l2db_transfer;
  end

  assign reqbuf_l2db_transfer_o = reqbuf_l2db_transfer;


  assign reqbuf_l2db_transfer_type_o = (((reqbuf_pass == PASS_UPDATE) |
                                         ((ACE == 0) & reqbuf_l2db_hit)) ? `CA53_L2DB_TRNSFR_L2DB_MASTER :
                                        reqbuf_l2_hit                    ? `CA53_L2DB_TRNSFR_RAM_L2DB :
                                                                           `CA53_L2DB_TRNSFR_SLV_L2DB);


  assign slv_transfer_info = {reqbuf_qos,
                              1'b1,
                              {10{1'b0}},
                              {1'b0, reqbuf_snoop_data_cpu, 3'b000},
                              reqbuf_addr1[5:4],
                              REQBUF_ID[5:0]};

  assign master_transfer_info = {reqbuf_qos,
                                 1'b1,
                                 reqbuf_cluster_unique,
                                 1'b0,
                                 1'b0,
                                 ~reqbuf_l2db_hit,
                                 reqbuf_srcid[6],
                                 (ACE != 0) ? `CA53_DATA_OPCODE_SNOOPDATA : snp_resp,
                                 reqbuf_txnid,
                                 reqbuf_addr1[5:4],
                                 reqbuf_srcid[5:0]};

  assign ram_transfer_info = {reqbuf_qos,
                              1'b1,
                              1'b0,
                              reqbuf_l2_hit_way,
                              reqbuf_addr1[16:4],
                              REQBUF_ID[5:0]};

  assign reqbuf_l2db_transfer_info_o = (((reqbuf_pass == PASS_UPDATE) |
                                         ((ACE == 0) & reqbuf_l2db_hit)) ? master_transfer_info :
                                        reqbuf_l2_hit                    ? ram_transfer_info :
                                                                           slv_transfer_info);


  assign reqbuf_l2db_release_o = ((reqbuf_state == STATE_WAIT_L2DB) &
                                  l2db_early_done & require_resp_after_l2db &
                                  ((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                                   (reqbuf_type == `CA53_ACE_CLEANINVALID)) &
                                  ~((reqbuf_l1_hit & reqbuf_l1_dirty) |
                                    (reqbuf_l2_hit & reqbuf_l2_dirty)) &
                                  ~reqbuf_l2db_hit);


  // The L2DB is reporting that it has completed its transfer.
  assign l2dbs_slv_done = {l2db10_snpslv_done_i,
                           l2db9_snpslv_done_i,
                           l2db8_snpslv_done_i,
                           l2db7_snpslv_done_i,
                           l2db6_snpslv_done_i,
                           l2db5_snpslv_done_i,
                           l2db4_snpslv_done_i,
                           l2db3_snpslv_done_i,
                           l2db2_snpslv_done_i,
                           l2db1_snpslv_done_i,
                           l2db0_snpslv_done_i};

  assign reqbuf_l2db_id_onehot = (11'b0000_0000_001 << reqbuf_l2db_id);

  // Let the state machines know when they can move on to the next state if
  // they are waiting for an L2DB.
  assign l2db_done = |(l2dbs_slv_done & reqbuf_l2db_id_onehot) & ~reqbuf_l2db_transfer;

  assign l2db_early_done = (l2db_done |
                            (require_resp_after_l2db &
                             ~|(reqbufs_older_i & (reqbufs_cr_unsent_i |
                                                   reqbufs_cd_unsent_i)) &
                             ramctl_l2dbs_valid_i & ramctl_l2dbs_last_i &
                             ~ramctl_bypassed_err_i &
                             (ramctl_l2dbs_id_i == reqbuf_l2db_id)));

  assign l2db_err = |(reqbuf_l2db_id_onehot & {l2db10_slv_err_i,
                                               l2db9_slv_err_i,
                                               l2db8_slv_err_i,
                                               l2db7_slv_err_i,
                                               l2db6_slv_err_i,
                                               l2db5_slv_err_i,
                                               l2db4_slv_err_i,
                                               l2db3_slv_err_i,
                                               l2db2_slv_err_i,
                                               l2db1_slv_err_i,
                                               l2db0_slv_err_i});

  // The L2DB is reporting that it is waiting for arbitration to the master.
  assign l2dbs_slv_master_arb = {l2db10_slv_master_arb_i,
                                 l2db9_slv_master_arb_i,
                                 l2db8_slv_master_arb_i,
                                 l2db7_slv_master_arb_i,
                                 l2db6_slv_master_arb_i,
                                 l2db5_slv_master_arb_i,
                                 l2db4_slv_master_arb_i,
                                 l2db3_slv_master_arb_i,
                                 l2db2_slv_master_arb_i,
                                 l2db1_slv_master_arb_i,
                                 l2db0_slv_master_arb_i};

  assign l2db_master_arb = |(l2dbs_slv_master_arb & reqbuf_l2db_id_onehot) | reqbuf_l2db_transfer;

  // Tell the other reqbufs that we have not sent our CD data yet, so that
  // they can wait until we have if they are older.
  assign reqbuf_cd_unsent_o = ((reqbuf_state == STATE_WAIT_CD) |
                               (reqbuf_state == STATE_WAIT_L2DB_ARB));

  // We must delay sending our CD data if there are older request buffers still
  // waiting to send theirs.
  assign delay_cd_data = |(reqbufs_older_i & reqbufs_cd_unsent_i);

  // Let ramctl know if an L2DB might be making a request in the following cycle.
  assign reqbuf_ramctl_active_o = reqbuf_l2db_transfer & (reqbuf_pass == PASS_SERIALISE) & reqbuf_l2_hit;

  // Let the master know if an L2DB might be making a request in the following cycle.
  assign reqbuf_master_active_o = reqbuf_l2db_transfer & ((reqbuf_pass == PASS_UPDATE) |
                                                          ((ACE == 0) & reqbuf_l2db_hit));

  // Detect when we are able to return the CR but not yet sent all the CD data
  // to the master for a snoop that hit a ReadUnique L2DB. This is required to
  // ensure that the CR response is not sent externally, and hence the
  // interconnect cannot start returning read data for the ReadUnique, before
  // the L2DB is ready to accept the data.
  assign reqbuf_snp_cd_l2db_o = ((ACE != 0) & reqbuf_l2db_hit &
                                 ~((reqbuf_type == `CA53_ACE_DVM_MESSAGE) |
                                   (reqbuf_type == `CA53_ACE_DVM_COMPLETE)) &
                                 (((reqbuf_state == STATE_RESP) &
                                   reqbuf_cr_ready_i &
                                   ~|(reqbufs_older_i & reqbufs_cr_unsent_i)) |
                                  (reqbuf_state == STATE_WAIT_CD) |
                                  (reqbuf_state == STATE_WAIT_L2DB_ARB) |
                                  (reqbuf_state == STATE_WAIT_L2DB)));

  //----------------------------------------------------------------------------
  //  CR responses
  //----------------------------------------------------------------------------

  // Indicate to other reqbufs when we have sent the response, to ensure they
  // are sent in order (ACE only).
  assign reqbuf_cr_unsent_o = (reqbuf_state != STATE_IDLE) & (reqbuf_pass == PASS_SERIALISE) & (ACE != 0);

  // Send the response when we are ready, and there are no older reqbufs that
  // have not yet send their response.
  assign reqbuf_cr_valid_o = (((reqbuf_state == STATE_RESP) |
                               (reqbuf_state == STATE_RESP2) |
                               ((reqbuf_state == STATE_TC4) &
                                require_resp_after_tagctl)) &
                              ~|(reqbufs_older_i & reqbufs_cr_unsent_i));

  assign reqbuf_cr_cancel_o = (reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i;

  // Indicate if we might be asserting cr_valid in the next cycle. Does not
  // need to include the time when cr_valid is already asserted.
  assign reqbuf_cr_active_o = ((reqbuf_state == STATE_TC3) |
                               ((reqbuf_state == STATE_WAIT_L2DB) &
                                l2db_early_done & require_resp_after_l2db) |
                               ((reqbuf_state == STATE_WAIT_AFB) &
                                afb_done & ~require_l2db_after_afb));


  assign cr_datatransfer = (((reqbuf_l1_hit | reqbuf_l2_hit | reqbuf_l2db_hit) &
                             ((reqbuf_type == `CA53_ACE_READONCE) |
                              (reqbuf_type == `CA53_ACE_READSHARED) |
                              (reqbuf_type == `CA53_ACE_READCLEAN) |
                              (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                              (reqbuf_type == `CA53_ACE_READUNIQUE))) |
                            (((reqbuf_l1_hit & reqbuf_l1_dirty) |
                              (reqbuf_l2_hit & reqbuf_l2_dirty) |
                              (reqbuf_l2db_hit & reqbuf_l2db_dirty)) &
                             ((reqbuf_type == `CA53_ACE_CLEANSHARED) |
                              (reqbuf_type == `CA53_ACE_CLEANINVALID))));

  // Report an error if the data being provided had a fatal ECC error. If the
  // tag had an error then this is treated as a miss and not reported on the
  // snoop interface (because if the tag has an error then it is not known if
  // it matches or not).
  assign cr_err = ((cr_datatransfer & l2db_err) |
                   ((reqbuf_type == `CA53_ACE_DVM_MESSAGE) & ((reqbuf_addr2[14:12] == 3'b101) |
                                                              (reqbuf_addr2[14:12] == 3'b111))));

  assign cr_dirty = ((reqbuf_l1_hit & reqbuf_l1_dirty) |
                     (reqbuf_l2_hit & reqbuf_l2_dirty) |
                     (reqbuf_l2db_hit & reqbuf_l2db_dirty));

  // Pass the line as dirty when it is dirty and leaving the cluster.
  assign cr_passdirty = (cr_datatransfer &
                         cr_dirty &
                         ((reqbuf_type == `CA53_ACE_READUNIQUE) |
                          (reqbuf_type == `CA53_ACE_CLEANINVALID) |
                          (reqbuf_type == `CA53_ACE_CLEANSHARED)));

  // We keep a copy of the line whenever allowed to.
  assign cr_isshared = ((cr_datatransfer &
                         ((reqbuf_type == `CA53_ACE_READONCE) |
                          (reqbuf_type == `CA53_ACE_READSHARED) |
                          (reqbuf_type == `CA53_ACE_READCLEAN) |
                          (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY))) |
                        ((reqbuf_l1_hit | reqbuf_l2_hit | reqbuf_l2db_hit) &
                         (reqbuf_type == `CA53_ACE_CLEANSHARED)));

  assign cr_wasunique = ((reqbuf_l1_hit | reqbuf_l2_hit | reqbuf_l2db_hit) &
                         reqbuf_cluster_unique &
                         ~((reqbuf_type == `CA53_ACE_DVM_MESSAGE) |
                           (reqbuf_type == `CA53_ACE_DVM_COMPLETE)));

  // Skyros responses must indicate what our final state of the line is.
  always @*
  case (reqbuf_type)
    `CA53_ACE_READSHARED,
    `CA53_ACE_READCLEAN:    snp_resp = cr_datatransfer ? {1'b0, cr_dirty, 1'b1} : 3'b000;
    `CA53_ACE_READONCE:     snp_resp = cr_datatransfer ? {1'b0, reqbuf_cluster_unique | cr_dirty,
                                                          ~reqbuf_cluster_unique} : 3'b000;
    `CA53_ACE_CLEANSHARED:  snp_resp = (reqbuf_l1_hit |
                                        reqbuf_l2_hit |
                                        reqbuf_l2db_hit) ? {cr_passdirty, 2'b01} : 3'b000;
    `CA53_ACE_CLEANINVALID,
    `CA53_ACE_READUNIQUE:   snp_resp = {cr_dirty, 2'b00};
    `CA53_ACE_MAKEINVALID,
    `CA53_ACE_DVM_MESSAGE:  snp_resp = 3'b000;
    default:                snp_resp = 3'bxxx;
  endcase

  assign snp_resperr = ((reqbuf_type == `CA53_ACE_DVM_MESSAGE) & (reqbuf_addr2[14:12] > 3'b100)) ? 2'b11 : 2'b00;

  assign reqbuf_cr_resp_o = (ACE != 0) ? {cr_wasunique,
                                          cr_isshared,
                                          cr_passdirty,
                                          cr_err,
                                          cr_datatransfer} : {snp_resp, snp_resperr};

  //----------------------------------------------------------------------------
  //  Hazarding
  //----------------------------------------------------------------------------

  // Address comparators.
  assign addr1_l1_index_hz_tc1 = ({config_l1_dc_size_i & tagctl_addr_tc1_i[13:11], tagctl_addr_tc1_i[10:6]} ==
                                  {config_l1_dc_size_i & reqbuf_addr1[13:11], reqbuf_addr1[10:6]});

  assign addr_l2_index_hz_tc1 = (tagctl_addr_valid_tc1_i &
                                 ({config_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {config_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]}));

  assign addr_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                 ({config_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                  {config_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]}));

  assign hz_comp_tc1 = (tagctl_addr_tc1_i[41:13] == reqbuf_addr1[41:13]) & addr_l2_index_hz_tc1;
  assign hz_comp_tc3 = (tagctl_addr_tc3_i[40:13] == reqbuf_addr1[40:13]) & addr_l2_index_hz_tc3;

  // Hazard this request based on serialised addresses.
  assign reqbuf_hz_addr = ((reqbuf_type != `CA53_ACE_DVM_COMPLETE) &
                           (reqbuf_type != `CA53_ACE_DVM_MESSAGE));

  // This request buffer has been serialised, or will be serialised before the
  // request in tc1/tc3.
  assign reqbuf_serialised_tc1 = ((reqbuf_state != STATE_IDLE) &
                                  ~((reqbuf_pass == PASS_SERIALISE) &
                                    ((reqbuf_state == STATE_DVM1) |
                                     (reqbuf_state == STATE_DVM2) |
                                     (reqbuf_state == STATE_TC0_TC1) |
                                     (((reqbuf_state == STATE_TC2) |
                                       (reqbuf_state == STATE_TC3) |
                                       (reqbuf_state == STATE_TC4)) &
                                      ~tagctl_serialising_tc1_i))));

  assign reqbuf_serialised_tc3 = ((reqbuf_state != STATE_IDLE) &
                                  ~((reqbuf_pass == PASS_SERIALISE) &
                                    ((reqbuf_state == STATE_TC0_TC1) |
                                     (reqbuf_state == STATE_TC2) |
                                     (reqbuf_state == STATE_TC3) |
                                     ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i))));

  assign reqbuf_older_than_tc1 = ((tagctl_reqbufid_tc1_i[2:0] != REQBUF_ID[2:0]) &
                                  ~|(reqbufs_older_i & (5'b00001 << tagctl_reqbufid_tc1_i[2:0])));

  // For ACE, requests must be responded to in order, and so the request in
  // tc1 must hazard if it is also from the snpslv and is younger than this
  // request and this request hasn't been serialised yet.
  assign order_hz_tc1 = ((ACE != 0) &
                         (reqbuf_state != STATE_IDLE) &
                         (tagctl_reqbufid_tc1_i[5:3] == REQBUF_ID[5:3]) &
                         reqbuf_older_than_tc1);

  // A DVM sync may not be serialised when there are any other DVMs outstanding,
  // to ensure the sync requests are only sent to the CPUs after earlier DVM
  // messages.
  assign sync_hz_tc1 = ((reqbuf_state != STATE_WAIT_SYNC) &
                        (reqbuf_type == `CA53_ACE_DVM_MESSAGE) &
                        (tagctl_snp_sync_tc1_i |
                         (tagctl_cpu_sync_tc1_i & (reqbuf_addr2[14:12] == `CA53_ACE_DVM_SYNC))));

  assign l2_index_hz_tc1 = ((reqbuf_pass == PASS_SERIALISE) &
                            ((reqbuf_state == STATE_TC2) |
                             (reqbuf_state == STATE_TC3)) & addr_l2_index_hz_tc1);

  assign requestor_way_tc1 = {{4{tagctl_reqbufid_tc1_i[4:3] == 2'b11}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b10}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b01}},
                              {4{tagctl_reqbufid_tc1_i[4:3] == 2'b00}}} & tagctl_ecc_way_tc1_i;

  // If there was a fatal ECC error on the duplicate tags then the normal
  // address hazarding may not catch an L1 eviction to the same index/way
  // as an existing request that is going to update the tag, so detect that
  // case here.
  assign l1_index_way_hz_tc1 = (tagctl_serialising_tc1_i &
                                tagctl_l1_lf_tc1_i &
                                addr1_l1_index_hz_tc1 &
                                |(reqbuf_hit_ways[15:0] & requestor_way_tc1) &
                                ((reqbuf_type == `CA53_ACE_MAKEINVALID) |
                                 (reqbuf_type == `CA53_ACE_READUNIQUE) |
                                 (reqbuf_type == `CA53_ACE_CLEANINVALID) |
                                 (reqbuf_type == `CA53_ACE_READSHARED) |
                                 (reqbuf_type == `CA53_ACE_READCLEAN) |
                                 (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                 (reqbuf_type == `CA53_ACE_CLEANSHARED)) &
                                ~((reqbuf_pass == PASS_SERIALISE) &
                                  ((reqbuf_state == STATE_TC0_TC1) |
                                   (reqbuf_state == STATE_TC2) |
                                   (reqbuf_state == STATE_TC3))));

  // Collate the hazarding hazarding information. It will then be combined with
  // the other reqbuf outputs and registered in the slv before sending back to
  // tagctl in tc2.
  assign reqbuf_hz_tc1_o = (reqbuf_serialised_tc1 ? ((reqbuf_hz_addr & (hz_comp_tc1 |
                                                                        l2_index_hz_tc1)) |
                                                     l1_index_way_hz_tc1 |
                                                     sync_hz_tc1) :
                                                    order_hz_tc1);

  // If this request is going to be updating the duplicate tags, and there is a
  // fatal ECC error on the duplicate tags then that fatal error must not cause
  // a MakeInvalid snoop to the CPU because then when we update the tags they
  // will be inconsistent with the CPU. So detect this case and tell tagctl not
  // to send a snoop.
  assign reqbuf_ecc_hz_tc1_o = (reqbuf_serialised_tc1 & addr1_l1_index_hz_tc1 &
                                |(tagctl_ecc_way_tc1_i & reqbuf_hit_ways[15:0]) &
                                ((reqbuf_type == `CA53_ACE_MAKEINVALID) |
                                 (reqbuf_type == `CA53_ACE_READUNIQUE) |
                                 (reqbuf_type == `CA53_ACE_CLEANINVALID) |
                                 (reqbuf_type == `CA53_ACE_READSHARED) |
                                 (reqbuf_type == `CA53_ACE_READCLEAN) |
                                 (reqbuf_type == `CA53_ACE_READNOTSHAREDDIRTY) |
                                 (reqbuf_type == `CA53_ACE_CLEANSHARED)));

  assign reqbuf_l2_way_used = ({16{reqbuf_serialised_tc3 &
                                   reqbuf_hz_addr &
                                   reqbuf_l2_hit}} &
                               `CA53_L2_WAY_DEC(reqbuf_l2_hit_way));

  assign reqbuf_l2_way_used_tc1_o = reqbuf_l2_way_used & {16{addr_l2_index_hz_tc1 &
                                                             ~`CA53_REQBUF_IS_TAGECC(tagctl_reqbufid_tc1_i)}};

  assign reqbuf_l2_way_used_vc1_o = (reqbuf_l2_way_used &
                                     {16{{config_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                         {config_l2_size_i & reqbuf_addr1[16:13], reqbuf_addr1[12:6]}}});

  assign l2_index_hz_tc3 = ((reqbuf_pass == PASS_SERIALISE) &
                            ((reqbuf_state == STATE_TC2) |
                             (reqbuf_state == STATE_TC3)) & addr_l2_index_hz_tc3);

  // The request in tc3 must hazard because this is an earlier serialised
  // request to the same address.
  assign reqbuf_hz_tc3_o = (reqbuf_serialised_tc3 &
                            (reqbuf_hz_addr & (hz_comp_tc3 |
                                               l2_index_hz_tc3)));


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

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The request buffer must be idle if it said it was going to be ready")
  u_ovl_reqbuf_ready (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (next_reqbuf_ready_o),
                      .test_expr   (reqbuf_state == STATE_IDLE));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_addr1_en")
  u_ovl_x_reqbuf_addr1_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (reqbuf_addr1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: initial_hit_en")
  u_ovl_x_initial_hit_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (initial_hit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: initial_hit_tc4_en")
  u_ovl_x_initial_hit_tc4_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (initial_hit_tc4_en));

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

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_l1_resp_en")
  u_ovl_x_reqbuf_l1_resp_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (reqbuf_l1_resp_en));


`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
