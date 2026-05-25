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


`include "nic400_ib_gpvmain_ahb_ib_defs_sse710_main.v"


module nic400_ib_gpvmain_ahb_ib_slave_domain_sse710_main
  (
  

    aaddr_itb_s,
    alen_itb_s,
    asize_itb_s,
    aburst_itb_s,
    alock_itb_s,
    acache_itb_s,
    aprot_itb_s,
    awrite_itb_s,
    avalid_itb_s,
    avalid_vect_itb_s,
    aready_itb_s,

    wdata_itb_s,
    wstrb_itb_s,
    wlast_itb_s,
    wvalid_itb_s,
    wready_itb_s,

    ddata_itb_s,
    dresp_itb_s,
    dlast_itb_s,
    dbnr_itb_s,
    dvalid_itb_s,
    dready_itb_s,


    a_data,
    a_valid,
    a_ready,

    d_data,
    d_valid,
    d_ready,

    w_data,
    w_valid,
    w_ready,
    empty,

    aclk_s,
    aresetn_s

  );



  


  input   [31:0]      aaddr_itb_s;                        
  input   [3:0]       alen_itb_s;                         
  input   [2:0]       asize_itb_s;                        
  input   [1:0]       aburst_itb_s;                       
  input   [1:0]       alock_itb_s;                        
  input   [3:0]       acache_itb_s;                       
  input   [2:0]       aprot_itb_s;                        
  input               awrite_itb_s;                       
  input               avalid_itb_s;                       
  input   [1:0]       avalid_vect_itb_s;                  
  output              aready_itb_s;                       

  input   [31:0]      wdata_itb_s;                        
  input   [3:0]       wstrb_itb_s;                        
  input               wlast_itb_s;                        
  input               wvalid_itb_s;                       
  output              wready_itb_s;                       

  output  [31:0]      ddata_itb_s;                        
  output  [1:0]       dresp_itb_s;                        
  output              dlast_itb_s;                        
  output              dbnr_itb_s;                         
  output              dvalid_itb_s;                       
  input               dready_itb_s;                       



  output  [51:0]      a_data;                             
  output              a_valid;                            
  input               a_ready;                            

  input   [35:0]      d_data;                             
  input               d_valid;                            
  output              d_ready;                            

  output  [36:0]      w_data;                             
  output              w_valid;                            
  input               w_ready;                            
  output              empty;                              

  input               aclk_s;                             
  input               aresetn_s;                          
   


  wire                empty_boundary;

  reg                 empty;
  wire                empty_cmb;
  wire                w_valid;
  wire                a_valid;  
 









  assign w_data = {
          wdata_itb_s,
          wstrb_itb_s,
          wlast_itb_s};


  assign w_valid = wvalid_itb_s;

  assign wready_itb_s = w_ready;


  assign a_data = {
          awrite_itb_s,
          aaddr_itb_s[31:0],
          alen_itb_s,
          asize_itb_s,
          aburst_itb_s,
          alock_itb_s[0],
          acache_itb_s,
          aprot_itb_s,
          avalid_vect_itb_s};


  assign a_valid = avalid_itb_s;

  assign aready_itb_s = a_ready;


  assign empty_boundary = 1'b1 & ~w_valid & ~a_valid;


  assign empty_cmb = ~(empty_boundary);


  always @(posedge aclk_s or negedge aresetn_s)
   begin
        if (!aresetn_s)
         begin
          empty   <= 1'b0;
         end
        else
         begin
           empty  <= empty_cmb;
         end
   end

  


  assign {
          dbnr_itb_s,
          ddata_itb_s,
          dresp_itb_s,
          dlast_itb_s} = d_data;

  assign d_ready = dready_itb_s;
  assign dvalid_itb_s = d_valid;



    
    
    
    


endmodule

`include "nic400_ib_gpvmain_ahb_ib_undefs_sse710_main.v"




