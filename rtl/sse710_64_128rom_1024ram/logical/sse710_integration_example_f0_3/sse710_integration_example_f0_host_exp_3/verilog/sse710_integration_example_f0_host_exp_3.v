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

 
 

module sse710_integration_example_f0_host_exp (

    input  wire           aclkout,
    input  wire           refclk,

    input  wire           systop_warmresetn_s_aclkout,
    input  wire           systop_warmresetn_s_refclk,

 
    input  wire           hostexpmst0_awakeup,      
    input  wire [11:0]    hostexpmst0_awid,      
    input  wire [31:0]    hostexpmst0_awaddr,    
    input  wire [7:0]     hostexpmst0_awlen,     
    input  wire [2:0]     hostexpmst0_awsize,    
    input  wire [1:0]     hostexpmst0_awburst,   
    input  wire           hostexpmst0_awlock,
    input  wire [3:0]     hostexpmst0_awcache,
    input  wire [2:0]     hostexpmst0_awprot,    
    input  wire           hostexpmst0_awvalid,
    input  wire [1:0]     hostexpmst0_awuser,
    input  wire [7:0]     hostexpmst0_awmmusid,
    input  wire [3:0]     hostexpmst0_awqos,
    output wire           hostexpmst0_awready,   

    input  wire [7:0]     hostexpmst0_wstrb,     
    input  wire           hostexpmst0_wlast,     
    input  wire           hostexpmst0_wvalid,    
    input  wire [63:0] hostexpmst0_wdata,     
    output wire           hostexpmst0_wready,    

    output wire [11:0]    hostexpmst0_bid,       
    output wire [1:0]     hostexpmst0_bresp,     
    output wire           hostexpmst0_bvalid,    
    input  wire           hostexpmst0_bready,    

    input  wire [11:0]    hostexpmst0_arid,      
    input  wire [31:0]    hostexpmst0_araddr,    
    input  wire [7:0]     hostexpmst0_arlen,     
    input  wire [2:0]     hostexpmst0_arsize,    
    input  wire [1:0]     hostexpmst0_arburst,
    input  wire           hostexpmst0_arlock,
    input  wire [3:0]     hostexpmst0_arcache,
    input  wire [2:0]     hostexpmst0_arprot,     
    input  wire           hostexpmst0_arvalid,
    input  wire [1:0]     hostexpmst0_aruser,
    input  wire [7:0]     hostexpmst0_armmusid,
    input  wire [3:0]     hostexpmst0_arqos,
    output wire           hostexpmst0_arready,   

    output wire [11:0]    hostexpmst0_rid,             
    output wire [1:0]     hostexpmst0_rresp,     
    output wire           hostexpmst0_rlast,     
    output wire           hostexpmst0_rvalid,    
    output wire [63:0] hostexpmst0_rdata,     
    input  wire           hostexpmst0_rready,    
 
    input  wire           hostexpmst1_awakeup,      
    input  wire [11:0]    hostexpmst1_awid,      
    input  wire [31:0]    hostexpmst1_awaddr,    
    input  wire [7:0]     hostexpmst1_awlen,     
    input  wire [2:0]     hostexpmst1_awsize,    
    input  wire [1:0]     hostexpmst1_awburst,   
    input  wire           hostexpmst1_awlock,
    input  wire [3:0]     hostexpmst1_awcache,
    input  wire [2:0]     hostexpmst1_awprot,    
    input  wire           hostexpmst1_awvalid,
    input  wire [1:0]     hostexpmst1_awuser,
    input  wire [7:0]     hostexpmst1_awmmusid,
    input  wire [3:0]     hostexpmst1_awqos,
    output wire           hostexpmst1_awready,   

    input  wire [7:0]     hostexpmst1_wstrb,     
    input  wire           hostexpmst1_wlast,     
    input  wire           hostexpmst1_wvalid,    
    input  wire [63:0] hostexpmst1_wdata,     
    output wire           hostexpmst1_wready,    

    output wire [11:0]    hostexpmst1_bid,       
    output wire [1:0]     hostexpmst1_bresp,     
    output wire           hostexpmst1_bvalid,    
    input  wire           hostexpmst1_bready,    

    input  wire [11:0]    hostexpmst1_arid,      
    input  wire [31:0]    hostexpmst1_araddr,    
    input  wire [7:0]     hostexpmst1_arlen,     
    input  wire [2:0]     hostexpmst1_arsize,    
    input  wire [1:0]     hostexpmst1_arburst,
    input  wire           hostexpmst1_arlock,
    input  wire [3:0]     hostexpmst1_arcache,
    input  wire [2:0]     hostexpmst1_arprot,     
    input  wire           hostexpmst1_arvalid,
    input  wire [1:0]     hostexpmst1_aruser,
    input  wire [7:0]     hostexpmst1_armmusid,
    input  wire [3:0]     hostexpmst1_arqos,
    output wire           hostexpmst1_arready,   

    output wire [11:0]    hostexpmst1_rid,             
    output wire [1:0]     hostexpmst1_rresp,     
    output wire           hostexpmst1_rlast,     
    output wire           hostexpmst1_rvalid,    
    output wire [63:0] hostexpmst1_rdata,     
    input  wire           hostexpmst1_rready,    
 

    output wire           vultan_psel,
    output wire           vultan_penable,
    output wire [31:0]    vultan_paddr,
    output wire           vultan_pwrite,
    output wire [3:0]     vultan_pstrb,
    output wire [31:0]    vultan_pwdata,
    output wire [2:0]     vultan_pprot,
    input  wire [31:0]    vultan_prdata,
    input  wire           vultan_pready,
    input  wire           vultan_pslverr,    

    input  wire [3:0]     aclk_qreqn,
    output wire [3:0]     aclk_qacceptn,
    output wire [3:0]     aclk_qdeny,
    output wire [3:0]     aclk_qactive,
 

     
    output wire           extsys0_slvmustacceptreqn_async,
    output wire           extsys0_slvcandenyreqn_async,
    input  wire           extsys0_slvacceptn_async,
    input  wire           extsys0_slvdeny_async,
    output wire           extsys0_si_to_mi_wakeup_async,
    input  wire           extsys0_mi_to_si_wakeup_async,
    output wire [3:0]     extsys0_aw_wr_ptr_async,
    input  wire [3:0]     extsys0_aw_rd_ptr_async,
    output wire [315:0]   extsys0_aw_payld_async,
    output wire [5:0]     extsys0_w_wr_ptr_async,
    input  wire [5:0]     extsys0_w_rd_ptr_async,
    output wire [221:0]   extsys0_w_payld_async,
    input  wire [1:0]     extsys0_b_wr_ptr_async,
    output wire [1:0]     extsys0_b_rd_ptr_async,
    input  wire [39:0]    extsys0_b_payld_async,
    output wire [3:0]     extsys0_ar_wr_ptr_async,
    input  wire [3:0]     extsys0_ar_rd_ptr_async,
    output wire [315:0]   extsys0_ar_payld_async,
    input  wire [3:0]     extsys0_r_wr_ptr_async,
    output wire [3:0]     extsys0_r_rd_ptr_async,
    input  wire [211:0]   extsys0_r_payld_async, 
           
    input  wire           extsys0_axi_pwr_qreqn,
    output wire           extsys0_axi_pwr_qacceptn,
    output wire           extsys0_axi_pwr_qdeny,
    output wire           extsys0_axi_pwr_qactive,
    
    input  wire           extsys0_apb_pwr_qreqn,
    output wire           extsys0_apb_pwr_qacceptn,
    output wire           extsys0_apb_pwr_qdeny,
    output wire           extsys0_apb_pwr_qactive,
    
    output wire           extsys0_ppu_apb_async_req,
    output wire [47:0]    extsys0_ppu_apb_async_req_payload,
    input  wire [32:0]    extsys0_ppu_apb_async_resp_payload,
    input  wire           extsys0_ppu_apb_async_ack,
     
    output wire           extsys1_slvmustacceptreqn_async,
    output wire           extsys1_slvcandenyreqn_async,
    input  wire           extsys1_slvacceptn_async,
    input  wire           extsys1_slvdeny_async,
    output wire           extsys1_si_to_mi_wakeup_async,
    input  wire           extsys1_mi_to_si_wakeup_async,
    output wire [3:0]     extsys1_aw_wr_ptr_async,
    input  wire [3:0]     extsys1_aw_rd_ptr_async,
    output wire [315:0]   extsys1_aw_payld_async,
    output wire [5:0]     extsys1_w_wr_ptr_async,
    input  wire [5:0]     extsys1_w_rd_ptr_async,
    output wire [221:0]   extsys1_w_payld_async,
    input  wire [1:0]     extsys1_b_wr_ptr_async,
    output wire [1:0]     extsys1_b_rd_ptr_async,
    input  wire [39:0]    extsys1_b_payld_async,
    output wire [3:0]     extsys1_ar_wr_ptr_async,
    input  wire [3:0]     extsys1_ar_rd_ptr_async,
    output wire [315:0]   extsys1_ar_payld_async,
    input  wire [3:0]     extsys1_r_wr_ptr_async,
    output wire [3:0]     extsys1_r_rd_ptr_async,
    input  wire [211:0]   extsys1_r_payld_async, 
           
    input  wire           extsys1_axi_pwr_qreqn,
    output wire           extsys1_axi_pwr_qacceptn,
    output wire           extsys1_axi_pwr_qdeny,
    output wire           extsys1_axi_pwr_qactive,
    
    input  wire           extsys1_apb_pwr_qreqn,
    output wire           extsys1_apb_pwr_qacceptn,
    output wire           extsys1_apb_pwr_qdeny,
    output wire           extsys1_apb_pwr_qactive,
    
    output wire           extsys1_ppu_apb_async_req,
    output wire [47:0]    extsys1_ppu_apb_async_req_payload,
    input  wire [32:0]    extsys1_ppu_apb_async_resp_payload,
    input  wire           extsys1_ppu_apb_async_ack,
 
    
    input  wire [15:0]    gpio_portin,
    output wire [15:0]    gpio_portout,
    output wire [15:0]    gpio_porten,
    output wire [15:0]    gpio_portfunc,    

    output wire           gpio_combint,

    input  wire           dftcgen,
    input  wire           dftrstdisable

  );


  wire           gpio_hsel;
  wire [31:0]    gpio_haddr;
  wire [1:0]     gpio_htrans;
  wire [2:0]     gpio_hsize;
  wire [2:0]     gpio_hburst;
  wire [3:0]     gpio_hprot;
  wire           gpio_hwrite;
  wire           gpio_hready;
  wire [31:0]    gpio_hwdata;
  wire [31:0]    gpio_hrdata;
  wire           gpio_hreadyout;
  wire           gpio_hresp;
  
  wire [3:0]     gpio_eco;

 
  wire           extsys0_awakeup;
  wire           extsys0_awvalid;
  reg            extsys0_awvalid_r;
  wire           extsys0_awready;
  wire [17:0]    extsys0_awid;
  wire [31:0]    extsys0_awaddr;
  wire [31:0]    extsys0_awaddr_flash;
  wire [7:0]     extsys0_awlen;
  wire [2:0]     extsys0_awsize;
  wire [1:0]     extsys0_awburst;
  wire           extsys0_awlock;
  wire [3:0]     extsys0_awcache;
  wire [2:0]     extsys0_awprot;
  wire [3:0]     extsys0_awregion;
  wire [3:0]     extsys0_awqos;
  wire           extsys0_awuser;              
  wire           extsys0_wvalid;
  wire           extsys0_wready;
  wire [31:0]    extsys0_wdata;
  wire [3:0]     extsys0_wstrb;
  wire           extsys0_wlast;
  wire           extsys0_wuser;              
  wire           extsys0_bvalid;
  wire           extsys0_bready;
  wire [17:0]    extsys0_bid;
  wire [1:0]     extsys0_bresp;
  wire           extsys0_buser;              
  wire           extsys0_arvalid;
  reg            extsys0_arvalid_r;
  wire           extsys0_arready;
  wire [17:0]    extsys0_arid;
  wire [31:0]    extsys0_araddr;
  wire [31:0]    extsys0_araddr_flash;   
  wire [7:0]     extsys0_arlen;
  wire [2:0]     extsys0_arsize;
  wire [1:0]     extsys0_arburst;
  wire           extsys0_arlock;
  wire [3:0]     extsys0_arcache;
  wire [2:0]     extsys0_arprot;
  wire [3:0]     extsys0_arregion;
  wire [3:0]     extsys0_arqos;
  wire           extsys0_aruser;           
  wire           extsys0_rvalid;
  wire           extsys0_rready;
  wire [17:0]    extsys0_rid;
  wire [31:0]    extsys0_rdata;
  wire [1:0]     extsys0_rresp;
  wire           extsys0_rlast;
  wire           extsys0_ruser;

  wire           extsys0_ppu_psel;
  wire           extsys0_ppu_penable;
  wire           extsys0_ppu_pwrite;
  wire [31:0]    extsys0_ppu_paddr;
  wire [31:0]    extsys0_ppu_pwdata;
  wire [31:0]    extsys0_ppu_prdata;
  wire           extsys0_ppu_pslverr;
  wire           extsys0_ppu_pready; 
  wire [2:0]     extsys0_ppu_pprot;
  
 
  wire           extsys1_awakeup;
  wire           extsys1_awvalid;
  reg            extsys1_awvalid_r;
  wire           extsys1_awready;
  wire [17:0]    extsys1_awid;
  wire [31:0]    extsys1_awaddr;
  wire [31:0]    extsys1_awaddr_flash;
  wire [7:0]     extsys1_awlen;
  wire [2:0]     extsys1_awsize;
  wire [1:0]     extsys1_awburst;
  wire           extsys1_awlock;
  wire [3:0]     extsys1_awcache;
  wire [2:0]     extsys1_awprot;
  wire [3:0]     extsys1_awregion;
  wire [3:0]     extsys1_awqos;
  wire           extsys1_awuser;              
  wire           extsys1_wvalid;
  wire           extsys1_wready;
  wire [31:0]    extsys1_wdata;
  wire [3:0]     extsys1_wstrb;
  wire           extsys1_wlast;
  wire           extsys1_wuser;              
  wire           extsys1_bvalid;
  wire           extsys1_bready;
  wire [17:0]    extsys1_bid;
  wire [1:0]     extsys1_bresp;
  wire           extsys1_buser;              
  wire           extsys1_arvalid;
  reg            extsys1_arvalid_r;
  wire           extsys1_arready;
  wire [17:0]    extsys1_arid;
  wire [31:0]    extsys1_araddr;
  wire [31:0]    extsys1_araddr_flash;   
  wire [7:0]     extsys1_arlen;
  wire [2:0]     extsys1_arsize;
  wire [1:0]     extsys1_arburst;
  wire           extsys1_arlock;
  wire [3:0]     extsys1_arcache;
  wire [2:0]     extsys1_arprot;
  wire [3:0]     extsys1_arregion;
  wire [3:0]     extsys1_arqos;
  wire           extsys1_aruser;           
  wire           extsys1_rvalid;
  wire           extsys1_rready;
  wire [17:0]    extsys1_rid;
  wire [31:0]    extsys1_rdata;
  wire [1:0]     extsys1_rresp;
  wire           extsys1_rlast;
  wire           extsys1_ruser;

  wire           extsys1_ppu_psel;
  wire           extsys1_ppu_penable;
  wire           extsys1_ppu_pwrite;
  wire [31:0]    extsys1_ppu_paddr;
  wire [31:0]    extsys1_ppu_pwdata;
  wire [31:0]    extsys1_ppu_prdata;
  wire           extsys1_ppu_pslverr;
  wire           extsys1_ppu_pready; 
  wire [2:0]     extsys1_ppu_pprot;
  
 
    
  reg            gpio_combint_r;
  wire           gpio_combint_int;
  
  wire           unused;
 
   
  wire [3:0] hostexpmst0_rid_unused; 
  wire [3:0] hostexpmst0_bid_unused; 
    
 
   
  wire [3:0] hostexpmst1_rid_unused; 
  wire [3:0] hostexpmst1_bid_unused; 
    
  


  nic400_sse710_integration_example_f0_host_exp u_nic400_sse710_integration_example_f0_host_exp (

    .aclkoutclk                    (aclkout),
    .aclkoutclken                  (1'b1),
    .aclkoutresetn                 (systop_warmresetn_s_aclkout),
    .refclk                        (refclk),
    .refresetn                     (systop_warmresetn_s_refclk),

 
    .paddr_extsys0_ppu_abp_m       (extsys0_ppu_paddr),
    .pwdata_extsys0_ppu_abp_m      (extsys0_ppu_pwdata),
    .pwrite_extsys0_ppu_abp_m      (extsys0_ppu_pwrite),
    .penable_extsys0_ppu_abp_m     (extsys0_ppu_penable),
    .pselx_extsys0_ppu_abp_m       (extsys0_ppu_psel),
    .prdata_extsys0_ppu_abp_m      (extsys0_ppu_prdata),
    .pslverr_extsys0_ppu_abp_m     (extsys0_ppu_pslverr),
    .pready_extsys0_ppu_abp_m      (extsys0_ppu_pready),

    .awid_extsys0_axi_m            (extsys0_awid),
    .awaddr_extsys0_axi_m          (extsys0_awaddr),
    .awlen_extsys0_axi_m           (extsys0_awlen),
    .awsize_extsys0_axi_m          (extsys0_awsize),
    .awburst_extsys0_axi_m         (extsys0_awburst),
    .awlock_extsys0_axi_m          (extsys0_awlock),
    .awcache_extsys0_axi_m         (extsys0_awcache),
    .awprot_extsys0_axi_m          (extsys0_awprot),
    .awvalid_extsys0_axi_m         (extsys0_awvalid),
    .awready_extsys0_axi_m         (extsys0_awready),   
    .wdata_extsys0_axi_m           (extsys0_wdata),
    .wstrb_extsys0_axi_m           (extsys0_wstrb),
    .wlast_extsys0_axi_m           (extsys0_wlast),
    .wvalid_extsys0_axi_m          (extsys0_wvalid),
    .wready_extsys0_axi_m          (extsys0_wready), 
    .bid_extsys0_axi_m             (extsys0_bid),
    .bresp_extsys0_axi_m           (extsys0_bresp),
    .bvalid_extsys0_axi_m          (extsys0_bvalid),
    .bready_extsys0_axi_m          (extsys0_bready),  
    .arid_extsys0_axi_m            (extsys0_arid),
    .araddr_extsys0_axi_m          (extsys0_araddr),
    .arlen_extsys0_axi_m           (extsys0_arlen),
    .arsize_extsys0_axi_m          (extsys0_arsize),
    .arburst_extsys0_axi_m         (extsys0_arburst),
    .arlock_extsys0_axi_m          (extsys0_arlock),
    .arcache_extsys0_axi_m         (extsys0_arcache),
    .arprot_extsys0_axi_m          (extsys0_arprot),
    .arvalid_extsys0_axi_m         (extsys0_arvalid),
    .arready_extsys0_axi_m         (extsys0_arready),   
    .rid_extsys0_axi_m             (extsys0_rid),
    .rdata_extsys0_axi_m           (extsys0_rdata),
    .rresp_extsys0_axi_m           (extsys0_rresp),
    .rlast_extsys0_axi_m           (extsys0_rlast),
    .rvalid_extsys0_axi_m          (extsys0_rvalid),
    .rready_extsys0_axi_m          (extsys0_rready),
 
    .paddr_extsys1_ppu_abp_m       (extsys1_ppu_paddr),
    .pwdata_extsys1_ppu_abp_m      (extsys1_ppu_pwdata),
    .pwrite_extsys1_ppu_abp_m      (extsys1_ppu_pwrite),
    .penable_extsys1_ppu_abp_m     (extsys1_ppu_penable),
    .pselx_extsys1_ppu_abp_m       (extsys1_ppu_psel),
    .prdata_extsys1_ppu_abp_m      (extsys1_ppu_prdata),
    .pslverr_extsys1_ppu_abp_m     (extsys1_ppu_pslverr),
    .pready_extsys1_ppu_abp_m      (extsys1_ppu_pready),

    .awid_extsys1_axi_m            (extsys1_awid),
    .awaddr_extsys1_axi_m          (extsys1_awaddr),
    .awlen_extsys1_axi_m           (extsys1_awlen),
    .awsize_extsys1_axi_m          (extsys1_awsize),
    .awburst_extsys1_axi_m         (extsys1_awburst),
    .awlock_extsys1_axi_m          (extsys1_awlock),
    .awcache_extsys1_axi_m         (extsys1_awcache),
    .awprot_extsys1_axi_m          (extsys1_awprot),
    .awvalid_extsys1_axi_m         (extsys1_awvalid),
    .awready_extsys1_axi_m         (extsys1_awready),   
    .wdata_extsys1_axi_m           (extsys1_wdata),
    .wstrb_extsys1_axi_m           (extsys1_wstrb),
    .wlast_extsys1_axi_m           (extsys1_wlast),
    .wvalid_extsys1_axi_m          (extsys1_wvalid),
    .wready_extsys1_axi_m          (extsys1_wready), 
    .bid_extsys1_axi_m             (extsys1_bid),
    .bresp_extsys1_axi_m           (extsys1_bresp),
    .bvalid_extsys1_axi_m          (extsys1_bvalid),
    .bready_extsys1_axi_m          (extsys1_bready),  
    .arid_extsys1_axi_m            (extsys1_arid),
    .araddr_extsys1_axi_m          (extsys1_araddr),
    .arlen_extsys1_axi_m           (extsys1_arlen),
    .arsize_extsys1_axi_m          (extsys1_arsize),
    .arburst_extsys1_axi_m         (extsys1_arburst),
    .arlock_extsys1_axi_m          (extsys1_arlock),
    .arcache_extsys1_axi_m         (extsys1_arcache),
    .arprot_extsys1_axi_m          (extsys1_arprot),
    .arvalid_extsys1_axi_m         (extsys1_arvalid),
    .arready_extsys1_axi_m         (extsys1_arready),   
    .rid_extsys1_axi_m             (extsys1_rid),
    .rdata_extsys1_axi_m           (extsys1_rdata),
    .rresp_extsys1_axi_m           (extsys1_rresp),
    .rlast_extsys1_axi_m           (extsys1_rlast),
    .rvalid_extsys1_axi_m          (extsys1_rvalid),
    .rready_extsys1_axi_m          (extsys1_rready),
     

    .paddr_vultan_apb_m            (vultan_paddr),
    .pwdata_vultan_apb_m           (vultan_pwdata), 
    .pwrite_vultan_apb_m           (vultan_pwrite),
    .pstrb_vultan_apb_m            (vultan_pstrb),
    .penable_vultan_apb_m          (vultan_penable),
    .pselx_vultan_apb_m            (vultan_psel),
    .prdata_vultan_apb_m           (vultan_prdata),
    .pslverr_vultan_apb_m          (vultan_pslverr),
    .pready_vultan_apb_m           (vultan_pready),
    .pprot_vultan_apb_m            (vultan_pprot),

 
   
    .awid_hostexpmst_0_s           ({4'b0 ,hostexpmst0_awid}),
   
    .awaddr_hostexpmst_0_s         (hostexpmst0_awaddr),
    .awlen_hostexpmst_0_s          (hostexpmst0_awlen),
    .awsize_hostexpmst_0_s         (hostexpmst0_awsize),
    .awburst_hostexpmst_0_s        (hostexpmst0_awburst),
    .awlock_hostexpmst_0_s         (hostexpmst0_awlock),
    .awcache_hostexpmst_0_s        (hostexpmst0_awcache),
    .awprot_hostexpmst_0_s         (hostexpmst0_awprot),
    .awvalid_hostexpmst_0_s        (hostexpmst0_awvalid),
    .awready_hostexpmst_0_s        (hostexpmst0_awready),
    .wdata_hostexpmst_0_s          (hostexpmst0_wdata),
    .wstrb_hostexpmst_0_s          (hostexpmst0_wstrb),
    .wlast_hostexpmst_0_s          (hostexpmst0_wlast),
    .wvalid_hostexpmst_0_s         (hostexpmst0_wvalid),
    .wready_hostexpmst_0_s         (hostexpmst0_wready),
   
    .bid_hostexpmst_0_s            ({hostexpmst0_bid_unused, hostexpmst0_bid}),
   
    .bresp_hostexpmst_0_s          (hostexpmst0_bresp),
    .bvalid_hostexpmst_0_s         (hostexpmst0_bvalid),
    .bready_hostexpmst_0_s         (hostexpmst0_bready),
   
    .arid_hostexpmst_0_s           ({4'b0 ,hostexpmst0_arid}),
       
    .araddr_hostexpmst_0_s         (hostexpmst0_araddr),
    .arlen_hostexpmst_0_s          (hostexpmst0_arlen),
    .arsize_hostexpmst_0_s         (hostexpmst0_arsize),
    .arburst_hostexpmst_0_s        (hostexpmst0_arburst),
    .arlock_hostexpmst_0_s         (hostexpmst0_arlock),
    .arcache_hostexpmst_0_s        (hostexpmst0_arcache),
    .arprot_hostexpmst_0_s         (hostexpmst0_arprot),
    .arvalid_hostexpmst_0_s        (hostexpmst0_arvalid),
    .arready_hostexpmst_0_s        (hostexpmst0_arready),
   
    .rid_hostexpmst_0_s            ({hostexpmst0_rid_unused, hostexpmst0_rid}),
   
    .rdata_hostexpmst_0_s          (hostexpmst0_rdata),
    .rresp_hostexpmst_0_s          (hostexpmst0_rresp),
    .rlast_hostexpmst_0_s          (hostexpmst0_rlast),
    .rvalid_hostexpmst_0_s         (hostexpmst0_rvalid),
    .rready_hostexpmst_0_s         (hostexpmst0_rready),
 
   
    .awid_hostexpmst_1_s           ({4'b0 ,hostexpmst1_awid}),
   
    .awaddr_hostexpmst_1_s         (hostexpmst1_awaddr),
    .awlen_hostexpmst_1_s          (hostexpmst1_awlen),
    .awsize_hostexpmst_1_s         (hostexpmst1_awsize),
    .awburst_hostexpmst_1_s        (hostexpmst1_awburst),
    .awlock_hostexpmst_1_s         (hostexpmst1_awlock),
    .awcache_hostexpmst_1_s        (hostexpmst1_awcache),
    .awprot_hostexpmst_1_s         (hostexpmst1_awprot),
    .awvalid_hostexpmst_1_s        (hostexpmst1_awvalid),
    .awready_hostexpmst_1_s        (hostexpmst1_awready),
    .wdata_hostexpmst_1_s          (hostexpmst1_wdata),
    .wstrb_hostexpmst_1_s          (hostexpmst1_wstrb),
    .wlast_hostexpmst_1_s          (hostexpmst1_wlast),
    .wvalid_hostexpmst_1_s         (hostexpmst1_wvalid),
    .wready_hostexpmst_1_s         (hostexpmst1_wready),
   
    .bid_hostexpmst_1_s            ({hostexpmst1_bid_unused, hostexpmst1_bid}),
   
    .bresp_hostexpmst_1_s          (hostexpmst1_bresp),
    .bvalid_hostexpmst_1_s         (hostexpmst1_bvalid),
    .bready_hostexpmst_1_s         (hostexpmst1_bready),
   
    .arid_hostexpmst_1_s           ({4'b0 ,hostexpmst1_arid}),
       
    .araddr_hostexpmst_1_s         (hostexpmst1_araddr),
    .arlen_hostexpmst_1_s          (hostexpmst1_arlen),
    .arsize_hostexpmst_1_s         (hostexpmst1_arsize),
    .arburst_hostexpmst_1_s        (hostexpmst1_arburst),
    .arlock_hostexpmst_1_s         (hostexpmst1_arlock),
    .arcache_hostexpmst_1_s        (hostexpmst1_arcache),
    .arprot_hostexpmst_1_s         (hostexpmst1_arprot),
    .arvalid_hostexpmst_1_s        (hostexpmst1_arvalid),
    .arready_hostexpmst_1_s        (hostexpmst1_arready),
   
    .rid_hostexpmst_1_s            ({hostexpmst1_rid_unused, hostexpmst1_rid}),
   
    .rdata_hostexpmst_1_s          (hostexpmst1_rdata),
    .rresp_hostexpmst_1_s          (hostexpmst1_rresp),
    .rlast_hostexpmst_1_s          (hostexpmst1_rlast),
    .rvalid_hostexpmst_1_s         (hostexpmst1_rvalid),
    .rready_hostexpmst_1_s         (hostexpmst1_rready),
 

    .hselx_gpio_ahb_m              (gpio_hsel),
    .haddr_gpio_ahb_m              (gpio_haddr),
    .htrans_gpio_ahb_m             (gpio_htrans),
    .hwrite_gpio_ahb_m             (gpio_hwrite),
    .hsize_gpio_ahb_m              (gpio_hsize),
    .hburst_gpio_ahb_m             (gpio_hburst),
    .hprot_gpio_ahb_m              (gpio_hprot),
    .hwdata_gpio_ahb_m             (gpio_hwdata),
    .hrdata_gpio_ahb_m             (gpio_hrdata),
    .hreadyout_gpio_ahb_m          (gpio_hreadyout),
    .hready_gpio_ahb_m             (gpio_hready),
    .hresp_gpio_ahb_m              (gpio_hresp)

  );


  always@(posedge aclkout or negedge systop_warmresetn_s_aclkout)
  begin
    if(!systop_warmresetn_s_aclkout)
    begin
 
      extsys0_awvalid_r <= 1'b0;
      extsys0_arvalid_r <= 1'b0;
 
      extsys1_awvalid_r <= 1'b0;
      extsys1_arvalid_r <= 1'b0;
 
    end
    else
    begin
 
      extsys0_awvalid_r <= extsys0_awvalid;
      extsys0_arvalid_r <= extsys0_arvalid;
 
      extsys1_awvalid_r <= extsys1_awvalid;
      extsys1_arvalid_r <= extsys1_arvalid;
 
    end
  end

   
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_arm_element_or_tree_0 (
    .or_tree_i  ({extsys0_awvalid_r, extsys0_arvalid_r}),
    .or_tree_o  (extsys0_awakeup)
  );
   
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_arm_element_or_tree_1 (
    .or_tree_i  ({extsys1_awvalid_r, extsys1_arvalid_r}),
    .or_tree_o  (extsys1_awakeup)
  );
 

    

  sse710_adb400_r3_axi4_slv_wrapper #(
    .ADDR_WIDTH             (32),
    .DATA_WIDTH             (32),
    .AWID_WIDTH             (18),
    .ARID_WIDTH             (18),
    .AWUSER_WIDTH           (0), 
    .WUSER_WIDTH            (0), 
    .BUSER_WIDTH            (0), 
    .ARUSER_WIDTH           (0), 
    .RUSER_WIDTH            (0), 
    .AW_FIFO_DEPTH          (4), 
    .W_FIFO_DEPTH           (6), 
    .B_FIFO_DEPTH           (2), 
    .AR_FIFO_DEPTH          (4), 
    .R_FIFO_DEPTH           (4), 
    .B_OPREG                (1), 
    .R_OPREG                (1), 
    .SI_SYNC_LEVELS         (2),
    .AW_PAYLOAD_WIDTH       (316),
    .W_PAYLOAD_WIDTH        (222),
    .B_PAYLOAD_WIDTH        (40),
    .AR_PAYLOAD_WIDTH       (316),
    .R_PAYLOAD_WIDTH        (212)    
  ) u_sse710_adb400_r3_axi4_slv_wrapper_0 (
    .pwrq_permit_deny_sar_i         (1'b1),
    .aclks                          (aclkout),
    .aresetns                       (systop_warmresetn_s_aclkout),
    
    .pwrqreqns_i                    (extsys0_axi_pwr_qreqn),
    .pwrqacceptns_o                 (extsys0_axi_pwr_qacceptn),
    .pwrqdenys_o                    (extsys0_axi_pwr_qdeny),
    
    .clkqreqns_i                    (aclk_qreqn[0]),
    .clkqacceptns_o                 (aclk_qacceptn[0]),
    .clkqdenys_o                    (aclk_qdeny[0]),   
    .clkqactives_o                  (aclk_qactive[0]), 
    
    .pwrqactives_o                  (extsys0_axi_pwr_qactive),
    
    .wakeups_i                      (extsys0_awakeup),
    .awvalids                       (extsys0_awvalid),
    .awreadys                       (extsys0_awready),
    .awusers                        (extsys0_awuser),
    .awids                          (extsys0_awid),
    .awaddrs                        (extsys0_awaddr_flash),
    .awregions                      (extsys0_awregion),          
    .awlens                         (extsys0_awlen),
    .awsizes                        (extsys0_awsize),
    .awbursts                       (extsys0_awburst),
    .awlocks                        (extsys0_awlock),
    .awcaches                       (extsys0_awcache),
    .awprots                        (extsys0_awprot),
    .awqoss                         (extsys0_awqos),  
    
    .wvalids                        (extsys0_wvalid),
    .wreadys                        (extsys0_wready),
    .wusers                         (extsys0_wuser),
    .wdatas                         (extsys0_wdata),
    .wstrbs                         (extsys0_wstrb),
    .wlasts                         (extsys0_wlast),
    
    .bvalids                        (extsys0_bvalid),
    .breadys                        (extsys0_bready),
    .busers                         (extsys0_buser),
    .bids                           (extsys0_bid),
    .bresps                         (extsys0_bresp),
    
    .arvalids                       (extsys0_arvalid),
    .arreadys                       (extsys0_arready),
    .arusers                        (extsys0_aruser),
    .arids                          (extsys0_arid),
    .araddrs                        (extsys0_araddr_flash),
    .arregions                      (extsys0_arregion),                     
    .arlens                         (extsys0_arlen),
    .arsizes                        (extsys0_arsize),
    .arbursts                       (extsys0_arburst),
    .arlocks                        (extsys0_arlock),
    .arcaches                       (extsys0_arcache),
    .arprots                        (extsys0_arprot),
    .arqoss                         (extsys0_arqos), 
    
    .rvalids                        (extsys0_rvalid),
    .rreadys                        (extsys0_rready),
    .rusers                         (extsys0_ruser),
    .rids                           (extsys0_rid),
    .rdatas                         (extsys0_rdata),
    .rresps                         (extsys0_rresp),
    .rlasts                         (extsys0_rlast),
    
    .slvmustacceptreqn_async        (extsys0_slvmustacceptreqn_async),
    .slvcandenyreqn_async           (extsys0_slvcandenyreqn_async),
    .slvacceptn_async               (extsys0_slvacceptn_async),
    .slvdeny_async                  (extsys0_slvdeny_async),
    .si_to_mi_wakeup_async          (extsys0_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async          (extsys0_mi_to_si_wakeup_async),
    .aw_wr_ptr_async                (extsys0_aw_wr_ptr_async),
    .aw_rd_ptr_async                (extsys0_aw_rd_ptr_async),
    .aw_payld_async                 (extsys0_aw_payld_async),
    .w_wr_ptr_async                 (extsys0_w_wr_ptr_async),
    .w_rd_ptr_async                 (extsys0_w_rd_ptr_async),
    .w_payld_async                  (extsys0_w_payld_async),
    .b_wr_ptr_async                 (extsys0_b_wr_ptr_async),
    .b_rd_ptr_async                 (extsys0_b_rd_ptr_async),
    .b_payld_async                  (extsys0_b_payld_async),
    .ar_wr_ptr_async                (extsys0_ar_wr_ptr_async),
    .ar_rd_ptr_async                (extsys0_ar_rd_ptr_async),
    .ar_payld_async                 (extsys0_ar_payld_async),
    .r_wr_ptr_async                 (extsys0_r_wr_ptr_async),
    .r_rd_ptr_async                 (extsys0_r_rd_ptr_async),
    .r_payld_async                  (extsys0_r_payld_async),
    
    .dftrstdisables                 (dftrstdisable)
    );
  
  assign extsys0_awregion = 4'h0;
  assign extsys0_arregion = 4'h0;
  
  assign extsys0_awqos     = 4'h0;
  assign extsys0_arqos     = 4'h0;
  
  assign extsys0_araddr_flash = {14'h0000,extsys0_araddr[17:0]};  
  assign extsys0_awaddr_flash = {14'h0000,extsys0_awaddr[17:0]};
  
  assign extsys0_awuser = 1'b0;
  assign extsys0_aruser = 1'b0;
  assign extsys0_wuser  = 1'b0;
    

  sse710_adb400_r3_axi4_slv_wrapper #(
    .ADDR_WIDTH             (32),
    .DATA_WIDTH             (32),
    .AWID_WIDTH             (18),
    .ARID_WIDTH             (18),
    .AWUSER_WIDTH           (0), 
    .WUSER_WIDTH            (0), 
    .BUSER_WIDTH            (0), 
    .ARUSER_WIDTH           (0), 
    .RUSER_WIDTH            (0), 
    .AW_FIFO_DEPTH          (4), 
    .W_FIFO_DEPTH           (6), 
    .B_FIFO_DEPTH           (2), 
    .AR_FIFO_DEPTH          (4), 
    .R_FIFO_DEPTH           (4), 
    .B_OPREG                (1), 
    .R_OPREG                (1), 
    .SI_SYNC_LEVELS         (2),
    .AW_PAYLOAD_WIDTH       (316),
    .W_PAYLOAD_WIDTH        (222),
    .B_PAYLOAD_WIDTH        (40),
    .AR_PAYLOAD_WIDTH       (316),
    .R_PAYLOAD_WIDTH        (212)    
  ) u_sse710_adb400_r3_axi4_slv_wrapper_1 (
    .pwrq_permit_deny_sar_i         (1'b1),
    .aclks                          (aclkout),
    .aresetns                       (systop_warmresetn_s_aclkout),
    
    .pwrqreqns_i                    (extsys1_axi_pwr_qreqn),
    .pwrqacceptns_o                 (extsys1_axi_pwr_qacceptn),
    .pwrqdenys_o                    (extsys1_axi_pwr_qdeny),
    
    .clkqreqns_i                    (aclk_qreqn[1]),
    .clkqacceptns_o                 (aclk_qacceptn[1]),
    .clkqdenys_o                    (aclk_qdeny[1]),   
    .clkqactives_o                  (aclk_qactive[1]), 
    
    .pwrqactives_o                  (extsys1_axi_pwr_qactive),
    
    .wakeups_i                      (extsys1_awakeup),
    .awvalids                       (extsys1_awvalid),
    .awreadys                       (extsys1_awready),
    .awusers                        (extsys1_awuser),
    .awids                          (extsys1_awid),
    .awaddrs                        (extsys1_awaddr_flash),
    .awregions                      (extsys1_awregion),          
    .awlens                         (extsys1_awlen),
    .awsizes                        (extsys1_awsize),
    .awbursts                       (extsys1_awburst),
    .awlocks                        (extsys1_awlock),
    .awcaches                       (extsys1_awcache),
    .awprots                        (extsys1_awprot),
    .awqoss                         (extsys1_awqos),  
    
    .wvalids                        (extsys1_wvalid),
    .wreadys                        (extsys1_wready),
    .wusers                         (extsys1_wuser),
    .wdatas                         (extsys1_wdata),
    .wstrbs                         (extsys1_wstrb),
    .wlasts                         (extsys1_wlast),
    
    .bvalids                        (extsys1_bvalid),
    .breadys                        (extsys1_bready),
    .busers                         (extsys1_buser),
    .bids                           (extsys1_bid),
    .bresps                         (extsys1_bresp),
    
    .arvalids                       (extsys1_arvalid),
    .arreadys                       (extsys1_arready),
    .arusers                        (extsys1_aruser),
    .arids                          (extsys1_arid),
    .araddrs                        (extsys1_araddr_flash),
    .arregions                      (extsys1_arregion),                     
    .arlens                         (extsys1_arlen),
    .arsizes                        (extsys1_arsize),
    .arbursts                       (extsys1_arburst),
    .arlocks                        (extsys1_arlock),
    .arcaches                       (extsys1_arcache),
    .arprots                        (extsys1_arprot),
    .arqoss                         (extsys1_arqos), 
    
    .rvalids                        (extsys1_rvalid),
    .rreadys                        (extsys1_rready),
    .rusers                         (extsys1_ruser),
    .rids                           (extsys1_rid),
    .rdatas                         (extsys1_rdata),
    .rresps                         (extsys1_rresp),
    .rlasts                         (extsys1_rlast),
    
    .slvmustacceptreqn_async        (extsys1_slvmustacceptreqn_async),
    .slvcandenyreqn_async           (extsys1_slvcandenyreqn_async),
    .slvacceptn_async               (extsys1_slvacceptn_async),
    .slvdeny_async                  (extsys1_slvdeny_async),
    .si_to_mi_wakeup_async          (extsys1_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async          (extsys1_mi_to_si_wakeup_async),
    .aw_wr_ptr_async                (extsys1_aw_wr_ptr_async),
    .aw_rd_ptr_async                (extsys1_aw_rd_ptr_async),
    .aw_payld_async                 (extsys1_aw_payld_async),
    .w_wr_ptr_async                 (extsys1_w_wr_ptr_async),
    .w_rd_ptr_async                 (extsys1_w_rd_ptr_async),
    .w_payld_async                  (extsys1_w_payld_async),
    .b_wr_ptr_async                 (extsys1_b_wr_ptr_async),
    .b_rd_ptr_async                 (extsys1_b_rd_ptr_async),
    .b_payld_async                  (extsys1_b_payld_async),
    .ar_wr_ptr_async                (extsys1_ar_wr_ptr_async),
    .ar_rd_ptr_async                (extsys1_ar_rd_ptr_async),
    .ar_payld_async                 (extsys1_ar_payld_async),
    .r_wr_ptr_async                 (extsys1_r_wr_ptr_async),
    .r_rd_ptr_async                 (extsys1_r_rd_ptr_async),
    .r_payld_async                  (extsys1_r_payld_async),
    
    .dftrstdisables                 (dftrstdisable)
    );
  
  assign extsys1_awregion = 4'h0;
  assign extsys1_arregion = 4'h0;
  
  assign extsys1_awqos     = 4'h0;
  assign extsys1_arqos     = 4'h0;
  
  assign extsys1_araddr_flash = {14'h0000,extsys1_araddr[17:0]};  
  assign extsys1_awaddr_flash = {14'h0000,extsys1_awaddr[17:0]};
  
  assign extsys1_awuser = 1'b0;
  assign extsys1_aruser = 1'b0;
  assign extsys1_wuser  = 1'b0;
 

  cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK      (16'hFFFF), 
    .ALTERNATE_FUNC_DEFAULT   (16'h0000), 
    .BE                       (0)         
  ) u_cmsdk_ahb_gpio (
    .HCLK                (refclk),
    .FCLK                (refclk),
    .HRESETn             (systop_warmresetn_s_refclk),

    .HSEL                (gpio_hsel),
    .HREADY              (gpio_hready),
    .HTRANS              (gpio_htrans),
    .HSIZE               (gpio_hsize),
    .HWRITE              (gpio_hwrite),
    .HADDR               (gpio_haddr[11:0]),
    .HWDATA              (gpio_hwdata),
    
    .ECOREVNUM           (gpio_eco),
    
    .HREADYOUT           (gpio_hreadyout),
    .HRESP               (gpio_hresp),
    .HRDATA              (gpio_hrdata),

    .PORTIN              (gpio_portin),
    .PORTOUT             (gpio_portout),
    .PORTEN              (gpio_porten),
    .PORTFUNC            (gpio_portfunc),

    .GPIOINT             (),
    .COMBINT             (gpio_combint_int)
    );
    
  always @(posedge refclk or negedge systop_warmresetn_s_refclk)
  begin
    if(!systop_warmresetn_s_refclk)
      gpio_combint_r <= 1'b0;
    else
      gpio_combint_r <= gpio_combint_int;
  end
  
  assign gpio_combint = gpio_combint_r;

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_arm_element_ecorevnum (
    .ecorevnum (gpio_eco)
  ); 
  
 

  css600_apbasyncbridgeslv u_css600_apbasyncbridgeslv_0 (
    .clk_s                      (aclkout),
    .reset_s_n                  (systop_warmresetn_s_aclkout),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (extsys0_ppu_psel),
    .penable_s                  (extsys0_ppu_penable),
    .paddr_s                    (extsys0_ppu_paddr[11:0]),
    .pwrite_s                   (extsys0_ppu_pwrite),
    .pwdata_s                   (extsys0_ppu_pwdata),
    .pprot_s                    (extsys0_ppu_pprot),
    .prdata_s                   (extsys0_ppu_prdata),
    .pready_s                   (extsys0_ppu_pready),
    .pslverr_s                  (extsys0_ppu_pslverr),
    .pwakeup_s                  (extsys0_ppu_psel),
    
    .clk_s_qreq_n               (aclk_qreqn[2]),
    .clk_s_qaccept_n            (aclk_qacceptn[2]),
    .clk_s_qdeny                (aclk_qdeny[2]),   
    .clk_s_qactive              (aclk_qactive[2]), 
    
    .pwr_qreq_n                 (extsys0_apb_pwr_qreqn),   
    .pwr_qaccept_n              (extsys0_apb_pwr_qacceptn),
    .pwr_qdeny                  (extsys0_apb_pwr_qdeny),   
    .pwr_qactive                (extsys0_apb_pwr_qactive), 
    
    .apb_async_req              (extsys0_ppu_apb_async_req),
    .apb_async_req_payload      (extsys0_ppu_apb_async_req_payload),
    .apb_async_resp_payload     (extsys0_ppu_apb_async_resp_payload),
    .apb_async_ack              (extsys0_ppu_apb_async_ack)
  );
  
  assign extsys0_ppu_pprot = 3'b000;  
 

  css600_apbasyncbridgeslv u_css600_apbasyncbridgeslv_1 (
    .clk_s                      (aclkout),
    .reset_s_n                  (systop_warmresetn_s_aclkout),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (extsys1_ppu_psel),
    .penable_s                  (extsys1_ppu_penable),
    .paddr_s                    (extsys1_ppu_paddr[11:0]),
    .pwrite_s                   (extsys1_ppu_pwrite),
    .pwdata_s                   (extsys1_ppu_pwdata),
    .pprot_s                    (extsys1_ppu_pprot),
    .prdata_s                   (extsys1_ppu_prdata),
    .pready_s                   (extsys1_ppu_pready),
    .pslverr_s                  (extsys1_ppu_pslverr),
    .pwakeup_s                  (extsys1_ppu_psel),
    
    .clk_s_qreq_n               (aclk_qreqn[3]),
    .clk_s_qaccept_n            (aclk_qacceptn[3]),
    .clk_s_qdeny                (aclk_qdeny[3]),   
    .clk_s_qactive              (aclk_qactive[3]), 
    
    .pwr_qreq_n                 (extsys1_apb_pwr_qreqn),   
    .pwr_qaccept_n              (extsys1_apb_pwr_qacceptn),
    .pwr_qdeny                  (extsys1_apb_pwr_qdeny),   
    .pwr_qactive                (extsys1_apb_pwr_qactive), 
    
    .apb_async_req              (extsys1_ppu_apb_async_req),
    .apb_async_req_payload      (extsys1_ppu_apb_async_req_payload),
    .apb_async_resp_payload     (extsys1_ppu_apb_async_resp_payload),
    .apb_async_ack              (extsys1_ppu_apb_async_ack)
  );
  
  assign extsys1_ppu_pprot = 3'b000;  
 
  
  assign unused = (|gpio_hprot)               |
 
                  (|hostexpmst0_awuser)       |
                  (|hostexpmst0_aruser)       |
                  (|hostexpmst0_armmusid)     |
                  (|hostexpmst0_awmmusid)     |
                  ( hostexpmst0_awakeup)      |                  
                  (|hostexpmst0_awqos)        |                  
                  (|hostexpmst0_arqos)        |    
 
                  (|hostexpmst1_awuser)       |
                  (|hostexpmst1_aruser)       |
                  (|hostexpmst1_armmusid)     |
                  (|hostexpmst1_awmmusid)     |
                  ( hostexpmst1_awakeup)      |                  
                  (|hostexpmst1_awqos)        |                  
                  (|hostexpmst1_arqos)        |    
 
 
                  (|extsys0_awaddr[31:18])    |
                  (|extsys0_araddr[31:18])    |
                  (|extsys0_ppu_paddr[31:12]) |
                  (|extsys0_ruser)            |
                  (|extsys0_buser)            |
 
                  (|extsys1_awaddr[31:18])    |
                  (|extsys1_araddr[31:18])    |
                  (|extsys1_ppu_paddr[31:12]) |
                  (|extsys1_ruser)            |
                  (|extsys1_buser)            |
 
 
   
                  (|hostexpmst0_rid_unused)   | 
                  (|hostexpmst0_bid_unused)   | 
    
 
   
                  (|hostexpmst1_rid_unused)   | 
                  (|hostexpmst1_bid_unused)   | 
    
 
                  (|gpio_haddr[31:12])        |
                  (|gpio_hburst);
  
endmodule
