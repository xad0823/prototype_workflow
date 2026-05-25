//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Expand encoded addresses into one-hot form
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de_regexpand (
  input  wire                       [5:0] rf_rd_addr_de_i,
  output reg   [`CA53_LONG_RF_ADDR_W-1:0] long_rf_rd_addr_de_o
);

  always @* begin
    long_rf_rd_addr_de_o = {`CA53_LONG_RF_ADDR_W{1'b0}};
    case (rf_rd_addr_de_i[5:0])
      `CA53_ADDR_X0       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X0]       = 1'b1;
      `CA53_ADDR_X1       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X1]       = 1'b1;
      `CA53_ADDR_X2       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X2]       = 1'b1;
      `CA53_ADDR_X3       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X3]       = 1'b1;
      `CA53_ADDR_X4       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X4]       = 1'b1;
      `CA53_ADDR_X5       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X5]       = 1'b1;
      `CA53_ADDR_X6       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X6]       = 1'b1;
      `CA53_ADDR_X7       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X7]       = 1'b1;
      `CA53_ADDR_X8       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X8]       = 1'b1;
      `CA53_ADDR_X9       : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X9]       = 1'b1;
      `CA53_ADDR_X10      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X10]      = 1'b1;
      `CA53_ADDR_X11      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X11]      = 1'b1;
      `CA53_ADDR_X12      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X12]      = 1'b1;
      `CA53_ADDR_X13      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X13]      = 1'b1;
      `CA53_ADDR_X14      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X14]      = 1'b1;
      `CA53_ADDR_X15      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X15]      = 1'b1;
      `CA53_ADDR_X16      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X16]      = 1'b1;
      `CA53_ADDR_X17      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X17]      = 1'b1;
      `CA53_ADDR_X18      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X18]      = 1'b1;
      `CA53_ADDR_X19      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X19]      = 1'b1;
      `CA53_ADDR_X20      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X20]      = 1'b1;
      `CA53_ADDR_X21      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X21]      = 1'b1;
      `CA53_ADDR_X22      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X22]      = 1'b1;
      `CA53_ADDR_X23      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X23]      = 1'b1;
      `CA53_ADDR_X24      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X24]      = 1'b1;
      `CA53_ADDR_X25      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X25]      = 1'b1;
      `CA53_ADDR_X26      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X26]      = 1'b1;
      `CA53_ADDR_X27      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X27]      = 1'b1;
      `CA53_ADDR_X28      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X28]      = 1'b1;
      `CA53_ADDR_X29      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X29]      = 1'b1;
      `CA53_ADDR_X30      : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_X30]      = 1'b1;
      `CA53_ADDR_SP_EL0   : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_SP_EL0]   = 1'b1;
      `CA53_ADDR_SP_EL1   : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_SP_EL1]   = 1'b1;
      `CA53_ADDR_SP_EL2   : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_SP_EL2]   = 1'b1;
      `CA53_ADDR_SP_EL3   : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_SP_EL3]   = 1'b1;
      `CA53_ADDR_ELR_EL1  : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_ELR_EL1]  = 1'b1;
      `CA53_ADDR_ELR_EL2  : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_ELR_EL2]  = 1'b1;
      `CA53_ADDR_ELR_EL3  : long_rf_rd_addr_de_o[`CA53_ADDR_BIT_ELR_EL3]  = 1'b1;
      default             : long_rf_rd_addr_de_o                          = {`CA53_LONG_RF_ADDR_W{1'bx}};
    endcase
  end

endmodule // ca53dpu_de_regexpand

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
