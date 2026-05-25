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
//  The L2 data buffer holds a cacheline of data. It can fill from a CPU, ACP,
//  or the L2 RAMs. It can drain to a CPU, ACP, master, or the L2 RAMs.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_l2db #(`CA53_SCU_INT_PARAM_DECL, parameter L2DB_NUM = 4'b0000)
 (
  input  wire         CLKIN,
  input  wire         clk,
  input  wire         reset_n,
  input  wire         DFTSE,

  // AFB control
  output wire         l2db_tagctl_available_o,
  output wire         l2db_tagctl_for_snoop_o,
  output wire         l2db_tagctl_for_write_o,
  input  wire         tagctl_l2db_alloc_i,
  input  wire         tagctl_alloc_for_snoop_i,
  input  wire         tagctl_alloc_for_write_i,
  input  wire         tagctl_l2db_release_i,
  input  wire         tagctl_l2db_snoops_done_i,
  input  wire         tagctl_l2db_fill_strbs_i,

  input  wire         master_afb0_ack_i,
  input  wire         master_afb1_ack_i,
  input  wire         master_afb2_ack_i,
  input  wire         master_afb3_ack_i,
  input  wire         master_afb4_ack_i,
  input  wire         master_afb5_ack_i,
  input  wire [3:0]   master_afb_waddr_id_i,

  input  wire         master_rsp_dbid_valid_i,
  input  wire         master_rsp_comp_valid_i,
  input  wire [6:0]   master_rsp_txnid_i,
  input  wire [7:0]   master_rsp_dbid_i,
  input  wire [6:0]   master_rsp_srcid_i,

  output wire         l2db_full_line_o,
  output wire         l2db_rmw_line_o,

  // CPU, ACP, and snoop slv control
  input  wire         cpuslv0_l2dbs_active_i,
  input  wire         cpuslv0_l2db_transfer_i,
  input  wire [2:0]   cpuslv0_l2db_transfer_type_i,
  input  wire [23:0]  cpuslv0_l2db_transfer_info_i,
  input  wire         cpuslv0_l2db_release_i,

  input  wire         cpuslv1_l2dbs_active_i,
  input  wire         cpuslv1_l2db_transfer_i,
  input  wire [2:0]   cpuslv1_l2db_transfer_type_i,
  input  wire [23:0]  cpuslv1_l2db_transfer_info_i,
  input  wire         cpuslv1_l2db_release_i,

  input  wire         cpuslv2_l2dbs_active_i,
  input  wire         cpuslv2_l2db_transfer_i,
  input  wire [2:0]   cpuslv2_l2db_transfer_type_i,
  input  wire [23:0]  cpuslv2_l2db_transfer_info_i,
  input  wire         cpuslv2_l2db_release_i,

  input  wire         cpuslv3_l2dbs_active_i,
  input  wire         cpuslv3_l2db_transfer_i,
  input  wire [2:0]   cpuslv3_l2db_transfer_type_i,
  input  wire [23:0]  cpuslv3_l2db_transfer_info_i,
  input  wire         cpuslv3_l2db_release_i,

  input  wire         acpslv_l2dbs_active_i,
  input  wire         acpslv_l2db_transfer_i,
  input  wire [2:0]   acpslv_l2db_transfer_type_i,
  input  wire [25:0]  acpslv_l2db_transfer_info_i,
  input  wire         acpslv_l2db_release_i,

  input  wire         snpslv_l2dbs_active_i,
  input  wire         snpslv_l2db_transfer_i,
  input  wire [2:0]   snpslv_l2db_transfer_type_i,
  input  wire [28:0]  snpslv_l2db_transfer_info_i,
  input  wire         snpslv_l2db_release_i,
  input  wire         snpslv_l2db_invalidate_i,
  input  wire         snpslv_l2db_makeshared_i,

  input  wire         afb0_l2dbs_transfer_i,
  input  wire [3:0]   afb0_l2dbs_id_i,
  input  wire [23:0]  afb0_l2dbs_transfer_info_i,

  input  wire         afb1_l2dbs_transfer_i,
  input  wire [3:0]   afb1_l2dbs_id_i,
  input  wire [23:0]  afb1_l2dbs_transfer_info_i,

  input  wire         afb2_l2dbs_transfer_i,
  input  wire [3:0]   afb2_l2dbs_id_i,
  input  wire [23:0]  afb2_l2dbs_transfer_info_i,

  input  wire         afb3_l2dbs_transfer_i,
  input  wire [3:0]   afb3_l2dbs_id_i,
  input  wire [23:0]  afb3_l2dbs_transfer_info_i,

  input  wire         afb4_l2dbs_transfer_i,
  input  wire [3:0]   afb4_l2dbs_id_i,
  input  wire [23:0]  afb4_l2dbs_transfer_info_i,

  input  wire         afb5_l2dbs_transfer_i,
  input  wire [3:0]   afb5_l2dbs_id_i,
  input  wire [23:0]  afb5_l2dbs_transfer_info_i,

  output wire         l2db_slv_done_o,
  output wire         l2db_snpslv_done_o,
  output wire         l2db_slv_master_arb_o,

  // Master write requests
  output wire         l2db_master_valid_o,
  output wire [5:0]   l2db_master_id_o,
  output wire [7:0]   l2db_master_dbid_o,
  output wire [6:0]   l2db_master_tgtid_o,
  output wire [3:0]   l2db_master_qos_o,
  output wire         l2db_master_snoop_o,
  output wire [127:0] l2db_master_data_o,
  output wire [15:0]  l2db_master_strb_o,
  output wire [1:0]   l2db_master_chunk_o,
  output wire         l2db_master_last_o,
  output wire [2:0]   l2db_master_opcode_o,
  output wire [2:0]   l2db_master_snpresp_o,
  output wire [1:0]   l2db_master_len_o,
  output wire [2:0]   l2db_master_size_o,
  output wire [5:0]   l2db_master_addr_o,
  output wire [7:0]   l2db_master_attrs_o,
  output wire         l2db_master_prot_o,
  output wire         l2db_master_strex_o,
  output wire         l2db_master_unique_o,
  output wire         l2db_master_err_o,
  input  wire         master_l2db_ready_i,
  output wire         l2db_master_invalidated_o,
  output wire         l2db_master_dirty_o,

  // L2 RAM controller requests
  output wire         l2db_ramctl_valid_o,
  output wire [1:0]   l2db_ramctl_rw_o,
  output wire [10:0]  l2db_ramctl_index_o,
  output wire [3:0]   l2db_ramctl_way_o,
  output wire [255:0] l2db_ramctl_data_o,
  output wire [7:0]   l2db_ramctl_banks_o,
  output wire         l2db_ramctl_err_o,
  input  wire         ramctl_l2db_ready_i,

  // CPU and ACP slv data requests
  output wire         l2db_slv_valid_o,
  output wire [5:0]   l2db_slv_id_o,
  output wire [4:0]   l2db_slv_biuid_o,
  output wire [127:0] l2db_slv_data_o,
  output wire [1:0]   l2db_slv_chunk_o,
  output wire         l2db_slv_last_o,
  output wire         l2db_slv_bypass_o,
  output wire         l2db_slv_err_o,
  input  wire         cpuslv0_l2db_ready_i,
  input  wire         cpuslv1_l2db_ready_i,
  input  wire         cpuslv2_l2db_ready_i,
  input  wire         cpuslv3_l2db_ready_i,
  input  wire         acpslv_l2db_ready_i,

  // Master read data
  input  wire         master_early_dr_valid_i,
  input  wire [5:0]   master_early_dr_id_i,
  input  wire [1:0]   master_early_dr_chunk_i,
  input  wire [127:0] master_early_dr_data_i,

  // L2 RAM controller read data
  input  wire         ramctl_l2dbs_valid_i,
  input  wire [3:0]   ramctl_l2dbs_id_i,
  input  wire [255:0] ramctl_l2dbs_data_i,
  input  wire [1:0]   ramctl_l2dbs_chunk_i,
  input  wire         ramctl_l2dbs_err_i,
  input  wire         ramctl_l2dbs_last_i,
  input  wire         ramctl_l2dbs_bypass_i,
  input  wire [3:0]   ramctl_l2dbs_bypass_id_i,
  input  wire         ramctl_bypassed_err_i,

  // CPU and ACP slv write data
  input  wire         cpuslv0_l2dbs_dw_valid_i,
  input  wire [3:0]   cpuslv0_l2dbs_dw_id_i,
  input  wire [3:0]   cpuslv0_l2dbs_dw_chunks_valid_i,
  input  wire         cpuslv0_l2dbs_dw_last_i,
  input  wire [255:0] cpuslv0_l2dbs_dw_data_i,
  input  wire [31:0]  cpuslv0_l2dbs_dw_strb_i,
  input  wire         cpuslv0_l2dbs_dw_err_i,
  input  wire         cpuslv0_l2dbs_dw_fatal_i,

  input  wire         cpuslv1_l2dbs_dw_valid_i,
  input  wire [3:0]   cpuslv1_l2dbs_dw_id_i,
  input  wire [3:0]   cpuslv1_l2dbs_dw_chunks_valid_i,
  input  wire         cpuslv1_l2dbs_dw_last_i,
  input  wire [255:0] cpuslv1_l2dbs_dw_data_i,
  input  wire [31:0]  cpuslv1_l2dbs_dw_strb_i,
  input  wire         cpuslv1_l2dbs_dw_err_i,
  input  wire         cpuslv1_l2dbs_dw_fatal_i,

  input  wire         cpuslv2_l2dbs_dw_valid_i,
  input  wire [3:0]   cpuslv2_l2dbs_dw_id_i,
  input  wire [3:0]   cpuslv2_l2dbs_dw_chunks_valid_i,
  input  wire         cpuslv2_l2dbs_dw_last_i,
  input  wire [255:0] cpuslv2_l2dbs_dw_data_i,
  input  wire [31:0]  cpuslv2_l2dbs_dw_strb_i,
  input  wire         cpuslv2_l2dbs_dw_err_i,
  input  wire         cpuslv2_l2dbs_dw_fatal_i,

  input  wire         cpuslv3_l2dbs_dw_valid_i,
  input  wire [3:0]   cpuslv3_l2dbs_dw_id_i,
  input  wire [3:0]   cpuslv3_l2dbs_dw_chunks_valid_i,
  input  wire         cpuslv3_l2dbs_dw_last_i,
  input  wire [255:0] cpuslv3_l2dbs_dw_data_i,
  input  wire [31:0]  cpuslv3_l2dbs_dw_strb_i,
  input  wire         cpuslv3_l2dbs_dw_err_i,
  input  wire         cpuslv3_l2dbs_dw_fatal_i,

  input  wire         acpslv_l2dbs_dw_valid_i,
  input  wire [3:0]   acpslv_l2dbs_dw_id_i,
  input  wire [1:0]   acpslv_l2dbs_dw_chunk_i,
  input  wire         acpslv_l2dbs_dw_last_i,
  input  wire [127:0] acpslv_l2dbs_dw_data_i,
  input  wire [15:0]  acpslv_l2dbs_dw_strb_i,

  output wire         l2db_cpuslv0_data_active_o,
  output wire         l2db_cpuslv1_data_active_o,
  output wire         l2db_cpuslv2_data_active_o,
  output wire         l2db_cpuslv3_data_active_o,

  input  wire         gov_mbistreq_i,
  input  wire [8:0]   gov_mbistarray0_i
);

  // These are encoded so that the lower two bits directly control the chunk(s)
  // being sent in some states. The upper two bits can be used to distinguish idle.
  localparam  STATE_IDLE             = 5'b00000;
  localparam  STATE_ALLOCATED        = 5'b01000;
  localparam  STATE_SLV_READ         = 5'b01001;
  localparam  STATE_SLV_FORWARD_WAIT = 5'b01011;
  localparam  STATE_SLV_FORWARD0     = 5'b01100;
  localparam  STATE_SLV_FORWARD1     = 5'b01101;
  localparam  STATE_SLV_FORWARD2     = 5'b01110;
  localparam  STATE_SLV_FORWARD3     = 5'b01111;
  localparam  STATE_RAM_WRITE0       = 5'b10000;
  localparam  STATE_RAM_WRITE1       = 5'b10010;
  localparam  STATE_RAM_READ         = 5'b10101;
  localparam  STATE_MASTER_COMP      = 5'b10110;
  localparam  STATE_MASTER_WAIT      = 5'b10111;
  localparam  STATE_MASTER_WRITE0    = 5'b11000;
  localparam  STATE_MASTER_WRITE1    = 5'b11001;
  localparam  STATE_MASTER_WRITE2    = 5'b11010;
  localparam  STATE_MASTER_WRITE3    = 5'b11011;
  localparam  STATE_MASTER_READ0     = 5'b11100;
  localparam  STATE_MASTER_READ1     = 5'b11101;
  localparam  STATE_MASTER_READ2     = 5'b11110;
  localparam  STATE_MASTER_READ3     = 5'b11111;
  localparam  STATE_X                = 5'bxxxxx;

