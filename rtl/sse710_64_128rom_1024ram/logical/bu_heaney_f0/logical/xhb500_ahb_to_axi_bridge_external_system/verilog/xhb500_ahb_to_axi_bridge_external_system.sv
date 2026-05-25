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

module xhb500_ahb_to_axi_bridge_external_system (

  input  wire logic                                         clk,
  input  wire logic                                         resetn,

  output      logic                                         buf_write_error_irq,
  input  wire logic                                         irq_en,

  input  wire logic                                         hsel,
  input  wire logic                                         hnonsec,
  input  wire logic [32-1:0]                                haddr,
  input  wire logic [1:0]                                   htrans,
  input  wire logic [2:0]                                   hsize,
  input  wire logic                                         hwrite,
  input  wire logic                                         hready,
  input  wire logic [6:0]                                   hprot,
  input  wire logic [2:0]                                   hburst,
  input  wire logic                                         hmastlock,
  input  wire logic [32-1:0]                                hwdata,
  input  wire logic                                         hexcl,
  input  wire logic [1-1:0]                                 hmaster,
  output      logic [32-1:0]                                hrdata,
  output      logic                                         hreadyout,
  output      logic                                         hresp,
  output      logic                                         hexokay,

  input  wire logic [3:0]                                   hqos,
  input  wire logic [3:0]                                   hregion,
  input  wire logic [3:0]                                   hnsaid,

  output      logic                                         awvalid,
  output      logic [32-1:0]                                awaddr,
  output      logic [1:0]                                   awdomain,
  output      logic [1:0]                                   awburst,
  output      logic [1-1:0]                                 awid,
  output      logic [7:0]                                   awlen,
  output      logic [2:0]                                   awsize,
  output      logic                                         awlock,
  output      logic [2:0]                                   awprot,
  input  wire logic                                         awready,
  output      logic [3:0]                                   awcache,
  output      logic [3:0]                                   awregion,
  output      logic [3:0]                                   awnsaid,
  output      logic [3:0]                                   awqos,

  output      logic                                         arvalid,
  output      logic [32-1:0]                                araddr,
  output      logic [1:0]                                   ardomain,
  output      logic [1:0]                                   arburst,
  output      logic [1-1:0]                                 arid,
  output      logic [7:0]                                   arlen,
  output      logic [2:0]                                   arsize,
  output      logic                                         arlock,
  output      logic [2:0]                                   arprot,
  input  wire logic                                         arready,
  output      logic [3:0]                                   arcache,
  output      logic [3:0]                                   arregion,
  output      logic [3:0]                                   arnsaid,
  output      logic [3:0]                                   arqos,

  output      logic                                         wvalid,
  output      logic                                         wlast,
  output      logic [4-1:0]                                 wstrb,
  output      logic [32-1:0]                                wdata,
  input  wire logic                                         wready,

  input  wire logic                                         rvalid,
  input  wire logic [1-1:0]                                 rid,
  input  wire logic                                         rlast,
  input  wire logic [32-1:0]                                rdata,
  input  wire logic [1:0]                                   rresp,
  output      logic                                         rready,

  input  wire logic                                         bvalid,
  input  wire logic [1-1:0]                                 bid,
  input  wire logic [1:0]                                   bresp,
  output      logic                                         bready,

  output      logic                                         awakeup,

  output      logic                                         clk_qactive,
  input  wire logic                                         clk_qreqn,
  output      logic                                         clk_qacceptn,
  output      logic                                         clk_qdeny,

  output      logic                                         pwr_qactive,
  input  wire logic                                         pwr_qreqn,
  output      logic                                         pwr_qacceptn,
  output      logic                                         pwr_qdeny

);

  wire logic [1+1-1:0] unused = { rid , rlast };

  wire logic unused_hsize = hsize[2];







  logic clk_qreqn_sync;
  logic pwr_qreqn_sync;

  logic                                         awvalid_i;
  logic [32-1:0]                                awaddr_i;
  logic [1:0]                                   awdomain_i;
  logic [1:0]                                   awburst_i;
  logic [1-1:0]                                 awid_i;
  logic [7:0]                                   awlen_i;
  logic [1:0]                                   awsize_i;
  logic                                         awlock_i;
  logic [2:0]                                   awprot_i;
  logic                                         awready_i;
  logic [3:0]                                   awcache_i;
  logic [3:0]                                   awregion_i;
  logic [3:0]                                   awnsaid_i;
  logic [3:0]                                   awqos_i;

  logic                                         arvalid_i;
  logic [32-1:0]                                araddr_i;
  logic [1:0]                                   ardomain_i;
  logic [1:0]                                   arburst_i;
  logic [1-1:0]                                 arid_i;
  logic [7:0]                                   arlen_i;
  logic [1:0]                                   arsize_i;
  logic                                         arlock_i;
  logic [2:0]                                   arprot_i;
  logic                                         arready_i;
  logic [3:0]                                   arcache_i;
  logic [3:0]                                   arregion_i;
  logic [3:0]                                   arnsaid_i;
  logic [3:0]                                   arqos_i;

  logic                                         wvalid_i;
  logic                                         wlast_i;
  logic [4-1:0]                                 wstrb_i;
  logic [32-1:0]                                wdata_i;
  logic                                         wready_i;

  logic                                         rvalid_i;
  logic [32-1:0]                                rdata_i;
  logic [1:0]                                   rresp_i;
  logic                                         rready_i;

  logic                                         bvalid_i;
  logic [1-1:0]                                 bid_i;
  logic [1:0]                                   bresp_i;
  logic                                         bready_i;



  xhb500_sync u_clk_qreqn_sync (
     .clk(clk), .reset_n(resetn), .d(clk_qreqn  ), .q(clk_qreqn_sync)
  );

  xhb500_sync u_pwr_qreqn_sync (
     .clk(clk), .reset_n(resetn), .d(pwr_qreqn  ), .q(pwr_qreqn_sync)
  );



  localparam AX_PAYLOAD_WIDTH = 32+2-1+2+1+8-4+1+1+20;

  localparam W_PAYLOAD_WIDTH  = 1+4+32;

  localparam R_PAYLOAD_WIDTH  = 32+2;

  localparam B_PAYLOAD_WIDTH  = 1+2;

  logic [AX_PAYLOAD_WIDTH-1:0] aw_payload_in;
  logic [AX_PAYLOAD_WIDTH-1:0] aw_payload_out;

  assign aw_payload_in  = {awaddr_i , awdomain_i[1] , awburst_i , awid_i , awlen_i[3:0] , awsize_i , awlock_i , awprot_i , awcache_i , awregion_i , awnsaid_i , awqos_i };

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH(AX_PAYLOAD_WIDTH)
  )
  u_aw_regslice
  (
    .valid_src          (awvalid_i),
    .payload_src        (aw_payload_in),
    .ready_src          (awready_i),
    .valid_dst          (awvalid),
    .payload_dst        (aw_payload_out),
    .ready_dst          (awready)
  );

  assign {awaddr , awdomain[1] , awburst , awid , awlen[3:0] , awsize[1:0] , awlock , awprot , awcache , awregion , awnsaid , awqos } = aw_payload_out;
  assign awdomain[0] = awdomain_i[0];
  assign awlen[7:4] = awlen_i[7:4];

  assign awsize[2] = 1'b0;

  logic [AX_PAYLOAD_WIDTH-1:0] ar_payload_in;
  logic [AX_PAYLOAD_WIDTH-1:0] ar_payload_out;

  assign ar_payload_in  = {araddr_i , ardomain_i[1] , arburst_i , arid_i , arlen_i[3:0] , arsize_i , arlock_i , arprot_i , arcache_i , arregion_i , arnsaid_i , arqos_i };

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH(AX_PAYLOAD_WIDTH)
  )
  u_ar_regslice
  (
    .valid_src          (arvalid_i),
    .payload_src        (ar_payload_in),
    .ready_src          (arready_i),
    .valid_dst          (arvalid),
    .payload_dst        (ar_payload_out),
    .ready_dst          (arready)
  );

  assign {araddr , ardomain[1] , arburst , arid , arlen[3:0] , arsize[1:0] , arlock , arprot , arcache , arregion , arnsaid , arqos } = ar_payload_out;
  assign ardomain[0] = ardomain_i[0];
  assign arlen[7:4] = arlen_i[7:4];

  assign arsize[2] = 1'b0;
  logic [W_PAYLOAD_WIDTH-1:0] w_payload_in;
  logic [W_PAYLOAD_WIDTH-1:0] w_payload_out;

  assign w_payload_in= {wlast_i , wstrb_i , wdata_i} ;

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH(W_PAYLOAD_WIDTH)
  )
  u_w_regslice
  (
    .valid_src          (wvalid_i),
    .payload_src        (w_payload_in),
    .ready_src          (wready_i),
    .valid_dst          (wvalid),
    .payload_dst        (w_payload_out),
    .ready_dst          (wready)
  );

  assign {wlast , wstrb , wdata} = w_payload_out;


  logic [R_PAYLOAD_WIDTH-1:0] r_payload_in;
  logic [R_PAYLOAD_WIDTH-1:0] r_payload_out;

  assign r_payload_in  = {rdata , rresp};

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH(R_PAYLOAD_WIDTH)
  )
  u_r_regslice
  (
    .valid_src          (rvalid),
    .payload_src        (r_payload_in),
    .ready_src          (rready),
    .valid_dst          (rvalid_i),
    .payload_dst        (r_payload_out),
    .ready_dst          (rready_i)
  );

  assign {rdata_i , rresp_i} = r_payload_out;


  logic [B_PAYLOAD_WIDTH-1:0] b_payload_in;
  logic [B_PAYLOAD_WIDTH-1:0] b_payload_out;

  assign b_payload_in  = {bid , bresp};

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH(B_PAYLOAD_WIDTH)
  )
  u_b_regslice
  (
    .valid_src          (bvalid),
    .payload_src        (b_payload_in),
    .ready_src          (bready),
    .valid_dst          (bvalid_i),
    .payload_dst        (b_payload_out),
    .ready_dst          (bready_i)
  );

  assign {bid_i , bresp_i} = b_payload_out;



