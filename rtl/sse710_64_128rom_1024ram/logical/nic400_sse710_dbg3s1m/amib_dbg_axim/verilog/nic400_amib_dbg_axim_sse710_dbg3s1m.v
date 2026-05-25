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



`include "nic400_amib_dbg_axim_defs_sse710_dbg3s1m.v"

module nic400_amib_dbg_axim_sse710_dbg3s1m
  (
  

    awid_dbg_axim_m,
    awaddr_dbg_axim_m,
    awlen_dbg_axim_m,
    awsize_dbg_axim_m,
    awburst_dbg_axim_m,
    awlock_dbg_axim_m,
    awcache_dbg_axim_m,
    awprot_dbg_axim_m,
    awvalid_dbg_axim_m,
    awready_dbg_axim_m,

    wdata_dbg_axim_m,
    wstrb_dbg_axim_m,
    wlast_dbg_axim_m,
    wvalid_dbg_axim_m,
    wready_dbg_axim_m,

    bid_dbg_axim_m,
    bresp_dbg_axim_m,
    bvalid_dbg_axim_m,
    bready_dbg_axim_m,

    arid_dbg_axim_m,
    araddr_dbg_axim_m,
    arlen_dbg_axim_m,
    arsize_dbg_axim_m,
    arburst_dbg_axim_m,
    arlock_dbg_axim_m,
    arcache_dbg_axim_m,
    arprot_dbg_axim_m,
    arvalid_dbg_axim_m,
    arready_dbg_axim_m,

    rid_dbg_axim_m,
    rdata_dbg_axim_m,
    rresp_dbg_axim_m,
    rlast_dbg_axim_m,
    rvalid_dbg_axim_m,
    rready_dbg_axim_m,

    awuser_dbg_axim_m,
    aruser_dbg_axim_m,


    awid_expmstr1_axim_s,
    awaddr_expmstr1_axim_s,
    awlen_expmstr1_axim_s,
    awsize_expmstr1_axim_s,
    awburst_expmstr1_axim_s,
    awlock_expmstr1_axim_s,
    awcache_expmstr1_axim_s,
    awprot_expmstr1_axim_s,
    awvalid_expmstr1_axim_s,
    awready_expmstr1_axim_s,

    wdata_expmstr1_axim_s,
    wstrb_expmstr1_axim_s,
    wlast_expmstr1_axim_s,
    wvalid_expmstr1_axim_s,
    wready_expmstr1_axim_s,

    bid_expmstr1_axim_s,
    bresp_expmstr1_axim_s,
    bvalid_expmstr1_axim_s,
    bready_expmstr1_axim_s,

    arid_expmstr1_axim_s,
    araddr_expmstr1_axim_s,
    arlen_expmstr1_axim_s,
    arsize_expmstr1_axim_s,
    arburst_expmstr1_axim_s,
    arlock_expmstr1_axim_s,
    arcache_expmstr1_axim_s,
    arprot_expmstr1_axim_s,
    arvalid_expmstr1_axim_s,
    arready_expmstr1_axim_s,

    rid_expmstr1_axim_s,
    rdata_expmstr1_axim_s,
    rresp_expmstr1_axim_s,
    rlast_expmstr1_axim_s,
    rvalid_expmstr1_axim_s,
    rready_expmstr1_axim_s,

    awuser_expmstr1_axim_s,
    aruser_expmstr1_axim_s,

    aclk,
    aresetn

  );




  


  output  [3:0]       awid_dbg_axim_m;              
  output  [31:0]      awaddr_dbg_axim_m;            
  output  [7:0]       awlen_dbg_axim_m;             
  output  [2:0]       awsize_dbg_axim_m;            
  output  [1:0]       awburst_dbg_axim_m;           
  output              awlock_dbg_axim_m;            
  output  [3:0]       awcache_dbg_axim_m;           
  output  [2:0]       awprot_dbg_axim_m;            
  output              awvalid_dbg_axim_m;           
  input               awready_dbg_axim_m;           

  output  [63:0]      wdata_dbg_axim_m;             
  output  [7:0]       wstrb_dbg_axim_m;             
  output              wlast_dbg_axim_m;             
  output              wvalid_dbg_axim_m;            
  input               wready_dbg_axim_m;            

  input   [3:0]       bid_dbg_axim_m;               
  input   [1:0]       bresp_dbg_axim_m;             
  input               bvalid_dbg_axim_m;            
  output              bready_dbg_axim_m;            

  output  [3:0]       arid_dbg_axim_m;              
  output  [31:0]      araddr_dbg_axim_m;            
  output  [7:0]       arlen_dbg_axim_m;             
  output  [2:0]       arsize_dbg_axim_m;            
  output  [1:0]       arburst_dbg_axim_m;           
  output              arlock_dbg_axim_m;            
  output  [3:0]       arcache_dbg_axim_m;           
  output  [2:0]       arprot_dbg_axim_m;            
  output              arvalid_dbg_axim_m;           
  input               arready_dbg_axim_m;           

  input   [3:0]       rid_dbg_axim_m;               
  input   [63:0]      rdata_dbg_axim_m;             
  input   [1:0]       rresp_dbg_axim_m;             
  input               rlast_dbg_axim_m;             
  input               rvalid_dbg_axim_m;            
  output              rready_dbg_axim_m;            

  output  [2:0]       awuser_dbg_axim_m;            
  output  [2:0]       aruser_dbg_axim_m;            



  input   [3:0]       awid_expmstr1_axim_s;         
  input   [31:0]      awaddr_expmstr1_axim_s;       
  input   [7:0]       awlen_expmstr1_axim_s;        
  input   [2:0]       awsize_expmstr1_axim_s;       
  input   [1:0]       awburst_expmstr1_axim_s;      
  input               awlock_expmstr1_axim_s;       
  input   [3:0]       awcache_expmstr1_axim_s;      
  input   [2:0]       awprot_expmstr1_axim_s;       
  input               awvalid_expmstr1_axim_s;      
  output              awready_expmstr1_axim_s;      

  input   [63:0]      wdata_expmstr1_axim_s;        
  input   [7:0]       wstrb_expmstr1_axim_s;        
  input               wlast_expmstr1_axim_s;        
  input               wvalid_expmstr1_axim_s;       
  output              wready_expmstr1_axim_s;       

  output  [3:0]       bid_expmstr1_axim_s;          
  output  [1:0]       bresp_expmstr1_axim_s;        
  output              bvalid_expmstr1_axim_s;       
  input               bready_expmstr1_axim_s;       

  input   [3:0]       arid_expmstr1_axim_s;         
  input   [31:0]      araddr_expmstr1_axim_s;       
  input   [7:0]       arlen_expmstr1_axim_s;        
  input   [2:0]       arsize_expmstr1_axim_s;       
  input   [1:0]       arburst_expmstr1_axim_s;      
  input               arlock_expmstr1_axim_s;       
  input   [3:0]       arcache_expmstr1_axim_s;      
  input   [2:0]       arprot_expmstr1_axim_s;       
  input               arvalid_expmstr1_axim_s;      
  output              arready_expmstr1_axim_s;      

  output  [3:0]       rid_expmstr1_axim_s;          
  output  [63:0]      rdata_expmstr1_axim_s;        
  output  [1:0]       rresp_expmstr1_axim_s;        
  output              rlast_expmstr1_axim_s;        
  output              rvalid_expmstr1_axim_s;       
  input               rready_expmstr1_axim_s;       

  input   [2:0]       awuser_expmstr1_axim_s;       
  input   [2:0]       aruser_expmstr1_axim_s;       

  input               aclk;                         
  input               aresetn;                      






  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [70:0]    r_master_port_src_data;     
  wire [70:0]    r_master_port_dst_data;     



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

  wire [5:0]     b_master_port_src_data;     
  wire [5:0]     b_master_port_dst_data;     



  wire           aw_master_port_dst_valid;
  wire           aw_master_port_dst_ready;
  wire           aw_master_port_src_valid;
  wire           aw_master_port_src_ready;

  wire [59:0]    aw_master_port_src_data;     
  wire [59:0]    aw_master_port_dst_data;     



  wire           ar_master_port_dst_valid;
  wire           ar_master_port_dst_ready;
  wire           ar_master_port_src_valid;
  wire           ar_master_port_src_ready;

  wire [59:0]    ar_master_port_src_data;     
  wire [59:0]    ar_master_port_dst_data;     




  wire [3:0]    awid;
  wire [3:0]    bid;
  wire [3:0]    arid;
  wire [3:0]    rid;




  wire [63:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_expmstr1_axim_s[63:56]  & {8{wstrb_expmstr1_axim_s[7]}}),
  (wdata_expmstr1_axim_s[55:48]  & {8{wstrb_expmstr1_axim_s[6]}}),
  (wdata_expmstr1_axim_s[47:40]  & {8{wstrb_expmstr1_axim_s[5]}}),
  (wdata_expmstr1_axim_s[39:32]  & {8{wstrb_expmstr1_axim_s[4]}}),
  (wdata_expmstr1_axim_s[31:24]  & {8{wstrb_expmstr1_axim_s[3]}}),
  (wdata_expmstr1_axim_s[23:16]  & {8{wstrb_expmstr1_axim_s[2]}}),
  (wdata_expmstr1_axim_s[15:8]  & {8{wstrb_expmstr1_axim_s[1]}}),
  (wdata_expmstr1_axim_s[7:0]  & {8{wstrb_expmstr1_axim_s[0]}})};
  

  
  assign awid = {awid_expmstr1_axim_s[3],
  awid_expmstr1_axim_s[2],
  awid_expmstr1_axim_s[1],
  awid_expmstr1_axim_s[0]};

  assign arid = {arid_expmstr1_axim_s[3],
  arid_expmstr1_axim_s[2],
  arid_expmstr1_axim_s[1],
  arid_expmstr1_axim_s[0]};


  assign rid_expmstr1_axim_s = {rid[3],
    rid[2],
    rid[1],
    rid[0]};

  assign bid_expmstr1_axim_s = {bid[3],
    bid[2],
    bid[1],
    bid[0]};


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_expmstr1_axim_s,
        wlast_expmstr1_axim_s};

  assign {wdata_dbg_axim_m,
        wstrb_dbg_axim_m,
        wlast_dbg_axim_m} = w_master_port_dst_data;

  assign wvalid_dbg_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_dbg_axim_m;

  assign w_master_port_src_valid = wvalid_expmstr1_axim_s;
  assign wready_expmstr1_axim_s = w_master_port_src_ready;




  assign aw_master_port_src_data = {awid,
        awaddr_expmstr1_axim_s,
        awlen_expmstr1_axim_s,
        awsize_expmstr1_axim_s,
        awburst_expmstr1_axim_s,
        awlock_expmstr1_axim_s,
        awcache_expmstr1_axim_s,
        awuser_expmstr1_axim_s,
        awprot_expmstr1_axim_s};

  assign {awid_dbg_axim_m,
        awaddr_dbg_axim_m,
        awlen_dbg_axim_m,
        awsize_dbg_axim_m,
        awburst_dbg_axim_m,
        awlock_dbg_axim_m,
        awcache_dbg_axim_m,
        awuser_dbg_axim_m,
        awprot_dbg_axim_m} = aw_master_port_dst_data;

  assign awvalid_dbg_axim_m = aw_master_port_dst_valid;
  assign aw_master_port_dst_ready = awready_dbg_axim_m;

  assign aw_master_port_src_valid = awvalid_expmstr1_axim_s;
  assign awready_expmstr1_axim_s = aw_master_port_src_ready;




  assign ar_master_port_src_data = {arid,
        araddr_expmstr1_axim_s,
        arlen_expmstr1_axim_s,
        arsize_expmstr1_axim_s,
        arburst_expmstr1_axim_s,
        arlock_expmstr1_axim_s,
        arcache_expmstr1_axim_s,
        aruser_expmstr1_axim_s,
        arprot_expmstr1_axim_s};

  assign {arid_dbg_axim_m,
        araddr_dbg_axim_m,
        arlen_dbg_axim_m,
        arsize_dbg_axim_m,
        arburst_dbg_axim_m,
        arlock_dbg_axim_m,
        arcache_dbg_axim_m,
        aruser_dbg_axim_m,
        arprot_dbg_axim_m} = ar_master_port_dst_data;

  assign arvalid_dbg_axim_m = ar_master_port_dst_valid;
  assign ar_master_port_dst_ready = arready_dbg_axim_m;

  assign ar_master_port_src_valid = arvalid_expmstr1_axim_s;
  assign arready_expmstr1_axim_s = ar_master_port_src_ready;



  assign r_master_port_src_data = {rid_dbg_axim_m,
        rdata_dbg_axim_m,
        rresp_dbg_axim_m,
        rlast_dbg_axim_m};

  assign {rid,
        rdata_expmstr1_axim_s,
        rresp_expmstr1_axim_s,
        rlast_expmstr1_axim_s} = r_master_port_dst_data;

  assign rvalid_expmstr1_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_expmstr1_axim_s;

  assign r_master_port_src_valid = rvalid_dbg_axim_m;
  assign rready_dbg_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_dbg_axim_m,
        bresp_dbg_axim_m};

  assign {bid,
        bresp_expmstr1_axim_s} = b_master_port_dst_data;

  assign bvalid_expmstr1_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_expmstr1_axim_s;

  assign b_master_port_src_valid = bvalid_dbg_axim_m;
  assign bready_dbg_axim_m = b_master_port_src_ready;






  nic400_amib_dbg_axim_chan_slice_sse710_dbg3s1m
    #(
       `RS_REGD,  
       71  
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




  nic400_amib_dbg_axim_chan_slice_sse710_dbg3s1m
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




  nic400_amib_dbg_axim_chan_slice_sse710_dbg3s1m
    #(
       `RS_REGD,  
       6  
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




  nic400_amib_dbg_axim_chan_slice_sse710_dbg3s1m
    #(
       `RS_REGD,  
       60  
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




  nic400_amib_dbg_axim_chan_slice_sse710_dbg3s1m
    #(
       `RS_REGD,  
       60  
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


  assign wif_hndshk = wvalid_dbg_axim_m & wready_dbg_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_dbg_axim_m[63:56]  & ~wstrb_dbg_axim_m[7]) | 
  (|wdata_dbg_axim_m[55:48]  & ~wstrb_dbg_axim_m[6]) | 
  (|wdata_dbg_axim_m[47:40]  & ~wstrb_dbg_axim_m[5]) | 
  (|wdata_dbg_axim_m[39:32]  & ~wstrb_dbg_axim_m[4]) | 
  (|wdata_dbg_axim_m[31:24]  & ~wstrb_dbg_axim_m[3]) | 
  (|wdata_dbg_axim_m[23:16]  & ~wstrb_dbg_axim_m[2]) | 
  (|wdata_dbg_axim_m[15:8]  & ~wstrb_dbg_axim_m[1]) | 
  (|wdata_dbg_axim_m[7:0]  & ~wstrb_dbg_axim_m[0]));



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

`include "nic400_amib_dbg_axim_undefs_sse710_dbg3s1m.v"

