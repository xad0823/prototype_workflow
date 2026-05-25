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



`include "nic400_amib_axi_m_defs_sse710_integration_example_f0_upsizer.v"

module nic400_amib_axi_m_sse710_integration_example_f0_upsizer
  (
  

    awid_axi_m,
    awaddr_axi_m,
    awlen_axi_m,
    awsize_axi_m,
    awburst_axi_m,
    awlock_axi_m,
    awcache_axi_m,
    awprot_axi_m,
    awvalid_axi_m,
    awready_axi_m,

    wdata_axi_m,
    wstrb_axi_m,
    wlast_axi_m,
    wvalid_axi_m,
    wready_axi_m,

    bid_axi_m,
    bresp_axi_m,
    bvalid_axi_m,
    bready_axi_m,

    arid_axi_m,
    araddr_axi_m,
    arlen_axi_m,
    arsize_axi_m,
    arburst_axi_m,
    arlock_axi_m,
    arcache_axi_m,
    arprot_axi_m,
    arvalid_axi_m,
    arready_axi_m,

    rid_axi_m,
    rdata_axi_m,
    rresp_axi_m,
    rlast_axi_m,
    rvalid_axi_m,
    rready_axi_m,


    awid_axi_m_s,
    awaddr_axi_m_s,
    awlen_axi_m_s,
    awsize_axi_m_s,
    awburst_axi_m_s,
    awlock_axi_m_s,
    awcache_axi_m_s,
    awprot_axi_m_s,
    awvalid_axi_m_s,
    awready_axi_m_s,

    wdata_axi_m_s,
    wstrb_axi_m_s,
    wlast_axi_m_s,
    wvalid_axi_m_s,
    wready_axi_m_s,

    bid_axi_m_s,
    bresp_axi_m_s,
    bvalid_axi_m_s,
    bready_axi_m_s,

    arid_axi_m_s,
    araddr_axi_m_s,
    arlen_axi_m_s,
    arsize_axi_m_s,
    arburst_axi_m_s,
    arlock_axi_m_s,
    arcache_axi_m_s,
    arprot_axi_m_s,
    arvalid_axi_m_s,
    arready_axi_m_s,

    rid_axi_m_s,
    rdata_axi_m_s,
    rresp_axi_m_s,
    rlast_axi_m_s,
    rvalid_axi_m_s,
    rready_axi_m_s,

    aclk,
    aresetn

  );




  


  output              awid_axi_m;           
  output  [31:0]      awaddr_axi_m;         
  output  [7:0]       awlen_axi_m;          
  output  [2:0]       awsize_axi_m;         
  output  [1:0]       awburst_axi_m;        
  output              awlock_axi_m;         
  output  [3:0]       awcache_axi_m;        
  output  [2:0]       awprot_axi_m;         
  output              awvalid_axi_m;        
  input               awready_axi_m;        

  output  [63:0]      wdata_axi_m;          
  output  [7:0]       wstrb_axi_m;          
  output              wlast_axi_m;          
  output              wvalid_axi_m;         
  input               wready_axi_m;         

  input               bid_axi_m;            
  input   [1:0]       bresp_axi_m;          
  input               bvalid_axi_m;         
  output              bready_axi_m;         

  output              arid_axi_m;           
  output  [31:0]      araddr_axi_m;         
  output  [7:0]       arlen_axi_m;          
  output  [2:0]       arsize_axi_m;         
  output  [1:0]       arburst_axi_m;        
  output              arlock_axi_m;         
  output  [3:0]       arcache_axi_m;        
  output  [2:0]       arprot_axi_m;         
  output              arvalid_axi_m;        
  input               arready_axi_m;        

  input               rid_axi_m;            
  input   [63:0]      rdata_axi_m;          
  input   [1:0]       rresp_axi_m;          
  input               rlast_axi_m;          
  input               rvalid_axi_m;         
  output              rready_axi_m;         



  input               awid_axi_m_s;         
  input   [31:0]      awaddr_axi_m_s;       
  input   [7:0]       awlen_axi_m_s;        
  input   [2:0]       awsize_axi_m_s;       
  input   [1:0]       awburst_axi_m_s;      
  input               awlock_axi_m_s;       
  input   [3:0]       awcache_axi_m_s;      
  input   [2:0]       awprot_axi_m_s;       
  input               awvalid_axi_m_s;      
  output              awready_axi_m_s;      

  input   [63:0]      wdata_axi_m_s;        
  input   [7:0]       wstrb_axi_m_s;        
  input               wlast_axi_m_s;        
  input               wvalid_axi_m_s;       
  output              wready_axi_m_s;       

  output              bid_axi_m_s;          
  output  [1:0]       bresp_axi_m_s;        
  output              bvalid_axi_m_s;       
  input               bready_axi_m_s;       

  input               arid_axi_m_s;         
  input   [31:0]      araddr_axi_m_s;       
  input   [7:0]       arlen_axi_m_s;        
  input   [2:0]       arsize_axi_m_s;       
  input   [1:0]       arburst_axi_m_s;      
  input               arlock_axi_m_s;       
  input   [3:0]       arcache_axi_m_s;      
  input   [2:0]       arprot_axi_m_s;       
  input               arvalid_axi_m_s;      
  output              arready_axi_m_s;      

  output              rid_axi_m_s;          
  output  [63:0]      rdata_axi_m_s;        
  output  [1:0]       rresp_axi_m_s;        
  output              rlast_axi_m_s;        
  output              rvalid_axi_m_s;       
  input               rready_axi_m_s;       

  input               aclk;                 
  input               aresetn;              






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [72:0]    w_master_port_src_data;     
  wire [72:0]    w_master_port_dst_data;     



  wire           b_master_port_dst_valid;
  wire           b_master_port_dst_ready;
  wire           b_master_port_src_valid;
  wire           b_master_port_src_ready;

  wire [2:0]     b_master_port_src_data;     
  wire [2:0]     b_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [67:0]    r_master_port_src_data;     
  wire [67:0]    r_master_port_dst_data;     







  wire [63:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_axi_m_s[63:56]  & {8{wstrb_axi_m_s[7]}}),
  (wdata_axi_m_s[55:48]  & {8{wstrb_axi_m_s[6]}}),
  (wdata_axi_m_s[47:40]  & {8{wstrb_axi_m_s[5]}}),
  (wdata_axi_m_s[39:32]  & {8{wstrb_axi_m_s[4]}}),
  (wdata_axi_m_s[31:24]  & {8{wstrb_axi_m_s[3]}}),
  (wdata_axi_m_s[23:16]  & {8{wstrb_axi_m_s[2]}}),
  (wdata_axi_m_s[15:8]  & {8{wstrb_axi_m_s[1]}}),
  (wdata_axi_m_s[7:0]  & {8{wstrb_axi_m_s[0]}})};
  
  assign awid_axi_m     = awid_axi_m_s;
  assign awaddr_axi_m   = awaddr_axi_m_s;
  assign awlen_axi_m    = awlen_axi_m_s;
  assign awsize_axi_m   = awsize_axi_m_s;
  assign awburst_axi_m  = awburst_axi_m_s;
  assign awlock_axi_m   = awlock_axi_m_s;
  assign awcache_axi_m  = awcache_axi_m_s;
  assign awprot_axi_m   = awprot_axi_m_s;
  assign awvalid_axi_m  = awvalid_axi_m_s;
  assign awready_axi_m_s  = awready_axi_m;
  assign arid_axi_m     = arid_axi_m_s;
  assign araddr_axi_m   = araddr_axi_m_s;
  assign arlen_axi_m    = arlen_axi_m_s;
  assign arsize_axi_m   = arsize_axi_m_s;
  assign arburst_axi_m  = arburst_axi_m_s;
  assign arlock_axi_m   = arlock_axi_m_s;
  assign arcache_axi_m  = arcache_axi_m_s;
  assign arprot_axi_m   = arprot_axi_m_s;
  assign arvalid_axi_m  = arvalid_axi_m_s;
  assign arready_axi_m_s  = arready_axi_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_axi_m_s,
        wlast_axi_m_s};

  assign {wdata_axi_m,
        wstrb_axi_m,
        wlast_axi_m} = w_master_port_dst_data;

  assign wvalid_axi_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_axi_m;

  assign w_master_port_src_valid = wvalid_axi_m_s;
  assign wready_axi_m_s = w_master_port_src_ready;



  assign b_master_port_src_data = {bid_axi_m,
        bresp_axi_m};

  assign {bid_axi_m_s,
        bresp_axi_m_s} = b_master_port_dst_data;

  assign bvalid_axi_m_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_axi_m_s;

  assign b_master_port_src_valid = bvalid_axi_m;
  assign bready_axi_m = b_master_port_src_ready;



  assign r_master_port_src_data = {rid_axi_m,
        rdata_axi_m,
        rresp_axi_m,
        rlast_axi_m};

  assign {rid_axi_m_s,
        rdata_axi_m_s,
        rresp_axi_m_s,
        rlast_axi_m_s} = r_master_port_dst_data;

  assign rvalid_axi_m_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_axi_m_s;

  assign r_master_port_src_valid = rvalid_axi_m;
  assign rready_axi_m = r_master_port_src_ready;






  nic400_amib_axi_m_chan_slice_sse710_integration_example_f0_upsizer
    #(
       `RS_REV_REG,  
       73  
     )
  u_w_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (w_master_port_src_valid),
     .src_data              (w_master_port_src_data),
     .dst_ready             (w_master_port_dst_ready),

     .src_ready             (w_master_port_src_ready),
     .dst_data              (w_master_port_dst_data),
     .dst_valid             (w_master_port_dst_valid)
     );




  nic400_amib_axi_m_chan_slice_sse710_integration_example_f0_upsizer
    #(
       `RS_REV_REG,  
       3  
     )
  u_b_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (b_master_port_src_valid),
     .src_data              (b_master_port_src_data),
     .dst_ready             (b_master_port_dst_ready),

     .src_ready             (b_master_port_src_ready),
     .dst_data              (b_master_port_dst_data),
     .dst_valid             (b_master_port_dst_valid)
     );




  nic400_amib_axi_m_chan_slice_sse710_integration_example_f0_upsizer
    #(
       `RS_REV_REG,  
       68  
     )
  u_r_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (r_master_port_src_valid),
     .src_data              (r_master_port_src_data),
     .dst_ready             (r_master_port_dst_ready),

     .src_ready             (r_master_port_src_ready),
     .dst_data              (r_master_port_dst_data),
     .dst_valid             (r_master_port_dst_valid)
     );











`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"




  wire strobeless_wdata;
  wire wif_hndshk;


  assign wif_hndshk = wvalid_axi_m & wready_axi_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_axi_m[63:56]  & ~wstrb_axi_m[7]) | 
  (|wdata_axi_m[55:48]  & ~wstrb_axi_m[6]) | 
  (|wdata_axi_m[47:40]  & ~wstrb_axi_m[5]) | 
  (|wdata_axi_m[39:32]  & ~wstrb_axi_m[4]) | 
  (|wdata_axi_m[31:24]  & ~wstrb_axi_m[3]) | 
  (|wdata_axi_m[23:16]  & ~wstrb_axi_m[2]) | 
  (|wdata_axi_m[15:8]  & ~wstrb_axi_m[1]) | 
  (|wdata_axi_m[7:0]  & ~wstrb_axi_m[0]));



  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "AMIB: WDATA not destrobed.")
  amib_destrob_mif
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (strobeless_wdata)
  );


  `endif 



endmodule

`include "nic400_amib_axi_m_undefs_sse710_integration_example_f0_upsizer.v"

