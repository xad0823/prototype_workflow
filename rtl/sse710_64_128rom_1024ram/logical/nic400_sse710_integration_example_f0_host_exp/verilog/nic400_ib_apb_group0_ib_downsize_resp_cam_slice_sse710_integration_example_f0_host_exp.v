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

module nic400_ib_apb_group0_ib_downsize_resp_cam_slice_sse710_integration_example_f0_host_exp
  (
    aresetn,
    aclk,

    matchid,        
    hazardid,       

    store,
    push_slice,
    pop_slice,
    update,
    match_pointer,

    hazard_in,
    hazard_pointer,

    n_response,
    bresp_in,

    hazard,
    match,
    valid,
    bresp_out

  );

 `include "nic400_ib_apb_group0_ib_defs_sse710_integration_example_f0_host_exp.v"


  input                 aresetn;
  input                 aclk;

  input [17:0]          matchid;
  input [17:0]          hazardid;

  input                 store;
  input                 push_slice;
  input                 pop_slice;
  input                 update;

  input                 hazard_pointer;
  input                 match_pointer;
  input                 hazard_in;

  input [3:0]           n_response;
  input [1:0]           bresp_in;

  output                hazard;
  output                match;
  output                valid;
  output [1:0]          bresp_out;


  reg [17:0]            id_reg;
  reg                   pointer_reg;

  reg                   hazard_reg;
  reg                   valid_reg;
  reg                   last_reg;
  reg [3:0]             n_response_reg;
  reg [1:0]             bresp_reg;


  wire [17:0]           next_id_reg;
  wire                  next_pointer_reg;

  wire                  next_hazard_reg;
  wire                  next_valid_reg;
  wire                  next_last_reg;
  wire [3:0]            next_n_response_reg;
  wire [1:0]            next_bresp_reg;

  wire                  allowed_to_match;
  wire                  bid_match;
  wire                  awid_match;
  wire                  match_i;
  wire                  last_reg_wr_en;
  wire                  hazard_reg_wr_en;
  wire                  valid_reg_wr_en;
  wire                  n_response_reg_wr_en;
  wire                  default_reg_wr_en;

  wire                  pointer_match;


 assign bid_match = (matchid == id_reg);
 assign awid_match = (hazardid == id_reg);
 
 assign allowed_to_match = valid_reg && ~hazard_reg && ~|n_response_reg;
 assign match_i = allowed_to_match && bid_match;
 assign match   = match_i;
 
 assign hazard = awid_match && last_reg && valid_reg && ~(match_i && pop_slice);

 assign default_reg_wr_en = (store && push_slice);

 assign next_id_reg = hazardid;

 always @(posedge aclk)
   begin : id_seq
      if (default_reg_wr_en)
         id_reg <= next_id_reg;
   end 

 assign next_pointer_reg = hazard_pointer;

  always @(posedge aclk)
   begin : pointer_seq
      if (default_reg_wr_en)
         pointer_reg <= next_pointer_reg;
   end 

 assign next_last_reg = (store && push_slice) ? 1'b1 : 
                        ((awid_match) ? 1'b0 : last_reg);

 assign last_reg_wr_en = (default_reg_wr_en || (awid_match && valid_reg && push_slice));
 
  always @(posedge aclk)
   begin : last_seq
      if (last_reg_wr_en)
         last_reg <= next_last_reg;
   end 

 assign pointer_match = (pointer_reg == match_pointer);

 assign next_hazard_reg = (store && push_slice) ? hazard_in : 1'b0;

 assign hazard_reg_wr_en = (default_reg_wr_en || (pointer_match && valid_reg && pop_slice));

  always @(posedge aclk)
   begin : hazard_seq
      if (hazard_reg_wr_en)
         hazard_reg <= next_hazard_reg;
   end 


 assign next_valid_reg = (store && push_slice) || (|n_response_reg); 

 assign valid_reg_wr_en = default_reg_wr_en || (match_i && pop_slice);

   always @(posedge aclk or negedge aresetn)
   begin : valid_seq
      if (!aresetn) 
         valid_reg <= 1'b0;
      else if (valid_reg_wr_en)
         valid_reg <= next_valid_reg;
   end 

  assign valid = valid_reg;

  assign next_n_response_reg = (store && push_slice) ? n_response : (n_response_reg - {{3{1'b0}}, 1'b1});
  assign next_bresp_reg = (store && push_slice) ? 2'b0 : (bresp_in | bresp_reg);

  assign n_response_reg_wr_en = (bid_match && ~hazard_reg && update && (|n_response_reg)) || (store && push_slice);

  always @(posedge aclk or negedge aresetn)
   begin : two_resp_seq
     if (!aresetn) begin
         n_response_reg <= 4'b0; 
         bresp_reg <= 2'b0;
     end else if (n_response_reg_wr_en) begin
         n_response_reg <= next_n_response_reg;
         bresp_reg <= next_bresp_reg;
     end
   end 
   
   assign bresp_out = {2{match_i}} & bresp_reg;

`ifdef ARM_ASSERT_ON


  assert_never #(0,0,"n_resp reg is always zero when slice is invalid")
  ovl_n_resp_val
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        (~valid_reg && |n_response_reg)
     );

`endif

`include "nic400_ib_apb_group0_ib_undefs_sse710_integration_example_f0_host_exp.v"
endmodule


