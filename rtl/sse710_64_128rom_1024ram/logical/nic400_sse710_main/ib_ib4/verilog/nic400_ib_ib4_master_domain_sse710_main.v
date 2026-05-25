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

module nic400_ib_ib4_master_domain_sse710_main
  (
  

    awid_axi_m_0,
    awaddr_axi_m_0,
    awlen_axi_m_0,
    awsize_axi_m_0,
    awburst_axi_m_0,
    awlock_axi_m_0,
    awcache_axi_m_0,
    awprot_axi_m_0,
    awvalid_axi_m_0,
    awvalid_vect_axi_m_0,
    awready_axi_m_0,

    wdata_axi_m_0,
    wstrb_axi_m_0,
    wlast_axi_m_0,
    wvalid_axi_m_0,
    wready_axi_m_0,

    bid_axi_m_0,
    bresp_axi_m_0,
    bvalid_axi_m_0,
    bready_axi_m_0,

    arid_axi_m_0,
    araddr_axi_m_0,
    arlen_axi_m_0,
    arsize_axi_m_0,
    arburst_axi_m_0,
    arlock_axi_m_0,
    arcache_axi_m_0,
    arprot_axi_m_0,
    arvalid_axi_m_0,
    arvalid_vect_axi_m_0,
    arready_axi_m_0,

    rid_axi_m_0,
    rdata_axi_m_0,
    rresp_axi_m_0,
    rlast_axi_m_0,
    rvalid_axi_m_0,
    rready_axi_m_0,

    awuser_axi_m_0,
    buser_axi_m_0,
    aruser_axi_m_0,
    ruser_axi_m_0,

    awqv_axi_m_0,
    arqv_axi_m_0,


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




  


  output  [11:0]      awid_axi_m_0;              
  output  [39:0]      awaddr_axi_m_0;            
  output  [7:0]       awlen_axi_m_0;             
  output  [2:0]       awsize_axi_m_0;            
  output  [1:0]       awburst_axi_m_0;           
  output              awlock_axi_m_0;            
  output  [3:0]       awcache_axi_m_0;           
  output  [2:0]       awprot_axi_m_0;            
  output              awvalid_axi_m_0;           
  output  [3:0]       awvalid_vect_axi_m_0;      
  input               awready_axi_m_0;           

  output  [31:0]      wdata_axi_m_0;             
  output  [3:0]       wstrb_axi_m_0;             
  output              wlast_axi_m_0;             
  output              wvalid_axi_m_0;            
  input               wready_axi_m_0;            

  input   [11:0]      bid_axi_m_0;               
  input   [1:0]       bresp_axi_m_0;             
  input               bvalid_axi_m_0;            
  output              bready_axi_m_0;            

  output  [11:0]      arid_axi_m_0;              
  output  [39:0]      araddr_axi_m_0;            
  output  [7:0]       arlen_axi_m_0;             
  output  [2:0]       arsize_axi_m_0;            
  output  [1:0]       arburst_axi_m_0;           
  output              arlock_axi_m_0;            
  output  [3:0]       arcache_axi_m_0;           
  output  [2:0]       arprot_axi_m_0;            
  output              arvalid_axi_m_0;           
  output  [3:0]       arvalid_vect_axi_m_0;      
  input               arready_axi_m_0;           

  input   [11:0]      rid_axi_m_0;               
  input   [31:0]      rdata_axi_m_0;             
  input   [1:0]       rresp_axi_m_0;             
  input               rlast_axi_m_0;             
  input               rvalid_axi_m_0;            
  output              rready_axi_m_0;            

  output  [9:0]       awuser_axi_m_0;            
  input               buser_axi_m_0;             
  output  [9:0]       aruser_axi_m_0;            
  input               ruser_axi_m_0;             

  output  [3:0]       awqv_axi_m_0;              
  output  [3:0]       arqv_axi_m_0;              



  input   [91:0]      aw_data;                   
  input               aw_valid;                  
  output              aw_ready;                  

  output  [14:0]      b_data;                    
  output              b_valid;                   
  input               b_ready;                   

  input   [102:0]     ar_data;                   
  input               ar_valid;                  
  output              ar_ready;                  

  output  [81:0]      r_data;                    
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



  wire [3:0]          awvalid_vector;
  wire [3:0]          arvalid_vector;

  wire                wr_cnt_empty;
  wire                mask_w;
  wire                mask_r;

  wire [3:0]          aw_qos_s;
  wire [3:0]          ar_qos_s;



  wire                rvalid_bif;
  wire                rlast_bif;
  wire [63:0]         rdata_bif;
  wire [1:0]          rresp_bif;
  wire [11:0]         rid_bif;
  wire                rready_bif;
  wire                ruser_bif;
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
          awid_axi_m_0,
          awaddr_axi_m_0[39:0],
          awlen_axi_m_0,
          awsize_axi_m_0,
          awburst_axi_m_0,
          awlock_axi_m_0,
          awcache_axi_m_0,
          awuser_axi_m_0,
          aw_qos_s,
          awprot_axi_m_0,
          awvalid_vector,downsize} = aw_data;

  

  assign awvalid_bif = aw_valid;
  assign aw_ready = awready_bif;







  assign {
          arid_axi_m_0,
          araddr_axi_m_0[39:0],
          arlen_axi_m_0,
          arsize_axi_m_0,
          arburst_axi_m_0,
          arlock_axi_m_0,
          arcache_axi_m_0,
          aruser_axi_m_0,
          ar_qos_s,
          arprot_axi_m_0,
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
          ruser_bif,
          rlast_bif,rbeats};

  assign r_valid = rvalid_bif;
  assign rready_bif = r_ready;



  assign b_data = {
          bid_axi_m_0,
          bresp_axi_m_0,
          buser_axi_m_0};

  assign b_valid = bvalid_master;
  assign bready_master = b_ready;








