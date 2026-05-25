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



module nic400_bm1_wr_st_tt_s0_sse710_integration_example_f0_host_exp
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


    output [3:0] aw_enable;     
    output [3:0] tt_enable;     
    output [3:0] wr_enable;     
    input  [3:0] asel;     
    input        aready;     
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid; 
    input        resp_ready;
    input        aclk;
    input        aresetn;





  wire  [3:0]    next_tt_reg;   
  wire  [3:0]    int_tt_en;   
  wire           asel_mask;   

  wire           add_push;           
  wire           next_resp_stall;    



  reg          valid_add;   
  reg   [3:0]    tt_reg;   
  reg            resp_stall;   
  reg            asel_reg;   
  reg            aready_reg;   

  reg   [3:0]    reg_tt_en;     


   assign asel_mask = |asel;
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


   assign next_tt_reg = add_push ? asel 
                        : (resp_valid && resp_ready) ? {4{1'b0}}
                        : tt_reg;


   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn) 
         begin
                tt_reg <= {4{1'b0}};
         end
       else if ((add_push) || (resp_valid && resp_ready))
         begin
                tt_reg <= next_tt_reg;
         end
     end 

  always @(posedge aclk or negedge aresetn)
     begin : p_va_seq
       if (!aresetn) 
         begin
                valid_add <= 1'b0;
         end
       else
         begin
           if (add_push)
                valid_add <= 1'b1;
           if (wvalid && wready && wlast)
                valid_add <= 1'b0;
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

   
   assign aw_enable = asel;

   assign wr_enable = tt_reg & {4{valid_add}};
   assign int_tt_en = tt_reg;


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



`endif 

  endmodule

