//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2020 Arm Limited or its affiliates.
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
//   Parameters for css600_tpiu
//
//----------------------------------------------------------------------------


  localparam REGA_SSPSR      = 12'h000;
  localparam REGA_CSPSR      = 12'h004;
  localparam REGA_PWRCTL     = 12'h0F0;
  localparam REGA_STMR       = 12'h100;
  localparam REGA_TCVR       = 12'h104;
  localparam REGA_TCMR       = 12'h108;
  localparam REGA_STPMR      = 12'h200;
  localparam REGA_CTPMR      = 12'h204;
  localparam REGA_TPRCR      = 12'h208;
  localparam REGA_FFSR       = 12'h300;
  localparam REGA_FFCR       = 12'h304;
  localparam REGA_FSCR       = 12'h308;
  localparam REGA_EXTCTLIN   = 12'h400;
  localparam REGA_EXTCTLOUT  = 12'h404;
  localparam REGA_ITTRFLIN   = 12'hEE8;
  localparam REGA_ITATBDATA0 = 12'hEEC;
  localparam REGA_ITATBCTR2  = 12'hEF0;
  localparam REGA_ITATBCTR1  = 12'hEF4;
  localparam REGA_ITATBCTR0  = 12'hEF8;
  localparam REGA_ITOUTCTR   = 12'hEFC;
  localparam REGA_ITCTRL     = 12'hF00;
  localparam REGA_CLAIMSET    = 12'hFA0;
  localparam REGA_CLAIMCLR    = 12'hFA4;
  localparam REGA_DEVID       = 12'hFC8;
  localparam REGA_DEVTYPE     = 12'hFCC;
  localparam REGA_PIDR4       = 12'hFD0;
  localparam REGA_PIDR0       = 12'hFE0;
  localparam REGA_PIDR1       = 12'hFE4;
  localparam REGA_PIDR2       = 12'hFE8;
  localparam REGA_PIDR3       = 12'hFEC;
  localparam REGA_CIDR0       = 12'hFF0;
  localparam REGA_CIDR1       = 12'hFF4;
  localparam REGA_CIDR2       = 12'hFF8;
  localparam REGA_CIDR3       = 12'hFFC;


  localparam REGV_SSPSR           = 32'hFFFFFFFF;

  localparam REGV_STMR_TCOUNT8    = 1'b1;
  localparam REGV_STMR_MULT64K    = 1'b1;
  localparam REGV_STMR_MULT256    = 1'b1;
  localparam REGV_STMR_MULT16     = 1'b1;
  localparam REGV_STMR_MULT4      = 1'b1;
  localparam REGV_STMR_MULT2      = 1'b1;

  localparam REGV_STPMR_PCONTEN   = 1'b1;
  localparam REGV_STPMR_PTIMEEN   = 1'b1;
  localparam REGV_STPMR_PATF0     = 1'b1;
  localparam REGV_STPMR_PATA5     = 1'b1;
  localparam REGV_STPMR_PATW0     = 1'b1;
  localparam REGV_STPMR_PATW1     = 1'b1;

  localparam REGV_DEVID_CTLEN       = 1'b0;
  localparam REGV_DEVID_RESERVED    = 4'b0;
  localparam REGV_DEVID_SWOUARTNRZ  = 1'b0;
  localparam REGV_DEVID_SWOMAN      = 1'b0;
  localparam REGV_DEVID_TCLKDATA    = 1'b0;
  localparam REGV_DEVID_FIFOSIZE    = 3'b0;
  localparam REGV_DEVID_CLKRELAT    = 1'b1;
  localparam REGV_DEVID_MUXNUM      = 5'h00;

  localparam REGV_DEVTYPE_SUB       = 4'h1;
  localparam REGV_DEVTYPE_MAJOR     = 4'h1;

  localparam REGV_PIDR0_PART0       = 8'hE7;
  localparam REGV_PIDR1_PART1       = 4'h9;
  localparam REGV_PIDR1_DES0        = 4'hB;
  localparam REGV_PIDR2_DES1        = 3'h3;
  localparam REGV_PIDR2_JEDEC       = 1'b1;
  localparam REGV_PIDR2_REVISION    = 4'h2;
  localparam REGV_PIDR3_CMOD        = 4'h0;
  localparam REGV_PIDR4_DES2        = 4'h4;
  localparam REGV_PIDR4_SIZE        = 4'h0;

  localparam REGV_CIDR0_PRMBL0         = 8'h0D;
  localparam REGV_CIDR1_CLASS          = 4'h9;
  localparam REGV_CIDR1_PRMBL1         = 4'h0;
  localparam REGV_CIDR2_PRMBL2         = 8'h05;
  localparam REGV_CIDR3_PRMBL3         = 8'hB1;


