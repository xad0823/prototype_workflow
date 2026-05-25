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

  `define AHB_LOCK_NOT_LOCK            2'b00
  `define AHB_LOCK_LOCK                2'b01
  `define AHB_LOCK_ERR                 2'b10
  `define AHB_LOCK_ILLEGAL_11          2'b11
  `define AHB_WC_IDLE                  1'b0
  `define AHB_WC_SUBMIT                1'b1
  `define AHB_RH_IDLE_BUSY             3'b001
  `define AHB_RH_SEQ_NSEQ              3'b010
  `define AHB_RH_ERROR                 3'b100
  `define AXI_ASM_IDLE                 3'b100
  `define AXI_ASM_PAUSE_ADDR           3'b000
  `define AXI_ASM_KEEP_AVALID          3'b001
  `define AXI_ASM_BEGIN_NEW            3'b010
  `define AXI_ASM_NEW_PENDING          3'b011
  `define AXI_ASM_ILLEGAL_101          3'b101
  `define AXI_ASM_ILLEGAL_110          3'b110
  `define AXI_ASM_ILLEGAL_111          3'b111
  `define AXI_WC_IDLE                  1'b0
  `define AXI_WC_WAIT_FOR_WREADY       1'b1
  `define AXI_BC_NORMAL                3'b000
  `define AXI_BC_BROKEN_READ           3'b001
  `define AXI_BC_BROKEN_WRITE          3'b011
  `define AXI_BC_WAIT_AHANDSHAKE       3'b100
  `define AXI_BC_WAIT_BHANDSHAKE       3'b111
  `define AXI_BC_ILLEGAL_110           3'b110
  `define AXI_BC_ILLEGAL_010           3'b010
  `define AXI_BC_ILLEGAL_101           3'b101
