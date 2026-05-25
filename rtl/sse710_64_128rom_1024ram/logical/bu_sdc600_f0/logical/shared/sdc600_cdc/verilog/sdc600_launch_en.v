//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Feb 15 13:50:35 2018 +0000
//
//      Revision            : 5715c65
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_launch_en #(
      parameter DATA_WIDTH = 1
   ) (
      input  wire                  clk,
      input  wire                  reset_n,
      input  wire                  en,
      input  wire [DATA_WIDTH-1:0] d,
      output wire [DATA_WIDTH-1:0] q
   );


  sdc600_flop_en #(
     .DATA_WIDTH(DATA_WIDTH)
  ) u_flop_sample (
    .clk(clk),
    .reset_n(reset_n),
    .en(en),
    .d(d),
    .q(q)
  );


endmodule
