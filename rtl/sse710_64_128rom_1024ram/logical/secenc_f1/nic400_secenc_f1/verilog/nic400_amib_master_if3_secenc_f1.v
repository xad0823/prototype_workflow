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



`include "nic400_amib_master_if3_defs_secenc_f1.v"

module nic400_amib_master_if3_secenc_f1
  (
  
    haddr_master_if3_m,
    htrans_master_if3_m,
    hwrite_master_if3_m,
    hsize_master_if3_m,
    hburst_master_if3_m,
    hprot_master_if3_m,
    hwdata_master_if3_m,
    hrdata_master_if3_m,
    hready_master_if3_m,
    hresp_master_if3_m,


    awid_master_if3_s,
    awaddr_master_if3_s,
    awlen_master_if3_s,
    awsize_master_if3_s,
    awburst_master_if3_s,
    awlock_master_if3_s,
    awcache_master_if3_s,
    awprot_master_if3_s,
    awvalid_master_if3_s,
    awready_master_if3_s,

    wdata_master_if3_s,
    wstrb_master_if3_s,
    wlast_master_if3_s,
    wvalid_master_if3_s,
    wready_master_if3_s,

    bid_master_if3_s,
    bresp_master_if3_s,
    bvalid_master_if3_s,
    bready_master_if3_s,

    arid_master_if3_s,
    araddr_master_if3_s,
    arlen_master_if3_s,
    arsize_master_if3_s,
    arburst_master_if3_s,
    arlock_master_if3_s,
    arcache_master_if3_s,
    arprot_master_if3_s,
    arvalid_master_if3_s,
    arready_master_if3_s,

    rid_master_if3_s,
    rdata_master_if3_s,
    rresp_master_if3_s,
    rlast_master_if3_s,
    rvalid_master_if3_s,
    rready_master_if3_s,

    aclk,
    aresetn

  );




  
  output  [31:0]      haddr_master_if3_m;        
  output  [1:0]       htrans_master_if3_m;       
  output              hwrite_master_if3_m;       
  output  [2:0]       hsize_master_if3_m;        
  output  [2:0]       hburst_master_if3_m;       
  output  [3:0]       hprot_master_if3_m;        
  output  [31:0]      hwdata_master_if3_m;       
  input   [31:0]      hrdata_master_if3_m;       
  input               hready_master_if3_m;       
  input               hresp_master_if3_m;        



  input               awid_master_if3_s;         
  input   [31:0]      awaddr_master_if3_s;       
  input   [7:0]       awlen_master_if3_s;        
  input   [2:0]       awsize_master_if3_s;       
  input   [1:0]       awburst_master_if3_s;      
  input               awlock_master_if3_s;       
  input   [3:0]       awcache_master_if3_s;      
  input   [2:0]       awprot_master_if3_s;       
  input               awvalid_master_if3_s;      
  output              awready_master_if3_s;      

  input   [31:0]      wdata_master_if3_s;        
  input   [3:0]       wstrb_master_if3_s;        
  input               wlast_master_if3_s;        
  input               wvalid_master_if3_s;       
  output              wready_master_if3_s;       

  output              bid_master_if3_s;          
  output  [1:0]       bresp_master_if3_s;        
  output              bvalid_master_if3_s;       
  input               bready_master_if3_s;       

  input               arid_master_if3_s;         
  input   [31:0]      araddr_master_if3_s;       
  input   [7:0]       arlen_master_if3_s;        
  input   [2:0]       arsize_master_if3_s;       
  input   [1:0]       arburst_master_if3_s;      
  input               arlock_master_if3_s;       
  input   [3:0]       arcache_master_if3_s;      
  input   [2:0]       arprot_master_if3_s;       
  input               arvalid_master_if3_s;      
  output              arready_master_if3_s;      

  output              rid_master_if3_s;          
  output  [31:0]      rdata_master_if3_s;        
  output  [1:0]       rresp_master_if3_s;        
  output              rlast_master_if3_s;        
  output              rvalid_master_if3_s;       
  input               rready_master_if3_s;       

  input               aclk;                      
  input               aresetn;                   





  wire           awrite_master_if3_s;
  wire           aid_master_if3_s;
  wire [31:0]    aaddr_master_if3_s;
  wire [7:0]        alen_master_if3_s;
  wire [2:0]     asize_master_if3_s;
  wire [1:0]     aburst_master_if3_s;
  wire [3:0]     acache_master_if3_s;
  wire [2:0]     aprot_master_if3_s;
  wire           avalid_master_if3_s;
  wire           aready_master_if3_s;

  wire           dbnr_master_if3_s;
  wire           did_master_if3_s;
  wire [31:0]    ddata_master_if3_s;
  wire [1:0]     dresp_master_if3_s;
  wire           dlast_master_if3_s;
  wire           dvalid_master_if3_s;
  wire           dready_master_if3_s;





  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_master_if3_s[31:24]  & {8{wstrb_master_if3_s[3]}}),
  (wdata_master_if3_s[23:16]  & {8{wstrb_master_if3_s[2]}}),
  (wdata_master_if3_s[15:8]  & {8{wstrb_master_if3_s[1]}}),
  (wdata_master_if3_s[7:0]  & {8{wstrb_master_if3_s[0]}})};
  
  nic400_amib_master_if3_axi_to_itb_secenc_f1 u_axi_to_itb
  (
    .awid           (awid_master_if3_s),
    .awaddr         (awaddr_master_if3_s),
    .awlen          (awlen_master_if3_s),
    .awsize         (awsize_master_if3_s),
    .awburst        (awburst_master_if3_s),
    .awlock         (awlock_master_if3_s),
    .awcache        (awcache_master_if3_s),
    .awprot         (awprot_master_if3_s),
    .awvalid        (awvalid_master_if3_s),
    .awready        (awready_master_if3_s),

    .bid            (bid_master_if3_s),
    .bresp          (bresp_master_if3_s),
    .bvalid         (bvalid_master_if3_s),
    .bready         (bready_master_if3_s),

    .arid           (arid_master_if3_s),
    .araddr         (araddr_master_if3_s),
    .arlen          (arlen_master_if3_s),
    .arsize         (arsize_master_if3_s),
    .arburst        (arburst_master_if3_s),
    .arlock         (arlock_master_if3_s),
    .arcache        (arcache_master_if3_s),
    .arprot         (arprot_master_if3_s),
    .arvalid        (arvalid_master_if3_s),
    .arready        (arready_master_if3_s),

    .rid            (rid_master_if3_s),
    .rdata          (rdata_master_if3_s),
    .rresp          (rresp_master_if3_s),
    .rlast          (rlast_master_if3_s),
    .rvalid         (rvalid_master_if3_s),
    .rready         (rready_master_if3_s),

    .awrite         (awrite_master_if3_s),
    .aid            (aid_master_if3_s),
    .aaddr          (aaddr_master_if3_s),
    .alen           (alen_master_if3_s),
    .asize          (asize_master_if3_s),
    .aburst         (aburst_master_if3_s),
    .alock          (),
    .acache         (acache_master_if3_s),
    .aprot          (aprot_master_if3_s),
    .avalid         (avalid_master_if3_s),
    .aready         (aready_master_if3_s),

    .dbnr           (dbnr_master_if3_s),
    .did            (did_master_if3_s),
    .ddata          (ddata_master_if3_s),
    .dresp          (dresp_master_if3_s),
    .dlast          (dlast_master_if3_s),
    .dvalid         (dvalid_master_if3_s),
    .dready         (dready_master_if3_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );



  nic400_amib_master_if3_ahb_m_secenc_f1 u_ahb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_master_if3_s),
    .aid              (aid_master_if3_s),
    .aaddr            (aaddr_master_if3_s),
    .alen             (alen_master_if3_s),
    .asize            (asize_master_if3_s),
    .aburst           (aburst_master_if3_s),
    .acache           (acache_master_if3_s),
    .aprot            (aprot_master_if3_s),
    .avalid           (avalid_master_if3_s),
    .aready           (aready_master_if3_s),

    .dbnr             (dbnr_master_if3_s),
    .did              (did_master_if3_s),
    .ddata            (ddata_master_if3_s),
    .dresp            (dresp_master_if3_s),
    .dlast            (dlast_master_if3_s),
    .dvalid           (dvalid_master_if3_s),
    .dready           (dready_master_if3_s),


    .wdata            (wdata_destrob),
    .wstrb            (wstrb_master_if3_s),
    .wlast            (wlast_master_if3_s),
    .wvalid           (wvalid_master_if3_s),
    .wready           (wready_master_if3_s),

    .haddr            (haddr_master_if3_m),
    .htrans           (htrans_master_if3_m),
    .hwrite           (hwrite_master_if3_m),
    .hsize            (hsize_master_if3_m),
    .hburst           (hburst_master_if3_m),
    .hprot            (hprot_master_if3_m),
    .hwdata           (hwdata_master_if3_m),
    .hresp            (hresp_master_if3_m),
    .hrdata           (hrdata_master_if3_m),
    .hready           (hready_master_if3_m)
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
  assign a_phase_idle_busy_en   = hready_master_if3_m;

  assign illegal_idle_busy_resp = a_phase_idle_busy && !hready_master_if3_m;
  always @(posedge aclk or negedge aresetn)
  begin : p_ovl_illegal_idle_busy_resp
      if (!aresetn)
          a_phase_idle_busy <= 1'b0;
      else if (a_phase_idle_busy_en)
          a_phase_idle_busy <= ~htrans_master_if3_m[1];
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

`include "nic400_amib_master_if3_undefs_secenc_f1.v"

