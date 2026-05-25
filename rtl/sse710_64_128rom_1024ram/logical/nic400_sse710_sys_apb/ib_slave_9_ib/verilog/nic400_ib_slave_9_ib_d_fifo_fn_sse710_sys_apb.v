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
  
    

function       nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn;
   input [1:0]  gry_pntr;
   case(gry_pntr)
  
    `NIC400_IB_SLAVE_9_IB_D_FIFO_0_0 : nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn = 1'd0;
    `NIC400_IB_SLAVE_9_IB_D_FIFO_1_0 : nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn = 1'd0; 
    
    `NIC400_IB_SLAVE_9_IB_D_FIFO_0_1 : nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn = 1'd1;
    `NIC400_IB_SLAVE_9_IB_D_FIFO_1_1 : nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn = 1'd1; 
    
     default : nic400_ib_slave_9_ib_d_fifo_gry_to_bin_fn = {1{1'bx}};
   endcase
endfunction


function [1:0] nic400_ib_slave_9_ib_d_fifo_next_gry_fn;
   input [1:0]  gry_pntr;
   case(gry_pntr)
    
    `NIC400_IB_SLAVE_9_IB_D_FIFO_0_0 : nic400_ib_slave_9_ib_d_fifo_next_gry_fn = `NIC400_IB_SLAVE_9_IB_D_FIFO_0_1;
    `NIC400_IB_SLAVE_9_IB_D_FIFO_1_0 : nic400_ib_slave_9_ib_d_fifo_next_gry_fn = `NIC400_IB_SLAVE_9_IB_D_FIFO_1_1;
    
    `NIC400_IB_SLAVE_9_IB_D_FIFO_0_1 : nic400_ib_slave_9_ib_d_fifo_next_gry_fn = `NIC400_IB_SLAVE_9_IB_D_FIFO_1_0;
    `NIC400_IB_SLAVE_9_IB_D_FIFO_1_1 : nic400_ib_slave_9_ib_d_fifo_next_gry_fn = `NIC400_IB_SLAVE_9_IB_D_FIFO_0_0;
  
     default : nic400_ib_slave_9_ib_d_fifo_next_gry_fn = `NIC400_IB_SLAVE_9_IB_D_FIFO_x_x;
   endcase
endfunction




function nic400_ib_slave_9_ib_d_fifo_empty_fn;
   input [1:0]  wpntr_gry;
   input [1:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_0_0,`NIC400_IB_SLAVE_9_IB_D_FIFO_0_0},
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_1_0,`NIC400_IB_SLAVE_9_IB_D_FIFO_1_0},
    
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_0_1,`NIC400_IB_SLAVE_9_IB_D_FIFO_0_1},
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_1_1,`NIC400_IB_SLAVE_9_IB_D_FIFO_1_1} :
    nic400_ib_slave_9_ib_d_fifo_empty_fn = 1'b1;
     default :
      nic400_ib_slave_9_ib_d_fifo_empty_fn = 1'b0;
   endcase
endfunction


function nic400_ib_slave_9_ib_d_fifo_full_fn;
   input [1:0]  wpntr_gry;
   input [1:0]  rpntr_gry;
   case({wpntr_gry, rpntr_gry})
    
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_0_0,`NIC400_IB_SLAVE_9_IB_D_FIFO_1_0},
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_1_0,`NIC400_IB_SLAVE_9_IB_D_FIFO_0_0},
    
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_0_1,`NIC400_IB_SLAVE_9_IB_D_FIFO_1_1},
    {`NIC400_IB_SLAVE_9_IB_D_FIFO_1_1,`NIC400_IB_SLAVE_9_IB_D_FIFO_0_1} :
    nic400_ib_slave_9_ib_d_fifo_full_fn = 1'b1;
     default :
      nic400_ib_slave_9_ib_d_fifo_full_fn = 1'b0;
   endcase
endfunction



