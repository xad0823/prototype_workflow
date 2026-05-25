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

module nic400_ib_stm_axim_ib_upsize_wr_resp_block_sse710_sys_apb
  (
  bvalid_m,
  bready_s,
  bresp_m,
  bid_m,

  bchannel_ready,

  bchannel_valid,
  bchannel_data,

  bvalid_s,
  bready_m,
  bid_s,
  bresp_s,

  aclk,
  aresetn
  );

`include "nic400_ib_stm_axim_ib_defs_sse710_sys_apb.v"

  input                   aclk;
  input                   aresetn;

  output                  bchannel_ready;   

  output                  bvalid_s;          
  output                  bready_m;          
  output [11:0]           bid_s;             
  output [1:0]            bresp_s;           

  input                   bvalid_m;
  input                   bready_s;
  input [11:0]            bid_m;
  input [1:0]             bresp_m;

  input                   bchannel_valid;
  input [12:0]            bchannel_data;


   wire [2:0]             match_bus;
   wire [2:0]             hazard_bus;

   wire [2:0]             valid_bus;
   wire                   match;              
   wire                   hazard;             

   wire                   bready_m_i;
   wire                   bhndshk;

   wire                   push_slice;
   wire                   pop_slice;          
   wire                   update;
   

   wire [11:0]            awid;
   wire                   n_response;
   wire                   next_bchannel_ready;
   
   wire [1:0]             bresp_out_0;
   wire [1:0]             bresp_out_1;
   wire [1:0]             bresp_out_2;
    

   reg [1:0]              hazard_pointer;
   reg [1:0]              match_pointer;

   reg [2:0]              store;

   reg                    bchannel_ready_i;  


   assign awid = bchannel_data[12:1];
   assign n_response = bchannel_data[0];

   assign match = |match_bus;

   assign hazard = |hazard_bus;

   assign next_bchannel_ready = ~(&(valid_bus | (store & {3{push_slice}}))) || (pop_slice);

   always @(posedge aclk or negedge aresetn)
    begin : bchannel_seq
      if (!aresetn)
         bchannel_ready_i <= 1'b0;
      else
         bchannel_ready_i <= next_bchannel_ready;
    end 

   assign bchannel_ready = bchannel_ready_i;
   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus[0])
           store = 3'b001;
         else if (!valid_bus[1])
            store = 3'b010;
         else if (!valid_bus[2])
            store = 3'b100;
        else
            store = match_bus;
      end 

   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          3'b0 : hazard_pointer = 2'b0;
           3'd1 : hazard_pointer = 2'd0;
          3'd2 : hazard_pointer = 2'd1;
          3'd4 : hazard_pointer = 2'd2;
         default : hazard_pointer = 2'bx;
       endcase
     end

   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          3'b0 : match_pointer = 2'b0;
           3'd1 : match_pointer = 2'd0;
          3'd2 : match_pointer = 2'd1;
          3'd4 : match_pointer = 2'd2;
         default : match_pointer = 2'bx;
       endcase
     end

    assign push_slice = bchannel_ready_i && bchannel_valid;

    assign bhndshk = bvalid_m && bready_m_i;
    assign update = bhndshk;
    assign pop_slice = update && match;


    assign bready_m_i = bvalid_m && (bready_s || ~match);
    assign bready_m   = bready_m_i;
    assign bid_s = bid_m;
    assign bresp_s = (bresp_m
                      |  bresp_out_0
                      |  bresp_out_1
                      |  bresp_out_2 );

    assign bvalid_s = (bvalid_m && match);



    

     nic400_ib_stm_axim_ib_upsize_resp_cam_slice_sse710_sys_apb u_upsize_resp_cam_slice_0
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[0]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[0]),
        .match                (match_bus[0]),
        .valid                (valid_bus[0]),
        .bresp_out            (bresp_out_0)
     );
     

     nic400_ib_stm_axim_ib_upsize_resp_cam_slice_sse710_sys_apb u_upsize_resp_cam_slice_1
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[1]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[1]),
        .match                (match_bus[1]),
        .valid                (valid_bus[1]),
        .bresp_out            (bresp_out_1)
     );
     

     nic400_ib_stm_axim_ib_upsize_resp_cam_slice_sse710_sys_apb u_upsize_resp_cam_slice_2
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[2]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[2]),
        .match                (match_bus[2]),
        .valid                (valid_bus[2]),
        .bresp_out            (bresp_out_2)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_zero_one_hot #(`OVL_FATAL,3,0,"More than one B Channel Slice matched")
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({3{bvalid_m}} & match_bus)
     );


  assert_zero_one_hot #(`OVL_FATAL,3,0,"More than one B Channel Slice hazard")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({3{bchannel_valid}} & hazard_bus)
     );


  assert_never #(`OVL_FATAL,`OVL_ASSERT,"No slices are valid and there is an incoming transaction")
  ovl_bslice_none_valid
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        (~|valid_bus && bvalid_m)
     );


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"ex_okay reponses lost")
  ovl_exokay_lost
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (bvalid_m && bresp_m == 2'b01),
     .consequent_expr  (match && bresp_s == 2'b01)
     );


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"B Channel HndShk Error")
  ovl_input_hndshk_error
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (bchannel_valid),
     .consequent_expr  (bchannel_ready_i)
     );


   assert_fifo_index #(`OVL_FATAL, 3, 1, 1, 0,"ERROR, BChannel Look-Up under or overflowed")
      ovl_bchannel_fifo_index
         (
           .clk       (aclk),
           .reset_n   (aresetn),
           .push      (bchannel_ready_i && bchannel_valid),
           .pop       (bvalid_s && bready_s)
         );


  wire [11:0] cam_id_reg [0:2];

  assign cam_id_reg[0] = u_upsize_resp_cam_slice_0.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 0 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_0_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_upsize_resp_cam_slice_0.hazard_reg),
     .consequent_expr  (valid_bus[u_upsize_resp_cam_slice_0.pointer_reg] && (cam_id_reg[0] == cam_id_reg[u_upsize_resp_cam_slice_0.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 0 is last but is pointed to by another valid CAM")
  ovl_cam_0_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_upsize_resp_cam_slice_0.last_reg),
     .consequent_expr  (!(
                          (valid_bus[1] && u_upsize_resp_cam_slice_1.hazard_reg && u_upsize_resp_cam_slice_1.pointer_reg == 0) ||
                          (valid_bus[2] && u_upsize_resp_cam_slice_2.hazard_reg && u_upsize_resp_cam_slice_2.pointer_reg == 0)))
     );
  
  assign cam_id_reg[1] = u_upsize_resp_cam_slice_1.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 1 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_1_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_upsize_resp_cam_slice_1.hazard_reg),
     .consequent_expr  (valid_bus[u_upsize_resp_cam_slice_1.pointer_reg] && (cam_id_reg[1] == cam_id_reg[u_upsize_resp_cam_slice_1.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 1 is last but is pointed to by another valid CAM")
  ovl_cam_1_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_upsize_resp_cam_slice_1.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_upsize_resp_cam_slice_0.hazard_reg && u_upsize_resp_cam_slice_0.pointer_reg == 1) ||
                          (valid_bus[2] && u_upsize_resp_cam_slice_2.hazard_reg && u_upsize_resp_cam_slice_2.pointer_reg == 1)))
     );
  
  assign cam_id_reg[2] = u_upsize_resp_cam_slice_2.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 2 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_2_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_upsize_resp_cam_slice_2.hazard_reg),
     .consequent_expr  (valid_bus[u_upsize_resp_cam_slice_2.pointer_reg] && (cam_id_reg[2] == cam_id_reg[u_upsize_resp_cam_slice_2.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 2 is last but is pointed to by another valid CAM")
  ovl_cam_2_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_upsize_resp_cam_slice_2.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_upsize_resp_cam_slice_0.hazard_reg && u_upsize_resp_cam_slice_0.pointer_reg == 2) ||
                          (valid_bus[1] && u_upsize_resp_cam_slice_1.hazard_reg && u_upsize_resp_cam_slice_1.pointer_reg == 2)))
     );
  

`endif

`include "nic400_ib_stm_axim_ib_undefs_sse710_sys_apb.v"

endmodule
