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


`include "nic400_ib_gpv_0_ib1_defs_sse710_main.v"


module nic400_ib_gpv_0_ib1_slave_domain_sse710_main
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
    arready_axi4_s,

    rid_axi4_s,
    rdata_axi4_s,
    rresp_axi4_s,
    rlast_axi4_s,
    rvalid_axi4_s,
    rready_axi4_s,


    a_data,
    a_valid,
    a_ready,

    d_data,
    d_valid,
    d_ready,

    w_data,
    w_valid,
    w_ready,

    aclk,
    aresetn

  );



  


  input   [11:0]      awid_axi4_s;         
  input   [39:0]      awaddr_axi4_s;       
  input   [7:0]       awlen_axi4_s;        
  input   [2:0]       awsize_axi4_s;       
  input   [1:0]       awburst_axi4_s;      
  input               awlock_axi4_s;       
  input   [3:0]       awcache_axi4_s;      
  input   [2:0]       awprot_axi4_s;       
  input               awvalid_axi4_s;      
  output              awready_axi4_s;      

  input   [31:0]      wdata_axi4_s;        
  input   [3:0]       wstrb_axi4_s;        
  input               wlast_axi4_s;        
  input               wvalid_axi4_s;       
  output              wready_axi4_s;       

  output  [11:0]      bid_axi4_s;          
  output  [1:0]       bresp_axi4_s;        
  output              bvalid_axi4_s;       
  input               bready_axi4_s;       

  input   [11:0]      arid_axi4_s;         
  input   [39:0]      araddr_axi4_s;       
  input   [7:0]       arlen_axi4_s;        
  input   [2:0]       arsize_axi4_s;       
  input   [1:0]       arburst_axi4_s;      
  input               arlock_axi4_s;       
  input   [3:0]       arcache_axi4_s;      
  input   [2:0]       arprot_axi4_s;       
  input               arvalid_axi4_s;      
  output              arready_axi4_s;      

  output  [11:0]      rid_axi4_s;          
  output  [31:0]      rdata_axi4_s;        
  output  [1:0]       rresp_axi4_s;        
  output              rlast_axi4_s;        
  output              rvalid_axi4_s;       
  input               rready_axi4_s;       



  output  [73:0]      a_data;              
  output              a_valid;             
  input               a_ready;             

  input   [47:0]      d_data;              
  input               d_valid;             
  output              d_ready;             

  output  [36:0]      w_data;              
  output              w_valid;             
  input               w_ready;             

  input               aclk;                
  input               aresetn;             
   


  
  wire [72:0]         aw_slave_port_src_data;     
  wire [72:0]         aw_slave_port_dst_data;     

  wire                aw_slave_port_dst_valid;
  wire                aw_slave_port_dst_ready;
  wire                aw_slave_port_src_valid;
  wire                aw_slave_port_src_ready;

  
  wire [72:0]         ar_slave_port_src_data;     
  wire [72:0]         ar_slave_port_dst_data;     

  wire                ar_slave_port_dst_valid;
  wire                ar_slave_port_dst_ready;
  wire                ar_slave_port_src_valid;
  wire                ar_slave_port_src_ready;

  wire [46:0]         r_slave_port_src_data;     
  wire [46:0]         r_slave_port_dst_data;     

  wire [36:0]         w_slave_port_src_data;     
  wire [36:0]         w_slave_port_dst_data;     

  wire [13:0]         b_slave_port_src_data;     
  wire [13:0]         b_slave_port_dst_data;     



  wire                awrite_iif;
  wire                avalid_iif;
  wire [39:0]         aaddr_iif;
  wire [7:0]          alen_iif;
  wire [2:0]          asize_iif;
  wire [1:0]          aburst_iif;
  wire           alock_iif;
  wire [3:0]          acache_iif;
  wire [2:0]          aprot_iif;
  wire [11:0]         aid_iif;
  wire                aready_iif;

  wire                dbnr_iif;
  wire                dvalid_iif;
  wire                dlast_iif;
  wire [31:0]         ddata_iif;
  wire [1:0]          dresp_iif;
  wire [11:0]         did_iif;
  wire                dready_iif;


  wire                arvalid_axi_r;
  wire [39:0]         araddr_axi_r;
  wire [7:0]          arlen_axi_r;
  wire [2:0]          arsize_axi_r;
  wire [1:0]          arburst_axi_r;
  wire           arlock_axi_r;
  wire [3:0]          arcache_axi_r;
  wire [2:0]          arprot_axi_r;
  wire [11:0]         arid_axi_r;
  wire                arready_axi_r;

  wire                awvalid_axi_r;
  wire [39:0]         awaddr_axi_r;
  wire [7:0]          awlen_axi_r;
  wire [2:0]          awsize_axi_r;
  wire [1:0]          awburst_axi_r;
  wire           awlock_axi_r;
  wire [3:0]          awcache_axi_r;
  wire [2:0]          awprot_axi_r;
  wire [11:0]         awid_axi_r;
  wire                awready_axi_r;


  wire                rvalid_axi_r;
  wire                rlast_axi_r;
  wire [31:0]         rdata_axi_r;
  wire [1:0]          rresp_axi_r;
  wire [11:0]         rid_axi_r;
  wire                rready_axi_r;

  wire                wvalid_axi_r;
  wire                wlast_axi_r;
  wire [31:0]         wdata_axi_r;
  wire [3:0]          wstrb_axi_r;
  wire                wready_axi_r;

  wire                bvalid_axi_r;
  wire [1:0]          bresp_axi_r;
  wire [11:0]         bid_axi_r;
  wire                bready_axi_r;






  nic400_ib_gpv_0_ib1_axi_to_itb_sse710_main u_axi_to_itb
  (
    .awid           (awid_axi_r),
    .awaddr         (awaddr_axi_r),
    .awlen          (awlen_axi_r),
    .awsize         (awsize_axi_r),
    .awburst        (awburst_axi_r),
    .awlock         (awlock_axi_r),
    .awcache        (awcache_axi_r),
    .awprot         (awprot_axi_r),
    .awvalid        (awvalid_axi_r),
    .awready        (awready_axi_r),

    
    .bid            (bid_axi_r),
    .bresp          (bresp_axi_r),
    .bvalid         (bvalid_axi_r),
    .bready         (bready_axi_r),
    
    .arid           (arid_axi_r),
    .araddr         (araddr_axi_r),
    .arlen          (arlen_axi_r),
    .arsize         (arsize_axi_r),
    .arburst        (arburst_axi_r),
    .arlock         (arlock_axi_r),
    .arcache        (arcache_axi_r),
    .arprot         (arprot_axi_r),
    .arvalid        (arvalid_axi_r),
    .arready        (arready_axi_r),
    
    .rid            (rid_axi_r),
    .rdata          (rdata_axi_r),
    .rresp          (rresp_axi_r),
    .rlast          (rlast_axi_r),
    .rvalid         (rvalid_axi_r),
    .rready         (rready_axi_r),

    .awrite         (awrite_iif),
    .aid            (aid_iif),
    .aaddr          (aaddr_iif),
    .alen           (alen_iif),
    .asize          (asize_iif),
    .aburst         (aburst_iif),
    .alock          (alock_iif),
    .acache         (acache_iif),
    .aprot          (aprot_iif),
    .avalid         (avalid_iif),
    .aready         (aready_iif),

    .dbnr           (dbnr_iif),
    .did            (did_iif),
    .ddata          (ddata_iif),
    .dresp          (dresp_iif),
    .dlast          (dlast_iif),
    .dvalid         (dvalid_iif),
    .dready         (dready_iif),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );






  assign w_data = {
          wdata_axi_r,
          wstrb_axi_r,
          wlast_axi_r};


  assign w_valid = wvalid_axi_r;

  assign wready_axi_r = w_ready;


  assign a_data = {
          aid_iif,
          awrite_iif,
          aaddr_iif,
          alen_iif,
          asize_iif,
          aburst_iif,
          alock_iif,
          acache_iif,
          aprot_iif};


  assign a_valid = avalid_iif;

  assign aready_iif = a_ready;



  assign {
          did_iif,
          dbnr_iif,
          ddata_iif,
          dresp_iif,
          dlast_iif} = d_data;

  assign d_ready = dready_iif;
  assign dvalid_iif = d_valid;





  assign aw_slave_port_src_data = {
          awid_axi4_s,
          awaddr_axi4_s[39:0],
          awlen_axi4_s,
          awsize_axi4_s,
          awburst_axi4_s,
          awlock_axi4_s,
          awcache_axi4_s,
          awprot_axi4_s};

  assign {
          awid_axi_r,
          awaddr_axi_r[39:0],
          awlen_axi_r,
          awsize_axi_r,
          awburst_axi_r,
          awlock_axi_r,
          awcache_axi_r,
          awprot_axi_r} = aw_slave_port_dst_data;


  assign awvalid_axi_r = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_axi_r;

  assign aw_slave_port_src_valid = awvalid_axi4_s;
  assign awready_axi4_s = aw_slave_port_src_ready;



  assign ar_slave_port_src_data = {
          arid_axi4_s,
          araddr_axi4_s[39:0],
          arlen_axi4_s,
          arsize_axi4_s,
          arburst_axi4_s,
          arlock_axi4_s,
          arcache_axi4_s,
          arprot_axi4_s};

  assign {
          arid_axi_r,
          araddr_axi_r[39:0],
          arlen_axi_r,
          arsize_axi_r,
          arburst_axi_r,
          arlock_axi_r,
          arcache_axi_r,
          arprot_axi_r} = ar_slave_port_dst_data;


  assign arvalid_axi_r = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_axi_r;

  assign ar_slave_port_src_valid = arvalid_axi4_s;
  assign arready_axi4_s = ar_slave_port_src_ready;




  assign r_slave_port_src_data = {
          rid_axi_r,
          rdata_axi_r,
          rresp_axi_r,
          rlast_axi_r};

  assign {
          rid_axi4_s,
          rdata_axi4_s,
          rresp_axi4_s,
          rlast_axi4_s} = r_slave_port_dst_data;


  assign r_slave_port_dst_data = r_slave_port_src_data;

  assign rvalid_axi4_s = rvalid_axi_r;
  assign rready_axi_r = rready_axi4_s;




  assign w_slave_port_src_data = {
          wdata_axi4_s,
          wstrb_axi4_s,
          wlast_axi4_s};

  assign {
          wdata_axi_r,
          wstrb_axi_r,
          wlast_axi_r} = w_slave_port_dst_data;


  assign w_slave_port_dst_data = w_slave_port_src_data;

  assign wvalid_axi_r = wvalid_axi4_s;
  assign wready_axi4_s = wready_axi_r;




  assign b_slave_port_src_data = {
          bid_axi_r,
          bresp_axi_r};

  assign {
          bid_axi4_s,
          bresp_axi4_s} = b_slave_port_dst_data;


  assign b_slave_port_dst_data = b_slave_port_src_data;

  assign bvalid_axi4_s = bvalid_axi_r;
  assign bready_axi_r = bready_axi4_s;


  nic400_ib_gpv_0_ib1_chan_slice_sse710_main
    #(
       `RS_REV_REG,  
       73  
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




  nic400_ib_gpv_0_ib1_chan_slice_sse710_main
    #(
       `RS_REV_REG,  
       73  
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



    
    
    
    
    
    
    


endmodule

`include "nic400_ib_gpv_0_ib1_undefs_sse710_main.v"




