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


module nic400_asib_hostexpmst_1_s_decode_sse710_integration_example_f0_host_exp
  (
    addr_s,
    security62,
    security58,
    aprot,
    acache_in,
    acache_out,
    avalid_int,
    aregion_out
  );



  input  [31:0]    addr_s;          
  input            security62;
  input  [15:0]    security58;
  input            aprot;
  input  [3:0]     acache_in;
  output [3:0]     acache_out;
  output [3:0]     avalid_int;
  output [3:0]     aregion_out;




  wire [2:0]       avalid_dec;
  wire [2:0]       decode_int;
  wire [2:0]       remap_decode;
  wire [3:0]       region_int;







  assign decode_int[0] = (32'h60000000 <= addr_s) && (addr_s <= 32'h6003FFFF);

  assign decode_int[1] = (32'h60040000 <= addr_s) && (addr_s <= 32'h60040FFF);

  assign decode_int[2] = (32'h60050000 <= addr_s) && (addr_s <= 32'h60050FFF);





  assign remap_decode[0] = ~(aprot & security62) & decode_int[0];

  assign remap_decode[1] = ~(aprot & security58[1]) & decode_int[1];

  assign remap_decode[2] = ~(aprot & security58[2]) & decode_int[2];



  assign avalid_dec[0] = (1'b0);
  assign avalid_dec[1] = ((remap_decode[0]));
  assign avalid_dec[2] = ((remap_decode[1] || remap_decode[2]));
  assign avalid_int[3] = (~|avalid_int[2:0]);

  assign avalid_int[2:0] = avalid_dec;


  assign region_int[0] = remap_decode[1];

  assign region_int[1] = remap_decode[2];

  assign region_int[2] = 1'b0;

  assign region_int[3] = 1'b0;





  assign acache_out = acache_in;


  assign aregion_out = region_int;






endmodule

