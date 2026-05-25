//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
//  Round robin arbiter, including the priority counter register.
//-----------------------------------------------------------------------------
//
`include "cortexa53params.v"


module ca53_rr_reg_arb #(parameter WIDTH = 6) (
  input  wire                         clk,
  input  wire                         reset_n,
  input  wire                         enable_i,
  input  wire [WIDTH-1:0]             requests_i,
  output wire [WIDTH-1:0]             arb_o
);

  localparam INCR = 1;
  localparam MAX = WIDTH - 1;
  localparam COUNT_W = `CA53_LOG2(WIDTH);

  reg  [COUNT_W-1:0] rr_counter;
  wire [COUNT_W-1:0] next_rr_counter;

  assign next_rr_counter = ((rr_counter >= MAX[COUNT_W-1:0]) ? {COUNT_W{1'b0}} :
                                                               (rr_counter + INCR[COUNT_W-1:0]));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    rr_counter <= {COUNT_W{1'b0}};
  end else if (enable_i) begin
    rr_counter <= next_rr_counter;
  end

  ca53_rr_arb #(.WIDTH(WIDTH)) u_arb (
    .clk          (clk),
    .reset_n      (reset_n),
    .rr_counter_i (rr_counter),
    .requests_i   (requests_i),
    .arb_o        (arb_o)
  );

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Round robin counter must be inside the range of requests")
  u_ovl_rr_range (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (rr_counter < WIDTH)
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_i")
  u_ovl_x_enable_i (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (enable_i));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
