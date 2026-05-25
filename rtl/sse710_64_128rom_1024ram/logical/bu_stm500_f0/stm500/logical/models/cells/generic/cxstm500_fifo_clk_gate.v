//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Gated-clock cell model
//-----------------------------------------------------------------------------

module cxstm500_fifo_clk_gate (
  // Inputs
  input wire  CLK,           // free running clock
  input wire  clk_enable_i,  // clock enable

  // Outputs
  output wire clk_o          // gated clock
  );

`ifdef FPGA

  assign clk_o = CLK & clk_enable_i;

`else

  //----------------------------------------------------------------------------
  // Latch
  //----------------------------------------------------------------------------
  reg clk_en_lat;

  always @ (CLK or clk_enable_i)
    begin
      if (~CLK)
        clk_en_lat <= clk_enable_i;
    end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  assign clk_o = CLK & clk_en_lat;

`endif

endmodule
