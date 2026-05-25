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



`include "nic400_amib_extsys0_axi_m_defs_sse710_integration_example_f0_host_exp.v"

module nic400_amib_extsys0_axi_m_sse710_integration_example_f0_host_exp
  (
  

    awid_extsys0_axi_m_m,
    awaddr_extsys0_axi_m_m,
    awlen_extsys0_axi_m_m,
    awsize_extsys0_axi_m_m,
    awburst_extsys0_axi_m_m,
    awlock_extsys0_axi_m_m,
    awcache_extsys0_axi_m_m,
    awprot_extsys0_axi_m_m,
    awvalid_extsys0_axi_m_m,
    awready_extsys0_axi_m_m,

    wdata_extsys0_axi_m_m,
    wstrb_extsys0_axi_m_m,
    wlast_extsys0_axi_m_m,
    wvalid_extsys0_axi_m_m,
    wready_extsys0_axi_m_m,

    bid_extsys0_axi_m_m,
    bresp_extsys0_axi_m_m,
    bvalid_extsys0_axi_m_m,
    bready_extsys0_axi_m_m,

    arid_extsys0_axi_m_m,
    araddr_extsys0_axi_m_m,
    arlen_extsys0_axi_m_m,
    arsize_extsys0_axi_m_m,
    arburst_extsys0_axi_m_m,
    arlock_extsys0_axi_m_m,
    arcache_extsys0_axi_m_m,
    arprot_extsys0_axi_m_m,
    arvalid_extsys0_axi_m_m,
    arready_extsys0_axi_m_m,

    rid_extsys0_axi_m_m,
    rdata_extsys0_axi_m_m,
    rresp_extsys0_axi_m_m,
    rlast_extsys0_axi_m_m,
    rvalid_extsys0_axi_m_m,
    rready_extsys0_axi_m_m,


    awid_extsys0_axi_m_s,
    awaddr_extsys0_axi_m_s,
    awlen_extsys0_axi_m_s,
    awsize_extsys0_axi_m_s,
    awburst_extsys0_axi_m_s,
    awlock_extsys0_axi_m_s,
    awcache_extsys0_axi_m_s,
    awprot_extsys0_axi_m_s,
    awvalid_extsys0_axi_m_s,
    awready_extsys0_axi_m_s,

    wdata_extsys0_axi_m_s,
    wstrb_extsys0_axi_m_s,
    wlast_extsys0_axi_m_s,
    wvalid_extsys0_axi_m_s,
    wready_extsys0_axi_m_s,

    bid_extsys0_axi_m_s,
    bresp_extsys0_axi_m_s,
    bvalid_extsys0_axi_m_s,
    bready_extsys0_axi_m_s,

    arid_extsys0_axi_m_s,
    araddr_extsys0_axi_m_s,
    arlen_extsys0_axi_m_s,
    arsize_extsys0_axi_m_s,
    arburst_extsys0_axi_m_s,
    arlock_extsys0_axi_m_s,
    arcache_extsys0_axi_m_s,
    arprot_extsys0_axi_m_s,
    arvalid_extsys0_axi_m_s,
    arready_extsys0_axi_m_s,

    rid_extsys0_axi_m_s,
    rdata_extsys0_axi_m_s,
    rresp_extsys0_axi_m_s,
    rlast_extsys0_axi_m_s,
    rvalid_extsys0_axi_m_s,
    rready_extsys0_axi_m_s,

    aclk,
    aresetn

  );




  


  output  [17:0]      awid_extsys0_axi_m_m;         
  output  [31:0]      awaddr_extsys0_axi_m_m;       
  output  [7:0]       awlen_extsys0_axi_m_m;        
  output  [2:0]       awsize_extsys0_axi_m_m;       
  output  [1:0]       awburst_extsys0_axi_m_m;      
  output              awlock_extsys0_axi_m_m;       
  output  [3:0]       awcache_extsys0_axi_m_m;      
  output  [2:0]       awprot_extsys0_axi_m_m;       
  output              awvalid_extsys0_axi_m_m;      
  input               awready_extsys0_axi_m_m;      

  output  [31:0]      wdata_extsys0_axi_m_m;        
  output  [3:0]       wstrb_extsys0_axi_m_m;        
  output              wlast_extsys0_axi_m_m;        
  output              wvalid_extsys0_axi_m_m;       
  input               wready_extsys0_axi_m_m;       

  input   [17:0]      bid_extsys0_axi_m_m;          
  input   [1:0]       bresp_extsys0_axi_m_m;        
  input               bvalid_extsys0_axi_m_m;       
  output              bready_extsys0_axi_m_m;       

  output  [17:0]      arid_extsys0_axi_m_m;         
  output  [31:0]      araddr_extsys0_axi_m_m;       
  output  [7:0]       arlen_extsys0_axi_m_m;        
  output  [2:0]       arsize_extsys0_axi_m_m;       
  output  [1:0]       arburst_extsys0_axi_m_m;      
  output              arlock_extsys0_axi_m_m;       
  output  [3:0]       arcache_extsys0_axi_m_m;      
  output  [2:0]       arprot_extsys0_axi_m_m;       
  output              arvalid_extsys0_axi_m_m;      
  input               arready_extsys0_axi_m_m;      

  input   [17:0]      rid_extsys0_axi_m_m;          
  input   [31:0]      rdata_extsys0_axi_m_m;        
  input   [1:0]       rresp_extsys0_axi_m_m;        
  input               rlast_extsys0_axi_m_m;        
  input               rvalid_extsys0_axi_m_m;       
  output              rready_extsys0_axi_m_m;       



  input   [17:0]      awid_extsys0_axi_m_s;         
  input   [31:0]      awaddr_extsys0_axi_m_s;       
  input   [7:0]       awlen_extsys0_axi_m_s;        
  input   [2:0]       awsize_extsys0_axi_m_s;       
  input   [1:0]       awburst_extsys0_axi_m_s;      
  input               awlock_extsys0_axi_m_s;       
  input   [3:0]       awcache_extsys0_axi_m_s;      
  input   [2:0]       awprot_extsys0_axi_m_s;       
  input               awvalid_extsys0_axi_m_s;      
  output              awready_extsys0_axi_m_s;      

  input   [31:0]      wdata_extsys0_axi_m_s;        
  input   [3:0]       wstrb_extsys0_axi_m_s;        
  input               wlast_extsys0_axi_m_s;        
  input               wvalid_extsys0_axi_m_s;       
  output              wready_extsys0_axi_m_s;       

  output  [17:0]      bid_extsys0_axi_m_s;          
  output  [1:0]       bresp_extsys0_axi_m_s;        
  output              bvalid_extsys0_axi_m_s;       
  input               bready_extsys0_axi_m_s;       

  input   [17:0]      arid_extsys0_axi_m_s;         
  input   [31:0]      araddr_extsys0_axi_m_s;       
  input   [7:0]       arlen_extsys0_axi_m_s;        
  input   [2:0]       arsize_extsys0_axi_m_s;       
  input   [1:0]       arburst_extsys0_axi_m_s;      
  input               arlock_extsys0_axi_m_s;       
  input   [3:0]       arcache_extsys0_axi_m_s;      
  input   [2:0]       arprot_extsys0_axi_m_s;       
  input               arvalid_extsys0_axi_m_s;      
  output              arready_extsys0_axi_m_s;      

  output  [17:0]      rid_extsys0_axi_m_s;          
  output  [31:0]      rdata_extsys0_axi_m_s;        
  output  [1:0]       rresp_extsys0_axi_m_s;        
  output              rlast_extsys0_axi_m_s;        
  output              rvalid_extsys0_axi_m_s;       
  input               rready_extsys0_axi_m_s;       

  input               aclk;                         
  input               aresetn;                      






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [36:0]    w_master_port_src_data;     
  wire [36:0]    w_master_port_dst_data;     



  wire           b_master_port_dst_valid;
  wire           b_master_port_dst_ready;
  wire           b_master_port_src_valid;
  wire           b_master_port_src_ready;

  wire [19:0]    b_master_port_src_data;     
  wire [19:0]    b_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [52:0]    r_master_port_src_data;     
  wire [52:0]    r_master_port_dst_data;     







  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_extsys0_axi_m_s[31:24]  & {8{wstrb_extsys0_axi_m_s[3]}}),
  (wdata_extsys0_axi_m_s[23:16]  & {8{wstrb_extsys0_axi_m_s[2]}}),
  (wdata_extsys0_axi_m_s[15:8]  & {8{wstrb_extsys0_axi_m_s[1]}}),
  (wdata_extsys0_axi_m_s[7:0]  & {8{wstrb_extsys0_axi_m_s[0]}})};
  
  assign awid_extsys0_axi_m_m     = awid_extsys0_axi_m_s;
  assign awaddr_extsys0_axi_m_m   = awaddr_extsys0_axi_m_s;
  assign awlen_extsys0_axi_m_m    = awlen_extsys0_axi_m_s;
  assign awsize_extsys0_axi_m_m   = awsize_extsys0_axi_m_s;
  assign awburst_extsys0_axi_m_m  = awburst_extsys0_axi_m_s;
  assign awlock_extsys0_axi_m_m   = awlock_extsys0_axi_m_s;
  assign awcache_extsys0_axi_m_m  = awcache_extsys0_axi_m_s;
  assign awprot_extsys0_axi_m_m   = awprot_extsys0_axi_m_s;
  assign awvalid_extsys0_axi_m_m  = awvalid_extsys0_axi_m_s;
  assign awready_extsys0_axi_m_s  = awready_extsys0_axi_m_m;
  assign arid_extsys0_axi_m_m     = arid_extsys0_axi_m_s;
  assign araddr_extsys0_axi_m_m   = araddr_extsys0_axi_m_s;
  assign arlen_extsys0_axi_m_m    = arlen_extsys0_axi_m_s;
  assign arsize_extsys0_axi_m_m   = arsize_extsys0_axi_m_s;
  assign arburst_extsys0_axi_m_m  = arburst_extsys0_axi_m_s;
  assign arlock_extsys0_axi_m_m   = arlock_extsys0_axi_m_s;
  assign arcache_extsys0_axi_m_m  = arcache_extsys0_axi_m_s;
  assign arprot_extsys0_axi_m_m   = arprot_extsys0_axi_m_s;
  assign arvalid_extsys0_axi_m_m  = arvalid_extsys0_axi_m_s;
  assign arready_extsys0_axi_m_s  = arready_extsys0_axi_m_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_extsys0_axi_m_s,
        wlast_extsys0_axi_m_s};

  assign {wdata_extsys0_axi_m_m,
        wstrb_extsys0_axi_m_m,
        wlast_extsys0_axi_m_m} = w_master_port_dst_data;

  assign wvalid_extsys0_axi_m_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_extsys0_axi_m_m;

  assign w_master_port_src_valid = wvalid_extsys0_axi_m_s;
  assign wready_extsys0_axi_m_s = w_master_port_src_ready;



  assign b_master_port_src_data = {bid_extsys0_axi_m_m,
        bresp_extsys0_axi_m_m};

  assign {bid_extsys0_axi_m_s,
        bresp_extsys0_axi_m_s} = b_master_port_dst_data;

  assign bvalid_extsys0_axi_m_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_extsys0_axi_m_s;

  assign b_master_port_src_valid = bvalid_extsys0_axi_m_m;
  assign bready_extsys0_axi_m_m = b_master_port_src_ready;



  assign r_master_port_src_data = {rid_extsys0_axi_m_m,
        rdata_extsys0_axi_m_m,
        rresp_extsys0_axi_m_m,
        rlast_extsys0_axi_m_m};

  assign {rid_extsys0_axi_m_s,
        rdata_extsys0_axi_m_s,
        rresp_extsys0_axi_m_s,
        rlast_extsys0_axi_m_s} = r_master_port_dst_data;

  assign rvalid_extsys0_axi_m_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_extsys0_axi_m_s;

  assign r_master_port_src_valid = rvalid_extsys0_axi_m_m;
  assign rready_extsys0_axi_m_m = r_master_port_src_ready;






  nic400_amib_extsys0_axi_m_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       37  
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




  nic400_amib_extsys0_axi_m_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       20  
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




  nic400_amib_extsys0_axi_m_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       53  
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


  assign wif_hndshk = wvalid_extsys0_axi_m_m & wready_extsys0_axi_m_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_extsys0_axi_m_m[31:24]  & ~wstrb_extsys0_axi_m_m[3]) | 
  (|wdata_extsys0_axi_m_m[23:16]  & ~wstrb_extsys0_axi_m_m[2]) | 
  (|wdata_extsys0_axi_m_m[15:8]  & ~wstrb_extsys0_axi_m_m[1]) | 
  (|wdata_extsys0_axi_m_m[7:0]  & ~wstrb_extsys0_axi_m_m[0]));



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

`include "nic400_amib_extsys0_axi_m_undefs_sse710_integration_example_f0_host_exp.v"

