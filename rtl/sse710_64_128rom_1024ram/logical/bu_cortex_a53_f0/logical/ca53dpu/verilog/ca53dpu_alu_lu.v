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
// Abstract : Logic Unit for ca53dpu
//-----------------------------------------------------------------------------
//
// Overview
// --------
// This module performs various logic functions (AND, OR etc) on the two
// operands.  There is additionally some multiplexing and sign extension
// logic used for some of the bitfield extract instructions
//
//          Q
// A | B || AND | ORR | BIC | EOR | ORN | MOVA | MOVB
// --+---++-----+-----+-----+-----+-----+------+------
// 0 | 0 ||  0  |  0  |  0  |  0  |  1  |   0  |   0
// 0 | 1 ||  0  |  1  |  0  |  1  |  0  |   0  |   1
// 1 | 0 ||  0  |  1  |  1  |  1  |  1  |   1  |   0
// 1 | 1 ||  1  |  1  |  0  |  0  |  1  |   1  |   1
// --+---++-----+-----+-----+-----+-----+------+------
// lu_ctl:  1000| 1110| 0100| 0110| 1101| 1100 | 1010           
//                                      | also encoded as ORR with other operand as 0
//
// Note that instructions which do MOVA/MOVB are always encoded as ORR with 0,
// but skewed operations, which need to select the B operand whilst preserving
// the original A operand into Ex2 (for base restore) use an explicit MOVB
// control pattern.
// 
//-----------------------------------------------------------------------------

module ca53dpu_alu_lu (
  // Inputs
  input  wire   [3:0] lu_ctl_i,
  input  wire  [63:0] data_a_i,
  input  wire  [63:0] data_b_i,
  // Outputs
  output wire  [63:0] lu_out_o
  );

  genvar i;

  reg  [63:0] lu_out;

  generate for (i = 0; i < 64; i = i + 1) begin : g_lu
    always @*
      case ({data_a_i[i], data_b_i[i]})
        2'b11   : lu_out[i] = lu_ctl_i[3];
        2'b10   : lu_out[i] = lu_ctl_i[2];
        2'b01   : lu_out[i] = lu_ctl_i[1];
        2'b00   : lu_out[i] = lu_ctl_i[0];
        default : lu_out[i] = 1'bx;
      endcase
  end endgenerate

  assign lu_out_o[63:0] = lu_out[63:0];

endmodule // ca53dpu_alu_lu
