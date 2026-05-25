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
// Abstract : CortexA53 GIC CPU Interface inbound packet decoding logic
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"


module ca53gic_cpu_dpacket (
  // Inputs
  input   wire                            clk,
  input   wire                            reset_n,
  input   wire  [((`CA53_TDATA_W*2)-1):0] arb_data_i,
  input   wire                            arb_req_i,
  input   wire                            ipr_empty_i,
  input   wire                            ipr_empty_v_i,
  // Outputs
  output  wire                            activate_ack_recv_o,
  output  wire                            activate_ack_v_recv_o,
  output  wire  [(`CA53_GIC_ID_W-1):0]    arb_data_rs_interrupt_o,
  output  wire                            arb_data_rs_grp_o,
  output  wire                            arb_data_rs_grp_mod_o,
  output  wire  [(`CA53_GIC_PRI_W-1):0]   arb_data_rs_priority_o,
  output  wire                            clear_recv_o,
  output  wire                            deactivate_ack_recv_o,
  output  wire                            downstream_wr_recv_o,
  output  wire                            dpkt_active_o,
  output  wire                            generate_sgi_ack_recv_o,
  output  wire                            gic_arb_ack_o,
  output  wire                            gicd_ctlr_ds_o,
  output  wire                            quiesce_recv_o,
  output  wire                            set_recv_o,
  output  wire                            upstream_wr_ack_recv_o,
  output  wire                            vclear_recv_o,
  output  wire                            vset_recv_o
);

  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg   [20:0]                  arb_data_31_11_rs;
  reg   [5:0]                   arb_data_5_0_rs;
  reg                           downstream_wr_id_valid;
  reg                           gicd_ctlr_ds;
  reg                           last_packet_valid;
  reg                           packet_valid;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire                          activate_ack;
  wire                          activate_ack_recv;
  wire                          activate_ack_v_recv;
  wire  [(`CA53_GIC_ID_W-1):0]  arb_data_rs_interrupt;
  wire                          arb_data_rs_grp;
  wire                          arb_data_rs_grp_mod;
  wire  [(`CA53_GIC_PRI_W-1):0] arb_data_rs_priority;
  wire                          arb_data_rs_v;
  wire                          clear_recv;
  wire                          deactivate_ack_recv;
  wire                          downstream_wr_recv;
  wire                          generate_sgi_ack_recv;
  wire                          nxt_downstream_wr_id_valid;
  wire                          nxt_gicd_ctlr_ds;
  wire                          nxt_packet_valid;
  wire                          packet_en;
  wire                          packet_stalled;
  wire                          quiesce_recv;
  wire                          set_recv;
  wire                          upstream_wr_ack_recv;
  wire  [3:0]                   valid_packet_id;
  wire                          vclear_recv;
  wire                          vset_recv;


  // ------------------------------------------------------
  // Packet Buffer
  // ------------------------------------------------------

  // The packet in the packet buffer is valid.  A packet will become valid when
  // a new packet arrives and there is no current valid packet.  A packet will
  // remain valid only for a single cycle unless it is being stalled.  Stalling
  // a packet can only occur when there is a valid packet
  // (i.e. packet_stalled -> packet_valid).
  assign nxt_packet_valid = packet_valid ? packet_stalled : arb_req_i;

  // Only a single Downstream Write identifier - 0x0 - has been defined.  The
  // identifer is an 8-bit field, where five bits are only used for this packet,
  // for the identifier.  The identifier comparison is hence moved before the
  // flop to remove the redundant registers.
  assign nxt_downstream_wr_id_valid = arb_data_i[11:4] == {8{1'b0}};

  // A shadow copy of the Distributor's GICD_CTLR.DS (Disable Security) bit is
  // kept in each GIC CPU Interface.  This bit once asserted can not be
  // deasserted until reset.  It is set by a Downstream Write packet.
  assign nxt_gicd_ctlr_ds = ( downstream_wr_recv & downstream_wr_id_valid & arb_data_31_11_rs[(16-11)] ) | gicd_ctlr_ds;

  // A new packet is registed when there is a new request and the current
  // packet is not stalling.  This signal may be asserted for a cycle before
  // the clock is started.
  assign packet_en = arb_req_i & ~packet_valid;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      packet_valid      <= 1'b0;
      last_packet_valid <= 1'b0;
      gicd_ctlr_ds      <= 1'b0;
    end else begin
      packet_valid      <= nxt_packet_valid;
      last_packet_valid <= packet_valid;
      gicd_ctlr_ds      <= nxt_gicd_ctlr_ds;
    end

  always @ ( posedge clk )
    if ( packet_en ) begin
      arb_data_31_11_rs       <= arb_data_i[31:11];
      arb_data_5_0_rs         <= arb_data_i[5:0];
      downstream_wr_id_valid  <= nxt_downstream_wr_id_valid;
    end

  // The new packet has been received and is being processed.
  assign gic_arb_ack_o          = packet_valid & ~last_packet_valid;

  // The incoming packet is still being processed.  This signal
  // only needs to be driven until it causes another outbound packet to
  // becoming pending or potentially released.
  assign dpkt_active_o          = packet_valid & last_packet_valid;

  // Packet fields for Clear, Set, VClear, and VSet packets
  assign arb_data_rs_grp        = arb_data_5_0_rs[4];
  assign arb_data_rs_grp_mod    = arb_data_5_0_rs[5];
  assign arb_data_rs_interrupt  = arb_data_31_11_rs[(31-11):(16-11)];
  assign arb_data_rs_priority   = arb_data_31_11_rs[(15-11):(11-11)];
  assign arb_data_rs_v          = arb_data_5_0_rs[4];

  // The packet ID is only considered valid when it it being processed.  This
  // relies on all defined packet IDs being non-zero.
  assign valid_packet_id        = arb_data_5_0_rs[3:0] & {4{packet_valid}};

  assign activate_ack           = valid_packet_id == `CA53_GIC_ICD_ACTIVATE_ACK_ID;
  assign clear_recv             = valid_packet_id == `CA53_GIC_ICD_CLEAR_ID;
  assign deactivate_ack_recv    = valid_packet_id == `CA53_GIC_ICD_DEACTIVATE_ACK_ID;
  assign downstream_wr_recv     = valid_packet_id == `CA53_GIC_ICD_DOWNSTREAM_WR_ID;
  assign generate_sgi_ack_recv  = valid_packet_id == `CA53_GIC_ICD_SGI_ACK_ID;
  assign quiesce_recv           = valid_packet_id == `CA53_GIC_ICD_QUIESCE_ID;
  assign set_recv               = valid_packet_id == `CA53_GIC_ICD_SET_ID;
  assign upstream_wr_ack_recv   = valid_packet_id == `CA53_GIC_ICD_UPSTREAM_WR_ACK_ID;
  assign vclear_recv            = valid_packet_id == `CA53_GIC_ICD_VCLEAR_ID;
  assign vset_recv              = valid_packet_id == `CA53_GIC_ICD_VSET_ID;

  assign activate_ack_recv      = activate_ack & ~arb_data_rs_v;
  assign activate_ack_v_recv    = activate_ack &  arb_data_rs_v;

  // Processing of the packet has become stalled as there is an active
  // operation on the target IPR.  Stalling implies there is a valid packet.
  assign packet_stalled         = ( set_recv  & ~ipr_empty_i) |
                                  ( vset_recv & ~ipr_empty_v_i );


  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign activate_ack_recv_o      = activate_ack_recv;
  assign activate_ack_v_recv_o    = activate_ack_v_recv;
  assign arb_data_rs_interrupt_o  = arb_data_rs_interrupt;
  assign arb_data_rs_grp_o        = arb_data_rs_grp;
  assign arb_data_rs_grp_mod_o    = arb_data_rs_grp_mod;
  assign arb_data_rs_priority_o   = arb_data_rs_priority;
  assign clear_recv_o             = clear_recv;
  assign deactivate_ack_recv_o    = deactivate_ack_recv;
  assign downstream_wr_recv_o     = downstream_wr_recv;
  assign generate_sgi_ack_recv_o  = generate_sgi_ack_recv;
  assign gicd_ctlr_ds_o           = gicd_ctlr_ds;
  assign quiesce_recv_o           = quiesce_recv;
  assign set_recv_o               = set_recv;
  assign upstream_wr_ack_recv_o   = upstream_wr_ack_recv;
  assign vclear_recv_o            = vclear_recv;
  assign vset_recv_o              = vset_recv;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  reg ovl_last_gicd_ctlr_ds;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_gicd_ctlr_ds <= 1'b0;
    end else begin
      ovl_last_gicd_ctlr_ds <= gicd_ctlr_ds;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "gicd_ctlr_ds can only be deasserted at reset")
  u_ovl_gicd_ctlr_ds (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (ovl_last_gicd_ctlr_ds),
                      .consequent_expr (gicd_ctlr_ds));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Stalling can only occur when there is a valid packet")
  u_ovl_stall_valid (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (packet_stalled),
                     .consequent_expr (packet_valid));

  assert_zero_one_hot #(`OVL_FATAL, 11, `OVL_ASSERT, "Zero-One-Hot: one packet at a time")
  u_ovl_zoh_one_packet_at_a_time (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ({ activate_ack_recv,
                                                activate_ack_v_recv,
                                                clear_recv,
                                                deactivate_ack_recv,
                                                downstream_wr_recv,
                                                generate_sgi_ack_recv,
                                                quiesce_recv,
                                                set_recv,
                                                upstream_wr_ack_recv,
                                                vclear_recv,
                                                vset_recv }));


  // ------------------------------------------------------
  // X-check
  // ------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: packet_en")
  u_ovl_x_packet_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (packet_en));

  // OVL_ASSERT_END

`endif


endmodule // ca53gic_cpu_dpacket


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"
`undef CA53_UNDEFINE

