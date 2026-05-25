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
// File: adb400_r3_dnstrm_payld.v
//-----------------------------------------------------------------------------
// Purpose : The downstream half of an asynchronous-crossing channel with payload.
//-----------------------------------------------------------------------------

module adb400_r3_dnstrm_payld
  #(parameter
      WIDTH            = 32,
      DEPTH            = 8,
      SYNC_LEVELS      = 2,
      CACTIVE_OUTPUT   = 1
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // Clock management signals
    output wire                   cactive,

    // The downstream channel handshake and payload
    output wire                   dst_valid,
    input  wire                   dst_ready,
    output wire [((WIDTH==0)?0:(WIDTH-1)):0] dst_payld,

    // The read/write pointers to/from upstream
    input  wire [DEPTH-1:0]       wr_ptr_async,
    output reg  [DEPTH-1:0]       rd_ptr_async,

    // The payload from upstream
    input  wire [((WIDTH==0)?0:((WIDTH*DEPTH)-1)):0] payld_async
  );

`include "adb400_r3_functions.v"

  genvar j;

  //--------------------------------------------------------------------
  // Synchronise the wr_ptr_async input into this clock domain.
  //--------------------------------------------------------------------

  // Signal for the sync'ed wr_ptr_g
  wire [DEPTH-1:0] wr_ptr_async_s;

  // Instantiate a synchroniser for each bit of the pointer
  generate
    for (j=0; j<DEPTH ; j=j+1)
      begin : g_j
        adb400_r3_syncn
          #(
            .LEVELS (SYNC_LEVELS)
          )
          u_syncn_wr_ptr_async
          (
            .aclk    (aclk),
            .aresetn (aresetn),
            .din     (wr_ptr_async[j]),
            .dout    (wr_ptr_async_s[j])
          );
      end
  endgenerate

  //--------------------------------------------------------------------
  // The read pointer for selecting from the registers
  //--------------------------------------------------------------------

  // Register the local read pointer
  reg  [DEPTH-1:0] rd_ptr_sync;
  wire             rd_ptr_upd_en;

  // Manage the update of the local read pointer
  wire [DEPTH-1:0] rd_ptr_sync_nxt = 
    {rd_ptr_sync[DEPTH-1-1:0],rd_ptr_sync[DEPTH-1]};

  always @(posedge aclk or negedge aresetn)
    begin : p_rd_ptr_sync
      if (!aresetn)
        rd_ptr_sync <= {{DEPTH-1{1'b0}},1'b1};
      else if (rd_ptr_upd_en)
        rd_ptr_sync <= rd_ptr_sync_nxt;
    end

  //--------------------------------------------------------------------
  // The read pointer for communicating occupancy to the other
  // half of the channel.
  //--------------------------------------------------------------------

  assign dst_valid = (|((rd_ptr_async ^ wr_ptr_async_s) & rd_ptr_sync));

  // Update the read pointers when we emit something  or power down
  assign rd_ptr_upd_en = (dst_valid & dst_ready);

  // The next value of the occupancy flag structure
  wire [DEPTH-1:0] rd_ptr_async_nxt = 
    {rd_ptr_async[DEPTH-1-1:0],~rd_ptr_async[DEPTH-1]};

  always @(posedge aclk or negedge aresetn)
    begin : p_rd_ptr_async
      if (!aresetn)
        rd_ptr_async <= {DEPTH{1'b0}};
      else if (rd_ptr_upd_en)
        rd_ptr_async <= rd_ptr_async_nxt;
    end

  //--------------------------------------------------------------------
  // Mux the data out if there is payload
  //--------------------------------------------------------------------

  generate
    if (WIDTH==0)
      begin : g_WIDTH_ez

        assign dst_payld = 1'b0;

      end
    else
      begin : g_WIDTH_nz

        adb400_r3_muxn
          #(
            .CARDINALITY     (DEPTH),
            .WIDTH           (WIDTH)
          )
          u_glitch_free_mux_payload
          (
            .data_i (payld_async),
            .cntrl  (rd_ptr_sync),
            .data_o (dst_payld)
          );

      end

    //--------------------------------------------------------------------
    // The clock requirement indicator
    //--------------------------------------------------------------------

    if (CACTIVE_OUTPUT == 0)
      begin : g_no_cactive
        assign cactive = 1'b0;
      end
    else
      begin : g_has_cactive
        assign cactive = (rd_ptr_async != wr_ptr_async_s);
      end

  endgenerate

endmodule
