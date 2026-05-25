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



module nic400_ful_regd_slice_sse710_boot_reg
  (
   aresetn,
   aclk,

   valid_src,
   ready_dst,
   payload_src,

   valid_dst,
   ready_src,
   payload_dst
   );

  parameter PAYLD_WIDTH = 2;

  parameter PAYLD_MAX = (PAYLD_WIDTH - 1);
  parameter NUM_SEL_LINES  = (PAYLD_WIDTH + 7) / 8;
  parameter REM_SEL_LINE   = (((PAYLD_WIDTH - 1) % 8) + 1);


  input                 aresetn;        
  input                 aclk;           

  input                 valid_src;      
  input                 ready_dst;      
  input [PAYLD_MAX:0]   payload_src;    

  output                valid_dst;      
  output                ready_src;      
  output [PAYLD_MAX:0]  payload_dst;    

  wire                  aresetn;        
  wire                  aclk;           

  wire                  valid_src;      
  wire                  ready_dst;      
  wire [PAYLD_MAX:0]    payload_src;    

  wire                  valid_dst;      
  wire                  ready_src;      
  reg [PAYLD_MAX:0]     payload_dst;    

  wire                  enable_a;       
  wire                  enable_b;       
  wire                  load_sel_en;    
  wire                  nxt_valid_a;    
  wire                  nxt_valid_b;    
  reg [PAYLD_MAX:0]     payload_reg_a;  
  reg [PAYLD_MAX:0]     payload_reg_b;  
  reg                   valid_a;        
  reg                   valid_b;        
  wire                  iready_src;     
  wire                  ivalid_dst;     
  reg                   load_b;         
  reg [NUM_SEL_LINES:0] sel_b;          
  wire                  sel_b_en;       


  assign valid_dst = ivalid_dst;

  assign ready_src = iready_src;

  always @(sel_b or payload_reg_a or payload_reg_b)
  begin : p_payload_mux
    integer i;    
    integer j;    
    integer base; 
    base = 0;
    for (i=1; i<NUM_SEL_LINES; i=i+1)
    begin
      for (j=base; j<(base+8); j=j+1)
        payload_dst[j] = (sel_b[i] ? payload_reg_b[j] : payload_reg_a[j]);
      base = (8 * i);
    end
    for (j=base; j<(base+REM_SEL_LINE); j=j+1)
      payload_dst[j] = (sel_b[NUM_SEL_LINES] ? payload_reg_b[j] : payload_reg_a[j]);
  end

  assign enable_a = ~load_b & valid_src & iready_src;

  assign enable_b = load_b & valid_src & iready_src;

  assign load_sel_en = valid_src & iready_src;

  assign nxt_valid_a = (enable_a ? 1'b1
                      :((~sel_b[0] & ivalid_dst & ready_dst) ? 1'b0
                        : valid_a));

  assign nxt_valid_b = (enable_b ? 1'b1
                      :((sel_b[0] & ivalid_dst & ready_dst) ? 1'b0
                        : valid_b));

  always @(posedge aclk)
  begin : p_payload_reg_a
    if (enable_a)
      payload_reg_a <= payload_src;
  end 

  always @(posedge aclk)
  begin : p_payload_reg_b
    if (enable_b)
      payload_reg_b <= payload_src;
  end 

  always @(posedge aclk or negedge aresetn)
  begin : p_valid_a
    if (~aresetn)
      valid_a <= 1'b0;
    else
      valid_a <= nxt_valid_a;
  end 

  always @(posedge aclk or negedge aresetn)
  begin : p_valid_b
    if (~aresetn)
      valid_b <= 1'b0;
    else
      valid_b <= nxt_valid_b;
  end 

  assign iready_src = ~valid_a | ~valid_b;

  assign ivalid_dst = valid_a | valid_b;

  always @(posedge aclk or negedge aresetn)
  begin : p_load_b
    if (~aresetn)
      load_b <= 1'b0;
    else
      if (load_sel_en)
        load_b <= ~load_b;
  end 

  assign sel_b_en = ((~sel_b[0] & nxt_valid_b & (~valid_a | ready_dst)) |
                     ( sel_b[0] & nxt_valid_a & (~valid_b | ready_dst)));
 
  always @(posedge aclk or negedge aresetn)
  begin : p_sel_b
    if (~aresetn)
      sel_b <= {NUM_SEL_LINES+1{1'b0}};
    else
      if (sel_b_en)
        sel_b <= ~sel_b;
  end 

endmodule 

