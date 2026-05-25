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

module sse710_integration_example_f0_flash_system (

    input  wire           aclkout,

    input  wire           systop_warmresetn_s,

    input  wire           xnvm_awakeup,
    input  wire [11:0]    xnvm_awid,
    input  wire [31:0]    xnvm_awaddr,
    input  wire [7:0]     xnvm_awlen,
    input  wire [2:0]     xnvm_awsize,
    input  wire [1:0]     xnvm_awburst,
    input  wire           xnvm_awlock,
    input  wire [3:0]     xnvm_awcache,
    input  wire [2:0]     xnvm_awprot,    
    input  wire           xnvm_awvalid,
    input  wire [1:0]     xnvm_awuser,
    input  wire [7:0]     xnvm_awmmusid,
    input  wire [3:0]     xnvm_awqos,
    output wire           xnvm_awready,

    input  wire [7:0]     xnvm_wstrb,
    input  wire           xnvm_wlast,
    input  wire           xnvm_wvalid,
    input  wire [63:0]    xnvm_wdata,
    output wire           xnvm_wready,

    output wire [11:0]    xnvm_bid,
    output wire [1:0]     xnvm_bresp,
    output wire           xnvm_bvalid,
    input  wire           xnvm_bready,

    input  wire [11:0]    xnvm_arid,
    input  wire [31:0]    xnvm_araddr,
    input  wire [7:0]     xnvm_arlen,
    input  wire [2:0]     xnvm_arsize,
    input  wire [1:0]     xnvm_arburst,
    input  wire           xnvm_arlock,
    input  wire [3:0]     xnvm_arcache,
    input  wire [2:0]     xnvm_arprot,    
    input  wire           xnvm_arvalid,
    input  wire [1:0]     xnvm_aruser,
    input  wire [7:0]     xnvm_armmusid,
    input  wire [3:0]     xnvm_arqos,
    output wire           xnvm_arready,

    output wire [11:0]    xnvm_rid,
    output wire [1:0]     xnvm_rresp,
    output wire           xnvm_rlast,
    output wire           xnvm_rvalid,
    output wire [63:0]    xnvm_rdata,
    input  wire           xnvm_rready,

    input  wire           vultan_clk_qreqn,
    output wire           vultan_clk_qacceptn,
    output wire           vultan_clk_qdeny,
    output wire           vultan_clk_qactive,

    input  wire           vultan_pwr_qreqn,
    output wire           vultan_pwr_qacceptn,
    output wire           vultan_pwr_qdeny,
    output wire           vultan_pwr_qactive,

    output wire           vultan_irq,

    input  wire           vultan_psel_s,
    input  wire           vultan_penable_s,
    input  wire [31:0]    vultan_paddr_s,
    input  wire           vultan_pwrite_s,
    input  wire [3:0]     vultan_pstrb_s,
    input  wire [31:0]    vultan_pwdata_s,
    input  wire [2:0]     vultan_pprot_s,
    output wire [31:0]    vultan_prdata_s,
    output wire           vultan_pready_s,
    output wire           vultan_pslverr_s,

    output wire           vultan_psel_m,
    output wire           vultan_penable_m,
    output wire [11:0]    vultan_paddr_m,
    output wire           vultan_pwrite_m,
    output wire [3:0]     vultan_pstrb_m,
    output wire [31:0]    vultan_pwdata_m,
    input  wire [31:0]    vultan_prdata_m,
    input  wire           vultan_pready_m,
    input  wire           vultan_pslverr_m,

    output wire [21:0]    vultan_faddr,
    output wire [2:0]     vultan_fcmd,
    output wire           vultan_fabort,
    output wire [31:0]    vultan_fwdata,
    input  wire [127:0]   vultan_frdata,
    input  wire           vultan_fready,
    input  wire           vultan_fresp,

    output wire           vultan_preq,
    output wire           vultan_pstate,
    input  wire           vultan_paccept,
    input  wire           vultan_pdeny,
    input  wire           vultan_pactive,

    output wire           vultan_flash_pwr_rdy
  );


  wire [11:0]      xhb_awid;
  wire [31:0]      xhb_awaddr;
  wire [7:0]       xhb_awlen;
  wire [2:0]       xhb_awsize;
  wire [1:0]       xhb_awburst;
  wire             xhb_awlock;
  wire [3:0]       xhb_awcache;
  wire [2:0]       xhb_awprot;
  wire             xhb_awvalid;
  wire             xhb_awready;
  
  wire [15:0]      xhb_wstrb;
  wire             xhb_wlast;
  wire             xhb_wvalid;
  wire [127:0]     xhb_wdata;
  wire             xhb_wready;

  wire [11:0]      xhb_bid;
  wire [1:0]       xhb_bresp;
  wire             xhb_bvalid;
  wire             xhb_bready;

  wire [11:0]      xhb_arid;
  wire [31:0]      xhb_araddr;
  wire [7:0]       xhb_arlen;
  wire [2:0]       xhb_arsize;
  wire [1:0]       xhb_arburst;
  wire             xhb_arlock;
  wire [3:0]       xhb_arcache;
  wire [2:0]       xhb_arprot;  
  wire             xhb_arvalid;
  wire             xhb_arready;

  wire [11:0]      xhb_rid;
  wire [1:0]       xhb_rresp;
  wire             xhb_rlast;
  wire             xhb_rvalid;
  wire [127:0]     xhb_rdata;
  wire             xhb_rready;

  wire             vultan_hsel;
  wire [31:0]      vultan_haddr;
  wire [1:0]       vultan_htrans;
  wire             vultan_hwrite;
  wire [2:0]       vultan_hsize;
  wire [2:0]       vultan_hburst;
  wire             vultan_hmastlock;
  wire             vultan_hreadyout;
  wire             vultan_hresp;
  wire [127:0]     vultan_hrdata;
  wire             vultan_hnonsec;
  wire [6:0]       vultan_hprot;
  wire             vultan_hexcl;
  wire             vultan_hexokay;
  
  wire             vultan_irq_int;
  reg              vultan_irq_r;
  
  reg              vultan_gfb_activity_r;
  wire             nxt_vultan_gfb_activity;
  wire             vultan_pwr_qacceptn_int;
  wire             vultan_clk_qactive_int;
  wire             vultan_pwr_qactive_int;  
  
  wire             unused;


  nic400_sse710_integration_example_f0_flash u_nic400_sse710_integration_example_f0_flash (
    .aclkoutclk                (aclkout),
    .aclkoutresetn             (systop_warmresetn_s),  
    
    .awid_xnvm_axi_m           (xhb_awid),
    .awaddr_xnvm_axi_m         (xhb_awaddr),
    .awlen_xnvm_axi_m          (xhb_awlen),
    .awsize_xnvm_axi_m         (xhb_awsize),
    .awburst_xnvm_axi_m        (xhb_awburst),
    .awlock_xnvm_axi_m         (xhb_awlock),
    .awcache_xnvm_axi_m        (xhb_awcache),
    .awprot_xnvm_axi_m         (xhb_awprot),
    .awvalid_xnvm_axi_m        (xhb_awvalid),
    .awready_xnvm_axi_m        (xhb_awready),
    
    .wdata_xnvm_axi_m          (xhb_wdata),
    .wstrb_xnvm_axi_m          (xhb_wstrb),
    .wlast_xnvm_axi_m          (xhb_wlast),
    .wvalid_xnvm_axi_m         (xhb_wvalid),
    .wready_xnvm_axi_m         (xhb_wready),
    
    .bid_xnvm_axi_m            (xhb_bid),
    .bresp_xnvm_axi_m          (xhb_bresp),
    .bvalid_xnvm_axi_m         (xhb_bvalid),
    .bready_xnvm_axi_m         (xhb_bready),
    
    .arid_xnvm_axi_m           (xhb_arid),
    .araddr_xnvm_axi_m         (xhb_araddr),
    .arlen_xnvm_axi_m          (xhb_arlen),
    .arsize_xnvm_axi_m         (xhb_arsize),
    .arburst_xnvm_axi_m        (xhb_arburst),
    .arlock_xnvm_axi_m         (xhb_arlock),
    .arcache_xnvm_axi_m        (xhb_arcache),
    .arprot_xnvm_axi_m         (xhb_arprot),
    .arvalid_xnvm_axi_m        (xhb_arvalid),
    .arready_xnvm_axi_m        (xhb_arready),
    
    .rid_xnvm_axi_m            (xhb_rid),
    .rdata_xnvm_axi_m          (xhb_rdata),
    .rresp_xnvm_axi_m          (xhb_rresp),
    .rlast_xnvm_axi_m          (xhb_rlast),
    .rvalid_xnvm_axi_m         (xhb_rvalid),
    .rready_xnvm_axi_m         (xhb_rready),
    
    .awid_xnvm_axi_s           (xnvm_awid),
    .awaddr_xnvm_axi_s         (xnvm_awaddr),
    .awlen_xnvm_axi_s          (xnvm_awlen),
    .awsize_xnvm_axi_s         (xnvm_awsize),
    .awburst_xnvm_axi_s        (xnvm_awburst),
    .awlock_xnvm_axi_s         (xnvm_awlock),
    .awcache_xnvm_axi_s        (xnvm_awcache),
    .awprot_xnvm_axi_s         (xnvm_awprot),
    .awvalid_xnvm_axi_s        (xnvm_awvalid),
    .awready_xnvm_axi_s        (xnvm_awready),
                               
    .wdata_xnvm_axi_s          (xnvm_wdata),
    .wstrb_xnvm_axi_s          (xnvm_wstrb),
    .wlast_xnvm_axi_s          (xnvm_wlast),
    .wvalid_xnvm_axi_s         (xnvm_wvalid),
    .wready_xnvm_axi_s         (xnvm_wready),
                               
    .bid_xnvm_axi_s            (xnvm_bid),
    .bresp_xnvm_axi_s          (xnvm_bresp),
    .bvalid_xnvm_axi_s         (xnvm_bvalid),
    .bready_xnvm_axi_s         (xnvm_bready),
                               
    .arid_xnvm_axi_s           (xnvm_arid),
    .araddr_xnvm_axi_s         (xnvm_araddr),
    .arlen_xnvm_axi_s          (xnvm_arlen),
    .arsize_xnvm_axi_s         (xnvm_arsize),
    .arburst_xnvm_axi_s        (xnvm_arburst),
    .arlock_xnvm_axi_s         (xnvm_arlock),
    .arcache_xnvm_axi_s        (xnvm_arcache),
    .arprot_xnvm_axi_s         (xnvm_arprot),
    .arvalid_xnvm_axi_s        (xnvm_arvalid),
    .arready_xnvm_axi_s        (xnvm_arready),
                               
    .rid_xnvm_axi_s            (xnvm_rid),
    .rdata_xnvm_axi_s          (xnvm_rdata),
    .rresp_xnvm_axi_s          (xnvm_rresp),
    .rlast_xnvm_axi_s          (xnvm_rlast),
    .rvalid_xnvm_axi_s         (xnvm_rvalid),
    .rready_xnvm_axi_s         (xnvm_rready)   
  );


  xhb500_axi_to_ahb_bridge_flash  u_xhb500_axi_to_ahb_bridge_flash (
      
    .clk               (aclkout),
    .resetn            (systop_warmresetn_s),
   
    .clk_qreqn         (1'b1),
    .clk_qacceptn      (),
    .clk_qdeny         (),
    .clk_qactive       (),
   
    .pwr_qreqn         (1'b1),
    .pwr_qacceptn      (),
    .pwr_qdeny         (),
    .pwr_qactive       (),
   
    .awvalid           (xhb_awvalid),
    .awready           (xhb_awready),
    .awaddr            (xhb_awaddr),
    .awburst           (xhb_awburst),
    .awid              (xhb_awid),
    .awlen             (xhb_awlen),
    .awsize            (xhb_awsize),
    .awlock            (xhb_awlock),
    .awprot            (xhb_awprot),
    .awcache           (xhb_awcache),
    
    .arvalid           (xhb_arvalid),
    .arready           (xhb_arready),
    .araddr            (xhb_araddr),
    .arburst           (xhb_arburst),
    .arid              (xhb_arid),
    .arlen             (xhb_arlen),
    .arsize            (xhb_arsize),
    .arlock            (xhb_arlock),
    .arprot            (xhb_arprot),
    .arcache           (xhb_arcache),
    
    .wvalid            (xhb_wvalid),
    .wready            (xhb_wready),
    .wlast             (xhb_wlast),
    .wstrb             (xhb_wstrb),
    .wdata             (xhb_wdata),
    
    .rvalid            (xhb_rvalid),
    .rready            (xhb_rready),
    .rid               (xhb_rid),
    .rlast             (xhb_rlast),
    .rdata             (xhb_rdata),
    .rresp             (xhb_rresp),
    
    .bvalid            (xhb_bvalid),
    .bready            (xhb_bready),
    .bid               (xhb_bid),
    .bresp             (xhb_bresp),                                      
   
    .ardomain          (2'b00),
    .awdomain          (2'b00),
   
    .awakeup           (1'b1), 
    .awnsaid           (4'h0),
    .arnsaid           (4'h0),
    .awqos             (4'h0),
    .arqos             (4'h0),
    .awregion          (4'h0),
    .arregion          (4'h0),
    
    .awsparse          (1'b1),
    
    .hnsaid            (),
    .hregion           (),
    .hqos              (),   
   
    .hnonsec           (vultan_hnonsec), 
    .haddr             (vultan_haddr),
    .htrans            (vultan_htrans),
    .hsize             (vultan_hsize),
    .hwrite            (vultan_hwrite),
    .hprot             (vultan_hprot),                        
    .hburst            (vultan_hburst),
    .hmastlock         (vultan_hmastlock),
    .hwdata            (),
    .hexcl             (vultan_hexcl),               
    .hmaster           (),
    .hrdata            (vultan_hrdata),
    .hready            (vultan_hreadyout),
    .hresp             (vultan_hresp),
    .hexokay           (vultan_hexokay)
  );


  vultan_top u_vultan_top (
    .clk             (aclkout),
    .resetn          (systop_warmresetn_s),

    .hsel            (vultan_hsel),
    .haddr           (vultan_haddr[21:0]),
    .htrans          (vultan_htrans),
    .hwrite          (vultan_hwrite),
    .hsize           (3'b100),            
    .hburst          (vultan_hburst),
    .hmastlock       (vultan_hmastlock),
    .hready          (vultan_hreadyout),
    .hreadyout       (vultan_hreadyout),
    .hresp           (vultan_hresp),
    .hrdata          (vultan_hrdata),
                      
    .psel_s          (vultan_psel_s),
    .penable_s       (vultan_penable_s),
    .paddr_s         (vultan_paddr_s[12:0]),
    .pwrite_s        (vultan_pwrite_s),
    .pstrb_s         (vultan_pstrb_s),
    .pwdata_s        (vultan_pwdata_s),
    .prdata_s        (vultan_prdata_s),
    .pready_s        (vultan_pready_s),
    .pslverr_s       (vultan_pslverr_s),
                      
    .psel_m          (vultan_psel_m),
    .penable_m       (vultan_penable_m),
    .paddr_m         (vultan_paddr_m),
    .pwrite_m        (vultan_pwrite_m),
    .pstrb_m         (vultan_pstrb_m),
    .pwdata_m        (vultan_pwdata_m),
    .prdata_m        (vultan_prdata_m),
    .pready_m        (vultan_pready_m),
    .pslverr_m       (vultan_pslverr_m),
                      
    .faddr           (vultan_faddr),
    .fcmd            (vultan_fcmd),
    .fabort          (vultan_fabort),
    .fwdata          (vultan_fwdata),
    .frdata          (vultan_frdata),
    .fready          (vultan_fready),
    .fresp           (vultan_fresp),
                      
    .qreqn_clk       (vultan_clk_qreqn),
    .qacceptn_clk    (vultan_clk_qacceptn),
    .qdeny_clk       (vultan_clk_qdeny),
    .qactive_clk     (vultan_clk_qactive_int),
                      
    .qreqn_pwr       (vultan_pwr_qreqn),
    .qacceptn_pwr    (vultan_pwr_qacceptn_int),
    .qdeny_pwr       (vultan_pwr_qdeny),
    .qactive_pwr     (vultan_pwr_qactive_int),
                      
    .preq            (vultan_preq),
    .pstate          (vultan_pstate),
    .paccept         (vultan_paccept),
    .pdeny           (vultan_pdeny),
    .pactive         (vultan_pactive),
     
    .irq             (vultan_irq_int),
    .flash_pwr_rdy   (vultan_flash_pwr_rdy)
    );
    
  assign vultan_pwr_qacceptn = vultan_pwr_qacceptn_int;
  
  assign vultan_hsel = 1'b1; 
  
  assign vultan_hexokay = 1'b0;
  
  always @(posedge aclkout or negedge systop_warmresetn_s)
  begin
    if(!systop_warmresetn_s)
      vultan_irq_r <= 1'b0;
    else
      vultan_irq_r <= vultan_irq_int;
  end
  
  assign vultan_irq = vultan_irq_r;
  
  
  always @(posedge aclkout or negedge systop_warmresetn_s)
  begin
    if(!systop_warmresetn_s)
      vultan_gfb_activity_r <= 1'b0;
    else
      vultan_gfb_activity_r <= nxt_vultan_gfb_activity;
  end
  
  assign nxt_vultan_gfb_activity = vultan_pwr_qacceptn_int & ~vultan_fready; 

  arm_element_std_or2 u_arm_element_std_or2_0
  (
    .A (vultan_clk_qactive_int),
    .B (vultan_gfb_activity_r),
    .Y (vultan_clk_qactive)
  );

  arm_element_std_or2 u_arm_element_std_or2_1
  (
    .A (vultan_pwr_qactive_int),
    .B (vultan_gfb_activity_r),
    .Y (vultan_pwr_qactive)
  );
  
  
  assign unused = (|xnvm_aruser)         |
                  (|xnvm_awuser)         |
                  (|xnvm_awmmusid)       |
                  (|xnvm_armmusid)       |
                  (|xnvm_arqos)          |
                  (|xnvm_awqos)          |
                  ( xnvm_awakeup)        |
                  (|vultan_pprot_s)      |
                  (|vultan_hnonsec)      |
                  (|vultan_hprot)        |
                  (|vultan_hexcl)        |
                  (|vultan_haddr[31:22]) |
                  (|vultan_hsize)        |
                  (|vultan_paddr_s[31:13]);

endmodule
