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


`include "nic400_ib_slave_if0_0_m_ib_defs_sse710_boot_reg.v"


module nic400_ib_slave_if0_0_m_ib_slave_domain_sse710_boot_reg
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


    a_data_async,
    a_rpntr_gry_async,
    a_rpntr_bin,
    a_wpntr_gry_async,

    d_data_async,
    d_rpntr_gry_async,
    d_rpntr_bin,
    d_wpntr_gry_async,

    w_data_async,
    w_rpntr_gry_async,
    w_rpntr_bin,
    w_wpntr_gry_async,
    empty_async,

    aclk_s,
    aresetn_s

  );



  


  input   [9:0]       awid_axi4_s;                          
  input   [31:0]      awaddr_axi4_s;                        
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

  output  [9:0]       bid_axi4_s;                           
  output  [1:0]       bresp_axi4_s;                         
  output              bvalid_axi4_s;                        
  input               bready_axi4_s;                        

  input   [9:0]       arid_axi4_s;                          
  input   [31:0]      araddr_axi4_s;                        
  input   [7:0]       arlen_axi4_s;                         
  input   [2:0]       arsize_axi4_s;                        
  input   [1:0]       arburst_axi4_s;                       
  input               arlock_axi4_s;                        
  input   [3:0]       arcache_axi4_s;                       
  input   [2:0]       arprot_axi4_s;                        
  input               arvalid_axi4_s;                       
  output              arready_axi4_s;                       

  output  [9:0]       rid_axi4_s;                           
  output  [31:0]      rdata_axi4_s;                         
  output  [1:0]       rresp_axi4_s;                         
  output              rlast_axi4_s;                         
  output              rvalid_axi4_s;                        
  input               rready_axi4_s;                        



  output  [63:0]      a_data_async;                         
  input   [1:0]       a_rpntr_gry_async;                    
  input               a_rpntr_bin;                          
  output  [1:0]       a_wpntr_gry_async;                    

  input   [45:0]      d_data_async;                         
  output  [1:0]       d_rpntr_gry_async;                    
  output              d_rpntr_bin;                          
  input   [1:0]       d_wpntr_gry_async;                    

  output  [36:0]      w_data_async;                         
  input   [1:0]       w_rpntr_gry_async;                    
  input               w_rpntr_bin;                          
  output  [1:0]       w_wpntr_gry_async;                    
  output              empty_async;                          

  input               aclk_s;                               
  input               aresetn_s;                            
   


  
  wire                a_boundary_src_valid;
  wire                a_boundary_src_ready;

  wire [63:0]         a_boundary_src_data;     
  wire [63:0]         a_boundary_dst_data;     


  
  wire                w_boundary_src_valid;
  wire                w_boundary_src_ready;

  wire [36:0]         w_boundary_src_data;     
  wire [36:0]         w_boundary_dst_data;     


  
  wire                d_boundary_dst_valid;
  wire                d_boundary_dst_ready;

  wire [45:0]         d_boundary_dst_data;     


  wire [1:0]          a_rpntr_gry_async;             
  wire                a_rpntr_bin;             
  wire [1:0]          a_wpntr_gry_async;             
  
  wire [1:0]          w_rpntr_gry_async;             
  wire                w_rpntr_bin;             
  wire [1:0]          w_wpntr_gry_async;             
  
  wire [1:0]          d_rpntr_gry_async;             
  wire                d_rpntr_bin;             
  wire [1:0]          d_wpntr_gry_async;             


  wire                awrite_iif;
  wire                avalid_iif;
  wire [31:0]         aaddr_iif;
  wire [7:0]          alen_iif;
  wire [2:0]          asize_iif;
  wire [1:0]          aburst_iif;
  wire           alock_iif;
  wire [3:0]          acache_iif;
  wire [2:0]          aprot_iif;
  wire [9:0]          aid_iif;
  wire                aready_iif;

  wire                dbnr_iif;
  wire                dvalid_iif;
  wire                dlast_iif;
  wire [31:0]         ddata_iif;
  wire [1:0]          dresp_iif;
  wire [9:0]          did_iif;
  wire                dready_iif;
  wire                empty_boundary;
  wire                empty;
  wire                a_valid;
  wire                w_valid;  
 
  wire                empty_a;
  wire                empty_w;






  nic400_ib_slave_if0_0_m_ib_axi_to_itb_sse710_boot_reg u_axi_to_itb
  (
    .awid           (awid_axi4_s),
    .awaddr         (awaddr_axi4_s),
    .awlen          (awlen_axi4_s),
    .awsize         (awsize_axi4_s),
    .awburst        (awburst_axi4_s),
    .awlock         (awlock_axi4_s),
    .awcache        (awcache_axi4_s),
    .awprot         (awprot_axi4_s),
    .awvalid        (awvalid_axi4_s),
    .awready        (awready_axi4_s),

    
    .bid            (bid_axi4_s),
    .bresp          (bresp_axi4_s),
    .bvalid         (bvalid_axi4_s),
    .bready         (bready_axi4_s),
    
    .arid           (arid_axi4_s),
    .araddr         (araddr_axi4_s),
    .arlen          (arlen_axi4_s),
    .arsize         (arsize_axi4_s),
    .arburst        (arburst_axi4_s),
    .arlock         (arlock_axi4_s),
    .arcache        (arcache_axi4_s),
    .arprot         (arprot_axi4_s),
    .arvalid        (arvalid_axi4_s),
    .arready        (arready_axi4_s),
    
    .rid            (rid_axi4_s),
    .rdata          (rdata_axi4_s),
    .rresp          (rresp_axi4_s),
    .rlast          (rlast_axi4_s),
    .rvalid         (rvalid_axi4_s),
    .rready         (rready_axi4_s),

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

    .aclk           (aclk_s),
    .aresetn        (aresetn_s)
  );






  assign a_boundary_src_data = {
          aid_iif,
          awrite_iif,
          aaddr_iif,
          alen_iif,
          asize_iif,
          aburst_iif,
          alock_iif,
          acache_iif,
          aprot_iif};


  assign a_boundary_src_valid = avalid_iif;
  assign aready_iif = a_boundary_src_ready;

  assign a_data_async = a_boundary_dst_data;
  

  assign w_boundary_src_data = {
          wdata_axi4_s,
          wstrb_axi4_s,
          wlast_axi4_s};


  assign w_boundary_src_valid = wvalid_axi4_s;
  assign wready_axi4_s = w_boundary_src_ready;

  assign w_data_async = w_boundary_dst_data;
  

  assign empty_boundary = 1'b1 & empty_a & empty_w;


  assign empty = ~(empty_boundary);


  nic400_cdc_launch_gry_sse710_boot_reg #(1) u_cdc_launch_empty_ptr_gry
   (
      .clk       (aclk_s),
      .resetn    (aresetn_s),
      .enable    (1'b1),
      .in_cdc    (empty),
      .out_async (empty_async));



  assign {
          did_iif,
          dbnr_iif,
          ddata_iif,
          dresp_iif,
          dlast_iif} = d_boundary_dst_data;

  assign d_boundary_dst_ready = dready_iif;
  assign dvalid_iif = d_boundary_dst_valid;




  nic400_ib_slave_if0_0_m_ib_a_fifo_wr_sse710_boot_reg
  u_a_fifo_wr
    (
     .wresetn               (aresetn_s),
     .wclk                  (aclk_s),
     .empty                 (empty_a),

     .src_valid             (a_boundary_src_valid),
     .src_data              (a_boundary_src_data),
     .rpntr_gry_async       (a_rpntr_gry_async),
     .rpntr_bin             (a_rpntr_bin),

     .src_ready             (a_boundary_src_ready),
     .dst_data              (a_boundary_dst_data),
     .wpntr_gry_async       (a_wpntr_gry_async)
     );




  nic400_ib_slave_if0_0_m_ib_w_fifo_wr_sse710_boot_reg
  u_w_fifo_wr
    (
     .wresetn               (aresetn_s),
     .wclk                  (aclk_s),
     .empty                 (empty_w),

     .src_valid             (w_boundary_src_valid),
     .src_data              (w_boundary_src_data),
     .rpntr_gry_async       (w_rpntr_gry_async),
     .rpntr_bin             (w_rpntr_bin),

     .src_ready             (w_boundary_src_ready),
     .dst_data              (w_boundary_dst_data),
     .wpntr_gry_async       (w_wpntr_gry_async)
     );




  nic400_ib_slave_if0_0_m_ib_d_fifo_rd_sse710_boot_reg
  u_d_fifo_rd
    (
     .rresetn               (aresetn_s),
     .rclk                  (aclk_s),
     .src_data              (d_data_async),
     .dst_ready             (d_boundary_dst_ready),
     .wpntr_gry_async       (d_wpntr_gry_async),

     .dst_data              (d_boundary_dst_data),
     .dst_valid             (d_boundary_dst_valid),
     .rpntr_gry_async       (d_rpntr_gry_async),
     .rpntr_bin             (d_rpntr_bin)
     );



    


endmodule

`include "nic400_ib_slave_if0_0_m_ib_undefs_sse710_boot_reg.v"




