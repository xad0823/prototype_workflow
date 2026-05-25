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

  parameter NUM_IRQ         = 32,           
  parameter LVL_WIDTH       = 3,            
  parameter WIC_LINES       = NUM_IRQ+3,    
  parameter WIC_PRESENT     = 1,            
  parameter BB_PRESENT      = 1,            
  parameter MPU_PRESENT     = 1,            
  parameter TRACE_LVL       = 1,            
  parameter DEBUG_LVL       = 3,            
  parameter CLKGATE_PRESENT = 1,            
  parameter RESET_ALL_REGS  = 0,            
  parameter OBSERVATION     = 0,            
  parameter ETM_PRESENT     = 1,            
  parameter EXTRA_ROM_ENTRY = 32'h00000000  
