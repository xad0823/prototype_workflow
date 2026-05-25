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


`include "nic400_ib_apb_group0_ib_defs_sse710_integration_example_f0_host_exp.v"
`include "Axi.v"

module nic400_ib_apb_group0_ib_slave_domain_sse710_integration_example_f0_host_exp
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


    a_data,
    a_valid,
    a_ready,

    d_data,
    d_valid,
    d_ready,

    w_data,
    w_valid,
    w_ready,

    aclk,
    aresetn

  );



  


  input   [17:0]      awid_axi4_s;          
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

  input   [63:0]      wdata_axi4_s;         
  input   [7:0]       wstrb_axi4_s;         
  input               wlast_axi4_s;         
  input               wvalid_axi4_s;        
  output              wready_axi4_s;        

  output  [17:0]      bid_axi4_s;           
  output  [1:0]       bresp_axi4_s;         
  output              bvalid_axi4_s;        
  input               bready_axi4_s;        

  input   [17:0]      arid_axi4_s;          
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

  output  [17:0]      rid_axi4_s;           
  output  [63:0]      rdata_axi4_s;         
  output  [1:0]       rresp_axi4_s;         
  output              rlast_axi4_s;         
  output              rvalid_axi4_s;        
  input               rready_axi4_s;        



  output  [88:0]      a_data;               
  output              a_valid;              
  input               a_ready;              

  input   [87:0]      d_data;               
  input               d_valid;              
  output              d_ready;              

  output  [72:0]      w_data;               
  output              w_valid;              
  input               w_ready;              

  input               aclk;                 
  input               aresetn;              
   


  
  wire [74:0]         aw_slave_port_src_data;     
  wire [74:0]         aw_slave_port_dst_data;     

  wire                aw_slave_port_dst_valid;
  wire                aw_slave_port_dst_ready;
  wire                aw_slave_port_src_valid;
  wire                aw_slave_port_src_ready;

  
  wire [74:0]         ar_slave_port_src_data;     
  wire [74:0]         ar_slave_port_dst_data;     

  wire                ar_slave_port_dst_valid;
  wire                ar_slave_port_dst_ready;
  wire                ar_slave_port_src_valid;
  wire                ar_slave_port_src_ready;

  wire [84:0]         r_slave_port_src_data;     
  wire [84:0]         r_slave_port_dst_data;     

  wire [72:0]         w_slave_port_src_data;     
  wire [72:0]         w_slave_port_dst_data;     

  wire [19:0]         b_slave_port_src_data;     
  wire [19:0]         b_slave_port_dst_data;     



  wire [21:0]         bdata_data;
  wire                bdata_valid;
  wire                bdata_ready;

  wire [10:0]         awdata_data;
  wire                awdata_valid;
  wire                awdata_ready;

  wire                merge;
  wire                merge_clear;
  wire [1:0]          data_select;
  wire                strb_skid_valid;

  wire [63:0]         wdata_merged;
  wire [7:0]          wstrb_merged;
  wire [11:0]         arfmt_data;
  wire [1:0]          rbeats;
  
  wire                downsize;




  wire [17:0]         bid_bif;
  wire [1:0]          bresp_bif;
  wire                bvalid_bif;
  wire                bready_bif;

  wire                rlast_bif;
  wire                rvalid_bif;
  wire                rready_bif;




  wire                awrite_bif;
  wire                avalid_bif;
  wire [31:0]         aaddr_bif;
  wire [7:0]          alen_bif;
  wire [2:0]          asize_bif;
  wire [1:0]          aburst_bif;
  wire           alock_bif;
  wire [3:0]          acache_bif;
  wire [2:0]          aprot_bif;
  wire [17:0]         aid_bif;
  wire                aready_bif;
  wire [3:0]          aregion_bif;

  wire                dbnr_bif;
  wire                dvalid_bif;
  wire                dlast_bif;
  wire [63:0]         ddata_bif;
  wire [1:0]          dresp_bif;
  wire [17:0]         did_bif;
  wire                dready_bif;
  wire                wvalid_bif;
  wire                wready_bif;
  wire [63:0]         wdata_bif;
  wire [7:0]          wstrb_bif;
  wire                wlast_bif;


  wire                awrite_iif;
  wire                avalid_iif;
  wire [31:0]         aaddr_iif;
  wire [7:0]          alen_iif;
  wire [2:0]          asize_iif;
  wire [1:0]          aburst_iif;
  wire           alock_iif;
  wire [3:0]          acache_iif;
  wire [2:0]          aprot_iif;
  wire [17:0]         aid_iif;
  wire                aready_iif;
  wire [3:0]          aregion_iif;

  wire                dbnr_iif;
  wire                dvalid_iif;
  wire                dlast_iif;
  wire [63:0]         ddata_iif;
  wire [1:0]          dresp_iif;
  wire [17:0]         did_iif;
  wire                dready_iif;


  wire [17:0]         bid_iif;
  wire [1:0]          bresp_iif;
  wire                bvalid_iif;
  wire                bready_iif;

  wire                rlast_iif;
  wire                rvalid_iif;
  wire                rready_iif;



  wire                arvalid_axi_r;
  wire [31:0]         araddr_axi_r;
  wire [7:0]          arlen_axi_r;
  wire [2:0]          arsize_axi_r;
  wire [1:0]          arburst_axi_r;
  wire           arlock_axi_r;
  wire [3:0]          arcache_axi_r;
  wire [2:0]          arprot_axi_r;
  wire [3:0]          arregion_axi_r;
  wire [17:0]         arid_axi_r;
  wire                arready_axi_r;

  wire                awvalid_axi_r;
  wire [31:0]         awaddr_axi_r;
  wire [7:0]          awlen_axi_r;
  wire [2:0]          awsize_axi_r;
  wire [1:0]          awburst_axi_r;
  wire           awlock_axi_r;
  wire [3:0]          awcache_axi_r;
  wire [2:0]          awprot_axi_r;
  wire [3:0]          awregion_axi_r;
  wire [17:0]         awid_axi_r;
  wire                awready_axi_r;


  wire                rvalid_axi_r;
  wire                rlast_axi_r;
  wire [63:0]         rdata_axi_r;
  wire [1:0]          rresp_axi_r;
  wire [17:0]         rid_axi_r;
  wire                rready_axi_r;

  wire                wvalid_axi_r;
  wire                wlast_axi_r;
  wire [63:0]         wdata_axi_r;
  wire [7:0]          wstrb_axi_r;
  wire                wready_axi_r;

  wire                bvalid_axi_r;
  wire [1:0]          bresp_axi_r;
  wire [17:0]         bid_axi_r;
  wire                bready_axi_r;






  nic400_ib_apb_group0_ib_axi_to_itb_sse710_integration_example_f0_host_exp u_axi_to_itb
  (
    .awid           (awid_axi_r),
    .awaddr         (awaddr_axi_r),
    .awlen          (awlen_axi_r),
    .awsize         (awsize_axi_r),
    .awburst        (awburst_axi_r),
    .awlock         (awlock_axi_r),
    .awcache        (awcache_axi_r),
    .awprot         (awprot_axi_r),
    .awregion       (awregion_axi_r),
    .awvalid        (awvalid_axi_r),
    .awready        (awready_axi_r),

    
    .bid            (bid_axi_r),
    .bresp          (bresp_axi_r),
    .bvalid         (bvalid_axi_r),
    .bready         (bready_axi_r),
    
    .arid           (arid_axi_r),
    .araddr         (araddr_axi_r),
    .arlen          (arlen_axi_r),
    .arsize         (arsize_axi_r),
    .arburst        (arburst_axi_r),
    .arlock         (arlock_axi_r),
    .arcache        (arcache_axi_r),
    .arprot         (arprot_axi_r),
    .arregion       (arregion_axi_r),
    .arvalid        (arvalid_axi_r),
    .arready        (arready_axi_r),
    
    .rid            (rid_axi_r),
    .rdata          (rdata_axi_r),
    .rresp          (rresp_axi_r),
    .rlast          (rlast_axi_r),
    .rvalid         (rvalid_axi_r),
    .rready         (rready_axi_r),

    .awrite         (awrite_iif),
    .aid            (aid_iif),
    .aaddr          (aaddr_iif),
    .alen           (alen_iif),
    .asize          (asize_iif),
    .aburst         (aburst_iif),
    .alock          (alock_iif),
    .acache         (acache_iif),
    .aprot          (aprot_iif),
    .aregion        (aregion_iif),
    .avalid         (avalid_iif),
    .aready         (aready_iif),

    .dbnr           (dbnr_iif),
    .did            (did_iif),
    .ddata          (ddata_iif),
    .dresp          (dresp_iif),
    .dlast          (dlast_iif),
    .dvalid         (dvalid_iif),
    .dready         (dready_iif),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );


  assign awrite_bif  = awrite_iif;

  assign bready_iif  = dready_iif & dvalid_iif & dbnr_iif;
  assign rready_iif  = dready_iif & dvalid_iif & ~dbnr_iif;
  assign dvalid_iif  = bvalid_iif | rvalid_iif;
  assign dready_bif  = (dbnr_bif) ? bready_bif : rready_bif;
  assign bvalid_bif  = dvalid_bif & dbnr_bif;
  assign rvalid_bif  = dvalid_bif & ~dbnr_bif;
  assign dbnr_iif    = dbnr_bif;



  nic400_ib_apb_group0_ib_downsize_itb_addr_fmt_sse710_integration_example_f0_host_exp u_itb_address_format
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

    .bdata_data                       (bdata_data),
    .bdata_valid                      (bdata_valid),
    .bdata_ready                      (bdata_ready),

    .awfmt_valid                      (awdata_valid),
    .awfmt_ready                      (awdata_ready),
    .awfmt_data                       (awdata_data),


    .aid_s                            (aid_iif),
    .awrite_s                         (awrite_iif),
    .aaddr_s                          (aaddr_iif),
    .alen_s                           (alen_iif),
    .asize_s                          (asize_iif),
    .aburst_s                         (aburst_iif),
    .avalid_s                         (avalid_iif),
    .aready_s                         (aready_iif),
    .aprot_s                          (aprot_iif),
    .acache_s                         (acache_iif),
    .alock_s                          (alock_iif),

    .aid_m                            (aid_bif),
    .aaddr_m                          (aaddr_bif),
    .alen_m                           (alen_bif),
    .asize_m                          (asize_bif),
    .aburst_m                         (aburst_bif),
    .avalid_m                         (avalid_bif),
    .aready_m                         (aready_bif),
    .aprot_m                          (aprot_bif),
    .alock_m                          (alock_bif),
    .acache_m                         (acache_bif),
    .arfmt_data                       (arfmt_data),
    .downsize_m                       (downsize)
  );
  
  
  assign aregion_bif = aregion_iif;


