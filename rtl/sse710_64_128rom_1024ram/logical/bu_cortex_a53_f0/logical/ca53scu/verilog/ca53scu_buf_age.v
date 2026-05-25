//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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
// Description:
//  Age tracking logic for determining the order in which buffers became valid.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_buf_age #(parameter NUM_BUFS = 4)
 (
  input  wire                         clk,
  input  wire                         reset_n,

  input  wire [NUM_BUFS-1:0]          buf_alloc_i,
  output wire [NUM_BUFS*NUM_BUFS-1:0] buf_older_o
);

  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  genvar i;
  genvar j;

  wire [NUM_BUFS-1:0] buf_older [NUM_BUFS-1:0];
  wire                buf_older_en;

  //----------------------------------------------------------------------------
  //  Main logic
  //----------------------------------------------------------------------------

  // In order to maintain ordering between requests, the buffer ordering bits are maintained.
  // These form a matrix. The ordering bit in the i-th row and j-th column indicates that
  // the i-th request buffer is ordered after the j-th if it is set, or the reverse otherwise.
  // For example, if there were four request buffers:
  //
  //      A  B  C  D
  //   A  0  0  1  0
  //   B  1  0  1  1
  //   C  0  0  0  0
  //   D  1  0  1  0
  //
  // This set of bits indicates that the buffers are ordered C (oldest), A, D, B (youngest).
  // It can be observed that the bits on the diagonal (where i == j) are always zero, and that
  // the bits in the lower-left triangle are a complement of those in the upper-right triangle.
  // As such, it is only necessary to actually register the upper-right triangle of bits.
  //
  // When a request buffer is allocated, it becomes the youngest buffer, and so all bits in
  // the row corresponding to that buffer are set, and all bits in the corresponding column
  // are cleared.

  assign buf_older_en = |buf_alloc_i;

  generate for (i = 0; i < NUM_BUFS; i = i + 1) begin : g_buf_loop1

    for (j = 0; j < NUM_BUFS; j = j + 1) begin : g_buf_loop3
      // Output for each buf which other bufs are older than it.
      if (j < i) begin : g_buf1
        reg  older_bit;
        wire next_older_bit;

        assign next_older_bit = (buf_alloc_i[i] | buf_older[i][j]) & ~buf_alloc_i[j];

        always @(posedge clk)
        if (buf_older_en) begin
          older_bit <= next_older_bit;
        end

        assign buf_older[i][j] = older_bit;
      end else if (j > i) begin : g_buf2
        assign buf_older[i][j] = ~buf_older[j][i];
      end else begin : g_buf3
        assign buf_older[i][j] = 1'b0;
      end
    end

    assign buf_older_o[NUM_BUFS*i +: NUM_BUFS] = buf_older[i];

  end endgenerate

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  generate for (i = 0; i < NUM_BUFS; i = i + 1) begin : g_ovl_buf_loop1

    assert_never #(`OVL_FATAL, `OVL_ASSERT, "A buffer must never be older than itself")
    u_ovl_buf_older (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr (buf_older_o[NUM_BUFS*i + i]));
  end endgenerate

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: buf_older_en")
  u_ovl_x_buf_older_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (buf_older_en));


`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
