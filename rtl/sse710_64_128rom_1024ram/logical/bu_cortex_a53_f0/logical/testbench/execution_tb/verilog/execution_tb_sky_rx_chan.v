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
//   Skyros validation subsystem RX channel.  This module contains a flit FIFO
//   and credit mangement for RX channels.
//------------------------------------------------------------------------------

`include "execution_tb_defs.v"

module execution_tb_sky_rx_chan #(parameter integer FLIT_WIDTH = 100,
                                  parameter integer FIFO_DEPTH = 4)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    reset_n,

  // Skyros signals
  input  wire                    rxflitv_i,
  input  wire [(FLIT_WIDTH-1):0] rxflit_i,
  output wire                    rxlcrdv_o,

  // Link active state
  input  wire [1:0]              rxlinkactive_st_i,

  // Internal channel interface
  output wire                    ch_active_o,   // The channel is active
  output wire                    ch_flitv_o,    // At least one flit is pending
  input  wire                    ch_pop_i,      // Pop a pending flit
  output wire [(FLIT_WIDTH-1):0] ch_flit_o,     // Popped flit
  input  wire                    ch_crd_rtn_i   // Credit returned
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam integer CNT_WIDTH = `CA53_EXECTB_LOG2(FIFO_DEPTH+1);

  // Common Skyros constants
  `include "execution_tb_sky_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Flit control
  wire [(FLIT_WIDTH-1):0] flit;
  wire                    flit_fifo_empty;

  // Credit management
  reg  [(CNT_WIDTH-1):0]  credit_cnt;
  wire [(CNT_WIDTH-1):0]  nxt_credit_cnt;
  wire                    credit_cnt_we;

  // Credit issuing
  reg                     rxlcrdv;
  wire                    nxt_rxlcrdv;


  //----------------------------------------------------------------------------
  // Flit FIFO
  //----------------------------------------------------------------------------

  execution_tb_sky_fifo #(.WIDTH  (FLIT_WIDTH),
                          .ENTRIES(FIFO_DEPTH))
    u_execution_tb_sky_rx_fifo
      (.clk       (clk),
       .reset_n   (reset_n),
       .push_i    (rxflitv_i),
       .pushd_i   (rxflit_i),
       .pop_i     (ch_pop_i),
       .popd_o    (flit),
       .empty_o   (flit_fifo_empty),
       .full_o    ()  // Not used in RX channel
      );


  //----------------------------------------------------------------------------
  // Credit management
  //
  //   Up to FIFO_DEPTH credits are issued to the transmitter when the link is
  //   active in the RUN state.
  //----------------------------------------------------------------------------

  // Issued credit counter
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      credit_cnt  <= {CNT_WIDTH{1'b0}};
    else if (credit_cnt_we)
      credit_cnt  <= nxt_credit_cnt;

  // Counter incremented on the same cycle that rxlcrdv goes high.  Decremented
  // when the validation subsystem consumes a flit (which includes credit
  // returns.)
  assign nxt_credit_cnt = nxt_rxlcrdv ? (credit_cnt + 1'b1) : (credit_cnt - 1'b1);
  assign credit_cnt_we  = nxt_rxlcrdv ^ ch_pop_i;

  // Issue credits
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rxlcrdv <= 1'b0;
    else
      rxlcrdv <= nxt_rxlcrdv;

  assign nxt_rxlcrdv = (rxlinkactive_st_i == SKY_LINK_RUN) & (credit_cnt < FIFO_DEPTH);


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign rxlcrdv_o   = rxlcrdv;
  assign ch_active_o = (credit_cnt != {CNT_WIDTH{1'b0}});
  assign ch_flitv_o  = ~flit_fifo_empty;
  assign ch_flit_o   = flit;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_EXECTB_UNDEFINE
`include "execution_tb_defs.v"
`undef CA53_EXECTB_UNDEFINE
/*END*/

