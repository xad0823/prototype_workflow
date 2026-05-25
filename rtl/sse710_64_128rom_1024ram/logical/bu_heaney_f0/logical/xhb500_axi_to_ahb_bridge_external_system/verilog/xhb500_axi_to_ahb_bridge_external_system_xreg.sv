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

module xhb500_axi_to_ahb_bridge_external_system_xreg
(

  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ctrl_lpi_en_t                 ctrl_lpi_en,
  output      logic                                                 ctrl_xreg_active,

  input wire logic                                                  arvalid,
  output     logic                                                  arready,
  input wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_axpayld_t                  arpayld,
  input wire logic                                                  awvalid,
  output     logic                                                  awready,
  input wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_awsppayld_t                awsppayld,
  input wire logic                                                  wvalid,
  output     logic                                                  wready,
  input wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_wpayld_t                   wpayld,

  output     logic                                                  xreg_arvalid,
  input wire logic                                                  xreg_arready,
  output xhb500_axi_to_ahb_bridge_external_system_pkg::axi_axpayld_t                      xreg_arpayld,
  output     logic                                                  xreg_awvalid,
  input wire logic                                                  xreg_awready,
  output xhb500_axi_to_ahb_bridge_external_system_pkg::axi_awsppayld_t                    xreg_awsppayld,
  output     logic                                                  xreg_wvalid,
  input wire logic                                                  xreg_wready,
  output xhb500_axi_to_ahb_bridge_external_system_pkg::axi_wpayld_t                       xreg_wpayld
);


  wire logic unused = ctrl_lpi_en.en_core | ctrl_lpi_en.en_bridge;

  wire logic xreg_arempty, xreg_awempty, xreg_wempty;
  assign ctrl_xreg_active = ~xreg_arempty | ~xreg_awempty | ~xreg_wempty;




  xhb500_bypass_regd_slice_empty
  #(
    .PAYLD_WIDTH($bits(xhb500_axi_to_ahb_bridge_external_system_pkg::axi_axpayld_t))
  )
  u_xreg_ar
  (
    .empty              (xreg_arempty),

    .valid_src          (arvalid),
    .payload_src        (arpayld),
    .ready_src          (arready),

    .valid_dst          (xreg_arvalid),
    .payload_dst        (xreg_arpayld),
    .ready_dst          (xreg_arready)
  );


  xhb500_bypass_regd_slice_empty
  #(
    .PAYLD_WIDTH($bits(xhb500_axi_to_ahb_bridge_external_system_pkg::axi_awsppayld_t))
  )
  u_xreg_aw
  (
    .empty              (xreg_awempty),

    .valid_src          (awvalid),
    .payload_src        (awsppayld),
    .ready_src          (awready),

    .valid_dst          (xreg_awvalid),
    .payload_dst        (xreg_awsppayld),
    .ready_dst          (xreg_awready)

  );


  xhb500_bypass_regd_slice_empty
  #(
    .PAYLD_WIDTH($bits(xhb500_axi_to_ahb_bridge_external_system_pkg::axi_wpayld_t))
  )
  u_xreg_w
  (

    .empty              (xreg_wempty),

    .valid_src          (wvalid),
    .payload_src        (wpayld),
    .ready_src          (wready),

    .valid_dst          (xreg_wvalid),
    .payload_dst        (xreg_wpayld),
    .ready_dst          (xreg_wready)
  );

endmodule

