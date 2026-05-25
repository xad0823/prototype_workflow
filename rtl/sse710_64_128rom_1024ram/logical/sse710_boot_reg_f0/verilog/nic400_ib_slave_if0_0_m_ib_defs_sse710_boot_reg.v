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

`define RS_REGD            0            
`define RS_FWD_REG         1            
`define RS_REV_REG         2            
`define RS_STATIC_BYPASS   3            


`define AWFIFO_BYPASS 0
`define AWFIFO_SIZE 3:1
`define AWFIFO_ADDR 5:4
`define AWFIFO_MASK 7:6
`define AWFIFO_WRAP_FITS 8


`define ARDATA_SIZE 2:0
`define ARDATA_BYPASS 3
`define ARDATA_ADDR 5:4
`define ARDATA_MASK 7:6
`define ARDATA_END 9:8
`define ARDATA_ID 19:10
`define ARDATA_TWO 23:20
`define ARDATA_WRAP_FITS 24


  
`define NIC400_IB_SLAVE_IF0_0_M_IB_A_FIFO_0_0 2'd0
`define NIC400_IB_SLAVE_IF0_0_M_IB_A_FIFO_0_1 2'd1
`define NIC400_IB_SLAVE_IF0_0_M_IB_A_FIFO_1_0 2'd3
`define NIC400_IB_SLAVE_IF0_0_M_IB_A_FIFO_1_1 2'd2
`define NIC400_IB_SLAVE_IF0_0_M_IB_A_FIFO_x_x {2{1'bx}}



  
`define NIC400_IB_SLAVE_IF0_0_M_IB_W_FIFO_0_0 2'd0
`define NIC400_IB_SLAVE_IF0_0_M_IB_W_FIFO_0_1 2'd1
`define NIC400_IB_SLAVE_IF0_0_M_IB_W_FIFO_1_0 2'd3
`define NIC400_IB_SLAVE_IF0_0_M_IB_W_FIFO_1_1 2'd2
`define NIC400_IB_SLAVE_IF0_0_M_IB_W_FIFO_x_x {2{1'bx}}



  
`define NIC400_IB_SLAVE_IF0_0_M_IB_D_FIFO_0_0 2'd0
`define NIC400_IB_SLAVE_IF0_0_M_IB_D_FIFO_0_1 2'd1
`define NIC400_IB_SLAVE_IF0_0_M_IB_D_FIFO_1_0 2'd3
`define NIC400_IB_SLAVE_IF0_0_M_IB_D_FIFO_1_1 2'd2
`define NIC400_IB_SLAVE_IF0_0_M_IB_D_FIFO_x_x {2{1'bx}}





