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
// Abstract: Bit reversal Unit
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block performs a bit reversal of the input data. It is required
// for the RBIT instruction
//
// pseudo_code of operation is as follows:
//
// for( i=0; i<32, i++)
//   output[i] = input[31-i]
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_rbit (
  input  wire  [31:0] alu_data_a_ex1_i,
  output wire  [31:0] alu_data_a_rbit_ex1_o
);

assign alu_data_a_rbit_ex1_o = {alu_data_a_ex1_i[0],
                                alu_data_a_ex1_i[1],
                                alu_data_a_ex1_i[2],
                                alu_data_a_ex1_i[3],
                                alu_data_a_ex1_i[4],
                                alu_data_a_ex1_i[5],
                                alu_data_a_ex1_i[6],
                                alu_data_a_ex1_i[7],
                                alu_data_a_ex1_i[8],
                                alu_data_a_ex1_i[9],
                                alu_data_a_ex1_i[10],
                                alu_data_a_ex1_i[11],
                                alu_data_a_ex1_i[12],
                                alu_data_a_ex1_i[13],
                                alu_data_a_ex1_i[14],
                                alu_data_a_ex1_i[15],
                                alu_data_a_ex1_i[16],
                                alu_data_a_ex1_i[17],
                                alu_data_a_ex1_i[18],
                                alu_data_a_ex1_i[19],
                                alu_data_a_ex1_i[20],
                                alu_data_a_ex1_i[21],
                                alu_data_a_ex1_i[22],
                                alu_data_a_ex1_i[23],
                                alu_data_a_ex1_i[24],
                                alu_data_a_ex1_i[25],
                                alu_data_a_ex1_i[26],
                                alu_data_a_ex1_i[27],
                                alu_data_a_ex1_i[28],
                                alu_data_a_ex1_i[29],
                                alu_data_a_ex1_i[30],
                                alu_data_a_ex1_i[31]};

endmodule // ca53dpu_alu_rbit

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
