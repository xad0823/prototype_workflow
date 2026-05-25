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



`include "nic400_amib_gpio_ahb_m_defs_sse710_integration_example_f0_host_exp.v"

module nic400_amib_gpio_ahb_m_sse710_integration_example_f0_host_exp
  (
  
    hsel_gpio_ahb_m_m,
    haddr_gpio_ahb_m_m,
    htrans_gpio_ahb_m_m,
    hwrite_gpio_ahb_m_m,
    hsize_gpio_ahb_m_m,
    hburst_gpio_ahb_m_m,
    hprot_gpio_ahb_m_m,
    hwdata_gpio_ahb_m_m,
    hrdata_gpio_ahb_m_m,
    hready_gpio_ahb_m_m,
    hreadymux_gpio_ahb_m_m,
    hresp_gpio_ahb_m_m,


    aid_gpio_ahb_m_s,
    aaddr_gpio_ahb_m_s,
    alen_gpio_ahb_m_s,
    asize_gpio_ahb_m_s,
    aburst_gpio_ahb_m_s,
    alock_gpio_ahb_m_s,
    acache_gpio_ahb_m_s,
    aprot_gpio_ahb_m_s,
    awrite_gpio_ahb_m_s,
    avalid_gpio_ahb_m_s,
    aready_gpio_ahb_m_s,

    wdata_gpio_ahb_m_s,
    wstrb_gpio_ahb_m_s,
    wlast_gpio_ahb_m_s,
    wvalid_gpio_ahb_m_s,
    wready_gpio_ahb_m_s,

    did_gpio_ahb_m_s,
    ddata_gpio_ahb_m_s,
    dresp_gpio_ahb_m_s,
    dlast_gpio_ahb_m_s,
    dbnr_gpio_ahb_m_s,
    dvalid_gpio_ahb_m_s,
    dready_gpio_ahb_m_s,

    aclk,
    aresetn

  );




  
  output              hsel_gpio_ahb_m_m;           
  output  [31:0]      haddr_gpio_ahb_m_m;          
  output  [1:0]       htrans_gpio_ahb_m_m;         
  output              hwrite_gpio_ahb_m_m;         
  output  [2:0]       hsize_gpio_ahb_m_m;          
  output  [2:0]       hburst_gpio_ahb_m_m;         
  output  [3:0]       hprot_gpio_ahb_m_m;          
  output  [31:0]      hwdata_gpio_ahb_m_m;         
  input   [31:0]      hrdata_gpio_ahb_m_m;         
  input               hready_gpio_ahb_m_m;         
  output              hreadymux_gpio_ahb_m_m;      
  input               hresp_gpio_ahb_m_m;          



  input   [17:0]      aid_gpio_ahb_m_s;            
  input   [31:0]      aaddr_gpio_ahb_m_s;          
  input   [7:0]       alen_gpio_ahb_m_s;           
  input   [2:0]       asize_gpio_ahb_m_s;          
  input   [1:0]       aburst_gpio_ahb_m_s;         
  input               alock_gpio_ahb_m_s;          
  input   [3:0]       acache_gpio_ahb_m_s;         
  input   [2:0]       aprot_gpio_ahb_m_s;          
  input               awrite_gpio_ahb_m_s;         
  input               avalid_gpio_ahb_m_s;         
  output              aready_gpio_ahb_m_s;         

  input   [31:0]      wdata_gpio_ahb_m_s;          
  input   [3:0]       wstrb_gpio_ahb_m_s;          
  input               wlast_gpio_ahb_m_s;          
  input               wvalid_gpio_ahb_m_s;         
  output              wready_gpio_ahb_m_s;         

  output  [17:0]      did_gpio_ahb_m_s;            
  output  [31:0]      ddata_gpio_ahb_m_s;          
  output  [1:0]       dresp_gpio_ahb_m_s;          
  output              dlast_gpio_ahb_m_s;          
  output              dbnr_gpio_ahb_m_s;           
  output              dvalid_gpio_ahb_m_s;         
  input               dready_gpio_ahb_m_s;         

  input               aclk;                        
  input               aresetn;                     








  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_gpio_ahb_m_s[31:24]  & {8{wstrb_gpio_ahb_m_s[3]}}),
  (wdata_gpio_ahb_m_s[23:16]  & {8{wstrb_gpio_ahb_m_s[2]}}),
  (wdata_gpio_ahb_m_s[15:8]  & {8{wstrb_gpio_ahb_m_s[1]}}),
  (wdata_gpio_ahb_m_s[7:0]  & {8{wstrb_gpio_ahb_m_s[0]}})};
  

  nic400_amib_gpio_ahb_m_ahb_m_sse710_integration_example_f0_host_exp u_ahb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_gpio_ahb_m_s),
    .aid              (aid_gpio_ahb_m_s),
    .aaddr            (aaddr_gpio_ahb_m_s),
    .alen             (alen_gpio_ahb_m_s),
    .asize            (asize_gpio_ahb_m_s),
    .aburst           (aburst_gpio_ahb_m_s),
    .acache           (acache_gpio_ahb_m_s),
    .aprot            (aprot_gpio_ahb_m_s),
    .avalid           (avalid_gpio_ahb_m_s),
    .aready           (aready_gpio_ahb_m_s),

    .dbnr             (dbnr_gpio_ahb_m_s),
    .did              (did_gpio_ahb_m_s),
    .ddata            (ddata_gpio_ahb_m_s),
    .dresp            (dresp_gpio_ahb_m_s),
    .dlast            (dlast_gpio_ahb_m_s),
    .dvalid           (dvalid_gpio_ahb_m_s),
    .dready           (dready_gpio_ahb_m_s),


    .wdata            (wdata_destrob),
    .wstrb            (wstrb_gpio_ahb_m_s),
    .wlast            (wlast_gpio_ahb_m_s),
    .wvalid           (wvalid_gpio_ahb_m_s),
    .wready           (wready_gpio_ahb_m_s),

    .hsel             (hsel_gpio_ahb_m_m),
    .haddr            (haddr_gpio_ahb_m_m),
    .htrans           (htrans_gpio_ahb_m_m),
    .hwrite           (hwrite_gpio_ahb_m_m),
    .hsize            (hsize_gpio_ahb_m_m),
    .hburst           (hburst_gpio_ahb_m_m),
    .hprot            (hprot_gpio_ahb_m_m),
    .hwdata           (hwdata_gpio_ahb_m_m),
    .hreadymux        (hreadymux_gpio_ahb_m_m),
    .hresp            (hresp_gpio_ahb_m_m),
    .hrdata           (hrdata_gpio_ahb_m_m),
    .hready           (hready_gpio_ahb_m_m)
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
  assign a_phase_idle_busy_en   = hready_gpio_ahb_m_m && hsel_gpio_ahb_m_m && hreadymux_gpio_ahb_m_m;

  assign illegal_idle_busy_resp = a_phase_idle_busy && !hready_gpio_ahb_m_m;
  always @(posedge aclk or negedge aresetn)
  begin : p_ovl_illegal_idle_busy_resp
      if (!aresetn)
          a_phase_idle_busy <= 1'b0;
      else if (a_phase_idle_busy_en)
          a_phase_idle_busy <= ~htrans_gpio_ahb_m_m[1];
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

`include "nic400_amib_gpio_ahb_m_undefs_sse710_integration_example_f0_host_exp.v"

