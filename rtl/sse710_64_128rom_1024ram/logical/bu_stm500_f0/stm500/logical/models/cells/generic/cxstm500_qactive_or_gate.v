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
//      STM500 OR Gate for QACTIVE calculation
//      This file should be replaced with a technology-specific glitch free
//      OR gate during implementation
//-----------------------------------------------------------------------------

module cxstm500_qactive_or_gate (

  input qactive_i,
  input wakeup_i,
  output qactive_o

);


  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------

  wire qactive_int;

  //----------------------------------------------------------------------------
  // Main Body of Code
  //----------------------------------------------------------------------------

  assign qactive_int = qactive_i | wakeup_i;

  //----------------------------------------------------------------------------
  // Output Assignment
  //----------------------------------------------------------------------------

  assign qactive_o = qactive_int;

endmodule


