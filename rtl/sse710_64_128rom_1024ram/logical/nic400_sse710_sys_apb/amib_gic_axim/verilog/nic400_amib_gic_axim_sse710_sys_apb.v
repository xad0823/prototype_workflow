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



`include "nic400_amib_gic_axim_defs_sse710_sys_apb.v"

module nic400_amib_gic_axim_sse710_sys_apb
  (
  

    awid_gic_axim_m,
    awaddr_gic_axim_m,
    awlen_gic_axim_m,
    awsize_gic_axim_m,
    awburst_gic_axim_m,
    awlock_gic_axim_m,
    awcache_gic_axim_m,
    awprot_gic_axim_m,
    awvalid_gic_axim_m,
    awready_gic_axim_m,

    wdata_gic_axim_m,
    wstrb_gic_axim_m,
    wlast_gic_axim_m,
    wvalid_gic_axim_m,
    wready_gic_axim_m,

    bid_gic_axim_m,
    bresp_gic_axim_m,
    bvalid_gic_axim_m,
    bready_gic_axim_m,

    arid_gic_axim_m,
    araddr_gic_axim_m,
    arlen_gic_axim_m,
    arsize_gic_axim_m,
    arburst_gic_axim_m,
    arlock_gic_axim_m,
    arcache_gic_axim_m,
    arprot_gic_axim_m,
    arvalid_gic_axim_m,
    arready_gic_axim_m,

    rid_gic_axim_m,
    rdata_gic_axim_m,
    rresp_gic_axim_m,
    rlast_gic_axim_m,
    rvalid_gic_axim_m,
    rready_gic_axim_m,

    awuser_gic_axim_m,
    aruser_gic_axim_m,

    awqv_gic_axim_m,
    arqv_gic_axim_m,


    awid_gic_axim_s,
    awaddr_gic_axim_s,
    awlen_gic_axim_s,
    awsize_gic_axim_s,
    awburst_gic_axim_s,
    awlock_gic_axim_s,
    awcache_gic_axim_s,
    awprot_gic_axim_s,
    awvalid_gic_axim_s,
    awready_gic_axim_s,

    wdata_gic_axim_s,
    wstrb_gic_axim_s,
    wlast_gic_axim_s,
    wvalid_gic_axim_s,
    wready_gic_axim_s,

    bid_gic_axim_s,
    bresp_gic_axim_s,
    bvalid_gic_axim_s,
    bready_gic_axim_s,

    arid_gic_axim_s,
    araddr_gic_axim_s,
    arlen_gic_axim_s,
    arsize_gic_axim_s,
    arburst_gic_axim_s,
    arlock_gic_axim_s,
    arcache_gic_axim_s,
    arprot_gic_axim_s,
    arvalid_gic_axim_s,
    arready_gic_axim_s,

    rid_gic_axim_s,
    rdata_gic_axim_s,
    rresp_gic_axim_s,
    rlast_gic_axim_s,
    rvalid_gic_axim_s,
    rready_gic_axim_s,

    awuser_gic_axim_s,
    aruser_gic_axim_s,

    awqv_gic_axim_s,
    arqv_gic_axim_s,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_gic_axim_m;         
  output  [31:0]      awaddr_gic_axim_m;       
  output  [7:0]       awlen_gic_axim_m;        
  output  [2:0]       awsize_gic_axim_m;       
  output  [1:0]       awburst_gic_axim_m;      
  output              awlock_gic_axim_m;       
  output  [3:0]       awcache_gic_axim_m;      
  output  [2:0]       awprot_gic_axim_m;       
  output              awvalid_gic_axim_m;      
  input               awready_gic_axim_m;      

  output  [31:0]      wdata_gic_axim_m;        
  output  [3:0]       wstrb_gic_axim_m;        
  output              wlast_gic_axim_m;        
  output              wvalid_gic_axim_m;       
  input               wready_gic_axim_m;       

  input   [11:0]      bid_gic_axim_m;          
  input   [1:0]       bresp_gic_axim_m;        
  input               bvalid_gic_axim_m;       
  output              bready_gic_axim_m;       

  output  [11:0]      arid_gic_axim_m;         
  output  [31:0]      araddr_gic_axim_m;       
  output  [7:0]       arlen_gic_axim_m;        
  output  [2:0]       arsize_gic_axim_m;       
  output  [1:0]       arburst_gic_axim_m;      
  output              arlock_gic_axim_m;       
  output  [3:0]       arcache_gic_axim_m;      
  output  [2:0]       arprot_gic_axim_m;       
  output              arvalid_gic_axim_m;      
  input               arready_gic_axim_m;      

  input   [11:0]      rid_gic_axim_m;          
  input   [31:0]      rdata_gic_axim_m;        
  input   [1:0]       rresp_gic_axim_m;        
  input               rlast_gic_axim_m;        
  input               rvalid_gic_axim_m;       
  output              rready_gic_axim_m;       

  output  [9:0]       awuser_gic_axim_m;       
  output  [9:0]       aruser_gic_axim_m;       

  output  [3:0]       awqv_gic_axim_m;         
  output  [3:0]       arqv_gic_axim_m;         



  input   [11:0]      awid_gic_axim_s;         
  input   [31:0]      awaddr_gic_axim_s;       
  input   [7:0]       awlen_gic_axim_s;        
  input   [2:0]       awsize_gic_axim_s;       
  input   [1:0]       awburst_gic_axim_s;      
  input               awlock_gic_axim_s;       
  input   [3:0]       awcache_gic_axim_s;      
  input   [2:0]       awprot_gic_axim_s;       
  input               awvalid_gic_axim_s;      
  output              awready_gic_axim_s;      

  input   [31:0]      wdata_gic_axim_s;        
  input   [3:0]       wstrb_gic_axim_s;        
  input               wlast_gic_axim_s;        
  input               wvalid_gic_axim_s;       
  output              wready_gic_axim_s;       

  output  [11:0]      bid_gic_axim_s;          
  output  [1:0]       bresp_gic_axim_s;        
  output              bvalid_gic_axim_s;       
  input               bready_gic_axim_s;       

  input   [11:0]      arid_gic_axim_s;         
  input   [31:0]      araddr_gic_axim_s;       
  input   [7:0]       arlen_gic_axim_s;        
  input   [2:0]       arsize_gic_axim_s;       
  input   [1:0]       arburst_gic_axim_s;      
  input               arlock_gic_axim_s;       
  input   [3:0]       arcache_gic_axim_s;      
  input   [2:0]       arprot_gic_axim_s;       
  input               arvalid_gic_axim_s;      
  output              arready_gic_axim_s;      

  output  [11:0]      rid_gic_axim_s;          
  output  [31:0]      rdata_gic_axim_s;        
  output  [1:0]       rresp_gic_axim_s;        
  output              rlast_gic_axim_s;        
  output              rvalid_gic_axim_s;       
  input               rready_gic_axim_s;       

  input   [9:0]       awuser_gic_axim_s;       
  input   [9:0]       aruser_gic_axim_s;       

  input   [3:0]       awqv_gic_axim_s;         
  input   [3:0]       arqv_gic_axim_s;         

  input               aclk;                    
  input               aresetn;                 






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [36:0]    w_master_port_src_data;     
  wire [36:0]    w_master_port_dst_data;     



  wire           r_master_port_dst_valid;
  wire           r_master_port_dst_ready;
  wire           r_master_port_src_valid;
  wire           r_master_port_src_ready;

  wire [46:0]    r_master_port_src_data;     
  wire [46:0]    r_master_port_dst_data;     



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




  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_gic_axim_s[31:24]  & {8{wstrb_gic_axim_s[3]}}),
  (wdata_gic_axim_s[23:16]  & {8{wstrb_gic_axim_s[2]}}),
  (wdata_gic_axim_s[15:8]  & {8{wstrb_gic_axim_s[1]}}),
  (wdata_gic_axim_s[7:0]  & {8{wstrb_gic_axim_s[0]}})};
  

  
  assign awid = {awid_gic_axim_s[11],
  awid_gic_axim_s[10],
  awid_gic_axim_s[9],
  awid_gic_axim_s[8],
  awid_gic_axim_s[7],
  awid_gic_axim_s[6],
  awid_gic_axim_s[5],
  awid_gic_axim_s[4],
  awid_gic_axim_s[3],
  awid_gic_axim_s[2],
  awid_gic_axim_s[1],
  awid_gic_axim_s[0]};

  assign arid = {arid_gic_axim_s[11],
  arid_gic_axim_s[10],
  arid_gic_axim_s[9],
  arid_gic_axim_s[8],
  arid_gic_axim_s[7],
  arid_gic_axim_s[6],
  arid_gic_axim_s[5],
  arid_gic_axim_s[4],
  arid_gic_axim_s[3],
  arid_gic_axim_s[2],
  arid_gic_axim_s[1],
  arid_gic_axim_s[0]};


  assign rid_gic_axim_s = {rid[11],
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

  assign bid_gic_axim_s = {bid[11],
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
  assign awid_gic_axim_m     = awid;
  assign awaddr_gic_axim_m   = awaddr_gic_axim_s;
  assign awlen_gic_axim_m    = awlen_gic_axim_s;
  assign awsize_gic_axim_m   = awsize_gic_axim_s;
  assign awburst_gic_axim_m  = awburst_gic_axim_s;
  assign awlock_gic_axim_m   = awlock_gic_axim_s;
  assign awcache_gic_axim_m  = awcache_gic_axim_s;
  assign awqv_gic_axim_m     = awqv_gic_axim_s;
  assign awprot_gic_axim_m   = awprot_gic_axim_s;
  assign awuser_gic_axim_m   = awuser_gic_axim_s;
  assign awvalid_gic_axim_m  = awvalid_gic_axim_s;
  assign awready_gic_axim_s  = awready_gic_axim_m;
  assign arid_gic_axim_m     = arid;
  assign araddr_gic_axim_m   = araddr_gic_axim_s;
  assign arlen_gic_axim_m    = arlen_gic_axim_s;
  assign arsize_gic_axim_m   = arsize_gic_axim_s;
  assign arburst_gic_axim_m  = arburst_gic_axim_s;
  assign arlock_gic_axim_m   = arlock_gic_axim_s;
  assign arcache_gic_axim_m  = arcache_gic_axim_s;
  assign arqv_gic_axim_m     = arqv_gic_axim_s;
  assign arprot_gic_axim_m   = arprot_gic_axim_s;
  assign aruser_gic_axim_m   = aruser_gic_axim_s;
  assign arvalid_gic_axim_m  = arvalid_gic_axim_s;
  assign arready_gic_axim_s  = arready_gic_axim_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_gic_axim_s,
        wlast_gic_axim_s};

  assign {wdata_gic_axim_m,
        wstrb_gic_axim_m,
        wlast_gic_axim_m} = w_master_port_dst_data;

  assign wvalid_gic_axim_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_gic_axim_m;

  assign w_master_port_src_valid = wvalid_gic_axim_s;
  assign wready_gic_axim_s = w_master_port_src_ready;



  assign r_master_port_src_data = {rid_gic_axim_m,
        rdata_gic_axim_m,
        rresp_gic_axim_m,
        rlast_gic_axim_m};

  assign {rid,
        rdata_gic_axim_s,
        rresp_gic_axim_s,
        rlast_gic_axim_s} = r_master_port_dst_data;

  assign rvalid_gic_axim_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_gic_axim_s;

  assign r_master_port_src_valid = rvalid_gic_axim_m;
  assign rready_gic_axim_m = r_master_port_src_ready;



  assign b_master_port_src_data = {bid_gic_axim_m,
        bresp_gic_axim_m};

  assign {bid,
        bresp_gic_axim_s} = b_master_port_dst_data;

  assign bvalid_gic_axim_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_gic_axim_s;

  assign b_master_port_src_valid = bvalid_gic_axim_m;
  assign bready_gic_axim_m = b_master_port_src_ready;






  nic400_amib_gic_axim_chan_slice_sse710_sys_apb
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




  nic400_amib_gic_axim_chan_slice_sse710_sys_apb
    #(
       `RS_REV_REG,  
       47  
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




  nic400_amib_gic_axim_chan_slice_sse710_sys_apb
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


  assign wif_hndshk = wvalid_gic_axim_m & wready_gic_axim_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_gic_axim_m[31:24]  & ~wstrb_gic_axim_m[3]) | 
  (|wdata_gic_axim_m[23:16]  & ~wstrb_gic_axim_m[2]) | 
  (|wdata_gic_axim_m[15:8]  & ~wstrb_gic_axim_m[1]) | 
  (|wdata_gic_axim_m[7:0]  & ~wstrb_gic_axim_m[0]));



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

`include "nic400_amib_gic_axim_undefs_sse710_sys_apb.v"

