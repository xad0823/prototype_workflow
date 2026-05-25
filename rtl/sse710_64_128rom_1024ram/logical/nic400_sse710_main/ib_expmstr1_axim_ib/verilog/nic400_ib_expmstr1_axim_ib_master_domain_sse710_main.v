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



`include "nic400_ib_expmstr1_axim_ib_defs_sse710_main.v"



module nic400_ib_expmstr1_axim_ib_master_domain_sse710_main
  (
  

    awid_axi4_m,
    awaddr_axi4_m,
    awlen_axi4_m,
    awsize_axi4_m,
    awburst_axi4_m,
    awlock_axi4_m,
    awcache_axi4_m,
    awprot_axi4_m,
    awvalid_axi4_m,
    awready_axi4_m,

    wdata_axi4_m,
    wstrb_axi4_m,
    wlast_axi4_m,
    wvalid_axi4_m,
    wready_axi4_m,

    bid_axi4_m,
    bresp_axi4_m,
    bvalid_axi4_m,
    bready_axi4_m,

    arid_axi4_m,
    araddr_axi4_m,
    arlen_axi4_m,
    arsize_axi4_m,
    arburst_axi4_m,
    arlock_axi4_m,
    arcache_axi4_m,
    arprot_axi4_m,
    arvalid_axi4_m,
    arready_axi4_m,

    rid_axi4_m,
    rdata_axi4_m,
    rresp_axi4_m,
    rlast_axi4_m,
    rvalid_axi4_m,
    rready_axi4_m,

    awuser_axi4_m,
    buser_axi4_m,
    aruser_axi4_m,
    ruser_axi4_m,

    awqv_axi4_m,
    arqv_axi4_m,


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




  


  output  [11:0]      awid_axi4_m;         
  output  [31:0]      awaddr_axi4_m;       
  output  [7:0]       awlen_axi4_m;        
  output  [2:0]       awsize_axi4_m;       
  output  [1:0]       awburst_axi4_m;      
  output              awlock_axi4_m;       
  output  [3:0]       awcache_axi4_m;      
  output  [2:0]       awprot_axi4_m;       
  output              awvalid_axi4_m;      
  input               awready_axi4_m;      

  output  [63:0]      wdata_axi4_m;        
  output  [7:0]       wstrb_axi4_m;        
  output              wlast_axi4_m;        
  output              wvalid_axi4_m;       
  input               wready_axi4_m;       

  input   [11:0]      bid_axi4_m;          
  input   [1:0]       bresp_axi4_m;        
  input               bvalid_axi4_m;       
  output              bready_axi4_m;       

  output  [11:0]      arid_axi4_m;         
  output  [31:0]      araddr_axi4_m;       
  output  [7:0]       arlen_axi4_m;        
  output  [2:0]       arsize_axi4_m;       
  output  [1:0]       arburst_axi4_m;      
  output              arlock_axi4_m;       
  output  [3:0]       arcache_axi4_m;      
  output  [2:0]       arprot_axi4_m;       
  output              arvalid_axi4_m;      
  input               arready_axi4_m;      

  input   [11:0]      rid_axi4_m;          
  input   [63:0]      rdata_axi4_m;        
  input   [1:0]       rresp_axi4_m;        
  input               rlast_axi4_m;        
  input               rvalid_axi4_m;       
  output              rready_axi4_m;       

  output  [9:0]       awuser_axi4_m;       
  input               buser_axi4_m;        
  output  [9:0]       aruser_axi4_m;       
  input               ruser_axi4_m;        

  output  [3:0]       awqv_axi4_m;         
  output  [3:0]       arqv_axi4_m;         



  input   [78:0]      aw_data;             
  input               aw_valid;            
  output              aw_ready;            

  output  [14:0]      b_data;              
  output              b_valid;             
  input               b_ready;             

  input   [78:0]      ar_data;             
  input               ar_valid;            
  output              ar_ready;            

  output  [79:0]      r_data;              
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



  wire                wr_cnt_empty;
  wire                mask_w;
  wire                mask_r;

  wire [3:0]          aw_qos_s;
  wire [3:0]          ar_qos_s;







  assign {
          awid_axi4_m,
          awaddr_axi4_m[31:0],
          awlen_axi4_m,
          awsize_axi4_m,
          awburst_axi4_m,
          awlock_axi4_m,
          awcache_axi4_m,
          awuser_axi4_m,
          aw_qos_s,
          awprot_axi4_m} = aw_data;

  

  assign awvalid_master = aw_valid;
  assign aw_ready = awready_master;







  assign {
          arid_axi4_m,
          araddr_axi4_m[31:0],
          arlen_axi4_m,
          arsize_axi4_m,
          arburst_axi4_m,
          arlock_axi4_m,
          arcache_axi4_m,
          aruser_axi4_m,
          ar_qos_s,
          arprot_axi4_m} = ar_data;

  

  assign arvalid_master = ar_valid;
  assign ar_ready = arready_master;







  assign {
          wdata_axi4_m,
          wstrb_axi4_m,
          wlast_axi4_m} = w_data;

  

  assign wvalid_axi4_m = w_valid;
  assign w_ready = wready_axi4_m;





  assign r_data = {
          rid_axi4_m,
          rdata_axi4_m,
          rresp_axi4_m,
          ruser_axi4_m,
          rlast_axi4_m};

  assign r_valid = rvalid_axi4_m;
  assign rready_axi4_m = r_ready;



  assign b_data = {
          bid_axi4_m,
          bresp_axi4_m,
          buser_axi4_m};

  assign b_valid = bvalid_master;
  assign bready_master = b_ready;






nic400_ib_expmstr1_axim_ib_maskcntl_sse710_main u_maskcntl (
        .awvalid_m    (awvalid_master),
        .arvalid_m    (arvalid_master),
        .awready_m    (awready_master),
        .arready_m    (arready_master),
        .aw_qos_s     (aw_qos_s),
        .ar_qos_s     (ar_qos_s),
        .bvalid_m     (bvalid_master),
        .bready_m     (bready_master),
        .rvalid_m     (rvalid_master),
        .rready_m     (rready_axi4_m),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aw_qos_m     (awqv_axi4_m),
        .ar_qos_m     (arqv_axi4_m),
        .tracker_busy (),
        .aclk         (aclk),
        .aresetn      (aresetn)
        );


  
  assign awvalid_axi4_m = (awvalid_master & !mask_w);
  assign arvalid_axi4_m = (arvalid_master & !mask_r);

  assign awready_master = (awready_axi4_m & !mask_w);
  assign arready_master = (arready_axi4_m & !mask_r);

  assign bvalid_master = (bvalid_axi4_m & !wr_cnt_empty);
  assign bready_axi4_m = (bready_master & !wr_cnt_empty);



  assign rvalid_master = rvalid_axi4_m & rlast_axi4_m;

  








endmodule
`include "nic400_ib_expmstr1_axim_ib_undefs_sse710_main.v"




