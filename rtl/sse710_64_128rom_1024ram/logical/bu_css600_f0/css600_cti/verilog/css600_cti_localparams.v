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
//   Parameters for css600_cti
//
//----------------------------------------------------------------------------


localparam CTICONTROL_ADDR    = 10'h000;
localparam CTIINTACK_ADDR     = 10'h004;
localparam CTIAPPSET_ADDR     = 10'h005;
localparam CTIAPPCLEAR_ADDR   = 10'h006;
localparam CTIAPPPULSE_ADDR   = 10'h007;

localparam CTIGATE_ADDR       = 10'h050;
localparam ASICCTRL_ADDR      = 10'h051;

localparam CTIINEN0_ADDR      = 10'h008;
localparam CTIINEN1_ADDR      = 10'h009;
localparam CTIINEN2_ADDR      = 10'h00A;
localparam CTIINEN3_ADDR      = 10'h00B;
localparam CTIINEN4_ADDR      = 10'h00C;
localparam CTIINEN5_ADDR      = 10'h00D;
localparam CTIINEN6_ADDR      = 10'h00E;
localparam CTIINEN7_ADDR      = 10'h00F;
localparam CTIINEN8_ADDR      = 10'h010;
localparam CTIINEN9_ADDR      = 10'h011;
localparam CTIINEN10_ADDR     = 10'h012;
localparam CTIINEN11_ADDR     = 10'h013;
localparam CTIINEN12_ADDR     = 10'h014;
localparam CTIINEN13_ADDR     = 10'h015;
localparam CTIINEN14_ADDR     = 10'h016;
localparam CTIINEN15_ADDR     = 10'h017;
localparam CTIINEN16_ADDR     = 10'h018;
localparam CTIINEN17_ADDR     = 10'h019;
localparam CTIINEN18_ADDR     = 10'h01A;
localparam CTIINEN19_ADDR     = 10'h01B;
localparam CTIINEN20_ADDR     = 10'h01C;
localparam CTIINEN21_ADDR     = 10'h01D;
localparam CTIINEN22_ADDR     = 10'h01E;
localparam CTIINEN23_ADDR     = 10'h01F;
localparam CTIINEN24_ADDR     = 10'h020;
localparam CTIINEN25_ADDR     = 10'h021;
localparam CTIINEN26_ADDR     = 10'h022;
localparam CTIINEN27_ADDR     = 10'h023;
localparam CTIINEN28_ADDR     = 10'h024;
localparam CTIINEN29_ADDR     = 10'h025;
localparam CTIINEN30_ADDR     = 10'h026;
localparam CTIINEN31_ADDR     = 10'h027;

localparam CTIOUTEN0_ADDR     = 10'h028;
localparam CTIOUTEN1_ADDR     = 10'h029;
localparam CTIOUTEN2_ADDR     = 10'h02A;
localparam CTIOUTEN3_ADDR     = 10'h02B;
localparam CTIOUTEN4_ADDR     = 10'h02C;
localparam CTIOUTEN5_ADDR     = 10'h02D;
localparam CTIOUTEN6_ADDR     = 10'h02E;
localparam CTIOUTEN7_ADDR     = 10'h02F;
localparam CTIOUTEN8_ADDR     = 10'h030;
localparam CTIOUTEN9_ADDR     = 10'h031;
localparam CTIOUTEN10_ADDR    = 10'h032;
localparam CTIOUTEN11_ADDR    = 10'h033;
localparam CTIOUTEN12_ADDR    = 10'h034;
localparam CTIOUTEN13_ADDR    = 10'h035;
localparam CTIOUTEN14_ADDR    = 10'h036;
localparam CTIOUTEN15_ADDR    = 10'h037;
localparam CTIOUTEN16_ADDR    = 10'h038;
localparam CTIOUTEN17_ADDR    = 10'h039;
localparam CTIOUTEN18_ADDR    = 10'h03A;
localparam CTIOUTEN19_ADDR    = 10'h03B;
localparam CTIOUTEN20_ADDR    = 10'h03C;
localparam CTIOUTEN21_ADDR    = 10'h03D;
localparam CTIOUTEN22_ADDR    = 10'h03E;
localparam CTIOUTEN23_ADDR    = 10'h03F;
localparam CTIOUTEN24_ADDR    = 10'h040;
localparam CTIOUTEN25_ADDR    = 10'h041;
localparam CTIOUTEN26_ADDR    = 10'h042;
localparam CTIOUTEN27_ADDR    = 10'h043;
localparam CTIOUTEN28_ADDR    = 10'h044;
localparam CTIOUTEN29_ADDR    = 10'h045;
localparam CTIOUTEN30_ADDR    = 10'h046;
localparam CTIOUTEN31_ADDR    = 10'h047;

