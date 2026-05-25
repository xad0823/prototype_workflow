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


module nic400_bm0_sse710_integration_example_f0_cvm
  (

    awid_axi_s_0,
    awaddr_axi_s_0,
    awlen_axi_s_0,
    awsize_axi_s_0,
    awburst_axi_s_0,
    awlock_axi_s_0,
    awcache_axi_s_0,
    awprot_axi_s_0,
    awvalid_axi_s_0,
    awvalid_vect_axi_s_0,
    awready_axi_s_0,

    wdata_axi_s_0,
    wstrb_axi_s_0,
    wlast_axi_s_0,
    wvalid_axi_s_0,
    wready_axi_s_0,

    bid_axi_s_0,
    bresp_axi_s_0,
    bvalid_axi_s_0,
    bready_axi_s_0,

    arid_axi_s_0,
    araddr_axi_s_0,
    arlen_axi_s_0,
    arsize_axi_s_0,
    arburst_axi_s_0,
    arlock_axi_s_0,
    arcache_axi_s_0,
    arprot_axi_s_0,
    arvalid_axi_s_0,
    arvalid_vect_axi_s_0,
    arready_axi_s_0,

    rid_axi_s_0,
    rdata_axi_s_0,
    rresp_axi_s_0,
    rlast_axi_s_0,
    rvalid_axi_s_0,
    rready_axi_s_0,

    aw_qv_axi_s_0,
    ar_qv_axi_s_0,


    awid_axi_m_0,
    awaddr_axi_m_0,
    awlen_axi_m_0,
    awsize_axi_m_0,
    awburst_axi_m_0,
    awlock_axi_m_0,
    awcache_axi_m_0,
    awprot_axi_m_0,
    awvalid_axi_m_0,
    awvalid_vect_axi_m_0,
    awready_axi_m_0,

    wdata_axi_m_0,
    wstrb_axi_m_0,
    wlast_axi_m_0,
    wvalid_axi_m_0,
    wready_axi_m_0,

    bid_axi_m_0,
    bresp_axi_m_0,
    bvalid_axi_m_0,
    bready_axi_m_0,

    arid_axi_m_0,
    araddr_axi_m_0,
    arlen_axi_m_0,
    arsize_axi_m_0,
    arburst_axi_m_0,
    arlock_axi_m_0,
    arcache_axi_m_0,
    arprot_axi_m_0,
    arvalid_axi_m_0,
    arvalid_vect_axi_m_0,
    arready_axi_m_0,

    rid_axi_m_0,
    rdata_axi_m_0,
    rresp_axi_m_0,
    rlast_axi_m_0,
    rvalid_axi_m_0,
    rready_axi_m_0,

    aw_qv_axi_m_0,
    ar_qv_axi_m_0,


    awid_axi_m_1,
    awaddr_axi_m_1,
    awlen_axi_m_1,
    awsize_axi_m_1,
    awburst_axi_m_1,
    awlock_axi_m_1,
    awcache_axi_m_1,
    awprot_axi_m_1,
    awvalid_axi_m_1,
    awvalid_vect_axi_m_1,
    awready_axi_m_1,

    wdata_axi_m_1,
    wstrb_axi_m_1,
    wlast_axi_m_1,
    wvalid_axi_m_1,
    wready_axi_m_1,

    bid_axi_m_1,
    bresp_axi_m_1,
    bvalid_axi_m_1,
    bready_axi_m_1,

    arid_axi_m_1,
    araddr_axi_m_1,
    arlen_axi_m_1,
    arsize_axi_m_1,
    arburst_axi_m_1,
    arlock_axi_m_1,
    arcache_axi_m_1,
    arprot_axi_m_1,
    arvalid_axi_m_1,
    arvalid_vect_axi_m_1,
    arready_axi_m_1,

    rid_axi_m_1,
    rdata_axi_m_1,
    rresp_axi_m_1,
    rlast_axi_m_1,
    rvalid_axi_m_1,
    rready_axi_m_1,

    aw_qv_axi_m_1,
    ar_qv_axi_m_1,

    aclk,
    aresetn

  );


  


  input   [11:0]      awid_axi_s_0;              
  input   [31:0]      awaddr_axi_s_0;            
  input   [7:0]       awlen_axi_s_0;             
  input   [2:0]       awsize_axi_s_0;            
  input   [1:0]       awburst_axi_s_0;           
  input               awlock_axi_s_0;            
  input   [3:0]       awcache_axi_s_0;           
  input   [2:0]       awprot_axi_s_0;            
  input               awvalid_axi_s_0;           
  input   [1:0]       awvalid_vect_axi_s_0;      
  output              awready_axi_s_0;           

  input   [63:0]      wdata_axi_s_0;             
  input   [7:0]       wstrb_axi_s_0;             
  input               wlast_axi_s_0;             
  input               wvalid_axi_s_0;            
  output              wready_axi_s_0;            

  output  [11:0]      bid_axi_s_0;               
  output  [1:0]       bresp_axi_s_0;             
  output              bvalid_axi_s_0;            
  input               bready_axi_s_0;            

  input   [11:0]      arid_axi_s_0;              
  input   [31:0]      araddr_axi_s_0;            
  input   [7:0]       arlen_axi_s_0;             
  input   [2:0]       arsize_axi_s_0;            
  input   [1:0]       arburst_axi_s_0;           
  input               arlock_axi_s_0;            
  input   [3:0]       arcache_axi_s_0;           
  input   [2:0]       arprot_axi_s_0;            
  input               arvalid_axi_s_0;           
  input   [1:0]       arvalid_vect_axi_s_0;      
  output              arready_axi_s_0;           

  output  [11:0]      rid_axi_s_0;               
  output  [63:0]      rdata_axi_s_0;             
  output  [1:0]       rresp_axi_s_0;             
  output              rlast_axi_s_0;             
  output              rvalid_axi_s_0;            
  input               rready_axi_s_0;            

  input   [3:0]       aw_qv_axi_s_0;             
  input   [3:0]       ar_qv_axi_s_0;             



  output  [11:0]      awid_axi_m_0;              
  output  [31:0]      awaddr_axi_m_0;            
  output  [7:0]       awlen_axi_m_0;             
  output  [2:0]       awsize_axi_m_0;            
  output  [1:0]       awburst_axi_m_0;           
  output              awlock_axi_m_0;            
  output  [3:0]       awcache_axi_m_0;           
  output  [2:0]       awprot_axi_m_0;            
  output              awvalid_axi_m_0;           
  output              awvalid_vect_axi_m_0;      
  input               awready_axi_m_0;           

  output  [63:0]      wdata_axi_m_0;             
  output  [7:0]       wstrb_axi_m_0;             
  output              wlast_axi_m_0;             
  output              wvalid_axi_m_0;            
  input               wready_axi_m_0;            

  input   [11:0]      bid_axi_m_0;               
  input   [1:0]       bresp_axi_m_0;             
  input               bvalid_axi_m_0;            
  output              bready_axi_m_0;            

  output  [11:0]      arid_axi_m_0;              
  output  [31:0]      araddr_axi_m_0;            
  output  [7:0]       arlen_axi_m_0;             
  output  [2:0]       arsize_axi_m_0;            
  output  [1:0]       arburst_axi_m_0;           
  output              arlock_axi_m_0;            
  output  [3:0]       arcache_axi_m_0;           
  output  [2:0]       arprot_axi_m_0;            
  output              arvalid_axi_m_0;           
  output              arvalid_vect_axi_m_0;      
  input               arready_axi_m_0;           

  input   [11:0]      rid_axi_m_0;               
  input   [63:0]      rdata_axi_m_0;             
  input   [1:0]       rresp_axi_m_0;             
  input               rlast_axi_m_0;             
  input               rvalid_axi_m_0;            
  output              rready_axi_m_0;            

  output  [3:0]       aw_qv_axi_m_0;             
  output  [3:0]       ar_qv_axi_m_0;             



  output  [11:0]      awid_axi_m_1;              
  output  [31:0]      awaddr_axi_m_1;            
  output  [7:0]       awlen_axi_m_1;             
  output  [2:0]       awsize_axi_m_1;            
  output  [1:0]       awburst_axi_m_1;           
  output              awlock_axi_m_1;            
  output  [3:0]       awcache_axi_m_1;           
  output  [2:0]       awprot_axi_m_1;            
  output              awvalid_axi_m_1;           
  output              awvalid_vect_axi_m_1;      
  input               awready_axi_m_1;           

  output  [63:0]      wdata_axi_m_1;             
  output  [7:0]       wstrb_axi_m_1;             
  output              wlast_axi_m_1;             
  output              wvalid_axi_m_1;            
  input               wready_axi_m_1;            

  input   [11:0]      bid_axi_m_1;               
  input   [1:0]       bresp_axi_m_1;             
  input               bvalid_axi_m_1;            
  output              bready_axi_m_1;            

  output  [11:0]      arid_axi_m_1;              
  output  [31:0]      araddr_axi_m_1;            
  output  [7:0]       arlen_axi_m_1;             
  output  [2:0]       arsize_axi_m_1;            
  output  [1:0]       arburst_axi_m_1;           
  output              arlock_axi_m_1;            
  output  [3:0]       arcache_axi_m_1;           
  output  [2:0]       arprot_axi_m_1;            
  output              arvalid_axi_m_1;           
  output              arvalid_vect_axi_m_1;      
  input               arready_axi_m_1;           

  input   [11:0]      rid_axi_m_1;               
  input   [63:0]      rdata_axi_m_1;             
  input   [1:0]       rresp_axi_m_1;             
  input               rlast_axi_m_1;             
  input               rvalid_axi_m_1;            
  output              rready_axi_m_1;            

  output  [3:0]       aw_qv_axi_m_1;             
  output  [3:0]       ar_qv_axi_m_1;             

  input               aclk;                      
  input               aresetn;                   




    wire  [11:0]                 awid_0_0;
    wire  [31:0]                awaddr_0_0;
    wire  [7:0]                 awlen_0_0;
    wire  [2:0]                 awsize_0_0;
    wire  [1:0]                 awburst_0_0;
    wire                        awlock_0_0;
    wire  [3:0]                 awcache_0_0;
    wire  [2:0]                 awprot_0_0;
    wire                        awvalid_0_0;
    wire                   awvalid_vect_0_0;
    wire                        awready_0_0;
    wire  [3:0]                 aw_qv_0_0;
   
    wire  [63:0]                wdata_0_0;
    wire  [7:0]                 wstrb_0_0;
    wire                        wlast_0_0;
    wire                        wvalid_0_0;
    wire                        wready_0_0;

    wire  [11:0]                 bid_0_0;
    wire  [1:0]                 bresp_0_0;
    wire                        bvalid_0_0;
    wire                        bready_0_0;

    wire  [11:0]                 arid_0_0;
    wire  [31:0]                araddr_0_0;
    wire  [7:0]                 arlen_0_0;
    wire  [2:0]                 arsize_0_0;
    wire  [1:0]                 arburst_0_0;
    wire                        arlock_0_0;
    wire  [3:0]                 arcache_0_0;
    wire  [2:0]                 arprot_0_0;
    wire                        arvalid_0_0;
    wire                   arvalid_vect_0_0;
    wire                        arready_0_0;
    wire  [3:0]                 ar_qv_0_0;
   
    wire  [11:0]                 rid_0_0;
    wire  [63:0]                rdata_0_0;
    wire  [1:0]                 rresp_0_0;
    wire                        rlast_0_0;
    wire                        rvalid_0_0;
    wire                        rready_0_0;


    wire  [11:0]                 awid_0_1;
    wire  [31:0]                awaddr_0_1;
    wire  [7:0]                 awlen_0_1;
    wire  [2:0]                 awsize_0_1;
    wire  [1:0]                 awburst_0_1;
    wire                        awlock_0_1;
    wire  [3:0]                 awcache_0_1;
    wire  [2:0]                 awprot_0_1;
    wire                        awvalid_0_1;
    wire                   awvalid_vect_0_1;
    wire                        awready_0_1;
    wire  [3:0]                 aw_qv_0_1;
   
    wire  [63:0]                wdata_0_1;
    wire  [7:0]                 wstrb_0_1;
    wire                        wlast_0_1;
    wire                        wvalid_0_1;
    wire                        wready_0_1;

    wire  [11:0]                 bid_0_1;
    wire  [1:0]                 bresp_0_1;
    wire                        bvalid_0_1;
    wire                        bready_0_1;

    wire  [11:0]                 arid_0_1;
    wire  [31:0]                araddr_0_1;
    wire  [7:0]                 arlen_0_1;
    wire  [2:0]                 arsize_0_1;
    wire  [1:0]                 arburst_0_1;
    wire                        arlock_0_1;
    wire  [3:0]                 arcache_0_1;
    wire  [2:0]                 arprot_0_1;
    wire                        arvalid_0_1;
    wire                   arvalid_vect_0_1;
    wire                        arready_0_1;
    wire  [3:0]                 ar_qv_0_1;
   
    wire  [11:0]                 rid_0_1;
    wire  [63:0]                rdata_0_1;
    wire  [1:0]                 rresp_0_1;
    wire                        rlast_0_1;
    wire                        rvalid_0_1;
    wire                        rready_0_1;

 





  nic400_bm0_ml_build_sse710_integration_example_f0_cvm u_nic400_bm0_ml_build_sse710_integration_example_f0_cvm
  (    


        .awid_s0         (awid_axi_s_0),
        .awaddr_s0       (awaddr_axi_s_0),
        .awlen_s0        (awlen_axi_s_0),
        .awsize_s0       (awsize_axi_s_0),
        .awburst_s0      (awburst_axi_s_0),
        .awlock_s0       (awlock_axi_s_0),
        .awcache_s0      (awcache_axi_s_0),
        .awprot_s0       (awprot_axi_s_0),
        .awvalid_s0      (awvalid_axi_s_0),
        .awvalid_vect_s0 (awvalid_vect_axi_s_0),
        .awready_s0      (awready_axi_s_0),
        .aw_qv_s0        (aw_qv_axi_s_0),

        .wdata_s0        (wdata_axi_s_0),
        .wstrb_s0        (wstrb_axi_s_0),   
        .wlast_s0        (wlast_axi_s_0),
        .wvalid_s0       (wvalid_axi_s_0),
        .wready_s0       (wready_axi_s_0),

        .bid_s0          (bid_axi_s_0),
        .bresp_s0        (bresp_axi_s_0),
        .bvalid_s0       (bvalid_axi_s_0),
        .bready_s0       (bready_axi_s_0),  

        .arid_s0         (arid_axi_s_0),
        .araddr_s0       (araddr_axi_s_0),
        .arlen_s0        (arlen_axi_s_0),
        .arsize_s0       (arsize_axi_s_0),
        .arburst_s0      (arburst_axi_s_0),
        .arlock_s0       (arlock_axi_s_0),
        .arcache_s0      (arcache_axi_s_0),
        .arprot_s0       (arprot_axi_s_0),
        .arvalid_s0      (arvalid_axi_s_0),
        .arvalid_vect_s0 (arvalid_vect_axi_s_0),
        .arready_s0      (arready_axi_s_0),
        .ar_qv_s0        (ar_qv_axi_s_0),
   
        .rid_s0          (rid_axi_s_0),
        .rdata_s0        (rdata_axi_s_0),
        .rresp_s0        (rresp_axi_s_0),
        .rlast_s0        (rlast_axi_s_0),
        .rvalid_s0       (rvalid_axi_s_0),
        .rready_s0       (rready_axi_s_0),



        .awid_0_0         (awid_0_0),
        .awaddr_0_0       (awaddr_0_0),
        .awlen_0_0        (awlen_0_0),
        .awsize_0_0       (awsize_0_0),
        .awburst_0_0      (awburst_0_0),
        .awlock_0_0       (awlock_0_0),
        .awcache_0_0      (awcache_0_0),
        .awprot_0_0       (awprot_0_0),
        .awvalid_0_0      (awvalid_0_0),
        .awvalid_vect_0_0 (awvalid_vect_0_0),
        .awready_0_0      (awready_0_0),
        .aw_qv_0_0        (aw_qv_0_0),
   
        .wdata_0_0        (wdata_0_0),
        .wstrb_0_0        (wstrb_0_0),   
        .wlast_0_0        (wlast_0_0),
        .wvalid_0_0       (wvalid_0_0),
        .wready_0_0       (wready_0_0),

        .bid_0_0          (bid_0_0),
        .bresp_0_0        (bresp_0_0),
        .bvalid_0_0       (bvalid_0_0),
        .bready_0_0       (bready_0_0),  

        .arid_0_0         (arid_0_0),
        .araddr_0_0       (araddr_0_0),
        .arlen_0_0        (arlen_0_0),
        .arsize_0_0       (arsize_0_0),
        .arburst_0_0      (arburst_0_0),
        .arlock_0_0       (arlock_0_0),
        .arcache_0_0      (arcache_0_0),
        .arprot_0_0       (arprot_0_0),
        .arvalid_0_0      (arvalid_0_0),
        .arvalid_vect_0_0 (arvalid_vect_0_0),
        .arready_0_0      (arready_0_0),
        .ar_qv_0_0        (ar_qv_0_0),
   
        .rid_0_0          (rid_0_0),
        .rdata_0_0        (rdata_0_0),
        .rresp_0_0        (rresp_0_0),
        .rlast_0_0        (rlast_0_0),
        .rvalid_0_0       (rvalid_0_0),
        .rready_0_0       (rready_0_0),


        .awid_0_1         (awid_0_1),
        .awaddr_0_1       (awaddr_0_1),
        .awlen_0_1        (awlen_0_1),
        .awsize_0_1       (awsize_0_1),
        .awburst_0_1      (awburst_0_1),
        .awlock_0_1       (awlock_0_1),
        .awcache_0_1      (awcache_0_1),
        .awprot_0_1       (awprot_0_1),
        .awvalid_0_1      (awvalid_0_1),
        .awvalid_vect_0_1 (awvalid_vect_0_1),
        .awready_0_1      (awready_0_1),
        .aw_qv_0_1        (aw_qv_0_1),
   
        .wdata_0_1        (wdata_0_1),
        .wstrb_0_1        (wstrb_0_1),   
        .wlast_0_1        (wlast_0_1),
        .wvalid_0_1       (wvalid_0_1),
        .wready_0_1       (wready_0_1),

        .bid_0_1          (bid_0_1),
        .bresp_0_1        (bresp_0_1),
        .bvalid_0_1       (bvalid_0_1),
        .bready_0_1       (bready_0_1),  

        .arid_0_1         (arid_0_1),
        .araddr_0_1       (araddr_0_1),
        .arlen_0_1        (arlen_0_1),
        .arsize_0_1       (arsize_0_1),
        .arburst_0_1      (arburst_0_1),
        .arlock_0_1       (arlock_0_1),
        .arcache_0_1      (arcache_0_1),
        .arprot_0_1       (arprot_0_1),
        .arvalid_0_1      (arvalid_0_1),
        .arvalid_vect_0_1 (arvalid_vect_0_1),
        .arready_0_1      (arready_0_1),
        .ar_qv_0_1        (ar_qv_0_1),
   
        .rid_0_1          (rid_0_1),
        .rdata_0_1        (rdata_0_1),
        .rresp_0_1        (rresp_0_1),
        .rlast_0_1        (rlast_0_1),
        .rvalid_0_1       (rvalid_0_1),
        .rready_0_1       (rready_0_1),


        .aclk    (aclk),
        .aresetn    (aresetn)
  );





  nic400_bm0_ml_map_sse710_integration_example_f0_cvm u_nic400_bm0_ml_map_sse710_integration_example_f0_cvm
  (     

        .awid_m0         (awid_axi_m_0),
        .awaddr_m0       (awaddr_axi_m_0),
        .awlen_m0        (awlen_axi_m_0),
        .awsize_m0       (awsize_axi_m_0),
        .awburst_m0      (awburst_axi_m_0),
        .awlock_m0       (awlock_axi_m_0),
        .awcache_m0      (awcache_axi_m_0),
        .awprot_m0       (awprot_axi_m_0),
        .awvalid_m0      (awvalid_axi_m_0),
        .awvalid_vect_m0 (awvalid_vect_axi_m_0),
        .awready_m0      (awready_axi_m_0),
        .aw_qv_m0        (aw_qv_axi_m_0),
   
        .wdata_m0        (wdata_axi_m_0),
        .wstrb_m0        (wstrb_axi_m_0),   
        .wlast_m0        (wlast_axi_m_0),
        .wvalid_m0       (wvalid_axi_m_0),
        .wready_m0       (wready_axi_m_0),

        .bid_m0          (bid_axi_m_0),
        .bresp_m0        (bresp_axi_m_0),
        .bvalid_m0       (bvalid_axi_m_0),
        .bready_m0       (bready_axi_m_0),  

        .arid_m0         (arid_axi_m_0),
        .araddr_m0       (araddr_axi_m_0),
        .arlen_m0        (arlen_axi_m_0),
        .arsize_m0       (arsize_axi_m_0),
        .arburst_m0      (arburst_axi_m_0),
        .arlock_m0       (arlock_axi_m_0),
        .arcache_m0      (arcache_axi_m_0),
        .arprot_m0       (arprot_axi_m_0),
        .arvalid_m0      (arvalid_axi_m_0),
        .arvalid_vect_m0 (arvalid_vect_axi_m_0),
        .arready_m0      (arready_axi_m_0),
        .ar_qv_m0        (ar_qv_axi_m_0),
   
        .rid_m0          (rid_axi_m_0),
        .rdata_m0        (rdata_axi_m_0),
        .rresp_m0        (rresp_axi_m_0),
        .rlast_m0        (rlast_axi_m_0),
        .rvalid_m0       (rvalid_axi_m_0),
        .rready_m0       (rready_axi_m_0),

        .awid_m1         (awid_axi_m_1),
        .awaddr_m1       (awaddr_axi_m_1),
        .awlen_m1        (awlen_axi_m_1),
        .awsize_m1       (awsize_axi_m_1),
        .awburst_m1      (awburst_axi_m_1),
        .awlock_m1       (awlock_axi_m_1),
        .awcache_m1      (awcache_axi_m_1),
        .awprot_m1       (awprot_axi_m_1),
        .awvalid_m1      (awvalid_axi_m_1),
        .awvalid_vect_m1 (awvalid_vect_axi_m_1),
        .awready_m1      (awready_axi_m_1),
        .aw_qv_m1        (aw_qv_axi_m_1),
   
        .wdata_m1        (wdata_axi_m_1),
        .wstrb_m1        (wstrb_axi_m_1),   
        .wlast_m1        (wlast_axi_m_1),
        .wvalid_m1       (wvalid_axi_m_1),
        .wready_m1       (wready_axi_m_1),

        .bid_m1          (bid_axi_m_1),
        .bresp_m1        (bresp_axi_m_1),
        .bvalid_m1       (bvalid_axi_m_1),
        .bready_m1       (bready_axi_m_1),  

        .arid_m1         (arid_axi_m_1),
        .araddr_m1       (araddr_axi_m_1),
        .arlen_m1        (arlen_axi_m_1),
        .arsize_m1       (arsize_axi_m_1),
        .arburst_m1      (arburst_axi_m_1),
        .arlock_m1       (arlock_axi_m_1),
        .arcache_m1      (arcache_axi_m_1),
        .arprot_m1       (arprot_axi_m_1),
        .arvalid_m1      (arvalid_axi_m_1),
        .arvalid_vect_m1 (arvalid_vect_axi_m_1),
        .arready_m1      (arready_axi_m_1),
        .ar_qv_m1        (ar_qv_axi_m_1),
   
        .rid_m1          (rid_axi_m_1),
        .rdata_m1        (rdata_axi_m_1),
        .rresp_m1        (rresp_axi_m_1),
        .rlast_m1        (rlast_axi_m_1),
        .rvalid_m1       (rvalid_axi_m_1),
        .rready_m1       (rready_axi_m_1),




        .awid_0_0         (awid_0_0),
        .awaddr_0_0       (awaddr_0_0),
        .awlen_0_0        (awlen_0_0),
        .awsize_0_0       (awsize_0_0),
        .awburst_0_0      (awburst_0_0),
        .awlock_0_0       (awlock_0_0),
        .awcache_0_0      (awcache_0_0),
        .awprot_0_0       (awprot_0_0),
        .awvalid_0_0      (awvalid_0_0),
        .awvalid_vect_0_0 (awvalid_vect_0_0),
        .awready_0_0      (awready_0_0),
        .aw_qv_0_0        (aw_qv_0_0),
   
        .wdata_0_0        (wdata_0_0),
        .wstrb_0_0        (wstrb_0_0),   
        .wlast_0_0        (wlast_0_0),
        .wvalid_0_0       (wvalid_0_0),
        .wready_0_0       (wready_0_0),

        .bid_0_0          (bid_0_0),
        .bresp_0_0        (bresp_0_0),
        .bvalid_0_0       (bvalid_0_0),
        .bready_0_0       (bready_0_0),  

        .arid_0_0         (arid_0_0),
        .araddr_0_0       (araddr_0_0),
        .arlen_0_0        (arlen_0_0),
        .arsize_0_0       (arsize_0_0),
        .arburst_0_0      (arburst_0_0),
        .arlock_0_0       (arlock_0_0),
        .arcache_0_0      (arcache_0_0),
        .arprot_0_0       (arprot_0_0),
        .arvalid_0_0      (arvalid_0_0),
        .arvalid_vect_0_0 (arvalid_vect_0_0),
        .arready_0_0      (arready_0_0),
        .ar_qv_0_0        (ar_qv_0_0),
   
        .rid_0_0          (rid_0_0),
        .rdata_0_0        (rdata_0_0),
        .rresp_0_0        (rresp_0_0),
        .rlast_0_0        (rlast_0_0),
        .rvalid_0_0       (rvalid_0_0),
        .rready_0_0       (rready_0_0),



        .awid_0_1         (awid_0_1),
        .awaddr_0_1       (awaddr_0_1),
        .awlen_0_1        (awlen_0_1),
        .awsize_0_1       (awsize_0_1),
        .awburst_0_1      (awburst_0_1),
        .awlock_0_1       (awlock_0_1),
        .awcache_0_1      (awcache_0_1),
        .awprot_0_1       (awprot_0_1),
        .awvalid_0_1      (awvalid_0_1),
        .awvalid_vect_0_1 (awvalid_vect_0_1),
        .awready_0_1      (awready_0_1),
        .aw_qv_0_1        (aw_qv_0_1),
   
        .wdata_0_1        (wdata_0_1),
        .wstrb_0_1        (wstrb_0_1),   
        .wlast_0_1        (wlast_0_1),
        .wvalid_0_1       (wvalid_0_1),
        .wready_0_1       (wready_0_1),

        .bid_0_1          (bid_0_1),
        .bresp_0_1        (bresp_0_1),
        .bvalid_0_1       (bvalid_0_1),
        .bready_0_1       (bready_0_1),  

        .arid_0_1         (arid_0_1),
        .araddr_0_1       (araddr_0_1),
        .arlen_0_1        (arlen_0_1),
        .arsize_0_1       (arsize_0_1),
        .arburst_0_1      (arburst_0_1),
        .arlock_0_1       (arlock_0_1),
        .arcache_0_1      (arcache_0_1),
        .arprot_0_1       (arprot_0_1),
        .arvalid_0_1      (arvalid_0_1),
        .arvalid_vect_0_1 (arvalid_vect_0_1),
        .arready_0_1      (arready_0_1),
        .ar_qv_0_1        (ar_qv_0_1),
   
        .rid_0_1          (rid_0_1),
        .rdata_0_1        (rdata_0_1),
        .rresp_0_1        (rresp_0_1),
        .rlast_0_1        (rlast_0_1),
        .rvalid_0_1       (rvalid_0_1),
        .rready_0_1       (rready_0_1),


        .aclk    (aclk),
        .aresetn    (aresetn)
  );


  endmodule


