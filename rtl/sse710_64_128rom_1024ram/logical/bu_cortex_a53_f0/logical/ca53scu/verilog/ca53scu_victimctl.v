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
//  The victim control pipeline accesses the victim RAM, and pick L2 victim ways.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_victimctl #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                                     clk,
  input  wire                                     reset_n,
  input  wire                                     DFTSE,
  input  wire                                     DFTRAMHOLD,

  input  wire                                     leaving_reset_i,
  input  wire                                     config_l2rstdisable_i,
  input  wire [`CA53_L2_SIZE_W-1:0]               config_l2_size_i,
  input  wire [1:0]                               gov_l2victim_ctl_i,
  input  wire                                     gov_l2_in_retention_i,
  input  wire                                     ram_idle_count_max_i,

  // RAM interface
  output wire                                     l2_victimram_no_acc_next_cycle_o,
  output wire                                     l2_victimram_clken_o,
  output wire                                     l2_victimram_en_o,
  output wire                                     l2_victimram_wr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata_o,
  input  wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_rdata_i,


  // Slv requests
  input  wire                                     cpuslv0_victimctl_active_i,
  input  wire                                     cpuslv0_victimctl_valid_i,
  input  wire [10:0]                              cpuslv0_victimctl_index_i,
  input  wire                                     cpuslv0_victimctl_wr_i,
  input  wire                                     cpuslv0_victimctl_age_i,
  input  wire                                     cpuslv0_victimctl_iside_i,
  input  wire                                     cpuslv0_victimctl_nontemp_i,
  input  wire [3:0]                               cpuslv0_victimctl_way_i,
  input  wire [2:0]                               cpuslv0_victimctl_id_i,

  input  wire                                     cpuslv1_victimctl_active_i,
  input  wire                                     cpuslv1_victimctl_valid_i,
  input  wire [10:0]                              cpuslv1_victimctl_index_i,
  input  wire                                     cpuslv1_victimctl_wr_i,
  input  wire                                     cpuslv1_victimctl_age_i,
  input  wire                                     cpuslv1_victimctl_iside_i,
  input  wire                                     cpuslv1_victimctl_nontemp_i,
  input  wire [3:0]                               cpuslv1_victimctl_way_i,
  input  wire [2:0]                               cpuslv1_victimctl_id_i,

  input  wire                                     cpuslv2_victimctl_active_i,
  input  wire                                     cpuslv2_victimctl_valid_i,
  input  wire [10:0]                              cpuslv2_victimctl_index_i,
  input  wire                                     cpuslv2_victimctl_wr_i,
  input  wire                                     cpuslv2_victimctl_age_i,
  input  wire                                     cpuslv2_victimctl_iside_i,
  input  wire                                     cpuslv2_victimctl_nontemp_i,
  input  wire [3:0]                               cpuslv2_victimctl_way_i,
  input  wire [2:0]                               cpuslv2_victimctl_id_i,

  input  wire                                     cpuslv3_victimctl_active_i,
  input  wire                                     cpuslv3_victimctl_valid_i,
  input  wire [10:0]                              cpuslv3_victimctl_index_i,
  input  wire                                     cpuslv3_victimctl_wr_i,
  input  wire                                     cpuslv3_victimctl_age_i,
  input  wire                                     cpuslv3_victimctl_iside_i,
  input  wire                                     cpuslv3_victimctl_nontemp_i,
  input  wire [3:0]                               cpuslv3_victimctl_way_i,
  input  wire [2:0]                               cpuslv3_victimctl_id_i,

  input  wire                                     acpslv_victimctl_active_i,
  input  wire                                     acpslv_victimctl_valid_i,
  input  wire [10:0]                              acpslv_victimctl_index_i,
  input  wire                                     acpslv_victimctl_wr_i,
  input  wire                                     acpslv_victimctl_age_i,
  input  wire [3:0]                               acpslv_victimctl_way_i,
  input  wire [2:0]                               acpslv_victimctl_id_i,

  // Slv responses
  output wire                                     victimctl_ready_o,
  output wire [5:0]                               victimctl_ready_id_o,
  output wire                                     victimctl_ack_o,
  output wire [5:0]                               victimctl_ack_id_o,
  output wire [3:0]                               victimctl_victim_way_o,

  // Hazarding
  output wire [10:0]                              victimctl_index_vc1_o,
  input  wire [15:0]                              cpuslv0_l2_way_used_vc2_i,
  input  wire [15:0]                              cpuslv1_l2_way_used_vc2_i,
  input  wire [15:0]                              cpuslv2_l2_way_used_vc2_i,
  input  wire [15:0]                              cpuslv3_l2_way_used_vc2_i,
  input  wire [15:0]                              acpslv_l2_way_used_vc2_i,
  input  wire [15:0]                              snpslv_l2_way_used_vc2_i,

  // MBIST
  input  wire                                     gov_mbistreq_i,
  input  wire [`CA53_MBIST0_RAMARRAY_W-1:0]       gov_mbistarray0_i,
  input  wire                                     gov_mbistwriteen0_i,
  input  wire                                     gov_mbistreaden0_i,
  input  wire [`CA53_MBIST0_ADDR_W-1:0]           gov_mbistaddr0_i,
  input  wire [`CA53_MBIST0_BE_W-1:0]             gov_mbistbe0_i,
  input  wire                                     gov_mbistcfg0_i,
  input  wire [31:0]                              gov_mbistindata0_i,
  output wire                                     victimctl_mbist_sel_o,
  output wire [31:0]                              victimctl_mbistoutdata_o
);

