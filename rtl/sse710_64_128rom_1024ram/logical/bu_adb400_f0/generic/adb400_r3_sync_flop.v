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
// File: adb400_r3_sync_flop.v
//-----------------------------------------------------------------------------
// Purpose : The default, synthesiser-inferred implementation of a 1-bit
//           synchroniser flop.
//-----------------------------------------------------------------------------

module adb400_r3_sync_flop
  (
    input  wire aclk,
    input  wire aresetn,
    input  wire din,
    output reg  dout
  );

  // An edge-sensitive register is inferred from
  // this code.
  always @(posedge aclk or negedge aresetn)
    begin : p_sync_flop_cell
      if (!aresetn)
        dout <= 1'b0;
      else
// ACS_off CDC_END This is where the CDC is supposed to be from
        dout <= din;
    end

endmodule
