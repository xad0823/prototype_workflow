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
//  The DVM sync request buffer generates barrier and DVM complete requests for
//  responses to external DVM sync requests.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"


module ca53scu_reqbuf_sync #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire                   config_sysbardisable_i,

  output wire                   reqbuf_busy_o,
  input  wire                   reqbuf_alloc_i,
  input  wire                   master_snpslv_waddrs_valid_i,
  input  wire                   master_snpslv_db_valid_i,
  input  wire                   master_snpslv_dr_valid_i,
  input  wire                   master_rsp_comp_valid_i,
  input  wire [6:0]             master_rsp_txnid_i,
  input  wire                   master_snpslv_reqbuf_retry_i,
  input  wire [1:0]             master_snpslv_pcrdtype_i,
  output wire                   sync_bar_completed_o,

  input  wire                   cpuslv0_noncoh_since_barrier_i,
  input  wire                   cpuslv1_noncoh_since_barrier_i,
  input  wire                   cpuslv2_noncoh_since_barrier_i,
  input  wire                   cpuslv3_noncoh_since_barrier_i,

  // Tagctl requests
  output wire                   reqbuf_tagctl_valid_tc0_o,
  output wire [3:0]             reqbuf_tagctl_pass_tc0_o,
  input  wire                   reqbuf_arb_tc1_i,
  output wire [4:0]             reqbuf_type_o,
  output wire [7:0]             reqbuf_attrs_o,
  output wire                   reqbuf_static_pcredit_tc1_o,
  output wire [1:0]             reqbuf_pcrdtype_tc1_o,

  input  wire                   tagctl_slv_flush_tc1_i,
  input  wire [2:0]             tagctl_slv_afb_tc1_i,
  input  wire                   afb0_done_i,
  input  wire                   afb1_done_i,
  input  wire                   afb2_done_i,
  input  wire                   afb3_done_i,
  input  wire                   afb4_done_i,
  input  wire                   afb5_done_i
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE           = 3'b000;
  localparam STATE_WAIT_WADDRS    = 3'b001;
  localparam STATE_TC0_TC1        = 3'b011;
  localparam STATE_TC2            = 3'b100;
  localparam STATE_WAIT_AFB       = 3'b110;
  localparam STATE_WAIT_EXT       = 3'b111;
  localparam STATE_X              = 3'bxxx;

  localparam PASS_BARRIER         = 2'b00;
  localparam PASS_RETRY           = 2'b01;
  localparam PASS_COMPLETE        = 2'b10;

  reg [2:0]   reqbuf_state;
  reg [1:0]   reqbuf_pass;
  reg [2:0]   reqbuf_afb;
  reg         resp_received;

  reg [2:0]   next_reqbuf_state;
  wire        reqbuf_state_tc0;
  wire        reqbuf_state_tc1;
  wire        reqbuf_en;
  wire        update_reqbuf_pass;
  wire [1:0]  next_reqbuf_pass;
  wire        afb_done;
  wire [2:0]  next_reqbuf_afb;
  wire        ext_barrier_done;
  wire        next_resp_received;


  //----------------------------------------------------------------------------
  //  State machine
  //----------------------------------------------------------------------------

  always @*
  begin
    next_reqbuf_state = reqbuf_state;
    case (reqbuf_state)
      STATE_IDLE: begin
        if (reqbuf_alloc_i) begin
          next_reqbuf_state = STATE_WAIT_WADDRS;
        end
      end
      STATE_WAIT_WADDRS: begin
        // Wait for all waddrs that were active at the time of the barrier starting.
        if (~master_snpslv_waddrs_valid_i | ~config_sysbardisable_i) begin
          if (ACE) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else if ((cpuslv3_noncoh_since_barrier_i |
                        cpuslv2_noncoh_since_barrier_i |
                        cpuslv1_noncoh_since_barrier_i |
                        cpuslv0_noncoh_since_barrier_i) &
                       ~config_sysbardisable_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end else begin
            next_reqbuf_state = STATE_IDLE;
          end
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
        next_reqbuf_state = STATE_WAIT_AFB;
      end
      STATE_WAIT_AFB: begin
        if (afb_done) begin
          next_reqbuf_state = STATE_WAIT_EXT;
        end
      end
      STATE_WAIT_EXT: begin
        if ((reqbuf_pass == PASS_BARRIER) |
            (reqbuf_pass == PASS_RETRY)) begin
          if (ext_barrier_done) begin
            if (ACE) begin
              next_reqbuf_state = STATE_TC0_TC1;
            end else begin
              next_reqbuf_state = STATE_IDLE;
            end
          end else if (master_snpslv_reqbuf_retry_i) begin
            next_reqbuf_state = STATE_TC0_TC1;
          end
        end else begin
          if (master_snpslv_dr_valid_i) begin
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

  // For Skyros the reqbuf needs to know when the barrier is completed.
  assign sync_bar_completed_o = (((reqbuf_state == STATE_WAIT_WADDRS) &
                                  ~master_snpslv_waddrs_valid_i &
                                  ((~cpuslv3_noncoh_since_barrier_i &
                                    ~cpuslv2_noncoh_since_barrier_i &
                                    ~cpuslv1_noncoh_since_barrier_i &
                                    ~cpuslv0_noncoh_since_barrier_i) |
                                   config_sysbardisable_i)) |
                                 ((reqbuf_state == STATE_WAIT_EXT) & ext_barrier_done));

  // Keep track of what stage the request is at, and therefore what it needs
  // to do the next time it goes down tagctl.
  assign update_reqbuf_pass = (((reqbuf_state == STATE_WAIT_WADDRS) & (ACE != 0) &
                                ~master_snpslv_waddrs_valid_i & config_sysbardisable_i) |
                               ((reqbuf_state == STATE_WAIT_EXT) & ext_barrier_done));

  assign next_reqbuf_pass = ((reqbuf_state == STATE_IDLE) ? PASS_BARRIER :
                             master_snpslv_reqbuf_retry_i ? PASS_RETRY :
                             update_reqbuf_pass ? PASS_COMPLETE :
                             reqbuf_pass);

  always @(posedge clk)
  if (reqbuf_en) begin
    reqbuf_pass <= next_reqbuf_pass;
  end


  //----------------------------------------------------------------------------
  //  Tagctl requests
  //----------------------------------------------------------------------------

  assign reqbuf_tagctl_valid_tc0_o = reqbuf_state_tc0;


  assign reqbuf_tagctl_pass_tc0_o = `CA53_TAGCTL_PASS_MASTER_R;

  assign reqbuf_type_o = {(reqbuf_pass != PASS_COMPLETE), `CA53_ACE_DVM_COMPLETE};

  assign reqbuf_attrs_o = 8'b10000001;

  assign reqbuf_static_pcredit_tc1_o = (reqbuf_pass == PASS_RETRY);

  generate if (ACE) begin : g_ace

    assign reqbuf_pcrdtype_tc1_o = 2'b00;

  end else begin : g_skyros
    reg [1:0] reqbuf_pcrdtype;

    always @(posedge clk)
    if (master_snpslv_reqbuf_retry_i) begin
      reqbuf_pcrdtype <= master_snpslv_pcrdtype_i;
    end

    assign reqbuf_pcrdtype_tc1_o = {2{reqbuf_pass == PASS_RETRY}} & reqbuf_pcrdtype;

  end endgenerate

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

  assign next_resp_received = reqbuf_alloc_i ? 1'b0 : (resp_received |
                                                       master_snpslv_dr_valid_i |
                                                       master_snpslv_db_valid_i);

  always @(posedge clk)
  if (reqbuf_en) begin
    resp_received <= next_resp_received;
  end

  // The barrier is done when both halves have been received.
  assign ext_barrier_done = ((master_snpslv_dr_valid_i & master_snpslv_db_valid_i) |
                             (resp_received &
                              (master_snpslv_dr_valid_i | master_snpslv_db_valid_i)) |
                             (master_rsp_comp_valid_i & (master_rsp_txnid_i == `CA53_SNPSLV_TXNID)));

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
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: master_snpslv_reqbuf_retry_i")
  u_ovl_x_master_snpslv_reqbuf_retry_i (.clk       (clk),
                                        .reset_n   (reset_n),
                                        .qualifier (1'b1),
                                        .test_expr (master_snpslv_reqbuf_retry_i));

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

`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
