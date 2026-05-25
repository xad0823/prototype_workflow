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
//  The reqbuf holds and controls L2 clean and invalidate ops as a result of an
//  ECC error.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"


module ca53scu_reqbuf_ecc #(`CA53_SCU_INT_PARAM_DECL, parameter NUM_REQBUFS = 1, parameter REQBUF_ID = 6'b000000)
 (
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire [3:0]             config_l2_size_i,

  // AC channel interface
  output wire                   reqbuf_busy_o,
  input  wire                   reqbuf_alloc_i,
  input  wire [10:0]            ramctl_ecc_flush_index_i,
  input  wire [3:0]             ramctl_ecc_flush_way_i,

  // Hazarding
  input  wire [41:6]            tagctl_addr_tc1_i,
  input  wire                   tagctl_addr_valid_tc1_i,
  input  wire [5:0]             tagctl_reqbufid_tc1_i,
  input  wire [10:0]            victimctl_index_vc1_i,
  output wire                   reqbuf_hz_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_tc1_o,
  output wire [15:0]            reqbuf_l2_way_used_vc1_o,
  input  wire [40:6]            tagctl_addr_tc3_i,
  input  wire                   tagctl_addr_valid_tc3_i,
  output wire                   reqbuf_hz_tc3_o,

  // Tagctl requests
  output wire                   reqbuf_tagctl_valid_tc0_o,
  output wire                   reqbuf_tagctl_prearb_req_o,
  output wire                   reqbuf_update_pass_o,
  output wire [3:0]             reqbuf_tagctl_pass_tc0_o,
  output wire [41:0]            reqbuf_tagctl_addr1_tc0_o,
  output wire [31:0]            reqbuf_tagctl_ways_tc0_o,
  output wire [4:0]             reqbuf_tagctl_write_tc0_o,
  input  wire                   reqbuf_tagctl_prearb_tc0_i,
  input  wire                   reqbuf_arb_tc1_i,
  output wire [4:0]             reqbuf_type_o,
  output wire [7:0]             reqbuf_attrs_o,
  output wire [40:0]            reqbuf_addr2_o,
  output wire                   reqbuf_dirty_o,
  output wire                   reqbuf_cluster_unique_o,

  input  wire                   tagctl_slv_flush_tc1_i,
  input  wire                   tagctl_slv_flush_tc2_i,
  input  wire                   tagctl_slv_flush_tc3_i,
  input  wire                   tagctl_slv_flush_tc4_i,
  input  wire                   tagctl_ecc_err_tc3_i,
  input  wire [2:0]             tagctl_slv_afb_tc1_i,
  input  wire [3:0]             tagctl_slv_l2db_tc3_i,
  input  wire [15:0]            tagctl_l1_hit_ways_tc3_i,
  input  wire                   tagctl_l2_victim_dirty_tc3_i,
  input  wire                   tagctl_l2_victim_alloc_tc3_i,
  input  wire [1:0]             tagctl_l2_victim_shareability_tc3_i,
  input  wire                   tagctl_l2_victim_valid_tc3_i,
  input  wire                   tagctl_l2_victim_cu_tc3_i,
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

  // L2DB control
  output wire                   reqbuf_l2db_transfer_o,
  output wire [3:0]             reqbuf_l2db_id_o,
  output wire [2:0]             reqbuf_l2db_transfer_type_o,
  output wire [28:0]            reqbuf_l2db_transfer_info_o,
  output wire                   reqbuf_l2db_release_o,

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

  output wire                   reqbuf_master_active_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE           = 3'b000;
  localparam STATE_TC0_TC1        = 3'b001;
  localparam STATE_TC2            = 3'b010;
  localparam STATE_TC3            = 3'b011;
  localparam STATE_TC4            = 3'b100;
  localparam STATE_WAIT_AFB       = 3'b101;
  localparam STATE_WAIT_L2DB      = 3'b110;
  localparam STATE_X              = 3'bxxx;

  localparam PASS_SERIALISE = 1'b0;
  localparam PASS_VICTIM    = 1'b1;

generate if (SCU_CACHE_PROTECTION) begin : g_ecc

  reg [2:0]            reqbuf_state;
  reg                  reqbuf_pass;
  reg [3:0]            reqbuf_l2db_id;
  reg [3:0]            reqbuf_way;
  reg [40:6]           reqbuf_addr;
  reg [2:0]            reqbuf_afb;
  reg                  reqbuf_l2_dirty;
  reg                  reqbuf_l2_alloc;
  reg                  reqbuf_l2_victim_valid;
  reg                  reqbuf_l2_victim_cu;
  reg [1:0]            reqbuf_shareability;
  reg                  reqbuf_l2db_transfer;
  reg                  reqbuf_victim_l1_hit;

  reg [2:0]            next_reqbuf_state;
  wire                 reqbuf_en;
  wire                 update_reqbuf_pass;
  wire                 next_reqbuf_pass;
  wire                 reqbuf_addr_en;
  wire [40:6]          next_reqbuf_addr;
  wire                 initial_hit_en;
  wire                 next_reqbuf_l2_victim_valid;
  wire                 afb_done;
  wire                 afb_victim_write;
  wire [2:0]           next_reqbuf_afb;
  wire [MAX_L2DBS-1:0] l2dbs_slv_done;
  wire [MAX_L2DBS-1:0] reqbuf_l2db_id_onehot;
  wire                 hazard_snoops;
  wire                 addr_l2_index_hz_tc1;
  wire                 addr_l2_index_hz_tc3;
  wire                 l2_index_hz_tc1;
  wire                 hz_comp_tc1;
  wire                 hz_comp_tc3;
  wire                 reqbuf_serialised_tc1;
  wire                 reqbuf_serialised_tc3;
  wire [15:0]          reqbuf_l2_way_used;
  wire                 reqbuf_state_tc0;
  wire                 reqbuf_state_tc1;
  wire [7:0]           setway_attrs;
  wire [28:0]          master_transfer_info;
  wire [28:0]          ram_transfer_info;
  wire                 l2db_done;
  wire                 next_reqbuf_l2db_transfer;
  wire                 victim_l1_hit_en;
  wire                 next_reqbuf_victim_l1_hit;


  //----------------------------------------------------------------------------
  //  State machine
  //----------------------------------------------------------------------------

  always @*
  begin
    next_reqbuf_state = reqbuf_state;
    case (reqbuf_state)
      STATE_IDLE: begin
        if (reqbuf_alloc_i) begin
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
        end else begin
          // These operations must wait until tc2 to ensure any other access
          // that started a tag read before this write will still detect an
          // address hazard when it is in tc3.
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
          if (reqbuf_l2_victim_valid |
              (reqbuf_pass == PASS_VICTIM)) begin
            next_reqbuf_state = STATE_WAIT_L2DB;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end
      end
      STATE_WAIT_L2DB: begin
        if (l2db_done) begin
          if (reqbuf_pass == PASS_SERIALISE) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
        end
      end
      default: next_reqbuf_state = STATE_X;
    endcase
  end

  // Decode some states that are more than just the state variable.
  assign reqbuf_state_tc0 = (reqbuf_state == STATE_TC0_TC1) & ~reqbuf_arb_tc1_i;

  assign reqbuf_state_tc1 = (reqbuf_state == STATE_TC0_TC1) & reqbuf_arb_tc1_i;

  // Enable various state only when active.
  assign reqbuf_en = reqbuf_alloc_i | (reqbuf_state != STATE_IDLE);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_state <= STATE_IDLE;
  end else if (reqbuf_en) begin
    reqbuf_state <= next_reqbuf_state;
  end

  assign reqbuf_busy_o = (reqbuf_state != STATE_IDLE);

  // Keep track of what stage the request is at, and therefore what it needs
  // to do the next time it goes down tagctl.
  assign update_reqbuf_pass = (reqbuf_state == STATE_WAIT_L2DB) & l2db_done;

  assign reqbuf_update_pass_o = update_reqbuf_pass | reqbuf_alloc_i;

  assign next_reqbuf_pass = ((reqbuf_state == STATE_IDLE) ? PASS_SERIALISE :
                             update_reqbuf_pass ? PASS_VICTIM :
                             reqbuf_pass);

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_pass <= next_reqbuf_pass;
  end


  //----------------------------------------------------------------------------
  //  Request storage
  //----------------------------------------------------------------------------

  assign reqbuf_type_o  = {1'b0, `CA53_SNP_CLEANINVSETWAY};

  assign reqbuf_attrs_o = setway_attrs;

  always @(posedge clk)
  if (reqbuf_alloc_i) begin
    reqbuf_way <= ramctl_ecc_flush_way_i;
  end

  assign next_reqbuf_addr = {tagctl_addr_tc3_i[40:17], reqbuf_alloc_i ? ramctl_ecc_flush_index_i : tagctl_addr_tc3_i[16:6]};

  assign reqbuf_addr_en = reqbuf_alloc_i | initial_hit_en;

  always @(posedge clk)
  if (reqbuf_addr_en) begin
    reqbuf_addr <= next_reqbuf_addr;
  end

  assign reqbuf_addr2_o = {reqbuf_addr, 6'b000000};

  assign initial_hit_en = (reqbuf_state == STATE_TC3) & (reqbuf_pass == PASS_SERIALISE) & ~tagctl_ecc_err_tc3_i;

  always @(posedge clk)
  if (initial_hit_en) begin
    reqbuf_l2_victim_cu    <= tagctl_l2_victim_cu_tc3_i;
    reqbuf_l2_dirty        <= tagctl_l2_victim_dirty_tc3_i;
    reqbuf_l2_alloc        <= tagctl_l2_victim_alloc_tc3_i;
    reqbuf_shareability    <= tagctl_l2_victim_shareability_tc3_i;
  end

  assign next_reqbuf_l2_victim_valid = (initial_hit_en ? tagctl_l2_victim_valid_tc3_i :
                                                         (reqbuf_l2_victim_valid &
                                                          ~(reqbuf_state_tc1 & (reqbuf_pass == PASS_VICTIM))));

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_l2_victim_valid <= next_reqbuf_l2_victim_valid;
  end

  // Store the results of the victim lookup.
  assign victim_l1_hit_en = (reqbuf_state == STATE_TC3) & (reqbuf_pass == PASS_VICTIM) & ~tagctl_ecc_err_tc3_i;

  assign next_reqbuf_victim_l1_hit = |tagctl_l1_hit_ways_tc3_i;

  always @(posedge clk)
  if (victim_l1_hit_en) begin
    reqbuf_victim_l1_hit <= next_reqbuf_victim_l1_hit;
  end

  assign reqbuf_dirty_o = reqbuf_l2_dirty;

  assign reqbuf_cluster_unique_o = reqbuf_l2_victim_cu;


  //----------------------------------------------------------------------------
  //  Tagctl requests
  //----------------------------------------------------------------------------

  assign reqbuf_tagctl_valid_tc0_o = reqbuf_state_tc0 & ((reqbuf_pass == PASS_SERIALISE) | reqbuf_tagctl_prearb_tc0_i);

  assign reqbuf_tagctl_prearb_req_o = reqbuf_state_tc0 & (reqbuf_pass == PASS_VICTIM) & ~reqbuf_tagctl_prearb_tc0_i;

  assign reqbuf_tagctl_pass_tc0_o = (reqbuf_pass == PASS_SERIALISE) ? `CA53_TAGCTL_PASS_SERIALISE :
                                                                      `CA53_TAGCTL_PASS_VICTIM;

  // Send the address to tagctl.
  assign reqbuf_tagctl_addr1_tc0_o = {1'b0, reqbuf_addr[40:32],
                                      (reqbuf_pass == PASS_SERIALISE) ? reqbuf_way : reqbuf_addr[31:28],
                                      reqbuf_addr[27:6], 6'b000000};

  assign reqbuf_tagctl_ways_tc0_o = {{16{(reqbuf_pass == PASS_SERIALISE) |
                                         reqbuf_l2_victim_valid}} & `CA53_L2_WAY_DEC(reqbuf_way),
                                     {16{reqbuf_pass == PASS_VICTIM}}};

  assign reqbuf_tagctl_write_tc0_o = {(reqbuf_pass == PASS_VICTIM), 4'b0000};

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

  assign afb_victim_write = ((afb0_done_i & (reqbuf_afb == 3'b000) & afb0_write_done_i) |
                             (afb1_done_i & (reqbuf_afb == 3'b001) & afb1_write_done_i) |
                             (afb2_done_i & (reqbuf_afb == 3'b010) & afb2_write_done_i) |
                             (afb3_done_i & (reqbuf_afb == 3'b011) & afb3_write_done_i) |
                             (afb4_done_i & (reqbuf_afb == 3'b100) & afb4_write_done_i) |
                             (afb5_done_i & (reqbuf_afb == 3'b101) & afb5_write_done_i));

  //----------------------------------------------------------------------------
  //  L2DB control
  //----------------------------------------------------------------------------


  // Record the L2DB allocated to this request when tagctl has allocated it
  // and confirmed it is needed. If the request is then flushed due to a
  // hazard tagctl is responsible for releasing them, but if the initial tagctl
  // pass is successful then the reqbuf is responsible for the L2DB after that.

  always @(posedge clk)
  if (initial_hit_en) begin
    reqbuf_l2db_id <= tagctl_slv_l2db_tc3_i;
  end

  assign reqbuf_l2db_id_o = reqbuf_l2db_id;

  // Transfers are done the cycle after we know there are no hazards.
  assign next_reqbuf_l2db_transfer = (((reqbuf_state == STATE_TC4) & ~tagctl_slv_flush_tc4_i &
                                       (reqbuf_pass == PASS_SERIALISE) &
                                       reqbuf_l2_victim_valid) |
                                      ((reqbuf_state == STATE_TC3) & ~tagctl_slv_flush_tc3_i &
                                       (reqbuf_pass == PASS_VICTIM) & ~tagctl_ecc_err_tc3_i));


  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reqbuf_l2db_transfer <= 1'b0;
  end else begin
    reqbuf_l2db_transfer <= next_reqbuf_l2db_transfer;
  end

  assign reqbuf_l2db_transfer_o = reqbuf_l2db_transfer;


  assign reqbuf_l2db_transfer_type_o = ((reqbuf_pass == PASS_VICTIM)  ? `CA53_L2DB_TRNSFR_L2DB_MASTER :
                                                                        `CA53_L2DB_TRNSFR_RAM_L2DB);


  assign setway_attrs = {4'b1011, 1'b1, reqbuf_l2_alloc, reqbuf_shareability};

  assign master_transfer_info = {4'b0000,
                                 1'b0,
                                 reqbuf_l2_victim_cu,
                                 1'b0,
                                 1'b1,
                                 1'b1,
                                 1'b0,
                                 (reqbuf_l2_dirty & reqbuf_victim_l1_hit)  ? `CA53_DATA_OPCODE_WRITECLEAN :
                                 reqbuf_l2_dirty                           ? `CA53_DATA_OPCODE_WRITEBACK :
                                                                             `CA53_DATA_OPCODE_EVICT,
                                 setway_attrs,
                                 2'b00,
                                 (ACE != 0) ? {REQBUF_ID[5:3], reqbuf_afb} : REQBUF_ID[5:0]};

  assign ram_transfer_info = {4'b0000,
                              1'b0,
                              1'b0,
                              reqbuf_way,
                              reqbuf_addr[16:6],
                              2'b00,
                              REQBUF_ID[5:0]};

  assign reqbuf_l2db_transfer_info_o = (reqbuf_pass == PASS_VICTIM) ? master_transfer_info : ram_transfer_info;


  assign reqbuf_l2db_release_o = ((reqbuf_state == STATE_WAIT_AFB) &
                                  (reqbuf_pass == PASS_VICTIM) &
                                  afb_done & ~afb_victim_write);


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

  assign reqbuf_l2db_id_onehot = (11'b0000_0000_001 << reqbuf_l2db_id);

  // Let the state machines know when they can move on to the next state if
  // they are waiting for an L2DB.
  assign l2db_done = |(l2dbs_slv_done & reqbuf_l2db_id_onehot) & ~reqbuf_l2db_transfer;

  // Let the master know if an L2DB might be making a request in the following cycle.
  assign reqbuf_master_active_o = reqbuf_l2db_transfer & (reqbuf_pass == PASS_VICTIM);

  //----------------------------------------------------------------------------
  //  Hazarding
  //----------------------------------------------------------------------------

  assign hazard_snoops = ~((ACE == 0) & (reqbuf_state == STATE_WAIT_L2DB) & (reqbuf_pass == PASS_VICTIM));

  // Address comparators.
  assign addr_l2_index_hz_tc1 = (tagctl_addr_valid_tc1_i &
                                 ({config_l2_size_i & tagctl_addr_tc1_i[16:13], tagctl_addr_tc1_i[12:6]} ==
                                  {config_l2_size_i & reqbuf_addr[16:13], reqbuf_addr[12:6]}));

  assign addr_l2_index_hz_tc3 = (tagctl_addr_valid_tc3_i &
                                 ({config_l2_size_i & tagctl_addr_tc3_i[16:13], tagctl_addr_tc3_i[12:6]} ==
                                  {config_l2_size_i & reqbuf_addr[16:13], reqbuf_addr[12:6]}));

  assign hz_comp_tc1 = (tagctl_addr_tc1_i[41:13] == {1'b0, reqbuf_addr[40:13]}) & addr_l2_index_hz_tc1;
  assign hz_comp_tc3 = (tagctl_addr_tc3_i[40:13] == reqbuf_addr[40:13]) & addr_l2_index_hz_tc3;

  // This request buffer has been serialised, or will be serialised before the
  // request in tc1/tc3.
  assign reqbuf_serialised_tc1 = ((reqbuf_state != STATE_IDLE) &
                                  ~((reqbuf_pass == PASS_SERIALISE) & (reqbuf_state == STATE_TC0_TC1)));

  assign reqbuf_serialised_tc3 = ((reqbuf_state != STATE_IDLE) &
                                  ~((reqbuf_pass == PASS_SERIALISE) &
                                    ((reqbuf_state == STATE_TC0_TC1) |
                                     (reqbuf_state == STATE_TC2) |
                                     (reqbuf_state == STATE_TC3) |
                                     ((reqbuf_state == STATE_TC4) & tagctl_slv_flush_tc4_i))));

  assign l2_index_hz_tc1 = ((reqbuf_pass == PASS_SERIALISE) &
                            ((reqbuf_state == STATE_TC2) |
                             (reqbuf_state == STATE_TC3)) &
                            addr_l2_index_hz_tc1);

  // Collate the hazarding hazarding information. It will then be combined with
  // the other reqbuf outputs and registered in the slv before sending back to
  // tagctl in tc2.
  assign reqbuf_hz_tc1_o = ((reqbuf_serialised_tc1 &
                             (hazard_snoops | ~`CA53_REQBUF_IS_SNOOP(tagctl_reqbufid_tc1_i)) &
                             tagctl_addr_valid_tc1_i & hz_comp_tc1) |
                            l2_index_hz_tc1);

  assign reqbuf_l2_way_used = {16{reqbuf_serialised_tc3}} & `CA53_L2_WAY_DEC(reqbuf_way);

  assign reqbuf_l2_way_used_tc1_o = reqbuf_l2_way_used & {16{addr_l2_index_hz_tc1 &
                                                             ~`CA53_REQBUF_IS_TAGECC(tagctl_reqbufid_tc1_i)}};

  assign reqbuf_l2_way_used_vc1_o = (reqbuf_l2_way_used &
                                     {16{{config_l2_size_i & victimctl_index_vc1_i[10:7], victimctl_index_vc1_i[6:0]} ==
                                         {config_l2_size_i & reqbuf_addr[16:13], reqbuf_addr[12:6]}}});

  // The request in tc3 must hazard because this is an earlier serialised
  // request to the same address.
  assign reqbuf_hz_tc3_o = (reqbuf_serialised_tc3 & tagctl_addr_valid_tc3_i & hz_comp_tc3);


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

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: initial_hit_en")
  u_ovl_x_initial_hit_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (initial_hit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reqbuf_addr_en")
  u_ovl_x_reqbuf_addr_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (reqbuf_addr_en));

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

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victim_l1_hit_en")
  u_ovl_x_victim_l1_hit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (victim_l1_hit_en));



`endif

end else begin : g_n_ecc

  assign reqbuf_busy_o = 1'b0;
  assign reqbuf_hz_tc1_o = 1'b0;
  assign reqbuf_l2_way_used_tc1_o = {16{1'b0}};
  assign reqbuf_l2_way_used_vc1_o = {16{1'b0}};
  assign reqbuf_hz_tc3_o = 1'b0;
  assign reqbuf_tagctl_valid_tc0_o = 1'b0;
  assign reqbuf_tagctl_prearb_req_o = 1'b0;
  assign reqbuf_update_pass_o = 1'b0;
  assign reqbuf_tagctl_pass_tc0_o = {4{1'b0}};
  assign reqbuf_tagctl_addr1_tc0_o = {42{1'b0}};
  assign reqbuf_tagctl_ways_tc0_o = {32{1'b0}};
  assign reqbuf_tagctl_write_tc0_o = {5{1'b0}};
  assign reqbuf_type_o = {5{1'b0}};
  assign reqbuf_attrs_o = {8{1'b0}};
  assign reqbuf_addr2_o = {41{1'b0}};
  assign reqbuf_dirty_o = 1'b0;
  assign reqbuf_cluster_unique_o = 1'b0;
  assign reqbuf_l2db_transfer_o = 1'b0;
  assign reqbuf_l2db_id_o = {4{1'b0}};
  assign reqbuf_l2db_transfer_type_o = {3{1'b0}};
  assign reqbuf_l2db_transfer_info_o = {29{1'b0}};
  assign reqbuf_l2db_release_o = 1'b0;
  assign reqbuf_master_active_o = 1'b0;

end endgenerate

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
