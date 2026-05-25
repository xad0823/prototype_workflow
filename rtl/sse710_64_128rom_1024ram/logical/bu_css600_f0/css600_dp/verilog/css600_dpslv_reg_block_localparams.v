//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Parameters for css600_dp
//
//----------------------------------------------------------------------------


localparam [1:0] DP_ADDR_0       = 2'b00;
localparam [1:0] DP_ADDR_4       = 2'b01;
localparam [1:0] DP_ADDR_8       = 2'b10;
localparam [1:0] DP_ADDR_C       = 2'b11;

localparam [3:0] DP_ADDR_SEL_0       = 4'b0001;
localparam [3:0] DP_ADDR_SEL_4       = 4'b0010;
localparam [3:0] DP_ADDR_SEL_8       = 4'b0100;
localparam [3:0] DP_ADDR_SEL_C       = 4'b1000;

localparam [15:0] ABORT_REG_SEL     = 16'b0000000000000001;
localparam [15:0] DPIDR_REG_SEL     = 16'b0000000000000010;
localparam [15:0] DPIDR1_REG_SEL    = 16'b0000000000000100;
localparam [15:0] BASEPTR0_REG_SEL  = 16'b0000000000001000;
localparam [15:0] BASEPTR1_REG_SEL  = 16'b0000000000010000;
localparam [15:0] CTRLSTAT_REG_SEL  = 16'b0000000000100000;
localparam [15:0] DLCR_REG_SEL      = 16'b0000000001000000;
localparam [15:0] TARGETID_REG_SEL  = 16'b0000000010000000;
localparam [15:0] DLPIDR_REG_SEL    = 16'b0000000100000000;
localparam [15:0] EVENTSTAT_REG_SEL = 16'b0000001000000000;
localparam [15:0] SELECT1_REG_SEL   = 16'b0000010000000000;
localparam [15:0] RESEND_REG_SEL    = 16'b0000100000000000;
localparam [15:0] SELECT_REG_SEL    = 16'b0001000000000000;
localparam [15:0] RDBUFF_REG_SEL    = 16'b0010000000000000;
localparam [15:0] TARGETSEL_REG_SEL = 16'b0100000000000000;
localparam [15:0] RESERVED_REG_SEL  = 16'b1000000000000000;
localparam [15:0] NO_REG_SEL        = 16'b0000000000000000;


localparam [31:0] DPIDR = 32'h4C013477;


