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



`include "nic400_asib_hostexpmst_0_s_defs_sse710_integration_example_f0_host_exp.v"

module nic400_asib_hostexpmst_0_s_sse710_integration_example_f0_host_exp
 (
  

    awid_hostexpmst_0_s_s,
    awaddr_hostexpmst_0_s_s,
    awlen_hostexpmst_0_s_s,
    awsize_hostexpmst_0_s_s,
    awburst_hostexpmst_0_s_s,
    awlock_hostexpmst_0_s_s,
    awcache_hostexpmst_0_s_s,
    awprot_hostexpmst_0_s_s,
    awvalid_hostexpmst_0_s_s,
    awready_hostexpmst_0_s_s,

    wdata_hostexpmst_0_s_s,
    wstrb_hostexpmst_0_s_s,
    wlast_hostexpmst_0_s_s,
    wvalid_hostexpmst_0_s_s,
    wready_hostexpmst_0_s_s,

    bid_hostexpmst_0_s_s,
    bresp_hostexpmst_0_s_s,
    bvalid_hostexpmst_0_s_s,
    bready_hostexpmst_0_s_s,

    arid_hostexpmst_0_s_s,
    araddr_hostexpmst_0_s_s,
    arlen_hostexpmst_0_s_s,
    arsize_hostexpmst_0_s_s,
    arburst_hostexpmst_0_s_s,
    arlock_hostexpmst_0_s_s,
    arcache_hostexpmst_0_s_s,
    arprot_hostexpmst_0_s_s,
    arvalid_hostexpmst_0_s_s,
    arready_hostexpmst_0_s_s,

    rid_hostexpmst_0_s_s,
    rdata_hostexpmst_0_s_s,
    rresp_hostexpmst_0_s_s,
    rlast_hostexpmst_0_s_s,
    rvalid_hostexpmst_0_s_s,
    rready_hostexpmst_0_s_s,


    awid_hostexpmst_0_s_m,
    awaddr_hostexpmst_0_s_m,
    awlen_hostexpmst_0_s_m,
    awsize_hostexpmst_0_s_m,
    awburst_hostexpmst_0_s_m,
    awlock_hostexpmst_0_s_m,
    awcache_hostexpmst_0_s_m,
    awprot_hostexpmst_0_s_m,
    awvalid_hostexpmst_0_s_m,
    awvalid_vect_hostexpmst_0_s_m,
    awregion_hostexpmst_0_s_m,
    awready_hostexpmst_0_s_m,

    wdata_hostexpmst_0_s_m,
    wstrb_hostexpmst_0_s_m,
    wlast_hostexpmst_0_s_m,
    wvalid_hostexpmst_0_s_m,
    wready_hostexpmst_0_s_m,

    bid_hostexpmst_0_s_m,
    bresp_hostexpmst_0_s_m,
    bvalid_hostexpmst_0_s_m,
    bready_hostexpmst_0_s_m,

    arid_hostexpmst_0_s_m,
    araddr_hostexpmst_0_s_m,
    arlen_hostexpmst_0_s_m,
    arsize_hostexpmst_0_s_m,
    arburst_hostexpmst_0_s_m,
    arlock_hostexpmst_0_s_m,
    arcache_hostexpmst_0_s_m,
    arprot_hostexpmst_0_s_m,
    arvalid_hostexpmst_0_s_m,
    arvalid_vect_hostexpmst_0_s_m,
    arregion_hostexpmst_0_s_m,
    arready_hostexpmst_0_s_m,

    rid_hostexpmst_0_s_m,
    rdata_hostexpmst_0_s_m,
    rresp_hostexpmst_0_s_m,
    rlast_hostexpmst_0_s_m,
    rvalid_hostexpmst_0_s_m,
    rready_hostexpmst_0_s_m,

    awqv_hostexpmst_0_s_m,
    arqv_hostexpmst_0_s_m,

    aclk,
    aresetn

  );




  


  input   [15:0]      awid_hostexpmst_0_s_s;              
  input   [31:0]      awaddr_hostexpmst_0_s_s;            
  input   [7:0]       awlen_hostexpmst_0_s_s;             
  input   [2:0]       awsize_hostexpmst_0_s_s;            
  input   [1:0]       awburst_hostexpmst_0_s_s;           
  input               awlock_hostexpmst_0_s_s;            
  input   [3:0]       awcache_hostexpmst_0_s_s;           
  input   [2:0]       awprot_hostexpmst_0_s_s;            
  input               awvalid_hostexpmst_0_s_s;           
  output              awready_hostexpmst_0_s_s;           

  input   [63:0]      wdata_hostexpmst_0_s_s;             
  input   [7:0]       wstrb_hostexpmst_0_s_s;             
  input               wlast_hostexpmst_0_s_s;             
  input               wvalid_hostexpmst_0_s_s;            
  output              wready_hostexpmst_0_s_s;            

  output  [15:0]      bid_hostexpmst_0_s_s;               
  output  [1:0]       bresp_hostexpmst_0_s_s;             
  output              bvalid_hostexpmst_0_s_s;            
  input               bready_hostexpmst_0_s_s;            

  input   [15:0]      arid_hostexpmst_0_s_s;              
  input   [31:0]      araddr_hostexpmst_0_s_s;            
  input   [7:0]       arlen_hostexpmst_0_s_s;             
  input   [2:0]       arsize_hostexpmst_0_s_s;            
  input   [1:0]       arburst_hostexpmst_0_s_s;           
  input               arlock_hostexpmst_0_s_s;            
  input   [3:0]       arcache_hostexpmst_0_s_s;           
  input   [2:0]       arprot_hostexpmst_0_s_s;            
  input               arvalid_hostexpmst_0_s_s;           
  output              arready_hostexpmst_0_s_s;           

  output  [15:0]      rid_hostexpmst_0_s_s;               
  output  [63:0]      rdata_hostexpmst_0_s_s;             
  output  [1:0]       rresp_hostexpmst_0_s_s;             
  output              rlast_hostexpmst_0_s_s;             
  output              rvalid_hostexpmst_0_s_s;            
  input               rready_hostexpmst_0_s_s;            



  output  [17:0]      awid_hostexpmst_0_s_m;              
  output  [31:0]      awaddr_hostexpmst_0_s_m;            
  output  [7:0]       awlen_hostexpmst_0_s_m;             
  output  [2:0]       awsize_hostexpmst_0_s_m;            
  output  [1:0]       awburst_hostexpmst_0_s_m;           
  output              awlock_hostexpmst_0_s_m;            
  output  [3:0]       awcache_hostexpmst_0_s_m;           
  output  [2:0]       awprot_hostexpmst_0_s_m;            
  output              awvalid_hostexpmst_0_s_m;           
  output  [4:0]       awvalid_vect_hostexpmst_0_s_m;      
  output  [3:0]       awregion_hostexpmst_0_s_m;          
  input               awready_hostexpmst_0_s_m;           

  output  [63:0]      wdata_hostexpmst_0_s_m;             
  output  [7:0]       wstrb_hostexpmst_0_s_m;             
  output              wlast_hostexpmst_0_s_m;             
  output              wvalid_hostexpmst_0_s_m;            
  input               wready_hostexpmst_0_s_m;            

  input   [17:0]      bid_hostexpmst_0_s_m;               
  input   [1:0]       bresp_hostexpmst_0_s_m;             
  input               bvalid_hostexpmst_0_s_m;            
  output              bready_hostexpmst_0_s_m;            

  output  [17:0]      arid_hostexpmst_0_s_m;              
  output  [31:0]      araddr_hostexpmst_0_s_m;            
  output  [7:0]       arlen_hostexpmst_0_s_m;             
  output  [2:0]       arsize_hostexpmst_0_s_m;            
  output  [1:0]       arburst_hostexpmst_0_s_m;           
  output              arlock_hostexpmst_0_s_m;            
  output  [3:0]       arcache_hostexpmst_0_s_m;           
  output  [2:0]       arprot_hostexpmst_0_s_m;            
  output              arvalid_hostexpmst_0_s_m;           
  output  [4:0]       arvalid_vect_hostexpmst_0_s_m;      
  output  [3:0]       arregion_hostexpmst_0_s_m;          
  input               arready_hostexpmst_0_s_m;           

  input   [17:0]      rid_hostexpmst_0_s_m;               
  input   [63:0]      rdata_hostexpmst_0_s_m;             
  input   [1:0]       rresp_hostexpmst_0_s_m;             
  input               rlast_hostexpmst_0_s_m;             
  input               rvalid_hostexpmst_0_s_m;            
  output              rready_hostexpmst_0_s_m;            

  output  [3:0]       awqv_hostexpmst_0_s_m;              
  output  [3:0]       arqv_hostexpmst_0_s_m;              

  input               aclk;                               
  input               aresetn;                            



  


  wire           aw_slave_port_dst_valid;
  wire           aw_slave_port_dst_ready;
  wire           aw_slave_port_src_valid;
  wire           aw_slave_port_src_ready;

  wire [68:0]    aw_slave_port_src_data;     
  wire [68:0]    aw_slave_port_dst_data;     

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

  wire [68:0]    ar_slave_port_src_data;     
  wire [68:0]    ar_slave_port_dst_data;     

  wire [82:0]    r_slave_port_src_data;     
  wire [82:0]    r_slave_port_dst_data;     

  wire [17:0]    b_slave_port_src_data;     
  wire [17:0]    b_slave_port_dst_data;     

  wire                security63;
  wire [15:0]         security58;
  wire                security61;
  wire [4:0]          awvalid_vector;            
  wire [4:0]          arvalid_vector;            
  wire                rvalid_maskcntl;
  wire                bvalid_master;
  wire                bready_master;

  wire                mask_w;
  wire                mask_r;


  wire                wr_cnt_empty;

  wire [3:0]          arcache_int_hostexpmst_0_s_m;
  wire [3:0]          awcache_int_hostexpmst_0_s_m;
  wire [2:0]          arprot_int_hostexpmst_0_s_m;
  wire [2:0]          awprot_int_hostexpmst_0_s_m;
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
  wire [15:0]         awid;
  wire [15:0]         bid;
  wire [15:0]         arid;
  wire [15:0]         rid;


  wire                zero_pad;
  wire                asib_hostexpmst_0_s_siid;
  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;






  assign asib_hostexpmst_0_s_siid = 1'b0;



  assign zero_pad = 1'b0;

  assign awid_hostexpmst_0_s_m = {zero_pad,awid,asib_hostexpmst_0_s_siid};
  assign arid_hostexpmst_0_s_m = {zero_pad,arid,asib_hostexpmst_0_s_siid};
  assign bid = bid_hostexpmst_0_s_m[16:1];
  assign rid = rid_hostexpmst_0_s_m[16:1];


  assign security63 = 1'b0;
  assign security58 = 16'hFFFE;
  assign security61 = 1'b0;


  assign arvalid_int_m = arvalid_int_s;
  assign awvalid_int_m = awvalid_int_s;

  assign arready_int_s = arready_int_m;
  assign awready_int_s = awready_int_m;





  assign arvalid_hostexpmst_0_s_m = arvalid_int_m & cds_ar_enable & !mask_r;
  assign awvalid_hostexpmst_0_s_m = awvalid_int_m & cds_aw_enable & !mask_w;
  assign arready_int_m  = arready_hostexpmst_0_s_m & cds_ar_enable & !mask_r;
  assign awready_int_m  = awready_hostexpmst_0_s_m & cds_aw_enable & !mask_w;


  assign awaddr_int_m = awaddr_int_s;
  assign araddr_int_m = araddr_int_s;

  assign awaddr_hostexpmst_0_s_m = awaddr_int_m;
  assign araddr_hostexpmst_0_s_m = araddr_int_m;

  assign arprot_hostexpmst_0_s_m[2] = arprot_int_hostexpmst_0_s_m[2];
  assign arprot_hostexpmst_0_s_m[1] = 1'b1;
  assign arprot_hostexpmst_0_s_m[0] = arprot_int_hostexpmst_0_s_m[0];

  assign awprot_hostexpmst_0_s_m[2] = awprot_int_hostexpmst_0_s_m[2];
  assign awprot_hostexpmst_0_s_m[1] = 1'b1;
  assign awprot_hostexpmst_0_s_m[0] = awprot_int_hostexpmst_0_s_m[0];


  nic400_asib_hostexpmst_0_s_decode_sse710_integration_example_f0_host_exp u_aw_add_decode
  (
    .addr_s                 (awaddr_int_s),
    .aregion_out            (awregion_hostexpmst_0_s_m),
    .security63               (security63),
    .security58               (security58),
    .security61               (security61),
    .aprot                  (awprot_hostexpmst_0_s_m[1]),
    .acache_in              (awcache_int_hostexpmst_0_s_m),
    .acache_out             (awcache_hostexpmst_0_s_m),
    .avalid_int             (awvalid_vector)

  );

nic400_asib_hostexpmst_0_s_wr_ss_cdas_sse710_integration_example_f0_host_exp u_asib_hostexpmst_0_s_wr_ss_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vector),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .wvalid                 (wvalid_hostexpmst_0_s_m),
    .wready                 (wready_hostexpmst_0_s_m),
    .wlast                  (wlast_hostexpmst_0_s_m),
    .resp_valid             (bvalid_hostexpmst_0_s_m),
    .resp_ready             (bready_hostexpmst_0_s_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_hostexpmst_0_s_decode_sse710_integration_example_f0_host_exp u_ar_add_decode
  (
    .addr_s                 (araddr_int_s),
    .aregion_out            (arregion_hostexpmst_0_s_m),
    .security63               (security63),
    .security58               (security58),
    .security61               (security61),
    .aprot                  (arprot_hostexpmst_0_s_m[1]),
    .acache_in              (arcache_int_hostexpmst_0_s_m),
    .acache_out             (arcache_hostexpmst_0_s_m),
    .avalid_int             (arvalid_vector)

  );

nic400_asib_hostexpmst_0_s_rd_ss_cdas_sse710_integration_example_f0_host_exp u_asib_hostexpmst_0_s_rd_ss_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vector),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .resp_valid             (rvalid_hostexpmst_0_s_m),
    .resp_last              (rlast_hostexpmst_0_s_m),
    .resp_ready             (rready_hostexpmst_0_s_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_hostexpmst_0_s_maskcntl_sse710_integration_example_f0_host_exp u_asib_hostexpmst_0_s_maskcntl (
      .awvalid_m    (awvalid_int_m),
      .arvalid_m    (arvalid_int_m),
      .awready_m    (awready_int_m),
      .arready_m    (arready_int_m),
      .bvalid_m     (bvalid_hostexpmst_0_s_m),
      .bready_m     (bready_hostexpmst_0_s_m),
      .rvalid_m     (rvalid_maskcntl),
      .rready_m     (rready_hostexpmst_0_s_m),

      .wr_cnt_empty (wr_cnt_empty),
      .mask_w       (mask_w),
      .mask_r       (mask_r),
      .aw_qos_m     (awqv_hostexpmst_0_s_m),
      .ar_qos_m     (arqv_hostexpmst_0_s_m),
      .aclk         (aclk),
      .aresetn      (aresetn)
      );

  assign rvalid_maskcntl = rvalid_hostexpmst_0_s_m & rlast_hostexpmst_0_s_m;

 

  assign bvalid_master = (bvalid_hostexpmst_0_s_m & ~wr_cnt_empty);
  assign bready_hostexpmst_0_s_m = (bready_master & ~wr_cnt_empty);



    
  assign awvalid_vect_hostexpmst_0_s_m = ({5{awvalid_hostexpmst_0_s_m}} & awvalid_vector);
  assign arvalid_vect_hostexpmst_0_s_m = ({5{arvalid_hostexpmst_0_s_m}} & arvalid_vector);
    

  assign aw_slave_port_src_data = {awid_hostexpmst_0_s_s,
          awaddr_hostexpmst_0_s_s,
          awlen_hostexpmst_0_s_s,
          awsize_hostexpmst_0_s_s,
          awburst_hostexpmst_0_s_s,
          awlock_hostexpmst_0_s_s,
          awcache_hostexpmst_0_s_s,
          awprot_hostexpmst_0_s_s};

  assign {awid,
          awaddr_int_s,
          awlen_hostexpmst_0_s_m,
          awsize_hostexpmst_0_s_m,
          awburst_hostexpmst_0_s_m,
          awlock_hostexpmst_0_s_m,
          awcache_int_hostexpmst_0_s_m,
          awprot_int_hostexpmst_0_s_m} = aw_slave_port_dst_data;



  assign awvalid_int_s = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_int_s;

  assign aw_slave_port_src_valid = awvalid_hostexpmst_0_s_s;
  assign awready_hostexpmst_0_s_s = aw_slave_port_src_ready;


  assign w_slave_port_src_data = {wdata_hostexpmst_0_s_s,
          wstrb_hostexpmst_0_s_s,
          wlast_hostexpmst_0_s_s};

  assign {wdata_hostexpmst_0_s_m,
          wstrb_hostexpmst_0_s_m,
          wlast_hostexpmst_0_s_m} = w_slave_port_dst_data;



  assign wvalid_hostexpmst_0_s_m = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_hostexpmst_0_s_m;

  assign w_slave_port_src_valid = wvalid_hostexpmst_0_s_s;
  assign wready_hostexpmst_0_s_s = w_slave_port_src_ready;


  assign ar_slave_port_src_data = {arid_hostexpmst_0_s_s,
          araddr_hostexpmst_0_s_s,
          arlen_hostexpmst_0_s_s,
          arsize_hostexpmst_0_s_s,
          arburst_hostexpmst_0_s_s,
          arlock_hostexpmst_0_s_s,
          arcache_hostexpmst_0_s_s,
          arprot_hostexpmst_0_s_s};

  assign {arid,
          araddr_int_s,
          arlen_hostexpmst_0_s_m,
          arsize_hostexpmst_0_s_m,
          arburst_hostexpmst_0_s_m,
          arlock_hostexpmst_0_s_m,
          arcache_int_hostexpmst_0_s_m,
          arprot_int_hostexpmst_0_s_m} = ar_slave_port_dst_data;



  assign arvalid_int_s = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_int_s;

  assign ar_slave_port_src_valid = arvalid_hostexpmst_0_s_s;
  assign arready_hostexpmst_0_s_s = ar_slave_port_src_ready;



  assign r_slave_port_src_data = {rid,
          rdata_hostexpmst_0_s_m,
          rresp_hostexpmst_0_s_m,
          rlast_hostexpmst_0_s_m};

  assign {rid_hostexpmst_0_s_s,
          rdata_hostexpmst_0_s_s,
          rresp_hostexpmst_0_s_s,
          rlast_hostexpmst_0_s_s} = r_slave_port_dst_data;


  assign r_slave_port_dst_data = r_slave_port_src_data;

  assign rvalid_hostexpmst_0_s_s = rvalid_hostexpmst_0_s_m;
  assign rready_hostexpmst_0_s_m = rready_hostexpmst_0_s_s;



  assign b_slave_port_src_data = {bid,
          bresp_hostexpmst_0_s_m};

  assign {bid_hostexpmst_0_s_s,
          bresp_hostexpmst_0_s_s} = b_slave_port_dst_data;


  assign b_slave_port_dst_data = b_slave_port_src_data;

  assign bvalid_hostexpmst_0_s_s = bvalid_master;
  assign bready_master = bready_hostexpmst_0_s_s;



  nic400_asib_hostexpmst_0_s_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       69  
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




  nic400_asib_hostexpmst_0_s_chan_slice_sse710_integration_example_f0_host_exp
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




  nic400_asib_hostexpmst_0_s_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       69  
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
    #(`OVL_FATAL, 5, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot zero")
      ovl_arvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {5{arvalid_int_m}} & arvalid_vector )
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
    #(`OVL_FATAL, 5, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot zero")
      ovl_awvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {5{awvalid_int_m}} & awvalid_vector )
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

`include "nic400_asib_hostexpmst_0_s_undefs_sse710_integration_example_f0_host_exp.v"



