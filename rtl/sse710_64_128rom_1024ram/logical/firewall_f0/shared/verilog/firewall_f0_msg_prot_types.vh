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


localparam HNDSHK_REQ_T = 2'b00;
localparam IRQ_REQ_T = 2'b01;
localparam CFG_RSP_T = 2'b10;
localparam CNCT_REQ_T = 1'b0;
localparam DISCNCT_REQ_T = 1'b1;
localparam CFG_WRITE_RSP_T = 1'b0;
localparam CFG_READ_RSP_T = 1'b1;
localparam WRITE_VAL_RSP_T = 1'b0;
localparam WRITE_INVAL_RSP_T = 1'b1;
localparam WRITE_NO_TAMP_T = 1'b0;
localparam WRITE_TAMP_T = 1'b1;
localparam HNDSHK_RSP_T = 2'b00;
localparam RESTORE_FRAME_T = 2'b01;
localparam CFG_REQ_T = 2'b10;
localparam HNDSHK_CNCT_T = 1'b0;
localparam HNDSHK_DISCNCT_T = 1'b1;
localparam HNDSHK_ACCEPT_T = 1'b0;
localparam HNDSHK_DENY_T = 1'b1;
localparam CFG_WRITE_REQ_T = 1'b0;
localparam CFG_READ_REQ_T = 1'b1;
localparam REG_NRST_T = 1'b0;
localparam REG_RST_T = 1'b1;

localparam CNCT_ACCEPT_RSP_MSG_HDR = {HNDSHK_ACCEPT_T, HNDSHK_CNCT_T, HNDSHK_RSP_T};
localparam DISCNCT_ACCEPT_RSP_MSG_HDR = {HNDSHK_ACCEPT_T, HNDSHK_DISCNCT_T, HNDSHK_RSP_T};
localparam WRITE_REQ_MSG_HDR = {CFG_WRITE_REQ_T, CFG_REQ_T};
localparam READ_REQ_MSG_HDR = {CFG_READ_REQ_T, CFG_REQ_T};
localparam RESTORE_FRAME_MSG_HDR = {RESTORE_FRAME_T};
localparam DISCNCT_REQ_MSG_HDR = {DISCNCT_REQ_T, HNDSHK_REQ_T};
localparam CNCT_NRST_REQ_MSG_HDR = {REG_NRST_T, CNCT_REQ_T, HNDSHK_REQ_T};
localparam CNCT_RST_REQ_MSG_HDR = {REG_RST_T, CNCT_REQ_T, HNDSHK_REQ_T};
localparam IRQ_MSG_HDR = {IRQ_REQ_T};
localparam WRITE_VAL_RSP_MSG_HDR = {WRITE_VAL_RSP_T, CFG_WRITE_RSP_T, CFG_RSP_T};
localparam WRITE_INVAL_NTAMP_RSP_MSG_HDR = {WRITE_NO_TAMP_T, WRITE_INVAL_RSP_T, CFG_WRITE_RSP_T, CFG_RSP_T};
localparam WRITE_INVAL_TAMP_RSP_MSG_HDR = {WRITE_TAMP_T, WRITE_INVAL_RSP_T, CFG_WRITE_RSP_T, CFG_RSP_T};
localparam READ_RSP_MSG_HDR = {CFG_READ_RSP_T, CFG_RSP_T};
