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



`include "nic400_amib_stm_axim_defs_sse710_sys_apb.v"

module nic400_amib_stm_axim_sse710_sys_apb
  (
  

    awid_stm_axim_m,
    awaddr_stm_axim_m,
    awlen_stm_axim_m,
    awsize_stm_axim_m,
    awburst_stm_axim_m,
    awlock_stm_axim_m,
    awcache_stm_axim_m,
    awprot_stm_axim_m,
    awvalid_stm_axim_m,
    awready_stm_axim_m,

    wdata_stm_axim_m,
    wstrb_stm_axim_m,
    wlast_stm_axim_m,
    wvalid_stm_axim_m,
    wready_stm_axim_m,

    bid_stm_axim_m,
    bresp_stm_axim_m,
    bvalid_stm_axim_m,
    bready_stm_axim_m,

    arid_stm_axim_m,
    araddr_stm_axim_m,
    arlen_stm_axim_m,
    arsize_stm_axim_m,
    arburst_stm_axim_m,
    arlock_stm_axim_m,
    arcache_stm_axim_m,
    arprot_stm_axim_m,
    arvalid_stm_axim_m,
    arready_stm_axim_m,

    rid_stm_axim_m,
    rdata_stm_axim_m,
    rresp_stm_axim_m,
    rlast_stm_axim_m,
    rvalid_stm_axim_m,
    rready_stm_axim_m,

    awuser_stm_axim_m,
    aruser_stm_axim_m,


    awid_stm_axim_s,
    awaddr_stm_axim_s,
    awlen_stm_axim_s,
    awsize_stm_axim_s,
    awburst_stm_axim_s,
    awlock_stm_axim_s,
    awcache_stm_axim_s,
    awprot_stm_axim_s,
    awvalid_stm_axim_s,
    awready_stm_axim_s,

    wdata_stm_axim_s,
    wstrb_stm_axim_s,
    wlast_stm_axim_s,
    wvalid_stm_axim_s,
    wready_stm_axim_s,

    bid_stm_axim_s,
    bresp_stm_axim_s,
    bvalid_stm_axim_s,
    bready_stm_axim_s,

    arid_stm_axim_s,
    araddr_stm_axim_s,
    arlen_stm_axim_s,
    arsize_stm_axim_s,
    arburst_stm_axim_s,
    arlock_stm_axim_s,
    arcache_stm_axim_s,
    arprot_stm_axim_s,
    arvalid_stm_axim_s,
    arready_stm_axim_s,

    rid_stm_axim_s,
    rdata_stm_axim_s,
    rresp_stm_axim_s,
    rlast_stm_axim_s,
    rvalid_stm_axim_s,
    rready_stm_axim_s,

    awuser_stm_axim_s,
    aruser_stm_axim_s,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_stm_axim_m;         
  output  [31:0]      awaddr_stm_axim_m;       
  output  [7:0]       awlen_stm_axim_m;        
  output  [2:0]       awsize_stm_axim_m;       
  output  [1:0]       awburst_stm_axim_m;      
  output              awlock_stm_axim_m;       
  output  [3:0]       awcache_stm_axim_m;      
  output  [2:0]       awprot_stm_axim_m;       
  output              awvalid_stm_axim_m;      
  input               awready_stm_axim_m;      

  output  [63:0]      wdata_stm_axim_m;        
  output  [7:0]       wstrb_stm_axim_m;        
  output              wlast_stm_axim_m;        
  output              wvalid_stm_axim_m;       
  input               wready_stm_axim_m;       

  input   [11:0]      bid_stm_axim_m;          
  input   [1:0]       bresp_stm_axim_m;        
  input               bvalid_stm_axim_m;       
  output              bready_stm_axim_m;       

  output  [11:0]      arid_stm_axim_m;         
  output  [31:0]      araddr_stm_axim_m;       
  output  [7:0]       arlen_stm_axim_m;        
  output  [2:0]       arsize_stm_axim_m;       
  output  [1:0]       arburst_stm_axim_m;      
  output              arlock_stm_axim_m;       
  output  [3:0]       arcache_stm_axim_m;      
  output  [2:0]       arprot_stm_axim_m;       
  output              arvalid_stm_axim_m;      
  input               arready_stm_axim_m;      

  input   [11:0]      rid_stm_axim_m;          
  input   [63:0]      rdata_stm_axim_m;        
  input   [1:0]       rresp_stm_axim_m;        
  input               rlast_stm_axim_m;        
  input               rvalid_stm_axim_m;       
  output              rready_stm_axim_m;       

  output  [9:0]       awuser_stm_axim_m;       
  output  [9:0]       aruser_stm_axim_m;       



  input   [11:0]      awid_stm_axim_s;         
  input   [31:0]      awaddr_stm_axim_s;       
  input   [7:0]       awlen_stm_axim_s;        
  input   [2:0]       awsize_stm_axim_s;       
  input   [1:0]       awburst_stm_axim_s;      
  input               awlock_stm_axim_s;       
  input   [3:0]       awcache_stm_axim_s;      
  input   [2:0]       awprot_stm_axim_s;       
  input               awvalid_stm_axim_s;      
  output              awready_stm_axim_s;      

  input   [63:0]      wdata_stm_axim_s;        
  input   [7:0]       wstrb_stm_axim_s;        
  input               wlast_stm_axim_s;        
  input               wvalid_stm_axim_s;       
  output              wready_stm_axim_s;       

  output  [11:0]      bid_stm_axim_s;          
  output  [1:0]       bresp_stm_axim_s;        
  output              bvalid_stm_axim_s;       
  input               bready_stm_axim_s;       

  input   [11:0]      arid_stm_axim_s;         
  input   [31:0]      araddr_stm_axim_s;       
  input   [7:0]       arlen_stm_axim_s;        
  input   [2:0]       arsize_stm_axim_s;       
  input   [1:0]       arburst_stm_axim_s;      
  input               arlock_stm_axim_s;       
  input   [3:0]       arcache_stm_axim_s;      
  input   [2:0]       arprot_stm_axim_s;       
  input               arvalid_stm_axim_s;      
  output              arready_stm_axim_s;      

  output  [11:0]      rid_stm_axim_s;          
  output  [63:0]      rdata_stm_axim_s;        
  output  [1:0]       rresp_stm_axim_s;        
  output              rlast_stm_axim_s;        
  output              rvalid_stm_axim_s;       
  input               rready_stm_axim_s;       

  input   [9:0]       awuser_stm_axim_s;       
  input   [9:0]       aruser_stm_axim_s;       

  input               aclk;                    
  input               aresetn;                 






  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [78:0]    r_master_port_src_data;     
  wire [78:0]    r_master_port_dst_data;     



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




  wire [11:0]   awid;
  wire [11:0]   bid;
  wire [11:0]   arid;
  wire [11:0]   rid;




  wire [63:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_stm_axim_s[63:56]  & {8{wstrb_stm_axim_s[7]}}),
  (wdata_stm_axim_s[55:48]  & {8{wstrb_stm_axim_s[6]}}),
  (wdata_stm_axim_s[47:40]  & {8{wstrb_stm_axim_s[5]}}),
  (wdata_stm_axim_s[39:32]  & {8{wstrb_stm_axim_s[4]}}),
  (wdata_stm_axim_s[31:24]  & {8{wstrb_stm_axim_s[3]}}),
  (wdata_stm_axim_s[23:16]  & {8{wstrb_stm_axim_s[2]}}),
  (wdata_stm_axim_s[15:8]  & {8{wstrb_stm_axim_s[1]}}),
  (wdata_stm_axim_s[7:0]  & {8{wstrb_stm_axim_s[0]}})};
  

  
  assign awid = {awid_stm_axim_s[11],
  awid_stm_axim_s[10],
  awid_stm_axim_s[9],
  awid_stm_axim_s[8],
  awid_stm_axim_s[7],
  awid_stm_axim_s[6],
  awid_stm_axim_s[5],
  awid_stm_axim_s[4],
  awid_stm_axim_s[3],
  awid_stm_axim_s[2],
  awid_stm_axim_s[1],
  awid_stm_axim_s[0]};

  assign arid = {arid_stm_axim_s[11],
  arid_stm_axim_s[10],
  arid_stm_axim_s[9],
  arid_stm_axim_s[8],
  arid_stm_axim_s[7],
  arid_stm_axim_s[6],
  arid_stm_axim_s[5],
  arid_stm_axim_s[4],
  arid_stm_axim_s[3],
  arid_stm_axim_s[2],
  arid_stm_axim_s[1],
  arid_stm_axim_s[0]};


  assign rid_stm_axim_s = {rid[11],
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

  assign bid_stm_axim_s = {bid[11],
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
  assign awid_stm_axim_m     = awid;
  assign awaddr_stm_axim_m   = awaddr_stm_axim_s;
  assign awlen_stm_axim_m    = awlen_stm_axim_s;
  assign awsize_stm_axim_m   = awsize_stm_axim_s;
  assign awburst_stm_axim_m  = awburst_stm_axim_s;
  assign awlock_stm_axim_m   = awlock_stm_axim_s;
  assign awcache_stm_axim_m  = awcache_stm_axim_s;
  assign awprot_stm_axim_m   = awprot_stm_axim_s;
  assign awuser_stm_axim_m   = awuser_stm_axim_s;
  assign awvalid_stm_axim_m  = awvalid_stm_axim_s;
  assign awready_stm_axim_s  = awready_stm_axim_m;
  assign arid_stm_axim_m     = arid;
  assign araddr_stm_axim_m   = araddr_stm_axim_s;
  assign arlen_stm_axim_m    = arlen_stm_axim_s;
  assign arsize_stm_axim_m   = arsize_stm_axim_s;
  assign arburst_stm_axim_m  = arburst_stm_axim_s;
  assign arlock_stm_axim_m   = arlock_stm_axim_s;
  assign arcache_stm_axim_m  = arcache_stm_axim_s;
  assign arprot_stm_axim_m   = arprot_stm_axim_s;
  assign aruser_stm_axim_m   = aruser_stm_axim_s;
  assign arvalid_stm_axim_m  = arvalid_stm_axim_s;
  assign arready_stm_axim_s  = arready_stm_axim_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_stm_axim_s,
        wlast_stm_axim_s};

  assign {wdata_stm_axim_m,
        wstrb_stm_axim_m,
        wlast_stm_axim_m} = w_master_port_dst_data;

  assign wvalid_stm_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_stm_axim_m;

  assign w_master_port_src_valid = wvalid_stm_axim_s;
  assign wready_stm_axim_s = w_master_port_src_ready;



  assign r_master_port_src_data = {rid_stm_axim_m,
        rdata_stm_axim_m,
        rresp_stm_axim_m,
        rlast_stm_axim_m};

  assign {rid,
        rdata_stm_axim_s,
        rresp_stm_axim_s,
        rlast_stm_axim_s} = r_master_port_dst_data;

  assign rvalid_stm_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_stm_axim_s;

  assign r_master_port_src_valid = rvalid_stm_axim_m;
  assign rready_stm_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_stm_axim_m,
        bresp_stm_axim_m};

  assign {bid,
        bresp_stm_axim_s} = b_master_port_dst_data;

  assign bvalid_stm_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_stm_axim_s;

  assign b_master_port_src_valid = bvalid_stm_axim_m;
  assign bready_stm_axim_m = b_master_port_src_ready;






  nic400_amib_stm_axim_chan_slice_sse710_sys_apb
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




  nic400_amib_stm_axim_chan_slice_sse710_sys_apb
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




  nic400_amib_stm_axim_chan_slice_sse710_sys_apb
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











`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"




  wire strobeless_wdata;
  wire wif_hndshk;


  assign wif_hndshk = wvalid_stm_axim_m & wready_stm_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_stm_axim_m[63:56]  & ~wstrb_stm_axim_m[7]) | 
  (|wdata_stm_axim_m[55:48]  & ~wstrb_stm_axim_m[6]) | 
  (|wdata_stm_axim_m[47:40]  & ~wstrb_stm_axim_m[5]) | 
  (|wdata_stm_axim_m[39:32]  & ~wstrb_stm_axim_m[4]) | 
  (|wdata_stm_axim_m[31:24]  & ~wstrb_stm_axim_m[3]) | 
  (|wdata_stm_axim_m[23:16]  & ~wstrb_stm_axim_m[2]) | 
  (|wdata_stm_axim_m[15:8]  & ~wstrb_stm_axim_m[1]) | 
  (|wdata_stm_axim_m[7:0]  & ~wstrb_stm_axim_m[0]));



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

`include "nic400_amib_stm_axim_undefs_sse710_sys_apb.v"

