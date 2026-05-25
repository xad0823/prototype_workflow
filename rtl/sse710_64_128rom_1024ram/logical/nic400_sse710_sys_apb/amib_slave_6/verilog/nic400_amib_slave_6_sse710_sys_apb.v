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



`include "nic400_amib_slave_6_defs_sse710_sys_apb.v"

module nic400_amib_slave_6_sse710_sys_apb
  (
  

    awid_slave_6_s,
    awaddr_slave_6_s,
    awlen_slave_6_s,
    awsize_slave_6_s,
    awburst_slave_6_s,
    awlock_slave_6_s,
    awcache_slave_6_s,
    awprot_slave_6_s,
    awvalid_slave_6_s,
    awregion_slave_6_s,
    awready_slave_6_s,

    wdata_slave_6_s,
    wstrb_slave_6_s,
    wlast_slave_6_s,
    wvalid_slave_6_s,
    wready_slave_6_s,

    bid_slave_6_s,
    bresp_slave_6_s,
    bvalid_slave_6_s,
    bready_slave_6_s,

    arid_slave_6_s,
    araddr_slave_6_s,
    arlen_slave_6_s,
    arsize_slave_6_s,
    arburst_slave_6_s,
    arlock_slave_6_s,
    arcache_slave_6_s,
    arprot_slave_6_s,
    arvalid_slave_6_s,
    arregion_slave_6_s,
    arready_slave_6_s,

    rid_slave_6_s,
    rdata_slave_6_s,
    rresp_slave_6_s,
    rlast_slave_6_s,
    rvalid_slave_6_s,
    rready_slave_6_s,

    paddr_hostsysdbg_apb,
    pwdata_hostsysdbg_apb,
    pwrite_hostsysdbg_apb,
    pprot_hostsysdbg_apb,
    pstrb_hostsysdbg_apb,
    penable_hostsysdbg_apb,
    psel_hostsysdbg_apb,
    prdata_hostsysdbg_apb,
    pslverr_hostsysdbg_apb,
    pready_hostsysdbg_apb,

    paddr_sdc600_apb,
    pwdata_sdc600_apb,
    pwrite_sdc600_apb,
    pprot_sdc600_apb,
    pstrb_sdc600_apb,
    penable_sdc600_apb,
    psel_sdc600_apb,
    prdata_sdc600_apb,
    pslverr_sdc600_apb,
    pready_sdc600_apb,

    apb_pclken,
    aclk,
    aresetn

  );




  


  input   [11:0]      awid_slave_6_s;              
  input   [31:0]      awaddr_slave_6_s;            
  input   [7:0]       awlen_slave_6_s;             
  input   [2:0]       awsize_slave_6_s;            
  input   [1:0]       awburst_slave_6_s;           
  input               awlock_slave_6_s;            
  input   [3:0]       awcache_slave_6_s;           
  input   [2:0]       awprot_slave_6_s;            
  input               awvalid_slave_6_s;           
  input   [3:0]       awregion_slave_6_s;          
  output              awready_slave_6_s;           

  input   [31:0]      wdata_slave_6_s;             
  input   [3:0]       wstrb_slave_6_s;             
  input               wlast_slave_6_s;             
  input               wvalid_slave_6_s;            
  output              wready_slave_6_s;            

  output  [11:0]      bid_slave_6_s;               
  output  [1:0]       bresp_slave_6_s;             
  output              bvalid_slave_6_s;            
  input               bready_slave_6_s;            

  input   [11:0]      arid_slave_6_s;              
  input   [31:0]      araddr_slave_6_s;            
  input   [7:0]       arlen_slave_6_s;             
  input   [2:0]       arsize_slave_6_s;            
  input   [1:0]       arburst_slave_6_s;           
  input               arlock_slave_6_s;            
  input   [3:0]       arcache_slave_6_s;           
  input   [2:0]       arprot_slave_6_s;            
  input               arvalid_slave_6_s;           
  input   [3:0]       arregion_slave_6_s;          
  output              arready_slave_6_s;           

  output  [11:0]      rid_slave_6_s;               
  output  [31:0]      rdata_slave_6_s;             
  output  [1:0]       rresp_slave_6_s;             
  output              rlast_slave_6_s;             
  output              rvalid_slave_6_s;            
  input               rready_slave_6_s;            

  output  [31:0]      paddr_hostsysdbg_apb;  
  output  [31:0]      pwdata_hostsysdbg_apb; 
  output              pwrite_hostsysdbg_apb; 
  output  [2:0]       pprot_hostsysdbg_apb;  
  output  [3:0]       pstrb_hostsysdbg_apb;  
  output              penable_hostsysdbg_apb;
  output              psel_hostsysdbg_apb;   
  input   [31:0]      prdata_hostsysdbg_apb; 
  input               pslverr_hostsysdbg_apb;
  input               pready_hostsysdbg_apb; 

  output  [31:0]      paddr_sdc600_apb;      
  output  [31:0]      pwdata_sdc600_apb;     
  output              pwrite_sdc600_apb;     
  output  [2:0]       pprot_sdc600_apb;      
  output  [3:0]       pstrb_sdc600_apb;      
  output              penable_sdc600_apb;    
  output              psel_sdc600_apb;       
  input   [31:0]      prdata_sdc600_apb;     
  input               pslverr_sdc600_apb;    
  input               pready_sdc600_apb;     

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


  wire           awrite_slave_6_s;
  wire [11:0]    aid_slave_6_s;
  wire [31:0]    aaddr_slave_6_s;
  wire [7:0]        alen_slave_6_s;
  wire [2:0]     asize_slave_6_s;
  wire [1:0]     aburst_slave_6_s;
  wire [3:0]     acache_slave_6_s;
  wire [2:0]     aprot_slave_6_s;
  wire [3:0]     aregion_slave_6_s;
  wire           avalid_slave_6_s;
  wire           aready_slave_6_s;

  wire           dbnr_slave_6_s;
  wire [11:0]    did_slave_6_s;
  wire [31:0]    ddata_slave_6_s;
  wire [1:0]     dresp_slave_6_s;
  wire           dlast_slave_6_s;
  wire           dvalid_slave_6_s;
  wire           dready_slave_6_s;



  wire                            penable_apb;          
  wire                            pwrite_apb;           
  wire [31:0]                     paddr_apb;            
  wire [31:0]                     pwdata_apb;           

  wire [2:0]                      pprot_apb;            
  wire [3:0]                      pstrb_apb;            



  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_slave_6_s[31:24]  & {8{wstrb_slave_6_s[3]}}),
  (wdata_slave_6_s[23:16]  & {8{wstrb_slave_6_s[2]}}),
  (wdata_slave_6_s[15:8]  & {8{wstrb_slave_6_s[1]}}),
  (wdata_slave_6_s[7:0]  & {8{wstrb_slave_6_s[0]}})};
  
  nic400_amib_slave_6_axi_to_itb_sse710_sys_apb u_axi_to_itb
  (
    .awid           (awid_slave_6_s),
    .awaddr         (awaddr_slave_6_s),
    .awlen          (awlen_slave_6_s),
    .awsize         (awsize_slave_6_s),
    .awburst        (awburst_slave_6_s),
    .awlock         (awlock_slave_6_s),
    .awcache        (awcache_slave_6_s),
    .awprot         (awprot_slave_6_s),
    .awregion       (awregion_slave_6_s),
    .awvalid        (awvalid_slave_6_s),
    .awready        (awready_slave_6_s),

    .bid            (bid_slave_6_s),
    .bresp          (bresp_slave_6_s),
    .bvalid         (bvalid_slave_6_s),
    .bready         (bready_slave_6_s),

    .arid           (arid_slave_6_s),
    .araddr         (araddr_slave_6_s),
    .arlen          (arlen_slave_6_s),
    .arsize         (arsize_slave_6_s),
    .arburst        (arburst_slave_6_s),
    .arlock         (arlock_slave_6_s),
    .arcache        (arcache_slave_6_s),
    .arprot         (arprot_slave_6_s),
    .arregion       (arregion_slave_6_s),
    .arvalid        (arvalid_slave_6_s),
    .arready        (arready_slave_6_s),

    .rid            (rid_slave_6_s),
    .rdata          (rdata_slave_6_s),
    .rresp          (rresp_slave_6_s),
    .rlast          (rlast_slave_6_s),
    .rvalid         (rvalid_slave_6_s),
    .rready         (rready_slave_6_s),

    .awrite         (awrite_slave_6_s),
    .aid            (aid_slave_6_s),
    .aaddr          (aaddr_slave_6_s),
    .alen           (alen_slave_6_s),
    .asize          (asize_slave_6_s),
    .aburst         (aburst_slave_6_s),
    .alock          (),
    .acache         (acache_slave_6_s),
    .aprot          (aprot_slave_6_s),
    .aregion        (aregion_slave_6_s),
    .avalid         (avalid_slave_6_s),
    .aready         (aready_slave_6_s),

    .dbnr           (dbnr_slave_6_s),
    .did            (did_slave_6_s),
    .ddata          (ddata_slave_6_s),
    .dresp          (dresp_slave_6_s),
    .dlast          (dlast_slave_6_s),
    .dvalid         (dvalid_slave_6_s),
    .dready         (dready_slave_6_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );




  assign w_master_port_src_data = {wdata_destrob,
        wstrb_slave_6_s,
        wlast_slave_6_s};

  assign {wdata_apb,
        wstrb_apb,
        wlast_apb} = w_master_port_dst_data;

  assign wvalid_apb = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_apb;

  assign w_master_port_src_valid = wvalid_slave_6_s;
  assign wready_slave_6_s = w_master_port_src_ready;




  assign a_master_port_src_data = {aid_slave_6_s,
        aaddr_slave_6_s,
        alen_slave_6_s,
        asize_slave_6_s,
        aburst_slave_6_s,
        acache_slave_6_s,
        aregion_slave_6_s,
        aprot_slave_6_s,
        awrite_slave_6_s};

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

  assign a_master_port_src_valid = avalid_slave_6_s;
  assign aready_slave_6_s = a_master_port_src_ready;



  assign d_master_port_src_data = {did_apb,
        ddata_apb,
        dresp_apb,
        dlast_apb,
        dbnr_apb};

  assign {did_slave_6_s,
        ddata_slave_6_s,
        dresp_slave_6_s,
        dlast_slave_6_s,
        dbnr_slave_6_s} = d_master_port_dst_data;

  assign dvalid_slave_6_s =  d_master_port_dst_valid;
  assign d_master_port_dst_ready = dready_slave_6_s;

  assign d_master_port_src_valid = dvalid_apb;
  assign dready_apb = d_master_port_src_ready;


  nic400_amib_slave_6_apb_m_sse710_sys_apb #(
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
    .psel_hostsysdbg_apb_i     (psel_hostsysdbg_apb),
    .psel_sdc600_apb_i     (psel_sdc600_apb),
    .pready_hostsysdbg_apb_i   (pready_hostsysdbg_apb),
    .pready_sdc600_apb_i   (pready_sdc600_apb),
    .pslverr_hostsysdbg_apb_i  (pslverr_hostsysdbg_apb),
    .pslverr_sdc600_apb_i  (pslverr_sdc600_apb),
    .prdata_hostsysdbg_apb_i   (prdata_hostsysdbg_apb),
    .prdata_sdc600_apb_i   (prdata_sdc600_apb),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_hostsysdbg_apb = penable_apb;
  assign penable_sdc600_apb = penable_apb;

  assign pwrite_hostsysdbg_apb = pwrite_apb;
  assign pwrite_sdc600_apb = pwrite_apb;

  assign paddr_hostsysdbg_apb = paddr_apb;
  assign paddr_sdc600_apb = paddr_apb;

  assign pwdata_hostsysdbg_apb = pwdata_apb;
  assign pwdata_sdc600_apb = pwdata_apb;

  assign pprot_hostsysdbg_apb = pprot_apb;
  assign pprot_sdc600_apb = pprot_apb;

  assign pstrb_hostsysdbg_apb = pstrb_apb;
  assign pstrb_sdc600_apb = pstrb_apb;





  nic400_amib_slave_6_chan_slice_sse710_sys_apb
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




  nic400_amib_slave_6_chan_slice_sse710_sys_apb
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




  nic400_amib_slave_6_chan_slice_sse710_sys_apb
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

`include "nic400_amib_slave_6_undefs_sse710_sys_apb.v"

