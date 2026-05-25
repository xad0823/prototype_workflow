//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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
//   Parameters for css600_tmc
//
//----------------------------------------------------------------------------


  localparam ETB = 0;
  localparam ETR = 1;
  localparam ETF = 2;
  localparam ETS = 3;

  localparam REGA_RSZ         = 12'h004;
  localparam REGA_STS         = 12'h00C;
  localparam REGA_RRD         = 12'h010;
  localparam REGA_RRP         = 12'h014;
  localparam REGA_RWP         = 12'h018;
  localparam REGA_TRG         = 12'h01C;
  localparam REGA_CTL         = 12'h020;
  localparam REGA_RWD         = 12'h024;
  localparam REGA_MODE        = 12'h028;
  localparam REGA_LBUFLEVEL   = 12'h02C;
  localparam REGA_CBUFLEVEL   = 12'h030;
  localparam REGA_BUFWM       = 12'h034;
  localparam REGA_RRPHI       = 12'h038;
  localparam REGA_RWPHI       = 12'h03C;
  localparam REGA_AXICTL      = 12'h110;
  localparam REGA_DBALO       = 12'h118;
  localparam REGA_DBAHI       = 12'h11C;
  localparam REGA_RURP        = 12'h120;
  localparam REGA_FFSR        = 12'h300;
  localparam REGA_FFCR        = 12'h304;
  localparam REGA_PSCR        = 12'h308;
  localparam REGA_ITATBMDATA0 = 12'hED0;
  localparam REGA_ITATBMCTR2  = 12'hED4;
  localparam REGA_ITATBMCTR1  = 12'hED8;
  localparam REGA_ITATBMCTR0  = 12'hEDC;
  localparam REGA_ITEVTINTR   = 12'hEE0;
  localparam REGA_ITTRFLIN    = 12'hEE8;
  localparam REGA_ITATBDATA0  = 12'hEEC;
  localparam REGA_ITATBCTR2   = 12'hEF0;
  localparam REGA_ITATBCTR1   = 12'hEF4;
  localparam REGA_ITATBCTR0   = 12'hEF8;
  localparam REGA_ITCTRL      = 12'hF00;
  localparam REGA_CLAIMSET    = 12'hFA0;
  localparam REGA_CLAIMCLR    = 12'hFA4;
  localparam REGA_AUTHSTATUS  = 12'hFB8;
  localparam REGA_DEVID1      = 12'hFC4;
  localparam REGA_DEVID       = 12'hFC8;
  localparam REGA_DEVTYPE     = 12'hFCC;
  localparam REGA_PID4        = 12'hFD0;
  localparam REGA_PID5        = 12'hFD4;
  localparam REGA_PID6        = 12'hFD8;
  localparam REGA_PID7        = 12'hFDC;
  localparam REGA_PID0        = 12'hFE0;
  localparam REGA_PID1        = 12'hFE4;
  localparam REGA_PID2        = 12'hFE8;
  localparam REGA_PID3        = 12'hFEC;
  localparam REGA_CID0        = 12'hFF0;
  localparam REGA_CID1        = 12'hFF4;
  localparam REGA_CID2        = 12'hFF8;
  localparam REGA_CID3        = 12'hFFC;

  localparam AWCACHE_RST_VAL = 4'h0;
  localparam ARCACHE_RST_VAL = 4'h0;
  localparam PSCOUNT_RST_VAL = 5'h0A;

  localparam ST_APBSLV_IDLE  = 2'b00;
  localparam ST_APBSLV_RDY   = 2'b01;
  localparam ST_APBSLV_MEM   = 2'b10;
  localparam ST_APBSLV_UNDEF = 2'bxx;

