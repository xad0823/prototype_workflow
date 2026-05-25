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
  
    

function [2:0] nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn;
   input [3:0]  gry_pntr;
   case(gry_pntr)
  
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd0;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd0; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd1;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd1; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd2;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd2; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd3;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd3; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd4;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd4; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd5;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd5; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd6;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd6; 
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd7;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7 : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = 3'd7; 
    
     default : nic400_ib_p0_axis_ib_aw_fifo_gry_to_bin_fn = {3{1'bx}};
   endcase
endfunction


function [3:0] nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn;
   input [3:0]  gry_pntr;
   case(gry_pntr)
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7;
    
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0;
    `NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7 : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0;
  
     default : nic400_ib_p0_axis_ib_aw_fifo_next_gry_fn = `NIC400_IB_P0_AXIS_IB_AW_FIFO_x_x;
   endcase
endfunction




function nic400_ib_p0_axis_ib_aw_fifo_empty_fn;
   input [3:0]  wpntr_gry;
   input [3:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7} :
    nic400_ib_p0_axis_ib_aw_fifo_empty_fn = 1'b1;
     default :
      nic400_ib_p0_axis_ib_aw_fifo_empty_fn = 1'b0;
   endcase
endfunction


function nic400_ib_p0_axis_ib_aw_fifo_full_fn;
   input [3:0]  wpntr_gry;
   input [3:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_0,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_0},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_1,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_1},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_2,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_2},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_3,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_3},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_4,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_4},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_5,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_5},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_6,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_6},
    
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7,`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7},
    {`NIC400_IB_P0_AXIS_IB_AW_FIFO_1_7,`NIC400_IB_P0_AXIS_IB_AW_FIFO_0_7} :
    nic400_ib_p0_axis_ib_aw_fifo_full_fn = 1'b1;
     default :
      nic400_ib_p0_axis_ib_aw_fifo_full_fn = 1'b0;
   endcase
endfunction



