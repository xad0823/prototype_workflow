//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
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
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_reg_stage
#(
  parameter PAYLOAD_WIDTH  = 2
)(
  input  wire                      clk,
  input  wire                      reset_n,
  input  wire                      valid_src,
  input  wire [PAYLOAD_WIDTH-1:0]  payload_src,
  output wire                      ready_src,
  output wire                      valid_dst,
  output wire [PAYLOAD_WIDTH-1:0]  payload_dst,
  input  wire                      ready_dst
);

  wire                     payload_en;
  wire                     valid_en;
  reg                      valid_q;
  reg [PAYLOAD_WIDTH-1:0]  payload_q;


  assign ready_src   = ready_dst | ~valid_q;
  assign valid_dst   = valid_q;
  assign payload_dst = payload_q;

  assign payload_en = (valid_src & ~valid_q) | (valid_src & valid_q & ready_dst);

  always @(posedge clk)
  begin : reg_payload
    if (payload_en)
      payload_q <= payload_src;
  end

  assign valid_en = valid_src | ready_dst;

  always @(posedge clk or negedge reset_n)
  begin : reg_valid
    if (!reset_n)
      valid_q <= 1'b0;
    else if (valid_en)
      valid_q <= valid_src;
  end


endmodule

