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



`include "nic400_ib_axi_m_ib_defs_sse710_integration_example_f0_upsizer.v"

`include "Axi.v"

module nic400_ib_axi_m_ib_master_domain_sse710_integration_example_f0_upsizer
  (
  

    awid_axi4_m,
    awaddr_axi4_m,
    awlen_axi4_m,
    awsize_axi4_m,
    awburst_axi4_m,
    awlock_axi4_m,
    awcache_axi4_m,
    awprot_axi4_m,
    awvalid_axi4_m,
    awready_axi4_m,

    wdata_axi4_m,
    wstrb_axi4_m,
    wlast_axi4_m,
    wvalid_axi4_m,
    wready_axi4_m,

    bid_axi4_m,
    bresp_axi4_m,
    bvalid_axi4_m,
    bready_axi4_m,

    arid_axi4_m,
    araddr_axi4_m,
    arlen_axi4_m,
    arsize_axi4_m,
    arburst_axi4_m,
    arlock_axi4_m,
    arcache_axi4_m,
    arprot_axi4_m,
    arvalid_axi4_m,
    arready_axi4_m,

    rid_axi4_m,
    rdata_axi4_m,
    rresp_axi4_m,
    rlast_axi4_m,
    rvalid_axi4_m,
    rready_axi4_m,


    aw_data,
    aw_valid,
    aw_ready,

    b_data,
    b_valid,
    b_ready,

    ar_data,
    ar_valid,
    ar_ready,

    r_data,
    r_valid,
    r_ready,

    w_data,
    w_valid,
    w_ready,

    aclk,
    aresetn

  );




  


  output              awid_axi4_m;         
  output  [31:0]      awaddr_axi4_m;       
  output  [7:0]       awlen_axi4_m;        
  output  [2:0]       awsize_axi4_m;       
  output  [1:0]       awburst_axi4_m;      
  output              awlock_axi4_m;       
  output  [3:0]       awcache_axi4_m;      
  output  [2:0]       awprot_axi4_m;       
  output              awvalid_axi4_m;      
  input               awready_axi4_m;      

  output  [63:0]      wdata_axi4_m;        
  output  [7:0]       wstrb_axi4_m;        
  output              wlast_axi4_m;        
  output              wvalid_axi4_m;       
  input               wready_axi4_m;       

  input               bid_axi4_m;          
  input   [1:0]       bresp_axi4_m;        
  input               bvalid_axi4_m;       
  output              bready_axi4_m;       

  output              arid_axi4_m;         
  output  [31:0]      araddr_axi4_m;       
  output  [7:0]       arlen_axi4_m;        
  output  [2:0]       arsize_axi4_m;       
  output  [1:0]       arburst_axi4_m;      
  output              arlock_axi4_m;       
  output  [3:0]       arcache_axi4_m;      
  output  [2:0]       arprot_axi4_m;       
  output              arvalid_axi4_m;      
  input               arready_axi4_m;      

  input               rid_axi4_m;          
  input   [63:0]      rdata_axi4_m;        
  input   [1:0]       rresp_axi4_m;        
  input               rlast_axi4_m;        
  input               rvalid_axi4_m;       
  output              rready_axi4_m;       



  input   [53:0]      aw_data;             
  input               aw_valid;            
  output              aw_ready;            

  output  [2:0]       b_data;              
  output              b_valid;             
  input               b_ready;             

  input   [53:0]      ar_data;             
  input               ar_valid;            
  output              ar_ready;            

  output  [67:0]      r_data;              
  output              r_valid;             
  input               r_ready;             

  input   [72:0]      w_data;              
  input               w_valid;             
  output              w_ready;             

  input               aclk;                
  input               aresetn;             









  assign {
          awid_axi4_m,
          awaddr_axi4_m[31:0],
          awlen_axi4_m,
          awsize_axi4_m,
          awburst_axi4_m,
          awlock_axi4_m,
          awcache_axi4_m,
          awprot_axi4_m} = aw_data;

  

  assign awvalid_axi4_m = aw_valid;
  assign aw_ready = awready_axi4_m;







  assign {
          arid_axi4_m,
          araddr_axi4_m[31:0],
          arlen_axi4_m,
          arsize_axi4_m,
          arburst_axi4_m,
          arlock_axi4_m,
          arcache_axi4_m,
          arprot_axi4_m} = ar_data;

  

  assign arvalid_axi4_m = ar_valid;
  assign ar_ready = arready_axi4_m;







  assign {
          wdata_axi4_m,
          wstrb_axi4_m,
          wlast_axi4_m} = w_data;

  

  assign wvalid_axi4_m = w_valid;
  assign w_ready = wready_axi4_m;





  assign r_data = {
          rid_axi4_m,
          rdata_axi4_m,
          rresp_axi4_m,
          rlast_axi4_m};

  assign r_valid = rvalid_axi4_m;
  assign rready_axi4_m = r_ready;



  assign b_data = {
          bid_axi4_m,
          bresp_axi4_m};

  assign b_valid = bvalid_axi4_m;
  assign bready_axi4_m = b_ready;














endmodule
`include "nic400_ib_axi_m_ib_undefs_sse710_integration_example_f0_upsizer.v"
`include "Axi_undefs.v"



