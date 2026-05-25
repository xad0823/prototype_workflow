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


module pck600_or_tree
#(
  parameter NUM_OR_TREE_INPUTS = 1
)
(
  input  wire [NUM_OR_TREE_INPUTS-1:0] or_tree_i,
  output wire                          or_tree_o
);


  localparam ODD_INPUTS = NUM_OR_TREE_INPUTS % 2;

  localparam NUM_FIRST_STAGE_GATES = (ODD_INPUTS == 0)? (NUM_OR_TREE_INPUTS/2):
                                                        ((NUM_OR_TREE_INPUTS-1)/2);
  localparam NUM_OR_GATES = (NUM_OR_TREE_INPUTS == 1)? 0:
                                     ((ODD_INPUTS == 0)? (NUM_OR_TREE_INPUTS - 1):
                                                         (NUM_OR_TREE_INPUTS - 2));


  genvar                      I;

  wire [NUM_OR_GATES:0]       or_tree;



generate
if(NUM_OR_TREE_INPUTS > 1)
begin:include_or_tree

  for(I=0; I<NUM_FIRST_STAGE_GATES; I=I+1)
  begin:first_stage_or_gates

    pck600_std_or2
    u_pck600_std_or2
    (
      .A  (or_tree_i[I*2]),
      .B  (or_tree_i[I*2+1]),
      .Y  (or_tree[I])
    );

  end

  for(I=NUM_FIRST_STAGE_GATES; I<NUM_OR_GATES; I=I+1)
  begin:remaining_stage_or_gates

    pck600_std_or2
    u_pck600_std_or2
    (
      .A  (or_tree[(I-NUM_FIRST_STAGE_GATES)*2]),
      .B  (or_tree[(I-NUM_FIRST_STAGE_GATES)*2+1]),
      .Y  (or_tree[I])
    );

  end

  if(ODD_INPUTS)
  begin:odd_inputs

    pck600_std_or2
    u_pck600_std_or2
    (
      .A  (or_tree[NUM_OR_GATES-1]),
      .B  (or_tree_i[NUM_OR_TREE_INPUTS-1]),
      .Y  (or_tree[NUM_OR_GATES])
    );

  end
  else
  begin:even_inputs

    assign or_tree[NUM_OR_GATES] = or_tree[NUM_OR_GATES-1];

  end
end
else
begin:exclude_or_tree

  assign or_tree[NUM_OR_GATES] = or_tree_i[0];

end
endgenerate


  assign or_tree_o = or_tree[NUM_OR_GATES];

endmodule

