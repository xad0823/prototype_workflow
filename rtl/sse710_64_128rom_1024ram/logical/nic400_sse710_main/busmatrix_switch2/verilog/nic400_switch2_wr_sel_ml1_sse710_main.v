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


module nic400_switch2_wr_sel_ml1_sse710_main
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

    wdata_s6,
    wstrb_s6,   
    wlast_s6,
    wvalid_s6,
    wready_s6,

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
  input  [63:0]     wdata_s6;
  input  [7:0]      wstrb_s6;   
  input             wlast_s6;
  input             wvalid_s6;
  output            wready_s6;


  input [6:0]    aw_sel;
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
  wire   [63:0]     wdata_masked6;
  wire   [7:0]      wstrb_masked6;   
  wire              wlast_masked6;
  wire              wvalid_masked6;


  wire   [6:0]     next_wr_ch_en; 
 
  wire              wt_push; 
  wire              wt_pop; 
  wire   [2:0]      next_enc; 
  wire   [2:0]      enc_fifo_op; 
  reg    [6:0]      fifo_op; 
  reg               next_wr_ptr; 
  reg               next_rd_ptr; 
  reg          wr_ptr_en; 
  wire              next_empty; 



  reg               aw_sel_reg; 
  reg               awready_reg;  
  reg   [6:0]       wr_ch_en; 
  reg   [2:0]       fifo; 
  reg               wr_ptr; 
  reg               rd_ptr; 
  reg               empty; 




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





   assign wt_push =  (add_push && |wr_ch_en && !empty)
               || (add_push && |wr_ch_en && !last_beat);
   assign wt_pop = (|wr_ch_en) && last_beat && !empty;
      
   assign next_enc[0] = aw_sel[1]
                        | aw_sel[3]
                        | aw_sel[5];
   assign next_enc[1] = aw_sel[2]
                        | aw_sel[3]
                        | aw_sel[6];

   assign next_enc[2] = aw_sel[4]
                        | aw_sel[5]
                        | aw_sel[6];

   always @(wr_ptr or rd_ptr or wt_push or wt_pop)
     begin : p_fifo_comb
       next_wr_ptr = wr_ptr;
       next_rd_ptr = rd_ptr;
       if (wt_push)
         begin
             if (wr_ptr == 1'b0)
               next_wr_ptr = 1'b1;
             else
               next_wr_ptr = 1'b0;
         end
       if (wt_pop)
         begin
             if (rd_ptr == 1'b0)
               next_rd_ptr = 1'b1;
             else
               next_rd_ptr = 1'b0;
         end
     end 

   always @(wt_push)
     begin : p_ptr_en

                wr_ptr_en = wt_push;
     end 

   always @(posedge aclk or negedge aresetn)
     begin : p_fifo_ptr_seq
       if (!aresetn) begin
              wr_ptr <= 1'b0;
              rd_ptr <= 1'b0;
        end else begin
           if (wt_push) 
                 wr_ptr <= next_wr_ptr;
           if (wt_pop) 
               rd_ptr <= next_rd_ptr;
        end
     end 

   always @(posedge aclk)
     begin : p_fifo_seq
         if (wr_ptr_en) begin
                 fifo <= next_enc;
         end
     end 

   assign enc_fifo_op = fifo;
   always @(enc_fifo_op)
     begin : p_uncode_comb
       fifo_op = {7{1'b0}};
       fifo_op[enc_fifo_op] = 1'b1;
     end 

   assign next_empty = wt_push && !wt_pop ? 1'b0
                         : !wt_push && wt_pop ? 1'b1
                         :  empty;


   always @(posedge aclk or negedge aresetn)
     begin : p_empty_seq
       if (!aresetn)
         begin
             empty <= 1'b1;
         end
       else if (wt_push || wt_pop)
         begin
             empty <= next_empty;
         end
    end 


   assign next_wr_ch_en = ~empty ? fifo_op : (add_push) ? aw_sel : {7{1'b0}};



   always @(posedge aclk or negedge aresetn)
     begin : p_wr_ch_en_seq
       if (!aresetn)
         begin
             wr_ch_en    <= {7{1'b0}};
         end
       else if (last_beat | (~|wr_ch_en & ((add_push) | ~empty)))
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

    assign wdata_masked6  = wdata_s6 & {64{wr_ch_en[6]}};
    assign wstrb_masked6  = wstrb_s6 & {8{wr_ch_en[6]}}; 
    assign wlast_masked6  = wlast_s6 & wr_ch_en[6];
    assign wvalid_masked6 = wvalid_s6 & wr_ch_en[6];

    assign wdata_m  = wdata_masked0 | wdata_masked1 | wdata_masked2 | wdata_masked3 | wdata_masked4 | wdata_masked5 | wdata_masked6;
    assign wstrb_m  = wstrb_masked0 | wstrb_masked1 | wstrb_masked2 | wstrb_masked3 | wstrb_masked4 | wstrb_masked5 | wstrb_masked6;
    assign wlast_m  = wlast_masked0 | wlast_masked1 | wlast_masked2 | wlast_masked3 | wlast_masked4 | wlast_masked5 | wlast_masked6;
    assign wvalid_m = wvalid_masked0 | wvalid_masked1 | wvalid_masked2 | wvalid_masked3 | wvalid_masked4 | wvalid_masked5 | wvalid_masked6;

    assign wready_s0 = (wready_m & wr_ch_en[0]);
    assign wready_s1 = (wready_m & wr_ch_en[1]);
    assign wready_s2 = (wready_m & wr_ch_en[2]);
    assign wready_s3 = (wready_m & wr_ch_en[3]);
    assign wready_s4 = (wready_m & wr_ch_en[4]);
    assign wready_s5 = (wready_m & wr_ch_en[5]);
    assign wready_s6 = (wready_m & wr_ch_en[6]);

 
    `ifdef ARM_ASSERT_ON

      parameter  WR_ISS_DEPTH = 2;
      assert_zero_one_hot #(0,7,0,"ERROR, More than one write channel enabled")
         ovl_write_channel_en
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (wr_ch_en)
            );

       assert_fifo_index #(0, WR_ISS_DEPTH - 1, 1, 1, 0,"ERROR, Write tracker fifo under or overflowed")
         ovl_wr_tracker_fifo_index
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .push      (wt_push),
            .pop       (wt_pop)
            );

       assert_implication #(0,0,"ERROR, Write tracker empty flag does not have the expected value")
         ovl_wr_tracker_empty_flag
          (
           .clk       (aclk),
           .reset_n   (aresetn),
           .antecedent_expr (empty),
           .consequent_expr (rd_ptr == wr_ptr)
         );
 
       assert_never #(1,0,"ERROR, Write channel select is X")
         ovl_wr_ch_sel_x
          (
           .clk       (aclk),
           .reset_n   (aresetn),
           .test_expr (!empty && |(enc_fifo_op ^ enc_fifo_op))
         );
 
       assert_never #(1,0,"ERROR, wr_sel fifo_op index to large")
         ovl_fifo_op_index
          (
           .clk       (aclk),
           .reset_n   (aresetn),
           .test_expr (!empty && (enc_fifo_op >= 7))
         );


    `endif


endmodule


