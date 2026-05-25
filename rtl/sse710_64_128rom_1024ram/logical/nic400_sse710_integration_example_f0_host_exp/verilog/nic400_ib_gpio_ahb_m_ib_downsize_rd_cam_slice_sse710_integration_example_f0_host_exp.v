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

module nic400_ib_gpio_ahb_m_ib_downsize_rd_cam_slice_sse710_integration_example_f0_host_exp
  (
    aresetn,
    aclk,

    match_id,        

    store,
    push_slice,
    pop_slice,
    update,
    clear_slice,
    match_pointer,

    hazard_in,
    hazard_pointer,

    
    archannel_data,
    
    ar_cam_data,            

    rdata_m,
    rresp_m,
    rlast_m,

    hazard,
    match,
    last_addr_match,
    valid,
    beat_complete,
    beat_number,
    
    rdata_cam,
    
    rresp_cam,
    
    mask_last

  );

`include "nic400_ib_gpio_ahb_m_ib_defs_sse710_integration_example_f0_host_exp.v"
`include "Axi.v"


  input                  aresetn;
  input                  aclk;

  input [17:0]           match_id;

  input                  store;
  input                  push_slice;
  input                  pop_slice;
  input                  update;
  input                  clear_slice;

  input                  hazard_pointer;
  input                  match_pointer;
  input                  hazard_in;

  input [11:0]           archannel_data;
  input [24:0]           ar_cam_data;            

  input [31:0]           rdata_m;
  input [1:0]            rresp_m;
  input                  rlast_m;

  output                 hazard;
  output                 valid;
  output                 match;
  output                 last_addr_match;
  output                 beat_complete;
  output [1:0]           beat_number;
  
  output [31:0]          rdata_cam;
  
  output [1:0]           rresp_cam;
  
  output                 mask_last;

 

  reg [17:0]            id_reg;
  reg                   pointer_reg;
  reg                   hazard_reg;
  reg                   valid_reg;
  reg                   last_reg;
  reg [3:0]               n_response_reg;
  reg [2:0]             addr_next;
  reg [2:0]             addr_reg;
  reg [2:0]             addr_mask_reg;
  reg [1:0]             addr_mask_end_reg;
  reg [1:0]             size_reg;
  reg                   bypass_reg;
  reg [2:0]             downsize_reg;
  
  reg [3:0]             size_incr;
  
  reg [1:0]             beats_masked;
  reg [1:0]             addr_end_masked;
  
  reg                   fixed_mask_reg;

  
  reg [31:0]            rdata_reg;  

  reg [1:0]             rresp_reg;

  


  wire [17:0]           next_id_reg;
  wire                  next_pointer_reg;

  wire                  next_hazard_reg;
  wire                  next_valid_reg;
  wire                  next_last_reg;
  wire [3:0]               next_n_response_reg;
  wire [2:0]            next_addr_reg;
  wire [2:0]            next_addr_mask_reg;

  wire                  allowed_to_match;
  wire                  rid_match;
  wire                  arid_match;
  wire                  pointer_match;

  wire                  last_reg_wr_en;
  wire                  hazard_reg_wr_en;
  wire                  valid_reg_wr_en;
  wire                  n_response_reg_wr_en;
  wire                  default_reg_wr_en;
  wire                  addr_reg_wr;
  wire                  fixed_incr_addr;

  wire [1:0]            size_in;
  wire                  bypass_in;
  wire [2:0]            addr;
  wire [2:0]            addr_mask;
  wire [2:0]            addr_out;
  wire [3:0]               n_response;
  wire [1:0]            addr_mask_end;
  wire [17:0]           hazard_id;
  
  wire [2:0]            downsize;
  wire                  fixed_mask;
  
  wire [1:0]            beat_number;

  wire                  boundary_cross;
  wire [3:0]            addr_incr;
  wire                  can_complete;
  
  wire                  rdata_cam_valid;
  
  wire                  rresp_reg_en;
  
  wire [1:0]            rresp_reg_nxt;
  wire [1:0]            rresp_cam_nxt;
  
  wire                  data_select;
  
  wire                  rdata_reg_en;
  wire [31:0]           next_rdata_reg;

  wire                  last_addr_match_i;
  wire                  match_i;

 assign addr_mask     = archannel_data[2:0];
 assign addr_mask_end = archannel_data[4:3];
 assign n_response    = fixed_mask ? {4{1'b0}} : archannel_data[8:5];
 assign downsize      = archannel_data[11:9];

 assign bypass_in     = ar_cam_data[0];
 assign fixed_mask    = ar_cam_data[1];
 assign size_in       = ar_cam_data[3:2];
 assign addr          = ar_cam_data[6:4];
 assign hazard_id     = ar_cam_data[24:7];

    
 

 assign rid_match = (match_id == id_reg);
 assign arid_match = (hazard_id == id_reg);
 
 assign allowed_to_match = valid_reg && ~hazard_reg;
 assign match_i          = allowed_to_match && rid_match;
 assign match            = match_i;
 assign can_complete     = match_i && ~|n_response_reg;
 
 

 
  
  assign data_select = ~addr_out[2];
 
 assign rdata_reg_en   = ((data_select) && downsize_reg[2] && match_i) | clear_slice;
 assign next_rdata_reg = clear_slice ? 32'b0 : (update && match_i) ? rdata_m : rdata_reg;
 
 always @(posedge aclk or negedge aresetn)
   begin : r_data_seq
     if (!aresetn) begin
        rdata_reg <= 32'b0;
     end
     else if (rdata_reg_en) begin
        rdata_reg <= next_rdata_reg;
     end    
   end 
   
  
 
 assign rdata_cam[31:0] = (rdata_cam_valid ? rdata_reg : rdata_m) & {32{match_i}};

 assign rresp_reg_en = (update && match_i);
 
 always @(posedge aclk or negedge aresetn)
  begin : rresp_reg_seq
    if (!aresetn)
       rresp_reg <= 2'b01;
    else if (rresp_reg_en)
       rresp_reg <= rresp_reg_nxt;    
  end 
 
  assign rresp_reg_nxt = boundary_cross ? 2'b01 : rresp_cam_nxt;

  assign rresp_cam_nxt = (rresp_reg == 2'b01) ? rresp_m :
                         ((rresp_m != 2'b01) ? (rresp_reg | rresp_m) :
                         rresp_reg);
   
 always @(posedge aclk or negedge aresetn)
  begin : fixed_mask_seq
    if (!aresetn)
       fixed_mask_reg <= 1'b0;
    else if (default_reg_wr_en)
       fixed_mask_reg <= fixed_mask;    
  end 
  
  
  
  assign rdata_cam_valid = downsize_reg[2] & addr_out[2];
  
  assign rresp_cam = rresp_cam_nxt & {2{match_i}};
  
  assign mask_last = fixed_mask_reg & match_i;


 assign hazard = arid_match && last_reg && valid_reg && ~(can_complete && pop_slice);

 assign default_reg_wr_en = (store && push_slice);

 assign next_id_reg = hazard_id;

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

 assign next_last_reg = (store) ? 1'b1 : 
                        ((arid_match) ? 1'b0 : last_reg);

 assign last_reg_wr_en = (default_reg_wr_en || (arid_match && valid_reg && push_slice));
 
  always @(posedge aclk)
   begin : last_seq
      if (last_reg_wr_en)
         last_reg <= next_last_reg;
   end 

 assign pointer_match = (pointer_reg == match_pointer);

 assign next_hazard_reg = (store) ? hazard_in : 1'b0;

 assign hazard_reg_wr_en = (default_reg_wr_en || (pointer_match && valid_reg && pop_slice && rid_match));

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

  assign next_n_response_reg = (store && push_slice) ? n_response : (n_response_reg - 4'b0001);

  assign n_response_reg_wr_en =  (rid_match && ~hazard_reg && rlast_m && update) || default_reg_wr_en;

  always @(posedge aclk or negedge aresetn)
   begin : two_resp_seq
     if (!aresetn) 
         n_response_reg <= 4'b0;
     else if (n_response_reg_wr_en)
         n_response_reg <= next_n_response_reg;
   end 


  assign boundary_cross = |((addr_incr ^ {1'b0, addr_reg}) 
                          & ({1'b1, ~addr_mask_reg} | {1'b0,~downsize_reg}));
  
  always @(downsize_reg or addr_out or addr_mask_reg)
  begin : beats_masked_p
    
    beats_masked = {2{1'b0}};
    
    case (downsize_reg)
       3'd0    : beats_masked = (~addr_out[1:0]) & (addr_mask_reg[1:0]);
       3'd1    : beats_masked = ({{1{1'b0}}, ~addr_out[1]}) & (addr_mask_reg[1:0]);          
         
    endcase

  end  
  
  
  always @(downsize_reg or addr_mask_end_reg)
  begin : addr_end_masked_p
    
    addr_end_masked = {2{1'b0}};
    
    case (downsize_reg)
       3'd0    : addr_end_masked = (addr_mask_end_reg[1:0]);
       3'd1    : addr_end_masked = {{1{1'b0}}, addr_mask_end_reg[1]};          
        
    endcase
  end
  

  always @(size_reg)
  begin : size_incr_p
    case (size_reg)
       2'd0    : size_incr = {3'b0, 1'b1}; 
       2'd1    : size_incr = {2'b0, 2'b10};  
       2'd2    : size_incr = {1'b0, 3'b100};  
       2'd3    : size_incr = {3'b0, 1'b1};    
       default         : size_incr = {4'bx};
    endcase
  end

  assign addr_incr = {1'b0, addr_reg} + size_incr;

  always @(addr_reg or addr_mask_reg or addr_incr)
  begin : addr_reg_nxt_p
     integer index_i;
     for (index_i = 0; index_i < 3 ; index_i = index_i + 1)
     begin
       if (addr_mask_reg[index_i] == 1'b1)
         addr_next[index_i] = addr_incr[index_i];
       else
         addr_next[index_i] = addr_reg[index_i];
     end
   end 

  assign addr_reg_wr = default_reg_wr_en || (match_i && update);

  assign next_addr_reg = (store && push_slice) ? addr : 
                          (addr_next & {{1{1'b1}},{2{1'b0}}});

  
  always @(posedge aclk or negedge aresetn)
   begin : addr_seq
     if (!aresetn) 
         addr_reg <= 3'b0;
     else if (addr_reg_wr)
         addr_reg <= next_addr_reg;
   end 

  assign addr_out = addr_reg & {3{match_i}};
  assign last_addr_match_i = (~|n_response_reg || (downsize_reg[2] & (~|addr_mask_reg)));
  assign last_addr_match   = last_addr_match_i;
  assign beat_complete     = boundary_cross;
  
  assign beat_number = bypass_reg ? {2{1'b0}} : 
                        ((last_addr_match_i && rlast_m) ? (addr_end_masked & {2{match_i}}) : 
                          ((beats_masked) & {2{match_i}}));


  
  assign fixed_incr_addr = (~|addr_mask) & 
                            ((downsize[2] & (~addr[2])) 
                            );
                            

  assign next_addr_mask_reg = (fixed_incr_addr) ? {3{1'b1}} : addr_mask;
  
  
  always @(posedge aclk or negedge aresetn)
   begin : ardata_seq
     if (!aresetn) begin
         addr_mask_reg <= 3'b0;
         addr_mask_end_reg <= 2'b0;
         size_reg  <= 2'b0;
         bypass_reg <= 1'b0;
         downsize_reg <= 3'b0;
     end else if (default_reg_wr_en) begin
         addr_mask_reg <= next_addr_mask_reg;
         addr_mask_end_reg  <= addr_mask_end;
         size_reg <= size_in;
         bypass_reg <= bypass_in;
         downsize_reg <= downsize;
     end
   end 




`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"

  wire        size_out_range;
  
  assign      size_out_range = (size_reg > 2'd2);


  wire                    illegal_size_incr;        

  assign illegal_size_incr =  (size_incr == {3'b0, 1'b1}) & size_out_range;

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "Input size_in to size_incr calculation has gone out of legal range")
  ovl_size_incr_illegal_asize
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (illegal_size_incr)
  );


  wire [6:0]                    rdata_buffer_enables;      

  assign rdata_buffer_enables = {rdata_reg_en, 6'b0};
  

  assert_never_unknown #(`OVL_FATAL, 7,
                         `OVL_ASSERT,
                         "Clock enable has gone X")
  ovl_clock_gate_unknown
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .qualifier  (valid_reg),
    .test_expr  (rdata_buffer_enables & {7{nic400_ib_gpio_ahb_m_ib_downsize_rd_chan_sse710_integration_example_f0_host_exp.rvalid_m}})
  );
`endif

endmodule

`include "nic400_ib_gpio_ahb_m_ib_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"


