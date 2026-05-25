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



`include "nic400_ib_ib2_defs_sse710_integration_example_f0_host_exp.v"

`include "Axi.v"

module nic400_ib_ib2_master_domain_sse710_integration_example_f0_host_exp
  (
  

    awid_ib2_m,
    awaddr_ib2_m,
    awlen_ib2_m,
    awsize_ib2_m,
    awburst_ib2_m,
    awlock_ib2_m,
    awcache_ib2_m,
    awprot_ib2_m,
    awvalid_ib2_m,
    awvalid_vect_ib2_m,
    awregion_ib2_m,
    awready_ib2_m,

    wdata_ib2_m,
    wstrb_ib2_m,
    wlast_ib2_m,
    wvalid_ib2_m,
    wready_ib2_m,

    bid_ib2_m,
    bresp_ib2_m,
    bvalid_ib2_m,
    bready_ib2_m,

    arid_ib2_m,
    araddr_ib2_m,
    arlen_ib2_m,
    arsize_ib2_m,
    arburst_ib2_m,
    arlock_ib2_m,
    arcache_ib2_m,
    arprot_ib2_m,
    arvalid_ib2_m,
    arvalid_vect_ib2_m,
    arregion_ib2_m,
    arready_ib2_m,

    rid_ib2_m,
    rdata_ib2_m,
    rresp_ib2_m,
    rlast_ib2_m,
    rvalid_ib2_m,
    rready_ib2_m,

    awqv_ib2_m,
    arqv_ib2_m,


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




  


  output  [17:0]      awid_ib2_m;              
  output  [31:0]      awaddr_ib2_m;            
  output  [7:0]       awlen_ib2_m;             
  output  [2:0]       awsize_ib2_m;            
  output  [1:0]       awburst_ib2_m;           
  output              awlock_ib2_m;            
  output  [3:0]       awcache_ib2_m;           
  output  [2:0]       awprot_ib2_m;            
  output              awvalid_ib2_m;           
  output  [1:0]       awvalid_vect_ib2_m;      
  output  [3:0]       awregion_ib2_m;          
  input               awready_ib2_m;           

  output  [31:0]      wdata_ib2_m;             
  output  [3:0]       wstrb_ib2_m;             
  output              wlast_ib2_m;             
  output              wvalid_ib2_m;            
  input               wready_ib2_m;            

  input   [17:0]      bid_ib2_m;               
  input   [1:0]       bresp_ib2_m;             
  input               bvalid_ib2_m;            
  output              bready_ib2_m;            

  output  [17:0]      arid_ib2_m;              
  output  [31:0]      araddr_ib2_m;            
  output  [7:0]       arlen_ib2_m;             
  output  [2:0]       arsize_ib2_m;            
  output  [1:0]       arburst_ib2_m;           
  output              arlock_ib2_m;            
  output  [3:0]       arcache_ib2_m;           
  output  [2:0]       arprot_ib2_m;            
  output              arvalid_ib2_m;           
  output  [1:0]       arvalid_vect_ib2_m;      
  output  [3:0]       arregion_ib2_m;          
  input               arready_ib2_m;           

  input   [17:0]      rid_ib2_m;               
  input   [31:0]      rdata_ib2_m;             
  input   [1:0]       rresp_ib2_m;             
  input               rlast_ib2_m;             
  input               rvalid_ib2_m;            
  output              rready_ib2_m;            

  output  [3:0]       awqv_ib2_m;              
  output  [3:0]       arqv_ib2_m;              



  input   [81:0]      aw_data;                 
  input               aw_valid;                
  output              aw_ready;                

  output  [19:0]      b_data;                  
  output              b_valid;                 
  input               b_ready;                 

  input   [92:0]      ar_data;                 
  input               ar_valid;                
  output              ar_ready;                

  output  [86:0]      r_data;                  
  output              r_valid;                 
  input               r_ready;                 

  input   [72:0]      w_data;                  
  input               w_valid;                 
  output              w_ready;                 

  input               aclk;                    
  input               aresetn;                 



  wire                awvalid_master;
  wire                awready_master;
  wire                arvalid_master;
  wire                arready_master;
  wire                bvalid_master;
  wire                bready_master;
  wire                rvalid_master;



  wire [1:0]          awvalid_vector;
  wire [1:0]          arvalid_vector;

  wire                wr_cnt_empty;
  wire                mask_w;
  wire                mask_r;

  wire [3:0]          aw_qos_s;
  wire [3:0]          ar_qos_s;



  wire                rvalid_bif;
  wire                rlast_bif;
  wire [63:0]         rdata_bif;
  wire [1:0]          rresp_bif;
  wire [17:0]         rid_bif;
  wire                rready_bif;
  wire                arvalid_bif;
  wire                arready_bif;

  wire                awvalid_bif;
  wire                awready_bif;
  wire                wvalid_bif;
  wire                wlast_bif;
  wire [63:0]         wdata_bif;
  wire [7:0]          wstrb_bif;
  wire                wready_bif;

  wire [1:0]          rbeats;
  wire [11:0]         arfmt_data;
  wire                downsize;






  assign {
          awid_ib2_m,
          awaddr_ib2_m[31:0],
          awlen_ib2_m,
          awsize_ib2_m,
          awburst_ib2_m,
          awlock_ib2_m,
          awcache_ib2_m,
          awregion_ib2_m,
          aw_qos_s,
          awprot_ib2_m,
          awvalid_vector,downsize} = aw_data;

  

  assign awvalid_bif = aw_valid;
  assign aw_ready = awready_bif;







  assign {
          arid_ib2_m,
          araddr_ib2_m[31:0],
          arlen_ib2_m,
          arsize_ib2_m,
          arburst_ib2_m,
          arlock_ib2_m,
          arcache_ib2_m,
          arregion_ib2_m,
          ar_qos_s,
          arprot_ib2_m,
          arvalid_vector,arfmt_data} = ar_data;

  

  assign arvalid_bif = ar_valid;
  assign ar_ready = arready_bif;







  assign {
          wdata_bif,
          wstrb_bif,
          wlast_bif} = w_data;

  

  assign wvalid_bif = w_valid;
  assign w_ready = wready_bif;





  assign r_data = {
          rid_bif,
          rdata_bif,
          rresp_bif,
          rlast_bif,rbeats};

  assign r_valid = rvalid_bif;
  assign rready_bif = r_ready;



  assign b_data = {
          bid_ib2_m,
          bresp_ib2_m};

  assign b_valid = bvalid_master;
  assign bready_master = b_ready;








nic400_ib_ib2_maskcntl_sse710_integration_example_f0_host_exp u_maskcntl (
        .awvalid_m    (awvalid_master),
        .arvalid_m    (arvalid_master),
        .awready_m    (awready_master),
        .arready_m    (arready_master),
        .aw_qos_s     (aw_qos_s),
        .ar_qos_s     (ar_qos_s),
        .bvalid_m     (bvalid_master),
        .bready_m     (bready_master),
        .rvalid_m     (rvalid_master),
        .rready_m     (rready_ib2_m),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aw_qos_m     (awqv_ib2_m),
        .ar_qos_m     (arqv_ib2_m),
        .aclk         (aclk),
        .aresetn      (aresetn)
        );


  
  assign awvalid_ib2_m = (awvalid_master & !mask_w);
  assign arvalid_ib2_m = (arvalid_master & !mask_r);

  assign awready_master = (awready_ib2_m & !mask_w);
  assign arready_master = (arready_ib2_m & !mask_r);

  assign bvalid_master = (bvalid_ib2_m & !wr_cnt_empty);
  assign bready_ib2_m = (bready_master & !wr_cnt_empty);



  assign rvalid_master = rvalid_ib2_m & rlast_ib2_m;

  
  assign awvalid_vect_ib2_m = ({2{awvalid_ib2_m}} & awvalid_vector);
  assign arvalid_vect_ib2_m = ({2{arvalid_ib2_m}} & arvalid_vector);
  
  nic400_ib_ib2_downsize_wr_mux_sse710_integration_example_f0_host_exp u_downsize_write_mux
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .awaddr_s                         (awaddr_ib2_m[2:0]),
    .awlen_s                          (awlen_ib2_m),
    .awsize_s                         (awsize_ib2_m[1:0]),
    .awburst_s                        (awburst_ib2_m),

    .awvalid_s                        (awvalid_bif),
    .awready_s                        (awready_bif),

    .awvalid_m                        (awvalid_master),
    .awready_m                        (awready_master),

    .wdata_s                          (wdata_bif),
    .wstrb_s                          (wstrb_bif),
    .wlast_s                          (wlast_bif),

    .wready_s                         (wready_bif),
    .wvalid_s                         (wvalid_bif),

    .wdata_m                          (wdata_ib2_m),
    .wstrb_m                          (wstrb_ib2_m),
    .wlast_m                          (wlast_ib2_m),

    .wready_m                         (wready_ib2_m),
    .wvalid_m                         (wvalid_ib2_m),

    .downsize                         (downsize)

  );



nic400_ib_ib2_downsize_rd_chan_sse710_integration_example_f0_host_exp u_downsize_read_channel
  (

  .aresetn                           (aresetn),
  .aclk                              (aclk),

  .archannel_data                    (arfmt_data),
  .archannel_valid                   (arvalid_bif),
  .archannel_ready                   (arready_bif),

  .arsize                            (arsize_ib2_m),
  .araddr                            (araddr_ib2_m[2:0]),
  .arid                              (arid_ib2_m),

  .arvalid_m                         (arvalid_master),
  .arready_m                         (arready_master),

  .rvalid_m                          (rvalid_ib2_m),
  .rdata_m                           (rdata_ib2_m),
  .rlast_m                           (rlast_ib2_m),
  .rid_m                             (rid_ib2_m),
  .rresp_m                           (rresp_ib2_m),

  .rready_s                          (rready_bif),


  .rready_m                          (rready_ib2_m),

  .rvalid_s                          (rvalid_bif),
  .rdata_s                           (rdata_bif),
  .rlast_s                           (rlast_bif),
  .rid_s                             (rid_bif),
  .rresp_s                           (rresp_bif),

  .rbeats_s                          (rbeats)

  );
















endmodule
`include "nic400_ib_ib2_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"



