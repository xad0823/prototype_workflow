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

module nic400_ib_apb_group0_ib_master_domain_sse710_integration_example_f0_host_exp
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



  input   [88:0]      a_data;               
  input               a_valid;              
  output              a_ready;              

  output  [87:0]      d_data;               
  output              d_valid;              
  input               d_ready;              

  input   [72:0]      w_data;               
  input               w_valid;              
  output              w_ready;              

  input               aclk;                 
  input               aresetn;              





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
          aprot_itb_m,downsize,arfmt_data} = a_data;

  

  assign avalid_bif = a_valid;
  assign a_ready = aready_bif;







  assign {
          wdata_bif,
          wstrb_bif,
          wlast_bif} = w_data;

  

  assign wvalid_bif = w_valid;
  assign w_ready = wready_bif;





  assign d_data = {
          did_bif,
          dbnr_bif,
          ddata_bif,
          dresp_bif,
          dlast_bif,rbeats};

  assign d_valid = dvalid_bif;
  assign dready_bif = d_ready;




  nic400_ib_apb_group0_ib_downsize_wr_mux_sse710_integration_example_f0_host_exp u_downsize_write_mux
  (
    .aresetn                          (aresetn),
    .aclk                             (aclk),

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


nic400_ib_apb_group0_ib_downsize_rd_chan_sse710_integration_example_f0_host_exp u_downsize_read_channel
  (

  .aresetn                           (aresetn),
  .aclk                              (aclk),

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
`include "nic400_ib_apb_group0_ib_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"