generate if (L2_CACHE) begin : g_l2cc

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  genvar i;

  reg                     clk_enable;
  reg                     inval_all;
  reg                     victimctl_mbistreq;
  reg                     victimctl_en_vc1;
  reg                     victimctl_wr_vc1;
  reg [31:0]              victimctl_wdata_vc1;
  reg [15:0]              victimctl_strb_vc1;
  reg                     victimctl_valid_vc1;
  reg                     victimctl_valid_vc2;
  reg                     victimctl_valid_vc3;
  reg                     victimctl_valid_vc4;
  reg [10:0]              victimctl_addr_vc1;
  reg [10:0]              victimctl_addr_vc2;
  reg [10:0]              victimctl_addr_vc3;
  reg [5:0]               victimctl_id_vc1;
  reg [5:0]               victimctl_id_vc2;
  reg [5:0]               victimctl_id_vc3;
  reg [5:0]               victimctl_id_vc4;
  reg [31:0]              victimctl_rdata_vc3;
  reg [15:0]              victimctl_way_used_vc3;
  reg                     victimctl_disable_vc3;
  reg                     victimram_no_acc_next_cycle;
  reg [3:0]               age_round_robin_vc3;
  reg [3:0]               victimctl_way_vc4;

  wire                    clk_victimctl;
  wire                    victimctl_active;
  wire                    next_clk_enable;
  wire                    next_inval_all;
  wire [10:0]             victimctl_inv_all_addr_vc0;
  wire                    inval_all_complete;
  wire [4:0]              victimctl_req_vc0;
  wire [7:0]              victimctl_arb_vc0;
  wire [NUM_CPUS:0]       rr_req_vc0;
  wire                    rr_req_en_vc0;
  wire [NUM_CPUS+ACP-1:0] rr_arb_vc0;
  wire                    victimctl_valid_vc0;
  wire                    victimctl_en_vc0;
  wire                    victimctl_id_en_vc0;
  wire [10:0]             victimctl_addr_vc0;
  wire                    victimctl_wr_vc0;
  wire [31:0]             victimctl_wdata_vc0;
  wire [15:0]             victimctl_strb_vc0;
  wire                    victimctl_slv_age_vc0;
  wire                    victimctl_slv_iside_vc0;
  wire                    victimctl_slv_nontemp_vc0;
  wire [1:0]              victimctl_slv_new_age_vc0;
  wire [5:0]              victimctl_id_vc0;
  wire [15:0]             victimctl_way_used_vc2;
  wire                    victimctl_disable_vc2;
  wire [15:0]             victimctl_age0_vc3;
  wire [15:0]             victimctl_age1_vc3;
  wire [15:0]             victimctl_age2_vc3;
  wire [15:0]             victimctl_age3_vc3;
  wire [31:0]             victimctl_aged_data_vc3;
  wire                    victimctl_ageing_required_vc3;
  wire [1:0]              victimctl_age_amount_vc3;
  wire [3:0]              next_age_round_robin_vc3;
  wire [15:0]             victim_sel_age0_vc3;
  wire [15:0]             victim_sel_age1_vc3;
  wire [15:0]             victim_sel_age2_vc3;
  wire [15:0]             victim_sel_age3_vc3;
  wire [15:0]             victim_arb_age0_vc3;
  wire [15:0]             victim_arb_age1_vc3;
  wire [15:0]             victim_arb_age2_vc3;
  wire [15:0]             victim_arb_age3_vc3;
  wire [15:0]             victim_oldest_way_vc3;
  wire                    victimram_no_acc_in_2cycles;
  wire [4:0]              victimctl_ready;
  wire [3:0]              next_victimctl_way_vc4;

  //----------------------------------------------------------------------------
  // Clocking and reset
  //----------------------------------------------------------------------------

  assign victimctl_active = (|victimctl_req_vc0 |
                             victimctl_en_vc1 |
                             victimctl_valid_vc0 |
                             victimctl_valid_vc1 |
                             victimctl_valid_vc2 |
                             victimctl_valid_vc3 |
                             victimctl_valid_vc4 |
                             inval_all);

  assign next_clk_enable = (cpuslv0_victimctl_active_i |
                            cpuslv1_victimctl_active_i |
                            cpuslv2_victimctl_active_i |
                            cpuslv3_victimctl_active_i |
                            acpslv_victimctl_active_i |
                            victimctl_active |
                            gov_mbistreq_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b1;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate (
    .clk_i         (clk),
    .clk_enable_i  (clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_victimctl));


  always @(posedge clk_victimctl or negedge reset_n)
  if (~reset_n) begin
    victimctl_mbistreq <= 1'b0;
  end else begin
    victimctl_mbistreq <= gov_mbistreq_i;
  end

  // The victim RAM needs to be invalidated on reset, because it is not
  // qualified with the tags being valid when it is looked up normally.
  assign next_inval_all = victimctl_mbistreq ? 1'b0 :
                          leaving_reset_i ? ~config_l2rstdisable_i :
                                            (inval_all & ~inval_all_complete);

  always @(posedge clk_victimctl or negedge reset_n)
  if (~reset_n) begin
    inval_all <= 1'b0;
  end else begin
    inval_all <= next_inval_all;
  end

  assign victimctl_inv_all_addr_vc0 = victimctl_addr_vc1 + 11'h001;

  assign inval_all_complete = (&(victimctl_addr_vc1[10:7] | ~config_l2_size_i) &
                               (&victimctl_addr_vc1[6:1]) & ~victimctl_addr_vc1[0]);

  //----------------------------------------------------------------------------
  //  Request arbitration
  //----------------------------------------------------------------------------

  assign victimctl_req_vc0 = {acpslv_victimctl_valid_i,
                              cpuslv3_victimctl_valid_i,
                              cpuslv2_victimctl_valid_i,
                              cpuslv1_victimctl_valid_i,
                              cpuslv0_victimctl_valid_i} & ~victimctl_ready;

  // Compress the request down to remove cpus that cannot be active, to ensure
  // the arbiter is not unfair.
  assign rr_req_vc0 = {victimctl_req_vc0[4], victimctl_req_vc0[NUM_CPUS-1:0]};

  assign rr_req_en_vc0 = |victimctl_req_vc0 & ~|victimctl_arb_vc0[7:5];

  ca53_rr_reg_arb #(.WIDTH(NUM_CPUS + ACP)) u_slv_arb (
    .clk        (clk_victimctl),
    .reset_n    (reset_n),
    .enable_i   (rr_req_en_vc0),
    .requests_i (rr_req_vc0[NUM_CPUS+ACP-1:0]),
    .arb_o      (rr_arb_vc0)
  );

  // Decompress the granted slv.
  for (i = 0; i < 4; i = i + 1) begin : g_cpu_arb
    if (i < NUM_CPUS) begin : g_cpu
      assign victimctl_arb_vc0[i] = rr_arb_vc0[i] & ~|victimctl_arb_vc0[7:5];
    end else begin : g_n_cpu
      assign victimctl_arb_vc0[i] = 1'b0;
    end
  end

  if (ACP) begin : g_acp
    assign victimctl_arb_vc0[4] = rr_arb_vc0[NUM_CPUS] & ~|victimctl_arb_vc0[7:5];
  end else begin : g_n_acp
    assign victimctl_arb_vc0[4] = 1'b0;
  end

  assign victimctl_arb_vc0[5] = victimctl_ageing_required_vc3 & ~victimctl_mbistreq;
  assign victimctl_arb_vc0[6] = inval_all & ~victimctl_mbistreq;
  assign victimctl_arb_vc0[7] = victimctl_mbistreq;

  // Only reads of the RAM are marked as valid, because for writes once the RAM
  // is enabled nothing else needs to be done. MBIST must be marked as valid so
  // the the registers capturing the RAM output are enabled.
  assign victimctl_valid_vc0 = ((|victimctl_req_vc0 &
                                 ~victimctl_wr_vc0 &
                                 ~victimctl_ageing_required_vc3) |
                                victimctl_mbistreq);

  assign victimctl_en_vc0 = (victimctl_mbistreq ? ((&gov_mbistarray0_i[6:5] | gov_mbistcfg0_i) &
                                                   (gov_mbistreaden0_i | gov_mbistwriteen0_i)) :
                                                  ((inval_all & ~gov_l2_in_retention_i) |
                                                   (|victimctl_req_vc0) |
                                                   victimctl_ageing_required_vc3));

  assign victimctl_addr_vc0 = (({11{victimctl_arb_vc0[7]}} & gov_mbistaddr0_i[10:0]) |
                               ({11{victimctl_arb_vc0[6]}} & victimctl_inv_all_addr_vc0) |
                               ({11{victimctl_arb_vc0[5]}} & victimctl_addr_vc3) |
                               ({11{victimctl_arb_vc0[4]}} &  acpslv_victimctl_index_i) |
                               ({11{victimctl_arb_vc0[3]}} & cpuslv3_victimctl_index_i) |
                               ({11{victimctl_arb_vc0[2]}} & cpuslv2_victimctl_index_i) |
                               ({11{victimctl_arb_vc0[1]}} & cpuslv1_victimctl_index_i) |
                               ({11{victimctl_arb_vc0[0]}} & cpuslv0_victimctl_index_i));

  assign victimctl_wr_vc0 = ((victimctl_arb_vc0[7] & gov_mbistwriteen0_i) |
                             (victimctl_arb_vc0[6]) |
                             (victimctl_arb_vc0[5]) |
                             (victimctl_arb_vc0[4] &  acpslv_victimctl_wr_i) |
                             (victimctl_arb_vc0[3] & cpuslv3_victimctl_wr_i) |
                             (victimctl_arb_vc0[2] & cpuslv2_victimctl_wr_i) |
                             (victimctl_arb_vc0[1] & cpuslv1_victimctl_wr_i) |
                             (victimctl_arb_vc0[0] & cpuslv0_victimctl_wr_i));

  assign victimctl_slv_age_vc0 = ((victimctl_arb_vc0[4] &  acpslv_victimctl_age_i) |
                                  (victimctl_arb_vc0[3] & cpuslv3_victimctl_age_i) |
                                  (victimctl_arb_vc0[2] & cpuslv2_victimctl_age_i) |
                                  (victimctl_arb_vc0[1] & cpuslv1_victimctl_age_i) |
                                  (victimctl_arb_vc0[0] & cpuslv0_victimctl_age_i));

  assign victimctl_slv_iside_vc0 = ((victimctl_arb_vc0[3] & cpuslv3_victimctl_iside_i) |
                                    (victimctl_arb_vc0[2] & cpuslv2_victimctl_iside_i) |
                                    (victimctl_arb_vc0[1] & cpuslv1_victimctl_iside_i) |
                                    (victimctl_arb_vc0[0] & cpuslv0_victimctl_iside_i));

  assign victimctl_slv_nontemp_vc0 = ((victimctl_arb_vc0[3] & cpuslv3_victimctl_nontemp_i) |
                                      (victimctl_arb_vc0[2] & cpuslv2_victimctl_nontemp_i) |
                                      (victimctl_arb_vc0[1] & cpuslv1_victimctl_nontemp_i) |
                                      (victimctl_arb_vc0[0] & cpuslv0_victimctl_nontemp_i));

  // Non-temporal data is always inserted as the oldest age, and recently
  // accessed data is always inserted as the newest age. The rest is inserted
  // in the middle, depending on the settings in the L2ACTLR.
  assign victimctl_slv_new_age_vc0 = (victimctl_slv_nontemp_vc0                        ? 2'b00 :
                                      victimctl_slv_age_vc0                            ? 2'b11 :
                                      (victimctl_slv_iside_vc0 ? ~gov_l2victim_ctl_i[0] :
                                                                 ~|gov_l2victim_ctl_i) ? 2'b10 :
                                                                                         2'b01);

  assign victimctl_wdata_vc0 = (({32{victimctl_arb_vc0[7]}}    & gov_mbistindata0_i[31:0]) |
                                ({32{victimctl_arb_vc0[5]}}    & victimctl_aged_data_vc3) |
                                ({32{|victimctl_arb_vc0[4:0]}} & {16{victimctl_slv_new_age_vc0}}));

  assign victimctl_strb_vc0 = (({16{victimctl_arb_vc0[7]}} & ({16{gov_mbistwriteen0_i}} & gov_mbistbe0_i[15:0])) |
                               ({16{victimctl_arb_vc0[6]}}) |
                               ({16{victimctl_arb_vc0[5]}}) |
                               ({16{victimctl_arb_vc0[4]}} & {16{ acpslv_victimctl_wr_i}} & (16'h0001 <<  acpslv_victimctl_way_i)) |
                               ({16{victimctl_arb_vc0[3]}} & {16{cpuslv3_victimctl_wr_i}} & (16'h0001 << cpuslv3_victimctl_way_i)) |
                               ({16{victimctl_arb_vc0[2]}} & {16{cpuslv2_victimctl_wr_i}} & (16'h0001 << cpuslv2_victimctl_way_i)) |
                               ({16{victimctl_arb_vc0[1]}} & {16{cpuslv1_victimctl_wr_i}} & (16'h0001 << cpuslv1_victimctl_way_i)) |
                               ({16{victimctl_arb_vc0[0]}} & {16{cpuslv0_victimctl_wr_i}} & (16'h0001 << cpuslv0_victimctl_way_i)));

  assign victimctl_id_vc0 = (({6{victimctl_arb_vc0[7]}} & {&gov_mbistarray0_i[6:5], 5'b00000}) |
                             ({6{victimctl_arb_vc0[6]}} & 6'b111111) |
                             ({6{victimctl_arb_vc0[5]}} & 6'b111111) |
                             ({6{victimctl_arb_vc0[4]}} & {3'b100,  acpslv_victimctl_id_i}) |
                             ({6{victimctl_arb_vc0[3]}} & {3'b011, cpuslv3_victimctl_id_i}) |
                             ({6{victimctl_arb_vc0[2]}} & {3'b010, cpuslv2_victimctl_id_i}) |
                             ({6{victimctl_arb_vc0[1]}} & {3'b001, cpuslv1_victimctl_id_i}) |
                             ({6{victimctl_arb_vc0[0]}} & {3'b000, cpuslv0_victimctl_id_i}));

  //----------------------------------------------------------------------------
  //  Pipeline requests, and drive RAM
  //----------------------------------------------------------------------------

  always @(posedge clk_victimctl or negedge reset_n)
  if (~reset_n) begin
    victimctl_en_vc1    <= 1'b0;
    victimctl_valid_vc1 <= 1'b0;
    victimctl_valid_vc2 <= 1'b0;
    victimctl_valid_vc3 <= 1'b0;
    victimctl_valid_vc4 <= 1'b0;
  end else if (victimctl_active) begin
    victimctl_en_vc1    <= victimctl_en_vc0;
    victimctl_valid_vc1 <= victimctl_valid_vc0;
    victimctl_valid_vc2 <= victimctl_valid_vc1;
    victimctl_valid_vc3 <= victimctl_valid_vc2;
    victimctl_valid_vc4 <= victimctl_valid_vc3;
  end

  always @(posedge clk_victimctl or negedge reset_n)
  if (~reset_n) begin
    victimctl_addr_vc1  <= {11{1'b1}};
  end else if (victimctl_en_vc0) begin
    victimctl_addr_vc1  <= victimctl_addr_vc0;
  end

  always @(posedge clk_victimctl)
  if (victimctl_en_vc0) begin
    victimctl_wr_vc1    <= victimctl_wr_vc0;
    victimctl_wdata_vc1 <= victimctl_wdata_vc0;
    victimctl_strb_vc1  <= victimctl_strb_vc0;
  end

  // The ID must be clocked separately because it is also used in MBIST.
  assign victimctl_id_en_vc0 = victimctl_en_vc0 | victimctl_mbistreq;

  always @(posedge clk_victimctl)
  if (victimctl_id_en_vc0) begin
    victimctl_id_vc1 <= victimctl_id_vc0;
  end

  assign l2_victimram_clken_o = victimctl_en_vc1;
  assign l2_victimram_en_o    = victimctl_en_vc1 & ~DFTRAMHOLD;
  assign l2_victimram_addr_o  = victimctl_addr_vc1;
  assign l2_victimram_wr_o    = victimctl_wr_vc1;
  assign l2_victimram_wdata_o = victimctl_wdata_vc1;
  assign l2_victimram_strb_o  = victimctl_strb_vc1;

  // Indicate that the L2 Victim RAMs are not likely to be accessed in 2-cycles.
  // Once pipelined a registered signal can be provided to the RAM instances
  // that an access will not happen in the next cycle and a light-sleep mode
  // is possible.
  assign victimram_no_acc_in_2cycles = (ram_idle_count_max_i | victimram_no_acc_next_cycle) & ~next_clk_enable;

  // This needs to be on the main SCU clock, because it will get asserted only
  // after all victim RAM activity has finished.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    victimram_no_acc_next_cycle <= 1'b0;
  end else begin
    victimram_no_acc_next_cycle <= victimram_no_acc_in_2cycles;
  end

  assign l2_victimram_no_acc_next_cycle_o = victimram_no_acc_next_cycle;

  // Tell the slv if its request was accepted.
  for (i = 0; i < 5; i = i + 1) begin : g_ready
    assign victimctl_ready[i] = victimctl_en_vc1 & (victimctl_id_vc1[5:3] == i[2:0]);
  end

  assign victimctl_ready_o = victimctl_en_vc1;
  assign victimctl_ready_id_o = victimctl_id_vc1;

  always @(posedge clk_victimctl)
  if (victimctl_valid_vc1) begin
    victimctl_addr_vc2 <= victimctl_addr_vc1;
    victimctl_id_vc2   <= victimctl_id_vc1;
  end

  // Capture the RAM output.
  always @(posedge clk_victimctl)
  if (victimctl_valid_vc2) begin
    victimctl_rdata_vc3 <= l2_victimram_rdata_i;
    victimctl_addr_vc3  <= victimctl_addr_vc2;
    victimctl_id_vc3    <= victimctl_id_vc2;
  end

  assign victimctl_mbist_sel_o = victimctl_id_vc3[5];
  assign victimctl_mbistoutdata_o = victimctl_rdata_vc3;

  //----------------------------------------------------------------------------
  //  Pick a victim
  //----------------------------------------------------------------------------

  // Send the index to the slvs, so they can indicate in the following cycle if
  // any ways are currently in use for that index.
  assign victimctl_index_vc1_o = victimctl_addr_vc1;

  assign victimctl_way_used_vc2 = (cpuslv0_l2_way_used_vc2_i |
                                   cpuslv1_l2_way_used_vc2_i |
                                   cpuslv2_l2_way_used_vc2_i |
                                   cpuslv3_l2_way_used_vc2_i |
                                   acpslv_l2_way_used_vc2_i |
                                   snpslv_l2_way_used_vc2_i);

  assign victimctl_disable_vc2 = &gov_l2victim_ctl_i;

  always @(posedge clk_victimctl)
  if (victimctl_valid_vc2) begin
    victimctl_way_used_vc3 <= victimctl_way_used_vc2;
    victimctl_disable_vc3  <= victimctl_disable_vc2;
  end

  for (i = 0; i < 16; i = i + 1) begin : g_victim_age

    // Find the age of each way.
    assign victimctl_age0_vc3[i] = (victimctl_rdata_vc3[2*i+:2] == 2'b00) | victimctl_disable_vc3;
    assign victimctl_age1_vc3[i] = (victimctl_rdata_vc3[2*i+:2] == 2'b01);
    assign victimctl_age2_vc3[i] = (victimctl_rdata_vc3[2*i+:2] == 2'b10);
    assign victimctl_age3_vc3[i] = (victimctl_rdata_vc3[2*i+:2] == 2'b11);

    // Adjust the age of each way so that there is at least one way set to the
    // oldest age.
    assign victimctl_aged_data_vc3[2*i+:2] = victimctl_rdata_vc3[2*i+:2] - victimctl_age_amount_vc3;

  end

  // If there are no entries of the oldest age, then we need to age all the
  // ways and write back the updated values to the RAM.
  assign victimctl_ageing_required_vc3 = victimctl_valid_vc3 & ~|victimctl_age0_vc3;

  assign victimctl_age_amount_vc3 = (|victimctl_age0_vc3 ? 2'b00 :
                                     |victimctl_age1_vc3 ? 2'b01 :
                                     |victimctl_age2_vc3 ? 2'b10 :
                                                           2'b11);

  // If there are multiple ways with the oldest age, then select one on a
  // round robin basis, which should give a random way when distributed across
  // all indexes.
  assign next_age_round_robin_vc3 = age_round_robin_vc3 + 4'b0001;

  always @(posedge clk_victimctl or negedge reset_n)
  if (~reset_n) begin
    age_round_robin_vc3 <= 4'b0000;
  end else if (victimctl_valid_vc2) begin
    age_round_robin_vc3 <= next_age_round_robin_vc3;
  end

  // For each age, select one way that is not already being used by a
  // different request.
  assign victim_sel_age0_vc3 = {16{victimctl_valid_vc3}} & victimctl_age0_vc3 & ~victimctl_way_used_vc3;
  assign victim_sel_age1_vc3 = {16{victimctl_valid_vc3}} & victimctl_age1_vc3 & ~victimctl_way_used_vc3;
  assign victim_sel_age2_vc3 = {16{victimctl_valid_vc3}} & victimctl_age2_vc3 & ~victimctl_way_used_vc3;
  assign victim_sel_age3_vc3 = {16{victimctl_valid_vc3}} & victimctl_age3_vc3 & ~victimctl_way_used_vc3;

  ca53_rr_arb #(.WIDTH(16)) u_age0_arb (
    .clk          (clk_victimctl),
    .reset_n      (reset_n),
    .rr_counter_i (age_round_robin_vc3),
    .requests_i   (victim_sel_age0_vc3),
    .arb_o        (victim_arb_age0_vc3)
  );

  ca53_rr_arb #(.WIDTH(16)) u_age1_arb (
    .clk          (clk_victimctl),
    .reset_n      (reset_n),
    .rr_counter_i (age_round_robin_vc3),
    .requests_i   (victim_sel_age1_vc3),
    .arb_o        (victim_arb_age1_vc3)
  );

  ca53_rr_arb #(.WIDTH(16)) u_age2_arb (
    .clk          (clk_victimctl),
    .reset_n      (reset_n),
    .rr_counter_i (age_round_robin_vc3),
    .requests_i   (victim_sel_age2_vc3),
    .arb_o        (victim_arb_age2_vc3)
  );

  ca53_rr_arb #(.WIDTH(16)) u_age3_arb (
    .clk          (clk_victimctl),
    .reset_n      (reset_n),
    .rr_counter_i (age_round_robin_vc3),
    .requests_i   (victim_sel_age3_vc3),
    .arb_o        (victim_arb_age3_vc3)
  );

  // Select a way from the oldest age that has unused valid ways.
  assign victim_oldest_way_vc3 = (|victim_sel_age0_vc3 ? victim_arb_age0_vc3 :
                                  |victim_sel_age1_vc3 ? victim_arb_age1_vc3 :
                                  |victim_sel_age2_vc3 ? victim_arb_age2_vc3 :
                                                         victim_arb_age3_vc3);

  assign next_victimctl_way_vc4 = `CA53_L2_WAY_ENC(victim_oldest_way_vc3);

  always @(posedge clk_victimctl)
  if (victimctl_valid_vc3) begin
    victimctl_id_vc4  <= victimctl_id_vc3;
    victimctl_way_vc4 <= next_victimctl_way_vc4;
  end

  // Tell the slv which way has been picked.
  assign victimctl_ack_o = victimctl_valid_vc4;

  assign victimctl_ack_id_o = victimctl_id_vc4;

  assign victimctl_victim_way_o = victimctl_way_vc4;

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_zero_one_hot #(`OVL_FATAL, 16, `OVL_ASSERT, "Victim way picked must be onehot")
  u_ovl_oldest_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (victimctl_valid_vc3 ? victim_oldest_way_vc3 : 16'h0001)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Victim request must not be made without an earlier active indication")
  u_ovl_active_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|victimctl_req_vc0),
    .consequent_expr (clk_enable)
  );


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_valid_vc3")
  u_ovl_x_victimctl_valid_vc3 (.clk       (clk_victimctl),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (victimctl_valid_vc3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_id_en_vc0")
  u_ovl_x_victimctl_id_en_vc0 (.clk       (clk_victimctl),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (victimctl_id_en_vc0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_active")
  u_ovl_x_victimctl_active (.clk       (clk_victimctl),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (victimctl_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_en_vc0")
  u_ovl_x_victimctl_en_vc0 (.clk       (clk_victimctl),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (victimctl_en_vc0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_valid_vc1")
  u_ovl_x_victimctl_valid_vc1 (.clk       (clk_victimctl),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (victimctl_valid_vc1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: victimctl_valid_vc2")
  u_ovl_x_victimctl_valid_vc2 (.clk       (clk_victimctl),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (victimctl_valid_vc2));


`endif

end else begin : g_n_l2cc

  assign l2_victimram_clken_o = 1'b0;
  assign l2_victimram_en_o = 1'b0;
  assign l2_victimram_wr_o = 1'b0;
  assign l2_victimram_strb_o = {16{1'b0}};
  assign l2_victimram_addr_o = {11{1'b0}};
  assign l2_victimram_wdata_o = {32{1'b0}};
  assign l2_victimram_no_acc_next_cycle_o = 1'b1;
  assign victimctl_ready_o = 1'b0;
  assign victimctl_ready_id_o = {6{1'b0}};
  assign victimctl_ack_o = 1'b0;
  assign victimctl_ack_id_o = {6{1'b0}};
  assign victimctl_victim_way_o = {4{1'b0}};
  assign victimctl_index_vc1_o = {11{1'b0}};
  assign victimctl_mbist_sel_o = 1'b0;
  assign victimctl_mbistoutdata_o = {32{1'b0}};

end endgenerate

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
