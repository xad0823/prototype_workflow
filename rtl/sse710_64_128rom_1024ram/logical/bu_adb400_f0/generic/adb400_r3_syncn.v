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
// File: adb400_r3_syncn.v
//-----------------------------------------------------------------------------
// Purpose : The default, synthesiser-inferred implementation of an N-level
//           synchroniser structure.
//-----------------------------------------------------------------------------

module adb400_r3_syncn
  #(parameter
      LEVELS           = 2
  )
  (
    input  wire aclk,
    input  wire aresetn,
    input  wire din,
    output wire dout
  );

  wire [LEVELS-1:0] d_int;
      
  // The first resgister in the synchroniser chain,
  // with the asynchronous input.
  adb400_r3_sync_flop u_sync_flop_async
  (
    .aclk    (aclk),
    .aresetn (aresetn),
    .din     (din),
    .dout    (d_int[0])
  );

  genvar i;
  generate
    if (LEVELS>2)
      begin : g_levels_gt_2
        // The other synchronisers in the chain
        for (i=0 ; i<LEVELS-2 ; i=i+1)
          begin : g_i
            adb400_r3_sync_flop u_sync_flop_part
            (
              .aclk    (aclk),
              .aresetn (aresetn),
              .din     (d_int[i]),
              .dout    (d_int[i+1])
            );
          end
      end
  endgenerate
      
  // The last resgister in the synchroniser chain,
  // with a synchronous input.
  adb400_r3_sync_flop u_sync_flop_sync
  (
    .aclk    (aclk),
    .aresetn (aresetn),
    .din     (d_int[LEVELS-2]),
    .dout    (d_int[LEVELS-1])
  );

  assign dout = d_int[LEVELS-1];

endmodule
