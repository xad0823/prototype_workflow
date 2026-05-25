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

module pck600_lpd_p_active_async_sse710_clustop 
(
  input  wire [10:0] dev0_pactive_i,
  input  wire [10:0] dev1_pactive_i,
  input  wire [10:0] dev2_pactive_i,
  input  wire [10:0] dev3_pactive_i,
  output wire [10:0] ctrl_pactive_o,

  input  wire       int_clken_i,
  input  wire       ctrl_preq_i,
  output wire       clk_qactive_o
);


  pck600_std_or2
  u_pck600_or2_clk_qactive
  (
    .A  (int_clken_i),
    .B  (ctrl_preq_i),
    .Y  (clk_qactive_o)
  );






  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_0 
  (
    .or_tree_i ({dev0_pactive_i[0],dev1_pactive_i[0],dev2_pactive_i[0],dev3_pactive_i[0]}),
    .or_tree_o (ctrl_pactive_o[0])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_1 
  (
    .or_tree_i ({dev0_pactive_i[1],dev1_pactive_i[1],dev2_pactive_i[1],dev3_pactive_i[1]}),
    .or_tree_o (ctrl_pactive_o[1])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_2 
  (
    .or_tree_i ({dev0_pactive_i[2],dev1_pactive_i[2],dev2_pactive_i[2],dev3_pactive_i[2]}),
    .or_tree_o (ctrl_pactive_o[2])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_3 
  (
    .or_tree_i ({dev0_pactive_i[3],dev1_pactive_i[3],dev2_pactive_i[3],dev3_pactive_i[3]}),
    .or_tree_o (ctrl_pactive_o[3])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_4 
  (
    .or_tree_i ({dev0_pactive_i[4],dev1_pactive_i[4],dev2_pactive_i[4],dev3_pactive_i[4]}),
    .or_tree_o (ctrl_pactive_o[4])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_5 
  (
    .or_tree_i ({dev0_pactive_i[5],dev1_pactive_i[5],dev2_pactive_i[5],dev3_pactive_i[5]}),
    .or_tree_o (ctrl_pactive_o[5])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_6 
  (
    .or_tree_i ({dev0_pactive_i[6],dev1_pactive_i[6],dev2_pactive_i[6],dev3_pactive_i[6]}),
    .or_tree_o (ctrl_pactive_o[6])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_7 
  (
    .or_tree_i ({dev0_pactive_i[7],dev1_pactive_i[7],dev2_pactive_i[7],dev3_pactive_i[7]}),
    .or_tree_o (ctrl_pactive_o[7])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_8 
  (
    .or_tree_i ({dev0_pactive_i[8],dev1_pactive_i[8],dev2_pactive_i[8],dev3_pactive_i[8]}),
    .or_tree_o (ctrl_pactive_o[8])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_9 
  (
    .or_tree_i ({dev0_pactive_i[9],dev1_pactive_i[9],dev2_pactive_i[9],dev3_pactive_i[9]}),
    .or_tree_o (ctrl_pactive_o[9])
  );

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (4)
  )
  u_pck600_or_tree_ctrl_pactive_10 
  (
    .or_tree_i ({dev0_pactive_i[10],dev1_pactive_i[10],dev2_pactive_i[10],dev3_pactive_i[10]}),
    .or_tree_o (ctrl_pactive_o[10])
  );

endmodule
