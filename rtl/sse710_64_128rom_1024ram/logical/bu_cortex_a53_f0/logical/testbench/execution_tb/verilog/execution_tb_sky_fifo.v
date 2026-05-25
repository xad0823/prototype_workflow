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
//   A FIFO buffering flits in the Skyros subsystem
//------------------------------------------------------------------------------

`include "execution_tb_defs.v"

module execution_tb_sky_fifo #(parameter integer WIDTH   = 100,
                               parameter integer ENTRIES = 4)
(
  // Clocks and rests
  input  wire               clk,
  input  wire               reset_n,

  // Push and pop
  input  wire [(WIDTH-1):0] pushd_i,
  input  wire               push_i,
  output wire [(WIDTH-1):0] popd_o,
  input  wire               pop_i,

  // FIFO status
  output wire               empty_o,
  output wire               full_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam integer PTR_WIDTH = `CA53_EXECTB_LOG2(ENTRIES);
  localparam integer CNT_WIDTH = `CA53_EXECTB_LOG2(ENTRIES+1);


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  reg  [(WIDTH-1):0]     fifo    [0:(ENTRIES-1)];
  wire                   fifo_we [0:(ENTRIES-1)];

  reg  [(PTR_WIDTH-1):0] rptr;
  wire [(PTR_WIDTH-1):0] nxt_rptr;
  wire                   rptr_we;
  reg  [(PTR_WIDTH-1):0] wptr;
  wire [(PTR_WIDTH-1):0] nxt_wptr;
  wire                   wptr_we;
  reg  [(CNT_WIDTH-1):0] cntr;
  wire [(CNT_WIDTH-1):0] nxt_cntr;
  wire                   cntr_we;

  wire [(WIDTH-1):0]     popd;

  wire                   empty;
  wire                   full;

  genvar i;


  //----------------------------------------------------------------------------
  // Main code
  //----------------------------------------------------------------------------

  // FIFO
  generate for (i=0; i<ENTRIES; i=i+1) begin : gen_fifo
    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        fifo[i] <= {WIDTH{1'b0}};
      else if (fifo_we[i])
        fifo[i] <= pushd_i;

    assign fifo_we[i] = (wptr == i[(PTR_WIDTH-1):0]) & push_i & ~full;
  end endgenerate

  // Read pointer
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rptr <= {PTR_WIDTH{1'b0}};
    else if (rptr_we)
      rptr <= nxt_rptr;

  assign rptr_we  = pop_i & ~empty;
  assign nxt_rptr = rptr + 1'b1;

  // Write pointer
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      wptr <= {PTR_WIDTH{1'b0}};
    else if (wptr_we)
      wptr <= nxt_wptr;

  assign wptr_we  = push_i & ~full;
  assign nxt_wptr = wptr + 1'b1;

  // Element counter
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      cntr <= {CNT_WIDTH{1'b0}};
    else if (cntr_we)
      cntr <= nxt_cntr;

  assign cntr_we  = push_i ^ pop_i;
  assign nxt_cntr = push_i ? (cntr + 1'b1) : (cntr - 1'b1);

  // Pop
  assign popd = fifo[rptr];

  // Status
  assign empty    = (cntr == {CNT_WIDTH{1'b0}});
  assign full     = (cntr == ENTRIES);


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign popd_o  = popd;
  assign empty_o = empty;
  assign full_o  = full;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_EXECTB_UNDEFINE
`include "execution_tb_defs.v"
`undef CA53_EXECTB_UNDEFINE
/*END*/

