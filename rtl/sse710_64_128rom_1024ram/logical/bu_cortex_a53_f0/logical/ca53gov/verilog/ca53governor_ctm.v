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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Description: Cross Trigger Matrix
//------------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_ctm `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                  CLKIN,
  input  wire                                  DFTSE,
  input  wire                                  npresetdbg_gov,
  input  wire [NUM_CPUS-1:0]                   apb_dec_pseldbg_cti_i,
  input  wire [NUM_CPUS-1:0]                   cti_active_i,
  input  wire                                  cisbypass_i,
  input  wire [3:0]                            cihsbypass_i,
  input  wire [`CA53_CTICH_PKDED_W-1:0]        cti_ctichout_i,
  input  wire [3:0]                            ctmchin_i,
  input  wire [3:0]                            ctmchoutack_i,
  // Outputs
  output wire [`CA53_CTICH_PKDED_W-1:0]        ctm_ctichin_o,
  output wire [3:0]                            ctm_ctichinack_o,
  output wire [3:0]                            ctm_ctichout_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [3:0]                            ctmchin_rs;
  reg                                  cisbypass_rs;
  reg [3:0]                            ctm_ctichinack;
  reg [3:0]                            ctm_ctichout;
  reg [3:0]                            ctm_choutack_rs;
  reg [3:0]                            ch_out_holder_4;
  reg [3:0]                            cihsbypass_rs;
  reg                                  ctm_clk_en;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [3:0]                           ctm_or_4;
  wire [3:0]                           ctm_ch_in_4_synced;
  wire [3:0]                           ctmchin_sync;
  wire [3:0]                           ctmchoutack_sync;
  wire [3:0]                           ctm_ch_out_ack_4_synced;
  wire [3:0]                           nxt_ch_out_holder_4;
  wire [3:0]                           ctm_ch_out_or_4;
  wire                                 nxt_ctm_clk_en;
  wire                                 clk_cisbypass;
  wire                                 clk_ctm;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  assign nxt_ctm_clk_en = ((|apb_dec_pseldbg_cti_i)                  | // Debug channel selecting the CTI
                           (|cti_active_i)                           | // CTI Active
                           (|ctm_ctichout)                           | // Output channel to the system is active
                           (|ctm_ctichinack) | (|ctm_ch_in_4_synced)); // ACKing an input from the system

  always @(posedge CLKIN or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ctm_clk_en <= 1'b1;
    else
      ctm_clk_en <= nxt_ctm_clk_en;

  ca53_cell_inter_clkgate u_inter_clkgate_ctm (
    .clk_i         (CLKIN),
    .clk_enable_i  (ctm_clk_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ctm)
  );

  // ------------------------------------------------------
  // Synchroniser bypass control
  // ------------------------------------------------------

  // Register cisbypass
  always @(posedge clk_ctm or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      cisbypass_rs <= 1'b0;
    else
      cisbypass_rs <= cisbypass_i;

  // Instantiate a clock gate based on CISBYPASS
  ca53_cell_clkgate u_clkgate_cisbypass_cdc (
    .clk_i         (clk_ctm),
    .clk_enable_i  (cisbypass_rs),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_cisbypass)
  );

  // ------------------------------------------------------
  // Channel in
  // ------------------------------------------------------

  // Register ctmchin directly, but place behind the CISBYPASS instantiated clock gate
  // to ensure the path from these registers to the mux is CDC-safe when CISBYPASS is
  // low and the synchronised ctmchin versions are being used.
  always @(posedge clk_cisbypass or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ctmchin_rs <= {4{1'b0}};
    else
      ctmchin_rs <= ctmchin_i;

  // Synchronise ctmchin
  ca53_cell_sync u_ctm_ch_in_0 (.out_o    (ctmchin_sync[0]),
                                .clk_i    (clk_ctm),
                                .inp_i    (ctmchin_i[0]),
                                .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_in_1 (.out_o    (ctmchin_sync[1]),
                                .clk_i    (clk_ctm),
                                .inp_i    (ctmchin_i[1]),
                                .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_in_2 (.out_o    (ctmchin_sync[2]),
                                .clk_i    (clk_ctm),
                                .inp_i    (ctmchin_i[2]),
                                .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_in_3 (.out_o    (ctmchin_sync[3]),
                                .clk_i    (clk_ctm),
                                .inp_i    (ctmchin_i[3]),
                                .resetn_i (npresetdbg_gov));

  // Channel input sync bypass mux
  assign ctm_ch_in_4_synced = cisbypass_rs ? ctmchin_rs : ctmchin_sync;

  // ------------------------------------------------------
  // Channel in ack
  // ------------------------------------------------------

  // Generate input acknowledge
  always @(posedge clk_ctm or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ctm_ctichinack <= {4{1'b1}};
    else
      ctm_ctichinack <= ctm_ch_in_4_synced;

  assign ctm_ctichinack_o = ctm_ctichinack;

  // ------------------------------------------------------
  // Combine channel events
  // ------------------------------------------------------

  // OR stage to combine channel events
  generate if (NUM_CPUS >= 4) begin : ctmchin_4_cpus
    assign ctm_ctichin_o[ 3: 0] = ctm_ch_in_4_synced |                       cti_ctichout_i[7:4] | cti_ctichout_i[11:8] | cti_ctichout_i[15:12];
    assign ctm_ctichin_o[ 7: 4] = ctm_ch_in_4_synced | cti_ctichout_i[3:0]                       | cti_ctichout_i[11:8] | cti_ctichout_i[15:12];
    assign ctm_ctichin_o[11: 8] = ctm_ch_in_4_synced | cti_ctichout_i[3:0] | cti_ctichout_i[7:4]                        | cti_ctichout_i[15:12];
    assign ctm_ctichin_o[15:12] = ctm_ch_in_4_synced | cti_ctichout_i[3:0] | cti_ctichout_i[7:4] | cti_ctichout_i[11:8];
    assign ctm_or_4             =                      cti_ctichout_i[3:0] | cti_ctichout_i[7:4] | cti_ctichout_i[11:8] | cti_ctichout_i[15:12];
  end else if (NUM_CPUS >= 3) begin : ctmchin_3_cpus
    assign ctm_ctichin_o[ 3: 0] = ctm_ch_in_4_synced |                       cti_ctichout_i[7:4] | cti_ctichout_i[11:8];
    assign ctm_ctichin_o[ 7: 4] = ctm_ch_in_4_synced | cti_ctichout_i[3:0]                       | cti_ctichout_i[11:8];
    assign ctm_ctichin_o[11: 8] = ctm_ch_in_4_synced | cti_ctichout_i[3:0] | cti_ctichout_i[7:4];
    assign ctm_or_4             =                      cti_ctichout_i[3:0] | cti_ctichout_i[7:4] | cti_ctichout_i[11:8];
  end else if (NUM_CPUS >= 2) begin : ctmchin_2_cpus
    assign ctm_ctichin_o[ 3: 0] = ctm_ch_in_4_synced |                       cti_ctichout_i[7:4];
    assign ctm_ctichin_o[ 7: 4] = ctm_ch_in_4_synced | cti_ctichout_i[3:0];
    assign ctm_or_4             =                      cti_ctichout_i[3:0] | cti_ctichout_i[7:4];
  end else begin : ctmchin_1_cpus
    assign ctm_ctichin_o[ 3: 0] = ctm_ch_in_4_synced;
    assign ctm_or_4             =                      cti_ctichout_i[3:0];
  end
  endgenerate

  // ------------------------------------------------------
  // Channel out ack
  // ------------------------------------------------------

  // Register ctmchoutack directly, but place behind the CISBYPASS instantiated clock gate
  // to ensure the path from these registers to the mux is CDC-safe when CISBYPASS is low
  // and the synchronised ctmchoutack versions are being used.
  always @(posedge clk_cisbypass or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ctm_choutack_rs <= {4{1'b0}};
    else
      ctm_choutack_rs <= ctmchoutack_i;

  // Synchronise ctmchoutack
  ca53_cell_sync u_ctm_ch_out_0 (.out_o    (ctmchoutack_sync[0]),
                                 .clk_i    (clk_ctm),
                                 .inp_i    (ctmchoutack_i[0]),
                                 .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_out_1 (.out_o    (ctmchoutack_sync[1]),
                                 .clk_i    (clk_ctm),
                                 .inp_i    (ctmchoutack_i[1]),
                                 .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_out_2 (.out_o    (ctmchoutack_sync[2]),
                                 .clk_i    (clk_ctm),
                                 .inp_i    (ctmchoutack_i[2]),
                                 .resetn_i (npresetdbg_gov));

  ca53_cell_sync u_ctm_ch_out_3 (.out_o    (ctmchoutack_sync[3]),
                                 .clk_i    (clk_ctm),
                                 .inp_i    (ctmchoutack_i[3]),
                                 .resetn_i (npresetdbg_gov));

  // Channel output ack sync bypass mux
  assign ctm_ch_out_ack_4_synced = cisbypass_rs ? ctm_choutack_rs : ctmchoutack_sync;

  // ------------------------------------------------------
  // Channel out
  // ------------------------------------------------------

  // Channel output OR gate
  // Combine new events and event that is stored in the event output holder.
  assign ctm_ch_out_or_4 = (ctm_or_4 | ch_out_holder_4);

  // Register cihsbypass for timing reasons.
  always @(posedge clk_ctm or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      cihsbypass_rs <= {4{1'b0}};
    else
      cihsbypass_rs <= cihsbypass_i;

  // Next value for Output Holder
  //   Can be disabled by Handshaking bypass control
  //   Set when a channel event occurs. Clear if there is an ack received.
  assign nxt_ch_out_holder_4 = ctm_ch_out_or_4 & ~ctm_ch_out_ack_4_synced & ~cihsbypass_rs;

  // Output holder registers
  always @(posedge clk_ctm or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ch_out_holder_4 <= {4{1'b0}};
    else
      ch_out_holder_4 <= nxt_ch_out_holder_4;

  // Channel Out to the system
  always @(posedge clk_ctm or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      ctm_ctichout <= {4{1'b0}};
    else
      ctm_ctichout <= ctm_ch_out_or_4;

  assign ctm_ctichout_o = ctm_ctichout;

endmodule // ca53governor_ctm

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
