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

//---------------------------------------------------------------------------
// Ex2 stage extract unit
//
// Used by AA32 extend instructions which do not use the ALU - by putting in Ex2
// can accept forwarded data later, reducing interlocks
//--------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_extract (
  input  wire                                   zero_sign_extend_i,
  input  wire  [`CA53_ALU_EX1_XTRACT_TYP_W-1:0] extract_type_i,
  input  wire                            [23:0] rotated_data_i,

  output reg                             [31:0] extracted_data_o
);

  always @*
    case (extract_type_i)
      `CA53_EXTRACT_LS_BYTE:
        case (zero_sign_extend_i)
          1'b0:     extracted_data_o = {{24{1'b0}},               rotated_data_i[ 7: 0]};
          1'b1:     extracted_data_o = {{24{rotated_data_i[ 7]}}, rotated_data_i[ 7: 0]};
          default:  extracted_data_o = {32{1'bx}};
        endcase

      `CA53_EXTRACT_LS_HWORD:
        case (zero_sign_extend_i)
          1'b0:     extracted_data_o = {{16{1'b0}},               rotated_data_i[15: 0]};
          1'b1:     extracted_data_o = {{16{rotated_data_i[15]}}, rotated_data_i[15: 0]};
          default:  extracted_data_o = {32{1'bx}};
        endcase

      `CA53_EXTRACT_TWO_BYTES:
        case (zero_sign_extend_i)
          1'b0:     extracted_data_o = {{8{1'b0}},               rotated_data_i[23:16],
                                        {8{1'b0}},               rotated_data_i[ 7: 0]};
          1'b1:     extracted_data_o = {{8{rotated_data_i[23]}}, rotated_data_i[23:16],
                                        {8{rotated_data_i[ 7]}}, rotated_data_i[ 7: 0]};
          default:  extracted_data_o = {32{1'bx}};
        endcase

      `CA53_EXTRACT_SH_BYTE,
      `CA53_EXTRACT_SH_HWORD,
      `CA53_EXTRACT_SH_WORD,
      `CA53_EXTRACT_SH_XWORD:
        extracted_data_o = {32{1'b0}};
      default:  extracted_data_o = {32{1'bx}};
    endcase

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