xhb500_ahb_to_axi_bridge_external_system_core u_core(
   .clk                (clk),
   .resetn             (resetn),

   .buf_write_error_irq(buf_write_error_irq),
   .irq_en             (irq_en),

   .hsel               (hsel),
   .hnonsec            (hnonsec),
   .haddr              (haddr),
   .htrans             (htrans),
   .hsize              (hsize[1:0]),
   .hwrite             (hwrite),
   .hready             (hready),
   .hprot              (hprot),
   .hburst             (hburst),
   .hmastlock          (hmastlock),
   .hwdata             (hwdata),
   .hexcl              (hexcl),
   .hmaster            (hmaster),
   .hrdata             (hrdata),
   .hreadyout          (hreadyout),
   .hresp              (hresp),
   .hexokay            (hexokay),

   .hqos               (hqos),
   .hregion            (hregion),
   .hnsaid             (hnsaid),

   .awvalid            (awvalid_i),
   .awaddr             (awaddr_i),
   .awdomain           (awdomain_i),
   .awburst            (awburst_i),
   .awid               (awid_i),
   .awlen              (awlen_i),
   .awsize             (awsize_i),
   .awlock             (awlock_i),
   .awprot             (awprot_i),
   .awready            (awready_i),
   .awcache            (awcache_i),
   .awregion           (awregion_i),
   .awnsaid            (awnsaid_i),
   .awqos              (awqos_i),

   .arvalid            (arvalid_i),
   .araddr             (araddr_i),
   .ardomain           (ardomain_i),
   .arburst            (arburst_i),
   .arid               (arid_i),
   .arlen              (arlen_i),
   .arsize             (arsize_i),
   .arlock             (arlock_i),
   .arprot             (arprot_i),
   .arready            (arready_i),
   .arcache            (arcache_i),
   .arregion           (arregion_i),
   .arnsaid            (arnsaid_i),
   .arqos              (arqos_i),

   .wvalid             (wvalid_i),
   .wlast              (wlast_i),
   .wstrb              (wstrb_i),
   .wdata              (wdata_i),
   .wready             (wready_i),

   .rvalid             (rvalid_i),
   .rdata              (rdata_i),
   .rresp              (rresp_i),
   .rready             (rready_i),

   .bvalid             (bvalid_i),
   .bid                (bid_i),
   .bresp              (bresp_i),
   .bready             (bready_i),

   .awakeup            (awakeup),

   .clk_qactive        (clk_qactive),
   .clk_qreqn          (clk_qreqn_sync),
   .clk_qacceptn       (clk_qacceptn),
   .clk_qdeny          (clk_qdeny),

   .pwr_qactive        (pwr_qactive),
   .pwr_qreqn          (pwr_qreqn_sync),
   .pwr_qreqn_async    (pwr_qreqn),
   .pwr_qacceptn       (pwr_qacceptn),
   .pwr_qdeny          (pwr_qdeny)

);












endmodule
