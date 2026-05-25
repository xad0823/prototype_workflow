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


module pck600_lpc_q_active_async
#(
  parameter NUM_CTRL_Q_CHL = 2,
  parameter NUM_DEV_Q_CHL = 1
)
(
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qactive_i,


  input  wire [NUM_CTRL_Q_CHL-1:0] ctrl_qreqn_i,
  input  wire [NUM_CTRL_Q_CHL-1:0] ctrl_qacceptn_i,

  input  wire                      clk_qactive_syn_i,

  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qactive_o,

  output wire                      clk_qactive_o

);


  genvar I;

  wire                        int_ctrl_qactive;

  wire                        int_clk_qactive;

  wire [NUM_CTRL_Q_CHL-1:0]   qreqn_qacceptn_xor;



  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (NUM_DEV_Q_CHL)
  )
  u_pck600_or_tree_ctrl_qactive
  (
    .or_tree_i  (dev_qactive_i),
    .or_tree_o  (int_ctrl_qactive)
  );


generate
for(I=0; I<NUM_CTRL_Q_CHL; I=I+1)
begin:ctrl_qreqn_qaccept_xor_loop

  pck600_std_xor2
  u_pck600_xor2_qreqn_qacceptn
  (
    .A  (ctrl_qreqn_i[I]),
    .B  (ctrl_qacceptn_i[I]),
    .Y  (qreqn_qacceptn_xor[I])
  );

end
endgenerate

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (NUM_CTRL_Q_CHL)
  )
  u_pck600_or_tree_clk_qactive
  (
    .or_tree_i  (qreqn_qacceptn_xor),
    .or_tree_o  (int_clk_qactive)
  );

  pck600_std_or2
  u_pck600_or2_clk_qactive
  (
    .A  (clk_qactive_syn_i),
    .B  (int_clk_qactive),
    .Y  (clk_qactive_o)
  );


  assign ctrl_qactive_o[NUM_CTRL_Q_CHL-1:0] = {NUM_CTRL_Q_CHL{int_ctrl_qactive}};

endmodule
