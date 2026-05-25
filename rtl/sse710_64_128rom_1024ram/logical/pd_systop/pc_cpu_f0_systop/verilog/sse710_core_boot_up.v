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
module sse710_core_boot_up #(
  parameter HOST_CPU_NUM_CORES = 4
)  (

  input  wire      clk,
  input  wire      resetn,

  input  wire      clustop_ppuhwstat_0,
  input  wire      clustop_ppuhwstat_2,
  input  wire      clustop_ppuhwstat_7,
  input  wire      clustop_ppuhwstat_8,
  input  wire      clustop_ppuhwstat_9,

  input  wire [HOST_CPU_NUM_CORES-1:0] core_ppuhwstat_on,
  input  wire [HOST_CPU_NUM_CORES-1:0] boot_mask,

  output wire [HOST_CPU_NUM_CORES-1:0] core_boot_up
);


localparam IDLE = 2'b00;
localparam NO_BOOT = 2'b01;
localparam BOOT = 2'b10;

reg [1:0]  current_state_r;
reg [HOST_CPU_NUM_CORES-1:0]  core_boot_up_r;

reg [1:0]  next_state;
reg [HOST_CPU_NUM_CORES-1:0]  core_boot_up_nxt;


always @(posedge clk or negedge resetn)
begin
  if (~resetn)
  begin
    current_state_r <= NO_BOOT;
    core_boot_up_r <= {HOST_CPU_NUM_CORES{1'b0}}; 
  end
  else 
  begin
    current_state_r <= next_state;
    core_boot_up_r <= core_boot_up_nxt;
  end
end

always @*
begin
  case (current_state_r)
  IDLE:
  begin
    if (clustop_ppuhwstat_2 | clustop_ppuhwstat_0)
    begin
      next_state = NO_BOOT;
      core_boot_up_nxt = {HOST_CPU_NUM_CORES{1'b0}};
    end
    else
    begin
      next_state = current_state_r;
      core_boot_up_nxt = (|core_ppuhwstat_on) ? {HOST_CPU_NUM_CORES{1'b0}} : core_boot_up_r;
    end
  end

  NO_BOOT:
  begin
    if ((clustop_ppuhwstat_7 | clustop_ppuhwstat_8 | clustop_ppuhwstat_9) & (core_boot_up_r == 1'b0))
    begin
      next_state = BOOT;
      core_boot_up_nxt = boot_mask; 
    end
    else
    begin
      next_state = current_state_r;
      core_boot_up_nxt = {HOST_CPU_NUM_CORES{1'b0}};
    end
  end

  BOOT:
  begin
    next_state = IDLE;
    core_boot_up_nxt = core_boot_up_r;
  end

  default:
  begin
    next_state = 2'bxx;
    core_boot_up_nxt = {HOST_CPU_NUM_CORES{1'bx}};
  end
  endcase
end

 assign core_boot_up = core_boot_up_r;

endmodule
