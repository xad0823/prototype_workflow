//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2004, 2012, 2014, 2016 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_trace_clk
(
  input  wire    traceclk_in,
  input  wire    treset_n,
  output  reg    traceclk
);

  wire nxt_traceclk;


  assign nxt_traceclk = ~traceclk;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : p_traceclk
    if (!treset_n)
      traceclk <= 1'b0;
    else
      traceclk <= nxt_traceclk;
  end

endmodule

