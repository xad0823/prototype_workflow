//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_axi_to_ahb_bridge_flash_hreg
(


  input wire logic                                       clk,
  input wire logic                                       resetn,

  input wire logic                                       tr_en,
  input wire logic                                       h_en,
  input wire logic                                       w_en,

  input wire logic                                       hready_in,
  input wire logic     [1:0]                             htrans_in,
  output     logic                                       hready_out,
  output     logic     [1:0]                             htrans_out,

  input wire xhb500_axi_to_ahb_bridge_flash_pkg::ahb_mpayld_t        ahb_in,

  output     xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trq_t         ahb_tr_q,

  output     xhb500_axi_to_ahb_bridge_flash_pkg::ahb_mpayld_t        ahb_out,

  output     logic                                       empty
);

  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trfix_t   hreg_trfix;

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      ahb_tr_q      <= '0;
    end
    else if(tr_en) begin
      ahb_tr_q      <= ahb_in.trfix.trfixq;
    end
  end

  localparam HPAYLD_WIDTH = $bits(htrans_in) + $bits(ahb_in.hfix);

  xhb500_bypass_regd_slice_empty
  #(
    .PAYLD_WIDTH      (HPAYLD_WIDTH)
  )
  u_hreg_h
  (

    .valid_src          (h_en),
    .payload_src        ({ htrans_in,  ahb_in.hfix}),
    .ready_src          (hready_out),

    .valid_dst          (),
    .payload_dst        ({htrans_out, ahb_out.hfix}),
    .ready_dst          (hready_in),

    .empty              ()
  );

  wire logic tr_ready;
  wire logic tr_ack = hready_in;

  xhb500_bypass_regd_slice_empty
  #(
    .PAYLD_WIDTH        ($bits(ahb_in.trfix))
  )
  u_hreg_tr
  (

    .valid_src          (tr_en),
    .payload_src        ( ahb_in.trfix),
    .ready_src          (tr_ready),

    .valid_dst          (),
    .payload_dst        (hreg_trfix),
    .ready_dst          (tr_ack),

    .empty              (empty)
  );

  assign ahb_out.trfix  = hreg_trfix;

  wire logic unused = tr_ready;




  wire logic wr_en  = w_en;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_wdata_t  hreg_wr_in = ahb_in.wdata;

  wire logic wr_ack = 1'b1;

  xhb500_forward_regd_slice
  #(
    .PAYLD_WIDTH        ($bits(ahb_in.wdata))
  )
  
  u_hreg_w
  (
    .clk                (clk),
    .resetn             (resetn),

    .valid_src          (wr_en),
    .payload_src        (hreg_wr_in),
    .ready_src          (),           

    .valid_dst          (),
    .payload_dst        (ahb_out.wdata),
    .ready_dst          (wr_ack)
  );


endmodule


