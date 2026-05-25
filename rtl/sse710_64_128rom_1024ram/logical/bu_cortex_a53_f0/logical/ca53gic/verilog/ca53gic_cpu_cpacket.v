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
// Abstract : CortexA53 GIC CPU Interface to Distributor Packet Control Logic
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"


module ca53gic_cpu_cpacket (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire                              activate_ack_recv_i,
  input   wire                              activate_ack_v_recv_i,
  input   wire                              activate_not_release_i,
  input   wire                              activate_not_release_v_i,
  input   wire                              activate_release_pending_i,
  input   wire                              activate_release_v_pending_i,
  input   wire                              arb_tready_i,
  input   wire                              clear_recv_i,
  input   wire  [40:0]                      cp_gov_wdata_i,
  input   wire  [12:0]                      cp_gov_wdata_rs_i,
  input   wire                              cp_virtual_i,
  input   wire                              deactivate_ack_recv_i,
  input   wire                              deactivate_grp0_i,
  input   wire                              deactivate_grp1_ns_i,
  input   wire                              deactivate_grp1_s_i,
  input   wire                              deactivate_lr_grp0_i,
  input   wire                              deactivate_lr_grp1_ns_i,
  input   wire  [(`CA53_GIC_LR_PID_W-1):0]  deactivate_lr_pid_i,
  input   wire                              downstream_wr_recv_i,
  input   wire                              generate_sgi_ack_recv_i,
  input   wire                              grp0_enable_i,
  input   wire                              grp1_ns_enable_i,
  input   wire                              grp1_s_enable_i,
  input   wire  [(`CA53_GIC_ID_W-1):0]      ipr_id_i,
  input   wire  [(`CA53_GIC_ID_W-1):0]      ipr_id_v_i,
  input   wire                              ns_el_i,
  input   wire  [(`CA53_GIC_PRI_W-1):0]     priority_mask_i,
  input   wire                              quiesce_recv_i,
  input   wire                              send_deactivate_i,
  input   wire                              send_deactivate_lr_i,
  input   wire                              send_generate_sgi_i,
  input   wire                              send_upstream_wr_enables_i,
  input   wire                              send_upstream_wr_enables_v_i,
  input   wire                              send_upstream_wr_priority_i,
  input   wire  [(`CA53_GIC_SGT_W-1):0]     sgt_i,
  input   wire                              upstream_wr_ack_recv_i,
  input   wire                              v_grp0_enable_i,
  input   wire                              v_grp1_enable_i,
  input   wire                              vclear_recv_i,
  // Outputs
  output  wire                              activate_ack_outstanding_o,
  output  wire                              activate_ack_v_outstanding_o,
  output  wire                              activate_release_sent_o,
  output  wire                              activate_release_v_sent_o,
  output  wire                              clear_ack_pending_o,
  output  wire                              clear_ack_v_pending_o,
  output  wire                              deactivate_pending_o,
  output  wire                              downstream_wr_ack_pending_o,
  output  wire                              generate_sgi_pending_o,
  output  reg                               gic_stall_dsb_o,
  output  wire                              gic_tvalid_o,
  output  reg   [(`CA53_TDATA_W-1):0]       gic_tdata_o,
  output  reg                               gic_tlast_o,
  output  wire                              quiesce_ack_pending_o,
  output  wire                              upstream_wr_pending_o
);


  // ------------------------------------------------------
  // Constant declarations
  // ------------------------------------------------------

  // Packet priorities (lower values sent first)
  localparam  PACKET_COUNT          = 9;
  localparam  P_ACTIVATE_RELEASE    = 2;
  localparam  P_ACTIVATE_RELEASE_V  = 4;
  localparam  P_CLEAR_ACK           = 3;  // Lower priority than P_ACTIVATE_RELEASE
  localparam  P_CLEAR_ACK_V         = 5;  // Lower priority than P_ACTIVATE_RELEASE_V
  localparam  P_DEACTIVATE          = 6;  // Lower priority than P_ACTIVATE_RELEASE
  localparam  P_DOWNSTREAM_WR_ACK   = 7;  // Low priority as this should happen rarely with nothing pending
  localparam  P_GENERATE_SGI        = 1;  // High priority as this packet stalls CPU until sent
  localparam  P_UPSTREAM_WR         = 0;  // Highest priority to prevent Set-Release loop
  localparam  P_QUIESCE_ACK         = 8;  // Lowest priority to ensure all other packets have been sent

  // P_UPSTREAM_WR packet encodings
  localparam  UPSTR_WR_W            = 2;
  localparam  UPSTR_WR_ENABLES      = 2'b01;
  localparam  UPSTR_WR_ENABLES_V    = 2'b10;
  localparam  UPSTR_WR_PRIORITY     = 2'b11;

  // Packet lengths (one-hot encoding)
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] ACTIVATE_L          = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_ACTIVATE_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] CLEAR_ACK_L         = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_CLEAR_ACK_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] DEACTIVATE_L        = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_DEACTIVATE_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] DOWNSTREAM_WR_ACK_L = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_DOWNSTREAM_WR_ACK_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] GENERATE_SGI_L      = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_SGI_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] QUIESCE_ACK_L       = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_QUIESCE_ACK_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] RELEASE_L           = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_RELEASE_LEN-1);
  localparam  [(`CA53_GIC_ICC_MAX_LEN-1):0] UPSTREAM_WR_L       = {{(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}<<(`CA53_GIC_ICC_UPSTREAM_WR_LEN-1);


  // ------------------------------------------------------
  // Variable declarations
  // ------------------------------------------------------

  genvar i;
  genvar j;


  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg                                 activate_ack_outstanding;
  reg                                 activate_ack_v_outstanding;
  reg                                 clear_ack_pending;
  reg                                 clear_ack_v_pending;
  reg                                 deactivate_ack_outstanding;
  reg                                 deactivate_pending;
  reg                                 downstream_wr_ack_pending;
  reg                                 generate_sgi_ack_outstanding;
  reg                                 generate_sgi_pending;
  reg                                 gic_tvalid;
  reg                                 quiesce_ack_pending;
  reg   [(PACKET_COUNT-1):0]          sel_packet;
  reg   [(`CA53_GIC_ICC_MAX_LEN-1):0] transfer_count;
  reg                                 upstream_wr_ack_outstanding;
  reg   [(UPSTR_WR_W-1):0]            upstream_wr_pending_enc;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire                                activate_pending;
  wire                                activate_v_pending;
  wire  [2:0]                         deactivate_groups;
  wire  [(`CA53_GIC_ID_W-1):0]        deactivate_interrupt_id;
  wire                                nxt_activate_ack_outstanding;
  wire                                nxt_activate_ack_v_outstanding;
  wire                                nxt_clear_ack_pending;
  wire                                nxt_clear_ack_v_pending;
  wire                                nxt_deactivate_ack_outstanding;
  wire                                nxt_deactivate_pending;
  wire                                nxt_downstream_wr_ack_pending;
  wire                                nxt_generate_sgi_ack_outstanding;
  wire                                nxt_generate_sgi_pending;
  wire                                nxt_gic_stall_dsb;
  wire                                nxt_quiesce_ack_pending;
  wire  [(PACKET_COUNT-1):0]          nxt_sel_packet;
  wire  [(`CA53_GIC_ICC_MAX_LEN-1):0] nxt_transfer_count;
  wire                                nxt_upstream_wr_ack_outstanding;
  wire  [(UPSTR_WR_W-1):0]            nxt_upstream_wr_pending_enc;
  wire  [47:0]                        packet_data;
  wire  [47:0]                        packet_data_activate;
  wire  [47:0]                        packet_data_activate_v;
  wire  [47:0]                        packet_data_release;
  wire  [47:0]                        packet_data_release_v;
  wire  [47:0]                        packet_data_upstream_wr_enables;
  wire  [47:0]                        packet_data_upstream_wr_enables_v;
  wire  [47:0]                        packet_data_upstream_wr_priority;
  wire  [(`CA53_GIC_ICC_MAX_LEN-1):0] packet_len;
  wire  [(PACKET_COUNT-1):0]          packets_sent;
  wire  [47:0]                        packets_data [(PACKET_COUNT-1):0];
  wire  [(`CA53_GIC_ICC_MAX_LEN-1):0] packets_len [(PACKET_COUNT-1):0];
  wire                                sel_new_packet;
  wire  [(PACKET_COUNT-1):0]          send_packets;
  wire  [(PACKET_COUNT-1):0]          send_packets_masked;
  wire  [(UPSTR_WR_W-1):0]            send_upstream_wr_enc;
  wire                                sending_packet;
  wire                                store_transfer;
  wire                                transfer_count_en;
  wire  [(`CA53_TDATA_W-1):0]         transfer_data;
  wire                                transfer_last;
  wire                                upstream_wr_enables_pending;
  wire                                upstream_wr_enables_v_pending;
  wire                                upstream_wr_pending;
  wire                                upstream_wr_priority_pending;
  wire  [(PACKET_COUNT-1):0]          valid_packets_data [47:0];
  wire  [(PACKET_COUNT-1):0]          valid_packets_len [(`CA53_GIC_ICC_MAX_LEN-1):0];
  wire  [(`CA53_GIC_ICC_MAX_LEN-1):0] valid_transfer_data [(`CA53_TDATA_W-1):0];


  // ------------------------------------------------------
  // Pending Packets
  // ------------------------------------------------------

  assign send_upstream_wr_enc = ( UPSTR_WR_ENABLES    & {UPSTR_WR_W{send_upstream_wr_enables_i}} ) |
                                ( UPSTR_WR_ENABLES_V  & {UPSTR_WR_W{send_upstream_wr_enables_v_i}} ) |
                                ( UPSTR_WR_PRIORITY   & {UPSTR_WR_W{send_upstream_wr_priority_i}} );

  // Packets are pending to be sent
  assign nxt_clear_ack_pending          = ( clear_ack_pending & ~packets_sent[P_CLEAR_ACK] ) | clear_recv_i;

  assign nxt_clear_ack_v_pending        = ( clear_ack_v_pending & ~packets_sent[P_CLEAR_ACK_V] ) | vclear_recv_i;

  assign nxt_deactivate_pending         = ( deactivate_pending & ~packets_sent[P_DEACTIVATE] ) | send_deactivate_i | send_deactivate_lr_i;

  assign nxt_downstream_wr_ack_pending  = ( downstream_wr_ack_pending & ~packets_sent[P_DOWNSTREAM_WR_ACK] ) | downstream_wr_recv_i;

  assign nxt_generate_sgi_pending       = ( generate_sgi_pending & ~packets_sent[P_GENERATE_SGI] ) | send_generate_sgi_i;

  assign nxt_quiesce_ack_pending        = ( quiesce_ack_pending & ~packets_sent[P_QUIESCE_ACK] ) | quiesce_recv_i;

  assign nxt_upstream_wr_pending_enc    = ( upstream_wr_pending_enc & {UPSTR_WR_W{~packets_sent[P_UPSTREAM_WR]}} ) | send_upstream_wr_enc;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      clear_ack_pending         <= 1'b0;
      clear_ack_v_pending       <= 1'b0;
      deactivate_pending        <= 1'b0;
      downstream_wr_ack_pending <= 1'b0;
      generate_sgi_pending      <= 1'b0;
      quiesce_ack_pending       <= 1'b0;
      upstream_wr_pending_enc   <= {UPSTR_WR_W{1'b0}};
    end else begin
      clear_ack_pending         <= nxt_clear_ack_pending;
      clear_ack_v_pending       <= nxt_clear_ack_v_pending;
      deactivate_pending        <= nxt_deactivate_pending;
      downstream_wr_ack_pending <= nxt_downstream_wr_ack_pending;
      generate_sgi_pending      <= nxt_generate_sgi_pending;
      quiesce_ack_pending       <= nxt_quiesce_ack_pending;
      upstream_wr_pending_enc   <= nxt_upstream_wr_pending_enc;
    end

  // Decode pending packets
  assign activate_pending               = activate_release_pending_i & activate_not_release_i;
  assign activate_v_pending             = activate_release_v_pending_i & activate_not_release_v_i;
  assign upstream_wr_enables_pending    = upstream_wr_pending_enc == UPSTR_WR_ENABLES;
  assign upstream_wr_enables_v_pending  = upstream_wr_pending_enc == UPSTR_WR_ENABLES_V;
  assign upstream_wr_priority_pending   = upstream_wr_pending_enc == UPSTR_WR_PRIORITY;

  // upstream_wr_pending specifies if any upstream write packet is pending
  assign upstream_wr_pending            = upstream_wr_enables_pending |
                                          upstream_wr_enables_v_pending |
                                          upstream_wr_priority_pending;


  // ------------------------------------------------------
  // Distributor packet acknowledges are outstanding
  // ------------------------------------------------------

  assign nxt_activate_ack_outstanding     = ( activate_ack_outstanding & ~activate_ack_recv_i ) |
                                            ( packets_sent[P_ACTIVATE_RELEASE] &  activate_pending );

  assign nxt_activate_ack_v_outstanding   = ( activate_ack_v_outstanding & ~activate_ack_v_recv_i ) |
                                            ( packets_sent[P_ACTIVATE_RELEASE_V] &  activate_v_pending );

  assign nxt_deactivate_ack_outstanding   = ( deactivate_ack_outstanding & ~deactivate_ack_recv_i ) |
                                            packets_sent[P_DEACTIVATE];

  assign nxt_generate_sgi_ack_outstanding = ( generate_sgi_ack_outstanding & ~generate_sgi_ack_recv_i ) |
                                            packets_sent[P_GENERATE_SGI];

  assign nxt_upstream_wr_ack_outstanding  = ( upstream_wr_ack_outstanding & ~upstream_wr_ack_recv_i ) |
                                            packets_sent[P_UPSTREAM_WR];

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      activate_ack_outstanding      <= 1'b0;
      activate_ack_v_outstanding    <= 1'b0;
      deactivate_ack_outstanding    <= 1'b0;
      generate_sgi_ack_outstanding  <= 1'b0;
      upstream_wr_ack_outstanding   <= 1'b0;
    end else begin
      activate_ack_outstanding      <= nxt_activate_ack_outstanding;
      activate_ack_v_outstanding    <= nxt_activate_ack_v_outstanding;
      deactivate_ack_outstanding    <= nxt_deactivate_ack_outstanding;
      generate_sgi_ack_outstanding  <= nxt_generate_sgi_ack_outstanding;
      upstream_wr_ack_outstanding   <= nxt_upstream_wr_ack_outstanding;
    end


  // ------------------------------------------------------
  // Packets can be sent
  // ------------------------------------------------------

  assign send_packets[P_ACTIVATE_RELEASE]   =  activate_release_pending_i;

  assign send_packets[P_ACTIVATE_RELEASE_V] =  activate_release_v_pending_i;

  assign send_packets[P_CLEAR_ACK]          =  clear_ack_pending;

  assign send_packets[P_CLEAR_ACK_V]        =  clear_ack_v_pending;

  assign send_packets[P_DEACTIVATE]         =  deactivate_pending & ~deactivate_ack_outstanding;

  assign send_packets[P_DOWNSTREAM_WR_ACK]  =  downstream_wr_ack_pending;

  assign send_packets[P_GENERATE_SGI]       =  generate_sgi_pending & ~generate_sgi_ack_outstanding;

  assign send_packets[P_QUIESCE_ACK]        =  quiesce_ack_pending &
                                              ~activate_pending &
                                              ~activate_ack_outstanding &
                                              ~activate_v_pending &
                                              ~activate_ack_v_outstanding &
                                              ~deactivate_pending &
                                              ~deactivate_ack_outstanding &
                                              ~generate_sgi_pending &
                                              ~generate_sgi_ack_outstanding &
                                              ~upstream_wr_pending &
                                              ~upstream_wr_ack_outstanding;

  assign send_packets[P_UPSTREAM_WR]        =  upstream_wr_pending & ~upstream_wr_ack_outstanding;


  // ------------------------------------------------------
  // DSBs stall logic
  // ------------------------------------------------------

  // DSBs should be stalled while the GIC CPU Interface is sending packets
  // generated by CP requests or waiting for acknowledge packets for those
  // requests.  This excludes Priority Change packets which have no visible
  // Distributor state.

  assign nxt_gic_stall_dsb  = activate_pending      | activate_ack_outstanding      |
                              activate_v_pending    | activate_ack_v_outstanding    |
                              deactivate_pending    | deactivate_ack_outstanding    |
                              generate_sgi_pending  | generate_sgi_ack_outstanding  |
                              upstream_wr_pending   | upstream_wr_ack_outstanding;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_stall_dsb_o <= 1'b0;
    end else begin
      gic_stall_dsb_o <= nxt_gic_stall_dsb;
    end


  // ------------------------------------------------------
  // Packet Data
  // ------------------------------------------------------

  // Packet payload physical and virtual data multiplexing
  assign deactivate_groups        = cp_virtual_i ?  { 1'b0,                           // [2]      : Group 1s - RES0
                                                      deactivate_lr_grp1_ns_i,        // [1]      : Group 1(ns,ds)
                                                      deactivate_lr_grp0_i }:         // [0]      : Group 0
                                                    { deactivate_grp1_s_i,            // [2]      : Group 1s
                                                      deactivate_grp1_ns_i,           // [1]      : Group 1(ns,ds)
                                                      deactivate_grp0_i };            // [0]      : Group 0;

  // NOTE: LPI IDs do not require a Deactivate which permits the Deactivate
  // packet's interrupt ID to be truncated.
  assign deactivate_interrupt_id  = cp_virtual_i ? { {6{1'b0}} , deactivate_lr_pid_i }: 
                                                   { {3{1'b0}} , cp_gov_wdata_rs_i};

  // 48-bit redundant packet format for multiplexing
  assign packet_data_activate               = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                ipr_id_i,                             // [31:16]  : Interrupt ID
                                                {8{1'b0}},                            // [15:8]   : RES0
                                                {2{1'b0}},                            // [7:6]    : ID Length - 16 bits
                                                1'b0,                                 // [5]      : RES0
                                                1'b0,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_ACTIVATE_ID };          // [3:0]    : ID

  assign packet_data_activate_v             = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                ipr_id_v_i,                           // [31:16]  : Interrupt ID
                                                {8{1'b0}},                            // [15:8]   : RES0
                                                {2{1'b0}},                            // [7:6]    : ID Length - 16 bits
                                                1'b0,                                 // [5]      : RES0
                                                1'b1,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_ACTIVATE_ID };          // [3:0]    : ID

  assign packets_data[P_CLEAR_ACK]          = { {32{1'b0}},                           // [47:16]  : RES0 - Beyond packet length
                                                {11{1'b0}},                           // [15:5]   : RES0
                                                1'b0,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_CLEAR_ACK_ID };         // [3:0]    : ID

  assign packets_data[P_CLEAR_ACK_V]        = { {32{1'b0}},                           // [47:16]  : RES0 - Beyond packet length
                                                {11{1'b0}},                           // [15:5]   : RES0
                                                1'b1,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_CLEAR_ACK_ID };         // [3:0]    : ID

  assign packets_data[P_DEACTIVATE]         = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                deactivate_interrupt_id,              // [31:16]  : Interrupt ID
                                                {5{1'b0}},                            // [15:11]  : RES0
                                                deactivate_groups,                    // [10:8]   : Groups
                                                {2{1'b0}},                            // [7:6]    : ID Length - 16 bits
                                                {2{1'b0}},                            // [5:4]    : RES0
                                                `CA53_GIC_ICC_DEACTIVATE_ID };        // [3:0]    : ID

  assign packets_data[P_DOWNSTREAM_WR_ACK]  = { {32{1'b0}},                           // [47:16]  : RES0 - Beyond packet length
                                                {12{1'b0}},                           // [15:4]   : RES0
                                                `CA53_GIC_ICC_DOWNSTREAM_WR_ACK_ID }; // [3:0]    : ID

  assign packets_data[P_GENERATE_SGI]       = { cp_gov_wdata_i[39:32],                // [47:40]  : A2
                                                cp_gov_wdata_i[23:16],                // [39:32]  : A1
                                                cp_gov_wdata_i[15:0],                 // [31:16]  : Target list
                                                cp_gov_wdata_i[27:24],                // [15:12]  : SGInum
                                                {3{1'b0}},                            // [11:9]   : RES0
                                                1'b0,                                 // [8]      : A3V - RES0 - not supported
                                                cp_gov_wdata_i[40],                   // [7]      : IRM
                                                ns_el_i,                              // [6]      : NS
                                                sgt_i,                                // [5:0]    : SGT
                                                `CA53_GIC_ICC_SGI_ID };               // [3:0]    : ID

  assign packets_data[P_QUIESCE_ACK]        = { {32{1'b0}},                           // [47:16]  : RES0 - Beyond packet length
                                                {12{1'b0}},                           // [15:4]   : RES0
                                                `CA53_GIC_ICC_QUIESCE_ACK_ID };       // [3:0]    : ID

  assign packet_data_release                = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                ipr_id_i,                             // [31:16]  : Interrupt ID
                                                {11{1'b0}},                           // [15:5]   : RES0
                                                1'b0,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_RELEASE_ID };           // [3:0]    : ID

  assign packet_data_release_v              = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                ipr_id_v_i,                           // [31:16]  : Interrupt ID
                                                {11{1'b0}},                           // [15:5]   : RES0
                                                1'b1,                                 // [4]      : V-bit
                                                `CA53_GIC_ICC_RELEASE_ID };           // [3:0]    : ID

  assign packet_data_upstream_wr_enables    = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                {8{1'b0}},                            // [31:24]  : Data1 - unused
                                                {4{1'b0}},                            // [23:20]  : Data0[7:4] - RES0
                                                1'b0,                                 // [19]     : Data0[3] - Enable SEI - RES0
                                                grp1_s_enable_i,                      // [18]     : Data0[2] - Enable Group 1s
                                                grp1_ns_enable_i,                     // [17]     : Data0[1] - Enable Group 1(ns,ds)
                                                grp0_enable_i,                        // [16]     : Data0[0] - Enable Group 0
                                                4'd1,                                 // [15:12]  : Length
                                                8'd0,                                 // [11:4]   : Identifier
                                                `CA53_GIC_ICC_UPSTREAM_WR_ID };       // [3:0]    : ID

  assign packet_data_upstream_wr_enables_v  = { {16{1'b0}},                           // [47:32]  : RES0 - Beyond packet length
                                                {8{1'b0}},                            // [31:24]  : Data1 - unused
                                                {6{1'b0}},                            // [23:18]  : Data0[7:2] - RES0
                                                v_grp1_enable_i,                      // [17]     : Data0[1] - Enable Group 1
                                                v_grp0_enable_i,                      // [16]     : Data0[0] - Enable Group 0
                                                4'd1,                                 // [15:12]  : Length
                                                8'd1,                                 // [11:4]   : Identifier
                                                `CA53_GIC_ICC_UPSTREAM_WR_ID };       // [3:0]    : ID

  assign packet_data_upstream_wr_priority   = { {16{1'b0}},                           // [47:16]  : RES0 - Beyond packet length
                                                {8{1'b0}},                            // [31:24]  : Data1 - unused
                                                priority_mask_i,                      // [23:19]  : Data0[7:3] - Priority
                                                {3{1'b0}},                            // [18:16]  : Data0[2:0] - Priority (unused)
                                                4'd1,                                 // [15:12]  : Length
                                                8'd2,                                 // [11:4]   : Identifier                                                
                                                `CA53_GIC_ICC_UPSTREAM_WR_ID };       // [3:0]    : ID


  // Select packet data for encoded pending packets
  assign packets_data[P_ACTIVATE_RELEASE]   = activate_not_release_i ? packet_data_activate : packet_data_release;

  assign packets_data[P_ACTIVATE_RELEASE_V] = activate_not_release_v_i ? packet_data_activate_v : packet_data_release_v;

  assign packets_data[P_UPSTREAM_WR]        = ( {48{upstream_wr_enables_pending}}   & packet_data_upstream_wr_enables ) |
                                              ( {48{upstream_wr_enables_v_pending}} & packet_data_upstream_wr_enables_v ) |
                                              ( {48{upstream_wr_priority_pending}}  & packet_data_upstream_wr_priority );


  // ------------------------------------------------------
  // Packet length
  // ------------------------------------------------------

  assign packets_len[P_ACTIVATE_RELEASE]    = activate_not_release_i ? ACTIVATE_L : RELEASE_L;
  assign packets_len[P_ACTIVATE_RELEASE_V]  = activate_not_release_i ? ACTIVATE_L : RELEASE_L;
  assign packets_len[P_CLEAR_ACK]           = CLEAR_ACK_L;
  assign packets_len[P_CLEAR_ACK_V]         = CLEAR_ACK_L;
  assign packets_len[P_DEACTIVATE]          = DEACTIVATE_L;
  assign packets_len[P_DOWNSTREAM_WR_ACK]   = DOWNSTREAM_WR_ACK_L;
  assign packets_len[P_GENERATE_SGI]        = GENERATE_SGI_L;
  assign packets_len[P_QUIESCE_ACK]         = QUIESCE_ACK_L;
  assign packets_len[P_UPSTREAM_WR]         = UPSTREAM_WR_L;


  // ------------------------------------------------------
  // Packet Multiplexing
  // ------------------------------------------------------

  // Select packet data
  generate
    for ( i = 0; i < ( `CA53_GIC_ICC_MAX_LEN * `CA53_TDATA_W ); i = i + 1 ) begin : packet_data_bit_n
      for ( j = 0; j < PACKET_COUNT; j = j + 1 ) begin : packet_data_n
        assign valid_packets_data[i][j] = sel_packet[j] & packets_data[j][i];
      end
      assign packet_data[i] = |valid_packets_data[i];
    end
  endgenerate

  // Select transfer from packet
  generate
    for ( i = 0; i < `CA53_TDATA_W; i = i + 1 ) begin : transfer_data_bit_n
      for ( j = 0; j < `CA53_GIC_ICC_MAX_LEN; j = j + 1 ) begin : transfer_n
        assign valid_transfer_data[i][j] = transfer_count[j] & packet_data[((j*`CA53_TDATA_W)+i)];
      end
      assign transfer_data[i] = |valid_transfer_data[i];
    end
  endgenerate

  // Select packet length
  generate
    for ( i = 0; i < `CA53_GIC_ICC_MAX_LEN; i = i + 1 ) begin : packet_len_bit_n
      for ( j = 0; j < PACKET_COUNT; j = j + 1 ) begin : packet_len_n
        assign valid_packets_len[i][j] = sel_packet[j] & packets_len[j][i];
      end
      assign packet_len[i] = |valid_packets_len[i];
    end
  endgenerate

  assign transfer_last = packet_len == transfer_count;


  // ------------------------------------------------------
  // Packet and transfer select logic
  // ------------------------------------------------------

  assign sel_new_packet       = ( ( |send_packets ) & ( ~sending_packet ) )|  // Idle to new packet
                                ( transfer_last     & store_transfer );       // Back-to-back packets or end of packet

  assign send_packets_masked  = send_packets & ( ~sel_packet );

  generate
    for ( i = 0; i < PACKET_COUNT; i = i + 1 ) begin : highest_priority_packet
      if ( i == 0 ) begin : highest_priority_packet_lsb
        assign nxt_sel_packet[0] = send_packets_masked[0];
      end else begin : highest_priority_packet_n
        assign nxt_sel_packet[i] = send_packets_masked[i] & ( ~|send_packets_masked[0+:i] );
      end
    end
  endgenerate

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      sel_packet <= {PACKET_COUNT{1'b0}};
    end else if ( sel_new_packet ) begin
      sel_packet <= nxt_sel_packet;
    end

  assign transfer_count_en  = sending_packet & ( arb_tready_i | ~gic_tvalid );

  assign nxt_transfer_count = transfer_last ? { {(`CA53_GIC_ICC_MAX_LEN-1){1'b0}},1'b1}:
                                              { transfer_count[(`CA53_GIC_ICC_MAX_LEN-2):0],1'b0};

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      transfer_count <= { {(`CA53_GIC_ICC_MAX_LEN-1){1'b0}} , 1'b1 };
    end else if ( transfer_count_en ) begin
      transfer_count <= nxt_transfer_count;
    end

  // If any packet is selected then the the current packet is being sent and
  // the selected Data and Last values are considered valid.
  assign sending_packet = |sel_packet;

  // A packet is buffered and no longer pending in the next cycle if the
  // current transfer being buffered is the last transfer for that packet.
  assign packets_sent = {PACKET_COUNT{store_transfer & transfer_last}} & sel_packet;


  // ------------------------------------------------------
  // Transfer Register Slice
  // ------------------------------------------------------

  // Load a new transfer into an empty buffer or send a buffered transfer when
  // Arbiter is ready.
  assign store_transfer = gic_tvalid ? arb_tready_i : sending_packet;

  always @ ( posedge clk )
    if ( store_transfer ) begin
      gic_tdata_o <= transfer_data;
      gic_tlast_o <= transfer_last;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_tvalid <= 1'b0;
    end else if ( store_transfer ) begin
      gic_tvalid <= sending_packet;
    end


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign activate_ack_outstanding_o   = activate_ack_outstanding;
  assign activate_ack_v_outstanding_o = activate_ack_v_outstanding;
  assign activate_release_sent_o      = packets_sent[P_ACTIVATE_RELEASE];
  assign activate_release_v_sent_o    = packets_sent[P_ACTIVATE_RELEASE_V];
  assign clear_ack_pending_o          = clear_ack_pending;
  assign clear_ack_v_pending_o        = clear_ack_v_pending;
  assign deactivate_pending_o         = deactivate_pending;
  assign downstream_wr_ack_pending_o  = downstream_wr_ack_pending;
  assign generate_sgi_pending_o       = generate_sgi_pending;
  assign gic_tvalid_o                 = gic_tvalid;
  assign quiesce_ack_pending_o        = quiesce_ack_pending;
  assign upstream_wr_pending_o        = upstream_wr_pending;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ------------------------------------------------------
  // Packet request coalescence is not supported
  // ------------------------------------------------------

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: clear_ack")
  u_ovl_coalesce_clear_ack (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (clear_recv_i),
                            .consequent_expr (~clear_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: clear_ack_v")
  u_ovl_coalesce_clear_ack_v (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (vclear_recv_i),
                              .consequent_expr (~clear_ack_v_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: deactivate")
  u_ovl_coalesce_deactivate (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (send_deactivate_i | send_deactivate_lr_i),
                             .consequent_expr (~deactivate_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: downstream_wr_ack")
  u_ovl_coalesce_downstream_wr_ack (.clk             (clk),
                                    .reset_n         (reset_n),
                                    .antecedent_expr (downstream_wr_recv_i),
                                    .consequent_expr (~downstream_wr_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: generate_sgi")
  u_ovl_coalesce_generate_sgi (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (send_generate_sgi_i),
                               .consequent_expr (~generate_sgi_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: quiesce_ack")
  u_ovl_coalesce_quiesce_ack (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (quiesce_recv_i),
                              .consequent_expr (~quiesce_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet generation request coalescence: upstream_wr")
  u_ovl_coalesce_upstream_wr (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (send_upstream_wr_enables_i | send_upstream_wr_enables_v_i | send_upstream_wr_priority_i),
                              .consequent_expr (~upstream_wr_pending));



  // ------------------------------------------------------
  // Packet must be pending when sent
  // ------------------------------------------------------

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_activate_release_pending_i (.clk             (clk),
                                                .reset_n         (reset_n),
                                                .antecedent_expr (packets_sent[P_ACTIVATE_RELEASE]),
                                                .consequent_expr (activate_release_pending_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_activate_release_v_pending_i (.clk             (clk),
                                                  .reset_n         (reset_n),
                                                  .antecedent_expr (packets_sent[P_ACTIVATE_RELEASE_V]),
                                                  .consequent_expr (activate_release_v_pending_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_clear_ack_pending (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr (packets_sent[P_CLEAR_ACK]),
                                       .consequent_expr (clear_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_clear_ack_v_pending (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (packets_sent[P_CLEAR_ACK_V]),
                                         .consequent_expr (clear_ack_v_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_deactivate (.clk             (clk),
                                .reset_n         (reset_n),
                                .antecedent_expr (packets_sent[P_DEACTIVATE]),
                                .consequent_expr (deactivate_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_downstream_wr_ack_pending (.clk             (clk),
                                               .reset_n         (reset_n),
                                               .antecedent_expr (packets_sent[P_DOWNSTREAM_WR_ACK]),
                                               .consequent_expr (downstream_wr_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_generate_sgi_pending (.clk             (clk),
                                          .reset_n         (reset_n),
                                          .antecedent_expr (packets_sent[P_GENERATE_SGI]),
                                          .consequent_expr (generate_sgi_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_quiesce_ack_pending (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (packets_sent[P_QUIESCE_ACK]),
                                         .consequent_expr (quiesce_ack_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet must be pending when sent")
  u_ovl_implication_upstream_wr_pending (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (packets_sent[P_UPSTREAM_WR]),
                                         .consequent_expr (upstream_wr_pending));


  // ------------------------------------------------------
  // Packet selection
  // ------------------------------------------------------

  assert_zero_one_hot #(`OVL_FATAL, PACKET_COUNT, `OVL_ASSERT, "Multiple packets are selected")
  u_ovl_multiple_sel_packet (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (sel_packet));


  // ------------------------------------------------------
  // Inputs are stable while being used for packet generation
  // ------------------------------------------------------

  reg                             ovl_last_activate_pending;
  reg                             ovl_last_clear_ack_pending;
  reg                             ovl_last_clear_ack_v_pending;
  reg [40:0]                      ovl_last_cp_gov_wdata;
  reg [12:0]                      ovl_last_cp_gov_wdata_rs;
  reg                             ovl_last_cp_virtual;
  reg                             ovl_last_deactivate_pending;
  reg                             ovl_last_downstream_wr_ack_pending;
  reg                             ovl_last_deactivate_grp0;
  reg                             ovl_last_deactivate_grp1_ns;
  reg                             ovl_last_deactivate_grp1_s;
  reg                             ovl_last_deactivate_lr_grp0;
  reg                             ovl_last_deactivate_lr_grp1_ns;
  reg [(`CA53_GIC_LR_PID_W-1):0]  ovl_last_deactivate_lr_pid;
  reg                             ovl_last_generate_sgi_pending;
  reg                             ovl_last_grp0_enable;
  reg                             ovl_last_grp1_ns_enable;
  reg                             ovl_last_grp1_s_enable;
  reg [(`CA53_GIC_ID_W-1):0]      ovl_last_pcpu_ipr_id;
  reg [(`CA53_GIC_PRI_W-1):0]     ovl_last_priority_mask;
  reg                             ovl_last_quiesce_ack_pending;
  reg                             ovl_last_upstream_wr_enables_pending;
  reg                             ovl_last_upstream_wr_enables_v_pending;
  reg                             ovl_last_upstream_wr_priority_pending;
  reg                             ovl_last_v_grp0_enable;
  reg                             ovl_last_v_grp1_enable;

  // Requests
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_activate_pending               <= 1'b0;
      ovl_last_clear_ack_pending              <= 1'b0;
      ovl_last_clear_ack_v_pending            <= 1'b0;
      ovl_last_deactivate_pending             <= 1'b0;
      ovl_last_downstream_wr_ack_pending      <= 1'b0;
      ovl_last_generate_sgi_pending           <= 1'b0;
      ovl_last_quiesce_ack_pending            <= 1'b0;
      ovl_last_upstream_wr_enables_pending    <= 1'b0;
      ovl_last_upstream_wr_enables_v_pending  <= 1'b0;
      ovl_last_upstream_wr_priority_pending   <= 1'b0;
    end else begin
      ovl_last_activate_pending               <= activate_pending;
      ovl_last_clear_ack_pending              <= clear_ack_pending;
      ovl_last_clear_ack_v_pending            <= clear_ack_v_pending;
      ovl_last_deactivate_pending             <= deactivate_pending;
      ovl_last_downstream_wr_ack_pending      <= downstream_wr_ack_pending;
      ovl_last_generate_sgi_pending           <= generate_sgi_pending;
      ovl_last_quiesce_ack_pending            <= quiesce_ack_pending;
      ovl_last_upstream_wr_enables_pending    <= upstream_wr_enables_pending;
      ovl_last_upstream_wr_enables_v_pending  <= upstream_wr_enables_v_pending;
      ovl_last_upstream_wr_priority_pending   <= upstream_wr_priority_pending;
    end

  // Data value
  always @ ( posedge clk )
    begin
      ovl_last_cp_gov_wdata           <= cp_gov_wdata_i;
      ovl_last_cp_gov_wdata_rs        <= cp_gov_wdata_rs_i;
      ovl_last_cp_virtual             <= cp_virtual_i;
      ovl_last_deactivate_grp0        <= deactivate_grp0_i;
      ovl_last_deactivate_grp1_ns     <= deactivate_grp1_ns_i;
      ovl_last_deactivate_grp1_s      <= deactivate_grp1_s_i;
      ovl_last_deactivate_lr_grp0     <= deactivate_lr_grp0_i;
      ovl_last_deactivate_lr_grp1_ns  <= deactivate_lr_grp1_ns_i;
      ovl_last_deactivate_lr_pid      <= deactivate_lr_pid_i;
      ovl_last_grp0_enable            <= grp0_enable_i;
      ovl_last_grp1_ns_enable         <= grp1_ns_enable_i;
      ovl_last_grp1_s_enable          <= grp1_s_enable_i;
      ovl_last_priority_mask          <= priority_mask_i;
      ovl_last_v_grp0_enable          <= v_grp0_enable_i;
      ovl_last_v_grp1_enable          <= v_grp1_enable_i;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: cp_gov_wdata_i")
  u_ovl_implication_stable_cp_gov_wdata_i (.clk             (clk),
                                           .reset_n         (reset_n),
                                           .antecedent_expr (ovl_last_generate_sgi_pending),
                                           .consequent_expr (cp_gov_wdata_i == ovl_last_cp_gov_wdata));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: cp_gov_wdata_rs_i")
  u_ovl_implication_stable_cp_gov_wdata_rs_i (.clk             (clk),
                                              .reset_n         (reset_n),
                                              .antecedent_expr (ovl_last_deactivate_pending & ~cp_virtual_i),
                                              .consequent_expr (cp_gov_wdata_rs_i == ovl_last_cp_gov_wdata_rs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: cp_virtual_i")
  u_ovl_implication_stable_cp_virtual_i (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (ovl_last_deactivate_pending),
                                         .consequent_expr (cp_virtual_i == ovl_last_cp_virtual));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_grp0_i")
  u_ovl_implication_stable_deactivate_grp0_i (.clk             (clk),
                                              .reset_n         (reset_n),
                                              .antecedent_expr (ovl_last_deactivate_pending & ~cp_virtual_i),
                                              .consequent_expr (deactivate_grp0_i == ovl_last_deactivate_grp0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_grp1_ns_i")
  u_ovl_implication_stable_deactivate_grp1_ns_i (.clk             (clk),
                                                 .reset_n         (reset_n),
                                                 .antecedent_expr (ovl_last_deactivate_pending & ~cp_virtual_i),
                                                 .consequent_expr (deactivate_grp1_ns_i == ovl_last_deactivate_grp1_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_grp1_s_i")
  u_ovl_implication_stable_deactivate_grp1_s_i (.clk              (clk),
                                                .reset_n          (reset_n),
                                                .antecedent_expr  (ovl_last_deactivate_pending & ~cp_virtual_i),
                                                .consequent_expr  (deactivate_grp1_s_i == ovl_last_deactivate_grp1_s));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_lr_grp0_i")
  u_ovl_implication_stable_deactivate_lr_grp0_i (.clk             (clk),
                                                 .reset_n         (reset_n),
                                                 .antecedent_expr (ovl_last_deactivate_pending & cp_virtual_i),
                                                 .consequent_expr (deactivate_lr_grp0_i == ovl_last_deactivate_lr_grp0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_lr_grp1_ns_i")
  u_ovl_implication_stable_deactivate_lr_grp1_ns_i (.clk             (clk),
                                                    .reset_n         (reset_n),
                                                    .antecedent_expr (ovl_last_deactivate_pending & cp_virtual_i),
                                                    .consequent_expr (deactivate_lr_grp1_ns_i == ovl_last_deactivate_lr_grp1_ns));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: deactivate_lr_pid_i")
  u_ovl_implication_stable_deactivate_lr_pid_i (.clk             (clk),
                                                .reset_n         (reset_n),
                                                .antecedent_expr (ovl_last_deactivate_pending & cp_virtual_i),
                                                .consequent_expr (deactivate_lr_pid_i == ovl_last_deactivate_lr_pid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: grp0_enable_i")
  u_ovl_implication_stable_grp0_enable_i (.clk             (clk),
                                          .reset_n         (reset_n),
                                          .antecedent_expr (ovl_last_upstream_wr_enables_pending),
                                          .consequent_expr (grp0_enable_i == ovl_last_grp0_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: grp1_ns_enable_i")
  u_ovl_implication_stable_grp1_ns_enable_i (.clk             (clk),
                                             .reset_n         (reset_n),
                                             .antecedent_expr (ovl_last_upstream_wr_enables_pending),
                                             .consequent_expr (grp1_ns_enable_i == ovl_last_grp1_ns_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: grp1_s_enable_i")
  u_ovl_implication_stable_grp1_s_enable_i (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (ovl_last_upstream_wr_enables_pending),
                                            .consequent_expr (grp1_s_enable_i == ovl_last_grp1_s_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: priority_mask_i")
  u_ovl_implication_stable_priority_mask_i (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (ovl_last_upstream_wr_priority_pending),
                                            .consequent_expr (priority_mask_i == ovl_last_priority_mask));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: v_grp0_enable_i")
  u_ovl_implication_stable_v_grp0_enable_i (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (ovl_last_upstream_wr_enables_v_pending),
                                            .consequent_expr (v_grp0_enable_i == ovl_last_v_grp0_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unstable packet data: v_grp1_enable_i")
  u_ovl_implication_stable_v_grp1_enable_i (.clk             (clk),
                                            .reset_n         (reset_n),
                                            .antecedent_expr (ovl_last_upstream_wr_enables_v_pending),
                                            .consequent_expr (v_grp1_enable_i == ovl_last_v_grp1_enable));


  // ------------------------------------------------------
  // Packet hazards
  // ------------------------------------------------------

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet hazard: Activate must be observed before Deactivate")
  u_ovl_implication_hazard_activate_deactivate (.clk             (clk),
                                                .reset_n         (reset_n),
                                                .antecedent_expr (ovl_last_activate_pending & ovl_last_deactivate_pending),
                                                .consequent_expr (deactivate_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet hazard: Activate packets must always be able to be sent")
  u_ovl_implication_hazard_activate_activate (.clk             (clk),
                                              .reset_n         (reset_n),
                                              .antecedent_expr (activate_ack_outstanding),
                                              .consequent_expr (~activate_pending));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Packet hazard: Activate(v) packets must always be able to be sent")
  u_ovl_implication_hazard_activate_v_activate_v (.clk             (clk),
                                                  .reset_n         (reset_n),
                                                  .antecedent_expr (activate_ack_v_outstanding),
                                                  .consequent_expr (~activate_v_pending));


  // ------------------------------------------------------
  // Register enable X-check
  // ------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sel_new_packet")
  u_ovl_x_sel_new_packet (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (sel_new_packet));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: store_transfer")
  u_ovl_x_store_transfer (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (store_transfer));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: transfer_count_en")
  u_ovl_x_transfer_count_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (transfer_count_en));

  // OVL_ASSERT_END

`endif


endmodule // ca53gic_cpu_cpacket


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"
`undef CA53_UNDEFINE

