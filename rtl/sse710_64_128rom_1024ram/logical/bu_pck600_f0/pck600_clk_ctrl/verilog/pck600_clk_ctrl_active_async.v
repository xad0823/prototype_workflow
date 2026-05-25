// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_clk_ctrl_active_async
#(
  parameter NUM_QACTIVE = 1
)
(

  input  wire [NUM_QACTIVE-1:0] clk_qactive_async_i,

  input  wire                 pwr_qreqn_async_i,

  input  wire                 pwr_qacceptn_i,

  input  wire                 pwr_qdeny_i,

  output wire                 hc_qactive_o,

  output wire                 pwr_qactive_o

);


  wire                        int_pwr_qactive;

  wire                        pwr_qreqn_qacceptn_xor;

  wire                        pwr_qreqn_qacceptn_qdeny_or;



  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (NUM_QACTIVE)
  )
  u_pck600_or_tree
  (
    .or_tree_i  (clk_qactive_async_i),
    .or_tree_o  (int_pwr_qactive)
  );


  pck600_std_xor2
  u_pck600_xor2_pwrqreqn
  (
    .A  (pwr_qreqn_async_i),
    .B  (pwr_qacceptn_i),
    .Y  (pwr_qreqn_qacceptn_xor)
  );

  pck600_std_or2
  u_pck600_or2_pwr_qreqn_qacceptn_qdeny
  (
    .A  (pwr_qreqn_qacceptn_xor),
    .B  (pwr_qdeny_i),
    .Y  (pwr_qreqn_qacceptn_qdeny_or)
  );

  pck600_std_or2
  u_pck600_or2_hcqactive
  (
    .A  (int_pwr_qactive),
    .B  (pwr_qreqn_qacceptn_qdeny_or),
    .Y  (hc_qactive_o)
  );


  assign pwr_qactive_o = 1'b0;

endmodule

