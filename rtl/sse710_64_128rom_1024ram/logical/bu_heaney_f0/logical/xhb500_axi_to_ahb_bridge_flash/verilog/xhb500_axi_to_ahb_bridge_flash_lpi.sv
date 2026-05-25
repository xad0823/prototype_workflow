//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_axi_to_ahb_bridge_flash_lpi
(


  input wire logic              clk,
  input wire logic              resetn,

  input wire logic              awakeup,

  input wire logic              arvalid,
  input wire logic              awvalid,
  input wire logic              wvalid,


  output xhb500_axi_to_ahb_bridge_flash_pkg::ctrl_lpi_en_t                 ctrl_lpi_en,
  input wire logic              ctrl_core_active,
  input wire logic              ctrl_xreg_active,

  output     logic              clk_qactive,
  input wire logic              clk_qreqn,
  output     logic              clk_qacceptn,
  output     logic              clk_qdeny,

  output     logic              pwr_qactive,
  input wire logic              pwr_qreqn,
  output     logic              pwr_qacceptn,
  output     logic              pwr_qdeny
);

  wire logic clk_qreqn_sync;
  wire logic pwr_qreqn_sync;

  assign clk_qreqn_sync = clk_qreqn;
  xhb500_sync u_pwr_qreqn_sync (
     .clk(clk), .reset_n(resetn), .d(pwr_qreqn), .q(pwr_qreqn_sync)
  );

  wire logic clk_Q_REQ        =  clk_qacceptn & ~clk_qreqn_sync & ~clk_qdeny;
  wire logic clk_Q_EXIT       = ~clk_qacceptn &  clk_qreqn_sync & ~clk_qdeny;
  wire logic clk_Q_CONT       =  clk_qacceptn &  clk_qreqn_sync &  clk_qdeny;
  wire logic clk_Q_nSTOP_nREQ =  (clk_qreqn_sync & ~clk_qdeny) | (clk_qacceptn & clk_qdeny);
  wire logic pwr_Q_REQ        =  pwr_qacceptn & ~pwr_qreqn_sync & ~pwr_qdeny;
  wire logic pwr_Q_EXIT       = ~pwr_qacceptn &  pwr_qreqn_sync & ~pwr_qdeny;
  wire logic pwr_Q_CONT       =  pwr_qacceptn &  pwr_qreqn_sync &  pwr_qdeny;
  wire logic pwr_Q_nSTOP_nREQ =  (pwr_qreqn_sync & ~pwr_qdeny) | (pwr_qacceptn & pwr_qdeny);


  wire logic tr_valid_in      = ctrl_lpi_en.en_bridge & (arvalid | awvalid | wvalid);
  wire logic bridge_active    = tr_valid_in | ctrl_core_active | ctrl_xreg_active;

  wire logic set_bridge_en    = ~ctrl_lpi_en.en_bridge & clk_Q_nSTOP_nREQ & pwr_Q_nSTOP_nREQ;
  wire logic clear_bridge_en  =  ctrl_lpi_en.en_bridge & (clk_Q_REQ | pwr_Q_REQ) & ~bridge_active;

  always_ff @ (posedge clk, negedge resetn)
  if(~resetn)
    ctrl_lpi_en <= '0;
  else if(set_bridge_en)
    ctrl_lpi_en <= '1;
  else if(clear_bridge_en)
    ctrl_lpi_en <= '0;

  logic bridge_active_q;
  wire logic set_bridge_active   = ~bridge_active_q & tr_valid_in;
  wire logic clear_bridge_active =  bridge_active_q & ~bridge_active;

  always_ff @ (posedge clk, negedge resetn)
    if(~resetn)
      bridge_active_q <= '0;
    else if(set_bridge_active)
      bridge_active_q <= '1;
    else if(clear_bridge_active)
      bridge_active_q <= '0;


  wire logic pwr_transition;
  xhb500_xor u_pwr_transition (
    .in_a(pwr_qreqn), .in_b(pwr_qacceptn), .out_y(pwr_transition)
  );

  xhb500_or  u_clk_qactive (
    .in_a(pwr_qactive), .in_b(pwr_transition), .out_y(clk_qactive)
  );

  xhb500_or  u_pwr_qactive (
    .in_a(awakeup), .in_b(bridge_active_q), .out_y(pwr_qactive)
  );

  wire logic clk_deny_req     = awakeup | bridge_active | (pwr_qreqn_sync ^ pwr_qacceptn);
  wire logic pwr_deny_req     = awakeup | bridge_active;

  wire logic clk_qacceptn_en = (clk_Q_REQ & ~clk_deny_req & ~ctrl_lpi_en.en_bridge) | clk_Q_EXIT;

  always_ff @ (posedge clk, negedge resetn)
    if(~resetn)
      clk_qacceptn <= 1'b0;
    else if(clk_qacceptn_en)
      clk_qacceptn <= ~clk_qacceptn;

  wire logic clk_qdeny_en = clk_Q_CONT | (clk_Q_REQ & clk_deny_req);

  always_ff @ (posedge clk, negedge resetn)
    if(~resetn)
      clk_qdeny    <= 1'b0;
    else if(clk_qdeny_en)
      clk_qdeny    <= ~clk_qdeny;

  wire logic pwr_qacceptn_en = (pwr_Q_REQ & ~pwr_deny_req & ~ctrl_lpi_en.en_bridge) | pwr_Q_EXIT;

  always_ff @ (posedge clk, negedge resetn)
    if(~resetn)
      pwr_qacceptn <= 1'b0;
    else if(pwr_qacceptn_en)
      pwr_qacceptn <= ~pwr_qacceptn;

  wire logic pwr_qdeny_en   = pwr_Q_CONT | (pwr_Q_REQ & pwr_deny_req);

  always_ff @ (posedge clk, negedge resetn)
    if(~resetn)
      pwr_qdeny    <= 1'b0;
    else if(pwr_qdeny_en)
      pwr_qdeny    <= ~pwr_qdeny;







endmodule
