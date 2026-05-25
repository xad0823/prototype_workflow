//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//
module xhb500_reverse_regd_slice_rst_empty
#(
  parameter PAYLD_WIDTH = 2
)
(
  input wire logic                     clk,
  input wire logic                     resetn,

  output     logic                     empty,

  input wire logic                     valid_src,
  input wire logic [PAYLD_WIDTH-1:0]   payload_src,
  output     logic                     ready_src,

  input wire logic                     ready_dst,
  output     logic                     valid_dst,
  output     logic [PAYLD_WIDTH-1:0]   payload_dst
);

  localparam NUM_SEL_LINES        = (PAYLD_WIDTH + 7) / 8;
  localparam REM_SEL_LINE         = (((PAYLD_WIDTH - 1) % 8) + 1);

  logic [PAYLD_WIDTH-1:0]           payload_reg;
  logic [NUM_SEL_LINES:0]           buffer_full;



  wire logic buffer_en = (valid_src & ~buffer_full[0] & ~ready_dst);

  always_ff @ (posedge clk or negedge resetn) begin : p_buffer_seq
    if (~resetn)
      payload_reg <= '0;
    else if (buffer_en)
      payload_reg <= payload_src;
  end

  wire logic buffer_full_en = (buffer_en | ready_dst);

  always_ff @ (negedge resetn or posedge clk)
  begin : p_buffer_full_seq
    if (~resetn)
      buffer_full <= '0;
    else if (buffer_full_en)
      buffer_full <= {NUM_SEL_LINES+1{buffer_en}};
  end

  assign ready_src = ~buffer_full[0];


  assign valid_dst = (valid_src | buffer_full[0]);

  always_comb
  begin : p_payload_mux
    integer base;
    base = 0;
    for (int i=1; i<NUM_SEL_LINES; i=i+1)
    begin
      for (int j=base; j<(base+8); j=j+1)
        payload_dst[j] = (buffer_full[i] ? payload_reg[j] : payload_src[j]);
      base = (8 * i);
    end
    for (int j=base; j<(base+REM_SEL_LINE); j=j+1)
      payload_dst[j] = (buffer_full[NUM_SEL_LINES] ? payload_reg[j]
                         : payload_src[j]);
  end

  assign empty = ready_src;









endmodule



