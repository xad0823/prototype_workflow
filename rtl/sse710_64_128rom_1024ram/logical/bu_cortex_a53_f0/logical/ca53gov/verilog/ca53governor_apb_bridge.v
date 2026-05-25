//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Description: Synchronous APB bridge
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_apb_bridge
  (//Clock and reset signals
   input                 CLKIN,      //apb clock
   input                 presetn_i,  //apb reset
   //APB3 Bus
   input                 pclkens_i,  //apb clock enable (slave)
   input   [21:2]        paddrs_i,   //address of APB bus
   input                 paddr31s_i, //Access:Debug/Memory
   input   [31:0]        pwdatas_i,  //write data of APB bus
   input                 pwrites_i,  //read/write control of APB bus
   input                 penables_i, //enable of APB bus
   input                 psels_i,    //peripheral select of APB bus
   output  [31:0]        prdatas_o,  //read data of APB bus
   output                pslverrs_o, //error response of APB bus
   output                preadys_o,  //ready of APB bus
   //APB3 Bus
   input                 pclkenm_i,  //apb clock enable (master)
   output  [21:2]        paddrm_o,   //address of APB bus
   output                paddr31m_o, //Access:Debug/Memory
   output  [31:0]        pwdatam_o,  //write data of APB bus
   output                pwritem_o,  //read/write control of APB bus
   output                pselm_o,    //peripheral select of APB bus
   input   [31:0]        prdatam_i,  //read data of APB bus
   input                 pslverrm_i, //error response of APB bus
   input                 preadym_i   //ready of APB bus
   );

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam APBAS_ST_W = 2;
  localparam [APBAS_ST_W-1:0] APBAS_ST_IDLE   = 2'b00;
  localparam [APBAS_ST_W-1:0] APBAS_ST_SETUP  = 2'b01;
  localparam [APBAS_ST_W-1:0] APBAS_ST_ACCESS = 2'b10;
  localparam [APBAS_ST_W-1:0] APBAS_ST_ACK    = 2'b11;

  // Packet size
  localparam APB_IN_SIZE  = 54;
  localparam APB_OUT_SIZE = 33;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [APBAS_ST_W-1:0]              current_state_q;
  reg [APBAS_ST_W-1:0]              next_state;

  // Common
  reg [APB_IN_SIZE-1:0]             fwd_data_sync;
  reg [APB_OUT_SIZE-1:0]            rev_data_sync;

  // Slave interface
  reg                               hs_req_q;
  reg                               pready_q;
  reg [APB_OUT_SIZE-1:0]            apbm_rev_data_capt;
  reg                               apbm_ack_sync;
  reg                               pclkens_rs;
  reg                               penables_rs;
  reg                               psels_rs;
  reg                               apb_idle_rs;

  // Master interface
  reg                               psel_q;
  reg                               apbs_req_sync;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                              pending_req;
  wire                              nxt_hs_req;
  wire                              hs_req_en;
  wire                              clk_ready_en;
  wire                              pready_q_nxt;
  wire                              apbm_req_sync;
  wire [APB_OUT_SIZE-1:0]           apbm_rev_data_sync;
  wire                              clk_fwd_en;
  wire [APB_IN_SIZE-1:0]            apbm_fwd_data_sync;
  wire                              clk_en;
  wire                              psel_q_nxt;
  wire                              capt_en;
  wire [APB_IN_SIZE-1:0]            apbs_fwd_data_sync;
  wire                              apbs_ack_sync;
  wire                              clk_rev_en;
  wire [APB_OUT_SIZE-1:0]           apbs_rev_data_sync;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Interface pipeline
  // ------------------------------------------------------

  // Pipeline the PCLKENDBG signal to ease timing paths from the system.  The system must
  // be aware that the PCLKENDBG signal must be inserted ahead of everything else.
  always @ (posedge CLKIN)
    pclkens_rs <= pclkens_i;

  // Pipeline the PENABLE and PSEL signals. Bridge must wait for de-assertion of penable
  // before starting new transaction
  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      penables_rs <= 1'b0;
    else if (pclkens_rs)
      penables_rs <= penables_i;

  always @ (posedge CLKIN)
    if (pclkens_rs) begin
      psels_rs    <= psels_i;
      apb_idle_rs <= penables_rs;
    end

  // ------------------------------------------------------
  // Slave interface
  // ------------------------------------------------------

  // Handshake is initiated when there's a pending request (both PENABLE and
  // PSEL high) and when previous transfer is completed (synchronized
  // acknowledge from core domain is low)
  assign pending_req = penables_rs & psels_rs & ~apb_idle_rs;

  assign hs_req_en  = pclkens_rs &
                    ((~hs_req_q & ~pready_q & pending_req) |
                     (hs_req_q & apbm_ack_sync));
  assign nxt_hs_req = ~hs_req_q & ~apbm_ack_sync & pending_req;

  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      hs_req_q <= 1'b0;
    else if (hs_req_en)
      hs_req_q <= nxt_hs_req;

  assign clk_ready_en = pclkens_rs & (apbm_ack_sync & hs_req_q | pready_q);

  assign pready_q_nxt = apbm_ack_sync & hs_req_q;

  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      pready_q <= 1'b1;
    else if (clk_ready_en)
      pready_q <= pready_q_nxt;

  assign preadys_o = pready_q;

  //
  // Incoming Data
  //
  assign apbm_rev_data_sync = rev_data_sync & {APB_OUT_SIZE{apbm_ack_sync}};

  always @(posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      apbm_rev_data_capt <= {{32{1'b0}},1'b1};
    else if (hs_req_q)
      apbm_rev_data_capt <= apbm_rev_data_sync;

  // Expand Reverse Payload
  assign {prdatas_o, pslverrs_o} = apbm_rev_data_capt;

  //
  // Outgoing Req
  //
  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      apbs_req_sync <= 1'b0;
    else if (hs_req_en)
      apbs_req_sync <= apbm_req_sync;

  assign apbm_req_sync = nxt_hs_req;

  //
  // Outgoing Data
  //
  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      fwd_data_sync <= {APB_IN_SIZE{1'b0}};
    else if (clk_fwd_en)
      fwd_data_sync <= apbm_fwd_data_sync;

  // Generate Clock Enable
  assign clk_fwd_en = ~hs_req_q & ~pready_q & pending_req & pclkens_rs;

  // Concatenate Forward Payload
  assign apbm_fwd_data_sync = {paddr31s_i, paddrs_i, pwdatas_i, pwrites_i};

  // ------------------------------------------------------
  // Master interface
  // ------------------------------------------------------

  assign clk_en = pclkenm_i &
                  (apbs_req_sync | (current_state_q == APBAS_ST_ACK));

  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      current_state_q <= APBAS_ST_IDLE;
    else if (clk_en)
      current_state_q <= next_state;

  always @* begin
    case (current_state_q)
      APBAS_ST_IDLE   : next_state = apbs_req_sync ? APBAS_ST_SETUP : APBAS_ST_IDLE;
      APBAS_ST_SETUP  : next_state = APBAS_ST_ACCESS;
      APBAS_ST_ACCESS : next_state = preadym_i ? APBAS_ST_ACK : APBAS_ST_ACCESS;
      APBAS_ST_ACK    : next_state = ~apbs_req_sync ? APBAS_ST_IDLE : APBAS_ST_ACK;
      default         : next_state = {APBAS_ST_W{1'bx}};
    endcase
  end

  assign psel_q_nxt = apbs_req_sync & (current_state_q == APBAS_ST_IDLE) |
                      (current_state_q == APBAS_ST_SETUP) |
                      ~preadym_i & (current_state_q == APBAS_ST_ACCESS);

  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      psel_q <= 1'b0;
    else if (clk_en)
      psel_q <= psel_q_nxt;

  assign pselm_o = psel_q;

  //
  // Incoming Data
  //
  assign apbs_fwd_data_sync = fwd_data_sync & {APB_IN_SIZE{capt_en}};

  // Enable the cdc capt block from rising edge of synchronised req until rising
  // edge of output ack.
  assign capt_en = apbs_req_sync & (~apbs_ack_sync);

  // Expand Forward Payload
  assign {paddr31m_o, paddrm_o, pwdatam_o, pwritem_o} = apbs_fwd_data_sync;

  //
  // Outgoing Ack
  //
  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      apbm_ack_sync <= 1'b0;
    else
      apbm_ack_sync <= apbs_ack_sync;

  assign apbs_ack_sync = (current_state_q == APBAS_ST_ACK);

  //
  // Outgoing Data
  //
  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i)
      rev_data_sync <= {APB_OUT_SIZE{1'b0}};
    else if (clk_rev_en)
      rev_data_sync <= apbs_rev_data_sync;

  // Generate Clock Enable
  assign clk_rev_en = pclkenm_i & (current_state_q == APBAS_ST_ACCESS) & preadym_i;

  // Concatenate Reverse Payload
  assign apbs_rev_data_sync = {prdatam_i, pslverrm_i};

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pclkens_rs")
  u_ovl_x_pclkens_rs (.clk       (CLKIN),
                      .reset_n   (presetn_i),
                      .qualifier (1'b1),
                      .test_expr (pclkens_rs));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clk_en")
  u_ovl_x_clk_en (.clk       (CLKIN),
                  .reset_n   (presetn_i),
                  .qualifier (1'b1),
                  .test_expr (clk_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clk_fwd_en")
  u_ovl_x_clk_fwd_en (.clk       (CLKIN),
                      .reset_n   (presetn_i),
                      .qualifier (1'b1),
                      .test_expr (clk_fwd_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clk_ready_en")
  u_ovl_x_clk_ready_en (.clk       (CLKIN),
                        .reset_n   (presetn_i),
                        .qualifier (1'b1),
                        .test_expr (clk_ready_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clk_rev_en")
  u_ovl_x_clk_rev_en (.clk       (CLKIN),
                      .reset_n   (presetn_i),
                      .qualifier (1'b1),
                      .test_expr (clk_rev_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hs_req_en")
  u_ovl_x_hs_req_en (.clk       (CLKIN),
                     .reset_n   (presetn_i),
                     .qualifier (1'b1),
                     .test_expr (hs_req_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hs_req_q")
  u_ovl_x_hs_req_q (.clk       (CLKIN),
                    .reset_n   (presetn_i),
                    .qualifier (1'b1),
                    .test_expr (hs_req_q));

  //----------------------------------------------------------------------------
  // State machine X-Checks
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "State-machine: next_state x-check")
  u_ovl_x_next_state (.clk       (CLKIN),
                      .reset_n   (presetn_i),
                      .qualifier (1'b1),
                      .test_expr (next_state[1:0]));

  //----------------------------------------------------------------------------
  // Check the APB input bus remains constant when PCLKENDBG is deasserted
  //----------------------------------------------------------------------------

  reg        ovl_pclken;
  reg        ovl_paddr31s;
  reg [21:2] ovl_paddrs;
  reg [31:0] ovl_pwdatas;
  reg        ovl_pwrites;
  reg        ovl_penables;
  reg        ovl_psels;

  always @ (posedge CLKIN or negedge presetn_i)
    if (!presetn_i) begin
      ovl_pclken   <= 1'b0;
      ovl_paddr31s <= 1'b0;
      ovl_paddrs   <= {20{1'b0}};
      ovl_pwdatas  <= {32{1'b0}};
      ovl_pwrites  <= 1'b0;
      ovl_penables <= 1'b0;
      ovl_psels    <= 1'b0;
    end
    else begin
      ovl_pclken   <= pclkens_rs;
      ovl_paddr31s <= fwd_data_sync[53   ];
      ovl_paddrs   <= fwd_data_sync[52:33];
      ovl_pwdatas  <= fwd_data_sync[32: 1];
      ovl_pwrites  <= fwd_data_sync[    0];
      ovl_penables <= penables_rs;
      ovl_psels    <= psels_rs;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "APB inputs should not be sampled when PCLKENDBG is deasserted")
  u_ovl_constant_apb_in (.clk             (CLKIN),
                         .reset_n         (presetn_i),
                         .antecedent_expr (~ovl_pclken),
                         .consequent_expr ((ovl_paddr31s === fwd_data_sync[53   ]) &&
                                           (ovl_paddrs   === fwd_data_sync[52:33]) &&
                                           (ovl_pwdatas  === fwd_data_sync[32: 1]) &&
                                           (ovl_pwrites  === fwd_data_sync[    0])));

`endif //  `ifdef ARM_ASSERT_ON

endmodule // ca53governor_apb_bridge

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
