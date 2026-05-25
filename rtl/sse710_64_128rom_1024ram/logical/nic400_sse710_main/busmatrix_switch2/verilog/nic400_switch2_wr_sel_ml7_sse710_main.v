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


module nic400_switch2_wr_sel_ml7_sse710_main
  (
    aclk,
    aresetn,
    aw_sel,
    awready_m,
    wdata_s0,
    wstrb_s0,   
    wlast_s0,
    wvalid_s0,
    wready_s0,

    wdata_s1,
    wstrb_s1,   
    wlast_s1,
    wvalid_s1,
    wready_s1,

    wdata_s2,
    wstrb_s2,   
    wlast_s2,
    wvalid_s2,
    wready_s2,

    wdata_s3,
    wstrb_s3,   
    wlast_s3,
    wvalid_s3,
    wready_s3,

    wdata_s4,
    wstrb_s4,   
    wlast_s4,
    wvalid_s4,
    wready_s4,

    wdata_s5,
    wstrb_s5,   
    wlast_s5,
    wvalid_s5,
    wready_s5,

    wdata_m,
    wstrb_m,
    wlast_m,
    wvalid_m,
    wready_m
  );




  output  [63:0]    wdata_m;
  output  [7:0]     wstrb_m;
  output            wlast_m;
  output            wvalid_m;
  input             wready_m;
  input  [63:0]     wdata_s0;
  input  [7:0]      wstrb_s0;   
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;
  input  [63:0]     wdata_s1;
  input  [7:0]      wstrb_s1;   
  input             wlast_s1;
  input             wvalid_s1;
  output            wready_s1;
  input  [63:0]     wdata_s2;
  input  [7:0]      wstrb_s2;   
  input             wlast_s2;
  input             wvalid_s2;
  output            wready_s2;
  input  [63:0]     wdata_s3;
  input  [7:0]      wstrb_s3;   
  input             wlast_s3;
  input             wvalid_s3;
  output            wready_s3;
  input  [63:0]     wdata_s4;
  input  [7:0]      wstrb_s4;   
  input             wlast_s4;
  input             wvalid_s4;
  output            wready_s4;
  input  [63:0]     wdata_s5;
  input  [7:0]      wstrb_s5;   
  input             wlast_s5;
  input             wvalid_s5;
  output            wready_s5;


  input [5:0]    aw_sel;
  input             awready_m;

  input             aclk;
  input             aresetn;


  wire              add_push;  
  wire              last_beat; 
  wire   [63:0]     wdata_masked0;
  wire   [7:0]      wstrb_masked0;   
  wire              wlast_masked0;
  wire              wvalid_masked0;
  wire   [63:0]     wdata_masked1;
  wire   [7:0]      wstrb_masked1;   
  wire              wlast_masked1;
  wire              wvalid_masked1;
  wire   [63:0]     wdata_masked2;
  wire   [7:0]      wstrb_masked2;   
  wire              wlast_masked2;
  wire              wvalid_masked2;
  wire   [63:0]     wdata_masked3;
  wire   [7:0]      wstrb_masked3;   
  wire              wlast_masked3;
  wire              wvalid_masked3;
  wire   [63:0]     wdata_masked4;
  wire   [7:0]      wstrb_masked4;   
  wire              wlast_masked4;
  wire              wvalid_masked4;
  wire   [63:0]     wdata_masked5;
  wire   [7:0]      wstrb_masked5;   
  wire              wlast_masked5;
  wire              wvalid_masked5;


  wire   [5:0]     next_wr_ch_en; 
 


  reg               aw_sel_reg; 
  reg               awready_reg;  
  reg   [5:0]       wr_ch_en; 




   always @(posedge aclk or negedge aresetn)
     begin : p_add_push_seq
       if (!aresetn)
         begin
             aw_sel_reg  <= 1'b0;
             awready_reg <= 1'b0;
         end
       else
         begin
            if ((|aw_sel) || aw_sel_reg)
             begin
                 aw_sel_reg  <= |aw_sel;
             end
            if (awready_m || awready_reg)
             begin
                awready_reg   <= awready_m;
             end
         end
     end 

   assign add_push = (|aw_sel & ~aw_sel_reg) | (|aw_sel & aw_sel_reg & awready_reg);


   assign last_beat = wvalid_m & wready_m & wlast_m;





   assign next_wr_ch_en = (add_push) ? aw_sel : {6{1'b0}};



   always @(posedge aclk or negedge aresetn)
     begin : p_wr_ch_en_seq
       if (!aresetn)
         begin
             wr_ch_en    <= {6{1'b0}};
         end
       else if (last_beat | (~|wr_ch_en & ((add_push))))
         begin
             wr_ch_en    <=   next_wr_ch_en;
         end
     end 

     


    assign wdata_masked0  = wdata_s0 & {64{wr_ch_en[0]}};
    assign wstrb_masked0  = wstrb_s0 & {8{wr_ch_en[0]}}; 
    assign wlast_masked0  = wlast_s0 & wr_ch_en[0];
    assign wvalid_masked0 = wvalid_s0 & wr_ch_en[0];

    assign wdata_masked1  = wdata_s1 & {64{wr_ch_en[1]}};
    assign wstrb_masked1  = wstrb_s1 & {8{wr_ch_en[1]}}; 
    assign wlast_masked1  = wlast_s1 & wr_ch_en[1];
    assign wvalid_masked1 = wvalid_s1 & wr_ch_en[1];

    assign wdata_masked2  = wdata_s2 & {64{wr_ch_en[2]}};
    assign wstrb_masked2  = wstrb_s2 & {8{wr_ch_en[2]}}; 
    assign wlast_masked2  = wlast_s2 & wr_ch_en[2];
    assign wvalid_masked2 = wvalid_s2 & wr_ch_en[2];

    assign wdata_masked3  = wdata_s3 & {64{wr_ch_en[3]}};
    assign wstrb_masked3  = wstrb_s3 & {8{wr_ch_en[3]}}; 
    assign wlast_masked3  = wlast_s3 & wr_ch_en[3];
    assign wvalid_masked3 = wvalid_s3 & wr_ch_en[3];

    assign wdata_masked4  = wdata_s4 & {64{wr_ch_en[4]}};
    assign wstrb_masked4  = wstrb_s4 & {8{wr_ch_en[4]}}; 
    assign wlast_masked4  = wlast_s4 & wr_ch_en[4];
    assign wvalid_masked4 = wvalid_s4 & wr_ch_en[4];

    assign wdata_masked5  = wdata_s5 & {64{wr_ch_en[5]}};
    assign wstrb_masked5  = wstrb_s5 & {8{wr_ch_en[5]}}; 
    assign wlast_masked5  = wlast_s5 & wr_ch_en[5];
    assign wvalid_masked5 = wvalid_s5 & wr_ch_en[5];

    assign wdata_m  = wdata_masked0 | wdata_masked1 | wdata_masked2 | wdata_masked3 | wdata_masked4 | wdata_masked5;
    assign wstrb_m  = wstrb_masked0 | wstrb_masked1 | wstrb_masked2 | wstrb_masked3 | wstrb_masked4 | wstrb_masked5;
    assign wlast_m  = wlast_masked0 | wlast_masked1 | wlast_masked2 | wlast_masked3 | wlast_masked4 | wlast_masked5;
    assign wvalid_m = wvalid_masked0 | wvalid_masked1 | wvalid_masked2 | wvalid_masked3 | wvalid_masked4 | wvalid_masked5;

    assign wready_s0 = (wready_m & wr_ch_en[0]);
    assign wready_s1 = (wready_m & wr_ch_en[1]);
    assign wready_s2 = (wready_m & wr_ch_en[2]);
    assign wready_s3 = (wready_m & wr_ch_en[3]);
    assign wready_s4 = (wready_m & wr_ch_en[4]);
    assign wready_s5 = (wready_m & wr_ch_en[5]);

 
    `ifdef ARM_ASSERT_ON

      parameter  WR_ISS_DEPTH = 1;
      assert_zero_one_hot #(0,6,0,"ERROR, More than one write channel enabled")
         ovl_write_channel_en
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (wr_ch_en)
            );


    `endif


endmodule


