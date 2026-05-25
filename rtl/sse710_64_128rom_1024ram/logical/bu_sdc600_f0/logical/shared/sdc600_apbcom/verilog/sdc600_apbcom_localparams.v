//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu May 10 12:37:48 2018 +0200
//
//      Revision            : a2dc0a9
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

`include "sdc600_apbcom_variants.v"

localparam ADDR_ITSTATUS    = 12'hEFC;
localparam ADDR_ITCTRL      = 12'hF00;
localparam ADDR_CLAIMSET    = 12'hFA0;
localparam ADDR_CLAIMCLR    = 12'hFA4;
localparam ADDR_AUTHSTATUS  = 12'hFB8;
localparam ADDR_DEVARCH     = 12'hFBC;
localparam ADDR_DEVID       = 12'hFC8;
localparam ADDR_PIDR0       = 12'hFE0;
localparam ADDR_PIDR1       = 12'hFE4;
localparam ADDR_PIDR2       = 12'hFE8;
localparam ADDR_PIDR3       = 12'hFEC;
localparam ADDR_PIDR4       = 12'hFD0;
localparam ADDR_CIDR0       = 12'hFF0;
localparam ADDR_CIDR1       = 12'hFF4;
localparam ADDR_CIDR2       = 12'hFF8;
localparam ADDR_CIDR3       = 12'hFFC;
localparam ADDR_IDR         = 12'h0FC;
localparam ADDR_ROMENTRY    = (APBCOM_VAR == APBCOM_EXT_ROM) ? 12'h000 : 12'h003;
localparam ADDR_VIDR        = (APBCOM_VAR == COMAP) ? 12'h000 : 12'hD00;
localparam ADDR_FIDTXR      = (APBCOM_VAR == COMAP) ? 12'h008 : 12'hD08;
localparam ADDR_FIDRXR      = (APBCOM_VAR == COMAP) ? 12'h00C : 12'hD0C;
localparam ADDR_ICSR        = (APBCOM_VAR == COMAP) ? 12'h010 : 12'hD10;
localparam ADDR0_SR         = (APBCOM_VAR == COMAP) ? 12'h02C : 12'hD2C;
localparam ADDR1_SR         = (APBCOM_VAR == COMAP) ? 12'h03C : 12'hD3C;

localparam ADDR_DR          = (APBCOM_VAR == COMAP) ? 12'h020 : 12'hD20;
localparam ADDR_DBR         = (APBCOM_VAR == COMAP) ? 12'h030 : 12'hD30;


localparam C_JEDEC          = 1'b1;
localparam C_CMOD           = 4'h0;
localparam C_SIZE           = 4'h0;
localparam C_PIDR0          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},PART_NUMBER[7:0]}                 : {{24{1'b0}},8'hEF};
localparam C_PIDR1          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},JEP106_ID[3:0],PART_NUMBER[11:8]} : {{24{1'b0}},8'hB9};
localparam C_PIDR2          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},REVISION,C_JEDEC,JEP106_ID[6:4]}  : {{24{1'b0}},8'h0B};
localparam C_PIDR3          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},ECO_REV_AND,C_CMOD}               : {{24{1'b0}},8'h00};
localparam C_PIDR4          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},C_SIZE,JEP106_ID[10:7]}           : {{24{1'b0}},8'h04};


localparam C_PRMBL_0        = 8'h0D;
localparam C_CLASS          = 4'h9;
localparam C_PRMBL_1        = 4'h0;
localparam C_PRMBL_2        = 8'h05;
localparam C_PRMBL_3        = 8'hB1;
localparam C_CIDR0          = {{24{1'b0}},C_PRMBL_0};
localparam C_CIDR1          = {{24{1'b0}},C_CLASS,C_PRMBL_1};
localparam C_CIDR2          = {{24{1'b0}},C_PRMBL_2};
localparam C_CIDR3          = {{24{1'b0}},C_PRMBL_3};

localparam C_DEVID          = (APBCOM_VAR == APBCOM_EXT_ROM) ? {{24{1'b0}},8'h40} : {32{1'b0}};


localparam C_IDR            = (APBCOM_VAR == COMAP) ? 32'h0476_2000 : {32{1'b0}};


localparam C_VIDR           = {32{1'b0}};


localparam C_FIDTXR         = (APBCOM_VAR == APBCOM_INT) ?
                              {{21{1'b0}},1'b1,1'b0,1'b0,4'h1,2'b00,1'b1,1'b1} :
                              {{21{1'b0}},1'b1,1'b0,1'b0,4'h1,2'b00,1'b0,1'b1} ;

localparam C_FIDRXR         = (APBCOM_VAR == APBCOM_INT) ?
                              {{21{1'b0}},1'b1,1'b0,1'b0,6'h00,1'b1,1'b1} :
                              {{21{1'b0}},1'b1,1'b0,1'b0,6'h00,1'b0,1'b1} ;


localparam C_ARCHITECT        = 11'h23B;
localparam C_PRESENT          = 1'b1;
localparam C_DEVARCH_REVISION = 4'h0;
localparam C_ARCHID           = (APBCOM_VAR == APBCOM_EXT_ROM) ? 16'h0AF7 : 16'h0A57;
localparam C_DEVARCH          = {C_ARCHITECT,C_PRESENT,C_DEVARCH_REVISION,C_ARCHID};


localparam C_ROM_ENTRY0  = (APBCOM_VAR == APBCOM_EXT_ROM) ? ROM_ENTRY0[31:12] : {20{1'b0}};


localparam ECODATA_WIDTH    = 12;
localparam ECODATA          = {C_PIDR2[7:4],C_PIDR3[7:0]};

localparam FLAG_LPH1RA = 8'ha6;
localparam FLAG_LPH1RL = 8'ha7;
localparam FLAG_LPH2RA = 8'ha8;
localparam FLAG_LPH2RL = 8'ha9;
localparam FLAG_LERR   = 8'hab;
localparam FLAG_NULL   = 8'haf;


localparam ENCODED_LPH1RA = 3'b000;
localparam ENCODED_LPH1RL = 3'b001;
localparam ENCODED_LPH2RA = 3'b010;
localparam ENCODED_LPH2RL = 3'b011;
localparam ENCODED_LERR   = 3'b100;
localparam ENCODED_EMPTY  = 3'b111;
