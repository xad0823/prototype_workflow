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
//      Checked In          : $Date: 2014-07-03 09:32:30 +0100 (Thu, 03 Jul 2014) $
//
//      Revision            : $Revision: 283879 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
//  The Skyros master block implements the Skyros specific parts of the master
//  interface. It includes the TXREQ, RXRSP, TXDAT, and RXDAT channels.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_master_skyros #(`CA53_SCU_INT_PARAM_DECL, parameter NUM_RBUFS = 1)
 (
  input  wire                 clk,
  input  wire                 clk_master,
  input  wire                 clk_ext_master,
  input  wire                 reset_n,
  input  wire                 clean_aclken_i,
  input  wire                 config_broadcastinner_i,
  input  wire                 config_broadcastouter_i,
  input  wire                 tagctl_master_active_i,
  input  wire                 snpslv_master_active_i,
  input  wire                 standbywfil2_req_i,
  output wire                 clk_enable_ext_o,
  output wire                 master_linkactive_o,
  output wire                 interface_active_o,
  output wire                 err_response_o,

  // External channels
  input  wire [6:0]           config_nodeid_i,
  output wire                 scu_txsactive_o,
  input  wire                 ext_rxlinkactivereq_i,
  output wire                 scu_rxlinkactiveack_o,
  output wire                 scu_txlinkactivereq_o,
  input  wire                 ext_txlinkactiveack_i,

  output wire                 scu_txreqflitpend_o,
  output wire                 scu_txreqflitv_o,
  output wire [99:0]          scu_txreqflit_o,
  input  wire                 ext_txreqlcrdv_i,
  output wire [7:0]           scu_reqmemattr_o,

  output wire                 scu_txdatflitpend_o,
  output wire                 scu_txdatflitv_o,
  output wire [193:0]         scu_txdatflit_o,
  input  wire                 ext_txdatlcrdv_i,

  input  wire                 ext_rxrspflitpend_i,
  input  wire                 ext_rxrspflitv_i,
  input  wire [44:0]          ext_rxrspflit_i,
  output wire                 scu_rxrsplcrdv_o,

  input  wire                 ext_rxdatflitpend_i,
  input  wire                 ext_rxdatflitv_i,
  input  wire [193:0]         ext_rxdatflit_i,
  output wire                 scu_rxdatlcrdv_o,

  // Arbitrated address requests
  input  wire                 addr_arb_req_i,
  input  wire                 addr_arb_early_req_i,
  input  wire [6:0]           addr_arb_id_i,
  input  wire [40:0]          addr_arb_addr_i,
  input  wire [4:0]           addr_arb_opcode_i,
  input  wire [1:0]           addr_arb_len_i,
  input  wire [2:0]           addr_arb_size_i,
  input  wire                 addr_arb_lock_i,
  input  wire [7:0]           addr_arb_attrs_i,
  input  wire [1:0]           addr_arb_prot_i,
  input  wire [3:0]           addr_arb_l2db_i,
  input  wire [6:0]           addr_arb_tgtid_i,
  input  wire                 addr_arb_static_pcredit_i,
  input  wire [1:0]           addr_arb_pcrdtype_i,
  output wire                 addr_arb_ack_o,
  output wire                 next_addr_arb_ack_o,

  // Arbitrated data requests
  input  wire                 data_arb_req_i,
  input  wire                 data_arb_snoop_i,
  input  wire [NUM_L2DBS-1:0] data_arb_i,
  input  wire [7:0]           data_arb_dbid_i,
  input  wire [6:0]           data_arb_tgtid_i,
  input  wire [3:0]           data_arb_qos_i,
  input  wire [127:0]         data_arb_data_i,
  input  wire [15:0]          data_arb_strb_i,
  input  wire [1:0]           data_arb_chunk_i,
  input  wire                 data_arb_err_i,
  input  wire [2:0]           data_arb_opcode_i,
  input  wire [2:0]           data_arb_snpresp_i,
  input  wire [5:4]           data_arb_addr_i,
  input  wire                 data_arb_unique_i,
  output wire                 data_arb_sel_snoop_o,
  output wire                 data_arb_sel_write_o,
  output wire                 data_arb_sel_write_first_o,
  output wire                 data_arb_dw_ready_o,
  output wire                 data_arb_cd_ready_o,

  // L2DB status
  input  wire                 l2db10_master_invalidated_i,
  input  wire                 l2db9_master_invalidated_i,
  input  wire                 l2db8_master_invalidated_i,
  input  wire                 l2db7_master_invalidated_i,
  input  wire                 l2db6_master_invalidated_i,
  input  wire                 l2db5_master_invalidated_i,
  input  wire                 l2db4_master_invalidated_i,
  input  wire                 l2db3_master_invalidated_i,
  input  wire                 l2db2_master_invalidated_i,
  input  wire                 l2db1_master_invalidated_i,
  input  wire                 l2db0_master_invalidated_i,

  input  wire                 l2db10_master_dirty_i,
  input  wire                 l2db9_master_dirty_i,
  input  wire                 l2db8_master_dirty_i,
  input  wire                 l2db7_master_dirty_i,
  input  wire                 l2db6_master_dirty_i,
  input  wire                 l2db5_master_dirty_i,
  input  wire                 l2db4_master_dirty_i,
  input  wire                 l2db3_master_dirty_i,
  input  wire                 l2db2_master_dirty_i,
  input  wire                 l2db1_master_dirty_i,
  input  wire                 l2db0_master_dirty_i,

  input  wire                 l2db10_master_unique_i,
  input  wire                 l2db9_master_unique_i,
  input  wire                 l2db8_master_unique_i,
  input  wire                 l2db7_master_unique_i,
  input  wire                 l2db6_master_unique_i,
  input  wire                 l2db5_master_unique_i,
  input  wire                 l2db4_master_unique_i,
  input  wire                 l2db3_master_unique_i,
  input  wire                 l2db2_master_unique_i,
  input  wire                 l2db1_master_unique_i,
  input  wire                 l2db0_master_unique_i,

  // Read responses
  output wire                 read_resp_valid_o,
  output wire [3:0]           read_resp_o,
  output wire [127:0]         read_resp_data_o,
  output wire [5:0]           read_resp_id_o,
  output wire [5:0]           read_resp_cpuslv0_id_o,
  output wire [5:0]           read_resp_cpuslv1_id_o,
  output wire [5:0]           read_resp_cpuslv2_id_o,
  output wire [5:0]           read_resp_cpuslv3_id_o,
  output wire [5:0]           read_resp_acpslv_id_o,
  output wire [7:0]           read_resp_dbid_o,
  output wire [6:0]           read_resp_srcid_o,
  output wire [1:0]           read_resp_chunk_o,
  input wire                  read_resp_ready_i,
  input wire [4:0]            rbuf_valid_i,
  input wire [3:0]            credit_return_i,

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
  output wire [1:0]           master_snpslv_pcrdtype_o,

  // Skyros responses
  output wire                 master_rsp_dbid_valid_o,
  output wire                 master_rsp_comp_valid_o,
  output wire                 master_rsp_readreceipt_valid_o,
  output wire [6:0]           master_rsp_txnid_o,
  output wire [7:0]           master_rsp_dbid_o,
  output wire [6:0]           master_rsp_srcid_o,
  output wire [3:0]           master_rsp_resp_o,

  // Snpslv interaction
  input  wire                 snpslv_txrsp_req_i,
  input  wire                 snpslv_rxsnp_active_i,
  input  wire                 snpslv_active_i,
  input  wire                 cpuslv0_compack_valid_i,
  input  wire                 cpuslv1_compack_valid_i,
  input  wire                 cpuslv2_compack_valid_i,
  input  wire                 cpuslv3_compack_valid_i,
  input  wire                 acpslv_compack_valid_i,
  output wire                 master_rxla_run_o,
  output wire                 master_rxla_deactivate_o,
  output wire                 master_rxla_stop_o,
  output wire                 master_txla_run_o,
  output wire                 master_txla_deactivate_o,
  input  wire                 cpuslv0_master_sactive_i,
  input  wire                 cpuslv1_master_sactive_i,
  input  wire                 cpuslv2_master_sactive_i,
  input  wire                 cpuslv3_master_sactive_i,
  input  wire                 acpslv_master_sactive_i,

  // Hazarding
  input  wire [41:6]          tagctl_addr_tc1_i,
  input  wire                 tagctl_addr_valid_tc1_i,
  input  wire [40:6]          tagctl_addr_tc3_i,
  input  wire                 tagctl_addr_valid_tc3_i,
  input  wire [5:0]           tagctl_reqbufid_tc1_i,
  output wire                 master_hz_tc2_o,
  output wire                 master_hz_tc4_o,
  output wire                 master_hz_l2db_tc2_o,
  output wire                 master_hz_dirty_tc2_o,
  output wire                 master_hz_cu_tc2_o,
  output wire [3:0]           master_l2db_tc2_o
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  localparam RXDAT_CREDITS = NUM_RBUFS + 1;

  // External channels
  reg                                   scu_txsactive;
  reg                                   txlinkactivereq;
  reg                                   txlinkactiveack;
  reg                                   rxlinkactivereq;
  reg                                   rxlinkactiveack;

  reg                                   scu_txreqflitpend;
  reg                                   scu_txreqflitv;
  reg                                   txreqlcrdv;
  reg [6:0]                             txreqflit_tgtid;
  reg [6:0]                             txreqflit_txnid;
  reg [4:0]                             txreqflit_opcode;
  reg [2:0]                             txreqflit_size;
  reg [40:0]                            txreqflit_addr;
  reg                                   txreqflit_ns;
  reg                                   txreqflit_likelyshared;
  reg                                   txreqflit_dynpcrd;
  reg [1:0]                             txreqflit_order;
  reg [1:0]                             txreqflit_pcrdtype;
  reg [3:0]                             txreqflit_memattr;
  reg [1:0]                             txreqflit_snpattr;
  reg [2:0]                             txreqflit_lpid;
  reg                                   txreqflit_excl;
  reg                                   txreqflit_expcompack;
  reg [7:0]                             scu_reqmemattr;

  reg                                   txdatlcrdv;
  reg                                   scu_txdatflitpend;
  reg                                   scu_txdatflitv;
  reg [3:0]                             scu_txdatflit_qos;
  reg [6:0]                             scu_txdatflit_tgtid;
  reg [7:0]                             scu_txdatflit_txnid;
  reg [1:0]                             scu_txdatflit_opcode;
  reg                                   scu_txdatflit_resperr;
  reg [2:0]                             scu_txdatflit_resp;
  reg [1:0]                             scu_txdatflit_ccid;
  reg [1:0]                             scu_txdatflit_dataid;
  reg [15:0]                            scu_txdatflit_be;
  reg [127:0]                           scu_txdatflit_data;

  reg                                   rxrspflitpend;
  reg                                   scu_rxrsplcrdv;

  reg                                   rxdatflitpend;
  reg                                   scu_rxdatlcrdv;

  reg                                   waddr_valid  [NUM_L2DBS-1:0];
  reg [34:0]                            waddr_addr   [NUM_L2DBS-1:0];
  reg [4:0]                             waddr_opcode [NUM_L2DBS-1:0];
  reg [6:0]                             waddr_tgtid  [NUM_L2DBS-1:0];
  reg [7:0]                             waddr_attrs  [NUM_L2DBS-1:0];
  reg [NUM_L2DBS-1:0]                   waddr_force;
  reg                                   master_hz_tc2;
  reg                                   master_hz_l2db_tc2;
  reg                                   master_hz_dirty_tc2;
  reg                                   master_hz_cu_tc2;
  reg [3:0]                             master_l2db_tc2;
  reg                                   master_hz_tc4;
  reg [`CA53_LOG2(RXDAT_CREDITS)-1:0]   rbuf_credits;
  reg                                   rbuf_credit_return_decr;
  reg [3:0]                             rbuf_credit_return;

  wire [NUM_L2DBS-1:0]                  waddr_valid_en;
  wire [NUM_L2DBS-1:0]                  waddr_en;
  wire [NUM_L2DBS-1:0]                  hazard_tc1;
  wire [NUM_L2DBS-1:0]                  hazard_tc3;
  wire [MAX_L2DBS-1:0]                  waddr_dirty;
  wire [MAX_L2DBS-1:0]                  waddr_unique;
  wire [MAX_L2DBS-1:0]                  waddr_invalidated;
  wire [NUM_L2DBS-1:0]                  l2db_hazard_tc1;
  wire [NUM_L2DBS-1:0]                  l2db_hz_tc1;
  wire [6:0]                            next_waddr_tgtid  [NUM_L2DBS-1:0];
  wire [7:0]                            next_waddr_attrs  [NUM_L2DBS-1:0];
  wire [15:0]                           waddr_hz_tc1;
  wire                                  next_master_hz_tc2;
  wire                                  next_master_hz_l2db_tc2;
  wire                                  next_master_hz_dirty_tc2;
  wire                                  next_master_hz_cu_tc2;
  wire [3:0]                            next_master_l2db_tc2;
  wire                                  next_master_hz_tc4;
  wire                                  link_credit_valid;
  wire [2:0]                            rbuf_credit_incr;
  wire [1:0]                            rbuf_credit_decr;
  wire                                  next_rbuf_credit_return_decr;
  wire [`CA53_LOG2(RXDAT_CREDITS)-1:0]  next_rbuf_credits;
  wire [`CA53_LOG2(RXDAT_CREDITS)-1:0]  rbuf_avail_credits;
  wire                                  rbuf_early_credit;

  // Read data channel
  reg                                   ext_read_valid;
  reg                                   read_resp_sent;
  reg                                   read_resp_opcode;
  reg [127:0]                           read_resp_data;
  reg [5:0]                             read_resp_id;
  reg [7:0]                             read_resp_dbid;
  reg [1:0]                             read_resp_chunk;
  reg [1:0]                             read_resp_resperr;
  reg                                   read_resp_resp_is;
  reg                                   read_resp_resp_pd;
  reg [6:0]                             read_resp_srcid;

  wire                                  next_read_resp_sent;
  wire                                  rxdat_en;
  wire                                  read_resp_valid;

  reg [3:0]                             txdat_credits;
  wire                                  txdat_credits_en;
  wire [3:0]                            next_txdat_credits;
  wire                                  txdat_credit_avail;
  wire                                  scu_txdatflit_en;
  wire                                  next_scu_txdatflitpend;
  wire                                  next_scu_txdatflitv;
  wire [3:0]                            next_scu_txdatflit_qos;
  wire [7:0]                            next_scu_txdatflit_txnid;
  reg [2:0]                             txdat_opcode;
  wire [2:0]                            next_scu_txdatflit_opcode;
  reg [2:0]                             next_scu_txdatflit_resp;
  wire                                  txreqflit_en;
  wire [6:0]                            next_txreqflit_tgtid;
  wire [6:0]                            next_txreqflit_txnid;
  wire [4:0]                            next_txreqflit_opcode;
  wire [2:0]                            next_txreqflit_size;
  wire [40:0]                           next_txreqflit_addr;
  wire                                  next_txreqflit_ns;
  wire                                  next_txreqflit_likelyshared;
  wire                                  next_txreqflit_dynpcrd;
  wire [1:0]                            next_txreqflit_order;
  wire [1:0]                            next_txreqflit_pcrdtype;
  wire [3:0]                            next_txreqflit_memattr;
  wire [1:0]                            next_txreqflit_snpattr;
  wire [2:0]                            next_txreqflit_lpid;
  wire                                  next_txreqflit_excl;
  wire                                  next_txreqflit_expcompack;
  wire [7:0]                            next_scu_reqmemattr;
  wire                                  txreq_mem_coh;
  reg  [4:0]                            txreq_opcode;
  wire                                  data_force_non_shareable;

  reg [6:0]                             rxrsp_srcid;
  reg [6:0]                             rxrsp_txnid;
  reg [3:0]                             rxrsp_opcode;
  reg [1:0]                             rxrsp_resperr;
  reg [2:0]                             rxrsp_resp;
  reg [7:0]                             rxrsp_dbid;
  reg [1:0]                             rxrsp_pcrdtype;
  reg [3:0]                             rxrsp_credits;

  reg                                   ext_rsp_valid;
  reg                                   rsp_sent;
  wire                                  rsp_valid;
  wire                                  next_scu_rxrsplcrdv;
  wire                                  rxrsp_credits_en;
  wire [3:0]                            next_rxrsp_credits;
  wire                                  rxrsp_en;
  wire                                  next_scu_rxdatlcrdv;
  wire                                  next_rsp_sent;

  reg [3:0]                             txreq_credits;
  reg                                   addr_arb_ack;

  wire [3:0]                            next_txreq_credits;
  wire                                  txreq_credits_en;
  wire                                  txreq_credit_avail;
  wire                                  send_retry;
  wire                                  next_scu_txreqflitpend;
  wire                                  next_scu_txreqflitv;
  wire                                  next_addr_arb_ack;
  wire                                  force_non_shareable;
  wire                                  alloc_waddr;
  wire                                  master_rsp_dbid_valid;
  wire                                  master_rsp_comp_valid;
  wire                                  comp_waddr_valid;
  wire [3:0]                            comp_waddr;
  wire [7:0]                            txreq_attrs;
  wire [15:0]                           waddr_arbitrated;
  wire [3:0]                            retry_waddr;
  wire [34:0]                           retry_addr;
  wire [6:0]                            retry_tgtid;
  wire [7:0]                            retry_attrs;
  wire [4:0]                            retry_opcode;
  wire                                  txreq_rr_en;
  wire                                  txreq_l2db_rr_en;
  wire [1:0]                            txreq_req;
  wire [NUM_L2DBS:0]                    txreq_arb;
  wire [1:0]                            txreq_partial_arb;
  wire [NUM_L2DBS-1:0]                  txreq_l2db_arb;
  wire [NUM_L2DBS-1:0]                  l2db_retry_valid;
  wire [NUM_L2DBS-1:0]                  l2db_retry_ready;
  wire [1:0]                            l2db_retry_pcrdtype;
  wire                                  l2db_retry_active;
  wire                                  next_txlinkactivereq;
  wire                                  next_rxlinkactiveack;
  wire                                  next_scu_txsactive;
  wire                                  txla_stop;
  wire                                  txla_activate;
  wire                                  txla_run;
  wire                                  txla_deactivate;
  wire                                  rxla_stop;
  wire                                  rxla_activate;
  wire                                  rxla_run;
  wire                                  rxla_deactivate;
  wire                                  txlink_req;

  genvar i;

  //-----------------------------------------------------------------------------
  //  TXREQ channel
  //-----------------------------------------------------------------------------

  // Credit management. Keep a count of all L-credits received, and not yet used.

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    txreqlcrdv <= 1'b0;
  end else if (clean_aclken_i) begin
    txreqlcrdv <= ext_txreqlcrdv_i;
  end

  assign txreq_credits_en = clean_aclken_i & (txreqlcrdv ^ next_scu_txreqflitv);

  assign next_txreq_credits = txreqlcrdv ? (txreq_credits + 4'b0001) : (txreq_credits - 4'b0001);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    txreq_credits <= 4'b0000;
  end else if (txreq_credits_en) begin
    txreq_credits <= next_txreq_credits;
  end

  assign txreq_credit_avail = (|txreq_credits | txreqlcrdv) & txla_run & ~rxla_deactivate & scu_txreqflitpend & clean_aclken_i;

  // Record if this request has been sent, so it can be signalled back to the
  // arbiter in the following cycle.
  assign next_addr_arb_ack = (addr_arb_req_i & ~send_retry) & txreq_credit_avail;

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    addr_arb_ack <= 1'b0;
  end else begin
    addr_arb_ack <= next_addr_arb_ack;
  end

  assign addr_arb_ack_o = addr_arb_ack;
  assign next_addr_arb_ack_o = next_addr_arb_ack;

  // Arbitrate between all waddrs and the new tagctl request, if more than one
  // wants to send on the TXREQ channel.
  assign txreq_req = {addr_arb_early_req_i, |l2db_retry_valid};

  assign txreq_rr_en = |txreq_req & txreq_credit_avail;

  ca53_rr_reg_arb #(.WIDTH(2)) u_txreq_arb (
    .clk        (clk_master),
    .reset_n    (reset_n),
    .enable_i   (txreq_rr_en),
    .requests_i (txreq_req),
    .arb_o      (txreq_partial_arb)
  );

  assign txreq_l2db_rr_en = txreq_partial_arb[0] & txreq_credit_avail;

  ca53_rr_reg_arb #(.WIDTH(NUM_L2DBS)) u_txreq_l2db_arb (
    .clk        (clk_master),
    .reset_n    (reset_n),
    .enable_i   (txreq_l2db_rr_en),
    .requests_i (l2db_retry_valid),
    .arb_o      (txreq_l2db_arb)
  );

  assign txreq_arb = {txreq_partial_arb[1], {NUM_L2DBS{txreq_partial_arb[0]}} & txreq_l2db_arb};

  assign l2db_retry_ready = {NUM_L2DBS{send_retry & txreq_credit_avail}} & txreq_arb[NUM_L2DBS-1:0];

  // Indicate when we might be sending a flit in the following cycle.
  assign next_scu_txreqflitpend = (txla_deactivate |
                                   (txla_run & (tagctl_master_active_i | l2db_retry_active)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_txreqflitpend <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_txreqflitpend <= next_scu_txreqflitpend;
  end

  assign scu_txreqflitpend_o = scu_txreqflitpend;

  // Calculate external valid signal.
  assign next_scu_txreqflitv = (((addr_arb_req_i | send_retry) & txreq_credit_avail) |
                                (txla_deactivate & |txreq_credits & scu_txreqflitpend));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_txreqflitv <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_txreqflitv <= next_scu_txreqflitv;
  end

  assign scu_txreqflitv_o = scu_txreqflitv;

  // Generate the TXREQ flit contents.

  assign next_txreqflit_tgtid = send_retry ? retry_tgtid : addr_arb_tgtid_i;

  assign next_txreqflit_txnid = (txla_deactivate ? {7{1'b0}} :
                                 send_retry      ? {3'b100, retry_waddr} :
                                 alloc_waddr     ? {3'b100, addr_arb_l2db_i} :
                                                   {1'b0, addr_arb_id_i[5:0]});

  assign txreq_attrs = send_retry ? retry_attrs : addr_arb_attrs_i;

  // If the access is to a shareability less than what must be broadcast
  // externally, then we must force the access to be non-shareable as far
  // as the outside world is concerned.
  assign force_non_shareable = (~(((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB)) & ~send_retry) &
                                (~`CA53_MEM_SHAREABLE(txreq_attrs) |
                                 ~config_broadcastouter_i |
                                 (~`CA53_MEM_O_SHAREABLE(txreq_attrs) & ~config_broadcastinner_i)));

  always @*
  case (addr_arb_opcode_i)
    `CA53_REQ_OPCODE_READNOSNOOP:      txreq_opcode = `CA53_SKYROS_REQ_READNOSNOOP;
    `CA53_REQ_OPCODE_READONCE:         txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_READNOSNOOP : `CA53_SKYROS_REQ_READONCE;
    `CA53_REQ_OPCODE_READSHARED:       txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_READNOSNOOP : `CA53_SKYROS_REQ_READSHARED;
    `CA53_REQ_OPCODE_READUNIQUE:       txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_READNOSNOOP : `CA53_SKYROS_REQ_READUNIQUE;
    `CA53_REQ_OPCODE_CLEANSHARED:      txreq_opcode = `CA53_SKYROS_REQ_CLEANSHARED;
    `CA53_REQ_OPCODE_CLEANINVALID:     txreq_opcode = `CA53_SKYROS_REQ_CLEANINVALID;
    `CA53_REQ_OPCODE_MAKEINVALID:      txreq_opcode = `CA53_SKYROS_REQ_MAKEINVALID;
    `CA53_REQ_OPCODE_CLEANUNIQUE:      txreq_opcode = `CA53_SKYROS_REQ_CLEANUNIQUE;
    `CA53_REQ_OPCODE_MAKEUNIQUE:       txreq_opcode = `CA53_SKYROS_REQ_MAKEUNIQUE;
    `CA53_REQ_OPCODE_DMB:              txreq_opcode = `CA53_SKYROS_REQ_DMB;
    `CA53_REQ_OPCODE_DSB:              txreq_opcode = `CA53_SKYROS_REQ_DSB;
    `CA53_REQ_OPCODE_DVM:              txreq_opcode = `CA53_SKYROS_REQ_DVM;
    `CA53_REQ_OPCODE_DVM_COMPLETE:     txreq_opcode = `CA53_SKYROS_REQ_DVM;
    `CA53_REQ_OPCODE_EVICT:            txreq_opcode = `CA53_SKYROS_REQ_EVICT;
    `CA53_REQ_OPCODE_EVICTDATA:        txreq_opcode = `CA53_SKYROS_REQ_WRITEEVICTFULL;
    `CA53_REQ_OPCODE_WRITECLEAN:       txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_WRITENOSNOOPFULL : `CA53_SKYROS_REQ_WRITECLEANFULL;
    `CA53_REQ_OPCODE_WRITEUNIQUE:      txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_WRITENOSNOOPPTL  : `CA53_SKYROS_REQ_WRITEUNIQUEPTL;
    `CA53_REQ_OPCODE_WRITELINEUNIQUE:  txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_WRITENOSNOOPFULL : `CA53_SKYROS_REQ_WRITEUNIQUEFULL;
    `CA53_REQ_OPCODE_WRITEBACKPTL:     txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_WRITENOSNOOPPTL  : `CA53_SKYROS_REQ_WRITEBACKPTL;
    `CA53_REQ_OPCODE_WRITEBACK:        txreq_opcode = force_non_shareable ? `CA53_SKYROS_REQ_WRITENOSNOOPFULL : `CA53_SKYROS_REQ_WRITEBACKFULL;
    `CA53_REQ_OPCODE_WRITENOSNOOP:     txreq_opcode = `CA53_SKYROS_REQ_WRITENOSNOOPPTL;
    `CA53_REQ_OPCODE_WRITENOSNOOPFULL: txreq_opcode = `CA53_SKYROS_REQ_WRITENOSNOOPFULL;
    default:                           txreq_opcode = 5'bxxxxx;
  endcase

  assign next_txreqflit_opcode = (txla_deactivate ? `CA53_SKYROS_REQ_LINKFLIT :
                                  send_retry      ? retry_opcode :
                                                    txreq_opcode);

  assign next_txreqflit_size = (send_retry                                    ? 3'b110 :
                                (addr_arb_len_i == 2'b11)                     ? 3'b110 :
                                (addr_arb_len_i == 2'b01)                     ? 3'b101 :
                                ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB)) ? 3'b000 :
                                ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? 3'b011 :
                                                                                addr_arb_size_i);

  assign next_txreqflit_addr = send_retry ? {1'b0, retry_addr[33:0], 6'b000000} :
                               ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? {addr_arb_addr_i[4:2],
                                                                                addr_arb_addr_i[39:32],
                                                                                addr_arb_addr_i[23:16],
                                                                                addr_arb_addr_i[31:24],
                                                                                addr_arb_addr_i[14:8],
                                                                                addr_arb_addr_i[5],
                                                                                addr_arb_addr_i[6],
                                                                                addr_arb_addr_i[0],
                                                                                4'b0000} :
                                            {1'b0, addr_arb_addr_i[39:0]};

  assign next_txreqflit_ns = send_retry ? retry_addr[34] :
                             ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                              (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? 1'b0 : addr_arb_addr_i[40];

  assign next_txreqflit_likelyshared = send_retry ? 1'b0 : (addr_arb_prot_i[1] &
                                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_READSHARED) &
                                                            ~force_non_shareable);

  assign next_txreqflit_dynpcrd = send_retry ? 1'b0 : ~addr_arb_static_pcredit_i;

  assign next_txreqflit_order = (`CA53_MEM_REORDERABLE(txreq_attrs) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? 2'b00 : 2'b11;

  assign next_txreqflit_pcrdtype = send_retry ? l2db_retry_pcrdtype : addr_arb_pcrdtype_i;

  assign next_txreqflit_lpid = (send_retry | alloc_waddr) ? 3'b111 : addr_arb_id_i[5:3];

  assign next_txreqflit_excl = send_retry ? 1'b0 : (addr_arb_lock_i &
                                                    ~(`CA53_MEM_COHERENT(txreq_attrs) &
                                                      force_non_shareable));

  assign next_txreqflit_expcompack = send_retry ? 1'b0 : (`CA53_REQ_OPCODE_IS_READ(addr_arb_opcode_i) &
                                                          ~((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assign txreq_mem_coh = `CA53_MEM_COHERENT(txreq_attrs) | (addr_arb_opcode_i == `CA53_REQ_OPCODE_CLEANSHARED);

  assign next_txreqflit_memattr = ((((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) & ~send_retry) ? 4'b0000 :
                                   {txreq_mem_coh &
                                    ((send_retry ? 1'b0 : `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode_i)) ? `CA53_MEM_OUTER_RA(txreq_attrs) :
                                                                                                         `CA53_MEM_OUTER_WA(txreq_attrs)) &
                                    (next_txreqflit_opcode != `CA53_SKYROS_REQ_EVICT),
                                    txreq_mem_coh,
                                    `CA53_MEM_DEVICE(txreq_attrs),
                                    ~`CA53_MEM_nGnRnE(txreq_attrs)});

  assign next_txreqflit_snpattr = ((((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) & ~send_retry) |
                                   force_non_shareable) ? 2'b00 : {txreq_mem_coh &
                                                                   `CA53_MEM_O_SHAREABLE(txreq_attrs),
                                                                   txreq_mem_coh &
                                                                   `CA53_MEM_SHAREABLE(txreq_attrs)};

  assign next_scu_reqmemattr = `CA53_ATTRS_TO_MEMATTR(txreq_attrs);


  assign txreqflit_en = clean_aclken_i & next_scu_txreqflitv;

  always @(posedge clk_master)
  if (txreqflit_en) begin
    txreqflit_tgtid        <= next_txreqflit_tgtid;
    txreqflit_txnid        <= next_txreqflit_txnid;
    txreqflit_opcode       <= next_txreqflit_opcode;
    txreqflit_size         <= next_txreqflit_size;
    txreqflit_addr         <= next_txreqflit_addr;
    txreqflit_ns           <= next_txreqflit_ns;
    txreqflit_likelyshared <= next_txreqflit_likelyshared;
    txreqflit_dynpcrd      <= next_txreqflit_dynpcrd;
    txreqflit_order        <= next_txreqflit_order;
    txreqflit_pcrdtype     <= next_txreqflit_pcrdtype;
    txreqflit_memattr      <= next_txreqflit_memattr;
    txreqflit_snpattr      <= next_txreqflit_snpattr;
    txreqflit_lpid         <= next_txreqflit_lpid;
    txreqflit_excl         <= next_txreqflit_excl;
    txreqflit_expcompack   <= next_txreqflit_expcompack;
    scu_reqmemattr         <= next_scu_reqmemattr;
  end

  assign scu_txreqflit_o = {4'b0000,
                            txreqflit_expcompack,
                            txreqflit_excl,
                            txreqflit_lpid,
                            txreqflit_snpattr,
                            txreqflit_memattr,
                            txreqflit_pcrdtype,
                            txreqflit_order,
                            txreqflit_dynpcrd,
                            txreqflit_likelyshared,
                            txreqflit_ns,
                            3'b000,
                            txreqflit_addr,
                            txreqflit_size,
                            txreqflit_opcode,
                            1'b0,
                            txreqflit_txnid,
                            config_nodeid_i,
                            txreqflit_tgtid,
                            4'b0000};

  assign scu_reqmemattr_o = scu_reqmemattr;

  //-----------------------------------------------------------------------------
  //  Write address hazard buffers
  //-----------------------------------------------------------------------------

  // A waddr is only allocated for L1 or L2 evictions. All other requests are
  // handled in the reqbuf.
  assign alloc_waddr = next_addr_arb_ack & ((addr_arb_opcode_i == `CA53_REQ_OPCODE_EVICT) |
                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_WRITECLEAN) |
                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_WRITEBACK) |
                                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_EVICTDATA));


  generate for (i = 0; i < NUM_L2DBS; i = i + 1) begin : g_buf

    // Enable the buffer when a new entry is written.
    assign waddr_en[i] = alloc_waddr & (addr_arb_l2db_i == i[3:0]);

    // Stop hazarding on this buffer if a received Comp or CompDBID response matches
    // this buffer entry.
    assign waddr_valid_en[i] = waddr_en[i] | (comp_waddr_valid & (comp_waddr == i[3:0]));

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      waddr_valid[i] <= 1'b0;
    end else if (waddr_valid_en[i]) begin
      waddr_valid[i] <= waddr_en[i];
    end

    // Capture the address for hazarding, and all the details of the request
    // that will be needed if it has to be retried later.
    always @(posedge clk_master)
    if (waddr_en[i]) begin
      waddr_addr[i]   <= addr_arb_addr_i[40:6];
      waddr_opcode[i] <= next_txreqflit_opcode;
      waddr_force[i]  <= force_non_shareable;
    end

    // Reuse some storage when the CompDBID is received. The target ID is
    // updated from the response packet, as if an external SAM is present
    // then it may be different from what we originally thought. The DBID
    // is stored in the attrs, as if we have a DBID we know we won't get a
    // retry and hence won't need the attrs anymore.
    assign next_waddr_tgtid[i] = waddr_en[i] ? addr_arb_tgtid_i : rxrsp_srcid;
    assign next_waddr_attrs[i] = waddr_en[i] ? addr_arb_attrs_i : rxrsp_dbid;

    always @(posedge clk_master)
    if (waddr_valid_en[i]) begin
      waddr_tgtid[i] <= next_waddr_tgtid[i];
      waddr_attrs[i] <= next_waddr_attrs[i];
    end

    // Hazard check the tc1 and tc3 addresses against the waddr buffers.
    assign hazard_tc1[i] = waddr_valid[i] & tagctl_addr_valid_tc1_i & (tagctl_addr_tc1_i == {1'b0, waddr_addr[i]});
    assign hazard_tc3[i] = waddr_valid[i] & tagctl_addr_valid_tc3_i & (tagctl_addr_tc3_i == waddr_addr[i]);

  end endgenerate

  assign waddr_invalidated = {l2db10_master_invalidated_i,
                              l2db9_master_invalidated_i,
                              l2db8_master_invalidated_i,
                              l2db7_master_invalidated_i,
                              l2db6_master_invalidated_i,
                              l2db5_master_invalidated_i,
                              l2db4_master_invalidated_i,
                              l2db3_master_invalidated_i,
                              l2db2_master_invalidated_i,
                              l2db1_master_invalidated_i,
                              l2db0_master_invalidated_i};                              

  assign waddr_dirty = {l2db10_master_dirty_i,
                        l2db9_master_dirty_i,
                        l2db8_master_dirty_i,
                        l2db7_master_dirty_i,
                        l2db6_master_dirty_i,
                        l2db5_master_dirty_i,
                        l2db4_master_dirty_i,
                        l2db3_master_dirty_i,
                        l2db2_master_dirty_i,
                        l2db1_master_dirty_i,
                        l2db0_master_dirty_i};                              

  assign waddr_unique = {l2db10_master_unique_i,
                         l2db9_master_unique_i,
                         l2db8_master_unique_i,
                         l2db7_master_unique_i,
                         l2db6_master_unique_i,
                         l2db5_master_unique_i,
                         l2db4_master_unique_i,
                         l2db3_master_unique_i,
                         l2db2_master_unique_i,
                         l2db1_master_unique_i,
                         l2db0_master_unique_i};                              

  // Register the hazard comparison results before returning them to tagctl.
  assign next_master_hz_tc2 = |(hazard_tc1 & ~{NUM_L2DBS{`CA53_REQBUF_IS_SNOOP(tagctl_reqbufid_tc1_i)}});

  assign l2db_hazard_tc1 = (hazard_tc1 &  {NUM_L2DBS{`CA53_REQBUF_IS_SNOOP(tagctl_reqbufid_tc1_i)}} &
                            ~waddr_force & ~waddr_invalidated[NUM_L2DBS-1:0]);

  assign next_master_hz_l2db_tc2 = |l2db_hazard_tc1;

  // Pick the lowest numbered L2DB that hazards
  assign l2db_hz_tc1[0] = l2db_hazard_tc1[0];

  generate for (i = 1; i < NUM_L2DBS; i = i + 1) begin : g_l2db_hz
    assign l2db_hz_tc1[i] = l2db_hazard_tc1[i] & ~|l2db_hazard_tc1[i-1:0];
  end endgenerate

  assign next_master_hz_dirty_tc2 = |(l2db_hz_tc1[NUM_L2DBS-1:0] & waddr_dirty[NUM_L2DBS-1:0]);
  assign next_master_hz_cu_tc2    = |(l2db_hz_tc1[NUM_L2DBS-1:0] & waddr_unique[NUM_L2DBS-1:0]);
  assign next_master_hz_tc4       = |hazard_tc3;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    master_hz_tc2       <= 1'b0;
    master_hz_l2db_tc2  <= 1'b0;
    master_hz_dirty_tc2 <= 1'b0;
    master_hz_cu_tc2    <= 1'b0;
    master_hz_tc4       <= 1'b0;
  end else begin
    master_hz_tc2       <= next_master_hz_tc2;
    master_hz_l2db_tc2  <= next_master_hz_l2db_tc2;
    master_hz_dirty_tc2 <= next_master_hz_dirty_tc2;
    master_hz_cu_tc2    <= next_master_hz_cu_tc2;
    master_hz_tc4       <= next_master_hz_tc4;
  end

  assign waddr_hz_tc1 = {{(16 - NUM_L2DBS){1'b0}}, l2db_hz_tc1};

  assign next_master_l2db_tc2 = `CA53_L2_WAY_ENC(waddr_hz_tc1);

  always @(posedge clk)
  begin
    master_l2db_tc2 <= next_master_l2db_tc2;
  end

  assign master_hz_tc2_o       = master_hz_tc2;
  assign master_hz_l2db_tc2_o  = master_hz_l2db_tc2;
  assign master_hz_dirty_tc2_o = master_hz_dirty_tc2;
  assign master_hz_cu_tc2_o    = master_hz_cu_tc2;
  assign master_l2db_tc2_o     = master_l2db_tc2;
  assign master_hz_tc4_o       = master_hz_tc4;

  // Send a waddr retry if no new request got arbitrated.
  assign send_retry = txreq_rr_en & ~txreq_arb[NUM_L2DBS];

  assign waddr_arbitrated = {{(16 - NUM_L2DBS){1'b0}}, txreq_arb[NUM_L2DBS-1:0]};

  assign retry_waddr = `CA53_L2_WAY_ENC(waddr_arbitrated);

  `CA53_ONEHOT_MUX(retry_addr,  35, txreq_arb[NUM_L2DBS-1:0], waddr_addr,   NUM_L2DBS, g_mux_retry_addr)
  `CA53_ONEHOT_MUX(retry_tgtid,  7, txreq_arb[NUM_L2DBS-1:0], waddr_tgtid,  NUM_L2DBS, g_mux_retry_tgtid)
  `CA53_ONEHOT_MUX(retry_attrs,  8, txreq_arb[NUM_L2DBS-1:0], waddr_attrs,  NUM_L2DBS, g_mux_retry_attrs)
  `CA53_ONEHOT_MUX(retry_opcode, 5, txreq_arb[NUM_L2DBS-1:0], waddr_opcode, NUM_L2DBS, g_mux_retry_opcode)

  //-----------------------------------------------------------------------------
  //  TXDAT channel
  //-----------------------------------------------------------------------------


  // Credit management. Keep a count of all L-credits received, and not yet used.

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    txdatlcrdv <= 1'b0;
  end else if (clean_aclken_i) begin
    txdatlcrdv <= ext_txdatlcrdv_i;
  end

  assign txdat_credits_en = clean_aclken_i & (txdatlcrdv ^ next_scu_txdatflitv);

  assign next_txdat_credits = txdatlcrdv ? (txdat_credits + 4'b0001) : (txdat_credits - 4'b0001);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    txdat_credits <= 4'b0000;
  end else if (txdat_credits_en) begin
    txdat_credits <= next_txdat_credits;
  end

  assign txdat_credit_avail = (|txdat_credits | txdatlcrdv) & txla_run & ~rxla_deactivate & scu_txdatflitpend & clean_aclken_i;

  // Indicate when we might be sending a flit in the following cycle.
  assign next_scu_txdatflitpend = (txla_deactivate |
                                   (txla_run & (snpslv_master_active_i |
                                                data_arb_req_i |
                                                master_rsp_dbid_valid)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_txdatflitpend <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_txdatflitpend <= next_scu_txdatflitpend;
  end

  assign scu_txdatflitpend_o = scu_txdatflitpend;

  // Calculate external valid signal
  assign next_scu_txdatflitv = ((data_arb_req_i & txdat_credit_avail) |
                                (txla_deactivate & |txdat_credits & scu_txdatflitpend));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_txdatflitv <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_txdatflitv <= next_scu_txdatflitv;
  end

  assign scu_txdatflitv_o = scu_txdatflitv;

  // An arbitrated request can always be accepted on a bus cycle if there is
  // a credit available.
  assign data_arb_dw_ready_o = txdat_credit_avail;
  assign data_arb_cd_ready_o = txdat_credit_avail;

  assign next_scu_txdatflit_qos = data_arb_snoop_i ? data_arb_qos_i : 4'b0000;

  assign next_scu_txdatflit_txnid = txla_deactivate ? 8'h00 : data_arb_dbid_i;

  // If the access is to a shareability less than what must be broadcast
  // externally, then we must force the access to be non-shareable as far
  // as the outside world is concerned.
  assign data_force_non_shareable = |(data_arb_i & waddr_force);

  always @*
  case (data_arb_opcode_i)
    `CA53_DATA_OPCODE_SNOOPDATA:    txdat_opcode = `CA53_SKYROS_DAT_SNPRESP;
    `CA53_DATA_OPCODE_WRITENOSNOOP,
    `CA53_DATA_OPCODE_WRITEUNIQUE:  txdat_opcode = `CA53_SKYROS_DAT_NONCOPYBACK;  
    `CA53_DATA_OPCODE_WRITEBACK,
    `CA53_DATA_OPCODE_WRITECLEAN:   txdat_opcode = data_force_non_shareable ? `CA53_SKYROS_DAT_NONCOPYBACK :
                                                                              `CA53_SKYROS_DAT_COPYBACK;
    `CA53_DATA_OPCODE_EVICT,
    `CA53_DATA_OPCODE_EVICTDATA,
    `CA53_DATA_OPCODE_INVALID:      txdat_opcode = `CA53_SKYROS_DAT_COPYBACK;
    default:                        txdat_opcode = 3'bxxx;
  endcase

  assign next_scu_txdatflit_opcode = txla_deactivate ? `CA53_SKYROS_DAT_LINKFLIT : txdat_opcode;

  always @*
  case (data_arb_opcode_i)
    `CA53_DATA_OPCODE_SNOOPDATA:    next_scu_txdatflit_resp = data_arb_snpresp_i;
    `CA53_DATA_OPCODE_WRITENOSNOOP,
    `CA53_DATA_OPCODE_WRITEUNIQUE,
    `CA53_DATA_OPCODE_INVALID:      next_scu_txdatflit_resp = 3'b000;
    `CA53_DATA_OPCODE_WRITEBACK,
    `CA53_DATA_OPCODE_WRITECLEAN:   next_scu_txdatflit_resp = data_force_non_shareable ? 3'b000 :
                                                              data_arb_unique_i        ? 3'b110 :
                                                                                         3'b111;
    `CA53_DATA_OPCODE_EVICT,
    `CA53_DATA_OPCODE_EVICTDATA:    next_scu_txdatflit_resp = data_arb_unique_i ? 3'b010 : 3'b001;
    default:                        next_scu_txdatflit_resp = 3'bxxx;
  endcase

  assign scu_txdatflit_en = clean_aclken_i & next_scu_txdatflitv;

  always @(posedge clk_master)
  if (scu_txdatflit_en) begin
    scu_txdatflit_qos     <= next_scu_txdatflit_qos;
    scu_txdatflit_tgtid   <= data_arb_tgtid_i;
    scu_txdatflit_txnid   <= next_scu_txdatflit_txnid;
    scu_txdatflit_opcode  <= next_scu_txdatflit_opcode[1:0];
    scu_txdatflit_resperr <= data_arb_err_i;
    scu_txdatflit_resp    <= next_scu_txdatflit_resp;
    scu_txdatflit_ccid    <= data_arb_addr_i[5:4];
    scu_txdatflit_dataid  <= data_arb_chunk_i;
    scu_txdatflit_be      <= data_arb_strb_i;
    scu_txdatflit_data    <= data_arb_data_i;
  end

  assign scu_txdatflit_o = {scu_txdatflit_data,
                            scu_txdatflit_be,
                            4'b0000,
                            scu_txdatflit_dataid,
                            scu_txdatflit_ccid,
                            8'h00,
                            scu_txdatflit_resp,
                            scu_txdatflit_resperr,
                            2'b00,
                            scu_txdatflit_opcode,
                            scu_txdatflit_txnid,
                            config_nodeid_i,
                            scu_txdatflit_tgtid,
                            scu_txdatflit_qos};


  // Can always accept any type of request.
  assign data_arb_sel_snoop_o = 1'b1;
  assign data_arb_sel_write_o = 1'b1;
  assign data_arb_sel_write_first_o = 1'b1;

  //-----------------------------------------------------------------------------
  //  RXRSP channel
  //-----------------------------------------------------------------------------

  // Wake up the regional clock gate if the interconnect indicates that it might
  // send a flit in the following cycle.
  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rxrspflitpend <= 1'b0;
  end else if (clean_aclken_i) begin
    rxrspflitpend <= ext_rxrspflitpend_i;
  end

  // Clock the interface data registers only when there might be a new transaction.
  assign rxrsp_en = clean_aclken_i & rxrspflitpend;

  // Track rxrsp credits. Because we can always accept a response, then send the
  // maximum number of credits allowed.

  assign rxrsp_credits_en = (clean_aclken_i & next_scu_rxrsplcrdv) ^ rsp_valid;

  assign next_rxrsp_credits = rsp_valid ? (rxrsp_credits + 4'b0001) : (rxrsp_credits - 4'b0001);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rxrsp_credits <= 4'b1111;
  end else if (rxrsp_credits_en) begin
    rxrsp_credits <= next_rxrsp_credits;
  end

  assign next_scu_rxrsplcrdv = rxla_run & |rxrsp_credits;

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    scu_rxrsplcrdv <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_rxrsplcrdv <= next_scu_rxrsplcrdv;
  end

  assign scu_rxrsplcrdv_o = scu_rxrsplcrdv;


  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    ext_rsp_valid <= 1'b0;
  end else if (rxrsp_en) begin
    ext_rsp_valid <= ext_rxrspflitv_i;
  end

  // Record when the response has been sent, but is still valid in the interface
  // registers because we haven't reached the next SCLK cycle.
  assign next_rsp_sent = (ext_rsp_valid | rsp_sent) & ~rxrsp_en;

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rsp_sent <= 1'b0;
  end else begin
    rsp_sent <= next_rsp_sent;
  end

  assign rsp_valid = ext_rsp_valid & ~rsp_sent;

  // The opcode must be clocked even when we are not expecting any flits, as we
  // might still receive a link layer flit at any time that the link is active.
  always @(posedge clk_ext_master)
  if (rxrsp_en) begin
    rxrsp_opcode <= ext_rxrspflit_i[29:26];
  end

  always @(posedge clk_master)
  if (rxrsp_en) begin
    rxrsp_srcid    <= ext_rxrspflit_i[17:11];
    rxrsp_txnid    <= ext_rxrspflit_i[24:18];
    rxrsp_resperr  <= ext_rxrspflit_i[31:30];
    rxrsp_resp     <= ext_rxrspflit_i[34:32];
    rxrsp_dbid     <= ext_rxrspflit_i[42:35];
    rxrsp_pcrdtype <= ext_rxrspflit_i[44:43];
  end

  assign master_rsp_dbid_valid = rsp_valid & ((rxrsp_opcode == `CA53_SKYROS_RSP_COMPDBIDRESP) |
                                              (rxrsp_opcode == `CA53_SKYROS_RSP_DBIDRESP));

  assign master_rsp_dbid_valid_o = master_rsp_dbid_valid;

  assign master_rsp_comp_valid = rsp_valid & ((rxrsp_opcode == `CA53_SKYROS_RSP_COMPDBIDRESP) |
                                              (rxrsp_opcode == `CA53_SKYROS_RSP_COMP));
  assign master_rsp_comp_valid_o = master_rsp_comp_valid;

  assign master_rsp_readreceipt_valid_o = rsp_valid & (rxrsp_opcode == `CA53_SKYROS_RSP_READRECEIPT);
  assign master_rsp_txnid_o = rxrsp_txnid;
  assign master_rsp_dbid_o  = rxrsp_dbid;
  assign master_rsp_srcid_o = rxrsp_srcid;
  assign master_rsp_resp_o  = {rxrsp_resp[2], rxrsp_resp[0], rxrsp_resperr};

  // Indicate an error so that nEXTERRIRQ can be asserted, for anything that
  // cannot be attributed back to a CPU.
  // This includes coherent writes and snpslv accesses.
  assign err_response_o = (rsp_valid & (rxrsp_opcode != `CA53_SKYROS_RSP_LINKFLIT) &
                           (rxrsp_txnid[6] | (rxrsp_txnid == `CA53_SNPSLV_TXNID)) &
                           |rxrsp_resperr);

  assign comp_waddr_valid = master_rsp_comp_valid & rxrsp_txnid[6];
  assign comp_waddr = rxrsp_txnid[3:0];

  //-----------------------------------------------------------------------------
  //  Protocol layer retry tracking
  //-----------------------------------------------------------------------------

  ca53scu_master_retries #(`CA53_SCU_INT_PARAM_INST) u_master_retries (
    /*ARMAUTO*/
    // Inputs
    .clk                           (clk),
    .clk_master                    (clk_master),
    .reset_n                       (reset_n),
    .rsp_valid_i                   (rsp_valid),
    .rxrsp_opcode_i                (rxrsp_opcode[3:0]),
    .rxrsp_txnid_i                 (rxrsp_txnid[6:0]),
    .rxrsp_srcid_i                 (rxrsp_srcid[6:0]),
    .rxrsp_pcrdtype_i              (rxrsp_pcrdtype[1:0]),
    .l2db_retry_ready_i            (l2db_retry_ready[NUM_L2DBS-1:0]),
    // Outputs
    .l2db_retry_valid_o            (l2db_retry_valid[NUM_L2DBS-1:0]),
    .l2db_retry_pcrdtype_o         (l2db_retry_pcrdtype[1:0]),
    .l2db_retry_active_o           (l2db_retry_active),
    .master_cpuslv0_reqbuf_retry_o (master_cpuslv0_reqbuf_retry_o[7:0]),
    .master_cpuslv1_reqbuf_retry_o (master_cpuslv1_reqbuf_retry_o[7:0]),
    .master_cpuslv2_reqbuf_retry_o (master_cpuslv2_reqbuf_retry_o[7:0]),
    .master_cpuslv3_reqbuf_retry_o (master_cpuslv3_reqbuf_retry_o[7:0]),
    .master_acpslv_reqbuf_retry_o  (master_acpslv_reqbuf_retry_o[3:0]),
    .master_snpslv_reqbuf_retry_o  (master_snpslv_reqbuf_retry_o),
    .master_cpuslv0_pcrdtype_o     (master_cpuslv0_pcrdtype_o[1:0]),
    .master_cpuslv1_pcrdtype_o     (master_cpuslv1_pcrdtype_o[1:0]),
    .master_cpuslv2_pcrdtype_o     (master_cpuslv2_pcrdtype_o[1:0]),
    .master_cpuslv3_pcrdtype_o     (master_cpuslv3_pcrdtype_o[1:0]),
    .master_acpslv_pcrdtype_o      (master_acpslv_pcrdtype_o[1:0]),
    .master_snpslv_pcrdtype_o      (master_snpslv_pcrdtype_o[1:0])
  );  // u_master_retries


  //-----------------------------------------------------------------------------
  //  RXDAT data channel
  //-----------------------------------------------------------------------------

  // Wake up the regional clock gate if the interconnect indicates that it might
  // send a flit in the following cycle.
  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rxdatflitpend <= 1'b0;
  end else if (clean_aclken_i) begin
    rxdatflitpend <= ext_rxdatflitpend_i;
  end

  // Clock the interface data registers only when there might be a new transaction.
  assign rxdat_en = clean_aclken_i & rxdatflitpend & ~(ext_read_valid &
                                                       ~read_resp_sent &
                                                       ~read_resp_ready_i);

  // Record when the interface registers contain a beat of data/response. These
  // registers are only clocked on SCLK cycles, so the data may have left
  // in the following cycle even if this register is still set. This is
  // indicated by read_resp_sent being asserted.
  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    ext_read_valid <= 1'b0;
  end else if (rxdat_en) begin
    ext_read_valid <= ext_rxdatflitv_i;
  end


  // Record when the beat of data has been sent to the read buffers, but is
  // still valid in the interface registers because we haven't reached the
  // next valid SCLK cycle.
  assign next_read_resp_sent = (((ext_read_valid & (read_resp_ready_i | ~read_resp_opcode)) |
                                 read_resp_sent) &
                                ~rxdat_en);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    read_resp_sent <= 1'b0;
  end else begin
    read_resp_sent <= next_read_resp_sent;
  end

  // Send the beat to the read buffers as soon as possible if it hasn't already
  // been sent. Link flits must not be sent to the read buffers.
  assign read_resp_valid = ext_read_valid & ~read_resp_sent & read_resp_opcode;
  assign read_resp_valid_o = read_resp_valid;

  assign link_credit_valid = ext_read_valid & ~read_resp_sent & ~read_resp_opcode;

  assign next_rbuf_credit_return_decr = clean_aclken_i & rxla_run & ~rbuf_early_credit;

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_credit_return      <= 4'b0000;
    rbuf_credit_return_decr <= 1'b0;
  end else begin
    rbuf_credit_return      <= credit_return_i;
    rbuf_credit_return_decr <= next_rbuf_credit_return_decr;
  end


  assign rbuf_credit_incr = (rbuf_credit_return[0] +
                             rbuf_credit_return[1] +
                             rbuf_credit_return[2] +
                             rbuf_credit_return[3] +
                             link_credit_valid);

  assign rbuf_credit_decr = ((clean_aclken_i & rxla_run & rbuf_early_credit) +
                             (rbuf_credit_return_decr & |rbuf_credit_return));

  assign next_rbuf_credits = (rbuf_credits +
                              rbuf_credit_incr -
                              rbuf_credit_decr);

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_credits <= RXDAT_CREDITS[`CA53_LOG2(RXDAT_CREDITS)-1:0];
  end else begin
    rbuf_credits <= next_rbuf_credits;
  end

  // We must not delay link deactivation if there are uncompleted snoops, only
  // if there are credits outstanding in the interconnect.
  assign rbuf_avail_credits = (rbuf_credits +
                               read_resp_valid +
                               rbuf_valid_i[4] +
                               rbuf_valid_i[3] +
                               rbuf_valid_i[2] +
                               rbuf_valid_i[1] +
                               rbuf_valid_i[0]);


  assign rbuf_early_credit = |rbuf_credits | (rbuf_credit_return_decr ? (rbuf_credit_incr > 3'b001) :
                                                                        (rbuf_credit_incr > 3'b000));

  assign next_scu_rxdatlcrdv = rxla_run & (|credit_return_i | rbuf_early_credit);


  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    scu_rxdatlcrdv <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_rxdatlcrdv <= next_scu_rxdatlcrdv;
  end

  assign scu_rxdatlcrdv_o = scu_rxdatlcrdv;

  // The opcode must be clocked even when we are not expecting any flits, as we
  // might still receive a link layer flit at any time that the link is active.
  always @(posedge clk_ext_master)
  if (rxdat_en) begin
    read_resp_opcode <= ext_rxdatflit_i[28];
  end

  always @(posedge clk_master)
  if (rxdat_en) begin
    read_resp_data    <= ext_rxdatflit_i[193:66];
    read_resp_id      <= ext_rxdatflit_i[23:18];
    read_resp_dbid    <= ext_rxdatflit_i[41:34];
    read_resp_chunk   <= ext_rxdatflit_i[45:44];
    read_resp_resperr <= ext_rxdatflit_i[30:29];
    read_resp_resp_is <= ext_rxdatflit_i[31];
    read_resp_resp_pd <= ext_rxdatflit_i[33];
    read_resp_srcid   <= ext_rxdatflit_i[17:11];
  end

  assign read_resp_data_o       = read_resp_data;
  assign read_resp_id_o         = read_resp_id;
  assign read_resp_cpuslv0_id_o = read_resp_id;
  assign read_resp_cpuslv1_id_o = read_resp_id;
  assign read_resp_cpuslv2_id_o = read_resp_id;
  assign read_resp_cpuslv3_id_o = read_resp_id;
  assign read_resp_acpslv_id_o  = read_resp_id;
  assign read_resp_dbid_o       = read_resp_dbid;
  assign read_resp_srcid_o      = read_resp_srcid;
  assign read_resp_chunk_o      = read_resp_chunk;
  assign read_resp_o            = {read_resp_resp_is, read_resp_resp_pd, read_resp_resperr};

  //-----------------------------------------------------------------------------
  //  Misc
  //-----------------------------------------------------------------------------

  assign txlink_req = (|txreq_req |
                       data_arb_req_i |
                       snpslv_txrsp_req_i |
                       cpuslv3_compack_valid_i |
                       cpuslv2_compack_valid_i |
                       cpuslv1_compack_valid_i |
                       cpuslv0_compack_valid_i |
                       acpslv_compack_valid_i);
                       
  // The link active state machine must only transition at certain times as
  // described in the Skyros specification.
  // We must only send requests when in the run state.
  // We must return all link layer credits when in the deactivate state.
  assign next_txlinkactivereq = ((txla_stop & ((txlink_req & rxla_stop) |
                                               rxla_activate)) |
                                 txla_activate |
                                 (txla_run & ~((rxla_run & standbywfil2_req_i) |
                                               rxla_deactivate)));

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    txlinkactivereq <= 1'b0;
    txlinkactiveack <= 1'b0;
  end else if (clean_aclken_i) begin
    txlinkactivereq <= next_txlinkactivereq;
    txlinkactiveack <= ext_txlinkactiveack_i;
  end

  assign scu_txlinkactivereq_o = txlinkactivereq;

  assign txla_stop       = ~txlinkactivereq & ~txlinkactiveack;
  assign txla_activate   =  txlinkactivereq & ~txlinkactiveack;
  assign txla_run        =  txlinkactivereq &  txlinkactiveack;
  assign txla_deactivate = ~txlinkactivereq &  txlinkactiveack;

  assign master_txla_run_o = txla_run;
  assign master_txla_deactivate_o = txla_deactivate;

  assign next_rxlinkactiveack = ((rxla_activate & (txla_activate | txla_run)) |
                                 rxla_run |
                                 (rxla_deactivate & ((rxrsp_credits != 4'b1111) |
                                                     (rbuf_avail_credits != RXDAT_CREDITS[`CA53_LOG2(RXDAT_CREDITS)-1:0]) |
                                                     snpslv_rxsnp_active_i)));

  always @(posedge clk_ext_master or negedge reset_n)
  if (~reset_n) begin
    rxlinkactivereq <= 1'b0;
    rxlinkactiveack <= 1'b0;
  end else if (clean_aclken_i) begin
    rxlinkactivereq <= ext_rxlinkactivereq_i;
    rxlinkactiveack <= next_rxlinkactiveack;
  end

  assign scu_rxlinkactiveack_o = rxlinkactiveack;

  assign rxla_stop       = ~rxlinkactivereq & ~rxlinkactiveack;
  assign rxla_activate   =  rxlinkactivereq & ~rxlinkactiveack;
  assign rxla_run        =  rxlinkactivereq &  rxlinkactiveack;
  assign rxla_deactivate = ~rxlinkactivereq &  rxlinkactiveack;

  assign master_rxla_run_o = rxla_run;
  assign master_rxla_deactivate_o = rxla_deactivate;
  assign master_rxla_stop_o = rxla_stop;

  // Indicate to the interconnect that we are active when we want to send a
  // request, and keep active until all request buffers have completed.
  assign next_scu_txsactive = ((txla_stop & next_txlinkactivereq) |
                               txla_activate |
                               (txlink_req | snpslv_active_i) |
                               (scu_txsactive &
                                (cpuslv0_master_sactive_i |
                                 cpuslv1_master_sactive_i |
                                 cpuslv2_master_sactive_i |
                                 cpuslv3_master_sactive_i |
                                 acpslv_master_sactive_i)));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_txsactive <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_txsactive <= next_scu_txsactive;
  end

  assign scu_txsactive_o = scu_txsactive;

  // The main clock logic must keep clk_ext_master running unless both links
  // are inactive.
  assign master_linkactive_o = ~(txla_stop & rxla_stop);

  assign interface_active_o = (scu_txreqflitpend |
                               scu_txreqflitv |
                               scu_txdatflitpend |
                               scu_txdatflitv |
                               scu_rxrsplcrdv |
                               scu_rxdatlcrdv |
                               (rxdatflitpend & ~rxla_stop) |
                               read_resp_valid |
                               (rxrspflitpend & ~rxla_stop) |
                               rsp_valid |
                               l2db_retry_active |
                               txla_activate |
                               txla_deactivate |
                               rxla_activate |
                               rxla_deactivate);

  assign clk_enable_ext_o = rxdatflitpend | rxrspflitpend | txreqlcrdv | txdatlcrdv;


  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slave returned too many txreq credits")
  u_ovl_txreq_credits (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (txreqlcrdv),
                       .consequent_expr (txreq_credits < 4'b1111));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Slave returned too many txdat credits")
  u_ovl_txdat_credits (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr (txdatlcrdv),
                       .consequent_expr (txdat_credits < 4'b1111));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A waddr must only be cleared if it is valid")
  u_ovl_waddr_clear (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (comp_waddr_valid),
                     .consequent_expr (waddr_valid[comp_waddr]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Length must never be 3 beats")
  u_ovl_arb_len (.clk             (clk),
                 .reset_n         (reset_n),
                 .antecedent_expr (addr_arb_req_i),
                 .consequent_expr (addr_arb_len_i != 2'b10));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Size must be quadword if more than a single beat")
  u_ovl_arb_size (.clk             (clk),
                 .reset_n         (reset_n),
                 .antecedent_expr (addr_arb_req_i & (addr_arb_len_i != 2'b00)),
                 .consequent_expr (addr_arb_size_i == 3'b100));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The rxdat registers must be enabled when a flit arrives")
  u_ovl_rxdat_en (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (clean_aclken_i & ext_rxdatflitv_i),
                  .consequent_expr (rxdat_en));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The rxrsp registers must be enabled when a flit arrives")
  u_ovl_rxrsp_en (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (clean_aclken_i & ext_rxrspflitv_i),
                  .consequent_expr (rxrsp_en));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The txla and rxla states must be consistent")
  u_ovl_txla_state1 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (txla_activate),
                     .consequent_expr (~rxla_deactivate));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The txla and rxla states must be consistent")
  u_ovl_txla_state2 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (txla_deactivate),
                     .consequent_expr (~rxla_activate));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "When a credit is used, the flit must be sent in the following cycle")
  u_ovl_txreqflitv (.clk         (clk),
                    .reset_n     (reset_n),
                    .start_event (clean_aclken_i & next_scu_txreqflitv),
                    .test_expr   (scu_txreqflitv));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "When a credit is used, the flit must be sent in the following cycle")
  u_ovl_txdatflitv (.clk         (clk),
                    .reset_n     (reset_n),
                    .start_event (clean_aclken_i & next_scu_txdatflitv),
                    .test_expr   (scu_txdatflitv));

  assert_zero_one_hot #(`OVL_FATAL, 16, `OVL_ASSERT, "Only one L2DB should be picked for a snoop hazard")
  u_ovl_l2db_hz_tc1_zoh (
    .clk        (clk),
    .reset_n    (reset_n),
    .test_expr  (waddr_hz_tc1)
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxrsp_credits_en")
  u_ovl_x_rxrsp_credits_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (rxrsp_credits_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: scu_txdatflit_en")
  u_ovl_x_scu_txdatflit_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (scu_txdatflit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: txdat_credits_en")
  u_ovl_x_txdat_credits_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (txdat_credits_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: txreq_credits_en")
  u_ovl_x_txreq_credits_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (txreq_credits_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: txreq_rr_en")
  u_ovl_x_txreq_rr_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (txreq_rr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: txreqflit_en")
  u_ovl_x_txreqflit_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (txreqflit_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxrsp_en")
  u_ovl_x_rxrsp_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (rxrsp_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclken_i")
  u_ovl_x_clean_aclken_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (clean_aclken_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rxdat_en")
  u_ovl_x_rxdat_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (rxdat_en));

  assert_never_unknown #(`OVL_FATAL, NUM_L2DBS, `OVL_ASSERT, "Register enable x-check: waddr_en")
  u_ovl_x_waddr_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (waddr_en));

  assert_never_unknown #(`OVL_FATAL, NUM_L2DBS, `OVL_ASSERT, "Register enable x-check: waddr_valid_en")
  u_ovl_x_waddr_status_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (waddr_valid_en));


`endif

endmodule // ca53scu_master_skyros

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
