//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2011-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-01-21 15:26:03 +0000 (Thu, 21 Jan 2016)
// Revision : 205793
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_ful_regd_slice.v
//-----------------------------------------------------------------------------
// Purpose : The ful_regd_slice provides full timing isolation between the
//           source and destination interfaces.
//-----------------------------------------------------------------------------
// Overview :
//
// The ful_regd_slice monitors and drives the handshake signals from/to
// the master and slave interfaces.  The component instantiates two storage
// registers to ensure a minimum latency of 1 and back to back transfer
// support.  A minimum of two storage registers are required for full timing
// isolation due to the latency effects of the registers and protocol
// requirements.
//
// rd_sel is split into a bussed signal in order to reduce the loading on the
// registers generating rd_sel.  Each rd_sel[] signal drives no more than
// MAX_BITS_PER_SEL multiplexor elements.  rd_sel[NUM_SEL_BITS-1] drives the
// remainder. rd_sel[NUM_SEL_BITS-1] is used in the control logic as that will
// never have higher fanout than any other bit, and will likely have lower
// fanout.
//----------------------------------------------------------------------------

module adb400_r3_ful_regd_slice
  #(parameter
      PAYLD_WIDTH = 2
  )
  (
    input  wire                   aclk,      // global clock
    input  wire                   aresetn,   // global reset
  
    input  wire                   valid_src, // transfer valid from the source
    output wire                   ready_src, // source ready to accept transfer
    input  wire [PAYLD_WIDTH-1:0] payld_src, // transfer payload from source
  
    output wire                   valid_dst, // transfer valid to the destination
    input  wire                   ready_dst, // destination ready to accept transfer
    output wire [PAYLD_WIDTH-1:0] payld_dst  // transfer payload to destination
   );

  //----------------------------------------------------------------------------
  // internal signals declarations
  //----------------------------------------------------------------------------
  reg        wr_sel;    // select receiver of payld_src
  wire [1:0] wr_valid;  // valid to each payload register
  // NOTE: no wr_ready needed as is implicit in there being a non-occupied slot

  reg        rd_sel;    // select driver for payld_dst
  wire [1:0] rd_ready;  // ready to each payload register
  reg  [1:0] rd_valid;  // valid content of the payload registers

  //----------------------------------------------------------------------------
  // Destination of valid_src depends on wr_sel
  //----------------------------------------------------------------------------

  assign wr_valid[0] = ~wr_sel & valid_src;
  assign wr_valid[1] =  wr_sel & valid_src;

  //----------------------------------------------------------------------------
  // Destination of ready_dst depends on rd_sel
  //----------------------------------------------------------------------------

  assign rd_ready[0] = ~rd_sel & ready_dst;
  assign rd_ready[1] =  rd_sel & ready_dst;

  //----------------------------------------------------------------------------
  // Select which register to write to
  //----------------------------------------------------------------------------

  wire wr_sel_upd_en = valid_src & ready_src;
  always @(posedge aclk or negedge aresetn)
  begin : p_wr_sel
    if (!aresetn)
      wr_sel <= 1'b0;
    else if (wr_sel_upd_en)
      wr_sel <= ~wr_sel;
  end

  //----------------------------------------------------------------------------
  // Enable to write into payload registers
  //----------------------------------------------------------------------------

  // Can write into it if selected and not already full.
  wire [1:0] wr_en = wr_valid & ~rd_valid;

  //----------------------------------------------------------------------------
  // Store the payload
  //----------------------------------------------------------------------------

// ACS_off UNRESET_REGISTER Always set before use except for the first slot at the reset case
  reg  [PAYLD_WIDTH-1:0]  payld0;  // payload storage register
  reg  [PAYLD_WIDTH-1:0]  payld1;  // payload storage register

  // NOTE: payld0 needs to be reset as that is the default-when-empty selection

  always @(posedge aclk or negedge aresetn)
  begin : p_payld0
    if (!aresetn)
      payld0 <= {PAYLD_WIDTH{1'b0}};
    else if (wr_en[0])
// ACS_off CDC_END Where this register exists, it is an expected CDC endpoint.
      payld0 <= payld_src;
  end

  always @(posedge aclk)
  begin : p_payld1
    if (wr_en[1])
// ACS_off UNRESETTABLE_REGISTER CDC_END Payload rather than control ; Where this register exists, it is an expected CDC endpoint.
      payld1 <= payld_src;
  end

  //----------------------------------------------------------------------------
  // Track occupancy of the payload registers
  //----------------------------------------------------------------------------

  // If the payload register is written, or is occupied and not emptied it will
  // be valid next.
  wire[1:0] rd_valid_nxt = (wr_en | (rd_valid & ~rd_ready));

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_valid_0
    if (!aresetn)
      rd_valid[0] <= 1'b0;
    else
      rd_valid[0] <= rd_valid_nxt[0];
  end

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_valid_1
    if (!aresetn)
      rd_valid[1] <= 1'b0;
    else
      rd_valid[1] <= rd_valid_nxt[1];
  end

  //----------------------------------------------------------------------------
  // Select which register to read from
  //----------------------------------------------------------------------------

  wire rd_sel_upd_en = |(rd_valid & rd_ready);

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_sel
    if (!aresetn)
      rd_sel <= 1'b0;
    else if (rd_sel_upd_en)
      rd_sel <= ~rd_sel;
  end

  //----------------------------------------------------------------------------
  // Drive payload output
  //----------------------------------------------------------------------------

  // If rd_sel driven high, drive the contents of payld1 onto the output.
  // If rd_sel not driven high, drive the contents of payld0 onto the output.
  assign payld_dst = rd_sel ? payld1 : payld0;

  //----------------------------------------------------------------------------
  // Interface handshake outputs
  //----------------------------------------------------------------------------

  // ready_src when one of the internal registers is not occupied
  assign ready_src = |(~rd_valid);

  // valid_dst when one of the internal registers is occupied
  assign valid_dst = |( rd_valid);

endmodule // cci400_ful_regd_slice
