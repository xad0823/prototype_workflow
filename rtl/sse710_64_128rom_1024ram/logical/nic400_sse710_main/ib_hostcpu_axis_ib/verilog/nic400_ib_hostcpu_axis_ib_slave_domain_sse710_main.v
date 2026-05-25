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


`include "nic400_ib_hostcpu_axis_ib_defs_sse710_main.v"
`include "Axi.v"

module nic400_ib_hostcpu_axis_ib_slave_domain_sse710_main
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
    awvalid_vect_axi4_s,
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
    arvalid_vect_axi4_s,
    arready_axi4_s,

    rid_axi4_s,
    rdata_axi4_s,
    rresp_axi4_s,
    rlast_axi4_s,
    rvalid_axi4_s,
    rready_axi4_s,

    awuser_axi4_s,
    buser_axi4_s,
    aruser_axi4_s,
    ruser_axi4_s,

    paddrm,
    pwdatam,
    pwritem,
    penablem,
    pselm,
    prdatam,
    pslverrm,
    preadym,

    apbs_req,
    apbs_ack,
    apbs_fwd_data,
    apbs_rev_data,


    aw_data,
    aw_rpntr_gry,
    aw_rpntr_bin,
    aw_wpntr_gry,

    b_data,
    b_rpntr_gry,
    b_rpntr_bin,
    b_wpntr_gry,

    ar_data,
    ar_rpntr_gry,
    ar_rpntr_bin,
    ar_wpntr_gry,

    r_data,
    r_rpntr_gry,
    r_rpntr_bin,
    r_wpntr_gry,

    w_data,
    w_rpntr_gry,
    w_rpntr_bin,
    w_wpntr_gry,

    aclk,
    aresetn

  );



  


  input   [7:0]       awid_axi4_s;              
  input   [39:0]      awaddr_axi4_s;            
  input   [7:0]       awlen_axi4_s;             
  input   [2:0]       awsize_axi4_s;            
  input   [1:0]       awburst_axi4_s;           
  input               awlock_axi4_s;            
  input   [3:0]       awcache_axi4_s;           
  input   [2:0]       awprot_axi4_s;            
  input               awvalid_axi4_s;           
  input   [10:0]      awvalid_vect_axi4_s;      
  output              awready_axi4_s;           

  input   [127:0]     wdata_axi4_s;             
  input   [15:0]      wstrb_axi4_s;             
  input               wlast_axi4_s;             
  input               wvalid_axi4_s;            
  output              wready_axi4_s;            

  output  [7:0]       bid_axi4_s;               
  output  [1:0]       bresp_axi4_s;             
  output              bvalid_axi4_s;            
  input               bready_axi4_s;            

  input   [7:0]       arid_axi4_s;              
  input   [39:0]      araddr_axi4_s;            
  input   [7:0]       arlen_axi4_s;             
  input   [2:0]       arsize_axi4_s;            
  input   [1:0]       arburst_axi4_s;           
  input               arlock_axi4_s;            
  input   [3:0]       arcache_axi4_s;           
  input   [2:0]       arprot_axi4_s;            
  input               arvalid_axi4_s;           
  input   [10:0]      arvalid_vect_axi4_s;      
  output              arready_axi4_s;           

  output  [7:0]       rid_axi4_s;               
  output  [127:0]     rdata_axi4_s;             
  output  [1:0]       rresp_axi4_s;             
  output              rlast_axi4_s;             
  output              rvalid_axi4_s;            
  input               rready_axi4_s;            

  input   [9:0]       awuser_axi4_s;            
  output              buser_axi4_s;             
  input   [9:0]       aruser_axi4_s;            
  output              ruser_axi4_s;             

  output  [31:0]      paddrm;                   
  output  [31:0]      pwdatam;                  
  output              pwritem;                  
  output              penablem;                 
  output              pselm;                    
  input   [31:0]      prdatam;                  
  input               pslverrm;                 
  input               preadym;                  

  input               apbs_req;                 
  output              apbs_ack;                 
  input   [71:0]      apbs_fwd_data;            
  output  [32:0]      apbs_rev_data;            



  output  [90:0]      aw_data;                  
  input   [4:0]       aw_rpntr_gry;             
  input   [3:0]       aw_rpntr_bin;             
  output  [4:0]       aw_wpntr_gry;             

  input   [10:0]      b_data;                   
  output  [2:0]       b_rpntr_gry;              
  output  [1:0]       b_rpntr_bin;              
  input   [2:0]       b_wpntr_gry;              

  output  [103:0]     ar_data;                  
  input   [4:0]       ar_rpntr_gry;             
  input   [3:0]       ar_rpntr_bin;             
  output  [4:0]       ar_wpntr_gry;             

  input   [142:0]     r_data;                   
  output  [2:0]       r_rpntr_gry;              
  output  [1:0]       r_rpntr_bin;              
  input   [2:0]       r_wpntr_gry;              

  output  [144:0]     w_data;                   
  input   [4:0]       w_rpntr_gry;              
  input   [3:0]       w_rpntr_bin;              
  output  [4:0]       w_wpntr_gry;              

  input               aclk;                     
  input               aresetn;                  
   


  wire                pslverr;
  wire                pready;
  wire [31:0]         prdata;
  wire                decode_match;
  wire                bypass_merge_apb;
  wire                long_burst;
  wire                pslverr_apb;
  wire                pready_apb;
  wire [31:0]         prdata_apb;
  wire                pselm_apb;
  
  wire                aw_boundary_src_valid;
  wire                aw_boundary_src_ready;

  wire [90:0]         aw_boundary_src_data;     
  wire [90:0]         aw_boundary_dst_data;     


  
  wire                ar_boundary_src_valid;
  wire                ar_boundary_src_ready;

  wire [103:0]        ar_boundary_src_data;     
  wire [103:0]        ar_boundary_dst_data;     


  
  wire                r_boundary_dst_valid;
  wire                r_boundary_dst_ready;

  
  wire                w_boundary_src_valid;
  wire                w_boundary_src_ready;

  wire [144:0]        w_boundary_src_data;     
  wire [144:0]        w_boundary_dst_data;     


  
  wire                b_boundary_dst_valid;
  wire                b_boundary_dst_ready;

  wire [4:0]          aw_rpntr_gry;            
  wire [3:0]          aw_rpntr_bin;             
  wire [4:0]          aw_wpntr_gry;            
  
  wire [4:0]          ar_rpntr_gry;            
  wire [3:0]          ar_rpntr_bin;             
  wire [4:0]          ar_wpntr_gry;            
  
  wire [4:0]          w_rpntr_gry;             
  wire [3:0]          w_rpntr_bin;             
  wire [4:0]          w_wpntr_gry;             
  
  wire [2:0]          b_rpntr_gry;             
  wire [1:0]          b_rpntr_bin;             
  wire [2:0]          b_wpntr_gry;             
  
  wire [2:0]          r_rpntr_gry;             
  wire [1:0]          r_rpntr_bin;             
  wire [2:0]          r_wpntr_gry;             
  


  wire [11:0]         bdata_data;
  wire                bdata_valid;
  wire                bdata_ready;

  wire [12:0]         awdata_data;
  wire                awdata_valid;
  wire                awdata_ready;

  wire                merge;
  wire                merge_clear;
  wire [1:0]          data_select;
  wire                strb_skid_valid;

  wire [127:0]        wdata_merged;
  wire [15:0]         wstrb_merged;
  wire [13:0]         arfmt_data;
  wire [2:0]          rbeats;
  
  wire                downsize;  
  wire  [89:0]        aw_fmt_src_data;
  wire  [89:0]        ar_fmt_src_data;
  wire  [89:0]        aw_fmt_dst_data;
  wire  [89:0]        ar_fmt_dst_data;




  wire [7:0]          awid_bif;
  wire [39:0]         awaddr_bif;
  wire [7:0]          awlen_bif;
  wire [2:0]          awsize_bif;
  wire [1:0]          awburst_bif;
  wire           awlock_bif;
  wire [3:0]          awcache_bif;
  wire [9:0]          awuser_bif;
  wire [2:0]          awprot_bif;
  wire                awvalid_bif;
  wire [10:0]         awvalid_vect_bif;
  wire                awready_bif;

  wire [7:0]          arid_bif;
  wire [39:0]         araddr_bif;
  wire [7:0]          arlen_bif;
  wire [2:0]          arsize_bif;
  wire [1:0]          arburst_bif;
  wire           arlock_bif;
  wire [3:0]          arcache_bif;
  wire [9:0]          aruser_bif;
  wire [2:0]          arprot_bif;
  wire                arvalid_bif;
  wire [10:0]         arvalid_vect_bif;
  wire                arready_bif;
  wire                wvalid_bif;
  wire                wready_bif;
  wire [127:0]        wdata_bif;
  wire [15:0]         wstrb_bif;
  wire                wlast_bif;
  wire [7:0]          bid_bif;
  wire [1:0]          bresp_bif;
  wire                buser_bif;
  wire                bvalid_bif;
  wire                bready_bif;

  wire [7:0]          rid_bif;
  wire [1:0]          rresp_bif;
  wire [127:0]        rdata_bif;
  wire                ruser_bif;
  wire                rlast_bif;
  wire                rvalid_bif;
  wire                rready_bif;


  wire                arvalid_fmt;
  wire [10:0]         arvalid_vect_fmt;
  wire [39:0]         araddr_fmt;
  wire [7:0]          arlen_fmt;
  wire [2:0]          arsize_fmt;
  wire [1:0]          arburst_fmt;
  wire           arlock_fmt;
  wire [3:0]          arcache_fmt;
  wire [2:0]          arprot_fmt;
  wire [7:0]          arid_fmt;
  wire                arready_fmt;
  wire [9:0]          aruser_fmt;
  wire                awvalid_fmt;
  wire [10:0]         awvalid_vect_fmt;
  wire [39:0]         awaddr_fmt;
  wire [7:0]          awlen_fmt;
  wire [2:0]          awsize_fmt;
  wire [1:0]          awburst_fmt;
  wire           awlock_fmt;
  wire [3:0]          awcache_fmt;
  wire [2:0]          awprot_fmt;
  wire [7:0]          awid_fmt;
  wire                awready_fmt;
  wire [9:0]          awuser_fmt;





  nic400_ib_hostcpu_axis_ib_apb_ib_slv_sse710_main u_ib_ib_slv_apb
     (
      .aresetn                          (aresetn),

      .pready                           (pready_apb),
      .prdata                           (prdata_apb),
      .pslverr                          (pslverr_apb),
      .fn_mod_lb                        (long_burst),
      .bypass_merge                     (bypass_merge_apb),
      .decode_match                     (decode_match),

      .aclk                             (aclk),
      .pclken                           (1'b1),
      .paddr                            (paddrm),
      .psel                             (pselm_apb),
      .penable                          (penablem),
      .pwrite                           (pwritem),
      .pwdata                           (pwdatam)
     );


  assign aw_fmt_src_data = {
          awid_axi4_s,
          awaddr_axi4_s[39:0],
          awlen_axi4_s,
          awsize_axi4_s,
          awburst_axi4_s,
          awlock_axi4_s,
          awcache_axi4_s,
          awuser_axi4_s,
          awprot_axi4_s,
          awvalid_vect_axi4_s};


  assign awvalid_fmt  = awvalid_axi4_s;
  assign awready_axi4_s = awready_fmt;
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
          awprot_fmt,
          awvalid_vect_fmt} = aw_fmt_dst_data;

  nic400_ib_hostcpu_axis_ib_downsize_wr_addr_fmt_sse710_main u_axi_write_address_format
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
    .downsize_m                       (downsize),
    .long_burst                       (long_burst),
    .bypass_merge                     (bypass_merge_apb)
  );
  
  
  assign awvalid_vect_bif = awvalid_vect_fmt;


