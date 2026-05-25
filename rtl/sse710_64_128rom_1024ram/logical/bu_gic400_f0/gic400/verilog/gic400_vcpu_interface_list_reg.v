//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-08-03 15:09:44 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180427 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose: Implements a virtual CPU interface list register, calculates the
//          Ack and EOI/deactivate associated with the list register, and
//          tracks the active/pending status for the list.
//
//-----------------------------------------------------------------------------

module gic400_vcpu_interface_list_reg
(
  input  wire           clk_p,
  input  wire           reset_n,

  input  wire           p_read_i,
  input  wire           p_rd_front_i,
  input  wire           p_write_i,
  input  wire           p_wr_front_i,
  input  wire    [31:0] p_wdata_i,

  input  wire           p_rd_ack_front_i,
  input  wire           p_rd_ack_ns_alias_front_i,
  input  wire           p_wr_eoi_front_i,
  input  wire           p_wr_eoi_ns_alias_front_i,
  input  wire           p_wr_deactivate_front_i,
  input  wire           p_wr_list_back_i,

  input  wire           eoi_virt_id_match_i,
  input  wire           interrupt_valid_i,
  input  wire           hppi_sel_i,
  input  wire           vm_ack_ctl_i,
  input  wire           vm_eoimode_i,

  output wire           list_active_o,
  output wire           list_pending_o,
  output wire           list_send_deactivate_o,
  output wire           list_hw_o,
  output wire           list_ns_o,
  output wire     [4:0] list_priority_o,
  output wire           list_ei_o,
  output wire     [8:0] list_phys_id_o,
  output wire     [9:0] list_virt_id_o

);

  //---------------------------------------------------------------------------
  // Wire declarations & constants
  //---------------------------------------------------------------------------

  // State machine states
  localparam [1:0] STATE_INVALID = 2'b00;
  localparam [1:0] STATE_PENDING = 2'b01;
  localparam [1:0] STATE_ACTIVE  = 2'b10;
  localparam [1:0] STATE_PACTIVE = 2'b11;

  wire        list_ack;
  wire        list_eoi_deactivate;
  wire        list_write;
  reg   [1:0] nxt_list_state;
  reg   [1:0] list_state_q;
  wire        nxt_list_ei;
  reg         list_hw_q;
  reg         list_ns_q;
  reg   [4:0] list_priority_q;
  reg         list_ei_q;
  reg   [8:0] list_phys_id_q;
  reg   [9:0] list_virt_id_q;


  //---------------------------------------------------------------------------
  // State machine
  //---------------------------------------------------------------------------

  // IAR
  assign list_ack  = p_read_i & p_rd_front_i & interrupt_valid_i & hppi_sel_i &
                     ((p_rd_ack_front_i & (~list_ns_q | vm_ack_ctl_i)) |  // Secure ack's also apply to ns if AckCtl set
                      p_rd_ack_ns_alias_front_i & list_ns_q);             // Non-secure ack's only apply to ns

  // EOI/Deactivate
  // - Format is same for all EOI/deactivate registers, with virtual ID in
  //   wdata[9:0]
  assign list_eoi_deactivate = p_write_i & p_wr_front_i & eoi_virt_id_match_i & list_state_q[1] & // Active set
                               (vm_eoimode_i ? p_wr_deactivate_front_i
                                             : (p_wr_eoi_front_i | p_wr_eoi_ns_alias_front_i));

  assign list_write = p_write_i & ~p_wr_front_i & p_wr_list_back_i;

  always @* begin
    if (list_write) begin
      // Write to register sets value directly, and has priority over
      // Ack
      nxt_list_state = p_wdata_i[29:28];
    end else begin
      case (list_state_q)
        STATE_INVALID : nxt_list_state = list_state_q;  // Only a write can change state from idle
        STATE_PENDING : nxt_list_state = list_ack            ? STATE_ACTIVE  : list_state_q;  // EOI ignored when not Active
        STATE_ACTIVE  : nxt_list_state = list_eoi_deactivate ? STATE_INVALID : list_state_q;   // Ack ignored when already Active
        STATE_PACTIVE : nxt_list_state = list_eoi_deactivate ? STATE_PENDING : list_state_q;
        default: nxt_list_state = 2'bxx;
      endcase
    end
  end

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      list_state_q[1:0] <= STATE_INVALID;
    else
      list_state_q[1:0] <= nxt_list_state[1:0];

  assign list_active_o  = list_state_q[1];
  assign list_pending_o = list_state_q[0];


  //---------------------------------------------------------------------------
  // Architectural List Register
  //---------------------------------------------------------------------------

  assign nxt_list_ei = ~p_wdata_i[31] & p_wdata_i[19];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      list_hw_q            <= 1'b0;
      list_ns_q            <= 1'b0;
      list_priority_q[4:0] <= {5{1'b0}};
      list_ei_q            <= 1'b0;
      list_phys_id_q[8:0]  <= {9{1'b0}};
      list_virt_id_q[9:0]  <= {10{1'b0}};
    end else if (list_write) begin
      list_hw_q            <= p_wdata_i[31];
      list_ns_q            <= p_wdata_i[30];
      list_priority_q[4:0] <= p_wdata_i[27:23];
      list_ei_q            <= nxt_list_ei;
      list_phys_id_q[8:0]  <= p_wdata_i[18:10];
      list_virt_id_q[9:0]  <= p_wdata_i[9:0];
    end

  // Matching List Register with referenced interrupt ID has active bit set 
  // and List Register has HW set
  assign list_send_deactivate_o = eoi_virt_id_match_i & list_state_q[1] & list_hw_q;

  assign list_hw_o        = list_hw_q;
  assign list_ns_o        = list_ns_q;
  assign list_priority_o  = list_priority_q[4:0];
  assign list_ei_o        = list_ei_q;
  assign list_phys_id_o   = list_phys_id_q[8:0];
  assign list_virt_id_o   = list_virt_id_q[9:0];

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: list_write")
  u_ovl_x_list_write (.clk       (clk_p),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (list_write));


`endif

endmodule

