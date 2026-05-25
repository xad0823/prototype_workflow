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



`include "nic400_amib_sysctrl_axim_defs_sse710_main.v"

module nic400_amib_sysctrl_axim_sse710_main
  (
  

    awid_sysctrl_axim_s,
    awaddr_sysctrl_axim_s,
    awlen_sysctrl_axim_s,
    awsize_sysctrl_axim_s,
    awburst_sysctrl_axim_s,
    awlock_sysctrl_axim_s,
    awcache_sysctrl_axim_s,
    awprot_sysctrl_axim_s,
    awvalid_sysctrl_axim_s,
    awready_sysctrl_axim_s,

    wdata_sysctrl_axim_s,
    wstrb_sysctrl_axim_s,
    wlast_sysctrl_axim_s,
    wvalid_sysctrl_axim_s,
    wready_sysctrl_axim_s,

    bid_sysctrl_axim_s,
    bresp_sysctrl_axim_s,
    bvalid_sysctrl_axim_s,
    bready_sysctrl_axim_s,

    arid_sysctrl_axim_s,
    araddr_sysctrl_axim_s,
    arlen_sysctrl_axim_s,
    arsize_sysctrl_axim_s,
    arburst_sysctrl_axim_s,
    arlock_sysctrl_axim_s,
    arcache_sysctrl_axim_s,
    arprot_sysctrl_axim_s,
    arvalid_sysctrl_axim_s,
    arready_sysctrl_axim_s,

    rid_sysctrl_axim_s,
    rdata_sysctrl_axim_s,
    rresp_sysctrl_axim_s,
    rlast_sysctrl_axim_s,
    rvalid_sysctrl_axim_s,
    rready_sysctrl_axim_s,

    awuser_sysctrl_axim_s,
    buser_sysctrl_axim_s,
    aruser_sysctrl_axim_s,
    ruser_sysctrl_axim_s,


    awid_sysctrl_axim_m,
    awaddr_sysctrl_axim_m,
    awlen_sysctrl_axim_m,
    awsize_sysctrl_axim_m,
    awburst_sysctrl_axim_m,
    awlock_sysctrl_axim_m,
    awcache_sysctrl_axim_m,
    awprot_sysctrl_axim_m,
    awvalid_sysctrl_axim_m,
    awready_sysctrl_axim_m,

    wdata_sysctrl_axim_m,
    wstrb_sysctrl_axim_m,
    wlast_sysctrl_axim_m,
    wvalid_sysctrl_axim_m,
    wready_sysctrl_axim_m,

    bid_sysctrl_axim_m,
    bresp_sysctrl_axim_m,
    bvalid_sysctrl_axim_m,
    bready_sysctrl_axim_m,

    arid_sysctrl_axim_m,
    araddr_sysctrl_axim_m,
    arlen_sysctrl_axim_m,
    arsize_sysctrl_axim_m,
    arburst_sysctrl_axim_m,
    arlock_sysctrl_axim_m,
    arcache_sysctrl_axim_m,
    arprot_sysctrl_axim_m,
    arvalid_sysctrl_axim_m,
    arready_sysctrl_axim_m,

    rid_sysctrl_axim_m,
    rdata_sysctrl_axim_m,
    rresp_sysctrl_axim_m,
    rlast_sysctrl_axim_m,
    rvalid_sysctrl_axim_m,
    rready_sysctrl_axim_m,

    awuser_sysctrl_axim_m,
    buser_sysctrl_axim_m,
    aruser_sysctrl_axim_m,
    ruser_sysctrl_axim_m,

    aclk,
    aresetn

  );




  


  input   [11:0]      awid_sysctrl_axim_s;         
  input   [39:0]      awaddr_sysctrl_axim_s;       
  input   [7:0]       awlen_sysctrl_axim_s;        
  input   [2:0]       awsize_sysctrl_axim_s;       
  input   [1:0]       awburst_sysctrl_axim_s;      
  input               awlock_sysctrl_axim_s;       
  input   [3:0]       awcache_sysctrl_axim_s;      
  input   [2:0]       awprot_sysctrl_axim_s;       
  input               awvalid_sysctrl_axim_s;      
  output              awready_sysctrl_axim_s;      

  input   [31:0]      wdata_sysctrl_axim_s;        
  input   [3:0]       wstrb_sysctrl_axim_s;        
  input               wlast_sysctrl_axim_s;        
  input               wvalid_sysctrl_axim_s;       
  output              wready_sysctrl_axim_s;       

  output  [11:0]      bid_sysctrl_axim_s;          
  output  [1:0]       bresp_sysctrl_axim_s;        
  output              bvalid_sysctrl_axim_s;       
  input               bready_sysctrl_axim_s;       

  input   [11:0]      arid_sysctrl_axim_s;         
  input   [39:0]      araddr_sysctrl_axim_s;       
  input   [7:0]       arlen_sysctrl_axim_s;        
  input   [2:0]       arsize_sysctrl_axim_s;       
  input   [1:0]       arburst_sysctrl_axim_s;      
  input               arlock_sysctrl_axim_s;       
  input   [3:0]       arcache_sysctrl_axim_s;      
  input   [2:0]       arprot_sysctrl_axim_s;       
  input               arvalid_sysctrl_axim_s;      
  output              arready_sysctrl_axim_s;      

  output  [11:0]      rid_sysctrl_axim_s;          
  output  [31:0]      rdata_sysctrl_axim_s;        
  output  [1:0]       rresp_sysctrl_axim_s;        
  output              rlast_sysctrl_axim_s;        
  output              rvalid_sysctrl_axim_s;       
  input               rready_sysctrl_axim_s;       

  input   [9:0]       awuser_sysctrl_axim_s;       
  output              buser_sysctrl_axim_s;        
  input   [9:0]       aruser_sysctrl_axim_s;       
  output              ruser_sysctrl_axim_s;        



  output  [11:0]      awid_sysctrl_axim_m;         
  output  [31:0]      awaddr_sysctrl_axim_m;       
  output  [7:0]       awlen_sysctrl_axim_m;        
  output  [2:0]       awsize_sysctrl_axim_m;       
  output  [1:0]       awburst_sysctrl_axim_m;      
  output              awlock_sysctrl_axim_m;       
  output  [3:0]       awcache_sysctrl_axim_m;      
  output  [2:0]       awprot_sysctrl_axim_m;       
  output              awvalid_sysctrl_axim_m;      
  input               awready_sysctrl_axim_m;      

  output  [31:0]      wdata_sysctrl_axim_m;        
  output  [3:0]       wstrb_sysctrl_axim_m;        
  output              wlast_sysctrl_axim_m;        
  output              wvalid_sysctrl_axim_m;       
  input               wready_sysctrl_axim_m;       

  input   [11:0]      bid_sysctrl_axim_m;          
  input   [1:0]       bresp_sysctrl_axim_m;        
  input               bvalid_sysctrl_axim_m;       
  output              bready_sysctrl_axim_m;       

  output  [11:0]      arid_sysctrl_axim_m;         
  output  [31:0]      araddr_sysctrl_axim_m;       
  output  [7:0]       arlen_sysctrl_axim_m;        
  output  [2:0]       arsize_sysctrl_axim_m;       
  output  [1:0]       arburst_sysctrl_axim_m;      
  output              arlock_sysctrl_axim_m;       
  output  [3:0]       arcache_sysctrl_axim_m;      
  output  [2:0]       arprot_sysctrl_axim_m;       
  output              arvalid_sysctrl_axim_m;      
  input               arready_sysctrl_axim_m;      

  input   [11:0]      rid_sysctrl_axim_m;          
  input   [31:0]      rdata_sysctrl_axim_m;        
  input   [1:0]       rresp_sysctrl_axim_m;        
  input               rlast_sysctrl_axim_m;        
  input               rvalid_sysctrl_axim_m;       
  output              rready_sysctrl_axim_m;       

  output  [9:0]       awuser_sysctrl_axim_m;       
  input               buser_sysctrl_axim_m;        
  output  [9:0]       aruser_sysctrl_axim_m;       
  input               ruser_sysctrl_axim_m;        

  input               aclk;                        
  input               aresetn;                     






  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [47:0]    r_master_port_src_data;     
  wire [47:0]    r_master_port_dst_data;     



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

  wire [14:0]    b_master_port_src_data;     
  wire [14:0]    b_master_port_dst_data;     



  wire           aw_master_port_dst_valid;
  wire           aw_master_port_dst_ready;
  wire           aw_master_port_src_valid;
  wire           aw_master_port_src_ready;

  wire [74:0]    aw_master_port_src_data;     
  wire [74:0]    aw_master_port_dst_data;     



  wire           ar_master_port_dst_valid;
  wire           ar_master_port_dst_ready;
  wire           ar_master_port_src_valid;
  wire           ar_master_port_src_ready;

  wire [74:0]    ar_master_port_src_data;     
  wire [74:0]    ar_master_port_dst_data;     




  wire [11:0]   awid;
  wire [11:0]   bid;
  wire [11:0]   arid;
  wire [11:0]   rid;




  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_sysctrl_axim_s[31:24]  & {8{wstrb_sysctrl_axim_s[3]}}),
  (wdata_sysctrl_axim_s[23:16]  & {8{wstrb_sysctrl_axim_s[2]}}),
  (wdata_sysctrl_axim_s[15:8]  & {8{wstrb_sysctrl_axim_s[1]}}),
  (wdata_sysctrl_axim_s[7:0]  & {8{wstrb_sysctrl_axim_s[0]}})};
  

  
  assign awid = {awid_sysctrl_axim_s[10],
  awid_sysctrl_axim_s[9],
  awid_sysctrl_axim_s[8],
  awid_sysctrl_axim_s[7],
  awid_sysctrl_axim_s[6],
  awid_sysctrl_axim_s[5],
  awid_sysctrl_axim_s[4],
  awid_sysctrl_axim_s[3],
  awid_sysctrl_axim_s[11],
  awid_sysctrl_axim_s[2],
  awid_sysctrl_axim_s[1],
  awid_sysctrl_axim_s[0]};

  assign arid = {arid_sysctrl_axim_s[10],
  arid_sysctrl_axim_s[9],
  arid_sysctrl_axim_s[8],
  arid_sysctrl_axim_s[7],
  arid_sysctrl_axim_s[6],
  arid_sysctrl_axim_s[5],
  arid_sysctrl_axim_s[4],
  arid_sysctrl_axim_s[3],
  arid_sysctrl_axim_s[11],
  arid_sysctrl_axim_s[2],
  arid_sysctrl_axim_s[1],
  arid_sysctrl_axim_s[0]};


  assign rid_sysctrl_axim_s = {rid[3],
    rid[11],
    rid[10],
    rid[9],
    rid[8],
    rid[7],
    rid[6],
    rid[5],
    rid[4],
    rid[2],
    rid[1],
    rid[0]};

  assign bid_sysctrl_axim_s = {bid[3],
    bid[11],
    bid[10],
    bid[9],
    bid[8],
    bid[7],
    bid[6],
    bid[5],
    bid[4],
    bid[2],
    bid[1],
    bid[0]};


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_sysctrl_axim_s,
        wlast_sysctrl_axim_s};

  assign {wdata_sysctrl_axim_m,
        wstrb_sysctrl_axim_m,
        wlast_sysctrl_axim_m} = w_master_port_dst_data;

  assign wvalid_sysctrl_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_sysctrl_axim_m;

  assign w_master_port_src_valid = wvalid_sysctrl_axim_s;
  assign wready_sysctrl_axim_s = w_master_port_src_ready;




  assign aw_master_port_src_data = {awid,
        awaddr_sysctrl_axim_s[31:0],
        awlen_sysctrl_axim_s,
        awsize_sysctrl_axim_s,
        awburst_sysctrl_axim_s,
        awlock_sysctrl_axim_s,
        awcache_sysctrl_axim_s,
        awuser_sysctrl_axim_s,
        awprot_sysctrl_axim_s};

  assign {awid_sysctrl_axim_m,
        awaddr_sysctrl_axim_m,
        awlen_sysctrl_axim_m,
        awsize_sysctrl_axim_m,
        awburst_sysctrl_axim_m,
        awlock_sysctrl_axim_m,
        awcache_sysctrl_axim_m,
        awuser_sysctrl_axim_m,
        awprot_sysctrl_axim_m} = aw_master_port_dst_data;

  assign awvalid_sysctrl_axim_m = aw_master_port_dst_valid;
  assign aw_master_port_dst_ready = awready_sysctrl_axim_m;

  assign aw_master_port_src_valid = awvalid_sysctrl_axim_s;
  assign awready_sysctrl_axim_s = aw_master_port_src_ready;




  assign ar_master_port_src_data = {arid,
        araddr_sysctrl_axim_s[31:0],
        arlen_sysctrl_axim_s,
        arsize_sysctrl_axim_s,
        arburst_sysctrl_axim_s,
        arlock_sysctrl_axim_s,
        arcache_sysctrl_axim_s,
        aruser_sysctrl_axim_s,
        arprot_sysctrl_axim_s};

  assign {arid_sysctrl_axim_m,
        araddr_sysctrl_axim_m,
        arlen_sysctrl_axim_m,
        arsize_sysctrl_axim_m,
        arburst_sysctrl_axim_m,
        arlock_sysctrl_axim_m,
        arcache_sysctrl_axim_m,
        aruser_sysctrl_axim_m,
        arprot_sysctrl_axim_m} = ar_master_port_dst_data;

  assign arvalid_sysctrl_axim_m = ar_master_port_dst_valid;
  assign ar_master_port_dst_ready = arready_sysctrl_axim_m;

  assign ar_master_port_src_valid = arvalid_sysctrl_axim_s;
  assign arready_sysctrl_axim_s = ar_master_port_src_ready;



  assign r_master_port_src_data = {rid_sysctrl_axim_m,
        rdata_sysctrl_axim_m,
        rresp_sysctrl_axim_m,
        ruser_sysctrl_axim_m,
        rlast_sysctrl_axim_m};

  assign {rid,
        rdata_sysctrl_axim_s,
        rresp_sysctrl_axim_s,
        ruser_sysctrl_axim_s,
        rlast_sysctrl_axim_s} = r_master_port_dst_data;

  assign rvalid_sysctrl_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_sysctrl_axim_s;

  assign r_master_port_src_valid = rvalid_sysctrl_axim_m;
  assign rready_sysctrl_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_sysctrl_axim_m,
        bresp_sysctrl_axim_m,
        buser_sysctrl_axim_m};

  assign {bid,
        bresp_sysctrl_axim_s,
        buser_sysctrl_axim_s} = b_master_port_dst_data;

  assign bvalid_sysctrl_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_sysctrl_axim_s;

  assign b_master_port_src_valid = bvalid_sysctrl_axim_m;
  assign bready_sysctrl_axim_m = b_master_port_src_ready;






  nic400_amib_sysctrl_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       48  
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




  nic400_amib_sysctrl_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
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




  nic400_amib_sysctrl_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       15  
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




  nic400_amib_sysctrl_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       75  
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




  nic400_amib_sysctrl_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       75  
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


  assign wif_hndshk = wvalid_sysctrl_axim_m & wready_sysctrl_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_sysctrl_axim_m[31:24]  & ~wstrb_sysctrl_axim_m[3]) | 
  (|wdata_sysctrl_axim_m[23:16]  & ~wstrb_sysctrl_axim_m[2]) | 
  (|wdata_sysctrl_axim_m[15:8]  & ~wstrb_sysctrl_axim_m[1]) | 
  (|wdata_sysctrl_axim_m[7:0]  & ~wstrb_sysctrl_axim_m[0]));



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

`include "nic400_amib_sysctrl_axim_undefs_sse710_main.v"

