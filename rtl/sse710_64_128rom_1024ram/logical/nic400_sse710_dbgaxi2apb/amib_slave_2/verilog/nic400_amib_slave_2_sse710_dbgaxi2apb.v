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



`include "nic400_amib_slave_2_defs_sse710_dbgaxi2apb.v"

module nic400_amib_slave_2_sse710_dbgaxi2apb
  (
  
    paddr_extdbg_apb,
    pwdata_extdbg_apb,
    pwrite_extdbg_apb,
    pprot_extdbg_apb,
    pstrb_extdbg_apb,
    penable_extdbg_apb,
    psel_extdbg_apb,
    prdata_extdbg_apb,
    pslverr_extdbg_apb,
    pready_extdbg_apb,


    awid_slave_2_s,
    awaddr_slave_2_s,
    awlen_slave_2_s,
    awsize_slave_2_s,
    awburst_slave_2_s,
    awlock_slave_2_s,
    awcache_slave_2_s,
    awprot_slave_2_s,
    awvalid_slave_2_s,
    awready_slave_2_s,

    wdata_slave_2_s,
    wstrb_slave_2_s,
    wlast_slave_2_s,
    wvalid_slave_2_s,
    wready_slave_2_s,

    bid_slave_2_s,
    bresp_slave_2_s,
    bvalid_slave_2_s,
    bready_slave_2_s,

    arid_slave_2_s,
    araddr_slave_2_s,
    arlen_slave_2_s,
    arsize_slave_2_s,
    arburst_slave_2_s,
    arlock_slave_2_s,
    arcache_slave_2_s,
    arprot_slave_2_s,
    arvalid_slave_2_s,
    arready_slave_2_s,

    rid_slave_2_s,
    rdata_slave_2_s,
    rresp_slave_2_s,
    rlast_slave_2_s,
    rvalid_slave_2_s,
    rready_slave_2_s,

    apb_pclken,
    aclk,
    aresetn

  );




  
  output  [31:0]      paddr_extdbg_apb;  
  output  [31:0]      pwdata_extdbg_apb; 
  output              pwrite_extdbg_apb; 
  output  [2:0]       pprot_extdbg_apb;  
  output  [3:0]       pstrb_extdbg_apb;  
  output              penable_extdbg_apb;
  output              psel_extdbg_apb;   
  input   [31:0]      prdata_extdbg_apb; 
  input               pslverr_extdbg_apb;
  input               pready_extdbg_apb; 



  input   [8:0]       awid_slave_2_s;          
  input   [31:0]      awaddr_slave_2_s;        
  input   [7:0]       awlen_slave_2_s;         
  input   [2:0]       awsize_slave_2_s;        
  input   [1:0]       awburst_slave_2_s;       
  input               awlock_slave_2_s;        
  input   [3:0]       awcache_slave_2_s;       
  input   [2:0]       awprot_slave_2_s;        
  input               awvalid_slave_2_s;       
  output              awready_slave_2_s;       

  input   [31:0]      wdata_slave_2_s;         
  input   [3:0]       wstrb_slave_2_s;         
  input               wlast_slave_2_s;         
  input               wvalid_slave_2_s;        
  output              wready_slave_2_s;        

  output  [8:0]       bid_slave_2_s;           
  output  [1:0]       bresp_slave_2_s;         
  output              bvalid_slave_2_s;        
  input               bready_slave_2_s;        

  input   [8:0]       arid_slave_2_s;          
  input   [31:0]      araddr_slave_2_s;        
  input   [7:0]       arlen_slave_2_s;         
  input   [2:0]       arsize_slave_2_s;        
  input   [1:0]       arburst_slave_2_s;       
  input               arlock_slave_2_s;        
  input   [3:0]       arcache_slave_2_s;       
  input   [2:0]       arprot_slave_2_s;        
  input               arvalid_slave_2_s;       
  output              arready_slave_2_s;       

  output  [8:0]       rid_slave_2_s;           
  output  [31:0]      rdata_slave_2_s;         
  output  [1:0]       rresp_slave_2_s;         
  output              rlast_slave_2_s;         
  output              rvalid_slave_2_s;        
  input               rready_slave_2_s;        

  input               apb_pclken;              
  input               aclk;                    
  input               aresetn;                 






  wire           w_master_port_dst_valid;
  wire           w_master_port_dst_ready;
  wire           w_master_port_src_valid;
  wire           w_master_port_src_ready;

  wire [36:0]    w_master_port_src_data;     
  wire [36:0]    w_master_port_dst_data;     


  wire [31:0]    wdata_apb;
  wire [3:0]     wstrb_apb;
  wire           wlast_apb;
  wire           wvalid_apb;
  wire           wready_apb;


  wire           awrite_slave_2_s;
  wire [8:0]     aid_slave_2_s;
  wire [31:0]    aaddr_slave_2_s;
  wire [7:0]        alen_slave_2_s;
  wire [2:0]     asize_slave_2_s;
  wire [1:0]     aburst_slave_2_s;
  wire [3:0]     acache_slave_2_s;
  wire [2:0]     aprot_slave_2_s;
  wire           avalid_slave_2_s;
  wire           aready_slave_2_s;

  wire           dbnr_slave_2_s;
  wire [8:0]     did_slave_2_s;
  wire [31:0]    ddata_slave_2_s;
  wire [1:0]     dresp_slave_2_s;
  wire           dlast_slave_2_s;
  wire           dvalid_slave_2_s;
  wire           dready_slave_2_s;



  wire                            penable_apb;          
  wire                            pwrite_apb;           
  wire [31:0]                     paddr_apb;            
  wire [31:0]                     pwdata_apb;           

  wire [2:0]                      pprot_apb;            
  wire [3:0]                      pstrb_apb;            



  wire [31:0]   wdata_destrob;
  assign wdata_destrob = {
  (wdata_slave_2_s[31:24]  & {8{wstrb_slave_2_s[3]}}),
  (wdata_slave_2_s[23:16]  & {8{wstrb_slave_2_s[2]}}),
  (wdata_slave_2_s[15:8]  & {8{wstrb_slave_2_s[1]}}),
  (wdata_slave_2_s[7:0]  & {8{wstrb_slave_2_s[0]}})};
  
  nic400_amib_slave_2_axi_to_itb_sse710_dbgaxi2apb u_axi_to_itb
  (
    .awid           (awid_slave_2_s),
    .awaddr         (awaddr_slave_2_s),
    .awlen          (awlen_slave_2_s),
    .awsize         (awsize_slave_2_s),
    .awburst        (awburst_slave_2_s),
    .awlock         (awlock_slave_2_s),
    .awcache        (awcache_slave_2_s),
    .awprot         (awprot_slave_2_s),
    .awvalid        (awvalid_slave_2_s),
    .awready        (awready_slave_2_s),

    .bid            (bid_slave_2_s),
    .bresp          (bresp_slave_2_s),
    .bvalid         (bvalid_slave_2_s),
    .bready         (bready_slave_2_s),

    .arid           (arid_slave_2_s),
    .araddr         (araddr_slave_2_s),
    .arlen          (arlen_slave_2_s),
    .arsize         (arsize_slave_2_s),
    .arburst        (arburst_slave_2_s),
    .arlock         (arlock_slave_2_s),
    .arcache        (arcache_slave_2_s),
    .arprot         (arprot_slave_2_s),
    .arvalid        (arvalid_slave_2_s),
    .arready        (arready_slave_2_s),

    .rid            (rid_slave_2_s),
    .rdata          (rdata_slave_2_s),
    .rresp          (rresp_slave_2_s),
    .rlast          (rlast_slave_2_s),
    .rvalid         (rvalid_slave_2_s),
    .rready         (rready_slave_2_s),

    .awrite         (awrite_slave_2_s),
    .aid            (aid_slave_2_s),
    .aaddr          (aaddr_slave_2_s),
    .alen           (alen_slave_2_s),
    .asize          (asize_slave_2_s),
    .aburst         (aburst_slave_2_s),
    .alock          (),
    .acache         (acache_slave_2_s),
    .aprot          (aprot_slave_2_s),
    .avalid         (avalid_slave_2_s),
    .aready         (aready_slave_2_s),

    .dbnr           (dbnr_slave_2_s),
    .did            (did_slave_2_s),
    .ddata          (ddata_slave_2_s),
    .dresp          (dresp_slave_2_s),
    .dlast          (dlast_slave_2_s),
    .dvalid         (dvalid_slave_2_s),
    .dready         (dready_slave_2_s),

    .aclk           (aclk),
    .aresetn        (aresetn)
  );




  assign w_master_port_src_data = {wdata_destrob,
        wstrb_slave_2_s,
        wlast_slave_2_s};

  assign {wdata_apb,
        wstrb_apb,
        wlast_apb} = w_master_port_dst_data;

  assign wvalid_apb = w_master_port_dst_valid;
  assign w_master_port_dst_ready = wready_apb;

  assign w_master_port_src_valid = wvalid_slave_2_s;
  assign wready_slave_2_s = w_master_port_src_ready;


  nic400_amib_slave_2_apb_m_sse710_dbgaxi2apb #(
    .ID_WIDTH         (9),
    .ADDR_WIDTH       (32)
  ) u_apb_m
  (
    .aclk             (aclk),
    .aresetn          (aresetn),

    .awrite           (awrite_slave_2_s),
    .aid              (aid_slave_2_s),
    .aaddr            (aaddr_slave_2_s),
    .alen             (alen_slave_2_s),
    .asize            (asize_slave_2_s),
    .aburst           (aburst_slave_2_s),
    .aprot            (aprot_slave_2_s),

    .avalid           (avalid_slave_2_s),
    .aready           (aready_slave_2_s),

    .dbnr             (dbnr_slave_2_s),
    .did              (did_slave_2_s),
    .ddata            (ddata_slave_2_s),
    .dresp            (dresp_slave_2_s),
    .dlast            (dlast_slave_2_s),
    .dvalid           (dvalid_slave_2_s),
    .dready           (dready_slave_2_s),

    .wdata            (wdata_apb),
    .wstrb            (wstrb_apb),
    .wlast            (wlast_apb),
    .wvalid           (wvalid_apb),
    .wready           (wready_apb),

    .pclken           (apb_pclken),
    .psel_extdbg_apb_i     (psel_extdbg_apb),
    .pready_extdbg_apb_i   (pready_extdbg_apb),
    .pslverr_extdbg_apb_i  (pslverr_extdbg_apb),
    .prdata_extdbg_apb_i   (prdata_extdbg_apb),
    .penable          (penable_apb),
    .pwrite           (pwrite_apb),
    .paddr            (paddr_apb),
    .pwdata           (pwdata_apb),
    .pprot            (pprot_apb),
    .pstrb            (pstrb_apb)

  );


  assign penable_extdbg_apb = penable_apb;

  assign pwrite_extdbg_apb = pwrite_apb;

  assign paddr_extdbg_apb = paddr_apb;

  assign pwdata_extdbg_apb = pwdata_apb;

  assign pprot_extdbg_apb = pprot_apb;

  assign pstrb_extdbg_apb = pstrb_apb;





  nic400_amib_slave_2_chan_slice_sse710_dbgaxi2apb
    #(
       `RS_REV_REG,  
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

`include "nic400_amib_slave_2_undefs_sse710_dbgaxi2apb.v"

