//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_or_tree
//
//----------------------------------------------------------------------------


module css600_or_tree
#(
  parameter NUM_OR_INPUTS = 2
)
(
  input  wire [NUM_OR_INPUTS-1:0] or_inputs,
  output wire                     or_output
);


  localparam ODD_INPUTS            = NUM_OR_INPUTS % 2;
  localparam NUM_FIRST_STAGE_GATES = (ODD_INPUTS == 0)
                                     ? (NUM_OR_INPUTS  )/2
                                     : (NUM_OR_INPUTS - 1)/2;
  localparam NUM_OR_GATES          = (ODD_INPUTS == 0)
                                     ? NUM_OR_INPUTS - 1
                                     : NUM_OR_INPUTS - 2;


  genvar i;

/* verilator lint_off UNOPTFLAT */
  wire [NUM_OR_GATES-1:0] or_outputs;
/* verilator lint_on UNOPTFLAT */


generate

  for (i=0; i<NUM_FIRST_STAGE_GATES; i=i+1) begin: gen_first_stage

    css600_or u_css600_or (
      .in_a  (or_inputs[ i*2]),
      .in_b  (or_inputs[(i*2)+1]),
      .out_y (or_outputs[i])
    );

  end

  for (i=NUM_FIRST_STAGE_GATES; i<NUM_OR_GATES; i=i+1) begin: gen_remaining

    css600_or u_css600_or (
      .in_a  (or_outputs[ (i - NUM_FIRST_STAGE_GATES)*2]),
      .in_b  (or_outputs[((i - NUM_FIRST_STAGE_GATES)*2)+1]),
      .out_y (or_outputs[  i])
    );
  end

  if (ODD_INPUTS!=0) begin: gen_or_odd
    css600_or u_css600_or (
      .in_a  (or_outputs[NUM_OR_GATES-1 ]),
      .in_b  (or_inputs [NUM_OR_INPUTS-1]),
      .out_y (or_output)
    );

  end
  else begin: gen_final_output
    assign or_output = or_outputs[NUM_OR_GATES-1];
  end

endgenerate

endmodule
