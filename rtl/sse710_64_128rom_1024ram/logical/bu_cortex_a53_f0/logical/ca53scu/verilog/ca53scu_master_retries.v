//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
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
//  Retry and pcredit tracking for the Skyros master interface.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_master_retries #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                 clk,
  input  wire                 clk_master,
  input  wire                 reset_n,

  input  wire                 rsp_valid_i,
  input  wire [3:0]           rxrsp_opcode_i,
  input  wire [6:0]           rxrsp_txnid_i,
  input  wire [6:0]           rxrsp_srcid_i,
  input  wire [1:0]           rxrsp_pcrdtype_i,
  input  wire [NUM_L2DBS-1:0] l2db_retry_ready_i,

  output wire [NUM_L2DBS-1:0] l2db_retry_valid_o,
  output wire [1:0]           l2db_retry_pcrdtype_o,
  output wire                 l2db_retry_active_o,

  output wire [7:0]           master_cpuslv0_reqbuf_retry_o,
  output wire [7:0]           master_cpuslv1_reqbuf_retry_o,
  output wire [7:0]           master_cpuslv2_reqbuf_retry_o,
  output wire [7:0]           master_cpuslv3_reqbuf_retry_o,
  output wire [3:0]           master_acpslv_reqbuf_retry_o,
  output wire                 master_snpslv_reqbuf_retry_o,

  output wire [1:0]           master_cpuslv0_pcrdtype_o,
  output wire [1:0]           master_cpuslv1_pcrdtype_o,
  output wire [1:0]           master_cpuslv2_pcrdtype_o,
  output wire [1:0]           master_cpuslv3_pcrdtype_o,
  output wire [1:0]           master_acpslv_pcrdtype_o,
  output wire [1:0]           master_snpslv_pcrdtype_o
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  localparam NUM_REQBUFS = (NUM_CPUS * 8) + (ACP ? 4 : 0);
  localparam NUM_RETRY = NUM_REQBUFS + NUM_L2DBS + 1;
  localparam NUM_RETRY_PART = NUM_RETRY/8;
  localparam NUM_RETRY_PARTS = (NUM_RETRY+7)/8;
  localparam NUM_RETRY_REM = NUM_RETRY[2:0];

  reg [NUM_RETRY-1:0]                   retrylist_retry_valid;
  reg [NUM_RETRY-1:0]                   retrylist_credit_valid;
  reg [6:0]                             retrylist_tgtid    [NUM_RETRY-1:0];
  reg [1:0]                             retrylist_pcrdtype [NUM_RETRY-1:0];
  reg                                   displaced_pcredit_skid;
  reg [6:0]                             displaced_tgtid_skid;
  reg [1:0]                             displaced_pcrdtype_skid;
  
  wire [6:0]                            next_retrylist_tgtid    [NUM_RETRY-1:0];
  wire [1:0]                            next_retrylist_pcrdtype [NUM_RETRY-1:0];
  wire [NUM_RETRY-1:0]                  push_retry;
  wire [NUM_RETRY-1:0]                  pop_retry;
  wire [NUM_RETRY-1:0]                  next_retrylist_retry_valid;
  wire [NUM_RETRY-1:0]                  displace_credit;
  wire [NUM_RETRY-1:0]                  push_pcredit;
  wire [NUM_RETRY-1:0]                  pop_pcredit;
  wire [NUM_RETRY-1:0]                  next_retrylist_credit_valid;
  wire [NUM_RETRY-1:0]                  retrylist_en;
  wire [NUM_RETRY-1:0]                  retry_unused;
  wire [NUM_RETRY-1:0]                  tgt_type_match;
  wire [NUM_RETRY-1:0]                  retry_credit_match;
  wire [NUM_RETRY-1:0]                  retry_lower_unused;
  wire [NUM_RETRY-1:0]                  retry_lowest_unused;
  wire [NUM_RETRY-1:0]                  retry_lower_credit_match;
  wire [NUM_RETRY-1:0]                  retry_lowest_credit_match;
  wire [NUM_RETRY-1:0]                  retrylist_ready_req;
  wire [NUM_RETRY-1:0]                  retrylist_match_req;
  wire [NUM_RETRY-1:0]                  retrylist_match_arb;
  wire [NUM_RETRY-1:0]                  retrylist_match_raw_arb;
  wire [NUM_RETRY_PARTS-1:0]            retrylist_match_part_req;
  wire [NUM_RETRY_PARTS-1:0]            retrylist_match_part_arb;
  wire [NUM_RETRY_PARTS-1:0]            retrylist_rr_en;
  wire [1:0]                            retrylist_l2db_pcrdtype [NUM_L2DBS-1:0];
  wire                                  rxrsp_retry;
  wire                                  rxrsp_pcredit;
  wire                                  retrylist_valid_en;
  wire                                  retrylist_match_en;
  wire                                  displaced_pcredit;
  wire [6:0]                            displaced_tgtid;
  wire [1:0]                            displaced_pcrdtype;
  wire                                  next_displaced_pcredit_skid;
  wire                                  retry_displaced_credit_match;

  genvar i;


  // The retry list is pushed when a relevant rxrsp flit arrives.
  assign rxrsp_retry   = rsp_valid_i & (rxrsp_opcode_i == `CA53_SKYROS_RSP_RETRYACK);
  assign rxrsp_pcredit = rsp_valid_i & (rxrsp_opcode_i == `CA53_SKYROS_RSP_PCRDGRANT);

  assign retrylist_valid_en = |retrylist_ready_req | rxrsp_retry | rxrsp_pcredit | displaced_pcredit_skid;

  generate for (i = 0; i < NUM_RETRY; i = i + 1) begin : g_retry

    // Push and pop retry entries based on an exact mapping of reqbuf/waddr
    // to retrylist entry.
    if (i < (8*NUM_CPUS)) begin : g_reqbuf
      assign push_retry[i] = rxrsp_retry & (rxrsp_txnid_i == {1'b0, i[5:0]});
      assign pop_retry[i]  = retrylist_ready_req[i];
    end else if (i < NUM_REQBUFS) begin : g_reqbuf_acp
      assign push_retry[i] = rxrsp_retry & (rxrsp_txnid_i == {5'b01001, i[1:0]});
      assign pop_retry[i]  = retrylist_ready_req[i];
    end else if (i < (NUM_RETRY-1)) begin : g_waddr
      wire [3:0] waddr;

      assign waddr = i[3:0] - NUM_REQBUFS[3:0];
      assign push_retry[i] = rxrsp_retry & (rxrsp_txnid_i == {3'b100, waddr[3:0]});
      assign pop_retry[i]  = l2db_retry_ready_i[waddr[3:0]];
    end else begin : g_snpslv
      assign push_retry[i] = rxrsp_retry & (rxrsp_txnid_i == `CA53_SNPSLV_TXNID);
      assign pop_retry[i]  = retrylist_ready_req[i];
    end

    assign next_retrylist_retry_valid[i] = (push_retry[i] |
                                            (retrylist_retry_valid[i] & ~pop_retry[i]));

    // Push credits to either a matching entry, otherwise to any empty entry.
    // If a credit is taking an entry that needs to be used for a retry then
    // pop it and push it back into a different entry in the following cycle.
    assign displace_credit[i] = retrylist_credit_valid[i] & push_retry[i] & ~tgt_type_match[i];

    assign push_pcredit[i] = ((|retrylist_match_req & retrylist_match_arb[i]) |
                              (push_retry[i] & ~retry_credit_match[i] &
                               (|retry_credit_match | retry_displaced_credit_match)) |
                              (((rxrsp_pcredit & ~|retrylist_match_req) |
                                (displaced_pcredit_skid & ~rxrsp_pcredit & ~retry_displaced_credit_match)) &
                               retry_lowest_unused[i]));

    assign pop_pcredit[i] = (pop_retry[i] | displace_credit[i] |
                             (retry_lowest_credit_match[i] & ~|(push_retry & retry_credit_match)));

    assign next_retrylist_credit_valid[i] = (push_pcredit[i] |
                                             (retrylist_credit_valid[i] & ~pop_pcredit[i]));

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      retrylist_retry_valid[i]  <= 1'b0;
      retrylist_credit_valid[i] <= 1'b0;
    end else if (retrylist_valid_en) begin
      retrylist_retry_valid[i]  <= next_retrylist_retry_valid[i];
      retrylist_credit_valid[i] <= next_retrylist_credit_valid[i];
    end

    // Store the information associated with this entry.
    assign retrylist_en[i] = push_retry[i] | push_pcredit[i];

    assign next_retrylist_tgtid[i]    = (push_retry[i] | rxrsp_pcredit) ? rxrsp_srcid_i    : displaced_tgtid_skid;
    assign next_retrylist_pcrdtype[i] = (push_retry[i] | rxrsp_pcredit) ? rxrsp_pcrdtype_i : displaced_pcrdtype_skid;

    always @(posedge clk_master)
    if (retrylist_en[i]) begin
      retrylist_tgtid[i]    <= next_retrylist_tgtid[i];
      retrylist_pcrdtype[i] <= next_retrylist_pcrdtype[i];
    end

    // If there is no matching retry when a pcredit arrives, then store it in
    // the lowest unused entry.
    assign retry_unused[i] = ~(retrylist_retry_valid[i] | retrylist_credit_valid[i] | push_retry[i]);

    // If there is a match of incoming retry ack with an existing pcredit, then
    // select the lowest matching pcredit.
    assign tgt_type_match[i] = ((rxrsp_srcid_i == retrylist_tgtid[i]) &
                                (rxrsp_pcrdtype_i == retrylist_pcrdtype[i]));

    assign retry_credit_match[i] = rxrsp_retry & retrylist_credit_valid[i] & ~retrylist_retry_valid[i] & tgt_type_match[i];

    if (i == 0) begin : g_zero
      assign retry_lower_unused[i] = 1'b0;
      assign retry_lower_credit_match[i] = 1'b0;
    end else begin : g_n_zero
      assign retry_lower_unused[i] = retry_unused[i-1] | retry_lower_unused[i-1];
      assign retry_lower_credit_match[i] = retry_credit_match[i-1] | retry_lower_credit_match[i-1];
    end

    assign retry_lowest_unused[i] = retry_unused[i] & ~retry_lower_unused[i];
    assign retry_lowest_credit_match[i] = retry_credit_match[i] & ~retry_lower_credit_match[i];

    // When both retry and credit are present, then the entry is ready to pop
    // and start a retry.
    assign retrylist_ready_req[i] = retrylist_retry_valid[i] & retrylist_credit_valid[i];

    // Detect when there is a credit arriving that matches an existing retry
    // entry. If there are multiple matches then one must be selected on a
    // round robin basis to prevent starvation.
    assign retrylist_match_req[i] = (retrylist_retry_valid[i] &
                                     ~retrylist_credit_valid[i] &
                                     rxrsp_pcredit &
                                     tgt_type_match[i]);

  end endgenerate

  // Indicate when we might be able to send a retry for a waddr in the next cycle.
  assign l2db_retry_active_o = (|(retrylist_retry_valid[NUM_RETRY-1:NUM_REQBUFS] &
                                  retrylist_credit_valid[NUM_RETRY-1:NUM_REQBUFS]) | 
                                (rxrsp_pcredit | displaced_pcredit_skid));

  assign displaced_pcredit = |displace_credit;

  // Select the details of the credit that is being displaced.
  `CA53_ONEHOT_MUX(displaced_tgtid,    7, displace_credit, retrylist_tgtid,    NUM_RETRY, g_mux_displaced_tgtid)
  `CA53_ONEHOT_MUX(displaced_pcrdtype, 2, displace_credit, retrylist_pcrdtype, NUM_RETRY, g_mux_displaced_pcrdtype)

  // Store the displaced credit in a skid register, so it can be inserted back
  // into another entry in the following cycle. If there is a new credit
  // arriving when there is still a skidded credit then the skidded credit is
  // put into the retry list and the incoming credit is placed in the skid
  // registers. If there is a new retry arriving then the skidded credit remains
  // in the skid registers for another cycle.
  assign next_displaced_pcredit_skid = displaced_pcredit | (displaced_pcredit_skid & rxrsp_pcredit);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    displaced_pcredit_skid <= 1'b0;
  end else begin
    displaced_pcredit_skid <= next_displaced_pcredit_skid;
  end

  always @(posedge clk_master)
  if (displaced_pcredit) begin
    displaced_tgtid_skid    <= displaced_tgtid;
    displaced_pcrdtype_skid <= displaced_pcrdtype;
  end

  // If an arriving retry matches the displaced credit, but not any other
  // credits, then it must use the displaced credit.
  assign retry_displaced_credit_match = (rxrsp_retry & displaced_pcredit_skid &
                                         (rxrsp_srcid_i == displaced_tgtid_skid) &
                                         (rxrsp_pcrdtype_i == displaced_pcrdtype_skid) &
                                         ~|retry_credit_match);

  assign retrylist_match_en = |retrylist_match_req;

  // Arbitrate which of the matching retries that are waiting should get the
  // new credit.
  // The arbitration is done in two layers, to avoid a very large and hence
  // slower arbiter.
  generate for (i = 0; i < NUM_RETRY_PART; i = i + 1) begin : g_retry_part_arb

    assign retrylist_rr_en[i] = retrylist_match_en & retrylist_match_part_arb[i];

    ca53_rr_reg_arb #(.WIDTH(8)) u_retry_ready_part_arb (
      .clk        (clk_master),
      .reset_n    (reset_n),
      .enable_i   (retrylist_rr_en[i]),
      .requests_i (retrylist_match_req[8*i+:8]),
      .arb_o      (retrylist_match_raw_arb[8*i+:8])
    );

    assign retrylist_match_part_req[i] = |retrylist_match_req[8*i+:8];

  end endgenerate

  generate if (NUM_RETRY_REM > 0) begin : g_retry_rem_arb

    assign retrylist_rr_en[NUM_RETRY_PART] = retrylist_match_en & retrylist_match_part_arb[NUM_RETRY_PART];

    ca53_rr_reg_arb #(.WIDTH(NUM_RETRY_REM)) u_retry_ready_part_arb (
      .clk        (clk_master),
      .reset_n    (reset_n),
      .enable_i   (retrylist_rr_en[NUM_RETRY_PART]),
      .requests_i (retrylist_match_req[8*NUM_RETRY_PART+:NUM_RETRY_REM]),
      .arb_o      (retrylist_match_raw_arb[8*NUM_RETRY_PART+:NUM_RETRY_REM])
    );

    assign retrylist_match_part_req[NUM_RETRY_PART] = |retrylist_match_req[8*NUM_RETRY_PART+:NUM_RETRY_REM];

  end endgenerate

  ca53_rr_reg_arb #(.WIDTH(NUM_RETRY_PARTS)) u_retry_ready_arb (
    .clk        (clk_master),
    .reset_n    (reset_n),
    .enable_i   (retrylist_match_en),
    .requests_i (retrylist_match_part_req),
    .arb_o      (retrylist_match_part_arb)
  );

  generate for (i = 0; i < NUM_RETRY; i = i + 1) begin : g_retry_arb2
    assign retrylist_match_arb[i] = retrylist_match_raw_arb[i] & retrylist_match_part_arb[i/8];
  end endgenerate

  // Signal back to the reqbufs when they must retry their request.
  assign master_cpuslv0_reqbuf_retry_o = retrylist_ready_req[7:0];

  assign master_cpuslv0_pcrdtype_o = (({2{retrylist_ready_req[7]}} & retrylist_pcrdtype[7]) |
                                      ({2{retrylist_ready_req[6]}} & retrylist_pcrdtype[6]) |
                                      ({2{retrylist_ready_req[5]}} & retrylist_pcrdtype[5]) |
                                      ({2{retrylist_ready_req[4]}} & retrylist_pcrdtype[4]) |
                                      ({2{retrylist_ready_req[3]}} & retrylist_pcrdtype[3]) |
                                      ({2{retrylist_ready_req[2]}} & retrylist_pcrdtype[2]) |
                                      ({2{retrylist_ready_req[1]}} & retrylist_pcrdtype[1]) |
                                      ({2{retrylist_ready_req[0]}} & retrylist_pcrdtype[0]));

  generate if (NUM_CPUS > 1) begin : g_cpu1
    assign master_cpuslv1_reqbuf_retry_o = retrylist_ready_req[15:8];

    assign master_cpuslv1_pcrdtype_o = (({2{retrylist_ready_req[15]}} & retrylist_pcrdtype[15]) |
                                        ({2{retrylist_ready_req[14]}} & retrylist_pcrdtype[14]) |
                                        ({2{retrylist_ready_req[13]}} & retrylist_pcrdtype[13]) |
                                        ({2{retrylist_ready_req[12]}} & retrylist_pcrdtype[12]) |
                                        ({2{retrylist_ready_req[11]}} & retrylist_pcrdtype[11]) |
                                        ({2{retrylist_ready_req[10]}} & retrylist_pcrdtype[10]) |
                                        ({2{retrylist_ready_req[9]}}  & retrylist_pcrdtype[9]) |
                                        ({2{retrylist_ready_req[8]}}  & retrylist_pcrdtype[8]));

  end else begin : g_n_cpu1
    assign master_cpuslv1_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv1_pcrdtype_o = 2'b00;
  end endgenerate

  generate if (NUM_CPUS > 2) begin : g_cpu2
    assign master_cpuslv2_reqbuf_retry_o = retrylist_ready_req[23:16];

    assign master_cpuslv2_pcrdtype_o = (({2{retrylist_ready_req[23]}} & retrylist_pcrdtype[23]) |
                                        ({2{retrylist_ready_req[22]}} & retrylist_pcrdtype[22]) |
                                        ({2{retrylist_ready_req[21]}} & retrylist_pcrdtype[21]) |
                                        ({2{retrylist_ready_req[20]}} & retrylist_pcrdtype[20]) |
                                        ({2{retrylist_ready_req[19]}} & retrylist_pcrdtype[19]) |
                                        ({2{retrylist_ready_req[18]}} & retrylist_pcrdtype[18]) |
                                        ({2{retrylist_ready_req[17]}} & retrylist_pcrdtype[17]) |
                                        ({2{retrylist_ready_req[16]}} & retrylist_pcrdtype[16]));

  end else begin : g_n_cpu2
    assign master_cpuslv2_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv2_pcrdtype_o = 2'b00;
  end endgenerate

  generate if (NUM_CPUS > 3) begin : g_cpu3
    assign master_cpuslv3_reqbuf_retry_o = retrylist_ready_req[31:24];

    assign master_cpuslv3_pcrdtype_o = (({2{retrylist_ready_req[31]}} & retrylist_pcrdtype[31]) |
                                        ({2{retrylist_ready_req[30]}} & retrylist_pcrdtype[30]) |
                                        ({2{retrylist_ready_req[29]}} & retrylist_pcrdtype[29]) |
                                        ({2{retrylist_ready_req[28]}} & retrylist_pcrdtype[28]) |
                                        ({2{retrylist_ready_req[27]}} & retrylist_pcrdtype[27]) |
                                        ({2{retrylist_ready_req[26]}} & retrylist_pcrdtype[26]) |
                                        ({2{retrylist_ready_req[25]}} & retrylist_pcrdtype[25]) |
                                        ({2{retrylist_ready_req[24]}} & retrylist_pcrdtype[24]));

  end else begin : g_n_cpu3
    assign master_cpuslv3_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv3_pcrdtype_o = 2'b00;
  end endgenerate

  generate if (ACP) begin : g_acp
    assign master_acpslv_reqbuf_retry_o = retrylist_ready_req[NUM_CPUS*8+:4];

    assign master_acpslv_pcrdtype_o = (({2{retrylist_ready_req[NUM_CPUS*8+3]}} & retrylist_pcrdtype[NUM_CPUS*8+3]) |
                                       ({2{retrylist_ready_req[NUM_CPUS*8+2]}} & retrylist_pcrdtype[NUM_CPUS*8+2]) |
                                       ({2{retrylist_ready_req[NUM_CPUS*8+1]}} & retrylist_pcrdtype[NUM_CPUS*8+1]) |
                                       ({2{retrylist_ready_req[NUM_CPUS*8+0]}} & retrylist_pcrdtype[NUM_CPUS*8+0]));

  end else begin : g_n_acp
    assign master_acpslv_reqbuf_retry_o = {4{1'b0}};
    assign master_acpslv_pcrdtype_o = 2'b00;
  end endgenerate

  assign l2db_retry_valid_o = retrylist_ready_req[NUM_RETRY-2:NUM_REQBUFS];

  generate for (i = 0; i < NUM_L2DBS; i = i + 1) begin : g_l2db
    assign retrylist_l2db_pcrdtype[i] = retrylist_pcrdtype[i + NUM_REQBUFS];
  end endgenerate

  `CA53_ONEHOT_MUX(l2db_retry_pcrdtype_o, 2, l2db_retry_ready_i, retrylist_l2db_pcrdtype, NUM_L2DBS, g_mux_l2db_retry_pcrdtype)

  assign master_snpslv_reqbuf_retry_o = retrylist_ready_req[NUM_RETRY-1];
  assign master_snpslv_pcrdtype_o = retrylist_pcrdtype[NUM_RETRY-1];

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "One entry should be pushed when a retry arrives")
  u_ovl_retry_pushed (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (rxrsp_retry),
                      .consequent_expr (|push_retry));

  assert_zero_one_hot #(`OVL_FATAL, NUM_RETRY, `OVL_ASSERT, "One entry should be pushed when a retry arrives")
  u_ovl_retry_push_zoh (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (push_retry));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A valid entry cannot be pushed")
  u_ovl_retry_valid_pushed (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (|push_retry),
                            .consequent_expr (~|(push_retry & retrylist_retry_valid)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "There must be an empty entry when a credit arrives")
  u_ovl_credit_valid_pushed (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (rxrsp_pcredit | displaced_pcredit_skid),
                            .consequent_expr (~&retrylist_credit_valid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A credit cannot be pushed to an entry that already has a credit")
  u_ovl_push_credit (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (|push_pcredit),
                     .consequent_expr (~|(push_pcredit & retrylist_credit_valid & ~pop_pcredit)));

  assert_zero_one_hot #(`OVL_FATAL, NUM_RETRY, `OVL_ASSERT, "Only one pcredit entry should be pushed unless a skidded credit is present")
  u_ovl_pcredit_push_zoh (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (displaced_pcredit_skid ? {NUM_RETRY{1'b0}} : push_pcredit));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: displaced_pcredit")
  u_ovl_x_displaced_pcredit (.clk       (clk_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (displaced_pcredit));

  assert_never_unknown #(`OVL_FATAL, NUM_RETRY, `OVL_ASSERT, "Register enable x-check: retrylist_en")
  u_ovl_x_retrylist_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (retrylist_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: retrylist_valid_en")
  u_ovl_x_retrylist_valid_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (retrylist_valid_en));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
