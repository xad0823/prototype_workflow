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


`timescale 1ns/1ps


module sse710_integration_example_f0_ahb_mtx_decoderINITCM3S (

    HCLK,
    HRESETn,

    remapping_dec,

    HREADYS,
    sel_dec,
    decode_addr_dec,
    trans_dec,

    active_dec1,
    readyout_dec1,
    resp_dec1,
    rdata_dec1,
    ruser_dec1,

    active_dec2,
    readyout_dec2,
    resp_dec2,
    rdata_dec2,
    ruser_dec2,

    active_dec3,
    readyout_dec3,
    resp_dec3,
    rdata_dec3,
    ruser_dec3,

    active_dec4,
    readyout_dec4,
    resp_dec4,
    rdata_dec4,
    ruser_dec4,

    active_dec5,
    readyout_dec5,
    resp_dec5,
    rdata_dec5,
    ruser_dec5,

    active_dec6,
    readyout_dec6,
    resp_dec6,
    rdata_dec6,
    ruser_dec6,

    active_dec7,
    readyout_dec7,
    resp_dec7,
    rdata_dec7,
    ruser_dec7,

    sel_dec1,
    sel_dec2,
    sel_dec3,
    sel_dec4,
    sel_dec5,
    sel_dec6,
    sel_dec7,

    active_dec,
    HREADYOUTS,
    HRESPS,
    HRUSERS,
    HRDATAS

    );



    input         HCLK;           
    input         HRESETn;        

    input   [2:0] remapping_dec;      

    input         HREADYS;        
    input         sel_dec;            
    input [31:10] decode_addr_dec;     
    input   [1:0] trans_dec;          

    input         active_dec1;        
    input         readyout_dec1;      
    input   [1:0] resp_dec1;          
    input  [31:0] rdata_dec1;         
    input  [3:0] ruser_dec1;         

    input         active_dec2;        
    input         readyout_dec2;      
    input   [1:0] resp_dec2;          
    input  [31:0] rdata_dec2;         
    input  [3:0] ruser_dec2;         

    input         active_dec3;        
    input         readyout_dec3;      
    input   [1:0] resp_dec3;          
    input  [31:0] rdata_dec3;         
    input  [3:0] ruser_dec3;         

    input         active_dec4;        
    input         readyout_dec4;      
    input   [1:0] resp_dec4;          
    input  [31:0] rdata_dec4;         
    input  [3:0] ruser_dec4;         

    input         active_dec5;        
    input         readyout_dec5;      
    input   [1:0] resp_dec5;          
    input  [31:0] rdata_dec5;         
    input  [3:0] ruser_dec5;         

    input         active_dec6;        
    input         readyout_dec6;      
    input   [1:0] resp_dec6;          
    input  [31:0] rdata_dec6;         
    input  [3:0] ruser_dec6;         

    input         active_dec7;        
    input         readyout_dec7;      
    input   [1:0] resp_dec7;          
    input  [31:0] rdata_dec7;         
    input  [3:0] ruser_dec7;         

    output        sel_dec1;           
    output        sel_dec2;           
    output        sel_dec3;           
    output        sel_dec4;           
    output        sel_dec5;           
    output        sel_dec6;           
    output        sel_dec7;           

    output        active_dec;         
    output        HREADYOUTS;     
    output  [1:0] HRESPS;         
    output [3:0] HRUSERS;        
    output [31:0] HRDATAS;        



    wire          HCLK;            
    wire          HRESETn;         
    wire    [2:0] remapping_dec;       

    wire          HREADYS;         
    wire          sel_dec;             
    wire  [31:10] decode_addr_dec;      
    wire    [1:0] trans_dec;           

    wire          active_dec1;         
    wire          readyout_dec1;       
    wire    [1:0] resp_dec1;           
    wire   [31:0] rdata_dec1;          
    wire   [3:0] ruser_dec1;          
    reg           sel_dec1;            

    wire          active_dec2;         
    wire          readyout_dec2;       
    wire    [1:0] resp_dec2;           
    wire   [31:0] rdata_dec2;          
    wire   [3:0] ruser_dec2;          
    reg           sel_dec2;            

    wire          active_dec3;         
    wire          readyout_dec3;       
    wire    [1:0] resp_dec3;           
    wire   [31:0] rdata_dec3;          
    wire   [3:0] ruser_dec3;          
    reg           sel_dec3;            

    wire          active_dec4;         
    wire          readyout_dec4;       
    wire    [1:0] resp_dec4;           
    wire   [31:0] rdata_dec4;          
    wire   [3:0] ruser_dec4;          
    reg           sel_dec4;            

    wire          active_dec5;         
    wire          readyout_dec5;       
    wire    [1:0] resp_dec5;           
    wire   [31:0] rdata_dec5;          
    wire   [3:0] ruser_dec5;          
    reg           sel_dec5;            

    wire          active_dec6;         
    wire          readyout_dec6;       
    wire    [1:0] resp_dec6;           
    wire   [31:0] rdata_dec6;          
    wire   [3:0] ruser_dec6;          
    reg           sel_dec6;            

    wire          active_dec7;         
    wire          readyout_dec7;       
    wire    [1:0] resp_dec7;           
    wire   [31:0] rdata_dec7;          
    wire   [3:0] ruser_dec7;          
    reg           sel_dec7;            



    reg           active_dec;          
    reg           HREADYOUTS;      
    reg     [1:0] HRESPS;          
    reg    [3:0] HRUSERS;
    reg    [31:0] HRDATAS;         

    reg     [3:0] addr_out_port;     
    reg     [3:0] data_out_port;     

    reg           sel_dft_slv;       
    wire          readyout_dft_slv;  
    wire    [1:0] resp_dft_slv;      




  sse710_integration_example_f0_ahb_mtx_default_slave u_sse710_integration_example_f0_ahb_mtx_default_slave (

    .HCLK        (HCLK),
    .HRESETn     (HRESETn),

    .HSEL        (sel_dft_slv),
    .HTRANS      (trans_dec),
    .HREADY      (HREADYS),
    .HREADYOUT   (readyout_dft_slv),
    .HRESP       (resp_dft_slv)

    );




  always @ (
             decode_addr_dec or
             remapping_dec or data_out_port or trans_dec
           )
    begin : p_addr_out_port_comb

      if (trans_dec != 2'b00)
      begin

        case (remapping_dec)  
          3'b000 : begin
            if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b001 : begin
            if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b010 : begin
            if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b011 : begin
            if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b100 : begin
            if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b101 : begin
            if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b110 : begin
            if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          3'b111 : begin
            if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h08001f))
               addr_out_port = 4'b0001;  

            else if ((decode_addr_dec >= 22'h080020) & (decode_addr_dec <= 22'h08003f))
               addr_out_port = 4'b0010;  

            else if ((decode_addr_dec >= 22'h080040) & (decode_addr_dec <= 22'h08005f))
               addr_out_port = 4'b0011;  

            else if ((decode_addr_dec >= 22'h080060) & (decode_addr_dec <= 22'h08007f))
               addr_out_port = 4'b0100;  

            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h10003f))
               addr_out_port = 4'b0101;  

            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h28003f))
               addr_out_port = 4'b0110;  

            else if ((decode_addr_dec >= 22'h080080) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h100040) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h280040) & (decode_addr_dec <= 22'h2fffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h300000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0111;  
            else if ((decode_addr_dec >= 22'h380400) & (decode_addr_dec <= 22'h3fffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          default : addr_out_port = {4{1'bx}};
        endcase

      end 
      else
        addr_out_port = data_out_port;   

    end 

  always @ (sel_dec or addr_out_port)
    begin : p_sel_comb
      sel_dec1 = 1'b0;
      sel_dec2 = 1'b0;
      sel_dec3 = 1'b0;
      sel_dec4 = 1'b0;
      sel_dec5 = 1'b0;
      sel_dec6 = 1'b0;
      sel_dec7 = 1'b0;
      sel_dft_slv = 1'b0;

      if (sel_dec)
        case (addr_out_port)
          4'b0001 : sel_dec1 = 1'b1;
          4'b0010 : sel_dec2 = 1'b1;
          4'b0011 : sel_dec3 = 1'b1;
          4'b0100 : sel_dec4 = 1'b1;
          4'b0101 : sel_dec5 = 1'b1;
          4'b0110 : sel_dec6 = 1'b1;
          4'b0111 : sel_dec7 = 1'b1;
          4'b1000 : sel_dft_slv = 1'b1;    
          default : begin
            sel_dec1 = 1'bx;
            sel_dec2 = 1'bx;
            sel_dec3 = 1'bx;
            sel_dec4 = 1'bx;
            sel_dec5 = 1'bx;
            sel_dec6 = 1'bx;
            sel_dec7 = 1'bx;
            sel_dft_slv = 1'bx;
          end
        endcase 
    end 

  always @ (
             active_dec1 or
             active_dec2 or
             active_dec3 or
             active_dec4 or
             active_dec5 or
             active_dec6 or
             active_dec7 or
             addr_out_port
           )
    begin : p_active_comb
      case (addr_out_port)
        4'b0001 : active_dec = active_dec1;
        4'b0010 : active_dec = active_dec2;
        4'b0011 : active_dec = active_dec3;
        4'b0100 : active_dec = active_dec4;
        4'b0101 : active_dec = active_dec5;
        4'b0110 : active_dec = active_dec6;
        4'b0111 : active_dec = active_dec7;
        4'b1000 : active_dec = 1'b1;         
        default : active_dec = 1'bx;
      endcase 
    end 




  always @ (negedge HRESETn or posedge HCLK)
    begin : p_data_out_port_seq
      if (~HRESETn)
        data_out_port <= 4'b1000;
      else
        if (HREADYS)
          if (sel_dec & trans_dec[1])
            data_out_port <= addr_out_port;
          else
            data_out_port <= 4'b1000;
    end 

  always @ (
             readyout_dft_slv or
             readyout_dec1 or
             readyout_dec2 or
             readyout_dec3 or
             readyout_dec4 or
             readyout_dec5 or
             readyout_dec6 or
             readyout_dec7 or
             data_out_port
           )
  begin : p_ready_comb
    case (data_out_port)
      4'b0001 : HREADYOUTS = readyout_dec1;
      4'b0010 : HREADYOUTS = readyout_dec2;
      4'b0011 : HREADYOUTS = readyout_dec3;
      4'b0100 : HREADYOUTS = readyout_dec4;
      4'b0101 : HREADYOUTS = readyout_dec5;
      4'b0110 : HREADYOUTS = readyout_dec6;
      4'b0111 : HREADYOUTS = readyout_dec7;
      4'b1000 : HREADYOUTS = readyout_dft_slv;    
      default : HREADYOUTS = 1'bx;
    endcase 
  end 

  always @ (
             resp_dft_slv or
             resp_dec1 or
             resp_dec2 or
             resp_dec3 or
             resp_dec4 or
             resp_dec5 or
             resp_dec6 or
             resp_dec7 or
             data_out_port
           )
  begin : p_resp_comb
    case (data_out_port)
      4'b0001 : HRESPS = resp_dec1;
      4'b0010 : HRESPS = resp_dec2;
      4'b0011 : HRESPS = resp_dec3;
      4'b0100 : HRESPS = resp_dec4;
      4'b0101 : HRESPS = resp_dec5;
      4'b0110 : HRESPS = resp_dec6;
      4'b0111 : HRESPS = resp_dec7;
      4'b1000 : HRESPS = resp_dft_slv;     
      default : HRESPS = {2{1'bx}};
    endcase 
  end 

  always @ (
             rdata_dec1 or
             rdata_dec2 or
             rdata_dec3 or
             rdata_dec4 or
             rdata_dec5 or
             rdata_dec6 or
             rdata_dec7 or
             data_out_port
           )
  begin : p_rdata_comb
    case (data_out_port)
      4'b0001 : HRDATAS = rdata_dec1;
      4'b0010 : HRDATAS = rdata_dec2;
      4'b0011 : HRDATAS = rdata_dec3;
      4'b0100 : HRDATAS = rdata_dec4;
      4'b0101 : HRDATAS = rdata_dec5;
      4'b0110 : HRDATAS = rdata_dec6;
      4'b0111 : HRDATAS = rdata_dec7;
      4'b1000 : HRDATAS = {32{1'b0}};   
      default : HRDATAS = {32{1'bx}};
    endcase 
  end 

  always @ (
             ruser_dec1 or
             ruser_dec2 or
             ruser_dec3 or
             ruser_dec4 or
             ruser_dec5 or
             ruser_dec6 or
             ruser_dec7 or
             data_out_port
           )
  begin : p_ruser_comb
    case (data_out_port)
      4'b0001 : HRUSERS = ruser_dec1;
      4'b0010 : HRUSERS = ruser_dec2;
      4'b0011 : HRUSERS = ruser_dec3;
      4'b0100 : HRUSERS = ruser_dec4;
      4'b0101 : HRUSERS = ruser_dec5;
      4'b0110 : HRUSERS = ruser_dec6;
      4'b0111 : HRUSERS = ruser_dec7;
      4'b1000 : HRUSERS = {4{1'b0}};   
      default : HRUSERS = {4{1'bx}};
    endcase 
  end 


endmodule

