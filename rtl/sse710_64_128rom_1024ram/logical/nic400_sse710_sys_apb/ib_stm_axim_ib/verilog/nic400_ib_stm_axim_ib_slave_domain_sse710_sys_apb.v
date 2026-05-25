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


`include "nic400_ib_stm_axim_ib_defs_sse710_sys_apb.v"
`include "Axi.v"

module nic400_ib_stm_axim_ib_slave_domain_sse710_sys_apb
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
    awregion_axi4_s,
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
    arregion_axi4_s,
    arready_axi4_s,

    rid_axi4_s,
    rdata_axi4_s,
    rresp_axi4_s,
    rlast_axi4_s,
    rvalid_axi4_s,
    rready_axi4_s,

    awuser_axi4_s,
    aruser_axi4_s,


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



  


  input   [11:0]      awid_axi4_s;          
  input   [31:0]      awaddr_axi4_s;        
  input   [7:0]       awlen_axi4_s;         
  input   [2:0]       awsize_axi4_s;        
  input   [1:0]       awburst_axi4_s;       
  input               awlock_axi4_s;        
  input   [3:0]       awcache_axi4_s;       
  input   [2:0]       awprot_axi4_s;        
  input               awvalid_axi4_s;       
  input   [3:0]       awregion_axi4_s;      
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
  input   [31:0]      araddr_axi4_s;        
  input   [7:0]       arlen_axi4_s;         
  input   [2:0]       arsize_axi4_s;        
  input   [1:0]       arburst_axi4_s;       
  input               arlock_axi4_s;        
  input   [3:0]       arcache_axi4_s;       
  input   [2:0]       arprot_axi4_s;        
  input               arvalid_axi4_s;       
  input   [3:0]       arregion_axi4_s;      
  output              arready_axi4_s;       

  output  [11:0]      rid_axi4_s;           
  output  [31:0]      rdata_axi4_s;         
  output  [1:0]       rresp_axi4_s;         
  output              rlast_axi4_s;         
  output              rvalid_axi4_s;        
  input               rready_axi4_s;        

  input   [9:0]       awuser_axi4_s;        
  input   [9:0]       aruser_axi4_s;        



  output  [78:0]      aw_data;              
  output              aw_valid;             
  input               aw_ready;             

  input   [13:0]      b_data;               
  input               b_valid;              
  output              b_ready;              

  output  [78:0]      ar_data;              
  output              ar_valid;             
  input               ar_ready;             

  input   [78:0]      r_data;               
  input               r_valid;              
  output              r_ready;              

  output  [72:0]      w_data;               
  output              w_valid;              
  input               w_ready;              

  input               aclk;                 
  input               aresetn;              
   


  
  wire [78:0]         aw_slave_port_src_data;     
  wire [78:0]         aw_slave_port_dst_data;     

  wire                aw_slave_port_dst_valid;
  wire                aw_slave_port_dst_ready;
  wire                aw_slave_port_src_valid;
  wire                aw_slave_port_src_ready;

  
  wire [78:0]         ar_slave_port_src_data;     
  wire [78:0]         ar_slave_port_dst_data;     

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



  wire [12:0]         bdata_data;
  wire                bdata_valid;
  wire                bdata_ready;

  wire [15:0]         awdata_data;
  wire                awdata_valid;
  wire                awdata_ready;

  wire                merge;
  wire                merge_clear;
  wire [1:0]          data_select;
  wire                strb_skid_valid;

  wire [63:0]         wdata_merged;
  wire [7:0]          wstrb_merged;
  wire [26:0]         arfifo_data;
  wire                arfifo_valid;
  wire                arfifo_ready;  
  wire  [78:0]        aw_fmt_src_data;
  wire  [78:0]        ar_fmt_src_data;
  wire  [78:0]        aw_fmt_dst_data;
  wire  [78:0]        ar_fmt_dst_data;




  wire [11:0]         awid_bif;
  wire [31:0]         awaddr_bif;
  wire [7:0]          awlen_bif;
  wire [2:0]          awsize_bif;
  wire [1:0]          awburst_bif;
  wire           awlock_bif;
  wire [3:0]          awcache_bif;
  wire [9:0]          awuser_bif;
  wire [2:0]          awprot_bif;
  wire [3:0]          awregion_bif;
  wire                awvalid_bif;
  wire                awready_bif;

  wire [11:0]         arid_bif;
  wire [31:0]         araddr_bif;
  wire [7:0]          arlen_bif;
  wire [2:0]          arsize_bif;
  wire [1:0]          arburst_bif;
  wire           arlock_bif;
  wire [3:0]          arcache_bif;
  wire [9:0]          aruser_bif;
  wire [2:0]          arprot_bif;
  wire [3:0]          arregion_bif;
  wire                arvalid_bif;
  wire                arready_bif;
  wire                wvalid_bif;
  wire                wready_bif;
  wire [63:0]         wdata_bif;
  wire [7:0]          wstrb_bif;
  wire                wlast_bif;
  wire [11:0]         bid_bif;
  wire [1:0]          bresp_bif;
  wire                bvalid_bif;
  wire                bready_bif;

  wire [11:0]         rid_bif;
  wire [1:0]          rresp_bif;
  wire [63:0]         rdata_bif;
  wire                rlast_bif;
  wire                rvalid_bif;
  wire                rready_bif;


  wire                arvalid_fmt;
  wire [31:0]         araddr_fmt;
  wire [7:0]          arlen_fmt;
  wire [2:0]          arsize_fmt;
  wire [1:0]          arburst_fmt;
  wire           arlock_fmt;
  wire [3:0]          arcache_fmt;
  wire [2:0]          arprot_fmt;
  wire [3:0]          arregion_fmt;
  wire [11:0]         arid_fmt;
  wire                arready_fmt;
  wire [9:0]          aruser_fmt;
  wire                awvalid_fmt;
  wire [31:0]         awaddr_fmt;
  wire [7:0]          awlen_fmt;
  wire [2:0]          awsize_fmt;
  wire [1:0]          awburst_fmt;
  wire           awlock_fmt;
  wire [3:0]          awcache_fmt;
  wire [2:0]          awprot_fmt;
  wire [3:0]          awregion_fmt;
  wire [11:0]         awid_fmt;
  wire                awready_fmt;
  wire [9:0]          awuser_fmt;


  wire                arvalid_axi_r;
  wire [31:0]         araddr_axi_r;
  wire [7:0]          arlen_axi_r;
  wire [2:0]          arsize_axi_r;
  wire [1:0]          arburst_axi_r;
  wire           arlock_axi_r;
  wire [3:0]          arcache_axi_r;
  wire [2:0]          arprot_axi_r;
  wire [3:0]          arregion_axi_r;
  wire [11:0]         arid_axi_r;
  wire                arready_axi_r;
  wire [9:0]          aruser_axi_r;

  wire                awvalid_axi_r;
  wire [31:0]         awaddr_axi_r;
  wire [7:0]          awlen_axi_r;
  wire [2:0]          awsize_axi_r;
  wire [1:0]          awburst_axi_r;
  wire           awlock_axi_r;
  wire [3:0]          awcache_axi_r;
  wire [2:0]          awprot_axi_r;
  wire [3:0]          awregion_axi_r;
  wire [11:0]         awid_axi_r;
  wire                awready_axi_r;
  wire [9:0]          awuser_axi_r;


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





  assign aw_fmt_src_data = {
          awid_axi_r,
          awaddr_axi_r[31:0],
          awlen_axi_r,
          awsize_axi_r,
          awburst_axi_r,
          awlock_axi_r,
          awcache_axi_r,
          awuser_axi_r,
          awregion_axi_r,
          awprot_axi_r};


  assign awvalid_fmt  = awvalid_axi_r;
  assign awready_axi_r = awready_fmt;
  assign aw_fmt_dst_data  = aw_fmt_src_data;


  assign {
          awid_fmt,
          awaddr_fmt[31:0],
          awlen_fmt,
          awsize_fmt,
          awburst_fmt,
          awlock_fmt,
          awcache_fmt,
          awuser_fmt,
          awregion_fmt,
          awprot_fmt} = aw_fmt_dst_data;

  nic400_ib_stm_axim_ib_upsize_wr_addr_fmt_sse710_sys_apb u_axi_write_address_format
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
    .awcache_m                        (awcache_bif)
  );
  
  
  assign awregion_bif = awregion_fmt;


