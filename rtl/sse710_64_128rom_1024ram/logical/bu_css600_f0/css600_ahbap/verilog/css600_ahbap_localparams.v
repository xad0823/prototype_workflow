//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2018, 2020 Arm Limited or its affiliates.
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
//   Parameters for css600_ahbap
//
//----------------------------------------------------------------------------


  localparam ST_APBSLV_IDLE       = 2'b00;
  localparam ST_APBSLV_MEM        = 2'b01;
  localparam ST_APBSLV_RDY        = 2'b10;
  localparam ST_APBSLV_ERR        = 2'b11;
  localparam ST_APBSLV_UNDEF      = 2'bxx;

  localparam ST_AHBMSTR_IDLE      = 2'b00;
  localparam ST_AHBMSTR_AD_PHASE  = 2'b01;
  localparam ST_AHBMSTR_DT_PHASE  = 2'b10;
  localparam ST_AHBMSTR_UNDEF     = 2'bxx;

  localparam REGA_DAR_MIN         = 12'h000;
  localparam REGA_DAR_MAX         = 12'h3FF;
  localparam REGA_CSW             = 12'hD00;
  localparam REGA_TAR             = 12'hD04;
  localparam REGA_DRW             = 12'hD0C;
  localparam REGA_BD0             = 12'hD10;
  localparam REGA_BD1             = 12'hD14;
  localparam REGA_BD2             = 12'hD18;
  localparam REGA_BD3             = 12'hD1C;
  localparam REGA_TRR             = 12'hD24;
  localparam REGA_CFG             = 12'hDF4;
  localparam REGA_BASE            = 12'hDF8;
  localparam REGA_IDR             = 12'hDFC;
  localparam REGA_ITSTATUS        = 12'hEFC;
  localparam REGA_ITCTRL          = 12'hF00;
  localparam REGA_CLAIMSET        = 12'hFA0;
  localparam REGA_CLAIMCLR        = 12'hFA4;
  localparam REGA_AUTHSTATUS      = 12'hFB8;
  localparam REGA_DEVARCH         = 12'hFBC;
  localparam REGA_DEVTYPE         = 12'hFCC;
  localparam REGA_PIDR4           = 12'hFD0;
  localparam REGA_PIDR0           = 12'hFE0;
  localparam REGA_PIDR1           = 12'hFE4;
  localparam REGA_PIDR2           = 12'hFE8;
  localparam REGA_PIDR3           = 12'hFEC;
  localparam REGA_CIDR0           = 12'hFF0;
  localparam REGA_CIDR1           = 12'hFF4;
  localparam REGA_CIDR2           = 12'hFF8;
  localparam REGA_CIDR3           = 12'hFFC;


  localparam REGV_CFG_DARSIZE          = 4'hA;
  localparam REGV_CFG_ERR              = 4'h1;
  localparam REGV_CFG_TARINC           = 4'h1;

  localparam REGV_BASE_FORMAT          = 1'b1;

  localparam REGV_IDR_TYPE             = 4'h8;
  localparam REGV_IDR_VARIANT          = 4'h0;
  localparam REGV_IDR_CLASS            = 4'h8;
  localparam REGV_IDR_JEDECCODE        = 7'h3B;
  localparam REGV_IDR_JEDECBANK        = 4'h4;
  localparam REGV_IDR_REVISION         = 4'h3;

  localparam REGV_DEVARCH_ARCHID       = 16'h0A17;
  localparam REGV_DEVARCH_REVISION     = 4'h0;
  localparam REGV_DEVARCH_PRESENT      = 1'b1;
  localparam REGV_DEVARCH_ARCHITECT    = 11'h23B;

  localparam REGV_DEVTYPE_MAJOR        = 4'h0;
  localparam REGV_DEVTYPE_SUB          = 4'h0;

  localparam REGV_PIDR0_PART0          = 8'hE3;
  localparam REGV_PIDR1_PART1          = 4'h9;
  localparam REGV_PIDR1_DES0           = 4'hB;
  localparam REGV_PIDR2_DES1           = 3'h3;
  localparam REGV_PIDR2_JEDEC          = 1'b1;
  localparam REGV_PIDR2_REVISION       = REGV_IDR_REVISION;
  localparam REGV_PIDR3_CMOD           = 4'h0;
  localparam REGV_PIDR4_DES2           = 4'h4;
  localparam REGV_PIDR4_SIZE           = 4'h0;

  localparam REGV_CIDR0_PRMBL0         = 8'h0D;
  localparam REGV_CIDR1_PRMBL1         = 4'h0;
  localparam REGV_CIDR1_CLASS          = 4'h9;
  localparam REGV_CIDR2_PRMBL2         = 8'h05;
  localparam REGV_CIDR3_PRMBL3         = 8'hB1;


  localparam NUM_DAR = ((REGA_DAR_MAX-REGA_DAR_MIN)+12'h001)/4;

  localparam AHBM_HPROT_DEFAULT = 5'b0_0011;
  localparam AHBM_HPROT6_DEFAULT = 1'b0;

  localparam LOGICAL_AP0 = 1'b0;
  localparam LOGICAL_AP1 = 1'b1;
  localparam AHBAP_BYTE      = 2'b00;
  localparam AHBAP_HALF_WORD = 2'b01;
  localparam AHBAP_WORD      = 2'b10;
  localparam AHBAP_DWORD     = 2'b11;


