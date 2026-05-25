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


`define AXIBM_AW_READY_HIGH           1'b0
`define AXIBM_AW_READY_LOW            1'b1

`define AXIBM_W_READY_LOW             1'b0
`define AXIBM_W_READY_HIGH            1'b1

`define AXIBM_B_VALID_LOW             1'b0
`define AXIBM_B_VALID_HIGH            1'b1

`define AXIBM_AR_READY_HIGH           1'b0
`define AXIBM_AR_READY_LOW            1'b1

`define AXIBM_R_VALID_LOW             1'b0
`define AXIBM_R_VALID_HIGH            1'b1

`define AXIBM_RLAST_LOW               2'b00
`define AXIBM_RLAST_HIGH_HANDSHAKE    2'b01
`define AXIBM_RLAST_HIGH_NOT_READY    2'b10

