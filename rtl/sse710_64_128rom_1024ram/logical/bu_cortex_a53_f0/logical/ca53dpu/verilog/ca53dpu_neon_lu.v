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

//-----------------------------------------------------------------------------
// Abstract : Logic Unit for ca53dpu.
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

// Overview
// --------
// This module performs various logic functions (AND, OR etc) on the two
// operands.  There is additionally some multiplexing and sign extension
// logic used for some of the bitfield extract instructions
//
//              Q
// A | B | C || AND | BIC | BIF | BIT | BSL | EOR | MOV | MVN | ORN | ORR | VCGT | VCEQ |
// --+---+---++-----+-----+-----+-----+-----+-----+-----+-----+------+----+--------------
// 0 | 0 | 0 ||  0  |  0  |  0  |  0  |  0  |  0  |  0  |  1  |  1  |  0  |   0  |   0  |
// 0 | 0 | 1 ||  0  |  0  |  0  |  1  |  0  |  0  |  0  |  1  |  1  |  0  |   0  |   0  |
// 0 | 1 | 0 ||  0  |  0  |  0  |  0  |  1  |  1  |  1  |  0  |  0  |  1  |   0  |   1  |
// 0 | 1 | 1 ||  0  |  0  |  1  |  0  |  0  |  1  |  1  |  0  |  0  |  1  |   0  |   1  |
// 1 | 0 | 0 ||  0  |  1  |  1  |  0  |  0  |  1  |  0  |  1  |  1  |  1  |   1  |   0  |
// 1 | 0 | 1 ||  0  |  1  |  1  |  1  |  1  |  1  |  0  |  1  |  1  |  1  |   1  |   0  |
// 1 | 1 | 0 ||  1  |  0  |  0  |  1  |  1  |  0  |  1  |  0  |  1  |  1  |   1  |   1  |
// 1 | 1 | 1 ||  1  |  0  |  1  |  1  |  1  |  0  |  1  |  0  |  1  |  1  |   1  |   1  |
// --+---+---++-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+------+-------
// lu_ctl:     0001| 0010 | 0011| 0100| 0101| 0110| 0111| 1000| 1001| 1010| 1100 | 1101 |

module ca53dpu_neon_lu (
  // Inputs
  input  wire   [7:0] neon_lu_ctl_f3_i,   // Which logic function is applied to A and B inputs
  input  wire  [63:0] frc_opa_f3_i,       // Vn operand
  input  wire  [63:0] frc_opb_f3_i,       // Vm operand
  input  wire  [63:0] neon_frc_opc_f3_i,  // Vd operand
  // Outputs
  output wire  [63:0] neon_lu_res_f3_o    // Final result
);


  // -----------------------------
  // Genvar declaration
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [63:0] lu_f3;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  generate for (i = 0; i < 64; i = i + 1) begin : g_lu
    always @*
      case({frc_opa_f3_i[i], frc_opb_f3_i[i], neon_frc_opc_f3_i[i]})
        3'b111  : lu_f3[i] = neon_lu_ctl_f3_i[7];
        3'b110  : lu_f3[i] = neon_lu_ctl_f3_i[6];
        3'b101  : lu_f3[i] = neon_lu_ctl_f3_i[5];
        3'b100  : lu_f3[i] = neon_lu_ctl_f3_i[4];
        3'b011  : lu_f3[i] = neon_lu_ctl_f3_i[3];
        3'b010  : lu_f3[i] = neon_lu_ctl_f3_i[2];
        3'b001  : lu_f3[i] = neon_lu_ctl_f3_i[1];
        3'b000  : lu_f3[i] = neon_lu_ctl_f3_i[0];
        default : lu_f3[i] = 1'bx;
      endcase
  end endgenerate

  // Aliasing for Output
  assign neon_lu_res_f3_o[63:0] = lu_f3[63:0];

endmodule // ca53dpu_neon_lu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
