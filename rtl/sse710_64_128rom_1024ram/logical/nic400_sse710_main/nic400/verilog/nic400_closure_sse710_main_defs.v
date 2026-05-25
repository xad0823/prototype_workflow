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




   `define RSB_L4_ASYNC





`define RSB_REG_DEBUG_AXIS_IB_A_SLAVE `RS_STATIC_BYPASS

`define RSB_DATA_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN  mdata
`define RSB_VALID_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN mvalid
`define RSB_READY_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN mready
`define RSB_REG_EXTSYS0_AXIS_IB_A_SLAVE `RS_STATIC_BYPASS

`define RSB_DATA_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN  rsb_data_m_debug_axis_ib
`define RSB_VALID_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_valid_m_debug_axis_ib
`define RSB_READY_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_ready_m_debug_axis_ib
`define RSB_REG_EXTSYS1_AXIS_IB_A_SLAVE `RS_STATIC_BYPASS

`define RSB_DATA_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN  rsb_data_m_extsys0_axis_ib
`define RSB_VALID_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_valid_m_extsys0_axis_ib
`define RSB_READY_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_ready_m_extsys0_axis_ib
`define RSB_REG_SECENC_AXIS_IB_A_SLAVE `RS_REGD

`define RSB_DATA_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN  rsb_data_m_extsys1_axis_ib
`define RSB_VALID_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_valid_m_extsys1_axis_ib
`define RSB_READY_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_ready_m_extsys1_axis_ib
`define RSB_REG_HOSTCPU_AXIS_IB_A_SLAVE `RS_STATIC_BYPASS

`define RSB_DATA_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN  rsb_data_m_secenc_axis_ib
`define RSB_VALID_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_valid_m_secenc_axis_ib
`define RSB_READY_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN rsb_ready_m_secenc_axis_ib
`define RSB_REG_REGS_A_SLAVE `RS_STATIC_BYPASS

`define RSB_DATA_S_REGS_A_SLAVE_SSE710_MAIN  rsb_data_m_hostcpu_axis_ib
`define RSB_VALID_S_REGS_A_SLAVE_SSE710_MAIN rsb_valid_m_hostcpu_axis_ib
`define RSB_READY_S_REGS_A_SLAVE_SSE710_MAIN rsb_ready_m_hostcpu_axis_ib
`define RSB_DATA_S_LAST_A_SLAVE_SSE710_MAIN  rsb_data_m_regs
`define RSB_VALID_S_LAST_A_SLAVE_SSE710_MAIN rsb_valid_m_regs
`define RSB_READY_S_LAST_A_SLAVE_SSE710_MAIN rsb_ready_m_regs

`define RSB_DATA_S_GPV_0_A_MASTER_SSE710_MAIN  mdata
`define RSB_VALID_S_GPV_0_A_MASTER_SSE710_MAIN mvalid
`define RSB_READY_S_GPV_0_A_MASTER_SSE710_MAIN mready
`define RSB_DATA_S_LAST_A_MASTER_SSE710_MAIN  rsb_data_m_gpv_0
`define RSB_VALID_S_LAST_A_MASTER_SSE710_MAIN rsb_valid_m_gpv_0
`define RSB_READY_S_LAST_A_MASTER_SSE710_MAIN rsb_ready_m_gpv_0

  
  `define RSB_DATA_M_A_MASTER_M rsb_data_a_slave_s
  `define RSB_WPTR_M_A_MASTER_M rsb_wptr_a_slave_s
  `define RSB_B_RPTR_M_A_MASTER_M rsb_b_rptr_a_slave_s
  `define RSB_RPTR_M_A_MASTER_M rsb_rptr_a_slave_s
  `define RSB_A_MASTER_SRC_CLK "a_slave"
  `define RSB_DATA_M_A_SLAVE_M rsb_data_a_master_s
  `define RSB_WPTR_M_A_SLAVE_M rsb_wptr_a_master_s
  `define RSB_B_RPTR_M_A_SLAVE_M rsb_b_rptr_a_master_s
  `define RSB_RPTR_M_A_SLAVE_M rsb_rptr_a_master_s
  `define RSB_A_SLAVE_SRC_CLK "a_master"


  
  `define RSB_A_MASTER_S_SYNC
  `define RSB_A_MASTER_M_SYNC
  
  `define RSB_A_SLAVE_S_SYNC
  `define RSB_A_SLAVE_M_SYNC
  

