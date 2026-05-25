//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


module nic400_asib_p1_axis_decode_sse710_dbg3s1m
  (
    addr_s,
    security7,
    aprot,
    acache_in,
    acache_out,
    avalid_int
  );



  input  [31:0]    addr_s;          
  input            security7;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output           avalid_int;











  assign avalid_int = ~(aprot & security7);





  assign acache_out = acache_in;






endmodule

