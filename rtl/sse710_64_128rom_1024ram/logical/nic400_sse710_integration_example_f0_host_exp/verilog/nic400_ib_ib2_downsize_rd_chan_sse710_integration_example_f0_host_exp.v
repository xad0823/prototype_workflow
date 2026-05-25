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


module nic400_ib_ib2_downsize_rd_chan_sse710_integration_example_f0_host_exp
  (
  rvalid_m,
  rdata_m,
  rlast_m,
  rid_m,
  rresp_m,
  
  rready_s,
 
  rready_m,
  
  rvalid_s,
  rdata_s,
  rlast_s,
  rid_s,
  rresp_s,
  
  rbeats_s,
  

  arvalid_m,
  arready_m,

  archannel_data,
  archannel_valid,
  archannel_ready,
  
  arsize,
  araddr,
  arid,
  
  aclk, 
  aresetn
  );

`include "nic400_ib_ib2_defs_sse710_integration_example_f0_host_exp.v"
`include "Axi.v"

  input                   aclk;
  input                   aresetn;

  input                   archannel_valid;
  output                  archannel_ready;
  input [11:0]            archannel_data;

    
  output                  arvalid_m;
  input                   arready_m;
  
  input [2:0]             arsize;
  input [2:0]             araddr;
  input [17:0]            arid;

  
  input                   rready_s;               

  output                  rvalid_s;
  output [63:0]           rdata_s;
  output [17:0]           rid_s;
  output [1:0]            rresp_s;
  output                  rlast_s;
  
  output [1:0]            rbeats_s;

  output                  rready_m;               

  input                   rvalid_m;
  input [31:0]            rdata_m;
  input [17:0]            rid_m;
  input [1:0]             rresp_m;
  input                   rlast_m;

 
   wire [1:0]             match_bus; 
   wire [1:0]             hazard_bus;
   wire [1:0]             valid_bus;
   wire [1:0]             last_addr_match_bus;
   wire [1:0]             beat_complete_slice_bus;

   reg                    hazard_pointer;
   reg                    match_pointer;

   wire                   hazard;           
   wire                   last_addr_match;  
   wire                   beat_complete_slice;           

   reg [1:0]              store;

   wire                   archannel_hndshk;
   wire                   rchannel_hndshk;

   wire                   push_slice;
   wire                   pop_slice;          
   wire                   update;
   wire [1:0]             clear_slice;

   wire                   beat_complete;

   
   wire                   bypass;

   wire [1:0]             rbeats;
   
   
   
 
   wire                   rlast_m;
   wire [17:0]            rid_m;
   wire [1:0]             rresp_m;
   
   wire                   rlast_out;
   wire                   rlast_out_masked;
   
   wire [24:0]            ar_cam_data;
   
   wire [11:0]            ar_channel_data;

   wire                   cam_update;




    
  
   wire [1:0]             beat_number0;
  
   wire [1:0]             beat_number1;
       
   wire [1:0]             rresp_cam;
   wire                   mask_last;
   wire [31:0]            rdata_cam;
  
   wire [31:0]            rdata_cam0;
  
   wire [31:0]            rdata_cam1;
  
   wire [1:0]             rresp_cam0;
  
   wire [1:0]             rresp_cam1;
  
   wire                   mask_last0;
  
   wire                   mask_last1;
   
   wire [63:0]            rdata_out;
   wire [1:0]             rresp_out;
   
   
   wire                   fixed_dwnsize;   
   
   wire [3:0]                n_response;
   
   wire [2:0]             addr_mask;
   
   wire [3:0]                next_n_response_reg;
   wire                   n_response_reg_wr_en;
   wire                   slice_required;
    
    
    


   reg [2:0]              downsize;

   reg [3:0]                 n_response_reg;


   assign rid_s   = rid_m;
   assign rdata_s = rdata_out;
   assign rresp_s = rresp_out;
   assign rlast_s = rlast_out_masked;
   
   assign rbeats_s = rbeats;
     



   assign hazard = |hazard_bus;

   assign last_addr_match = |(last_addr_match_bus & match_bus);

   assign beat_complete_slice = |(beat_complete_slice_bus & match_bus);

   assign rbeats = beat_number0
              |  beat_number1;
   
   assign rdata_cam = rdata_cam0
              |  rdata_cam1;
   

   
   assign rresp_cam = rresp_cam0
              |  rresp_cam1;
   
   assign mask_last = mask_last0
              |  mask_last1;

   


   assign rdata_out[63:32] = rdata_m;
  
    
   assign rdata_out[31:0] = rdata_cam[31:0];
  

   assign rlast_out = last_addr_match  && rlast_m;
   
   assign rlast_out_masked = rlast_out & ~mask_last;
   
   assign rresp_out = rresp_cam;
   

  always @(archannel_data)
    begin : downsize_mask_p
      case (archannel_data[2:0])
         `AXI_ASIZE_8    : downsize = {3{1'b0}};
         `AXI_ASIZE_16   : downsize = {{2{1'b0}},{1'b1}};
         `AXI_ASIZE_32   : downsize = {{1{1'b0}},{2'b11}};
         `AXI_ASIZE_64   : downsize = {{3'b111}};
         `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : downsize = {3{1'b0}};    
        default : downsize = 3'bx;
      endcase
    end
    
    
    assign ar_cam_data = {arid,araddr,arsize[1:0],fixed_dwnsize,bypass};
    
    assign ar_channel_data = {downsize,archannel_data[11:3]};
    

   
   assign n_response = archannel_data[11:8];
   
   
   assign addr_mask = archannel_data[5:3];
   
   
   
    assign bypass = (archannel_data[2:0] == arsize[2:0]) & (~|n_response);

   
   assign fixed_dwnsize = (|n_response) & (downsize[2]) & (~|addr_mask);
      
   
   assign next_n_response_reg = n_response; 

   assign n_response_reg_wr_en =  (archannel_hndshk);


   always @(posedge aclk or negedge aresetn)
     begin : next_resp_seq
       if (!aresetn) 
          n_response_reg <= 4'b0;
      else if (n_response_reg_wr_en)
           n_response_reg <= next_n_response_reg;
   end 

   assign arvalid_m = archannel_valid & ((~&valid_bus) | ~slice_required);
   assign archannel_ready = arready_m & ((~&valid_bus) | ~slice_required); 

   assign archannel_hndshk = archannel_ready && archannel_valid;

   assign slice_required = (~|n_response_reg) | ((downsize[2]) & (~|addr_mask));
   assign push_slice = archannel_hndshk & slice_required;
   
   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus[0])
           store = 2'b01;
         else if (!valid_bus[1])
            store = 2'b10;
        else
           store = match_bus;
      end 
      
   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          2'b0 : hazard_pointer = 1'b0;
           2'd1 : hazard_pointer = 1'd0;
          2'd2 : hazard_pointer = 1'd1;
         default : hazard_pointer = 1'bx;
       endcase
     end
     
   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          2'b0 : match_pointer = 1'b0;
           2'd1 : match_pointer = 1'd0;
          2'd2 : match_pointer = 1'd1;
         default : match_pointer = 1'bx;
       endcase
     end

   assign beat_complete = (rlast_out | beat_complete_slice) && update;

   
   assign rready_m = (beat_complete | (~beat_complete_slice)) && rvalid_m;

   assign rvalid_s = beat_complete_slice && rvalid_m;
   

   assign rchannel_hndshk = rvalid_s && rready_s;
      
   assign update = rchannel_hndshk;

   assign clear_slice = {2{update}} & match_bus;

   assign cam_update = rvalid_m & rready_m;

   assign pop_slice = update && rlast_out;


    
     nic400_ib_ib2_downsize_rd_cam_slice_sse710_integration_example_f0_host_exp u_downsize_rd_cam_slice_0
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[0]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[0]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[0]),
        .match                (match_bus[0]),
        .valid                (valid_bus[0]),
        .last_addr_match      (last_addr_match_bus[0]),
        .beat_complete        (beat_complete_slice_bus[0]),
        .beat_number          (beat_number0),
        
        .rdata_cam            (rdata_cam0),
        
        .rresp_cam            (rresp_cam0),
        
        .mask_last            (mask_last0)
     );
     
     nic400_ib_ib2_downsize_rd_cam_slice_sse710_integration_example_f0_host_exp u_downsize_rd_cam_slice_1
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[1]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[1]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[1]),
        .match                (match_bus[1]),
        .valid                (valid_bus[1]),
        .last_addr_match      (last_addr_match_bus[1]),
        .beat_complete        (beat_complete_slice_bus[1]),
        .beat_number          (beat_number1),
        
        .rdata_cam            (rdata_cam1),
        
        .rresp_cam            (rresp_cam1),
        
        .mask_last            (mask_last1)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_zero_one_hot #(0,2,0,"More than one Rd Channel Slice matched")
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({2{rchannel_hndshk}} & match_bus)
     );


  assert_zero_one_hot #(0,2,0,"More than one R Channel Slice hazard")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({2{archannel_hndshk}} & hazard_bus)
     );


  wire [17:0]   cam_id_reg [0:1];

  assign cam_id_reg[0] = u_downsize_rd_cam_slice_0.id_reg;


  assert_implication #(0,0,"CAM 0 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_0_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_0.pointer_reg] && (cam_id_reg[0] == cam_id_reg[u_downsize_rd_cam_slice_0.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 0 is last but is pointed to by another valid CAM")
  ovl_cam_0_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_rd_cam_slice_0.last_reg),
     .consequent_expr  (!(
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 0)))
     );
  
  assign cam_id_reg[1] = u_downsize_rd_cam_slice_1.id_reg;


  assert_implication #(0,0,"CAM 1 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_1_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_1.pointer_reg] && (cam_id_reg[1] == cam_id_reg[u_downsize_rd_cam_slice_1.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 1 is last but is pointed to by another valid CAM")
  ovl_cam_1_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_rd_cam_slice_1.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 1)))
     );
  
     
     wire        arsize_out_range;
 
     assign      arsize_out_range = archannel_valid && (archannel_data[2:0] > `AXI_ASIZE_64);
                                                                                             
     wire        illegal_downsize;        

     assign illegal_downsize =  (downsize == {3{1'b0}}) & arsize_out_range;

     assert_never #(`OVL_FATAL,
                    `OVL_ASSERT,
                    "Input archannel_data[2:0] to downsize calculation has gone out of legal range")
     ovl_downsize_illegal_asize
     (
       .clk        (aclk),
       .reset_n    (aresetn),
       .test_expr  (illegal_downsize)
     );


`endif

endmodule

`include "nic400_ib_ib2_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"

