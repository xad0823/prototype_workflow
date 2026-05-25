//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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


module css600_pulsesyncbridgeslv #(parameter
  WIDTH         = 1,
  WAKE_ON_PULSE = 1,
  FF_SYNC_DEPTH = 2
)
(
  clk_s,
  reset_s_n,
  pulse_in,
  pulse_req,
  pulse_ack,
  clk_s_qactive,
  pwr_qreq_n,
  pwr_qaccept_n,
  pwr_qactive
);

  localparam WIDTH_INT = (WIDTH > 0 && WIDTH < 33) ? WIDTH : 1;

  localparam WAKE_ON_PULSE_INT = (WAKE_ON_PULSE == 1) ? 1 : 0;

  localparam FF_SYNC_DEPTH_INT = (FF_SYNC_DEPTH == 3) ? 3 : 2;


  input  wire                 clk_s;
  input  wire                 reset_s_n;

  input  wire [WIDTH_INT-1:0] pulse_in;

  output wire [WIDTH_INT-1:0] pulse_req;
  input  wire [WIDTH_INT-1:0] pulse_ack;

  output wire                 clk_s_qactive;

  input  wire                 pwr_qreq_n;
  output reg                  pwr_qaccept_n;
  output wire                 pwr_qactive;


  wire [WIDTH_INT-1:0] pulse_in_q_next;
  reg  [WIDTH_INT-1:0] pulse_in_q;
  wire [WIDTH_INT-1:0] pulse_in_pulse;
  wire [WIDTH_INT-1:0] pulse_req_next;
  wire [WIDTH_INT-1:0] pulse_req_int;
  reg  [WIDTH_INT-1:0] pulse_req_q;

  wire                 pwr_qreq_n_sync;
  wire                 pwr_qaccept_n_next;

  wire [2*WIDTH_INT-1:0] or_inputs;


  assign pulse_in_q_next = pulse_in & ~pulse_req_q & ~pulse_ack
                         & {WIDTH_INT{pwr_qaccept_n}};

  always @(posedge clk_s or negedge reset_s_n) begin
    if (!reset_s_n)
      pulse_in_q <= {WIDTH_INT{1'b0}};
    else
      pulse_in_q <= pulse_in_q_next;
  end

  generate
    if(WAKE_ON_PULSE_INT == 1) begin : gen_wake_on_pulse
      wire [WIDTH_INT-1:0] pulse_req_qq_next;
      reg [WIDTH_INT-1:0] pulse_req_qq;
      assign pulse_in_pulse = pulse_in & ~pulse_in_q;
      assign pulse_req_qq_next = {WIDTH_INT{pwr_qaccept_n_next}} & pulse_req_next;
      always @(posedge clk_s or negedge reset_s_n)
        if (!reset_s_n)
          pulse_req_qq <= {WIDTH_INT{1'b0}};
        else
          pulse_req_qq <= pulse_req_qq_next;
      assign pulse_req_int = pulse_req_qq;
    end

    else begin : gen_no_wake_on_pulse
      assign pulse_in_pulse = {WIDTH_INT{pwr_qreq_n_sync}} &
                              (pulse_in & ~pulse_in_q);
      assign pulse_req_int = pulse_req_q;
    end
  endgenerate

  assign pulse_req_next = (pulse_in_pulse & ~pulse_ack) |
                          (pulse_req_q    & ~pulse_ack);

  always @(posedge clk_s or negedge reset_s_n)
    if (!reset_s_n)
      pulse_req_q <= {WIDTH_INT{1'b0}};
    else
      pulse_req_q <= pulse_req_next;

  assign pulse_req = pulse_req_int;


  assign or_inputs = {pulse_req_q, pulse_ack};

  css600_pulsesyncbridgeslv_async #(.NUM_OR_INPUTS(2*WIDTH_INT))
    u_qactive_async (
      .or_inputs     (or_inputs),
      .pwr_qreq_n    (pwr_qreq_n),
      .pwr_qaccept_n (pwr_qaccept_n),
      .clk_s_qactive (clk_s_qactive),
      .pwr_qactive   (pwr_qactive)
  );

  assign pwr_qaccept_n_next = pwr_qreq_n_sync |
                              (pwr_qaccept_n &
                               pwr_qactive);

  always @(posedge clk_s or negedge reset_s_n)
    if (!reset_s_n)
      pwr_qaccept_n <= 1'b0;
    else
      pwr_qaccept_n <= pwr_qaccept_n_next;


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT)
  )
  u_css600_cdc_capt_sync_pwr_qreq_n(
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (pwr_qreq_n),
    .q_sync_o  (pwr_qreq_n_sync)
  );

endmodule


