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



`include "nic400_amib_slave_if0_0_m_defs_sse710_boot_reg.v"

module nic400_amib_slave_if0_0_m_sse710_boot_reg
  (
  
    paddr_master_if0,
    pwdata_master_if0,
    pwrite_master_if0,
    pprot_master_if0,
    pstrb_master_if0,
    penable_master_if0,
    psel_master_if0,
    prdata_master_if0,
    pslverr_master_if0,
    pready_master_if0,


    aid_slave_if0_0_m_s,
    aaddr_slave_if0_0_m_s,
    alen_slave_if0_0_m_s,
    asize_slave_if0_0_m_s,
    aburst_slave_if0_0_m_s,
    alock_slave_if0_0_m_s,
    acache_slave_if0_0_m_s,
    aprot_slave_if0_0_m_s,
    awrite_slave_if0_0_m_s,
    avalid_slave_if0_0_m_s,
    aready_slave_if0_0_m_s,

    wdata_slave_if0_0_m_s,
    wstrb_slave_if0_0_m_s,
    wlast_slave_if0_0_m_s,
    wvalid_slave_if0_0_m_s,
    wready_slave_if0_0_m_s,

    did_slave_if0_0_m_s,
    ddata_slave_if0_0_m_s,
    dresp_slave_if0_0_m_s,
    dlast_slave_if0_0_m_s,
    dbnr_slave_if0_0_m_s,
    dvalid_slave_if0_0_m_s,
    dready_slave_if0_0_m_s,

    apb_pclken,
    aclk,
    aresetn

  );




  
  output  [31:0]      paddr_master_if0;      
  output  [31:0]      pwdata_master_if0;     
  output              pwrite_master_if0;     
  output  [2:0]       pprot_master_if0;      
  output  [3:0]       pstrb_master_if0;      
  output              penable_master_if0;    
  output              psel_master_if0;       
  input   [31:0]      prdata_master_if0;     
  input               pslverr_master_if0;    
  input               pready_master_if0;     



  input   [9:0]       aid_slave_if0_0_m_s;         
  input   [31:0]      aaddr_slave_if0_0_m_s;       
  input   [7:0]       alen_slave_if0_0_m_s;        
  input   [2:0]       asize_slave_if0_0_m_s;       
  input   [1:0]       aburst_slave_if0_0_m_s;      
  input               alock_slave_if0_0_m_s;       
  input   [3:0]       acache_slave_if0_0_m_s;      
  input   [2:0]       aprot_slave_if0_0_m_s;       
  input               awrite_slave_if0_0_m_s;      
  input               avalid_slave_if0_0_m_s;      
  output              aready_slave_if0_0_m_s;      

  input   [31:0]      wdata_slave_if0_0_m_s;       
  input   [3:0]       wstrb_slave_if0_0_m_s;       
  input               wlast_slave_if0_0_m_s;       
  input               wvalid_slave_if0_0_m_s;      
  output              wready_slave_if0_0_m_s;      

  output  [9:0]       did_slave_if0_0_m_s;         
  output  [31:0]      ddata_slave_if0_0_m_s;       
  output  [1:0]       dresp_slave_if0_0_m_s;       
  output              dlast_slave_if0_0_m_s;       
  output              dbnr_slave_if0_0_m_s;        
  output              dvalid_slave_if0_0_m_s;      
  input               dready_slave_if0_0_m_s;      

  input               apb_pclken;                  
  input               aclk;                        
  input               aresetn;                     






  wire                            penable_apb;          
  wire                            pwrite_apb;           
  wire [31:0]                     paddr_apb;            
  wire [31:0]                     pwdata_apb;           

  wire [2:0]                      pprot_apb;            
  wire [3:0]                      pstrb_apb;            



  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_slave_if0_0_m_s[31:24]  & {8{wstrb_slave_if0_0_m_s[3]}}),
  (wdata_slave_if0_0_m_s[23:16]  & {8{wstrb_slave_if0_0_m_s[2]}}),
  (wdata_slave_if0_0_m_s[15:8]  & {8{wstrb_slave_if0_0_m_s[1]}}),
  (wdata_slave_if0_0_m_s[7:0]  & {8{wstrb_slave_if0_0_m_s[0]}})};
  
  nic400_amib_slave_if0_0_m_apb_m_sse710_boot_reg #(
    .ID_WIDTH         (10),
    .ADDR_WIDTH       (32)
  ) u_apb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_slave_if0_0_m_s),
    .aid              (aid_slave_if0_0_m_s),
    .aaddr            (aaddr_slave_if0_0_m_s),
    .alen             (alen_slave_if0_0_m_s),
    .asize            (asize_slave_if0_0_m_s),
    .aburst           (aburst_slave_if0_0_m_s),
    .aprot            (aprot_slave_if0_0_m_s),

    .avalid           (avalid_slave_if0_0_m_s),
    .aready           (aready_slave_if0_0_m_s),

    .dbnr             (dbnr_slave_if0_0_m_s),
    .did              (did_slave_if0_0_m_s),
    .ddata            (ddata_slave_if0_0_m_s),
    .dresp            (dresp_slave_if0_0_m_s),
    .dlast            (dlast_slave_if0_0_m_s),
    .dvalid           (dvalid_slave_if0_0_m_s),
    .dready           (dready_slave_if0_0_m_s),

    .wdata            (wdata_destrob),
    .wstrb            (wstrb_slave_if0_0_m_s),
    .wlast            (wlast_slave_if0_0_m_s),
    .wvalid           (wvalid_slave_if0_0_m_s),
    .wready           (wready_slave_if0_0_m_s),

    .pclken           (apb_pclken),
    .psel_master_if0_i     (psel_master_if0),
    .pready_master_if0_i   (pready_master_if0),
    .pslverr_master_if0_i  (pslverr_master_if0),
    .prdata_master_if0_i   (prdata_master_if0),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_master_if0 = penable_apb;

  assign pwrite_master_if0 = pwrite_apb;

  assign paddr_master_if0 = paddr_apb;

  assign pwdata_master_if0 = pwdata_apb;

  assign pprot_master_if0 = pprot_apb;

  assign pstrb_master_if0 = pstrb_apb;













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


  wire strobeless_wdata;
  wire wif_hndshk;


  assign wif_hndshk = penable_apb & pwrite_apb;
  assign strobeless_wdata = wif_hndshk & (
  (|pwdata_apb[31:24]  & ~pstrb_apb[3]) | 
  (|pwdata_apb[23:16]  & ~pstrb_apb[2]) | 
  (|pwdata_apb[15:8]  & ~pstrb_apb[1]) | 
  (|pwdata_apb[7:0]  & ~pstrb_apb[0]));



  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "AMIB: WDATA not destrobed.")
  amib_destrob_mif
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (strobeless_wdata)
  );


  `endif 



endmodule

`include "nic400_amib_slave_if0_0_m_undefs_sse710_boot_reg.v"

