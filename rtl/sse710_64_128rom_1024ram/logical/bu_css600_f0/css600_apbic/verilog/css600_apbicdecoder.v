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


module css600_apbicdecoder #(parameter
  `include "css600_apbic_params.v"
)
(
  clk,
  reset_n,
  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  pprot_s,
  paddr_s,
  pwdata_s,
  pready_s,
  pslverr_s,
  prdata_s,
  pwakeup_e,
  psel_e,
  penable_e,
  pwrite_e,
  pprot_e,
  paddr_e,
  pwdata_e,
  pready_e,
  pslverr_e,
  prdata_e,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,
  clk_qactive
);

`include "css600_apbic_localparams.v"
`include "css600_apbic_functions.v"

  localparam APB_INTER_ADDR_WIDTH   = max_inter_addr_width(PSEL_MASK_ALL);


  input  wire                                                   clk;
  input  wire                                                   reset_n;
  input  wire [ L_NUM_APB_SLAVES-1:0]                           pwakeup_s;
  input  wire [ L_NUM_APB_SLAVES-1:0]                           psel_s;
  input  wire [ L_NUM_APB_SLAVES-1:0]                           penable_s;
  input  wire [ L_NUM_APB_SLAVES-1:0]                           pwrite_s;
  input  wire [(L_NUM_APB_SLAVES * 3)-1:0]                      pprot_s;
  input  wire [(L_NUM_APB_SLAVES * L_APB_SLAVE_ADDR_WIDTH)-1:0] paddr_s;
  input  wire [(L_NUM_APB_SLAVES * 32)-1:0]                     pwdata_s;
  output wire [ L_NUM_APB_SLAVES-1:0]                           pready_s;
  output wire [ L_NUM_APB_SLAVES-1:0]                           pslverr_s;
  output wire [31:0]                                            prdata_s;
  output wire [ L_NUM_EXPANDERS-1:0]                            pwakeup_e;
  output wire [ L_NUM_EXPANDERS-1:0]                            psel_e;
  output wire [ L_NUM_EXPANDERS-1:0]                            penable_e;
  output wire                                                   pwrite_e;
  output wire [ 2:0]                                            pprot_e;
  output wire [APB_INTER_ADDR_WIDTH-1:0]                        paddr_e;
  output wire [ 31:0]                                           pwdata_e;
  input  wire [ L_NUM_EXPANDERS-1:0]                            pready_e;
  input  wire [ L_NUM_EXPANDERS-1:0]                            pslverr_e;
  input  wire [(L_NUM_EXPANDERS * 32)-1:0]                      prdata_e;
  input  wire                                                   clk_qreq_n;
  output wire                                                   clk_qaccept_n;
  output wire                                                   clk_qdeny;
  output wire                                                   clk_qactive;


  wire                                          dev_active;
  wire                                          cycle_start;
  wire                                          apb_active /* verilator clock_enable */;
  wire                                          dev_run;
  wire                                          qreq_sync_n;
  wire                                          lp_request;
  wire                                          penable_int;
  wire                                          pready_int;
  wire                                          cycle_active;
  wire                                          psel_default;
  wire                                          psel_default_q;
  wire [L_NUM_EXPANDERS-1:0]                    psel_e_next;
  wire [L_NUM_APB_MASTERS-1:0]                  psel_m;
  wire [L_APB_SLAVE_ADDR_WIDTH-1:0]             paddr_s_arb;
  wire [L_NUM_APB_SLAVES-1:0]                   slave_select;
  wire [APB_INTER_ADDR_WIDTH*L_NUM_EXPANDERS-1:0] paddr_e_int;


  css600_apbicdecoder_arb #(
    .NUM_APB_SLAVES  (L_NUM_APB_SLAVES)
  ) u_arb (
    .clk             (clk),
    .reset_n         (reset_n),
    .psel_s          (psel_s),
    .psel_default_q  (psel_default_q),
    .penable_int     (penable_int),
    .pready_int      (pready_int),
    .slave_select    (slave_select),
    .cycle_start     (cycle_start),
    .cycle_active    (cycle_active),
    .dev_run         (dev_run),
    .dev_active      (dev_active)
  );


  css600_apbicdecoder_mux #(
    .APB_INTER_ADDR_WIDTH (APB_INTER_ADDR_WIDTH),
  `include "css600_apbic_param_connections.v"
  ) u_mux (
    .clk            (clk),
    .reset_n        (reset_n),
    .slave_select   (slave_select),
    .cycle_start    (cycle_start),
    .cycle_active   (cycle_active),
    .psel_e         (psel_e),
    .psel_e_next    (psel_e_next),
    .psel_default   (psel_default),
    .psel_default_q (psel_default_q),
    .penable_s      (penable_s),
    .paddr_s        (paddr_s),
    .pwrite_s       (pwrite_s),
    .pprot_s        (pprot_s),
    .pwdata_s       (pwdata_s),
    .pready_s       (pready_s),
    .pslverr_s      (pslverr_s),
    .prdata_s       (prdata_s),
    .paddr_s_arb    (paddr_s_arb),
    .paddr_e        (paddr_e),
    .paddr_e_int    (paddr_e_int),
    .pwrite_e       (pwrite_e),
    .pprot_e        (pprot_e),
    .pwdata_e       (pwdata_e),
    .prdata_e       (prdata_e),
    .pready_e       (pready_e),
    .pslverr_e      (pslverr_e),
    .penable_e      (penable_e),
    .pready_int     (pready_int)
  );


  css600_apbicdecoder_stage1 #(
  `include "css600_apbic_param_connections.v"
  ) u_decoder_stage1 (
    .cycle_start  (cycle_start),
    .paddr_s_arb  (paddr_s_arb),
    .psel_m       (psel_m),
    .psel_default (psel_default)
  );


  genvar expander;
  generate
    for (expander = 0; expander < L_NUM_EXPANDERS; expander = expander + 1)
    begin: stage2_decoder

      css600_apbicdecoder_stage2 #(
        .EXPANDER_NUMBER       (expander),
        .APB_INTER_ADDR_WIDTH  (APB_INTER_ADDR_WIDTH),
        `include "css600_apbic_param_connections.v"
      ) u_decoder_stage2 (
         .clk         (clk),
         .reset_n     (reset_n),
         .psel_m      (psel_m),
         .paddr_s_arb (paddr_s_arb),
         .penable_int (penable_int),
         .psel_e      (psel_e[expander]),
         .psel_e_next (psel_e_next[expander]),
         .penable_e   (penable_e[expander]),
         .pwakeup_e   (pwakeup_e[expander]),
         .pready_e    (pready_e[expander]),
         .paddr_e_int (paddr_e_int
                        [APB_INTER_ADDR_WIDTH*expander
                        +: APB_INTER_ADDR_WIDTH])
      );
    end
  endgenerate


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
  ) u_qreq_sync (
    .clk       (clk),
    .reset_n   (reset_n),
    .d_async_i (clk_qreq_n),
    .q_sync_o  (qreq_sync_n)
  );

  assign apb_active = dev_active | cycle_start;

  css600_lpislave u_lpislave
  (
    .clk         (clk),
    .reset_n     (reset_n),
    .qreq_sync_n (qreq_sync_n),
    .qaccept_n   (clk_qaccept_n),
    .qdeny       (clk_qdeny),
    .lp_request  (lp_request),
    .dev_active  (apb_active),
    .lp_done     (lp_request),
    .dev_run     (dev_run),
    .cg_en       ()
  );

  css600_or_tree #(
    .NUM_OR_INPUTS(L_NUM_APB_SLAVES + 1))
  u_qactive_async (
    .or_inputs ({dev_active, pwakeup_s}),
    .or_output (clk_qactive)
  );


endmodule
