//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Mon Oct 10 16:05:00 2016 +0100
//
//      Revision            : 49a7242
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_gpio #(
  parameter  ALTERNATE_FUNC_MASK     = 16'hFFFF,

  parameter  ALTERNATE_FUNC_DEFAULT  = 16'h0000,

  parameter  PORT_NONSEC_MASK        = 16'h0000,


  parameter  ENDIANNESS              = 0)
  (
    input  wire                   hclk,
    input  wire                   fclk,
    input  wire                   hresetn,

    input  wire                   hsel,
    input  wire                   hnonsec,
    input  wire  [11:0]           haddr,
    input  wire  [1:0]            htrans,
    input  wire  [2:0]            hsize,
    input  wire                   hwrite,
    input  wire                   hready,
    input  wire  [31:0]           hwdata,

    output wire  [31:0]           hrdata,
    output wire                   hreadyout,
    output wire                   hresp,

    input  wire  [15:0]           port_in,
    output wire  [15:0]           port_out,
    output wire  [15:0]           port_en,
    output wire  [15:0]           port_func,

    output wire  [15:0]           gpio_sec_irq,
    output wire  [15:0]           gpio_nonsec_irq,
    output wire                   comb_sec_irq,
    output wire                   comb_nonsec_irq,
    output wire                   sec_acc_irq,
    input  wire                   sec_acc_irq_enable,

    input  wire                   cfg_sec_resp

  );


  localparam ADDR_WIDTH = 12;


  wire  [ADDR_WIDTH-1:0]  int_addr;
  wire                    int_nonsec;
  wire                    int_trans_req;
  wire  [ADDR_WIDTH-1:0]  int_addr_reg;
  wire                    int_read_en;
  wire                    int_write_en;
  wire  [3:0]             int_byte_strobe;
  wire  [31:0]            int_wdata;
  wire  [31:0]            int_rdata;
  wire                    int_sec_acc_err;


  sie200_ahb5_gpio_if #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .ENDIANNESS   (ENDIANNESS))
  u_ahb5_gpio_if (
    .hclk         (hclk),
    .hresetn      (hresetn),

    .cfg_sec_resp (cfg_sec_resp),

    .hsel         (hsel),
    .hnonsec      (hnonsec),
    .haddr        (haddr),
    .htrans       (htrans),
    .hsize        (hsize),
    .hwrite       (hwrite),
    .hready       (hready),
    .hwdata       (hwdata),

    .hreadyout    (hreadyout),
    .hresp        (hresp),
    .hrdata       (hrdata),

    .addr         (int_addr),
    .nonsec       (int_nonsec),
    .trans_req    (int_trans_req),
    .sec_acc_err  (int_sec_acc_err),

    .addr_reg     (int_addr_reg),
    .read_en      (int_read_en),
    .write_en     (int_write_en),
    .byte_strobe  (int_byte_strobe),
    .wdata        (int_wdata),
    .rdata        (int_rdata)
  );

  sie200_ahb5_gpio_reg #(
    .ALTERNATE_FUNC_MASK    (ALTERNATE_FUNC_MASK),
    .ALTERNATE_FUNC_DEFAULT (ALTERNATE_FUNC_DEFAULT),
    .PORT_NONSEC_MASK       (PORT_NONSEC_MASK)
  )
  u_ahb5_gpio_reg (
    .hclk               (hclk),
    .fclk               (fclk),
    .hresetn            (hresetn),

    .addr               (int_addr),
    .nonsec             (int_nonsec),
    .trans_req          (int_trans_req),
    .sec_acc_err        (int_sec_acc_err),

    .addr_reg           (int_addr_reg),
    .read_en            (int_read_en),
    .write_en           (int_write_en),
    .byte_strobe        (int_byte_strobe),
    .wdata              (int_wdata),
    .rdata              (int_rdata),

    .port_in            (port_in),
    .port_out           (port_out),
    .port_en            (port_en),
    .port_func          (port_func),

    .gpio_sec_irq       (gpio_sec_irq),
    .gpio_nonsec_irq    (gpio_nonsec_irq),
    .comb_sec_irq       (comb_sec_irq),
    .comb_nonsec_irq    (comb_nonsec_irq),
    .sec_acc_irq        (sec_acc_irq),
    .sec_acc_irq_enable (sec_acc_irq_enable)
  );


endmodule
