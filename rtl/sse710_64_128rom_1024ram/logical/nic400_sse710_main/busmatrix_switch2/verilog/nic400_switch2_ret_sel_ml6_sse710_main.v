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


module nic400_switch2_ret_sel_ml6_sse710_main
  (
    wr_cnt_empty,

    buser_s0,
    bid_s0,
    bresp_s0,
    bvalid_s0,
    bready_s0,  
    ruser_s0,
    rid_s0,
    rdata_s0,
    rresp_s0,
    rlast_s0,
    rvalid_s0,
    rready_s0,

    buser_s1,
    bid_s1,
    bresp_s1,
    bvalid_s1,
    bready_s1,  
    ruser_s1,
    rid_s1,
    rdata_s1,
    rresp_s1,
    rlast_s1,
    rvalid_s1,
    rready_s1,

    buser_m,
    bid_m,
    bresp_m,
    bvalid_m,
    bready_m,
    ruser_m,
    rid_m,
    rdata_m,
    rresp_m,
    rlast_m,
    rvalid_m,
    rready_m
 );



  input             wr_cnt_empty;
  input           buser_m;
  input [11:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;
  input             ruser_m;
  input [11:0]       rid_m;
  input [63:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;

  output            buser_s0;
  output [11:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  
  output            ruser_s0;
  output  [11:0]     rid_s0;
  output  [63:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;

  output            buser_s1;
  output [11:0]      bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;  
  output            ruser_s1;
  output  [11:0]     rid_s1;
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
  reg [2:0]       iid_bsel;
  reg [2:0]       iid_rsel;






   always @(bid_m or bvalid_m)
   begin : p_b_ret_sel
     reg [1:0] loc_bsel; 
     loc_bsel = {2{1'b0}}; 
     if (bvalid_m)
     begin
        case(bid_m[2:0])
           3'b000 : loc_bsel[0] = 1'b1;
           3'b001 : loc_bsel[1] = 1'b1;
          default  : loc_bsel = {2{1'b0}};
        endcase
        iid_bsel = {3{1'b0}}; 
        case(bid_m[11])
           1'd1 : iid_bsel[1] = 1'b1;
          default  : iid_bsel[2] = 1'b1;
        endcase
        if (~iid_bsel[2])
            bsel = iid_bsel[1:0];
        else
            bsel = loc_bsel;
     end else
     begin
        iid_bsel = {3{1'b0}}; 
        bsel = {2{1'b0}};
     end 
   end 

   always @(rid_m or rvalid_m)
     begin : p_r_ret_sel
     reg [1:0] loc_rsel; 
     loc_rsel = {2{1'b0}};
     if (rvalid_m)
     begin
        case(rid_m[2:0])
           3'b000 : loc_rsel[0] = 1'b1;
           3'b001 : loc_rsel[1] = 1'b1;
          default  : loc_rsel = {2{1'b0}};
        endcase
        iid_rsel = {3{1'b0}}; 
        case(rid_m[11])
           1'd1 : iid_rsel[1] = 1'b1;
          default  : iid_rsel[2] = 1'b1;
        endcase
        if (~iid_rsel[2])
            rsel = iid_rsel[1:0];
        else
            rsel = loc_rsel;
     end else
     begin
        iid_rsel = {3{1'b0}}; 
        rsel = {2{1'b0}};
     end 
   end 


   assign bvalid_masked = bvalid_m & ~wr_cnt_empty;


    assign buser_s0  = buser_m & {1{bsel[0]}};
    assign bid_s0  = bid_m & {12{bsel[0]}};
    assign bresp_s0  = bresp_m & {2{bsel[0]}};
    assign bvalid_s0  = bvalid_masked & bsel[0];

    assign buser_s1  = buser_m & {1{bsel[1]}};
    assign bid_s1  = bid_m & {12{bsel[1]}};
    assign bresp_s1  = bresp_m & {2{bsel[1]}};
    assign bvalid_s1  = bvalid_masked & bsel[1];



    assign ruser_s0 = ruser_m & {1{rsel[0]}};
    assign rid_s0 = rid_m & {12{rsel[0]}};
    assign rdata_s0 = rdata_m & {64{rsel[0]}};
    assign rresp_s0 = rresp_m & {2{rsel[0]}};
    assign rlast_s0 = rlast_m & rsel[0];
    assign rvalid_s0 = rvalid_m & rsel[0];

    assign ruser_s1 = ruser_m & {1{rsel[1]}};
    assign rid_s1 = rid_m & {12{rsel[1]}};
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



`endif

endmodule


