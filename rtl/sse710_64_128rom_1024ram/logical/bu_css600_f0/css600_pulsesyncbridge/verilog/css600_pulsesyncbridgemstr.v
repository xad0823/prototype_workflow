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


module css600_pulsesyncbridgemstr #(parameter
  WIDTH = 1
)
(
  clk_m,
  reset_m_n,

  pulse_out,

  pulse_req,
  pulse_ack
);


  localparam WIDTH_INT = (WIDTH > 0 && WIDTH < 33) ? WIDTH : 1;


  input  wire                 clk_m;
  input  wire                 reset_m_n;

  output reg  [WIDTH_INT-1:0] pulse_out;

  input  wire [WIDTH_INT-1:0] pulse_req;
  output reg  [WIDTH_INT-1:0] pulse_ack;


  wire [WIDTH_INT-1:0] pulse_ack_next;
  wire [WIDTH_INT-1:0] pulse_out_next;
  reg  [WIDTH_INT-1:0] pulse_req_q;


  assign pulse_ack_next = pulse_req_q;
  assign pulse_out_next = pulse_req_q & ~pulse_ack;

  always @(posedge clk_m or negedge reset_m_n) begin
    if (!reset_m_n) begin
      pulse_req_q <= {WIDTH_INT{1'b0}};
      pulse_ack   <= {WIDTH_INT{1'b0}};
      pulse_out   <= {WIDTH_INT{1'b0}};
    end
    else begin
      pulse_req_q <= pulse_req;
      pulse_ack   <= pulse_ack_next;
      pulse_out   <= pulse_out_next;
    end
  end

endmodule


