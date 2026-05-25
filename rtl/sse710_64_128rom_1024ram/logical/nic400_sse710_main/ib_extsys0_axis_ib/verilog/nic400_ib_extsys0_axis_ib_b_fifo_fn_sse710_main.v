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
  
    

function [1:0] nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn;
   input [2:0]  gry_pntr;
   case(gry_pntr)
  
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd0;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd0; 
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd1;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd1; 
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd2;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd2; 
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd3;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3 : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = 2'd3; 
    
     default : nic400_ib_extsys0_axis_ib_b_fifo_gry_to_bin_fn = {2{1'bx}};
   endcase
endfunction


function [2:0] nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn;
   input [2:0]  gry_pntr;
   case(gry_pntr)
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1;
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2;
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3;
    
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0;
    `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3 : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0;
  
     default : nic400_ib_extsys0_axis_ib_b_fifo_next_gry_fn = `NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_x_x;
   endcase
endfunction




function nic400_ib_extsys0_axis_ib_b_fifo_empty_fn;
   input [2:0]  wpntr_gry;
   input [2:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3} :
    nic400_ib_extsys0_axis_ib_b_fifo_empty_fn = 1'b1;
     default :
      nic400_ib_extsys0_axis_ib_b_fifo_empty_fn = 1'b0;
   endcase
endfunction


function nic400_ib_extsys0_axis_ib_b_fifo_full_fn;
   input [2:0]  wpntr_gry;
   input [2:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_0,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_0},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_1,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_1},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_2,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_2},
    
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3},
    {`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_1_3,`NIC400_IB_EXTSYS0_AXIS_IB_B_FIFO_0_3} :
    nic400_ib_extsys0_axis_ib_b_fifo_full_fn = 1'b1;
     default :
      nic400_ib_extsys0_axis_ib_b_fifo_full_fn = 1'b0;
   endcase
endfunction



