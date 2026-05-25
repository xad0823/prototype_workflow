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



module nic400_rsb_s_decode_sse710_main
  (
   rclk,
   rresetn,

   rsb_data_s,
   rsb_valid_s,
   rsb_ready_s,

   rsb_data_pass,
   rsb_valid_pass,
   rsb_ready_pass,

   rsb_data_apb,
   rsb_valid_apb,
   rsb_ready_apb,

   bcast_addr,

   apb_done

   );

`include "nic400_rsb_defs_sse710_main.v"


  parameter ADN_VALUE = 0;

  parameter NUM_ADDRESSES = 2;

  parameter BADN_VALUE_1 = 0;   
  
  input                   rclk;         
  input                   rresetn;      

  input             [7:0] rsb_data_s;
  input                   rsb_valid_s;
  output                  rsb_ready_s;
  
  output            [7:0] rsb_data_pass;
  output                  rsb_valid_pass;
  input                   rsb_ready_pass;

  output            [7:0] rsb_data_apb;
  output                  rsb_valid_apb;
  input                   rsb_ready_apb;

  output                  bcast_addr;

  input                   apb_done;


  reg                     bcast_addr_i;
  reg                     local_match;
  reg                     reg_match;
  
  reg               [3:0] rsb_state;
  reg               [3:0] rsb_state_nxt;
  wire                    rsb_state_en;

  reg                     node_addr_match;
  reg                     node_addr_match_nxt;
  wire                    node_addr_match_en;

  wire              [7:0] w_adn_value [0:1];


  wire                    i_rsb_ready_s;
  wire                    rsb_pass;
  
  

  assign w_adn_value[0] = ADN_VALUE;
  assign w_adn_value[1] = BADN_VALUE_1;


  always @(rsb_state or node_addr_match)
  begin : p_trk_curr_rsb_state
    if (rsb_state == `STATE_DAT3) begin
      if (node_addr_match)
        rsb_state_nxt = `STATE_WAIT;
      else
        rsb_state_nxt = `STATE_ADN;
    end else begin
      if (rsb_state == `STATE_WAIT)
        rsb_state_nxt = `STATE_ADN;
      else
        rsb_state_nxt = rsb_state + 4'b0001;
    end
  end 

  assign rsb_state_en = (((rsb_state != `STATE_WAIT) &
                          rsb_valid_s & i_rsb_ready_s) |
                         ((rsb_state == `STATE_WAIT) & apb_done));

  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_state
    if (~rresetn)
      rsb_state <= `STATE_ADN;
    else if (rsb_state_en)
      rsb_state <= rsb_state_nxt;
  end


  always @(rsb_data_s or rsb_state or
           w_adn_value[0] or w_adn_value[1])
  begin : p_node_addr_match
    integer     i;            
    local_match  = 1'b0;
    reg_match    = 1'b0;
    bcast_addr_i = 1'b0;
    if (rsb_state == `STATE_ADN)
      for (i=0; i<NUM_ADDRESSES; i=i+1)
      begin
        local_match = (rsb_data_s == w_adn_value[i]);
        reg_match   = reg_match  | local_match;
        bcast_addr_i  = bcast_addr_i | ((i == 0) ? 1'b0 : local_match);
      end
    node_addr_match_nxt = reg_match;
  end 

  assign node_addr_match_en = ((rsb_state == `STATE_ADN) &
                               rsb_valid_s & i_rsb_ready_s) | 
                               apb_done;

  always @(posedge rclk or negedge rresetn)
  begin : p_node_addr_match_reg
    if (~rresetn)
      node_addr_match <= 1'b0;
    else if (node_addr_match_en)
      node_addr_match <= node_addr_match_nxt;
  end

  assign bcast_addr = bcast_addr_i;
  

  assign rsb_pass = ~(node_addr_match_nxt | node_addr_match);

  assign i_rsb_ready_s = (rsb_pass ? rsb_ready_pass : rsb_ready_apb);
  assign rsb_ready_s = i_rsb_ready_s;

  assign rsb_valid_pass = rsb_pass & rsb_valid_s;
  assign rsb_data_pass = rsb_data_s;

  assign rsb_valid_apb = ~rsb_pass & rsb_valid_s;
  assign rsb_data_apb = rsb_data_s;

  
`include "nic400_rsb_undefs_sse710_main.v"


endmodule 


