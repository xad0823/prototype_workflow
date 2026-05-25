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

module nic400_switch2_add_arb_ml3_sse710_main
  (
    a_sel,
    a_valid_vector,
    aready,
    mask,
    qv0,
    qv1,
    qv2,
    qv3,
    qv4,
    qv5,
    qv6,
    aclk,
    aresetn
  );





  parameter REQUESTS      = 7;
  parameter QOS_WIDTH     = 4;


  output [6:0]      a_sel;
  input  [6:0]      a_valid_vector;
  input             aready;
  input  [6:0]      mask;
  input  [3:0]      qv0;
  input  [3:0]      qv1;
  input  [3:0]      qv2;
  input  [3:0]      qv3;
  input  [3:0]      qv4;
  input  [3:0]      qv5;
  input  [3:0]      qv6;

  input             aclk;
  input             aresetn;


  wire              update;    
  wire  [6:0]       a_sel;      
  wire              valid_op;    
  wire              next_stall;    
  wire              sel_en;    
  wire  [6:0]       int_sel;    

  wire  [(REQUESTS*QOS_WIDTH)-1:0]  request_qos;
  wire  [REQUESTS-1:0]              request;
  wire  [QOS_WIDTH-1:0]             max_qos;
  wire  [REQUESTS-1:0]              is_highest_qos;
  wire  [6:0]       qv_valids ;    
 

  reg               stall;    
  reg   [6:0]       reg_sel;     





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


   assign request_qos = {qv6 ,
                        qv5 ,
                        qv4 ,
                        qv3 ,
                        qv2 ,
                        qv1 ,
                        qv0};

  assign qv_valids = a_valid_vector;

nic400_switch2_qv_cmp_sse710_main #(.REQUESTS (REQUESTS), .QOS_WIDTH (QOS_WIDTH)) u_highest_qos (
 .request_valids (qv_valids),   
 .request_qos    (request_qos),      
 .highest_mh     (is_highest_qos),
 .highest_qos    (max_qos)
);


assign request = is_highest_qos & ~mask;


assign update = (|request &  ~stall);

nic400_switch2_lrg_arb_sse710_main #(.WIDTH(REQUESTS)) u_lrg_arb (
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
          reg_sel <= {7{1'b0}};
        end
       else if (sel_en)
         begin
          reg_sel <= int_sel;
        end
     end 
 
   assign sel_en = (next_stall & ~stall);

   assign a_sel = stall ? reg_sel : int_sel;


`ifdef ARM_ASSERT_ON

   assert_zero_one_hot #(0,7,0,"ERROR, More than one slave interface arbitrated")
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
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 2")
     ovl_high_qv_avail2
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[2]),
       .consequent_expr (max_qos >= qv2)
     );
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 3")
     ovl_high_qv_avail3
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[3]),
       .consequent_expr (max_qos >= qv3)
     );
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 4")
     ovl_high_qv_avail4
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[4]),
       .consequent_expr (max_qos >= qv4)
     );
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 5")
     ovl_high_qv_avail5
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[5]),
       .consequent_expr (max_qos >= qv5)
     );
   
   assert_implication #(0, 0, "ERROR, Higher QV than selected available on port 6")
     ovl_high_qv_avail6
      (
       .clk             (aclk),
       .reset_n         (aresetn),
       .antecedent_expr (a_valid_vector[6]),
       .consequent_expr (max_qos >= qv6)
     );
   
`endif


  endmodule

`include "reg_slice_axi_undefs.v"


