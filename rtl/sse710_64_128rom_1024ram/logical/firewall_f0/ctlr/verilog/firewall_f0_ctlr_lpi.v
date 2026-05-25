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

module firewall_f0_ctlr_lpi #(
    parameter FW_SRE_LVL = 1
  ) (
  input  wire        clk               ,
  input  wire        clk_gated         ,
  input  wire        reset_n           ,

  input  wire        bypass_syncd      ,
  input  wire        tinit_delay       ,

  input  wire        clk_qreqn_i       ,
  output wire        clk_qacceptn_o    ,
  output wire        clk_qdeny_o       ,
  output wire        clk_qactive_o     ,

  input  wire        pwr_preq_i        ,
  output wire        pwr_paccept_o     ,
  output wire        pwr_pdeny_o       ,
  output wire [10:0] pwr_pactive_o     ,
  input  wire [3:0]  pwr_pstate_i      ,

  output wire        cfg_hold_o,
  input  wire        cfg_busy_i,
  input  wire        cfg_ram_req_i ,
  output wire        cfg_ram_ack_o ,
  output wire        cfg_ram_init_o,
  input  wire        cfg_ram_init_done_i,

  output wire        gate_hold_req_o   ,
  input  wire        gate_hold_ack_i   ,
  input  wire        gate_busy_i       ,

  input  wire        rb_fc_con_i       ,
  input  wire        rb_fc_sr_pwr_i    ,
  input  wire        rb_pwr_deny_i     ,
  output wire        rb_prot_en_o      ,
  output wire        default_state_o   ,

  output wire        clk_gate_en,

  input  wire        dftcgen
);

wire      pwr_clk_req;
wire      pwr_gate_hold_req;
wire      clk_gate_hold_req;
wire      clk_cfg_hold;
wire      pwr_cfg_hold;

reg       i_bps_d1;
reg       i_bps_d2;
wire      i_bps_clken;
wire      i_clk_qactive;

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

firewall_f0_clkctrl u_ctlr_clkctrl (
  .clk                 (clk                ),
  .rstn                (reset_n            ),
  .gate_busy_i         (gate_busy_i        ),
  .gate_hold_req_o     (clk_gate_hold_req  ),
  .gate_hold_ack_i     (gate_hold_ack_i    ),
  .cfg_busy_i          (cfg_busy_i         ),
  .cfg_clk_hold_o      (clk_cfg_hold       ),
  .clk_request_i       (pwr_clk_req | i_bps_clken),
  .clk_gate_en         (clk_gate_en        ),
  .qreqn_i             (clk_qreqn_i        ),
  .qacceptn_o          (clk_qacceptn_o     ),
  .qdeny_o             (clk_qdeny_o        ),
  .qactive_o           (i_clk_qactive      )
  );

firewall_f0_or2 u_lpi_or2_0 (
  .din0 (i_bps_clken),
  .din1 (i_clk_qactive),
  .dout (clk_qactive_o)
);

firewall_f0_ctlr_pwrctrl #(
  .FW_SRE_LVL (FW_SRE_LVL)
) u_ctlr_pwrctrl (
  .clk                 (clk_gated          ),
  .rstn                (reset_n            ),
  .tinit_delay         (tinit_delay        ),
  .gate_hold_req_o     (pwr_gate_hold_req  ),
  .gate_busy_i         (gate_busy_i        ),
  .rb_fc_con_i         (rb_fc_con_i        ),
  .rb_fc_sr_pwr_i      (rb_fc_sr_pwr_i     ),
  .rb_pwr_deny_i       (rb_pwr_deny_i      ),
  .rb_prot_en_o        (rb_prot_en_o       ),
  .default_state_o     (default_state_o    ),
  .cfg_hold_o          (pwr_cfg_hold       ),
  .cfg_busy_i          (cfg_busy_i         ),
  .cfg_ram_req_i       (cfg_ram_req_i      ),
  .cfg_ram_ack_o       (cfg_ram_ack_o      ),
  .cfg_ram_init_o      (cfg_ram_init_o     ),
  .cfg_ram_init_done_i (cfg_ram_init_done_i),
  .clk_hold_i          (clk_cfg_hold       ),
  .clk_request_o       (pwr_clk_req        ),
  .preq_i              (pwr_preq_i         ),
  .paccept_o           (pwr_paccept_o      ),
  .pdeny_o             (pwr_pdeny_o        ),
  .pstate_i            (pwr_pstate_i       ),
  .pactive_o           (pwr_pactive_o      )
  );

assign gate_hold_req_o = clk_gate_hold_req | pwr_gate_hold_req;
assign cfg_hold_o = clk_cfg_hold | pwr_cfg_hold;

endmodule
