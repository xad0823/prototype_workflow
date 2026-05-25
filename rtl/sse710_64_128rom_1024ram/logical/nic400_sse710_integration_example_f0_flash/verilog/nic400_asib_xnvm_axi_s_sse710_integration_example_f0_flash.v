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



`include "nic400_asib_xnvm_axi_s_defs_sse710_integration_example_f0_flash.v"

module nic400_asib_xnvm_axi_s_sse710_integration_example_f0_flash
 (
  

    awid_xnvm_axi_s_s,
    awaddr_xnvm_axi_s_s,
    awlen_xnvm_axi_s_s,
    awsize_xnvm_axi_s_s,
    awburst_xnvm_axi_s_s,
    awlock_xnvm_axi_s_s,
    awcache_xnvm_axi_s_s,
    awprot_xnvm_axi_s_s,
    awvalid_xnvm_axi_s_s,
    awready_xnvm_axi_s_s,

    wdata_xnvm_axi_s_s,
    wstrb_xnvm_axi_s_s,
    wlast_xnvm_axi_s_s,
    wvalid_xnvm_axi_s_s,
    wready_xnvm_axi_s_s,

    bid_xnvm_axi_s_s,
    bresp_xnvm_axi_s_s,
    bvalid_xnvm_axi_s_s,
    bready_xnvm_axi_s_s,

    arid_xnvm_axi_s_s,
    araddr_xnvm_axi_s_s,
    arlen_xnvm_axi_s_s,
    arsize_xnvm_axi_s_s,
    arburst_xnvm_axi_s_s,
    arlock_xnvm_axi_s_s,
    arcache_xnvm_axi_s_s,
    arprot_xnvm_axi_s_s,
    arvalid_xnvm_axi_s_s,
    arready_xnvm_axi_s_s,

    rid_xnvm_axi_s_s,
    rdata_xnvm_axi_s_s,
    rresp_xnvm_axi_s_s,
    rlast_xnvm_axi_s_s,
    rvalid_xnvm_axi_s_s,
    rready_xnvm_axi_s_s,


    awid_xnvm_axi_s_m,
    awaddr_xnvm_axi_s_m,
    awlen_xnvm_axi_s_m,
    awsize_xnvm_axi_s_m,
    awburst_xnvm_axi_s_m,
    awlock_xnvm_axi_s_m,
    awcache_xnvm_axi_s_m,
    awprot_xnvm_axi_s_m,
    awvalid_xnvm_axi_s_m,
    awvalid_vect_xnvm_axi_s_m,
    awready_xnvm_axi_s_m,

    wdata_xnvm_axi_s_m,
    wstrb_xnvm_axi_s_m,
    wlast_xnvm_axi_s_m,
    wvalid_xnvm_axi_s_m,
    wready_xnvm_axi_s_m,

    bid_xnvm_axi_s_m,
    bresp_xnvm_axi_s_m,
    bvalid_xnvm_axi_s_m,
    bready_xnvm_axi_s_m,

    arid_xnvm_axi_s_m,
    araddr_xnvm_axi_s_m,
    arlen_xnvm_axi_s_m,
    arsize_xnvm_axi_s_m,
    arburst_xnvm_axi_s_m,
    arlock_xnvm_axi_s_m,
    arcache_xnvm_axi_s_m,
    arprot_xnvm_axi_s_m,
    arvalid_xnvm_axi_s_m,
    arvalid_vect_xnvm_axi_s_m,
    arready_xnvm_axi_s_m,

    rid_xnvm_axi_s_m,
    rdata_xnvm_axi_s_m,
    rresp_xnvm_axi_s_m,
    rlast_xnvm_axi_s_m,
    rvalid_xnvm_axi_s_m,
    rready_xnvm_axi_s_m,

    aclk,
    aresetn

  );




  


  input   [11:0]      awid_xnvm_axi_s_s;              
  input   [31:0]      awaddr_xnvm_axi_s_s;            
  input   [7:0]       awlen_xnvm_axi_s_s;             
  input   [2:0]       awsize_xnvm_axi_s_s;            
  input   [1:0]       awburst_xnvm_axi_s_s;           
  input               awlock_xnvm_axi_s_s;            
  input   [3:0]       awcache_xnvm_axi_s_s;           
  input   [2:0]       awprot_xnvm_axi_s_s;            
  input               awvalid_xnvm_axi_s_s;           
  output              awready_xnvm_axi_s_s;           

  input   [63:0]      wdata_xnvm_axi_s_s;             
  input   [7:0]       wstrb_xnvm_axi_s_s;             
  input               wlast_xnvm_axi_s_s;             
  input               wvalid_xnvm_axi_s_s;            
  output              wready_xnvm_axi_s_s;            

  output  [11:0]      bid_xnvm_axi_s_s;               
  output  [1:0]       bresp_xnvm_axi_s_s;             
  output              bvalid_xnvm_axi_s_s;            
  input               bready_xnvm_axi_s_s;            

  input   [11:0]      arid_xnvm_axi_s_s;              
  input   [31:0]      araddr_xnvm_axi_s_s;            
  input   [7:0]       arlen_xnvm_axi_s_s;             
  input   [2:0]       arsize_xnvm_axi_s_s;            
  input   [1:0]       arburst_xnvm_axi_s_s;           
  input               arlock_xnvm_axi_s_s;            
  input   [3:0]       arcache_xnvm_axi_s_s;           
  input   [2:0]       arprot_xnvm_axi_s_s;            
  input               arvalid_xnvm_axi_s_s;           
  output              arready_xnvm_axi_s_s;           

  output  [11:0]      rid_xnvm_axi_s_s;               
  output  [63:0]      rdata_xnvm_axi_s_s;             
  output  [1:0]       rresp_xnvm_axi_s_s;             
  output              rlast_xnvm_axi_s_s;             
  output              rvalid_xnvm_axi_s_s;            
  input               rready_xnvm_axi_s_s;            



  output  [11:0]      awid_xnvm_axi_s_m;              
  output  [31:0]      awaddr_xnvm_axi_s_m;            
  output  [7:0]       awlen_xnvm_axi_s_m;             
  output  [2:0]       awsize_xnvm_axi_s_m;            
  output  [1:0]       awburst_xnvm_axi_s_m;           
  output              awlock_xnvm_axi_s_m;            
  output  [3:0]       awcache_xnvm_axi_s_m;           
  output  [2:0]       awprot_xnvm_axi_s_m;            
  output              awvalid_xnvm_axi_s_m;           
  output  [1:0]       awvalid_vect_xnvm_axi_s_m;      
  input               awready_xnvm_axi_s_m;           

  output  [63:0]      wdata_xnvm_axi_s_m;             
  output  [7:0]       wstrb_xnvm_axi_s_m;             
  output              wlast_xnvm_axi_s_m;             
  output              wvalid_xnvm_axi_s_m;            
  input               wready_xnvm_axi_s_m;            

  input   [11:0]      bid_xnvm_axi_s_m;               
  input   [1:0]       bresp_xnvm_axi_s_m;             
  input               bvalid_xnvm_axi_s_m;            
  output              bready_xnvm_axi_s_m;            

  output  [11:0]      arid_xnvm_axi_s_m;              
  output  [31:0]      araddr_xnvm_axi_s_m;            
  output  [7:0]       arlen_xnvm_axi_s_m;             
  output  [2:0]       arsize_xnvm_axi_s_m;            
  output  [1:0]       arburst_xnvm_axi_s_m;           
  output              arlock_xnvm_axi_s_m;            
  output  [3:0]       arcache_xnvm_axi_s_m;           
  output  [2:0]       arprot_xnvm_axi_s_m;            
  output              arvalid_xnvm_axi_s_m;           
  output  [1:0]       arvalid_vect_xnvm_axi_s_m;      
  input               arready_xnvm_axi_s_m;           

  input   [11:0]      rid_xnvm_axi_s_m;               
  input   [63:0]      rdata_xnvm_axi_s_m;             
  input   [1:0]       rresp_xnvm_axi_s_m;             
  input               rlast_xnvm_axi_s_m;             
  input               rvalid_xnvm_axi_s_m;            
  output              rready_xnvm_axi_s_m;            

  input               aclk;                           
  input               aresetn;                        



  


  wire           aw_slave_port_dst_valid;
  wire           aw_slave_port_dst_ready;
  wire           aw_slave_port_src_valid;
  wire           aw_slave_port_src_ready;

  wire [64:0]    aw_slave_port_src_data;     
  wire [64:0]    aw_slave_port_dst_data;     

  wire           w_slave_port_dst_valid;
  wire           w_slave_port_dst_ready;
  wire           w_slave_port_src_valid;
  wire           w_slave_port_src_ready;

  wire [72:0]    w_slave_port_src_data;     
  wire [72:0]    w_slave_port_dst_data;     

  wire           ar_slave_port_dst_valid;
  wire           ar_slave_port_dst_ready;
  wire           ar_slave_port_src_valid;
  wire           ar_slave_port_src_ready;

  wire [64:0]    ar_slave_port_src_data;     
  wire [64:0]    ar_slave_port_dst_data;     

  wire [78:0]    r_slave_port_src_data;     
  wire [78:0]    r_slave_port_dst_data;     

  wire [13:0]    b_slave_port_src_data;     
  wire [13:0]    b_slave_port_dst_data;     

  wire                security63;
  wire [1:0]          awvalid_vect_xnvm_axi_s_m;            
  wire [1:0]          arvalid_vect_xnvm_axi_s_m;            
  wire [3:0]          arcache_int_xnvm_axi_s_m;
  wire [3:0]          awcache_int_xnvm_axi_s_m;
  wire [2:0]          arprot_int_xnvm_axi_s_m;
  wire [2:0]          awprot_int_xnvm_axi_s_m;
  wire                arready_int_m;
  wire                awready_int_m;
  wire                arvalid_int_m;
  wire                awvalid_int_m;
  wire                arready_int_s;
  wire                awready_int_s;
  wire                arvalid_int_s;
  wire                awvalid_int_s;
  wire [31:0]         awaddr_int_s;
  wire [31:0]         araddr_int_s;
  wire [31:0]         awaddr_int_m;
  wire [31:0]         araddr_int_m;
  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;



  assign security63 = 1'b0;


  assign arvalid_int_m = arvalid_int_s;
  assign awvalid_int_m = awvalid_int_s;

  assign arready_int_s = arready_int_m;
  assign awready_int_s = awready_int_m;



  assign arvalid_xnvm_axi_s_m = arvalid_int_m & cds_ar_enable;
  assign awvalid_xnvm_axi_s_m = awvalid_int_m & cds_aw_enable;
  assign arready_int_m  = arready_xnvm_axi_s_m & cds_ar_enable;
  assign awready_int_m  = awready_xnvm_axi_s_m & cds_aw_enable;

  assign awaddr_int_m = awaddr_int_s;
  assign araddr_int_m = araddr_int_s;

  assign awaddr_xnvm_axi_s_m = awaddr_int_m;
  assign araddr_xnvm_axi_s_m = araddr_int_m;

  assign arprot_xnvm_axi_s_m[2] = arprot_int_xnvm_axi_s_m[2];
  assign arprot_xnvm_axi_s_m[1] = 1'b0;
  assign arprot_xnvm_axi_s_m[0] = arprot_int_xnvm_axi_s_m[0];

  assign awprot_xnvm_axi_s_m[2] = awprot_int_xnvm_axi_s_m[2];
  assign awprot_xnvm_axi_s_m[1] = 1'b0;
  assign awprot_xnvm_axi_s_m[0] = awprot_int_xnvm_axi_s_m[0];


  nic400_asib_xnvm_axi_s_decode_sse710_integration_example_f0_flash u_aw_add_decode
  (
    .addr_s                 (awaddr_int_s),
    .security63               (security63),
    .aprot                  (awprot_xnvm_axi_s_m[1]),
    .acache_in              (awcache_int_xnvm_axi_s_m),
    .acache_out             (awcache_xnvm_axi_s_m),
    .avalid_int             (awvalid_vect_xnvm_axi_s_m)

  );

nic400_asib_xnvm_axi_s_wr_ss_cdas_sse710_integration_example_f0_flash u_asib_xnvm_axi_s_wr_ss_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vect_xnvm_axi_s_m),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .wvalid                 (wvalid_xnvm_axi_s_m),
    .wready                 (wready_xnvm_axi_s_m),
    .wlast                  (wlast_xnvm_axi_s_m),
    .resp_valid             (bvalid_xnvm_axi_s_m),
    .resp_ready             (bready_xnvm_axi_s_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_xnvm_axi_s_decode_sse710_integration_example_f0_flash u_ar_add_decode
  (
    .addr_s                 (araddr_int_s),
    .security63               (security63),
    .aprot                  (arprot_xnvm_axi_s_m[1]),
    .acache_in              (arcache_int_xnvm_axi_s_m),
    .acache_out             (arcache_xnvm_axi_s_m),
    .avalid_int             (arvalid_vect_xnvm_axi_s_m)

  );

nic400_asib_xnvm_axi_s_rd_ss_cdas_sse710_integration_example_f0_flash u_asib_xnvm_axi_s_rd_ss_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vect_xnvm_axi_s_m),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .resp_valid             (rvalid_xnvm_axi_s_m),
    .resp_last              (rlast_xnvm_axi_s_m),
    .resp_ready             (rready_xnvm_axi_s_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );


  assign aw_slave_port_src_data = {awid_xnvm_axi_s_s,
          awaddr_xnvm_axi_s_s,
          awlen_xnvm_axi_s_s,
          awsize_xnvm_axi_s_s,
          awburst_xnvm_axi_s_s,
          awlock_xnvm_axi_s_s,
          awcache_xnvm_axi_s_s,
          awprot_xnvm_axi_s_s};

  assign {awid_xnvm_axi_s_m,
          awaddr_int_s,
          awlen_xnvm_axi_s_m,
          awsize_xnvm_axi_s_m,
          awburst_xnvm_axi_s_m,
          awlock_xnvm_axi_s_m,
          awcache_int_xnvm_axi_s_m,
          awprot_int_xnvm_axi_s_m} = aw_slave_port_dst_data;



  assign awvalid_int_s = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_int_s;

  assign aw_slave_port_src_valid = awvalid_xnvm_axi_s_s;
  assign awready_xnvm_axi_s_s = aw_slave_port_src_ready;


  assign w_slave_port_src_data = {wdata_xnvm_axi_s_s,
          wstrb_xnvm_axi_s_s,
          wlast_xnvm_axi_s_s};

  assign {wdata_xnvm_axi_s_m,
          wstrb_xnvm_axi_s_m,
          wlast_xnvm_axi_s_m} = w_slave_port_dst_data;



  assign wvalid_xnvm_axi_s_m = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_xnvm_axi_s_m;

  assign w_slave_port_src_valid = wvalid_xnvm_axi_s_s;
  assign wready_xnvm_axi_s_s = w_slave_port_src_ready;


  assign ar_slave_port_src_data = {arid_xnvm_axi_s_s,
          araddr_xnvm_axi_s_s,
          arlen_xnvm_axi_s_s,
          arsize_xnvm_axi_s_s,
          arburst_xnvm_axi_s_s,
          arlock_xnvm_axi_s_s,
          arcache_xnvm_axi_s_s,
          arprot_xnvm_axi_s_s};

  assign {arid_xnvm_axi_s_m,
          araddr_int_s,
          arlen_xnvm_axi_s_m,
          arsize_xnvm_axi_s_m,
          arburst_xnvm_axi_s_m,
          arlock_xnvm_axi_s_m,
          arcache_int_xnvm_axi_s_m,
          arprot_int_xnvm_axi_s_m} = ar_slave_port_dst_data;



  assign arvalid_int_s = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_int_s;

  assign ar_slave_port_src_valid = arvalid_xnvm_axi_s_s;
  assign arready_xnvm_axi_s_s = ar_slave_port_src_ready;



  assign r_slave_port_src_data = {rid_xnvm_axi_s_m,
          rdata_xnvm_axi_s_m,
          rresp_xnvm_axi_s_m,
          rlast_xnvm_axi_s_m};

  assign {rid_xnvm_axi_s_s,
          rdata_xnvm_axi_s_s,
          rresp_xnvm_axi_s_s,
          rlast_xnvm_axi_s_s} = r_slave_port_dst_data;


  assign r_slave_port_dst_data = r_slave_port_src_data;

  assign rvalid_xnvm_axi_s_s = rvalid_xnvm_axi_s_m;
  assign rready_xnvm_axi_s_m = rready_xnvm_axi_s_s;



  assign b_slave_port_src_data = {bid_xnvm_axi_s_m,
          bresp_xnvm_axi_s_m};

  assign {bid_xnvm_axi_s_s,
          bresp_xnvm_axi_s_s} = b_slave_port_dst_data;


  assign b_slave_port_dst_data = b_slave_port_src_data;

  assign bvalid_xnvm_axi_s_s = bvalid_xnvm_axi_s_m;
  assign bready_xnvm_axi_s_m = bready_xnvm_axi_s_s;



  nic400_asib_xnvm_axi_s_chan_slice_sse710_integration_example_f0_flash
    #(
       `RS_REV_REG,  
       65  
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




  nic400_asib_xnvm_axi_s_chan_slice_sse710_integration_example_f0_flash
    #(
       `RS_REV_REG,  
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




  nic400_asib_xnvm_axi_s_chan_slice_sse710_integration_example_f0_flash
    #(
       `RS_REV_REG,  
       65  
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









`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"



  assert_zero_one_hot
    #(`OVL_FATAL, 2, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot zero")
      ovl_arvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {2{arvalid_int_m}} & arvalid_vect_xnvm_axi_s_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot during ARVALID")
      ovl_arvalid_vect_one_hot_when_arvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( arvalid_int_m & ~|arvalid_vect_xnvm_axi_s_m )
      );

  assert_zero_one_hot
    #(`OVL_FATAL, 2, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot zero")
      ovl_awvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {2{awvalid_int_m}} & awvalid_vect_xnvm_axi_s_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot during AWVALID")
      ovl_awvalid_vect_one_hot_when_awvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( awvalid_int_m & ~|awvalid_vect_xnvm_axi_s_m )
      );


`endif


endmodule

`include "nic400_asib_xnvm_axi_s_undefs_sse710_integration_example_f0_flash.v"



