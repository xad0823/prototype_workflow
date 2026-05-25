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


module nic400_asib_slave_if1_decode_secenc_f1
  (
    addr_s,
    security61,
    security63,
    aprot,
    acache_in,
    acache_out,
    avalid_int
  );



  input  [31:0]    addr_s;          
  input            security61;
  input            security63;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [2:0]     avalid_int;




  wire [1:0]       avalid_dec;
  wire [2:0]       decode_int;
  wire [2:0]       remap_decode;
  wire             ahb_target;







  assign decode_int[0] = (32'h0 <= addr_s) && (addr_s <= 32'h1FFFF);

  assign decode_int[1] = (32'h30000000 <= addr_s) && (addr_s <= 32'h300FFFFF);

  assign decode_int[2] = (32'h60000000 <= addr_s) && (addr_s <= 32'hDFFFFFFF);





  assign remap_decode[0] = ~(aprot & security61) & decode_int[0];

  assign remap_decode[1] = ~(aprot & security61) & decode_int[1];

  assign remap_decode[2] = ~(aprot & security63) & decode_int[2];



  assign avalid_dec[0] = ((remap_decode[2]));
  assign avalid_dec[1] = ((remap_decode[0] || remap_decode[1]));
  assign avalid_int[2] = (~|avalid_int[1:0]);

  assign avalid_int[1:0] = avalid_dec;





  assign acache_out[3] = (ahb_target) ? 1'b0 : acache_in[3];
  assign acache_out[2] = (ahb_target) ? acache_in[1] : acache_in[2];
  assign acache_out[1] = (ahb_target) ? 1'b0 : acache_in[1];
  assign acache_out[0] = acache_in[0];

  assign ahb_target    = avalid_int[1];






endmodule

