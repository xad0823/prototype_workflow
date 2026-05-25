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


module crypto_accelerator #(

  parameter                 CAAON2CA_WIDTH     = 289, 
  parameter                 CA2CAAON_WIDTH     = 300,
  parameter                 RAM_AW              = 14

 ) (

  input  wire               CRYPTOCLKOUT,
  input  wire               CRYPTORESETn,

  output wire               HSELCAD,
  output wire        [31:0] HADDRCAD,
  output wire         [2:0] HBURSTCAD,
  output wire               HMASTLOCKCAD,
  output wire         [3:0] HPROTCAD,
  output wire         [2:0] HSIZECAD,
  output wire               HNONSECCAD,
  output wire         [1:0] HTRANSCAD,
  output wire        [31:0] HWDATACAD,
  output wire               HWRITECAD,
  output wire               HREADYCAD,
  input  wire        [31:0] HRDATACAD,
  input  wire               HREADYOUTCAD,
  input  wire               HRESPCAD,

  input  wire        [31:0] HADDRCAC,
  input  wire         [2:0] HBURSTCAC,
  input  wire               HMASTLOCKCAC, 
  input  wire         [3:0] HPROTCAC,
  input  wire         [2:0] HSIZECAC,
  input  wire         [1:0] HTRANSCAC,
  input  wire        [31:0] HWDATACAC,
  input  wire               HWRITECAC,
  output wire        [31:0] HRDATACAC,
  output wire               HREADYCAC,
  output wire               HRESPCAC,

  input  wire  [CAAON2CA_WIDTH-1:0] CAAON2CA,
  output wire  [CA2CAAON_WIDTH-1:0] CA2CAAON,

  output wire               CAINT,

  output wire               CAE,
    
  input  wire               MBISTREQ,
  input  wire               DFTCGEN,
  input  wire               DFTRAMHOLD,
  input  wire               DFTRSTDISABLE,
  input  wire               DFTSE,
  input  wire               DFTTESTMODE
);

    wire [RAM_AW-2-1:0] ramaddr;
    wire ramcs;
    wire [4-1:0] ramwen;
    wire [32-1:0] ramwdata;
    wire [32-1:0] ramrdata;

  assign HSELCAD      = 1'b0;
  assign HADDRCAD     = 32'h0000_0000;
  assign HBURSTCAD    = 3'h0;
  assign HMASTLOCKCAD = 1'b0;
  assign HPROTCAD     = 4'h0;
  assign HSIZECAD     = 3'h0;
  assign HNONSECCAD   = 1'b0;
  assign HTRANSCAD    = 2'h0;
  assign HWDATACAD    = 32'h0000_0000;
  assign HWRITECAD    = 1'b0;
  assign HREADYCAD    = HREADYOUTCAD;

  //assign HRDATACAC = 32'h0000_0000;    
  //assign HREADYCAC = 1'b1;
  //assign HRESPCAC  = 1'b0;

  assign CA2CAAON  = 300'h0;

  assign CAINT = 1'b0;
  
  assign CAE = 1'b0;

  cmsdk_ahb_to_sram #(
    .AW           (RAM_AW)
  ) u_OTP_ahb_to_sram (
    .HCLK         (CRYPTOCLKOUT),
    .HRESETn      (CRYPTORESETn),
    .HSEL         (1'b1        ),
    .HREADY       (HREADYCAC   ),
    .HTRANS       (HTRANSCAC   ),
    .HSIZE        (HSIZECAC    ),
    .HWRITE       (HWRITECAC   ),
    .HADDR        (HADDRCAC    ),
    .HWDATA       (HWDATACAC   ),
    .HREADYOUT    (HREADYCAC   ),
    .HRESP        (HRESPCAC    ),
    .HRDATA       (HRDATACAC   ),

    .SRAMRDATA    (ramrdata     ),
    .SRAMADDR     (ramaddr      ),
    .SRAMWEN      (ramwen       ),
    .SRAMWDATA    (ramwdata     ),
    .SRAMCS       (ramcs        )
  );

  secenc_f1_ram_wrapper #(
    .DATA_WIDTH   (32),
    .ADDR_WIDTH   (RAM_AW-2)
  ) u_OTP_ram_wrapper (
    .clk          (CRYPTOCLKOUT),
    .a            (ramaddr),
    .cena         (ramcs),
    .wena         (ramwen),
    .q            (ramrdata),
    .d            (ramwdata),
    .DFTRAMHOLD   (DFTRAMHOLD)
  );
  
endmodule
