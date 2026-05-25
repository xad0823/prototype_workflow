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



module nic400_fwd_regd_slice_sse710_dbgaxi2apb
  (
   aresetn,
   aclk,

   valid_src,
   ready_dst,
   payload_src,

   ready_src,
   valid_dst,
   payload_dst
   );

  parameter PAYLD_WIDTH = 2;

  parameter PAYLD_MAX = (PAYLD_WIDTH - 1);

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

  wire                  payload_en;     
  wire                  valid_dst_en;   
  reg                   ivalid_dst;     


  assign valid_dst = ivalid_dst;

  assign ready_src = ready_dst | ~ivalid_dst;

  always @(posedge aclk)
  begin : p_payload_dst
    if (payload_en)
      payload_dst <= payload_src;
  end 

  assign payload_en = ((valid_src & ~ivalid_dst) |
                       (valid_src & ivalid_dst & ready_dst));

  assign valid_dst_en = (valid_src | ready_dst);

  always @(posedge aclk or negedge aresetn)
  begin : p_ivalid_dst
    if (~aresetn)
      ivalid_dst <= 1'b0;
    else if (valid_dst_en)
      ivalid_dst <= valid_src;
  end 

endmodule