generate if (L2DB_NUM < NUM_L2DBS) begin : g_l2db
  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  reg [4:0]    l2db_state;
  reg [511:0]  l2db_data;
  reg [63:0]   l2db_strb;
  reg [3:0]    l2db_chunks_valid;
  reg [24:0]   l2db_info;
  reg          l2db_after_ctl;
  reg [1:0]    l2db_beat_ctl;
  reg          l2db_for_snoop;
  reg          l2db_for_write;
  reg          l2db_delay_last_beat;
  reg          l2db_err;
  reg          l2db_ramctl_valid;
  reg          l2db_slv_done;
  reg          clk_enable;
  reg          l2db_mbistreq;
  reg          l2db_slv_bypass;
  reg          l2db_ramctl_err;
  reg          l2db_cpuslv_err;
  reg          l2db_full_line;
  reg          l2db_rmw_line;
  reg [1:0]    l2db_master_write_chunk;
  reg [2:0]    l2db_master_beat_size;
  reg [3:0]    l2db_master_beat_addr;
  reg          last_forward_beat;
  reg          l2db_snp_wait;
  reg          l2db_snp_resend_cu;
  reg [2:0]    l2db_snp_resend_opcode;
  reg [5:0]    l2db_snp_resend_reqbuf;

  wire         clk_l2db;
  wire         next_clk_enable;
  reg [4:0]    next_l2db_state;
  wire         next_l2db_slv_done;
  wire         transfer_req;
  wire [2:0]   transfer_type;
  wire [24:0]  transfer_info;
  wire         l2db_release;
  wire [255:0] l2db_data_halfline;
  wire [127:0] l2db_data_quarterline;
  wire [3:0]   next_l2db_chunks_valid;
  wire         l2db_chunks_valid_en;
  wire [15:0]  master_strb;
  wire [15:0]  size_strb;
  wire         next_l2db_delay_last_beat;
  wire         next_l2db_for_snoop;
  wire         next_l2db_for_write;
  wire         next_l2db_after_ctl;
  wire [1:0]   next_l2db_beat_ctl;
  wire         len_fullline;
  wire         len_halfline;
  wire         next_l2db_full_line;
  wire         next_l2db_rmw_line;
  wire         l2db_master_last;
  wire         slv_accepting_data;
  wire         l2db_slv_valid;
  wire         next_last_forward_beat;
  wire [255:0] next_l2db_data;
  wire [63:0]  next_l2db_strb;
  wire         next_l2db_err;
  wire [2:0]   next_l2db_master_beat_size;
  wire [3:0]   next_l2db_master_beat_addr;
  wire         l2db_data_force_en;
  wire [63:0]  l2db_data_en;
  wire [3:0]   l2db_strb_en;
  wire [31:0]  new_l2db_strb;
  wire [7:0]   ram_write_banks;
  wire [6:0]   data_sel;
  wire [4:0]   l2db_src_slv;
  wire         l2db_state_slv_forward;
  wire         l2db_state_master_write;
  wire         master_read_match;
  wire         ram_read_match;
  wire         slv_read_match;
  wire         read_match;
  wire [1:0]   master_chunk;
  wire [3:0]   chunks_valid;
  wire [3:0]   new_chunks_no_master;
  wire         receiving_last_beat;
  wire         l2db_info_en;
  wire         l2db_waddr_en;
  wire         master_ack;
  wire         l2db_opcode_en;
  wire         l2db_cu_en;
  wire         next_comp_received;
  wire         next_l2db_ramctl_valid;
  wire [7:0]   ram_read_banks;
  wire [24:0]  next_l2db_info;
  wire [6:0]   next_l2db_tgtid;
  wire         next_l2db_slv_bypass;
  wire         next_l2db_ramctl_err;
  wire         next_l2db_cpuslv_err;
  wire [5:0]   afb_transfer;
  wire         l2db_state_en;
  wire [1:0]   next_l2db_master_write_chunk;
  wire         zero;
  wire         next_l2db_snp_wait;
  wire         l2db_resend_afb_transfer;
  wire         l2db_snp_resend_en;
  wire [2:0]   snp_resp;
  reg [2:0]    next_l2db_snp_resend_opcode;
  wire         next_l2db_snp_resend_cu;
  wire [24:0]  afb_resend_info;


  genvar i;


  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  // Avoid clocking the L2DB if it is not in use and there are no requests in
  // the slvs that might allocate it in the next cycle.
  assign next_clk_enable = ((l2db_state != STATE_IDLE) |
                            tagctl_l2db_alloc_i |
                            cpuslv0_l2dbs_active_i |
                            cpuslv1_l2dbs_active_i |
                            cpuslv2_l2dbs_active_i |
                            cpuslv3_l2dbs_active_i |
                            acpslv_l2dbs_active_i |
                            snpslv_l2dbs_active_i |
                            gov_mbistreq_i);

  // This must use CLKIN because the cpuslvs will assert active in tc0 but the
  // main SCU clk may not be active until tc1.
  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b1;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_l2db (
    .clk_i         (clk),
    .clk_enable_i  (clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_l2db));

  assign zero = 1'b0;

  if (L2DB_NUM == 0) begin : g_mbist

    // Only the first L2DB is used during MBIST.
    always @(posedge clk_l2db or negedge reset_n)
    if (~reset_n) begin
      l2db_mbistreq <= 1'b0;
    end else begin
      l2db_mbistreq <= gov_mbistreq_i;
    end

  end else begin : g_n_mbist
    always @*
      l2db_mbistreq = zero;
  end

  //----------------------------------------------------------------------------
  //  Control state machine
  //----------------------------------------------------------------------------

  assign l2db_tagctl_available_o = ~|l2db_state[4:3];

  assign l2db_tagctl_for_snoop_o = |l2db_state[4:3] & l2db_for_snoop;

  assign l2db_tagctl_for_write_o = |l2db_state[4:3] & l2db_for_write;

  assign afb_transfer = {afb5_l2dbs_transfer_i & (afb5_l2dbs_id_i == L2DB_NUM[3:0]),
                         afb4_l2dbs_transfer_i & (afb4_l2dbs_id_i == L2DB_NUM[3:0]),
                         afb3_l2dbs_transfer_i & (afb3_l2dbs_id_i == L2DB_NUM[3:0]),
                         afb2_l2dbs_transfer_i & (afb2_l2dbs_id_i == L2DB_NUM[3:0]),
                         afb1_l2dbs_transfer_i & (afb1_l2dbs_id_i == L2DB_NUM[3:0]),
                         afb0_l2dbs_transfer_i & (afb0_l2dbs_id_i == L2DB_NUM[3:0])};

  // Select the source that is requesting this L2DB performs a transfer. Only
  // one source should be requesting for this L2DB at a time, so we do not need
  // to arbitrate.
  assign transfer_req = (cpuslv0_l2db_transfer_i |
                         cpuslv1_l2db_transfer_i |
                         cpuslv2_l2db_transfer_i |
                         cpuslv3_l2db_transfer_i |
                         acpslv_l2db_transfer_i |
                         snpslv_l2db_transfer_i |
                         (|afb_transfer) |
                         l2db_resend_afb_transfer);

  assign transfer_type = (cpuslv0_l2db_transfer_type_i |
                          cpuslv1_l2db_transfer_type_i |
                          cpuslv2_l2db_transfer_type_i |
                          cpuslv3_l2db_transfer_type_i |
                          acpslv_l2db_transfer_type_i |
                          snpslv_l2db_transfer_type_i |
                          ({3{|afb_transfer |
                              l2db_resend_afb_transfer}} & `CA53_L2DB_TRNSFR_L2DB_MASTER));

  assign afb_resend_info = {1'b0, l2db_snp_resend_cu, 2'b01, 1'b1, 1'b0, l2db_snp_resend_opcode, 8'h00, 2'b00, l2db_snp_resend_reqbuf};

  assign transfer_info = ({1'b0, cpuslv0_l2db_transfer_info_i} |
                          {1'b0, cpuslv1_l2db_transfer_info_i} |
                          {1'b0, cpuslv2_l2db_transfer_info_i} |
                          {1'b0, cpuslv3_l2db_transfer_info_i} |
                          {1'b0, acpslv_l2db_transfer_info_i[23:0]} |
                          snpslv_l2db_transfer_info_i[24:0] |
                          ({25{afb_transfer[0]}} & {1'b0, afb0_l2dbs_transfer_info_i}) |
                          ({25{afb_transfer[1]}} & {1'b0, afb1_l2dbs_transfer_info_i}) |
                          ({25{afb_transfer[2]}} & {1'b0, afb2_l2dbs_transfer_info_i}) |
                          ({25{afb_transfer[3]}} & {1'b0, afb3_l2dbs_transfer_info_i}) |
                          ({25{afb_transfer[4]}} & {1'b0, afb4_l2dbs_transfer_info_i}) |
                          ({25{afb_transfer[5]}} & {1'b0, afb5_l2dbs_transfer_info_i}) |
                          ({25{l2db_resend_afb_transfer}} & afb_resend_info));

  assign l2db_release = (tagctl_l2db_release_i |
                         snpslv_l2db_release_i |
                         acpslv_l2db_release_i |
                         cpuslv0_l2db_release_i |
                         cpuslv1_l2db_release_i |
                         cpuslv2_l2db_release_i |
                         cpuslv3_l2db_release_i);

  // If a forwarding transfer is started, we must not send the last beat of
  // data until the AFB tells us that all snoops associated with the transaction
  // have completed. This ensures that a CPU cannot make a write observable
  // until all invalidates of other copies have taken place. This is only used
  // on the first transfer of a primary request.
  assign next_l2db_delay_last_beat = (tagctl_l2db_alloc_i |
                                      (l2db_delay_last_beat &
                                       ~(transfer_req & ~transfer_info[`CA53_L2DB_INFO_DELAY_LAST]) &
                                       ~tagctl_l2db_snoops_done_i));

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_delay_last_beat <= next_l2db_delay_last_beat;
  end

  // The L2DB must store if it is allocated for a snoop or not, so that we can
  // ensure that not all L2DBs are allocated to non-snoops.
  // Similarly we do not want all remaining L2DBs allocated to writes.
  assign next_l2db_for_snoop = (l2db_state == STATE_IDLE) ? tagctl_alloc_for_snoop_i : l2db_for_snoop;
  assign next_l2db_for_write = (l2db_state == STATE_IDLE) ? tagctl_alloc_for_write_i : l2db_for_write;

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_for_snoop <= next_l2db_for_snoop;
    l2db_for_write <= next_l2db_for_write;
  end

  // Store control information needed to decide what to do after the first
  // transfer is finished. For RAM writes, it indicates whether a RAM read
  // is required after the write. For forwarding, it indicates if the data
  // is coming from L2.
  assign next_l2db_after_ctl = ((transfer_type == `CA53_L2DB_TRNSFR_RAM_SWAP) |
                                (transfer_type == `CA53_L2DB_TRNSFR_RAM_SLV));

  always @(posedge clk_l2db)
  if (transfer_req) begin
    l2db_after_ctl <= next_l2db_after_ctl;
  end

  if (ACP) begin : g_acp

    assign next_l2db_beat_ctl = acpslv_l2db_transfer_i ? acpslv_l2db_transfer_info_i[`CA53_L2DB_INFO_BEAT_CTL] : 2'b00;

    always @(posedge clk_l2db)
    if (transfer_req) begin
      l2db_beat_ctl <= next_l2db_beat_ctl;
    end

  end else begin : g_n_acp

    always @*
      l2db_beat_ctl = {2{zero}};

  end

  assign next_l2db_info = {transfer_info[24],
                           transfer_req & transfer_info[23],
                           transfer_info[22:19],
                           transfer_req ? transfer_info[18:16] : `CA53_DATA_OPCODE_INVALID,
                           l2db_mbistreq ? {3'b000, gov_mbistarray0_i[8:7], transfer_info[10:8]} :
                           transfer_req ? transfer_info[15:8] : master_rsp_dbid_i,
                           transfer_info[7:6],
                           transfer_req ? transfer_info[5:0] : {l2db_info[4:3], master_afb_waddr_id_i}};

  assign l2db_info_en = transfer_req | l2db_mbistreq;

  // The lower bits may need to be updated when the master provides more information.
  assign l2db_waddr_en = l2db_info_en | master_ack;

  if (ACE) begin : g_ace

    assign master_ack = ((l2db_state == STATE_MASTER_WAIT) & 
                         ((master_afb0_ack_i & (l2db_info[2:0] == 3'b000)) |
                          (master_afb1_ack_i & (l2db_info[2:0] == 3'b001)) |
                          (master_afb2_ack_i & (l2db_info[2:0] == 3'b010)) |
                          (master_afb3_ack_i & (l2db_info[2:0] == 3'b011)) |
                          (master_afb4_ack_i & (l2db_info[2:0] == 3'b100)) |
                          (master_afb5_ack_i & (l2db_info[2:0] == 3'b101))));

    always @(posedge clk_l2db)
    if (l2db_info_en) begin
      l2db_info[24:6] <= next_l2db_info[24:6];
    end

    always @(posedge clk_l2db)
    if (l2db_waddr_en) begin
      l2db_info[5:0] <= next_l2db_info[5:0];
    end

    assign l2db_master_tgtid_o = {7{1'b0}};
    assign l2db_master_qos_o = {4{1'b0}};
    assign next_comp_received = 1'b1;
    assign l2db_opcode_en = 1'b0;
    assign l2db_cu_en = 1'b0;

  end else begin : g_skyros
    reg [6:0] l2db_tgtid;
    reg [3:0] l2db_qos;
    reg       comp_received;
    wire      master_rsp_match;

    assign master_rsp_match = ((master_rsp_txnid_i == {3'b100, L2DB_NUM[3:0]}) |
                               (master_rsp_txnid_i == {1'b0, l2db_info[5:0]}));

    assign master_ack = ((l2db_state == STATE_MASTER_WAIT) &
                         (master_rsp_dbid_valid_i |
                          (master_rsp_comp_valid_i &
                           (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_EVICT))) &
                         master_rsp_match);

    assign next_comp_received = ((comp_received |
                                  ((l2db_state_master_write |
                                    (l2db_state == STATE_MASTER_WAIT) |
                                    (l2db_state == STATE_MASTER_COMP)) &
                                   master_rsp_comp_valid_i & master_rsp_match)) &
                                 (l2db_state != STATE_IDLE));

    always @(posedge clk_l2db or negedge reset_n)
    if (~reset_n) begin
      comp_received <= 1'b0;
    end else if (l2db_state_en) begin
      comp_received <= next_comp_received;
    end

    assign l2db_cu_en = l2db_info_en | snpslv_l2db_makeshared_i;

    always @(posedge clk_l2db)
    if (l2db_cu_en) begin
      l2db_info[23] <= next_l2db_info[23];
    end

    always @(posedge clk_l2db)
    if (l2db_info_en) begin
      l2db_info[24]    <= next_l2db_info[24];
      l2db_info[22:19] <= next_l2db_info[22:19];
    end

    assign l2db_opcode_en = l2db_info_en | snpslv_l2db_invalidate_i;

    always @(posedge clk_l2db)
    if (l2db_opcode_en) begin
      l2db_info[18:16] <= next_l2db_info[18:16];
    end

    assign next_l2db_tgtid = transfer_req ? {transfer_info[19], transfer_info[5:0]} : master_rsp_srcid_i;

    always @(posedge clk_l2db)
    if (l2db_waddr_en) begin
      l2db_info[15:8] <= next_l2db_info[15:8];
      l2db_tgtid <= next_l2db_tgtid;
    end

    always @(posedge clk_l2db)
    if (l2db_info_en) begin
      l2db_info[7:0] <= next_l2db_info[7:0];
      l2db_qos       <= snpslv_l2db_transfer_info_i[`CA53_L2DB_INFO_MASTER_QOS];
    end

    always @(posedge clk_l2db)
    if (l2db_waddr_en) begin
    end
  
    assign l2db_master_tgtid_o = l2db_tgtid;
    assign l2db_master_qos_o   = l2db_qos;

  end

  always @*
  begin
    next_l2db_state = l2db_state;
    case (l2db_state)
      STATE_IDLE: begin
        if (tagctl_l2db_alloc_i & ~l2db_mbistreq) begin
          // Allocate L2DB but don't start any transfer yet.
          next_l2db_state = STATE_ALLOCATED;
        end
      end
      STATE_ALLOCATED: begin
        // L2DB is idle, or allocated but not in the process of transferring
        // any data. It may or may not be empty at this time.
        if (transfer_req) begin
          case (transfer_type)
            `CA53_L2DB_TRNSFR_MASTER_L2DB: begin
              next_l2db_state = STATE_MASTER_READ0;
            end
            `CA53_L2DB_TRNSFR_L2DB_MASTER: begin
              if (snpslv_l2db_transfer_info_i[`CA53_L2DB_INFO_MASTER_SNP]) begin
                case (transfer_info[`CA53_L2DB_INFO_CRITICAL_CHUNK])
                  2'b00:   next_l2db_state = STATE_MASTER_WRITE0;
                  2'b01:   next_l2db_state = STATE_MASTER_WRITE1;
                  2'b10:   next_l2db_state = STATE_MASTER_WRITE2;
                  2'b11:   next_l2db_state = STATE_MASTER_WRITE3;
                  default: next_l2db_state = STATE_X;
                endcase
              end else begin
                next_l2db_state = STATE_MASTER_WAIT;
              end
            end
            `CA53_L2DB_TRNSFR_L2DB_RAM: begin
              if (|ram_write_banks[3:0]) begin
                next_l2db_state = STATE_RAM_WRITE0;
              end else begin
                next_l2db_state = STATE_RAM_WRITE1;
              end
            end
            `CA53_L2DB_TRNSFR_RAM_SWAP: begin
              next_l2db_state = STATE_RAM_WRITE0;
            end
            `CA53_L2DB_TRNSFR_RAM_L2DB: begin
              next_l2db_state = STATE_RAM_READ;
            end
            `CA53_L2DB_TRNSFR_SLV_L2DB: begin
              next_l2db_state = STATE_SLV_READ;
            end
            `CA53_L2DB_TRNSFR_RAM_SLV,
            `CA53_L2DB_TRNSFR_SLV_SLV: begin
              case (transfer_info[`CA53_L2DB_INFO_CRITICAL_CHUNK])
                2'b00:   next_l2db_state = STATE_SLV_FORWARD0;
                2'b01:   next_l2db_state = STATE_SLV_FORWARD1;
                2'b10:   next_l2db_state = STATE_SLV_FORWARD2;
                2'b11:   next_l2db_state = STATE_SLV_FORWARD3;
                default: next_l2db_state = STATE_X;
              endcase
            end
            default: begin
              next_l2db_state = STATE_X;
            end
          endcase
        end else if (l2db_release) begin
          next_l2db_state = STATE_IDLE;
        end
      end
      STATE_MASTER_WAIT: begin
        // Wait for the master to tell us what ID to use.
        if (master_ack) begin
          // Work out what the start chunk is, and hence what state to go
          // to. Evict transactions only need to send one beat (and it
          // doesn't matter which beat), which the master will not send
          // externally (but it needs that beat in order to send the address).
          if (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_EVICT) begin
            if (ACE) begin
              next_l2db_state = STATE_MASTER_WRITE3;
            end else begin
              // The Skyros master does not need us to send any data for
              // Evict transactions.
              next_l2db_state = STATE_IDLE;
            end
          end else begin
            next_l2db_state = {STATE_MASTER_WRITE0[4:2], l2db_master_write_chunk};
          end
        end else if (l2db_release) begin
          next_l2db_state = STATE_IDLE;
        end else if ((ACE == 0) & transfer_req) begin
          // A Skyros snoop needs to transfer data while a write is waiting for serialisation.
          case (transfer_info[`CA53_L2DB_INFO_CRITICAL_CHUNK])
            2'b00:   next_l2db_state = STATE_MASTER_WRITE0;
            2'b01:   next_l2db_state = STATE_MASTER_WRITE1;
            2'b10:   next_l2db_state = STATE_MASTER_WRITE2;
            2'b11:   next_l2db_state = STATE_MASTER_WRITE3;
            default: next_l2db_state = STATE_X;
          endcase
        end
      end
      STATE_MASTER_WRITE0,
      STATE_MASTER_WRITE1,
      STATE_MASTER_WRITE2,
      STATE_MASTER_WRITE3: begin
        if (master_l2db_ready_i) begin
          if (l2db_master_last) begin
            if (l2db_info[`CA53_L2DB_INFO_MASTER_RELEASE]) begin
              // Release the L2DB after all data sent, and the Comp has been received if needed.
              if (~next_comp_received & ~l2db_info[`CA53_L2DB_INFO_MASTER_SNP]) begin
                next_l2db_state = STATE_MASTER_COMP;
              end else begin
                next_l2db_state = STATE_IDLE;
              end
            end else begin
              // Remain allocated, if this write was due to a snoop but the L2DB
              // belongs to another access.
              next_l2db_state = STATE_ALLOCATED;
            end
          end else begin
            next_l2db_state = {l2db_state[4:2], l2db_state[1:0] + 2'b01};
          end
        end
      end
      STATE_MASTER_COMP: begin
        if (next_comp_received) begin
          next_l2db_state = STATE_IDLE;
        end
      end
      STATE_MASTER_READ0: begin
        // When accepting read data from the master, we do not know what order
        // the beats will arrive in and so just count the number of beats to
        // determine the end of the burst.
        if (master_read_match) begin
          next_l2db_state = STATE_MASTER_READ1;
        end
      end
      STATE_MASTER_READ1: begin
        if (master_read_match) begin
          next_l2db_state = STATE_MASTER_READ2;
        end
      end
      STATE_MASTER_READ2: begin
        if (master_read_match) begin
          next_l2db_state = STATE_MASTER_READ3;
        end
      end
      STATE_MASTER_READ3: begin
        if (master_read_match) begin
          next_l2db_state = STATE_ALLOCATED;
        end
      end
      STATE_RAM_WRITE0: begin
        if (ramctl_l2db_ready_i) begin
          if (|ram_write_banks[7:4]) begin
            next_l2db_state = STATE_RAM_WRITE1;
          end else if (l2db_after_ctl) begin
            // Wait for read data after we have sent the write data.
            next_l2db_state = STATE_RAM_READ;
          end else begin
            next_l2db_state = STATE_IDLE;
          end
        end
      end
      STATE_RAM_WRITE1: begin
        if (ramctl_l2db_ready_i) begin
          if (l2db_after_ctl) begin
            // Wait for read data after we have sent the write data.
            next_l2db_state = STATE_RAM_READ;
          end else begin
            next_l2db_state = STATE_IDLE;
          end
        end
      end
      STATE_RAM_READ: begin
        if (receiving_last_beat) begin
          next_l2db_state = STATE_ALLOCATED;
        end
      end
      STATE_SLV_READ: begin
        if (receiving_last_beat) begin
          next_l2db_state = STATE_ALLOCATED;
        end
      end
      STATE_SLV_FORWARD0,
      STATE_SLV_FORWARD1,
      STATE_SLV_FORWARD2,
      STATE_SLV_FORWARD3: begin
        // Move through the forward states based on how much data has been sent.
        // We cannot reach the end before all the data has been received, as if
        // we haven't got the data yet it cannot have been forwarded on.
        // If we were sending bypass data, but that data had an error then we
        // must go back a state so it can be sent again, but this time from the
        // L2DB with the corrected data.
        if ((l2db_state[1:0] != l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK]) &
            ram_read_match & ramctl_bypassed_err_i) begin
          next_l2db_state = {l2db_state[4:2], l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK]};
        end else if (slv_accepting_data) begin
          if (last_forward_beat) begin
            if (l2db_beat_ctl[0] & ~len_fullline) begin
              next_l2db_state = STATE_SLV_FORWARD_WAIT;
            end else begin
              next_l2db_state = STATE_ALLOCATED;
            end
          end else begin
            next_l2db_state = {l2db_state[4:2], l2db_state[1:0] + 2'b01};
          end
        end
      end
      STATE_SLV_FORWARD_WAIT: begin
        if (len_fullline) begin
          next_l2db_state = STATE_ALLOCATED;
        end
      end
      default: begin
        next_l2db_state = STATE_X;
      end
    endcase
  end

  assign l2db_state_en = tagctl_l2db_alloc_i | (l2db_state != STATE_IDLE);

  always @(posedge clk_l2db or negedge reset_n)
  if (~reset_n) begin
    l2db_state <= STATE_IDLE;
  end else if (l2db_state_en) begin
    l2db_state <= next_l2db_state;
  end

  assign l2db_state_slv_forward = ((l2db_state == STATE_SLV_FORWARD0) |
                                   (l2db_state == STATE_SLV_FORWARD1) |
                                   (l2db_state == STATE_SLV_FORWARD2) |
                                   (l2db_state == STATE_SLV_FORWARD3));

  assign l2db_state_master_write = ((l2db_state == STATE_MASTER_WRITE0) |
                                    (l2db_state == STATE_MASTER_WRITE1) |
                                    (l2db_state == STATE_MASTER_WRITE2) |
                                    (l2db_state == STATE_MASTER_WRITE3));

  // Signal to the reqbuf when a transfer is completed.
  assign next_l2db_slv_done = ((l2db_state == STATE_IDLE) |
                               (((l2db_state == STATE_ALLOCATED) & ~transfer_req) |
                                ((l2db_state == STATE_MASTER_WAIT) &
                                 ((master_ack & (ACE == 0) &
                                   (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_EVICT)) |
                                  l2db_release)) |
                                (l2db_state_master_write &
                                 master_l2db_ready_i & l2db_master_last &
                                 (l2db_info[`CA53_L2DB_INFO_MASTER_SNP] |
                                  next_comp_received |
                                  ~l2db_info[`CA53_L2DB_INFO_MASTER_RELEASE])) |
                                ((l2db_state == STATE_MASTER_COMP) & next_comp_received) |
                                ((l2db_state == STATE_MASTER_READ3) &
                                 master_read_match) |
                                ((l2db_state == STATE_RAM_WRITE0) &
                                 ramctl_l2db_ready_i & ~l2db_after_ctl & ~|ram_write_banks[7:4]) |
                                ((l2db_state == STATE_RAM_WRITE1) &
                                 ramctl_l2db_ready_i & ~l2db_after_ctl) |
                                (((l2db_state == STATE_RAM_READ) |
                                  (l2db_state == STATE_SLV_READ)) &
                                 receiving_last_beat) |
                                (((l2db_state == STATE_SLV_FORWARD0) |
                                  (l2db_state == STATE_SLV_FORWARD1) |
                                  (l2db_state == STATE_SLV_FORWARD2) |
                                  (l2db_state == STATE_SLV_FORWARD3)) &
                                 slv_accepting_data & last_forward_beat &
                                 ~(l2db_beat_ctl[0] & ~len_fullline)) |
                                ((l2db_state == STATE_SLV_FORWARD_WAIT) & len_fullline)));

  always @(posedge clk_l2db or negedge reset_n)
  if (~reset_n) begin
    l2db_slv_done <= 1'b0;
  end else if (l2db_state_en) begin
    l2db_slv_done <= next_l2db_slv_done;
  end

  assign l2db_slv_done_o = l2db_slv_done & ~l2db_snp_wait;
  assign l2db_snpslv_done_o = l2db_slv_done;

  // Signal to the snoop reqbufs when a transfer is still arbitrating for
  // access to the master.
  assign l2db_slv_master_arb_o = (l2db_state_master_write &
                                  (l2db_state[1:0] == l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK]));

  // Mux the output data based on the lower bits of the state.
  assign l2db_data_halfline = l2db_state[1] ? l2db_data[511:256] : l2db_data[255:0];
  assign l2db_data_quarterline = l2db_state[0] ? l2db_data_halfline[255:128] : l2db_data_halfline[127:0];

  if (ACE) begin : g_ace_snp

    assign l2db_resend_afb_transfer = 1'b0;
    assign l2db_master_invalidated_o = 1'b0;
    assign l2db_master_dirty_o = 1'b0;
    assign l2db_snp_resend_en = 1'b0;

    always @*
    begin
      l2db_snp_wait = zero;
      l2db_snp_resend_cu = zero;
      l2db_snp_resend_opcode = {3{zero}};
      l2db_snp_resend_reqbuf = {6{zero}};
    end

  end else begin : g_skyros_snp
    // If a Skyros snoop needs to transfer data while the L2DB is waiting for a
    // master response then we must remember it so that the original request can
    // be restarted afterwards.
    assign next_l2db_snp_wait = (((l2db_state == STATE_MASTER_WAIT) & transfer_req) |
                                 (l2db_snp_wait & (l2db_state != STATE_ALLOCATED)));

    always @(posedge clk_l2db or negedge reset_n)
    if (~reset_n) begin
      l2db_snp_wait <= 1'b0;
    end else if (l2db_state_en) begin
      l2db_snp_wait <= next_l2db_snp_wait;
    end

    // If the transfer request was originally made by an AFB, then the raw
    // data will not be stored anywhere else, therefore if a snoop transfer
    // overwrites it we must save it off so it can be restored afterwards.
    assign l2db_snp_resend_en = (l2db_state == STATE_MASTER_WAIT) & snpslv_l2db_transfer_i;

    assign snp_resp = snpslv_l2db_transfer_info_i[`CA53_L2DB_INFO_MASTER_OPCODE];

    assign next_l2db_snp_resend_cu = l2db_info[`CA53_L2DB_INFO_MASTER_UNIQUE] & (snp_resp[1:0] == 2'b10);

    always @*
    case (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE])
      `CA53_DATA_OPCODE_WRITENOSNOOP,
      `CA53_DATA_OPCODE_WRITEUNIQUE,
      `CA53_DATA_OPCODE_INVALID:      next_l2db_snp_resend_opcode = `CA53_DATA_OPCODE_INVALID;
      `CA53_DATA_OPCODE_WRITEBACK:    next_l2db_snp_resend_opcode = (snp_resp[1:0] == 2'b00) ? `CA53_DATA_OPCODE_INVALID :
                                                                    (snp_resp[2:1] != 2'b01) ? `CA53_DATA_OPCODE_EVICTDATA :
                                                                                               `CA53_DATA_OPCODE_WRITEBACK;
      `CA53_DATA_OPCODE_WRITECLEAN:   next_l2db_snp_resend_opcode = (snp_resp[1:0] == 2'b00) ? `CA53_DATA_OPCODE_INVALID :
                                                                    (snp_resp[2:1] != 2'b01) ? `CA53_DATA_OPCODE_EVICTDATA :
                                                                                               `CA53_DATA_OPCODE_WRITECLEAN;
      `CA53_DATA_OPCODE_EVICT:        next_l2db_snp_resend_opcode = `CA53_DATA_OPCODE_EVICT;
      `CA53_DATA_OPCODE_EVICTDATA:    next_l2db_snp_resend_opcode = (snp_resp[1:0] == 2'b00) ? `CA53_DATA_OPCODE_INVALID :
                                                                                               `CA53_DATA_OPCODE_EVICTDATA;
      default:                        next_l2db_snp_resend_opcode = 3'bxxx;
    endcase

    always @(posedge clk_l2db)
    if (l2db_snp_resend_en) begin
      l2db_snp_resend_cu     <= next_l2db_snp_resend_cu;
      l2db_snp_resend_opcode <= next_l2db_snp_resend_opcode;
      l2db_snp_resend_reqbuf <= l2db_info[`CA53_L2DB_INFO_MASTER_ID];
    end

    assign l2db_resend_afb_transfer = (l2db_state == STATE_ALLOCATED) & l2db_snp_wait;

    assign l2db_master_invalidated_o = ((l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_INVALID) |
                                        (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_EVICT));
    assign l2db_master_dirty_o = ((l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_WRITEBACK) |
                                  (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_WRITECLEAN));

  end

  //----------------------------------------------------------------------------
  //  Master write interface
  //----------------------------------------------------------------------------

  assign l2db_master_valid_o = l2db_state_master_write; 

  // Calculate and register the first chunk that needs to be sent to the master.
  // This is done separately from the state machine because it is needed for
  // Skyros on the same cycle that the transfer request arrives.
  // Note that this is only valid for writes, and not snoops.
  assign next_l2db_master_write_chunk = (l2db_state_master_write ? (master_l2db_ready_i ? (l2db_master_write_chunk + 2'b01) :
                                                                                          l2db_master_write_chunk) :
                                         (l2db_chunks_valid[0] |
                                          (l2db_chunks_valid[1] & len_halfline) |
                                          len_fullline) ? 2'b00 :
                                         l2db_chunks_valid[1] ? 2'b01 :
                                         (l2db_chunks_valid[2] |
                                          (l2db_chunks_valid[3] & len_halfline)) ? 2'b10 : 2'b11);

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_master_write_chunk <= next_l2db_master_write_chunk;
  end

  // The byte strobes and data selected is based on the chunk, which is
  // controlled by the lower two bits of the state machine.
  assign master_strb = (({16{l2db_master_write_chunk == 2'b00}} & l2db_strb[15:0]) |
                        ({16{l2db_master_write_chunk == 2'b01}} & l2db_strb[31:16]) |
                        ({16{l2db_master_write_chunk == 2'b10}} & l2db_strb[47:32]) |
                        ({16{l2db_master_write_chunk == 2'b11}} & l2db_strb[63:48]));

  // If the data has a fatal error then suppress the write strobes, to avoid
  // writing corrupt data out.
  assign l2db_master_strb_o = master_strb & ~{16{l2db_err & (ACE != 0) & ~l2db_info[`CA53_L2DB_INFO_MASTER_SNP]}};

  assign l2db_master_snoop_o = l2db_info[`CA53_L2DB_INFO_MASTER_SNP];

  assign l2db_master_data_o = l2db_data_quarterline;

  assign l2db_master_chunk_o = l2db_state[1:0];

  // Bursts are always sent as aligned quarter lines, halflines, of full lines.
  // This ensures that the length is always a power of two.
  assign len_fullline = |l2db_chunks_valid[3:2] & |l2db_chunks_valid[1:0];
  assign len_halfline = (&l2db_chunks_valid[3:2] | &l2db_chunks_valid[1:0]) & ~len_fullline;

  assign l2db_master_len_o = {len_fullline,
                              len_fullline | len_halfline};

  // The reqbufs and AFBs need to know if the L2DB contains a full line of data
  // to allow optimisations on WriteUniques. Registered before sending to help
  // timing. ACP writes need to know a cycle before CPU writes.
  assign next_l2db_full_line = &l2db_strb[47:0] & (slv_read_match ? (data_sel[4] &
                                                                     (acpslv_l2dbs_dw_chunk_i == 2'b11) &
                                                                     (&acpslv_l2dbs_dw_strb_i)) : &l2db_strb[63:48]);

  // The reqbufs and AFBs need to know if a read-modify-write is needed for any
  // 64 bit chunk of data. Registered before sending to help timing.
  assign next_l2db_rmw_line = ((|l2db_strb[7:0]   & ~&l2db_strb[7:0]) |
                               (|l2db_strb[15:8]  & ~&l2db_strb[15:8]) |
                               (|l2db_strb[23:16] & ~&l2db_strb[23:16]) |
                               (|l2db_strb[31:24] & ~&l2db_strb[31:24]) |
                               (|l2db_strb[39:32] & ~&l2db_strb[39:32]) |
                               (|l2db_strb[47:40] & ~&l2db_strb[47:40]) |
                               (|l2db_strb[55:48] & ~&l2db_strb[55:48]) |
                               (|l2db_strb[63:56] & ~&l2db_strb[63:56]));

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_full_line <= next_l2db_full_line;
    l2db_rmw_line  <= next_l2db_rmw_line;
  end

  assign l2db_full_line_o = l2db_full_line;
  assign l2db_rmw_line_o = l2db_rmw_line;

  // The strobes for the chunk if there is only one valid chunk.
  assign size_strb = (({16{l2db_chunks_valid[0]}} & l2db_strb[15:0]) |
                      ({16{l2db_chunks_valid[1]}} & l2db_strb[31:16]) |
                      ({16{l2db_chunks_valid[2]}} & l2db_strb[47:32]) |
                      ({16{l2db_chunks_valid[3]}} & l2db_strb[63:48]));

  // If the burst has only a single beat then the size needs to be worked out
  // from the byte strobes, otherwise the size is the full width of the bus.
  assign next_l2db_master_beat_size = ((|size_strb[15:8] & |size_strb[7:0]) ? 3'b100 :
                                       ((|size_strb[15:12] & |size_strb[11:8]) |
                                        (|size_strb[7:4]   & |size_strb[3:0])) ? 3'b011 :
                                       ((|size_strb[15:14] & |size_strb[13:12]) |
                                        (|size_strb[11:10] & |size_strb[9:8]) |
                                        (|size_strb[7:6]   & |size_strb[5:4]) |
                                        (|size_strb[3:2]   & |size_strb[1:0])) ? 3'b010 :
                                       (&size_strb[15:14] | &size_strb[13:12] |
                                        &size_strb[11:10] | &size_strb[9:8] |
                                        &size_strb[7:6]   | &size_strb[5:4] |
                                        &size_strb[3:2]   | &size_strb[1:0]) ? 3'b001 : 3'b000);

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_master_beat_size <= next_l2db_master_beat_size;
  end

  assign l2db_master_size_o = (len_fullline | len_halfline) ? 3'b100 : l2db_master_beat_size;

  // Calculate the lower address bits based on the byte strobes.
  assign next_l2db_master_beat_addr = {|size_strb[15:8] & ~|size_strb[7:0],
                                       (|size_strb[7:4]   & ~|{size_strb[15:8], size_strb[3:0]}) |
                                       (|size_strb[15:12] & ~|size_strb[11:0]),
                                       (|size_strb[3:2]   & ~|{size_strb[15:4], size_strb[1:0]}) |
                                       (|size_strb[7:6]   & ~|{size_strb[15:8], size_strb[5:0]}) |
                                       (|size_strb[11:10] & ~|{size_strb[15:12], size_strb[9:0]}) |
                                       (|size_strb[15:14] & ~|size_strb[13:0]),
                                       (|size_strb[1]  & ~|{size_strb[15:2],  size_strb[0]}) |
                                       (|size_strb[3]  & ~|{size_strb[15:4],  size_strb[2:0]}) |
                                       (|size_strb[5]  & ~|{size_strb[15:6],  size_strb[4:0]}) |
                                       (|size_strb[7]  & ~|{size_strb[15:8],  size_strb[6:0]}) |
                                       (|size_strb[9]  & ~|{size_strb[15:10], size_strb[8:0]}) |
                                       (|size_strb[11] & ~|{size_strb[15:12], size_strb[10:0]}) |
                                       (|size_strb[13] & ~|{size_strb[15:14], size_strb[12:0]}) |
                                       (|size_strb[15] & ~|size_strb[14:0])};

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    l2db_master_beat_addr <= next_l2db_master_beat_addr;
  end

  assign l2db_master_addr_o = (l2db_state_master_write &
                               l2db_info[`CA53_L2DB_INFO_MASTER_SNP] &
                               (ACE == 0)) ? {l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK], 4'b0000} :
                              {|l2db_chunks_valid[3:2] & ~|l2db_chunks_valid[1:0],
                               (l2db_chunks_valid[3] ^ l2db_chunks_valid[1]) &
                               ~l2db_chunks_valid[2] & ~l2db_chunks_valid[0],
                               (len_fullline | len_halfline) ? 4'b0000 :
                               l2db_master_beat_addr};

  // The last beat depends on the length of the burst.
  assign l2db_master_last = (l2db_info[`CA53_L2DB_INFO_MASTER_SNP] ? last_forward_beat :
                                                                     ((l2db_state == STATE_MASTER_WRITE3) |
                                                                      ((l2db_state == STATE_MASTER_WRITE1) & len_halfline) |
                                                                      (~len_fullline & ~len_halfline)));

  assign l2db_master_last_o = l2db_master_last;

  assign l2db_master_err_o = l2db_err;

  if (ACE) begin : g_ace_opcode

    assign l2db_master_dbid_o = 8'h00;

    // WriteEvict transactions on ACE must have all write strobes set, so if
    // we are suppressing the strobes due to a fatal ECC error then turn the
    // transaction into an Evict.
    assign l2db_master_opcode_o = (((l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] == `CA53_DATA_OPCODE_EVICTDATA) &
                                    l2db_err) ? `CA53_DATA_OPCODE_EVICT : l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE]);
  end else begin : g_n_ace_opcode
    assign l2db_master_dbid_o   = l2db_info[`CA53_L2DB_INFO_MASTER_DBID];
    assign l2db_master_opcode_o = l2db_info[`CA53_L2DB_INFO_MASTER_SNP] ? `CA53_DATA_OPCODE_SNOOPDATA :
                                                                          l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE];
  end

  assign l2db_master_id_o      = l2db_info[`CA53_L2DB_INFO_MASTER_ID];
  assign l2db_master_snpresp_o = l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE];
  assign l2db_master_attrs_o   = l2db_info[`CA53_L2DB_INFO_MASTER_ATTRS];
  assign l2db_master_prot_o    = l2db_info[`CA53_L2DB_INFO_MASTER_PROT];
  assign l2db_master_strex_o   = l2db_info[`CA53_L2DB_INFO_MASTER_STREX];
  assign l2db_master_unique_o  = l2db_info[`CA53_L2DB_INFO_MASTER_UNIQUE];


  //----------------------------------------------------------------------------
  //  L2 RAM controller read and write requests
  //----------------------------------------------------------------------------

  assign next_l2db_ramctl_valid = (((l2db_state == STATE_ALLOCATED) &
                                    transfer_req &
                                    ((transfer_type == `CA53_L2DB_TRNSFR_L2DB_RAM) |
                                     (transfer_type == `CA53_L2DB_TRNSFR_RAM_SWAP) |
                                     ((transfer_type == `CA53_L2DB_TRNSFR_RAM_L2DB) &
                                      acpslv_l2db_transfer_info_i[`CA53_L2DB_INFO_SINGLE_BEAT]))) |
                                   ((l2db_state == STATE_RAM_WRITE0) & |ram_write_banks[7:4]) |
                                   (l2db_ramctl_valid & ~ramctl_l2db_ready_i));
                                

  always @(posedge clk_l2db or negedge reset_n)
  if (~reset_n) begin
    l2db_ramctl_valid <= 1'b0;
  end else if (l2db_state_en) begin
    l2db_ramctl_valid <= next_l2db_ramctl_valid;
  end

  assign ram_read_banks = 8'b11111111 << {l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK], 1'b0};

  assign ram_write_banks = {l2db_strb[56], l2db_strb[48],
                            l2db_strb[40], l2db_strb[32],
                            l2db_strb[24], l2db_strb[16],
                            l2db_strb[8],  l2db_strb[0]};

  assign l2db_ramctl_valid_o  = l2db_ramctl_valid;
  assign l2db_ramctl_rw_o     = (l2db_state == STATE_RAM_READ) ? 2'b10 : {l2db_after_ctl, 1'b1};
  assign l2db_ramctl_index_o  = l2db_info[`CA53_L2DB_INFO_RAM_INDEX];
  assign l2db_ramctl_way_o    = l2db_info[`CA53_L2DB_INFO_RAM_WAY];
  assign l2db_ramctl_data_o   = l2db_data_halfline;
  assign l2db_ramctl_banks_o  = (l2db_state == STATE_RAM_READ) ? ram_read_banks : ram_write_banks;
  assign l2db_ramctl_err_o    = l2db_err;


  //----------------------------------------------------------------------------
  //  CPU/ACP slv read data
  //----------------------------------------------------------------------------

  // If in the next cycle the following chunk is the critical chunk then that
  // must be the last chunk and hence all but the last chunk have now been sent.
  assign next_last_forward_beat = ((~l2db_state_slv_forward &
                                    ~l2db_state_master_write) ? 1'b0 :
                                   (l2db_state_slv_forward &
                                    l2db_beat_ctl[0]) ? 1'b1 :
                                   ((l2db_state_slv_forward &
                                     slv_accepting_data) |
                                    (l2db_state_master_write &
                                     master_l2db_ready_i)) ? ((l2db_state[1:0] + 2'b10) ==
                                                              (l2db_beat_ctl[1] ? 2'b00 :
                                                                                  l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK])) :
                                                             last_forward_beat);

  // When ramctl tells us the data will be available in the next cycle, we can
  // try to set up the bypass path to the cpuslv for the critical chunk.
  assign next_l2db_slv_bypass = ramctl_l2dbs_bypass_i & (ramctl_l2dbs_bypass_id_i == L2DB_NUM);

  // If there is an error then block forwarding of data, and wait until we know
  // if the error was fatal or not before progressing. The fatal information
  // arrives a cycle after the data. On the cycle ramctl_bypassed_err is
  // asserted we do not need to block because the slv will known about the
  // error and it will be blocking.
  assign next_l2db_ramctl_err = ram_read_match & ramctl_bypassed_err_i;

  assign next_l2db_cpuslv_err = (read_match & ((data_sel[3] & cpuslv3_l2dbs_dw_err_i) |
                                               (data_sel[2] & cpuslv2_l2dbs_dw_err_i) |
                                               (data_sel[1] & cpuslv1_l2dbs_dw_err_i) |
                                               (data_sel[0] & cpuslv0_l2dbs_dw_err_i)));

  always @(posedge clk_l2db)
  if (l2db_state_en) begin
    last_forward_beat <= next_last_forward_beat;
    l2db_cpuslv_err   <= next_l2db_cpuslv_err;
  end

  if (L2_CACHE) begin : g_l2cc

    always @(posedge clk_l2db)
    if (l2db_state_en) begin
      l2db_slv_bypass <= next_l2db_slv_bypass;
    end

  end else begin : g_n_l2cc
    always @*
      l2db_slv_bypass = zero;
  end

  if (SCU_CACHE_PROTECTION) begin : g_scu_ecc

    always @(posedge clk_l2db)
    if (l2db_state_en) begin
      l2db_ramctl_err <= next_l2db_ramctl_err;
    end

  end else begin : g_n_scu_ecc

    always @*
      l2db_ramctl_err = zero;

  end

  // The last beat of data must be delayed in some cases until all snoops
  // related to this transaction have completed. The AFB controls this and
  // tells the L2DB when it is safe to send the last beat.
  // When forwarding data, it is always provided in 128 bit or more chunks,
  // and so we only need to check one byte strobe per chunk to know if we have
  // all of that chunk.
  // When there is an error on the bypass data, the slv will not arbitrate in
  // the following cycle, so there is no need to suppress the valid here.
  assign l2db_slv_valid = (l2db_state_slv_forward &
                           ~((last_forward_beat & l2db_delay_last_beat) |
                             l2db_ramctl_err | l2db_cpuslv_err) &
                           ((l2db_slv_bypass & (l2db_info[`CA53_L2DB_INFO_DEST_SLV] != 3'b100)) | 
                            ((l2db_state[1:0] == 2'b00) & l2db_strb[0]) |
                            ((l2db_state[1:0] == 2'b01) & l2db_strb[16]) |
                            ((l2db_state[1:0] == 2'b10) & l2db_strb[32]) |
                            ((l2db_state[1:0] == 2'b11) & l2db_strb[48])));

  assign l2db_slv_valid_o = l2db_slv_valid;

  assign slv_accepting_data = (l2db_slv_valid &
                               (((l2db_info[`CA53_L2DB_INFO_DEST_SLV] == 3'b100) &  acpslv_l2db_ready_i) |
                                ((l2db_info[`CA53_L2DB_INFO_DEST_SLV] == 3'b011) & cpuslv3_l2db_ready_i) |
                                ((l2db_info[`CA53_L2DB_INFO_DEST_SLV] == 3'b010) & cpuslv2_l2db_ready_i) |
                                ((l2db_info[`CA53_L2DB_INFO_DEST_SLV] == 3'b001) & cpuslv1_l2db_ready_i) |
                                ((l2db_info[`CA53_L2DB_INFO_DEST_SLV] == 3'b000) & cpuslv0_l2db_ready_i)));

  assign l2db_slv_data_o = l2db_data_quarterline;
  assign l2db_slv_chunk_o = l2db_state[1:0];
  assign l2db_slv_last_o = ((l2db_state[1:0] == 2'b11) |
                            (l2db_state_slv_forward & l2db_beat_ctl[0]));
  assign l2db_slv_id_o = l2db_info[`CA53_L2DB_INFO_DEST_ID];
  assign l2db_slv_biuid_o = l2db_info[`CA53_L2DB_INFO_DEST_BIU_ID];
  assign l2db_slv_bypass_o = l2db_slv_bypass;
  assign l2db_slv_err_o = l2db_err;


  //----------------------------------------------------------------------------
  //  Storing data arriving for the L2DB
  //----------------------------------------------------------------------------

  assign l2db_src_slv = {l2db_info[`CA53_L2DB_INFO_SRC_SLV] == 3'b100,
                         l2db_info[`CA53_L2DB_INFO_SRC_SLV] == 3'b011,
                         l2db_info[`CA53_L2DB_INFO_SRC_SLV] == 3'b010,
                         l2db_info[`CA53_L2DB_INFO_SRC_SLV] == 3'b001,
                         l2db_info[`CA53_L2DB_INFO_SRC_SLV] == 3'b000};

  // Select which source of data we are expecting data from. There may not
  // be data from this source, or destined for this L2DB, this cycle. However
  // there will never be any data destined for this L2DB from a different source.
  assign data_sel = {(l2db_state == STATE_MASTER_READ0) |
                     (l2db_state == STATE_MASTER_READ1) |
                     (l2db_state == STATE_MASTER_READ2) |
                     (l2db_state == STATE_MASTER_READ3),
                     (l2db_state == STATE_RAM_READ) |
                     (l2db_state_slv_forward & l2db_after_ctl),
                     {5{(l2db_state == STATE_SLV_READ) |
                        ((l2db_state_slv_forward |
                          (l2db_state == STATE_SLV_FORWARD_WAIT)) & ~l2db_after_ctl) |
                        l2db_mbistreq}} & l2db_src_slv};

  // Mux the data, assuming it is valid. Some sources only supply 128 bits of
  // data, others 256. In either case we will only have data for the upper half
  // of the line or the lower half, therefore can generate the next register
  // value as 256 bits which is then replicated to either the upper or lower
  // half of the 512 bit register.
  assign next_l2db_data = (({2{{128{data_sel[6]}} & master_early_dr_data_i}}) |
                           (   {256{data_sel[5]}} & ramctl_l2dbs_data_i) |
                           ({2{{128{data_sel[4]}} & acpslv_l2dbs_dw_data_i}}) |
                           (   {256{data_sel[3]}} & cpuslv3_l2dbs_dw_data_i) |
                           (   {256{data_sel[2]}} & cpuslv2_l2dbs_dw_data_i) |
                           (   {256{data_sel[1]}} & cpuslv1_l2dbs_dw_data_i) |
                           (   {256{data_sel[0]}} & cpuslv0_l2dbs_dw_data_i));

  // Mux the byte strobes. The master and RAM always provide full chunks of data.
  assign new_l2db_strb = (({32{l2db_mbistreq}}) |
                          ({32{data_sel[6]}}) |
                          ({32{data_sel[5]}}) |
                          ({2{{16{data_sel[4]}} & acpslv_l2dbs_dw_strb_i}}) |
                          ({32{data_sel[3]}} & cpuslv3_l2dbs_dw_strb_i) |
                          ({32{data_sel[2]}} & cpuslv2_l2dbs_dw_strb_i) |
                          ({32{data_sel[1]}} & cpuslv1_l2dbs_dw_strb_i) |
                          ({32{data_sel[0]}} & cpuslv0_l2dbs_dw_strb_i));

  // Determine if the data is valid this cycle and destined for this L2DB. This
  // does not need to look at ready, because any data destined for an L2DB will
  // be suppressed by the slv, and so cannot stall.
  // Because we are selecting based on reqbuf, and the reqbuf could be doing two
  // transfers, we must only match this data if we are expecting it to come from
  // the master.
  assign master_read_match = (data_sel[6] &
                              master_early_dr_valid_i &
                              (master_early_dr_id_i == l2db_info[`CA53_L2DB_INFO_SRC_REQBUF]));

  assign ram_read_match = ramctl_l2dbs_valid_i & (ramctl_l2dbs_id_i == L2DB_NUM);

  assign slv_read_match = (( acpslv_l2dbs_dw_valid_i & ( acpslv_l2dbs_dw_id_i == L2DB_NUM)) |
                           (cpuslv3_l2dbs_dw_valid_i & (cpuslv3_l2dbs_dw_id_i == L2DB_NUM)) |
                           (cpuslv2_l2dbs_dw_valid_i & (cpuslv2_l2dbs_dw_id_i == L2DB_NUM)) |
                           (cpuslv1_l2dbs_dw_valid_i & (cpuslv1_l2dbs_dw_id_i == L2DB_NUM)) |
                           (cpuslv0_l2dbs_dw_valid_i & (cpuslv0_l2dbs_dw_id_i == L2DB_NUM)));

  assign read_match = (master_read_match |
                       ram_read_match |
                       slv_read_match |
                       l2db_mbistreq);

  // With ACE, we know what order the chunks will arrive in, so to help timing
  // we calculate it ourselves rather than rely on the later arriving
  // information from the master.
  assign master_chunk = ACE ? (l2db_info[`CA53_L2DB_INFO_CRITICAL_CHUNK] + l2db_state[1:0]) : master_early_dr_chunk_i;

  // Calculate which 128 bit chunks should be written to the L2DB this cycle.
  assign new_chunks_no_master = (({4{data_sel[5]}} & (4'b0011 << ramctl_l2dbs_chunk_i)) |
                                 ({4{data_sel[4]}} & (4'b0001 << acpslv_l2dbs_dw_chunk_i)) |
                                 ({4{data_sel[3]}} & cpuslv3_l2dbs_dw_chunks_valid_i) |
                                 ({4{data_sel[2]}} & cpuslv2_l2dbs_dw_chunks_valid_i) |
                                 ({4{data_sel[1]}} & cpuslv1_l2dbs_dw_chunks_valid_i) |
                                 ({4{data_sel[0]}} & cpuslv0_l2dbs_dw_chunks_valid_i));

  assign chunks_valid = {4{read_match}} & (new_chunks_no_master |
                                           ({4{data_sel[6]}} & (4'b0001 << master_chunk)) |
                                           {4{l2db_mbistreq}});

  // Indicate we are receiving the last beat of data, and can therefore stop
  // waiting for more. Note that this does not cover read data from the master,
  // because the master does not keep track of the last beat so we must do that
  // separately ourselves.
  assign receiving_last_beat = (read_match & ((data_sel[5] & ramctl_l2dbs_last_i) |
                                              (data_sel[4] & acpslv_l2dbs_dw_last_i) |
                                              (data_sel[3] & cpuslv3_l2dbs_dw_last_i) |
                                              (data_sel[2] & cpuslv2_l2dbs_dw_last_i) |
                                              (data_sel[1] & cpuslv1_l2dbs_dw_last_i) |
                                              (data_sel[0] & cpuslv0_l2dbs_dw_last_i)));

  // When merging data, we normally only enable bytes that are being written and
  // not already valid. However we must force the enable when the data being
  // written is newer than that already in the L2DB. This can be from a CPU
  // (this can only happen if the store buffer sends the same chunk more than
  // once in the burst), or from the RAM when doing a swap (because all the data
  // is new, and the existing data is not valid anymore).
  assign l2db_data_force_en = ((|data_sel[4:0] & l2db_info[`CA53_L2DB_INFO_OVERWRITE]) |
                               (data_sel[5] & l2db_after_ctl) |
                               l2db_mbistreq);

  assign l2db_data_en = {{16{chunks_valid[3]}} & (new_l2db_strb[31:16] & ({16{l2db_data_force_en}} | ~l2db_strb[63:48])),
                         {16{chunks_valid[2]}} & (new_l2db_strb[15:0]  & ({16{l2db_data_force_en}} | ~l2db_strb[47:32])),
                         {16{chunks_valid[1]}} & (new_l2db_strb[31:16] & ({16{l2db_data_force_en}} | ~l2db_strb[31:16])),
                         {16{chunks_valid[0]}} & (new_l2db_strb[15:0]  & ({16{l2db_data_force_en}} | ~l2db_strb[15:0]))};

  for (i = 0; i < 64; i = i + 1) begin : g_l2db_data
    always @(posedge clk_l2db)
    if (l2db_data_en[i]) begin
      l2db_data[i*8+:8] <= next_l2db_data[((i < 32) ? i : (i-32))*8+:8];
    end
  end

  // Clear the strobes when the L2DB is first allocated, because we do not know
  // if all chunks will be written eventually or not. After that, or together
  // the existing strobes and ones from any new data being merged in.
  assign next_l2db_strb = ({2{new_l2db_strb}} |
                           {64{tagctl_l2db_fill_strbs_i |
                               (data_sel[5] & ~l2db_slv_bypass & ~ramctl_bypassed_err_i)}} |
                           (l2db_strb & {64{(l2db_state != STATE_IDLE) & |l2db_chunks_valid}}));

  // Master reads, which are only done by WriteUniques, must not update the
  // strobes because if the later lookup hits in L1 or L2 then we must
  // overwrite the master data with the cache data (while still keeping
  // the original request data).
  // RAM reads update all chunks on the second transfer cycle, unless there
  // was an error on the first cycle.
  // The strobes are only cleared when the first transfer request is made, to
  // avoid enabling them for l2dbs that are allocated but never used.
  assign l2db_strb_en = ({4{transfer_req & ~|l2db_chunks_valid}} |
                         {4{tagctl_l2db_fill_strbs_i}} |
                         ({4{slv_read_match}} & new_chunks_no_master) |
                         ({4{ram_read_match & ~l2db_slv_bypass}} &
                          (ramctl_bypassed_err_i ? new_chunks_no_master : 4'b1111)));

  for (i = 0; i < 4; i = i + 1) begin : g_l2db_strb
    always @(posedge clk_l2db)
    if (l2db_strb_en[i]) begin
      l2db_strb[i*16+:16] <= next_l2db_strb[i*16+:16];
    end
  end

  assign l2db_chunks_valid_en = (tagctl_l2db_alloc_i |
                                 tagctl_l2db_fill_strbs_i |
                                 ram_read_match |
                                 slv_read_match);

  assign next_l2db_chunks_valid = tagctl_l2db_alloc_i ? 4'b0000 : (l2db_chunks_valid |
                                                                   new_chunks_no_master |
                                                                   {4{tagctl_l2db_fill_strbs_i}});

  always @(posedge clk_l2db)
  if (l2db_chunks_valid_en) begin
    l2db_chunks_valid <= next_l2db_chunks_valid;
  end

  // Store if any beat in the L2DB got a fatal ECC error. For RAMCtl data, the fatal error
  // indication arrives a cycle after the data.
  assign next_l2db_err = (((l2db_err & ~((l2db_state == STATE_RAM_WRITE1) &
                                         l2db_after_ctl &
                                         ramctl_l2db_ready_i)) |
                           (l2db_ramctl_err & ramctl_l2dbs_err_i) |
                           (l2db_cpuslv_err &
                            ((l2db_src_slv[3] & cpuslv3_l2dbs_dw_fatal_i) |
                             (l2db_src_slv[2] & cpuslv2_l2dbs_dw_fatal_i) |
                             (l2db_src_slv[1] & cpuslv1_l2dbs_dw_fatal_i) |
                             (l2db_src_slv[0] & cpuslv0_l2dbs_dw_fatal_i)))) &
                          ~tagctl_l2db_alloc_i);

  always @(posedge clk_l2db)
  begin
    l2db_err <= next_l2db_err;
  end

  // Tell the cpuslv if we are expecting data from it, so it can gate the clock
  // when idle.
  assign l2db_cpuslv0_data_active_o = data_sel[0];
  assign l2db_cpuslv1_data_active_o = data_sel[1];
  assign l2db_cpuslv2_data_active_o = data_sel[2];
  assign l2db_cpuslv3_data_active_o = data_sel[3];

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L2DB clock must be enabled when a request arrives")
  u_ovl_clk_en (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (tagctl_l2db_alloc_i),
    .consequent_expr (clk_enable)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L2DB may only be allocated when it is idle")
  u_ovl_alloc_idle (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (tagctl_l2db_alloc_i),
    .consequent_expr  (l2db_state == STATE_IDLE)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L2DB may only be released by a cpuslv when it is allocated or waiting for master")
  u_ovl_release_slv (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (cpuslv0_l2db_release_i |
                       cpuslv1_l2db_release_i |
                       cpuslv2_l2db_release_i |
                       cpuslv3_l2db_release_i),
    .consequent_expr  ((l2db_state == STATE_ALLOCATED) |
                       (l2db_state == STATE_MASTER_WAIT))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "L2DB may only be released by when it is allocated or idle")
  u_ovl_release_tagctl (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (tagctl_l2db_release_i),
    .consequent_expr  ((l2db_state == STATE_ALLOCATED) |
                       (l2db_state == STATE_IDLE))
  );

  assert_zero_one_hot #(`OVL_FATAL, 5, `OVL_ASSERT, "Only one source may release an L2DB")
  u_ovl_release_zoh (
    .clk        (clk),
    .reset_n    (reset_n),
    .test_expr  ({tagctl_l2db_release_i,
                  cpuslv0_l2db_release_i,
                  cpuslv1_l2db_release_i,
                  cpuslv2_l2db_release_i,
                  cpuslv3_l2db_release_i})
  );

  assert_zero_one_hot #(`OVL_FATAL, 6, `OVL_ASSERT, "Only one source may request a transfer at the same time")
  u_ovl_transfer_zoh (
    .clk        (clk),
    .reset_n    (reset_n),
    .test_expr  ({cpuslv0_l2db_transfer_i,
                  cpuslv1_l2db_transfer_i,
                  cpuslv2_l2db_transfer_i,
                  cpuslv3_l2db_transfer_i,
                  acpslv_l2db_transfer_i,
                  snpslv_l2db_transfer_i})
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer request may only arrive when the L2DB is allocated or waiting for master")
  u_ovl_transfer_req (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (transfer_req),
    .consequent_expr  ((l2db_state == STATE_ALLOCATED) |
                       (l2db_state == STATE_MASTER_WAIT))
  );



  reg [63:0] ovl_prev_l2db_strb;

  for (i = 0; i < 64; i = i + 1) begin : g_ovl_l2db_strb

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      ovl_prev_l2db_strb[i] <= 1'b0;
    end else begin
      ovl_prev_l2db_strb[i] <= (l2db_state != STATE_IDLE) & l2db_chunks_valid[i/16] & (ovl_prev_l2db_strb[i] | l2db_strb[i]);
    end

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once a byte strobe is set, it must remain set until the L2DB is released")
    u_ovl_strb_set (
      .clk              (clk),
      .reset_n          (reset_n),
      .antecedent_expr  (ovl_prev_l2db_strb[i]),
      .consequent_expr  (l2db_strb[i])
    );
  end

  reg ovl_prev_l2db_err;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_prev_l2db_err <= 1'b0;
  end else begin
    ovl_prev_l2db_err <= ((l2db_state != STATE_IDLE) &
                          (ovl_prev_l2db_err | l2db_err) &
                          ~((l2db_state == STATE_RAM_WRITE1) &
                            l2db_after_ctl &
                            ramctl_l2db_ready_i));
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once the error flag is set, it must remain set until the L2DB is released or written to L2")
  u_ovl_err_set (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (ovl_prev_l2db_err),
    .consequent_expr  (l2db_err)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero0 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~cpuslv0_l2db_transfer_i),
    .consequent_expr  (~|cpuslv0_l2db_transfer_type_i &
                       ~|cpuslv0_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero1 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~cpuslv1_l2db_transfer_i),
    .consequent_expr  (~|cpuslv1_l2db_transfer_type_i &
                       ~|cpuslv1_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero2 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~cpuslv2_l2db_transfer_i),
    .consequent_expr  (~|cpuslv2_l2db_transfer_type_i &
                       ~|cpuslv2_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero3 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~cpuslv3_l2db_transfer_i),
    .consequent_expr  (~|cpuslv3_l2db_transfer_type_i &
                       ~|cpuslv3_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero4 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~acpslv_l2db_transfer_i),
    .consequent_expr  (~|acpslv_l2db_transfer_type_i &
                       ~|acpslv_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Transfer type and info must be zero from slvs not making a request")
  u_ovl_transfer_zero5 (
    .clk              (clk),
    .reset_n          (reset_n),
    .antecedent_expr  (~snpslv_l2db_transfer_i),
    .consequent_expr  (~|snpslv_l2db_transfer_type_i &
                       ~|snpslv_l2db_transfer_info_i)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "If RAMCtl says we can bypass, then it must provide data in the following cycle")
  u_ovl_bypass_valid1 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (l2db_state_slv_forward & l2db_slv_bypass),
                       .consequent_expr (ram_read_match));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "If RAMCtl says we can bypass, then it must provide data in the following two cycles")
  u_ovl_bypass_valid2 (.clk         (clk),
                       .reset_n     (reset_n),
                       .start_event (l2db_state_slv_forward & l2db_slv_bypass),
                       .test_expr   (ram_read_match));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The master chunk calculation must match what the master sends")
  u_ovl_master_chunk (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (master_read_match),
                      .consequent_expr (master_chunk == master_early_dr_chunk_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The master chunk register must match the state machine when sending data to the master")
  u_ovl_l2db_master_write_chunk (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (l2db_state_master_write &
                                                   ~l2db_info[`CA53_L2DB_INFO_MASTER_SNP] &
                                                   (l2db_info[`CA53_L2DB_INFO_MASTER_OPCODE] != `CA53_DATA_OPCODE_EVICT)),
                                 .consequent_expr (l2db_master_write_chunk == l2db_state[1:0]));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "l2db_slv_done calculation correct")
  u_ovl_l2db_slv_done (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr (next_l2db_slv_done == ((next_l2db_state == STATE_IDLE) |
                                                          (next_l2db_state == STATE_ALLOCATED))));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Data must only arrive when expected")
  u_ovl_ram_data_expected (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (ram_read_match),
                           .consequent_expr (data_sel[5]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Data must only arrive when expected")
  u_ovl_slv_data_expected (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (slv_read_match),
                           .consequent_expr (|data_sel[4:0]));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_chunks_valid_en")
  u_ovl_x_l2db_chunks_valid_en (.clk       (clk_l2db),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (l2db_chunks_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_cu_en")
  u_ovl_x_l2db_cu_en (.clk       (clk_l2db),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (l2db_cu_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_opcode_en")
  u_ovl_x_l2db_opcode_en (.clk       (clk_l2db),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (l2db_opcode_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_snp_resend_en")
  u_ovl_x_l2db_snp_resend_en (.clk       (clk_l2db),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (l2db_snp_resend_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_state_en")
  u_ovl_x_l2db_state_en (.clk       (clk_l2db),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (l2db_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_info_en")
  u_ovl_x_l2db_info_en (.clk       (clk_l2db),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (l2db_info_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2db_waddr_en")
  u_ovl_x_l2db_waddr_en (.clk       (clk_l2db),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (l2db_waddr_en));


  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "Register enable x-check: l2db_data_en")
  u_ovl_x_l2db_data_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (l2db_data_en));

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "Register enable x-check: l2db_strb_en")
  u_ovl_x_l2db_strb_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (l2db_strb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: transfer_req")
  u_ovl_x_transfer_req (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (transfer_req));


`endif

end else begin : g_no_l2db
  // L2DB not present, so tie off all outputs
  assign l2db_tagctl_available_o = 1'b0;
  assign l2db_tagctl_for_snoop_o = 1'b0;
  assign l2db_tagctl_for_write_o = 1'b0;
  assign l2db_slv_done_o = 1'b0;
  assign l2db_snpslv_done_o = 1'b0;
  assign l2db_slv_master_arb_o = 1'b0;
  assign l2db_full_line_o = 1'b0;
  assign l2db_rmw_line_o = 1'b0;
  assign l2db_master_valid_o = 1'b0;
  assign l2db_master_id_o = {6{1'b0}};
  assign l2db_master_dbid_o = {8{1'b0}};
  assign l2db_master_tgtid_o = {7{1'b0}};
  assign l2db_master_qos_o = {4{1'b0}};
  assign l2db_master_snoop_o = 1'b0;
  assign l2db_master_data_o = {128{1'b0}};
  assign l2db_master_strb_o = {16{1'b0}};
  assign l2db_master_chunk_o = 2'b00;
  assign l2db_master_last_o = 1'b0;
  assign l2db_master_opcode_o = 3'b000;
  assign l2db_master_snpresp_o = 3'b000;
  assign l2db_master_len_o = 2'b00;
  assign l2db_master_size_o = 3'b000;
  assign l2db_master_addr_o = {6{1'b0}};
  assign l2db_master_attrs_o = {8{1'b0}};
  assign l2db_master_prot_o = 1'b0;
  assign l2db_master_strex_o = 1'b0;
  assign l2db_master_unique_o = 1'b0;
  assign l2db_master_err_o = 1'b0;
  assign l2db_master_invalidated_o = 1'b0;
  assign l2db_master_dirty_o = 1'b0;
  assign l2db_ramctl_valid_o = 1'b0;
  assign l2db_ramctl_index_o = {11{1'b0}};
  assign l2db_ramctl_way_o = 4'b0000;
  assign l2db_ramctl_rw_o = 2'b00;
  assign l2db_ramctl_banks_o = {8{1'b0}};
  assign l2db_ramctl_data_o = {256{1'b0}};
  assign l2db_ramctl_err_o = 1'b0;
  assign l2db_slv_valid_o = 1'b0;
  assign l2db_slv_id_o = {6{1'b0}};
  assign l2db_slv_biuid_o = {5{1'b0}};
  assign l2db_slv_data_o = {128{1'b0}};
  assign l2db_slv_chunk_o = 2'b00;
  assign l2db_slv_last_o = 1'b0;
  assign l2db_slv_bypass_o = 1'b0;
  assign l2db_slv_err_o = 1'b0;
  assign l2db_cpuslv0_data_active_o = 1'b0;
  assign l2db_cpuslv1_data_active_o = 1'b0;
  assign l2db_cpuslv2_data_active_o = 1'b0;
  assign l2db_cpuslv3_data_active_o = 1'b0;
end endgenerate


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