nic400_ib_hostcpu_axis_ib_downsize_wr_cntrl_sse710_main u_downsize_axi_write_control
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .awfifo_valid                     (awdata_valid),
    .awfifo_ready                     (awdata_ready),
    .awfifo_data                      (awdata_data),

    .wvalid_s                         (wvalid_axi4_s),
    .wready_s                         (wready_axi4_s),
    .wlast                            (wlast_axi4_s),

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



  nic400_ib_hostcpu_axis_ib_downsize_wr_merge_buffer_sse710_main u_downsize_axi_write_merge_buffer
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .wdata_out                        (wdata_merged),
    .wstrb_out                        (wstrb_merged),

    .wdata_in                         (wdata_axi4_s),
    .wstrb_in                         (wstrb_axi4_s),

    .data_select                      (data_select),
    .merge_skid_valid                 (strb_skid_valid),
    .merge                            (merge),
    .merge_clear                      (merge_clear)
  );



  nic400_ib_hostcpu_axis_ib_downsize_wr_resp_block_sse710_main u_downsize_axi_write_response_block
  (

  .aclk                               (aclk),
  .aresetn                            (aresetn),

  .bchannel_ready                     (bdata_ready),
  .bchannel_valid                     (bdata_valid),
  .bchannel_data                      (bdata_data),

  .bready_s                           (bready_axi4_s),
  .bvalid_s                           (bvalid_axi4_s),
  .buser_s                            (buser_axi4_s),
  .bid_s                              (bid_axi4_s),
  .bresp_s                            (bresp_axi4_s),

  .bresp_m                            (bresp_bif),
  .bid_m                              (bid_bif),
  .buser_m                            (buser_bif),
  .bvalid_m                           (bvalid_bif),
  .bready_m                           (bready_bif)

  );


  assign ar_fmt_src_data = {
          arid_axi4_s,
          araddr_axi4_s[39:0],
          arlen_axi4_s,
          arsize_axi4_s,
          arburst_axi4_s,
          arlock_axi4_s,
          arcache_axi4_s,
          aruser_axi4_s,
          arprot_axi4_s,
          arvalid_vect_axi4_s};



  assign arvalid_fmt  = arvalid_axi4_s;
  assign arready_axi4_s = arready_fmt;
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
          arprot_fmt,
          arvalid_vect_fmt} = ar_fmt_dst_data;



  nic400_ib_hostcpu_axis_ib_downsize_rd_addr_fmt_sse710_main u_axi_read_address_format
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
    .arfmt_data                       (arfmt_data),
    .long_burst                       (long_burst),
    .bypass_merge                     (bypass_merge_apb)
  );

  assign arvalid_vect_bif = arvalid_vect_fmt;

  nic400_ib_hostcpu_axis_ib_downsize_rd_cntrl_sse710_main u_downsize_read_control
  (
     .aresetn                        (aresetn),
     .aclk                           (aclk),

     .rready_s                       (rready_axi4_s),

     .rbeats                         (rbeats),
     .rvalid_m                       (rvalid_bif),
     .rlast_m                        (rlast_bif),

     .rvalid_s                       (rvalid_axi4_s),
     .rlast_s                        (rlast_axi4_s),

     .rready_m                       (rready_bif)
   );





  nic400_apb_bridge_master_domain_sse710_main u_apb_async_m
  (
    .pclkm                    (aclk),
    .pclkenm                  (1'b1),
    .presetmn                 (aresetn),

    .pselm                    (pselm_apb),
    .penablem                 (penablem),
    .preadym                  (pready),

    .pwritem                  (pwritem),
    .paddrm                   (paddrm),
    .pwdatam                  (pwdatam),
    .pprotm                   (),
    .pstrbm                   (),
    .prdatam                  (prdata),
    .pslverrm                 (pslverr),

    .apbs_req_async           (apbs_req),
    .apbs_ack_async           (apbs_ack),
    .apbs_fwd_data_async      (apbs_fwd_data),
    .apbs_rev_data_async      (apbs_rev_data)
  );

  assign pslverr = decode_match ? pslverr_apb : pslverrm;
  assign pready  = decode_match ? pready_apb  : preadym;
  assign prdata  = decode_match ? prdata_apb  : prdatam;
  assign pselm   = decode_match ? 1'b0        : pselm_apb;



  assign aw_boundary_src_data = {
          awid_bif,
          awaddr_bif,
          awlen_bif,
          awsize_bif,
          awburst_bif,
          awlock_bif,
          awcache_bif,
          awuser_bif,
          awprot_bif,
          awvalid_vect_bif,downsize};


  assign aw_boundary_src_valid = awvalid_bif;
  assign awready_bif = aw_boundary_src_ready;

  assign aw_data = aw_boundary_dst_data;
  

  assign ar_boundary_src_data = {
          arid_bif,
          araddr_bif,
          arlen_bif,
          arsize_bif,
          arburst_bif,
          arlock_bif,
          arcache_bif,
          aruser_bif,
          arprot_bif,
          arvalid_vect_bif,arfmt_data};


  assign ar_boundary_src_valid = arvalid_bif;
  assign arready_bif = ar_boundary_src_ready;

  assign ar_data = ar_boundary_dst_data;
  

  assign w_boundary_src_data = {
          wdata_bif,
          wstrb_bif,
          wlast_bif};


  assign w_boundary_src_valid = wvalid_bif;
  assign wready_bif = w_boundary_src_ready;

  assign w_data = w_boundary_dst_data;
  


  assign {
          rid_bif,
          rdata_bif,
          rresp_bif,
          ruser_bif,
          rlast_bif,rbeats} = r_data;

  assign r_boundary_dst_ready = rready_bif;
  assign rvalid_bif = r_boundary_dst_valid;



  assign rid_axi4_s = rid_bif;
  assign rdata_axi4_s = rdata_bif;
  assign rresp_axi4_s = rresp_bif;
  assign ruser_axi4_s = ruser_bif;


  assign {
          bid_bif,
          bresp_bif,
          buser_bif} = b_data;

  assign b_boundary_dst_ready = bready_bif;
  assign bvalid_bif = b_boundary_dst_valid;




  nic400_ib_hostcpu_axis_ib_aw_fifo_wr_sse710_main
  u_aw_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (aw_boundary_src_valid),
     .src_data              (aw_boundary_src_data),
     .rpntr_gry             (aw_rpntr_gry),
     .rpntr_bin             (aw_rpntr_bin),

     .src_ready             (aw_boundary_src_ready),
     .dst_data              (aw_boundary_dst_data),
     .wpntr_gry             (aw_wpntr_gry)
     );




  nic400_ib_hostcpu_axis_ib_ar_fifo_wr_sse710_main
  u_ar_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (ar_boundary_src_valid),
     .src_data              (ar_boundary_src_data),
     .rpntr_gry             (ar_rpntr_gry),
     .rpntr_bin             (ar_rpntr_bin),

     .src_ready             (ar_boundary_src_ready),
     .dst_data              (ar_boundary_dst_data),
     .wpntr_gry             (ar_wpntr_gry)
     );




  nic400_ib_hostcpu_axis_ib_r_fifo_rd_sse710_main
  u_r_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (r_boundary_dst_ready),
     .wpntr_gry             (r_wpntr_gry),

     .dst_valid             (r_boundary_dst_valid),
     .rpntr_gry             (r_rpntr_gry),
     .rpntr_bin             (r_rpntr_bin)
     );




  nic400_ib_hostcpu_axis_ib_w_fifo_wr_sse710_main
  u_w_fifo_wr
    (
     .wresetn               (aresetn),
     .wclk                  (aclk),
     .src_valid             (w_boundary_src_valid),
     .src_data              (w_boundary_src_data),
     .rpntr_gry             (w_rpntr_gry),
     .rpntr_bin             (w_rpntr_bin),

     .src_ready             (w_boundary_src_ready),
     .dst_data              (w_boundary_dst_data),
     .wpntr_gry             (w_wpntr_gry)
     );




  nic400_ib_hostcpu_axis_ib_b_fifo_rd_sse710_main
  u_b_fifo_rd
    (
     .rresetn               (aresetn),
     .rclk                  (aclk),
     .dst_ready             (b_boundary_dst_ready),
     .wpntr_gry             (b_wpntr_gry),

     .dst_valid             (b_boundary_dst_valid),
     .rpntr_gry             (b_rpntr_gry),
     .rpntr_bin             (b_rpntr_bin)
     );





endmodule

`include "nic400_ib_hostcpu_axis_ib_undefs_sse710_main.v"
`include "Axi_undefs.v"



