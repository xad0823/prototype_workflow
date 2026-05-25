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



`include "nic400_amib_master_if1_defs_secenc_f1.v"

module nic400_amib_master_if1_secenc_f1
  (
  

    awaddr_master_if1_m,
    awlen_master_if1_m,
    awsize_master_if1_m,
    awburst_master_if1_m,
    awlock_master_if1_m,
    awcache_master_if1_m,
    awprot_master_if1_m,
    awvalid_master_if1_m,
    awready_master_if1_m,

    wdata_master_if1_m,
    wstrb_master_if1_m,
    wlast_master_if1_m,
    wvalid_master_if1_m,
    wready_master_if1_m,

    bresp_master_if1_m,
    bvalid_master_if1_m,
    bready_master_if1_m,

    araddr_master_if1_m,
    arlen_master_if1_m,
    arsize_master_if1_m,
    arburst_master_if1_m,
    arlock_master_if1_m,
    arcache_master_if1_m,
    arprot_master_if1_m,
    arvalid_master_if1_m,
    arready_master_if1_m,

    rdata_master_if1_m,
    rresp_master_if1_m,
    rlast_master_if1_m,
    rvalid_master_if1_m,
    rready_master_if1_m,


    awid_master_if1_s,
    awaddr_master_if1_s,
    awlen_master_if1_s,
    awsize_master_if1_s,
    awburst_master_if1_s,
    awlock_master_if1_s,
    awcache_master_if1_s,
    awprot_master_if1_s,
    awvalid_master_if1_s,
    awready_master_if1_s,

    wdata_master_if1_s,
    wstrb_master_if1_s,
    wlast_master_if1_s,
    wvalid_master_if1_s,
    wready_master_if1_s,

    bid_master_if1_s,
    bresp_master_if1_s,
    bvalid_master_if1_s,
    bready_master_if1_s,

    arid_master_if1_s,
    araddr_master_if1_s,
    arlen_master_if1_s,
    arsize_master_if1_s,
    arburst_master_if1_s,
    arlock_master_if1_s,
    arcache_master_if1_s,
    arprot_master_if1_s,
    arvalid_master_if1_s,
    arready_master_if1_s,

    rid_master_if1_s,
    rdata_master_if1_s,
    rresp_master_if1_s,
    rlast_master_if1_s,
    rvalid_master_if1_s,
    rready_master_if1_s,

    aclk,
    aresetn

  );




  


  output  [31:0]      awaddr_master_if1_m;       
  output  [7:0]       awlen_master_if1_m;        
  output  [2:0]       awsize_master_if1_m;       
  output  [1:0]       awburst_master_if1_m;      
  output              awlock_master_if1_m;       
  output  [3:0]       awcache_master_if1_m;      
  output  [2:0]       awprot_master_if1_m;       
  output              awvalid_master_if1_m;      
  input               awready_master_if1_m;      

  output  [31:0]      wdata_master_if1_m;        
  output  [3:0]       wstrb_master_if1_m;        
  output              wlast_master_if1_m;        
  output              wvalid_master_if1_m;       
  input               wready_master_if1_m;       

  input   [1:0]       bresp_master_if1_m;        
  input               bvalid_master_if1_m;       
  output              bready_master_if1_m;       

  output  [31:0]      araddr_master_if1_m;       
  output  [7:0]       arlen_master_if1_m;        
  output  [2:0]       arsize_master_if1_m;       
  output  [1:0]       arburst_master_if1_m;      
  output              arlock_master_if1_m;       
  output  [3:0]       arcache_master_if1_m;      
  output  [2:0]       arprot_master_if1_m;       
  output              arvalid_master_if1_m;      
  input               arready_master_if1_m;      

  input   [31:0]      rdata_master_if1_m;        
  input   [1:0]       rresp_master_if1_m;        
  input               rlast_master_if1_m;        
  input               rvalid_master_if1_m;       
  output              rready_master_if1_m;       



  input               awid_master_if1_s;         
  input   [31:0]      awaddr_master_if1_s;       
  input   [7:0]       awlen_master_if1_s;        
  input   [2:0]       awsize_master_if1_s;       
  input   [1:0]       awburst_master_if1_s;      
  input               awlock_master_if1_s;       
  input   [3:0]       awcache_master_if1_s;      
  input   [2:0]       awprot_master_if1_s;       
  input               awvalid_master_if1_s;      
  output              awready_master_if1_s;      

  input   [31:0]      wdata_master_if1_s;        
  input   [3:0]       wstrb_master_if1_s;        
  input               wlast_master_if1_s;        
  input               wvalid_master_if1_s;       
  output              wready_master_if1_s;       

  output              bid_master_if1_s;          
  output  [1:0]       bresp_master_if1_s;        
  output              bvalid_master_if1_s;       
  input               bready_master_if1_s;       

  input               arid_master_if1_s;         
  input   [31:0]      araddr_master_if1_s;       
  input   [7:0]       arlen_master_if1_s;        
  input   [2:0]       arsize_master_if1_s;       
  input   [1:0]       arburst_master_if1_s;      
  input               arlock_master_if1_s;       
  input   [3:0]       arcache_master_if1_s;      
  input   [2:0]       arprot_master_if1_s;       
  input               arvalid_master_if1_s;      
  output              arready_master_if1_s;      

  output              rid_master_if1_s;          
  output  [31:0]      rdata_master_if1_s;        
  output  [1:0]       rresp_master_if1_s;        
  output              rlast_master_if1_s;        
  output              rvalid_master_if1_s;       
  input               rready_master_if1_s;       

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

  wire [1:0]     b_master_port_src_data;     
  wire [1:0]     b_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [34:0]    r_master_port_src_data;     
  wire [34:0]    r_master_port_dst_data;     







  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_master_if1_s[31:24]  & {8{wstrb_master_if1_s[3]}}),
  (wdata_master_if1_s[23:16]  & {8{wstrb_master_if1_s[2]}}),
  (wdata_master_if1_s[15:8]  & {8{wstrb_master_if1_s[1]}}),
  (wdata_master_if1_s[7:0]  & {8{wstrb_master_if1_s[0]}})};
  

  

  assign rid_master_if1_s = {1'b0};

  assign bid_master_if1_s = {1'b0};
      
    
  assign awaddr_master_if1_m   = awaddr_master_if1_s;
  assign awlen_master_if1_m    = awlen_master_if1_s;
  assign awsize_master_if1_m   = awsize_master_if1_s;
  assign awburst_master_if1_m  = awburst_master_if1_s;
  assign awlock_master_if1_m   = awlock_master_if1_s;
  assign awcache_master_if1_m  = awcache_master_if1_s;
  assign awprot_master_if1_m   = awprot_master_if1_s;
  assign awvalid_master_if1_m  = awvalid_master_if1_s;
  assign awready_master_if1_s  = awready_master_if1_m;
  assign araddr_master_if1_m   = araddr_master_if1_s;
  assign arlen_master_if1_m    = arlen_master_if1_s;
  assign arsize_master_if1_m   = arsize_master_if1_s;
  assign arburst_master_if1_m  = arburst_master_if1_s;
  assign arlock_master_if1_m   = arlock_master_if1_s;
  assign arcache_master_if1_m  = arcache_master_if1_s;
  assign arprot_master_if1_m   = arprot_master_if1_s;
  assign arvalid_master_if1_m  = arvalid_master_if1_s;
  assign arready_master_if1_s  = arready_master_if1_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_master_if1_s,
        wlast_master_if1_s};

  assign {wdata_master_if1_m,
        wstrb_master_if1_m,
        wlast_master_if1_m} = w_master_port_dst_data;

  assign wvalid_master_if1_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_master_if1_m;

  assign w_master_port_src_valid = wvalid_master_if1_s;
  assign wready_master_if1_s = w_master_port_src_ready;



  assign b_master_port_src_data = {bresp_master_if1_m};

  assign {bresp_master_if1_s} = b_master_port_dst_data;

  assign bvalid_master_if1_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_master_if1_s;

  assign b_master_port_src_valid = bvalid_master_if1_m;
  assign bready_master_if1_m = b_master_port_src_ready;



  assign r_master_port_src_data = {rdata_master_if1_m,
        rresp_master_if1_m,
        rlast_master_if1_m};

  assign {rdata_master_if1_s,
        rresp_master_if1_s,
        rlast_master_if1_s} = r_master_port_dst_data;

  assign rvalid_master_if1_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_master_if1_s;

  assign r_master_port_src_valid = rvalid_master_if1_m;
  assign rready_master_if1_m = r_master_port_src_ready;






  nic400_amib_master_if1_chan_slice_secenc_f1
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




  nic400_amib_master_if1_chan_slice_secenc_f1
    #(
       `RS_REV_REG,  
       2  
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




  nic400_amib_master_if1_chan_slice_secenc_f1
    #(
       `RS_REV_REG,  
       35  
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


  assign wif_hndshk = wvalid_master_if1_m & wready_master_if1_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_master_if1_m[31:24]  & ~wstrb_master_if1_m[3]) | 
  (|wdata_master_if1_m[23:16]  & ~wstrb_master_if1_m[2]) | 
  (|wdata_master_if1_m[15:8]  & ~wstrb_master_if1_m[1]) | 
  (|wdata_master_if1_m[7:0]  & ~wstrb_master_if1_m[0]));



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

`include "nic400_amib_master_if1_undefs_secenc_f1.v"

