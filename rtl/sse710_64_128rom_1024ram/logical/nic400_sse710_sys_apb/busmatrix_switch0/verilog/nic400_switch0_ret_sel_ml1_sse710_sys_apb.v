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


module nic400_switch0_ret_sel_ml1_sse710_sys_apb
  (
    wr_cnt_empty,

    bid_s0,
    bresp_s0,
    bvalid_s0,
    bready_s0,  
    rid_s0,
    rdata_s0,
    rresp_s0,
    rlast_s0,
    rvalid_s0,
    rready_s0,

    bid_m,
    bresp_m,
    bvalid_m,
    bready_m,
    rid_m,
    rdata_m,
    rresp_m,
    rlast_m,
    rvalid_m,
    rready_m
 );



  input             wr_cnt_empty;
  input [11:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;
  input [11:0]       rid_m;
  input [31:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;

  output [11:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  
  output  [11:0]     rid_s0;
  output  [31:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;




  wire              bvalid_masked;
  wire              bready_comb;
  wire              bready_masked0;  
  wire              rready_masked0;
  wire            bsel; 
  wire            rsel; 







        assign bsel = 1'b1;

        assign rsel = 1'b1;


   assign bvalid_masked = bvalid_m & ~wr_cnt_empty;


    assign bid_s0  = bid_m & {12{bsel}};
    assign bresp_s0  = bresp_m & {2{bsel}};
    assign bvalid_s0  = bvalid_masked & bsel;



    assign rid_s0 = rid_m & {12{rsel}};
    assign rdata_s0 = rdata_m & {32{rsel}};
    assign rresp_s0 = rresp_m & {2{rsel}};
    assign rlast_s0 = rlast_m & rsel;
    assign rvalid_s0 = rvalid_m & rsel;


    assign bready_masked0 = bready_s0 & bsel;
    assign rready_masked0 = rready_s0 & rsel;

    assign bready_comb = bready_masked0;
    assign bready_m = bready_comb & ~wr_cnt_empty;
    assign rready_m = rready_masked0;


`ifdef ARM_ASSERT_ON



`endif

endmodule