localparam TRIGINSTATUS_ADDR  = 10'h04C;
localparam TRIGOUTSTATUS_ADDR = 10'h04D;
localparam CHINSTATUS_ADDR    = 10'h04E;
localparam CHOUTSTATUS_ADDR   = 10'h04F;

localparam ITCTRL_ADDR        = 10'h3C0;
localparam ITCHINACK_ADDR     = 10'h3B7;
localparam ITTRIGINACK_ADDR   = 10'h3B8;
localparam ITCHOUT_ADDR       = 10'h3B9;
localparam ITTRIGOUT_ADDR     = 10'h3BA;
localparam ITCHOUTACK_ADDR    = 10'h3BB;
localparam ITTRIGOUTACK_ADDR  = 10'h3BC;
localparam ITCHIN_ADDR        = 10'h3BD;
localparam ITTRIGIN_ADDR      = 10'h3BE;

localparam CLAIMSET_ADDR   = 10'h3E8;
localparam CLAIMCLR_ADDR   = 10'h3E9;
localparam DEVAFF0_ADDR    = 10'h3EA;
localparam DEVAFF1_ADDR    = 10'h3EB;
localparam LOCKACCESS_ADD  = 10'h3EC;
localparam LOCKSTATUS_ADD  = 10'h3ED;
localparam AUTHSTATUS_ADDR = 10'h3EE;
localparam DEVARCH_ADDR    = 10'h3EF;
localparam DEVID2_ADDR     = 10'h3F0;
localparam DEVID1_ADDR     = 10'h3F1;
localparam DEVID_ADDR      = 10'h3F2;
localparam DEVTYPE_ADDR    = 10'h3F3;
localparam PIDR4_ADDR      = 10'h3F4;
localparam PIDR5_ADDR      = 10'h3F5;
localparam PIDR6_ADDR      = 10'h3F6;
localparam PIDR7_ADDR      = 10'h3F7;
localparam PIDR0_ADDR      = 10'h3F8;
localparam PIDR1_ADDR      = 10'h3F9;
localparam PIDR2_ADDR      = 10'h3FA;
localparam PIDR3_ADDR      = 10'h3FB;
localparam CIDR0_ADDR      = 10'h3FC;
localparam CIDR1_ADDR      = 10'h3FD;
localparam CIDR2_ADDR      = 10'h3FE;
localparam CIDR3_ADDR      = 10'h3FF;

localparam CLAIMSET_VAL           = 4'hF;
localparam AUTHSTATUS_NSID_VAL    = 1'h1;
localparam AUTHSTATUS_NSNID_VAL   = 1'h1;
localparam AUTHSTATUS_SID_VAL     = 1'h0;
localparam AUTHSTATUS_SNID_VAL    = 1'h0;
localparam DEVARCH_ARCHITECT_VAL  = 11'h23B;
localparam DEVARCH_PRESENT_VAL    = 1'h1;
localparam DEVARCH_REVISION_VAL   = 4'h0;
localparam DEVARCH_ARCHID_VAL     = 16'h1A14;
localparam DEVTYPE_SUB_VAL        = 4'h1;
localparam DEVTYPE_MAJOR_VAL      = 4'h4;
localparam PIDR4_SIZE_VAL         = 4'h0;
localparam PIDR4_DES2_VAL         = 4'h4;
localparam PIDR0_PART0_VAL        = 8'hED;
localparam PIDR1_DES0_VAL         = 4'hB;
localparam PIDR1_PART1_VAL        = 4'h9;
localparam PIDR2_REVISION_VAL     = 4'h3;
localparam PIDR2_JEDEC_VAL        = 1'h1;
localparam PIDR2_DES1_VAL         = 3'h3;
localparam PIDR3_CMOD_VAL         = 4'h0;
localparam CIDR0_VAL              = 8'h0D;
localparam CIDR1_VAL              = 8'h90;
localparam CIDR2_VAL              = 8'h05;
localparam CIDR3_VAL              = 8'hB1;

