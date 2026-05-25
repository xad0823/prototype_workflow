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

module arm_element_or_tree
#(
  parameter NUM_OR_TREE_INPUTS = 1 
)
(
  input  wire [NUM_OR_TREE_INPUTS-1:0] or_tree_i,
  output wire                          or_tree_o
);

generate
if (NUM_OR_TREE_INPUTS > 1)
begin : include_or_tree

  localparam ODD_INPUTS = NUM_OR_TREE_INPUTS % 2;

  localparam NUM_STAGE1_TERMS = (ODD_INPUTS==1) ? NUM_OR_TREE_INPUTS-1 :
                                                  NUM_OR_TREE_INPUTS;

  localparam NUM_STAGE1_GATES = NUM_STAGE1_TERMS / 2;

  localparam NUM_LOOP_OR_GATES = NUM_STAGE1_TERMS - 1;

  wire [NUM_STAGE1_TERMS-1:0] stage1_in;

  wire [NUM_LOOP_OR_GATES-1:0] or_tree;

  if (ODD_INPUTS)
  begin : add_odd_term_or_gate
  

    arm_element_std_or2 u_arm_element_std_or2
    (
      .A (or_tree_i[NUM_OR_TREE_INPUTS-1]),
      .B (or_tree_i[NUM_OR_TREE_INPUTS-2]),
      .Y (stage1_in[NUM_STAGE1_TERMS-1])
    );
    
    assign stage1_in[NUM_STAGE1_TERMS-2:0] = or_tree_i[NUM_STAGE1_TERMS-2:0];
    
  end 
  else
  begin : no_extra_gates
    
    assign stage1_in[NUM_STAGE1_TERMS-1:0] = or_tree_i[NUM_STAGE1_TERMS-1:0];
    
  end 

  genvar I;

  for (I=0; I<NUM_STAGE1_GATES; I=I+1)
  begin : or_tree_stage_1

    arm_element_std_or2 u_arm_element_std_or2
    (
      .A (stage1_in[I*2]),
      .B (stage1_in[(I*2)+1]),
      .Y (or_tree[I])
    );

  end 

  for (I=NUM_STAGE1_GATES; I<NUM_LOOP_OR_GATES; I=I+1)
  begin : or_tree_stage_2

    arm_element_std_or2 u_arm_element_std_or2
    (
      .A (or_tree[(I-NUM_STAGE1_GATES)*2]),
      .B (or_tree[((I-NUM_STAGE1_GATES)*2)+1]),
      .Y (or_tree[I])
    );

  end 

  assign or_tree_o = or_tree[NUM_LOOP_OR_GATES-1];

end 
else
begin : exclude_or_tree

  assign or_tree_o = or_tree_i;

end 
endgenerate

endmodule
