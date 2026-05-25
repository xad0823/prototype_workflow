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

`define RESP_OKAY 2'b00

module sse710_integration_example_f0_ahb_code_mux (
  HCLK, HRESETn,
  HADDRI, HTRANSI, HSIZEI, HBURSTI, HPROTI,
  HADDRD, HTRANSD, HSIZED, HBURSTD, HPROTD, HWDATAD, HWRITED, EXREQD,
  HRDATAC, HREADYC, HRESPC, EXRESPC,
  HRDATAI, HREADYI, HRESPI, HRDATAD, HREADYD, HRESPD, EXRESPD,
  HADDRC, HWDATAC, HTRANSC, HWRITEC, HSIZEC, HBURSTC, HPROTC, EXREQC
  );

  input         HCLK;             
  input         HRESETn;          

  input [31:0]  HADDRI;           
  input  [1:0]  HTRANSI;          
  input  [2:0]  HSIZEI;           
  input  [2:0]  HBURSTI;          
  input  [3:0]  HPROTI;           
  input [31:0]  HADDRD;           
  input  [1:0]  HTRANSD;          
  input  [2:0]  HSIZED;           
  input  [2:0]  HBURSTD;          
  input  [3:0]  HPROTD;           
  input [31:0]  HWDATAD;          
  input         HWRITED;          
  input         EXREQD;           

  input [31:0]  HRDATAC;          
  input         HREADYC;          
  input  [1:0]  HRESPC;           
  input         EXRESPC;          

  output [31:0] HRDATAI;          
  output        HREADYI;          
  output  [1:0] HRESPI;           
  output [31:0] HRDATAD;          
  output        HREADYD;          
  output  [1:0] HRESPD;           
  output        EXRESPD;          

  output [31:0] HADDRC;           
  output [31:0] HWDATAC;          
  output  [1:0] HTRANSC;          
  output        HWRITEC;          
  output  [2:0] HSIZEC;           
  output  [2:0] HBURSTC;          
  output  [3:0] HPROTC;           
  output        EXREQC;           


  wire          d_trans_active;     
  reg           d_trans_active_reg; 


  assign d_trans_active = HTRANSD[1];

  assign HADDRC  = d_trans_active ? HADDRD  : HADDRI;
  assign HTRANSC = d_trans_active ? HTRANSD : HTRANSI;
  assign HWRITEC = d_trans_active ? HWRITED : 1'b0;
  assign HSIZEC  = d_trans_active ? HSIZED  : HSIZEI;
  assign HBURSTC = d_trans_active ? HBURSTD : HBURSTI;
  assign HPROTC  = d_trans_active ? HPROTD  : HPROTI;

  assign HRDATAI = HRDATAC;
  assign HRDATAD = HRDATAC;
  assign HWDATAC = HWDATAD;

  assign HREADYI = HREADYC;
  assign HREADYD = HREADYC;

  assign HRESPI  = d_trans_active_reg ? `RESP_OKAY : HRESPC;
  assign HRESPD  = d_trans_active_reg ? HRESPC     : `RESP_OKAY;

  assign EXREQC  = EXREQD;
  assign EXRESPD = d_trans_active_reg & EXRESPC;

  always @ (posedge HCLK or negedge HRESETn)
    begin
      if (!HRESETn)
        d_trans_active_reg <= 1'b0;
      else if (HREADYC)
        d_trans_active_reg <= d_trans_active;
    end



endmodule

