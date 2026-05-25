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
//   Shared sub-module of css600_pulseasyncbridge
//
//----------------------------------------------------------------------------


module css600_pulseasyncbridgeslv_async #(parameter
  NUM_OR_INPUTS = 2
)
(
  input wire [NUM_OR_INPUTS-1:0] or_inputs,
  input wire                     pwr_qreq_n,
  input wire                     pwr_qaccept_n,
  output wire                    clk_s_qactive,
  output wire                    pwr_qactive
);

  wire                   pulse_or;
  wire                   pwr_xor;

  css600_or_tree #(.NUM_OR_INPUTS(NUM_OR_INPUTS))
    u_css600_or_tree (.or_inputs (or_inputs),
                      .or_output (pulse_or));

  css600_xor u_css600_xor (.in_a  (pwr_qreq_n),
                           .in_b  (pwr_qaccept_n),
                           .out_y (pwr_xor));

  css600_or u_css600_or(.in_a  (pulse_or),
                        .in_b  (pwr_xor),
                        .out_y (clk_s_qactive));

  assign pwr_qactive  = pulse_or;

endmodule


