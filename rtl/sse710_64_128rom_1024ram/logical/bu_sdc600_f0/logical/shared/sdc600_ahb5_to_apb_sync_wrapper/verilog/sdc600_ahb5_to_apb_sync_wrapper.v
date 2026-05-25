//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Feb 19 12:27:52 2018 +0000
//
//      Revision            : bdc4508
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_ahb5_to_apb_sync_wrapper (
  input  wire        hclk,
  input  wire        hresetn,
  input  wire        hsel,
  input  wire [11:0] haddr,
  input  wire [ 1:0] htrans,
  input  wire [ 2:0] hsize,
  input  wire        hwrite,
  input  wire        hready,
  input  wire [31:0] hwdata,
  output wire        hreadyout,
  output wire [31:0] hrdata,
  output wire        hresp,
  output wire [11:0] paddr,
  output wire        penable,
  output wire        pwrite,
  output wire [31:0] pwdata,
  output wire        psel,
  input  wire [31:0] prdata,
  input  wire        pready,
  input  wire        pslverr
);

assign      paddr     = haddr;
assign      pwrite    = hwrite;

wire        tie_low   = 1'b0;
wire        tie_high  = 1'b1;
wire  [2:0] unused    = hsize;

sdc600_ahb5_to_apb_ll_sync #(
  .ADDR_WIDTH     (12),
  .MASTER_WIDTH   ( 1),
  .REGISTER_RDATA ( 0),
  .REGISTER_WDATA ( 0),
  .REGISTER_CNTRL ( 0)
) u_sdc600_ahb_to_apb_ll_sync (

  .hclk       (hclk),
  .hresetn    (hresetn),
  .pclk_en    (1'b1),
  .apb_active (),
  .hsel       (hsel),
  .hnonsec    (tie_low),
  .haddr      ({12{tie_low}}),
  .htrans     (htrans),
  .hsize      ({tie_low,tie_high,tie_low}),
  .hwrite     (hwrite),
  .hready     (hready),
  .hprot      ({7{tie_low}}),
  .hwdata     (hwdata),
  .hmaster    (tie_low),
  .hrdata     (hrdata),
  .hreadyout  (hreadyout),
  .hresp      (hresp),
  .psel       (psel),
  .penable    (penable),
  .paddr      (),
  .pwrite     (),
  .pstrb      (),
  .pprot      (),
  .pwdata     (pwdata),
  .pmaster    (),
  .prdata     (prdata),
  .pready     (pready),
  .pslverr    (pslverr)
);

 endmodule
