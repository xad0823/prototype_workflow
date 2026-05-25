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



`include "nic400_amib_slave_8_defs_sse710_sys_apb.v"

module nic400_amib_slave_8_sse710_sys_apb
  (
  

    awid_slave_8_s,
    awaddr_slave_8_s,
    awlen_slave_8_s,
    awsize_slave_8_s,
    awburst_slave_8_s,
    awlock_slave_8_s,
    awcache_slave_8_s,
    awprot_slave_8_s,
    awvalid_slave_8_s,
    awregion_slave_8_s,
    awready_slave_8_s,

    wdata_slave_8_s,
    wstrb_slave_8_s,
    wlast_slave_8_s,
    wvalid_slave_8_s,
    wready_slave_8_s,

    bid_slave_8_s,
    bresp_slave_8_s,
    bvalid_slave_8_s,
    bready_slave_8_s,

    arid_slave_8_s,
    araddr_slave_8_s,
    arlen_slave_8_s,
    arsize_slave_8_s,
    arburst_slave_8_s,
    arlock_slave_8_s,
    arcache_slave_8_s,
    arprot_slave_8_s,
    arvalid_slave_8_s,
    arregion_slave_8_s,
    arready_slave_8_s,

    rid_slave_8_s,
    rdata_slave_8_s,
    rresp_slave_8_s,
    rlast_slave_8_s,
    rvalid_slave_8_s,
    rready_slave_8_s,

    paddr_hse_mhu0,
    pwdata_hse_mhu0,
    pwrite_hse_mhu0,
    pprot_hse_mhu0,
    pstrb_hse_mhu0,
    penable_hse_mhu0,
    psel_hse_mhu0,
    prdata_hse_mhu0,
    pslverr_hse_mhu0,
    pready_hse_mhu0,

    paddr_seh_mhu0,
    pwdata_seh_mhu0,
    pwrite_seh_mhu0,
    pprot_seh_mhu0,
    pstrb_seh_mhu0,
    penable_seh_mhu0,
    psel_seh_mhu0,
    prdata_seh_mhu0,
    pslverr_seh_mhu0,
    pready_seh_mhu0,

    paddr_hse_mhu1,
    pwdata_hse_mhu1,
    pwrite_hse_mhu1,
    pprot_hse_mhu1,
    pstrb_hse_mhu1,
    penable_hse_mhu1,
    psel_hse_mhu1,
    prdata_hse_mhu1,
    pslverr_hse_mhu1,
    pready_hse_mhu1,

    paddr_seh_mhu1,
    pwdata_seh_mhu1,
    pwrite_seh_mhu1,
    pprot_seh_mhu1,
    pstrb_seh_mhu1,
    penable_seh_mhu1,
    psel_seh_mhu1,
    prdata_seh_mhu1,
    pslverr_seh_mhu1,
    pready_seh_mhu1,

    paddr_hes0_mhu0,
    pwdata_hes0_mhu0,
    pwrite_hes0_mhu0,
    pprot_hes0_mhu0,
    pstrb_hes0_mhu0,
    penable_hes0_mhu0,
    psel_hes0_mhu0,
    prdata_hes0_mhu0,
    pslverr_hes0_mhu0,
    pready_hes0_mhu0,

    paddr_es0h_mhu0,
    pwdata_es0h_mhu0,
    pwrite_es0h_mhu0,
    pprot_es0h_mhu0,
    pstrb_es0h_mhu0,
    penable_es0h_mhu0,
    psel_es0h_mhu0,
    prdata_es0h_mhu0,
    pslverr_es0h_mhu0,
    pready_es0h_mhu0,

    paddr_hes0_mhu1,
    pwdata_hes0_mhu1,
    pwrite_hes0_mhu1,
    pprot_hes0_mhu1,
    pstrb_hes0_mhu1,
    penable_hes0_mhu1,
    psel_hes0_mhu1,
    prdata_hes0_mhu1,
    pslverr_hes0_mhu1,
    pready_hes0_mhu1,

    paddr_es0h_mhu1,
    pwdata_es0h_mhu1,
    pwrite_es0h_mhu1,
    pprot_es0h_mhu1,
    pstrb_es0h_mhu1,
    penable_es0h_mhu1,
    psel_es0h_mhu1,
    prdata_es0h_mhu1,
    pslverr_es0h_mhu1,
    pready_es0h_mhu1,

    paddr_hes1_mhu0,
    pwdata_hes1_mhu0,
    pwrite_hes1_mhu0,
    pprot_hes1_mhu0,
    pstrb_hes1_mhu0,
    penable_hes1_mhu0,
    psel_hes1_mhu0,
    prdata_hes1_mhu0,
    pslverr_hes1_mhu0,
    pready_hes1_mhu0,

    paddr_es1h_mhu0,
    pwdata_es1h_mhu0,
    pwrite_es1h_mhu0,
    pprot_es1h_mhu0,
    pstrb_es1h_mhu0,
    penable_es1h_mhu0,
    psel_es1h_mhu0,
    prdata_es1h_mhu0,
    pslverr_es1h_mhu0,
    pready_es1h_mhu0,

    paddr_hes1_mhu1,
    pwdata_hes1_mhu1,
    pwrite_hes1_mhu1,
    pprot_hes1_mhu1,
    pstrb_hes1_mhu1,
    penable_hes1_mhu1,
    psel_hes1_mhu1,
    prdata_hes1_mhu1,
    pslverr_hes1_mhu1,
    pready_hes1_mhu1,

    paddr_es1h_mhu1,
    pwdata_es1h_mhu1,
    pwrite_es1h_mhu1,
    pprot_es1h_mhu1,
    pstrb_es1h_mhu1,
    penable_es1h_mhu1,
    psel_es1h_mhu1,
    prdata_es1h_mhu1,
    pslverr_es1h_mhu1,
    pready_es1h_mhu1,

    apb_pclken,
    aclk,
    aresetn

  );




  


  input   [11:0]      awid_slave_8_s;          
  input   [31:0]      awaddr_slave_8_s;        
  input   [7:0]       awlen_slave_8_s;         
  input   [2:0]       awsize_slave_8_s;        
  input   [1:0]       awburst_slave_8_s;       
  input               awlock_slave_8_s;        
  input   [3:0]       awcache_slave_8_s;       
  input   [2:0]       awprot_slave_8_s;        
  input               awvalid_slave_8_s;       
  input   [3:0]       awregion_slave_8_s;      
  output              awready_slave_8_s;       

  input   [31:0]      wdata_slave_8_s;         
  input   [3:0]       wstrb_slave_8_s;         
  input               wlast_slave_8_s;         
  input               wvalid_slave_8_s;        
  output              wready_slave_8_s;        

  output  [11:0]      bid_slave_8_s;           
  output  [1:0]       bresp_slave_8_s;         
  output              bvalid_slave_8_s;        
  input               bready_slave_8_s;        

  input   [11:0]      arid_slave_8_s;          
  input   [31:0]      araddr_slave_8_s;        
  input   [7:0]       arlen_slave_8_s;         
  input   [2:0]       arsize_slave_8_s;        
  input   [1:0]       arburst_slave_8_s;       
  input               arlock_slave_8_s;        
  input   [3:0]       arcache_slave_8_s;       
  input   [2:0]       arprot_slave_8_s;        
  input               arvalid_slave_8_s;       
  input   [3:0]       arregion_slave_8_s;      
  output              arready_slave_8_s;       

  output  [11:0]      rid_slave_8_s;           
  output  [31:0]      rdata_slave_8_s;         
  output  [1:0]       rresp_slave_8_s;         
  output              rlast_slave_8_s;         
  output              rvalid_slave_8_s;        
  input               rready_slave_8_s;        

  output  [31:0]      paddr_hse_mhu0;    
  output  [31:0]      pwdata_hse_mhu0;   
  output              pwrite_hse_mhu0;   
  output  [2:0]       pprot_hse_mhu0;    
  output  [3:0]       pstrb_hse_mhu0;    
  output              penable_hse_mhu0;  
  output              psel_hse_mhu0;     
  input   [31:0]      prdata_hse_mhu0;   
  input               pslverr_hse_mhu0;  
  input               pready_hse_mhu0;   

  output  [31:0]      paddr_seh_mhu0;    
  output  [31:0]      pwdata_seh_mhu0;   
  output              pwrite_seh_mhu0;   
  output  [2:0]       pprot_seh_mhu0;    
  output  [3:0]       pstrb_seh_mhu0;    
  output              penable_seh_mhu0;  
  output              psel_seh_mhu0;     
  input   [31:0]      prdata_seh_mhu0;   
  input               pslverr_seh_mhu0;  
  input               pready_seh_mhu0;   

  output  [31:0]      paddr_hse_mhu1;    
  output  [31:0]      pwdata_hse_mhu1;   
  output              pwrite_hse_mhu1;   
  output  [2:0]       pprot_hse_mhu1;    
  output  [3:0]       pstrb_hse_mhu1;    
  output              penable_hse_mhu1;  
  output              psel_hse_mhu1;     
  input   [31:0]      prdata_hse_mhu1;   
  input               pslverr_hse_mhu1;  
  input               pready_hse_mhu1;   

  output  [31:0]      paddr_seh_mhu1;    
  output  [31:0]      pwdata_seh_mhu1;   
  output              pwrite_seh_mhu1;   
  output  [2:0]       pprot_seh_mhu1;    
  output  [3:0]       pstrb_seh_mhu1;    
  output              penable_seh_mhu1;  
  output              psel_seh_mhu1;     
  input   [31:0]      prdata_seh_mhu1;   
  input               pslverr_seh_mhu1;  
  input               pready_seh_mhu1;   

  output  [31:0]      paddr_hes0_mhu0;   
  output  [31:0]      pwdata_hes0_mhu0;  
  output              pwrite_hes0_mhu0;  
  output  [2:0]       pprot_hes0_mhu0;   
  output  [3:0]       pstrb_hes0_mhu0;   
  output              penable_hes0_mhu0; 
  output              psel_hes0_mhu0;    
  input   [31:0]      prdata_hes0_mhu0;  
  input               pslverr_hes0_mhu0; 
  input               pready_hes0_mhu0;  

  output  [31:0]      paddr_es0h_mhu0;   
  output  [31:0]      pwdata_es0h_mhu0;  
  output              pwrite_es0h_mhu0;  
  output  [2:0]       pprot_es0h_mhu0;   
  output  [3:0]       pstrb_es0h_mhu0;   
  output              penable_es0h_mhu0; 
  output              psel_es0h_mhu0;    
  input   [31:0]      prdata_es0h_mhu0;  
  input               pslverr_es0h_mhu0; 
  input               pready_es0h_mhu0;  

  output  [31:0]      paddr_hes0_mhu1;   
  output  [31:0]      pwdata_hes0_mhu1;  
  output              pwrite_hes0_mhu1;  
  output  [2:0]       pprot_hes0_mhu1;   
  output  [3:0]       pstrb_hes0_mhu1;   
  output              penable_hes0_mhu1; 
  output              psel_hes0_mhu1;    
  input   [31:0]      prdata_hes0_mhu1;  
  input               pslverr_hes0_mhu1; 
  input               pready_hes0_mhu1;  

  output  [31:0]      paddr_es0h_mhu1;   
  output  [31:0]      pwdata_es0h_mhu1;  
  output              pwrite_es0h_mhu1;  
  output  [2:0]       pprot_es0h_mhu1;   
  output  [3:0]       pstrb_es0h_mhu1;   
  output              penable_es0h_mhu1; 
  output              psel_es0h_mhu1;    
  input   [31:0]      prdata_es0h_mhu1;  
  input               pslverr_es0h_mhu1; 
  input               pready_es0h_mhu1;  

  output  [31:0]      paddr_hes1_mhu0;   
  output  [31:0]      pwdata_hes1_mhu0;  
  output              pwrite_hes1_mhu0;  
  output  [2:0]       pprot_hes1_mhu0;   
  output  [3:0]       pstrb_hes1_mhu0;   
  output              penable_hes1_mhu0; 
  output              psel_hes1_mhu0;    
  input   [31:0]      prdata_hes1_mhu0;  
  input               pslverr_hes1_mhu0; 
  input               pready_hes1_mhu0;  

  output  [31:0]      paddr_es1h_mhu0;   
  output  [31:0]      pwdata_es1h_mhu0;  
  output              pwrite_es1h_mhu0;  
  output  [2:0]       pprot_es1h_mhu0;   
  output  [3:0]       pstrb_es1h_mhu0;   
  output              penable_es1h_mhu0; 
  output              psel_es1h_mhu0;    
  input   [31:0]      prdata_es1h_mhu0;  
  input               pslverr_es1h_mhu0; 
  input               pready_es1h_mhu0;  

  output  [31:0]      paddr_hes1_mhu1;   
  output  [31:0]      pwdata_hes1_mhu1;  
  output              pwrite_hes1_mhu1;  
  output  [2:0]       pprot_hes1_mhu1;   
  output  [3:0]       pstrb_hes1_mhu1;   
  output              penable_hes1_mhu1; 
  output              psel_hes1_mhu1;    
  input   [31:0]      prdata_hes1_mhu1;  
  input               pslverr_hes1_mhu1; 
  input               pready_hes1_mhu1;  

  output  [31:0]      paddr_es1h_mhu1;   
  output  [31:0]      pwdata_es1h_mhu1;  
  output              pwrite_es1h_mhu1;  
  output  [2:0]       pprot_es1h_mhu1;   
  output  [3:0]       pstrb_es1h_mhu1;   
  output              penable_es1h_mhu1; 
  output              psel_es1h_mhu1;    
  input   [31:0]      prdata_es1h_mhu1;  
  input               pslverr_es1h_mhu1; 
  input               pready_es1h_mhu1;  

  input               apb_pclken;              
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

  wire [68:0]    a_master_port_src_data;     
  wire [68:0]    a_master_port_dst_data;     



  wire           d_master_port_dst_valid;
  wire           d_master_port_dst_ready;
  wire           d_master_port_src_valid;
  wire           d_master_port_src_ready;

  wire [47:0]    d_master_port_src_data;     
  wire [47:0]    d_master_port_dst_data;     


  wire           awrite_apb;
  wire [11:0]    aid_apb;
  wire [31:0]    aaddr_apb;
  wire [7:0]        alen_apb;
  wire [2:0]     asize_apb;
  wire [1:0]     aburst_apb;
  wire [3:0]     acache_apb;
  wire [2:0]     aprot_apb;
  wire [3:0]     aregion_apb;
  wire           avalid_apb;
  wire           aready_apb;


  wire [31:0]    wdata_apb;
  wire [3:0]     wstrb_apb;
  wire           wlast_apb;
  wire           wvalid_apb;
  wire           wready_apb;


  wire           dbnr_apb;
  wire [11:0]    did_apb;
  wire [31:0]    ddata_apb;
  wire [1:0]     dresp_apb;
  wire           dlast_apb;
  wire           dvalid_apb;
  wire           dready_apb;


  wire           awrite_slave_8_s;
  wire [11:0]    aid_slave_8_s;
  wire [31:0]    aaddr_slave_8_s;
  wire [7:0]        alen_slave_8_s;
  wire [2:0]     asize_slave_8_s;
  wire [1:0]     aburst_slave_8_s;
  wire [3:0]     acache_slave_8_s;
  wire [2:0]     aprot_slave_8_s;
  wire [3:0]     aregion_slave_8_s;
  wire           avalid_slave_8_s;
  wire           aready_slave_8_s;

  wire           dbnr_slave_8_s;
  wire [11:0]    did_slave_8_s;
  wire [31:0]    ddata_slave_8_s;
  wire [1:0]     dresp_slave_8_s;
  wire           dlast_slave_8_s;
  wire           dvalid_slave_8_s;
  wire           dready_slave_8_s;



  wire                            penable_apb;          
  wire                            pwrite_apb;           
  wire [31:0]                     paddr_apb;            
  wire [31:0]                     pwdata_apb;           

  wire [2:0]                      pprot_apb;            
  wire [3:0]                      pstrb_apb;            



  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_slave_8_s[31:24]  & {8{wstrb_slave_8_s[3]}}),
  (wdata_slave_8_s[23:16]  & {8{wstrb_slave_8_s[2]}}),
  (wdata_slave_8_s[15:8]  & {8{wstrb_slave_8_s[1]}}),
  (wdata_slave_8_s[7:0]  & {8{wstrb_slave_8_s[0]}})};
  
  nic400_amib_slave_8_axi_to_itb_sse710_sys_apb u_axi_to_itb
  (
    .awid           (awid_slave_8_s),
    .awaddr         (awaddr_slave_8_s),
    .awlen          (awlen_slave_8_s),
    .awsize         (awsize_slave_8_s),
    .awburst        (awburst_slave_8_s),
    .awlock         (awlock_slave_8_s),
    .awcache        (awcache_slave_8_s),
    .awprot         (awprot_slave_8_s),
    .awregion       (awregion_slave_8_s),
    .awvalid        (awvalid_slave_8_s),
    .awready        (awready_slave_8_s),

    .bid            (bid_slave_8_s),
    .bresp          (bresp_slave_8_s),
    .bvalid         (bvalid_slave_8_s),
    .bready         (bready_slave_8_s),

    .arid           (arid_slave_8_s),
    .araddr         (araddr_slave_8_s),
    .arlen          (arlen_slave_8_s),
    .arsize         (arsize_slave_8_s),
    .arburst        (arburst_slave_8_s),
    .arlock         (arlock_slave_8_s),
    .arcache        (arcache_slave_8_s),
    .arprot         (arprot_slave_8_s),
    .arregion       (arregion_slave_8_s),
    .arvalid        (arvalid_slave_8_s),
    .arready        (arready_slave_8_s),

    .rid            (rid_slave_8_s),
    .rdata          (rdata_slave_8_s),
    .rresp          (rresp_slave_8_s),
    .rlast          (rlast_slave_8_s),
    .rvalid         (rvalid_slave_8_s),
    .rready         (rready_slave_8_s),

    .awrite         (awrite_slave_8_s),
    .aid            (aid_slave_8_s),
    .aaddr          (aaddr_slave_8_s),
    .alen           (alen_slave_8_s),
    .asize          (asize_slave_8_s),
    .aburst         (aburst_slave_8_s),
    .alock          (),
    .acache         (acache_slave_8_s),
    .aprot          (aprot_slave_8_s),
    .aregion        (aregion_slave_8_s),
    .avalid         (avalid_slave_8_s),
    .aready         (aready_slave_8_s),

    .dbnr           (dbnr_slave_8_s),
    .did            (did_slave_8_s),
    .ddata          (ddata_slave_8_s),
    .dresp          (dresp_slave_8_s),
    .dlast          (dlast_slave_8_s),
    .dvalid         (dvalid_slave_8_s),
    .dready         (dready_slave_8_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );




  assign w_master_port_src_data = {wdata_destrob,
        wstrb_slave_8_s,
        wlast_slave_8_s};

  assign {wdata_apb,
        wstrb_apb,
        wlast_apb} = w_master_port_dst_data;

  assign wvalid_apb = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_apb;

  assign w_master_port_src_valid = wvalid_slave_8_s;
  assign wready_slave_8_s = w_master_port_src_ready;




  assign a_master_port_src_data = {aid_slave_8_s,
        aaddr_slave_8_s,
        alen_slave_8_s,
        asize_slave_8_s,
        aburst_slave_8_s,
        acache_slave_8_s,
        aregion_slave_8_s,
        aprot_slave_8_s,
        awrite_slave_8_s};

  assign {aid_apb,
        aaddr_apb,
        alen_apb,
        asize_apb,
        aburst_apb,
        acache_apb,
        aregion_apb,
        aprot_apb,
        awrite_apb} = a_master_port_dst_data;

  assign avalid_apb = a_master_port_dst_valid;
  assign a_master_port_dst_ready = aready_apb;

  assign a_master_port_src_valid = avalid_slave_8_s;
  assign aready_slave_8_s = a_master_port_src_ready;



  assign d_master_port_src_data = {did_apb,
        ddata_apb,
        dresp_apb,
        dlast_apb,
        dbnr_apb};

  assign {did_slave_8_s,
        ddata_slave_8_s,
        dresp_slave_8_s,
        dlast_slave_8_s,
        dbnr_slave_8_s} = d_master_port_dst_data;

  assign dvalid_slave_8_s =  d_master_port_dst_valid;
  assign d_master_port_dst_ready = dready_slave_8_s;

  assign d_master_port_src_valid = dvalid_apb;
  assign dready_apb = d_master_port_src_ready;


  nic400_amib_slave_8_apb_m_sse710_sys_apb #(
    .ID_WIDTH         (12),
    .ADDR_WIDTH       (32)
  ) u_apb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_apb),
    .aid              (aid_apb),
    .aaddr            (aaddr_apb),
    .alen             (alen_apb),
    .asize            (asize_apb),
    .aburst           (aburst_apb),
    .aregion          (aregion_apb),
    .aprot            (aprot_apb),

    .avalid           (avalid_apb),
    .aready           (aready_apb),

    .dbnr             (dbnr_apb),
    .did              (did_apb),
    .ddata            (ddata_apb),
    .dresp            (dresp_apb),
    .dlast            (dlast_apb),
    .dvalid           (dvalid_apb),
    .dready           (dready_apb),

    .wdata            (wdata_apb),
    .wstrb            (wstrb_apb),
    .wlast            (wlast_apb),
    .wvalid           (wvalid_apb),
    .wready           (wready_apb),

    .pclken           (apb_pclken),
    .psel_hse_mhu0_i     (psel_hse_mhu0),
    .psel_seh_mhu0_i     (psel_seh_mhu0),
    .psel_hse_mhu1_i     (psel_hse_mhu1),
    .psel_seh_mhu1_i     (psel_seh_mhu1),
    .psel_hes0_mhu0_i     (psel_hes0_mhu0),
    .psel_es0h_mhu0_i     (psel_es0h_mhu0),
    .psel_hes0_mhu1_i     (psel_hes0_mhu1),
    .psel_es0h_mhu1_i     (psel_es0h_mhu1),
    .psel_hes1_mhu0_i     (psel_hes1_mhu0),
    .psel_es1h_mhu0_i     (psel_es1h_mhu0),
    .psel_hes1_mhu1_i     (psel_hes1_mhu1),
    .psel_es1h_mhu1_i     (psel_es1h_mhu1),
    .pready_hse_mhu0_i   (pready_hse_mhu0),
    .pready_seh_mhu0_i   (pready_seh_mhu0),
    .pready_hse_mhu1_i   (pready_hse_mhu1),
    .pready_seh_mhu1_i   (pready_seh_mhu1),
    .pready_hes0_mhu0_i   (pready_hes0_mhu0),
    .pready_es0h_mhu0_i   (pready_es0h_mhu0),
    .pready_hes0_mhu1_i   (pready_hes0_mhu1),
    .pready_es0h_mhu1_i   (pready_es0h_mhu1),
    .pready_hes1_mhu0_i   (pready_hes1_mhu0),
    .pready_es1h_mhu0_i   (pready_es1h_mhu0),
    .pready_hes1_mhu1_i   (pready_hes1_mhu1),
    .pready_es1h_mhu1_i   (pready_es1h_mhu1),
    .pslverr_hse_mhu0_i  (pslverr_hse_mhu0),
    .pslverr_seh_mhu0_i  (pslverr_seh_mhu0),
    .pslverr_hse_mhu1_i  (pslverr_hse_mhu1),
    .pslverr_seh_mhu1_i  (pslverr_seh_mhu1),
    .pslverr_hes0_mhu0_i  (pslverr_hes0_mhu0),
    .pslverr_es0h_mhu0_i  (pslverr_es0h_mhu0),
    .pslverr_hes0_mhu1_i  (pslverr_hes0_mhu1),
    .pslverr_es0h_mhu1_i  (pslverr_es0h_mhu1),
    .pslverr_hes1_mhu0_i  (pslverr_hes1_mhu0),
    .pslverr_es1h_mhu0_i  (pslverr_es1h_mhu0),
    .pslverr_hes1_mhu1_i  (pslverr_hes1_mhu1),
    .pslverr_es1h_mhu1_i  (pslverr_es1h_mhu1),
    .prdata_hse_mhu0_i   (prdata_hse_mhu0),
    .prdata_seh_mhu0_i   (prdata_seh_mhu0),
    .prdata_hse_mhu1_i   (prdata_hse_mhu1),
    .prdata_seh_mhu1_i   (prdata_seh_mhu1),
    .prdata_hes0_mhu0_i   (prdata_hes0_mhu0),
    .prdata_es0h_mhu0_i   (prdata_es0h_mhu0),
    .prdata_hes0_mhu1_i   (prdata_hes0_mhu1),
    .prdata_es0h_mhu1_i   (prdata_es0h_mhu1),
    .prdata_hes1_mhu0_i   (prdata_hes1_mhu0),
    .prdata_es1h_mhu0_i   (prdata_es1h_mhu0),
    .prdata_hes1_mhu1_i   (prdata_hes1_mhu1),
    .prdata_es1h_mhu1_i   (prdata_es1h_mhu1),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_hse_mhu0 = penable_apb;
  assign penable_seh_mhu0 = penable_apb;
  assign penable_hse_mhu1 = penable_apb;
  assign penable_seh_mhu1 = penable_apb;
  assign penable_hes0_mhu0 = penable_apb;
  assign penable_es0h_mhu0 = penable_apb;
  assign penable_hes0_mhu1 = penable_apb;
  assign penable_es0h_mhu1 = penable_apb;
  assign penable_hes1_mhu0 = penable_apb;
  assign penable_es1h_mhu0 = penable_apb;
  assign penable_hes1_mhu1 = penable_apb;
  assign penable_es1h_mhu1 = penable_apb;

  assign pwrite_hse_mhu0 = pwrite_apb;
  assign pwrite_seh_mhu0 = pwrite_apb;
  assign pwrite_hse_mhu1 = pwrite_apb;
  assign pwrite_seh_mhu1 = pwrite_apb;
  assign pwrite_hes0_mhu0 = pwrite_apb;
  assign pwrite_es0h_mhu0 = pwrite_apb;
  assign pwrite_hes0_mhu1 = pwrite_apb;
  assign pwrite_es0h_mhu1 = pwrite_apb;
  assign pwrite_hes1_mhu0 = pwrite_apb;
  assign pwrite_es1h_mhu0 = pwrite_apb;
  assign pwrite_hes1_mhu1 = pwrite_apb;
  assign pwrite_es1h_mhu1 = pwrite_apb;

  assign paddr_hse_mhu0 = paddr_apb;
  assign paddr_seh_mhu0 = paddr_apb;
  assign paddr_hse_mhu1 = paddr_apb;
  assign paddr_seh_mhu1 = paddr_apb;
  assign paddr_hes0_mhu0 = paddr_apb;
  assign paddr_es0h_mhu0 = paddr_apb;
  assign paddr_hes0_mhu1 = paddr_apb;
  assign paddr_es0h_mhu1 = paddr_apb;
  assign paddr_hes1_mhu0 = paddr_apb;
  assign paddr_es1h_mhu0 = paddr_apb;
  assign paddr_hes1_mhu1 = paddr_apb;
  assign paddr_es1h_mhu1 = paddr_apb;

  assign pwdata_hse_mhu0 = pwdata_apb;
  assign pwdata_seh_mhu0 = pwdata_apb;
  assign pwdata_hse_mhu1 = pwdata_apb;
  assign pwdata_seh_mhu1 = pwdata_apb;
  assign pwdata_hes0_mhu0 = pwdata_apb;
  assign pwdata_es0h_mhu0 = pwdata_apb;
  assign pwdata_hes0_mhu1 = pwdata_apb;
  assign pwdata_es0h_mhu1 = pwdata_apb;
  assign pwdata_hes1_mhu0 = pwdata_apb;
  assign pwdata_es1h_mhu0 = pwdata_apb;
  assign pwdata_hes1_mhu1 = pwdata_apb;
  assign pwdata_es1h_mhu1 = pwdata_apb;

  assign pprot_hse_mhu0 = pprot_apb;
  assign pprot_seh_mhu0 = pprot_apb;
  assign pprot_hse_mhu1 = pprot_apb;
  assign pprot_seh_mhu1 = pprot_apb;
  assign pprot_hes0_mhu0 = pprot_apb;
  assign pprot_es0h_mhu0 = pprot_apb;
  assign pprot_hes0_mhu1 = pprot_apb;
  assign pprot_es0h_mhu1 = pprot_apb;
  assign pprot_hes1_mhu0 = pprot_apb;
  assign pprot_es1h_mhu0 = pprot_apb;
  assign pprot_hes1_mhu1 = pprot_apb;
  assign pprot_es1h_mhu1 = pprot_apb;

  assign pstrb_hse_mhu0 = pstrb_apb;
  assign pstrb_seh_mhu0 = pstrb_apb;
  assign pstrb_hse_mhu1 = pstrb_apb;
  assign pstrb_seh_mhu1 = pstrb_apb;
  assign pstrb_hes0_mhu0 = pstrb_apb;
  assign pstrb_es0h_mhu0 = pstrb_apb;
  assign pstrb_hes0_mhu1 = pstrb_apb;
  assign pstrb_es0h_mhu1 = pstrb_apb;
  assign pstrb_hes1_mhu0 = pstrb_apb;
  assign pstrb_es1h_mhu0 = pstrb_apb;
  assign pstrb_hes1_mhu1 = pstrb_apb;
  assign pstrb_es1h_mhu1 = pstrb_apb;





  nic400_amib_slave_8_chan_slice_sse710_sys_apb
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




  nic400_amib_slave_8_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       69  
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




  nic400_amib_slave_8_chan_slice_sse710_sys_apb
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

`include "nic400_amib_slave_8_undefs_sse710_sys_apb.v"

