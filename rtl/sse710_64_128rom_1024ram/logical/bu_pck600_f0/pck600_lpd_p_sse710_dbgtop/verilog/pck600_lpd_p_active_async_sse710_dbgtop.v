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

module pck600_lpd_p_active_async_sse710_dbgtop 
(
  input  wire [10:0] dev0_pactive_i,
  input  wire [10:0] dev1_pactive_i,
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





assign ctrl_pactive_o[0] = 1'b0;
assign ctrl_pactive_o[1] = 1'b0;
assign ctrl_pactive_o[2] = 1'b0;
assign ctrl_pactive_o[3] = 1'b0;
assign ctrl_pactive_o[4] = 1'b0;
assign ctrl_pactive_o[5] = 1'b0;
assign ctrl_pactive_o[6] = 1'b0;
assign ctrl_pactive_o[7] = 1'b0;

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (2)
  )
  u_pck600_or_tree_ctrl_pactive_8 
  (
    .or_tree_i ({dev0_pactive_i[8],dev1_pactive_i[8]}),
    .or_tree_o (ctrl_pactive_o[8])
  );
assign ctrl_pactive_o[9] = 1'b0;
assign ctrl_pactive_o[10] = 1'b0;

endmodule
