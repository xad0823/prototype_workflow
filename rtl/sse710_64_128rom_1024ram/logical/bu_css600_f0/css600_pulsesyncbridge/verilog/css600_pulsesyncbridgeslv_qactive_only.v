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
//   Shared sub-module of css600_pulsesyncbridge
//
//----------------------------------------------------------------------------


module css600_pulsesyncbridgeslv_qactive_only #(parameter
  WIDTH         = 1
)
(
  clk_s,
  reset_s_n,
  pulse_in,
  pulse_req,
  pulse_ack,
  clk_s_qactive
);

  localparam WIDTH_INT = (WIDTH > 0 && WIDTH < 33) ? WIDTH : 1;


  input  wire                 clk_s;
  input  wire                 reset_s_n;

  input  wire [WIDTH_INT-1:0] pulse_in;

  output wire [WIDTH_INT-1:0] pulse_req;
  input  wire [WIDTH_INT-1:0] pulse_ack;

  output wire                 clk_s_qactive;


  wire [WIDTH_INT-1:0] pulse_in_q_next;
  reg  [WIDTH_INT-1:0] pulse_in_q;
  wire [WIDTH_INT-1:0] pulse_in_pulse;
  wire [WIDTH_INT-1:0] pulse_req_next;
  wire [WIDTH_INT-1:0] pulse_req_int;
  reg  [WIDTH_INT-1:0] pulse_req_q;

  wire [2*WIDTH_INT-1:0] or_inputs;


  assign pulse_in_q_next = pulse_in & ~pulse_req_q & ~pulse_ack;

  always @(posedge clk_s or negedge reset_s_n) begin
    if (!reset_s_n)
      pulse_in_q <= {WIDTH_INT{1'b0}};
    else
      pulse_in_q <= pulse_in_q_next;
  end

  assign pulse_in_pulse = (pulse_in & ~pulse_in_q);
  assign pulse_req_int  = pulse_req_q;

  assign pulse_req_next = (pulse_in_pulse & ~pulse_ack) |
                          (pulse_req_q    & ~pulse_ack);

  always @(posedge clk_s or negedge reset_s_n)
    if (!reset_s_n)
      pulse_req_q <= {WIDTH_INT{1'b0}};
    else
      pulse_req_q <= pulse_req_next;

  assign pulse_req = pulse_req_int;


  assign or_inputs = {pulse_req_q, pulse_ack};

  css600_or_tree #(.NUM_OR_INPUTS(2*WIDTH_INT))
    u_css600_or_tree (.or_inputs (or_inputs),
                      .or_output (clk_s_qactive));

endmodule


