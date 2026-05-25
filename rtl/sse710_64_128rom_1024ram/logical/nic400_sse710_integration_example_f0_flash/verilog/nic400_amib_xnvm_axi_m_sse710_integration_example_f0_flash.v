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



`include "nic400_amib_xnvm_axi_m_defs_sse710_integration_example_f0_flash.v"

module nic400_amib_xnvm_axi_m_sse710_integration_example_f0_flash
  (
  

    awid_xnvm_axi_m_m,
    awaddr_xnvm_axi_m_m,
    awlen_xnvm_axi_m_m,
    awsize_xnvm_axi_m_m,
    awburst_xnvm_axi_m_m,
    awlock_xnvm_axi_m_m,
    awcache_xnvm_axi_m_m,
    awprot_xnvm_axi_m_m,
    awvalid_xnvm_axi_m_m,
    awready_xnvm_axi_m_m,

    wdata_xnvm_axi_m_m,
    wstrb_xnvm_axi_m_m,
    wlast_xnvm_axi_m_m,
    wvalid_xnvm_axi_m_m,
    wready_xnvm_axi_m_m,

    bid_xnvm_axi_m_m,
    bresp_xnvm_axi_m_m,
    bvalid_xnvm_axi_m_m,
    bready_xnvm_axi_m_m,

    arid_xnvm_axi_m_m,
    araddr_xnvm_axi_m_m,
    arlen_xnvm_axi_m_m,
    arsize_xnvm_axi_m_m,
    arburst_xnvm_axi_m_m,
    arlock_xnvm_axi_m_m,
    arcache_xnvm_axi_m_m,
    arprot_xnvm_axi_m_m,
    arvalid_xnvm_axi_m_m,
    arready_xnvm_axi_m_m,

    rid_xnvm_axi_m_m,
    rdata_xnvm_axi_m_m,
    rresp_xnvm_axi_m_m,
    rlast_xnvm_axi_m_m,
    rvalid_xnvm_axi_m_m,
    rready_xnvm_axi_m_m,


    awid_xnvm_axi_m_s,
    awaddr_xnvm_axi_m_s,
    awlen_xnvm_axi_m_s,
    awsize_xnvm_axi_m_s,
    awburst_xnvm_axi_m_s,
    awlock_xnvm_axi_m_s,
    awcache_xnvm_axi_m_s,
    awprot_xnvm_axi_m_s,
    awvalid_xnvm_axi_m_s,
    awready_xnvm_axi_m_s,

    wdata_xnvm_axi_m_s,
    wstrb_xnvm_axi_m_s,
    wlast_xnvm_axi_m_s,
    wvalid_xnvm_axi_m_s,
    wready_xnvm_axi_m_s,

    bid_xnvm_axi_m_s,
    bresp_xnvm_axi_m_s,
    bvalid_xnvm_axi_m_s,
    bready_xnvm_axi_m_s,

    arid_xnvm_axi_m_s,
    araddr_xnvm_axi_m_s,
    arlen_xnvm_axi_m_s,
    arsize_xnvm_axi_m_s,
    arburst_xnvm_axi_m_s,
    arlock_xnvm_axi_m_s,
    arcache_xnvm_axi_m_s,
    arprot_xnvm_axi_m_s,
    arvalid_xnvm_axi_m_s,
    arready_xnvm_axi_m_s,

    rid_xnvm_axi_m_s,
    rdata_xnvm_axi_m_s,
    rresp_xnvm_axi_m_s,
    rlast_xnvm_axi_m_s,
    rvalid_xnvm_axi_m_s,
    rready_xnvm_axi_m_s,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_xnvm_axi_m_m;         
  output  [31:0]      awaddr_xnvm_axi_m_m;       
  output  [7:0]       awlen_xnvm_axi_m_m;        
  output  [2:0]       awsize_xnvm_axi_m_m;       
  output  [1:0]       awburst_xnvm_axi_m_m;      
  output              awlock_xnvm_axi_m_m;       
  output  [3:0]       awcache_xnvm_axi_m_m;      
  output  [2:0]       awprot_xnvm_axi_m_m;       
  output              awvalid_xnvm_axi_m_m;      
  input               awready_xnvm_axi_m_m;      

  output  [127:0]     wdata_xnvm_axi_m_m;        
  output  [15:0]      wstrb_xnvm_axi_m_m;        
  output              wlast_xnvm_axi_m_m;        
  output              wvalid_xnvm_axi_m_m;       
  input               wready_xnvm_axi_m_m;       

  input   [11:0]      bid_xnvm_axi_m_m;          
  input   [1:0]       bresp_xnvm_axi_m_m;        
  input               bvalid_xnvm_axi_m_m;       
  output              bready_xnvm_axi_m_m;       

  output  [11:0]      arid_xnvm_axi_m_m;         
  output  [31:0]      araddr_xnvm_axi_m_m;       
  output  [7:0]       arlen_xnvm_axi_m_m;        
  output  [2:0]       arsize_xnvm_axi_m_m;       
  output  [1:0]       arburst_xnvm_axi_m_m;      
  output              arlock_xnvm_axi_m_m;       
  output  [3:0]       arcache_xnvm_axi_m_m;      
  output  [2:0]       arprot_xnvm_axi_m_m;       
  output              arvalid_xnvm_axi_m_m;      
  input               arready_xnvm_axi_m_m;      

  input   [11:0]      rid_xnvm_axi_m_m;          
  input   [127:0]     rdata_xnvm_axi_m_m;        
  input   [1:0]       rresp_xnvm_axi_m_m;        
  input               rlast_xnvm_axi_m_m;        
  input               rvalid_xnvm_axi_m_m;       
  output              rready_xnvm_axi_m_m;       



  input   [11:0]      awid_xnvm_axi_m_s;         
  input   [31:0]      awaddr_xnvm_axi_m_s;       
  input   [7:0]       awlen_xnvm_axi_m_s;        
  input   [2:0]       awsize_xnvm_axi_m_s;       
  input   [1:0]       awburst_xnvm_axi_m_s;      
  input               awlock_xnvm_axi_m_s;       
  input   [3:0]       awcache_xnvm_axi_m_s;      
  input   [2:0]       awprot_xnvm_axi_m_s;       
  input               awvalid_xnvm_axi_m_s;      
  output              awready_xnvm_axi_m_s;      

  input   [127:0]     wdata_xnvm_axi_m_s;        
  input   [15:0]      wstrb_xnvm_axi_m_s;        
  input               wlast_xnvm_axi_m_s;        
  input               wvalid_xnvm_axi_m_s;       
  output              wready_xnvm_axi_m_s;       

  output  [11:0]      bid_xnvm_axi_m_s;          
  output  [1:0]       bresp_xnvm_axi_m_s;        
  output              bvalid_xnvm_axi_m_s;       
  input               bready_xnvm_axi_m_s;       

  input   [11:0]      arid_xnvm_axi_m_s;         
  input   [31:0]      araddr_xnvm_axi_m_s;       
  input   [7:0]       arlen_xnvm_axi_m_s;        
  input   [2:0]       arsize_xnvm_axi_m_s;       
  input   [1:0]       arburst_xnvm_axi_m_s;      
  input               arlock_xnvm_axi_m_s;       
  input   [3:0]       arcache_xnvm_axi_m_s;      
  input   [2:0]       arprot_xnvm_axi_m_s;       
  input               arvalid_xnvm_axi_m_s;      
  output              arready_xnvm_axi_m_s;      

  output  [11:0]      rid_xnvm_axi_m_s;          
  output  [127:0]     rdata_xnvm_axi_m_s;        
  output  [1:0]       rresp_xnvm_axi_m_s;        
  output              rlast_xnvm_axi_m_s;        
  output              rvalid_xnvm_axi_m_s;       
  input               rready_xnvm_axi_m_s;       

  input               aclk;                      
  input               aresetn;                   






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [144:0]   w_master_port_src_data;     
  wire [144:0]   w_master_port_dst_data;     



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

  wire [142:0]   r_master_port_src_data;     
  wire [142:0]   r_master_port_dst_data;     







  wire [127:0]  wdata_destrob;
  assign wdata_destrob = {
  (wdata_xnvm_axi_m_s[127:120]  & {8{wstrb_xnvm_axi_m_s[15]}}),
  (wdata_xnvm_axi_m_s[119:112]  & {8{wstrb_xnvm_axi_m_s[14]}}),
  (wdata_xnvm_axi_m_s[111:104]  & {8{wstrb_xnvm_axi_m_s[13]}}),
  (wdata_xnvm_axi_m_s[103:96]  & {8{wstrb_xnvm_axi_m_s[12]}}),
  (wdata_xnvm_axi_m_s[95:88]  & {8{wstrb_xnvm_axi_m_s[11]}}),
  (wdata_xnvm_axi_m_s[87:80]  & {8{wstrb_xnvm_axi_m_s[10]}}),
  (wdata_xnvm_axi_m_s[79:72]  & {8{wstrb_xnvm_axi_m_s[9]}}),
  (wdata_xnvm_axi_m_s[71:64]  & {8{wstrb_xnvm_axi_m_s[8]}}),
  (wdata_xnvm_axi_m_s[63:56]  & {8{wstrb_xnvm_axi_m_s[7]}}),
  (wdata_xnvm_axi_m_s[55:48]  & {8{wstrb_xnvm_axi_m_s[6]}}),
  (wdata_xnvm_axi_m_s[47:40]  & {8{wstrb_xnvm_axi_m_s[5]}}),
  (wdata_xnvm_axi_m_s[39:32]  & {8{wstrb_xnvm_axi_m_s[4]}}),
  (wdata_xnvm_axi_m_s[31:24]  & {8{wstrb_xnvm_axi_m_s[3]}}),
  (wdata_xnvm_axi_m_s[23:16]  & {8{wstrb_xnvm_axi_m_s[2]}}),
  (wdata_xnvm_axi_m_s[15:8]  & {8{wstrb_xnvm_axi_m_s[1]}}),
  (wdata_xnvm_axi_m_s[7:0]  & {8{wstrb_xnvm_axi_m_s[0]}})};
  
  assign awid_xnvm_axi_m_m     = awid_xnvm_axi_m_s;
  assign awaddr_xnvm_axi_m_m   = awaddr_xnvm_axi_m_s;
  assign awlen_xnvm_axi_m_m    = awlen_xnvm_axi_m_s;
  assign awsize_xnvm_axi_m_m   = awsize_xnvm_axi_m_s;
  assign awburst_xnvm_axi_m_m  = awburst_xnvm_axi_m_s;
  assign awlock_xnvm_axi_m_m   = awlock_xnvm_axi_m_s;
  assign awcache_xnvm_axi_m_m  = awcache_xnvm_axi_m_s;
  assign awprot_xnvm_axi_m_m   = awprot_xnvm_axi_m_s;
  assign awvalid_xnvm_axi_m_m  = awvalid_xnvm_axi_m_s;
  assign awready_xnvm_axi_m_s  = awready_xnvm_axi_m_m;
  assign arid_xnvm_axi_m_m     = arid_xnvm_axi_m_s;
  assign araddr_xnvm_axi_m_m   = araddr_xnvm_axi_m_s;
  assign arlen_xnvm_axi_m_m    = arlen_xnvm_axi_m_s;
  assign arsize_xnvm_axi_m_m   = arsize_xnvm_axi_m_s;
  assign arburst_xnvm_axi_m_m  = arburst_xnvm_axi_m_s;
  assign arlock_xnvm_axi_m_m   = arlock_xnvm_axi_m_s;
  assign arcache_xnvm_axi_m_m  = arcache_xnvm_axi_m_s;
  assign arprot_xnvm_axi_m_m   = arprot_xnvm_axi_m_s;
  assign arvalid_xnvm_axi_m_m  = arvalid_xnvm_axi_m_s;
  assign arready_xnvm_axi_m_s  = arready_xnvm_axi_m_m;


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_xnvm_axi_m_s,
        wlast_xnvm_axi_m_s};

  assign {wdata_xnvm_axi_m_m,
        wstrb_xnvm_axi_m_m,
        wlast_xnvm_axi_m_m} = w_master_port_dst_data;

  assign wvalid_xnvm_axi_m_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_xnvm_axi_m_m;

  assign w_master_port_src_valid = wvalid_xnvm_axi_m_s;
  assign wready_xnvm_axi_m_s = w_master_port_src_ready;



  assign b_master_port_src_data = {bid_xnvm_axi_m_m,
        bresp_xnvm_axi_m_m};

  assign {bid_xnvm_axi_m_s,
        bresp_xnvm_axi_m_s} = b_master_port_dst_data;

  assign bvalid_xnvm_axi_m_s =  b_master_port_dst_valid;
  assign b_master_port_dst_ready = bready_xnvm_axi_m_s;

  assign b_master_port_src_valid = bvalid_xnvm_axi_m_m;
  assign bready_xnvm_axi_m_m = b_master_port_src_ready;



  assign r_master_port_src_data = {rid_xnvm_axi_m_m,
        rdata_xnvm_axi_m_m,
        rresp_xnvm_axi_m_m,
        rlast_xnvm_axi_m_m};

  assign {rid_xnvm_axi_m_s,
        rdata_xnvm_axi_m_s,
        rresp_xnvm_axi_m_s,
        rlast_xnvm_axi_m_s} = r_master_port_dst_data;

  assign rvalid_xnvm_axi_m_s =  r_master_port_dst_valid;
  assign r_master_port_dst_ready = rready_xnvm_axi_m_s;

  assign r_master_port_src_valid = rvalid_xnvm_axi_m_m;
  assign rready_xnvm_axi_m_m = r_master_port_src_ready;






  nic400_amib_xnvm_axi_m_chan_slice_sse710_integration_example_f0_flash
    #(
       `RS_REV_REG,  
       145  
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




  nic400_amib_xnvm_axi_m_chan_slice_sse710_integration_example_f0_flash
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




  nic400_amib_xnvm_axi_m_chan_slice_sse710_integration_example_f0_flash
    #(
       `RS_REV_REG,  
       143  
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


  assign wif_hndshk = wvalid_xnvm_axi_m_m & wready_xnvm_axi_m_m;
  assign strobeless_wdata = wif_hndshk & (
  (|wdata_xnvm_axi_m_m[127:120]  & ~wstrb_xnvm_axi_m_m[15]) | 
  (|wdata_xnvm_axi_m_m[119:112]  & ~wstrb_xnvm_axi_m_m[14]) | 
  (|wdata_xnvm_axi_m_m[111:104]  & ~wstrb_xnvm_axi_m_m[13]) | 
  (|wdata_xnvm_axi_m_m[103:96]  & ~wstrb_xnvm_axi_m_m[12]) | 
  (|wdata_xnvm_axi_m_m[95:88]  & ~wstrb_xnvm_axi_m_m[11]) | 
  (|wdata_xnvm_axi_m_m[87:80]  & ~wstrb_xnvm_axi_m_m[10]) | 
  (|wdata_xnvm_axi_m_m[79:72]  & ~wstrb_xnvm_axi_m_m[9]) | 
  (|wdata_xnvm_axi_m_m[71:64]  & ~wstrb_xnvm_axi_m_m[8]) | 
  (|wdata_xnvm_axi_m_m[63:56]  & ~wstrb_xnvm_axi_m_m[7]) | 
  (|wdata_xnvm_axi_m_m[55:48]  & ~wstrb_xnvm_axi_m_m[6]) | 
  (|wdata_xnvm_axi_m_m[47:40]  & ~wstrb_xnvm_axi_m_m[5]) | 
  (|wdata_xnvm_axi_m_m[39:32]  & ~wstrb_xnvm_axi_m_m[4]) | 
  (|wdata_xnvm_axi_m_m[31:24]  & ~wstrb_xnvm_axi_m_m[3]) | 
  (|wdata_xnvm_axi_m_m[23:16]  & ~wstrb_xnvm_axi_m_m[2]) | 
  (|wdata_xnvm_axi_m_m[15:8]  & ~wstrb_xnvm_axi_m_m[1]) | 
  (|wdata_xnvm_axi_m_m[7:0]  & ~wstrb_xnvm_axi_m_m[0]));



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

`include "nic400_amib_xnvm_axi_m_undefs_sse710_integration_example_f0_flash.v"

