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


module nic400_asib_gpvmain_ahb_decode_sse710_main
  (
    addr_s,
    security,
    aprot,
    acache_in,
    acache_out,
    avalid_int
  );



  input  [31:0]    addr_s;          
  input            security;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [1:0]     avalid_int;




  wire             avalid_dec;
  wire             decode_int;
  wire             remap_decode;







  assign decode_int = (32'h1E000000 <= addr_s) && (addr_s <= 32'h1E0FFFFF);





  assign remap_decode = ~(aprot & security) & decode_int;



  assign avalid_dec = ((remap_decode));
  assign avalid_int[1] = (~avalid_int[0]);

  assign avalid_int[0] = avalid_dec;





  assign acache_out = acache_in;






endmodule

