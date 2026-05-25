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



`include "nic400_ib_debug_axis_ib_defs_sse710_main.v"



module nic400_ib_debug_axis_ib_master_domain_sse710_main
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
    awvalid_vect_axi4_m,
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
    arvalid_vect_axi4_m,
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

    paddr,
    pwdata,
    pwrite,
    penable,
    psel,
    prdata,
    pslverr,
    pready,

    apbm_req,
    apbm_ack,
    apbm_fwd_data,
    apbm_rev_data,


    aw_data,
    aw_rpntr_gry,
    aw_rpntr_bin,
    aw_wpntr_gry,

    b_data,
    b_rpntr_gry,
    b_rpntr_bin,
    b_wpntr_gry,

    ar_data,
    ar_valid,
    ar_ready,

    r_data,
    r_valid,
    r_ready,

    w_data,
    w_rpntr_gry,
    w_rpntr_bin,
    w_wpntr_gry,

    aclk,
    aresetn

  );




  


  output  [11:0]      awid_axi4_m;              
  output  [39:0]      awaddr_axi4_m;            
  output  [7:0]       awlen_axi4_m;             
  output  [2:0]       awsize_axi4_m;            
  output  [1:0]       awburst_axi4_m;           
  output              awlock_axi4_m;            
  output  [3:0]       awcache_axi4_m;           
  output  [2:0]       awprot_axi4_m;            
  output              awvalid_axi4_m;           
  output  [9:0]       awvalid_vect_axi4_m;      
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
  output  [39:0]      araddr_axi4_m;            
  output  [7:0]       arlen_axi4_m;             
  output  [2:0]       arsize_axi4_m;            
  output  [1:0]       arburst_axi4_m;           
  output              arlock_axi4_m;            
  output  [3:0]       arcache_axi4_m;           
  output  [2:0]       arprot_axi4_m;            
  output              arvalid_axi4_m;           
  output  [9:0]       arvalid_vect_axi4_m;      
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

  input   [31:0]      paddr;                    
  input   [31:0]      pwdata;                   
  input               pwrite;                   
  input               penable;                  
  input               psel;                     
  output  [31:0]      prdata;                   
  output              pslverr;                  
  output              pready;                   

  output              apbm_req;                 
  input               apbm_ack;                 
  output  [71:0]      apbm_fwd_data;            
  input   [32:0]      apbm_rev_data;            



  input   [76:0]      aw_data;                  
  output  [3:0]       aw_rpntr_gry;             
  output  [2:0]       aw_rpntr_bin;             
  input   [3:0]       aw_wpntr_gry;             

  output  [6:0]       b_data;                   
  input   [2:0]       b_rpntr_gry;              
  input   [1:0]       b_rpntr_bin;              
  output  [2:0]       b_wpntr_gry;              

  input   [76:0]      ar_data;                  
  input               ar_valid;                 
  output              ar_ready;                 

  output  [71:0]      r_data;                   
  output              r_valid;                  
  input               r_ready;                  

  input   [72:0]      w_data;                   
  output  [3:0]       w_rpntr_gry;              
  output  [2:0]       w_rpntr_bin;              
  input   [3:0]       w_wpntr_gry;              

  input               aclk;                     
  input               aresetn;                  



  wire                psel_exp;
  wire [31:0]         prdata_exp;
  wire                pslverr_exp;
  wire                pready_exp;

  wire                decode_match_mask;
  wire [31:0]         prdata_mask;
  wire                pslverr_mask;
  wire                pready_mask;

  wire                awvalid_master;
  wire                awready_master;
  wire                arvalid_master;
  wire                arready_master;
  wire                bvalid_master;
  wire                bready_master;
  wire                rvalid_master;



  wire [9:0]          awvalid_vector;
  wire [9:0]          arvalid_vector;

  wire                wr_cnt_empty;
  wire                mask_w;
  wire                mask_r;

  
  wire                aw_boundary_dst_valid;
  wire                aw_boundary_dst_ready;

  
  wire                w_boundary_dst_valid;
  wire                w_boundary_dst_ready;

  
  wire                b_boundary_src_valid;
  wire                b_boundary_src_ready;

  wire [6:0]          b_boundary_src_data;     
  wire [6:0]          b_boundary_dst_data;     


  wire [3:0]          aw_rpntr_gry;          
  wire [2:0]          aw_rpntr_bin;          
  wire [3:0]          aw_wpntr_gry;          

  wire [3:0]          w_rpntr_gry;           
  wire [2:0]          w_rpntr_bin;           
  wire [3:0]          w_wpntr_gry;           

  wire [2:0]          b_rpntr_gry;           
  wire [1:0]          b_rpntr_bin;           
  wire [2:0]          b_wpntr_gry;           


  wire [3:0]          awid;

  wire [3:0]          wid;
  wire [3:0]          arid;
  wire [3:0]          rid;
  wire [3:0]          bid;
  wire [3:0]          zero_pad;
      
  wire [2:0]          asib_debug_axis_ib_siid;
  
  wire                iid;






  assign {
          awid,
          awaddr_axi4_m[31:0],
          awlen_axi4_m,
          awsize_axi4_m,
          awburst_axi4_m,
          awlock_axi4_m,
          awcache_axi4_m,
          awuser_axi4_m,
          awprot_axi4_m,
          awvalid_vector} = aw_data;

  

  assign awvalid_master = aw_boundary_dst_valid;
  assign aw_boundary_dst_ready = awready_master;







  assign {
          arid,
          araddr_axi4_m[31:0],
          arlen_axi4_m,
          arsize_axi4_m,
          arburst_axi4_m,
          arlock_axi4_m,
          arcache_axi4_m,
          aruser_axi4_m,
          arprot_axi4_m,
          arvalid_vector} = ar_data;

  

  assign arvalid_master = ar_valid;
  assign ar_ready = arready_master;







  assign {
          wdata_axi4_m,
          wstrb_axi4_m,
          wlast_axi4_m} = w_data;

  

  assign wvalid_axi4_m = w_boundary_dst_valid;
  assign w_boundary_dst_ready = wready_axi4_m;





  assign r_data = {
          rid,
          rdata_axi4_m,
          rresp_axi4_m,
          ruser_axi4_m,
          rlast_axi4_m};

  assign r_valid = rvalid_axi4_m;
  assign rready_axi4_m = r_ready;



  assign b_boundary_src_data = {
          bid,
          bresp_axi4_m,
          buser_axi4_m};

  assign b_boundary_src_valid = bvalid_master;
  assign bready_master = b_boundary_src_ready;

  assign b_data = b_boundary_dst_data;
  

  nic400_ib_debug_axis_ib_aw_fifo_rd_sse710_main
  u_aw_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (aw_boundary_dst_ready),
     .wpntr_gry             (aw_wpntr_gry),

     .dst_valid             (aw_boundary_dst_valid),
     .rpntr_gry             (aw_rpntr_gry),
     .rpntr_bin             (aw_rpntr_bin)
     );




  nic400_ib_debug_axis_ib_w_fifo_rd_sse710_main
  u_w_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (w_boundary_dst_ready),
     .wpntr_gry             (w_wpntr_gry),

     .dst_valid             (w_boundary_dst_valid),
     .rpntr_gry             (w_rpntr_gry),
     .rpntr_bin             (w_rpntr_bin)
     );




  nic400_ib_debug_axis_ib_b_fifo_wr_sse710_main
  u_b_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (b_boundary_src_valid),
     .src_data              (b_boundary_src_data),
     .rpntr_gry             (b_rpntr_gry),
     .rpntr_bin             (b_rpntr_bin),

     .src_ready             (b_boundary_src_ready),
     .dst_data              (b_boundary_dst_data),
     .wpntr_gry             (b_wpntr_gry)
     );







  assign awaddr_axi4_m[39:32] = {8{1'b0}};
  assign araddr_axi4_m[39:32] = {8{1'b0}};






  assign asib_debug_axis_ib_siid = 3'b110;
  assign iid = 1'd0;


  assign zero_pad = 4'b0;

  assign awid_axi4_m = {iid,zero_pad,awid,asib_debug_axis_ib_siid};
  assign arid_axi4_m = {iid,zero_pad,arid,asib_debug_axis_ib_siid};

  assign bid = bid_axi4_m[6:3];
  assign rid = rid_axi4_m[6:3];
  



nic400_ib_debug_axis_ib_maskcntl_sse710_main u_maskcntl (
        .awvalid_m    (awvalid_master),
        .arvalid_m    (arvalid_master),
        .awready_m    (awready_master),
        .arready_m    (arready_master),
        .bvalid_m     (bvalid_master),
        .bready_m     (bready_master),
        .rvalid_m     (rvalid_master),
        .rready_m     (rready_axi4_m),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aw_qos_m     (awqv_axi4_m),
        .ar_qos_m     (arqv_axi4_m),
        .paddr        (paddr),
        .psel         (psel),
        .penable      (penable),
        .pwrite       (pwrite),
        .pwdata       (pwdata),
        .prdata       (prdata_mask),
        .pready       (pready_mask),
        .pslverr      (pslverr_mask),
        .decode_match (decode_match_mask),
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

  
  assign awvalid_vect_axi4_m = ({10{awvalid_axi4_m}} & awvalid_vector);
  assign arvalid_vect_axi4_m = ({10{arvalid_axi4_m}} & arvalid_vector);
  









  nic400_apb_bridge_slave_domain_sse710_main u_apb_async_s
  (
    .pclks                    (aclk),
    .pclkens                  (1'b1),
    .presetsn                 (aresetn),

    .psels                    (psel_exp),
    .penables                 (penable),
    .preadys                  (pready_exp),

    .pwrites                  (pwrite),
    .pprots                   (3'b000),
    .pstrbs                   (4'h0),
    .paddrs                   (paddr),
    .pwdatas                  (pwdata),
    .prdatas                  (prdata_exp),
    .pslverrs                 (pslverr_exp),

    .apbm_req_async           (apbm_req),
    .apbm_ack_async           (apbm_ack),
    .apbm_fwd_data_async      (apbm_fwd_data),
    .apbm_rev_data_async      (apbm_rev_data)
  );


  assign psel_exp = (decode_match_mask) ? 1'b0 : psel;

  assign prdata = decode_match_mask ? prdata_mask : prdata_exp;
  assign pready = decode_match_mask ? pready_mask : pready_exp;
  assign pslverr = decode_match_mask ? pslverr_mask : pslverr_exp;








endmodule
`include "nic400_ib_debug_axis_ib_undefs_sse710_main.v"




