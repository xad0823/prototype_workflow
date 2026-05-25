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

module sec_firewall (
    input  wire          clk,
    input  wire          rstn,

    input  wire          fctlr_arid_s_i,
    input  wire [31:0]   fctlr_araddr_s_i,
    input  wire [7:0]    fctlr_arlen_s_i,
    input  wire [2:0]    fctlr_arsize_s_i,
    input  wire [1:0]    fctlr_arburst_s_i,
    input  wire          fctlr_arlock_s_i,
    input  wire [3:0]    fctlr_arcache_s_i,
    input  wire [2:0]    fctlr_arprot_s_i,
    input  wire [3:0]    fctlr_arqos_s_i,
    input  wire [3:0]    fctlr_arregion_s_i,
    input  wire          fctlr_aruser_s_i,
    input  wire          fctlr_arvalid_s_i,
    output wire          fctlr_arready_s_o,

    input  wire          fctlr_awid_s_i,
    input  wire [31:0]   fctlr_awaddr_s_i,
    input  wire [7:0]    fctlr_awlen_s_i,
    input  wire [2:0]    fctlr_awsize_s_i,
    input  wire [1:0]    fctlr_awburst_s_i,
    input  wire          fctlr_awlock_s_i,
    input  wire [3:0]    fctlr_awcache_s_i,
    input  wire [2:0]    fctlr_awprot_s_i,
    input  wire [3:0]    fctlr_awqos_s_i,
    input  wire [3:0]    fctlr_awregion_s_i,
    input  wire          fctlr_awuser_s_i,
    input  wire          fctlr_awvalid_s_i,
    output wire          fctlr_awready_s_o,

    input  wire [31:0]   fctlr_wdata_s_i,
    input  wire [3:0]    fctlr_wstrb_s_i,
    input  wire          fctlr_wlast_s_i,
    input  wire          fctlr_wuser_s_i,
    input  wire          fctlr_wvalid_s_i,
    output wire          fctlr_wready_s_o,

    output wire          fctlr_bid_s_o,
    output wire [1:0]    fctlr_bresp_s_o,
    output wire          fctlr_buser_s_o,
    output wire          fctlr_bvalid_s_o,
    input  wire          fctlr_bready_s_i,

    output wire          fctlr_rid_s_o,
    output wire [31:0]   fctlr_rdata_s_o,
    output wire [1:0]    fctlr_rresp_s_o,
    output wire          fctlr_rlast_s_o,
    output wire          fctlr_ruser_s_o,
    output wire          fctlr_rvalid_s_o,
    input  wire          fctlr_rready_s_i,
    
    input  wire          arid_s_i,
    input  wire [31:0]   araddr_s_i,
    input  wire [7:0]    arlen_s_i,
    input  wire [2:0]    arsize_s_i,
    input  wire [1:0]    arburst_s_i,
    input  wire          arlock_s_i,
    input  wire [3:0]    arcache_s_i,
    input  wire [2:0]    arprot_s_i,
    input  wire [3:0]    arqos_s_i,
    input  wire [3:0]    arregion_s_i,
    input  wire          aruser_s_i,
    input  wire          arvalid_s_i,
    output wire          arready_s_o,

    input  wire          awid_s_i,
    input  wire [31:0]   awaddr_s_i,
    input  wire [7:0]    awlen_s_i,
    input  wire [2:0]    awsize_s_i,
    input  wire [1:0]    awburst_s_i,
    input  wire          awlock_s_i,
    input  wire [3:0]    awcache_s_i,
    input  wire [2:0]    awprot_s_i,
    input  wire [3:0]    awqos_s_i,
    input  wire [3:0]    awregion_s_i,
    input  wire          awuser_s_i,
    input  wire          awvalid_s_i,
    output wire          awready_s_o,

    input  wire [31:0]   wdata_s_i,
    input  wire [3:0]    wstrb_s_i,
    input  wire          wlast_s_i,
    input  wire          wuser_s_i,
    input  wire          wvalid_s_i,
    output wire          wready_s_o,

    output wire          bid_s_o,
    output wire [1:0]    bresp_s_o,
    output wire          buser_s_o,
    output wire          bvalid_s_o,
    input  wire          bready_s_i,

    output wire          rid_s_o,
    output wire [31:0]   rdata_s_o,
    output wire [1:0]    rresp_s_o,
    output wire          rlast_s_o,
    output wire          ruser_s_o,
    output wire          rvalid_s_o,
    input  wire          rready_s_i,

    output wire          arid_m_o,
    output wire [31:0]   araddr_m_o,
    output wire [7:0]    arlen_m_o,
    output wire [2:0]    arsize_m_o,
    output wire [1:0]    arburst_m_o,
    output wire          arlock_m_o,
    output wire [3:0]    arcache_m_o,
    output wire [2:0]    arprot_m_o,
    output wire [3:0]    arqos_m_o,
    output wire [3:0]    arregion_m_o,
    output wire          aruser_m_o,
    output wire          arvalid_m_o,
    input  wire          arready_m_i,

    output wire          awid_m_o,
    output wire [31:0]   awaddr_m_o,
    output wire [7:0]    awlen_m_o,
    output wire [2:0]    awsize_m_o,
    output wire [1:0]    awburst_m_o,
    output wire          awlock_m_o,
    output wire [3:0]    awcache_m_o,
    output wire [2:0]    awprot_m_o,
    output wire [3:0]    awqos_m_o,
    output wire [3:0]    awregion_m_o,
    output wire          awuser_m_o,
    output wire          awvalid_m_o,
    input  wire          awready_m_i,

    output wire [31:0]   wdata_m_o,
    output wire [3:0]    wstrb_m_o,
    output wire          wlast_m_o,
    output wire          wuser_m_o,
    output wire          wvalid_m_o,
    input  wire          wready_m_i,

    input  wire          bid_m_i,
    input  wire [1:0]    bresp_m_i,
    input  wire          buser_m_i,
    input  wire          bvalid_m_i,
    output wire          bready_m_o,

    input  wire          rid_m_i,
    input  wire [31:0]   rdata_m_i,
    input  wire [1:0]    rresp_m_i,
    input  wire          rlast_m_i,
    input  wire          ruser_m_i,
    input  wire          rvalid_m_i,
    output wire          rready_m_o,

    output wire          awakeup_m_o,

    input  wire          bypass_i,
    output wire          interrupt,
    
    input  wire          dftcgen    
);

