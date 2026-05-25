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


`include "nic400_ib_p1_axis_ib_defs_sse710_dbg3s1m.v"


module nic400_ib_p1_axis_ib_slave_domain_sse710_dbg3s1m
  (
  

    awid_axi4_s,
    awaddr_axi4_s,
    awlen_axi4_s,
    awsize_axi4_s,
    awburst_axi4_s,
    awlock_axi4_s,
    awcache_axi4_s,
    awprot_axi4_s,
    awvalid_axi4_s,
    awvalid_vect_axi4_s,
    awready_axi4_s,

    wdata_axi4_s,
    wstrb_axi4_s,
    wlast_axi4_s,
    wvalid_axi4_s,
    wready_axi4_s,

    bid_axi4_s,
    bresp_axi4_s,
    bvalid_axi4_s,
    bready_axi4_s,

    arid_axi4_s,
    araddr_axi4_s,
    arlen_axi4_s,
    arsize_axi4_s,
    arburst_axi4_s,
    arlock_axi4_s,
    arcache_axi4_s,
    arprot_axi4_s,
    arvalid_axi4_s,
    arvalid_vect_axi4_s,
    arready_axi4_s,

    rid_axi4_s,
    rdata_axi4_s,
    rresp_axi4_s,
    rlast_axi4_s,
    rvalid_axi4_s,
    rready_axi4_s,

    awuser_axi4_s,
    aruser_axi4_s,


    aw_data,
    aw_rpntr_gry,
    aw_rpntr_bin,
    aw_wpntr_gry,

    b_data,
    b_rpntr_gry,
    b_rpntr_bin,
    b_wpntr_gry,

    ar_data,
    ar_valid,
    ar_ready,

    r_data,
    r_valid,
    r_ready,

    w_data,
    w_rpntr_gry,
    w_rpntr_bin,
    w_wpntr_gry,

    aclk,
    aresetn

  );



  


  input   [1:0]       awid_axi4_s;              
  input   [31:0]      awaddr_axi4_s;            
  input   [7:0]       awlen_axi4_s;             
  input   [2:0]       awsize_axi4_s;            
  input   [1:0]       awburst_axi4_s;           
  input               awlock_axi4_s;            
  input   [3:0]       awcache_axi4_s;           
  input   [2:0]       awprot_axi4_s;            
  input               awvalid_axi4_s;           
  input               awvalid_vect_axi4_s;      
  output              awready_axi4_s;           

  input   [31:0]      wdata_axi4_s;             
  input   [3:0]       wstrb_axi4_s;             
  input               wlast_axi4_s;             
  input               wvalid_axi4_s;            
  output              wready_axi4_s;            

  output  [1:0]       bid_axi4_s;               
  output  [1:0]       bresp_axi4_s;             
  output              bvalid_axi4_s;            
  input               bready_axi4_s;            

  input   [1:0]       arid_axi4_s;              
  input   [31:0]      araddr_axi4_s;            
  input   [7:0]       arlen_axi4_s;             
  input   [2:0]       arsize_axi4_s;            
  input   [1:0]       arburst_axi4_s;           
  input               arlock_axi4_s;            
  input   [3:0]       arcache_axi4_s;           
  input   [2:0]       arprot_axi4_s;            
  input               arvalid_axi4_s;           
  input               arvalid_vect_axi4_s;      
  output              arready_axi4_s;           

  output  [1:0]       rid_axi4_s;               
  output  [31:0]      rdata_axi4_s;             
  output  [1:0]       rresp_axi4_s;             
  output              rlast_axi4_s;             
  output              rvalid_axi4_s;            
  input               rready_axi4_s;            

  input   [2:0]       awuser_axi4_s;            
  input   [2:0]       aruser_axi4_s;            



  output  [58:0]      aw_data;                  
  input   [3:0]       aw_rpntr_gry;             
  input   [2:0]       aw_rpntr_bin;             
  output  [3:0]       aw_wpntr_gry;             

  input   [3:0]       b_data;                   
  output  [2:0]       b_rpntr_gry;              
  output  [1:0]       b_rpntr_bin;              
  input   [2:0]       b_wpntr_gry;              

  output  [58:0]      ar_data;                  
  output              ar_valid;                 
  input               ar_ready;                 

  input   [36:0]      r_data;                   
  input               r_valid;                  
  output              r_ready;                  

  output  [36:0]      w_data;                   
  input   [3:0]       w_rpntr_gry;              
  input   [2:0]       w_rpntr_bin;              
  output  [3:0]       w_wpntr_gry;              

  input               aclk;                     
  input               aresetn;                  
   


  
  wire                aw_boundary_src_valid;
  wire                aw_boundary_src_ready;

  wire [58:0]         aw_boundary_src_data;     
  wire [58:0]         aw_boundary_dst_data;     


  
  wire                w_boundary_src_valid;
  wire                w_boundary_src_ready;

  wire [36:0]         w_boundary_src_data;     
  wire [36:0]         w_boundary_dst_data;     


  
  wire                b_boundary_dst_valid;
  wire                b_boundary_dst_ready;

  wire [3:0]          aw_rpntr_gry;            
  wire [2:0]          aw_rpntr_bin;             
  wire [3:0]          aw_wpntr_gry;            
  
  wire [3:0]          w_rpntr_gry;             
  wire [2:0]          w_rpntr_bin;             
  wire [3:0]          w_wpntr_gry;             
  
  wire [2:0]          b_rpntr_gry;             
  wire [1:0]          b_rpntr_bin;             
  wire [2:0]          b_wpntr_gry;             
  









  assign aw_boundary_src_data = {
          awid_axi4_s,
          awaddr_axi4_s[31:0],
          awlen_axi4_s,
          awsize_axi4_s,
          awburst_axi4_s,
          awlock_axi4_s,
          awcache_axi4_s,
          awuser_axi4_s,
          awprot_axi4_s,
          awvalid_vect_axi4_s};


  assign aw_boundary_src_valid = awvalid_axi4_s;
  assign awready_axi4_s = aw_boundary_src_ready;

  assign aw_data = aw_boundary_dst_data;
  

  assign ar_data = {
          arid_axi4_s,
          araddr_axi4_s[31:0],
          arlen_axi4_s,
          arsize_axi4_s,
          arburst_axi4_s,
          arlock_axi4_s,
          arcache_axi4_s,
          aruser_axi4_s,
          arprot_axi4_s,
          arvalid_vect_axi4_s};


  assign ar_valid = arvalid_axi4_s;

  assign arready_axi4_s = ar_ready;


  assign w_boundary_src_data = {
          wdata_axi4_s,
          wstrb_axi4_s,
          wlast_axi4_s};


  assign w_boundary_src_valid = wvalid_axi4_s;
  assign wready_axi4_s = w_boundary_src_ready;

  assign w_data = w_boundary_dst_data;
  


  assign {
          rid_axi4_s,
          rdata_axi4_s,
          rresp_axi4_s,
          rlast_axi4_s} = r_data;

  assign r_ready = rready_axi4_s;
  assign rvalid_axi4_s = r_valid;





  assign {
          bid_axi4_s,
          bresp_axi4_s} = b_data;

  assign b_boundary_dst_ready = bready_axi4_s;
  assign bvalid_axi4_s = b_boundary_dst_valid;




  nic400_ib_p1_axis_ib_aw_fifo_wr_sse710_dbg3s1m
  u_aw_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (aw_boundary_src_valid),
     .src_data              (aw_boundary_src_data),
     .rpntr_gry             (aw_rpntr_gry),
     .rpntr_bin             (aw_rpntr_bin),

     .src_ready             (aw_boundary_src_ready),
     .dst_data              (aw_boundary_dst_data),
     .wpntr_gry             (aw_wpntr_gry)
     );




  nic400_ib_p1_axis_ib_w_fifo_wr_sse710_dbg3s1m
  u_w_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (w_boundary_src_valid),
     .src_data              (w_boundary_src_data),
     .rpntr_gry             (w_rpntr_gry),
     .rpntr_bin             (w_rpntr_bin),

     .src_ready             (w_boundary_src_ready),
     .dst_data              (w_boundary_dst_data),
     .wpntr_gry             (w_wpntr_gry)
     );




  nic400_ib_p1_axis_ib_b_fifo_rd_sse710_dbg3s1m
  u_b_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (b_boundary_dst_ready),
     .wpntr_gry             (b_wpntr_gry),

     .dst_valid             (b_boundary_dst_valid),
     .rpntr_gry             (b_rpntr_gry),
     .rpntr_bin             (b_rpntr_bin)
     );



    
    


endmodule

`include "nic400_ib_p1_axis_ib_undefs_sse710_dbg3s1m.v"




