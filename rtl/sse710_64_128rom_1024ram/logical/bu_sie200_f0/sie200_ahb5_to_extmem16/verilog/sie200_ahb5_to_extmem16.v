//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : Thu Nov 24 18:07:53 2016 +0100
//
//      Revision            : 71f5000
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_extmem16 #(
  parameter ADDR_WIDTH  = 16,
  parameter ENDIANNESS  = 0
)
(
  input  wire          hclk,
  input  wire          hresetn,
  input  wire          hsel,
  input  wire [ADDR_WIDTH-1:0] haddr,
  input  wire    [1:0] htrans,
  input  wire    [2:0] hsize,
  input  wire          hwrite,
  input  wire   [31:0] hwdata,
  input  wire          hready,
  output wire          hreadyout,
  output wire   [31:0] hrdata,
  output wire          hresp,

  input  wire    [2:0] cfg_read_cycle,
  input  wire    [2:0] cfg_write_cycle,
  input  wire    [2:0] cfg_turnaround_cycle,
  input  wire          cfg_size,

  input  wire   [15:0] datain,

  output wire [ADDR_WIDTH-1:0] addr,
  output wire   [15:0] dataout,
  output wire          dataout_en,

  output wire          we_n,
  output wire          oe_n,
  output wire          ce_n,
  output wire          lb_n,
  output wire          ub_n
);

  wire            rdreq;
  wire            wrreq;
  wire            done;
  wire      [1:0] nxtbytemask;

  wire      [2:0] memfsmstate;
  wire      [2:0] busfsmstate;

  sie200_ahb5_to_extmem16_ahb_fsm #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .ENDIANNESS   (ENDIANNESS))
    u_ahb_to_extmem16_ahb_fsm (
    .hclk         (hclk),
    .hresetn      (hresetn),
    .hsel         (hsel),
    .haddr        (haddr),
    .htrans       (htrans),
    .hsize        (hsize),
    .hwrite       (hwrite),
    .hready       (hready),
    .hwdata       (hwdata),

    .hreadyout    (hreadyout),
    .hrdata       (hrdata),
    .hresp        (hresp),

    .cfg_size     (cfg_size),

    .addr         (addr),
    .dataout      (dataout),
    .datain       (datain),

    .rdreq        (rdreq),
    .wrreq        (wrreq),
    .nxtbytemask  (nxtbytemask),
    .done         (done),

    .busfsmstate  (busfsmstate)
    );

  sie200_ahb5_to_extmem16_mem_fsm
    u_ahb_to_extmem16_mem_fsm (
    .hclk         (hclk),
    .hresetn      (hresetn),

    .rdreq        (rdreq),
    .wrreq        (wrreq),
    .nxtbytemask  (nxtbytemask),
    .done         (done),

    .cfg_read_cycle       (cfg_read_cycle),
    .cfg_write_cycle      (cfg_write_cycle),
    .cfg_turnaround_cycle (cfg_turnaround_cycle),

    .dataout_en   (dataout_en),
    .we_n         (we_n),
    .oe_n         (oe_n),
    .ce_n         (ce_n),
    .lb_n         (lb_n),
    .ub_n         (ub_n),

    .memfsmstate  (memfsmstate)
  );



































endmodule