nic400_ib_ib4_maskcntl_sse710_main u_maskcntl (
        .awvalid_m    (awvalid_master),
        .arvalid_m    (arvalid_master),
        .awready_m    (awready_master),
        .arready_m    (arready_master),
        .aw_qos_s     (aw_qos_s),
        .ar_qos_s     (ar_qos_s),
        .bvalid_m     (bvalid_master),
        .bready_m     (bready_master),
        .rvalid_m     (rvalid_master),
        .rready_m     (rready_axi_m_0),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aw_qos_m     (awqv_axi_m_0),
        .ar_qos_m     (arqv_axi_m_0),
        .tracker_busy (),
        .aclk         (aclk),
        .aresetn      (aresetn)
        );


  
  assign awvalid_axi_m_0 = (awvalid_master & !mask_w);
  assign arvalid_axi_m_0 = (arvalid_master & !mask_r);

  assign awready_master = (awready_axi_m_0 & !mask_w);
  assign arready_master = (arready_axi_m_0 & !mask_r);

  assign bvalid_master = (bvalid_axi_m_0 & !wr_cnt_empty);
  assign bready_axi_m_0 = (bready_master & !wr_cnt_empty);



  assign rvalid_master = rvalid_axi_m_0 & rlast_axi_m_0;

  
  assign awvalid_vect_axi_m_0 = ({4{awvalid_axi_m_0}} & awvalid_vector);
  assign arvalid_vect_axi_m_0 = ({4{arvalid_axi_m_0}} & arvalid_vector);
  
  nic400_ib_ib4_downsize_wr_mux_sse710_main u_downsize_write_mux
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .awaddr_s                         (awaddr_axi_m_0[2:0]),
    .awlen_s                          (awlen_axi_m_0),
    .awsize_s                         (awsize_axi_m_0[1:0]),
    .awburst_s                        (awburst_axi_m_0),

    .awvalid_s                        (awvalid_bif),
    .awready_s                        (awready_bif),

    .awvalid_m                        (awvalid_master),
    .awready_m                        (awready_master),

    .wdata_s                          (wdata_bif),
    .wstrb_s                          (wstrb_bif),
    .wlast_s                          (wlast_bif),

    .wready_s                         (wready_bif),
    .wvalid_s                         (wvalid_bif),

    .wdata_m                          (wdata_axi_m_0),
    .wstrb_m                          (wstrb_axi_m_0),
    .wlast_m                          (wlast_axi_m_0),

    .wready_m                         (wready_axi_m_0),
    .wvalid_m                         (wvalid_axi_m_0),

    .downsize                         (downsize)

  );



nic400_ib_ib4_downsize_rd_chan_sse710_main u_downsize_read_channel
  (

  .aresetn                           (aresetn),
  .aclk                              (aclk),

  .archannel_data                    (arfmt_data),
  .archannel_valid                   (arvalid_bif),
  .archannel_ready                   (arready_bif),

  .arsize                            (arsize_axi_m_0),
  .araddr                            (araddr_axi_m_0[2:0]),
  .arid                              (arid_axi_m_0),

  .arvalid_m                         (arvalid_master),
  .arready_m                         (arready_master),

  .rvalid_m                          (rvalid_axi_m_0),
  .rdata_m                           (rdata_axi_m_0),
  .ruser_m                           (ruser_axi_m_0),
  .rlast_m                           (rlast_axi_m_0),
  .rid_m                             (rid_axi_m_0),
  .rresp_m                           (rresp_axi_m_0),

  .rready_s                          (rready_bif),


  .rready_m                          (rready_axi_m_0),

  .rvalid_s                          (rvalid_bif),
  .rdata_s                           (rdata_bif),
  .ruser_s                           (ruser_bif),
  .rlast_s                           (rlast_bif),
  .rid_s                             (rid_bif),
  .rresp_s                           (rresp_bif),

  .rbeats_s                          (rbeats)

  );
















endmodule
`include "nic400_ib_ib4_undefs_sse710_main.v"
`include "Axi_undefs.v"



