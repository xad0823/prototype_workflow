//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
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
//   Parameters for css600_catu
//
//----------------------------------------------------------------------------


localparam ST_TRANSLATE_IDLE       = 3'b000;
localparam ST_TRANSLATE_HIT        = 3'b001;
localparam ST_TRANSLATE_MISS       = 3'b010;
localparam ST_TRANSLATED           = 3'b011;
localparam ST_INVALID_ADD          = 3'b100;
localparam ST_INVALID_RESP         = 3'b101;
localparam ST_TRANS_CMP            = 3'b110;
localparam ST_TRANSLATE_UNDEF      = 3'bxxx;

localparam ST_FETCH_IDLE       = 2'b00;
localparam ST_FETCH_INIT       = 2'b01;
localparam ST_FETCH_INIT_CMP   = 2'b10;
localparam ST_FETCH_COMPLETE   = 2'b11;
localparam ST_FETCH_UNDEF      = 2'bxx;
localparam ST_FETCH_BITS       = 2;

localparam ST_SLW_IDLE       = 3'b000;
localparam ST_SLW_ACT        = 3'b001;
localparam ST_SLW_SRCH       = 3'b010;
localparam ST_SLW_UPD        = 3'b011;
localparam ST_SLW_FETCH      = 3'b100;
localparam ST_SLW_WAIT       = 3'b101;
localparam ST_SLW_UNDEF      = 3'bxxx;
localparam ST_SLW_BITS       = 3;

localparam SP_SIZE           = 20;

localparam SCATTER_NEXT_PAGE = 12'hFF8;
localparam SCATTER_PREV_PAGE = 12'hFF0;

localparam REG_CONTROL_ADDR               = 10'h000;
localparam REG_CONTROL_ENABLE_MSB         = 0;
localparam REG_CONTROL_ENABLE_LSB         = 0;
localparam REG_CONTROL_ENABLE_INIT        = 1'b0;
localparam REG_MODE_ADDR                 = 10'h001;
localparam REG_MODE_MODE_MSB             = 0;
localparam REG_MODE_MODE_LSB             = 0;
localparam REG_AXICTRL_ADDR              = 10'h002;
localparam REG_AXICTRL_ARCACHE_MSB       = 7;
localparam REG_AXICTRL_ARCACHE_LSB       = 4;
localparam REG_AXICTRL_ARCACHE_INIT      = 4'b0000;
localparam REG_AXICTRL_ARPROT_MSB        = 1;
localparam REG_AXICTRL_ARPROT_LSB        = 0;
localparam REG_IRQEN_ADDR                = 10'h003;
localparam REG_IRQEN_IRQEN_MSB           = 0;
localparam REG_IRQEN_IRQEN_LSB           = 0;
localparam REG_SLADDRLO_ADDR             = 10'h008;
localparam REG_SLADDRLO_SLADDRLO_MSB     = 31;
localparam REG_SLADDRLO_SLADDRLO_LSB     = 12;
localparam REG_SLADDRHI_ADDR             = 10'h009;
localparam REG_SLADDRHI_SLADDRHI_LSB     = 0;
localparam REG_INADDRLO_ADDR             = 10'h00A;
localparam REG_INADDRLO_INADDRLO_MSB     = 31;
localparam REG_INADDRLO_INADDRLO_LSB     = 20;
localparam REG_INADDRHI_ADDR             = 10'h00B;
localparam REG_INADDRHI_INADDRHI_LSB     = 0;

localparam REG_STATUS_ADDR               = 10'h040;
localparam REG_STATUS_READY_MSB          = 8;
localparam REG_STATUS_READY_LSB          = 8;
localparam REG_STATUS_AXIERR_MSB         = 4;
localparam REG_STATUS_AXIERR_LSB         = 4;
localparam REG_STATUS_ADDRERR_MSB        = 0;
localparam REG_STATUS_ADDRERR_LSB        = 0;

localparam REG_ITIRQ_ADDR                = 10'h3B4;
localparam REG_ITIRQ_ADDRERR_MSB      = 0;
localparam REG_ITIRQ_ADDRERR_LSB      = 0;
localparam REG_ITCTRL_ADDR               = 10'h3C0;
localparam REG_ITCTRL_IME_MSB            = 0;
localparam REG_ITCTRL_IME_LSB            = 0;
localparam REG_ITCTRL_IME_INIT           = 1'b0;

