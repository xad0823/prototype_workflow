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


module nic400_bm1_ret_sel_ml0_sse710_integration_example_f0_host_exp
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

    bid_s1,
    bresp_s1,
    bvalid_s1,
    bready_s1,  
    rid_s1,
    rdata_s1,
    rresp_s1,
    rlast_s1,
    rvalid_s1,
    rready_s1,

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
  input [17:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;
  input [17:0]       rid_m;
  input [63:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;

  output [17:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  
  output  [17:0]     rid_s0;
  output  [63:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;

  output [17:0]      bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;  
  output  [17:0]     rid_s1;
  output  [63:0]    rdata_s1;
  output [1:0]      rresp_s1;
  output            rlast_s1;
  output            rvalid_s1;
  input             rready_s1;




  wire              bvalid_masked;
  wire              bready_comb;
  wire              bready_masked0;  
  wire              rready_masked0;

  wire              bready_masked1;  
  wire              rready_masked1;
  reg [1:0]       bsel; 
  reg [1:0]       rsel; 







   always @(bid_m or bvalid_m)
   begin : p_b_ret_sel
     reg [1:0] loc_bsel; 
     reg       i_bid_m;
     loc_bsel = {2{1'b0}};
     if (bvalid_m)
     begin
        i_bid_m = bid_m[0];
        loc_bsel[i_bid_m] = 1'b1;
        bsel = loc_bsel;
     end else
     begin
        i_bid_m = {1{1'b0}};
        bsel = {2{1'b0}};
     end 
   end 

   always @(rid_m or rvalid_m)
   begin : p_r_ret_sel
     reg [1:0] loc_rsel; 
     reg       i_rid_m;
     loc_rsel = {2{1'b0}};
     if (rvalid_m)
     begin
        i_rid_m = rid_m[0];
        loc_rsel[i_rid_m] = 1'b1;
        rsel = loc_rsel;
     end else
     begin
        i_rid_m = {1{1'b0}};
        rsel = {2{1'b0}};
     end 
   end 


   assign bvalid_masked = bvalid_m & ~wr_cnt_empty;


    assign bid_s0  = bid_m & {18{bsel[0]}};
    assign bresp_s0  = bresp_m & {2{bsel[0]}};
    assign bvalid_s0  = bvalid_masked & bsel[0];

    assign bid_s1  = bid_m & {18{bsel[1]}};
    assign bresp_s1  = bresp_m & {2{bsel[1]}};
    assign bvalid_s1  = bvalid_masked & bsel[1];



    assign rid_s0 = rid_m & {18{rsel[0]}};
    assign rdata_s0 = rdata_m & {64{rsel[0]}};
    assign rresp_s0 = rresp_m & {2{rsel[0]}};
    assign rlast_s0 = rlast_m & rsel[0];
    assign rvalid_s0 = rvalid_m & rsel[0];

    assign rid_s1 = rid_m & {18{rsel[1]}};
    assign rdata_s1 = rdata_m & {64{rsel[1]}};
    assign rresp_s1 = rresp_m & {2{rsel[1]}};
    assign rlast_s1 = rlast_m & rsel[1];
    assign rvalid_s1 = rvalid_m & rsel[1];


    assign bready_masked0 = bready_s0 & bsel[0];
    assign rready_masked0 = rready_s0 & rsel[0];
    assign bready_masked1 = bready_s1 & bsel[1];
    assign rready_masked1 = rready_s1 & rsel[1];

    assign bready_comb = bready_masked0 | bready_masked1;
    assign bready_m = bready_comb & ~wr_cnt_empty;
    assign rready_m = rready_masked0 | rready_masked1;


`ifdef ARM_ASSERT_ON


assert_never #(1,0,"ERROR, RID SIID received larger than local no of slave if's")
ovl_assert_illegal_rid
   (
    .clk       (nic400_bm1_sse710_integration_example_f0_host_exp.aclk),
    .reset_n   (nic400_bm1_sse710_integration_example_f0_host_exp.aresetn),
    .test_expr (p_r_ret_sel.i_rid_m > 2));

assert_never #(1,0,"ERROR, BID SIID received larger than local no of slave if's")
ovl_assert_illegal_bid
   (
    .clk       (nic400_bm1_sse710_integration_example_f0_host_exp.aclk),
    .reset_n   (nic400_bm1_sse710_integration_example_f0_host_exp.aresetn),
    .test_expr (p_b_ret_sel.i_bid_m > 2));



`endif

endmodule


