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
module css600_dpabortsyncbridge
 #(parameter
  WIDTH         = 1,
  WAKE_ON_PULSE = 1,
  FF_SYNC_DEPTH = 2,
  WIDTH_INT     = (WIDTH > 0 && WIDTH < 33) ? WIDTH : 1
) (

  input  wire                 clk,
  input  wire                 reset_n,
  
  
  input  wire [WIDTH_INT-1:0] pulse_in,
  output wire [WIDTH_INT-1:0] pulse_out,

  input  wire                 pwr_qreq_n,
  output wire                 pwr_qaccept_n,
  output wire                 pwr_qactive,
  output wire                 clk_s_qactive
  
);



  wire [WIDTH_INT-1:0] i_pulse_req;
  wire [WIDTH_INT-1:0] i_pulse_ack;




css600_pulsesyncbridgeslv #(
  .WIDTH         (WIDTH),
  .WAKE_ON_PULSE (WAKE_ON_PULSE),
  .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
) u_css600_pulsesyncbridgeslv_i0 (
  .clk_s        (clk),
  .reset_s_n    (reset_n),
  .pulse_in     (pulse_in),
  .pulse_req    (i_pulse_req),
  .pulse_ack    (i_pulse_ack),
  .clk_s_qactive(clk_s_qactive),
  .pwr_qreq_n   (pwr_qreq_n),
  .pwr_qaccept_n(pwr_qaccept_n),
  .pwr_qactive  (pwr_qactive)
);



css600_pulsesyncbridgemstr #(
  .WIDTH (WIDTH)
) u_css600_pulsesyncbridgemstr_i0 (
  .clk_m    (clk),
  .reset_m_n(reset_n),
  .pulse_out(pulse_out),
  .pulse_req(i_pulse_req),
  .pulse_ack(i_pulse_ack)
);

endmodule
