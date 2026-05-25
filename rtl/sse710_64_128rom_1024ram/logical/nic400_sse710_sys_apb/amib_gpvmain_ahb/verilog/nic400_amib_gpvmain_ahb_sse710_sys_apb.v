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



`include "nic400_amib_gpvmain_ahb_defs_sse710_sys_apb.v"

module nic400_amib_gpvmain_ahb_sse710_sys_apb
  (
  
    hsel_gpvmain_ahb_m,
    haddr_gpvmain_ahb_m,
    htrans_gpvmain_ahb_m,
    hwrite_gpvmain_ahb_m,
    hsize_gpvmain_ahb_m,
    hburst_gpvmain_ahb_m,
    hprot_gpvmain_ahb_m,
    hwdata_gpvmain_ahb_m,
    hrdata_gpvmain_ahb_m,
    hready_gpvmain_ahb_m,
    hreadymux_gpvmain_ahb_m,
    hresp_gpvmain_ahb_m,


    awid_gpvmain_ahb_s,
    awaddr_gpvmain_ahb_s,
    awlen_gpvmain_ahb_s,
    awsize_gpvmain_ahb_s,
    awburst_gpvmain_ahb_s,
    awlock_gpvmain_ahb_s,
    awcache_gpvmain_ahb_s,
    awprot_gpvmain_ahb_s,
    awvalid_gpvmain_ahb_s,
    awready_gpvmain_ahb_s,

    wdata_gpvmain_ahb_s,
    wstrb_gpvmain_ahb_s,
    wlast_gpvmain_ahb_s,
    wvalid_gpvmain_ahb_s,
    wready_gpvmain_ahb_s,

    bid_gpvmain_ahb_s,
    bresp_gpvmain_ahb_s,
    bvalid_gpvmain_ahb_s,
    bready_gpvmain_ahb_s,

    arid_gpvmain_ahb_s,
    araddr_gpvmain_ahb_s,
    arlen_gpvmain_ahb_s,
    arsize_gpvmain_ahb_s,
    arburst_gpvmain_ahb_s,
    arlock_gpvmain_ahb_s,
    arcache_gpvmain_ahb_s,
    arprot_gpvmain_ahb_s,
    arvalid_gpvmain_ahb_s,
    arready_gpvmain_ahb_s,

    rid_gpvmain_ahb_s,
    rdata_gpvmain_ahb_s,
    rresp_gpvmain_ahb_s,
    rlast_gpvmain_ahb_s,
    rvalid_gpvmain_ahb_s,
    rready_gpvmain_ahb_s,

    aclk,
    aresetn

  );




  
  output              hsel_gpvmain_ahb_m;           
  output  [31:0]      haddr_gpvmain_ahb_m;          
  output  [1:0]       htrans_gpvmain_ahb_m;         
  output              hwrite_gpvmain_ahb_m;         
  output  [2:0]       hsize_gpvmain_ahb_m;          
  output  [2:0]       hburst_gpvmain_ahb_m;         
  output  [3:0]       hprot_gpvmain_ahb_m;          
  output  [31:0]      hwdata_gpvmain_ahb_m;         
  input   [31:0]      hrdata_gpvmain_ahb_m;         
  input               hready_gpvmain_ahb_m;         
  output              hreadymux_gpvmain_ahb_m;      
  input               hresp_gpvmain_ahb_m;          



  input   [11:0]      awid_gpvmain_ahb_s;           
  input   [31:0]      awaddr_gpvmain_ahb_s;         
  input   [7:0]       awlen_gpvmain_ahb_s;          
  input   [2:0]       awsize_gpvmain_ahb_s;         
  input   [1:0]       awburst_gpvmain_ahb_s;        
  input               awlock_gpvmain_ahb_s;         
  input   [3:0]       awcache_gpvmain_ahb_s;        
  input   [2:0]       awprot_gpvmain_ahb_s;         
  input               awvalid_gpvmain_ahb_s;        
  output              awready_gpvmain_ahb_s;        

  input   [31:0]      wdata_gpvmain_ahb_s;          
  input   [3:0]       wstrb_gpvmain_ahb_s;          
  input               wlast_gpvmain_ahb_s;          
  input               wvalid_gpvmain_ahb_s;         
  output              wready_gpvmain_ahb_s;         

  output  [11:0]      bid_gpvmain_ahb_s;            
  output  [1:0]       bresp_gpvmain_ahb_s;          
  output              bvalid_gpvmain_ahb_s;         
  input               bready_gpvmain_ahb_s;         

  input   [11:0]      arid_gpvmain_ahb_s;           
  input   [31:0]      araddr_gpvmain_ahb_s;         
  input   [7:0]       arlen_gpvmain_ahb_s;          
  input   [2:0]       arsize_gpvmain_ahb_s;         
  input   [1:0]       arburst_gpvmain_ahb_s;        
  input               arlock_gpvmain_ahb_s;         
  input   [3:0]       arcache_gpvmain_ahb_s;        
  input   [2:0]       arprot_gpvmain_ahb_s;         
  input               arvalid_gpvmain_ahb_s;        
  output              arready_gpvmain_ahb_s;        

  output  [11:0]      rid_gpvmain_ahb_s;            
  output  [31:0]      rdata_gpvmain_ahb_s;          
  output  [1:0]       rresp_gpvmain_ahb_s;          
  output              rlast_gpvmain_ahb_s;          
  output              rvalid_gpvmain_ahb_s;         
  input               rready_gpvmain_ahb_s;         

  input               aclk;                         
  input               aresetn;                      






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [36:0]    w_master_port_src_data;     
  wire [36:0]    w_master_port_dst_data;     



  wire           a_master_port_dst_valid;
  wire           a_master_port_dst_ready;
  wire           a_master_port_src_valid;
  wire           a_master_port_src_ready;

  wire [64:0]    a_master_port_src_data;     
  wire [64:0]    a_master_port_dst_data;     



  wire           d_master_port_dst_valid;
  wire           d_master_port_dst_ready;
  wire           d_master_port_src_valid;
  wire           d_master_port_src_ready;

  wire [47:0]    d_master_port_src_data;     
  wire [47:0]    d_master_port_dst_data;     


  wire           awrite_gpvmain_ahb_m;
  wire [11:0]    aid_gpvmain_ahb_m;
  wire [31:0]    aaddr_gpvmain_ahb_m;
  wire [7:0]        alen_gpvmain_ahb_m;
  wire [2:0]     asize_gpvmain_ahb_m;
  wire [1:0]     aburst_gpvmain_ahb_m;
  wire [3:0]     acache_gpvmain_ahb_m;
  wire [2:0]     aprot_gpvmain_ahb_m;
  wire           avalid_gpvmain_ahb_m;
  wire           aready_gpvmain_ahb_m;


  wire [31:0]    wdata_gpvmain_ahb_m;
  wire [3:0]     wstrb_gpvmain_ahb_m;
  wire           wlast_gpvmain_ahb_m;
  wire           wvalid_gpvmain_ahb_m;
  wire           wready_gpvmain_ahb_m;


  wire           dbnr_gpvmain_ahb_m;
  wire [11:0]    did_gpvmain_ahb_m;
  wire [31:0]    ddata_gpvmain_ahb_m;
  wire [1:0]     dresp_gpvmain_ahb_m;
  wire           dlast_gpvmain_ahb_m;
  wire           dvalid_gpvmain_ahb_m;
  wire           dready_gpvmain_ahb_m;


  wire           awrite_gpvmain_ahb_s;
  wire [11:0]    aid_gpvmain_ahb_s;
  wire [31:0]    aaddr_gpvmain_ahb_s;
  wire [7:0]        alen_gpvmain_ahb_s;
  wire [2:0]     asize_gpvmain_ahb_s;
  wire [1:0]     aburst_gpvmain_ahb_s;
  wire [3:0]     acache_gpvmain_ahb_s;
  wire [2:0]     aprot_gpvmain_ahb_s;
  wire           avalid_gpvmain_ahb_s;
  wire           aready_gpvmain_ahb_s;

  wire           dbnr_gpvmain_ahb_s;
  wire [11:0]    did_gpvmain_ahb_s;
  wire [31:0]    ddata_gpvmain_ahb_s;
  wire [1:0]     dresp_gpvmain_ahb_s;
  wire           dlast_gpvmain_ahb_s;
  wire           dvalid_gpvmain_ahb_s;
  wire           dready_gpvmain_ahb_s;





  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_gpvmain_ahb_s[31:24]  & {8{wstrb_gpvmain_ahb_s[3]}}),
  (wdata_gpvmain_ahb_s[23:16]  & {8{wstrb_gpvmain_ahb_s[2]}}),
  (wdata_gpvmain_ahb_s[15:8]  & {8{wstrb_gpvmain_ahb_s[1]}}),
  (wdata_gpvmain_ahb_s[7:0]  & {8{wstrb_gpvmain_ahb_s[0]}})};
  
  nic400_amib_gpvmain_ahb_axi_to_itb_sse710_sys_apb u_axi_to_itb
  (
    .awid           (awid_gpvmain_ahb_s),
    .awaddr         (awaddr_gpvmain_ahb_s),
    .awlen          (awlen_gpvmain_ahb_s),
    .awsize         (awsize_gpvmain_ahb_s),
    .awburst        (awburst_gpvmain_ahb_s),
    .awlock         (awlock_gpvmain_ahb_s),
    .awcache        (awcache_gpvmain_ahb_s),
    .awprot         (awprot_gpvmain_ahb_s),
    .awvalid        (awvalid_gpvmain_ahb_s),
    .awready        (awready_gpvmain_ahb_s),

    .bid            (bid_gpvmain_ahb_s),
    .bresp          (bresp_gpvmain_ahb_s),
    .bvalid         (bvalid_gpvmain_ahb_s),
    .bready         (bready_gpvmain_ahb_s),

    .arid           (arid_gpvmain_ahb_s),
    .araddr         (araddr_gpvmain_ahb_s),
    .arlen          (arlen_gpvmain_ahb_s),
    .arsize         (arsize_gpvmain_ahb_s),
    .arburst        (arburst_gpvmain_ahb_s),
    .arlock         (arlock_gpvmain_ahb_s),
    .arcache        (arcache_gpvmain_ahb_s),
    .arprot         (arprot_gpvmain_ahb_s),
    .arvalid        (arvalid_gpvmain_ahb_s),
    .arready        (arready_gpvmain_ahb_s),

    .rid            (rid_gpvmain_ahb_s),
    .rdata          (rdata_gpvmain_ahb_s),
    .rresp          (rresp_gpvmain_ahb_s),
    .rlast          (rlast_gpvmain_ahb_s),
    .rvalid         (rvalid_gpvmain_ahb_s),
    .rready         (rready_gpvmain_ahb_s),

    .awrite         (awrite_gpvmain_ahb_s),
    .aid            (aid_gpvmain_ahb_s),
    .aaddr          (aaddr_gpvmain_ahb_s),
    .alen           (alen_gpvmain_ahb_s),
    .asize          (asize_gpvmain_ahb_s),
    .aburst         (aburst_gpvmain_ahb_s),
    .alock          (),
    .acache         (acache_gpvmain_ahb_s),
    .aprot          (aprot_gpvmain_ahb_s),
    .avalid         (avalid_gpvmain_ahb_s),
    .aready         (aready_gpvmain_ahb_s),

    .dbnr           (dbnr_gpvmain_ahb_s),
    .did            (did_gpvmain_ahb_s),
    .ddata          (ddata_gpvmain_ahb_s),
    .dresp          (dresp_gpvmain_ahb_s),
    .dlast          (dlast_gpvmain_ahb_s),
    .dvalid         (dvalid_gpvmain_ahb_s),
    .dready         (dready_gpvmain_ahb_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );




  assign w_master_port_src_data = {wdata_destrob,
        wstrb_gpvmain_ahb_s,
        wlast_gpvmain_ahb_s};

  assign {wdata_gpvmain_ahb_m,
        wstrb_gpvmain_ahb_m,
        wlast_gpvmain_ahb_m} = w_master_port_dst_data;

  assign wvalid_gpvmain_ahb_m = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_gpvmain_ahb_m;

  assign w_master_port_src_valid = wvalid_gpvmain_ahb_s;
  assign wready_gpvmain_ahb_s = w_master_port_src_ready;




  assign a_master_port_src_data = {aid_gpvmain_ahb_s,
        aaddr_gpvmain_ahb_s,
        alen_gpvmain_ahb_s,
        asize_gpvmain_ahb_s,
        aburst_gpvmain_ahb_s,
        acache_gpvmain_ahb_s,
        aprot_gpvmain_ahb_s,
        awrite_gpvmain_ahb_s};

  assign {aid_gpvmain_ahb_m,
        aaddr_gpvmain_ahb_m,
        alen_gpvmain_ahb_m,
        asize_gpvmain_ahb_m,
        aburst_gpvmain_ahb_m,
        acache_gpvmain_ahb_m,
        aprot_gpvmain_ahb_m,
        awrite_gpvmain_ahb_m} = a_master_port_dst_data;

  assign avalid_gpvmain_ahb_m = a_master_port_dst_valid;
  assign a_master_port_dst_ready = aready_gpvmain_ahb_m;

  assign a_master_port_src_valid = avalid_gpvmain_ahb_s;
  assign aready_gpvmain_ahb_s = a_master_port_src_ready;



  assign d_master_port_src_data = {did_gpvmain_ahb_m,
        ddata_gpvmain_ahb_m,
        dresp_gpvmain_ahb_m,
        dlast_gpvmain_ahb_m,
        dbnr_gpvmain_ahb_m};

  assign {did_gpvmain_ahb_s,
        ddata_gpvmain_ahb_s,
        dresp_gpvmain_ahb_s,
        dlast_gpvmain_ahb_s,
        dbnr_gpvmain_ahb_s} = d_master_port_dst_data;

  assign dvalid_gpvmain_ahb_s =  d_master_port_dst_valid;
  assign d_master_port_dst_ready = dready_gpvmain_ahb_s;

  assign d_master_port_src_valid = dvalid_gpvmain_ahb_m;
  assign dready_gpvmain_ahb_m = d_master_port_src_ready;



  nic400_amib_gpvmain_ahb_ahb_m_sse710_sys_apb u_ahb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_gpvmain_ahb_m),
    .aid              (aid_gpvmain_ahb_m),
    .aaddr            (aaddr_gpvmain_ahb_m),
    .alen             (alen_gpvmain_ahb_m),
    .asize            (asize_gpvmain_ahb_m),
    .aburst           (aburst_gpvmain_ahb_m),
    .acache           (acache_gpvmain_ahb_m),
    .aprot            (aprot_gpvmain_ahb_m),
    .avalid           (avalid_gpvmain_ahb_m),
    .aready           (aready_gpvmain_ahb_m),

    .dbnr             (dbnr_gpvmain_ahb_m),
    .did              (did_gpvmain_ahb_m),
    .ddata            (ddata_gpvmain_ahb_m),
    .dresp            (dresp_gpvmain_ahb_m),
    .dlast            (dlast_gpvmain_ahb_m),
    .dvalid           (dvalid_gpvmain_ahb_m),
    .dready           (dready_gpvmain_ahb_m),


    .wdata            (wdata_gpvmain_ahb_m),
    .wstrb            (wstrb_gpvmain_ahb_m),
    .wlast            (wlast_gpvmain_ahb_m),
    .wvalid           (wvalid_gpvmain_ahb_m),
    .wready           (wready_gpvmain_ahb_m),

    .hsel             (hsel_gpvmain_ahb_m),
    .haddr            (haddr_gpvmain_ahb_m),
    .htrans           (htrans_gpvmain_ahb_m),
    .hwrite           (hwrite_gpvmain_ahb_m),
    .hsize            (hsize_gpvmain_ahb_m),
    .hburst           (hburst_gpvmain_ahb_m),
    .hprot            (hprot_gpvmain_ahb_m),
    .hwdata           (hwdata_gpvmain_ahb_m),
    .hreadymux        (hreadymux_gpvmain_ahb_m),
    .hresp            (hresp_gpvmain_ahb_m),
    .hrdata           (hrdata_gpvmain_ahb_m),
    .hready           (hready_gpvmain_ahb_m)
  );





  nic400_amib_gpvmain_ahb_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       37  
     )
  u_w_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (w_master_port_src_valid),
     .src_data              (w_master_port_src_data),
     .dst_ready             (w_master_port_dst_ready),

     .src_ready             (w_master_port_src_ready),
     .dst_data              (w_master_port_dst_data),
     .dst_valid             (w_master_port_dst_valid)
     );




  nic400_amib_gpvmain_ahb_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       65  
     )
  u_a_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (a_master_port_src_valid),
     .src_data              (a_master_port_src_data),
     .dst_ready             (a_master_port_dst_ready),

     .src_ready             (a_master_port_src_ready),
     .dst_data              (a_master_port_dst_data),
     .dst_valid             (a_master_port_dst_valid)
     );




  nic400_amib_gpvmain_ahb_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       48  
     )
  u_d_master_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (d_master_port_src_valid),
     .src_data              (d_master_port_src_data),
     .dst_ready             (d_master_port_dst_ready),

     .src_ready             (d_master_port_src_ready),
     .dst_data              (d_master_port_dst_data),
     .dst_valid             (d_master_port_dst_valid)
     );









`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"





  wire lock_rx_no_lock_support;

  assign lock_rx_no_lock_support = 1'b0;


  assert_never #(`OVL_ERROR,
                 `OVL_ASSERT,
                 "AMIB: Lock transaction received when not supported.")
  amib_lock_no_lock_support
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (lock_rx_no_lock_support)
  );



  wire illegal_idle_busy_resp;
  reg  a_phase_idle_busy;
  wire a_phase_idle_busy_en;
  assign a_phase_idle_busy_en   = hready_gpvmain_ahb_m && hsel_gpvmain_ahb_m && hreadymux_gpvmain_ahb_m;

  assign illegal_idle_busy_resp = a_phase_idle_busy && !hready_gpvmain_ahb_m;
  always @(posedge aclk or negedge aresetn)
  begin : p_ovl_illegal_idle_busy_resp
      if (!aresetn)
          a_phase_idle_busy <= 1'b0;
      else if (a_phase_idle_busy_en)
          a_phase_idle_busy <= ~htrans_gpvmain_ahb_m[1];
  end

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "AMIB: AHB-Lite protocol violation. Nonzero-wait-state response to IDLE or BUSY")
  ovl_illegal_idle_busy_resp
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (illegal_idle_busy_resp)
  );


  `endif 



endmodule

`include "nic400_amib_gpvmain_ahb_undefs_sse710_sys_apb.v"

