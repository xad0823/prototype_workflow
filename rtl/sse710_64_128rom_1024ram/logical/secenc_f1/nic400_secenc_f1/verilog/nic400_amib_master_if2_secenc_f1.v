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



`include "nic400_amib_master_if2_defs_secenc_f1.v"

module nic400_amib_master_if2_secenc_f1
  (
  
    hsel_master_if2_m,
    haddr_master_if2_m,
    htrans_master_if2_m,
    hwrite_master_if2_m,
    hsize_master_if2_m,
    hburst_master_if2_m,
    hprot_master_if2_m,
    hwdata_master_if2_m,
    hrdata_master_if2_m,
    hready_master_if2_m,
    hreadymux_master_if2_m,
    hresp_master_if2_m,
    hauser_master_if2_m,


    awid_master_if2_s,
    awaddr_master_if2_s,
    awlen_master_if2_s,
    awsize_master_if2_s,
    awburst_master_if2_s,
    awlock_master_if2_s,
    awcache_master_if2_s,
    awprot_master_if2_s,
    awvalid_master_if2_s,
    awready_master_if2_s,

    wdata_master_if2_s,
    wstrb_master_if2_s,
    wlast_master_if2_s,
    wvalid_master_if2_s,
    wready_master_if2_s,

    bid_master_if2_s,
    bresp_master_if2_s,
    bvalid_master_if2_s,
    bready_master_if2_s,

    arid_master_if2_s,
    araddr_master_if2_s,
    arlen_master_if2_s,
    arsize_master_if2_s,
    arburst_master_if2_s,
    arlock_master_if2_s,
    arcache_master_if2_s,
    arprot_master_if2_s,
    arvalid_master_if2_s,
    arready_master_if2_s,

    rid_master_if2_s,
    rdata_master_if2_s,
    rresp_master_if2_s,
    rlast_master_if2_s,
    rvalid_master_if2_s,
    rready_master_if2_s,

    awuser_master_if2_s,
    aruser_master_if2_s,

    aclk,
    aresetn

  );




  
  output              hsel_master_if2_m;           
  output  [31:0]      haddr_master_if2_m;          
  output  [1:0]       htrans_master_if2_m;         
  output              hwrite_master_if2_m;         
  output  [2:0]       hsize_master_if2_m;          
  output  [2:0]       hburst_master_if2_m;         
  output  [3:0]       hprot_master_if2_m;          
  output  [31:0]      hwdata_master_if2_m;         
  input   [31:0]      hrdata_master_if2_m;         
  input               hready_master_if2_m;         
  output              hreadymux_master_if2_m;      
  input               hresp_master_if2_m;          
  output  [1:0]       hauser_master_if2_m;         



  input               awid_master_if2_s;           
  input   [31:0]      awaddr_master_if2_s;         
  input   [7:0]       awlen_master_if2_s;          
  input   [2:0]       awsize_master_if2_s;         
  input   [1:0]       awburst_master_if2_s;        
  input               awlock_master_if2_s;         
  input   [3:0]       awcache_master_if2_s;        
  input   [2:0]       awprot_master_if2_s;         
  input               awvalid_master_if2_s;        
  output              awready_master_if2_s;        

  input   [31:0]      wdata_master_if2_s;          
  input   [3:0]       wstrb_master_if2_s;          
  input               wlast_master_if2_s;          
  input               wvalid_master_if2_s;         
  output              wready_master_if2_s;         

  output              bid_master_if2_s;            
  output  [1:0]       bresp_master_if2_s;          
  output              bvalid_master_if2_s;         
  input               bready_master_if2_s;         

  input               arid_master_if2_s;           
  input   [31:0]      araddr_master_if2_s;         
  input   [7:0]       arlen_master_if2_s;          
  input   [2:0]       arsize_master_if2_s;         
  input   [1:0]       arburst_master_if2_s;        
  input               arlock_master_if2_s;         
  input   [3:0]       arcache_master_if2_s;        
  input   [2:0]       arprot_master_if2_s;         
  input               arvalid_master_if2_s;        
  output              arready_master_if2_s;        

  output              rid_master_if2_s;            
  output  [31:0]      rdata_master_if2_s;          
  output  [1:0]       rresp_master_if2_s;          
  output              rlast_master_if2_s;          
  output              rvalid_master_if2_s;         
  input               rready_master_if2_s;         

  input   [1:0]       awuser_master_if2_s;         
  input   [1:0]       aruser_master_if2_s;         

  input               aclk;                        
  input               aresetn;                     





  wire           awrite_master_if2_s;
  wire           aid_master_if2_s;
  wire [31:0]    aaddr_master_if2_s;
  wire [7:0]        alen_master_if2_s;
  wire [2:0]     asize_master_if2_s;
  wire [1:0]     aburst_master_if2_s;
  wire [3:0]     acache_master_if2_s;
  wire [2:0]     aprot_master_if2_s;
  wire [1:0]     auser_master_if2_s;
  wire           avalid_master_if2_s;
  wire           aready_master_if2_s;

  wire           dbnr_master_if2_s;
  wire           did_master_if2_s;
  wire [31:0]    ddata_master_if2_s;
  wire [1:0]     dresp_master_if2_s;
  wire           dlast_master_if2_s;
  wire           dvalid_master_if2_s;
  wire           dready_master_if2_s;





  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_master_if2_s[31:24]  & {8{wstrb_master_if2_s[3]}}),
  (wdata_master_if2_s[23:16]  & {8{wstrb_master_if2_s[2]}}),
  (wdata_master_if2_s[15:8]  & {8{wstrb_master_if2_s[1]}}),
  (wdata_master_if2_s[7:0]  & {8{wstrb_master_if2_s[0]}})};
  
  nic400_amib_master_if2_axi_to_itb_secenc_f1 u_axi_to_itb
  (
    .awid           (awid_master_if2_s),
    .awaddr         (awaddr_master_if2_s),
    .awlen          (awlen_master_if2_s),
    .awsize         (awsize_master_if2_s),
    .awburst        (awburst_master_if2_s),
    .awlock         (awlock_master_if2_s),
    .awcache        (awcache_master_if2_s),
    .awprot         (awprot_master_if2_s),
    .awuser         (awuser_master_if2_s),
    .awvalid        (awvalid_master_if2_s),
    .awready        (awready_master_if2_s),

    .bid            (bid_master_if2_s),
    .bresp          (bresp_master_if2_s),
    .bvalid         (bvalid_master_if2_s),
    .bready         (bready_master_if2_s),

    .arid           (arid_master_if2_s),
    .araddr         (araddr_master_if2_s),
    .arlen          (arlen_master_if2_s),
    .arsize         (arsize_master_if2_s),
    .arburst        (arburst_master_if2_s),
    .arlock         (arlock_master_if2_s),
    .arcache        (arcache_master_if2_s),
    .arprot         (arprot_master_if2_s),
    .aruser         (aruser_master_if2_s),
    .arvalid        (arvalid_master_if2_s),
    .arready        (arready_master_if2_s),

    .rid            (rid_master_if2_s),
    .rdata          (rdata_master_if2_s),
    .rresp          (rresp_master_if2_s),
    .rlast          (rlast_master_if2_s),
    .rvalid         (rvalid_master_if2_s),
    .rready         (rready_master_if2_s),

    .awrite         (awrite_master_if2_s),
    .aid            (aid_master_if2_s),
    .aaddr          (aaddr_master_if2_s),
    .alen           (alen_master_if2_s),
    .asize          (asize_master_if2_s),
    .aburst         (aburst_master_if2_s),
    .alock          (),
    .acache         (acache_master_if2_s),
    .aprot          (aprot_master_if2_s),
    .auser          (auser_master_if2_s),
    .avalid         (avalid_master_if2_s),
    .aready         (aready_master_if2_s),

    .dbnr           (dbnr_master_if2_s),
    .did            (did_master_if2_s),
    .ddata          (ddata_master_if2_s),
    .dresp          (dresp_master_if2_s),
    .dlast          (dlast_master_if2_s),
    .dvalid         (dvalid_master_if2_s),
    .dready         (dready_master_if2_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );



  nic400_amib_master_if2_ahb_m_secenc_f1 u_ahb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_master_if2_s),
    .aid              (aid_master_if2_s),
    .aaddr            (aaddr_master_if2_s),
    .alen             (alen_master_if2_s),
    .asize            (asize_master_if2_s),
    .aburst           (aburst_master_if2_s),
    .acache           (acache_master_if2_s),
    .aprot            (aprot_master_if2_s),
    .auser            (auser_master_if2_s),
    .avalid           (avalid_master_if2_s),
    .aready           (aready_master_if2_s),

    .dbnr             (dbnr_master_if2_s),
    .did              (did_master_if2_s),
    .ddata            (ddata_master_if2_s),
    .dresp            (dresp_master_if2_s),
    .dlast            (dlast_master_if2_s),
    .dvalid           (dvalid_master_if2_s),
    .dready           (dready_master_if2_s),


    .wdata            (wdata_destrob),
    .wstrb            (wstrb_master_if2_s),
    .wlast            (wlast_master_if2_s),
    .wvalid           (wvalid_master_if2_s),
    .wready           (wready_master_if2_s),

    .hsel             (hsel_master_if2_m),
    .haddr            (haddr_master_if2_m),
    .htrans           (htrans_master_if2_m),
    .hwrite           (hwrite_master_if2_m),
    .hsize            (hsize_master_if2_m),
    .hburst           (hburst_master_if2_m),
    .hprot            (hprot_master_if2_m),
    .hauser           (hauser_master_if2_m),
    .hwdata           (hwdata_master_if2_m),
    .hreadymux        (hreadymux_master_if2_m),
    .hresp            (hresp_master_if2_m),
    .hrdata           (hrdata_master_if2_m),
    .hready           (hready_master_if2_m)
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
  assign a_phase_idle_busy_en   = hready_master_if2_m && hsel_master_if2_m && hreadymux_master_if2_m;

  assign illegal_idle_busy_resp = a_phase_idle_busy && !hready_master_if2_m;
  always @(posedge aclk or negedge aresetn)
  begin : p_ovl_illegal_idle_busy_resp
      if (!aresetn)
          a_phase_idle_busy <= 1'b0;
      else if (a_phase_idle_busy_en)
          a_phase_idle_busy <= ~htrans_master_if2_m[1];
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

`include "nic400_amib_master_if2_undefs_secenc_f1.v"