localparam REG_CLAIMSET_ADDR             = 10'h3E8;
localparam REG_CLAIMSET_SET_MSB          = 3;
localparam REG_CLAIMSET_SET_LSB          = 0;
localparam REG_CLAIMSET_SET_INIT         = 4'hF;
localparam REG_CLAIMCLR_ADDR             = 10'h3E9;
localparam REG_CLAIMSET_CLR_MSB          = 3;
localparam REG_CLAIMSET_CLR_LSB          = 0;
localparam REG_CLAIMSET_CLR_INIT         = 4'h0;
localparam REG_DEVAFF0_ADDR              = 10'h3EA;
localparam REG_DEVAFF1_ADDR              = 10'h3EB;
localparam REG_LOCKACCESS_ADD            = 10'h3EC;
localparam REG_LOCKSTATUS_ADD            = 10'h3ED;
localparam REG_AUTHSTATUS_ADDR           = 10'h3EE;
localparam REG_AUTHSTATUS_HNID_MSB       = 11;
localparam REG_AUTHSTATUS_HNID_LSB       = 10;
localparam REG_AUTHSTATUS_HNID_INIT      = 2'h0;
localparam REG_AUTHSTATUS_HID_MSB        = 9;
localparam REG_AUTHSTATUS_HID_LSB        = 8;
localparam REG_AUTHSTATUS_HID_INIT       = 2'h0;
localparam REG_AUTHSTATUS_SNID_MSB       = 7;
localparam REG_AUTHSTATUS_SNID_LSB       = 6;
localparam REG_AUTHSTATUS_SNID_INIT      = 2'h0;
localparam REG_AUTHSTATUS_SID_MSB        = 5;
localparam REG_AUTHSTATUS_SID_LSB        = 4;
localparam REG_AUTHSTATUS_SID_INIT       = 1'h1;
localparam REG_AUTHSTATUS_NSNID_MSB      = 3;
localparam REG_AUTHSTATUS_NSNID_LSB      = 2;
localparam REG_AUTHSTATUS_NSNID_INIT     = 2'h0;
localparam REG_AUTHSTATUS_NSID_MSB       = 1;
localparam REG_AUTHSTATUS_NSID_LSB       = 0;
localparam REG_AUTHSTATUS_NSID_INIT      = 1'h1;
localparam REG_DEVARCH_ADDR              = 10'h3EF;
localparam REG_DEVARCH_ARCHITECT_MSB     = 31;
localparam REG_DEVARCH_ARCHITECT_LSB     = 21;
localparam REG_DEVARCH_ARCHITECT_INIT    = 11'h0;
localparam REG_DEVARCH_PRESENT_MSB       = 20;
localparam REG_DEVARCH_PRESENT_LSB       = 20;
localparam REG_DEVARCH_PRESENT_INIT      = 1'h0;
localparam REG_DEVARCH_REVISION_MSB      = 19;
localparam REG_DEVARCH_REVISION_LSB      = 16;
localparam REG_DEVARCH_REVISION_INIT     = 4'h0;
localparam REG_DEVARCH_ARCHID_MSB        = 15;
localparam REG_DEVARCH_ARCHID_LSB        = 0;
localparam REG_DEVARCH_ARCHID_INIT       = 16'h0;
localparam REG_DEVID2_ADDR               = 10'h3F0;
localparam REG_DEVID1_ADDR               = 10'h3F1;
localparam REG_DEVID_ADDR                = 10'h3F2;
localparam REG_DEVID_AXIDW_MSB           = 12;
localparam REG_DEVID_AXIDW_LSB           = 8;
localparam REG_DEVID_AXIAW_MSB           = 6;
localparam REG_DEVID_AXIAW_LSB           = 0;
localparam REG_DEVTYPE_ADDR              = 10'h3F3;
localparam REG_DEVTYPE_SUB_MSB           = 7;
localparam REG_DEVTYPE_SUB_LSB           = 4;
localparam REG_DEVTYPE_SUB_INIT          = 4'h0;
localparam REG_DEVTYPE_MAJOR_MSB         = 3;
localparam REG_DEVTYPE_MAJOR_LSB         = 0;
localparam REG_DEVTYPE_MAJOR_INIT        = 4'h0;
localparam REG_PIDR4_ADDR                = 10'h3F4;
localparam REG_PIDR4_SIZE_MSB            = 7;
localparam REG_PIDR4_SIZE_LSB            = 4;
localparam REG_PIDR4_SIZE_INIT           = 4'h0;
localparam REG_PIDR4_DES2_MSB            = 3;
localparam REG_PIDR4_DES2_LSB            = 0;
localparam REG_PIDR4_DES2_INIT           = 4'h4;
localparam REG_PIDR5_ADDR                = 10'h3F5;
localparam REG_PIDR6_ADDR                = 10'h3F6;
localparam REG_PIDR7_ADDR                = 10'h3F7;
localparam REG_PIDR0_ADDR                = 10'h3F8;
localparam REG_PIDR0_PART0_MSB           = 7;
localparam REG_PIDR0_PART0_LSB           = 0;
localparam REG_PIDR0_PART0_INIT          = 8'hEE;
localparam REG_PIDR1_ADDR                = 10'h3F9;
localparam REG_PIDR1_DES0_MSB            = 7;
localparam REG_PIDR1_DES0_LSB            = 4;
localparam REG_PIDR1_DES0_INIT           = 4'hB;
localparam REG_PIDR1_PART1_MSB           = 3;
localparam REG_PIDR1_PART1_LSB           = 0;
localparam REG_PIDR1_PART1_INIT          = 4'h9;
localparam REG_PIDR2_ADDR                = 10'h3FA;
localparam REG_PIDR2_REVISION_MSB        = 7;
localparam REG_PIDR2_REVISION_LSB        = 4;
localparam REG_PIDR2_REVISION_INIT       = 4'h1;
localparam REG_PIDR2_JEDEC_MSB           = 3;
localparam REG_PIDR2_JEDEC_LSB           = 3;
localparam REG_PIDR2_JEDEC_INIT          = 1'h1;
localparam REG_PIDR2_DES1_MSB            = 2;
localparam REG_PIDR2_DES1_LSB            = 0;
localparam REG_PIDR2_DES1_INIT           = 3'h3;
localparam REG_PIDR3_ADDR                = 10'h3FB;
localparam REG_PIDR3_REVAND_MSB          = 7;
localparam REG_PIDR3_REVAND_LSB          = 4;
localparam REG_PIDR3_CMOD_MSB            = 3;
localparam REG_PIDR3_CMOD_LSB            = 0;
localparam REG_PIDR3_CMOD_INIT           = 4'h0;
localparam REG_CIDR0_ADDR                = 10'h3FC;
localparam REG_CIDR0_PRMBL_0_MSB         = 7;
localparam REG_CIDR0_PRMBL_0_LSB         = 0;
localparam REG_CIDR0_PRMBL_0_INIT        = 8'h0D;
localparam REG_CIDR1_ADDR                = 10'h3FD;
localparam REG_CIDR1_CLASS_MSB           = 7;
localparam REG_CIDR1_CLASS_LSB           = 4;
localparam REG_CIDR1_CLASS_INIT          = 4'h9;
localparam REG_CIDR1_PRMBL_1_MSB         = 3;
localparam REG_CIDR1_PRMBL_1_LSB         = 0;
localparam REG_CIDR1_PRMBL_1_INIT        = 4'h0;
localparam REG_CIDR2_ADDR                = 10'h3FE;
localparam REG_CIDR2_PRMBL_2_MSB         = 7;
localparam REG_CIDR2_PRMBL_2_LSB         = 0;
localparam REG_CIDR2_PRMBL_2_INIT        = 8'h05;
localparam REG_CIDR3_ADDR                = 10'h3FF;
localparam REG_CIDR3_PRMBL_3_MSB         = 7;
localparam REG_CIDR3_PRMBL_3_LSB         = 0;
localparam REG_CIDR3_PRMBL_3_INIT        = 8'hB1;


