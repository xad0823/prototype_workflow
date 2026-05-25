//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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


module css600_apbicdecoder_mux # (parameter
  APB_INTER_ADDR_WIDTH = 12,
`include "css600_apbic_params.v"
)
(
  input  wire                                               clk,
  input  wire                                               reset_n,
  input  wire [NUM_APB_SLAVES-1:0]                          slave_select,
  input  wire                                               cycle_start,
  input  wire                                               cycle_active,
  input  wire [NUM_EXPANDERS-1:0]                           psel_e,
  input  wire [NUM_EXPANDERS-1:0]                           psel_e_next,
  input  wire                                               psel_default,
  output reg                                                psel_default_q,
  input  wire [ NUM_APB_SLAVES-1:0]                         penable_s,
  input  wire [(NUM_APB_SLAVES * APB_SLAVE_ADDR_WIDTH)-1:0] paddr_s,
  input  wire [ NUM_APB_SLAVES-1:0]                         pwrite_s,
  input  wire [(NUM_APB_SLAVES * 3)-1:0]                    pprot_s,
  input  wire [(NUM_APB_SLAVES * 32)-1:0]                   pwdata_s,
  output wire [ NUM_APB_SLAVES-1:0]                         pready_s,
  output wire [ NUM_APB_SLAVES-1:0]                         pslverr_s,
  output wire [31:0]                                        prdata_s,
  output wire [APB_SLAVE_ADDR_WIDTH-1:0]                    paddr_s_arb,
  output reg  [APB_INTER_ADDR_WIDTH-1:0]                    paddr_e,
  input  wire [APB_INTER_ADDR_WIDTH*NUM_EXPANDERS-1:0]      paddr_e_int,
  output reg                                                pwrite_e,
  output reg  [ 2:0]                                        pprot_e,
  output reg  [ 31:0]                                       pwdata_e,
  input  wire [(NUM_EXPANDERS * 32)-1:0]                    prdata_e,
  input  wire [ NUM_EXPANDERS-1:0]                          pready_e,
  input  wire [ NUM_EXPANDERS-1:0]                          pslverr_e,
  input  wire [ NUM_EXPANDERS-1:0]                          penable_e,
  output reg                                                pready_int
);

  `include "css600_apbic_localparams.v"

  reg                             pslverr_int;
  reg  [NUM_APB_SLAVES-1:0]       slave_select_q;

  wire                            pwrite_e_next;
  wire [2:0]                      pprot_e_next;
  wire [31:0]                     pwdata_e_next;
  wire [APB_INTER_ADDR_WIDTH-1:0] paddr_e_next;

  integer                         expander;


  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      psel_default_q <= 1'b0;
    else if (cycle_start)
      psel_default_q <= psel_default;
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      slave_select_q <= {NUM_APB_SLAVES{1'b0}};
    else if (cycle_start)
      slave_select_q <= slave_select;
  end


  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_SLAVES),
  .DATA_WIDTH (APB_SLAVE_ADDR_WIDTH)
  ) u_paddr_s_mux (
    .inp_sel (slave_select),
    .inp_data (paddr_s),
    .out_data (paddr_s_arb)
  );

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_SLAVES),
  .DATA_WIDTH (1)
  ) u_pwite_mux (
    .inp_sel (slave_select),
    .inp_data (pwrite_s),
    .out_data (pwrite_e_next)
  );

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_SLAVES),
  .DATA_WIDTH (3)
  ) u_pprot_ux (
    .inp_sel (slave_select),
    .inp_data (pprot_s),
    .out_data (pprot_e_next)
  );

  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_APB_SLAVES),
  .DATA_WIDTH (32)
  ) u_pwdata_mux (
    .inp_sel (slave_select),
    .inp_data (pwdata_s),
    .out_data (pwdata_e_next)
  );


  css600_one_hot_mux #(
  .SEL_WIDTH  (NUM_EXPANDERS),
  .DATA_WIDTH (APB_INTER_ADDR_WIDTH)
  ) u_paddr_e_mux (
    .inp_sel (psel_e_next),
    .inp_data (paddr_e_int),
    .out_data (paddr_e_next)
  );

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      paddr_e <= {APB_INTER_ADDR_WIDTH{1'b0}};
    else if(cycle_start)
      paddr_e <= paddr_e_next;
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      pwrite_e  <= 1'b0;
      pwdata_e  <= 32'b0;
      pprot_e   <= 3'b0;
    end
    else if (cycle_start && !psel_default) begin
      pwrite_e  <= pwrite_e_next;
      pwdata_e  <= pwdata_e_next;
      pprot_e   <= pprot_e_next;
    end
  end


  css600_one_hot_mux #(
    .SEL_WIDTH  (NUM_EXPANDERS),
    .DATA_WIDTH (32)
  ) u_prdata_mux (
    .inp_sel (psel_e),
    .inp_data (psel_default_q ? {(NUM_EXPANDERS * 32){1'b0}} : prdata_e),
    .out_data (prdata_s)
  );


  always @(*) begin
    pready_int  = psel_default_q ? 1'b1 : |(pready_e & penable_e);
    pslverr_int = psel_default_q ? 1'b1 : |(pslverr_e & penable_e);
  end

  genvar slave;
  generate
    for (slave=0;slave<NUM_APB_SLAVES;slave=slave+1) begin: ready_slverr
      assign pslverr_s[slave] = cycle_active & penable_s[slave] & pslverr_int & slave_select_q[slave];
      assign pready_s[slave]  = cycle_active & penable_s[slave] & pready_int  & slave_select_q[slave];
    end
  endgenerate

endmodule