nic400_ib_apb_group0_ib_downsize_wr_cntrl_sse710_integration_example_f0_host_exp u_downsize_axi_write_control
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



  nic400_ib_apb_group0_ib_downsize_wr_merge_buffer_sse710_integration_example_f0_host_exp u_downsize_axi_write_merge_buffer
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



  nic400_ib_apb_group0_ib_downsize_wr_resp_block_sse710_integration_example_f0_host_exp u_downsize_axi_write_response_block
  (

  .aclk                               (aclk),
  .aresetn                            (aresetn),

  .bchannel_ready                     (bdata_ready),
  .bchannel_valid                     (bdata_valid),
  .bchannel_data                      (bdata_data),

  .bready_s                           (bready_iif),
  .bvalid_s                           (bvalid_iif),
  .bid_s                              (bid_iif),
  .bresp_s                            (bresp_iif),

  .bresp_m                            (bresp_bif),
  .bid_m                              (bid_bif),
  .bvalid_m                           (bvalid_bif),
  .bready_m                           (bready_bif)

  );


  assign bid_bif   = did_bif;
  assign bresp_bif = dresp_bif;


  nic400_ib_apb_group0_ib_downsize_rd_cntrl_sse710_integration_example_f0_host_exp u_downsize_read_control
  (
     .aresetn                        (aresetn),
     .aclk                           (aclk),

     .rready_s                       (rready_iif),

     .rbeats                         (rbeats),
     .rvalid_m                       (rvalid_bif),
     .rlast_m                        (rlast_bif),

     .rvalid_s                       (rvalid_iif),
     .rlast_s                        (rlast_iif),

     .rready_m                       (rready_bif)
   );



  assign rlast_bif   = dlast_bif;

  assign dlast_iif   = rlast_iif;
  assign dresp_iif   = (dbnr_iif) ? bresp_iif : dresp_bif;
  assign did_iif     = (dbnr_iif) ? bid_iif : did_bif;
  assign ddata_iif   = ddata_bif;





  assign a_data = {
          aid_bif,
          awrite_bif,
          aaddr_bif,
          alen_bif,
          asize_bif,
          aburst_bif,
          alock_bif,
          acache_bif,
          aregion_bif,
          aprot_bif,downsize,arfmt_data};


  assign a_valid = avalid_bif;

  assign aready_bif = a_ready;


  assign w_data = {
          wdata_bif,
          wstrb_bif,
          wlast_bif};


  assign w_valid = wvalid_bif;

  assign wready_bif = w_ready;



  assign {
          did_bif,
          dbnr_bif,
          ddata_bif,
          dresp_bif,
          dlast_bif,rbeats} = d_data;

  assign d_ready = dready_bif;
  assign dvalid_bif = d_valid;





  assign aw_slave_port_src_data = {
          awid_axi4_s,
          awaddr_axi4_s[31:0],
          awlen_axi4_s,
          awsize_axi4_s,
          awburst_axi4_s,
          awlock_axi4_s,
          awcache_axi4_s,
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


  nic400_ib_apb_group0_ib_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       75  
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




  nic400_ib_apb_group0_ib_chan_slice_sse710_integration_example_f0_host_exp
    #(
       `RS_REV_REG,  
       75  
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

`include "nic400_ib_apb_group0_ib_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"



