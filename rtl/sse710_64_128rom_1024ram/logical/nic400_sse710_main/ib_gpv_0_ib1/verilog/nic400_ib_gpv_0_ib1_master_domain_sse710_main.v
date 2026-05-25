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



`include "nic400_ib_gpv_0_ib1_defs_sse710_main.v"



module nic400_ib_gpv_0_ib1_master_domain_sse710_main
  (
  

    aid_itb_m,
    aaddr_itb_m,
    alen_itb_m,
    asize_itb_m,
    aburst_itb_m,
    alock_itb_m,
    acache_itb_m,
    aprot_itb_m,
    awrite_itb_m,
    avalid_itb_m,
    aready_itb_m,

    wdata_itb_m,
    wstrb_itb_m,
    wlast_itb_m,
    wvalid_itb_m,
    wready_itb_m,

    did_itb_m,
    ddata_itb_m,
    dresp_itb_m,
    dlast_itb_m,
    dbnr_itb_m,
    dvalid_itb_m,
    dready_itb_m,


    a_data,
    a_valid,
    a_ready,

    d_data,
    d_valid,
    d_ready,

    w_data,
    w_valid,
    w_ready,

    aclk,
    aresetn

  );




  


  output  [11:0]      aid_itb_m;           
  output  [39:0]      aaddr_itb_m;         
  output  [7:0]       alen_itb_m;          
  output  [2:0]       asize_itb_m;         
  output  [1:0]       aburst_itb_m;        
  output              alock_itb_m;         
  output  [3:0]       acache_itb_m;        
  output  [2:0]       aprot_itb_m;         
  output              awrite_itb_m;        
  output              avalid_itb_m;        
  input               aready_itb_m;        

  output  [31:0]      wdata_itb_m;         
  output  [3:0]       wstrb_itb_m;         
  output              wlast_itb_m;         
  output              wvalid_itb_m;        
  input               wready_itb_m;        

  input   [11:0]      did_itb_m;           
  input   [31:0]      ddata_itb_m;         
  input   [1:0]       dresp_itb_m;         
  input               dlast_itb_m;         
  input               dbnr_itb_m;          
  input               dvalid_itb_m;        
  output              dready_itb_m;        



  input   [73:0]      a_data;              
  input               a_valid;             
  output              a_ready;             

  output  [47:0]      d_data;              
  output              d_valid;             
  input               d_ready;             

  input   [36:0]      w_data;              
  input               w_valid;             
  output              w_ready;             

  input               aclk;                
  input               aresetn;             





  wire                avalid_itb_m;
  wire                aready_itb_m;

  wire                dbnr_itb_m;
  wire                dvalid_itb_m;
  wire                dlast_itb_m;
  wire [31:0]         ddata_itb_m;
  wire [1:0]          dresp_itb_m;
  wire [11:0]         did_itb_m;
  wire                dready_itb_m;






  assign {
          wdata_itb_m,
          wstrb_itb_m,
          wlast_itb_m} = w_data;

  

  assign wvalid_itb_m = w_valid;
  assign w_ready = wready_itb_m;







  assign {
          aid_itb_m,
          awrite_itb_m,
          aaddr_itb_m[39:0],
          alen_itb_m,
          asize_itb_m,
          aburst_itb_m,
          alock_itb_m,
          acache_itb_m,
          aprot_itb_m} = a_data;

  

  assign avalid_itb_m = a_valid;
  assign a_ready = aready_itb_m;





  assign d_data = {
          did_itb_m,
          dbnr_itb_m,
          ddata_itb_m,
          dresp_itb_m,
          dlast_itb_m};

  assign d_valid = dvalid_itb_m;
  assign dready_itb_m = d_ready;
















endmodule
`include "nic400_ib_gpv_0_ib1_undefs_sse710_main.v"




