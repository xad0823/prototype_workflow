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
localparam INT_RTR_CTRL   = 12'h000;
localparam LD_CTRL        = 12'h010;
localparam SHD_INT_CFG    = 12'h104;
localparam SHD_INT_LCTRL  = 12'h108;
localparam SHD_INT_SEL    = 12'h10C;
localparam INT_RTR_TMP_ST = 12'hE90;
localparam SHD_INT_INFO  = 12'h100;
localparam INT_RTR_CAP   = 12'hFA0;
localparam INT_RTR_CFG   = 12'hFB0;
localparam PID0 = 12'hFE0;
localparam PID1 = 12'hFE4;
localparam PID2 = 12'hFE8;
localparam PID3 = 12'hFEC;
localparam PID4 = 12'hFD0;
localparam PID5 = 12'hFD4;
localparam PID6 = 12'hFD8;
localparam PID7 = 12'hFDC;
localparam ID0 = 12'hFF0;
localparam ID1 = 12'hFF4;
localparam ID2 = 12'hFF8;
localparam ID3 = 12'hFFC;

`define INT_RTR_ADDR_MAP_OVERRIDE \
  .INT_RTR_CTRL (INT_RTR_CTRL), \
  .LD_CTRL (LD_CTRL), \
  .SHD_INT_CFG (SHD_INT_CFG), \
  .SHD_INT_LCTRL (SHD_INT_LCTRL), \
  .SHD_INT_SEL (SHD_INT_SEL), \
  .INT_RTR_TMP_ST (INT_RTR_TMP_ST), \
  .SHD_INT_INFO (SHD_INT_INFO), \
  .INT_RTR_CAP (INT_RTR_CAP), \
  .INT_RTR_CFG (INT_RTR_CFG), \
  .PID0 (PID0), \
  .PID1 (PID1), \
  .PID2 (PID2), \
  .PID3 (PID3), \
  .PID4 (PID4), \
  .PID5 (PID5), \
  .PID6 (PID6), \
  .PID7 (PID7), \
  .ID0 (ID0), \
  .ID1 (ID1), \
  .ID2 (ID2), \
  .ID3 (ID3),

