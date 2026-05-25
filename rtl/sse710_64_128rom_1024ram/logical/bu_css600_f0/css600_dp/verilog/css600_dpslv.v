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
//   Sub-module of css600_dp
//
//----------------------------------------------------------------------------


module css600_dpslv #(parameter
  SWDP_PRESENT     = 1,
  JTAGDP_PRESENT   = 1,
  APB_ADDR_WIDTH   = 32,
  JTAG_IR_LENGTH   = 4,
  FF_SYNC_DEPTH    = 2
)
(
  swclktck,
  porst_n,

  ntrst,
  swditms,
  tdi,
  swdo,
  swdo_en,
  tdo,
  tdo_en_n,

  swactive,
  jtagactive,
  jtagir,
  jtagstate,
  dormantstate,

  dp_eventstatus,

  cdbgpwrupreq,
  cdbgpwrupack,
  csyspwrupreq,
  csyspwrupack,
  cdbgrstreq,
  cdbgrstack,

  targetid,
  instanceid,
  baseaddr,
  baseaddr_valid,

  bus_req,
  bus_req_payload,
  bus_ack,
  bus_ack_payload,
  dp_abort_req,
  dp_abort_ack
);


  localparam JTAGDP_IRLEN = (JTAG_IR_LENGTH != 8) ? 4 : 8;

  localparam ADDR_SIZE    = (APB_ADDR_WIDTH == 12) ? 12 :
                            (APB_ADDR_WIDTH == 20) ? 20 :
                             32;
  localparam SW_DP = (SWDP_PRESENT == 1) ? 1 : 0;

  localparam JTAG_DP = (JTAGDP_PRESENT == 1) ? 1 :
                       SW_DP ? 0 : 1;

  localparam SYNC_DEPTH = (FF_SYNC_DEPTH == 3) ? 3 : 2;


  localparam SWDP_WRITEBUFFER = 1;


  input  wire        swclktck;
  input  wire        porst_n;

  input  wire        ntrst;
  input  wire        swditms;
  input  wire        tdi;
  output wire        swdo;
  output wire        swdo_en;
  output wire        tdo;
  output wire        tdo_en_n;

  output wire                    swactive;
  output wire                    jtagactive;
  output wire [JTAGDP_IRLEN-1:0] jtagir;
  output wire              [3:0] jtagstate;
  output wire                    dormantstate;

  input wire         dp_eventstatus;

  output wire        cdbgpwrupreq;
  input  wire        cdbgpwrupack;
  output wire        csyspwrupreq;
  input  wire        csyspwrupack;
  output wire        cdbgrstreq;
  input  wire        cdbgrstack;

  input wire          [31:0] targetid;
  input wire           [3:0] instanceid;
  input wire [ADDR_SIZE-1:0] baseaddr;
  input wire                 baseaddr_valid;

  output wire                    bus_req;
  output wire [ADDR_SIZE+31-1:0] bus_req_payload;
  input  wire                    bus_ack;
  input  wire             [33:0] bus_ack_payload;
  output wire                    dp_abort_req;
  input  wire                    dp_abort_ack;


  wire [31:0] bus_wdata;
  wire  [1:0] bus_addr;
  wire        bus_write;
  wire        bus_load_int;
  wire        bus_req_int;
  wire        bus_req_int_reject;

  wire [31:0] bus_rdata;
  wire        bus_err_set;
  wire        bus_ack_int;
  wire        bus_pwr_int;

  wire          [31:0] reg_wdata;
  wire           [1:0] reg_addr;
  wire                 reg_write;
  wire                 reg_orun;
  wire                 reg_sel;

  wire [ADDR_SIZE-1:0] reg_paddr;

  wire        stickyerr_clr;

  wire  [31:0] reg_rdata;
  wire         reg_stky_err;
  wire   [3:0] reg_select_dpbanksel;
  wire [31:28] reg_dlpidr;
  wire  [27:0] reg_targetid;
  wire         reg_orundetect;
  wire         reg_wdataerr;
  wire  [1:0]  reg_sw_trn;


  wire        reg_wdata_err;
  wire        reg_readok;


  wire        dp_eventstatus_sync;
  wire        cdbgpwrupack_sync;
  wire        csyspwrupack_sync;
  wire        cdbgrstack_sync;

  wire        dp_abort_int;

  wire        tlr_reset_req;
  wire        protocol_err_req;


  wire        swactive_rise;

  wire        linereset;

  wire        safetms_q;


  wire  [31:0] jt_bus_wdata;
  wire   [1:0] jt_bus_addr;
  wire         jt_bus_write;
  wire         jt_bus_load_int;
  wire         jt_bus_req_int;
  wire         jt_bus_req_int_reject;
  wire  [31:0] jt_reg_wdata;
  wire   [1:0] jt_reg_addr;
  wire         jt_reg_write;
  wire         jt_reg_orun;
  wire         jt_reg_sel;
  wire         jt_stickyerr_clr;

  wire  [31:0] sw_bus_wdata;
  wire   [1:0] sw_bus_addr;
  wire         sw_bus_write;
  wire         sw_bus_load_int;
  wire         sw_bus_req_int;
  wire         sw_bus_req_int_reject;
  wire  [31:0] sw_reg_wdata;
  wire   [1:0] sw_reg_addr;
  wire         sw_reg_write;
  wire         sw_reg_orun;
  wire         sw_reg_sel;
  wire         sw_reg_wdata_err;
  wire         sw_reg_readok;
  wire         sw_stickyerr_clr;


  css600_dpslv_watcher
    #(.JTAG_DP       (JTAG_DP),
      .SW_DP         (SW_DP),
      .SYNC_DEPTH    (SYNC_DEPTH),
      .JTAGDP_IRLEN  (JTAGDP_IRLEN))
    u_css600_dpslv_watcher
      (
       .swclktck           (swclktck),
       .porst_n            (porst_n),
       .ntrst              (ntrst),
       .swditms_i          (swditms),
       .jtagstate_i        (jtagstate),
       .linereset_i        (linereset),
       .jtagactive_o       (jtagactive),
       .swactive_o         (swactive),
       .swactive_rise_o    (swactive_rise),
       .dormantstate_o     (dormantstate),
       .safetms_q_o        (safetms_q),
       .tlr_reset_req_o    (tlr_reset_req),
       .protocol_err_req_o (protocol_err_req)
       );


