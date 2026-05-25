//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------


`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_clz106 (
  input  wire [105:0] opa,
  output wire [  6:0] res
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [2:0] clz_byte[13:0];

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [13:1] check_byte;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Byte evaluation
  // ------------------------------------------------------

  // Evaluate each byte to see if it contains a '1'
  assign check_byte[1]  = |(opa[  9: 2]);
  assign check_byte[2]  = |(opa[ 17:10]);
  assign check_byte[3]  = |(opa[ 25:18]);
  assign check_byte[4]  = |(opa[ 33:26]);
  assign check_byte[5]  = |(opa[ 41:34]);
  assign check_byte[6]  = |(opa[ 49:42]);
  assign check_byte[7]  = |(opa[ 57:50]);
  assign check_byte[8]  = |(opa[ 65:58]);
  assign check_byte[9]  = |(opa[ 73:66]);
  assign check_byte[10] = |(opa[ 81:74]);
  assign check_byte[11] = |(opa[ 89:82]);
  assign check_byte[12] = |(opa[ 97:90]);
  assign check_byte[13] = |(opa[105:98]);

  // ------------------------------------------------------
  // Byte-0 leading '1' check
  // ------------------------------------------------------

  always @*
    case (opa[1:0])
      2'b11,
      2'b10   : clz_byte[0] = 3'b000;
      2'b01   : clz_byte[0] = 3'b001;
      2'b00   : clz_byte[0] = 3'b010;
      default : clz_byte[0] = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Bytes 1 to 13 leading '1' check
  // ------------------------------------------------------

  genvar i;
  generate for (i = 0; i < 13; i = i + 1) begin : g_byte
    always @*
      case (opa[105-(i*8)-:8])
        `ca53dpu_sel_1xxx_xxxx : clz_byte[13-i] = 3'b000;
        `ca53dpu_sel_01xx_xxxx : clz_byte[13-i] = 3'b001;
        `ca53dpu_sel_001x_xxxx : clz_byte[13-i] = 3'b010;
        `ca53dpu_sel_0001_xxxx : clz_byte[13-i] = 3'b011;
        `ca53dpu_sel_0000_1xxx : clz_byte[13-i] = 3'b100;
        `ca53dpu_sel_0000_01xx : clz_byte[13-i] = 3'b101;
        `ca53dpu_sel_0000_001x : clz_byte[13-i] = 3'b110;
          8'b0000_0001         : clz_byte[13-i] = 3'b111;
        default                : clz_byte[13-i] = 3'bxxx;
      endcase
  end endgenerate

  // ------------------------------------------------------
  // Select between results
  // ------------------------------------------------------

  assign res = check_byte[13] ? {4'b0000, clz_byte[13]} :
               check_byte[12] ? {4'b0001, clz_byte[12]} :
               check_byte[11] ? {4'b0010, clz_byte[11]} :
               check_byte[10] ? {4'b0011, clz_byte[10]} :
               check_byte[ 9] ? {4'b0100, clz_byte[ 9]} :
               check_byte[ 8] ? {4'b0101, clz_byte[ 8]} :
               check_byte[ 7] ? {4'b0110, clz_byte[ 7]} :
               check_byte[ 6] ? {4'b0111, clz_byte[ 6]} :
               check_byte[ 5] ? {4'b1000, clz_byte[ 5]} :
               check_byte[ 4] ? {4'b1001, clz_byte[ 4]} :
               check_byte[ 3] ? {4'b1010, clz_byte[ 3]} :
               check_byte[ 2] ? {4'b1011, clz_byte[ 2]} :
               check_byte[ 1] ? {4'b1100, clz_byte[ 1]} :
                                {4'b1101, clz_byte[ 0]};

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
