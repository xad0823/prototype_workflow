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
//   Parameters for css600_apbrom
//
//----------------------------------------------------------------------------


  localparam L_NUM_ENTRIES     = NUM_ENTRIES <= 512
                                 ? NUM_ENTRIES
                                 : 1;
  localparam L_TIE_OFF_PRESENT = (TIE_OFF_PRESENT == 1) ? 1'b1 : 1'b0;
  localparam L_NUM_DBGPWRUP_MASTERS = ((NUM_DBGPWRUP_MASTERS >= 1)
                                    && (NUM_DBGPWRUP_MASTERS <= 32))
                                      ? NUM_DBGPWRUP_MASTERS
                                      : 1;
  localparam L_NUM_SYSPWRUP_MASTERS = ((NUM_SYSPWRUP_MASTERS >= 1)
                                    && (NUM_SYSPWRUP_MASTERS <= 32))
                                      ? NUM_SYSPWRUP_MASTERS
                                      : 1;
  localparam L_FF_SYNC_DEPTH     = (FF_SYNC_DEPTH == 3)
                                 ? 3
                                 : 2;
  localparam PRIDR0_NO_GPR     = 32'h00000000;
  localparam PRIDR0_GPR        = 32'h00000031;
  localparam PWR_NO_GPR        = 32'h00000000;
  localparam RST_NO_GPR        = 32'h00000000;
  localparam DEVARCH           = 32'h47700AF7;
  localparam DEVID_NO_GPR      = (SYSMEM == 1)
                                 ? 32'h00000010
                                 : 32'h00000000;
  localparam DEVID_GPR         = (SYSMEM == 1)
                                 ? 32'h00000030
                                 : 32'h00000020;
  localparam SIZE              = 4'h0;
  localparam PERIPHID5         = 8'h00;
  localparam PERIPHID6         = 8'h00;
  localparam PERIPHID7         = 8'h00;
  localparam CMOD              = 4'h0;
  localparam PRMBL_0           = 8'h0D;
  localparam PRMBL_1           = 4'h0;
  localparam PRMBL_2           = 8'h05;
  localparam PRMBL_3           = 8'hB1;
  localparam CMP_CLASS         = 4'h9;


