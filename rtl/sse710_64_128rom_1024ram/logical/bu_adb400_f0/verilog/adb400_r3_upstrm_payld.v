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
// File: adb400_r3_upstrm_payld.v
//-----------------------------------------------------------------------------
// Purpose : The upstream half of an asynchronous-crossing channel with payload.
//-----------------------------------------------------------------------------

module adb400_r3_upstrm_payld
  #(parameter
      WIDTH = 32,
      DEPTH = 8,
      SYNC_LEVELS = 2,
      CACTIVE_OUTPUT   = 1
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // Clock and power management signals
    output wire                   cactive,

    // The upstream channel handshake and payload
    input  wire                   src_valid,
    output wire                   src_ready,
    input  wire [((WIDTH==0)?0:(WIDTH-1)):0] src_payld,

    // The read/write pointers to/from downstream
    output reg  [DEPTH-1:0]       wr_ptr_async,
    input  wire [DEPTH-1:0]       rd_ptr_async,

    // The payload to downstream
    output wire [((WIDTH==0)?0:((WIDTH*DEPTH)-1)):0] payld_async
  );

  genvar i, j;

  //--------------------------------------------------------------------
  // Synchronise the rd_ptr_async input into this clock domain.
  //--------------------------------------------------------------------

  // Signal for the sync'ed rd_ptr_g
  wire [DEPTH-1:0] rd_ptr_async_s;

  // Instantiate a synchroniser for each bit of the pointer
  generate
    for (j=0; j<DEPTH ; j=j+1)
      begin : g_j
        adb400_r3_syncn
          #(
            .LEVELS (SYNC_LEVELS)
          )
          u_syncn_rd_ptr_async
          (
            .aclk    (aclk),
            .aresetn (aresetn),
            .din     (rd_ptr_async[j]),
            .dout    (rd_ptr_async_s[j])
          );
      end
  endgenerate

  //--------------------------------------------------------------------
  // The write pointer for updating the registers
  //--------------------------------------------------------------------

  reg  [DEPTH-1:0] wr_ptr_sync;
  wire             wr_ptr_upd_en;

  // Manage the update of the local write pointer
  wire [DEPTH-1:0] wr_ptr_sync_nxt = 
    {wr_ptr_sync[DEPTH-1-1:0],wr_ptr_sync[DEPTH-1]};

  always @(posedge aclk or negedge aresetn)
    begin : p_wr_ptr_sync
      if (!aresetn)
        wr_ptr_sync <= {{DEPTH-1{1'b0}},1'b1};
      else if (wr_ptr_upd_en)
        wr_ptr_sync <= wr_ptr_sync_nxt;
    end

  //--------------------------------------------------------------------
  // The write pointer for communicating occupancy to the other
  // half of the channel.
  //--------------------------------------------------------------------

  assign src_ready = ~(|((wr_ptr_async ^ rd_ptr_async_s) & wr_ptr_sync));

  // Update the write pointers when we handshake or we power down
  assign wr_ptr_upd_en = (src_ready & src_valid);

  // The next value of the occupancy flag structure
  wire [DEPTH-1:0] wr_ptr_async_nxt = 
    {wr_ptr_async[DEPTH-1-1:0],~wr_ptr_async[DEPTH-1]};

  always @(posedge aclk or negedge aresetn)
    begin : p_wr_ptr_async
      if (!aresetn)
        wr_ptr_async <= {DEPTH{1'b0}};
      else if (wr_ptr_upd_en)
        wr_ptr_async <= wr_ptr_async_nxt;
    end

  //--------------------------------------------------------------------
  // Update the FIFO slots if there is payload
  //--------------------------------------------------------------------

  generate
    if (WIDTH==0)
      begin : g_WIDTH_ez

        assign payld_async = 1'b0;

      end
    else
      begin : g_WIDTH_nz

        // The registers the data is stored in
// ACS_off UNRESET_REGISTER Validity is explicitly indicated
        reg  [WIDTH-1:0] data [DEPTH-1:0];
  
        // Enable writes to one slot if appropriate
        wire [DEPTH-1:0] wr_en = (wr_ptr_upd_en ? wr_ptr_sync : {DEPTH{1'b0}});
  
        for (i=0 ; i<DEPTH ; i=i+1)
          begin : g_i_reg
            assign payld_async [(WIDTH*i)+:WIDTH] = data[i];

            // FIFO *payload* contents needs no reset as always written before reading.
            always @(posedge aclk)
              begin : p_data_no_rst
                if (wr_en[i])
// ACS_off UNRESETTABLE_REGISTER Payload rather than control
                  data[i] <= src_payld;
              end
          end
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
        assign cactive = (rd_ptr_async_s != wr_ptr_async);
      end

  endgenerate

endmodule
