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



`include "nic400_ib_gpio_ahb_m_ib_defs_sse710_integration_example_f0_host_exp.v"

`include "Axi.v"

module nic400_ib_gpio_ahb_m_ib_master_domain_sse710_integration_example_f0_host_exp
  (
  

    aid_itb_m,
    aaddr_itb_m,
    alen_itb_m,
    asize_itb_m,
    aburst_itb_m,
    alock_itb_m,
    acache_itb_m,
    aprot_itb_m,
    awrite_itb_m,
    avalid_itb_m,
    aregion_itb_m,
    aready_itb_m,

    wdata_itb_m,
    wstrb_itb_m,
    wlast_itb_m,
    wvalid_itb_m,
    wready_itb_m,

    did_itb_m,
    ddata_itb_m,
    dresp_itb_m,
    dlast_itb_m,
    dbnr_itb_m,
    dvalid_itb_m,
    dready_itb_m,


    a_data_async,
    a_rpntr_gry_async,
    a_rpntr_bin,
    a_wpntr_gry_async,

    d_data_async,
    d_rpntr_gry_async,
    d_rpntr_bin,
    d_wpntr_gry_async,

    w_data_async,
    w_rpntr_gry_async,
    w_rpntr_bin,
    w_wpntr_gry_async,

    aclk_m,
    aresetn_m

  );




  


  output  [17:0]      aid_itb_m;              
  output  [31:0]      aaddr_itb_m;            
  output  [7:0]       alen_itb_m;             
  output  [2:0]       asize_itb_m;            
  output  [1:0]       aburst_itb_m;           
  output              alock_itb_m;            
  output  [3:0]       acache_itb_m;           
  output  [2:0]       aprot_itb_m;            
  output              awrite_itb_m;           
  output              avalid_itb_m;           
  output  [3:0]       aregion_itb_m;          
  input               aready_itb_m;           

  output  [31:0]      wdata_itb_m;            
  output  [3:0]       wstrb_itb_m;            
  output              wlast_itb_m;            
  output              wvalid_itb_m;           
  input               wready_itb_m;           

  input   [17:0]      did_itb_m;              
  input   [31:0]      ddata_itb_m;            
  input   [1:0]       dresp_itb_m;            
  input               dlast_itb_m;            
  input               dbnr_itb_m;             
  input               dvalid_itb_m;           
  output              dready_itb_m;           



  input   [88:0]      a_data_async;           
  output  [3:0]       a_rpntr_gry_async;      
  output  [2:0]       a_rpntr_bin;            
  input   [3:0]       a_wpntr_gry_async;      

  output  [87:0]      d_data_async;           
  input   [3:0]       d_rpntr_gry_async;      
  input   [2:0]       d_rpntr_bin;            
  output  [3:0]       d_wpntr_gry_async;      

  input   [72:0]      w_data_async;           
  output  [3:0]       w_rpntr_gry_async;      
  output  [2:0]       w_rpntr_bin;            
  input   [3:0]       w_wpntr_gry_async;      

  input               aclk_m;           
  input               aresetn_m;        



  
  wire                a_boundary_dst_valid;
  wire                a_boundary_dst_ready;

  wire [88:0]         a_boundary_dst_data;     


  
  wire                w_boundary_dst_valid;
  wire                w_boundary_dst_ready;

  wire [72:0]         w_boundary_dst_data;     


  
  wire                d_boundary_src_valid;
  wire                d_boundary_src_ready;

  wire [87:0]         d_boundary_src_data;     
  wire [87:0]         d_boundary_dst_data;     


  wire [3:0]          a_rpntr_gry_async;           
  wire [2:0]          a_rpntr_bin;           
  wire [3:0]          a_wpntr_gry_async;           

  wire [3:0]          w_rpntr_gry_async;           
  wire [2:0]          w_rpntr_bin;           
  wire [3:0]          w_wpntr_gry_async;           

  wire [3:0]          d_rpntr_gry_async;           
  wire [2:0]          d_rpntr_bin;           
  wire [3:0]          d_wpntr_gry_async;           


  wire                awrite_itb_m;
  wire                avalid_itb_m;
  wire [31:0]         aaddr_itb_m;
  wire [7:0]          alen_itb_m;
  wire [2:0]          asize_itb_m;
  wire [1:0]          aburst_itb_m;
  wire           alock_itb_m;
  wire [3:0]          acache_itb_m;
  wire [2:0]          aprot_itb_m;
  wire [17:0]         aid_itb_m;
  wire                aready_itb_m;
  wire [3:0]          aregion_itb_m;


  wire                dbnr_itb_m;
  wire                dvalid_itb_m;
  wire                dlast_itb_m;
  wire [31:0]         ddata_itb_m;
  wire [1:0]          dresp_itb_m;
  wire [17:0]         did_itb_m;
  wire                dready_itb_m;


  wire [31:0]         awaddr_itb_m;
  wire [7:0]          awlen_itb_m;
  wire [1:0]          awsize_itb_m;
  wire [1:0]          awburst_itb_m;
  wire                awvalid_itb_m;
  wire                awready_itb_m;

  wire [17:0]         arid_itb_m;
  wire [31:0]         araddr_itb_m;
  wire [2:0]          arsize_itb_m;
  wire                arvalid_itb_m;
  wire                arready_itb_m;

  wire [17:0]         rid_itb_m;
  wire [31:0]         rdata_itb_m;
  wire [1:0]          rresp_itb_m;
  wire                rlast_itb_m;
  wire                rvalid_itb_m;
  wire                rready_itb_m;



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


  wire                avalid_bif;
  wire                aready_bif;

  wire                dbnr_bif;
  wire                dvalid_bif;
  wire                dlast_bif;
  wire [63:0]         ddata_bif;
  wire [1:0]          dresp_bif;
  wire [17:0]         did_bif;
  wire                dready_bif;






  assign {
          aid_itb_m,
          awrite_itb_m,
          aaddr_itb_m[31:0],
          alen_itb_m,
          asize_itb_m,
          aburst_itb_m,
          alock_itb_m,
          acache_itb_m,
          aregion_itb_m,
          aprot_itb_m,downsize,arfmt_data} = a_boundary_dst_data;

  

  assign avalid_bif = a_boundary_dst_valid;
  assign a_boundary_dst_ready = aready_bif;







  assign {
          wdata_bif,
          wstrb_bif,
          wlast_bif} = w_boundary_dst_data;

  

  assign wvalid_bif = w_boundary_dst_valid;
  assign w_boundary_dst_ready = wready_bif;





  assign d_boundary_src_data = {
          did_bif,
          dbnr_bif,
          ddata_bif,
          dresp_bif,
          dlast_bif,rbeats};

  assign d_boundary_src_valid = dvalid_bif;
  assign dready_bif = d_boundary_src_ready;

  assign d_data_async = d_boundary_dst_data;
  

  nic400_ib_gpio_ahb_m_ib_a_fifo_rd_sse710_integration_example_f0_host_exp
  u_a_fifo_rd
    (
     .rresetn               (aresetn_m),
     .rclk                  (aclk_m),
     .src_data              (a_data_async),
     .dst_ready             (a_boundary_dst_ready),
     .wpntr_gry_async       (a_wpntr_gry_async),

     .dst_data              (a_boundary_dst_data),
     .dst_valid             (a_boundary_dst_valid),
     .rpntr_gry_async       (a_rpntr_gry_async),
     .rpntr_bin             (a_rpntr_bin)
     );




  nic400_ib_gpio_ahb_m_ib_w_fifo_rd_sse710_integration_example_f0_host_exp
  u_w_fifo_rd
    (
     .rresetn               (aresetn_m),
     .rclk                  (aclk_m),
     .src_data              (w_data_async),
     .dst_ready             (w_boundary_dst_ready),
     .wpntr_gry_async       (w_wpntr_gry_async),

     .dst_data              (w_boundary_dst_data),
     .dst_valid             (w_boundary_dst_valid),
     .rpntr_gry_async       (w_rpntr_gry_async),
     .rpntr_bin             (w_rpntr_bin)
     );




  nic400_ib_gpio_ahb_m_ib_d_fifo_wr_sse710_integration_example_f0_host_exp
  u_d_fifo_wr
    (
     .wresetn               (aresetn_m),
     .wclk                  (aclk_m),
     .src_valid             (d_boundary_src_valid),
     .src_data              (d_boundary_src_data),
     .rpntr_gry_async       (d_rpntr_gry_async),
     .rpntr_bin             (d_rpntr_bin),

     .src_ready             (d_boundary_src_ready),
     .dst_data              (d_boundary_dst_data),
     .wpntr_gry_async       (d_wpntr_gry_async)
     );



  nic400_ib_gpio_ahb_m_ib_downsize_wr_mux_sse710_integration_example_f0_host_exp u_downsize_write_mux
  (
    .aresetn                          (aresetn_m),
    .aclk                             (aclk_m),

    .awaddr_s                         (awaddr_itb_m[2:0]),
    .awlen_s                          (awlen_itb_m),
    .awsize_s                         (awsize_itb_m[1:0]),
    .awburst_s                        (awburst_itb_m),

    .awvalid_s                        (awvalid_bif),
    .awready_s                        (awready_bif),

    .awvalid_m                        (awvalid_itb_m),
    .awready_m                        (awready_itb_m),

    .wdata_s                          (wdata_bif),
    .wstrb_s                          (wstrb_bif),
    .wlast_s                          (wlast_bif),

    .wready_s                         (wready_bif),
    .wvalid_s                         (wvalid_bif),

    .wdata_m                          (wdata_itb_m),
    .wstrb_m                          (wstrb_itb_m),
    .wlast_m                          (wlast_itb_m),

    .wready_m                         (wready_itb_m),
    .wvalid_m                         (wvalid_itb_m),

    .downsize                         (downsize)

  );




  assign awaddr_itb_m  = aaddr_itb_m;
  assign awlen_itb_m   = alen_itb_m;
  assign awsize_itb_m  = asize_itb_m[1:0];
  assign awburst_itb_m = aburst_itb_m;
  assign awvalid_bif = avalid_bif & awrite_itb_m;
  assign aready_bif  = awvalid_bif ? awready_bif : arready_bif;
  assign avalid_itb_m  = awvalid_itb_m | arvalid_itb_m;
  assign awready_itb_m = aready_itb_m & awvalid_itb_m & awrite_itb_m;


