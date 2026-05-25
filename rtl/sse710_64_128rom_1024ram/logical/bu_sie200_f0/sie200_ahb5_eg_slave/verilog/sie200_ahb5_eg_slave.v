//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Dec 1 16:03:15 2016 +0000
//
//      Revision            : 6ca04ec
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_eg_slave
  (
    input  wire         hclk,
    input  wire         hresetn,

    input  wire         cfg_sec_resp,

    input  wire         hsel,
    input  wire         hnonsec,
    input  wire  [11:0] haddr,
    input  wire  [1:0]  htrans,
    input  wire  [2:0]  hsize,
    input  wire         hwrite,
    input  wire         hready,
    input  wire  [31:0] hwdata,

    output wire         hreadyout,
    output wire         hresp,
    output wire  [31:0] hrdata,

    input  wire         eg_slv_irq_enable,
    output wire         eg_slv_irq
  );



  wire  [11:0]  addr;
  wire          nonsec;
  wire          trans_req;
  wire  [11:0]  addr_reg;
  wire          read_en;
  wire          write_en;
  wire  [3:0]   byte_strobe;
  wire  [31:0]  wdata;
  wire  [31:0]  rdata;
  wire          sec_acc_err;


  sie200_ahb5_eg_slave_interface
   u_ahb5_eg_slave_interface (
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

  .addr         (addr),
  .nonsec       (nonsec),
  .trans_req    (trans_req),
  .addr_reg     (addr_reg),
  .read_en      (read_en),
  .write_en     (write_en),
  .byte_strobe  (byte_strobe),
  .wdata        (wdata),
  .rdata        (rdata),
  .sec_acc_err  (sec_acc_err)
  );

  sie200_ahb5_eg_slave_reg
   u_ahb5_eg_slave_reg (

  .hclk         (hclk),
  .hresetn      (hresetn),

  .addr         (addr),
  .nonsec       (nonsec),
  .trans_req    (trans_req),
  .addr_reg     (addr_reg),
  .read_en      (read_en),
  .write_en     (write_en),
  .byte_strobe  (byte_strobe),
  .wdata        (wdata),
  .rdata        (rdata),
  .sec_acc_err  (sec_acc_err),
  .eg_slv_irq_enable (eg_slv_irq_enable),
  .eg_slv_irq   (eg_slv_irq)
  );


endmodule

