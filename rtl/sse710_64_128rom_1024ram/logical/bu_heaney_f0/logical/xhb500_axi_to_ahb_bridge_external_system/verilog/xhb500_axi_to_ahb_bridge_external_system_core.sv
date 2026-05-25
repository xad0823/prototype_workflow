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

module xhb500_axi_to_ahb_bridge_external_system_core
(


  input  wire logic                                                   clk,
  input  wire logic                                                   resetn,

  input  wire logic                                                   ctrl_core_en,
  output      logic                                                   ctrl_core_active,


  input  wire logic                                                   awsparse,

  input  wire logic                                                   awvalid,
  output      logic                                                   awready,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_axpayld_t                   awpayld,

  input  wire logic                                                   arvalid,
  output      logic                                                   arready,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_axpayld_t                   arpayld,

  input  wire logic                                                   wvalid,
  output      logic                                                   wready,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_wpayld_t                    wpayld,

  output      logic                                                   rvalid,
  input  wire logic                                                   rready,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::axi_rpayld_t                    rpayld,

  output      logic                                                   bvalid,
  input  wire logic                                                   bready,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::axi_bpayld_t                    bpayld,


  output      logic     [1:0]                                         htrans,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_mpayld_t                    hmpayld,

  input  wire logic                                                   hready,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_spayld_t                    hspayld
);

  wire logic              ctrl_xin_active;
  wire logic              hreg_empty;
  wire logic              ctrl_h_xout_active;

  assign ctrl_core_active = ctrl_xin_active | ~hreg_empty | ctrl_h_xout_active;


  wire logic              hreg_tr_en;
  wire logic              hreg_h_en;
  wire logic              hreg_w_en;
  wire logic       [1:0]  hreg_htrans_in;
  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_mpayld_t hreg_ahb_in;
  wire logic              hreg_hready_out;
  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_m_trq_t hreg_ahb_tr_q;


  xhb500_axi_to_ahb_bridge_external_system_core_xin u_core_xin
  (
    .clk                  (clk),
    .resetn               (resetn),
    .ctrl_core_en         (ctrl_core_en),
    .ctrl_xin_active      (ctrl_xin_active),

    .awsparse             (awsparse),
    .awvalid              (awvalid),
    .awready              (awready),
    .awpayld              (awpayld),

    .arvalid              (arvalid),
    .arready              (arready),
    .arpayld              (arpayld),

    .wvalid               (wvalid),
    .wready               (wready),
    .wpayld               (wpayld),

    .tr_en                (hreg_tr_en),
    .h_en                 (hreg_h_en),
    .w_en                 (hreg_w_en),

    .htrans_out           (hreg_htrans_in),
    .ahb_out              (hreg_ahb_in),

    .hready_in            (hreg_hready_out),
    .ahb_tr_q_in          (hreg_ahb_tr_q)
  );


  wire logic              hreg_hready_in;
  wire logic       [1:0]  hreg_htrans_out;
  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_mpayld_t hreg_ahb_out;

  xhb500_axi_to_ahb_bridge_external_system_hreg u_hreg
  (
    .clk                  (clk),
    .resetn               (resetn),

    .empty                (hreg_empty),

    .tr_en                (hreg_tr_en),
    .h_en                 (hreg_h_en),
    .w_en                 (hreg_w_en),

    .htrans_in            (hreg_htrans_in),
    .ahb_in               (hreg_ahb_in),

    .hready_out           (hreg_hready_out),
    .ahb_tr_q             (hreg_ahb_tr_q),

    .htrans_out           (hreg_htrans_out),
    .ahb_out              (hreg_ahb_out),

    .hready_in            (hreg_hready_in)
  );


  xhb500_axi_to_ahb_bridge_external_system_core_h_xout u_core_h_xout
  (
    .clk                   (clk),
    .resetn                (resetn),

    .ctrl_h_xout_active    (ctrl_h_xout_active),

    .htrans_in             (hreg_htrans_out),
    .ahb_in                (hreg_ahb_out),

    .hready_out            (hreg_hready_in),

    .htrans                (htrans),
    .hmpayld               (hmpayld),
    .hready                (hready),
    .hspayld               (hspayld),

    .rvalid                (rvalid),
    .rready                (rready),
    .rpayld                (rpayld),

    .bvalid                (bvalid),
    .bready                (bready),
    .bpayld                (bpayld)
  );










endmodule

