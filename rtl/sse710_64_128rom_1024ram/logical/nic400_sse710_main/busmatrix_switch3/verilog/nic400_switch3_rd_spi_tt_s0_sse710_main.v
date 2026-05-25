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




module nic400_switch3_rd_spi_tt_s0_sse710_main
  (
    tt_enable,
    resp_valid,
    resp_last,
    resp_ready,
    rvalid_m0,
    rvalid_m1,
    rvalid_m2,
    rvalid_m3,

    aclk,
    aresetn
  );


    output [3:0]    tt_enable;     
    input        resp_valid;
    input        resp_last;
    input        resp_ready;
    input        rvalid_m0;
    input        rvalid_m1;
    input        rvalid_m2;
    input        rvalid_m3;
    input        aclk;
    input        aresetn;


  wire           next_resp_stall;    
  reg   [3:0]    reg_tt_en;     

  wire           t_pop;   

  wire  [1:0]    next_ptr0;   
  wire  [1:0]    next_ptr1;   
  wire  [1:0]    next_ptr2;   
  wire  [1:0]    next_ptr3;   
  reg   [1:0]    ptr_sel;   
  reg   [3:0]    int_tt_en;   
  reg   [3:0]    shift;   
  wire  [3:0]    resp_valid_vector;   



  reg            resp_stall;    
  reg   [1:0]    ptr0;     
  reg   [1:0]    ptr1;     
  reg   [1:0]    ptr2;     
  reg   [1:0]    ptr3;     



 
   assign t_pop = resp_valid & resp_ready & resp_last;

   assign resp_valid_vector[0] = rvalid_m0;
   assign resp_valid_vector[1] = rvalid_m1;
   assign resp_valid_vector[2] = rvalid_m2;
   assign resp_valid_vector[3] = rvalid_m3;

   always @(resp_valid_vector or ptr0 or ptr1 or ptr2 or ptr3)
   begin : p_lrg_comb
        int_tt_en = {4{1'b0}};
        ptr_sel = {2{1'b0}};
        shift = {4{1'b0}};
        if (resp_valid_vector[ptr0] == 1'b1) 
        begin
                int_tt_en[ptr0] =1'b1;
                ptr_sel = ptr0;
                shift = 4'b1111;
        end
        else if (resp_valid_vector[ptr1] == 1'b1) 
        begin
                int_tt_en[ptr1] =1'b1;
                ptr_sel = ptr1;
                shift = 4'b1110;
        end
        else if (resp_valid_vector[ptr2] == 1'b1) 
        begin
                int_tt_en[ptr2] =1'b1;
                ptr_sel = ptr2;
                shift = 4'b1100;
        end
        else if (resp_valid_vector[ptr3] == 1'b1) 
        begin
                int_tt_en[ptr3] =1'b1;
                ptr_sel = ptr3;
                shift = 4'b1000;
        end
        
   end 


   assign next_ptr0 = shift[0] ? ptr1 : ptr0;
   assign next_ptr1 = shift[1] ? ptr2 : ptr1;
   assign next_ptr2 = shift[2] ? ptr3 : ptr2;
   assign next_ptr3 = shift[3] ? ptr_sel : ptr3;







    always @(posedge aclk or negedge aresetn)
    begin : p_ptr_seq
      if (!aresetn) 
      begin
           ptr0    <= 2'd0;
           ptr1    <= 2'd1;
           ptr2    <= 2'd2;
           ptr3    <= 2'd3;
      end else 
      begin
        if (t_pop)
         begin
             ptr0    <=   next_ptr0;
             ptr1    <=   next_ptr1;
             ptr2    <=   next_ptr2;
             ptr3    <=   next_ptr3;
         end
      end 
    end 



   assign next_resp_stall = (resp_valid & ~resp_ready);

   always @(posedge aclk or negedge aresetn)
     begin : p_stall_seq
       if (!aresetn)
         begin
          resp_stall <= 1'b0;
        end
       else
         begin
          resp_stall <= next_resp_stall;
        end
     end 

 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_en_seq
       if (!aresetn)
         begin
          reg_tt_en <= {4{1'b0}};
        end
       else if (next_resp_stall && !resp_stall)
         begin
          reg_tt_en <= int_tt_en;
        end
     end 
 
   assign tt_enable = resp_stall ? reg_tt_en : int_tt_en;


`ifdef ARM_ASSERT_ON


   assert_always #(0,0,"ERROR, LRG item 0 is not unique")
      ovl_lrg_qv_list_unique0
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (
                   (ptr0 != ptr1) &&
                   (ptr0 != ptr2) &&
                   (ptr0 != ptr3))
       );
   
   assert_always #(0,0,"ERROR, LRG item 1 is not unique")
      ovl_lrg_qv_list_unique1
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (
                   (ptr1 != ptr0) &&
                   (ptr1 != ptr2) &&
                   (ptr1 != ptr3))
       );
   
   assert_always #(0,0,"ERROR, LRG item 2 is not unique")
      ovl_lrg_qv_list_unique2
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (
                   (ptr2 != ptr0) &&
                   (ptr2 != ptr1) &&
                   (ptr2 != ptr3))
       );
   
   assert_always #(0,0,"ERROR, LRG item 3 is not unique")
      ovl_lrg_qv_list_unique3
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (
                   (ptr3 != ptr0) &&
                   (ptr3 != ptr1) &&
                   (ptr3 != ptr2))
       );
   

   reg [3:0] ptr_sel_reg;
   reg       start;
   reg [3:0] ptr0_reg;
   reg [3:0] ptr1_reg;
   reg [3:0] ptr2_reg;
   reg [3:0] ptr3_reg;

   always @(posedge aclk or negedge aresetn)
     begin : p_psel_reg_seq
       if (!aresetn)
         begin
          ptr_sel_reg <= 4'b0;
          start       <= 1'b0;
          ptr0_reg    <= 2'd0;
          ptr1_reg    <= 2'd1;
          ptr2_reg    <= 2'd2;
          ptr3_reg    <= 2'd3;
        end
       else
         begin
          ptr_sel_reg <= ptr_sel;
          start       <= t_pop;
          ptr0_reg    <= ptr0;
          ptr1_reg    <= ptr1;
          ptr2_reg    <= ptr2;
          ptr3_reg    <= ptr3;
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
   

   assert_implication #(0,0,"ERROR, LRG list item 3 incorrectly updated")
     ovl_lrg_list_update3
      (
       .clk       (aclk),
       .reset_n   (aresetn),
       .antecedent_expr (start),
       .consequent_expr ((ptr3 == ptr_sel_reg)) 
     );


   assert_never #(1,0,"ERROR, ptr0 illegal value")
    ovl_ptr0_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr0 >= 4));

   assert_never #(1,0,"ERROR, ptr1 illegal value")
    ovl_ptr1_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr1 >= 4));

   assert_never #(1,0,"ERROR, ptr2 illegal value")
    ovl_ptr2_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr2 >= 4));

   assert_never #(1,0,"ERROR, ptr3 illegal value")
    ovl_ptr3_too_large
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (ptr3 >= 4));


`endif

  endmodule

