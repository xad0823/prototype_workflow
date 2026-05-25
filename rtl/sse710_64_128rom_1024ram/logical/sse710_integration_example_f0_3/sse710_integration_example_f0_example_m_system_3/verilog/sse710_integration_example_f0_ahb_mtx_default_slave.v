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


module sse710_integration_example_f0_ahb_mtx_default_slave (

    HCLK,
    HRESETn,

    HSEL,
    HTRANS,
    HREADY,

    HREADYOUT,
    HRESP

    );



    input         HCLK;           
    input         HRESETn;        

    input         HSEL;           
    input  [1:0]  HTRANS;         
    input         HREADY;         

    output        HREADYOUT;      
    output  [1:0] HRESP;          



`define RSP_OKAY    2'b00      
`define RSP_ERROR   2'b01     
`define RSP_RETRY   2'b10     
`define RSP_SPLIT   2'b11     



    wire          HCLK;           
    wire          HRESETn;        

    wire          HSEL;           
    wire    [1:0] HTRANS;         
    wire          HREADY;         

    wire          HREADYOUT;      
    wire    [1:0] HRESP;          



    wire          invalid;    
    wire          hready_next; 
    reg           i_hreadyout; 
    wire    [1:0] hresp_next;  
    reg     [1:0] i_hresp;     



  assign invalid = ( HREADY & HSEL & HTRANS[1] );
  assign hready_next = i_hreadyout ?  ~invalid : 1'b1 ;
  assign hresp_next = invalid ? `RSP_ERROR : `RSP_OKAY;

  always @(negedge HRESETn or posedge HCLK)
    begin : p_resp_seq
      if (~HRESETn)
        begin
          i_hreadyout <= 1'b1;
          i_hresp     <= `RSP_OKAY;
        end
      else
        begin
          i_hreadyout <= hready_next;

          if (i_hreadyout)
            i_hresp <= hresp_next;
        end
    end

  assign HREADYOUT = i_hreadyout;
  assign HRESP     = i_hresp;


endmodule

