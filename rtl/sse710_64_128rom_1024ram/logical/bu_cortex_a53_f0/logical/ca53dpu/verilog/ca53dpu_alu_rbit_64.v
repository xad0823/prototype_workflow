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
//      Checked In          : $Date: 2011-11-18 17:02:59 +0000 (Fri, 18 Nov 2011) $
//
//      Revision            : $Revision: 192060 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Bit reversal Unit - 64bit version
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block performs a bit reversal of the input data. It is required
// for the RBIT instruction
//
// pseudo_code of operation is as follows:
//
// for( i=0; i<64, i++)
//   output[i] = input[63-i]
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_rbit_64 (
  input  wire  [63:0] alu_data_a_ex1_i,
  output wire  [63:0] alu_data_a_rbit_ex1_o
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
                                alu_data_a_ex1_i[31],
                                alu_data_a_ex1_i[32],
                                alu_data_a_ex1_i[33],
                                alu_data_a_ex1_i[34],
                                alu_data_a_ex1_i[35],
                                alu_data_a_ex1_i[36],
                                alu_data_a_ex1_i[37],
                                alu_data_a_ex1_i[38],
                                alu_data_a_ex1_i[39],
                                alu_data_a_ex1_i[40],
                                alu_data_a_ex1_i[41],
                                alu_data_a_ex1_i[42],
                                alu_data_a_ex1_i[43],
                                alu_data_a_ex1_i[44],
                                alu_data_a_ex1_i[45],
                                alu_data_a_ex1_i[46],
                                alu_data_a_ex1_i[47],
                                alu_data_a_ex1_i[48],
                                alu_data_a_ex1_i[49],
                                alu_data_a_ex1_i[50],
                                alu_data_a_ex1_i[51],
                                alu_data_a_ex1_i[52],
                                alu_data_a_ex1_i[53],
                                alu_data_a_ex1_i[54],
                                alu_data_a_ex1_i[55],
                                alu_data_a_ex1_i[56],
                                alu_data_a_ex1_i[57],
                                alu_data_a_ex1_i[58],
                                alu_data_a_ex1_i[59],
                                alu_data_a_ex1_i[60],
                                alu_data_a_ex1_i[61],
                                alu_data_a_ex1_i[62],
                                alu_data_a_ex1_i[63]};

endmodule // ca53dpu_alu_rbit

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
