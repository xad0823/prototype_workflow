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



`include "nic400_amib_apb_group0_defs_sse710_integration_example_f0_host_exp.v"

module nic400_amib_apb_group0_sse710_integration_example_f0_host_exp
  (
  
    paddr_vultan_apb_m,
    pwdata_vultan_apb_m,
    pwrite_vultan_apb_m,
    pprot_vultan_apb_m,
    pstrb_vultan_apb_m,
    penable_vultan_apb_m,
    psel_vultan_apb_m,
    prdata_vultan_apb_m,
    pslverr_vultan_apb_m,
    pready_vultan_apb_m,

    paddr_extsys0_ppu_abp_m,
    pwdata_extsys0_ppu_abp_m,
    pwrite_extsys0_ppu_abp_m,
    penable_extsys0_ppu_abp_m,
    psel_extsys0_ppu_abp_m,
    prdata_extsys0_ppu_abp_m,
    pslverr_extsys0_ppu_abp_m,
    pready_extsys0_ppu_abp_m,

    paddr_extsys1_ppu_abp_m,
    pwdata_extsys1_ppu_abp_m,
    pwrite_extsys1_ppu_abp_m,
    penable_extsys1_ppu_abp_m,
    psel_extsys1_ppu_abp_m,
    prdata_extsys1_ppu_abp_m,
    pslverr_extsys1_ppu_abp_m,
    pready_extsys1_ppu_abp_m,


    aid_apb_group0_s,
    aaddr_apb_group0_s,
    alen_apb_group0_s,
    asize_apb_group0_s,
    aburst_apb_group0_s,
    alock_apb_group0_s,
    acache_apb_group0_s,
    aprot_apb_group0_s,
    awrite_apb_group0_s,
    avalid_apb_group0_s,
    aregion_apb_group0_s,
    aready_apb_group0_s,

    wdata_apb_group0_s,
    wstrb_apb_group0_s,
    wlast_apb_group0_s,
    wvalid_apb_group0_s,
    wready_apb_group0_s,

    did_apb_group0_s,
    ddata_apb_group0_s,
    dresp_apb_group0_s,
    dlast_apb_group0_s,
    dbnr_apb_group0_s,
    dvalid_apb_group0_s,
    dready_apb_group0_s,

    apb_pclken,
    aclk,
    aresetn

  );




  
  output  [31:0]      paddr_vultan_apb_m;       
  output  [31:0]      pwdata_vultan_apb_m;      
  output              pwrite_vultan_apb_m;      
  output  [2:0]       pprot_vultan_apb_m;       
  output  [3:0]       pstrb_vultan_apb_m;       
  output              penable_vultan_apb_m;     
  output              psel_vultan_apb_m;        
  input   [31:0]      prdata_vultan_apb_m;      
  input               pslverr_vultan_apb_m;     
  input               pready_vultan_apb_m;      

  output  [31:0]      paddr_extsys0_ppu_abp_m;  
  output  [31:0]      pwdata_extsys0_ppu_abp_m; 
  output              pwrite_extsys0_ppu_abp_m; 
  output              penable_extsys0_ppu_abp_m;
  output              psel_extsys0_ppu_abp_m;   
  input   [31:0]      prdata_extsys0_ppu_abp_m; 
  input               pslverr_extsys0_ppu_abp_m;
  input               pready_extsys0_ppu_abp_m; 

  output  [31:0]      paddr_extsys1_ppu_abp_m;  
  output  [31:0]      pwdata_extsys1_ppu_abp_m; 
  output              pwrite_extsys1_ppu_abp_m; 
  output              penable_extsys1_ppu_abp_m;
  output              psel_extsys1_ppu_abp_m;   
  input   [31:0]      prdata_extsys1_ppu_abp_m; 
  input               pslverr_extsys1_ppu_abp_m;
  input               pready_extsys1_ppu_abp_m; 



  input   [17:0]      aid_apb_group0_s;               
  input   [31:0]      aaddr_apb_group0_s;             
  input   [7:0]       alen_apb_group0_s;              
  input   [2:0]       asize_apb_group0_s;             
  input   [1:0]       aburst_apb_group0_s;            
  input               alock_apb_group0_s;             
  input   [3:0]       acache_apb_group0_s;            
  input   [2:0]       aprot_apb_group0_s;             
  input               awrite_apb_group0_s;            
  input               avalid_apb_group0_s;            
  input   [3:0]       aregion_apb_group0_s;           
  output              aready_apb_group0_s;            

  input   [31:0]      wdata_apb_group0_s;             
  input   [3:0]       wstrb_apb_group0_s;             
  input               wlast_apb_group0_s;             
  input               wvalid_apb_group0_s;            
  output              wready_apb_group0_s;            

  output  [17:0]      did_apb_group0_s;               
  output  [31:0]      ddata_apb_group0_s;             
  output  [1:0]       dresp_apb_group0_s;             
  output              dlast_apb_group0_s;             
  output              dbnr_apb_group0_s;              
  output              dvalid_apb_group0_s;            
  input               dready_apb_group0_s;            

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
  (wdata_apb_group0_s[31:24]  & {8{wstrb_apb_group0_s[3]}}),
  (wdata_apb_group0_s[23:16]  & {8{wstrb_apb_group0_s[2]}}),
  (wdata_apb_group0_s[15:8]  & {8{wstrb_apb_group0_s[1]}}),
  (wdata_apb_group0_s[7:0]  & {8{wstrb_apb_group0_s[0]}})};
  
  nic400_amib_apb_group0_apb_m_sse710_integration_example_f0_host_exp #(
    .ID_WIDTH         (18),
    .ADDR_WIDTH       (32)
  ) u_apb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_apb_group0_s),
    .aid              (aid_apb_group0_s),
    .aaddr            (aaddr_apb_group0_s),
    .alen             (alen_apb_group0_s),
    .asize            (asize_apb_group0_s),
    .aburst           (aburst_apb_group0_s),
    .aregion          (aregion_apb_group0_s),
    .aprot            (aprot_apb_group0_s),

    .avalid           (avalid_apb_group0_s),
    .aready           (aready_apb_group0_s),

    .dbnr             (dbnr_apb_group0_s),
    .did              (did_apb_group0_s),
    .ddata            (ddata_apb_group0_s),
    .dresp            (dresp_apb_group0_s),
    .dlast            (dlast_apb_group0_s),
    .dvalid           (dvalid_apb_group0_s),
    .dready           (dready_apb_group0_s),

    .wdata            (wdata_destrob),
    .wstrb            (wstrb_apb_group0_s),
    .wlast            (wlast_apb_group0_s),
    .wvalid           (wvalid_apb_group0_s),
    .wready           (wready_apb_group0_s),

    .pclken           (apb_pclken),
    .psel_vultan_apb_m_i     (psel_vultan_apb_m),
    .psel_extsys0_ppu_abp_m_i     (psel_extsys0_ppu_abp_m),
    .psel_extsys1_ppu_abp_m_i     (psel_extsys1_ppu_abp_m),
    .pready_vultan_apb_m_i   (pready_vultan_apb_m),
    .pready_extsys0_ppu_abp_m_i   (pready_extsys0_ppu_abp_m),
    .pready_extsys1_ppu_abp_m_i   (pready_extsys1_ppu_abp_m),
    .pslverr_vultan_apb_m_i  (pslverr_vultan_apb_m),
    .pslverr_extsys0_ppu_abp_m_i  (pslverr_extsys0_ppu_abp_m),
    .pslverr_extsys1_ppu_abp_m_i  (pslverr_extsys1_ppu_abp_m),
    .prdata_vultan_apb_m_i   (prdata_vultan_apb_m),
    .prdata_extsys0_ppu_abp_m_i   (prdata_extsys0_ppu_abp_m),
    .prdata_extsys1_ppu_abp_m_i   (prdata_extsys1_ppu_abp_m),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_vultan_apb_m = penable_apb;
  assign penable_extsys0_ppu_abp_m = penable_apb;
  assign penable_extsys1_ppu_abp_m = penable_apb;

  assign pwrite_vultan_apb_m = pwrite_apb;
  assign pwrite_extsys0_ppu_abp_m = pwrite_apb;
  assign pwrite_extsys1_ppu_abp_m = pwrite_apb;

  assign paddr_vultan_apb_m = paddr_apb;
  assign paddr_extsys0_ppu_abp_m = paddr_apb;
  assign paddr_extsys1_ppu_abp_m = paddr_apb;

  assign pwdata_vultan_apb_m = pwdata_apb;
  assign pwdata_extsys0_ppu_abp_m = pwdata_apb;
  assign pwdata_extsys1_ppu_abp_m = pwdata_apb;

  assign pprot_vultan_apb_m = pprot_apb;

  assign pstrb_vultan_apb_m = pstrb_apb;













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

`include "nic400_amib_apb_group0_undefs_sse710_integration_example_f0_host_exp.v"

