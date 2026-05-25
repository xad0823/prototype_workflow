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


`include "nic400_ib_extsys1_axis_ib_defs_sse710_main.v"


module nic400_ib_extsys1_axis_ib_slave_domain_sse710_main
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
    buser_axi4_s,
    aruser_axi4_s,
    ruser_axi4_s,

    paddrm,
    pwdatam,
    pwritem,
    penablem,
    pselm,
    prdatam,
    pslverrm,
    preadym,

    apbs_req,
    apbs_ack,
    apbs_fwd_data,
    apbs_rev_data,


    aw_data,
    aw_rpntr_gry,
    aw_rpntr_bin,
    aw_wpntr_gry,

    b_data,
    b_rpntr_gry,
    b_rpntr_bin,
    b_wpntr_gry,

    ar_data,
    ar_rpntr_gry,
    ar_rpntr_bin,
    ar_wpntr_gry,

    r_data,
    r_rpntr_gry,
    r_rpntr_bin,
    r_wpntr_gry,

    w_data,
    w_rpntr_gry,
    w_rpntr_bin,
    w_wpntr_gry,

    aclk,
    aresetn

  );



  


  input   [7:0]       awid_axi4_s;              
  input   [31:0]      awaddr_axi4_s;            
  input   [7:0]       awlen_axi4_s;             
  input   [2:0]       awsize_axi4_s;            
  input   [1:0]       awburst_axi4_s;           
  input               awlock_axi4_s;            
  input   [3:0]       awcache_axi4_s;           
  input   [2:0]       awprot_axi4_s;            
  input               awvalid_axi4_s;           
  input   [9:0]       awvalid_vect_axi4_s;      
  output              awready_axi4_s;           

  input   [63:0]      wdata_axi4_s;             
  input   [7:0]       wstrb_axi4_s;             
  input               wlast_axi4_s;             
  input               wvalid_axi4_s;            
  output              wready_axi4_s;            

  output  [7:0]       bid_axi4_s;               
  output  [1:0]       bresp_axi4_s;             
  output              bvalid_axi4_s;            
  input               bready_axi4_s;            

  input   [7:0]       arid_axi4_s;              
  input   [31:0]      araddr_axi4_s;            
  input   [7:0]       arlen_axi4_s;             
  input   [2:0]       arsize_axi4_s;            
  input   [1:0]       arburst_axi4_s;           
  input               arlock_axi4_s;            
  input   [3:0]       arcache_axi4_s;           
  input   [2:0]       arprot_axi4_s;            
  input               arvalid_axi4_s;           
  input   [9:0]       arvalid_vect_axi4_s;      
  output              arready_axi4_s;           

  output  [7:0]       rid_axi4_s;               
  output  [63:0]      rdata_axi4_s;             
  output  [1:0]       rresp_axi4_s;             
  output              rlast_axi4_s;             
  output              rvalid_axi4_s;            
  input               rready_axi4_s;            

  input   [9:0]       awuser_axi4_s;            
  output              buser_axi4_s;             
  input   [9:0]       aruser_axi4_s;            
  output              ruser_axi4_s;             

  output  [31:0]      paddrm;                   
  output  [31:0]      pwdatam;                  
  output              pwritem;                  
  output              penablem;                 
  output              pselm;                    
  input   [31:0]      prdatam;                  
  input               pslverrm;                 
  input               preadym;                  

  input               apbs_req;                 
  output              apbs_ack;                 
  input   [71:0]      apbs_fwd_data;            
  output  [32:0]      apbs_rev_data;            



  output  [80:0]      aw_data;                  
  input   [3:0]       aw_rpntr_gry;             
  input   [2:0]       aw_rpntr_bin;             
  output  [3:0]       aw_wpntr_gry;             

  input   [10:0]      b_data;                   
  output  [2:0]       b_rpntr_gry;              
  output  [1:0]       b_rpntr_bin;              
  input   [2:0]       b_wpntr_gry;              

  output  [80:0]      ar_data;                  
  input   [3:0]       ar_rpntr_gry;             
  input   [2:0]       ar_rpntr_bin;             
  output  [3:0]       ar_wpntr_gry;             

  input   [75:0]      r_data;                   
  output  [2:0]       r_rpntr_gry;              
  output  [1:0]       r_rpntr_bin;              
  input   [2:0]       r_wpntr_gry;              

  output  [72:0]      w_data;                   
  input   [2:0]       w_rpntr_gry;              
  input   [1:0]       w_rpntr_bin;              
  output  [2:0]       w_wpntr_gry;              

  input               aclk;                     
  input               aresetn;                  
   


  wire                pslverr;
  wire                pready;
  wire [31:0]         prdata;
  wire                pselm_apb;
  
  wire                aw_boundary_src_valid;
  wire                aw_boundary_src_ready;

  wire [80:0]         aw_boundary_src_data;     
  wire [80:0]         aw_boundary_dst_data;     


  
  wire                ar_boundary_src_valid;
  wire                ar_boundary_src_ready;

  wire [80:0]         ar_boundary_src_data;     
  wire [80:0]         ar_boundary_dst_data;     


  
  wire                r_boundary_dst_valid;
  wire                r_boundary_dst_ready;

  
  wire                w_boundary_src_valid;
  wire                w_boundary_src_ready;

  wire [72:0]         w_boundary_src_data;     
  wire [72:0]         w_boundary_dst_data;     


  
  wire                b_boundary_dst_valid;
  wire                b_boundary_dst_ready;

  wire [3:0]          aw_rpntr_gry;            
  wire [2:0]          aw_rpntr_bin;             
  wire [3:0]          aw_wpntr_gry;            
  
  wire [3:0]          ar_rpntr_gry;            
  wire [2:0]          ar_rpntr_bin;             
  wire [3:0]          ar_wpntr_gry;            
  
  wire [2:0]          w_rpntr_gry;             
  wire [1:0]          w_rpntr_bin;             
  wire [2:0]          w_wpntr_gry;             
  
  wire [2:0]          b_rpntr_gry;             
  wire [1:0]          b_rpntr_bin;             
  wire [2:0]          b_wpntr_gry;             
  
  wire [2:0]          r_rpntr_gry;             
  wire [1:0]          r_rpntr_bin;             
  wire [2:0]          r_wpntr_gry;             
  








  nic400_apb_bridge_master_domain_sse710_main u_apb_async_m
  (
    .pclkm                    (aclk),
    .pclkenm                  (1'b1),
    .presetmn                 (aresetn),

    .pselm                    (pselm_apb),
    .penablem                 (penablem),
    .preadym                  (pready),

    .pwritem                  (pwritem),
    .paddrm                   (paddrm),
    .pwdatam                  (pwdatam),
    .pprotm                   (),
    .pstrbm                   (),
    .prdatam                  (prdata),
    .pslverrm                 (pslverr),

    .apbs_req_async           (apbs_req),
    .apbs_ack_async           (apbs_ack),
    .apbs_fwd_data_async      (apbs_fwd_data),
    .apbs_rev_data_async      (apbs_rev_data)
  );

  assign pslverr = pslverrm;
  assign pready  = preadym;
  assign prdata  = prdatam;
  assign pselm   = pselm_apb;



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
  

  assign ar_boundary_src_data = {
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


  assign ar_boundary_src_valid = arvalid_axi4_s;
  assign arready_axi4_s = ar_boundary_src_ready;

  assign ar_data = ar_boundary_dst_data;
  

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
          ruser_axi4_s,
          rlast_axi4_s} = r_data;

  assign r_boundary_dst_ready = rready_axi4_s;
  assign rvalid_axi4_s = r_boundary_dst_valid;





  assign {
          bid_axi4_s,
          bresp_axi4_s,
          buser_axi4_s} = b_data;

  assign b_boundary_dst_ready = bready_axi4_s;
  assign bvalid_axi4_s = b_boundary_dst_valid;




  nic400_ib_extsys1_axis_ib_aw_fifo_wr_sse710_main
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




  nic400_ib_extsys1_axis_ib_ar_fifo_wr_sse710_main
  u_ar_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (ar_boundary_src_valid),
     .src_data              (ar_boundary_src_data),
     .rpntr_gry             (ar_rpntr_gry),
     .rpntr_bin             (ar_rpntr_bin),

     .src_ready             (ar_boundary_src_ready),
     .dst_data              (ar_boundary_dst_data),
     .wpntr_gry             (ar_wpntr_gry)
     );




  nic400_ib_extsys1_axis_ib_r_fifo_rd_sse710_main
  u_r_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (r_boundary_dst_ready),
     .wpntr_gry             (r_wpntr_gry),

     .dst_valid             (r_boundary_dst_valid),
     .rpntr_gry             (r_rpntr_gry),
     .rpntr_bin             (r_rpntr_bin)
     );




  nic400_ib_extsys1_axis_ib_w_fifo_wr_sse710_main
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




  nic400_ib_extsys1_axis_ib_b_fifo_rd_sse710_main
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

`include "nic400_ib_extsys1_axis_ib_undefs_sse710_main.v"




