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

module nic400_bm1_qv_cmp_sse710_integration_example_f0_host_exp (
 
 request_valids,   
 request_qos,     
 
 highest_mh,
 highest_qos
);


parameter REQUESTS      = 16;
parameter QOS_WIDTH     = 4;
parameter SPEED         = 0;

function integer pow_of_2 (input integer value);
  begin : f_pow_of_2
    integer i;
    pow_of_2 = 1;
    for (i = 0; i < value; i = i + 1)
      pow_of_2 = pow_of_2 * 2;
  end
endfunction

localparam QV_LEVELS  = pow_of_2(QOS_WIDTH);


input  [REQUESTS-1:0]                  request_valids;
input  [(REQUESTS*QOS_WIDTH)-1:0]      request_qos;

output [REQUESTS-1:0]                  highest_mh;
output [QOS_WIDTH-1:0]                 highest_qos;


generate
 
  if (REQUESTS == 1) 
  begin : g_one_request
    assign highest_mh  = request_valids;
    assign highest_qos = request_qos;
  end
  
  if (REQUESTS == 2) 
  begin : g_two_requests
  
    assign highest_mh[0] = request_valids[0] 
                             ? (request_valids[1] ? (request_qos[(QOS_WIDTH*0)+:QOS_WIDTH] >= request_qos[(QOS_WIDTH*1)+:QOS_WIDTH]) : 1'b1)
                             :  1'b0;
    assign highest_mh[1] = request_valids[1] 
                             ? (request_valids[0] ? (request_qos[(QOS_WIDTH*1)+:QOS_WIDTH] >= request_qos[(QOS_WIDTH*0)+:QOS_WIDTH]) : 1'b1)
                             :  1'b0;
  
    assign highest_qos = highest_mh[1]
                          ? request_qos[(QOS_WIDTH*1)+:QOS_WIDTH]
                          : request_qos[(QOS_WIDTH*0)+:QOS_WIDTH];

  end
  
  if ((REQUESTS > 2) && (REQUESTS < 16 || SPEED == 1)) 
  begin : g_small_requests
  
    reg [REQUESTS-1:0]                  qv_requests        [REQUESTS-1:0];
    reg [REQUESTS-1:0]                  highest_mh_i;
    reg  [QOS_WIDTH-1:0]                highest_qv_value;
  
    always @*
    begin : p_qv_requests_comb
      integer a;
      integer b;
      for (a = 0; a < REQUESTS; a = a + 1) begin
        for (b = 0; b < REQUESTS; b = b + 1) begin
          qv_requests[a][b] = ~request_valids[b] | (request_qos[(QOS_WIDTH * a) +: QOS_WIDTH] >= request_qos[(QOS_WIDTH * b) +: QOS_WIDTH]);
        end 
        highest_mh_i[a] = request_valids[a] & (&qv_requests[a]);
      end 
    end 
    
    always @* 
    begin : p_highest_qv_comb  
      integer a;
      highest_qv_value = {QOS_WIDTH{1'b0}};
      for (a=0;a<REQUESTS;a=a+1) begin
        highest_qv_value = highest_qv_value | ({QOS_WIDTH{highest_mh_i[a]}} & request_qos[(QOS_WIDTH*a)+:QOS_WIDTH]);
      end
    end
    
    assign highest_mh  = highest_mh_i;
    assign highest_qos = highest_qv_value;
    
  end
  
  if (REQUESTS >= 16 && (SPEED == 0))
  begin : g_multiple_requests
  

  reg  [REQUESTS-1:0]                  qv_requests        [QV_LEVELS-1:0];
  reg  [QV_LEVELS-1:0]                 qv_requests_masked [REQUESTS-1:0];

  reg  [QV_LEVELS-1:0]                 is_qv;      
  reg  [QOS_WIDTH-1:0]                 highest_qv_value;
  reg  [REQUESTS-1:0]                  highest_mh_i;


  
  always @ *
  begin : p_qv_requests_comb
    integer e;
    integer qv_level;
    for (e = 0; e < REQUESTS; e = e + 1) begin
      for (qv_level = 0; qv_level < QV_LEVELS; qv_level = qv_level + 1) begin
        qv_requests[qv_level][e] = request_valids[e] & (request_qos[(QOS_WIDTH * e) +: QOS_WIDTH] >= qv_level);
      end 
    end 
  end 



  always @ *
  begin : p_is_qv_comb
    integer qv_level;
    for (qv_level = 0; qv_level < QV_LEVELS; qv_level = qv_level + 1) begin
      is_qv[qv_level] = |(qv_requests[qv_level]);
    end 
  end 


  always @ *
  begin : p_entry_cmp_value_comb
    integer qv_level;
    highest_qv_value = {QOS_WIDTH{1'b0}};
    for (qv_level = 0; qv_level < QV_LEVELS; qv_level = qv_level + 1) begin
      if (is_qv[qv_level]) begin
        highest_qv_value = qv_level;
      end
    end 
  end 



  always @ *
  begin : p_qv_requests_masked_comb
    integer e;
    integer qv_level;
    for (e = 0; e < REQUESTS; e = e + 1) begin
      for (qv_level = 0; qv_level < QV_LEVELS-1; qv_level = qv_level + 1) begin
        qv_requests_masked[e][qv_level] = qv_requests[qv_level][e] & ~(is_qv[qv_level+1]);
      end 
      qv_requests_masked[e][QV_LEVELS-1] = qv_requests[QV_LEVELS-1][e];
    end 
  end 



  always @ *
  begin : p_highest_mh_comb
    integer e;
    integer qv_level;
    for (e = 0; e < REQUESTS; e = e + 1) begin
      highest_mh_i[e] = |qv_requests_masked[e];
    end 
  end 
  

  assign highest_mh  = highest_mh_i;
  assign highest_qos = highest_qv_value;

  end
endgenerate

endmodule

