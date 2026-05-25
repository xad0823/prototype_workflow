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



`include "nic400_amib_ocvm_axim_defs_sse710_main.v"

module nic400_amib_ocvm_axim_sse710_main
  (
  

    awid_ocvm_axim_m,
    awaddr_ocvm_axim_m,
    awlen_ocvm_axim_m,
    awsize_ocvm_axim_m,
    awburst_ocvm_axim_m,
    awlock_ocvm_axim_m,
    awcache_ocvm_axim_m,
    awprot_ocvm_axim_m,
    awvalid_ocvm_axim_m,
    awready_ocvm_axim_m,

    wdata_ocvm_axim_m,
    wstrb_ocvm_axim_m,
    wlast_ocvm_axim_m,
    wvalid_ocvm_axim_m,
    wready_ocvm_axim_m,

    bid_ocvm_axim_m,
    bresp_ocvm_axim_m,
    bvalid_ocvm_axim_m,
    bready_ocvm_axim_m,

    arid_ocvm_axim_m,
    araddr_ocvm_axim_m,
    arlen_ocvm_axim_m,
    arsize_ocvm_axim_m,
    arburst_ocvm_axim_m,
    arlock_ocvm_axim_m,
    arcache_ocvm_axim_m,
    arprot_ocvm_axim_m,
    arvalid_ocvm_axim_m,
    arready_ocvm_axim_m,

    rid_ocvm_axim_m,
    rdata_ocvm_axim_m,
    rresp_ocvm_axim_m,
    rlast_ocvm_axim_m,
    rvalid_ocvm_axim_m,
    rready_ocvm_axim_m,

    awuser_ocvm_axim_m,
    buser_ocvm_axim_m,
    aruser_ocvm_axim_m,
    ruser_ocvm_axim_m,

    awqv_ocvm_axim_m,
    arqv_ocvm_axim_m,


    awid_ocvm_axim_s,
    awaddr_ocvm_axim_s,
    awlen_ocvm_axim_s,
    awsize_ocvm_axim_s,
    awburst_ocvm_axim_s,
    awlock_ocvm_axim_s,
    awcache_ocvm_axim_s,
    awprot_ocvm_axim_s,
    awvalid_ocvm_axim_s,
    awready_ocvm_axim_s,

    wdata_ocvm_axim_s,
    wstrb_ocvm_axim_s,
    wlast_ocvm_axim_s,
    wvalid_ocvm_axim_s,
    wready_ocvm_axim_s,

    bid_ocvm_axim_s,
    bresp_ocvm_axim_s,
    bvalid_ocvm_axim_s,
    bready_ocvm_axim_s,

    arid_ocvm_axim_s,
    araddr_ocvm_axim_s,
    arlen_ocvm_axim_s,
    arsize_ocvm_axim_s,
    arburst_ocvm_axim_s,
    arlock_ocvm_axim_s,
    arcache_ocvm_axim_s,
    arprot_ocvm_axim_s,
    arvalid_ocvm_axim_s,
    arready_ocvm_axim_s,

    rid_ocvm_axim_s,
    rdata_ocvm_axim_s,
    rresp_ocvm_axim_s,
    rlast_ocvm_axim_s,
    rvalid_ocvm_axim_s,
    rready_ocvm_axim_s,

    awuser_ocvm_axim_s,
    buser_ocvm_axim_s,
    aruser_ocvm_axim_s,
    ruser_ocvm_axim_s,

    awqv_ocvm_axim_s,
    arqv_ocvm_axim_s,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_ocvm_axim_m;         
  output  [31:0]      awaddr_ocvm_axim_m;       
  output  [7:0]       awlen_ocvm_axim_m;        
  output  [2:0]       awsize_ocvm_axim_m;       
  output  [1:0]       awburst_ocvm_axim_m;      
  output              awlock_ocvm_axim_m;       
  output  [3:0]       awcache_ocvm_axim_m;      
  output  [2:0]       awprot_ocvm_axim_m;       
  output              awvalid_ocvm_axim_m;      
  input               awready_ocvm_axim_m;      

  output  [63:0]      wdata_ocvm_axim_m;        
  output  [7:0]       wstrb_ocvm_axim_m;        
  output              wlast_ocvm_axim_m;        
  output              wvalid_ocvm_axim_m;       
  input               wready_ocvm_axim_m;       

  input   [11:0]      bid_ocvm_axim_m;          
  input   [1:0]       bresp_ocvm_axim_m;        
  input               bvalid_ocvm_axim_m;       
  output              bready_ocvm_axim_m;       

  output  [11:0]      arid_ocvm_axim_m;         
  output  [31:0]      araddr_ocvm_axim_m;       
  output  [7:0]       arlen_ocvm_axim_m;        
  output  [2:0]       arsize_ocvm_axim_m;       
  output  [1:0]       arburst_ocvm_axim_m;      
  output              arlock_ocvm_axim_m;       
  output  [3:0]       arcache_ocvm_axim_m;      
  output  [2:0]       arprot_ocvm_axim_m;       
  output              arvalid_ocvm_axim_m;      
  input               arready_ocvm_axim_m;      

  input   [11:0]      rid_ocvm_axim_m;          
  input   [63:0]      rdata_ocvm_axim_m;        
  input   [1:0]       rresp_ocvm_axim_m;        
  input               rlast_ocvm_axim_m;        
  input               rvalid_ocvm_axim_m;       
  output              rready_ocvm_axim_m;       

  output  [9:0]       awuser_ocvm_axim_m;       
  input               buser_ocvm_axim_m;        
  output  [9:0]       aruser_ocvm_axim_m;       
  input               ruser_ocvm_axim_m;        

  output  [3:0]       awqv_ocvm_axim_m;         
  output  [3:0]       arqv_ocvm_axim_m;         



  input   [11:0]      awid_ocvm_axim_s;         
  input   [31:0]      awaddr_ocvm_axim_s;       
  input   [7:0]       awlen_ocvm_axim_s;        
  input   [2:0]       awsize_ocvm_axim_s;       
  input   [1:0]       awburst_ocvm_axim_s;      
  input               awlock_ocvm_axim_s;       
  input   [3:0]       awcache_ocvm_axim_s;      
  input   [2:0]       awprot_ocvm_axim_s;       
  input               awvalid_ocvm_axim_s;      
  output              awready_ocvm_axim_s;      

  input   [63:0]      wdata_ocvm_axim_s;        
  input   [7:0]       wstrb_ocvm_axim_s;        
  input               wlast_ocvm_axim_s;        
  input               wvalid_ocvm_axim_s;       
  output              wready_ocvm_axim_s;       

  output  [11:0]      bid_ocvm_axim_s;          
  output  [1:0]       bresp_ocvm_axim_s;        
  output              bvalid_ocvm_axim_s;       
  input               bready_ocvm_axim_s;       

  input   [11:0]      arid_ocvm_axim_s;         
  input   [31:0]      araddr_ocvm_axim_s;       
  input   [7:0]       arlen_ocvm_axim_s;        
  input   [2:0]       arsize_ocvm_axim_s;       
  input   [1:0]       arburst_ocvm_axim_s;      
  input               arlock_ocvm_axim_s;       
  input   [3:0]       arcache_ocvm_axim_s;      
  input   [2:0]       arprot_ocvm_axim_s;       
  input               arvalid_ocvm_axim_s;      
  output              arready_ocvm_axim_s;      

  output  [11:0]      rid_ocvm_axim_s;          
  output  [63:0]      rdata_ocvm_axim_s;        
  output  [1:0]       rresp_ocvm_axim_s;        
  output              rlast_ocvm_axim_s;        
  output              rvalid_ocvm_axim_s;       
  input               rready_ocvm_axim_s;       

  input   [9:0]       awuser_ocvm_axim_s;       
  output              buser_ocvm_axim_s;        
  input   [9:0]       aruser_ocvm_axim_s;       
  output              ruser_ocvm_axim_s;        

  input   [3:0]       awqv_ocvm_axim_s;         
  input   [3:0]       arqv_ocvm_axim_s;         

  input               aclk;                     
  input               aresetn;                  






  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [79:0]    r_master_port_src_data;     
  wire [79:0]    r_master_port_dst_data;     



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

  wire [14:0]    b_master_port_src_data;     
  wire [14:0]    b_master_port_dst_data;     



  wire           aw_master_port_dst_valid;
  wire           aw_master_port_dst_ready;
  wire           aw_master_port_src_valid;
  wire           aw_master_port_src_ready;

  wire [78:0]    aw_master_port_src_data;     
  wire [78:0]    aw_master_port_dst_data;     



  wire           ar_master_port_dst_valid;
  wire           ar_master_port_dst_ready;
  wire           ar_master_port_src_valid;
  wire           ar_master_port_src_ready;

  wire [78:0]    ar_master_port_src_data;     
  wire [78:0]    ar_master_port_dst_data;     




  wire [11:0]   awid;
  wire [11:0]   bid;
  wire [11:0]   arid;
  wire [11:0]   rid;




  wire [63:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_ocvm_axim_s[63:56]  & {8{wstrb_ocvm_axim_s[7]}}),
  (wdata_ocvm_axim_s[55:48]  & {8{wstrb_ocvm_axim_s[6]}}),
  (wdata_ocvm_axim_s[47:40]  & {8{wstrb_ocvm_axim_s[5]}}),
  (wdata_ocvm_axim_s[39:32]  & {8{wstrb_ocvm_axim_s[4]}}),
  (wdata_ocvm_axim_s[31:24]  & {8{wstrb_ocvm_axim_s[3]}}),
  (wdata_ocvm_axim_s[23:16]  & {8{wstrb_ocvm_axim_s[2]}}),
  (wdata_ocvm_axim_s[15:8]  & {8{wstrb_ocvm_axim_s[1]}}),
  (wdata_ocvm_axim_s[7:0]  & {8{wstrb_ocvm_axim_s[0]}})};
  

  
  assign awid = {awid_ocvm_axim_s[10],
  awid_ocvm_axim_s[9],
  awid_ocvm_axim_s[8],
  awid_ocvm_axim_s[7],
  awid_ocvm_axim_s[6],
  awid_ocvm_axim_s[5],
  awid_ocvm_axim_s[4],
  awid_ocvm_axim_s[3],
  awid_ocvm_axim_s[11],
  awid_ocvm_axim_s[2],
  awid_ocvm_axim_s[1],
  awid_ocvm_axim_s[0]};

  assign arid = {arid_ocvm_axim_s[10],
  arid_ocvm_axim_s[9],
  arid_ocvm_axim_s[8],
  arid_ocvm_axim_s[7],
  arid_ocvm_axim_s[6],
  arid_ocvm_axim_s[5],
  arid_ocvm_axim_s[4],
  arid_ocvm_axim_s[3],
  arid_ocvm_axim_s[11],
  arid_ocvm_axim_s[2],
  arid_ocvm_axim_s[1],
  arid_ocvm_axim_s[0]};


  assign rid_ocvm_axim_s = {rid[3],
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

  assign bid_ocvm_axim_s = {bid[3],
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
        wstrb_ocvm_axim_s,
        wlast_ocvm_axim_s};

  assign {wdata_ocvm_axim_m,
        wstrb_ocvm_axim_m,
        wlast_ocvm_axim_m} = w_master_port_dst_data;

  assign wvalid_ocvm_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_ocvm_axim_m;

  assign w_master_port_src_valid = wvalid_ocvm_axim_s;
  assign wready_ocvm_axim_s = w_master_port_src_ready;




  assign aw_master_port_src_data = {awid,
        awaddr_ocvm_axim_s,
        awlen_ocvm_axim_s,
        awsize_ocvm_axim_s,
        awburst_ocvm_axim_s,
        awlock_ocvm_axim_s,
        awcache_ocvm_axim_s,
        awuser_ocvm_axim_s,
        awqv_ocvm_axim_s,
        awprot_ocvm_axim_s};

  assign {awid_ocvm_axim_m,
        awaddr_ocvm_axim_m,
        awlen_ocvm_axim_m,
        awsize_ocvm_axim_m,
        awburst_ocvm_axim_m,
        awlock_ocvm_axim_m,
        awcache_ocvm_axim_m,
        awuser_ocvm_axim_m,
        awqv_ocvm_axim_m,
        awprot_ocvm_axim_m} = aw_master_port_dst_data;

  assign awvalid_ocvm_axim_m = aw_master_port_dst_valid;
  assign aw_master_port_dst_ready = awready_ocvm_axim_m;

  assign aw_master_port_src_valid = awvalid_ocvm_axim_s;
  assign awready_ocvm_axim_s = aw_master_port_src_ready;




  assign ar_master_port_src_data = {arid,
        araddr_ocvm_axim_s,
        arlen_ocvm_axim_s,
        arsize_ocvm_axim_s,
        arburst_ocvm_axim_s,
        arlock_ocvm_axim_s,
        arcache_ocvm_axim_s,
        aruser_ocvm_axim_s,
        arqv_ocvm_axim_s,
        arprot_ocvm_axim_s};

  assign {arid_ocvm_axim_m,
        araddr_ocvm_axim_m,
        arlen_ocvm_axim_m,
        arsize_ocvm_axim_m,
        arburst_ocvm_axim_m,
        arlock_ocvm_axim_m,
        arcache_ocvm_axim_m,
        aruser_ocvm_axim_m,
        arqv_ocvm_axim_m,
        arprot_ocvm_axim_m} = ar_master_port_dst_data;

  assign arvalid_ocvm_axim_m = ar_master_port_dst_valid;
  assign ar_master_port_dst_ready = arready_ocvm_axim_m;

  assign ar_master_port_src_valid = arvalid_ocvm_axim_s;
  assign arready_ocvm_axim_s = ar_master_port_src_ready;



  assign r_master_port_src_data = {rid_ocvm_axim_m,
        rdata_ocvm_axim_m,
        rresp_ocvm_axim_m,
        ruser_ocvm_axim_m,
        rlast_ocvm_axim_m};

  assign {rid,
        rdata_ocvm_axim_s,
        rresp_ocvm_axim_s,
        ruser_ocvm_axim_s,
        rlast_ocvm_axim_s} = r_master_port_dst_data;

  assign rvalid_ocvm_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_ocvm_axim_s;

  assign r_master_port_src_valid = rvalid_ocvm_axim_m;
  assign rready_ocvm_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_ocvm_axim_m,
        bresp_ocvm_axim_m,
        buser_ocvm_axim_m};

  assign {bid,
        bresp_ocvm_axim_s,
        buser_ocvm_axim_s} = b_master_port_dst_data;

  assign bvalid_ocvm_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_ocvm_axim_s;

  assign b_master_port_src_valid = bvalid_ocvm_axim_m;
  assign bready_ocvm_axim_m = b_master_port_src_ready;






  nic400_amib_ocvm_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       80  
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




  nic400_amib_ocvm_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
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




  nic400_amib_ocvm_axim_chan_slice_sse710_main
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




  nic400_amib_ocvm_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       79  
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




  nic400_amib_ocvm_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       79  
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


  assign wif_hndshk = wvalid_ocvm_axim_m & wready_ocvm_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_ocvm_axim_m[63:56]  & ~wstrb_ocvm_axim_m[7]) | 
  (|wdata_ocvm_axim_m[55:48]  & ~wstrb_ocvm_axim_m[6]) | 
  (|wdata_ocvm_axim_m[47:40]  & ~wstrb_ocvm_axim_m[5]) | 
  (|wdata_ocvm_axim_m[39:32]  & ~wstrb_ocvm_axim_m[4]) | 
  (|wdata_ocvm_axim_m[31:24]  & ~wstrb_ocvm_axim_m[3]) | 
  (|wdata_ocvm_axim_m[23:16]  & ~wstrb_ocvm_axim_m[2]) | 
  (|wdata_ocvm_axim_m[15:8]  & ~wstrb_ocvm_axim_m[1]) | 
  (|wdata_ocvm_axim_m[7:0]  & ~wstrb_ocvm_axim_m[0]));



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

`include "nic400_amib_ocvm_axim_undefs_sse710_main.v"

