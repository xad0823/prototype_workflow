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


module xhb500_axi_to_ahb_bridge_flash
(

  input  wire logic                                    clk,
  input  wire logic                                    resetn,

  output      logic                                    clk_qactive,
  input  wire logic                                    clk_qreqn,
  output      logic                                    clk_qacceptn,
  output      logic                                    clk_qdeny,

  output      logic                                    pwr_qactive,
  input  wire logic                                    pwr_qreqn,
  output      logic                                    pwr_qacceptn,
  output      logic                                    pwr_qdeny,


  input  wire logic                                    awvalid,
  output      logic                                    awready,
  input  wire logic     [32-1:0]                       awaddr,
  input  wire logic     [1:0]                          awburst,
  input  wire logic     [12-1:0]                       awid,
  input  wire logic     [7:0]                          awlen,
  input  wire logic     [2:0]                          awsize,
  input  wire logic                                    awlock,
  input  wire logic     [2:0]                          awprot,
  input  wire logic     [3:0]                          awcache,

  input  wire logic                                    arvalid,
  output      logic                                    arready,
  input  wire logic     [32-1:0]                       araddr,
  input  wire logic     [1:0]                          arburst,
  input  wire logic     [12-1:0]                       arid,
  input  wire logic     [7:0]                          arlen,
  input  wire logic     [2:0]                          arsize,
  input  wire logic                                    arlock,
  input  wire logic     [2:0]                          arprot,
  input  wire logic     [3:0]                          arcache,

  input  wire logic                                    wvalid,
  output      logic                                    wready,
  input  wire logic                                    wlast,
  input  wire logic     [16-1:0]                       wstrb,
  input  wire logic     [128-1:0]                      wdata,

  output      logic                                    rvalid,
  input  wire logic                                    rready,
  output      logic     [12-1:0]                       rid,
  output      logic                                    rlast,
  output      logic     [128-1:0]                      rdata,
  output      logic     [1:0]                          rresp,

  output      logic                                    bvalid,
  input  wire logic                                    bready,
  output      logic     [12-1:0]                       bid,
  output      logic     [1:0]                          bresp,


  input  wire logic     [1:0]                          ardomain,
  input  wire logic     [1:0]                          awdomain,
  input  wire logic                                    awsparse,

  input  wire logic                                    awakeup,
  input  wire logic     [3:0]                          awnsaid,
  input  wire logic     [3:0]                          arnsaid,
  input  wire logic     [3:0]                          awqos,
  input  wire logic     [3:0]                          arqos,
  input  wire logic     [3:0]                          awregion,
  input  wire logic     [3:0]                          arregion,


  output      logic                                    hnonsec,
  output      logic     [32-1:0]                       haddr,
  output      logic     [1:0]                          htrans,
  output      logic     [2:0]                          hsize,
  output      logic                                    hwrite,
  output      logic     [6:0]                          hprot,
  output      logic     [2:0]                          hburst,
  output      logic                                    hmastlock,
  output      logic     [128-1:0]                      hwdata,
  output      logic                                    hexcl,
  output      logic     [12-1:0]                       hmaster,

  input  wire logic     [128-1:0]                      hrdata,
  input  wire logic                                    hready,
  input  wire logic                                    hresp,
  input  wire logic                                    hexokay,


  output      logic     [3:0]                          hqos,
  output      logic     [3:0]                          hregion,
  output      logic     [3:0]                          hnsaid
);



  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t   axi_arpayld;
  assign axi_arpayld.axaddr                 = araddr;
  assign axi_arpayld.axburst                = arburst;
  assign axi_arpayld.axid                   = arid;
  assign axi_arpayld.axlen                  = arlen;
  assign axi_arpayld.axsize                 = arsize;
  assign axi_arpayld.axlock                 = arlock;
  assign axi_arpayld.axprot                 = arprot;
  assign axi_arpayld.axcache                = arcache;
  assign axi_arpayld.axdomain               = ardomain;
  assign axi_arpayld.axnsaid                = arnsaid;
  assign axi_arpayld.axqos                  = arqos;
  assign axi_arpayld.axregion               = arregion;

  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_awsppayld_t axi_awsppayld;
  assign axi_awsppayld.awsparse             = awsparse;
  assign axi_awsppayld.awpayld.axaddr       = awaddr;
  assign axi_awsppayld.awpayld.axburst      = awburst;
  assign axi_awsppayld.awpayld.axid         = awid;
  assign axi_awsppayld.awpayld.axlen        = awlen;
  assign axi_awsppayld.awpayld.axsize       = awsize;
  assign axi_awsppayld.awpayld.axlock       = awlock;
  assign axi_awsppayld.awpayld.axprot       = awprot;
  assign axi_awsppayld.awpayld.axcache      = awcache;
  assign axi_awsppayld.awpayld.axdomain     = awdomain;
  assign axi_awsppayld.awpayld.axnsaid      = awnsaid;
  assign axi_awsppayld.awpayld.axqos        = awqos;
  assign axi_awsppayld.awpayld.axregion     = awregion;

  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_wpayld_t axi_wpayld;
  assign axi_wpayld.wlast                   = wlast;
  assign axi_wpayld.wstrb                   = wstrb;
  assign axi_wpayld.wdata                   = wdata;

  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_rpayld_t   axi_rpayld;
  assign rid                                = axi_rpayld.rid;
  assign rdata                              = axi_rpayld.rdata;
  assign rlast                              = axi_rpayld.rlast;
  assign rresp                              = axi_rpayld.rresp;

  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_bpayld_t   axi_bpayld;
  assign bid                                = axi_bpayld.bid;
  assign bresp                              = axi_bpayld.bresp;

  wire xhb500_axi_to_ahb_bridge_flash_pkg::ahb_mpayld_t ahb_mpayld;
  assign hwrite                             = ahb_mpayld.trfix.hwrite;
  assign hexcl                              = ahb_mpayld.trfix.trfixq.hexcl;
  assign hburst                             = ahb_mpayld.trfix.trfixq.hburst;
  assign hnonsec                            = ahb_mpayld.trfix.trfixq.hnonsec;
  assign hprot                              = ahb_mpayld.trfix.trfixq.hprot;
  assign hmaster                            = ahb_mpayld.trfix.trfixq.hmaster;
  assign hqos                               = ahb_mpayld.trfix.trfixq.hqos;
  assign hregion                            = ahb_mpayld.trfix.trfixq.hregion;
  assign hnsaid                             = ahb_mpayld.trfix.trfixq.hnsaid;
  assign haddr                              = {ahb_mpayld.trfix.trfixq.haddr_m_12, ahb_mpayld.hfix.haddr_11_0};
  assign hsize                              = ahb_mpayld.hfix.hsize;
  assign hmastlock                          = ahb_mpayld.hfix.hmastlock;
  assign hwdata                             = ahb_mpayld.wdata.hwdata;

  wire logic unused_out                     = &{ahb_mpayld.hfix.resp_ctrl, ahb_mpayld.trfix.ctrl_exclid};

  wire xhb500_axi_to_ahb_bridge_flash_pkg::ahb_spayld_t   ahb_spayld;
  assign ahb_spayld.hrdata                  = hrdata;
  assign ahb_spayld.hresp                   = hresp;
  assign ahb_spayld.hexokay                 = hexokay;



  wire xhb500_axi_to_ahb_bridge_flash_pkg::ctrl_lpi_en_t  ctrl_lpi_en;
  wire logic                                  ctrl_core_active;
  wire logic                                  ctrl_xreg_active;

  xhb500_axi_to_ahb_bridge_flash_lpi u_lpi
  (
    .clk                (clk),
    .resetn             (resetn),

    .awakeup            (awakeup),

    .arvalid            (arvalid),
    .awvalid            (awvalid),
    .wvalid             (wvalid),

    .ctrl_lpi_en        (ctrl_lpi_en),
    .ctrl_core_active   (ctrl_core_active),
    .ctrl_xreg_active   (ctrl_xreg_active),

    .clk_qactive        (clk_qactive),
    .clk_qreqn          (clk_qreqn),
    .clk_qacceptn       (clk_qacceptn),
    .clk_qdeny          (clk_qdeny),

    .pwr_qactive        (pwr_qactive),
    .pwr_qreqn          (pwr_qreqn),
    .pwr_qacceptn       (pwr_qacceptn),
    .pwr_qdeny          (pwr_qdeny)
  );



  wire logic                                   xreg_arvalid;
  wire logic                                   xreg_arready;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t   xreg_arpayld;
  wire logic                                   xreg_awvalid;
  wire logic                                   xreg_awready;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_awsppayld_t xreg_awsppayld;
  wire logic                                   xreg_wvalid;
  wire logic                                   xreg_wready;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_wpayld_t    xreg_wpayld;

  xhb500_axi_to_ahb_bridge_flash_xreg u_xreg
  (
    .clk                (clk),
    .resetn             (resetn),

    .ctrl_lpi_en        (ctrl_lpi_en),
    .ctrl_xreg_active   (ctrl_xreg_active),

    .awvalid            (awvalid),
    .awready            (awready),
    .awsppayld          (axi_awsppayld),

    .arvalid            (arvalid),
    .arready            (arready),
    .arpayld            (axi_arpayld),

    .wvalid             (wvalid),
    .wready             (wready),
    .wpayld             (axi_wpayld),

    .xreg_awvalid       (xreg_awvalid),
    .xreg_awready       (xreg_awready),
    .xreg_awsppayld     (xreg_awsppayld),

    .xreg_arvalid       (xreg_arvalid),
    .xreg_arready       (xreg_arready),
    .xreg_arpayld       (xreg_arpayld),

    .xreg_wvalid        (xreg_wvalid),
    .xreg_wready        (xreg_wready),
    .xreg_wpayld        (xreg_wpayld)
  );



  xhb500_axi_to_ahb_bridge_flash_core
  u_core
  (
    .clk                (clk),
    .resetn             (resetn),

    .ctrl_core_en       (ctrl_lpi_en.en_core),
    .ctrl_core_active   (ctrl_core_active),


    .awsparse           (xreg_awsppayld.awsparse),

    .awvalid            (xreg_awvalid),
    .awready            (xreg_awready),
    .awpayld            (xreg_awsppayld.awpayld),

    .arvalid            (xreg_arvalid),
    .arready            (xreg_arready),
    .arpayld            (xreg_arpayld),

    .wvalid             (xreg_wvalid),
    .wready             (xreg_wready),
    .wpayld             (xreg_wpayld),

    .rvalid             (rvalid),
    .rready             (rready),
    .rpayld             (axi_rpayld),

    .bvalid             (bvalid),
    .bready             (bready),
    .bpayld             (axi_bpayld),

    .htrans             (htrans),
    .hmpayld            (ahb_mpayld),

    .hready             (hready),
    .hspayld            (ahb_spayld)
  );

endmodule
