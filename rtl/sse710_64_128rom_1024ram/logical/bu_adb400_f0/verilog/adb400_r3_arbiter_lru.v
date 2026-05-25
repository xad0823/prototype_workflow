//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2010-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-07 15:31:26 +0000 (Sun, 07 Feb 2016)
// Revision : 206510
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_arbiter_lru.v
//-----------------------------------------------------------------------------
// Purpose : LRU arbiter
//
//   The arbiter selects the Least Recently Used (LRU) input that is valid.
//
// Usage :
//   The actual select used at a given moment needs to be fed back into the
//   arbiter on select_i so that along with ready_i the LRU arbitration can be
//   updated.
//-----------------------------------------------------------------------------

module adb400_r3_arbiter_lru
  //---------------------------------------------------------------------------
  // Parameters (for ports or related)
  //---------------------------------------------------------------------------
  #(parameter WAYS = 6)


  //---------------------------------------------------------------------------
  // Ports
  //---------------------------------------------------------------------------
  (
    input   wire                        aclk,
    input   wire                        aresetn,
    input   wire  [WAYS-1:0]            request_i,
    input   wire  [WAYS-1:0]            select_i,
    input   wire                        ready_i,

    output  wire  [WAYS-1:0]            select_o
  );


  //---------------------------------------------------------------------------
  // Signal declarations
  //---------------------------------------------------------------------------

  genvar i;
  genvar j;
  genvar a;
  genvar b;

  wire [WAYS-1:0]   mru;

  wire [WAYS-1-1:0]   sel   [WAYS-1:0];


  //---------------------------------------------------------------------------
  // Functional code
  //---------------------------------------------------------------------------

  // Set MRU (most recently used) flag
  assign mru = ready_i ? select_i : {WAYS{1'b0}};

  generate

    // sel[A][B] is a 2D array of 1-bit flags indicating whether to select
    // input A over input B.  Input A is selected over input B in the following
    // circumstances.
    // * B isn't being requested
    // * A is the LRU (least recently used)
    for (a=1; a<WAYS; a=a+1)
      begin: g_sel_outer
        for (b=0; b<a; b=b+1)
          begin: g_sel_inner

            reg    lru;
            wire   lru_up_en;

            // Update the LRU flag if it relates to the MRU input in any way
            assign lru_up_en = mru[a] | mru[b];

            always @(posedge aclk or negedge aresetn)
              begin: p_lru_seq
                // Set the LRU flag at reset to default to priority based
                // arbitration (higher numbered input has priority)
                if (!aresetn)
                  lru <= 1'b1;
                // Clear the flag if the input A is the MRU input
                // Set the flag if the input B is the MRU input
                else if (lru_up_en)
                  lru <= mru[b];
              end // p_lru_seq

            assign sel   [a][b] = ~request_i[b] | (request_i[a] & lru);
            // Create the transpose of the entries in the other half of the rectangle. The
            // transpose half is shifted left one column.
            assign sel   [b][a-1] = ~sel[a][b];

          end // g_sel_inner
      end // g_sel_outer

    for (j=0 ; j<WAYS ; j=j+1)
      begin : g_ways
        if (WAYS <= 2)
          begin : g_WAYS_le_2
            assign select_o[j] = (request_i[j] & sel[j]);
          end
        else
          begin : g_WAYS_gt_2
            assign select_o[j] = (request_i[j] & (&(sel[j])));
          end
      end

  endgenerate

endmodule
