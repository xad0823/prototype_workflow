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
//      Checked In          : $Date: 2014-07-02 17:05:58 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283841 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
//  The ACE master block implements the ACE specific parts of the master
//  interface. It includes the AR, R, AW, W, B and CD channels.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

`define CA53_CREATE_INT_ID(cpu) (read_resp_ext_id[5:3] == 3'b000) ? (read_resp_ext_id[2] ? 6'b110000 : \
                                                                     {1'b0, read_resp_ext_id[1:0], \
                                                                      dcu_read_resp_id_all[cpu]}) : \
                                                                    read_early_resp_id

module ca53scu_master_ace #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire         clk,
  input  wire         clk_master,
  input  wire         reset_n,
  input  wire         clean_aclken_i,
  input  wire         config_broadcastinner_i,
  input  wire         config_broadcastouter_i,
  output wire         clk_enable_ext_o,
  output wire         interface_active_o,
  output wire         master_writes_active_o,
  output wire         err_response_o,

  // External channels
  output wire         scu_ext_ar_valid_o,
  input  wire         scu_ext_ar_ready_i,
  output wire [43:0]  scu_ext_ar_addr_o,
  output wire [7:0]   scu_ext_ar_len_o,
  output wire [2:0]   scu_ext_ar_size_o,
  output wire [1:0]   scu_ext_ar_burst_o,
  output wire         scu_ext_ar_lock_o,
  output wire [3:0]   scu_ext_ar_cache_o,
  output wire [2:0]   scu_ext_ar_prot_o,
  output wire [1:0]   scu_ext_ar_domain_o,
  output wire [3:0]   scu_ext_ar_snoop_o,
  output wire [5:0]   scu_ext_ar_id_o,
  output wire [1:0]   scu_ext_ar_bar_o,
  output wire [7:0]   scu_ext_rdmemattr_o,

  input  wire         scu_ext_dr_valid_i,
  output wire         scu_ext_dr_ready_o,
  input  wire [5:0]   scu_ext_dr_id_i,
  input  wire         scu_ext_dr_last_i,
  input  wire [127:0] scu_ext_dr_data_i,
  input  wire [3:0]   scu_ext_dr_resp_i,

  output wire         scu_ext_aw_valid_o,
  input  wire         scu_ext_aw_ready_i,
  output wire [43:0]  scu_ext_aw_addr_o,
  output wire [7:0]   scu_ext_aw_len_o,
  output wire [2:0]   scu_ext_aw_size_o,
  output wire [1:0]   scu_ext_aw_burst_o,
  output wire         scu_ext_aw_lock_o,
  output wire [3:0]   scu_ext_aw_cache_o,
  output wire [2:0]   scu_ext_aw_prot_o,
  output wire [4:0]   scu_ext_aw_id_o,
  output wire [2:0]   scu_ext_aw_snoop_o,
  output wire [1:0]   scu_ext_aw_domain_o,
  output wire [1:0]   scu_ext_aw_bar_o,
  output wire         scu_ext_aw_unique_o,
  output wire [7:0]   scu_ext_wrmemattr_o,

  output wire         scu_ext_dw_valid_o,
  input  wire         scu_ext_dw_ready_i,
  output wire [127:0] scu_ext_dw_data_o,
  output wire [15:0]  scu_ext_dw_strb_o,
  output wire [4:0]   scu_ext_dw_id_o,
  output wire         scu_ext_dw_last_o,

  input  wire         scu_ext_db_valid_i,
  output wire         scu_ext_db_ready_o,
  input  wire [4:0]   scu_ext_db_id_i,
  input  wire [1:0]   scu_ext_db_resp_i,

  output wire         scu_ext_rack_o,
  output wire         scu_ext_wack_o,

  output wire         scu_ext_cd_valid_o,
  input  wire         scu_ext_cd_ready_i,
  output wire [127:0] scu_ext_cd_data_o,
  output wire         scu_ext_cd_last_o,

  // Arbitrated address requests
  input  wire         addr_arb_req_i,
  input  wire [6:0]   addr_arb_id_i,
  input  wire [40:0]  addr_arb_addr_i,
  input  wire [4:0]   addr_arb_opcode_i,
  input  wire [1:0]   addr_arb_len_i,
  input  wire [2:0]   addr_arb_size_i,
  input  wire         addr_arb_lock_i,
  input  wire [7:0]   addr_arb_attrs_i,
  input  wire [1:0]   addr_arb_prot_i,
  input  wire         addr_arb_dvm_part_two_i,
  output wire         addr_arb_ack_o,
  output wire [3:0]   addr_arb_waddr_id_o,

  // Arbitrated data requests
  input  wire         data_arb_req_i,
  input  wire         data_arb_snoop_i,
  input  wire         data_arb_first_i,
  input  wire [5:0]   data_arb_id_i,
  input  wire [127:0] data_arb_data_i,
  input  wire [15:0]  data_arb_strb_i,
  input  wire         data_arb_last_i,
  input  wire [2:0]   data_arb_opcode_i,
  input  wire [1:0]   data_arb_len_i,
  input  wire [2:0]   data_arb_size_i,
  input  wire [5:0]   data_arb_addr_i,
  input  wire [7:0]   data_arb_attrs_i,
  input  wire         data_arb_prot_i,
  input  wire         data_arb_strex_i,
  input  wire         data_arb_unique_i,
  output wire         data_arb_sel_snoop_o,
  output wire         data_arb_sel_write_o,
  output wire         data_arb_sel_write_first_o,
  output wire         data_arb_dw_ready_o,
  output wire         data_arb_cd_ready_o,

  // Read responses
  output wire         read_resp_valid_o,
  output wire [3:0]   read_resp_o,
  output wire [127:0] read_resp_data_o,
  output wire [5:0]   read_resp_id_o,
  output wire [5:0]   read_resp_cpuslv0_id_o,
  output wire [5:0]   read_resp_cpuslv1_id_o,
  output wire [5:0]   read_resp_cpuslv2_id_o,
  output wire [5:0]   read_resp_cpuslv3_id_o,
  output wire [5:0]   read_resp_acpslv_id_o,
  output wire [1:0]   read_resp_chunk_o,
  input wire          read_resp_ready_i,
  input wire          read_resp_next_ready_i,

  output wire         read_early_resp_valid_o,
  output wire [5:0]   read_early_resp_id_o,
  output wire         read_early_resp_barrier_o,

  // STREX and barrier write responses
  output wire         master_cpuslv0_strex_db_valid_o,
  output wire         master_cpuslv1_strex_db_valid_o,
  output wire         master_cpuslv2_strex_db_valid_o,
  output wire         master_cpuslv3_strex_db_valid_o,
  output wire         master_cpuslv0_barrier_db_valid_o,
  output wire         master_cpuslv1_barrier_db_valid_o,
  output wire         master_cpuslv2_barrier_db_valid_o,
  output wire         master_cpuslv3_barrier_db_valid_o,
  output wire         master_cpuslv0_dev_db_valid_o,
  output wire         master_cpuslv1_dev_db_valid_o,
  output wire         master_cpuslv2_dev_db_valid_o,
  output wire         master_cpuslv3_dev_db_valid_o,
  output wire [1:0]   master_db_resp_o,
  output wire         master_db_waddr_valid_o,
  output wire [3:0]   master_db_waddr_o,

  // Waddr status for barriers
  output wire         master_cpuslv0_waddrs_valid_o,
  output wire         master_cpuslv1_waddrs_valid_o,
  output wire         master_cpuslv2_waddrs_valid_o,
  output wire         master_cpuslv3_waddrs_valid_o,

  input  wire         cpuslv0_sample_waddrs_i,
  input  wire         cpuslv1_sample_waddrs_i,
  input  wire         cpuslv2_sample_waddrs_i,
  input  wire         cpuslv3_sample_waddrs_i,
  input  wire         cpuslv0_sample_waddrs_dsb_i,
  input  wire         cpuslv1_sample_waddrs_dsb_i,
  input  wire         cpuslv2_sample_waddrs_dsb_i,
  input  wire         cpuslv3_sample_waddrs_dsb_i,
  input  wire         snpslv_sample_waddrs_i,
  output wire         master_snpslv_waddrs_valid_o,
  output wire         master_snpslv_db_valid_o,

  // Hazarding
  input  wire [40:6]  tagctl_addr_tc1_i,
  input  wire         tagctl_addr_valid_tc1_i,
  input  wire [40:6]  tagctl_addr_tc3_i,
  input  wire         tagctl_addr_valid_tc3_i,
  input  wire [5:0]   tagctl_reqbufid_tc1_i,
  output wire         master_hz_tc2_o,
  output wire         master_hz_tc4_o,
  output wire [3:0]   master_hz_waddr_tc4_o,
  output wire         master_hz_dev_tc2_o,
  output wire         master_ncoh_db_o,
  output wire [15:0]  master_waddr_valid_o
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  localparam NUM_WADDRS = 16;

  reg          clk_enable_ext;

  wire         next_clk_enable_ext;

  // Read address channel
  reg          addr_arb_ack;
  reg          scu_ext_ar_valid;
  reg [5:0]    scu_ext_ar_id;
  reg [43:0]   scu_ext_ar_addr;
  reg [1:0]    scu_ext_ar_len;
  reg [2:0]    scu_ext_ar_size;
  reg          scu_ext_ar_burst;
  reg          scu_ext_ar_lock;
  reg [3:0]    scu_ext_ar_cache;
  reg [2:0]    scu_ext_ar_prot;
  reg [1:0]    scu_ext_ar_domain;
  reg [3:0]    scu_ext_ar_snoop;
  reg [1:0]    scu_ext_ar_bar;
  reg [7:0]    scu_ext_rdmemattr;

  wire         new_arb_ar_req;
  wire         next_scu_ext_ar_valid;
  wire         next_addr_arb_ack;
  wire [1:0]   next_scu_ext_ar_bar;
  reg  [3:0]   next_scu_ext_ar_snoop;
  wire [1:0]   next_scu_ext_ar_domain;
  wire [3:0]   next_scu_ext_ar_cache;
  wire         next_scu_ext_ar_burst;
  wire         next_scu_ext_ar_lock;
  wire [2:0]   next_scu_ext_ar_prot;
  wire [43:0]  next_scu_ext_ar_addr;
  wire [5:0]   next_scu_ext_ar_id;
  wire [7:0]   next_scu_ext_rdmemattr;
  wire         ext_ar_en;
  wire         force_ar_non_shareable;

  // Write address channel
  reg          scu_ext_aw_valid;
  reg [4:0]    scu_ext_aw_id;
  reg [39:0]   scu_ext_aw_addr;
  reg [1:0]    scu_ext_aw_len;
  reg [2:0]    scu_ext_aw_size;
  reg          scu_ext_aw_lock;
  reg [3:0]    scu_ext_aw_cache;
  reg [1:0]    scu_ext_aw_prot;
  reg [1:0]    scu_ext_aw_domain;
  reg [2:0]    scu_ext_aw_snoop;
  reg [1:0]    scu_ext_aw_bar;
  reg          scu_ext_aw_unique;
  reg [7:0]    scu_ext_wrmemattr;
  reg          aw_skid_valid;
  reg [4:0]    aw_skid_ext_id;
  reg [2:0]    aw_skid_opcode;
  reg [1:0]    aw_skid_len;
  reg [2:0]    aw_skid_size;
  reg [40:0]   aw_skid_addr;
  reg [7:0]    aw_skid_attrs;
  reg          aw_skid_prot;
  reg          aw_skid_strex;
  reg          aw_skid_unique;
  reg          barrier_aw_sent;
  reg          ack_for_barrier;
  reg          dcu_ar_req_pushed;
  reg          aw_block_data;

  wire         next_scu_ext_aw_valid;
  wire [4:0]   next_scu_ext_aw_id;
  wire [40:0]  next_scu_ext_aw_addr;
  wire [1:0]   next_scu_ext_aw_len;
  wire [2:0]   next_scu_ext_aw_size;
  wire         next_scu_ext_aw_lock;
  wire [3:0]   next_scu_ext_aw_cache;
  wire [1:0]   next_scu_ext_aw_prot;
  wire [1:0]   next_scu_ext_aw_domain;
  wire [2:0]   next_scu_ext_aw_snoop;
  wire [1:0]   next_scu_ext_aw_bar;
  wire         next_scu_ext_aw_unique;
  wire [7:0]   next_scu_ext_wrmemattr;
  wire [7:0]   aw_attrs;
  reg [2:0]    data_aw_snoop;
  wire         data_aw_req;
  wire         data_aw_strex;
  wire         data_aw_unique;
  wire         data_aw_dev;
  wire         new_arb_aw_ready;
  wire         new_arb_aw_req;
  wire         new_arb_waddr_req;
  wire         next_barrier_aw_sent;
  wire         next_ack_for_barrier;
  wire         new_aw_req;
  wire         ext_aw_en;
  wire         next_aw_block_data;
  wire         next_aw_skid_valid;
  wire [40:0]  data_arb_full_addr;
  wire [2:0]   data_aw_opcode;
  wire [1:0]   data_aw_len;
  wire [2:0]   data_aw_size;
  wire [7:0]   data_aw_attrs;
  wire         data_aw_prot;
  wire         force_aw_non_shareable;
  wire         next_dcu_ar_req_pushed;


  reg [2:0]             waddr_status [NUM_WADDRS-1:0];
  reg [40:6]            waddr_addr   [NUM_WADDRS-1:0];
  reg [1:0]             waddr_cpu    [NUM_WADDRS-1:0];
  reg                   master_hz_tc2;
  reg                   master_hz_tc4;
  reg                   master_hz_dev_tc2;
  reg [3:0]             master_hz_waddr_tc4;
  reg [3:0]             addr_arb_waddr_id;
  reg [NUM_WADDRS-1:0]  waddr_outstanding [NUM_CPUS-1:0];
  reg [NUM_WADDRS-1:0]  snp_barrier_waddrs;

  wire [2:0]            next_waddr_status [NUM_WADDRS-1:0];
  wire                  waddr_dev_rr_en;
  wire [NUM_WADDRS-1:0] waddr_valid;
  wire [NUM_WADDRS-1:0] waddr_strex;
  wire [NUM_WADDRS-1:0] waddr_dev;
  wire [NUM_WADDRS-1:0] waddr_sent_dev;
  wire [NUM_WADDRS-1:0] waddr_coh;
  wire [NUM_WADDRS-1:0] waddr_lower_empty;
  wire [NUM_WADDRS-1:0] waddr_matching_dev;
  wire [NUM_WADDRS-1:0] waddr_dev_arb;
  wire [NUM_WADDRS-1:0] first_empty_waddr;
  wire [NUM_WADDRS-1:0] waddr_en;
  wire [NUM_WADDRS-1:0] waddr_status_en;
  wire [NUM_WADDRS-1:0] free_waddr;
  wire [NUM_WADDRS-1:0] upgrade_dev_waddr;
  wire [NUM_WADDRS-1:0] hazard_tc1;
  wire [NUM_WADDRS-1:0] hazard_tc3;
  wire [NUM_WADDRS-1:0] hazard_dev_tc1;
  wire [NUM_WADDRS-1:0] next_waddr_outstanding [NUM_CPUS-1:0];
  wire [NUM_WADDRS-1:0] waddr_outstanding_cpu [3:0];
  wire                  waddr_outstanding_en;
  wire [3:0]            cpuslv_sample_waddrs;
  wire [3:0]            cpuslv_sample_waddrs_dsb;
  wire                  waddr_available;
  wire [2:0]            new_waddr_status;
  wire                  next_master_hz_tc2;
  wire                  next_master_hz_tc4;
  wire                  next_master_hz_dev_tc2;
  wire [3:0]            next_master_hz_waddr_tc4;
  wire                  addr_arb_waddr_id_en;
  wire [3:0]            next_addr_arb_waddr_id;
  wire [4:0]            data_arb_ext_id;
  wire                  snp_barrier_waddrs_en;
  wire [NUM_WADDRS-1:0] next_snp_barrier_waddrs;
  wire                  master_snpslv_waddrs_valid;

  // Write and snoop data channels
  reg          data_skid_dw_valid;
  reg          data_skid_cd_valid;
  reg [127:0]  data_skid_data;
  reg [15:0]   data_skid_strb;
  reg          data_skid_last;
  reg          cd_skid0_valid;
  reg [127:0]  cd_skid0_data;
  reg          cd_skid0_last;
  reg          cd_skid0_newest;
  reg          cd_skid1_valid;
  reg [127:0]  cd_skid1_data;
  reg          cd_skid1_last;
  reg          scu_ext_dw_valid;
  reg [4:0]    scu_ext_dw_id;
  reg [127:0]  scu_ext_dw_data;
  reg [15:0]   scu_ext_dw_strb;
  reg          scu_ext_dw_last;
  reg          scu_ext_cd_valid;
  reg [127:0]  scu_ext_cd_data;
  reg          scu_ext_cd_last;

  wire         next_scu_ext_dw_valid;
  wire         next_scu_ext_cd_valid;
  wire         next_data_skid_dw_valid;
  wire         next_data_skid_cd_valid;
  wire         skid_en;
  wire         ext_dw_en;
  wire         ext_cd_en;
  wire         data_arb_dw_ready;
  wire         data_arb_cd_ready;
  wire         data_arb_ready;
  wire         new_data_arb_req;
  wire [4:0]   next_scu_dw_ext_id;
  wire [127:0] next_scu_dw_ext_data;
  wire [15:0]  next_scu_dw_ext_strb;
  wire         next_scu_dw_ext_last;
  wire [127:0] next_scu_cd_ext_data;
  wire         next_scu_cd_ext_last;
  wire         cd_ready;
  wire         cd_skid0_en;
  wire         cd_skid1_en;
  wire         next_cd_skid0_valid;
  wire         next_cd_skid1_valid;
  wire         next_cd_skid0_newest;
  wire [127:0] new_scu_cd_ext_data;
  wire         new_scu_cd_ext_last;

  // Write response channel
  reg          scu_ext_wack;
  reg          ext_db_valid;
  reg [4:0]    db_id;
  reg [1:0]    db_resp;

  wire         db_en;
  wire         db_valid;
  wire         strex_db_valid;
  wire         barrier_db_valid;
  wire         ncoh_db_valid;
  wire [1:0]   db_cpu;

  // Read data channel
  reg          ext_read_valid;
  reg          read_resp_sent;
  reg          scu_ext_dr_ready;
  reg [127:0]  read_resp_data;
  reg [5:0]    read_resp_ext_id;
  reg [3:0]    read_resp;
  reg          read_resp_last;
  reg          scu_ext_rack;
  reg [1:0]    read_chunk_cpu                [NUM_CPUS*8-1:0];
  reg [2:0]    dcu_reqbuf_fifo               [NUM_CPUS*4-1:0];
  reg [1:0]    dcu_reqbuf_fifo_head          [NUM_CPUS-1:0];
  reg [1:0]    dcu_reqbuf_fifo_tail          [NUM_CPUS-1:0];
  reg [1:0]    dcu_read_resp_chunk           [NUM_CPUS-1:0];
  reg [2:0]    dcu_read_resp_id              [NUM_CPUS-1:0];
  reg          dr_req_popped;

  wire         next_ext_read_valid;
  wire         next_scu_ext_dr_ready;
  wire         next_read_resp_sent;
  wire         dr_en;
  wire         next_scu_ext_rack;
  wire         read_resp_valid;
  wire         dcu_reqbuf_fifo_dr            [NUM_CPUS-1:0];
  wire         dcu_reqbuf_fifo_pop           [NUM_CPUS-1:0];
  wire [1:0]   dcu_reqbuf_fifo_head_plus_one [NUM_CPUS-1:0];
  wire [1:0]   next_dcu_reqbuf_fifo_head     [NUM_CPUS-1:0];
  wire [1:0]   dcu_reqbuf_fifo_tail_plus_one [NUM_CPUS-1:0];
  wire [1:0]   next_dcu_reqbuf_fifo_tail     [NUM_CPUS-1:0];
  wire [2:0]   next_dcu_reqbuf_fifo          [NUM_CPUS*4-1:0];
  wire [2:0]   next_dcu_read_resp_id         [NUM_CPUS-1:0];
  wire [1:0]   next_dcu_read_resp_chunk      [NUM_CPUS-1:0];
  wire [1:0]   dcu_chunk_this_burst          [NUM_CPUS-1:0];
  wire [1:0]   dcu_chunk_next_burst          [NUM_CPUS-1:0];
  wire [1:0]   dcu_chunk_next_beat           [NUM_CPUS-1:0];
  wire [1:0]   dcu_read_resp_chunk_all       [3:0];
  wire [2:0]   dcu_read_resp_id_all          [3:0];
  wire [1:0]   next_read_chunk_cpu           [NUM_CPUS*8-1:0];
  wire [1:0]   read_chunk_cpu_all            [4*8-1:0];
  wire [5:0]   read_resp_id;
  wire [5:0]   read_early_resp_id;
  wire         dr_req_pop;
  wire         next_dr_req_popped;
  wire         read_chunk_en;
  wire         dcu_read_chunk_en;
  wire         cpu_ar_req;
  wire         dcu_ar_req;
  wire         acp_ar_req;
  wire         cpu_dr_req;
  wire         dcu_dr_req;
  wire         acp_dr_req;

  genvar i;
  genvar j;

  //-----------------------------------------------------------------------------
  //  Read address channel
  //-----------------------------------------------------------------------------

  // Send a read request for any read, and also for a barrier but only once the
  // write half has been sent.
  assign new_arb_ar_req = (addr_arb_req_i &
                           (((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                             (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB)) ? (barrier_aw_sent & ~addr_arb_ack) :
                                                                            `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode_i)));


  // Calculate external valid signal
  assign next_scu_ext_ar_valid = ((scu_ext_ar_valid & ~scu_ext_ar_ready_i) |
                                  new_arb_ar_req);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_ext_ar_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_ar_valid <= next_scu_ext_ar_valid;
  end

  assign scu_ext_ar_valid_o = scu_ext_ar_valid;

  // Signal back to the arbiter when all parts of the request have been sent.
  assign next_addr_arb_ack = ((new_arb_waddr_req & waddr_available) |
                              (new_arb_ar_req & clean_aclken_i &
                               (~scu_ext_ar_valid | scu_ext_ar_ready_i)));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    addr_arb_ack <= 1'b0;
  end else begin
    addr_arb_ack <= next_addr_arb_ack;
  end

  assign addr_arb_ack_o = addr_arb_ack;

  // The internal ID indicates the reqbuf that generated the request. Convert to an external ID.
  // Internal ID:
  // 6 DCU access
  // 5:3 ACP/CPU number. 0-3 CPU, 4 ACP, 5 Snoop
  // 2:0 reqbuf
  assign next_scu_ext_ar_id = ((addr_arb_id_i[6] &
                                (addr_arb_lock_i |
                                 ~`CA53_MEM_REORDERABLE(addr_arb_attrs_i))) ? {4'b0000, addr_arb_id_i[4:3]} :
                               (addr_arb_id_i[5:3] == 3'b101)               ? {4'b0010, addr_arb_id_i[4:3]} :
                               next_scu_ext_ar_bar[0]                       ? {4'b0001, addr_arb_id_i[4:3]} :
                               (addr_arb_id_i[5:3] == 3'b100)               ? {1'b0, addr_arb_id_i[2:0], addr_arb_id_i[4:3]} :
                                                                              {1'b1, addr_arb_id_i[2:0], addr_arb_id_i[4:3]});


  assign next_scu_ext_ar_bar = ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) ? `CA53_ACE_BAR_MEM :
                                (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) ? `CA53_ACE_BAR_SYNC :
                                                                              `CA53_ACE_BAR_NORMAL);

  // If the access is to a shareability less than what must be broadcast
  // externally, then we must force the access to be non-shareable as far
  // as the outside world is concerned.
  assign force_ar_non_shareable = ((~`CA53_MEM_SHAREABLE(addr_arb_attrs_i) |
                                    ~config_broadcastouter_i |
                                    (~`CA53_MEM_O_SHAREABLE(addr_arb_attrs_i) & ~config_broadcastinner_i)) &
                                   ~((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                     (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB)));

  always @*
  case (addr_arb_opcode_i)
    `CA53_REQ_OPCODE_READNOSNOOP:  next_scu_ext_ar_snoop = `CA53_ACE_READNOSNOOP;
    `CA53_REQ_OPCODE_READONCE:     next_scu_ext_ar_snoop = force_ar_non_shareable ? `CA53_ACE_READNOSNOOP : `CA53_ACE_READONCE;
    `CA53_REQ_OPCODE_READSHARED:   next_scu_ext_ar_snoop = force_ar_non_shareable ? `CA53_ACE_READNOSNOOP : `CA53_ACE_READSHARED;
    `CA53_REQ_OPCODE_READUNIQUE:   next_scu_ext_ar_snoop = force_ar_non_shareable ? `CA53_ACE_READNOSNOOP : `CA53_ACE_READUNIQUE;
    `CA53_REQ_OPCODE_CLEANUNIQUE:  next_scu_ext_ar_snoop = `CA53_ACE_CLEANUNIQUE;
    `CA53_REQ_OPCODE_MAKEUNIQUE:   next_scu_ext_ar_snoop = `CA53_ACE_MAKEUNIQUE;
    `CA53_REQ_OPCODE_CLEANSHARED:  next_scu_ext_ar_snoop = `CA53_ACE_CLEANSHARED;
    `CA53_REQ_OPCODE_CLEANINVALID: next_scu_ext_ar_snoop = `CA53_ACE_CLEANINVALID;
    `CA53_REQ_OPCODE_MAKEINVALID:  next_scu_ext_ar_snoop = `CA53_ACE_MAKEINVALID;
    `CA53_REQ_OPCODE_DVM:          next_scu_ext_ar_snoop = `CA53_ACE_DVM_MESSAGE;
    `CA53_REQ_OPCODE_DVM_COMPLETE: next_scu_ext_ar_snoop = `CA53_ACE_DVM_COMPLETE;
    `CA53_REQ_OPCODE_DMB:          next_scu_ext_ar_snoop = 4'b0000;
    `CA53_REQ_OPCODE_DSB:          next_scu_ext_ar_snoop = 4'b0000;
    default:                       next_scu_ext_ar_snoop = 4'bxxxx;
  endcase


  assign next_scu_ext_ar_domain = ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? `CA53_ACE_DOMAIN_INNER :
                                  `CA53_ATTRS_TO_DOMAIN(addr_arb_attrs_i, force_ar_non_shareable,
                                                        (addr_arb_opcode_i == `CA53_REQ_OPCODE_CLEANSHARED));

  assign next_scu_ext_ar_cache = (((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? 4'b0010 :
                                  `CA53_MEM_nGnRnE(addr_arb_attrs_i)            ? 4'b0000 :
                                  `CA53_MEM_DEVICE(addr_arb_attrs_i)            ? 4'b0001 :
                                  ~`CA53_MEM_COHERENT(addr_arb_attrs_i)         ? 4'b0011 :
                                  (addr_arb_attrs_i[3] ? 4'b1111 : 4'b1011));

  assign next_scu_ext_rdmemattr = `CA53_ATTRS_TO_MEMATTR(addr_arb_attrs_i);

  assign next_scu_ext_ar_burst = (((addr_arb_opcode_i == `CA53_REQ_OPCODE_READSHARED) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_READUNIQUE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_CLEANUNIQUE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_MAKEUNIQUE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_READONCE) |
                                   ((addr_arb_opcode_i == `CA53_REQ_OPCODE_READNOSNOOP) &
                                    (`CA53_MEM_WB(addr_arb_attrs_i) |
                                     `CA53_MEM_WT(addr_arb_attrs_i)))) &
                                  (&addr_arb_len_i));

  assign next_scu_ext_ar_lock = addr_arb_lock_i & ~(`CA53_MEM_COHERENT(addr_arb_attrs_i) & force_ar_non_shareable);

  assign next_scu_ext_ar_prot = (((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                  (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) |
                                  (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                  (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ? 3'b000 :
                                 {((addr_arb_opcode_i == `CA53_REQ_OPCODE_READONCE) |
                                   (addr_arb_opcode_i == `CA53_REQ_OPCODE_READNOSNOOP)) & addr_arb_prot_i[1],
                                  addr_arb_addr_i[40],
                                  addr_arb_prot_i[0]});

  // Because DVM messages are compressed into 41 bits of address, we must expand
  // them before sending externally.
  assign next_scu_ext_ar_addr = (addr_arb_dvm_part_two_i ? {addr_arb_addr_i[2:0], addr_arb_addr_i[40:3], 3'b000} :
                                 ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM_COMPLETE) |
                                  (addr_arb_opcode_i == `CA53_REQ_OPCODE_DVM)) ?
                                                           {addr_arb_addr_i[15], addr_arb_addr_i[7],
                                                            addr_arb_addr_i[1], addr_arb_addr_i[40:16],
                                                            (addr_arb_addr_i[14:12] == `CA53_ACE_DVM_SYNC),
                                                            addr_arb_addr_i[14:8], 1'b0,
                                                            addr_arb_addr_i[6:2], 1'b0, addr_arb_addr_i[0]} :
                                                           {4'b0000, addr_arb_addr_i[39:0]});

  // Enable the output registers only when there is valid data to send, and the
  // output register is ready to accept new data.
  assign ext_ar_en = clean_aclken_i & new_arb_ar_req & (~scu_ext_ar_valid | scu_ext_ar_ready_i);

  always @(posedge clk_master)
  if (ext_ar_en) begin
    scu_ext_ar_id     <= next_scu_ext_ar_id[5:0];
    scu_ext_ar_addr   <= next_scu_ext_ar_addr;
    scu_ext_ar_len    <= addr_arb_len_i;
    scu_ext_ar_size   <= addr_arb_size_i;
    scu_ext_ar_burst  <= next_scu_ext_ar_burst;
    scu_ext_ar_lock   <= next_scu_ext_ar_lock;
    scu_ext_ar_cache  <= next_scu_ext_ar_cache;
    scu_ext_ar_prot   <= next_scu_ext_ar_prot;
    scu_ext_ar_domain <= next_scu_ext_ar_domain;
    scu_ext_ar_snoop  <= next_scu_ext_ar_snoop;
    scu_ext_ar_bar    <= next_scu_ext_ar_bar;
    scu_ext_rdmemattr <= next_scu_ext_rdmemattr;
  end

  assign scu_ext_ar_id_o     = scu_ext_ar_id;
  assign scu_ext_ar_addr_o   = scu_ext_ar_addr;
  assign scu_ext_ar_len_o    = {6'b000000, scu_ext_ar_len};
  assign scu_ext_ar_size_o   = scu_ext_ar_size;
  assign scu_ext_ar_burst_o  = {scu_ext_ar_burst, ~scu_ext_ar_burst};
  assign scu_ext_ar_lock_o   = scu_ext_ar_lock;
  assign scu_ext_ar_cache_o  = scu_ext_ar_cache;
  assign scu_ext_ar_prot_o   = scu_ext_ar_prot;
  assign scu_ext_ar_domain_o = scu_ext_ar_domain;
  assign scu_ext_ar_snoop_o  = scu_ext_ar_snoop;
  assign scu_ext_ar_bar_o    = scu_ext_ar_bar;
  assign scu_ext_rdmemattr_o = scu_ext_rdmemattr;

  //-----------------------------------------------------------------------------
  //  Write address channel
  //-----------------------------------------------------------------------------

  // Only barrier requests are sent directly on the AW channel. All other write
  // requests are placed in the waddr buffers and sent later with the data.
  assign new_arb_aw_req = (addr_arb_req_i &
                           ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                            (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB)) &
                           ~barrier_aw_sent);

  assign new_arb_waddr_req = addr_arb_req_i & `CA53_REQ_OPCODE_IS_WRITE(addr_arb_opcode_i);

  assign new_arb_aw_ready = ~(data_aw_req & ~aw_block_data) & ~aw_skid_valid;

  // If a barrier cannot make progress because of a write, then block further
  // writes until the barrier is arbitrated, to ensure fairness between the two.
  assign next_aw_block_data = (new_arb_aw_req & (data_aw_req | aw_skid_valid)) & ~aw_block_data;

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    aw_block_data <= 1'b0;
  end else if (ext_aw_en) begin
    aw_block_data <= next_aw_block_data;
  end
  
  // Store if the request is a barrier, so we know in the next cycle if there is
  // an ack that is for a barrier. If a barrier gets pre-empted betweent he two
  // parts we must not forget that the write part has been sent.
  assign next_ack_for_barrier = ((addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) |
                                 (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    ack_for_barrier <= 1'b0;
  end else begin
    ack_for_barrier <= next_ack_for_barrier;
  end

  // Record if the write part of a barrier has been sent.
  assign next_barrier_aw_sent = ((barrier_aw_sent & ~(addr_arb_ack & ack_for_barrier)) |
                                 (new_arb_aw_req & 
                                  new_arb_aw_ready &
                                  clean_aclken_i &
                                  (~scu_ext_aw_valid | scu_ext_aw_ready_i)));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    barrier_aw_sent <= 1'b0;
  end else begin
    barrier_aw_sent <= next_barrier_aw_sent;
  end

  // Drive a request externally if either the address channel wants to or the
  // first beat of a write is being sent or has been sent.
  assign new_aw_req = new_arb_aw_req | data_aw_req | aw_skid_valid;

  // Calculate external valid signal.
  assign next_scu_ext_aw_valid = ((scu_ext_aw_valid & ~scu_ext_aw_ready_i) |
                                  new_aw_req);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_ext_aw_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_aw_valid <= next_scu_ext_aw_valid;
  end

  assign scu_ext_aw_valid_o = scu_ext_aw_valid;

  // Most write IDs are based on the waddr holding the address, however
  // barriers, STREXes and non-reorderable device accesses have special IDs.
  // This is to ensure, for barriers and STREXes, that the write part goes out
  // with the same ID that was used for the read part. For device accesses it
  // is to ensure that all non-reorderable device writes from a particular CPU
  // go out with the same ID and hence are kept in order by the interconnect.
  assign next_scu_ext_aw_id = ((new_arb_aw_ready & (addr_arb_id_i[5:3] == 3'b101)) ? 5'b01001 :
                               new_arb_aw_ready ? {3'b001, addr_arb_id_i[4:3]} :
                               aw_skid_valid  ?   aw_skid_ext_id :
                               data_aw_strex  ?   {3'b000, data_arb_id_i[5:4]} :
                               data_aw_dev    ?   {3'b011, data_arb_id_i[5:4]} :
                                                  {1'b1, data_arb_id_i[3:0]});


  // Because only barriers are send directly on AW, and they have a fixed
  // address, there is no need to factor the arbitrated address in.
  assign next_scu_ext_aw_addr = (aw_skid_valid |
                                 new_arb_aw_ready) ? (aw_skid_addr & ~{41{new_arb_aw_ready}}) :
                                                     data_arb_full_addr;

  assign next_scu_ext_aw_bar = (new_arb_aw_ready & (addr_arb_opcode_i == `CA53_REQ_OPCODE_DMB) ? `CA53_ACE_BAR_MEM :
                                new_arb_aw_ready & (addr_arb_opcode_i == `CA53_REQ_OPCODE_DSB) ? `CA53_ACE_BAR_SYNC :
                                                                                                 `CA53_ACE_BAR_NORMAL);

  assign next_scu_ext_aw_unique = data_aw_unique & ((data_aw_opcode == `CA53_DATA_OPCODE_WRITEBACK) |
                                                    (data_aw_opcode == `CA53_DATA_OPCODE_EVICTDATA)) & ~new_arb_aw_ready;

  // If the access is to a shareability less than what must be broadcast
  // externally, then we must force the access to be non-shareable as far
  // as the outside world is concerned.
  assign force_aw_non_shareable = (~`CA53_MEM_SHAREABLE(data_aw_attrs) |
                                   ~config_broadcastouter_i |
                                   (~`CA53_MEM_O_SHAREABLE(data_aw_attrs) & ~config_broadcastinner_i)) & ~new_arb_aw_ready;

  always @*
  case (data_aw_opcode)
    `CA53_DATA_OPCODE_WRITENOSNOOP: data_aw_snoop  = `CA53_ACE_WRITENOSNOOP;
    `CA53_DATA_OPCODE_WRITEBACK:    data_aw_snoop  = force_aw_non_shareable ? `CA53_ACE_WRITENOSNOOP : `CA53_ACE_WRITEBACK;
    `CA53_DATA_OPCODE_WRITECLEAN:   data_aw_snoop  = force_aw_non_shareable ? `CA53_ACE_WRITENOSNOOP : `CA53_ACE_WRITECLEAN;
    `CA53_DATA_OPCODE_EVICT:        data_aw_snoop  = `CA53_ACE_EVICT;
    `CA53_DATA_OPCODE_EVICTDATA:    data_aw_snoop  = `CA53_ACE_WRITEBACKUC;
    default:                        data_aw_snoop  = 3'bxxx;
  endcase

  assign next_scu_ext_aw_snoop  = data_aw_snoop & ~{3{new_arb_aw_ready}};
  assign next_scu_ext_aw_len    = data_aw_len & ~{2{new_arb_aw_ready}};
  assign next_scu_ext_aw_size   = new_arb_aw_ready ? `CA53_ACE_SIZE_128BIT : data_aw_size;
  assign next_scu_ext_aw_lock   = data_aw_strex & ~new_arb_aw_ready;
  assign next_scu_ext_aw_cache  = (new_arb_aw_ready                 ? 4'b0010 :
                                   `CA53_MEM_nGnRnE(data_aw_attrs)    ? 4'b0000 :
                                   `CA53_MEM_DEVICE(data_aw_attrs)    ? 4'b0001 :
                                   ~`CA53_MEM_COHERENT(data_aw_attrs) ? 4'b0011 :
                                   (data_aw_attrs[2] ? 4'b1111 : 4'b0111));

  assign next_scu_ext_aw_prot   = {next_scu_ext_aw_addr[40],
                                   data_aw_prot & ~new_arb_aw_ready};

  assign aw_attrs = new_arb_aw_ready ? addr_arb_attrs_i : data_aw_attrs;

  assign next_scu_ext_aw_domain = `CA53_ATTRS_TO_DOMAIN(aw_attrs, force_aw_non_shareable, 1'b0);

  assign next_scu_ext_wrmemattr = `CA53_ATTRS_TO_MEMATTR(aw_attrs);

  // Enable the output registers only when there is valid data to send, and the
  // output register is ready to accept new data.
  assign ext_aw_en = clean_aclken_i & new_aw_req & (~scu_ext_aw_valid | scu_ext_aw_ready_i);

  always @(posedge clk_master)
  if (ext_aw_en) begin
    scu_ext_aw_id     <= next_scu_ext_aw_id;
    scu_ext_aw_addr   <= next_scu_ext_aw_addr[39:0];
    scu_ext_aw_len    <= next_scu_ext_aw_len;
    scu_ext_aw_size   <= next_scu_ext_aw_size;
    scu_ext_aw_lock   <= next_scu_ext_aw_lock;
    scu_ext_aw_cache  <= next_scu_ext_aw_cache;
    scu_ext_aw_prot   <= next_scu_ext_aw_prot;
    scu_ext_aw_domain <= next_scu_ext_aw_domain;
    scu_ext_aw_snoop  <= next_scu_ext_aw_snoop;
    scu_ext_aw_bar    <= next_scu_ext_aw_bar;
    scu_ext_aw_unique <= next_scu_ext_aw_unique;
    scu_ext_wrmemattr <= next_scu_ext_wrmemattr;
  end


  assign scu_ext_aw_id_o     = scu_ext_aw_id;
  assign scu_ext_aw_addr_o   = {4'b0000, scu_ext_aw_addr};
  assign scu_ext_aw_len_o    = {6'b000000, scu_ext_aw_len};
  assign scu_ext_aw_size_o   = scu_ext_aw_size;
  assign scu_ext_aw_burst_o  = 2'b01;
  assign scu_ext_aw_lock_o   = scu_ext_aw_lock;
  assign scu_ext_aw_cache_o  = scu_ext_aw_cache;
  assign scu_ext_aw_prot_o   = {1'b0, scu_ext_aw_prot};
  assign scu_ext_aw_domain_o = scu_ext_aw_domain;
  assign scu_ext_aw_snoop_o  = scu_ext_aw_snoop;
  assign scu_ext_aw_bar_o    = scu_ext_aw_bar;
  assign scu_ext_aw_unique_o = scu_ext_aw_unique;
  assign scu_ext_wrmemattr_o = scu_ext_wrmemattr;


  //-----------------------------------------------------------------------------
  //  Write address hazard buffers
  //-----------------------------------------------------------------------------


  // If all waddrs are in use then further writes must be stalled.
  assign waddr_available = waddr_lower_empty[NUM_WADDRS-1] | ~waddr_valid[NUM_WADDRS-1];

  // Identify the lowest numbered waddr that is empty, so that this can be used
  // to hold the next write address.
  assign first_empty_waddr = ~waddr_valid & ~waddr_lower_empty;

  // Enable the address and CPU storage in the waddr only when a new entry is written.
  assign waddr_en = ({NUM_WADDRS{new_arb_waddr_req}} & first_empty_waddr);

  // Also enable the status bits when the waddr is cleared or the data is sent
  // (if a device write).
  assign waddr_status_en = waddr_en | free_waddr | upgrade_dev_waddr;

  assign waddr_outstanding_en = (new_arb_waddr_req |
                                 cpuslv0_sample_waddrs_i |
                                 cpuslv1_sample_waddrs_i |
                                 cpuslv2_sample_waddrs_i |
                                 cpuslv3_sample_waddrs_i);

  // The new status field for any new write address.
  assign new_waddr_status = ((addr_arb_id_i[5:3] == 3'b100)          ? 3'b001 : // ACP
                             addr_arb_lock_i                         ? 3'b110 :
                             `CA53_MEM_COHERENT(addr_arb_attrs_i)    ? 3'b010 :
                             `CA53_MEM_REORDERABLE(addr_arb_attrs_i) ? 3'b011 :
                                                                       3'b100); // Non-reorderable device

  assign cpuslv_sample_waddrs = {cpuslv3_sample_waddrs_i,
                                 cpuslv2_sample_waddrs_i,
                                 cpuslv1_sample_waddrs_i,
                                 cpuslv0_sample_waddrs_i};

  assign cpuslv_sample_waddrs_dsb = {cpuslv3_sample_waddrs_dsb_i,
                                     cpuslv2_sample_waddrs_dsb_i,
                                     cpuslv1_sample_waddrs_dsb_i,
                                     cpuslv0_sample_waddrs_dsb_i};

  // Because a non-reorderable device response could match several waddrs, we
  // must pick one. This uses round-robin to ensure that any single waddr cannot
  // remain valid indefinitely, and thus prevent a DSB from making progress.
  assign waddr_dev_rr_en = db_valid & (db_id[4:2] == 3'b011);

  ca53_rr_reg_arb #(.WIDTH(NUM_WADDRS)) u_waddr_dev_arb (
    .clk        (clk_master),
    .reset_n    (reset_n),
    .enable_i   (waddr_dev_rr_en),
    .requests_i (waddr_matching_dev),
    .arb_o      (waddr_dev_arb)
  );

  generate for (i = 0; i < NUM_WADDRS; i = i + 1) begin : g_buf

    // Decode the status field
    assign waddr_valid[i] = |waddr_status[i];
    assign waddr_strex[i] = (waddr_status[i] == 3'b110);
    assign waddr_dev[i] = (waddr_status[i][2:1] == 2'b10);
    assign waddr_sent_dev[i] = (waddr_status[i] == 3'b101);
    assign waddr_coh[i] = ((waddr_status[i] == 3'b001) |
                           (waddr_status[i] == 3'b010));


    assign waddr_matching_dev[i] = waddr_sent_dev[i] & db_valid & (db_id[1:0] == waddr_cpu[i]);

    // Calculate if this buffer has any lower numbered buffers that are empty, or device from the same CPU.
    if (i == 0) begin : g_buf0
      assign waddr_lower_empty[i] = 1'b0;
    end else begin : g_others
      assign waddr_lower_empty[i] = ~waddr_valid[i-1] | waddr_lower_empty[i-1];
    end

    // Free this buffer if a received write response directly matches this
    // buffer entry, it is a STREX response for the same CPU (there can be
    // only one waddr that matches), or a device response for the same CPU
    // (there can be several that match, but we can pick any one of them).
    assign free_waddr[i] = db_valid & ((db_id[4] & (db_id[3:0] == i[3:0])) |
                                       (waddr_strex[i] & ((db_id[4:2] == 3'b000) &
                                                          (db_id[1:0] == waddr_cpu[i]))) |
                                       (waddr_dev_arb[i] & (db_id[4:2] == 3'b011)));

    // When the data is sent for a non-reordereable device write, then upgrade
    // the waddr status to indicate the data has been sent. This must not happen
    // until after the address to be sent has been read from the waddr, as once
    // upgraded the entry may be cleared by a different device write response.
    assign upgrade_dev_waddr[i] = data_aw_req & (data_arb_id_i[3:0] == i[3:0]) & waddr_dev[i];


    assign next_waddr_status[i] = (waddr_en[i] ? new_waddr_status :
                                   upgrade_dev_waddr[i] ? 3'b101 :
                                   3'b000);

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      waddr_status[i] <= 3'b000;
    end else if (waddr_status_en[i]) begin
      waddr_status[i] <= next_waddr_status[i];
    end

    // Capture the address and CPU.
    always @(posedge clk_master)
    if (waddr_en[i]) begin
      waddr_addr[i] <= addr_arb_addr_i[40:6];
      waddr_cpu[i]  <= addr_arb_id_i[4:3];
    end

    // Hazard checking. Device writes are not checked by address because they
    // are checked independently of address. Because the waddrs are not cleared
    // by ID for device accesses, an address hazard could otherwise remain after
    // the transaction had finished.
    // Non-coherent writes should only hazard accesses from the same CPU, and
    // must not hazard snoops.
    assign hazard_tc1[i] = (waddr_valid[i] & ~waddr_dev[i] &
                            (waddr_coh[i] | (tagctl_reqbufid_tc1_i[5:3] == {1'b0, waddr_cpu[i]})) &
                            tagctl_addr_valid_tc1_i &
                            (tagctl_addr_tc1_i == waddr_addr[i]));
    assign hazard_tc3[i] = (waddr_valid[i] & waddr_coh[i] &
                            tagctl_addr_valid_tc3_i &
                            (tagctl_addr_tc3_i == waddr_addr[i]));

    assign hazard_dev_tc1[i] = (waddr_valid[i] & waddr_dev[i] &
                                tagctl_addr_valid_tc1_i &
                                ~tagctl_reqbufid_tc1_i[5] &
                                (tagctl_reqbufid_tc1_i[4:3] == waddr_cpu[i]));

    // When a CPU issues a barrier, mark all waddrs that are outstanding for
    // that CPU at that time. The barrier will wait for them to drain, but new
    // writes from the same CPU may overtake the barrier and mustn't cause the
    // barrier to wait for longer.
    for (j = 0; j < 4; j = j + 1) begin : g_cpus

      if (j < NUM_CPUS) begin : g_cpu

        assign next_waddr_outstanding[j][i] = ((cpuslv_sample_waddrs[j] & (waddr_cpu[i] == j[1:0])) |
                                               cpuslv_sample_waddrs_dsb[j] |
                                               waddr_outstanding[j][i]) & ~waddr_en[i];

        always @(posedge clk_master)
        if (waddr_outstanding_en) begin
          waddr_outstanding[j][i] <= next_waddr_outstanding[j][i];
        end
  
        assign waddr_outstanding_cpu[j][i] = waddr_valid[i] & waddr_outstanding[j][i];

      end else begin : g_n_cpu

        assign waddr_outstanding_cpu[j][i] = 1'b0;

      end
    end

  end endgenerate

  // Let the cpuslv know when it has outstanding waddrs, so it can track
  // requests for barriers.
  assign master_cpuslv0_waddrs_valid_o = |waddr_outstanding_cpu[0];
  assign master_cpuslv1_waddrs_valid_o = |waddr_outstanding_cpu[1];
  assign master_cpuslv2_waddrs_valid_o = |waddr_outstanding_cpu[2];
  assign master_cpuslv3_waddrs_valid_o = |waddr_outstanding_cpu[3];

  // Tell tagctl when a response for a non-coherent write is received, so that
  // it can maintain a count of outstanding accesses.
  assign master_ncoh_db_o = |(free_waddr & ~waddr_coh);

  // When a snpslv barrier starts, sample the currently valid waddrs. Indicate
  // back to the slv when all of those have drained.
  assign snp_barrier_waddrs_en = snpslv_sample_waddrs_i | (db_valid & master_snpslv_waddrs_valid);

  assign next_snp_barrier_waddrs = (snpslv_sample_waddrs_i ? waddr_valid : snp_barrier_waddrs) & ~free_waddr;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    snp_barrier_waddrs <= {NUM_WADDRS{1'b0}};
  end else if (snp_barrier_waddrs_en) begin
    snp_barrier_waddrs <= next_snp_barrier_waddrs;
  end

  assign master_snpslv_waddrs_valid = |snp_barrier_waddrs;
  assign master_snpslv_waddrs_valid_o = master_snpslv_waddrs_valid;

  // Register the hazard comparison results before returning them to tagctl.
  assign next_master_hz_tc2 = |hazard_tc1;
  assign next_master_hz_tc4 = |hazard_tc3;
  assign next_master_hz_dev_tc2 = |hazard_dev_tc1;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    master_hz_tc2     <= 1'b0;
    master_hz_tc4     <= 1'b0;
    master_hz_dev_tc2 <= 1'b0;
  end else begin
    master_hz_tc2     <= next_master_hz_tc2;
    master_hz_tc4     <= next_master_hz_tc4;
    master_hz_dev_tc2 <= next_master_hz_dev_tc2;
  end

  assign next_master_hz_waddr_tc4 = {|hazard_tc3[15:8],
                                     |{hazard_tc3[15:12], hazard_tc3[7:4]},
                                     |{hazard_tc3[15:14], hazard_tc3[11:10], hazard_tc3[7:6], hazard_tc3[3:2]},
                                     |{hazard_tc3[15], hazard_tc3[13], hazard_tc3[11], hazard_tc3[9],
                                       hazard_tc3[7], hazard_tc3[5], hazard_tc3[3], hazard_tc3[1]}};

  always @(posedge clk)
  begin
    master_hz_waddr_tc4 <= next_master_hz_waddr_tc4;
  end

  assign master_hz_tc2_o = master_hz_tc2;
  assign master_hz_tc4_o = master_hz_tc4;
  assign master_hz_dev_tc2_o = master_hz_dev_tc2;
  assign master_hz_waddr_tc4_o = master_hz_waddr_tc4;

  assign master_waddr_valid_o = waddr_valid;

  // Encode the waddr being allocated before passing back to the AFB in the following cycle.
  assign next_addr_arb_waddr_id = {|waddr_en[15:8],
                                   |{waddr_en[15:12], waddr_en[7:4]},
                                   |{waddr_en[15:14], waddr_en[11:10], waddr_en[7:6], waddr_en[3:2]},
                                   |{waddr_en[15], waddr_en[13], waddr_en[11], waddr_en[9],
                                     waddr_en[7], waddr_en[5], waddr_en[3], waddr_en[1]}};

  assign addr_arb_waddr_id_en = new_arb_waddr_req & waddr_available;

  always @(posedge clk_master)
  if (addr_arb_waddr_id_en) begin
    addr_arb_waddr_id <= next_addr_arb_waddr_id;
  end

  assign addr_arb_waddr_id_o = addr_arb_waddr_id;



  // Write address requests due to data
  // ----------------------------------

  // The upper bits of the address are read from the waddr, but the lower bits
  // are calulated from the byte strobes of the L2DB.
  assign data_arb_full_addr = {waddr_addr[data_arb_id_i[3:0]][40:6], data_arb_addr_i};

  assign next_aw_skid_valid = (((data_aw_req & ~aw_block_data) | aw_skid_valid) &
                               ~(clean_aclken_i & (~scu_ext_aw_valid | scu_ext_aw_ready_i)));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    aw_skid_valid <= 1'b0;
  end else begin
    aw_skid_valid <= next_aw_skid_valid;
  end


  always @(posedge clk_master)
  if (data_aw_req) begin
    aw_skid_ext_id <= data_arb_ext_id;
    aw_skid_opcode <= data_arb_opcode_i;
    aw_skid_len    <= data_arb_len_i;
    aw_skid_size   <= data_arb_size_i;
    aw_skid_attrs  <= data_arb_attrs_i;
    aw_skid_prot   <= data_arb_prot_i;
    aw_skid_strex  <= data_arb_strex_i;
    aw_skid_unique <= data_arb_unique_i;
    aw_skid_addr   <= data_arb_full_addr;
  end

  assign data_arb_ext_id = (data_arb_strex_i                         ? {3'b000, data_arb_id_i[5:4]} :
                            ~`CA53_MEM_REORDERABLE(data_arb_attrs_i) ? {3'b011, data_arb_id_i[5:4]} :
                                                                       {1'b1, data_arb_id_i[3:0]});

  assign data_aw_opcode = aw_skid_valid ? aw_skid_opcode : data_arb_opcode_i;
  assign data_aw_len    = aw_skid_valid ? aw_skid_len    : data_arb_len_i;
  assign data_aw_size   = aw_skid_valid ? aw_skid_size   : data_arb_size_i;
  assign data_aw_attrs  = aw_skid_valid ? aw_skid_attrs  : data_arb_attrs_i;
  assign data_aw_prot   = aw_skid_valid ? aw_skid_prot   : data_arb_prot_i;
  assign data_aw_strex  = aw_skid_valid ? aw_skid_strex  : data_arb_strex_i;
  assign data_aw_unique = aw_skid_valid ? aw_skid_unique : data_arb_unique_i;
  assign data_aw_dev    = ~`CA53_MEM_REORDERABLE(data_aw_attrs);

  //-----------------------------------------------------------------------------
  //  Write data channel
  //-----------------------------------------------------------------------------


  // An arbitrated request can always be accepted if the skid buffer is empty
  // or the port can definitely accept a request this cycle.
  assign data_arb_dw_ready = (~data_skid_dw_valid &
                              (~data_skid_cd_valid |
                               (clean_aclken_i & ~scu_ext_dw_valid)));

  assign data_arb_cd_ready = (~data_skid_cd_valid &
                              (~data_skid_dw_valid | cd_ready));

  assign data_arb_dw_ready_o = data_arb_dw_ready;
  assign data_arb_cd_ready_o = data_arb_cd_ready;

  assign data_arb_ready = data_arb_snoop_i ? data_arb_cd_ready : data_arb_dw_ready;

  // If this is the first beat of write data, then the address must be read out of the
  // waddrs and sent on the AW channel.
  assign data_aw_req = data_arb_req_i & data_arb_ready & ~data_arb_snoop_i & data_arb_first_i;

  // Evict transactions must send the address but no data beats.
  assign new_data_arb_req = data_arb_req_i & data_arb_ready & (data_arb_opcode_i != `CA53_DATA_OPCODE_EVICT);

  // Drive external valid signals
  assign next_scu_ext_dw_valid = ((scu_ext_dw_valid & ~scu_ext_dw_ready_i) |
                                  data_skid_dw_valid |
                                  (new_data_arb_req & ~data_arb_snoop_i));

  assign next_scu_ext_cd_valid = ((scu_ext_cd_valid & ~scu_ext_cd_ready_i) |
                                  data_skid_cd_valid |
                                  cd_skid0_valid |
                                  cd_skid1_valid |
                                  (new_data_arb_req & data_arb_snoop_i));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_ext_dw_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_dw_valid <= next_scu_ext_dw_valid;
  end

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_ext_cd_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_cd_valid <= next_scu_ext_cd_valid;
  end

  // The skid buffer can hold either dw or cd data, but not both.
  assign next_data_skid_dw_valid = ((data_skid_dw_valid | (new_data_arb_req & ~data_arb_snoop_i)) &
                                    ~(clean_aclken_i & (~scu_ext_dw_valid | scu_ext_dw_ready_i)));

  assign next_data_skid_cd_valid = ((data_skid_cd_valid | (new_data_arb_req & data_arb_snoop_i)) &
                                    ~cd_ready);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    data_skid_dw_valid <= 1'b0;
    data_skid_cd_valid <= 1'b0;
  end else begin
    data_skid_dw_valid <= next_data_skid_dw_valid;
    data_skid_cd_valid <= next_data_skid_cd_valid;
  end


  assign skid_en = (new_data_arb_req &
                    (data_arb_snoop_i ? ~cd_ready : 
                                        ((scu_ext_dw_valid &
                                          ~(clean_aclken_i & scu_ext_dw_ready_i)) |
                                         ~clean_aclken_i)));

  always @(posedge clk_master)
  if (skid_en) begin
    data_skid_data <= data_arb_data_i;
    data_skid_strb <= data_arb_strb_i;
    data_skid_last <= data_arb_last_i;
  end


  // The AW skid is used for the ID rather than store it separately for DW,
  // because the AW skid cannot be overwritten until this burst has completed.
  assign next_scu_dw_ext_id   = data_aw_req        ? data_arb_ext_id : aw_skid_ext_id;
  assign next_scu_dw_ext_data = data_skid_dw_valid ? data_skid_data  : data_arb_data_i;
  assign next_scu_dw_ext_strb = data_skid_dw_valid ? data_skid_strb  : data_arb_strb_i;
  assign next_scu_dw_ext_last = data_skid_dw_valid ? data_skid_last  : data_arb_last_i;

  // Enable the output registers only when there is valid data to send, and the
  // output register is ready to accept new data.
  assign ext_dw_en = (clean_aclken_i &
                      (data_skid_dw_valid |
                       (new_data_arb_req & ~data_arb_snoop_i)) &
                      (~scu_ext_dw_valid | scu_ext_dw_ready_i));

  always @(posedge clk_master)
  if (ext_dw_en) begin
    scu_ext_dw_id   <= next_scu_dw_ext_id;
    scu_ext_dw_data <= next_scu_dw_ext_data;
    scu_ext_dw_strb <= next_scu_dw_ext_strb;
    scu_ext_dw_last <= next_scu_dw_ext_last;
  end

  // Select between arbitrated data and the main skid buffer.
  assign new_scu_cd_ext_data = data_skid_cd_valid ? data_skid_data : data_arb_data_i;
  assign new_scu_cd_ext_last = data_skid_cd_valid ? data_skid_last : data_arb_last_i;

  // The CD channel has two additional skid buffers so that the combination of
  // the skid buffers and the interface register can hold a whole cache line of
  // data. This is required so that the L2DB can be freed up before the CR
  // response is sent if the snoop hit on an L2DB, and therefore any external
  // read data cannot be returned by the interconnect until the L2DB is ready.
  assign cd_ready = ~(cd_skid0_valid & cd_skid1_valid);
                                      
  assign cd_skid0_en = (((new_data_arb_req & data_arb_snoop_i) |
                         data_skid_cd_valid) &
                        cd_ready &
                        ~cd_skid0_valid &
                        (cd_skid1_valid | ~ext_cd_en));

  assign cd_skid1_en = (((new_data_arb_req & data_arb_snoop_i) |
                         data_skid_cd_valid) &
                        cd_ready &
                        cd_skid0_valid &
                        ~cd_skid1_valid);

  assign next_cd_skid0_valid = ((cd_skid0_valid & (~ext_cd_en | (cd_skid1_valid & cd_skid0_newest))) |
                                cd_skid0_en);
  
  assign next_cd_skid1_valid = ((cd_skid1_valid & (~ext_cd_en | (cd_skid0_valid & ~cd_skid0_newest))) |
                                cd_skid1_en);

  assign next_cd_skid0_newest = cd_skid0_en | (cd_skid0_newest & ~cd_skid1_en);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    cd_skid0_valid  <= 1'b0;
    cd_skid1_valid  <= 1'b0;
    cd_skid0_newest <= 1'b0;
  end else begin
    cd_skid0_valid  <= next_cd_skid0_valid;
    cd_skid1_valid  <= next_cd_skid1_valid;
    cd_skid0_newest <= next_cd_skid0_newest;
  end

  always @(posedge clk_master)
  if (cd_skid0_en) begin
    cd_skid0_data <= new_scu_cd_ext_data;
    cd_skid0_last <= new_scu_cd_ext_last;
  end

  always @(posedge clk_master)
  if (cd_skid1_en) begin
    cd_skid1_data <= new_scu_cd_ext_data;
    cd_skid1_last <= new_scu_cd_ext_last;
  end

  // Pick the oldest skid buffer, if neither valid then any new data.
  assign next_scu_cd_ext_data = (cd_skid0_valid &
                                 ~(cd_skid1_valid &
                                   cd_skid0_newest)) ? cd_skid0_data :
                                cd_skid1_valid       ? cd_skid1_data :
                                                       new_scu_cd_ext_data;

  assign next_scu_cd_ext_last = (cd_skid0_valid &
                                 ~(cd_skid1_valid &
                                   cd_skid0_newest)) ? cd_skid0_last :
                                cd_skid1_valid       ? cd_skid1_last :
                                                       new_scu_cd_ext_last;

  // Enable the output registers only when there is valid data to send, and the
  // output register is ready to accept new data.
  assign ext_cd_en = (clean_aclken_i &
                      (data_skid_cd_valid |
                       cd_skid0_valid |
                       cd_skid1_valid |
                       (new_data_arb_req & data_arb_snoop_i)) &
                      (~scu_ext_cd_valid | scu_ext_cd_ready_i));

  always @(posedge clk_master)
  if (ext_cd_en) begin
    scu_ext_cd_data <= next_scu_cd_ext_data;
    scu_ext_cd_last <= next_scu_cd_ext_last;
  end


  assign scu_ext_dw_valid_o = scu_ext_dw_valid;
  assign scu_ext_dw_id_o    = scu_ext_dw_id;
  assign scu_ext_dw_data_o  = scu_ext_dw_data;
  assign scu_ext_dw_strb_o  = scu_ext_dw_strb;
  assign scu_ext_dw_last_o  = scu_ext_dw_last;

  assign scu_ext_cd_valid_o = scu_ext_cd_valid;
  assign scu_ext_cd_data_o  = scu_ext_cd_data;
  assign scu_ext_cd_last_o  = scu_ext_cd_last;


  // If the skid buffer is empty, then allow the arbitration to select any type of
  // request, otherwise only choose requests that have a different type of data
  // from that which is in the skid buffer.
  assign data_arb_sel_snoop_o = ~data_skid_cd_valid;
  assign data_arb_sel_write_o = ~data_skid_dw_valid;

  // Only accept a new first beat of write data if we know we can accept the
  // address ID.
  assign data_arb_sel_write_first_o = ~aw_skid_valid & ~aw_block_data;

  //-----------------------------------------------------------------------------
  //  Write response channel
  //-----------------------------------------------------------------------------

  // Responses can always be accepted, because nothing else in the SCU can
  // apply backpressure.
  assign scu_ext_db_ready_o = 1'b1;


  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ext_db_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    ext_db_valid <= scu_ext_db_valid_i;
  end

  // Internally pulse db_valid for a single core cycle.
  assign db_valid = ext_db_valid & clean_aclken_i;

  // Return WACK on the next ACLK cycle following the write response.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_ext_wack <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_wack <= ext_db_valid;
  end

  assign scu_ext_wack_o = scu_ext_wack;

  assign db_en = clean_aclken_i & scu_ext_db_valid_i;

  always @(posedge clk)
  if (db_en) begin
    db_id   <= scu_ext_db_id_i;
    db_resp <= scu_ext_db_resp_i;
  end

  // Indicate an error so that nEXTERRIRQ can be asserted, for anything that
  // cannot be attributed back to a CPU.
  // This includes coherent writes and snpslv accesses.
  assign err_response_o = ((db_valid & db_resp[1] & ((db_id == 5'b01001) |
                                                     (db_id[4] & waddr_coh[db_id[3:0]]))) |
                           (read_resp_valid & read_resp_ready_i &
                            (read_resp_ext_id == 6'b001001) & read_resp[1]));


  // Send any response for a STREX back to the cpuslv that made the request.
  assign strex_db_valid = db_valid & (db_id[4:2] == 3'b000);

  assign master_cpuslv3_strex_db_valid_o = strex_db_valid & (db_id[1:0] == 2'b11);
  assign master_cpuslv2_strex_db_valid_o = strex_db_valid & (db_id[1:0] == 2'b10);
  assign master_cpuslv1_strex_db_valid_o = strex_db_valid & (db_id[1:0] == 2'b01);
  assign master_cpuslv0_strex_db_valid_o = strex_db_valid & (db_id[1:0] == 2'b00);

  // Send any response for any device or non-coherent write back to the cpuslv
  // that made the request.
  assign ncoh_db_valid = db_valid & ((db_id[4:2] == 3'b011) |
                                     (db_id[4] & ~waddr_coh[db_id[3:0]]));

  assign db_cpu = db_id[4] ? waddr_cpu[db_id[3:0]] : db_id[1:0];

  assign master_cpuslv3_dev_db_valid_o = ncoh_db_valid & (db_cpu[1:0] == 2'b11);
  assign master_cpuslv2_dev_db_valid_o = ncoh_db_valid & (db_cpu[1:0] == 2'b10);
  assign master_cpuslv1_dev_db_valid_o = ncoh_db_valid & (db_cpu[1:0] == 2'b01);
  assign master_cpuslv0_dev_db_valid_o = ncoh_db_valid & (db_cpu[1:0] == 2'b00);

  assign master_db_resp_o = db_resp;

  // Send any write response for a DMB or DSB back to the cpuslv that made the
  // request, so it can know when both the read and write parts have completed.
  assign barrier_db_valid = db_valid & (db_id[4:2] == 3'b001);

  assign master_cpuslv3_barrier_db_valid_o = barrier_db_valid & (db_id[1:0] == 2'b11);
  assign master_cpuslv2_barrier_db_valid_o = barrier_db_valid & (db_id[1:0] == 2'b10);
  assign master_cpuslv1_barrier_db_valid_o = barrier_db_valid & (db_id[1:0] == 2'b01);
  assign master_cpuslv0_barrier_db_valid_o = barrier_db_valid & (db_id[1:0] == 2'b00);

  assign master_db_waddr_valid_o = db_valid & db_id[4];
  assign master_db_waddr_o = db_id[3:0];

  assign master_snpslv_db_valid_o = db_valid & (db_id == 5'b01001);

  //-----------------------------------------------------------------------------
  //  Read data channel
  //-----------------------------------------------------------------------------


  // Record when the interface registers contain a beat of data/response. These
  // registers are only clocked on ACLK cycles, so the data may have left
  // in the following cycle even if this register is still set. This is
  // indicated by read_resp_sent being asserted.
  assign next_ext_read_valid = scu_ext_dr_valid_i | (ext_read_valid & ~scu_ext_dr_ready);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ext_read_valid <= 1'b0;
  end else if (clean_aclken_i) begin
    ext_read_valid <= next_ext_read_valid;
  end


  // Record when the beat of data has been sent to the read buffers, but is
  // still valid in the interface registers because we haven't reached the
  // next ACLK cycle.
  assign next_read_resp_sent = (((ext_read_valid & read_resp_ready_i) | read_resp_sent) &
                                ~(clean_aclken_i & scu_ext_dr_ready));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    read_resp_sent <= 1'b0;
  end else begin
    read_resp_sent <= next_read_resp_sent;
  end

  // Send the beat to the read buffers as soon as possible if it hasn't already
  // been sent.
  assign read_resp_valid = ext_read_valid & ~read_resp_sent;
  assign read_resp_valid_o = read_resp_valid;


  // Indicate if we can accept another beat in the next ACLK cycle. This is if
  // we are empty or becoming empty, and not filling this cycle or have enough
  // space in the read buffers for at least this beat and the next.
  assign next_scu_ext_dr_ready = (((~ext_read_valid | read_resp_sent) | read_resp_ready_i) &
                                  (~scu_ext_dr_valid_i | read_resp_next_ready_i));


  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    scu_ext_dr_ready <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_dr_ready <= next_scu_ext_dr_ready;
  end

  assign scu_ext_dr_ready_o = scu_ext_dr_ready;

  // Clock the interface data registers only when there is a new transaction.
  assign dr_en = clean_aclken_i & scu_ext_dr_valid_i & scu_ext_dr_ready;

  always @(posedge clk)
  if (dr_en) begin
    read_resp_data   <= scu_ext_dr_data_i;
    read_resp_ext_id <= scu_ext_dr_id_i;
    read_resp        <= scu_ext_dr_resp_i;
    read_resp_last   <= scu_ext_dr_last_i;
  end

  assign read_resp_data_o = read_resp_data;
  assign read_resp_o = read_resp;

  // Return RACK on the next ACLK cycle following the last beat of data.
  assign next_scu_ext_rack = scu_ext_dr_valid_i & scu_ext_dr_ready & scu_ext_dr_last_i;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    scu_ext_rack <= 1'b0;
  end else if (clean_aclken_i) begin
    scu_ext_rack <= next_scu_ext_rack;
  end

  assign scu_ext_rack_o = scu_ext_rack;

  // Calculate the chunk ID (the quadword offset) of each beat of read data.
  // All bursts can be treated as wrapping on a 64byte boundary, because no
  // incrementing burst will ever cross such a boundary.

  // Pop the chunks and FIFOs when the read buffer might get overwritten,
  // rather than when it is sent, to help timing.
  assign dr_req_pop = ext_read_valid & (read_resp_sent | (clean_aclken_i & scu_ext_dr_ready)) & ~dr_req_popped;

  // Record when the request has been popped, so that we don't pop it a second
  // time. We cannot delay the pop until the next aclk cycle, because if aclk
  // is very slow then the next ar request for the same ID might arrive before
  // we have popped the old request.
  assign next_dr_req_popped = (dr_req_pop | dr_req_popped) & ~(clean_aclken_i & scu_ext_dr_ready);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    dr_req_popped <= 1'b0;
  end else begin
    dr_req_popped <= next_dr_req_popped;
  end

  // Enable all chunks if any might need to change.
  assign read_chunk_en = (clean_aclken_i & new_arb_ar_req) | dr_req_pop;

  // The DCU chunk logic needs enabling a cycle after the main FIFO when
  // pushing, because it gets its input from the main FIFO.
  assign dcu_read_chunk_en = scu_ext_ar_valid | dr_req_pop;


  // Calculate when an address request is sent, in order to reset the chunk
  // counters to the critial quadword.
  // Note that this does not factor the external ar_ready signal in, to reduce
  // the fanout on that signal. The registers will usually not be enabled if
  // ar_ready is not set, but if they are it does not matter functionally if
  // the registers are updated multiple times because the data cannot arrive
  // back until after the address is accepted.
  assign cpu_ar_req = clean_aclken_i & new_arb_ar_req & ~addr_arb_id_i[5];
  assign acp_ar_req = clean_aclken_i & new_arb_ar_req & (addr_arb_id_i[5:3] == 3'b100);

  // Calculate when a read data beat is returned, so that the chunk counter
  // for that burst can be incremented.
  assign cpu_dr_req = (read_resp_ext_id[5] | (read_resp_ext_id[4:2] == 3'b000));
  assign acp_dr_req = (read_resp_ext_id[5:4] == 2'b01);

  generate for (i = 0; i < 4*8; i = i + 1) begin : g_chunk_cpu
    if (i < NUM_CPUS*8) begin : g_chunk_cpu_present

      assign next_read_chunk_cpu[i] = (cpu_ar_req & (addr_arb_id_i[4:0] == i[4:0])) ? addr_arb_addr_i[5:4] :
                                      (cpu_dr_req & dr_req_pop &
                                       (read_resp_id[4:0] == i[4:0]))  ? (read_chunk_cpu[i] + 2'b01) :
                                                                         read_chunk_cpu[i];

      always @ (posedge clk_master)
      if (read_chunk_en) begin
        read_chunk_cpu[i] <= next_read_chunk_cpu[i];
      end

      assign read_chunk_cpu_all[i] = read_chunk_cpu[i];

    end else begin : g_chunk_cpu_n_present

      assign read_chunk_cpu_all[i] = 2'b00;

    end
  end endgenerate


  generate if (ACP) begin : g_chunk_acp
    reg  [1:0] read_chunk_acp      [3:0];
    wire [1:0] next_read_chunk_acp [3:0];

    for (i = 0; i < 4; i = i + 1) begin : g_chunk
      assign next_read_chunk_acp[i] = (acp_ar_req & (addr_arb_id_i[1:0] == i[1:0])) ? addr_arb_addr_i[5:4] :
                                      (acp_dr_req & dr_req_pop &
                                       (read_resp_ext_id[3:2] == i[1:0]))  ? (read_chunk_acp[i] + 2'b01) :
                                                                             read_chunk_acp[i];

      always @ (posedge clk_master)
      if (read_chunk_en) begin
        read_chunk_acp[i] <= next_read_chunk_acp[i];
      end
    end

    // Select the chunk ID for the beat being returned. This uses
    // read_resp_ext_id rather than the decoded read_resp_id to improve timing
    // on the DCU IDs.
    assign read_resp_chunk_o = (({2{dcu_dr_req}}               & dcu_read_resp_chunk_all[read_resp_ext_id[1:0]]) |
                                ({2{cpu_dr_req & ~dcu_dr_req}} & read_chunk_cpu_all[{read_resp_ext_id[1:0], read_resp_ext_id[4:2]}]) |
                                ({2{acp_dr_req}}               & read_chunk_acp[read_resp_ext_id[3:2]]));

  end else begin : g_chunk_nacp

    assign read_resp_chunk_o = dcu_dr_req ? dcu_read_resp_chunk_all[read_resp_ext_id[1:0]] :
                                            read_chunk_cpu_all[{read_resp_ext_id[1:0], read_resp_ext_id[4:2]}];

  end endgenerate

  // For requests that go out on the DCU ID, there can be multiple requests on
  // the same ID and so we must keep track of which reqbufs generated the
  // requests, and in what order. This uses a FIFO per CPU, with head and tail
  // pointers for each.

  // Detect push and pop requests. We push on a new address request, and pop on
  // the last beat of data. To avoid factoring the ready signals into more places than
  // necessary, we push/pop assuming that the request will be accepted, and then
  // record the fact that it has been pushed/popped so that is not pushed a second time.
  assign dcu_ar_req = (new_arb_ar_req &
                       ~dcu_ar_req_pushed &
                       (addr_arb_id_i[6] &
                        (addr_arb_lock_i |
                         ~`CA53_MEM_REORDERABLE(addr_arb_attrs_i))));

  assign next_dcu_ar_req_pushed = ((new_arb_ar_req | dcu_ar_req_pushed) &
                                   ~(new_arb_ar_req & clean_aclken_i & (~scu_ext_ar_valid | scu_ext_ar_ready_i)));

  always @ (posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    dcu_ar_req_pushed <= 1'b0;
  end else if (read_chunk_en) begin
    dcu_ar_req_pushed <= next_dcu_ar_req_pushed;
  end

  assign dcu_dr_req = (read_resp_ext_id[5:2] == 4'b0000);

  generate for (i = 0; i < 4; i = i + 1) begin : g_fifo_ctl_dcu
    if (i < NUM_CPUS) begin : g_fifo_ctl_dcu_present

      // Increment the head pointer when the end of a burst is received.
      assign dcu_reqbuf_fifo_dr[i] = dcu_dr_req & dr_req_pop & (read_resp_ext_id[1:0] == i[1:0]);

      assign dcu_reqbuf_fifo_pop[i] = dcu_reqbuf_fifo_dr[i] & read_resp_last;

      assign dcu_reqbuf_fifo_head_plus_one[i] = dcu_reqbuf_fifo_head[i] + 2'b01;

      assign next_dcu_reqbuf_fifo_head[i] = dcu_reqbuf_fifo_pop[i] ? dcu_reqbuf_fifo_head_plus_one[i] : dcu_reqbuf_fifo_head[i];

      // Increment the tail pointer when a new DCU address is sent.
      assign dcu_reqbuf_fifo_tail_plus_one[i] = dcu_reqbuf_fifo_tail[i] + 2'b01;

      assign next_dcu_reqbuf_fifo_tail[i] = (dcu_ar_req & (addr_arb_id_i[4:3] == i[1:0])) ?
                                            dcu_reqbuf_fifo_tail_plus_one[i] : dcu_reqbuf_fifo_tail[i];

      always @ (posedge clk_master or negedge reset_n)
      if (~reset_n) begin
        dcu_reqbuf_fifo_head[i] <= 2'b00;
        dcu_reqbuf_fifo_tail[i] <= 2'b00;
      end else if (read_chunk_en) begin
        dcu_reqbuf_fifo_head[i] <= next_dcu_reqbuf_fifo_head[i];
        dcu_reqbuf_fifo_tail[i] <= next_dcu_reqbuf_fifo_tail[i];
      end

      // Calculate the next chunk for DCU IDs, depending on what (if any)
      // response is arriving this cycle.
      assign dcu_chunk_this_burst[i] = read_chunk_cpu[{i[1:0], dcu_reqbuf_fifo[{i[1:0], dcu_reqbuf_fifo_head[i]}]}];
      assign dcu_chunk_next_burst[i] = read_chunk_cpu[{i[1:0], dcu_reqbuf_fifo[{i[1:0], dcu_reqbuf_fifo_head_plus_one[i]}]}];
      assign dcu_chunk_next_beat[i] = dcu_read_resp_chunk[i] + 2'b01;

      // Calculate the next chunk for DCU IDs, and register it so that it is
      // ready early in the next cycle. This forms a cache of the main FIFO, so
      // that we don't have to calculate the value in the same cycle as the
      // data is forwarded on elsewhere.
      assign next_dcu_read_resp_chunk[i] = (dcu_reqbuf_fifo_pop[i] ? dcu_chunk_next_burst[i] :
                                            dcu_reqbuf_fifo_dr[i]  ? dcu_chunk_next_beat[i] :
                                                                     dcu_chunk_this_burst[i]);

      assign next_dcu_read_resp_id[i] = (dcu_reqbuf_fifo_pop[i] ? dcu_reqbuf_fifo[{i[1:0], dcu_reqbuf_fifo_head_plus_one[i]}] :
                                                                  dcu_reqbuf_fifo[{i[1:0], dcu_reqbuf_fifo_head[i]}]);

      always @ (posedge clk_master)
      if (dcu_read_chunk_en) begin
        dcu_read_resp_chunk[i] <= next_dcu_read_resp_chunk[i];
        dcu_read_resp_id[i]    <= next_dcu_read_resp_id[i];
      end

      assign dcu_read_resp_chunk_all[i] = dcu_read_resp_chunk[i];
      assign dcu_read_resp_id_all[i]    = dcu_read_resp_id[i];

    end else begin : g_fifo_ctl_dcu_n_present

      assign dcu_read_resp_chunk_all[i] = 2'b00;
      assign dcu_read_resp_id_all[i]    = 3'b000;

    end
  end endgenerate


  generate for (i = 0; i < NUM_CPUS*4; i = i + 1) begin : g_fifo_dcu

    // Store the data value (the reqbuf number) in the FIFO.
    assign next_dcu_reqbuf_fifo[i] = (dcu_ar_req &
                                      (addr_arb_id_i[4:3] == i[3:2]) &
                                      (dcu_reqbuf_fifo_tail[i[3:2]] == i[1:0])) ? addr_arb_id_i[2:0] : dcu_reqbuf_fifo[i];

    always @ (posedge clk_master)
    if (read_chunk_en) begin
      dcu_reqbuf_fifo[i] <= next_dcu_reqbuf_fifo[i];
    end

  end endgenerate

  // For coherent CPU responses and barriers, we can provide an earlier version
  // of the response ID.
  assign read_early_resp_valid_o = read_resp_valid & (read_resp_ext_id[5:2] != 4'b0000);

  assign read_early_resp_id = {~read_resp_ext_id[5], read_resp_ext_id[1:0], read_resp_ext_id[4:2]};
  assign read_early_resp_id_o = read_early_resp_id;

  assign read_early_resp_barrier_o = (read_resp_ext_id[5:2] == 4'b0001);

  // Convert the external read ID back to the internal ID
  // For CPU barriers, create an ID that won't match any reqbuf, because the
  // matching will be done on the early resp.

  assign read_resp_id = `CA53_CREATE_INT_ID(read_resp_ext_id[1:0]);
  assign read_resp_id_o = read_resp_id;

  // Slightly earlier versions, that are only valid for specific destinations.
  assign read_resp_cpuslv0_id_o = `CA53_CREATE_INT_ID(0);
  assign read_resp_cpuslv1_id_o = `CA53_CREATE_INT_ID(1);
  assign read_resp_cpuslv2_id_o = `CA53_CREATE_INT_ID(2);
  assign read_resp_cpuslv3_id_o = `CA53_CREATE_INT_ID(3);
  assign read_resp_acpslv_id_o  = `CA53_CREATE_INT_ID(0);


  //-----------------------------------------------------------------------------
  //  Misc
  //-----------------------------------------------------------------------------

  assign interface_active_o = (data_arb_req_i |
                               scu_ext_ar_valid |
                               scu_ext_aw_valid |
                               scu_ext_dw_valid |
                               scu_ext_cd_valid |
                               data_skid_dw_valid |
                               data_skid_cd_valid |
                               ext_read_valid |
                               scu_ext_rack |
                               ext_db_valid |
                               scu_ext_wack |
                               (|waddr_valid));

  assign master_writes_active_o = (scu_ext_aw_valid |
                                   scu_ext_dw_valid |
                                   ext_db_valid |
                                   scu_ext_wack |
                                   (|waddr_valid));

  // Because the external signals may be running off a slower synchronous clock,
  // we must register them separately from the internal signals that need to be
  // registered every cycle.
  assign next_clk_enable_ext = scu_ext_dr_valid_i | scu_ext_db_valid_i;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable_ext <= 1'b0;
  end else if (clean_aclken_i) begin
    clk_enable_ext <= next_clk_enable_ext;
  end

  assign clk_enable_ext_o = clk_enable_ext;

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only valid, sent waddrs can be cleared")
  u_ovl_waddr_clear (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|free_waddr),
    .consequent_expr (~|(free_waddr & ~(waddr_valid & ~(waddr_dev & ~waddr_sent_dev))))
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Skid buffer cannot hold two types of data at the same time")
  u_ovl_skid_valids (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (data_skid_dw_valid),
    .consequent_expr (~data_skid_cd_valid)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "read_resp_chunk DCU optimisation correct")
  u_ovl_read_resp_chunk (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (read_resp_valid & cpu_dr_req & (read_resp_ext_id[5:2] != 4'b0001)),
    .consequent_expr (read_resp_chunk_o == read_chunk_cpu_all[read_resp_id[4:0]])
  );

  generate for (i = 0; i < 4; i = i + 1) begin : g_ovl_cpu

    wire [NUM_WADDRS-1:0] ovl_valid_strex;
    genvar j;

    for (j = 0; j < NUM_WADDRS; j = j + 1) begin : g_ovl_waddr
      assign ovl_valid_strex[j] = waddr_valid[j] & waddr_strex[j] & (waddr_cpu[j] == i[1:0]);
    end

    assert_zero_one_hot #(`OVL_FATAL, NUM_WADDRS, `OVL_ASSERT, "Each CPU can only have one strex outstanding at a time.")
    u_ovl_only_one_strex_per_cpu (
      .clk       (clk),
      .reset_n   (reset_n),
      .test_expr (ovl_valid_strex)
    );

  end endgenerate

  reg       ovl_dvm_two_part;
  reg [5:0] ovl_dvm_two_part_id;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_dvm_two_part    <= 1'b0;
    ovl_dvm_two_part_id <= 6'b000000;
  end else if (scu_ext_ar_valid & scu_ext_ar_ready_i & clean_aclken_i) begin
    ovl_dvm_two_part    <= (scu_ext_ar_snoop == `CA53_ACE_DVM_MESSAGE) & scu_ext_ar_addr[0] & ~ovl_dvm_two_part;
    ovl_dvm_two_part_id <= scu_ext_ar_id;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The second half of a two part DVM must follow the first")
  u_ovl_dvm_two_part (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_ar_valid & ovl_dvm_two_part),
    .consequent_expr ((scu_ext_ar_snoop == `CA53_ACE_DVM_MESSAGE) & ~scu_ext_ar_addr[0])
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The ID of both parts of a DVM must match")
  u_ovl_dvm_two_part_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_ar_valid & ovl_dvm_two_part),
    .consequent_expr (scu_ext_ar_id == ovl_dvm_two_part_id)
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cd_skid0_en")
  u_ovl_x_cd_skid0_en (.clk       (clk_master),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (cd_skid0_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cd_skid1_en")
  u_ovl_x_cd_skid1_en (.clk       (clk_master),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (cd_skid1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: waddr_outstanding_en")
  u_ovl_x_waddr_outstanding_en (.clk       (clk_master),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (waddr_outstanding_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: db_en")
  u_ovl_x_db_en (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (db_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: snp_barrier_waddrs_en")
  u_ovl_x_snp_barrier_waddrs_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (snp_barrier_waddrs_en));


  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arb_waddr_id_en")
  u_ovl_x_addr_arb_waddr_id_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (addr_arb_waddr_id_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclken_i")
  u_ovl_x_clean_aclken_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (clean_aclken_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_aw_req")
  u_ovl_x_data_aw_req (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (data_aw_req));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dcu_read_chunk_en")
  u_ovl_x_dcu_read_chunk_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (dcu_read_chunk_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dr_en")
  u_ovl_x_dr_en (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (dr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ext_ar_en")
  u_ovl_x_ext_ar_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (ext_ar_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ext_aw_en")
  u_ovl_x_ext_aw_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (ext_aw_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ext_cd_en")
  u_ovl_x_ext_cd_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (ext_cd_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ext_dw_en")
  u_ovl_x_ext_dw_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (ext_dw_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: read_chunk_en")
  u_ovl_x_read_chunk_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (read_chunk_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: skid_en")
  u_ovl_x_skid_en (.clk       (clk),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (skid_en));

  assert_never_unknown #(`OVL_FATAL, NUM_WADDRS, `OVL_ASSERT, "Register enable x-check: waddr_en")
  u_ovl_x_waddr_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (waddr_en));

  assert_never_unknown #(`OVL_FATAL, NUM_WADDRS, `OVL_ASSERT, "Register enable x-check: waddr_status_en")
  u_ovl_x_waddr_status_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (waddr_status_en));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`undef CA53_CREATE_INT_ID
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
