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


module nic400_asib_sysperi_axis_decode_sse710_sys_apb
  (
    addr_s,
    security57,
    security63,
    security58,
    security62,
    security60,
    security61,
    aprot,
    acache_in,
    acache_out,
    avalid_int,
    aregion_out
  );



  input  [31:0]    addr_s;          
  input            security57;
  input            security63;
  input  [15:0]    security58;
  input            security62;
  input  [15:0]    security60;
  input            security61;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [6:0]     avalid_int;
  output [3:0]     aregion_out;




  wire [5:0]       avalid_dec;
  wire [22:0]      decode_int;
  wire [22:0]      remap_decode;
  wire [3:0]       region_int;
  wire             ahb_target;







  assign decode_int[0] = (32'h1BC00000 <= addr_s) && (addr_s <= 32'h1BC4FFFF);

  assign decode_int[1] = (32'h1C010000 <= addr_s) && (addr_s <= 32'h1C010FFF);

  assign decode_int[2] = (32'h1B830000 <= addr_s) && (addr_s <= 32'h1B830FFF);

  assign decode_int[3] = (32'h1D000000 <= addr_s) && (addr_s <= 32'h1DFFFFFF);

  assign decode_int[4] = (32'h1B900000 <= addr_s) && (addr_s <= 32'h1B900FFF);

  assign decode_int[5] = (32'h1B000000 <= addr_s) && (addr_s <= 32'h1B000FFF);

  assign decode_int[6] = (32'h1B800000 <= addr_s) && (addr_s <= 32'h1B800FFF);

  assign decode_int[7] = (32'h1B810000 <= addr_s) && (addr_s <= 32'h1B810FFF);

  assign decode_int[8] = (32'h1B820000 <= addr_s) && (addr_s <= 32'h1B820FFF);

  assign decode_int[9] = (32'h10000000 <= addr_s) && (addr_s <= 32'h11FFFFFF);

  assign decode_int[10] = (32'h1B010000 <= addr_s) && (addr_s <= 32'h1B010FFF);

  assign decode_int[11] = (32'h1B020000 <= addr_s) && (addr_s <= 32'h1B020FFF);

  assign decode_int[12] = (32'h1B030000 <= addr_s) && (addr_s <= 32'h1B030FFF);

  assign decode_int[13] = (32'h1B040000 <= addr_s) && (addr_s <= 32'h1B040FFF);

  assign decode_int[14] = (32'h1B050000 <= addr_s) && (addr_s <= 32'h1B050FFF);

  assign decode_int[15] = (32'h1B060000 <= addr_s) && (addr_s <= 32'h1B060FFF);

  assign decode_int[16] = (32'h1B070000 <= addr_s) && (addr_s <= 32'h1B070FFF);

  assign decode_int[17] = (32'h1C02F000 <= addr_s) && (addr_s <= 32'h1C030FFF);

  assign decode_int[18] = (32'h1C04F000 <= addr_s) && (addr_s <= 32'h1C050FFF);

  assign decode_int[19] = (32'h1C06F000 <= addr_s) && (addr_s <= 32'h1C070FFF);

  assign decode_int[20] = (32'h12000000 <= addr_s) && (addr_s <= 32'h123FFFFF);

  assign decode_int[21] = (32'h1E000000 <= addr_s) && (addr_s <= 32'h1E0FFFFF);

  assign decode_int[22] = (32'h13000000 <= addr_s) && (addr_s <= 32'h133FFFFF);





  assign remap_decode[0] = ~(aprot & security57) & decode_int[0];

  assign remap_decode[1] = ~(aprot & security63) & decode_int[1];

  assign remap_decode[2] = ~(aprot & security63) & decode_int[17];

  assign remap_decode[3] = ~(aprot & security63) & decode_int[18];

  assign remap_decode[4] = ~(aprot & security63) & decode_int[19];

  assign remap_decode[5] = ~(aprot & security58[3]) & decode_int[2];

  assign remap_decode[6] = ~(aprot & security58[4]) & decode_int[5];

  assign remap_decode[7] = ~(aprot & security58[0]) & decode_int[6];

  assign remap_decode[8] = ~(aprot & security58[1]) & decode_int[7];

  assign remap_decode[9] = ~(aprot & security58[2]) & decode_int[8];

  assign remap_decode[10] = ~(aprot & security58[5]) & decode_int[10];

  assign remap_decode[11] = ~(aprot & security58[6]) & decode_int[11];

  assign remap_decode[12] = ~(aprot & security58[7]) & decode_int[12];

  assign remap_decode[13] = ~(aprot & security58[8]) & decode_int[13];

  assign remap_decode[14] = ~(aprot & security58[9]) & decode_int[14];

  assign remap_decode[15] = ~(aprot & security58[10]) & decode_int[15];

  assign remap_decode[16] = ~(aprot & security58[11]) & decode_int[16];

  assign remap_decode[17] = ~(aprot & security62) & decode_int[3];

  assign remap_decode[18] = ~(aprot & security60[1]) & decode_int[4];

  assign remap_decode[19] = ~(aprot & security60[0]) & decode_int[9];

  assign remap_decode[20] = ~(aprot & security60[0]) & decode_int[20];

  assign remap_decode[21] = ~(aprot & security60[0]) & decode_int[22];

  assign remap_decode[22] = ~(aprot & security61) & decode_int[21];



  assign avalid_dec[0] = ((remap_decode[1] || remap_decode[2] || remap_decode[3] || remap_decode[4]));
  assign avalid_dec[1] = ((remap_decode[17]));
  assign avalid_dec[2] = ((remap_decode[0]));
  assign avalid_dec[3] = ((remap_decode[22]));
  assign avalid_dec[4] = ((remap_decode[5] || remap_decode[6] || remap_decode[7] || remap_decode[8] || remap_decode[9] || remap_decode[10] || remap_decode[11] || remap_decode[12] || remap_decode[13] || remap_decode[14] || remap_decode[15] || remap_decode[16]));
  assign avalid_dec[5] = ((remap_decode[18] || remap_decode[19] || remap_decode[20] || remap_decode[21]));
  assign avalid_int[6] = (~|avalid_int[5:0]);

  assign avalid_int[5:0] = avalid_dec;


  assign region_int[0] = remap_decode[5] | remap_decode[8] | remap_decode[10]
                       | remap_decode[12] | remap_decode[14] | remap_decode[16]
                       | remap_decode[18];

  assign region_int[1] = remap_decode[5] | remap_decode[9] | remap_decode[11]
                       | remap_decode[12] | remap_decode[15] | remap_decode[16];

  assign region_int[2] = remap_decode[6] | remap_decode[10] | remap_decode[11]
                       | remap_decode[12];

  assign region_int[3] = remap_decode[13] | remap_decode[14] | remap_decode[15]
                       | remap_decode[16];





  assign acache_out[3] = (ahb_target) ? 1'b0 : acache_in[3];
  assign acache_out[2] = (ahb_target) ? acache_in[1] : acache_in[2];
  assign acache_out[1] = (ahb_target) ? 1'b0 : acache_in[1];
  assign acache_out[0] = acache_in[0];

  assign ahb_target    = avalid_int[3];


  assign aregion_out = region_int;






endmodule

