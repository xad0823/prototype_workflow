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
//  The tagctl ECC state machine deals with correcting ECC errors in the tag RAMs.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_tagctl_ecc #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire         clk,
  input  wire         reset_n,

  input  wire         ecc_err_tc3_i,
  input  wire [15:0]  l1_tag_err_tc3_i,
  input  wire [15:0]  l2_tag_err_tc3_i,
  input  wire [111:0] l1_tag_syndrome_tc3_i,
  input  wire [111:0] l2_tag_syndrome_tc3_i,
  input  wire [16:6]  req_addr1_tc3_i,
  input  wire [34:0]  victim_tag_tc3_i,
  input  wire [6:0]   victim_tag_ecc_tc3_i,
  input  wire [31:0]  req_ways_read_tc3_i,
  input  wire         flush_tc0_i,
  input  wire [2:0]   tagctl_l1_dc_size_i,
  input  wire [3:0]   tagctl_l2_size_i,
  input  wire         tagctl_ecc_hz_tc2_i,
  input  wire         tagctl_mbistreq_i,

  output wire         ecc_in_progress_o,
  output wire         ecc_tagctl_valid_tc0_o,
  output wire         ecc_tagctl_wr_tc0_o,
  output wire         ecc_tagctl_l2_tc0_o,
  output wire [3:0]   ecc_tagctl_pass_tc0_o,
  output wire [10:0]  ecc_tagctl_index_tc0_o,
  output wire [31:0]  ecc_tagctl_ways_tc0_o,
  output wire [39:0]  ecc_tagctl_wr_data_tc0_o,
  output wire         tagctl_ecc_wr_tc1_o,
  output wire         tagctl_err_valid_o,
  output wire         tagctl_err_fatal_o,
  output wire [10:0]  tagctl_err_index_o,
  output wire [4:0]   tagctl_err_way_o,
  output wire [3:0]   ecc_smp_en_o,
  output wire [3:0]   ecc_snoop_req_o,
  input  wire         ecc_ac_ready_i,
  output wire [40:0]  ecc_ac_addr_o,
  output wire [3:0]   ecc_ac_way_o,
  input  wire         cpuslv0_cr_valid_i,
  input  wire [2:0]   cpuslv0_cr_id_i,
  input  wire         cpuslv1_cr_valid_i,
  input  wire [2:0]   cpuslv1_cr_id_i,
  input  wire         cpuslv2_cr_valid_i,
  input  wire [2:0]   cpuslv2_cr_id_i,
  input  wire         cpuslv3_cr_valid_i,
  input  wire [2:0]   cpuslv3_cr_id_i
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  localparam STATE_IDLE      = 4'b0000;
  localparam STATE_READ_TC0  = 4'b0001;
  localparam STATE_READ_TC1  = 4'b0010;
  localparam STATE_READ_TC2  = 4'b0011;
  localparam STATE_READ_TC3  = 4'b0100;
  localparam STATE_WRITE_TC0 = 4'b0110;
  localparam STATE_FATAL_TC0 = 4'b0111;
  localparam STATE_FATAL_TC1 = 4'b1010;
  localparam STATE_FATAL_TC2 = 4'b1011;
  localparam STATE_SNOOP_AC  = 4'b1000;
  localparam STATE_SNOOP_CR  = 4'b1001;
  localparam STATE_X         = 4'bxxxx;

