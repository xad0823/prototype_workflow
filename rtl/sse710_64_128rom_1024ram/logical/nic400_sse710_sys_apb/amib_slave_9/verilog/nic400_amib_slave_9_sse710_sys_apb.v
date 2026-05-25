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



`include "nic400_amib_slave_9_defs_sse710_sys_apb.v"

module nic400_amib_slave_9_sse710_sys_apb
  (
  
    paddr_ppu_cpu_apb,
    pwdata_ppu_cpu_apb,
    pwrite_ppu_cpu_apb,
    pprot_ppu_cpu_apb,
    pstrb_ppu_cpu_apb,
    penable_ppu_cpu_apb,
    psel_ppu_cpu_apb,
    prdata_ppu_cpu_apb,
    pslverr_ppu_cpu_apb,
    pready_ppu_cpu_apb,


    aid_slave_9_s,
    aaddr_slave_9_s,
    alen_slave_9_s,
    asize_slave_9_s,
    aburst_slave_9_s,
    alock_slave_9_s,
    acache_slave_9_s,
    aprot_slave_9_s,
    awrite_slave_9_s,
    avalid_slave_9_s,
    aready_slave_9_s,

    wdata_slave_9_s,
    wstrb_slave_9_s,
    wlast_slave_9_s,
    wvalid_slave_9_s,
    wready_slave_9_s,

    did_slave_9_s,
    ddata_slave_9_s,
    dresp_slave_9_s,
    dlast_slave_9_s,
    dbnr_slave_9_s,
    dvalid_slave_9_s,
    dready_slave_9_s,

    apb_pclken,
    aclk,
    aresetn

  );




  
  output  [31:0]      paddr_ppu_cpu_apb;  
  output  [31:0]      pwdata_ppu_cpu_apb; 
  output              pwrite_ppu_cpu_apb; 
  output  [2:0]       pprot_ppu_cpu_apb;  
  output  [3:0]       pstrb_ppu_cpu_apb;  
  output              penable_ppu_cpu_apb;
  output              psel_ppu_cpu_apb;   
  input   [31:0]      prdata_ppu_cpu_apb; 
  input               pslverr_ppu_cpu_apb;
  input               pready_ppu_cpu_apb; 



  input   [11:0]      aid_slave_9_s;            
  input   [31:0]      aaddr_slave_9_s;          
  input   [7:0]       alen_slave_9_s;           
  input   [2:0]       asize_slave_9_s;          
  input   [1:0]       aburst_slave_9_s;         
  input               alock_slave_9_s;          
  input   [3:0]       acache_slave_9_s;         
  input   [2:0]       aprot_slave_9_s;          
  input               awrite_slave_9_s;         
  input               avalid_slave_9_s;         
  output              aready_slave_9_s;         

  input   [31:0]      wdata_slave_9_s;          
  input   [3:0]       wstrb_slave_9_s;          
  input               wlast_slave_9_s;          
  input               wvalid_slave_9_s;         
  output              wready_slave_9_s;         

  output  [11:0]      did_slave_9_s;            
  output  [31:0]      ddata_slave_9_s;          
  output  [1:0]       dresp_slave_9_s;          
  output              dlast_slave_9_s;          
  output              dbnr_slave_9_s;           
  output              dvalid_slave_9_s;         
  input               dready_slave_9_s;         

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

  wire [64:0]    a_master_port_src_data;     
  wire [64:0]    a_master_port_dst_data;     



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



  wire                            penable_apb;          
  wire                            pwrite_apb;           
  wire [31:0]                     paddr_apb;            
  wire [31:0]                     pwdata_apb;           

  wire [2:0]                      pprot_apb;            
  wire [3:0]                      pstrb_apb;            



  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_slave_9_s[31:24]  & {8{wstrb_slave_9_s[3]}}),
  (wdata_slave_9_s[23:16]  & {8{wstrb_slave_9_s[2]}}),
  (wdata_slave_9_s[15:8]  & {8{wstrb_slave_9_s[1]}}),
  (wdata_slave_9_s[7:0]  & {8{wstrb_slave_9_s[0]}})};
  


  assign w_master_port_src_data = {wdata_destrob,
        wstrb_slave_9_s,
        wlast_slave_9_s};

  assign {wdata_apb,
        wstrb_apb,
        wlast_apb} = w_master_port_dst_data;

  assign wvalid_apb = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_apb;

  assign w_master_port_src_valid = wvalid_slave_9_s;
  assign wready_slave_9_s = w_master_port_src_ready;




  assign a_master_port_src_data = {aid_slave_9_s,
        aaddr_slave_9_s,
        alen_slave_9_s,
        asize_slave_9_s,
        aburst_slave_9_s,
        acache_slave_9_s,
        aprot_slave_9_s,
        awrite_slave_9_s};

  assign {aid_apb,
        aaddr_apb,
        alen_apb,
        asize_apb,
        aburst_apb,
        acache_apb,
        aprot_apb,
        awrite_apb} = a_master_port_dst_data;

  assign avalid_apb = a_master_port_dst_valid;
  assign a_master_port_dst_ready = aready_apb;

  assign a_master_port_src_valid = avalid_slave_9_s;
  assign aready_slave_9_s = a_master_port_src_ready;



  assign d_master_port_src_data = {did_apb,
        ddata_apb,
        dresp_apb,
        dlast_apb,
        dbnr_apb};

  assign {did_slave_9_s,
        ddata_slave_9_s,
        dresp_slave_9_s,
        dlast_slave_9_s,
        dbnr_slave_9_s} = d_master_port_dst_data;

  assign dvalid_slave_9_s =  d_master_port_dst_valid;
  assign d_master_port_dst_ready = dready_slave_9_s;

  assign d_master_port_src_valid = dvalid_apb;
  assign dready_apb = d_master_port_src_ready;


  nic400_amib_slave_9_apb_m_sse710_sys_apb #(
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
    .psel_ppu_cpu_apb_i     (psel_ppu_cpu_apb),
    .pready_ppu_cpu_apb_i   (pready_ppu_cpu_apb),
    .pslverr_ppu_cpu_apb_i  (pslverr_ppu_cpu_apb),
    .prdata_ppu_cpu_apb_i   (prdata_ppu_cpu_apb),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_ppu_cpu_apb = penable_apb;

  assign pwrite_ppu_cpu_apb = pwrite_apb;

  assign paddr_ppu_cpu_apb = paddr_apb;

  assign pwdata_ppu_cpu_apb = pwdata_apb;

  assign pprot_ppu_cpu_apb = pprot_apb;

  assign pstrb_ppu_cpu_apb = pstrb_apb;





  nic400_amib_slave_9_chan_slice_sse710_sys_apb
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




  nic400_amib_slave_9_chan_slice_sse710_sys_apb
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




  nic400_amib_slave_9_chan_slice_sse710_sys_apb
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

`include "nic400_amib_slave_9_undefs_sse710_sys_apb.v"

