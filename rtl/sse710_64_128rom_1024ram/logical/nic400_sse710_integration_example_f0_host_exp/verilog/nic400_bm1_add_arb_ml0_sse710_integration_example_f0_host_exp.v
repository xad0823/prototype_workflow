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

`include "reg_slice_axi_defs.v"

module nic400_bm1_add_arb_ml0_sse710_integration_example_f0_host_exp
  (
    a_sel,
    a_valid_vector,
    aready,
    mask,
    qv0,
    qv1,
    aclk,
    aresetn
  );





  parameter REQUESTS      = 2;
  parameter QOS_WIDTH     = 4;


  output [1:0]      a_sel;
  input  [1:0]      a_valid_vector;
  input             aready;
  input  [1:0]      mask;
  input  [3:0]      qv0;
  input  [3:0]      qv1;

  input             aclk;
  input             aresetn;


  wire              update;    
  wire  [1:0]       a_sel;      
  wire              valid_op;    
  wire              next_stall;    
  wire              sel_en;    
  wire  [1:0]       int_sel;    

  wire  [(REQUESTS*QOS_WIDTH)-1:0]  request_qos;
  wire  [REQUESTS-1:0]              request;
  wire  [QOS_WIDTH-1:0]             max_qos;
  wire  [REQUESTS-1:0]              is_highest_qos;
  wire  [1:0]       qv_valids ;    
 

  reg               stall;    
  reg   [1:0]       reg_sel;     





   assign valid_op = |a_sel;
   assign next_stall = (valid_op & ~aready);

   always @(posedge aclk or negedge aresetn)
     begin : p_stall_seq
       if (!aresetn)
         begin
          stall <= 1'b0;
        end
       else
         begin
          stall <= next_stall;
        end
     end 


   assign request_qos = {qv1 ,
                        qv0};

  assign qv_valids = a_valid_vector;

nic400_bm1_qv_cmp_sse710_integration_example_f0_host_exp #(.REQUESTS (REQUESTS), .QOS_WIDTH (QOS_WIDTH)) u_highest_qos (
 .request_valids (qv_valids),   
 .request_qos    (request_qos),      
 .highest_mh     (is_highest_qos),
 .highest_qos    (max_qos)
);


assign request = is_highest_qos & ~mask;


assign update = (|request &  ~stall);

nic400_bm1_lrg_arb_sse710_integration_example_f0_host_exp #(.WIDTH(REQUESTS)) u_lrg_arb (
  .aclk       (aclk),
  .aresetn    (aresetn),
  .update_en  (update),
  .request    (request),
  .grant      (int_sel)
);


  






   always @(posedge aclk or negedge aresetn)
     begin : p_a_sel_seq
       if (!aresetn)
         begin
          reg_sel <= {2{1'b0}};
        end
       else if (sel_en)
         begin
          reg_sel <= int_sel;
        end
     end 
 
   assign sel_en = (next_stall & ~stall);

   assign a_sel = stall ? reg_sel : int_sel;


`ifdef ARM_ASSERT_ON

   assert_zero_one_hot #(0,2,0,"ERROR, More than one slave interface arbitrated")
     ovl_slave_if_arb
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (a_sel)
        );

   assert_never #(0,0,"ERROR, No transaction was arbitrated when expected") 
      ovl_lrg_always_arb
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr ((|(a_valid_vector & ~mask)) && (~|a_sel))
       );

   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 0")
     ovl_high_qv_avail0
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[0]),
       .consequent_expr (max_qos >= qv0)
     );
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 1")
     ovl_high_qv_avail1
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[1]),
       .consequent_expr (max_qos >= qv1)
     );
   
`endif


  endmodule

`include "reg_slice_axi_undefs.v"


