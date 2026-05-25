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

module xhb500_axi_to_ahb_bridge_flash_respreg_r
#(
  parameter PAYLD_WIDTH = 2
)
(
  input wire logic                    clk,
  input wire logic                    resetn,

  input wire                          ready_dst,

  input wire logic                    valid_in,
  input wire logic                    valid_in_nohready,

  input wire logic [PAYLD_WIDTH-1:0]  payld_in,

  output     logic                    valid_out,
  output     logic [PAYLD_WIDTH-1:0]  payld_out,

  output     logic                    empty,
  output     logic                    accept_ctrl_out
);

  wire logic                          rreg_valid_in;
  wire logic                          rreg_valid_out;
  wire logic [PAYLD_WIDTH-1:0]        rreg_payld_out;
  wire logic                          rreg_ready_src;

  wire logic                          ctrl_accept_always;
  wire logic                          ctrl_accept_if_nodata;

  wire logic                          unused = rreg_ready_src;


  xhb500_forward_regd_slice_empty
  #(
    .PAYLD_WIDTH        (PAYLD_WIDTH)
  )
  u_rreg
  (
  .clk                (clk),
  .resetn             (resetn),

  .valid_src          (rreg_valid_in),
  .payload_src        (payld_in),
  .ready_src          (rreg_ready_src),

  .valid_dst          (rreg_valid_out),
  .payload_dst        (rreg_payld_out),
  .ready_dst          (ready_dst),

  .empty              (empty)
  );

  assign ctrl_accept_always           = empty & ready_dst & valid_in;
  assign ctrl_accept_if_nodata        = empty | ready_dst;



  assign accept_ctrl_out = ctrl_accept_always | (ctrl_accept_if_nodata  & ~valid_in_nohready);



  assign rreg_valid_in = (~empty | ~ready_dst) & valid_in;

  assign valid_out     = empty ? valid_in : rreg_valid_out;
  assign payld_out     = empty ? payld_in : rreg_payld_out;

endmodule
