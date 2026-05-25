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



`include "nic400_asib_gpvmain_ahb_defs_sse710_main.v"

module nic400_asib_gpvmain_ahb_sse710_main
 (
  
    haddr_gpvmain_ahb_s,
    htrans_gpvmain_ahb_s,
    hwrite_gpvmain_ahb_s,
    hsize_gpvmain_ahb_s,
    hburst_gpvmain_ahb_s,
    hprot_gpvmain_ahb_s,
    hwdata_gpvmain_ahb_s,
    hselx_gpvmain_ahb_s,
    hrdata_gpvmain_ahb_s,
    hready_gpvmain_ahb_s,
    hreadyout_gpvmain_ahb_s,
    hresp_gpvmain_ahb_s,


    aaddr_gpvmain_ahb_m,
    alen_gpvmain_ahb_m,
    asize_gpvmain_ahb_m,
    aburst_gpvmain_ahb_m,
    alock_gpvmain_ahb_m,
    acache_gpvmain_ahb_m,
    aprot_gpvmain_ahb_m,
    awrite_gpvmain_ahb_m,
    avalid_gpvmain_ahb_m,
    avalid_vect_gpvmain_ahb_m,
    aready_gpvmain_ahb_m,

    wdata_gpvmain_ahb_m,
    wstrb_gpvmain_ahb_m,
    wlast_gpvmain_ahb_m,
    wvalid_gpvmain_ahb_m,
    wready_gpvmain_ahb_m,

    ddata_gpvmain_ahb_m,
    dresp_gpvmain_ahb_m,
    dlast_gpvmain_ahb_m,
    dbnr_gpvmain_ahb_m,
    dvalid_gpvmain_ahb_m,
    dready_gpvmain_ahb_m,

    gpvmain_ahb_cactive,

    gpvmain_ahb_cactive_wakeup,

    gpvmain_ahb_port_enable,

    aclk,
    aresetn

  );




  
  input   [31:0]      haddr_gpvmain_ahb_s;             
  input   [1:0]       htrans_gpvmain_ahb_s;            
  input               hwrite_gpvmain_ahb_s;            
  input   [2:0]       hsize_gpvmain_ahb_s;             
  input   [2:0]       hburst_gpvmain_ahb_s;            
  input   [3:0]       hprot_gpvmain_ahb_s;             
  input   [31:0]      hwdata_gpvmain_ahb_s;            
  input               hselx_gpvmain_ahb_s;             
  output  [31:0]      hrdata_gpvmain_ahb_s;            
  input               hready_gpvmain_ahb_s;            
  output              hreadyout_gpvmain_ahb_s;         
  output              hresp_gpvmain_ahb_s;             



  output  [31:0]      aaddr_gpvmain_ahb_m;             
  output  [3:0]       alen_gpvmain_ahb_m;              
  output  [2:0]       asize_gpvmain_ahb_m;             
  output  [1:0]       aburst_gpvmain_ahb_m;            
  output  [1:0]       alock_gpvmain_ahb_m;             
  output  [3:0]       acache_gpvmain_ahb_m;            
  output  [2:0]       aprot_gpvmain_ahb_m;             
  output              awrite_gpvmain_ahb_m;            
  output              avalid_gpvmain_ahb_m;            
  output  [1:0]       avalid_vect_gpvmain_ahb_m;       
  input               aready_gpvmain_ahb_m;            

  output  [31:0]      wdata_gpvmain_ahb_m;             
  output  [3:0]       wstrb_gpvmain_ahb_m;             
  output              wlast_gpvmain_ahb_m;             
  output              wvalid_gpvmain_ahb_m;            
  input               wready_gpvmain_ahb_m;            

  input   [31:0]      ddata_gpvmain_ahb_m;             
  input   [1:0]       dresp_gpvmain_ahb_m;             
  input               dlast_gpvmain_ahb_m;             
  input               dbnr_gpvmain_ahb_m;              
  input               dvalid_gpvmain_ahb_m;            
  output              dready_gpvmain_ahb_m;            


  output              gpvmain_ahb_cactive;             


  output              gpvmain_ahb_cactive_wakeup;      


  input               gpvmain_ahb_port_enable;         

  input               aclk;                            
  input               aresetn;                         



  wire                gpvmain_ahb_ar_enable;
  wire                gpvmain_ahb_aw_enable;
  wire                gpvmain_ahb_w_enable;

  


  wire           w_slave_port_dst_valid;
  wire           w_slave_port_dst_ready;
  wire           w_slave_port_src_valid;
  wire           w_slave_port_src_ready;

  wire [36:0]    w_slave_port_src_data;     
  wire [36:0]    w_slave_port_dst_data;     

  wire           a_slave_port_dst_valid;
  wire           a_slave_port_dst_ready;
  wire           a_slave_port_src_valid;
  wire           a_slave_port_src_ready;

  wire [52:0]    a_slave_port_src_data;     
  wire [52:0]    a_slave_port_dst_data;     

  wire           d_slave_port_dst_valid;
  wire           d_slave_port_dst_ready;
  wire           d_slave_port_src_valid;
  wire           d_slave_port_src_ready;

  wire [35:0]    d_slave_port_src_data;     
  wire [35:0]    d_slave_port_dst_data;     

  wire                security;
  wire  [1:0]          htrans_int;
  wire                 hready_int;

  wire                r_override;          
  wire                w_override;          

  wire [3:0]          acache_int_gpvmain_ahb_s;
  wire                awrite_gpvmain_ahb_s;
  wire [31:0]         aaddr_gpvmain_ahb_s;
  wire [3:0]             alen_gpvmain_ahb_s;
  wire [2:0]          asize_gpvmain_ahb_s;
  wire [1:0]          aburst_gpvmain_ahb_s;
  wire [1:0]             alock_gpvmain_ahb_s;
  wire [3:0]          acache_gpvmain_ahb_s;
  wire [2:0]          aprot_gpvmain_ahb_s;
  wire [1:0]          avalid_vect_gpvmain_ahb_s;
  wire                avalid_gpvmain_ahb_s;
  wire                aready_gpvmain_ahb_s;

  wire                dbnr_gpvmain_ahb_s;
  wire [31:0]         ddata_gpvmain_ahb_s;
  wire [1:0]          dresp_gpvmain_ahb_s;
  wire                dlast_gpvmain_ahb_s;
  wire                dvalid_gpvmain_ahb_s;
  wire                dready_gpvmain_ahb_s;

  wire [31:0]         wdata_gpvmain_ahb_s;
  wire [3:0]          wstrb_gpvmain_ahb_s;
  wire                wlast_gpvmain_ahb_s;
  wire                wvalid_gpvmain_ahb_s;
  wire                wready_gpvmain_ahb_s;

  wire [31:0]         aaddr_int_s;

  wire                tracker_busy;
  wire                gpvmain_ahb_ot;
  wire                ahb_cactive;
  wire                cds_a_enable;
  wire                cds_w_enable;






  assign gpvmain_ahb_ot = (tracker_busy | ahb_cactive);


  assign gpvmain_ahb_cactive_wakeup = 1'b0;


  assign gpvmain_ahb_cactive = gpvmain_ahb_ot;
  assign gpvmain_ahb_ar_enable = gpvmain_ahb_port_enable;
  assign gpvmain_ahb_aw_enable = gpvmain_ahb_port_enable;
  assign gpvmain_ahb_w_enable  = gpvmain_ahb_port_enable;


    assign r_override    = 1'b0;
    assign w_override    = 1'b0;
    assign hrdata_gpvmain_ahb_s = ddata_gpvmain_ahb_s;

    assign htrans_int = htrans_gpvmain_ahb_s;
    assign hreadyout_gpvmain_ahb_s = hready_int;

nic400_asib_gpvmain_ahb_ahb_sse710_main u_asib_gpvmain_ahb_ahb
    (
        .aclk               (aclk),
        .aresetn            (aresetn),

        .r_override         (r_override),
        .w_override         (w_override),

        .cactive            (ahb_cactive),

        .hreadyout          (hready_int),
        .hready             (hready_gpvmain_ahb_s),
        .hselx              (hselx_gpvmain_ahb_s),
        .hresp              (hresp_gpvmain_ahb_s),
        .haddr              (haddr_gpvmain_ahb_s),
        .htrans             (htrans_int),
        .hwrite             (hwrite_gpvmain_ahb_s),
        .hsize              (hsize_gpvmain_ahb_s),
        .hburst             (hburst_gpvmain_ahb_s),
        .hprot              (hprot_gpvmain_ahb_s),
        .hwdata             (hwdata_gpvmain_ahb_s),

        .awrite             (awrite_gpvmain_ahb_s),
        .aaddr              (aaddr_int_s),
        .alen               (alen_gpvmain_ahb_s),
        .asize              (asize_gpvmain_ahb_s),
        .aburst             (aburst_gpvmain_ahb_s),
        .alock              (alock_gpvmain_ahb_s),
        .acache             (acache_int_gpvmain_ahb_s),
        .aprot              (aprot_gpvmain_ahb_s),
        .avalid             (avalid_gpvmain_ahb_s),
        .aready             (aready_gpvmain_ahb_s),

        .dbnr               (dbnr_gpvmain_ahb_s),
        .dresp              (dresp_gpvmain_ahb_s),
        .dlast              (dlast_gpvmain_ahb_s),
        .dvalid             (dvalid_gpvmain_ahb_s),
        .dready             (dready_gpvmain_ahb_s),

        .wdata              (wdata_gpvmain_ahb_s),
        .wstrb              (wstrb_gpvmain_ahb_s),
        .wlast              (wlast_gpvmain_ahb_s),
        .wvalid             (wvalid_gpvmain_ahb_s),
        .wready             (wready_gpvmain_ahb_s)
    );

 
  assign security = 1'b1;
  assign aaddr_gpvmain_ahb_s = aaddr_int_s;

  nic400_asib_gpvmain_ahb_decode_sse710_main u_a_add_decode
  (
    .addr_s                         (aaddr_int_s),
    .security                      (security),
    .aprot                          (aprot_gpvmain_ahb_s[1]),
    .acache_in                      (acache_int_gpvmain_ahb_s),
    .acache_out                     (acache_gpvmain_ahb_s),
    .avalid_int                     (avalid_vect_gpvmain_ahb_s)
    );

nic400_asib_gpvmain_ahb_itb_ss_cdas_sse710_main u_asib_gpvmain_ahb_itb_ss_cdas
  (
    .a_enable               (cds_a_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (avalid_vect_gpvmain_ahb_s),
    .avalid                 (avalid_gpvmain_ahb_s),
    .aready                 (aready_gpvmain_ahb_s),
    .awrite                 (awrite_gpvmain_ahb_s),
    .wvalid                 (wvalid_gpvmain_ahb_s),
    .wready                 (wready_gpvmain_ahb_s),
    .wlast                  (wlast_gpvmain_ahb_s),
    .resp_valid             (dvalid_gpvmain_ahb_s),
    .resp_ready             (dready_gpvmain_ahb_s),
    .resp_last              (dlast_gpvmain_ahb_s),
    .resp_dbnr              (dbnr_gpvmain_ahb_s),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );

  nic400_asib_gpvmain_ahb_itb_trans_counter_sse710_main u_itb_trans_counter (
        .avalid_m     (avalid_gpvmain_ahb_m),
        .aready_m     (aready_gpvmain_ahb_m),
        .dvalid_m     (dvalid_gpvmain_ahb_m),
        .dready_m     (dready_gpvmain_ahb_m),
        .dbnr_m       (dbnr_gpvmain_ahb_m),
        .dlast_m      (dlast_gpvmain_ahb_m),
        .tracker_busy (tracker_busy),
        .aclk         (aclk),
        .aresetn      (aresetn)
        );


  assign w_slave_port_src_data = {wdata_gpvmain_ahb_s,
          wstrb_gpvmain_ahb_s,
          wlast_gpvmain_ahb_s};

  assign {wdata_gpvmain_ahb_m,
          wstrb_gpvmain_ahb_m,
          wlast_gpvmain_ahb_m} = w_slave_port_dst_data;



  assign wvalid_gpvmain_ahb_m = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_gpvmain_ahb_m;

  assign w_slave_port_src_valid = wvalid_gpvmain_ahb_s & gpvmain_ahb_w_enable;
  assign wready_gpvmain_ahb_s = w_slave_port_src_ready & gpvmain_ahb_w_enable;


  assign a_slave_port_src_data = {
          aaddr_gpvmain_ahb_s,
          alen_gpvmain_ahb_s,
          asize_gpvmain_ahb_s,
          aburst_gpvmain_ahb_s,
          alock_gpvmain_ahb_s,
          acache_gpvmain_ahb_s,
          aprot_gpvmain_ahb_s,
          awrite_gpvmain_ahb_s,
          avalid_vect_gpvmain_ahb_s};

  assign {
          aaddr_gpvmain_ahb_m,
          alen_gpvmain_ahb_m,
          asize_gpvmain_ahb_m,
          aburst_gpvmain_ahb_m,
          alock_gpvmain_ahb_m,
          acache_gpvmain_ahb_m,
          aprot_gpvmain_ahb_m,
          awrite_gpvmain_ahb_m,
          avalid_vect_gpvmain_ahb_m} = a_slave_port_dst_data;



  assign avalid_gpvmain_ahb_m = a_slave_port_dst_valid;
  assign a_slave_port_dst_ready = aready_gpvmain_ahb_m;

  assign a_slave_port_src_valid = avalid_gpvmain_ahb_s & cds_a_enable;
  assign aready_gpvmain_ahb_s = a_slave_port_src_ready & cds_a_enable;



  assign d_slave_port_src_data = {
          ddata_gpvmain_ahb_m,
          dresp_gpvmain_ahb_m,
          dlast_gpvmain_ahb_m,
          dbnr_gpvmain_ahb_m};

  assign {
          ddata_gpvmain_ahb_s,
          dresp_gpvmain_ahb_s,
          dlast_gpvmain_ahb_s,
          dbnr_gpvmain_ahb_s} = d_slave_port_dst_data;


  assign dvalid_gpvmain_ahb_s =  d_slave_port_dst_valid;
  assign d_slave_port_dst_ready = dready_gpvmain_ahb_s;

  assign d_slave_port_src_valid = dvalid_gpvmain_ahb_m;
  assign dready_gpvmain_ahb_m = d_slave_port_src_ready;



  nic400_asib_gpvmain_ahb_chan_slice_sse710_main
    #(
       `RS_REGD,  
       37  
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




  nic400_asib_gpvmain_ahb_chan_slice_sse710_main
    #(
       `RS_REGD,  
       53  
     )
  u_a_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (a_slave_port_src_valid),
     .src_data              (a_slave_port_src_data),
     .dst_ready             (a_slave_port_dst_ready),

     .src_ready             (a_slave_port_src_ready),
     .dst_data              (a_slave_port_dst_data),
     .dst_valid             (a_slave_port_dst_valid)
     );




  nic400_asib_gpvmain_ahb_chan_slice_sse710_main
    #(
       `RS_REGD,  
       36  
     )
  u_d_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (d_slave_port_src_valid),
     .src_data              (d_slave_port_src_data),
     .dst_ready             (d_slave_port_dst_ready),

     .src_ready             (d_slave_port_src_ready),
     .dst_data              (d_slave_port_dst_data),
     .dst_valid             (d_slave_port_dst_valid)
     );







`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"



  assert_zero_one_hot
    #(`OVL_FATAL, 2, `OVL_ASSERT,
      "Error: Valid vector not one-hot zero")
      ovl_avalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( avalid_gpvmain_ahb_s & avalid_vect_gpvmain_ahb_s )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: Valid vector not one-hot during AVALID")
      ovl_avalid_vect_one_hot_when_avalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( avalid_gpvmain_ahb_s & ~|avalid_vect_gpvmain_ahb_s )
      );




`endif


endmodule

`include "nic400_asib_gpvmain_ahb_undefs_sse710_main.v"



