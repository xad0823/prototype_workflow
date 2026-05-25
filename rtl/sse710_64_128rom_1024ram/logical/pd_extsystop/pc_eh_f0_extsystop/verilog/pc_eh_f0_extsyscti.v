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

module pc_eh_f0_extsyscti (

    input  wire           extsysx_cticlk,

    input  wire           extsysx_ctiresetn,

    input  wire [3:0]     extsysx_ctichin,

    output wire [3:0]     extsysx_ctichout,

    input  wire           qreqn_extsysx_cticlk,
    output wire           qacceptn_extsysx_cticlk,
    output wire           qdeny_extsysx_cticlk,
    output wire           qactive_extsysx_cticlk,

    input  wire           qreqn_extsysx_ctiinpwr,
    output wire           qacceptn_extsysx_ctiinpwr,
    output wire           qdeny_extsysx_ctiinpwr,
    output wire           qactive_extsysx_ctiinpwr,

    input  wire [3:0]     pulse_req_ehx_cti_out,
    output wire [3:0]     pulse_ack_ehx_cti_out,

    input  wire [3:0]     pulse_ack_ehx_cti_in,
    output wire [3:0]     pulse_req_ehx_cti_in
    );


  wire      clk_m_qactive;
  wire      clk_s_qactive;

  css600_pulseasyncbridgemstr #(
    .WIDTH         (4),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr (
    .clk_m             (extsysx_cticlk),
    .reset_m_n         (extsysx_ctiresetn),
    .pulse_out         (extsysx_ctichout),
    .pulse_req         (pulse_req_ehx_cti_out),
    .pulse_ack         (pulse_ack_ehx_cti_out),
    .clk_m_qreq_n      (qreqn_extsysx_cticlk),
    .clk_m_qaccept_n   (qacceptn_extsysx_cticlk),
    .clk_m_qactive     (clk_m_qactive)
    );

  assign qdeny_extsysx_cticlk = 1'b0;

  css600_pulseasyncbridgeslv #(
    .WIDTH            (4),
    .WAKE_ON_PULSE    (0), 
    .FF_SYNC_DEPTH    (2)
  ) u_css600_pulseasyncbridgeslv  (
    .clk_s            (extsysx_cticlk),
    .reset_s_n        (extsysx_ctiresetn),
    .pulse_in         (extsysx_ctichin),
    .pulse_req        (pulse_req_ehx_cti_in),
    .pulse_ack        (pulse_ack_ehx_cti_in),
    .clk_s_qactive    (clk_s_qactive),
    .pwr_qreq_n       (qreqn_extsysx_ctiinpwr),
    .pwr_qaccept_n    (qacceptn_extsysx_ctiinpwr),
    .pwr_qactive      (qactive_extsysx_ctiinpwr)
    );

  assign qdeny_extsysx_ctiinpwr = 1'b0;

  arm_element_std_or2 u_arm_element_std_or2 (
    .A  (clk_m_qactive),
    .B  (clk_s_qactive),
    .Y  (qactive_extsysx_cticlk)
  );

endmodule
