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

module mhuv2_f1_adb_apb3_q_channel
(
  input wire                  pclk,
  input wire                  presetn,

  input wire                  qreqn_i,
  output wire                 qacceptn_o,
  output wire                 qdeny_o,

  input wire                  request_i,
  output wire                 en_o,

  output wire                 clken_o
);

localparam Q_STOPPED = 2'b00;
localparam Q_RUN = 2'b01;
localparam Q_DENY = 2'b10;


  reg [1:0]                   state;
  reg [1:0]                   nxt_state;
  reg                         state_en;
  reg                         enable;
  reg                         qacceptn_r;
  reg                         qdeny_r;
  reg                         nxt_qacceptn_r;
  reg                         nxt_qdeny_r;
  reg                         clken;




  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      state[1:0] <= Q_STOPPED;
      qacceptn_r <= 1'b0;
      qdeny_r <= 1'b0;
    end
    else if(state_en)
    begin
      state[1:0] <= nxt_state[1:0];
      qacceptn_r <= nxt_qacceptn_r;
      qdeny_r <= nxt_qdeny_r;
    end
  end

  always@*
  begin
    case(state[1:0])
    Q_STOPPED:
    begin
      nxt_state[1:0] = Q_RUN;
      state_en = qreqn_i;
      enable = qreqn_i;
      nxt_qacceptn_r = 1'b1;
      nxt_qdeny_r = 1'b0;
      clken = qreqn_i;
    end
    Q_RUN:
    begin
      nxt_state[1:0] = (request_i)? Q_DENY:Q_STOPPED;
      state_en = ~qreqn_i;
      enable = qreqn_i | request_i;
      nxt_qacceptn_r = request_i;
      nxt_qdeny_r = request_i;
      clken = ~qreqn_i;
    end
    Q_DENY:
    begin
      nxt_state[1:0] = Q_RUN;
      state_en = qreqn_i;
      enable = 1'b1;
      nxt_qacceptn_r = 1'b1;
      nxt_qdeny_r = 1'b0;
      clken = 1'b1;
    end
    default:
    begin
      nxt_state[1:0] = 2'bxx;
      state_en = 1'bx;
      enable = 1'bx;
      nxt_qacceptn_r = 1'bx;
      nxt_qdeny_r = 1'bx;
      clken = 1'bx;
    end
    endcase
  end


  assign qacceptn_o = qacceptn_r;
  assign qdeny_o = qdeny_r;

  assign en_o = enable;

  assign clken_o = clken;

endmodule