nic400_ib_gpio_ahb_m_ib_downsize_rd_chan_sse710_integration_example_f0_host_exp u_downsize_read_channel
  (

  .aresetn                           (aresetn_m),
  .aclk                              (aclk_m),

  .archannel_data                    (arfmt_data),
  .archannel_valid                   (arvalid_bif),
  .archannel_ready                   (arready_bif),

  .arsize                            (arsize_itb_m),
  .araddr                            (araddr_itb_m[2:0]),
  .arid                              (arid_itb_m),

  .arvalid_m                         (arvalid_itb_m),
  .arready_m                         (arready_itb_m),

  .rvalid_m                          (rvalid_itb_m),
  .rdata_m                           (rdata_itb_m),
  .rlast_m                           (rlast_itb_m),
  .rid_m                             (rid_itb_m),
  .rresp_m                           (rresp_itb_m),

  .rready_s                          (rready_bif),


  .rready_m                          (rready_itb_m),

  .rvalid_s                          (rvalid_bif),
  .rdata_s                           (rdata_bif),
  .rlast_s                           (rlast_bif),
  .rid_s                             (rid_bif),
  .rresp_s                           (rresp_bif),

  .rbeats_s                          (rbeats)

  );


  assign arid_itb_m    = aid_itb_m;
  assign araddr_itb_m  = aaddr_itb_m;
  assign arsize_itb_m  = asize_itb_m;
  assign arvalid_bif = avalid_bif & ~awrite_itb_m;
  assign arready_itb_m = aready_itb_m & avalid_itb_m & ~awrite_itb_m;

  assign rdata_itb_m   = ddata_itb_m;
  assign rlast_itb_m   = dlast_itb_m;
  assign rid_itb_m     = did_itb_m;
  assign rresp_itb_m   = dresp_itb_m;
  assign rvalid_itb_m  = dvalid_itb_m & ~dbnr_itb_m;
  assign rready_bif  = dready_bif & dvalid_bif & ~dbnr_bif;

  assign dbnr_bif    = dbnr_itb_m;

  assign ddata_bif   = rdata_bif;
  assign dlast_bif   = rlast_bif;
  assign did_bif     = (dbnr_bif) ? did_itb_m : rid_bif;
  assign dresp_bif   = (dbnr_bif) ? dresp_itb_m : rresp_bif;
  assign dvalid_bif  = (dbnr_bif) ? dvalid_itb_m : rvalid_bif;
  assign dready_itb_m  = (dbnr_itb_m) ? dready_bif : rready_itb_m;









endmodule
`include "nic400_ib_gpio_ahb_m_ib_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"



