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



`include "nic400_asib_cvm_slave_if_defs_sse710_integration_example_f0_cvm.v"

module nic400_asib_cvm_slave_if_sse710_integration_example_f0_cvm
 (
  

    awid_cvm_slave_if_s,
    awaddr_cvm_slave_if_s,
    awlen_cvm_slave_if_s,
    awsize_cvm_slave_if_s,
    awburst_cvm_slave_if_s,
    awlock_cvm_slave_if_s,
    awcache_cvm_slave_if_s,
    awprot_cvm_slave_if_s,
    awvalid_cvm_slave_if_s,
    awready_cvm_slave_if_s,

    wdata_cvm_slave_if_s,
    wstrb_cvm_slave_if_s,
    wlast_cvm_slave_if_s,
    wvalid_cvm_slave_if_s,
    wready_cvm_slave_if_s,

    bid_cvm_slave_if_s,
    bresp_cvm_slave_if_s,
    bvalid_cvm_slave_if_s,
    bready_cvm_slave_if_s,

    arid_cvm_slave_if_s,
    araddr_cvm_slave_if_s,
    arlen_cvm_slave_if_s,
    arsize_cvm_slave_if_s,
    arburst_cvm_slave_if_s,
    arlock_cvm_slave_if_s,
    arcache_cvm_slave_if_s,
    arprot_cvm_slave_if_s,
    arvalid_cvm_slave_if_s,
    arready_cvm_slave_if_s,

    rid_cvm_slave_if_s,
    rdata_cvm_slave_if_s,
    rresp_cvm_slave_if_s,
    rlast_cvm_slave_if_s,
    rvalid_cvm_slave_if_s,
    rready_cvm_slave_if_s,


    awid_cvm_slave_if_m,
    awaddr_cvm_slave_if_m,
    awlen_cvm_slave_if_m,
    awsize_cvm_slave_if_m,
    awburst_cvm_slave_if_m,
    awlock_cvm_slave_if_m,
    awcache_cvm_slave_if_m,
    awprot_cvm_slave_if_m,
    awvalid_cvm_slave_if_m,
    awvalid_vect_cvm_slave_if_m,
    awready_cvm_slave_if_m,

    wdata_cvm_slave_if_m,
    wstrb_cvm_slave_if_m,
    wlast_cvm_slave_if_m,
    wvalid_cvm_slave_if_m,
    wready_cvm_slave_if_m,

    bid_cvm_slave_if_m,
    bresp_cvm_slave_if_m,
    bvalid_cvm_slave_if_m,
    bready_cvm_slave_if_m,

    arid_cvm_slave_if_m,
    araddr_cvm_slave_if_m,
    arlen_cvm_slave_if_m,
    arsize_cvm_slave_if_m,
    arburst_cvm_slave_if_m,
    arlock_cvm_slave_if_m,
    arcache_cvm_slave_if_m,
    arprot_cvm_slave_if_m,
    arvalid_cvm_slave_if_m,
    arvalid_vect_cvm_slave_if_m,
    arready_cvm_slave_if_m,

    rid_cvm_slave_if_m,
    rdata_cvm_slave_if_m,
    rresp_cvm_slave_if_m,
    rlast_cvm_slave_if_m,
    rvalid_cvm_slave_if_m,
    rready_cvm_slave_if_m,

    awqv_cvm_slave_if_m,
    arqv_cvm_slave_if_m,

    aclk,
    aresetn

  );




  


  input   [11:0]      awid_cvm_slave_if_s;              
  input   [31:0]      awaddr_cvm_slave_if_s;            
  input   [7:0]       awlen_cvm_slave_if_s;             
  input   [2:0]       awsize_cvm_slave_if_s;            
  input   [1:0]       awburst_cvm_slave_if_s;           
  input               awlock_cvm_slave_if_s;            
  input   [3:0]       awcache_cvm_slave_if_s;           
  input   [2:0]       awprot_cvm_slave_if_s;            
  input               awvalid_cvm_slave_if_s;           
  output              awready_cvm_slave_if_s;           

  input   [63:0]      wdata_cvm_slave_if_s;             
  input   [7:0]       wstrb_cvm_slave_if_s;             
  input               wlast_cvm_slave_if_s;             
  input               wvalid_cvm_slave_if_s;            
  output              wready_cvm_slave_if_s;            

  output  [11:0]      bid_cvm_slave_if_s;               
  output  [1:0]       bresp_cvm_slave_if_s;             
  output              bvalid_cvm_slave_if_s;            
  input               bready_cvm_slave_if_s;            

  input   [11:0]      arid_cvm_slave_if_s;              
  input   [31:0]      araddr_cvm_slave_if_s;            
  input   [7:0]       arlen_cvm_slave_if_s;             
  input   [2:0]       arsize_cvm_slave_if_s;            
  input   [1:0]       arburst_cvm_slave_if_s;           
  input               arlock_cvm_slave_if_s;            
  input   [3:0]       arcache_cvm_slave_if_s;           
  input   [2:0]       arprot_cvm_slave_if_s;            
  input               arvalid_cvm_slave_if_s;           
  output              arready_cvm_slave_if_s;           

  output  [11:0]      rid_cvm_slave_if_s;               
  output  [63:0]      rdata_cvm_slave_if_s;             
  output  [1:0]       rresp_cvm_slave_if_s;             
  output              rlast_cvm_slave_if_s;             
  output              rvalid_cvm_slave_if_s;            
  input               rready_cvm_slave_if_s;            



  output  [11:0]      awid_cvm_slave_if_m;              
  output  [31:0]      awaddr_cvm_slave_if_m;            
  output  [7:0]       awlen_cvm_slave_if_m;             
  output  [2:0]       awsize_cvm_slave_if_m;            
  output  [1:0]       awburst_cvm_slave_if_m;           
  output              awlock_cvm_slave_if_m;            
  output  [3:0]       awcache_cvm_slave_if_m;           
  output  [2:0]       awprot_cvm_slave_if_m;            
  output              awvalid_cvm_slave_if_m;           
  output  [1:0]       awvalid_vect_cvm_slave_if_m;      
  input               awready_cvm_slave_if_m;           

  output  [63:0]      wdata_cvm_slave_if_m;             
  output  [7:0]       wstrb_cvm_slave_if_m;             
  output              wlast_cvm_slave_if_m;             
  output              wvalid_cvm_slave_if_m;            
  input               wready_cvm_slave_if_m;            

  input   [11:0]      bid_cvm_slave_if_m;               
  input   [1:0]       bresp_cvm_slave_if_m;             
  input               bvalid_cvm_slave_if_m;            
  output              bready_cvm_slave_if_m;            

  output  [11:0]      arid_cvm_slave_if_m;              
  output  [31:0]      araddr_cvm_slave_if_m;            
  output  [7:0]       arlen_cvm_slave_if_m;             
  output  [2:0]       arsize_cvm_slave_if_m;            
  output  [1:0]       arburst_cvm_slave_if_m;           
  output              arlock_cvm_slave_if_m;            
  output  [3:0]       arcache_cvm_slave_if_m;           
  output  [2:0]       arprot_cvm_slave_if_m;            
  output              arvalid_cvm_slave_if_m;           
  output  [1:0]       arvalid_vect_cvm_slave_if_m;      
  input               arready_cvm_slave_if_m;           

  input   [11:0]      rid_cvm_slave_if_m;               
  input   [63:0]      rdata_cvm_slave_if_m;             
  input   [1:0]       rresp_cvm_slave_if_m;             
  input               rlast_cvm_slave_if_m;             
  input               rvalid_cvm_slave_if_m;            
  output              rready_cvm_slave_if_m;            

  output  [3:0]       awqv_cvm_slave_if_m;              
  output  [3:0]       arqv_cvm_slave_if_m;              

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
  wire [1:0]          awvalid_vector;            
  wire [1:0]          arvalid_vector;            
  wire                rvalid_maskcntl;
  wire                bvalid_master;
  wire                bready_master;

  wire                mask_w;
  wire                mask_r;


  wire                wr_cnt_empty;

  wire [3:0]          arcache_int_cvm_slave_if_m;
  wire [3:0]          awcache_int_cvm_slave_if_m;
  wire [2:0]          arprot_int_cvm_slave_if_m;
  wire [2:0]          awprot_int_cvm_slave_if_m;
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
  wire [11:0]         awid;
  wire [11:0]         bid;
  wire [11:0]         arid;
  wire [11:0]         rid;


  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;











  assign awid_cvm_slave_if_m = {awid};
  assign arid_cvm_slave_if_m = {arid};
  assign bid = bid_cvm_slave_if_m;
  assign rid = rid_cvm_slave_if_m;


  assign security63 = 1'b1;


  assign arvalid_int_m = arvalid_int_s;
  assign awvalid_int_m = awvalid_int_s;

  assign arready_int_s = arready_int_m;
  assign awready_int_s = awready_int_m;





  assign arvalid_cvm_slave_if_m = arvalid_int_m & cds_ar_enable & !mask_r;
  assign awvalid_cvm_slave_if_m = awvalid_int_m & cds_aw_enable & !mask_w;
  assign arready_int_m  = arready_cvm_slave_if_m & cds_ar_enable & !mask_r;
  assign awready_int_m  = awready_cvm_slave_if_m & cds_aw_enable & !mask_w;


  assign awaddr_int_m = awaddr_int_s;
  assign araddr_int_m = araddr_int_s;

  assign awaddr_cvm_slave_if_m = awaddr_int_m;
  assign araddr_cvm_slave_if_m = araddr_int_m;

  assign arprot_cvm_slave_if_m[2] = arprot_int_cvm_slave_if_m[2];
  assign arprot_cvm_slave_if_m[1] = 1'b0;
  assign arprot_cvm_slave_if_m[0] = arprot_int_cvm_slave_if_m[0];

  assign awprot_cvm_slave_if_m[2] = awprot_int_cvm_slave_if_m[2];
  assign awprot_cvm_slave_if_m[1] = 1'b0;
  assign awprot_cvm_slave_if_m[0] = awprot_int_cvm_slave_if_m[0];


  nic400_asib_cvm_slave_if_decode_sse710_integration_example_f0_cvm u_aw_add_decode
  (
    .addr_s                 (awaddr_int_s),
    .security63               (security63),
    .aprot                  (awprot_cvm_slave_if_m[1]),
    .acache_in              (awcache_int_cvm_slave_if_m),
    .acache_out             (awcache_cvm_slave_if_m),
    .avalid_int             (awvalid_vector)

  );

nic400_asib_cvm_slave_if_wr_ss_cdas_sse710_integration_example_f0_cvm u_asib_cvm_slave_if_wr_ss_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vector),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .wvalid                 (wvalid_cvm_slave_if_m),
    .wready                 (wready_cvm_slave_if_m),
    .wlast                  (wlast_cvm_slave_if_m),
    .resp_valid             (bvalid_cvm_slave_if_m),
    .resp_ready             (bready_cvm_slave_if_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_cvm_slave_if_decode_sse710_integration_example_f0_cvm u_ar_add_decode
  (
    .addr_s                 (araddr_int_s),
    .security63               (security63),
    .aprot                  (arprot_cvm_slave_if_m[1]),
    .acache_in              (arcache_int_cvm_slave_if_m),
    .acache_out             (arcache_cvm_slave_if_m),
    .avalid_int             (arvalid_vector)

  );

nic400_asib_cvm_slave_if_rd_ss_cdas_sse710_integration_example_f0_cvm u_asib_cvm_slave_if_rd_ss_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vector),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .resp_valid             (rvalid_cvm_slave_if_m),
    .resp_last              (rlast_cvm_slave_if_m),
    .resp_ready             (rready_cvm_slave_if_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_cvm_slave_if_maskcntl_sse710_integration_example_f0_cvm u_asib_cvm_slave_if_maskcntl (
      .awvalid_m    (awvalid_int_m),
      .arvalid_m    (arvalid_int_m),
      .awready_m    (awready_int_m),
      .arready_m    (arready_int_m),
      .bvalid_m     (bvalid_cvm_slave_if_m),
      .bready_m     (bready_cvm_slave_if_m),
      .rvalid_m     (rvalid_maskcntl),
      .rready_m     (rready_cvm_slave_if_m),

      .wr_cnt_empty (wr_cnt_empty),
      .mask_w       (mask_w),
      .mask_r       (mask_r),
      .aw_qos_m     (awqv_cvm_slave_if_m),
      .ar_qos_m     (arqv_cvm_slave_if_m),
      .aclk         (aclk),
      .aresetn      (aresetn)
      );

  assign rvalid_maskcntl = rvalid_cvm_slave_if_m & rlast_cvm_slave_if_m;

 

  assign bvalid_master = (bvalid_cvm_slave_if_m & ~wr_cnt_empty);
  assign bready_cvm_slave_if_m = (bready_master & ~wr_cnt_empty);



    
  assign awvalid_vect_cvm_slave_if_m = ({2{awvalid_cvm_slave_if_m}} & awvalid_vector);
  assign arvalid_vect_cvm_slave_if_m = ({2{arvalid_cvm_slave_if_m}} & arvalid_vector);
    

  assign aw_slave_port_src_data = {awid_cvm_slave_if_s,
          awaddr_cvm_slave_if_s,
          awlen_cvm_slave_if_s,
          awsize_cvm_slave_if_s,
          awburst_cvm_slave_if_s,
          awlock_cvm_slave_if_s,
          awcache_cvm_slave_if_s,
          awprot_cvm_slave_if_s};

  assign {awid,
          awaddr_int_s,
          awlen_cvm_slave_if_m,
          awsize_cvm_slave_if_m,
          awburst_cvm_slave_if_m,
          awlock_cvm_slave_if_m,
          awcache_int_cvm_slave_if_m,
          awprot_int_cvm_slave_if_m} = aw_slave_port_dst_data;



  assign awvalid_int_s = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_int_s;

  assign aw_slave_port_src_valid = awvalid_cvm_slave_if_s;
  assign awready_cvm_slave_if_s = aw_slave_port_src_ready;


  assign w_slave_port_src_data = {wdata_cvm_slave_if_s,
          wstrb_cvm_slave_if_s,
          wlast_cvm_slave_if_s};

  assign {wdata_cvm_slave_if_m,
          wstrb_cvm_slave_if_m,
          wlast_cvm_slave_if_m} = w_slave_port_dst_data;



  assign wvalid_cvm_slave_if_m = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_cvm_slave_if_m;

  assign w_slave_port_src_valid = wvalid_cvm_slave_if_s;
  assign wready_cvm_slave_if_s = w_slave_port_src_ready;


  assign ar_slave_port_src_data = {arid_cvm_slave_if_s,
          araddr_cvm_slave_if_s,
          arlen_cvm_slave_if_s,
          arsize_cvm_slave_if_s,
          arburst_cvm_slave_if_s,
          arlock_cvm_slave_if_s,
          arcache_cvm_slave_if_s,
          arprot_cvm_slave_if_s};

  assign {arid,
          araddr_int_s,
          arlen_cvm_slave_if_m,
          arsize_cvm_slave_if_m,
          arburst_cvm_slave_if_m,
          arlock_cvm_slave_if_m,
          arcache_int_cvm_slave_if_m,
          arprot_int_cvm_slave_if_m} = ar_slave_port_dst_data;



  assign arvalid_int_s = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_int_s;

  assign ar_slave_port_src_valid = arvalid_cvm_slave_if_s;
  assign arready_cvm_slave_if_s = ar_slave_port_src_ready;



  assign r_slave_port_src_data = {rid,
          rdata_cvm_slave_if_m,
          rresp_cvm_slave_if_m,
          rlast_cvm_slave_if_m};

  assign {rid_cvm_slave_if_s,
          rdata_cvm_slave_if_s,
          rresp_cvm_slave_if_s,
          rlast_cvm_slave_if_s} = r_slave_port_dst_data;


  assign r_slave_port_dst_data = r_slave_port_src_data;

  assign rvalid_cvm_slave_if_s = rvalid_cvm_slave_if_m;
  assign rready_cvm_slave_if_m = rready_cvm_slave_if_s;



  assign b_slave_port_src_data = {bid,
          bresp_cvm_slave_if_m};

  assign {bid_cvm_slave_if_s,
          bresp_cvm_slave_if_s} = b_slave_port_dst_data;


  assign b_slave_port_dst_data = b_slave_port_src_data;

  assign bvalid_cvm_slave_if_s = bvalid_master;
  assign bready_master = bready_cvm_slave_if_s;



  nic400_asib_cvm_slave_if_chan_slice_sse710_integration_example_f0_cvm
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




  nic400_asib_cvm_slave_if_chan_slice_sse710_integration_example_f0_cvm
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




  nic400_asib_cvm_slave_if_chan_slice_sse710_integration_example_f0_cvm
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
        .test_expr ( {2{arvalid_int_m}} & arvalid_vector )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot during ARVALID")
      ovl_arvalid_vect_one_hot_when_arvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( arvalid_int_m & ~|arvalid_vector )
      );

  assert_zero_one_hot
    #(`OVL_FATAL, 2, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot zero")
      ovl_awvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {2{awvalid_int_m}} & awvalid_vector )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot during AWVALID")
      ovl_awvalid_vect_one_hot_when_awvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( awvalid_int_m & ~|awvalid_vector )
      );


`endif


endmodule

`include "nic400_asib_cvm_slave_if_undefs_sse710_integration_example_f0_cvm.v"



