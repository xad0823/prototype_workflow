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


module sse710_integration_example_f0_ahb_mtx_decoderINITCM3DI (

    HCLK,
    HRESETn,

    remapping_dec,

    HREADYS,
    sel_dec,
    decode_addr_dec,
    trans_dec,

    active_dec0,
    readyout_dec0,
    resp_dec0,
    rdata_dec0,
    ruser_dec0,

    active_dec7,
    readyout_dec7,
    resp_dec7,
    rdata_dec7,
    ruser_dec7,

    sel_dec0,
    sel_dec7,

    active_dec,
    HREADYOUTS,
    HRESPS,
    HRUSERS,
    HRDATAS

    );



    input         HCLK;           
    input         HRESETn;        

    input   [0:0] remapping_dec;      

    input         HREADYS;        
    input         sel_dec;            
    input [31:10] decode_addr_dec;     
    input   [1:0] trans_dec;          

    input         active_dec0;        
    input         readyout_dec0;      
    input   [1:0] resp_dec0;          
    input  [31:0] rdata_dec0;         
    input  [3:0] ruser_dec0;         

    input         active_dec7;        
    input         readyout_dec7;      
    input   [1:0] resp_dec7;          
    input  [31:0] rdata_dec7;         
    input  [3:0] ruser_dec7;         

    output        sel_dec0;           
    output        sel_dec7;           

    output        active_dec;         
    output        HREADYOUTS;     
    output  [1:0] HRESPS;         
    output [3:0] HRUSERS;        
    output [31:0] HRDATAS;        



    wire          HCLK;            
    wire          HRESETn;         
    wire    [0:0] remapping_dec;       

    wire          HREADYS;         
    wire          sel_dec;             
    wire  [31:10] decode_addr_dec;      
    wire    [1:0] trans_dec;           

    wire          active_dec0;         
    wire          readyout_dec0;       
    wire    [1:0] resp_dec0;           
    wire   [31:0] rdata_dec0;          
    wire   [3:0] ruser_dec0;          
    reg           sel_dec0;            

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
          1'b0 : begin
            if ((decode_addr_dec >= 22'h000000) & (decode_addr_dec <= 22'h0000ff))
               addr_out_port = 4'b0000;  
            else if ((decode_addr_dec >= 22'h000100) & (decode_addr_dec <= 22'h0001ff))
               addr_out_port = 4'b0000;  

            else if ((decode_addr_dec >= 22'h000200) & (decode_addr_dec <= 22'h07ffff))
               addr_out_port = 4'b0111;  

            else
              addr_out_port = 4'b1000;   
          end

          1'b1 : begin
            if ((decode_addr_dec >= 22'h000100) & (decode_addr_dec <= 22'h0001ff))
               addr_out_port = 4'b0111;  

            else if ((decode_addr_dec >= 22'h000000) & (decode_addr_dec <= 22'h0000ff))
               addr_out_port = 4'b0000;  
            else if ((decode_addr_dec >= 22'h000100) & (decode_addr_dec <= 22'h0001ff))
               addr_out_port = 4'b0000;  

            else if ((decode_addr_dec >= 22'h000200) & (decode_addr_dec <= 22'h07ffff))
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
      sel_dec0 = 1'b0;
      sel_dec7 = 1'b0;
      sel_dft_slv = 1'b0;

      if (sel_dec)
        case (addr_out_port)
          4'b0000 : sel_dec0 = 1'b1;
          4'b0111 : sel_dec7 = 1'b1;
          4'b1000 : sel_dft_slv = 1'b1;    
          default : begin
            sel_dec0 = 1'bx;
            sel_dec7 = 1'bx;
            sel_dft_slv = 1'bx;
          end
        endcase 
    end 

  always @ (
             active_dec0 or
             active_dec7 or
             addr_out_port
           )
    begin : p_active_comb
      case (addr_out_port)
        4'b0000 : active_dec = active_dec0;
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
             readyout_dec0 or
             readyout_dec7 or
             data_out_port
           )
  begin : p_ready_comb
    case (data_out_port)
      4'b0000 : HREADYOUTS = readyout_dec0;
      4'b0111 : HREADYOUTS = readyout_dec7;
      4'b1000 : HREADYOUTS = readyout_dft_slv;    
      default : HREADYOUTS = 1'bx;
    endcase 
  end 

  always @ (
             resp_dft_slv or
             resp_dec0 or
             resp_dec7 or
             data_out_port
           )
  begin : p_resp_comb
    case (data_out_port)
      4'b0000 : HRESPS = resp_dec0;
      4'b0111 : HRESPS = resp_dec7;
      4'b1000 : HRESPS = resp_dft_slv;     
      default : HRESPS = {2{1'bx}};
    endcase 
  end 

  always @ (
             rdata_dec0 or
             rdata_dec7 or
             data_out_port
           )
  begin : p_rdata_comb
    case (data_out_port)
      4'b0000 : HRDATAS = rdata_dec0;
      4'b0111 : HRDATAS = rdata_dec7;
      4'b1000 : HRDATAS = {32{1'b0}};   
      default : HRDATAS = {32{1'bx}};
    endcase 
  end 

  always @ (
             ruser_dec0 or
             ruser_dec7 or
             data_out_port
           )
  begin : p_ruser_comb
    case (data_out_port)
      4'b0000 : HRUSERS = ruser_dec0;
      4'b0111 : HRUSERS = ruser_dec7;
      4'b1000 : HRUSERS = {4{1'b0}};   
      default : HRUSERS = {4{1'bx}};
    endcase 
  end 


endmodule