`ifndef SE_FPGA

wire tvalid_ds;
wire tready_ds;
wire [31:0] tdata_ds;
wire [3:0] tkeep_ds;
wire tlast_ds;
wire tid_ds;
wire twakeup_ds;

wire tvalid_us;
wire tready_us;
wire [31:0] tdata_us;
wire [3:0] tkeep_us;
wire tlast_us;
wire tdest_us;
wire twakeup_us;

wire unused;


assign unused = |{fctlr_araddr_s_i, fctlr_arqos_s_i, fctlr_arregion_s_i, fctlr_aruser_s_i,
                  fctlr_awaddr_s_i, fctlr_awqos_s_i, fctlr_awregion_s_i, fctlr_awuser_s_i,
                  fctlr_wuser_s_i};

reg fctlr_awakeup_s;
reg awakeup_s;

always @(posedge clk or negedge rstn)
begin
  if (!rstn)
  begin
    fctlr_awakeup_s <= 1'b0;
    awakeup_s       <= 1'b0;
  end
  else
  begin
    fctlr_awakeup_s <= fctlr_arvalid_s_i | fctlr_awvalid_s_i | fctlr_wvalid_s_i;
    awakeup_s       <= arvalid_s_i       | awvalid_s_i       | wvalid_s_i;
  end
end


`include "firewall_f0_global_masterid_cfg_secenc.vh"
`include "firewall_f0_ctlr_global_cfg_secenc.vh"

firewall_f0_ctlr #(
    `include "firewall_f0_ctlr_cfg_secenc.vh"
) u_fw_ctlr_secenc (
    .clk                (clk),
    .reset_n            (rstn),
    .dftcgen            (dftcgen),
    .dftrambyp          (1'b0),
    .dftramhold         (1'b0),
    
    .arid_s_i           (fctlr_arid_s_i),
    .araddr_s_i         (fctlr_araddr_s_i[20:0]),
    .arlen_s_i          (fctlr_arlen_s_i),
    .arsize_s_i         (fctlr_arsize_s_i),
    .arburst_s_i        (fctlr_arburst_s_i),
    .arlock_s_i         (fctlr_arlock_s_i),
    .arcache_s_i        (fctlr_arcache_s_i),
    .arprot_s_i         (fctlr_arprot_s_i),
    .arvalid_s_i        (fctlr_arvalid_s_i),
    .arready_s_o        (fctlr_arready_s_o),
    .armmusid_s_i       (1'b0),

    .awid_s_i           (fctlr_awid_s_i),
    .awaddr_s_i         (fctlr_awaddr_s_i[20:0]),
    .awlen_s_i          (fctlr_awlen_s_i),
    .awsize_s_i         (fctlr_awsize_s_i),
    .awburst_s_i        (fctlr_awburst_s_i),
    .awlock_s_i         (fctlr_awlock_s_i),
    .awcache_s_i        (fctlr_awcache_s_i),
    .awprot_s_i         (fctlr_awprot_s_i),
    .awvalid_s_i        (fctlr_awvalid_s_i),
    .awready_s_o        (fctlr_awready_s_o),
    .awmmusid_s_i       (1'b0),

    .wdata_s_i          (fctlr_wdata_s_i),
    .wstrb_s_i          (fctlr_wstrb_s_i),
    .wlast_s_i          (fctlr_wlast_s_i),
    .wvalid_s_i         (fctlr_wvalid_s_i),
    .wready_s_o         (fctlr_wready_s_o),

    .bid_s_o            (fctlr_bid_s_o),
    .bresp_s_o          (fctlr_bresp_s_o),
    .buser_s_o          (fctlr_buser_s_o),
    .bvalid_s_o         (fctlr_bvalid_s_o),
    .bready_s_i         (fctlr_bready_s_i),

    .rid_s_o            (fctlr_rid_s_o),
    .rdata_s_o          (fctlr_rdata_s_o),
    .rresp_s_o          (fctlr_rresp_s_o),
    .rlast_s_o          (fctlr_rlast_s_o),
    .ruser_s_o          (fctlr_ruser_s_o),
    .rvalid_s_o         (fctlr_rvalid_s_o),
    .rready_s_i         (fctlr_rready_s_i),

    .awakeup_s_i        (fctlr_awakeup_s),

    .tvalid_ds_i        (tvalid_ds),
    .tready_ds_o        (tready_ds),
    .tdata_ds_i         (tdata_ds),
    .tkeep_ds_i         (tkeep_ds),
    .tlast_ds_i         (tlast_ds),
    .tid_ds_i           (tid_ds),
    .twakeup_ds_i       (twakeup_ds),

    .tvalid_us_o        (tvalid_us),
    .tready_us_i        (tready_us),
    .tdata_us_o         (tdata_us),
    .tkeep_us_o         (tkeep_us),
    .tlast_us_o         (tlast_us),
    .tdest_us_o         (tdest_us),
    .twakeup_us_o       (twakeup_us),

    .clk_qreqn_i        (1'b1),
    .clk_qacceptn_o     (),
    .clk_qdeny_o        (),
    .clk_qactive_o      (),

    .pwr_preq_i         (1'b0),
    .pwr_paccept_o      (),
    .pwr_pdeny_o        (),
    .pwr_pactive_o      (),
    .pwr_pstate_i       (4'b1000),

    .lockdown_i         (1'b0),
    .interrupt_o        (interrupt),
    .tamper_interrupt_o (),
    .protsize_i         (8'd32),
    .bypass_i           (bypass_i)
    
);

firewall_f0_comp #(
    `include "firewall_f0_comp_cfg_secenc_add_remap.vh"
) u_fw_comp_secenc (
    .clk          (clk),
    .reset_n      (rstn),

    .arid_s_i     (arid_s_i),
    .araddr_s_i   (araddr_s_i),
    .arlen_s_i    (arlen_s_i),
    .arsize_s_i   (arsize_s_i),
    .arburst_s_i  (arburst_s_i),
    .arlock_s_i   (arlock_s_i),
    .arcache_s_i  (arcache_s_i),
    .arprot_s_i   (arprot_s_i),
    .arqos_s_i    (arqos_s_i),
    .arregion_s_i (arregion_s_i),
    .aruser_s_i   (aruser_s_i),
    .arvalid_s_i  (arvalid_s_i),
    .arready_s_o  (arready_s_o),
    .armmusid_s_i (1'b0),

    .awid_s_i     (awid_s_i),
    .awaddr_s_i   (awaddr_s_i),
    .awlen_s_i    (awlen_s_i),
    .awsize_s_i   (awsize_s_i),
    .awburst_s_i  (awburst_s_i),
    .awlock_s_i   (awlock_s_i),
    .awcache_s_i  (awcache_s_i),
    .awprot_s_i   (awprot_s_i),
    .awqos_s_i    (awqos_s_i),
    .awregion_s_i (awregion_s_i),
    .awuser_s_i   (awuser_s_i),
    .awvalid_s_i  (awvalid_s_i),
    .awready_s_o  (awready_s_o),
    .awmmusid_s_i (1'b0),

    .wdata_s_i    (wdata_s_i),
    .wstrb_s_i    (wstrb_s_i),
    .wlast_s_i    (wlast_s_i),
    .wuser_s_i    (wuser_s_i),
    .wvalid_s_i   (wvalid_s_i),
    .wready_s_o   (wready_s_o),

    .bid_s_o      (bid_s_o),
    .bresp_s_o    (bresp_s_o),
    .buser_s_o    (buser_s_o),
    .bvalid_s_o   (bvalid_s_o),
    .bready_s_i   (bready_s_i),

    .rid_s_o      (rid_s_o),
    .rdata_s_o    (rdata_s_o),
    .rresp_s_o    (rresp_s_o),
    .rlast_s_o    (rlast_s_o),
    .ruser_s_o    (ruser_s_o),
    .rvalid_s_o   (rvalid_s_o),
    .rready_s_i   (rready_s_i),

    .awakeup_s_i  (awakeup_s),

    .arid_m_o     (arid_m_o),
    .araddr_m_o   (araddr_m_o),
    .arlen_m_o    (arlen_m_o),
    .arsize_m_o   (arsize_m_o),
    .arburst_m_o  (arburst_m_o),
    .arlock_m_o   (arlock_m_o),
    .arcache_m_o  (arcache_m_o),
    .arprot_m_o   (arprot_m_o),
    .arqos_m_o    (arqos_m_o),
    .arregion_m_o (arregion_m_o),
    .aruser_m_o   (aruser_m_o),
    .arvalid_m_o  (arvalid_m_o),
    .arready_m_i  (arready_m_i),
    .armmusid_m_o (),

    .awid_m_o     (awid_m_o),
    .awaddr_m_o   (awaddr_m_o),
    .awlen_m_o    (awlen_m_o),
    .awsize_m_o   (awsize_m_o),
    .awburst_m_o  (awburst_m_o),
    .awlock_m_o   (awlock_m_o),
    .awcache_m_o  (awcache_m_o),
    .awprot_m_o   (awprot_m_o),
    .awqos_m_o    (awqos_m_o),
    .awregion_m_o (awregion_m_o),
    .awuser_m_o   (awuser_m_o),
    .awvalid_m_o  (awvalid_m_o),
    .awready_m_i  (awready_m_i),
    .awmmusid_m_o (),

    .wdata_m_o    (wdata_m_o),
    .wstrb_m_o    (wstrb_m_o),
    .wlast_m_o    (wlast_m_o),
    .wuser_m_o    (wuser_m_o),
    .wvalid_m_o   (wvalid_m_o),
    .wready_m_i   (wready_m_i),

    .bid_m_i      (bid_m_i),
    .bresp_m_i    (bresp_m_i),
    .buser_m_i    (buser_m_i),
    .bvalid_m_i   (bvalid_m_i),
    .bready_m_o   (bready_m_o),

    .rid_m_i      (rid_m_i),
    .rdata_m_i    (rdata_m_i),
    .rresp_m_i    (rresp_m_i),
    .rlast_m_i    (rlast_m_i),
    .ruser_m_i    (ruser_m_i),
    .rvalid_m_i   (rvalid_m_i),
    .rready_m_o   (rready_m_o),

    .awakeup_m_o  (awakeup_m_o),

    .tvalid_ds_o  (tvalid_ds),
    .tready_ds_i  (tready_ds),
    .tdata_ds_o   (tdata_ds),
    .tkeep_ds_o   (tkeep_ds),
    .tlast_ds_o   (tlast_ds),
    .tid_ds_o     (tid_ds),
    .twakeup_ds_o (twakeup_ds),
    
    .tvalid_us_i  (tvalid_us),
    .tready_us_o  (tready_us),
    .tdata_us_i   (tdata_us),
    .tkeep_us_i   (tkeep_us),
    .tlast_us_i   (tlast_us),
    .tdest_us_i   (tdest_us),
    .twakeup_us_i (twakeup_us),

    .clk_qreqn_i    (1'b1),
    .clk_qacceptn_o (),
    .clk_qdeny_o    (),
    .clk_qactive_o  (),

    .pwr_qreqn_i    (1'b1),
    .pwr_qacceptn_o (),
    .pwr_qdeny_o    (),
    .pwr_qactive_o  (),

    .bypass_i       (bypass_i),
    
    .dftcgen        (dftcgen)
);

`else


  assign fctlr_arready_s_o = 1'b1;
  assign fctlr_awready_s_o = 1'b1;
  assign fctlr_wready_s_o  = 1'b1;
  assign fctlr_bid_s_o     = 1'b0;
  assign fctlr_bresp_s_o   = 2'b0;
  assign fctlr_buser_s_o   = 1'b0;
  assign fctlr_bvalid_s_o  = 1'b0;
  assign fctlr_rid_s_o     = 1'b0;
  assign fctlr_rdata_s_o   = 32'b0;
  assign fctlr_rresp_s_o   = 2'b0;
  assign fctlr_rlast_s_o   = 1'b0;
  assign fctlr_ruser_s_o   = 1'b0;
  assign fctlr_rvalid_s_o  = 1'b0;

    assign interrupt         = 1'b0;
  
  assign arready_s_o =  arready_m_i;  
  assign awready_s_o =  awready_m_i;     
  assign wready_s_o =   wready_m_i;
  assign bid_s_o =      bid_m_i;
  assign bresp_s_o =    bresp_m_i;
  assign buser_s_o =    buser_m_i;
  assign bvalid_s_o =   bvalid_m_i;
  assign rid_s_o =      rid_m_i;
  assign rdata_s_o =    rdata_m_i;
  assign rresp_s_o =    rresp_m_i;
  assign rlast_s_o =    rlast_m_i;
  assign ruser_s_o =    ruser_m_i;
  assign rvalid_s_o =   rvalid_m_i;

  assign arid_m_o =     arid_s_i;
  assign araddr_m_o =   araddr_s_i;
  assign arlen_m_o =    arlen_s_i;
  assign arsize_m_o =   arsize_s_i;
  assign arburst_m_o =  arburst_s_i;
  assign arlock_m_o =   arlock_s_i;
  assign arcache_m_o =  arcache_s_i;
  assign arprot_m_o =   arprot_s_i;
  assign arqos_m_o =    arqos_s_i;
  assign arregion_m_o = arregion_s_i;
  assign aruser_m_o =   aruser_s_i;
  assign arvalid_m_o =  arvalid_s_i;
  assign awid_m_o =     awid_s_i;
  assign awaddr_m_o =   awaddr_s_i;
  assign awlen_m_o =    awlen_s_i;
  assign awsize_m_o =   awsize_s_i;
  assign awburst_m_o =  awburst_s_i;
  assign awlock_m_o =   awlock_s_i;
  assign awcache_m_o =  awcache_s_i;
  assign awprot_m_o =   awprot_s_i;
  assign awqos_m_o =    awqos_s_i;
  assign awregion_m_o = awregion_s_i;
  assign awuser_m_o =   awuser_s_i;
  assign awvalid_m_o =  awvalid_s_i;
  assign wdata_m_o =    wdata_s_i;
  assign wstrb_m_o =    wstrb_s_i;
  assign wlast_m_o =    wlast_s_i;
  assign wuser_m_o =    wuser_s_i;
  assign wvalid_m_o =   wvalid_s_i;
  assign bready_m_o =   bready_s_i;
  assign rready_m_o =   rready_s_i;

  assign awakeup_m_o =  arvalid_s_i | awvalid_s_i | wvalid_s_i;

`endif
endmodule
