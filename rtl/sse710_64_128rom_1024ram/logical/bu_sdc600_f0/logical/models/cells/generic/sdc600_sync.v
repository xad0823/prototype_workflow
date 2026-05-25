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
//      Checked In          : Mon Feb 19 12:27:52 2018 +0000
//
//      Revision            : bdc4508
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------


module sdc600_sync#(
    parameter FF_SYNC_DEPTH = 2
   )
   (
    input  wire clk,
    input  wire reset_n,
    input  wire d,
    output wire q
   );

  localparam SYNC_DEPTH = (FF_SYNC_DEPTH == 3) ? 3 : 2;

  wire q_meta;

  generate
    if (SYNC_DEPTH == 3) begin: sync_depth_3
      wire q_sync0;
      sdc600_flop  u_flop_meta  (.clk(clk), .reset_n(reset_n), .d(d      ),  .q(q_meta ));
      sdc600_flop  u0_flop_sync (.clk(clk), .reset_n(reset_n), .d(q_meta ),  .q(q_sync0));
      sdc600_flop  u1_flop_sync (.clk(clk), .reset_n(reset_n), .d(q_sync0),  .q(q      ));
    end
    else begin: sync_depth_2
      sdc600_flop  u_flop_meta  (.clk(clk), .reset_n(reset_n), .d(d      ),  .q(q_meta ));
      sdc600_flop  u_flop_sync  (.clk(clk), .reset_n(reset_n), .d(q_meta ),  .q(q      ));
    end
  endgenerate


endmodule
