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
module sse710_core_powerup_q_chan #(
  parameter SYNC_ENABLE = 1'b0
) (

  input  wire                      clk,
  input  wire                      resetn,

  input  wire                      pwr_qreqn_i,
  output reg                       pwr_qacceptn_o,
  output reg                       pwr_qdeny_o,
  input  wire [3:0]                pstate_i,

  output wire                      cpuqreqn_o,
  input  wire                      cpuqacceptn_i,
  input  wire                      cpuqdeny_i,

  input  wire                      standbywfi_i

);

localparam POWER_DOWN = 2'b00;
localparam FULL_RET   = 2'b01;
localparam POWER_UP   = 2'b10;

reg [1:0]  current_state_r;
reg [1:0]  next_state;

reg  nxt_pwr_qacceptn;
reg  nxt_pwr_qdeny;

wire cpuqacceptn;
wire cpuqdeny;

genvar i;

if (SYNC_ENABLE == 1'b1)
begin:sync_en
  arm_element_cdc_capt_sync u_cpuqacceptn_sync (
    .clk       (clk),
    .nreset    (resetn),

    .d_async   (cpuqacceptn_i),
    .q         (cpuqacceptn)
  );

  arm_element_cdc_capt_sync u_cpuqdeny_sync (
    .clk       (clk),
    .nreset    (resetn),

    .d_async   (cpuqdeny_i),
    .q         (cpuqdeny)
  );
end

if (SYNC_ENABLE == 1'b0)
begin:no_sync
  assign cpuqacceptn = cpuqacceptn_i;
  assign cpuqdeny    = cpuqdeny_i;
end

assign cpuqreqn_o = pwr_qreqn_i;

always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    pwr_qacceptn_o  <= 1'b0;
    pwr_qdeny_o     <= 1'b0;
    current_state_r <= POWER_DOWN;
  end
  else
  begin
    pwr_qacceptn_o  <= nxt_pwr_qacceptn;
    pwr_qdeny_o     <= nxt_pwr_qdeny;
    current_state_r <= next_state;
  end
end

always @(*)
begin
  case (current_state_r)
  POWER_DOWN:
  if (pwr_qreqn_i)
  begin
    next_state       = POWER_UP;
    nxt_pwr_qacceptn = (cpuqacceptn & (~standbywfi_i)) ? 1'b1 : pwr_qacceptn_o;
    nxt_pwr_qdeny    = cpuqdeny;
  end
  else
  begin
    next_state       = current_state_r;
    nxt_pwr_qacceptn = cpuqacceptn;
    nxt_pwr_qdeny    = cpuqdeny;
  end

  FULL_RET:
  if (pwr_qreqn_i)
  begin
    next_state       = (cpuqacceptn == 1'b1) ? POWER_UP : FULL_RET;
    nxt_pwr_qacceptn = cpuqacceptn;
    nxt_pwr_qdeny    = cpuqdeny;
  end
  else
  begin
    next_state       = current_state_r;
    nxt_pwr_qacceptn = cpuqacceptn;
    nxt_pwr_qdeny    = cpuqdeny;
  end

  POWER_UP:
  if (~pwr_qreqn_i)
  begin
    next_state       = (pstate_i == 4'b0101) ? FULL_RET : POWER_DOWN;
    nxt_pwr_qacceptn = cpuqacceptn;
    nxt_pwr_qdeny    = cpuqdeny;
  end
  else
  begin
    next_state       = current_state_r;
    nxt_pwr_qacceptn = (cpuqacceptn & (~standbywfi_i)) ? 1'b1 : pwr_qacceptn_o;
    nxt_pwr_qdeny    = cpuqdeny;
  end

  default:
  begin
    next_state       = 2'bxx;
    nxt_pwr_qacceptn = 1'bx;
    nxt_pwr_qdeny    = 1'bx;
  end
  endcase
end

endmodule


  
