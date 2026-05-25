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


module nic400_asib_sysctrl_axis_decode_sse710_sctrl_apb
  (
    addr_s,
    security63,
    security62,
    aprot,
    acache_in,
    acache_out,
    avalid_int
  );



  input  [31:0]    addr_s;          
  input            security63;
  input            security62;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [2:0]     avalid_int;




  wire [1:0]       avalid_dec;
  wire [11:0]      decode_int;
  wire [11:0]      remap_decode;







  assign decode_int[0] = (32'h1A000000 <= addr_s) && (addr_s <= 32'h1A01FFFF);

  assign decode_int[1] = (32'h1A200000 <= addr_s) && (addr_s <= 32'h1A20FFFF);

  assign decode_int[2] = (32'h1A300000 <= addr_s) && (addr_s <= 32'h1A31FFFF);

  assign decode_int[3] = (32'h1A020000 <= addr_s) && (addr_s <= 32'h1A04FFFF);

  assign decode_int[4] = (32'h1A210000 <= addr_s) && (addr_s <= 32'h1A26FFFF);

  assign decode_int[5] = (32'h1A320000 <= addr_s) && (addr_s <= 32'h1A33FFFF);

  assign decode_int[6] = (32'h1A400000 <= addr_s) && (addr_s <= 32'h1A40FFFF);

  assign decode_int[7] = (32'h1A410000 <= addr_s) && (addr_s <= 32'h1A44FFFF);

  assign decode_int[8] = (32'h1A500000 <= addr_s) && (addr_s <= 32'h1A50FFFF);

  assign decode_int[9] = (32'h1A600000 <= addr_s) && (addr_s <= 32'h1A6FFFFF);

  assign decode_int[10] = (32'h1A510000 <= addr_s) && (addr_s <= 32'h1A510FFF);

  assign decode_int[11] = (32'h1A520000 <= addr_s) && (addr_s <= 32'h1A520FFF);





  assign remap_decode[0] = ~(aprot & security63) & decode_int[0];

  assign remap_decode[1] = ~(aprot & security63) & decode_int[1];

  assign remap_decode[2] = ~(aprot & security63) & decode_int[2];

  assign remap_decode[3] = ~(aprot & security63) & decode_int[3];

  assign remap_decode[4] = ~(aprot & security63) & decode_int[4];

  assign remap_decode[5] = ~(aprot & security63) & decode_int[5];

  assign remap_decode[6] = ~(aprot & security63) & decode_int[6];

  assign remap_decode[7] = ~(aprot & security63) & decode_int[7];

  assign remap_decode[8] = ~(aprot & security63) & decode_int[8];

  assign remap_decode[9] = ~(aprot & security63) & decode_int[9];

  assign remap_decode[10] = ~(aprot & security62) & decode_int[10];

  assign remap_decode[11] = ~(aprot & security62) & decode_int[11];



  assign avalid_dec[0] = ((remap_decode[0] || remap_decode[1] || remap_decode[2] || remap_decode[3] || remap_decode[4] || remap_decode[5] || remap_decode[6] || remap_decode[7] || remap_decode[8] || remap_decode[9]));
  assign avalid_dec[1] = ((remap_decode[10] || remap_decode[11]));
  assign avalid_int[2] = (~|avalid_int[1:0]);

  assign avalid_int[1:0] = avalid_dec;





  assign acache_out = acache_in;






endmodule

