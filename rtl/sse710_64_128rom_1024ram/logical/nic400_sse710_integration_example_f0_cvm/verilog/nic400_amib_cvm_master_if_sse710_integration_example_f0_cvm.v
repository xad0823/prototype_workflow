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



`include "nic400_amib_cvm_master_if_defs_sse710_integration_example_f0_cvm.v"

module nic400_amib_cvm_master_if_sse710_integration_example_f0_cvm
  (
  

    awid_cvm_master_if_m,
    awaddr_cvm_master_if_m,
    awlen_cvm_master_if_m,
    awsize_cvm_master_if_m,
    awburst_cvm_master_if_m,
    awlock_cvm_master_if_m,
    awcache_cvm_master_if_m,
    awprot_cvm_master_if_m,
    awvalid_cvm_master_if_m,
    awready_cvm_master_if_m,

    wdata_cvm_master_if_m,
    wstrb_cvm_master_if_m,
    wlast_cvm_master_if_m,
    wvalid_cvm_master_if_m,
    wready_cvm_master_if_m,

    bid_cvm_master_if_m,
    bresp_cvm_master_if_m,
    bvalid_cvm_master_if_m,
    bready_cvm_master_if_m,

    arid_cvm_master_if_m,
    araddr_cvm_master_if_m,
    arlen_cvm_master_if_m,
    arsize_cvm_master_if_m,
    arburst_cvm_master_if_m,
    arlock_cvm_master_if_m,
    arcache_cvm_master_if_m,
    arprot_cvm_master_if_m,
    arvalid_cvm_master_if_m,
    arready_cvm_master_if_m,

    rid_cvm_master_if_m,
    rdata_cvm_master_if_m,
    rresp_cvm_master_if_m,
    rlast_cvm_master_if_m,
    rvalid_cvm_master_if_m,
    rready_cvm_master_if_m,


    awid_cvm_master_if_s,
    awaddr_cvm_master_if_s,
    awlen_cvm_master_if_s,
    awsize_cvm_master_if_s,
    awburst_cvm_master_if_s,
    awlock_cvm_master_if_s,
    awcache_cvm_master_if_s,
    awprot_cvm_master_if_s,
    awvalid_cvm_master_if_s,
    awready_cvm_master_if_s,

    wdata_cvm_master_if_s,
    wstrb_cvm_master_if_s,
    wlast_cvm_master_if_s,
    wvalid_cvm_master_if_s,
    wready_cvm_master_if_s,

    bid_cvm_master_if_s,
    bresp_cvm_master_if_s,
    bvalid_cvm_master_if_s,
    bready_cvm_master_if_s,

    arid_cvm_master_if_s,
    araddr_cvm_master_if_s,
    arlen_cvm_master_if_s,
    arsize_cvm_master_if_s,
    arburst_cvm_master_if_s,
    arlock_cvm_master_if_s,
    arcache_cvm_master_if_s,
    arprot_cvm_master_if_s,
    arvalid_cvm_master_if_s,
    arready_cvm_master_if_s,

    rid_cvm_master_if_s,
    rdata_cvm_master_if_s,
    rresp_cvm_master_if_s,
    rlast_cvm_master_if_s,
    rvalid_cvm_master_if_s,
    rready_cvm_master_if_s,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_cvm_master_if_m;         
  output  [31:0]      awaddr_cvm_master_if_m;       
  output  [7:0]       awlen_cvm_master_if_m;        
  output  [2:0]       awsize_cvm_master_if_m;       
  output  [1:0]       awburst_cvm_master_if_m;      
  output              awlock_cvm_master_if_m;       
  output  [3:0]       awcache_cvm_master_if_m;      
  output  [2:0]       awprot_cvm_master_if_m;       
  output              awvalid_cvm_master_if_m;      
  input               awready_cvm_master_if_m;      

  output  [63:0]      wdata_cvm_master_if_m;        
  output  [7:0]       wstrb_cvm_master_if_m;        
  output              wlast_cvm_master_if_m;        
  output              wvalid_cvm_master_if_m;       
  input               wready_cvm_master_if_m;       

  input   [11:0]      bid_cvm_master_if_m;          
  input   [1:0]       bresp_cvm_master_if_m;        
  input               bvalid_cvm_master_if_m;       
  output              bready_cvm_master_if_m;       

  output  [11:0]      arid_cvm_master_if_m;         
  output  [31:0]      araddr_cvm_master_if_m;       
  output  [7:0]       arlen_cvm_master_if_m;        
  output  [2:0]       arsize_cvm_master_if_m;       
  output  [1:0]       arburst_cvm_master_if_m;      
  output              arlock_cvm_master_if_m;       
  output  [3:0]       arcache_cvm_master_if_m;      
  output  [2:0]       arprot_cvm_master_if_m;       
  output              arvalid_cvm_master_if_m;      
  input               arready_cvm_master_if_m;      

  input   [11:0]      rid_cvm_master_if_m;          
  input   [63:0]      rdata_cvm_master_if_m;        
  input   [1:0]       rresp_cvm_master_if_m;        
  input               rlast_cvm_master_if_m;        
  input               rvalid_cvm_master_if_m;       
  output              rready_cvm_master_if_m;       



  input   [11:0]      awid_cvm_master_if_s;         
  input   [31:0]      awaddr_cvm_master_if_s;       
  input   [7:0]       awlen_cvm_master_if_s;        
  input   [2:0]       awsize_cvm_master_if_s;       
  input   [1:0]       awburst_cvm_master_if_s;      
  input               awlock_cvm_master_if_s;       
  input   [3:0]       awcache_cvm_master_if_s;      
  input   [2:0]       awprot_cvm_master_if_s;       
  input               awvalid_cvm_master_if_s;      
  output              awready_cvm_master_if_s;      

  input   [63:0]      wdata_cvm_master_if_s;        
  input   [7:0]       wstrb_cvm_master_if_s;        
  input               wlast_cvm_master_if_s;        
  input               wvalid_cvm_master_if_s;       
  output              wready_cvm_master_if_s;       

  output  [11:0]      bid_cvm_master_if_s;          
  output  [1:0]       bresp_cvm_master_if_s;        
  output              bvalid_cvm_master_if_s;       
  input               bready_cvm_master_if_s;       

  input   [11:0]      arid_cvm_master_if_s;         
  input   [31:0]      araddr_cvm_master_if_s;       
  input   [7:0]       arlen_cvm_master_if_s;        
  input   [2:0]       arsize_cvm_master_if_s;       
  input   [1:0]       arburst_cvm_master_if_s;      
  input               arlock_cvm_master_if_s;       
  input   [3:0]       arcache_cvm_master_if_s;      
  input   [2:0]       arprot_cvm_master_if_s;       
  input               arvalid_cvm_master_if_s;      
  output              arready_cvm_master_if_s;      

  output  [11:0]      rid_cvm_master_if_s;          
  output  [63:0]      rdata_cvm_master_if_s;        
  output  [1:0]       rresp_cvm_master_if_s;        
  output              rlast_cvm_master_if_s;        
  output              rvalid_cvm_master_if_s;       
  input               rready_cvm_master_if_s;       

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

  wire [13:0]    b_master_port_src_data;     
  wire [13:0]    b_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [78:0]    r_master_port_src_data;     
  wire [78:0]    r_master_port_dst_data;     



  wire           aw_master_port_dst_valid;
  wire           aw_master_port_dst_ready;
  wire           aw_master_port_src_valid;
  wire           aw_master_port_src_ready;

  wire [64:0]    aw_master_port_src_data;     
  wire [64:0]    aw_master_port_dst_data;     



  wire           ar_master_port_dst_valid;
  wire           ar_master_port_dst_ready;
  wire           ar_master_port_src_valid;
  wire           ar_master_port_src_ready;

  wire [64:0]    ar_master_port_src_data;     
  wire [64:0]    ar_master_port_dst_data;     




  wire [11:0]   awid;
  wire [11:0]   bid;
  wire [11:0]   arid;
  wire [11:0]   rid;




  wire [63:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_cvm_master_if_s[63:56]  & {8{wstrb_cvm_master_if_s[7]}}),
  (wdata_cvm_master_if_s[55:48]  & {8{wstrb_cvm_master_if_s[6]}}),
  (wdata_cvm_master_if_s[47:40]  & {8{wstrb_cvm_master_if_s[5]}}),
  (wdata_cvm_master_if_s[39:32]  & {8{wstrb_cvm_master_if_s[4]}}),
  (wdata_cvm_master_if_s[31:24]  & {8{wstrb_cvm_master_if_s[3]}}),
  (wdata_cvm_master_if_s[23:16]  & {8{wstrb_cvm_master_if_s[2]}}),
  (wdata_cvm_master_if_s[15:8]  & {8{wstrb_cvm_master_if_s[1]}}),
  (wdata_cvm_master_if_s[7:0]  & {8{wstrb_cvm_master_if_s[0]}})};
  

  
  assign awid = {awid_cvm_master_if_s[11],
  awid_cvm_master_if_s[10],
  awid_cvm_master_if_s[9],
  awid_cvm_master_if_s[8],
  awid_cvm_master_if_s[7],
  awid_cvm_master_if_s[6],
  awid_cvm_master_if_s[5],
  awid_cvm_master_if_s[4],
  awid_cvm_master_if_s[3],
  awid_cvm_master_if_s[2],
  awid_cvm_master_if_s[1],
  awid_cvm_master_if_s[0]};

  assign arid = {arid_cvm_master_if_s[11],
  arid_cvm_master_if_s[10],
  arid_cvm_master_if_s[9],
  arid_cvm_master_if_s[8],
  arid_cvm_master_if_s[7],
  arid_cvm_master_if_s[6],
  arid_cvm_master_if_s[5],
  arid_cvm_master_if_s[4],
  arid_cvm_master_if_s[3],
  arid_cvm_master_if_s[2],
  arid_cvm_master_if_s[1],
  arid_cvm_master_if_s[0]};


  assign rid_cvm_master_if_s = {rid[11],
    rid[10],
    rid[9],
    rid[8],
    rid[7],
    rid[6],
    rid[5],
    rid[4],
    rid[3],
    rid[2],
    rid[1],
    rid[0]};

  assign bid_cvm_master_if_s = {bid[11],
    bid[10],
    bid[9],
    bid[8],
    bid[7],
    bid[6],
    bid[5],
    bid[4],
    bid[3],
    bid[2],
    bid[1],
    bid[0]};


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_cvm_master_if_s,
        wlast_cvm_master_if_s};

  assign {wdata_cvm_master_if_m,
        wstrb_cvm_master_if_m,
        wlast_cvm_master_if_m} = w_master_port_dst_data;

  assign wvalid_cvm_master_if_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_cvm_master_if_m;

  assign w_master_port_src_valid = wvalid_cvm_master_if_s;
  assign wready_cvm_master_if_s = w_master_port_src_ready;




  assign aw_master_port_src_data = {awid,
        awaddr_cvm_master_if_s,
        awlen_cvm_master_if_s,
        awsize_cvm_master_if_s,
        awburst_cvm_master_if_s,
        awlock_cvm_master_if_s,
        awcache_cvm_master_if_s,
        awprot_cvm_master_if_s};

  assign {awid_cvm_master_if_m,
        awaddr_cvm_master_if_m,
        awlen_cvm_master_if_m,
        awsize_cvm_master_if_m,
        awburst_cvm_master_if_m,
        awlock_cvm_master_if_m,
        awcache_cvm_master_if_m,
        awprot_cvm_master_if_m} = aw_master_port_dst_data;

  assign awvalid_cvm_master_if_m = aw_master_port_dst_valid;
  assign aw_master_port_dst_ready = awready_cvm_master_if_m;

  assign aw_master_port_src_valid = awvalid_cvm_master_if_s;
  assign awready_cvm_master_if_s = aw_master_port_src_ready;




  assign ar_master_port_src_data = {arid,
        araddr_cvm_master_if_s,
        arlen_cvm_master_if_s,
        arsize_cvm_master_if_s,
        arburst_cvm_master_if_s,
        arlock_cvm_master_if_s,
        arcache_cvm_master_if_s,
        arprot_cvm_master_if_s};

  assign {arid_cvm_master_if_m,
        araddr_cvm_master_if_m,
        arlen_cvm_master_if_m,
        arsize_cvm_master_if_m,
        arburst_cvm_master_if_m,
        arlock_cvm_master_if_m,
        arcache_cvm_master_if_m,
        arprot_cvm_master_if_m} = ar_master_port_dst_data;

  assign arvalid_cvm_master_if_m = ar_master_port_dst_valid;
  assign ar_master_port_dst_ready = arready_cvm_master_if_m;

  assign ar_master_port_src_valid = arvalid_cvm_master_if_s;
  assign arready_cvm_master_if_s = ar_master_port_src_ready;



  assign b_master_port_src_data = {bid_cvm_master_if_m,
        bresp_cvm_master_if_m};

  assign {bid,
        bresp_cvm_master_if_s} = b_master_port_dst_data;

  assign bvalid_cvm_master_if_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_cvm_master_if_s;

  assign b_master_port_src_valid = bvalid_cvm_master_if_m;
  assign bready_cvm_master_if_m = b_master_port_src_ready;



  assign r_master_port_src_data = {rid_cvm_master_if_m,
        rdata_cvm_master_if_m,
        rresp_cvm_master_if_m,
        rlast_cvm_master_if_m};

  assign {rid,
        rdata_cvm_master_if_s,
        rresp_cvm_master_if_s,
        rlast_cvm_master_if_s} = r_master_port_dst_data;

  assign rvalid_cvm_master_if_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_cvm_master_if_s;

  assign r_master_port_src_valid = rvalid_cvm_master_if_m;
  assign rready_cvm_master_if_m = r_master_port_src_ready;






  nic400_amib_cvm_master_if_chan_slice_sse710_integration_example_f0_cvm
    #(
       `RS_FWD_REG,  
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




  nic400_amib_cvm_master_if_chan_slice_sse710_integration_example_f0_cvm
    #(
       `RS_REV_REG,  
       14  
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




  nic400_amib_cvm_master_if_chan_slice_sse710_integration_example_f0_cvm
    #(
       `RS_REV_REG,  
       79  
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




  nic400_amib_cvm_master_if_chan_slice_sse710_integration_example_f0_cvm
    #(
       `RS_FWD_REG,  
       65  
     )
  u_aw_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (aw_master_port_src_valid),
     .src_data              (aw_master_port_src_data),
     .dst_ready             (aw_master_port_dst_ready),

     .src_ready             (aw_master_port_src_ready),
     .dst_data              (aw_master_port_dst_data),
     .dst_valid             (aw_master_port_dst_valid)
     );




  nic400_amib_cvm_master_if_chan_slice_sse710_integration_example_f0_cvm
    #(
       `RS_FWD_REG,  
       65  
     )
  u_ar_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (ar_master_port_src_valid),
     .src_data              (ar_master_port_src_data),
     .dst_ready             (ar_master_port_dst_ready),

     .src_ready             (ar_master_port_src_ready),
     .dst_data              (ar_master_port_dst_data),
     .dst_valid             (ar_master_port_dst_valid)
     );









`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"




  wire strobeless_wdata;
  wire wif_hndshk;


  assign wif_hndshk = wvalid_cvm_master_if_m & wready_cvm_master_if_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_cvm_master_if_m[63:56]  & ~wstrb_cvm_master_if_m[7]) | 
  (|wdata_cvm_master_if_m[55:48]  & ~wstrb_cvm_master_if_m[6]) | 
  (|wdata_cvm_master_if_m[47:40]  & ~wstrb_cvm_master_if_m[5]) | 
  (|wdata_cvm_master_if_m[39:32]  & ~wstrb_cvm_master_if_m[4]) | 
  (|wdata_cvm_master_if_m[31:24]  & ~wstrb_cvm_master_if_m[3]) | 
  (|wdata_cvm_master_if_m[23:16]  & ~wstrb_cvm_master_if_m[2]) | 
  (|wdata_cvm_master_if_m[15:8]  & ~wstrb_cvm_master_if_m[1]) | 
  (|wdata_cvm_master_if_m[7:0]  & ~wstrb_cvm_master_if_m[0]));



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

`include "nic400_amib_cvm_master_if_undefs_sse710_integration_example_f0_cvm.v"

