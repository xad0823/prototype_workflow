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


module nic400_asib_debug_axis_decode_sse710_main
  (
    addr_s,
    security63,
    security62,
    security61,
    security55,
    security58,
    security57,
    security60,
    security56,
    security59,
    aprot,
    acache_in,
    acache_out,
    avalid_int
  );



  input  [31:0]    addr_s;          
  input            security63;
  input            security62;
  input            security61;
  input            security55;
  input            security58;
  input            security57;
  input            security60;
  input            security56;
  input            security59;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [9:0]     avalid_int;




  wire [8:0]       avalid_dec;
  wire [18:0]      decode_int;
  wire [18:0]      remap_decode;







  assign decode_int[0] = (32'h0 <= addr_s) && (addr_s <= 32'hFFF);

  assign decode_int[1] = (32'h2000000 <= addr_s) && (addr_s <= 32'h3FFFFFF);

  assign decode_int[2] = (32'h8000000 <= addr_s) && (addr_s <= 32'hFFFFFFF);

  assign decode_int[3] = (32'h40000000 <= addr_s) && (addr_s <= 32'h5FFFFFFF);

  assign decode_int[4] = (32'h60000000 <= addr_s) && (addr_s <= 32'h7FFFFFFF);

  assign decode_int[5] = (32'h80000000 <= addr_s) && (addr_s <= 32'hFFFFFFFF);

  assign decode_int[6] = (32'h1A000000 <= addr_s) && (addr_s <= 32'h1A04FFFF);

  assign decode_int[7] = (32'h1A200000 <= addr_s) && (addr_s <= 32'h1A26FFFF);

  assign decode_int[8] = (32'h1A300000 <= addr_s) && (addr_s <= 32'h1A33FFFF);

  assign decode_int[9] = (32'h1A400000 <= addr_s) && (addr_s <= 32'h1A44FFFF);

  assign decode_int[10] = (32'h1A500000 <= addr_s) && (addr_s <= 32'h1A52FFFF);

  assign decode_int[11] = (32'h1A600000 <= addr_s) && (addr_s <= 32'h1A6FFFFF);

  assign decode_int[12] = (32'h1A800000 <= addr_s) && (addr_s <= 32'h1A9FFFFF);

  assign decode_int[13] = (32'h1B000000 <= addr_s) && (addr_s <= 32'h1B07FFFF);

  assign decode_int[14] = (32'h1B800000 <= addr_s) && (addr_s <= 32'h1B83FFFF);

  assign decode_int[15] = (32'h1B900000 <= addr_s) && (addr_s <= 32'h1B90FFFF);

  assign decode_int[16] = (32'h1BC00000 <= addr_s) && (addr_s <= 32'h1BC4FFFF);

  assign decode_int[17] = (32'h1C000000 <= addr_s) && (addr_s <= 32'h1DFFFFFF);

  assign decode_int[18] = (32'h1E000000 <= addr_s) && (addr_s <= 32'h1E0FFFFF);





  assign remap_decode[0] = ~(aprot & security63) & decode_int[0];

  assign remap_decode[1] = ~(aprot & security62) & decode_int[1];

  assign remap_decode[2] = ~(aprot & security61) & decode_int[2];

  assign remap_decode[3] = ~(aprot & security55) & decode_int[3];

  assign remap_decode[4] = ~(aprot & security58) & decode_int[4];

  assign remap_decode[5] = ~(aprot & security57) & decode_int[5];

  assign remap_decode[6] = ~(aprot & security60) & decode_int[6];

  assign remap_decode[7] = ~(aprot & security60) & decode_int[7];

  assign remap_decode[8] = ~(aprot & security60) & decode_int[8];

  assign remap_decode[9] = ~(aprot & security60) & decode_int[9];

  assign remap_decode[10] = ~(aprot & security60) & decode_int[10];

  assign remap_decode[11] = ~(aprot & security60) & decode_int[11];

  assign remap_decode[12] = ~(aprot & security56) & decode_int[12];

  assign remap_decode[13] = ~(aprot & security59) & decode_int[13];

  assign remap_decode[14] = ~(aprot & security59) & decode_int[14];

  assign remap_decode[15] = ~(aprot & security59) & decode_int[15];

  assign remap_decode[16] = ~(aprot & security59) & decode_int[16];

  assign remap_decode[17] = ~(aprot & security59) & decode_int[17];

  assign remap_decode[18] = ~(aprot & security59) & decode_int[18];



  assign avalid_dec[0] = ((remap_decode[1]));
  assign avalid_dec[1] = ((remap_decode[2]));
  assign avalid_dec[2] = ((remap_decode[3]));
  assign avalid_dec[3] = ((remap_decode[4]));
  assign avalid_dec[4] = ((remap_decode[5]));
  assign avalid_dec[5] = ((remap_decode[13] || remap_decode[14] || remap_decode[15] || remap_decode[16] || remap_decode[17] || remap_decode[18]));
  assign avalid_dec[6] = ((remap_decode[6] || remap_decode[7] || remap_decode[8] || remap_decode[9] || remap_decode[10] || remap_decode[11]));
  assign avalid_dec[7] = ((remap_decode[0]));
  assign avalid_dec[8] = ((remap_decode[12]));
  assign avalid_int[9] = (~|avalid_int[8:0]);

  assign avalid_int[8:0] = avalid_dec;





  assign acache_out = acache_in;






endmodule

