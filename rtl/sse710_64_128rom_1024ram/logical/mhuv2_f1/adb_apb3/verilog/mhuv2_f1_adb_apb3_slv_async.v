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

module mhuv2_f1_adb_apb3_slv_async
#(
   parameter [6:0] MHU_NUM_CH        = 7'd1
)(

  input wire                    recawake_async_i,
  input wire [MHU_NUM_CH-1:0] edge_async_req_i,

  input wire                    pwakeup_i,
  input wire                    recawake_async_sss_i,
  input wire                    recawake_async_ssss_i,

  output wire                   pclksqactive_o
);


  wire                        recawake_xor0;
  wire                        recawake_xor1;


  mhuv2_f1_adb_xor2
  u_mhuv2_f1_adb_xor2_0
  (
    .A  (recawake_async_i),
    .B  (recawake_async_sss_i),
    .Y  (recawake_xor0)
  );
  
  mhuv2_f1_adb_xor2
  u_mhuv2_f1_adb_xor2_1
  (
    .A  (recawake_async_sss_i),
    .B  (recawake_async_ssss_i),
    .Y  (recawake_xor1)
  );  

  mhuv2_f1_adb_or_tree #(
    .NUM_OR_TREE_INPUTS ({25'h0, MHU_NUM_CH} + 3)
  ) u_mhuv2_f1_adb_or_tree (
    .or_tree_i  ({recawake_xor1, recawake_xor0, pwakeup_i, edge_async_req_i}),
    .or_tree_o  (pclksqactive_o)
  );

endmodule
