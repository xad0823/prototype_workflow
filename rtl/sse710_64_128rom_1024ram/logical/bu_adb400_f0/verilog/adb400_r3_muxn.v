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
// File: adb400_r3_muxn.v
//-----------------------------------------------------------------------------
// Purpose : A N-input M-way structurally composed multiplexer.
//-----------------------------------------------------------------------------


module adb400_r3_muxn
  #(parameter
      CARDINALITY     = 8,
      WIDTH           = 32
  )
  (
    input  wire [(CARDINALITY*WIDTH)-1:0]   data_i,
    input  wire [CARDINALITY-1:0]           cntrl,
    output wire [WIDTH-1:0]                 data_o
  );
 
`include "adb400_r3_functions.v"

  genvar i, j, k;

  // The data are passed in as a concatenation of all CARDINALITY off WIDTH-way vectors.

  // Vector array of WIDTH off CARDINALITY-way values each of which is reduced to a
  // single bit for output.
  wire [CARDINALITY-1:0] data_i_filtered_t [WIDTH-1:0];

  generate
    for (i=0 ; i<CARDINALITY ; i=i+1)
      begin : g_i
        for (j=0 ; j<WIDTH ; j=j+1)
          begin : g_j
            // Instantiate (CARDINALITY*WIDTH) NAND gates to filter out changes to bits not
            // being considered. These must be protected in the netlist to maintain functional
            // integrity.
            adb400_r3_nand2 u_nand_keep
              (
               .din0 (data_i[(i*WIDTH)+j]),
               .din1 (cntrl[i]),
               .dout (data_i_filtered_t[j][i])
              );    
          end
      end

    for (k=0 ; k<WIDTH ; k=k+1)
      begin : g_k
        assign data_o[k] = ~(&(data_i_filtered_t[k]));
      end 
  endgenerate
  
endmodule
