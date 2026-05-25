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



module nic400_rev_regd_slice_sse710_dbgaxi2apb
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

  parameter PAYLD_WIDTH = 1;

  parameter PAYLD_MAX      = PAYLD_WIDTH - 1;
  parameter NUM_SEL_LINES  = (PAYLD_WIDTH + 7) / 8;
  parameter REM_SEL_LINE   = (((PAYLD_WIDTH - 1) % 8) + 1);


  input                 aclk;            
  input                 aresetn;         

  input [PAYLD_MAX:0]   payload_src;     
  output [PAYLD_MAX:0]  payload_dst;     


  input                 valid_src;       
  output                ready_src;       

  output                valid_dst;       
  input                 ready_dst;       

  reg [PAYLD_MAX:0]     payload_dst;     

  reg [PAYLD_MAX:0]     payload_reg;     
  wire                  buffer_en;       
  wire                  buffer_full_en;  
  reg [NUM_SEL_LINES:0] buffer_full;     



  assign buffer_en = (valid_src & ~buffer_full[0] & ~ready_dst);

  always @(posedge aclk)
  begin : p_buffer_seq
    if (buffer_en)
      payload_reg <= payload_src;
  end

  assign buffer_full_en = (buffer_en | ready_dst);

  always @(negedge aresetn or posedge aclk)
  begin : p_buffer_full_seq
    if (~aresetn)
      buffer_full <= {NUM_SEL_LINES+1{1'b0}};
    else if (buffer_full_en)
      buffer_full <= {NUM_SEL_LINES+1{buffer_en}};
  end

  assign ready_src = ~buffer_full[0];

  assign valid_dst = (valid_src | buffer_full[0]);

  always @(buffer_full or payload_reg or payload_src)
  begin : p_payload_mux
    integer i;    
    integer j;    
    integer base; 
    base = 0;
    for (i=1; i<NUM_SEL_LINES; i=i+1)
    begin
      for (j=base; j<(base+8); j=j+1)
        payload_dst[j] = (buffer_full[i] ? payload_reg[j] : payload_src[j]);
      base = (8 * i);
    end
    for (j=base; j<(base+REM_SEL_LINE); j=j+1)
      payload_dst[j] = (buffer_full[NUM_SEL_LINES] ? payload_reg[j]
                         : payload_src[j]);
  end

endmodule 