generate if (CPU_CACHE_PROTECTION[0] || SCU_CACHE_PROTECTION[0]) begin : g_ecc

  reg [3:0]    ecc_state;
  reg [10:0]   ecc_index;
  reg [4:0]    ecc_way;
  reg [39:0]   ecc_tagctl_wr_data_tc0;

  reg [3:0]    next_ecc_state;
  wire         ecc_state_en;
  wire         ecc_info_en;
  wire [4:0]   next_ecc_way;
  wire [10:0]  next_ecc_index;
  wire [6:0]   tag_syndrome_tc3 [31:0];
  wire [6:0]   victim_syndrome_tc3;
  wire [32:0]  victim_raw_tag_tc3;
  wire [39:0]  repaired_tag_tc3;
  wire         fatal_err_tc3;
  wire [39:0]  wr_data_tc3;
  wire         wr_data_en;
  wire         ecc_cr_valid;

  genvar i;

  //----------------------------------------------------------------------------
  //  Error information capture and correction
  //----------------------------------------------------------------------------

  // If a second error occurs whilst we are already dealing with a first, then
  // ignore it. The access with the error will retry again later.
  assign ecc_info_en = (ecc_state == STATE_IDLE) & ecc_err_tc3_i;

  // If there are multiple ways with an error, then pick one of them. It doesn't
  // matter which, as after correcting one we will go around again until all of
  // them are corrected.
  assign next_ecc_way = |l1_tag_err_tc3_i ? {1'b0, `CA53_L2_WAY_PICK(l1_tag_err_tc3_i)} :
                                            {1'b1, `CA53_L2_WAY_PICK(l2_tag_err_tc3_i)};

  assign next_ecc_index = |l1_tag_err_tc3_i ? {3'b000, req_addr1_tc3_i[13:11] & tagctl_l1_dc_size_i, req_addr1_tc3_i[10:6]} :
                                              {        req_addr1_tc3_i[16:13] & tagctl_l2_size_i,    req_addr1_tc3_i[12:6]};

  always @(posedge clk)
  if (ecc_info_en) begin
    ecc_index <= next_ecc_index;
    ecc_way   <= next_ecc_way;
  end

  // On the read pass, select the syndrome for the way we have read.
  for (i = 0; i < 16; i = i + 1) begin : g_syndrome_mux
    assign tag_syndrome_tc3[i]    = l1_tag_syndrome_tc3_i[7*i+:7];
    assign tag_syndrome_tc3[i+16] = l2_tag_syndrome_tc3_i[7*i+:7];
  end

  assign victim_syndrome_tc3 = tag_syndrome_tc3[ecc_way];

  // The tagctl victim selection logic aligns the tag so that the address bits
  // match between L1 and L2, so we must convert back to the raw RAM format here.
  assign victim_raw_tag_tc3 = ecc_way[4] ? victim_tag_tc3_i[34:2] : victim_tag_tc3_i[32:0];

  ca53_ecc_repair33 u_ecc_repair (
    .data_i     (victim_raw_tag_tc3),
    .ecc_i      (victim_tag_ecc_tc3_i),
    .syndrome_i (victim_syndrome_tc3),
    .data_o     (repaired_tag_tc3[32:0]),
    .ecc_o      (repaired_tag_tc3[39:33])
  );

  ca53_ecc_fatal33 u_ecc_fatal (
    .syndrome_i (victim_syndrome_tc3),
    .fatal_o    (fatal_err_tc3)
  );

  //----------------------------------------------------------------------------
  //  State machine
  //----------------------------------------------------------------------------

  // When an ECC error is detected, first we read the index and way that had the
  // error, then the error is corrected if possible, before either the corrected
  // value is written back, or the tag is invalidated.
  // If a tag invalidation was in progress when we tried to read the tag then
  // nothing will have been read, and the tag will be invalidated anyway and so
  // there is no need to update the tag.

  always @*
  case (ecc_state)
    STATE_IDLE:      next_ecc_state = ecc_err_tc3_i ? STATE_READ_TC0 : STATE_IDLE;
    STATE_READ_TC0:  next_ecc_state = flush_tc0_i ? STATE_READ_TC0 : STATE_READ_TC1;
    STATE_READ_TC1:  next_ecc_state = STATE_READ_TC2;
    STATE_READ_TC2:  next_ecc_state = STATE_READ_TC3;
    STATE_READ_TC3:  next_ecc_state = ~|req_ways_read_tc3_i ? STATE_IDLE :
                                      fatal_err_tc3         ? STATE_FATAL_TC0 :
                                                              STATE_WRITE_TC0;
    STATE_WRITE_TC0: next_ecc_state = STATE_IDLE;
    STATE_FATAL_TC0: next_ecc_state = ecc_way[4] ? STATE_IDLE : STATE_FATAL_TC1;
    STATE_FATAL_TC1: next_ecc_state = STATE_FATAL_TC2;
    STATE_FATAL_TC2: next_ecc_state = tagctl_ecc_hz_tc2_i ? STATE_IDLE : STATE_SNOOP_AC;
    STATE_SNOOP_AC:  next_ecc_state = ecc_ac_ready_i ? STATE_SNOOP_CR : STATE_SNOOP_AC;
    STATE_SNOOP_CR:  next_ecc_state = ecc_cr_valid ? STATE_IDLE : STATE_SNOOP_CR;
    default:         next_ecc_state = STATE_X;
  endcase

  assign ecc_state_en = ecc_err_tc3_i | (ecc_state != STATE_IDLE);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ecc_state <= STATE_IDLE;
  end else if (ecc_state_en) begin
    ecc_state <= next_ecc_state;
  end

  assign ecc_in_progress_o = (ecc_state != STATE_IDLE);

  // Send the read or write requests to tc0 arbitration. Because arbitration is
  // blocked when a correction is in progress, the correction is always granted,
  // although the read could be flushed due to an earlier access still in progress.
  assign ecc_tagctl_valid_tc0_o = ((ecc_state == STATE_READ_TC0) |
                                   (ecc_state == STATE_WRITE_TC0) |
                                   (ecc_state == STATE_FATAL_TC0));

  assign ecc_tagctl_wr_tc0_o = ((ecc_state == STATE_WRITE_TC0) |
                                (ecc_state == STATE_FATAL_TC0));

  assign ecc_tagctl_pass_tc0_o = ((ecc_state == STATE_WRITE_TC0) |
                                  (ecc_state == STATE_FATAL_TC0)) ? `CA53_TAGCTL_PASS_UPDATE :
                                                                    `CA53_TAGCTL_PASS_LOOKUP;
  assign ecc_tagctl_l2_tc0_o = ecc_way[4];

  assign ecc_tagctl_index_tc0_o = ecc_index;

  for (i = 0; i < 32; i = i + 1) begin : g_ecc_way
    assign ecc_tagctl_ways_tc0_o[i] = (ecc_way == i[4:0]);
  end

  assign wr_data_tc3 = (fatal_err_tc3 |
                        (ecc_state != STATE_READ_TC3)) ? {`CA53_TAG_NULL_ECC, {33{1'b0}}} : repaired_tag_tc3;

  assign wr_data_en = ecc_err_tc3_i | (ecc_state == STATE_READ_TC3);

  always @(posedge clk)
  if (wr_data_en) begin
    ecc_tagctl_wr_data_tc0 <= wr_data_tc3;
  end

  assign ecc_tagctl_wr_data_tc0_o = ecc_tagctl_wr_data_tc0;

  assign tagctl_ecc_wr_tc1_o = (ecc_state == STATE_FATAL_TC1);

  // Error reporting
  assign tagctl_err_valid_o = ((ecc_state == STATE_WRITE_TC0) |
                               (ecc_state == STATE_FATAL_TC0));
  assign tagctl_err_fatal_o = (ecc_state == STATE_FATAL_TC0);
  assign tagctl_err_index_o = ecc_index;
  assign tagctl_err_way_o = ecc_way;

  //----------------------------------------------------------------------------
  //  Snoop requests
  //----------------------------------------------------------------------------

  // SMPEN must have been set for a lookup and thus error to have occured.
  assign ecc_smp_en_o = {4{ecc_state != STATE_IDLE}} & (4'b0001 << ecc_way[3:2]);

  assign ecc_snoop_req_o = {4{(ecc_state == STATE_SNOOP_AC) & ~tagctl_mbistreq_i}} & (4'b0001 << ecc_way[3:2]);
  assign ecc_ac_addr_o = {{24{1'b0}}, ecc_index, {5{1'b0}}, 1'b1};
  assign ecc_ac_way_o = 4'b0001 << ecc_way[1:0];

  assign ecc_cr_valid = |{cpuslv3_cr_valid_i & (cpuslv3_cr_id_i == 3'b111),
                          cpuslv2_cr_valid_i & (cpuslv2_cr_id_i == 3'b111),
                          cpuslv1_cr_valid_i & (cpuslv1_cr_id_i == 3'b111),
                          cpuslv0_cr_valid_i & (cpuslv0_cr_id_i == 3'b111)};

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Tagctl ECC statemachine can only be in valid states")
  u_ovl_ecc_state (
    .clk        (clk),
    .reset_n    (reset_n),
    .test_expr  ((ecc_state == STATE_IDLE) |
                 (ecc_state == STATE_READ_TC0) |
                 (ecc_state == STATE_READ_TC1) |
                 (ecc_state == STATE_READ_TC2) |
                 (ecc_state == STATE_READ_TC3) |
                 (ecc_state == STATE_WRITE_TC0) |
                 (ecc_state == STATE_FATAL_TC0) |
                 (ecc_state == STATE_FATAL_TC1) |
                 (ecc_state == STATE_FATAL_TC2) |
                 (ecc_state == STATE_SNOOP_AC) |
                 (ecc_state == STATE_SNOOP_CR))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl writes must never be flushed in tc0")
  u_ovl_ecc_wr_flush (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((ecc_state == STATE_WRITE_TC0) |
                      (ecc_state == STATE_FATAL_TC0)),
    .consequent_expr (~flush_tc0_i)
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_data_en")
  u_ovl_x_wr_data_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (wr_data_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ecc_info_en")
  u_ovl_x_ecc_info_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ecc_info_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ecc_state_en")
  u_ovl_x_ecc_state_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (ecc_state_en));



`endif

end else begin : g_n_ecc

  assign ecc_in_progress_o = 1'b0;
  assign ecc_tagctl_valid_tc0_o = 1'b0;
  assign ecc_tagctl_wr_tc0_o = 1'b0;
  assign ecc_tagctl_pass_tc0_o = {4{1'b0}};
  assign ecc_tagctl_l2_tc0_o = 1'b0;
  assign ecc_tagctl_index_tc0_o = {11{1'b0}};
  assign ecc_tagctl_ways_tc0_o = {32{1'b0}};
  assign ecc_tagctl_wr_data_tc0_o = {40{1'b0}};
  assign tagctl_ecc_wr_tc1_o = 1'b0;
  assign tagctl_err_valid_o = 1'b0;
  assign tagctl_err_fatal_o = 1'b0;
  assign tagctl_err_index_o = {11{1'b0}};
  assign tagctl_err_way_o = {5{1'b0}};
  assign ecc_smp_en_o = {4{1'b0}};
  assign ecc_snoop_req_o = {4{1'b0}};
  assign ecc_ac_addr_o = {41{1'b0}};
  assign ecc_ac_way_o = {4{1'b0}};

end endgenerate

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
