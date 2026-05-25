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
// Description: ATB Bridge
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_atb_bridge (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  clk_cpu,
  input  wire                                  po_reset_n_gov,
  input  wire                                  atclken_i,
  input  wire                                  atreadym_i,
  input  wire                                  afvalidm_i,
  input  wire [(`CA53_ATDATAM_W-1): 0]         etm_atdatam_i,
  input  wire                                  etm_atvalidm_i,
  input  wire [(`CA53_ATBYTESM_W-1): 0]        etm_atbytesm_i,
  input  wire                                  etm_afreadym_i,
  input  wire [(`CA53_ATIDM_W-1):0]            etm_atidm_i,
  input  wire                                  syncreqm_i,
  // Outputs
  output wire                                  gov_atclken_o,
  output wire                                  gov_atreadym_o,
  output wire                                  gov_afvalidm_o,
  output wire [(`CA53_ATDATAM_W-1): 0]         atdatam_o,
  output wire                                  atvalidm_o,
  output wire [(`CA53_ATBYTESM_W-1): 0]        atbytesm_o,
  output wire                                  afreadym_o,
  output wire [(`CA53_ATIDM_W-1):0]            atidm_o,
  output wire                                  gov_syncreqm_o
);

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  localparam BS1T1_AT_IDLE       = 3'b000;
  localparam BS1T1_AT_TRAN1      = 3'b001;
  localparam BS1T1_AT_PENDING1   = 3'b010;
  localparam BS1T1_AT_TRAN2      = 3'b011;
  localparam BS1T1_AT_PENDING2   = 3'b100;
  localparam BS1T1_AT_INVALID1   = 3'b101;
  localparam BS1T1_AT_INVALID2   = 3'b110;
  localparam BS1T1_AT_INVALID3   = 3'b111;
  localparam BS1T1_AT_UNDEF      = 3'bxxx;

  localparam BS1T1_ST_F_IDLE     = 3'b000;
  localparam BS1T1_ST_F_REQ      = 3'b001;
  localparam BS1T1_ST_F_WAIT1    = 3'b010;
  localparam BS1T1_ST_F_WAIT2    = 3'b011;
  localparam BS1T1_ST_F_ASSERT   = 3'b100;
  localparam BS1T1_ST_F_INVALID1 = 3'b101;
  localparam BS1T1_ST_F_INVALID2 = 3'b110;
  localparam BS1T1_ST_F_INVALID3 = 3'b111;
  localparam BS1T1_ST_F_UNDEF    = 3'bxxx;

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire                           en_atdatam_held;
  wire                           en_atvalidm_held;
  wire                           en_atbytesm_held;
  wire                           en_atidm_held;
  wire                           nxt_afvalidm_rs;
  wire                           nxt_afreadym_rs;
  wire                           two_trans_pend;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                            atclken_gov;
  reg                            atvalidm_held;
  reg [2:0]                      transfer_state;
  reg [2:0]                      new_transfer_state;
  reg                            atreadym_rs;
  reg                            atvalidm_rs;
  reg [31:0]                     atdatam_held;
  reg [31:0]                     atdatam_rs;
  reg [6:0]                      atidm_held;
  reg [6:0]                      atidm_rs;
  reg [1:0]                      atbytesm_held;
  reg [1:0]                      atbytesm_rs;
  reg [2:0]                      new_flush_state;
  reg [2:0]                      flush_state;
  reg                            afvalidm_rs;
  reg                            afreadym_rs;
  reg                            syncreqm_rs;
  reg                            sample_en;
  reg                            nxt_atreadym_rs;
  reg                            nxt_atvalidm_rs;
  reg [6:0]                      nxt_atidm_rs;
  reg [1:0]                      nxt_atbytesm_rs;
  reg [31:0]                     nxt_atdatam_rs;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //
  // This bridge has two ATB interfaces: an input and an output. It is intended on being used
  // with both interfaces existing in the same clock domain and as such is referred to as a
  // 1:1 bridge. The design  consists two set of registers across the data interface and the
  // control signals that are emitted  from trace sources.

  // ------------------------------------------------------
  // ATCLKEN
  // ------------------------------------------------------

  // Balance ATCLKEN paths between bridge and the CPU
  // Use a free-running clock to ensure that the ATCLKEN will toggle correctly during WFx
  // (particularly important on exit from WFx where we don't want an old enable)
  always @(posedge CLKIN)
    atclken_gov <= atclken_i;

  // ------------------------------------------------------
  // SYNCREQ
  // ------------------------------------------------------

  // Use a free-running clock to ensure that the SYNCREQM isn't held during WFx including
  // on exit from WFx where it could send an incorrect sync-request to the ETM
  always @(posedge CLKIN or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      syncreqm_rs <= 1'b0;
    else if (atclken_gov)
      syncreqm_rs <= syncreqm_i;

  // ------------------------------------------------------
  // ATVALIDM register
  // ------------------------------------------------------
  // Used as first pipeline stage
  //
  // The Synchronous bridge has two slices of registers for supporting back to back transfers.
  // By default, the bridge expects atreadym_rs to be HIGH, and in this case the first pipeline
  // stage (Hold registers) is bypassed. If ATREADY is low, the bridge uses the first pipeline
  // stage.

  assign en_atvalidm_held = atclken_gov & atreadym_rs;

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atvalidm_held <= 1'b0;
    else if (en_atvalidm_held)
      atvalidm_held <= etm_atvalidm_i;

  // ------------------------------------------------------
  // ATREADYM State machine
  // ------------------------------------------------------
  //
  // BS1T1_AT_IDLE     - No transfer has been requested.
  // BS1T1_AT_TRAN1    - A transfer has been requested, and is pushed to the
  //                     secondpipeline stage.
  // BS1T1_AT_PENDING1 - The first transfer has not been acknowledged by the
  //                     slave. The bridge waits for the atreadym_i signal.
  // BS1T1_AT_TRAN2    - The first transfer was not acknowledged inmediately
  //                     and the bridge uses the first pipeline stage.
  // BS1T1_AT_PENDING2 - The second transfer was not acknowledged by the slave.
  //                     The bridge waits for the atreadym_i signal.

  always @*
    begin
      case (transfer_state)
        BS1T1_AT_INVALID1,
        BS1T1_AT_INVALID2,
        BS1T1_AT_INVALID3,
        BS1T1_AT_IDLE  : begin
          new_transfer_state = etm_atvalidm_i ? BS1T1_AT_TRAN1 : BS1T1_AT_IDLE;
          nxt_atreadym_rs    = 1'b1;
          nxt_atvalidm_rs    = etm_atvalidm_i;
          nxt_atdatam_rs     = etm_atdatam_i;
          nxt_atidm_rs       = etm_atidm_i;
          nxt_atbytesm_rs    = etm_atbytesm_i;
          sample_en          = etm_atvalidm_i & atclken_gov;
        end
        BS1T1_AT_TRAN1 : begin
          new_transfer_state = ~atreadym_i ? BS1T1_AT_PENDING1 : ~etm_atvalidm_i ? BS1T1_AT_IDLE : BS1T1_AT_TRAN1;
          nxt_atreadym_rs    = atreadym_i;
          nxt_atvalidm_rs    = ~atreadym_i | etm_atvalidm_i;
          nxt_atdatam_rs     = etm_atdatam_i;
          nxt_atidm_rs       = etm_atidm_i;
          nxt_atbytesm_rs    = etm_atbytesm_i;
          sample_en          = atreadym_i & etm_atvalidm_i & atclken_gov;
        end
        BS1T1_AT_PENDING1 : begin
          new_transfer_state = ~atreadym_i ? BS1T1_AT_PENDING1 : ~atvalidm_held ? BS1T1_AT_IDLE : BS1T1_AT_TRAN2;
          nxt_atreadym_rs    = atreadym_i;
          nxt_atvalidm_rs    = ~atreadym_i | atvalidm_held;
          nxt_atdatam_rs     = atreadym_i & atvalidm_held ? atdatam_held  : etm_atdatam_i;
          nxt_atidm_rs       = atreadym_i & atvalidm_held ? atidm_held    : etm_atidm_i;
          nxt_atbytesm_rs    = atreadym_i & atvalidm_held ? atbytesm_held : etm_atbytesm_i;
          sample_en          = atreadym_i & atvalidm_held & atclken_gov;
        end
        BS1T1_AT_TRAN2 : begin
          new_transfer_state = ~atreadym_i ? BS1T1_AT_PENDING2 : ~etm_atvalidm_i ? BS1T1_AT_IDLE : BS1T1_AT_TRAN1;
          nxt_atreadym_rs    = atreadym_i;
          nxt_atvalidm_rs    = ~atreadym_i | etm_atvalidm_i;
          nxt_atdatam_rs     = atreadym_i ? etm_atdatam_i  : atdatam_held;
          nxt_atidm_rs       = atreadym_i ? etm_atidm_i    : atidm_held;
          nxt_atbytesm_rs    = atreadym_i ? etm_atbytesm_i : atbytesm_held;
          sample_en          = atreadym_i & etm_atvalidm_i & atclken_gov;
        end
        BS1T1_AT_PENDING2 : begin
          new_transfer_state = ~atreadym_i ? BS1T1_AT_PENDING2 : ~atvalidm_held ? BS1T1_AT_IDLE : BS1T1_AT_TRAN2;
          nxt_atreadym_rs    = atreadym_i;
          nxt_atvalidm_rs    = ~atreadym_i | atvalidm_held;
          nxt_atdatam_rs     = (atreadym_i & ~atvalidm_held) ? etm_atdatam_i  : atdatam_held;
          nxt_atidm_rs       = (atreadym_i & ~atvalidm_held) ? etm_atidm_i    : atidm_held;
          nxt_atbytesm_rs    = (atreadym_i & ~atvalidm_held) ? etm_atbytesm_i : atbytesm_held;
          sample_en          = atreadym_i & atvalidm_held & atclken_gov;
        end
        default : begin
          new_transfer_state = BS1T1_AT_UNDEF;
          nxt_atreadym_rs = 1'bx;
          nxt_atvalidm_rs = 1'bx;
          nxt_atdatam_rs  = {32{1'bx}};
          nxt_atidm_rs    = {7{1'bx}};
          nxt_atbytesm_rs = {2{1'bx}};
          sample_en       = 1'bx;
        end
      endcase
    end // always @ *

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      transfer_state <= BS1T1_AT_IDLE;
    else if (atclken_gov)
      transfer_state <= new_transfer_state;

  // ------------------------------------------------------
  // Generate ATREADYM output
  // ------------------------------------------------------
  //
  // atreadym_rs is asserted by default except when the bridge is expecting
  // atreadym_i to be asserted, in the PENDING states of the state machine.
  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atreadym_rs <= 1'b0;
    else if (atclken_gov)
      atreadym_rs <= nxt_atreadym_rs;

  // ------------------------------------------------------
  // Generate AT PACKET output
  // ------------------------------------------------------
  //
  // atvalidm_rs will not be HIGH when the bridge is in IDLE state. In any other state, the
  // bridge is either commiting a transfer to the ATB bus or waiting for a transfer to be
  // completed, thus atvalidm_rs should be driven HIGH
  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atvalidm_rs <= 1'b0;
    else if (atclken_gov)
      atvalidm_rs <= nxt_atvalidm_rs;

  // atdatam_held is the first pipeline stage, bypassed when atreadym_i is high.
  assign en_atdatam_held = atclken_gov & atreadym_rs & etm_atvalidm_i;

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atdatam_held <= {32{1'b0}};
    else if (en_atdatam_held)
      atdatam_held <= etm_atdatam_i;

  // atidm_held is the first pipeline stage, bypassed when atreadym_i is high.
  assign en_atidm_held = atclken_gov & atreadym_rs & etm_atvalidm_i;

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atidm_held <= {7{1'b0}};
    else if (en_atidm_held)
      atidm_held <= etm_atidm_i[6:0];

  // atbytesm_held is the first pipeline stage, bypassed when atreadym_i is high.
  assign en_atbytesm_held = atclken_gov & atreadym_rs & etm_atvalidm_i;

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      atbytesm_held <= {2{1'b0}};
    else if (en_atbytesm_held)
      atbytesm_held <= etm_atbytesm_i;

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov) begin
      atdatam_rs  <= {32{1'b0}};
      atidm_rs    <= {7{1'b0}};
      atbytesm_rs <= {2{1'b0}};
    end else if (sample_en) begin
      atdatam_rs  <= nxt_atdatam_rs[31:0];
      atidm_rs    <= nxt_atidm_rs[6:0];
      atbytesm_rs <= nxt_atbytesm_rs;
    end
  // ------------------------------------------------------
  // Flush Request and Acknowledge
  // ------------------------------------------------------
  //
  // The normal behaviour of the Flush request and acknowledge is depicted here
  //
  //                       ______________________________________
  // afvalidm_i __________/                                      \______________
  //                            ____________________
  // afvalidm_rs_o ____________/                    \______________________________
  //                                               __
  // etm_afreadym_i ______________________________/  \__________________________
  //                                                                 __
  // afreadym_rs_o _________________________________________________/  \___________
  //
  // When etm_afreadym_i is asserted there can be one or two transfers in the pipeline
  // waiting for completion. Once they have finished, afreadym_rs_o can be asserted

  // ------------------------------------------------------
  // Flush state machine
  // ------------------------------------------------------
  //
  // BS1T1_ST_F_IDLE   - No flush is requested
  // BS1T1_ST_F_REQ    - A flush has been requested but not finished in the
  //                     slave side
  // BS1T1_ST_F_WAIT1  - Flush requested has finished on the slave side but
  //                     there are TWO transfers waiting for completion in the
  //                     pipeline.
  // BS1T1_ST_F_WAIT2  - Flush requested has finished on the slave side but
  //                     there is ONE transfer waiting for completion in the
  //                     pipeline.
  // BS1T1_ST_F_ASSERT - Flush has finished in the Master side, afreadym_rs_o is
  //                     asserted.

  assign two_trans_pend = ((transfer_state == BS1T1_AT_PENDING1) |
                           (transfer_state == BS1T1_AT_PENDING2)) & atvalidm_held;

  always @*
    case (flush_state)
      BS1T1_ST_F_INVALID1,
      BS1T1_ST_F_INVALID2,
      BS1T1_ST_F_INVALID3,
      BS1T1_ST_F_IDLE   : new_flush_state = afvalidm_i ? BS1T1_ST_F_REQ : BS1T1_ST_F_IDLE;
      BS1T1_ST_F_REQ    : new_flush_state = etm_afreadym_i ? (two_trans_pend ? BS1T1_ST_F_WAIT1 :
                                                              ((atvalidm_rs & ~atreadym_i) ? BS1T1_ST_F_WAIT2 : BS1T1_ST_F_ASSERT)) :
                                            BS1T1_ST_F_REQ;

      BS1T1_ST_F_WAIT1  : new_flush_state = (atvalidm_rs & atreadym_i) ? BS1T1_ST_F_WAIT2  : BS1T1_ST_F_WAIT1;
      BS1T1_ST_F_WAIT2  : new_flush_state = (atvalidm_rs & atreadym_i) ? BS1T1_ST_F_ASSERT : BS1T1_ST_F_WAIT2;
      BS1T1_ST_F_ASSERT : new_flush_state = BS1T1_ST_F_IDLE;
      default           : new_flush_state = BS1T1_ST_F_UNDEF;
    endcase

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      flush_state <= BS1T1_ST_F_IDLE;
    else if (atclken_gov)
      flush_state <= new_flush_state;

  // ------------------------------------------------------
  // Generate AFVALIDM output
  // ------------------------------------------------------

  assign nxt_afvalidm_rs = (new_flush_state == BS1T1_ST_F_REQ);

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      afvalidm_rs <= 1'b0;
    else if (atclken_gov)
      afvalidm_rs <= nxt_afvalidm_rs;

  // ------------------------------------------------------
  // Generate AFREADYM output
  // ------------------------------------------------------
  //
  // Either indicate a flush completion when the state machine has tracked
  // packets through the bridge or when there are no packets in the bridge, nor
  // any packets reported by the master (if the system is empty and the
  // attached master has AFREADY set then it is safe to assume it is empty).

  assign nxt_afreadym_rs = ((new_flush_state == BS1T1_ST_F_ASSERT) |
                            (~etm_atvalidm_i & (transfer_state == BS1T1_AT_IDLE) & etm_afreadym_i));

  always @(posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      afreadym_rs <= 1'b1;
    else if (atclken_gov)
      afreadym_rs <= nxt_afreadym_rs;

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign gov_atclken_o  = atclken_gov;
  assign gov_atreadym_o = atreadym_rs;
  assign gov_afvalidm_o = afvalidm_rs;
  assign atdatam_o      = atdatam_rs[31:0];
  assign atvalidm_o     = atvalidm_rs;
  assign atbytesm_o     = atbytesm_rs[1:0];
  assign afreadym_o     = afreadym_rs;
  assign atidm_o        = atidm_rs[6:0];
  assign gov_syncreqm_o = syncreqm_rs;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sample_en")
  u_ovl_x_sample_en (.clk       (clk_cpu),
                     .reset_n   (po_reset_n_gov),
                     .qualifier (1'b1),
                     .test_expr (sample_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: atclken_gov")
  u_ovl_x_atclken_gov (.clk       (clk_cpu),
                       .reset_n   (po_reset_n_gov),
                       .qualifier (1'b1),
                       .test_expr (atclken_gov));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_atbytesm_held")
  u_ovl_x_en_atbytesm_held (.clk       (clk_cpu),
                            .reset_n   (po_reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (en_atbytesm_held));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_atdatam_held")
  u_ovl_x_en_atdatam_held (.clk       (clk_cpu),
                           .reset_n   (po_reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (en_atdatam_held));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_atidm_held")
  u_ovl_x_en_atidm_held (.clk       (clk_cpu),
                         .reset_n   (po_reset_n_gov),
                         .qualifier (1'b1),
                         .test_expr (en_atidm_held));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_atvalidm_held")
  u_ovl_x_en_atvalidm_held (.clk       (clk_cpu),
                            .reset_n   (po_reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (en_atvalidm_held));

  //----------------------------------------------------------------------------
  // ATB state machine assertions
  //----------------------------------------------------------------------------

  reg          nRESETovl;

  // Reset repeaters
  always @ (posedge clk_cpu or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      nRESETovl <= 1'b0;
    else if (~nRESETovl)
      nRESETovl <= po_reset_n_gov;

  // ATB state machine in unpredictable state
  assert_never #(`OVL_ERROR, `OVL_ASSERT, "CSBRIDGESYNC1T1 - Transfer state machine in unpredictable state")
    transfer_sm_unpredictable (clk_cpu, nRESETovl, ((transfer_state == BS1T1_AT_INVALID1) ||
                                                    (transfer_state == BS1T1_AT_INVALID2) ||
                                                    (transfer_state == BS1T1_AT_INVALID3)));

  // Flush state machine in unpredictable state
  assert_never #(`OVL_ERROR, `OVL_ASSERT, "CSBRIDGESYNC1T1 - Flush state machine in unpredictable state")
    flush_sm_unpredictable (clk_cpu, nRESETovl, ((flush_state == BS1T1_ST_F_INVALID1) ||
                                                 (flush_state == BS1T1_ST_F_INVALID2) ||
                                                 (flush_state == BS1T1_ST_F_INVALID3)));
`endif

endmodule // ca53governor_cpu_atb_bridge

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
