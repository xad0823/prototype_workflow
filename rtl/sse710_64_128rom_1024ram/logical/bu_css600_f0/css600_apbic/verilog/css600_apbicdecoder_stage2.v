//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_apbic
//
//----------------------------------------------------------------------------


module css600_apbicdecoder_stage2 #(parameter
  EXPANDER_NUMBER       = 0,
  APB_INTER_ADDR_WIDTH  = 13,
  `include "css600_apbic_params.v"
)
(
  input  wire                            clk,
  input  wire                            reset_n,
  input  wire [NUM_APB_MASTERS-1:0]      psel_m,
  input  wire [APB_SLAVE_ADDR_WIDTH-1:0] paddr_s_arb,
  input  wire                            penable_int,
  output reg                             psel_e,
  output wire                            psel_e_next,
  output wire                            penable_e,
  output wire                            pwakeup_e,
  input  wire                            pready_e,
  output wire [APB_INTER_ADDR_WIDTH-1:0] paddr_e_int
);

`include "css600_apbic_localparams.v"
`include "css600_apbic_functions.v"

  localparam [63:0] PSEL_MASK      = PSEL_MASK_ALL[64*EXPANDER_NUMBER +: 64];
  localparam PSEL_COMPRESSED_WIDTH = count_bits(PSEL_MASK) > 0
                                     ? count_bits(PSEL_MASK)
                                     : 1;
  localparam EXP_SEL_WIDTH         = logb2(PSEL_COMPRESSED_WIDTH);
  localparam APB_MASTER_ADDR_WIDTH = max_addr_width(EXPANDER_NUMBER);

  wire                             psel_e_en;
  wire [PSEL_COMPRESSED_WIDTH-1:0] compressed_psel_m;
  wire [63:0]                      compressed_psel_m_full;
  integer                          i;

  function [63:0] compress_vector;
    input [NUM_APB_MASTERS-1:0] sparse_vector;
    integer i;
    begin
      compress_vector = 64'h0000000000000000;
      if (NUM_APB_MASTERS == 1)
        compress_vector[63] = sparse_vector[0];
      else if (PSEL_COMPRESSED_WIDTH == 1) begin
        for (i=0; i<NUM_APB_MASTERS; i=i+1)
          compress_vector[63] = PSEL_MASK[i]
                            ? sparse_vector[i]
                            : compress_vector[63];
      end
      else begin
        for (i=0; i<NUM_APB_MASTERS; i=i+1)
          compress_vector = PSEL_MASK[i]
                            ? {sparse_vector[i],
                               compress_vector[63:1]}
                            : compress_vector;
      end
    end
  endfunction

  assign compressed_psel_m_full = compress_vector(psel_m);
  assign compressed_psel_m = compressed_psel_m_full[63 -: PSEL_COMPRESSED_WIDTH];

  generate
    localparam PADDING = APB_INTER_ADDR_WIDTH
                       - APB_MASTER_ADDR_WIDTH
                       - EXP_SEL_WIDTH
                       ;
    if (EXP_SEL_WIDTH > 0) begin: gen_exp_sel
      reg [EXP_SEL_WIDTH-1:0] exp_sel;

      always @(compressed_psel_m) begin
        exp_sel = {EXP_SEL_WIDTH{1'b0}};
        for (i = 0; i < PSEL_COMPRESSED_WIDTH; i = i + 1) begin
          if (compressed_psel_m[i] == 1'b1) begin
            exp_sel = i[EXP_SEL_WIDTH-1:0];
          end
        end
      end

      if (PADDING > 0) begin: gen_pad
        assign paddr_e_int = {{PADDING{1'b0}},
                               exp_sel[EXP_SEL_WIDTH-1:0],
                               paddr_s_arb[APB_MASTER_ADDR_WIDTH-1:0]};
      end
      else begin: gen_exp_padddr
        assign paddr_e_int = {exp_sel[EXP_SEL_WIDTH-1:0],
                              paddr_s_arb[APB_MASTER_ADDR_WIDTH-1:0]};
      end
    end
    else begin: gen_pad_paddr
      if (PADDING > 0) begin: gen_pad
        assign paddr_e_int = {{PADDING{1'b0}},
                               paddr_s_arb[APB_MASTER_ADDR_WIDTH-1:0]};
      end
      else begin: gen_paddr
        assign paddr_e_int = paddr_s_arb[APB_MASTER_ADDR_WIDTH-1:0];
      end
    end
  endgenerate

  assign psel_e_next      = |(compressed_psel_m)
                          | psel_e & ~penable_e
                          | psel_e & ~pready_e;


  assign psel_e_en = psel_e_next ^ psel_e;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      psel_e <= 1'b0;
    end
    else if (psel_e_en) begin
      psel_e <= psel_e_next;
    end
  end

  assign pwakeup_e = psel_e;

  assign penable_e = penable_int & psel_e;

endmodule
