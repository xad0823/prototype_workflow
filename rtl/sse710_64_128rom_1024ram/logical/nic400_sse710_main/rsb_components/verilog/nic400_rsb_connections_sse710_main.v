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




module nic400_rsb_connections_sse710_main
 (
  
    rsb_data_a_slave_m,
    rsb_wptr_a_slave_m,
    rsb_rptr_a_slave_m,
    rsb_b_rptr_a_slave_m,

    rsb_data_a_slave_s,
    rsb_wptr_a_slave_s,
    rsb_rptr_a_slave_s,
    rsb_b_rptr_a_slave_s,

    rsb_data_a_master_m,
    rsb_wptr_a_master_m,
    rsb_rptr_a_master_m,
    rsb_b_rptr_a_master_m,

    rsb_data_a_master_s,
    rsb_wptr_a_master_s,
    rsb_rptr_a_master_s,
    rsb_b_rptr_a_master_s

 );


  `include "nic400_closure_sse710_main_defs.v"

  

  output  [7:0]       rsb_data_a_slave_m;         
  output  [2:0]       rsb_wptr_a_slave_m;         
  input   [2:0]       rsb_rptr_a_slave_m;         
  input   [1:0]       rsb_b_rptr_a_slave_m;       


  input   [7:0]       rsb_data_a_slave_s;         
  input   [2:0]       rsb_wptr_a_slave_s;         
  output  [2:0]       rsb_rptr_a_slave_s;         
  output  [1:0]       rsb_b_rptr_a_slave_s;       


  output  [7:0]       rsb_data_a_master_m;        
  output  [2:0]       rsb_wptr_a_master_m;        
  input   [2:0]       rsb_rptr_a_master_m;        
  input   [1:0]       rsb_b_rptr_a_master_m;      


  input   [7:0]       rsb_data_a_master_s;        
  input   [2:0]       rsb_wptr_a_master_s;        
  output  [2:0]       rsb_rptr_a_master_s;        
  output  [1:0]       rsb_b_rptr_a_master_s;      



  assign rsb_data_a_slave_m = `RSB_DATA_M_A_SLAVE_M;
  assign rsb_wptr_a_slave_m = `RSB_WPTR_M_A_SLAVE_M;
  assign `RSB_RPTR_M_A_SLAVE_M = rsb_rptr_a_slave_m;
  assign `RSB_B_RPTR_M_A_SLAVE_M = rsb_b_rptr_a_slave_m;

  assign rsb_data_a_master_m = `RSB_DATA_M_A_MASTER_M;
  assign rsb_wptr_a_master_m = `RSB_WPTR_M_A_MASTER_M;
  assign `RSB_RPTR_M_A_MASTER_M = rsb_rptr_a_master_m;
  assign `RSB_B_RPTR_M_A_MASTER_M = rsb_b_rptr_a_master_m;


  `include "nic400_closure_sse710_main_undefs.v"

endmodule