nic400_ib_stm_axim_ib_upsize_wr_cntrl_sse710_sys_apb u_upsize_axi_write_control
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .awfifo_valid                     (awdata_valid),
    .awfifo_ready                     (awdata_ready),
    .awfifo_data                      (awdata_data),

    .wvalid_s                         (wvalid_axi_r),
    .wready_s                         (wready_axi_r),
    .wlast                            (wlast_axi_r),

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



  nic400_ib_stm_axim_ib_upsize_wr_merge_buffer_sse710_sys_apb u_upsize_axi_write_merge_buffer
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .wdata_out                        (wdata_merged),
    .wstrb_out                        (wstrb_merged),

    .wdata_in                         (wdata_axi_r),
    .wstrb_in                         (wstrb_axi_r),

    .data_select                      (data_select),
    .merge_skid_valid                 (strb_skid_valid),
    .merge                            (merge),
    .merge_clear                      (merge_clear)
  );



  nic400_ib_stm_axim_ib_upsize_wr_resp_block_sse710_sys_apb u_upsize_axi_write_response_block
  (

  .aclk                               (aclk),
  .aresetn                            (aresetn),

  .bchannel_ready                     (bdata_ready),
  .bchannel_valid                     (bdata_valid),
  .bchannel_data                      (bdata_data),

  .bready_s                           (bready_axi_r),
  .bvalid_s                           (bvalid_axi_r),
  .bid_s                              (bid_axi_r),
  .bresp_s                            (bresp_axi_r),

  .bresp_m                            (bresp_bif),
  .bid_m                              (bid_bif),
  .bvalid_m                           (bvalid_bif),
  .bready_m                           (bready_bif)

  );


  assign ar_fmt_src_data = {
          arid_axi_r,
          araddr_axi_r[31:0],
          arlen_axi_r,
          arsize_axi_r,
          arburst_axi_r,
          arlock_axi_r,
          arcache_axi_r,
          aruser_axi_r,
          arregion_axi_r,
          arprot_axi_r};



  assign arvalid_fmt  = arvalid_axi_r;
  assign arready_axi_r = arready_fmt;
  assign ar_fmt_dst_data  = ar_fmt_src_data;


  assign {
          arid_fmt,
          araddr_fmt[31:0],
          arlen_fmt,
          arsize_fmt,
          arburst_fmt,
          arlock_fmt,
          arcache_fmt,
          aruser_fmt,
          arregion_fmt,
          arprot_fmt} = ar_fmt_dst_data;



  nic400_ib_stm_axim_ib_upsize_rd_addr_fmt_sse710_sys_apb u_axi_read_address_format
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .ardata_valid                     (arfifo_valid),
    .ardata_ready                     (arfifo_ready),
    .ardata_data                      (arfifo_data),

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
    .arcache_m                        (arcache_bif)
  );

  assign arregion_bif = arregion_fmt;


  nic400_ib_stm_axim_ib_upsize_rd_chan_sse710_sys_apb u_upsize_axi_read_channel
  (

  .aresetn                           (aresetn),
  .aclk                              (aclk),

  .archannel_data                    (arfifo_data),
  .archannel_valid                   (arfifo_valid),
  .archannel_ready                   (arfifo_ready),

  .rvalid_s                          (rvalid_axi_r),
  .rdata_s                           (rdata_axi_r),
  .rlast_s                           (rlast_axi_r),
  .rid_s                             (rid_axi_r),
  .rresp_s                           (rresp_axi_r),

  .rready_s                          (rready_axi_r),

  .rvalid_m                          (rvalid_bif),
  .rdata_m                           (rdata_bif),
  .rlast_m                           (rlast_bif),
  .rid_m                             (rid_bif),
  .rresp_m                           (rresp_bif),
  .rready_m                          (rready_bif)

  );






  assign aw_data = {
          awid_bif,
          awaddr_bif,
          awlen_bif,
          awsize_bif,
          awburst_bif,
          awlock_bif,
          awcache_bif,
          awuser_bif,
          awregion_bif,
          awprot_bif};


  assign aw_valid = awvalid_bif;

  assign awready_bif = aw_ready;


  assign ar_data = {
          arid_bif,
          araddr_bif,
          arlen_bif,
          arsize_bif,
          arburst_bif,
          arlock_bif,
          arcache_bif,
          aruser_bif,
          arregion_bif,
          arprot_bif};


  assign ar_valid = arvalid_bif;

  assign arready_bif = ar_ready;


  assign w_data = {
          wdata_bif,
          wstrb_bif,
          wlast_bif};


  assign w_valid = wvalid_bif;

  assign wready_bif = w_ready;



  assign {
          rid_bif,
          rdata_bif,
          rresp_bif,
          rlast_bif} = r_data;

  assign r_ready = rready_bif;
  assign rvalid_bif = r_valid;





  assign {
          bid_bif,
          bresp_bif} = b_data;

  assign b_ready = bready_bif;
  assign bvalid_bif = b_valid;





  assign aw_slave_port_src_data = {
          awid_axi4_s,
          awaddr_axi4_s[31:0],
          awlen_axi4_s,
          awsize_axi4_s,
          awburst_axi4_s,
          awlock_axi4_s,
          awcache_axi4_s,
          awuser_axi4_s,
          awregion_axi4_s,
          awprot_axi4_s};

  assign {
          awid_axi_r,
          awaddr_axi_r[31:0],
          awlen_axi_r,
          awsize_axi_r,
          awburst_axi_r,
          awlock_axi_r,
          awcache_axi_r,
          awuser_axi_r,
          awregion_axi_r,
          awprot_axi_r} = aw_slave_port_dst_data;


  assign awvalid_axi_r = aw_slave_port_dst_valid;
  assign aw_slave_port_dst_ready = awready_axi_r;

  assign aw_slave_port_src_valid = awvalid_axi4_s;
  assign awready_axi4_s = aw_slave_port_src_ready;



  assign ar_slave_port_src_data = {
          arid_axi4_s,
          araddr_axi4_s[31:0],
          arlen_axi4_s,
          arsize_axi4_s,
          arburst_axi4_s,
          arlock_axi4_s,
          arcache_axi4_s,
          aruser_axi4_s,
          arregion_axi4_s,
          arprot_axi4_s};

  assign {
          arid_axi_r,
          araddr_axi_r[31:0],
          arlen_axi_r,
          arsize_axi_r,
          arburst_axi_r,
          arlock_axi_r,
          arcache_axi_r,
          aruser_axi_r,
          arregion_axi_r,
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


  nic400_ib_stm_axim_ib_chan_slice_sse710_sys_apb
    #(
       `RS_REV_REG,  
       79  
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




  nic400_ib_stm_axim_ib_chan_slice_sse710_sys_apb
    #(
       `RS_REV_REG,  
       79  
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



   
`endif

endmodule

`include "nic400_ib_stm_axim_ib_undefs_sse710_sys_apb.v"
`include "Axi_undefs.v"



