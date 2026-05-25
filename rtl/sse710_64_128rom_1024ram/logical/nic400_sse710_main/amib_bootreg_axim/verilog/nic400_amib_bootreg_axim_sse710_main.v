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



`include "nic400_amib_bootreg_axim_defs_sse710_main.v"

module nic400_amib_bootreg_axim_sse710_main
  (
  

    awid_bootreg_axim_s,
    awaddr_bootreg_axim_s,
    awlen_bootreg_axim_s,
    awsize_bootreg_axim_s,
    awburst_bootreg_axim_s,
    awlock_bootreg_axim_s,
    awcache_bootreg_axim_s,
    awprot_bootreg_axim_s,
    awvalid_bootreg_axim_s,
    awready_bootreg_axim_s,

    wdata_bootreg_axim_s,
    wstrb_bootreg_axim_s,
    wlast_bootreg_axim_s,
    wvalid_bootreg_axim_s,
    wready_bootreg_axim_s,

    bid_bootreg_axim_s,
    bresp_bootreg_axim_s,
    bvalid_bootreg_axim_s,
    bready_bootreg_axim_s,

    arid_bootreg_axim_s,
    araddr_bootreg_axim_s,
    arlen_bootreg_axim_s,
    arsize_bootreg_axim_s,
    arburst_bootreg_axim_s,
    arlock_bootreg_axim_s,
    arcache_bootreg_axim_s,
    arprot_bootreg_axim_s,
    arvalid_bootreg_axim_s,
    arready_bootreg_axim_s,

    rid_bootreg_axim_s,
    rdata_bootreg_axim_s,
    rresp_bootreg_axim_s,
    rlast_bootreg_axim_s,
    rvalid_bootreg_axim_s,
    rready_bootreg_axim_s,

    awuser_bootreg_axim_s,
    aruser_bootreg_axim_s,


    awid_bootreg_axim_m,
    awaddr_bootreg_axim_m,
    awlen_bootreg_axim_m,
    awsize_bootreg_axim_m,
    awburst_bootreg_axim_m,
    awlock_bootreg_axim_m,
    awcache_bootreg_axim_m,
    awprot_bootreg_axim_m,
    awvalid_bootreg_axim_m,
    awready_bootreg_axim_m,

    wdata_bootreg_axim_m,
    wstrb_bootreg_axim_m,
    wlast_bootreg_axim_m,
    wvalid_bootreg_axim_m,
    wready_bootreg_axim_m,

    bid_bootreg_axim_m,
    bresp_bootreg_axim_m,
    bvalid_bootreg_axim_m,
    bready_bootreg_axim_m,

    arid_bootreg_axim_m,
    araddr_bootreg_axim_m,
    arlen_bootreg_axim_m,
    arsize_bootreg_axim_m,
    arburst_bootreg_axim_m,
    arlock_bootreg_axim_m,
    arcache_bootreg_axim_m,
    arprot_bootreg_axim_m,
    arvalid_bootreg_axim_m,
    arready_bootreg_axim_m,

    rid_bootreg_axim_m,
    rdata_bootreg_axim_m,
    rresp_bootreg_axim_m,
    rlast_bootreg_axim_m,
    rvalid_bootreg_axim_m,
    rready_bootreg_axim_m,

    awuser_bootreg_axim_m,
    aruser_bootreg_axim_m,

    aclk,
    aresetn

  );




  


  input   [11:0]      awid_bootreg_axim_s;         
  input   [39:0]      awaddr_bootreg_axim_s;       
  input   [7:0]       awlen_bootreg_axim_s;        
  input   [2:0]       awsize_bootreg_axim_s;       
  input   [1:0]       awburst_bootreg_axim_s;      
  input               awlock_bootreg_axim_s;       
  input   [3:0]       awcache_bootreg_axim_s;      
  input   [2:0]       awprot_bootreg_axim_s;       
  input               awvalid_bootreg_axim_s;      
  output              awready_bootreg_axim_s;      

  input   [31:0]      wdata_bootreg_axim_s;        
  input   [3:0]       wstrb_bootreg_axim_s;        
  input               wlast_bootreg_axim_s;        
  input               wvalid_bootreg_axim_s;       
  output              wready_bootreg_axim_s;       

  output  [11:0]      bid_bootreg_axim_s;          
  output  [1:0]       bresp_bootreg_axim_s;        
  output              bvalid_bootreg_axim_s;       
  input               bready_bootreg_axim_s;       

  input   [11:0]      arid_bootreg_axim_s;         
  input   [39:0]      araddr_bootreg_axim_s;       
  input   [7:0]       arlen_bootreg_axim_s;        
  input   [2:0]       arsize_bootreg_axim_s;       
  input   [1:0]       arburst_bootreg_axim_s;      
  input               arlock_bootreg_axim_s;       
  input   [3:0]       arcache_bootreg_axim_s;      
  input   [2:0]       arprot_bootreg_axim_s;       
  input               arvalid_bootreg_axim_s;      
  output              arready_bootreg_axim_s;      

  output  [11:0]      rid_bootreg_axim_s;          
  output  [31:0]      rdata_bootreg_axim_s;        
  output  [1:0]       rresp_bootreg_axim_s;        
  output              rlast_bootreg_axim_s;        
  output              rvalid_bootreg_axim_s;       
  input               rready_bootreg_axim_s;       

  input   [9:0]       awuser_bootreg_axim_s;       
  input   [9:0]       aruser_bootreg_axim_s;       



  output  [9:0]       awid_bootreg_axim_m;         
  output  [39:0]      awaddr_bootreg_axim_m;       
  output  [7:0]       awlen_bootreg_axim_m;        
  output  [2:0]       awsize_bootreg_axim_m;       
  output  [1:0]       awburst_bootreg_axim_m;      
  output              awlock_bootreg_axim_m;       
  output  [3:0]       awcache_bootreg_axim_m;      
  output  [2:0]       awprot_bootreg_axim_m;       
  output              awvalid_bootreg_axim_m;      
  input               awready_bootreg_axim_m;      

  output  [31:0]      wdata_bootreg_axim_m;        
  output  [3:0]       wstrb_bootreg_axim_m;        
  output              wlast_bootreg_axim_m;        
  output              wvalid_bootreg_axim_m;       
  input               wready_bootreg_axim_m;       

  input   [9:0]       bid_bootreg_axim_m;          
  input   [1:0]       bresp_bootreg_axim_m;        
  input               bvalid_bootreg_axim_m;       
  output              bready_bootreg_axim_m;       

  output  [9:0]       arid_bootreg_axim_m;         
  output  [39:0]      araddr_bootreg_axim_m;       
  output  [7:0]       arlen_bootreg_axim_m;        
  output  [2:0]       arsize_bootreg_axim_m;       
  output  [1:0]       arburst_bootreg_axim_m;      
  output              arlock_bootreg_axim_m;       
  output  [3:0]       arcache_bootreg_axim_m;      
  output  [2:0]       arprot_bootreg_axim_m;       
  output              arvalid_bootreg_axim_m;      
  input               arready_bootreg_axim_m;      

  input   [9:0]       rid_bootreg_axim_m;          
  input   [31:0]      rdata_bootreg_axim_m;        
  input   [1:0]       rresp_bootreg_axim_m;        
  input               rlast_bootreg_axim_m;        
  input               rvalid_bootreg_axim_m;       
  output              rready_bootreg_axim_m;       

  output  [9:0]       awuser_bootreg_axim_m;       
  output  [9:0]       aruser_bootreg_axim_m;       

  input               aclk;                        
  input               aresetn;                     






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [36:0]    w_master_port_src_data;     
  wire [36:0]    w_master_port_dst_data;     



  wire           aw_master_port_dst_valid;
  wire           aw_master_port_dst_ready;
  wire           aw_master_port_src_valid;
  wire           aw_master_port_src_ready;

  wire [80:0]    aw_master_port_src_data;     
  wire [80:0]    aw_master_port_dst_data;     



  wire           ar_master_port_dst_valid;
  wire           ar_master_port_dst_ready;
  wire           ar_master_port_src_valid;
  wire           ar_master_port_src_ready;

  wire [80:0]    ar_master_port_src_data;     
  wire [80:0]    ar_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [44:0]    r_master_port_src_data;     
  wire [44:0]    r_master_port_dst_data;     



  wire           b_master_port_dst_valid;
  wire           b_master_port_dst_ready;
  wire           b_master_port_src_valid;
  wire           b_master_port_src_ready;

  wire [11:0]    b_master_port_src_data;     
  wire [11:0]    b_master_port_dst_data;     




  wire [9:0]    awid;
  wire [9:0]    bid;
  wire [9:0]    arid;
  wire [9:0]    rid;




  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_bootreg_axim_s[31:24]  & {8{wstrb_bootreg_axim_s[3]}}),
  (wdata_bootreg_axim_s[23:16]  & {8{wstrb_bootreg_axim_s[2]}}),
  (wdata_bootreg_axim_s[15:8]  & {8{wstrb_bootreg_axim_s[1]}}),
  (wdata_bootreg_axim_s[7:0]  & {8{wstrb_bootreg_axim_s[0]}})};
  

  
  assign awid = {awid_bootreg_axim_s[10],
  awid_bootreg_axim_s[9],
  awid_bootreg_axim_s[8],
  awid_bootreg_axim_s[7],
  awid_bootreg_axim_s[6],
  awid_bootreg_axim_s[5],
  awid_bootreg_axim_s[4],
  awid_bootreg_axim_s[3],
  awid_bootreg_axim_s[1],
  awid_bootreg_axim_s[0]};

  assign arid = {arid_bootreg_axim_s[10],
  arid_bootreg_axim_s[9],
  arid_bootreg_axim_s[8],
  arid_bootreg_axim_s[7],
  arid_bootreg_axim_s[6],
  arid_bootreg_axim_s[5],
  arid_bootreg_axim_s[4],
  arid_bootreg_axim_s[3],
  arid_bootreg_axim_s[1],
  arid_bootreg_axim_s[0]};


  assign rid_bootreg_axim_s = {rid_bootreg_axim_s[0],
    rid[9],
    rid[8],
    rid[7],
    rid[6],
    rid[5],
    rid[4],
    rid[3],
    rid[2],
    rid_bootreg_axim_s[1],
    rid[1],
    rid[0]};

  assign bid_bootreg_axim_s = {bid_bootreg_axim_s[0],
    bid[9],
    bid[8],
    bid[7],
    bid[6],
    bid[5],
    bid[4],
    bid[3],
    bid[2],
    bid_bootreg_axim_s[1],
    bid[1],
    bid[0]};


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_bootreg_axim_s,
        wlast_bootreg_axim_s};

  assign {wdata_bootreg_axim_m,
        wstrb_bootreg_axim_m,
        wlast_bootreg_axim_m} = w_master_port_dst_data;

  assign wvalid_bootreg_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_bootreg_axim_m;

  assign w_master_port_src_valid = wvalid_bootreg_axim_s;
  assign wready_bootreg_axim_s = w_master_port_src_ready;




  assign aw_master_port_src_data = {awid,
        awaddr_bootreg_axim_s,
        awlen_bootreg_axim_s,
        awsize_bootreg_axim_s,
        awburst_bootreg_axim_s,
        awlock_bootreg_axim_s,
        awcache_bootreg_axim_s,
        awuser_bootreg_axim_s,
        awprot_bootreg_axim_s};

  assign {awid_bootreg_axim_m,
        awaddr_bootreg_axim_m,
        awlen_bootreg_axim_m,
        awsize_bootreg_axim_m,
        awburst_bootreg_axim_m,
        awlock_bootreg_axim_m,
        awcache_bootreg_axim_m,
        awuser_bootreg_axim_m,
        awprot_bootreg_axim_m} = aw_master_port_dst_data;

  assign awvalid_bootreg_axim_m = aw_master_port_dst_valid;
  assign aw_master_port_dst_ready = awready_bootreg_axim_m;

  assign aw_master_port_src_valid = awvalid_bootreg_axim_s;
  assign awready_bootreg_axim_s = aw_master_port_src_ready;




  assign ar_master_port_src_data = {arid,
        araddr_bootreg_axim_s,
        arlen_bootreg_axim_s,
        arsize_bootreg_axim_s,
        arburst_bootreg_axim_s,
        arlock_bootreg_axim_s,
        arcache_bootreg_axim_s,
        aruser_bootreg_axim_s,
        arprot_bootreg_axim_s};

  assign {arid_bootreg_axim_m,
        araddr_bootreg_axim_m,
        arlen_bootreg_axim_m,
        arsize_bootreg_axim_m,
        arburst_bootreg_axim_m,
        arlock_bootreg_axim_m,
        arcache_bootreg_axim_m,
        aruser_bootreg_axim_m,
        arprot_bootreg_axim_m} = ar_master_port_dst_data;

  assign arvalid_bootreg_axim_m = ar_master_port_dst_valid;
  assign ar_master_port_dst_ready = arready_bootreg_axim_m;

  assign ar_master_port_src_valid = arvalid_bootreg_axim_s;
  assign arready_bootreg_axim_s = ar_master_port_src_ready;



  assign r_master_port_src_data = {rid_bootreg_axim_m,
        rdata_bootreg_axim_m,
        rresp_bootreg_axim_m,
        rlast_bootreg_axim_m};

  assign {rid,
        rdata_bootreg_axim_s,
        rresp_bootreg_axim_s,
        rlast_bootreg_axim_s} = r_master_port_dst_data;

  assign rvalid_bootreg_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_bootreg_axim_s;

  assign r_master_port_src_valid = rvalid_bootreg_axim_m;
  assign rready_bootreg_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_bootreg_axim_m,
        bresp_bootreg_axim_m};

  assign {bid,
        bresp_bootreg_axim_s} = b_master_port_dst_data;

  assign bvalid_bootreg_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_bootreg_axim_s;

  assign b_master_port_src_valid = bvalid_bootreg_axim_m;
  assign bready_bootreg_axim_m = b_master_port_src_ready;






  nic400_amib_bootreg_axim_chan_slice_sse710_main
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




  nic400_amib_bootreg_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       81  
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




  nic400_amib_bootreg_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       81  
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




  nic400_amib_bootreg_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       45  
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




  nic400_amib_bootreg_axim_chan_slice_sse710_main
    #(
       `RS_REGD,  
       12  
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









`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"




  wire strobeless_wdata;
  wire wif_hndshk;


  assign wif_hndshk = wvalid_bootreg_axim_m & wready_bootreg_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_bootreg_axim_m[31:24]  & ~wstrb_bootreg_axim_m[3]) | 
  (|wdata_bootreg_axim_m[23:16]  & ~wstrb_bootreg_axim_m[2]) | 
  (|wdata_bootreg_axim_m[15:8]  & ~wstrb_bootreg_axim_m[1]) | 
  (|wdata_bootreg_axim_m[7:0]  & ~wstrb_bootreg_axim_m[0]));



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

`include "nic400_amib_bootreg_axim_undefs_sse710_main.v"

