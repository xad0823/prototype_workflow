//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
// Description:
//
//   Skyros validation subsystem TX channel.  This module contains a flit FIFO
//   and credit mangement for TX channels.
//------------------------------------------------------------------------------

module execution_tb_sky_tx_chan #(parameter integer FLIT_WIDTH = 144,
                                  parameter integer FIFO_DEPTH = 4)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    reset_n,

  // Skyros signals
  output wire                    txflitpend_o,
  output wire                    txflitv_o,
  output wire [(FLIT_WIDTH-1):0] txflit_o,
  input  wire                    txlcrdv_i,

  // Link active state
  input  wire [1:0]              txlinkactive_st_i,

  // Internal channel interface
  output wire                    ch_full_o,     // FIFO is full
  output wire                    ch_empty_o,    // FIFO is empty
  input  wire                    ch_push_i,     // Push a flit
  input  wire [(FLIT_WIDTH-1):0] ch_flit_i      // Pushed flit
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  // Regardless of the FIFO depth, a transmitter must be able to accept up to 15
  // L-credits from the receiver.
  localparam integer CNT_WIDTH = 4;

  // Common Skyros constants
  `include "execution_tb_sky_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Flit control
  wire                    flit_fifo_full;
  wire                    flit_fifo_empty;
  wire                    pop;
  wire [(FLIT_WIDTH-1):0] popd;
  wire [(FLIT_WIDTH-1):0] txflit;
  wire                    txflitv;
  wire                    txflitpend;

  // Credit management
  reg  [(CNT_WIDTH-1):0]  credit_cnt;
  wire [(CNT_WIDTH-1):0]  nxt_credit_cnt;
  wire                    credit_cnt_we;
  wire                    credit_rtn;
  reg                     credit_rtn_reg;


  //----------------------------------------------------------------------------
  // Flit FIFO
  //----------------------------------------------------------------------------

  execution_tb_sky_fifo #(.WIDTH  (FLIT_WIDTH),
                          .ENTRIES(FIFO_DEPTH))
    u_execution_tb_sky_tx_fifo
      (.clk       (clk),
       .reset_n   (reset_n),
       .push_i    (ch_push_i),
       .pushd_i   (ch_flit_i),
       .pop_i     (pop),
       .popd_o    (popd),
       .empty_o   (flit_fifo_empty),
       .full_o    (flit_fifo_full)
      );

  // Flit popped when the FIFO isn't empty and the channel is in credit,
  // provided the link is active.
  assign pop = (credit_cnt != {CNT_WIDTH{1'b0}}) & ~flit_fifo_empty & (txlinkactive_st_i == SKY_LINK_RUN);

  // The output flit comes from the FIFO in the normal case but is zeroed out
  // when the link is not active.  This creates the L-credit return flit.
  assign txflit     = popd & {FLIT_WIDTH{(txlinkactive_st_i == SKY_LINK_RUN)}};
  assign txflitv    = pop | credit_rtn_reg;
  assign txflitpend = ch_push_i | ~flit_fifo_empty | (txlinkactive_st_i == SKY_LINK_DEACTIVATE);


  //----------------------------------------------------------------------------
  // Credit management
  //----------------------------------------------------------------------------

  // Received credit counter
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      credit_cnt <= {CNT_WIDTH{1'b0}};
    else if (credit_cnt_we)
      credit_cnt <= nxt_credit_cnt;

  // Increment counter when credit is received.  Decrement it when a flit is
  // pushed or credit returned.
  assign nxt_credit_cnt = txlcrdv_i ? (credit_cnt + 1'b1) : (credit_cnt - 1'b1);
  assign credit_cnt_we  = (txlcrdv_i ^ pop) | credit_rtn;

  // Credit returned when link de-activates and credit is still available
  assign credit_rtn = (txlinkactive_st_i == SKY_LINK_DEACTIVATE) & (credit_cnt != {CNT_WIDTH{1'b0}});

  // Clean registered credit return signal for factoring in FLITV. The FLITV
  // term must be one cycle later than the FLITPEND term.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      credit_rtn_reg <= 1'b0;
    else
      credit_rtn_reg <= credit_rtn;


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign ch_full_o    = flit_fifo_full;
  assign ch_empty_o   = flit_fifo_empty;
  assign txflitpend_o = txflitpend;
  assign txflitv_o    = txflitv;
  assign txflit_o     = txflit;

endmodule

