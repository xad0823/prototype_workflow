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
//      Checked In          : $Date: 2010-06-29 16:17:26 +0100 (Tue, 29 Jun 2010) $
//
//      Revision            : $Revision: 141876 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Expand encoded addresses into one-hot form
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_ctl_regexpand (
  input  wire                       [5:0] raw_rf_rd_addr_i, // Encoded register
  output reg   [`CA53_LONG_RF_ADDR_W-1:0] exp_rf_rd_addr_o  // Expanded register
);

  always @* begin
    exp_rf_rd_addr_o = {`CA53_LONG_RF_ADDR_W{1'b0}};
    case (raw_rf_rd_addr_i[5:0])
      `CA53_ADDR_X0       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X0]       = 1'b1;
      `CA53_ADDR_X1       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X1]       = 1'b1;
      `CA53_ADDR_X2       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X2]       = 1'b1;
      `CA53_ADDR_X3       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X3]       = 1'b1;
      `CA53_ADDR_X4       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X4]       = 1'b1;
      `CA53_ADDR_X5       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X5]       = 1'b1;
      `CA53_ADDR_X6       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X6]       = 1'b1;
      `CA53_ADDR_X7       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X7]       = 1'b1;
      `CA53_ADDR_X8       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X8]       = 1'b1;
      `CA53_ADDR_X9       : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X9]       = 1'b1;
      `CA53_ADDR_X10      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X10]      = 1'b1;
      `CA53_ADDR_X11      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X11]      = 1'b1;
      `CA53_ADDR_X12      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X12]      = 1'b1;
      `CA53_ADDR_X13      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X13]      = 1'b1;
      `CA53_ADDR_X14      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X14]      = 1'b1;
      `CA53_ADDR_X15      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X15]      = 1'b1;
      `CA53_ADDR_X16      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X16]      = 1'b1;
      `CA53_ADDR_X17      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X17]      = 1'b1;
      `CA53_ADDR_X18      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X18]      = 1'b1;
      `CA53_ADDR_X19      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X19]      = 1'b1;
      `CA53_ADDR_X20      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X20]      = 1'b1;
      `CA53_ADDR_X21      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X21]      = 1'b1;
      `CA53_ADDR_X22      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X22]      = 1'b1;
      `CA53_ADDR_X23      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X23]      = 1'b1;
      `CA53_ADDR_X24      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X24]      = 1'b1;
      `CA53_ADDR_X25      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X25]      = 1'b1;
      `CA53_ADDR_X26      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X26]      = 1'b1;
      `CA53_ADDR_X27      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X27]      = 1'b1;
      `CA53_ADDR_X28      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X28]      = 1'b1;
      `CA53_ADDR_X29      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X29]      = 1'b1;
      `CA53_ADDR_X30      : exp_rf_rd_addr_o[`CA53_ADDR_BIT_X30]      = 1'b1;
      `CA53_ADDR_SP_EL0   : exp_rf_rd_addr_o[`CA53_ADDR_BIT_SP_EL0]   = 1'b1;
      `CA53_ADDR_SP_EL1   : exp_rf_rd_addr_o[`CA53_ADDR_BIT_SP_EL1]   = 1'b1;
      `CA53_ADDR_SP_EL2   : exp_rf_rd_addr_o[`CA53_ADDR_BIT_SP_EL2]   = 1'b1;
      `CA53_ADDR_SP_EL3   : exp_rf_rd_addr_o[`CA53_ADDR_BIT_SP_EL3]   = 1'b1;
      `CA53_ADDR_ELR_EL1  : exp_rf_rd_addr_o[`CA53_ADDR_BIT_ELR_EL1]  = 1'b1;
      `CA53_ADDR_ELR_EL2  : exp_rf_rd_addr_o[`CA53_ADDR_BIT_ELR_EL2]  = 1'b1;
      `CA53_ADDR_ELR_EL3  : exp_rf_rd_addr_o[`CA53_ADDR_BIT_ELR_EL3]  = 1'b1;
      default             : exp_rf_rd_addr_o                          = {`CA53_LONG_RF_ADDR_W{1'bx}};
    endcase
  end

endmodule // ca53dpu_ctl_regexpand

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
