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
module firewall_f0_comp_lpi(

  input  wire            clk,
  input  wire            clk_gated,
  input  wire            reset_n,

  input  wire            bypass_syncd,

  input  wire            clk_qreqn_i,
  output wire            clk_qacceptn_o,
  output wire            clk_qdeny_o,
  output wire            clk_qactive_o,

  input  wire            pwr_qreqn_i,
  output wire            pwr_qacceptn_o,
  output wire            pwr_qdeny_o,
  output wire            pwr_qactive_o,

  output wire            gate_hold_req_o,
  input  wire            gate_hold_ack_i,
  input  wire            gate_busy_i,

  input  wire            rb_pwr_deny_i,
  output wire            default_state_o,

  output wire [1:0]      cfg_con_o,
  output wire            cfg_dis_o,
  output wire            cfg_clk_hold_o,
  input  wire            cfg_busy_i,
  input  wire            cfg_accept_i,

  output wire            clk_gate_en,

  input  wire            dftcgen
);

wire pwr_clk_req;
wire clk_gate_hold_req;
wire pwr_gate_hold_req;

wire i_clk_gate_en;
wire i_clk_qactive;
reg  i_bps_d1;
reg  i_bps_d2;
wire i_bps_clken;

always @(posedge clk_gated or negedge reset_n)
begin
  if (!reset_n)
  begin
    i_bps_d1 <= 1'b0;
    i_bps_d2 <= 1'b0;
  end
  else if (i_bps_clken)
  begin
    i_bps_d1 <= bypass_syncd;
    i_bps_d2 <= i_bps_d1;
  end
end

firewall_f0_xor2 u_comp_lpi_xor2_0 (
  .din0 (bypass_syncd),
  .din1 (i_bps_d2),
  .dout (i_bps_clken)
);

firewall_f0_clkctrl u_comp_clkctrl (
  .clk             (clk               ),
  .rstn            (reset_n           ),
  .gate_busy_i     (gate_busy_i       ),
  .gate_hold_req_o (clk_gate_hold_req ),
  .gate_hold_ack_i (gate_hold_ack_i   ),
  .cfg_busy_i      (cfg_busy_i        ),
  .cfg_clk_hold_o  (cfg_clk_hold_o    ),
  .clk_request_i   (pwr_clk_req | i_bps_clken),
  .clk_gate_en     (clk_gate_en       ),
  .qreqn_i         (clk_qreqn_i       ),
  .qacceptn_o      (clk_qacceptn_o    ),
  .qdeny_o         (clk_qdeny_o       ),
  .qactive_o       (i_clk_qactive     )
  );

firewall_f0_or2 u_lpi_or2_0 (
  .din0 (i_bps_clken),
  .din1 (i_clk_qactive),
  .dout (clk_qactive_o)
);

firewall_f0_comp_pwrctrl u_comp_pwrctrl (
  .clk             (clk_gated         ),
  .rstn            (reset_n           ),
  .gate_busy_i     (gate_busy_i       ),
  .gate_hold_req_o (pwr_gate_hold_req ),
  .gate_hold_ack_i (gate_hold_ack_i   ),
  .rb_pwr_deny_i   (rb_pwr_deny_i     ),
  .default_state_o (default_state_o   ),
  .cfg_busy_i      (cfg_busy_i        ),
  .cfg_dis_o       (cfg_dis_o         ),
  .cfg_con_o       (cfg_con_o         ),
  .cfg_accept_i    (cfg_accept_i      ),
  .clk_hold_i      (cfg_clk_hold_o    ),
  .clk_request_o   (pwr_clk_req       ),
  .qreqn_i         (pwr_qreqn_i       ),
  .qacceptn_o      (pwr_qacceptn_o    ),
  .qdeny_o         (pwr_qdeny_o       ),
  .qactive_o       (pwr_qactive_o     )
);

assign gate_hold_req_o = clk_gate_hold_req | pwr_gate_hold_req;

endmodule