generate
  if (JTAG_DP == 1) begin : JTAG_PROTOCOL_ENGINE

    wire              [68:0] cdc_demux_input_jtag;
    wire              [68:0] cdc_demux_output_jtag;

    wire                     jt_tdi;
    wire                     jt_swditms;
    wire              [31:0] jt_bus_rdata;
    wire                     jt_bus_ack_int;
    wire                     jt_bus_pwr_int;
    wire              [31:0] jt_reg_rdata;
    wire                     jt_reg_stky_err;

    wire                     jt_tdo;
    wire                     jt_tdo_en_n;
    wire               [3:0] jt_jtagstate;
    wire  [JTAGDP_IRLEN-1:0] jt_jtagir;


    assign      cdc_demux_input_jtag = { tdi,
                                         swditms,
                                         bus_rdata,
                                         bus_ack_int,
                                         bus_pwr_int,
                                         reg_rdata,
                                         reg_stky_err };

    css600_and #( .OP_W(69) ) u_jtag_demux (
        .datain  (cdc_demux_input_jtag),
        .maskn   (jtagactive),
        .dataout (cdc_demux_output_jtag)
      );


    assign { jt_tdi,
             jt_swditms,
             jt_bus_rdata,
             jt_bus_ack_int,
             jt_bus_pwr_int,
             jt_reg_rdata,
             jt_reg_stky_err } = cdc_demux_output_jtag;


    css600_dpslv_jtag_protocol
      #(.JTAGDP_IRLEN (JTAGDP_IRLEN))
      u_css600_dpslv_jtag_protocol
       (
        .tck                    (swclktck),
        .porst_n                (porst_n),
        .jtagactive_i           (jtagactive),
        .ntrst                  (ntrst),
        .tdi_i                  (jt_tdi),
        .tms_i                  (jt_swditms),
        .bus_rdata_i            (jt_bus_rdata),
        .bus_ack_int_i          (jt_bus_ack_int),
        .bus_pwr_int_i          (jt_bus_pwr_int),
        .reg_rdata_i            (jt_reg_rdata),
        .reg_stky_err_i         (jt_reg_stky_err),
        .tlr_reset_req_i        (tlr_reset_req),

        .tdo_o                  (jt_tdo),
        .tdo_en_n_o             (jt_tdo_en_n),
        .bus_wdata_o            (jt_bus_wdata),
        .bus_addr_o             (jt_bus_addr),
        .bus_write_o            (jt_bus_write),
        .bus_load_int_o         (jt_bus_load_int),
        .bus_req_int_o          (jt_bus_req_int),
        .bus_req_int_reject_o   (jt_bus_req_int_reject),
        .reg_wdata_o            (jt_reg_wdata),
        .reg_addr_o             (jt_reg_addr),
        .reg_write_o            (jt_reg_write),
        .reg_orun_o             (jt_reg_orun),
        .reg_sel_o              (jt_reg_sel),
        .stickyerr_clr_o        (jt_stickyerr_clr),
        .jtagstate_o            (jt_jtagstate),
        .jtagir_o               (jt_jtagir)
       );

    assign tdo       = jt_tdo;
    assign tdo_en_n  = jt_tdo_en_n;
    assign jtagstate = jt_jtagstate;
    assign jtagir    = jt_jtagir;

  end
  else begin : NO_JTAG_PROTOCOL_ENGINE
    assign tdo = 0;
    assign tdo_en_n = 1;
    assign jtagstate = 4'b1111;
    assign jtagir = {JTAGDP_IRLEN{1'b1}};

    assign jt_bus_wdata             = 0;
    assign jt_bus_addr              = 0;
    assign jt_bus_write             = 0;
    assign jt_bus_load_int          = 0;
    assign jt_bus_req_int           = 0;
    assign jt_bus_req_int_reject    = 0;
    assign jt_reg_wdata             = 0;
    assign jt_reg_addr              = 0;
    assign jt_reg_write             = 0;
    assign jt_reg_orun              = 0;
    assign jt_reg_sel               = 0;
    assign jt_stickyerr_clr         = 0;
  end
endgenerate


generate
  if (SW_DP == 1) begin : SW_PROTOCOL_ENGINE

    wire [108:0] cdc_demux_input_sw;
    wire [108:0] cdc_demux_output_sw;

    wire         sw_swdi_q;
    wire  [31:0] sw_bus_rdata;
    wire         sw_bus_ack_int;
    wire         sw_bus_pwr_int;
    wire  [31:0] sw_reg_rdata;
    wire         sw_reg_stky_err;
    wire   [3:0] sw_reg_select_dpbanksel;
    wire [31:28] sw_reg_dlpidr;
    wire  [27:0] sw_reg_targetid;
    wire         sw_protocol_err_req;
    wire         sw_reg_orundetect;
    wire         sw_reg_wdataerr;
    wire   [1:0] sw_trn;

    wire         sw_swdo;
    wire         sw_swdoen;

    wire         sw_linereset;


    assign      cdc_demux_input_sw   = { safetms_q,
                                         bus_rdata,
                                         bus_ack_int,
                                         bus_pwr_int,
                                         reg_rdata,
                                         reg_stky_err,
                                         reg_select_dpbanksel,
                                         reg_dlpidr,
                                         reg_targetid,
                                         protocol_err_req,
                                         reg_orundetect,
                                         reg_wdataerr,
                                         reg_sw_trn };

    css600_and #( .OP_W(109) ) u_sw_demux (
        .datain  (cdc_demux_input_sw),
        .maskn   (swactive),
        .dataout (cdc_demux_output_sw)
      );


    assign { sw_swdi_q,
             sw_bus_rdata,
             sw_bus_ack_int,
             sw_bus_pwr_int,
             sw_reg_rdata,
             sw_reg_stky_err,
             sw_reg_select_dpbanksel,
             sw_reg_dlpidr,
             sw_reg_targetid,
             sw_protocol_err_req,
             sw_reg_orundetect,
             sw_reg_wdataerr,
             sw_trn }               = cdc_demux_output_sw;


    css600_dpslv_sw_protocol
      #(.SWDP_WRITEBUFFER (SWDP_WRITEBUFFER))
      u_css600_dpslv_sw_protocol
      (
       .swclk                   (swclktck),
       .porst_n                 (porst_n),
       .swdi_q_i                (sw_swdi_q),
       .bus_rdata_i             (sw_bus_rdata),
       .bus_ack_int_i           (sw_bus_ack_int),
       .bus_pwr_int_i           (sw_bus_pwr_int),
       .reg_rdata_i             (sw_reg_rdata),
       .reg_stky_err_i          (sw_reg_stky_err),
       .reg_select_dpbanksel_i  (sw_reg_select_dpbanksel),
       .reg_dlpidr_i            (sw_reg_dlpidr),
       .reg_targetid_i          (sw_reg_targetid),
       .protocol_err_req_i      (sw_protocol_err_req),
       .reg_orundetect_i        (sw_reg_orundetect),
       .reg_wdataerr_i          (sw_reg_wdataerr),
       .sw_trn_i                (sw_trn),
       .swactive_i              (swactive),

       .swdo_o                  (sw_swdo),
       .swdoen_o                (sw_swdoen),
       .bus_wdata_o             (sw_bus_wdata),
       .bus_addr_o              (sw_bus_addr),
       .bus_write_o             (sw_bus_write),
       .bus_req_int_o           (sw_bus_req_int),
       .bus_req_int_reject_o    (sw_bus_req_int_reject),
       .reg_wdata_o             (sw_reg_wdata),
       .reg_addr_o              (sw_reg_addr),
       .reg_write_o             (sw_reg_write),
       .reg_orun_o              (sw_reg_orun),
       .reg_sel_o               (sw_reg_sel),
       .reg_wdata_err_o         (sw_reg_wdata_err),
       .reg_readok_o            (sw_reg_readok),
       .stickyerr_clr_o         (sw_stickyerr_clr),
       .linereset_o             (sw_linereset)
      );

    assign swdo      = sw_swdo;
    assign swdo_en   = sw_swdoen;
    assign linereset = sw_linereset;


  end
  else begin : NO_SW_PROTOCOL_ENGINE
    assign swdo = 0;
    assign swdo_en = 0;
    assign linereset = 0;

    assign sw_bus_wdata             = 0;
    assign sw_bus_addr              = 0;
    assign sw_bus_write             = 0;
    assign sw_bus_req_int           = 0;
    assign sw_bus_req_int_reject    = 0;
    assign sw_reg_wdata             = 0;
    assign sw_reg_addr              = 0;
    assign sw_reg_write             = 0;
    assign sw_reg_orun              = 0;
    assign sw_reg_sel               = 0;
    assign sw_reg_wdata_err         = 0;
    assign sw_reg_readok            = 0;
    assign sw_stickyerr_clr         = 0;

  end
endgenerate


  css600_dpslv_reg_block
    #(.JTAG_DP   (JTAG_DP),
      .SW_DP     (SW_DP),
      .ADDR_SIZE (ADDR_SIZE))
    u_css600_dpslv_reg_block
      (
       .swclktck                (swclktck),
       .porst_n                 (porst_n),

       .reg_wdata_i             (reg_wdata),
       .reg_addr_i              (reg_addr),
       .reg_write_i             (reg_write),
       .reg_orun_i              (reg_orun),
       .reg_sel_i               (reg_sel),
       .reg_wdata_err_i         (reg_wdata_err),
       .reg_readok_i            (reg_readok),
       .stickyerr_clr_i         (stickyerr_clr),
       .jtagactive_i            (jtagactive),
       .swactive_i              (swactive),
       .dp_eventstatus_i        (dp_eventstatus_sync),
       .cdbgpwrupack_i          (cdbgpwrupack_sync),
       .csyspwrupack_i          (csyspwrupack_sync),
       .cdbgrstack_i            (cdbgrstack_sync),
       .bus_err_set_i           (bus_err_set),
       .bus_rdata_i             (bus_rdata),
       .targetid_i              (targetid),
       .instanceid_i            (instanceid),
       .baseaddr_i              (baseaddr),
       .baseaddr_valid_i        (baseaddr_valid),
       .linereset_i             (linereset),

       .reg_rdata_o            (reg_rdata),
       .reg_stky_err_o         (reg_stky_err),
       .reg_select_dpbanksel_o (reg_select_dpbanksel),
       .reg_dlpidr_o           (reg_dlpidr),
       .reg_targetid_o         (reg_targetid),
       .cdbgpwrupreq_o         (cdbgpwrupreq),
       .csyspwrupreq_o         (csyspwrupreq),
       .cdbgrstreq_o           (cdbgrstreq),
       .reg_paddr_o            (reg_paddr),
       .dp_abort_o             (dp_abort_int),
       .reg_orundetect_o       (reg_orundetect),
       .reg_wdataerr_o         (reg_wdataerr),
       .sw_trn_o               (reg_sw_trn)
    );


  css600_pulseasyncbridgeslv_qactive_only #(
    .WIDTH (1),
    .FF_SYNC_DEPTH (SYNC_DEPTH)
  ) u_css600_pulseasyncbridgeslv_qactive_only
  (
    .clk_s        (swclktck),
    .reset_s_n    (porst_n),
    .pulse_in     (dp_abort_int),
    .pulse_req    (dp_abort_req),
    .pulse_ack    (dp_abort_ack),
    .clk_s_qactive()
  );

      assign bus_wdata           = ({32{jtagactive}} & jt_bus_wdata) |
                                   ({32{swactive}}   & sw_bus_wdata);

      assign bus_addr            = ({2{jtagactive}} & jt_bus_addr) |
                                   ({2{swactive}}   & sw_bus_addr);

      assign bus_write           = (jtagactive & jt_bus_write) |
                                   (swactive   & sw_bus_write);

      assign bus_load_int        = (jtagactive & jt_bus_load_int) |
                                   (swactive   & sw_bus_load_int);

      assign bus_req_int         = (jtagactive & jt_bus_req_int) |
                                   (swactive   & sw_bus_req_int);

      assign bus_req_int_reject  = (jtagactive & jt_bus_req_int_reject) |
                                   (swactive   & sw_bus_req_int_reject);

      assign reg_wdata           = ({32{jtagactive}} & jt_reg_wdata) |
                                   ({32{swactive}}   & sw_reg_wdata);

      assign reg_addr            = ({2{jtagactive}} & jt_reg_addr) |
                                   ({2{swactive}}   & sw_reg_addr);

      assign reg_write           = (jtagactive & jt_reg_write) |
                                   (swactive   & sw_reg_write);

      assign reg_orun            = (jtagactive & jt_reg_orun) |
                                   (swactive   & sw_reg_orun);

      assign reg_sel             = (jtagactive & jt_reg_sel) |
                                   (swactive   & sw_reg_sel);

      assign reg_wdata_err       = (swactive   & sw_reg_wdata_err);

      assign reg_readok          = (swactive   & sw_reg_readok);

      assign stickyerr_clr       = (jtagactive & jt_stickyerr_clr) |
                                   (swactive   & sw_stickyerr_clr);


  css600_dpslv_sync
    #(.SYNC_DEPTH (SYNC_DEPTH))
   u_css600_dpslv_sync
   (
    .swclktck          (swclktck),
    .porst_n           (porst_n),

    .cdbgpwrupack_i    (cdbgpwrupack),
    .csyspwrupack_i    (csyspwrupack),
    .cdbgrstack_i      (cdbgrstack),
    .dp_eventstatus_i  (dp_eventstatus),

    .cdbgpwrupack_o    (cdbgpwrupack_sync),
    .csyspwrupack_o    (csyspwrupack_sync),
    .cdbgrstack_o      (cdbgrstack_sync),
    .dp_eventstatus_o  (dp_eventstatus_sync)

    );


  css600_dpslv_cdc
    #(.ADDR_SIZE (ADDR_SIZE),
      .SYNC_DEPTH (SYNC_DEPTH)
     )
    u_css600_dpslv_cdc
     (
      .swclktck                 (swclktck),
      .porst_n                  (porst_n),

      .bus_wdata_i              (bus_wdata),
      .bus_addr_i               (bus_addr),
      .bus_write_i              (bus_write),
      .bus_load_int_i           (bus_load_int),
      .bus_req_int_i            (bus_req_int),
      .bus_req_int_reject_i     (bus_req_int_reject),
      .reg_paddr_i              (reg_paddr),
      .bus_ack_payload_i        (bus_ack_payload),
      .bus_ack_i                (bus_ack),
      .swactive_rise_i          (swactive_rise),

      .bus_rdata_o              (bus_rdata),
      .bus_err_set_o            (bus_err_set),
      .bus_req_o                (bus_req),
      .bus_req_payload_o        (bus_req_payload),
      .bus_req_int_rising_o     (sw_bus_load_int),
      .bus_ack_int_o            (bus_ack_int),
      .bus_pwr_int_o            (bus_pwr_int)

    );


endmodule

