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



module nic400_bm0_wr_ss_tt_s0_sse710_integration_example_f0_cvm
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

    aclk,
    aresetn
  );


    output [1:0] aw_enable;     
    output [1:0] tt_enable;     
    output [1:0] wr_enable;     
    input  [1:0] asel;     
    input        aready;     
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid; 
    input        resp_ready;
    input        aclk;
    input        aresetn;




  reg   [1:0]    next_last_cnt;    
  wire  [1:0]    next_valid_add;     
  wire  [1:0]    next_tt_reg;   
  reg   [1:0]    next_tt_cnt;    
  reg            dec_tt_cnt;    

  wire  [1:0]    int_tt_en;    
  wire           next_empty;    
  wire  [1:0]    asel_mask;   
  wire  [1:0]    asel_masked;    
  wire           asel_int;    

  wire           add_push;           
  wire           aw_enable_bit;      
  wire           next_add_stall;     
  wire           next_resp_stall;    



  reg [1:0]         valid_add;   
  reg   [1:0]    last_cnt;   
  reg   [1:0]    tt_cnt;   
  reg            add_stall;
  reg   [1:0]    tt_reg;   
  reg            resp_stall;   
  reg            asel_reg;   
  reg            aready_reg;   

  wire           valid_add_en;
  reg            empty;     

  reg   [1:0]    reg_tt_en;     



   assign asel_mask = tt_reg | {2{empty}};
   assign asel_masked = (asel & asel_mask);
   assign asel_int = |asel_masked & aw_enable_bit;

   always @(posedge aclk or negedge aresetn)
     begin : p_add_push_seq
       if (!aresetn)
         begin
             asel_reg  <= 1'b0;
             aready_reg <= 1'b0;
         end
       else
         begin
            if (asel_int || asel_reg)
             begin
                 asel_reg  <= asel_int;
             end
            if (aready_reg || aready)
             begin
                aready_reg   <= aready;
             end
         end
     end 

   assign add_push = ((asel_int & ~asel_reg) | (asel_int & asel_reg & aready_reg));


   always @(add_push or resp_valid or resp_ready or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        dec_tt_cnt = 1'b0;
        if (add_push && !(resp_valid && resp_ready)) 
                next_tt_cnt = tt_cnt + 1'b1;
        if (!(add_push) && (resp_valid && resp_ready))  begin
                next_tt_cnt = tt_cnt - 1'b1;
                dec_tt_cnt = 1'b1;
        end
     end 

   always @(wvalid or wready or wlast or resp_valid or resp_ready or last_cnt)
     begin : p_next_last_comb
        next_last_cnt = last_cnt;
        if ((wvalid && wready && wlast) && !(resp_valid && resp_ready)) 
                next_last_cnt = last_cnt + 1'b1;
        if (!(wvalid && wready && wlast) && (resp_valid && resp_ready)) 
                next_last_cnt = last_cnt - 1'b1;
     end 

    assign next_tt_reg = (add_push) ? asel 
                        : (tt_cnt == 2'b01 && dec_tt_cnt) ? {2{1'b0}}
                        : tt_reg;

   assign next_empty = (tt_cnt == 2'b01) && dec_tt_cnt;


   assign next_valid_add[0] = (add_push & ~(wvalid & wready & wlast)) ? 1'b1 :
                              (~add_push & (wvalid & wready & wlast)) ? valid_add[1] :
                               valid_add[0];
   assign next_valid_add[1] = (add_push & ~(wvalid & wready & wlast)) ? valid_add[0] :
                              (~add_push & (wvalid & wready & wlast)) ? 1'b0 :
                               valid_add[1];

   assign valid_add_en = (add_push | (wvalid & wready & wlast));


  always @(posedge aclk or negedge aresetn)
     begin : p_tt_last_seq
       if (!aresetn) begin 
             last_cnt <= {2{1'b0}};
       end
       else 
        begin
             last_cnt <= next_last_cnt;
       end
     end 

  always @(posedge aclk or negedge aresetn)
     begin : p_val_seq
       if (!aresetn) begin 
             valid_add <= 2'b00;
       end
       else if (valid_add_en)
        begin
             valid_add <= next_valid_add;
       end
     end 


   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq 
       if (!aresetn) 
         begin
             tt_reg <= {2{1'b0}};
             tt_cnt <= {2{1'b0}};
             empty <= 1'b1;
         end
       else if ((add_push) || (resp_valid && resp_ready))
         begin
             tt_reg <= next_tt_reg;
             tt_cnt <= next_tt_cnt;
             empty <= next_empty;
         end
       end 
 


   assign next_add_stall = (asel_int & ~aready);
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

   assign aw_enable_bit = add_stall ? 1'b1 : (~valid_add[1]);
   assign aw_enable = asel_masked & {2{aw_enable_bit}};

   assign wr_enable = tt_reg & {2{valid_add[0]}};
   assign int_tt_en = tt_reg;


    always @(posedge aclk or negedge aresetn)
     begin : p_tt_en_seq
       if (!aresetn)
         begin
          reg_tt_en <= {2{1'b0}};
        end
       else if (next_resp_stall && !resp_stall)
         begin
          reg_tt_en <= int_tt_en;
        end
     end 
 
   assign tt_enable = resp_stall ? reg_tt_en : int_tt_en;


`ifdef ARM_ASSERT_ON



`endif 

  endmodule

