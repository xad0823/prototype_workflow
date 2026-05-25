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
//      Revision            : $Revision$
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Synchronizer for STM500
//-----------------------------------------------------------------------------

module cxstm500_synchronizer (

  input CLK,
  input RESETn,
  input sync_i,
  output sync_o
);

  //----------------------------------------------------------------------------
  // Registers
  //----------------------------------------------------------------------------

  reg sync_int_reg;
  reg sync_int_reg2;

  //----------------------------------------------------------------------------
  // Main Body of Code
  //----------------------------------------------------------------------------

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn)
      sync_int_reg <= 1'b0;
    else
      sync_int_reg <= sync_i;
  end

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn)
      sync_int_reg2 <= 1'b0;
    else
      sync_int_reg2 <= sync_int_reg;
  end

  //----------------------------------------------------------------------------
  // Output Assignment
  //----------------------------------------------------------------------------

  assign sync_o = sync_int_reg2;

endmodule




