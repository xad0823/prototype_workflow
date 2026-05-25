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


module css600_apbicexpander # (parameter
  EXPANDER_NUMBER = 0,
  `include "css600_apbic_params.v"
)
(
  clk,
  reset_n,
  pwakeup_e,
  psel_e,
  penable_e,
  pwrite_e,
  pprot_e,
  paddr_e,
  pwdata_e,
  prdata_e,
  pready_e,
  pslverr_e,
  pwakeup_m,
  psel_m,
  penable_m,
  pwrite_m,
  pprot_m,
  paddr_m,
  pwdata_m,
  prdata_m,
  pready_m,
  pslverr_m
);

`include "css600_apbic_localparams.v"
`include "css600_apbic_functions.v"


  localparam [63:0] PSEL_MASK      = PSEL_MASK_ALL[64*EXPANDER_NUMBER +: 64];
  localparam NUM_APB_MASTERS_THIS  = count_bits(PSEL_MASK) > 0
                                     ? count_bits(PSEL_MASK)
                                     : 1;
  localparam EXP_SEL_WIDTH         = logb2(NUM_APB_MASTERS_THIS);
  localparam APB_MASTER_ADDR_WIDTH = max_addr_width(EXPANDER_NUMBER);
  localparam CHECK_ADDR_WIDTH      = APB_MASTER_ADDR_WIDTH + EXP_SEL_WIDTH;
  localparam EXPECTED_ADDR_WIDTH   = max_inter_addr_width(PSEL_MASK_ALL);
  localparam APB_INTER_ADDR_WIDTH  = EXPECTED_ADDR_WIDTH <= CHECK_ADDR_WIDTH
                                     ? EXPECTED_ADDR_WIDTH
                                     : CHECK_ADDR_WIDTH;

  input  wire                                   clk;
  input  wire                                   reset_n;
  input  wire                                   pwakeup_e;
  input  wire                                   psel_e;
  input  wire                                   penable_e;
  input  wire                                   pwrite_e;
  input  wire [2:0]                             pprot_e;
  input  wire [APB_INTER_ADDR_WIDTH-1:0]        paddr_e;
  input  wire [31:0]                            pwdata_e;
  output wire [31:0]                            prdata_e;
  output wire                                   pready_e;
  output wire                                   pslverr_e;
  output reg  [NUM_APB_MASTERS_THIS-1:0]        pwakeup_m;
  output wire [NUM_APB_MASTERS_THIS-1:0]        psel_m;
  output wire [NUM_APB_MASTERS_THIS-1:0]        penable_m;
  output wire                                   pwrite_m;
  output wire [2:0]                             pprot_m;
  output wire [APB_MASTER_ADDR_WIDTH-1:0]       paddr_m;
  output wire [31:0]                            pwdata_m;
  input  wire [(NUM_APB_MASTERS_THIS * 32)-1:0] prdata_m;
  input  wire [NUM_APB_MASTERS_THIS-1:0]        pready_m;
  input  wire [NUM_APB_MASTERS_THIS-1:0]        pslverr_m;

  wire                               pready_int;
  wire                               pslverr_int;
  wire                               pwakeup_m_en;
  wire [31:0]                        prdata_int;
  wire [NUM_APB_MASTERS_THIS-1:0]    pwakeup_m_next;
  wire [NUM_APB_MASTERS_THIS-1:0]    exp_sel_one_hot;

  genvar master;


  assign paddr_m = paddr_e[APB_MASTER_ADDR_WIDTH-1:0];

  assign pwrite_m = pwrite_e;
  assign pprot_m  = pprot_e;
  assign pwdata_m = pwdata_e;


  generate
    for (master=0;master<NUM_APB_MASTERS_THIS;master=master+1) begin: psel_gen
      if (EXP_SEL_WIDTH > 0) begin: gen_exp_enables
        wire [EXP_SEL_WIDTH-1:0]           exp_sel;
        assign exp_sel = paddr_e[APB_MASTER_ADDR_WIDTH +: EXP_SEL_WIDTH];
        assign psel_m[master]    = psel_e    & (master[EXP_SEL_WIDTH-1:0] == exp_sel);
        assign penable_m[master] = penable_e & (master[EXP_SEL_WIDTH-1:0] == exp_sel);
      end
      else begin: gen_enables
        assign psel_m[master]    = psel_e;
        assign penable_m[master] = penable_e;
      end
    end
  endgenerate

  assign pwakeup_m_next = psel_m;
  assign pwakeup_m_en   = (pwakeup_m != pwakeup_m_next);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      pwakeup_m <= {NUM_APB_MASTERS_THIS{1'b0}};
    else if (pwakeup_m_en)
      pwakeup_m <= pwakeup_m_next;
  end


  generate
    for (master=0;master<NUM_APB_MASTERS_THIS;master=master+1) begin: exp_sel_gen
      if (EXP_SEL_WIDTH > 0) begin: gen_exp_oh
        wire [EXP_SEL_WIDTH-1:0]           exp_sel;
        assign exp_sel = paddr_e[APB_MASTER_ADDR_WIDTH +: EXP_SEL_WIDTH];
        assign exp_sel_one_hot[master] = (exp_sel == master[EXP_SEL_WIDTH-1:0]);
      end
      else begin: gen_no_oh
        assign exp_sel_one_hot[master] = 1'b1;
      end
    end
  endgenerate

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_MASTERS_THIS),
  .DATA_WIDTH (32)
  ) u_prdata_mux (
    .inp_sel (exp_sel_one_hot),
    .inp_data (prdata_m),
    .out_data (prdata_int)
  );

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_MASTERS_THIS),
  .DATA_WIDTH (1)
  ) u_pready_mux (
    .inp_sel (exp_sel_one_hot),
    .inp_data (pready_m),
    .out_data (pready_int)
  );

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_MASTERS_THIS),
  .DATA_WIDTH (1)
  ) u_pslverr_mux (
    .inp_sel (exp_sel_one_hot),
    .inp_data (pslverr_m),
    .out_data (pslverr_int)
  );

  assign prdata_e  = prdata_int  & {32{penable_e}};
  assign pready_e  = pready_int  & penable_e;
  assign pslverr_e = pslverr_int & pready_int;


endmodule

