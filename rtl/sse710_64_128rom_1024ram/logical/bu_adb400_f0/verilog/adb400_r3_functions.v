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
// Checked In :  2016-02-05 16:06:21 +0000 (Fri, 05 Feb 2016)
// Revision : 206461
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_functions.v
//-----------------------------------------------------------------------------
// Purpose : Commonly used functions to include.
//-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Not actually a clogb2 function (does not return strictly the ceiling of log2(x)),
  // instead it is returns the number of bits required to represetn the argument.
  //-----------------------------------------------------------------------------
// ACS_off FUNCTION_VARIABLES Variables declared inside function
  function automatic integer clogb2 (input integer x);
    begin : fn_clogb2
      integer x1;
      x1 = x;
// ACS_off UNEQUAL_WIDTH_OP_ARGS Inequality is in for-loop control
      for (clogb2 = 0; x1 > 0; clogb2 = clogb2 + 1)
      begin
// ACS_off IMPLICIT_TYPE_CONVERSION The LSR operator creates a reg, which is converted back to an int
        x1 = x1 >> 1;
      end
    end
  endfunction // clogb2

