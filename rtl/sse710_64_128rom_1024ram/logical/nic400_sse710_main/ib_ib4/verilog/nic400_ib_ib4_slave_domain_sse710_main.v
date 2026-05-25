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


`include "nic400_ib_ib4_defs_sse710_main.v"
`include "Axi.v"

module nic400_ib_ib4_slave_domain_sse710_main
  (
  

    awid_axi_s_0,
    awaddr_axi_s_0,
    awlen_axi_s_0,
    awsize_axi_s_0,
    awburst_axi_s_0,
    awlock_axi_s_0,
    awcache_axi_s_0,
    awprot_axi_s_0,
    awvalid_axi_s_0,
    awvalid_vect_axi_s_0,
    awready_axi_s_0,

    wdata_axi_s_0,
    wstrb_axi_s_0,
    wlast_axi_s_0,
    wvalid_axi_s_0,
    wready_axi_s_0,

    bid_axi_s_0,
    bresp_axi_s_0,
    bvalid_axi_s_0,
    bready_axi_s_0,

    arid_axi_s_0,
    araddr_axi_s_0,
    arlen_axi_s_0,
    arsize_axi_s_0,
    arburst_axi_s_0,
    arlock_axi_s_0,
    arcache_axi_s_0,
    arprot_axi_s_0,
    arvalid_axi_s_0,
    arvalid_vect_axi_s_0,
    arready_axi_s_0,

    rid_axi_s_0,
    rdata_axi_s_0,
    rresp_axi_s_0,
    rlast_axi_s_0,
    rvalid_axi_s_0,
    rready_axi_s_0,

    awuser_axi_s_0,
    buser_axi_s_0,
    aruser_axi_s_0,
    ruser_axi_s_0,

    awqv_axi_s_0,
    arqv_axi_s_0,


    aw_data,
    aw_valid,
    aw_ready,

    b_data,
    b_valid,
    b_ready,

    ar_data,
    ar_valid,
    ar_ready,

    r_data,
    r_valid,
    r_ready,

    w_data,
    w_valid,
    w_ready,

    aclk,
    aresetn

  );



  


  input   [11:0]      awid_axi_s_0;              
  input   [39:0]      awaddr_axi_s_0;            
  input   [7:0]       awlen_axi_s_0;             
  input   [2:0]       awsize_axi_s_0;            
  input   [1:0]       awburst_axi_s_0;           
  input               awlock_axi_s_0;            
  input   [3:0]       awcache_axi_s_0;           
  input   [2:0]       awprot_axi_s_0;            
  input               awvalid_axi_s_0;           
  input   [3:0]       awvalid_vect_axi_s_0;      
  output              awready_axi_s_0;           

  input   [63:0]      wdata_axi_s_0;             
  input   [7:0]       wstrb_axi_s_0;             
  input               wlast_axi_s_0;             
  input               wvalid_axi_s_0;            
  output              wready_axi_s_0;            

  output  [11:0]      bid_axi_s_0;               
  output  [1:0]       bresp_axi_s_0;             
  output              bvalid_axi_s_0;            
  input               bready_axi_s_0;            

  input   [11:0]      arid_axi_s_0;              
  input   [39:0]      araddr_axi_s_0;            
  input   [7:0]       arlen_axi_s_0;             
  input   [2:0]       arsize_axi_s_0;            
  input   [1:0]       arburst_axi_s_0;           
  input               arlock_axi_s_0;            
  input   [3:0]       arcache_axi_s_0;           
  input   [2:0]       arprot_axi_s_0;            
  input               arvalid_axi_s_0;           
  input   [3:0]       arvalid_vect_axi_s_0;      
  output              arready_axi_s_0;           

  output  [11:0]      rid_axi_s_0;               
  output  [63:0]      rdata_axi_s_0;             
  output  [1:0]       rresp_axi_s_0;             
  output              rlast_axi_s_0;             
  output              rvalid_axi_s_0;            
  input               rready_axi_s_0;            

  input   [9:0]       awuser_axi_s_0;            
  output              buser_axi_s_0;             
  input   [9:0]       aruser_axi_s_0;            
  output              ruser_axi_s_0;             

  input   [3:0]       awqv_axi_s_0;              
  input   [3:0]       arqv_axi_s_0;              



  output  [91:0]      aw_data;                   
  output              aw_valid;                  
  input               aw_ready;                  

  input   [14:0]      b_data;                    
  input               b_valid;                   
  output              b_ready;                   

  output  [102:0]     ar_data;                   
  output              ar_valid;                  
  input               ar_ready;                  

  input   [81:0]      r_data;                    
  input               r_valid;                   
  output              r_ready;                   

  output  [72:0]      w_data;                    
  output              w_valid;                   
  input               w_ready;                   

  input               aclk;                      
  input               aresetn;                   
   


  
  wire [90:0]         aw_slave_port_src_data;     
  wire [90:0]         aw_slave_port_dst_data;     

  wire                aw_slave_port_dst_valid;
  wire                aw_slave_port_dst_ready;
  wire                aw_slave_port_src_valid;
  wire                aw_slave_port_src_ready;

  
  wire [90:0]         ar_slave_port_src_data;     
  wire [90:0]         ar_slave_port_dst_data;     

  wire                ar_slave_port_dst_valid;
  wire                ar_slave_port_dst_ready;
  wire                ar_slave_port_src_valid;
  wire                ar_slave_port_src_ready;

  
  wire [79:0]         r_slave_port_src_data;     
  wire [79:0]         r_slave_port_dst_data;     

  wire                r_slave_port_dst_valid;
  wire                r_slave_port_dst_ready;
  wire                r_slave_port_src_valid;
  wire                r_slave_port_src_ready;

  
  wire [72:0]         w_slave_port_src_data;     
  wire [72:0]         w_slave_port_dst_data;     

  wire                w_slave_port_dst_valid;
  wire                w_slave_port_dst_ready;
  wire                w_slave_port_src_valid;
  wire                w_slave_port_src_ready;

  
  wire [14:0]         b_slave_port_src_data;     
  wire [14:0]         b_slave_port_dst_data;     

  wire                b_slave_port_dst_valid;
  wire                b_slave_port_dst_ready;
  wire                b_slave_port_src_valid;
  wire                b_slave_port_src_ready;



  wire [15:0]         bdata_data;
  wire                bdata_valid;
  wire                bdata_ready;

  wire [10:0]         awdata_data;
  wire                awdata_valid;
  wire                awdata_ready;

  wire                merge;
  wire                merge_clear;
  wire [1:0]          data_select;
  wire                strb_skid_valid;

  wire [63:0]         wdata_merged;
  wire [7:0]          wstrb_merged;
  wire [11:0]         arfmt_data;
  wire [1:0]          rbeats;
  
  wire                downsize;  
  wire  [90:0]        aw_fmt_src_data;
  wire  [90:0]        ar_fmt_src_data;
  wire  [90:0]        aw_fmt_dst_data;
  wire  [90:0]        ar_fmt_dst_data;




  wire [11:0]         awid_bif;
  wire [39:0]         awaddr_bif;
  wire [7:0]          awlen_bif;
  wire [2:0]          awsize_bif;
  wire [1:0]          awburst_bif;
  wire           awlock_bif;
  wire [3:0]          awcache_bif;
  wire [9:0]          awuser_bif;
  wire [2:0]          awprot_bif;
  wire                awvalid_bif;
  wire [3:0]          awvalid_vect_bif;
  wire                awready_bif;
  wire [3:0]          awqv_bif;

  wire [11:0]         arid_bif;
  wire [39:0]         araddr_bif;
  wire [7:0]          arlen_bif;
  wire [2:0]          arsize_bif;
  wire [1:0]          arburst_bif;
  wire           arlock_bif;
  wire [3:0]          arcache_bif;
  wire [9:0]          aruser_bif;
  wire [2:0]          arprot_bif;
  wire                arvalid_bif;
  wire [3:0]          arvalid_vect_bif;
  wire                arready_bif;
  wire [3:0]          arqv_bif;
  wire                wvalid_bif;
  wire                wready_bif;
  wire [63:0]         wdata_bif;
  wire [7:0]          wstrb_bif;
  wire                wlast_bif;
  wire [11:0]         bid_bif;
  wire [1:0]          bresp_bif;
  wire                buser_bif;
  wire                bvalid_bif;
  wire                bready_bif;

  wire [11:0]         rid_bif;
  wire [1:0]          rresp_bif;
  wire [63:0]         rdata_bif;
  wire                ruser_bif;
  wire                rlast_bif;
  wire                rvalid_bif;
  wire                rready_bif;


  wire                arvalid_fmt;
  wire [3:0]          arvalid_vect_fmt;
  wire [39:0]         araddr_fmt;
  wire [7:0]          arlen_fmt;
  wire [2:0]          arsize_fmt;
  wire [1:0]          arburst_fmt;
  wire           arlock_fmt;
  wire [3:0]          arcache_fmt;
  wire [2:0]          arprot_fmt;
  wire [11:0]         arid_fmt;
  wire                arready_fmt;
  wire [9:0]          aruser_fmt;
  wire [3:0]          arqv_fmt;
  wire                awvalid_fmt;
  wire [3:0]          awvalid_vect_fmt;
  wire [39:0]         awaddr_fmt;
  wire [7:0]          awlen_fmt;
  wire [2:0]          awsize_fmt;
  wire [1:0]          awburst_fmt;
  wire           awlock_fmt;
  wire [3:0]          awcache_fmt;
  wire [2:0]          awprot_fmt;
  wire [11:0]         awid_fmt;
  wire                awready_fmt;
  wire [9:0]          awuser_fmt;
  wire [3:0]          awqv_fmt;


  wire                arvalid_axi_r;
  wire [3:0]          arvalid_vect_axi_r;
  wire [39:0]         araddr_axi_r;
  wire [7:0]          arlen_axi_r;
  wire [2:0]          arsize_axi_r;
  wire [1:0]          arburst_axi_r;
  wire           arlock_axi_r;
  wire [3:0]          arcache_axi_r;
  wire [2:0]          arprot_axi_r;
  wire [11:0]         arid_axi_r;
  wire                arready_axi_r;
  wire [9:0]          aruser_axi_r;
  wire [3:0]          arqv_axi_r;

  wire                awvalid_axi_r;
  wire [3:0]          awvalid_vect_axi_r;
  wire [39:0]         awaddr_axi_r;
  wire [7:0]          awlen_axi_r;
  wire [2:0]          awsize_axi_r;
  wire [1:0]          awburst_axi_r;
  wire           awlock_axi_r;
  wire [3:0]          awcache_axi_r;
  wire [2:0]          awprot_axi_r;
  wire [11:0]         awid_axi_r;
  wire                awready_axi_r;
  wire [9:0]          awuser_axi_r;
  wire [3:0]          awqv_axi_r;


  wire                rvalid_axi_r;
  wire                rlast_axi_r;
  wire [63:0]         rdata_axi_r;
  wire [1:0]          rresp_axi_r;
  wire [11:0]         rid_axi_r;
  wire                rready_axi_r;
  wire                ruser_axi_r;

  wire                wvalid_axi_r;
  wire                wlast_axi_r;
  wire [63:0]         wdata_axi_r;
  wire [7:0]          wstrb_axi_r;
  wire                wready_axi_r;

  wire                bvalid_axi_r;
  wire [1:0]          bresp_axi_r;
  wire [11:0]         bid_axi_r;
  wire                bready_axi_r;
  wire                buser_axi_r;





  assign aw_fmt_src_data = {
          awid_axi_r,
          awaddr_axi_r[39:0],
          awlen_axi_r,
          awsize_axi_r,
          awburst_axi_r,
          awlock_axi_r,
          awcache_axi_r,
          awuser_axi_r,
          awqv_axi_r,
          awprot_axi_r,
          awvalid_vect_axi_r};


  assign awvalid_fmt  = awvalid_axi_r;
  assign awready_axi_r = awready_fmt;
  assign aw_fmt_dst_data  = aw_fmt_src_data;


  assign {
          awid_fmt,
          awaddr_fmt[39:0],
          awlen_fmt,
          awsize_fmt,
          awburst_fmt,
          awlock_fmt,
          awcache_fmt,
          awuser_fmt,
          awqv_fmt,
          awprot_fmt,
          awvalid_vect_fmt} = aw_fmt_dst_data;

  nic400_ib_ib4_downsize_wr_addr_fmt_sse710_main u_axi_write_address_format
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    

    .bdata_data                       (bdata_data),
    .bdata_valid                      (bdata_valid),
    .bdata_ready                      (bdata_ready),

    .awfmt_valid                      (awdata_valid),
    .awfmt_ready                      (awdata_ready),
    .awfmt_data                       (awdata_data),

    .awid_s                           (awid_fmt),
    .awaddr_s                         (awaddr_fmt),
    .awlen_s                          (awlen_fmt),
    .awsize_s                         (awsize_fmt),
    .awburst_s                        (awburst_fmt),
    .awvalid_s                        (awvalid_fmt),
    .awready_s                        (awready_fmt),
    .awprot_s                         (awprot_fmt),
    .awcache_s                        (awcache_fmt),
    .awlock_s                         (awlock_fmt),
    .awuser_s                         (awuser_fmt),

    .awid_m                           (awid_bif),
    .awaddr_m                         (awaddr_bif),
    .awlen_m                          (awlen_bif),
    .awsize_m                         (awsize_bif),
    .awburst_m                        (awburst_bif),
    .awvalid_m                        (awvalid_bif),
    .awready_m                        (awready_bif),
    .awprot_m                         (awprot_bif),
    .awlock_m                         (awlock_bif),
    .awuser_m                         (awuser_bif),
    .awcache_m                        (awcache_bif),
    .downsize_m                       (downsize)
  );
  
  
  assign awvalid_vect_bif = awvalid_vect_fmt;
  assign awqv_bif = awqv_fmt;


