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


module nic400_switch2_ret_sel_ml7_sse710_main
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

    buser_s2,
    bid_s2,
    bresp_s2,
    bvalid_s2,
    bready_s2,  
    ruser_s2,
    rid_s2,
    rdata_s2,
    rresp_s2,
    rlast_s2,
    rvalid_s2,
    rready_s2,

    buser_s3,
    bid_s3,
    bresp_s3,
    bvalid_s3,
    bready_s3,  
    ruser_s3,
    rid_s3,
    rdata_s3,
    rresp_s3,
    rlast_s3,
    rvalid_s3,
    rready_s3,

    buser_s4,
    bid_s4,
    bresp_s4,
    bvalid_s4,
    bready_s4,  
    ruser_s4,
    rid_s4,
    rdata_s4,
    rresp_s4,
    rlast_s4,
    rvalid_s4,
    rready_s4,

    buser_s5,
    bid_s5,
    bresp_s5,
    bvalid_s5,
    bready_s5,  
    ruser_s5,
    rid_s5,
    rdata_s5,
    rresp_s5,
    rlast_s5,
    rvalid_s5,
    rready_s5,

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

  output            buser_s2;
  output [11:0]      bid_s2;
  output [1:0]      bresp_s2;
  output            bvalid_s2;
  input             bready_s2;  
  output            ruser_s2;
  output  [11:0]     rid_s2;
  output  [63:0]    rdata_s2;
  output [1:0]      rresp_s2;
  output            rlast_s2;
  output            rvalid_s2;
  input             rready_s2;

  output            buser_s3;
  output [11:0]      bid_s3;
  output [1:0]      bresp_s3;
  output            bvalid_s3;
  input             bready_s3;  
  output            ruser_s3;
  output  [11:0]     rid_s3;
  output  [63:0]    rdata_s3;
  output [1:0]      rresp_s3;
  output            rlast_s3;
  output            rvalid_s3;
  input             rready_s3;

  output            buser_s4;
  output [11:0]      bid_s4;
  output [1:0]      bresp_s4;
  output            bvalid_s4;
  input             bready_s4;  
  output            ruser_s4;
  output  [11:0]     rid_s4;
  output  [63:0]    rdata_s4;
  output [1:0]      rresp_s4;
  output            rlast_s4;
  output            rvalid_s4;
  input             rready_s4;

  output            buser_s5;
  output [11:0]      bid_s5;
  output [1:0]      bresp_s5;
  output            bvalid_s5;
  input             bready_s5;  
  output            ruser_s5;
  output  [11:0]     rid_s5;
  output  [63:0]    rdata_s5;
  output [1:0]      rresp_s5;
  output            rlast_s5;
  output            rvalid_s5;
  input             rready_s5;




  wire              bvalid_masked;
  wire              bready_comb;
  wire              bready_masked0;  
  wire              rready_masked0;

  wire              bready_masked1;  
  wire              rready_masked1;

  wire              bready_masked2;  
  wire              rready_masked2;

  wire              bready_masked3;  
  wire              rready_masked3;

  wire              bready_masked4;  
  wire              rready_masked4;

  wire              bready_masked5;  
  wire              rready_masked5;
  reg [5:0]       bsel; 
  reg [5:0]       rsel; 







   always @(bid_m or bvalid_m)
   begin : p_b_ret_sel
     reg [5:0] loc_bsel; 
     loc_bsel = {6{1'b0}}; 
     if (bvalid_m)
     begin
        case(bid_m[2:0])
           3'b000 : loc_bsel[0] = 1'b1;
           3'b010 : loc_bsel[1] = 1'b1;
           3'b011 : loc_bsel[2] = 1'b1;
           3'b100 : loc_bsel[3] = 1'b1;
           3'b101 : loc_bsel[4] = 1'b1;
           3'b110 : loc_bsel[5] = 1'b1;
          default  : loc_bsel = {6{1'b0}};
        endcase
        bsel = loc_bsel;
     end else
     begin
        bsel = {6{1'b0}};
     end 
   end 

   always @(rid_m or rvalid_m)
     begin : p_r_ret_sel
     reg [5:0] loc_rsel; 
     loc_rsel = {6{1'b0}};
     if (rvalid_m)
     begin
        case(rid_m[2:0])
           3'b000 : loc_rsel[0] = 1'b1;
           3'b010 : loc_rsel[1] = 1'b1;
           3'b011 : loc_rsel[2] = 1'b1;
           3'b100 : loc_rsel[3] = 1'b1;
           3'b101 : loc_rsel[4] = 1'b1;
           3'b110 : loc_rsel[5] = 1'b1;
          default  : loc_rsel = {6{1'b0}};
        endcase
        rsel = loc_rsel;
     end else
     begin
        rsel = {6{1'b0}};
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

    assign buser_s2  = buser_m & {1{bsel[2]}};
    assign bid_s2  = bid_m & {12{bsel[2]}};
    assign bresp_s2  = bresp_m & {2{bsel[2]}};
    assign bvalid_s2  = bvalid_masked & bsel[2];

    assign buser_s3  = buser_m & {1{bsel[3]}};
    assign bid_s3  = bid_m & {12{bsel[3]}};
    assign bresp_s3  = bresp_m & {2{bsel[3]}};
    assign bvalid_s3  = bvalid_masked & bsel[3];

    assign buser_s4  = buser_m & {1{bsel[4]}};
    assign bid_s4  = bid_m & {12{bsel[4]}};
    assign bresp_s4  = bresp_m & {2{bsel[4]}};
    assign bvalid_s4  = bvalid_masked & bsel[4];

    assign buser_s5  = buser_m & {1{bsel[5]}};
    assign bid_s5  = bid_m & {12{bsel[5]}};
    assign bresp_s5  = bresp_m & {2{bsel[5]}};
    assign bvalid_s5  = bvalid_masked & bsel[5];



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

    assign ruser_s2 = ruser_m & {1{rsel[2]}};
    assign rid_s2 = rid_m & {12{rsel[2]}};
    assign rdata_s2 = rdata_m & {64{rsel[2]}};
    assign rresp_s2 = rresp_m & {2{rsel[2]}};
    assign rlast_s2 = rlast_m & rsel[2];
    assign rvalid_s2 = rvalid_m & rsel[2];

    assign ruser_s3 = ruser_m & {1{rsel[3]}};
    assign rid_s3 = rid_m & {12{rsel[3]}};
    assign rdata_s3 = rdata_m & {64{rsel[3]}};
    assign rresp_s3 = rresp_m & {2{rsel[3]}};
    assign rlast_s3 = rlast_m & rsel[3];
    assign rvalid_s3 = rvalid_m & rsel[3];

    assign ruser_s4 = ruser_m & {1{rsel[4]}};
    assign rid_s4 = rid_m & {12{rsel[4]}};
    assign rdata_s4 = rdata_m & {64{rsel[4]}};
    assign rresp_s4 = rresp_m & {2{rsel[4]}};
    assign rlast_s4 = rlast_m & rsel[4];
    assign rvalid_s4 = rvalid_m & rsel[4];

    assign ruser_s5 = ruser_m & {1{rsel[5]}};
    assign rid_s5 = rid_m & {12{rsel[5]}};
    assign rdata_s5 = rdata_m & {64{rsel[5]}};
    assign rresp_s5 = rresp_m & {2{rsel[5]}};
    assign rlast_s5 = rlast_m & rsel[5];
    assign rvalid_s5 = rvalid_m & rsel[5];


    assign bready_masked0 = bready_s0 & bsel[0];
    assign rready_masked0 = rready_s0 & rsel[0];
    assign bready_masked1 = bready_s1 & bsel[1];
    assign rready_masked1 = rready_s1 & rsel[1];
    assign bready_masked2 = bready_s2 & bsel[2];
    assign rready_masked2 = rready_s2 & rsel[2];
    assign bready_masked3 = bready_s3 & bsel[3];
    assign rready_masked3 = rready_s3 & rsel[3];
    assign bready_masked4 = bready_s4 & bsel[4];
    assign rready_masked4 = rready_s4 & rsel[4];
    assign bready_masked5 = bready_s5 & bsel[5];
    assign rready_masked5 = rready_s5 & rsel[5];

    assign bready_comb = bready_masked0 | bready_masked1 | bready_masked2 | bready_masked3 | bready_masked4 | bready_masked5;
    assign bready_m = bready_comb & ~wr_cnt_empty;
    assign rready_m = rready_masked0 | rready_masked1 | rready_masked2 | rready_masked3 | rready_masked4 | rready_masked5;


`ifdef ARM_ASSERT_ON



`endif

endmodule


