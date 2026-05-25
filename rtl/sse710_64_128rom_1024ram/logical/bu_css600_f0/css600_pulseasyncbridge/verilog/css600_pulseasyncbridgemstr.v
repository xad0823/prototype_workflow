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
//   Shared sub-module of css600_pulseasyncbridge
//
//----------------------------------------------------------------------------


module css600_pulseasyncbridgemstr #(parameter
  WIDTH         = 1,
  FF_SYNC_DEPTH = 2
)
(
  clk_m,
  reset_m_n,
  pulse_out,
  pulse_req,
  pulse_ack,
  clk_m_qreq_n,
  clk_m_qaccept_n,
  clk_m_qactive
);

  localparam WIDTH_INT = (WIDTH > 0 && WIDTH < 33) ? WIDTH : 1;

  localparam FF_SYNC_DEPTH_INT = (FF_SYNC_DEPTH == 3) ? 3 : 2;


  input  wire                 clk_m;
  input  wire                 reset_m_n;


  output wire [WIDTH_INT-1:0] pulse_out;

  input  wire [WIDTH_INT-1:0] pulse_req;
  output wire [WIDTH_INT-1:0] pulse_ack;

  input  wire                 clk_m_qreq_n;
  output reg                  clk_m_qaccept_n;
  output wire                 clk_m_qactive;


  wire [WIDTH_INT-1:0] pulse_ack_int;
  reg  [WIDTH_INT-1:0] pulse_ack_q;
  wire [WIDTH_INT-1:0] pulse_req_sync;

  wire                 clk_m_qreq_n_sync;
  wire                 clk_m_qaccept_n_next;

  wire [2*WIDTH_INT-1:0] or_inputs;

  genvar               i;


  assign pulse_ack_int = pulse_req_sync & {WIDTH_INT{clk_m_qaccept_n}};

  always @(posedge clk_m or negedge reset_m_n)
    if (!reset_m_n)
      pulse_ack_q <= {WIDTH_INT{1'b0}};
    else
      pulse_ack_q <= pulse_ack_int;

  assign pulse_out = pulse_ack_int & ~pulse_ack_q;


  assign or_inputs = {pulse_req, pulse_ack_q};

  css600_or_tree #(.NUM_OR_INPUTS (2*WIDTH_INT))
    u_qactive_async (.or_inputs (or_inputs),
                      .or_output (clk_m_qactive));

  assign clk_m_qaccept_n_next = clk_m_qreq_n_sync |
                                (clk_m_qaccept_n & |pulse_req_sync);

  always @(posedge clk_m or negedge reset_m_n)
    if (!reset_m_n)
      clk_m_qaccept_n <= 1'b0;
    else
      clk_m_qaccept_n <= clk_m_qaccept_n_next;


  generate
    for(i = 0; i < WIDTH_INT; i = i + 1) begin: gen_req_sync_no_cdc
      css600_cdc_capt_sync
        #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT))
        u_css600_cdc_capt_sync_req(
        .clk       (clk_m),
        .reset_n   (reset_m_n),
        .d_async_i (pulse_req[i]),
        .q_sync_o  (pulse_req_sync[i])
      );
    end
  endgenerate


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT))
    u_css600_cdc_capt_sync_clk_m_qreq_n(
    .clk       (clk_m),
    .reset_n   (reset_m_n),
    .d_async_i (clk_m_qreq_n),
    .q_sync_o  (clk_m_qreq_n_sync)
  );


  assign    pulse_ack = pulse_ack_q;

endmodule


