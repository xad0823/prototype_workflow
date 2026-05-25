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


module pck600_lpd_q_active_async
#(
  parameter NUM_QCHL = 2
)
(
  input  wire [NUM_QCHL-1:0]  dev_qactive_i,

  input wire                  ctrl_qreqn_i,
  input wire                  ctrl_qacceptn_i,
  input wire                  ctrl_qdeny_i,

  output wire                 ctrl_qactive_o,

  output wire                 clk_qactive_o

);


  wire                        xor_ctrl_qreqn_qacceptn;



  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (NUM_QCHL)
  )
  u_pck600_or_tree
  (
    .or_tree_i  (dev_qactive_i),
    .or_tree_o  (ctrl_qactive_o)
  );


  pck600_std_xor2
  u_pck600_xor2_qreqn_qacceptn
  (
    .A  (ctrl_qreqn_i),
    .B  (ctrl_qacceptn_i),
    .Y  (xor_ctrl_qreqn_qacceptn)
  );

  pck600_std_or2
  u_pck600_or2_clk_qactive
  (
    .A  (xor_ctrl_qreqn_qacceptn),
    .B  (ctrl_qdeny_i),
    .Y  (clk_qactive_o)
  );

endmodule