nic400_ib_ib4_downsize_wr_cntrl_sse710_main u_downsize_axi_write_control
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .awfifo_valid                     (awdata_valid),
    .awfifo_ready                     (awdata_ready),
    .awfifo_data                      (awdata_data),

    .wvalid_s                         (wvalid_axi_r),
    .wready_s                         (wready_axi_r),
    .wlast                            (wlast_axi_r),

    .merge                            (merge),
    .merge_clear                      (merge_clear),
    .data_select                      (data_select),
    .strb_skid_valid                  (strb_skid_valid),

    .wdata_merged                     (wdata_merged),
    .wstrb_merged                     (wstrb_merged),

    .wvalid_m                         (wvalid_bif),
    .wready_m                         (wready_bif),
    .wlast_m                          (wlast_bif),
    .wdata_m                          (wdata_bif),
    .wstrb_m                          (wstrb_bif)
  );



  nic400_ib_ib4_downsize_wr_merge_buffer_sse710_main u_downsize_axi_write_merge_buffer
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .wdata_out                        (wdata_merged),
    .wstrb_out                        (wstrb_merged),

    .wdata_in                         (wdata_axi_r),
    .wstrb_in                         (wstrb_axi_r),

    .data_select                      (data_select),
    .merge_skid_valid                 (strb_skid_valid),
    .merge                            (merge),
    .merge_clear                      (merge_clear)
  );



  nic400_ib_ib4_downsize_wr_resp_block_sse710_main u_downsize_axi_write_response_block
  (

  .aclk                               (aclk),
  .aresetn                            (aresetn),

  .bchannel_ready                     (bdata_ready),
  .bchannel_valid                     (bdata_valid),
  .bchannel_data                      (bdata_data),

  .bready_s                           (bready_axi_r),
  .bvalid_s                           (bvalid_axi_r),
  .buser_s                            (buser_axi_r),
  .bid_s                              (bid_axi_r),
  .bresp_s                            (bresp_axi_r),

  .bresp_m                            (bresp_bif),
  .bid_m                              (bid_bif),
  .buser_m                            (buser_bif),
  .bvalid_m                           (bvalid_bif),
  .bready_m                           (bready_bif)

  );


  assign ar_fmt_src_data = {
          arid_axi_r,
          araddr_axi_r[39:0],
          arlen_axi_r,
          arsize_axi_r,
          arburst_axi_r,
          arlock_axi_r,
          arcache_axi_r,
          aruser_axi_r,
          arqv_axi_r,
          arprot_axi_r,
          arvalid_vect_axi_r};



  assign arvalid_fmt  = arvalid_axi_r;
  assign arready_axi_r = arready_fmt;
  assign ar_fmt_dst_data  = ar_fmt_src_data;


  assign {
          arid_fmt,
          araddr_fmt[39:0],
          arlen_fmt,
          arsize_fmt,
          arburst_fmt,
          arlock_fmt,
          arcache_fmt,
          aruser_fmt,
          arqv_fmt,
          arprot_fmt,
          arvalid_vect_fmt} = ar_fmt_dst_data;



  nic400_ib_ib4_downsize_rd_addr_fmt_sse710_main u_axi_read_address_format
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    

    .arid_s                           (arid_fmt),
    .araddr_s                         (araddr_fmt),
    .arlen_s                          (arlen_fmt),
    .arsize_s                         (arsize_fmt),
    .arburst_s                        (arburst_fmt),
    .arvalid_s                        (arvalid_fmt),
    .arready_s                        (arready_fmt),
    .arprot_s                         (arprot_fmt),
    .arcache_s                        (arcache_fmt),
    .arlock_s                         (arlock_fmt),
    .aruser_s                         (aruser_fmt),

    .arid_m                           (arid_bif),
    .araddr_m                         (araddr_bif),
    .arlen_m                          (arlen_bif),
    .arsize_m                         (arsize_bif),
    .arburst_m                        (arburst_bif),
    .arvalid_m                        (arvalid_bif),
    .arready_m                        (arready_bif),
    .arprot_m                         (arprot_bif),
    .aruser_m                         (aruser_bif),
    .arlock_m                         (arlock_bif),
    .arcache_m                        (arcache_bif),
    .arfmt_data                       (arfmt_data)
  );

  assign arvalid_vect_bif = arvalid_vect_fmt;
  assign arqv_bif         = arqv_fmt;

  nic400_ib_ib4_downsize_rd_cntrl_sse710_main u_downsize_read_control
  (
     .aresetn                        (aresetn),
     .aclk                           (aclk),

     .rready_s                       (rready_axi_r),

     .rbeats                         (rbeats),
     .rvalid_m                       (rvalid_bif),
     .rlast_m                        (rlast_bif),

     .rvalid_s                       (rvalid_axi_r),
     .rlast_s                        (rlast_axi_r),

     .rready_m                       (rready_bif)
   );






  assign aw_data = {
          awid_bif,
          awaddr_bif,
          awlen_bif,
          awsize_bif,
          awburst_bif,
          awlock_bif,
          awcache_bif,
          awuser_bif,
          awqv_bif,
          awprot_bif,
          awvalid_vect_bif,downsize};


  assign aw_valid = awvalid_bif;

  assign awready_bif = aw_ready;


  assign ar_data = {
          arid_bif,
          araddr_bif,
          arlen_bif,
          arsize_bif,
          arburst_bif,
          arlock_bif,
          arcache_bif,
          aruser_bif,
          arqv_bif,
          arprot_bif,
          arvalid_vect_bif,arfmt_data};


  assign ar_valid = arvalid_bif;

  assign arready_bif = ar_ready;


  assign w_data = {
          wdata_bif,
          wstrb_bif,
          wlast_bif};


  assign w_valid = wvalid_bif;

  assign wready_bif = w_ready;



  assign {
          rid_bif,
          rdata_bif,
          rresp_bif,
          ruser_bif,
          rlast_bif,rbeats} = r_data;

  assign r_ready = rready_bif;
  assign rvalid_bif = r_valid;



  assign rid_axi_r = rid_bif;
  assign rdata_axi_r = rdata_bif;
  assign rresp_axi_r = rresp_bif;
  assign ruser_axi_r = ruser_bif;


  assign {
          bid_bif,
          bresp_bif,
          buser_bif} = b_data;

  assign b_ready = bready_bif;
  assign bvalid_bif = b_valid;





  assign aw_slave_port_src_data = {
          awid_axi_s_0,
          awaddr_axi_s_0[39:0],
          awlen_axi_s_0,
          awsize_axi_s_0,
          awburst_axi_s_0,
          awlock_axi_s_0,
          awcache_axi_s_0,
          awuser_axi_s_0,
          awqv_axi_s_0,
          awprot_axi_s_0,
          awvalid_vect_axi_s_0};

  assign {
          awid_axi_r,
          awaddr_axi_r[39:0],
          awlen_axi_r,
          awsize_axi_r,
          awburst_axi_r,
          awlock_axi_r,
          awcache_axi_r,
          awuser_axi_r,
          awqv_axi_r,
          awprot_axi_r,
          awvalid_vect_axi_r} = aw_slave_port_dst_data;


  assign awvalid_axi_r = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_axi_r;

  assign aw_slave_port_src_valid = awvalid_axi_s_0;
  assign awready_axi_s_0 = aw_slave_port_src_ready;



  assign ar_slave_port_src_data = {
          arid_axi_s_0,
          araddr_axi_s_0[39:0],
          arlen_axi_s_0,
          arsize_axi_s_0,
          arburst_axi_s_0,
          arlock_axi_s_0,
          arcache_axi_s_0,
          aruser_axi_s_0,
          arqv_axi_s_0,
          arprot_axi_s_0,
          arvalid_vect_axi_s_0};

  assign {
          arid_axi_r,
          araddr_axi_r[39:0],
          arlen_axi_r,
          arsize_axi_r,
          arburst_axi_r,
          arlock_axi_r,
          arcache_axi_r,
          aruser_axi_r,
          arqv_axi_r,
          arprot_axi_r,
          arvalid_vect_axi_r} = ar_slave_port_dst_data;


  assign arvalid_axi_r = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_axi_r;

  assign ar_slave_port_src_valid = arvalid_axi_s_0;
  assign arready_axi_s_0 = ar_slave_port_src_ready;



  assign r_slave_port_src_data = {
          rid_axi_r,
          rdata_axi_r,
          rresp_axi_r,
          ruser_axi_r,
          rlast_axi_r};

  assign {
          rid_axi_s_0,
          rdata_axi_s_0,
          rresp_axi_s_0,
          ruser_axi_s_0,
          rlast_axi_s_0} = r_slave_port_dst_data;


  assign rvalid_axi_s_0 = r_slave_port_dst_valid;
  assign r_slave_port_dst_ready = rready_axi_s_0;

  assign r_slave_port_src_valid = rvalid_axi_r;
  assign rready_axi_r = r_slave_port_src_ready;



  assign w_slave_port_src_data = {
          wdata_axi_s_0,
          wstrb_axi_s_0,
          wlast_axi_s_0};

  assign {
          wdata_axi_r,
          wstrb_axi_r,
          wlast_axi_r} = w_slave_port_dst_data;


  assign wvalid_axi_r = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_axi_r;

  assign w_slave_port_src_valid = wvalid_axi_s_0;
  assign wready_axi_s_0 = w_slave_port_src_ready;



  assign b_slave_port_src_data = {
          bid_axi_r,
          bresp_axi_r,
          buser_axi_r};

  assign {
          bid_axi_s_0,
          bresp_axi_s_0,
          buser_axi_s_0} = b_slave_port_dst_data;


  assign bvalid_axi_s_0 = b_slave_port_dst_valid;
  assign b_slave_port_dst_ready = bready_axi_s_0;

  assign b_slave_port_src_valid = bvalid_axi_r;
  assign bready_axi_r = b_slave_port_src_ready;


  nic400_ib_ib4_chan_slice_sse710_main
    #(
       `RS_REGD,  
       91  
     )
  u_aw_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (aw_slave_port_src_valid),
     .src_data              (aw_slave_port_src_data),
     .dst_ready             (aw_slave_port_dst_ready),

     .src_ready             (aw_slave_port_src_ready),
     .dst_data              (aw_slave_port_dst_data),
     .dst_valid             (aw_slave_port_dst_valid)
     );




  nic400_ib_ib4_chan_slice_sse710_main
    #(
       `RS_REGD,  
       91  
     )
  u_ar_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (ar_slave_port_src_valid),
     .src_data              (ar_slave_port_src_data),
     .dst_ready             (ar_slave_port_dst_ready),

     .src_ready             (ar_slave_port_src_ready),
     .dst_data              (ar_slave_port_dst_data),
     .dst_valid             (ar_slave_port_dst_valid)
     );




  nic400_ib_ib4_chan_slice_sse710_main
    #(
       `RS_REGD,  
       80  
     )
  u_r_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (r_slave_port_src_valid),
     .src_data              (r_slave_port_src_data),
     .dst_ready             (r_slave_port_dst_ready),

     .src_ready             (r_slave_port_src_ready),
     .dst_data              (r_slave_port_dst_data),
     .dst_valid             (r_slave_port_dst_valid)
     );




  nic400_ib_ib4_chan_slice_sse710_main
    #(
       `RS_REGD,  
       73  
     )
  u_w_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (w_slave_port_src_valid),
     .src_data              (w_slave_port_src_data),
     .dst_ready             (w_slave_port_dst_ready),

     .src_ready             (w_slave_port_src_ready),
     .dst_data              (w_slave_port_dst_data),
     .dst_valid             (w_slave_port_dst_valid)
     );




  nic400_ib_ib4_chan_slice_sse710_main
    #(
       `RS_REGD,  
       15  
     )
  u_b_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (b_slave_port_src_valid),
     .src_data              (b_slave_port_src_data),
     .dst_ready             (b_slave_port_dst_ready),

     .src_ready             (b_slave_port_src_ready),
     .dst_data              (b_slave_port_dst_data),
     .dst_valid             (b_slave_port_dst_valid)
     );



    
    
    
    
    



`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"



   
`endif

endmodule

`include "nic400_ib_ib4_undefs_sse710_main.v"
`include "Axi_undefs.v"



