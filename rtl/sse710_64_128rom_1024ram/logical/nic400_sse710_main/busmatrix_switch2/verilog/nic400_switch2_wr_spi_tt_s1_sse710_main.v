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



module nic400_switch2_wr_spi_tt_s1_sse710_main
  (
    aw_enable,
    tt_enable,
    wr_enable,
    asel,
    aready,
    wvalid,
    wready,
    wlast,
    resp_valid,
    resp_ready,
    bvalid_m0,
    bvalid_m1,
    bvalid_m2,
    bvalid_m3,
    bvalid_m4,
    bvalid_m5,
    bvalid_m6,

    aclk,
    aresetn
  );


    output [6:0] aw_enable;     
    output [6:0] tt_enable;     
    output [6:0] wr_enable;     
    input  [6:0] asel;     
    input        aready;     
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid; 
    input        resp_ready;
    input        bvalid_m0;
    input        bvalid_m1;
    input        bvalid_m2;
    input        bvalid_m3;
    input        bvalid_m4;
    input        bvalid_m5;
    input        bvalid_m6;
    input        aclk;
    input        aresetn;




  wire      next_valid_add;     
  wire  [6:0]    next_tt_reg;   
  reg   [1:0]    next_tt_cnt;    
  reg            dec_tt_cnt;    

  wire           t_pop;   
  wire           asel_mask;   

  wire  [2:0]    next_ptr0;   
  wire  [2:0]    next_ptr1;   
  wire  [2:0]    next_ptr2;   
  wire  [2:0]    next_ptr3;   
  wire  [2:0]    next_ptr4;   
  wire  [2:0]    next_ptr5;   
  wire  [2:0]    next_ptr6;   
  reg   [2:0]    ptr_sel;   
  reg   [6:0]    int_tt_en;  
  reg   [6:0]    shift;  
  wire  [6:0]    resp_valid_vector;   

  wire           add_push;           
  wire           aw_enable_bit;      
  wire           next_add_stall;     
  wire           next_resp_stall;    



  reg          valid_add;   
  reg   [1:0]    tt_cnt;   
  reg            add_stall;
  reg   [6:0]    tt_reg[1:0];   
  reg            aw_sel;   
  reg            tt_sel;   
  reg            resp_stall;   
  reg            asel_reg;   
  reg            aready_reg;   

  reg   [2:0]    ptr0;   
  reg   [2:0]    ptr1;   
  reg   [2:0]    ptr2;   
  reg   [2:0]    ptr3;   
  reg   [2:0]    ptr4;   
  reg   [2:0]    ptr5;   
  reg   [2:0]    ptr6;   
  reg   [6:0]    reg_tt_en;     



   assign asel_mask = |asel & aw_enable_bit;
   always @(posedge aclk or negedge aresetn)
     begin : p_add_push_seq
       if (!aresetn)
         begin
             asel_reg  <= 1'b0;
             aready_reg <= 1'b0;
         end
       else
         begin
            if (asel_mask || asel_reg)
             begin
                 asel_reg  <= asel_mask;
             end
            if (aready_reg || aready)
             begin
                aready_reg   <= aready;
             end
         end
     end 

   assign add_push = ((asel_mask & ~asel_reg) | (asel_mask & asel_reg & aready_reg));



   always @(add_push or wvalid or wready or wlast or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        dec_tt_cnt = 1'b0;
        if (add_push && !(wvalid && wready && wlast)) 
                next_tt_cnt = tt_cnt + 1'b1;
        if (!(add_push) && (wvalid && wready && wlast))
        begin
                next_tt_cnt = tt_cnt - 1'b1;
                dec_tt_cnt = 1'b1;
        end
     end 
 


   assign t_pop = resp_valid & resp_ready;

   assign resp_valid_vector[0] = bvalid_m0;
   assign resp_valid_vector[1] = bvalid_m1;
   assign resp_valid_vector[2] = bvalid_m2;
   assign resp_valid_vector[3] = bvalid_m3;
   assign resp_valid_vector[4] = bvalid_m4;
   assign resp_valid_vector[5] = bvalid_m5;
   assign resp_valid_vector[6] = bvalid_m6;

   always @(resp_valid_vector or ptr0 or ptr1 or ptr2 or ptr3 or ptr4 or ptr5 or ptr6)
   begin : p_lrg_comb
        int_tt_en = {7{1'b0}};
        ptr_sel = {3{1'b0}};
        shift = {7{1'b0}};
        if (resp_valid_vector[ptr0] == 1'b1) 
        begin
                int_tt_en[ptr0] =1'b1;
                ptr_sel = ptr0;
                shift = 7'b1111111;
        end
        else if (resp_valid_vector[ptr1] == 1'b1) 
        begin
                int_tt_en[ptr1] =1'b1;
                ptr_sel = ptr1;
                shift = 7'b1111110;
        end
        else if (resp_valid_vector[ptr2] == 1'b1) 
        begin
                int_tt_en[ptr2] =1'b1;
                ptr_sel = ptr2;
                shift = 7'b1111100;
        end
        else if (resp_valid_vector[ptr3] == 1'b1) 
        begin
                int_tt_en[ptr3] =1'b1;
                ptr_sel = ptr3;
                shift = 7'b1111000;
        end
        else if (resp_valid_vector[ptr4] == 1'b1) 
        begin
                int_tt_en[ptr4] =1'b1;
                ptr_sel = ptr4;
                shift = 7'b1110000;
        end
        else if (resp_valid_vector[ptr5] == 1'b1) 
        begin
                int_tt_en[ptr5] =1'b1;
                ptr_sel = ptr5;
                shift = 7'b1100000;
        end
        else if (resp_valid_vector[ptr6] == 1'b1) 
        begin
                int_tt_en[ptr6] =1'b1;
                ptr_sel = ptr6;
                shift = 7'b1000000;
        end
        
   end 


   assign next_ptr0 = shift[0] ? ptr1 : ptr0;
   assign next_ptr1 = shift[1] ? ptr2 : ptr1;
   assign next_ptr2 = shift[2] ? ptr3 : ptr2;
   assign next_ptr3 = shift[3] ? ptr4 : ptr3;
   assign next_ptr4 = shift[4] ? ptr5 : ptr4;
   assign next_ptr5 = shift[5] ? ptr6 : ptr5;
   assign next_ptr6 = shift[6] ? ptr_sel : ptr6;


    assign next_tt_reg = (add_push) ? asel 
                        : (tt_cnt == 2'b01 && dec_tt_cnt) ? {7{1'b0}}
                        : tt_reg[tt_sel];




   assign next_valid_add = (|next_tt_cnt);

   always @(posedge aclk or negedge aresetn)
     begin : p_aw_sel_seq 
       if (!aresetn) 
         begin
            aw_sel <= 1'b0;
            tt_reg[0] <= {7{1'b0}};
            tt_reg[1] <= {7{1'b0}};
         end
       else if (add_push)
         begin
            aw_sel <= ~aw_sel;
            tt_reg[aw_sel] <= next_tt_reg;
         end
      end 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_sel_seq 
       if (!aresetn) 
         begin
            tt_sel <= 1'b0;
         end
       else if ((wvalid && wready && wlast))
         begin
            tt_sel <= ~tt_sel;
         end
      end 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq 
       if (!aresetn) 
         begin
             tt_cnt <= {2{1'b0}};
             valid_add <= 1'b0;
         end
        else 
         begin
           if ((add_push) || (wvalid && wready && wlast))
           begin
             tt_cnt <= next_tt_cnt;
             valid_add <= next_valid_add;
           end
         end
       end 
 

    always @(posedge aclk or negedge aresetn)
    begin : p_ptr_seq
      if (!aresetn) 
      begin
         ptr0    <= 3'd0;
         ptr1    <= 3'd1;
         ptr2    <= 3'd2;
         ptr3    <= 3'd3;
         ptr4    <= 3'd4;
         ptr5    <= 3'd5;
         ptr6    <= 3'd6;
      end else 
      begin
        if (t_pop)
         begin
             ptr0    <=   next_ptr0;
             ptr1    <=   next_ptr1;
             ptr2    <=   next_ptr2;
             ptr3    <=   next_ptr3;
             ptr4    <=   next_ptr4;
             ptr5    <=   next_ptr5;
             ptr6    <=   next_ptr6;
         end
      end 
    end 



   assign next_add_stall = (aw_enable_bit & ~aready);
   assign next_resp_stall = (resp_valid & ~resp_ready);

   always @(posedge aclk or negedge aresetn)
     begin : p_stall_seq
       if (!aresetn)
         begin
          resp_stall <= 1'b0;
          add_stall  <= 1'b0;
        end
       else
         begin
          resp_stall <= next_resp_stall;
          add_stall  <= next_add_stall;
        end
     end 


   assign aw_enable_bit = add_stall ? 1'b1 : ~tt_cnt[1];
   assign aw_enable = {7{aw_enable_bit}} & asel;

   assign wr_enable = tt_reg[tt_sel] & {7{valid_add}};



    always @(posedge aclk or negedge aresetn)
     begin : p_tt_en_seq
       if (!aresetn)
         begin
          reg_tt_en <= {7{1'b0}};
        end
       else if (next_resp_stall && !resp_stall)
         begin
          reg_tt_en <= int_tt_en;
        end
     end 
 
   assign tt_enable = resp_stall ? reg_tt_en : int_tt_en;


`ifdef ARM_ASSERT_ON



assign dec_from_zero = (tt_cnt=={2{1'b0}}) & (wvalid & wready & wlast );

assert_never #(1,0,"ERROR, Transaction Counter decrementing from 0")
ovl_assert_dec_empty
   (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (dec_from_zero));


assign inc_from_full = (tt_cnt==2'b11) & add_push & ~(wvalid & wready & wlast );

assert_never #(1,0,"ERROR, Transaction Counter incrementing when full")
ovl_assert_inc_full
   (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (inc_from_full));



   reg [2:0] ptr_sel_reg;
   reg       hold;
   reg       start;
   reg [2:0] ptr0_reg;
   reg [2:0] ptr1_reg;
   reg [2:0] ptr2_reg;
   reg [2:0] ptr3_reg;
   reg [2:0] ptr4_reg;
   reg [2:0] ptr5_reg;
   reg [2:0] ptr6_reg;

   always @(posedge aclk or negedge aresetn)
     begin : p_psel_reg_seq
       if (!aresetn)
         begin
          ptr_sel_reg <= 3'b0;
          hold        <= 1'b0;
          start       <= 1'b0;
          ptr0_reg    <= 3'd0;
          ptr1_reg    <= 3'd1;
          ptr2_reg    <= 3'd2;
          ptr3_reg    <= 3'd3;
          ptr4_reg    <= 3'd4;
          ptr5_reg    <= 3'd5;
          ptr6_reg    <= 3'd6;
        end
       else
         begin
          ptr_sel_reg <= ptr_sel;
          hold        <= |asel & ~aready;
          start       <= t_pop;
          ptr0_reg    <= ptr0;
          ptr1_reg    <= ptr1;
          ptr2_reg    <= ptr2;
          ptr3_reg    <= ptr3;
          ptr4_reg    <= ptr4;
          ptr5_reg    <= ptr5;
          ptr6_reg    <= ptr6;
        end
     end 

   
   assert_implication #(0, 0, "ERROR, LRG list item 0 incorrectly updated")
     ovl_lrg_list_update0
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr0 != ptr0_reg),
       .consequent_expr (ptr0 == ptr1_reg)
     );
   
   assert_implication #(0, 0, "ERROR, LRG list item 1 incorrectly updated")
     ovl_lrg_list_update1
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr1 != ptr1_reg),
       .consequent_expr (ptr1 == ptr2_reg)
     );
   
   assert_implication #(0, 0, "ERROR, LRG list item 2 incorrectly updated")
     ovl_lrg_list_update2
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr2 != ptr2_reg),
       .consequent_expr (ptr2 == ptr3_reg)
     );
   
   assert_implication #(0, 0, "ERROR, LRG list item 3 incorrectly updated")
     ovl_lrg_list_update3
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr3 != ptr3_reg),
       .consequent_expr (ptr3 == ptr4_reg)
     );
   
   assert_implication #(0, 0, "ERROR, LRG list item 4 incorrectly updated")
     ovl_lrg_list_update4
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr4 != ptr4_reg),
       .consequent_expr (ptr4 == ptr5_reg)
     );
   
   assert_implication #(0, 0, "ERROR, LRG list item 5 incorrectly updated")
     ovl_lrg_list_update5
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (ptr5 != ptr5_reg),
       .consequent_expr (ptr5 == ptr6_reg)
     );
   

   assert_implication #(0,0,"ERROR, LRG list item 6 incorrectly updated")
     ovl_lrg_list_update6
      (
       .clk       (aclk),
       .reset_n   (aresetn),
       .antecedent_expr (start),
       .consequent_expr ((ptr6 == ptr_sel_reg)) 
     );


   assert_never #(1,0,"ERROR, ptr0 illegal value")
    ovl_ptr0_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr0 >= 7));

   assert_never #(1,0,"ERROR, ptr1 illegal value")
    ovl_ptr1_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr1 >= 7));

   assert_never #(1,0,"ERROR, ptr2 illegal value")
    ovl_ptr2_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr2 >= 7));

   assert_never #(1,0,"ERROR, ptr3 illegal value")
    ovl_ptr3_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr3 >= 7));

   assert_never #(1,0,"ERROR, ptr4 illegal value")
    ovl_ptr4_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr4 >= 7));

   assert_never #(1,0,"ERROR, ptr5 illegal value")
    ovl_ptr5_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr5 >= 7));

   assert_never #(1,0,"ERROR, ptr6 illegal value")
    ovl_ptr6_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr6 >= 7));


`endif 

  endmodule

